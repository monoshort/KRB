/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.InteropTools.HL7.MessageAnalyzer.NFA.Traverser.ScanTraverser Extends BaseTraverser
{

Property UnseenNames As %List [ ReadOnly ];

Method Seen(pElement As ElementBase)
{
}

Method Unseen(pUnseenNames As %List)
{
	Set i%UnseenNames=pUnseenNames
}

}
