Class HS.FHIR.DTL.Util.SDA3.Handler.ExplanationOfBenefit
{

ClassMethod Insurance(coverageExternalId As %String, isFocal As %Boolean, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.insurance
{
	if coverageExternalId = "" return ""
	
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	set insurance = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.ExplanationOfBenefit.insurance", "%New")
	set insurance.focal = isFocal
	set insurance.coverage = aux("transformer").GetReference("Coverage", coverageExternalId)
	
	return insurance
}

/// This method is used by transformations for MedicalExplanationOfBenefit/ExplanationOfBenefit,
/// MedicalClaim/Claim, and PharmacyClaim/Claim. It produces a "careTeam" Backbone element for
/// ExplanationOfBenefit and Claim resources. The "target" input and the return type are
/// abstracted to %RegisteredObject to reflect the multipurpose use of this method.
ClassMethod CareTeam(source As HS.SDA3.FinancialCareTeamMember, target As %RegisteredObject, ByRef aux) As %RegisteredObject
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	set careTeam = ""
	
	set DTL = aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".FinancialCareTeamMember." _ target.%ClassName(0) _ ".careTeam")
	if DTL '= "" {
		set careTeam = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element." _ target.%ClassName(0) _ ".careTeam", "%New")
		$$$ThrowOnError($classmethod(DTL, "Transform", source, .careTeam, .aux))
		set careTeam.sequence = target.careTeam.Count() + 1
	}
	return careTeam
}

/// This method produces a "careTeam" Backbone element for Claim resources, using the 
/// HS.SDA3.CodeTableDetail.CareProvider data type.
ClassMethod CareTeamCareProvider(source As HS.SDA3.CodeTableDetail.CareProvider, target As %RegisteredObject, ByRef aux) As %RegisteredObject
{
	set financialCareTeamMember = ##class(HS.SDA3.FinancialCareTeamMember).%New()
	set financialCareTeamMember.CareProvider = source
	
	return ..CareTeam(financialCareTeamMember, target, .aux)
}

/// The SupportingInfo* methods are used by transformations for MedicalExplanationOfBenefit/ExplanationOfBenefit,
/// MedicalClaim/Claim, and PharmacyClaim/Claim. Despite the ExplanationOfBenefit-centered naming of variables
/// and object types in these methods, the supportingInfo Backbone element for FHIR ExplanationOfBenefit and
/// Claim are the same. Therefore the logic will work the same when called for either transformation.
ClassMethod SupportingInfo(source As HS.SDA3.EOBSupportingInfo, EOB As HS.FHIR.DTL.vR4.Model.Resource.ExplanationOfBenefit, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.supportingInfo
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	set supportingInfo = ""
	
	set DTL = aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".EOBSupportingInfo." _ EOB.%ClassName(0) _ ".supportingInfo")
	if DTL '= "" {
		set supportingInfo = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element." _ EOB.%ClassName(0) _ ".supportingInfo", "%New")
		$$$ThrowOnError($classmethod(DTL, "Transform", source, .supportingInfo, .aux))
		set supportingInfo.sequence = EOB.supportingInfo.Count() + 1
	}
	return supportingInfo
}

ClassMethod SupportingInfoCode(source As HS.SDA3.CodeTableTranslated, categorySystem As %String, categoryValue As %String, EOB As HS.FHIR.DTL.vR4.Model.Resource.ExplanationOfBenefit, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.supportingInfo
{
	set sdaSupportingInfo = ##class(HS.SDA3.EOBSupportingInfo).%New()
	set sdaSupportingInfo.Category.Code = categoryValue
	set sdaSupportingInfo.Category.SDACodingStandard = categorySystem
	
	set sdaSupportingInfo.Code = source
	
	return ..SupportingInfo(sdaSupportingInfo, EOB, .aux)
}

ClassMethod SupportingInfoQuantity(source As %Numeric, unitCode As %String, unitDescription As %String, unitSystem As %String, categorySystem As %String, categoryValue As %String, EOB As HS.FHIR.DTL.vR4.Model.Resource.ExplanationOfBenefit, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.supportingInfo
{
	if source = "" return ""
	
	set sdaSupportingInfo = ##class(HS.SDA3.EOBSupportingInfo).%New()
	set sdaSupportingInfo.Category.Code = categoryValue
	set sdaSupportingInfo.Category.SDACodingStandard = categorySystem
	
	set sdaSupportingInfo.ValueQuantity.Value = source
	if unitCode '= "" {
		set sdaSupportingInfo.ValueQuantity.UnitOfMeasure.Code = unitCode
		set sdaSupportingInfo.ValueQuantity.UnitOfMeasure.Description = unitDescription
		set sdaSupportingInfo.ValueQuantity.UnitOfMeasure.SDACodingStandard = unitSystem
	}
	return ..SupportingInfo(sdaSupportingInfo, EOB, .aux)
}

ClassMethod SupportingInfoDate(start As HS.SDA3.TimeStamp = "", end As HS.SDA3.TimeStamp = "", isPeriod As %Boolean, categorySystem As %String, categoryValue As %String, EOB As HS.FHIR.DTL.vR4.Model.Resource.ExplanationOfBenefit, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.supportingInfo
{
	if (start = "") && (end = "") return ""
	
	set sdaSupportingInfo = ##class(HS.SDA3.EOBSupportingInfo).%New()
	set sdaSupportingInfo.Category.Code = categoryValue
	set sdaSupportingInfo.Category.SDACodingStandard = categorySystem
	
	if isPeriod {
		set sdaSupportingInfo.TimingPeriodStart = start
		set sdaSupportingInfo.TimingPeriodEnd = end
	}
	else {
		set sdaSupportingInfo.TimingDate = start
	}
	
	return ..SupportingInfo(sdaSupportingInfo, EOB, .aux)
}

ClassMethod SupportingInfoReference(source As HS.SDA3.CodeTableTranslated, DTL As %String, categorySystem As %String, categoryValue As %String, EOB As HS.FHIR.DTL.vR4.Model.Resource.ExplanationOfBenefit, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.supportingInfo
{
	set sdaSupportingInfo = ##class(HS.SDA3.EOBSupportingInfo).%New()
	set sdaSupportingInfo.Category.Code = categoryValue
	set sdaSupportingInfo.Category.SDACodingStandard = categorySystem
	
	set DTL = aux("transformer").GetDTL(source, DTL)
	if DTL '= "" {
		set resource = $classmethod($classmethod(DTL, "GetTargetType"), "%New")
		$$$ThrowOnError($classmethod(DTL, "Transform", source, .resource, .aux))
		set reference = aux("transformer").AddResource(source, resource)
		set sdaSupportingInfo.ValueReference = reference.reference
	}
	
	return ..SupportingInfo(sdaSupportingInfo, EOB, .aux)
}

ClassMethod SupportingInfoString(source As %String, categorySystem As %String, categoryValue As %String, EOB As HS.FHIR.DTL.vR4.Model.Resource.ExplanationOfBenefit, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.supportingInfo
{
	set sdaSupportingInfo = ##class(HS.SDA3.EOBSupportingInfo).%New()
	set sdaSupportingInfo.Category.Code = categoryValue
	set sdaSupportingInfo.Category.SDACodingStandard = categorySystem
	
	set sdaSupportingInfo.ValueString = source
	
	return ..SupportingInfo(sdaSupportingInfo, EOB, .aux)
}

ClassMethod Adjudication(source As HS.SDA3.AdjudicationDetail, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.item.adjudication
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	set adjudication = ""
	set DTL = aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".AdjudicationDetail.ExplanationOfBenefit.adjudication")
	if DTL '= "" {
		set adjudication = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.ExplanationOfBenefit.item.adjudication", "%New")
		$$$ThrowOnError($classmethod(DTL, "Transform", source, .adjudication, .aux))
	}
	
	return adjudication
}

ClassMethod AdjudicationReason(source As HS.SDA3.CodeTableTranslated, categorySystem As %String, categoryValue As %String, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.item.adjudication
{
	set sdaAdjudication = ##class(HS.SDA3.AdjudicationDetail).%New()
	set sdaAdjudication.Category.Code = categoryValue
	set sdaAdjudication.Category.SDACodingStandard = categorySystem
	
	set sdaAdjudication.Reason = source
	
	return ..Adjudication(sdaAdjudication, .aux)
}

ClassMethod AdjudicationCategory(source As HS.SDA3.CodeTableTranslated, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.item.adjudication
{
	set sdaAdjudication = ##class(HS.SDA3.AdjudicationDetail).%New()
	set sdaAdjudication.Category = source
	
	return ..Adjudication(sdaAdjudication, .aux)
}

ClassMethod AdjudicationValue(source As %String, categorySystem As %String, categoryValue As %String, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.item.adjudication
{
	if source = "" return ""
	
	set sdaAdjudication = ##class(HS.SDA3.AdjudicationDetail).%New()
	set sdaAdjudication.Category.Code = categoryValue
	set sdaAdjudication.Category.SDACodingStandard = categorySystem
	
	set sdaAdjudication.Value = source
	
	return ..Adjudication(sdaAdjudication, .aux)
}

ClassMethod AdjudicationAmount(source As HS.SDA3.CodeTableTranslated, categorySystem As %String, categoryValue As %String, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.item.adjudication
{
	set sdaAdjudication = ##class(HS.SDA3.AdjudicationDetail).%New()
	set sdaAdjudication.Category.Code = categoryValue
	set sdaAdjudication.Category.SDACodingStandard = categorySystem
	
	set sdaAdjudication.Value = source
	
	return ..Adjudication(sdaAdjudication, .aux)
}

ClassMethod TotalCategory(source As HS.SDA3.CodeTableTranslated, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.total
{
	set sdaAdjudication = ##class(HS.SDA3.AdjudicationDetail).%New()
	set sdaAdjudication.Category = source
	set sdaAdjudication.Amount = 0
	set sdaAdjudication.Currency.Code = "USD"
	set sdaAdjudication.Currency.SDACodingStandard = "urn:iso:std:iso:4217"
	
	return ..Adjudication(sdaAdjudication, .aux)
}

ClassMethod Diagnosis(sdaDiagnosis As HS.SDA3.Diagnosis, target As HS.FHIR.DTL.vR4.Model.Resource.ExplanationOfBenefit, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.diagnosis
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	set diagnosis = ""
	
	set DTL = aux("transformer").GetDTL(sdaDiagnosis, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".Diagnosis.ExplanationOfBenefit.diagnosis")
	if DTL '= "" {
		set diagnosis = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.ExplanationOfBenefit.diagnosis", "%New")
		$$$ThrowOnError($classmethod(DTL, "Transform", sdaDiagnosis, .diagnosis, .aux))
		set diagnosis.sequence = target.diagnosis.Count() + 1
	}
	
	return diagnosis
}

ClassMethod Procedure(sdaProcedure As HS.SDA3.Procedure, isPrimary As %Boolean, target As HS.FHIR.DTL.vR4.Model.Resource.ExplanationOfBenefit, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ExplanationOfBenefit.procedure
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	set procedure = ""
	
	set DTL = aux("transformer").GetDTL(sdaProcedure, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".Procedure.ExplanationOfBenefit.procedure")
	if DTL '= "" {
		set procedure = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.ExplanationOfBenefit.procedure", "%New")
		$$$ThrowOnError($classmethod(DTL, "Transform", sdaProcedure, .procedure, .aux))
		if isPrimary {
			set procedure.sequence = 1
			set typeCode = "principal"
			set typeDisplay = "Principal"
		}
		else {
			set procedure.sequence = target.procedure.Count() + 2
			set typeCode = "other"
			set typeDisplay = "Other"
		}
		set codeableConcept = ##class(HS.FHIR.DTL.Util.Element.Object).CodeableConcept(typeCode, typeDisplay, "http://hl7.org/fhir/us/carin-bb/CodeSystem/C4BBClaimProcedureType")
		do procedure.type.Insert(codeableConcept)
	}
	
	return procedure
}

/// This method is used by transformations for PharmacyEOBLine/ExplanationOfBenefit.item.detail,
/// and PharmacyClaimLine/Claim.item.detail. It produces a "item.detail" Backbone element for
/// ExplanationOfBenefit and Claim resources. The "target" input and the return type are
/// abstracted to %RegisteredObject to reflect the multipurpose use of this method.
ClassMethod ItemDetail(compoundMedication As HS.SDA3.CodeTableDetail.DrugProduct, target As %RegisteredObject, ByRef aux) As %RegisteredObject
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	set detail = ""
	
	set targetClass = $classname(target)
	set resourceType = $Select(targetClass[".Claim.":"Claim", targetClass[".ClaimResponse.":"ClaimResponse", 1:"ExplanationOfBenefit")
	
	set DTL = aux("transformer").GetDTL(compoundMedication, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".CodeTableDetail.DrugProduct." _ resourceType _ ".item.detail")
	if DTL '= "" {
		set detail = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element." _ resourceType _ ".item.detail", "%New")
		$$$ThrowOnError($classmethod(DTL, "Transform", compoundMedication, .detail, .aux))
		set detail.sequence = target.detail.Count() + 1
	}
	
	return detail
}

}
