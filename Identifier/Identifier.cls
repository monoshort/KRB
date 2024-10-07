/// Transforms SDA3 HS.SDA3.Identifier to vSTU3 Identifier
Class HS.FHIR.DTL.SDA3.vSTU3.Identifier.Identifier Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Identifier, HS.FHIR.DTL.vSTU3.Model.Datatype.Identifier), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Identifier' targetClass='HS.FHIR.DTL.vSTU3.Model.Datatype.Identifier' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Identifier (SDA3) to Identifier (vSTU3) ]]>
  </annotation>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.ISOAssigningAuthority)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.system' action='set' >
<annotation>
<![CDATA[ The namespace for the identifier value ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.Number&apos;=""'> 
<true> 
<assign value='source.Number' property='target.value' action='set' >
<annotation>
<![CDATA[ The value that is unique ]]>
</annotation>
</assign></true> 
</if> 

<if condition='source.NumberType&apos;=""'> 
<true>
<assign value='source.NumberType' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.type.coding.(1).code' action='set' >
<annotation>
<![CDATA[ Description of identifier ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='source.NumberTypeCodeSystem&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.NumberTypeCodeSystem)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.type.coding.(1).system' action='set' >
<annotation>
<![CDATA[ Identity of the terminology system ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.Identifier.Identifier")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.Identifier.Identifier).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
