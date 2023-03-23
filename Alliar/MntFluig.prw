#Include 'Protheus.ch'

//--------------------------------------------------------------------
/*/{Protheus.doc} MNTFLUIG
Realiza o processo de integração.

@author Larissa Thaís de Farias
@since 07/12/2015
@return Nil
/*/
//--------------------------------------------------------------------
User Function MNTFLUIG(aValores, cXIdFluig, lWS)
	Local aRet          := {}
	Local cComment      := "Atualização dos dados da Solicitação de Serviço gerada pelo Protheus."
	Local oFluig
	Local nI := 1
	Local nPos := 0
	Local nCompanyID		:= Val(GetMv("MV_ECMEMP"))
	Local cUserID			:= GetMv("MV_ECMMAT")
	Local nChoosedState		:= 20 //Proximo passo
	Local cUserName			:= GetMv("MV_ECMUSER")
	Local cPassword			:= GetMv("MV_ECMPSW")
	Local cColleagueID		:= GetMv("MV_ECMMAT")
	Local aCardData			:= {}
	Local x,y
	
	//Instancia WebService Client Fluig
	oFluig := WSECMWorkflowEngineServiceService():New()
	
	
	oFluig:cUserName			:= cUserName
	oFluig:cPassword			:= cPassword
	oFluig:nCompanyID			:= nCompanyID
	oFluig:cUserID				:= cUserName
	oFluig:nProcessInstanceID	:= Val(cXIdFluig)
	oFluig:cColleagueID			:= cColleagueID
	oFluig:cUserID				:= cUserID
	oFluig:cComments			:= "Atualização dos dados da Solicitação de Serviço gerada pelo Protheus."
	oFluig:_URL				:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	If oFluig:getInstanceCardData()
	
		For nI := 1 To Len(oFluig:oWSGetInstanceCardDataCardData:oWsItem)
			
			nPos := aScan(aValores, { |x| UPPER(x[1]) == UPPER(oFluig:oWSGetInstanceCardDataCardData:oWsItem[nI]:CITEM[1])})
			
			If  nPos > 0
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[nI]:CITEM[2] := aValores[nPos][2]
			EndIf
					
		Next x
		
		lOk := .T.
	Else
		MsgStop("Erro ao obter CardData da solicitação Fluig " + cXIdFluig)
		lOk := .F.
	EndIf
			
	If lOk
	
		oFluig:lCompleteTask	:= .T.
		oFLuig:nChoosedState	:= nChoosedState
		oFluig:lManagerMode		:= .F.
		oFluig:nThreadSequence	:= 0
		oFluig:oWSSaveAndSendTaskCardData := oFluig:oWSGetInstanceCardDataCardData //AtualizaCardData do método SaveAndSendTask
		
		If oFluig:saveAndSendTask()
			
			nPos := aScan(oFluig:oWSsaveAndSendTaskresult:oWsItem,{|x| "ERRO" $ x:cItem[1]})
			If nPos > 0
				Alert("Erro ao atualizar a Solicitação de Serviço com o Fluig: " + oFluig:oWSsaveAndSendTaskresult:oWsItem[nPos]:cItem[2])
			Else
				Conout("Solicitação de Serviço atualizada com sucesso no Fluig! (" + AllTrim(cXIdFluig) + ")")
			EndIf
			
		Else
			nPos := aScan(oFluig:oWSsaveAndSendTaskresult:oWsItem,{|x| "ERRO" $ x:cItem[1]})
			If nPos > 0
				Alert("Erro ao atualizar a Solicitação de Serviço com o Fluig: " + oFluig:oWSsaveAndSendTaskresult:oWsItem[nPos]:cItem[2])
			Else
				if !Empty(GetWSCError())
					Alert(GetWSCError())
				endif
				Alert("Erro ao atualizar a Solicitação de Serviço com o Fluig: " + cXIdFluig)
			Endif
		EndIf
	endif
	
Return .T.

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
	Local cLog	:= ""

	cLog += "aCardData | cCampo: " + cCampo + "|"
	cLog += "xValor: "
	cLog += If(ValType(xValor) == "D", DtoC(xValor), "")
	cLog += If(ValType(xValor) == "N", Val(xValor), "")
	cLog += If(ValType(xValor) == "C", xValor, "")
	cLog += "|"

	Aadd(aTemp, cCampo)
	Aadd(aTemp, xValor)
	Aadd(aCardData, aClone(aTemp))
Return NIL

//--------------------------------------------------------------------
/*/{Protheus.doc} MNTA280GOC
Gera a String contendo as informações de ocorrências da OS

@author Larissa Thaís de Farias
@since 07/12/2015
@return array
/*/
//--------------------------------------------------------------------
User Function MNTA280G(cOrdem)
	
	Local aValores := {}
	Local cT8Nome  := ''
	Local cT8Tipo  := ''
	Local cCausa   := ''
	Local cProblema := ''
	Local cSolucao := ''
	
	DbSelectArea("STN")
	DbSetOrder(01)
	
	IF DbSeek(xFILIAL("STN") + cOrdem)
		
		While !EoF() .And. STN->TN_ORDEM == cOrdem
			
			DbSelectArea("ST8")
			//T8_FILIAL+T8_CODOCOR+T8_TIPO
			IF DbSeek(xFILIAL("ST8") + STN->TN_CODOCOR + "P")
				cProblema += AllTrim( if(!empty(cT8Nome), "; ", "") + ST8->T8_NOME )
//				cT8Tipo += if(!empty(cT8Tipo), "; ", "") + "Problema"
			endif
			
			IF DbSeek(xFILIAL("ST8") + STN->TN_CAUSA + "C")
				cCausa += AllTrim( if(!empty(cT8Nome), "; ", "") + ST8->T8_NOME )
//				cT8Tipo += if(!empty(cT8Tipo), "; ", "") + "Causa"
			endif
			
			IF DbSeek(xFILIAL("ST8") + STN->TN_SOLUCAO + "S")
				cSolucao += AllTrim( if(!empty(cT8Nome), "; ", "") + ST8->T8_NOME )
//				cT8Tipo += if(!empty(cT8Tipo), "; ", "") + "Solução"
			endif
			
			DbSelectArea("STN")
			dbSkip()
			
		end
		
//		aADD(aValores, {"T8_NOME",cT8Nome})
//		aADD(aValores, {"T8_TIPO",cT8Tipo})
		
		aADD(aValores, {"T8_TIPO",cCausa})
		aADD(aValores, {"T8_NOME",cProblema})
		aADD(aValores, {"solucao",cSolucao})
		
	ENDIF
	
Return aValores
