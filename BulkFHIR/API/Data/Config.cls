Include HS.BulkFHIR

Class HS.BulkFHIR.API.Data.Config Extends (%RegisteredObject, %JSON.Adaptor)
{

/// Relative url to host the Bulk FHIR Coordinator from.
/// Eg. "/bulkfhir/r4"
Property "endpoint_url" As %String(MAXLEN = 250) [ Required ];

/// Name for this Bulk FHIR Coordinator. Will be used
/// as the value in the Coordinator's CapabilityStatement
/// name.
Property name As %String [ Required ];

/// FHIR package id for this Coordinator. Eg.
/// "hl7.fhir.r4.core@4.0.1"
Property "core_fhir_package" As %String(MAXLEN = 100);

/// Maximum size (in bytes) any file will be exported
/// as. Note that this cannot be honored if a single
/// resource is larger than this value.
Property "max_file_size" As %Integer(MINVAL = 1) [ InitialExpression = 1000000000, Required ];

/// Approximate maximum number of minutes resources
/// can be buffered before a flush to the storage
/// adapter is forced
Property "flush_interval_mins" As %Integer(MINVAL = 0) [ InitialExpression = 60, Required ];

/// Flag indicating whether export jobs will be
/// started as soon as they come in, or if they
/// require manual approval.
Property "auto_start" As %Boolean [ InitialExpression = 1, Required ];

/// Whether the Patient export operation (/Patient/$export)
/// is supported
Property "patient_export" As %Boolean [ InitialExpression = 1, Required ];

/// Whether the Group export operation (/Group/<id>/$export)
/// is supported
Property "group_export" As %Boolean [ InitialExpression = 1, Required ];

/// Whether the system level export operation (/$export)
/// is supported
Property "system_export" As %Boolean [ InitialExpression = 1, Required ];

/// How many minutes after the export is completed before
/// the files are deemed expired, and may be deleted.
Property "expire_after_mins" As %Integer(MINVAL = 0) [ InitialExpression = 1440, Required ];

/// Name of the fetch adapter to use in retreiving clinical
/// data as FHIR.
Property "fetch_adapter" As %String(MAXLEN = 220) [ Required ];

/// Configuration object for the fetch adapter. The schema
/// for this object will be defined by the fetch adapter
/// itself.
Property "fetch_config" As HS.BulkFHIR.API.Data.AdapterConfig(%JSONINCLUDE = "OUTPUTONLY") [ Required ];

/// Name of the auth adapter to use for authenticating
/// and authorizing clients to interact with the Bulk
/// FHIR coordinator
Property "auth_adapter" As %String(MAXLEN = 220) [ Required ];

/// Configuration object for the auth adapter. The schema
/// for this object will be defined by the auth adapter
/// itself.
Property "auth_config" As HS.BulkFHIR.API.Data.AdapterConfig(%JSONINCLUDE = "OUTPUTONLY") [ Required ];

/// Name of the storage adapter to use for persisting
/// files generated during the bulk export operation.
Property "storage_adapter" As %String(MAXLEN = 220) [ Required ];

/// Configuration object for the storage adapter. The schema
/// for this object will be defined by the storage adapter
/// itself.
Property "storage_config" As HS.BulkFHIR.API.Data.AdapterConfig(%JSONINCLUDE = "OUTPUTONLY") [ Required ];

/// Directory where temporary files will be stored before being passed to the storage file adapter
Property "working_directory" As %String(MAXLEN = 512) [ InitialExpression = {##class(%Library.File).NormalizeDirectory($system.Util.ManagerDirectory()_"Temp/BulkFHIR/"_$namespace)} ];

/// Capability statement of resource server
Property "capability_statement" As %String(MAXLEN = "");

/// Non-administrative users who are permitted to initiate exports on this configuration
Property "authorized_users" As list Of %String;

/// @API
/// Converts a json string or %DynamicObject into an instance of 
/// the config object
ClassMethod FromJson(json) As HS.BulkFHIR.API.Data.Config
{
	if '$isobject(json) {
		set json = {}.%FromJSON(json)
	}
	
	set config = ##class(HS.BulkFHIR.API.Data.Config).%New()
	$$$ThrowOnError(config.%JSONImport(json))
	
	if '##class(%Dictionary.ClassDefinition).%ExistsId($$$BFCFetchClass(config)) {
		$$$ThrowFHIR($$$HSBFCErrAdapterClassDoesNotExist, $$$BFCFetchClass(config))
	}
	if '##class(%Dictionary.ClassDefinition).%ExistsId($$$BFCAuthClass(config)) {
		$$$ThrowFHIR($$$HSBFCErrAdapterClassDoesNotExist, $$$BFCAuthClass(config))
	}
	if '##class(%Dictionary.ClassDefinition).%ExistsId($$$BFCStorageClass(config)) {
		$$$ThrowFHIR($$$HSBFCErrAdapterClassDoesNotExist, $$$BFCStorageClass(config))
	}
	
	set $$$BFCFetchConfig(config) = $classmethod($parameter($$$BFCFetchClass(config), "configClass"), "FromJson", $S(json."fetch_config"="":{},1:json."fetch_config"))
	set $$$BFCAuthConfig(config) = $classmethod($parameter($$$BFCAuthClass(config), "configClass"), "FromJson", $S(json."auth_config"="":{},1:json."auth_config"))
	set $$$BFCStorageConfig(config) = $classmethod($parameter($$$BFCStorageClass(config), "configClass"), "FromJson", $S(json."storage_config"="":{},1:json."storage_config"))
	If config."endpoint_url" = $$$BFCStorageConfig(config)."file_url" {
		$$$ThrowFHIR($$$HSBFCErrDuplicateApp)
	}
	
	return config
}

Method %OnValidateObject() As %Status
{
	if '##class(%Dictionary.ClassDefinition).%ExistsId(.."fetch_adapter") {
		return $$$ERROR($$$HSBFCErrAdapterClassDoesNotExist, .."fetch_adapter")
	}
	if '##class(%Dictionary.ClassDefinition).%ExistsId(.."auth_adapter") {
		return $$$ERROR($$$HSBFCErrAdapterClassDoesNotExist, .."auth_adapter")
	}
	if '##class(%Dictionary.ClassDefinition).%ExistsId(.."storage_adapter") {
		return $$$ERROR($$$HSBFCErrAdapterClassDoesNotExist, .."storage_adapter")
	}
	
	return $$$OK
}

}
