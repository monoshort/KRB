/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonCloudWatchLogs.OutboundAdapter Extends (EnsLib.PEX.OutboundAdapter, EnsLib.Amazon.Common) [ ClassType = "", Inheritance = right, ProcedureBlock, System = 4 ]
{

Method OnInit() As %Status
{
	Set ..%remoteClassname = "com.intersystems.cloud.amazonCWLogs.OutboundAdapter"
	Set ..%gatewayName = "%Java Server"
	Set ..%gatewayExtraClasspaths = ..GetCloudClientJARPaths()
	Quit ##super()
}

Method PutLogEvents(logGroupName As %String, logStreamName As %String, logMessage As %String, logTimestamp As %Library.TimeStamp, Output nextToken As %String) As %Status
{
	Set tSC = $$$OK
	Try {
		Set nextToken = ..%gatewayProxy.putLogEvents(logGroupName, logStreamName, logMessage, logTimestamp)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}
