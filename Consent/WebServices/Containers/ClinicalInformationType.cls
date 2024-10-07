/// used in the web service for adding clinical information types
Class HS.Consent.WebServices.Containers.ClinicalInformationType Extends HS.Consent.WebServices.ServiceStatus
{

Property ID As %Integer;

Property Active As %Boolean [ InitialExpression = 1 ];

Property Code As %String;

Property Description As %String(MAXLEN = 2048);

Property Facility As %String;

Property Name As %String(MAXLEN = 100);

Property Rules As list Of %Integer;

}
