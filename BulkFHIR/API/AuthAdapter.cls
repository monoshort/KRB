/// Base class for all auth adapters. Subclasses must extend this class,
/// uniquely identify themselves, and implement the abstract methods.
/// Then they may be used for auth tasks within a BFC.
Class HS.BulkFHIR.API.AuthAdapter Extends (HS.BulkFHIR.API.AdapterBase, %CSP.REST)
{

/// Whether the adapter uses OAuth access tokens. Used in conjunction
/// with the storage adapter to set the requireAccessToken setting
/// in a status request.
Parameter IsOAuth As Boolean [ Abstract ];

/// @API.Overridable<br>
/// Called when the BFC is first configured and again if that configuration
/// is changed, this method may be used to do any implementation-specific setup.
ClassMethod Initialize(pBFCConfig As HS.BulkFHIR.API.Data.Config)
{
}

/// @API.Overridable<br>
/// Authentication method to be called from the BFC Rest Handler OnPreDispatch.
/// Ensures that the request is authenticated. If authentication fails then this
/// method must set pContinue=0 before returning. This method will be invoked on
/// any HTTP request to the BFC Rest Handler, whether it is a kickoff request,
/// search, or request for status. The CSP %request and %response objects are
/// available to this method.<br>
/// @Input pUrl Portion of the request URL that follows the base URL.<br>
/// @Output pContinue Flag indicating whether to continue with DispatchClass processing.<br>
/// @Returns %Status.
ClassMethod Authenticate(pBFCconfig As HS.BulkFHIR.API.Data.Config, pUrl As %String, ByRef pContinue As %Boolean) As %Status [ Abstract ]
{
}

/// @API.Overridable<br>
/// Called on any FHIR request (search or operation), this API does any additional checking
/// necessary to verify that the request user is authorized for the current request.<br>
/// @Input pRequest	FHIR request object representing an interaction, eg. export or search<br>
/// @Input pBFCconfig BFC configuration for the current BFC endpoint.<br>
/// @Throws if request is not allowed, eg. $$$ThrowFHIR($$$HttpOnlyResponse(401))
ClassMethod AuthorizeFHIRRequest(pRequest As HS.FHIRServer.API.Data.Request, pBFCconfig As HS.BulkFHIR.API.Data.Config)
{
}

/// @API.Overridable<br>
/// If using OAuth, this method is expected to return the information from the
/// baseURL/.well-known/smart-configuration query on the BFC endpoint.<br>
/// @Input pBFCconfig Full BFC configuration object in effect for the current BFC endpoint.<br>
/// @Returns a %DynamicObject representing the .well-known/smart-configuration for an endpoint.
ClassMethod WellKnownConfiguration(pBFCconfig As HS.BulkFHIR.API.Data.Config) As %DynamicObject
{
	return {}
}

/// @API.Overridable<br>
/// If using OAuth, this method is expected to return selected information about
/// the OAuth access token, if any, that is on the request to the BFC.<br>
/// @Input pBFCconfig Full BFC configuration object in effect for the current BFC session.<br>
/// @Input pTokenString Encoded string representation of an access token provided on the current request to the BFC.<br>
/// @Returns a %DynamicObject representing the access token information.
ClassMethod GetAccessTokenInfo(pBFCconfig As HS.BulkFHIR.API.Data.Config, pTokenString As %String) As %DynamicObject
{
	return {}
}

}
