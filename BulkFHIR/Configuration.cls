/// Persistent storage of the endpoint configurations
Class HS.BulkFHIR.Configuration Extends %Persistent
{

/// The unique name of the endpoint configuration.  "name" in the json document
Property Name As %String(MAXLEN = 255) [ Required ];

/// The "endpoint_url" defined in the json configuration, ie /bulkfhir/happy
Property BFCEndpoint As %String(MAXLEN = 255) [ Required ];

/// The original json configuration document of the BFC endpoint
Property Configuration As %DynamicObject [ Required ];

Index BFCEndpointIndex On BFCEndpoint [ Unique ];

Index NameIndex On Name [ Unique ];

ClassMethod GetConfiguration(pApplication As %String) As HS.BulkFHIR.API.Data.Config
{
	Set configuration = ..BFCEndpointIndexOpen( pApplication )
	If '$IsObject(configuration) {
		return ""
	}
	Set config = configuration.Configuration
	Quit ##class(HS.BulkFHIR.API.Data.Config).FromJson(config)
}

Storage Default
{
<Data name="Configuration">
<Attribute>Configuration</Attribute>
<Structure>node</Structure>
<Subscript>"Configuration"</Subscript>
</Data>
<Data name="ConfigurationDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>BFCEndpoint</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^HS.BulkFHIR.ConfigurationD</DataLocation>
<DefaultData>ConfigurationDefaultData</DefaultData>
<IdLocation>^HS.BulkFHIR.ConfigurationD</IdLocation>
<IndexLocation>^HS.BulkFHIR.ConfigurationI</IndexLocation>
<StreamLocation>^HS.BulkFHIR.ConfigurationS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
