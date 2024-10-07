/// used in the web service for adding clinical information types
Class HS.Consent.WebServices.Containers.SNO Extends HS.Consent.WebServices.Containers.Abstract
{

/// If true, this will prevent users from applying Break the Glass. (BTG allows users who would not ordinarily be consented to override consent rules.)
Property PreventBTG As %Boolean [ InitialExpression = 0 ];

}
