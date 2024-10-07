/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class Ens.SAM.SensorDefinitions Extends %RegisteredObject [ Language = objectscript, System = 4 ]
{

/// namespace will be the id label
XData EnsMonitorService [ MimeType = application/json ]
{
{
		"sensorClass":"Ens.SAM.SensorSampler",
		"sensors":[
			{
				"sensorName":"InteropHosts",
				"sensorType":"Gauge",
				"sensorDescription":"Count of host items by Status",
				"sensorLabels" : [
									"production",
									"status",
									"host"
								]
			},
			{
				"sensorName":"InteropQueued",
				"sensorType":"Gauge",
				"sensorDescription":"Count of queued messages for hosts with Queue Count Alert value",
				"sensorLabels": [
									"production",
									"host"
								]
			},
			{
				"sensorName":"InteropAlertDelay",
				"sensorType":"Gauge",
				"sensorDescription":"Count of Host Items that have triggered Alert for Message processing Delay",
				"sensorLabels": [
									"production",
									"host"
								]
			},
			{
				"sensorName":"InteropMessages",
				"sensorType":"CounterWithPerSec",
				"sensorDescription":"Count of Messages processed since production started.",
				"sensorLabels": [
									"production",
									"host"
								]
			}
		]
	}
}

/// sensorDescription and sensorLabels for information
XData EnsActivityOperationBase [ MimeType = application/json ]
{
{
		"sensorClass":"Ens.SAM.SensorSampler",
		"sensors":[
			{
				"sensorName":"InteropSampleCount",
				"sensorType":"GaugeWithPerSec",
				"sensorDescription":"Activity Count of Host Items within the sampling window",
				"sensorLabels" : [
									"production",
									"hosttype",
									"host",
									"messagetype"
								]
			},
			{
				"sensorName":"InteropAvgProcessingTime",
				"sensorType":"Gauge",
				"sensorValueAverageBy":"InteropActivityCount",
				"sensorDescription":"Average time message was being processed by host items",
				"sensorLabels" : [
									"production",
									"hosttype",
									"host",
									"messagetype"
								]
			},
			{
				"sensorName":"InteropAvgQueueingTime",
				"sensorType":"Gauge",
				"sensorValueAverageBy":"InteropActivityCount",
				"sensorDescription":"Average time message was queued before being processed by a host item",
				"sensorLabels" : [
									"production",
									"hosttype",
									"host",
									"messagetype"
								]
			}
		]
	}
}

/// sensorDescription and sensorLabels for information
XData EnsHTTPRequest [ MimeType = application/json ]
{
{
		"sensorClass":"Ens.SAM.SensorSampler",
		"sensors":[
			{
				"sensorName":"InteropHttpSampleCount",
				"sensorType":"GaugeWithPerSec",
				"sensorDescription":"Activity Count of HTTP transmissions within the sampling window",
				"sensorLabels" : [
									"production",
									"host"
								]
			},
			{
				"sensorName":"InteropAvgHttpTtfc",
				"sensorType":"Gauge",
				"sensorValueAverageBy":"InteropHttpSampleCount",
				"sensorDescription":"Average time since start of request to first character of response",
				"sensorLabels" : [
									"production",
									"host"
								]
			},
			{
				"sensorName":"InteropAvgHttpTtlc",
				"sensorType":"Gauge",
				"sensorValueAverageBy":"InteropHttpSampleCount",
				"sensorDescription":"Average time since start of request to last character of response",
				"sensorLabels" : [
									"production",
									"host"
								]
			},
			{
				"sensorName":"InteropAvgHttpSentChars",
				"sensorType":"Gauge",
				"sensorValueAverageBy":"InteropHttpSampleCount",
				"sensorDescription":"Average sent characters per SOAP request",
				"sensorLabels" : [
									"production",
									"host"
								]
			},
			{
				"sensorName":"InteropAvgHttpReceivedChars",
				"sensorType":"Gauge",
				"sensorValueAverageBy":"InteropHttpSampleCount",
				"sensorDescription":"Average received characters per SOAP response",
				"sensorLabels" : [
									"production",
									"host"
								]
			}
		]
	}
}

}
