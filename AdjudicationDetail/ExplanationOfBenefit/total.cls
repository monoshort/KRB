/// Transforms SDA3 HS.SDA3.AdjudicationDetail to vR4 ExplanationOfBenefit:total
Class HS.FHIR.DTL.SDA3.vR4.AdjudicationDetail.ExplanationOfBenefit.total Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.AdjudicationDetail, HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.total), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.AdjudicationDetail' targetClass='HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.total' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.AdjudicationDetail (SDA3) to ExplanationOfBenefit:total (vR4) ]]>
  </annotation>
<if condition='(source.Amount &apos;= "") || ##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Currency")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.Money).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3.vR4.AdjudicationDetail.Money")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.amount' action='set'  >
<annotation>
<![CDATA[ Financial total for the category ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Category")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Category, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Category, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.category' action='set'  >
<annotation>
<![CDATA[ Type of adjudication information
 --- In this case, any FHIR4 code may be used; adjudication shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.AdjudicationDetail.ExplanationOfBenefit.total")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.AdjudicationDetail.ExplanationOfBenefit.total).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
