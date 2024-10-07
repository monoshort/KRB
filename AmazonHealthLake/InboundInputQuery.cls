/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.AmazonHealthLake.InboundInputQuery Extends %RegisteredObject
{

Property DatastoreId As %String(MAXLEN = 1000);

Property SearchType As %String(MAXLEN = 1000);

Property SearchParameters As %String(MAXLEN = 1000);

Property PayLoad As %GlobalBinaryStream;

}
