Class HS.BulkFHIR.UI.REST.v2 Extends HS.BulkFHIR.UI.REST.v1
{

/// Returns information about current namespace and system version
ClassMethod GetJSONMetadata() As %Library.DynamicObject
{
    Set response = ##super()
    Set response."system_version" = {}
	Set response."system_version".major = $SYSTEM.Version.GetMajor()
	Set response."system_version".minor = $SYSTEM.Version.GetMinor()
	Quit response
}

}
