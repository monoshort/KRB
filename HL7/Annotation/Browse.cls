/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Include EnsHL7.Annotation

Class EnsLib.HL7.Annotation.Browse Extends %CSP.Page [ System = 4 ]
{

Parameter DOMAIN = "Ensemble";

Parameter SECURITYRESOURCE = "%Ens_EDISchemaAnnotations:READ";

ClassMethod OnPage() As %Status
{
	//to work around issue with initial installation
	IF $D(^EnsHL7.Annotation("HealthShare_2.5")),'$D(^EnsHL7.Schema("HealthShare_2.5")) {
		S ^EnsHL7.Schema("HealthShare_2.5","base")=2.5,^("time")=$ZTIMESTAMP
	}
	Set version=$G(%request.Data("version",1),$S($D(^EnsHL7.Schema("HealthShare_2.5")):"HealthShare_2.5",1:"2.5"))
	Set type=$G(%request.Data("type",1),"MG")
	Set item=$G(%request.Data("item",1))
	#dim annot As EnsLib.HL7.Annotation.Data
	S annot=##Class(EnsLib.HL7.Annotation.Data).%New(version)
	Set basever=annot.GetBase()
	Set tStyle = ##class(%CSP.Page).Link("/csp/sys/intersystems.css")
	&html<<html>
<head> >
	&html<<link rel="stylesheet" type="text/css" href="#(tStyle)#">>
	&html<<style type="text/css">
h1 { font-size: 1.6em }
td.usage {text-align: center}
td.annotl {width: 100px}
td.annot {font-family: monospace ; font-size: x-small ; width: 800 px}
td.HSDBSDA {font-family: monospace ; font-size: x-small ; width:450 px ;border-width:2 border-style:solid}
td.HSDBSDAL {font-family: monospace ; font-size: x-small ; width: 50 px ;border-width:2 border-style:solid}
textarea {overflow: hidden ; border: 0 ; font-family: monospace ; font-size: x-small}
a.wtdlink {text-decoration: none}
</style>
<script language="javascript" type="text/javascript">
function go()
{
	box=document.forms[0].VersionList;
	location.href=box.options[box.selectedIndex].value;
}
</script>
</head>
<body>>
	W "<form name='ver'>"
	W "&nbsp;&nbsp;<a href=EnsLib.HL7.Annotation.ReportServerHTML.cls?version="_version_"&planned=0>",$$$TextHTML("HTML Report Today"),"</a>"
	W "&nbsp;&nbsp;<a href=EnsLib.HL7.Annotation.ReportServerXML.cls?version="_version_"&planned=0>",$$$TextHTML("XML Report Today"),"</a>"
	W "&nbsp;&nbsp;<a href=EnsLib.HL7.Annotation.ReportServerHTML.cls?version="_version_"&planned=1>",$$$TextHTML("HTML Report Planned"),"</a>"
	W "&nbsp;&nbsp;<a href=EnsLib.HL7.Annotation.ReportServerXML.cls?version="_version_"&planned=1>",$$$TextHTML("XML Report Planned"),"</a>"
	W:type'="CT"&&($SYSTEM.Security.Check("%Ens_EDISchemaAnnotations","WRITE")) "&nbsp;&nbsp;<a href=EnsLib.HL7.Annotation.EnterData.cls?version="_version_"&type="_type_"&item="_item,">",$$$TextHTML("Edit"),"</a>"
	W "&nbsp;&nbsp;<b>",$$$TextHTML("Version"),"  </b><select name='VersionList' size=1 onchange='go()'>" Set v=""
	F  {
		s v=$O(^EnsHL7.Schema(v)) Q:v=""
		W "<option value=EnsLib.HL7.Annotation.Browse.cls?version="_v_"&type="_type_"&item="_item
		W:v=version " selected" W ">",v,"</option>"
	}
	W "</select><form>&nbsp;&nbsp;"
	IF type="MG" {
		DO annot.LoadMG(.mgs)
		Set mg=""
		Write "<br><br>"
		W "<table border=4 cellspacing=0 cellpadding=4><caption><h1>",$$$TextHTML("Message Groups"),"</h1></caption>"
		W "<tr align='left'><th>",$$$TextHTML("Group"),"</th><th>",$$$TextHTML("Description"),"</th><th>",$$$TextHTML("Usage"),"</th></tr>"
		FOR  {
			Set mg=$O(mgs(mg)) Q:mg=""
			W "<tr>",$$wtdlink("MT",mg,mg),$$wtd(mgs(mg,"Name"),700),$$usage(mgs(mg,"U")),"</tr>"
			DO notes(mgs(mg,"Note"),1,2)
		}
		Write "</table><br><br>"
	}
	ElseIF type="MT" {
		Write "<br><br>"
		W "<table border=4 cellspacing=0 cellpadding=4><caption><h1>",$$$TextHTML("Message Types"),"</h1></caption>"
		W "<tr align='left'><th>",$$$TextHTML("Event"),"</th><th>",$$$TextHTML("Structure"),"</th><th>"
		W $$$TextHTML("Description"),"</th>",$$uheads,"</tr>"
		DO annot.LoadMT(item,.mts) Set mt=""
		FOR {
			Set mt=$O(mts(mt)) Q:mt=""
			W "<tr>",$$wtd(mt),$$wtdlink("MS",mts(mt,"MS"),$S(mts(mt,"MS")["_":"-"_$P(mts(mt,"MS"),"_",2,9),1:mts(mt,"MS")))
			W $$wtd(mts(mt,"Name"),600),$$usage(mts(mt,"U")),$$usage(mts(mt,"UC")),"</tr>"
			DO notes(mts(mt,"Note"),1,4)
		}
		Write "</table>"
	}
	ElseIF type="MS" {
		Do annot.LoadMS(item,.segs)
		W "<br><br><table border=4 cellspacing=0 cellpadding=4><caption><h1>",$$$TextHTML("Message Structure"),"  ",item ,"</h1></caption>"
		W "<tr><th>&nbsp;</th><th width=700>",annot.GetName("MS",item),"</th>",$$uheads,"</tr>"
		FOR i=1:1:segs {
			Set title=""
			IF (segs(i,"Type")="SEG")!(segs(i,"Type")="GRP") {
				Set title=" title= 'HL7 "_$S(segs(i,"Code")["[":"Optional",1:"Required")_" "_$S(segs(i,"Code")["{":", Repeating",1:"")_"'"
				
			}
			W "<tr><td",title,">" W:segs(i,"Type")="SEG" $$link("SS",segs(i,"SS"))
			W $$nbsp($J("",($L(segs(i,"Path"),",")-1)*3)_segs(i,"Code")) W:segs(i,"Type")="SEG" "</a>" W "</td>"
			W $$wtd($S(segs(i,"Type")'="SEG":"--- ",1:"")_segs(i,"Name")_$S(segs(i,"Type")="GRP":" begin",segs(i,"Type")="END":" end",1:""),700)
			IF segs(i,"Type")'="END" W $$usage(segs(i,"U")),$$usage(segs(i,"UC")) DO notes(segs(i,"Note"),1,3)
			W "</tr>"
		}
		W "</table>"
	}
	ElseIF type="SS" {
		W "<br><br><table border=4 cellspacing=0 cellpadding=4><caption><h1>",$$$TextHTML("Segment Structure"),"  ",item," - ",annot.GetName("SS",item),"</h1>"
		Set example=""
		FOR  {
			S example=$O(^EnsHL7.Annotation(version,"HS","SEGREF",item,example)) Q:example=""
			Set x=^EnsHL7.Annotation(version,"HS","EXAMPLE",example)
			W "Example ",example," (",$LI(x,1),") uses SDA Path ",$LI(x,2),". "
		}
		W "</caption>"
		W "<tr><th>",$$$TextHTML("Seq"),"</th><th>",$$$TextHTML("Description"),"</th>",$$uheads
		#if $$$EnsHSManage
			W "<th>HSPriority</th>"
		#endif
		W "<th>",$$$TextHTML("Code"),"<br>",$$$TextHTML("Table"),"</th><th>",$$$TextHTML("Data"),"<br>",$$$TextHTML("Struct"),"</th><th>",$$$TextHTML("Len"),"</th><th>",$$$TextHTML("HL7"),"<br>",$$$TextHTML("Required"),"</th><th>",$$$TextHTML("HL7"),"<br>",$$$TextHTML("Rpt"),"</th></tr>"
		Do annot.LoadSS(item,.flds)
		For i=1:1:flds {
			W "<tr>"
			Set u=flds(i,"U")
			W $$wtd(i),$$wtd(flds(i,"Name"),500),$$usage(u),$$usage(flds(i,"UC"))
			#if $$$EnsHSManage
				W $$wtd($g(flds(i,"HSPRI")))
			#endif
			IF flds(i,"CT")="" {W $$wtd("")}
			Else {W $$wtdlink("CT",$P(flds(i,"CT"),":",2),flds(i,"CT")) }
			IF flds(i,"DS")="" {W $$wtd("")}
			Else {W $$wtdlink("DS",$p(flds(i,"DS"),":",2),flds(i,"DS"))}
			S x=flds(i,"Req"),x=$S(x="R":"Required",x="O":"Optional",x="C":"Conditional",x="B":"Backwards Compatible",1:x)
			W $$wtd(flds(i,"Len")),$$wtd(x,100,,"usage"),$$wtd(flds(i,"Rpt"))
			W "</tr>"
			#if $$$EnsHSManage
				DO notes(flds(i,"Note"),1,9,i,version,item)
			#else
				DO notes(flds(i,"Note"),1,8,i,version,item)
			#endif
		}
		W "</table>"
	}
	ElseIF type="DS" {
	Set ds=""
		W "<br><br><table border=4 cellspacing=0 cellpadding=4><caption><h1>",$$$TextHTML("Data Structure"),"  ",basever,":",item," - ",annot.GetName("DS",item),"</h1></caption>"
		W "<tr><th>",$$$TextHTML("Seq"),"</th><th>",$$$TextHTML("Description"),"</th>",$$uheads,"<th>",$$$TextHTML("Code"),"<br>",$$$TextHTML("Table"),"</th><th>",$$$TextHTML("Data"),"<br>",$$$TextHTML("Struct"),"</th></tr>"
		Do annot.LoadDS(item,.flds)
		For i=1:1:flds {
			W "<tr>"
			Set u=flds(i,"U")
			W $$wtd(i),$$wtd(flds(i,"Name"),500),$$usage(u),$$usage(flds(i,"UC"))
			IF flds(i,"CT")="" {W $$wtd("")}
			Else {W $$wtdlink("CT",$P(flds(i,"CT"),":",2),flds(i,"CT")) }
			IF flds(i,"DS")="" {W $$wtd("")}
			Else {W $$wtdlink("DS",$p(flds(i,"DS"),":",2),flds(i,"DS"))}
			W "</tr>" DO notes(flds(i,"Note"),1,6)
		}
		W "</table>"
	}
	ElseIF type="CT" {
		W "<br><br><table border=4 cellspacing=0 cellpadding=4><caption><h1>",$$$TextHTML("Code Table"),"  ",basever,":",item," - ",annot.GetName("CT",item),"</h1></caption>"
		W "<tr><th>",$$$TextHTML("Value"),"</th><th width=700>",$$$TextHTML("Description"),"</th></tr>"
		DO annot.LoadOneCT(item,.codes) Set code=""
		FOR {
			s code=$O(codes(code)) Q:code=""
			W "<tr>",$$wtd(code),$$wtd(codes(code))
		}
	}
	&html<</body>
</html>>
	Quit $$$OK
	
notes(note,span1,span2,fldnum=0,v,seg)
	IF fldnum=0 {QUIT:note=""}
	//ELSE {QUIT:note_$G(flds(fldnum,"SDA"))_$G(flds(fldnum,"Trak"))=""
	ELSE  {KILL SDAEX MERGE SDAEX=^EnsHL7.Annotation(version,"HS","FLDREF",item,fldnum) Q:(note="")&'$D(SDAEX) }
	W !,"<tr>",$$wtd("","",span1),"<td colspan='",span2,"'><Table>"
	IF note'="" {
		W "<tr><td class='annotl'>HS Notes:</td><td><textarea readonly rows='"
		W $L(note)\77++$L(note,$C(13,10)),"' class='note' cols='77'>",$ZCVT(note,"O","HTML"),"</textarea></td></tr>"
	}
	W "</Table>"
	IF fldnum>0 {
		IF $D(SDAEX) {
			W !,"<table border=4>" SET ex="" F  {
				SET ex=$O(SDAEX(ex)) Q:ex=""  KILL exs
				W !,"<tr><td class='annotl'>",ex,": </td>"
				W "<td><table border=2>"
				F j=1:1:SDAEX(ex,0) {
					//sort by component, result (assuming global has space in place of nil)
					S x=SDAEX(ex,j),comp=$LI(x,1),res=$LI(x,3),exs(comp,res,$LI(x,2))=$LI(x,4)
				}
				SET comp=""
				FOR  {
					Set comp=$O(exs(comp)) Q:comp=""  SET res=""
					FOR  {
						Set res=$O(exs(comp,res)) Q:res=""  SET sda="", numcol=1
						W "<tr>"
						IF comp'=" " Set numcol=2 W "<td class='HSDBSDA'>" W:comp'=" " "Component: ",fldnum,".",comp,"</td>"
						W "<td class='",$S(numcol=2:"HSDBSDA",1:"annot"),"'>"  w:res'=" " "Sample: ",res W "</td></tr>"
						W "<tr><td colspan=",numcol,"><table>"
						FOR {
							Set sda=$O(exs(comp,res,sda)) Q:sda=""
							W !,"<tr><td class='HSDBSDAL'>HSDB:</td><td class='HSDBSDA'>",$Replace(exs(comp,res,sda),"@"," =&GT;"),"<td>"
							W "<td class='HSDBSDAL'>SDA:</td><td class='HSDBSDA'>",sda,"</td></tr>"
						}
						W "</table></td></tr>"
					}
				}
				W "</td></table>"
			}
			W !,"</Table>"
		}
		//IF $G(flds(fldnum,"SDA"))'="" {W "<tr><td class='annotl'>SDA field:</td><td class='annot'>",flds(fldnum,"SDA"),"</td></tr>"}
		//IF $G(flds(fldnum,"Trak"))'="" {W "<tr><td class='annotl'>Trak field:</td><td class='annot'>",flds(fldnum,"Trak"),"</td></tr>"}
	}
	//W "</table></td></tr>" Q
	W "</td></tr>" Q


wtdlink(ty,it,xx,wid="",class="")
	QUIT "<td"_$s(class'="": " class='"_class_"'",1:"")_$s(wid'="":" width='"_wid_"'",1:"")_">"_$$link(ty,it)_$S(xx="":"&nbsp;",1:$ZCVT(xx,"O","HTML"))_"</a></td>"

link(ty,it)
	QUIT "<a class='wtdlink' href='EnsLib.HL7.Annotation.Browse.cls?version="_version_"&type="_ty_"&item="_it_"'>"

uheads()
	QUIT "<th>"_$$$TextHTML("Explicit")_"<br>"_$$$TextHTML("Usage")_"</th><th>"_$$$TextHTML("Implicit")_"<br>"_$$$TextHTML("Usage")_"</th>"
	
usage(us)
	QUIT $$wtd($S(us="S":$$$TextHTML("Today"),us="P":$$$TextHTML("Planned"),1:$$$TextHTML("Not Used")),"","","usage")

wtd(xx,wid="",colspan="", class="")
	QUIT "<td"_$s(class'="": " class='"_class_"'",1:"")_$s(wid'="":" width='"_wid_"'",1:"")_$s(colspan'="":" colspan="_colspan,1:"")_">"_$S(xx="":"&nbsp;",1:$ZCVT(xx,"O","HTML"))_"</td>"
	
nbsp(yy)
	WHILE yy[" " { Set yy=$P(yy," ")_"&nbsp;"_$P(yy," ",2,999) }
	QUIT yy
}

}
