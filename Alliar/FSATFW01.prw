#Include "Protheus.ch"
#Include "APWebSrv.ch"
#Include "APWebex.CH"           

/*/{Protheus.doc} FSATFW01
A Fun��o de nome FSATFW01 n�o ser� implementada

@type function
@author claudiol
@since 09/12/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function FSATFW01()
Return

//Par�metros da Consulta
WsStruct oParConsulta
	WsData cEmpCon	As String
	WsData cPlaqueta	As String
EndWsStruct

//Estrutura de Retorno
WsStruct oRetorno
	WSData cStatus	As String
	WSData cMensagem	As String
	WSData cXml		As String
EndWsStruct

//WS Ativo Fixo
WsService WSAtivoFixo Description "WS Customizado Ativo Fixo" // Namespace ""
	// Dados do Retorno
	WsData oRetorno 			As oRetorno

	// Paramentros da consulta da Situa��o
	WsData oParConsulta 		As oParConsulta
	
	// Processo de consulta de situa��o financeira de Pessoa
	WsMethod ConsultaBem Description "Consulta Situa��o do Bem no M�dulo Ativo Fixo"

EndWsService

//M�todo de Consulta Bem Ativo Fixo
WsMethod ConsultaBem WsReceive oParConsulta WsSend oRetorno WsService WSAtivoFixo
	Local aRet:= {}
	
	aRet := U_FSATFP01(::oParConsulta:cEmpCon, ::oParConsulta:cPlaqueta)
	
	::oRetorno:cStatus	:= aRet[1] 
	::oRetorno:cMensagem	:= aRet[2] 
	::oRetorno:cXml		:= aRet[3] 
Return .T.
