/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonHealthLake.InboundAdapter Extends (EnsLib.Amazon.Common, EnsLib.PEX.InboundAdapter) [ Inheritance = right, ProcedureBlock, System = 4 ]
{

/// HealthLake data store id
Property DatastoreId As %String(MAXLEN = 1000);

/// FHIR resource type
Property ResourceType As %String(MAXLEN = 1000);

/// FHIR resource id
Property ResourceId As %String(MAXLEN = 1000);

/// Flag to indicate whether deleting the resource after the GET request
Property DeleteAfterGET As %Boolean [ InitialExpression = 0 ];

Parameter SETTINGS = "DatastoreId:HealthLake,ResourceType:HealthLake,ResourceId:HealthLake,DeleteAfterGET:HealthLake";

Method CreateInboundInput(pInput As %Net.Remote.Object) As InboundInput
{
	Set input = ##class(InboundInput).%New()
	Set input.DatastoreId = ..DatastoreId
	Set input.ResourceType = ..ResourceType
	Set input.ResourceId = ..ResourceId
	Set input.PayLoad = pInput.getData().%getall()
	Quit input
}

Method OnInit() As %Status
{
	Set ..%remoteClassname = "com.intersystems.cloud.amazonHL.InboundAdapter"
	Set ..%gatewayName = "%Java Server"
	Set ..%gatewayExtraClasspaths = ..GetCloudClientJARPaths()
	Quit ##super()
}

}
