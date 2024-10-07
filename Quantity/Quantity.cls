/// Transforms SDA3 HS.SDA3.Quantity to vR4 Quantity
Class HS.FHIR.DTL.SDA3.vR4.Quantity.Quantity Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Quantity, HS.FHIR.DTL.vR4.Model.Datatype.Quantity), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Quantity' targetClass='HS.FHIR.DTL.vR4.Model.Datatype.Quantity' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.Quantity (SDA3) to Quantity (vR4) ]]>
  </annotation>
<if condition='source.Comparator&apos;=""'> 
<true> 
<assign value='source.Comparator' property='target.comparator' action='set' >
<annotation>
<![CDATA[ < | <= | >= | > - how to understand the value
 --- The source field HS.SDA3.Quantity:Comparator is an SDA3 string type with a VALUELIST. 
 --- This is similar to a coded value, but SDA does not define it as a coded type. The value of this field is used as both the data value and the display text. 
 --- The values for HS.SDA3.Quantity:Comparator are:  ,<,<.    ]]>
</annotation>
</assign></true> 
</if> 

<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "UnitOfMeasure")'> 
<true>
<assign value='target' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.UnitOfMeasure, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.Quantity")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.UnitOfMeasure, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target' action='set'  >
<annotation>
<![CDATA[ A measured or measurable amount ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='source.Value&apos;=""'> 
<true> 
<assign value='source.Value' property='target.value' action='set' >
<annotation>
<![CDATA[ Numerical value (with implicit precision) ]]>
</annotation>
</assign></true> 
</if> 

<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Quantity.Quantity")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.Quantity.Quantity).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
