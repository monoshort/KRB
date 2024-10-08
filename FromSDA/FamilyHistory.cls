/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
Class HS.FHIR.DTL.FromSDA.FamilyHistory Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.FamilyHistory, HS.FHIR.vDSTU2.Model.Resource.FamilyMemberHistory), Deprecated ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
XData DTL [ Deprecated, XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.FamilyHistory' targetClass='HS.FHIR.vDSTU2.Model.Resource.FamilyMemberHistory' create='new' language='objectscript' >
<annotation>This transform uses the reserved DTL input parameter named &#39;aux&#39;.
For this transform, aux is a local array of strings.  The values held in aux were generated by the SDA to FHIR DTL framework prior to calling into this transform.
aux("ResourceId"): FHIR resource id to assign to the resource being created by this transform.
aux("PatientResourceId"): FHIR resource id for the patient represented by the Patient object in the SDA Container being transformed.</annotation>
<assign value='$G(aux("ResourceId"))' property='target.id.value' action='set' />
<if condition='source.ExternalId &apos;= ""' >
<true>
<assign value='"official"' property='target.identifier.(1).use.value' action='set' />
<assign value='"ExternalId"' property='target.identifier.(1).type.text.value' action='set' />
<assign value='source.ExternalId' property='target.identifier.(1).value.value' action='set' />
</true>
</if>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.PatientReference' targetObj='target.patient' sourceObj='target' aux='.aux' />
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.EnteredOn)' property='target.date.value' action='set' />
<if condition='source.UpdatedOn &apos;= ""' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.UpdatedOn)' property='target.date.value' action='set' />
</true>
</if>
<assign value='"completed"' property='target.status.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' sourceObj='source.FamilyMember' targetObj='target.relationship' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' sourceObj='source.Diagnosis' targetObj='target.condition.(1).code' />
<if condition='source.FromTime &apos;= ""' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.FromTime)' property='target.condition.(1).onsetPeriod.start.value' action='set' />
</true>
</if>
<if condition='source.ToTime &apos;= ""' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.ToTime)' property='target.condition.(1).onsetPeriod.end.value' action='set' />
</true>
</if>
<if condition='source.NoteText &apos;= ""' >
<true>
<assign value='source.NoteText' property='target.note.text.value' action='set' />
</true>
</if>
</transform>
}

}
