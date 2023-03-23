#Include "Protheus.ch"
#Include "APWebSrv.ch"
#Include "APWebex.CH"           

/*/{Protheus.doc} FSATFW01
A Função de nome FSATFW01 não será implementada

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

//Parâmetros da Consulta
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

	// Paramentros da consulta da Situação
	WsData oParConsulta 		As oParConsulta
	
	// Processo de consulta de situação financeira de Pessoa
	WsMethod ConsultaBem Description "Consulta Situação do Bem no Módulo Ativo Fixo"

EndWsService

//Método de Consulta Bem Ativo Fixo
WsMethod ConsultaBem WsReceive oParConsulta WsSend oRetorno WsService WSAtivoFixo
	Local aRet:= {}
	
	aRet := U_FSATFP01(::oParConsulta:cEmpCon, ::oParConsulta:cPlaqueta)
	
	::oRetorno:cStatus	:= aRet[1] 
	::oRetorno:cMensagem	:= aRet[2] 
	::oRetorno:cXml		:= aRet[3] 
Return .T.
