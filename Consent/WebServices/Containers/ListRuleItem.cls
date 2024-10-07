/// used in the web service for adding clinical information types
Class HS.Consent.WebServices.Containers.ListRuleItem Extends HS.Consent.WebServices.Containers.ListItem
{

/// Deprecated
Property Category As %String;

Property Code As %String;

Property Facility As %String;

/// Deprecated
Property SubCategory As %String;

Property StreamletType As %String(MAXLEN = 255);

Property Qualifier As %String(MAXLEN = 255);

Property CustomClass As %String(MAXLEN = 255);

}
