/// Used in the web services for Add / Edit / Load / List Facility Consent records
Class HS.Consent.WebServices.Containers.Facility Extends HS.Consent.WebServices.Containers.Abstract
{

Parameter XMLTYPE = "ConsentWebServiceContainerFacility";

Property Facility As HS.Types.Facility;

/// Available in Load
Property FacilityName As %String;

}
