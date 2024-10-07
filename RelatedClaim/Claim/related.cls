/// Transforms SDA3 HS.SDA3.RelatedClaim to vR4 Claim:related
Class HS.FHIR.DTL.SDA3.vR4.RelatedClaim.Claim.related Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.RelatedClaim, HS.FHIR.DTL.vR4.Model.Element.Claim.related), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.RelatedClaim' targetClass='HS.FHIR.DTL.vR4.Model.Element.Claim.related' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.RelatedClaim (SDA3) to Claim:related (vR4) ]]>
  </annotation>
<assign value='##class(HS.FHIR.DTL.Util.Element.Object).Identifier(source.ClaimNumber, "", "uc", " Unique Claim ID", "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBIdentifierType")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.reference' action='set' >
<annotation>
<![CDATA[ File or case reference ]]>
</annotation>
</assign></true> 
</if> 
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Relationship")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Relationship, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Relationship, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.relationship' action='set'  >
<annotation>
<![CDATA[ How the reference claim is related
 --- In this case, any FHIR4 code may be used; related-claim-relationship shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.RelatedClaim.Claim.related")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.RelatedClaim.Claim.related).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
