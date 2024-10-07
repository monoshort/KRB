/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonHealthLake.BusinessOperation Extends Ens.BusinessOperation
{

Parameter INVOCATION = "Queue";

Parameter ADAPTER = "EnsLib.AmazonHealthLake.OutboundAdapter";

Property Adapter As EnsLib.AmazonHealthLake.OutboundAdapter;

/// HealthLake data store id
Property DatastoreId As %String(MAXLEN = 1000);

Parameter SETTINGS = "DatastoreId:HealthLake";

XData MessageMap
{
<MapItems>
    <MapItem MessageType="EnsLib.AmazonHealthLake.POSTRequest">
		<Method>MakePOSTRequest</Method>
	</MapItem>
	<MapItem MessageType="EnsLib.AmazonHealthLake.GETRequest">
		<Method>MakeGETRequest</Method>
	</MapItem>
	<MapItem MessageType="EnsLib.AmazonHealthLake.PUTRequest">
		<Method>MakePUTRequest</Method>
	</MapItem>
	<MapItem MessageType="EnsLib.AmazonHealthLake.DELETERequest">
		<Method>MakeDELETERequest</Method>
	</MapItem>
	<MapItem MessageType="EnsLib.AmazonHealthLake.QueryRequest">
		<Method>MakeQueryRequest</Method>
	</MapItem>
</MapItems>
}

Method MakePOSTRequest(request As EnsLib.AmazonHealthLake.POSTRequest, Output response As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tSC = ..Adapter.MakePOSTRequest(..DatastoreId, request.ResourceType, request.Content, .response)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

Method MakeGETRequest(request As EnsLib.AmazonHealthLake.GETRequest, Output response As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tSC = ..Adapter.MakeGETRequest(..DatastoreId, request.ResourceType, request.ResourceId, .response)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

Method MakePUTRequest(request As EnsLib.AmazonHealthLake.PUTRequest, Output response As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tSC = ..Adapter.MakePUTRequest(..DatastoreId, request.ResourceType, request.ResourceId, request.Content, .response)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

Method MakeDELETERequest(request As EnsLib.AmazonHealthLake.DELETERequest, Output response As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tSC = ..Adapter.MakeDELETERequest(..DatastoreId, request.ResourceType, request.ResourceId, .response)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

Method MakeQueryRequest(request As EnsLib.AmazonHealthLake.QueryRequest, Output response As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tSC = ..Adapter.MakeQueryRequest(..DatastoreId, request.SearchType, request.SearchParameters, .response)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}
