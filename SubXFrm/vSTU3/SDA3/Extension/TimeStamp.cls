Class HS.FHIR.DTL.SubXFrm.vSTU3.SDA3.Extension.TimeStamp
{

ClassMethod Transform(source As HS.FHIR.DTL.vSTU3.Model.Base.Extension, Output target As %String, Output aux = "") As %Status
{
	set tSC = $$$OK
	try {
		set target = ##class(HS.FHIR.DTL.Util.Element.TypeCast).FHIRDateToSDA3(source.valueDateTime)
	} catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

}
