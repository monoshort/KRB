/// Base class for all fetch adapters. Subclasses must extend this class,
/// uniquely identify themselves, and implement the abstract methods.
/// Then they may be used for fetch tasks within a BFC.
Class HS.BulkFHIR.API.FetchAdapter Extends HS.BulkFHIR.API.AdapterBase
{

/// Flag which indicates whether the implementation of this
/// adapter supports patient export. If false, and a configuration
/// tries using this adapter with that operation requested,
/// will throw an error
Parameter supportsPatientExport As Boolean [ Abstract ];

/// Flag which indicates whether the implementation of this
/// adapter supports group export. If false, and a configuration
/// tries using this adapter with that operation requested,
/// will throw an error
Parameter supportsGroupExport As Boolean [ Abstract ];

/// Flag which indicates whether the implementation of this
/// adapter supports system export. If false, and a configuration
/// tries using this adapter with that operation requested,
/// will throw an error
Parameter supportsSystemExport As Boolean [ Abstract ];

/// (Optional overrideable)
/// Called when the BFC is first configured and again if that configuration
/// is changed, this method may be used to do any implementation-specific setup.
ClassMethod Initialize(pBFCconfig As HS.BulkFHIR.API.Data.Config)
{
}

/// Starts or resumes a $export operation. This overrrideable is expected to fetch resources
/// out of a clinical data repository in accordance with the provided $export operation, and 
/// add resources to a result set as FHIR using APIs in HS.BulkFHIR.ExportManager. The
/// implementation of this method should be able to handle receiving pause/cancel signals
/// from another process, and quiesce as soon as possible.
/// @Input pRequest		FHIR request object representing an export operation to be started
/// @Input pSession		HS.BulkFHIR.Session for the export operation 
/// @Returns a boolean flag indicating whether the operation was completed. This should only
/// 			be used to indicate whether the job was paused/cancelled. Any other reason to
/// 			stop processing should be thrown as a fatal error. 
/// @Throws any *fatal* error which prevents processing of the export operation. Non-fatal
/// 		errors should be included in the result set using the API in HS.BulkFHIR.ExportManager
ClassMethod Start(pRequest As HS.FHIRServer.API.Data.Request, pSession As HS.BulkFHIR.Session) As %Boolean [ Abstract ]
{
}

/// Pauses a $export operation that's currently in progress. This overrideable is expected to
/// signal the process working on the $export operation and quiesce it as soon as possible, with
/// the expectation that the job may be resumed in the future.
/// @Input sessionId	session id for the export operation to be paused
ClassMethod Pause(pSessionId As %String) [ Abstract ]
{
}

/// Cancels a $export operation that's currently in progress. This overrideable is expected to
/// signal the process working on the $export operation and quiesce it as soon as possible, with
/// the expectation that the job will not be resumed in the future.
/// @Input sessionId	session id for the export operation to be canceled
ClassMethod Cancel(pSessionId As %String) [ Abstract ]
{
}

/// Executes a FHIR search request (currently only Group resources). This overrideable is expected
/// to be able to process a FHIR search request against the underlying clinical data store,
/// and return a searchset Bundle of all matching resources.
/// @Input pConfig 		BulkFHIR configuration object
/// @Input request		FHIR request object representing a search
/// @Output response	FHIR response object containing the results of the search
ClassMethod Search(pConfig As HS.BulkFHIR.API.Data.Config, request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response) [ Abstract ]
{
}

/// Executes a FHIR read request (currently only Group resources). This overrideable is expected
/// to be able to process a FHIR read request against the underlying clinical data store,
/// and return a resource, if one exists
/// @Input pConfig 		BulkFHIR configuration object
/// @Input request		FHIR request object representing a read
/// @Output response	FHIR response object containing the results of the read
ClassMethod Read(pConfig As HS.BulkFHIR.API.Data.Config, request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response) [ Abstract ]
{
}

/// Provides an array of supported search parameters for the Group resource. This
/// overrideable will be used to construct the CapabilityStatement for the BFC.
/// @Input pConfig 		BulkFHIR configuration object
/// @Returns a %DynamicArray with a structure compatible with
/// 		the field CapabilityStatement.rest.resource.searchParam.
ClassMethod GroupSearchParameters(pConfig As HS.BulkFHIR.API.Data.Config) As %DynamicArray [ Abstract ]
{
}

/// (Optional overrideable)
/// Returns the status of an in-progress $export operation. This overrideable can be
/// used to modify the message returned to the client when they poll for status, as well as
/// inform them how long they should wait to ask again.
/// @Input sessionId	session id for the export operation being examined
/// @Output status		a short (<100 char) string to display in the X-Progress header
/// @Output retryAfter	how long to wait before polling again.
/// @Output json		a json object to be returned in the response body. not required per the spec for a progress request
ClassMethod Status(sessionId As %String, Output status As %String, Output retryAfter As %Integer, Output json As %DynamicObject)
{
	set status = "in-progress"
	set retryAfter = 120
	set json = ""
}

/// (Optional overrideable)
/// Returns a string in markdown syntax which will be displayed next to all supported operations
/// in the CapabilityStatement.
ClassMethod OperationDocumentation() As %String
{
	return ""
}

}
