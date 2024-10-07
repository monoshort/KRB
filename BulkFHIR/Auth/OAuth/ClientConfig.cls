Class HS.BulkFHIR.Auth.OAuth.ClientConfig Extends HS.BulkFHIR.API.Data.AdapterConfig
{

/// Unique name to identify this client. Will be used as the key
/// for referencing operations by this client.
Property name As %String(MAXLEN = 100, MINLEN = 1) [ Required ];

/// How this client will authenticate with the OAuth server. This
/// value is used only when Bulk FHIR config save is generating a
/// new client definition for this client.
Property "authentication_method" As %String(VALUELIST = ",client_secret_post,private_key_jwt,") [ Required ];

}
