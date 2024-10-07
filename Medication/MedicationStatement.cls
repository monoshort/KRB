/// Transforms SDA3 HS.SDA3.Medication to vSTU3 MedicationStatement
Class HS.FHIR.DTL.SDA3.vSTU3.Medication.MedicationStatement Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Medication, HS.FHIR.DTL.vSTU3.Model.Resource.MedicationStatement), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Medication' targetClass='HS.FHIR.DTL.vSTU3.Model.Resource.MedicationStatement' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Medication (SDA3) to MedicationStatement (vSTU3) ]]>
  </annotation>
<assign value='aux("transformer").GetPatientReference()' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.subject' action='set' >
<annotation>
<![CDATA[ Who is/was taking  the medication ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Resource.Medication).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3.vSTU3.Medication.Medication")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.medicationReference' action='set'  >
<annotation>
<![CDATA[ What medication was taken. ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>

<if condition='(source.DosageSteps.Count() = 0) &amp;&amp; (((##class(HS.FHIR.DTL.Util.Element.Object).Defined(source,"Frequency")) &amp;&amp; (source.Frequency.Code = "PRN")) || ((##class(HS.FHIR.DTL.Util.Element.Object).Defined(source,"Priority")) &amp;&amp; (source.Priority.Code = "PRN")))'> 
<true>
<assign value='"1"' property='target.dosage.(1).asNeededBoolean' action='set' >
<annotation>
<![CDATA[ Take "as needed" (true or false, or for the reason given). ]]>
</annotation>
</assign>
</true>
</if>
<if condition='(source.DosageSteps.Count() = 0) &amp;&amp; (((&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source,"Frequency")) || (source.Frequency.Code &apos;= "PRN")) &amp;&amp; ((&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source,"Priority")) || (source.Priority.Code &apos;= "PRN")))'> 
<true>
<assign value='"0"' property='target.dosage.(1).asNeededBoolean' action='set' >
<annotation>
<![CDATA[ Take "as needed" (true or false, or for the reason given). ]]>
</annotation>
</assign>
</true>
</if>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).SaveValueToAux("EncounterNumber", source.EncounterNumber, .aux)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target' action='set' >
<annotation>
<![CDATA[ A record of a medication that is being consumed by a Patient: A MedicationStatement may indicate that the patient may be taking the medication now, or has taken the medication in the past or will be taking the medication in the future. The source of this information can be the patient, significant other (such as a family member or spouse), or a clinician. A common scenario where this information is captured is during the history taking process during a patient visit or stay. The medication information may come from sources such as the patient's memory, from a prescription bottle, or from a list of medications the patient, clinician or other party maintains The primary difference between a medication statement and a medication administration is that the medication administration has complete administration information and is based on actual administration information from the person who administered the medication. A medication statement is often, if not always, less specific. There is no required date/time when the medication was administered, in fact we only know that a source has reported the patient is taking this medication, where details such as time, quantity, or rate or even medication product may be incomplete or missing or less precise. As stated earlier, the medication statement information may come from the patient's memory, from a prescription bottle or from a list of medications the patient, clinician or other party maintains. Medication administration is more formal and is not missing detailed information. ]]>
</annotation>
</assign></true> 
</if> 
<if condition='(source.Administrations.Count() = 0)'> 
<true>
<assign value='"unk"' property='target.taken' action='set' >
<annotation>
<![CDATA[ y | n | unk | na
 --- This mapping entry assigns a literal value to a target field. A field-to-field mapping to this target field also exists. Be aware that literal value mappings execute first, then field-to-field mappings. The result is that if any field-to-field mapping is non-empty, it will overwrite any literal value mapped to the same target field. If this is not the desired result, the Condition to Set This Field for mappings to this target field must coordinate conditions to ensure that the literal value takes precedence when it should.   ]]>
</annotation>
</assign>
</true>
</if>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).SaveValueToAux("MedicationReference", target.medicationReference, .aux)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target' action='set' >
<annotation>
<![CDATA[ A record of a medication that is being consumed by a Patient: A MedicationStatement may indicate that the patient may be taking the medication now, or has taken the medication in the past or will be taking the medication in the future. The source of this information can be the patient, significant other (such as a family member or spouse), or a clinician. A common scenario where this information is captured is during the history taking process during a patient visit or stay. The medication information may come from sources such as the patient's memory, from a prescription bottle, or from a list of medications the patient, clinician or other party maintains The primary difference between a medication statement and a medication administration is that the medication administration has complete administration information and is based on actual administration information from the person who administered the medication. A medication statement is often, if not always, less specific. There is no required date/time when the medication was administered, in fact we only know that a source has reported the patient is taking this medication, where details such as time, quantity, or rate or even medication product may be incomplete or missing or less precise. As stated earlier, the medication statement information may come from the patient's memory, from a prescription bottle or from a list of medications the patient, clinician or other party maintains. Medication administration is more formal and is not missing detailed information. ]]>
</annotation>
</assign></true> 
</if> 
<foreach property='source.Administrations()' key='st' >
<assign value='target.partOf.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Resource.MedicationAdministration).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Administrations.(st), "HS.FHIR.DTL.SDA3.vSTU3.Administration.MedicationAdministration")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Administrations.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.Administrations.(st), tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.partOf' action='set' key='index'  >
<annotation>
<![CDATA[ Part of referenced event ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</foreach>
<if condition='(source.Administrations.Count() > 0)'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vSTU3","HS.SDA3.CodeTableDetail.AdministrationStatus","medication-statement-taken",source.Administrations.(1).AdministrationStatus.Code)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.taken' action='set' >
<annotation>
<![CDATA[ y | n | unk | na
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"unk"' property='target.taken' action='set' />
</false> 
</if> 
</true>
</if>
<if condition='source.Comments&apos;=""'> 
<true>
<assign value='target.note.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Datatype.Annotation).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Comments, "HS.FHIR.DTL.SubXFrm.SDA3.vSTU3.String.Annotation")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Comments, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.note' action='set' key='index'  >
<annotation>
<![CDATA[ Further information about the statement ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<if condition='source.DosageSteps.Count()>0'> 
<true> 
<assign value='target' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.DosageSteps.(1), "HS.FHIR.DTL.SDA3.vSTU3.DosageStep.MedicationStatement")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.DosageSteps.(1), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target' action='set'  >
<annotation>
<![CDATA[ A record of a medication that is being consumed by a Patient: A MedicationStatement may indicate that the patient may be taking the medication now, or has taken the medication in the past or will be taking the medication in the future. The source of this information can be the patient, significant other (such as a family member or spouse), or a clinician. A common scenario where this information is captured is during the history taking process during a patient visit or stay. The medication information may come from sources such as the patient's memory, from a prescription bottle, or from a list of medications the patient, clinician or other party maintains The primary difference between a medication statement and a medication administration is that the medication administration has complete administration information and is based on actual administration information from the person who administered the medication. A medication statement is often, if not always, less specific. There is no required date/time when the medication was administered, in fact we only know that a source has reported the patient is taking this medication, where details such as time, quantity, or rate or even medication product may be incomplete or missing or less precise. As stated earlier, the medication statement information may come from the patient's memory, from a prescription bottle or from a list of medications the patient, clinician or other party maintains. Medication administration is more formal and is not missing detailed information.
 --- SDA3 HS.SDA3.Medication:DosageSteps is a *List*, and FHIR STU3 MedicationStatement is *Single*. 
 --- For a list object mapped to a single FHIR object, the mapping table must contain 2 mapping entries for the source list: One maps only the first item from the list to the target object; the other maps the list to a FHIR extension that contains the full list.   ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if> 
<if condition='source.DoseQuantity&apos;=""'> 
<true>
<if condition='(source.DosageSteps.Count() = 0)'> 
<true>
<if condition='source.DoseQuantity&apos;=""'> 
<true> 
<assign value='source.DoseQuantity' property='target.dosage.(1).doseQuantity.value' action='set' >
<annotation>
<![CDATA[ Numerical value (with implicit precision) ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
</true>
</if>
<if condition='source.DoseQuantity = ""'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "DoseUoM")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Datatype.SimpleQuantity).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.DoseUoM, "HS.FHIR.DTL.SDA3.vSTU3.CodeTableTranslated.SimpleQuantity")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.DoseUoM, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.dosage.(1).doseQuantity' action='set'  >
<annotation>
<![CDATA[ Amount of medication per dose. ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
</true>
</if>
<if condition='source.DoseQuantity = ""'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "DoseUoM")'> 
<true>
<assign value='target.dosage.(1).doseQuantity' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.DoseUoM, "HS.FHIR.DTL.SDA3.vSTU3.CodeTableTranslated.SimpleQuantity")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.DoseUoM, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.dosage.(1).doseQuantity' action='set'  >
<annotation>
<![CDATA[ Amount of medication per dose. ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
</true>
</if>
<assign value='aux("transformer").GetReference("Encounter",source.EncounterNumber)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.context' action='set' >
<annotation>
<![CDATA[ Encounter / Episode associated with MedicationStatement ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.Order).FillerId(source.FillerId, .aux)' property='value' action='set' />
<assign value='target.identifier.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.identifier' action='set' key='index'  >
<annotation>
<![CDATA[ External identifier ]]>
</annotation>
</assign></true> 
</if> 
<if condition='(source.DosageSteps.Count() = 0)'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Frequency")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.Dosage).Frequency(source.Frequency)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.dosage.(1).timing' action='set' >
<annotation>
<![CDATA[ When medication should be administered ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
</true>
</if>
<if condition='source.Indication&apos;=""'> 
<true>
<if condition='source.Indication&apos;=""'> 
<true> 
<assign value='source.Indication' property='target.reasonCode.(1).text' action='set' >
<annotation>
<![CDATA[ Plain text representation of the concept ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.Order).PlacerId(source.PlacerId, .aux)' property='value' action='set' />
<assign value='target.identifier.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.identifier' action='set' key='index'  >
<annotation>
<![CDATA[ External identifier ]]>
</annotation>
</assign></true> 
</if> 
<if condition='(source.DosageSteps.Count() = 0)'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Route")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Route, "HS.FHIR.DTL.SDA3.vSTU3.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Route, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.dosage.(1).route' action='set'  >
<annotation>
<![CDATA[ How drug should enter body
 --- In this case, any FHIR3 code may be used; route-codes shows Example codes, but you may use codes from any ValueSet. 
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
<assign value='##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vSTU3","HS.SDA3.Medication:Status","medication-statement-status",source.Status)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.status' action='set' >
<annotation>
<![CDATA[ active | completed | entered-in-error | intended | stopped | on-hold
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"unknown"' property='target.status' action='set' />
</false> 
</if> 
<if condition='source.Status&apos;=""'> 
<true>
<if condition='(##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vSTU3","HS.SDA3.Medication:Status","medication-dispense-status",source.Status) = "")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Status, "HS.FHIR.DTL.SubXFrm.SDA3.vSTU3.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Status, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/medication-status"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional Content defined by implementations
 --- This mapping supports a related mapping that does a table lookup to match the incoming source value with a value to place in the target field. This mapping has the same Condition to Set this Field as the table lookup. If the lookup successfully finds a value for target field, this mapping stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
</true>
</if>
<if condition='source.TextInstruction&apos;=""'> 
<true>
<if condition='(source.DosageSteps.Count() = 0)'> 
<true>
<if condition='source.TextInstruction&apos;=""'> 
<true> 
<assign value='source.TextInstruction' property='target.dosage.(1).text' action='set' >
<annotation>
<![CDATA[ Free text dosage instructions e.g. SIG ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
</true>
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.Medication.MedicationStatement")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.Medication.MedicationStatement).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
