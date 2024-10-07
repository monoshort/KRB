/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.CloudStorage.InboundAdapter Extends (EnsLib.CloudStorage.Common, EnsLib.PEX.InboundAdapter) [ ClassType = "", Inheritance = right, ProcedureBlock, System = 4 ]
{

/// Bucket name
Property BucketName As %String(MAXLEN = 1000);

/// Blob name prefix, used to filter blobs on server.
Property BlobNamePrefix As %String(MAXLEN = 1000);

/// Blob name pattern, used to filter blobs on client. Support wildcards ? and *.
Property BlobNamePattern As %String(MAXLEN = 1000);

/// Flag to indicate whether deleting the blob after downlaod
Property DeleteAfterDownload As %Boolean [ InitialExpression = 1 ];

Parameter SETTINGS = "BucketName:Cloud Storage,BlobNamePrefix:Cloud Storage,BlobNamePattern:Cloud Storage,DeleteAfterDownload:Cloud Storage";

Method CreateInboundInput(pInput As %Net.Remote.Object) As InboundInput
{
	Set input = ##class(InboundInput).%New()
	Set input.Name = pInput.getName()
	Set input.Meta = pInput.getMeta()
	Set input.Content = pInput.getContent().%getall()
	Quit input
}

Method OnInit() As %Status
{
	Set ..%remoteClassname = "com.intersystems.cloud.storage.InboundAdapter"
	Set ..%gatewayName = "%Java Server"
	Set ..%gatewayExtraClasspaths = ..GetCloudClientJARPaths()
	Quit ##super()
}

}
