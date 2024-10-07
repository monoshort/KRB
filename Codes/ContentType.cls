Class HS.Codes.ContentType Extends (%Persistent, HS.Types.Code, HS.Util.CopyFrom, %XML.Adaptor)
{

Index IDKEY On Code [ IdKey, Unique ];

Index DescIndex On Description;

Query ListContentTypes() As %SQLQuery
{
SELECT Code,Description FROM ContentType ORDER BY Description
}

Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
	Set:..Description="" ..Description = ..Code
	Quit $$$OK
}

Storage Default
{
<Data name="ContentTypeDefaultData">
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
<DataLocation>^HS.Codes.ContentTypeD</DataLocation>
<DefaultData>ContentTypeDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^HS.Codes.ContentTypeD</IdLocation>
<IndexLocation>^HS.Codes.ContentTypeI</IndexLocation>
<StreamLocation>^HS.Codes.ContentTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
