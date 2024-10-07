Include HS.BulkFHIR

Class HS.BulkFHIR.Installer Extends HS.BulkFHIR.Util.Security
{

/// @API
/// Configures/re-configures a Bulk FHIR Coordinator
/// in the current namespace
/// @Input pBFCconfig	configuration object containing the settings, adapters,
/// 					and adapter configurations needed to set up a Bulk FHIR
/// 					Coordinator. May either be an instance of Data.Config,
/// 					or a %DynamicObject
ClassMethod Configure(pBFCconfig As HS.BulkFHIR.API.Data.Config)
{
	Do ..ResourceCheck($lb("%HS_BFC_Configuration","WRITE"))
	// Create Log database entry - no-op if it exists
	do ##class(HS.BulkFHIR.Log).Create()
	// Ensure an SSL config for Bulk FHIR to use. This is separate from
	// any "default SSL config" that might be defined for the instance.
	do ..EnsureBFCSSLConfig($$$BFCBaseSSLConfig)

	
	try {
		Set logObject = {
				"severity": ($$$LogLevelInfo),
				"component": "bfc",
				"type": "config",
				"config": "Not parsed"
			}
		set config = pBFCconfig
		if config.%Extends("%DynamicObject") {
			set config = ##class(HS.BulkFHIR.API.Data.Config).FromJson(config)
		}
		do ..ValidateConfigure(config, "HS.BulkFHIR.API.Data.Config")
		$$$ThrowOnError(config.%JSONExportToString(.json))
		Set logObject.config = json
		set transaction = ##class(HS.Util.Scoped.Transaction).Start()	
		
		// We expect that the current namespace is dedicated to the BFC.
		// Set a namespace-specific value for %Net.HttpRequest Timeout.
		// Requests to the resource server use RestClient which uses the
		// Timeout value from the associated Service Registry entry, so
		// those should not be affected by this.
		do ..SetHttpTimeoutDefault(90, 0)

		Set lastURL = ""
		set configuration = ##class(HS.BulkFHIR.Configuration).BFCEndpointIndexOpen( config."endpoint_url" )
		if '$isobject(configuration) {
			// If we have the configuration name in another endpoint
			set configuration = ##class(HS.BulkFHIR.Configuration).NameIndexOpen( config.name )
			If $IsObject(configuration) {
				$$$ThrowFHIR($$$HSBFCErrNameExists,config.name)
			}
		} else {
			If ##class(HS.BulkFHIR.Configuration).NameIndexExists(config.name,.id) && (id '=configuration.%Id() ) {
				$$$ThrowFHIR($$$HSBFCErrEndpointImmutable)
			}
			if config."storage_config"."file_url" '= configuration.Configuration."storage_config"."file_url" {
				$$$ThrowFHIR($$$HSBFCErrEndpointImmutable)
			}
			Set lastURL = configuration.BFCEndpoint
		}
		if '$isobject(configuration) {
			set configuration = ##class(HS.BulkFHIR.Configuration).%New()
			set configuration.BFCEndpoint = config."endpoint_url"
		}
		set configuration.Name = config.name
		Set app = ""
		If ..CSPAppExists(config."endpoint_url",.app,.sc) {
			If app.NameSpace '= $namespace || '($classMethod(app.DispatchClass,"%IsA","HS.BulkFHIR.RestHandler") || $classMethod(app.DispatchClass,"%Extends","HS.BulkFHIR.RestHandler")) {
				$$$ThrowFHIR($$$HSBFCErrApplicationExists,config."endpoint_url")
			}
		} Else {
			// if there was a status code ensure it's just doesn't exist
			If $system.Status.GetErrorCodes(sc) '= $$$ApplicationDoesNotExist {
				$$$ThrowOnError(sc)
			}
		}

		Set app=""
		If config."storage_config"."file_url"]"" {
			If ..CSPAppExists(config."storage_config"."file_url",.app,.sc) {
				If app.NameSpace '= $namespace || '($classMethod(app.DispatchClass,"%IsA","HS.BulkFHIR.Storage.File.RestHandler") || $classMethod(app.DispatchClass,"%Extends","HS.BulkFHIR.Storage.File.RestHandler")) {
					$$$ThrowFHIR($$$HSBFCErrApplicationExists,config."storage_config"."file_url")
				}
			} Else {
				// if there was a status code ensure it's just doesn't exist
				If $system.Status.GetErrorCodes(sc) '= $$$ApplicationDoesNotExist {
					$$$ThrowOnError(sc)
				}
			}
		}


		if '$parameter($$$BFCFetchClass(config), "supportsPatientExport") && config."patient_export" {
			$$$ThrowFHIR($$$HSBFCErrFetchOperationNotSupported, $$$BFCFetchClass(config), "patient")
		}
		if '$parameter($$$BFCFetchClass(config), "supportsGroupExport") && config."group_export" {
			$$$ThrowFHIR($$$HSBFCErrFetchOperationNotSupported, $$$BFCFetchClass(config), "group")
		}
		if '$parameter($$$BFCFetchClass(config), "supportsSystemExport") && config."system_export" {
			$$$ThrowFHIR($$$HSBFCErrFetchOperationNotSupported, $$$BFCFetchClass(config), "system")
		}

		do ..ValidateConfigure($$$BFCFetchConfig(config), $parameter($$$BFCFetchClass(config),"configClass"))
		do ..ValidateConfigure($$$BFCAuthConfig(config), $parameter($$$BFCAuthClass(config),"configClass"))
		do ..ValidateConfigure($$$BFCStorageConfig(config),$parameter($$$BFCStorageClass(config),"configClass"))

		If config."core_fhir_package" = "" || (lastURL '= config."fetch_config"."endpoint_url") {
			Set fetch = config."fetch_config"
			Set config."core_fhir_package" = ..GetResourceServerMetadata(fetch."endpoint_url",,fetch."ssl_configuration")
		}

		do ..CreateWebApp(config."endpoint_url")
		
		do ..ConfigureAuth(config)
		do ..ConfigureStorage(config)
		do ..ConfigureFetch(config)
		$$$ThrowOnError(config.%JSONExportToString(.json))
		Set configuration.Configuration = {}.%FromJSON(json)
		$$$ThrowOnError(configuration.%Save())
		
		do ##class(HS.BulkFHIR.Util.SystemStartup).AddToStartupTable()
		Do ##class(HS.HC.SystemConfig.API).ScheduleTask($namespace, "HS.BulkFHIR.Util.ExpireTask", $namespace)
		// Schedule/create the PurgeExpiredSearchResultsTask
		Do ##class(HS.HC.SystemConfig.API).ScheduleTask("HSSYS", "HS.BulkFHIR.Util.PurgeExpiredSearchResultsTask", "HSSYS")

		do transaction.Commit()
	} catch ex {
		If $IsObject($GET(transaction)) {
			do transaction.Rollback()
		}
		Set transaction = ""
		Set logObject.reason = $system.Status.GetErrorText(ex.AsStatus())
		Set logObject.stack = $ListToString(ex.iStack)
		Set logObject.severity = $$$LogLevelError
		Do ##class(HS.BulkFHIR.Log).Log(logObject)
		Throw ex
	}
	Do ##class(HS.BulkFHIR.Log).Log(logObject)
}

/// Set the local namespace default for %Net.HttpRequest Timeout.
/// Must explicitly state to override existing value if any.
ClassMethod SetHttpTimeoutDefault(pTimeoutSecs As %Integer, pForce As %Boolean = 0)
{
	If ('$Data(^SYS("HttpRequest", "Timeout"))#10) || (pForce) {
		Set ^SYS("HttpRequest", "Timeout") = pTimeoutSecs
	}
}

/// Called by UI, given config name remove csp apps for BFC and files or queue them to 
/// ^HS.BFC.AppsToDelete(type,endpoint)=datetime queued
ClassMethod Delete(pConfigName As %String) [ Internal ]
{
	Do ..ResourceCheck($lb("%HS_BFC_Configuration","WRITE"))
	set configuration = ##class(HS.BulkFHIR.Configuration).NameIndexOpen( pConfigName, 4, .sc )
	$$$ThrowOnError(sc)
	Set storageConfig = $$$BFCStorageConfig(configuration.Configuration)

	Set endpoints = ""
	// look for sessions on this endpoint which are not purged
	Set list = ##class(HS.BulkFHIR.Session).GetSessions(,configuration.BFCEndpoint,0)
	Set endpoints = endpoints_$lb($lb("BFC",configuration.BFCEndpoint,list.Size))
	Set list = ##class(HS.BulkFHIR.Session).GetSessions(,,0,storageConfig."file_url")
	Set endpoints = endpoints_$lb($lb("FILE",storageConfig."file_url",list.Size))
	Set pendingOnFileEndpoint = list.Size
	Set ptr=0
	While $listNext(endpoints,ptr,item) {
		Set $lb(type,endpoint,size)=item
		If size {
			Set ^HS.BFC.AppsToDelete(type,endpoint)=$H
		} Else {
			Do ##class(HS.HC.SystemConfig.API).DeleteCSPApp($namespace, endpoint,0)
		}
	}
	$$$ThrowOnError(configuration.%DeleteId(configuration.%Id()))
	Quit
}

/// Called by ExpireTask which runs hourly to cleanup any endpoints from 
/// ^HS.BFC.AppsToDelete(type,endpoint)=queued time by checking to see if the endpoint is stil in use
ClassMethod CleanupOutstandingEndpoints()
{
	Set sc = $$$OK
	Set type=""
	For {
		Set type = $O(^HS.BFC.AppsToDelete(type))
		If type = "" { Quit }
		Set endpoint = ""
		For  {
			Set endpoint = $O(^HS.BFC.AppsToDelete(type,endpoint))
			If endpoint = "" { Quit }
			If type="FILE" {
				Set list = ##class(HS.BulkFHIR.Session).GetSessions(,,0,endpoint)
				If 'list.Size {
					try {
						Do ##class(HS.HC.SystemConfig.API).DeleteCSPApp($namespace, endpoint,0)
						Kill ^HS.BFC.AppsToDelete(type,endpoint)
					} catch ex {
						Set sc = $$$ADDSC(sc,ex.AsStatus())
					}
				}
			} ElseIf type="BFC" {
				Set list = ##class(HS.BulkFHIR.Session).GetSessions(,endpoint,0)
				If 'list.Size {
					try {
						Do ##class(HS.HC.SystemConfig.API).DeleteCSPApp($namespace, endpoint,0)
						Kill ^HS.BFC.AppsToDelete(type,endpoint)
					} catch ex {
						Set sc = $$$ADDSC(sc,ex.AsStatus())
					}
				}
			}
		}
	}
	$$$ThrowOnError(sc)
}

/// @Input BFCConfig	complete BFC configuration object 
ClassMethod ConfigureAuth(pBFCconfig As HS.BulkFHIR.API.Data.Config) [ Internal, Private ]
{
	Do $CLASSMETHOD($$$BFCAuthClass(pBFCconfig), "Initialize",pBFCconfig)
}

/// @Input BFCConfig	complete BFC configuration object 
ClassMethod ConfigureStorage(pBFCconfig As HS.BulkFHIR.API.Data.Config) [ Internal, Private ]
{
	do $CLASSMETHOD($$$BFCStorageClass(pBFCconfig), "Initialize",pBFCconfig)
}

/// @Input BFCConfig	complete BFC configuration object 
ClassMethod ConfigureFetch(pBFCconfig As HS.BulkFHIR.API.Data.Config) [ Internal, Private ]
{
	#dim fetchConfig As HS.BulkFHIR.Fetch.PureFHIR.Config = $$$BFCFetchConfig(pBFCconfig)

	// Validate resource_types to schema specified
	set typeList = fetchConfig."resource_types"
	Set size = typeList.Size
	If size {
		Set corespec = pBFCconfig."core_fhir_package" 
		Set schemaObj = ##class(HS.FHIRServer.Schema).LoadSchema(corespec)

		for idx = size:-1:1 {
			Set type = typeList.GetAt(idx)
			If type=$C(0) {
				/// remove empty entries (,,) 
				Do typeList.RemoveAt(idx)
				Continue
			}
			If type]"" && 'schemaObj.IsValidResourceType(type) {
				$$$ThrowFHIR($$$HSBFCErrResourceType, type)	
			}
		}
	}
		
	do $classmethod($$$BFCFetchClass(pBFCconfig), "Initialize",pBFCconfig)
	//The CapabilityStatement has a dependency on the fetch adapter. Therefore,
	//it's updated whenever the fetch config is updated
	do ..SaveCapabilityStatement(pBFCconfig)
}

/// @API
/// Returns the configuration definition currently in use for the BFC
ClassMethod Export(pBFCurl As %String) As HS.BulkFHIR.API.Data.Config
{
	return ##class(HS.BulkFHIR.Configuration).GetConfiguration( pBFCurl )
}

/// Logic shared across all Configure methods to validate the config object and ensure
/// the configuration changes should be allowed to take place.
ClassMethod ValidateConfigure(config As %RegisteredObject, requiredClassname As %String)
{
	if requiredClassname '= config.%ClassName(1) {
		$$$ThrowFHIR($$$HSBFCErrIncorrectConfigClass, requiredClassname, config.%ClassName(1))
	}
	$$$ThrowOnError(config.%ValidateObject())
	return
}

ClassMethod Reset(pRemoveConfig = 0) [ Internal ]
{
	try {
		set rs = ##class(%SQL.Statement).%ExecDirect(,"SELECT id from HS_BulkFHIR.Session")
		if (rs.%SQLCODE < 0) {
 			set sc = $$$ERROR($$$SQLError, rs.%SQLCODE, rs.%Message)
 			$$$ThrowOnError(sc)
		}
		while rs.%Next() {
			set session = ##class(HS.BulkFHIR.Session).%OpenId(rs.ID)
			do ##class(HS.BulkFHIR.Service).Purge(session)
		}		
	} Catch {}
	if pRemoveConfig {
		do ##class(HS.BulkFHIR.Configuration).%KillExtent()
	}
	kill $$$BFCTempGbl($namespace)
	kill $$$BFCPersistedGbl
	Kill ^IRIS.Temp.BFC.PureFHIR.Job
	do ##class(HS.BulkFHIR.Session).%KillExtent()
	do ##class(HS.BulkFHIR.Session.Link).%KillExtent()
	do ##class(HS.BulkFHIR.Session.PatientId).%KillExtent()
	do ##class(HS.BulkFHIR.Log).%KillExtent()
}

/// Create the BFC web app based on configuration
ClassMethod CreateWebApp(url As %String) [ Internal ]
{
	set tProps("Name") = url
	set tProps("NameSpace") = $namespace
	set tProps("DispatchClass") = "HS.BulkFHIR.RestHandler" 
	set tProps("AutheEnabled") = $$$AutheUnauthenticated + $$$AutheCache //Authentication is delegated to the auth adapter
	set tProps("Description") = "Bulk FHIR endpoint"
	Set hsRoleName = ##class(HS.HC.SystemConfig.Utils).GetHSRoleName($namespace)
	set tMatchRoles = ":"_hsRoleName_":%DB_HSCUSTOM:%DB_HSLIB:%DB_HSSYS:%DB_IRISSYS"
	Set tMatchRoles = tMatchRoles _ ":%HS_ImpersonateUser"
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
	Do ##class(HS.HC.SystemConfig.API).UpdateCSPApp($namespace,url,$$$NVPairToList(tProps),1,"n")
}

/// Called from HS.Util.Installer.Foundation
ClassMethod Setup(pNamespace As %String = {$namespace}) [ Internal ]
{
	New $NAMESPACE
	Set $namespace=pNamespace
	$$$ActivationLogInfo($Namespace, "Starting ")
	do ..EnsureBFCSSLConfig($$$BFCBaseSSLConfig)
	$$$ThrowOnError(##class(HS.HC.Util.Installer).SetupPermissions(pNamespace, ""))
	Do ..ConfigureRolesAndResources()
	Do ..CreateUIApplication(pNamespace)
	$$$ActivationLogInfo($Namespace, "Completed ")
}

/// Create CSP application for UI and API 
ClassMethod CreateUIApplication(pNamespace As %String = {$namespace}) [ Internal ]
{

	New $namespace
	Set $namespace=pNamespace

	Set prop("AutheEnabled")=$$$AutheUnauthenticated
	Set baseApp = "/csp/healthshare/"_$zcvt(pNamespace,"l")_"/bulkfhir"
	Set prop("GroupById")="%ISCMgtPortal"
	Set prop("UseCookies")=2
	Set prop("CookiePath")=baseApp_"/"
	/// Autocompile not needed for non-CSP apps
	Set prop("AutoCompile")=0
	do ##class(HS.Util.Installer.ConfigItem).CreateWebApplicationForUI(baseApp,pNamespace,"/csp/hslib/ui/bulkfhir-ui/",.prop,.found,0)
	/// Modify if existing
	if (found = 1) {
		Do ##class(HS.HC.SystemConfig.API).UpdateWebApplication(pNamespace, baseApp, $$$NVPairToList(prop))
	}
	/// API needs specialized roles
	Set hsRoleName = ##class(HS.HC.SystemConfig.Utils).GetHSRoleName($namespace)
	set tMatchRoles = hsRoleName_":%DB_HSCUSTOM:%DB_HSLIB:%DB_HSSYS:%DB_IRISSYS,:%HS_ImpersonateUser"
	Set tProps("MatchRoles") = tMatchRoles
	/// Enable JWT authentication for REST API
	Set prop("AutheEnabled")=$$$AutheCache
	Set prop("JWTAuthEnabled")=1
	Set prop("JWTAccessTokenTimeout")=60
	Set prop("JWTRefreshTokenTimeout")=900
	Set restApp=baseApp_"/api"
	do ##class(HS.Util.Installer.ConfigItem).CreateWebApplicationForREST(restApp,pNamespace,"HS.BulkFHIR.UI.RestHandler",.prop,.found)
	/// Modify if existing
	if (found = 1) {
		Do ##class(HS.HC.SystemConfig.API).UpdateWebApplication(pNamespace, restApp, $$$NVPairToList(prop))
	}
}

ClassMethod AddSQLProceduresToRole(pNamespace As %String, pRole As %String, pSQLProceduresList As %List)
{
	try {
		Set privilege = "Execute"
		Set type = "Stored Procedures"
		Set withGrant = 0	
		Do ##class(HS.HC.SystemConfig.API).SQLGrant( pNamespace, pNamespace, privilege, type, pSQLProceduresList, pRole, withGrant)
	} catch ex {
		// if already defined, the grant will throw an error Unknown or non-unique user or role
		If ex.Code '= $$$SQLCode || ($lg(ex.Data)'=-118) {
			$$$ThrowOnError(ex.AsStatus())
		} 
	}
}

/// Ensures an SSL configuration which can be used by all components
/// within the Bulk FHIR Coordinator. This SSL configuration does not verify
/// server identities. It may in the future, but for now that configuration
/// (if desired) must be done manually (as well as updating the respective
/// Service Registry or OAuth definition entries.
ClassMethod EnsureBFCSSLConfig(pName As %String) [ Internal ]
{
	new $namespace
	set $namespace = "%SYS"
	
	if '$classmethod("Security.SSLConfigs","Exists",pName) {
		do $classmethod("Security.SSLConfigs","Create",pName)
	}
}

ClassMethod SaveCapabilityStatement(pBFCconfig As HS.BulkFHIR.API.Data.Config) [ Internal ]
{
	#dim meta As HS.FHIRMeta.API = $$$BFCMetaAPI(pBFCconfig)
	
	set json = {
		  "resourceType": "CapabilityStatement",
		  "id": "1",
		  "meta": {
		    "versionId": "1",
	    	"lastUpdated": ($zdatetime($horolog,3,7))
		  },
		  "url": "<replaced-at-runtime>",
		  "version": "1",
		  "name": (pBFCconfig.name),
		  "status": "active",
		  "experimental": false,
		  "date": ($zdate($horolog, 3)),
		  "publisher": "InterSystems Corporation",
		  "kind": "instance",
		  "software": {
		    "name": "InterSystems Bulk FHIR Coordinator"
		  },
		  "implementation": {
		    "description": (pBFCconfig.name),
		    "url": "<replaced-at-runtime>"
		  },
		  "fhirVersion": (meta.FHIRVersion),
		  "format": [
		    "json"
		  ],
		  "rest": [
		  	{
			  	"mode": "server"
		  	}
		]
	}
	
	set wellKnown = $classmethod($$$BFCAuthClass(pBFCconfig), "WellKnownConfiguration", pBFCconfig)
	if $isobject(wellKnown) {
		set json.rest.%Get(0).security = {
	        "service": [
	          {
	            "coding": [
	              {
	                // For system on security service:
					// STU3: http://hl7.org/fhir/restful-security-service
					// R4:   http://terminology.hl7.org/CodeSystem/restful-security-service
					// R4B:  http://terminology.hl7.org/CodeSystem/restful-security-service
					// R5:   http://hl7.org/fhir/restful-security-service
					"system": ($SELECT(+meta.FHIRVersion=4 : "http://terminology.hl7.org/CodeSystem/restful-security-service", 1:"http://hl7.org/fhir/restful-security-service")),
	                "code": "SMART-on-FHIR",
	                "display": "SMART-on-FHIR"
	              }
	            ],
	            "text": "OAuth2 using SMART-on-FHIR profile (see http://docs.smarthealthit.org)"
	          }
	        ],
	        "extension": [
	        	{
					"url": "http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris",
					"extension": [
						{
							"url": "token",
							"valueUri": (wellKnown."token_endpoint")
						},
						{
							"url": "authorize",
							"valueUri": (wellKnown."authorization_endpoint")
						}
					]
	        	}
	        ]
		}
		if wellKnown."management_endpoint" '= "" {
			do json.rest.%Get(0).security.extension.%Push({
				"url": "manage",
				"valueUri": (wellKnown."management_endpoint")
			})
		}
	}
	
	set operationDocumentation = $classmethod($$$BFCFetchClass(pBFCconfig), "OperationDocumentation")
	if pBFCconfig."patient_export" || pBFCconfig."group_export" {
		set json.rest.%Get(0).resource = []
	}
	
	// In the core HL7 FHIR spec, OperationDefinition.name is just a name ("Name for
	// this operation definition (computer friendly)"), and OperationDefinition.code
	// is what is actually used in a FHIR request URL ("Recommended name for operation
	// in search url"). CapabilityStatement.rest.resource.operation.name indicates
	// that OperationDefinition.code should be used, without specifically mentioning
	// code ("Name by which the operation/query is invoked", "For an operation, this
	// is the name prefixed with $ and used in the URL.").
	if pBFCconfig."patient_export" {
		set patient = {
	  		"type": "Patient",
	  		"operation": [
	  			{
		  			"name": "export",
		  			"definition": "http://hl7.org/fhir/uv/bulkdata/OperationDefinition/patient-export"
	  			}
	  		]
  		}
  		if operationDocumentation '= "" {
	  		set patient.operation.%Get(0).documentation = operationDocumentation
  		}
  		
  		do json.rest.%Get(0).resource.%Push(patient)
	}
	if pBFCconfig."group_export" {
		set group = {
	  		"type": "Group",
	  		"operation": [
	  			{
		  			"name": "export",
		  			"definition": "http://hl7.org/fhir/uv/bulkdata/OperationDefinition/group-export"
	  			}
	  		]
  		}
  		set searchParams = ($classmethod($$$BFCFetchClass(pBFCconfig), "GroupSearchParameters",pBFCconfig))
  		if $isobject(searchParams) && (searchParams.%Size()) {
	  		set group.interaction = [
	  			{
		  			"code": "search-type"
	  			},
	  			{
		  			"code": "read"
	  			}
	  		]
	  		set group.searchParam = searchParams
  		}
  		
  		if operationDocumentation '= "" {
	  		set group.operation.%Get(0).documentation = operationDocumentation
  		}
  		do json.rest.%Get(0).resource.%Push(group)
	}
	
	if pBFCconfig."system_export" {
		set json.rest.%Get(0).operation = [
  			{
	  			"name": "export",
	  			"definition": "http://hl7.org/fhir/uv/bulkdata/OperationDefinition/export"
  			}
  		]
  		if operationDocumentation '= "" {
	  		set json.rest.%Get(0).operation.%Get(0).documentation = operationDocumentation
  		}
	}
	
	set pBFCconfig."capability_statement" = json.%ToJSON()
}

ClassMethod CSPAppExists(pCSPApp, ByRef pAppObj, ByRef pSC) As %Boolean
{
	Set pAppObj = ""
	Set pSC = ""
	New $Namespace
	Set $Namespace = "%SYS"
	Return $classmethod("Security.Applications","Exists",pCSPApp, .pAppObj, .pSC)
}

ClassMethod GetResourceServerMetadata(pURL As %String, Output pMetadata As %DynamicObject, pSSLConfiguration As %String = "") As %String
{
	Set url = $zcvt(pURL,"l")
	Set httpRequest = ##class(%Net.HttpRequest).%New()
	Set httpRequest.Server = $Piece($Piece(pURL, "/", 3), ":", 1)
	Do httpRequest.SetHeader("Accept","application/fhir+json")
	/// for metadata we don't want to use the namespace 90 second default timeout
	Set httpRequest.Timeout = 30
	Set secure = $Extract(url,5)="s"
	Set port = $Piece($Piece(pURL, "/", 3), ":", 2)
	If secure {
		Set httpRequest.SSLConfiguration = $SELECT(pSSLConfiguration="":$$$BFCBaseSSLConfig,1:pSSLConfiguration)
		Set httpRequest.Https = 1
	}
	Set httpRequest.Port = port
	Set path = $p(pURL,"/",4,*)
	Set:$e(path,*)'="/" path=path_"/"
	Set path = "/"_path_"metadata"
	Set sc = $Method(httpRequest, "Get", path)
	$$$ThrowOnError(sc)
	If $Extract(httpRequest.HttpResponse.StatusCode)'=2 {
		$$$ThrowFHIR($$$HSBFCErrMetadataFetch,path,httpRequest.HttpResponse.StatusCode)
	}
	Set pMetadata = {}.%FromJSON(httpRequest.HttpResponse.Data)
	Set version = pMetadata.fhirVersion
	&sql( SELECT id into :id FROM HS_FHIRMeta_Storage.Package where version=:version)
	If SQLCODE {
		$$$ThrowFHIR($$$HSBFCErrMetadataVersion,version)
	}
	Quit id
}

ClassMethod ConfigureRolesAndResources(pKey As %String = "HS.BulkFHIR.Installer:RolesAndResources") [ Internal ]
{
	Set hsRoleName = ##class(HS.HC.SystemConfig.Utils).GetHSRoleName($namespace)
	Do ..AddSQLProceduresToRole($namespace,hsRoleName,$lb("%Library.File_FileSet"))
	Set class = $p(pKey,":")
	Set block = $p(pKey,":",2)
	Set xdata =##class(%Dictionary.XDataDefinition).IDKEYOpen(class,block,0,.sc)
	Set data = {}.%FromJSON(xdata.Data)
	Set resourceIter = data.resources.%GetIterator()
	while resourceIter.%GetNext(.idx, .resourceObj) {
		Do ##class(HS.HC.SystemConfig.API).AddUpdateResource($namespace,resourceObj.resource, resourceObj.description)
	}
	Set rolesIter = data.roles.%GetIterator()
	while rolesIter.%GetNext(.idx, .roleObj) {
		Set resourceIter = roleObj.resources.%GetIterator()
		Set resources = ""
		While resourceIter.%GetNext(,.resource) {
			Set resources = resources _ "," _ resource.resource_":"_resource.privilege
		}
		Do ##class(HS.HC.SystemConfig.API).AddUpdateRole($namespace,roleObj.role, roleObj.description, $E(resources,2,*) )
	}

	Do ##class(HS.HC.SystemConfig.API).UpdateUserRoles($namespace,"Admin",$lb("%HS_BFC_Administrator"))
}

/// Resource and role definition
XData RolesAndResources [ MimeType = application/json ]
{
{
	"resources":[
		{ "resource":"%HS_BFC_Configuration","description":"W: create, edit or delete configurations; R: view configurations."},
		{ "resource":"%HS_BFC_Export_System","description":"U: start a system export."},
		{ "resource":"%HS_BFC_Export_Patient","description":"U: start a patient export."},
		{ "resource":"%HS_BFC_Export_Group","description":"U: start a group export."},
		{ "resource":"%HS_BFC_Export_Status","description":"R: view exports started by the current user; W: pause or cancel exports started by the current user."},
		{ "resource":"%HS_BFC_Export_Log","description":"R: view BFC Log entries for exports which were started by the current user."},
		{ "resource":"%HS_BFC_Export_Download","description":"U: download files created by exports which were started by the current user only."},
		{ "resource":"%HS_BFC_Export_Manage","description":"U: view, pause, stop, and resume exports in progress which were started by any user."},
		{ "resource":"%HS_BFC_Log_Manage","description":"U: view logs for exports which were started by any user."},
		{ "resource":"%HS_BFC_Download_Manage","description":"U: download files created by exports which were started by any user."}
	],
	"roles":[
		{
			"role":"%HS_BFC_Administrator",
			"description":"Configure and manage the operation of the Bulk FHIR Coordinator.",
			"resources":[
				{ "resource":"%Admin_OAuth2_Client","privilege":"U"},
				{ "resource":"%Admin_Secure","privilege":"U"},
				{ "resource":"%Admin_Task","privilege":"U"},
				{ "resource":"%Admin_Manage","privilege":"U"},
				{ "resource":"%HS_BFC_Configuration","privilege":"RW"},
				{ "resource":"%HS_BFC_Export_System","privilege":"U"},
				{ "resource":"%HS_BFC_Export_Status","privilege":"RW"},
				{ "resource":"%HS_BFC_Export_Log","privilege":"RW"},
				{ "resource":"%HS_BFC_Export_Download","privilege":"U"},
				{ "resource":"%HS_BFC_Export_Manage","privilege":"U"},
				{ "resource":"%HS_BFC_Log_Manage","privilege":"U"}
			]
		},
		{
			"role":"%HS_BFC_Exporter",
			"description":"Manage bulk FHIR exports and access exported files.",
			"resources":[
				{ "resource":"%HS_BFC_Export_Patient","privilege":"U"},
				{ "resource":"%HS_BFC_Export_Group","privilege":"U"},
				{ "resource":"%HS_BFC_Export_Status","privilege":"RW"},
				{ "resource":"%HS_BFC_Export_Log","privilege":"R"},
				{ "resource":"%HS_BFC_Export_Download","privilege":"U"}
			]
		},
		{
			"role":"%HS_BFC_Download_Manage",
			"description":"Download files created by exports which were started by any user.",
			"resources":[
				{ "resource":"%HS_BFC_Download_Manage","privilege":"U"}
			]
		},
		{
			"role":"%HS_BFC_Export_Manage",
			"description":"View, pause, stop, and resume exports in progress which were started by any user.",
			"resources":[
				{ "resource":"%HS_BFC_Export_Manage","privilege":"U"}
			]
		}
	]
}
}

}
