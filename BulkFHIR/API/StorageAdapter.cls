/// Base class for all storage adapters. Subclasses must extend this class,
/// uniquely identify themselves, and implement the abstract methods.
/// Then they may be used for storage tasks within a BFC.
Class HS.BulkFHIR.API.StorageAdapter Extends (HS.BulkFHIR.API.AdapterBase, HS.BulkFHIR.Util.Security)
{

/// (Optional overrideable)
/// Called when the BFC is first configured and again if that configuration
/// is changed, this method may be used to do any implementation-specific setup.
ClassMethod Initialize(pBFCconfig As HS.BulkFHIR.API.Data.Config)
{
}

/// Moves contents from pInStream to permanent storage returns the URL where the file can be accessed.
/// The session for the export operation and the file's resource type are
/// also provided, as it may be useful or relevant for the storage strategy.
/// @Input pInStream		stream object containing a file to be saved.
/// @Input pSession			session object for the export operation the file is linked to
/// @Input pType			type of file - either a resource type or "error"
/// This method moves the ndjson from the Temp files into the permanent file during flush operations and at completion
ClassMethod SaveFile(ByRef pInStream As %Stream.Object, pSession As HS.BulkFHIR.Session, pType As %String) [ Abstract ]
{
}

/// @Input pSession			session object for the export operation the file is linked to
/// @Input pFilename		filename to generate URL for 
ClassMethod GetFile(pSession As HS.BulkFHIR.Session, pFilename As %String) As %Stream.Object [ Final ]
{
	Do ..CheckResources(pSession)
	Set stream = ..GetFileInternal(pSession,pFilename)
	Set event = {
		"severity": ($$$LogLevelInfo),
		"sessionId": (pSession.sessionId),
		"component": "storage",
		"type": "file_access",
		"client": (%bfcRESTSecurity.Username),
		"file": (pFilename)
	}
	If 'stream.Size {
		Set event.severity = $$$LogLevelWarning
		Set event.reason = $$$Text("File is empty","HSBFCErr")
	}
	Do ##class(HS.BulkFHIR.Log).Log(event)
	Quit stream
}

/// Called by GetFile, to be able to download any file first check the resources
/// @Input pSession			session object the export operation is linked to
/// @Input pFilename		filename we are checking resources on
ClassMethod CheckResources(pSession As HS.BulkFHIR.Session) [ Final ]
{
	Do ..ResourceCheck($lb("%HS_BFC_Export_Download","U"),pSession,$lb("%HS_BFC_Download_Manage","U"))
}

/// After checking resources call the GetFileInternal in the adapter class
/// @Input pSession			session object for the export operation the file is linked to
/// @Input pFilename		filename to generate URL for 
ClassMethod GetFileInternal(pSession As HS.BulkFHIR.Session, pFilename As %String) As %Stream.Object [ Abstract ]
{
}

/// @Input pStorageConfig	The Storage File Adapter configuration
/// @Input pSession			session object for the export operation the file is linked to
/// @Input pType			type of file - either a resource type or "error"
/// @Input pFilename		filename to generate URL for 
/// Returns the URL for this file <server_base>fileurl/sessionid/type/filename.ndjson
ClassMethod GetURL(pStorageConfig As HS.BulkFHIR.Storage.File.Config, pSession As HS.BulkFHIR.Session, pType As %String, pFilename As %String) As %String [ CodeMode = expression ]
{
"<server_base>"_pStorageConfig."file_url" _ "/"_ pSession.sessionId_"_"_pType_"_"_pFilename
}

/// Indicates whether the files created by this adapter will be
/// access controlled *directly* by the auth adapter. If the files
/// are not access controlled, or the auth adapter isn't controlling
/// access from the client's perspective (ie. AWS S3), this should be false.
/// @Returns a boolean representing whether the auth adapter will be used for access control
ClassMethod UsesAuthAdapter() As %Boolean [ Abstract ]
{
}

/// (Optional overrideable)
/// Deletes a file that was saved previously, either because the operation failed or because the file
/// is expired
/// @Input url	url of the file that was saved previously and shall be deleted
ClassMethod DeleteFile(url As %String)
{
	return
}

/// (Optional overrideable)
/// If the StorageAdapter can purge everything with just the sessionId implement that code and return 1
/// A return of 0 will call DeleteFile with every file in links and errors
/// @Input pSessionId	sessionId to be purged
ClassMethod PurgeSession(pSession As HS.BulkFHIR.Session) As %Boolean
{
	Return 0
}

}
