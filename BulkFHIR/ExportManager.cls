Include HS.BulkFHIR

Class HS.BulkFHIR.ExportManager Extends HS.BulkFHIR.Util
{

Parameter errorType = "error";

/// @API
/// API for a fetch adapter to add a resource to the result set for
/// a specified session
/// @Input pSession		Session object of the session being processed
/// @Input rsrc			FHIR resource to add to the operation's result set
/// @Input query		(optional) the fetch adapter may specify this resource
/// 					was added from a specific query. This must be provided if
/// 					the adapter wants to take advantage of the IsQueryComplete
/// 					API in this class.
ClassMethod AddResource(pSession As HS.BulkFHIR.Session, rsrc As %DynamicObject, query As %String = "")
{
	if '$isobject(rsrc) || (rsrc.resourceType = "") {
		$$$ThrowFHIR($$$HSBFCErrInvalidAddResource)
	}
		
	if '..CheckFilters(pSession, rsrc) {
		return
	}
	
	do ..AddEntry(pSession, rsrc.resourceType, rsrc, query)
}

/// Evaluate the resource content against any of a number of filters
/// that are persisted on the session object.
ClassMethod CheckFilters(session As HS.BulkFHIR.Session, rsrc As %DynamicObject) As %Boolean
{
	set sinceSeconds = session.sinceSeconds
	
	// Currently the only implemented filter here is _since. If no _since
	// was specified on the $export, then return 1 (passes the filter).
	if sinceSeconds '> 0 {
		return 1
	}
	
	set rsrcMeta = rsrc.meta
	
	// Currently the only implemented filters here depend on data found in
	// the resource meta. If no meta, then return 1 (passes the filter).
	if rsrcMeta = "" {
		return 1
	}
	
	set lastUpdatedInstant = rsrcMeta.lastUpdated
	
	if lastUpdatedInstant '= "" {
		set lastUpdatedSeconds = ..ConvertInstantToUTCSecs(lastUpdatedInstant)
		if lastUpdatedSeconds '> sinceSeconds {
			return 0
		}
	}
	
	return 1
}

/// @API
/// API for a fetch adapter to add an error/warning to the result set for
/// a specified session. This will not trigger a fatal error and termination,
/// it will make the error available for the client to see along with the
/// successfully added resources.
/// @Input pSession		the session being processed
/// @Input error		FHIR OperationOutcome error to add to the operation's
/// 					error result set
/// @Input query		(optional) the fetch adapter may specify this error
/// 					was added from a specific query. This must be provided if
/// 					the adapter wants to take advantage of the IsQueryComplete
/// 					API in this class.
ClassMethod AddError(pSession As HS.BulkFHIR.Session, error As %DynamicObject, query As %String = "")
{
	if '$isobject(error) || (error.resourceType = "") {
		$$$ThrowFHIR($$$HSBFCErrInvalidAddResource)
	}
	do ..AddEntry(pSession, ..#errorType, error, query)
}

/// @API
/// API to check whether a resource has been successfully added. The
/// ExportManager buffers resources before delivering them to the storage
/// adapter, so fetch adapters should make use of this method rather than
/// doing their own bookkeeping. This will prevent resources from being
/// lost if the system goes down during an operation.
/// @Output pLockManager take out a lock on the resource to ensure only a single process is adding it
/// @Input pSession		session being processed
/// @Input pType		Resource type being looked up
/// @Input pID			id of the resource being looked up
ClassMethod IsResourceAdded(Output pLockManager As %ZHSLIB.LockManager, pSession As HS.BulkFHIR.Session, pType As %String, pID As %String) As %Boolean
{
	Set pLockManager = ##class(%ZHSLIB.LockManager).%New()
	$$$ThrowOnError(pLockManager.Lock($name($$$BFCPersistedKey(pSession, pType, pID)),, 60)) //Expect lock to be available in <1s.
	Set added = ($data($$$BFCPersistedKey(pSession, pType, pID)) > 0)
	If added {
		// don't hold a lock when complete
		Kill pLockManager
	}
	Quit added
}

/// @API
/// API for the fetch adapter to register a query as complete. Once
/// a query is complete, the IsQueryComplete API will return true. The
/// fetch adapter can use that to determine whether it needs to re-run
/// a query if the job is paused and restarted.
/// @Input pSession		the session being processed
/// @Input pQuery		The query string to be marked as complete.
ClassMethod CompleteQuery(pSession As HS.BulkFHIR.Session, pQuery As %String)
{
	set $$$BFCPersistedQueryComplete(pSession, pQuery) = 1
}

/// @API
/// API for the fetch adapter to check whether a query has been completed.
/// The ExportManager buffers resources before delivering them to the storage
/// adapter, so fetch adapters should make use of this method rather than
/// doing their own bookkeeping. This will prevent queries from being
/// re-run if the system goes down during an operation.
/// @Output pLockManager take out a lock on the queryPath to ensure another process is not adding it
/// @Input pSession		the session being processed
/// @Input pQuery		The query string which may or may not be complete
ClassMethod IsQueryComplete(Output pLockManager As %ZHSLIB.LockManager, pSession As HS.BulkFHIR.Session, pQuery As %String) As %Boolean
{
	Set pLockManager = ##class(%ZHSLIB.LockManager).%New()
	$$$ThrowOnError(pLockManager.Lock($name($$$BFCPersistedQueryComplete(pSession, pQuery)),, 60)) //Expect lock to be available in <1s.
	Set complete = $get($$$BFCPersistedQueryComplete(pSession, pQuery), 0)
	If complete {
		// don't hold a lock when complete
		Kill pLockManager
	}
	Quit complete
}

ClassMethod AddEntry(pSession As HS.BulkFHIR.Session, type As %Global, content As %DynamicObject, query As %String) [ Internal, Private ]
{
	//As we're adding resources, periodically call FlushTask to determine whether *any*
	//resource types should be flushed based on how long they've been in the buffer.
	if '$data($$$BFCBufferLastScanTime(pSession)) || ($system.SQL.Functions.DATEDIFF("second", $$$BFCBufferLastScanTime(pSession), $zdt($zts, 3)) >= 60) {
		do ..FlushTask(pSession, 1)
		set $$$BFCBufferLastScanTime(pSession) = $zdt($zts, 3)
	}
	
	set tempStream = ##class(%Stream.TmpCharacter).%New()
	do content.%ToJSON(.tempStream)
	
	Set config = pSession.configuration
	set stream = ..GetStream(pSession,type)
	if (stream.Size + tempStream.Size + 1) > config."max_file_size" {
		do ##class(HS.BulkFHIR.Log).Log({
			"severity": ($$$LogLevelInfo),
			"sessionId": (pSession.%Id()),
			"component": "bfc",
			"type": "flush",
			"flush_type": (type),
			"reason": "size",
			"size": (stream.Size)
		})
		do ..Flush(pSession, type, .stream)
	}
	
	while 'tempStream.AtEnd {
		$$$ThrowOnError(stream.Write(tempStream.Read()))
	}
	Do stream.Write($c(10))	
	$$$ThrowOnError(stream.%Save())
	//Register this key as in the buffer
	if content.id '= "" {
		set $$$BFCPersistedKey(pSession, type, content.id) = ""
	}
	
	//Ensure a time by which the buffer will be forced to flush, regardless of its size
	if '$data($$$BFCBufferStartTime(pSession, type)) {
		set $$$BFCBufferStartTime(pSession, type) = $zdt($zts, 3)
	}
	/// track the buffered file.  
	Set $$$BFCBuffer(pSession, type)=""
}

/// @BFC_Internal
/// Ensures all resources and errors are flushed to the storage adapter
/// once fetching is complete
ClassMethod FlushSession(pSession As HS.BulkFHIR.Session) [ Internal ]
{
	do ..FlushTask(pSession, 0)
}

/// @BFC_Internal
/// Does all necessary cleanup on a session once processing is
/// complete
ClassMethod FinalizeSession(pSession As HS.BulkFHIR.Session) [ Internal ]
{
	kill $$$BFCTempGbl($namespace,pSession.%Id())
}

/// @BFC_Internal
/// Iterate through BFCFileRecordCount for session and update the links counts
/// @Input pSession			session to be inspected
ClassMethod UpdateFileCounts(pSession As HS.BulkFHIR.Session) [ Internal ]
{
	set config = pSession.configuration
	/// update the links table which will provide the file links for the status call
	Set typeAndFilename = ""
	For {
		Set typeAndFilename = $O($$$BFCFileRecordCount(pSession,typeAndFilename),1,count)
		If typeAndFilename = "" { Quit }
		Set type = $p(typeAndFilename,"_")
		Set filename = $p(typeAndFilename,"_",2,*)
		Set url = $CLASSMETHOD($$$BFCStorageClass(config),"GetURL",$$$BFCStorageConfig(config),pSession,type,filename)
		Set size = $g($$$BFCFileSize(pSession,typeAndFilename))
		if type = ..#errorType {
			Do ##class(HS.BulkFHIR.Session.Link).Add(pSession,..#errorType,count,size,url)
		}
		else {
			Do ##class(HS.BulkFHIR.Session.Link).Add(pSession,type,count,size,url)
		}
	}
}

/// Iterates through all buffers. Will either flush all of them, or
/// will only flush buffers that have been active for longer than
/// the configured buffer lifetype.
/// @Input pSession				session object to be inspected
/// @Input onlyPeriodicFlush	If true, will only flush buffers that have been
/// 							around longer than the configured lifetime. If
/// 							false, will flush all buffers
ClassMethod FlushTask(pSession As HS.BulkFHIR.Session, onlyPeriodicFlush As %Boolean) [ Internal ]
{
	set config = pSession.configuration
	set flushReason = $select(onlyPeriodicFlush:"flush_interval_exceeded", 1:"finalize_session")
	
	set type = ""
	for {
		set type = $order($$$BFCBuffer(pSession, type))
		quit:(type = "")
		
		if onlyPeriodicFlush {
			if $system.SQL.Functions.DATEDIFF("minute", $$$BFCBufferStartTime(pSession, type), $zdt($zts, 3)) < config."flush_interval_mins" {
				continue
			}
		}
		
		
		set stream = ..GetStream(pSession,type)
		Set size = stream.Size
		if size = 0 continue
		do ..Flush(pSession, type, .stream)
		do ##class(HS.BulkFHIR.Log).Log({
			"severity": ($$$LogLevelInfo),
			"sessionId": (pSession.%Id()),
			"component": "bfc",
			"type": "flush",
			"flush_type": (type),
			"reason": (flushReason),
			"size": (size)
		})
		kill stream
	}
}

/// @BFC_Internal
/// Flush a single file (resource type)
ClassMethod Flush(pSession As HS.BulkFHIR.Session, pType As %String, ByRef pStream As %Stream.GlobalCharacter) [ Internal, Private ]
{
	set fileSize = pStream.Size
	Set config = pSession.configuration
	//Ensure no other process tries writing to this resource type's buffer while
	//we're flushing it
	set lockManager = ##class(%ZHSLIB.LockManager).%New()
	$$$ThrowOnError(lockManager.Lock($name($$$BFCFileLock(pSession,pType)),, 90)) //Wait for any other jobs to flush
	Do $classmethod($$$BFCStorageClass(config), "SaveFile", .pStream, pSession, pType)

	//Kill global (including count and buffer), then re-initialize stream. Calling
	kill $$$BFCBuffer(pSession, pType)
	kill $$$BFCBufferStartTime(pSession, pType)
	set pStream = ..GetStream(pSession,pType)
}

/// @BFC_Internal
/// Called by system startup move any files from temp into permanent storage
/// Check files to ensure that items have been marked as persisted (we save the item then mark it)
ClassMethod CleanupSession(pSession As HS.BulkFHIR.Session) [ Internal ]
{
	Set config = pSession.configuration
	Set storageConfig = $$$BFCStorageConfig(config)
	Set path = ##class(%Library.File).NormalizeDirectory(storageConfig.directory_"/"_pSession.%Id()_"/")
	Do ..GetFiles(path,.array)
	For idx = 1:1:$g(array) {
		Set filename = array(idx)
		Set stream = ##class(%Stream.FileCharacter).%OpenId(filename)
		Set type = $p(filename,"_",*)
		Do ..PersistIDs(pSession,type,stream)
		do ..Flush(pSession, type, .stream)
		kill stream
	}
	/// remove any stream files that may have been left from the interrupt
	Do ..GetFiles(path,.array,"*.stream")
	For idx = 1:1:$g(array) {
		Do ##class(%Library.File).Delete(array(idx))
	}
}

/// @BFC_Internal
/// When restarting sessions walk each job file to ensure everything was marked as persisted
/// It's unlikely but a file could be incomplete on the last line, in that case drop the last line from the file
/// which will be fine because we write the file, then we update the $$$PersistedKey
ClassMethod PersistIDs(pSession As HS.BulkFHIR.Session, pType As %String, pStream As %Stream.FileCharacter) [ Internal ]
{
	If $zcvt(pType,"l")="error" {
		Quit
	}
	try {
		Do pStream.Rewind()
		Set allGood = 1
		TSTART
		For idx =1:1 {
			If pStream.AtEnd { Quit }
			Do ..GetStreamLine(pStream,.line,.tempStream)
			try {
				Set obj = {}.%FromJSON($S($IsObject(tempStream):tempStream,1:line))
				Set $$$BFCPersistedKey(pSession,pType,obj.id)=""
			} catch ex {
				// if the object isn't valid we might be suffering from an incomplete write during a system crash
				Set allGood = 0
			}
			Quit:'allGood
		}
		Do pStream.Rewind()
		If 'allGood {
			Set stream = ##class(%Stream.TmpCharacter).%New()
			// we had a problem so drop everything after that
			For idx2 = 1:1:(idx-1) {
				Do ..GetStreamLine(pStream,.line,.tempStream)
				Set obj = {}.%FromJSON($S($IsObject(tempStream):tempStream,1:line))
				Do stream.WriteLine(obj.%ToJSON())
			}
			Do stream.Rewind()
			Do pStream.CopyFrom(stream)
			$$$ThrowOnError(pStream.%Save())
			Do pStream.Rewind()
			Do stream.Clear()
		}
		TCOMMIT
	} catch ex {
		TROLLBACK
		Throw ex
	}
}

/// @BFC_Internal
/// using the ndjson file get the object into either pLine or pTempStream (depending on size)
ClassMethod GetStreamLine(pStream As %Stream.FileCharacter, Output pLine As %String, Output pTempStream As %Stream.TmpCharacter)
{
	Set pLine=""
	Set pTempStream=""
	For idxx=1:1 {
		/// a single line could take multiple reads if it's longer than 3000K
		Set pLine = pStream.ReadLine($$$MaxStringLength,.sc,.eol)
		$$$ThrowOnError(sc)
		If $IsObject(pTempStream) {
			Do pTempStream.Write(pLine)
			Quit:pStream.AtEnd
			continue:'eol
		}
		Quit:eol||pStream.AtEnd
		Set pTempStream = ##class(%Stream.TmpCharacter).%New()
		Do pTempStream.Write(pLine)
		Set pLine=""
	}
}

/// @BFC_Internal
/// Used to locate files from jobs which were running during a crash or shutdown so that they can be moved to 
/// permanent storage
ClassMethod GetFiles(pDirectory, Output pArray, pWildcard = "Job_*") [ Internal ]
{
	// On a session start we call cleanup, but when job first starts the directory doesn't exist yet
	If '##class(%File).DirectoryExists(pDirectory) {
		Quit 
	}
	Set stmt = ##class(%SQL.Statement).%New()
	Set status = stmt.%PrepareClassQuery("%File", "FileSet")
	$$$ThrowOnError(status)
	Set rs = stmt.%Execute(##class(%File).NormalizeDirectory(pDirectory), pWildcard)
	If rs.%SQLCODE {
		$$$ThrowOnError($$$ERROR($$$SQLError, rs.%SQLCODE, rs.%Message))
	}
	While rs.%Next() {
		Set pArray($i(pArray))=rs.CurrentResult.Name
	}
}

/// @BFC_Internal
/// Using specified working_directory get existing or new buffer file for type (for this job)
ClassMethod GetStream(pSession As HS.BulkFHIR.Session, pType As %String) As %Stream.FileCharacter
{
	Set config = pSession.configuration
	Set filename = ##class(%Library.File).NormalizeFilename(config."working_directory"_"/"_pSession.%Id()_"/Job_"_$j_"_"_pType)
	Set stream = ##class(%Stream.FileCharacter).%OpenId(filename)
	Do stream.MoveToEnd()
	return stream
}

}
