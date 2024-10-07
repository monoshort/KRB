/// Base REST API implementation class for Bulk FHIR User Interface
Class HS.BulkFHIR.UI.REST.v1 Extends HS.BulkFHIR.UI.RestHandler
{

XData UrlMap
{
<Routes>
<Route Url="/metadata"							Method="GET"	Call="GetMetadata"/>
<Route Url="/sessiondata"						Method="GET"	Call="GetSessionData"/>
<Route Url="/sessiondata/logout"				Method="GET"	Call="SessionLogout"/>
<Route Url="/configs"							Method="GET"	Call="GetConfigs"/>
<Route Url="/config"							Method="POST"	Call="PostConfig"/>
<Route Url="/config"							Method="DELETE"	Call="DeleteConfig"/>
<Route Url="/logs"								Method="GET"	Call="GetSessionsLog"/>
<Route Url="/logoptions"						Method="GET"	Call="GetLogFilterOptions"/>
<Route Url="/sessions"							Method="GET"	Call="GetSessions"/>
<Route Url="/session/:sessionId/:action"		Method="GET"	Call="SessionAction"/>
<Route Url="/session"							Method="POST"	Call="PostSession"/>
<Route Url="/file/:sessionId/:fileName"			Method="GET"	Call="GetFile"/>

</Routes>
}

/// Handler for GET /metadata
/// Returns information about current namespace
ClassMethod GetMetadata() As %Status
{
    Set response = {}
    Set responseSC = $$$OK
	Try {
		Set response = ..GetJSONMetadata()
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	Quit ..Response(response,responseSC)
}

/// Handler for GET /sessiondata
/// Returns information about current user
ClassMethod GetSessionData() As %Status
{
    Set response = {}
    Set responseSC = $$$OK
	Try {
	    Set response.username = $USERNAME
	    Set response.version = $ZVERSION
	    Set response.namespace = $NAMESPACE
	    Set resources = {}
	    For resourceName = "%HS_BFC_Configuration","%HS_BFC_Export_System","%HS_BFC_Export_Patient","%HS_BFC_Export_Group","%HS_BFC_Export_Status","%HS_BFC_Export_Log","%HS_BFC_Export_Download","%HS_BFC_Export_Manage","%HS_BFC_Log_Manage","%HS_BFC_Download_Manage" {
	    	Set resourcePriv = $SYSTEM.Security.Check(resourceName)
	    	Do resources.%Set(resourceName,resourcePriv)
	    }
	    Set response.resources = resources
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	Quit ..Response(response,responseSC)
}

/// Handler for GET /sessiondata/logout
/// Finishes current session
ClassMethod SessionLogout() As %Status
{
    Set response = {}
    Set responseSC = $$$OK
	Try {
	   	Set sc = %session.Logout(1)
		Set %session.EndSession = 1
		Set response.logout = sc
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	Quit ..Response(response,responseSC)
}

/// Handler for GET /configs
/// Returns a list of configured Bulk FHIR controllers in the namespace
ClassMethod GetConfigs() As %Status
{
    Set response = {}
    Set responseSC = $$$OK
	Try {
	    Set response = ..GetJSONConfigs()
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	Quit ..Response(response,responseSC)
}

/// Handler for GET /sessions
/// Returns a list of Bulk FHIR sessions in the namespace
ClassMethod GetSessions() As %Status
{
    Set response = {}
    Set responseSC = $$$OK
    Set response.meta = {}

	Try {
		Set response.sessions = []
		Set whereSQL ="", whereSQLString="", whereParam=""
	    Set status = $Get(%request.Data("_status",1))
		Set response.meta.status = status
		If status'="" {
			Set $List(whereSQL,*+1) = "(status = ?)"
			Set whereParam($Increment(whereParam))=status
		}
	    Set completionTimeFrom = $Get(%request.Data("_completion_time_from",1))
		Set response.meta."completion_time_from" = completionTimeFrom
		If completionTimeFrom'="" {
			// The UI will always send the user's selected value with a timestamp and converted to UTC
			Set $List(whereSQL,*+1) = "( completionTime >= ? )"
			Set whereParam($Increment(whereParam))=completionTimeFrom
		}
	    Set completionTimeTo = $Get(%request.Data("_completion_time_to",1))
		Set response.meta."completion_time_to" = completionTimeTo
		If completionTimeTo'="" {
			// The UI will always send the user's selected value with a timestamp and converted to UTC
			Set $List(whereSQL,*+1) = "( completionTime <= ? )"
			Set whereParam($Increment(whereParam))=completionTimeTo
		}
	    Set isActive = $Get(%request.Data("_active",1))
		Set response.meta.active = isActive
		If isActive'="" {
			If 1=isActive {
				Set $List(whereSQL,*+1) = "status IN ('in-progress','pending', 'error')"
			} Else {
				Set $List(whereSQL,*+1) = "status NOT IN ('in-progress','pending', 'error')"
			}
		}
		// Restrict results to sessions that have not been purged
		Set $List(whereSQL,*+1) = "( Purged = ? )"
		Set whereParam($Increment(whereParam)) = 0
		// If UI requested to filter by username AND the user has privileges to view other users' exports add the requested username clause to the query
		// If the user does not have privileges to view other users' exports, restrict results to just their own 
	    Set username = $Get(%request.Data("_username",1))
		// Check if user can view other's exports
		If '$SYSTEM.Security.Check("%HS_BFC_Export_Manage","USE") {
			Set username=$UserName
			Set response.meta."username" = username
		}
		Set username = $zcvt(username,"U")
		If username'="" {
			Set $List(whereSQL,*+1) = "( client = ? )"
			Set whereParam($Increment(whereParam))=username
		}
		Set:whereSQL'="" whereSQLString = "where "_$ListToString(whereSQL," AND ")
		
		Set tSql = "select top 1001 * from HS_BulkFHIR.Session "_whereSQLString_" order by ID desc"
		Set tcStatement = ##class(%SQL.Statement).%New()
		Set tcStatus = tcStatement.%Prepare(tSql)
		If ($$$ISOK(tcStatus)) { 
			Set tcResult = tcStatement.%Execute(whereParam...)
			If (tcResult.%SQLCODE=0) {
				Set response.meta."has_more_data" = 0
				While tcResult.%Next() {
					If tcResult.%ROWCOUNT>1000 {
						Set response.meta."has_more_data" = 1
						Quit
					}
					Set tSessionInfo = {
						"ID" : (tcResult.ID),
						"username" : (tcResult.client),
						"completionTime" : (tcResult.completionTime),
						"errorCount" : (+tcResult.errorCount),
						"expiresTime" : (tcResult.expiresTime),
						"exportSize" : (+tcResult.exportSize),
						"purged" : (tcResult.purged),
						"requestTime" : (tcResult.requestTime),
						"requestUrl" : (tcResult.requestUrl),
						"sessionId" : (tcResult.ID),
						"sinceSeconds" : (tcResult.sinceSeconds),
						"status" : (tcResult.status),
						"transactionTime" : (tcResult.transactionTime),
						"transactionTimeSeconds" : (tcResult.transactionTimeSeconds),
						"request_Prefer" : (tcResult."request_Prefer"),
						"request_RequestMethod" : (tcResult."request_RequestMethod"),
						"request_RequestPath" : (tcResult."request_RequestPath"),
						"request_SessionApplication" : (tcResult."request_SessionApplication"),
						"request_TimestampUTC" : (tcResult."request_TimestampUTC"),
						"resourceCount" : (+tcResult.resourceCount)
					}
					If tcResult.terminatedReason'="",$$$ISERR(tcResult.terminatedReason) {
						Set tSessionInfo.terminatedReason = $zcvt($system.Status.GetErrorText(tcResult.terminatedReason),"O","UTF8")
					} Else {
						Set tSessionInfo.terminatedReason = tcResult.terminatedReason
					}
					
					Set tSessionInfo."group_id" = ""
					Set:"Group"=$p(tcResult."request_RequestPath","/",1) tSessionInfo."group_id" = $p(tcResult."request_RequestPath","/",2)
										
					Set nsConfig = {}.%FromJSON(tcResult.config)
					Do nsConfig.%Remove("capability_statement")
					Set tSessionInfo.config = {}
					Set tSessionInfo.config.name = nsConfig.name
					Do response.sessions.%Push(tSessionInfo)
				}
			}
		}
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	Quit ..Response(response,responseSC)
}

/// Handler for GET /file
/// Returns an exported file content via Storage Adapter
ClassMethod GetFile(pSessionId As %String, pFileName As %String) As %Status
{
    Set response = {}
    Set responseSC = $$$OK
	Try {
		Set session = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId)
		set config = session.configuration
		Set class = $$$BFCStorageClass(config)
		Set stream = $classmethod(class,"GetFile",session,pFileName)
		If stream.Size = 0 {
			Set %response.Status = 404
			Return $$$OK
		}
		Set %response.ContentType = "application/fhir+ndjson"
		While 'stream.AtEnd {
			Write stream.Read()
		}
	} Catch ex {
		Set responseSC = ex.AsStatus()
		Do ..Response(response,responseSC)
	}
	Quit $$$OK
}

/// Returns information about current namespace
ClassMethod GetJSONMetadata() As %Library.DynamicObject
{
	Set response = {}
	Set response.endpoints = []

	Set sql = "select Name, BFCEndpoint from HS_BulkFHIR.Configuration"
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatus = tStatement.%Prepare(sql)
	If ($$$ISOK(tStatus)) { 
		Set tResult = tStatement.%Execute()
		If (tResult.%SQLCODE=0) {
			While tResult.%Next() {
				Set bfconfig = {
					"name": (tResult.Name),
					"endpoint_url": (tResult.BFCEndpoint)
					}
				Do response.endpoints.%Push(bfconfig)
			}
		}
	}
	

	Set response.credentials = ..GetCredentials()
	Set response."fetch_adapters" = ..GetAdapters("HS.BulkFHIR.API.FetchAdapter")
	Set response."auth_adapters" = ..GetAdapters("HS.BulkFHIR.API.AuthAdapter")
	Set response."storage_adapters" = ..GetAdapters("HS.BulkFHIR.API.StorageAdapter")
	Quit response
}

/// Returns a list of configured Bulk FHIR controllers in the namespace
ClassMethod GetJSONConfigs() As %Library.DynamicObject
{
	Set response = {}
	Set Foundation = ##class(HS.Util.Installer.ConfigItem).%OpenId($namespace)
	Quit:'$isobject(Foundation) response
	Set response.foundation = {
		"name": (Foundation.Name),
		"created_at": (Foundation.CreatedAt),
		"last_activated": (Foundation.LastActivated)
	}		
	Set response.configs = []
	Set sql = "select Name, BFCEndpoint, Configuration from HS_BulkFHIR.Configuration"
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatus = tStatement.%Prepare(sql)
	If ($$$ISOK(tStatus)) { 
		Set tResult = tStatement.%Execute()
		If (tResult.%SQLCODE=0) {
			While tResult.%Next() {
				Set bfconfig = ..GetJSONConfig(tResult.BFCEndpoint)
				If (bfconfig=$$$NULLOREF) {
					Continue
				}
				Do response.configs.%Push(bfconfig)
			}
		}
	}
	Quit response
}

/// Returns information about configured credentials in the current namespace
ClassMethod GetCredentials() As %Library.DynamicObject
{
	Set response = []
	Set csql = "select ID, Username from Ens_Config.Credentials"
	Set tcStatement = ##class(%SQL.Statement).%New()
	Set tcStatus = tcStatement.%Prepare(csql)
	If ($$$ISOK(tcStatus)) { 
		Set tcResult = tcStatement.%Execute()
		If (tcResult.%SQLCODE=0) {
			While tcResult.%Next() {
				Set tCredentialInfo = {
					"id" : (tcResult.ID),
					"username" : (tcResult.Username)
				}
				Do response.%Push(tCredentialInfo)
			}
		}
	}
	Quit response
}

/// Returns information about configured Bulk FHIR adapters in the current namespace
ClassMethod GetAdapters(pAdapterClassName) As %Library.DynamicObject
{
	Set response = []
	Set rs = ##class(%ResultSet).%New("%ClassDefinition:SubclassOf")
	Do rs.%Execute(pAdapterClassName)
	While rs.%Next() {
		Set name = rs.Name
		Set tAdapterInfo = {
			"id" : (name)
		}
		Set tAdapterInfo.properties = ..GetAdapterProperties(name)
		Do response.%Push(tAdapterInfo)
	}
	Quit response
}

/// Returns information about properties of a particular configured Bulk FHIR adapters
ClassMethod GetAdapterProperties(pAdapterName) As %Library.DynamicObject
{
	Set response = []
	Set tConfigClass = pAdapterName
	Set $p(tConfigClass,".",*) = "Config"
	Set tempSettings = $PARAMETER(tConfigClass,"SETTINGS")
	Set settings = ""
	For idx = 1:1:$length(tempSettings,",") {
		Set item = $piece(tempSettings,",",idx)
		Set property = $piece(item,":")
		If property '= "" {
			If $Extract(property)'="-" {
				Set settings(property)=item
				Set $List(settings,*+1) = $piece(item,":")
			} Else {
				Set settings($extract(property,2,*))=item
			}
		}
	}
	Set instance = $classMethod(tConfigClass,"%New")
	Set sql = "select Name, Description, Required, Type, Collection from %Dictionary.CompiledProperty "
		_" where parent = ? and Internal = 0 order by origin, sequencenumber"
	Set tStatement = ##class(%SQL.Statement).%New()
	Set tStatus = tStatement.%Prepare(sql)
	$$$ThrowOnError(tStatus)
	Set tResult = tStatement.%Execute(tConfigClass)
	If tResult.%SQLCODE'=0 {
		$$$ThrowOnError($$$ERROR($$$SQLError, tResult.%SQLCODE, tResult.%Message))
	}
	While tResult.%Next() {
		If '$Data(settings(tResult.Name),item) {
			Set item = "" ; otherwise SETTINGS info from previously item will be used for this setting
			Set $List(settings,*+1) = tResult.Name
			Set settings(tResult.Name)=tResult.Name
		} ElseIf $Extract(item)="-" {
			Continue
		}
		Set displayName = $piece(item,":",4)
		If displayName = "" {
			Set displayName = $Translate(tResult.Name,"_"," ")
			Set pos = 1
			For {
				Set $extract(displayName,pos)=$zcvt($extract(displayName,pos),"U")
				Set pos = $find(displayName," ",pos)
				If pos = 0 {
					Quit
				}
			}
		}
		Set default = $property(instance,tResult.Name)  /* originally using initial expression from the query but ssl_configuration came out as $$$BFCBaseSSLConfig not BFC_SSL*/
		If tResult.Collection'="" {
			Set idx=""
			Set collection = default
			Set default = ""
			For {
				Set value = collection.GetNext(.idx)
				If idx="" { Quit }
				Set default = default _ "," _ value
			}
			Set default = $Extract(default,2,*)
		}
		Set tPropInfo = {
			"name": (tResult.Name),
			"required": (tResult.Required),
			"description": (tResult.Description),
			"type": (tResult.Type),
			"collection": (tResult.Collection'=""),
			"default": (default),
			"group": ($p(item,":",2)),
			"category": ($p(item,":",3)),
			"displayName": (displayName)
		}
		Set properties(tResult.Name) = tPropInfo
	}
	/// order properties first based on Settings if it exists or by order of properties
	Set ptr=0
	While $listNext(settings,ptr,item) {
		If '$Data(properties(item),tPropInfo) {
			continue
		}
		Do response.%Push(tPropInfo)
	}
	Quit response
}

/// Returns information about a particular Bulk FHIR controller without capability_statement
ClassMethod GetJSONConfig(pBFCEndpointName) As %Library.DynamicObject
{
	Set response = $$$NULLOREF
	Set conf = ##class(HS.BulkFHIR.Configuration).GetConfiguration(pBFCEndpointName)
	
	If ($SYSTEM.Security.Check("%HS_BFC_Configuration","WRITE") || $SYSTEM.Security.Check("%HS_BFC_Export_Manage","USE")) {
		Set authorized = 1
	} Else {
		// Do not return the configuration if this user is not authorized to configure or use it
		Set authorized = 0
		If $IsObject(conf."authorized_users") {
			Set pos = ""
			For {
				If ($ZCVT(conf."authorized_users".GetNext(.pos),"U") = $ZCVT($Username,"U")) {
					Set authorized = 1
					Quit
				} ElseIf (pos = "") {
					Quit
				}
			}
		}
	}
	
	If authorized {
		Do conf.%JSONExportToString(.confJSON)
		Set response = {}.%FromJSON(confJSON)
		Do response.%Remove("capability_statement")
	}
	Quit response
}

/// Handler for POST /configs
/// Creates a new Bulk FHIR configuration
ClassMethod PostConfig() As %Status
{
	#dim %request As %CSP.Request
	#dim ex As %Exception.StatusException

    Set response = {}
    Set responseSC = $$$OK

	Try {
		Do ##class(HS.BulkFHIR.Util.Security).CheckResource("%HS_BFC_Configuration","WRITE") 
		Set response = {}
		Set response."extra_config" = {}

		If $isobject(%request.Content) && '(%request.Content.%IsA("%Library.DynamicObject")) {
			Set %request.Content = {}.%FromJSON(%request.Content)
		}

		If (%request.ContentType '= ..#CONTENTTYPEJSON) {
			$$$ThrowOnError($$$ERROR($$$HTTPStatus406NotAcceptable,"Content Type must be "_..#CONTENTTYPEJSON))
		}

		Set config = %request.Content."extra_config"
		Set:config="" config = {}
		Set bulkfhirConfig = %request.Content."bulkfhir_config"
		// Configure
		Set response."bulkfhir_config" = bulkfhirConfig
		Do ##class(HS.BulkFHIR.Installer).Configure(bulkfhirConfig)
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	Quit ..Response(response,responseSC)
}

/// Handler for POST /sessions
/// Creates a new Bulk FHIR session
ClassMethod PostSession() As %Status
{
	#dim %request As %CSP.Request

    Set response = {}
    Set responseSC = $$$OK

	Try {

		If $isobject(%request.Content) && '(%request.Content.%IsA("%Library.DynamicObject")) {
			Set %request.Content = {}.%FromJSON(%request.Content)
		}

		If (%request.ContentType '= ..#CONTENTTYPEJSON) {
			$$$ThrowOnError($$$ERROR($$$HTTPStatus406NotAcceptable,"Content Type must be "_..#CONTENTTYPEJSON))
		}

		Set request = ##class(HS.FHIRServer.API.Data.Request).%New()
		// %request.Content."endpoint_url" is the url of the BFC endpoint. The unconditional
		// use of that item here is intended to help provide a mimic of an external REST
		// client sending a request in over HTTP. Otherwise, the path would be something
		// like "/csp/healthshare/bulkfhir/bulkfhir/api/session" (as an example).
		Set request.BaseURL = ..GetRequestHost(%request)_%request.Content."endpoint_url"
		Set request.Prefer = "respond-async"
		Do request.AdditionalInfo.SetAt(1, "export task started from api")
		Set request.RequestMethod = "GET"
		Set request.SessionApplication = %request.Content."endpoint_url"

		If %request.Content.type="System" {
			Set request.RequestPath = "$export"
		} ElseIf %request.Content.type="Patient" {
			Set request.RequestPath = "Patient/$export"
		} ElseIf %request.Content.type="Group" {
			Set groupId = $s(%request.Content."group_id"="":%request.Content."groupId",1:%request.Content."group_id")
			Set request.RequestPath = "Group/"_groupId_"/$export"
		} Else {
			$$$ThrowOnError($$$ERROR($$$HTTPStatus400BadRequest,"Only System, Patient and Group types supported"))
		}

		If %request.Content.since'="" {
			// This value is local time.  The FHIR Service deals with converting to UTC
			If $l(%request.Content.since," ") > 1 {
				Set request.QueryString = "_since="_$zcvt($p(%request.Content.since," ",1)_"T"_$p(%request.Content.since," ",2)_"Z","O","URL")
			} else {
				Set request.QueryString = "_since="_$zcvt(%request.Content.since_"T00:00:00Z","O","URL")
			}
		}
		Set tFhirResponse = ##class(HS.FHIRServer.API.Data.Response).%New()
	 	// Start export session
	 	Do ##class(HS.BulkFHIR.Service).Operation(request, .tFhirResponse)
		Set response.id = $p(tFhirResponse.ContentLocation,"/",*)
		Set response.status = tFhirResponse.Status
		Set response.contentLocation = tFhirResponse.ContentLocation
		Set response.json = tFhirResponse.Json
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	Quit ..Response(response,responseSC)
}

/// Handler for GET /logs
/// Returns a list of Bulk FHIR logs in the namespace
ClassMethod GetSessionsLog() As %Status
{
	#dim %request As %CSP.Request
    Set response = {}
    Set response.meta = {}
    Set responseSC = $$$OK
	Set response.log = []
	Set whereSQL="", whereParam=""
	Try {
		Do ##class(HS.BulkFHIR.Util.Security).CheckResource("%HS_BFC_Export_Log","READ")

		// Create where clause if filter values were specified on the Log table
	    Set logId = $Get(%request.Data("_id",1))
		If logId'="" {
			Set whereSQL = whereSQL_" AND ( Log.%ID=? )"
			Set whereParam($Increment(whereParam))=logId
		}
	    Set sessionId = $Get(%request.Data("_sessionId",1))
		If sessionId'="" {
			Set whereSQL = whereSQL_" AND ( Session.ID=? )"
			Set whereParam($Increment(whereParam))=sessionId
		}
		For filterOption = "component","type","severity","status" {
		    Set filterValue = $Get(%request.Data("_"_filterOption,1))
			If filterValue'="" {
				Set whereSQL = whereSQL_" AND ( "_filterOption_"=? )"
				Set whereParam($Increment(whereParam))=filterValue
			}
		}
	    Set endpoint = $Get(%request.Data("_endpoint_url",1))
		If endpoint'="" {
			Set whereSQL = whereSQL_" AND ( Session.request_SessionApplication=? )"
			Set whereParam($Increment(whereParam))=endpoint
		}
	    Set requestPath = $Get(%request.Data("_request_path",1))
		If requestPath'="" {
			Set whereSQL = whereSQL_" AND ( Session.request_RequestPath=? )"
			Set whereParam($Increment(whereParam))=requestPath
		}
		Set errorText = $G(%request.Data("_error",1))
		If errorText'="" {
			// There won't be an error message if the severity is info
			// so we can filter out non-errors in the query, and then check the actual text in the results
			Set whereSQL = whereSQL_" AND ( severity > ?)"
			Set whereParam($Increment(whereParam))=$$$LogLevelInfo
		}
		Set lastModifiedFrom = $Get(%request.Data("_last_modified_from",1))
		If lastModifiedFrom'="" {
			// The UI will always send the user's selected value with a timestamp and converted to UTC
			Set whereSQL = whereSQL_" AND ( %LastModified >= ? )"
			Set whereParam($Increment(whereParam))=lastModifiedFrom
		}
	    Set lastModifiedTo = $Get(%request.Data("_last_modified_to",1))
		If lastModifiedTo'="" {
			// The UI will always send the user's selected value with a timestamp and converted to UTC
			Set whereSQL = whereSQL_" AND ( %LastModified <= ? )"
			Set whereParam($Increment(whereParam))=lastModifiedTo
		}
		Set client = $Get(%request.Data("_client",1))
		// Check if user can view other's exports.  If not, limit to self even if request is for other clients
		If '$SYSTEM.Security.Check("%HS_BFC_Log_Manage","USE") {
			Set client=$ZCVT($UserName,"U")
			Set response.meta."username" = client
		}
		If client'="" {
			Set whereSQL = whereSQL_" AND ( client=? )"
			Set whereParam($Increment(whereParam))=client
		}

		// Remove " AND " from the beginning of current whereSQL value
		Set:whereSQL'="" whereSQL = " where"_$Piece(whereSQL,"AND",2,*)

		Set tSql = "select top 1001 Log.ID As ID, Log.%Doc, Log.%LastModified, Log.severity, Session.client, Session.status, Session.request_RequestPath As request_path, Session.request_SessionApplication As endpoint_url from HS_BulkFHIR.Log LEFT JOIN HS_BulkFHIR.Session ON Log.sessionId = Session.ID"_whereSQL_" order by ID desc"
		Set tStatement = ##class(%SQL.Statement).%New()
		Set tStatus = tStatement.%Prepare(tSql)
		If ($$$ISOK(tStatus)) { 
			Set tResult = tStatement.%Execute(whereParam...)
			If (tResult.%SQLCODE=0) {
				Set response.meta."has_more_data" = 0
				While tResult.%Next() {
					If tResult.%ROWCOUNT>1000 {
						Set response.meta."has_more_data" = 1
						Continue
					}
					Set doc = {}.%FromJSON(tResult.%Doc)
					Set log = {
						"id": (+tResult.ID),
						"doc": (doc),
						"lastModified": (tResult.%LastModified),
						"severity": ($Case(tResult.severity,$$$LogLevelInfo:"Information",$$$LogLevelWarning:"Warning",$$$LogLevelError:"Error",:"")),
						"endpoint_url" : (tResult."endpoint_url"),
						"status" : (tResult.status),
						"request_path" : (tResult."request_path"),
						"client" : (tResult.client)
					}
					If tResult.severity > $$$LogLevelInfo {
						Set log.error = doc.reason
					}
					// If filtering on error text, skip logs that do not contain the specified text
					If (errorText'="") && (log.error '[ errorText) {
						Continue
					}
					Do response.log.%Push(log)
				}
			}
		}	
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	Quit ..Response(response,responseSC)
}

/// Handler for GET /logoptions
/// Returns a list of distinct values appearing for the specified property in Bulk FHIR logs in the namespace
ClassMethod GetLogFilterOptions() As %Status
{
	#dim %request As %CSP.Request
	#dim property As %String
	#dim result As %SQL.StatementResult
    Set response = {}
    Set options = []
    #dim responseSC As %Status = $$$OK
	Try {
		Do ##class(HS.BulkFHIR.Util.Security).CheckResource("%HS_BFC_Export_Log","READ")
		Set limited = '$SYSTEM.Security.Check("%HS_BFC_Log_Manage","USE")
		Set property = $G(%request.Data("_property",1))
		If property'="" {
			If $case(property,"component":1,"type":1,:0) {
				Set tSql = "select distinct "_property_" from HS_BulkFHIR.Log"
				If limited {
					set tSql = tSql_" inner join HS_BulkFHIR.Session on Log.sessionId=Session.ID where client=?"
				}
				Set tSql = tSql_" order by "_property_" asc"
				Set statement = ##class(%SQL.Statement).%New()
				Set responseSC = statement.%Prepare(tSql)
				If ($$$ISOK(responseSC)) { 
					Set result = $Select(limited: statement.%Execute($UserName),1:statement.%Execute())
					If result.%SQLCODE'=0 {
						Set responseSC = $$$ERROR($$$SQLError, result.%SQLCODE, result.%Message)
						Quit
					}
					While result.%Next() {
						Do options.%Push($property(result,property))
					}
					Set $Property(response,property) = options
				}
			} ElseIf (property = "severity") {
				Set options = {}
				Set $Property(options,$$$LogLevelInfo) = "Information"
				Set $Property(options,$$$LogLevelWarning) = "Warning"
				Set $Property(options,$$$LogLevelError) = "Error"
				set $Property(response,property) = options
			} Else {
				Set sqlProp = $Case(property,"client":"client","endpoint_url":"request_SessionApplication","request_path":"request_RequestPath","status":"status","user":"client",:"")
				If ""'=sqlProp {
					Set tSql = "select distinct "_sqlProp_" As "_property_" from HS_BulkFHIR.Session"
					If limited {
						Set tSql = tSql_" where client=?"
					}
					Set tSql = tSql_" order by "_property_" asc"
					Set statement = ##class(%SQL.Statement).%New()
					Set responseSC = statement.%Prepare(tSql)
					If ($$$ISOK(responseSC)) { 
						Set result = $Select(limited: statement.%Execute($UserName),1:statement.%Execute())
						If result.%SQLCODE'=0 {
							Set responseSC = $$$ERROR($$$SQLError, result.%SQLCODE, result.%Message)
							Quit
						}
						While result.%Next() {
							Do options.%Push($property(result,property))
						}
						Set $Property(response,property) = options
					}
				}
			}
		}	
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	
	Quit ..Response(response,responseSC)
}

/// Handler for GET /session/:sessionId/:action
/// Perform specific action for Bulk FHIR session
ClassMethod SessionAction(pSessionId, pAction) As %Status
{
	#dim %request As %CSP.Request

    Set response = {}
    Set responseSC = $$$OK

	Try {
		If pAction = "pause" {
			Do ##class(HS.BulkFHIR.Service).Pause(pSessionId)
		} ElseIf pAction = "cancel" {
			Do ##class(HS.BulkFHIR.Service).Cancel(pSessionId)
		} ElseIf pAction = "resume" {
			Do ##class(HS.BulkFHIR.Service).Resume(pSessionId)
		} ElseIf pAction = "status" {
			// Pass the full base url (scheme, host, port, url), as specified by the REST client, to Status().
			Set baseUrl = ##class(HS.Local.BulkFHIR.Util.BaseURL).GetBaseURL(%request)
			Do ##class(HS.BulkFHIR.Service).Status(pSessionId, baseUrl, .status, .retryAfter, .expires, .json, .httpStatus)
			
			Set response.status = status
			Set response.retryAfter = retryAfter
			Set response.expires = expires
			Set response.json = json
			Set response.httpStatus = httpStatus
			Set response.user = ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId).client

		} ElseIf pAction = "getConfig" {
			// get BulkFHIR configuration at time session started
			Set response.config =  ##class(HS.BulkFHIR.Session).getBySessionId(pSessionId).config
		}
		Set response.status = 1
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	Quit ..Response(response,responseSC)
}

/// Handler for DELETE /config?_config:name
/// Delete Bulk FHIR config
ClassMethod DeleteConfig() As %Status
{
	#dim %request As %CSP.Request

    Set response = {}
    Set responseSC = $$$OK

	Try {
		Set configName = $Get(%request.Data("_config",1))
		Do ##class(HS.BulkFHIR.Installer).Delete(configName)
	} Catch ex {
		Set responseSC = ex.AsStatus()
	}
	Quit ..Response(response,responseSC)
}

}
