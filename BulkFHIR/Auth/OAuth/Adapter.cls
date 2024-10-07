/// This OAuth adapter points to and uses an existing OAuth server for the validation
/// of access tokens that come into the BFC endpoint. The OAuth server:<br>
/// - May be an ISC or non-ISC OAuth server.<br>
/// - May be located anywhere that is accessible over HTTP.<br>
/// - Must be able to handle the requirements of SMART Backend Authorization Service profile (http://www.hl7.org/fhir/smart-app-launch/backend-services.html).
Class HS.BulkFHIR.Auth.OAuth.Adapter Extends HS.BulkFHIR.API.AuthAdapter
{

Parameter IsOAuth As Boolean = 1;

Parameter configClass = "HS.BulkFHIR.Auth.OAuth.Config";

ClassMethod Initialize(pBFCconfig As HS.BulkFHIR.API.Data.Config)
{
	do ..AddOAuthDefinitions(pBFCconfig)
}

ClassMethod Authenticate(pBFCconfig As HS.BulkFHIR.API.Data.Config, pUrl As %String, ByRef pContinue As %Boolean) As %Status
{
	Set sc = $$$OK
	
	// Check the basics - is there a token, is token in header, is token on secure connection.
	Do ..PrelimTokenCheck(%request, .accessToken, .httpStatus, .exception, .failReason, .failText)
	
	// If httpStatus = "", that means no problem so far.
	If httpStatus = "" {
		
		// Only metadata and .well-known requests are allowed to have no access token here.
		If accessToken = "" {
			If ($Piece(%request.URL, "/", *) = "metadata") || ($Piece(%request.URL, "/", *-1) = ".well-known") {
				Return sc
				
			} Else {
				Set httpStatus = ..#HTTP401UNAUTHORIZED
				Set failText = "Access token missing from request"
			}
			
		} Else {
			// If there is a token, then validate it now.
			
			Set BFCClientName = pBFCconfig."auth_config"."bfc_client_name"
			
			Do ..ValidateOAuthToken(pBFCconfig, %request, BFCClientName, .accessToken, .httpStatus, .exception, .failReason, .failText)
		}
	}
	
	// httpStatus with a value means there was a fail during token checking.
	If httpStatus '= "" {
		
		Set pContinue = 0
		
		Do ##class(HS.BulkFHIR.Util).LogAuthFail(httpStatus, failText, %request)
		
		If +httpStatus = 401 {
			// If an access token was provided with the request, and the request was
			// rejected with 401 Unauthorized, then fill in the WWW-Authenticate
			// response header. Rejection because of not using https does not count
			// as bad access token. Rejection because of placing the token in the
			// URL or in the form encoded body does not count as bad access token.
			If '((failReason = "url") || (failReason = "unsecure") || (failReason = "internal_error")) {
				Do %response.SetHeader("WWW-Authenticate", "Bearer")
			}
			Set %response.Status = httpStatus
			
		} ElseIf $IsObject(exception) {
			Set %response.Status = httpStatus
			Do ..ReportHttpStatusCode(httpStatus, exception.AsStatus())
			
		} Else {
			Do ..ReportHttpStatusCode(httpStatus)
		}
		
	}
	
	// No need to alter sc for this method.
	return sc
}

/// If a token is present and passes these checks, return the token string as an Output parameter:<br>
/// - The token is located in the Authorization header.<br>
/// - The token is not blank (i.e., the Authorization header is not simply "Bearer" or "Bearer ").<br>
/// - The current request is secure (i.e., is over https).<br>
ClassMethod PrelimTokenCheck(pRequest As %CSP.Request, Output pAccessToken As %String = "", Output pHTTPStatus As %String = "", Output pException As %Exception.AbstractException = {$$$NULLOREF}, Output pFailReason As %String = "", Output pFailText As %String = "") [ Internal ]
{
	Try {
		// Intentionally does not use ##class(%SYS.OAuth2.AccessToken).GetAccessTokenFromRequest().
		
		// If an access token is present, ISC FHIR policy is that the token
		// SHALL be located in the HTTP AUTHORIZATION header.
		
		// Look for form encoded body or query parameter for access token.
		// If there, it is not valid for ISC FHIR.
		If $Get(pRequest.Data("access_token", 1)) '= "" {
			Set pHTTPStatus = ..#HTTP401UNAUTHORIZED
			Set pFailReason = "url"
			Quit
		}
		
		Set pAccessToken = pRequest.GetCgiEnv("HTTP_AUTHORIZATION")
		
		If $Piece($ZConvert(pAccessToken, "U"), " ", 1) '= "BEARER" {
			// No access token present, nothing to validate.
			Set pAccessToken = ""
			Quit
		}
		
		If 'pRequest.Secure {
			Set pAccessToken = ""
			Set pHTTPStatus = ..#HTTP401UNAUTHORIZED
			Set pFailReason = "unsecure"
			Quit
		}
		
		Set pAccessToken = $Piece(pAccessToken, " ", 2)
		
		If pAccessToken = "" {
			Set pHTTPStatus = ..#HTTP401UNAUTHORIZED
			Set pFailReason = "blank"
			Set pFailText = "Token failed: Blank bearer token in authorization header"
			Quit
		}
		
	} Catch eException {
		Set pAccessToken = ""
		Set pHTTPStatus = ..#HTTP500INTERNALSERVERERROR
		Set pFailReason = "internal_error"
		Set pException = eException
	}
	
	Quit
}

/// Validate the access token per the token handler defined for the current endpoint.<br>
/// Input:<br>
/// - pRequest         : %CSP.Request object.<br>
/// - pOAuthClientName : OAuth 2.0 client to use for validating the token and invoking introspection.
/// - pAccessToken     : Access token string.<br>
/// Output:<br>
/// - pHTTPStatus  : If the token fails validation, this is the HTTP status code
///                  recommended for the particular fail. Otherwise, this is
///                  returned as blank.<br>
/// - pException   : If validation of the token incurs an exception, this is the
///                  exception object.<br>
/// - pFailReason  : Reason text to aid in discriminating between various reasons
///                  for 401 and 500 status codes.
ClassMethod ValidateOAuthToken(pBFCconfig As HS.BulkFHIR.API.Data.Config, pRequest As %CSP.Request, pOAuthClientName As %String, pAccessToken As %String, Output pHTTPStatus As %String = "", Output pException As %Exception.AbstractException = {$$$NULLOREF}, Output pFailReason As %String = "", Output pFailText As %String = "") [ Internal ]
{
	Try {
		Set return = ##class(%SYS.OAuth2.Validation).ValidateJWT(pOAuthClientName, pAccessToken, "", "", .jwt, .securityParams, .sc)
		If $$$ISERR(sc) || 'return {
			Set pHTTPStatus = ..#HTTP401UNAUTHORIZED
			Set pFailReason = "invalid"
			Set pFailText = "ValidateJWT returned: " _ return _ " with status: " _ $system.Status.GetErrorText(sc)
			Quit
		}
		
		If ('($Data(securityParams("sigalg"))#2)) && ('($Data(securityParams("encalg"))#2)) {
			Set pHTTPStatus = ..#HTTP401UNAUTHORIZED
			Set pFailReason = "invalid"
			Set pFailText = "access token is neither signed nor encrypted"
			Quit
		}
		
		Set sc = ##class(%SYS.OAuth2.AccessToken).GetIntrospection(pOAuthClientName, pAccessToken, .intro)
		If $$$ISERR(sc) {
			Set pHTTPStatus = ..#HTTP401UNAUTHORIZED
			Set pFailReason = "invalid"
			Set pFailText = "Introspection on access token returned: " _ $system.Status.GetErrorText(sc)
			Quit
		}
		
		If '$isobject(intro) || 'intro.active {
			Set pHTTPStatus = ..#HTTP401UNAUTHORIZED
			Set pFailReason = "invalid"
			Set pFailText = "Introspection response not present, or token is inactive"
			Quit
		}
		
		// Get both the REST client-specified full base url and the 'local'
		// full base url for compare against aud values.
		Set requestBaseUrl = ##class(HS.Local.BulkFHIR.Util.BaseURL).GetBaseURL(pRequest, .localBaseUrl)
		Set requestBaseUrlFormatted = ..FormatURLForAudCompare(requestBaseUrl)
		Set localBaseUrlFormatted = ..FormatURLForAudCompare(localBaseUrl)
		
		#dim authConfig As HS.BulkFHIR.Auth.OAuth.Config = $$$BFCAuthConfig(pBFCconfig)
		
		Set adapterClientsDefined = (($IsObject(authConfig.clients)) && (authConfig.clients.Count()))
		
		// Initialize localUser from jwt.sub, which could be blank.
		Set localUser = jwt.sub
		
		// If sub is indeed missing, then we will try to obtain a username
		// from aud, by cross-referencing aud values against client ids
		// defined in IRIS OAuth Client definitions.
		
		// aud must be a non-blank string or a non-empty array.
		If (jwt.aud '= "") && '(($IsObject(jwt.aud)) && ('jwt.aud.%Size())) {
			
			Set audHasURL = 0
			Set audHasValidURL = 0
			
			// If aud is a string, then convert it to %DynamicArray
			// so we can use the same loop on it.
			If '$IsObject(jwt.aud) {
				Set audArray = [(jwt.aud)]
				
			} Else {
				Set audArray = jwt.aud
			}
			
			Set audIter = audArray.%GetIterator()
			While audIter.%GetNext(.audIdx, .aud) {
				If localUser = "" {
					Set clientName = ##class(%ZHS.BulkFHIR.Utils).ClientIdToClientName(aud)
					// If this aud matches a client Id defined in OAuth Client,
					// set it into localUser. It will be verified after looping
					// through the remaining aud values.
					If clientName '= "" {
						Set localUser = aud
					}
				}
				Set isURL = (($Extract(aud, 1, 7) = "http://") || ($Extract(aud, 1, 8) = "https://"))
				If isURL {
					Set audHasURL = 1
				}
				If ('audHasValidURL) && (isURL) {
					// If we have not yet encountered a valid url, and this
					// value is a url, then check to see if it is match.
					// Otherwise, if we have already found a valid url, no need
					// to continue checking against current request url.
					Set audUrlFormatted = ..FormatURLForAudCompare(aud)
					If (audUrlFormatted = requestBaseUrlFormatted) || (audUrlFormatted = localBaseUrlFormatted) {
						Set audHasValidURL = 1
					}
				}
			}
			
			If (audHasURL) && ('audHasValidURL) {
				Set pHTTPStatus = ..#HTTP401UNAUTHORIZED
				Set pFailReason = "invalid"
				Set pFailText = "none of access token aud URL values is valid for the endpoint"
				Quit
			}
		}
		
		If localUser '= "" {
			Set clientName = ##class(%ZHS.BulkFHIR.Utils).ClientIdToClientName(localUser)
			// If localUser matches a client id defined in OAuth Client, verify
			// that the client name matches one allowed by the BFC auth config.
			If clientName '= "" {
				Set localUser = ""
				For clientIdx = 1:1:authConfig.clients.Count() {
					Set clientObj = authConfig.clients.GetAt(clientIdx)
					If clientObj.name = clientName {
						Set localUser = clientName
						Quit
					}
				}
			}
		}
		
		If localUser = "" {
			Set pHTTPStatus = ..#HTTP401UNAUTHORIZED
			Set pFailReason = "invalid"
			Set pFailText = "clientId value not found in access token sub or aud, or clientId is not mapped to an approved OAuth client name for the BFC"
			Quit
		}
			
		Set %bfcRESTSecurity.Username = localUser
		
	} Catch eException {
		Set pHTTPStatus = ..#HTTP500INTERNALSERVERERROR
		Set pFailReason = "internal_error"
		Set pException = eException
	}
	
	Quit
}

/// Format the specified aud URL string to facilitate more reasonable URL
/// aud validation. Strip trailing slash, and facilitate case-insensitive
/// compare of host and port by converting those to lowercase.
ClassMethod FormatURLForAudCompare(pAudIn As %String) As %String [ Internal ]
{
	Set audOut = pAudIn
	
	// Strip trailing slash.
	If $Extract(audOut, *)="/" {
		Set audOut = $Extract(audOut, 1, *-1)
	}
	Set audOutL = $ZConvert(audOut, "L")
	If ($Extract(audOutL, 1, 7) = "http://") || ($Extract(audOutL, 1, 8) = "https://") {
		// If aud is an HTTP URL, then make the comparison case-INsensitive
		// against the scheme and server, and case-SENSITIVE against the
		// rest of the URL.
		Set audOut = $Piece(audOutL, "/", 1, 3) _ $Select($Length(audOut, "/")>3:"/"_$Piece(audOut, "/", 4, *), 1:"")
	}
	
	Return audOut
}

/// Use the access token information to authorize the current interaction.
/// metadata request does NOT come through this method. Such authorization
/// is not needed for metadata.
ClassMethod AuthorizeFHIRRequest(request As HS.FHIRServer.API.Data.Request, pBFCconfig As HS.BulkFHIR.API.Data.Config)
{
	set accessToken = request.AdditionalInfo.GetAt("USER:OAuthToken")
	if accessToken = "" {
		do ##class(HS.BulkFHIR.Util).LogAuthFail("401", "Access token missing from request", %request)
		$$$ThrowFHIR($$$HttpOnlyResponse(401))
	}
	//The token was already introspected in Authenticate, but we need the list of scopes 
	//in the introspection response to authorize the request
	
	Set BFCClientName = pBFCconfig."auth_config"."bfc_client_name"
	
	set sc = ##class(%SYS.OAuth2.AccessToken).GetIntrospection(BFCClientName, accessToken, .intro)
	$$$ThrowOnError(sc)
	
	Set request.Username = %bfcRESTSecurity.Username
	
	for i=1:1:$length(intro.scope, " ") {
		//We've already verified in the config validation that we'll only have system read level scopes.
		//Skip over any non-FHIR scopes
		set scope = $piece(intro.scope, " ", i)
		if scope?1"system"1"/"1.E1".read" { 
			set type = $piece($piece(scope, "system/", *), ".read", 1)
			set allowedTypes(type) = ""
		}
	}
	
	if request.OperationName = "$export" {
		set usesType = 0
		for paramIndex = request.Parameters.Count():-1:1 {
			set searchQueryParameter = request.Parameters.GetAt(paramIndex)
			set paramName = searchQueryParameter.name
			set paramVal = searchQueryParameter.value
			if paramName = "_type" {
				set usesType = 1
				
				for i=1:1:$length(paramVal, ",") {
					set oneVal = $piece(paramVal, ",", i)
					
					if '$$AllowedByScope(oneVal) {
						do ##class(HS.BulkFHIR.Util).LogAuthFail("403", "Request does not have the necessary scope to access resource of type " _ oneVal, %request)
						$$$ThrowFHIR($$$HttpOnlyResponse(403))
					}
					set requestedTypes(oneVal) = ""
				}
			}
		}
		
		//Require wildcard read access if no explicit _types were
		//specified. Otherwise we have to do the full export operation
		//to know whether the operation is permitted, and that's too
		//expensive.
		if 'usesType && '$$AllowedByScope("*") {
			do ##class(HS.BulkFHIR.Util).LogAuthFail("403", "Request must have 'system/*.read' scope to perform unqualified (ie. not using '_type') export", %request)
			$$$ThrowFHIR($$$HttpOnlyResponse(403))
		}
	}
	else { //Is a search or read request
		set resourceType = request.Type
		if '$$AllowedByScope(resourceType) {
			do ##class(HS.BulkFHIR.Util).LogAuthFail("403", "Request does not have the necessary scope to access resource of type " _ resourceType, %request)
			$$$ThrowFHIR($$$HttpOnlyResponse(403))
		}
		
		for paramIndex = request.Parameters.Count():-1:1 {
			set searchQueryParameter = request.Parameters.GetAt(paramIndex)
			set paramName = searchQueryParameter.name
			//The spec allows for searching and reading on Group resources.
			//Any chaining/include searches don't really make sense if
			//we only expose Group, therefore it's blocked for now.
			//If that spec/requirement changes, these cases will need
			//to be implemented.
			if (paramName = "_include") || (paramName = "_revinclude") ||
				(searchQueryParameter.nextInChain '= "") ||
				(searchQueryParameter.nextInRevChain '= "")
			{
				do ##class(HS.BulkFHIR.Util).LogAuthFail("403", "Searches using _include, _revinclude, chaining, or reverse chaining are not allowed", %request)
				$$$ThrowFHIR($$$HttpOnlyResponse(403))
			}
		}
	}
AllowedByScope(resType)
	return ($data(allowedTypes("*")) || $data(allowedTypes(resType)))
}

/// Override of API method.<br>
/// @Returns a %DynamicObject representing the .well-known/smart-configuration for the BFC OAuth server.
ClassMethod WellKnownConfiguration(pBFCconfig As HS.BulkFHIR.API.Data.Config) As %DynamicObject
{
	set authMeta = ##class(%ZHS.HC.OAuth2.Utils).GetServerMetadataByClient(pBFCconfig."auth_config"."bfc_client_name")
	
	set scopes = []
	set scopeIter = authMeta."scopes_supported".%GetIterator()
	while scopeIter.%GetNext(,.scope) {
		//Exclude the default IRIS scopes from what we return to the client
		if $listfind($lb("openid", "profile", "email", "address", "phone"), scope) continue
		do scopes.%Push(scope)
	}
	
	return {
		"authorization_endpoint": (authMeta."authorization_endpoint"),
		"token_endpoint": (authMeta."token_endpoint"),
		"token_endpoint_auth_methods": (authMeta."token_endpoint_auth_methods_supported"), //SOF uses different naming convention here
		"scopes_supported": (scopes),
		"introspection_endpoint": (authMeta."introspection_endpoint"),
		"revocation_endpoint": (authMeta."revocation_endpoint"),
		"capabilities": [ "client-confidential-symmetric", "launch-standalone", "permission-offline" ]
	}
}

/// Override of API method.<br>
/// Return a %DynamicObject of selected access token fields.<br>
/// @Returns a %DynamicObject representing information about the access token.
ClassMethod GetAccessTokenInfo(pBFCconfig As HS.BulkFHIR.API.Data.Config, pTokenString As %String) As %DynamicObject
{
	set tokenInfo = {}
	
	set tokenJson = ..GetAccessTokenJson(pBFCconfig, pTokenString)
	
	if tokenJson.scope '= "" {
		set tokenInfo.scope = tokenJson.scope
	}
	
	return tokenInfo
}

/// @API.Overridable<br>
/// Return a %DynamicObject representing the full access token information.<br>
/// @Input pBFCconfig Full BFC configuration object in effect for the current BFC session.<br>
/// @Input pTokenString Encoded string representation of an access token provided on the current request to the BFC.<br>
/// @Returns a %DynamicObject representing the full access token information.
ClassMethod GetAccessTokenJson(pBFCconfig As HS.BulkFHIR.API.Data.Config, pTokenString As %String) As %DynamicObject
{
	Set BFCClientName = pBFCconfig."auth_config"."bfc_client_name"
	
	Set serverMeta = ##class(%ZHS.HC.OAuth2.Utils).GetServerMetadataByClient(BFCClientName)
	
	If serverMeta."introspection_endpoint" '= "" {
		$$$ThrowOnError(..GetIntrospection(BFCClientName, pTokenString, .tokenJson))
		
	} Else {
		// This is a fall-back in case no introspection endpoint available.
		// This will not work for opaque token, which does not seem to be
		// applicable if following SMART Backend Services authorization.
		Set bool = ##class(%SYS.OAuth2.Validation).ValidateJWT(BFCClientName, pTokenString, "", "", .tokenJson, .securityParams, .sc)
		If $$$ISERR(sc) || 'bool {
			// Not sure how this could happen at this point, but provide for it anyway.
			Set text = "GetAccessTokenJson ValidateJWT returned: " _ bool _ " with status: " _ $system.Status.GetErrorText(sc)
			Do ##class(HS.BulkFHIR.Util).LogAuthFail("401", text)
			$$$ThrowFHIR($$$HttpOnlyResponse(401))
		}
	}
	
	If tokenJson = "" {
		Set tokenJson = {}
	}
	
	Return tokenJson
}

/// @API.Overridable<br>
/// This method presents the token string to the introspection endpoint for the server that
/// granted this token.<br>
/// <br>
/// The server returns a JSON object with information about the token. RFC 7662 "OAuth 2.0
/// Token Introspection" Section 2.2 (https://datatracker.ietf.org/doc/html/rfc7662#section-2.2)
/// describes the expected contents of the returned JSON object. RFC 7662 lists "scope" as
/// OPTIONAL. However, for FHIRServer processing, it is REQUIRED.<br>
/// <br>
/// This method checks the JSON object to verify that the token is active (well-formed and not
/// expired), and returns it as ByRef variable pJWTObj.<br>
/// <br>
/// By the time this method returns, pJWTObj MUST hold the token scopes in the 'scope' property,
/// as a space-delimited string. If the tokens being handled by this class are expected to hold
/// scopes in an alternate property and/or in an alternate format, you may need to override this
/// method to ensure that the scopes are moved and/or reformatted into the 'scope' property. The
/// default implementation of this method handles only one common alternate scenario, where the
/// token object scopes are found in property 'scp', either as a JSON array or a space-delimited
/// string. Other alternate scenarios must be handled via override of this method.<br>
/// <br>
/// If the server that granted the token does not host an introspection endpoint, then you must
/// override this method to derive/obtain a JSON object that holds information about the access
/// token, with the required properties described above.<br>
/// <br>
/// @Input pOAuthClient OAuth 2.0 client name as defined in ISC OAuth 2.0 Client definitions.<br>
/// @Input pTokenString OAuth 2.0 access token string.<br>
/// @Output pJWTObj JSON object that holds information about the token.<br>
/// @Return %Status return value.
ClassMethod GetIntrospection(pOAuthClient As %String, pTokenString As %String, Output pJWTObj) As %Status
{
	Set pJWTObj = ""
	
	Set status = ##class(%SYS.OAuth2.AccessToken).GetIntrospection(pOAuthClient, pTokenString, .pJWTObj)
	
	If $$$ISOK(status) {
		If '$IsObject($Get(pJWTObj)) {
			Set status = $$$ERROR($$$HSFHIRErrTokenIntrospectionNoToken)
			
		} ElseIf 'pJWTObj.active {
			Set status = $$$ERROR($$$HSFHIRErrTokenIntrospectionInactive)
			
		} Else {
			// Compensate for use of 'scp' instead of 'scope' for scopes.
			// Some auth server implementations specify 'scp' to be a
			// space-delimited list, and other implementations specify it
			// to be a JSON array of strings.
			If (pJWTObj.scope = "") && (pJWTObj.scp '= "") {
				
				If '$IsObject(pJWTObj.scp) {
					Set pJWTObj.scope = pJWTObj.scp
					
				} ElseIf pJWTObj.scp.%IsA("%Library.DynamicArray") {
					Set reconstructedScope = ""
					Set arrIter = pJWTObj.scp.%GetIterator()
					While arrIter.%GetNext(.arrIdx, .oneScope) {
						If '$IsObject(oneScope) {
							If oneScope '= "" {
								Set reconstructedScope = reconstructedScope _ $Select(reconstructedScope'="":" ", 1:"") _ oneScope
							}
						} Else {
							// If array is not all strings then abort the reconstruct.
							Set reconstructedScope = ""
							Quit
						}
					}
					If reconstructedScope '= "" {
						Set pJWTObj.scope = reconstructedScope
					}
				} 
			}
		}
	}
	
	Return status
}

/// This method:<br>
/// - Does not add an OAuth server.<br>
/// - Adds an OAuth client-side ServerDefinition for the issuer URL for the server, if one does not already exist.<br>
/// - Adds an OAuth client for the BFC endpoint to use for validating incoming access tokens,
///   if that client does not already exist.<br>
/// - Adds any other OAuth clients specified in the config metadata, for REST clients
///   of the BFC to use.<br>
/// Clients are set up both on the server and on the client-side ServerDefinition.
/// However, it is usually only the server-side client that is used at run-time.
ClassMethod AddOAuthDefinitions(pBFCconfig As HS.BulkFHIR.API.Data.Config) [ Internal, Private ]
{
	#dim authConfig As HS.BulkFHIR.Auth.OAuth.Config = $$$BFCAuthConfig(pBFCconfig)
	
	new $namespace
	set $namespace = "%SYS"
	
	set issuerURL = pBFCconfig."auth_config"."issuer_url"
	
	set BFCClientName = pBFCconfig."auth_config"."bfc_client_name"
	
	set serverDefinition = ##class(OAuth2.ServerDefinition).OpenByIssuer(issuerURL)
	// If a ServerDefinition for the issuer URL exists, then do not modify it.
	// Otherwise, create a new ServerDefinition.
	if '$isobject(serverDefinition) {
		$$$ThrowOnError(##class(%SYS.OAuth2.Registration).Discover(issuerURL, $$$BFCBaseSSLConfig, .serverDefinition))
	}
	
	// Ensure the client that the BFC itself will use for validating an incoming access token.
	set client = ##class(OAuth2.Client).%OpenId(BFCClientName)
	if '$isobject(client) {
		// If the Client exists, then do not modify it. Otherwise, create a new Client.
		set client = ##class(OAuth2.Client).%New()
		set client.ApplicationName = BFCClientName
		set client.Description = "This client represents the Bulk FHIR Coordinator as a resource server (though that client type should not be used). This allows the BFC to authenticate incoming requests"
		set client.ClientType = "confidential"
		set client.SSLConfiguration = $$$BFCBaseSSLConfig
		set client.ServerDefinition = serverDefinition
		set client.RedirectionEndpoint.UseSSL = 1
	
		set client.Metadata."token_endpoint_auth_method" = "client_secret_post"
		set client.Metadata."grant_types" = $lb("client_credentials")
		set client.Metadata."client_name" = BFCClientName
		set client.Metadata."access_token_signed_response_alg" = "RS256"
		
		set client.RedirectionEndpoint.Host = $$$HSSecureHostName
		set client.RedirectionEndpoint.Port = $$$HSSecurePort
		set client.RedirectionEndpoint.Prefix = $$$HSSecurePrefix
		
		$$$ThrowOnError(client.RegisterClient())
	}
	
	// Ensure the client(s) that are allowed to be used to verify incoming access token
	// 
	for i=1:1:authConfig.clients.Count() {
		#dim clientDescription as HS.BulkFHIR.Auth.OAuth.ClientConfig = authConfig.clients.GetAt(i)
		
		set client = ##class(OAuth2.Client).%OpenId(clientDescription.name)
		// If the Client exists, then do not modify it. Otherwise, create a new Client.
		if '$isobject(client) {
			set client = ##class(OAuth2.Client).%New()
			set client.ApplicationName = clientDescription.name
			
			set client.ClientType = "confidential"
			set client.SSLConfiguration = $$$BFCBaseSSLConfig
			set client.ServerDefinition = serverDefinition
			set client.RedirectionEndpoint.UseSSL = 1
			
			set client.Metadata."client_name" = clientDescription.name
			set client.Metadata."access_token_signed_response_alg" = "RS256"
			set client.Metadata."token_endpoint_auth_signing_alg" = "ES384"
			set client.Metadata."grant_types" = $lb("client_credentials", "refresh_token")
			
			set client.RedirectionEndpoint.Host = $$$HSSecureHostName
			set client.RedirectionEndpoint.Port = $$$HSSecurePort
			set client.RedirectionEndpoint.Prefix = $$$HSSecurePrefix
			
			set client.Metadata."token_endpoint_auth_method" = clientDescription."authentication_method"
			
			$$$ThrowOnError(client.RegisterClient())
		}
	}
}

}
