/// Deprecated -- moved to HS.Registry.Codes
Class HS.Codes.Languages Extends (%Persistent, HS.Types.Code, HS.Util.CopyFrom, %XML.Adaptor)
{

Index IDKEY On Code [ IdKey, Unique ];

Index DescIndex On Description;

Query ListLanguages() As %SQLQuery
{
SELECT Code,Description FROM Languages ORDER BY Description
}

Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
	Set:..Description="" ..Description = ..Code
	Quit $$$OK
}

Storage Default
{
<Data name="LanguagesDefaultData">
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
<DataLocation>^HS.Codes.LanguagesD</DataLocation>
<DefaultData>LanguagesDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^HS.Codes.LanguagesD</IdLocation>
<IndexLocation>^HS.Codes.LanguagesI</IndexLocation>
<StreamLocation>^HS.Codes.LanguagesS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
