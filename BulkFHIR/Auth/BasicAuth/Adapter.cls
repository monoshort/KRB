Class HS.BulkFHIR.Auth.BasicAuth.Adapter Extends HS.BulkFHIR.API.AuthAdapter
{

Parameter configClass = "HS.BulkFHIR.Auth.BasicAuth.Config";

Parameter IsOAuth As Boolean = 0;

ClassMethod Initialize(pBFCconfig As HS.BulkFHIR.API.Data.Config)
{
}

ClassMethod Authenticate(pBFCConfig As HS.BulkFHIR.API.Data.Config, pUrl As %String, ByRef pContinue As %Boolean) As %Status
{
	Set sc = $$$OK
	
	Set httpStatus = ""
	#dim authConfig As HS.BulkFHIR.Auth.BasicAuth.Config = $$$BFCAuthConfig(pBFCConfig)
	if ($p(%request.URL,"/",*) = "metadata") {
		// Basic auth has already been determined valid - is valid credentials
		// or is UnknownUser. If this is a metadata request, 
		// then no need for further checking.
		return sc
	}
	if ($username = "UnknownUser") {
		Set httpStatus = ..#HTTP401UNAUTHORIZED
		Set failText = "Valid Basic Auth credentials not provided"
	}
	
	If httpStatus '= "" {
		Set pContinue = 0
		do ##class(HS.BulkFHIR.Util).LogAuthFail(httpStatus, failText, %request)
		Set %response.Status = httpStatus
	}
	
	// No need to alter sc for this method.
	Return sc
}

}
