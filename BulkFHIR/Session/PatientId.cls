Include HS.BulkFHIR

/// Ids of patients which were accessed in the export operation.
Class HS.BulkFHIR.Session.PatientId Extends %Persistent
{

/// Resource id of patient
Property patientid As %String(MAXLEN = 64) [ Required ];

/// Session reference
Property session As HS.BulkFHIR.Session [ Required ];

/// 0 - pending, 1 - completed, 2 - in progress
Property completed As %Integer [ InitialExpression = 0 ];

Index SessionPatientIndex On (session, patientid);

Index CompletedIndex On (session, completed);

/// Utility to indicate a patient id was accessed in this export operation
/// This utility calls a SQL stored procedure to file the data (so that the permissions can be granted to UnknownUser)
ClassMethod LinkPatient(pSession As HS.BulkFHIR.Session, pPatientId As %String)
{
	Set id = pSession.%Id()
	If pPatientId = "" {
		$$$ThrowFHIR($$$HSBFCErrSessionPatientIdRequired)
	}
	&sql(SELECT ID FROM HS_BulkFHIR_Session.PatientId WHERE Session = :id AND patientid=:pPatientId)
	$$$ThrowSQLIfError(SQLCODE,%msg)
	If SQLCODE=100 {
		&sql(INSERT INTO HS_BulkFHIR_Session.PatientId Set Session = :id, patientid=:pPatientId)
		$$$ThrowSQLIfError(SQLCODE,%msg)
	}
}

ClassMethod PatientCompleted(pSession As HS.BulkFHIR.Session, pPatientId As %String)
{
	Set id = pSession.%Id()
	&sql(UPDATE HS_BulkFHIR_Session.PatientId SET Completed = 1 WHERE Session = :id AND patientid=:pPatientId)
	$$$ThrowSQLIfError(SQLCODE,%msg)
}

ClassMethod GetPatients(pSession As HS.BulkFHIR.Session, Output pPatientList As %List, pGroupCount As %Integer = 10)
{
	Set id = pSession.%Id()
	Set pPatientList=""
	set lockManager = ##class(%ZHSLIB.LockManager).%New()
	Set name=$name(^HS.BulkFHIR.Patients(id))
	$$$ThrowOnError(lockManager.Lock(name,, 900)) //Expect lock to be available in <1s.
	&SQL(DECLARE PIDCursor CURSOR FOR select TOP :pGroupCount patientid INTO :pid from HS_BulkFHIR_Session.PatientId WHERE Session = :id And completed=0)
	&SQL(OPEN PIDCursor)
	For {
		&SQL(FETCH PIDCursor)
		QUIT:SQLCODE=100
		/// TODO: on restart update all 2's to 0
		&SQL(Update HS_BulkFHIR_Session.PatientId Set completed = 2 WHERE Session=:id AND patientid = :pid)
		If 'SQLCODE {
			Set pPatientList = pPatientList _$LB(pid)
		}
	}
	&SQL(CLOSE PIDCursor)
	Do lockManager.Unlock(name)
}

Storage Default
{
<Data name="PatientIdDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>patientid</Value>
</Value>
<Value name="3">
<Value>session</Value>
</Value>
<Value name="4">
<Value>completed</Value>
</Value>
</Data>
<DataLocation>^HS.BulkFHIR.Session.PatientIdD</DataLocation>
<DefaultData>PatientIdDefaultData</DefaultData>
<IdLocation>^HS.BulkFHIR.Session.PatientIdD</IdLocation>
<IndexLocation>^HS.BulkFHIR.Session.PatientIdI</IndexLocation>
<StreamLocation>^HS.BulkFHIR.Session.PatientIdS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
