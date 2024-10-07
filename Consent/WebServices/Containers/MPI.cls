/// Used in the web services for Add / Edit / Load / List Consent records for system wide MPI
Class HS.Consent.WebServices.Containers.MPI Extends HS.Consent.WebServices.ServiceStatus
{

/// Policy ID
Property ID As %String;

Property AllowBreakTheGlass As %Boolean [ InitialExpression = 1 ];

Property Decision As %String(DISPLAYLIST = ",Default Block,Default Block Except,Always Block,Always Block Except,Default Show,Default Show Except,Always Show,Always Show Except", VALUELIST = ",0,0Except,0Always,0AlwaysExcept,1,1Except,1Always,1AlwaysExcept");

/// Used during Load method 
Property DecisionString As %String(MAXLEN = 250);

/// either block or show exceptions
Property Exceptions As list Of %String;

}
