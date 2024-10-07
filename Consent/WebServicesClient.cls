Class HS.Consent.WebServicesClient Extends %SOAP.WebClient
{

/// This is the URL used to access the web service.
Parameter LOCATION;

/// This is the namespace used by the Service
Parameter NAMESPACE = "http://www.intersystems.com/hs/hub/consent";

/// Use xsi:type attribute for literal types.
Parameter OUTPUTTYPEATTRIBUTE = 1;

/// This is the name of the Service
Parameter SERVICENAME = "HS.Hub.Consent.WebServices";

Method AddEditMPIFacilityPolicy(pPolicy As HS.Consent.WebServices.Containers.MPIFacility = "") As HS.Consent.WebServices.Containers.MPIFacility [ WebMethod ]
{
	Quit ..WebMethod("AddEditMPIFacilityPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.AddEditMPIFacilityPolicy",pPolicy)
}

Method AddEditFacilityPolicy(pPolicy As HS.Consent.WebServices.Containers.Facility = "") As HS.Consent.WebServices.Containers.Facility [ WebMethod ]
{
	Quit ..WebMethod("AddEditFacilityPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.AddEditFacilityPolicy",pPolicy)
}

/// retrieve the current active MPI facility policy
Method LoadCurrentMPIFacilityPolicy(pFacility As %String = "") As HS.Consent.WebServices.Containers.MPIFacility [ WebMethod ]
{
	Quit ..WebMethod("LoadCurrentMPIFacilityPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadCurrentMPIFacilityPolicy",pFacility)
}

/// Given a MPIFacilityPolicy ID return the Policy
Method LoadMPIFacilityPolicy(pID As %String = "") As HS.Consent.WebServices.Containers.MPIFacility [ WebMethod ]
{
	Quit ..WebMethod("LoadMPIFacilityPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadMPIFacilityPolicy",pID)
}

Method LoadFacilityPolicy(pID As %String = "") As HS.Consent.WebServices.Containers.Facility [ WebMethod ]
{
	Quit ..WebMethod("LoadFacilityPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadFacilityPolicy",pID)
}

Method DeleteFacilityPolicy(pPolicy As HS.Consent.WebServices.Containers.Facility = "") As HS.Consent.WebServices.Containers.Facility [ WebMethod ]
{
	Quit ..WebMethod("DeleteFacilityPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.DeleteFacilityPolicy",pPolicy)
}

Method DeleteMPIFacilityPolicy(pPolicy As HS.Consent.WebServices.Containers.MPIFacility = "") As HS.Consent.WebServices.Containers.MPIFacility [ WebMethod ]
{
	Quit ..WebMethod("DeleteMPIFacilityPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.DeleteMPIFacilityPolicy",pPolicy)
}

Method AddEditMPISNOPolicy(pPolicy As HS.Consent.WebServices.Containers.MPISNO) As HS.Consent.WebServices.Containers.MPISNO [ WebMethod ]
{
	Quit ..WebMethod("AddEditMPISNOPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.AddEditMPISNOPolicy",pPolicy)
}

/// Update the SNO decisions with ClinicalInformationTypes using effective / expiration dates
Method AddEditSNOPolicy(pPolicy As HS.Consent.WebServices.Containers.SNO = "") As HS.Consent.WebServices.Containers.SNO [ WebMethod ]
{
	Quit ..WebMethod("AddEditSNOPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.AddEditSNOPolicy",pPolicy)
}

/// retrieve the current active MPI SNO policy
Method LoadCurrentMPISNOPolicy() As HS.Consent.WebServices.Containers.MPISNO [ WebMethod ]
{
	Quit ..WebMethod("LoadCurrentMPISNOPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadCurrentMPISNOPolicy")
}

Method LoadMPISNOPolicy(pID As %String = "") As HS.Consent.WebServices.Containers.MPISNO [ WebMethod ]
{
	Quit ..WebMethod("LoadMPISNOPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadMPISNOPolicy",pID)
}

/// Load the SNO ClinicalInformationTypes decisions including effective / expiration dates
Method LoadSNOPolicy(pID As %String = "") As HS.Consent.WebServices.Containers.SNO [ WebMethod ]
{
	Quit ..WebMethod("LoadSNOPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadSNOPolicy",pID)
}

/// Delete a system wide consent policy
Method DeleteSNOPolicy(pPolicy As HS.Consent.WebServices.Containers.SNO = "") As HS.Consent.WebServices.Containers.SNO [ WebMethod ]
{
	Quit ..WebMethod("DeleteSNOPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.DeleteSNOPolicy",pPolicy)
}

/// Delete a system wide consent policy
Method DeleteMPISNOPolicy(pPolicy As HS.Consent.WebServices.Containers.MPISNO = "") As HS.Consent.WebServices.Containers.MPISNO [ WebMethod ]
{
	Quit ..WebMethod("DeleteMPISNOPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.DeleteMPISNOPolicy",pPolicy)
}

Method AddEditMPIPatientPolicy(pPolicy As HS.Consent.WebServices.Containers.MPIPatient = "") As HS.Consent.WebServices.Containers.MPIPatient [ WebMethod ]
{
	Quit ..WebMethod("AddEditMPIPatientPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.AddEditMPIPatientPolicy",pPolicy)
}

Method AddEditPatientPolicy(pPolicy As HS.Consent.WebServices.Containers.Patient = "") As HS.Consent.WebServices.Containers.Patient [ WebMethod ]
{
	Quit ..WebMethod("AddEditPatientPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.AddEditPatientPolicy",pPolicy)
}

Method LoadMPIPatientPolicy(pID As %String = "") As HS.Consent.WebServices.Containers.MPIPatient [ WebMethod ]
{
	Quit ..WebMethod("LoadMPIPatientPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadMPIPatientPolicy",pID)
}

Method LoadPatientPolicy(pID As %String = "") As HS.Consent.WebServices.Containers.Patient [ WebMethod ]
{
	Quit ..WebMethod("LoadPatientPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadPatientPolicy",pID)
}

/// Delete the consent policy defined for a MPI patient
Method DeleteMPIPatientPolicy(pPolicy As HS.Consent.WebServices.Containers.MPIPatient = "") As HS.Consent.WebServices.Containers.MPIPatient [ WebMethod ]
{
	Quit ..WebMethod("DeleteMPIPatientPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.DeleteMPIPatientPolicy",pPolicy)
}

/// Delete the consent policy defined for a patient
Method DeletePatientPolicy(pPolicy As HS.Consent.WebServices.Containers.Facility = "") As HS.Consent.WebServices.Containers.Patient [ WebMethod ]
{
	Quit ..WebMethod("DeletePatientPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.DeletePatientPolicy",pPolicy)
}

Method AddEditCITRule(pRule As HS.Consent.WebServices.Containers.CITRule = "") As HS.Consent.WebServices.Containers.CITRule [ WebMethod ]
{
	Quit ..WebMethod("AddEditCITRule").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.AddEditCITRule",pRule)
}

Method LoadCITRule(pID = "") As HS.Consent.WebServices.Containers.CITRule [ WebMethod ]
{
	Quit ..WebMethod("LoadCITRule").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadCITRule",pID)
}

Method DeleteCITRule(pID As %String = "") As HS.Consent.WebServices.Containers.CITRule [ WebMethod ]
{
	Quit ..WebMethod("DeleteCITRule").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.DeleteCITRule",pID)
}

///  Update ClinicalInformationType 
/// 	Using a container object because the CIT contains a set of rules
Method AddEditCIT(pCIT As HS.Consent.WebServices.Containers.ClinicalInformationType = "") As HS.Consent.WebServices.Containers.ClinicalInformationType [ WebMethod ]
{
	Quit ..WebMethod("AddEditCIT").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.AddEditCIT",pCIT)
}

Method LoadCIT(pID As %String = "") As HS.Consent.WebServices.Containers.ClinicalInformationType [ WebMethod ]
{
	Quit ..WebMethod("LoadCIT").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadCIT",pID)
}

Method DeleteCIT(pID As %String = "") As HS.Consent.WebServices.Containers.ClinicalInformationType [ WebMethod ]
{
	Quit ..WebMethod("DeleteCIT").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.DeleteCIT",pID)
}

Method ListRules(pFacility As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListRules").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListRules",pFacility)
}

Method ListClinicalInformationTypes(pFacility As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListClinicalInformationTypes").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListClinicalInformationTypes",pFacility)
}

Method ListCITRuleVersions() As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListCITRuleVersions").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListCITRuleVersions")
}

Method ListFacilities(pIncludeDecision As %Boolean = 0, pRoles As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListFacilities").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListFacilities",pIncludeDecision,pRoles)
}

Method ListCategories() As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListCategories").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListCategories")
}

Method ListSubCategories(pCategory As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListSubCategories").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListSubCategories",pCategory)
}

Method ListPatientCIRules() As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListPatientCIRules").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListPatientCIRules")
}

Method ListAllGroups() As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListAllGroups").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListAllGroups")
}

Method ListSNOPolicyLineItems() As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListSNOPolicyLineItems").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListSNOPolicyLineItems")
}

Method ListMPISNOPolicyLineItems() As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListMPISNOPolicyLineItems").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListMPISNOPolicyLineItems")
}

Method ListFacilityPolicyLineItems(pFacility As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListFacilityPolicyLineItems").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListFacilityPolicyLineItems",pFacility)
}

Method ListMPIFacilityPolicyLineItems(pFacility As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListMPIFacilityPolicyLineItems").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListMPIFacilityPolicyLineItems",pFacility)
}

Method ListPatientPolicyLineItems(pMPI As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListPatientPolicyLineItems").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListPatientPolicyLineItems",pMPI)
}

Method ListMPIPatientPolicyLineItems(pMPI As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListMPIPatientPolicyLineItems").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListMPIPatientPolicyLineItems",pMPI)
}

/// List the patient, facility, and system clinical-information consent-policy line items for a patient and optional facility
Method ListSummaryPolicyLineItems(pMPI As %String = "", pFacility As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListMPISummaryPolicyLineItems").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListSummaryPolicyLineItems",pMPI,pFacility)
}

/// List the patient, facility, and system MPI consent-policy line items for a patient and optional facility
Method ListMPISummaryPolicyLineItems(pMPI As %String = "", pFacility As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListSummaryPolicyLineItems").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListMPISummaryPolicyLineItems",pMPI,pFacility)
}

Method ImportXMLPolicy(pPolicy As HS.Consent.WebServices.Containers.XMLPolicy) As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ImportXMLPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ImportXMLPolicy",pPolicy)
}

Method ExportXMLPolicy(pMPI As %String = "") As HS.Consent.WebServices.Containers.XMLPolicy [ WebMethod ]
{
	Quit ..WebMethod("ExportXMLPolicy").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ExportXMLPolicy",pMPI)
}

Method ImportXACML(pPolicy As HS.Consent.WebServices.Containers.XMLPolicy) As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ImportXACML").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ImportXACML",pPolicy)
}

Method ExportXACML(pMPI As %String = "") As HS.Consent.WebServices.Containers.XMLPolicy [ WebMethod ]
{
	Quit ..WebMethod("ExportXACML").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ExportXACML",pMPI)
}

Method FetchMRNsForPatient(pMPIID As %String) As HS.Consent.WebServices.Containers.Patients [ WebMethod ]
{
	Quit ..WebMethod("FetchMRNsForPatient").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.FetchMRNsForPatient",pMPIID)
}

Method AddEditCITQualifier(pQualifier As HS.Consent.WebServices.Containers.CITQualifier = "") As HS.Consent.WebServices.Containers.CITQualifier [ WebMethod ]
{
	Quit ..WebMethod("AddEditCITQualifier").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.AddEditCITQualifier",pQualifier)
}

Method LoadCITQualifier(pID = "") As HS.Consent.WebServices.Containers.CITQualifier [ WebMethod ]
{
	Quit ..WebMethod("LoadCITQualifier").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.LoadCITQualifier",pID)
}

Method DeleteCITQualifier(pID As %String = "") As HS.Consent.WebServices.Containers.CITQualifier [ WebMethod ]
{
	Quit ..WebMethod("DeleteCITQualifier").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.DeleteCITQualifier",pID)
}

Method ListCITQualifiers(pStreamletType As %String = "") As HS.Consent.WebServices.Containers.ListItems [ WebMethod ]
{
	Quit ..WebMethod("ListCITQualifiers").Invoke(##this,"http://www.intersystems.com/hs/hub/consent/HS.Consent.WebServices.ListCITQualifiers",pStreamletType)
}

}
