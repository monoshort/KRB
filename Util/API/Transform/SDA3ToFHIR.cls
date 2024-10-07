Include HS.FHIRServer

Class HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR Extends %RegisteredObject
{

/// Contains the FHIR Bundle generated during the transformation. If transforming
/// individual SDA classes, it contain the FHIR representation of those classes and
/// can be continuously appended to. If transforming a Container, 
/// will be the entire contents of the Container, represented as FHIR.
Property bundle As %DynamicObject [ Calculated ];

Property schema As HS.FHIRMeta.API [ Calculated ];

Property fhirVersion As %String [ Calculated ];

Property %bundle As %DynamicObject [ Private ];

Property %schema As HS.FHIRMeta.API [ Private ];

Property %fhirVersion As %String [ Private ];

Property %resourceValidator As HS.FHIRServer.Util.ResourceValidator [ Private ];

Property %patientId As %String [ Private ];

/// Tracks the id mapping from an SDA identifier and resource type to a
/// resource id
Property %resourceIds As %String [ MultiDimensional, Private ];

/// Maps the resource type and id to the actual resource for O(1) lookup when
/// resolving certain references
Property %resourceIndex [ MultiDimensional, Private ];

/// Provenance resource set-aside queue.  Cannot populate target(s) until all streamlets have been transformed.
Property %provenance [ MultiDimensional, Private ];

/// Provenance targets, accumulated during post-processing in TransformHelper
Property %provenanceTarget [ MultiDimensional, Private ];

/// Transforms an SDA stream (Container or SDA class) to the specified FHIR version. Returns an instance of this class
/// which contains a "bundle" property. That property will contain a FHIR Bundle with all the resources
/// generated during the transformation, and with all references resolved. If <var>patientId</var> or
/// <var>encounterId</var> are specified, those values will go into any applicable Patient and Encounter
/// references.
/// @API.Method
/// @Argument	stream			%Stream representation of an SDA object or Container
/// @Argument	SDAClassname	Classname for the object contained in the stream (eg. HS.SDA3.Container)
/// @Argument	fhirVersion		Version of FHIR used by the resource, eg. "STU3", "R4"
/// @Argument	patientId		(optional) FHIR resource id to be assigned to the Patient resource
/// @Argument	encounterId		(optional) FHIR resource id to be assigned to the Encounter resource, if not transforming a Container
ClassMethod TransformStream(stream As %Stream.Object, SDAClassname As %String, fhirVersion As %String, patientId As %String = "", encounterId As %String = "") As HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR
{
	set source = $classmethod(SDAClassname, "%New")
	if SDAClassname = "HS.SDA3.Container" {
		$$$ThrowOnError(source.InitializeXMLParse(stream, "SDA3"))
	}
	else {
		$$$ThrowOnError(source.XMLImportSDAString(stream.Read(3700000)))
	}
	return ..TransformObject(source, fhirVersion, patientId, encounterId)
}

/// Transforms an SDA object (Container or SDA class) to the specified FHIR version. Returns an instance of this class
/// which contains a "bundle" property. That property will contain a FHIR Bundle with all the resources
/// generated during the transformation, and with all references resolved. If <var>patientId</var> or
/// <var>encounterId</var> are specified, those values will go into any applicable Patient and Encounter
/// references.
/// @API.Method
/// @Argument	source			SDA object or Container
/// @Argument	fhirVersion		Version of FHIR used by the resource, eg. "STU3", "R4"
/// @Argument	patientId		(optional) FHIR resource id to be assigned to the Patient resource
/// @Argument	encounterId		(optional) FHIR resource id to be assigned to the Encounter resource, if not transforming a Container
ClassMethod TransformObject(source, fhirVersion As %String, patientId As %String = "", encounterId As %String = "") As HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR
{
	set schema = ##class(HS.FHIRServer.Schema).LoadSchema(fhirVersion)
	set transformer = ..%New(schema)
	
	//SDA gets patient and encounter id and Container only gets patient id
	//because a Container can have multiple encounters and we can't assume which one they're referring to
	if source.%ClassName(1) = "HS.SDA3.Container" {
		do transformer.TransformContainer(source, patientId)
	}
	else {
		do transformer.TransformSDA(source, patientId, encounterId)
	}
	
	return transformer
}

/// Transforms an SDA Container to FHIR. Returns an instance of this class
/// which contains a "bundle" property. That property will contain a FHIR Bundle with all the resources
/// generated during the transformation, and with all references resolved. 
/// @API.Method
/// @Argument	source			SDA Container
/// @Argument	patientId		(optional) FHIR resource id to be assigned to the Patient resource
Method TransformContainer(source As HS.SDA3.Container, patientId As %String = "") As HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR
{
	if ..%bundle.entry.%Size() > 0 {
		$$$ThrowStatus($$$ERROR($$$GeneralError, "Multiple Containers cannot be transformed consecutively. This API only supports single patient context."))
	}
	
	if patientId '= "" {
		set ..%patientId = patientId
		set ..%resourceIds("Patient") = patientId
	}
	
	for {
		// gotObject = 1 means the call returned an SDA3 object.
		// gotObject = 0 means the call incurred an error, or
		//  the call got only the ending </Container> tag (no
		//  more SDA3 objects to return).
		set gotObject = source.GetNextSDA(.sdaType, .sdaObj, .tSC)
		
		// Throw (abort the entire transform of the Container) if an error was incurred.
		$$$ThrowOnError(tSC)
		
		// Simply quit the loop if we just ran out of SDA3 to parse.
		if 'gotObject quit
		
		do ..TransformHelper(sdaObj)
	}
	
	do ..ProcessProvenanceSetAsideQueue()

	return $this
}

/// Transforms an SDA object to FHIR. Returns an instance of this class
/// which contains a "bundle" property. That property will contain a FHIR Bundle with all the resources
/// generated during the transformation, and with all references resolved. 
/// @API.Method
/// @Argument	source			SDA object
/// @Argument	patientId		(optional) FHIR resource id to be assigned to the Patient resource
/// @Argument	encounterId		(optional) FHIR resource id to be assigned to the Encounter resource, if not transforming a Container
Method TransformSDA(source As HS.SDA3.SuperClass, patientId As %String = "", encounterId As %String = "") As HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR
{
	if patientId '= "" {
		set ..%patientId = patientId
		set ..%resourceIds("Patient") = patientId
	}
	if encounterId '= "" {
		set ..%resourceIds("Encounter") = encounterId
	}
	
	do ..TransformHelper(source)
	
	return $this
}

/// Transforms an SDA datatype to FHIR, which may or may not be a subclass of HS.SDA3.SuperClass. Because of this,
/// a target resource type must be provided. If no transformation from the SDA datatype to the given resource type,
/// no action will be taken. Returns an instance of this class
/// which contains a "bundle" property. That property will contain a FHIR Bundle with all the resources
/// generated during the transformation, and with all references resolved. 
/// @API.Method
/// @Argument	source			SDA object
/// @Argument	targetType		FHIR resource type to create from the provided input
/// @Argument	patientId		(optional) FHIR resource id to be assigned to the Patient resource
/// @Argument	encounterId		(optional) FHIR resource id to be assigned to the Encounter resource, if not transforming a Container
Method TransformDatatype(source As HS.SDA3.DataType, targetType As %String, patientId As %String = "", encounterId As %String = "") As HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR
{
	if patientId '= "" {
		set ..%patientId = patientId
		set ..%resourceIds("Patient") = patientId
	}
	if encounterId '= "" {
		set ..%resourceIds("Encounter") = encounterId
	}
	
	if ..schema.IsValidResourceType(targetType) {
		do ..TransformHelper(source, targetType)
	}
	else {
		$$$ThrowError($$$GeneralError, "Not implemented")
	}
	return $this
}

/// Resets this transformer object to its initial state.
/// @API.Method
Method Reset()
{
	set ..%bundle = ##class(%DynamicObject).%New()
	set ..%bundle.resourceType = "Bundle"
	set ..%bundle.type = "transaction"
	set ..%bundle.entry = ##class(%DynamicArray).%New()
	set ..%patientId = ""
	kill ..%resourceIds, ..%resourceIndex
}

/// Helper method for the transformation
Method TransformHelper(source As HS.SDA3.SuperClass, targetType As %String = "") [ Internal, Private ]
{
	set DTL = ..GetDTL(source,, targetType)
	quit:(DTL="")
	
	set aux("transformer") = $this
	set target = $classmethod($classmethod(DTL, "GetTargetType"), "%New")
	$$$ThrowOnError($classmethod(DTL, "Transform", source, .target, .aux))

	if (source.%ClassName(1) = "HS.SDA3.Vaccination") {
		$$$ThrowOnError(..CreateImmunizationsFromAdministrations(source, target, .aux))
		quit
	}
	
	if (source.%ClassName(1) = "HS.SDA3.RadOrder") {
		if (target.resourceType = "DiagnosticReport") {
			$$$ThrowOnError(..AppendAdditionalCategory(source,target,.aux,"LP29684-5","http://loinc.org","Radiology","Radiology","vR4"))
			quit
		}
	}

	if (source.%ClassName(1) = "HS.SDA3.OtherOrder") {
		if (target.resourceType = "DiagnosticReport") {
			$$$ThrowOnError(..AppendAdditionalCategory(source,target,.aux,"LP7839-6","http://loinc.org","Pathology","Pathology","vR4"))
			quit
		}
	}

	if (source.%ClassName(1) = "HS.SDA3.ObservationGroup") {
		$$$ThrowOnError(..ProcessObservationComponents(source, target, .aux))
		quit
	}
	
	if (source.%ClassName(1) = "HS.SDA3.Provenance") {
		$$$ThrowOnError(..ProcessProvenance(source, target, .aux))
		quit
	}
	
	set reference = ..AddResource(source, target)
	quit:reference=""
	
	if ((source.%ClassName(1) '= "HS.SDA3.Provenance") && $classmethod(source.%ClassName(1),"%Extends","HS.SDA3.SuperClass")) {
		$$$ThrowOnError(..ProcessProvenanceTargets(source, reference.reference))
	}

	if (source.%ClassName(1) = "HS.SDA3.Medication") &&
			((target.resourceType = "MedicationDispense") || (target.resourceType = "MedicationRequest")) {
		if target.resourceType = "MedicationRequest" {
			set aux("MedicationRequestReference") = reference
		}
		
		$$$ThrowOnError(##class(HS.FHIR.DTL.Util.SDA3.Handler.Medication).MedicationAdministration(source, .responses, .aux))
		for i=1:1:responses.Count() {
			do ..AddResource(source.Administrations.GetAt(i), responses.GetAt(i))
		}
	}
		
	if (source.%ClassName(1) = "HS.SDA3.QuestionnaireResponse") {
		$$$ThrowOnError(..ProcessQuestionnaireResponse(source, target, .aux))
		quit
	}
}

/// Utility method to append an additional category object to the target resource's category list.
/// One of <var>target</var> or <var>resourceJson</var> must be provided.
/// @Inputs
/// source			SDA object which created this resource
/// target			Object model version of the resource
/// aux				Auxiliary value
/// pCode			Value for category[n].coding[n].code
/// pSystem			Value for category[n].coding[n].system
/// pDisplay		Value for category[n].coding[n].display
/// pText			Value for category[n].text
/// pFhirVersion	Version of FHIR output to append a category
Method AppendAdditionalCategory(source As HS.SDA3.SuperClass, target As %RegisteredObject, ByRef aux, pCode As %String, pSystem As %String, pDisplay As %String, pText As %String, pFhirVersion As %String) As %Status
{
	set tSC = $$$OK
	try {
		set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
		if (configuredFhirVersion = pFhirVersion) {
			set category=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.CodeableConcept","%New")
			set category.coding = ""
			set category.text = pText
			set coding=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.Coding","%New")
			set coding.system=pSystem
			set coding.code=pCode
			set coding.display=pDisplay
			do category.coding.Insert(coding)
			do target.category.Insert(category)
		}
		do ..AddResource(source, target)
	}
	catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Creates Immunization resources based on Administrations within the inbound SDA3 Vaccination.
/// An Immunization resource will be created for each Administration in the SDA. 
/// If there are no Administrations, no Immunization resource will be created.
/// If any one of the resources fail validation, no resources will be created for this streamlet.
Method CreateImmunizationsFromAdministrations(source As HS.SDA3.Vaccination, target As %RegisteredObject, ByRef aux) As %Status
{
	set tSC = $$$OK
	try {
		set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
		if (source.Administrations.Count() > 0) {
			for i=1:1:source.Administrations.Count() {
				set administration = source.Administrations.GetAt(i)
				set DTL = aux("transformer").GetDTL(administration, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".Administration.Immunization")
				if (DTL = "") {
					$$$ThrowStatus($$$ERROR($$$GeneralError, "DTL for transforming HS.SDA3.Administration to FHIR Immunization not found"))
				}
				set currentTarget = target.%ConstructClone()
				$$$ThrowOnError($classmethod(DTL, "Transform", administration, .currentTarget, .aux))
				do ..AddResource(source, currentTarget)
			}
		} else {
			do ..AddResource(source, target)
		}
	}
	catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// If an observation in the Observation.component[x] array matches on observation code: Observation.component[x].code.code = Observation.code.code:
///     - Copy the valueQuantity property from the component array to the top-level: Observation.component[x].valueQuantity --> Observation.valueQuantity
///     - Remove the matching redundant component from the component array
Method ProcessObservationComponents(source As HS.SDA3.Vaccination, target As %RegisteredObject, ByRef aux) As %Status
{
	set tSC = $$$OK
	try {
		// get top-level observation code and coding system
		set codingSystem = ""
		set codingCode = ""
		if ($IsObject(target.code) && (target.code.coding.Count()>0)) {
			set codingSystem = target.code.coding.GetAt(1).system
			set codingCode = target.code.coding.GetAt(1).code
		}
		if $IsObject(target.component) {
			set key = ""
			for {
				set component = target.component.GetNext(.key)
				quit:key=""
				set coding = component.code.coding.GetAt(1)							
				if (coding.code = codingCode) && (coding.system = codingSystem) {
					// copy property valueQuantity from component to top-level
					if $IsObject(component.valueQuantity) {
						set target.valueQuantity = component.valueQuantity
					}
					// remove the component that matched the top-level observation code
					do target.component.RemoveAt(key)
				}
			}			
		}
		do ..AddResource(source, target)						
	}
	catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Helper method to process answers within items. Answers can contain multiple items
/// US Core requirements require valueString, valueDecimal, valueCoding and item to be filled out. 
Method HelperAnswerProcess(configuredFhirVersion As %String, source As %Library.DynamicObject) As HS.FHIR.DTL.vR4.Model.Element.QuestionnaireResponse.item.answer
{
	set tSC = $$$OK
	try {
		set targetAnswer=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.QuestionnaireResponse.item.answer","%New")
		set targetAnswer.id = source.id
		set targetAnswer.valueString = source.valueString
		set targetAnswer.valueDecimal = source.valueDecimal
		if source.valueCoding '= "" {
			set targetAnswer.valueCoding = ""
			set targetCoding=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.Coding","%New")
			set targetCoding.code = source.valueCoding.code
			set targetCoding.display = source.valueCoding.display
			set targetCoding.system = source.valueCoding.system
			set targetAnswer.valueCoding = targetCoding
		}
		if source.item '= "" {
			set iter= source.item.%GetIterator() 
			while iter.%GetNext(.key, .value) {
				set targetItemElement = ..HelperItemProcess(configuredFhirVersion, value)
				do targetAnswer.item.Insert(targetItemElement)							
			}
		}
		return targetAnswer
	}
	catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Helper method to process item fields. Items can contain multiple items, and answers
Method HelperItemProcess(configuredFhirVersion As %String, source As %Library.DynamicObject) As HS.FHIR.DTL.vR4.Model.Element.QuestionnaireResponse.item.answer
{
	set tSC = $$$OK
	try {
		set targetItem=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.QuestionnaireResponse.item","%New")
		set targetItem.linkId = source.linkId
		set targetItem.text = source.text
		set targetItem.id = source.id
		if source.answer'= "" {
			set iter= source.answer.%GetIterator() 
			while iter.%GetNext(.key, .value) {
				// Only populate answer field if valueString,valueDecimal, or valueCoding is populated or there is another item within answer as US CORE requirements
				if ((value.valueString '= "") || (value.valueDecimal '= "") || (value.valueCoding '= "") || (value.item '= "")) {
					set targetAnswer = ..HelperAnswerProcess(configuredFhirVersion, value)
					do targetItem.answer.Insert(targetAnswer)		
				}					
			}
		}
		// Use recursion to process items within items
		if source.item '= "" {
			set iter= source.item.%GetIterator() 
			while iter.%GetNext(.key, .value) {
				set targetItemElement = ..HelperItemProcess(configuredFhirVersion, value)
				do targetItem.item.Insert(targetItemElement)							
			}
		}
		return targetItem
	}
	catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

Method ProcessQuestionnaireResponse(source As HS.SDA3.QuestionnaireResponse, target As %RegisteredObject, ByRef aux) As %Status
{
	set tSC = $$$OK
	try {
		// get configuredFhirVersion
		set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
		
		// map Tags to tag(s)
		if (source.IsDefined("Tags") && (source.Tags.Count() > 0)) {
			set target.meta = ""
			set targetMeta=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Meta","%New")
			for i=1:1:source.Tags.Count() {
				set sourceTag = source.Tags.GetAt(i)
				set targetTag=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.Coding","%New")
				set targetTag.code = sourceTag.Code
				set targetTag.display = sourceTag.Description 
				set targetTag.system = sourceTag.SDACodingStandard 
				do targetMeta.tag.Insert(targetTag)	
			}
			set target.meta = targetMeta
		}
		
		//set QuestionnaireName and QuestionnaireUri to _questionnaire (extension property) elements only if QuestionnaireName field exists
		if ((source.QuestionnaireName'= "") && (source.QuestionnaireUri'= "")) {
			set target.extension = ""
			set questionnaireURIExtension=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension","%New")
			//Questionnaire URI Extension 
			set questionnaireURIExtension.url = "http://hl7.org/fhir/us/core/StructureDefinition/us-core-extension-questionnaire-uri"
			set questionnaireURIExtension.valueUri = source.QuestionnaireUri
			do target.extension.Insert(questionnaireURIExtension)
			set questionnaireDisplayExtension=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension","%New")
			//Questionnaire Display valueString Extension
			set questionnaireDisplayExtension.url = "http://hl7.org/fhir/StructureDefinition/display"
			set questionnaireDisplayExtension.valueString = source.QuestionnaireName
			do target.extension.Insert(questionnaireDisplayExtension)			
		}
		// if questionnaireName/Uri is null, map questionnaire from QuestionnaireUri
		else {
			set target.questionnaire = source.QuestionnaireUri
		} 
		
		//set Items to item
		if source.Items'= "" {
			set itemArray = {}.%FromJSON(source.Items)
			for i=0:1:itemArray.%Size()-1 {
				set item = itemArray.%Get(i)
				set targetItem=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.QuestionnaireResponse.item","%New")
				set targetItem.linkId = item.linkId
				set targetItem.text = item.text
				set targetItem.id = item.id
				// item can contain multiple items
				if item.item'="" {
					set iter= item.item.%GetIterator() 
					while iter.%GetNext(.key, .value) {
						set targetItemElement = ..HelperItemProcess(configuredFhirVersion, value)
						do targetItem.item.Insert(targetItemElement)							
					}
				}
				do target.item.Insert(targetItem)	
			}
		}
		do ..AddResource(source, target)						
	}
	catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Map SourceFormat to PDex extension, map Agents, initialize target array to be populated in TransformContainer
/// Store provenance resource in ..%provenance (set-aside queue), to be added to output bundle later when we are able
/// to reconstitute target array from ..%provenanceTarget in TransformContainer.
Method ProcessProvenance(source As HS.SDA3.Provenance, target As %RegisteredObject, ByRef aux) As %Status
{
	set tSC = $$$OK
	try {
		// get configuredFhirVersion
		set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)
		// create an empty target array.  it will be populated in TransformContainer as pos-processing
		set target.target=""
		// map SourceFormat to entity.extension
		if (source.IsDefined("SourceFormat") && (source.SourceFormat.Code '= "")) {
			set target.entity=""
			set provenanceEntity=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.Provenance.entity","%New")
			set provenanceEntity.role="source"
			set whatReference = $classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Reference","%New")
			set whatReference.display="source"
			if (configuredFhirVersion="vR4") {
				set provenanceEntity.what=whatReference
			} else {
				set provenanceEntity.whatReference=whatReference
			}
			set provenanceEntity.extension=""
			set provenanceEntityExtension=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Base.Extension","%New")
 			set provenanceEntityExtension.url="http://hl7.org/fhir/us/davinci-pdex/StructureDefinition/ProvenanceSourceFrom"
			set valueCodeableConcept=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.CodeableConcept","%New")
			set valueCodeableConcept.coding=""
			set coding=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.Coding","%New")
			set coding.system=source.SourceFormat.SDACodingStandard
			set coding.code=source.SourceFormat.Code
			set coding.display=source.SourceFormat.Description
			do valueCodeableConcept.coding.Insert(coding)
			set provenanceEntityExtension.valueCodeableConcept=valueCodeableConcept
			do provenanceEntity.extension.Insert(provenanceEntityExtension)
			do target.entity.Insert(provenanceEntity)
		}
		// map Agents to agent(s)		
		if (source.IsDefined("Agents") && (source.Agents.Count() > 0)) {
			set target.agent=""
			for i=1:1:source.Agents.Count() {
				#dim provenanceAgent as HS.SDA3.ProvenanceAgent
				set provenanceAgent = source.Agents.GetAt(i)
				set agent=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Element.Provenance.agent","%New")
				if ((configuredFhirVersion="vR4")&&($IsObject(provenanceAgent.Type))) {
					set type=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.CodeableConcept","%New")
					set type.coding=""
					set coding=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Datatype.Coding","%New")
					set coding.system=provenanceAgent.Type.SDACodingStandard
					set coding.code=provenanceAgent.Type.Code
					set coding.display=provenanceAgent.Type.Description
					do type.coding.Insert(coding)
					set agent.type=type
				}
				// transform HS.SDA3.ProvenanceAgent:CareProvider -> Practitioner reference
				if (($IsObject(provenanceAgent.CareProvider)) && (provenanceAgent.CareProvider.Code '= "")) {
					set DTL = aux("transformer").GetDTL(provenanceAgent.CareProvider, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".CodeTableDetail.CareProvider.Practitioner")
					if (DTL = "") {
						$$$ThrowStatus($$$ERROR($$$GeneralError, "DTL for transforming HS.SDA3.CodeTableDetail.CareProvider to FHIR Practitioner not found"))
					}
					set practitioner=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Resource.Practitioner","%New")
					$$$ThrowOnError($classmethod(DTL, "Transform", provenanceAgent.CareProvider, .practitioner, .aux))
					#dim practitioner as HS.FHIR.DTL.vR4.Model.Resource.Practitioner
					set practitionerJSON=practitioner.ToJSON()
					set practitionerReference=..AddResource(provenanceAgent.CareProvider, practitioner)
					if (configuredFhirVersion="vR4") {
						set agent.who=practitionerReference
					} else {
						set agent.whoReference=practitionerReference
					}
				}
				// transform HS.SDA3.ProvenanceAgent:Organization -> Organization reference 
				if (($IsObject(provenanceAgent.Organization)) && (provenanceAgent.Organization.Code '= "")) {
					set DTL = aux("transformer").GetDTL(provenanceAgent.Organization, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".CodeTableDetail.Organization.Organization")
					if (DTL = "") {
						$$$ThrowStatus($$$ERROR($$$GeneralError, "DTL for transforming HS.SDA3.CodeTableDetail.Organization to FHIR Organization not found"))
					}
					set organization=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Resource.Organization","%New")
					$$$ThrowOnError($classmethod(DTL, "Transform", provenanceAgent.Organization, .organization, .aux))
					#dim organization as HS.FHIR.DTL.vR4.Model.Resource.Organization
					set organizationJSON=organization.ToJSON()
					set organizationReference=..AddResource(provenanceAgent.Organization, organization)
					if (configuredFhirVersion="vR4") {
						set agent.who=organizationReference
					} else {
						set agent.whoReference=organizationReference
					}
				}
				// transform HS.SDA3.ProvenanceAgent:OnBehalfOfOrganization -> Organization reference 
				if (($IsObject(provenanceAgent.OnBehalfOfOrganization)) && (provenanceAgent.OnBehalfOfOrganization.Code '= "")) {
					set DTL = aux("transformer").GetDTL(provenanceAgent.OnBehalfOfOrganization, "HS.FHIR.DTL.SDA3." _ configuredFhirVersion _ ".CodeTableDetail.Organization.Organization")
					if (DTL = "") {
						$$$ThrowStatus($$$ERROR($$$GeneralError, "DTL for transforming HS.SDA3.CodeTableDetail.Organization to FHIR Organization not found"))
					}
					set organization=$classmethod("HS.FHIR.DTL." _ configuredFhirVersion _ ".Model.Resource.Organization","%New")
					$$$ThrowOnError($classmethod(DTL, "Transform", provenanceAgent.OnBehalfOfOrganization, .organization, .aux))
					set organizationReference=..AddResource(provenanceAgent.OnBehalfOfOrganization, organization)
					if (configuredFhirVersion="vR4") {
						set agent.onBehalfOf=organizationReference
					} else {
						set agent.onBehalfOfReference=organizationReference
					}
				}
				do target.agent.Insert(agent)
			}
		}
		// stash provenance resource into set-aside queue.  still needs target(s) to be valid
		// it is considered an invalid data condition for a Provenance streamlet to have ExternalId = "", FHIR-to-SDA3 transformation
		// assigns a GUID to each ingested provenance resource.  It is possible to create invalid provenance streamlets using SDAIn 
		if source.ExternalId '= "" {
			set provenanceGUID = source.ExternalId
		}
		else {
			set provenanceGUID = $system.Util.CreateGUID()
		}
		set ..%provenance(provenanceGUID)=target
		set ..%provenance(provenanceGUID,"Source")=source
	}
	catch ex {
		set tSC = ex.AsStatus()
	}
		
	quit tSC
}

/// All streamlets that are target(s) of Provenance contain their provenance references in property ProvenanceIds
/// Iterate these GUIDs and set ..%provenanceTargets(GUID,reference)
Method ProcessProvenanceTargets(source As HS.SDA3.SuperClass, reference As %String) As %Status
{
	set tSC = $$$OK
	try {
		if (source.ProvenanceIds.Count() > 0) {
			for i=1:1:source.ProvenanceIds.Count() {
				set provenanceGUID=source.ProvenanceIds.GetAt(i)
				set ..%provenanceTarget(provenanceGUID,reference)=""
			}
		}
	}
	catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// Process provenance streamlets in the set-aside queue: ..%provenance, and populate "target" using references from ..%provenanceTarget 
Method ProcessProvenanceSetAsideQueue()
{
	// Process provenance streamlets in the set-aside queue: ..%provenance, and populate "target" using references from ..%provenanceTarget 
	set guid=""
	for {
		set guid=$order(..%provenance(guid))
		quit:guid=""
		set provenanceResource=..%provenance(guid)
		set provenanceSource=..%provenance(guid,"Source")
		
		set reference=""
		for {
			set reference=$order(..%provenanceTarget(guid,reference))
			quit:reference=""
			set targetReference = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Base.Reference", "%New")
			set targetReference.reference=reference
			do provenanceResource.target.Insert(targetReference)
		}
		set provenanceReference = ..AddResource(provenanceSource,provenanceResource)
	}
}

/// Specifies the DTL class to use for a given SDA object. A preferred DTL will be specified in 
/// subtransformations, but will not be specified for top level transformations. Default logic
/// for top level transformations can be viewed in the FHIR annotations, under the Container
/// mappings. This can be overriden if different logic is desired.
/// @API.Overrideable
Method GetDTL(source As HS.SDA3.DataType, DTL As %Dictionary.Classname = "", targetType As %String = "") As %Dictionary.Classname
{
	set useCustom = (##class(HS.FHIR.DTL.Util.API.ExecDefinition).GetCustomDTLPackage() '= "")
	if DTL '= "" {
		return $select(useCustom: ##class(HS.FHIR.DTL.Util.API.ExecDefinition).GetDTLPackageAndClass(DTL),
						1:DTL)
	}
	set aux("transformer") = $this
	set SDAClass = source.%ClassName(1)
	for {
		set DTL = $order(^HS.XF.Transform("SDA3", ..%fhirVersion, SDAClass, DTL))
		quit:DTL=""
		
		if targetType '= "" {
			if $find(DTL, targetType, $length(DTL) - $length(targetType)) = ($length(DTL) + 1) { //Check targetType is the last thing in DTL
				return $select(useCustom: ##class(HS.FHIR.DTL.Util.API.ExecDefinition).GetDTLPackageAndClass(DTL),
							1:DTL)
			}	
		}
		else {
			set condition = ^HS.XF.Transform("SDA3", ..%fhirVersion, SDAClass, DTL)
			if (condition '= "") && $xecute("(source, aux) return (" _ condition _ ")", source, .aux) {
				return $select(useCustom: ##class(HS.FHIR.DTL.Util.API.ExecDefinition).GetDTLPackageAndClass(DTL),
								1:DTL)
			}
		}
	}
	return ""
}

/// Overrideable method which indicates whether a resource is a duplicate. This method
/// shall return a reference to the original resource if the one provided is a duplicate.
/// Otherwise, it shall return an empty string. The id that will be assigned to the resource
/// if it's not a duplicate is also provided. Default implementation is to deduplicate shared
/// resources if the json representations of them are identical.
/// @API.Overrideable
Method IsDuplicate(resource As %DynamicObject, id As %String) As HS.FHIR.DTL.vR4.Model.Base.Reference [ Private ]
{
	if ..%schema.IsSharedResourceType(resource.resourceType) {
		do $system.Encryption.SHA1HashResult()
		//Hash will be computed on first 32KB of resource stream
		do $system.Encryption.SHA1HashInput(resource.%ToJSON())
		set hash = $system.Encryption.Base64Encode($system.Encryption.SHA1HashResult())
		
		if $data(..%resourceIndex("hash", hash)) {
			return ..CreateReference(resource.resourceType, ..%resourceIndex("hash", hash))
		}
		
		set ..%resourceIndex("hash", hash) = id
	}
	return ""
}

/// Returns a resource given a try and id. Default implementation is to only search
/// the resources created and in the Bundle, but other implementations may want to also search
/// in a repository
/// @API.Overrideable
Method ResourceLookup(resourceType As %String, id As %String) As %DynamicObject [ Private ]
{
	if $data(..%resourceIndex(resourceType, id)) {
		return ..%resourceIndex(resourceType, id)
	}
	else {
		return ""
	}
}

/// Ensures the resource is valid FHIR, adds the resource to the output Bundle,
/// and returns a reference to that resource. Will also output the resource as a
/// %DynamicObject.
/// @Inputs
/// source			SDA object which created this resource
/// resource		Object model version of the resource
/// resourceJson	%DynamicObject version of the resource
/// One of <var>resource</var> or <var>resourceJson</var> must be provided. If both are provided,
/// the %DynamicObject representation will be given precedence 
Method AddResource(source As HS.SDA3.SuperClass, resource As %RegisteredObject = "", ByRef resourceJson As %DynamicObject = "") As HS.FHIR.DTL.vR4.Model.Base.Reference [ Internal ]
{
	if '$isobject(resourceJson) {
		set resourceJson = ##class(%DynamicObject).%FromJSON(resource.ToJSON())
	}
	
	try {
		do ..%resourceValidator.ValidateResource(resourceJson)
	} catch ex {
		do ..HandleInvalidResource(resourceJson, ex)
		return ""
	}
	
	set entry = ##class(%DynamicObject).%New()
	set entry.request = ##class(%DynamicObject).%New()
	
	set id = ..GetId(source, resourceJson)
	if id '= "" {
		set resourceJson.id = id
	}
	
	//Check for an SDA identifier->id mapping to maintain references
	//Note: Provenance assigns a GUID to ExternalId for internal use, it is not an external id and shouldn't influence id assignment 
	set sourceIdentifier = ""
	if resourceJson.resourceType = "Encounter" {
		set sourceIdentifier = source.EncounterNumber
	}
	elseif ((source.%Extends("HS.SDA3.SuperClass")) && (resourceJson.resourceType '= "Provenance")) {
		set sourceIdentifier = source.ExternalId
	}
	
	if id = "" {
		if (resourceJson.resourceType = "Patient") && (..%patientId '= "") {
			set id = ..%patientId
		}
		elseif $get(..%resourceIds(resourceJson.resourceType)) '= "" {
			set id = ..%resourceIds(resourceJson.resourceType)
		}
		elseif (sourceIdentifier '= "") && $data(..%resourceIds(resourceJson.resourceType, sourceIdentifier)) {
			set id = ..%resourceIds(resourceJson.resourceType, sourceIdentifier)
		}
		
		if id '= "" {
			set resource.id = id
			set resourceJson.id = id
		}
	}
	
	if resourceJson.id '= "" {
		set id = resourceJson.id
		set entry.fullUrl = $select(..GetBaseURL()'="":..GetBaseURL() _ "/", 1:"") _ resourceJson.resourceType _ "/" _ resourceJson.id
		set entry.request.method = "PUT"
		set entry.request.url = resourceJson.resourceType _ "/" _ resourceJson.id
	}
	else {
		set id = $zconvert($system.Util.CreateGUID(), "L")
		set entry.fullUrl = "urn:uuid:" _ id
		set entry.request.method = "POST"
		set entry.request.url = resourceJson.resourceType
	}
	
	//Save id mappings for later access
	if resourceJson.resourceType = "Patient" {
		set ..%patientId = id
	}
	elseif sourceIdentifier '= "" {
		set ..%resourceIds(resourceJson.resourceType, sourceIdentifier) = id
	}
	
	set duplicate = ..IsDuplicate(resourceJson, id)
	if duplicate '= "" {
		return duplicate
	}
	
	//Index for O(1) lookup if needed for post-processing
	set ..%resourceIndex(resourceJson.resourceType, id) = resourceJson
	
	set entry.resource = resourceJson
	do ..%bundle.entry.%Push(entry)
	
	return ..CreateReference(resourceJson.resourceType, id)
}

/// Returns a reference to the resource generated from the provided source identifier. Predominant
/// use case is to return a reference to the Encounter resource given an EncounterNumber
/// @API.Overrideable
Method GetReference(resourceType As %String, sourceIdentifier As %String) As %String
{
	if $get(..%resourceIds(resourceType)) '= "" {
		return ..CreateReference(resourceType, ..%resourceIds(resourceType))
	}
	
	if sourceIdentifier = "" {
		return ""
	}
	if '$data(..%resourceIds(resourceType, sourceIdentifier)) {
		set ..%resourceIds(resourceType, sourceIdentifier) = $zconvert($system.Util.CreateGUID(), "L")
	}
	
	return ..CreateReference(resourceType, ..%resourceIds(resourceType, sourceIdentifier))
}

/// Returns a reference to the Patient resource. Will generate an id if one isn't passed in
/// @API.Overrideable
Method GetPatientReference() As %String
{
	if ..%patientId = "" {
		set ..%patientId = $zconvert($system.Util.CreateGUID(), "L")
	}
	
	return ..CreateReference("Patient", ..%patientId)
}

/// Overrideable method that allows custom designation of a resource id. SDA source
/// and the generated resource are provided.
/// @API.Overrideable
Method GetId(source As HS.SDA3.SuperClass, resource As %DynamicObject) As %String
{
	return ""
}

/// Overrideable method that allows custom designation of a server base URL.
/// @API.Overrideable
Method GetBaseURL() [ Private ]
{
	return ""
}

/// Overrideable method that allows custom handling of an invalid resource. The default behavior
/// is to throw an exception and exit transformation.
/// @API.Overrideable
Method HandleInvalidResource(resource As %DynamicObject, exception As %Exception.AbstractException) [ Private ]
{
	if resource.resourceType = "Provenance" {
		return
	}
	throw exception
}

/// Helper method to generate a reference element
Method CreateReference(resourceType As %String, id As %String) [ Internal ]
{
	set reference = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Base.Reference", "%New")
	if ##class(HS.HC.Util).IsUUID(id) {
		set reference.reference = "urn:uuid:" _ id
	}
	else {
		set reference.reference = resourceType _ "/" _ id
	}
	
	return reference
}

/// Getter method for immutable property
Method bundleGet() [ Internal ]
{
	//They didn't provide an Patient id, but a reference was created
	if '$data(..%resourceIds("Patient")) && (..%patientId '= "") {
		if '$data(..%resourceIndex("Patient", ..%patientId)) {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "Patient resource id was not specified and no Patient resource was transformed"))
		}
	}
	//They didn't provide an Encounter id, but a reference was created
	if $data(..%resourceIds("Encounter")) = 10 {
		//Check for the referenced resource
		set encounterNumber = ""
		for {
			set encounterNumber = $order(..%resourceIds("Encounter", encounterNumber))
			quit:encounterNumber=""
			
			set encounterId = ..%resourceIds("Encounter", encounterNumber)
			if '$data(..%resourceIndex("Encounter", encounterId)) {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "Encounter resource id was not specified and Encounter with EncounterNumber " _ encounterNumber _ " was not transformed"))
			}
		}
	}
	
	return ..%bundle
}

/// Getter method for immutable property
Method fhirVersionGet() [ CodeMode = expression, Internal ]
{
..%fhirVersion
}

/// Getter method for immutable property
Method schemaGet() [ CodeMode = expression, Internal ]
{
..%schema
}

/// Override %OnNew to configure the transformer
/// @Inputs
/// schema				Instance of HS.FHIRServer.Schema/HS.FHIRMeta.API for the target version of FHIR
Method %OnNew(schema As HS.FHIRServer.Schema) As %Status [ Private, ServerOnly = 1 ]
{
	set ..%schema = schema
	set ..%resourceValidator = ##class(HS.FHIRServer.Util.ResourceValidator).%New(..schema)
	set ..%fhirVersion = ..GetXFSchemaFromMetadataSet(schema.FHIRMetadataSetKey)
	
	do ..Reset()
	
	quit $$$OK
}

/// Returns the transformation schema for a given metadata set
/// @API.Method
ClassMethod GetXFSchemaFromMetadataSet(metadataKey As %String) As %String
{
	//Get the base FHIR metadata set to determine the transformations to use
	// NOTE: This should take the schema (metaAPI) object ... but we can easily create another for now
	#dim metaAPI as HS.FHIRMeta.API = ##class(HS.FHIRMeta.API).getInstance(metadataKey)
	Set fhirVersion = +$E(metaAPI.FHIRVersion)
	set schema = $case(fhirVersion,  3:"vSTU3", 4:"vR4", :"")
	if schema = "" {
		$$$ThrowStatus($$$ERROR($$$GeneralError, "Transformations not defined for metadata set " _ metadataKey))
	}
	
	return schema
}

/// Returns a $List of FHIR resource names that are fed by SDA3 streamlets via SDA3 to FHIR transformations.
/// <p>
/// Indicate the schema name parameter with a string that starts with "v" and ends with the FHIR
/// major version number indicator. Examples of valid values are: "vSTU3", "vR4", etc.
/// @API.Method
ClassMethod GetTargetResourceList(schemaName As %String, Output resourceList) As %Status
{
	set tSC = $$$OK
	set resourceList = ""
	try {
		if schemaName="" {
			$$$ThrowStatus($$$ERROR($$$GeneralError, "schemaName not specified"))
		}
		
		set source = "" for { set source = $order(^HS.XF.Transform("SDA3", schemaName, source), 1) quit:(source = "")
			set target = "" for { set target = $order(^HS.XF.Transform("SDA3", schemaName, source, target), 1) quit:(target = "")
				set fhirList($piece(target, ".", *)) = ""
			}
		}
		set keyList = "" for { set keyList = $order(fhirList(keyList), 1) quit:(keyList = "")
			if $extract(keyList)'?1L {
				set resourceList = resourceList _ $listbuild(keyList)
			}
		}
	} 
	catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

}
