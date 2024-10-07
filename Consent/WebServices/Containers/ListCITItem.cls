/// used in the web service for adding clinical information types
Class HS.Consent.WebServices.Containers.ListCITItem Extends HS.Consent.WebServices.Containers.ListItem
{

Property Active As %Boolean [ InitialExpression = 1 ];

Property Code As %String;

Property Description As %String;

Property Facility As %String;

}
