/// Transforms SDA3 HS.SDA3.CodeTableDetail.CareProvider to vR4 Practitioner
Class HS.FHIR.DTL.CARINBB.SDA3.vR4.CodeTableDetail.CareProvider.Practitioner Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.CodeTableDetail.CareProvider, HS.FHIR.DTL.vR4.Model.Resource.Practitioner), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.CodeTableDetail.CareProvider' targetClass='HS.FHIR.DTL.vR4.Model.Resource.Practitioner' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.CodeTableDetail.CareProvider (SDA3) to Practitioner (vR4) ]]>
  </annotation>
<assign value='target' property='tmp' action='set' />
<assign value='"HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.CareProvider.Practitioner"' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target' action='set'  >
<annotation>
<![CDATA[ A person with a  formal responsibility in the provisioning of healthcare or related services ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

<if condition='target.meta&apos;=""'> 
<true> 
<assign value='target.meta.profile.Count()+1' property='index' action='set' />
</true> 
<false> 
<assign value='1' property='index' action='set' />
</false> 
</if> 
<assign value='"http://hl7.org/fhir/us/carin-bb/StructureDefinition/C4BB-Practitioner"' property='target.meta.profile' action='set' key='index'  >
<annotation>
<![CDATA[ Profiles this resource claims to conform to ]]>
</annotation>
</assign>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.CodeTableDetail.CareProvider.Practitioner")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.CodeTableDetail.CareProvider.Practitioner).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
