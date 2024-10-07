Include %ZHSLIB

Class HS.BulkFHIR.Util.PurgeExpiredSearchResultsTask Extends %SYS.Task.Definition
{

/// How many minutes after a paged search result is last interacted with should it be kept in the cache (Currently stored in ^IRIS.Temp.BulkFHIRSearchResult)
Property MinutesToKeep As %Integer [ InitialExpression = 60 ];

Method OnTask() As %Status
{
    Set status =  $$$OK
    Try {
        Set status = ##class(HS.BulkFHIR.Util.SearchResult).PurgeCachedResults(..MinutesToKeep)
    }
    Catch(ex) {
        Set status = ex.AsStatus()
    }
    If ($$$ISERR(status)) {
        Set text = "Error running "_$CLASSNAME()_". Beware of potential for unchecked growth in IRISTEMP database"
        Do ##class(%SYS.System).WriteToConsoleLog(text,,2)
    }
    Return status
}

/// Schedule the task to run if it isn't defined.
/// Default is to run hourly and purge cached search results that are older than an hour.
ClassMethod Schedule(pNamespace As %String = "HSSYS") As %Status
{
    Set status = $$$OK
	Try {
		#dim task As %SYS.Task
		
		set this = $ClassName()
		&sql(SELECT ID INTO :id FROM %SYS.Task WHERE TaskClass = :this AND NameSpace = :pNamespace)

		If id '= "" {
			Quit
		}
		Else {
			Set task = $system.Task.%New()
		}
		
		Set task.Name = "Bulk FHIR Purge Expired Search Results Task"
		Set task.Description = "Periodically checks for cached Bulk FHIR Search results that have have exceeded the configured duration since last being interacted with and purges them from IRISTEMP"
		Set task.TaskClass = $ClassName()
		Set task.NameSpace = pNamespace
		Set task.RunAsUser = $$$HSTaskUserName
		Set task.DailyFrequency = task.DailyFrequencyDisplayToLogical("Several")
		Set task.DailyFrequencyTime = task.DailyFrequencyTimeDisplayToLogical("Hourly")
		Set task.DailyIncrement = 1 //Every one hour
		Set task.Expires = 0
		Set task.RescheduleOnStart = 1
		Set status = task.%Save()
		Quit:$$$ISERR(status)
		
		Do task.Resume(task.%Id())
	} catch ex {
		Set status = ex.AsStatus()
	}
	Return status
}

}
