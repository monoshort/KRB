/// Used in the web services for Add / Edit / Load / List Consent records
Class HS.Consent.WebServices.Containers.MPIFacility Extends HS.Consent.WebServices.Containers.MPISNO
{

Property Facility As HS.Types.Facility;

Property AllowBreakTheGlass As %Boolean [ InitialExpression = 1 ];

/// Available in Load
Property FacilityName As %String;

}
