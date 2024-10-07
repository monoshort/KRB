/// Transforms SDA3 HS.SDA3.Provenance to vSTU3 Provenance
Class HS.FHIR.DTL.SDA3.vSTU3.Provenance.Provenance Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Provenance, HS.FHIR.DTL.vSTU3.Model.Resource.Provenance), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Provenance' targetClass='HS.FHIR.DTL.vSTU3.Model.Resource.Provenance' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Provenance (SDA3) to Provenance (vSTU3) ]]>
  </annotation>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.Recorded, "instant")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.recorded' action='set' >
<annotation>
<![CDATA[ When the activity was recorded / updated
 --- The source is optional, but the target is *Required*. When there is no source data to assign to this field, there is no default value, so the FHIR resource fails validation and is not saved. For this field, this is the desired behavior.   ]]>
</annotation>
</assign></true> 
</if> 
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.Provenance.Provenance")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.Provenance.Provenance).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
