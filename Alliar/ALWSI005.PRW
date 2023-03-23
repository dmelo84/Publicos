#INCLUDE "ALWSI005.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALWSI005
Funcao Generica para Compilacao

@author Guilherme Santos
@since 14/11/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALWSI005()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} wsIntegracaoGenesys
Integracao do Atendimento Protheus x Genesys

@author Guilherme Santos
@since 14/11/2016
@version P12
*/
//-------------------------------------------------------------------
WSSERVICE wsIntegracaoGenesys 	Description "Integração Protheus x Genesys"
	WsData sCPF					as String
	WsData sOperator			as String
	WsData sIDTran				as String
	WsData sReturn				as String
	WsData sDDD					as String
	WsData sFone				as String
	WsData sMarca				as String
	WsData sTipo				as String
	WsMethod IntAtendimento		Description "Integração Atendimento"
EndWSService
//-------------------------------------------------------------------
/*{Protheus.doc} IntAtendimento
Metodo de Integracao do Atendimento

@author Guilherme Santos
@since 14/11/2016
@version P12
*/
//-------------------------------------------------------------------
WSMethod IntAtendimento WSReceive sCPF, sOperator, sIDTran, sDDD, sFone, sMarca, sTipo WsSend sReturn WSService wsIntegracaoGenesys
	Local lRetorno := .T.

	DbSelectArea("SZE")
	DbSetOrder(1)		//ZE_FILIAL, ZE_IDTRAN
	
	If SZE->(DbSeek(xFilial("SZE") + ::sIDTran))
		RecLock("SZE", .F.)
			SZE->ZE_STATUS	:= "1"
			SZE->ZE_OPERADO	:= ::sOperator
			SZE->ZE_DTINC	:= Date()
			SZE->ZE_HRINC	:= Time()
			SZE->ZE_CPF		:= ::sCPF
			SZE->ZE_DDD		:= ::sDDD
			SZE->ZE_FONE	:= ::sFone
			SZE->ZE_MARCA	:= ::sMarca
			SZE->ZE_TIPO	:= ::sTipo
		MsUnlock()
	Else
		RecLock("SZE", .T.)
			SZE->ZE_FILIAL	:= xFilial("SZE")
			SZE->ZE_IDTRAN	:= ::sIDTran
			SZE->ZE_STATUS	:= "1"
			SZE->ZE_OPERADO	:= ::sOperator
			SZE->ZE_DTINC	:= Date()
			SZE->ZE_HRINC	:= Time()
			SZE->ZE_CPF		:= ::sCPF
			SZE->ZE_DDD		:= ::sDDD
			SZE->ZE_FONE	:= ::sFone
			SZE->ZE_MARCA	:= ::sMarca
			SZE->ZE_TIPO	:= ::sTipo
		MsUnlock()
	EndIf

	::sReturn	:= "Registro gravado com sucesso."

Return lRetorno
