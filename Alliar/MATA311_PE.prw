#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} MATA311_PE
Ponto de Entrada na Rotina de Solicitacao de Transferencias

@author Guilherme.Santos
@since 04/01/2016
@version P12
*/
//-------------------------------------------------------------------
User Function MATA311()
	Local oObjMod		:= PARAMIXB[1]	//Objeto com o Model
	Local cAction		:= PARAMIXB[2]	//Id da Acao
	Local cIdForm		:= PARAMIXB[3]	//Id do Formulario
	Local nPosLin		:= 0

	Local xRetorno	:= .T.
	
	If ValType(oObjMod) == "O"
		//|MODELPRE|MODELPOS|FORMPRE|FORMPOS|FORMLINEPRE|FORMLINEPOS|MODELCOMITTTS|MODELCOMMITNTTS|FORMCOMMITTTSPRE|FORMCOMMITTTSPOS|FORMCANCEL|BUTTONBAR|
		If cAction == "MODELPOS" .AND. cIdForm == "MATA311"
			If oObjMod:GetOperation() == 3
				MsAguarde({|| xRetorno := WSAprova(oObjMod)}, "Enviando processo de Aprovacao para o Fluig.")
			ElseIf oObjMod:GetOperation() == 4
				If IsInCallStack("A311Altera")
					MsAguarde({|| xRetorno := WSAprova(oObjMod)}, "Enviando processo de Aprovacao para o Fluig.")
				EndIf
			EndIf
		EndIf

		If cAction == "MODELPRE" .AND. cIdForm == "MATA311" 
			If oObjMod:GetOperation() == 4
				If IsInCallStack("A311Altera")
					If oObjMod:GetModel("NNSMASTER"):GetValue("NNS_STATUS") == "3"
						Help(" ", 1, "Help", "MATA311_PE", "Nao e permitido alterar Solicitacoes em Aprovacao.", 3, 0)
						xRetorno := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	
Return xRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} WSAprova
Envia as Informacoes da Solicitacao para Aprovacao via Fluig

@author Guilherme.Santos
@since 05/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function WSAprova(oObjMod)
	Local oObjNNS		:= oObjMod:GetModel("NNSMASTER")
	Local oObjNNT		:= oObjMod:GetModel("NNTDETAIL")

	Local cArmDes		:= SuperGetMV("ES_ARMDESC", NIL, "91")
	Local cRetWS		:= ""
	Local nLinNNT		:= oObjNNT:GetLine()
	Local nI			:= 0
	Local lConecta	:= .F.
	Local lRetorno	:= .T.

	For nI := 1 to oObjNNT:Length()
		oObjNNT:GoLine(nI)

		If oObjNNT:GetValue("NNT_LOCLD") $ cArmDes
			lConecta := .T.
		EndIf
	Next nI

	If lConecta
		//Inicia o Processo no Fluig via Web Service
		lRetorno	:= U_ALREST03(oObjMod, @cRetWS)

		If lRetorno
			//Muda o Status para em Aprovacao
			oObjNNS:LoadValue("NNS_STATUS", "3")		//Em Aprovacao
			oObjNNS:LoadValue("NNS_XIDFLG", cRetWS)	//Retorno do Web Service
		Else
			Help(" ", 1, "Help", "MATA311_PE|WSAprova", "Nao foi possivel enviar o Processo de Aprovacao ao Fluig.", 3, 0)
			Help(" ", 1, "Help", "MATA311_PE|WSAprova", cRetWS, 3, 0)
		EndIf
	EndIf

	//Retorna para a Linha Original do Detalhe
	oObjNNT:GoLine(nLinNNT)
Return lRetorno
