#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*{Protheus.doc} MA185ENC
Ponto de Entrada no Encerramento da Pre Requisicao

@author Guilherme Santos
@since 29/04/2016
@version P12
*/
//-------------------------------------------------------------------
User Function MA185ENC()
	Local aArea		:= GetArea()
	Local aAreaSCP	:= SCP->(GetArea())
	Local aAreaSCQ	:= SCQ->(GetArea())

	Local cMsgErro	:= ""
	Local lRetorno	:= .T.
	
	If ValType(l185Auto) == "L" .AND. !l185Auto
		If FindFunction("U_E06UPDFL")
			If SCP->(FieldPos("CP_XIDFLG")) > 0 .AND. !Empty(SCP->CP_XIDFLG)
				
				MsAguarde({|| lRetorno := U_E06UPDFL(SCP->CP_NUM, @cMsgErro)}, "Atualizando processo no Fluig...")
				
				If !lRetorno
					Aviso("M185ENC", cMsgErro, {"Fechar"})
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSCQ)
	RestArea(aAreaSCP)
	RestArea(aArea)
Return NIL
