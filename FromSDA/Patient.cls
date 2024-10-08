/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
Class HS.FHIR.DTL.FromSDA.Patient Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Patient, HS.FHIR.vDSTU2.Model.Resource.Patient), Deprecated ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
XData DTL [ Deprecated, XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Patient' targetClass='HS.FHIR.vDSTU2.Model.Resource.Patient' create='new' language='objectscript' >
<annotation>This transform uses the reserved DTL input parameter named &#39;aux&#39;.
For this transform, aux is a local array of strings.  The values held in aux were generated by the SDA to FHIR DTL framework prior to calling into this transform.
aux("PatientResourceId"): FHIR resource id for the patient represented by the Patient object in the SDA Container being transformed.</annotation>
<code>
<![CDATA[ set identifier = 1]]></code>
<assign value='$G(aux("PatientResourceId"))' property='target.id.value' action='set' />
<if condition='source.MPIID &apos;= ""' >
<true>
<assign value='"official"' property='target.identifier.(identifier).use.value' action='set' />
<assign value='source.MPIID' property='target.identifier.(identifier).value.value' action='set' />
<assign value='"MPIID"' property='target.identifier.(identifier).type.coding.(1).code.value' action='set' />
<assign value='"MPIID"' property='target.identifier.(identifier).type.text.value' action='set' />
<code>
<![CDATA[ set identifier = identifier + 1]]></code>
</true>
<false>
<if condition='source.ExternalId  &apos;= ""' >
<true>
<assign value='source.ExternalId' property='target.identifier.(identifier).value.value' action='set' />
<code>
<![CDATA[ set identifier = identifier + 1]]></code>
</true>
</if>
</false>
</if>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.Name' targetObj='target.name.(1)' sourceObj='source.Name' />
<assign value='"official"' property='target.name.(1).use.value' action='set' />
<foreach property='source.Aliases()' key='k1' >
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.NameAlias' targetObj='target.name.(k1+1)' sourceObj='source.Aliases.(k1)' />
</foreach>
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.DeathTime)' property='target.deceasedDateTime.value' action='set' />
<assign value='source.BirthOrder' property='target.multipleBirthInteger.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDate(source.BirthTime)' property='target.birthDate.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.Gender' targetObj='target.gender' sourceObj='source.Gender' />
<assign value='source.IsDead' property='target.deceasedBoolean.value' action='set' />
<foreach property='source.Addresses()' key='k2' >
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.Address' targetObj='target.address.(k2)' sourceObj='source.Addresses.(k2)' />
</foreach>
<foreach property='source.SupportContacts()' key='k3' >
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.Name' targetObj='target.contact.(k3).name' sourceObj='source.SupportContacts.(k3).Name' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.Address' targetObj='target.contact.(k3).address' sourceObj='source.SupportContacts.(k3).Address' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.Gender' targetObj='target.contact.(k3).gender' sourceObj='source.SupportContacts.(k3).Gender' />
<if condition='(source.SupportContacts.(k3).Relationship.Code &apos;= "")||(source.SupportContacts.(k3).Relationship.Description &apos;= "")' >
<true>
<assign value='source.SupportContacts.(k3).Relationship.OriginalText' property='target.contact.(k3).relationship.(1).text.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.SupportContacts.(k3).Relationship.SDACodingStandard)' property='target.contact.(k3).relationship.(1).coding.(1).system.value' action='set' />
<assign value='source.SupportContacts.(k3).Relationship.CodeSystemVersionId' property='target.contact.(k3).relationship.(1).coding.(1).version.value' action='set' />
<assign value='source.SupportContacts.(k3).Relationship.Code' property='target.contact.(k3).relationship.(1).coding.(1).code.value' action='set' />
<assign value='source.SupportContacts.(k3).Relationship.Description' property='target.contact.(k3).relationship.(1).coding.(1).display.value' action='set' />
</true>
</if>
<if condition='(source.SupportContacts.(k3).FromTime &apos;= "")&amp;&amp;(source.SupportContacts.(k3).ToTime &apos;= "")' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.SupportContacts.(k3).FromTime)' property='target.contact.(k3).period.start.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.SupportContacts.(k3).ToTime)' property='target.contact.(k3).period.end.value' action='set' />
</true>
</if>
<code>
<![CDATA[ set iTelecom = 1]]></code>
<if condition='source.SupportContacts.(k3).ContactInfo.HomePhoneNumber &apos;=""' >
<true>
<assign value='source.SupportContacts.(k3).ContactInfo.HomePhoneNumber' property='target.contact.(k3).telecom.(iTelecom).value.value' action='set' />
<assign value='"phone"' property='target.contact.(k3).telecom.(iTelecom).system.value' action='set' />
<assign value='"home"' property='target.contact.(k3).telecom.(iTelecom).use.value' action='set' />
<code>
<![CDATA[ set iTelecom = iTelecom + 1]]></code>
</true>
</if>
<if condition='source.SupportContacts.(k3).ContactInfo.WorkPhoneNumber &apos;= ""' >
<true>
<assign value='source.SupportContacts.(k3).ContactInfo.WorkPhoneNumber' property='target.contact.(k3).telecom.(iTelecom).value.value' action='set' />
<assign value='"phone"' property='target.contact.(k3).telecom.(iTelecom).system.value' action='set' />
<assign value='"work"' property='target.contact.(k3).telecom.(iTelecom).use.value' action='set' />
<code>
<![CDATA[ set iTelecom = iTelecom + 1]]></code>
</true>
</if>
<if condition='source.SupportContacts.(k3).ContactInfo.MobilePhoneNumber &apos;= ""' >
<true>
<assign value='source.SupportContacts.(k3).ContactInfo.MobilePhoneNumber' property='target.contact.(k3).telecom.(iTelecom).value.value' action='set' />
<assign value='"phone"' property='target.contact.(k3).telecom.(iTelecom).system.value' action='set' />
<assign value='"mobile"' property='target.contact.(k3).telecom.(iTelecom).use.value' action='set' />
<code>
<![CDATA[ set iTelecom = iTelecom + 1]]></code>
</true>
</if>
<if condition='source.SupportContacts.(k3).ContactInfo.EmailAddress &apos;= ""' >
<true>
<assign value='source.SupportContacts.(k3).ContactInfo.EmailAddress' property='target.contact.(k3).telecom.(iTelecom).value.value' action='set' />
<assign value='"email"' property='target.contact.(k3).telecom.(iTelecom).system.value' action='set' />
<code>
<![CDATA[ set iTelecom = iTelecom + 1]]></code>
</true>
</if>
</foreach>
<if condition='##class(HS.FHIR.DTL.Utils).CTIsDefined(source,"PrimaryLanguage")' >
<true>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' targetObj='target.communication.(1).language' sourceObj='source.PrimaryLanguage' />
<assign value='"true"' property='target.communication.(1).preferred.value' action='set' />
</true>
</if>
<foreach property='source.OtherLanguages()' key='k4' >
<assign value='source.OtherLanguages.(k4).PreferredLanguage.OriginalText' property='target.communication.(k4+1).language.text.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.OtherLanguages.(k4).PreferredLanguage.SDACodingStandard)' property='target.communication.(k4+1).language.coding.(1).system.value' action='set' />
<assign value='source.OtherLanguages.(k4).PreferredLanguage.Code' property='target.communication.(k4+1).language.coding.(1).code.value' action='set' />
<assign value='source.OtherLanguages.(k4).PreferredLanguage.Description' property='target.communication.(k4+1).language.coding.(1).display.value' action='set' />
<assign value='source.OtherLanguages.(k4).PreferredLanguage.CodeSystemVersionId' property='target.communication.(k4+1).language.coding.(1).version.value' action='set' />
</foreach>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' targetObj='target.maritalStatus' sourceObj='source.MaritalStatus' />
<code>
<![CDATA[ set iTelecom = 1]]></code>
<if condition='source.ContactInfo.HomePhoneNumber &apos;=""' >
<true>
<assign value='source.ContactInfo.HomePhoneNumber' property='target.telecom.(iTelecom).value.value' action='set' />
<assign value='"phone"' property='target.telecom.(iTelecom).system.value' action='set' />
<assign value='"home"' property='target.telecom.(iTelecom).use.value' action='set' />
<code>
<![CDATA[ set iTelecom = iTelecom + 1]]></code>
</true>
</if>
<if condition='source.ContactInfo.WorkPhoneNumber &apos;= ""' >
<true>
<assign value='source.ContactInfo.WorkPhoneNumber' property='target.telecom.(iTelecom).value.value' action='set' />
<assign value='"phone"' property='target.telecom.(iTelecom).system.value' action='set' />
<assign value='"work"' property='target.telecom.(iTelecom).use.value' action='set' />
<code>
<![CDATA[ set iTelecom = iTelecom + 1]]></code>
</true>
</if>
<if condition='source.ContactInfo.MobilePhoneNumber &apos;= ""' >
<true>
<assign value='source.ContactInfo.MobilePhoneNumber' property='target.telecom.(iTelecom).value.value' action='set' />
<assign value='"phone"' property='target.telecom.(iTelecom).system.value' action='set' />
<assign value='"mobile"' property='target.telecom.(iTelecom).use.value' action='set' />
<code>
<![CDATA[ set iTelecom = iTelecom + 1]]></code>
</true>
</if>
<if condition='source.ContactInfo.EmailAddress &apos;= ""' >
<true>
<assign value='source.ContactInfo.EmailAddress' property='target.telecom.(iTelecom).value.value' action='set' />
<assign value='"email"' property='target.telecom.(iTelecom).system.value' action='set' />
<code>
<![CDATA[ set iTelecom = iTelecom + 1]]></code>
</true>
</if>
<code>
<![CDATA[ set iExtension = 1]]></code>
<if condition='##class(HS.FHIR.DTL.Utils).CTIsDefined(source,"Race")' >
<true>
<assign value='source.Race.OriginalText' property='target.extension.(iExtension).valueCodeableConcept.text.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.Race.SDACodingStandard)' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).system.value' action='set' />
<assign value='source.Race.CodeSystemVersionId' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).version.value' action='set' />
<assign value='source.Race.Description' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).display.value' action='set' />
<assign value='source.Race.Code' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).code.value' action='set' />
<assign value='"http://hl7.org/fhir/StructureDefinition/us-core-race"' property='target.extension.(iExtension).url' action='set' />
<code>
<![CDATA[ set iExtension = iExtension + 1]]></code>
</true>
</if>
<foreach property='source.Races()' key='k5' >
<assign value='source.Races.(k5).OriginalText' property='target.extension.(iExtension).valueCodeableConcept.text.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.Races.(k5).SDACodingStandard)' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).system.value' action='set' />
<assign value='source.Races.(k5).CodeSystemVersionId' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).version.value' action='set' />
<assign value='source.Races.(k5).Description' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).display.value' action='set' />
<assign value='source.Races.(k5).Code' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).code.value' action='set' />
<assign value='"http://hl7.org/fhir/StructureDefinition/us-core-race"' property='target.extension.(iExtension).url' action='set' />
<code>
<![CDATA[ set iExtension = iExtension + 1]]></code>
</foreach>
<if condition='##class(HS.FHIR.DTL.Utils).CTIsDefined(source,"EthnicGroup")' >
<true>
<assign value='source.EthnicGroup.OriginalText' property='target.extension.(iExtension).valueCodeableConcept.text.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.EthnicGroup.SDACodingStandard)' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).system.value' action='set' />
<assign value='source.EthnicGroup.CodeSystemVersionId' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).version.value' action='set' />
<assign value='source.EthnicGroup.Description' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).display.value' action='set' />
<assign value='source.EthnicGroup.Code' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).code.value' action='set' />
<assign value='"http://hl7.org/fhir/StructureDefinition/us-core-ethnicity"' property='target.extension.(iExtension).url' action='set' />
<code>
<![CDATA[ set iExtension = iExtension + 1]]></code>
</true>
</if>
<if condition='source.MothersMaidenName &apos;=""' >
<true>
<assign value='source.MothersMaidenName' property='target.extension.(iExtension).valueString.value' action='set' />
<assign value='"http://hl7.org/fhir/StructureDefinition/patient-mothersMaidenName"' property='target.extension.(iExtension).url ' action='set' />
<code>
<![CDATA[ set iExtension = iExtension + 1]]></code>
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Utils).CTIsDefined(source,"Religion")' >
<true>
<assign value='"http://hl7.org/fhir/StructureDefinition/us-core-religion"' property='target.extension.(iExtension).url' action='set' />
<assign value='source.Religion.Description' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).display.value' action='set' />
<assign value='source.Religion.Code' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).code.value' action='set' />
<assign value='source.Religion.CodeSystemVersionId' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).version.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.Religion.SDACodingStandard)' property='target.extension.(iExtension).valueCodeableConcept.coding.(1).system.value' action='set' />
<assign value='source.Religion.OriginalText' property='target.extension.(iExtension).valueCodeableConcept.text.value' action='set' />
<code>
<![CDATA[ set iExtension = iExtension + 1]]></code>
</true>
</if>
<foreach property='source.PatientNumbers()' key='k6' >
<if condition='source.PatientNumbers.(k6).NumberType = "MRN"' >
<true>
<assign value='source.PatientNumbers.(k6).Number' property='target.identifier.(identifier).value.value' action='set' />
<assign value='"MR"' property='target.identifier.(identifier).type.text.value' action='set' />
<assign value='"MR"' property='target.identifier.(identifier).type.coding.(1).code.value' action='set' />
<assign value='"Medical record number"' property='target.identifier.(identifier).type.coding.(1).display.value' action='set' />
<assign value='"http://hl7.org/fhir/v2/0203"' property='target.identifier.(identifier).type.coding.(1).system.value' action='set' />
<if condition='source.PatientNumbers.(k6).Organization.Code &apos;= ""' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.PatientNumbers.(k6).Organization.Code)' property='target.identifier.(identifier).system.value' action='set' />
<assign value='source.PatientNumbers.(k6).Organization.Code' property='target.identifier.(identifier).assigner.display.value' action='set' />
</true>
</if>
<code>
<![CDATA[ set identifier = identifier + 1]]></code>
</true>
</if>
<if condition='source.PatientNumbers.(k6).NumberType = "DL"' >
<true>
<assign value='source.PatientNumbers.(k6).Number' property='target.identifier.(identifier).value.value' action='set' />
<assign value='"DL"' property='target.identifier.(identifier).type.text.value' action='set' />
<assign value='"DL"' property='target.identifier.(identifier).type.coding.(1).code.value' action='set' />
<assign value='"Drivers license number"' property='target.identifier.(identifier).type.coding.(1).display.value' action='set' />
<assign value='"http://hl7.org/fhir/v2/0203"' property='target.identifier.(identifier).type.coding.(1).system.value' action='set' />
<if condition='source.PatientNumbers.(k6).Organization.Code &apos;= ""' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.PatientNumbers.(k6).Organization.Code)' property='target.identifier.(identifier).system.value' action='set' />
<assign value='source.PatientNumbers.(k6).Organization.Code' property='target.identifier.(identifier).assigner.display.value' action='set' />
</true>
</if>
<code>
<![CDATA[ set identifier = identifier + 1]]></code>
</true>
</if>
<if condition='source.PatientNumbers.(k6).NumberType = "SSN"' >
<true>
<assign value='source.PatientNumbers.(k6).Number' property='target.identifier.(identifier).value.value' action='set' />
<assign value='"SSN"' property='target.identifier.(identifier).type.text.value' action='set' />
<assign value='"SSN"' property='target.identifier.(identifier).type.coding.(1).code.value' action='set' />
<assign value='"Social security number"' property='target.identifier.(identifier).type.coding.(1).display.value' action='set' />
<assign value='"http://hl7.org/fhir/v2/0203"' property='target.identifier.(identifier).type.coding.(1).system.value' action='set' />
<assign value='"SSN"' property='target.identifier.(identifier).assigner.display.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode("SSN")' property='target.identifier.(identifier).system.value' action='set' />
<code>
<![CDATA[ set identifier = identifier + 1]]></code>
</true>
</if>
<if condition='source.PatientNumbers.(k6).NumberType = "PPN"' >
<true>
<assign value='source.PatientNumbers.(k6).Number' property='target.identifier.(identifier).value.value' action='set' />
<assign value='"PPN"' property='target.identifier.(identifier).type.text.value' action='set' />
<assign value='"PPN"' property='target.identifier.(identifier).type.coding.(1).code.value' action='set' />
<assign value='"Passport number"' property='target.identifier.(identifier).type.coding.(1).display.value' action='set' />
<assign value='"http://hl7.org/fhir/v2/0203"' property='target.identifier.(identifier).type.coding.(1).system.value' action='set' />
<if condition='source.PatientNumbers.(k6).Organization.Code &apos;= ""' >
<true>
<assign value='source.PatientNumbers.(k6).Organization.Code' property='target.identifier.(identifier).system.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.PatientNumbers.(k6).Organization.Code)' property='target.identifier.(identifier).assigner.display.value' action='set' />
</true>
</if>
<code>
<![CDATA[ set identifier = identifier + 1]]></code>
</true>
</if>
</foreach>
<code>
<![CDATA[ set iContained = 0]]></code>
<if condition='##class(HS.FHIR.DTL.Utils).RDIsDefined(source,"FamilyDoctor")' >
<true>
<code>
<![CDATA[ set iContained=1]]></code>
<assign value='"#"_source.FamilyDoctor.InternalReference' property='target.careProvider.(1).reference.value' action='set' />
<assign value='source.FamilyDoctor.Name.GivenName_" "_source.FamilyDoctor.Name.FamilyName' property='target.careProvider.(1).display.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.ReferralDoctor' targetObj='target.contained.(iContained).Practitioner' sourceObj='source.FamilyDoctor' />
</true>
</if>
</transform>
}

}
