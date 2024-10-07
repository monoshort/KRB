/// Transforms SDA3 HS.SDA3.EOBSupportingInfo to vR4 Claim:supportingInfo
Class HS.FHIR.DTL.SDA3.vR4.EOBSupportingInfo.Claim.supportingInfo Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.EOBSupportingInfo, HS.FHIR.DTL.vR4.Model.Element.Claim.supportingInfo), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.EOBSupportingInfo' targetClass='HS.FHIR.DTL.vR4.Model.Element.Claim.supportingInfo' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.EOBSupportingInfo (SDA3) to Claim:supportingInfo (vR4) ]]>
  </annotation>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Category")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Category, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Category, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.category' action='set'  >
<annotation>
<![CDATA[ Classification of the supplied information
 --- In this case, any FHIR4 code may be used; claim-informationcategory shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Code")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Code, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Code, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.code' action='set'  >
<annotation>
<![CDATA[ Type of information
 --- In this case, any FHIR4 code may be used; claim-exception shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Reason")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Reason, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Reason, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.reason' action='set'  >
<annotation>
<![CDATA[ Explanation for the information
 --- In this case, any FHIR4 code may be used; missing-tooth-reason shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.TimingDate, "date")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.timingDate' action='set' >
<annotation>
<![CDATA[ When it occurred ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.TimingPeriodEnd&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.TimingPeriodEnd, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.timingPeriod.end' action='set' >
<annotation>
<![CDATA[ End time with inclusive boundary, if not ongoing ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='source.TimingPeriodStart&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.TimingPeriodStart, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.timingPeriod.start' action='set' >
<annotation>
<![CDATA[ Starting time with inclusive boundary ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "ValueAttachment")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.Attachment).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ValueAttachment, "HS.FHIR.DTL.SDA3.vR4.Document.Attachment")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ValueAttachment, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.valueAttachment' action='set'  >
<annotation>
<![CDATA[ Data to be provided ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<assign value='$select(source.ValueBoolean="true":1,source.ValueBoolean="false":0, 1:source.ValueBoolean)' property='target.valueBoolean' action='set' >
<annotation>
<![CDATA[ Data to be provided ]]>
</annotation>
</assign>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "ValueQuantity")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.Quantity).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ValueQuantity, "HS.FHIR.DTL.SDA3.vR4.Quantity.Quantity")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ValueQuantity, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.valueQuantity' action='set'  >
<annotation>
<![CDATA[ Data to be provided ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='source.ValueReference&apos;=""'> 
<true>
<if condition='source.ValueReference&apos;=""'> 
<true> 
<assign value='source.ValueReference' property='target.valueReference.reference' action='set' >
<annotation>
<![CDATA[ Literal reference, Relative, internal or absolute URL ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<if condition='source.ValueString&apos;=""'> 
<true> 
<assign value='source.ValueString' property='target.valueString' action='set' >
<annotation>
<![CDATA[ Data to be provided ]]>
</annotation>
</assign></true> 
</if> 

<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.EOBSupportingInfo.Claim.supportingInfo")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.EOBSupportingInfo.Claim.supportingInfo).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
