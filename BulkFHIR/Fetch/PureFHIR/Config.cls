Class HS.BulkFHIR.Fetch.PureFHIR.Config Extends HS.BulkFHIR.API.Data.AdapterConfig
{

/// https://usjira.iscinternal.com/browse/IF-3640
/// style like {property}:{group}:{category}:{property rename} where group, category, and property rename are optional.  
/// In this case category would be Authorization, and groups would be HTTP, X-API, OAuth.
/// A '-' before a setting will exclude it from the list returned to the UI
Parameter SETTINGS = "endpoint_url:::Endpoint URL,ssl_configuration:::SSL Configuration,resource_types,max_req_per_sec:::Max Requests Per Second,http_timeout:::HTTP Timeout,http_credential_id:HTTP:Authorization:HTTP Credential ID,x_api_key_credential_id:X-API:Authorization:X-API Key Credential,oauth_issuer_url:OAuth:Authorization:OAuth Issuer URL,client_name:OAuth:Authorization,grant_type:OAuth:Authorization,fetch_token_scopes:OAuth:Authorization,fetch_token_credential_id:OAuth:Authorization:Fetch Token Credential ID,worker_jobs";

/// Base full url for a FHIR resource server endpoint, eg. "https://example.org/fhir/r4"
Property "endpoint_url" As %String(MAXLEN = 250) [ Required ];

/// Default SSL configuration when using https
Property "ssl_configuration" As %String [ InitialExpression = {$$$BFCBaseSSLConfig} ];

/// Default list of resource types to include in an export operation.
/// Can be overridden by a client using the _type query parameter.
/// Leaving this empty will include all resource types by default.
Property "resource_types" As list Of %String;

/// Maximum number of HTTP requests to make to the FHIR endpoint in
/// a second. This number will be shared across all active export
/// operations, and may be used to limit the load imposed by the
/// coordinator on the endpoint.
Property "max_req_per_sec" As %Integer [ InitialExpression = 10, Required ];

/// The Interoperability Credential ID to use in authenticating
/// with the FHIR endpoint if using Basic Auth.
Property "http_credential_id" As %String;

/// Timeout value when fetching data from resource server.
Property "http_timeout" As %Integer [ InitialExpression = 180 ];

/// _count to add to search and $everything requests
/// Setting this value over the default for the FHIR Server can speed up performance by reducing paging.
/// Note, FHIR Servers may have a limit lower than the selected value for how many results will be returned per page
/// and some FHIR Servers may not support _count for all request types
Property "fetch_count" As %Integer [ InitialExpression = 500 ];

/// The Interoperability Credential ID to use in authenticating
/// with the FHIR endpoint if using the x-api-key header. The
/// credential password shall contain the api key.
Property "x_api_key_credential_id" As %String;

/// Issuer url for the FHIR endpoint's OAuth server.
Property "oauth_issuer_url" As %String(MAXLEN = "");

/// Name to identify the Bulk FHIR Coordinator with
/// the FHIR endpoint's OAuth server, if using OAuth.
Property "client_name" As %String(MAXLEN = "");

/// OAuth grant type to use when obtaining an access
/// token from the FHIR endpoint's OAuth server.
Property "grant_type" As %String(VALUELIST = ",client_credentials,password");

/// Comma-delimited list of OAuth scopes to specify when obtaining
/// an access token from the FHIR endpoint's OAuth server. Applies
/// only when there was no access token in the request to the Bulk
/// FHIR Coordinator.
Property "fetch_token_scopes" As list Of %String(MAXLEN = "");

/// The Interoperability Credential ID to use in authenticating
/// with the FHIR endpoint's OAuth server for a grant type that
/// needs Basic Auth credentials.
Property "fetch_token_credential_id" As %String;

/// Number of worker jobs (background) assigned to do processing
Property "worker_jobs" As %Integer [ InitialExpression = 4 ];

Method %OnValidateObject() As %Status
{
	Set url = $zcvt(.."endpoint_url","l")
	If $Extract(url,1,7)'="http://" && ($Extract(url,1,8)'="https://") {
		return $$$ERROR($$$HSBFCErrInvalidConfig, "endpoint_url must start with http:// or https://")
	}
	//confirm OAuth
	if .."oauth_issuer_url" '= "" {
		
		set sslStart = "https:"
		
		if .."client_name" = "" {
			return $$$ERROR($$$HSBFCErrInvalidConfig, "client_name must be defined if using OAuth for fetch")
			
		} elseif .."grant_type" = "" {
			return $$$ERROR($$$HSBFCErrInvalidConfig, "grant_type must be defined if using OAuth for fetch")
			
		} elseif $Extract(.."oauth_issuer_url", 1, $Length(sslStart)) '= sslStart {
			return $$$ERROR($$$HSBFCErrInvalidConfig, "oauth_issuer_url must start with '" _ sslStart _ "' if using OAuth for fetch")
			
		} elseif $Extract(.."endpoint_url", 1, $Length(sslStart)) '= sslStart {
			return $$$ERROR($$$HSBFCErrInvalidConfig, "endpoint_url must start with '" _ sslStart _ "' if using OAuth for fetch")
			
		} elseif (.."grant_type" = "password") && (.."fetch_token_credential_id" = "") {
			return $$$ERROR($$$HSBFCErrInvalidConfig, "fetch_token_credential_id must be defined if OAuth grant_type is 'password'")
			
		} elseif (.."fetch_token_credential_id" '= "") && ('##class(Ens.Config.Credentials).%ExistsId(.."fetch_token_credential_id")) {
			return $$$ERROR($$$HSBFCErrInvalidConfig, "fetch_token_credential_id '" _ .."fetch_token_credential_id" _ "' not defined as Interoperability Credentials entry in this namespace")
			
		} elseif .."x_api_key_credential_id" '= "" {
			return $$$ERROR($$$HSBFCErrInvalidConfig, "x_api_key_credential_id cannot be defined if using OAuth for fetch")
		}
	}
	//confirm basic auth
	elseif .."http_credential_id" '= "" {
		if '##class(Ens.Config.Credentials).%ExistsId(.."http_credential_id") {
			return $$$ERROR($$$HSBFCErrInvalidConfig, "http_credential_id '" _ .."http_credential_id" _ "' not defined as Interoperability Credentials entry in this namespace")
			
		} elseif .."x_api_key_credential_id" '= "" {
			return $$$ERROR($$$HSBFCErrInvalidConfig, "x_api_key_credential_id cannot be defined if using http_credential_id for fetch")
		}
	}
	//confirm x-api-key header auth
	elseif .."x_api_key_credential_id" '= "" {
		if '##class(Ens.Config.Credentials).%ExistsId(.."x_api_key_credential_id") {
			return $$$ERROR($$$HSBFCErrInvalidConfig, "x_api_key_credential_id '" _ .."x_api_key_credential_id" _ "' not defined as Interoperability Credentials entry in this namespace")
		}
	}
	else {
		return $$$ERROR($$$HSBFCErrInvalidConfig, "One of oauth_issuer_url, http_credential_id, or x_api_key_credential_id must be defined")
	}
	
	return $$$OK
}

}
