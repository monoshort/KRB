/// Transforms SDA3 HS.SDA3.PharmacyClaim to vR4 ClaimResponse
Class HS.FHIR.DTL.SDA3.vR4.PharmacyClaim.ClaimResponse Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.PharmacyClaim, HS.FHIR.DTL.vR4.Model.Resource.ClaimResponse), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.PharmacyClaim' targetClass='HS.FHIR.DTL.vR4.Model.Resource.ClaimResponse' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.PharmacyClaim (SDA3) to ClaimResponse (vR4) ]]>
  </annotation>
<assign value='aux("transformer").GetPatientReference()' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.patient' action='set' >
<annotation>
<![CDATA[ The recipient of the products and services ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Claim).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3.vR4.PharmacyClaim.Claim")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.request' action='set'  >
<annotation>
<![CDATA[ Id of resource triggering adjudication
Note: If PharmacyClaim data exists, this is where the Claim resource is created. This way, the ClaimResponse and Claim resources are linked by a reference. ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>

<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.MedicalClaim).Insurance(source.AdjudicatedCoverage, target, 1, .aux)' property='value' action='set' />
<assign value='target.insurance.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.insurance' action='set' key='index'  >
<annotation>
<![CDATA[ Patient insurance information ]]>
</annotation>
</assign></true> 
</if> 
<foreach property='source.AdjudicationDetails()' key='st' >
<assign value='target.adjudication.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.item.adjudication).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.AdjudicationDetails.(st), "HS.FHIR.DTL.SDA3.vR4.AdjudicationDetail.ClaimResponse.adjudication")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.AdjudicationDetails.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.adjudication' action='set' key='index'  >
<annotation>
<![CDATA[ Header-level adjudication ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "AdjudicationStatus")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).CodeTable(source.AdjudicationStatus, "ClaimResponse", "outcome", .aux)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.outcome' action='set' >
<annotation>
<![CDATA[ queued | complete | error | partial
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension. 
 --- SDA3 HS.SDA3.PharmacyClaim:AdjudicationStatus is optional, and FHIR4 ClaimResponse:outcome is required. No source value is mapped unconditionally to the target and *No Default Value* is supplied in case of no data received. This can be a serious gap. 
 --- This case might be fine, if there exists another mapping to the same target with a non-empty Condition to Set This Field. For example, two mappings could be defined to the same target, each with a Condition to Set This Field, in order to specify mutually exclusive cases.    ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "BillingProvider")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Organization).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.BillingProvider, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.Organization.Organization")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.BillingProvider, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.BillingProvider, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.requestor' action='set'  >
<annotation>
<![CDATA[ Party responsible for the claim ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.ClaimProcessedDate, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.created' action='set' >
<annotation>
<![CDATA[ Response creation date
 --- The source is optional, but the target is *Required*. When there is no source data to assign to this field, there is no default value, so the FHIR resource fails validation and is not saved. For this field, this is the desired behavior.   ]]>
</annotation>
</assign></true> 
</if> 
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "ClaimSubType")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ClaimSubType, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ClaimSubType, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.subType' action='set'  >
<annotation>
<![CDATA[ More granular claim type
 --- In this case, any FHIR4 code may be used; claim-subtype shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "ClaimType")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ClaimType, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ClaimType, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.type' action='set'  >
<annotation>
<![CDATA[ More granular claim type
 --- In this case, claim-type is the *Required* FHIR4 ValueSet for codes, but if you need to express meanings not found in claim-type, you may formally *Extend* claim-type to add codes to it. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<foreach property='source.DeniedReasonCodes()' key='st' >
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).AdjudicationReason(source.DeniedReasonCodes.GetAt(st), "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBAdjudicationDiscriminator", "denialreason", .aux)' property='value' action='set' />
<assign value='target.adjudication.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.adjudication' action='set' key='index'  >
<annotation>
<![CDATA[ Header-level adjudication ]]>
</annotation>
</assign></true> 
</if> </foreach>
<foreach property='source.OtherCoverage()' key='st' >
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.MedicalClaim).Insurance(source.OtherCoverage.GetAt(st), target, 0, .aux)' property='value' action='set' />
<assign value='target.insurance.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.insurance' action='set' key='index'  >
<annotation>
<![CDATA[ Patient insurance information ]]>
</annotation>
</assign></true> 
</if> </foreach>
<foreach property='source.OtherIdentifiers()' key='st' >
<assign value='target.identifier.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.Identifier).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.OtherIdentifiers.(st), "HS.FHIR.DTL.SDA3.vR4.Identifier.Identifier")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.OtherIdentifiers.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.identifier' action='set' key='index'  >
<annotation>
<![CDATA[ Business Identifier for a claim response ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Payer")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Organization).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Payer, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.Organization.Organization")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Payer, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.Payer, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.insurer' action='set'  >
<annotation>
<![CDATA[ Party responsible for reimbursement ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<if condition='source.PaymentAmount&apos;=""'> 
<true>
<if condition='source.PaymentAmount&apos;=""'> 
<true> 
<assign value='source.PaymentAmount' property='target.payment.amount.value' action='set' >
<annotation>
<![CDATA[ Numerical value (with implicit precision) ]]>
</annotation>
</assign></true> 
</if> 

</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "PaymentCurrency")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).CodeTable(source.PaymentCurrency, "Money", "currency", .aux)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.payment.amount.currency' action='set' >
<annotation>
<![CDATA[ ISO 4217 Currency Code
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<if condition='source.PaymentDate&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.PaymentDate, "date")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.payment.date' action='set' >
<annotation>
<![CDATA[ Expected date of payment ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "PaymentStatus")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.PaymentStatus, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.PaymentStatus, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.payment.type' action='set'  >
<annotation>
<![CDATA[ Partial or complete payment
 --- In this case, any FHIR4 code may be used; ex-paymenttype shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<foreach property='source.PharmacyClaimLines()' key='st' >
<assign value='target.item.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.item).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.PharmacyClaimLines.(st), "HS.FHIR.DTL.SDA3.vR4.PharmacyClaimLine.ClaimResponse.item")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.PharmacyClaimLines.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.item' action='set' key='index'  >
<annotation>
<![CDATA[ Adjudication for claim line items ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
<assign value='##class(HS.FHIR.DTL.Util.Element.Object).Identifier(source.PharmacyClaimNumber, "", "uc", " Unique Claim ID", "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBIdentifierType")' property='value' action='set' />
<assign value='target.identifier.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.identifier' action='set' key='index'  >
<annotation>
<![CDATA[ Business Identifier for a claim response ]]>
</annotation>
</assign></true> 
</if> 
<foreach property='source.ProcessNotes()' key='st' >
<assign value='target.processNote.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.processNote).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ProcessNotes.(st), "HS.FHIR.DTL.SDA3.vR4.ProcessNote.ClaimResponse.processNote")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ProcessNotes.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.processNote' action='set' key='index'  >
<annotation>
<![CDATA[ Note concerning adjudication ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Status")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).CodeTable(source.Status, "Claim", "status", .aux, "fm-status|4.0.1")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.status' action='set' >
<annotation>
<![CDATA[ active | cancelled | draft | entered-in-error
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension. 
 --- SDA3 HS.SDA3.PharmacyClaim:Status is optional, and FHIR4 ClaimResponse:status is required. No source value is mapped unconditionally to the target and *No Default Value* is supplied in case of no data received. This can be a serious gap. 
 --- This case might be fine, if there exists another mapping to the same target with a non-empty Condition to Set This Field. For example, two mappings could be defined to the same target, each with a Condition to Set This Field, in order to specify mutually exclusive cases.    ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<foreach property='source.TotalAdjudicationDetails()' key='st' >
<assign value='target.total.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.total).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.TotalAdjudicationDetails.(st), "HS.FHIR.DTL.SDA3.vR4.AdjudicationDetail.ClaimResponse.total")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.TotalAdjudicationDetails.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.total' action='set' key='index'  >
<annotation>
<![CDATA[ Adjudication totals ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Use")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).CodeTable(source.Use, "Claim", "use", .aux, "claim-use|4.0.1")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.use' action='set' >
<annotation>
<![CDATA[ claim | preauthorization | predetermination
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"claim"' property='target.use' action='set' />
</false> 
</if> </true> 
<false> 
<assign value='"claim"' property='target.use' action='set' />
</false> 
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.PharmacyClaim.ClaimResponse")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.PharmacyClaim.ClaimResponse).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
