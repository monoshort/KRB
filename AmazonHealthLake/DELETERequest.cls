/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonHealthLake.DELETERequest Extends Ens.Request
{

Property ResourceType As %String(MAXLEN = 100);

Property ResourceId As %String(MAXLEN = 1000);

Storage Default
{
<Data name="DELETERequestDefaultData">
<Subscript>"DELETERequest"</Subscript>
<Value name="1">
<Value>ResourceType</Value>
</Value>
<Value name="2">
<Value>ResourceId</Value>
</Value>
</Data>
<DefaultData>DELETERequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
