Include HS.BulkFHIR

Class HS.BulkFHIR.Log Extends %DocDB.Document [ ProcedureBlock ]
{

/// Overriding this until it's fixed in core (MINVAL was not set, therefore not allowing bitmap indices https://usjira.iscinternal.com/browse/DP-419354)
Property %DocumentId As %Integer(MINVAL = 1) [ Identity ];

Property component As %String [ SqlComputeCode = { set {*}=$$%EvaluatePathOne^%DocDB.Document({%Doc},"$.component")
}, SqlComputed, SqlComputeOnChange = %Doc ];

Property sessionId As %String [ SqlComputeCode = { set {*}=$$%EvaluatePathOne^%DocDB.Document({%Doc},"$.sessionId")
}, SqlComputed, SqlComputeOnChange = %Doc ];

Property type As %String [ SqlComputeCode = { set {*}=$$%EvaluatePathOne^%DocDB.Document({%Doc},"$.type")
}, SqlComputed, SqlComputeOnChange = %Doc ];

Property severity As %String [ SqlComputeCode = { set {*}=$$%EvaluatePathOne^%DocDB.Document({%Doc},"$.severity")
}, SqlComputed, SqlComputeOnChange = %Doc ];

Index component On component [ Type = bitmap ];

Index sessionId On sessionId;

Index type On type [ Type = bitmap ];

Index severity On severity [ Type = bitmap ];

ClassMethod Create()
{
	Set name = ..%ClassName(1)
	If '$system.DocDB.Exists(name) {
		Set db = ##class(%DocDB.Database).%New()
		Set db.Name = name
		Set db.ClassName = name
		Set db.SqlNameQualified = $$$comClassKeyGet(name,$$$cCLASSsqlqualifiednameQ)
		Do db.%Save()
	
	}
}

ClassMethod Log(event As %DynamicObject)
{
	set db = ##class(%DocDB.Database).%GetDatabase(..%ClassName(1))
	do db.%SaveDocument(event)
}

Storage Default
{
<Data name="%Doc">
<Attribute>%Doc</Attribute>
<Structure>node</Structure>
<Subscript>"%Doc"</Subscript>
</Data>
<Data name="LogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>%LastModified</Value>
</Value>
<Value name="3">
<Value>sessionId</Value>
</Value>
<Value name="4">
<Value>component</Value>
</Value>
<Value name="5">
<Value>type</Value>
</Value>
<Value name="6">
<Value>severity</Value>
</Value>
</Data>
<DataLocation>^HS.BulkFHIR.LogD</DataLocation>
<DefaultData>LogDefaultData</DefaultData>
<ExtentLocation>^HS.BulkFHIR.Log</ExtentLocation>
<IdLocation>^HS.BulkFHIR.LogD</IdLocation>
<Index name="$Log">
<Location>^HS.BulkFHIR.Log.2</Location>
</Index>
<Index name="IDKEY">
<Location>^HS.BulkFHIR.LogD</Location>
</Index>
<Index name="component">
<Location>^HS.BulkFHIR.LogI("component")</Location>
</Index>
<Index name="sessionId">
<Location>^HS.BulkFHIR.LogI("sessionId")</Location>
</Index>
<Index name="severity">
<Location>^HS.BulkFHIR.Log.6</Location>
</Index>
<Index name="type">
<Location>^HS.BulkFHIR.LogI("type")</Location>
</Index>
<IndexLocation>^HS.BulkFHIR.LogI</IndexLocation>
<StreamLocation>^HS.BulkFHIR.LogS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
