/// Transforms SDA3 HS.SDA3.Result to vSTU3 Media
Class HS.FHIR.DTL.SDA3.vSTU3.Result.Media Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Result, HS.FHIR.DTL.vSTU3.Model.Resource.Media), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Result' targetClass='HS.FHIR.DTL.vSTU3.Model.Resource.Media' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Result (SDA3) to Media (vSTU3) ]]>
  </annotation>
<if condition='source.Comments&apos;=""'> 
<true>
<if condition='source.Comments&apos;=""'> 
<true> 
<assign value='source.Comments' property='target.note.(1).text' action='set' >
<annotation>
<![CDATA[ The annotation  - text content ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "EnteredBy")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Resource.Practitioner).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.EnteredBy, "HS.FHIR.DTL.SDA3.vSTU3.CodeTableDetail.Practitioner")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.EnteredBy, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.EnteredBy, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.subject' action='set'  >
<annotation>
<![CDATA[ Who/What this Media is a record of ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<if condition='source.ExternalId&apos;=""'> 
<true>
<if condition='source.ExternalId&apos;=""'> 
<true> 
<assign value='source.ExternalId' property='target.identifier.(1).value' action='set' >
<annotation>
<![CDATA[ The value that is unique ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vSTU3","HS.SDA3.Result:FileType","digital-media-type",source.FileType)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.type' action='set' >
<annotation>
<![CDATA[ photo | video | audio
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"photo"' property='target.type' action='set' />
</false> 
</if> 
<if condition='source.Stream&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.Object).FromStream(source.Stream)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.content.data' action='set' >
<annotation>
<![CDATA[ Data inline, base64ed ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.Result.Media")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.Result.Media).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
