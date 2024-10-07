Include HS.BulkFHIR

Class HS.BulkFHIR.RestHandler Extends %CSP.REST
{

Parameter HandleCorsRequest As Integer = 1;

XData UrlMap
{
<Routes>
<Route Url="/status/:sessionId"					Method="GET" 		Call="Status"/>
<Route Url="/status/:sessionId"					Method="DELETE" 	Call="Cancel"/>
<Route Url="/.well-known/smart-configuration"	Method="GET" 		Call="WellKnown"/>
<Route Url="/(.*)"  							Method="GET" 		Call="ProcessFHIRRequest"/>
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
	Do ..GetExactCase(.exactCaseApp, .exactCasePrefix)
	Set sessionApplication = $$$AppKeyFromApp(exactCaseApp)
	Set configuration = ##class(HS.BulkFHIR.Configuration).GetConfiguration( sessionApplication )
	If '$ISOBJECT(configuration) {
		Set pContinue = 0 
	} Else { 
		Set sc = $classmethod($$$BFCAuthClass(configuration), "Authenticate", configuration, pUrl, .pContinue)
	}
	Do:'pContinue ..OnHandleCorsRequest(pUrl)
	if (pMethod = "GET") && $IsObject($Get(%session)) {
		// Permit concurrent GET requests.
		// This call is ineffectual if %CSP.REST UseSession=0.
		do %session.Unlock()
	}
	
	If 'pContinue {
		// Do logging only if we are not proceeding to main processing for this REST handler.
		Set methodDesc = "["_ $$$CurrentClass _":"_ $$$CurrentMethod _"]"
		Do ..LogCSPRequest(methodDesc, 1)
		Do ..LogCSPResponse(methodDesc, 1)
	}
	
	quit sc
}

ClassMethod Status(sessionId As %String) As %Status
{
	Try {
		Set classAndMethod = "["_ $$$CurrentClass _":"_ $$$CurrentMethod _"]"
		Do ..LogCSPRequest(classAndMethod, 1)
		
		If '..VerifyJsonAccept() {
			Quit
		}
		
		// Pass the full base url (scheme, host, port, url), as specified by the REST client, to Status().
		Set baseUrl = ##class(HS.Local.BulkFHIR.Util.BaseURL).GetBaseURL(%request)
		
		Do ##class(HS.BulkFHIR.Service).Status(sessionId, baseUrl, .status, .retryAfter, .expires, .json, .httpStatus)
		Set %response.Status = httpStatus
		If status '= "" {
			Do %response.SetHeader("X-Progress", status)
		}
		If retryAfter '= "" {
			Do %response.SetHeader("Retry-After", retryAfter)
		}
		If expires '= "" {
			Do %response.SetHeader("Expires", expires)
		}
		If json '= "" {
			Set %response.ContentType = "application/json"
			Do json.%ToJSON()
		}
		
	} Catch ex {
		New %FHIRDebugIncludeTracebacks
		Set %FHIRDebugIncludeTracebacks=1
		Set outcome = ##class(HS.FHIRServer.Util.Outcome).CreateFromStatus(ex.AsStatus(), .httpStatus)
		Set %response.Status = httpStatus
		
		If $ISOBJECT(outcome) {
			Set %response.ContentType = "application/json"
			Do outcome.%ToJSON()
		}
	}
	
	Do ..LogCSPResponse(classAndMethod, 1)
	
	Return $$$OK
}

ClassMethod Cancel(sessionId As %String) As %Status
{
	Try { 		
		Set classAndMethod = "["_ $$$CurrentClass _":"_ $$$CurrentMethod _"]"
		Do ..LogCSPRequest(classAndMethod, 1)
		
		If '..VerifyJsonAccept() {
			Quit
		}
		
		Do ##class(HS.BulkFHIR.Service).Cancel(sessionId)
		Set httpStatus = 202
		Set %response.Status = httpStatus
	} Catch ex {
		New %FHIRDebugIncludeTracebacks
		Set %FHIRDebugIncludeTracebacks=1
		Set outcome = ##class(HS.FHIRServer.Util.Outcome).CreateFromStatus(ex.AsStatus(), .httpStatus)
		Set %response.Status = httpStatus
		
		If $ISOBJECT(outcome) {
			Set %response.ContentType = "application/json"
			Do outcome.%ToJSON()
		}
	}
	
	Do ..LogCSPResponse(classAndMethod, 1)
	
	Return $$$OK
}

ClassMethod WellKnown() As %Status
{
	Do ..GetExactCase(.exactCaseApp, .exactCasePrefix)
	Set sessionApplication = $$$AppKeyFromApp(exactCaseApp)
	Set configuration = ##class(HS.BulkFHIR.Configuration).GetConfiguration( sessionApplication )

	Set classAndMethod = "["_ $$$CurrentClass _":"_ $$$CurrentMethod _"]"
	Do ..LogCSPRequest(classAndMethod, 1)
	
	If '..VerifyJsonAccept() {
		Do ..LogCSPResponse(classAndMethod, 1)
		Return $$$OK
	}
	
	Set wellKnown = $CLASSMETHOD($$$BFCAuthClass(configuration), "WellKnownConfiguration", configuration)
	If 'wellKnown.%Size(){
		Set %response.Status = 500
		Return $$$OK
	}
	Set %response.ContentType = "application/json"
	Do wellKnown.%ToJSON()
	
	Do ..LogCSPResponse(classAndMethod, 1)
	
	Return $$$OK
}

/// Verify that the Accept header includes application/json and/or */*.
ClassMethod VerifyJsonAccept() As %Boolean
{
	Set ok = 0
	
	Set acceptHeader = %request.GetCgiEnv("HTTP_ACCEPT")
	
	For i = 1:1:$LENGTH(acceptHeader, ";") {
		Set p  = $PIECE(acceptHeader, ";", i)
		If ((p = "application/json") || (p = "application/fhir+json") || (p = "*/*")) {
			Set ok = 1
			Quit
		}
	}
	If 'ok {
		Set %response.ContentType = "text/plain"
		Set %response.Status = 406
		Write $SYSTEM.Status.GetErrorText($$$ERROR($$$HSFHIRErrInvalidAcceptSpec))
	}
	
	Return ok
}

ClassMethod ProcessFHIRRequest(pRequestPath As %String) As %Status
{
	#dim outputStream as %Stream.Object = ##class(HS.FHIRServer.Util.DeviceStream).%New()
	Try {
		#dim request As HS.FHIRServer.API.Data.Request = ##class(HS.FHIRServer.API.Data.Request).%New()
		#dim response As HS.FHIRServer.API.Data.Response = request.NewResponse()

		Set classAndMethod = "["_ $$$CurrentClass _":"_ $$$CurrentMethod _"]"
		Do ..LogCSPRequest(classAndMethod, 1)
		
		Set request.RequestPath = pRequestPath
		Do ..marshallRequestFromHttp(request)
		
		If ($Piece(%request.URL, "/", *) = "$export") {
			If '..VerifyJsonAccept() {
				Return $$$OK
			}
			
		} Else {
			Set request.ResponseFormatCode =  ##class(HS.FHIRServer.RestHandler).determineOutputFormatCode()
		}
		
		If %request.Secure {
			Set accessToken = ##class(%SYS.OAuth2.AccessToken).GetAccessTokenFromRequest(.tSC)
			$$$ThrowOnError(tSC)
			If accessToken '= "" {
				Do request.AdditionalInfo.SetAt(accessToken, "USER:OAuthToken")
			}
		}
		
		Do ##class(HS.BulkFHIR.Service).ProcessFHIRRequest(request, .response)
		
		Do ..marshallResponseHeaders(response)
		
	} Catch ex {
		New %FHIRDebugIncludeTracebacks
		Set %FHIRDebugIncludeTracebacks=1
		Set outcome = ##class(HS.FHIRServer.Util.Outcome).CreateFromStatus(ex.AsStatus(), .httpStatus)
		Set %response.Status = httpStatus

		Set response = request.NewResponse()
		Set response.ResponseFormatCode = request.ResponseFormatCode
		Set response.IsPrettyOut = 1
		Set response.Json = outcome
	}
	
	Do ..WriteResponse(response.Json, request.ResponseFormatCode, 1, outputStream, .%response)
	
	Do ..LogCSPResponse(classAndMethod, 1)
	
	Return $$$OK
}

/// 
/// Marshall the incoming FHIR REST request into a message ready for dispatch to the FHIR business service
/// 
ClassMethod marshallRequestFromHttp(pRequest As HS.FHIRServer.API.Data.Request) [ Internal ]
{
	#dim tKey As %String
	#dim tSubKey As %String
	#dim tItem As %String
	#dim tHeader As %String
	#dim %request As %CSP.Request

	Set pRequest.RequestMethod = %request.Method
	
	// Get the request URL in the casing as specified by the REST client.
	Do ..GetExactCase(.exactCaseApp, .exactCasePrefix)
	
	// Request object BaseURL is the full URL including scheme host, port and url as specified by the REST client.
	Set pRequest.BaseURL = ##class(HS.Local.BulkFHIR.Util.BaseURL).GetBaseURL(%request)
	Set pRequest.QueryString = ##class(HS.FHIRServer.API.Data.QueryParameters).CreateFromCSPRequest(%request).AsString(0)

	// The Session Application is the CSP App Key (the trailing slash is removed)
	Set pRequest.SessionApplication = $$$AppKeyFromApp(exactCaseApp)
	
	// Copy in HTTP header values used in the FHIR API
	Set pRequest.Prefer = %request.GetCgiEnv("HTTP_PREFER")	
	Do pRequest.AdditionalInfo.SetAt(%request.GetCgiEnv("REMOTE_ADDR"), "ClientAddr")
	Do pRequest.AdditionalInfo.SetAt(%request.Secure, "Secure")
	Do pRequest.AdditionalInfo.SetAt(%session.SessionId, "CSPSessionId")
	
	// For compatability, copy all HTTP_ headers into the AdditionalInfo section of the request
	Set tKey = ""
	For {
		Set tKey = $ORDER(%request.CgiEnvs(tKey))
		Quit:tKey=""
		
		If tKey?1"HTTP_"1.E {
			// Determine the proper header name (will be all caps unfortunately)
			Set tHeader = $PIECE(tKey,"HTTP_",2,*)
			
			// Copy the HTTP headers - except for certain ones.
			If (tHeader '= "AUTHORIZATION") {
				Do pRequest.AdditionalInfo.SetAt(%request.CgiEnvs(tKey), "HEADER:"_tHeader)
			}
		}
	}
}

/// Derive application base URL in the exact casing as specified by the REST client.
/// Return case-sensitive app URL, and prefix if any.
ClassMethod GetExactCase(Output pAppMatchExact As %String, Output pPrefixExact As %String) [ Internal ]
{
	Set pAppMatchExact = ""
	Set pPrefixExact = ""
	
	Set i = $Find($ZConvert(%request.URL, "L"), %request.AppMatch)
	Set start = (i - $Length(%request.AppMatch))
	
	Set pAppMatchExact = $Extract(%request.URL, start, i - 1)
	
	If start > 0 Set pPrefixExact = $Extract(%request.URL, 1, start-1)
	
	Quit
}

ClassMethod marshallResponseHeaders(pResponse As HS.FHIRServer.API.Data.Response) [ Internal ]
{
	#dim %response As %CSP.Response

	// Default the response to OK
	Set %response.Status = $SELECT(pResponse.Status="":200, 1:pResponse.Status)
	
	If pResponse.ContentLocation '= "" {
		Do %response.SetHeader( "Content-Location", pResponse.ContentLocation)
	}
	If pResponse.Location '= "" {
		Do %response.SetHeader( "Location", pResponse.Location)
	}
	
	If pResponse.ETag '= "" {
		Do %response.SetHeader( "ETag", pResponse.ETag)
	}
	If pResponse.LastModified '= "" {
		Do %response.SetHeader( "Last-Modified", pResponse.LastModified)
	}
	
	Quit
}

ClassMethod WriteResponse(json As %DynamicObject, pResponseFormatCode As %String, isPretty As %Boolean, pOutStream As %Stream.Object, ByRef pMimeObj)
{
	If $ISOBJECT(json) {
		// Set the Mime Headers in the response if there is content
		Set pMimeObj.ContentType = "application/fhir+json"
		Set pMimeObj.CharSet = "UTF-8"
		
		If isPretty {
			Set indent = $Char(9)
			Set lineEnd = $CHAR(13,10)
		} Else {
			Set indent = ""
			Set lineEnd = ""
		}
		If (pResponseFormatCode = $$$FHIRContentCodeXML) {
			/// ToDo: check this much earlier don't do the work if the response format code is XML
			// XML does not appear in the spec
			$$$ThrowFHIR($$$NotImplemented)
		} Else {
			// Output as JSON
			Do ##class(HS.FHIRServer.Util.JsonHelper).ToJSONStream(json,.pOutStream, indent, lineEnd)
		}
	}
}

ClassMethod GetResponseMimeType(pResponseFormatCode As %String, ByRef toObject)
{
	If (pResponseFormatCode = $$$FHIRContentCodeXML) {
		// Output as XML
		Set toObject.ContentType = "application/fhir+xml"
		Set toObject.CharSet = "UTF-8"
	} Else {
		// Output as JSON
		Set toObject.ContentType = "application/fhir+json"
		Set toObject.CharSet = "UTF-8"
	}
}

/// Log details of HTTP request received by CSP
ClassMethod LogCSPRequest(methodName As %String, server As %Boolean) [ Internal ]
{
	#define SysLogLevel                            $get(^%ISCLOG,1)
	#define SysLog(%level,%cat,%message,%data)     Do:$get(^%ISCLOG,1)'<%level Log^%SYS.ISCLOG($ZNAME,%level,%cat,%message,%data)
	
	If $$$SysLogLevel<3 Quit
	
	Set data="Content-Type: "_%request.ContentType
	If $isobject(%request.Content) {
		Set contentLength = %request.Content.Size
	} Else {
		Set contentLength = $Length(%request.Content)
	}
	Set data=data_", ContentLength: "_contentLength
	Set data=data_", Secure: "_%request.Secure
	Set data=data_", $Username: "_$Username
	Set name=""
	For {
		Set name=$order(%request.Data(name))
		If name="" Quit
		Set index=""
		For {
			Set index=$order(%request.Data(name,index),1,value)
			If index="" Quit
			Set data(name,index)=value
		}
	}
	If $$$SysLogLevel>=5 {
		Set name=""
		For {
			Set name=%request.NextCookie(name)
			If name="" Quit
			Set data("Cookie",name)=%request.GetCookie(name)
		}
		Set name="HTTP_"
		For {
			Set name=$order(%request.CgiEnvs(name),1,value)
			If $extract(name,1,5)'="HTTP_" Quit
			If ($zcvt(name,"U") = "HTTP_AUTHORIZATION") Continue
			Set data("Header",name)=value
		}
	}
	$$$SysLog(3,"HSFHIR"_$select(server:"Server",1:""),methodName_"CSP Request",.data)
}

/// Log details of HTTP response about to be returned via CSP
ClassMethod LogCSPResponse(methodName As %String, server As %Boolean) [ Internal ]
{
	#define SysLogLevel                            $get(^%ISCLOG,1)
	#define SysLog(%level,%cat,%message,%data)     Do:$get(^%ISCLOG,1)'<%level Log^%SYS.ISCLOG($ZNAME,%level,%cat,%message,%data)
	
	If $$$SysLogLevel<3 Quit
	Set data="Content-Type: "_%response.ContentType
	Set data=data_", HTTPVersion: "_%response.HTTPVersion
	Set data=data_", Status: "_%response.Status
	Set data=data_", Redirect: "_%response.Redirect
	Set data=data_", ServerSideRedirect: "_%response.ServerSideRedirect
	Set data=data_", ContentLength: "_%response.ContentLength
	If $$$SysLogLevel>=5 {
		Set name=""
		For {
			Set name=$Order(%response.Headers(name))
			If name="" Quit
			Set data("Header",name)=%response.Headers(name)
		}
		Set name=""
		For {
			Set name=$Order(%response.Cookies(name))
			If name="" Quit
			Set sub=""
			For {
				Set sub=$Order(%response.Cookies(name,sub))
				If sub="" Quit
				Set data("Cookie",name,sub)=%response.Cookies(name,sub)
			}
		}
	}
	$$$SysLog(3,"HSFHIR"_$select(server:"Server",1:""),methodName_"CSP Response",.data)
}

}
