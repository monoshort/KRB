/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

/// Rule Extension class for HL7 property paths
Class EnsLib.HL7.RuleExtension Extends (Ens.Rule.Extension, %CSP.REST)
{

Parameter PluginName = "HL7v2";

Parameter DataTypes = "HL7v2";

/// REST URL Map for this Rule Extension
XData UrlMap
{
<Routes>
<Route Url="/docType"			              Method="GET"     Call="GetDocTypeList"/>
</Routes>
}

ClassMethod GetDocTypeList(Svc As EnsLib.REST.Service, InStream As %CSP.BinaryStream, Output OutStream As %GlobalBinaryStream, pPluginName As %String) As %Status
{
	$$$ASSERT(pPluginName=..#PluginName)
	Set tSC = $$$OK
	try {
		Set body = {"columns":{"MessageStructure":{"pos":0,"type":"%String"},"Description":{"pos":1,"type":"%String"},"IsStandard":{"pos":1,"type":"%Boolean"}},"data":[]}
		Set tRS = ##class(%Library.ResultSet).%New("EnsLib.HL7.Schema:MessageStructures")
		Set tSC = tRS.Execute("")
		While $$$ISOK(tSC) && tRS.Next(.tSC) {
			Do body.data.%Push([(tRS.Data("MessageStructure")),(tRS.Data("Description")),(tRS.Data("IsStandard"))])
		} Set:tSC'=0 tSCc=tRS.Close() Set tSC=$S(tSC'=0&&$$$ISERR(tSC):tSC, tSC'=0:tSCc, 1:$$$ERROR($$$GeneralError,"Failed to create %ResultSet "_$$$StatusDisplayString($g(%objlasterror))))
		Quit:$$$ISERR(tSC)
		Do body.%ToJSON(OutStream)
		Set OutStream.Attributes("Content-Type")="application/json; charset=""UTF-8"""
	} catch ex {
		Set tSC=ex.AsStatus()
	}
	If $$$ISERR(tSC) {
		Quit:'$$$IsdefObject(OutStream) tSC
		Set OutStream.Attributes("Content-Type")="text/plain; charset=""UTF-8"""
		Set OutStream.Attributes("ResponseCode")=..#HTTP500INTERNALSERVERERROR
		Do OutStream.Write($P($$$StatusDisplayString(tSC)," / ["))
	}
	Quit $$$OK
}

}
