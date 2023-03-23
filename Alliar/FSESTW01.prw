#include 'protheus.ch'
#include 'parmtype.ch'
#Include "APWebSrv.ch"
#Include "APWebex.CH"           

/*/{Protheus.doc} FSESTW01
A Função de nome FSESTW01 não será implementada
@author claudiol
@since 24/02/2016
@version undefined

@type function
/*/
user function FSESTW01()
return

//Parâmetros da Consulta
WsStruct oParEst
	WsData XML	As String
EndWsStruct

//Estrutura de Retorno
WsStruct oRetEst
	WSData CODSTATUS	As String
	WSData MSGERRO	As String
EndWsStruct

//WS Ativo Fixo
WsService INTEGRAESTOQUE Description "FSWBH-Integração de Estoque entre Protheus e Digitalmed - Pleres" // Namespace ""
	// Dados do Retorno
	WsData oRetEst As oRetEst

	// Paramentros da consulta da Situação
	WsData oParEst As oParEst
	
	// Processo de requisicao ao almoxarifado
	WsMethod Requisicao Description "Metodo para recebimento de solicitação ao almoxarifado"

	// Processo de recebimento do consumo efetuado no Pleres
	WsMethod EstoquePleres Description "Metodo para recebimento do consumo efetuado no Pleres"

EndWsService

//Método de Requisicao ao almoxarifado
WsMethod Requisicao WsReceive oParEst WsSend oRetEst WsService INTEGRAESTOQUE
	Local aRet:= {}
	
	aRet := U_FSESTP03(self:oParEst:XML)
	
	::oRetEst:CODSTATUS	:= aRet[1] 
	::oRetEst:MSGERRO		:= aRet[2] 
Return .T.

//Processo de recebimento do consumo efetuado no Pleres
WsMethod EstoquePleres WsReceive oParEst WsSend oRetEst WsService INTEGRAESTOQUE
	Local aRet:= {}
	
	aRet := U_FSESTP04(self:oParEst:XML)
	
	::oRetEst:CODSTATUS	:= aRet[1] 
	::oRetEst:MSGERRO		:= aRet[2] 
Return .T.
