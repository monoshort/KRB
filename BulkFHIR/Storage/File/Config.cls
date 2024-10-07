Class HS.BulkFHIR.Storage.File.Config Extends HS.BulkFHIR.API.Data.AdapterConfig
{

Parameter SETTINGS = "file_url:::File URL";

/// CSP Application URL to serve bulk export files.  
/// Multiple configurations in a single namespace can use the same URL.
/// Eg. "/file" or "/bulkfhir/file"
Property "file_url" As %String(MAXLEN = 512) [ Required ];

/// Storage location of ndjson files, which defaults to the instance mgr/Temp/BulkFHIR/$namespace/ and will contain 
/// session directories with resource group directories and files.  
/// Distinct directories must be used between namespaces due to collisions in session identifiers.
Property directory As %String(MAXLEN = 512) [ InitialExpression = {##class(%Library.File).NormalizeDirectory($system.Util.ManagerDirectory()_"Temp/BulkFHIR/"_$namespace)} ];

}
