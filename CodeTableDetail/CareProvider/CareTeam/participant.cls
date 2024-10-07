/// Transforms SDA3 HS.SDA3.CodeTableDetail.CareProvider to vR4 CareTeam:participant
Class HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.CareProvider.CareTeam.participant Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.CodeTableDetail.CareProvider, HS.FHIR.DTL.vR4.Model.Element.CareTeam.participant), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.CodeTableDetail.CareProvider' targetClass='HS.FHIR.DTL.vR4.Model.Element.CareTeam.participant' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.CodeTableDetail.CareProvider (SDA3) to CareTeam:participant (vR4) ]]>
  </annotation>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Practitioner).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.CareProvider.Practitioner")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.member' action='set'  >
<annotation>
<![CDATA[ Who is involved ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>

<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "CareProviderType")'> 
<true>
<assign value='target.role.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.CareProviderType, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.CareProviderType, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.role' action='set' key='index'  >
<annotation>
<![CDATA[ Type of involvement
 --- In this case, any FHIR4 code may be used; participant-role shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.CodeTableDetail.CareProvider.CareTeam.participant")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.CodeTableDetail.CareProvider.CareTeam.participant).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
