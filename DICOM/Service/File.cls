/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Include EnsDICOM

Class EnsLib.DICOM.Service.File Extends Ens.BusinessService [ ProcedureBlock, SqlTableName = _File, System = 4 ]
{

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

Parameter SETTINGS = "TargetConfigName:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},UseStorageLocation:Basic";

Property TargetConfigName As %String(MAXLEN = "");

/// To preserve backward compatibility, this service does not use the production's Storage Location by default, 
/// but the user can set this flag to do so and match the DICOM TCP adapter's behavior.
/// DICOM's TCP-based services and operations always use Storage Location and cannot be configured otherwise. 
Property UseStorageLocation As %Boolean [ InitialExpression = 0 ];

Method OnProcessInput(pInput As %RegisteredObject, pOutput As %RegisteredObject) As %Status
{
	#dim tSC As %Status
	#dim tDocument As EnsLib.DICOM.Document
	#dim tValue As %String
	#dim tStorageLocation As %String
	
	try {
		#; Do not use the production's storage location unless configured to do so
		Set tStorageLocation=""
		If ..UseStorageLocation {
			#; Get the current storage location
			Set tStorageLocation=..GetProductionSettingValue("StorageLocation",.tSC)
			If $$$ISERR(tSC) $$$LOGSTATUS(tSC) Quit
			
			If tStorageLocation'=""&&(0=##class(%File).DirectoryExists(tStorageLocation)) {
				Set tSC=$$$EnsError($$$DirectoryNotExist,tStorageLocation) Quit
			}
		}
		
		#; Create an instance of a DICOM Document from the file stream
		Set tSC=##class(EnsLib.DICOM.Document).CreateFromDicomFileStream(pInput,.tDocument,tStorageLocation)
		If $$$ISERR(tSC) Quit
		
		#; Set the CommandField, this is a 'Store' Request
		Set tSC=tDocument.SetValueAt($$$Str2MsgTyp("C-STORE-RQ"),"CommandSet.CommandField")
		If $$$ISERR(tSC) Quit
		
		#; Set the priority field, this is medium
		Set tSC=tDocument.SetValueAt(0,"CommandSet.Priority")
		If $$$ISERR(tSC) Quit
		
		#; Send the request to the process ( don't want a response )
		Set tSC=..SendRequestAsync(..TargetConfigName,tDocument,0)

	} catch {
		Set tSC=$$$EnsSystemError
	}
	Quit tSC
}

/// Return an array of connections for drawing lines on the config diagram
ClassMethod OnGetConnections(Output pArray As %String, pItem As Ens.Config.Item)
{
	Do ##super(.pArray,pItem)
	If pItem.GetModifiedSetting("TargetConfigName",.tValue) {
		Set tOne=$ZStrip(tValue,"<>W")
		Set:""'=tOne pArray(tOne)=""
	}
}

}
