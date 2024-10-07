/// Transforms SDA3 HS.SDA3.PharmacyClaimLine to vR4 Claim:item
Class HS.FHIR.DTL.SDA3.vR4.PharmacyClaimLine.Claim.item Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.PharmacyClaimLine, HS.FHIR.DTL.vR4.Model.Element.Claim.item), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.PharmacyClaimLine' targetClass='HS.FHIR.DTL.vR4.Model.Element.Claim.item' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.PharmacyClaimLine (SDA3) to Claim:item (vR4) ]]>
  </annotation>
<if condition='source.ChargedAmount&apos;=""'> 
<true>
<if condition='source.ChargedAmount&apos;=""'> 
<true> 
<assign value='source.ChargedAmount' property='target.net.value' action='set' >
<annotation>
<![CDATA[ Numerical value (with implicit precision) ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<foreach property='source.CompoundMedication()' key='st' >
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).ItemDetail(source.CompoundMedication.GetAt(st), target, .aux)' property='value' action='set' />
<assign value='target.detail.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.detail' action='set' key='index'  >
<annotation>
<![CDATA[ Product or service provided ]]>
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-claim-line-external-id"' property='tmp.url' action='set' />
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
<if condition='source.ToTime = ""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.FromTime, "date")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.servicedDate' action='set' >
<annotation>
<![CDATA[ Date or dates of service or product delivery
Note: If both FromTime and ToTime have a value, then servicedPeriod is populated. Otherwise, if only FromTime has a value, then servicedDate is populated, with only the date portion of the value. ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='source.FromTime&apos;=""'> 
<true>
<if condition='source.ToTime &apos;= ""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.FromTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.servicedPeriod.start' action='set' >
<annotation>
<![CDATA[ Starting time with inclusive boundary
Note: If both FromTime and ToTime have a value, then servicedPeriod is populated. Otherwise, if only FromTime has a value, then servicedDate is populated, with only the date portion of the value. ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
</true>
</if>
<if condition='source.LineCounter&apos;=""'> 
<true> 
<assign value='source.LineCounter' property='target.sequence' action='set' >
<annotation>
<![CDATA[ Item instance identifier
 --- Claim:item[n].sequence is restricted to integer values *1* or greater.    ]]>
</annotation>
</assign></true> 
</if> 

<if condition='source.ToTime&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.ToTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.servicedPeriod.end' action='set' >
<annotation>
<![CDATA[ End time with inclusive boundary, if not ongoing
Note: If both FromTime and ToTime have a value, then servicedPeriod is populated. Otherwise, if only FromTime has a value, then servicedDate is populated, with only the date portion of the value. ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.PharmacyClaimLine.Claim.item")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.PharmacyClaimLine.Claim.item).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
