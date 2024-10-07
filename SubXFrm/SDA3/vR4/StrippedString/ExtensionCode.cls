Class HS.FHIR.DTL.SubXFrm.SDA3.vR4.StrippedString.ExtensionCode [ DependsOn = (%Library.String, HS.FHIR.DTL.vR4.Model.Base.Extension), ProcedureBlock ]
{

ClassMethod Transform(source As HS.SDA3.StrippedString, Output target As HS.FHIR.DTL.vR4.Model.Base.Extension, Output aux = "") As %Status
{
	set tSC = $$$OK
	try {
		set target.valueCode = source
	} catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

ClassMethod GetTargetType(create) As %String
{
	quit "HS.FHIR.DTL.vR4.Model.Base.Extension"
}

}
