#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALREST03
Conexao ao Web Service do Fluig para Envio de Aprovacao de Transferencia

@author Guilherme.Santos
@since 05/01/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALREST03(oObjMod, cRetWS)
	Local lRetorno	:= .T.
	Default cRetWS	:= ""

	lRetorno := GeraFluig(oObjMod, @cRetWS)

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} GeraFluig
Envia o Processo de Aprovacao para o Fluig

@author Guilherme.Santos
@since 06/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function GeraFluig(oObjMod, cRetWs)
	Local nCompanyID		:= Val(SuperGetMv("MV_ECMEMP", NIL, 1))
	Local cUserID			:= SuperGetMv("MV_ECMMAT")
	Local cProcessID		:= "ProcessoDescarte" 	//Padrao para o proceso
	Local nChoosedState	:= 118 					//Inicio da Atividade
	Local cUserName		:= SuperGetMv("MV_ECMUSER", NIL, "integrador")
	Local cPassword		:= SuperGetMv("MV_ECMPSW", NIL, "integrador")
	Local cColleagueID	:= SuperGetMv("MV_ECMUSER", NIL, "integrador")
	Local aCardData		:= {}
	//Local aTemp			:= {}  
	Local oFluig			:= NIL
	Local nX				:= 0
	Local nY				:= 0
	Local nI				:= 0
	Local xValor			:= NIL
	Local lRetorno		:= .T.
	Local cString			:= ""
	Local cLoteCt			:= ""
	Local dDtVali			:= CtoD("")
	Local nCusto			:= 0
	Local nTotItem		:= 0
	Local nTotGeral		:= 0
	
	//Monta Formulário para Início da Tarefa
	AddCard(@aCardData, "M0_CODIGO"		, SM0->M0_CODIGO)
	AddCard(@aCardData, "M0_NOME"		, SM0->M0_NOME)
	AddCard(@aCardData, "M0_CODFIL"		, AllTrim(SM0->M0_CODFIL))
	AddCard(@aCardData, "M0_FILIAL"		, SM0->M0_FILIAL)
	AddCard(@aCardData, "login"			, alltrim(UsrRetMail(RetCodUsr())) )  //H&A-Compila 20210331 troca da funcao pswret
	AddCard(@aCardData, "colleagueName", alltrim(PswChave(RetCodUsr())) )     //H&A-Compila 20210331 troca da funcao pswret
	AddCard(@aCardData, "NNS_COD"		, oObjMod:GetModel("NNSMASTER"):GetValue("NNS_COD"))
	AddCard(@aCardData, "NNS_JUSTIF"	, oObjMod:GetModel("NNSMASTER"):GetValue("NNS_JUSTIF"))
	 
	For nI := 1 to oObjMod:GetModel("NNTDETAIL"):Length()
		cString := "___" + AllTrim(Str(nI))
		oObjMod:GetModel("NNTDETAIL"):GoLine(nI)
		If !oObjMod:GetModel("NNTDETAIL"):IsDeleted()

			cLoteCt	:= If(Empty(oObjMod:GetValue("NNTDETAIL", "NNT_LOTECT")), ".", oObjMod:GetValue("NNTDETAIL", "NNT_LOTECT"))
			dDtVali	:= If(Empty(oObjMod:GetValue("NNTDETAIL", "NNT_DTVALI")), dDatabase, oObjMod:GetValue("NNTDETAIL", "NNT_DTVALI"))
			nCusto		:= Posicione("SB2", 1, xFilial("SB2") + oObjMod:GetValue("NNTDETAIL", "NNT_PROD") + oObjMod:GetValue("NNTDETAIL", "NNT_LOCAL"), "B2_CM1")
			nTotItem 	:= Round(oObjMod:GetValue("NNTDETAIL", "NNT_QUANT") * nCusto, 2)
			nTotGeral	+= nTotItem

			AddCard(@aCardData, "NNT_PROD" + cString			, oObjMod:GetValue("NNTDETAIL", "NNT_PROD"))
			AddCard(@aCardData, "NNT_DESC" + cString			, oObjMod:GetValue("NNTDETAIL", "NNT_DESC"))
			AddCard(@aCardData, "NNT_LOCAL" + cString			, oObjMod:GetValue("NNTDETAIL", "NNT_LOCAL"))
			AddCard(@aCardData, "NNT_UM" + cString				, Posicione("SB1", 1, xFilial("SB1") + oObjMod:GetValue("NNTDETAIL", "NNT_PROD"), "B1_UM"))
			AddCard(@aCardData, "NNT_DESC_LOCAL" + cString	, Posicione("NNR", 1, xFilial("NNR") + oObjMod:GetModel("NNTDETAIL"):GetValue("NNT_LOCAL"), "NNR_DESCRI"))
			AddCard(@aCardData, "NNT_LOTECT" + cString		, cLoteCt)
			AddCard(@aCardData, "NNT_DTVALI" + cString		, dDtVali)
			AddCard(@aCardData, "NNT_QUANT" + cString			, oObjMod:GetValue("NNTDETAIL", "NNT_QUANT"))
			AddCard(@aCardData, "NNT_VAL_MEDIO" + cString		, nCusto)
			AddCard(@aCardData, "TOTAL_ITEM" + cString		, nTotItem)
		EndIf
	Next nI

	AddCard(@aCardData, "TOTAL_ITENS"	, nTotGeral)

	//Instancia WebService Client Fluig
	oFluig	:= WSECMWorkflowEngineServiceService():New()
	
	oFluig:cUserName			:= cUserName
	oFluig:cPassword			:= cPassword
	oFluig:nCompanyID			:= nCompanyID
	oFluig:cProcessID			:= cProcessID
	oFLuig:nChoosedState		:= nChoosedState
	oFluig:cColleagueID		:= cColleagueID
	oFluig:cUserID			:= cUserID
	oFluig:lCompleteTask		:= .T.
	oFluig:lManagerMode		:= .F.
	oFluig:cComments			:= "Processo Aprovação de Descarte"
	oFluig:_URL				:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	//Atribui CardData
	For nX	:= 1 to Len(aCardData)
		Aadd(oFluig:OWSSTARTPROCESSCARDDATA:oWSitem, ECMWorkflowEngineServiceService_stringArray():New())
		
		For nY := 1 to Len(aCardData[nX])
			/*
			-----------------------------------------------------------------------------------------------------
				Trata valores diferentes de caractere para adicionar no array cItem
				Não trato valores caractere, pois os mesmos são incluidos normalmente no xml
			-----------------------------------------------------------------------------------------------------	
			*/
			xValor := aCardData[nX][nY]

			If ValType(xValor) == "L"
				If xValor
					xValor := "true"
				Else
					xValor := "false"
				EndIf
			ElseIf ValType(xValor) == "D"
				xValor := DtoC(xValor)
			ElseIf ValType(xValor) == "N"
				xValor := AllTrim(Transform(xValor, "@E 999,999,999,999.99"))
			EndIf
			
			Aadd(aTail(oFluig:OWSSTARTPROCESSCARDDATA:oWSitem):cItem, xValor)
		Next nY
	Next nX
	
	//Inicia processo no Fluig
	If oFluig:StartProcess()
		If oFluig:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[1] == "ERROR"
			cRetWS 	+= "Erro durante a abertura da solicitação Fluig." + CRLF
			cRetWS		+= "Descrição do erro: " + CRLF
			cRetWs		+= oFluig:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[2] + CRLF
			lRetorno 	:= .F.
		Else
			//Numero da Solicitacao de Aprovacao do Fluig
			cRetWs 	:= ""
			lRetorno 	:= .T.

			For nI := 1 to Len(oFluig:OWSSTARTPROCESSRESULT:OWSITEM)
				If AllTrim(oFluig:OWSSTARTPROCESSRESULT:OWSITEM[nI]:cItem[1]) == "iProcess"
					cRetWS := oFluig:OWSSTARTPROCESSRESULT:OWSITEM[nI]:cItem[2]
				EndIf
			Next nI
		EndIf
	Else
		cRetWS 	:= "Falha na comunicação com o Fluig. A Solicitação não foi iniciada." + CRLF
		cRetWS		+= "Verificar com o administrador do Protheus, WebServer Protheus ou Fluig não iniciado" + CRLF
		cRetWs 	+= "Erro de Execução : " + GetWSCError() + CRLF
		lRetorno 	:= .F.
	EndIf
	
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} AddCard
Adiciona os Dados do Formulario para Envio

@author Guilherme.Santos
@since 06/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function AddCard(aCardData, cCampo, xValor)
	Local aTemp := {}

	Aadd(aTemp, cCampo)
	Aadd(aTemp, xValor)
	Aadd(aCardData, aClone(aTemp))
Return NIL
