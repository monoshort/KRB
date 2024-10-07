/// used in the web service for adding clinical information types
Class HS.Consent.WebServices.Containers.ListPolicyLineItem Extends HS.Consent.WebServices.Containers.ListItem
{

Property Decision As %String;

Property DecisionString As %String(MAXLEN = 250);

Property EffectiveDate As %String;

Property ExpirationDate As %String;

Property EventEffective As %String;

Property EventExpiration As %String;

Property MRN As %String;

Property MRNAssigningAuthority As %String;

Property MRNInActive As %String;

Property Type As %String;

Property Facility As %String;

Property GroupList As list Of %String(STORAGEDEFAULT = "array");

Property AllowBreakTheGlass As %Boolean;

Property ClinicalInformationType As %Integer;

Property ModificationTime As %TimeStamp;

Property AppliesTo As %String;

/// List of HS.Push.Relationship IDs
Property RelationshipList As list Of %String(STORAGEDEFAULT = "array");

Property BlockEncounter As %Boolean;

}
