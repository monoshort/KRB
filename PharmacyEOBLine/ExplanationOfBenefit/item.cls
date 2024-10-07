/// Transforms SDA3 HS.SDA3.PharmacyEOBLine to vR4 ExplanationOfBenefit:item
Class HS.FHIR.DTL.SDA3.vR4.PharmacyEOBLine.ExplanationOfBenefit.item Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.PharmacyEOBLine, HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.item), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.PharmacyEOBLine' targetClass='HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.item' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.PharmacyEOBLine (SDA3) to ExplanationOfBenefit:item (vR4) ]]>
  </annotation>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.CustomPairs).Extension(source.CustomPairs, .target, .aux)' property='value' action='set' />
<assign value='target.extension.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-e-o-b-line-custom-pairs"' property='value.url' action='set' />
<assign value='value' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations
 --- When the SDA3 source data contains a CustomPairs collection, and the target is FHIR, the collection is mapped to a FHIR extension that contains a Parameters resource. This Parameters resource is a collection of paired fields: name and valueString.   ]]>
</annotation>
</assign></true> 
</if> 
<foreach property='source.AdjudicationDetails()' key='st' >
<assign value='target.adjudication.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.item.adjudication).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.AdjudicationDetails.(st), "HS.FHIR.DTL.SDA3.vR4.AdjudicationDetail.ExplanationOfBenefit.adjudication")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.AdjudicationDetails.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.adjudication' action='set' key='index'  >
<annotation>
<![CDATA[ Adjudication details ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
<foreach property='source.CompoundMedication()' key='st' >
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).ItemDetail(source.CompoundMedication.GetAt(st), target, .aux)' property='value' action='set' />
<assign value='target.detail.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.detail' action='set' key='index'  >
<annotation>
<![CDATA[ Additional items ]]>
</annotation>
</assign></true> 
</if> </foreach>
<foreach property='source.DeniedReasonCodes()' key='st' >
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).AdjudicationReason(source.DeniedReasonCodes.GetAt(st), "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBAdjudicationDiscriminator", "denialreason", .aux)' property='value' action='set' />
<assign value='target.adjudication.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.adjudication' action='set' key='index'  >
<annotation>
<![CDATA[ Adjudication details ]]>
</annotation>
</assign></true> 
</if> </foreach>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "DrugCode")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.DrugCode, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.DrugProduct.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.DrugCode, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.productOrService' action='set'  >
<annotation>
<![CDATA[ Billing, service, product, or drug code ]]>
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-e-o-b-line-encounter-number"' property='tmp.url' action='set' />
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-e-o-b-line-entered-at"' property='tmp.url' action='set' />
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-e-o-b-line-entered-by"' property='tmp.url' action='set' />
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-e-o-b-line-entered-on"' property='tmp.url' action='set' />
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-e-o-b-line-external-id"' property='tmp.url' action='set' />
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
<if condition='source.FromTime&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.FromTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.servicedPeriod.start' action='set' >
<annotation>
<![CDATA[ Starting time with inclusive boundary ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "InOutNetwork")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).AdjudicationCategory(source.InOutNetwork, .aux)' property='value' action='set' />
<assign value='target.adjudication.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.adjudication' action='set' key='index'  >
<annotation>
<![CDATA[ Adjudication details ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<if condition='source.LineCounter&apos;=""'> 
<true> 
<assign value='source.LineCounter' property='target.sequence' action='set' >
<annotation>
<![CDATA[ Item instance identifier
 --- ExplanationOfBenefit:item[n].sequence is restricted to integer values *1* or greater.    ]]>
</annotation>
</assign></true> 
</if> 

<foreach property='source.ProcessNoteIds()' key='ll1' >
<assign value='source.ProcessNoteIds.(ll1)' property='target.noteNumber' action='set' key='ll1' >
<annotation>
<![CDATA[ Applicable note numbers
 --- ExplanationOfBenefit:item[n].noteNumber is restricted to integer values *1* or greater.    ]]>
</annotation>
</assign></foreach>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Quantity")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.Quantity).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Quantity, "HS.FHIR.DTL.SDA3.vR4.Quantity.Quantity")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Quantity, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.quantity' action='set'  >
<annotation>
<![CDATA[ Count of products or services ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='source.ToTime&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.ToTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.servicedPeriod.end' action='set' >
<annotation>
<![CDATA[ End time with inclusive boundary, if not ongoing ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.PharmacyEOBLine.ExplanationOfBenefit.item")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.PharmacyEOBLine.ExplanationOfBenefit.item).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
