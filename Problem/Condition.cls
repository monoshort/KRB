/// Transforms SDA3 HS.SDA3.Problem to vR4 Condition
Class HS.FHIR.DTL.SDA3.vR4.Problem.Condition Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Problem, HS.FHIR.DTL.vR4.Model.Resource.Condition), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Problem' targetClass='HS.FHIR.DTL.vR4.Model.Resource.Condition' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Problem (SDA3) to Condition (vR4) ]]>
  </annotation>
<if condition='&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source,"Category")'> 
<true>
<assign value='"problem-list-item"' property='target.category.(1).coding.(1).code' action='set' >
<annotation>
<![CDATA[ problem-list-item | encounter-diagnosis
 --- This target is one field within a CodeableConcept object assigned to the target Condition:category.    ]]>
</annotation>
</assign>
</true>
</if>
<if condition='&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source,"Category")'> 
<true>
<assign value='"Problem List Item"' property='target.category.(1).coding.(1).display' action='set' >
<annotation>
<![CDATA[ Representation defined by the system
 --- This target is one field within a CodeableConcept object assigned to the target Condition:category.    ]]>
</annotation>
</assign>
</true>
</if>
<if condition='&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source,"Category")'> 
<true>
<assign value='"Problem List Item"' property='target.category.(1).text' action='set' >
<annotation>
<![CDATA[ Plain text representation of the concept
 --- This target is one field within a CodeableConcept object assigned to the target Condition:category.    ]]>
</annotation>
</assign>
</true>
</if>
<if condition='&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source,"Category")'> 
<true>
<assign value='"http://terminology.hl7.org/CodeSystem/condition-category"' property='target.category.(1).coding.(1).system' action='set' >
<annotation>
<![CDATA[ Identity of the terminology system
 --- This target is one field within a CodeableConcept object assigned to the target Condition:category.    ]]>
</annotation>
</assign>
</true>
</if>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.CustomPairs).Extension(source.CustomPairs, .target, .aux)' property='value' action='set' />
<assign value='target.extension.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/problem-custom-pairs"' property='value.url' action='set' />
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
<![CDATA[ Who has the condition? ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.IsDefined("Status") &amp;&amp; (##class(HS.FHIR.DTL.Util.Lookup).CodeTable(source.Status, "Condition", "clinicalStatus", .aux, "condition-clinical|4.0.1") &apos;= "")'> 
<true>
<assign value='"http://terminology.hl7.org/CodeSystem/condition-clinical"' property='target.clinicalStatus.coding.(1).system' action='set' >
<annotation>
<![CDATA[ Identity of the terminology system
Note: If a lookup table was used for the status, add FHIR's required CodeSystem to the status object
 --- This target is one field within a CodeableConcept object assigned to the target Condition:clinicalStatus.    ]]>
</annotation>
</assign>
</true>
</if>
<if condition='source.IsDefined("VerificationStatus") &amp;&amp; (##class(HS.FHIR.DTL.Util.Lookup).CodeTable(source.VerificationStatus, "Condition", "verificationStatus", .aux, "condition-ver-status|4.0.1") &apos;= "")'> 
<true>
<assign value='"http://terminology.hl7.org/CodeSystem/condition-ver-status"' property='target.verificationStatus.coding.(1).system' action='set' >
<annotation>
<![CDATA[ Identity of the terminology system
Note: If a lookup table was used for the status, add FHIR's required CodeSystem to the status object
 --- This target is one field within a CodeableConcept object assigned to the target Condition:verificationStatus.    ]]>
</annotation>
</assign>
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Category")'> 
<true>
<assign value='target.category.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Category, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Category, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.category' action='set' key='index'  >
<annotation>
<![CDATA[ problem-list-item | encounter-diagnosis
 --- In this case, condition-category is the *Required* FHIR4 ValueSet for codes, but if you need to express meanings not found in condition-category, you may formally *Extend* condition-category to add codes to it. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='source.CauseofDeath&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.CauseofDeath, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.CauseofDeath, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/problem-causeof-death"' property='tmp.url' action='set' />
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
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Clinician")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Practitioner).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Clinician, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.CareProvider.Practitioner")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Clinician, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.Clinician, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.asserter' action='set'  >
<annotation>
<![CDATA[ Person who asserts this condition ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<if condition='source.Comments&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Comments, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Comments, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/problem-comments"' property='tmp.url' action='set' />
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/problem-encounter-number"' property='tmp.url' action='set' />
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
<assign value='aux("transformer").GetReference("Encounter",source.EncounterNumber)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.encounter' action='set' >
<annotation>
<![CDATA[ Encounter created as part of ]]>
</annotation>
</assign></true> 
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/problem-entered-at"' property='tmp.url' action='set' />
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
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/problem-entered-by"' property='tmp.url' action='set' />
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
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Practitioner).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.EnteredBy, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.Practitioner")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.EnteredBy, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.EnteredBy, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.recorder' action='set'  >
<annotation>
<![CDATA[ Who recorded the condition ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.EnteredOn, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.recordedDate' action='set' >
<annotation>
<![CDATA[ Date record was first recorded ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExternalId).Identifier(source.ExternalId)' property='value' action='set' />
<assign value='target.identifier.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.identifier' action='set' key='index'  >
<annotation>
<![CDATA[ External Ids for this condition ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.FromTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.onsetDateTime' action='set' >
<annotation>
<![CDATA[ Estimated or actual date,  date-time, or age ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.IdentificationTime&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.IdentificationTime, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.TimeStamp.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.IdentificationTime, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://hl7.org/fhir/StructureDefinition/condition-assertedDate"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
<foreach property='source.Identifiers()' key='st' >
<assign value='target.identifier.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.Identifier).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Identifiers.(st), "HS.FHIR.DTL.SDA3.vR4.Identifier.Identifier")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Identifiers.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.identifier' action='set' key='index'  >
<annotation>
<![CDATA[ Other identifiers for the document ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Problem")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Problem, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Problem, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.code' action='set'  >
<annotation>
<![CDATA[ Identification of the condition, problem or diagnosis
 --- In this case, any FHIR4 code may be used; condition-code shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='source.ProblemDetails&apos;=""'> 
<true>
<assign value='target.note.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.Annotation).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ProblemDetails, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.String.Annotation")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ProblemDetails, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.note' action='set' key='index'  >
<annotation>
<![CDATA[ Additional information about the Condition ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<if condition='source.IsDefined("Status") &amp;&amp; (##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.Status.SDACodingStandard) = "http://terminology.hl7.org/CodeSystem/condition-clinical")'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Status")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Status, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Status, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.clinicalStatus' action='set'  >
<annotation>
<![CDATA[ active | recurrence | relapse | inactive | remission | resolved
Note: If the CodeTable uses FHIR's required CodeSystem, no lookup table is needed
 --- In this case, condition-clinical|4.0.1 is the *Required* FHIR4 ValueSet for codes; you may NOT extend condition-clinical|4.0.1 and you may NOT use codes from other ValueSets. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
</true>
</if>
<if condition='source.IsDefined("Status") &amp;&amp; (##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.Status.SDACodingStandard) &apos;= "http://terminology.hl7.org/CodeSystem/condition-clinical")'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Status")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).CodeTable(source.Status, "Condition", "clinicalStatus", .aux, "condition-clinical|4.0.1")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.clinicalStatus.coding.(1).code' action='set' >
<annotation>
<![CDATA[ active | recurrence | relapse | inactive | remission | resolved
Note: If the CodeTable doesn't claim to use FHIR's required CodeSystem, refer to the lookup table
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
</true>
</if>
<if condition='&apos;$isobject(target.clinicalStatus)'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Status")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Status, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Status, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/problem-status"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations
Note: If neither of the above work, preserve the status in a FHIR extension ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
</true>
</if>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.ToTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.abatementDateTime' action='set' >
<annotation>
<![CDATA[ When in resolution/remission ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.IsDefined("VerificationStatus") &amp;&amp; (##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.VerificationStatus.SDACodingStandard) = "http://terminology.hl7.org/CodeSystem/condition-ver-status")'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "VerificationStatus")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.VerificationStatus, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.VerificationStatus, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.verificationStatus' action='set'  >
<annotation>
<![CDATA[ unconfirmed | provisional | differential | confirmed | refuted | entered-in-error
Note: If the CodeTable uses FHIR's required CodeSystem, no lookup table is needed
 --- In this case, condition-ver-status|4.0.1 is the *Required* FHIR4 ValueSet for codes; you may NOT extend condition-ver-status|4.0.1 and you may NOT use codes from other ValueSets. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
</true>
</if>
<if condition='source.IsDefined("VerificationStatus") &amp;&amp; (##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.VerificationStatus.SDACodingStandard) &apos;= "http://terminology.hl7.org/CodeSystem/condition-ver-status")'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "VerificationStatus")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).CodeTable(source.VerificationStatus, "Condition", "verificationStatus", .aux, "condition-ver-status|4.0.1")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.verificationStatus.coding.(1).code' action='set' >
<annotation>
<![CDATA[ unconfirmed | provisional | differential | confirmed | refuted | entered-in-error
Note: If the CodeTable doesn't claim to use FHIR's required CodeSystem, refer to the lookup table
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
</true>
</if>
<if condition='&apos;$isobject(target.verificationStatus)'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "VerificationStatus")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.VerificationStatus, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.VerificationStatus, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/problem-verification-status"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations
Note: If neither of the above work, preserve the status in a FHIR extension ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
</true>
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Problem.Condition")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Problem.Condition).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
<if condition='source.IsDefined("Problem") &amp;&amp; (##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3", "vR4", "HS.SDA3.HealthConcern", "condition-code", source.Problem.Code)= source.Problem.SDACodingStandard)'> 
<true>
<assign value='target.category.Count()+1' property='index' action='set' />
<assign value='"sdoh"' property='target.category.(index).coding.(1).code' action='set' />
<assign value='"http://hl7.org/fhir/us/core/CodeSystem/us-core-tags"' property='target.category.(index).coding.(1).system' action='set' />
<assign value='"SDOH"' property='target.category.(index).coding.(1).display' action='set' />
<assign value='"Social Determinants Of Health"' property='target.category.(index).text' action='set' />
</true>
</if>
</transform>
}

}
