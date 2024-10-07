/// Transforms SDA3 HS.SDA3.QuestionnaireResponse to vR4 QuestionnaireResponse
Class HS.FHIR.DTL.SDA3.vR4.QuestionnaireResponse.QuestionnaireResponse Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.QuestionnaireResponse, HS.FHIR.DTL.vR4.Model.Resource.QuestionnaireResponse), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.QuestionnaireResponse' targetClass='HS.FHIR.DTL.vR4.Model.Resource.QuestionnaireResponse' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.QuestionnaireResponse (SDA3) to QuestionnaireResponse (vR4) ]]>
  </annotation>
<assign value='aux("transformer").GetPatientReference()' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.subject' action='set' >
<annotation>
<![CDATA[ The subject of the questions ]]>
</annotation>
</assign></true> 
</if> 
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Author")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Practitioner).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Author, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.CareProvider.Practitioner")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Author, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.Author, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.author' action='set'  >
<annotation>
<![CDATA[ Person who received and recorded the answers ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.Authored, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.authored' action='set' >
<annotation>
<![CDATA[ Date the answers were gathered ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExternalId).Identifier(source.ExternalId)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.identifier' action='set' >
<annotation>
<![CDATA[ Unique id for this set of answers ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.QuestionnaireUri&apos;=""'> 
<true> 
<assign value='source.QuestionnaireUri' property='target.questionnaire' action='set' >
<annotation>
<![CDATA[ Form being answered ]]>
</annotation>
</assign></true> 
</if> 

<assign value='##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vR4","HS.SDA3.QuestionnaireResponse:Status","questionnaire-answers-status|4.0.1",source.Status)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.status' action='set' >
<annotation>
<![CDATA[ in-progress | completed | amended | entered-in-error | stopped
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"in-progress"' property='target.status' action='set' />
</false> 
</if> 
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.QuestionnaireResponse.QuestionnaireResponse")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.QuestionnaireResponse.QuestionnaireResponse).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
