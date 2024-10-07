Include HS.FHIRServer

Class HS.FHIR.DTL.Util.API.Transform.FHIRToSDA3 Extends %RegisteredObject
{

/// All SDA objects this transformer instance creates will be stored
/// here, unless Reset() is called.
Property container As HS.SDA3.Container [ Calculated ];

Property %container As HS.SDA3.Container [ Private ];

/// The most recent SDA object this transformer instance created will
/// be stored here, unless Reset() is called.
Property object As HS.SDA3.SuperClass [ Calculated ];

Property %object As HS.SDA3.SuperClass [ Private ];

Property fhirVersion As %String [ Calculated ];

Property %fhirVersion As %String [ Private ];

Property %schema As %String [ Private ];

/// Map of <resourceId -> resource json> 
/// For TransformBundle, all resources in the bundle are in the Map
/// For TransformResource, just the input resource is in the Map
Property %resourceMap [ MultiDimensional, Private ];

/// Contains the output of HS.FHIRServer.Util.ReferenceVisitor
Property %referenceContext [ MultiDimensional, Private ];

/// The reference to the current resource being transformed. Used to
/// help generate the identifier for a streamlet, even if the resource
/// doesn't have an id.
Property %currentReference As %String [ Private ];

/// Original top-level reference from data provider to the current resource
Property %topLevelReference As %String [ Private ];

/// Stores a GUID for each Provenance resource in the bundle
/// Ex: set ..%provenance(resourceId)=<GUID>
Property %provenance [ MultiDimensional, Private ];

/// Stores the target resources that are referenced by Provenance resources and links them by the Provenance GUID
/// Ex: set ..%provenanceTarget(resourceId,GUID)=""
Property %provenanceTarget [ MultiDimensional, Private ];

/// ClassMethod which transforms a FHIR resource stream into SDA. The FHIR resource can be either a Bundle or a Patient
/// specific resource, but references will only be able to be honored when transforming a Bundle. Returns an instance
/// of this class which has an "object" property containing the result of the Transform.<br/>
/// @API.Method
/// @Argument	stream			%Stream representation of a FHIR resource
/// @Argument	fhirVersion		Version of FHIR used by the resource, eg. "STU3", "R4"
ClassMethod TransformStream(stream As %Stream.Object, fhirVersion As %String, fhirFormat As %String) As HS.FHIR.DTL.Util.API.Transform.FHIRToSDA3
{
	set schema = ##class(HS.FHIRServer.Schema).LoadSchema(fhirVersion)
	if fhirFormat = $$$FHIRContentCodeJSON {
		set dynObj = {}.%FromJSON(stream)
	} elseif fhirFormat = $$$FHIRContentCodeXML {
		set dynObj = ##class(HS.FHIRServer.Util.XMLToJSON).XMLToJSON(stream, schema)
	}
	return ..%New(schema).Transform(dynObj)
}

/// ClassMethod which transforms a FHIR resource into SDA. The FHIR resource can be either a Bundle or a Patient
/// specific resource, but references will only be able to be honored when transforming a Bundle. Returns an instance
/// of this class which has an "object" property containing the result of the Transform.<br/>
/// @API.Method
/// @Argument	source			%DynamicObject containing a FHIR resource
/// @Argument	fhirVersion		Version of FHIR used by the resource, eg. "STU3", "R4"
ClassMethod TransformObject(source As %DynamicObject, fhirVersion As %String) As HS.FHIR.DTL.Util.API.Transform.FHIRToSDA3
{
	return ..%New(##class(HS.FHIRServer.Schema).LoadSchema(fhirVersion)).Transform(source)
}

/// Transforms a FHIR resource into SDA. The FHIR resource can be either a Bundle or a Patient specific resource,
/// but references will only be able to be honored when transforming a Bundle. Returns an instance of this class
/// which has an "object" property containing the result of the most recent Transform and a "container" property 
/// containing the result of all Transforms using this transformer.<br/>
/// @API.Method
/// @Argument	source		%DynamicObject containing a FHIR resource
Method Transform(source As %DynamicObject) As HS.FHIR.DTL.Util.API.Transform.FHIRToSDA3
{
	if source.resourceType = "Bundle" {
		return ..TransformBundle(source)
	}
	else {
		return ..TransformResource(source)
	}
}

/// Resets this transformer object to its initial state.
/// @API.Method
Method Reset()
{
	set ..%container = ##class(HS.SDA3.Container).%New()
	set ..%object = $$$NULLOREF, ..%currentReference = $$$NULLOREF
	kill ..%referenceContext, ..%resourceMap
	
	set ..%referenceContext("schema") = ..%schema
}

Method TransformBundle(source As %DynamicObject) As HS.FHIR.DTL.Util.API.Transform.FHIRToSDA3 [ Internal, Private ]
{
	//First build the map of resources so we know which should be skipped, because they're
	//referred to from other resources
	merge referenceContext = ..%referenceContext
	set entryIter = source.entry.%GetIterator()
	while entryIter.%GetNext(, .entry) {
		if (entry.fullUrl '= "") && (entry.fullUrl [ "urn:uuid:") {
			set ..%resourceMap(entry.fullUrl) = entry.resource
			if entry.resource.resourceType = "Patient" {
				set ..%resourceMap("Patient", entry.fullUrl) = entry.resource
			}
		}
		if (entry.resource.id '= "") {
			set ..%resourceMap(entry.resource.resourceType, entry.resource.id) = entry.resource
		}

		if (entry.resource.resourceType = "Provenance") {
			do ..MapProvenanceToTargets(.entry)
		}
		
		do ##class(HS.FHIRServer.Util.ReferenceVisitor).VisitAll(entry.resource, .referenceContext)
	}
	merge ..%referenceContext = referenceContext
	
	set entryIter = source.entry.%GetIterator()
	while entryIter.%GetNext(, .entry) {
		set ..%currentReference = ""
		if (entry.fullUrl '= "") && (entry.fullUrl [ "urn:uuid:") {
			set ..%currentReference = entry.fullUrl
		}
		elseif (entry.resource.id '= "") {
			set ..%currentReference = entry.resource.resourceType _ "/" _ entry.resource.id
		}
		
		do ..TransformHelper(entry.resource)
	}
	
	set ..%object = ..%container
	
	return $this
}

Method MapProvenanceToTargets(entry As %DynamicObject) [ Internal, Private ]
{
	set resourceReference = ""
	if (entry.fullUrl '= "") && (entry.fullUrl [ "urn:uuid:") {
		set resourceReference = entry.fullUrl
	}
	else {
		set resourceReference = entry.resource.resourceType _ "/" _ entry.resource.id
	}

	// Assign a GUID to each provenance resource
	set provenanceGUID=$system.Util.CreateGUID()
	set ..%provenance(resourceReference)=provenanceGUID
	
	// Iterate over targets and link using the provenance resource's GUID
	set targetIter=entry.resource.target.%GetIterator()
	while targetIter.%GetNext(, .target) {
		if ((target.reference = "") || ($extract(target.reference,1)="#") ) {
			continue	
		}

		if (target.reference [ "urn:uuid:") {
			set targetReference = target.reference
		}
		else {
			set targetReference = $piece(target.reference,"/",*-1) _ "/" _ $piece(target.reference,"/",*)
		}
			
		set ..%provenanceTarget(targetReference,provenanceGUID)=""
	}
}

Method TransformResource(source As %DynamicObject) As HS.FHIR.DTL.Util.API.Transform.FHIRToSDA3 [ Internal, Private ]
{
	set ..%currentReference = ""
	if (source.id '= "") {
		set ..%resourceMap(source.resourceType, source.id) = source
		set ..%currentReference = source.resourceType _ "/" _ source.id
	}
	
	set ..%object = ..TransformHelper(source)
	
	return $this
}

Method TransformHelper(source As %DynamicObject) As HS.SDA3.DataType [ Internal, Private ]
{
	set ..%topLevelReference=..%currentReference
	
	//If a resource is referenced from somewhere else, we need to handle it differently so we don't cause it
	//to be duplicated. Patient and Encounter are excluded because they are independent of any referencing resources
	set referencedFrom = ..ReferencedFrom()
	
	// Provenance, observation(sdoh & survey), and questionnaireResponse references should not cause us to skip the incoming resource.
	set referenceList=""
	set ptr=0
	set skipObservationRsrc = 1
	while $listnext(referencedFrom,ptr,value) {
		if '(value [ "Provenance") {
			set $list(referenceList,*+1)=value
		}
		// For the case of observation-referencing-observation, do not skip resource when target resourceType is SocialDeterminant or Survey.
		// The purpose is to make sure observation resources are still translated while being referenced in hasMember or derivedFrom properties.
		if ((value [ "Observation") && (source.resourceType = "Observation")){
			set dtlSource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource." _ source.resourceType, "FromJSONHelper", source, ..%fhirVersion)
			set DTL = ..GetDTL(dtlSource)
			if DTL = "" return ""
			set target = $classmethod($classmethod(DTL, "GetTargetType"), "%New")
			if (target.%ClassName() = "SocialDeterminant") || (target.%ClassName() = "Survey"){
				set skipObservationRsrc = 0
				quit
			}
		}
		if ((value [ "Observation") && (source.resourceType = "QuestionnaireResponse")){
			set skipObservationRsrc = 0
			quit
		}
	}

	if '((referenceList = "") || (source.resourceType = "Patient") || (source.resourceType = "Encounter") ||
                                                    (((source.resourceType = "Goal") || (source.resourceType = "Condition")) && (referenceList [ "CarePlan")) || 'skipObservationRsrc) {
                    return ""
    }

	set dtlSource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource." _ source.resourceType, "FromJSONHelper", source, ..%fhirVersion)
	set DTL = ..GetDTL(dtlSource)
	if DTL = "" return ""
	
	set aux("transformer") = $this
	set target = $classmethod($classmethod(DTL, "GetTargetType"), "%New")
	$$$ThrowOnError($classmethod(DTL, "Transform", dtlSource, .target, .aux))

	// Provenance post-transform processing.    SDA3 is a containment model (not referential), so we invert the references,
	// storing them with the referenced streamlet.
	if target.%ClassName() = "Provenance" {
		set target.ExternalId=..%provenance(..%topLevelReference)
		do ..MapProvenanceAgents(.source,.target)
		// PDex defines an extension. Use it to populate HS.SDA3.Provenance:SourceFormat
		do ..MapProvSourceFromExtension(.source,.target)
	}
	
	// For all resources: $order through ..%provenanceTarget and for each reference add the Provenance GUID to its ProvenanceIds list property.
	set provenanceGUID=""
    for {
	    set provenanceGUID=$order(..%provenanceTarget(..%topLevelReference,provenanceGUID))
	    quit:provenanceGUID=""
	    
	    do target.ProvenanceIds.Insert(provenanceGUID)
	}
	
	if target.%ClassName() = "Patient" {
		if ..%container.IsDefined("Patient") $$$ThrowStatus($$$ERROR($$$GeneralError, "Cannot transform more than one Patient into a single Container"))
		set ..%container.Patient = target
	} else {
		// For DiagnosticOrder --> LabOrder, each DiagnosticOrder.result produces one LabOrder.Results.LabResultItem
		// For panel results, where DiagnosticOrder.result.hasMember is defined, the LabResultItem is for the panel and contains no value,
		// we need to replace each panel LabResultItem with one-to-many actaul lab results by iterating Observation references 
		// in DiagnosticOrder.result.[n].hasMember
		if target.%ClassName() = "LabOrder" {
			$$$ThrowOnError(..ReplacePanelWithHasMemberResults(.source,.target))
		}
		set containerPropName = $zstrip(target.StartXMLList(), "<>", "<>")
		do $method($property(..%container, containerPropName), "Insert", target)
	}
	
	if target.%ClassName() = "SocialHistory" {
		do ..MapSocialHistoryEnteredAt(.source,.target)
		do ..MapSocialHistoryEnteredBy(.source,.target)
	}

	if (target.%ClassName() = "Referral") && (..%fhirVersion = "vR4") {
		do ..MapReferralFromPerformer(.source,.target)
	}
	
	if target.%ClassName() = "QuestionnaireResponse" {
		do ..MapQuestionnaireResponse(.source,.target)
	}

	// Extract a unique source identifier to be SocialDeterminant or Survey's ExternalId.
	// ExternalId is used to keep references from observation.hasMember and observation.derivedFrom.
	if (source.resourceType = "Observation") && ((target.%ClassName() = "SocialDeterminant") || (target.%ClassName() = "Survey")) {
		if source.fullUrl [ "urn:uuid" {
			set identifiers = source.identifier
			set uniqueID = ""
			if $IsObject(identifiers) {
				set uniqueID = ..GetIdentifierFromList(identifiers)
			}
			else {
				set uniqueID = ""
			}
		}
		else {
			set uniqueID = ..GetIdentifier(source.resourceType, source.id)
		}
		if uniqueID '= "" {
			set target.ExternalId = uniqueID
		}
	}
	
	return target
}

/// Map the first Organization resource to Referral:ReferredToOrganization and 
/// the first Practitioner resource to Referral:ReferredToOrganization from ServiceRequest:performer list 
Method MapReferralFromPerformer(source As %DynamicObject, target As HS.SDA3.Referral) [ Internal, Private ]
{
	#dim findOrganization As %Boolean = 0
	#dim findPractitioner As %Boolean = 0
	set aux("transformer") = $this
	set performerArr=source.%Get("performer")
	if '$IsObject(performerArr) {
		quit
	}
	set performerIter=performerArr.%GetIterator()
	while performerIter.%GetNext(, .performer) {
		set performerResource = ..GetResourceFromReference(performer)
		if $IsObject(performerResource){
			if (performerResource.resourceType = "Organization") && ('findOrganization) {
				set dtlResource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource.Organization", "FromJSONHelper", performerResource, ..%fhirVersion)
				set DTL="HS.FHIR.DTL." _ ..%fhirVersion _ ".SDA3.Organization.CodeTableDetail.HealthCareFacility"
				set dtlOut=##class(HS.SDA3.CodeTableDetail.HealthCareFacility).%New()
				$$$ThrowOnError($classmethod(DTL,"Transform",dtlResource,.dtlOut,.aux))
				set target.ReferredToOrganization=dtlOut
				set findOrganization = 1
			} elseif (performerResource.resourceType = "Practitioner") && ('findPractitioner) {
				set dtlResource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource.Practitioner", "FromJSONHelper", performerResource, ..%fhirVersion)
				set DTL="HS.FHIR.DTL." _ ..%fhirVersion _ ".SDA3.Practitioner.CodeTableDetail"
				set dtlOut=##class(HS.SDA3.CodeTableDetail.CareProvider).%New()
				$$$ThrowOnError($classmethod(DTL,"Transform",dtlResource,.dtlOut,.aux))
				set target.ReferredToProvider=dtlOut
				set findPractitioner = 1
			}
			Quit:(findOrganization && findPractitioner)
		}	
	}
}

/// Map the first Organization resource from Observation:performer list to SocialHistory:EnteredAt
Method MapSocialHistoryEnteredAt(source As %DynamicObject, target As HS.SDA3.SocialHistory) [ Internal, Private ]
{
	set aux("transformer") = $this
	set performerArr=source.%Get("performer")
	if '$IsObject(performerArr) {
		quit
	}
	set performerIter=performerArr.%GetIterator()
	while performerIter.%GetNext(, .performer) {
		set performerResource = ..GetResourceFromReference(performer)
		if $IsObject(performerResource){
			if performerResource.resourceType="Organization" {
				set dtlResource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource.Organization", "FromJSONHelper", performerResource, ..%fhirVersion)
				set DTL="HS.FHIR.DTL." _ ..%fhirVersion _ ".SDA3.Organization.CodeTableDetail.Organization"
				set dtlOut=##class(HS.SDA3.CodeTableDetail.Organization).%New()
				$$$ThrowOnError($classmethod(DTL,"Transform",dtlResource,.dtlOut,.aux))
				set target.EnteredAt=dtlOut
			}
			Quit:target.EnteredAt.Code'=""
		}	
	}
}

/// Map the first Practitioner resource from Observation:performer list to SocialHistory:EnteredBy
Method MapSocialHistoryEnteredBy(source As %DynamicObject, target As HS.SDA3.SocialHistory) [ Internal, Private ]
{
	set aux("transformer") = $this
	set performerArr=source.%Get("performer")
	if '$IsObject(performerArr) {
		quit
	}
	set performerIter=performerArr.%GetIterator()
	while performerIter.%GetNext(, .performer) {
		set performerResource = ..GetResourceFromReference(performer)
		if $IsObject(performerResource){
			if performerResource.resourceType = "Practitioner" {
				set dtlResource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource.Practitioner", "FromJSONHelper", performerResource, ..%fhirVersion)
				set DTL="HS.FHIR.DTL." _ ..%fhirVersion _ ".SDA3.Practitioner.CodeTableDetail"
				set dtlOut=##class(HS.SDA3.CodeTableDetail.User).%New()
				$$$ThrowOnError($classmethod(DTL,"Transform",dtlResource,.dtlOut,.aux))
				set target.EnteredBy=dtlOut
			}
			Quit:target.EnteredBy.Code'=""
		}	
	}
}

Method MapProvenanceAgents(source As %DynamicObject, target As HS.SDA3.Provenance) [ Internal, Private ]
{
	set aux("transformer") = $this
	if ..%fhirVersion = "vSTU3" {
		set whoElementName = "whoReference"
		set onBehalfOfElementName = "onBehalfOfReference"
		set includeType = 0
	}
	else {
		set whoElementName = "who"
		set onBehalfOfElementName = "onBehalfOf"
		set includeType = 1
	}	
	// Copy all provenance agents from FHIR to SDA3
	set agentIter=source.agent.%GetIterator()
	while agentIter.%GetNext(, .agent) {
		set provAgent=##class(HS.SDA3.ProvenanceAgent).%New()
		// using %Get("type"), populate HS.SDA3.ProvenanceAgent:Type 
		if includeType {
			set agentType=agent.%Get("type")
			if $IsObject(agentType) {
				set coding=agentType.%Get("coding")
				if $IsObject(coding) {
					set codingIter=coding.%GetIterator()
					while codingIter.%GetNext(, .typeCode) {
						set provAgentType=##class(HS.SDA3.CodeTableDetail.ProvenanceAgentType).%New()
						set provAgentType.SDACodingStandard=typeCode.%Get("system")
						set provAgentType.Code=typeCode.%Get("code")
						set provAgentType.Description=typeCode.%Get("display")
						set provAgent.Type=provAgentType
						quit // cardinality mismatch FHIR CodeableConcept supports 1..* coding(s); SDA3 uses only the first coding
					}
				}
			}
		}
		// using %Get("who"), populate HS.SDA3.ProvenanceAgent:CareProvider or HS.SDA3.ProvenanceAgent:Organization
		set whoReference=agent.%Get(whoElementName)
		if $IsObject(whoReference) {
			set whoResource=..GetResourceFromReference(whoReference)
			if $IsObject(whoResource) {
				// for provenance agents we only map "who" to CareProvider from a Practitioner reference and to Organization from an Organization reference
				if whoResource.resourceType = "Organization" {
					set dtlResource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource.Organization", "FromJSONHelper", whoResource, ..%fhirVersion)
					set DTL="HS.FHIR.DTL." _ ..%fhirVersion _ ".SDA3.Organization.CodeTableDetail.Organization"
					set dtlOut=##class(HS.SDA3.CodeTableDetail.Organization).%New()
					$$$ThrowOnError($classmethod(DTL,"Transform",dtlResource,.dtlOut,.aux))
					set provAgent.Organization=dtlOut
				}
				if whoResource.resourceType = "Practitioner" {
					set dtlResource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource.Practitioner", "FromJSONHelper", whoResource, ..%fhirVersion)
					set DTL="HS.FHIR.DTL." _ ..%fhirVersion _ ".SDA3.Practitioner.CodeTableDetail.CareProvider"
					set dtlOut=##class(HS.SDA3.CodeTableDetail.CareProvider).%New()
					$$$ThrowOnError($classmethod(DTL,"Transform",dtlResource,.dtlOut,.aux))
					set provAgent.CareProvider=dtlOut
				}
			}
		}
		// using %Get("onBehalfOf"), populate HS.SDA3.ProvenanceAgent:OnBehalfOfOrganization
		set onBehalfOfReference=agent.%Get(onBehalfOfElementName)
		if $IsObject(onBehalfOfReference) {
			set onBehalfOfResource=..GetResourceFromReference(onBehalfOfReference)
			if $IsObject(onBehalfOfResource) {
				set dtlResource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource.Organization", "FromJSONHelper", onBehalfOfResource, ..%fhirVersion)
				set DTL="HS.FHIR.DTL." _ ..%fhirVersion _ ".SDA3.Organization.CodeTableDetail.Organization"
				set dtlOut=##class(HS.SDA3.CodeTableDetail.Organization).%New()
				$$$ThrowOnError($classmethod(DTL,"Transform",dtlResource,.dtlOut,.aux))
				set provAgent.OnBehalfOfOrganization=dtlOut
			}
		}
		do target.Agents.Insert(provAgent)
	}
}

// Map QuestionnaireResponse extension property and tag arrays in meta 

Method MapQuestionnaireResponse(source As %DynamicObject, target As HS.SDA3.QuestionnaireResponse) [ Internal, Private ]
{

	// Get iterator for QuestionnaireName and QuestionnaireUri from questionnaire.extension 
	set questionnaireExtArr=source.%Get("_questionnaire")
	if (questionnaireExtArr '= "") && $IsObject(questionnaireExtArr) {
		set questionnaireArr = questionnaireExtArr.%Get("extension")
		if (questionnaireArr '= "") && $IsObject(questionnaireArr) {
			set questionnaireArrIter=questionnaireArr.%GetIterator()
			while questionnaireArrIter.%GetNext(, .questionnaire) {
				// check with the static url value if the extension refers to Display or questionnaire extension uri value
				if (questionnaire.%Get("url") = "http://hl7.org/fhir/StructureDefinition/display") {
					set target.QuestionnaireName=questionnaire.%Get("valueString")
				}
				if (questionnaire.%Get("url") = "http://hl7.org/fhir/us/core/StructureDefinition/us-core-extension-questionnaire-uri") {
					set target.QuestionnaireUri=questionnaire.%Get("valueUri")
				}
			}
		}
	}

	// if questionnaire is defined, then map QuestionnaireUri from questionnaire canonical
	set questionnaire = source.%Get("questionnaire")
	if (questionnaire '= "") {
		set target.QuestionnaireUri=questionnaire
	}

	// Get iterator to map Tags from Meta.tag
	set meta = source.%Get("meta")
	if (meta '= "") && $IsObject(meta) {
		set tagArr = meta.%Get("tag")
		if (tagArr '= "") && $IsObject(tagArr) {
			set tagArrIter=tagArr.%GetIterator()
			while tagArrIter.%GetNext(, .tagItem) {
				set tag=##class(HS.SDA3.CodeTableDetail.Tag).%New()
				set tag.Code=tagItem.%Get("code")
				//if code is "sdoh", set SDACodingStandard and Description to default SDOH value
				If (tag.Code = "sdoh") {
					set tag.SDACodingStandard="http://hl7.org/fhir/us/core/CodeSystem/us-core-tags"
					set tag.Description="SDOH"
				}
				Else {
					set tag.SDACodingStandard=tagItem.%Get("system")
					set tag.Description=tagItem.%Get("display")
				}
				do target.Tags.Insert(tag)
			}
		}
	}

	// Convert item to JSON String and map to Items
	set item = source.%Get("item")
	if (item '= "") && $IsObject(item) {
		set target.Items = item.%ToJSON()
	}
}

Method MapProvSourceFromExtension(source As %DynamicObject, target As HS.SDA3.Provenance) [ Internal, Private ]
{
	// Get iterator for PDex SourceFrom entity.extension 
	set entityArr=source.%Get("entity")
	if '$IsObject(entityArr) {
		quit
	}
	set entityArrIter=entityArr.%GetIterator()
	while entityArrIter.%GetNext(, .entity) {
		set extensionArr=entity.%Get("extension")
		set extensionArrIter=extensionArr.%GetIterator()
		while extensionArrIter.%GetNext(, .extension) {
			set url=extension.%Get("url")
			if url="http://hl7.org/fhir/us/davinci-pdex/StructureDefinition/ProvenanceSourceFrom" {
				set sourceFormat=extension.%Get("valueCodeableConcept")
				if $IsObject(sourceFormat) {
					set coding=sourceFormat.%Get("coding")
					if $IsObject(coding) {
						set codingIter=coding.%GetIterator()
						while codingIter.%GetNext(, .sourceFormatCode) {
							set sourceFormat=##class(HS.SDA3.CodeTableDetail.SourceFormat).%New()
							set sourceFormat.SDACodingStandard=sourceFormatCode.%Get("system")
							set sourceFormat.Code=sourceFormatCode.%Get("code")
							set sourceFormat.Description=sourceFormatCode.%Get("display")
							set target.SourceFormat=sourceFormat
							quit // cardinality mismatch FHIR CodeableConcept supports 1..* coding(s); SDA3 uses only the first coding
						}
					}
				}
			}					
		}

	}
}

Method ReplacePanelWithHasMemberResults(source As %DynamicObject, target As HS.SDA3.LabOrder) As %Status [ Internal, Private ]
{
	set tSC = $$$OK
	
	try {
		set aux("transformer") = $this

		// get configuredFhirVersion
		set configuredFhirVersion = ##class(HS.FHIR.DTL.Util.Package).GetConfiguredSchemaName(aux("transformer").fhirVersion)

		if (configuredFhirVersion = "vSTU3") {
			quit
		}

		// Iterate over all DiagnosticReport.result
		// If hasMember is defined, replace panel with actual results from hasMember
		set result=source.%Get("result")
		quit:'$IsObject(result)
		set resultIter=result.%GetIterator()
		while resultIter.%GetNext(, .resultReference) {
			set observationResource = ..GetResourceFromReference(resultReference)
			if (($IsObject(observationResource)) && (observationResource.%Get("hasMember")'="")) {
				set dtlSource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource.Observation", "FromJSONHelper", observationResource, configuredFhirVersion)
				set DTL = aux("transformer").GetDTL(dtlSource,"HS.FHIR.DTL." _ configuredFhirVersion _ ".SDA3.Observation.LabOrder")
				if (DTL = "") {
					$$$ThrowStatus($$$ERROR($$$GeneralError, "DTL for transforming FHIR Observation to HS.SDA3.LabOrder notfound"))
				}
				set labOrder = ##class(HS.SDA3.LabOrder).%New()
				$$$ThrowOnError($classmethod(DTL, "Transform", dtlSource, .labOrder, .aux))

				if target.PlacerId '= "" {
					set labOrder.PlacerId = target.PlacerId
					set labOrder.ParentPlacerId = target.PlacerId
				}
				if target.FillerId '= "" {
					set labOrder.FillerId = target.FillerId
					set labOrder.ParentFillerId = target.FillerId
				}

				set hasMemberIter=observationResource.hasMember.%GetIterator()
				while hasMemberIter.%GetNext(, .hasMemberReference) {
					set hasMemberResource=..GetResourceFromReference(hasMemberReference)
					set dtlSource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource.Observation", "FromJSONHelper", hasMemberResource, configuredFhirVersion)
					// Get DTL
					// Call TransformReference for each Observation in hasMember returning a result item
					// Add it to labOrder.Result.ResultItems
					set DTL = aux("transformer").GetDTL(dtlSource,"HS.FHIR.DTL." _ configuredFhirVersion _ ".SDA3.Observation.LabResultItem")
					if (DTL = "") {
						$$$ThrowStatus($$$ERROR($$$GeneralError, "DTL for transforming FHIR Observation to HS.SDA3.LabResultItem notfound"))
					}
					set labResultItem = ##class(HS.SDA3.LabResultItem).%New()
					$$$ThrowOnError($classmethod(DTL, "Transform", dtlSource, .labResultItem, .aux))
					do labOrder.Result.ResultItems.Insert(labResultItem)
				}

				do $method(..%container.LabOrders, "Insert", labOrder)
			}
		}
	}
	catch ex {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

/// This method is a CALLBACK from the DTL requesting another DTL for  DTL class to use for a given FHIR object. 
/// A preferred DTL will be specified in subtransformations, but will not be specified for top level transformations.
/// Default logic for top level transformations can be viewed in the FHIR annotations, under the Bundle:entry
/// mappings. This can be overriden if different logic is desired.
/// @API.Overrideable
Method GetDTL(source As HS.FHIR.DTL.vR4.Model.Base.Resource, DTL As %Dictionary.Classname = "") As %Dictionary.Classname
{
	set useCustom = (##class(HS.FHIR.DTL.Util.API.ExecDefinition).GetCustomDTLPackage() '= "")
	if DTL '= "" {
		return $select(useCustom: ##class(HS.FHIR.DTL.Util.API.ExecDefinition).GetDTLPackageAndClass(DTL),
						1:DTL)
	}
	
	set aux("transformer") = $this
	for {
		set DTL = $order(^HS.XF.Transform(..%fhirVersion, "SDA3", source.resourceType, DTL))
		quit:DTL=""
		
		set condition = ^HS.XF.Transform(..%fhirVersion, "SDA3", source.resourceType, DTL)
		if (condition '= "") && $xecute("(source, aux) return (" _ condition _ ")", source, .aux) {
			return $select(useCustom: ##class(HS.FHIR.DTL.Util.API.ExecDefinition).GetDTLPackageAndClass(DTL),
							1:DTL)
		}
		
	}
	return ""
}

/// Returns the resource object given a FHIR reference. This can be overriden if resources need to
/// be transformed one at a time (ie. not as a complete Bundle), but still want fully populated SDA.
/// @API.Overrideable
Method GetResourceFromReference(reference As HS.FHIR.DTL.vR4.Model.Base.Reference) As %DynamicObject [ Private ]
{
	if (reference = "") || (reference.reference = "") {
		return ""
	}
	
	//Search in the current resource if it's a reference to a contained resource
	if reference.reference?1"#".AN {
		set parentReference = {
			"reference": (..%currentReference)
		}
		set currentResource = ..GetResourceFromReference(parentReference)
		if (currentResource = "") || '$isobject(currentResource.contained) {
			return ""
		}
		for i=0:1:currentResource.contained.%Size()-1 {
			set containedResource = currentResource.contained.%Get(i)
			if containedResource.id = $piece(reference.reference, "#", *) {
				return containedResource
			}
		}
		return ""
	}
	else {
		if reference.reference [ "urn:uuid:" {
			return $get(..%resourceMap(reference.reference), "")
		}
		else {
			return $get(..%resourceMap($piece(reference.reference, "/", *-1), $piece(reference.reference, "/", *)), "")
		}
	}
}

/// Helper method to verify if a FHIR Reference is a certain resource type.
Method isResourceType(reference As HS.FHIR.DTL.vR4.Model.Base.Reference, resourceType As %String) As %Boolean [ Internal ]
{
	set resource = ..GetResourceFromReference(reference)
	if (resource.resourceType = resourceType) {
		return 1
	}
	return 0
}

/// This method is a CALLBACK from the DTL.  Its purpose is to transform from a FHIR Reference to appropriate SDA.
/// Since SDA does not support generalized references, most transforms resolve the reference and transform the referenced
/// FHIR Object into an embedded object (provided in the 'target' input argument) in the output SDA.  If 'target' is not
/// an object, then the transform is to the string value of the referenced Resource's Identifier.
Method TransformReference(reference As HS.FHIR.DTL.vR4.Model.Base.Reference, ByRef target As HS.SDA3.DataType, ByRef aux) As HS.SDA3.DataType [ Internal ]
{
	set resource = ..GetResourceFromReference(reference)
	if resource = "" {
		return ..HandleMissingResource(reference)
	}
	
	set previousReference = ..%currentReference
	set ..%currentReference = reference.reference
	
	//Target not being an object means it's mapped to a string, the SDA equivalent of a reference
	if $get(target) = "" {
		if reference.reference [ "urn:uuid" {
			set identifiers = $get(..%resourceMap(reference.reference)).identifier
			if $IsObject(identifiers) {
				return ..GetIdentifierFromList(identifiers)
			}
			else {
				return ""
			}
		}
		else {
			return ..GetIdentifier($piece(reference.reference, "/", *-1), $piece(reference.reference, "/", *))
		}
	}
	
	//Get preferred DTL based on source and target types
	set DTLTarget = $replace(target.%ClassName(1), "HS.SDA3.", "")
	if DTLTarget = "CodeTableDetail.User" {
		set DTLTarget = "CodeTableDetail"
	}

	set DTL = ""
	for {
		set DTL = $order(^HS.XF.Transform(..%fhirVersion, "SDA3", resource.resourceType, DTL))
		quit:((DTL = "") || (DTL [ (resource.resourceType _ "." _ DTLTarget)))
	}
	if DTL = "" {
		set ..%currentReference = previousReference
		return ""
	}
	
	set DTL = ..GetDTL(resource, DTL)
	if DTL = "" {
		set ..%currentReference = previousReference
		return target
	}
	
	set dtlResource = $classmethod("HS.FHIR.DTL." _ ..%fhirVersion _ ".Model.Resource." _ resource.resourceType, "FromJSONHelper", resource, ..%fhirVersion)
	$$$ThrowOnError($classmethod(DTL, "Transform", dtlResource, .target, .aux))
	
	set ..%currentReference = previousReference
	return target
}

/// Returns a list of places the current resource is referenced from.
Method ReferencedFrom() As %List [ Internal ]
{
	merge referenceContext = ..%referenceContext
	return ##class(HS.FHIRServer.Util.ReferenceVisitor).GetReferencingIds(..%currentReference, .referenceContext)
}

/// Specifies the Container's SendingFacility property. Default behavior is to get it from the Patient
/// managingOrganization or the first MRN in their list of identifier. Will default to "FHIR" if neither
/// exist.
/// @API.Overrideable
Method GetSendingFacility() As %String [ Private ]
{
	set default = "FHIR"
	
	set patientId = $order(..%resourceMap("Patient", ""))
	if patientId = "" {
		return default
	}
	set patient = ..%resourceMap("Patient", patientId)
	
	set facility = ""
	if patient.managingOrganization '= "" {
		set facility = ..GetResourceFromReference(patient.managingOrganization)
	}
	if '$isobject(facility) && $isobject(patient.identifier) {
		for i=0:1:patient.identifier.%Size()-1 {
			if $isobject(patient.identifier.%Get(i).type) && $isobject(patient.identifier.%Get(i).type.coding) && (patient.identifier.%Get(i).type.coding.%Get(0).code = "MR") {
				set facility = ..GetResourceFromReference(patient.identifier.%Get(i).assigner)
				if $isobject(facility) quit
			}
		}
	}
	
	if '$isobject(facility) {
		return default
	}
	
	for i=0:1:facility.identifier.%Size()-1 {
		if facility.identifier.%Get(i).value '= "" {
			return facility.identifier.%Get(i).value
		}
	}
	if facility.name '= "" {
		return facility.name
	}
	
	return default
}

/// This method is a CALLBACK from the DTL.  Its purpose is to extract a unique, source-defined, identifier
/// from a FHIR Resource (as defined by a resource type and id.
/// There may be multiple identifiers for a resource.  (e.g. a patient may have an MRN, an MPIID, a Drivers Licence, etc).
/// In SDA, there is no equivalent of a FHIR resource id.  Where one SDA object refers to another, it typically refers to the
/// 'ExternalId' property of the other resource (except for Encounters where the unique id is stored in 'EncounterNumber'.
/// In order to differentiate among multiple FHIR Identifier entries ('identifier' is an array property), two optional arguments may
/// be provided to this method:
/// <ul><li>code, if specified will define the 'value' (and optionally 'system') associated with the desired identifier.  This may be a
/// a simple value string (e.g. "ThisEncounterId"), or be preceded by the system URL and a '|' 
/// (e.g. "https://www.cloverhealth.com/encounteridentifiers|ThisEncounterId")
/// <ul><li>use, if specified, is a preference ordered comma separated list of 'use' values that are acceptable.
/// </ul>
/// @API.Overrideable
Method GetIdentifier(resourceType As %String, id As %String, sourceProperty As %String = "value") As %String
{
	set result = ""
	set identifiers = ..%resourceMap(resourceType, id).identifier
	if $IsObject(identifiers) {
		if (identifiers.%IsA("%DynamicObject")){
			set result = identifiers.value
		} else {
			set result = ..GetIdentifierFromList(identifiers,,sourceProperty)
		}
	}
	return result
}

Method GetIdentifierFromList(identifiers As %DynamicArray, use As %String = "official,usual,secondary", sourceProperty As %String = "value") As %String
{
	set result = ""
	set useArray = $lfs(use)		
	set best = 999
	set iter = identifiers.%GetIterator()
	while iter.%GetNext(.key, .identifier) {
		if (key = 0) {
			// Default to the first value in the list
			set result = identifier.value
		}
		set level = $listfind(useArray, identifier.use)
		continue:level=0
	
		if (level<best) {
			set best = level
			set result = $property(identifier,sourceProperty)
		}
	}
	return result
}

/// Allows overrides to behavior when a referenced resource doesn't exist. User may choose
/// to throw an exception, log a warning, or proceed silently.
/// @API.Overrideable
Method HandleMissingResource(reference As HS.FHIR.DTL.vR4.Model.Base.Reference) [ Private ]
{
	return ""
}

/// Getter method for immutable property
Method containerGet() [ Internal ]
{
	//Ensure that the Container has at least a Patient object
	if '..%container.IsDefined("Patient") {
		$$$ThrowStatus($$$ERROR($$$GeneralError, "Container is not valid because no Patient object has been created yet"))
	}
	set ..%container.SendingFacility = ..GetSendingFacility()
	
	return ..%container
}

/// Getter method for immutable property
Method objectGet() [ CodeMode = expression, Internal ]
{
..%object
}

/// Getter method for immutable property
Method fhirVersionGet() [ CodeMode = expression, Internal ]
{
..%fhirVersion
}

Method %OnNew(schema As HS.FHIRServer.Schema) As %Status [ Private, ServerOnly = 1 ]
{
	set ..%schema = schema
	set ..%fhirVersion = ##class(HS.FHIR.DTL.Util.API.Transform.SDA3ToFHIR).GetXFSchemaFromMetadataSet(schema.FHIRMetadataSetKey)
	
	do ..Reset()
	
	quit $$$OK
}

}
