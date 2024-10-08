/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
Class HS.FHIR.DTL.FromSDA.MedicationFromOrdered Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.Medication, HS.FHIR.vDSTU2.Model.Resource.Medication), Deprecated ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

/// <b>THIS TRANSFORM CLASS IS DEPRECATED</b>
XData DTL [ Deprecated, XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.Medication' targetClass='HS.FHIR.vDSTU2.Model.Resource.Medication' create='new' language='objectscript' >
<annotation>This transform uses the reserved DTL input parameter named &#39;aux&#39;.
For this transform, aux is a local array of strings.  The values held in aux were generated by the SDA to FHIR DTL framework prior to calling into this transform.
aux("ResourceId"): FHIR resource id to assign to the resource being created by this transform.</annotation>
<assign value='$G(aux("ResourceId"))' property='target.id.value' action='set' />
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' sourceObj='source.OrderItem' targetObj='target.code' />
<if condition='##class(HS.FHIR.DTL.Utils).CTIsDefined(source,"DosageForm")="1"' >
<true>
<subtransform class='HS.FHIR.DTL.FromSDA.SubTransform.CodeTableTranslated' sourceObj='source.DosageForm' targetObj='target.product.form' />
</true>
</if>
</transform>
}

}
