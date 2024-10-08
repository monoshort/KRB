/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
Class HS.FHIR.DTL.FromSDA.SubTransform.LabResultItem Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.LabResultItem, HS.FHIR.vDSTU2.Model.Resource.Observation), Deprecated ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
XData DTL [ Deprecated, XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.LabResultItem' targetClass='HS.FHIR.vDSTU2.Model.Resource.Observation' create='new' language='objectscript' >
<annotation>This transform uses the reserved DTL input parameter named &#39;aux&#39;.
For this transform, aux is a local array of strings.  The values held in aux were generated by the SDA to FHIR DTL framework prior to calling into this transform.
aux("PatientResourceId"): FHIR resource id for the patient represented by the Patient object in the SDA Container being transformed.</annotation>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.PatientReference' targetObj='target.subject' sourceObj='target' aux='.aux' />
<if condition='source.ExternalId &apos;= ""' >
<true>
<assign value='"official"' property='target.identifier.(1).use.value' action='set' />
<assign value='"ExternalId"' property='target.identifier.(1).type.text.value' action='set' />
<assign value='source.ExternalId' property='target.identifier.(1).value.value' action='set' />
</true>
</if>
<assign value='##class(HS.FHIR.DTL.Utils).LookupFHIR("FromSDALabResultItemStatus",source.TestItemStatus,"final",3)' property='target.status.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' targetObj='target.code' sourceObj='source.TestItemCode' />
<assign value='source.Comments' property='target.comments.value' action='set' />
<if condition='source.ObservationTime &apos;= ""' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.ObservationTime)' property='target.effectiveDateTime.value' action='set' />
</true>
<false>
<if condition='(source.FromTime &apos;= "")||(source.ToTime &apos;= "")' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.FromTime)' property='target.effectivePeriod.start.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).FHIRDateTime(source.ToTime)' property='target.effectivePeriod.end.value' action='set' />
</true>
</if>
</false>
</if>
<if condition='source.ResultInterpretation &apos;= ""' >
<true>
<assign value='source.ResultInterpretation' property='target.interpretation.text.value' action='set' />
<assign value='source.ResultInterpretation' property='target.interpretation.coding.(1).display.value' action='set' />
</true>
</if>
<if condition='source.ObservationMethods.Count() &gt; 0' >
<true>
<assign value='source.ObservationMethods.(1).OriginalText' property='target.method.text.value' action='set' />
<assign value='source.ObservationMethods.(1).Description' property='target.method.coding.(1).display.value' action='set' />
<assign value='source.ObservationMethods.(1).Code' property='target.method.coding.(1).code.value' action='set' />
<assign value='source.ObservationMethods.(1).CodeSystemVersionId' property='target.method.coding.(1).version.value' action='set' />
<assign value='##class(HS.FHIR.DTL.Utils).GetURIForCode(source.ObservationMethods.(1).SDACodingStandard)' property='target.method.coding.(1).system.value' action='set' />
</true>
</if>

<if condition='source.ResultValue &apos;= ""' >
<true>
<if condition='(..StartsWith(source.ResultValue,">=")=0)&amp;&amp;(..StartsWith(source.ResultValue,"&lt;=")=0)&amp;&amp;(..StartsWith(source.ResultValue,"=>")=0)&amp;&amp;(..StartsWith(source.ResultValue,"=&lt;")=0)&amp;&amp;(..StartsWith(source.ResultValue,">")=0)&amp;&amp;(..StartsWith(source.ResultValue,"&lt;")=0)'>
<true>
<if condition='##class(HS.FHIR.DTL.Utils).IsNumeric(source.ResultValue)=1' >
<true>
<assign value='source.ResultValue' property='target.valueQuantity.value.value' action='set' />
<if condition='source.ResultValueUnits &apos;= ""' >
<true>
<assign value='source.ResultValueUnits' property='target.valueQuantity.unit.value' action='set' />
</true>
</if>
</true>
<false>
<assign value='source.ResultValue' property='target.valueString.value' action='set' />
</false>
</if>
</true>
<false>
<if condition='(..StartsWith(source.ResultValue,">=")=1)||(..StartsWith(source.ResultValue,"&lt;=")=1)||(..StartsWith(source.ResultValue,"=>")=1)||(..StartsWith(source.ResultValue,"=&lt;")=1)' >
<true>
<if condition='##class(HS.FHIR.DTL.Utils).IsNumeric(source.ResultValue,1)=1' >
<true>
<assign value='..SubString(source.ResultValue,3)' property='target.valueQuantity.value.value' action='set' />
<if condition='(..StartsWith(source.ResultValue,">=")=1)||(..StartsWith(source.ResultValue,"=>")=1)' >
<true>
<assign value='">="' property='target.valueQuantity.comparator.value' action='set' />
</true>
<false>
<assign value='"&lt;="' property='target.valueQuantity.comparator.value' action='set' />
</false>
</if>
<if condition='source.ResultValueUnits &apos;= ""' >
<true>
<assign value='source.ResultValueUnits' property='target.valueQuantity.unit.value' action='set' />
</true>
</if>
</true>
<false>
<assign value='source.ResultValue' property='target.valueString.value' action='set' />
</false>
</if>
</true>
<false>
<if condition='(..StartsWith(source.ResultValue,">")=1)||(..StartsWith(source.ResultValue,"&lt;")=1)' >
<true>
<if condition='##class(HS.FHIR.DTL.Utils).IsNumeric(source.ResultValue,1)=1' >
<true>
<assign value='..SubString(source.ResultValue,2)' property='target.valueQuantity.value.value' action='set' />
<assign value='..SubString(source.ResultValue,1,1)' property='target.valueQuantity.comparator.value' action='set' />
<if condition='source.ResultValueUnits &apos;= ""' >
<true>
<assign value='source.ResultValueUnits' property='target.valueQuantity.unit.value' action='set' />
</true>
</if>
</true>
<false>
<assign value='source.ResultValue' property='target.valueString.value' action='set' />
</false>
</if>
</true>
</if>
</false>
</if>
</false>
</if>
</true>
<false>
<if condition='##class(HS.FHIR.DTL.Utils).CTIsDefined(source,"ResultCodedValue")' >
<true>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' sourceObj='source.ResultCodedValue' targetObj='target.valueCodeableConcept' />
</true>
</if>
</false>
</if>

<if condition='source.ResultNormalRange &apos;= ""' >
<true>
<assign value='##class(HS.FHIR.DTL.Utils).FromSDAReferenceRange(source.ResultNormalRange,source.ResultValueUnits)' property='target.referenceRange.(1)' action='set' />
</true>
</if>
</transform>
}

}
