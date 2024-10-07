Class HS.Codes.Types.SimpleCode Extends (%RegisteredObject, %XML.Adaptor, HS.Util.CopyFrom)
{

Parameter XMLIGNOREINVALIDTAG As BOOLEAN = 1;

Parameter XMLIGNORENULL = "inputonly";

Property Code As %String(MAXLEN = 220);

Property Description As %String(MAXLEN = 220);

}
