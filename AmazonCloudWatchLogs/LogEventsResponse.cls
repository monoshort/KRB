/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonCloudWatchLogs.LogEventsResponse Extends Ens.Response
{

Property NextToken As %String(MAXLEN = 1000);

Storage Default
{
<Data name="LogEventsResponseDefaultData">
<Subscript>"LogEventsResponse"</Subscript>
<Value name="1">
<Value>NextToken</Value>
</Value>
</Data>
<DefaultData>LogEventsResponseDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
