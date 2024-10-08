/// Transforms SDA3 HS.SDA3.DosageStep to vR4 Dosage
Class HS.FHIR.DTL.SDA3.vR4.DosageStep.Dosage Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.DosageStep, HS.FHIR.DTL.vR4.Model.Element.Dosage), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.DosageStep' targetClass='HS.FHIR.DTL.vR4.Model.Element.Dosage' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.DosageStep (SDA3) to Dosage (vR4) ]]>
  </annotation>
<if condition='&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source,"Frequency") || (source.Frequency.Code &apos;= "PRN")'> 
<true>
<assign value='"0"' property='target.asNeededBoolean' action='set' >
<annotation>
<![CDATA[ Take \"as needed\" (for x) ]]>
</annotation>
</assign>
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source,"Frequency") &amp;&amp; (source.Frequency.Code = "PRN")'> 
<true>
<assign value='"1"' property='target.asNeededBoolean' action='set' >
<annotation>
<![CDATA[ Take \"as needed\" (for x) ]]>
</annotation>
</assign>
</true>
</if>
<if condition='source.DoseQuantity&apos;=""'> 
<true>
<if condition='source.DoseQuantity&apos;=""'> 
<true> 
<assign value='source.DoseQuantity' property='target.doseAndRate.(1).doseQuantity.value' action='set' >
<annotation>
<![CDATA[ Numerical value (with implicit precision) ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<if condition='source.DoseUoM.Code&apos;=""'> 
<true>
<if condition='source.DoseUoM.Code&apos;=""'> 
<true> 
<assign value='source.DoseUoM.Code' property='target.doseAndRate.(1).doseQuantity.code' action='set' >
<annotation>
<![CDATA[ Coded form of the unit ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.DoseUoM.SDACodingStandard) = ""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).GetURIForValueSet("vR4", "http://unitsofmeasure.org", source.DoseUoM.Code)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.doseAndRate.(1).doseQuantity.system' action='set' >
<annotation>
<![CDATA[ System that defines coded unit form ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"http://www.intersystems.com/fhir/system"' property='target.doseAndRate.(1).doseQuantity.system' action='set' />
</false> 
</if> 
</true>
</if>
<if condition='source.DoseUoM.Description&apos;=""'> 
<true>
<if condition='source.DoseUoM.Description&apos;=""'> 
<true> 
<assign value='source.DoseUoM.Description' property='target.doseAndRate.(1).doseQuantity.unit' action='set' >
<annotation>
<![CDATA[ Unit representation ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<if condition='source.DoseUoM.SDACodingStandard&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.DoseUoM.SDACodingStandard)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.doseAndRate.(1).doseQuantity.system' action='set' >
<annotation>
<![CDATA[ System that defines coded unit form ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='source.DoseUoM.SDACodingStandard&apos;=""'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.DoseUoM.SDACodingStandard) = ""'> 
<true>
<assign value='1' property='index' action='set' />
<if condition='(target.doseAndRate&apos;="") &amp;&amp; (target.doseAndRate.Count() &gt; 0)'> 
<true> 
<if condition='target.doseAndRate.(1).doseQuantity&apos;=""'> 
<true> 
<assign value='target.doseAndRate.(1).doseQuantity.extension.Count()+1' property='index' action='set' />
</true> 
</if> 
</true> 
</if> 
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.DoseUoM.SDACodingStandard, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.StrippedString.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.DoseUoM.SDACodingStandard, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/dosage-step-dose-uo-m-s-d-a-coding-standard"' property='tmp.url' action='set' />
<assign value='tmp' property='target.doseAndRate.(1).doseQuantity.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Duration")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Duration, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.Duration.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Duration, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/dosage-step-duration"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='source.EncounterNumber&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.EncounterNumber, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.EncounterNumber, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/dosage-step-encounter-number"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "EnteredAt")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.EnteredAt, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.Organization.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.EnteredAt, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/dosage-step-entered-at"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "EnteredBy")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.EnteredBy, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.EnteredBy, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/dosage-step-entered-by"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='source.EnteredOn&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.EnteredOn, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.TimeStamp.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.EnteredOn, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/dosage-step-entered-on"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<if condition='source.ExternalId&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ExternalId, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ExternalId, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/dosage-step-external-id"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Frequency")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.Dosage).Frequency(source.Frequency)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.timing' action='set' >
<annotation>
<![CDATA[ When medication should be administered ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<if condition='source.FromTime&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.FromTime, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.TimeStamp.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.FromTime, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/dosage-step-from-time"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<if condition='source.TextInstruction&apos;=""'> 
<true> 
<assign value='source.TextInstruction' property='target.text' action='set' >
<annotation>
<![CDATA[ Free text dosage instructions e.g. SIG ]]>
</annotation>
</assign></true> 
</if> 

<if condition='source.ToTime&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ToTime, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.TimeStamp.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ToTime, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/dosage-step-to-time"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.DosageStep.Dosage")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.DosageStep.Dosage).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
