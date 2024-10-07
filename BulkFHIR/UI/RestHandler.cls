Include (HS.BulkFHIR, HSMOD.REST.Errors, HSMOD.REST)

/// Dispatch class for all UI REST requests
Class HS.BulkFHIR.UI.RestHandler Extends (%CSP.REST, HS.BulkFHIR.Util)
{

Parameter HandleCorsRequest As Integer = 1;

Parameter CHARSET = "UTF-8";

Parameter UseSession As BOOLEAN = 0;

XData UrlMap
{
<Routes>
	<Map Prefix="/v2" Forward="HS.BulkFHIR.UI.REST.v2"/>
	<Map Prefix="/v1" Forward="HS.BulkFHIR.UI.REST.v1"/>
	<!-- The following mapping is for API requests with no version info (prior to IRIS 2023.3) -->
	<Map Prefix="(?=)" Forward="HS.BulkFHIR.UI.REST.v1"/>
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
	Quit sc
}

/// Output either response or error message in a standard way
ClassMethod Response(pResponse = "", pSC = "") As %Status
{
	Set %response.ContentType = "application/json"
	If $$$ISERR(pSC) {
		Do ..httpStatusResponse(pSC)
		Quit $$$OK
	}
    If $isobject(pResponse) {
        If pResponse.%IsA("%DynamicAbstractObject") {
            Do pResponse.%ToJSON()
        } Else {
			// We don't support any other object types, so just write it as string to help with debugging
            Write pResponse
        }
    } Else {
       Write pResponse 
    }
	Quit $$$OK
}

/// Same response handler as HSMOD.REST.Base, but always send response body with error description
ClassMethod httpStatusResponse(pSC As %Status) As %Boolean
{
	Set tSCDecompose = $system.Status.DecomposeStatus(pSC,.errlist)
	If $$$ISERR(tSCDecompose) {
		Set %response.Status = $$$HTTPStatus("500InternalServerError","DecomposeStatus("_pSC_")")
		Quit
	}
	Set tHTTPStatus = "", tHadErr = 0
	
	// If pSC is $$$OK then errlist is empty and we don't loop. 
	For i = +$get(errlist):-1:1 {  
		Set code = $get(errlist(i,"code"))
		Set tHadErr = 1
		If "<HTTPStatus>" = $extract(code,1,$length("<HTTPStatus>")) {
			// just use that code, but trim out whitespace
			Set tHTTPStatus = $ZStrip($system.Status.GetOneStatusText(pSC,i),"<>W")
		} ElseIf code = $$$HSFHIRErrHttpOnlyResponse {
			Set tHTTPStatus = $p($get(errlist(i,"param",1)),"|",2)
		} Else {
			// Decorate %Status code with a reasonably representative HTTP status code.
			Set tHTTPError = $case(code,
												// Gateway issues
							$$$ClassDoesNotExist:$$$ERROR($$$HTTPStatus502BadGateway,": ClassDoesNotExist"),
							$$$MethodDoesNotExist:$$$ERROR($$$HTTPStatus502BadGateway,": MethodDoesNotExist"),
												// Resource Not Found errors
							$$$LoadObjectNotFound:$$$ERROR($$$HTTPStatus404NotFound,": LoadObjectNotFound"),
						$$$DeleteObjectNotFound:$$$ERROR($$$HTTPStatus404NotFound,": DeleteObjectNotFound"),
						$$$KeyValueNotFoundOpen:$$$ERROR($$$HTTPStatus404NotFound,": KeyValueNotFoundOpen"),
						$$$KeyValueNotFoundDelete:$$$ERROR($$$HTTPStatus404NotFound,": KeyValueNotFoundDelete"),
								$$$KeyNotFound:$$$ERROR($$$HTTPStatus404NotFound,": KeyNotFound"),
							$$$NotAnInstanceError:$$$ERROR($$$HTTPStatus404NotFound,": NotAnInstance"),
							$$$QueryDoesNotExist:$$$ERROR($$$HTTPStatus404NotFound,": QueryDoesNotExist"),
												// Validation (e.g. bad request) issues
							$$$InvalidArgument:$$$ERROR($$$HTTPStatus400BadRequest,": InvalidArgument"),
					$$$DatatypeValidationFailed:$$$ERROR($$$HTTPStatus400BadRequest,": DatatypeValidationFailed"),
								$$$DTValueList:$$$ERROR($$$HTTPStatus400BadRequest,": DTValueList"),
							$$$PropertyRequired:$$$ERROR($$$HTTPStatus400BadRequest,": PropertyRequired"),
								$$$IDKeyNotUnique:$$$ERROR($$$HTTPStatus400BadRequest,": IDKeyNotUnique"),
								$$$KeyNotUnique:$$$ERROR($$$HTTPStatus400BadRequest,": KeyNotUnique"),
												// No mapping ...
												:$$$OK)

			If $$$ISERR(tHTTPError) { 
				// we found an error status in the sieve; use it. (If not, we will continue looping)
				Set tHTTPStatus = $$$HTTPERRStatus(tHTTPError)
			}
		}
		If $length(tHTTPStatus) { 
			Quit
		}
	}
	
	// If we found an HTTP status error or a recognizable common error, then tHTTPStatus contains an error DESCRIPTION string. 
	// otherwise it's still "". So we Set the response status as follows: 
	// If tHTTPStatus is nonempty, use that. (HTTPStatus or common Ensemble/CSP/Cache problems, but we also want this for module-specific replacements)
	// otherwise, If the loop executed because there was an error of some kind (tHadErr), we clobber it with a 500 internal for the http response, 
	// and we want to stuff a JSON representation of the real error into the output. 
	// Otherwise (no error) we Set the response status to 200 OK. 
	 
	Set %response.Status = $select((tHTTPStatus'=""):tHTTPStatus
							, tHadErr:$$$HTTPStatus("500InternalServerError")
							, 1:$$$HTTPStatus("200OK"))
	If (tHadErr && ('$System.Status.Equals(pSC,$$$HSFHIRErrHttpOnlyResponse)) && $$$ISOK(..StatusToJSON(pSC,.tSCDetailObj))) 
	{
		Do tSCDetailObj.%ToJSON()
	}
	Quit tHadErr
}

}
