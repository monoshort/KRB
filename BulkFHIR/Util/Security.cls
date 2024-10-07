Include HS.BulkFHIR

Class HS.BulkFHIR.Util.Security
{

/// @API
/// @Input pBaseResourceAccess 		$lb(resource,access)
/// @Input pSession					Session object [ optional]
/// @Input pNonOwnerResourceAccess	$lb(resource,access) which will only be validated if a session object is provided 
ClassMethod ResourceCheck(pBaseResourceAccess As %List = "", pSession As HS.BulkFHIR.Session = "", pNonOwnerResourceAccess As %List = "")
{
	Do ..CheckResource($li(pBaseResourceAccess),$li(pBaseResourceAccess,2))

	Quit:'$IsObject(pSession)
	If pSession.client = $username || ((%bfcRESTSecurity.%IsA("HS.FHIRServer.API.Data.Request") && (pSession.client = %bfcRESTSecurity.Username))) {
		// if the owner
	} Else {
		Do ..CheckResource($li(pNonOwnerResourceAccess),$li(pNonOwnerResourceAccess,2))	
	}
}

/// @API
/// Check if current user has access to a specific resource and throw an error if not
/// @Input pResourceName 			resource name
/// @Input pResourceAccess			resource access (R,W,U)
ClassMethod CheckResource(pResourceName As %String, pResourceAccess As %String)
{
	If '($SYSTEM.Security.Check(pResourceName,pResourceAccess) || ((%bfcRESTSecurity.%IsA("HS.FHIRServer.API.Data.Request") && $System.Security.CheckUserPermission(%bfcRESTSecurity.Username,pResourceName,pResourceAccess)))) {
		$$$ThrowFHIR($$$HttpOnlyResponse(403))
	}
}

}
