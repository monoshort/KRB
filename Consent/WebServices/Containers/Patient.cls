/// used in the web service for adding clinical information types
/// 
Class HS.Consent.WebServices.Containers.Patient Extends HS.Consent.WebServices.Containers.Abstract
{

Property Decision As %String(DISPLAYLIST = ",Block,Block Except,Show,Show Except", VALUELIST = ",0,0Except,1,1Except");

Property Facility As %String;

Property MPI As %String;

Property PreventBTG As %Boolean [ InitialExpression = 0 ];

Property MRN As %String;

Property MRNAssigningAuthority As %String;

Property InActive As %Boolean [ InitialExpression = 0 ];

}
