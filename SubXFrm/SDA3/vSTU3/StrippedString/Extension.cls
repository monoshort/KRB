Class HS.FHIR.DTL.SubXFrm.SDA3.vSTU3.StrippedString.Extension [ DependsOn = (%Library.String, HS.FHIR.DTL.vSTU3.Model.Base.Extension), ProcedureBlock ]
{

ClassMethod Transform(source As %RegisteredObject, Output target As %RegisteredObject, Output aux = "") As %Status
{
	set tSC = $$$OK
	try {
		set strippedSource = $zstrip(source, "<>W")
		set target.valueString = strippedSource
	} catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

ClassMethod GetTargetType(create) As %String
{
	quit "HS.FHIR.DTL.vSTU3.Model.Base.Extension"
}

}
