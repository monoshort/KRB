/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
Class HS.FHIR.DTL.FromSDA.Observation Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Observation, HS.FHIR.vDSTU2.Model.Resource.Observation), Deprecated ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
XData DTL [ Deprecated, XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Observation' targetClass='HS.FHIR.vDSTU2.Model.Resource.Observation' create='new' language='objectscript' >
<annotation>This transform uses the reserved DTL input parameter named &#39;aux&#39;.
For this transform, aux is a local array of strings.  The values held in aux were generated by the SDA to FHIR DTL framework prior to calling into this transform.
aux("ResourceId"): FHIR resource id to assign to the resource being created by this transform.
aux("PatientResourceId"): FHIR resource id for the patient represented by the Patient object in the SDA Container being transformed.
aux("EncounterResourceIds", sda_encounter_number) = FHIR resource id for the Encounters from the SDA Container.</annotation>
<assign value='$G(aux("ResourceId"))' property='target.id.value' action='set' />
<if condition='source.ExternalId &apos;= ""' >
<true>
<assign value='"official"' property='target.identifier.(1).use.value' action='set' />
<assign value='"ExternalId"' property='target.identifier.(1).type.text.value' action='set' />
<assign value='source.ExternalId' property='target.identifier.(1).value.value' action='set' />
</true>
</if>
<assign value='"final"' property='target.status.value' action='set' />
<if condition='..In(source.ObservationCode.Code,"9279-1,8867-4,2710-2,8480-6,8462-4,8310-5,8302-2,8306-3,8287-5,3141-9")' >
<true>
<assign value='"Vital Signs"' property='target.category.text.value' action='set' />
<assign value='"Vital Signs"' property='target.category.coding.(1).display.value' action='set' />
<assign value='"vital-signs"' property='target.category.coding.(1).code.value' action='set' />
<assign value='"http://hl7.org/fhir/observation-category"' property='target.category.coding.(1).system.value' action='set' />
</true>
</if>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' sourceObj='source.ObservationCode' targetObj='target.code' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.PatientReference' targetObj='target.subject' sourceObj='target' aux='.aux' />
<if condition='(source.EncounterNumber &apos;= "") &amp;&amp; ($G(aux("EncounterResourceIds",source.EncounterNumber)) &apos;= "")' >
<true>
<assign value='"Encounter/"_aux("EncounterResourceIds",source.EncounterNumber)' property='target.encounter.reference.value' action='set' />
<assign value='source.EncounterNumber' property='target.encounter.display.value' action='set' />
</true>
</if>
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.ObservationTime)' property='target.effectiveDateTime.value' action='set' />
<if condition='##class(HS.FHIR.DTL.Utils).CPIsDefined(source,"Clinician")' >
<true>
<assign value='"#"_source.Clinician.InternalReference' property='target.performer.(1).reference.value' action='set' />
<if condition='(source.Clinician.Name.GivenName_source.Clinician.Name.FamilyName) &apos;= ""' >
<true>
<assign value='source.Clinician.Name.GivenName_" "_source.Clinician.Name.FamilyName' property='target.performer.(1).display.value' action='set' />
</true>
</if>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CareProvider' targetObj='target.contained.(1).Practitioner' sourceObj='source.Clinician' />
</true>
</if>
<assign value='source.Comments' property='target.comments.value' action='set' />
<if condition='source.ObservationMethods.Count() &gt; 0' >
<true>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' sourceObj='source.ObservationMethods.(1)' targetObj='target.method' />
</true>
</if>

<if condition='source.ObservationValue &apos;= ""' >
<true>
<if condition='(..StartsWith(source.ObservationValue,">=")=0)&amp;&amp;(..StartsWith(source.ObservationValue,"&lt;=")=0)&amp;&amp;(..StartsWith(source.ObservationValue,"=>")=0)&amp;&amp;(..StartsWith(source.ObservationValue,"=&lt;")=0)&amp;&amp;(..StartsWith(source.ObservationValue,">")=0)&amp;&amp;(..StartsWith(source.ObservationValue,"&lt;")=0)'>
<true>
<if condition='##class(HS.FHIR.DTL.Utils).IsNumeric(source.ObservationValue)=1' >
<true>
<assign value='source.ObservationValue' property='target.valueQuantity.value.value' action='set' />
<if condition='##class(HS.FHIR.DTL.Utils).CTIsDefined(source.ObservationCode,"ObservationValueUnits")' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.ObservationCode.ObservationValueUnits.SDACodingStandard)' property='target.valueQuantity.system.value' action='set' />
<assign value='source.ObservationCode.ObservationValueUnits.Description' property='target.valueQuantity.unit.value' action='set' />
<assign value='source.ObservationCode.ObservationValueUnits.Code' property='target.valueQuantity.code.value' action='set' />
</true>
</if>
</true>
<false>
<assign value='source.ObservationValue' property='target.valueString.value' action='set' />
</false>
</if>
</true>
<false>
<if condition='(..StartsWith(source.ObservationValue,">=")=1)||(..StartsWith(source.ObservationValue,"&lt;=")=1)||(..StartsWith(source.ObservationValue,"=>")=1)||(..StartsWith(source.ObservationValue,"=&lt;")=1)' >
<true>
<if condition='##class(HS.FHIR.DTL.Utils).IsNumeric(source.ObservationValue,1)=1' >
<true>
<assign value='..SubString(source.ObservationValue,3)' property='target.valueQuantity.value.value' action='set' />
<if condition='(..StartsWith(source.ObservationValue,">=")=1)||(..StartsWith(source.ObservationValue,"=>")=1)' >
<true>
<assign value='">="' property='target.valueQuantity.comparator.value' action='set' />
</true>
<false>
<assign value='"&lt;="' property='target.valueQuantity.comparator.value' action='set' />
</false>
</if>
<if condition='##class(HS.FHIR.DTL.Utils).CTIsDefined(source.ObservationCode,"ObservationValueUnits")' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.ObservationCode.ObservationValueUnits.SDACodingStandard)' property='target.valueQuantity.system.value' action='set' />
<assign value='source.ObservationCode.ObservationValueUnits.Description' property='target.valueQuantity.unit.value' action='set' />
<assign value='source.ObservationCode.ObservationValueUnits.Code' property='target.valueQuantity.code.value' action='set' />
</true>
</if>
</true>
<false>
<assign value='source.ObservationValue' property='target.valueString.value' action='set' />
</false>
</if>
</true>
<false>
<if condition='(..StartsWith(source.ObservationValue,">")=1)||(..StartsWith(source.ObservationValue,"&lt;")=1)' >
<true>
<if condition='##class(HS.FHIR.DTL.Utils).IsNumeric(source.ObservationValue,1)=1' >
<true>
<assign value='..SubString(source.ObservationValue,2)' property='target.valueQuantity.value.value' action='set' />
<assign value='..SubString(source.ObservationValue,1,1)' property='target.valueQuantity.comparator.value' action='set' />
<if condition='##class(HS.FHIR.DTL.Utils).CTIsDefined(source.ObservationCode,"ObservationValueUnits")' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.ObservationCode.ObservationValueUnits.SDACodingStandard)' property='target.valueQuantity.system.value' action='set' />
<assign value='source.ObservationCode.ObservationValueUnits.Description' property='target.valueQuantity.unit.value' action='set' />
<assign value='source.ObservationCode.ObservationValueUnits.Code' property='target.valueQuantity.code.value' action='set' />
</true>
</if>
</true>
<false>
<assign value='source.ObservationValue' property='target.valueString.value' action='set' />
</false>
</if>
</true>
</if>
</false>
</if>
</false>
</if>
</true>
<false>
<if condition='##class(HS.FHIR.DTL.Utils).CTIsDefined(source,"ObservationCodedValue")' >
<true>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' sourceObj='source.ObservationCodedValue' targetObj='target.valueCodeableConcept' />
</true>
</if>
</false>
</if>

</transform>
}

}
