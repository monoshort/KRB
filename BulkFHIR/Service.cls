Include HS.BulkFHIR

Class HS.BulkFHIR.Service Extends (HS.BulkFHIR.Util, HS.BulkFHIR.Util.Security)
{

/// @API
/// Processes a request for status on an export operation. If the operation is complete, will
/// show the result. Otherwise, delegates to the fetch adapter for displaying the current status.
/// @Input pSessionId 	BFC Session id to fetch status for
/// @Input pBaseUrl		URL to be included in session json output
/// @Output pStatus		a short (<100 char) string to display in the X-Progress header
/// @Output pRetryAfter	how long to wait before polling again.
/// @Output pExpires 	when the session expires and available for cleanup
/// @Output pJson		a json object to be returned in the response body. not required per the spec for a progress request
ClassMethod Status(pSessionId As %String, pBaseUrl As %String, Output pStatus As %String, Output pRetryAfter As %Integer, Output pExpires As %TimeStamp, Output pJson As %DynamicObject, Output pHttpStatus As %Integer)
{
	Set %bfcRESTSecurity=$G(%bfcRESTSecurity,##class(HS.FHIRServer.API.Data.Request).%New())
	#dim session As HS.BulkFHIR.Session = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId)
	Do ..ResourceCheck($lb("%HS_BFC_Export_Status","READ"),session,$lb("%HS_BFC_Export_Manage","USE"))
	Set config = session.configuration
	set pStatus = "", pRetryAfter = "", pJson = "", pExpires = ""
	if session.status = "complete" {
		set pHttpStatus = 200
		set pJson = session.ToJsonOutput(pBaseUrl)
		set pExpires = ##class(%CSP.StreamServer).ToHTTPDate($zdth(session.expiresTime, 3, 7))
	}
	elseif session.status = "terminated" {
		set pHttpStatus = 500
		set pJson = ##class(HS.FHIRServer.Util.Outcome).CreateFromStatus(session.terminatedReason)
	}
	else {
		set pHttpStatus = 202
		do $classmethod($$$BFCFetchClass(config), "Status", pSessionId, .pStatus, .pRetryAfter, .pJson)
	}
}

/// @API
/// Pauses a $export operation that's currently in progress. This operation may be resumed
/// by calling the Resume method.
/// @Throws if the session is already complete
ClassMethod Pause(pSessionId As %String)
{
	Set %bfcRESTSecurity=$G(%bfcRESTSecurity,##class(HS.FHIRServer.API.Data.Request).%New())
	#dim session As HS.BulkFHIR.Session = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId)
	Do ..ResourceCheck($lb("%HS_BFC_Export_Status","WRITE"),session,$lb("%HS_BFC_Export_Manage","USE"))
	do session.Pause()
	Set config = session.configuration
	do $classmethod($$$BFCFetchClass(config), "Pause", pSessionId)
	do ##class(HS.BulkFHIR.Log).Log({
		"severity": ($$$LogLevelInfo),
		"sessionId": (pSessionId),
		"component": "bfc",
		"type": "session_action",
		"action": "pause"
	})
}

ClassMethod Errored(pSessionId As %String, pReason As %String) [ Internal, Private ]
{
	#dim session As HS.BulkFHIR.Session = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId)
	set session.status = "error"
	Set sc = session.SafeSave()
	If $$$ISERR(sc) {
		do ##class(HS.BulkFHIR.Log).Log({
			"severity": ($$$LogLevelError),
			"sessionId": (pSessionId),
			"component": "bfc",
			"type": "update_session",
			"reason": ($system.Status.GetErrorText(sc)),
			"action": "failure"
		})
		$$$ThrowStatus(sc)
	}
}

/// @API
/// Cancels a $export operation that's currently in progress. This operation may not be
/// resumed after being canceled.
/// @Throws if the session is already complete
ClassMethod Cancel(pSessionId As %String)
{
	Set %bfcRESTSecurity=$G(%bfcRESTSecurity,##class(HS.FHIRServer.API.Data.Request).%New())
	Set session = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId) //Ensure session exists before calling EndSession
	Do ..ResourceCheck($lb("%HS_BFC_Export_Status","WRITE"),session,$lb("%HS_BFC_Export_Manage","USE"))
	do ..EndSession(session,$$$ERROR($$$HSBFCErrOperationTerminated, pSessionId, $$$OutcomeIs(500, "error", "deleted")))
	do ##class(HS.BulkFHIR.Log).Log({
		"severity": ($$$LogLevelInfo),
		"sessionId": (pSessionId),
		"component": "bfc",
		"type": "session_action",
		"action": "cancel"
	})
}

/// @BFC_Internal
/// Internal API to end a session before it completes processing. A %Status must be
/// provided to explain why the session is being cancelled, which can either be a
/// fatal error encountered during processing or an error message indicating the
/// operation was manually terminated.
ClassMethod EndSession(pSession As HS.BulkFHIR.Session, status As %Status) [ Internal, Private ]
{
	Set sessionId = pSession.%Id()
	Set config = pSession.configuration
	Do $classmethod($$$BFCFetchClass(config), "Cancel", sessionId)
	/// wait for job to stop
	Lock +$$$BFCSessionJob(pSession)#"S"
	For idx=1:1:20 {
		Set pid=$G($$$BFCSessionJob(pSession))
		If '$D(^$JOB(pid)) { Quit }
		Hang 1
	}
	Lock -$$$BFCSessionJob(pSession)#"S"
	/// ****TODO: what should we do if the session didn't stop?
	Do pSession.Terminate(status,config."expire_after_mins")
	Set tree = ##class(%Library.File).NormalizeDirectory(config."working_directory"_"/"_sessionId)
	Set success = ##class(%Library.File).RemoveDirectoryTree(tree)
	/// mark session as purged and cleanup storage files
	Do ..Purge(pSession,0)
	/// cleanup any temp globals
	do ##class(HS.BulkFHIR.ExportManager).FinalizeSession(pSession)
}

/// @BFC_Internal
/// Purges all files associated with a session. A successful session is expected to be
/// purged after its expiration time has passed. A session may also be purged
/// if it was unsuccessful (either encountered an error or was manually cancelled)
ClassMethod Purge(pSession As HS.BulkFHIR.Session, pMarkPurged As %Boolean = 1) [ Internal ]
{
	Set sessionId = pSession.%Id()
	do ##class(HS.BulkFHIR.Log).Log({
		"severity": ($$$LogLevelInfo),
		"sessionId": (sessionId),
		"component": "bfc",
		"type": "session_action",
		"action": "purge"
	})
	Set config = pSession.configuration
	/// If PurgeSession is implemented there is no need to purge individual items, otherwise delete items individually
	If '$classmethod($$$BFCStorageClass(config), "PurgeSession", pSession) {
		&SQL(DECLARE curLinks CURSOR for SELECT url into :url from HS_BulkFHIR_session.Link where Session = :sessionId And Session->Purged=0)
		&sql(OPEN curLinks)
		If SQLCODE {
			$$$ThrowOnError($$$ERROR($$$SQLError,SQLCODE,%msg))
		}
		For {
			&sql(FETCH curLinks)
			QUIT:SQLCODE
			do $classmethod($$$BFCStorageClass(config), "DeleteFile", url)
		}
		&SQL(CLOSE curLinks)

	}
	
	If pMarkPurged {
		set pSession.purged = 1
		
		$$$ThrowOnError(pSession.SafeSave())
	}
	// remove persisted session data
	kill $$$BFCPersistedGbl(pSession.%Id())
}

/// @API
/// Resumes a $export operation that was paused (will spawn background task).
/// @Throws if the session is already complete or if it's already been resumed, or the job fails to start
ClassMethod Resume(sessionId As %String)
{
	Set %bfcRESTSecurity=$G(%bfcRESTSecurity,##class(HS.FHIRServer.API.Data.Request).%New())
	#dim session As HS.BulkFHIR.Session = ##class(HS.BulkFHIR.Session).getBySessionId(sessionId)
	Do ..ResourceCheck($lb("%HS_BFC_Export_Status","WRITE"),session,$lb("%HS_BFC_Export_Manage","USE"))
	Do ..DoSessionStart(session,"resume")
}

/// @API
/// Processes a FHIR interaction request ($export, group search, metadata). In the event the request is an
/// $export kickoff, will start a background job to process it.
ClassMethod ProcessFHIRRequest(request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response)
{
	#dim config as HS.BulkFHIR.API.Data.Config = ##class(HS.BulkFHIR.Configuration).GetConfiguration( request.SessionApplication )
	set handler = ..ParseRequest(.request)
	if handler = "" {
		set response.Status = 404
		return
	}
	
	if (request.RequestPath '= "metadata") && ($Piece(request.RequestPath, "/", *-1) '= ".well-known") {
		// config may contain settings that are relevant to the FHIR request
		// authorization, such as the OAuth client name for the BFC endpoint.
		do $classmethod($$$BFCAuthClass(config), "AuthorizeFHIRRequest", request, config)
	}

	// If an access token is present on the request, get the access token properties
	// that we are comfortable with persisting and passing around, and put them into
	// the request AdditionalInfo.
	set bfcTokenString =  request.AdditionalInfo.GetAt("USER:OAuthToken")
	if bfcTokenString '= "" {
		set bfcTokenInfo = $ClassMethod(config."auth_adapter", "GetAccessTokenInfo", config, bfcTokenString)
		do request.AdditionalInfo.SetAt(bfcTokenInfo.%ToJSON(), "USER:BFCTokenInfo")
	}
	
	do $classmethod($this, handler, request, .response)
	return
}

ClassMethod Operation(request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response) [ Internal ]
{
	// First check if user is permitted to make this type of export
	Set type = $CASE( $p($zcvt(request.RequestPath,"l"),"$export"),"":"System",:$p(request.RequestPath,"/"))
	Do ..ResourceCheck($lb("%HS_BFC_Export_"_type,"USE"))
		
	set session = ##class(HS.BulkFHIR.Session).%New()
	set session.requestUrl = request.BaseURL _ "/" _ request.RequestPath _ $select(request.QueryString '= "":"?" _ request.QueryString, 1:"")
	set session.client = request.Username
	set sinceInstant = request.Parameters.GetParameterValue("_since")
	if sinceInstant '= "" {
		// ParseRequest / CreateQueryString already verified valid FHIR instant.
		set session.sinceSeconds = ..ConvertInstantToUTCSecs(sinceInstant)
	}
	set request.Parameters = "" //Having Parameters set when calling %Save throws a %GetSerial error
	set session.request = request
	/// fetch dynamic object configuration based on url
	Set configuration = ##class(HS.BulkFHIR.Configuration).BFCEndpointIndexOpen( request.SessionApplication )
	/// Store dynamic object configuration in session 
	Set session.config = configuration.Configuration
	Set config = session.configuration  /// get parsed configuration HS.BulkFHIR.API.Data.Config
	// Check whether user is permitted to make exports on this configuration
	Try {
		Do ..CheckResource("%HS_BFC_Export_Manage","USE")
	} Catch ex {
		// If the user does not have %HS_BFC_Export_Manage:USE, make sure they are an authorized user of the configuration
		If '$IsObject(configuration.Configuration."authorized_users") {
			Throw ex
		} Else {
			Set authorized = 0
			Set pos = ""
			For {
				If ($ZCVT(config."authorized_users".GetNext(.pos),"U") = $ZCVT(request.Username,"U")) {
					Set authorized = 1
					Quit
				} ElseIf (pos = "") {
					Quit
				}
			}
			If 'authorized {
				Throw ex
			}
		}
	}	
	
	// Add the selected access token properties to the persisted session,
	// to make that data available to the export processes.
	Set bfcTokenInfoStr = request.AdditionalInfo.GetAt("USER:BFCTokenInfo")
	If bfcTokenInfoStr '= "" {
		Set session.tokenInfo = {}.%FromJSON(bfcTokenInfoStr)
	}
	
	Set sc = session.%Save()
	Set sessionId = session.%Id()
	Set path = ##class(%Library.File).NormalizeDirectory(config."working_directory"_"/"_sessionId)
	If ##class(%Library.File).DirectoryExists(path) {
		Set sc = $$$ERROR($$$HSBFCErrDirectoryShouldNotExist,path)
	}

	Set logObject = {
		"severity": ($$$LogLevelInfo),
		"sessionId": (sessionId),
		"component": "bfc",
		"type": "session_action",
		"action": "created"
	}
	If $$$ISERR(sc) {
		Set logObject.reason = ($system.Status.GetErrorText(sc))
		Set logObject.severity = $$$LogLevelError
	}
	do ##class(HS.BulkFHIR.Log).Log(logObject)
	$$$ThrowOnError(sc)
	
	if config."auto_start" {
		Do ..DoSessionStart(session,"start")
		Set session = $$$NULLOREF
	}
	
	set response.Status = 202
	
	set response.ContentLocation = request.BaseURL _ "/status/" _ sessionId
	
	return
}

/// Mark session started/resumed, job item, and log output
ClassMethod DoSessionStart(pSession As HS.BulkFHIR.Session, pAction As %String) [ Internal, Private ]
{
	Set logObject = {
			"severity": ($$$LogLevelInfo),
			"sessionId": (pSession.%Id()),
			"component": "bfc",
			"type": "session_action",
			"action": (pAction)
		}
	Set sc = $$$OK
	try {
		do pSession.Start()
	} catch ex {
		Set sc = ex.AsStatus()
		Set reason = $system.Status.GetErrorText(sc)
		Set logObject.reason = ex.AsStatus()
		Set logObject.severity = $$$LogLevelError
	}

	If $$$ISOK(sc) {
		job ..OperationMonitor(pSession.%Id())::15
		If '$T {
			Set logObject.reason = $ze
			Set logObject.severity = $$$LogLevelError
			Set sc = $$$HSBFCErrJobFailed
		}
	}
	do ##class(HS.BulkFHIR.Log).Log(logObject)
	If $$$ISERR(sc) {
		$$$ThrowFHIR(sc)
	}
}

ClassMethod OperationMonitor(pSessionId As %String) [ Internal ]
{
	try {
		#dim session As HS.BulkFHIR.Session = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId)
		Set config = session.configuration
		set request = session.request
		do ..ParseRequest(.request)
		
		//If we don't throw but return False, the job was paused or cancelled. 
		//Therefore, don't flag the session as complete.
		set isComplete = $classmethod($$$BFCFetchClass(config), "Start", request, session)
		/// reload session to be sure it's up to date
		Do session.%Reload()
		//Always flush, even if paused, to prevent resources from staying in the buffer
		//for a long period of time.
		do ##class(HS.BulkFHIR.ExportManager).FlushSession(session)
		if 'isComplete {
			return
		}
		do ##class(HS.BulkFHIR.ExportManager).FinalizeSession(session)
		
		do session.Complete(config."expire_after_mins")
		do ##class(HS.BulkFHIR.Log).Log({
			"severity": ($$$LogLevelInfo),
			"sessionId": (pSessionId),
			"component": "bfc",
			"type": "session_action",
			"action": "complete"
		})
	} catch ex {
		Set statusText = $system.Status.GetErrorText(ex.AsStatus())
		do ##class(HS.BulkFHIR.Log).Log({
			"severity": ($$$LogLevelError),
			"sessionId": (pSessionId),
			"component": "bfc",
			"type": "session_action",
			"action": "failure",
			"reason": (statusText),
			"stack": ($ListToString(ex.iStack))
		})
		//Always flush, even if paused, to prevent resources from staying in the buffer
		//for a long period of time.
		If $IsObject($g(session)) {
			do ##class(HS.BulkFHIR.ExportManager).FlushSession(session)
			Set session.terminatedReason = statusText
		}
		Do ..Errored(pSessionId,statusText)
	}
}

ClassMethod Search(request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response) [ Internal ]
{
	Set config = ##class(HS.BulkFHIR.Configuration).GetConfiguration( request.SessionApplication )
	do $classmethod($$$BFCFetchClass(config), "Search", config, request, .response)
}

ClassMethod Read(request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response) [ Internal ]
{
	Set config = ##class(HS.BulkFHIR.Configuration).GetConfiguration( request.SessionApplication )
	do $classmethod($$$BFCFetchClass(config), "Read", config, request, .response)
}

ClassMethod Metadata(request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response) [ Internal ]
{
	Set config = ##class(HS.BulkFHIR.Configuration).GetConfiguration( request.SessionApplication )
	set metadata = {}.%FromJSON(config."capability_statement")
	
	set metadata.url = request.BaseURL _ "/metadata"
	if metadata.implementation '= "" {
		set metadata.implementation.url = request.BaseURL
	}
	set response.Json = metadata
	set response.Status = 200
}

ClassMethod ParseRequest(request As HS.FHIRServer.API.Data.Request) As %String [ Internal, Private ]
{
	if request.RequestMethod '= "GET" {
		$$$ThrowFHIR($$$HSBFCErrMethodNotAllowed, request.RequestMethod)
	}
	set handlerMethod = ""
	
	Set url = request.RequestPath
	Set verb = request.RequestMethod

	If $Extract(url)="/" Set url = $Extract(url, 2, *)
	If $Extract(url, *)="/" Set url = $Extract(url, 1, *-1)
	Set partCount = $Length(url, "/")
	if partCount > 4 {
		return handlerMethod
	}
	
	Set config = ##class(HS.BulkFHIR.Configuration).GetConfiguration( request.SessionApplication )
	#dim meta as HS.FHIRMeta.API = $$$BFCMetaAPI(config)
	set metadata = {}.%FromJSON(config."capability_statement")
	
	set key = ""
	for i=1:1:4 {
		set part = $piece(url, "/", i)
		set char = $select(part="metadata":"m",
							 part="status":"s",
							$e(part) = "$":"$",
								 part = "":"-",
										 1:"+")
		set key = key _ char
	}
	
	set map("GET","m---") = $lb("Metadata")
	set map("GET","s+--") = $lb("Status")
	set map("GET","$---") = $lb("Operation", "o")
	set map("GET","+$--") = $lb("Operation", "to")
	set map("GET","++$-") = $lb("Operation", "tio")
	set map("GET","+---") = $lb("Search", "t", "search-type")
	set map("GET","++--") = $lb("Read", "ti", "read")
	
	if $D(map(verb, key), epMeta) = 0 {
		return handlerMethod
	}
	set handlerMethod = $lg(map(verb, key), 1)
	set pattern = $lg(map(verb, key), 2)
	set requiredInteraction = $lg(map(verb, key), 3)
	for i=1:1:4 {
		set patternKey = $e(pattern, i)
		set part = $piece(url, "/", i)
		if (patternKey = "t") {
			set resourceEntry = meta.FHIRPathAPI.evaluateToJson(metadata, meta.FHIRPathAPI.parse("CapabilityStatement.rest.resource.where(type='" _ part _ "')"))
			if ('meta.IsValidResourceType(part) || 'resourceEntry.%Size()) && (handlerMethod '= "Operation") {
				$$$ThrowFHIR($$$HSBFCErrTypeNotSupported, part)
			}
			if requiredInteraction '= "" {
				set found = 0
				if $isobject(resourceEntry.%Get(0).interaction) {
					set interactionIter = resourceEntry.%Get(0).interaction.%GetIterator()
					while interactionIter.%GetNext(,.interaction) {
						if interaction.code = requiredInteraction  {
							set found = 1
						}
					}
				}
				if 'found {
					$$$ThrowFHIR($$$HSBFCErrInteractionNotSupported, requiredInteraction, part)
				}
			}
			
			set request.Interaction = part
			set request.Type = part
		}
		elseif (patternKey = "o") {
			if (part '= "$export") {
				$$$ThrowFHIR($$$HSBFCErrOperationNotSupported, part)
			}
			set request.OperationName = part
		}
		elseif (patternKey = "i") {
			set request.Id = part
		}
	}
	
	if request.OperationName = "$export" {
		if request.Type = "Patient" {
			if 'config."patient_export" {
				$$$ThrowFHIR($$$HSBFCErrExportTypeNotSupported, "Patient", $$$OutcomeNotSupported(400))
			}
			
		} elseIf request.Type = "Group" {
			if 'config."group_export" {
				$$$ThrowFHIR($$$HSBFCErrExportTypeNotSupported, "Group", $$$OutcomeNotSupported(400))
			}
			
		} elseIf request.Type = "" {
			if 'config."system_export" {
				$$$ThrowFHIR($$$HSBFCErrExportTypeNotSupported, "System", $$$OutcomeNotSupported(400))
			}
			
		} else {
			$$$ThrowFHIR($$$HSBFCErrTypeNotSupported, request.Type, $$$OutcomeInvalid(400))
		}
	}
	
	// If FHIR Search, then use existing FHIRServer logic to evaluate query parameters,
	// and honor Prefer handling parameter. Otherwise, if $export, then use local logic
	// to evaluate parameters, and always abort with error if any problems found with
	// query parameters.
	if handlerMethod = "Search" {
		set request.Parameters = ##class(HS.FHIRServer.API.Data.QueryParameters).CreateFromQueryString(request.QueryString, meta, request.Type)
		if ##class(HS.FHIRServer.Service).GetPreferHeader(request, "handling") = "strict" {
			$$$ThrowOnError(request.Parameters.status)
		}
	}
	else {
		set request.Parameters = ..CreateFromQueryString(config,request.QueryString, request.Type)
		$$$ThrowOnError(request.Parameters.status)
	}
	
	return handlerMethod
}

ClassMethod CreateFromQueryString(pConfig As HS.BulkFHIR.API.Data.Config, pParametersString As %String, pResourceType As %String = "") As HS.FHIRServer.API.Data.QueryParameters
{
	Set errStatus = $$$OK
	
	#dim result as HS.FHIRServer.API.Data.QueryParameters = ##class(HS.FHIRServer.API.Data.QueryParameters).%New()
	
	For i = 1:1:$Length(pParametersString, "&") {
		Set paramP = $Piece(pParametersString, "&", i)
		If paramP'="" {
			// Split Name from Value
			Set nameAndMod = $Piece(paramP, "=", 1)
			
			// If a query string is encoded at all, it should have been URI-encoded.
			Set value = $ZConvert($Piece(paramP,"=",2,*), "I", "URI")
			
			if $Find(nameAndMod,".") {
				$$$FHIRAddError(errStatus, $$$ERROR($$$HSFHIRErrInvalidChainLink, name, value, $$$OutcomeInvalid(400)))
				Continue
			}
			
			Set name = $Piece(nameAndMod, ":", 1)
			Set modifier = $Piece(nameAndMod, ":", 2,*)
			
			If modifier '= "" {
				$$$FHIRAddError(errStatus, $$$ERROR($$$HSFHIRErrUnsupportedParameterModifier, name, value, $$$OutcomeInvalid(400)))
				Continue
			}
			
			// TODO: Metadata-drive these lists once we achieve full support of Bulk FHIR 2.0.0.
			Set allParamNames = $ListBuild("_outputFormat", "_since", "_type")
			Set supportedParamNames = $ListBuild("_outputFormat", "_since", "_type")
			
			If '$ListFind(allParamNames, name) {
				$$$FHIRAddError(errStatus, $$$ERROR($$$HSFHIRErrInvalidQueryParameter, name, value, $$$OutcomeInvalid(400)))
				Continue
			}
			If '$ListFind(supportedParamNames, name) {
				$$$FHIRAddError(errStatus, $$$ERROR($$$HSFHIRErrParameterNotSupported, name, value, $$$OutcomeInvalid(400)))
				Continue
			}
			
			// The _type parameter must be resource types that are appropriate for
			// the core FHIR version being served by the current BFC.
			If name = "_type" {
				For valIdx = 1:1:$Length(value, ",") {
					Set valP = $Piece(value, ",", valIdx)
					If valP '= "" {
						Set metaAPI = $$$BFCMetaAPI(pConfig)
						If 'metaAPI.IsValidResourceType(valP) {
							$$$FHIRAddError(errStatus, $$$ERROR($$$HSFHIRErrInvalidParameterValue, name, value, $$$OutcomeInvalid(400)))
							Continue
						}
					}
				}
				
			} ElseIf name = "_outputFormat" {
				// If specified, _outputFormat must be one of the formats that the BFC supports.
				Set validOutputFormats = $ListBuild("application/fhir+ndjson", "application/ndjson", "ndjson")
				If (value '= "") && ('$ListFind(validOutputFormats, value)) {
					$$$FHIRAddError(errStatus, $$$ERROR($$$HSFHIRErrInvalidParameterValue, name, value, $$$OutcomeInvalid(400)))
					Continue
				}
				
			} ElseIf name = "_since" {
				// If specified, the _since parameter must be a valid FHIR instant.
				If '$Match(value, "([0-9]([0-9]([0-9][1-9]|[1-9]0)|[1-9]00)|[1-9]000)-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])T([01][0-9]|2[0-3]):[0-5][0-9]:([0-5][0-9]|60)(\.[0-9]+)?(Z|(\+|-)((0[0-9]|1[0-3]):[0-5][0-9]|14:00))") {
					$$$FHIRAddError(errStatus, $$$ERROR($$$HSFHIRErrInvalidParameterValue, name, value, $$$OutcomeInvalid(400)))
					Continue
				}
				Set sinceSeconds = ..ConvertInstantToUTCSecs(value)
				Set currentSeconds = ..ConvertInstantToUTCSecs($ZDateTime($Horolog, 3, 7))
				If sinceSeconds '< currentSeconds {
					$$$FHIRAddError(errStatus, $$$ERROR($$$HSBFCErrSinceNotBeforeCurrentTime, value, $$$OutcomeInvalid(400)))
					Continue
				}
			}
			Set newParam = ##class(HS.FHIRServer.API.SearchQueryParameter).%New(name, value)
			Set addParamSC = result.AddParameter(newParam, 1)
			If $$$ISERR(addParamSC) {
				$$$FHIRAddError(errStatus, addParamSC)
			}
		}
	}
	Set result.status = errStatus
	
	return result
}

}
