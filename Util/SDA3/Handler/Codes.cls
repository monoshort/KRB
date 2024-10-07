Class HS.FHIR.DTL.Util.SDA3.Handler.Codes
{

ClassMethod InCodeTableDetail(pCodeTableDetail As HS.SDA3.CodeTableDetail, pCode As %String) As %Boolean
{
    if (pCodeTableDetail = "") {
        return 0
    }
    if (pCodeTableDetail.Code = pCode){
        return 1
    }
    return 0
}

ClassMethod InCodeTableDetailList(pCodeTableDetailList, pCode As %String) As %Boolean
{
    if (pCodeTableDetailList = "") {
        return 0
    }
    for i=1:1:pCodeTableDetailList.Count() {
        set codeTableDetail = pCodeTableDetailList.GetAt(i)
        if (..InCodeTableDetail(codeTableDetail,pCode)) {
            return 1
        }
    }
    return 0
}

}
