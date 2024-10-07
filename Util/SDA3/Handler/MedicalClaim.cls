Class HS.FHIR.DTL.Util.SDA3.Handler.MedicalClaim
{

/// This method is needed to ensure the sequence numbers for the list of diagnoses is accurate and puts the principal
/// diagnosis first. This method should be used by SDA3 to STU3 (FHIR3) transformations ONLY.
ClassMethod Diagnosis(diagnosis As HS.SDA3.CodeTableDetail.Diagnosis, isPrincipal As %Boolean, diagnosisList As %ListOfObjects, ByRef aux) As HS.FHIR.DTL.vSTU3.Model.Element.Claim.diagnosis
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
	set target = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.Claim.diagnosis", "%New")
	set diagnosisCodeableConcept = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.CodeableConcept", "%New")
	set DTL = aux("transformer").GetDTL(diagnosis, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".CodeTableTranslated.CodeableConcept")
	if DTL = "" quit ""
	$$$ThrowOnError($classmethod(DTL, "Transform", diagnosis, .diagnosisCodeableConcept, .aux))
	
	if isPrincipal {
		set target.sequence = 1
	}
	else {
		set target.sequence = diagnosisList.Count() + 2
	}
	set target.diagnosisCodeableConcept = diagnosisCodeableConcept
	
	quit target
}

/// This method is needed to ensure the sequence numbers for the list of procedures is accurate.
/// This method should be used by SDA3 to STU3 (FHIR3) transformations ONLY.
ClassMethod Procedure(procedure As HS.SDA3.CodeTableDetail.Procedure, claim As HS.FHIR.DTL.vSTU3.Model.Resource.Claim, ByRef aux) As HS.FHIR.DTL.vSTU3.Model.Element.Claim.procedure
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaFromClassname($classname(claim))
	set target = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.Claim.procedure", "%New")
	set procedureCodeableConcept = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.CodeableConcept", "%New")
	set DTL = aux("transformer").GetDTL(procedure, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".CodeTableTranslated.CodeableConcept")
	if DTL = "" quit ""
	$$$ThrowOnError($classmethod(DTL, "Transform", procedure, .procedureCodeableConcept, .aux))
	
	set target.sequence = claim.procedure.Count() + 1
	set target.procedureCodeableConcept = procedureCodeableConcept
	
	quit target
}

/// This method is used by transformations for MedicalClaim/Claim and PharmacyClaim/Claim.
/// It produces a "procedure" Backbone element for Claim resources. It ensures the sequence
/// numbers for the list of procedures, and adds the type, if specified.
ClassMethod ProcedureSDA3(procedure As HS.SDA3.Procedure, target As HS.FHIR.DTL.vR4.Model.Resource.Claim, type As %String, ByRef aux) As %RegisteredObject
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaFromClassname($classname(target))
	set claimProcedure = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element." _ target.%ClassName(0) _ ".procedure", "%New")
	set DTL = aux("transformer").GetDTL(procedure, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".Procedure." _ target.%ClassName(0) _ ".procedure")
	if DTL = "" quit ""
	$$$ThrowOnError($classmethod(DTL, "Transform", procedure, .claimProcedure, .aux))
	
	set claimProcedure.sequence = target.procedure.Count() + 1
	
	// type is not a property of the Claim procedure Backbone element in STU3.
	if ($get(type) '= "") && (configuredFhirVersion '= "vSTU3") {
		set typeCodeableConcept = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.CodeableConcept", "%New")
		set typeCodeableConcept.text = type
		set typeCoding = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.Coding", "%New")
		set typeCoding.code = type
		set typeCoding.system = "http://terminology.hl7.org/CodeSystem/ex-procedure-type"
		do typeCodeableConcept.coding.Insert(typeCoding)
		do claimProcedure.type.Insert(typeCodeableConcept)
	}
	
	quit claimProcedure
}

/// This method is needed to ensure the sequence numbers for the list of Claim items is accurate.
ClassMethod MedicalClaimLine(medicalClaimLine As HS.SDA3.MedicalClaimLine, claim As HS.FHIR.DTL.vR4.Model.Resource.Claim, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.Claim.item
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaFromClassname($classname(claim))
	set item = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.Claim.item", "%New")
	set DTL = aux("transformer").GetDTL(medicalClaimLine, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".MedicalClaimLine.Claim.item")
	if DTL = "" quit ""
	$$$ThrowOnError($classmethod(DTL, "Transform", medicalClaimLine, .item, .aux))
	
	set item.sequence = claim.item.Count() + 1
	
	quit item
}

/// This method is needed to ensure the sequence numbers for the list of Claim items is accurate.
ClassMethod MedicalClaimLineToResponseItem(medicalClaimLine As HS.SDA3.MedicalClaimLine, target As HS.FHIR.DTL.vR4.Model.Resource.ClaimResponse, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.item
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaFromClassname($classname(claim))
	set item = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.ClaimResponse.item", "%New")
	set DTL = aux("transformer").GetDTL(medicalClaimLine, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".MedicalClaimLine.ClaimResponse.item")
	if DTL = "" quit ""
	$$$ThrowOnError($classmethod(DTL, "Transform", medicalClaimLine, .item, .aux))
	
	set item.sequence = claim.item.Count() + 1
	
	quit item
}

ClassMethod MedicalClaimLineToInsurance(claim, target, ByRef aux)
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
	set count = 0
	for i=1:1:claim.MedicalClaimLines.Count() {
		for j=1:1:claim.MedicalClaimLines.GetAt(i).HealthFunds.Count() {
			set healthfund = claim.MedicalClaimLines.GetAt(i).HealthFunds.GetAt(j)
			set insurance = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.Claim.insurance", "%New")
			set coverage = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Resource.Coverage", "%New")
			set DTL = aux("transformer").GetDTL(healthfund, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".HealthFund.Coverage")
			if DTL = "" continue
			$$$ThrowOnError($classmethod(DTL, "Transform", healthfund, .coverage, .aux))
			set reference = aux("transformer").AddResource(healthfund, coverage)
			
			set insurance.sequence = $i(count)
			set insurance.focal = 0
			set insurance.coverage = reference
			
	 		do target.insurance.Insert(insurance)
		}
	}
	
	return target
}

/// This method is used for transformations for MedicalClaim/Claim and PharmacyClaim/Claim.
/// It produces a "diagnosis" Backbone element for Claim resources, using CodeTableDetail
/// input. It ensures the sequence numbers for the list of diagnoses, and adds the type,
/// if specified.
ClassMethod DiagnosisCodeTable(diagnosis As HS.SDA3.CodeTableDetail.Diagnosis, target As HS.FHIR.DTL.vR4.Model.Resource.Claim, type As %String, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.Claim.diagnosis
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
	set claimDiagnosis = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.Claim.diagnosis", "%New")
	set diagnosisCodeableConcept = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.CodeableConcept", "%New")
	set DTL = aux("transformer").GetDTL(diagnosis, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".CodeTableTranslated.CodeableConcept")
	if DTL = "" quit ""
	$$$ThrowOnError($classmethod(DTL, "Transform", diagnosis, .diagnosisCodeableConcept, .aux))
	
	set claimDiagnosis.diagnosisCodeableConcept = diagnosisCodeableConcept
	
	set claimDiagnosis.sequence = target.diagnosis.Count() + 1
	
	if $get(type) '= "" {
		set typeCodeableConcept = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.CodeableConcept", "%New")
		set typeCodeableConcept.text = type
		set typeCoding = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.Coding", "%New")
		set typeCoding.code = type
		set typeCoding.system = "http://terminology.hl7.org/CodeSystem/ex-diagnosistype"
		do typeCodeableConcept.coding.Insert(typeCoding)
		do claimDiagnosis.type.Insert(typeCodeableConcept)
	}
	
	quit claimDiagnosis
}

/// This method is used for transformations for MedicalClaim/Claim and PharmacyClaim/Claim.
/// It produces a "diagnosis" Backbone element for Claim resources, using SDA3 Object type
/// input. It ensures the sequence numbers for the list of diagnoses.
ClassMethod DiagnosisSDA3(diagnosis As HS.SDA3.Diagnosis, target As HS.FHIR.DTL.vR4.Model.Resource.Claim, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.Claim.diagnosis
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	set claimDiagnosis = ""
	
	set DTL = aux("transformer").GetDTL(diagnosis, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".Diagnosis.Claim.diagnosis")
	if DTL '= "" {
		set claimDiagnosis = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.Claim.diagnosis", "%New")
		$$$ThrowOnError($classmethod(DTL, "Transform", diagnosis, .claimDiagnosis, .aux))
		set claimDiagnosis.sequence = target.diagnosis.Count() + 1
	}
	
	return claimDiagnosis
}

/// This method produces an "insurance" Backbone element for Claim and ClaimResponse
/// resources. "target" input and the return type are abstracted to %RegisteredObject
/// to reflect the multipurpose use of this method.
ClassMethod Insurance(coverageExternalId As %String, target As %RegisteredObject, isFocal As %Boolean, ByRef aux) As %RegisteredObject
{
	if coverageExternalId = "" return ""
	
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	set insurance = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element." _ target.%ClassName(0) _ ".insurance", "%New")
	set insurance.focal = isFocal
	set insurance.coverage = aux("transformer").GetReference("Coverage", coverageExternalId)
	
	if isFocal {
		set insurance.sequence = 1
	} else {
		set insurance.sequence = target.insurance.Count() + 2
	}
	
	return insurance
}

ClassMethod Adjudication(source As HS.SDA3.AdjudicationDetail, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.item.adjudication
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	set adjudication = ""
	set DTL = aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".AdjudicationDetail.ClaimResponse.adjudication")
	if DTL '= "" {
		set adjudication = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.ClaimResponse.item.adjudication", "%New")
		$$$ThrowOnError($classmethod(DTL, "Transform", source, .adjudication, .aux))
	}
	
	return adjudication
}

ClassMethod AdjudicationAmountNumeric(source As HS.SDA3.Numeric, categorySystem As %String, categoryValue As %String, ByRef aux) As HS.FHIR.DTL.vR4.Model.Element.ClaimResponse.item.adjudication
{
	if source = "" return ""
	
	set sdaAdjudication = ##class(HS.SDA3.AdjudicationDetail).%New()
	set sdaAdjudication.Category.Code = categoryValue
	set sdaAdjudication.Category.SDACodingStandard = categorySystem
	
	set sdaAdjudication.Amount = source
	
	return ..Adjudication(sdaAdjudication, .aux)
}

ClassMethod ProcedureModifier(source As %String, ByRef aux) As HS.FHIR.DTL.vR4.Model.Datatype.CodeableConcept
{
	if source = "" return ""
	
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName((aux("transformer").fhirVersion))
	
	set modifier = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.CodeableConcept", "%New")
	set modifier.text = source
	set modifierCoding = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.Coding", "%New")
	set modifierCoding.code = source
	do modifier.coding.Insert(modifierCoding)
	
	return modifier
}

}
