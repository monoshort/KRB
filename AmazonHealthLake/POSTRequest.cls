/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonHealthLake.POSTRequest Extends Ens.Request
{

Property ResourceType As %String(MAXLEN = 100);

Property Content As %GlobalBinaryStream;

Storage Default
{
<Data name="POSTRequestDefaultData">
<Subscript>"POSTRequest"</Subscript>
<Value name="1">
<Value>ResourceType</Value>
</Value>
<Value name="2">
<Value>Content</Value>
</Value>
</Data>
<DefaultData>POSTRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
