Include HS.BulkFHIR

Class HS.BulkFHIR.Storage.File.RestHandler Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap
{
<Routes>
<Route Url="/:filename"			Method="GET" 		Call="GetFile"/>
</Routes>
}

/// Override of %CSP.REST OnPreDispatch(). This method gets called prior to dispatch
/// of EVERY request. If this method sets pContinue to 0, the request will NOT be
/// dispatched according to the UrlMap. In that case it is the responsibility of
/// this method to return a response.
ClassMethod OnPreDispatch(pUrl As %String, pMethod As %String, ByRef pContinue As %Boolean) As %Status
{
	Set sc = $$$OK
	Set %bfcRESTSecurity=##class(HS.FHIRServer.API.Data.Request).%New()
	Set sessionId = ##class(HS.BulkFHIR.Storage.File.Adapter).SessionIdForFilename($E(pUrl,2,*))
	Set session = ##class(HS.BulkFHIR.Session).getBySessionId(sessionId)
	Set config = session.configuration

	Set sc = $classmethod($$$BFCAuthClass(config), "Authenticate", config, pUrl, .pContinue)
	Do:'pContinue ..OnHandleCorsRequest(pUrl)
	if (pMethod = "GET") && $IsObject($Get(%session)) {
		// Permit concurrent GET requests.
		// This call is ineffectual if %CSP.REST UseSession=0.
		do %session.Unlock()
	}
	
	If 'pContinue {
		// Do logging only if we are not proceeding to main processing for this REST handler.
		Set methodDesc = "["_ $$$CurrentClass _":"_ $$$CurrentMethod _"]"
		//TODO: centralize LogCSPRequest / response methods
		Do ##class(HS.BulkFHIR.RestHandler).LogCSPRequest(methodDesc, 1)
		Do ##class(HS.BulkFHIR.RestHandler).LogCSPResponse(methodDesc, 1)
	}
	
	quit sc
}

ClassMethod GetFile(filename As %String) As %Status
{
	Try {
		Set sessionId = ##class(HS.BulkFHIR.Storage.File.Adapter).SessionIdForFilename(filename)
		Set session = ##class(HS.BulkFHIR.Session).getBySessionId(sessionId)
		Set stream = ##class(HS.BulkFHIR.Storage.File.Adapter).GetFile(session,filename)
		If stream.Size = 0 {
			Set %response.Status = 404
			Return $$$OK
		}
		
		Set %response.ContentType = "application/fhir+ndjson"
		While 'stream.AtEnd {
			Write stream.Read()
		}
	} Catch ex {
		New %FHIRDebugIncludeTracebacks
		Set %FHIRDebugIncludeTracebacks=1
		Set outcome = ##class(HS.FHIRServer.Util.Outcome).CreateFromStatus(ex.AsStatus(), .httpStatus)
		Set %response.Status = httpStatus
		
		If $ISOBJECT(outcome) {
			Set %response.ContentType = "application/json"
			Write outcome.%ToJSON()
		}		
	}
	
	Return $$$OK
}

}
