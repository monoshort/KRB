/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonHealthLake.OutboundAdapter Extends (EnsLib.PEX.OutboundAdapter, EnsLib.Amazon.Common) [ ClassType = "", Inheritance = right, ProcedureBlock, System = 4 ]
{

ClassMethod ToUTF8(stream As %Stream.Object) As %Stream.TmpBinary [ Private ]
{
	// Create binary stream
	Set bs = ##class(%Stream.TmpBinary).%New()
	Do stream.Rewind()
	While (stream.AtEnd = 0) {
		Set len = 32000
		Set buffer = stream.Read(.len)
		// Convert to UTF8
		Set utf8 = $ZCONVERT(buffer, "O", "UTF8")
		// Write to binary stream
		Do bs.Write(utf8)
	}
	Quit bs
}

Method OnInit() As %Status
{
	Set ..%remoteClassname = "com.intersystems.cloud.amazonHL.OutboundAdapter"
	Set ..%gatewayName = "%Java Server"
	Set ..%gatewayExtraClasspaths = ..GetCloudClientJARPaths()
	Quit ##super()
}

ClassMethod GetHttpResponse(jresponse As %Net.Remote.Object) As %Net.HttpResponse
{
	Set response = ##class(%Net.HttpResponse).%New()
	
	Set response.ContentBoundary = jresponse.getContentBoundary()
	Set response.ContentInfo = jresponse.getContentInfo()
	Set response.ContentLength = jresponse.getContentLength()
	Set response.ContentType = jresponse.getContentType()
	// Data is a binary stream
	Set response.Data = jresponse.getData().%getall()
	Set response.Headers = jresponse.getHeaders()
	Set response.HttpVersion = jresponse.getHttpVersion()
	Set response.ReasonPhrase = jresponse.getReasonPhrase()
	Set response.StatusCode = jresponse.getStatusCode()
	Set response.StatusLine = jresponse.getStatusLine()
	
	Quit response
}

Method MakePOSTRequest(datastoreId As %String, resourceType As %String, content As %String, Output response As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		#Dim jresponse As %Net.Remote.Object
		If $IsObject(content) { // Stream
			Set bs = $S(content.IsCharacter():..ToUTF8(content), 1:content)
			Set bytes = ##class(%Net.Remote.Object).%New(..%gatewayConnection, "byte[*]", bs)
			Set jresponse = ..%gatewayProxy.makePOSTRequest(datastoreId, resourceType, bytes)
		}
		Else { // String
			Set jresponse = ..%gatewayProxy.makePOSTRequest(datastoreId, resourceType, content)
		}
		Set response = ..GetHttpResponse(jresponse)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

Method MakeGETRequest(datastoreId As %String, resourceType As %String, resourceId As %String, Output response As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set jresponse = ..%gatewayProxy.makeGETRequest(datastoreId, resourceType, resourceId)
		Set response = ..GetHttpResponse(jresponse)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

Method MakePUTRequest(datastoreId As %String, resourceType As %String, resourceId As %String, content As %String, Output response As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		#Dim jresponse As %Net.Remote.Object
		If $IsObject(content) { // Stream
			Set bs = $S(content.IsCharacter():..ToUTF8(content), 1:content)
			Set bytes = ##class(%Net.Remote.Object).%New(..%gatewayConnection, "byte[*]", bs)
			Set jresponse = ..%gatewayProxy.makePUTRequest(datastoreId, resourceType, resourceId, bytes)
		}
		Else { // String
			Set jresponse = ..%gatewayProxy.makePUTRequest(datastoreId, resourceType, resourceId, content)
		}
		Set response = ..GetHttpResponse(jresponse)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

Method MakeDELETERequest(datastoreId As %String, resourceType As %String, resourceId As %String, Output response As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set jresponse = ..%gatewayProxy.makeDELETERequest(datastoreId, resourceType, resourceId)
		Set response = ..GetHttpResponse(jresponse)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

Method MakeQueryRequest(datastoreId As %String, searchType As %String, searchParameters As %String, Output response As %Net.HttpResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set jresponse = ..%gatewayProxy.makeQueryRequest(datastoreId, searchType, searchParameters)
		Set response = ..GetHttpResponse(jresponse)
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}
