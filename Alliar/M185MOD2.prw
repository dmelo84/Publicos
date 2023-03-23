#Include 'Protheus.ch'
//-------------------------------------------------------------------
/*{Protheus.doc} M185MOD2
Validacao da Baixa da Pre-Requisicao

@author Guilherme Santos
@since 19/05/2016
@version P12
*/
//-------------------------------------------------------------------
User Function M185MOD2()
	Local aArea		:= GetArea()
	Local aAreaSCP	:= SCP->(GetArea())
	Local aAreaSCQ	:= SCQ->(GetArea())
	Local aColsBxa	:= aClone(PARAMIXB)
	Local cMsgErro	:= ""
	Local lRetorno 	:= .T.

	If ValType(l185Auto) == "L" .AND. !l185Auto
		If FindFunction("U_E06VLDBX")
			If SCP->(FieldPos("CP_XIDFLG")) > 0 .AND. !Empty(SCP->CP_XIDFLG)
	
				MsAguarde({|| lRetorno := U_E06VLDBX(SCP->CP_NUM, aColsBxa, @cMsgErro)}, "Validando Baixa dos Itens no Fluig...")
	
				If !lRetorno
					DisarmTransaction()
					Aviso("M185MOD2", cMsgErro, {"Fechar"})
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSCQ)
	RestArea(aAreaSCP)
	RestArea(aArea)

Return lRetorno
