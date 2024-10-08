/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.ITK.Setup.UI.ProductionConfigurationLegend Extends EnsPortal.Dialog.standardDialog [ System = 4 ]
{

Parameter PAGENAME = "Production Configuration Legend";

/// User needs READ permissions on the %Ens_ProductionConfig resource to view this page.
Parameter RESOURCE = "%Ens_ProductionConfig:READ";

Parameter APPLYBUTTON = 0;

Parameter CANCELBUTTON = 0;

Parameter CLOSEONENTER = 1;

XData Style
{
<style type="text/css">

body {
	margin: 0px;
	padding: 0px;
}

</style>
}

/// This XML block defines the contents of this pane.
XData dialogBody [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<pane xmlns="http://www.intersystems.com/zen" cellStyle="padding-left:8px;padding-top:8px;">
<svgFrame id="legend" width="700" height="510" svgWidth="700" svgHeight="510"
svgPage="EnsLib.ITK.Setup.UI.ProductionConfigurationLegendSVG">
</svgFrame>
</pane>
}

ClientMethod getDialogValue() [ Language = javascript ]
{
	return null;
}

/// This callback is called when the user presses the OK button.
/// If this returns false, then the action is canceled.
ClientMethod ondialogFinish(action) As %Boolean [ Language = javascript ]
{
	return true;
}

// Get the (localized) name of the page.

Method %OnGetPageName() As %String
{
	Quit $$$Text("Production Configuration Legend")
}

/// Get the (localized) title string for the page.
Method %OnGetTitle() As %String
{
	Quit ..%OnGetPageName()
}

/// Get the (localized) subtitle string for the dialog.
/// This should be implemented in a subclass.
Method %OnGetSubtitle() As %String
{
	Quit ""
}

}
