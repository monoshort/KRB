/// Transforms SDA3 HS.SDA3.CodeTableDetail.DrugProduct to vR4 ExplanationOfBenefit:item[n].detail
Class HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.DrugProduct.ExplanationOfBenefit.item.detail Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.CodeTableDetail.DrugProduct, HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.item.detail), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.CodeTableDetail.DrugProduct' targetClass='HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.item.detail' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.CodeTableDetail.DrugProduct (SDA3) to ExplanationOfBenefit:item[n].detail (vR4) ]]>
  </annotation>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.DrugProduct.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.productOrService' action='set'  >
<annotation>
<![CDATA[ Billing, service, product, or drug code
 --- In this case, any FHIR4 code may be used; service-uscls shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "DispensedQuantity")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.Quantity).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.DispensedQuantity, "HS.FHIR.DTL.SDA3.vR4.Quantity.Quantity")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.DispensedQuantity, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.quantity' action='set'  >
<annotation>
<![CDATA[ Count of products or services ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.CodeTableDetail.DrugProduct.ExplanationOfBenefit.item.detail")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.CodeTableDetail.DrugProduct.ExplanationOfBenefit.item.detail).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
