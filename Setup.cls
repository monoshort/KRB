/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Include %occMessages

Class EnsLib.InteropTools.HL7.Setup Extends %RegisteredObject
{

Property ConversionType As %String;

Property Bag As %String [ MultiDimensional ];

/// Allowable values eGate,DataGate,Cloverleaf
ClassMethod Run(pType = "", pLocalClass As %String = "", pClassPath As %String = "", pPathJavaEXE As %String = "", pScriptsDir As %String = "")
{
    Set tTypes = ""
    Set tTypesCompare=""
	For tType = "eGate","DataGate","Cloverleaf" {
		If ##class(%ClassDefinition).%ExistsId("EnsLib.InteropTools.HL7."_tType) {
			Set tTypes=tTypes_$lb(tType)
            Set tTypesCompare = tTypesCompare _ $lb($zcvt(tType,"l"))
		}
	}
	Set tText = $$$FormatText($$$Text("Please enter a valid type %1","Ensemble"),$listtostring(tTypes)) 
	For {
		If pType="" {
			Write !,tText
			Read ": ",pType
			Return:pType="" $$$ERROR($$$GeneralError,$$$Text("No type selected","Ensemble"))
		}
        Set tPosition = $lf(tTypesCompare,$zcvt(pType,"l"))
        If 'tPosition {
            Set pType=""
        } Else {
            Set pType = $li(tTypes,tPosition)
            Quit
        }
	}
	Set tObject = ..%New()
	Set tObject.ConversionType=pType
	If pLocalClass]"" {
		Set tValid = tObject.imLocalClassValidate(pLocalClass)
		Set tValid = $$$ADDSC(tValid,tObject.imClassPathValidate(pClassPath))
		Set tValid = $$$ADDSC(tValid,tObject.imJavaExecutableValidate(pPathJavaEXE))
		If pScriptsDir ]"" {
			// for backwards compatibility - new version uses Interop.jar
			Set tValid = $$$ADDSC(tValid,tObject.imJavaScriptsDirValidate(pScriptsDir))
		}
		If $$$ISOK(tValid) {
			Set tValid = tObject.imUpdate()
		}
		Quit tValid
	}
	Quit tObject.imRun()
}

Method imRun()
{
	Set tQuestions = $lb("imLocalClass","imClassPath","imJavaExecutable","imUpdate")
	Set tQuestion = 1
	
	For  {
		Set tSC = $method($this,$li(tQuestions,tQuestion))
		If tSC = "^" Set tQuestion = tQuestion-1 Continue
		If $$$ISERR(tSC) Return tSC
		Set tQuestion = tQuestion+1
		Quit:tQuestion>$ll(tQuestions)
	}
	Quit tSC
}

Method imUpdate()
{
	Set tItem = ""
	Set tClass = ..Bag("c")
	Set ..Bag("p","CLASSNAMEPREFIX")=$G(..Bag("p","CLASSNAMEPREFIX"))
	Set ..Bag("p","CLASSNAMEPREFIX","Comment")="Optionally provide a prefix for generated classnames"

	For  {
		Set tItem = $O(..Bag("p",tItem)) 
		Quit:tItem=""
		Set tParameter = $G(..Bag("p",tItem,"r"))
		If '$isObject(tParameter) {
			Set tParameter=##class(%Dictionary.ParameterDefinition).%New(tClass)
			Do tClass.Parameters.Insert(tParameter)
			Set tParameter.Name=tItem
			Set tParameter.Description = $G(..Bag("p",tItem,"Comment"))
		}
		Set tParameter.Default = ..Bag("p",tItem)
	}
	Set tSC = tClass.%Save()
	If $$$ISERR(tSC) {
		Write !,$system.Status.GetErrorText(tSC)
	} Else {
		Write !,$$$FormatText($$$Text("%1 updated","Ensemble"),tClass.Name)
		Set tSC = $system.OBJ.Compile(tClass.Name,"k")
		If $$$ISERR(tSC) {
			Write !,$system.Status.GetErrorText(tSC)
		} ElseIf $g(..Bag("p","SCRIPTTOXMLCD"))]"" {
			Set tSC = $classMethod(tClass.Name,"CompileJava")
		}
	}
	Quit tSC
}

Method imLocalClassValidate(pClassName) As %Status
{
	Kill ..Bag
	Set ..Bag("slash")=$S($$$isWINDOWS:"\",1:"/")

	Set tSC=##class(%Dictionary.ClassDefinition).NameIsValid(pClassName) 
	If 'tSC {
		Quit tSC
	}
	If pClassName'="" {
		IF $l(pClassName,".")=1 {
			Set pClassName="User."_pClassName
		}
		Set tClass = ##class(%Dictionary.ClassDefinition).%OpenId(pClassName)
		If $IsObject(tClass) {
			For tIdx = 1:1:tClass.Parameters.Count() {
				Set tParam = tClass.Parameters.GetAt(tIdx)
				Set ..Bag("p",tParam.Name)=tParam.Default
				Set ..Bag("p",tParam.Name,"r")=tParam
			}
			
		} Else {
			Set tClass = ##class(%Dictionary.ClassDefinition).%New(pClassName)
			Set tClass.Super="EnsLib.InteropTools.HL7."_..ConversionType
			Set tClass.ProcedureBlock=1
		}
		Set ..Bag("c")=tClass
		Set ..Bag("p","CMDCONCATENATION")=$G(..Bag("p","CMDCONCATENATION"),$S($$$isWINDOWS:"&",1:";"))
		Quit $$$OK
	}
	Quit $$$ERROR($$$GeneralError,$$$Text("Class name is empty","Ensemble"))
}

Method imLocalClass()
{
	For {
		Read !,"Classname: ",tClassName
		If tClassName="" Quit
		If tClassName="^" 
		If tClassName="?" {
			Write !,$$$Text("A classname for a generated class which will hold the configuration parameters","Ensemble")
			Continue
		}
		Set tSC =..imLocalClassValidate(tClassName)
		If $$$ISERR(tSC) {
			Do $system.Status.DisplayError(tSC)
		} Else {
			Quit
		}
	}
	If '$ISObject($g(..Bag("c"))) {
		Set tText = $$$Text("Class definition is not an Object","Ensemble") 
		Write !,tText
		Return $$$ERROR($$$GeneralError,tText)
	}
	Quit $$$OK
}

Method imClassPath()
{
	Set tOriginalClassPath = $G(..Bag("p","JAVACLASSPATH"))
	If tOriginalClassPath = "" {
		Set slash=..Bag("slash")
		Set tAntlr = $zse(##class(%File).NormalizeDirectory($system.Util.InstallDirectory()_"dev/InteropTools/antlr/")_"antlr-*.jar")
		Set tInteropTools = $zse(##class(%File).NormalizeDirectory($system.Util.InstallDirectory()_"dev/InteropTools/java/")_"*.jar")
		Set tOriginalClassPath = $S(tAntlr]"":tAntlr_$S($$$isWINDOWS:";",1:":"))_tInteropTools
	}
	For {
		Write !,"Java ClassPath: ",tOriginalClassPath
		Read "          ",tClassPath
		If tClassPath="^" Return "^"
		If tClassPath="?" {
			Write !,$$$Text("A reference to the antlr complete and interop jars which can be found in the distribution","Ensemble")
			Continue
		}
		If tClassPath="" {
			Set tClassPath = tOriginalClassPath 
		}
		Set tSC = ..imClassPathValidate(tClassPath)
		If $$$ISERR(tSC) {
			Do $system.Status.DisplayError(tSC)
		} Else {
			Quit
		}
	}
	Quit $$$OK
}

Method imClassPathValidate(pClassPath) As %Status
{
	Set tSC = $$$OK
	Set tDelimiter = $S($$$isWINDOWS:";",1:":")
	For tIdx = 1:1:$l(pClassPath,tDelimiter) {
		Set tClassPath = $p(pClassPath,tDelimiter)
		If tClassPath = "" continue
		If '##class(%File).Exists(tClassPath) {
			Set tText = $$$Text("File does not exist at this location.","Ensemble")
			Set tSC = $$$ERROR($$$GeneralError,tText)
		}
	}
	If $$$ISOK(tSC) {
		Set ..Bag("p","JAVACLASSPATH")=pClassPath
	}
	Quit tSC
}

/// Parameter JAVACMD = "/library/java/javavirtualmachines/adoptopenjdk-13.jdk/Contents/Home/bin/java";
Method imJavaExecutable()
{
	#define Slash ..Bag("slash")
	Set tOriginalJavaPath = $G(..Bag("p","JAVACMD"))
	If tOriginalJavaPath = "" {
		Set tOriginalJavaPath=$system.Util.GetEnviron("JAVA_HOME")
		If tOriginalJavaPath = "" {
			If $$$isWINDOWS {
				Set tOriginalJavaPath =  "c:\Program Files\AdoptOpenJDK\jdk-8.0.232.09-hotspot\bin\java.exe"
			} Else {
				If ($zse("/usr/bin/java")]"") {
					Set tOriginalJavaPath = "/usr/bin/java"
				} Else {
					Set tOriginalJavaPath = "/library/java/javavirtualmachines/adoptopenjdk-13.jdk/Contents/Home/bin/java"
				}
			}
		} Else {
			Set tOriginalJavaPath = ##Class(%File).NormalizeFilename(tOriginalJavaPath_"/bin/java"_$S($$$isWINDOWS:".exe",1:""))
		}
	}
	For {
		Write !,"Path to java executable: ",tOriginalJavaPath
		Read "          ",tJavaPath
		If tJavaPath="^" Return "^"
		If tJavaPath="?" {
			Write !,$$$Text("The complete path to the java executable","Ensemble")
			Continue
		}
		If tJavaPath="" {
			Set tJavaPath = tOriginalJavaPath
		}
		Set tSC = ..imJavaExecutableValidate(tJavaPath)
		If $$$ISERR(tSC) {
			Do $system.Status.DisplayError(tSC)
		} Else {
			Quit
		}
	}
	
	Quit $$$OK
}

Method imJavaExecutableValidate(pJavaPath)
{
	Set tSC = $$$OK
	If '##class(%File).Exists(pJavaPath) {
		Set tSC = $$$ERROR($$$GeneralError,$$$Text("File does not exist at this location.","Ensemble"))
	} Else {
		Set ..Bag("p","JAVACMD")=pJavaPath
	}
	Quit tSC
}

/// Parameter SCRIPTTOXMLCD = "cd /Volumes/isc/migration/monk/java/";
Method imJavaScriptsDir()
{
	#define Slash ..Bag("slash")
	Set tOriginalJavaPath = $G(..Bag("p","SCRIPTTOXMLCD"))
	If tOriginalJavaPath = "" {
		If ..ConversionType = "Cloverleaf" {
			Set tOriginalJavaPath = ##class(%File).NormalizeDirectory($system.Util.InstallDirectory()_"dev/InteropTools/java/Cloverleaf/")
		} Else {
			Set tOriginalJavaPath = ##class(%File).NormalizeDirectory($system.Util.InstallDirectory()_"dev/InteropTools/java/Monk/")
		}
	}
	For {
		Write !,"Path to java (*.java) files: ",tOriginalJavaPath
		Read "          ",tJavaPath
		If tJavaPath="^" Return "^"
		If tJavaPath="?" {
			Write !,$$$Text("The complete path to the location of the java files supplied in the distribution","Ensemble")
			Continue
		}
		If tJavaPath="" {
			Set tJavaPath = tOriginalJavaPath
		}
		Set tSC = ..imJavaScriptsDirValidate(tJavaPath)
		If $$$ISERR(tSC) {
			Do $system.Status.DisplayError(tSC)
			Continue
		}
		Quit
	}
	
	Quit $$$OK
}

Method imJavaScriptsDirValidate(pJavaPath) As %Status
{
	Set tSC = $$$OK
	Set tDir = ##class(%File).GetDirectory(pJavaPath)
	Set tRS=##class(%ResultSet).%New("%Library.File:FileSet")
	If 'tRS.Execute(tDir,"*ToXML.java") || 'tRS.%Next() {
		Set tSC = $$$ERROR($$$GeneralError,$$$FormatText($$$Text("Expected files do not exist at this location %1.","Ensemble"),tDir))
	} Else {
		Set ..Bag("p","SCRIPTTOXMLCD")=pJavaPath
	}
	Quit tSC
}

}
