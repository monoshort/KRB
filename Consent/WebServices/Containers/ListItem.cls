/// used in the web service for adding clinical information types
Class HS.Consent.WebServices.Containers.ListItem Extends (%RegisteredObject, %XML.Adaptor) [ Inheritance = right ]
{

Parameter XMLIGNOREINVALIDTAG As BOOLEAN = 1;

Parameter XMLIGNORENULL = "inputonly";

Property ID As %String;

Property Name As %String(MAXLEN = 100);

}
