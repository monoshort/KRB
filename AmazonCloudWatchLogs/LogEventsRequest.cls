/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonCloudWatchLogs.LogEventsRequest Extends Ens.Request
{

Property LogMessage As %String(MAXLEN = "");

Property LogTimeStamp As %Library.TimeStamp;

Storage Default
{
<Data name="LogEventsRequestDefaultData">
<Subscript>"LogEventsRequest"</Subscript>
<Value name="1">
<Value>LogMessage</Value>
</Value>
<Value name="2">
<Value>LogTimeStamp</Value>
</Value>
</Data>
<DefaultData>LogEventsRequestDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
