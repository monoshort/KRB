/// Transforms SDA3 HS.SDA3.System to vR4 MessageHeader:source
Class HS.FHIR.DTL.SDA3.vR4.System.MessageHeader.source Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.System, HS.FHIR.DTL.vR4.Model.Element.MessageHeader.source), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.System' targetClass='HS.FHIR.DTL.vR4.Model.Element.MessageHeader.source' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.System (SDA3) to MessageHeader:source (vR4) ]]>
  </annotation>
<if condition='(source.Code &apos;= "") || (source.SDACodingStandard &apos;= "")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3.vR4.System.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/system"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<if condition='source.Endpoint&apos;=""'> 
<true> 
<assign value='source.Endpoint' property='target.endpoint' action='set' >
<annotation>
<![CDATA[ Actual message source address or id ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"unknown"' property='target.endpoint' action='set' />
</false> 
</if> 

<if condition='source.Name&apos;=""'> 
<true> 
<assign value='source.Name' property='target.name' action='set' >
<annotation>
<![CDATA[ Name of system ]]>
</annotation>
</assign></true> 
</if> 

<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.System.MessageHeader.source")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.System.MessageHeader.source).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
