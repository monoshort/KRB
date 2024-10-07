/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

/// This class is for internal use
Class EnsPortal.Util.PageLinks [ Abstract, System = 4 ]
{

Property ruleEditorBaseURL As %String [ InitialExpression = {..GetRuleEditorURL(1)} ];

ClassMethod GetRuleEditorURL(pIncludeNamespace As %Boolean = 0, pZenEditor As %Boolean = 0) As %String [ Internal ]
{
	Set tNonZenURL = "/ui/interop/rule-editor/index.html"
	Set tZenURL = "EnsPortal.RuleEditor.zen"
	Return $S(pZenEditor||('..isWebAppEnabledForURL(tNonZenURL)):tZenURL,1:tNonZenURL) _ $S(pIncludeNamespace:"?$NAMESPACE="_$ZCVT($NAMESPACE,"O","URL"),1:"")
}

ClassMethod isWebAppEnabledForURL(pURL As %String) As %Boolean [ Internal ]
{
	Return ''$$$GetSecurityApplicationsEnabled($$getapp^%SYS.cspServer(pURL))
}

}
