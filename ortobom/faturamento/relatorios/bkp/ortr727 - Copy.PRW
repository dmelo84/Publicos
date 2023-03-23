/*==========================================================================||
||                     FICHA TECNICA DO PROGRAMA:                           ||
||==========================================================================||
||                         PROPOSTA COMERCIAL                               ||
||==========================================================================||
|| Autor:       ||	    	ADRIANO S DOURADO                               ||
||              || 	E-mail: ADRIANO.DOURADO@ORTOBOM.COM.BR                  ||
||==============||==========================================================||
|| Descrição:   ||	Relatório em FWMSPrinter para                           ||
||				||	impressão das PROPOSTAS DE NEGÓCIO          			||
||              ||  COLCHAO/TRAVESSEIRO/ADICIONAL               			||
||==============||==========================================================||
|| Nome:        ||	U_ORTR727()                                             ||
||==============||==========================================================||
|| Desenvolvida:||	20/08/2018                                              ||                        
|| Alterado:    ||	Solicitação 116341  - 12/05/2021                        || 
|| Alterado:    ||	Solicitação 119519  - 06/07/2021                        || 
||==========================================================================*/                         
                                                                                        

/*/{Protheus.doc} ORTR727

//TODO  Correção do cálculo do Mix e Markup
Criação de função específica para cálculo de ambos.                                                 
Identação adequada do fonte.

@author Peder Munksgaard
@since 21/09/2018
@version 1.0
@type function
/*/

#INCLUDE "FWPrintSetup.ch"                                                                   
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

********************************
USER FUNCTION ORTR727(aVetPed,cClix,dDtIni,dDtFim)
********************************

Local _nLinhas	:= 0
Local cVar 	 	:= ""
Local nTotPed	:= 0
Local nTotMarc	:= 0
Local nItens	:= 0
Local nTCusto	:= 0
Local nPCusReal := 0
Local nTCusReal := 0
Local nMix		:= 0
Local nSimBa	:= 0
Local nMixReal  := 0
Local nMarcReal := 0
Local nQtdVen	:= 0
Local cQuery 	:= ""
Local nI, nx, _nf		:= 0
Local lPrimVez	:= .T. //SSI-92851 - Variáveis - Vagner Almeida - 23/03/2020

Local nTotPed2		:= 0
Local nTotMarc2		:= 0
Local nTLucMar2		:= 0
Local nTLucReal2	:= 0
Local nTDesVar2		:= 0
Local nTMarc2		:= 0
Local nItens2		:= 0
Local nTCusto2		:= 0
Local nPCusReal2    := 0
Local nTCusReal2    := 0
Local nMix2         := 0
Local nMixReal2     := 0
//Local nTLiqVpc2		:= 0
Local nMarcReal2    := 0
Local nMarcMarf2    := 0
//Local nCliVpc2      := 0
Local nQtdVen2		:= 0
//Local nVpcPon2		:= 0
Local nDesVar2		:= 0
Local nDescFin2 	:= 0
Local nDescMes2		:= 0
Local nSimBa2 	 	:= 0  
Local _cTabOri	    := ""
Private nGf2   		:= 0
Private nDg2   		:= 0

Private cPedidos  := " "
Private oPrinter
Private oTim10
Private oTim9N
Private oTim6
Private oTim10N
Private oTim11N
Private oTim11
Private oTim12N
Private _cUsu 	  	:= RetCodUsr()   //__cUserID
Private cCodGru 	:= " "
Private cXVend  	:= " "
Private nPag		:= 1
Private aPergs		:= {}
Private aRet		:= {}
Private aCli        := {}
Private aPedidos    := {}
Private aCliente    := {}
Private aRetMix 	:= {}
Private aRetMix2 	:= {}
Private cTitulo     := "Inclusão de Dados"
Private nLin 		:= 100
Private nEsp 		:= 50
Private nLinIf		:= 0
Private cVend		:= ""
Private cGer		:= ""
Private cCliMun		:= ""
Private cCliNom		:= ""
Private nCliLim		:= 0
Private nCliDeb		:= 0
Private nGf    		:= 0
Private nDg    		:= 0
Private nMTri		:= 0
Private nMMes		:= 0
Private nMAMes		:= 0
Private nM30 		:= 0
Private nUpmeT		:= 0
Private nUpmeM		:= 0
Private nUpAmeM		:= 0
Private nUpmeD 		:= 0
Private nUpmePed	:= 0
Private nDebProp	:= 0
Private nProp		:= 0
Private cClasCli	:= ""

Private _aVenTAB    := {}
Private _aVenGG     := {}
Private _aVenREG    := {}

Private _aVenTAB2   := {}
Private _aVenGG2    := {}
Private _aVenREG2   := {}

Private cClix	
Private dDtIni	
Private dDtFim	

aAdd( aPergs ,{9,"Parâmetros para Inclusão de Dados Complementares:",200,,,.T.})
aAdd( aPergs ,{1,"Km de Ida/Volta da Unidade",Space(30),,,,,50,.F.})
aAdd( aPergs ,{1,"Quem está vendendo",Space(60) ,,,,,100,.F.})
aAdd( aPergs ,{9,"Mix com rentabilidade inferior a média trimestral ou último mês deve informar:",220,,,.T.})
aAdd( aPergs ,{5,"Foi concedido desconto, brinde ou algum VPC que fez a rentabilidade diminuir.",.F.,220,,.F.}) //CHECKBOX
aAdd( aPergs ,{5,"Houve alta de custo e a alta não foi repassada ao cliente diminuindo a rentabilidade.",.F.,220,,.F.})
aAdd( aPergs ,{5,"Aumentou a participação de produtos que tem a rentabilidade inferior a média.",.F.,220,,.F.})
aAdd( aPergs ,{5,"Caiu a participação de produtos que tem a rentabilidade superior a média.",.F.,220,,.F.})
aAdd( aPergs ,{1,"Outros",Space(250) ,,,,,125,.F.})
aAdd( aPergs ,{1,"Prazo médio",0	,"@E 9999",,,,50,.T.})
aAdd( aPergs ,{1,"Forma de Pagamento",Space(60),"@!",,,,65,.T.})
aAdd( aPergs ,{11,"Observações" ,,,,.F.})

If !Parambox ( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTR727" /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
	Return
EndIf

//========= Monta Array com Pedidos selecionados =========//

For nI:= 1 to Len(aVetPed)
	If aVetPed[nI,1]
		Aadd(aPedidos, aVetPed[nI,2])

		nPos:= aScan(aCliente, aVetPed[nI,3] )	
		if nPos == 0 
			Aadd(aCliente, aVetPed[nI,3])
		endif	

	Endif
Next

For nI:= 1 to Len(aPedidos)
	
	DbselectArea("SC5")
	DbSetorder(1)
	DbSeek(xFilial("SC5")+aPedidos[nI])

	_cTabOri := SC5->C5_TABELA
	
	//SSI-92851 - Inicio - Vagner Almeida - 23/03/2020
	/*
	If SC5->C5_XOPER == '05'
		cPedidos+= aPedidos[nI]+"B  "
	Else
		cPedidos+= aPedidos[nI]+"  "
	Endif
	*/
	If SC5->C5_XOPER == '05'
		If lPrimVez
			lPrimVez := .F.
			cPedidos += 		aPedidos[nI] + "B - " + DTOC( SC5->C5_EMISSAO )  
		Else
			cPedidos += " | " + aPedidos[nI] + "B - " + DTOC( SC5->C5_EMISSAO ) 
		EndIf	
	Else
		If lPrimVez
			lPrimVez := .F.
			cPedidos +=         aPedidos[nI] + " - " + DTOC( SC5->C5_EMISSAO )
		Else	
			cPedidos += " | " + aPedidos[nI] + " - " + DTOC( SC5->C5_EMISSAO )
		EndIf	
	Endif
	//SSI-92851 - Final - Vagner Almeida - 23/03/2020

	If !Empty(MV_PAR12)
		SC5->(Reclock("SC5",.F.)) //cr//
			SC5->C5_XOBSPRO := MV_PAR12 //cr//
		MsUnlock() //cr//
	Endif

Next nI

Dbselectarea("SC5")
DbsetOrder(1)
Dbseek(xFilial("SC5")+aPedidos[1])
cXVend  := SC5->C5_VEND1

If SC5->C5_XPRONUM == 0
	nProp := fPropNum(1) 
Else
	If cEmpAnt == "21" .and. !_lImp
		nProp := fPropNum(1) 	
	Else	
	   fPropNum(2) 
	   nProp := SC5->C5_XPRONUM
	Endif	
Endif

DbSelectArea("SA1")
DbSetOrder(1)
DBSeek(xFilial("SA1")+SC5->C5_CLIENTE)
cCliMun	:= SA1->A1_MUN
cCliNom	:= Substr(SA1->A1_NOME,1, 25)
cCodGru := SA1->A1_XCODGRU

//---------===UPME Dia===--------//
Dbselectarea("SM2")
DBSetorder(1)

Dbseek(SC5->C5_EMISSAO)
nUpmePed:=SM2->M2_MOEDA5
SM2->(DBCloseArea())
//---------=====||||=====--------//

oPrinter	  	:= FWMSPrinter():New("Proposta"+StrZero(nProp,8)+".pdf",6,.T.,,.T.)
oTim10	  		:=	TFont():New("Times New Roman",,13,,.F.,,,,,.F.,.F.)
oTim6	 	  	:=	TFont():New("Times New Roman",,9 ,,.F.,,,,,.F.,.F.)
oTim9N	  		:=	TFont():New("Times New Roman",,12,,.T.,,,,,.F.,.F.)
oTim10N 		:=	TFont():New("Times New Roman",,13,,.T.,,,,,.F.,.F.)
oTim11N 		:=	TFont():New("Times New Roman",,14,,.T.,,,,,.F.,.F.)
oTim11	  		:=	TFont():New("Times New Roman",,14,,.F.,,,,,.F.,.F.)
oTim16N 		:=	TFont():New("Times New Roman",,16,,.T.,,,,,.F.,.F.)

//================== FORMATACAO DA PAGINA ==================//

oPrinter:SetResolution(72) //Tamanho estipulado para a Danfe
oPrinter:SetPortrait()
oPrinter:SetPaperSize(9)
oPrinter:StartPage()

///////////////////////////////////////////////////////////////////////////
/////////////////////// LIMITE E DEBITO PROPRIO ///////////////////////////
///////////////////////////////////////////////////////////////////////////

cQuery:="DELETE DEB"+cEmpAnt+" WHERE USU = '"+_cUsu+"'"
TCSQLEXEC(cQuery)
cQuery:="DELETE PED"+cEmpAnt+" WHERE USU = '"+_cUsu+"'"
TCSQLEXEC(cQuery)
cQuery:="DELETE PON"+cEmpAnt+" WHERE USU = '"+_cUsu+"'"
TCSQLEXEC(cQuery)
cQuery:="DELETE PROCDEB WHERE USU = '"+_cUsu+"'"
TCSQLEXEC(cQuery)

cQuery:="INSERT INTO PROCDEB (CLIENTE,LOJA,USU) VALUES ('"+SC5->C5_CLIENTE+"','"+SC5->C5_LOJACLI+"','"+_cUsu+"') "

Begin Transaction
TCSQLEXEC(cQuery)
End Transaction
aResult:={}
aResult:=TCSPEXEC("PEDDEB"+cEmpAnt,_cUsu,'T','F',100,cFilAnt,xFilial("SC5"))
if Empty(aResult) .or. aResult[1] == "F"
	Msgbox("Problemas na excucao da stored procedure PEDDEB. Tente novamente ou entre em contato com a T.I.")
	Return()
endif	




cQuery:="SELECT SUM(DECODE(DB.TIPO,'PON',0,DB.VLR)) DEBTOT, "
cQuery+="SUM(CASE WHEN DB.TIPO IN ('DCHT','CCHT','CDPT','DDPT','RCHT','RDPT') THEN DB.VLR ELSE 0 END) DEBTER, "
cQuery+="SUM(CASE WHEN DB.TIPO IN ('DCC ', 'CCC ', 'RCC ', 'DCD ', 'CCD ', 'RCD ') THEN DB.VLR ELSE 0 END) DEBCC, "
cQuery+="SUM(DECODE(DB.TIPO,'CONS',DB.VLR,0)) DEBCONS "
cQuery+="FROM DEB"+cEmpAnt+" DB, "+RetSQLName("SA1")+" SA1 "//, PON"+cEmpAnt+" PON "
cQuery+="WHERE SA1.A1_XCODGRU   = '"+cCodGru+"' "
cQuery+="  AND DB.CLIENTE(+) = SA1.A1_COD                "
cQuery+="  AND DB.LOJA(+)    = SA1.A1_LOJA               "
cQuery+="  AND DB.TIPO(+)    NOT LIKE 'PVP%'             " //Exclui Pedidos Parcelados
cQuery+="  AND DB.TIPO(+)    <> 'NFDV'                   " //Exclui Devolucoes
cQuery+="  AND DB.TIPO(+)    <> 'PVCC'                   " //Exclui Pedidos Cancelados
cQuery+="  AND DB.TIPO(+)    <> 'PVAC'                   " //Exclui Pedidos Acertados
cQuery+="  AND DB.TIPO(+)    <> 'PVTR'                   " //Exclui Pedidos Troca
cQuery+="  AND PREV(+) = 'R' "
cQuery+="  AND DB.USU(+) = '"+_cUsu+"'"
cQuery+="  AND SA1.D_E_L_E_T_ = ' ' "
cQuery+="  AND SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
cQuery+="GROUP BY SA1.A1_COD, SA1.A1_NOME, SA1.A1_LOJA, SA1.A1_CGC "//, PONTUACAO "
memowrit("C:\qry\ORTR728DEB.SQL", cquery)

If Select("TDEB") > 0
	TDEB->(DbCloseArea())
Endif
TcQuery cQuery Alias "TDEB" New
DbSelectArea("TDEB")
TDEB->(DbGoTop())

nDebProp:= TDEB->DEBTOT-TDEB->DEBTER-TDEB->DEBCC-TDEB->DEBCONS
cCliDeb	:= cValtoChar(Transform(nDebProp,"@E 999,999,999.99"))

cQuery:=" SELECT SUM(CASE WHEN (TIPO <> 'QTDFOR' AND TIPO <> 'PRURAL') THEN 	"
cQuery+="              VLR   ELSE  0   END) LIMITEATUAL, 						"
cQuery+="       SUM(CASE WHEN  TIPO = 'CHSFD' THEN VLR ELSE 0 END) CHSF, 		"
cQuery+="       SUM(CASE WHEN  TIPO LIKE 'FUND%A' THEN VLR ELSE 0 END) FUNDACAO,"
cQuery+="       SUM(CASE WHEN  TIPO = 'PRURAL' THEN VLR ELSE 0 END) PRURAL, 	"
cQuery+="       SUM(CASE WHEN  TIPO = 'LJPRO'  THEN VLR ELSE 0 END) LJPRO, 		"
cQuery+="       SUM(CASE WHEN  TIPO = 'QTDFIL' THEN VLR ELSE 0 END) QTDFIL, 	"
cQuery+="       SUM(CASE WHEN  TIPO = 'PARVD'  THEN VLR ELSE 0 END) PARECEVD, 	"
cQuery+="       SUM(CASE WHEN  TIPO = 'OUTEMP' THEN VLR ELSE 0 END) OUTEMP, 	"
cQuery+="       SUM(CASE WHEN  TIPO = 'PARGE'  THEN VLR ELSE 0 END) PARECEGE, 	"
cQuery+="       SUM(CASE WHEN  TIPO = '10%CAP' THEN VLR ELSE 0 END) Z5_P10CAP, 	"
cQuery+="       SUM(CASE WHEN  TIPO = 'PONTUA' THEN VLR ELSE 0 END) PONTUALIDADE,"
cQuery+="       SUM(CASE WHEN  TIPO = '3%FAT'  THEN VLR ELSE 0 END) FATLOJA, 	"
cQuery+="       SUM(CASE WHEN  TIPO = 'COMPRA' THEN VLR ELSE 0 END) UPME_COMPRA "
cQuery+="  FROM SIGA.PON"+cEmpAnt+" PON "
cQuery+=" WHERE "
cQuery+="   GRUPO = '"+cCodGru+"'"
cQuery+="   AND USU = '"+_cUsu+"'"
memowrit("c:\ORTR727(PONTUACAO).SQL", cquery)

If Select("TPON") > 0
	TPON->(DbCloseArea())
Endif
tcquery cquery alias "TPON" NEW
DbSelectArea("TPON")
TPON->(DbGoTop())

cCliLim	:= cValtoChar(Transform(TPON->LIMITEATUAL*nUpmePed,"@E 999,999,999.99"))

TPON->(DbCloseArea())

//Alert(nDebProp)

cQuery:="DELETE DEB"+cEmpAnt+" WHERE USU = '"+_cUsu+"'"
TCSQLEXEC(cQuery)
//		TCSQLEXEC("COMMIT")
cQuery:="DELETE PED"+cEmpAnt+" WHERE USU = '"+_cUsu+"'"
TCSQLEXEC(cQuery)
//		TCSQLEXEC("COMMIT")
cQuery:="DELETE PON"+cEmpAnt+" WHERE USU = '"+_cUsu+"'"
TCSQLEXEC(cQuery)
//		TCSQLEXEC("COMMIT")
cQuery:="DELETE PROCDEB WHERE USU = '"+_cUsu+"'"
TCSQLEXEC(cQuery)

//================== Cabeçalho-Proposta ==================//
oPrinter:Box(0044,0044,3000,2350)		// Margem
fImpCab()
SA1->(DBCloseArea())

//================== Itens do Pedido ==================//

For nI:= 1 to Len(aPedidos)
	
	Dbselectarea("SC5")
	DbsetOrder(1)
	Dbseek(xFilial("SC5")+aPedidos[nI])	
	Dbselectarea("SC6")
	Dbsetorder(1)
	If Dbseek(xFilial("SC5")+SC5->C5_NUM)
		
		Do While SC6->(!EOF()) .and. SC6->C6_NUM == SC5->C5_NUM
			
			fLinha()
			
			
			oPrinter:Say(nLin,0070,"Produto:  "+SC6->C6_PRODUTO+SC6->C6_DESCRI,oTim10N,,0)
			oPrinter:Say(nLin,1250,"Marc.: "	+cValtoChar(Transform(U_CalcMM(2,(SC6->C6_XPRUNIT - (SC6->C6_XFEILOJ/SC6->C6_QTDVEN)), SC6->C6_XCUSTO  ),"@E 99.99"))		,oTim10N,,0)
			oPrinter:Say(nLin,1550,"Mix: "		+cValtoChar(Transform(U_CalcMM(1,(SC6->C6_XPRUNIT - (SC6->C6_XFEILOJ/SC6->C6_QTDVEN)), SC6->C6_XCUSTO  ),"@E 99.99"))+"%"		,oTim10N,,0)
			oPrinter:Say(nLin,1850,"Qtd.: "	+cValtoChar(Transform(SC6->C6_QTDVEN,"@E 999,999.99"))	,oTim10N,,0)
			nLin+=nEsp
			
			nQtdVen := SC6->C6_QTDVEN
			If SC5->C5_XOPER <> '05'
				nTotPed += SC6->C6_VALOR
			Endif
			nTotMarc+= U_CalcMM(2,(SC6->C6_XPRUNIT - (SC6->C6_XFEILOJ/SC6->C6_QTDVEN)), SC6->C6_XCUSTO) * nQtdVen
			nTCusto += SC6->C6_XCUSTO * nQtdVen
			nItens  	+= SC6->C6_QTDVEN
			nSimBa	+= SC6->C6_XFEILOJ                                     	
			_cQuery := " SELECT FCUSTOPA"+cEmpAnt+"0('"+SC6->C6_PRODUTO+"') CUSTO_REAL FROM DUAL " 			
			If Select("CUSR") > 0
				CUSR->(DbCloseArea())
			Endif
			TcQuery _cQuery Alias "CUSR" New
			nPCusReal += CUSR->CUSTO_REAL
			CUSR->(DbCloseArea())
			//nPCusReal += nPCusReal*0.1
			nTCusReal += nPCusReal * SC6->C6_QTDVEN
			nPCusReal:=0
			SC6->(DbSkip())
			
		Enddo
	Else
		Conout("ORTR727-Itens Pedido:"+SC5->C5_NUM+" Emp.:"+cEmpAnt+" Filial: "+xFilial("SC5")+" Não localizados!")
	Endif
	
Next nI

nMix	 := (1-(1/((nTotPed-nSimBa)/nTCusto)))*100

nLin+=nEsp

If !(Empty(MV_PAR02))
	fLinha()
	oPrinter:Say(nLin,0070,"Quem está vendendo?  "+MV_PAR03 ,oTim10N, ,0)
	nLin+=nEsp*2
Endif

oPrinter:Say(nLin,1550, "Valor do pedido R$ " ,oTim10N,,0)
oPrinter:Say(nLin,1860, Transform(nTotPed,"@E 999,999,999.99") ,oTim10N,,0)

//================== Tabelas / Preço / Custo / MIX ==================//

If cEmpAnt = '18' .And. cFilAnt = '03'
	_cUn := '27'
Else
	_cUn := cEmpAnt
EndIf

cQuery := " SELECT PERC, DG "
cQuery += "   FROM SIGA.GANHOF "
cQuery += " WHERE UN = '"+_cUn+"' "
cQuery += " AND MES = '"+SubStr(DtoS(dDatabase),5,2)+"'  "
cQuery += " AND ANO = '"+SubStr(DtoS(dDatabase),3,2)+"'  "
cQuery += " AND D_E_L_E_T_ = ' '  "
cQuery += "  ORDER BY ANO, MES "

Memowrite("C:\727GFDG.SQL", cQuery)

IF SELECT("QRY") > 0
	DBSELECTAREA("QRY")
	DBCLOSEAREA()
ENDIF

TcQuery cQuery ALIAS "QRY" NEW

DbSelectArea("QRY")
QRY->(DBGoTop())

If !(EOF("QRY"))
	nGf:= QRY->PERC
	nDg:= QRY->DG
Else
//	nGf:= 10.64
//	nDg:= 34.82
	MsgInfo("Ganho fabril e Despesas Gerais não localizados, favor verificar cadastro!")
Endif

Dbselectarea("SM2")
DBSetorder(1)

If nLin+500 > 2675
	
	//oPrinter:Line (nLin, 0050,nLin , 2350)
	nLin := 100
	oPrinter:EndPage()
	oPrinter:StartPage()
	oPrinter:Box(0044,0044,3000,2350)		// Margem
	nPag++
/*
	oPrinter:Say(0100,0100,"Pag. "+cValTochar(nPag)		,oTim10N,,0)
	nLin+=nEsp
	oPrinter:Say(0150,0100,"Proposta: "+StrZero(nProp,8),oTim10N,,0)
	nLin+=nEsp
*/
	fImpCab()	
//	oPrinter:Line (nLin, 0050,nLin , 2350)
EndIf

nLin += nEsp

If Dbseek(SC5->C5_EMISSAO)
	nUpmePed:=SM2->M2_MOEDA5
	fLinha()
	oPrinter:Say(nLin,0100,"UPME Dia: "+ cValToChar(Transform(nUpmePed,"@E 999.99")),oTim10N,,0)
Else
	fLinha()
	oPrinter:Say(nLin,0100,"UPME Dia: "+ "Valor não localizado",oTim10N,,0)
Endif
oPrinter:Say(nLin,1200,"Somente utilizar se a marcação, pelo custo MARFIL, for inferior a 1,5",oTim11N,,0)
oPrinter:Say(nLin+(nEsp*0.7),1200,"ou em caso de resultado negativo.",oTim11N,,0)
nLin+=nEsp

SM2->(DbCloseArea())

//------------------------------------ TABELA PEDIDO ------------------------------//

nLinIf:=nLin // Marca Linha If

oPrinter:Box(nLin,0044,nLin+nEsp,1000)
oPrinter:Box(nLin,1200,nLin+nEsp,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, "Valor do Pedido ",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1250, "Valor do Pedido ",oTim10N,,0)

nLin+=nEsp

oPrinter:Box(nLin,0044,nLin+nEsp,1000)
oPrinter:Box(nLin,1200,nLin+nEsp,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, "Custo MARFIL ",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1250, "Custo Prático ",oTim10N,,0)
If nTotPed/nTCusto < 1.5 .OR. (nMix+nGf-nDg) < 0
	oPrinter:Box(nLin,01000,nLin+nEsp,1200)
Endif

nLin+=nEsp

oPrinter:Box(nLin,0044,nLin+nEsp,1000)
oPrinter:Box(nLin,1200,nLin+nEsp,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, "Marcação ",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1250, "Marcação ",oTim10N,,0)

nLin+=nEsp

oPrinter:Box(nLin,0044,nLin+nEsp,1000)
oPrinter:Box(nLin,1200,nLin+nEsp,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, "MIX ",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1250, "MIX ",oTim10N,,0)

nLin+=nEsp

oPrinter:Box(nLin,0044,nLin+nEsp,1000)
oPrinter:Box(nLin,1200,nLin+nEsp,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, "Ganho Fabril ",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1250, "Total DG Comercial ",oTim10N,,0)

nLin+=nEsp

oPrinter:Box(nLin,0044,nLin+nEsp,1000)
oPrinter:Box(nLin,1200,nLin+nEsp,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, "MIX + Ganho Fabril ",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1250, "DG Sobre o valor do Pedido ",oTim10N,,0)

nLin+=nEsp

oPrinter:Box(nLin,0044,nLin+nEsp,1000)
oPrinter:Box(nLin,1200,nLin+nEsp,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, "Total DG Comercial ",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1250, "Lucro (MIX-DG) ",oTim10N,,0)

nLin+=nEsp

oPrinter:Box(nLin,0044,nLin+nEsp,1000)
oPrinter:Say(nLin+nEsp*0.7, 0100, "DG Sobre o Valor do Pedido ",oTim10N,,0)
nLin+=nEsp

oPrinter:Box(nLin,0044,nLin+nEsp,1000)
oPrinter:Say(nLin+nEsp*0.7, 0100, "Lucro (MIX+GF-DG) ",oTim10N,,0)
If nSimBa > 0
	oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	oPrinter:Say(nLin+nEsp*0.7, 1250, "SimBahia ",oTim10N,,0)
Endif
nLin+=nEsp

oPrinter:Line ( nLin-nEsp*9	,0600, nLin, 0600)
oPrinter:Line ( nLin-nEsp	,0780, nLin, 0780)
oPrinter:Line ( nLin-nEsp*9	,1750, nLin-nEsp*2,1750 )
oPrinter:Line ( nLin-nEsp*3	,1930, nLin-nEsp*2,1930 )
nLin+=nEsp


//---------Impressão dos Valores----------//

If nTotPed/nTCusto < 1.5 .OR. (nMix+nGf-nDg) < 0 //.OR. nTCusto/nTCusReal < 1.5
	
	nTCusReal+= nTCusReal*0.05
	nTCusReal+= nTCusReal*0.05
	nMarcReal:= (nTotPed-nSimBa)/nTCusReal
	nMixReal := (1-(1/nMarcReal))*100
	
	//Valor Pedido
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, "R$ "+cValtoChar(Transform(nTotPed,"@E 999,999,999.99")) ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 1950, "R$ "+cValtoChar(Transform(nTotPed,"@E 999,999,999.99")) ,oTim10N,,0)
	
	//Custo Marfil/Pratico 	// Comparativo
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, "R$ "+cValtoChar(Transform(nTCusto,"@E 999,999,999.99")) ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 1950, "R$ "+cValtoChar(Transform(nTCusReal,"@E 999,999,999.99")) ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 1080, cValtoChar(Transform(nTCusto/nTCusReal,"@E 99.99")) ,oTim10N,,0)
	
	//Marcacao
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, cValtoChar(Transform((nTotPed-nSimBa)/nTCusto,"@E 999,999,999.99")) ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform(nMarcReal,"@E 999,999,999.99")) ,oTim10N,,0)
	
	//MIX
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, cValToChar(Transform(nMix,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValToChar(Transform(nMixReal,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	
	
	//Ganho Fabril / Total DG
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, cValtoChar(Transform(nGf,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform(nDg,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	
	//MIX + Ganho // DG Pedido
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, cValtoChar(Transform(nMix+nGf,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 1950, "R$ "+cValtoChar(Transform((nTotPed-nSimBa)*nDg/100,"@E 999,999,999.99")) ,oTim10N,,0)
	
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, cValtoChar(Transform(nDg,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 1730, cValtoChar(Transform(nMixReal-nDg,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 1950, "R$ "+cValtoChar(Transform(((nMixReal-nDg)*nTotPed)/100,"@E 999,999,999.99")) ,oTim10N,,0)
	
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, "R$ "+cValtoChar(Transform((nTotPed-nSimBa)*nDg/100,"@E 999,999,999.99")) ,oTim10N,,0)
	
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0600, cValtoChar(Transform(nMix+nGf-nDg,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 0795, "R$ "+cValtoChar(Transform(((nMix+nGf-nDg)*nTotPed)/100,"@E 999,999,999.99")) ,oTim10N,,0)
	If nSimBa > 0
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform(nSimBa,"@E 999,999,999.99")) ,oTim10N,,0)
	Endif
	
Else
	
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, "R$ "+cValtoChar(Transform(nTotPed,"@E 999,999,999.99")) ,oTim10N,,0)
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, "R$ "+cValtoChar(Transform(nTCusto,"@E 999,999,999.99")) ,oTim10N,,0)
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, cValtoChar(Transform((nTotPed-nSimBa)/nTCusto,"@E 999,999,999.99")) ,oTim10N,,0)
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, cValToChar(Transform(nMix,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, cValtoChar(Transform(nGf,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, cValtoChar(Transform(nMix+nGf,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, cValtoChar(Transform(nDg,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0700, "R$ "+cValtoChar(Transform((nTotPed-nSimBa)*nDg/100,"@E 999,999,999.99")) ,oTim10N,,0)
	nLinIf+=nEsp
	
	oPrinter:Say(nLinIf+nEsp*0.7, 0600, cValtoChar(Transform(nMix+nGf-nDg,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	oPrinter:Say(nLinIf+nEsp*0.7, 0795, "R$ "+cValtoChar(Transform(((nMix+nGf-nDg)*nTotPed)/100,"@E 999,999,999.99")) ,oTim10N,,0)
	If nSimBa > 0
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform(nSimBa,"@E 999,999,999.99")) ,oTim10N,,0)
	Endif
	
Endif

//fLinha()

If nLin+500 > 2675
	
	//oPrinter:Line (nLin, 0050,nLin , 2350)                                       
	nLin := 100
	oPrinter:EndPage()
	oPrinter:StartPage()
//	oPrinter:Box(0044,0044,3000,2350)		// Margem
	nPag++
/*
	oPrinter:Say(0100,0100,"Pag. "+cValTochar(nPag)		,oTim10N,,0)
	nLin+=nEsp
	oPrinter:Say(0150,0100,"Proposta: "+StrZero(nProp,8),oTim10N,,0)
	nLin+=nEsp
*/
	fImpCab()	
//	oPrinter:Line (nLin, 0050,nLin , 2350)
EndIf

nLinAtu := nLin

// NOVA TABELA ATUAL ------------------------------------------------------------------------------------------------------------------------------------- //
_cTabela := ""
_cQry	:=	" SELECT MAX(DA0_CODTAB) DA0_CODTAB FROM "+RetSQLName("DA0")+" DA0 "
_cQry	+="                     WHERE DA0.D_E_L_E_T_ = ' ' "
_cQry	+="                       AND DA0_FILIAL = '"+xFilial("DA0")+"' "
_cQry	+="                       AND DA0_DATATE = (SELECT MAX(DA0_DATATE) FROM "+RetSQLName("DA0")+" DA0 "
_cQry	+="                                          WHERE DA0.D_E_L_E_T_ = ' ' "
_cQry	+="                                            AND DA0_DATDE <= '"+Dtos(dDataBase)+"' "
_cQry	+="                                            AND DA0_DATATE >= '"+Dtos(dDataBase)+"' "
_cQry	+="                                            AND DA0_FILIAL = '"+xFilial("DA0")+"') 

MemoWrit('C:\QRY\TAB_ATU',_cQry)

If Select("TABATU") > 0
	TABATU->(DbCloseArea())
Endif

TcQuery _cQry New Alias "TABATU"

If TABATU->(!EOF())
	_cTabela := TABATU->da0_codtab
Endif

// Se Tabelas forem diferentes -------------------------------------------------------------------------------------------------------------------------- //
If _cTabOri <> _cTabela

	nLin := nLinAtu
	nLin+=25
	oPrinter:Say(nLin,1220,"Tabela Atual ["+_cTabela+"]",oTim10N,,0)
	nLin+=25
	nLinIf:=nLin // Marca Linha If
	oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	oPrinter:Say(nLin+nEsp*0.7, 1220, "Valor do Pedido ",oTim10N,,0)
	
	//nLin+=nEsp
	//oPrinter:Box(nLin,1200,nLin+nEsp,2350)                                                                                      
	//oPrinter:Say(nLin+nEsp*0.7, 1220, "Valor após Verbas e Provisionamento ",oTim10N,,0)
	
	nLin+=nEsp
	oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	oPrinter:Say(nLin+nEsp*0.7, 1220, "Custo MARFIL ",oTim10N,,0)
	
	nLin+=nEsp
	oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	oPrinter:Say(nLin+nEsp*0.7, 1220, "Marcação ",oTim10N,,0)
	
	nLin+=nEsp
	oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	oPrinter:Say(nLin+nEsp*0.7, 1220, "MIX",oTim10N,,0)
	
	//nLin+=nEsp
	//oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	//oPrinter:Say(nLin+nEsp*0.7, 1220, "VPC Pontual",oTim10N,,0)
	
	//nLin+=nEsp
	//oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	//oPrinter:Say(nLin+nEsp*0.7, 1220, "MIX(2)- VPC Pontual",oTim10N,,0)
	
	nLin+=nEsp
	oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	oPrinter:Say(nLin+nEsp*0.7, 1220, "Ganho Fabril ",oTim10N,,0)
	
	nLin+=nEsp
	oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	oPrinter:Say(nLin+nEsp*0.7, 1220, "MIX + Ganho Fabril ",oTim10N,,0)
	
	nLin+=nEsp
	oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	oPrinter:Say(nLin+nEsp*0.7, 1220, "Total DG Comercial ",oTim10N,,0)
	
	nLin+=nEsp
	oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	oPrinter:Say(nLin+nEsp*0.7, 1220, "DG Sobre o Valor do Pedido ",oTim10N,,0)
	nLin+=nEsp
	
	oPrinter:Box(nLin,1200,nLin+nEsp,2350)
	oPrinter:Say(nLin+nEsp*0.7, 1220, "Lucro (MIX+GF-DG) ",oTim10N,,0)
	nLin+=nEsp
	
	//oPrinter:Line ( nLin-nEsp*09,1750, nLin, 1750)
	//oPrinter:Line ( nLin-nEsp*1	,1930, nLin, 1930)
	//oPrinter:Line ( nLin-nEsp*7	,1930, nLin-nEsp*6 , 1930)
	//oPrinter:Line ( nLin-nEsp*08,1930, nLin-nEsp*07, 1930)
	
	oPrinter:Line ( nLin-nEsp*9	,1750, nLin, 1750)
	oPrinter:Line ( nLin-nEsp	,1930, nLin, 1930)
	
	nLin+=nEsp
	
	//================== Itens do Pedido ==================// NOVA TABELA
	//nVpcPon2		:= nVpcPon
	//nDesVar2		:= nDesVar
	//nDescFin2  	:= nDescFin
	//nDescMes2  		:= nDescMes
	nGf2			:= nGf
	nDg2			:= nDg
	
	For nI:= 1 to Len(aPedidos)
		
		Dbselectarea("SC5")
		DbsetOrder(1)
		Dbseek(xFilial("SC5")+aPedidos[nI])
		
		Dbselectarea("SC6")
		Dbsetorder(1)
		If Dbseek(xFilial("SC5")+SC5->C5_NUM)
			While SC6->(!EOF()) .and. SC6->C6_NUM == SC5->C5_NUM
				
				_cProduto := SC6->C6_PRODUTO
	
				_nPrcVen := SC6->C6_PRCVEN
				_nXCusto := SC6->C6_XCUSTO
				DbSelectArea('DA1')
				DbSetOrder(1)
				DbGoTop()
				if Dbseek(xFilial('DA1') + _cTabela + _cProduto) // Tabela de Preço do produto
					If DA1->DA1_PRCVEN <> 0
						_nPrcVen := DA1->DA1_PRCVEN
					Endif	
					If DA1->DA1_XCUSTO <> 0 
						_nXCusto := DA1->DA1_XCUSTO
					Endif	
	//				SC6->C6_XMIX    := U_FMIX(SC6->C6_PRCVEN, SC6->C6_XCUSTO)
	//				SC6->C6_XMARKUP := U_FMKP(SC6->C6_PRCVEN,SC6->C6_XCUSTO)	
				Endif
				
				nQtdVen2 := SC6->C6_QTDVEN
				_nC6_valor:= (_nPrcVen * nQtdVen)
				If SC5->C5_XOPER <> '05'
					nTotPed2 += _nC6_valor
				Endif
				nTotMarc2+= U_CalcMM(2,(SC6->C6_XPRUNIT - (SC6->C6_XFEILOJ/SC6->C6_QTDVEN)), _nXCusto) * nQtdVen2
				nTCusto2 += _nXCusto * nQtdVen2
				nItens2  += SC6->C6_QTDVEN
				nSimBa2  += SC6->C6_XFEILOJ
				
				_cQuery := " SELECT FCUSTOPA"+cEmpAnt+"0('"+SC6->C6_PRODUTO+"') AS TOTAL_REAL "			
				_cQuery += "   FROM DUAL"
				
				If Select("CUSR") > 0
					CUSR->(DbCloseArea())
				Endif
				TcQuery _cQuery Alias "CUSR" New
				DbSelectArea("CUSR")
				nPCusReal2 := CUSR->TOTAL_REAL
				CUSR->(DbCloseArea())
				nTCusReal2 += (nPCusReal2 * SC6->C6_QTDVEN)
				nPCusReal2:=0
				SC6->(DbSkip())
				
			End
		Endif
		
	Next nI

	nTotPed2 := nTotPed
	
	//nTLiqVpc2 := nTotPed2 - ((SC5->C5_XVERREP*nTotPed2)/100) - (nVpcPon2*nTotPed2/100)
	nMix2	 := (1-(1/((nTotPed2-nSimBa2)/nTCusto2)))*100
	
	//nMarcMarf2:=((nTotPed2-nSimBa2)-(nTotPed2*SC5->C5_XVERREP/100))/nTCusto2
	//nTLucMar2 :=((1-(1/nMarcMarf2))*100)-nVpcPon2+nGf2-nDg2
	
	////////=============== Impressão dos Valores ===============////////
	
	If nTotPed2/nTCusto2 < 1.5 .OR. (nMix2+nGf2-nDg2) < 0
		
		// [01]
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, "R$ "+cValtoChar(Transform(nTotPed2,"@E 999,999,999.99")) ,oTim10N,,0)
		
		// [03]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, "R$ "+cValtoChar(Transform(nTCusto2,"@E 999,999,999.99")) ,oTim10N,,0)
	
		// [04]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform((nTotPed2-nSimBa2)/nTCusto2,"@E 999,999,999.99")) ,oTim10N,,0)
	
		// [05]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValToChar(Transform(nMix2,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
		
		// [08]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform(nGf2,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	
		// [09]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform(nMix2+nGf2,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	
		// [10]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform(nDg2,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	
		// [11]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, "R$ "+cValtoChar(Transform((nTotPed2-nSimBa2)*nDg2/100,"@E 999,999,999.99")) ,oTim10N,,0)
	
		// [12]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1755, cValtoChar(Transform(nMix2+nGf2-nDg2,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
		oPrinter:Say(nLinIf+nEsp*0.7, 1955, "R$ "+cValtoChar(Transform(((nMix2+nGf2-nDg2)*nTotPed2)/100,"@E 999,999,999.99")) ,oTim10N,,0)
		
	Else
		
		// [01]
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, "R$ "+cValtoChar(Transform(nTotPed2,"@E 999,999,999.99")) ,oTim10N,,0)
		
		// [03]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, "R$ "+cValtoChar(Transform(nTCusto2,"@E 999,999,999.99")) ,oTim10N,,0)
	
		// [04]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform((nTotPed2-nSimBa2)/nTCusto2,"@E 999,999,999.99")) ,oTim10N,,0)
	
		// [05]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValToChar(Transform(nMix2,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	
		// [08]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform(nGf2,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	
		// [09]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform(nMix2+nGf2,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	
		// [10]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, cValtoChar(Transform(nDg2,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
	
		// [11]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1950, "R$ "+cValtoChar(Transform((nTotPed2-nSimBa2)*nDg2/100,"@E 999,999,999.99")) ,oTim10N,,0)
	
		// [12]	
		nLinIf+=nEsp
		oPrinter:Say(nLinIf+nEsp*0.7, 1755, cValtoChar(Transform(nMix2+nGf2-nDg2,"@E 999,999,999.99"))+"%" ,oTim10N,,0)
		oPrinter:Say(nLinIf+nEsp*0.7, 1955, "R$ "+cValtoChar(Transform(((nMix2+nGf2-nDg2)*nTotPed2)/100,"@E 999,999,999.99")) ,oTim10N,,0)
		
	Endif
	// NOVA TABELA ATUAL ------------------------------------------------------------------------------------------------------------------------------------- //
Endif

oPrinter:Box(nLin,0600,nLin+nEsp,1000)
oPrinter:Box(nLin,1000,nLin+nEsp,1750)
oPrinter:Say(nLin+nEsp*0.7, 0700, "Prazo Médio: ",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1300, cValtoChar(MV_PAR10)/*cValtoChar(SC5->C5_XPRZMED)*/,oTim10N,,0)
nLin+=nEsp*2
QRY->(DBCloseArea())

//-------------------------FIM TABELA DE CUSTO--------------------------//

//--------------------=====||COMENTARIOS||=====---------------------------//

nLin+=nEsp
fLinha()
oPrinter:Say(nLin, 0070, "Comentários: ",oTim11N,,0)
nLin += nEsp/2
oPrinter:Line (nLin, 0050,nLin , 2350)
nLin += nEsp
cPeds := SC5->C5_XOBSPRO					//Impressão do Campo MEMO - Observação
_nLinhas := MlCount(cPeds,105)
For nX := 1 To _nLinhas
	oPrinter:Say( nLin,100, MemoLine(cPeds,105,nX),oTim10N, ,0)
	nLin +=nEsp
Next nX
//nLin += nEsp/2
//oPrinter:Line (nLin, 0050,nLin , 2350)
//nLin += nEsp
oPrinter:Say(nLin, 0100, "Pedidos: "+SUBSTR(cPedidos,1,140),oTim11N,,0)
nLin += nEsp
_nPosPed := 141
_nTamPed := 150
oPrinter:Say(nLin, 0100, SUBSTR(cPedidos,_nPosPed,_nTamPed),oTim11N,,0)
nLin += nEsp
For _Nf := 1 to 15
	If STRZERO(_Nf,2) $ "05/10" // A cada 5 Linhas verifica quebra
		If nLin+300 > 2675
			nLin := 10
			oPrinter:EndPage()
			oPrinter:StartPage()
			oPrinter:Box(0044,0044,3000,2350)		// Margem
			nPag++
		
			fImpCab()	
		EndIf
	Endif	

	_nPosPed += _nTamPed
	If AllTrim(SUBSTR(cPedidos,_nPosPed,_nTamPed)) <> ""
		oPrinter:Say(nLin, 0100, SUBSTR(cPedidos,_nPosPed,_nTamPed),oTim11N,,0)
		nLin += nEsp	
	Endif	
Next 

oPrinter:Say(nLin, 0100, "Forma de Pagamento: "+MV_PAR11,oTim11N,,0)
nLin += nEsp

//-----------------=====||OPÇÕES MIX INFERIOR||=====-----------------//

If nLin+300 > 2675
	
	nLin := 10
	oPrinter:EndPage()
	oPrinter:StartPage()
	oPrinter:Box(0044,0044,3000,2350)		// Margem
	nPag++

	fImpCab()	
EndIf

//oPrinter:Line (nLin, 0050,nLin , 2350)
nLin += nEsp
fLinha()

//-----------======||Médias Trim/Mes/Prop||======------------//

DbSelectarea("SC5")
DbSetOrder(1)
DbSeek(xFilial("SC5")+aPedidos[1])
FPRAZO(SC5->C5_EMISSAO, SC5->C5_CLIENTE, SC5->C5_LOJACLI)
//FMANOP(SC5->C5_EMISSAO, SC5->C5_CLIENTE, SC5->C5_LOJACLI) //05082021
//FPRAZO(dDatabase,cCodGru,SC5->C5_LOJACLI)

////----------=========||Classificação da Proposta/Cliente||=========-----------\\\\\

If nUpmeT>2500 .OR. nUpmeM>2500 .OR. nUpmeD>2500 .OR. (nTotPed/nUpmePed)>2500
	cClassCli:= "SUPER VERTICAL"
Elseif nUpmeT>299  .OR. nUpmeM>299 .OR. nUpmeD>299  .OR. (nTotPed/nUpmePed) >299
	cClassCli:= "ESPECIAL"
Else
	cClassCli:= "PULVERIZADO"
Endif

////---------------=========||Pulv./Espec./Sup.Vert./Com.Geral||===========----------------\\\\

//	nLin+=nEsp*2
//	fLinha()
oPrinter:Say(nLin,0175, "Classificação do Cliente: "+cClassCli , oTim10N, , 0 )
//	nLin+=nEsp*2

//	fLinha()
oPrinter:Say(nLin, 0900, "Mix com rentabilidade inferior a média trimestral ou último mês deve informar:" ,oTim11N,,0)
nLin += nEsp

If mv_par05
	oPrinter:Say(nLin, 0100, "Foi concedido desconto, brinde ou algum VPC que fez a rentabilidade diminuir" ,oTim10N,,0)
	nLin += nEsp
Endif
If mv_par06
	oPrinter:Say(nLin, 0100, "Houve alta de custo e a alta não foi repassada ao cliente diminuindo a rentabilidade" ,oTim10N,,0)
	nLin += nEsp
Endif
If mv_par07
	oPrinter:Say(nLin, 0100, "Aumentou a participação de produtos que tem a rentabilidade inferior a média" ,oTim10N,,0)
	nLin += nEsp
Endif
If mv_par08
	oPrinter:Say(nLin, 0100, "Caiu a participação de produtos que tem a rentabilidade superior a média" ,oTim10N,,0)
	nLin += nEsp
Endif

If !(Empty(mv_par09))
	fLinha()
	oPrinter:Say(nLin, 0100, "Outros: "+ mv_par09 ,oTim10N,,0)
	nLin += nEsp
Endif

oPrinter:Line (nLin, 0050,nLin , 2350)

fLinha()

  nLin+=10
  
  //oPrinter:Box(nLin,0056,nLin+nEsp,0523) //05082021

  oPrinter:Box(nLin,0539,nLin+nEsp,1005)

  oPrinter:Box(nLin,1017,nLin+nEsp,1481)

  oPrinter:Box(nLin,1495,nLin+nEsp,1964)

  oPrinter:Box(nLin,1976,nLin+nEsp,2348)
  
  //oPrinter:Say(nLin+nEsp*0.7,0125,"Venda do Mês Ano Anterior"	,oTim10N,,0) //05082021
  oPrinter:Say(nLin+nEsp*0.7,0665,"Média Trimestre"				,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,1129,"Último Mês"					,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,1584,"Últimos 30 Dias"				,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,2097,"Proposta"					,oTim10N,,0)

  nLin+=nEsp

  //oPrinter:Box(nLin,0056,nLin+nEsp,0289) //05082021 
  //oPrinter:Box(nLin,0289,nLin+nEsp,0525) //05082021

  oPrinter:Box(nLin,0539,nLin+nEsp,0774)
  oPrinter:Box(nLin,0774,nLin+nEsp,1005)

  oPrinter:Box(nLin,1017,nLin+nEsp,1250)
  oPrinter:Box(nLin,1250,nLin+nEsp,1481)

  oPrinter:Box(nLin,1495,nLin+nEsp,1729)
  oPrinter:Box(nLin,1729,nLin+nEsp,1962)

  oPrinter:Box(nLin,1976,nLin+nEsp,2190)
  oPrinter:Box(nLin,2190,nLin+nEsp,2345)

  //oPrinter:Say(nLin+nEsp*0.7,0105,"UPME"	,oTim10N,,0) //05082021
  //oPrinter:Say(nLin+nEsp*0.7,0340,"MIX"		,oTim10N,,0) //05082021
  oPrinter:Say(nLin+nEsp*0.7,0567,"UPME"	,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,0823,"MIX"		,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,1059,"UPME"	,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,1292,"MIX"		,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,1544,"UPME"	,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,1785,"MIX"		,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,2013,"UPME"	,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,2251,"MIX"		,oTim10N,,0)


  nLin+=nEsp

  //oPrinter:Box(nLin,0056,nLin+nEsp,0289) //05082021
  //oPrinter:Box(nLin,0289,nLin+nEsp,0525) //05082021

  oPrinter:Box(nLin,0539,nLin+nEsp,0774)
  oPrinter:Box(nLin,0774,nLin+nEsp,1005)

  oPrinter:Box(nLin,1017,nLin+nEsp,1250)
  oPrinter:Box(nLin,1250,nLin+nEsp,1481)

  oPrinter:Box(nLin,1495,nLin+nEsp,1729)
  oPrinter:Box(nLin,1729,nLin+nEsp,1962)

  oPrinter:Box(nLin,1976,nLin+nEsp,2190)
  oPrinter:Box(nLin,2190,nLin+nEsp,2345)

  

//oPrinter:Say(nLin+nEsp*0.7, 0105, cValToChar(Transform(nUpAmeM	,"@E 999,999,999.99"))			,oTim10N,,0) //05082021
//oPrinter:Say(nLin+nEsp*0.7, 0312, cValToChar(Transform(nMAMes	,"@E 999.99"))+"%"				,oTim10N,,0) //05082021


oPrinter:Say(nLin+nEsp*0.7, 0571, cValToChar(Transform(nUpmeT	,"@E 999,999,999.99"))			,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0800, cValToChar(Transform(nMTri	,"@E 999.99"))+"%"				,oTim10N,,0)

oPrinter:Say(nLin+nEsp*0.7, 1066, cValToChar(Transform(nUpmeM	,"@E 999,999,999.99"))			,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(nMMes	,"@E 999.99"))+"%"				,oTim10N,,0)

oPrinter:Say(nLin+nEsp*0.7, 1537, cValToChar(Transform(nUpmeD	,"@E 999,999,999.99"))			,oTim10N,,0)
If nM30 < 0 
	oPrinter:Say(nLin+nEsp*0.7, 1771, cValToChar(Transform(nM30	,"@E 99999.99"))+"%"			,oTim10N,,0)
Else
	oPrinter:Say(nLin+nEsp*0.7, 1771, cValToChar(Transform(nM30	,"@E 999.99"))+"%"				,oTim10N,,0)
Endif		

oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(nTotPed/nUpmePed,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(nMix,"@E 999.99"))+"%"					,oTim10N,,0)

 // nLin+=nEsp

/* Solicitação ##119519##
//1ª Box
oPrinter:Box(nLin,0175,nLin+nEsp,0575)
oPrinter:Box(nLin,0675,nLin+nEsp,1075)
oPrinter:Box(nLin,1175,nLin+nEsp,1575)
oPrinter:Box(nLin,1675,nLin+nEsp,2075)
oPrinter:Say(nLin+nEsp*0.7, 0195, PadC("Média Trimestre",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0695, PadC("Último Mês",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1195, PadC("Últimos 30 dias",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1695, PadC("Proposta",35),oTim10N,,0)
nLin+=nEsp

//2ª Box
oPrinter:Box(nLin,0175,nLin+nEsp,0425)
oPrinter:Box(nLin,0425,nLin+nEsp,0575)
oPrinter:Box(nLin,0675,nLin+nEsp,0925)
oPrinter:Box(nLin,0924,nLin+nEsp,1075)
oPrinter:Box(nLin,1175,nLin+nEsp,1425)
oPrinter:Box(nLin,1425,nLin+nEsp,1575)
oPrinter:Box(nLin,1675,nLin+nEsp,1925)
oPrinter:Box(nLin,1925,nLin+nEsp,2075)

oPrinter:Say(nLin+nEsp*0.7, 0195, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0445, "MIX"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0695, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0944, "MIX"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1195, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1445, "MIX"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1695, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1945, "MIX"	,oTim10N,,0)
nLin+=nEsp

//3ª Box
oPrinter:Box(nLin,0175,nLin+nEsp,0425)
oPrinter:Box(nLin,0425,nLin+nEsp,0575)
oPrinter:Box(nLin,0675,nLin+nEsp,0925)
oPrinter:Box(nLin,0924,nLin+nEsp,1075)
oPrinter:Box(nLin,1175,nLin+nEsp,1425)
oPrinter:Box(nLin,1425,nLin+nEsp,1575)
oPrinter:Box(nLin,1675,nLin+nEsp,1925)
oPrinter:Box(nLin,1925,nLin+nEsp,2075)

oPrinter:Say(nLin+nEsp*0.7, 0215, cValToChar(Transform(nUpmeT,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0445, cValToChar(Transform(nMTri,"@E 999.99"))+"%"	,oTim10N,,0)

oPrinter:Say(nLin+nEsp*0.7, 0712, cValToChar(Transform(nUpmeM,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0944, cValToChar(Transform(nMMes,"@E 999.99"))+"%"	,oTim10N,,0)

oPrinter:Say(nLin+nEsp*0.7, 1212, cValToChar(Transform(nUpmeD,"@E 999,999,999.99"))	,oTim10N,,0)
If nM30 < 0 
	oPrinter:Say(nLin+nEsp*0.7, 1445, cValToChar(Transform(nM30,"@E 99999.99"))+"%"	,oTim10N,,0)
Else
	oPrinter:Say(nLin+nEsp*0.7, 1445, cValToChar(Transform(nM30,"@E 999.99"))+"%"	,oTim10N,,0)
Endif		

oPrinter:Say(nLin+nEsp*0.7, 1715, cValToChar(Transform(nTotPed/nUpmePed,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1945, cValToChar(Transform(nMix,"@E 999.99"))+"%"	,oTim10N,,0)

*/


nLin+=nEsp+50
/*
  oPrinter:Box(nLin,0406,nLin+nEsp,0639)
  oPrinter:Box(nLin,0639,nLin+nEsp,0872)
  oPrinter:Box(nLin,0872,nLin+nEsp,1106)
  oPrinter:Box(nLin,1106,nLin+nEsp,1339)

  oPrinter:Say(nLin+nEsp*0.7,0462,"Tipo"     ,oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,0665,"Potencial",oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,0898,"Trimestre",oTim10N,,0)
  oPrinter:Say(nLin+nEsp*0.7,1115,"Proposta" ,oTim10N,,0)

*/
  oPrinter:Box(nLin,0175,nLin+nEsp,0408)
  oPrinter:Box(nLin,0408,nLin+nEsp,0739)
  oPrinter:Box(nLin,0739,nLin+nEsp,1110)
  oPrinter:Box(nLin,1110,nLin+nEsp,1411)

  oPrinter:Say(nLin+nEsp*0.7,0231,"Tipo"     					,oTim9N,,0)
  oPrinter:Say(nLin+nEsp*0.7,0434,"Potencial em Peças Mês"		,oTim9N,,0)
  oPrinter:Say(nLin+nEsp*0.7,0760,"Vendas em Peças Trimestre"	,oTim9N,,0)
  oPrinter:Say(nLin+nEsp*0.7,1119,"Peças na Proposta" 			,oTim9N,,0)


nLin+=nEsp

//---------------=========||VALIDAÇÕES/ASSINATURAS||===========-----------------//

//nLin+=nEsp*3
oPrinter:Say(nLin-10,1850,SUBSTR(DTOS(ddataBase),7,2),oTim10N, ,0)	
oPrinter:Say(nLin-10,1920,SUBSTR(DTOS(ddataBase),5,2),oTim10N, ,0)	
oPrinter:Say(nLin-10,1990,SUBSTR(DTOS(ddataBase),1,4),oTim10N, ,0)	
oPrinter:Say(nLin,1550,"_____________          ____/____/____ " ,oTim10N, ,0)	
nLin+=nEsp
oPrinter:Say(nLin,1550,"R U B R I C A                   DATA" ,oTim10N, ,0)	
nLin+=nEsp*2
oPrinter:Say(nLin,1550,"Rubens Dias - Auditoria Comercial" ,oTim10N, ,0)	
nLin+=nEsp
oPrinter:Say(nLin,1550,"Digital Serviços de Apoio Administrativo Ltda." ,oTim10N, ,0)	

//nLin+=nEsp*4                                                                                 

nLin := nLin - 200 
//ImpDet(cClix,dDtIni,dDtFim,aPedidos[1])

ImpDet(cClix,dDtIni,dDtFim,aPedidos,aCliente)

fDiscLin()

fDiscL2()

If nLin+800 > 2625
	
	//oPrinter:Line (nLin, 0050,nLin , 2350)
	nLin := 100
	oPrinter:EndPage()
	oPrinter:StartPage()
	oPrinter:Box(0044,0044,3000,2350)		// Margem
	nPag++
/*
	oPrinter:Say(0100,0100,"Pag. "+cValTochar(nPag)		,oTim10N,,0)
	nLin+=nEsp
	oPrinter:Say(0150,0100,"Proposta: "+StrZero(nProp,8),oTim10N,,0)
	nLin+=nEsp
*/
	fImpCab()	
EndIf

//oPrinter:Line (nLin, 0050,nLin , 2350)

nLin+=nEsp
nLin+=nEsp
*'--BOX TABELAS 1 -----------------------------------------------------------------------------------'*
//1ª Box
oPrinter:Say(nLin+nEsp*0.7, 0445, "Informação Geral unidade",oTim10N,,0)
nLin+=nEsp
oPrinter:Box(nLin,0430,nLin+nEsp,2350)
//oPrinter:Box(nLin,0675,nLin+nEsp,1075)
//oPrinter:Box(nLin,1175,nLin+nEsp,1575)
//oPrinter:Box(nLin,1675,nLin+nEsp,2075)

// Horizontal
oPrinter:Say(nLin+nEsp*0.7, 0445, PadC("Venda Tab.",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0945, PadC("Venda G.G.",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1445, PadC("Venda Reg.",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1945, PadC("Geral"     ,35),oTim10N,,0)
nLin+=nEsp

oPrinter:Line(nLin+nEsp,0175,nLin+500,0175)
oPrinter:Line(nLin,0430,nLin+500,0430)
oPrinter:Line(nLin,0680,nLin+500,0680)
oPrinter:Line(nLin-nEsp,0930,nLin+500,0930)
oPrinter:Line(nLin,1180,nLin+500,1180)
oPrinter:Line(nLin-nEsp,1430,nLin+500,1430)
oPrinter:Line(nLin,1680,nLin+500,1680)
oPrinter:Line(nLin-nEsp,1930,nLin+500,1930)
oPrinter:Line(nLin,2180,nLin+500,2180)

oPrinter:Say(nLin+nEsp*0.7, 0445, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0695, "MIX"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0945, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1195, "MIX"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1445, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1695, "MIX"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1945, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2195, "MIX"	,oTim10N,,0)


nLin+=nEsp

// Vertical
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Pulverizado",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(_aVenTab[2,1],"@E 999,999,999.99"))	,oTim10N,,0) // Tabela
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_aVenTab[1,1],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(_aVenGG[2,1] ,"@E 999,999,999.99"))	,oTim10N,,0) // G.G.
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_aVenGG[1,1] ,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(_aVenReg[2,1],"@E 999,999,999.99"))	,oTim10N,,0) // Regional
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_aVenReg[1,1],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(aRetMix[2,1] ,"@E 999,999,999.99"))	,oTim10N,,0) // Geral
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix[1,1] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5
*'---------------------------------------------------------------------------------------------------'*
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Especial"   ,35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(_aVenTab[2,2],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_aVenTab[1,2],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(_aVenGG[2,2] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_aVenGG[1,2],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(_aVenReg[2,2],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_aVenReg[1,2],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(aRetMix[2,2] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix[1,2] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5
*'---------------------------------------------------------------------------------------------------'*
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Super Ver." ,35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(_aVenTab[2,3],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_aVenTab[1,3],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(_aVenGG[2,3] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_aVenGG[1,3],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(_aVenReg[2,3],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_aVenReg[1,3],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(aRetMix[2,3] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix[1,3] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5
*'---------------------------------------------------------------------------------------------------'*
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Comercial"  ,35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(_aVenTab[2,4],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_aVenTab[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(_aVenGG[2,4] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_aVenGG[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(_aVenReg[2,4],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_aVenReg[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(aRetMix[2,4] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix[1,4] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5
*'---------------------------------------------------------------------------------------------------'*
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Industrial" ,35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(0,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(0,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(0,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(0,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(0,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(0,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(0,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(0,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5
*'---------------------------------------------------------------------------------------------------'*
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Geral"      ,35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(_aVenTab[2,4],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_aVenTab[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(_aVenGG[2,4] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_aVenGG[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(_aVenReg[2,4],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_aVenReg[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(aRetMix[2,4] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix[1,4] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5

_nPorcT3 := noround((_aVenTab[2,4] / aRetMix[2,4]) * 100,2)
_nPorcG3 := noround(( _aVenGG[2,4] / aRetMix[2,4]) * 100,2)
_nPorcR3 := noround((_aVenReg[2,4] / aRetMix[2,4]) * 100,2)

If _nPorcT3 <> 0 
	_nPorcT3 := noround(100 - _nPorcG3 - _nPorcR3,2)
Endif	

oPrinter:Line(nLin,0175,nLin,2350)    
oPrinter:Line(nLin,0175,nLin+080,0175)
oPrinter:Line(nLin,0430,nLin+080,0430)
oPrinter:Line(nLin,0930,nLin+080,0930)
oPrinter:Line(nLin,1430,nLin+080,1430)
oPrinter:Line(nLin,1930,nLin+080,1930)
//oPrinter:Line(nLin,2180,nLin+080,2180)

oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Participação",35)    ,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_nPorcT3,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_nPorcG3,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_nPorcR3,"@E 999.99"))+"%"	,oTim10N,,0)
//oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix[1,4] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp      
nLin+=nEsp * 0.5

oPrinter:Line(nLin,0175,nLin,2350)
*'--BOX TABELAS 1 -----------------------------------------------------------------------------------'*

nLin+=nEsp * 2                                                                       


If nLin+800 > 2625
	
	//oPrinter:Line (nLin, 0050,nLin , 2350)
	nLin := 100
	oPrinter:EndPage()
	oPrinter:StartPage()
	oPrinter:Box(0044,0044,3000,2350)		// Margem
	nPag++
/*
	oPrinter:Say(0100,0100,"Pag. "+cValTochar(nPag)		,oTim10N,,0)
	nLin+=nEsp
	oPrinter:Say(0150,0100,"Proposta: "+StrZero(nProp,8),oTim10N,,0)
	nLin+=nEsp
*/
	fImpCab()	
EndIf

*'--BOX TABELAS 2 -----------------------------------------------------------------------------------'*
//1ª Box
oPrinter:Say(nLin+nEsp*0.7, 0445, "Informação por Zona de Venda ["+cXVend+"]",oTim10N,,0)
nLin+=nEsp
oPrinter:Box(nLin,0430,nLin+nEsp,2350)
//oPrinter:Box(nLin,0675,nLin+nEsp,1075)
//oPrinter:Box(nLin,1175,nLin+nEsp,1575)
//oPrinter:Box(nLin,1675,nLin+nEsp,2075)

// Horizontal
oPrinter:Say(nLin+nEsp*0.7, 0445, PadC("Venda Tab.",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0945, PadC("Venda G.G.",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1445, PadC("Venda Reg.",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1945, PadC("Geral"     ,35),oTim10N,,0)
nLin+=nEsp

oPrinter:Line(nLin+nEsp,0175,nLin+500,0175)
oPrinter:Line(nLin,0430,nLin+500,0430)
oPrinter:Line(nLin,0680,nLin+500,0680)
oPrinter:Line(nLin-nEsp,0930,nLin+500,0930)
oPrinter:Line(nLin,1180,nLin+500,1180)
oPrinter:Line(nLin-nEsp,1430,nLin+500,1430)
oPrinter:Line(nLin,1680,nLin+500,1680)
oPrinter:Line(nLin-nEsp,1930,nLin+500,1930)
oPrinter:Line(nLin,2180,nLin+500,2180)

oPrinter:Say(nLin+nEsp*0.7, 0445, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0695, "MIX"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0945, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1195, "MIX"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1445, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1695, "MIX"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1945, "UPME",oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2195, "MIX"	,oTim10N,,0)


nLin+=nEsp

// Vertical
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Pulverizado",35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(_aVenTab2[2,1],"@E 999,999,999.99"))	,oTim10N,,0) // Tabela
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_aVenTab2[1,1],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(_aVenGG2[2,1] ,"@E 999,999,999.99"))	,oTim10N,,0) // G.G.
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_aVenGG2[1,1] ,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(_aVenReg2[2,1],"@E 999,999,999.99"))	,oTim10N,,0) // Regional
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_aVenReg2[1,1],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(aRetMix2[2,1] ,"@E 999,999,999.99"))	,oTim10N,,0) // Geral
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix2[1,1] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5
*'---------------------------------------------------------------------------------------------------'*
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Especial"   ,35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(_aVenTab2[2,2],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_aVenTab2[1,2],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(_aVenGG2[2,2] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_aVenGG2[1,2],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(_aVenReg2[2,2],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_aVenReg2[1,2],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(aRetMix2[2,2] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix2[1,2] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5
*'---------------------------------------------------------------------------------------------------'*
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Super Ver." ,35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(_aVenTab2[2,3],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_aVenTab2[1,3],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(_aVenGG2[2,3] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_aVenGG2[1,3],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(_aVenReg2[2,3],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_aVenReg2[1,3],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(aRetMix2[2,3] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix2[1,3] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5
*'---------------------------------------------------------------------------------------------------'*
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Comercial"  ,35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(_aVenTab2[2,4],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_aVenTab2[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(_aVenGG2[2,4] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_aVenGG2[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(_aVenReg2[2,4],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_aVenReg2[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(aRetMix2[2,4] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix2[1,4] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5
*'---------------------------------------------------------------------------------------------------'*
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Industrial" ,35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(0,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(0,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(0,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(0,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(0,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(0,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(0,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(0,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5
*'---------------------------------------------------------------------------------------------------'*
oPrinter:Line(nLin,0175,nLin,2350)
oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Geral"      ,35),oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0500, cValToChar(Transform(_aVenTab2[2,4],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_aVenTab2[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1000, cValToChar(Transform(_aVenGG2[2,4] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_aVenGG2[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1500, cValToChar(Transform(_aVenReg2[2,4],"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_aVenReg2[1,4],"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2000, cValToChar(Transform(aRetMix2[2,4] ,"@E 999,999,999.99"))	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix2[1,4] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp
nLin+=nEsp * 0.5

_nPorcT3 := noround((_aVenTab2[2,4] / aRetMix2[2,4]) * 100,2)
_nPorcG3 := noround(( _aVenGG2[2,4] / aRetMix2[2,4]) * 100,2)
_nPorcR3 := noround((_aVenReg2[2,4] / aRetMix2[2,4]) * 100,2)

If _nPorcT3 <> 0 
	_nPorcT3 := noround(100 - _nPorcG3 - _nPorcR3,2)
Endif	

oPrinter:Line(nLin,0175,nLin,2350)    
oPrinter:Line(nLin,0175,nLin+080,0175)
oPrinter:Line(nLin,0430,nLin+080,0430)
oPrinter:Line(nLin,0930,nLin+080,0930)
oPrinter:Line(nLin,1430,nLin+080,1430)
oPrinter:Line(nLin,1930,nLin+080,1930)
//oPrinter:Line(nLin,2180,nLin+080,2180)

oPrinter:Say(nLin+nEsp*0.7, 0100, PadC("Participação",35)    ,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 0790, cValToChar(Transform(_nPorcT3,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1290, cValToChar(Transform(_nPorcG3,"@E 999.99"))+"%"	,oTim10N,,0)
oPrinter:Say(nLin+nEsp*0.7, 1790, cValToChar(Transform(_nPorcR3,"@E 999.99"))+"%"	,oTim10N,,0)
//oPrinter:Say(nLin+nEsp*0.7, 2230, cValToChar(Transform(aRetMix[1,4] ,"@E 999.99"))+"%"	,oTim10N,,0)
nLin+=nEsp      
nLin+=nEsp * 0.5
oPrinter:Line(nLin,0175,nLin,2350)

*'--BOX TABELAS 2-------------------------------------------------------------------------------------------------'*

//---------------=========||VALIDAÇÕES/ASSINATURAS||===========-----------------//
oPrinter:Line (nLin, 0225,nLin , 0575)
oPrinter:Line (nLin, 0995,nLin , 1345)
oPrinter:Line (nLin, 1745,nLin , 2070)
nLin += nEsp
oPrinter:Say(nLin, 0295, "SUBGERENTE"	 ,oTim10N,,0)
oPrinter:Say(nLin, 0905, "G. GERAL / DIRETOR COMERCIAL"  ,oTim10N,,0)
oPrinter:Say(nLin, 1765, "GER. COMERCIAL"	 ,oTim10N,,0)

oPrinter:EndPage()
oPrinter:Preview()

Return()

**************************
Static Function fLinha()
**************************

If nLin > 2600
	
	nLin := 150
	oPrinter:EndPage()
	oPrinter:StartPage()
	oPrinter:Box(0044,0044,3000,2350)	// Margem
	nPag++
	fImpCab()	
	
EndIf

Return()

/********************************************************************************************/
/* FUNCAO PARE RETORNARA A MEDIA DE COMPRA TRIMESTRAL, MENSAL E DIARIO DO GRUPO DO CLIENTE  */
/********************************************************************************************/
******************************************
STATIC FUNCTION FPRAZO(CDATA,CCLI,CLOJA)
******************************************

LOCAL CQUERY	:= ""
Local dEmissao	:= ""
Local nX		:= 0
Local dDia		:= CToD('  /  /  ')
Local dTriDe	:= CToD('  /  /  ')
Local dTriAte	:= CToD('  /  /  ')
Local dCurDe	:= CToD('  /  /  ')
Local dCurAte	:= CToD('  /  /  ')
Local dMesDe	:= CToD('  /  /  ')
Local dMesAte	:= CToD('  /  /  ')
Local aRet		:= {}

dDia	:= CDATA

dTriDe	:= FirstDay(dDia)
For nX := 1 To 3
	dTriDe	:= FirstDay(dTriDe - 1)
Next nX
dTriAte	:= FirstDay(dDia) - 1

dCurDe	:= dDia - 30
dCurAte	:= dDia

dMesAte	:= FirstDay(dDia) - 1
dMesDe	:= FirstDay(dMesAte)

cQuery	:= " SELECT SA1.A1_XCODGRU, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dTriDe)+"' AND '"+DToS(dTriAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS TRIM_VL, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dTriDe)+"' AND '"+DToS(dTriAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * "
cQuery	+= "               ((C6_XPRUNIT) * (100 - (C5_XVERREP + C5_XVEREXT) ) / 100))-C6_XFEILOJ) / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS TRIM_MIX, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dTriDe)+"' AND '"+DToS(dTriAte)+"' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS TRIM_CUSTO, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dCurDe)+"' AND '"+DToS(dCurAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS CUR_VL, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dCurDe)+"' AND '"+DToS(dCurAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * "
cQuery	+= "               ((C6_XPRUNIT) * (100 - (C5_XVERREP + C5_XVEREXT)) / 100))-C6_XFEILOJ) / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS CUR_MIX, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dCurDe)+"' AND '"+DToS(dCurAte)+"' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS CUR_CUSTO, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dMesDe)+"' AND '"+DToS(dMesAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS MES_VL, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dMesDe)+"' AND '"+DToS(dMesAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * "
cQuery	+= "               ((C6_XPRUNIT) * (100 - (C5_XVERREP + C5_XVEREXT)) / 100))-C6_XFEILOJ) / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS MES_MIX, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dMesDe)+"' AND '"+DToS(dMesAte)+"' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS MES_CUS, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO = '"+DToS(dDia)+"' AND C5_XOPER <> '05' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS DIA_VL, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO = '"+DToS(dDia)+"' AND C5_XOPER <> '05' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * "
cQuery	+= "               (C6_XPRUNIT * (100 - (C5_XVERREP + C5_XVEREXT)) / 100) / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS DIA_MIX, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO = '"+DToS(dDia)+"' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS DIA_CUSTO "
cQuery	+= "   FROM "+RetSqlName("SC5")+" SC5, "
cQuery	+= "        "+RetSqlName("SC6")+" SC6, "
cQuery	+= "        "+RetSqlName("SA1")+" SA1, "
cQuery	+= "        "+RetSqlName("SA1")+" GRU, "
cQuery	+= "        "+RetSqlName("SM2")+" SM2, "
cQuery	+= "        "+RetSqlName("SD2")+" SD2, "
cQuery	+= "        "+RetSqlName("SZH")+" SZH "
cQuery	+= "  WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SC6.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SD2.D_E_L_E_T_(+) = ' ' "
cQuery	+= "    AND GRU.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SM2.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SZH.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery	+= "    AND C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery	+= "    AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery	+= "    AND SD2.D2_FILIAL(+) = '"+xFilial("SD2")+"' "
cQuery	+= "    AND GRU.A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery	+= "    AND SZH.ZH_FILIAL = '"+xFilial("SZH")+"' "
cQuery	+= "    AND SC5.C5_NUM = C6_NUM "
cQuery	+= "    AND SC5.C5_CLIENTE = GRU.A1_COD "
cQuery	+= "    AND SC5.C5_LOJACLI = GRU.A1_LOJA "
cQuery	+= "    AND GRU.A1_XCODGRU = SA1.A1_XCODGRU "
cQuery	+= "    AND SA1.A1_XCODGRU = '"+POSICIONE("SA1",1,XFILIAL("SA1")+cCli,"A1_XCODGRU")+"' "
cQuery	+= "    AND GRU.A1_COD = SA1.A1_COD "
cQuery	+= "    AND GRU.A1_LOJA = SA1.A1_LOJA "
cQuery	+= "    AND SA1.A1_LOJA = '"+cLoja+"' "
cQuery	+= "    AND D2_PEDIDO(+) = C6_NUM "
cQuery	+= "    AND D2_ITEM(+) = C6_ITEM "
cQuery	+= "    AND D2_COD(+) = C6_PRODUTO "
cQuery	+= "    AND SC5.C5_XOPER IN "
cQuery	+= "        ('01', '04', '05', '10', '11', '14','15', '16', '20', '21', '19', '26', '27', '23') "
cQuery	+= "    AND SC5.C5_XTPSEGM IN ('1', '2', '5', '6') "
cQuery	+= "    AND C5_EMISSAO BETWEEN '"+DToS(dTriDe)+"' AND '"+DToS(dDia)+"' "
cQuery	+= "    AND SC5.C5_XOPERAN <> '99' "
cQuery	+= "    AND SC5.C5_XMOTCAN IN ('98', '  ') "
cQuery	+= "    AND SZH.ZH_CLIENTE = SC5.C5_CLIENTE "
cQuery	+= "    AND SZH.ZH_LOJA = SC5.C5_LOJACLI "
cQuery	+= "    AND SZH.ZH_VEND = SC5.C5_VEND1 "
cQuery	+= "    AND SZH.ZH_SEGMENT = SC5.C5_XTPSEGM "
cQuery	+= "    AND M2_DATA = SC5.C5_EMISSAO "
cQuery	+= "    AND M2_MOEDA5 > 0 "
cQuery	+= "  GROUP BY SA1.A1_XCODGRU "
cQuery	+= "  ORDER BY 1 "

U_ORTQUERY(cQuery, "ORTR020_P")

dbSelectArea("ORTR020_P")

aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)

If !(ORTR020_P->(EOF()))
	nMixTri := U_OR16BCLB(ORTR020_P->TRIM_MIX, ORTR020_P->TRIM_CUSTO)
	nMixCur := U_OR16BCLB(ORTR020_P->CUR_MIX , ORTR020_P->CUR_CUSTO )
	nMixMes := U_OR16BCLB(ORTR020_P->MES_MIX , ORTR020_P->MES_CUS   )
	nMixDia := U_OR16BCLB(ORTR020_P->DIA_MIX , ORTR020_P->DIA_CUSTO )
	
	aRet[01]:= Round(ORTR020_P->TRIM_VL / 3, 2)
	aRet[02]:= Round(ORTR020_P->CUR_VL, 2)'
	aRet[03]:= Round(ORTR020_P->MES_VL, 2)
	aRet[04]:= Round(ORTR020_P->DIA_VL, 2)
	aRet[05]:= nMixTri
	aRet[06]:= nMixCur
	aRet[07]:= nMixMes
	aRet[08]:= nMixDia
	
	nUpmeT :=aRet[01]
	nUpmeD :=aRet[02]
	nUpmeM :=aRet[03]
	nMTri  :=aRet[05]
	nM30   :=aRet[06]
	nMMes  :=aRet[07]
	
	
EndIf

ORTR020_P->(dbCloseArea())
dbSelectArea("SC5")

Return(aRet)

/*/{Protheus.doc} CalcMM

//TODO Função auxiliar para calcular Mix e Markup

@author Peder Munksgaard
@since 21/09/2018
@version 1.0
@return ${return}, ${Retorna valor do Mix ou Markup}
@param _nOpc, , Opçção 1 - Mix, 2 - Markup
@param _nPrc, , Preço de venda
@param _nCus, , Custo do produto
@type function
/*/
User Function CalcMM(_nOpc, _nPrc, _nCus)

Local _nRet := 0

Default _nOpc := 1
Default _nPrc := 1
Default _nCus := 1

If     _nOpc == 1
	
	_nRet := Round(((_nPrc - _nCus) / _nPrc) * 100, 2)
	
Elseif _nOpc == 2
	
	_nRet := Round(_nPrc / _nCus, 2)
	
Else
	
	MsgStop("Opção inválida!","ORTR727")
	
Endif

Return(_nRet)

**********************************
Static Function fPropNum(nOp)
**********************************

Local 	cQry := ""
Local  nProp:= 0
Local ni :=0
If nOp == 1
	
	cQry := "SELECT MAX(PROPOSTA) AS PROPOSTA FROM SIGA.PROPNUM "
	
    If Select("OR727_P") > 0
       OR727_P->(DbCloseArea())
    EndIf
    DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry),"OR727_P", .F., .T.)

	nProp:= OR727_P->PROPOSTA + 1
    OR727_P->(DbCloseArea())

	cQry := "INSERT INTO SIGA.PROPNUM "
	cQry += "(UN, PROPOSTA, STATUS,USRGERA,USRCANC, DTIMP, PEDIDOS, OBS, FILIAL ) "
	cQry += "VALUES ( '"+cEmpAnt+"', "+Str(nProp)+", 1, '"+_cUsu+"', ' ', "
	cQry += "  "+DtoS(dDataBase)+", '"+cPedidos+"', 'COMERCIAL "+"KM: "+Alltrim(MV_PAR02)+" VEND: "+Alltrim(MV_PAR03)+  ;
	" OUTROS: "+Alltrim(MV_PAR09)+" PRAZO: "+Alltrim(MV_PAR10)+" TPPG: "+Alltrim(MV_PAR11)+"', '"+xFilial("SC5")+"' ) "

	TCSQLEXEC(cQry)
	TCSQLEXEC("COMMIT")

	DBSelectArea("SC5")
	DbSetOrder(1)
	
	For nI:= 1 to Len(aPedidos)

		DbSeek(xFilial("SC5")+aPedidos[nI])
		Reclock("SC5",.F.)//cr//
		SC5->C5_XPRONUM := nProp //Transform(nProp,"@E 99999999")//cr//
		MsUnlock()//cr//

	Next nI
	
Else

	cQry := "UPDATE SIGA.PROPNUM "
	cQry += "SET USRGERA = '"+_cUsu+"', DTIMP = '"+DtoS(dDataBase)+"', OBS = 'COMERCIAL "+"KM: "+Alltrim(MV_PAR02)+" VEND: "+Alltrim(MV_PAR03)+  ;
	" OUTROS: "+Alltrim(MV_PAR09)+" PRAZO: "+Alltrim(MV_PAR10)+" TPPG: "+Alltrim(MV_PAR11)+"'  "
	cQry += " WHERE PROPOSTA =   "+Alltrim(Str(SC5->C5_XPRONUM))+ "  "
	cQry +=" AND   FILIAL  	= '"+xFilial("SC5")+"' "
	cQry +=" AND   UN  	= '"+cEmpAnt+"' "
	
	TCSQLEXEC(cQry)
	TCSQLEXEC("COMMIT")

Endif

Return(nProp)

***********************************
Static Function fDiscLin()
***********************************

Local cQuery   := " "
Local nTotMed  := 0
Local nTotQtd  := 0
Local nTotLiq  := 0
Local nTotCusto:= 0
Local nMixLiq  := 0
Local cGrupo   := " "

Local dIniTrim  := DTOS(FirstDate(MonthSub(dDataBase,3)))
Local d2IniTrim := DTOS(FirstDate(MonthSub(dDataBase,6)))
Local dFimTrim  := DTOS(FirstDate(dDataBase)-1)

Local dIniAnt  := DTOS(FirstDate(MonthSub(YearSub(dDataBase,1),3)))
Local d2IniAnt := DTOS(FirstDate(MonthSub(YearSub(dDataBase,1),6)))
Local dFimAnt  := DTOS(FirstDate(YearSub(dDataBase,1))-1)

Local nIdx
Local nIdy
Local nColIni  := 36
Local nRefCol  := nColIni

// MONTAGEM DA TABELA AUXILIAR PARA CLASSIfICACAO DOS CLIENTES EM ESPECIAL ,PULVERIZADO E SUPER VERTICAL
// TcSqlExec("Drop table MIX"+_cUsu+"'")

Droptable("MIX"+_cUsu+"")

cQry := "CREATE TABLE MIX"+_cUsu+" AS "
cQry += "SELECT CLIENTE CLI , ZH_VEND Vendedor , TPCLI, "
cQry += "       SUM(CASE WHEN TPCLI = 'P' THEN TOTPED ELSE 0 End) PULVERIZADO,   "
cQry += "       SUM(CASE WHEN TPCLI = 'E' THEN TOTPED ELSE 0 End) ESPECIAL,      "
cQry += "       SUM(CASE WHEN TPCLI = 'S' THEN TOTPED ELSE 0 End) SUPERVERTICAL, "
cQry += "       SUM(INAT) INATIVOS, "
cQry += "       SUM(ATIV) ATIVOS,   "
cQry += "       SUM(MEDTRI)/3 MEDTRI, "
cQry += "       SUM(PERIODO) PERIODO "
cQry += "    FROM ( SELECT"
//cQry += "           A1_XTPCLI TPCLI, CLIENTE , ZH_VEND , MEDTRI , INAT , ATIV , TOTPED , PERIODO "
//cQry += "  FROM (SELECT A1_COD CLIENTE, A1_XTPCLI, ZH_VEND,"
cQry += "          (CASE WHEN TOTPED < 300 THEN 'P' 
cQry += "                WHEN TOTPED < 500 THEN 'E' 
cQry += "                WHEN TOTPED < 2500 AND A1_XTIPO NOT IN ('1','5') THEN 'E' 
cQry += "                ELSE 'S' END) TPCLI, CLIENTE , ZH_VEND , MEDTRI , INAT , ATIV , TOTPED , PERIODO "
cQry += "  FROM (SELECT A1_COD CLIENTE, ZH_VEND, A.A1_XTIPO, "
cQry += "                SUM(NVALTRI) NVALTRI , SUM(NVALCUR) NVALCUR, SUM(NVALMES) NVALMES , SUM(TOTPED) TOTPED , "
cQry += "                (CASE WHEN A1_ULTCOM <> ' ' AND TO_CHAR(SYSDATE, 'YYYYMMDD') - A1_ULTCOM  > 90 THEN 1 ELSE 0 End) INAT, "
cQry += "                (CASE WHEN A1_ULTCOM <> ' ' AND TO_CHAR(SYSDATE, 'YYYYMMDD') - A1_ULTCOM <= 90 THEN 1 ELSE 0 End) ATIV, "
cQry += "                (CASE WHEN A1_ULTCOM <> ' ' AND TO_DATE(A1_ULTCOM, 'YYYYMMDD') BETWEEN TRUNC(ADD_MONTHS(SYSDATE, -3), 'DD') AND TRUNC(SYSDATE, 'DD') THEN 1 ELSE 0 End) MEDTRI, "
cQry += "                (CASE WHEN A1_ULTCOM <> ' ' AND A1_ULTCOM BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN 1 ELSE 0 End) PERIODO    "
cQry += "           FROM "
//cQry += "                       (SELECT GRU.A1_XCODGRU GRUPO, ZH_VEND, "
cQry += "                       (SELECT GRU.A1_XCODGRU GRUPO, ZH_VEND, GRU.A1_XTIPO, "
cQry += "                              SUM(CASE WHEN OPER <> '05' AND EMISSAO >= '"+DTOS(FirstDate(dDataBase))+"' AND EMISSAO <= '"+DTOS(dDataBase)+"' THEN (((PRUNIT*QTDVEN)*(1-((GUELTA+RESSARC)/100))))/M2_MOEDA5 ELSE 0 End) TOTPED, "
cQry += "                              SUM(CASE WHEN OPER <> '05' AND EMISSAO BETWEEN '"+DTOS(FirstDate(MonthSub(dDataBase,3)))+"' AND '"+DTOS(FirstDate(dDataBase))+"'   "
cQry += "                                            THEN (((QTDVEN * PRUNIT)*(1-((GUELTA+RESSARC)/100))) / M2_MOEDA5 )"
cQry += "                                            ELSE 0 End) / 3 NVALTRI, "
cQry += "                              SUM(CASE WHEN OPER <> '05' AND EMISSAO BETWEEN '"+DTOS(DAYSUB(dDataBase,36))+"' AND '"+DTOS(dDataBase)+"' THEN "
cQry += "                                      ( QTDVEN * (PRUNIT*(1-((GUELTA+RESSARC)/100))) / M2_MOEDA5) "
cQry += "                                     ELSE 0 End) NVALCUR, "
cQry += "                              SUM(CASE WHEN OPER <> '05' AND EMISSAO BETWEEN '"+DTOS(FirstDate(MonthSub(dDataBase,1)))+"' AND '"+DTOS(LastDate(MonthSub(dDataBase,1)))+"' THEN "
cQry += "                                    (QTDVEN * (PRUNIT*(1-((GUELTA+RESSARC)/100))) / M2_MOEDA5) "
cQry += "                                   ELSE 0 End) NVALMES "
cQry += "                          FROM "+RETSQLNAME("SA1")+" SA1, "
cQry += "                               "+RETSQLNAME("SA1")+" GRU, "
cQry += "                               "+RETSQLNAME("SM2")+" SM2, "
cQry += "                               "+RETSQLNAME("SZH")+" SZH, "
cQry += "                               "+RETSQLNAME("SB1")+" SB1, "
cQry += "                               "+RETSQLNAME("SBM")+" SBM, "
cQry += "                               MIX"+CEMPANT+"0 MIX  "
cQry += "                          WHERE CLIENTE = GRU.A1_COD "
cQry += "                           AND GRU.A1_XCODGRU = SA1.A1_XCODGRU "
cQry += "                           AND GRU.A1_COD = SA1.A1_COD "
cQry += "                           AND GRU.A1_LOJA = SA1.A1_LOJA "
cQry += "                           AND ZH_CLIENTE  = CLIENTE "
cQry += "                           AND ZH_SEGMENT  = TPSEGM "
cQry += "                           AND BM_GRUPO    = B1_GRUPO "
cQry += "                           AND B1_COD      = COD      "
cQry += "                           AND B1_GRUPO    = BM_GRUPO "
cQry += "                           AND SA1.D_E_L_E_T_ = ' ' "
cQry += "                           AND Sb1.D_E_L_E_T_ = ' ' "
cQry += "                           AND Sbm.D_E_L_E_T_ = ' ' "
cQry += "                           AND GRU.D_E_L_E_T_ = ' ' "
cQry += "                           AND SM2.D_E_L_E_T_ = ' ' "
cQry += "                           AND SZH.D_E_L_E_T_ = ' ' "
cQry += "                           AND SA1.A1_FILIAL = '"+XFILIAL("SA1")+"'"
cQry += "                           AND GRU.A1_FILIAL = '"+XFILIAL("SA1")+"'"
cQry += "                           AND SZH.ZH_FILIAL = '"+XFILIAL("SZH")+"'"
cQry += "							AND BM_FILIAL = '"+XFILIAL("SBM")+"' "
cQry += "                           AND B1_FILIAL = '"+XFILIAL("SB1")+"' "
cQry += " AND EMISSAO BETWEEN '"+DTOS(FirstDate(MonthSub(dDataBase,3)))+"' "
cQry += " AND '"+DTOS(dDataBase)+"' "
cQry += " AND M2_DATA = EMISSAO "
cQry += " AND SA1.A1_XCODGRU = GRU.A1_XCODGRU "
cQry += " AND SA1.A1_LOJA = '01' "
cQry += " AND OPER IN ('01','05','13','04', '14', '15', '16', '20', '21','26') "
cQry += " AND TPSEGM IN ('2') "
//cQry += " GROUP BY GRU.A1_XCODGRU , ZH_VEND  ) , "+RETSQLNAME("SA1")+" SA1 "
//cQry += " WHERE D_E_L_e_T_= ' ' AND A1_FILIAL ='"+XFILIAL("SA1")+"' AND A1_XCODGRU = GRUPO  group by a1_cod, A1_XTPCLI, A1_ULTCOM , zh_VEND ) )"
cQry += " GROUP BY GRU.A1_XCODGRU , GRU.A1_XTIPO, ZH_VEND  ) A, "+RETSQLNAME("SA1")+" SA1 "
cQry += " WHERE D_E_L_e_T_= ' ' AND A1_FILIAL ='"+XFILIAL("SA1")+"' AND A1_XCODGRU = GRUPO  group by a1_cod, A1_XTPCLI, A1_ULTCOM , zh_VEND, A.A1_XTIPO ) )"
cQry += " GROUP BY CLIENTE,ZH_VEND, TPCLI "
MEMOWRIT("C:\ORTR16B_TABELA1.SQL",cQry)
If TcSqlExec(cQry) < 0
	MsgStop("Erro na seleção dos registros, contate o suporte microsiga!")
	Droptable("MIX"+_cUsu+"")
	Return
EndIf

//---------QRY DESC LIN--------//

cQuery := " SELECT GRUPO, 	"
cQuery += "       BM_XSUBGRU, "
cQuery += "       B1_XMODELO,   "
cQuery += "       (select sum(Z7_QTD) "
cQuery += "          from "+RETSQLNAME("SZ7")+" SZ7, "+RETSQLNAME("SB1")+" SB1, "+RETSQLNAME("SA1")+" SA1 "
cQuery += "         where SZ7.d_e_l_e_t_ = ' '                            "
cQuery += "           and sb1.d_e_l_e_t_ = ' '                            "
cQuery += "           and sa1.d_e_l_e_t_ = ' '                            "
cQuery += "           and z7_filial = '"+xFilial("SZ7")+"'                "
cQuery += "           and b1_filial = '"+xFilial("SB1")+"'                "
cQuery += "           and a1_filial = '"+xFilial("SA1")+"'                "
cQuery += "           and A1_COD = Z7_CLIENTE                             "
cQuery += "           and A1_LOJA = Z7_LOJA                               "
cQuery += "           and A1_XTIPO IN ('2')                               "
cQuery += "           and b1_grupo = grupo                                "
cQuery += "           and z7_cod = b1_cod) CONSIGNADO,                    "
cQuery += "       SUM((QTDVEN * CUSTO) / SM2.M2_MOEDA5) CUSTO,            "
cQuery += "       SUM(((QTDVEN * PRCTAB)) / SM2.M2_MOEDA5) PRCTAB,        "
cQuery += "       SUM(CASE                                                "
cQuery += "             WHEN TPSEGM IN ('1', '5') THEN                    "
cQuery += "              QTDVEN * B1_PESO                                 "
cQuery += "             WHEN TPSEGM NOT IN ('1', '5') AND B1_XMODELO = '000008' THEN "
cQuery += "              QTDVEN * 5                                                  "
cQuery += "             ELSE                                                         "
cQuery += "              QTDVEN                                                      "
cQuery += "           END) QTD,                                                      "
cQuery += "       DECODE(INSTR(BM_DESC, 'CORTE'), 1, SUBSTR(BM_DESC, 6), BM_DESC) BM_DESC, "
cQuery += "       MAX(VERBREP) VERBREP,                                              "
cQuery += "       MAX(GUELTA) GUELTA,                                                "
cQuery += "       MAX(RESSARC) RESSARC,                                              "
cQuery += "       MAX(TPSEGM) tpsegm,                                                "
cQuery += "       SUM(CASE                                                           "
cQuery += "             WHEN OPER <> '05' THEN                                       "
cQuery += "              (QTDVEN * PRUNIT) / SM2.M2_MOEDA5                           "
cQuery += "             ELSE                                                         "
cQuery += "              0                                                           "
cQuery += "           End) VALBRUT,                                                  "
cQuery += "       SUM(CASE                                                           "
cQuery += "             WHEN OPER <> '05' THEN                                       "
cQuery += "              (QTDVEN * PRUNIT * GUELTA / 100) / SM2.M2_MOEDA5            "
cQuery += "             ELSE                                                         "
cQuery += "              0                                                           "
cQuery += "           End) VALGUELTA,                                                "
cQuery += "       SUM(CASE                                                           "
cQuery += "             WHEN OPER <> '05' THEN                                       "
cQuery += "              (QTDVEN * PRUNIT * RESSARC / 100) / SM2.M2_MOEDA5           "
cQuery += "             ELSE                                                         "
cQuery += "              0                                                           "
cQuery += "           End) VALRESSARC,                                               "
cQuery += "       SUM(CASE                                                           "
cQuery += "             WHEN OPER <> '05' THEN                                       "
cQuery += "              (QTDVEN * (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) /    "
cQuery += "              SM2.M2_MOEDA5   "
cQuery += "             ELSE    "
cQuery += "              0       "
cQuery += "           End) VALLIQ,  "
cQuery += "       SUM(CASE    "
cQuery += "             WHEN OPER <> '05' THEN   "
cQuery += "              ((QTDVEN * (PRUNIT * (1 - ((VERBREP + GUELTA + RESSARC) / 100))))) /  "
cQuery += "              SM2.M2_MOEDA5  "
cQuery += "             ELSE            "
cQuery += "              0              "
cQuery += "           End) VALMIX,      "
cQuery += "       SUM(CASE "
cQuery += "             WHEN OPER <> '05' THEN "
cQuery += "              (QTDVEN * (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) /  "
cQuery += "              SM2.M2_MOEDA5 "
cQuery += "             ELSE 0 "
cQuery += "           End) PRUNIT, "
cQuery += "       QTDTOT, PRUNITTOT, PRCTABTOT, PRCIND, PRCCOM, "
cQuery += "       PRCLOJ, CUSTOIND, CUSTOCOM, CUSTOLOJ, BM_XORDMIX, "
cQuery += "       (SELECT MIN(M2_MOEDA5) "
cQuery += "          FROM "+RETSQLNAME("SM2")+" SM2 "
cQuery += "         WHERE D_E_L_E_T_ = ' ' "
cQuery += "           AND M2_DATA = '"+DTOS(FirstDate(dDataBase))+"') AS MOEDANT, "
cQuery += "       (SELECT MAX(M2_MOEDA5) "
cQuery += "          FROM "+RETSQLNAME("SM2")+" SM2 "
cQuery += "         WHERE D_E_L_E_T_ = ' ' "
cQuery += "           AND M2_DATA = '"+DTOS(LastDay(dDataBase))+"') AS MOEDATU, "
cQuery += "       SUM(CASE "
cQuery += "             WHEN OPER <> '05' THEN "
cQuery += "              ((QTDVEN * (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) /  "
cQuery += "              SM2.M2_MOEDA5) * TO_NUMBER(PRZMED)                         "
cQuery += "             ELSE 0 "
cQuery += "           End) PRZMED, "
cQuery += "       SUM(CASE "
cQuery += "             WHEN TPSEGM IN ('1', '5') THEN "
cQuery += "              ((QTDVEN * (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) /  "
cQuery += "              SM2.M2_MOEDA5) * TO_NUMBER(PRZMED) "
cQuery += "             ELSE 0 "
cQuery += "           End) PRZIND, "
cQuery += "       SUM(CASE "
cQuery += "             WHEN TPSEGM IN ('2', '6') THEN "
cQuery += "              ((QTDVEN * (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) /  "
cQuery += "              SM2.M2_MOEDA5) * TO_NUMBER(PRZMED) "
cQuery += "             ELSE 0 "
cQuery += "           End) PRZCOM, "
cQuery += "       SUM(CASE "
cQuery += "             WHEN TPSEGM IN ('3', '4') THEN "
cQuery += "              ((QTDVEN * (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) /  "
cQuery += "              SM2.M2_MOEDA5) * TO_NUMBER(PRZMED) "
cQuery += "             ELSE 0 "
cQuery += "           End) PRZLOJ, "
cQuery += "       max(nvl((select max(cont1)  "
cQuery += "                from tabcad2 "
cQuery += "                where (BM_XSUBGRU NOT LIKE '2000%I' AND "
cQuery += "                      decode(substr(bm_grupo, 1, 1), '8', B1_XMODELO, BM_XSUBGRU) = CHAVE)"
cQuery += "                   OR (((BM_XSUBGRU IN ('20001I', '20002I', '20009I') AND "
cQuery += "                      B1_XMODELO = '000011') OR "
cQuery += "                      (BM_XSUBGRU = '20007I' AND B1_XMODELO = '000013') OR "
cQuery += "                      (BM_XSUBGRU LIKE '2000%I' AND "
cQuery += "                      B1_XMODELO IN ('000008', '000009', '000010', '000018'))) AND "
cQuery += "                      decode(B1_XMODELO, '000011', BM_XSUBGRU, B1_XMODELO) = "
cQuery += "                      CHAVE)), "
cQuery += "               '   SEM GRUPO')) QUEBRA, "
cQuery += "       NVL((SELECT SUM(CASE "
cQuery += "                        WHEN TPSEGM IN ('1', '5') THEN "
cQuery += "                         QTDVEN * B1_PESO "
cQuery += "                        WHEN TPSEGM NOT IN ('1', '5') AND B1_XMODELO = '000008' THEN "
cQuery += "                         QTDVEN * 5 "
cQuery += "                        ELSE "
cQuery += "                         QTDVEN "
cQuery += "                      END) / 3 MEDATU "
cQuery += "             FROM SIGA.MIX" + cEmpAnt + "0 ATU, "+RETSQLNAME("SB1")+" SB11 "
cQuery += " WHERE MIX.GRUPO = ATU.GRUPO  "
cQuery += "              AND SB11.D_E_L_E_T_ = ' ' "
cQuery += "              AND SB11.B1_FILIAL = '"+XFILIAL("SB1")+"' "
cQuery += "              AND SB11.B1_COD = ATU.COD "
cQuery += "              AND ATU.TPSEGM IN ('2')   "
cQuery += "              AND ATU.OPER IN ('01', '04', '05', '10', '11', '14', '15', '16', '20', '21', '19', '26', '27') "
cQuery += "              AND EMISSAO BETWEEN '"+dIniTrim+"' AND '"+dFimTrim+"'), 0) MEDATU, "
cQuery += "       NVL((SELECT SUM(CASE "
cQuery += "                        WHEN TPSEGM IN ('1', '5') THEN "
cQuery += "                         QTDVEN * B1_PESO "
cQuery += "                        WHEN TPSEGM NOT IN ('1', '5') AND B1_XMODELO = '000008' THEN "
cQuery += "                         QTDVEN * 5 "
cQuery += "                        ELSE QTDVEN "
cQuery += "                      END) / 3 MEDANT "
cQuery += "             FROM SIGA.MIX"+cEmpAnt+"0 ANT, "+RetSqlName("SB1")+" SB12 "
cQuery += "            WHERE MIX.GRUPO = ANT.GRUPO  "
cQuery += "              AND SB12.D_E_L_E_T_ = ' '  "
cQuery += "              AND SB12.B1_FILIAL = '"+XFILIAL("SB1")+"'  "
cQuery += "              AND SB12.B1_COD = ANT.COD  "
cQuery += "              AND ANT.TPSEGM IN ('2')    "
cQuery += "              AND ANT.OPER in ('01', '04', '05', '10', '11', '14', '15', '16', '20', '21', '19', '26', '27') "
cQuery += "              AND EMISSAO BETWEEN '"+dIniTrim+"' AND '"+dFimTrim+"'), 0) MEDANT "
cQuery += "  FROM SIGA.MIX"+cEmpAnt+"0 MIX, "+RetSqlName("SB1")+" SB1, "
cQuery += "       "+RetSqlName("SBM")+" SBM, "+RetSqlName("SM2")+" SM2, "+RetSqlName("SA3")+" SA3, "
cQuery += "       (SELECT A1_COD, "
cQuery += "               A1_EST, "
cQuery += "               SA1.R_E_C_N_O_ REC,"
cQuery += "               MAX(ZH_VERBREP) ZH_VERBREP "
cQuery += "          FROM "+RetSqlName("SA1")+" SA1, "+RetSqlName("SZH")+" SZH "
cQuery += "         WHERE SA1.D_E_L_E_T_ = ' ' "
cQuery += "           AND SZH.D_E_L_E_T_ = ' ' "
cQuery += "           AND A1_FILIAL = '"+XFILIAL("SA1")+"' "
cQuery += "           AND ZH_FILIAL = '"+XFILIAL("SZH")+"' "
cQuery += "           AND A1_COD = ZH_CLIENTE "
cQuery += "           AND A1_LOJA = ZH_LOJA   "
cQuery += "           AND ZH_SEGMENT IN ('2') "
cQuery += "         GROUP BY A1_COD, A1_EST, SA1.R_E_C_N_O_) SA1, "
cQuery += "       (SELECT SUM(CASE "
cQuery += "                     WHEN TPSEGM IN ('1', '5') THEN "
cQuery += "                      QTDVEN * B1_PESO "
cQuery += "                     WHEN TPSEGM NOT IN ('1', '5') AND B1_XMODELO = '000008' THEN"
cQuery += "                      QTDVEN * 5 "
cQuery += "                     ELSE "
cQuery += "                      QTDVEN "
cQuery += "                   END) QTDTOT, "
cQuery += "               SUM(CASE "
cQuery += "                     WHEN OPER <> '05' THEN "
cQuery += "                      ((QTDVEN * (PRUNIT * (1 - ((GUELTA + RESSARC) / 100))))) / "
cQuery += "                      M2_MOEDA5 "
cQuery += "                     ELSE 0 "
cQuery += "                   End) PRUNITTOT, "
cQuery += "               SUM(CASE "
cQuery += "                     WHEN OPER <> '05' AND TPSEGM IN ('1', '5') THEN "
cQuery += "                      (QTDVEN * (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) / "
cQuery += "                      M2_MOEDA5 "
cQuery += "                     ELSE 0 "
cQuery += "                   End) PRCIND, "
cQuery += "               SUM(CASE "
cQuery += "                     WHEN TPSEGM IN ('1', '5') THEN "
cQuery += "                      (QTDVEN * CUSTO) / M2_MOEDA5 "
cQuery += "                     ELSE  0 "
cQuery += "                   End) CUSTOIND, "
cQuery += "               SUM(CASE "
cQuery += "                     WHEN OPER <> '05' AND TPSEGM IN ('2', '6') THEN "
cQuery += "                      (QTDVEN * (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) / "
cQuery += "                      M2_MOEDA5 "
cQuery += "                     ELSE   0  "
cQuery += "                   End) PRCCOM, "
cQuery += "               SUM(CASE "
cQuery += "                     WHEN TPSEGM IN ('2', '6') THEN  "
cQuery += "                      (QTDVEN * CUSTO) / M2_MOEDA5  "
cQuery += "                     ELSE   0  "
cQuery += "                   End) CUSTOCOM,"
cQuery += "               SUM(CASE "
cQuery += "                     WHEN OPER <> '05' AND TPSEGM IN ('3', '4') THEN "
cQuery += "                      ((QTDVEN * (PRUNIT * (1 - ((GUELTA + RESSARC) / 100))))) / "
cQuery += "                      M2_MOEDA5 "
cQuery += "                     ELSE       "
cQuery += "                      0         "
cQuery += "                   End) PRCLOJ, "
cQuery += "               SUM(CASE         "
cQuery += "                     WHEN TPSEGM IN ('3', '4') THEN "
cQuery += "                      (QTDVEN * CUSTO) / M2_MOEDA5  "
cQuery += "                     ELSE "
cQuery += "                      0   "
cQuery += "                   End) CUSTOLOJ, "
cQuery += "               SUM(CASE           "
cQuery += "                     WHEN OPER <> '05' THEN "
cQuery += "                      (QTDVEN * PRCTAB) / M2_MOEDA5 "
cQuery += "                     ELSE "
cQuery += "                      0   "
cQuery += "                   End) PRCTABTOT "
cQuery += "          FROM MIX"+CEMPANT+"0  MIX,   "
cQuery += "               "+RetSqlName("SM2")+" SM2,   "
cQuery += "               "+RetSqlName("SBM")+" SBM,   "
cQuery += "               "+RetSqlName("SB1")+" SB1,   "
cQuery += "               "+RetSqlName("SA3")+" SA3,   "
cQuery += "               (SELECT A1_COD,    "
cQuery += "                       A1_EST,    "
cQuery += "                       SA1.R_E_C_N_O_ REC, "
cQuery += "                       MAX(ZH_VERBREP) ZH_VERBREP "
cQuery += "                  FROM "+RetSqlName("SA1")+" SA1, "+RetSqlName("SZH")+" SZH "
cQuery += "                 WHERE SA1.D_E_L_E_T_ = ' ' "
cQuery += "                   AND SZH.D_E_L_E_T_ = ' ' "
cQuery += "                   AND A1_FILIAL = '"+XFILIAL("SA1")+"'     "
cQuery += "                   AND ZH_FILIAL = '"+XFILIAL("SZH")+"'     "
cQuery += "                   AND A1_COD = ZH_CLIENTE  "
cQuery += "                   AND A1_LOJA = ZH_LOJA    "
cQuery += "                   AND ZH_SEGMENT IN ('2')  "
cQuery += "                 GROUP BY A1_COD, A1_EST, SA1.R_E_C_N_O_) SA1 "
cQuery += "         WHERE M2_DATA = TO_CHAR(SYSDATE, 'YYYYMMDD')         "
cQuery += "           AND SM2.D_E_L_E_T_ = ' ' "
cQuery += "           AND SBM.D_E_L_E_T_ = ' ' "
cQuery += "           AND BM_FILIAL = '"+XFILIAL("SBM")+"'     "
cQuery += "           AND BM_GRUPO = B1_GRUPO  "
cQuery += "           AND B1_COD = COD "
cQuery += "           AND A1_COD = CLIENTE        "
cQuery += "           AND A3_COD = VEND           "
cQuery += "           AND SA3.D_E_L_E_T_ = ' '    "
cQuery += "           AND A3_FILIAL = '"+XFILIAL("SA3")+"' "
cQuery += "           AND EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(LastDay(dDataBase))+"' "
cQuery += "           AND BM_XSUBGRU NOT IN "
cQuery += "               ('20007I', '20008I', '10007O', '10008O', '10007M') "
cQuery += "           AND BM_XSUBGRU <> ' ' "
cQuery += "           AND TPSEGM IN ('2')   "
cQuery += "           AND OPER in           "
cQuery += "               ('01', '04', '05', '10', '11', '15', '16', '20', '21', '19', '26', '27')) TOT "
cQuery += " WHERE B1_COD = COD            "
cQuery += "   AND BM_GRUPO = B1_GRUPO     "
cQuery += "   AND A1_COD = CLIENTE        "
cQuery += "   AND VEND = A3_COD           "
cQuery += "   AND SB1.D_E_L_E_T_ = ' '    "
cQuery += "   AND SBM.D_E_L_E_T_ = ' '    "
cQuery += "   AND SM2.D_E_L_E_T_ = ' '    "
cQuery += "   AND SA3.D_E_L_E_T_ = ' '    "
cQuery += "   AND SM2.M2_DATA = EMISSAO   "
cQuery += "   AND B1_FILIAL = '"+XFILIAL("SB1")+"' "
cQuery += "   AND BM_FILIAL = '"+XFILIAL("SBM")+"' "
cQuery += "   AND A3_FILIAL = '"+XFILIAL("SA3")+"' "
cQuery += "   AND EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(LastDay(dDataBase))+"' "
cQuery += "   AND BM_XSUBGRU NOT IN ('20007I', '20008I', '10007O', '10008O', '10007M')"
cQuery += "   AND OPER in "                                          "
cQuery += "       ('01', '04', '05', '10', '11', '15', '16', '20', '21', '19', '26', '27')"
cQuery += "   AND TPSEGM IN ('2') "
cQuery += " GROUP BY GRUPO,       "
cQuery += "          PRUNITTOT,   "
cQuery += "          QTDTOT,      "
cQuery += "          BM_XSUBGRU,  "
cQuery += "          B1_XMODELO,  "
cQuery += "          PRCTABTOT,   "
cQuery += "          PRCIND,      "
cQuery += "          PRCCOM,      "
cQuery += "          PRCLOJ,      "
cQuery += "          CUSTOIND,    "
cQuery += "          CUSTOCOM,    "
cQuery += "          CUSTOLOJ,    "
cQuery += "          BM_DESC,     "
cQuery += "          BM_XORDMIX   "
cQuery += " ORDER BY quebra, BM_XORDMIX, BM_DESC "

MEMOWRIT("C:\MIXPROP.SQL",cQuery)

If Select("Lin") > 0
	dbSelectArea("Lin")
	dbCloseArea()
EndIf
TcQuery cQuery Alias "Lin" New

DBSELECTAREA("Lin")
If LIN->(EOF())
	DBSELECTAREA("LIN")
	DBClOSEAREA()

	Aadd(aRetMix, { 0, 0, 0, 0 })
	Aadd(aRetMix, { 0, 0, 0, 0 })
	Aadd(aRetMix, { 0, 0, 0, 0 })

	Aadd(aRetMix2, { 0, 0, 0, 0 })
	Aadd(aRetMix2, { 0, 0, 0, 0 })
	Aadd(aRetMix2, { 0, 0, 0, 0 })

	Return
EndIf

cQuebra := SUBSTR(LIN->QUEBRA,4)
nTrim := 0
nTrimAnt := 0
nTotCota := 0
nTotCusto:= 0
nTotTab := 0
nTotLiq := 0
nTotPrz := 0
nTotLb  := 0
nTotVerbRep:= 0
nTotInd := 0
nTotCom := 0
nTotLoj := 0
nTPrz  := 0
nTCusto:= 0
nTCota  := 0
nValLiq := 0
nTGuelta:= 0
nSubT1 := 0
nSubT2 := 0
nSubT3 := 0
nSubT4 := 0
nSubT5 := 0
nSubT6 := 0
nSubT7 := 0
nSubT8 := 0
nSubT9 := 0
nSubTA := 0
nTGer1 := 0
nTGer2 := 0
nTGer3 := 0
nTGer4 := 0
nTGer5 := 0
nTGer6 := 0
nTGer7 := 0
nTGer8 := 0
nTGerA := 0
nTGer9 := 0

nDescFin:= (((LIN->PRCTABTOT - LIN->PRUNITTOT) / LIN->PRCTABTOT) * 100)
nDefMes := (((1 - (LIN->MOEDANT / LIN->MOEDATU)) / 12) * 100)
nPrzInd := LIN->PRZIND
nPrzCom := LIN->PRZCOM
nPrzLoj := LIN->PRZLOJ
nTotal  := LIN->PRUNITTOT

// Totais de vEnda e custo para calculos de deflacao
nValCom := LIN->PRCCOM
nValInd := LIN->PRCIND
nValLoja:= LIN->PRCLOJ
nCtCom := LIN->CUSTOCOM
nCtLoja:= LIN->CUSTOLOJ
nCtInd := LIN->CUSTOIND
nTotMix:= 0
nValMix:= 0
nQtdIt := 0
nQtdGIt:= 0

While !LIN->(Eof())
	lQuebra := .F.
	nQtdIt++
	
	nTGuelta += LIN->VALGUELTA
	// Acumuladores SUB-TOTAIS
	nSubT1 += LIN->QTD
	nSubT2 += (LIN->PRZMED / LIN->VALLIQ)
	nSubT3 += ((LIN->QTD / LIN->QTDTOT) * 100)
	nSubT4 += ((LIN->VALLIQ / LIN->PRUNITTOT) * 100)
	nSubT5 += LIN->VALBRUT
	nSubT6 += LIN->PRCTAB
	nSubT7 += LIN->VALLIQ
	nSubT8 += LIN->CUSTO
	nSubTA += LIN->VALMIX
	
	/// GLM: George: 10/09/2012
	nSubT9 += Iif(LIN->VERBREP>0,(LIN->VERBREP/LIN->VALLIQ)*100,0)
	///nSubT9 += 0
	
	// Acumuladores
	nValLiq += LIN->VALLIQ
	nTCota += LIN->QTD
	nTPrz += LIN->PRZMED
	nTCusto += LIN->CUSTO
	nValMix += LIN->VALMIX
	
	// Acumuladores Gerais
	nTotPrz += LIN->PRZMED
	nTotMix += LIN->VALMIX
	nTotLiq += LIN->VALLIQ
	nTotCusto += LIN->CUSTO
	nTotTab += LIN->PRCTAB
	
	// Acumuladores de prazo medio
	nPrzInd += LIN->PRZIND
	nPrzCom += LIN->PRZCOM
	nPrzLoj += LIN->PRZLOJ
	
	// Acumuladores por segmento
	If LIN->PRZIND > 0
		nTotInd++
	EndIf  2
	If LIN->PRZCOM > 0
		nTotInd++
	EndIf
	If LIN->PRZLOJ > 0
		nTotInd++
	EndIf
	
	LIN->(Dbskip())
	
	If cQuebra <> SubStr(LIN->QUEBRA,4)
		lQuebra := .T.
		nQtdGIt++
		
		// Acumuladores TOTAIS GERAIS
		nTGer1 += nSubT1
		nTGer2 += (nSubT2 / nQtdIt)
		nTGer3 += nSubT3
		nTGer4 += nSubT4
		nTGer5 += nSubT5
		nTGer6 += nSubT6
		nTGer7 += nSubT7
		nTGer8 += nSubT8
		nTGerA += nSubTA
		nTGer9 += nSubT9
		
		// Acumuladores
		nValLiq:= 0
		nTCota := 0
		nTPrz  := 0
		nTCusto:= 0
		nValMix:= 0
		nSubT1 := 0
		nSubT2 := 0
		nSubT3 := 0
		nSubT4 := 0
		nSubT5 := 0
		nSubT6 := 0
		nSubT7 := 0
		nSubT8 := 0
		nSubTA := 0
		nQtdIt := 0
		
		cQuebra:= SUBSTR(LIN->QUEBRA,4)
		
	EndIf
	
End

// Calculos de Deflacao
nPrzMed := NoRound((nTotPrz / nTotLiq), 0)
nDefPrz := NoRound(((nDefMes / 30) * nPrzMed), 2)
nValDef := NoRound(((100 - nDefPrz) / 100) * NoRound(nTotLiq, 2), 2)
nValMix := NoRound(((100 - nDefPrz) / 100) * NoRound(nTotMix, 2), 2)

nMixLiq	:= U_OR16BCLB(nValMix, nTotCusto)

nTot  := (((nTotLiq / nTotCusto) * 100) - 100)
nTot2 := (nTotMix / nTotCusto)
nTot3 := (nTotTab / nTotCusto)

DbSelectArea("LIN")
DbCloseArea()

*'---------------------------------------------------------------------------------------------------------'*
// Variaveis para Totalizacao dos clientes quanto a pulv. , especial e s. vertical - Tabela 1              
*'---------------------------------------------------------------------------------------------------------'*
nTotCli := 0
nTotEsp := 0
nTotPul := 0
nTotSup := 0
nTotAtiv := 0
nTotInat := 0
aEsp := {0, 0, 0, 0, 0, 0}
aSup := {0, 0, 0, 0, 0, 0}
aPul := {0, 0, 0, 0, 0, 0}

cQuery := " SELECT TPCLI,                                                                    "
cQuery += "       SUM(CASE                                                                   "
cQuery += "             WHEN TPCLI = 'P' THEN                                                "
cQuery += "              GERAL                                                               "
cQuery += "             ELSE                                                                 "
cQuery += "              0                                                                   "
cQuery += "           End) PULVERIZADO,                                                      "
cQuery += "       SUM(CASE                                                                   "
cQuery += "             WHEN TPCLI = 'E' THEN                                                "
cQuery += "              GERAL                                                               "
cQuery += "             ELSE                                                                 "
cQuery += "              0                                                                   "
cQuery += "           End) ESPECIAL,                                                         "
cQuery += "       SUM(CASE                                                                   "
cQuery += "             WHEN TPCLI = 'S' THEN                                                "
cQuery += "              GERAL                                                               "
cQuery += "             ELSE                                                                 "
cQuery += "              0                                                                   "
cQuery += "           End) SUPERVERTICAL,                                                    "
cQuery += "       SUM(case                                                                   "
cQuery += "             when CLASCLI = 1 then                                                "
cQuery += "              1                                                                   "
cQuery += "             else                                                                 "
cQuery += "              0                                                                   "
cQuery += "           End) ATIVOS,                                                           "
cQuery += "       SUM(case                                                                   "
cQuery += "             when CLASCLI = 0 then                                                "
cQuery += "              1                                                                   "
cQuery += "             else                                                                 "
cQuery += "              0                                                                   "
cQuery += "           End) INATIVOS,                                                         "
cQuery += "       SUM(MEDTRI) / 3 MEDTRI,                                                    "
cQuery += "       SUM(PERIODO) PERIODO,                                                      "
cQuery += "       SUM(CUSTO) CUSTO,                                                          "
cQuery += "       SUM(GERAL) VEndAS,                                                         "
cQuery += "       SUM(VEndAMIX) VEndAMIX,                                                    "
cQuery += "       SUM(PRZ) PRZ                                                               "
cQuery += "  FROM (SELECT (CASE                                                              "
cQuery += "                 WHEN TPCLI IS NULL THEN                                          "
cQuery += "                  'P'                                                             "
cQuery += "                ELSE                                                             "
cQuery += "                  TPCLI                                                           "
cQuery += "               End) TPCLI,                                                        "
cQuery += "               ZH_CLIENTE,                                                        "
cQuery += "               (CASE                                                              "
cQuery += "                 WHEN ULTCOM <> ' ' AND ('"+DtoS(dDataBase)+"' - ULTCOM) <= 90 THEN            "
cQuery += "                  1                                                               "
cQuery += "                 ELSE                                                             "
cQuery += "                  0                                                               "
cQuery += "               End) CLASCLI,                                                      "
cQuery += "               (CASE                                                              "
cQuery += "                 WHEN ULTCOM <> ' ' AND                                           "
cQuery += "                      ULTCOM BETWEEN                                              "
cQuery += "                      TO_CHAR(TRUNC(ADD_MONTHS(SYSDATE, -3), 'DD'),               "
cQuery += "                              'YYYYMMDD') AND                                     "
cQuery += "                      TO_CHAR(TRUNC(SYSDATE, 'DD'), 'YYYYMMDD') THEN              "
cQuery += "                  1                                                               "
cQuery += "                 ELSE                                                             "
cQuery += "                  0                                                               "
cQuery += "               End) MEDTRI,                                                       "
cQuery += "               (CASE                                                              "
cQuery += "                 WHEN ULTCOM BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN "
cQuery += "                  1                                                               "
cQuery += "                 ELSE                                                             "
cQuery += "                  0                                                               "
cQuery += "               End) PERIODO,                                                      "
cQuery += "               PRZ,                                                               "
cQuery += "               CUSTO,                                                             "
cQuery += "               GERAL,                                                             "
cQuery += "               VEndAMIX                                                           "
cQuery += "          FROM (SELECT MAX(EMISSAO) ULTCOM,                                       "
cQuery += "                       ZH_CLIENTE,                                                "
cQuery += "                       SUM(CASE                                                   "
cQuery += "                        WHEN OPER <> '05' AND EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN"
cQuery += "                              (QTDVEN *                                           "
cQuery += "                              (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) /      "
cQuery += "                              M2_MOEDA5                                           "
cQuery += "                        ELSE                                                 "
cQuery += "                              0                                                   "
cQuery += "                           End) GERAL,                                            "
cQuery += "                       SUM(CASE                                                   "
cQuery += "                             WHEN OPER <> '05' AND EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN "
cQuery += "                              ((QTDVEN * PRUNIT) *                                "
cQuery += "                              (1 - ((VERBREP + GUELTA + RESSARC) / 100))) /       "
cQuery += "                              M2_MOEDA5                                           "
cQuery += "                             ELSE                                                 "
cQuery += "                              0                                                   "
cQuery += "                           End) VEndAMIX,                                         "
cQuery += "                       SUM(CASE                                                   "
cQuery += "                             WHEN EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN  "
cQuery += "                              (QTDVEN * CUSTO) / M2_MOEDA5                        "
cQuery += "                             ELSE                                                 "
cQuery += "                              0                                                   "
cQuery += "                           End) CUSTO,                                            "
cQuery += "                       SUM(CASE                                                   "
cQuery += "                             WHEN OPER <> '05' AND EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN "
cQuery += "                              ((QTDVEN *                                       "
cQuery += "                              (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) /   "
cQuery += "                              SM2.M2_MOEDA5) * TO_NUMBER(PRZMED)               "
cQuery += "                             ELSE                                              "
cQuery += "                              0                                                "
cQuery += "                           End) PRZ,                                           "
cQuery += "                       TPCLI                                                   "
cQuery += "                  FROM (SELECT *                                               "
cQuery += "                          FROM MIX"+CEMPANT+"0  MIX, "+RetSqlName("SB1")+" SB1, "+RetSqlName("SBM")+" SBM              "
cQuery += "                         WHERE SBM.D_E_L_E_T_ = ' '                            "
cQuery += "                           AND SB1.D_E_L_E_T_ = ' '                            "
cQuery += "                           AND SBM.BM_FILIAL = '"+XFILIAL("SBM")+"'            "
cQuery += "                           AND SB1.B1_FILIAL = '"+XFILIAL("SB1")+"'            "
cQuery += "                           AND B1_COD = COD                                    "
cQuery += "                           AND B1_GRUPO = BM_GRUPO                             "
cQuery += "                           AND BM_XSUBGRU NOT IN ('20007I', '20008I', '10007O',"
cQuery += "                                '10008O', '10007M')) MIX,                     "
cQuery += "                       MIX"+_cUsu+" M,                                           "
cQuery += "                       "+RetSqlName("SM2")+" SM2,                             "
cQuery += "                       (SELECT ZH_VEnd,                                       "
cQuery += "                               ZH_ITINER,                                     "
cQuery += "                               A1_COD ZH_CLIENTE,                             "
cQuery += "                               ZH_SEGMENT,                                    "
cQuery += "                               MAX(ZH_VERBREP) ZH_VERBREP                     "
cQuery += "                          FROM "+RetSqlName("SZH")+" SZH, "+RetSqlName("SA3")+" SA3, "+RetSqlName("SA1")+" SA1 "
cQuery += "                         WHERE SZH.D_E_L_E_T_ = ' '                           "
cQuery += "                           AND SA1.D_E_L_E_T_ = ' '                           "
cQuery += "                           AND SA3.D_E_L_E_T_ = ' '                           "
cQuery += "                           AND SZH.ZH_FILIAL = '"+XFILIAL("SZH")+"'           "
cQuery += "                           AND SA1.A1_FILIAL = '"+XFILIAL("SA1")+"'           "
cQuery += "                           AND SA3.A3_FILIAL = '"+XFILIAL("SA3")+"'           "
cQuery += "                           AND SZH.ZH_CLIENTE = SA1.A1_COD                    "
cQuery += "                           AND SZH.ZH_LOJA = SA1.A1_LOJA                      "
cQuery += "                           AND SZH.ZH_VEND = SA3.A3_COD                       "
cQuery += "                           AND SZH.ZH_MSBLQL <> '1'                           "
cQuery += "                           AND ZH_SEGMENT IN ('2')                            "
cQuery += "                         GROUP BY ZH_VEnd, ZH_ITINER, A1_COD, ZH_SEGMENT) SA1 "
cQuery += "                 WHERE M.CLI(+) = ZH_CLIENTE                        "
cQuery += "                   AND M.Vendedor(+) = ZH_VEND                      "
cQuery += "                   AND SM2.D_E_L_E_T_ = ' '                         "
cQuery += "                   AND M2_DATA = EMISSAO                            "
cQuery += "                   AND ZH_SEGMENT IN ('2')                          "
cQuery += "                   AND OPER(+) IN ('01', '04',  '05', '10',   '11', "
cQuery += "                                   '14',                            "
cQuery += "                                   '15',                            "
cQuery += "                                   '16',                            "
cQuery += "                                   '20',                            "
cQuery += "                                   '21',                            "
cQuery += "                                   '19',                            "
cQuery += "                                   '26',                            "
cQuery += "                                   '27')                            "
cQuery += "                   AND EMISSAO(+) BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' "
cQuery += "                   AND ZH_CLIENTE = CLIENTE(+)                      "
cQuery += "                   AND ZH_SEGMENT = TPSEGM(+)                       "
cQuery += "                   AND ZH_VEND = VEnd(+)                            "
cQuery += "                 GROUP BY ZH_VEnd, TPCLI, ZH_CLIENTE))              "
cQuery += " GROUP BY TPCLI                                                     "

MEMOWRIT("C:\QRY\MIXPRO_CLI_1.SQL", cQuery)

If Select("CLI") > 0
	dbSelectArea("CLI")
	dbCloseArea()
EndIf
TcQuery cQuery Alias "CLI" New

DBSELECTAREA("CLI")

CLI->(dbGoTop())
If !CLI->(EOF())
	
	WHILE !CLI->(EOF())
		
		If ALLTRIM(CLI->TPCLI) == 'S'
			ASUP[1]:= CLI->MEDTRI
			ASUP[2]:= CLI->PERIODO
			ASUP[3]:= noRound(CLI->VEndAS,2)
			nMark  := noRound(CLI->VEndAMIX/CLI->CUSTO,2)
			ASUP[4]:= noRound(((nMark-1)/nMark)*100,2)
			ASUP[5]:= noRound( CLI->PRZ/CLI->VEndAS,0)
			ASUP[6]:= CLI->CUSTO
		elseIf ALLTRIM(CLI->TPCLI) =='P'
			APUL[1]:= CLI->MEDTRI
			APUL[2]:= CLI->PERIODO
			APUL[3]:= noRound(CLI->VEndAS,2)
			nMark  := noRound(CLI->VEndAMIX/CLI->CUSTO,2)
			APUL[4]:= noRound(((nMark-1)/nMark)*100,2)
			APUL[5]:= noRound( CLI->PRZ/CLI->VEndAS,0)
			APUL[6]:= CLI->CUSTO
		elseIf ALLTRIM(CLI->TPCLI) == 'E'
			AESP[1]:= CLI->MEDTRI
			AESP[2]:= CLI->PERIODO
			AESP[3]:= noRound(CLI->VEndAS,2)
			nMark  := noRound(CLI->VEndAMIX/CLI->CUSTO,2)
			AESP[4]:= noRound(((nMark-1)/nMark)*100,2)
			AESP[5]:= noRound(CLI->PRZ/CLI->VEndAS,0)
			AESP[6]:= CLI->CUSTO
		EndIf
		CLI->(DBSKIP())
	End
	
	// calculo de deflacao para o segmento comercial
	nDef    := noRound((nDefMes  / 30) * noRound(nPrzCom/nValCom,2),2)
	nDefVal := noRound(((100-nDef)/100) * noRound(nValCom,2),2)
	nDefCt  := noRound(((100-nDef)/100) * noRound(nCtCom,2),2)
	nMark   := noRound(nValCom/nCtCom,2)
	nRetCom := noRound(((nMark-1)/nMark)*100,2)
	nMark   := noRound(nDefVal/nDefCt,2)
	nRetDef := noRound(((nMark-1)/nMark)*100,2)
	
	Aadd(aRetMix, { APUL[4], AESP[4], ASUP[4], nMixLiq })
	Aadd(aRetMix, { APUL[3], AESP[3], ASUP[3], (APUL[3]+AESP[3]+ASUP[3]) })
	Aadd(aRetMix, { APUL[6], AESP[6], ASUP[6], (APUL[6]+AESP[6]+ASUP[6]) })
	
	dbSelectArea("CLI")
	dbCloseArea()
Else
	Aadd(aRetMix, { 0, 0, 0, 0 })
	Aadd(aRetMix, { 0, 0, 0, 0 })
	Aadd(aRetMix, { 0, 0, 0, 0 })
Endif

*'---------------------------------------------------------------------------------------------------------'*
// Variaveis para Totalizacao dos clientes (ZONA)  quanto a pulv. , especial e s. vertical - Tabela 2               
*'---------------------------------------------------------------------------------------------------------'*
nTotCli := 0
nTotEsp := 0
nTotPul := 0
nTotSup := 0
nTotAtiv := 0
nTotInat := 0
aEsp := {0, 0, 0, 0, 0, 0}
aSup := {0, 0, 0, 0, 0, 0}
aPul := {0, 0, 0, 0, 0, 0}

cQuery := " SELECT TPCLI,                                                                    "
cQuery += "       SUM(CASE                                                                   "
cQuery += "             WHEN TPCLI = 'P' THEN                                                "
cQuery += "              GERAL                                                               "
cQuery += "             ELSE                                                                 "
cQuery += "              0                                                                   "
cQuery += "           End) PULVERIZADO,                                                      "
cQuery += "       SUM(CASE                                                                   "
cQuery += "             WHEN TPCLI = 'E' THEN                                                "
cQuery += "              GERAL                                                               "
cQuery += "             ELSE                                                                 "
cQuery += "              0                                                                   "
cQuery += "           End) ESPECIAL,                                                         "
cQuery += "       SUM(CASE                                                                   "
cQuery += "             WHEN TPCLI = 'S' THEN                                                "
cQuery += "              GERAL                                                               "
cQuery += "             ELSE                                                                 "
cQuery += "              0                                                                   "
cQuery += "           End) SUPERVERTICAL,                                                    "
cQuery += "       SUM(case                                                                   "
cQuery += "             when CLASCLI = 1 then                                                "
cQuery += "              1                                                                   "
cQuery += "             else                                                                 "
cQuery += "              0                                                                   "
cQuery += "           End) ATIVOS,                                                           "
cQuery += "       SUM(case                                                                   "
cQuery += "             when CLASCLI = 0 then                                                "
cQuery += "              1                                                                   "
cQuery += "             else                                                                 "
cQuery += "              0                                                                   "
cQuery += "           End) INATIVOS,                                                         "
cQuery += "       SUM(MEDTRI) / 3 MEDTRI,                                                    "
cQuery += "       SUM(PERIODO) PERIODO,                                                      "
cQuery += "       SUM(CUSTO) CUSTO,                                                          "
cQuery += "       SUM(GERAL) VEndAS,                                                         "
cQuery += "       SUM(VEndAMIX) VEndAMIX,                                                    "
cQuery += "       SUM(PRZ) PRZ                                                               "
cQuery += "  FROM (SELECT (CASE                                                              "
cQuery += "                 WHEN TPCLI IS NULL THEN                                          "
cQuery += "                  'P'                                                             "
cQuery += "                ELSE                                                             "
cQuery += "                  TPCLI                                                           "
cQuery += "               End) TPCLI,                                                        "
cQuery += "               ZH_CLIENTE,                                                        "
cQuery += "               (CASE                                                              "
cQuery += "                 WHEN ULTCOM <> ' ' AND ('"+DtoS(dDataBase)+"' - ULTCOM) <= 90 THEN            "
cQuery += "                  1                                                               "
cQuery += "                 ELSE                                                             "
cQuery += "                  0                                                               "
cQuery += "               End) CLASCLI,                                                      "
cQuery += "               (CASE                                                              "
cQuery += "                 WHEN ULTCOM <> ' ' AND                                           "
cQuery += "                      ULTCOM BETWEEN                                              "
cQuery += "                      TO_CHAR(TRUNC(ADD_MONTHS(SYSDATE, -3), 'DD'),               "
cQuery += "                              'YYYYMMDD') AND                                     "
cQuery += "                      TO_CHAR(TRUNC(SYSDATE, 'DD'), 'YYYYMMDD') THEN              "
cQuery += "                  1                                                               "
cQuery += "                 ELSE                                                             "
cQuery += "                  0                                                               "
cQuery += "               End) MEDTRI,                                                       "
cQuery += "               (CASE                                                              "
cQuery += "                 WHEN ULTCOM BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN "
cQuery += "                  1                                                               "
cQuery += "                 ELSE                                                             "
cQuery += "                  0                                                               "
cQuery += "               End) PERIODO,                                                      "
cQuery += "               PRZ,                                                               "
cQuery += "               CUSTO,                                                             "
cQuery += "               GERAL,                                                             "
cQuery += "               VEndAMIX                                                           "
cQuery += "          FROM (SELECT MAX(EMISSAO) ULTCOM,                                       "
cQuery += "                       ZH_CLIENTE,                                                "
cQuery += "                       SUM(CASE                                                   "
cQuery += "                        WHEN OPER <> '05' AND EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN"
cQuery += "                              (QTDVEN *                                           "
cQuery += "                              (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) /      "
cQuery += "                              M2_MOEDA5                                           "
cQuery += "                        ELSE                                                 "
cQuery += "                              0                                                   "
cQuery += "                           End) GERAL,                                            "
cQuery += "                       SUM(CASE                                                   "
cQuery += "                             WHEN OPER <> '05' AND EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN "
cQuery += "                              ((QTDVEN * PRUNIT) *                                "
cQuery += "                              (1 - ((VERBREP + GUELTA + RESSARC) / 100))) /       "
cQuery += "                              M2_MOEDA5                                           "
cQuery += "                             ELSE                                                 "
cQuery += "                              0                                                   "
cQuery += "                           End) VEndAMIX,                                         "
cQuery += "                       SUM(CASE                                                   "
cQuery += "                             WHEN EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN  "
cQuery += "                              (QTDVEN * CUSTO) / M2_MOEDA5                        "
cQuery += "                             ELSE                                                 "
cQuery += "                              0                                                   "
cQuery += "                           End) CUSTO,                                            "
cQuery += "                       SUM(CASE                                                   "
cQuery += "                             WHEN OPER <> '05' AND EMISSAO BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' THEN "
cQuery += "                              ((QTDVEN *                                       "
cQuery += "                              (PRUNIT * (1 - ((GUELTA + RESSARC) / 100)))) /   "
cQuery += "                              SM2.M2_MOEDA5) * TO_NUMBER(PRZMED)               "
cQuery += "                             ELSE                                              "
cQuery += "                              0                                                "
cQuery += "                           End) PRZ,                                           "
cQuery += "                       TPCLI                                                   "
cQuery += "                  FROM (SELECT *                                               "
cQuery += "                          FROM MIX"+CEMPANT+"0  MIX, "+RetSqlName("SB1")+" SB1, "+RetSqlName("SBM")+" SBM              "
cQuery += "                         WHERE SBM.D_E_L_E_T_ = ' '                            "
cQuery += "                           AND SB1.D_E_L_E_T_ = ' '                            "
cQuery += "                           AND SBM.BM_FILIAL = '"+XFILIAL("SBM")+"'            "
cQuery += "                           AND SB1.B1_FILIAL = '"+XFILIAL("SB1")+"'            "
cQuery += "                           AND B1_COD = COD                                    "
cQuery += "                           AND B1_GRUPO = BM_GRUPO                             "
cQuery += "                           AND BM_XSUBGRU NOT IN ('20007I', '20008I', '10007O',"
cQuery += "                                '10008O', '10007M')) MIX,                     "
cQuery += "                       MIX"+_cUsu+" M,                                           "
cQuery += "                       "+RetSqlName("SM2")+" SM2,                             "
cQuery += "                       (SELECT ZH_VEnd,                                       "
cQuery += "                               ZH_ITINER,                                     "
cQuery += "                               A1_COD ZH_CLIENTE,                             "
cQuery += "                               ZH_SEGMENT,                                    "
cQuery += "                               MAX(ZH_VERBREP) ZH_VERBREP                     "
cQuery += "                          FROM "+RetSqlName("SZH")+" SZH, "+RetSqlName("SA3")+" SA3, "+RetSqlName("SA1")+" SA1 "
cQuery += "                         WHERE SZH.D_E_L_E_T_ = ' '                           "
cQuery += "                           AND SA1.D_E_L_E_T_ = ' '                           "
cQuery += "                           AND SA3.D_E_L_E_T_ = ' '                           "
cQuery += "                           AND SZH.ZH_FILIAL = '"+XFILIAL("SZH")+"'           "
cQuery += "                           AND SA1.A1_FILIAL = '"+XFILIAL("SA1")+"'           "
cQuery += "                           AND SA3.A3_FILIAL = '"+XFILIAL("SA3")+"'           "
cQuery += "                           AND SZH.ZH_CLIENTE = SA1.A1_COD                    "
cQuery += "                           AND SZH.ZH_LOJA = SA1.A1_LOJA                      "
cQuery += "                           AND SZH.ZH_VEND = SA3.A3_COD                       "
cQuery += "                           AND SZH.ZH_MSBLQL <> '1'                           "
cQuery += "                           AND ZH_SEGMENT IN ('2')                            "
cQuery += "                         GROUP BY ZH_VEnd, ZH_ITINER, A1_COD, ZH_SEGMENT) SA1 "
cQuery += "                 WHERE M.CLI(+) = ZH_CLIENTE                        "
cQuery += "                   AND M.Vendedor(+) = ZH_VEND                      "
cQuery += "                   AND SM2.D_E_L_E_T_ = ' '                         "
cQuery += "                   AND M2_DATA = EMISSAO                            "
cQuery += "                   AND ZH_SEGMENT IN ('2')                          "
cQuery += "                   AND OPER(+) IN ('01', '04',  '05', '10',   '11', "
cQuery += "                                   '14',                            "
cQuery += "                                   '15',                            "
cQuery += "                                   '16',                            "
cQuery += "                                   '20',                            "
cQuery += "                                   '21',                            "
cQuery += "                                   '19',                            "
cQuery += "                                   '26',                            "
cQuery += "                                   '27')                            "
cQuery += "                   AND EMISSAO(+) BETWEEN '"+DTOS(FirstDate(dDataBase))+"' AND '"+DTOS(dDataBase)+"' "
cQuery += "                   AND ZH_CLIENTE = CLIENTE(+)                      "
cQuery += "                   AND ZH_SEGMENT = TPSEGM(+)                       "
cQuery += "                   AND ZH_VEND = VEnd(+)                            "
cQuery += "                   AND ZH_VEND = '"+cXVend+"'   					   "
cQuery += "                 GROUP BY ZH_VEnd, TPCLI, ZH_CLIENTE))              "
cQuery += " GROUP BY TPCLI                                                     "

MEMOWRIT("C:\QRY\MIXPRO_CLI_2.SQL", cQuery)

If Select("CLI") > 0
	dbSelectArea("CLI")
	dbCloseArea()
EndIf
TcQuery cQuery Alias "CLI" New

DBSELECTAREA("CLI")

CLI->(dbGoTop())
If !CLI->(EOF())
	
	WHILE !CLI->(EOF())
		
		If ALLTRIM(CLI->TPCLI) == 'S'
			ASUP[1]:= CLI->MEDTRI
			ASUP[2]:= CLI->PERIODO
			ASUP[3]:= noRound(CLI->VEndAS,2)
			nMark  := noRound(CLI->VEndAMIX/CLI->CUSTO,2)
			ASUP[4]:= noRound(((nMark-1)/nMark)*100,2)
			ASUP[5]:= noRound( CLI->PRZ/CLI->VEndAS,0)
			ASUP[6]:= CLI->CUSTO
		elseIf ALLTRIM(CLI->TPCLI) =='P'
			APUL[1]:= CLI->MEDTRI
			APUL[2]:= CLI->PERIODO
			APUL[3]:= noRound(CLI->VEndAS,2)
			nMark  := noRound(CLI->VEndAMIX/CLI->CUSTO,2)
			APUL[4]:= noRound(((nMark-1)/nMark)*100,2)
			APUL[5]:= noRound( CLI->PRZ/CLI->VEndAS,0)
			APUL[6]:= CLI->CUSTO
		elseIf ALLTRIM(CLI->TPCLI) == 'E'
			AESP[1]:= CLI->MEDTRI
			AESP[2]:= CLI->PERIODO
			AESP[3]:= noRound(CLI->VEndAS,2)
			nMark  := noRound(CLI->VEndAMIX/CLI->CUSTO,2)
			AESP[4]:= noRound(((nMark-1)/nMark)*100,2)
			AESP[5]:= noRound(CLI->PRZ/CLI->VEndAS,0)
			AESP[6]:= CLI->CUSTO
		EndIf
		CLI->(DBSKIP())
	End
	
	// calculo de deflacao para o segmento comercial
	nDef    := noRound((nDefMes  / 30) * noRound(nPrzCom/nValCom,2),2)
	nDefVal := noRound(((100-nDef)/100) * noRound(nValCom,2),2)
	nDefCt  := noRound(((100-nDef)/100) * noRound(nCtCom,2),2)
	nMark   := noRound(nValCom/nCtCom,2)
	nRetCom := noRound(((nMark-1)/nMark)*100,2)
	nMark   := noRound(nDefVal/nDefCt,2)
	nRetDef := noRound(((nMark-1)/nMark)*100,2)
	
	Aadd(aRetMix2, { APUL[4], AESP[4], ASUP[4], nMixLiq })
	Aadd(aRetMix2, { APUL[3], AESP[3], ASUP[3], (APUL[3]+AESP[3]+ASUP[3]) })
	Aadd(aRetMix2, { APUL[6], AESP[6], ASUP[6], (APUL[6]+AESP[6]+ASUP[6]) })
	
	dbSelectArea("CLI")
	dbCloseArea()
Else
	Aadd(aRetMix2, { 0, 0, 0, 0 })
	Aadd(aRetMix2, { 0, 0, 0, 0 })
	Aadd(aRetMix2, { 0, 0, 0, 0 })
Endif

Return(aRetMix, aRetMix2)

***********************************
Static Function fDiscL2()
***********************************

Local cQuery   := " "
Local nTotMed  := 0
Local nTotQtd  := 0
Local nTotLiq  := 0
Local nTotCusto:= 0
Local nMixLiq  := 0
Local cGrupo   := " "

Local dIniTrim  := DTOS(FirstDate(MonthSub(dDataBase,3)))
Local d2IniTrim := DTOS(FirstDate(MonthSub(dDataBase,6)))
Local dFimTrim  := DTOS(FirstDate(dDataBase)-1)

Local dIniAnt  := DTOS(FirstDate(MonthSub(YearSub(dDataBase,1),3)))
Local d2IniAnt := DTOS(FirstDate(MonthSub(YearSub(dDataBase,1),6)))
Local dFimAnt  := DTOS(FirstDate(YearSub(dDataBase,1))-1)

Local nIdx
Local nIdy
Local nColIni  := 36
Local nRefCol  := nColIni

_aVenTab  := {}
_aVenGG   := {}
_aVenReg  := {}

_aVenTab2 := {}
_aVenGG2  := {}
_aVenReg2 := {}

*'TAB 1 -------------------------------------------------------------------------------------------'*
cQry := " SELECT AUTORIZ, TPCLI, "
cQry += "       SUM(CASE WHEN TPCLI = 'P' THEN TOTPED ELSE 0 End) PULVERIZADO,   "
cQry += "       SUM(CASE WHEN TPCLI = 'E' THEN TOTPED ELSE 0 End) ESPECIAL,      "
cQry += "       SUM(CASE WHEN TPCLI = 'S' THEN TOTPED ELSE 0 End) SUPERVERTICAL "
cQry += "    FROM ( SELECT AUTORIZ, (CASE WHEN TOTPED < 300 THEN 'P' 
cQry += "        				          WHEN TOTPED < 500 THEN 'E' 
cQry += "                				  WHEN TOTPED < 2500 AND A1_XTIPO NOT IN ('1','5') THEN 'E' 
cQry += "                ELSE 'S' END) TPCLI, " 
cQry += "  CLIENTE , ZH_VEND , TOTPED "
cQry += "  FROM (SELECT AUTORIZ, A1_COD CLIENTE,  A1_XTPCLI, ZH_VEND, A.A1_XTIPO, SUM(TOTPED) TOTPED "
cQry += "           FROM "
cQry += "                       (SELECT AUTORIZ, GRU.A1_XCODGRU GRUPO, ZH_VEND, GRU.A1_XTIPO, "
cQry += "                              SUM(CASE WHEN OPER <> '05' AND EMISSAO >= '"+DTOS(FirstDate(dDataBase))+"' AND EMISSAO <= '"+DTOS(dDataBase)+"' THEN (((PRUNIT*QTDVEN)*(1-((GUELTA+RESSARC)/100))))/M2_MOEDA5 ELSE 0 End) TOTPED "
cQry += "                          FROM "+RETSQLNAME("SA1")+" SA1, "
cQry += "                               "+RETSQLNAME("SA1")+" GRU, "
cQry += "                               "+RETSQLNAME("SM2")+" SM2, "
cQry += "                               "+RETSQLNAME("SZH")+" SZH, "
cQry += "                               "+RETSQLNAME("SB1")+" SB1, "
cQry += "                               "+RETSQLNAME("SBM")+" SBM, "
cQry += "                                 (SELECT MIX.*, "
cQry += "                                          NVL(NVL((SELECT DISTINCT '3' "
cQry += "                                                    FROM " + RetSqlName("SZE")
cQry += "                                                   WHERE D_E_L_E_T_ = ' ' "
cQry += "                                                     AND ZE_FILIAL = '"+XFILIAL("SZE")+"' "
cQry += "                                                     AND ZE_PEDIDO = NUM "
cQry += "                                                     AND ZE_AUTORIZ IN ('BLQMIX','BLQPZM')), "
cQry += "                                                  (SELECT '1' "
cQry += "                                                     FROM " + RetSqlName("SZE")
cQry += "                                                    WHERE D_E_L_E_T_ = ' ' "
cQry += "                                                      AND ZE_FILIAL = '"+XFILIAL("SZE")+"' "
cQry += "                                                      AND ZE_PEDIDO = NUM "
cQry += "                                                      AND ZE_AUTORIZ = 'BLQPRC' "
cQry += "                                                      AND EXISTS ( "
cQry += "                                                                   SELECT 'X' FROM " 
cQry += "                                                      				"+RETSQLNAME("SC5") + " SC5, " + RETSQLNAME("SC6") + " SC6, " + RETSQLNAME("ACP") + " ACP "
cQry += "                                                                   WHERE SC5.D_E_L_E_T_ = ' ' "
cQry += "                                                                   AND SC6.D_E_L_E_T_ = ' ' "
cQry += "                                                                   AND ACP.D_E_L_E_T_ = ' ' "
cQry += "                                                                   AND SC5.C5_FILIAL  = '"+XFILIAL("SC5")+"' "
cQry += "                                                                   AND SC6.C6_FILIAL  = '"+XFILIAL("SC6")+"' "
cQry += "                                                                   AND ACP.ACP_FILIAL = '"+XFILIAL("ACP")+"' "
cQry += "                                                                   AND SC6.C6_PRODUTO = COD "
cQry += "                                                                   AND SC5.C5_NUM = NUM "
cQry += "                                                                   AND ACP_CODPRO = SC6.C6_PRODUTO "
cQry += "                                                                   AND SC5.C5_NUM = SC6.C6_NUM "
cQry += "                                                                   AND ACP_CODREG = '00'||C5_TABELA||C5_XREFTAB "
cQry += "                                                                   AND C6_XPRCVEN >= ACP_XPRECO)) ), "
cQry += "                                              '2') AUTORIZ "
cQry += "                                     FROM MIX"+CEMPANT+"0 MIX "

cQry += " WHERE EMISSAO BETWEEN '"+DTOS(FirstDate(MonthSub(dDataBase,3)))+"' AND '"+DTOS(dDataBase)+"' "
cQry += " AND OPER IN ('01','05','13','04', '14', '15', '16', '20', '21','26') "
cQry += " AND TPSEGM IN ('2')) "

cQry += "                          WHERE CLIENTE = GRU.A1_COD "
cQry += "                           AND GRU.A1_XCODGRU = SA1.A1_XCODGRU "
cQry += "                           AND GRU.A1_COD = SA1.A1_COD "
cQry += "                           AND GRU.A1_LOJA = SA1.A1_LOJA "
cQry += "                           AND ZH_CLIENTE  = CLIENTE "
cQry += "                           AND ZH_SEGMENT  = TPSEGM "
cQry += "                           AND BM_GRUPO    = B1_GRUPO "                         
cQry += "                           AND B1_COD      = COD      "
cQry += "                           AND B1_GRUPO    = BM_GRUPO "
cQry += "                           AND SA1.D_E_L_E_T_ = ' ' "
cQry += "                           AND Sb1.D_E_L_E_T_ = ' ' "
cQry += "                           AND Sbm.D_E_L_E_T_ = ' ' "
cQry += "                           AND GRU.D_E_L_E_T_ = ' ' "
cQry += "                           AND SM2.D_E_L_E_T_ = ' ' "
cQry += "                           AND SZH.D_E_L_E_T_ = ' ' "
cQry += "                           AND SA1.A1_FILIAL = '"+XFILIAL("SA1")+"'"
cQry += "                           AND GRU.A1_FILIAL = '"+XFILIAL("SA1")+"'"
cQry += "                           AND SZH.ZH_FILIAL = '"+XFILIAL("SZH")+"'"
cQry += "							AND BM_FILIAL = '"+XFILIAL("SBM")+"' "
cQry += "                           AND B1_FILIAL = '"+XFILIAL("SB1")+"' "
cQry += " AND M2_DATA = EMISSAO "
cQry += " AND SA1.A1_XCODGRU = GRU.A1_XCODGRU "
cQry += " AND SA1.A1_LOJA = '01' "

cQry += " GROUP BY AUTORIZ, GRU.A1_XCODGRU , GRU.A1_XTIPO, ZH_VEND ) A, "+RETSQLNAME("SA1")+" SA1 "
cQry += " WHERE D_E_L_e_T_= ' ' AND A1_FILIAL ='"+XFILIAL("SA1")+"' AND A1_XCODGRU = GRUPO  group by AUTORIZ, A1_COD, A1_XTPCLI, ZH_VEND, A.A1_XTIPO))"
cQry += " GROUP BY AUTORIZ, TPCLI "
cQry += " ORDER BY AUTORIZ, TPCLI "

MEMOWRIT("C:\QRY\ORTR16B_TABELA2_1.SQL",cQry)
U_ORTQUERY(cQry, "TABMIX")

_nTotPul := 0
_nTotEsp := 0
_nTotSup := 0

_nTabTot := 0
_nGGTot  := 0
_nRegTot := 0

_nTabPul := 0
_nTabEsp := 0
_nTabSup := 0

_nGGPul  := 0
_nGGEsp  := 0
_nGGSup  := 0

_nRegPul := 0
_nRegEsp := 0
_nRegSup := 0

TABMIX->(DbGoTop())

While !TABMIX->(EOF())
	
	If TABMIX->TPCLI == "P"
		_nTotPul += TABMIX->PULVERIZADO
		If TABMIX->AUTORIZ == "1"
			_nTabPul += TABMIX->PULVERIZADO
			_nTabTot += TABMIX->PULVERIZADO
		ELSEIf TABMIX->AUTORIZ == "2"
			_nGGPul  += TABMIX->PULVERIZADO
			_nGGTot  += TABMIX->PULVERIZADO
		ELSEIf TABMIX->AUTORIZ == "3"
			_nRegPul += TABMIX->PULVERIZADO
			_nRegTot += TABMIX->PULVERIZADO
		Endif
	ElseIf TABMIX->TPCLI == "E"
		_nTotEsp += TABMIX->ESPECIAL
		If TABMIX->AUTORIZ == "1"
			_nTabEsp += TABMIX->ESPECIAL
			_nTabTot += TABMIX->ESPECIAL
		ELSEIf TABMIX->AUTORIZ == "2"
			_nGGEsp  += TABMIX->ESPECIAL
			_nGGTot  += TABMIX->ESPECIAL
		ELSEIf TABMIX->AUTORIZ == "3"
			_nRegEsp += TABMIX->ESPECIAL
			_nRegTot += TABMIX->ESPECIAL
		Endif
	ElseIf TABMIX->TPCLI == "S"
		_nTotSup += TABMIX->SUPERVERTICAL
		If TABMIX->AUTORIZ == "1"
			_nTabSup += TABMIX->SUPERVERTICAL
			_nTabTot += TABMIX->SUPERVERTICAL
		ElseIf TABMIX->AUTORIZ == "2"
			_nGGSup  += TABMIX->SUPERVERTICAL
			_nGGTot  += TABMIX->SUPERVERTICAL
		ElseIf TABMIX->AUTORIZ == "3"
			_nRegSup += TABMIX->SUPERVERTICAL
			_nRegTot += TABMIX->SUPERVERTICAL
		Endif
	Endif
	
	TABMIX->(DbSkip())
End

TABMIX->(dbCloseArea())

// aRetMix[2] // Valor
// aRetMix[1] // %

_nPorc1 := 0.1   // Nivel arredondamento
_nPorc2 := 0.05  // Nivel arredondamento
_nPorc3 := 0.15  // Nivel arredondamento

_nPTabPul := (_nTabPul / _nTotPul) * 100
_nPTabEsp := (_nTabEsp / _nTotEsp) * 100
_nPTabSup := (_nTabSup / _nTotSup) * 100

_nPGGPul  := (_nGGPul  / _nTotPul) * 100
_nPGGEsp  := (_nGGEsp  / _nTotEsp) * 100
_nPGGSup  := (_nGGSup  / _nTotSup) * 100

_nPRegPul := (_nRegPul / _nTotPul) * 100
_nPRegEsp := (_nRegEsp / _nTotEsp) * 100
_nPRegSup := (_nRegSup / _nTotSup) * 100


// Tabela //////////////////////////////////////////////////////////////////////////
nPValT   := (_nTabTot / aRetMix[2,4]) * 100
nValMix1 := noround((aRetMix[2,4] * nPValT) / 100,2)
nTotCus1 := noround((aRetMix[3,4] * (nPValT+_nPorc1)) / 100,2)
nMixLiq	 := U_OR16BCLB(nValMix1, nTotCus1)

*'Valor'*
_nVlrPul := noround((aRetMix[2,1] * _nPTabPul) / 100,2)
_nVlrEsp := noround((aRetMix[2,2] * _nPTabEsp) / 100,2)
_nVlrSup := noround((aRetMix[2,3] * _nPTabSup) / 100,2)

*'Custo'*
_nCusPul := noround((aRetMix[3,1] * (_nPTabPul+_nPorc1)) / 100,2)
_nCusEsp := noround((aRetMix[3,2] * (_nPTabEsp+_nPorc2)) / 100,2)
_nCusSup := noround((aRetMix[3,3] * (_nPTabSup+_nPorc3)) / 100,2)

*'Porcentagem'*
nMark    := Round(_nVlrPul/_nCusPul,2)
_nPorPul := noRound(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrEsp/_nCusEsp,2)
_nPorEsp := Round(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrSup/_nCusSup,2)
_nPorSup :=	noRound(((nMark-1)/nMark)*100,2)

Aadd(_aVenTab, { _nPorPul, _nPorEsp, _nPorSup, nMixLiq })
Aadd(_aVenTab, { _nVlrPul, _nVlrEsp, _nVlrSup, _nVlrPul+_nVlrEsp+_nVlrSup})

// G.G. ////////////////////////////////////////////////////////////////////////////
nPValT   := (_nGGTot / aRetMix[2,4]) * 100
nValMix1 := noround((aRetMix[2,4] * nPValT) / 100,2)
nTotCus1 := noround((aRetMix[3,4] * (nPValT+_nPorc2)) / 100,2)
nMixLiq	 := U_OR16BCLB(nValMix1, nTotCus1)

*'Valor'*
_nVlrPul := noround((aRetMix[2,1] * _nPGGPul) / 100,2)
_nVlrEsp := noround((aRetMix[2,2] * _nPGGEsp) / 100,2)
_nVlrSup := noround((aRetMix[2,3] * _nPGGSup) / 100,2)

*'Custo'*
_nCusPul := noround((aRetMix[3,1] * (_nPGGPul+_nPorc1)) / 100,2)
_nCusEsp := noround((aRetMix[3,2] * (_nPGGEsp+_nPorc2)) / 100,2)
_nCusSup := noround((aRetMix[3,3] * (_nPGGSup+_nPorc3)) / 100,2)

*'Porcentagem'*
nMark    := Round(_nVlrPul/_nCusPul,2)
_nPorPul := noRound(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrEsp/_nCusEsp,2)
_nPorEsp := Round(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrSup/_nCusSup,2)
_nPorSup :=	noRound(((nMark-1)/nMark)*100,2)

Aadd(_aVenGG, { _nPorPul, _nPorEsp, _nPorSup, nMixLiq })
Aadd(_aVenGG, { _nVlrPul, _nVlrEsp, _nVlrSup, _nVlrPul+_nVlrEsp+_nVlrSup})

// Regional ////////////////////////////////////////////////////////////////////////
nPValT   := (_nRegTot / aRetMix[2,4]) * 100
nValMix1 := noround((aRetMix[2,4] * nPValT) / 100,2)
nTotCus1 := noround((aRetMix[3,4] * (nPValT+_nPorc3)) / 100,2)
nMixLiq	 := U_OR16BCLB(nValMix1, nTotCus1)

*'Valor'*
_nVlrPul := noround((aRetMix[2,1] * _nPRegPul) / 100,2)
_nVlrEsp := noround((aRetMix[2,2] * _nPRegEsp) / 100,2)
_nVlrSup := noround((aRetMix[2,3] * _nPRegSup) / 100,2)

*'Custo'*
_nCusPul := noround((aRetMix[3,1] * (_nPRegPul+_nPorc1)) / 100,2)
_nCusEsp := noround((aRetMix[3,2] * (_nPRegEsp+_nPorc2)) / 100,2)
_nCusSup := noround((aRetMix[3,3] * (_nPRegSup+_nPorc3)) / 100,2)

*'Porcentagem'*
nMark    := Round(_nVlrPul/_nCusPul,2)
_nPorPul := noRound(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrEsp/_nCusEsp,2)
_nPorEsp := Round(((	nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrSup/_nCusSup,2)
_nPorSup :=	noRound(((nMark-1)/nMark)*100,2)

Aadd(_aVenReg, { _nPorPul, _nPorEsp, _nPorSup, nMixLiq })
Aadd(_aVenReg, { _nVlrPul, _nVlrEsp, _nVlrSup, _nVlrPul+_nVlrEsp+_nVlrSup})


*'TAB 2 -------------------------------------------------------------------------------------------'*
cQry := " SELECT AUTORIZ, TPCLI, "
cQry += "       SUM(CASE WHEN TPCLI = 'P' THEN TOTPED ELSE 0 End) PULVERIZADO,   "
cQry += "       SUM(CASE WHEN TPCLI = 'E' THEN TOTPED ELSE 0 End) ESPECIAL,      "
cQry += "       SUM(CASE WHEN TPCLI = 'S' THEN TOTPED ELSE 0 End) SUPERVERTICAL "
cQry += "    FROM ( SELECT AUTORIZ, (CASE WHEN TOTPED < 300 THEN 'P' 
cQry += "        				          WHEN TOTPED < 500 THEN 'E' 
cQry += "                				  WHEN TOTPED < 2500 AND A1_XTIPO NOT IN ('1','5') THEN 'E' 
cQry += "                ELSE 'S' END) TPCLI, " 
cQry += "  CLIENTE , ZH_VEND , TOTPED "
cQry += "  FROM (SELECT AUTORIZ, A1_COD CLIENTE,  A1_XTPCLI, ZH_VEND, A.A1_XTIPO, SUM(TOTPED) TOTPED "
cQry += "           FROM "
cQry += "                       (SELECT AUTORIZ, GRU.A1_XCODGRU GRUPO, ZH_VEND, GRU.A1_XTIPO, "
cQry += "                              SUM(CASE WHEN OPER <> '05' AND EMISSAO >= '"+DTOS(FirstDate(dDataBase))+"' AND EMISSAO <= '"+DTOS(dDataBase)+"' THEN (((PRUNIT*QTDVEN)*(1-((GUELTA+RESSARC)/100))))/M2_MOEDA5 ELSE 0 End) TOTPED "
cQry += "                          FROM "+RETSQLNAME("SA1")+" SA1, "
cQry += "                               "+RETSQLNAME("SA1")+" GRU, "
cQry += "                               "+RETSQLNAME("SM2")+" SM2, "
cQry += "                               "+RETSQLNAME("SZH")+" SZH, "
cQry += "                               "+RETSQLNAME("SB1")+" SB1, "
cQry += "                               "+RETSQLNAME("SBM")+" SBM, "
cQry += "                                 (SELECT MIX.*, "
cQry += "                                          NVL(NVL((SELECT DISTINCT '3' "
cQry += "                                                    FROM " + RetSqlName("SZE")
cQry += "                                                   WHERE D_E_L_E_T_ = ' ' "
cQry += "                                                     AND ZE_FILIAL = '"+XFILIAL("SZE")+"' "
cQry += "                                                     AND ZE_PEDIDO = NUM "
cQry += "                                                     AND ZE_AUTORIZ IN ('BLQMIX','BLQPZM')), "
cQry += "                                                  (SELECT '1' "
cQry += "                                                     FROM " + RetSqlName("SZE")
cQry += "                                                    WHERE D_E_L_E_T_ = ' ' "
cQry += "                                                      AND ZE_FILIAL = '"+XFILIAL("SZE")+"' "
cQry += "                                                      AND ZE_PEDIDO = NUM "
cQry += "                                                      AND ZE_AUTORIZ = 'BLQPRC' "
cQry += "                                                      AND EXISTS ( "
cQry += "                                                                   SELECT 'X' FROM " 
cQry += "                                                      				"+RETSQLNAME("SC5") + " SC5, " + RETSQLNAME("SC6") + " SC6, " + RETSQLNAME("ACP") + " ACP "
cQry += "                                                                   WHERE SC5.D_E_L_E_T_ = ' ' "
cQry += "                                                                   AND SC6.D_E_L_E_T_ = ' ' "
cQry += "                                                                   AND ACP.D_E_L_E_T_ = ' ' "
cQry += "                                                                   AND SC5.C5_FILIAL  = '"+XFILIAL("SC5")+"' "
cQry += "                                                                   AND SC6.C6_FILIAL  = '"+XFILIAL("SC6")+"' "
cQry += "                                                                   AND ACP.ACP_FILIAL = '"+XFILIAL("ACP")+"' "
cQry += "                                                                   AND SC6.C6_PRODUTO = COD "
cQry += "                                                                   AND SC5.C5_NUM = NUM "
cQry += "                                                                   AND ACP_CODPRO = SC6.C6_PRODUTO "
cQry += "                                                                   AND SC5.C5_NUM = SC6.C6_NUM "
cQry += "                                                                   AND ACP_CODREG = '00'||C5_TABELA||C5_XREFTAB "
cQry += "                                                                   AND C6_XPRCVEN >= ACP_XPRECO)) ), "
cQry += "                                              '2') AUTORIZ "
cQry += "                                     FROM MIX"+CEMPANT+"0 MIX "

cQry += " WHERE EMISSAO BETWEEN '"+DTOS(FirstDate(MonthSub(dDataBase,3)))+"' AND '"+DTOS(dDataBase)+"' "
cQry += " AND OPER IN ('01','05','13','04', '14', '15', '16', '20', '21','26') "
cQry += " AND TPSEGM IN ('2')) "

cQry += "                          WHERE CLIENTE = GRU.A1_COD "
cQry += "                           AND GRU.A1_XCODGRU = SA1.A1_XCODGRU "
cQry += "                           AND GRU.A1_COD = SA1.A1_COD "
cQry += "                           AND GRU.A1_LOJA = SA1.A1_LOJA "
cQry += "                           AND ZH_CLIENTE  = CLIENTE "
cQry += "                           AND ZH_SEGMENT  = TPSEGM "
cQry += "                           AND BM_GRUPO    = B1_GRUPO "                         
cQry += "                           AND B1_COD      = COD      "
cQry += "                           AND B1_GRUPO    = BM_GRUPO "
cQry += "                           AND SA1.D_E_L_E_T_ = ' ' "
cQry += "                           AND Sb1.D_E_L_E_T_ = ' ' "
cQry += "                           AND Sbm.D_E_L_E_T_ = ' ' "
cQry += "                           AND GRU.D_E_L_E_T_ = ' ' "
cQry += "                           AND SM2.D_E_L_E_T_ = ' ' "
cQry += "                           AND SZH.D_E_L_E_T_ = ' ' "
cQry += "                           AND SA1.A1_FILIAL = '"+XFILIAL("SA1")+"'"
cQry += "                           AND GRU.A1_FILIAL = '"+XFILIAL("SA1")+"'"
cQry += "                           AND SZH.ZH_FILIAL = '"+XFILIAL("SZH")+"'"
cQry += "							AND BM_FILIAL = '"+XFILIAL("SBM")+"' "
cQry += "                           AND B1_FILIAL = '"+XFILIAL("SB1")+"' "
cQry += " AND M2_DATA = EMISSAO "
cQry += " AND SA1.A1_XCODGRU = GRU.A1_XCODGRU "
cQry += " AND SA1.A1_LOJA = '01' "

cQry += " GROUP BY AUTORIZ, GRU.A1_XCODGRU , GRU.A1_XTIPO, ZH_VEND ) A, "+RETSQLNAME("SA1")+" SA1 "
cQry += " WHERE D_E_L_e_T_= ' ' AND A1_FILIAL ='"+XFILIAL("SA1")+"' AND A1_XCODGRU = GRUPO  group by AUTORIZ, A1_COD, A1_XTPCLI, ZH_VEND, A.A1_XTIPO))"
cQry += " WHERE ZH_VEND = '" + cXVend + "' "
cQry += " GROUP BY AUTORIZ, TPCLI, ZH_VEND "
cQry += " ORDER BY AUTORIZ, TPCLI "

MEMOWRIT("C:\QRY\ORTR16B_TABELA2_2.SQL",cQry)
U_ORTQUERY(cQry, "TABMIX")

_nTotPul := 0
_nTotEsp := 0
_nTotSup := 0

_nTabTot := 0
_nGGTot  := 0
_nRegTot := 0

_nTabPul := 0
_nTabEsp := 0
_nTabSup := 0

_nGGPul  := 0
_nGGEsp  := 0
_nGGSup  := 0

_nRegPul := 0
_nRegEsp := 0
_nRegSup := 0

TABMIX->(DbGoTop())

While !TABMIX->(EOF())
	

	If TABMIX->TPCLI == "P"
		_nTotPul += TABMIX->PULVERIZADO
		If TABMIX->AUTORIZ == "1"
			_nTabPul += TABMIX->PULVERIZADO
			_nTabTot += TABMIX->PULVERIZADO
		ELSEIf TABMIX->AUTORIZ == "2"
			_nGGPul  += TABMIX->PULVERIZADO
			_nGGTot  += TABMIX->PULVERIZADO
		ELSEIf TABMIX->AUTORIZ == "3"
			_nRegPul += TABMIX->PULVERIZADO
			_nRegTot += TABMIX->PULVERIZADO
		Endif
	ElseIf TABMIX->TPCLI == "E"
		_nTotEsp += TABMIX->ESPECIAL
		If TABMIX->AUTORIZ == "1"
			_nTabEsp += TABMIX->ESPECIAL
			_nTabTot += TABMIX->ESPECIAL
		ELSEIf TABMIX->AUTORIZ == "2"
			_nGGEsp  += TABMIX->ESPECIAL
			_nGGTot  += TABMIX->ESPECIAL
		ELSEIf TABMIX->AUTORIZ == "3"
			_nRegEsp += TABMIX->ESPECIAL
			_nRegTot += TABMIX->ESPECIAL
		Endif
	ElseIf TABMIX->TPCLI == "S"
		_nTotSup += TABMIX->SUPERVERTICAL
		If TABMIX->AUTORIZ == "1"
			_nTabSup += TABMIX->SUPERVERTICAL
			_nTabTot += TABMIX->SUPERVERTICAL
		ElseIf TABMIX->AUTORIZ == "2"
			_nGGSup  += TABMIX->SUPERVERTICAL
			_nGGTot  += TABMIX->SUPERVERTICAL
		ElseIf TABMIX->AUTORIZ == "3"
			_nRegSup += TABMIX->SUPERVERTICAL
			_nRegTot += TABMIX->SUPERVERTICAL
		Endif
	Endif
	
	TABMIX->(DbSkip())
End

TABMIX->(dbCloseArea())


_nPorc1 := 0.1   // Nivel arredondamento
_nPorc2 := 0.05  // Nivel arredondamento
_nPorc3 := 0.15  // Nivel arredondamento

_nPTabPul := (_nTabPul / _nTotPul) * 100
_nPTabEsp := (_nTabEsp / _nTotEsp) * 100
_nPTabSup := (_nTabSup / _nTotSup) * 100

_nPGGPul  := (_nGGPul  / _nTotPul) * 100
_nPGGEsp  := (_nGGEsp  / _nTotEsp) * 100
_nPGGSup  := (_nGGSup  / _nTotSup) * 100

_nPRegPul := (_nRegPul / _nTotPul) * 100
_nPRegEsp := (_nRegEsp / _nTotEsp) * 100
_nPRegSup := (_nRegSup / _nTotSup) * 100


// Tabela //////////////////////////////////////////////////////////////////////////
nPValT   := (_nTabTot / aRetMix2[2,4]) * 100
nValMix1 := noround((aRetMix2[2,4] * nPValT) / 100,2)
nTotCus1 := noround((aRetMix2[3,4] * (nPValT+_nPorc1)) / 100,2)
nMixLiq	 := U_OR16BCLB(nValMix1, nTotCus1)

*'Valor'*
_nVlrPul := noround((aRetMix2[2,1] * _nPTabPul) / 100,2)
_nVlrEsp := noround((aRetMix2[2,2] * _nPTabEsp) / 100,2)
_nVlrSup := noround((aRetMix2[2,3] * _nPTabSup) / 100,2)

*'Custo'*
_nCusPul := noround((aRetMix2[3,1] * (_nPTabPul+_nPorc1)) / 100,2)
_nCusEsp := noround((aRetMix2[3,2] * (_nPTabEsp+_nPorc2)) / 100,2)
_nCusSup := noround((aRetMix2[3,3] * (_nPTabSup+_nPorc3)) / 100,2)

*'Porcentagem'*
nMark    := Round(_nVlrPul/_nCusPul,2)
_nPorPul := noRound(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrEsp/_nCusEsp,2)
_nPorEsp := Round(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrSup/_nCusSup,2)
_nPorSup :=	noRound(((nMark-1)/nMark)*100,2)

Aadd(_aVenTab2, { _nPorPul, _nPorEsp, _nPorSup, nMixLiq })
Aadd(_aVenTab2, { _nVlrPul, _nVlrEsp, _nVlrSup, _nVlrPul+_nVlrEsp+_nVlrSup})

// G.G. ////////////////////////////////////////////////////////////////////////////
nPValT   := (_nGGTot / aRetMix2[2,4]) * 100
nValMix1 := noround((aRetMix2[2,4] * nPValT) / 100,2)
nTotCus1 := noround((aRetMix2[3,4] * (nPValT+_nPorc2)) / 100,2)
nMixLiq	 := U_OR16BCLB(nValMix1, nTotCus1)

*'Valor'*
_nVlrPul := noround((aRetMix2[2,1] * _nPGGPul) / 100,2)
_nVlrEsp := noround((aRetMix2[2,2] * _nPGGEsp) / 100,2)
_nVlrSup := noround((aRetMix2[2,3] * _nPGGSup) / 100,2)

*'Custo'*
_nCusPul := noround((aRetMix2[3,1] * (_nPGGPul+_nPorc1)) / 100,2)
_nCusEsp := noround((aRetMix2[3,2] * (_nPGGEsp+_nPorc2)) / 100,2)
_nCusSup := noround((aRetMix2[3,3] * (_nPGGSup+_nPorc3)) / 100,2)

*'Porcentagem'*
nMark    := Round(_nVlrPul/_nCusPul,2)
_nPorPul := noRound(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrEsp/_nCusEsp,2)
_nPorEsp := Round(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrSup/_nCusSup,2)
_nPorSup :=	noRound(((nMark-1)/nMark)*100,2)

Aadd(_aVenGG2, { _nPorPul, _nPorEsp, _nPorSup, nMixLiq })
Aadd(_aVenGG2, { _nVlrPul, _nVlrEsp, _nVlrSup, _nVlrPul+_nVlrEsp+_nVlrSup})

// Regional ////////////////////////////////////////////////////////////////////////
nPValT   := (_nRegTot / aRetMix2[2,4]) * 100
nValMix1 := noround((aRetMix2[2,4] * nPValT) / 100,2)
nTotCus1 := noround((aRetMix2[3,4] * (nPValT+_nPorc3)) / 100,2)
nMixLiq	 := U_OR16BCLB(nValMix1, nTotCus1)

*'Valor'*
_nVlrPul := noround((aRetMix2[2,1] * _nPRegPul) / 100,2)
_nVlrEsp := noround((aRetMix2[2,2] * _nPRegEsp) / 100,2)
_nVlrSup := noround((aRetMix2[2,3] * _nPRegSup) / 100,2)

*'Custo'*
_nCusPul := noround((aRetMix2[3,1] * (_nPRegPul+_nPorc1)) / 100,2)
_nCusEsp := noround((aRetMix2[3,2] * (_nPRegEsp+_nPorc2)) / 100,2)
_nCusSup := noround((aRetMix2[3,3] * (_nPRegSup+_nPorc3)) / 100,2)

*'Porcentagem'*
nMark    := Round(_nVlrPul/_nCusPul,2)
_nPorPul := noRound(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrEsp/_nCusEsp,2)
_nPorEsp := Round(((nMark-1)/nMark)*100,2)
nMark    := noRound(_nVlrSup/_nCusSup,2)
_nPorSup :=	noRound(((nMark-1)/nMark)*100,2)

Aadd(_aVenReg2, { _nPorPul, _nPorEsp, _nPorSup, nMixLiq })
Aadd(_aVenReg2, { _nVlrPul, _nVlrEsp, _nVlrSup, _nVlrPul+_nVlrEsp+_nVlrSup})

Return()

******************************
Static Function Droptable(cTable)
******************************
Local cQuery:="SELECT COUNT(*) TOT FROM ALL_TABLES WHERE OWNER = 'SIGA' AND TABLE_NAME = '"+cTable+"' "

U_ORTQUERY(cQuery, "DROPTAB")

IF DROPTAB->TOT>0
	TCDELFILE(cTable)
EndIf

DROPTAB->(dbCloseArea())

Return()

***********************************
Static Function fImpCab()
***********************************
Local _aArea := GetArea()
nLin+=nEsp
oPrinter:Say(nLin,0600,"Proposta de Negócio - Comercial (Colchão/Travesseiro/Adicional)"		,oTim16N,,0)
oPrinter:Say(nLin,0070,"Pag. "+cValTochar(nPag)		,oTim10N,,0)
//---Info Anexo---//
oPrinter:Say(nLin-nEsp,1975,   "Anexo 03 - CI 119 Comercial/Gerência "		,oTim6,,0)
oPrinter:Say(nLin-nEsp/2,2005, "            Data de Origem: 17/02/2016 "		,oTim6,,0)
oPrinter:Say(nLin,2000,        "      Data de Atualização: 10/04/2018 "		,oTim6,,0)
nLin+=nEsp
//**** Posicionando o Vendedor mais em cima e com mais destaque conforme SSI 89971
DbSelectArea("SA3")
DbSetOrder(1)
DBSeek(xFilial("SA3")+SC5->C5_VEND1)
cVend:= Substr(SA3->A3_NREDUZ,1, 15)
cCodGer:= SA3->A3_GEREN
SA3->(DBGoTop())
DBSeek(xFilial("SA3")+cCodGer)
cGer:= Substr(SA3->A3_NREDUZ,1, 15)
oPrinter:Say(nLin,0070,"Vendedor: "+ SC5->C5_VEND1+" - "+cVend		,oTim16N,,0)
oPrinter:Say(nLin,0900,"Proposta: "+StrZero(nProp,8),oTim11N,,0)
oPrinter:Say(nLin,1600,"Canal: "+SC5->C5_XNICHO + "-" + AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+SC5->C5_XNICHO,"Z0_DESCRI")) ,oTim11N,,0)
nLin+=nEsp
oPrinter:Say(nLin,0070,"Unidade: "+ iif(cEmpAnt=="18".and.cFilAnt=="03","27",cEmpAnt) ,oTim10N,,0)
//**** Posicionando o Vendedor mais em cima e com mais destaque conforme SSI 89971
DbSelectArea("SA3")
oPrinter:Say(nLin,1600,"Gerente: "+cCodGer+" - "+cGer		,oTim10N,,0)
SA3->(DBCloseArea())
nLin+=nEsp

oPrinter:Say(nLin,0070,"Cliente: "+SC5->C5_CLIENTE+" - "+cCliNom	,oTim10N,,0)
oPrinter:Say(nLin,0900,"Limite Crédito: R$"+cCliLim	,oTim10N,,0)
oPrinter:Say(nLin,1600,"Débito Próprio: R$"+cCliDeb	,oTim10N,,0)
nLin+=nEsp
oPrinter:Say(nLin,0070,"Cidade: "+ cCliMun	,oTim10N,,0)
oPrinter:Say(nLin,0550,"Km Unidade (Ida/Volta): "+MV_PAR02	,oTim10N,,0)
oPrinter:Say(nLin,1250,"VPC: "+cValtoChar(Transform(SC5->C5_XVERREP,"@E 99.99"))+" %",	oTim10N,,0)
oPrinter:Say(nLin,1600,"Tabela: "+SC5->C5_TABELA+"/"+SC5->C5_XREFTAB,	oTim10N,,0)
nLin+=nEsp*2
RestArea(_aArea)
Return()

***********************************
Static Function ImpDet(cClix,dDtIni,dDtFim,aPedPro,aCliente)
***********************************
Local x:=0
	cModTrav	:= "" 

For x=1 to len(aPedPro)
	If x == 1
		cPedPro := "('"+aPedPro[x]
	Else 	
		cPedPro += "','"+aPedPro[x]
	EndIf
	
Next x
cPedPro += "')"

For x=1 to len(aCliente)
	If x == 1
		cClix1 := "('"+aCliente[x]
	Else 	
		cClix1 += "','"+aCliente[x]
	EndIf
	
Next x
cClix1 += "')"



	If !cEmpAnt == '21' 
		cModTrav := ",'000028', '000029'" //tratamento de modelo pois, na Ortofio, esses modelos não são Travesseiro e sim Tecido.
	EndIf

cQuery := "SELECT SUM(PROPOSTA) AS PROPOSTA, "
cQuery += "       AGRUPA, "
cQuery += "       SUM(C6_QTDVEN) AS VENDA, "
cQuery += "       SUM(C6_UNSVEN) AS VENDA2UN, "
cQuery += "       SUM(ZZE_QUANT) AS ZZE_QUANT, "
cQuery += "       SUM(TRIMESTRE) AS TRIMESTRE , "
cQuery += "       SUM(VENDANOANT) AS  VENDANOANT "
cQuery += "FROM ( "

cQuery += "SELECT 0 AS PROPOSTA, "
cQuery += "CASE WHEN B1_XMODELO IN ('000002','000003','000004','000005') THEN '1' "
cQuery += "WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CONJUG%' THEN '1' "
cQuery += "WHEN B1_XMODELO IN ('000001','000021') THEN '2' "
cQuery += "WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CABECE%' THEN '3' "
cQuery += "WHEN B1_XMODELO IN ('000006','000017','000019','000028','000029') THEN '4' "
cQuery += "WHEN B1_XMODELO IN ('000008','000009','000010','000011','000012','000013','000018') THEN '5' WHEN B1_TIPO = 'PA' AND B1_GRUPO IN ('2343','2344','2345','2353','3530','3637','5020','5070','6644','6645') THEN '6' WHEN B1_XMODELO IN ('000014') THEN '7' WHEN B1_XMODELO IN ('000022','000023','000024','000025','000026','000027','000028','000033','000034','000035','000036','000037','000038','000039','000040','000041','000042','000043','000123','000124','000125','000126','000127','000128','000129','000130','000131','000132','000133','000134','000135','000136','000137','000138','000139','000140','000141','000142','000143','000145','000146','000148','001023','001024','001025','001026','001027','001028','001123','001124','001125','001126','001127','001128','001129','001130','001131','001144','001147') THEN '9' WHEN SUBSTR(B1_XMODELO,1,2)='24' THEN '9' END AS AGRUPA, "
cQuery += "0 AS C6_QTDVEN, "
cQuery += "C6_UNSVEN, "
cQuery += "0 AS ZZE_QUANT, "
cQuery += "0 AS TRIMESTRE, "
cQuery += "CASE WHEN B1_XMODELO IN ('000008','000009','000010','000012','000018') THEN C6_QTDVEN * B1_PESO WHEN SUBSTR(B1_XMODELO,1,2) = '24' AND B1_XMODELO <> '240007' THEN C6_UNSVEN ELSE C6_QTDVEN "
cQuery += "END  VENDANOANT "

cQuery += " FROM " + RetSQLName("SC5") + " C5 ," + RetSQLName("SC6") + " C6 , " + RetSQLName("SB1") + " B1 , " + RetSQLName("SA3") + " A3 , " + RetSQLName("SA3") + " A3GER , " + RetSQLName("SZH") + " ZH "
cQuery += " WHERE  C5.D_E_L_E_T_ = ' ' "
cQuery += " AND C6.D_E_L_E_T_ = ' ' "
cQuery += " AND B1.D_E_L_E_T_ = ' ' "
cQuery += " AND A3.D_E_L_E_T_ = ' ' "
cQuery += " AND A3GER.D_E_L_E_T_(+) = ' ' "
cQuery += " AND ZH.D_E_L_E_T_ = ' ' "
cQuery += "           AND C5_FILIAL          = '"+xFilial("SC5")+"'                                                     "
cQuery += "           AND C6_FILIAL          = '"+xFilial("SC6")+"'                                                     "
cQuery += "           AND B1_FILIAL          = '"+xFilial("SB1")+"'                                                     "
cQuery += "           AND A3.A3_FILIAL       = '"+xFilial("SA3")+"'                                                     "
cQuery += "           AND A3GER.A3_FILIAL(+) = '"+xFilial("SA3")+"'                                                     "
cQuery += "           AND ZH_FILIAL          = '"+xFilial("SZH")+"'    

cQuery += " AND C5_NUM = C6_NUM "
cQuery += " AND C5_CLIENTE = C6_CLI "
cQuery += " AND C5_LOJACLI = C6_LOJA "
cQuery += " AND B1_COD = C6_PRODUTO "
cQuery += "AND C5_CLIENTE = ZH_CLIENTE "
cQuery += " AND C5_LOJACLI = ZH_LOJA "
cQuery += " AND C5_XTPSEGM = ZH_SEGMENT "
cQuery += " AND A3.A3_COD = C5_VEND1 "
cQuery += " AND A3.A3_GEREN = A3GER.A3_COD(+) "
cQuery += " AND C5_XTPSEGM IN ('1', '2', '5', '6') "
cQuery += " AND C5_XOPER IN ('01', '14') "
cQuery += "           AND C5_EMISSAO      BETWEEN '"+DtoS(dDtIni)+"' AND '"+DtoS(dDtFim)+"'                         "
cQuery += " AND C5_NOTA <> ' ' "
cQuery += "       AND C5_CLIENTE in  "+cClix1                                                                                "


cQuery += " UNION  "
 
cQuery += "SELECT SUM(PROPOSTA) AS PROPOSTA,AGRUPA,SUM(C6_QTDVEN) AS VENDA,SUM(C6_UNSVEN) AS C6_UNSVEN,SUM(ZZE_QUANT) AS ZZE_QUANT,SUM(TRIMESTRE) AS TRIMESTRE ,SUM(VENDANOANT) AS VENDANOANT "
cQuery += "FROM ( "
 
cQuery += " SELECT C6_QTDVEN AS PROPOSTA, "
cQuery += "        CASE WHEN B1_XMODELO IN ('000002','000003','000004','000005') "
cQuery += "             THEN '1' "
cQuery += "             WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CONJUG%' "
cQuery += "             THEN '1' "
cQuery += "             WHEN B1_XMODELO IN ('000001','000021') "
cQuery += "             THEN '2' "
cQuery += "             WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CABECE%' "
cQuery += "             THEN '3' "
cQuery += "             WHEN B1_XMODELO IN ('000006','000017','000019','000028','000029') "
cQuery += "             THEN '4' "
cQuery += "             WHEN B1_XMODELO IN ('000008','000009','000010','000011','000012','000013','000018') "
cQuery += "             THEN '5' "
cQuery += "             WHEN B1_TIPO = 'PA' AND B1_GRUPO IN ('2343','2344','2345','2353','3530','3637','5020','5070','6644','6645') "
cQuery += "             THEN '6' "
cQuery += "             WHEN B1_XMODELO IN ('000014') "
cQuery += "             THEN '7' "
cQuery += "             WHEN B1_XMODELO IN ('000022','000023','000024','000025','000026','000027','000028','000033','000034','000035','000036','000037','000038','000039','000040','000041','000042','000043','000123','000124','000125','000126','000127','000128','000129','000130','000131','000132','000133','000134','000135','000136','000137','000138','000139','000140','000141','000142','000143','000145','000146','000148','001023','001024','001025','001026','001027','001028','001123','001124','001125','001126','001127','001128','001129','001130','001131','001144','001147') "
cQuery += "             THEN '9' "
cQuery += "             WHEN SUBSTR(B1_XMODELO,1,2)='24' "
cQuery += "             THEN '9' "
cQuery += "             ELSE 'X' "
cQuery += "             END AS AGRUPA, "
cQuery += " 0 AS  C6_QTDVEN, "
cQuery += " 0 AS C6_UNSVEN, "
cQuery += " 0 AS ZZE_QUANT, "
cQuery += " 0 AS TRIMESTRE , "
cQuery += " 0 AS VENDANOANT "
cQuery += " FROM " + RetSQLName("SC5") + " C5 ," + RetSQLName("SC6") + " C6 , " + RetSQLName("SB1") + " B1 , " + RetSQLName("SA3") + " A3 , " + RetSQLName("SA3") + " A3GER , " + RetSQLName("SZH") + " ZH "
cQuery += " WHERE  C5.D_E_L_E_T_ = ' ' "
cQuery += " AND C6.D_E_L_E_T_ = ' ' "
cQuery += " AND B1.D_E_L_E_T_ = ' ' "
cQuery += " AND A3.D_E_L_E_T_ = ' ' "
cQuery += " AND A3GER.D_E_L_E_T_(+) = ' ' "
cQuery += " AND ZH.D_E_L_E_T_ = ' ' "
cQuery += "           AND C5_FILIAL          = '"+xFilial("SC5")+"'                                                     "
cQuery += "           AND C6_FILIAL          = '"+xFilial("SC6")+"'                                                     "
cQuery += "           AND B1_FILIAL          = '"+xFilial("SB1")+"'                                                     "
cQuery += "           AND A3.A3_FILIAL       = '"+xFilial("SA3")+"'                                                     "
cQuery += "           AND A3GER.A3_FILIAL(+) = '"+xFilial("SA3")+"'                                                     "
cQuery += "           AND ZH_FILIAL          = '"+xFilial("SZH")+"'    


cQuery += " AND C5_NUM = C6_NUM "
cQuery += " AND C5_CLIENTE = C6_CLI "
cQuery += " AND C5_LOJACLI = C6_LOJA "
cQuery += " AND B1_COD = C6_PRODUTO "
cQuery += " AND C5_CLIENTE = ZH_CLIENTE "
cQuery += " AND C5_LOJACLI = ZH_LOJA "
cQuery += " AND C5_XTPSEGM = ZH_SEGMENT "
cQuery += " AND A3.A3_COD = C5_VEND1 "
cQuery += " AND A3.A3_GEREN = A3GER.A3_COD(+) "
cQuery += " AND C5_XTPSEGM IN ('1', '2', '5', '6') "
cQuery += "           AND C5_NUM 	IN "+cPedPro 
cQuery += "       AND C5_CLIENTE in  "+cClix1

cQuery += " )DADOS "
cQuery += "   GROUP BY AGRUPA  "

     
cQuery += "  UNION "
  
cQuery += "   SELECT 0 AS PROPOSTA,CASE WHEN B1_XMODELO IN ('000002','000003','000004','000005') THEN '1' WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CONJUG%' THEN '1' WHEN B1_XMODELO IN ('000001','000021') THEN '2' WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CABECE%' THEN '3' WHEN B1_XMODELO IN ('000006','000017','000019','000028','000029') THEN '4' WHEN B1_XMODELO IN ('000008','000009','000010','000011','000012','000018') THEN '5' WHEN B1_TIPO = 'PA' AND B1_GRUPO IN ('2343','2344','2345','2353','3530','3637','5020','5070','6644','6645') THEN '6' WHEN B1_XMODELO IN ('000014') THEN '7' WHEN B1_XMODELO IN ('000022','000023','000024','000025','000026','000027','000028','000033','000034','000035','000036','000037','000038','000039','000040','000041','000042','000043','000123','000124','000125','000126','000127','000128','000129','000130','000131','000132','000133','000134','000135','000136','000137','000138','000139','000140','000141','000142','000143','000145','000146','000148','001023','001024','001025','001026','001027','001028','001123','001124','001125','001126','001127','001128','001129','001130','001131','001144','001147') THEN '9' WHEN SUBSTR(B1_XMODELO,1,2)='24' THEN '9' END AS AGRUPA, "
cQuery += "   CASE WHEN B1_XMODELO IN ('000008','000009','000010','000011','000012','000013','000018') THEN C6_QTDVEN * B1_PESO WHEN SUBSTR(B1_XMODELO,1,2) = '24' AND B1_XMODELO <> '240007' THEN C6_UNSVEN ELSE C6_QTDVEN "
cQuery += "   END C6_QTDVEN, "
cQuery += "   C6_UNSVEN, "
cQuery += "   0 AS ZZE_QUANT, "
cQuery += "   C6_QTDVEN AS TRIMESTRE, "
cQuery += "   0 AS VENDANOANT "
cQuery += " FROM " + RetSQLName("SC5") + " C5 ," + RetSQLName("SC6") + " C6 , " + RetSQLName("SB1") + " B1 , " + RetSQLName("SA3") + " A3 , " + RetSQLName("SA3") + " A3GER , " + RetSQLName("SZH") + " ZH "

cQuery += "    WHERE  C5.D_E_L_E_T_ = ' ' "
cQuery += "    AND C6.D_E_L_E_T_ = ' ' "
cQuery += "    AND B1.D_E_L_E_T_ = ' ' "
cQuery += "    AND A3.D_E_L_E_T_ = ' ' "
cQuery += "    AND A3GER.D_E_L_E_T_(+) = ' ' "
cQuery += "    AND ZH.D_E_L_E_T_ = ' ' "
cQuery += "           AND C5_FILIAL          = '"+xFilial("SC5")+"'                                                     "
cQuery += "           AND C6_FILIAL          = '"+xFilial("SC6")+"'                                                     "
cQuery += "           AND B1_FILIAL          = '"+xFilial("SB1")+"'                                                     "
cQuery += "           AND A3.A3_FILIAL       = '"+xFilial("SA3")+"'                                                     "
cQuery += "           AND A3GER.A3_FILIAL(+) = '"+xFilial("SA3")+"'                                                     "
cQuery += "           AND ZH_FILIAL          = '"+xFilial("SZH")+"'    
cQuery += "    AND C5_NUM = C6_NUM "
cQuery += "    AND C5_CLIENTE = C6_CLI "
cQuery += "    AND C5_LOJACLI = C6_LOJA "
cQuery += "    AND B1_COD = C6_PRODUTO "
cQuery += "    AND C5_CLIENTE = ZH_CLIENTE "
cQuery += "    AND C5_LOJACLI = ZH_LOJA "
cQuery += "    AND C5_XTPSEGM = ZH_SEGMENT "
cQuery += "    AND A3.A3_COD = C5_VEND1 "
cQuery += "    AND A3.A3_GEREN = A3GER.A3_COD(+) "
cQuery += "    AND C5_XTPSEGM IN ('1', '2', '5', '6') "
cQuery += "    AND C5_XOPER IN ('01', '14') "

nDIAS 		:= FIRSTDAY(ddatabase)-1
NDIASpE1 	:= NDIAS -90
nDiasPer	:= FIRSTDAY(NDIASpE1)

cQuery += "           AND C5_EMISSAO      BETWEEN '"+DtoS(NDIASpER)+"' AND '"+DtoS(nDIAS)+"'                         "

cQuery += "    AND C5_NOTA <> ' ' "
cQuery += "       AND C5_CLIENTE in "+cClix1   
cQuery += "    UNION  "
    
cQuery += "    SELECT PROPOSTA,AGRUPA,C6_QTDVEN,C6_UNSVEN,ZZE_QUANT,0 AS TRIMESTRE, 0 AS VENDANOANT "
cQuery += "    FROM ( "
cQuery += "          SELECT 0 AS PROPOSTA, "
cQuery += "          ZZE_AGRUPA AS AGRUPA, "
cQuery += "          0 AS C6_QTDVEN, "
cQuery += "          0 AS C6_UNSVEN, "
cQuery += "          SUM(ZZE_QUANT) ZZE_QUANT, "
cQuery += "          0 AS TRIMESTRE , "
cQuery += "          0 AS VENDANOANT "
cQuery += " FROM " + RetSQLName("ZZE") + " ZZE ," + RetSQLName("SZH") + " ZH , " + RetSQLName("SA3") + " A3 , " + RetSQLName("SA3") + " A3GER , " + RetSQLName("SA1") + " A1 "
cQuery += "          WHERE  ZZE.D_E_L_E_T_ = ' ' "
cQuery += "          AND ZH.D_E_L_E_T_ = ' ' "
cQuery += "          AND A1.D_E_L_E_T_ = ' ' "
cQuery += "          AND ZZE_FILIAL = '  ' "
cQuery += "          AND ZH_FILIAL = '  ' "
cQuery += "          AND A1_FILIAL = '  ' "
cQuery += "          AND A3.A3_FILIAL = '  ' "
cQuery += "          AND A3GER.A3_FILIAL(+) = '  ' "
cQuery += "          AND ZZE_CODCLI = ZH_CLIENTE "
cQuery += "          AND A1_COD = ZH_CLIENTE "
cQuery += "          AND A1_MSBLQL != '1' "
cQuery += "          AND A3.D_E_L_E_T_ = ' ' "
cQuery += "          AND A3GER.D_E_L_E_T_(+) = ' ' "
cQuery += "          AND A3.A3_COD = ZH_VEND "
cQuery += "          AND A3.A3_GEREN = A3GER.A3_COD(+) "
cQuery += "       AND A1_COD in  "+cClix1   
cQuery += "    GROUP BY  ZZE_AGRUPA "
cQuery += "    )   "
    
cQuery += "     ) "
cQuery += "    WHERE  AGRUPA IS NOT NULL "
cQuery += "    GROUP BY AGRUPA  ORDER BY  AGRUPA "


	cQuery := ChangeQuery(cQuery)

	memowrite("C:\ORTR727_det.SQL",cQuery)

	If Select("QRY") > 0
		dbSelectArea("QRY")
		QRY->(DbCloseArea())
	EndIf


	TcQuery cQuery Alias "QRY" New


	QRY->(dbGoTop())

	_cAgrIn 	:= ""


	While !QRY->(EOF())
		oPrinter:Box(nLin,0175,nLin+nEsp,0408)
		oPrinter:Box(nLin,0408,nLin+nEsp,0739)
		oPrinter:Box(nLin,0739,nLin+nEsp,1110)
		oPrinter:Box(nLin,1110,nLin+nEsp,1411)


		If !(AllTrim("'" + QRY->AGRUPA + "',") $ _cAgrIn)
			_cAgrIn += "'" + QRY->AGRUPA + "'," 
		EndIf

		_cAgrupa := fNomeAgr(QRY->AGRUPA)

		oPrinter:Say(nLin+nEsp*0.7,0231,AllTrim(_cAgrupa)     					,oTim10N,,0)
		oPrinter:Say(nLin+nEsp*0.7,0434,AllTrim(Str(Round(qry->zze_quant,2))) 	,oTim10N,,0)
		oPrinter:Say(nLin+nEsp*0.7,0783,AllTrim(Str(Round(QRY->TRIMESTRE,2)))	,oTim10N,,0)
		oPrinter:Say(nLin+nEsp*0.7,1160,AllTrim(Str(Round(QRY->PROPOSTA,2)))	,oTim10N,,0)

		nLin+=nEsp
		QRY->(DbSkip())

	End


return()

***********************************
Static Function fNomeAgr(_cCodAgr) 
***********************************
	Do Case 
		Case _cCodAgr = '1'
		_cAgrupa := "Colchão"
		Case _cCodAgr = '2'
		_cAgrupa := "Base"
		Case _cCodAgr = '3'
		_cAgrupa := "Cabeceira"
		Case _cCodAgr = '4'
		_cAgrupa := "Travesseiro"
		Case _cCodAgr = '5'
		_cAgrupa := "Espuma"
		Case _cCodAgr = '6'
		_cAgrupa := "Tecido"
		Case _cCodAgr = '7'
		_cAgrupa := "Manta"
		Case _cCodAgr = '8'
		_cAgrupa := "Mola"
		Case _cCodAgr = '9'
		_cAgrupa := "Plastico"
		Case _cCodAgr = 'X'
		_cAgrupa := "Outros"		
	EndCase

Return(_cAgrupa)

/********************************************************************************************/
/* FUNCAO PARE RETORNARA A MEDIA DE COMPRA MENSAL ANO ANTERIOR DO GRUPO DO CLIENTE          */
/********************************************************************************************/
******************************************
STATIC FUNCTION FMANOP(CDATA,CCLI,CLOJA)
******************************************

LOCAL CQUERY	:= ""
Local dEmissao	:= ""
Local nX		:= 0
Local dDia		:= CToD('  /  /  ')
Local dTriDe	:= CToD('  /  /  ')
Local dTriAte	:= CToD('  /  /  ')
Local dCurDe	:= CToD('  /  /  ')
Local dCurAte	:= CToD('  /  /  ')
Local dMesDe	:= CToD('  /  /  ')
Local dMesAte	:= CToD('  /  /  ')
Local aRet		:= {}

dDia	:= CDATA-365
dMesDe	:= FirstDay(dDia)
dMesAte	:= LastDay(dDia)// - 1

cQuery	:= " SELECT SA1.A1_XCODGRU,         
cQuery	+= "        SUM(CASE               
cQuery	+= "               WHEN C5_EMISSAO BETWEEN '"+DToS(dMesDe)+"' AND '"+DToS(dMesAte)+"' "
cQuery	+= "                    AND C5_XOPER <> '05' 
cQuery	+= "                THEN (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5               
cQuery	+= "                ELSE                0             END) AS TRIM_VL,         
cQuery	+= "         SUM(CASE               
cQuery	+= "                WHEN C5_EMISSAO BETWEEN '"+DToS(dMesDe)+"' AND '"+DToS(dMesAte)+"' " 
cQuery	+= "                     AND C5_XOPER <> '05' 
cQuery	+= "                THEN (((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * ((C6_XPRUNIT) * (100 - (C5_XVERREP + C5_XVEREXT) ) / 100))-C6_XFEILOJ) / M2_MOEDA5               
cQuery	+= "                ELSE 0             END) AS TRIM_MIX,         
cQuery	+= "         SUM(CASE               
cQuery	+= "                WHEN C5_EMISSAO BETWEEN '"+DToS(dMesDe)+"' AND '"+DToS(dMesAte)+"' "
cQuery	+= "                THEN (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5               
cQuery	+= "                ELSE 0             END) AS TRIM_CUSTO

cQuery	+= "   FROM "+RetSqlName("SC5")+" SC5, "
cQuery	+= "        "+RetSqlName("SC6")+" SC6, "
cQuery	+= "        "+RetSqlName("SA1")+" SA1, "
cQuery	+= "        "+RetSqlName("SA1")+" GRU, "
cQuery	+= "        "+RetSqlName("SM2")+" SM2, "
cQuery	+= "        "+RetSqlName("SD2")+" SD2, "
cQuery	+= "        "+RetSqlName("SZH")+" SZH "

cQuery	+= "       WHERE SC5.D_E_L_E_T_ 	= ' '     
cQuery	+= "       AND SC6.D_E_L_E_T_ 		= ' '     
cQuery	+= "       AND SA1.D_E_L_E_T_ 		= ' '     
cQuery	+= "       AND SD2.D_E_L_E_T_(+) 	= ' '     
cQuery	+= "       AND GRU.D_E_L_E_T_ 		= ' '     
cQuery	+= "       AND SM2.D_E_L_E_T_ 		= ' '     
cQuery	+= "       AND SZH.D_E_L_E_T_ 		= ' '     

cQuery	+= "    AND SC5.C5_FILIAL 		= '"+xFilial("SC5")+"' "
cQuery	+= "    AND C6_FILIAL 			= '"+xFilial("SC6")+"' "
cQuery	+= "    AND SA1.A1_FILIAL 		= '"+xFilial("SA1")+"' "
cQuery	+= "    AND SD2.D2_FILIAL(+) 	= '"+xFilial("SD2")+"' "
cQuery	+= "    AND GRU.A1_FILIAL 		= '"+xFilial("SA1")+"' "
cQuery	+= "    AND SZH.ZH_FILIAL 		= '"+xFilial("SZH")+"' "



cQuery	+= "       AND SC5.C5_NUM 			= C6_NUM     
cQuery	+= "       AND SC5.C5_CLIENTE 		= GRU.A1_COD     
cQuery	+= "       AND SC5.C5_LOJACLI 		= GRU.A1_LOJA     
cQuery	+= "       AND GRU.A1_XCODGRU 		= SA1.A1_XCODGRU     
cQuery	+= "       AND SA1.A1_XCODGRU 		= '"+CCLI+"' "
cQuery	+= "       AND GRU.A1_COD 			= SA1.A1_COD     
cQuery	+= "       AND GRU.A1_LOJA 			= SA1.A1_LOJA     
cQuery	+= "       AND SA1.A1_LOJA 			= '01'     
cQuery	+= "       AND D2_PEDIDO(+) 		= C6_NUM     
cQuery	+= "       AND D2_ITEM(+) 			= C6_ITEM     
cQuery	+= "       AND D2_COD(+) 			= C6_PRODUTO     
cQuery	+= "       AND SC5.C5_XOPER 		IN ('01', '04', '05', '10', '11', '14','15', '16', '20', '21', '19', '26', '27', '23')     
cQuery	+= "       AND SC5.C5_XTPSEGM 		IN ('1', '2', '5', '6')     
cQuery	+= "       AND C5_EMISSAO 			BETWEEN '"+DToS(dMesDe)+"' AND '"+DToS(dMesAte)+"' "
cQuery	+= "       AND SC5.C5_XOPERAN 		<> '99'     
cQuery	+= "       AND SC5.C5_XMOTCAN 		IN ('98', '  ')     
cQuery	+= "       AND SZH.ZH_CLIENTE 		= SC5.C5_CLIENTE     
cQuery	+= "       AND SZH.ZH_LOJA 			= SC5.C5_LOJACLI     
cQuery	+= "       AND SZH.ZH_VEND 			= SC5.C5_VEND1     
cQuery	+= "       AND SZH.ZH_SEGMENT 		= SC5.C5_XTPSEGM     
cQuery	+= "       AND M2_DATA 				= SC5.C5_EMISSAO     
cQuery	+= "       AND M2_MOEDA5 			> 0   
cQuery	+= "       GROUP BY SA1.A1_XCODGRU   
cQuery	+= "       ORDER BY 1




U_ORTQUERY(cQuery, "ORTR020_PA")

dbSelectArea("ORTR020_PA")

aAdd(aRet,0)
aAdd(aRet,0)

If !(ORTR020_PA->(EOF()))
	
	nMixAMes := U_OR16BCLB(ORTR020_PA->TRIM_MIX , ORTR020_PA->TRIM_CUSTO   )
	
	
	aRet[01]:= nMixAMes
	aRet[02]:= Round(ORTR020_PA->TRIM_VL, 2)
	
	
	nMAMes  :=aRet[01]
	nUpAmeM :=aRet[02]
	

	
EndIf

ORTR020_PA->(dbCloseArea())
dbSelectArea("SC5")

Return(aRet)
