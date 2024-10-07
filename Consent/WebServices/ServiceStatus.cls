Class HS.Consent.WebServices.ServiceStatus Extends (%RegisteredObject, %XML.Adaptor) [ Inheritance = right ]
{

Parameter XMLIGNOREINVALIDTAG As BOOLEAN = 1;

Parameter XMLIGNORENULL = "inputonly";

Property Status As %Status;

Property %User As %String [ InitialExpression = {$Username} ];

Property %Roles As %String(MAXLEN = "") [ InitialExpression = {$Roles} ];

Property %Gateway As %String [ InitialExpression = {$namespace} ];

/// Read only value
Property CreationTime As %TimeStamp;

/// Read only value 
Property ModificationTime As %TimeStamp;

}
