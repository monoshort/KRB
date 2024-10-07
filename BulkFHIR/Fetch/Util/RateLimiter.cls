Include HS.BulkFHIR

/// Basic rate limiter implementation, allows for calling functions
/// to limit the number of requests made for a resource to a fixed
/// number per second. This rate limit is honored across potentially
/// multiple IRIS processes.
Class HS.BulkFHIR.Fetch.Util.RateLimiter Extends %RegisteredObject
{

Property %key As %String [ Private ];

Property %maxRequestsPerSecond As %Integer [ Private ];

Parameter global = "^IRIS.Temp.BFC.PureFHIR.RateLimiter";

/// @API
/// Logs a request on the specified key. If the request
/// would exceed the specified rate limit, will wait until
/// the rate limit will not be exceeded. Then will allow
/// the calling routine to proceed. This rate limit is honored
/// across multiple IRIS processes.
/// @Returns	Time waited before allowing the request through
Method WaitUntilAllowed() As %Numeric
{
	set start = $zh
	//Only allow one rate limiter to through at a time, lock so one process isn't left waiting
	// due to poor timing.
	set lockManager = ##class(%ZHSLIB.LockManager).%New()
	$$$ThrowOnError(lockManager.Lock($name(@..#global(..%key)),, 60)) //Expect lock to be available in <1s.
	Set part = "."_$p(start,".",2)
	For {
		set now = $number($zh, 0)
		if $i(@..#global(now, ..%key)) <= ..%maxRequestsPerSecond {
			Quit
		}
		hang 1-part
		Set part = "."_$p($zh,".",2)
	}
	return ($zh - start)
}

/// @Input key					Uniquely identifies what's being rate-limited. May be an HTTP endpoint
/// 			 				or service registry name.
/// @Input maxRequestsPerSecond	Number of requests to be allowed for this key in a given second
Method %OnNew(key As %String, maxRequestsPerSecond As %Integer) As %Status
{
	if maxRequestsPerSecond < 1 {
		$$$ThrowFHIR($$$HSBFCErrRateTooLow)
	}
	set ..%key = key
	set ..%maxRequestsPerSecond = maxRequestsPerSecond
	return $$$OK
}

ClassMethod Cleanup()
{
	/// cleanup ratelimiter global nodes
	Set global = ..#global
	Set end = $zh-1
	Set node = ""
	For  {
		Set node = $O(@global@(node)) 
		Quit:(node=""||(node>end))
		Kill @global@(node)
	}
}

}
