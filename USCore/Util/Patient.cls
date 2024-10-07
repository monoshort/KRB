Class HS.FHIR.DTL.USCore.Util.Patient
{

/// Transform a citizenship CodeTable into a FHIR extension. This method is needed due to the unique
/// format of the hl7.org citizenship extension.
ClassMethod Races(races As %ListOfObjects, ByRef aux) As HS.FHIR.DTL.vSTU3.Model.Base.Extension
{
	if races.Count() = 0 {
		return ""
	}
	
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
	set extension = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension", "%New")
	
	set DTL = aux("transformer").GetDTL(races.GetAt(1), "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".CodeTableTranslated.Coding")
	if DTL = "" return ""
	
	set textValue = ""
	for i=1:1:races.Count() {
		#dim race As HS.SDA3.CodeTableDetail.Race = races.GetAt(i)
		set ombCategory = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension", "%New")
		set coding = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.Coding", "%New")
		$$$ThrowOnError($classmethod(DTL, "Transform", race, .coding, .aux))
		set ombCategory.url = "ombCategory"
		set ombCategory.valueCoding = coding
		do extension.extension.Insert(ombCategory)
		
		if i '= 1 set textValue = textValue _ ", "
		set textValue = textValue _ $select(race.OriginalText '= "": race.OriginalText, race.Description '= "": race.Description, 1: race.Code)
	}
	
	set text = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension", "%New")
	set text.url = "text"
	set text.valueString = textValue
	do extension.extension.Insert(text)
	
	quit extension
}

/// Transform an ethnic group CodeTable into a FHIR extension. This method is needed due to the unique
/// format of the hl7.org ethnic group extension.
ClassMethod EthnicGroup(ethnicGroup As HS.SDA3.CodeTableDetail.EthnicGroup, ByRef aux) As HS.FHIR.DTL.vSTU3.Model.Base.Extension
{
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
	set extension = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension", "%New")
	
	set DTL = aux("transformer").GetDTL(ethnicGroup, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".CodeTableTranslated.Coding")
	if DTL = "" return ""
	
	set ombCategory = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension", "%New")
	set coding = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.Coding", "%New")
	$$$ThrowOnError($classmethod(DTL, "Transform", ethnicGroup, .coding, .aux))
	set ombCategory.url = "ombCategory"
	set ombCategory.valueCoding = coding
	do extension.extension.Insert(ombCategory)
	
	set text = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension", "%New")
	set text.url = "text"
	set text.valueString = $select(ethnicGroup.OriginalText '= "": ethnicGroup.OriginalText,
									ethnicGroup.Description '= "": ethnicGroup.Description,
									1: ethnicGroup.Code)
	do extension.extension.Insert(text)
	
	quit extension
}

/// Transform a gender identity CodeTable into a FHIR extension.
/// This method includes logic for the coding of the USCore gender identity extension.
ClassMethod GenderIdentity(genderIdentity As HS.SDA3.CodeTableDetail.GenderIdentity, ByRef aux) As HS.FHIR.DTL.vSTU3.Model.Base.Extension
{
	//If the CodeTable has no code or description, we don't want to export it
	if ((genderIdentity.Code = "") && (genderIdentity.Description = "")) {
		return ""
	}
	
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
	set extension = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension", "%New")
	
	set DTL = aux("transformer").GetDTL(genderIdentity, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".CodeTableTranslated.Extension")
	if DTL = "" return ""

	$$$ThrowOnError($classmethod(DTL, "Transform", genderIdentity, .extension, .aux))

	if (extension.valueCodeableConcept.coding.Count() = 0) {
		quit extension
	}

	//Check Lookup table to see if code corresponds to a value in the USCore valueset
	set mappedCode = ##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3", configuredFhirVersion,"HS.SDA3.CodeTableDetail.GenderIdentity","gender-identity", genderIdentity)

	if (mappedCode '= ""){
		//If the code does fits the valueset, update it as well as the system and description
		set outCode = mappedCode
		set outDescription = ##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3", configuredFhirVersion,"HS.SDA3.CodeTableDetail.GenderIdentity","gender-identity-descriptions", mappedCode)
		if ((mappedCode = "OTH") || (mappedCode = "ASKU")) {
			set outSystem = "https://terminology.hl7.org/4.0.0/CodeSystem-v3-NullFlavor.html"
		} else {
			set outSystem = "http://snomed.info/sct"
		}

		set extension.valueCodeableConcept.coding.GetAt(1).code = outCode
		set extension.valueCodeableConcept.coding.GetAt(1).system = outSystem
		set extension.valueCodeableConcept.coding.GetAt(1).extension = ##class(%ListOfObjects).%New()
		if (outDescription '= "") {
			set extension.valueCodeableConcept.coding.GetAt(1).display = outDescription
		}
	}

	quit extension
}

/// Transform BirthGender CodeTable into a FHIR ExtensionCode.
/// Adds support for USCore birth sex extension: http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex
ClassMethod BirthGender(birthGender As HS.SDA3.CodeTableDetail.Gender, ByRef aux) As HS.FHIR.DTL.vSTU3.Model.Base.Extension
{
	//If the CodeTable has no code
	if (birthGender.Code = "") {
		return ""
	}
	
	set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
	set extension = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension", "%New")
	set extension.valueCode=birthGender.Code

	quit extension
}

}
