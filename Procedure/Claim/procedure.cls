/// Transforms SDA3 HS.SDA3.Procedure to vR4 Claim:procedure
Class HS.FHIR.DTL.SDA3.vR4.Procedure.Claim.procedure Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Procedure, HS.FHIR.DTL.vR4.Model.Element.Claim.procedure), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Procedure' targetClass='HS.FHIR.DTL.vR4.Model.Element.Claim.procedure' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Procedure (SDA3) to Claim:procedure (vR4) ]]>
  </annotation>
<foreach property='source.Devices()' key='st' >
<assign value='target.udi.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Device).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Devices.(st), "HS.FHIR.DTL.SDA3.vR4.Device.Device")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Devices.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.Devices.(st), tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.udi' action='set' key='index'  >
<annotation>
<![CDATA[ Unique device identifier ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</foreach>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Procedure")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Procedure, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Procedure, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.procedureCodeableConcept' action='set'  >
<annotation>
<![CDATA[ Specific clinical procedure
 --- In this case, any FHIR4 code may be used; icd-10-procedures shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.ProcedureTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.date' action='set' >
<annotation>
<![CDATA[ When the procedure was performed ]]>
</annotation>
</assign></true> 
</if> 
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Procedure.Claim.procedure")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Procedure.Claim.procedure).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
