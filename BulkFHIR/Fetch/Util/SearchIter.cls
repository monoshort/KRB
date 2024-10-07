Include HS.BulkFHIR

/// Iterator class which returns all results of a FHIR search,
/// including paginated results
Class HS.BulkFHIR.Fetch.Util.SearchIter Extends %RegisteredObject
{

Property %iter As %Iterator.Array [ Private ];

Property %fpApi As HS.FHIRPath.API [ Private ];

Property %restClient As HS.BulkFHIR.Fetch.Util.RestClient [ Private ];

Property %baseUrl As %String [ Private ];

Property %nextUrl As %String [ Private ];

/// Locks are based on %session.%Id() and %grouping
Property %sessionId As %String [ Private ];

/// Locks are based on %session.%Id() and %grouping
/// if multiple search iterators are used for the same session, the grouping is required to keep them separate
/// the default in %OnNew is "NoGrouping"
Property %grouping As %String [ Private ];

/// For system export we'd like to know if there are resources before launching background jobs (we only validate total = 0 as truly none)
Property %total As %Integer [ Private ];

/// if there is no bundle next link
Property %atEnd As %Boolean [ InitialExpression = 0, Private ];

/// @API
/// Returns the next resource in the query's result set. May make an HTTP request
/// for a subsequent page, if one exists and the iterator is at the end of the
/// current page.
/// @Output resource		next resource in the result set
/// @Output sc			status for fetching the next resource
/// @Returns a boolean indicating whether the iterator is complete (1 - continue, 0 - complete or error)
Method Next(Output resource As %DynamicObject, Output sc As %Status) As %Boolean
{
	set sc = $$$OK
	if ..%iter.%GetNext(,.resource) {
		return 1
	}
	else {
		try {
			set lockManager = ##class(%ZHSLIB.LockManager).%New()
			$$$ThrowOnError(lockManager.Lock($name($$$BFCSearchIterator(..%sessionId,..%grouping)),, 900)) 
			Set url = $G($$$BFCSearchIterator(..%sessionId,..%grouping))
			If url]"" {
				Kill $$$BFCSearchIterator(..%sessionId,..%grouping)
				Do ..GetBundle(url)
				return ..Next(.resource, .sc)
			}
		} catch ex {
			set sc = ex.AsStatus()
		}
	}
	
	return 0
}

Method GetBundle(pNextUrl As %String) [ Internal, Private ]
{
	#dim restResponse As HS.FHIRServer.API.Data.RestClient.Response = ..%restClient.Get(pNextUrl)
	
	set bundle = {}.%FromJSON(restResponse.Payload)
	if bundle.resourceType '= "Bundle" {
		// if this is a single resource, add it to the iterator and quit
		set ..%total = 1
		set ..%iter = [].%Push(bundle).%GetIterator()
		Quit
	}
	set resources = ..%fpApi.evaluateToJson(bundle, ..%fpApi.parse("Bundle.entry.resource"))
	Set ..%total = bundle.total
	set ..%iter = resources.%GetIterator()
	set next = ..%fpApi.evaluateToJson(bundle, ..%fpApi.parse("Bundle.link.where(relation='next').url"))
	if next.%Size() {
		set fullUrl = next.%Get(0)
		// Use just the location if the fullUrl base is the fetch endpoint (this is faster), otherwise use the full url
		set searchUrl = ##class(HS.BulkFHIR.Util).GetSearchURL(fullUrl,..%baseUrl)
		If ((searchUrl=fullUrl)&&($zcvt($P(..%baseUrl,"://"),"l")="http")&&($zcvt($P(searchUrl,"://"),"l")="https")) {
			// Use http because no SSL will have been configured
			Set $E(searchUrl,5)=""
		}
		Set $$$BFCSearchIterator(..%sessionId,..%grouping)=searchUrl
	}
	else {
		Set ..%atEnd=1
	}
}

/// @Input restClient		Configured instance of HS.BulkFHIR.Fetch.Util.RestClient for a FHIR endpoint
/// @Input requestPath		Relative query path to be executed. Must be a query that returns a Bundle, eg. "Patient", "Patient/<id>/$everything"
/// @Input pSession 		Session object which holds the BFC configuration and sessionId for multiple processes
Method %OnNew(restClient As HS.BulkFHIR.Fetch.Util.RestClient, requestPath As %String, pSession As HS.BulkFHIR.Session, pGrouping As %String = "NoGroup") As %Status
{
	set sc = $$$OK
	#dim config As HS.BulkFHIR.API.Data.Config = pSession.configuration
	set ..%restClient = restClient
	set ..%baseUrl = $zstrip(restClient.BaseURL,">","/")
	set ..%fpApi = $$$BFCMetaAPI(config).FHIRPathAPI
	Set ..%sessionId = pSession.%Id()
	Set ..%grouping = pGrouping
	
	set ..%iter = ##class(%Iterator.Array).%New([])
	try {
		If requestPath]"" {
			Do ..GetBundle(requestPath)
		}
	} catch ex {
		Set sc = ex.AsStatus()
	}
	return sc
}

Method AtEnd() As %Boolean
{
	Quit ..%atEnd
}

Method Total() As %Integer
{
	Quit ..%total
}

}
