/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonHealthLake.PUTRequest Extends Ens.Request
{

Property ResourceType As %String(MAXLEN = 100);

Property ResourceId As %String(MAXLEN = 1000);

Property Content As %GlobalBinaryStream;

Storage Default
{
<Data name="PUTRequestDefaultData">
<Subscript>"PUTRequest"</Subscript>
<Value name="1">
<Value>ResourceType</Value>
</Value>
<Value name="2">
<Value>ResourceId</Value>
</Value>
<Value name="3">
<Value>Content</Value>
</Value>
</Data>
<DefaultData>PUTRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
