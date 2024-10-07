/// Transforms SDA3 HS.SDA3.CodeTableDetail.HealthFund to vR4 Organization
Class HS.FHIR.DTL.CARINBB.SDA3.vR4.CodeTableDetail.HealthFund.Organization Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.CodeTableDetail.HealthFund, HS.FHIR.DTL.vR4.Model.Resource.Organization), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.CodeTableDetail.HealthFund' targetClass='HS.FHIR.DTL.vR4.Model.Resource.Organization' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.CodeTableDetail.HealthFund (SDA3) to Organization (vR4) ]]>
  </annotation>
<assign value='target' property='tmp' action='set' />
<assign value='"HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.HealthFund.Organization"' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target' action='set'  >
<annotation>
<![CDATA[ A grouping of people or organizations with a common purpose ]]>
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
<assign value='"http://hl7.org/fhir/us/carin-bb/StructureDefinition/C4BB-Organization"' property='target.meta.profile' action='set' key='index'  >
<annotation>
<![CDATA[ Profiles this resource claims to conform to ]]>
</annotation>
</assign>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.CodeTableDetail.HealthFund.Organization")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.CodeTableDetail.HealthFund.Organization).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
