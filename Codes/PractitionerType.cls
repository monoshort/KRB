/// Deprecated -- moved to HS.Registry.Codes
Class HS.Codes.PractitionerType Extends (%Persistent, HS.Types.Code, HS.Util.CopyFrom, %XML.Adaptor)
{

Index IDKEY On Code [ IdKey, Unique ];

Index DescIndex On Description;

Query ListPractitionerTypes() As %SQLQuery
{
SELECT Code,Description FROM PractitionerType ORDER BY Description
}

Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
	Set:..Description="" ..Description = ..Code
	Quit $$$OK
}

Storage Default
{
<Data name="PractitionerTypeDefaultData">
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
<DataLocation>^HS.Codes.PractitionerTypeD</DataLocation>
<DefaultData>PractitionerTypeDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^HS.Codes.PractitionerTypeD</IdLocation>
<IndexLocation>^HS.Codes.PractitionerTypeI</IndexLocation>
<StreamLocation>^HS.Codes.PractitionerTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
