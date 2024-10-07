/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Include Ensemble

Class Ens.Util.Tasks.Purge Extends %SYS.Task.Definition [ System = 4 ]
{

Parameter RESOURCE = "%Ens_PurgeSchedule:USE";

/// How many days of messages should not be purged
Property NumberOfDaysToKeep As %Integer(MINVAL = 0) [ InitialExpression = 7 ];

/// Preserve messages not yet completely processed
Property KeepIntegrity As %Boolean [ InitialExpression = 1 ];

/// Delete message bodies whenever their message header is deleted. This is off by default because some Productions may
/// use message objects that are part of a larger environment and not transitory.
Property BodiesToo As %Boolean [ InitialExpression = 0 ];

/// The type of thing to purge
Property TypesToPurge As %String(DISPLAYLIST = ",All Types,Events,Messages,Business Processes,Rule Logs,I/O Logs,Host Monitor Data,Managed Alerts", VALUELIST = ",all,events,messages,processes,rulelogs,iologs,hostcounters,managedalerts") [ InitialExpression = "events", Required ];

/// For purging messages it is possible to split the purge into
/// multiple batches and submit to the Work Queue Manager.
/// Specify a Work Queue Category name to use this feature.
/// If an invalid category is entered then the Default category is used.
/// The splitting of the purge into categories can be tuned using 
/// optionalMessageWQBatchSize
Property optionalMessageWorkQueueCategory As %String;

/// If optionalMessageWorkQueueCategory then this gives
/// the number of messages to split into multiple jobs (exclusive of 
/// completeness or config item name requirements) as starting batch lists.
/// The default if not specified is 100000.
/// The minimum count applied will be 10000
Property optionalMessageWorkQueueBatchSize As %Integer;

/// A comma separated list of production host items that if defined will
///  limit the purge to SourceConfigName or TargetConfigName contained in the list
Property optionalMessageLimitToConfigItems As %String(MAXLEN = 10000);

/// Used to record deleted count arrays for testing purposes
Property %DeletedCount As %String [ Internal, MultiDimensional ];

Property %CalledFromUnitTest As %Boolean [ Internal ];

/// Setting this property to 1 allows logging the purge status in the operator console messages (messages.log). 
/// This status can also be seen on the SMP under: System Operation->System Logs->Messages Log
Property UseSystemMessagesLog As %Boolean [ InitialExpression = 0 ];

/// The OnTask() method is called to execute the task
Method OnTask() As %Status
{
	Set tTime = $ZH
    Set tDeletedCount = -1
    Set tBitmapCount = 0

	/* Configure extended message purge options */
	If (..TypesToPurge = "all") || (..TypesToPurge = "messages") {
		If ..optionalMessageWorkQueueCategory'="" {
			Set tExtendedOptions("WQCategory") = ..optionalMessageWorkQueueCategory
			If +..optionalMessageWorkQueueBatchSize {
				Set tExtendedOptions("WQBatchSize") = ..optionalMessageWorkQueueBatchSize
			}
		}
		If ..optionalMessageLimitToConfigItems'="" Set tExtendedOptions("LimitToConfigItems") = ..optionalMessageLimitToConfigItems
	}

    If ..TypesToPurge = "all" {
		Set tSC = ##class(Ens.Purge).PurgeAll(.tDeletedCount,..NumberOfDaysToKeep,..KeepIntegrity,..BodiesToo,/* default BitmapChunkLimit*/,.tExtendedOptions)
		If ..%CalledFromUnitTest Merge ..%DeletedCount = tDeletedCount
		Set (type,tDeletedCount)="" For { Set type=$O(tDeletedCount(type),1,count)  Quit:""=type  Continue:'count
			Set tDeletedCount=tDeletedCount_", "_count_" "_type
		} 
		Set tDeletedCount=$E(tDeletedCount,3,$L(tDeletedCount)) // get rid of the leading comma and space
		Set tBitmapCount = -1
    } ElseIf ..TypesToPurge = "events" {
		Set tSC = ##class(Ens.Purge).PurgeEventLogsByDate(..NumberOfDaysToKeep,.tDeletedCount,..KeepIntegrity)
    } ElseIf ..TypesToPurge = "messages" {
		Set tSC = ##class(Ens.Purge).PurgeMessagesByDate(..NumberOfDaysToKeep,.tDeletedCount,..KeepIntegrity,..BodiesToo,.tExtendedOptions)
		If ..%CalledFromUnitTest Merge ..%DeletedCount = tDeletedCount
		Set tDeletedCount=tDeletedCount_$S($G(tDeletedCount("bodies")):"("_tDeletedCount("bodies")_" bodies)",1:"")
    } ElseIf ..TypesToPurge = "processes" {
		Set tSC = ##class(Ens.Purge).PurgeBusinessProcessesByDate(..NumberOfDaysToKeep,.tDeletedCount,..KeepIntegrity)
    } ElseIf ..TypesToPurge = "rulelogs" {
		Set tSC = ##class(Ens.Purge).PurgeRuleLogsByDate(..NumberOfDaysToKeep,.tDeletedCount,..KeepIntegrity)
    } ElseIf ..TypesToPurge = "iologs" {
		Set tSC = ##class(Ens.Util.IOLog).Purge(.tDeletedCount,..NumberOfDaysToKeep,..KeepIntegrity) 
    } ElseIf ..TypesToPurge = "hostcounters" {
		Set tSC = ##class(Ens.MonitorService).Purge(.tDeletedCount,..NumberOfDaysToKeep,..KeepIntegrity)
    } ElseIf ..TypesToPurge = "managedalerts" {
	    Set tSC = ##class(Ens.Alerting.ManagedAlert).Purge(.tDeletedCount,..NumberOfDaysToKeep,..KeepIntegrity)
    } ElseIf $ZStrip(..TypesToPurge,"*WC") = "" {
		Set tSC = $$$ERROR($$$EnsErrGeneral,"No TypesToPurge specified")
    } Else {
		Set tSC = $$$ERROR($$$EnsErrGeneral,"Unrecognized TypesToPurge value '"_..TypesToPurge_"'") 
    }
    Set tTime = $ZH - tTime
	If ..%CalledFromUnitTest && (..TypesToPurge'="all") && (..TypesToPurge'="messages") Merge ..%DeletedCount = tDeletedCount
    If $$$ISOK(tSC) {
		If (tBitmapCount = 0) {
			Set tBitmapCount = +$G(tDeletedCount("bitmaps"))
		}
        Set purgeStatus = "Purged "_tDeletedCount_" "_..TypesToPurgeLogicalToDisplay(..TypesToPurge)_$S(tBitmapCount>0: " and "_tBitmapCount_" bitmap chunks", 1: "")_" keeping the last "_..NumberOfDaysToKeep_" days with KeepIntegrity="_..KeepIntegrity_$S($Case(..TypesToPurge,"all":1,"messages":1,:0):" and BodiesToo="_..BodiesToo,1:"")_" in "_tTime_"s"
        $$$LOGINFO(purgeStatus)
		Do:..UseSystemMessagesLog ##class(%SYS.System).WriteToConsoleLog(purgeStatus, 0, 0, "Interop.Purge")
	}
	Else { 
		Set purgeStatus = "Error purging"_..TypesToPurgeLogicalToDisplay(..TypesToPurge)_" keeping the last "_..NumberOfDaysToKeep_" days with KeepIntegrity="_..KeepIntegrity_$S($Case(..TypesToPurge,"all":1,"messages":1,:0):" and BodiesToo="_..BodiesToo,1:"")_" : "_ $$$StatusDisplayString(tSC)
		$$$LOGERROR(purgeStatus) 
		Do:..UseSystemMessagesLog ##class(%SYS.System).WriteToConsoleLog(purgeStatus, 0, 0, "Interop.Purge")
	}
	Quit tSC
}

/// Purge the message store, and event log
ClassMethod PurgeAll(pTypesToPurge As %String = "all", pNumberOfDaysToKeep As %Integer = 0, pBodiesToo As %Boolean = 1) As %Status
{
	Set tTask = ..%New()
	Set tTask.TypesToPurge = pTypesToPurge
	Set tTask.NumberOfDaysToKeep = pNumberOfDaysToKeep
	Set tTask.BodiesToo = pBodiesToo
	Quit tTask.OnTask()
}

}
