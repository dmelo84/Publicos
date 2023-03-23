#Include 'Protheus.ch'
#Include "topconn.ch"

/*/{Protheus.doc} FSFATP05
Rotina que percorre notas fiscais faturadas e valida quais foram integradas com o Pleres.
@type function
@author gustavo.barcelos
@since 15/02/2016
@version 1.0
/*/
user function FSFATP05(aParam)

Local aAreOld := {}

Local cCodEmp	:= ""
Local cCodFil	:= ""
Local lManual	:= .T.
Local nHdlLock := -1
Local cMensLog:= ""
Local lRet		:= .T.

Default aParam:= {}

If !Empty(aParam)
	cCodEmp	:= aParam[1]
	cCodFil	:= aParam[2]
	lManual	:= .F.
//	Conout("FSFATP05 - Parametros enviados")
//	Conout("FSFATP05 - lManual := .F.")
Else
//	Conout("FSFATP05 - Parametros enviados")
//	Conout("FSFATP05 - lManual := .T.")
EndIf

If !Empty(cCodEmp) .And. !Empty(cCodFil)

	RpcSetType(3)
	RpcSetEnv(cCodEmp, cCodFil)
	nModulo := 04

	//Verifica se a rotina ja esta sendo executada travando-a para nao ser executada mais de uma vez
	If U_FSTraExe(@nHdlLock, "FSFATP05", .T., lManual)
		Return(Nil)
	EndIf

	//Executa processo de integracao
	FProArq(@cMensLog,lManual)

	//Destrava a rotina
	U_FSTraExe(@nHdlLock, "FSFATP05")

	//Fecha ambiente atual
	RpcClearEnv()

	Conout(cMensLog)

Else

	aAreOld := {SM0->(GetArea()), GetArea()}

	lRet:= FProArq(@cMensLog,lManual)

	If !Empty(cMensLog) .And. !lRet
		ApMsgStop(cMensLog,".:Atenção:.")
	Else
		If ApMsgNoYes("Apresenta XML enviado?")
			U_FSMosTxt(,cMensLog)
		EndIf
	EndIf

	aEval(aAreOld, {|xAux| RestArea(xAux)})

EndIf

Return


/*/{Protheus.doc} FProArq
Efetua processamento
@author claudiol
@since 11/03/2016
@version undefined
@param lManual, logical, descricao
@type function
/*/
Static Function FProArq(cMensLog,lManual)

	Local cQuery		:= ""
	Local cXml			:= ""
	Local cJson		:= ""
	Local cCgcFil 	:= "" 
	Local cCodFil 	:= "" 
	Local cTipFat 	:= ""
	Local cIdPleres 	:= ""
	Local cCgcCli 	:= ""
	Local cNomeCli 	:= ""
	Local cSerie		:= ""
	Local cDoc 		:= ""
	Local cChvNfe		:= ""
	Local cDatEmi		:= ""
	Local cAliTmp		:= GetNextAlias()
	Local lRet			:= .F.
	Local cNFElet	:= ""
	Local nVlrBrt		:= 0
	Local cFilBkp		:= cFilAnt

	ConOut("*********************************************************")
	ConOut("* FSFATP05 - Enviando chave nota fiscal                 *")
	ConOut("*********************************************************")

	cQuery += "SELECT 	SF2.F2_FILIAL" + CRLF
	cQuery += ", 			SF2.F2_DOC" + CRLF
	cQuery += ", 			SF2.F2_SERIE" + CRLF
	cQuery += ", 			SF2.F2_CHVNFE" + CRLF
	cQuery += ", 			SF2.F2_EMISSAO" + CRLF
	cQuery += ", 			SF2.R_E_C_N_O_ RECNO" + CRLF
	cQuery += ", 			SD2.D2_PEDIDO" + CRLF
	cQuery += ", 			SC5.C5_XIDPLE" + CRLF
	cQuery += ", 			SC5.C5_XTIPFAT" + CRLF
	cQuery += ", 			SA1.A1_CGC" + CRLF
	cQuery += ", 			SA1.A1_NOME" + CRLF
	cQuery += ", 			SF2.F2_EMINFE" + CRLF
	cQuery += ", 			SF2.F2_CODNFE" + CRLF
	cQuery += ", 			SF2.F2_NFELETR" + CRLF
	cQuery += ", 			SF3.F3_CODNFE" + CRLF
	cQuery += ", 			SF3.F3_NFELETR" + CRLF
	cQuery += ", 			SF2.F2_VALBRUT" + CRLF
	cQuery += ", 			SF2.F2_XINTPLE" + CRLF

	cQuery += "FROM 	" + RetSqlName("SF2") + " SF2" + CRLF

	cQuery += "	INNER JOIN" + CRLF 

	cQuery += "	" + RetSqlName("SF3") + " SF3" + CRLF

	cQuery += "	ON 		SF3.F3_FILIAL = SF2.F2_FILIAL" + CRLF 
	cQuery += "	AND		SF3.F3_NFISCAL = SF2.F2_DOC" + CRLF
	cQuery += "	AND		SF3.F3_SERIE = SF2.F2_SERIE" + CRLF
	cQuery += "	AND 	LEFT(SF3.F3_CFO,1) >= '5'" + CRLF
	cQuery += "	AND		SF3.D_E_L_E_T_ = ''" + CRLF

	cQuery += "	INNER JOIN" + CRLF

	cQuery += "	" + RetSqlName("SD2") + " SD2" + CRLF
	
	cQuery += "	ON 		SD2.D2_FILIAL = SF2.F2_FILIAL" + CRLF 
	cQuery += "	AND 	SD2.D2_DOC = SF2.F2_DOC" + CRLF
	cQuery += "	AND 	SD2.D2_SERIE = SF2.F2_SERIE" + CRLF
	cQuery += "	AND		SD2.D2_CLIENTE = SF2.F2_CLIENTE" + CRLF
	cQuery += "	AND		SD2.D2_LOJA = SF2.F2_LOJA" + CRLF
	cQuery += "	AND 	SD2.D_E_L_E_T_ = ''" + CRLF
	
	cQuery += "	INNER JOIN" + CRLF

	cQuery += "	" + RetSqlName("SC5") + " SC5" + CRLF

	cQuery += "	ON 		SC5.C5_FILIAL	 = SD2.D2_FILIAL" + CRLF 
	cQuery += "	AND 	SC5.C5_NUM = SD2.D2_PEDIDO" + CRLF
	cQuery += "	AND		SC5.C5_XIDPLE <> ''" + CRLF
	cQuery += "	AND 	SC5.D_E_L_E_T_ = ''" + CRLF

	cQuery += "	INNER JOIN" + CRLF
	
	cQuery += "	" + RetSqlName("SA1") + " SA1" + CRLF

	cQuery += "	ON		SA1.A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
	cQuery += "	AND		SA1.A1_COD = SF2.F2_CLIENTE" + CRLF 
	cQuery += "	AND 	SA1.A1_LOJA = SF2.F2_LOJA" + CRLF
	cQuery += "	AND 	SA1.D_E_L_E_T_ = ''" + CRLF

	cQuery += "WHERE 		SF2.D_E_L_E_T_ = ''" + CRLF


	If lManual
		cQuery += "AND	SF2.R_E_C_N_O_ = " + cValToChar(SF2->(Recno())) + CRLF
	Else
		cQuery += "AND 	((SF2.F2_XINTPLE = '') OR (SF2.F2_XINTPLE = '1' AND SF2.F2_CHVNFE <> ''))" + CRLF
	EndIf

	cQuery += "GROUP BY SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CHVNFE, SF2.F2_EMISSAO, SF2.R_E_C_N_O_, SD2.D2_PEDIDO, SC5.C5_XIDPLE, SC5.C5_XTIPFAT, SA1.A1_CGC, SA1.A1_NOME, SF2.F2_EMINFE, SF2.F2_CODNFE, SF2.F2_NFELETR, SF3.F3_CODNFE,	SF3.F3_NFELETR, SF2.F2_VALBRUT,  SF2.F2_XINTPLE" + CRLF

	cQuery := ChangeQuery(cQuery)
	
	TCQUERY cQuery NEW ALIAS (cAliTmp)
	
	(cAliTmp)->(DBGoTop())
	While !((cAliTmp)->( EOF() ))
		lRet:= .T.
		
		SM0->(DBSeek(cEmpAnt + (cAliTmp)->F2_FILIAL))
		cCgcFil := SM0->M0_CGC
		cCodFil := SM0->M0_FILIAL

		cFilAnt := SM0->M0_CODFIL

		cTipFat := (cAliTmp)->C5_XTIPFAT
		cIdPleres:= (cAliTmp)->C5_XIDPLE
		cCgcCli := (cAliTmp)->A1_CGC
		cNomeCli:= (cAliTmp)->A1_NOME
		cSerie	:= (cAliTmp)->F2_SERIE
		cDoc 	:= (cAliTmp)->F2_DOC
		
		cDatEmi	:= Iif(Empty((cAliTmp)->F2_EMINFE), (cAliTmp)->F2_EMISSAO, (cAliTmp)->F2_EMINFE)
		
		nVlrBrt	:= (cAliTmp)->F2_VALBRUT
		nVlrLiq	:= (cAliTmp)->F2_VALBRUT
		
		If Empty((cAliTmp)->F2_CODNFE)
			cChvNfe	:= (cAliTmp)->F3_CODNFE
			cNFElet	:= (cAliTmp)->F3_NFELETR
		Else
			cChvNfe	:= (cAliTmp)->F2_CODNFE
			cNFElet	:= (cAliTmp)->F2_NFELETR
		Endif
		
		ConOut("********************************************************") 
		ConOut("FSFATP05 - Filial: " + cFilAnt + " - ID: " + cIdPleres)
		ConOut("********************************************************") 

		If Left(cIdPleres,1) != "V"
			
			cXml:= U_FSXmlNFS(cCgcFil,cCodFil,cTipFat,cIdPleres,cCgcCli,cNomeCli,cSerie,cDoc,cChvNfe,cDatEmi,cNFElet, nVlrBrt)	
			aRet:= U_FSPLEFAT(cXml,cIdPleres)

		Else
			
			aRet := U_CP16JNFS(cCgcFil,cIdPleres,cSerie,cDoc,cChvNfe,cDatEmi,cNFElet)
			If aRet[1]
				aRet[1] := "0"
			Else
				aRet[1] := "-1"
			Endif
		Endif		

		If aRet[1] <> "-1"
			//Inclui flag de integração com sistema Pleres.
			SF2->(DBGoTo((cAliTmp)->RECNO))
			If RecLock("SF2", .F.)
				SF2->F2_XINTPLE := Iif(Empty(cChvNfe), "1", "2")
				SF2->(MsUnlock())
			EndIf
			
//			/*----------------------------------------
//				28/08/2018 - Jonatas Oliveira - Compila
//				Cria Fila de Processamento Atualização de Nota- Fluig
//			------------------------------------------*/
//			IF !EMPTY(cChvNfe)
//				//|Cria Fila de Processamento Atualização de Nota- Fluig|
//				U_CP12ADD("000020", "SF2", SF2->(RECNO()), , )
//			ENDIF 

			ConOut("********************************************************") 
			ConOut("FSFATP05 - ID: " + cIdPleres + " Integrado com Sucesso.")
			ConOut("********************************************************") 

		Else
			cMensLog += aRet[2] + CRLF

			ConOut("********************************************************") 
			ConOut("FSFATP05 - Filial: " + cFilAnt + " - Erro ao Integrar ID: " + cIdPleres)
			ConOut("********************************************************") 
			ConOut(cMensLog)
			ConOut("********************************************************") 
		EndIf

		(cAliTmp)->( DBSkip() )
	EndDo
	
	(cAliTmp)->( DBCloseArea() )
	

	If !lRet
		cMensLog+= "Sem dados para Processar!"
	Else
		If lManual
			cMensLog += cXml
		EndIf
	EndIf

	ConOut("*********************************************************")
	ConOut("* Processo Finalizado!" + DtoC(Date()) + " " + Time() )
	ConOut("*********************************************************")	

	cFilAnt := cFilBkp

Return(lRet)
