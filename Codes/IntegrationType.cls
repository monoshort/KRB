Class HS.Codes.IntegrationType Extends (%Persistent, HS.Types.Code, HS.Util.CopyFrom, %XML.Adaptor)
{

Index IDKEY On Code [ IdKey, Unique ];

Index DescIndex On Description;

Query ListIntegrationTypes() As %SQLQuery
{
SELECT Code,Description FROM IntegrationType ORDER BY Description
}

Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
	Set:..Description="" ..Description = ..Code
	Quit $$$OK
}

Storage Default
{
<Data name="IntegrationTypeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>CodeSystem</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
</Data>
<DataLocation>^HS.Codes.IntegrationTypeD</DataLocation>
<DefaultData>IntegrationTypeDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^HS.Codes.IntegrationTypeD</IdLocation>
<IndexLocation>^HS.Codes.IntegrationTypeI</IndexLocation>
<StreamLocation>^HS.Codes.IntegrationTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
