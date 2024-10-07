/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonHealthLake.InboundAdapterQuery Extends (EnsLib.Amazon.Common, EnsLib.PEX.InboundAdapter) [ Inheritance = right, ProcedureBlock, System = 4 ]
{

/// HealthLake data store id
Property DatastoreId As %String(MAXLEN = 1000);

/// Search type: metadata, Patient etc.
Property SearchType As %String(MAXLEN = 1000);

/// Search parameters, e.g., name=<name>&owner=<owner>
Property SearchParameters As %String(MAXLEN = 1000);

Parameter SETTINGS = "DatastoreId:HealthLake,SearchType:HealthLake,SearchParameters:HealthLake";

Method CreateInboundInput(pInput As %Net.Remote.Object) As InboundInputQuery
{
	Set input = ##class(InboundInputQuery).%New()
	Set input.DatastoreId = ..DatastoreId
	Set input.SearchType = ..SearchType
	Set input.SearchParameters = ..SearchParameters
	Set input.PayLoad = pInput.getData().%getall()
	Quit input
}

Method OnInit() As %Status
{
	Set ..%remoteClassname = "com.intersystems.cloud.amazonHL.InboundAdapterQuery"
	Set ..%gatewayName = "%Java Server"
	Set ..%gatewayExtraClasspaths = ..GetCloudClientJARPaths()
	Quit ##super()
}

}
