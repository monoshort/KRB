/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Include (%occInclude, EnsLib.InteropTools.HL7.Common)

Class EnsLib.InteropTools.HL7.Cloverleaf Extends (EnsLib.InteropTools.HL7.Cloverleaf.Parser, Common)
{

Parameter VARIABLETRANSLATEFROM = "-_?";

Parameter VARIALBETRANSLATETO = "duq";

Parameter DEFAULTVERSION;

Parameter CLASSNAMESUFFIX;

Parameter PERMANENTBAIL = 2;

/// When set to 0 CopyStrip becomes Copy
Parameter COPYSTRIP = 1;

Parameter FUNCTIONSET = "##class(EnsLib.InteropTools.HL7.DataGate.Functions).";

Parameter INCLUDECOMMENTS = 1;

Parameter SCRIPTTOXMLCD;

Parameter SCRIPTTOXML = "CloverleafToXML";

Property Annotate As %Boolean [ InitialExpression = 0 ];

Property InDefine As %Boolean;

Property Delimiters As %String;

Property Structure As %String [ MultiDimensional ];

Property FixNote;

Property LoopVarRefs As %String(MAXLEN = "") [ MultiDimensional ];

/// Problems related to variable substitution
Property NoteVariable As %String(MAXLEN = "") [ MultiDimensional ];

ClassMethod Positions()
{
	Quit:$D(^Ens.InteropTools.HL7.CL.Positions)
	Set file = ##class(%File).NormalizeDirectory($system.Util.InstallDirectory()_"dev/InteropTools/AdditionalFiles/Cloverleaf/")_"HL7SegmentDataElements.csv"
	Set tStream = ##class(%Stream.FileCharacter).%New() 
	If 'tStream.LinkToFile(file) {
		$$$ThrowStatus($$$ERROR($$$GeneralError,"Unable to process segment data elements file"))
	}
	Do ##class(EnsLib.InteropTools.HL7.ProductionGenerator).ParseCSV(tStream,.tStructure,.tRS)
	Do tRS.%Next() /// skip header
	Set tVersions=$lb("2.1","2.2","2.3","2.3.1","2.4","2.5") // from Versions table in order of row id

	While tRS.%Next() { 
		If tRS."version_id" = "" Continue
		Set tSeg=tRS."seg_code",tVer=tRS."version_id",tVersion=$li(tVersions,tVer),tSeq=tRS."seq_no",tItem=$E(100000+tRS."data_item",2,6) 
		Set:'$D(^Ens.InteropTools.HL7.CL.Positions(tSeg,tItem))#10 ^Ens.InteropTools.HL7.CL.Positions(tSeg,tItem)=tSeq 
		Set ^Ens.InteropTools.HL7.CL.Positions(tSeg,tItem,tVersion)=tSeq 
		If $G(^Ens.InteropTools.HL7.CL.Positions(tSeg,tItem),tSeq)'=tSeq ZKill ^Ens.InteropTools.HL7.CL.Positions(tSeg,tItem) 
	}
	Quit
}

Method DereferenceVariables() As %Status
{
	try {
		Set tSC = $$$OK
		Merge:..Debug $$$DebugGlobal("VariableReplacement")=..VariableReplacement
		Do ..Positions()
		//Kill $$$NamesForPosition
		Quit:($G(..Code("SourceDocType"))="" || ($G(..Code("TargetDocType"))))
		Set tScript=$p($zcvt(##class(%File).GetFilename(..Filename),"l"),".xlt")
		Set tName("Source")=tScript_"source"
		Set tName("Target")=tScript_"target"
		
		For tType = "Source","Target" {
			Set tVersion = ..Code(tType_"Version")
			Set tDocType = ..Code(tType_"DocType")
			If tDocType="" || (tVersion="") Continue
			If $D($$$InverseScheme(tVersion,tDocType),tData) {
				Set:$d(tData) ..Code(tType_"VerDocType")=tData 
				Continue
			}
			Set tStoreVersion = tVersion,tStoreDocType=tDocType
			Set tLookupVersion = tVersion,tLookupDocType = tDocType
			If '$D(^EnsHL7.Schema(tLookupVersion,"MS",tLookupDocType)) {
				If $D(^EnsHL7.Schema(tLookupVersion,"MT",tLookupDocType),tData) { //="2.6:ADT_A39"
					Set ..Code(tType_"VerDocType")=tData
					Set tLookupVersion=$p(tData,":")
					Set tLookupDocType=$p(tData,":",2)
				} Else {
					Set tLookupVersion=$G(^EnsHL7.Schema(tLookupVersion,"base")," ")
					Set ..Code(tType_"VerDocType")=tLookupVersion_":"_tLookupDocType
				}
			}
			If '$D(^EnsHL7.Schema(tLookupVersion,"MS",tLookupDocType)) {
				If $D(^EnsHL7.Schema(tLookupVersion,"MT",tLookupDocType),tData) { //="2.6:ADT_A39"
					Set ..Code(tType_"VerDocType")=tData
					Set tLookupVersion=$p(tData,":")
					Set tLookupDocType=$p(tData,":",2)
				} Else {
					Do ..ReportItem(tType_" DocType not found "_tVersion_":"_tDocType,0)
				}
	 		}
	 		Set:$D(..Code(tType_"VerDocType")) $$$InverseScheme(tVersion,tDocType)=..Code(tType_"VerDocType")
			Set tNode ="" 
			For  {
				Set tNode = $O(^EnsHL7.Schema(tLookupVersion,"MS",tLookupDocType,"map",tNode),1,tSchemaData) Quit:tNode=""
				Set tSeg = $p($p(tSchemaData,"|",2),":",2)
				If tSeg'?3AN continue
				Set tBase = tVersion
				If '$D(^EnsHL7.Schema(tVersion,"SS",tSeg)) {
					Set tBase = $G(^EnsHL7.Schema(tVersion,"base")," ")
					Continue:'$D(^EnsHL7.Schema(tBase,"SS",tSeg)) 
				}
				
				Set $$$InverseScheme(tVersion,tDocType,tSeg,"P",tNode)=$i($$$InverseScheme(tVersion,tDocType,tSeg,"P"))
				Set tName=""
				Set tTypeInfoList = ^EnsHL7.Schema(tBase,"SS",tSeg)
				For  {
					Set tName=$O(^EnsHL7.Schema(tBase,"SS",tSeg,"names",tName),1,tPosition) Quit:tName=""
					Set $$$InverseScheme(tVersion,tDocType,tSeg,"Positions",tPosition)=tName
					//Set %ref = $$$LiteralInverseScheme_"(""_tVersion_"",""_tDocType_"",""_tSeg_"",""Positions"","_tPosition_")"
					Kill tTypeInfoAry
					Do ..GetDataTypeInfo($li(tTypeInfoList,tPosition),.tTypeInfoAry,1)
					Merge $$$InverseScheme(tVersion,tDocType,tSeg,"Positions",tPosition,"SubPos")=tTypeInfoAry
					If $li($li(tTypeInfoList,tPosition),6) {
						Set $$$InverseScheme(tVersion,tDocType,tSeg,"Positions",tPosition,"R")=1
					}
					///Set tTypeInfo = 
					/*
					For tIdx=1:1:$ll(tTypeInfoList) {
						Set tTypeInfo = $li(tTypeInfoList,tIdx)
						Set tDataType = $p($li(tTypeInfo),":",2)
						If tDataType="" {  continue }
						Set tDTVersion=$p($li(tTypeInfo),":")
						If $LL(^EnsHL7.Schema(tDTVersion,"DT",tDataType))'=1 {
							Set tNames=""
							For  {
								Set tNames=$O(^EnsHL7.Schema(tDTVersion,"DT",tDataType,"names",tNames),1,tSubPos) Quit:tNames=""
								Set $$$InverseScheme(tBase,tDocType,tSeg,"Positions",tPosition,"SubPos",tDataType,tSubPos)=tNames
							}
						}
					}
					*/
				}
			}
		}
		/// for each of the variables found try to determine what the vdoc is for IRIS
		Set tVar = "",tLastValid=0,tRound=0
		/// zw ..Code("Variables")
		For {
			Set tValid=0,tTotal=0,tRound=tRound+1
			For  {
				Set tVar = $O(..VariableReplacement(tVar),1,tUpdatedRef) Quit:tVar=""
				Set tTotal=tTotal+1
				/// not done the replacement
				If tUpdatedRef="" {
					Set tRef = $p($p(tVar,"[|||",2),"|||]")  //source.{[|||1(0).PID(0).#2(0).[0]|||]} ==> 1(0).PID(0).#2(0).[0]
					Continue:tRef=""
					Set tNode=$E(tVar,1,6)
					If tNode="source" {
						Set ..Code("Version")=..Code("SourceVersion")
						Set ..Code("DocType")=..Code("SourceDocType")
					} Else {
						Set ..Code("Version")=..Code("TargetVersion")
						Set ..Code("DocType")=..Code("TargetDocType")
					}
					break:..Code("Version")=" "
					Do ..DereferenceStructure(tNode,tRef,.tUpdatedRef,tRound,tVar)
					If tUpdatedRef]"" { 
						Set tLastChar = $E(tUpdatedRef,*) /// don't want to substitute () from foreach so strip last char and put it back on
						Set tUpdatedUpdatedRef = $replace($E(tUpdatedRef,1,*-1),"()","(1)")_tLastChar  
						If tUpdatedUpdatedRef'=tUpdatedRef {
							Do ..NoteVariable(tUpdatedUpdatedRef,"Updated () to (1) for reference "_tVar_" was "_tUpdatedRef_" and changed to "_tUpdatedUpdatedRef,0)
						}
						Set ..VariableReplacement(tVar)=tUpdatedUpdatedRef
					}
				}
				Set:tUpdatedRef]"" tValid=tValid+1
			}
			Quit:tLastValid=tValid
			Set tLastValid=tValid
		}
		Do ..ReportItem("Variable Substitutions "_tValid_" of "_tTotal)
		Set $$$DebugGlobal("Substitutions",..Filename,$h)=tValid_"^"_tTotal  /// substitutions over time
		Set tCode = ..Code("Code")
		For tIdx = 1:1:tCode.Items.Count() {
			Set tItem = tCode.Items.GetAt(tIdx)
			Set tMethod = "ReplaceVars"_tItem.%ClassName(0)
			try {
				Do $method($this,tMethod,tItem)
			} catch ex {break}
		}
		If $isObject(..FixNote) {
			Do ..Code("Code").Items.InsertAt(..FixNote,1)
		}
		
	} catch ex {
		Set tSC = ex.AsStatus()
		Do ..ReportItem("Fatal Error "_$ze,0) break:..Debug
	}
	Quit tSC
}

/// Convert structure from 1(0).PID(0).#2(0).[0] => PIDgrp.PID:PatientID
Method DereferenceStructure(pNode, pReference, Output pUpdatedRef = "", pRound = 0, pFullReference)
{
	If pReference="" {
		break:..Debug  
		Do ..ReportItem("Reference is empty")
		Set pUpdatedRef=""
		Quit
	}
	Set tVersion = $this.Code("Version")
	Set tDocType = $this.Code("DocType")
	//If $E(pReference,1,5)="0(0)." Set pReference=$E(pReference,6,*)
	Set tRefLength = $l(pReference,".")
	/// Walk pReference pieces "." until we find the  segment, if we don't find a segment it could be a group reference
	Do ..ArySub(pReference,.tSelectedTransRef)
	//Set tSelectedTransRef=pReference

	For tSegIdx=1:1:tRefLength {
		Set tSeg = $P($p(tSelectedTransRef,".",tSegIdx),"(")
		If tSeg?1A.2AN {
			Set tFoundRef = $G(..SelectedTranslation(pNode,tSelectedTransRef))
			If tFoundRef]"" {
				Set tCouldBe=1,tCouldBe(tFoundRef)=1
			} Else {
				Do ..GetPossibilities(tSeg,tVersion,tDocType,.tCouldBe)
			}
			Quit
		} ElseIf tSegIdx=tRefLength && ($d(..SelectedTranslation(pNode,tSelectedTransRef))) {
			Set tCouldBe(..SelectedTranslation(pNode,tSelectedTransRef))=1,tCouldBe=1 break:..Debug
			Set tNodes($i(tNodes))=tSeg
		} Else {
			Set tNodes($i(tNodes))=tSeg
		}
	}
	/// 0(0) is special, it's the top node, ie MSH will be 0(0).MSH
	If $G(tCouldBe)>1 && ($l(pReference,".")=2) && ($p(pReference,".")="0(0)") {
		Set tSeg = $P($P(pReference,".",2),"(")
		If tSeg?1A.2AN && ($D(tCouldBe(tSeg)) || $D(tCouldBe(tSeg_"()"))) {
			Set tSegments=""
			For  {
				Set tSegments=$O(tCouldBe(tSegments)) Quit:tSegments=""
				If $e(tSegments,1,3)=tSeg Continue
				Kill tCouldBe(tSegments)
				Set tCouldBe=tCouldBe-1
			}
		}
	}
	If pReference[$G(%Watch,$c(0)) { Write pNode,".",pReference,! zw tCouldBe  break  } /// likely want to skip when pRound=1 
	If '$D(tCouldBe) { Do ..ReportItem("nothing for pReference:"_pReference) quit}
	If tCouldBe>1 {
		If '$D(..SelectedTranslation(pNode)) { Quit }
		Do ..CleanupPotentials(pNode,pReference,.tCouldBe,tNodes,pRound)
	}
	If tCouldBe = 1 {
		Set pUpdatedRef = $O(tCouldBe(""))
		Do ..ProcessSegment(pNode,tSeg,tVersion,tDocType,pReference,.pUpdatedRef,tNodes,pFullReference)
	} Else {
		Set tNode="",tString=""
		For {
			Set tNode=$O(tCouldBe(tNode)) Quit:tNode=""  Set tString=tString_$c(13,10)_tNode
		}
		Do ..NoteVariable(pReference,"Could not determine which reference for "_pReference_" could be "_tString,0)
	}
	Quit 1
}

Method GetDataTypeInfo(pTypeInfo, ByRef pTypeInfoAry, pIteration)
{
	Set tDataType = $p($li(pTypeInfo),":",2)
	Quit:tDataType="" 
	Set tDTVersion=$p($li(pTypeInfo),":")
	Set tDTInfo = $G(^EnsHL7.Schema(tDTVersion,"DT",tDataType))
	Set tNames=""
	For  {
		Set tNames=$O(^EnsHL7.Schema(tDTVersion,"DT",tDataType,"names",tNames),1,tSubPos) Quit:tNames=""
		Set pTypeInfoAry(tSubPos)=tNames
	}
	For tIdx = 1:1:$ll(tDTInfo) {
		Kill tSubArray
		Do ..GetDataTypeInfo($li(tDTInfo,tIdx),.tSubArray,pIteration+1)
		Merge pTypeInfoAry(tIdx,"SubPos")=tSubArray
	}
}

Method ArySub(pReference, ByRef pStrippedRef, ByRef pAry, ByRef pAryVar)
{
	Kill pAry
	Set pStrippedRef = pReference
	For  {
		Quit:'$F(pStrippedRef,"(")
		Set tAry = $p($p(pStrippedRef,"(",2),")")
		If tAry'?1N.N { 
			$$$FixVariable(tAry,tAry,..#VARIABLETRANSLATEFROM,..#VARIALBETRANSLATETO)
			Set pAryVar($i(pAryVar))=tAry
		}
		Set tAry=tAry+1
		Set tPosition = $l($p(pStrippedRef,"("),".")
		Set pAry(tPosition)=tAry
		For {
			/// there were cases where the parenthesis did not match { OUT {{3(0).02).IN1(0).#12(0).[0]}} } causing a maxstring
			Set tRightParen = $F(pStrippedRef,")")
			Set tLeftParen = $F(pStrippedRef,"(")
			Quit:'tLeftParen||'tRightParen
			If tRightParen<tLeftParen {
				Set $E(pStrippedRef,tRightParen-1)=""
				Continue
			}
			Quit
		}
		Set pStrippedRef=$P(pStrippedRef,"(")_$p(pStrippedRef,")",2,*)
		Break:..Debug&&($l(pStrippedRef)>500)
	}
}

/// <var>pSourceTarget</var> source or target to keep the SelectedTranslations separate ..SelectedTranslation(pSourceTarget,ref)=updatedref<br>
/// <var>pSegment</var>
/// <var>pVersion</var>
/// <var>pDocType</var>
/// <var>pReference</var>
/// <var>pUpdatedRef</var>
/// <var>pPiecesIn</var> - 
Method ProcessSegment(pSourceTarget, pSegment, pVersion, pDocType, pReference, ByRef pUpdatedRef, pPiecesIn, pFullReference)
{
	Do ..ArySub($p(pReference,".",1,pPiecesIn),.tRef,.tAry,.tAryVar)
	Set tUpdatedSeg = $p(pUpdatedRef,".",*)

	/// tTransFrom 0(0).AL1(%s3) becomes 0(0).AL1 
	/// tTransTo AL1() becomes AL1
	//Set tTransFrom = $zstrip($p(pReference,".",1,pPiecesIn)_"."_$P($P(pReference,".",pPiecesIn+1),"("),"<",".")
	Set tTransFrom = $zstrip($p(tRef,".",1,pPiecesIn)_"."_$P($P(tRef,".",pPiecesIn+1),"("),"<",".")
	//Set tTransTo = $zstrip($P(pUpdatedRef,".",1,*-1)_"."_$P(tUpdatedSeg,"("),"<",".")
	Set tTransTo = $zstrip($P(pUpdatedRef,".",1,*-1)_"."_tUpdatedSeg,"<",".")
	Set ..SelectedTranslation(pSourceTarget,tTransFrom_tUpdatedSeg)=tTransTo
	If $l(tTransTo,".")>1 {
		/// If there are multiple pieces we have a Group for the parent
		Set tTransToParent = $P(tTransTo,".",1,*-1)
		Set tTransFromParent = $zstrip($p(pReference,".",1,pPiecesIn-1)_"."_$P($P(pReference,".",pPiecesIn),"("),"<",".")
		Do ..ArySub(tTransFromParent,.tRefTransFromParent)
		//Set tRefTransFromParent=tTransFromParent
		Set ..SelectedTranslation(pSourceTarget,tRefTransFromParent)=tTransToParent
		//break:$l(tTransToParent,"()")>2  /// group is longer than 1 .?
	}

	Set tUpdatedRef = $p(pUpdatedRef,".",1,*-1)
	Set tPos=0,tVar=0
	For  {
		Set tPos = $F(tUpdatedRef,"()",tPos)
		Quit:'tPos
		Quit:'$D(tAryVar($I(tVar)))
		Set tUpdatedRef = $E(tUpdatedRef,1,tPos-2)_tAryVar(tVar)_$E(tUpdatedRef,tPos-1,*)
	}
	Set pUpdatedRef=$S(tUpdatedRef]"":tUpdatedRef_".",1:"")_tUpdatedSeg
	If $O(tAryVar(tVar))]"" {
		Do ..NoteVariable(pFullReference,"More array variables than possible "_pReference_" versus "_pUpdatedRef,1)
	}
	/// need to swap array variables
	break:pUpdatedRef[$G(%Watch,$c(0))
	If tUpdatedSeg["()" {
		Set tSegment = $p(pReference,".",pPiecesIn+1)
		Set tSegRepeatVar = $p($p(tSegment,"(",2),")")
		Set:tSegRepeatVar?1N.N tSegRepeatVar=tSegRepeatVar+1
		Set pUpdatedRef = $E(pUpdatedRef,1,*-1)_tSegRepeatVar_")"
		Set tSegRepeatPosition = $lb(($l(pUpdatedRef)-$l(tSegRepeatVar)),($l(pUpdatedRef)-$l(tSegRepeatVar)-1)+$l(tSegRepeatVar))
	}

	Set tRemaining = $p(pReference,".",pPiecesIn+2,*)
	Quit:tRemaining=""
	Set tPosition = $p(tRemaining,"."),tRemaining=$p(tRemaining,".",2,*)
	Quit:tPosition=""
	Set tRepeatVar =$p($p(tPosition,"(",2),")")
	Set:tRepeatVar?1N.N tRepeatVar=tRepeatVar+1
	//Set tAry = $P($p(tPosition,"(",2),")")
	Set tPosition = $P(tPosition,"(")
	If $E(tPosition)'="#" { 
		If '$D($$$NumPosition(pSegment,tPosition)) {
			If ..Debug { $$$missingpos(pSegment,tPosition) }
			Do ..ReportItem("Position "_tPosition_" not found for "_pSegment)
			Set pUpdatedRef=""
			Quit
		}
		Set tPosition = $G($$$NumPosition(pSegment,tPosition),tPosition)
	} Else {
		Set tPosition = $E(tPosition,2,*)
	}

	Quit:'$Number(tPosition)
	Set tName = $G($$$InverseScheme(pVersion,pDocType,pSegment,"Positions",tPosition))
	Set tRepeating = $G($$$InverseScheme(pVersion,pDocType,pSegment,"Positions",tPosition,"R"))

	Set tAry = $l(pUpdatedRef,".")+1
	Set pUpdatedRef = pUpdatedRef_":"_tName
	If tRepeatVar]"" {
		If tRepeating {
			Set pUpdatedRef=pUpdatedRef_"("_tRepeatVar_")"
		} Else {
			If '$D(tSegRepeatVar) {}
			ElseIf tSegRepeatVar?1N.N {
				Set $E(pUpdatedRef,$li(tSegRepeatPosition),$li(tSegRepeatPosition,2))=tRepeatVar 
			} ElseIf tRepeatVar=1 {  /// was just something like #2(0) where it's not really repeating
			} Else {
				Do ..NoteVariable(pUpdatedRef,"Expected repeating variable "_pReference_" was "_pUpdatedRef_" but didn't find it ",1)
			}
		}
	}
	Set %ref = $$$LiteralInverseScheme_"("""_pVersion_""","""_pDocType_""","""_pSegment_""",""Positions"","_tPosition_")"
	For {
		Quit:tRemaining=""
		Set tItem = $zstrip($p(tRemaining,"."),"<>W","[]")
		If tItem'?1N.N {
			//break:..Debug
			Do ..NoteVariable(pReference,"Thought reference "_pReference_" was "_pUpdatedRef_" but didn't understand "_tItem,1)
			Set pUpdatedRef=""
			Quit
		}
		Set tRemaining=$p(tRemaining,".",2,*)
		Set %ref1=%ref
		Set %ref=$e(%ref,1,*-1)_",""SubPos"","_(tItem+1)_")"
		If '$D(@%ref) {
			// tItem = 0 could be indicating first piece (always 1 piece?) *** todo
			If tItem'=0 {
				/// if we don't have this piece
				Do ..NoteVariable(pReference,"Thought reference "_pReference_" was "_pUpdatedRef_" but extra item "_tItem,1)
				//Set ..VariableReplacement(pReference,"Note")=..NoteVar
				Set pUpdatedRef=""
			}
			Quit
		} Else {
			If tItem=0 && (tRemaining="") {
				//break:pUpdatedRef["MSH"
				Set %ref1=$e(%ref1,1,*-1)_",""SubPos"","_(tItem+2)_")"
				/// for entries ending in [0] where there are no other sub items (likely CodedValueforUserDefinedTabl) 1(0).0(%g1).PV1(0).#2(0).[0], just drop CodedValueforUserDefinedTabl
				If '$d(@%ref1) {
					Quit
				}
		}
		
		
		}
		Set tName = @%ref
		Set pUpdatedRef = pUpdatedRef_"."_tName
	}
	Quit
}

/// <var>pPiecesIn</var> The number of pieces "." in from the left
/// <var>pRound</var> The number of times we've iterated through the list of variables
Method CleanupPotentials(pSourceTarget, pReference, ByRef pCouldBe, pPiecesIn, pRound)
{
	Kill tAry
	Set tRef = $p(pReference,".",1,pPiecesIn)
	Set tPos=$L(tRef)
	If $E(tRef,*)=")" {
		/// Strip last subscript 2(0).1(0).0(0) becomes 2(0).1(0).0
		Set tPos=0
		For  {
			Set tNextPos=$F(tRef,"(",tPos+2)
			Quit:'tNextPos
			Set tPos=tNextPos-2
		}
		Set tRef=$E(tRef,1,tPos)
	}

	break:pReference[$G(%Watch,$c(0))
	Do ..ArySub(tRef,.tSelTransRef)
	//Set tSelTransRef=tRef
	
	If tSelTransRef]"" {
		If $D(..SelectedTranslation(pSourceTarget,tSelTransRef),tData) {
			Set tNode = ""
			For  {
				Set tNode=$O(pCouldBe(tNode)) Quit:tNode=""
				If tNode'[tData {
					Kill pCouldBe(tNode)
					Set pCouldBe=pCouldBe-1
				}
			}
		} Else {
			///strip off one piece and see if we can get a match
			Set tSelTransRef=$p(tSelTransRef,".",1,$l(tSelTransRef,".")-1)
			If tSelTransRef]"" && $D(..SelectedTranslation(pSourceTarget,tSelTransRef),tData) {
				break
			}
		}
	}
	Quit
}

Method GetPossibilities(pSegment, pVersion, pDocType = "", ByRef pCouldBe)
{
	Kill pCouldBe
	/*
	Set pBase=pVersion
	If '$D(^EnsHL7.Schema(pVersion,"SS",pSegment)) {
		Set tBase = $G(^EnsHL7.Schema(pVersion,"base")," ")
		If '$D(^EnsHL7.Schema(tBase,"SS",pSegment)) Quit 0
		Set pBase=tBase
	}
	*/
	If pDocType]"" {
		If $D($$$InverseScheme(pVersion,pDocType,pSegment,"P"),tCount) {  //break
			/// add to pCouldBe
			Merge pCouldBe = $$$InverseScheme(pVersion,pDocType,pSegment,"P")
			Quit 1
		} Else {
			Quit 0
		}
	}
	Quit 0
}

/// pDirectoryFile - a directory name or filename to process
ClassMethod TableImport(pDirectoryFile = "", pTableGroupName = "")
{
	Set tFilename = ##class(%File).GetFilename(pDirectoryFile)
	If tFilename="" {
		Do ..Files(pDirectoryFile,"*.tbl","TableImportFile",,pTableGroupName)
		Set tSC = $$$OK
	} Else {
		Set tSC = ..TableImportFile(pDirectoryFile,pTableGroupName)
	}
	Quit tSC
}

/// s c=0,t="" f  s t=$o(^Ens.LookupTable(t)) Quit:t=""  s c=c+1  d ##class(Ens.Util.LookupTable).%ClearTable(t)
ClassMethod TableImportFile(pFilename = "", pTableGroupName = "")
{
	#define readLine(%file,%sc,%value,%stripWhere,%stripValue) Set %value = %file.ReadLine(30000000,.%sc) If %stripWhere]"" { Set %value=$zstrip(%value,%stripWhere,%stripValue) }
	try {
		Set tSC = $$$OK
		Set tBidir = 0
		Set tTableName = pTableGroupName_$E(##class(%File).GetFilename(pFilename),1,*-4)
		Set tFile = ##class(%Stream.FileCharacter).%New()
		Set tSC = tFile.LinkToFile(pFilename) Quit:'tSC
		If 'tFile.Size {
			Write !,"File "_pFilename_" is empty"
			Quit
		}
		Write !,"Processing file: "_pFilename," with table name ",tTableName
		/// skip prologue
		For  {
			$$$readLine(tFile,tSC,tLine,"","")
			Quit:'tSC||tFile.AtEnd
			If tLine["bidir:" Set tBidir=$zstrip($p(tLine,":",2),"<>W")
			Quit:tLine["end_prologue"
		}
		/// get defaults
		$$$readLine(tFile,tSC,tSep,">",$C(13))
		For  {
			$$$readLine(tFile,tSC,tLine,">",$C(13))
			Quit:tLine="#"
			Quit:'tSC||tFile.AtEnd
			Set $$$Defaults(tTableName)=pFilename
			If $E(tLine,1,5)="dflt=" {
				Set tDefault = $p(tLine,"=",2)
				If tDefault]"" Set $$$Defaults(tTableName,"dflt")=tDefault
			} ElseIf $E(tLine,1,18)="dflt_passthrough=1" {
				Set $$$Defaults(tTableName,"dflt")=$C(0)
			} Else {
				Set $$$Defaults(tTableName,tLine)="",$$$Defaults(0,tLine)=""
			}
		}
		
		For  {
			$$$readLine(tFile,tSC,tKeyName,">",$C(13))
			Quit:'tSC||tFile.AtEnd
			$$$readLine(tFile,tSC,tValue,">",$C(13))
			Quit:'tSC
			Set tSC = ##class(Ens.Util.LookupTable).%UpdateValue(tTableName, tKeyName, tValue,$G(tCreate,1)) 
			If tBidir {
				Set tSC = ##class(Ens.Util.LookupTable).%UpdateValue(tTableName, tValue, tKeyName,$G(tCreate,1)) 
			}
			For  {
				$$$readLine(tFile,tSC,tLine,">",$C(13))
				Quit:tLine="#"
				Continue:tLine="encoded=0,0"
				Quit:tFile.AtEnd
			}
			Quit:tFile.AtEnd
		}
		///
	} catch ex {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}
