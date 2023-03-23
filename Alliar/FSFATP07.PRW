#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FSFATP07
Rotina que percorre notas fiscais faturadas e valida quais foram integradas com o Pleres.
@type function
@author gustavo.barcelos
@since 15/02/2016
@version 1.0
/*/
user function FSFATP07(aParam)

Local aAreOld := {}

Local cCodEmp	:= ""
Local cCodFil	:= ""
Local lManual	:= .T.
Local nHdlLock := -1
Local cMensLog:= ""
Local lRet		:= .T.

Default aParam:= {}

SET DELETED OFF

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
	If U_FSTraExe(@nHdlLock, "FSFATP07A", .T., lManual)
		Return(Nil)
	EndIf

	//Executa processo de integracao
	FProArq(@cMensLog,lManual)

	//Destrava a rotina
	U_FSTraExe(@nHdlLock, "FSFATP07A")

	//Fecha ambiente atual
	RpcClearEnv()

Else

	aAreOld := {SM0->(GetArea()), GetArea()}

	lRet:= FProArq(@cMensLog,lManual)

	If ApMsgNoYes("Apresenta ocorrencia do envio?")
		U_FSMosTxt(,cMensLog)
	EndIf		

	aEval(aAreOld, {|xAux| RestArea(xAux)})

EndIf


SET DELETED ON

Return



User Function FSFATP7B()
	cMensLog	:= ""
	lManual		:= .F.
	FProArq(cMensLog,lManual)
	
	
	ALERT(cMensLog)
Return()





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
	Local cNFElet		:= ""
	Local nVlrBrt		:= 0
	Local cFilBkp		:= cFilAnt
	Local lExcNF		:= .F.
	Local lFinanc		:= .T.
	Local cIntPle		:= ""
	Local dImpTSS		:= GETMV("CP_RRISTSS",.F., STOD("20170301")) //| Data de corte para retorno do sistema RIS alteração de regra em função do TSS | Augusto Ribeiro (23/03/2017) 
	Local cLogFull		:= ""
	Local cCgcPar 		:= ""

	ConOut("*********************************************************")
	ConOut("* FSFATP07 - Filial: " + cFilAnt + " - ID: " + cIdPleres+" - " + DtoC(Date()) + " - " + Time() + "Enviando chave nota fiscal!")
	ConOut("*********************************************************")

	cQuery += "SELECT 	SF2.F2_FILIAL" + CRLF
	cQuery += ", 			SF2.F2_DOC" + CRLF
	cQuery += ", 			SF2.F2_SERIE" + CRLF
	cQuery += ", 			SF2.F2_EMISSAO" + CRLF
	cQuery += ", 			SF2.R_E_C_N_O_ F2RECNO" + CRLF
	cQuery += ", 			SC5.R_E_C_N_O_ C5RECNO" + CRLF
	cQuery += ", 			SD2.D2_PEDIDO" + CRLF
	cQuery += ", 			SC5.C5_XIDPLE" + CRLF
	cQuery += ", 			SC5.C5_XCGCPAR" + CRLF
	cQuery += ", 			SC5.C5_XTIPFAT" + CRLF
	cQuery += ", 			SA1.A1_CGC" + CRLF
	cQuery += ", 			SA1.A1_NOME" + CRLF
	cQuery += ", 			SF2.F2_EMINFE" + CRLF
	cQuery += ", 			SF2.F2_NFELETR" + CRLF
	cQuery += ", 			SF3.F3_CODNFE" + CRLF
	cQuery += ", 			SF3.F3_NFELETR" + CRLF
	cQuery += ", 			SF2.F2_VALBRUT" + CRLF
	cQuery += ", 			SF2.F2_VALFAT" + CRLF
	cQuery += ", 			SF2.F2_XINTPLE" + CRLF
	cQuery += ", 			SF2.F2_XCVNFS" + CRLF
	cQuery += ", 			SF2.F2_CODNFE" + CRLF
	cQuery += ", 			SF2.D_E_L_E_T_ SF2DELE" + CRLF
	
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
	cQuery += "	AND		SC5.C5_XIDPLE NOT LIKE  'X%' " + CRLF
	cQuery += "	AND		SC5.C5_XIDPLE NOT LIKE  'C%' " + CRLF

	cQuery += "	INNER JOIN" + CRLF
	
	cQuery += "	" + RetSqlName("SA1") + " SA1" + CRLF

	cQuery += "	ON		SA1.A1_FILIAL = '" + xFilial("SA1") + "'" + CRLF
	cQuery += "	AND		SA1.A1_COD = SF2.F2_CLIENTE" + CRLF 
	cQuery += "	AND 	SA1.A1_LOJA = SF2.F2_LOJA" + CRLF
	cQuery += "	AND 	SA1.D_E_L_E_T_ = ''" + CRLF

	cQuery += "WHERE 		SF2.D_E_L_E_T_ = '' AND " + CRLF
	//cQuery += "WHERE SF2.D_E_L_E_T_ = '' AND  SF2.F2_FILIAL IN ('01101MG0001') AND " + CRLF
	cQuery += " SF2.F2_EMISSAO >= '20180101' AND " 
   	cQuery += "( SF2.D_E_L_E_T_ <> '*' OR ( SF3.F3_OBSERV = 'NF CANCELADA' AND SF3.F3_CODRET = '333' ) ) AND " + CRLF
   	cQuery += "( SF2.D_E_L_E_T_ <> '*' OR ( SF2.D_E_L_E_T_ = '*' AND SF2.F2_EMISSAO >= '20170210' ) ) AND "+ CRLF                           
	If lManual
		cQuery += " SF2.R_E_C_N_O_ = " + cValToChar(SF2->(Recno())) + CRLF
	Else
		//cQuery += " ((SF2.F2_XINTPLE = '') OR (SF2.F2_XINTPLE = '1' AND SF2.F2_XCVNFS <> '') OR (SF2.D_E_L_E_T_ = '*'  AND SF2.F2_XINTPLE <> '3' ))" + CRLF
		cQuery += " ((SF2.F2_XINTPLE = '') OR (SF2.F2_XINTPLE = '1' AND SF2.F2_XCVNFS <> '') OR (SF2.F2_XINTPLE = '1' AND SF2.F2_CODNFE <> '' AND SF2.F2_EMISSAO >= '"+dtos(dImpTSS)+"') OR (SF2.D_E_L_E_T_ = '*'  AND SF2.F2_XINTPLE <> '3' AND SF2.F2_XINTPLE <> '9' ))" + CRLF
	EndIf

	cQuery += "GROUP BY SF2.F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, SF2.R_E_C_N_O_, SC5.R_E_C_N_O_, SD2.D2_PEDIDO, SC5.C5_XIDPLE, SC5.C5_XCGCPAR, SC5.C5_XTIPFAT, SA1.A1_CGC, SA1.A1_NOME, SF2.F2_EMINFE, SF2.F2_NFELETR, SF3.F3_CODNFE,	SF3.F3_NFELETR, SF2.F2_VALBRUT, SF2.F2_VALFAT, SF2.F2_XINTPLE, SF2.F2_XCVNFS, SF2.F2_CODNFE, SF2.D_E_L_E_T_ " + CRLF
	cQuery += "ORDER BY SF2.F2_FILIAL, SF2.R_E_C_N_O_ "
	
	
//	MemoWrite(GetTempPath(.T.) + "FSFATP07.SQL", cQuery)			
	
	//cQuery := ChangeQuery(cQuery)
	
	TCQUERY cQuery NEW ALIAS (cAliTmp)
	
	(cAliTmp)->(DBGoTop())
	
	
	/*----------------------------------------
	28/08/2018 - Jonatas Oliveira - Compila
	Quando faturamento pessoa Jurídica, cria 
	solicitação no Fluig. 
	------------------------------------------*/
	DBSELECTAREA("SA1")
	SA1->(DBSETORDER(1))
		
	
	While !((cAliTmp)->( EOF() ))
	
		SF2->(DBGoTo((cAliTmp)->F2RECNO))
		SC5->(DBGoTo((cAliTmp)->C5RECNO))
	
		cMensLog 	:= ""
		lRet		:= .T.
		lExcNF		:= .F.
		
		lFinanc := !(SC5->C5_XELIMRE == "S")
		
		If Alltrim((cAliTmp)->SF2DELE) == "*"
			lExcNF := .T.
		Endif	
		
		
		SM0->(DBSeek(cEmpAnt + (cAliTmp)->F2_FILIAL))
		cCgcFil 	:= SM0->M0_CGC
		cCodFil 	:= SM0->M0_FILIAL

		cFilAnt 	:= SM0->M0_CODFIL

		cTipFat 	:= (cAliTmp)->C5_XTIPFAT
		cIdPleres	:= (cAliTmp)->C5_XIDPLE
		cCgcCli 	:= (cAliTmp)->A1_CGC
		cNomeCli	:= (cAliTmp)->A1_NOME
		cSerie		:= (cAliTmp)->F2_SERIE
		cDoc 		:= (cAliTmp)->F2_DOC
		cCgcPar		:= (cAliTmp)->C5_XCGCPAR
		
		cDatEmi	:= Iif(Empty((cAliTmp)->F2_EMINFE), (cAliTmp)->F2_EMISSAO, (cAliTmp)->F2_EMINFE)
		
		nVlrBrt	:= (cAliTmp)->F2_VALBRUT
		nVlrLiq	:= (cAliTmp)->F2_VALFAT
		
		
		IF EMPTY((cAliTmp)->F2_XCVNFS)
			cChvNfe	:= ALLTRIM((cAliTmp)->F2_CODNFE)
		ELSE
			cChvNfe	:= ALLTRIM((cAliTmp)->F2_XCVNFS)
		ENDIF
		
		cNFElet	:= (cAliTmp)->F2_NFELETR  
		
		ConOut("*********************************************************")
		ConOut("* FSFATP07 - Filial: " + cFilAnt + " - ID: " + cIdPleres+" - " + DtoC(Date()) + " - " + Time() + " Integrando NF "+cDoc+" Emissao "+cDatEmi+"!")
		ConOut("*********************************************************")						

		// Se é NF gerada
		If Left(cIdPleres,1) != "V" .AND. Left(cIdPleres,1) != "R" .AND. Left(cIdPleres,1) != "U"
			if !lExcNF
				cXml	:= U_FSXmlNFS(cCgcFil, cCodFil, cTipFat, cIdPleres, cCgcCli, cNomeCli, cSerie, cDoc, cChvNfe, cDatEmi, cNFElet, nVlrBrt)
			Else
				cXML 	:= U_FSXmlNFS(cCgcFil, cCodFil, cTipFat, cIdPleres, cCgcCli, cNomeCli, cSerie, cDoc, cChvNfe, cDatEmi, cNFElet, nVlrBrt, 0, lExcNF, lFinanc)
			Endif		

			aRet:= U_FSPLEFAT(cXml,cIdPleres)
		Elseif Left(cIdPleres,1) == "V"
			
			aRet := U_CP16JNFS(cCgcFil,cIdPleres,cSerie,cDoc,cChvNfe,cDatEmi,cNFElet)
			If aRet[1]
				aRet[1] := "0"
			Else
				aRet[1] := "-1"
			Endif

		Elseif Left(cIdPleres,1) == "R" .OR. Left(cIdPleres,1) == "U"


			// If Empty(cCgcPar) 		    ==> bloqueado 20210423 HFP-Compila
			// 20210423-HFP-Caompila 		 ==> Incluido validacao conforme task https://compilabr.teamwork.com/#/tasks/21869297
			//                             ==> validacao abaixo --> (CNPJ_PARCEIRO = CNPJ_UNIDADE_PRESTADORA (ALIANÇA))
			If Empty(cCgcPar) .OR. cCgcFil ==  cCgcPar   //    
				If 	Left(cIdPleres,1) == "U"
					aRet := U_CP16JNFS(cCgcFil,cIdPleres,cSerie,cDoc,cChvNfe,cDatEmi,cNFElet)
				Else	
					aRet := U_CP16JNFB(cCgcFil,cIdPleres,cSerie,cDoc,cChvNfe,cDatEmi,cNFElet)
				Endif
			Else	 
				aRet := U_CP16JNFD(cCgcFil,cIdPleres,cSerie,cDoc,cChvNfe,cDatEmi,nVlrBrt)
			Endif
			
			If aRet[1]
				aRet[1] := "0"
			Else
				aRet[1] := "-1"
			Endif
		Endif
		
		If !( Left(cIdPleres,1) == "V" .AND. Empty(cNFElet))
			DBSELECTAREA("SZK")
			SZK->(DBSETORDER(1)) //|
			IF SZK->(DBSEEK(SM0->M0_CODIGO + SC5->C5_FILIAL)) .AND. SZK->ZK_FATPJAU == "S"
				IF !EMPTY(cChvNfe)
					/*----------------------------------------
						28/08/2018 - Jonatas Oliveira - Compila
						Cria Fila de Processamento Atualização de Nota- Fluig
					------------------------------------------*/
					IF SA1->(DBSEEK( XFILIAL("SA1") + SC5->( C5_CLIENTE + C5_LOJACLI ) )) .AND. SA1->A1_PESSOA == "J" .AND. SZK->ZK_PREFONL == "S"
						//|Cria Fila de Processamento Atualização de Nota- Fluig|
						U_CP12ADD("000029", "SF2", SF2->(RECNO()), , )
					ENDIF 
				ENDIF 
			ENDIF  
			

			If Alltrim(aRet[1]) ==  "0"

				ConOut("*********************************************************")
				ConOut("* FSFATP07 - Filial: " + cFilAnt + " - ID: " + cIdPleres+" - " + DtoC(Date()) + " - " + Time() + " Retorno do webservice "+aRet[1])
				ConOut("* F2_XINTPLE inicial " + SF2->F2_XINTPLE )
				ConOut("*********************************************************")						

				//Inclui flag de integração com sistema Pleres.
				
				if !lExcNF
					cIntPle := Iif(Empty(cChvNfe), "1", "2")
					
					/*----------------------------------------
						28/08/2018 - Jonatas Oliveira - Compila
						Cria Fila de Processamento Atualização de Nota- Fluig
					------------------------------------------*/
					/*
					IF !EMPTY(cChvNfe)
						//|Cria Fila de Processamento Atualização de Nota- Fluig|
						U_CP12ADD("000020", "SF2", SF2->(RECNO()), , )
					ENDIF 
					*/
				Else	
					cIntPle := "3" // Exclui NF
				Endif	
				
				/// Grava dados na SF2
				If UpdSF2Stat((cAliTmp)->F2RECNO, cIntPle , cIdPleres)
					ConOut("*********************************************************")
					ConOut("* FSFATP07 - Filial: " + cFilAnt + " - ID: " + cIdPleres+" - " + DtoC(Date()) + " - " + Time() + "Integrado com sucesso!")
					ConOut("* F2_XINTPLE alterado para " + SF2->F2_XINTPLE )
					ConOut("*********************************************************")			
				Else
					ConOut("*********************************************************")
					ConOut("* FSFATP07 - Filial: " + cFilAnt + " - ID: " + cIdPleres+" - " + DtoC(Date()) + " - " + Time() + "Nao foi alterado no Protheus!")
					ConOut("*********************************************************")
				Endif						
				
				(cAliTmp)->( DBSkip() )
			Else
				cMensLog 	:= ""
				cMensLog 	+= aRet[2] + CRLF

				ConOut("*********************************************************")
				ConOut("* FSFATP07 - Filial: " + cFilAnt + " - ID: " + cIdPleres+" - " + DtoC(Date()) + " - " + Time() + "Erro ao Integrar ID: " + cIdPleres)
				ConOut("* "+cMensLog)
				ConOut("********************************************************") 
				
				
				/*------------------------------------------------------ Augusto Ribeiro | 21/03/2017 - 7:17:02 PM
					Caso falha ocorra em função de Timeout, desconsidera Filial para otimizar performance da 
					integração.
					Filial será reprocessada na próxima execução do JOB
				------------------------------------------------------------------------------------------*/
				IF 'WSCERR044' $ UPPER(aRet[2])
					cLogFull	+= aRet[2]+CRLF
					cFilErro	:= (cAliTmp)->F2_FILIAL
					While !((cAliTmp)->( EOF() )) .AND. cFilErro == (cAliTmp)->F2_FILIAL
						(cAliTmp)->( DBSkip() )		
					ENDDO
				ELSEIF LEFT(ALLTRIM(cIdPleres),1) $ "U/R" .AND. Empty((cAliTmp)->F2_NFELETR)  
					(cAliTmp)->( DBSkip() )	
				ELSE
					//| Reposiciona no SF2|
					SF2->(DBGoTo((cAliTmp)->F2RECNO))
					RECLOCK("SF2",.F.)
						SF2->F2_XINTPLE	:= "9" //| 9 = FALHA |
					MSUNLOCK()

					dbSelectArea("ZJ1")
					ZJ1->(DBSetOrder(1))	
					
					RecLock("ZJ1", ZJ1->(!DbSeek("SF2"+cValToChar((cAliTmp)->F2RECNO))) ) 
						ZJ1->ZJ1_CODIGO := If(Empty(ZJ1->ZJ1_CODIGO),GetSxeNum("ZJ1","ZJ1_CODIGO"),ZJ1->ZJ1_CODIGO) 
						ZJ1->ZJ1_TABORI := "SF2"
						ZJ1->ZJ1_RECALI := cValToChar( (cAliTmp)->F2RECNO )
						ZJ1->ZJ1_MSGLOG := aRet[2]
					ZJ1->(MSUNLOCK())
					CONFIRMSX8()

					(cAliTmp)->( DBSkip() )			
				ENDIF
				
			EndIf
		Else
			(cAliTmp)->( DBSkip() )		
		Endif
	EndDo
	
	(cAliTmp)->( DBCloseArea() )
	

	If !lRet
		cMensLog += "Sem dados para Processar!"
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


/*{Protheus.doc} UpdXBLQ


@author Guilherme Santos
@since 18/10/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function UpdSF2Stat(nSF2Rec,cIntPle,cIdPle)
Local lRet 		:= .t.
Local cUpdate		:= ""

	//Exclusao dos movimentos de simulacao
	//Via Update pois as filiais dos movimentos dependem da filial do Bem a ser depreciado
	cUpdate := " UPDATE "+RetSQLName("SF2")+" " 
	cUpdate += " SET 	F2_XINTPLE = '"+cIntPle+"', "
	cUpdate += " 		F2_XIDPLE = '"+cIdPle+"' "
	cUpdate += " WHERE R_E_C_N_O_ = " +  Alltrim(Str( nSF2Rec ))

	If TCSqlExec(cUpdate) < 0
		Conout(TcSqlError())
		lRet := .F.
	Else
		TcSqlExec( "COMMIT" )
	Endif	

Return lRet
