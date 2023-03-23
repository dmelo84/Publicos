#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWCommand.ch'  

#Define _RTPLESTA 1
#Define _RTPLEMSG 2

/*/{Protheus.doc} FSESTP07
Efetua envio de baixa de SA ao Pleres - MANUAL

@author claudiol
@since 29/02/2016
@version undefined

@type function
/*/
user function FSESTP07(aParam)
	
Local cCodEmp	:= ""
Local cCodFil	:= ""
Local lManual	:= .T.

Local nOpca 	:= 0		// Flag de confirmacao para OK ou CANCELA
Local aSays	 	:= {} 		// Array com as mensagens explicativas da rotina
Local aButtons := {}		// Array com as perguntas (parametros) da rotina
Local cCadastro:= "Integração Digitalmed Estoque"
Local	nHdlLock := -1
Local cMensLog	:= ""

Default aParam:= {}

If !Empty(aParam)
	cCodEmp	:= aParam[1]
	cCodFil	:= aParam[2]
	lManual	:= .F.
EndIf

If !Empty(cCodEmp) .And. !Empty(cCodFil)

	RpcSetType(3)
	RpcSetEnv(cCodEmp, cCodFil)
	nModulo := 04

	//Verifica se a rotina ja esta sendo executada travando-a para nao ser executada mais de uma vez
	If U_FSTraExe(@nHdlLock, "FSESTP07", .T., lManual)
		Return(Nil)
	EndIf

	//Executa processo de integracao
	FProArq(@cMensLog,lManual)

	//Destrava a rotina
	U_FSTraExe(@nHdlLock, "FSESTP07")

	//Fecha ambiente atual
	RpcClearEnv()

	Conout(cMensLog)

Else

	//Verifica se a rotina ja esta sendo executada travando-a para nao ser executada mais de uma vez
	If U_FSTraExe(@nHdlLock, "FSESTP07", .T., lManual)
		Return(Nil)
	EndIf

	Private oProcess
	
	AADD(aSays, "Este programa tem como objetivo efetuar processo de Integracao com Pleres")
	AADD(aSays, "referente a baixa de movimentacao de Solicitação ao Armazém.")
	
	AADD(aButtons, { 1,.T.,{|o| nOpca := 1 , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
	
	FormBatch( cCadastro, aSays, aButtons )
		
	If ( nOpcA == 1)
		//Executa processo de integracao
		oProcess := MsNewProcess():New({|lEnd| FProArq(@cMensLog,lManual) },OemToAnsi("Processando"),OemToAnsi("Processando dados para envio. Aguarde..."),.F.)
		oProcess:Activate()
	EndIf

	//Destrava a rotina
	U_FSTraExe(@nHdlLock, "FSESTP07")

	If !Empty(cMensLog)
		ApMsgStop(cMensLog,".:Atenção:.")
	EndIf

EndIf

Return


/*/{Protheus.doc} FProArq
Processa envio de baixa
@author claudiol
@since 29/02/2016
@version undefined

@type function
/*/
Static Function FProArq(cMensLog,lManual)

Local nXi		:= 0
Local nTotReg	:= 0
Local nCtdReg	:= 0
Local cAliTmp	:= ""
Local cXml		:= ""
Local cQuebra1 := ""
Local aTagCab	:= {}
Local aTagXml	:= {}
Local aFilAtu 	:= {}
Local	aRecSD3	:= {}
Local aFilial	:= {}
Local lFirst	:= .F.

Local cFilOld	:= cFilAnt

//Tag do XML
Aadd(aTagXml,{"Produto"		,"D3_COD"		, "" })
Aadd(aTagXml,{"Quant"		,"D3_QUANT"	, "" })
Aadd(aTagXml,{"Necessidade"	,"CQ_DATPRF"	, "{|x| Dtos(x) }" })
Aadd(aTagXml,{"Lote"			,"D3_LOTECTL"	, "" })
Aadd(aTagXml,{"Validade"		,"D3_DTVALID"	, "{|x| Dtos(x) }" })
Aadd(aTagXml,{"IdRequis"		,"CP_XIDPLE"	, "" })

//Busca dados a processar
If FGerDad(@cAliTmp)

	If lManual
		(cAliTmp)->(dbGotop())
		(cAliTmp)->(dbEval({||nTotReg++, , Iif(aScan(aFilial, D3_FILIAL)==0, Aadd(aFilial,D3_FILIAL), Nil) }))

		oProcess:SetRegua1(Len(aFilial)*2)
		oProcess:SetRegua2(nTotReg)
	EndIf

	(cAliTmp)->(dbGotop())
	lFirst:= .T.
	lContinua:= .T.
	While lContinua

		If lFirst
			cQuebra1:= (cAliTmp)->D3_FILIAL
			If lManual
				oProcess:IncRegua1("Montando XML Filial: " + cQuebra1)
			EndIf
			
			//Altera a filial corrente
			U_FSMudFil((cAliTmp)->D3_FILIAL)

			//Retorna informacoes da filial de origem
			aFilAtu 	:= FWArrFilAtu(cEmpAnt,(cAliTmp)->CP_XFILORI)

			//Tab Cabecalho
			aTagCab:= {}
			Aadd(aTagCab,{"Login"			,""	, "{|x| '" + Supergetmv("ES_PLELOG",.F.,"") + "' }" })
			Aadd(aTagCab,{"Senha"			,""	, "{|x| '" + Supergetmv("ES_PLEPSW",.F.,"") + "' }" })
			Aadd(aTagCab,{"CNPJFilial"		,""	, "{|x| '" + aFilAtu[SM0_CGC] 		+ "' }" })
			Aadd(aTagCab,{"NomeFilial"		,""	, "{|x| '" + aFilAtu[SM0_NOMECOM] + "' }" })

			lFirst:= .F.
		EndIf
	
		//Posiciona registros
		SD3->(dbGoto((cAliTmp)->SD3RECNO))
		SCP->(dbGoto((cAliTmp)->SCPRECNO))
		SCQ->(dbGoto((cAliTmp)->SCQRECNO))
	
		//Monta XML de envio
		cXml+= MontaXML("Requisicao",,,,,,,.T.,.F.,.T.)
		
		For nXi:= 1 To Len(aTagCab)
			cXml+= U_FSCnvXML(aTagCab[nXi],2)
		Next nXi
		
		cXml+= MontaXML("Itens",,,,,,2,.T.,.F.,.T.)

		While (cAliTmp)->(!Eof()) .And. (cQuebra1 == (cAliTmp)->D3_FILIAL)

			If lManual
				nCtdReg++
				oProcess:IncRegua2("Processando: "+ cValToChar(nCtdReg) + " de " + cValToChar(nTotReg) )
			EndIf

			SD3->(dbGoto((cAliTmp)->SD3RECNO))
			SCP->(dbGoto((cAliTmp)->SCPRECNO))
			SCQ->(dbGoto((cAliTmp)->SCQRECNO))
		
			cXml+= MontaXML("Item",,,,,,2,.T.,.F.,.T.)
			
			For nXi:= 1 To Len(aTagXml)
				cXml+= U_FSCnvXML(aTagXml[nXi],4)
			Next nXi
			
			cXml+= MontaXML("Item",,,,,,2,.F.,.T.,.T.)

			Aadd(aRecSD3,(cAliTmp)->SD3RECNO)

			cQuebra1:= (cAliTmp)->D3_FILIAL

			(cAliTmp)->(dbSkip())
		EndDo

		cXml+= MontaXML("Itens",,,,,,2,.F.,.T.,.T.)
		
		//Fim
		cXml+= MontaXML("Requisicao",,,,,,,.F.,.T.)

		//Envia XML
		If lManual
			oProcess:IncRegua1("Enviando Filial: " + cQuebra1)
		EndIf

		//Envia via WS
		lTeste:= .F.
		If !lTeste
			aRet:= U_FSPLEEST("BXA", cXml)
		Else
			ApMsgAlert(cXml)
			aRet:= {"0",""}
		EndIf

		//Inicializa xml
		cXml:= ""

		If aRet[_RTPLESTA]=="-1"
			cMensLog+= "Filial: " + cQuebra1 
			cMensLog+= aRet[_RTPLEMSG] + CRLF
		Else
			//Marca flag como enviado
			BeginTran()
				
				For nXi:= 1 To Len(aRecSD3)
					SD3->(dbGoto(aRecSD3[nXi]))
					If (lRet:= RecLock("SD3",.F.))
						SD3->D3_XFLGPLE:= "E"
						SD3->(MsUnlock())
					Else
						Exit
					EndIf
				Next nXi

				aRecSD3:= {}

				If lRet
					//Efetiva transacao
					EndTran()
				Else
					//Disarmo a transação
					DisarmTransaction ()
				EndIF
			
			MsUnlockAll()
			
		EndIf

		lFirst:= .T.

		lContinua:= (cAliTmp)->(!Eof())

	EndDo
	
	//Restaura a filial corrente
	U_FSMudFil(cFilOld)

Else
	cMensLog += "Nao existem registros a processar!" + CRLF

EndIf
	
//Fecha cursor
(cAliTmp)->(dbCloseArea())

Return(lRet)


/*/{Protheus.doc} FGerDad
Gera area de trabalho com dados a serem exportados

@author claudiol
@since 29/02/2016
@version undefined
@param cAliTmp, characters, descricao
@type function
/*/
Static Function FGerDad(cAliTmp)

//Define area de trabalho
cAliTmp	:= GetNextAlias()

//Gera cursor em area de trabalho
BeginSql alias cAliTmp
	column D3_DTVALID as Date
	column CQ_DATPRF as Date

	SELECT D3_FILIAL, CP_XIDPLE, CP_XFILORI, D3_COD, D3_QUANT, D3_LOTECTL, D3_DTVALID, CQ_DATPRF, 
		SD3.R_E_C_N_O_ SD3RECNO, SCP.R_E_C_N_O_ SCPRECNO, SCQ.R_E_C_N_O_ SCQRECNO 
	FROM %table:SD3% SD3 
	INNER JOIN %table:SCQ% SCQ 
		ON  SD3.D3_FILIAL = SCQ.CQ_FILIAL 
		AND SD3.D3_NUMSA  = SCQ.CQ_NUM 
		AND SD3.D3_ITEMSA = SCQ.CQ_ITEM
		AND SD3.D3_NUMSEQ = SCQ.CQ_NUMREQ
		AND SD3.%notDel%
		AND SCQ.%notDel%
	INNER JOIN %table:SCP% SCP
		ON  SCP.CP_FILIAL = SCQ.CQ_FILIAL 
		AND SCP.CP_NUM    = SCQ.CQ_NUM
		AND SCP.CP_ITEM   = SCQ.CQ_ITEM
		AND SCP.%notDel%
	WHERE SD3.D3_XFLGPLE='B'
	
	ORDER BY SD3.D3_FILIAL, SCP.CP_XIDPLE
EndSql

//Retorna informacoes da ultima query executada
//aExeQry:=GetLastQuery()

(cAliTmp)->(dbGotop())
lRet:= (cAliTmp)->(!Eof())

Return(lRet)
