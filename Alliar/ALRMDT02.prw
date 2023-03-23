#Include "Totvs.ch"
#Include "TopConn.ch"
//#INCLUDE "FILEIO.CH"  
#INCLUDE "FWMVCDEF.CH"


/*log auxiliar para debug de performance em fase de testes
static Function LogProcesso(cTxt)
Local cFIleOpen :=   "c:\temp\bla.txt"   //SuperGetMV("ES_CIRIMP",, '') // "c:\temp\log_val.txt"  //SuperGetMV("ES_DITIMP",, '') // "c:\cargaRH\" + "log_sra.txt"
Local nHandleCr := 0
Default cMAlias := ''        

If !Empty(cFIleOpen)
	nHandleCr := fopen( cFileOpen  , FO_READWRITE + FO_SHARED )

	If nHandleCr  == -1
		nHandleCr := FCreate(cFileOpen)//esta função cria o arquivo automaticamente sempre no protheus_data\system
	Else                 
		fseek(nHandleCr, 0, FS_END)
	EndIf		
		   
	FWrite(nHandleCr, cTxt + Chr(13) + CHr(10))
		
	FClose(nHandleCr) 
EndIf

return*/                         



/*/{Protheus.doc} ALRMDT02

@author Jorge Heitor
@since 30/12/2015
@version 12.001.7
@description Rotina chamada pelo Ponto de Entrada na Gravação dos Mandatos da CIPA (Após geração das pendências na tabela TNW)
@param nOpc , 3 -> Inclusão , 5 -> Exclusão
@obs Específico ALLIAR - Abertura CIPA

/*/
User Function ALRMDT02(nOpc)

	Local cMsgErro := ''
	Local nPosErr := 0
	Local aArea				:= GetArea()
	Local oFluig
	Local oProcess
	Local nCompanyID		:= Val(GetMv("MV_ECMEMP"))
	Local cUserID			:= GetMv("MV_ECMMAT")
	Local cProcessID		:= "AberturaCIPA" //Padrão para o proceso
	Local nChoosedState		:= 22 //Proximo passo após a inclusao de mandato
	Local cUserName			:= GetMv("MV_ECMUSER")
	Local cPassword			:= GetMv("MV_ECMPSW")
	Local cColleagueID		:= GetMv("MV_ECMMAT")
	Local aCardData			:= {}
	Local x,y
	Local cIdFluig			:= M->TNN_XIDFLG
	Local cMandato			:= M->TNN_MANDAT
	Local cTipo				:= M->TNN_XTIPO //1 = Constituição | 2 = Designação
	Local dEdital
	Local dConvoc
	Local dCarta
	Local dIInscr
	Local dEInscr
	Local dEleicao
	Local dCurso
	Local dConvenc
	Local dComprovante
	Local dEnvCSC
	Local lOk				:= .F.
	Local cQuery			:= ""
	Local cStrXml
//	alert ("1 saveAndSend")
	//LogProcesso ("Inicio ALRMDT02 " + Time())
	//Faz a Leitura das datas quando é Constituição
	If cTipo == "1" //Constituição

	    //alert ("Tipo 1")
		dEdital			:= PegaData(cMandato,"2") //1. Edital de Convocação ate
		dConvoc			:= PegaData(cMandato,"3") //2. Convocação de Eleição ate
		dCarta			:= PegaData(cMandato,"4") //3. Enviar Carta ao Sindicato informando o inicio do processo eleitoral ate
		dIInscr			:= PegaData(cMandato,"5") //4. Iniciar as Inscrições dos candidatos de
		dEInscr			:= PegaData(cMandato,"7") //5. Iniciar as Inscrições dos candidatos ate
		dEleicao		:= PegaData(cMandato,"8") //6. Realizar a eleição dia
		dCurso			:= PegaData(cMandato,"C"/*a pedido de Aleluia mandar C também*/) //7. realizar curso para Cipeiro com empresa devidamente autorizada a conceder curso para Cipistas ate
		dConvenc		:= PegaData(cMandato,"B") //8. Verificar Convenção coletiva se ha obrigatoriedade do envio da documentação para Cipa ate
		//dComprovante	:= PegaData(cMandato,"Z") //9. Enviar ao Sesmt/CSC comprovante de curso da Cipa ate
		dEnvCSC			:= PegaData(cMandato,"C") //10. Enviar ao Sesmt/CSC a primeira Ata de instalação e posse ate
		
	ElseIf cTipo == "2" //Designação
	    //alert ("Tipo 2")
		dCurso := PegaData(cMandato,"C"/*a pedido de Aleluia mandar C também*/)
		
		
		dEnvCSC := PegaData(cMandato,"C")
		//dCurso := PegaData(cMandato,"A")
		
		
	EndIf
	
	//Baixa Pendencias não utilizadas no Processo
	If cTipo == "1"
	
		cWhere := " AND TNW_TIPO IN ('D') "
	
	Else
	
		cWhere := " AND TNW_TIPO NOT IN ('A','C') "
		
	EndIf
	
	cQuery := "SELECT R_E_C_N_O_ REG FROM " + RetSqlName("TNW") + " WHERE TNW_CODIGO = '" + cMandato + "' AND D_E_L_E_T_= ' ' AND TNW_FILIAL = '" + xFilial("TNW") + "' AND TNW_USUFIM = ' ' AND D_E_L_E_T_ = '' " + cWhere
	
	If Select("TREG") > 0
	
		TREG->(dbCloseArea())
		
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	
	TcQuery cQuery Alias "TREG" NEW
	
	dbSelectArea("TREG") 
	While !TREG->(Eof())
	
		dbSelectArea("TNW")
		dbGoTo(TREG->REG)
		RecLock("TNW",.F.)
		
			TNW->TNW_USUFIM := "Administrador"
			
		MsUnlock()
		
		TREG->(dbSkip())
		
	End
	
	
	cStrXml := getmv("MV_ECMURL")
	cStrXml += "ECMWorkflowEngineService"
	
//	LogProcesso ("Parte A - inicio " + Time() + " " + cUserName)
	
	//Instancia WebService Client Fluig
	oFluig := WSECMWorkflowEngineServiceService():New()
	oFluig:_Url := cStrXml//"http://alliartst.fluig.com:8080/webdesk/ECMDatasetService"
	
	
	oFluig:cUserName			:= cUserName
	oFluig:cPassword			:= cPassword
	oFluig:nCompanyID			:= nCompanyID
	oFluig:cUserID				:= cUserName
	oFluig:nProcessInstanceID	:= Val(cIdFluig)
	//oFluig:cProcessID		:= cProcessID
	//oFLuig:nChoosedState	:= nChoosedState
	oFluig:cColleagueID		:= cColleagueID
	oFluig:cUserID			:= cUserID
	//oFluig:lCompleteTask	:= .F.
	//oFluig:lManagerMode		:= .T.
	oFluig:cComments		:= "Processo de Abertura CIPA"
	
//	LogProcesso ("Parte A - cardData antes" + Time() )
	
	If oFluig:getInstanceCardData()
	
//	LogProcesso ("Parte A - cardData apos" + Time() )
	
		//Obtem data de abertura da solicitação (Desativado pois é para ser considerada a data de Posse ou Inicio do Mandato)
		/*
		For x := 1 To Len(oFluig:oWSGetInstanceCardDataCardData:oWsItem)
		
			If oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataAbertura"
			
				dDataAbertura := oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2]
				
			EndIf
			
		Next x
		

		If Empty(dDataAbertura)
		
			MsgStop("Campo 'Data de Abertura' da solicitação não encontrado.")
			
		EndIf
		*/
		
		If cTipo == "1"				
			
			dComprovante := dEnvCSC + 30
			
		EndIf
	
		For x := 1 To Len(oFluig:oWSGetInstanceCardDataCardData:oWsItem)
		
			If  oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataEdital" .And. cTipo == "1"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dEdital)
				//ALert ("Data Edital : " + DtoC(dEdital))
			
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataConvocacao" .And. cTipo == "1"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dConvoc)
				//Alert ("Data convocacao: " + DtoC(dConvoc))
			
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataCarta" .And. cTipo == "1"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dCarta)
				//Alert ("Data carta: " + DtoC(dCarta))
			
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataInscricoesIni" .And. cTipo == "1"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dIInscr)
				//Alert ("Data inscricao: " + DtoC(dIInscr))
			
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataInscricoesFim" .And. cTipo == "1"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dEInscr)
				//Alert (" DtoC(dEInscr): " +  DtoC(dEInscr))
			
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataEleicao" .And. cTipo == "1"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dEleicao)
				//ALert ("DtoC(dEleicao): " + DtoC(dEleicao))
			
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataCurso" .And. cTipo == "1"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dCurso)
				//Alert ("DtoC(dCurso): " + DtoC(dCurso))
			
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataDocumentacao" .And. cTipo == "1"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dConvenc)
				//Alert ("DtoC(dConvenc): " + DtoC(dConvenc))
			
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataComprovante" .And. cTipo == "1"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dComprovante)
				//Alert (" DtoC(dComprovante): " +  DtoC(dComprovante))
			
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataAta" .And. cTipo == "1"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dEnvCSC)
				//Alert ("DtoC(dEnvCSC): " + DtoC(dEnvCSC))
			
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataCursoDesignado" .And. cTipo == "2"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dCurso)
				//Alert ("DtoC(dCurso): " + DtoC(dCurso))
				
			ElseIf oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1] == "dataComprovanteDesignado" .And. cTipo == "2"
			
				oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2] := DtoC(dEnvCSC)
				//Alert ("DtoC(dEnvCSC): " + DtoC(dEnvCSC))

			EndIf
					
		Next x
		
		lOk := .T.
		
	Else
	 //  LogProcesso ("Parte A - cardData  NAO ENTROU" + Time() )
	   
	   	If !CipaPrimeira()
	   		MsgStop("Erro ao obter CardData da solicitação Fluig " + cIdFluig)
		EndIf
		lOk := .F.
		
	EndIf
		
	If lOk
		
	//	LogProcesso ("Parte B  inicio " + Time() )
		
		oFluig:lCompleteTask	:= .T.
		oFLuig:nChoosedState	:= nChoosedState
		oFluig:lManagerMode		:= .F.//forçar false pois nem sempre o ususario sera administrador no fluig!!!!
		oFluig:nThreadSequence	:= 0
		oFluig:oWSSaveAndSendTaskCardData := oFluig:oWSGetInstanceCardDataCardData //AtualizaCardData do método SaveAndSendTask
		
	//	LogProcesso ("Parte B  antes " + Time() )
		
		If oFluig:saveAndSendTask()
		
			nPosErr := aScan(oFluig:oWSsaveAndSendTaskresult:oWsItem,{|x| "ERRO" $ x:cItem[1]})

			If nPosErr > 0
			
				cMsgErro 	:= "Erro durante a atualização da solicitação Fluig." + CRLF
				cMsgErro	+= "Descrição do erro: " + CRLF
				cMsgErro 	+= oFluig:oWSsaveAndSendTaskresult:oWsItem[nPosErr]:cItem[2] + CRLF
				Alert ("Problemas: " + cMsgErro)
			else	
				Alert("Solicitação Fluig " + cIdFluig + " atualizada com sucesso!")
			endif
			
		Else
			//LogProcesso ("Parte B  Else " + Time() )
		
			Alert("Erro ao atualizar Solicitação Fluig " + cIdFluig)
			
		EndIf
		
		//LogProcesso ("Parte B  Fim " + Time() )
		
	EndIf
	
Return Nil
	
/*/{Protheus.doc} ALRMDT2I

@author Jorge Heitor
@since 04/01/2016
@version 12.001.7
@description Inicializa campo de Id Fluig (Tabela TNN) com a pendencia de Inclusão de Mandato mais recente (Fluig) para a filial
@obs Específico ALLIAR - Abertura CIPA

/*/
User Function ALRMDT2I(cCampo)
	
	Local cRet			:= ""
	Local oDataset		
	Local lTemFluig		:= .F.
	Local nCampo		:= 0
	Local cIdFluig		:= ""
	Local cEscolhaCipa	:= ""
	Local nOpc
	Local cStr
	//alert ("2")
	//LogProcesso ("Parte ALRMDT2I " + Time() )
		
	oDataset		:= WSECMDatasetServiceService():New()
	
	//Parametros padrão de DataSet
	oDataset:nCompanyId		:= Val(GetMv("MV_ECMEMP"))
	oDataset:cUserName		:= GetMv("MV_ECMUSER")
	oDataset:cPassword		:= GetMv("MV_ECMPSW")
	
	cStr := getmv("MV_ECMURL")
	cStr += "ECMDatasetService" //"ECMDataService"
	
	oDataset:_Url := cStr//"http://alliartst.fluig.com:8080/webdesk/ECMDatasetService"
	
	If cCampo == "TNN_XIDFLG"
//	    LogProcesso ("Parte ALRMDT2I  1" + Time() )
		
		cIdFluig := IdFluig(oDataset)
		
		cRet := cIdFluig
//		LogProcesso ("Parte ALRMDT2I  1 fim" + Time() )
		
	ElseIf cCampo == "TNN_XTIPO"
//		LogProcesso ("Parte ALRMDT2I  2" + Time() )
		
		cIdFluig := IdFluig(oDataset)
		oDataset := Nil
		cEscolhaCipa := EscolhaCipa(cIdFluig)
		cRet := cEscolhaCipa
//		LogProcesso ("Parte ALRMDT2I  2 fim  " + Time()  + " ESCOLHIDO: '" + cRet + "'")
		
	ElseIf cCampo == "TNN_DTINIC" .Or. cCampo == "TNN_DTTERM"
//		LogProcesso ("Parte ALRMDT2I  3" + Time() )
		
		cIdFluig := IdFluig(oDataset)
		oDataset := Nil
		nOpc := Iif(cCampo == "TNN_DTINIC",1,2)
		
		cRet :=  PegaDtIF(cIdFluig,nOpc)
//		LogProcesso ("Parte ALRMDT2I  3 fim" + Time() )
		
	EndIf
	
Return cRet

/*/{Protheus.doc} PegaData

@author Jorge Heitor
@since 19/01/2016
@version 12.001.7
@description Função que obtem as datas das Pendências CIPA (tabela TNW) para preenchimento do Fluig
@obs Específico ALLIAR - Abertura CIPA

/*/
Static Function PegaData(cMandato,cTipo)

	Local dRet	:= Date()
	Local cQuery	:= ""
	Local lQuery	:= .T.
	Local aArea		:= GetArea()
	//alert ("3")
	//LogProcesso ("PegaData inic" + Time() )
		
		
	cQuery	:= "SELECT TNW_DTINIC AS DATAEV FROM " + RetSqlName("TNW") + " (NOLOCK) WHERE TNW_CODIGO = '" + cMandato + "' AND TNW_TIPO = '" + cTipo + "' AND TNW_FILIAL = '" + xFilial("TNW") + "'  AND TNW_USUFIM = ' ' AND D_E_L_E_T_ = '' "
	//alert (cquery)
	If lQuery
		
		If Select("TTNW") > 0
			TTNW->(dbCloseArea())
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		
		TcQuery cQuery Alias "TTNW" NEW
		
		dbSelectArea("TTNW")
		If !Eof()
		
			While !TTNW->(Eof())
				//alert ('localizado:')
				dRet := StoD(TTNW->DATAEV)
				
				TTNW->(dbSkip())
			
			End
			
	//	Else
		//	MsgStop("Erro ao encontrar a data do registro tipo " + cTipo + " para o Mandato " + cMandato + ".")
			
		EndIf
		
		TTNW->(dbCloseArea())
	
	EndIf
	
	
	RestArea(aArea)
//	LogProcesso ("PegaData fim" + Time() )
	
Return dRet

/*/{Protheus.doc} ExistFluig

@author Jorge Heitor
@since /01/2016
@version 12.001.7
@description Função que retorna a existencia de um ID Fluig em um registro da tabela TNN
@obs Específico ALLIAR - Abertura CIPA

/*/
Static Function ExistFluig(cIdFluig)
 
	Local lRet		:= .F. 
	Local aArea		:= GetArea()
	Local cQuery	:= " SELECT COUNT(*) QTD FROM " + RetSqlName("TNN") + " WHERE TNN_XIDFLG = '" + PadR(cIdFluig,TamSX3("TNN_XIDFLG")[1]) + "' AND D_E_L_E_T_ = ' ' "
	
	If Select("TNNF") > 0 ; TNNF->(dbCloseArea()) ; EndIf
	//alert ("4")
	cQuery := ChangeQuery(cQuery)
	
	TcQuery cQuery Alias "TNNF" NEW
	
	dbSelectArea("TNNF")
	
	If TNNF->QTD > 0
	
		lRet := .T.
		
	EndIf
	
	TNNF->(dbCloseArea())
	
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} IdFluig
(long_description)
@type function
@author Jorge Heitor
@since 04/02/2016
@version 1.0
@return string, cRet
/*/
Static Function IdFluig(oDataset)

	Local cRet	:= ""
	Local lTemFluig		:= .F.
	Local nPosRes := 0
	//alert ("10")
	//LogProcesso ("IdFluig 1  " + Time() )
	
	oDataset:cName := "ds_wk_cipa"
	//oDataset:oWsGetDatasetConstraints:oWsItem := {}
	
	aAdd(oDataset:oWsGetDatasetConstraints:oWsItem,ECMDatasetServiceService_searchConstraintDto():NEW())
	aTail(oDataset:oWsGetDatasetConstraints:oWsItem):ccontraintType := "MUST"
	aTail(oDataset:oWsGetDatasetConstraints:oWsItem):cfieldName := "M0_CODIGO"
	aTail(oDataset:oWsGetDatasetConstraints:oWsItem):cinitialValue := SM0->M0_CODIGO
	aTail(oDataset:oWsGetDatasetConstraints:oWsItem):cfinalValue := SM0->M0_CODIGO
	aTail(oDataset:oWsGetDatasetConstraints:oWsItem):llikeSearch := .F.
	
	aAdd(oDataset:oWsGetDatasetConstraints:oWsItem,ECMDatasetServiceService_searchConstraintDto():NEW())
	aTail(oDataset:oWsGetDatasetConstraints:oWsItem):ccontraintType := "MUST"
	aTail(oDataset:oWsGetDatasetConstraints:oWsItem):cfieldName := "M0_CODFIL"
	aTail(oDataset:oWsGetDatasetConstraints:oWsItem):cinitialValue := FWxFilial("TNN")
	aTail(oDataset:oWsGetDatasetConstraints:oWsItem):cfinalValue := FWxFilial("TNN")
	aTail(oDataset:oWsGetDatasetConstraints:oWsItem):llikeSearch := .F.
	
//	LogProcesso ("IdFluig 2  " + Time() )
	
	If oDataset:getDataset()
//		LogProcesso ("IdFluig 3  " + Time() )
	
		nPosRes := Len(oDataSet:oWSGetDataSetDataSet:oWSValues)		

//		LogProcesso ("IdFluig 4  " + Time() )
	
		If nPosRes > 0
//			LogProcesso ("IdFluig 5  " + Time() )
	
			If AllTrim(oDataSet:oWSGetDataSetDataSet:oWSValues[nPosRes]:oWsValue[1]) == "columns"
			
				If !CipaPrimeira()
					MsgStop("Consulta retorna resultado em Branco. Não localizado nenhuma solicitação de CIPA no Fluig!")
				EndIf
				
				cRet := ""
				lTemFluig := .T.
			Else
				cRet := oDataSet:oWSGetDataSetDataSet:oWSValues[nPosRes]:oWsValue[1]:Text
				
				//cRet := aTail(oDataset:OWSGETDATASETDATASET:OWSVALUES):oWsValue[1]:Text
											
				If !Empty(cRet) .And. ExistFluig(cRet)
					
					//------->MsgStop("Mandato já incluído para a atividade Fluig " + cRet + ", encontrada para utilização.")
					cRet := ""
					lTemFluig := .T.
					
				EndIf
			EndIf
//			LogProcesso ("IdFluig 6  " + Time() )
	
		Else
			MsgStop("Não-conformidade na comunicação com o Fluig para obtenção da Lista de ID´s")
			cRet := ""
			lTemFluig := .T.
		EndIf
	Else
	
		MsgStop("Não-conformidade na comunicação com o Fluig para obtenção da Atividade relacionada ao Mandato!")
		
	EndIf
//	LogProcesso ("IdFluig 7  " + Time() )
	
	If Empty(cRet) .And. !lTemFluig
	
		MsgStop("Atividade Fluig com pendência de Inclusão de Mandato não encontrada!")
		cRet := Space(TamSX3("TNN_XIDFLG")[1])
		
	EndIf
	
//	LogProcesso ("IdFluig 8  " + Time() )
	
Return cRet	
	
	
/*/{Protheus.doc} EscolhaCipa
(long_description)
@type function
@author Jorge Heitor
@since 04/02/2016
@version 1.0
@return string, cRet
/*/
Static Function EscolhaCipa(cIdFluig)

	Local cRet				:= " "
	//Local oDSx				:= WSECMDatasetServiceService():New()
	//Local aArea				:= GetArea()
	Local oFluig
	Local nCompanyID		:= Val(GetMv("MV_ECMEMP"))
	Local cUserID			:= GetMv("MV_ECMMAT")
	Local cProcessID		:= "AberturaCIPA" //Padrão para o proceso
	Local nChoosedState		:= 22 //Proximo passo após a inclusao de mandato
	Local cUserName			:= GetMv("MV_ECMUSER")
	Local cPassword			:= GetMv("MV_ECMPSW")
	Local cColleagueID		:= GetMv("MV_ECMMAT")
	Local x
	Local cStr2Xml := getmv("MV_ECMURL")
	
	
//	LogProcesso ("EscolhaCipa 1  " + Time() )
	
	cStr2Xml += "ECMWorkflowEngineService"
	
	//Novo padrão: Ler diretamente do CardData
	oFluig := WSECMWorkflowEngineServiceService():New()
		
	
	oFluig:cUserName			:= cUserName
	oFluig:cPassword			:= cPassword
	oFluig:nCompanyID			:= nCompanyID
	oFluig:cUserID				:= cUserID
	oFluig:nProcessInstanceID	:= Val(cIdFluig)
	oFluig:cColleagueID			:= cColleagueID
	oFluig:cComments			:= "Processo de Abertura CIPA"
	
	oFluig:_Url := cStr2Xml//"http://alliartst.fluig.com:8080/webdesk/ECMDatasetService"
	
	/*
	oFluig:cUserName			:= cUserName
	oFluig:cPassword			:= cPassword
	oFluig:nCompanyID			:= nCompanyID
	oFluig:cUserID				:= cUserName
	oFluig:nProcessInstanceID	:= Val(cIdFluig)
	
	oFluig:cColleagueID		:= cColleagueID
	oFluig:cUserID			:= cUserID
	oFluig:cComments		:= "Processo de Abertura CIPA"
	
	*/
	
//	LogProcesso ("EscolhaCipa 2  " + Time() )
	
	If oFluig:getInstanceCardData()
	
//	LogProcesso ("EscolhaCipa 3  " + Time() )
	
		//Obtem data de abertura da solicitação
		For x := 1 To Len(oFluig:oWSGetInstanceCardDataCardData:oWsItem)
		
			If Upper(oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[1]) == "ESCOLHACIPA"
			
				cRet := oFluig:oWSGetInstanceCardDataCardData:oWsItem[x]:CITEM[2]
				Exit
				
			EndIf
			
		Next x
	//	LogProcesso ("EscolhaCipa 4  "  + Time() )
	
	Else
	//LogProcesso ("EscolhaCipa 5  " + Time() )
	
		//--->	MsgStop("Falha na obtenção do campo 'Tipo de Mandato'")
		cRet := " "
	EndIf
	
	//RestArea(aArea)
	
	//Elimina objeto Fluig
	oFluig := Nil
//	LogProcesso ("EscolhaCipa 6  " + Time() )
	
Return cRet
	
/*/{Protheus.doc} PegaDtInic

@author Jorge Heitor
@since 11/03/2016
@version 12.001.7
@description Obtém data de Inicio para o Proximo Mandato que está sendo incluído
@param cIdFluig, ID Fluig para pesquisa de Pendencia na TNW e posteriormente Mandato anterior na TNN
@param nOpc, 1 = Inicial e 2 = Final
@obs Específico ALLIAR - Abertura CIPA

/*/
Static Function PegaDtIF(cIdFluig,nOpc)

	Local dTemp
	Local dRet
	Local cQuery
	
	cQuery := "SELECT " + Iif(nOpc == 1,"TNN_DTINIC","TNN_DTTERM") + " DRET FROM " + RetSqlName("TNN") + " TNN "
	cQuery += " INNER JOIN " + RetSqlName("TNW") + " TNW ON "
	cQuery += " TNN.TNN_MANDAT = TNW.TNW_CODIGO "
	cQuery += " AND TNW.TNW_XIDFLG = '" + PadR(cIdFluig,TamSX3("TNW_XIDFLG")[1]) + "' "
	cQuery += " WHERE TNN.D_E_L_E_T_ = '' AND TNW.D_E_L_E_T_ = ''"
	
	If Select("TTNN") > 0 ; TTNN->(dbCloseArea()) ; EndIf
	
	cQuery := ChangeQuery(cQuery)
	
	TcQuery cQuery Alias "TTNN" NEW
	
	dbSelectArea("TTNN")
	If !Eof()
		
		cTemp := TTNN->DRET
		dRet := CtoD(SubStr(cTemp,7,2) + "/" + SubStr(cTemp,5,2) + "/" + AllTrim(Str(Year(StoD(cTemp))+1)))
	else
		dRet := ctod('')
	EndIf
	
Return dRet


Static function CipaPrimeira()
Local cTnnAlias := GetNextAlias()
Local lRet := .T.
Local nCOunt := 0

BeginSql Alias cTnnAlias
		
		SELECT TNN.*
		       FROM %table:TNN% TNN
		       WHERE TNN.%NotDel%  AND TNN.TNN_FILIAL = %Exp:(cFilAnt)%                               
EndSql
		
While (cTnnAlias)->(!Eof())
	If AllTrim( (cTnnAlias)->(TNN_FILIAL) ) == AllTrim(cFilAnt)
		nCount += 1
		
		If nCount > 1
			lRet := .F.
			exit
		EndIf
	else
		exit
	EndIf
	(cTnnAlias)->(DbSKip())
End

(cTnnAlias)->(DbCloseArea())


return	lRet	



User Function ALRTD02()//execblock("ALRTD02")
Local oBrowse 	:= Nil
Private aRotina := MenuDef()
Private cItSZ2 := "000"
oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("TNN")
oBrowse:SetDescription("Mandatos ")
// Opcionalmente pode ser desligado a exibição dos detalhes
oBrowse:DisableDetails()
oBrowse:Activate()
Return Nil

User Function ALRTD03()
Local dDataFictica := ctod('')
Local cTnwAlias := GetNextALias()
Local lRet := .F.
Private CPERG :=  "CIPA3FI"


BeginSql Alias cTnwAlias
		
		SELECT TNW.*
		       FROM %table:TNW% TNW
		       WHERE TNW.%NotDel%  
		       AND TNW.TNW_FILIAL = %Exp:(TNN->TNN_FILIAL)% 
		       AND TNW.TNW_CODIGO = %Exp:(TNN->TNN_MANDAT)%
		       AND TNW.TNW_TIPO = '1'                               
EndSql

If (cTnwAlias)->(!Eof())  .And.  Alltrim((cTnwAlias)->(TNW_CODIGO)) == AllTrim(TNN->TNN_MANDAT)  .And.  Alltrim((cTnwAlias)->(TNW_FILIAL)) == AllTrim(TNN->TNN_FILIAL)
	dbselectarea('TNW')
	TNW->( DbGoto( (cTnwAlias)->(R_E_C_N_O_)  ) )
	alert (dtos(TNW->TNW_DTFIM) + " codigo: " + (TNW->TNW_CODIGO)   + " filial: " + (TNW->TNW_FILIAL))
	
	lRet := .T.
EndIf

(cTnwAlias)->(DbCLoseArea())

If !lRet .or. EMpty(TNW->TNW_DTFIM)
	Alert ("Nenhum registro localizado na tabela TNW. Operação abortada!")
	return
EndIf

MsgInfo ("Data Fim do Mandato utilizado como referência:" + dtoc(TNW->TNW_DTFIM) )
/*
DbSelectArea("SX1")
SX1->(dbSetOrder(1))
SX1->( dbSeek(cPerg) )

While SX1->(!Eof()) .And. AllTrim(SX1->X1_GRUPO) == cPerg //porgrama padrao mata112 nao tem PE´s suficientes para isto. Por esta razao, tratamos aqui ...

	reclock('SX1',.F.)
	SX1->(DbDelete())
	MsUnLock()
	SX1->(DbSKip())
End



alert ('deletado')

DbSelectArea("SX1")
SX1->(dbSetOrder(1))
SX1->( dbSeek(cPerg) )

If !( SX1->(!Eof())  .ANd. AllTrim(SX1->X1_GRUPO) == cPerg )
	TNW3Ajust(CPERG)
	pergunte(CPERG,.F.)
alert ('recriou')
EndIf

DbSelectArea("SX1")
SX1->(dbSetOrder(1))
SX1->( dbSeek(cPerg) )

While SX1->(!Eof()) .And. AllTrim(SX1->X1_GRUPO) == cPerg //porgrama padrao mata112 nao tem PE´s suficientes para isto. Por esta razao, tratamos aqui ...

	If AllTrim(SX1->X1_PERGUNT) =="Data Fim ?" 
		reclock('SX1',.F.)
		
		SX1->X1_CNT01 := dtos(TNW->TNW_DTFIM)
		alert ('dando update')
		MsUnLock()
	EndIf
	
	SX1->(DbSkip())
End

//alert ("Setou parte 1:" + dtos(mv_par01) + " 2:" + mv_par02 + " 3:" + dtos(mv_par03))
alert ('ponto')
TNW3Ajust(CPERG)
pergunte(CPERG,.F.)
pergunte(CPERG,.T.)
*/


Return Nil

User Function ALRTD04()
Local dDataFictica := ctod('')
Local cTnwAlias := GetNextAlias()
Local lRet := .F.
Local nMyDias := SuperGetMV("ES_CIDIAS",, '')
Private CPERG :=  "CIPA4FI"

BeginSql Alias cTnwAlias
		
		SELECT TNW.*
		       FROM %table:TNW% TNW
		       WHERE TNW.%NotDel%  
		       AND TNW.TNW_FILIAL = %Exp:(TNN->TNN_FILIAL)% 
		       AND TNW.TNW_CODIGO = %Exp:(TNN->TNN_MANDAT)%
		       AND TNW.TNW_TIPO = '1'                               
EndSql

If (cTnwAlias)->(!Eof())  .And.  Alltrim((cTnwAlias)->(TNW_CODIGO)) == AllTrim(TNN->TNN_MANDAT)  .And.  Alltrim((cTnwAlias)->(TNW_FILIAL)) == AllTrim(TNN->TNN_FILIAL)
	dbselectarea('TNW')
	TNW->( DbGoto( (cTnwAlias)->(R_E_C_N_O_)  ) )
	alert (dtos(TNW->TNW_DTFIM) + " codigo: " + (TNW->TNW_CODIGO)   + " filial: " + (TNW->TNW_FILIAL))
	
	lRet := .T.
EndIf

(cTnwAlias)->(DbCLoseArea())

If !lRet .or. EMpty(TNW->TNW_DTFIM)
	Alert ("Nenhum registro localizado na tabela TNW. Operação abortada!")
	return
EndIf

dDataFictica := (TNW->TNW_DTFIM - nMyDias)

MsgInfo ("SIMUALAÇÂO: Sendo o parâmetro ES_CIDIAS igual a " + Alltrim( STR(nMyDias) )  + chr(13) + chr(10)  + " o Schedule irá gerar Fluig no dia " + dtoc(dDataFictica)    )

/*
DbSelectArea("SX1")
SX1->(dbSetOrder(1))
SX1->( dbSeek(cPerg) )

If !( SX1->(!Eof())  .ANd. AllTrim(SX1->X1_GRUPO) == cPerg )
	TNW4Ajust(CPERG)
	pergunte(CPERG,.F.)
	
EndIf

DbSelectArea("SX1")
SX1->(dbSetOrder(1))
SX1->( dbSeek(cPerg) )

While SX1->(!Eof()) .And. AllTrim(SX1->X1_GRUPO) == cPerg //porgrama padrao mata112 nao tem PE´s suficientes para isto. Por esta razao, tratamos aqui ...

	If AllTrim(SX1->X1_PERGUNT) =="ES_CIDIAS Atual ?" 
		reclock('SX1',.F.)
		SX1->X1_CNT01 := Alltrim( STR(nMyDias) )
		MsUnLock()
	EndIf
	
	If AllTrim(SX1->X1_PERGUNT) =="Executaria em ?" 
		reclock('SX1',.F.)
		dDataFictica := (TNW->TNW_DTFIM - nMyDias)
		SX1->X1_CNT01 :=  dtos(dDataFictica)
		MsUnLock()
	EndIf
	
	SX1->(DbSkip())
End

TNW4Ajust(CPERG)
pergunte(CPERG,.T.)
*/
Return Nil


/*
MenuDef
Funcao generica MVC com as opcoes de menu

@since 09/12/2014
@version 1.0
*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'PESQ' 	    ACTION "PesqBrw"           OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE 'Data Fim' 	ACTION "U_ALRTD03"  OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE 'Simular Schedule' 	ACTION "U_ALRTD04"  OPERATION 2 ACCESS 0  //"Visualizar"

/*
ADD OPTION aRotina TITLE 'VISUALIZAR' 	ACTION "VIEWDEF.PFFINA01"  OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE 'INCLUIR' 	ACTION "VIEWDEF.PFFINA01"  OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE 'ALTERAR'   	ACTION "VIEWDEF.PFFINA01"  OPERATION 4 ACCESS 0  //"Alterar"
ADD OPTION aRotina TITLE 'EXCLUIR' 	ACTION "VIEWDEF.PFFINA01"  OPERATION 5 ACCESS 0  //"Excluir"
ADD OPTION aRotina TITLE 'Efetivar' 	ACTION "U_PFXFI1()"   OPERATION 6 ACCESS 0  //"Excluir"
ADD OPTION aRotina TITLE 'Estornar' 	ACTION "U_PFXFI2()"    OPERATION 7 ACCESS 0  //"Excluir"
*/
Return ( aRotina )

