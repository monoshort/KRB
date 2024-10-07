/// Storage of the ndjson list with url with size, count, type for a session
Class HS.BulkFHIR.Session.Link Extends %Persistent
{

/// Resource Type, or OperationOutcome for errors  
Property type As %String;

/// count of rows in the ndjson file
Property count As %Integer;

/// size of ndjson file number of bytes
Property size As %Integer;

/// url for ndjson file ie <server_base>/fileJFHIR1/c066f5c0-22ed-11ed-9f71-3c22fb52d94b_Observation_0018.ndjson
Property url As %String(MAXLEN = 255);

/// Session 
Property session As HS.BulkFHIR.Session [ Required ];

Index SessionTypeIndex On (session, type);

Index URLIndex On url [ Unique ];

ClassMethod Add(pSession As HS.BulkFHIR.Session, pType As %String, pResourceCount As %Integer, pFileSize As %Integer, pURL)
{
	Set obj = ..URLIndexOpen(pURL)
	/// TODO: Paul investigating the incorrect class insertion of HS.FHIRServer.API.SearchQueryParameter into Parameters instead of HS.FHIRServer.API.Data.QueryParameters in the HS.FHIRServer.API.Data.Request
	Set pSession.request.Parameters=""
	If '$IsObject(obj) {
		Set obj = ..%New()
		Set obj.url = pURL
		Set obj.session = pSession
	}
	Set obj.type = pType
	Set obj.count = pResourceCount
	Set obj.size = pFileSize
	$$$ThrowOnError(obj.%Save())
}

Storage Default
{
<Data name="LinkDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>type</Value>
</Value>
<Value name="3">
<Value>count</Value>
</Value>
<Value name="4">
<Value>size</Value>
</Value>
<Value name="5">
<Value>url</Value>
</Value>
<Value name="6">
<Value>session</Value>
</Value>
</Data>
<DataLocation>^HS.BulkFHIR.Session.LinkD</DataLocation>
<DefaultData>LinkDefaultData</DefaultData>
<IdLocation>^HS.BulkFHIR.Session.LinkD</IdLocation>
<IndexLocation>^HS.BulkFHIR.Session.LinkI</IndexLocation>
<StreamLocation>^HS.BulkFHIR.Session.LinkS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
