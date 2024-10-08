Include (%ZHSLIB, EnsUtil)

/// Utility for setting up an IRIS OAuth 2.0 authorization server in the local IRIS
/// instance, specifically for handling SMART Backend Services Authorization for
/// the Bulk FHIR Coordinator.
Class HS.BulkFHIR.OAuth2Installer
{

/// SSL Configuration Name used throughout this utility.
Parameter OAuthSSLConfigName As String = "OAuth2.SSLConfig";

/// HTTP Service Registry entry name used throughout this utility.
Parameter OAuthIssuerServiceName As String = "OAuth2.Issuer";

/// SetupOAuthServer configures an IRIS OAuth 2.0 authorization server in the local
/// IRIS instance specifically for SMART Backend Services Authorization and creates
/// a Service Registry entry that points to the OAuth server issuer endpoint. This
/// method depends on class parameters OAuthSSLConfigName and OAuthIssuerServiceName
/// for the values of those two items.<br>
/// <br>
/// Prerequisites for using this method:<br>
/// - A web server and SSL is already configured for the current IRIS instance.<br>
/// - Installer Wizard Secure Communications definitions are already present and active.<br>
/// - Must be invoked in a Foundation namespace that is targeted for installing
///   Bulk FHIR Coordinator configurations.<br>
/// <br>
/// Input:<br>
/// - pForceDelete: 0 = abort and return fail if an existing OAuth server is found,
///                 1 = delete existing OAuth server and its clients before re-creating.<br>
/// - pVerbose:     0 = do not display method outcome text,
///                 1 = display method outcome text.
ClassMethod SetupOAuthServer(pForceDelete As %Boolean = 0, pVerbose As %Boolean = 1) As %Status
{
	Set sc = $$$OK
	
	Try {
		Do ..VerifyPrerequisites()
		
		// Ensure that the specified SSL Config exists.
		Do ##class(HS.HC.SystemConfig.API).CreateSSLConfig("%", ..#OAuthSSLConfigName, "")
		
		Set host = $$$HSNetworkHostName
		Set port = $$$HSSecurePort
		Set prefix = $$$HSSecurePrefix
		
		$$$ThrowOnError(..ConfigureAuthServer(.issuerURL, host, port, prefix, pForceDelete))
		
		$$$ThrowOnError(..ConfigureServiceRegistryEntry())

	} Catch eException {
		Set sc = eException.AsStatus()
	}
	
	If pVerbose {
		If $$$ISERR(sc) {
			Write !,$ClassName() _ " " _ $$$CurrentMethod _ " - " _ $system.Status.GetErrorText(sc)
		} Else {
			Write !,$ClassName() _ " " _ $$$CurrentMethod _ " completed successfully"
		}
	}
	
	Quit sc
}

/// @API.Method<br>
/// Configure an IRIS OAuth 2.0 authorization server in the local IRIS instance
/// specifically for handling SMART Backend Services Authorization for Bulk FHIR
/// Coordinator endpoints. This method does not overlay an existing server with
/// new definitions. When a server already exists, this method either deletes
/// the server before proceeding, or aborts, depending on the pForceDelete input
/// parameter.<br>
/// <br>
/// Input:<br>
/// - pHost       : Local secure web server host name.<br>
/// - pPort       : Local secure web server port.<br>
/// - pPrefix     : Local secure web server path prefix.<br>
/// - pForceDelete: 0 = abort and return fail if an existing OAuth server is found,
///                 1 = delete existing OAuth server and its clients before re-creating.
ClassMethod ConfigureAuthServer(Output pIssuerURL As %String, pHost As %String, pPort As %String, pPathPrefix As %String, pForceDelete As %Boolean = 0) As %Status
{
	Set sc = $$$OK
	
	New $Namespace
	
	Try {
		Set $Namespace = "%SYS"
		
		Set server = $ClassMethod("OAuth2.Server.Configuration", "Open")
		If $IsObject(server) {
			// Delete an existing Server configuration, or abort.
			If pForceDelete {
				$$$ThrowOnError(server.Delete())
				Kill server
			} Else {
				$$$ThrowOnError($$$ERROR($$$GeneralError, "OAuth 2.0 Server Configuration already exists in this instance. To delete and re-create the OAuth 2.0 Server Configuration, specify pForceDelete input value of 1."))
			}
		}
		
		Set server = $ClassMethod("OAuth2.Server.Configuration", "%New")
		Set server.Description = "InterSystems OAuth server for the Bulk FHIR Coordinator; generated by " _ $ClassName()
		Set server.IssuerEndpoint.Host       = pHost
		Set server.IssuerEndpoint.Port       = pPort
		Set server.IssuerEndpoint.Prefix     = pPathPrefix
		Set server.IssuerEndpoint.UseSSL     = 1
		Set server.AllowUnsupportedScope     = 0
		Set server.AudRequired               = 0
		Set server.SupportSession            = 0
		Set server.ReturnRefreshToken        = "a"
		Set server.SupportedGrantTypes       = "CJ"
		Set server.GenerateTokenClass        = "%OAuth2.Server.JWT"
		Set server.CustomizationNamespace    = "%SYS"
		Set server.CustomizationRoles        = "%All"
		Set server.AccessTokenInterval       = 300
		
		Do server.SupportedScopes.SetAt("Permission to export all resources that the current user can access", "system/*.read")
		Do server.SupportedScopes.SetAt("Permission to search and read Group resources that the current user can access", "user/Group.read")
		Set server.DefaultScope              = "system/*.read"
		Set server.SSLConfiguration          = ..#OAuthSSLConfigName
		
		Set server.Metadata."token_endpoint_auth_methods_supported" = $lb("client_secret_post", "private_key_jwt")
		
		Set sc = server.Save()
		
	} Catch eException {
		Set sc = eException.AsStatus()
	}
	
	Quit sc
}

/// SetupServiceEntry creates a Service Registry entry in the current namespace
/// to point to the issuer endpoint for the OAuth server in the current IRIS
/// instance. This method depends on class parameters OAuthSSLConfigName and
/// OAuthIssuerServiceName for the values of those two items.<br>
/// <br>
/// Prerequisites for using this method:<br>
/// - A web server and SSL is already configured for the current IRIS instance.<br>
/// - Installer Wizard Secure Communications definitions are already present and active.<br>
/// - Must be invoked in a Foundation namespace that is targeted for installing
///   Bulk FHIR Coordinator configurations.<br>
/// <br>
/// Input:<br>
/// - pVerbose: 0 = do not display method outcome text,
///             1 = display method outcome text.
ClassMethod SetupServiceEntry(pVerbose As %Boolean = 1) As %Status
{
	Set sc = $$$OK
	
	Try {
		Do ..VerifyPrerequisites()
		
		$$$ThrowOnError(..ConfigureServiceRegistryEntry())
	
	} Catch eException {
		Set sc = eException.AsStatus()
	}
	
	If pVerbose {
		If $$$ISERR(sc) {
			Write !,$ClassName() _ " " _ $$$CurrentMethod _ " - " _ $system.Status.GetErrorText(sc)
		} Else {
			Write !,$ClassName() _ " " _ $$$CurrentMethod _ " completed successfully"
		}
	}
	
	Quit sc
}

/// Internal method, called by SetupOAuthServer() and SetupServiceEntry().
ClassMethod ConfigureServiceRegistryEntry(pHost As %String = {$$$HSNetworkHostName}, pPort As %String = {$$$HSSecurePort}, pPrefix As %String = {$$$HSSecurePrefix}, pPath As %String = "/oauth2") As %Status [ Internal ]
{
	Set sc = $$$OK
	
	Try {
		#dim serviceObj As HS.Registry.Service.HTTP
		
		Set serviceObj = ##class(HS.Registry.Service.Abstract).EndPointForNameType(..#OAuthIssuerServiceName, "HTTP")
		If '$IsObject(serviceObj) {
			Set serviceObj = ##class(HS.Registry.Service.HTTP).%New()
			Set serviceObj.Type = "HTTP"
			Set serviceObj.Name = ..#OAuthIssuerServiceName
		}
		Set serviceObj.Host = pHost
		Set serviceObj.Port = pPort
		Set serviceObj.URL = pPrefix _ pPath
		Set serviceObj.SSLConfig = ..#OAuthSSLConfigName
		Set sc = serviceObj.%Save()
	
	} Catch eException {
		Set sc = eException.AsStatus()
	}
	
	Quit sc
}

/// This method verifies the common prerequisites for SetupOAuthServer() and SetupServiceRegistryEntry().
ClassMethod VerifyPrerequisites() [ Internal ]
{
	Set validNamespaceTypes = $ListBuild("Foundation")
	
	Set configObj = ##class(HS.Util.Installer.ConfigItem).%OpenId($Namespace)
	If '$IsObject(configObj) {
		$$$ThrowStatus($$$ERROR($$$GeneralError, "Invalid namespace " _ $Namespace))
	} ElseIf '$ListFind(validNamespaceTypes, configObj.Type) {
		$$$ThrowStatus($$$ERROR($$$GeneralError, "Namespace " _ $Namespace _ " type is " _ configObj.Type _ ", must be " _ $Select($ListLength(validNamespaceTypes)>1:"one of ", 1:"") _ $ListToString(validNamespaceTypes)))
	}
	Kill configObj
	
	If '$$$HSSecureIsActive {
		$$$ThrowStatus($$$ERROR($$$GeneralError,"No active Installer Wizard Secure Communication definition found"))
	}
	
	If ..#OAuthSSLConfigName = "" {
		$$$ThrowStatus($$$ERROR($$$GeneralError,"SSL Configuration Name not specified"))
	}
	
	If ..#OAuthIssuerServiceName = "" {
		$$$ThrowStatus($$$ERROR($$$GeneralError,"OAuth Issuer Service Registry entry name not specified"))
	}
}

}
