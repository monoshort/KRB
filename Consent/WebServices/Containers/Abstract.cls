/// Used in the web services for Add / Edit / Load / List Consent records
Class HS.Consent.WebServices.Containers.Abstract Extends HS.Consent.WebServices.ServiceStatus
{

/// Policy ID
Property ID As %String;

/// CIT ID
Property ClinicalInformationType As %String;

Property Decision As %String(DISPLAYLIST = ",Default Block,Default Block Except,Always Block,Always Block Except,Default Show,Default Show Except,Always Show,Always Show Except", VALUELIST = ",0,0Except,0Always,0AlwaysExcept,1,1Except,1Always,1AlwaysExcept");

/// Used during Load method 
Property DecisionString As %String(MAXLEN = 250);

/// Encounter Date
Property EventEffective As %String;

/// Encounter Date
Property EventExpiration As %String;

/// Request Date
Property EffectiveDate As %String;

/// Request Date
Property ExpirationDate As %String;

/// either block or show exceptions
Property GroupList As list Of %String;

Property AppliesTo As %String(DISPLAYLIST = ",Group,Relationship", VALUELIST = ",G,R");

/// List of HS.Push.Relationship IDs
Property RelationshipList As list Of %String(STORAGEDEFAULT = "array");

/// also block encounter if this policy matched
Property BlockEncounter As %Boolean;

}
