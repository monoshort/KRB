Include HS.BulkFHIR

Class HS.BulkFHIR.Fetch.PureFHIR.Adapter Extends HS.BulkFHIR.API.FetchAdapter
{

Parameter configClass As String = "HS.BulkFHIR.Fetch.PureFHIR.Config";

Parameter supportsPatientExport As Boolean = 1;

Parameter supportsGroupExport As Boolean = 1;

Parameter supportsSystemExport As Boolean = 1;

/// Number of seconds to wait for child jobs to stop
Parameter waitForChildJobs As Integer = 45;

/// Use the specified BFC configuration to:<br>
/// - Ensure a Service Registry entry for the FHIR resource server endpoint.<br>
/// - Ensure a client-side OAuth server definition, if using OAuth with resource server requests.<br>
/// - Ensure a client-side OAuth client, if using OAuth with resource server requests.<br>
ClassMethod Initialize(pBFCconfig As HS.BulkFHIR.API.Data.Config)
{
	Set fetchConfig = $$$BFCFetchConfig(pBFCconfig)
	Set serviceEntryName = $$$ServiceName(pBFCconfig)
	set serviceRegistryEntry = ##class(HS.Registry.Service.Abstract).EndPointForNameType(serviceEntryName, "HTTP")
	if '$isobject(serviceRegistryEntry) {
		set serviceRegistryEntry = ##class(HS.Registry.Service.HTTP).%New()
	}
	set serviceRegistryEntry.Name = serviceEntryName
	set serviceRegistryEntry.Type = "HTTP"
	/// if ssl but none was defined use $$$BFCBaseSSLConfig
	Set sslConfig = $S(fetchConfig."ssl_configuration"="":$$$BFCBaseSSLConfig,1:fetchConfig."ssl_configuration")
	set serviceRegistryEntry.SSLConfig = $select($extract(fetchConfig."endpoint_url", 1, 5) = "https":sslConfig, 1:"")
	$$$ThrowOnError(serviceRegistryEntry.ParseURL(fetchConfig."endpoint_url"))
	Set serviceRegistryEntry.Timeout = fetchConfig."http_timeout"
	set serviceRegistryEntry.HTTPCredentialsConfig = ""
	
	if fetchConfig."oauth_issuer_url" '= "" {
		do ..AddOAuthServerDefinition(pBFCconfig)
	}
	elseif fetchConfig."http_credential_id" '= "" {
		set serviceRegistryEntry.HTTPCredentialsConfig = fetchConfig."http_credential_id"
	}
	//If we're sending auth using the x-api-key header, don't save the credentials in the service
	//registry entry. That header will be added manually below in GetRestClient
	
	$$$ThrowOnError(serviceRegistryEntry.%Save())
}

ClassMethod Start(pRequest As HS.FHIRServer.API.Data.Request, pSession As HS.BulkFHIR.Session) As %Boolean
{
	Set sessionId = pSession.%Id()
	Set lockManager = ##class(%ZHSLIB.LockManager).%New()
	$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionJob(pSession)),"S", 60)) //Expect lock to be available in <1s.
	set $$$BFCSessionJob(pSession) = $job
	Do ##class(HS.BulkFHIR.ExportManager).CleanupSession(pSession)
	#dim config As HS.BulkFHIR.API.Data.Config = pSession.configuration

	#dim fetchConfig As HS.BulkFHIR.Fetch.PureFHIR.Config = $$$BFCFetchConfig(config)
	
	#dim metaApi As HS.FHIRMeta.API = $$$BFCMetaAPI(config)
	// _outputFormat is already validated by the Bulk FHIR Service.
	// _since is already validated by the Bulk FHIR Service. Its value is made
	//   available for use via the persisted Bulk FHIR session object.
	set supportedParams = $lb("_outputFormat", "_since", "_type")
	for paramIndex=1:1:pRequest.Parameters.Count() {
		#dim queryParameter as HS.FHIRServer.API.SearchQueryParameter = pRequest.Parameters.GetAt(paramIndex)
		set paramName = queryParameter.name
		set paramVal = queryParameter.value
		if '$listfind(supportedParams, paramName) {
			set opOutcome = ##class(HS.FHIRServer.Util.Outcome).CreateFromStatus($$$ERROR($$$HSFHIRErrParameterNotSupported, paramName, paramVal, $$$OutcomeInvalid(400)))
			do ##class(HS.BulkFHIR.ExportManager).AddError(pSession, opOutcome)
			continue
		}
		
		if paramName = "_type" {
			set typeList = $listfromstring(paramVal)
			set ptr = 0
			while $listnext(typeList, ptr, type) {
				set requestedResourceTypes(type) = ""
			}
		}
	}
	if '$data(requestedResourceTypes) && fetchConfig."resource_types".Count() {
		for i=1:1:fetchConfig."resource_types".Count() {
			set requestedResourceTypes(fetchConfig."resource_types".GetAt(i)) = ""
		}
	}
	
	// If fetch is using OAuth, then validate the requestedResourceTypes
	// against the access token scopes as derived from the BFC request
	// access token or the fetch-defined default scopes. If validate is
	// successful, then store input information for requesting an access
	// token from the resource server into the Session object.
	
	If fetchConfig."oauth_issuer_url" '= "" {
		// Check the BFC token info first. If none, then use the default
		// defined in the fetch config.
		Set fetchScopes = pSession.tokenInfo.scope
		If fetchScopes = "" {
			Set fetchScopes = ##class(HS.BulkFHIR.Util).ListOfStringToString(fetchConfig."fetch_token_scopes", " ")
		}
		try {
			// Validate that the requested resource types do not exceed what
			// is authorized by the access token scopes.
			Do ..ValidateTypesAndScopes(fetchScopes, .requestedResourceTypes)
		} catch ex {
			If (ex.Code = $$$HSFHIRErrHttpOnlyResponse) && ($LG(ex.Data) = $$$HttpIs(403)) {
				$$$ThrowStatus($$$ERROR($$$HSBFCErrScopesNotDetermined))
			}
			Throw ex
		}		
		
		// Put together some fetch token input values and store them into
		// the Session object so that they can be passed around, and
		// persisted for reference.
		Set fetchTokenInfo = {"scope": (fetchScopes), "credential_id": (fetchConfig."fetch_token_credential_id")}
		Set pSession.fetchTokenInfo = fetchTokenInfo
		$$$ThrowOnError(pSession.SafeSave())
	}
	
	set signaled = 0
	try {
		if pRequest.Type = "Patient" {
			do ..PatientExport(pSession, .requestedResourceTypes, .signaled)
		}
		elseif pRequest.Type = "Group" {
			do ..GroupExport(pSession, pRequest.Id, .requestedResourceTypes, .signaled)
		}
		elseif pRequest.Type = "" {
			do ..SystemExport(pSession, .requestedResourceTypes, .signaled)
		}
		else {
			$$$ThrowFHIR($$$NotImplemented)
		}
	} catch ex {
		kill $$$BFCSessionJob(pSession)
		throw ex
	}

	kill $$$BFCSessionJob(pSession)
	if signaled {
		return 0
	}
	else {
		Do ##class(HS.BulkFHIR.ExportManager).CleanupSession(pSession)
		Do ##class(HS.BulkFHIR.ExportManager).UpdateFileCounts(pSession)
		return 1
	}
}

/// Validate that the requested resource types do not exceed what
/// is authorized by the access token scopes.
ClassMethod ValidateTypesAndScopes(pScopes As %String, ByRef pRequestedResourceTypes) [ Internal ]
{
	For i = 1:1:$Length(pScopes, " ") {
		Set scope = $Piece(pScopes, " ", i)
		If scope '= "" {
			Set clinicalName = $Piece(scope, "/", 1)
			Set typeAndRW = $Piece(scope, "/", 2)
			If (clinicalName = "system") || (clinicalName = "user") {
				Set type = $Piece(typeAndRW, ".", 1)
				If $Piece(typeAndRW, ".", 2) = "read" {
					Set allowedTypes(type) = ""
				}
			}
		}
	}
		
	If $Data(pRequestedResourceTypes) {
		Set type = ""
		For {
			Set type = $Order(pRequestedResourceTypes(type))
			If type = "" Quit
			If '$$AllowedByScope(type) {
				Do ##class(HS.BulkFHIR.Util).LogAuthFail("403", "Request to resource server does not have the necessary scope to access resource of type " _ type)
				$$$ThrowFHIR($$$HttpOnlyResponse(403))
			}
		}
		
	} ElseIf '$$AllowedByScope("*") {
		do ##class(HS.BulkFHIR.Util).LogAuthFail("403", "Request to resource server must have 'user/*.read' scope to perform unqualified (ie. not using '_type') export")
		$$$ThrowFHIR($$$HttpOnlyResponse(403))
	}
	
	Return
		
AllowedByScope(resourceType)
	Return ($data(allowedTypes("*")) || $data(allowedTypes(resourceType)))
}

/// @BFC_Internal
/// Notify the session job as well as any children of request to stop (by the service)
/// pSessionId 	session id of session to pause
ClassMethod Pause(pSessionId As %String) [ Internal ]
{
	Set session = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId)
	Set lockManager = ##class(%ZHSLIB.LockManager).%New()
	$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionJob(session)),"S", 60)) //Expect lock to be available in <1s.
	if $data($$$BFCSessionJob(session)) {
		do $system.Event.Signal($$$BFCSessionJob(session))
		Set job = ""
		$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionChildJobs(session)),"S", 60)) //Expect lock to be available in <1s.
		For {
			Set job = $O($$$BFCSessionChildJob(session,job))
			If job = "" { Quit }
			do $system.Event.Signal(job)
		}
	}
}

/// @BFC_Internal
/// Notify the session job as well as any children of request to stop (by the service)
/// pSessionId 	session id of session to stop
ClassMethod Cancel(pSessionId As %String) [ Internal ]
{
	Do ..Pause(pSessionId)
}

ClassMethod Read(pConfig As HS.BulkFHIR.API.Data.Config, request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response)
{
	do ..Search(pConfig, request, .response)
}

ClassMethod Search(pConfig As HS.BulkFHIR.API.Data.Config, request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response)
{
	#dim fetchConfig As HS.BulkFHIR.Fetch.PureFHIR.Config = $$$BFCFetchConfig(pConfig)
	
	if fetchConfig."oauth_issuer_url" '= "" {
		// Check the BFC token info first. If none, then use the default defined
		// defined in the fetch config.
		set bfcTokenInfoStr = request.AdditionalInfo.GetAt("USER:BFCTokenInfo")
		set bfcTokenInfo = $Select(bfcTokenInfoStr'="":{}.%FromJSON(bfcTokenInfoStr), 1:{})
		set fetchScopes = bfcTokenInfo.scope
		if fetchScopes = "" {
			Set fetchScopes = ##class(HS.BulkFHIR.Util).ListOfStringToString(fetchConfig."fetch_token_scopes", " ")
		}
		
		set requestedResourceTypes(request.Type) = ""
		
		// Validate that the requested resource types do not exceed what
		// is authorized by the access token scopes.
		do ..ValidateTypesAndScopes(fetchScopes, .requestedResourceTypes)
		
		// Put together some fetch token input values and store them into
		// a token object so that they can passed to GetRestClient.
		set fetchTokenInfo = {"scope": (fetchScopes), "credential_id": (fetchConfig."fetch_token_credential_id")}
		set tokenObj = ##class(HS.BulkFHIR.Fetch.Util.AccessToken).Create(fetchConfig."client_name", "", fetchConfig."grant_type", bfcTokenInfo, fetchTokenInfo)
	} else {
		set tokenObj = ""
	}
	
	#dim restResponse As HS.FHIRServer.API.Data.RestClient.Response
	
	set queryID = request.GetParameterValue("queryId")
	If ""=queryID {
		// No queryId means this is an original search - not paginating
		set pageSize = request.GetParameterValue("_count")
		// Remove existing _count parameter for query we perform against the FHIR server and instead use fetch count (default 500) to reduce paging and speed up data collection
		if pageSize '="" {
			set qString = request.QueryString
			set start = $find(qString,"_count")-6
			set end = $find(qString,"&",start)
			set $extract(qString,start-1,$select(end=0:$length(qString),1:end-2))=""
			set request.QueryString = $zstrip(qString,"<","&")
		}
		set fetchCount = +fetchConfig."fetch_count"
		// Concatenate request Type, ID, and query parameters, then strip trailing character if request.QueryString was ""
		// Only add _count if fetch_count is configured and the request isn't for a specific resource ID
		set path = $zstrip(request.Type _ $select(request.Id'="":"/"_request.Id_"?", fetchCount > 0:"?_count="_fetchCount_"&", 1:"?") _ request.QueryString,">","&?")
		set restClient = ..GetRestClient(,pConfig, tokenObj)
		set restResponse = restClient.Get(path)
		
		set response.Status = $piece(restResponse.Status, " ", 1)
		if $isobject(restResponse.Payload) {
			set json = {}.%FromJSON(restResponse.Payload)
			if json.resourceType = "Bundle" {
				set count = 0
				set entries = []
				// Update entry fullUrls to point to the BFC instead of the FHIR server
				if $isobject(json.entry) {
					set entryIter = json.entry.%GetIterator()
					while entryIter.%GetNext(,.entry) {
						set searchUrl = ##class(HS.BulkFHIR.Util).GetSearchURL(entry.fullUrl,fetchConfig."endpoint_url")
						if searchUrl'=entry.fullUrl {
							// The fullUrl base was the fetch endpoint url - substitute it out for our base url
							// Otherwise make no change to the fullUrl because the changed Url would not work 
							set entry.fullUrl = request.BaseURL_searchUrl
						}
						do entries.%Push(entry)
						do $increment(count)
					}
				}
				
				if $isobject(json.link) {
					// Check whether the initial request used https
					set isHttps = ($zcvt($piece(request.BaseURL,"://"),"l")="https")
					set fpApi = $$$BFCMetaAPI(pConfig).FHIRPathAPI
					set next = fpApi.evaluateToJson(json, fpApi.parse("Bundle.link.where(relation='next').url"))
					while ($isobject(next) && next.%Size()) {
						set fullUrl = next.%Get(0)
						set next = ""
						// Use just the location if the fullUrl base is the fetch endpoint (this is faster), otherwise use the full url
						set searchUrl = ##class(HS.BulkFHIR.Util).GetSearchURL(fullUrl,fetchConfig."endpoint_url")
						if (searchUrl=fullUrl)&& 'isHttps && ($zcvt($piece(fullUrl,"://"),"l")="https") {
							// Use http because no SSL will have been configured
							set $extract(searchUrl,5)=""
						}
						set restResponse = restClient.Get(searchUrl)
						set response.Status = $piece(restResponse.Status, " ", 1)
						if $isobject(restResponse.Payload) {
							set bundle = {}.%FromJSON(restResponse.Payload)
							if bundle.resourceType = "Bundle" {
								if $isobject(bundle.entry) {
									// Update entry fullUrls to point to the BFC instead of the FHIR server and add entries to the bundle
									set entryIter = bundle.entry.%GetIterator()
									while entryIter.%GetNext(,.entry) {
										set searchUrl = ##class(HS.BulkFHIR.Util).GetSearchURL(entry.fullUrl,fetchConfig."endpoint_url")
										If searchUrl'=entry.fullUrl {
											// The fullUrl base was the fetch endpoint url - substitute it out for our base url
											// Otherwise make no change to the fullUrl because the changed Url would not work 
											Set entry.fullUrl = request.BaseURL_searchUrl
										}
										do entries.%Push(entry)
										do $increment(count)
									}
									
								}
								set next = fpApi.evaluateToJson(bundle, fpApi.parse("Bundle.link.where(relation='next').url"))
							}
						}
						
					}
					do json.%Remove("link")
				}
				
				// Set total because some FHIR Servers don't return it
				do json.%Set("total",count)
				
				if (""=pageSize) || (count <= pageSize) {
					set json.entry = entries
				} else {
					// More entries than requested
					// Clear out json.entry so it does not include extra entries, then add requested number back and
					/// store all entries in the resultSet which will be saved for pagination requests 
					set json.entry = []
					set resultSet = ##class(HS.BulkFHIR.Util.SearchResult).Create(pageSize,$username)
					
					do ##class(HS.FHIRServer.Service).GetPageLinks(request,resultSet.QueryId,count,pageSize,1,request.BaseURL,.urls)
					set position = $order(urls(""),1,url)
					if ""'=position {
						set links = []
						while ""'=position {
							set oneLink = {"relation":(position),"url":(url)}
							do links.%Push(oneLink)
							set position = $order(urls(position),1,url)
						}
						do json.%Set("link",links)
					}
					// Add pageSize entries to both the results we are returning and the results we are storing
					for i=0:1:pageSize-1 {
						set entry = entries.%Get(i)
						do json.entry.%Push(entry)
						do resultSet.AddRow(entry)
						
					}
					// Save the remaining entries to the resultSet
					while $increment(i) < count {
						do resultSet.AddRow(entries.%Get(i))
					}
					do resultSet.Paginate()
					do resultSet.Save()
				}
			}
			
			set response.Json = json
		}
	} else {
		// Paginating from a previous search
		
		// Throws if queryId not found
		set resultSet = ##class(HS.BulkFHIR.Util.SearchResult).Restore(queryID)
		
		set origUsername = resultSet.GetOriginalUsername()
		if (origUsername = "") {
			$$$ThrowFHIR($$$GeneralError, "Original query metadata could not be retreived") 
		} elseif (origUsername '= request.Username)  {
			$$$FSLog("Username for current Search queryId page query does not match Username for original query")
			$$$ThrowFHIR($$$HttpOnlyResponse(401))
		}
		
		set page = request.GetParameterValue("page")
		if (0 = +page) {
			set page = 1
		}
		do resultSet.SetIteratorToPage(page)
		
		do ##class(HS.FHIRServer.Service).GetPageLinks(request,resultSet.QueryId,resultSet.Total,resultSet.PageSize,page,request.BaseURL,.urls)
		
		Set schemaObj = ##class(HS.FHIRServer.Schema).LoadSchema(pConfig."core_fhir_package")
		set json = ##class(HS.FHIRServer.Service).CreateBundle("","searchset",resultSet.Total,.urls,schemaObj)
		
		set json.entry = []
		for ord=1:1:resultSet.PageSize {
			if 'resultSet.%Next() {
				Quit
			}
			do json.entry.%Push(resultSet.ResourceJson)
		}
		
		set response.Json = json
		set response.Status = 200

	}
	
	return
}

/// Return an array of the FHIR Group search parameters that are supported by the resource server.
ClassMethod GroupSearchParameters(pConfig As HS.BulkFHIR.API.Data.Config) As %DynamicArray
{
	set fpApi = $$$BFCMetaAPI(pConfig).FHIRPathAPI
	
	set capabilityStatement = ..Metadata(pConfig)
	
	return fpApi.evaluateToJson(capabilityStatement, fpApi.parse("CapabilityStatement.rest.resource.where(type='Group').searchParam"))
}

ClassMethod OperationDocumentation() As %String
{
	return "The result of this operation may include resources modified after the transactionTime in a Complete Status response."
}

/// generic callback for workqueue mgr
ClassMethod JobEnd(pArgs...) As %Status [ Internal ]
{
	Quit $$$OK
}

ClassMethod PatientExport(pSession As HS.BulkFHIR.Session, ByRef pRequestedResourceTypes, ByRef pSignaled As %Boolean) [ Internal ]
{
	#dim config As HS.BulkFHIR.API.Data.Config = pSession.configuration
	#dim fetchConfig As HS.BulkFHIR.Fetch.PureFHIR.Config = $$$BFCFetchConfig(config)

	set typeParam = ..ConstructTypeParam(.pRequestedResourceTypes)

	set sinceSeconds = pSession.sinceSeconds
	if sinceSeconds > 0 {
		set sinceParam = "_since=" _ $Piece($Piece(pSession.requestUrl, "_since=", 2), "&", 1)
	} else {
		set sinceParam = ""
	}	
	set fetchCount = +fetchConfig."fetch_count"
	if fetchCount > 0 {
		set fetchParam = "_count="_fetchCount
	} else {
		set fetchParam = ""
	}
	
	set queryParams = ..BuildQueryParams($ListBuild(typeParam, sinceParam,fetchParam))
	Set workerJobs = $S(fetchConfig."worker_jobs">=1:fetchConfig."worker_jobs",1:4)
	Set workQueue=##class(%SYSTEM.WorkMgr).%New(,workerJobs)
	Set lockManager = ##class(%ZHSLIB.LockManager).%New()
	Set patientCount = 100  /// number of patients to pass to child job

	// If patient id's haven't been collected yet, collect them
	If '$GET($$$BFCPersistedPatientsCollected(pSession)) {
		Set count =0 
		// CreateFromSession returns null object if the fetch config for the session does not indicate OAuth.
		Set tokenObj = ##class(HS.BulkFHIR.Fetch.Util.AccessToken).CreateFromSession(pSession, "")
		Set restClient =  ..GetRestClient(pSession, , tokenObj)
		Set path = "Patient?_elements=id"_$Select(fetchCount>0:"&_count="_fetchCount,1:"")
		#dim patientIter as HS.BulkFHIR.Fetch.Util.SearchIter = ##class(HS.BulkFHIR.Fetch.Util.SearchIter).%New(restClient, path ,pSession,"PatientList")
		If '$IsObject(patientIter) {
			/// first request is an error, something is wrong
			$$$ThrowOnError(%objlasterror)
		}
		Set list = ""
		while patientIter.Next(.patient, .sc) {
			if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
				set pSignaled = 1
				$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionChildJobs(pSession)),"S", 60)) //Expect lock to be available in <1s.
				For idx = 1:1:..#waitForChildJobs {
					Quit:'$D($$$BFCSessionChildJobs(pSession))
					Hang 1
				}
				return
			}
			Set count = count + 1
			// If no Patient resource was returned, then an error status should have been returned.
			// Make an OperationOutcome from the error status if a resource was not returned.
			If '$IsObject($Get(patient)) {
				If '$$$ISERR(sc) {
					set sc = $$$ERROR($$$GeneralError, "Patient resource not returned and error status not returned")
				}
				Set patient = ##class(HS.FHIRServer.Util.Outcome).CreateFromStatus(sc)
			}
			if patient.resourceType = "OperationOutcome" {
				do ##class(HS.BulkFHIR.ExportManager).AddError(pSession, patient)
				continue
			}
			Do ##class(HS.BulkFHIR.Session.PatientId).LinkPatient(pSession,patient.id)
			Set $li(list,*+1)=patient.id
			If count=patientCount {
				Set sc=workQueue.QueueCallback("..PatientExportJob","..JobEnd",pSession.%Id(),list,queryParams,.pRequestedResourceTypes)	
				Set list=""
				Set count = 0
			}

		}
		If $$$ISERR(sc) {
			/// determine if the sc is fatal or not
			Do ..HandleIterStatus(.sc,pSession)
		}
		
		/// if there are any remaining patients to process
		If count {
			Set sc=workQueue.QueueCallback("..PatientExportJob","..JobEnd",pSession.%Id(),list,queryParams,.pRequestedResourceTypes)	
			Set list=""
			Set count = 0 
		}

	} Else {
		For {
			Do ##class(HS.BulkFHIR.Session.PatientId).GetPatients(pSession,.list)
			If list = "" { Quit }
			if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
				set pSignaled = 1
				$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionChildJobs(pSession)),"S", 60)) //Expect lock to be available in <1s.
				For idx = 1:1:..#waitForChildJobs {
					Quit:'$D($$$BFCSessionChildJobs(pSession))
					Hang 1
				}
				return
			}
			Set sc=workQueue.QueueCallback("..PatientExportJob","..JobEnd",pSession.%Id(),list,queryParams,.pRequestedResourceTypes)	
		}
	}
	Set $$$BFCPersistedPatientsCollected(pSession)=1

	For  {
		Set sc=workQueue.Wait(,.atEnd,1)
		$$$ThrowOnError(sc)
		if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
			set pSignaled = 1
			$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionChildJobs(pSession)),"S", 60)) //Expect lock to be available in <1s.
			For idx = 1:1:..#waitForChildJobs {
				Quit:'$D($$$BFCSessionChildJobs(pSession))
				Hang 1
			}
			return
		}
		If atEnd { 
			/// be sure that we get the signaled flag before we quit for atEnd
			Quit
		}
	}

	return
}

/// WorkQueue job to process a list of patients
ClassMethod PatientExportJob(pSessionId As %String, pList As %List, pQueryParams As %String, ByRef pRequestedResourceTypes) As %Status [ Internal ]
{
	try {
		Set sc = $$$OK
		// Open the stored object with concurrency 0 because none of the code here
		// or called from here should be saving an update of the Session object.
		Set session = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId)
		Set lockManager = ##class(%ZHSLIB.LockManager).%New()
		$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionChildJobs(session)),"S", 60)) //Expect lock to be available in <1s.
		Set $$$BFCSessionChildJob(session,$job)=""
		// CreateFromSession returns null object if the fetch config for the session does not indicate OAuth.
		Set tokenObj = ##class(HS.BulkFHIR.Fetch.Util.AccessToken).CreateFromSession(session, "")
		Set restClient = ..GetRestClient(session, , tokenObj)
		Set ptr = 0
		While $ListNext(pList, ptr, patientId) {
			if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
				$$$ThrowOnError($$$ERROR($$$HSBFCErrBFCInterrupt))
			}
			Do ..AddResults(session, "Patient/" _ patientId _ "/$everything" _ pQueryParams, 0, .pRequestedResourceTypes, restClient)
			Do ##class(HS.BulkFHIR.Session.PatientId).PatientCompleted(session,patientId)
		}
		do ##class(HS.BulkFHIR.ExportManager).FlushTask(session, 0)
	} catch ex {
		Set sc = ex.AsStatus()
		/// don't log the external interrupt
		If $$$IsInterrupt(ex.Code,sc) {
			Set sc = $$$OK
		} Else {
			/// determine if the sc is fatal or not
			Do ..HandleIterStatus(.sc,session)
		}
	}
	Kill $$$BFCSessionChildJob(session,$job)
	Quit sc
}

ClassMethod GroupExport(pSession As HS.BulkFHIR.Session, groupResourceId As %String, ByRef requestedResourceTypes, ByRef pSignaled As %Boolean, pWorkQueue As %SYSTEM.WorkMgr = {$$$NULLOREF}, ByRef pGroupsInProgress) [ Internal ]
{
	Set sessionId = pSession.%Id()
	//Before proceeding, check whether this Group resource export is already in the call stack.
	//Groups can point to other Groups, and we don't want a cycle (A->B->C->A) getting us stuck
	//in a recursive loop indefinitely.
	if $data(pGroupsInProgress(groupResourceId)) {
		return
	}
	Set lockManager = ##class(%ZHSLIB.LockManager).%New()
	set pGroupsInProgress(groupResourceId) = ""
	
	//Use the Read API method to fetch the Group resource, rather than fetching it directly.
	//This allows another fetch adapter to override the Group resource construction without
	//needing to re-implement any other parts of Group export
	set groupRequest = ##class(HS.FHIRServer.API.Data.Request).%New()
	set groupRequest.RequestMethod = "GET"
	set groupRequest.Type = "Group"
	set groupRequest.Id = groupResourceId
	set groupResponse = groupRequest.NewResponse()
	// Add an indication that this Read being requested by the BFC itself
	// as part of an export, as opposed to a FHIR REST client of the BFC
	// requesting a read on a Group resource.
	do groupRequest.AdditionalInfo.SetAt(1, "USER:BFC_Export")
	try {
		do ..Read(pSession.configuration, groupRequest, .groupResponse)
	} catch ex {
		Set sc = ex.AsStatus()
		Do ..HandleIterStatus(.sc,pSession)
		/// we got a non-fatal error reading the group (likely a 404) nothing to process, so quit
		Return  
	}

	set group = groupResponse.Json
	Set itemCount = 100 // number of items to pass to child job
	if '$isobject(group.member) {
		$$$ThrowFHIR($$$HSBFCErrFeatureNotImplemented, "Group export using characteristics instead of members")
	}
	if $isobject(group.characteristic) {
		// The group includes both member and characteristic - we will only use member
		set logDynObj = {
			"severity": ($$$LogLevelWarning),
			"sessionId": (pSession.%Id()),
			"component": "bfc",
			"type": "rest_request",
			"path": (pSession.requestUrl),
			"reason": "Group includes characteristic. There might be be other candidate members who meet the characteristic and aren't in the list."
		}
		do ##class(HS.BulkFHIR.Log).Log(logDynObj)

	}
	
	// CreateFromSession returns null object if the fetch config for the session does not indicate OAuth.
	Set tokenObj = ##class(HS.BulkFHIR.Fetch.Util.AccessToken).CreateFromSession(pSession, "")
	
	set restClient = ..GetRestClient(pSession, , tokenObj)
	set typeParam = ..ConstructTypeParam(.requestedResourceTypes)
	
	set sinceSeconds = pSession.sinceSeconds
	if sinceSeconds > 0 {
		set sinceParam = "_since=" _ $Piece($Piece(pSession.requestUrl, "_since=", 2), "&", 1)
	} else {
		set sinceParam = ""
	}
	
	#dim fetchConfig As HS.BulkFHIR.Fetch.PureFHIR.Config = $$$BFCFetchConfig(pSession.configuration)
	set fetchCount = +fetchConfig."fetch_count"
	if fetchCount > 0 {
		set fetchParam = "?_count="_fetchCount
	} else {
		set fetchParam = ""
	}

	// Don't add fetchParam here because it will only be relevant for Patient/$everything requests, not other resource types 
	set queryParams = ..BuildQueryParams($ListBuild(typeParam, sinceParam))

	/// on recursive calls pWorkQueue will already exist
	If '$IsObject(pWorkQueue) {
		Set workerJobs = $S(fetchConfig."worker_jobs"]"":fetchConfig."worker_jobs",1:4)
		Set pWorkQueue = ##class(%SYSTEM.WorkMgr).%New(,workerJobs)
	}

	set memberIter = group.member.%GetIterator()
	Set list = ""
	while memberIter.%GetNext(.index, .member) {
		if pSignaled { Quit }
		if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
			set pSignaled = 1
			$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionChildJobs(pSession)),"S", 60)) //Expect lock to be available in <1s.
			For idx = 1:1:..#waitForChildJobs {
				Quit:'$D($$$BFCSessionChildJobs(pSession))
				Hang 1
			}
			return
		}

		if member.inactive {
			// Add a log entry about the inactive member, but do not include it
			set logDynObj = {
				"severity": ($$$LogLevelWarning),
				"sessionId": (pSession.%Id()),
				"component": "bfc",
				"type": "rest_request",
				"path": (pSession.requestUrl),
				"reason": ("Group member "_member.entity.reference_" is inactive. It is not included in the export.")
			}
			do ##class(HS.BulkFHIR.Log).Log(logDynObj)
			continue
		}
		
		if (member.entity.reference = "") || (member.entity.reference [ "?") {
			set opOutcome = ##class(HS.FHIRServer.Util.Outcome).CreateFromStatus($$$ERROR($$$HSBFCErrFeatureNotImplemented, "Resolving Group member[" _ index _"] with non-literal reference"))
			do ##class(HS.BulkFHIR.ExportManager).AddError(pSession, opOutcome)
			continue
		}
		
		set resourceKey = member.entity.reference
		
		set memberResourceType = $piece(resourceKey, "/", *-1)
		set memberResourceId = $piece(resourceKey, "/", *)
		
		if memberResourceType = "Group" {
			if list'="" {
				Set sc=pWorkQueue.QueueCallback("..GroupExportJob","..JobEnd",pSession.%Id(),list,queryParams,.requestedResourceTypes)	
				Set list = ""
			}
			do ..GroupExport(pSession, memberResourceId, .requestedResourceTypes, .pSignaled,.pWorkQueue,.pGroupsInProgress)
		} elseif memberResourceType = "Patient" {
			Set $li(list,*+1) = $lb(memberResourceType,memberResourceId,"/$everything"_fetchParam)
		} else {
			Set $li(list,*+1) = $lb(memberResourceType,memberResourceId,"")
		}

		If $listLength(list)>=itemCount {
			Set sc=pWorkQueue.QueueCallback("..GroupExportJob","..JobEnd",pSession.%Id(),list,queryParams,.requestedResourceTypes)	
			Set list = ""
		}
	}
	If $listLength(list) {
		Set sc=pWorkQueue.QueueCallback("..GroupExportJob","..JobEnd",pSession.%Id(),list,queryParams,.requestedResourceTypes)	
		Set list = ""
	}

	For  {
		Set sc=pWorkQueue.Wait(,.atEnd,1)
		If $$$ISERR(sc) {
			Set code = $system.Status.GetErrorCodes(sc)
			If $$$IsInterrupt(code,sc) {
				/// Don't log it, this is just a worker job stopping
				Continue
			} Else {
				$$$ThrowOnError(sc)
			}
		}
		if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
			$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionChildJobs(pSession)),"S", 60)) //Expect lock to be available in <1s.
			For idx = 1:1:..#waitForChildJobs {
				Quit:'$D($$$BFCSessionChildJobs(pSession))
				Hang 1
			}
			set pSignaled = 1
			Quit
		}
		If atEnd {
			/// be sure we get the signaled value before quitting for atEnd 
			Quit 
		}
	}

	return
}

/// @BFC_Internal
/// GroupExport will build a list of resources $lb($lb(resourceType,id,everything)) to process
ClassMethod GroupExportJob(pSessionId As %Integer, pList As %List, pQueryParams As %String, ByRef pRequestedResourceTypes) [ Internal ]
{
	try {
		Set sc=$$$OK
		// Open the stored object with concurrency 0 because none of the code here
		// or called from here should be saving an update of the Session object.
		Set session = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId)
		Set lockManager = ##class(%ZHSLIB.LockManager).%New()
		$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionChildJobs(session)),"S", 60)) //Expect lock to be available in <1s.
		Set $$$BFCSessionChildJob(session,$job)=""
		// CreateFromSession returns null object if the fetch config for the session does not indicate OAuth.
		Set tokenObj = ##class(HS.BulkFHIR.Fetch.Util.AccessToken).CreateFromSession(session, "")
		Set restClient = ..GetRestClient(session, , tokenObj)
		set ptr =0
		while $listnext(pList, ptr, item) {
			if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
				$$$ThrowOnError($$$ERROR($$$HSBFCErrBFCInterrupt))
			}
			Set $listbuild(resourceType,resourceKey,everything) = item
			try {
				do ..AddResults(session, resourceType _"/"_ resourceKey _ everything _ $S(everything["?":$E(pQueryParams,2,*),1:pQueryParams), 0, .pRequestedResourceTypes, restClient)
			} catch ex {
				Set sc = ex.AsStatus()
				Do ..HandleIterStatus(.sc,session)
				continue
			}
			If resourceType = "Patient" {
				do ##class(HS.BulkFHIR.Session).LinkPatient(session, resourceKey)
			}
		}
		do ##class(HS.BulkFHIR.ExportManager).FlushTask(session, 0)
	} catch ex {
		Set sc = ex.AsStatus()
		/// don't log the external interrupt
		If $$$IsInterrupt(ex.Code,sc) {
			Set sc = $$$OK
		} Else {
			//Catch any HTTP errors and insert them in the session result. 
			set opOutcome = ##class(HS.FHIRServer.Util.Outcome).CreateFromStatus(sc)
			do ##class(HS.BulkFHIR.ExportManager).AddError(session, opOutcome)
		}
	}
	Kill $$$BFCSessionChildJob(session,$job)
	Quit sc
}

/// Note: this sends a lot more requests than patient/group (one per rsrc type), so will
/// be a lot slower if low rate limiter ceiling
ClassMethod SystemExport(pSession As HS.BulkFHIR.Session, ByRef pRequestedResourceTypes, ByRef pSignaled As %Boolean) [ Internal ]
{
	Set bfcConfig = pSession.configuration
	#dim metaApi As HS.FHIRMeta.API = $$$BFCMetaAPI(bfcConfig)
	#dim fetchConfig As HS.BulkFHIR.Fetch.PureFHIR.Config = $$$BFCFetchConfig(bfcConfig)

	set capabilityStatement = ..Metadata(bfcConfig)

	set sinceSeconds = pSession.sinceSeconds
	if sinceSeconds > 0 {
		set lastUpdatedParam = "_lastUpdated=gt" _ $Piece($Piece(pSession.requestUrl, "_since=", 2), "&", 1)
	} else {
		set lastUpdatedParam = ""
	}
	
	set fetchCount = +fetchConfig."fetch_count"
	if fetchCount > 0 {
		set fetchParam = "_count="_fetchCount
	} else {
		set fetchParam = ""
	}
	
	set queryParams = ..BuildQueryParams($ListBuild(lastUpdatedParam,fetchParam))

	set resourceTypes = metaApi.FHIRPathAPI.evaluateToJson(capabilityStatement, metaApi.FHIRPathAPI.parse("CapabilityStatement.rest.resource.type"))
	set resourceTypeIter = resourceTypes.%GetIterator()
	Set lockManager = ##class(%ZHSLIB.LockManager).%New()

	set tokenObj = ##class(HS.BulkFHIR.Fetch.Util.AccessToken).CreateFromSession(pSession, "")
	set restClient = ..GetRestClient(pSession, , tokenObj)
	
	while resourceTypeIter.%GetNext(,.resourceType) {
		if '..TypeAllowed(.pRequestedResourceTypes, resourceType) {
			continue
		}

		// If we're restarting the export operation, skip patients which have already been completed
		// if it's not complete don't hold a lock with lockManager as multiple jobs will be working on this
		if ##class(HS.BulkFHIR.ExportManager).IsQueryComplete(,pSession, resourceType) {
			continue
		}

		set searchIter = ##class(HS.BulkFHIR.Fetch.Util.SearchIter).%New(restClient, resourceType _ queryParams, pSession,"IterateResults")
		If '$IsObject(searchIter) {
			Do ..HandleIterStatus(%objlasterror,pSession)
			Continue
		}
		If searchIter.Total()=0 {
			/// if it's specifically stated as 0 nothing to do
			Continue
		}
		Set workerJobs = $S(fetchConfig."worker_jobs"]"":fetchConfig."worker_jobs",1:4)
		Set workQueue = ##class(%SYSTEM.WorkMgr).%New(,workerJobs)
		For i=1:1:workerJobs {
			Set sc = workQueue.QueueCallback("..SystemExportJob","..JobEnd",pSession.%Id(),resourceType _ queryParams,1,.pRequestedResourceTypes)	
		}
		For {
			if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
				set pSignaled = 1
				$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionChildJobs(pSession)),"S", 60)) //Expect lock to be available in <1s.
				For idx = 1:1:..#waitForChildJobs {
					Quit:'$D($$$BFCSessionChildJobs(pSession))
					Hang 1
				}
				return
			}
			Set more = searchIter.Next(.resource, .sc)
			/// determine if the sc is fatal or not
			If $$$ISERR(sc) {
				Do ..HandleIterStatus(.sc,pSession)
			}
			If more {
				Do ..SystemExportItem(pSession, resource, resourceType _ queryParams, 1, metaApi)
			} Else  {
				Set sc=workQueue.Wait(,.atEnd,1)
				$$$ThrowOnError(sc)
				If atEnd {
					if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
						//make sure we mark that we were signaled to stop
						set pSignaled = 1
					}
					Quit 
				}
			}
		}
		do ##class(HS.BulkFHIR.ExportManager).CompleteQuery(pSession, resourceType)
		do ##class(HS.BulkFHIR.ExportManager).FlushTask(pSession, 0)
	}
	return
}

/// @BFC_Internal
/// Background job code to process the SystemExport search iterator 
ClassMethod SystemExportJob(pSessionId As %String, pQueryPath As %String, pLinkPatientRequired As %Boolean, ByRef pRequestedResourceTypes) As %Status [ Internal ]
{
	try {
		Set sc = $$$OK
		// Open the stored object with concurrency 0 because none of the code here
		// or called from here should be saving an update of the Session object.
		Set session = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId)
		Set lockManager = ##class(%ZHSLIB.LockManager).%New()
		$$$ThrowOnError(lockManager.Lock($name($$$BFCSessionChildJobs(session)),"S", 60)) //Expect lock to be available in <1s.
		Set $$$BFCSessionChildJob(session,$job)=""
		// CreateFromSession returns null object if the fetch config for the session does not indicate OAuth.
		Set tokenObj = ##class(HS.BulkFHIR.Fetch.Util.AccessToken).CreateFromSession(session, "")
		if pLinkPatientRequired {
			#dim metaApi as HS.FHIRMeta.API = $$$BFCMetaAPI(session.configuration)
		}
		set restClient = ..GetRestClient(session, , tokenObj)
		set searchIter = ##class(HS.BulkFHIR.Fetch.Util.SearchIter).%New(restClient, "",session,"IterateResults")
		If '$IsObject(searchIter) {
			Do ..HandleIterStatus(%objlasterror,session)
			Quit
		}
		while searchIter.Next(.resource, .sc) {
			if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
				$$$ThrowOnError($$$ERROR($$$HSBFCErrBFCInterrupt))
			}
			Do ..SystemExportItem(session, resource, pQueryPath, pLinkPatientRequired, metaApi)
		}
		do ##class(HS.BulkFHIR.ExportManager).FlushTask(session, 0)
		If $$$ISERR(sc) Do ..HandleIterStatus(.sc,session)
	} catch ex {
		Set sc = ex.AsStatus()
		/// don't return an error for the external interrupt
		If $$$IsInterrupt(ex.Code,sc) {
			Set sc = $$$OK
		} Else {
			/// determine if the sc is fatal or not
			Do ..HandleIterStatus(.sc,session)
		}
	}
	Kill $$$BFCSessionChildJob(session,$job)

	Quit sc
}

ClassMethod SystemExportItem(pSession As HS.BulkFHIR.Session, pResource As %DynamicObject, pQueryPath As %String, pLinkPatientRequired As %Boolean, pMetaAPI As HS.FHIRMeta.API)
{
	if pResource.resourceType = "OperationOutcome" {
		do ##class(HS.BulkFHIR.ExportManager).AddError(pSession, pResource, pQueryPath)
		Quit
	}
		
	if '..TypeAllowed(.pRequestedResourceTypes, pResource.resourceType) {
		Quit
	}
	
	//$everything requests may duplicate shared resources (like Organizations). Ensure
	//they're only added once
	if ##class(HS.BulkFHIR.ExportManager).IsResourceAdded(.lockManager, pSession, pResource.resourceType, pResource.id) {
		Quit
	}
	
	if pLinkPatientRequired {
		if 'pMetaAPI.IsSharedResourceType(pResource.resourceType) {
			set patientId = ""
			if pResource.resourceType = "Patient" {
				set patientId = pResource.id
			}
			else {
				set compartments = pMetaAPI.GetCompartmentsForResource(pResource)
				set ptr =0
				while $listnext(compartments, ptr, compartment) {
					if $e(compartment, 1,8) = "Patient/" {
						set patientId =  $E(compartment,9,*) 
						quit
					}
				}
			}
			if patientId '= "" {
				do ##class(HS.BulkFHIR.Session).LinkPatient(pSession, patientId)
			}
		}
	}
	do ##class(HS.BulkFHIR.ExportManager).AddResource(pSession, pResource, pQueryPath)
}

/// For a specified $ListBuild of URL parameter name-value pairs, any of which
/// could be blank, return a URL query string, including leading "?" if the
/// returned string is not to be blank.
ClassMethod BuildQueryParams(pParams As %List) As %String
{
	set queryParams = ""
	
	set pos = 0
	while $listnext(pParams, pos, param) {
		if param '= "" {
			if queryParams = "" {
				set queryParams = "?"
			} else {
				set queryParams = queryParams _ "&"
			}
		}
		set queryParams = queryParams _ param
	}
	
	return queryParams
}

/// Send a /metadata request to the resource server to get the endpoint's
/// FHIR CapabilityStatement resource, and return it as a %DynamicObject.
/// Input:<br>
/// @Input pBFCConfig Full BFC configuration object in effect for the current session.<br>
ClassMethod Metadata(pBFCconfig As HS.BulkFHIR.API.Data.Config) As %DynamicObject [ Internal ]
{
	set restClient = ..GetRestClient("", pBFCconfig)
	
	#dim response As HS.FHIRServer.API.Data.RestClient.Response = restClient.Get("metadata")
	
	return {}.%FromJSON(response.Payload)
}

ClassMethod AddResults(pSession As HS.BulkFHIR.Session, queryPath As %String, pLinkPatientRequired As %Boolean, ByRef pRequestedResourceTypes, ByRef pRestClient As %RegisteredObject) [ Internal ]
{
	//If we're restarting the export operation, skip items which have already been completed
	if ##class(HS.BulkFHIR.ExportManager).IsQueryComplete(.lockManagerQueryPath,pSession, queryPath) {
		return
	}
	if pLinkPatientRequired {
		#dim metaApi as HS.FHIRMeta.API = $$$BFCMetaAPI(pSession.configuration)
	}
	
	set searchIter = ##class(HS.BulkFHIR.Fetch.Util.SearchIter).%New(pRestClient, queryPath,pSession,"AddResults")
	If '$IsObject(searchIter) {
		Set sc = %objlasterror
	} Else {
		while searchIter.Next(.resource, .sc) {		
			if $system.Event.Wait("", 0) { //Pause/cancel was signaled, exit
				$$$ThrowOnError($$$ERROR($$$HSBFCErrBFCInterrupt))
			}
			if resource.resourceType = "OperationOutcome" {
				do ##class(HS.BulkFHIR.ExportManager).AddError(pSession, resource, queryPath)
				continue
			}
			
			if '..TypeAllowed(.pRequestedResourceTypes, resource.resourceType) {
				continue
			}
			
			//$everything requests may duplicate shared resources (like Organizations). Ensure
			//they're only added once
			if ##class(HS.BulkFHIR.ExportManager).IsResourceAdded(.lockManager, pSession, resource.resourceType, resource.id) {
				continue
			}
			
			if pLinkPatientRequired {
				if 'metaApi.IsSharedResourceType(resource.resourceType) {
					set patientId = ""
					if resource.resourceType = "Patient" {
						set patientId = resource.id
					}
					else {
						set compartments = metaApi.GetCompartmentsForResource(resource)
						set ptr =0
						while $listnext(compartments, ptr, compartment) {
							if $e(compartment, 1,8) = "Patient/" {
								set patientId =  $E(compartment,9,*) 
								quit
							}
						}
					}
					if patientId '= "" {
						do ##class(HS.BulkFHIR.Session).LinkPatient(pSession, patientId)
					}
				}
			}
			
			do ##class(HS.BulkFHIR.ExportManager).AddResource(pSession, resource, queryPath)
		}
	}
	/// determine if the sc is fatal or not, fatal will throw and therefore not complete the query
	If $$$ISERR(sc) Do ..HandleIterStatus(.sc,pSession)
	
	do ##class(HS.BulkFHIR.ExportManager).CompleteQuery(pSession, queryPath)
}

/// Determine what to do with pStatus, either log it to an error file (not fatal and continue) or throw an error (fatal)
ClassMethod HandleIterStatus(ByRef pStatus As %Status, pSession As HS.BulkFHIR.Session) [ Internal, Private ]
{
	Do $system.Status.DecomposeStatus(pStatus,.list)
	Set fatal = 1
	If $$$IsInterrupt(list(1,"code"),pStatus) {
		/// Don't log it, this is just a worker job stopping so just throw it
		$$$ThrowOnError(pStatus)	
	}
	If $G(list(1,"code"))=$$$HSBFCErrFetchRequestFailed && ($$$IsHTTPStatus($g(list(1,"param",1)),404)) {
		Set fatal = 0
	}
	If 'fatal {	
		//Catch any 404 errors and insert them in the session result. 
		set opOutcome = ##class(HS.FHIRServer.Util.Outcome).CreateFromStatus(pStatus)
		do ##class(HS.BulkFHIR.ExportManager).AddError(pSession, opOutcome)
	} Else {
		$$$ThrowOnError(pStatus)
	}
	Set pStatus = $$$OK
}

/// Internal method to get a configured rest client, rather than defining the config
/// everywhere we need an instance of the rest client
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

	#dim fetchConfig As HS.BulkFHIR.Fetch.PureFHIR.Config = $$$BFCFetchConfig(bfcConfig)
	if fetchConfig."x_api_key_credential_id" '= "" {
		set credential = ##class(Ens.Config.Credentials).%OpenId(fetchConfig."x_api_key_credential_id")
		set headers("x-api-key") = credential.Password
	}
	// Specify Prefer handling=lenient so that the request does not fail on possibly
	// unsupported parameters like _lastUpdated or _elements. If any of those params
	// is supported, then it helps optimize the export process. If none of those
	// params is supported, the BFC can still function okay.
	set headers("Prefer") = "handling=lenient"
	Set serviceEntryName = $$$ServiceName(bfcConfig)
	return ##class(HS.BulkFHIR.Fetch.Util.RestClient).getInstance(serviceEntryName, fetchConfig."max_req_per_sec", pTokenObj, sessionId, .headers)
}

ClassMethod AddOAuthServerDefinition(pBFCconfig As HS.BulkFHIR.API.Data.Config) [ Internal ]
{
	#dim fetchConfig As HS.BulkFHIR.Fetch.PureFHIR.Config = $$$BFCFetchConfig(pBFCconfig)
	new $namespace
	set $namespace = "%SYS"
	
	set serverDefinition = ##class(OAuth2.ServerDefinition).OpenByIssuer(fetchConfig."oauth_issuer_url")
	if '$isobject(serverDefinition) {
		set serverDefinition = ##class(OAuth2.ServerDefinition).%New()
		set serverDefinition.SSLConfiguration = $$$BFCBaseSSLConfig
		set serverDefinition.IsDiscovery = 1
	}
	set serverDefinition.IssuerEndpoint = fetchConfig."oauth_issuer_url"
	$$$ThrowOnError(##class(OAuth2.ServerDefinition).GetServerMetadata(serverDefinition.IssuerEndpoint, serverDefinition.SSLConfiguration, .metadata))
	set serverDefinition.Metadata = metadata
	$$$ThrowOnError(serverDefinition.%Save())
	
	set needsRegistration = 0
	set client = ##class(OAuth2.Client).%OpenId(fetchConfig."client_name")
	if '$isobject(client) {
		set needsRegistration = 1
		set client = ##class(OAuth2.Client).%New()
		set client.ApplicationName = fetchConfig."client_name"
		set client.ClientType = "confidential"
		set client.SSLConfiguration = $$$BFCBaseSSLConfig
		
		set client.Metadata."token_endpoint_auth_method" = "client_secret_post"
		set client.Metadata."grant_types" = $lb(fetchConfig."grant_type")
		set client.Metadata."client_name" = fetchConfig."client_name"
		set client.Metadata."access_token_signed_response_alg" = "RS256"
		
		set client.ServerDefinition = serverDefinition
	}
	
	//If the server definition doesn't match, this client was either never
	//registered or registered to a different server. Clear out its id and
	//secret, so it can be registered as a new client.
	if client.ServerDefinition '= serverDefinition {
		set needsRegistration = 1
		set client.ClientId = ""
		set client.ClientSecret = ""
		set client.ServerDefinition = serverDefinition
	}
	
	if $$$HSSecureIsActive {
		set client.RedirectionEndpoint.Host = $$$HSSecureHostName
		set client.RedirectionEndpoint.Port = $$$HSSecurePort
		set client.RedirectionEndpoint.Prefix = $$$HSSecurePrefix
		set client.RedirectionEndpoint.UseSSL = 1
	}
	else {
		$$$ThrowOnError(##class(%RoutineMgr).GetWebServerPort(.port, .server, .prefix))
		set client.RedirectionEndpoint.Host = server
		set client.RedirectionEndpoint.Port = port
		set client.RedirectionEndpoint.Prefix = prefix
		set client.RedirectionEndpoint.UseSSL = 0
	}
	
	if needsRegistration {
		$$$ThrowOnError(client.RegisterClient())
	}
	//The UpdateClient method was added after IRIS for Health 2021.1 was released. To
	//support running the BFC on earlier versions, do not attempt to call that method
	//when it doesn't exist.
	elseif ##class(%Dictionary.MethodDefinition).%ExistsId("OAuth2.Client||UpdateClient") {
		$$$ThrowOnError(client.UpdateClient())
	}
}

/// Construct a "_type" parameter to add to a query string, using
/// the specified multidimensional of requested resource types.
ClassMethod ConstructTypeParam(ByRef pRequestedResourceTypes) As %String [ Internal, Private ]
{
	set paramString = ""
	if $data(pRequestedResourceTypes) {
		set paramString = "_type="
		set resourceType = ""
		for {
			set resourceType = $order(pRequestedResourceTypes(resourceType))
			quit:(resourceType="")
			
			set paramString = paramString _ resourceType _ ","
		}
		set paramString = $e(paramString, 1, *-1) //Remove final ","
	}
	return paramString
}

ClassMethod TypeAllowed(ByRef pRequestedResourceTypes, resourceType As %String) As %Boolean [ CodeMode = expression, Internal, Private ]
{
'($data(pRequestedResourceTypes) && '$data(pRequestedResourceTypes(resourceType)))
}

}
