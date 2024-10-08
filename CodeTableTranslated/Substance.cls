/// Transforms SDA3 HS.SDA3.CodeTableTranslated to vSTU3 Substance
Class HS.FHIR.DTL.SDA3.vSTU3.CodeTableTranslated.Substance Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.CodeTableTranslated, HS.FHIR.DTL.vSTU3.Model.Resource.Substance), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.CodeTableTranslated' targetClass='HS.FHIR.DTL.vSTU3.Model.Resource.Substance' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.CodeTableTranslated (SDA3) to Substance (vSTU3) ]]>
  </annotation>
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3.vSTU3.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.code' action='set'  >
<annotation>
<![CDATA[ What substance this is
 --- In this case, any FHIR3 code may be used; substance-code shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.CodeTableTranslated.Substance")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.CodeTableTranslated.Substance).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
