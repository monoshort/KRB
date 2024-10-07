Include HS.BulkFHIR

Class HS.BulkFHIR.Fetch.Util.RestClient Extends HS.FHIRServer.RestClient.HTTP
{

/// Maximum number of retries for obtaining an OAuth token during $export when obtain fails.
Parameter TokenRetryLimit As Integer = 2;

Property %rateLimiter As HS.BulkFHIR.Fetch.Util.RateLimiter [ Private ];

Property %bfcSessionId As %String [ Private ];

Property %headers As %String [ MultiDimensional, Private ];

Property BaseURL As %String [ Calculated ];

/// @API<br>
/// Sends an HTTP GET request to the endpoint configured for this REST client.<br>
/// @Input path		path to send an HTTP request to, eg. "Patient" or "metadata"
Method Get(path As %String) As HS.FHIRServer.API.Data.RestClient.Response
{
	set path = $zstrip(path,"<","/")
	set rateLimitWaitTime = ..%rateLimiter.WaitUntilAllowed()
	set startRequestTime = $zh

	Set sc = $$$OK
	Set severity = $$$LogLevelInfo

	try {
		// execute request and catch errors so that the logging can be done
		Set restResponse = ..ExecuteRequest(path)
	} catch ex {
		Set sc = ex.AsStatus()
		Set severity = $$$LogLevelError
	}
	Set statusCode = $S($IsObject($g(restResponse)):restResponse.Status,1:500)

	set endRequestTime = $zh

	set logDynObj = {
		"severity": (severity),
		"sessionId": (..%bfcSessionId),
		"component": "fetch",
		"type": "rest_request",
		"path": (path),
		"rate_limit_time": (rateLimitWaitTime),
		"http_response_time": (endRequestTime - startRequestTime),
		"http_status": (statusCode)
	}
	
	// If the request timed out and a specific page size was requested, requesting a smaller page size usually helps
	If (($System.Status.Equals(sc,$$$CSPTimeout) || $$$IsHTTPStatus($G(statusCode),504)) && (path["_count") ) {
		Set start = $find(path,"_count")+1
		Set end = $find(path,"&",start)
		Set pageSize = $extract(path,start,$select(end=0:$length(path),1:end-2))
		If pageSize > 1 {
			// Log a warning that this initial attempt failed before attempting again with a smaller page size
			set logDynObj.severity = $$$LogLevelWarning
			set logDynObj.reason = "Fetch request timed out on GET /"_path
			do ##class(HS.BulkFHIR.Log).Log(logDynObj)
			// Try with smaller page size by replacing _count value with half of original
			Set $extract(path,start,$select(end=0:$length(path),1:end-2))=(pageSize\2)
			Return ..Get(path)
		}
	}
	If $$$ISERR(sc) {
		Set severity = $$$LogLevelError
		set logDynObj.reason = $system.Status.GetErrorText(ex.AsStatus())
		set logDynObj.stack = $ListToString(ex.iStack)
	} ElseIf '$$$IsHTTPStatus(statusCode,200) {
		If ($IsObject(restResponse)) && ($IsObject(restResponse.Payload)) {	
			// In general we do not want to log the response content body.
			// However, when the GET fails, the content body might be a
			// FHIR OperationOutcome with diagnostic information.
			Set contentBody = restResponse.Payload.Read()
			do restResponse.Payload.Rewind()
			set logDynObj."content_length"=restResponse.Payload.Size
			set logDynObj."content_body" = contentBody
			if contentBody '= "" {
				try {
					set errorText = ""
					set dynObj = {}.%FromJSON(contentBody)
					if dynObj.resourceType = "OperationOutcome" {
						If '$$$IsHTTPStatus(statusCode,404) {
							// Make sure to add this OperationOutcome now since it won't be returned.  We generate our own OperationOutcome from the error text of 404 outcomes
							do ##class(HS.BulkFHIR.ExportManager).AddError(##class(HS.BulkFHIR.Session).getBySessionId(..%bfcSessionId), dynObj, path)
						}
						if dynObj.issue '= "" {
							if dynObj.issue.%Get(0).details '= "" {
								set errorText = dynObj.issue.%Get(0).details.text
							} elseif dynObj.issue.%Get(0).diagnostics '= "" {
								set errorText = dynObj.issue.%Get(0).diagnostics
							}
						}
					}
				} catch ex {
					// No action needed. the string was not valid
					// JSON, cannot get diagnostics from it.
				}
			}
		} Else {
			Set errorText = "No response"
		}
		Set severity = $S($$$IsHTTPStatus(statusCode,404):$$$LogLevelWarning,1:$$$LogLevelError)
		Set sc = $$$ERROR($$$HSBFCErrFetchRequestFailed, statusCode, "GET /"_path, errorText)
		Set logDynObj.reason = $Select(errorText'="":errorText,1:"Fetch request failed on GET /"_path)

	}
	If $$$ISERR(sc) {
		Set code = $system.Status.GetErrorCodes(sc)
		If $$$IsInterrupt(code,sc) {
			/// Don't log it, this is just a worker job stopping so just throw it
			$$$ThrowOnError(sc)	
		}
	}
	Set logDynObj.severity = severity
	do ##class(HS.BulkFHIR.Log).Log(logDynObj)

	$$$ThrowOnError(sc)
		
	return restResponse
}

Method ExecuteRequest(pPath As %String) As HS.FHIRServer.API.Data.RestClient.Response
{
	// ..Search Throws upon an execution fail. Use Catch to trap a
	// possible $$$OAuth2NoAccessToken error, which means that the
	// current access token for this RestClient is expired.
	#dim restResponse As HS.FHIRServer.API.Data.RestClient.Response
	try {
		set searchSc = $$$OK
		set restResponse = ""
		set restResponse = ..Search("GET", pPath)
	} catch searchEx {
		set searchSc = searchEx.AsStatus()
	}
	if (..%OAuthClientName '= "") && (..%SessionId '= "") && (..%bfcSessionId '= "") {
		// This block applies only when an access token is in use as part of a $export session.
		if (($IsObject(restResponse)) && ($$$IsHTTPStatus(restResponse.Status,401)) ) || ($System.Status.Equals(searchSc, $$$OAuth2NoAccessToken)) {
			// Status 401 means the resource server rejected the token-based authentication.
			// $$$OAuth2NoAccessToken means the construction of the %Net.HttpRequest failed
			// because the access token was invalid.
			#dim session As HS.BulkFHIR.Session = ##class(HS.BulkFHIR.Session).getBySessionId(..%bfcSessionId)
			set fetchConfig = session.configuration."fetch_config"
			set tokenSessionId = ..%SessionId
			// Either refresh the current token or get a new one. If a
			// new token is obtained, then tokenSessionId is updated.
			set sc = ..EnsureFetchToken(..%OAuthClientName, .tokenSessionId, session.fetchTokenInfo, fetchConfig."grant_type", fetchConfig."endpoint_url", fetchConfig."http_credential_id")
			$$$ThrowOnError(sc)
			if ..%SessionId '= tokenSessionId {
				set ..%SessionId = tokenSessionId
			}
			// Re-try twice to work around other race conditions.
			For searchRetryIdx = 0:1:2 {
				try {
					set search2Sc = $$$OK
					kill restResponse
					set restResponse = ..Search("GET", pPath)
					if $$$IsHTTPStatus(restResponse.Status,200) { 
						Quit
					}
				} catch search2Ex {
					set search2Sc = search2Ex.AsStatus()
				}
			}
			$$$ThrowOnError(search2Sc)
			
		} else {
			$$$ThrowOnError(searchSc)
		}
		
	} else {
		$$$ThrowOnError(searchSc)
	}
	return restResponse
}

/// Override HS.FHIRServer.RestClient.HTTP to use the full path provided if pRequestPath is a full URL instead of using the service base URL
/// 
/// InvokeRequest takes the Private %HttpRequest object - passed in as pRequest here -
/// and invokes the request. The HTTP response is stored as the HttpResponse property
/// of the HTTP request object. This method returns a reference to that property.<br>
/// @Input pRequest %Net.HttpRequest object.<br>
/// @Input pRequestMethod HTTP verb.<br>
/// @Input pRequestPath Request path, as derived by the invoked interaction-specific method.<br>
/// @Input pQueryString Query string, as derived by the invoked interaction-specific method.
Method InvokeRequest(pRequest As %RegisteredObject, pRequestMethod As %String, pRequestPath As %String, pQueryString As %String) As %RegisteredObject
{
	If ($zconvert(pRequestMethod,"U")="GET") && $Case($zconvert($piece(pRequestPath,"://"),"l"),"/http":1,"/https":1,:0) {
		Set tRequestPath = $zstrip(pRequestPath,"<","/")_$Select(pQueryString="":"",1:"?"_$zstrip(pQueryString,"<","?"))
		Set tSC = $Method(..%HttpRequest,"Send","GET",tRequestPath)
		$$$ThrowOnError(tSC)
		Return ..%HttpRequest.HttpResponse
	}
	
	Return ##super(pRequest,pRequestMethod,pRequestPath,pQueryString)
}

/// @API<br>
/// Returns a configured instance of this class, which can be used as a rest client for
/// fetching content out of the configured FHIR endpoint.<br>
/// @Input pServiceEntryName 	Entry in the Service Registry that points to a FHIR endpoint<br>
/// @Input pMaxRequestsPerSecond	Imposes rate limiting on requests using this client object<br>
/// @Input pTokenObj			Object that holds information about the new token to request.<br>
/// @Input pSessionId			BFC sessionId.<br>
/// @Input pHeaders				Custom HTTP headers to add to requests.<br>
ClassMethod getInstance(pServiceEntryName As %String, pMaxRequestsPerSecond As %Integer, pTokenObj As HS.BulkFHIR.Fetch.Util.AccessToken = "", pSessionId As %String = "", ByRef pHeaders) As HS.BulkFHIR.Fetch.Util.RestClient
{
	if $IsObject(pTokenObj) {
		set serviceEntryObj = ##class(HS.Registry.Service.HTTP).EndPointForNameType(pServiceEntryName, "HTTP")
		if '$IsObject(serviceEntryObj) {
			$$$ThrowStatus($$$ERROR($$$HSFHIRErrInvalidHTTPServiceSpecified, pServiceEntryName))
		}
		set endpointURL = serviceEntryObj.EndPoint
		set httpCredentialsConfig = pTokenObj.FetchTokenInfo."credential_id"
		set oauthClientName = pTokenObj.OAuthClientName
		if pTokenObj.TokenSessionId '= "" {
			set tokenSessionId = pTokenObj.TokenSessionId
		} else {
			set tokenSessionId = ..GetNewFetchTokenSessionId()
		}
		
		do ..GetTokenForFetch(oauthClientName, tokenSessionId, pTokenObj.FetchTokenInfo, pTokenObj.GrantType, endpointURL, httpCredentialsConfig)
		
	} else {
		set oauthClientName = ""
		set tokenSessionId = ""
	}
	
	#dim restClient As HS.BulkFHIR.Fetch.Util.RestClient
	set restClient = ..CreateInstance(pServiceEntryName,, tokenSessionId, oauthClientName)
	do restClient.SetResponseFormat("JSON")
	
	set restClient.%rateLimiter = ##class(HS.BulkFHIR.Fetch.Util.RateLimiter).%New(pServiceEntryName, pMaxRequestsPerSecond)
	set restClient.%bfcSessionId = pSessionId
	
	merge restClient.%headers = pHeaders
	
	return restClient
}

/// Internal override to allow for custom headers to be added to outbound requests.
/// This is done because the FHIRServer RestClient class doesn't support custom headers
/// in IRIS 2021.1, which is the minimum target version for BFC.
Method MakeRequest(pRequestMethod As %String, pPayload, pRequestPath As %String, pQueryString As %String, ByRef pHeaders) As %RegisteredObject [ Internal ]
{
	merge pHeaders = ..%headers
	return ##super(pRequestMethod, pPayload, pRequestPath, pQueryString, .pHeaders)
}

Method BaseURLGet() As %String [ CodeMode = expression ]
{
..%HttpService.EndPoint
}

/// @API<br>
/// Return a new unique SessionId to use for OAuth token request, retrieve and revoke.
ClassMethod GetNewFetchTokenSessionId() As %String
{
	Return "BFC_Fetch_" _ $Job _ "_" _ $I(^IRIS.Temp.BFCFetchTokenIdx($Job))
}

/// @API<br>
/// Use an IRIS OAuth API call to verify that a token exists and is active for
/// the specified OAuth client name and SessionId. If not found or not active,
/// then obtain a new token.<br>
/// <br>
/// @Input pOAuthClientName OAuth client name.<br>
/// @Input pTokenSessionId OAuth token 'SessionId" value to use for storing and retrieving
///                        an access token. This is not the same item as the BFC sessionId.<br>
/// @Input pFetchTokenInfo %DynamicObject of information about the access token on the request to the BFC.<br>
/// @Input pGrantType OAuth token grant type to use when requesting the token.<br>
/// @Input pEndpointURL Resource server endpoint URL to use in the aud claim.<br>
/// @Input pHTTPCredentialsConfig Interoperability credentials config ID to use for password grant.
ClassMethod EnsureFetchToken(pOAuthClientName As %String, ByRef pTokenSessionId As %String, pFetchTokenInfo As %DynamicObject, pGrantType As %String, pEndpointURL As %String, pHTTPCredentialsConfig As %String) As %Status
{
	set sc = $$$OK
	
	#dim IsAuthorizedError As %OAuth2.Error
	#dim IsAuthorizedError2 As %OAuth2.Error
	
	Try {
		// Call IsAuthorized to verify and/or refesh the token.
		Set isAuthorizedBool = ##class(%SYS.OAuth2.AccessToken).IsAuthorized(pOAuthClientName, pTokenSessionId, , .accessToken, , , .IsAuthorizedError)
		// If isAuthorizedBool=1, that indicates the token was okay or got refreshed successfully.
		// Otherwise, proceed with trying to get a new token.
		If isAuthorizedBool Quit
		
		If $IsObject($Get(IsAuthorizedError)) {
			Set text = IsAuthorizedError.AsString()
		} Else {
			Set text = "(No error text returned)"
		}
		Set text = "Fetch adapter IsAuthorized on access token failed, proceeding to obtain new token: " _ text
		// Log the IsAuthorized fail.
		Do ##class(HS.BulkFHIR.Util).LogAuthFail("401", text)
		
		// Going to get a new token using a new OAuth SessionId. Revoke
		// whatever token is stored with the current SessionId first.
		Do ..RevokeAccessToken(pOAuthClientName, pTokenSessionId)
		
		// Loop implemented here to work around possible fails of
		// GetTokenForResourceServer and IsAuthorized.
		Set retryLimit = ..#TokenRetryLimit
		For retryIdx = 0:1:retryLimit {
			// Try to get a new token. GetTokenForResourceServer will Throw if it fails,
			// therefore it needs to be caught.
			Set getTokenSc = $$$OK
			Try {
				// Get new token SessionId to use.
				Set pTokenSessionId = ..GetNewFetchTokenSessionId()
				Do ..GetTokenForFetch(pOAuthClientName, pTokenSessionId, pFetchTokenInfo, pGrantType, pEndpointURL, pHTTPCredentialsConfig)
			} Catch gettokenEx {
				Set getTokenSc = gettokenEx.AsStatus()
			}
			If $$$ISERR(getTokenSc) {
				If retryIdx '< retryLimit {
					$$$ThrowStatus(getTokenSc)
				} Else {
					Continue
				}
			}
			
			Set isAuthorizedBool2 = ##class(%SYS.OAuth2.AccessToken).IsAuthorized(pOAuthClientName, pTokenSessionId, , .accessToken, , , .IsAuthorizedError2)
			If isAuthorizedBool2 {
				Quit
				
			} Else {
				// If refresh or obtain new token failed, log the error, and then try to get a new token.
				If $IsObject($Get(IsAuthorizedError2)) {
					Set text = IsAuthorizedError2.AsString()
				} Else {
					Set text = "(No error text returned)"
				}
				Set text = "Fetch adapter failed isAuthorized on newly acquired token, re-trying obtain of new token " _ text
			}
		}
		
	} catch tokenEx {
		set sc = tokenEx.AsStatus()
	}
	
	Return sc
}

/// @API<br>
/// Obtain an access token for interactions with the resource server.
/// If successful, the token is stored in a structure from which it
/// can be retrieved, given the OAuth client name and a session id.<br>
/// <br>
/// @Input pOAuthClientName OAuth client name.<br>
/// @Input pTokenSessionId OAuth token 'SessionId" value to use for storing and retrieving
///                        an access token. This is not the same item as the BFC sessionId.<br>
/// @Input pFetchTokenInfo %DynamicObject of information about the access token on the request to the BFC.<br>
/// @Input pGrantType OAuth token grant type to use when requesting the token.<br>
/// @Input pEndpointURL Resource server endpoint URL to use in the aud claim.<br>
/// @Input pHTTPCredentialsConfig Interoperability credentials config ID to use for password grant.
ClassMethod GetTokenForFetch(pOAuthClientName As %String, pTokenSessionId As %String, pFetchTokenInfo As %DynamicObject, pGrantType As %String, pEndpointURL As %String, pHTTPCredentialsConfig As %String)
{
	set scopes = ..GetScopesForToken(pFetchTokenInfo)
	
	if pGrantType = "client_credentials" {
		do ..GetTokenClient(pOAuthClientName, pTokenSessionId, scopes, pEndpointURL)
		
	} elseif pGrantType = "password" {
		do ..GetTokenPassword(pOAuthClientName, pTokenSessionId, scopes, pEndpointURL, pHTTPCredentialsConfig)
	}
}

/// Derive the OAuth scopes string to use for the access token for resource server interactions.
/// The return value is a space-delimited string of scopes.
ClassMethod GetScopesForToken(pFetchTokenInfo As %DynamicObject) As %String
{
	set resourceServerScopes = ""
	
	set inputScopes = pFetchTokenInfo.scope
	for i = 1:1:$Length(inputScopes, " ") {
		set scope = $Piece(inputScopes, " ", i)
		if scope '= "" {
			// Convert system scopes to user scopes, and leave all others as is.
			if ($Length(scope, "/") = 2) && ($Piece(scope, "/", 1) = "system") {
				set newScope = "user/" _ $Piece(scope, "/", 2)
			} else {
				set newScope = scope
			}
			if resourceServerScopes '= "" {
				set resourceServerScopes = resourceServerScopes _ " "
			}
			set resourceServerScopes = resourceServerScopes _ newScope
		}
	}
	
	return resourceServerScopes
}

/// Client credentials grant.<br>
/// Input:<br>
/// @Input pOAuthClientName OAuth client name.<br>
/// @Input pTokenSessionId OAuth token 'SessionId" value to use for storing and retrieving
///                        an access token. This is not the same item as the BFC sessionId.<br>
/// @Input pScopes Access token scopes to include in the token request.<br>
/// @Input pEndpointURL Resource server endpoint URL to use in the aud claim.
ClassMethod GetTokenClient(pOAuthClientName As %String, pTokenSessionId As %String, pScopes As %String, pEndpointURL As %String) [ Internal ]
{
	Set properties("aud") = [(pEndpointURL), (..GetClientId(pOAuthClientName))]
	
	Set sc = ##class(%SYS.OAuth2.Authorization).GetAccessTokenClient(pOAuthClientName,
																		pScopes,
																		.properties,
																		.error,
																		pTokenSessionId)
																		
	$$$ThrowOnError(sc)
}

/// Return the OAuth client id for a given OAuth client name.
ClassMethod GetClientId(pClientName) As %String
{
	New $Namespace
	Set $Namespace = "%SYS"
	
	Set client = ##class(OAuth2.Client).%OpenId(pClientName)
	If '$IsObject($Get(client)) {
		$$$ThrowStatus($$$ERROR($$$GeneralError, "Invalid OAuth Client Name '" _ pClientName _ "' specified"))
	}
	
	Return client.ClientId
}

/// Resource owner password credentials grant.<br>
/// Input:<br>
/// @Input pOAuthClientName OAuth client name.<br>
/// @Input pTokenSessionId OAuth token 'SessionId" value to use for storing and retrieving
///                        an access token. This is not the same item as the BFC sessionId.<br>
/// @Input pScopes Access token scopes to include in the token request.<br>
/// @Input pEndpointURL Resource server endpoint URL to use in the aud claim.<br>
/// @Input pHTTPCredentialsConfig Interoperability credentials config ID to use for password grant.
ClassMethod GetTokenPassword(pOAuthClientName As %String, pTokenSessionId As %String, pScopes As %String, pEndpointURL As %String, pHTTPCredentialsConfig As %String) [ Internal ]
{
	Set properties("aud") = pEndpointURL
	
	Set credential = ##class(Ens.Config.Credentials).%OpenId(pHTTPCredentialsConfig)
	
	Set sc = ##class(%SYS.OAuth2.Authorization).GetAccessTokenPassword(pOAuthClientName, 
																		credential.Username,
																		credential.Password,
																		pScopes,
																		.properties,
																		.error,
																		pTokenSessionId)
																				
	$$$ThrowOnError(sc)
}

ClassMethod RevokeAccessToken(pOAuthClientName As %String, pTokenSessionId As %String)
{
	If (pOAuthClientName '="") && (pTokenSessionId '= "") {
		Set isAuthorized = ##class(%SYS.OAuth2.AccessToken).IsAuthorized(pOAuthClientName,
																		pTokenSessionId,
																		,
																		.accessToken,
																		.IDToken,
																		.responseProperties,
																		.error)
		
		If $Get(accessToken) '= "" {
			// Ignore error here.
			If $Data(%objlasterror) Set saveobjlasterror = %objlasterror Kill %objlasterror
			Set revokeSc = ##class(%SYS.OAuth2.AccessToken).RevokeToken(pOAuthClientName, accessToken)
			If $Data(saveobjlasterror) Set %objlasterror = saveobjlasterror
		}
	}
}

/// Revoke an access token that might be in use by this RestClient instance.<br>
/// Input:<br>
/// @Input pOAuthClientName OAuth client name.<br>
/// @Input pTokenSessionId OAuth token 'SessionId" value to use for revoking the access
///                        token. This is not the same item as the BFC sessionId.<br>
Method Revoke()
{
	Do ..RevokeAccessToken(..%OAuthClientName, ..%SessionId)
}

/// This is executed when the RestClient object instance goes out of scope.
Method %OnClose() As %Status [ Private, ServerOnly = 1 ]
{
	Set sc = $$$OK
	
	Try {
		Do ..Revoke()
		
	} Catch ex {
		Set sc = ex.AsStatus()
	}
	
	Return sc
}

}
