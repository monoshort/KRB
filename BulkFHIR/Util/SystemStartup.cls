Class HS.BulkFHIR.Util.SystemStartup Extends HS.HC.Util.Installer.AbstractStartupClass
{

Parameter Name As STRING = "Bulk FHIR system startup";

Parameter ExecutionContext As INTEGER = 2;

ClassMethod OnSystemStartup()
{
	try {
		//Any sessions that were in progress during the system shutdown need
		//to be set to pending so they can be resumed
		set sessions = ##class(HS.BulkFHIR.Session).GetSessions("in-progress")
		for i=1:1:sessions.Count() {
			set session = sessions.GetAt(i)
			Do ##class(HS.BulkFHIR.ExportManager).CleanupSession(session)
			set session.status = "pending"
			$$$ThrowOnError(session.%Save())
		}
	} catch ex {
		$$$startupLogErr($system.Status.GetErrorText(ex.AsStatus()))
	}
	
	return
}

}
