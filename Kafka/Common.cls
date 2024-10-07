/* Copyright (c) 2024 by InterSystems Corporation.
   Cambridge, Massachusetts, U.S.A.  All rights reserved.
   Confidential property of InterSystems Corporation. */

Class EnsLib.Kafka.Common Extends %RegisteredObject [ Abstract, ClassType = "", ProcedureBlock, System = 4 ]
{

/// Kafka server host and port.
Property Servers As %String(MAXLEN = 200) [ InitialExpression = "localhost:9092" ];

/// This is the ID name of the set of credentials values (Username, Password) used to access the Kafka server.
Property Credentials As %String(MAXLEN = 200);

/// Security protocol between Kafka client and broker </br>
/// Supported protocol: SASL_PLAINTEXT, SASL_SSL </br>
Property SecurityProtocol As %String(DISPLAYLIST = ",SASL_PLAINTEXT,SASL_SSL", VALUELIST = ",SASL_PLAINTEXT,SASL_SSL") [ InitialExpression = "SASL_PLAINTEXT" ];

/// SASL mechanism </br>
/// Posssible values: GSSAPI,PLAIN,SCRAM-SHA-256,SCRAM-SHA-512,OAUTHBEARER </br>
/// Supported mechanism: PLAIN </br>
Property SASLMechanism As %String(MAXLEN = 50) [ InitialExpression = "PLAIN" ];

/// Trust store location
Property TrustStoreLocation As %String(MAXLEN = 200);

/// Credentials ID containing trust store password
Property TrustStoreCredentials As %String(MAXLEN = 200);

/// Key store location
Property KeyStoreLocation As %String(MAXLEN = 200);

/// Credentials ID containing key store password
Property KeyStoreCredentials As %String(MAXLEN = 200);

/// Credentials ID containing key password
Property KeyCredentials As %String(MAXLEN = 200);

Parameter SETTINGS = "Servers:Kafka Settings,Credentials:Kafka Settings:credentialsSelector,SecurityProtocol:Kafka Settings,SASLMechanism:Kafka Settings,TrustStoreLocation:Kafka Settings,TrustStoreCredentials:Kafka Settings:credentialsSelector,KeyStoreLocation:Kafka Settings,KeyStoreCredentials:Kafka Settings:credentialsSelector,KeyCredentials:Kafka Settings:credentialsSelector";

}
