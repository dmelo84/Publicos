#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "Tbiconn.ch"
#INCLUDE "rwmake.ch"
#include "sigawin.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ORTA113 ³ Autor ³ Eduardo Brust         ³ Data ³12/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³ Fabr.Tradicional ³Contato ³ eduardo.brust@microsiga.com.br ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PROGRAMA PARA IMP0RTACAO DE DADOS PARA O MICROSIGA         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ortaimp01()

// Variaveis Locais da Funcao
Local aComboBx1	 := {"Cliente","Pedido Mãe","Expositores"}
Local cComboBx1


// Variaveis da Funcao de Controle e GertArea/RestArea
Local _aArea   		:= {}
Local _aAlias  		:= {}

PREPARE ENVIRONMENT EMPRESA '05' FILIAL '02' 
// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
Private nRadioGrp1	:= 1
Private oRadioGrp1
Private nPedImp     := 0
Private nPedErr     := 0
Private aDados 		:= {}
Private cCodCli 	:= space(6)
Private cLojCli 	:= "  "
Private cTipCli 	:= " "
Private cLocal  	:= "  "
Private cMedW    	:= ""
Private cDescP  	:= ""
Private cUm     	:= ""
Private cGrpCli 	:= ""
Private cGrProd 	:= ""
Private _aArray 	:= {}
Private _aArrayOk 	:= {}
Private lErro 		:= .F.
Private __nLinhas	:=	0
Private indice      := "Pedido Mãe"
Private cCondPag    := ""
Private cEst        := ""
Private cCorte      :=""
Private cLinha      :=""
// Variaveis que definem a Acao do Formulario
Private c_dirimp := space(100)
Private cRefTab  :=""
Private nPrVen   :=0
Private nValCus  :=0
Private cModelo  :=""
Private cTpConv  :=""
Private nConv    :=0
MSAguarde({|| impsc5() },"Importando Pedidos...")
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ IMPSC5   º Autor ³                    º Data ³  18/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao Para Importacao de Pedidos de Venda.                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpSC5

Local nTamFile, nTamLin, nBtLidos, nValHora
Private cArqTxt := c_dirimp
Private cEOL    := "CHR(13)+CHR(10)"
Private c_NumPed  // nr do pedido microsiga
Private aDados      := {}, j:= 1 , aCabPV  := {}, aItemPV := {}
Private cTransp  := ""
Private cTpFrete := ""
Private cCodCli  := ""
Private cLojCli  := ""
Private cTipCli  := ""
Private xCusto   := 0
Private xMarkup  := 0
Private xMix     := 0

aDados   := {}

//ProcRegua(nTamFile) // Numero de registros a processar

lFirst := .T.                                                                                                                          
lErro := .F.
cPedErr:=""
cQuery:="SELECT * FROM MSIGA@WORLDSYS WHERE DTVENDA > '20100501' AND CODPRO LIKE '2%' ORDER BY PEDIDO, CODPRO "
MEMOWRIT("C:\ORTA113.SQL",CQUERY)
tcquery cQuery alias "WORLD" NEW
dbselectarea("WORLD")
dbgotop()
Do While !EOF()
	cPedW :=STRZERO(WORLD->PEDIDO,7)
	cCnpjW:=ALLTRIM(WORLD->CNPJ)
	cSegW :=STRZERO(WORLD->SEG,1)
	cTabW :=STRZERO(VAL(WORLD->TAB),3)
	cPrzW :=WORLD->PRZ
	cFPgtW:=ALLTRIM(WORLD->FPGT)
	cEntrW:=WORLD->ENTREGA
	cVendW:="C"+ALLTRIM(WORLD->CODVEN)
	cProdW:=WORLD->CODPRO
	cQtdW :=WORLD->QTD
	cQtdSw:=WORLD->QTD
	cVlrW :=WORLD->VLR
	cMedW :=ALLTRIM(STRZERO(WORLD->LARG*1000,4)+"X"+STRZERO(WORLD->COMP*1000,4)+"X"+STRZERO(WORLD->ALT*1000,4))
	cMotW :=ALLTRIM(WORLD->MOTTRO)
	cObsPW:=WORLD->OBSP
	cObsIW:=WORLD->OBSI
	cTpPW :=alltrim(WORLD->TPPED)
	cDtVW :=stod(WORLD->DTVENDA)
	nCompW:=WORLD->COMP
	nAltW :=WORLD->ALT
	nLargW:=WORLD->LARG
	cFeirW:=WORLD->FEIRAO
	if !empty(WORLD->ENTREGA) .and. ALLTRIM(WORLD->ENTREGA)<>"LIVRE"
		cEntregW:=CTOD(SUBSTR(WORLD->ENTREGA,01,10))
		cEntrefW:=CTOD(SUBSTR(WORLD->ENTREGA,14,10))
	else
		cEntregW:=CTOD("  /  /  ")
		cEntrefW:=CTOD("  /  /  ")
	endif
	if cMotW=="00"
		cMotW:="  "
	endif
	if !empty(cPedErr) .and. cPedErr==cPedW
		dbselectarea("WORLD")
		dbskip()
		loop
	endif
	cPedErr:=""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Incrementa a regua                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//	IncProc()
	
	If !lFirst .and. Len(aCabPv) > 0 .and.  aCabPV[8][2]<> cPedW
		SC5->(dbOrderNickName("CSC57"))
		SC5->(dbGoTop())
		If !SC5->(dbSeek(xFilial("SC5")+aCabPV[8][2]))
			GravaPv()
		Else
			Aadd (_aArray,  {aCabPV[8][2],cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Pedido Ficha ja importado"})
			tcSqlExec("UPDATE H_PEDIDO@WORLDSYS SET DIGITADO = SYSDATE WHERE NUMERO = "+aCabPV[8,2])
			tcSqlExec("COMMIT")
			aCabPV  := {}
			aItemPV := {}
			cPedErr := aCabPV[8][2]
			++nPedErr
			dbselectarea("WORLD")
			dbskip()
			
			Loop
		Endif
	EndIf
	lFirst := .F.
	lErro  := .F.
	
	IF cSegW == "4"
		cSegW := "2"
	ENDIF
	SC5->(dbOrderNickName("CSC57"))
	SC5->(dbGoTop())
	If SC5->(dbSeek(xFilial("SC5")+cPedW,.F.))
		Aadd (_aArray,  {cPedW,cDtVW,"C"+Subs(cVendW,2,5)+"-"+Posicione("SA3",1,xFilial("SA3")+"C"+Subs(cVendW,2,5),"A3_NOME"),"Pedido Ficha ja importado"})
		tcSqlExec("UPDATE H_PEDIDO@WORLDSYS SET DIGITADO = SYSDATE WHERE NUMERO = "+cPedW)
		tcSqlExec("COMMIT")
		aDados  := {}
		aCabPV  := {}
		aItemPV := {}
		cPedErr:=cPedW
		++nPedErr
		dbselectarea("WORLD")
		dbskip()
		Loop
	EndIf
	DbSelectArea("SA1")
	dbOrderNickName("PSA13")
	If DbSeek(xFilial("SA1")+cCNPJW)
		cTransp  := SA1->A1_TRANSP
		cTpFrete := SA1->A1_TPFRET
		cCodCli  := SA1->A1_COD
		cLojCli  := SA1->A1_LOJA
		cTipCli  := SA1->A1_TIPO
		cGrpCli  := SA1->A1_GRPTRIB
		cEst     := SA1->A1_EST
		If	cTpPW == '03' .Or.	cTpPW == '05'
			cFPgtW	:=	SUBSTR(SA1->A1_XFORMPG,1,2)
		Else
			If !(cFPgtW $ SA1->A1_XFORMPG)
				Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Forma de Pagamento nao Permitida"+"-"+cFPgtW+"-CLiente: "+SA1->A1_COD})
				cPedErr:=cPedW
				aDados  := {}
				aCabPV  := {}
				aItemPV := {}
				lErro := .T.
				aDados := {}
				dbselectarea("WORLD")
				dbskip()
				Loop
			Endif
		Endif
	Else
		Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Cliente nao cadastrado" + "-" +cCnpjW})
		cPedErr:=cPedW
		aDados  := {}
		aCabPV  := {}
		aItemPV := {}
		++nPedErr
		dbselectarea("WORLD")
		dbskip()
		Loop
	EndIf
	
	//--------------------------------------------------
	// Tratamento para o segmento
	//--------------------------------------------------
	
	dbSelectArea("SZH")
	dbOrderNickName("CSZH5")
	If !dbSeek(xFilial("SZH")+cVendW+cCodCli+cLojCli+cSegW,.F.)
		Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Segmento nao cadastrado para este Vendedor / Cliente "+cCodcLi})
		cPedErr:=cPedW
		lErro := .T.
		aDados := {}
		aCabPV  := {}
		aItemPV := {}
		++nPedErr
		dbselectarea("WORLD")
		dbskip()
		Loop
	endif
	dbselectarea("PA2")
	dbsetorder(1)
	if !dbseek(xFilial("PA2")+cVendW+SZH->ZH_ITINER)
		if Empty(cRefTab)
			Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Referencia nao cadastrada para este Vendedor / Cliente "+cCodcLi})
			cPedErr:=cPedW
			lErro := .T.
			aDados := {}
			aCabPV  := {}
			aItemPV := {}
			++nPedErr
			dbselectarea("WORLD")
			dbskip()
			Loop
		endif
	else
		cRefTab:=PA2->PA2_REFTAB
	EndIf
	//Pegando a condicao de pagamento
	cCodCP := cPrzW
	cBusCP := ""
	For nI := 1 To Len(cCodCP)
		If cBusCP = ""
			cBusCP := SubStr(cCodCp,nI,3)
		Else
			If VAL(SubStr(cCodCp,nI,3)) > 0
				cBusCP += ","+SubStr(cCodCp,nI,3)
			EndIf
		EndIf
		nI := nI + 3
	Next
	
	cQueryE4 := ""
	cQueryE4 := " SELECT E4_CODIGO, E4_XPRZMED FROM "+RetSqlName("SE4")+" "  //Condição de Pagamento
	cQueryE4 += " WHERE D_E_L_E_T_ <> '*' "
	cQueryE4 += "    AND E4_FILIAL <= '" + xFilial("SE4") + "' "
	cQueryE4 += "    AND E4_XCOND    = '" + cBusCP        + "' "
	cQueryE4 += "    AND E4_XPRZMED <> '  ' "
	
	TCQUERY cQueryE4 ALIAS "QRYSE4" NEW
	dbselectarea("QRYSE4")
	dbgotop()
	if !eof() .and. !empty(QRYSE4->E4_CODIGO)
		cCondPag := QRYSE4->E4_CODIGO
		cPrzMed  := QRYSE4->E4_XPRZMED
	else
		cCondPag := ""
		Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Prazo de pagamento inexistente "+alltrim(cBusCP)})
		cPedErr:=cPedW
		aCabPV  := {}
		aItemPV := {}
		++nPedErr
		lErro := .T.
		aDados := {}
		dbCloseArea()
		dbselectarea("WORLD")
		dbskip()
		Loop
	endif
	dbCloseArea()
	//------------------------------------------
	//Verificando Vigencia da Tabela de precos
	//------------------------------------------
	dbSelectArea("DA0")
	dbOrderNickName("PDA01")
	dbSeek(xFilial("DA0")+cTabW,.F.)
	If dtos(dDatabase) > Dtos(DA0->DA0_DATATE)
		Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Tabela de Precos fora de Vigencia: "+cTabW})
		cPedErr:=cPedW
		lErro := .T.
		aDados := {}
		aCabPV  := {}
		aItemPV := {}
		++nPedErr
		dbselectarea("WORLD")
		dbskip()
		Loop
	EndIf
	
	cCodProd:=VerProduto(cProdW)
	if cModelo=="000011" .or. cModelo=="000008" // Se for Bloco ou Laminado converte UM
		if cTpConv=="D"
			cQtdW := round(cQtdW*nConv,4)
			cVlrW := round(cVlrW/nConv,4)
		else
			cQtdW := round(cQtdW/nConv,4)
			cVlrW := round(cVlrW*nConv,4)
		endif
	endif
	if Empty(cCodProd)
		cPedErr:=cPedW
		lErro := .T.
		aCabPV  := {}
		aItemPV := {}
		++nPedErr
		aDados := {}
		dbselectarea("WORLD")
		dbskip()
		Loop
	Endif
	if SB1->B1_XCOMCOM == 0  .and. SB1->B1_XCOMIND == 0
		Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Produto sem comissao: "+cProdW})
		cPedErr:=cPedW
		aCabPV  := {}
		aItemPV := {}
		++nPedErr
		lErro := .T.
		aDados := {}
		dbselectarea("WORLD")
		dbskip()
		Loop
	endif
	dbSelectArea("SFM")
	DBSETORDER(2)
	If dbSeek(xFilial("SFM")+cTpPw+cGrpCli+cGrProd)
		cTes := SFM->FM_TS
	else
		Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Pedido sem TES Parametrizada - Cliente: "+cCodCli+" - Produto: "+cProdW+ " - Operacao: "+cTpPW})
		cPedErr:=cPedW
		aCabPV  := {}
		aItemPV := {}
		++nPedErr
		lErro := .T.
		aDados := {}
		dbselectarea("WORLD")
		dbskip()
		Loop
	Endif
	dbselectarea("SB2")
	dbsetorder(1)
	if !dbseek(xFilial("SB2")+PADL(cCodProd,15)+SB1->B1_LOCPAD)
		CriaSb2(cCodProd,SB1->B1_LOCPAD)
	endif
	dbselectarea("SF4")
	dbsetorder(1)
	dbseek(xFilial("SF4")+cTes)
	cCF  := If(cEst = Alltrim(GETMV("MV_ESTADO")),"5",If(cEst <> "EX","6","7")) + Substr(SF4->F4_CF,2,3)
	
	
	if cVlrW==0
		Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Pedido com preco zerado - Cliente: "+cCodCli+" - Produto: "+cProdW+ " - Operacao: "+cTpPW})
		cPedErr:=cPedW
		aCabPV  := {}
		aItemPV := {}
		++nPedErr
		lErro := .T.
		aDados := {}
		dbselectarea("WORLD")
		dbskip()
		Loop
	endif
	
	if len(aItemPv) > 0
		nTam:=Len(aItemPv)
		if (substr(cCodProd,1,6)=="407095" .and. substr(aItemPv[nTam][4][2],1,6) <> "407095") .or.;
			(substr(cCodProd,1,6)<>"407095" .and. substr(aItemPv[nTam][4][2],1,6) == "407095")
			Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Pedido com produtos proprios e terceirizados"})
			cPedErr:=cPedW
			aCabPV  := {}
			aItemPV := {}
			++nPedErr
			lErro := .T.
			dbselectarea("WORLD")
			dbskip()
			Loop
		endif
	endif
	
	dbselectarea("DA1")
	dbsetorder(7)
	if !dbseek(xFilial("DA1")+cTabW+cCodProd)
		Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Pedido com produto "+cProdW+" fora da tabela "+cTabW})
		cPedErr:=cPedW
		aCabPV  := {}
		aItemPV := {}
		++nPedErr
		lErro := .T.
		aDados := {}
		dbselectarea("WORLD")
		dbskip()
		Loop
	endif
	
	if Len(aCabPV)==0
		aCabPV := {     {"C5_FILIAL"	,xFilial("SC5")					        ,Nil},;
		{"C5_NUM"   	,""     		            	        ,Nil},; // Eduardo 24-01-07 - Nr do pedido Microsiga
		{"C5_TIPO"	    ,"N"       						        ,Nil},; // DEFAULT = N
		{"C5_CLIENTE"	,SA1->A1_COD	                        ,Nil},; // Codigo do cliente
		{"C5_LOJACLI"	,SA1->A1_LOJA                           ,Nil},; // Loja do cliente
		{"C5_XTPSEGM"	,cSegW              		        	,Nil},;  //Segmento
		{"C5_VEND1"	    ,cVendW                                	,Nil},;// Codigo do Vendedor
		{"C5_XPEDFIC"  	,cPedW                      	        ,Nil},; // Eduardo 24-01-07 - Num Pedido Ortobom
		{"C5_CLIENT"	,SA1->A1_COD		                    ,Nil},; // Codigo do cliente
		{"C5_LOJAENT"	,SA1->A1_LOJA                           ,Nil},; // Loja do cliente
		{"C5_TIPOCLI"	,SA1->A1_TIPO                           ,Nil},; // Tipo do cliente "F"
		{"C5_CONDPAG"	,cCondPag     					        ,Nil},; // Codigo da condicao de pagamanto*
		{"C5_EMISSAO"	,dDataBase               		        ,Nil},; // Data de emissao
		{"C5_XDTVEND"	,cDtVW           	        	        ,Nil},; // Data de emissao
		{"C5_MOEDA"  	,1	         					        ,Nil},; // Moeda
		{"C5_TABELA"  	,cTabW                  		        ,Nil},; // Tabela de Preco
		{"C5_TIPLIB"	,"1"       						        ,Nil},;
		{"C5_XOPER"	    ,cTpPW                  		        ,Nil},;
		{"C5_XPRZMED"   ,cPrzMed                 	            ,Nil},; // Prazo Medio - Ortobom
		{"C5_XTPPGT"    ,cFPgtW             		            ,Nil},; // Tipo de Pagamento - Ortobom
		{"C5_XENTREG"   ,cEntregW             		            ,Nil},; // Tipo de Pagamento - Ortobom
		{"C5_XENTREF"   ,cEntrefW             		            ,Nil},; // Tipo de Pagamento - Ortobom
		{"C5_COTACAO"   ,"IMPPDA"				                ,Nil},;
		{"C5_TPFRETE"  ,"C"                 					,Nil},;
		{"C5_XFEIRAO"  ,cFeirW                 					,Nil},;
		{"C5_XREFTAB"  ,PA2->PA2_REFTAB        					,Nil}}
	endif
	//Preenche Itens Pedido
	ni:=Len(aItemPV)+1
	AAdd(aItemPV,{{"C6_FILIAL"   ,xFilial("SC6")    ,Nil},;
	{"C6_NUM"	    ,""     			    	     ,Nil},; // Eduardo 24-01-07 - Nr do pedido Microsiga
	{"C6_ITEM"   	,StrZero(ni,2)  			     ,Nil},; // Numero do Item no Pedido
	{"C6_PRODUTO"	,cCodProd                        ,Nil},; // Codigo do Produto
	{"C6_UM"     	,SB1->B1_UM                      ,Nil},; // Unidade de Medida Primar.
	{"C6_QTDVEN" 	,cQtdW                           ,Nil},; // Quantidade Vendida
	{"C6_PRCVEN" 	,cVlrW                   	     ,Nil},; // Preco Unitario Liquido
	{"C6_VALOR"  	,round(cQtdW*cVlrW,2)            ,Nil},; // Valor Total do Item
	{"C6_TES"    	,SFM->FM_TS  				     ,Nil},; //Tipo de Entrada/Saida do Item
	{"C6_LOCAL"  	,SB1->B1_LOCPAD                  ,Nil},;  //Almoxarifado do Produto
	{"C6_CF" 		,cCF     		 			     ,Nil},; // Codigo Fiscal
	{"C6_CLI"    	,SA1->A1_COD           	         ,Nil},; // Cliente
	{"C6_LOJA"   	,SA1->A1_LOJA		             ,Nil},; // Loja do Cliente
	{"C6_DESCRI"	,SB1->B1_DESC+SB1->B1_XMED      ,Nil},; // Codigo do Produto
	{"C6_PEDCLI"  	,cPedW          			     ,Nil},; // Numero do pedido do cliente
	{"C6_PRUNIT" 	,cVlrW                  	     ,Nil},; // PRECO DE LISTA
	{"C6_XPRUNIT" 	,cVlrW                  	     ,Nil},; // PRECO DE LISTA
	{"C6_XMED"     ,SB1->B1_XMED             	     ,Nil},;// MEDIDA DO PRODUTO
	{"C6_XOBS"     ,cObsIW      				     ,Nil},;
	{"C6_XCUSTO"   ,DA1->DA1_XCUSTO				     ,Nil},;
	{"C6_XMOTTRO"  ,cMotW       				     ,Nil}})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Leitura da proxima linha do arquivo texto.                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbselectarea("WORLD")
	dbskip()
	
Enddo
If !lFirst .and. Len(aCabPv) > 0 
	SC5->(dbOrderNickName("CSC57"))
	SC5->(dbGoTop())
	If !SC5->(dbSeek(xFilial("SC5")+aCabPV[8][2]))
		GravaPv()
	Endif
EndIf

If len(_aArray)>0	.Or.	Len(_aArrayOk)	>	0
	If	len(_aArray)>0
		aSort(_aArray,,,{|x,y| SubStr(x[3],1,6)+x[1]<SubStr(y[3],1,6)+y[1]})
	Endif
	If	len(_aArrayOk)>0
		aSort(_aArrayOk,,,{|x,y| SubStr(x[3],1,6)+x[1]<SubStr(y[3],1,6)+y[1]})
	Endif
	IMPRIMIR()
Else
	ALERT("Importação Finalizada com Sucesso!")
EndIf


Return
***************************
Static Function VerProduto()
***************************
Local cCod:=""
DbSelectArea("SB1")
dbOrderNickName("PSB11")
DbSeek(xFilial("SB1")+cProdW)
lSobMed:= .F.
If	found()
	if Empty(SB1->B1_XCODBAS) .and. (substr(cProdW,1,6)=="407095" .or. cMedW=AllTrim(SB1->B1_XMED))
		lSobMed := .F.
		cCod        	:= SB1->B1_COD
		cLocal          := SB1->B1_LOCPAD
		cDescP          := SB1->B1_DESC
		cUm             := SB1->B1_UM
		cSegum          := SB1->B1_SEGUM
		cGrProd         := SB1->B1_GRTRIB
		cMedW           := SB1->B1_XMED
		cLinha          := SB1->B1_GRUPO
		cModelo         := SB1->B1_XMODELO
		nConv           := SB1->B1_CONV
		cTpConv         := SB1->B1_TIPCONV
	Else
		if empty(SB1->B1_XCODBAS)
			cCodBase:=SB1->B1_COD
		else
			cCodBase:= SB1->B1_XCODBAS
		endif
		IF SB1->B1_XMODELO <= "000007"
			cCorte:="COLCHÃO"
			cModelo  :=SB1->B1_XMODELO 
		else
			cCorte   :=Alltrim(Posicione("SX5",1,xFilial("SX5")+"ZD"+SB1->B1_XMODELO,"X5_DESCRI"))
			cLinha   :=SB1->B1_GRUPO
			cDescSMed:=SB1->B1_DESC
			cModelo  :=SB1->B1_XMODELO 
		endif
		dbselectarea("SB1")
		dbsetorder(1)
		if dbseek(xFilial("SB1")+cCodBase) .and. EMPTY(SB1->B1_XCODBAS)
			lRet:=.T.
			if cCorte=="COLCHÃO"
				cLinha:=SB1->B1_GRUPO
				cDescSMed:= Alltrim(SB1->B1_DESC)+" "+"SM"
			else
				if SB1->B1_XDENSEQ == 0
					lRet:=.F.
					Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Produto base sem densidade de enquadramento "+cProdW})
				endif
			endif
			if lRet
				cCodBase:=SB1->B1_COD
				cCod:=VerSobMed()
				dbselectarea("SB1")
				dbsetorder(1)
				if dbseek(xFilial("SB1")+cCod)
					cLocal          := SB1->B1_LOCPAD
					cDescP          := SB1->B1_DESC
					cUm             := SB1->B1_UM
					cSegum          := SB1->B1_SEGUM
					cGrProd         := SB1->B1_GRTRIB
					cMedW           := SB1->B1_XMED
					cLinha          := SB1->B1_GRUPO
					cModelo         := SB1->B1_XMODELO
					nConv           := SB1->B1_CONV
					cTpConv         := SB1->B1_TIPCONV
				endif
			endif
		else
			Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Produto base nao e padrao "+cProdW})
		endif
	endif
else
	Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Produtos nao encontrado "+cProdW})
Endif
Return(cCod)
***************************
Static Function GeraItemPed(ni)
***************************
Local PrcVen  := 0
Local nValor  := 0
Local cTes    := ""
Local cCF     := ""
Local cLocal  := "01"
Local nMarkUp := 0
Local nPc     := 0
Local nPf     := 0
Local nQtd    := 0
Local nQtdPri := 0
Local nQtdSeg := 0
Local cSegum  := ""
Local cTipConv:= ""
Local cConv   := 0.00
Local nPrunit := 0.00
Local nPrTot  := 0.00

nPrTot  := (VAL(aDados[ni][17])/100)
nQtd    := (VAL(aDados[ni][13]) / 100)
cNPVori:= STRZERO(VAL(aDados[ni][1]),6)
If SB1->B1_CONV > 0
	If SB1->B1_TIPCONV == "M"
		nQtdPri := (VAL(aDados[ni][13]) / 100) /// SB1->B1_CONV
	Else
		nQtdPri := (VAL(aDados[ni][13]) / 100) //* SB1->B1_CONV
	EndIf
	nPrUnit := nPrTot / nQtdPri
Else
	nQtdPri := (VAL(aDados[ni][13]) / 100)
	nPrUnit := (VAL(aDados[ni][14])/100)
EndIf



Return()
/*
{"C6_XEMB"     ,aDados[j][24]									           ,Nil},;

*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ GravaPv  º Autor ³ MARCOS FURTADO     º Data ³  06/02/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Esta rotina tem a função de criar os pedidos de vendas.    º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
***********************
Static Function GravaPv()
***********************
Local cNumPed := ""
Private nOpc  := 3  //3-inclusao

lMsErroAuto   := .F.

DbSelectArea("SA1")
cNumPed:=GetSXENum("SC5")
DbSelectArea("SC5")
dbOrderNickName("PSC51")
dbseek(xFilial("SC5")+cNumPed)
do while found()
	confirmSX8()
	cNumPed:=GetSXENum("SC5")
	dbgotop()
	dbseek(xFilial("SC5")+cNumPed)
enddo
aCabPv[2][2]:=cNumPed
for i:=1 to len(aItemPv)
	aItemPv[i][2][2]:=cNumPed
next
M->C5_CLIENTE := aCabPv[4][2]
M->C5_LOJACLI := aCabPv[5][2]
M->C5_XTPSEGM := aCabPv[6][2]
M->C5_TIPO    := "N"
M->C5_EMISSAO := dDataBase
M->C5_VEND1   := aCabPv[7][2]
M->C5_NUM     := cNumPed

DbSelectArea("SC6")
MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPV,aItemPV,nOpc)

If lMsErroAuto
	Aadd (_aArray,{aCabPV[8,2],aCabPV[14,2],aCabPV[7,2]+"-"+Posicione("SA3",1,xFilial("SA3")+aCabPV[7,2],"A3_NOME"),"Problema na importacao"})
	MostraErro()
	DisarmTransaction()
	RollbackSx8()
	aDados  := {}
	aCabPV  := {}
	aItemPV := {}
	++nPedErr
	Return
else
	Aadd (_aArrayOk,  {aCabPV[8,2],aCabPV[14,2],aCabPV[7,2]+"-"+Posicione("SA3",1,xFilial("SA3")+aCabPV[7,2],"A3_NOME"),"Pedido importado"})
	tcSqlExec("UPDATE H_PEDIDO@WORLDSYS SET DIGITADO = SYSDATE WHERE NUMERO = "+aCabPV[8,2])
	tcSqlExec("COMMIT")
	++nPedImp
	ConfirmSx8()
endif

aDados  := {}
aCabPV  := {}
aItemPV := {}

Return

*****************************************
* IMPRESSAO DO LOG                      *
*****************************************

STATIC Function IMPRIMIR

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "RELATORIO DE LOG DE IMPORTACAO DE PEDIDOS DO PALM "
Local cPict          := ""
Local titulo       	 := "Relatorio da Importacao do Palm "
Local nLin         	 := 80
Local Cabec1         := "PEDIDO   EMISSAO    VENDEDOR                                  MOTIVO                     "
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "ORTAIMP" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "ORTAIMP" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString      := "SC5"

*****************************************************************************
*   Monta a interface padrao com o usuario...                               *
*****************************************************************************

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

*****************************************************************************
*   Processamento. RPTSTATUS monta janela com a regua de processamento.     *
*****************************************************************************

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem

SetRegua(RecCount())

If len(_aArray)>0	.Or.	Len(_aArrayOk)	>	0
	nlin:=ImpX(_aArray,nlin,Cabec1,Cabec2,Titulo,1)
Endif

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

Static Function ImpX(_aArray,nlin,Cabec1,Cabec2,Titulo,nTipX)
Local cont
cont := 1
erroop := 0
nLin:=90

DbSelectArea("SC5")
dbOrderNickName("PSC51")

totalop := 0

For cont := 1 to len(_aArrayOk)
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif
	
	//	SB1->(dbSeek(xFilial("SB1")+Alltrim(_aArray[cont,1])))
	@ nLin,01 	PSAY _aArrayOk[cont,1]
	@ nLin,09 	PSAY _aArrayOk[cont,2]
	@ nLin,20 	PSAY substr(_aArrayOk[cont,3],1,40)
	@ nLin,62 	PSAY _aArrayOk[cont,4]
	//	@ nLin,100  PSAY SB1->B1_XCUSMED PICTURE "@E 999,999,999.99"
	
	nLin++
	
Next

nLin++
@nLin,00 PSAY Replicate("-",limite)
nLin++

@nLin,00 PSAY "PROBLEMAS"
nLin++
nLin++
For cont := 1 to len(_aArray)
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif
	
	//	SB1->(dbSeek(xFilial("SB1")+Alltrim(_aArray[cont,1])))
	@ nLin,01 	PSAY _aArray[cont,1]
	@ nLin,09 	PSAY _aArray[cont,2]
	@ nLin,20 	PSAY substr(_aArray[cont,3],1,40)
	@ nLin,62 	PSAY _aArray[cont,4]
	//	@ nLin,100  PSAY SB1->B1_XCUSMED PICTURE "@E 999,999,999.99"
	
	nLin++
	
Next
_aArray		:=	{}
_aArrayOk	:=	{}
Return(nlin)
***************************************
*SOB MEDIDA
***************************************
*****************************************************
* Funcao....: VerSobMed()                            *
* Finalidade: Buscar produto sob medida e se não    *
*             existir gera novo produto             *
*****************************************************
Static Function VerSobMed()
Local lRet := .F.
Local cNovoCod := ""
dbselectarea("SB1")
dbOrderNickName("CSB1A")
dbseek(xFilial("SB1")+cCodBase+cMedW)
while SB1->B1_FILIAL+SB1->B1_COD+SB1->B1_XMED == xFilial("SB1")+cCodBase+cMedW .and.;
	(SB1->B1_ATIVO == "N" .OR. SB1->B1_MSBLQL == "1" .or. !empty(SB1->B1_XPERSON) .or. SB1->B1_XMODELO <> cModelo)
	dbskip()
enddo
if alltrim(SB1->B1_FILIAL+SB1->B1_XCODBAS+SB1->B1_XMED) == alltrim(xFilial("SB1")+cCodBase+cMedW)
	cCodSMed	:= SB1->B1_COD
	IF cCorte <> "COLCHÃO" .and. cCorte <> "BLOCO" //.and. alltrim(SB1->B1_UM) == "KG"
		lRet:=AceProd()
		if lRet
			fValPrVen(cCodSMed)
		endif
	endif
	if cCorte=="COLCHÃO"
		lRet:=fCalcPrc()
	endif
else
	cQuery := "SELECT SB1.* "
	cQuery += "FROM " + RetSqlName("SB1") + " SB1 "
	cQuery += "WHERE SB1.D_E_L_E_T_ = ' '"
	cQuery += "  AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "  AND SB1.B1_XPERSON = ' ' "
	cQuery += "  AND B1_ATIVO <> 'N' "
	cQuery += "  AND B1_MSBLQL <> '1' "
	if cCorte == "COLCHÃO"
		cQuery += "  AND SB1.B1_GRUPO = '"+Posicione("SB1",1,xFilial("SB1")+cCodBase,"B1_GRUPO")+"' "
	else
		cQuery += "  AND SB1.B1_XCODBAS = '"+cCodBase+"' "
		cQuery += "  AND SB1.B1_XMODELO = '"+cModelo+"' "
	endif
	if cCorte=="LAMINADO"
		cQuery+=" AND B1_POSIPI = '"+GetMV("MV_XCFLAM")+"' "
	endif
	if cCorte=="PLACA"
		cQuery+=" AND B1_POSIPI = '"+GetNewPar("MV_XCFPLA",'94042100')+"' "
	endif
	cQuery += "  AND SB1.B1_XMED = '" + upper(cMedW) + "' "
	memowrit("c:\orta027.sql",cQuery)
	TcQuery cQuery ALIAS "TMPSB1" NEW
	If !EOF("TMPSB1")
		dbselectarea("SB1")
		dbOrderNickName("PSB11")
		dbseek(xFilial("SB1")+TMPSB1->B1_COD)
		cCodSMed	:= SB1->B1_COD
		IF cCorte <> "COLCHÃO" //.and. alltrim(SB1->B1_UM) == "KG"
			lRet:=AceProd()
			if lRet
				fValPrVen(cCodSMed)
			endif
		else
			lRet:=fCalcPrc()
		endif
	endif
	TMPSB1->(DbCloseArea())
	if !lRet
		cCodSMed:=U_GeraNovoCod(cCodBase,cMedW,.F.,"",cCorte,0)
		dbselectarea("SB1")
		dbOrderNickName("PSB11")
		dbseek(xFilial("SB1")+cCodSMed)
		if found()
			IF cCorte <> "COLCHÃO" //.and. alltrim(SB1->B1_UM) == "KG"
				lRet:=AceProd()
				if lRet
					fValPrVen(cCodSMed)
				endif
			else
				lRet:=fCalcPrc()
			endif
		Else
			Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Nao Foi Possivel a cricao do novo produto "+cProdW})
			lRet:=.F.
		endif
	endif
endif
if cCorte == "COLCHÃO"
	fCalcPrc()
else
	nPrVen:=SB1->B1_CUSTD*SB1->B1_XMARKUP
endif
if !lRet
	cNovoCod:=""
else
	cNovoCod:=cCodSMed
	dbselectarea("SB1")
	dbsetorder(1)
	dbseek(xFilial("SB1")+padr(cNovoCod,15))
endif
Return(cNovoCod)

*****************************************************
* Funcao....: fValPrVen()                           *
* Finalidade: Grava preco de venda no SB1.          *
*                                                   *
*****************************************************
Static Function fValPrVen(cCod)

Local cAreaAtu := GetArea()
Local lGrvTab  := .F.


dbSelectArea("SB1")
dbOrderNickName("PSB11")
If dbSeek(xFilial("SB1") + cCod)
	RecLock("SB1",.F.)
	Replace SB1->B1_PRV1 with nPrVen
	Replace SB1->B1_CUSTD WITH nValCus
	Replace SB1->B1_GRUPO with cLinha
	Replace SB1->B1_DESC  with cDescSMed
	MsUnLock()
	lGrvTab := .T.
Endif

cQueryDA1 := "SELECT MAX(DA1_ITEM) NITEM "
cQueryDA1 += "       FROM " + RetSqlName("DA1") + " "
cQueryDA1 += "       WHERE D_E_L_E_T_ = ' '"
cQueryDA1 += "       	   AND DA1_FILIAL = '" + XFILIAL("DA1") + "' "
cQueryDA1 += "       	   AND DA1_CODTAB = '" + cTabW + "' "

TcQuery cQueryDA1 ALIAS "TMPDA1" NEW

//nPrxIt := strzero(val(TMPDA1->NITEM) + 1,4)
nPrxIt := Soma1(TMPDA1->NITEM)

dbCloseArea("TMPDA1")

If lGrvTab
	dbSelectArea("DA1")
	dbOrderNickName("CDA14")
	if DbSeek(xFilial("DA1") + cTabW + cCod)
		RecLock("DA1",.F.)
	Else
		RecLock("DA1",.T.)
		Replace DA1_FILIAL with xFilial("DA1")       // Filial
		Replace DA1_ITEM   with nPrxIt               // Proximo item
		Replace DA1_CODTAB with cTabW               // Tabela
		Replace DA1_CODPRO with cCod   					// Produto
	EndIf
	Replace DA1_PRCVEN with nPrVen               // Valor
	Replace DA1_ATIVO  with "1"                  // Indica tabela ativa
	Replace DA1_TPOPER with	"4"                  // Tipo de operacao
	Replace DA1_QTDLOT with 999999.99            // Faixa para preco
	Replace DA1_INDLOT with "000000000999999.99" // Faixa para preco
	Replace DA1_MOEDA  with 1                    // Moeda
	Replace DA1_DATVIG with dDataBase	         // Data da vigencia
	Replace DA1_XCUSTO with nValCus					// Valor do custo
	MsUnLock()
Endif

RestArea(cAreaAtu)
Return

*****************************************************
* Funcao....: fTabPr()                              *
* Finalidade: Valida se tabela de preco esta ativa. *
*                                                   *
*****************************************************
Static Function fTabPr()

Local cAreaAtu := GetArea()
Local lRet     := .F.

cTabW := strzero(val(cTabW),3)

dbSelectArea("DA0")
dbOrderNickName("PDA01")
if dbSeek(xFilial("DA0") + cTabW)
	lRet := .T.
	dbSelectArea("DA1")
	dbOrderNickName("PDA11")
	If dbSeek(xFilial("DA1") + cTabW + cCodBase)
		nPrVen := DA1->DA1_PRCVEN
		nValCus:= DA1->DA1_XCUSTO
	Endif
Endif
RestArea(cAreaAtu)
Return(lRet)


**********************************
Static Function fCalcPrc()
**********************************
Local cQuery:=""
Local lAme  :=.F.
Local aArea :=GetArea()
Local lRet  :=.T.
cQuery:="SELECT  ZV_CUSTO, ZV_VENDA, ZV_VENAME "
cQuery+="FROM "+RetSqlName("SZV")+" SZV "
cQuery+="WHERE SZV.D_E_L_E_T_ = ' ' "
cQuery+="  AND ZV_FILIAL = '"+xFilial("SZV")+"' "
cQuery+="  AND ZV_GRUPO  = '"+cLinha+"' "
cQuery+="  AND ZV_TABELA = '"+cTabW+"' "
TCQUERY cQUery ALIAS "PRCSMED" NEW
dbselectarea("PRCSMED")
dbgotop()
if eof() .or. PRCSMED->ZV_CUSTO==0
	Aadd (_aArray,  {cPedW,cDtVW,cVendW+"-"+Posicione("SA3",1,xFilial("SA3")+cVendW,"A3_NOME"),"Produto sem preco para Sob-Medida "+cProdW})
	lRet:=.F.
endif
if lRet
	nPrVen :=nLargW*nCompW
	nValCus:=nLARGW*nCOMPW*ZV_CUSTO
	if nALTW > 0 .AND. cCorte <> "PROTETORES"
		nPrVen *=nALTW
		nValCus*=nALTW
	endif
	if nCompW == 2.03
		if nLargW == 0.96 .or. nLargW == 1.36 .or. nLargW == 1.53 .or. nLargW == 1.93
			lAme:=.T.
		endif
	else
		if nCompW == 1.98
			if nLargW == 1.48 .or. nLargW == 1.78 .or. nLargW ==1.38 .or. nLargW == 0.78 .or. nLargW == 0.88 .or.;
				nLargW == 1.08 .or. nLargW == 0.98 .or. nLargW ==1.18
				lAme:=.T.
			endif
		else
			if nCompW == 1.88
				if nLargW == 1.48 .or. nLargW == 1.58 .or. nLargW == 1.08 .or. nLargW == 0.98 .or. nLargW ==1.18
					lAme:=.T.
				endif
			else
				if nCompW == 1.90
					if nLargW == 0.96 .or. nLargW == 1.36
						lAme:=.T.
					endif
				else
					if nCompW == 2.00
						if nLargW == 1.48 .or. nLargW == 1.80
							lAme:=.T.
						endif
					else
						if nCompW == 2.13 .and. nLargW == 1.83
							lAme:=.T.
						else
							if nCompW == 2.10 .and. nLargW == 1.80
								lAme:=.T.
							else
								if nCompW == 0.70 .and. nLargW == 1.50
									lAme:=.T.
								endif
							endif
						endif
					endif
				endif
			endif
		endif
	endif
	if lAme .and. ZV_VENAME > 0
		nPrVen*=ZV_VENAME
	ELSE
		nPrVen*=ZV_VENDA
	endif
	fValPrVen(cCodSMed)
endif
DBCLOSEAREA()
RestArea(aArea)
Return(lRet)
****************************
Static Function AceProd()
****************************
Local cUM  :=""
Local aArea:=GetArea()
Local nCompWAux:=0
Local lRet:=.T.
dbselectarea("SB1")
dbOrderNickName("PSB11")
dbseek(xFilial("SB1")+cCodBase)
nCusto:=SB1->B1_CUSTD
nVol    :=round(SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP,2)
nPeso   :=SB1->B1_PESO
nDens   :=round(nPeso/nVol,2)
nDensEqu:=SB1->B1_XDENSEQ
nMark   :=SB1->B1_XMARKUP
if nDensEqu == 0
	lRet:=.F.
	Aadd (_aArray,  {cPedW,cDtVW,"C"+Subs(cVendW,2,5)+"-"+Posicione("SA3",1,xFilial("SA3")+"C"+Subs(cVendW,2,5),"A3_NOME"),"Bloco com densidade zerada. "+cProdW})
endif
if nMark ==0
	lRet:=.F.
	Aadd (_aArray,  {cPedW,cDtVW,"C"+Subs(cVendW,2,5)+"-"+Posicione("SA3",1,xFilial("SA3")+"C"+Subs(cVendW,2,5),"A3_NOME"),"Bloco com marcacao zerada. "+cProdW})
endif
if lRet
	dbgotop()
	dbseek(xFilial("SB1")+cCodSMed)
	if cCorte == "TORNEADO"
		cUM  :="MT"
	else
		if cCorte == "PEÇA" .or. cCorte == "LAMINADO" .or. cCorte == "ALMOFADA" .or. cCorte == "CHANFRADO" .or. cCorte == "PLACA"
			cUM:="UN"
		else
			cUM:="KG"
		endif
	endif
	if SB1->B1_XCOMP==1.9 .AND. cCorte <> "BLOCO"
		nCompWAux:=1.93
	else
		nCompWAux:=SB1->B1_XCOMP
	endif
	reclock("SB1",.F.)
	SB1->B1_UM     :=cUM
	SB1->B1_QB     :=1
	SB1->B1_PESO   :=(SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP)*nDens
	SB1->B1_XDENSEQ:=nDensEqu
	if cCorte == "CHANFRADO"
		SB1->B1_CUSTD  := nCUSTO*nCompWAux*SB1->B1_XLARG*((SB1->B1_XALT+SB1->B1_XCHANFR)/2)*nDensEqu //nCUSTO*nCompWAux*SB1->B1_XLARG*(SB1->B1_XALT+SB1->B1_XCHANFR)*2*nDensEqu
	else
		if cCorte == "TORNEADO"
			SB1->B1_CUSTD  := 1.15*nCUSTO*nCompWAux*SB1->B1_XLARG*((SB1->B1_XALT+SB1->B1_XCHANFR)/2)*nDensEqu //nCUSTO*nCompWAux*SB1->B1_XLARG*(SB1->B1_XALT+SB1->B1_XCHANFR)*2*nDensEqu
		else
			SB1->B1_CUSTD  :=nCUSTO*nCompWAux*SB1->B1_XLARG*SB1->B1_XALT*nDensEqu
		endif
	endif
	SB1->B1_XMARKUP:=nMark
	nPrven:=SB1->B1_CUSTD*nMark
	nValCus:=SB1->B1_CUSTD
	
	if cCorte == "LAMINADO"
		SB1->B1_SEGUM  :="MT"
		SB1->B1_CONV   :=5
		SB1->B1_TIPCONV:="M"
		SB1->B1_XMODELO:="000008" //Laminado
		SB1->B1_GRTRIB :=GetMV("MV_XGRTLAM")
		SB1->B1_IPI    :=GetMV("MV_XIPILAM")
		SB1->B1_POSIPI :=GetMV("MV_XCFLAM")
		SB1->B1_XESPACO:=SB1->B1_XALT*B1_XLARG*B1_XCOMP*13/5
		aarea:=GetArea()
		DBSELECTAREA("SB5")
		dbOrderNickName("PSB51")
		IF DBSEEK(XFILIAL("SB5")+SB1->B1_COD)
			RECLOCK("SB5",.F.)
		ELSE
			RECLOCK("SB5",.T.)
			SB5->B5_FILIAL:=XFILIAL("SB5")
			SB5->B5_COD   :=SB1->B1_COD
		ENDIF
		SB5->B5_CEME   := SB1->B1_DESC
		SB5->B5_UMDIPI :="MT"
		SB5->B5_CONVDIP:=5
		SB5->B5_CARPER :="2"
		SB5->B5_ROTACAO:="2"
		SB5->B5_UMIND  :="1"
		MSUNLOCK()
		RESTAREA(aArea)
	else
		if cCorte == "PLACA"
			SB1->B1_SEGUM  :="MT"
			SB1->B1_CONV   :=5
			SB1->B1_TIPCONV:="M"
			SB1->B1_XMODELO:="000008" //Laminado
			SB1->B1_GRTRIB :=GetNewPar("MV_XGRTPLA",'001')
			SB1->B1_IPI    :=GetNewPar("MV_XIPIPLA",0)
			SB1->B1_POSIPI :=GetNewPar("MV_XCFPLA",'94042100')
			SB1->B1_XESPACO:=SB1->B1_XALT*B1_XLARG*B1_XCOMP*13/5
			aarea:=GetArea()
			DBSELECTAREA("SB5")
			dbOrderNickName("PSB51")
			IF DBSEEK(XFILIAL("SB5")+SB1->B1_COD)
				RECLOCK("SB5",.F.)
			ELSE
				RECLOCK("SB5",.T.)
				SB5->B5_FILIAL:=XFILIAL("SB5")
				SB5->B5_COD   :=SB1->B1_COD
			ENDIF
			SB5->B5_CEME   := SB1->B1_DESC
			SB5->B5_UMDIPI :="MT"
			SB5->B5_CONVDIP:=5
			SB5->B5_CARPER :="2"
			SB5->B5_ROTACAO:="2"
			SB5->B5_UMIND  :="1"
			MSUNLOCK()
			RESTAREA(aArea)
		else
			if cCorte == "TORNEADO"
				SB1->B1_XMODELO:="000009" //Torneado
				SB1->B1_GRTRIB :=GetMV("MV_XGRTTOR")
				SB1->B1_IPI    :=GetMV("MV_XIPITOR")
				SB1->B1_POSIPI :=GetMV("MV_XCFTOR")
				SB1->B1_XESPACO:=SB1->B1_XALT*B1_XLARG*B1_XCOMP*13/5
			else
				if cCorte == "PEÇA"
					SB1->B1_XMODELO:="000010" //Peça
					SB1->B1_GRTRIB :=GetMV("MV_XGRTPEC")
					SB1->B1_IPI    :=GetMV("MV_XIPIPEC")
					SB1->B1_POSIPI :=GetMV("MV_XCFPEC")
				else
					if cCorte == "ALMOFADA"
						SB1->B1_XMODELO:="000010" //Almofada
						SB1->B1_GRTRIB :=GetMV("MV_XGRTALM")
						SB1->B1_IPI    :=GetMV("MV_XIPIALM")
						SB1->B1_POSIPI :=GetMV("MV_XCFALM")
					else
						if cCorte == "CHANFRADO"
							SB1->B1_XMODELO:="000012" //Peca Chanfrada
							SB1->B1_GRTRIB  :=GetMV("MV_XGRTPEC")
							SB1->B1_IPI     :=GetMV("MV_XIPIPEC")
							SB1->B1_POSIPI  :=GetMV("MV_XCFPEC")
							SB1->B1_XCHANFR:=0
						else
							SB1->B1_XMODELO:="000011" //BLOCO
							SB1->B1_CUSTD  :=nCusto
							SB1->B1_QB     :=nPeso
							SB1->B1_GRTRIB :=GetMV("MV_XGRTBLO")
							SB1->B1_IPI    :=GetMV("MV_XIPIBLO")
							SB1->B1_POSIPI :=GetMV("MV_XCFBLO")
							SB1->B1_CONV   :=nDens
							SB1->B1_TIPCONV:="D"
							SB1->B1_XESPACO:=SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP*10/B1_PESO
						endif
					endif
				Endif
			Endif
		Endif
	endif
	msunlock()
	if cCorte <> "BLOCO"
		dbselectarea("SG1")
		dbOrderNickName("PSG11")
		dbseek(xFilial("SG1")+cCodSMed) //Apaga Estrutura anterior se houver
		do while !eof() .and. Alltrim(SG1->G1_COD) == Alltrim(cCodSMed)
			reclock("SG1",.F.)
			delete
			msunlock()
			dbskip()
		enddo
		reclock("SG1",.T.)
		SG1->G1_FILIAL  :=xFilial("SG1")
		SG1->G1_COD     := cCodSMed
		SG1->G1_COMP    := cCodBase
		SG1->G1_QUANT   := (SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP)*nPeso
		SG1->G1_INI     := STOD("20050101")
		SG1->G1_FIM     := STOD("20050101")
		SG1->G1_FIXVAR  := "V"
		msunlock()
	else
		U_GeraEstru(cCodBase,cCodSMed,nil)
	endif
endif
RestArea(aArea)
Return(lRet)