/// Transforms SDA3 HS.SDA3.DosageStep to vSTU3 MedicationStatement
Class HS.FHIR.DTL.SDA3.vSTU3.DosageStep.MedicationStatement Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.DosageStep, HS.FHIR.DTL.vSTU3.Model.Resource.MedicationStatement), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.DosageStep' targetClass='HS.FHIR.DTL.vSTU3.Model.Resource.MedicationStatement' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.DosageStep (SDA3) to MedicationStatement (vSTU3) ]]>
  </annotation>
<if condition='source.DoseQuantity&apos;=""'> 
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
<if condition='source.DoseUoM.Code&apos;=""'> 
<true>
<if condition='source.DoseUoM.Code&apos;=""'> 
<true> 
<assign value='source.DoseUoM.Code' property='target.dosage.(1).doseQuantity.code' action='set' >
<annotation>
<![CDATA[ Coded form of the unit ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.DoseUoM.SDACodingStandard) = ""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).GetURIForValueSet("vSTU3", "http://unitsofmeasure.org", source.DoseUoM.Code)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.dosage.(1).doseQuantity.system' action='set' >
<annotation>
<![CDATA[ System that defines coded unit form ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"http://www.intersystems.com/fhir/system"' property='target.dosage.(1).doseQuantity.system' action='set' />
</false> 
</if> 
</true>
</if>
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
<if condition='source.TextInstruction&apos;=""'> 
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
<if condition='source.TextInstruction&apos;=""'> 
<true>
<if condition='source.TextInstruction&apos;=""'> 
<true> 
<assign value='source.TextInstruction' property='target.dosage.(1).patientInstruction' action='set' >
<annotation>
<![CDATA[ Patient or consumer oriented instructions ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.DosageStep.MedicationStatement")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.DosageStep.MedicationStatement).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
