#Include "Protheus.ch"
#Include "APWebSrv.ch"
#Include "APWebex.CH"           

/*/{Protheus.doc} FSCTBW01
A Função de nome FSCTBW01 não será implementada

@type function
@author Alex Teixeira de Souza
@since 08/01/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function FSCTBW01()
Return

//Parâmetros da Consulta
WsStruct oFSCTBW01Cons
	WsData cLogUsu	As String
	WsData cSenUsu	As String
	WsData cCNPJFil	As String
	WsData cNomeFil	As String
	WsData cRefer		As String
	WsData nValProd	As Float
	WsData nValPerd	As Float	
	WsData nValGlosa	As Float
EndWsStruct

//Estrutura de Retorno
WsStruct oFSCTBW01Ret
	WSData cStatus	As String
	WSData cMensagem	As String
EndWsStruct

//WS Ativo Fixo
WsService IntegraProducao Description "WS Integracao DigitaMedXContabilidade Protheus" // Namespace ""
	// Dados do Retorno
	WsData oFSCTBW01Ret 			As oFSCTBW01Ret

	// Paramentros da consulta da Situação
	WsData oFSCTBW01Cons 		As oFSCTBW01Cons
	
	// Processo de consulta de situação financeira de Pessoa
	WsMethod IntDadosCtb Description "Realiza gravaçao dos dados para contabilizacao"

EndWsService

//Método de Consulta Bem Ativo Fixo
WsMethod IntDadosCtb WsReceive oFSCTBW01Cons WsSend oFSCTBW01Ret WsService IntegraProducao
	Local aRet:= {}
	
	aRet := U_FSCTBP01(::oFSCTBW01Cons:cLogUsu, ::oFSCTBW01Cons:cSenUsu, ::oFSCTBW01Cons:cCNPJFil,::oFSCTBW01Cons:cRefer, ::oFSCTBW01Cons:nValProd, ::oFSCTBW01Cons:nValPerd, ::oFSCTBW01Cons:nValGlosa )
//	Conout("Retorno "+aRet[1]+" Mensagem "+aRet[2])
	
	::oFSCTBW01Ret:cStatus	:= aRet[1] 
	::oFSCTBW01Ret:cMensagem	:= aRet[2] 
Return .T.
