/// Transforms SDA3 HS.SDA3.Document to vR4 Attachment
Class HS.FHIR.DTL.SDA3.vR4.Document.Attachment Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Document, HS.FHIR.DTL.vR4.Model.Datatype.Attachment), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Document' targetClass='HS.FHIR.DTL.vR4.Model.Datatype.Attachment' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Document (SDA3) to Attachment (vR4) ]]>
  </annotation>
<if condition='source.DocumentName&apos;=""'> 
<true> 
<assign value='source.DocumentName' property='target.title' action='set' >
<annotation>
<![CDATA[ Label to display in place of the data ]]>
</annotation>
</assign></true> 
</if> 

<if condition='source.DocumentNumber&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.DocumentNumber, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.DocumentNumber, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/document-document-number"' property='tmp.url' action='set' />
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
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.DocumentTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.creation' action='set' >
<annotation>
<![CDATA[ Date attachment was first created ]]>
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

<assign value='##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vR4","HS.SDA3.Document:FileType","mimetypes|4.0.1",source.FileType)' property='value' action='set' />
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
<if condition='source.FileType&apos;=""'> 
<true>
<if condition='(##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vR4","HS.SDA3.Document:FileType","mimetypes|4.0.1",source.FileType) = "")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.FileType, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.FileType, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/document-file-type"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations
 --- This mapping supports a related mapping that does a table lookup to match the incoming source value with a value to place in the target field. This mapping has the same Condition to Set this Field as the table lookup. If the lookup successfully finds a value for target field, this mapping stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
</true>
</if>
<if condition='&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Stream") || (source.Stream.Size = 0)'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).Base64Encode(source.NoteText)' property='value' action='set' />
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
<assign value='##class(HS.FHIR.DTL.Util.Element.Object).FromStream(source.Stream)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.data' action='set' >
<annotation>
<![CDATA[ Data inline, base64ed ]]>
</annotation>
</assign></true> 
</if> 
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Document.Attachment")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Document.Attachment).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
