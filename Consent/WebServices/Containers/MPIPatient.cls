/// Used in the web services for Add / Edit / Load / List Consent records
Class HS.Consent.WebServices.Containers.MPIPatient Extends HS.Consent.WebServices.Containers.MPIFacility
{

Property MPI As %String;

Property MRN As %String;

Property MRNAssigningAuthority As %String;

Property InActive As %Boolean [ InitialExpression = 0 ];

}
