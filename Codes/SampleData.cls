Class HS.Codes.SampleData Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

ClassMethod clean() As %Status
{
	Do ##class(HS.Codes.EmailType).%KillExtent()
	Quit $$$OK
}

ClassMethod Populate() As %Status
{
	Set tSC=$$$OK
	Try {
		For tNode="EmailType" {
			Set txdata=##class(%Dictionary.CompiledXData).%OpenId(..%ClassName(1)_"||"_tNode).Data
			Set reader=##class(%XML.Reader).%New()
			Set tSC=reader.OpenStream(txdata) break:'tSC
			Set tClass="HS.Codes."_tNode
			Do reader.Correlate(tNode,tClass)
			While reader.Next(.tObject,.tSC) {
				If $$$ISERR(tSC) do $System.Status.DisplayError(tSC) break
				Set:'$classmethod(tClass,"%ExistsId",tObject.Code) tSC=tObject.%Save()
				If $$$ISERR(tSC) Do $System.Status.DisplayError(tSC) break
			}
		}
	} Catch ex {
		Set tSC=ex.AsStatus()
	}
	Quit tSC
}

XData EmailType
{
<?xml version="1.0" encoding="UTF-8"?>
<root>

<EmailType>
	<Code>DR</Code>
	<Description>Direct</Description>
</EmailType>
<EmailType>
	<Code>WP</Code>
	<Description>Work</Description>
</EmailType>
<EmailType>
	<Code>H</Code>
	<Description>Home</Description>
</EmailType>
<EmailType>
	<Code>ANY</Code>
	<Description>[Any]</Description>
</EmailType>
<EmailType>
	<Code>S</Code>
	<Description>Secure</Description>
</EmailType>
</root>
}

}
