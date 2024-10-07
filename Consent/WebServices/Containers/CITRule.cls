/// used in the web service for adding clinical information types
Class HS.Consent.WebServices.Containers.CITRule Extends HS.Consent.WebServices.ServiceStatus
{

Property CodingScheme As %String(MAXLEN = 1024);

Property MatchValues As list Of %String(MAXLEN = 100);

Property ID As %Integer;

/// Deprecated
Property Category As %String;

Property Code As %String;

Property Description As %String(MAXLEN = 2048);

Property Facility As %String;

/// Deprecated
Property SubCategory As %String;

Property Name As %String(MAXLEN = 100);

Property StreamletType As %String(MAXLEN = 255);

Property Qualifier As %String;

Property Operator As %String(VALUELIST = ",equal,word,code,codeonly,custom");

Property CustomClass As %String(MAXLEN = 255);

}
