Class HS.BulkFHIR.Fetch.ODS.Adapter Extends HS.BulkFHIR.Fetch.PureFHIR.Adapter
{

Parameter configClass As String = "HS.BulkFHIR.Fetch.ODS.Config";

/// ODS does not support unqualified search, therefore cannot
/// support a system level export as implemented in the pure
/// fhir adapter.
Parameter supportsSystemExport As Boolean = 0;

/// Return an instance of a FHIR REST client object to use for sending FHIR
/// requests to the resource server. Parameters of the client object are
/// based on the specified BFC configuration object, and other ODS-specific
/// items in this method. The configuration object is obtained from a
/// specified session object, or as a directly specified configuration object.
ClassMethod GetRestClient(pSession As HS.BulkFHIR.Session = "", pBFCconfig As HS.BulkFHIR.API.Data.Config = "", pTokenObj As HS.BulkFHIR.Fetch.Util.AccessToken = "") As HS.BulkFHIR.Fetch.Util.RestClient [ Internal ]
{
	// One of either pSession or pBFCConfig must be specified in input.
	
	If $IsObject(pSession) {
		Set bfcConfig = pSession.configuration
		Set sessionId = pSession.%Id()
		
	} Else {
		Set bfcConfig = pBFCconfig
		Set sessionId = ""
	}
	
	#dim fetchConfig as HS.BulkFHIR.Fetch.PureFHIR.Config = $$$BFCFetchConfig(bfcConfig)
	set headers("X_ISC_SUPPRESS_AUDIT") = 1
	// Specify Prefer handling=lenient so that the request does not fail on possibly
	// unsupported parameters like _lastUpdated or _elements. If any of those params
	// is supported, then it helps optimize the export process. If none of those
	// params is supported, the BFC can still function okay.
	set headers("Prefer") = "handling=lenient"
	Set serviceEntryName = $$$ServiceName(bfcConfig)
	return ##class(HS.BulkFHIR.Fetch.Util.RestClient).getInstance(serviceEntryName, fetchConfig."max_req_per_sec", pTokenObj, sessionId, .headers)
}

/// ODS-specific fetch adapter setup.
ClassMethod Initialize(pBFCconfig As HS.BulkFHIR.API.Data.Config)
{
	Do ##super(pBFCconfig)
	
	#dim fetchConfig As HS.BulkFHIR.Fetch.ODS.Config = $$$BFCFetchConfig(pBFCconfig)
	
	set serviceRegistryEntry = ##class(HS.Registry.Service.Abstract).EndPointForNameType($$$UCRServiceName(fetchConfig), "SOAP")
	if '$isobject(serviceRegistryEntry) {
		set serviceRegistryEntry = ##class(HS.Registry.Service.SOAP).%New()
		/// if ssl but none was defined use $$$BFCBaseSSLConfig
		Set sslConfig = $S(fetchConfig."ssl_configuration"="":$$$BFCBaseSSLConfig,1:fetchConfig."ssl_configuration")
		set serviceRegistryEntry.SSLConfig = $select($extract(fetchConfig."registry_webservice_endpoint_url", 1, 5) = "https":sslConfig, 1:"")
	}
	set serviceRegistryEntry.Name = $$$UCRServiceName(fetchConfig)
	set serviceRegistryEntry.Type = "SOAP"
	$$$ThrowOnError(serviceRegistryEntry.ParseURL(fetchConfig."registry_webservice_endpoint_url"))
	set serviceRegistryEntry.Timeout = fetchConfig."http_timeout"
	
	set serviceRegistryEntry.UsernameTokenProfileConfig = fetchConfig."registry_webservice_credential_id"
	$$$ThrowOnError(serviceRegistryEntry.%Save())
}

/// Perform a FHIR Search on an ODS resource server. Search on the Group resource type
/// is sent directly to the ODS registry web service endpoint as a SOAP request, using
/// the registry web service credential. Search on other resource type is done as a
/// FHIR request, using the logic in the super class.
ClassMethod Search(pConfig As HS.BulkFHIR.API.Data.Config, request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response)
{
	if request.Type '= "Group" {
		do ##super(pConfig, request, .response)
		
	} else {
		#dim fetchConfig As HS.BulkFHIR.Fetch.ODS.Config = $$$BFCFetchConfig(pConfig)
		set credentialConfig = ##class(Ens.Config.Credentials).%OpenId(fetchConfig."registry_webservice_credential_id")
		
		do ##class(HS.BulkFHIR.Fetch.ODS.GroupUCR).SearchGroup(pConfig, request, .response, $$$UCRServiceName(fetchConfig), ..GroupSearchParameters(pConfig), credentialConfig.Username)
	}
}

/// Perform a FHIR Read on an ODS resource server. Read on the Group resource type is
/// sent directly to the ODS registry web service endpoint as a SOAP request, using
/// the registry web service credential. Read on other resource type is done as a
/// FHIR request, using the logic in the super class.
ClassMethod Read(pConfig As HS.BulkFHIR.API.Data.Config, request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response)
{
	if request.Type '= "Group" {
		do ##super(pConfig, request, .response)
		
	} else {
		#dim fetchConfig As HS.BulkFHIR.Fetch.ODS.Config = $$$BFCFetchConfig(pConfig)
		set credentialConfig = ##class(Ens.Config.Credentials).%OpenId(fetchConfig."registry_webservice_credential_id")
		
		do ##class(HS.BulkFHIR.Fetch.ODS.GroupUCR).ReadGroup(request, .response, $$$UCRServiceName(fetchConfig), credentialConfig.Username)
	}
}

/// Return a %DynamicArray of the search parameters supported for the Group resource type.
ClassMethod GroupSearchParameters(pConfig As HS.BulkFHIR.API.Data.Config) As %DynamicArray
{
	return [
		{
			"name": "_id",
			"type": "token"
		},
		{
			"name": "actual",
			"type": "token"
		},
		{
			"name": "code",
			"type": "token"
		},
		{
			"name": "type",
			"type": "token"
		}
	]
}

}
