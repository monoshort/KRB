/// used in the web service for adding clinical information types
Class HS.Consent.WebServices.Containers.ListFacilityItem Extends HS.Consent.WebServices.Containers.ListItem
{

/// Policy ID
Property ID As %String;

Property AllowBreakTheGlass As %Boolean [ InitialExpression = 1 ];

Property Decision As %String(DISPLAYLIST = ",Default Block,Default Block Except,Always Block,Always Block Except,Default Show,Default Show Except,Always Show,Always Show Except", VALUELIST = ",0,0Except,0Always,0AlwaysExcept,1,1Except,1Always,1AlwaysExcept");

/// Used during Load method 
Property DecisionString As %String(MAXLEN = 250);

/// Request Date
Property EffectiveDate As %String;

/// Request Date
Property ExpirationDate As %String;

}
