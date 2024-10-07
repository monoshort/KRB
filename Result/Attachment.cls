/// Transforms SDA3 HS.SDA3.Result to vSTU3 Attachment
Class HS.FHIR.DTL.SDA3.vSTU3.Result.Attachment Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Result, HS.FHIR.DTL.vSTU3.Model.Datatype.Attachment), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Result' targetClass='HS.FHIR.DTL.vSTU3.Model.Datatype.Attachment' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Result (SDA3) to Attachment (vSTU3) ]]>
  </annotation>
<if condition='source.DocumentName&apos;=""'> 
<true> 
<assign value='source.DocumentName' property='target.title' action='set' >
<annotation>
<![CDATA[ Label to display in place of the data ]]>
</annotation>
</assign></true> 
</if> 

<if condition='source.DocumentURL&apos;=""'> 
<true> 
<assign value='source.DocumentURL' property='target.url' action='set' >
<annotation>
<![CDATA[ Uri where the data can be found ]]>
</annotation>
</assign></true> 
</if> 

<assign value='##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vSTU3","HS.SDA3.Document:FileType","MimeType RFC 4289",source.FileType)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.contentType' action='set' >
<annotation>
<![CDATA[ Mime type of the content, with charset etc.
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"text/plain"' property='target.contentType' action='set' />
</false> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).Base64Encode(source.ResultText)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.data' action='set' >
<annotation>
<![CDATA[ Data inline, base64ed ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.ResultTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.creation' action='set' >
<annotation>
<![CDATA[ Date attachment was first created ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.ResultText = ""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.Object).FromStream(source.Stream)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.data' action='set' >
<annotation>
<![CDATA[ Data inline, base64ed ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.Result.Attachment")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.Result.Attachment).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
