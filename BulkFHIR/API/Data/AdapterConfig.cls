Include HS.BulkFHIR

/// Base adapter configuration class. Any adapter that wants to receive configuration
/// inputs must subclass this class and define properties (and optionally validation).
Class HS.BulkFHIR.API.Data.AdapterConfig Extends (%RegisteredObject, %JSON.Adaptor)
{

/// @API
/// Converts a json string or %DynamicObject into an instance of 
/// the config object
ClassMethod FromJson(json) As HS.BulkFHIR.API.Data.AdapterConfig
{
	set config = $classmethod(..%ClassName(1), "%New")
	$$$ThrowOnError(config.%JSONImport(json))
	
	return config
}

}
