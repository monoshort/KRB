Class HS.BulkFHIR.Auth.OAuth.Config Extends HS.BulkFHIR.API.Data.AdapterConfig
{

/// Issuer url of an existing OAuth server to be used for the
/// Bulk FHIR endpoint (e.g., "https://example.org/oauth2").
Property "issuer_url" As %String(MAXLEN = "") [ Required ];

/// The Bulk FHIR Coordinator uses this OAuth client for communicating with the
/// OAuth server to validate tokens on requests to the Bulk FHIR endpoint. If this
/// client is already defined then it is not updated. Otherwise, if this client
/// is not defined then it is auto-created when the Bulk FHIR config is saved.
Property "bfc_client_name" As %String(MAXLEN = 128) [ Required ];

/* If a specified client is already defined, then it is not
 	updated. Otherwise, if a specified client is not defined, then it is auto-created
 	when the Bulk FHIR config is saved.*/
/// OAuth clients designated as approved for sending requests to the Bulk FHIR
/// endpoint (i.e., the client ID on a token is validated against the client IDs
/// for these clients). 
/// Clients can be specified as a comma-separated list of the form "name:authentication_method,name:authentication_method,..."
/// where the name is a unique name to identify the client which will be used as the key for referencing operations by this client,
/// and the authentication method is how this client will authenticate with the OAuth server.
/// The authentication method must be either "client_secret_post" or "private_key_jwt".
Property clients As list Of HS.BulkFHIR.Auth.OAuth.ClientConfig;

/// https://usjira.iscinternal.com/browse/IF-3640
/// style like {property}:{group}:{category}:{property rename} where group, category, and property rename are optional.  
/// In this case category would be Authorization, and groups would be HTTP, X-API, OAuth.
/// A '-' before a setting will exclude it from the list returned to the UI
Parameter SETTINGS = "issuer_url:::Issuer URL,bfc_client_name:::BFC Client Name,clients:::Clients";

Method %OnValidateObject() As %Status
{
	set sslStart = "https:"
	
	if $Extract(.."issuer_url", 1, $Length(sslStart)) '= sslStart {
		return $$$ERROR($$$HSBFCErrInvalidConfig, "issuer_url must start with '" _ sslStart _ "'")
	}

	return $$$OK
}

}
