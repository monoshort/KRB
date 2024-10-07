Class HS.BulkFHIR.Fetch.ODS.Config Extends HS.BulkFHIR.Fetch.PureFHIR.Config
{

/// https://usjira.iscinternal.com/browse/IF-3640
/// style like {property}:{group}:{category}:{property rename} where group, category, and property rename are optional.  
/// In this case category would be Authorization, and groups would be HTTP, X-API, OAuth.
/// A '-' before a setting will exclude it from the list returned to the UI
Parameter SETTINGS = "endpoint_url:::Endpoint URL,ssl_configuration:::SSL Configuration,resource_types,max_req_per_sec:::Max Requests Per Second,http_timeout:::HTTP Timeout,http_credential_id:HTTP:Authorization:HTTP Credential ID,-x_api_key_credential_id,oauth_issuer_url:OAuth:Authorization:OAuth Issuer URL,client_name:OAuth:Authorization,grant_type:OAuth:Authorization,fetch_token_scopes:OAuth:Authorization,fetch_token_credential_id:OAuth:Authorization:Fetch Token Credential ID,worker_jobs,registry_webservice_credential_id:::Registry Webservice Credential ID,registry_webservice_endpoint_url:::Registry Webservice Endpoint URL";

/// This will be applied to the HSREGISTRY WebServices Service Registry entry
/// Username Token Profile setting, and will be used as an input when invoking
/// the web service at runtime.
Property "registry_webservice_credential_id" As %String [ Required ];

/// UCR Hub (HSREGISTRY) WebServices url, eg. "http://example.org/csp/healthshare/hsregistry/services/HS.Hub.HSWS.WebServices.cls"
Property "registry_webservice_endpoint_url" As %String(MAXLEN = 250) [ Required ];

}
