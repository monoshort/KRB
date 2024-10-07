/// Used in the web services for Add / Edit / Load / List Consent records for system wide MPI
Class HS.Consent.WebServices.Containers.MPISNO Extends HS.Consent.WebServices.ServiceStatus
{

/// Policy ID
Property ID As %String;

Property AllowBreakTheGlass As %Boolean [ InitialExpression = 0 ];

Property Decision As %String(DISPLAYLIST = ",Default Block,Default Block Except,Always Block,Always Block Except,Default Show,Default Show Except,Always Show,Always Show Except", VALUELIST = ",0,0Except,0Always,0AlwaysExcept,1,1Except,1Always,1AlwaysExcept");

/// Used during Load method 
Property DecisionString As %String(MAXLEN = 250);

/// either block or show exceptions
Property GroupList As list Of %String;

/// Request Date
Property EffectiveDate As %String;

/// Request Date
Property ExpirationDate As %String;

Property AppliesTo As %String(DISPLAYLIST = ",Group,Relationship", VALUELIST = ",G,R");

/// List of HS.Push.Relationship IDs
Property RelationshipList As list Of %String(STORAGEDEFAULT = "array");

}
