/// Transforms SDA3 HS.SDA3.Identifier to vR4 Identifier
Class HS.FHIR.DTL.SDA3.vR4.Identifier.Identifier Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Identifier, HS.FHIR.DTL.vR4.Model.Datatype.Identifier), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Identifier' targetClass='HS.FHIR.DTL.vR4.Model.Datatype.Identifier' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Identifier (SDA3) to Identifier (vR4) ]]>
  </annotation>
<if condition='$zcvt(source.NumberType, "U") = "NPI"'> 
<true>
<assign value='"http://hl7.org/fhir/sid/us-npi"' property='target.system' action='set' >
<annotation>
<![CDATA[ The namespace for the identifier value
 --- This mapping entry assigns a literal value to a target field. A field-to-field mapping to this target field also exists. Be aware that literal value mappings execute first, then field-to-field mappings. The result is that if any field-to-field mapping is non-empty, it will overwrite any literal value mapped to the same target field. If this is not the desired result, the Condition to Set This Field for mappings to this target field must coordinate conditions to ensure that the literal value takes precedence when it should.   ]]>
</annotation>
</assign>
</true>
</if>
<if condition='$zcvt(source.NumberType, "U") &apos;= "NPI"'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).GetURIForCode(source.ISOAssigningAuthority)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.system' action='set' >
<annotation>
<![CDATA[ The namespace for the identifier value ]]>
</annotation>
</assign></true> 
</if> 
</true>
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
<assign value='##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vR4","HS.SDA3.Identifier:NumberType","identifier-type",source.NumberType)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.type.coding.(1).code' action='set' >
<annotation>
<![CDATA[ Description of identifier
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='source.NumberType&apos;=""'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vR4","HS.SDA3.Identifier:NumberType","identifier-type",source.NumberType) = ""'> 
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
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Identifier.Identifier")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Identifier.Identifier).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
