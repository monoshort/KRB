/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonCloudWatchLogs.BusinessOperation Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.AmazonCloudWatchLogs.OutboundAdapter";

Property Adapter As EnsLib.AmazonCloudWatchLogs.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// CloudWatch log group name
Property LogGroupName As %String(MAXLEN = 100);

/// CloudWatch log stream name
Property LogStreamName As %String(MAXLEN = 100);

Parameter SETTINGS = "LogGroupName:CloudWatchLogs,LogStreamName:CloudWatchLogs";

XData MessageMap
{
<MapItems>
  <MapItem MessageType="EnsLib.AmazonCloudWatchLogs.LogEventsRequest">
    <Method>PutLogEvents</Method>
  </MapItem>
</MapItems>
}

Method PutLogEvents(request As EnsLib.AmazonCloudWatchLogs.LogEventsRequest, Output response As EnsLib.AmazonCloudWatchLogs.LogEventsResponse) As %Status
{
	Set tSC = $$$OK
	Try {
		Set tSC = ..Adapter.PutLogEvents(..LogGroupName, ..LogStreamName, request.LogMessage, request.LogTimeStamp, .nextToken)
		Quit:$$$ISERR(tSC)
		Set response = ##class(EnsLib.AmazonCloudWatchLogs.LogEventsResponse).%New()
		Set response.NextToken = nextToken
	}
	Catch (ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}
