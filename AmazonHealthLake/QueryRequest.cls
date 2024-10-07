/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonHealthLake.QueryRequest Extends Ens.Request
{

Property SearchType As %String(MAXLEN = 1000);

Property SearchParameters As %String(MAXLEN = 1000);

Storage Default
{
<Data name="QueryRequestDefaultData">
<Subscript>"QueryRequest"</Subscript>
<Value name="1">
<Value>SearchType</Value>
</Value>
<Value name="2">
<Value>SearchParameters</Value>
</Value>
</Data>
<DefaultData>QueryRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
