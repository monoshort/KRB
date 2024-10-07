Include (HS.FHIRServer, HS.FHIRServer.Util.SearchResult)

Class HS.BulkFHIR.Util.SearchResult Extends HS.Util.TransientTable
{

Parameter GlobalName As %String = "^IRIS.Temp.BulkFHIRSearchResult";

Property ResourceString As %String [ Calculated ];

Property ResourceJson As %DynamicObject [ Calculated ];

Property Bundle As %DynamicObject [ Calculated ];

Property PageSize As %Integer [ Calculated ];

Property QueryId As %String [ Calculated ];

Property Total As %Integer [ Calculated ];

Property Created As %String [ Calculated ];

Property LastUsed As %String [ Calculated ];

Property %Username As %String [ Private ];

Property %PageSize As %Integer [ Private ];

Property %QueryId As %String [ Private ];

Property TimeIndex As %Integer [ Private ];

Property %Total As %Integer [ Private ];

Property %Bundle As %DynamicObject [ Private ];

Property PageStarts [ MultiDimensional, Private ];

Property SearchStatus As %Status;

Property %Created As %String [ Private ];

Property %LastUsed As %String [ Private ];

ClassMethod Create(pPageSize As %Integer = 0, pUsername As %String) As HS.FHIRServer.Util.SearchResult
{
	Set result = ..%New()
	Do result.Init(pPageSize,pUsername)
	return result
}

Method Init(pPageSize As %Integer, pUsername As %String)
{
	// Create the columns for this Result Set and verify that the column
	// numbers match the expected ones.  DEVNOTE: If the column number
	// macros change, we should also change the GlobalName parameter.
	$$$SearchResultAddCol("ResourceString", 1)
		
	Set ..%QueryId = $ZConvert($system.Util.CreateGUID(), "L")
	Set ..%Username = pUsername
	Set ..%PageSize = +pPageSize
	Set ..%Total = 0
	Set ..PageStarts = 0
	set ..SearchStatus = $$$OK
	//Use UTC time
	Set ..%Created = $ZDT($H,3,7)
	Set ..%LastUsed = $ZDT($H,3,7)
	
	return $$$OK
}

Method Reinit(pQueryId As %String)
{
	Set ..%QueryId = pQueryId
	//Throw a FHIR Error if the QueryId no longer exists so we don't return an <UNDEFINED>
	If ('$Data(@..#GlobalName@(pQueryId))) {
		$$$ThrowFHIR($$$HSFHIRErrQueryIdNotFound,pQueryId)
	}
	Set ..TimeIndex = @..#GlobalName@("ByKey", pQueryId)
	Set ..%PageSize = @..#GlobalName@("ByTime", ..TimeIndex, "pagesize")
	Set ..SearchStatus = @..#GlobalName@("ByTime", ..TimeIndex, "status")
	Set ..%Total = @..#GlobalName@("ByTime", ..TimeIndex, "total")
	Set ..%Username = @..#GlobalName@("ByTime", ..TimeIndex, "username")
	Set ..PageStarts = 0
	Merge ..PageStarts = @..#GlobalName@("ByTime", ..TimeIndex, "pageStarts")
	Set ..%Created = @..#GlobalName@("ByTime", ..TimeIndex, "created")
	Set ..%LastUsed = $ZDT($H,3,7)
	Set @..#GlobalName@("ByTime", ..TimeIndex, "lastUsed") = ..%LastUsed
}

ClassMethod Restore(pQueryId As %String) As HS.FHIRServer.Util.SearchResult
{
	Set result = ..%RestoreFrom(..#GlobalName, pQueryId)
	
	Do result.Reinit(pQueryId)
	return result
}

Method GetOriginalUsername() As %List
{
	Return ..%Username
}

ClassMethod Discard(key As %String)
{
	TSTART
	Try {
		Set timeIndex =  $G(@..#GlobalName@("ByKey", key))
		if timeIndex '= "" {
			kill @..#GlobalName@("ByTime",timeIndex)
			kill @..#GlobalName@("ByKey",key)
			kill @..#GlobalName@(key)
		}
		TCOMMIT
	}
	Catch(ex) {
		TROLLBACK 1
		$$$ThrowError(ex.AsStatus())
	}
}

Method Save() As %String
{
	TSTART
	Try {
		Do ..%SaveTo(..#GlobalName, ..%QueryId)
	
		if ..TimeIndex '= "" {
			kill @..#GlobalName@("ByTime", ..TimeIndex)
		}
		
		Set ..TimeIndex = $I(@..#GlobalName@("ByTime"))
		Set @..#GlobalName@("ByKey", ..%QueryId) = ..TimeIndex
		Set @..#GlobalName@("ByTime", ..TimeIndex, "pagesize") = ..%PageSize
		Set @..#GlobalName@("ByTime", ..TimeIndex, "id") = ..%QueryId
		Set @..#GlobalName@("ByTime", ..TimeIndex, "status") = ..SearchStatus
		Set @..#GlobalName@("ByTime", ..TimeIndex, "total") = ..%Total
		Set @..#GlobalName@("ByTime", ..TimeIndex, "username") = ..%Username
		Kill @..#GlobalName@("ByTime", ..TimeIndex, "pageStarts")
		Merge @..#GlobalName@("ByTime", ..TimeIndex, "pageStarts") = ..PageStarts
		Set @..#GlobalName@("ByTime", ..TimeIndex, "created") = ..%Created
		Set @..#GlobalName@("ByTime", ..TimeIndex, "lastUsed") = $ZDT($H,3,7)
		TCOMMIT
	}
	Catch(ex) {
		TROLLBACK 1
		$$$ThrowError(ex.AsStatus())
	}	
	return ..%QueryId
}

Method SetIteratorToPage(pageNum As %Integer)
{
	set iter = 0
	if pageNum > 0 {
		if pageNum > ..PageStarts {
			Set iter = ..%ROWCOUNT
		} else {
			set iter = ..PageStarts(pageNum) - 1
		}
	}
	Do ..%SetIterator(iter)
}

Method Paginate(pPageSize As %Integer = "") As %Integer
{
	kill ..PageStarts
	Set ..PageStarts = 0
		
	// Treat PageSize = 0 as "force one page"
	Set pageSize = $Select(pPageSize="":..%PageSize, 1:pPageSize)
	Set ..%PageSize = pageSize
	if pageSize <= 0 {
		Set ..PageStarts($I(..PageStarts)) = 1
	}
	
	For i=0:1:(..%Total\pageSize)-1 {
		Set ..PageStarts($I(..PageStarts)) = (i*pageSize) + 1
	}
	If ..%Total#pageSize {
		Set ..PageStarts($I(..PageStarts)) = ((i+1)*pageSize) + 1
	}
	
	Do ..%SetIterator(0)
	return ..PageStarts
}

Method AddRow(pJson = "") As %Integer
{
	Set curRow = ..%NewRow()

	if $IsObject(pJson) && pJson.%Extends("%DynamicObject") {
		Do ..%SetData(1, pJson.%ToJSON())
	} else {
		Do ..%SetData(1, pJson)
	}
	$$$ThrowOnError( ..%SaveRow() )
	Set ..%Total = ..%Total + 1
	return curRow
}

Method ResourceJsonGet() As %DynamicObject
{
	Set string = ..%GetData(1)
	if string '= "" {
		return ##class(%DynamicObject).%FromJSON(string)
	}
	return ""
}

Method PageSizeGet() [ CodeMode = expression ]
{
..%PageSize
}

Method TotalGet() [ CodeMode = expression ]
{
..%Total
}

Method QueryIdGet() [ CodeMode = expression ]
{
..%QueryId
}

Method CreatedGet() [ CodeMode = expression ]
{
..%Created
}

Method LastUsedGet() [ CodeMode = expression ]
{
..%LastUsed
}

/// @APIMethod
/// Used to purge expired search results based on the last time
/// they were interacted with e.g. needed to be re-initialized (paging does this)
ClassMethod PurgeCachedResults(pMinutesToKeep As %Integer = 60) As %Status
{
	Set status =  $$$OK
	Try {
		Set timeIndex = ""
		For {
			// Traverse the "ByTime" subscript so we go in order from oldest to newest search results
			Set timeIndex = $Order(@..#GlobalName@("ByTime",timeIndex))
			Quit:timeIndex=""
			Set key = @..#GlobalName@("ByTime",timeIndex,"id")
			Set created = $Get(@..#GlobalName@("ByTime",timeIndex,"created"))
			Set lastUsed = $Get(@..#GlobalName@("ByTime",timeIndex,"lastUsed"))

			// Old style Search Results should be purged
			If ((created = "") || (lastUsed = "")) {
				Do ..Discard(key)
				Continue
			}

			// Quit out if/when we encounter a search result created more recently than MinutesToKeep since all others will also be too new to purge
			If ($SYSTEM.SQL.Functions.DATEDIFF("minute",$ZDTH(created,3,7),$H) <= pMinutesToKeep) {
				Quit
			}

			If ($SYSTEM.SQL.Functions.DATEDIFF("minute",$ZDTH(lastUsed,3,7),$H) > pMinutesToKeep) {
				Do ..Discard(key)
			}
		}
	}
	Catch(ex) {
		Set status = ex.AsStatus()
	}
	Return status
}

}
