/// Class for holding and passing information related to the OAuth access
/// token for a given Fetch RestClient instance.
Class HS.BulkFHIR.Fetch.Util.AccessToken Extends %RegisteredObject
{

/// OAuth Client defined in IRIS.
Property OAuthClientName As %String(MAXLEN = "");

/// OAuth SessionId to use for obtaining and retrieving tokens.
Property TokenSessionId As %String(MAXLEN = "");

/// OAuth grant type to use for obtaining the token from the resource server.
Property GrantType As %String;

/// %DynamicObject of information about the OAuth access token
/// that was on the request to the Bulk FHIR endpoint itself.
Property BFCTokenInfo As %DynamicObject;

/// %DynamicObject of auxiliary information to use when requesting an
/// access token from the resource server.
Property FetchTokenInfo As %DynamicObject;

/// Create an instance of this class, deriving much of the input from a BFC Session object.
ClassMethod CreateFromSession(pSession As HS.BulkFHIR.Session, pTokenSessionId As %String) As HS.BulkFHIR.Fetch.Util.AccessToken
{
	Return ..Create(pSession.configuration."fetch_config"."client_name", pTokenSessionId, pSession.configuration."fetch_config"."grant_type", pSession.tokenInfo, pSession.fetchTokenInfo)
}

/// Create an instance of this class, with all input explicitly specified.
ClassMethod Create(pOAuthClientName As %String, pTokenSessionId As %String, pGrantType As %String, pBFCTokenInfo As %DynamicObject, pFetchTokenInfo As %DynamicObject) As HS.BulkFHIR.Fetch.Util.AccessToken
{
	If pOAuthClientName '= "" {
		Set obj = ..%New()
		Set obj.OAuthClientName = pOAuthClientName
		Set obj.TokenSessionId = pTokenSessionId
		Set obj.GrantType = pGrantType
		Set obj.BFCTokenInfo = pBFCTokenInfo
		Set obj.FetchTokenInfo = pFetchTokenInfo
		
	} Else {
		Set obj = ""
	}
	
	Return obj
}

}
