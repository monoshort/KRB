Include HS.BulkFHIR

/// Class for common Bulk FHIR utility methods.
Class HS.BulkFHIR.Util
{

/// Return the request scheme, host and port, without the url or trailing slash, as understood
/// by the originating REST client. This takes proxy server headers into account.
ClassMethod GetRequestHost(pCSPRequest As %CSP.Request) As %String
{
	#; Get base from HS.FHIRServer.Util.BaseURL for consistency so we only need to make changes in one place if new headers are added, etc.
	#dim fullBase As %String = ##class(HS.Local.BulkFHIR.Util.BaseURL).GetBaseURL(pCSPRequest)
	
	Return $P(fullBase,"/",1,3)
}

/// Return just the part of the pFullURL which appears after the pBaseURL.
/// If the only difference between the base and the beginning of the full url is which protocol they use, disregard this difference.
ClassMethod GetSearchURL(pFullURL As %String, pBaseURL As %String) As %String
{
	#dim searchUrl As %String = pFullURL
	
	If pFullURL [ pBaseURL {
		Set searchUrl = $piece(pFullURL, pBaseURL, *)
	} Else {
		If (pBaseURL [ "https") && (pFullURL '[ "https") {
			Set pFullURL = $replace(pFullURL,"http","https")
			
		} ElseIf (pFullURL [ "https") && (pBaseURL '[ "https") {
			set pFullURL = $replace(pFullURL,"https","http")
		}
		If pFullURL [ pBaseURL {
			Set searchUrl = $piece(pFullURL,pBaseURL, *)
		}
	}
		
	Quit searchUrl
}

/// Helper method to log auth failures
ClassMethod LogAuthFail(pStatusCode As %Integer, pReason As %String, pCSPRequest As %CSP.Request) [ Internal ]
{
	Set event = {
		"severity": ($$$LogLevelError),
		"component": "auth",
		"type": "failure",
		"http_status": (pStatusCode),
		"reason": (pReason)
	}
	
	If $Data(pCSPRequest) {
		// For example, if request was 'https://host:port/bulkfhir/r4/Patient/$export',
		// then derive the '/Patient/$export' part into the path variable so that it
		// can be used with both the local and forwarded base urls.
		Set requestUrlForwarded = ##class(HS.Local.BulkFHIR.Util.BaseURL).GetBaseURL(pCSPRequest, .requestUrlLocal)
		Set path = $Extract(pCSPRequest.URL, $Length($Piece(requestUrlLocal, "/", 4, *))+2, *)
		Do event.%Set("request_url", requestUrlLocal _ path)
		If requestUrlForwarded '= requestUrlLocal {
			Do event.%Set("request_url_forwarded", requestUrlForwarded _ path)
		}
	}
	
	Do ##class(HS.BulkFHIR.Log).Log(event)
}

/// For a specified valid FHIR instant value, return a representation
/// as decimal seconds since $Horolog 0, in UTC time.
ClassMethod ConvertInstantToUTCSecs(pInstant As %String) As %Decimal [ ForceGenerate, Internal ]
{
	Set date = $Piece(pInstant, "T")
	Set timeWithOffset = $Piece(pInstant, "T", 2)
	Set offset = $Extract(pInstant, *-4, *)
	
	If $Extract(offset, *) = "Z" {
		Set offsetInSeconds = 0
		Set timeWithoutOffset = $Extract(timeWithOffset, 1, *-1)
		
	} Else {
		Set offsetSign = $Extract(timeWithOffset, *-5)
		Set offsetInSeconds = (3600 * $Piece(offset, ":", 1)) + (60 * $Piece(offset, ":", 2))
		Set timeWithoutOffset = $Piece(timeWithOffset, offsetSign, 1)
	}
	
	Set secsPrecision = $Length($Piece(timeWithoutOffset, ".", 2))
	Set dateTimeH = $ZDateTimeH(date _ "T" _ timeWithoutOffset, 3, 7, secsPrecision)
	Set utcDecimalSecs = (($Piece(dateTimeH, ",", 1)*86400) + $Piece(dateTimeH, ",", 2))
	If offsetInSeconds {
		If offsetSign = "+" {
			Set utcDecimalSecs = utcDecimalSecs - offsetInSeconds
		} Else {
			Set utcDecimalSecs = utcDecimalSecs + offsetInSeconds
		}
	}
	
	Return utcDecimalSecs
}

/// Convert a %Library.ListOfDataTypes of Strings to a delimited string.
ClassMethod ListOfStringToString(pListOfStrings As %Library.ListOfDataTypes, pOutputDelimiter) As %String
{
	If pOutputDelimiter = "" {
		$$$ThrowStatus($$$ERROR($$$GeneralError, "List of Strings to delimited string delimiter cannot be blank"))
	}
	
	Set outputStr = ""
	
	For {
		Set oneStr = pListOfStrings.GetNext(.key)
		If key = "" Quit
		Set oneStr = $ZStrip(oneStr, "<>W")
		If oneStr '= "" {
			If oneStr [ pOutputDelimiter {
				$$$ThrowStatus($$$ERROR($$$GeneralError, "List of Strings item '"_ oneStr _ "' cannot include delimiter value '" _ pOutputDelimiter _ "'"))
			}
			If outputStr '= "" {
				Set outputStr = outputStr _ pOutputDelimiter
			}
			Set outputStr = outputStr _ oneStr
		}
	}
	
	Return outputStr
}

}
