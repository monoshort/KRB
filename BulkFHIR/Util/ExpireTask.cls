Include (HS.BulkFHIR, %ZHSLIB)

Class HS.BulkFHIR.Util.ExpireTask Extends %SYS.Task.Definition
{

Method OnTask() As %Status
{
	set sc = $$$OK
	try {
		set sessions = ##class(HS.BulkFHIR.Session).GetExpiredSessions()
		for i=1:1:sessions.Count() {
			#dim session As HS.BulkFHIR.Session = sessions.GetAt(i)
			do ##class(HS.BulkFHIR.Service).Purge(session)
		}
	} catch ex {
		set sc = ex.AsStatus()
	}
	try {
		Do ##class(HS.BulkFHIR.Fetch.Util.RateLimiter).Cleanup()
	} catch ex {
		Set sc = $$$ADDSC(sc,ex.AsStatus())
	}
	try {
		/// configurations that have been deleted that are waiting for the files to purge before the app can be deleted
		Do ##class(HS.BulkFHIR.Installer).CleanupOutstandingEndpoints()
	} catch ex {
		Set sc = $$$ADDSC(sc,ex.AsStatus())
	}

	return sc
}

ClassMethod Schedule(namespace As %String) As %Status
{
	set sc = $$$OK
	try {
		#dim task As %SYS.Task
		
		set this = ..%ClassName(1)
		&sql(SELECT ID INTO :id FROM %SYS.Task WHERE TaskClass = :this AND NameSpace = :namespace)
		if id '= "" {
			set task = $system.Task.%OpenId(id)
		}
		else {
			set task = $system.Task.%New()
		}
		
		set task.Name = "Bulk FHIR expiration task"
		set task.Description = "Periodically checks for FHIR export operations whose results have expired and can therefore be deleted."
		set task.TaskClass = ..%ClassName(1)
		set task.NameSpace = namespace
		set task.RunAsUser = $$$HSTaskUserName
		set task.DailyFrequency = task.DailyFrequencyDisplayToLogical("Several")
		set task.DailyFrequencyTime = task.DailyFrequencyTimeDisplayToLogical("Hourly")
		set task.DailyIncrement = 1 //Every one hour
		set task.Expires = 0
		set task.RescheduleOnStart = 1
		set sc = task.%Save()
		quit:$$$ISERR(sc)
		
		do task.Resume(task.%Id())
	} catch ex {
		set sc = ex.AsStatus()
	}
	return sc
}

}
