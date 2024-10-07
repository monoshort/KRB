Include HS.BulkFHIR

Class HS.BulkFHIR.Session Extends (%Persistent, HS.BulkFHIR.Util)
{

/// backward compatible for UI
Property sessionId As %String [ SqlComputeCode = { Set {*} = {ID} }, SqlComputed, Transient ];

Method sessionIdGet() As %String [ CodeMode = expression ]
{
..%Id()
}

/// Full url containing the request made by the client
Property requestUrl As %String(MAXLEN = 500);

/// Name of the client making the request (username or client id)
Property client As %String(MAXLEN = 300);

/// Status of the operation.
/// "pending" is the initial state and is
/// used when the job has been requested but isn't actively being worked
/// on (either waiting or paused)
/// "in-progress" represents a job that's actively being worked on, and may
/// transition to any of the other statuses (ie. may be paused, may finish, may error out).
/// "complete" is a terminal status representing an export operation that has
/// finished without error
/// "terminated" is a terminal status representing an export operation that was
/// stopped before it could finish, either by client request or by fatal error.
Property status As %String(VALUELIST = ",pending,in-progress,error,complete,terminated,") [ InitialExpression = "pending" ];

/// A collection of url's (stored items) storing the resourceType, count, and size
/// $lb(type, count, size)
/// Similar to the collection of links but a collection of error files, url for the item with type, count and size
/// $lb(type, count, size)
/// The time when the export operation was requested.
Property requestTime As %TimeStamp [ InitialExpression = {$zdt($zts, 3)} ];

/// The time when the export operation first began. This may be different
/// from the time the request was made, if jobs aren't auto-started.
Property transactionTime As %TimeStamp;

/// The time when a session reached a final state (complete, terminated).
Property completionTime As %TimeStamp;

/// The time when a session will be deemed expired and files
/// may be purged
Property expiresTime As %TimeStamp;

/// If the session was terminated before it could be completed,
/// a description (or error text) of why that occurred.
Property terminatedReason As %String(MAXLEN = "");

/// Whether the files for this session have been successfully purged,
/// either due to its early termination or expiration window passing.
Property purged As %Boolean [ InitialExpression = 0 ];

Property request As HS.FHIRServer.API.Data.Request;

/// How many resources are included in this export operation
Property resourceCount As %Integer;

/// How many errors are included in this export operation
Property errorCount As %Integer;

/// How large (in bytes) the contents of the export operation are
Property exportSize As %Integer;

/// calculated property to return parsed configuration
Property configuration As HS.BulkFHIR.API.Data.Config [ Calculated ];

/// "_since" requestUrl parameter value, expressed as number of seconds since $Horolog 0, in UTC time.
Property sinceSeconds As %Decimal [ InitialExpression = 0.0 ];

/// transactionTime, expressed as number of seconds since $Horolog 0, in UTC time.
Property transactionTimeSeconds As %Decimal [ InitialExpression = 0.0 ];

/// configuration converted from %DynamicObject to HS.BulkFHIR.API.Data.Config
Property parsedConfiguration As HS.BulkFHIR.API.Data.Config [ Internal, Private, Transient ];

/// Copy of BulkFHIR configuration at time session started (in dynamic object format)
Property config As %DynamicObject;

Property fileEndpoint As %String(MAXLEN = 512);

/// %DynamicObject of Bulk FHIR endpoint request access token properties to make available for reference during export processing.
Property tokenInfo As %DynamicObject;

/// %DynamicObject of information to be used as part of access token request to the resource server during export processing.
Property fetchTokenInfo As %DynamicObject;

Index fileEndpointIdx On fileEndpoint;

Index statusIdx On (status, requestTime);

Index purgedIdx On (purged, expiresTime);

Index sessionApplicationIdx On request.SessionApplication;

Index clientIdx On client;

/// @API
/// Returns all sessions, optionally filtered by status, sorted by when the request was initially made
ClassMethod GetSessions(status As %String = "", pEndpoint As %String = "", pPurged As %Boolean = "", pFileEndpoint As %String = "") As %ListOfObjects
{
	set sql = "SELECT ID FROM HS_BulkFHIR.Session"
	Set sqlWhere = " WHERE "
	if status '= "" {
		set sql = sql _ $S(sqlWhere="":" AND ",1:sqlWhere) _"status = ?"
		set sqlargs($i(sqlargs)) = status
		Set sqlWhere = ""
	}
	If pEndpoint '="" {
		Set sql = sql _ $S(sqlWhere="":" AND ",1:sqlWhere) _" request_sessionApplication = ?"
		Set sqlargs($i(sqlargs)) = pEndpoint
		Set sqlWhere = ""
	}
	If pPurged '="" {
		Set sql = sql _ $S(sqlWhere="":" AND ",1:sqlWhere) _" Purged = ?"
		Set sqlargs($i(sqlargs)) = pPurged
		Set sqlWhere = ""
	}
	If pFileEndpoint '="" {
		Set sql = sql _ $S(sqlWhere="":" AND ",1:sqlWhere) _" fileEndpoint = ?"
		Set sqlargs($i(sqlargs)) = pFileEndpoint
		Set sqlWhere = ""
	}
	set sql = sql _ " ORDER BY requestTime DESC"
	
	set statement = ##class(%SQL.Statement).%New()
	set tSC = statement.%Prepare(sql)
	$$$ThrowOnError(tSC)
	set result = statement.%Execute(sqlargs...)
	
	set list = ##class(%ListOfObjects).%New()	
	while result.%Next(.sc) {
		$$$ThrowOnError(sc)
		
		do list.Insert(..%OpenId(result.ID,,.sc))
		$$$ThrowOnError(sc)
	}
	$$$ThrowOnError(sc)
	
	return list
}

/// @API
/// Returns all sessions, optionally filtered by status, sorted by when the request was initially made
ClassMethod GetExpiredSessions() As %ListOfObjects
{
	set sql = "SELECT ID FROM HS_BulkFHIR.Session WHERE status NOT IN (?,?,?) AND expiresTime < ? AND purged = 0"
	
	set statement = ##class(%SQL.Statement).%New()
	set tSC = statement.%Prepare(sql)
	$$$ThrowOnError(tSC)
	set result = statement.%Execute("in-progress","pending", "error", $zdt($zts, 3))
	
	set list = ##class(%ListOfObjects).%New()	
	while result.%Next(.sc) {
		$$$ThrowOnError(sc)
		
		do list.Insert(..%OpenId(result.ID,,.sc))
		$$$ThrowOnError(sc)
	}
	$$$ThrowOnError(sc)
	
	return list
}

ClassMethod getBySessionId(pSessionId As %String) As HS.BulkFHIR.Session
{
	set session = ##class(HS.BulkFHIR.Session).%OpenId(pSessionId,0,.sc)
	If $$$ISERR(sc) {
		If $system.Status.GetErrorCodes(sc) [ $$$LoadObjectNotFound {
			$$$ThrowFHIR($$$HSFHIRErrInvalidId, pSessionId, $$$OutcomeInvalid(404))
		}
		$$$ThrowOnError(sc)
	}
	return session
}

Method configurationGet() As HS.BulkFHIR.API.Data.Config
{
	If i%parsedConfiguration = "" {
		Set i%parsedConfiguration = ##class(HS.BulkFHIR.API.Data.Config).FromJson(..config)
	}
	Quit i%parsedConfiguration
}

Method Start()
{
	if (..status = "complete") || (..status = "terminated") {
		$$$ThrowFHIR($$$HSBFCErrSessionAlreadyComplete, ..sessionId)
	}
	elseif (..status = "in-progress") {
		$$$ThrowFHIR($$$HSBFCErrSessionAlreadyInProgress, ..sessionId)
	}
	set ..status = "in-progress"
	if ..transactionTime = "" { //Transaction time shouldn't be reset if it was paused and restarted
		set ..transactionTime = $zdt($zts, 3)
		set ..transactionTimeSeconds = ..ConvertInstantToUTCSecs($ZDateTime($ZDateTimeH(..transactionTime, 3, 7), 3, 7))
	}
	Set ..fileEndpoint = ..configuration."storage_config"."file_url"
	/// ensure session working directory exists
	Set path = ##class(%Library.File).NormalizeDirectory(..configuration."working_directory"_"/"_..sessionId)
	If '##class(%Library.File).CreateDirectoryChain(path) {
		$$$ThrowFHIR($$$HSBFCErrUnableToCreateDirectoryChain,path)
	}
	$$$ThrowOnError(..%Save())
}

Method Complete(expiresAfterMins As %Integer)
{
	if (..status = "complete") || (..status = "terminated") {
		$$$ThrowFHIR($$$HSBFCErrSessionAlreadyComplete, ..sessionId)
	}
	set ..status = "complete"
	set ..completionTime = $zdt($zts, 3)
	set ..expiresTime = $system.SQL.Functions.DATEADD("minute", expiresAfterMins, ..completionTime)

	Set id = ..%Id()
	&sql(select sum("count"), sum("size") into :count,:size from HS_BulkFHIR_Session.Link where Session = :id AND type<>'error')
	If 'SQLCODE {
		Set ..resourceCount = count
		Set ..exportSize = size
	}

	&sql(select sum("count") into :count from HS_BulkFHIR_Session.Link where Session = :id and type='error')
	If 'SQLCODE {
		Set ..errorCount = count
	}
	$$$ThrowOnError(..%Save())
}

Method Pause()
{
	if (..status = "complete") || (..status = "terminated") {
		$$$ThrowFHIR($$$HSBFCErrSessionAlreadyComplete, ..sessionId)
	}
	set ..status = "pending"
	$$$ThrowOnError(..%Save())
}

Method Terminate(reason As %Status, expiresAfterMins)
{
	if (..status = "complete") || (..status = "terminated") {
		$$$ThrowFHIR($$$HSBFCErrSessionAlreadyComplete, ..sessionId)
	}
	set ..status = "terminated"
	set ..terminatedReason = reason
	set ..completionTime = $zdt($zts, 3)
	set ..expiresTime = $system.SQL.Functions.DATEADD("minute", expiresAfterMins, ..completionTime)
	$$$ThrowOnError(..SafeSave())
}

/// if we don't remove the paramters we end up with a <LIST>%GetSerial+1^%Library.ListOfObjects.1
Method SafeSave() As %Status
{
	Set ..request.Parameters=""
	Quit ..%Save()
}

/// Using the specified full base url, plus current session object properties,
/// generate and return the "status Complete" response content object.
Method ToJsonOutput(pBaseUrl As %String = "") As %DynamicObject
{
	set json = {
		"transactionTime": ($zdt($zdth(..transactionTime, 3, 7), 3, 7)),
		"request": (..requestUrl),
		"output":[],
		"error":[]
	}
	do json.%Set("requiresAccessToken", ($parameter(..configuration."auth_adapter", "IsOAuth") && $classmethod(..configuration."storage_adapter", "UsesAuthAdapter")), "boolean")

	Set id = ..%Id()
	&sql(DECLARE curLinks CURSOR FOR SELECT type,url into :type,:url FROM HS_BULKFHIR_Session.Link Where Session = :id order by Type)
	&sql(OPEN curLinks)
	// These links are for the retrievable export files. When an HTTP proxy
	// is involved, this method is assuming that the same proxy through which
	// the $export and status calls came in is the same proxy through which
	// they will be retrieving the files. The host and port can be affected
	// by the HTTP headers, but the url part is defined by the BFC storage
	// definition, and remains as is. If different logic is required, then
	// ..GetURLForLink can be customized by editing HS.Local.BulkFHIR.Util.BaseURL.
	For {
		&SQL(FETCH curLinks)
		QUIT:SQLCODE
		If type = "error" {
			do json.error.%Push({
				"type": ("OperationalOutcome"),
				"url": (##class(HS.Local.BulkFHIR.Util.BaseURL).GetURLForLink(url, pBaseUrl, %request))
			})
		} Else {
			do json.output.%Push({
				"type": (type),
				"url": (##class(HS.Local.BulkFHIR.Util.BaseURL).GetURLForLink(url, pBaseUrl, %request))
			})
		}

	}
	&SQL(CLOSE curLinks)

	return json
}

/// Utility to indicate a patient id was accessed in this export operation
/// This utility calls a SQL stored procedure to file the data (so that the permissions can be granted to UnknownUser)
ClassMethod LinkPatient(pSession As HS.BulkFHIR.Session, pPatientId As %String)
{
	Set id = pSession.%Id()
	If pPatientId = "" {
		$$$ThrowFHIR($$$HSBFCErrSessionPatientIdRequired)
	}
	&sql(SELECT ID FROM HS_BulkFHIR_Session.PatientId WHERE Session = :id AND patientid=:pPatientId)
	$$$ThrowSQLIfError(SQLCODE,%msg)
	If SQLCODE=100 {
		&sql(INSERT INTO HS_BulkFHIR_Session.PatientId Set Session = :id, patientid=:pPatientId)
		$$$ThrowSQLIfError(SQLCODE,%msg)
	}
}

Storage Default
{
<Data name="SessionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>sessionId</Value>
</Value>
<Value name="3">
<Value>requestUrl</Value>
</Value>
<Value name="4">
<Value>client</Value>
</Value>
<Value name="5">
<Value>status</Value>
</Value>
<Value name="6">
<Value>requestTime</Value>
</Value>
<Value name="7">
<Value>transactionTime</Value>
</Value>
<Value name="8">
<Value>completionTime</Value>
</Value>
<Value name="9">
<Value>expiresTime</Value>
</Value>
<Value name="10">
<Value>terminatedReason</Value>
</Value>
<Value name="11">
<Value>purged</Value>
</Value>
<Value name="12">
<Value>request</Value>
</Value>
<Value name="13">
<Value>resourceCount</Value>
</Value>
<Value name="14">
<Value>errorCount</Value>
</Value>
<Value name="15">
<Value>exportSize</Value>
</Value>
<Value name="16">
<Value>sinceSeconds</Value>
</Value>
<Value name="17">
<Value>transactionTimeSeconds</Value>
</Value>
<Value name="18">
<Value>fileEndpoint</Value>
</Value>
</Data>
<Data name="config">
<Attribute>config</Attribute>
<Structure>node</Structure>
<Subscript>"config"</Subscript>
</Data>
<Data name="fetchTokenInfo">
<Attribute>fetchTokenInfo</Attribute>
<Structure>node</Structure>
<Subscript>"fetchTokenInfo"</Subscript>
</Data>
<Data name="tokenInfo">
<Attribute>tokenInfo</Attribute>
<Structure>node</Structure>
<Subscript>"tokenInfo"</Subscript>
</Data>
<DataLocation>^HS.BulkFHIR.SessionD</DataLocation>
<DefaultData>SessionDefaultData</DefaultData>
<IdLocation>^HS.BulkFHIR.SessionD</IdLocation>
<IndexLocation>^HS.BulkFHIR.SessionI</IndexLocation>
<StreamLocation>^HS.BulkFHIR.SessionS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
