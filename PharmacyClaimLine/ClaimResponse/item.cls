/// Transforms SDA3 HS.SDA3.PharmacyClaimLine to vR4 ClaimResponse:item
Class HS.FHIR.DTL.SDA3.vR4.PharmacyClaimLine.ClaimResponse.item Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.PharmacyClaimLine, HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.item), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.PharmacyClaimLine' targetClass='HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.item' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.PharmacyClaimLine (SDA3) to ClaimResponse:item (vR4) ]]>
  </annotation>
<foreach property='source.AdjudicationDetails()' key='st' >
<assign value='target.adjudication.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.item.adjudication).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.AdjudicationDetails.(st), "HS.FHIR.DTL.SDA3.vR4.AdjudicationDetail.ClaimResponse.adjudication")' property='DTL' action='set' />
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
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "DeniedReasonCode")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).AdjudicationReason(source.DeniedReasonCode, "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBAdjudicationDiscriminator", "denialreason", .aux)' property='value' action='set' />
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-claim-line-entered-at"' property='tmp.url' action='set' />
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-claim-line-entered-by"' property='tmp.url' action='set' />
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-claim-line-entered-on"' property='tmp.url' action='set' />
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
<if condition='source.LineCounter&apos;=""'> 
<true> 
<assign value='source.LineCounter' property='target.itemSequence' action='set' >
<annotation>
<![CDATA[ Claim item instance identifier
 --- ClaimResponse:item[n].itemSequence is restricted to integer values *1* or greater.    ]]>
</annotation>
</assign></true> 
</if> 

<foreach property='source.ProcessNoteIds()' key='ll1' >
<assign value='source.ProcessNoteIds.(ll1)' property='target.noteNumber' action='set' key='ll1' >
<annotation>
<![CDATA[ Applicable note numbers
 --- ClaimResponse:item[n].noteNumber is restricted to integer values *1* or greater.    ]]>
</annotation>
</assign></foreach>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.PharmacyClaimLine.ClaimResponse.item")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.PharmacyClaimLine.ClaimResponse.item).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
