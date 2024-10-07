/// Transforms SDA3 HS.SDA3.ProcessNote to vR4 ClaimResponse:processNote
Class HS.FHIR.DTL.SDA3.vR4.ProcessNote.ClaimResponse.processNote Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.ProcessNote, HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.processNote), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.ProcessNote' targetClass='HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.processNote' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.ProcessNote (SDA3) to ClaimResponse:processNote (vR4) ]]>
  </annotation>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Language")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Language, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Language, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.language' action='set'  >
<annotation>
<![CDATA[ Language of the text
 --- In this case, languages is the Preferred FHIR4 ValueSet for codes, but if you need to express meanings not found in languages, you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='source.NoteId&apos;=""'> 
<true> 
<assign value='source.NoteId' property='target.number' action='set' >
<annotation>
<![CDATA[ Note instance identifier
 --- ClaimResponse:processNote[n].number is restricted to integer values *1* or greater.    ]]>
</annotation>
</assign></true> 
</if> 

<if condition='source.Text&apos;=""'> 
<true> 
<assign value='source.Text' property='target.text' action='set' >
<annotation>
<![CDATA[ Note explanatory text ]]>
</annotation>
</assign></true> 
</if> 

<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Type")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).CodeTable(source.Type, "ClaimResponse.processNote", "type", .aux)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.type' action='set' >
<annotation>
<![CDATA[ display | print | printoper
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.ProcessNote.ClaimResponse.processNote")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.ProcessNote.ClaimResponse.processNote).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
