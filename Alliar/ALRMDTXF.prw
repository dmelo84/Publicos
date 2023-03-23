#INCLUDE "PROTHEUS.CH"

Static cMsgErro := ""
//-------------------------------------------------------------------
/*{Protheus.doc} ALRMDTXF
Funcoes Genericas Medicina do Trabalho

@author Guilherme Santos
@since 13/05/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRMDTXF()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} MDTXFFTP
Envio do Arquivo PDF do Relatorio ao FTP do Fluig

@author Guilherme.Santos
@since 14/01/2016
@version P12
*/
//-------------------------------------------------------------------
User Function MDTXFFTP(cPath, cFile, cRetFtp)
	Local cUserFTP 	:= SuperGetMv("FS_ECMFTPU")
	Local cPassFTP 	:= SuperGetMv("FS_ECMFTPS")
	Local nFtpPort	:= SuperGetMv("MV_ECMFTPP")
	Local cURLFTP  	:= SuperGetMv("MV_ECMFTPU")
	Local cDirFTP		:= ""
	Local cOrigem		:= ProcName(1)
	Local nTentativa	:= 1
	Local lUsesIP		:= .F.
	Local lRetorno 	:= .T.
	Local oFTPHandle	:= tFtpClient():New()
	
	Default cRetFTP	:= ""

	oFTPHandle:bFirewallMode 		:= .T.
	oFTPHandle:bUsesIPConnection	:= 1

	If File(cPath + cFile)

		While nTentativa <= 5
	
			If oFTPHandle:FTPConnect(cURLFTP, nFtpPort, cUserFTP, cPassFTP) == 0
				Exit
			Else
				cRetFtp += oFTPHandle:GetLastResponse() + CRLF
			EndIf
	
			nTentativa++	
	
			If nTentativa > 5
				cRetFTP += "Não foi possível efetuar a conexão ao servidor FTP do FLUIG." + CRLF
				lRetorno := .F.
			EndIf
		End

		If lRetorno
			lRetorno := oFTPHandle:SetType(1) == 0
			
			cRetFtp += oFTPHandle:GetLastResponse() + CRLF
		EndIf

		If lRetorno
			If oFTPHandle:SendFile(cPath + cFile, cFile, .T.) == 0
				cRetFtp += "Arquivo enviado " + cFile + CRLF
			Else
				cRetFtp += oFTPHandle:GetLastResponse()
				cRetFtp += "Erro ao Enviar " + cFile + CRLF
				lRetorno := .F.
			EndIf
		EndIf 	
	Else
		cRetFtp += "Arquivo " + cPath + cFile + " não encontrado." + CRLF
	EndIf
	
	oFTPHandle:Close()
	
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} ALRXFLG
Inicia a Tarefa no Fluig

@author Guilherme.Santos
@since 14/05/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRXFLG(aCardData, cProcessID, nChoosedState, cRetWS, cAttach)
	Local nCompanyID		:= Val(SuperGetMv("MV_ECMEMP"))
	Local cUserID			:= SuperGetMv("MV_ECMMAT")
	Local cUserName		:= SuperGetMv("MV_ECMUSER")
	Local cPassword		:= SuperGetMv("MV_ECMPSW")
	Local cColleagueID	:= SuperGetMv("MV_ECMMAT")
	Local aTemp			:= {}
	Local oFluig			:= NIL
	Local nX				:= 0
	Local nY				:= 0
	Local nI				:= 0
	Local xValor			:= NIL
	Local lRetorno		:= .T.
	Local cString			:= ""

	Default aCardData			:= {}
	Default cProcessID		:= ""
	Default nChoosedState	:= 0
	Default cRetWS			:= ""
	Default cAttach			:= ""

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
	oFluig:cComments			:= cProcessID
	oFluig:_URL				:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	If !Empty(cAttach)
		//Vincula os Dados do Anexo enviado ao FTP
		Aadd(oFluig:oWSstartProcessattachments:oWSitem, ECMWorkflowEngineServiceService_processAttachmentDto():New())
		aTail(oFluig:oWSstartProcessattachments:oWSitem):nattachmentSequence := 1
		Aadd(aTail(oFluig:oWSstartProcessattachments:oWSitem):oWSattachments,ECMWorkflowEngineServiceService_attachment():New())
		aTail(aTail(oFluig:oWSstartProcessattachments:oWSitem):oWSattachments):cfilename := cAttach
		aTail(oFluig:oWSstartProcessattachments:oWSitem):ldeleted := .F.
		aTail(oFluig:oWSstartProcessattachments:oWSitem):cdescription := cAttach
		aTail(oFluig:oWSstartProcessattachments:oWSitem):lnewAttach := .T.
		aTail(oFluig:oWSstartProcessattachments:oWSitem):noriginalMovementSequence := 1
	EndIf

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
				xValor := AllTrim(Str(xValor))
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
/*{Protheus.doc} ALRXCRD
Adiciona os Dados do Formulario para Envio

@author Guilherme.Santos
@since 06/01/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRXCRD(aCardData, cCampo, xValor, cProcesso)
	Local aTemp 			:= {}
	Local cLog				:= ""
	Default cProcesso		:= ""

	cLog += "aCardData | cCampo: " + cCampo + "|"
	cLog += "xValor: "
	cLog += If(ValType(xValor) == "D", DtoC(xValor), "")
	cLog += If(ValType(xValor) == "N", Val(xValor), "")
	cLog += If(ValType(xValor) == "C", xValor, "")
	cLog += "|"

	U_ALRXLOG(cLog, .F., cProcesso)

	Aadd(aTemp, cCampo)
	Aadd(aTemp, xValor)
	Aadd(aCardData, aClone(aTemp))
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} ALRXLOG
Gravacao do Log de Processamento

@author TOTVS
@since 21/01/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRXLOG(cMensagem, lGrava, cProcesso)
	Default lGrava 		:= .F.
	Default cProcesso		:= ""


	cMsgErro += cMensagem + CRLF
	
	If lGrava
		MemoWrite(cProcesso + "_" + cFilAnt + "_" + DtoS(dDatabase) + "_" + StrTran(Time(), ":", "") + ".log", cMsgErro)
		cMsgErro := ""
	EndIf

Return NIL
