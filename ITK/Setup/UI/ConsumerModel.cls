/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.ITK.Setup.UI.ConsumerModel Extends (EnsLib.ITK.Setup.ConsumerServiceRegistry, EnsLib.ITK.Setup.UI.AbstractModel) [ System = 4 ]
{

/// This callback method is invoked when a new instance of DataModel is required.
/// If implemented, it returns a new instance of the data source object
/// used by the DataModel.<br>
/// The default implementation returns the DataModel itself as the source
/// object (this allows for simple DataModel classes that have no actual
/// source object).
Method OnNewSource(Output pSC As %Status = {$$$OK}) As %RegisteredObject
{
	Quit ##class(EnsLib.ITK.Setup.ConsumerServiceRegistry).%New()
}

/// This callback method is invoked when a DataModel is loaded into memory.
/// If implemented, it loads an instance of the data source object
/// used by the DataModel.<br>
/// The default implementation returns the DataModel itself as the source
/// object (this allows for simple DataModel classes that have no actual
/// source object).
Method OnOpenSource(pID As %String) As %RegisteredObject
{
	Quit ##class(EnsLib.ITK.Setup.ConsumerServiceRegistry).%OpenId(pID)
}

/// This callback method is called when the DataModel is saved. If
/// implemented, it is responsible for saving changes to the data source.
Method OnSaveSource(pSource As %RegisteredObject) As %Status
{
	Set tSC = pSource.%Save()
    Set ..%id = pSource.%Id()
    Quit tSC
}

/// This callback method is called when the DataModel is deleted. If
/// implemented, it is responsible for making the appropriate deletes
/// against the data source.
ClassMethod OnDeleteSource(pID As %String) As %Status
{
	Quit ##class(EnsLib.ITK.Setup.ConsumerServiceRegistry).%DeleteId(pID)
}

/// This callback method does the actual work of loading values from the source object.
Method OnLoadModel(pSource As EnsLib.ITK.Setup.ConsumerServiceRegistry) As %Status
{
	Set ..ConsumerName = pSource.ConsumerName
	Set ..ServiceName = pSource.ServiceName
	Set ..PartialLogicalEndpoint = pSource.PartialLogicalEndpoint
	Set ..InvocationPattern = pSource.InvocationPattern
	Set ..PartialPhysicalEndpoint = pSource.PartialPhysicalEndpoint
	
	Quit $$$OK
}

/// This callback method does the actual work of copying values 
/// from the DataModel to the data source.<br>
/// The default implementation is an expression method.
Method OnStoreModel(pSource As EnsLib.ITK.Setup.ConsumerServiceRegistry) As %Status
{
	Set pSource.ConsumerName = ..ConsumerName
	Set pSource.ServiceName = ..ServiceName
	Set pSource.PartialLogicalEndpoint = ..PartialLogicalEndpoint
	Set pSource.InvocationPattern = ..InvocationPattern
	Set pSource.PartialPhysicalEndpoint = ..PartialPhysicalEndpoint
	
	Quit pSource.%Save()
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
