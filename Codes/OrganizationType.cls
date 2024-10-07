/// Deprecated -- moved to HS.Registry.Codes
Class HS.Codes.OrganizationType Extends (%Persistent, HS.Types.Code, HS.Util.CopyFrom, %XML.Adaptor)
{

Index IDKEY On Code [ IdKey, Unique ];

Index DescIndex On Description;

Query ListOrganizationTypes() As %SQLQuery
{
SELECT Code,Description FROM OrganizationType ORDER BY Description
}

Method %OnBeforeSave(insert As %Boolean) As %Status [ Private, ServerOnly = 1 ]
{
	Set:..Description="" ..Description = ..Code
	Quit $$$OK
}

Storage Default
{
<Data name="OrganizationTypeDefaultData">
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
<DataLocation>^HS.Codes.OrganizationTypeD</DataLocation>
<DefaultData>OrganizationTypeDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^HS.Codes.OrganizationTypeD</IdLocation>
<IndexLocation>^HS.Codes.OrganizationTypeI</IndexLocation>
<StreamLocation>^HS.Codes.OrganizationTypeS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
