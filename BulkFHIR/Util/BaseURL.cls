/// Default approach to getting the base URL and URL to use for links in Bulk FHIR
/// Use HS.Local.BulkFHIR.Util.BaseURL to make any customizations
Class HS.BulkFHIR.Util.BaseURL Extends HS.FHIRServer.Util.BaseURL
{

/// @API.Overridable
/// Overridable method for finding the link to find the url to use in outputting a link.
/// In the simple default case we switch out <server_base> for the scheme, host and port
/// specified by the REST client.<br>
/// To customize, users may override this method in HS.Local.BulkFHIR.Util.BaseURL.<br>
/// @Input pLink Link formulated by Bulk FHIR component.<br>
/// @Input pBaseUrl Full base url, including scheme, host, port and url, as specified by
///                 the REST client. This value is used in the default implementation.<br>
/// @Input pRequest %CSP.Request object for the current request. Not used by default.
///                 Made available for customization use.<br>
ClassMethod GetURLForLink(pLink As %String = "", pBaseUrl As %String, pRequest As %CSP.Request) As %String
{
	Quit $replace(pLink, "<server_base>", $piece(pBaseUrl, "/", 1, 3))
}

}
