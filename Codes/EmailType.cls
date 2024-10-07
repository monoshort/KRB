Class HS.Codes.EmailType Extends (%Persistent, HS.Codes.Types.SimpleCode)
{

Index IDKEY On Code [ IdKey, Unique ];

Index DescIndex On Description;

Query ListEmailTypes() As %SQLQuery
{
SELECT Code,Description FROM EmailType ORDER BY Description
}

Storage Default
{
<Data name="EmailTypeDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Description</Value>
</Value>
</Data>
<DataLocation>^HS.Codes.EmailTypeD</DataLocation>
<DefaultData>EmailTypeDefaultData</DefaultData>
<IdLocation>^HS.Codes.EmailTypeD</IdLocation>
<IndexLocation>^HS.Codes.EmailTypeI</IndexLocation>
<StreamLocation>^HS.Codes.EmailTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
