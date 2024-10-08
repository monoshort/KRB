/// Transforms SDA3 HS.SDA3.OtherOrder to vSTU3 DiagnosticReport
Class HS.FHIR.DTL.SDA3.vSTU3.OtherOrder.DiagnosticReport Extends Ens.DataTransformDTL [ DependsOn = (HS.SDA3.OtherOrder, HS.FHIR.DTL.vSTU3.Model.Resource.DiagnosticReport), ProcedureBlock ]
{

/// This DTL XData block was generated. Do not modify it.
XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='HS.SDA3.OtherOrder' targetClass='HS.FHIR.DTL.vSTU3.Model.Resource.DiagnosticReport' create='existing' language='objectscript' >
  <annotation>
    <![CDATA[ Transforms HS.SDA3.OtherOrder (SDA3) to DiagnosticReport (vSTU3) ]]>
  </annotation>
<if condition='&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "OrderCategory")'> 
<true>
<assign value='"OTH"' property='target.category.coding.(1).code' action='set' >
<annotation>
<![CDATA[ Service category
 --- This target is one field within a CodeableConcept object assigned to the target DiagnosticReport:category.    ]]>
</annotation>
</assign>
</true>
</if>
<if condition='&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "OrderCategory")'> 
<true>
<assign value='"Other"' property='target.category.coding.(1).display' action='set' >
<annotation>
<![CDATA[ Representation defined by the system
 --- This target is one field within a CodeableConcept object assigned to the target DiagnosticReport:category.    ]]>
</annotation>
</assign>
</true>
</if>
<if condition='&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "OrderCategory")'> 
<true>
<assign value='"http://hl7.org/fhir/v2/0074"' property='target.category.coding.(1).system' action='set' >
<annotation>
<![CDATA[ Identity of the terminology system
 --- This target is one field within a CodeableConcept object assigned to the target DiagnosticReport:category.    ]]>
</annotation>
</assign>
</true>
</if>
<if condition='&apos;##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "OrderCategory")'> 
<true>
<assign value='"Other"' property='target.category.text' action='set' >
<annotation>
<![CDATA[ Plain text representation of the concept
 --- This target is one field within a CodeableConcept object assigned to the target DiagnosticReport:category.    ]]>
</annotation>
</assign>
</true>
</if>
<assign value='target.basedOn.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Resource.ProcedureRequest).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source, "HS.FHIR.DTL.SDA3.vSTU3.OtherOrder.ProcedureRequest")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.basedOn' action='set' key='index'  >
<annotation>
<![CDATA[ What was requested
Note: If results exist, this is where the ProcedureRequest resource is created. This way, the ProcedureRequest and DiagnosticReport resources are linked by a reference ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>

<assign value='aux("transformer").GetPatientReference()' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.subject' action='set' >
<annotation>
<![CDATA[ The subject of the report - usually, but not always, the patient ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.Comments&apos;=""'> 
<true> 
<assign value='source.Comments' property='target.conclusion' action='set' >
<annotation>
<![CDATA[ Clinical Interpretation of test results ]]>
</annotation>
</assign></true> 
</if> 

<assign value='aux("transformer").GetReference("Encounter",source.EncounterNumber)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.context' action='set' >
<annotation>
<![CDATA[ Health care event when test ordered ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.Lookup).SaveValueToAux("EncounterNumber", source.EncounterNumber, .aux)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target' action='set' >
<annotation>
<![CDATA[ The findings and interpretation of diagnostic tests performed on patients, groups of patients, devices, and locations, and/or specimens derived from these. The report includes clinical context such as requesting and provider information, and some mix of atomic results, images, textual and coded interpretations, and formatted representation of diagnostic reports. ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.ExternalId).Identifier(source.ExternalId)' property='value' action='set' />
<assign value='target.identifier.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.identifier' action='set' key='index'  >
<annotation>
<![CDATA[ Business identifier for report ]]>
</annotation>
</assign></true> 
</if> 
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.Order).FillerId(source.FillerId, .aux)' property='value' action='set' />
<assign value='target.identifier.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.identifier' action='set' key='index'  >
<annotation>
<![CDATA[ Business identifier for report ]]>
</annotation>
</assign></true> 
</if> 
<if condition='source.Result.ResultTime = ""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.FromTime, "instant")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.issued' action='set' >
<annotation>
<![CDATA[ DateTime this version was released ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.FromTime, "dateTime")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.effectiveDateTime' action='set' >
<annotation>
<![CDATA[ Clinically relevant time/time-period for report.  ]]>
</annotation>
</assign></true> 
</if> 
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "OrderCategory")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.OrderCategory, "HS.FHIR.DTL.SDA3.vSTU3.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.OrderCategory, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.category' action='set'  >
<annotation>
<![CDATA[ Service category
 --- In this case, any FHIR3 code may be used; diagnostic-service-sections shows Example codes, but you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "OrderedBy")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.Order).Clinician(source.OrderedBy, .aux)' property='value' action='set' />
<assign value='target.performer.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.performer' action='set' key='index'  >
<annotation>
<![CDATA[ Participants in producing the report ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "OrderItem")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Datatype.CodeableConcept).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.OrderItem, "HS.FHIR.DTL.SDA3.vSTU3.CodeTableTranslated.CodeableConcept")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.OrderItem, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.code' action='set'  >
<annotation>
<![CDATA[ Name/Code for this diagnostic report
 --- Although not required according to the HS.SDA3.OtherOrder class definition, in practice, the OrderItem property always contains a value.
 --- In this case, report-codes is the Preferred FHIR3 ValueSet for codes, but if you need to express meanings not found in report-codes, you may use codes from any ValueSet. 
 --- SDA does not restrict code values to a particular set.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "ParentResultObservation")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ParentResultObservation, "HS.FHIR.DTL.SDA3.vSTU3.CodeTableDetail.LabTestItem.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ParentResultObservation, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/other-order-parent-result-observation"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional Content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
<if condition='source.ParentResultObservationSubId&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ParentResultObservationSubId, "HS.FHIR.DTL.SubXFrm.SDA3.vSTU3.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ParentResultObservationSubId, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/other-order-parent-result-observation-sub-id"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional Content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<if condition='source.ParentResultObservationText&apos;=""'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.ParentResultObservationText, "HS.FHIR.DTL.SubXFrm.SDA3.vSTU3.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.ParentResultObservationText, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/other-order-parent-result-observation-text"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional Content defined by implementations ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.Order).PlacerId(source.PlacerId, .aux)' property='value' action='set' />
<assign value='target.identifier.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.identifier' action='set' key='index'  >
<annotation>
<![CDATA[ Business identifier for report ]]>
</annotation>
</assign></true> 
</if> 
<if condition='(source.Result.ResultItems.Count() = 0) &amp;&amp; (source.Result.Stream.Size > 0) &amp;&amp; (##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vSTU3","HS.SDA3.Result:FileType","digital-media-type",source.Result.FileType) &apos;= "")'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Result")'> 
<true>
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Resource.Media).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Result, "HS.FHIR.DTL.SDA3.vSTU3.Result.Media")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Result, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.Result, tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.image.(1).link' action='set'  >
<annotation>
<![CDATA[ Reference to the image source ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</true> 
</if>
</true>
</if>
<if condition='(source.Result.ResultItems.Count() = 0) &amp;&amp; ((source.Result.Stream.Size = 0) || (##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vSTU3","HS.SDA3.Result:FileType","digital-media-type",source.Result.FileType) = ""))'> 
<true>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "Result")'> 
<true>
<assign value='target.presentedForm.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Datatype.Attachment).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Result, "HS.FHIR.DTL.SDA3.vSTU3.Result.Attachment")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Result, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='tmp' property='target.presentedForm' action='set' key='index'  >
<annotation>
<![CDATA[ Entire report as issued ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true> 
</if>
</true>
</if>
<foreach property='source.Result.ResultItems()' key='st' >
<assign value='target.result.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Resource.Observation).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Result.ResultItems.(st), "HS.FHIR.DTL.SDA3.vSTU3.LabResultItem.Observation")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Result.ResultItems.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.Result.ResultItems.(st), tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.result' action='set' key='index'  >
<annotation>
<![CDATA[ Observations - simple, or complex nested groups ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</foreach>
<assign value='##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vSTU3","HS.SDA3.Result:ResultStatus","diagnostic-report-status",source.Result.ResultStatus)' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.status' action='set' >
<annotation>
<![CDATA[ registered | partial | preliminary | final +
 --- This mapping entry seeks a lookup table entry that can match a source value with a target value for this field. If the mapping cannot find the lookup table, or cannot find a matching entry in the lookup table, and it has a non-empty Default Value defined, it places its Default Value into the target field. Otherwise, the target receive no value from this mapping. 
 --- If the mapping is SDA to FHIR, and the source field contains a non-empty value, then by convention there are two mapping entries for this source field. Both entries execute under the same Condition to Set this Field. One entry does the lookup to retrieve the value to assign to the target field. The other stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
<false> 
<assign value='"unknown"' property='target.status' action='set' />
</false> 
</if> 
<if condition='source.Result.ResultStatus&apos;=""'> 
<true>
<if condition='(##class(HS.FHIR.DTL.Util.Lookup).Code("SDA3","vSTU3","HS.SDA3.Result:ResultStatus","diagnostic-report-status",source.Result.ResultStatus) = "")'> 
<true>
<assign value='target.extension.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Base.Extension).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Result.ResultStatus, "HS.FHIR.DTL.SubXFrm.SDA3.vSTU3.String.Extension")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Result.ResultStatus, .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='"http://intersystems.com/fhir/extn/sda3/lib/other-order-result-resultstatus"' property='tmp.url' action='set' />
<assign value='tmp' property='target.extension' action='set' key='index'  >
<annotation>
<![CDATA[ Additional Content defined by implementations
 --- This mapping supports a related mapping that does a table lookup to match the incoming source value with a value to place in the target field. This mapping has the same Condition to Set this Field as the table lookup. If the lookup successfully finds a value for target field, this mapping stores the original source field value in a FHIR extension.    ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>

</true>
</if>
</true>
</if>
<if condition='source.Result.ResultTime&apos;=""'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.Element.TypeCast).DateToFHIR(source.Result.ResultTime, "instant")' property='value' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.issued' action='set' >
<annotation>
<![CDATA[ DateTime this version was released ]]>
</annotation>
</assign></true> 
</if> 
</true>
</if>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source.Result, "VerifiedBy")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.Order).Clinician(source.Result.VerifiedBy, .aux)' property='value' action='set' />
<assign value='target.performer.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.performer' action='set' key='index'  >
<annotation>
<![CDATA[ Participants in producing the report ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<foreach property='source.Specimens()' key='st' >
<assign value='target.specimen.Count()+1' property='index' action='set' />
<assign value='##class(HS.FHIR.DTL.vSTU3.Model.Resource.Specimen).%New()' property='tmp' action='set' />
<assign value='aux("transformer").GetDTL(source.Specimens.(st), "HS.FHIR.DTL.SDA3.vSTU3.Specimen.Specimen")' property='DTL' action='set' />
<if condition='DTL&apos;=""'> 
<true>
<assign value='$classmethod(DTL, "Transform", source.Specimens.(st), .tmp, .aux)' property='status' action='set' />
<if condition='tmp&apos;=""'> 
<true>
<assign value='aux("transformer").AddResource(source.Specimens.(st), tmp)' property='reference' action='set' />
<if condition='reference&apos;=""'> 
<true>
<assign value='reference' property='target.specimen' action='set' key='index'  >
<annotation>
<![CDATA[ Specimens this report is based on ]]>
</annotation>
</assign></true> 
</if>
</true>
</if>
</true>
</if>
</foreach>
<if condition='##class(HS.FHIR.DTL.Util.Element.Object).Defined(source, "VerifiedBy")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Util.SDA3.Handler.Order).Clinician(source.VerifiedBy, .aux)' property='value' action='set' />
<assign value='target.performer.Count()+1' property='index' action='set' />
<if condition='value&apos;=""'> 
<true>
<assign value='value' property='target.performer' action='set' key='index'  >
<annotation>
<![CDATA[ Participants in producing the report ]]>
</annotation>
</assign></true> 
</if> </true> 
</if>
<if condition='##class(%Dictionary.ClassDefinition).%ExistsId("HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.OtherOrder.DiagnosticReport")'> 
<true>
<assign value='##class(HS.FHIR.DTL.Mapping.Extension.SDA3.vSTU3.OtherOrder.DiagnosticReport).Transform(source.Extension, .target, .aux)' property='target' action='set' />
</true>
</if>
</transform>
}

}
