/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
Class HS.FHIR.DTL.FromSDA.Encounter Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Encounter, HS.FHIR.vDSTU2.Model.Resource.Encounter), Deprecated ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
XData DTL [ Deprecated, XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Encounter' targetClass='HS.FHIR.vDSTU2.Model.Resource.Encounter' create='new' language='objectscript' >
<annotation>This transform uses the reserved DTL input parameter named &#39;aux&#39;.
For this transform, aux is a local array of strings.  The values held in aux were generated by the SDA to FHIR DTL framework prior to calling into this transform.
aux("ResourceId"): FHIR resource id to assign to the resource being created by this transform.
aux("PatientResourceId"): FHIR resource id for the patient represented by the Patient object in the SDA Container being transformed.
aux("EncounterResourceIds", sda_encounter_number) = FHIR resource id for the Encounters from the SDA Container.</annotation>
<if condition='source.EncounterNumber &apos;= ""' >
<true>
<assign value='$G(aux("EncounterResourceIds", source.EncounterNumber))' property='target.id.value' action='set' />
<assign value='"official"' property='target.identifier.(1).use.value' action='set' />
<assign value='source.EncounterNumber' property='target.identifier.(1).value.value' action='set' />
</true>
</if>
<if condition='(source.FromTime = "") &amp;&amp; (source.ToTime = "")' >
<annotation>SDA considers blank FromTime to be current date/time.</annotation>
<true>
<assign value='"in-progress"' property='target.status.value' action='set' />
</true>
<false>
<if condition='(source.FromTime &apos;= "") &amp;&amp; (source.ToTime = "")' >
<true>
<assign value='"in-progress"' property='target.status.value' action='set' />
</true>
<false>
<assign value='"finished"' property='target.status.value' action='set' />
</false>
</if>
</false>
</if>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.PatientReference' targetObj='target.patient' sourceObj='target' aux='.aux' />
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.ToTime)' property='target.period.end.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.FromTime)' property='target.period.start.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' targetObj='target.type.(1)' sourceObj='source.AdmissionType' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' targetObj='target.priority' sourceObj='source.Priority' />
<assign value='##class(HS.FHIR.DTL.Utils).LookupFHIR("FromSDAEncounterEncounterType",source.EncounterType,"outpatient",3)' property='target.class.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' targetObj='target.hospitalization.admitSource' sourceObj='source.AdmissionSource' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' targetObj='target.hospitalization.dischargeDisposition' sourceObj='source.SeparationMode' />
<code>
<![CDATA[ set iContained = 1]]></code>
<if condition='##class(HS.FHIR.DTL.Utils).CPIsDefined(source,"AdmittingClinician")' >
<true>
<assign value='"#"_source.AdmittingClinician.InternalReference' property='target.participant.(iContained).individual.reference.value' action='set' />
<assign value='source.AdmittingClinician.Name.GivenName_" "_source.AdmittingClinician.Name.FamilyName' property='target.participant.(iContained).individual.display.value' action='set' />
<assign value='"Admitting Clinician"' property='target.participant.(iContained).type.(1).text.value' action='set' />
<assign value='"admitter"' property='target.participant.(iContained).type.(1).coding.(1).display.value' action='set' />
<assign value='"ADM"' property='target.participant.(iContained).type.(1).coding.(1).code.value' action='set' />
<assign value='"http://hl7.org/fhir/v3/ParticipationType"' property='target.participant.(iContained).type.(1).coding.(1).system.value' action='set' />
<assign value='"v1"' property='target.participant.(iContained).type.(1).coding.(1).version.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CareProvider' targetObj='target.contained.(iContained).Practitioner' sourceObj='source.AdmittingClinician' />
<code>
<![CDATA[ set iContained = iContained + 1]]></code>
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Utils).RDIsDefined(source,"ReferringClinician")' >
<true>
<assign value='"#"_source.ReferringClinician.InternalReference' property='target.participant.(iContained).individual.reference.value' action='set' />
<assign value='source.ReferringClinician.Name.GivenName_" "_source.ReferringClinician.Name.FamilyName' property='target.participant.(iContained).individual.display.value' action='set' />
<assign value='"Referring Clinician"' property='target.participant.(iContained).type.(1).text.value' action='set' />
<assign value='"referrer"' property='target.participant.(iContained).type.(1).coding.(1).display.value' action='set' />
<assign value='"REF"' property='target.participant.(iContained).type.(1).coding.(1).code.value' action='set' />
<assign value='"http://hl7.org/fhir/v3/ParticipationType"' property='target.participant.(iContained).type.(1).coding.(1).system.value' action='set' />
<assign value='"v1"' property='target.participant.(iContained).type.(1).coding.(1).version.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.ReferralDoctor' targetObj='target.contained.(iContained).Practitioner' sourceObj='source.ReferringClinician' />
<code>
<![CDATA[ set iContained = iContained + 1]]></code>
</true>
</if>
<foreach property='source.AttendingClinicians()' key='k1' >
<assign value='"#"_source.AttendingClinicians.(k1).InternalReference' property='target.participant.(iContained).individual.reference.value' action='set' />
<assign value='source.AttendingClinicians.(k1).Name.GivenName_" "_source.AttendingClinicians.(k1).Name.FamilyName' property='target.participant.(iContained).individual.display.value' action='set' />
<assign value='"Attending Clinician"' property='target.participant.(iContained).type.(1).text.value' action='set' />
<assign value='"attender"' property='target.participant.(iContained).type.(1).coding.(1).display.value' action='set' />
<assign value='"ATND"' property='target.participant.(iContained).type.(1).coding.(1).code.value' action='set' />
<assign value='"http://hl7.org/fhir/v3/ParticipationType"' property='target.participant.(iContained).type.(1).coding.(1).system.value' action='set' />
<assign value='"v1"' property='target.participant.(iContained).type.(1).coding.(1).version.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CareProvider' targetObj='target.contained.(iContained).Practitioner' sourceObj='source.AttendingClinicians.(k1)' />
<code>
<![CDATA[ set iContained = iContained + 1]]></code>
</foreach>
<foreach property='source.ConsultingClinicians()' key='k2' >
<assign value='"#"_source.ConsultingClinicians.(k2).InternalReference' property='target.participant.(iContained).individual.reference.value' action='set' />
<assign value='source.ConsultingClinicians.(k2).Name.GivenName_" "_source.ConsultingClinicians.(k2).Name.FamilyName' property='target.participant.(iContained).individual.display.value' action='set' />
<assign value='"Consulting Clinician"' property='target.participant.(iContained).type.(1).text.value' action='set' />
<assign value='"consultant"' property='target.participant.(iContained).type.(1).coding.(1).display.value' action='set' />
<assign value='"CON"' property='target.participant.(iContained).type.(1).coding.(1).code.value' action='set' />
<assign value='"http://hl7.org/fhir/v3/ParticipationType"' property='target.participant.(iContained).type.(1).coding.(1).system.value' action='set' />
<assign value='"v1"' property='target.participant.(iContained).type.(1).coding.(1).version.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CareProvider' targetObj='target.contained.(iContained).Practitioner' sourceObj='source.ConsultingClinicians.(k2)' />
<code>
<![CDATA[ set iContained = iContained + 1]]></code>
</foreach>
<if condition='##class(HS.FHIR.DTL.Utils).HCFIsDefined(source, "HealthCareFacility")' >
<true>
<assign value='"#"_source.HealthCareFacility.Organization.InternalReference' property='target.serviceProvider.reference.value' action='set' />
<assign value='source.HealthCareFacility.Organization.Description' property='target.serviceProvider.display.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.HealthCareFacilityOrganization' targetObj='target.contained.(iContained).Organization' sourceObj='source.HealthCareFacility' />
<code>
<![CDATA[ set iContained = iContained + 1]]></code>
</true>
</if>
</transform>
}

}
