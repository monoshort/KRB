/// Deprecated -- moved to HS.Registry.Codes
Class HS.Codes.Specialty Extends (%Persistent, HS.Types.Code, HS.Util.CopyFrom, %XML.Adaptor)
{

Index IDKEY On Code [ IdKey, Unique ];

Index DescIndex On Description;

Query ListSpecialties() As %SQLQuery
{
SELECT Code,Description FROM Specialty ORDER BY Description
}

Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
	Set:..Description="" ..Description = ..Code
	Quit $$$OK
}

Storage Default
{
<Data name="SpecialtyDefaultData">
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
<DataLocation>^HS.Codes.SpecialtyD</DataLocation>
<DefaultData>SpecialtyDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^HS.Codes.SpecialtyD</IdLocation>
<IndexLocation>^HS.Codes.SpecialtyI</IndexLocation>
<StreamLocation>^HS.Codes.SpecialtyS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
