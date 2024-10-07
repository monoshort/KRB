/// Transforms SDA3 HS.SDA3.PharmacyClaim to vR4 Claim
Class HS.FHIR.DTL.SDA3.vR4.PharmacyClaim.Claim Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.PharmacyClaim, HS.FHIR.DTL.vR4.Model.Resource.Claim), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.PharmacyClaim' targetClass='HS.FHIR.DTL.vR4.Model.Resource.Claim' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.PharmacyClaim (SDA3) to Claim (vR4) ]]>
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
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.CustomPairs).Extension(source.CustomPairs, .target, .aux)' property='value' action='set' />
<assign value='target.extension.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-claim"' property='value.url' action='set' />
<assign value='value' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional content defined by implementations
 --- When the SDA3 source data contains a CustomPairs collection, and the target is FHIR, the collection is mapped to a FHIR extension that contains a Parameters resource. This Parameters resource is a collection of paired fields: name and valueString.   ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.PayeeBeneficiary'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.Object).CodeableConcept("beneficiary", "Beneficiary", "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBPayeeType")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.payee.type' action='set' >
<annotation>
<![CDATA[ Category of recipient ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='(source.IsDefined("PayeeProvider")) || (source.IsDefined("PayeeProviderOrganization"))'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.Object).CodeableConcept("provider", "Provider", "http://terminology.hl7.org/CodeSystem/payeetype")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.payee.type' action='set' >
<annotation>
<![CDATA[ Category of recipient ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='source.IsDefined("PayeeOther")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.Object).CodeableConcept("other", "Other", "http://terminology.hl7.org/CodeSystem/payeetype")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.payee.type' action='set' >
<annotation>
<![CDATA[ Category of recipient ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='source.IsDefined("PayeeSubscriber")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.Object).CodeableConcept("subscriber", "Subscriber", "http://terminology.hl7.org/CodeSystem/payeetype")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.payee.type' action='set' >
<annotation>
<![CDATA[ Category of recipient ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<foreach property='source.AdditionalSupportingInfo()' key='st' >
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).SupportingInfo(source.AdditionalSupportingInfo.GetAt(st), target, .aux)' property='value' action='set' />
<assign value='target.supportingInfo.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.supportingInfo' action='set' key='index'  >
<annotation>
<![CDATA[ Supporting information ]]>
</annotation>
</assign></true> 
</if> </foreach>
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
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "BillingNetworkContractingStatus")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).SupportingInfoCode(source.BillingNetworkContractingStatus, "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBSupportingInfoType", "billingnetworkcontractingstatus", target, .aux)' property='value' action='set' />
<assign value='target.supportingInfo.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.supportingInfo' action='set' key='index'  >
<annotation>
<![CDATA[ Supporting information ]]>
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
<assign value='reference' property='target.provider' action='set'  >
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
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "BrandGenericIndicator")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).SupportingInfoCode(source.BrandGenericIndicator, "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBSupportingInfoType", "brandgenericcode", target, .aux)' property='value' action='set' />
<assign value='target.supportingInfo.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.supportingInfo' action='set' key='index'  >
<annotation>
<![CDATA[ Supporting information ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<foreach property='source.CareTeamMembers()' key='st' >
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).CareTeam(source.CareTeamMembers.GetAt(st), target, .aux)' property='value' action='set' />
<assign value='target.careTeam.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.careTeam' action='set' key='index'  >
<annotation>
<![CDATA[ Members of the care team ]]>
</annotation>
</assign></true> 
</if> </foreach>
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
<![CDATA[ Category or discipline
 --- In this case, claim-type is the *Required* FHIR4 ValueSet for codes, but if you need to express meanings not found in claim-type, you may formally *Extend* claim-type to add codes to it. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "CompoundCode")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).SupportingInfoCode(source.CompoundCode, "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBSupportingInfoType", "compoundcode", target, .aux)' property='value' action='set' />
<assign value='target.supportingInfo.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.supportingInfo' action='set' key='index'  >
<annotation>
<![CDATA[ Supporting information ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).SupportingInfoQuantity(source.DaysSupply, "", "", "", "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBSupportingInfoType", "dayssupply", target, .aux)' property='value' action='set' />
<assign value='target.supportingInfo.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.supportingInfo' action='set' key='index'  >
<annotation>
<![CDATA[ Supporting information ]]>
</annotation>
</assign></true> 
</if> 
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "DispensedAsWritten")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).SupportingInfoCode(source.DispensedAsWritten, "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBSupportingInfoType", "dawcode", target, .aux)' property='value' action='set' />
<assign value='target.supportingInfo.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.supportingInfo' action='set' key='index'  >
<annotation>
<![CDATA[ Supporting information ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<if condition='source.EncounterNumber&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.EncounterNumber, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.EncounterNumber, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-claim-encounter-number"' property='tmp.url' action='set' />
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
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "EnteredAt")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.EnteredAt, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.Organization.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.EnteredAt, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-claim-entered-at"' property='tmp.url' action='set' />
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
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "EnteredBy")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Practitioner).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.EnteredBy, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.Practitioner")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.EnteredBy, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.EnteredBy, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.enterer' action='set'  >
<annotation>
<![CDATA[ Author of the claim ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<if condition='source.EnteredOn&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.EnteredOn, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.TimeStamp.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.EnteredOn, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-claim-entered-on"' property='tmp.url' action='set' />
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
<if condition='source.ExternalId&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ExternalId, "HS.FHIR.DTL.SubXFrm.SDA3.vR4.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ExternalId, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/pharmacy-claim-external-id"' property='tmp.url' action='set' />
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
<if condition='source.FromTime&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.FromTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.billablePeriod.start' action='set' >
<annotation>
<![CDATA[ Starting time with inclusive boundary ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
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
<![CDATA[ Business Identifier for claim ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</foreach>
<foreach property='source.OtherProcedures()' key='st' >
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.MedicalClaim).ProcedureSDA3(source.OtherProcedures.GetAt(st), target, "secondary", .aux)' property='value' action='set' />
<assign value='target.procedure.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.procedure' action='set' key='index'  >
<annotation>
<![CDATA[ Clinical procedures performed ]]>
</annotation>
</assign></true> 
</if> </foreach>
<if condition='source.PayeeBeneficiary&apos;=""'> 
<true>
<if condition='source.PayeeBeneficiary'> 
<true>
<assign value='aux("transformer").GetPatientReference()' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.payee.party' action='set' >
<annotation>
<![CDATA[ Recipient reference ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "PayeeOther")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.RelatedPerson).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.PayeeOther, "HS.FHIR.DTL.SDA3.vR4.Guarantor.RelatedPerson")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.PayeeOther, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.PayeeOther, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.payee.party' action='set'  >
<annotation>
<![CDATA[ Recipient reference ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "PayeeProvider")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Practitioner).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.PayeeProvider, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.CareProvider.Practitioner")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.PayeeProvider, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.PayeeProvider, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.payee.party' action='set'  >
<annotation>
<![CDATA[ Recipient reference ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "PayeeProviderOrganization")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.Organization).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.PayeeProviderOrganization, "HS.FHIR.DTL.SDA3.vR4.CodeTableDetail.Organization.Organization")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.PayeeProviderOrganization, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.PayeeProviderOrganization, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.payee.party' action='set'  >
<annotation>
<![CDATA[ Recipient reference ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "PayeeSubscriber")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Resource.RelatedPerson).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.PayeeSubscriber, "HS.FHIR.DTL.SDA3.vR4.Guarantor.RelatedPerson")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.PayeeSubscriber, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.PayeeSubscriber, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.payee.party' action='set'  >
<annotation>
<![CDATA[ Recipient reference ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
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
<![CDATA[ Target ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
<foreach property='source.PharmacyClaimLines()' key='st' >
<assign value='target.item.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.Claim.item).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.PharmacyClaimLines.(st), "HS.FHIR.DTL.SDA3.vR4.PharmacyClaimLine.Claim.item")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.PharmacyClaimLines.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.item' action='set' key='index'  >
<annotation>
<![CDATA[ Product or service provided ]]>
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
<![CDATA[ Business Identifier for claim ]]>
</annotation>
</assign></true> 
</if> 
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "PrescriptionOrigin")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).SupportingInfoCode(source.PrescriptionOrigin, "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBSupportingInfoType", "rxorigincode", target, .aux)' property='value' action='set' />
<assign value='target.supportingInfo.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.supportingInfo' action='set' key='index'  >
<annotation>
<![CDATA[ Supporting information ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "PrimaryProcedure")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.MedicalClaim).ProcedureSDA3(source.PrimaryProcedure, target, "primary", .aux)' property='value' action='set' />
<assign value='target.procedure.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.procedure' action='set' key='index'  >
<annotation>
<![CDATA[ Clinical procedures performed ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Priority")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Priority, "HS.FHIR.DTL.SDA3.vR4.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Priority, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.priority' action='set'  >
<annotation>
<![CDATA[ Desired processing ugency
 --- In this case, any FHIR4 code may be used; process-priority shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).SupportingInfoDate(source.ReceivedDate, "", 0, "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBSupportingInfoType", "clmrecvddate", target, .aux)' property='value' action='set' />
<assign value='target.supportingInfo.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.supportingInfo' action='set' key='index'  >
<annotation>
<![CDATA[ Supporting information ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit).SupportingInfoQuantity(source.RefillNumber, "", "", "", "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBSupportingInfoType", "refillnum", target, .aux)' property='value' action='set' />
<assign value='target.supportingInfo.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.supportingInfo' action='set' key='index'  >
<annotation>
<![CDATA[ Supporting information ]]>
</annotation>
</assign></true> 
</if> 
<foreach property='source.RelatedClaims()' key='st' >
<assign value='target.related.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vR4.Model.Element.Claim.related).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.RelatedClaims.(st), "HS.FHIR.DTL.SDA3.vR4.RelatedClaim.Claim.related")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.RelatedClaims.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.related' action='set' key='index'  >
<annotation>
<![CDATA[ Prior or corollary claims ]]>
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
 --- SDA3 HS.SDA3.PharmacyClaim:Status is optional, and FHIR4 Claim:status is required. No source value is mapped unconditionally to the target and *No Default Value* is supplied in case of no data received. This can be a serious gap. 
 --- This case might be fine, if there exists another mapping to the same target with a non-empty Condition to Set This Field. For example, two mappings could be defined to the same target, each with a Condition to Set This Field, in order to specify mutually exclusive cases.    ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.SubmissionDate, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.created' action='set' >
<annotation>
<![CDATA[ Resource creation date
 --- The source is optional, but the target is *Required*. When there is no source data to assign to this field, there is no default value, so the FHIR resource fails validation and is not saved. For this field, this is the desired behavior.   ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.ToTime&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.ToTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.billablePeriod.end' action='set' >
<annotation>
<![CDATA[ End time with inclusive boundary, if not ongoing ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
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
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.PharmacyClaim.Claim")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vR4.PharmacyClaim.Claim).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
