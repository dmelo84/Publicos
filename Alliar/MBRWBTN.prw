#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} MBRWBTN
Ponto de Entrada ao Clicar na Opcao da MBrowse

@author Guilherme Santos
@since 24/02/2016
@version P12
*/
//-------------------------------------------------------------------
User Function MBRWBTN()
	Local cAlias		:= PARAMIXB[1]
	Local nRecno		:= PARAMIXB[2]
	Local nOption		:= PARAMIXB[3]
	Local cFunction	:= PARAMIXB[4]
	Local nStatus		:= 0
	Local lRetorno 	:= .T.

	If cFunction == "A185ESTORN"
		If !Empty(SCP->CP_XIDFLG)
			//Verifica o Status da Tarefa no Fluig
			MsAguarde({|| nStatus := U_E06GETST(SCP->CP_FILIAL, SCP->CP_NUM)}, "Verificando Status da Solicitação no Fluig.")

			If nStatus == -1
				Aviso("MBRWBTN", "Não foi possível estabelecer a Conexão ao Fluig para verificação do Status da Solicitação.", {"Fechar"})
				lRetorno := .F.
			ElseIf nStatus <> 44 .AND. nStatus <> 49
				Aviso("MBRWBTN", "A Pre-Requisição não pode ser estornada, pois foi originada a partir do Fluig e está em um Status que não permite o Estorno.", {"Fechar"})
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	If cFunction == "A185BAIXAR"
		If !Empty(SCP->CP_XIDFLG)
			//Verifica o Status da Tarefa no Fluig
			MsAguarde({|| nStatus := U_E06GETST(SCP->CP_FILIAL, SCP->CP_NUM)}, "Verificando Status da Solicitação no Fluig.")

			If nStatus == -1
				Aviso("MBRWBTN", "Não foi possível estabelecer a Conexão ao Fluig para verificação do Status da Solicitação.", {"Fechar"})
				lRetorno := .F.
			ElseIf nStatus <> 44
				Aviso("MBRWBTN", "A Pre-Requisição não pode ser baixada, pois foi originada a partir do Fluig e está em um Status que não permite o Baixa.", {"Fechar"})
				lRetorno := .F.
			EndIf
		EndIf
	EndIf

	If cFunction == "A105DELETA"
		If !Empty(SCP->CP_XIDFLG)
			Aviso("MBRWBTN", "A Solicitação não pode ser excluida, pois foi originada a partir do Fluig.", {"Fechar"})
			lRetorno := .F.
		EndIf
	EndIf

	If cFunction == "A185EXCLUI"
		If !Empty(SCP->CP_XIDFLG)
			Aviso("MBRWBTN", "A Solicitação não pode ser excluida, pois foi originada a partir do Fluig.", {"Fechar"})
			lRetorno := .F.
		EndIf
	EndIf

Return lRetorno
