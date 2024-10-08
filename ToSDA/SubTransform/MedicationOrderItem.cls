/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
Class HS.FHIR.DTL.ToSDA.SubTransform.MedicationOrderItem Extends Ens.DataTransformDTL [ DependsOn = (HS.FHIR.vDSTU2.Model.Resource.Medication, HS.SDA3.Medication), Deprecated ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
XData DTL [ Deprecated, XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.FHIR.vDSTU2.Model.Resource.Medication' targetClass='HS.SDA3.Medication' create='existing' language='objectscript' >
<if condition='$IsObject(source.code)' >
<true>
<assign value='source.code.text.value' property='target.OrderItem.OriginalText' action='set' />
<assign value='source.code.coding.(1).display.value' property='target.OrderItem.Description' action='set' />
<assign value='source.code.coding.(1).code.value' property='target.OrderItem.Code' action='set' />
<assign value='source.code.coding.(1).version.value' property='target.OrderItem.CodeSystemVersionId' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).GetCodeForURI(source.code.coding.(1).system.value)' property='target.OrderItem.SDACodingStandard' action='set' />
</true>
</if>
</transform>
}

}
