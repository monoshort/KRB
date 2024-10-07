/// Stores files and makes them accessible through a REST API
Class HS.BulkFHIR.Storage.File.Adapter Extends HS.BulkFHIR.API.StorageAdapter
{

Parameter configClass = "HS.BulkFHIR.Storage.File.Config";

ClassMethod Initialize(pBFCconfig As HS.BulkFHIR.API.Data.Config)
{
	set storageConfig = $$$BFCStorageConfig(pBFCconfig)
	do ..CreateWebApp(storageConfig."file_url")
}

ClassMethod UsesAuthAdapter() As %Boolean [ CodeMode = expression ]
{
1
}

/// Moves contents from pInStream to permanent storage returns the URL where the file can be accessed.
/// The session for the export operation and the file's resource type are
/// also provided, as it may be useful or relevant for the storage strategy.
/// @Input pInStream		stream object containing a file to be saved.
/// @Input pSession			session object for the export operation the file is linked to
/// @Input pType			type of file - either a resource type or "error"
/// This method moves the ndjson from the Temp files into the permanent file during flush operations and at completion
ClassMethod SaveFile(ByRef pInStream As %Stream.Object, pSession As HS.BulkFHIR.Session, pType As %String)
{
	Set sessionId = pSession.sessionId
	#define filename(%counter) $E(10000+%counter,2,*)_".ndjson"
	Set config = pSession.configuration
	Set storageConfig = $$$BFCStorageConfig(config)
	Set path = ##class(%Library.File).NormalizeDirectory(storageConfig.directory_"/"_sessionId_"/"_pType_"/")
	If '$D($$$BFCFileCount(pSession, pType),counter) {
		Set counter = $i($$$BFCFileCount(pSession, pType))
		/// only need to create the chain for the first file
		$$$ThrowOnError( ##class(%Library.File).CreateDirectoryChain(path) )
	}
	Set filename = $$$filename(counter)
	Set stream = ..GetStream(path_filename)
	Set url = "<server_base>"_storageConfig."file_url" _ "/"_ sessionId_"_"_pType_"_"_filename

	Set counterURL = pType_"_"_filename

	While 'pInStream.AtEnd {
		// if resource is longer than a maxstring we'll need to move it to a stream to collect it
		Set str = $$$NULLOREF
		Set value = pInStream.ReadLine($$$MaxStringLength,.sc,.eol)
		$$$ThrowOnError(sc)
		If (value="") && pInStream.AtEnd {
			Quit
		}
		If 'eol {
			Set tmpStream = ##class(%Stream.TmpCharacter).%New()
			Do tmpStream.Write(value)
			For {
				Set value = pInStream.ReadLine($$$MaxStringLength,.sc,.eol)
				$$$ThrowOnError(sc)
				Do tmpStream.Write(value)
				If eol { Quit }
			} 
		}
		If ($Select($Isobject($Get(tmpStream)):tmpStream.Size,1:$l(value)) + stream.Size + 1) > config."max_file_size" {
			Set event = {
				"severity": ($$$LogLevelInfo),
				"sessionId": (sessionId),
				"component": "storage",
				"type": "flush",
				"flush_type": (pType),
				"reason": "size",
				"size": (stream.Size)
			}
			Set sc = stream.%Save()
			If $$$ISERR(sc) {
				Set event.severity = $$$LogLevelError
				Set event.reason = $$$FormatText($$$Text("Failed to save file: %1","HSBFCErr"),$system.Status.GetErrorText(sc))
			}
			do ##class(HS.BulkFHIR.Log).Log(event)
			$$$ThrowOnError(sc)
			Set $$$BFCFileSize(pSession,counterURL)=stream.Size
			Set counter = $i($$$BFCFileCount(pSession, pType))
			Set filename = $$$filename(counter)
			Set stream = ..GetStream(path_filename)
			Set counterURL = pType_"_"_filename
		}
		If $IsObject(str) {
			Do str.Rewind()
			While 'str.AtEnd {
				Do stream.Write(str.Read())
			}
			Do stream.Write($c(10))
		} Else {
			Do stream.Write(value_$c(10))
		}
		Do $i($$$BFCFileRecordCount(pSession,counterURL))
		Set obj = {}.%FromJSON($S($IsObject(str):str,1:value))
	}
	$$$ThrowOnError(stream.%Save())
	Set $$$BFCFileSize(pSession,counterURL)=stream.Size
	Do pInStream.Clear() 
	Do ##class(%Library.File).Delete(pInStream.Filename)
	Set pInStream=""
	return
}

/// @BFC_Internal
/// @Input pFilename 	filename
/// @Return file character stream for given filename, create if it doesn't exist
ClassMethod GetStream(pFilename As %String) As %Stream.FileCharacter [ Internal ]
{
	Set stream = ##class(%Stream.FileCharacter).%OpenId(pFilename)
	If $IsObject(stream) {
		Do stream.MoveToEnd()
	} Else {
		Set stream = ##class(%Stream.FileCharacter).%New()
		$$$ThrowOnError(stream.LinkToFile(pFilename))
	}
	return stream
}

/// @BFC_Internal
/// return normalized path breaking out type and filename
ClassMethod GetPath(pDirectory As %String, pFilename As %String) As %String [ CodeMode = expression, Internal ]
{
##class(%Library.File).NormalizeDirectory(pDirectory_"/"_$p(pFilename,"_")_"/"_$p(pFilename,"_",2))
}

/// @BFC_Internal
/// Given pURL delete the file
ClassMethod DeleteFile(pURL As %String)
{
	Set file = $p(pURL,"/",*)
	Set sessionId = ..SessionIdForFilename(file)
	Set session = ##class(HS.BulkFHIR.Session).getBySessionId(sessionId) 
	Set storageConfig = $$$BFCStorageConfig(session.configuration)
	Set directory = ..GetPath(storageConfig.directory,file)
	Set fileToDelete = directory_$p(file,"_",3,*)
	If '##class(%Library.File).Delete(fileToDelete) {
		$$$ThrowFHIR($$$HSBFCErrUnableToDeleteFile, fileToDelete)
	}
}

/// @BFC_Internal
/// Given pFilename return the stream
ClassMethod GetFileInternal(pSession As HS.BulkFHIR.Session, pFilename As %String) As %Stream.Object [ Internal ]
{
	Set storageConfig = $$$BFCStorageConfig(pSession.configuration)
	Set file = ##class(%Library.File).NormalizeFilename(storageConfig.directory_"/"_$tr(pFilename,"_","/"))
	Set stream = ##class(%Stream.FileCharacter).%New()
	Do stream.LinkToFile(file)
	return stream
}

/// @BFC_Internal
ClassMethod PurgeSession(pSession As HS.BulkFHIR.Session) As %Boolean [ Internal ]
{
	Set storageConfig = $$$BFCStorageConfig(pSession.configuration)
	Set sessionId = pSession.sessionId
	Set tree = ##class(%Library.File).NormalizeDirectory(storageConfig.directory_"/"_sessionId)
	If '##class(%Library.File).DirectoryExists(tree) {
		Return 1
	}
	Set success = ##class(%Library.File).RemoveDirectoryTree(tree)
	Return success
}

/// @BFC_Internal
/// Called by RestHandler
ClassMethod SessionIdForFilename(filename As %String) As %String [ CodeMode = expression, Internal ]
{
$piece(filename, "_", 1)
}

ClassMethod CreateWebApp(url As %String) [ Internal ]
{
	set tProps("Name") = url
	set tProps("NameSpace") = $namespace
	set tProps("DispatchClass") = "HS.BulkFHIR.Storage.File.RestHandler" 
	set tProps("AutheEnabled") = $$$AutheUnauthenticated + $$$AutheCache //Authentication is delegated to the auth adapter
	set tProps("Description") = "Bulk FHIR endpoint"
	Set hsRoleName = ##class(HS.HC.SystemConfig.Utils).GetHSRoleName($namespace)
	Set tMatchRoles = ":"_hsRoleName_":%DB_HSCUSTOM:%DB_HSLIB:%DB_HSSYS:%DB_IRISSYS:%HS_ImpersonateUser"
	Set tProps("MatchRoles") = tMatchRoles
	
	set tProps("Timeout") = 900
	set tProps("InbndWebServicesEnabled") = 0
	set tProps("AutoCompile") = 0
	set tProps("IsNameSpaceDefault") = 0
	set tProps("UseCookies") = 0
	set tProps("DeepSeeEnabled") = 0
	set tProps("GroupById") = ""
	set tProps("CookiePath") = ""
	set tProps("CSPZENEnabled") = 1
	Do ##class(HS.HC.SystemConfig.API).UpdateWebApplication($namespace,url,$$$NVPairToList(tProps),.tFound)
	If ('tFound) {
		Do ##class(HS.HC.SystemConfig.API).CreateWebApplication($namespace,url,$$$NVPairToList(tProps))
	}
}

}
