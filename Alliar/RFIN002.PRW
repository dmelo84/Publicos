#Include "PROTHEUS.Ch"
#INCLUDE "FWCOMMAND.CH"




/*/{Protheus.doc} rfin002
Relatório Contas a Pagar
@author Augusto Ribeiro | www.compila.com.br
@since 24/10/2016
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function RFIN002()
Local aRet		:= {.F., ""}
Local nI

Private _aRFIN02	:= {}
Private cLeng, nValBrut	, cContaPgto , cIdFluig
Private aLegFun		:= Fa040Legenda("SE2")
Private aRetLen 	:= {}

IF !EMPTY(_aRFIN02)
	aLegFun	:= aClone(_aRFIN02)
ENDIF

For nI := 1 TO len(aLegFun)	
	AADD(aRetLen,{ALLTRIM(STR(nI)),aLegFun[nI][3]})	
Next nI

// AjustaSX1()

oReport := ReportDef()
If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf

oReport:PrintDialog()
	
Return(aRet)


/*/{Protheus.doc} ReportDef
Realiza a impressao do relatorio
@author Augusto Ribeiro | www.compila.com.br
@since 24/10/2016
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef()
Local cPerg		:= "RFIN02"    


cDescRel	:= "Relatório Titulos a Pagar"+CRLF

oReport := TReport():New("RFIN002","Contas a Pagar" , cPerg , {|oReport| ReportPrint(oReport)} ,cDescRel)
oReport:SetLandscape()
oReport:SetTotalInLine(.F.) 

AjustSX1(cPerg)
Pergunte(oReport:uParam,.F.)


/*--------------------------
	SESSAO 01 - FILIAL
---------------------------*/
/*
oSection1 := TRSection():New(oReport,"Filial",{"SM0"})
TRCell():New(oSection1,"M0_CODFIL"		,"SM0","Cod.Filial"	,		,13) 
TRCell():New(oSection1,"M0_FILIAL"		,"SM0","Filial"	,			,44)

oSection1:NCLRBACK 	:= 14737632 // 13092807
oSection1:SetHeaderSection(.T.)
*/
/*--------------------------
	SESSAO 02 - TITULOS
---------------------------*/
oSection1 := TRSection():New(oReport,"Titulos",{"SE2","SA2"})

TRCell():New(oSection1,"M0_CODFIL"		,"SM0"	,"Cod.Filial"			,,15) 
TRCell():New(oSection1,"M0_FILIAL"		,"SM0"	,"Filial"				,,44)
TRCell():New(oSection1,"E2_TIPO"		,"SE2"	,"TP"					,,,.F.,)  				//"TP"
TRCell():New(oSection1,"TITULO"			,	  	,"Prf/Numero/Parcela"	,,15,.F., {|| SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA) } ) 		//"Prf-Numero" + "Parcela"

TRCell():New(oSection1,"F1_XIDFLG"		,"SF1"	,"ID Fluig"				,,30,.F., {|| cIdFluig })

TRCell():New(oSection1,"STATUS"			, 		,"Situação"				,,30,.F., {|| cLeng})  				//"STATUS"
TRCell():New(oSection1,"ED_CODIGO"		,"TSQL"	,"Cod.Natureza"			,,,.F.,)  			
//TRCell():New(oSection2,"ED_DESCRIC"	,"TSQL"	,"Natureza"				,,30,.F.,)  				
TRCell():New(oSection1,"A2_COD"			,"TSQL"	,"Cod./Loja"			,,10,.F.,{|| TSQL->(A2_COD+A2_LOJA) } )  			
TRCell():New(oSection1,"A2_NOME"		,"TSQL"	,"Fornecedor"			,,40,.F.)

TRCell():New(oSection1,"E2_EMIS1"		,"SE2"	,"Dt.Entrada"			,,12,.F.,)  
TRCell():New(oSection1,"E2_EMISSAO"		,"SE2"	,"Dt.Emissao"			,,12,.F.,)  
TRCell():New(oSection1,"E2_VENCTO"		,"SE2"	,"Dt.Vencto"			,,12,.F.,)
TRCell():New(oSection1,"E2_BAIXA"		,"SE2"	,"Dt.Baixa"				,,12,.F.,)    

TRCell():New(oSection1,"E2_VLCRUZ"		,"SE2"	,"Vlr.Bruto"			,,12,.F.,{|| nValBrut} )
TRCell():New(oSection1,"E2_VALOR"		,"SE2"	,"Vlr.Liquido"			,,12,.F.) //, {|| nValLiq})
TRCell():New(oSection1,"CONTA"			,		,"Conta Pgto"			,,16,.F., {|| cContaPgto})
TRCell():New(oSection1,"E2_NUMBOR"		,"SE2"	,"Borderô"				,,10,.F.,)

//TRFunction():New(oSection2:Cell("E2_VALOR"),"","SUM",,,,,.F.,.F.)

TRFunction():New(oSection1:Cell("E2_VLCRUZ")	,"@E 999,999.99","SUM",,,,,.T.,.F.,.F.)
TRFunction():New(oSection1:Cell("E2_VALOR")		,"@E 999,999.99","SUM",,,,,.T.,.F.,.F.)

oSection1:SetTotalText(" ")
oSection1:SetTotalInLine(.F.)

Return(oReport)



/*/{Protheus.doc} ReportPrint
Realiza a impressão do relatorio
@author Augusto Ribeiro | www.compila.com.br
@since 24/10/2016
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportPrint(oReport)
Local oSection1	:=	oReport:Section(1) 
//Local oSection2	:=	oReport:Section(1):Section(1)
Local nCount	:= 0
Local cFiltr	:= ""

Private aSelFil	:= {}
//Private aLegenda	:= {}

Private CCADASTRO	:= "Titulos a pagar"

dbSelectarea("SM0")
dbSelectarea("SE2")
dbSelectarea("SE5")




//AdmSelecFil("FIN150",38,.F.,@aSelFil,"SE2",.F.)
aSelFil := AdmGetFil(.F.,.F.,"SE2")
If Empty(aSelFil)
	Aadd(aSelFil,cFilAnt)
Endif

MsgRun("Verificando titulos",, {|| qTitulos(aSelFil) } )

IF TSQL->(!EOF())

	/*--------------------------
		Busca dados da legenda
	---------------------------*/
	//aLegFun	:= Fa040Legenda("SE2")
	nLeng	:= len(aLegFun)
	
	TSQL->(DBGoTop())	
	TSQL->( dbEval( {|| nCount++ } ) )	
	TSQL->(DBGoTop())
	

	/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE 
	-----------------------------------------*/
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	 	
	
	
	oReport:SetMeter(nCount)
	oReport:StartPage()
	
	oSection1:Init()	
	
	DBSELECTAREA("SF1")
	SF1->(DBSETORDER(1))//|F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA|
	
	DBSELECTAREA("SE2")
	
	//|Filtro de acordo com as situações informadas| 
	FOR nI := 1 TO nLeng	
		cFiltr	+= aLegFun[nI, 1] 
		
		IF nI <  nLeng
			cFiltr	+= " .OR. "
		ENDIF 
	NEXT nI
	
	
	WHILE TSQL->(!EOF())
		
		cIdFluig := ""
		
		If oReport:Cancel()
			Exit
		EndIf
						
		/*---------------------------------------
			Realiza a TROCA DA FILIAL CORRENTE 
		-----------------------------------------*/
		_cFilNew	:= TSQL->E2_FILIAL //| CODIGO DA FILIAL DE DESTINO 
		
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF
		
		SE2->(DBGOTO(TSQL->SE2_RECNO))
		
		//aLegend	:= Fa040Legenda("SE2")
		DBSELECTAREA("SE2")
		FOR nI := 1 TO nLeng
			IF &(aLegFun[nI, 1])
				cLeng	:= aLegFun[nI, 3]
				exit
			ENDIF
		NEXT nI
		
		oReport:IncMeter()
		
		//oSection2:Init()  
		
		//cQuebra	:= TSQL->E2_FILIAL
		
		IF &(cFiltr)
		
			//IF SF1->(DBSEEK(SE2->(E2_FILIAL + E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA )))
			cIdFluig := TSQL->F1_XIDFLG
				
			//ENDIF 	
				
			//| Retorna Banco, agencia e conta de pagamento |
			cContaPgto	:= ""
			IF !EMPTY(SE2->E2_BAIXA)
				cContaPgto	:= retConta(SE2->E2_FILIAL,SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_TIPO)
			ENDIF
		
			//nValLiq	:= SE2->E2_VLCRUZ// - SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,dDataBase,SE2->E2_FORNECE,SE2->E2_LOJA)
			
			nValBrut	:=  xMoeda(SE2->E2_VALOR,SE2->E2_MOEDA,SE2->E2_MOEDA,SE2->E2_EMISSAO,2, nil) //* If(SE2->E2_TIPO$MV_CPNEG+"/"+MVPAGANT, -1,1)
		
			oSection1:PrintLine()		
		ENDIF 
		
		TSQL->(DBSKIP())		
	
	ENDDO	
	
	/*---------------------------------------
	Restaura FILIAL  
	-----------------------------------------*/
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)			 			
	ENDIF   
	
	
	oSection1:Finish()
	oReport:EndPage()
	
ENDIF

Return(oReport)




/*/{Protheus.doc} qTitulos
Executa Query com a consulta
@author Augusto Ribeiro | www.compila.com.br
@since 24/10/2016
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qTitulos(aSeFIl)
Local cQuery := ""
Local nI 
Local cInFil	:= ""

for nI := 1 to Len(aSeFIl)

	IF !EMPTY(cInFil)
		cInFil	+= ","
	ENDIF
	cInFil	+= "'"+aSeFIl[nI]+"'"
next

cInFil	:= "("+cInFil+")"


cQuery := " SELECT SE2.R_E_C_N_O_  AS SE2_RECNO, "+CRLF
cQuery += " 		E2_FILIAL, "+CRLF
cQuery += " 		A2_COD, "+CRLF
cQuery += " 		A2_LOJA, " +CRLF
cQuery += " 		A2_NOME, "+CRLF
cQuery += " 		ED_CODIGO, "+CRLF
cQuery += " 		ED_DESCRIC, F1_XIDFLG "+CRLF

cQuery += " FROM "+RetSqlName("SE2")+" SE2 "+CRLF

cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 "+CRLF
cQuery += " 	ON SA2.A2_FILIAL = '' "+CRLF
cQuery += " 	AND SA2.A2_COD = E2_FORNECE "+CRLF
cQuery += " 	AND SA2.A2_LOJA = E2_LOJA "+CRLF
cQuery += " 	AND SA2.D_E_L_E_T_ = '' "+CRLF

cQuery += " LEFT JOIN "+Retsqlname("SF1")+" F1 "+CRLF
cQuery += " 	ON E2_FILIAL = F1_FILIAL "+CRLF 
cQuery += " 	AND E2_NUM = F1_DOC "+CRLF
cQuery += " 	AND E2_PREFIXO = F1_SERIE "+CRLF
cQuery += " 	AND E2_FORNECE = F1_FORNECE "+CRLF
cQuery += " 	AND E2_LOJA = F1_LOJA "+CRLF
cQuery += " 	AND F1.D_E_L_E_T_ = '' "+CRLF
cQuery += " 	AND F1_DTDIGIT BETWEEN '"+ DTOS(MV_PAR06) +"' AND '"+ DTOS(MV_PAR07) +"' "+CRLF
cQuery += " 	AND F1_XIDFLG BETWEEN '"+ MV_PAR16 +"' AND '"+ MV_PAR17 +"' "+CRLF

cQuery += " INNER JOIN "+RetSqlName("SED")+" SED "+CRLF

IF EMPTY(XFILIAL("SED"))
	cQuery += " 	ON SED.ED_FILIAL = '' "+CRLF
ELSE
	cQuery += " 	ON SED.ED_FILIAL = SE2.E2_FILIAL "+CRLF
ENDIF

cQuery += " 	AND SED.ED_CODIGO = SE2.E2_NATUREZ "+CRLF
cQuery += " 	AND SED.D_E_L_E_T_= '' "+CRLF

cQuery += " WHERE E2_FILIAL IN "+cInFil +CRLF
//cQuery += " 	AND E2_TIPO = 'NF' " +CRLF
cQuery += " 	AND E2_FORNECE BETWEEN '"+ MV_PAR08 +"' AND '"+ MV_PAR10 +"' "+CRLF
cQuery += " 	AND E2_LOJA BETWEEN '"+ MV_PAR09 +"' AND '"+ MV_PAR11 +"' "+CRLF
cQuery += " 	AND E2_NATUREZ BETWEEN '"+ MV_PAR12 +"' AND '"+ MV_PAR13 +"' "+CRLF
cQuery += " 	AND E2_EMISSAO BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"' "+CRLF
cQuery += " 	AND E2_VENCREA BETWEEN '"+ DTOS(MV_PAR03) +"' AND '"+ DTOS(MV_PAR04) +"' "+CRLF
cQuery += " 	AND E2_NUMBOR BETWEEN '"+ MV_PAR16 +"' AND '"+ MV_PAR17 +"' "+CRLF

cQuery += " 	AND SE2.D_E_L_E_T_ = '' "+CRLF

cQuery += " order by E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA "+CRLF

MemoWrite(GetTempPath(.T.) + "RFIN002.SQL", cQuery) 

If Select("TSQL") > 0
	TSQL->(DbCloseArea()) 
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						


Return()



/*/{Protheus.doc} retConta
Retorna Banco, Agencia e conta do ultimo pagamento 
@author Augusto Ribeiro | www.compila.com.br
@since 24/10/2016
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function retConta(cFil,cPref, cNum,cParc, cFor, cLoja, cTipo)
Local cRet	:= ""
Local cQuery := ""

cQuery := " SELECT MAX(R_E_C_N_O_)  AS SE5_RECNO "
cQuery += " FROM "+RetSqlName("SE5")+" SE5  "
cQuery += " WHERE E5_FILORIG = '"+cFil+"' "
cQuery += " AND SE5.E5_PREFIXO = '"+cPref+"'   "
cQuery += " AND SE5.E5_NUMERO = '"+cNum+"' "
cQuery += " AND SE5.E5_PARCELA = '"+cParc+"'   "
cQuery += " AND SE5.E5_CLIFOR = '"+cFor+"' "
cQuery += " AND SE5.E5_LOJA = '"+cLoja+"'   "
cQuery += " AND SE5.E5_TIPO = '"+cTipo+"'   "
cQuery += " AND SE5.E5_TIPODOC IN('BA','VL') " //IN ('BA','VL', 'PA') "
cQuery += " AND SE5.E5_RECPAG = 'P'   "
cQuery += " AND SE5.E5_SITUACA <> 'C' "
cQuery += " AND SE5.D_E_L_E_T_ = ''   "


If Select("TTMP") > 0
	TTMP->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TTMP",.F., .T.)						


IF TTMP->(!EOF())
	IF !EMPTY(TTMP->SE5_RECNO)
		SE5->(DBGOTO(TTMP->SE5_RECNO))	 
		
		cRet	:= SE5->E5_BANCO+" "+SE5->E5_AGENCIA+" "+SE5->E5_CONTA
	ENDIF
ENDIF	

TTMP->(DbCloseArea())

Return(cRet)











//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FA040LEGENDA

Legenda do SE1 - Contas a Receber
Arquivo original: FINXATU.PRX 

@param cLoteFin - número do lote par cálculo da Soma1.

@Author	Wagner Mobile Costa
@since	22/10/2001
/*/
//-----------------------------------------------------------------------------------------------------

#DEFINE STR0003 "Titulo em aberto"
#DEFINE STR0004 "Baixado parcialmente"
#DEFINE STR0005 "Titulo Baixado"
#DEFINE STR0006 "Titulo em Bordero"
#DEFINE STR0007  "Adiantamento com saldo"
#DEFINE STR0008 "Titulo baixado parcialmente e em bordero"
#DEFINE STR0009 "Adiantamento com resíduo no saldo"
#DEFINE STR0010 "Adiantamento gerado por Nota Fiscal"
#DEFINE STR0011 "Titulo com operacão de adiantamento"
#DEFINE STR0012 "Titulo Protestado"
#DEFINE STR0013 "Titulo aguardando liberacao"
#DEFINE STR0014 "Titulo com operacão de adiantamento"
#DEFINE STR0046 "46"
#DEFINE STR0066 "Legenda"
#DEFINE STR0070 "Titulo Vinculado a Docto Hábil"
#DEFINE STR0072 "Adiantamento de Imp. Bx. com saldo"
#DEFINE STR0073 "Adiantamento de Viagem sem taxa"
#DEFINE STR0074 "Titulo aguardando liberacao"




 
Static Function Fa040Legenda(cAliAux, nReg)
Local lPrjCni 	:= ValidaCNI()

Local uRetorno := .T.
Local aLegenda := { 	{"BR_VERDE", 	STR0003 },;	//1.  "Titulo em aberto"
						{"BR_AZUL", 	STR0004 },;	//2.  "Baixado parcialmente"
						{"BR_VERMELHO", STR0005 },;	//3.  "Titulo Baixado"
						{"BR_PRETO", 	STR0006 },;	//4.  "Titulo em Bordero"
						{"BR_BRANCO", 	STR0007 },;	//5.  "Adiantamento com saldo"
						{"BR_CINZA",	STR0008 },; //6. "Titulo baixado parcialmente e em bordero"
						{"BR_AMARELO", STR0072} } 	//7. "Adiantamento de Imp. Bx. com saldo"

// Ponto de Entrada permite visualizar na legenda se um titulo de PA possue residuos de saldo.						
Local lFaLegPares := ExistBlock("FaLegPARes") .And. ExecBlock("FaLegPARes",.f.,.f.)

Local lF040ADLE := ExistBlock("F040ADLE")
Local lFinaleg	:= ExistBlock("FINALEG")
Local lF040URET := ExistBlock("F040URET")




IF lFaLegPares	.And. cAliAux == "SE2"
	Aadd(aLegenda,{"BR_MARROM",STR0009}) //"Adiantamento com resíduo no saldo"
Endif	
If lF040ADLE .And. nReg != Nil
	aLegNew := ExecBlock("F040ADLE",.F.,.F.,aLegenda)
	If ValType(aLegNew) == "A"
		aEval(aLegNew,{|J| aAdd(aLegenda,{J[1],J[2]}) })
	Endif
Endif

If lFinaleg
	uRetorno := ExecBlock("FINALEG",.F.,.F.,{nReg,cAliAux})
Else
	If nReg == Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
		uRetorno := {}
		If cAliAux == "SE1"   
		
	   		If cPaisLoc == "MEX" .And. X3Usado("ED_OPERADT")
				Aadd(aLegenda, {"BR_PINK"	,STR0010}) //7.  "Adiantamento gerado por Nota Fiscal"
				Aadd(aLegenda, {"BR_LARANJA",STR0011}) //8.  "Titulo com operacão de adiantamento"
			EndIf 
			
			Aadd(aLegenda, {"BR_AMARELO", STR0012})  //"Titulo Protestado"
			Aadd(uRetorno, { 'ROUND(E1_SALDO,2) = 0'													, aLegenda[3][1]				, aLegenda[3][2]} ) //"Titulo Baixado" 
			Aadd(uRetorno, { '!Empty(E1_NUMBOR) .and.(ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2))'			, aLegenda[6][1]				, aLegenda[6][2]}  ) //"Titulo baixado parcialmente e em bordero"
			Aadd(uRetorno, { 'E1_TIPO == "'+MVRECANT+'".and. ROUND(E1_SALDO,2) > 0 .And. !FXAtuTitCo()'	, aLegenda[5][1]				, aLegenda[5][2]} ) //"Adiantamento com saldo"
			Aadd(uRetorno, { '!Empty(E1_NUMBOR)'														, aLegenda[4][1]				, aLegenda[4][2]} ) //"Titulo em Bordero"
			Aadd(uRetorno, { 'ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2) .And. !FXAtuTitCo()'				, aLegenda[2][1]				, aLegenda[2][2]} ) //"Baixado parcialmente"
			Aadd(uRetorno, { 'ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .and. E1_SITUACA == "F"'			, aLegenda[Len(aLegenda)][1]	,aLegenda[Len(aLegenda)][2]} ) //"Titulo Protestado"

			If cPaisLoc == "MEX" .And. X3Usado("ED_OPERADT")
				Aadd(uRetorno, {	'E1_ORIGEM == "MATA467N" .And. ROUND(E1_SALDO,2) > 0 .And. FXAtuTitCo()'									, aLegenda[7][1], aLegenda[7][2] } )
				Aadd(uRetorno, {	'E1_ORIGEM == "FINA087A" .And. ROUND(E1_SALDO,2) > 0 .And. FXAtuTitCo() .And. E1_TIPO == "'+MVRECANT+'"'	, aLegenda[8][1], aLegenda[8][2] } )
			EndIf       
			
			If !lF040URET
				Aadd(uRetorno, { '.T.', aLegenda[1][1], aLegenda[1][2] } )
			Endif
		Else
			If lPrjCni
				IF !Empty(GetMv("MV_APRPAG")) .or. GetMv("MV_CTLIPAG")           
					Aadd(aLegenda, {"BR_AMARELO", STR0013})  //"Titulo aguardando liberacao"
					Aadd(uRetorno, { ' EMPTY(E2_DATALIB) .AND. (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > GetMV("MV_VLMINPG") .AND. E2_SALDO > 0', aLegenda[Len(aLegenda)][1], aLegenda[Len(aLegenda)][2] } ) 
				EndIf
			Else
				IF GetMv("MV_CTLIPAG")           
					Aadd(aLegenda, {"BR_AMARELO", STR0074})	//"Titulo aguardando liberacao" 
					Aadd(uRetorno, { ' !( SE2->E2_TIPO $ MVPAGANT ).and. EMPTY(E2_DATALIB) .AND. (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > GetMV("MV_VLMINPG") .AND. E2_SALDO > 0', aLegenda[Len(aLegenda)][1], aLegenda[Len(aLegenda)][2] } ) 
				EndIf
			EndIf
			
			Aadd(aLegenda, {"BR_LARANJA", STR0073}) //"Adiantamento de Viagem sem taxa"
			Aadd(uRetorno, { ' (ALLTRIM(SE2->E2_ORIGEM) $ "FINA667|FINA677") .and. SE2->E2_MOEDA > 1 .AND. SE2->E2_TXMOEDA == 0 .AND. SE2->E2_SALDO > 0', aLegenda[Len(aLegenda)][1], aLegenda[Len(aLegenda)][2] } )
			
			IF lFaLegPares
				Aadd(aLegenda,{"BR_MARROM",STR0046})
				Aadd(uRetorno, { 'E2_TIPO == "'+MVPAGANT+'" .and. ROUND(E2_SALDO,2) > 0 .And. (ROUND(E2_SALDO,2) < ROUND(E2_VALOR,2))', aLegenda[Len(aLegenda)][1], aLegenda[Len(aLegenda)][2] } )										
			Endif								
			
			//Validação para uso do documento hábil - SIAFI
			If FinUsaDH()
				Aadd(aLegenda,{"BR_VIOLETA",STR0070}) // "Titulo Vinculado a Docto Hábil"
				Aadd(uRetorno, { 'ROUND(E2_SALDO,2) > 0 .And. !EMPTY(E2_DOCHAB)'	, aLegenda[Len(aLegenda)][1], aLegenda[Len(aLegenda)][2]				} ) //"Titulo relacionado ao Documento hábil"
			Endif
			Aadd(uRetorno, { 'E2_TIPO $ "INA/'+MVTXA+'" .and. ROUND(E2_SALDO,2) > 0 .And. E2_OK == "TA"  ', aLegenda[7][1], aLegenda[7][2] } )
			Aadd(uRetorno, { 'E2_TIPO == "'+MVPAGANT+'" .and. ROUND(E2_SALDO,2) > 0', aLegenda[5][1], aLegenda[5][2] } )			
			Aadd(uRetorno, { 'ROUND(E2_SALDO,2) + ROUND(E2_SDACRES,2)  = 0', aLegenda[3][1], aLegenda[3][2] } )
			Aadd(uRetorno, { '!Empty(E2_NUMBOR) .and.(ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2))', aLegenda[6][1], aLegenda[6][2] } )						
			Aadd(uRetorno, { '!Empty(E2_NUMBOR)', aLegenda[4][1], aLegenda[4][2] } )
			Aadd(uRetorno, { 'ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2)', aLegenda[2][1], aLegenda[4][2] } )
			If !lF040URET
				Aadd(uRetorno, { '.T.', aLegenda[1][1], aLegenda[1][2] } )
			Endif
		Endif
	Else
		If cAliAux == "SE1"  
			If cPaisLoc == "MEX" .And. X3Usado("ED_OPERADT")
				Aadd(aLegenda, {"BR_PINK"	,STR0010}) //7.  "Adiantamento gerado por Nota Fiscal"
				Aadd(aLegenda, {"BR_LARANJA",STR0014}) //8.  "Titulo com operacão de adiantamento"
			EndIf
			Aadd(aLegenda,{"BR_AMARELO", STR0012}) //"Titulo Protestado" 
	    Else 
			If lPrjCni
		    	IF !Empty(GetMv("MV_APRPAG")) .or. GetMv("MV_CTLIPAG")    
		    		Aadd(aLegenda, {"BR_AMARELO",  STR0013})		//"Titulo aguardando liberacao"  
		    	EndIf
			Else
		    	IF GetMv("MV_CTLIPAG")    
		    		Aadd(aLegenda, {"BR_AMARELO",  STR0013})		//"Titulo aguardando liberacao"  
		    	EndIf
			Endif
			
			IF lFaLegPares
				Aadd(aLegenda,{"BR_MARROM",STR0046})
			Endif
			
			//Validação para uso do documento habil (SIAFI)
			If FinUsaDH()
				Aadd(aLegenda,{"BR_VIOLETA",STR0070}) // "Titulo Vinculado a Docto Hábil"
			Endif
		EndIf
		BrwLegenda(cCadastro, STR0066, aLegenda)		//"Legenda"
	Endif
Endif

If lF040URET .And. ValType(uRetorno) == "A"
	uRetNew := ExecBlock("F040URET",.F.,.F.,{uRetorno,aLegenda})
	If ValType(uRetNew) = "A"
		aEval(uRetNew,{|J| aAdd(uRetorno,{J[1],J[2]}) })
		Aadd(uRetorno, { '.T.', aLegenda[1][1] } )
	Endif
Endif

Return uRetorno




/*/{Protheus.doc} AjustSX1
Ajusta as Perguntas.  
@author Jonatas Oliveira | www.compila.com.br
@since 08/11/2016
@version 1.0
/*/
Static Function AjustSX1(cPerg)
	Local aArea := GetArea()
	Local aHelpPor	:= {}
	Local aHelpEng 		:= {}
	Local aHelpSpa	:= {}

	aAdd( aHelpEng, "  ")
	aAdd( aHelpSpa, "  ")


	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao De")
	PutSx1(cPerg,"01","Data Emissao De?"		 	,"Data Emissao De?"		,"Data Emissao De?"			,"mv_ch1","D",08					,00,0,"G","NaoVazio"			,""		,""	,"","mv_par01",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )	
	
	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao Ate")
	PutSx1(cPerg,"02","Data Emissao Ate ?"			,"Data Emissao Ate?"	,"Data Emissao Ate?"		,"mv_ch2","D",08					,00,0,"G","NaoVazio"			,""		,""	,"","mv_par02",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
		
	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Vencimento De")
	PutSx1(cPerg,"03","Data Vencimento De?"		 	,"Data Vencimento De?"	,"Data Vencimento De?"		,"mv_ch3","D",08					,00,0,"G","NaoVazio"			,""		,""	,"","mv_par03",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )	
	
	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Vencimento Ate")
	PutSx1(cPerg,"04","Data Vencimento Ate ?"		,"Data Vencimento Ate?"	,"Data Vencimento Ate?"		,"mv_ch4","D",08					,00,0,"G","NaoVazio"			,""		,""	,"","mv_par04",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )	
	
	aHelpPor := {} ; Aadd( aHelpPor, "Situações de Titulo ")
	PutSx1( cPerg, "05","Situações ","Situações","Situações"	,"mv_ch5","C",60,0,0,"G","U_RFIN3ST","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Digitação De")
	PutSx1(cPerg,"06","Data Digitação De?"		 	,"Data Digitação De?"	,"Data Digitação De?"		,"mv_ch6","D",08					,00,0,"G",""					,""		,""	,"","mv_par06",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )	
	
	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Digitação Ate")
	PutSx1(cPerg,"07","Data Digitação Ate ?"		,"Data Digitação Ate?"	,"Data Digitação Ate?"		,"mv_ch7","D",08					,00,0,"G","NaoVazio"			,""		,""	,"","mv_par07",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Cod. Fornecedor De")
	PutSx1(cPerg,"08","Cod. Fornecedor De?"		 	,"Cod. Fornecedor De?"	,"Cod. Fornecedor De?"		,"mv_ch8","C",08					,00,0,"G",""					,"SA2"	,""	,"","mv_par08",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )	
	
	aHelpPor := {} ; Aadd( aHelpPor, "Cod. Loja De")
	PutSx1(cPerg,"09","Cod. Loja De?"		 		,"Cod. Loja De?"		,"Cod. Loja De?"			,"mv_ch9","C",TAMSX3("A2_LOJA")[1] ,00,0,"G",""						,""		,""	,"","mv_par11",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Cod. Fornecedor Ate")
	PutSx1(cPerg,"10","Cod. Fornecedor Ate?"		 ,"Cod. Fornecedor Ate?","Cod. Fornecedor Ate?"		,"mv_cha","C",08					,00,0,"G","NaoVazio"			,"SA2"	,""	,"","mv_par09",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Cod. Loja Ate")
	PutSx1(cPerg,"11","Cod. Loja Ate?"		 		,"Cod. Loja Ate?"		,"Cod. Loja Ate?"			,"mv_chb","C",TAMSX3("A2_LOJA")[1] ,00,0,"G",""						,""		,""	,"","mv_par11",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Natureza De")
	PutSx1(cPerg,"12","Cod. Natureza De?"		 	,"Cod. Natureza De?"	,"Cod. Natureza De?"		,"mv_chc","C",TAMSX3("ED_CODIGO")[1],00,0,"G",""					,"SED"	,""	,"","mv_par12",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Natureza Ate")
	PutSx1(cPerg,"13","Cod. Natureza Ate?"		 	,"Cod. Natureza Ate?"	,"Cod. Natureza Ate?"		,"mv_chd","C",TAMSX3("ED_CODIGO")[1],00,0,"G","NaoVazio"			,"SED"	,""	,"","mv_par13",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "ID Fluig De")
	PutSx1(cPerg,"14","Cod. ID Fluig De?"		 	,"Cod. ID Fluig De?"	,"Cod. ID Fluig De?"		,"mv_che","C",TAMSX3("F1_XIDFLG")[1],00,0,"G",""					,"SED"	,""	,"","mv_par14",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "ID Fluig Ate")
	PutSx1(cPerg,"15","Cod. ID Fluig Ate?"		 	,"Cod. ID Fluig Ate?"	,"Cod. ID Fluig Ate?"		,"mv_chf","C",TAMSX3("F1_XIDFLG")[1],00,0,"G","NaoVazio"			,"SED"	,""	,"","mv_par15",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Bordero De")
	PutSx1(cPerg,"16","Cod. Bordero De?"		 	,"Cod. Bordero De?"		,"Cod. Bordero De?"			,"mv_chg","C",TAMSX3("E1_NUMBOR")[1],00,0,"G",""					,""		,""	,"","mv_par16",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Bordero Ate")
	PutSx1(cPerg,"17","Cod. Bordero Ate?"		 	,"Cod. Bordero Ate?"	,"Cod. Bordero Ate?"		,"mv_chh","C",TAMSX3("E1_NUMBOR")[1],00,0,"G",""					,""		,""	,"","mv_par17",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
Return()



/*/{Protheus.doc} RFIN3ST
Busca os Situações de titulos utilizados 
@author Jonatas Oliveira | www.compila.com.br
@since 22/11/2016
@version 1.0
/*/
User Function RFIN3ST()
	Local _cRet	:= ""
	Local aCartoes	:= {}

	
	aCartoes := aRetLen
	_cRet := BrowX1("Situações", aCartoes)
	
	
Return() 



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AUGUSTO RIBEIRO                                             ³
//³                                                             ³
//³ Monta Pequeno Browser da Pergunta, permitindo que o usuário ³
//³selecione mais de uma opção.                                 ³
//³ Recebe Array com os elementos                               ³
//³ Retorna: ****                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function BrowX1(cTitBrw,aOpcoes)
	Local BrowX1	:= "Selecione"
	Local MvPar
	Local MvParDef	:=	""
	Local l1Elem   	:=	Nil
	Local lTipoRet	:= 	.T.
	Local cFilBack	:= cFilAnt
	
	Private _aFilial:=	{}
	Private aSit	:= 	{}
	
	l1Elem 			:= 	If (l1Elem = Nil , .F. , .T.)
	
	DEFAULT aOpcoes		:= {}
	
	IF LEN(aOpcoes) == 0
		Return
	ENDIF
	
	cAlias 			:= Alias() 					 // Salva Alias Anterior
	
	IF lTipoRet
		MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIF
	
	
	For nI := 1 To LEN(aOpcoes)
		
		aadd(aSit, aOpcoes[nI,1]+" - "+aOpcoes[nI,2])
		
		/*
		IF VALTYPE(aOpcoes[nI,1]) == "C"
			aadd(aSit, aOpcoes[nI,1]+" - "+aOpcoes[nI,2])
		ELSEIF IF VALTYPE(aOpcoes[nI,1]) == "N"
			aadd(aSit, ALLTRIM(STR(aOpcoes[nI,1])) + " - "+aOpcoes[nI,2])
		ENDIF
		*/
		MvParDef += aOpcoes[nI,1]
	Next nI
	
	
	
	// Tamanho dos caracters de retorno (Ex.: 04)
	nTam := LEN(aOpcoes[1,1])
	lComboBox := .T.
	IF lTipoRet
		IF f_Opcoes(@MvPar,BrowX1,aSit,MvParDef,12,49,l1Elem,nTam)	// Chama funcao f_Opcoes
			&MvRet := mvpar                                   			// Devolve Resultado
		EndIF
	EndIF
	
	dbSelectArea(cAlias) 	 // Retorna Alias
	
	cFilAnt	:= cFilBack 	// Retorna a empresa
	
Return( IF( lTipoRet , .T. , MvParDef ) )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AUGUSTO RIBEIRO                                  ³
//³                                                  ³
//³ Recebe String separa por caracter "X"            ³
//³ ou Numero de Caractres para "quebra" _nCaracX)   ³
//³ Retorna String pronta para IN em selects         ³
//³ Ex.: Retorn: ('A','C','F')                       ³
//³                                                  ³
//³ PARAMETROS:  _cString, _cCaracX                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function INQuery(_cString, _cCaracX, _nCaracX)
	Local _cRet	:= ""
	Local _cString, _cCaracX, _nCaracX, nY
	Local _aString	:= {}
	Default	_nCaracX := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida Informacoes Basicas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !EMPTY(_cString) .AND. (!EMPTY(_cCaracX) .OR. _nCaracX > 0)
		
		nString	:= LEN(_cString)
		
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza Separacao por Numero de Caracteres ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF _nCaracX > 0
			FOR nY := 1 TO nString STEP _nCaracX
				
				AADD(_aString, SUBSTR(_cString,nY, _nCaracX) )
				
			Next nY
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Utiliza Separacao por caracter especifico ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ELSE
			_aString	:= WFTokenChar(_cString, _cCaracX)
		ENDIF
		
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta String para utilizar com IN em querys³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cRet	+=  "('"
		FOR _nI := 1 TO Len(_aString)
			IF _nI > 1
				_cRet	+= ",'"
			ENDIF
			_cRet += ALLTRIM(_aString[_nI])+"'"
		Next _nI
		_cRet += ") "
		
	ENDIF
	
Return(_cRet)


