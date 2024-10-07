Include HS.BulkFHIR

Class HS.BulkFHIR.Fetch.ODS.GroupUCR
{

/// Delegate Group search out to a search directly to the UCR Cohort Registry (fka Program Registry).
ClassMethod SearchGroup(pConfig As HS.BulkFHIR.API.Data.Config, request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response, registryServiceName As %String, suppportedSearchParms As %DynamicArray, requestingUser As %String)
{
	#dim fhirAPIInstance as HS.FHIRMeta.API = $$$BFCMetaAPI(pConfig)
	set searchParams = request.Parameters
	
	// Gather supported search parameter names into a list.
	set paramsIter = suppportedSearchParms.%GetIterator()
	while paramsIter.%GetNext(.arrIdx, .paramObj) {
		set $List(supportedParamsList, *+1) = paramObj.name
	}
	
	// Re-validate search parameters, this time per this specialized functionality.
	if $IsObject(searchParams) {
		for paramIdx = searchParams.Count():-1:1 {
			set paramObj = searchParams.GetAt(paramIdx)
			set name = paramObj.name
			set value = paramObj.value
			
			// Must be in supported list.
			if '$ListFind(supportedParamsList, name) {
				$$$FHIRAddError(searchParams.status, $$$ERROR($$$HSFHIRErrParameterNotSupported, name, value, $$$OutcomeInvalid(400)))
				do searchParams.RemoveAt(paramIdx)
				continue
			}
		}
		// Detection of strict vs lenient is out of scope here.
		// Behave as though strict.
		$$$ThrowOnError(searchParams.status)
	}
	
	// Call GetCohortList to execute the Hub Web Service ListPrograms
	// query to get a list of cohorts. ListPrograms does not support
	// any search parameters.
	
	set listMode = "API"
	
	#dim listProgramsResponse As HS.Util.WebServices.ListItems = ..GetCohortList(registryServiceName, listMode, requestingUser)
	
	if $IsObject(searchParams) && (searchParams.Count()) {
		// Parse the listProgramsResponse and apply search parameters.
		for listItemIdx = listProgramsResponse.Items.Count():-1:1 {
			set listItem = listProgramsResponse.Items.GetAt(listItemIdx)
			set programInfo("actual") = 1
			set programInfo("type") = "person"
			set programInfo("_id") = listItem.ID
			set programInfo("code") = listItem.Description
			set programName = listItem.Name
			for searchParam = "actual", "type", "_id", "code" {
				if '..EvalGroupSearchParam(searchParams, searchParam, programInfo(searchParam)) {
					do listProgramsResponse.Items.RemoveAt(listItemIdx, .sc)
					$$$ThrowOnError(sc)
					quit
				}
			}
		}
	}
	
	// Use FetchPatientList to get the member counts for the surviving cohorts.
	// Call GetCohortMembers to execute the Hub Web Service FetchPatientList
	// query to get a count of members on each cohort.
	
	set groupJson = 0
	
	for listItemIdx = 1:1:listProgramsResponse.Items.Count() {		
		set listItem = listProgramsResponse.Items.GetAt(listItemIdx)
		set programId = listItem.ID
		set programName = listItem.Name
		set programDesc = listItem.Description
		set resourceKey = ("Group/" _ programId)
		
		do ..GetCohortMembers(programId, registryServiceName, requestingUser, 0, .memberCount, .memberArray)
		
		// Only return cohorts that have members.
		if 'memberCount continue
		
		// Formulate the Group resource, omitting the member collection.
		set groupJson($i(groupJson)) = ..GetGroupJson(programId, programName, programDesc, memberCount)
	}
	
	set urls("self") = ##class(HS.FHIRServer.Service).GetFullRequestURL(request)
	
	set bundle = ##class(HS.FHIRServer.Util.Bundle).CreateBundle("", "searchset", +groupJson, .urls, fhirAPIInstance)
	
	for resourceIdx = 1:1:groupJson {
		set fullUrl = request.BaseURL _ "/Group/" _ groupJson(resourceIdx).id
		do ##class(HS.FHIRServer.Util.Bundle).AddBundleEntry(bundle, fullUrl, groupJson(resourceIdx), "match")
	}
	
	do ##class(HS.FHIRServer.Util.Bundle).FinalizeBundle(bundle)
	
	set response.Json = bundle
	
	return
}

/// Specialized evaluation of a listProgramsResponse row property
/// against its associated FHIR Group resource search parameter.
ClassMethod EvalGroupSearchParam(pParameters As HS.FHIRServer.API.Data.QueryParameters, pParamName As %String, pPropVal As %String) As %Boolean [ Internal ]
{
	set paramCount = pParameters.GetParameterCount(pParamName)
	
	// No instance of the parameter found, nothing to fail against.
	if 'paramCount return 1
	
	// All the searchable properties in the virtualized ODS Group
	// resource will have a single value. If more than one instance
	// (i.e., AND) of a given param is present then automatically
	// fail.
	if paramCount > 1 return 0
	
	set pass = 0
	
	set paramVal = pParameters.GetParameterValue(pParamName)
	set propVal = pPropVal
	
	if paramVal '= "" {
		// pvp = param value piece
		
		if pParamName = "code" {
			// Massage any vertical bar out of the values,
			// drop those that have a system portion. Make
			// it case-insensitive.
			set pass = 0
			set paramVal = $ZConvert(paramVal, "U")
			set propVal = $ZConvert(propVal, "U")
			for commaIdx = 1:1:$Length(paramVal, ",") {
				set pvp = $piece(paramVal, ",", commaIdx)
				if ($extract(pvp) = "|") && ($length(pvp) > 1) {
					set $piece(paramVal, ",", commaIdx) = $extract(pvp, 2, *)
				}
			}
		}
		// Do startswith match on all values until a match or none found.
		for commaIdx = 1:1:$Length(paramVal, ",") {
			set pvp = $piece(paramVal, ",", commaIdx)
			set pvpl = $length(pvp)
			if $extract(propVal, 1, pvpl) = pvp {
				set pass = 1
				quit
			}
		}
		
	} else {
		// Parameter with no value, ignore.
		set pass = 1
	}
	
	return pass
}

/// Delegate Group read out to a direct retrieve of a UCR Cohort Registry (fka Program Registry) entry.
ClassMethod ReadGroup(request As HS.FHIRServer.API.Data.Request, ByRef response As HS.FHIRServer.API.Data.Response, registryServiceName As %String, requestingUser As %String)
{
	// ReadGroup equates resource id to Cohort ProgramId.
	set programId = request.Id
	
	#dim cohortDef As HS.Hub.HSWS.WebServices.Containers.Program = ..GetCohort(registryServiceName, programId)
	
	set programName = cohortDef.Name
	set programDesc = cohortDef.Description
	
	set includeMembers = +request.AdditionalInfo.GetAt("USER:BFC_Export")
	
	// Do GetCohortMembers, specifying to return the members array along with the count.
	do ..GetCohortMembers(programId, registryServiceName, requestingUser, includeMembers, .memberCount, .memberArray)
	
	// Formulate and return the Group resource.
	set response.Json = ..GetGroupJson(programId, programName, programDesc, memberCount, memberArray)
	
	quit
}

ClassMethod GetCohort(pHubService As %String, pProgramId As %String) As HS.Hub.HSWS.WebServices.Containers.Program [ Internal ]
{
	#dim loadProgramResponse As HS.Hub.HSWS.WebServices.Containers.Program
	
	set sc = ..InvokeSOAPService(pHubService,
								"HS.Hub.HSWS.WebServices",
								"HS.Hub.HSWS.WebServicesClientAPI",
								"LoadProgram",
								.loadProgramResponse,
								pProgramId)
	// This is a success/fail of InvokeSOAPService itself.
	$$$ThrowOnError(sc)
	
	// This is the status returned by the ListPrograms logic itself.
	if $$$ISERR(loadProgramResponse.Status) {
		// Object to Load not found
		if $system.Status.GetErrorCodes(loadProgramResponse.Status) = "5809" {
			$$$ThrowFHIR($$$HSFHIRErrResourceNotFound, "Group", pProgramId, $$$OutcomeNotFound)
		} else {
			$$$ThrowStatus(loadProgramResponse.Status)
		}
	}
	
	return loadProgramResponse
}

ClassMethod GetCohortList(pHubService As %String, pListMode As %String = "API", pRequestingUser As %String = "") As HS.Util.WebServices.ListItems [ Internal ]
{
	#dim listProgramsResponse As HS.Util.WebServices.ListItems
	
	set sc = ..InvokeSOAPService(pHubService,
								"HS.Hub.HSWS.WebServices",
								"HS.Hub.HSWS.WebServicesClientAPI",
								"ListPrograms",
								.listProgramsResponse,
								pListMode,
								pRequestingUser)
	// This is a success/fail of InvokeSOAPService itself.
	$$$ThrowOnError(sc)
	
	// This is the status returned by the ListPrograms logic itself.
	$$$ThrowOnError(listProgramsResponse.Status)
	
	return listProgramsResponse
}

ClassMethod GetCohortMembers(pProgramId As %String, pHubService As %String, requestingUser As %String, pIncludeMembers As %Boolean = 0, Output pMemberCount As %Integer, Output pMemberArray As %DynamicArray) [ Internal ]
{
	set pMemberCount = 0
	set pMemberArray = ""
	
	#dim fetchPatientListResponse As HS.Message.PatientListResponse
	
	set fetchPatientListRequest = ##class(HS.Message.PatientListRequest).%New()
	set fetchPatientListRequest.ListType = "program"
	set fetchPatientListRequest.ListId = pProgramId
	set fetchPatientListRequest.RequestingUser = requestingUser
	// How or if MaxPatients is actually applied on the server is unclear.
	// Provide an arbitrarily very high number to ensure all members are
	// counted and/or returned.
	set fetchPatientListRequest.MaxPatients = 99999999
	set sc = ..InvokeSOAPService(pHubService,
								"HS.Hub.HSWS.WebServices",
								"HS.Hub.HSWS.WebServicesClientAPI",
								"FetchPatientList",
								.fetchPatientListResponse,
								fetchPatientListRequest)
	// This is a success/fail of InvokeSOAPService itself.
	$$$ThrowOnError(sc)
	
	// This is the status returned by the FetchPatientList logic itself.
	set fplrSc = fetchPatientListResponse.Status
	if $$$ISERR(fplrSc) {
		// Don't incur a fail if it was a cohort that we do not have access to.
		if $system.Status.GetErrorText(fplrSc) [ "List not allowed" {
			return
		} else {
			$$$ThrowOnError(fplrSc)
		}
	}
	
	// If a cohort is MRN-based then an MPIID could appear multiple times.
	for memberIdx = 1:1:fetchPatientListResponse.Members.Count() {
		set mpiid = fetchPatientListResponse.Members.GetAt(memberIdx).MPIID
		If '$data(mpiids(pProgramId, mpiid)) {
			do $i(pMemberCount)
			set mpiids(pProgramId, mpiid) = ""
			if pIncludeMembers {
				if '$IsObject(pMemberArray) {
					set pMemberArray = []
				}
				Do pMemberArray.%Push({"entity":{"reference":("Patient/" _ mpiid)}})
			}
		}
	}
	
	return
}

ClassMethod GetGroupJson(pProgramId As %String, pProgramName As %String, pProgramDescription As %String, pMemberCount As %Integer, pMemberArray As %DynamicArray = "") [ Internal ]
{
	Set code = $Select(pProgramDescription'="": pProgramDescription, 1:"Patient")
	
	Set json = {
		"resourceType": "Group",
		"id": (pProgramId),
		"active": true,
		"type": "person",
		"actual": true,
		"code": {
			"coding":[
				{
					"code": (code)
				}
			],
			"text": (code)
		},
		"name": (pProgramName),
		"quantity": (pMemberCount)
	}

	if $IsObject(pMemberArray) && (pMemberArray.%Size()) {
		set json.member = pMemberArray
	}

	return json
}

/// Copied from HS.Util.SOAPAPIHelper and modified,
ClassMethod InvokeSOAPService(pSoapTarget, pServiceClassName As %String, pProxyClassName As %String, pMethodName As %String, Output pResponse, pArgs...) As %Status [ Final, Internal ]
{
	try {
		If pSoapTarget="" {
			Set tSC = $$$ERROR(5001,"Soap Service Target is required.")
			Quit
		}
		// Get the end point for the SOAP Service
		#dim tConfig as HS.Registry.Service.SOAP = ##class(HS.Registry.Service.SOAP).EndPointForNameType(pSoapTarget,"SOAP")
		If $isObject(tConfig) {
			Set tURL = $p(tConfig.EndPoint,"/",1,$l(tConfig.EndPoint,"/")-1)
			Set tSSLConfig=tConfig.SSLConfig
			Set tEnsembleUser = tConfig.UsernameTokenProfileConfig
			Set tCredentials = ##class(Ens.Config.Credentials).%OpenId(tEnsembleUser)
			Set tUser=tCredentials.Username, tPW=tCredentials.Password
		} Else {
			Set tSC = $$$ERROR($$$GeneralError, "The HealthShare component '" _ pSoapTarget _ " SOAP Service" _ "' is not properly configured")
			Quit
		}
		
		// Handle case of % in class name
		If $e(pServiceClassName)="%" Set $E(pServiceClassName)="_"
		// tSoap is an instance of the WebServicesClient
		Set tSoap=$zobjclassmethod(pProxyClassName,"%New")
		Set tSoap.Location=tURL_"/"_pServiceClassName_".cls"
		Set tSC=tSoap.WSSecurityLogin(tUser,tPW) QUIT:'tSC
		Set tSoap.SSLConfiguration=tSSLConfig
		// Invoke the method at the destination endpoint
		// Note, that pResponse here is only the %Status for Ensemble services.  The response object must be defined in the pArgs list 
		Set pResponse=$zobjmethod(tSoap,pMethodName,pArgs...)
		Set tSC=$$$OK
		
		QUIT

	} catch ex {
		Set tSC=$S($ZE["ZSOA":%objlasterror,1:##class(Ens.Util.Error).EnsSystemError($$$CurrentClass,$$$CurrentMethod))
	}
	Quit tSC
}

}
