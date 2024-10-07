/// Transforms SDA3 HS.SDA3.Survey to vR4 Observation
Class HS.FHIR.DTL.SDA3.vR4.Survey.Observation Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Survey, HS.FHIR.DTL.vR4.Model.Resource.Observation), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Survey' targetClass='HS.FHIR.DTL.vR4.Model.Resource.Observation' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Survey (SDA3) to Observation (vR4) ]]>
  </annotation>
<assign value='"survey"' property='target.category.(1).coding.(1).code' action='set' >
<annotation>
<![CDATA[ Classification of  type of observation
 --- This target is one field within a CodeableConcept object assigned to the target Observation:category.    ]]>
</annotation>
</assign>
<assign value='"http://terminology.hl7.org/CodeSystem/observation-category"' property='target.category.(1).coding.(1).system' action='set' >
<annotation>
<![CDATA[ Identity of the terminology system
 --- This target is one field within a CodeableConcept object assigned to the target Observation:category.    ]]>
</annotation>
</assign>
<assign value='"Survey"' property='target.category.(1).coding.(1).display' action='set' >
<annotation>
<![CDATA[ Representation defined by the system
 --- This target is one field within a CodeableConcept object assigned to the target Observation:category.    ]]>
</annotation>
</assign>
<assign value='"Survey"' property='target.category.(1).text' action='set' >
<annotation>
<![CDATA[ Plain text representation of the concept
 --- This target is one field within a CodeableConcept object assigned to the target Observation:category.    ]]>
</annotation>
</assign>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.CustomPairs).Extension(source.CustomPairs, .target, .aux)' property='value' action='set' />
<assign value='target.extension.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/survey"' property='value.url' action='set' />
<assign value='value' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations
 --- When the SDA3 source data contains a CustomPairs collection, and the target is FHIR, the collection is mapped to a FHIR extension that contains a Parameters resource. This Parameters resource is a collection of paired fields: name and valueString.   ]]>
</annotation>
</assign></true> 
</if> 
<assign value='aux("transformer").GetPatientReference()' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.subject' action='set' >
<annotation>
<![CDATA[ Who and/or what the observation is about ]]>
</annotation>
</assign></true> 
</if> 
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "DataAbsentReason")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.DataAbsentReason, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.DataAbsentReason, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.dataAbsentReason' action='set'  >
<annotation>
<![CDATA[ Why the result is missing
 --- In this case, data-absent-reason is the *Required* FHIR4 ValueSet for codes, but if you need to express meanings not found in data-absent-reason, you may formally *Extend* data-absent-reason to add codes to it. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.EffectiveDateTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.effectiveDateTime' action='set' >
<annotation>
<![CDATA[ Clinically relevant time/time-period for observation ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExternalId).Identifier(source.ExternalId)' property='value' action='set' />
<assign value='target.identifier.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.identifier' action='set' key='index'  >
<annotation>
<![CDATA[ Business Identifier for observation ]]>
</annotation>
</assign></true> 
</if> 
<foreach property='source.MemberIDs()' key='st' >
<assign value='aux("transformer").GetReference("Observation", source.MemberIDs.GetAt(st))' property='value' action='set' />
<assign value='target.hasMember.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.hasMember' action='set' key='index'  >
<annotation>
<![CDATA[ Related resource that belongs to the Observation group ]]>
</annotation>
</assign></true> 
</if> </foreach>
<foreach property='source.Performers()' key='st' >
<assign value='target.performer.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Practitioner).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Performers.(st), "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.CareProvider.Practitioner")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Performers.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.Performers.(st), tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.performer' action='set' key='index'  >
<annotation>
<![CDATA[ Who is responsible for the observation ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</foreach>
<foreach property='source.QuestionnaireSourceIDs()' key='st' >
<assign value='aux("transformer").GetReference("QuestionnaireResponse", source.QuestionnaireSourceIDs.GetAt(st))' property='value' action='set' />
<assign value='target.derivedFrom.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.derivedFrom' action='set' key='index'  >
<annotation>
<![CDATA[ Related measurements the observation is made from ]]>
</annotation>
</assign></true> 
</if> </foreach>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vR4","HS.SDA3.Survey:Status","observation-status|4.0.1",source.Status)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.status' action='set' >
<annotation>
<![CDATA[ registered | preliminary | final | amended +
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"unknown"' property='target.status' action='set' />
</false> 
</if> 
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "SurveyCode")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.SurveyCode, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.SurveyCode, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.code' action='set'  >
<annotation>
<![CDATA[ Type of observation (code / type)
 --- In this case, any FHIR4 code may be used; observation-codes shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<foreach property='source.SurveySourceIDs()' key='st' >
<assign value='aux("transformer").GetReference("Observation", source.SurveySourceIDs.GetAt(st))' property='value' action='set' />
<assign value='target.derivedFrom.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.derivedFrom' action='set' key='index'  >
<annotation>
<![CDATA[ Related measurements the observation is made from ]]>
</annotation>
</assign></true> 
</if> </foreach>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "UnitOfMeasure")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.Quantity).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.UnitOfMeasure, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.Quantity")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.UnitOfMeasure, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.valueQuantity' action='set'  >
<annotation>
<![CDATA[ Actual result ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='source.UnitOfMeasure.Code&apos;=""'> 
<true>
<if condition='source.ValueNumeric &apos;= ""'> 
<true>
<if condition='source.UnitOfMeasure.Code&apos;=""'> 
<true> 
<assign value='source.UnitOfMeasure.Code' property='target.valueQuantity.code' action='set' >
<annotation>
<![CDATA[ Coded form of the unit ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
</true>
</if>
<if condition='(source.ValueNumeric &apos;= "") &amp;&amp; (##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.UnitOfMeasure.SDACodingStandard) = "")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.UnitOfMeasure.Code)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.valueQuantity.system' action='set' >
<annotation>
<![CDATA[ System that defines coded unit form ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"http://www.intersystems.com/fhir/system"' property='target.valueQuantity.system' action='set' />
</false> 
</if> 
</true>
</if>
<if condition='source.UnitOfMeasure.Description&apos;=""'> 
<true>
<if condition='source.ValueNumeric &apos;= ""'> 
<true>
<if condition='source.UnitOfMeasure.Description&apos;=""'> 
<true> 
<assign value='source.UnitOfMeasure.Description' property='target.valueQuantity.unit' action='set' >
<annotation>
<![CDATA[ Unit representation ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
</true>
</if>
<if condition='source.UnitOfMeasure.SDACodingStandard&apos;=""'> 
<true>
<if condition='source.ValueNumeric &apos;= ""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.UnitOfMeasure.SDACodingStandard)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.valueQuantity.system' action='set' >
<annotation>
<![CDATA[ System that defines coded unit form ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
</true>
</if>
<if condition='source.UnitOfMeasure.SDACodingStandard&apos;=""'> 
<true>
<if condition='(source.ValueNumeric &apos;= "") &amp;&amp; (##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.UnitOfMeasure.SDACodingStandard) = "")'> 
<true>
<assign value='1' property='index' action='set' />
<if condition='target.valueQuantity&apos;=""'> 
<true> 
<assign value='target.valueQuantity.extension.Count()+1' property='index' action='set' />
</true> 
</if> 
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.UnitOfMeasure.SDACodingStandard, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.UnitOfMeasure.SDACodingStandard, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/survey-unit-of-measure-s-d-a-coding-standard"' property='tmp.url' action='set' />
<assign value='tmp' property='target.valueQuantity.extension' action='set' key='index'  >
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
<if condition='(source.ValueNumeric = "") &amp;&amp; (source.ValueText = "")'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "ValueCoded")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ValueCoded, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ValueCoded, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.valueCodeableConcept' action='set'  >
<annotation>
<![CDATA[ Actual result ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
</true>
</if>
<if condition='source.ValueNumeric&apos;=""'> 
<true>
<if condition='source.ValueNumeric&apos;=""'> 
<true> 
<assign value='source.ValueNumeric' property='target.valueQuantity.value' action='set' >
<annotation>
<![CDATA[ Numerical value (with implicit precision) ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<if condition='source.ValueNumeric = ""'> 
<true>
<if condition='source.ValueText&apos;=""'> 
<true> 
<assign value='source.ValueText' property='target.valueString' action='set' >
<annotation>
<![CDATA[ Actual result ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Survey.Observation")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Survey.Observation).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
