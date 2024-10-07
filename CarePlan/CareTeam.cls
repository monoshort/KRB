/// Transforms SDA3 HS.SDA3.CarePlan to vR4 CareTeam
Class HS.FHIR.DTL.SDA3.vR4.CarePlan.CareTeam Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.CarePlan, HS.FHIR.DTL.vR4.Model.Resource.CareTeam), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.CarePlan' targetClass='HS.FHIR.DTL.vR4.Model.Resource.CareTeam' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.CarePlan (SDA3) to CareTeam (vR4) ]]>
  </annotation>
<assign value='aux("transformer").GetPatientReference()' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.subject' action='set' >
<annotation>
<![CDATA[ Who care team is for ]]>
</annotation>
</assign></true> 
</if> 
<foreach property='source.Organizations()' key='st' >
<assign value='target.participant.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.CareTeam.participant).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Organizations.(st), "HS.FHIR.DTL.SDA3.vR4.DocumentOrganization.CareTeam.participant")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Organizations.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.participant' action='set' key='index'  >
<annotation>
<![CDATA[ Members of the team ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
<foreach property='source.Providers()' key='st' >
<assign value='target.participant.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.CareTeam.participant).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Providers.(st), "HS.FHIR.DTL.SDA3.vR4.DocumentProvider.CareTeam.participant")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Providers.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.participant' action='set' key='index'  >
<annotation>
<![CDATA[ Members of the team ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
<foreach property='source.SupportContacts()' key='st' >
<assign value='target.participant.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.CareTeam.participant).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.SupportContacts.(st), "HS.FHIR.DTL.SDA3.vR4.SupportContact.CareTeam.participant")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.SupportContacts.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.participant' action='set' key='index'  >
<annotation>
<![CDATA[ Members of the team ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.CarePlan.CareTeam")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.CarePlan.CareTeam).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
