#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALREST06
Exclusao das Pre Requisicoes e das Solicitacoes ao Armazem

@author Guilherme Santos
@since 26/04/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALREST06(cAlias, nReg, nOpc, lJobWSer, cMsgErro)
	Local cNumSol		:= ""
	Local lRetorno 	:= .T.

	Default lJobWSer	:= .F.
	Default cMsgErro	:= ""

	Begin Transaction
		DbSelectArea("SCP")
		DbSetOrder(1)		//CP_FILIAL, CP_NUM
		
		DbGoTo(nReg)
		
		If nReg == SCP->(Recno())
			cNumSol := SCP->CP_NUM

			If Empty(SCP->CP_XIDFLG)
				lRetorno 	:= .F.
				cMsgErro	:= "Este processo não é um processo originado no Fluig. Efetue a Exclusão a partir do Botão Excluir."
			Else
				If U_E06EXCPR(cNumSol, @cMsgErro)
					If U_E06EXCSA(cNumSol, @cMsgErro)
	
						If !lJobWSer
							MsAguarde({|| lRetorno := ExclFluig(SCP->CP_XIDFLG)}, "Efetuando a Exclusão da Tarefa no Fluig.")
				
							If !lRetorno
								cMsgErro := "Não foi possível efetuar a Exclusão do Processo no Fluig."
								DisarmTransaction()
							EndIf
						EndIf
					Else
						lRetorno := .F.				
						DisarmTransaction()
					EndIf			
				Else
					lRetorno := .F.
					DisarmTransaction()
				EndIf
			EndIf
		EndIf
	End Transaction

	If !lRetorno .AND. !lJobWSer
		Aviso("ALREST06", cMsgErro, {"Fechar"})
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} E06EXCSA
Exclusao da Solicitacao ao Armazem

@author Guilherme Santos
@since 26/04/2016
@version P12
*/
//-------------------------------------------------------------------
User Function E06EXCSA(cNumSol, cMsgErro)
	Local aAreaSCP	:= {}
	Local lRetorno 	:= .T.
	Local oSolArm		:= uSolArmazem():New()

	DbSelectArea("SCP")
	DbSetOrder(1)			//CP_FILIAL, CP_NUM
	
	If SCP->(DbSeek(xFilial("SCP") + cNumSol))
		oSolArm:AddCabec("EMPRESA", 	cEmpAnt)
		oSolArm:AddCabec("CP_FILIAL", 	SCP->CP_FILIAL)
		oSolArm:AddCabec("CP_NUM",		SCP->CP_NUM)
		oSolArm:AddCabec("CP_EMISSAO", 	SCP->CP_EMISSAO)
		oSolArm:AddCabec("CP_XIDFLG", 	SCP->CP_XIDFLG)

		aAreaSCP := SCP->(GetArea())

		While !SCP->(Eof()) .AND. xFilial("SCP") + cNumSol == SCP->CP_FILIAL + SCP->CP_NUM
				
			oSolArm:AddItem("CP_FILIAL"		, SCP->CP_FILIAL)
			oSolArm:AddItem("CP_ITEM"		, SCP->CP_ITEM)
			oSolArm:AddItem("CP_PRODUTO"	, SCP->CP_PRODUTO)
			oSolArm:AddItem("CP_UM"			, SCP->CP_UM)
			oSolArm:AddItem("CP_QUANT"		, SCP->CP_QUANT)
			oSolArm:AddItem("CP_SEGUM"		, SCP->CP_SEGUM)
			oSolArm:AddItem("CP_DATPRF"		, SCP->CP_DATPRF)
			oSolArm:AddItem("CP_LOCAL"		, SCP->CP_LOCAL)
			oSolArm:AddItem("CP_OBS"			, SCP->CP_OBS)
			oSolArm:AddItem("CP_CC"			, SCP->CP_CC)
			oSolArm:AddItem("CP_NUMSC"		, SCP->CP_NUMSC)
			oSolArm:AddItem("CP_XIDFLG"		, SCP->CP_XIDFLG)

			oSolArm:SetItem()

			SCP->(DbSkip())
		End

		RestArea(aAreaSCP)
			
		If !oSolArm:Gravacao(5)
			cMsgErro := oSolArm:GetMensagem()
			lRetorno := .F.
		EndIf
	Else
		lRetorno := .F.
	EndIf	

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} E06EXCPR
Exclusao da Pre Requisicao

@author Guilherme Santos
@since 26/04/2016
@version P12
*/
//-------------------------------------------------------------------
User Function E06EXCPR(cNumSol, cMsgErro)
	Local lRetorno 	:= .T.
	Local oPreReq		:= uPreReq():New()

	If !oPreReq:Exclusao(cNumSol)
		lRetorno 	:= .F.
		cMsgErro	:= oPreReq:GetMensagem()
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} ExclFluig
Exclui a Solicitacao no Fluig

@author Guilherme Santos
@since 04/03/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ExclFluig(cIdFluig)
	Local lRetorno 	:= .T.
	Local oFluig		:= WSECMWorkflowEngineServiceService():New()

	oFluig:_URL := SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	If oFluig:CancelInstance(	SuperGetMv("MV_ECMUSER"),;
	                        		SuperGetMv("MV_ECMPSW"),;
	                       		VAL(SuperGetMv("MV_ECMEMP")),;
	                        		VAL(cIdFluig),;
	                        		SuperGetMv("MV_ECMMAT"),;
	                        		"Processo cancelado através da integração com o Protheus") 
	Else
		lRetorno := .F.
	EndIf
   
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} E06UPDFL
Update da Solicitacao no Fluig

@author Guilherme Santos
@since 27/04/2016
@version P12
*/
//-------------------------------------------------------------------
User Function E06UPDFL(cNumSol, cMsgErro)
	Local aArea					:= GetArea()
	Local aAreaSCP				:= SCP->(GetArea())
	Local aAreaSCQ				:= SCQ->(GetArea())

	Local aCabec					:= {}
	Local aItens					:= {}

	Local cIdFluig				:= ""
	Local nItem					:= 0
	Local nIndice					:= 0
	Local nCampo					:= 0
	Local lInclui 				:= .F.
	Local lLoteCtl				:= .F.
	Local cCompara				:= ""

	Local lRetorno 				:= .T.
	Local oFluig					:= WSECMWorkflowEngineServiceService():New()
	Local nChoosedState			:= 0

	Local oECMData				:= uColecao():New()
	Local oItem					:= NIL
	Local cNextKey				:= "X01"

	Local aCardData				:= {}
	Local aOrder 					:= {}

	Local cCampo					:= ""
	Local xValor					:= NIL
	Local cChave					:= ""	
	Local nPosKey					:= 0
	Local nX						:= 0
	Local nY						:= 0

	Local cQuery					:= ""
	Local cTabQry					:= GetNextAlias()

	Local nPosErr 				:= 0

	Default cMsgErro				:= ""
	
	/*
	-----------------------------------------------------------------------------------------------------
		Atribuicao das Propriedades do Fluig para Conexao
	-----------------------------------------------------------------------------------------------------	
	*/
	If lRetorno
		oFluig:_Url 					:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
		oFluig:cUserName				:= SuperGetMV("MV_ECMUSER")
		oFluig:cPassword				:= SuperGetMV("MV_ECMPSW")
		oFluig:nCompanyID				:= Val(SuperGetMV("MV_ECMEMP"))
		oFluig:cUserID				:= SuperGetMV("MV_ECMMAT")
		oFluig:nProcessInstanceID	:= Val(Posicione("SCP", 1, xFilial("SCP") + cNumSol, "CP_XIDFLG"))
		oFluig:cProcessID				:= "SolicitacaoAoArmazem"
		oFluig:cColleagueID			:= SuperGetMV("MV_ECMMAT")
		oFluig:cComments				:= "Processo de Solicitacao ao Armazem"
		oFluig:nThreadSequence		:= 0
	EndIf
	
	/*
	-----------------------------------------------------------------------------------------------------
		Busca os Campos do Cabeçalho no CardData armazena para envio ao Fluig
	-----------------------------------------------------------------------------------------------------	
	*/
	If lRetorno
		If oFluig:getInstanceCardData()
			For nItem := 1 to Len(oFluig:oWSGetInstanceCardDataCardData:oWsItem)
				cCampo		:= oFluig:oWSGetInstanceCardDataCardData:oWsItem[nItem]:cItem[1]
				xValor		:= oFluig:oWSGetInstanceCardDataCardData:oWsItem[nItem]:cItem[2]
				cChave		:= ""

				If "___" $ cCampo
					cChave		:= Substr(cCampo, At("___", cCampo), Len(cCampo))
					cCampo		:= StrTran(cCampo, cChave, "")
				Else
					cChave		:= "CAB"
				EndIf

				//Cria um Objeto para o Cabecalho ou para os Itens
				If !oECMData:Contains(cChave)
					oECMData:Add(cChave, uColecao():New())
				EndIf

				oECMData:GetValue(cChave):Add(cCampo, xValor)
			Next nItem
		Else
			lRetorno := .F.
			cMsgErro := "Erro ao obter CardData da solicitação Fluig " + cIdFluig
		EndIf
	EndIf

	/*
	-----------------------------------------------------------------------------------------------------
		Busca o Status da Solicitacao Fluig
	-----------------------------------------------------------------------------------------------------	
	*/
	If lRetorno
		If oFluig:getAvailableStates()
			If Len(oFluig:oWSgetAvailableStatesStates:nItem) > 0
				nChoosedState := oFluig:oWSgetAvailableStatesStates:nItem[01]
			Else
				lRetorno := .F.
				cMsgErro := "Erro ao obter o Status Disponivel da solicitação Fluig " + cIdFluig
			EndIf
		Else
			lRetorno := .F.
			cMsgErro := "Erro ao obter o Status Disponivel da solicitação Fluig " + cIdFluig
		EndIf

		//nChoosedState := 45
	EndIf
	/*
	-----------------------------------------------------------------------------------------------------
		Tratamento dos Dados da Solicitacao ao Armazem para Envio ao Fluig
	-----------------------------------------------------------------------------------------------------	
	*/
	If lRetorno
			
		cQuery := GetQuery(cNumSol)

		DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
			
		While !(cTabQry)->(Eof())

			nItem 		:= 0
			lInclui 	:= .F.
			lLoteCtl	:= !Empty((cTabQry)->D3_LOTECTL)
			/*
			-----------------------------------------------------------------------------------------------------
				Procura pelo Item + Produto + Local + Lote
			-----------------------------------------------------------------------------------------------------	
			*/
			For nIndice := 1 to oECMData:Count()
				If oECMData:GetKey(nIndice) <> "CAB"
					oItem		:= oECMData:Elements(nIndice)
					cCompara	:= oItem:GetValue("id_item") + oItem:GetValue("id_produto") + Space(TamSX3("B1_COD")[1] - Len(oItem:GetValue("id_produto"))) + oItem:GetValue("id_armazem") + If(lLoteCtl, oItem:GetValue("id_lote") + Space(TamSX3("D3_LOTECTL")[1] - Len(oItem:GetValue("id_lote"))), "")

					If cCompara == (cTabQry)->CP_ITEM + (cTabQry)->CP_PRODUTO + (cTabQry)->CP_LOCAL + If(lLoteCtl, (cTabQry)->D3_LOTECTL, "")
						nItem		:= nIndice
					EndIf
				EndIf
			Next nIndice
			/*
			-----------------------------------------------------------------------------------------------------
				Se tem Lote e nao encontrou, busca pelo Item + Produto + Local
				Inclui um novo item na Colecao apenas se o Lote do Registro 
				localizado estiver preenchido com outro Lote
			-----------------------------------------------------------------------------------------------------	
			*/
			If lLoteCtl .AND. nItem == 0 
				For nIndice := 1 to oECMData:Count()
					If oECMData:GetKey(nIndice) <> "CAB"
						oItem		:= oECMData:Elements(nIndice)
						cCompara	:= oItem:GetValue("id_item") + oItem:GetValue("id_produto") + Space(TamSX3("B1_COD")[1] - Len(oItem:GetValue("id_produto"))) + oItem:GetValue("id_armazem")
	
						If cCompara == (cTabQry)->CP_ITEM + (cTabQry)->CP_PRODUTO + (cTabQry)->CP_LOCAL
							nItem		:= nIndice

							//Se o Lote ainda estiver em Branco no Registro usa o Proprio registro para Gravar o Lote
							If Empty(oItem:GetValue("id_lote")) .OR. oItem:GetValue("id_lote") == AllTrim((cTabQry)->D3_LOTECTL)
								oItem:SetValue("id_lote", AllTrim((cTabQry)->D3_LOTECTL))
								oItem:SetValue("id_dtvldlote", StoD((cTabQry)->D3_DTVALID))
							Else
								//Senao Inclui um Novo Registro para o Lote Atual da SD3
								lInclui	:= .T.
							EndIf
						EndIf
					EndIf
				Next nIndice
			EndIf

			//Encontrou o Item para Atualizacao ou Inclusao
			If nItem > 0
				If lInclui
					//Cria um Objeto para o Cabecalho ou para os Itens
					oECMData:Add(cNextKey, uColecao():New())
	
					//Atribui o Valor dos Campos do Fluig
					oECMData:GetValue(cNextKey):Add("cardid", oECMData:Elements(nItem):GetValue("cardid"))
					oECMData:GetValue(cNextKey):Add("companyid", oECMData:Elements(nItem):GetValue("companyid"))
					oECMData:GetValue(cNextKey):Add("documentid", oECMData:Elements(nItem):GetValue("documentid"))
					oECMData:GetValue(cNextKey):Add("id_armazem", (cTabQry)->CP_LOCAL)
					oECMData:GetValue(cNextKey):Add("id_atende", oECMData:Elements(nItem):GetValue("id_atende"))
					oECMData:GetValue(cNextKey):Add("id_ccusto", oECMData:Elements(nItem):GetValue("id_ccusto"))
					oECMData:GetValue(cNextKey):Add("id_dtnecessidade", oECMData:Elements(nItem):GetValue("id_dtnecessidade"))
					oECMData:GetValue(cNextKey):Add("id_dtvldlote", StoD((cTabQry)->D3_DTVALID))
					oECMData:GetValue(cNextKey):Add("id_encerrado", If((cTabQry)->CP_STATUS == "E", "1", "2"))
					oECMData:GetValue(cNextKey):Add("id_item", (cTabQry)->CP_ITEM)
					oECMData:GetValue(cNextKey):Add("id_lote", (cTabQry)->D3_LOTECTL)
					oECMData:GetValue(cNextKey):Add("id_nomeCentroCusto", oECMData:Elements(nItem):GetValue("id_nomeCentroCusto"))
					oECMData:GetValue(cNextKey):Add("id_nomeProduto", oECMData:Elements(nItem):GetValue("id_nomeProduto"))
					oECMData:GetValue(cNextKey):Add("id_observacoes", oECMData:Elements(nItem):GetValue("id_observacoes"))
					oECMData:GetValue(cNextKey):Add("id_produto", oECMData:Elements(nItem):GetValue("id_produto"))
					oECMData:GetValue(cNextKey):Add("id_qtdatend", (cTabQry)->D3_QUANT)
					oECMData:GetValue(cNextKey):Add("id_qtdatend_original", oECMData:Elements(nItem):GetValue("id_qtdatend_original"))
					oECMData:GetValue(cNextKey):Add("id_qtdbx", (cTabQry)->D3_QUANT)
					oECMData:GetValue(cNextKey):Add("id_qtdjentr", (cTabQry)->D3_QUANT)
					oECMData:GetValue(cNextKey):Add("id_quantidade", (cTabQry)->CP_QUANT)
					oECMData:GetValue(cNextKey):Add("id_um", oECMData:Elements(nItem):GetValue("id_um"))
					oECMData:GetValue(cNextKey):Add("masterid", oECMData:Elements(nItem):GetValue("masterid"))
					oECMData:GetValue(cNextKey):Add("tableid", oECMData:Elements(nItem):GetValue("tableid"))
					oECMData:GetValue(cNextKey):Add("version", oECMData:Elements(nItem):GetValue("version"))
					//oECMData:GetValue(cNextKey):Add("id_segum", oECMData:Elements(nItem):GetValue("id_segum"))
					//oECMData:GetValue(cNextKey):Add("id_qtdsegum", oECMData:Elements(nItem):GetValue(""))
	
					cNextKey := Soma1(cNextKey)
				Else
					oECMData:Elements(nItem):SetValue("id_encerrado", If((cTabQry)->CP_STATUS == "E", "1", "2"))
					oECMData:Elements(nItem):SetValue("id_qtdatend", (cTabQry)->D3_QUANT)
					oECMData:Elements(nItem):SetValue("id_qtdbx", (cTabQry)->D3_QUANT)
					oECMData:Elements(nItem):SetValue("id_qtdjentr", (cTabQry)->D3_QUANT)
					oECMData:Elements(nItem):SetValue("id_quantidade", (cTabQry)->CP_QUANT)
				EndIf
			EndIf

			(cTabQry)->(DbSkip())
		End
		
		If Select(cTabQry) > 0
			(cTabQry)->(DbCloseArea())
		EndIf
		
		RestArea(aArea)
		/*
		-----------------------------------------------------------------------------------------------------
			Reorganiza os Itens para Inclusao no Fluig
		-----------------------------------------------------------------------------------------------------	
		*/
		aOrder := {}

		For nIndice := 1 to oECMData:Count()
			If oECMData:GetKey(nIndice) <> "CAB"
				oItem		:= oECMData:Elements(nIndice)
				cCompara	:= oItem:GetValue("id_item") + oItem:GetValue("id_produto") + Space(TamSX3("B1_COD")[1] - Len(oItem:GetValue("id_produto"))) + oItem:GetValue("id_armazem") + oItem:GetValue("id_lote") + Space(TamSX3("D3_LOTECTL")[1] - Len(oItem:GetValue("id_lote")))

				Aadd(aOrder, {oECMData:GetKey(nIndice), cCompara})
			EndIf
		Next nIndice

		aSort(aOrder,,, {|x, y| x[02] < y[02]})

		For nIndice := 1 to oECMData:Count()
			If oECMData:GetKey(nIndice) <> "CAB"
				nPosNew := Ascan(aOrder, {|x| x[01] == oECMData:GetKey(nIndice)})
				
				oECMData:aColecao[nIndice][01] := "___" + AllTrim(Str(nPosNew))
			EndIf			
		Next nIndice
		/*
 		-----------------------------------------------------------------------------------------------------
 			Atualiza CardData do metodo SaveAndSendTask
 		-----------------------------------------------------------------------------------------------------	
 		*/
		For nIndice := 1 to oECMData:Count()
			For nCampo := 1 to oECMData:Elements(nIndice):Count()
				If oECMData:GetKey(nIndice) == "CAB"
					AddCard(@aCardData, oECMData:Elements(nIndice):GetKey(nCampo), oECMData:Elements(nIndice):Elements(nCampo))
				Else
					AddCard(@aCardData, oECMData:Elements(nIndice):GetKey(nCampo) + oECMData:GetKey(nIndice), oECMData:Elements(nIndice):Elements(nCampo))
				EndIf		
			Next nCampo
		Next nIndice

		//Atribui CardData
		For nX	:= 1 to Len(aCardData)
			Aadd(oFluig:oWSSaveAndSendTaskCardData:oWSitem, ECMWorkflowEngineServiceService_stringArray():New())
			
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
					xValor := AllTrim(Str(xValor))
				EndIf
				
				Aadd(aTail(oFluig:oWSSaveAndSendTaskCardData:oWSitem):cItem, xValor)
			Next nY
		Next nX
	EndIf
		
	If lRetorno
		oFluig:lCompleteTask					:= .F.
		oFluig:nChoosedState					:= nChoosedState
		oFluig:lManagerMode					:= .T.
		oFluig:nThreadSequence				:= 0
		
		If oFluig:saveAndSendTask()

			nPosErr := aScan(oFluig:oWSsaveAndSendTaskresult:oWsItem,{|x| "ERRO" $ x:cItem[1]})

			If nPosErr > 0
				cMsgErro 	+= "Erro durante a atualização da solicitação Fluig." + CRLF
				cMsgErro	+= "Descrição do erro: " + CRLF
				cMsgErro 	+= oFluig:oWSsaveAndSendTaskresult:oWsItem[nPosErr]:cItem[2] + CRLF
				lRetorno 	:= .F.
			Else
				cRetWs := "Solicitação Fluig atualizada com Sucesso." + CRLF
			EndIf
		Else
			cMsgErro := "Erro ao atualizar Solicitação Fluig " + cIdFluig + CRLF
			cMsgErro += GetWSCError()
			lRetorno := .F.
		EndIf
	EndIf

	Freeobj(oECMData)
	Freeobj(oFluig)

	RestArea(aAreaSCQ)
	RestArea(aAreaSCP)
	RestArea(aArea)

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} E06CHEST
Verifica se o Estorno da Baixa da Pre Requisicao pode ser executado

@author Guilherme Santos
@since 29/04/2016
@version P12
*/
//-------------------------------------------------------------------
User Function E06GETST(cFilSol, cNumSol)
	Local nRetorno 				:= 0
	Local oFluig					:= WSECMWorkflowEngineServiceService():New()

	DbSelectArea("SCP")
	DbSetOrder(1)		//CP_FILIAL, CP_NUM
	
	If SCP->(DbSeek(cFilSol + cNumSol))
		/*
		-----------------------------------------------------------------------------------------------------
			Atribuicao das Propriedades do Fluig para Conexao
		-----------------------------------------------------------------------------------------------------	
		*/
		oFluig:_Url 					:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
		oFluig:cUserName				:= SuperGetMV("MV_ECMUSER")
		oFluig:cPassword				:= SuperGetMV("MV_ECMPSW")
		oFluig:nCompanyID				:= Val(SuperGetMV("MV_ECMEMP"))
		oFluig:cUserID				:= SuperGetMV("MV_ECMMAT")
		oFluig:nProcessInstanceID	:= Val(SCP->CP_XIDFLG)
		oFluig:cProcessID				:= "SolicitacaoAoArmazem"
		oFluig:cColleagueID			:= SuperGetMV("MV_ECMMAT")
		oFluig:cComments				:= "Processo de Solicitacao ao Armazem"

		If oFluig:getAllActiveStates()
			If Len(oFluig:oWSgetAllActiveStatesStates:nItem) > 0
				nRetorno := oFluig:oWSgetAllActiveStatesStates:nItem[01]
			EndIf
		Else
			nRetorno := -1
		EndIf
	EndIf

Return nRetorno
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

	If Empty(xValor)
		Do Case
		Case "id_qtdatend" $ cCampo
			Aadd(aTemp, cCampo)
			Aadd(aTemp, "0")
			Aadd(aCardData, aClone(aTemp))
		EndCase
	Else
		Aadd(aTemp, cCampo)
		Aadd(aTemp, xValor)
		Aadd(aCardData, aClone(aTemp))
	EndIf

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} GetQuery
Retorna a Query para Selecao dos Dados da Movimentacao

@author Guilherme Santos
@since 04/05/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function GetQuery(cNumSol)

	Local cQuery := ""

	cQuery += "SELECT	SCP.CP_ITEM" + CRLF
	cQuery += ",		SCP.CP_PRODUTO" + CRLF
	cQuery += ",		SCP.CP_LOCAL" + CRLF
	cQuery += ",		SCP.CP_PREREQU" + CRLF
	cQuery += ",		SCP.CP_STATUS" + CRLF
	cQuery += ",		SCP.CP_QUANT" + CRLF
	cQuery += ",		SCP.CP_QUJE" + CRLF
	cQuery += ",		CASE WHEN SD3.D3_QUANT IS NULL THEN 0 ELSE SD3.D3_QUANT END D3_QUANT" + CRLF
	cQuery += ",		CASE WHEN SD3.D3_LOTECTL IS NULL THEN '' ELSE SD3.D3_LOTECTL END D3_LOTECTL" + CRLF
	cQuery += ",		CASE WHEN SD3.D3_DTVALID IS NULL THEN '' ELSE SD3.D3_DTVALID END D3_DTVALID" + CRLF

	cQuery += "FROM	" + RetSqlName("SCP") + " SCP" + CRLF

	cQuery += "		LEFT OUTER JOIN" + CRLF

	cQuery += "		(	SELECT	SD3.D3_FILIAL" + CRLF
	cQuery += "			,		SD3.D3_NUMSA" + CRLF
	cQuery += "			,		SD3.D3_ITEMSA" + CRLF
	cQuery += "			,		SD3.D3_COD" + CRLF
	cQuery += "			,		SD3.D3_LOCAL" + CRLF
	cQuery += "			,		SD3.D3_LOTECTL" + CRLF
	cQuery += "			,		SD3.D3_DTVALID" + CRLF
	cQuery += "			,		SUM(SD3.D3_QUANT) D3_QUANT" + CRLF

	cQuery += "			FROM	" + RetSqlName("SD3") + " SD3" + CRLF

	cQuery += "			WHERE	SD3.D3_FILIAL = '" + xFilial("SD3") + "'" + CRLF
	cQuery += "			AND		SD3.D3_NUMSA = '" + cNumSol + "'" + CRLF
	cQuery += "			AND		SD3.D3_ESTORNO = ''" + CRLF
	cQuery += "			AND		SD3.D_E_L_E_T_ = ''" + CRLF
	cQuery += "			GROUP BY SD3.D3_FILIAL, SD3.D3_NUMSA, SD3.D3_ITEMSA, SD3.D3_COD, SD3.D3_LOCAL, SD3.D3_LOTECTL, SD3.D3_DTVALID) SD3" + CRLF

	cQuery += "		ON	SCP.CP_FILIAL = SD3.D3_FILIAL" + CRLF
	cQuery += "		AND SCP.CP_PRODUTO = SD3.D3_COD" + CRLF
	cQuery += "		AND SCP.CP_LOCAL = SD3.D3_LOCAL" + CRLF
	cQuery += "		AND SCP.CP_NUM = SD3.D3_NUMSA" + CRLF
	cQuery += "		AND	SCP.CP_ITEM = SD3.D3_ITEMSA" + CRLF

	cQuery += "WHERE	SCP.CP_FILIAL = '" + xFilial("SCP") + "'" + CRLF
	cQuery += "AND	SCP.CP_NUM = '" + cNumSol + "'" + CRLF
	cQuery += "AND	SCP.D_E_L_E_T_ = ''" + CRLF
	
	cQuery := ChangeQuery(cQuery)

Return cQuery
//-------------------------------------------------------------------
/*{Protheus.doc} E06VLDBX
Valida a Baixa dos Itens da Solicitacao

@author Guilherme Santos
@since 19/05/2016
@version P12
*/
//-------------------------------------------------------------------
User Function E06VLDBX(cNumSol, aColsBxa, cMsgErro)
	Local oFluig		:= WSECMWorkflowEngineServiceService():New()

	Local oECMData	:= uColecao():New()
	Local oItem		:= NIL
	Local cCompara	:= ""
	Local nItem		:= 0
	Local nIndice		:= 0
	Local nCols		:= 0
	Local cItem		:= ""
	Local cCampo		:= NIL
	Local xValor		:= NIL
	Local cChave		:= ""
	Local lRetorno	:= .T.
	Local cIdFluig	:= Posicione("SCP", 1, xFilial("SCP") + cNumSol, "CP_XIDFLG")
	/*
	-----------------------------------------------------------------------------------------------------
		Atribuicao das Propriedades do Fluig para Conexao
	-----------------------------------------------------------------------------------------------------	
	*/
	If lRetorno
		oFluig:_Url 					:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
		oFluig:cUserName				:= SuperGetMV("MV_ECMUSER")
		oFluig:cPassword				:= SuperGetMV("MV_ECMPSW")
		oFluig:nCompanyID				:= Val(SuperGetMV("MV_ECMEMP"))
		oFluig:cUserID				:= SuperGetMV("MV_ECMMAT")
		oFluig:nProcessInstanceID	:= Val(cIdFluig)
		oFluig:cProcessID				:= "SolicitacaoAoArmazem"
		oFluig:cColleagueID			:= SuperGetMV("MV_ECMMAT")
		oFluig:cComments				:= "Processo de Solicitacao ao Armazem"
		oFluig:nThreadSequence		:= 0

		If oFluig:getInstanceCardData()
			For nItem := 1 to Len(oFluig:oWSGetInstanceCardDataCardData:oWsItem)
				cCampo		:= oFluig:oWSGetInstanceCardDataCardData:oWsItem[nItem]:cItem[1]
				xValor		:= oFluig:oWSGetInstanceCardDataCardData:oWsItem[nItem]:cItem[2]
				cChave		:= ""

				If "___" $ cCampo
					cChave		:= Substr(cCampo, At("___", cCampo), Len(cCampo))
					cCampo		:= StrTran(cCampo, cChave, "")
				Else
					cChave		:= "CAB"
				EndIf

				//Cria um Objeto para o Cabecalho ou para os Itens
				If !oECMData:Contains(cChave)
					oECMData:Add(cChave, uColecao():New())
				EndIf

				oECMData:GetValue(cChave):Add(cCampo, xValor)
			Next nItem
		Else
			lRetorno := .F.
			cMsgErro := "Erro ao obter CardData da solicitação Fluig " + cIdFluig
		EndIf
	EndIf
	/*
	-----------------------------------------------------------------------------------------------------
		Formato Array aColsBxa
	-----------------------------------------------------------------------------------------------------	
		01 - Marca de selecao
		02 - Numero da SA
		03 - Item da SA
		04 - Produto
		05 - Descricao do Produto
		06 - Armazem
		07 - UM
		08 - Qtd. a Requisitar (Formato Caracter)
		09 - Qtd. a Requisitar
		00 - Centro de Custo
		11 - 2a.UM
		12 - Qtd. 2a.UM
		13 - Ordem de Producao
		14 - Conta Contabil
		15 - Item Contabil
		16 - Classe Valor
		17 - Projeto
		18 - Nr. da OS
		19 - Tarefa
		20 - Alias Walk-Thru
		21 - Recno Walk-Thru
	*/

	If lRetorno
		lNAtende	:= .T.
	
		For nCols := 1 to Len(aColsBxa)
			nItem 	:= 0
			cItem	:= ""
	
			If aColsBxa[nCols][01]
	
				For nIndice := 1 to oECMData:Count()
					If oECMData:GetKey(nIndice) <> "CAB"
						oItem		:= oECMData:Elements(nIndice)
						cCompara	:= oItem:GetValue("id_item") + oItem:GetValue("id_produto") + Space(TamSX3("B1_COD")[1] - Len(oItem:GetValue("id_produto"))) + oItem:GetValue("id_armazem")
	
						If cCompara == aColsBxa[nCols][03] + aColsBxa[nCols][04] + aColsBxa[nCols][06]
							nItem		:= nIndice
							lNAtende	:= oItem:GetValue("id_atende") == "N" .AND. aColsBxa[nCols][09] < Val(oItem:GetValue("id_quantidade"))
							cItem		:= oItem:GetValue("id_item")
						EndIf
					EndIf
				Next nIndice
	
				If nItem > 0 .AND. lNAtende
					lRetorno := .F.
					cMsgErro := "O item " + cItem + " está marcado como não atende e não pode ser baixado pelo Protheus com Quantidades Menores que a Solicitação do Fluig."
				EndIf
			EndIf
		Next nI 
	EndIf

Return lRetorno
