#include "rwmake.ch"
#include "topconn.ch"
#include "sigawin.ch"
#include "tbiconn.ch"
#include "PROTHEUS.CH"
#include "font.ch"
#Include 'DBTREE.CH'
#include "Fileio.ch"
#include "colors.ch"
#INCLUDE "JPEG.CH"

#define K_F12    123
#Define	 ENTER CHR(13) + CHR(10)

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ORTP002   ∫ Autor ≥ Cesar Dupim        ∫ Data ≥  02/04/06   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫DescriáÑo ≥ Programa para geraÁ„o de embarque                          ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Arquivo MKW: dupim.MKW

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ORTA642   ∫ Autor ≥ M·rcio Sobreira    ∫ Data ≥  13/03/2018 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Ajusta Dados do Pedido de origem (Pela ImportaÁ„o) 		  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Faturamento				                                  ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/


User Function ORTP002

//PREPARE ENVIRONMENT EMPRESA '03' FILIAL '02'

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Declaracao de Variaveis                                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Private aTabPAP	 := {}
Private oOrigem  :=Nil
Private aOrigem  :={{"","","","",0,"",""}}
Private cOrigem  :=""
Private oRemessa :=Nil
//Private aRemessa :={{"","","","",0}}
Private aRemessa :={{"","","","",0,"","",""}}

Private cRemessa :=""
Private oConfere :=Nil
Private aConfere :={{"","","","",0,"",""}}
Private cConfere :=""
Private oPonto   :=Nil
Private aPonto   :={{"",0,"",0,"",0}}
Private cPonto   :=""
Private nValTot  :=0
Private nValTp   :=0
Private nValRem  :=0
Private nValConf :=0
Private nValPRem :=0
Private nValPConf:=0
Private cMotCrgEx := Space(250)
Private oValTot  :=Nil
Private oValRem  :=Nil
Private oEmbComp :=Nil
Private oValConf :=Nil
Private oXEMBMAE :=Nil
Private oMotCrgEx := Nil

Private nEspCam  	:=0  //espaco caminhao
Private nEspTot  	:=0
Private nEspRem  	:=0
Private nEspConf 	:=0
Private nEspPRem 	:=0
Private nEspPConf	:=	0
Private oEspCam  	:=Nil //espaco caminhao
Private oEspTot  	:=Nil
Private oEspRem  	:=Nil
Private oEspConf 	:=Nil
Private oRem     	:=Nil
Private cRem     	:=space(6)
Private oRem2    	:=Nil
Private cRem2    	:=space(7)
Private oConf    	:=Nil
Private cConf    	:=space(6)
Private oConf2   	:=Nil
Private cConf2   	:=space(7)
Private oRemove  	:=Nil
Private cRemove  	:=space(7)

Private cEmb     	:="000000"
Private nEmbTp      :=300000
Private dPreve   	:=ctod("  /  /  ")
Private lVisu    	:=.F.
Private lIncEmb  	:=.F.
Private lAltEmb  	:=.F.
Private	aCab     	:= {"Pedido","Cliente","Loja","Nome", "EspaÁo p/ Emb.","Roteiro" }
Private aRotina  	:= {}
Private cordemb 	:= "0000"
Private cordemb6 	:= "0000"

//Variaveis da Tela para informaÁıes de Frete.
Private aResiduo	:= {"Nao","Sim"}            // Cleverson
Private cPeds   	:= ""
Private cCodArea	:= Space(2)
Private cCodTrans	:= IIf(cEmpAnt=="21","M00997",Space(06))
Private cNomTrans	:= Space(25)
Private cResiduo
Private nValAdiat	:= 0
Private nValFret	:= 0
Private nValFret2	:= 0
//Private nPercTot	:= 0
Private nPercTot2	:= 0
Private nKilomet	:= 0
Private nPerFret	:= 0
Private nValKm	 	:= 0
Private nValSAC	 	:= 0
Private oCodArea
Private oCodTrans
Private oValAdiant
Private oValFret
Private oValFret2
Private oNomTrans
//Private oPercTot
Private oPercTot2
Private oKilomet
Private oPerFret
Private oValKm
Private oValSAC
Private _oObs
Private _cObs := space(250)
Private nPedSAC 	:= 	0
Private nTotSAC 	:= 	0
Private nCTotSAC    :=	0
Private nValFretN	:= 0
Private nPercTotN	:= 0
Private _nTotPedN	:= 0
//Private aItems := {"Normal.","Residuo","Complementar"}
Private aItems 	:= 	{}
Private aItems1	:=	{}
Private aItems2 :=  {}
Private cCombo 	:= 	"Normal"
Private cCombo1	:=	"COLCHAO"
Private cXEMBMAE := space(6)
Private _ctabc5 := retsqlname("SC5")
Private _ctabc6 := retsqlname("SC6")
Private cPerg   :="ORTP02AB"
Private __aExc	:=	{}
Private __nTp
Private __cLocPID  	:=  GetNewPar("MV_XLOCPID","05")
Private __cLocNPID 	:=  GetNewPar("MV_XLOCNPD","15")
Private __cLocPed	:=	GetNewPar("MV_XLOCPED","30")
Private cTpPgt   	:=	GetNewPar("MV_XTPVAL ","  ")
Private oNRepor
Private	lRepor	:=	.F.
Private	lRep	:=	.F.
Private cEmbComp:=	Space(6)
Private _aPedRet	:=	{}
Private _lPW		:=	.T.
Private _aPdRet		:=	{}
Private oCKilomet
Private nCKilomet	:=	0
Private oCValKm
Private nCValKm		:=	0
Private	oCValSac
Private	nCValSac	:=	0
Private oCValFret
Private nCValFret	:=	0
Private oCValFret2
Private nCValFret2	:=	0
Private oCPercTot2
Private nCPercTot2	:=	0
Private nCPerfret	:=	0
Private oTpVal      :=Nil
Private lTpVal      :=.F.
Private nBlqCarga 	:= 0
Private cPedCarga := ""
Private cEmpBlq := "03|05|06" // EMPRESAS PARA SEREM BLOQUEADAS NA PROGRAMACAO (T/B/S)


Private cfilemp         := substr(cNumEmp,1,2) //+"0" // cfilant+"0"

if cEmpAnt=="03"
	nEmbTp:=200000
endif

If u_IsBalanco()
   Return
Endif

ValidPerg(cPerg)

IF CEMPANT $ cEmpBlq
	aRotina  := {{"Pesquisar" 	 ,"AxPesqui" ,0,1},;
	{"Visualizar"	 ,"U_VisEmb" ,0,2},;
	{"Incluir"   	 ,"U_IncEmb" ,0,3},;
	{"Alterar"   	 ,"U_AltEmb" ,0,4},;
	{"1) Ver. Ped T/B/S"	 ,"U_VerPedTBS" ,0,4},;
	{"2) Lib. Ped T/B/S"	 ,"U_LibPedTBS" ,0,4},;
	{"3) Liberar Carga"	 ,"U_LibCarga" ,0,4}}
	AADD(aRotina,{"Excluir" ,"U_ExcEmb" ,0,5})
ELSE
	aRotina  := {{"Pesquisar" 	 ,"AxPesqui" ,0,1},;
	{"Visualizar"	 ,"U_VisEmb" ,0,2},;
	{"Incluir"   	 ,"U_IncEmb" ,0,3},;
	{"Alterar"   	 ,"U_AltEmb" ,0,4},;
	{"Liberar Carga"	 ,"U_LibCarga" ,0,4}}
	AADD(aRotina,{"Excluir" ,"U_ExcEmb" ,0,5})
ENDIF


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Criacao da Interface                                                ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
***********************************************************************
//PREPARE ENVIRONMENT EMPRESA "03" FILIAL "02" TABLES "SC5SC6SZQ"
***********************************************************************

dbSelectArea("SZQ")
dbOrderNickName("CSZQ1")

dbSelectArea("SZQ")
mBrowse(6,1,22,75,"SZQ")

Return
***************************
User Function VisEmb()
***************************

Local 	__cPed	:=	""

cMotCrgEx	:=Space(250)

lRepor	:=	.F.

//aItems := {"Normal","Residuo","Complementar","Extra","Acrilica","Bono","SAC"}
aItems := {"Normal","Residuo","Complementar","Extra","SAC"}

DbSelectArea("SX5")
dbOrderNickName("PSX51")

If	MsSeek(xFilial("SX5")+"PO",.F.)
	aItems1	:=	{}
	While !EOF() .AND.	X5_TABELA == "PO"
		AADD(aItems1,X5_DESCRI)
		DbSkip()
	Enddo
	
Endif

If SZQ->ZQ_XTPCAR 		== "1"
	cCombo		:= "Normal"
ElseIf SZQ->ZQ_XTPCAR 		== "2"
	cCombo		:= "Residuo"
elseif SZQ->ZQ_XTPCAR 	== "3"
	cCombo		:= "Complementar"
elseif SZQ->ZQ_XTPCAR 	== "4"
	cCombo		:= "Extra"
	cMotCrgEx	:=SZQ->ZQ_OBS
elseif SZQ->ZQ_XTPCAR 	== "5"
	cCombo  	:= "Acrilica"
elseif SZQ->ZQ_XTPCAR 	== "6"
	cCombo  	:= "Bono"
elseif SZQ->ZQ_XTPCAR 	== "7"
	cCombo 		:= "SAC"
endif

cCombo1:=Posicione("SX5",1,xFilial("SX5")+"PO"+SZQ->ZQ_TPCARGA,"X5_DESCRI")
/* RETIRADO POR DUPIM EM 17/01/2011 NAO FAZ SENTIDO SE EXISTE UMA TABELA
If	SZQ->ZQ_TPCARGA			== "C"
cCombo1	:=	"COLCHAO"
ElseIf	SZQ->ZQ_TPCARGA		==	"D"
cCombo1	:=	"DUBLADO"
ElseIf	SZQ->ZQ_TPCARGA		==	"E"
cCombo1	:=	"ESPUMA"
ElseIf	SZQ->ZQ_TPCARGA		==	"L"
cCombo1	:=	"LAMINADO"
ElseIf	SZQ->ZQ_TPCARGA		==	"M"
cCombo1	:=	"MISTO"
ElseIf	SZQ->ZQ_TPCARGA		==	"R"
cCombo1	:=	"RETIRA"
ElseIf	SZQ->ZQ_TPCARGA		==	"T"
cCombo1	:=	"TORNEADO"
ElseIf	SZQ->ZQ_TPCARGA		==	"A"
cCombo1	:=	"ALMOFADA"
ElseIf	SZQ->ZQ_TPCARGA		==	"F"
cCombo1	:=	"FIBRA"
ElseIf	SZQ->ZQ_TPCARGA		==	"N"
cCombo1	:=	"MANTA"
ElseIf	SZQ->ZQ_TPCARGA		==	"O"
cCombo1	:=	"MOLA"
ElseIf	SZQ->ZQ_TPCARGA		==	"P"
cCombo1	:=	"REFATURAMENTO"
ElseIf	SZQ->ZQ_TPCARGA		==	"V"
cCombo1	:=	"TRAVESSEIRO"
Endif
*/


Pergunte("ORTP02AB",.F.)
//aRemessa :={{"","","","",0}}
aRemessa :={{"","","","",0,"","",""}}

//aConfere :={{"","","","",0}}
aConfere :={{"","","","",0,"",""}}

lVisu:=.T.
lIncEmb:=.F.
lAltEmb:= .F.
cEmb:=SZQ->ZQ_EMBARQ
cEmbComp	:=	SZQ->ZQ_EMBCOMP
if cEmb >= "500000"
	cEmb:=StrZero(val(cEmb)-500000,6)
endif
if cEmb >= "300000"
	cEmb:=StrZero(val(cEmb)-nEmbTp,6)
endif
//cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN "
// ALTERADO POR DUPIM EM 08/06/2011 PARA COMPATIBILIZAR OS ESPACOS COM O PEDIDO DE CIRCULACAO INTERNA
cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN "
cQuery+="      C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, SA1.A1_NOME, SC5.C5_XNPVORT, "
cQuery+="      SC5.C5_XORDEMB, SC5.C5_XTPVAL, A1_XROTA "
cQuery+="FROM "+RetSqlName("SC6") +" SC6, "
cQuery+="     "+RetSqlName("SC5") +" SC5, "
cQuery+="     "+RetSqlName("SB1") +" SB1, "
cQuery+="     "+RetSqlName("SA1") +" SA1, "
cQuery+="     "+RetSqlName("SBM") +" SBM,  "
cQuery+="     "+RetSqlName("SZQ") +" SZQ  "
cQuery+="WHERE SC6.D_E_L_E_T_ <> '*' "
cQuery+="  AND SC5.D_E_L_E_T_ <> '*' "
cQuery+="  AND SB1.D_E_L_E_T_ <> '*' "
cQuery+="  AND SA1.D_E_L_E_T_ <> '*' "
cQuery+="  AND SBM.D_E_L_E_T_ <> '*' "
cQuery+="  AND SZQ.D_E_L_E_T_ <> '*' "
cQuery+="  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
cQuery+="  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
cQuery+="  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery+="  AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery+="  AND SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
cQuery+="  AND SZQ.ZQ_FILIAL = '" + xFilial("SZQ") + "' "
cQuery+="  AND SBM.BM_GRUPO = SB1.B1_GRUPO "
cQuery+="  AND SC5.C5_NUM     = SC6.C6_NUM     "
cQuery+="  AND SB1.B1_COD     = SC6.C6_PRODUTO "
cQuery+="  AND SC5.C5_CLIENTE = SC6.C6_CLI     "
cQuery+="  AND SC5.C5_LOJACLI = SC6.C6_LOJA    "
cQuery+="  AND SC5.C5_CLIENT = SA1.A1_COD     "
cQuery+="  AND SC5.C5_LOJAENT = SA1.A1_LOJA    "
cQuery+="  AND SC5.C5_XDTLIB  <>' '            "
cQuery+="  AND SC5.C5_XEMBARQ = SZQ.ZQ_EMBARQ  "
cQuery+="  AND SZQ.ZQ_EMBARQ  IN  ('"+cEmb+"','"+STRZERO(VAL(cEmb)+nEmbTp,6)+"')     "
cQuery+="  AND (SC5.C5_XOPER NOT IN ('96','99','98') OR (SC5.C5_XOPER = '14' AND SC5.C5_XUNORI <> '  ')) "
cQuery+="  AND C5_TIPO NOT IN ('B','D') "
cQuery+="  GROUP BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SA1.A1_NOME, SC5.C5_XNPVORT,SC5.C5_XORDEMB, "
cQuery+="           SC5.C5_XTPVAL, A1_XROTA "
//cQuery+="  ORDER BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA"
cQuery+="  UNION "
//cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN "
// ALTERADO POR DUPIM EM 08/06/2011 PARA COMPATIBILIZAR OS ESPACOS COM O PEDIDO DE CIRCULACAO INTERNA
cQuery+="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN "
cQuery+="       C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, SA2.A2_NOME, SC5.C5_XNPVORT,"
cQuery+="       SC5.C5_XORDEMB, SC5.C5_XTPVAL, '000000' A1_XROTA "
cQuery+="FROM "+RetSqlName("SC6") +" SC6, "
cQuery+="     "+RetSqlName("SC5") +" SC5, "
cQuery+="     "+RetSqlName("SB1") +" SB1, "
cQuery+="     "+RetSqlName("SA2") +" SA2,  "
cQuery+="     "+RetSqlName("SBM") +" SBM,  "
cQuery+="     "+RetSqlName("SZQ") +" SZQ  "
cQuery+="WHERE SC6.D_E_L_E_T_ <> '*' "
cQuery+="  AND SC5.D_E_L_E_T_ <> '*' "
cQuery+="  AND SB1.D_E_L_E_T_ <> '*' "
cQuery+="  AND SA2.D_E_L_E_T_ <> '*' "
cQuery+="  AND SA2.D_E_L_E_T_ <> '*' "
cQuery+="  AND SBM.D_E_L_E_T_ <> '*' "
cQuery+="  AND SZQ.D_E_L_E_T_ <> '*' "
cQuery+="  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
cQuery+="  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
cQuery+="  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery+="  AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
cQuery+="  AND SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
cQuery+="  AND SZQ.ZQ_FILIAL = '" + xFilial("SZQ") + "' "
cQuery+="  AND SBM.BM_GRUPO = SB1.B1_GRUPO "
cQuery+="  AND SC5.C5_NUM     = SC6.C6_NUM     "
cQuery+="  AND SB1.B1_COD     = SC6.C6_PRODUTO "
cQuery+="  AND SC5.C5_CLIENTE = SC6.C6_CLI     "
cQuery+="  AND SC5.C5_LOJACLI = SC6.C6_LOJA    "
cQuery+="  AND SC5.C5_CLIENT = SA2.A2_COD     "
cQuery+="  AND SC5.C5_LOJAENT = SA2.A2_LOJA    "
cQuery+="  AND SC5.C5_XDTLIB  <>' '            "
cQuery+="  AND SC5.C5_XEMBARQ = SZQ.ZQ_EMBARQ  "
cQuery+="  AND SZQ.ZQ_EMBARQ  IN  ('"+cEmb+"','"+STRZERO(VAL(cEmb)+nEmbTp,6)+"')     "
cQuery+="  AND (SC5.C5_XOPER NOT IN ('96','99','98') OR (SC5.C5_XOPER = '14' AND SC5.C5_XUNORI <> '  '))"
cQuery+="  AND C5_TIPO IN ('B','D') "
cQuery+="  GROUP BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SA2.A2_NOME, SC5.C5_XNPVORT,SC5.C5_XORDEMB, "
cQuery+="           SC5.C5_XTPVAL "
cQuery+="  ORDER BY C5_XORDEMB "

MEMOWRIT("C:\ortp002V.SQL",cQuery)

TCQUERY cQuery ALIAS "TRB" NEW
Dbselectarea("TRB")
if !eof()
	aRemessa:={}
endif
While !Eof()
	aadd(aRemessa,{TRB->C6_NUM,TRB->C6_CLI,TRB->C6_LOJA,TRB->A1_NOME,TRB->ESPACO,TRB->A1_XROTA,TRB->C5_XNPVORT,TRB->C5_XTPVAL})
	If	Empty(__cPed)
		__cPed:="'"+TRB->C6_NUM+"'"
	Else
		__cPed+=",'"+TRB->C6_NUM+"'"
	Endif
	
	DbSkip()
End
dbclosearea()
//cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, SA1.A1_NOME, SC5.C5_XORDEMB, SC5.C5_XNPVORT "
//alterado por dupim em 08/06/11
cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, "
cQuery+="SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, "
cQuery+="SA1.A1_NOME, SC5.C5_XORDEMB, SC5.C5_XNPVORT, A1_XROTA "
cQuery+="FROM "+RetSqlName("SC6") +" SC6, "
cQuery+="     "+RetSqlName("SC5") +" SC5, "
cQuery+="     "+RetSqlName("SB1") +" SB1, "
cQuery+="     "+RetSqlName("SA1") +" SA1,  "
cQuery+="     "+RetSqlName("SBM") +" SBM,  "
cQuery+="     "+RetSqlName("SZQ") +" SZQ  "
cQuery+="WHERE SC6.D_E_L_E_T_ <> '*' "
cQuery+="  AND SC5.D_E_L_E_T_ <> '*' "
cQuery+="  AND SB1.D_E_L_E_T_ <> '*' "
cQuery+="  AND SA1.D_E_L_E_T_ <> '*' "
cQuery+="  AND SBM.D_E_L_E_T_ <> '*' "
cQuery+="  AND SZQ.D_E_L_E_T_ <> '*' "
cQuery+="  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
cQuery+="  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
cQuery+="  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery+="  AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery+="  AND SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
cQuery+="  AND SZQ.ZQ_FILIAL = '" + xFilial("SZQ") + "' "
cQuery+="  AND SBM.BM_GRUPO = SB1.B1_GRUPO "
cQuery+="  AND SC5.C5_NUM     = SC6.C6_NUM     "
cQuery+="  AND SB1.B1_COD     = SC6.C6_PRODUTO "
cQuery+="  AND SC5.C5_CLIENTE = SC6.C6_CLI     "
cQuery+="  AND SC5.C5_LOJACLI = SC6.C6_LOJA    "
cQuery+="  AND SC5.C5_CLIENT = SA1.A1_COD     "
cQuery+="  AND SC5.C5_LOJAENT = SA1.A1_LOJA    "
cQuery+="  AND SC5.C5_XDTLIB  <>' '            "
cQuery+="  AND SC5.C5_XEMBARQ = SZQ.ZQ_EMBARQ  "
cQuery+="  AND (SC5.C5_XOPER NOT IN ('96','99','98') OR (SC5.C5_XOPER = '14' AND SC5.C5_XUNORI <> '  ')) "
cQuery+="  AND SZQ.ZQ_EMBARQ = '"+Strzero(val(cEmb)+500000,6)+"'     "
cQuery+="  AND C5_TIPO NOT IN ('B','D') "
cQuery+="  GROUP BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SA1.A1_NOME, SC5.C5_XNPVORT,SC5.C5_XORDEMB, A1_XROTA "
cQuery+="UNION "
//cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, SA1.A1_NOME, SC5.C5_XORDEMB, SC5.C5_XNPVORT "
//alterado por dupim em 08/06/11
cQuery+="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, "
cQuery+="SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, "
cQuery+="SA2.A2_NOME, SC5.C5_XORDEMB, SC5.C5_XNPVORT, '000000' A1_XROTA "
cQuery+="FROM "+RetSqlName("SC6") +" SC6, "
cQuery+="     "+RetSqlName("SC5") +" SC5, "
cQuery+="     "+RetSqlName("SB1") +" SB1, "
cQuery+="     "+RetSqlName("SA2") +" SA2,  "
cQuery+="     "+RetSqlName("SBM") +" SBM,  "
cQuery+="     "+RetSqlName("SZQ") +" SZQ  "
cQuery+="WHERE SC6.D_E_L_E_T_ <> '*' "
cQuery+="  AND SC5.D_E_L_E_T_ <> '*' "
cQuery+="  AND SB1.D_E_L_E_T_ <> '*' "
cQuery+="  AND SA2.D_E_L_E_T_ <> '*' "
cQuery+="  AND SBM.D_E_L_E_T_ <> '*' "
cQuery+="  AND SZQ.D_E_L_E_T_ <> '*' "
cQuery+="  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
cQuery+="  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
cQuery+="  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQuery+="  AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
cQuery+="  AND SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
cQuery+="  AND SZQ.ZQ_FILIAL = '" + xFilial("SZQ") + "' "
cQuery+="  AND SBM.BM_GRUPO   = SB1.B1_GRUPO     "
cQuery+="  AND SC5.C5_NUM     = SC6.C6_NUM     "
cQuery+="  AND SB1.B1_COD     = SC6.C6_PRODUTO "
cQuery+="  AND SC5.C5_CLIENTE = SC6.C6_CLI     "
cQuery+="  AND SC5.C5_LOJACLI = SC6.C6_LOJA    "
cQuery+="  AND SC5.C5_CLIENTE = SA2.A2_COD     "
cQuery+="  AND SC5.C5_LOJACLI = SA2.A2_LOJA    "
cQuery+="  AND SC5.C5_XDTLIB  <> ' ' "
cQuery+="  AND SC5.C5_XEMBARQ = SZQ.ZQ_EMBARQ  "
cQuery+="  AND (SC5.C5_XOPER NOT IN ('96','99','98') OR (SC5.C5_XOPER = '14' AND SC5.C5_XUNORI <> '  ')) "
cQuery+="  AND SZQ.ZQ_EMBARQ = '"+strzero(val(cEmb)+500000,6)+"' "
cQuery+="  AND C5_TIPO IN ('B','D') "
cQuery+="  GROUP BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SA2.A2_NOME, SC5.C5_XNPVORT,SC5.C5_XORDEMB "

//cQuery+="  ORDER BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA"
cQuery+="  ORDER BY C5_XORDEMB"

MEMOWRIT("C:\ortp002v2.SQL",cQuery)

TCQUERY cQuery ALIAS "TRB" NEW
Dbselectarea("TRB")
if !eof()
	aConfere:={}
endif
While !Eof()
	aadd(aConfere,{TRB->C6_NUM,TRB->C6_CLI,TRB->C6_LOJA,TRB->A1_NOME,TRB->ESPACO," ",TRB->A1_XROTA,"",TRB->C5_XNPVORT})
	If	Empty(__cPed)
		__cPed:="'"+TRB->C6_NUM+"'"
	Else
		__cPed+=",'"+TRB->C6_NUM+"'"
	Endif
	
	DbSkip()
End
dbclosearea()

If	!Empty(__cPed)
	__cQry	:=	"SELECT DISTINCT(C5_XOPER) OPER FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND D_E_L_E_T_ = ' ' AND C5_NUM IN ("+__cPed+") "//AND C5_XOPER = '04' "
	
	TCQUERY __cQry ALIAS "NRP" NEW
	
	DbSelectArea("NRP")
	
	lRepor	:=	.T.
	
	While !EOF()
		If	NRP->OPER <> '04' .AND. NRP->OPER <> '20'
			lRepor	:=	.F.
		Endif
		DbSkip()
	Enddo
	NRP->(DbCloseArea())
Endif

GeraTela()
lVisu:=.F.


Return()

***************************
User Function IncEmb()
***************************
Local aArea	:=	GetArea()

lRepor	:=	.F.

cCombo 		:= 	"Normal"
cCombo1		:=	"COLCHAO"
cEmbComp	:=	Space(06)

cCodArea  	:= 	Space(02)
cResiduo	:=	Space(01)
cCodTrans 	:= 	IIf(cEmpAnt=="21","M00997",Space(06))
cNomTrans 	:= 	Space(30)
nValAdiat 	:= 	0
nKilomet	:=	0
nPerFret	:= 	0
nValKm	 	:= 	0
nValSAC	 	:= 	0
nValFret 	:= 	0
nValFret2	:= 	0
//nPercTot 	:= 	0
nPercTot2	:= 	0

lVisu:=.F.
lIncEmb:=.T.
lAltEmb:= .F.
cordemb := "0000"
cordemb6 :="0000"
Pergunte("ORTP02AB",.F.)

MV_PAR05	:=	CTod(" ")

do while EMPTY(MV_PAR05) .OR. (MV_PAR05 < DATE()-IIf(cEmpAnt=="21",5,0) .AND. (MV_PAR05 <> STOD('20130701') .OR. CEMPANT <> '02'))
	If !Pergunte("ORTP02AB",.T.)
		Restarea(aArea)
		Return()
	EndIf
	if empty(MV_PAR05)
		MsgBox("Informe a Data de Programacao","ATENCAO")
	endif
	if MV_PAR05 < DATE()-IIf(cEmpAnt=="21",5,0)
		MsgBox("Data da Programacao nao pode ser inferior a data atual","ATENCAO")
	endif
enddo

nEspCam := MV_PAR06   //ESPACO CAMINHAO

//Exige uma senha para inclus„o de Cargas, no caso em que na data de programaÁ„o digitada j· haja OPs com o campo ZQ_OPGERAD = 'S'

//If	Alltrim(SM0->M0_CODIGO) = '03'
_cQuery	:=	"SELECT COUNT(*) COUNT FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")
_cQuery	+=	"' AND D_E_L_E_T_ = ' ' AND ZQ_DTPREVE = '"+Dtos(MV_PAR05)+"' AND ZQ_DTFECHA = 'S'"
//Else
//	_cQuery	:=	"SELECT COUNT(*) COUNT FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")
//	_cQuery	+=	"' AND D_E_L_E_T_ = ' ' AND ZQ_DTPREVE = '"+Dtos(MV_PAR05)+"' AND ZQ_OPGERAD = 'S'"
//Endif
MEMOWRIT("C:\ORTP002FCH.SQL",_cQuery)
TCQUERY _cQuery ALIAS "FCH" NEW

DbSelectArea("FCH")

If FCH->COUNT	>	0
	_lPW	:=	.F. //fValUSU()
else
	_lPW	:=	.T. //fValUSU()
Endif

DbSelectArea("FCH")
DbCloseArea()

RestArea(aArea)

If !_lPW
	Alert("Inclus„o n„o permitida, programaÁ„o j· fechada. Solicitar liberaÁ„o desta data")
	Return
ENdif

if ChecaSite() .AND. ( DOW(DATE()) < 7  )
	//Alterado - Vinicius LanÁa - 21/03/2019
	If MsgNoYes("Importe os pedidos do site que est„o pendentes. Inclus„o somente com liberaÁ„o do Gerente Geral. Prosseguir?"," AtenÁ„o ")
		lAprov := u_fValUSU("LIBCARGA","LiberaÁ„o Gerente Geral")
		IF lAprov
			_cInsReq := " INSERT INTO SIGA.LOGROTINA (UN, USUARIO, DTLOG, HORA, ROTINA, CNT, OBSERV) "
			_cInsReq += " VALUES ('"+cEmpAnt+"','"+__CUSERID+"','"+DTOC(dDatabase)+"','"+time()+"','ORTP002','N','O usu·rio: "+Alltrim(UsrRetName(__CUSERID))+" efetuou a liberaÁ„o.')"
			
			TcSqlExec(_cInsReq)
			TcSqlExec('commit')
		EndIf
	Else
		lAprov := .F.
	Endif
	
	If !lAprov
		Return(.F.)
	Endif
	//Alert("Inclus„o n„o permitida, Importe os pedidos do site que est„o pendentes.")
	//Return
Endif

cQuery	:=	"SELECT COUNT(*) PROG FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")
cQuery	+=	"' AND D_E_L_E_T_ = ' ' AND ZQ_DTPREVE > '"+Dtos(MV_PAR05)+"' AND ZQ_SITUACA <> 'C' "
TCQUERY cQuery ALIAS "PRGP" NEW
DbSelectArea("PRGP")

If PRGP->PROG	>	0
	aItems := {"Extra","SAC","Residuo","Complementar"}
	cCombo := "Extra"
else
	aItems := {"Normal","Residuo","Complementar","Extra","SAC"}
Endif
DbSelectArea("PRGP")
DbCloseArea()
RestArea(aArea)

DbSelectArea("SX5")
dbOrderNickName("PSX51")

If	MsSeek(xFilial("SX5")+"PO",.F.)
	aItems1	:=	{}
	While !EOF() .AND.	X5_TABELA == "PO"
		AADD(aItems1,X5_DESCRI)
		DbSkip()
	Enddo
	
Endif

//aRemessa :={{"","","","",0}}
aRemessa :={{"","","","",0,"","",""}}

//aConfere :={{"","","","",0}}
aConfere :={{"","","","",0,"",""}}
/*
cEmb:=GetMV("MV_XEMB")
cQuery:="SELECT COUNT(*) TOTREG FROM "+RetSqlName("SZQ")
cQuery+=" WHERE D_E_L_E_T_ <> '*' "
cQuery+="  AND ZQ_FILIAL = '" + xFilial("SZQ") + "' "
cQuery+="  AND (ZQ_EMBARQ = '"+cEmb+"' OR ZQ_EMBARQ = '"+Str(Val(cEmb)+500000,6)+"') "
TCQUERY cQuery ALIAS TOTEMB NEW
if TOTEMB->TOTREG > 0
MsgBox("NUMERA«√O DE EMBARQUE INVALIDA. ENTRE EM CONTATO COM A ADMINISTRA«√O","ATEN«¬O")
dbselectarea("TOTEMB")
dbclosearea()
Restarea(aArea)
return()
endif
dbselectarea("TOTEMB")
dbclosearea()
*/
Restarea(aArea)

GeraTela()
MsUnlockAll()
lTpVal:=.F.
Return()
***************************
User	Function 	AltEmb()
***************************
Local 	__cPed	:=	""
Local aArea  	:=	GetArea()
Local nTPid  	:= 	0
Local nVTSAC 	:= 	0
Local nPTSAC 	:= 	0
Local cPed   	:= 	""
u_libcobol()
cMotCrgEx	:=Space(250)

_aPedRet	:=	{}

lRepor	:=	.F.


lVisu		:=	.F.
lIncEmb		:=	.F.
lAltEmb		:= 	.T.
cCodArea  	:= 	space(2)
cResiduo	:= 	space(1)
cCodTrans 	:= 	space(6)
cNomTrans 	:= 	space(30)
nValAdiat 	:= 	0
nKilomet	:= 	0
nPerFret	:= 	0
nValKm	 	:= 	0
nValSAC	 	:= 	0
nValFret 	:= 	0
nValFret2	:= 	0
//nPercTot 	:= 	0
nPercTot2	:= 	0

//aRemessa :={{"","","","",0}}
aRemessa :={{"","","","",0,"","",""}}

//aConfere :={{"","","","",0}}
aConfere :={{"","","","",0,"",""}}

_aAreaAlt	:=	GetArea()

DbSelectArea("SX1")
If dbSeek(cPerg+'05')
	RecLock("SX1",.F.)
	X1_CNT01	:=	DTOC(SZQ->ZQ_DTPREVE)
	MsUnlock()
Endif

RestArea(_aAreaAlt)

If !Pergunte("ORTP02AB",.T.)
	Return
endif
do while EMPTY(MV_PAR05) .AND. MV_PAR05 < DATE()
	If !Pergunte("ORTP02AB",.T.)
		Restarea(aArea)
		Return()
	EndIf
	if empty(MV_PAR05)
		MsgBox("Informe a Data de Programacao","ATENCAO")
	endif
	if MV_PAR05 < DATE()
		MsgBox("Data da Programacao nao pode ser inferior a data atual","ATENCAO")
	endif
enddo



cQuery	:=	"SELECT COUNT(*) PROG FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")
cQuery	+=	"' AND D_E_L_E_T_ = ' ' AND ZQ_DTPREVE > '"+Dtos(MV_PAR05)+"' "
TCQUERY cQuery ALIAS "PRGP" NEW
DbSelectArea("PRGP")

If PRGP->PROG	>	0
	aItems := {"Extra","SAC","Residuo","Complementar"}
	cCombo := "Extra"
else
	aItems := {"Normal","Residuo","Complementar","Extra","SAC"}
Endif
DbSelectArea("PRGP")
DbCloseArea()
RestArea(aArea)


DbSelectArea("SX5")
dbOrderNickName("PSX51")

If	MsSeek(xFilial("SX5")+"PO",.F.)
	aItems1	:=	{}
	While !EOF() .AND.	X5_TABELA == "PO"
		AADD(aItems1,X5_DESCRI)
		DbSkip()
	Enddo
	
Endif


If SZQ->ZQ_XTPCAR			== "1"
	cCombo		:= "Normal"
ElseIf SZQ->ZQ_XTPCAR 		== "2"
	cCombo		:= "Residuo"
elseif SZQ->ZQ_XTPCAR 		== "3"
	cCombo		:= "Complementar"
elseif SZQ->ZQ_XTPCAR 		== "4"
	cCombo		:= "Extra"
	cMotCrgEx	:=SZQ->ZQ_OBS
elseif SZQ->ZQ_XTPCAR 		== "5"
	cCombo  	:= "Acrilica"
elseif SZQ->ZQ_XTPCAR 		== "6"
	cCombo  	:= "Bono"
elseif SZQ->ZQ_XTPCAR 		== "7"
	cCombo 		:= "SAC"
endif

cCombo1:=Posicione("SX5",1,xFilial("SX5")+"PO"+SZQ->ZQ_TPCARGA,"X5_DESCRI")
/* RETIRADO POR DUPIM EM 17/01/2011 NAO FAZ SENTIDO SE EXISTE UMA TABELA
If	SZQ->ZQ_TPCARGA			== 	"C"
cCombo1	:=	"COLCHAO"
ElseIf	SZQ->ZQ_TPCARGA		==	"D"
cCombo1	:=	"DUBLADO"
ElseIf	SZQ->ZQ_TPCARGA		==	"E"
cCombo1	:=	"ESPUMA"
ElseIf	SZQ->ZQ_TPCARGA		==	"L"
cCombo1	:=	"LAMINADO"
ElseIf	SZQ->ZQ_TPCARGA		==	"M"
cCombo1	:=	"MISTO"
ElseIf	SZQ->ZQ_TPCARGA		==	"R"
cCombo1	:=	"RETIRA"
ElseIf	SZQ->ZQ_TPCARGA		==	"T"
cCombo1	:=	"TORNEADO"
ElseIf	SZQ->ZQ_TPCARGA		==	"A"
cCombo1	:=	"ALMOFADA"
ElseIf	SZQ->ZQ_TPCARGA		==	"F"
cCombo1	:=	"FIBRA"
ElseIf	SZQ->ZQ_TPCARGA		==	"N"
cCombo1	:=	"MANTA"
ElseIf	SZQ->ZQ_TPCARGA		==	"O"
cCombo1	:=	"MOLA"
ElseIf	SZQ->ZQ_TPCARGA		==	"P"
cCombo1	:=	"REFATURAMENTO"
ElseIf	SZQ->ZQ_TPCARGA		==	"V"
cCombo1	:=	"TRAVESSEIRO"
Endif
*/

lIncEmb:=.F.
IF SZQ->ZQ_DTPREVE <> MV_PAR05
	MsgBox("Nao e permitido alterar data da programaÁ„o","ATEN«√O")
Else
	If 	SZQ->ZQ_OPGERAD=='S' .And. cEmpAnt <> '24'
		Msgbox("Carga j· programada para produÁ„o, estorne a produÁ„o","ATEN«¬O")
	ElseIf	SZQ->ZQ_SITUACA	==	'C'
		Msgbox("Cargas canceladas n„o podem ser alteradas","ATEN«¬O")
	Else
		//	If Pergunte("ORTP02",.T.)
		cEmb		:=SZQ->ZQ_EMBARQ
		cEmbComp	:=	SZQ->ZQ_EMBCOMP
		if cEmb >= "500000"
			cEmb	:=StrZero(val(cEmb)-500000,6)
		endif
		if cEmb >= "300000"
			cEmb	:=StrZero(val(cEmb)-nEmbTp,6)
		endif
		cQuery:="SELECT COUNT(*) TOTREG FROM "+RetSqlName("SC5")+"  "
		cQuery+="WHERE D_E_L_E_T_ <> '*' "
		cQuery+="  AND C5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery+="  AND C5_NOTA <> ' ' AND C5_XOPER NOT IN  ('96','99','98') "
		cQuery+="  AND C5_XEMBARQ  IN  ('"+cEmb+"','"+STRZERO(VAL(cEmb)+nEmbTp,6)+"','"+Str(Val(cEmb)+500000,6)+"') "
		TCQUERY cQuery ALIAS TOTEMB NEW
		if TOTEMB->TOTREG > 0
			MsgBox("Embarque j· possui Notas Emitidas","ATEN«¬O")
			if Alltrim(cUserName)<>"dupim"
				dbselectarea("TOTEMB")
				dbclosearea()
				Restarea(aArea)
				return()
			endif
		endif
		dbselectarea("TOTEMB")
		dbclosearea()
		
		//cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN "
		// ALTERADO POR DUPIM EM 08/06/2011 PARA COMPATIBILIZAR OS ESPACOS COM O PEDIDO DE CIRCULACAO INTERNA
		cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN "
		cQuery+="       C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, SA1.A1_NOME, A1_XROTA, "
		cQuery+="       SUM(DECODE(C6_QTDVEN,0,C6_VALOR,C6_QTDVEN*C6_XPRUNIT)) AS VALTOT, SC5.C5_XORDEMB,SC5.C5_XNPVORT, C5_XTPVAL, C5_XOPER "
		cQuery+="FROM "+RetSqlName("SC6") +" SC6, "
		cQuery+="     "+RetSqlName("SC5") +" SC5, "
		cQuery+="     "+RetSqlName("SB1") +" SB1, "
		cQuery+="     "+RetSqlName("SA1") +" SA1,  "
		cQuery+="     "+RetSqlName("SBM") +" SBM  "
		cQuery+="WHERE SC6.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SC5.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SB1.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SA1.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SBM.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery+="  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery+="  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery+="  AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery+="  AND SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
		cQuery+="  AND SBM.BM_GRUPO   = SB1.B1_GRUPO "
		cQuery+="  AND SC5.C5_NUM     = SC6.C6_NUM     "
		cQuery+="  AND SB1.B1_COD     = SC6.C6_PRODUTO "
		cQuery+="  AND SC5.C5_CLIENTE = SC6.C6_CLI     "
		cQuery+="  AND SC5.C5_LOJACLI = SC6.C6_LOJA    "
		cQuery+="  AND SC5.C5_CLIENT = SA1.A1_COD     "
		cQuery+="  AND SC5.C5_LOJAENT = SA1.A1_LOJA    "
		cQuery+="  AND SC5.C5_XDTLIB  <>' '            "
		cQuery+="  AND SC5.C5_XEMBARQ  IN  ('"+cEmb+"','"+STRZERO(VAL(cEmb)+nEmbTp,6)+"')     "
		if alltrim(cUserName) <> "dupim"
			cQuery+="  AND SC5.C5_NOTA    = ' '            "
		endif
		cQuery+="  AND C5_TIPO NOT IN ('B','D') "
		cQuery+="  AND (SC5.C5_XOPER NOT IN ('96','99','98') OR (SC5.C5_XOPER = '14' AND SC5.C5_XUNORI <> '  ')) "
		cQuery+="  GROUP BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SA1.A1_NOME, SC5.C5_XOPER , SC5.C5_XNPVORT, "
		cQuery+="           SC5.C5_XORDEMB, SC5.C5_XTPVAL, SA1.A1_XROTA "
		cQuery+=" UNION "
		//cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN "
		// ALTERADO POR DUPIM EM 08/06/2011 PARA COMPATIBILIZAR OS ESPACOS COM O PEDIDO DE CIRCULACAO INTERNA
		cQuery+="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN "
		cQuery+="       C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, SA2.A2_NOME, '000000' A1_XROTA, "
		cQuery+="       SUM(DECODE(C6_QTDVEN,0,C6_VALOR,C6_QTDVEN*C6_XPRUNIT)) AS VALTOT, SC5.C5_XORDEMB,SC5.C5_XNPVORT, SC5.C5_XTPVAL, C5_XOPER "
		cQuery+="FROM "+RetSqlName("SC6") +" SC6, "
		cQuery+="     "+RetSqlName("SC5") +" SC5, "
		cQuery+="     "+RetSqlName("SB1") +" SB1, "
		cQuery+="     "+RetSqlName("SA2") +" SA2,  "
		cQuery+="     "+RetSqlName("SBM") +" SBM  "
		cQuery+="WHERE SC6.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SC5.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SB1.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SA2.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SBM.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery+="  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery+="  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery+="  AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
		cQuery+="  AND SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
		cQuery+="  AND SBM.BM_GRUPO  = SB1.B1_GRUPO "
		cQuery+="  AND SC5.C5_NUM     = SC6.C6_NUM     "
		cQuery+="  AND SB1.B1_COD     = SC6.C6_PRODUTO "
		cQuery+="  AND SC5.C5_CLIENTE = SC6.C6_CLI     "
		cQuery+="  AND SC5.C5_LOJACLI = SC6.C6_LOJA    "
		cQuery+="  AND SC5.C5_CLIENTE = SA2.A2_COD     "
		cQuery+="  AND SC5.C5_LOJACLI = SA2.A2_LOJA    "
		cQuery+="  AND SC5.C5_XDTLIB  <>' '            "
		cQuery+="  AND SC5.C5_XEMBARQ  IN  ('"+cEmb+"','"+STRZERO(VAL(cEmb)+nEmbTp,6)+"')     "
		if alltrim(cUserName) <> "dupim"
			cQuery+="  AND SC5.C5_NOTA    = ' '            "
		endif
		cQuery+="  AND C5_TIPO IN ('B','D') "
		cQuery+="  AND (SC5.C5_XOPER NOT IN ('96','99','98') OR (SC5.C5_XOPER = '14' AND SC5.C5_XUNORI <> '  ')) "
		cQuery+="  GROUP BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SA2.A2_NOME, SC5.C5_XOPER , SC5.C5_XNPVORT, "
		cQuery+="           SC5.C5_XORDEMB, SC5.C5_XTPVAL "
		//cQuery+="  ORDER BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA"
		cQuery+="  ORDER BY C5_XORDEMB "
		MEMOWRIT("C:\ORTP002.SQL",cQuery)
		TCQUERY cQuery ALIAS "TRB" NEW
		Dbselectarea("TRB")
		if !eof()
			aRemessa:={}
			nTPid++
		endif
		cPed := ""
		While !Eof()
			
			nValTot += TRB->VALTOT
			//		Alert(nValTot)
			nVTSAC  += iif(TRB->C5_XOPER == '17', TRB->VALTOT, 0)
			nPTSAC  += iif(TRB->C5_XOPER == '17' .AND. (TRB->C6_NUM <> cPed .or. empty(cPed)), 1, 0)
			aadd(aRemessa,{TRB->C6_NUM,TRB->C6_CLI,TRB->C6_LOJA,TRB->A1_NOME,TRB->ESPACO,TRB->A1_XROTA,;
			TRB->C5_XNPVORT,TRB->C5_XTPVAL})
			
			If	Empty(__cPed)
				__cPed:="'"+TRB->C6_NUM+"'"
			Else
				__cPed+=",'"+TRB->C6_NUM+"'"
			Endif
			
			
			
			DbSkip()
			If !Eof()
				cPed := TRB->C6_NUM
			EndIf
		End
		dbclosearea()
		//cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN "
		// ALTERADO POR DUPIM EM 08/06/2011 PARA COMPATIBILIZAR OS ESPACOS COM O PEDIDO DE CIRCULACAO INTERNA
		cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN "
		cQuery+="       C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, SA1.A1_NOME, SA1.A1_XROTA, "
		cQuery+="       SUM(DECODE(C6_QTDVEN,0,C6_VALOR,C6_QTDVEN*C6_XPRUNIT)) AS VALTOT, SC5.C5_XORDEMB,SC5.C5_XNPVORT, SC5.C5_XTPVAL, c5_xoper "
		cQuery+="FROM "+RetSqlName("SC6") +" SC6, "
		cQuery+="     "+RetSqlName("SC5") +" SC5, "
		cQuery+="     "+RetSqlName("SB1") +" SB1, "
		cQuery+="     "+RetSqlName("SA1") +" SA1,  "
		cQuery+="     "+RetSqlName("SBM") +" SBM  "
		cQuery+="WHERE SC6.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SC5.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SB1.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SA1.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SBM.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery+="  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery+="  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery+="  AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery+="  AND SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
		cQuery+="  AND SBM.BM_GRUPO = SB1.B1_GRUPO "
		cQuery+="  AND SC5.C5_NUM     = SC6.C6_NUM     "
		cQuery+="  AND SB1.B1_COD     = SC6.C6_PRODUTO "
		cQuery+="  AND SC5.C5_CLIENT = SC6.C6_CLI     "
		cQuery+="  AND SC5.C5_LOJACLI = SC6.C6_LOJA    "
		cQuery+="  AND SC5.C5_CLIENT  = SA1.A1_COD     "
		cQuery+="  AND SC5.C5_LOJAENT = SA1.A1_LOJA    "
		cQuery+="  AND SC5.C5_XDTLIB  <>' '            "
		cQuery+="  AND SC5.C5_XEMBARQ = '"+strzero(val(cEmb)+500000,6)+"'     "
		cQuery+="  AND SC5.C5_NOTA    = ' '            "
		cQuery+="  AND (SC5.C5_XOPER NOT IN ('96','99','98') OR (SC5.C5_XOPER = '14' AND SC5.C5_XUNORI <> '  ')) "
		cQuery+="  AND C5_TIPO NOT IN ('B','D') "
		cQuery+="  GROUP BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SA1.A1_NOME, SC5.C5_XOPER, SC5.C5_XNPVORT, SA1.A1_XROTA, "
		cQuery+="           SC5.C5_XORDEMB, SC5.C5_XTPVAL "
		cQuery+="  UNION "
		//cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN "
		// ALTERADO POR DUPIM EM 08/06/2011 PARA COMPATIBILIZAR OS ESPACOS COM O PEDIDO DE CIRCULACAO INTERNA
		cQuery+="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN "
		cQuery+="       C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, SA2.A2_NOME, '000000' A1_XROTA, "
		cQuery+="       SUM(DECODE(C6_QTDVEN,0,C6_VALOR,C6_QTDVEN*C6_XPRUNIT)) AS VALTOT, SC5.C5_XORDEMB,SC5.C5_XNPVORT, SC5.C5_XTPVAL, c5_xoper "
		cQuery+="FROM "+RetSqlName("SC6") +" SC6, "
		cQuery+="     "+RetSqlName("SC5") +" SC5, "
		cQuery+="     "+RetSqlName("SB1") +" SB1, "
		cQuery+="     "+RetSqlName("SA2") +" SA2,  "
		cQuery+="     "+RetSqlName("SBM") +" SBM  "
		cQuery+="WHERE SC6.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SC5.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SB1.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SA2.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SBM.D_E_L_E_T_ <> '*' "
		cQuery+="  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery+="  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery+="  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery+="  AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
		cQuery+="  AND SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
		cQuery+="  AND SBM.BM_GRUPO = SB1.B1_GRUPO "
		cQuery+="  AND SC5.C5_NUM     = SC6.C6_NUM     "
		cQuery+="  AND SB1.B1_COD     = SC6.C6_PRODUTO "
		cQuery+="  AND SC5.C5_CLIENTE = SC6.C6_CLI     "
		cQuery+="  AND SC5.C5_LOJACLI = SC6.C6_LOJA    "
		cQuery+="  AND SC5.C5_CLIENTE = SA2.A2_COD     "
		cQuery+="  AND SC5.C5_LOJACLI = SA2.A2_LOJA    "
		cQuery+="  AND SC5.C5_XDTLIB  <>' '            "
		cQuery+="  AND C5_TIPO IN ('B','D') "
		cQuery+="  AND SC5.C5_XEMBARQ = '"+strzero(val(cEmb)+500000,6)+"'     "
		cQuery+="  AND SC5.C5_NOTA    = ' '            "
		cQuery+="  AND (SC5.C5_XOPER NOT IN ('96','99','98') OR (SC5.C5_XOPER = '14' AND SC5.C5_XUNORI <> '  ')) "
		cQuery+="  GROUP BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SA2.A2_NOME, SC5.C5_XOPER, SC5.C5_XNPVORT,  "
		cQuery+="           SC5.C5_XORDEMB, SC5.C5_XTPVAL "
		//cQuery+="  ORDER BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA"
		cQuery+="  ORDER BY C5_XORDEMB"
		
		MEMOWRIT("C:\ortp002alt.SQL",cQuery)
		
		TCQUERY cQuery ALIAS "TRB" NEW
		Dbselectarea("TRB")
		if !eof()
			aConfere:={}
			nTPid++
		endif
		
		cPed := ""
		
		While !Eof()
			nValTot += TRB->VALTOT
			//		Alert(nValTot)
			nVTSAC  += iif(TRB->C5_XOPER == '17', TRB->VALTOT, 0)
			nPTSAC  += iif(TRB->C5_XOPER == '17' .AND. (TRB->C6_NUM <> cPed .or. empty(cPed)), 1, 0)
			aadd(aConfere,{TRB->C6_NUM,TRB->C6_CLI,TRB->C6_LOJA,TRB->A1_NOME,TRB->ESPACO," ",TRB->C5_XNPVORT,;
			TRB->C5_XTPVAL})
			
			If	Empty(__cPed)
				__cPed:="'"+TRB->C6_NUM+"'"
			Else
				__cPed+=",'"+TRB->C6_NUM+"'"
			Endif
			
			DbSkip()
			If !Eof()
				cPed := TRB->C6_NUM
			EndIf
		End
		
		dbCloseArea()
		
		If	!Empty(__cPed)
			
			__cQry	:=	"SELECT DISTINCT(C5_XOPER) OPER FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")
			__cQry	+=  "' AND D_E_L_E_T_ = ' ' AND C5_NUM IN ("+__cPed+") " //AND C5_XOPER = '04' "
			
			MEMOWRIT("C:\NRP.SQL",__cQry)
			
			TCQUERY __cQry ALIAS "NRP" NEW
			
			DbSelectArea("NRP")
			
			If	!EOF()
				lRepor	:=	.T.
			Endif
			
			While !EOF()
				//			Alert(NRP->OPER)
				If	NRP->OPER <> '04' .AND. NRP->OPER <> '20'
					lRepor	:=	.F.
				Endif
				DbSkip()
				
			Enddo
			lRep	:=	lRepor
			NRP->(DbCloseArea())
		Endif
		
		
		if !lIncEmb
			// Atualiza informaÁıes para tela de frete
			
			
			_cQuery	:=	"SELECT * FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' "
			_cQuery	+=	" AND SUBSTR(ZQ_EMBARQ,2,5) = '"+SUBSTR(SZQ->ZQ_EMBARQ,2,5)+"' AND ZQ_EMBARQ < '5' "
			_cQuery	+=	" AND D_E_L_E_T_ = ' ' "
			
			TCQUERY _cQuery	ALIAS "SZQA" NEW
			
			DbSelectArea("SZQA")
			
			
			//	cCodArea  	:= SZQA->ZQ_PRACA
			//	cResiduo	:= IIF(SZQA->ZQ_RESIDUO = 'S', 'Sim', 'Nao')
			//	cCodTrans 	:= SZQA->ZQ_TRANSP
			//	cNomTrans 	:= POSICIONE("SA4",1,xFilial("SA4")+SZQA->ZQ_TRANSP, "A4_NOME")
			//	nValAdiat 	:= SZQA->ZQ_ADIANT// * nTPid
			nKilomet	:= SZQA->ZQ_KILOMET
			nPerFret	:= SZQA->ZQ_PERFRET
			nValKm	 	:= SZQA->ZQ_VALORKM// * nTPid
			nValSAC	 	:= SZQA->ZQ_VALORSA
			nValFret 	:= SZQA->ZQ_FRTMIN
			nValFret2	:= SZQA->ZQ_VALFRET
			nPercTot2	:= SZQA->ZQ_PERFRET
			SZQA->(DbCloseArea())
			
			
			_cQuery	:=	"SELECT * FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND "
			_cQuery	+=	"SUBSTR(ZQ_EMBARQ,2,5) = '"+SUBSTR(SZQ->ZQ_EMBARQ,2,5)+"' AND ZQ_EMBARQ >= '5' AND "
			_cQuery	+=	"D_E_L_E_T_ = ' ' "
			
			TCQUERY _cQuery	ALIAS "SZQA" NEW
			
			DbSelectArea("SZQA")
			
			/*
			cCodArea  	:= SZQA->ZQ_PRACA
			cResiduo	:= IIF(SZQA->ZQ_RESIDUO = 'S', 'Sim', 'Nao')
			cCodTrans 	:= SZQA->ZQ_TRANSP
			cNomTrans 	:= POSICIONE("SA4",1,xFilial("SA4")+SZQA->ZQ_TRANSP, "A4_NOME")
			nValAdiat 	:= SZQA->ZQ_ADIANT// * nTPid */
			nCKilomet	:= SZQA->ZQ_KILOMET
			nCPerFret	:= SZQA->ZQ_PERFRET
			nCValKm	 	:= SZQA->ZQ_VALORKM// * nTPid
			nCValSAC	:= SZQA->ZQ_VALORSA
			nCValFret 	:= SZQA->ZQ_FRTMIN
			nCValFret2	:= SZQA->ZQ_VALFRET
			nPercTotN	:= 0
			nPercTotN	:= SZQA->ZQ_PERFRET
			
			SZQA->(DbCloseArea())
			
			
			
		endif
		
		GeraTela()
		
	Endif
Endif
//endif
MsUnlockAll()
lTpVal:=.F.
Return()
***************************
User Function ExcEmb()
***************************
Local cQuery:=""


//dbselectarea("SZI")
//dbsetorder(4)
//dbseek(xFilial("SZI")+SZQ->ZQ_EMBARQ)
if SZQ->ZQ_OPGERAD='S'
	msgbox("Carga j· programada para produÁ„o, estorne a produÁ„o","ATEN«¬O")
ElseIf	SZQ->ZQ_SITUACA	==	'C'
	Msgbox("Cargas canceladas n„o podem ser excluidas","ATEN«¬O")
Else
	cQuery:="SELECT COUNT(*) NFAT "
	cQuery+="  FROM "+RETSQLNAME("SC5")+" SC5, "+RETSQLNAME("SD2")+" SD2 "
	cQuery+=" WHERE SC5.D_E_L_E_T_ = ' ' "
	cQuery+="   AND SD2.D_E_L_E_T_ = ' ' "
	cQuery+="   AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery+="   AND D2_FILIAL = '"+xFilial("SD2")+"' "
	cQuery+="   AND D2_PEDIDO = C5_NUM "
	cQuery+="   AND SUBSTR(C5_XEMBARQ,2,5) = '"+SUBSTR(SZQ->ZQ_EMBARQ,2,5)+"'     "
	tcquery cQuery alias "NFAT" new
	dbselectarea("NFAT")
	nTFAT:=NFAT->NFAT
	dbclosearea()
	if nTFAT > 0
		Msgbox("Cargas com notas faturadas n„o podem ser excluidas","ATEN«¬O")
	else
		
		If MsgBox("Confirma exclus„o do embarque "+SZQ->ZQ_EMBARQ+" ?","ATEN«¬O","YESNO")
			//		If SZQ->ZQ_EMBARQ > "500000"
			//			cEmbDel:=Strzero(Val(SZQ->ZQ_EMBARQ)-500000,6)
			//		Else
			//			cEmbDel:=Strzero(Val(SZQ->ZQ_EMBARQ)+500000,6)
			//		Endif
			cQuery:="UPDATE "+RetSQLName("SC5")+" SET C5_XEMBARQ = ' ', C5_XTPVAL = ' ' "
			cQuery+=" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND D_E_L_E_T_ = ' ' AND SUBSTR(C5_XEMBARQ,2,5) = '"+SUBSTR(SZQ->ZQ_EMBARQ,2,5)+"'     "
			Begin Transaction
			TCSQLExec(cQuery)
			
			
			//		cQuery:="DELETE "+RetSqlName("SZQ")+" WHERE ZQ_EMBARQ = '"+SZQ->ZQ_EMBARQ+"' "
			//      cQuery:="UPDATE "+RetSqlName("SZQ")+" SET D_E_L_E_T_ = '*' WHERE ZQ_EMBARQ = '"+SZQ->ZQ_EMBARQ+"' "
			cQuery:="UPDATE "+RetSqlName("SZQ")+" SET ZQ_SITUACA = 'C',	ZQ_VALOR = 0, ZQ_ESPACO = 0 "
			cQUery+=" WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND D_E_L_E_T_ = ' ' AND SUBSTR(ZQ_EMBARQ,2,5) = '"+SUBSTR(SZQ->ZQ_EMBARQ,2,5)+"'     "
			TCSQLExec(cQuery)
			
			//		cQuery:="UPDATE "+RetSQLName("SC5")+" SET C5_XEMBARQ = ' ', C5_XTPVAL = ' ' "
			//		cQuery+=" WHERE C5_XEMBARQ = '"+cEmbDel+"' "
			//		TCSQLExec(cQuery)
			//		cQuery:="DELETE "+RetSqlName("SZQ")+" WHERE ZQ_EMBARQ = '"+cEmbDel+"' "
			//      cQuery:="UPDATE "+RetSqlName("SZQ")+" SET D_E_L_E_T_ = '*' WHERE ZQ_EMBARQ = '"+cEmbDel+"' "
			//		cQuery:="UPDATE "+RetSqlName("SZQ")+" SET ZQ_SITUACA = 'C', ZQ_VALOR = 0, ZQ_ESPACO = 0 WHERE ZQ_EMBARQ = '"+cEmbDel+"' "
			//		TCSQLExec(cQuery)
			
			cQuery:="UPDATE "+RetSqlName("PAP")+" SET PAP_FILIAL = 'XX' "
			cQUery+=" WHERE PAP_FILIAL = '"+xFilial("PAP")+"' AND D_E_L_E_T_ = ' ' AND SUBSTR(PAP_EMBARQ,2,5) = '"+SUBSTR(SZQ->ZQ_EMBARQ,2,5)+"'"
			cQUery+=" AND PAP_EMP = '"+CEMPANT+"'"
			TCSQLExec(cQuery)
			End Transaction
			DBSELECTAREA("PAP")
			DBSETORDER(1)
			IF DBSEEK("XX")
				WHILE !(PAP->(EOF())) .AND. (PAP->PAP_FILIAL == "XX")
					DBSELECTAREA("PAP")
					reclock("PAP",.F.)
					dbdelete()
					msunlock()
					dbskip()
				ENDDO
			ENDIF
			MsgBox("Embarque Exluido!","ATEN«¬O")
		Endif
	Endif
Endif
MsUnlockAll()
Return()

***************************
Static Function GeraTela()
**************************
Local cQuery    :=""
cNPed	:=	""
cNomCli	:=	""

Define Font oFontGr Name "Arial" Size 0,-12 Bold

if !lVisu
	//cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, SA1.A1_NOME, SC5.C5_XORDEMB, SC5.C5_XNPVORT "
	//alterado por dupim em 08/06/11
	cQuery:="SELECT /*+ ORDERED */ SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, "
	cQuery+="SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, "
	cQuery+="SA1.A1_NOME, SC5.C5_XORDEMB, SC5.C5_XNPVORT, A1_XROTA "
    If cEmpAnt == "21" && If incluido em 07/01/2020 para adaptar o fonte a Ortofio - Henrique
 	   cQuery+=" FROM "
    Else
 	   cQuery+=" FROM CARTEIRA"+CEMPANT+"0, "
    EndIf
	cQuery+="     "+RetSqlName("SC5") +" SC5, "
	cQuery+="     "+RetSqlName("SC6") +" SC6, "
	cQuery+="     "+RetSqlName("SA1") +" SA1,  "
	cQuery+="     "+RetSqlName("SB1") +" SB1, "
	cQuery+="     "+RetSqlName("SZE") +" SZE, "
	cQuery+="     "+RetSqlName("SBM") +" SBM "
	cQuery+=" WHERE SC6.D_E_L_E_T_ = ' ' "
	cQuery+="  AND SC5.D_E_L_E_T_ = ' ' "
	cQuery+="  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery+="  AND SA1.D_E_L_E_T_ = ' ' "
	cQuery+="  AND SBM.D_E_L_E_T_ = ' ' "
	cQuery+="  AND SZE.D_E_L_E_T_(+) = ' ' "
    If cEmpAnt == "21" && If incluido em 07/01/2020 para adaptar o fonte a Ortofio - Henrique
       // Henrique - 10/09/2021 - Substituido para atender a SSI 124266
       //cQuery+="  AND SC5.C5_EMISSAO Between '" +DToS(MV_PAR03)+ "' AND '" +DToS(MV_PAR04)+ "'"
       cQuery+="  AND SC5.C5_XDTVEND Between '" +DToS(MV_PAR03)+ "' AND '" +DToS(MV_PAR04)+ "'"
       cQuery+="  AND SC5.C5_XOPER Not In ('05','23') "
       cQuery+="  AND SC5.R_E_C_N_O_ = (Select R_E_C_N_O_ REC "
       cQuery+="                        From Siga." +RetSQLName("SC5")+ " C5 "
       cQuery+="                        Where C5.D_E_L_E_T_ = ' ' "
       cQuery+="                          AND C5.C5_FILIAL = '" +xFilial("SC5")+ "' "
       cQuery+="                          AND C5.C5_TIPO In ('B','N') "
       cQuery+="                          AND C5.C5_XEMBARQ = ' ' "
       cQuery+="                          AND C5.C5_NOTA <> ' ' "
       cQuery+="                          AND C5.C5_EMISSAO = SC5.C5_EMISSAO "
       cQuery+="                          AND C5.C5_NUM = SC5.C5_NUM) "
    Else
 	   cQuery+="  AND SC5.R_E_C_N_O_ = REC "
    EndIf
	cQuery+="  AND SZE.ZE_FILIAL(+) = '" + xFilial("SZE") + "' "
	cQuery+="  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
	cQuery+="  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
	cQuery+="  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery+="  AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery+="  AND SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
	cQuery+="  AND SBM.BM_GRUPO = SB1.B1_GRUPO "
	cQuery+="  AND SC5.C5_NUM     = SC6.C6_NUM     "
	cQuery+="  AND SB1.B1_COD     = SC6.C6_PRODUTO "
	cQuery+="  AND SC5.C5_CLIENTE = SC6.C6_CLI     "
	cQuery+="  AND SC5.C5_LOJACLI = SC6.C6_LOJA    "
	cQuery+="  AND SC5.C5_CLIENT  = SA1.A1_COD     "
	cQuery+="  AND SC5.C5_LOJAENT = SA1.A1_LOJA    "
	cQuery+="  AND SC5.C5_NUM     = SZE.ZE_PEDIDO(+)    "
	cQuery+="  AND SZE.ZE_USUARIO(+) = ' '    "
	cQuery+="  AND SZE.ZE_DTAUT IS NULL    "
	cQuery+="  AND SC5.C5_XEMBARQ = ' '            "
    If cEmpAnt # "21" && If incluido em 07/01/2020 para adaptar o fonte a Ortofio - Henrique
 	   cQuery+="  AND SC5.C5_NOTA    = ' '            "
    EndIf
	cQuery+="  AND SC5.C5_XDTLIB  <>' '            "
	//cQuery+="  AND ( SC5.C5_XOPER <> '99' AND SC5.C5_XOPER <> '14' ) "
	cQuery+="  AND (SC5.C5_XOPER NOT IN ('96','99','98') OR (SC5.C5_XOPER = '14' AND SC5.C5_XUNORI <> '  '))"
	cQuery+="  AND C5_TIPO NOT IN ('B','D') "
	cQuery+="  AND A1_XROTA BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	//	cQuery+="  AND C6_ENTREG BETWEEN '"+Dtos(MV_PAR03)+"' AND '"+Dtos(MV_PAR04)+"' " //retirado por dupim em 11/10/2010 por questoes de performance
	cQuery+="  GROUP BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SA1.A1_NOME ,SC5.C5_XNPVORT, SC5.C5_XORDEMB,SA1.A1_XROTA "

    If cEmpAnt # "21"  && Inibida das notas de beneficiamento da Ortofio - Henrique 07/01/2020 
 	   cQuery+=" UNION "
	   //cQuery:="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, SA1.A1_NOME, SC5.C5_XORDEMB, SC5.C5_XNPVORT "
	   //alterado por dupim em 08/06/11
	   cQuery+="SELECT SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, "
	   cQuery+="SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) AS ESPACO, "
	   cQuery+="SA2.A2_NOME, SC5.C5_XORDEMB, SC5.C5_XNPVORT, ' ' A1_XROTA "
	   cQuery+=" FROM CARTEIRA"+CEMPANT+"0, "
	   cQuery+="     "+RetSqlName("SC5") +" SC5, "
	   cQuery+="     "+RetSqlName("SC6") +" SC6, "
	   cQuery+="     "+RetSqlName("SA2") +" SA2,  "
	   cQuery+="     "+RetSqlName("SB1") +" SB1, "
	   cQuery+="     "+RetSqlName("SBM") +" SBM "
	   cQuery+="WHERE SC6.D_E_L_E_T_ <> '*' "
	   cQuery+="  AND SC5.D_E_L_E_T_ <> '*' "
	   cQuery+="  AND SB1.D_E_L_E_T_ <> '*' "
	   cQuery+="  AND SA2.D_E_L_E_T_ <> '*' "
	   cQuery+="  AND SBM.D_E_L_E_T_ <> '*' "
	   cQuery+="  AND SC5.R_E_C_N_O_ = REC "
 	   cQuery+="  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
	   cQuery+="  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
	   cQuery+="  AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	   cQuery+="  AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
	   cQuery+="  AND SBM.BM_FILIAL = '" + xFilial("SBM") + "' "
	   cQuery+="  AND SBM.BM_GRUPO   = SB1.B1_GRUPO     "
	   cQuery+="  AND SC5.C5_NUM     = SC6.C6_NUM     "
	   cQuery+="  AND SB1.B1_COD     = SC6.C6_PRODUTO "
	   cQuery+="  AND SC5.C5_CLIENTE = SC6.C6_CLI     "
	   cQuery+="  AND SC5.C5_LOJACLI = SC6.C6_LOJA    "
 	   cQuery+="  AND SC5.C5_CLIENTE = SA2.A2_COD     "
	   cQuery+="  AND SC5.C5_LOJACLI = SA2.A2_LOJA    "
	   cQuery+="  AND SC5.C5_XEMBARQ = ' '            "
	   cQuery+="  AND SC5.C5_XDTLIB  <>' '            "
	   cQuery+="  AND C5_TIPO NOT IN ('C','I','N') "
	   cQuery+="  AND (SC5.C5_XOPER NOT IN ('96','99','98') OR (SC5.C5_XOPER = '14' AND SC5.C5_XUNORI <> '  ')) "
	   //	cQuery+="  AND C6_ENTREG BETWEEN '"+Dtos(MV_PAR03)+"' AND '"+Dtos(MV_PAR04)+"' " //retirado por dupim em 11/10/2010 por questoes de performance
	   cQuery+="  GROUP BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA, SA2.A2_NOME ,SC5.C5_XNPVORT, SC5.C5_XORDEMB "
	   //cQuery+="  ORDER BY SC6.C6_NUM, SC6.C6_CLI, SC6.C6_LOJA"
	   cQuery+="  ORDER BY C5_XORDEMB "
    EndIf
	memowrit("c:\ortp002I.sql",cQuery)
	TCQUERY cQuery ALIAS "TRB" NEW
	Dbselectarea("TRB")
	if !eof()
		aOrigem:={}
	endif
	While !Eof()
		aadd(aOrigem,{TRB->C6_NUM,TRB->C6_CLI,TRB->C6_LOJA,TRB->A1_NOME,TRB->ESPACO,TRB->A1_XROTA,TRB->C5_XNPVORT})
		DbSkip()
	End
	dbclosearea()
endif

SETKEY(VK_F12, { || Mensagem1()})

Define MSDialog oDlgCarga Title "Montagem de Carga: "+If(!lIncEmb,cEmb,"")+" "+dtoc(MV_PAR05) From 000,000 To 570,1010 of oMainwnd Pixel
@ 004,000 ListBox oOrigem Var cOrigem Fields HEADER "Pedido","Cliente","Nome", "EspaÁo p/ Emb.","Rota" FIELDSIZES 025,025,180,040,025,025 Size 220,180 OF oDlgCarga pixel
if !lVisu
	@ 004,222 Button OemToAnsi("&R-->") Size 50,17 Action MvOriRem() pixel
	@ 022,222 Say "Ped.Microsiga" pixel
	@ 031,222 Get oRem  var cRem    Size 50,10 valid fVldRem() pixel
	@ 047,222 Say "Ped.Cobol" pixel
	@ 056,222 Get oRem2 var cRem2   Size 50,10 valid fVldRem() pixel
	//if cEmpAnt$("03|04|15") //.and. dtos(MV_PAR05)<"20110601"
	//	@ 095,222 Button OemToAnsi("&P-->") Size 50,16 Action MvOriConf() pixel
	//	@ 113,222 Say "Ped.Microsiga" pixel
	//	@ 122,222 Get oConf  var cConf   Size 50,10 valid fVldConf() pixel
	//	@ 138,222 Say "Ped.Cobol" pixel
	//	@ 147,222 Get oConf2 var cConf2  Size 50,10 valid fVldConf() pixel
	//endif
	@ 185,222 Say "Remover Pedido" pixel
	@ 194,222 Get oRemove  var cRemove   Size 50,10 valid LocalizSel(1) pixel
	@ 194,275 Say "Ultimo Pedido Digitado: "+cNped+"-"+cNomCli pixel
	
endif
if cEmpAnt$("03|04|15") //.and. dtos(MV_PAR05)<"20110601"
	@ 004,275 ListBox oRemessa Var cRemessa Fields HEADER "Pedido","Cliente","Nome", "EspaÁo p/ Emb.","Rota","Tp.Pgt" FIELDSIZES 025,025,120,040,025 on dblclick RemoveSel(@aRemessa,@oRemessa) Size 220,090 OF oDlgCarga pixel
	@ 095,275 ListBox oConfere Var cConfere Fields HEADER "Pedido","Cliente","Nome", "EspaÁo p/ Emb.","Rota","Tp.Pgt" FIELDSIZES 025,025,120,040,025 on dblclick RemoveSel(@aConfere,@oConfere) Size 220,090 OF oDlgCarga pixel
else
	@ 004,275 ListBox oRemessa Var cRemessa Fields HEADER "Pedido","Cliente","Nome", "EspaÁo p/ Emb.","Rota","Tp.Pgt" FIELDSIZES 025,025,120,040,025 on dblclick RemoveSel(@aRemessa,@oRemessa) Size 220,180 OF oDlgCarga pixel
	
endif
@ 190,000 say "EspaÁo Total" pixel
@ 190,040 MsGet oEspTot  var nEspTot   picture "@E 999,999.999" When .F. pixel
@ 190,090 MsGet oEspRem  var nEspPRem  picture "@E 999.99" 		When .F. pixel
@ 190,125 MsGet oEspConf var nEspPConf picture "@E 999.99" 		When .F. pixel
@ 215,000 say "Valor Total" pixel
@ 215,040 MsGet oValTot  var nValTot   picture "@E 999,999.99" 	When .F. pixel
@ 215,090 MsGet oValRem  var nValPRem  picture "@E 999.99" 		When .F. pixel
@ 215,125 MsGet oValConf var nValPConf picture "@E 999.99" 		When .F. pixel
@ 215,222 say "Espaco Caminhao" pixel
//@ 215,265 COMBOBOX oEspCam ITEMS aItems3 SIZE 50,50 pixel of oDlgCarga      
@ 215,265 MsGet oEspCam  var nEspCam   picture "@E 999,999.999" When .F. pixel

@ 215,320 Button "&Pont. Fabril"     Size 037,014 Action RELPTF() Font oFontGr PIXEL OF oDlgCarga

@ 215,362 Button "&Mapa Vlr. Cargas" Size 050,014 Action VLCAR() Font oFontGr PIXEL OF oDlgCarga

@ 215,420 Button "&Aglut. Pedido" Size 050,014 Action AGLUPED() Font oFontGr PIXEL OF oDlgCarga

@ 235,000 say "Tipo Carga:" pixel
@ 235,065 COMBOBOX cCombo 	ITEMS 	aItems SIZE 50,50 pixel of oDlgCarga
@ 235,125 COMBOBOX cCombo1 	ITEMS 	aItems1 SIZE 80,50 pixel of oDlgCarga
/*
oNRepor := TCHECKBOX():Create(oDlgCarga)
oNRepor:cName := "oNRepor"
oNRepor:cCaption := "N„o Repor"
oNRepor:nLeft := 005
oNRepor:nTop := 580
oNRepor:nWidth := 89
oNRepor:nHeight := 21
oNRepor:lShowHint := .F.
oNRepor:lReadOnly := .F.
oNRepor:Align := 0
oNRepor:lVisibleControl := .T.
oNRepor:cVariable := "lRepor"
oNRepor:bSetGet := {|u| If(PCount()>0,lRepor:=u,lRepor) }
*/
if !empty(GetNewPar("MV_XTPVAL"," "))
	@ 255,000 CHECKBOX oTpVal VAR lTpVal PROMPT GetNewPar("MV_XTPVAL"," ") FONT oDlgCarga:oFont PIXEL SIZE 80, 09 OF oDlgCarga
endif

If	lRepor
	//	@ 295,000 CHECKBOX oNRepor 	VAR 	lRepor PROMPT "N„o Repor" FONT oDlgCarga:oFont PIXEL SIZE 80, 09 OF oDlgCarga When .F.
	//	oNRepor:lReadOnly := .T.
	//Else
	//	@ 295,000 CHECKBOX oNRepor 	VAR 	lRepor PROMPT "N„o Repor" FONT oDlgCarga:oFont PIXEL SIZE 80, 09 OF oDlgCarga
Endif
@ 255,065 say "Carga Principal: " pixel
@ 255,130 Get oEmbComp  var cEmbComp  Size 30,05 valid fValidComp() pixel
//@ 234,222 Get oRemove  var cRemove   Size 50,10 valid LocalizSel(1) pixel

//	@ 275,150 say "Carga Mae:" pixel
//	@ 275,200 MsGet oXEMBMAE var cXEMBMAE picture "@E 999999" When .T. pixel



//If MV_PAR05 < dDataBase + 2     // Cleverson em 01/03/2007
@ 235,250 say "Motivo Carga Extra:" pixel
@ 235,320 MsGet oMotCrgEx var cMotCrgEx picture "@!" valid len(alltrim(cMotCrgEx))>10 .Or. Alltrim(cCombo) <> "Extra" SIZE 150,10 When .T. pixel
//EndIf


@ 250,260 BmpButton Type 2 Action oDlgCarga:End()
If !lVisu
	@ 250,290 BmpButton Type 1 Action fConfOK()
Endif
//Alert(Len(aOrigem))
//If	Len(aOrigem) <= 0
//	aOrigem  :={{"","","","",0,""}}
//Endif





RefazRem()
RefazConf()

Activate Dialog oDlgCarga //centered

SET KEY K_F12 to

U_SPEXEC("VALCARGA"+cEMPANT+"0",{cEmb})
//TCSPEXEC("VALCARGA"+cEMPANT+"0",strzero(val(cEmb)+500000,6))

Return
********************************
Static Function MvOriRem()
********************************
Local aAux:={}
Local i:=0
Local lAprov := .T.
If len(aOrigem) > 0
	
	If	!fValidaPed(aorigem[oOrigem:nAt,1],1)
		Return(.F.)
	Endif
	// SSI 6321 - FABIO COSTA 21/05/15
	// EM 15/10/18 -> REALIZAR A VALIDA«√O EM TODAS AS UNIDADES - SSI 69518
	//If cEmpAnt = "22"

	If !( cEmpAnt $ ("18|21|22|23|24|") )
		If U_ORTP182(SC5->C5_CLIENTE) .AND. Alltrim(posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJAENT,"A1_XTIPO")) $ ("3|4")
			If cEmpAnt == "15" 
				MsgBox("Franquia com Serasa desatualizado, favor regularize para poder prosseguir.")							
				Return .F.
			Else
				MsgBox("Franquia com Serasa desatualizado, providencie a regularizaÁ„o atÈ 20/09.")				
			Endif
		Endif
	Endif

	If fTemCob(SC5->C5_CLIENTE) .AND. Alltrim(posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJAENT,"A1_XTIPO")) $ ("1|2")
		If MsgNoYes("Cliente com tÌtulos na cobranÁa.Inclus„o somente com liberaÁ„o do Gerente Geral. Prosseguir?"," AtenÁ„o ")
			lAprov := u_fValUSU("LIBCARGA","LiberaÁ„o Gerente Geral")
			IF lAprov
				_cInsReq := " INSERT INTO SIGA.LOGROTINA (UN, USUARIO, DTLOG, HORA, ROTINA, CNT, OBSERV) "
				_cInsReq += " VALUES ('"+cEmpAnt+"','"+__CUSERID+"','"+DTOC(dDatabase)+"','"+time()+"','ORTP002','N','"+SC5->C5_CLIENTE+"')"
				
				TcSqlExec(_cInsReq)
				TcSqlExec('commit')
			EndIf
		Else
			lAprov := .F.
		Endif
	Endif
	
	If !lAprov
		Return(.F.)
	Endif
	
	//Endif
	// -------------------
	
	//SSI 104633 - 06/11/20
	If !empty(SC5->C5_XTPENTR) .and. SC5->C5_XTPENTR == '05'
		If !MsgNoYes("Pedido com Entrega Via Operador Logistico. Prosseguir?"," AtenÁ„o ")
			Return(.F.)
		Endif
	Endif

	//SSI 27529 - 07/11/12
	If !empty(SC5->C5_XENTREG) .and. SC5->C5_XENTREG > dDatabase
		If !MsgNoYes("Pedido com ProgramaÁ„o para Entrega Futura: "+Dtoc(SC5->C5_XENTREG)+". Prosseguir?"," AtenÁ„o ")
			Return(.F.)
		Endif
	Endif
	//Fim SSI 27529
	If Empty(aRemessa[1,1])
		aRemessa:={}
	endif
	
	//oSayPed:cCaption := aorigem[oOrigem:nAt,1]
	if !lIncEmb
		fPedRet(aorigem[oOrigem:nAt,1])
	Endif
	
	cNPED	:=	AllTrim(aorigem[oOrigem:nAt,1])
	cNomCli	:=	AllTrim(aorigem[oOrigem:nAt,4])
	
	
	//    cordemb := len(aremessa)+1
	cordemb := soma1(cordemb,4)
	
	//	cordemb2 :=strzero(cordemb,2,0)
	
	aadd(aRemessa,aOrigem[oOrigem:nAt])
	if lTpVal
		aadd(aRemessa[len(aRemessa)],"T")
	else
		aadd(aRemessa[len(aRemessa)]," ")
	endif
	aadd(aRemessa[len(aRemessa)],cordemb)
	For i:=1 to len(aOrigem)
		If i <> oOrigem:nAt
			aadd(aAux,aOrigem[i])
		Endif
	next
	aOrigem:=aAux
	RefazRem()
	oRemessa:nAt	:=	Len(aRemessa)
endif
Return
*********************************
Static Function fVldRem()
*********************************
Local lRet:=.T.
Local nPos:=0
Local _cqped,_cLastAlias
If !Empty(cRem) .and. Len(crem)==6
	
	nPos:=ascan(aOrigem,{|x| x[1]==cRem})
	if nPos > 0
		//		oSayPed:cCaption := cRem
		If	!fValidaPed(cRem,1)
			Return(.F.)
		Endif
		
		if !lIncEmb
			fPedRet(cRem)
		Endif
		cNPed := cRem
		oOrigem:nAt:=nPos
		MvOriRem()
		oRem:SetFocus()
		cRem:=space(6)
		
	else
		nPos:=ascan(aRemessa,{|x| x[1]==cRem})
		if nPos > 0
			MsgBox("Pedido ja selecionado para remessa")
			lRet:=.F.
		else
			nPos:=ascan(aConfere,{|x| x[1]==cRem})
			if nPos > 0
				MsgBox("Pedido ja selecionado para previsao")
				lRet:=.F.
			else
				_clastAlias := Alias()
				_cqped := "SELECT C5_XDTLIB, C5_NOTA, C6_ENTREG, C5_XOPER, C5_XEMBARQ FROM "+_ctabc5+","+_ctabc6
				_cqped += " WHERE C5_NUM='"+cRem+"' AND C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM AND "+_ctabc5+".D_E_L_E_T_=' ' AND "+_ctabc6+".D_E_L_E_T_=' ' AND C5_FILIAL = '"+xFilial("SC5")+"'"
				tcquery _cqped new alias "TQP"
				If TQP->(EOF())
					MsgBox("Pedido inexistente","AtenÁ„o")
					lRet:=.F.
				ElseIf Empty(Alltrim(TQP->C5_XDTLIB))
					MsgBox("Pedido nao liberado","AtenÁ„o")
					lRet:=.F.
				ElseIf !Empty(Alltrim(TQP->C5_NOTA))
					MsgBox("Pedido ja faturado","AtenÁ„o")
					lRet:=.F.
					//				ElseIf STOD(TQP->C6_ENTREG)<MV_PAR03 .OR. STOD(TQP->C6_ENTREG)>MV_PAR04
					//					MsgBox("Pedido com entrega fora do parametro","AtenÁ„o")
				ElseIf TQP->C5_XOPER=="99"
					MsgBox("Pedido cancelado","AtenÁ„o")
					lRet:=.F.
				ElseIf TQP->C5_XEMBARQ <> " "
					MsgBox("Pedido Programado no Embarque: "+TQP->C5_XEMBARQ,"AtenÁ„o")
					lRet:=.F.
				ELSE
					dbselectarea("SZE")
					dbsetorder(3)
					if dbseek(xFilial("SZE")+cRem+"BLQPNV") .and. empty(SZE->ZE_USUARIO)
						MsgBox(SZE->ZE_OBS,"Bloqueio Financeiro")
						lRet:=.F.
					endif
					dbgotop()
					dbseek(xFilial("SZE")+cRem)
					do while !SZE->(eof()) .and. xFilial("SZE")+cRem==SZE->ZE_FILIAL+SZE->ZE_PEDIDO
						if Empty(SZE->ZE_USUARIO)
							MsgBox(alltrim(SZE->ZE_OBS),"Liberacao estornada")
							lRet:=.F.
							dbselectarea("SC5")
							dbsetorder(1)
							if dbseek(xFilial("SC5")+SZE->ZE_PEDIDO) .and. !empty(SC5->C5_XDTLIB)
								reclock("SC5",.F.)
								SC5->C5_XDTLIB:=ctod("  /  /  ")
								msunlock()
							endif
							dbselectarea("SZE")
						endif
						SZE->(dbskip())
					enddo
				Endif
				TQP->(dbCloseArea())
				If !Empty(_cLastAlias)
					dbSelectArea(_cLastAlias)
				Endif
			endif
		endif
		//lRet:=.F.
		cRem:=space(6)
	endif
	
ElseIf !Empty(crem2) .and. len(crem2)==7
	nPos:=ascan(aOrigem,{|x| x[7]==cRem2})
	if nPos > 0
		//		oSayPed:cCaption := cRem2
		if !lIncEmb
			fPedRet(cRem2)
		Endif
		cNPed := cRem2
		oOrigem:nAt:=nPos
		MvOriRem()
		oRem2:SetFocus()
		cRem2:=space(7)
	else
		nPos:=ascan(aRemessa,{|x| x[7]==cRem2})
		if nPos > 0
			MsgBox("Pedido ja selecionado para remessa")
		else
			nPos:=ascan(aConfere,{|x| x[6]==cRem2})
			if nPos > 0
				MsgBox("Pedido ja selecionado para previsao")
			else
				_clastAlias := Alias()
				_cqped := "SELECT C5_XDTLIB,C5_NOTA,C6_ENTREG, C5_XOPER, C5_XEMBARQ FROM "+_ctabc5+","+_ctabc6
				_cqped += " WHERE C5_XNPVORT='"+cRem2+"' AND C6_FILIAL=C5_FILIAL AND C6_NUM=C5_NUM AND "+_ctabc5+".D_E_L_E_T_=' ' AND "+_ctabc6+".D_E_L_E_T_=' '"
				tcquery _cqped new alias "TQP"
				If TQP->(EOF())
					MsgBox("Pedido inexistente","AtenÁ„o")
				ElseIf Empty(Alltrim(TQP->C5_XDTLIB))
					MsgBox("Pedido nao liberado","AtenÁ„o")
				ElseIf !Empty(Alltrim(TQP->C5_NOTA))
					MsgBox("Pedido ja faturado","AtenÁ„o")
					//				ElseIf STOD(TQP->C6_ENTREG)<MV_PAR03 .OR. STOD(TQP->C6_ENTREG)>MV_PAR04
					//					MsgBox("Pedido com entrega fora do parametro","AtenÁ„o")
				ElseIf TQP->C5_XOPER=="99"
					MsgBox("Pedido cancelado","AtenÁ„o")
				ElseIf TQP->C5_XEMBARQ <> " "
					MsgBox("Pedido Programado no Embarque: "+TQP->C5_XEMBARQ,"AtenÁ„o")
				else
					dbselectarea("SZE")
					dbsetorder(3)
					if dbseek(xFilial("SZE")+cRem2+"BLQPNV") .and. empty(SZE->ZE_USUARIO)
						MsgBox(SZE->ZE_OBS,"Bloqueio Financeiro")
					endif
					
				Endif
				TQP->(dbCloseArea())
				If !Empty(_cLastAlias)
					dbSelectArea(_cLastAlias)
				Endif
			endif
		endif
		lRet:=.F.
		cRem:=space(6)
	endif
	
endif

oRemessa:nAt	:=	Len(aRemessa)
//oRemessa:nAt	:=	Len(aRemessa)
oRemessa:Refresh()

return(lRet)
******************************
Static Function RefazRem()
******************************
RefazOri()
oRemessa:SetArray(aRemessa)
oRemessa:nAt:=1
oRemessa:bLine:={|| {aRemessa[oRemessa:nAt, 1],aRemessa[oRemessa:nAt, 2], aRemessa[oRemessa:nAt, 4],;
Transform(aRemessa[oRemessa:nAt, 5],"@E 999,999.999"),aRemessa[oRemessa:nAt, 6],aRemessa[oRemessa:nAt, 7],If(!Empty(aRemessa[oRemessa:nAt, 8]),;
GetNewPar("MV_XTPVAL","  ")," ")}}
oRemessa:Refresh()
Return()
******************************
Static Function RefazConf()
******************************
if cEmpAnt$("03|04|15") //.and. dtos(MV_PAR05)<"20110601"
	RefazOri()
	oConfere:SetArray(aConfere)
	oConfere:nAt:=1
	oConfere:bLine:={|| {aConfere[oConfere:nAt, 1],aConfere[oConfere:nAt, 2], aConfere[oConfere:nAt, 4], Transform(aConfere[oConfere:nAt, 5],"@E 999,999.999"),aConfere[oConfere:nAt, 6],aConfere[oConfere:nAt, 7]}}
	oConfere:Refresh()
endif
Return
******************************
Static Function RefazOri()
******************************
oOrigem:SetArray(aOrigem)
oOrigem:nAt:=1
oOrigem:bLine:={|| {aOrigem[ oOrigem:nAt, 1],aOrigem[oOrigem:nAt, 2],aOrigem[oOrigem:nAt, 4],Transform(aOrigem[oOrigem:nAt, 5],"@E 999,999.999"),aOrigem[oOrigem:nAt, 6],aOrigem[oOrigem:nAt, 7]}}
oOrigem:Refresh()
CalcVal()
Return
******************************
Static Function CalcVal()
******************************
Local cQuery:=""
Local cPedR :=""
Local cPedC :=""
Local cPedTp:=""
Local i:=0
for i:=1 to Len(aConfere)
	cPedC+="'"+aConfere[i,1]+"'"
	if i < Len(aConfere)
		cPedC+=","
	endif
next
for i:=1 to Len(aRemessa)
	if empty(aRemessa[i,8])
		if !empty(cPedR)
			cPedR+=","
		endif
		cPedR+="'"+aRemessa[i,1]+"'"
	else
		if !empty(cPedTp)
			cPedTp+=","
		endif
		cPedTp+="'"+aRemessa[i,1]+"'"
	endif
next
if len(alltrim(cPedR))+Len(alltrim(cPedC)) > 5
	cQuery:="SELECT SUM(ESPR) ESPR, SUM(ESPC) ESPC, SUM(VLRR) VLRR, SUM(VLRC) VLRC, SUM(VLTP) VLTP FROM ("
	if Len(alltrim(cPedR))>5
		//		cQuery+="SELECT SUM(C6_QTDVEN*B1_XESPACO) ESPR,  SUM(C6_QTDVEN*C6_PRCVEN) VLRR, 0 ESPC, 0 VLRC "
		//		cQuery+="SELECT SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) ESPR,  "
		//ALTERADO POR DUPIM EM 08/06/11
		cQuery+="SELECT SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) ESPR,  "
		cQuery+=" SUM(DECODE(C6_QTDVEN,0,C6_VALOR,C6_QTDVEN*C6_PRCVEN)) VLRR, 0 ESPC, 0 VLRC, 0 VLTP "
		cQuery+="FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SB1")+" SB1,"+RetSqlName("SBM")+" SBM "
		cQuery+="WHERE SC6.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND SB1.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND SBM.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND SC5.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND C5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery+="  AND C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery+="  AND BM_FILIAL = '" + xFilial("SBM") + "' "
		cQuery+="  AND B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery+="  AND C6_PRODUTO = B1_COD     "
		cQuery+="  AND C5_NUM     = C6_NUM     "
		cQuery+="  AND BM_GRUPO = B1_GRUPO     "
		cQuery+="  AND C6_NUM IN ("+cPedR+")   "
		if Len(alltrim(cPedC)) > 5 .or. Len(alltrim(cPedTp)) > 5
			cQuery+="UNION "
		endif
	endif
	if Len(alltrim(cPedTp))>5
		//		cQuery+="SELECT SUM(C6_QTDVEN*B1_XESPACO) ESPR,  SUM(C6_QTDVEN*C6_PRCVEN) VLRR, 0 ESPC, 0 VLRC "
		//		cQuery+="SELECT SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) ESPR,  "
		//ALTERADO POR DUPIM EM 08/06/11
		cQuery+="SELECT SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END) ESPR,  "
		cQuery+="  SUM(DECODE(C6_QTDVEN,0,C6_VALOR,C6_QTDVEN*C6_PRCVEN)) VLRR, 0 ESPC, 0 VLRC, SUM(C6_QTDVEN*C6_PRCVEN) VLTP "
		cQuery+="FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SB1")+" SB1,"+RetSqlName("SBM")+" SBM "
		cQuery+="WHERE SC6.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND SB1.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND SBM.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND SC5.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND C5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery+="  AND C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery+="  AND BM_FILIAL = '" + xFilial("SBM") + "' "
		cQuery+="  AND B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery+="  AND C6_PRODUTO = B1_COD     "
		cQuery+="  AND C5_NUM     = C6_NUM     "
		cQuery+="  AND BM_GRUPO = B1_GRUPO     "
		cQuery+="  AND C6_NUM IN ("+cPedTp+")   "
		if Len(alltrim(cPedC)) > 5
			cQuery+="UNION "
		endif
	endif
	
	if Len(alltrim(cPedC))>5
		//		cQuery+="SELECT 0 ESPR, 0 VLRR, SUM(C6_QTDVEN*B1_XESPACO) ESPC, SUM(C6_QTDVEN*C6_PRCVEN) VLRC "
		
		//		cQuery+="SELECT 0 ESPR, 0 VLRR, SUM(CASE WHEN BM_XSUBGRU = '20003I' THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END)  ESPC,
		//Alterado por dupim em 08/06/2011
		cQuery+="SELECT 0 ESPR, 0 VLRR, SUM(CASE WHEN B1_XMODELO IN ('000008','000018') THEN C6_UNSVEN*B1_XESPACO ELSE C6_QTDVEN*B1_XESPACO/DECODE(C5_XTPCOMP,'V',3,'C',2,1) END)  ESPC, "
		cQuery+="SUM(DECODE(C6_QTDVEN,0,C6_VALOR,C6_QTDVEN*C6_PRCVEN)) VLRC, 0 VLTP "
		cQuery+="FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SB1")+" SB1,"+RetSqlName("SBM")+" SBM "
		cQuery+="WHERE SC6.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND SB1.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND SBM.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND SC5.D_E_L_E_T_ <> '*'   "
		cQuery+="  AND C5_FILIAL = '" + xFilial("SC5") + "' "
		cQuery+="  AND C6_FILIAL = '" + xFilial("SC6") + "' "
		cQuery+="  AND BM_FILIAL = '" + xFilial("SBM") + "' "
		cQuery+="  AND B1_FILIAL = '" + xFilial("SB1") + "' "
		cQuery+="  AND C6_PRODUTO = B1_COD     "
		cQuery+="  AND C5_NUM     = C6_NUM     "
		cQuery+="  AND BM_GRUPO = B1_GRUPO     "
		cQuery+="  AND C6_NUM IN ("+cPedC+")   "
	endif
	cQuery+=")A   "
	MEMOWRIT("C:\ORTP002_CARGA.SQL",cQuery)
	If Select("QRY") > 0;QRY->(DbCloseArea());Endif
	
	TCQuery cQuery ALIAS "QRY" NEW
	
	dbselectarea("QRY")
	nValTot  :=QRY->VLRR+QRY->VLRC
	//	aLERT(NVALTOT)
	nValConf :=QRY->VLRC
	nValRem  :=QRY->VLRR
	nValTP   :=QRY->VLTP
	nValPConf:=ROUND((QRY->VLRC/nValTot)*100,2)
	nValPRem :=ROUND((QRY->VLRR/nValTot)*100,2)
	nEspTot  :=QRY->ESPR+QRY->ESPC
	nEspConf :=QRY->ESPC
	nEspRem  :=QRY->ESPR
	nEspPConf:=ROUND((QRY->ESPC/nEspTot)*100,2)
	nEspPRem :=ROUND((QRY->ESPR/nEspTot)*100,2)
	oEspTot:Refresh()
	oValTot:Refresh()
	oEspConf:Refresh()
	oEspRem:Refresh()
	oValConf:Refresh()
	oValRem:Refresh()
	dbclosearea()
endif
return

****************************
Static Function ConfEmb()
****************************

Local cQuery	  	:=	""
Local cPedR 	  	:=	""
Local cPedC 	  	:=	""
Local lRet  	  	:=	.T.
Local lAchouPid  	:= 	.F.
Local lAchouNPid 	:= 	.F.
Local nTotIpi 		:= 	0
Local	__cPed		:=	""
Local aItens2       := {}
Local __nCountR		:=	0
Local lP03CamaGC	:= .F.
Local i:=0
Local w:=0
Local u:=0
DbSelectArea("SX5")
dbOrderNickName("PSX51")

If	MsSeek(xFilial("SX5")+"PO",.F.)
	
	While !EOF() .AND.	X5_TABELA == "PO"
		AADD(aItens2,{X5_CHAVE,X5_DESCRI})
		DbSkip()
	Enddo
	
Endif


__aArea	:=	GetArea()


If	cCombo	==	"Complementar"	.And.	Empty(cEmbComp)
	Alert("N„o foi informado o n˙mero da Carga Complementar")
	Return(.F.)
Endif

if upper(alltrim(cCombo)) == "REFATURAMENTO"
	Alert("Tipo de carga nao permitido")
	Return(.F.)
Endif


For i:=1 to Len(aConfere)
	If	Empty(__cPed)
		__cPed+="'"+aConfere[i,1]+"'"
	Else
		__cPed+=",'"+aConfere[i,1]+"'"
	Endif
	
Next

For i:=1 to Len(aRemessa)
	If	Empty(__cPed)
		__cPed+="'"+aRemessa[i,1]+"'"
	Else
		__cPed+=",'"+aRemessa[i,1]+"'"
	Endif
	
Next

//Verifica se existe algum pedido N√O REPOR misturado com outros pedidos


If	!fPedMist("'04','20'",__cPed)
	Return(.F.)
Endif
If	!fPedMist("'22'",__cPed)
	Return(.F.)
Endif
If	!fPedMist("'12'",__cPed)
	Return(.F.)
Endif

//Verifica se existe algum pedido de Prestacao de Servicos misturado com outros pedidos
If	!fPedMist("'18'",__cPed)
	Return(.F.)
Endif


//Verifica se tem algum pedido com SC9 e estorna sua liberaÁ„o
fRetLib(__cPed)


If lRepor	//.and. !lRep
	If !MsgBox("Tem certeza que deseja alterar os pedido para 'N„o Repor' (S), ou abortar (N)?","ATEN«√O!","YESNO")
		Return(.F.)
	Endif
	
	
	
	//	Alert(__cPed)
	If len(alltrim(__cPed)) > 0
		
		__cQry	:=	"SELECT COUNT(*) COUNT FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND D_E_L_E_T_ = ' ' AND C5_NUM IN ("+__cPed+") AND (C5_XOPER NOT IN ('01','04','12','20') OR C5_XTPSEGM NOT IN('3','4','8')) "
		
		MEMOWRIT("C:\NRP.SQL",__cQry)
		
		TCQUERY __cQry ALIAS "NRP" NEW
		
		DbSelectArea("NRP")
		
		If NRP->COUNT > 0
			Alert("Existem pedidos selecionados que n„o devem ser alterados para N„o Repor. Verificar!")
			NRP->(DbClosearea())
			Return(.F.)
		EndIf
		
		NRP->(DbClosearea())
		
		cQuery	:=	"UPDATE "+RetSqlName("SC5")
		cQuery	+=	" SET C5_XOPERAN = C5_XOPER, C5_XOPER = '04' "
		cQuery	+=	" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND D_E_L_E_T_ = ' ' AND C5_NUM IN ("+__cPed+") AND C5_XOPER IN ('01','04') "
		Begin Transaction
		If TCSQLExec(cQuery) < 0
			MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro Nao Repor","ERRO NR")
			Return(.F.)
		Endif
		
		End Transaction
	Endif
	
Endif
cPedR:=""
for i:=1 to Len(aRemessa)
	if !empty(cPedR)
		cPedR+=","
	endif
	cPedR+="'"+aRemessa[i,1]+"'"
next
cQuery	:=	"SELECT C6_NUM,C6_ITEM,c6.r_e_c_n_o_ REC, fm_ts, b1_origem, f4_sittrib, f4_cf "
cQuery	+=	" FROM "+RetSqlName("SA1") +" a1, "+RetSqlName("SB1") +" b1, "+RetSqlName("SC5") +" c5, "+RetSqlName("SC6") +" c6, "
cQuery	+=  RetSqlName("SFM") +" fm, "+RetSqlName("SF4") +" f4 "
cQuery	+=	" WHERE a1_filial = '"+xFilial("SA1")+"' "
cQuery	+=	" AND b1_filial = '"+xFilial("SB1")+"' "
cQuery	+=	" AND c5_filial = '"+xFilial("SC5")+"' "
cQuery	+=	" AND c6_filial = '"+xFilial("SC6")+"' "
cQuery	+=	" AND fm_filial = '"+xFilial("SFM")+"'  "
cQuery	+=	" AND f4_filial = '"+xFilial("SF4")+"'  "
cQuery	+=	" AND a1.d_e_l_e_t_ = ' ' "
cQuery	+=	" AND b1.d_e_l_e_t_ = ' ' "
cQuery	+=	" AND c5.d_e_l_e_t_ = ' ' "
cQuery	+=	" AND c6.d_e_l_e_t_ = ' ' "
cQuery	+=	" AND fm.d_e_l_e_t_ = ' ' "
cQuery	+=	" AND f4.d_e_l_e_t_ = ' ' "
cQuery	+=	" AND a1_cod = c5_cliente "
cQuery	+=	" AND a1_loja = c5_lojacli "
cQuery	+=	" AND c5_num = c6_num "
cQuery	+=	" AND c6_produto = b1_cod "
cQuery	+=	" AND c5_xoper <> '22' "
cQuery	+=	" AND b1_grtrib = fm_grprod "
cQuery	+=	" AND a1_grptrib = fm_grtrib "
cQuery	+=	" AND fm_tipo = c5_xoper "
cQuery	+=	" AND fm_ts <> c6_tes "
cQuery	+=	" AND f4_codigo = fm_ts "
cQuery	+=	" AND c5_num in ("+cPedR+") "

MEMOWRIT("C:\TES.SQL",cQuery)

TCQUERY cQuery ALIAS "NRPAT" NEW

DbSelectArea("NRPAT")

While !EOF()
	DbSelectArea("SC6")
	DbGoTo(NRPAT->REC)
	If NRPAT->C6_NUM = SC6->C6_NUM	.And.	NRPAT->C6_ITEM = SC6->C6_ITEM
		RecLock("SC6",.F.)
		SC6->C6_TES	    :=NRPAT->FM_TS
		SC6->C6_CF	    :=SUBSTR(C6_CF,1,1)+SUBSTR(NRPAT->F4_CF,2,3)
		SC6->C6_CLASFIS :=NRPAT->B1_ORIGEM+NRPAT->F4_SITTRIB
		MsUnlock()
	Endif
	DbSelectArea("NRPAT")
	DbSkip()
EndDo
NRPAT->(DbCloseArea())


//######### VALIDA ESPACO DO CAMINHAO

// VERIFICA PERCENTUAL
nPercCam := nEspCam * 0.95 //colocar parametro

_cMsgBlq := ""  //mensagens de bloqueio

nBlqCarga := 0

if nEspTot < nPercCam .and. ALLTRIM(UPPER(cCombo1)) <> "RETIRA"
	_cMsgBlq += "1) Carga nao ocupou 95% do espaco do caminhao !" + ENTER
	nBlqCarga := 1
endif

cPedCarga := __cPed
//######## RETORNA QTD DE ROTAS DIFERENTES PARA A CARGA
_nRota := fValRota(__cPed)

if _nRota > 1
	_cMsgBlq += "2) Carga possui " + ALLTRIM(STR(_nRota))+ " rotas distintas !" + ENTER
	nBlqCarga := 2
endif

if (_nRota > 1) .and. (nEspTot < nPercCam)
	nBlqCarga := 3
endif


//####### JUSTIFICATIVA
IF !empty(_cMsgBlq)
	_cMsgBlq2 := "Carga com os seguintes bloqueios :" + ENTER
	_cMsgBlq2 += _cMsgBlq + ENTER
	_cMsgBlq2 += "Deseja Justificar ? SIM = Justifica ; NAO = Volta pra montagem de carga"
	
	If MsgBox( _cMsgBlq2 ,"ATEN«√O!","YESNO")
		fJustifica() //chama tela pra justificar
		if len(aTabPAP) > 0  //verifica se teve justificativa
			if nEspTot < nPercCam // testa se teve bloqueio de espaco
				if empty(aTabPAP[1][3])
					Aviso("Aviso","Carga Possui bloqueio de espaÁo e n„o possui justificativa !", {"Ok"} )
					return(.F.)
				endif
			endif
			if _nRota > 1 //testa se teve bloqueio de rota
				if empty(aTabPAP[1][4])
					Aviso("Aviso","Carga Possui bloqueio de Rota e n„o possui justificativa !", {"Ok"} )
					return(.F.)
				endif
			endif
		ELSE //CLICOU EM JUSTIFICAR E NAO JUSTIFICOU
			Aviso("Aviso","VocÍ optou por justificar e n„o justificou!", {"Ok"} )
			return(.F.)
		endif
		//SE NAO ENTRAR EM NENHUM IF SEGUE ROTINA
	ELSE //CLICOU EM CANCELAR
		//		ALERT("VOLTA PRA MONTAGEM DE CARGA")
		Return(.F.)
	Endif
ENDIF

RestArea(__aArea)

//Begin Transaction

If lIncEmb
	
	//	While (nHandle := FCREATE("CARGA"+SM0->M0_CODIGO+".SEM", FC_READONLY)) < 0
	//	EndDo
	//	__cQuery	:=	"SELECT MAX(CARGA) EMB"
	//	__cQuery	+=  "  FROM (SELECT ULT - CARGA DIF, LINHA, CARGA "
	//	__cQuery	+=  "          FROM (SELECT CARGA, ULT, ROWNUM LINHA "
	//	__cQuery	+=  "                  FROM (SELECT DISTINCT SUBSTR(ZQ_EMBARQ,2,5) CARGA, "
	//	__cQuery	+=  "                                        (SELECT MAX(SUBSTR(ZQ_EMBARQ,2,5)) "
	//	__cQuery	+=  "	                                        FROM "+RetSqlName("SZQ") "
	//	__cQuery	+=  "	                                        WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND ZQ_DTPREVE = '"+Dtos(MV_PAR05)+"') ULT "
	//	__cQuery	+=  "	             FROM	"+RetSqlName("SZQ") "
	//	__cQuery	+=  "               WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND ZQ_DTPREVE = '"+Dtos(MV_PAR05)+"'"
	//	__cQuery	+=  "               ORDER BY 1 DESC)))	"
	//	__cQuery	+=  "WHERE LINHA = DIF "
	
	
	/*
	
	__cQuery	:= "SELECT NVL(MAX(CARGA),0) EMB "
	__cQuery	+= "  FROM (SELECT ULT - CARGA DIF, LINHA, CARGA "
	__cQuery	+= "          FROM (SELECT CARGA, ULT, ROWNUM LINHA "
	__cQuery	+= "                  FROM (SELECT DISTINCT CASE "
	__cQuery	+= "                                        WHEN ZQ_EMBARQ > 500000 THEN ZQ_EMBARQ - 500000 "
	__cQuery	+= "                                        ELSE ZQ_EMBARQ - 0 END CARGA, "
	__cQuery	+= "                                       (SELECT MAX(ZQ_EMBARQ) "
	__cQuery	+= "                                          FROM (SELECT CASE "
	__cQuery	+= "                                                  WHEN ZQ_EMBARQ > '500000' THEN ZQ_EMBARQ - 500000 "
	__cQuery	+= "                                                  ELSE ZQ_EMBARQ - 0 END ZQ_EMBARQ "
	__cQuery	+= "                                                  FROM "+RetSqlName("SZQ")+" SZQ "
	__cQuery	+= "                                                 WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' "
	__cQuery	+= "	                                                 AND ZQ_DTPREVE > (SELECT MAX(ZQ_DTPREVE) FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND D_E_L_E_T_ = ' ' AND ZQ_OPGERAD = 'S') AND D_E_L_E_T_ = ' ')) ULT "
	//	__cQuery	+= "	                                                 AND ZQ_DTPREVE = '"+Dtos(MV_PAR05)+"' AND D_E_L_E_T_ = ' ')) ULT "
	__cQuery	+= "                          FROM "+RetSqlName("SZQ")+" SZQ "
	__cQuery	+= "                         WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' "
	__cQuery	+= "                           AND ZQ_DTPREVE >= (SELECT MAX(ZQ_DTPREVE) FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND D_E_L_E_T_ = ' ' AND ZQ_OPGERAD = 'S')"
	//	__cQuery	+= "                           AND ZQ_DTPREVE = '"+Dtos(MV_PAR05)+"' "
	__cQuery	+= "                           AND D_E_L_E_T_ = ' ' "
	__cQuery	+= "                        ORDER BY 1 DESC))) "
	__cQuery	+= "          WHERE LINHA - DIF <> 1 "
	
	MEMOWRITE("c:\xxx.sql",__cQuery)
	
	If Select("TRBEMB") > 0;TRBEMB->(DbCloseArea());Endif;
	
	TcQuery	__cQuery	New Alias "TRBEMB"
	
	DbSelectArea("TRBEMB")
	
	//Alert("1-"+TRBEMB->EMB)
	
	//If	EOF() .OR.	TRBEMB->EMB	== 0
	
	*/
	
	//		__cQuery	:=	"SELECT '1' || MAX(EMB) EMB FROM "
	//		__cQuery	+=	"(SELECT MAX(SUBSTR(ZQ_EMBARQ,2,5)) EMB FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND ZQ_EMBARQ < '500000' AND D_E_L_E_T_ = ' '  "
	//		__cQuery	+=	"UNION ALL "
	//		__cQuery	+=  "SELECT MAX(SUBSTR(ZQ_EMBARQ,2,5)) EMB FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND ZQ_EMBARQ >= '500000' AND D_E_L_E_T_ = ' ') NPID "
	//	__cQuery	+=  "SELECT MAX(TO_CHAR(TO_NUMBER(ZQ_EMBARQ-500000))) EMB FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND ZQ_EMBARQ >= '500000' AND D_E_L_E_T_ = ' ') NPID "
	
	/*
	Uma carga com numeraÁ„o acima de 500000 deve pular a numeraÁ„o equivalente na faixa 000001-299999. Exemplo:
	Se existe a carga 712178, a numeraÁ„o 212178 n„o deve ser retornada
	A mesma regra se aplica a faixa 300001-399999
	A regra varia por unidade na faixa 400001-499999
	*/
	__cQuery	:=	" SELECT TO_NUMBER(MAX(ZQ_EMBARQ)) EMB "
	__cQuery	+=	"   FROM (SELECT CASE "
	__cQuery	+=	"                  WHEN ZQ_EMBARQ > '500000' THEN "
	__cQuery	+=	"                   LPAD(TO_CHAR(TO_NUMBER(ZQ_EMBARQ - 500000)), 6, '0') "
	__cQuery	+=	"                  WHEN ZQ_EMBARQ > '400000' THEN "
	__cQuery	+=	"                   LPAD(TO_CHAR(TO_NUMBER(ZQ_EMBARQ - "+alltrim(str(nEmbtp))+")), 6, '0') "
	__cQuery	+=	"                  WHEN ZQ_EMBARQ > '300000' THEN "
	__cQuery	+=	"                   LPAD(TO_CHAR(TO_NUMBER(ZQ_EMBARQ - 200000)), 6, '0') "
//	__cQuery	+=	"                  WHEN ZQ_EMBARQ > '200000' THEN "
//	__cQuery	+=	"                   LPAD(TO_CHAR(TO_NUMBER(ZQ_EMBARQ - "
//	__cQuery	+=	"                                          DECODE(AUX, 1, 200000, 0))), "
//	__cQuery	+=	"                        6, "
//	__cQuery	+=	"                        '0') "
	__cQuery	+=	"                  ELSE "
	__cQuery	+=	"                   LPAD(TO_CHAR(TO_NUMBER(ZQ_EMBARQ - 0)), 6, '0') "
	__cQuery	+=	"                END ZQ_EMBARQ "
	__cQuery	+=	"           FROM "+RetSqlName("SZQ")+" SZQ, "
	__cQuery	+=	"                (SELECT NVL((SELECT MAX(1) "
	__cQuery	+=	"                              FROM " + RetSqlName("SZQ")
	__cQuery	+=	"                             WHERE D_E_L_E_T_ = ' ' "
	__cQuery	+=	"                               AND ZQ_FILIAL = '"+xFilial("SZQ")+"' "
	__cQuery	+=	"                               AND ZQ_EMBARQ = '299999'), "
	__cQuery	+=	"                            0) AS AUX "
	__cQuery	+=	"                   FROM DUAL) "
	__cQuery	+=	"          WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' "
	__cQuery	+=	"            AND ZQ_DTPREVE >= '"+dtos(dDataBase-30)+"' "
	__cQuery	+=	"            AND regexp_like(SZQ.ZQ_EMBARQ, '^-?[[:digit:],.]*$') "
	__cQuery	+=	"            AND D_E_L_E_T_ = ' ') "
	
	If Select("TRBEMB") > 0;TRBEMB->(DbCloseArea());Endif;
	
	TcQuery	__cQuery	New Alias "TRBEMB"
	
	DbSelectArea("TRBEMB")
	cEmb	:=	StrZero(TRBEMB->EMB	+	1,6)
	
	
	cGer:=""
	//	Begin Transaction
	If nValRem-nValtp > 0
		DbSelectArea("SZQ")
		RecLock("SZQ",.T.)
		SZQ->ZQ_FILIAL 	:=	xFilial("SZQ")
		SZQ->ZQ_EMBARQ	:=	AllTrim(cEmb)
		SZQ->ZQ_DTPREVE :=	MV_PAR05
		If cEmpAnt == '24'
			_cHoraT	:=	Dtoc(Date())+"-"+Time()
			SZQ->ZQ_OPGERAD	:= "S"
			//SZQ->ZQ_DTFECHA	:= "S"
			SZQ->ZQ_HORAT := _cHoraT
		EndIF
		DbSelectArea("SZQ")
		MsUnlock()
		cGer:=cEmb
		fGuardaJust("2",,,AllTrim(cEmb),cPedCarga)  // guarda justificativa
	Endif
	
	If nValtp > 0
		DbSelectArea("SZQ")
		Reclock("SZQ",.T.)
		SZQ->ZQ_FILIAL  := xFilial("SZQ")
		SZQ->ZQ_EMBARQ  := StrZero(Val(cEmb)+nEmbTp,6)
		SZQ->ZQ_DTPREVE :=	MV_PAR05
		If cEmpAnt == '24'
			_cHoraT	:=	Dtoc(Date())+"-"+Time()
			SZQ->ZQ_OPGERAD	:= "S"
			//SZQ->ZQ_DTFECHA	:= "S"
			SZQ->ZQ_HORAT := _cHoraT
		EndIF
		
		MsUnlock()
		fGuardaJust("2",,,StrZero(Val(cEmb)+nEmbTp,6),cPedCarga)  // guarda justificativa
		if !empty(cGer)
			cGer+="-"+StrZero(Val(cEmb)+nEmbTp,6)
		else
			cGer:=StrZero(Val(cEmb)+nEmbTp,6)
		endif
	Endif
	If nValConf > 0
		DbSelectArea("SZQ")
		Reclock("SZQ",.T.)
		SZQ->ZQ_FILIAL  := xFilial("SZQ")
		SZQ->ZQ_EMBARQ  := StrZero(Val(cEmb)+500000,6)
		SZQ->ZQ_DTPREVE :=	MV_PAR05
		If cEmpAnt == '24'
			_cHoraT	:=	Dtoc(Date())+"-"+Time()
			SZQ->ZQ_OPGERAD	:= "S"
			//SZQ->ZQ_DTFECHA	:= "S"
			SZQ->ZQ_HORAT := _cHoraT
		EndIF
		
		MsUnlock()
		fGuardaJust("2",,,StrZero(Val(cEmb)+500000,6),cPedCarga)  // guarda justificativa
		if !empty(cGer)
			cGer+="-"+StrZero(Val(cEmb)+500000,6)
		else
			cGer:=StrZero(Val(cEmb)+500000,6)
		endif
	Endif
	
	//	End Transaction
	
	MsgAlert("Embarques que est„o sendo gerados:"+cGer,"AtenÁ„o !")
	
Endif
If nValTot > 0
	If !fInfFrt()            // Tela para informaÁıes de Frete.
		//	MsgBox("Embarque n„o pode ser gerado sem informaÁıes de Frete!","ATEN«√O","ALERT")
		Return(.F.)
	EndIf
Endif

if nValTot > 0
	cPedc:=""
	For i:=1 to Len(aConfere)
		cPedC+="'"+aConfere[i,1]+"'"
		If i < Len(aConfere)
			cPedC+=","
		endif
	Next
	cPedR:=""
	For i:=1 to Len(aRemessa)
		cPedR+="'"+aRemessa[i,1]+"'"
		if i < Len(aRemessa)
			cPedR+=","
		endif
	Next
	cQuery:="UPDATE "+RetSqlName("SC5")
	cQuery+=" SET C5_XEMBARQ = ' ' "
	cQuery+=" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_XEMBARQ IN ('"+cEmb+"','"+strzero(val(cEmb)+nEmbTp,6)+"') AND D_E_L_E_T_ = ' ' "
	If TCSQLExec(cQuery) < 0
		MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 1","ERRO 1")
		lRet:=.F.
	Endif
	If lReT
		cQuery:="UPDATE "+RetSqlName("SC5")
		cQuery+=" SET C5_XEMBARQ = ' ' "
		cQuery+=" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_XEMBARQ = '"+strzero(val(cEmb)+500000,6)+"' "
		cQuery+="   AND D_E_L_E_T_ = ' ' "
		if TCSQLExec(cQuery) < 0
			MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 2","ERRO 2")
			lRet:=.F.
		endif
	endif
	
	
	/*
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥FunÁ„o recebe array com os pedidos excluidos da carga e estorna sua liberaÁ„o≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	if !lIncEmb
	//__cPedRet	:=	fRetLib(_aPedRet)
	
	If	!Empty(__cPedRet)
	cQuery:="UPDATE "+RetSqlName("SC6")
	cQuery+=" SET C6_LOCAL = '"+__cLocPed+"' "
	cQuery+=" WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND D_E_L_E_T_ = ' '
	cQuery+="       AND C6_NUM IN(SELECT C5_NUM FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"'  AND C5_NUM IN ("+__cPedRet+") AND D_E_L_E_T_ = ' ') "
	cQuery+="       AND C6_LOCAL <> '"+__cLocPed+"' "
	
	MEMOWRIT("C:\1A.SQL",cQuery)
	
	If TCSQLExec(cQuery) < 0
	MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 1A","ERRO 1A")
	lRet:=.F.
	Endif
	
	
	If	lRet
	fLibPed(__cPedRet)
	Endif
	
	Endif
	
	Endif
	*/
	/*
	__aAreaR	:=	GetArea()
	
	//Atualiza Reserva dos pedidos PID que estiverem em Local diferente do __cLocPID
	If lRet
	
	cQuery	:=	"SELECT C6_PRODUTO,3, SUM(C6_QTDVEN) QUANT, (SELECT R_E_C_N_O_ FROM "+RetSqlName("SB2")+" WHERE B2_FILIAL = '"+xFilial("SB2")+"' "
	cQuery	+=	"                                           AND D_E_L_E_T_ = ' ' AND B2_COD = C6_PRODUTO AND B2_LOCAL = C6_LOCAL ) B2ORI, "
	cQuery	+=	"                                         (SELECT R_E_C_N_O_ FROM "+RetSqlName("SB2")+" WHERE B2_FILIAL = '"+xFilial("SB2")+"' "
	cQuery	+=	"                                           AND D_E_L_E_T_ = ' ' AND B2_COD = C6_PRODUTO AND B2_LOCAL = '"+__cLocPID+"' ) B2DES "
	cQuery	+=	" FROM "+RetSqlName("SC6")+" C6 WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND D_E_L_E_T_ = ' ' AND C6_NUM IN ("+cPedR+" ) AND C6_LOCAL <>  '"+__cLocPID+"' "
	cQuery	+=	" GROUP BY C6_PRODUTO,C6_LOCAL			 "
	cQuery	+=	" ORDER BY C6_PRODUTO "
	
	TCQUERY cQuery ALIAS "RES" NEW
	Dbselectarea("RES")
	
	While !EOF()
	DbSelectArea("SB2")
	DbGoTo(RES->B2ORI)
	If !EOF()
	RecLock("SB2",.F.)
	B2_RESERVA	-=	RES->QUANT
	MsUnlock()
	Endif
	DbGoTo(RES->B2DES)
	If !EOF()
	RecLock("SB2",.F.)
	B2_RESERVA	+=	RES->QUANT
	MsUnlock()
	Endif
	
	DbSelectArea("RES")
	DbSkip()
	EndDo
	DbSelectArea("RES")
	DbCloseArea()
	
	Endif
	
	RestArea(__aAreaR)
	*/
	
	
	If lRet
		
		
		cQuery:="UPDATE "+RetSqlName("SC6")
		cQuery+=" SET C6_LOCAL  = '"+__cLocPID+"' "
		cQuery+=" WHERE  R_E_C_N_O_ IN(SELECT C6.R_E_C_N_O_ FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SB1") +" B1, "+RetSqlName("SC5") +" C5 WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM IN ("+cPedR+" )"
		cQuery+="                         AND B1_FILIAL = '"+xFilial("SB1")+"' AND C5_FILIAL = '"+xFilial("SC5")+"' AND C5.D_E_L_E_T_ = ' ' AND C5_NUM = C6_NUM "  //N√O ALTERA O ALMOXARIFADO DOS PEDIDOS DE VENDA DE INSUMO
		cQuery+="                         AND  C6.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND C6_PRODUTO = B1_COD) "
		
		MEMOWRIT("C:\3.SQL",cQuery)
		Begin Transaction
		if TCSQLExec(cQuery) < 0
			MsgBox("Problemas na atualizaÁ„o do embarque! - " + TCSQLError() + " - Informe Erro 3","ERRO 3")
			lRet:=.F.
		endif
		
		
		
		if cEmpAnt=="16" .or. cEmpAnt=="22"
			cQuery:="UPDATE "+RetSqlName("SC2")
			cQuery+=" SET C2_LOCAL  = '"+__cLocPID+"' "
			cQuery+=" WHERE C2_PEDIDO IN  ("+cPedR+" )"
			cQuery+="   AND D_E_L_E_T_ = ' ' "
			cQuery+="   AND C2_FILIAL  = '"+xFilial("SC2")+"' "
			
			MEMOWRIT("C:\31.SQL",cQuery)
			
			if TCSQLExec(cQuery) < 0
				MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 31","ERRO 31")
				lRet:=.F.
			endif
			
		endif
		End Transaction
		cQuery:="SELECT DISTINCT C6_PRODUTO, C6_LOCAL "
		cQuery+="  FROM "+RetSQLName("SB2")+" SB2, "+RetSQLName("SC6")+" SC6 "
		cQuery+=" WHERE SC6.D_E_L_E_T_ = ' '        "
		cQuery+="   AND SB2.D_E_L_E_T_(+) = ' '     "
		cQuery+="   AND C6_FILIAL    = '"+xFilial("SC6")+"' "
		cQuery+="   AND B2_FILIAL(+) = '"+xFilial("SC2")+"' "
		cQuery+="   AND C6_PRODUTO   = B2_COD(+)    "
		cQuery+="   AND C6_LOCAL     = B2_LOCAL(+)  "
		cQuery+="   AND B2_COD IS NULL              "
		cQuery+="   AND C6_NUM IN ("+cPedR+")       "
		tcquery cQuery ALIAS "CRIASB2" New
		
		dbselectarea("CRIASB2")
		dbgotop()
		do while !eof()
			CriaSB2(CRIASB2->C6_PRODUTO,CRIASB2->C6_LOCAL)
			dbselectarea("CRIASB2")
			dbskip()
		enddo
		dbclosearea()
		/*
		cQuery:="UPDATE "+RetSqlName("SC9")
		cQuery+=" SET C9_LOCAL  = '"+__cLocPID+"' "
		cQuery+=" WHERE  R_E_C_N_O_ IN(SELECT C9.R_E_C_N_O_ FROM "+RetSqlName("SC9")+" C9,"+RetSqlName("SB1") +" B1, "+RetSqlName("SC5") +" C5 WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO IN ("+cPedR+" )"
		cQuery+="                         AND B1_FILIAL = '"+xFilial("SB1")+"' AND C5_FILIAL = '"+xFilial("SC5")+"' AND C5.D_E_L_E_T_ = ' ' AND C5_NUM = C9_PEDIDO AND C5_XOPER <> '22'"  //N√O ALTERA O ALMOXARIFADO DOS PEDIDOS DE VENDA DE INSUMO
		cQuery+="                         AND  C9.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND B1_TIPO <> 'MP' AND C9_PRODUTO = B1_COD) "
		
		
		MEMOWRIT("C:\4.SQL",cQuery)
		If TCSQLExec(cQuery) < 0
		MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 4","ERRO 4")
		lRet:=.F.
		endif
		
		
		*/
		
	endif
	
	
	//Atualiza data de previs„o de entrega com a data da programaÁ„o
	If lRet
		
		cQuery:="UPDATE "+RetSqlName("SC6")
		cQuery+=" SET C6_ENTREG  = '"+Dtos(MV_PAR05)+"' "
		cQuery+=" WHERE  C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM IN ("+cPedR+" ) AND  D_E_L_E_T_ = ' '  "
		
		MEMOWRIT("C:\4A.SQL",cQuery)
		If TCSQLExec(cQuery) < 0
			MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 4A","ERRO 4A")
			lRet:=.F.
		endif
		
		
	Endif
	
	
	/*
	If lRet
	
	cQuery:="UPDATE "+RetSqlName("SC6")
	cQuery+=" SET C6_PRCVEN = NVL((SELECT B1_XCUSTER FROM "+RetSQLName("SB1") +" WHERE D_E_L_E_T_ <> '*'      "
	cQuery+="                                                  	  AND B1_COD = C6_PRODUTO AND B1_XMODELO = '000015' AND B1_XCUSTER >0 ), C6_PRCVEN) ,      "
	cQuery+=" C6_VALOR = NVL((SELECT B1_XCUSTER*C6_QTDVEN FROM "+RetSQLName("SB1") +" WHERE D_E_L_E_T_ <> '*' "
	cQuery+="                                               	  AND B1_COD = C6_PRODUTO AND B1_XMODELO = '000015' AND B1_XCUSTER > 0), C6_VALOR) ,       "
	cQuery+=" C6_VALDESC = NVL((SELECT (C6_XPRUNIT-B1_XCUSTER)*C6_QTDVEN FROM "+RetSQLName("SB1")
	cQuery+="                                  WHERE D_E_L_E_T_ <> '*'  AND B1_COD = C6_PRODUTO AND B1_XMODELO = '000015' AND B1_XCUSTER > 0), C6_VALDESC) "
	cQuery+=" WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND D_E_L_E_T_ = ' ' "
	cQuery+="   AND C6_NUM IN (SELECT C5_NUM FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND D_E_L_E_T_ = ' '     "
	cQuery+="   AND C5_XTPSEGM IN ('3','4') AND C5_XOPER <> '07' AND (C5_NUM IN ("+cPedR+" ) OR C5_NUM IN ("+cPedC+" )))"
	
	If TCSQLExec(cQuery) < 0
	MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 5","ERRO 5")
	lRet:=.F.
	Endif
	
	Endif
	*/
	If lRet
	    if !cEmpAnt$"18|21|22|23|24"
			cQuery:="UPDATE "+RetSQLName("SC6")
			cQuery+="   SET C6_PRCVEN  = C6_PRUNIT, "
			cQuery+="       C6_VALOR   = C6_QTDVEN*C6_PRUNIT, "
			cQuery+="       C6_VALDESC = 0, "
			cQuery+="       C6_DESCONT = 0  "
			cQuery+=" WHERE C6_NUM IN (SELECT C5_NUM "
			cQuery+="                    FROM "+RetSQLName("SC5")+" SC5 "
			cQuery+="                   WHERE SC5.D_E_L_E_T_ = ' '  "
			cQuery+="                     AND C5_FILIAL = '"+xFilial("SC5")+"' "
			cQuery+="                     AND C5_XTPSEGM IN ('1','5','M','I') "
			cQuery+="                     AND (C5_NUM IN ("+cPedR+" ) "
			cQuery+="                      OR  C5_NUM IN ("+cPedC+" ))) "
			cQuery+="   AND D_E_L_E_T_ = ' '  "
			cQuery+="   AND C6_QTDVEN > 0 "
			cQuery+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
			cQuery+="   AND NOT EXISTS (SELECT 'X' FROM SITEFISICO WHERE C6_NUM = NUMPED "
			cQuery+="                               AND C6_PRODUTO = PRODUTO "
			cQuery+="                               AND PRBRU IS NOT NULL "
			cQuery+="                               AND PRBRU <> PRUNIT) "
			if TCSQLExec(cQuery) < 0
				MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 6","ERRO 6")
				lRet:=.F.
			endif
		Endif
		cQuery	:= " SELECT C6_NUM, "
		cQuery	+= "        C5_CLIENTE, "
		cQuery	+= "        C5_EMISSAO, "
		cQuery	+= "        SUM(C6_PRUNIT * C6_QTDVEN * B1_IPI / 100) AS VALPED, "
		cQuery	+= "        C5_XDESPRO, "
		cQuery	+= "        C5_XTPSEGM, "
		cQuery	+= "        SUM(DECODE(B1_POSIPI, '94035000  ', 1, 0)) AS POSIPI, "
		cQuery	+= "        MAX(A3_GEREN) AS GEREN, "
		cQuery	+= "        SC5.R_E_C_N_O_ AS SC5REC "
		cQuery	+= "   FROM "+RetSqlName("SC5")+" SC5, "
		cQuery	+= "        "+RetSqlName("SC6")+" SC6, "
		cQuery	+= "        "+RetSqlName("SB1")+" SB1, "
		cQuery	+= "        "+RetSqlName("SF4")+" SF4, "
		cQuery	+= "        "+RetSqlName("SA3")+" SA3  "
		cQuery	+= "  WHERE SC5.D_E_L_E_T_ = ' ' "
		cQuery	+= "    AND SC6.D_E_L_E_T_ = ' ' "
		cQuery	+= "    AND SB1.D_E_L_E_T_ = ' ' "
		cQuery	+= "    AND SF4.D_E_L_E_T_ = ' ' "
		cQuery	+= "    AND SA3.D_E_L_E_T_ = ' ' "
		cQuery	+= "    AND C5_FILIAL = '"+xFilial("SC5")+"' "
		cQuery	+= "    AND C6_FILIAL = '"+xFilial("SC6")+"' "
		cQuery	+= "    AND B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery	+= "    AND F4_FILIAL = '"+xFilial("SF4")+"' "
		cQuery	+= "    AND A3_FILIAL = '"+xFilial("SA3")+"' "
		cQuery	+= "    AND C5_NUM = C6_NUM "
		cQuery	+= "    AND C6_TES = F4_CODIGO "
		cQuery	+= "    AND F4_IPI = 'S' "
		cQuery	+= "    AND C6_PRODUTO = B1_COD "
		cQuery	+= "    AND C6_QTDVEN > 0 "
		cQuery	+= "    AND C6_NUM IN ("+cPedR+") "
		cQuery	+= "    AND A3_COD = C5_VEND1 "
		cQuery	+= "  GROUP BY C6_NUM, C5_CLIENTE, C5_EMISSAO, C5_XDESPRO, F4_IPI, C5_XTPSEGM, SC5.R_E_C_N_O_ "
		TCQUERY cQuery alias "QRYIPI" NEW
		dbselectarea("QRYIPI")
		dbgotop()
		do while !eof()
			lP03CamaGC	:= .F.
			If cEmpAnt == "03"
				If QRYIPI->POSIPI > 0
					//IncluÌdo o cliente TELE RIO exceÁ„o a pedido da SSI 34047.
					If AllTrim(QRYIPI->GEREN) == "G00150" .And. QRYIPI->C5_CLIENTE <> '999P6Q'
						//XIPIDESCONTO - SSI 53171//
						if QRYIPI->C5_EMISSAO <= GetMv("MV_XDTCDCA",.f.,'20170923')
							lP03CamaGC	:= .T.
						endif
					EndIf
				EndIf
			EndIf
			
			If lP03CamaGC .And. AllTrim(QRYIPI->C5_XDESPRO) <> "2"
				SC5->(dbGoTo(QRYIPI->SC5REC))
				SC5->(RecLock("SC5", .F.))
				SC5->C5_XDESPRO	:= "2"
				SC5->(MsUnLock())
			EndIf
			
			nValIpi:=QRYIPI->VALPED
			nDescAc := round(nValipi * 0.9999,2)
			nValDesc := 0
			dbselectarea("SC6")
			dbOrderNickName("PSC61")
			dbseek(xFilial("SC6")+QRYIPI->C6_NUM)
			do while !eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == QRYIPI->C6_NUM
				dbselectarea("SB1")
				dbOrderNickName("PSB11")
				dbseek(xFilial("SB1")+SC6->C6_PRODUTO)
				dbselectarea("SF4")
				dbOrderNickName("PSF41")
				dbseek(xFilial("SF4")+SC6->C6_TES)
				dbselectarea("SC6")
				RECLOCK("SC6",.F.)
				//XIPIDESCONTO - SSI 53171//
				if lP03CamaGC .Or. ( QRYIPI->C5_XDESPRO == "2" .AND. QRYIPI->C5_XTPSEGM $ "1|5|M|I|" )
					if SB1->B1_IPI > 0 .and. SF4->F4_IPI == 'S'
						SC6->C6_VALDESC:=round(SB1->B1_IPI*SC6->C6_QTDVEN*SC6->C6_PRUNIT/100,2)
						SC6->C6_VALOR  :=round((SC6->C6_QTDVEN*C6_PRUNIT)-SC6->C6_VALDESC,2)
						SC6->C6_PRCVEN :=ROUND(SC6->C6_VALOR/SC6->C6_QTDVEN,2)
						nValdesc += ((SC6->C6_PRUNIT - SC6->C6_PRCVEN) * SC6->C6_QTDVEN)
						//					else
						//						SC6->C6_VALOR  :=SC6->C6_QTDVEN*SC6->C6_PRUNIT
						//						SC6->C6_VALDESC:=0
						//						SC6->C6_PRCVEN :=SC6->C6_PRUNIT
					endif
				elseif QRYIPI->C5_XDESPRO == "1"
					if SB1->B1_IPI > 0 .and. SF4->F4_IPI == 'S'
						IF SC6->C6_XPRUNIT=0
							SC6->C6_XPRUNIT:=SC6->C6_PRCVEN
						ENDIF
						//Comentado em 18/09/2013 - Marcos Furtado - Para aproximar o valor do desconto do ipi
						/*						SC6->C6_PRCVEN :=noround((SC6->C6_XPRUNIT)/(1+(SB1->B1_IPI/100)),4)
						SC6->C6_PRUNIT :=noround((SC6->C6_XPRUNIT)/(1+(SB1->B1_IPI/100)),4)*/
						SC6->C6_PRCVEN :=round((SC6->C6_XPRUNIT)/(1+(SB1->B1_IPI/100)),4)
						SC6->C6_PRUNIT :=round((SC6->C6_XPRUNIT)/(1+(SB1->B1_IPI/100)),4)
						SC6->C6_VALDESC:=0
						SC6->C6_DESCONT:=0
						SC6->C6_VALOR  :=round(SC6->C6_PRCVEN*SC6->C6_QTDVEN,2)
						if SC6->C6_XFEILOJ > 0
							SC6->C6_XFEILOJ :=round((SC6->C6_QTDVEN * SC6->C6_PRUNIT) * 11.828 / 100, 2)
						Endif
						//					else
						//						SC6->C6_VALOR  :=SC6->C6_QTDVEN*SC6->C6_PRUNIT
						//						SC6->C6_VALDESC:=0
						//						SC6->C6_PRCVEN :=SC6->C6_PRUNIT
					endif
					//				else
					//					SC6->C6_VALOR  :=SC6->C6_QTDVEN*SC6->C6_PRUNIT
					//					SC6->C6_VALDESC:=0
					//					SC6->C6_PRCVEN :=SC6->C6_PRUNIT
				endif
				msunlock()
				cPed := SC6->C6_NUM
				dbskip()
				iF cPED != SC6->C6_NUM .and. nValDesc <> 0
					dbskip(-1)
					nDif := nDescAc - nVALDESC + 0.01
					If nDif  <> 0
						RecLock("SC6",.f.)
						SC6->C6_VALDESC:=SC6->C6_VALDESC + nDif
						SC6->C6_VALOR  :=round((SC6->C6_QTDVEN*C6_PRUNIT)-SC6->C6_VALDESC,2)
						SC6->C6_PRCVEN :=ROUND(SC6->C6_VALOR/SC6->C6_QTDVEN,2)
						msunlock()
					endIf
					dbselectarea("SC6")
					dbskip()
				EndIf
			enddo
			nTotIpi += nValIPI
			dbselectarea("QRYIPI")
			dbskip()
		enddo
		dbclosearea()
		
		if cEmpAnt=="07" .OR. cEmpAnt=="23"  .OR. cEmpAnt=="24" // FABRICAS BAHIA (IND. BAIANA E CIAPLAST)
			_nPerBahia 	:= 11.828
			_nDifBahia 	:= (100 - _nPerBahia) / 100
			
			cQuery:="  SELECT C5_NUM, C5_XVERREP "
			cQuery+="     FROM "+RetSQLName("SC5")+" SC5, "+RetSQLName("SC6")+" SC6, "
			cQuery+=             RetSQLName("SB1")+" SB1, "+RetSQLName("SA1")+" SA1, "
			cQuery+=             RetSQLName("SF4")+" SF4  "
			cQuery+="    WHERE SC5.D_E_L_E_T_ = ' '  "
			cQuery+="      AND SC6.D_E_L_E_T_ = ' '  "
			cQuery+="      AND SB1.D_E_L_E_T_ = ' '  "
			cQuery+="      AND SA1.D_E_L_E_T_ = ' '  "
			cQuery+="      AND SF4.D_E_L_E_T_ = ' '  "
			cQuery+="      AND C5_FILIAL = '"+xFilial("SC5")+"' "
			cQuery+="      AND C6_FILIAL = '"+xFilial("SC6")+"' "
			cQuery+="      AND B1_FILIAL = '"+xFilial("SB1")+"' "
			cQuery+="      AND A1_FILIAL = '"+xFilial("SA1")+"' "
			cQuery+="      AND F4_FILIAL = '"+xFilial("SF4")+"' "
			If cEmpAnt == '23'
				cQuery+="      AND A1_GRPTRIB = '103' "
			Else
				cQuery+="      AND A1_GRPTRIB in ('103','019','114') "
			EndIf
			//If cEmpAnt # '24' && Henrique - 06/6/2018 - If incluido para atender a SSI 54934
			//	cQuery+="      AND SC5.C5_XOPER <> '05' " //Pedidos de amostras n„o devem ter o SIMBAHIA.
			//EndIf
			cQuery+="      AND C6_TES = F4_CODIGO     "
			cQuery+="      AND F4_CF <> '5916'        "
			cQuery+="      AND B1_GRTRIB <> '017'     "
			If cEmpAnt == '07'
				cQuery+="      AND B1_GRTRIB IN ('011','013','015','016') "
			ElseIf cEmpAnt == '24'
				cQuery+="      AND B1_GRTRIB > '015'      "
			ElseIf cEmpAnt == '23'
				cQuery+="      AND B1_GRTRIB IN ('001','005') "
			EndIf
			cQuery+="      AND B1_XMODELO NOT IN ('000015','000028') "
			cQuery+="      AND C5_NUM = C6_NUM        "
            cQuery+="      AND C5_XOPER <> '23' "
			cQuery+="      AND C5_NUM IN ("+cPedR+") "
			cQuery+="      AND A1_COD = C5_CLIENTE    "
			cQuery+="      AND A1_LOJA = C5_LOJACLI   "
			cQuery+="      AND C6_PRODUTO = B1_COD    "
			cQuery+="      AND C6_QTDVEN > 0          "
			
			Begin Transaction
			
			U_ORTQUERY(cQuery, "ORTRXXK")
			
			While !(ORTRXXK->(EOF()))
				
				U_JobCInfo("ORTP002.PRW", "SIMBAHIA - PEDIDO: " + ORTRXXK->C5_NUM + " - C5_XVERREP ANTERIOR: " + ALLTRIM(STR(ORTRXXK->C5_XVERREP))  , 2)
				
				cQuery1:="UPDATE siga."+RetSQLName("SC6")+" A SET "
				cQuery1+="       C6_VALOR = ROUND(C6_PRUNIT * " + AllTrim(Str(_nDifBahia)) + ",4)*C6_QTDVEN, "
				cQuery1+="       C6_PRCVEN = ROUND(C6_PRUNIT * " + AllTrim(Str(_nDifBahia)) + ",4), "
				cQuery1+="       C6_VALDESC = ( C6_QTDVEN * C6_PRUNIT )-( C6_QTDVEN * C6_PRUNIT * " + AllTrim(Str(_nDifBahia)) + "), "
				cQuery1+="       C6_DESCONT = " + AllTrim(Str(_nPerBahia)) + "  "
				cQuery1+=" WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
				cQuery1+="   AND D_E_L_E_T_ = ' '       		  "
				cQuery1+="   AND C6_NUM IN ('"+ORTRXXK->C5_NUM+"') "
				
				//cQuery2:="UPDATE siga."+RetSQLName("SC5")+" B SET "
				//cQuery2+="       C5_FILIAL = C5_FILIAL, C5_XVERREP = " + AllTrim(Str(_nPerBahia)) + " "
				//cQuery2+=" WHERE C5_FILIAL = '"+xFilial("SC6")+"' "
				//cQuery2+="   AND D_E_L_E_T_ = ' '      			  "
				//cQuery2+="   AND C5_NUM IN ('"+ORTRXXK->C5_NUM+"') "
				
				if TCSQLEXEC(cQuery1) <> 0
					U_JobCInfo("ORTP002.PRW", "SIMBAHIA - ERRO AO ATUALIZAR SC6 DO PEDIDO: " + ORTRXXK->C5_NUM + "" , 2)
				endif
				
				//if dDataBase >= stod('20180701')
				//	if TCSQLEXEC(cQuery2) <> 0
				//		U_JobCInfo("ORTP002.PRW", "SIMBAHIA - ERRO AO ATUALIZAR SC5 DO PEDIDO: " + ORTRXXK->C5_NUM + "" , 2)
				//	endif
				//endif
				
				ORTRXXK->(dbSkip())
			EndDo
			ORTRXXK->(dbCloseArea())
			
			End Transaction
			
		endif
	endif
	
	/*
	__aAreaR	:=	GetArea()
	
	//Atualiza Reserva dos pedidos NPID
	If lRet
	
	cQuery	:=	"SELECT C6_PRODUTO,C6_LOCAL, SUM(C6_QTDVEN) QUANT, (SELECT R_E_C_N_O_ FROM "+RetSqlName("SB2")+" WHERE B2_FILIAL = '"+xFilial("SB2")+"' "
	cQuery	+=	"                                           AND D_E_L_E_T_ = ' ' AND B2_COD = C6_PRODUTO AND B2_LOCAL = C6_LOCAL ) B2ORI, "
	cQuery	+=	"                                         (SELECT R_E_C_N_O_ FROM "+RetSqlName("SB2")+" WHERE B2_FILIAL = '"+xFilial("SB2")+"' "
	cQuery	+=	"                                           AND D_E_L_E_T_ = ' ' AND B2_COD = C6_PRODUTO AND B2_LOCAL = '"+__cLocNPID+"' ) B2DES "
	cQuery	+=	" FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SC5")+" C5  WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6.D_E_L_E_T_ = ' '  AND C5_FILIAL = '"+xFilial("SC5")+"' AND C5.D_E_L_E_T_ = ' ' AND C6_NUM IN ("+cPedC+" ) "
	cQuery	+=	" AND C5_NUM = C6_NUM AND C5_XOPER <> '22' "
	cQuery	+=	" GROUP BY C6_PRODUTO,C6_LOCAL			 "
	cQuery	+=	" ORDER BY C6_PRODUTO "
	
	TCQUERY cQuery ALIAS "RES" NEW
	Dbselectarea("RES")
	
	While !EOF()
	DbSelectArea("SB2")
	DbGoTo(RES->B2ORI)
	If !EOF()
	RecLock("SB2",.F.)
	B2_RESERVA	-=	RES->QUANT
	MsUnlock()
	Endif
	DbGoTo(RES->B2DES)
	If !EOF()
	RecLock("SB2",.F.)
	B2_RESERVA	+=	RES->QUANT
	MsUnlock()
	Endif
	DbSelectArea("RES")
	DbSkip()
	EndDo
	
	DbSelectArea("RES")
	DbCloseArea()
	
	Endif
	
	RestArea(__aAreaR)
	*/
	
	//Atualiza data de previs„o de entrega com a data da programaÁ„o
	If lRet
		
		cQuery:="UPDATE "+RetSqlName("SC6")
		cQuery+=" SET C6_ENTREG  = '"+Dtos(MV_PAR05)+"' "
		cQuery+=" WHERE  C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM IN ("+cPedC+" ) AND  D_E_L_E_T_ = ' '  "
		
		MEMOWRIT("C:\4A.SQL",cQuery)
		If TCSQLExec(cQuery) < 0
			MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 4A","ERRO 4A")
			lRet:=.F.
		endif
		
		
	Endif
	
	
	If lRet
		
		cQuery:="UPDATE "+RetSqlName("SC6")
		cQuery+=" SET C6_LOCAL = '"+__cLocNPID+"', C6_XTSANT = C6_TES, C6_TES = '999' "
		cQuery+=" WHERE C6_NUM IN ("+cPedC+" )"
		cQuery+="   AND D_E_L_E_T_ = ' '  "
		cQuery+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
		cQuery+="   AND R_E_C_N_O_ IN(SELECT C6.R_E_C_N_O_ FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SF4")+" F4, "+RetSqlName("SB1")+" B1, "+RetSqlName("SC5")+" C5 WHERE C6_NUM IN ("+cPedC+" )"
		cQuery+="   				  AND C6.D_E_L_E_T_ = ' ' AND F4.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' "
		cQuery+="                     AND C6_FILIAL = '"+xFilial("SC6")+"' AND C5_FILIAL = '"+xFilial("SC5")+"' AND F4_FILIAL = '"+xFilial("SF4")+"' AND B1_FILIAL = '"+xFilial("SB1")+"' "
		if cEmpAnt=="15"
			cQuery+="                  AND C5_XOPER <> '07'  "
		endif
		cQuery+="                     AND C6_TES = F4_CODIGO AND F4_ESTOQUE = 'S' AND C6_PRODUTO = B1_COD AND C6_NUM = C5_NUM)"
		
		
		MEMOWRITE("c:\9.SQL",cQuery)
		
		If TCSQLExec(cQuery) < 0
			MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 9","ERRO 9")
			lRet:=.F.
		Endif
		if cEmpAnt=="15"
			cQuery:="UPDATE "+RetSqlName("SC6")
			cQuery+=" SET C6_LOCAL = '"+__cLocNPID+"', C6_XTSANT = C6_TES, C6_TES = '998' "
			cQuery+=" WHERE C6_NUM IN ("+cPedC+" )"
			cQuery+="   AND D_E_L_E_T_ = ' '  "
			cQuery+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
			cQuery+="   AND R_E_C_N_O_ IN(SELECT C6.R_E_C_N_O_ FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SF4")+" F4, "+RetSqlName("SB1")+" B1, "+RetSqlName("SC5")+" C5 WHERE C6_NUM IN ("+cPedC+" )"
			cQuery+="   				     AND C6.D_E_L_E_T_ = ' ' AND F4.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' "
			cQuery+="                     AND C5_XOPER = '07'  "
			cQuery+="                     AND C6_FILIAL = '"+xFilial("SC6")+"' AND C5_FILIAL = '"+xFilial("SC5")+"' AND F4_FILIAL = '"+xFilial("SF4")+"' AND B1_FILIAL = '"+xFilial("SB1")+"' "
			cQuery+="                     AND C6_TES = F4_CODIGO AND F4_ESTOQUE = 'S' AND C6_PRODUTO = B1_COD AND C6_NUM = C5_NUM)"
			
			MEMOWRITE("c:\10.SQL",cQuery)
			
			If TCSQLExec(cQuery) < 0
				MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 10","ERRO 10")
				lRet:=.F.
			Endif
		endif
		/*
		cQuery:="UPDATE "+RetSqlName("SC6")
		cQuery+=" SET C6_TES = '999' "
		cQuery+=" WHERE C6_NUM IN ("+cPedC+" )"
		cQuery+="   AND D_E_L_E_T_ = ' '  "
		cQuery+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
		cQuery+="   AND R_E_C_N_O_ IN(SELECT C6.R_E_C_N_O_ FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SF4")+" F4, "+RetSqlName("SB1")+" B1, "+RetSqlName("SC5")+" C5 WHERE C6_NUM IN ("+cPedC+" )"
		cQuery+="   				  AND C6.D_E_L_E_T_ = ' ' AND F4.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' "
		cQuery+="                     AND C6_FILIAL = '"+xFilial("SC6")+"' AND C5_FILIAL = '"+xFilial("SC5")+"' AND F4_FILIAL = '"+xFilial("SF4")+"' AND B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery+="                     AND C6_TES = F4_CODIGO AND F4_ESTOQUE = 'S' AND C6_PRODUTO = B1_COD AND B1_TIPO = 'MP' AND C6_NUM = C5_NUM AND C5_XOPER = '22')"
		
		MEMOWRITE("c:\10.SQL",cQuery)
		
		If TCSQLExec(cQuery) < 0
		MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 10","ERRO 10")
		lRet:=.F.
		Endif
		*/
		
		
		
		cQuery:="UPDATE "+RetSqlName("SC6")
		cQuery+=" SET C6_LOCAL = '"+__cLocNPID+"', C6_XTSANT = C6_TES, C6_TES = '997' "
		cQuery+=" WHERE C6_NUM IN ("+cPedC+" )"
		cQuery+="   AND D_E_L_E_T_ = ' '  "
		cQuery+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
		cQuery+="   AND R_E_C_N_O_ IN(SELECT C6.R_E_C_N_O_ FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SF4")+" F4, "+RetSqlName("SB1")+" B1, "+RetSqlName("SC5")+" C5 WHERE C6_NUM IN ("+cPedC+" )"
		cQuery+="   				  AND C6.D_E_L_E_T_ = ' ' AND F4.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' "
		cQuery+="                     AND C6_FILIAL = '"+xFilial("SC6")+"' AND C5_FILIAL = '"+xFilial("SC5")+"' AND F4_FILIAL = '"+xFilial("SF4")+"' AND B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery+="                     AND C6_TES = F4_CODIGO AND F4_ESTOQUE = 'N' AND C6_PRODUTO = B1_COD AND C6_NUM = C5_NUM )"
		
		Begin Transaction
		If TCSQLExec(cQuery) < 0
			MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 11","ERRO 11")
			lRet:=.F.
		Endif
		
		
		
		if cEmpAnt=="16" .or. cEmpAnt=="22"
			cQuery:="UPDATE "+RetSqlName("SC2")
			cQuery+=" SET C2_LOCAL  = '"+__cLocNPID+"' "
			cQuery+=" WHERE C2_PEDIDO IN  ("+cPedC+" )"
			cQuery+="   AND D_E_L_E_T_ = ' ' "
			cQuery+="   AND C2_FILIAL  = '"+xFilial("SC2")+"' "
			
			MEMOWRIT("C:\111.SQL",cQuery)
			
			if TCSQLExec(cQuery) < 0
				MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 111","ERRO 111")
				lRet:=.F.
			endif
			
		endif
		End Transaction
		cQuery:="SELECT DISTINCT C6_PRODUTO, C6_LOCAL "
		cQuery+="  FROM "+RetSQLName("SB2")+" SB2, "+RetSQLName("SC6")+" SC6 "
		cQuery+=" WHERE SC6.D_E_L_E_T_ = ' '        "
		cQuery+="   AND SB2.D_E_L_E_T_(+) = ' '     "
		cQuery+="   AND C6_FILIAL    = '"+xFilial("SC6")+"' "
		cQuery+="   AND B2_FILIAL(+) = '"+xFilial("SC2")+"' "
		cQuery+="   AND C6_PRODUTO   = B2_COD(+)    "
		cQuery+="   AND C6_LOCAL     = B2_LOCAL(+)  "
		cQuery+="   AND B2_COD IS NULL              "
		cQuery+="   AND C6_NUM IN ("+cPedC+")       "
		tcquery cQuery ALIAS "CRIASB2" New
		
		dbselectarea("CRIASB2")
		dbgotop()
		do while !eof()
			CriaSB2(CRIASB2->C6_PRODUTO,CRIASB2->C6_LOCAL)
			dbselectarea("CRIASB2")
			dbskip()
		enddo
		dbclosearea()
		
		
		/*
		cQuery:="UPDATE "+RetSqlName("SC6")
		cQuery+=" SET  C6_TES = '997' "
		cQuery+=" WHERE C6_NUM IN ("+cPedC+" )"
		cQuery+="   AND D_E_L_E_T_ = ' '  "
		cQuery+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
		cQuery+="   AND R_E_C_N_O_ IN(SELECT C6.R_E_C_N_O_ FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SF4")+" F4, "+RetSqlName("SB1")+" B1, "+RetSqlName("SC5")+" C5  WHERE C6_NUM IN ("+cPedC+" )"
		cQuery+="   				  AND C6.D_E_L_E_T_ = ' ' AND F4.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' "
		cQuery+="                     AND C6_FILIAL = '"+xFilial("SC6")+"' AND C5_FILIAL = '"+xFilial("SC5")+"' AND F4_FILIAL = '"+xFilial("SF4")+"' AND B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery+="                     AND C6_TES = F4_CODIGO AND F4_ESTOQUE = 'N' AND C6_PRODUTO = B1_COD AND B1_TIPO = 'MP' AND C5_NUM = C6_NUM AND C5_XOPER = '22')"
		
		
		If TCSQLExec(cQuery) < 0
		MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 12","ERRO 12")
		lRet:=.F.
		Endif
		*/
		
		
		/*
		
		cQuery:="UPDATE "+RetSqlName("SC9")
		cQuery+=" SET C9_LOCAL = '"+__cLocNPID+"' "
		cQuery+=" WHERE C9_PEDIDO IN ("+cPedC+" )"
		cQuery+="   AND D_E_L_E_T_ = ' '  "
		cQuery+="   AND C9_FILIAL = '"+xFilial("SC9")+"' "
		cQuery+="   AND R_E_C_N_O_ IN(SELECT c9.R_E_C_N_O_ FROM "+RetSqlName("SC9")+" C9, "+RetSqlName("SB1")+" B1, "+RetSqlName("SC5")+" C5 WHERE C9_PEDIDO IN ("+cPedC+" )"
		cQuery+="   				  AND C9.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND C5.D_E_L_E_T_ = ' ' "
		cQuery+="                     AND C9_FILIAL 	= 	'"+xFilial("SC9")+"' 	AND C5_FILIAL = '"+xFilial("SC5")+"' AND B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery+="                     AND C9_PRODUTO 	= 	B1_COD AND B1_TIPO 		<> 	'MP' AND C9_PEDIDO	=	C5_NUM AND C5_XOPER <> '22')"
		
		If TCSQLExec(cQuery) < 0
		MsgBox("Problemas na atualizaÁ„o do embarque! Informe Erro 13","ERRO 13")
		lRet:=.F.
		Endif
		*/
		
	Endif
	
	If lRet .and. Len(alltrim(cPedR))>0
		//		cQuery:="UPDATE "+RetSqlName("SC5")
		//		cQuery+=" SET C5_XEMBARQ = '"+cEmb+"' "
		//		cQuery+=" WHERE C5_NUM IN ("+cPedR+" )"
		//		if TCSQLExec(cQuery) > 0
		//			MsgBox("Problemas na atualizaÁ„o do embarque!  Informe Erro 3","ERRO 3")
		//			lRet:=.F.
		//		endif
		
		__nCountR	:=	0
		__aArea		:=	GetArea()
		For w = 1 to len(aRemessa)
			If !Empty(alltrim(aRemessa[w,1])) .and. len(aremessa[w])>6
				/*
				cQuery:="UPDATE "+RetSqlName("SC5")
				cQuery+=" SET C5_XEMBARQ = '"+cEmb+"', "
				cQuery+="     C5_XORDEMB   = '"+strzero(w,2)+"' "
				cQuery+=" WHERE C5_NUM = '"+aRemessa[w,1]+"'"
				cQuery+=" AND (C5_XEMBARQ = ' ' OR C5_XEMBARQ = '"+cEmb+"')"
				If TCSQLExec(cQuery) < 0
				MsgBox("Problemas na atualizaÁ„o do embarque!  Informe Erro 3","ERRO 3")
				lRet:=.F.
				endif
				*/
				DbSelectArea("SC5")
				dbOrderNickName("PSC51")
				If	MsSeek(xFilial("SC5")+aRemessa[w,1],.T.)
					If	C5_XEMBARQ = " " .Or.  SubStr(C5_XEMBARQ,2,5) = SubStr(cEmb,2,5)
						RecLock("SC5", .F.)
						IF EMPTY(aRemessa[w,8])
							C5_XEMBARQ	:=	STRZERO(VAL(cEmb),6)
						ELSE
							C5_XEMBARQ	:=	STRZERO(VAL(cEmb)+nEmbTp,6)
						ENDIF
						C5_XORDEMB	:=	strzero(w,4)
						C5_XTPVAL   := aRemessa[w,8]
						MsUnlock()
						
						*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
						_cPedClx := AllTrim(SC5->C5_XPEDCLX)
						If !Empty(_cPedClx)
							// Localiza a Unidde de Origem
							cUnOri  := SC5->C5_XUNORI
							If !Empty(cUnOri)
								_lRetx  := U_ORTXRPC(cUnOri, "U_ORTP002O",{SC5->C5_XEMBARQ,_cPedClx})  // M·rcio - Remover o .T.
								//								U_ORTP002O(SC5->C5_XEMBARQ, _cPedCli)
							Endif
						Endif
						*'--------------------------------------------------------------------------------------------------'*
						
						cQuery:="UPDATE "+RetSQLName("SC6")+" SET C6_LOCAL = '"+__cLocPID+"', C6_BLQ = ' ' "
						cQuery+="WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+aRemessa[w,1]+"' "
						/* RETIRADO POR ORDENS DE RUBENS DIAS EM 01/10/2021
						Begin Transaction
						TCSqlExec(cQuery)
						//IF SC5->C5_XTPSEGM$("34")
						   cQuery:="UPDATE "+RetSQLName("SC6")+" SET C6_XCUSANT = C6_XCUSTO, "
						   cQuery+="       C6_XCUSTO = FCustoTab"+cEmpAnt+"0(C6_PRODUTO,'"+DToS(MV_PAR05)+"') "
						   cQuery+="WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+aRemessa[w,1]+"' "
						   TCSqlExec(cQuery)
						//Endif
						End Transaction
						*/
						__nCountR++
					Else
						AADD(__aExc,C5_NUM)
					Endif
				Else
					MsgBox("Problemas na atualizaÁ„o do embarque!  Informe Erro 14","ERRO 14")
					lRet:=.F.
				Endif
			Endif
		next
		
	Endif
	//Alert(__nCountR)
	//Alert(Len(aRemessa))
	
	if lRet .and. Len(alltrim(cPedC))>0
		//		cQuery:="UPDATE "+RetSqlName("SC5")
		//		cQuery+=" SET C5_XEMBARQ = '"+strzero(val(cEmb)+500000,6)+"' "
		//		cQuery+=" WHERE C5_NUM IN ("+cPedC+" )"
		//		if TCSQLExec(cQuery) > 0
		//			MsgBox("Problemas na atualizaÁ„o do embarque!  Informe Erro 4","ERRO 4")
		//			lRet:=.F.
		//		endif
		
		__nCountC	:=	0
		
		for w= 1 to len(aConfere)
			If !Empty(alltrim(aConfere[w,1])) .and. len(aConfere[w])>6
				/*
				cQuery:="UPDATE "+RetSqlName("SC5")
				cQuery+=" SET C5_XEMBARQ = '"+strzero(val(cEmb)+500000,6)+"', "
				cQuery+="     C5_XORDEMB   = '"+strzero(w,2)+"' "
				cQuery+=" WHERE C5_NUM     = '"+aConfere[w,1]+"' "
				if TCSQLExec(cQuery) < 0
				MsgBox("Problemas na atualizaÁ„o do embarque!  Informe Erro 3","ERRO 3")
				lRet:=.F.
				endif
				*/
				DbSelectArea("SC5")
				dbOrderNickName("PSC51")
				If	MsSeek(xFilial("SC5")+aConfere[w,1],.T.)
					If	C5_XEMBARQ = " " .Or.  SubStr(C5_XEMBARQ,2,5) = SubStr(Strzero(val(cEmb)+500000,6),2,5)
						RecLock("SC5", .F.)
						C5_XEMBARQ	:=	Strzero(val(cEmb)+500000,6)
						C5_XORDEMB	:=	strzero(w,4)
						MsUnlock()
						
						*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
						_cPedClx := AllTrim(SC5->C5_XPEDCLX)
						If !Empty(_cPedClx)
							// Localiza a Unidde de Origem
							cUnOri  := SC5->C5_XUNORI
							If !Empty(cUnOri)
								_lRetx  := U_ORTXRPC(cUnOri, "U_ORTP002O",{SC5->C5_XEMBARQ,_cPedClx})  // M·rcio - Remover o .T.
								//								U_ORTP002O(SC5->C5_XEMBARQ, _cPedCli)
							Endif
						Endif
						*'--------------------------------------------------------------------------------------------------'*
						__nCountC++
						
						cQuery:="UPDATE "+RetSQLName("SC6")+" SET C6_LOCAL = '"+__cLocNPID+"' WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+aConfere[w,1]+"' "
						Begin Transaction
						TCSqlExec(cQuery)
						End Transaction
					Else
						AADD(__aExc,C5_NUM)
					Endif
				Else
					MsgBox("Problemas na atualizaÁ„o do embarque!  Informe Erro 15","ERRO 15")
					lRet:=.F.
				Endif
				
			Endif
		next
	endif
	RestArea(__aArea)
	//Alert(__nCountC)
	//Alert(Len(aConfere))
	
	If lIncEmb
		//		FClose(nHandle)
		//		FErase("CARGA"+SM0->M0_CODIGO+".SEM")
	Endif
	
	
	If (__nCountR	<	len(aRemessa) .And. !empty(aRemessa[1,1]))	.Or.	(__nCountC	<	len(aConfere) .And.	!empty(aConfere[1,1]))
		Alert(Str(Len(__aExc))+" pedidos foram programados por outro usu·rio em outra carga, antes da finalizaÁ„o desta montagem!!")
		//	Alert(Len(__aExc))
		For u	:=	1	to Len(__aExc)
			cRemove	:=	__aExc[u]
			//Alert(__aExc[u])
			LocalizSel(2)
			cRemove	:=	" "
		Next
	Endif
	
	__aExc	:=	{}
	
	
	
	If	!lIncEmb
		if lRet
			cQuery:="DELETE "+RetSqlName("SZQ")
			cQuery+=" WHERE ZQ_EMBARQ IN ('"+cEmb+"','"+strzero(val(cEmb)+nEmbTp,6)+"','"+strzero(val(cEmb)+500000,6)+"') AND ZQ_FILIAL = '"+xFilial("SZQ")+"' "
			if TCSQLExec(cQuery) < 0
				MsgBox("Problemas na atualizaÁ„o do embarque!  Informe Erro 16","ERRO 16")
				lRet:=.F.
			endif
		endif
	Endif
	
	lAchouPid  := (nValRem > 0)
	lAchouNPid := (nValConf > 0)
	
	//Alert("|"+cEmb+"|")
	
	If lRet
		If nValRem-nValTp > 0
			DbSelectArea("SZQ")
			dbOrderNickName("CSZQ1")
			if dbSeek(xFilial("SZQ")+AllTrim(cEmb),.T.)
				Reclock("SZQ",.F.)
			Else
				Reclock("SZQ",.T.)
			Endif
			SZQ->ZQ_FILIAL  := 	xFilial("SZQ")
			SZQ->ZQ_EMBARQ  := 	cEmb
			SZQ->ZQ_PRACA   := 	cCodArea
			SZQ->ZQ_RESIDUO := 	LEFT(cResiduo,1)
			SZQ->ZQ_TRANSP  := 	cCodTrans
			SZQ->ZQ_DTPREVE := 	MV_PAR05
			SZQ->ZQ_VALOR   := 	nValRem-nValTp + nTotIPI - IIf(cEmpAnt=="21",fDescZF(cEmb),0)
			SZQ->ZQ_ESPACO  := 	nEspRem
			SZQ->ZQ_ESPACAM := nEspCam
			SZQ->ZQ_VALORSA := 	nValSAC
			SZQ->ZQ_KILOMET := 	nKilomet
			nKilomet:=0
			SZQ->ZQ_ADIANT  := 	nValAdiat
			SZQ->ZQ_EMBCOMP	:=	cEmbComp
			SZQ->ZQ_PERFRET := nPercTot2
			SZQ->ZQ_VALORKM := nValKm
			if nKilomet > 0 .and. nValKm > 0
				SZQ->ZQ_VALFRET:=  nKilomet*nValKm
			else
				SZQ->ZQ_VALFRET:=  nValFret2
			endif
			nValFret2:=0
			SZQ->ZQ_FRTMIN :=  nValFret
			If alltrim(cCombo) = "SAC"
				SZQ->ZQ_XTPCAR  := "7"
			Elseif alltrim(cCombo) = "Normal"
				SZQ->ZQ_XTPCAR  := "1"
			Elseif alltrim(cCombo) = "Residuo"
				SZQ->ZQ_XTPCAR  := "2"
			Elseif alltrim(cCombo) = "Complementar"
				SZQ->ZQ_XTPCAR  := "3"
			Elseif alltrim(cCombo) = "Acrilica"
				SZQ->ZQ_XTPCAR  := "5"
			Elseif alltrim(cCombo) = "Bono"
				SZQ->ZQ_XTPCAR  := "6"
			Elseif alltrim(cCombo) = "Extra"
				SZQ->ZQ_XTPCAR  := "4"
				SZQ->ZQ_OBS     := cMotCrgEx
			Endif
			nPosArr:=ascan(aItens2,{|x| alltrim(x[2])== Alltrim(cCombo1)})
			SZQ->ZQ_TPCARGA	:= aItens2[nPosArr][1]
			/*
			If	AllTrim(cCombo1)		==	"COLCHAO"
			SZQ->ZQ_TPCARGA	:= "C"
			ElseIf	AllTrim(cCombo1)	==	"DUBLADO"
			SZQ->ZQ_TPCARGA	:=	"D"
			ElseIf	AllTrim(cCombo1)	==	"ESPUMA"
			SZQ->ZQ_TPCARGA	:=	"E"
			ElseIf	Alltrim(cCombo1)	==	"LAMINADO"
			SZQ->ZQ_TPCARGA	:=	"L"
			ElseIf	AllTrim(cCombo1)	==	"MISTO"
			SZQ->ZQ_TPCARGA	:=	"M"
			ElseIf	AllTrim(cCombo1)	==	"RETIRA"
			SZQ->ZQ_TPCARGA	:=	"R"
			ElseIf	AllTrim(cCombo1)	==	"TORNEADO"
			SZQ->ZQ_TPCARGA	:=	"T"
			ElseIf	AllTrim(cCombo1)	==	"ALMOFADA"
			SZQ->ZQ_TPCARGA	:=	"A"
			ElseIf	cCombo1				==	"FIBRA"
			SZQ->ZQ_TPCARGA	:=	"F"
			ElseIf	AllTrim(cCombo1)	==	"MANTA"
			SZQ->ZQ_TPCARGA	:=	"N"
			ElseIf	AllTrim(cCombo1)	==	"MOLA"
			SZQ->ZQ_TPCARGA	:=	"O"
			ElseIf	AllTrim(cCombo1)	==	"REFATURAMENTO"
			SZQ->ZQ_TPCARGA	:=	"P"
			ElseIf	AllTrim(cCombo1)	==	"TRAVESSEIRO"
			SZQ->ZQ_TPCARGA	:=	"V"
			Endif
			*/
			SZQ->ZQ_OBSFRT:=_cObs
			If cEmpAnt == '24'
				_cHoraT	:=	Dtoc(Date())+"-"+Time()
				SZQ->ZQ_OPGERAD	:= "S"
				//SZQ->ZQ_DTFECHA	:= "S"
				SZQ->ZQ_HORAT := _cHoraT
			EndIF
			
			msunlock()
		endif
		
		If nValTp > 0
			DbSelectArea("SZQ")
			dbOrderNickName("CSZQ1")
			if dbSeek(xFilial("SZQ")+AllTrim(STRZERO(VAL(cEmb)+nEmbTp,6)),.T.)
				Reclock("SZQ",.F.)
			Else
				Reclock("SZQ",.T.)
			Endif
			SZQ->ZQ_FILIAL  := 	xFilial("SZQ")
			SZQ->ZQ_EMBARQ  := 	AllTrim(STRZERO(VAL(cEmb)+nEmbTp,6))
			SZQ->ZQ_PRACA   := 	cCodArea
			SZQ->ZQ_RESIDUO := 	LEFT(cResiduo,1)
			SZQ->ZQ_TRANSP  := 	cCodTrans
			SZQ->ZQ_DTPREVE := 	MV_PAR05
			SZQ->ZQ_VALOR   := 	nValTp + nTotIPI - IIf(cEmpAnt=="21",fDescZF(cEmb),0)
			SZQ->ZQ_ESPACO  := 	nEspRem
			SZQ->ZQ_ESPACAM := nEspCam
			SZQ->ZQ_VALORSA := 	nValSAC
			SZQ->ZQ_KILOMET := 	nKilomet
			SZQ->ZQ_ADIANT  := 	nValAdiat
			SZQ->ZQ_EMBCOMP	:=	cEmbComp
			SZQ->ZQ_PERFRET := nPercTot2
			SZQ->ZQ_VALORKM := nValKm
			if nKilomet > 0 .and. nValKm > 0
				SZQ->ZQ_VALFRET:=  nKilomet*nValKm
			else
				SZQ->ZQ_VALFRET:=  nValFret2
			endif
			SZQ->ZQ_FRTMIN :=  nValFret
			If alltrim(cCombo) = "SAC"
				SZQ->ZQ_XTPCAR  := "7"
			Elseif alltrim(cCombo) = "Normal"
				SZQ->ZQ_XTPCAR  := "1"
			Elseif alltrim(cCombo) = "Residuo"
				SZQ->ZQ_XTPCAR  := "2"
			Elseif alltrim(cCombo) = "Complementar"
				SZQ->ZQ_XTPCAR  := "3"
			Elseif alltrim(cCombo) = "Acrilica"
				SZQ->ZQ_XTPCAR  := "5"
			Elseif alltrim(cCombo) = "Bono"
				SZQ->ZQ_XTPCAR  := "6"
			Elseif alltrim(cCombo) = "Extra"
				SZQ->ZQ_XTPCAR  := "4"
				SZQ->ZQ_OBS     := cMotCrgEx
			Endif
			nPosArr:=ascan(aItens2,{|x| alltrim(x[2])== Alltrim(cCombo1)})
			SZQ->ZQ_TPCARGA	:= aItens2[nPosArr][1]
			/*
			
			If	AllTrim(cCombo1)		==	"COLCHAO"
			SZQ->ZQ_TPCARGA	:= "C"
			ElseIf	AllTrim(cCombo1)	==	"DUBLADO"
			SZQ->ZQ_TPCARGA	:=	"D"
			ElseIf	AllTrim(cCombo1)	==	"ESPUMA"
			SZQ->ZQ_TPCARGA	:=	"E"
			ElseIf	Alltrim(cCombo1)	==	"LAMINADO"
			SZQ->ZQ_TPCARGA	:=	"L"
			ElseIf	AllTrim(cCombo1)	==	"MISTO"
			SZQ->ZQ_TPCARGA	:=	"M"
			ElseIf	AllTrim(cCombo1)	==	"RETIRA"
			SZQ->ZQ_TPCARGA	:=	"R"
			ElseIf	AllTrim(cCombo1)	==	"TORNEADO"
			SZQ->ZQ_TPCARGA	:=	"T"
			ElseIf	AllTrim(cCombo1)	==	"ALMOFADA"
			SZQ->ZQ_TPCARGA	:=	"A"
			ElseIf	cCombo1				==	"FIBRA"
			SZQ->ZQ_TPCARGA	:=	"F"
			ElseIf	AllTrim(cCombo1)	==	"MANTA"
			SZQ->ZQ_TPCARGA	:=	"N"
			ElseIf	AllTrim(cCombo1)	==	"MOLA"
			SZQ->ZQ_TPCARGA	:=	"O"
			ElseIf	AllTrim(cCombo1)	==	"REFATURAMENTO"
			SZQ->ZQ_TPCARGA	:=	"P"
			ElseIf	AllTrim(cCombo1)	==	"TRAVESSEIRO"
			SZQ->ZQ_TPCARGA	:=	"V"
			Endif
			*/
			SZQ->ZQ_OBSFRT:=_cObs
			If cEmpAnt == '24'
				_cHoraT	:=	Dtoc(Date())+"-"+Time()
				SZQ->ZQ_OPGERAD	:= "S"
				//SZQ->ZQ_DTFECHA	:= "S"
				SZQ->ZQ_HORAT := _cHoraT
			EndIF
			
			msunlock()
		endif
		
		if nValConf > 0
			DbselectArea("SZQ")
			dbOrderNickName("CSZQ1")
			
			if dbSeek(xFilial("SZQ")+strzero(val(cEmb)+500000,6),.T.)
				Reclock("SZQ",.F.)
			Else
				Reclock("SZQ",.T.)
			Endif
			
			SZQ->ZQ_FILIAL  := xFilial("SZQ")
			SZQ->ZQ_EMBARQ  := StrZero(Val(cEmb)+500000,6)
			SZQ->ZQ_PRACA   := cCodArea
			SZQ->ZQ_RESIDUO := LEFT(cResiduo,1)
			SZQ->ZQ_TRANSP  := cCodTrans
			SZQ->ZQ_DTPREVE := MV_PAR05
			SZQ->ZQ_VALOR   := nValConf - IIf(cEmpAnt=="21",fDescZF(cEmb),0)
			SZQ->ZQ_ESPACO  := nEspConf
			SZQ->ZQ_ESPACAM := nEspCam
			SZQ->ZQ_KILOMET := nCKilomet//nKilomet
			SZQ->ZQ_VALORKM := nCValKm
			if nCKilomet > 0 .and. nCValKm > 0
				SZQ->ZQ_VALFRET:=  nKilomet*nValKm
			else
				SZQ->ZQ_VALFRET:=  nCValFret2
			endif
			SZQ->ZQ_PERFRET:=nPercTotN
			SZQ->ZQ_ADIANT  := iif(lAchouPid, (nValAdiat / 2), nValAdiat)
			SZQ->ZQ_EMBCOMP	:=	cEmbComp
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Grava o tipo da carga≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			//	If MV_PAR05 >= dDataBase + 2      // Cleverson em 01/03/2007
			If alltrim(cCombo) = "SAC"
				SZQ->ZQ_XTPCAR  := "7"
			Elseif alltrim(cCombo) = "Normal"
				SZQ->ZQ_XTPCAR  := "1"
			Elseif alltrim(cCombo) = "Residuo"
				SZQ->ZQ_XTPCAR  := "2"
			Elseif alltrim(cCombo) = "Complementar"
				SZQ->ZQ_XTPCAR  := "3"
			Elseif alltrim(cCombo) = "Acrilica"
				SZQ->ZQ_XTPCAR  := "5"
			Elseif alltrim(cCombo) = "Bono"
				SZQ->ZQ_XTPCAR  := "6"
			Elseif alltrim(cCombo) = "Extra"
				SZQ->ZQ_XTPCAR  := "4"
				SZQ->ZQ_OBS     := cMotCrgEx
			Endif
			nPosArr:=ascan(aItens2,{|x| alltrim(x[2])== Alltrim(cCombo1)})
			SZQ->ZQ_TPCARGA	:= aItens2[nPosArr][1]
			/*
			
			If	AllTrim(cCombo1)		==	"COLCHAO"
			SZQ->ZQ_TPCARGA	:= "C"
			ElseIf	AllTrim(cCombo1)	==	"DUBLADO"
			SZQ->ZQ_TPCARGA	:=	"D"
			ElseIf	AllTrim(cCombo1)	==	"ESPUMA"
			SZQ->ZQ_TPCARGA	:=	"E"
			ElseIf	Alltrim(cCombo1)	==	"LAMINADO"
			SZQ->ZQ_TPCARGA	:=	"L"
			ElseIf	AllTrim(cCombo1)	==	"MISTO"
			SZQ->ZQ_TPCARGA	:=	"M"
			ElseIf	AllTrim(cCombo1)	==	"RETIRA"
			SZQ->ZQ_TPCARGA	:=	"R"
			ElseIf	AllTrim(cCombo1)	==	"TORNEADO"
			SZQ->ZQ_TPCARGA	:=	"T"
			Endif
			*/
			SZQ->ZQ_PERFRET := nPercTotN
			//			SZQ->ZQ_VALFRET:=  nCValFret2
			SZQ->ZQ_FRTMIN :=  nCValFret
			If cEmpAnt == '24'
				_cHoraT	:=	Dtoc(Date())+"-"+Time()
				SZQ->ZQ_OPGERAD	:= "S"
				//SZQ->ZQ_DTFECHA	:= "S"
				SZQ->ZQ_HORAT := _cHoraT
			EndIF
			
			msunlock()
		endif
	endif
	
	
	
	aOrigem  :={{"","","","",0,"",""}}
	//	aRemessa :={{"","","","",0}}
	aRemessa :={{"","","","",0,"","",""}}
	
	//	aConfere :={{"","","","",0}}
	aConfere :={{"","","","",0,"",""}}
	
    U_SPEXEC("VALCARGA"+cEMPANT+"0",{cEmb})
//	TCSPEXEC("VALCARGA"+cEMPANT+"0",strzero(val(cEmb)+500000,6))
//	TCSPEXEC("VALCARGA"+cEMPANT+"0",STRZERO(VAL(cEmb)+nEmbTp,6))
	
else
	If	lIncEmb
		MsgBox("Embarque n„o pode ser gerado sem valor!","ATEN«√O")
		lRet:=.F.
	ElseIf	lAltEmb
		MsgBox("Para excluir todos os pedidos da carga, utilize a opÁ„o de exclus„o!","ATEN«√O")
		lRet:=.F.
	Endif
endif




//End Transaction
//If	lIncEmb
//	U_IncEmb()
//Endif

Return(lRet)



Static Function fInfFrt()
*************************

Local 	aArea 		:= 	GetArea()
Local	_lContinua	:=	.T.
Private lRetFrt 	:= 	.T.
Private oDlgFrt
Private _oPraca

If lIncEmb
	fCalcFrete(4,.T.)
Endif
If lAltEmb
	fCalcFrete(5,.T.)
Endif


Define Font oFntGrN Name "Arial" Size 0,-11
Define Font oFntGrB Name "Arial" Size 0,-12 Bold

While _lContinua
	
	DEFINE MSDIALOG oDlgFrt TITLE "InformaÁıes Complementares da Carga/Embarque" FROM  254,278 TO 770,816 PIXEL
	
	If lIncEmb
		fCalcFrete(4,.T.)
	Endif
	If lAltEmb
		fCalcFrete(5,.T.)
	Endif
	
	
	If	nValRem	>	0
		// Grupo Frete
		
		@ 008,004 TO 105,269 LABEL " Frete - R " PIXEL OF oDlgFrt
		
		@ 022,008 Say "Quilometragem Percorrida" Size 073,008 COLOR CLR_BLACK Font oFntGrN PIXEL OF oDlgFrt
		@ 022,084 MsGet oKilomet Var nKilomet Valid fCalcFrete(2) Size 030,010 COLOR CLR_BLACK Font oFntGrN Picture "@E 9,999" PIXEL OF oDlgFrt
		
		@ 022,140 Say "Valor por Km" Size 053,008 COLOR CLR_BLACK Font oFntGrN PIXEL OF oDlgFrt
		@ 022,199 MsGet oValKm Var nValKm Valid fCalcFrete(2) Size 050,010 COLOR CLR_BLACK Font oFntGrN Picture "@E 999,999.99" PIXEL OF oDlgFrt
		
		@ 043,008 Say "Valor por unidade SAC" Size 073,008 COLOR CLR_BLACK Font oFntGrN PIXEL OF oDlgFrt
		@ 043,084 MsGet oValSAC Var nValSAC Valid fCalcFrete(3) Size 050,010 COLOR CLR_BLACK Font oFntGrN Picture "@E 999,999.99" PIXEL OF oDlgFrt
		
		@ 064,008 Say "Frete Informado" Size 073,008 COLOR CLR_BLUE Font oFntGrB PIXEL OF oDlgFrt
		@ 064,084 MsGet oValFret Var nValFret When .F. Size 050,012 COLOR CLR_BLACK Font oFntGrB Picture "@E 999,999.99" PIXEL OF oDlgFrt
		
		@ 085,008 Say "Frete Calculado" Size 073,008 COLOR CLR_BLUE Font oFntGrB PIXEL OF oDlgFrt
		@ 085,084 MsGet oValFret2 Var nValFret2 When .F. Size 050,012 COLOR CLR_BLACK Font oFntGrB Picture "@E 999,999.99" PIXEL OF oDlgFrt
		
		@ 085,140 Say "% Frete na Carga" Size 050,008 COLOR CLR_BLUE Font oFntGrB PIXEL OF oDlgFrt
		@ 085,199 MsGet oPercTot2 Var nPercTot2 When .F. Size 035,012 COLOR CLR_BLACK Font oFntGrB Picture "@E 99.99" PIXEL OF oDlgFrt
	Else
		nKilomet	:=	0
		nValKm      :=	0
		nValSAC     :=	0
		nValFret    :=	0
		nValFret2   :=	0
		nPercTot2   :=	0
	Endif
	
	
	If	nValConf	>	0
		// Grupo Frete C
		@ 110,004 TO 205,269 LABEL " Frete - C " PIXEL OF oDlgFrt
		
		@ 122,008 Say "Quilometragem Percorrida" Size 073,008 COLOR CLR_BLACK Font oFntGrN PIXEL OF oDlgFrt
		@ 122,084 MsGet oCKilomet Var nCKilomet Valid fCalcFrete(2) Size 030,010 COLOR CLR_BLACK Font oFntGrN Picture "@E 9,999" PIXEL OF oDlgFrt
		
		@ 122,140 Say "Valor por Km" Size 053,008 COLOR CLR_BLACK Font oFntGrN PIXEL OF oDlgFrt
		@ 122,199 MsGet oCValKm Var nCValKm Valid fCalcFrete(2) Size 050,010 COLOR CLR_BLACK Font oFntGrN Picture "@E 999,999.99" PIXEL OF oDlgFrt
		
		@ 143,008 Say "Valor por unidade SAC" Size 073,008 COLOR CLR_BLACK Font oFntGrN PIXEL OF oDlgFrt
		@ 143,084 MsGet oCValSAC Var nCValSAC Valid fCalcFrete(3) Size 050,010 COLOR CLR_BLACK Font oFntGrN Picture "@E 999,999.99" PIXEL OF oDlgFrt
		
		@ 164,008 Say "Frete Informado" Size 073,008 COLOR CLR_BLUE Font oFntGrB PIXEL OF oDlgFrt
		@ 164,084 MsGet oCValFret Var nCValFret When .F. Size 050,012 COLOR CLR_BLACK Font oFntGrB Picture "@E 999,999.99" PIXEL OF oDlgFrt
		
		@ 185,008 Say "Frete Calculado" Size 073,008 COLOR CLR_BLUE Font oFntGrB PIXEL OF oDlgFrt
		@ 185,084 MsGet oCValFret2 Var nCValFret2 When .F. Size 050,012 COLOR CLR_BLACK Font oFntGrB Picture "@E 999,999.99" PIXEL OF oDlgFrt
		
		@ 185,140 Say "% Frete na Carga" Size 050,008 COLOR CLR_BLUE Font oFntGrB PIXEL OF oDlgFrt
		@ 185,199 MsGet oCPercTot2 Var nPercTotN When .F. Size 035,012 COLOR CLR_BLACK Font oFntGrB Picture "@E 99.99" PIXEL OF oDlgFrt
	Else
		nCKilomet	:=	0
		nCValKm      :=	0
		nCValSAC     :=	0
		nCValFret    :=	0
		nCValFret2   :=	0
		nPercTotN   :=	0
	Endif
	
	
	
	@ 212,004 TO 240,269 LABEL " ObservaÁ„o " PIXEL OF oDlgFrt
	
	@ 220,008 MsGet _oObs Var _cObs Size 255,010 COLOR CLR_BLACK Font oFntGrN Picture "@! " PIXEL OF oDlgFrt
	
	@ 245,186 Button "&Confirma" Size 037,013 Action Iif(fCalcFrete(4,.F.), (Close(oDlgFrt), lRetFrt := fCalcFrete(2),_lContinua:=	.F.), .F.) PIXEL OF oDlgFrt
	
	ACTIVATE MSDIALOG oDlgFrt CENTERED
Enddo
restarea(aArea)


Return(lRetFrt)


*********************************
Static Function fCalcFrete(nTipo, _lRecalcula, _lRefresh)
*********************************

Local lRet := .T.
Local i:=0
Local j:=0

Default _lRecalcula := .T.
Default _lRefresh	:= .T.

cPeds := ""
nPedSAC := 0
nTotSAC := 0


For i := 1 to len(aRemessa)
	cPeds += iif(!empty(aRemessa[i][1]), iif(!empty(cPeds), ",", "") + "'" + aRemessa[i][1] + "'", "")
Next i
/*
for j := 1 to len(aConfere)
cPeds += iif(!empty(aConfere[j][1]), iif(!empty(cPeds), ",", "") + "'" + aConfere[j][1] + "'", "")
next j

If !empty(cPeds)
cPeds := "(" + cPeds + ")"

cQuery := "SELECT NVL(COUNT(DISTINCT C5_NUM),0) AS nPED, NVL(SUM(C6_QTDVEN*C6_XPRUNIT),0) AS TOTALSAC "
cQuery += "FROM " + RetSqlName("SC5") + " SC5, "
cQuery +=           RetSqlName("SC6") + " SC6 "
cQuery += "WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery += "  AND SC6.D_E_L_E_T_ = ' ' "
cQuery += "  AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
cQuery += "  AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
cQuery += "  AND SC6.C6_NUM = SC5.C5_NUM "
cQuery += "  AND SC6.C6_CLI = SC5.C5_CLIENTE "
cQuery += "  AND SC6.C6_LOJA = SC5.C5_LOJACLI "
cQuery += "  AND SC5.C5_NUM IN " + cPeds
cQuery += "  AND SC5.C5_XOPER = '17' "

TCQUERY cQuery ALIAS "TMPSC5" NEW

nPedSAC := TMPSC5->nPED
nTotSAC := TMPSC5->TOTALSAC

TMPSC5->(DbCloseArea())
EndIf
*/

If !empty(cPeds)
	cPeds := "(" + cPeds + ")"
Endif


If	!Empty(cPeds)
	If nTipo >= 4
		//		cQuery 	:= " SELECT C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI, A1_XPERFRE, CASE WHEN C5_XOPER IN ('07') THEN SUM((C6_PRCVEN*C6_QTDVEN)) ELSE SUM((C6_XPRUNIT*C6_QTDVEN)*(100-(C6_XGUELTA+C6_XRESSAR))/100) END TOTPED "
		If nTipo = 4
			cQuery 	:= " SELECT C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI, A1_XPERFRE, C6_PRODUTO, SUM(DECODE(C5_TIPO,'P',C6_VALOR,DECODE(C5_XOPER,'07',C6_PRCVEN*C6_QTDVEN,C6_PRCVEN*C6_QTDVEN))) TOTPED, " //SSi 13666
		Else
			cQuery 	:= " SELECT C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI, A1_XPERFRE, C6_PRODUTO, " //SUM(DECODE(C5_TIPO,'P',C6_VALOR,DECODE(C5_XOPER,'07',C6_PRCVEN*C6_QTDVEN,C6_PRCVEN*C6_QTDVEN))) TOTPED, " //SSi 13666
			
			cQuery 	+= "	SUM(DECODE(C5_TIPO, "
			cQuery 	+= "				'P', "
			cQuery 	+= "	           C6_VALOR, "
			cQuery 	+= "	           DECODE(C5_XOPER, "
			cQuery 	+= "	                  '07', "
			cQuery 	+= "	                  C6_PRCVEN * C6_QTDVEN, "
			cQuery 	+= "	                  (CASE "
			cQuery 	+= "	                   WHEN C5_XDESPRO = '1' AND B1_IPI > 0 AND F4_IPI = 'S' AND "
			cQuery 	+= "	                        C5_XEMBARQ <> ' ' "
			cQuery 	+= "	                   THEN "
			cQuery 	+= "	                   		C6_XPRUNIT "
			If cEmpAnt == '03' //Para igular ao atendimento da SSI 20803
				cQuery 	+= "	                   WHEN C5_XDESPRO = '2' AND B1_IPI > 0 AND F4_IPI = 'S' AND "
				cQuery 	+= "	                        C5_XEMBARQ <> ' ' AND C5_XTPSEGM = '2' AND  "
				cQuery 	+= "	                        A3_GEREN = 'G00150' AND "
				cQuery 	+= "	                        B1_POSIPI = '94035000' "
				
				cQuery 	+= "	                   THEN "
				cQuery 	+= "	                   		C6_PRUNIT "
				
			EndIF
			cQuery 	+= "	                   WHEN C5_XDESPRO = '2' AND B1_IPI > 0 AND F4_IPI = 'S' AND "
			cQuery 	+= "	                        C5_XEMBARQ <> ' ' AND C5_XTPSEGM IN ('1','5','M','I') "
			cQuery 	+= "	                   THEN "
			cQuery 	+= "	                   		C6_PRUNIT "
			cQuery 	+= "	                   ELSE "
			cQuery 	+= "	                    	C6_PRCVEN "
			cQuery 	+= "	                   END) * C6_QTDVEN))) TOTPED, "
		EndIF
		
		/*		cQuery 	:= " SELECT C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI, A1_XPERFRE, C6_PRODUTO, "//SUM(DECODE(C5_TIPO,'P',C6_VALOR,DECODE(C5_XOPER,'07',C6_PRCVEN*C6_QTDVEN,C6_PRCVEN*C6_QTDVEN))) TOTPED, " //SSI 13666
		cQuery 	+= "	SUM(DECODE(C5_TIPO, "
		cQuery 	+= "				'P', "
		cQuery 	+= "	           C6_VALOR, "
		cQuery 	+= "	           DECODE(C5_XOPER, "
		cQuery 	+= "	                  '07', "
		cQuery 	+= "	                  C6_PRCVEN * C6_QTDVEN, "
		cQuery 	+= "	                  (CASE "
		cQuery 	+= "	                   WHEN C5_XDESPRO IN ('1', '2') AND B1_IPI > 0 AND F4_IPI = 'S' AND "
		cQuery 	+= "	                        C5_XEMBARQ <> ' ' "
		cQuery 	+= "	                   THEN "
		cQuery 	+= "	                   		C6_XPRUNIT "
		cQuery 	+= "	                   ELSE "
		cQuery 	+= "	                    	C6_PRCVEN "
		cQuery 	+= "	                   END) * C6_QTDVEN))) TOTPED, "*/
		
		cQuery 	+= "		CASE WHEN C5_XOPER IN ('07') THEN 'D' "
		cQuery 	+= "             WHEN C5_XOPER IN ('06') THEN 'DV' "
		cQuery 	+= "             WHEN C5_XOPER IN ('22') THEN 'Q' "
		cQuery 	+= "             WHEN C5_XOPER IN ('17') THEN 'T' "
		cQuery 	+= "             WHEN C5_XOPER IN ('08') THEN 'R' "
		cQuery 	+= "             WHEN C5_XOPER IN ('02') AND B1_XMODELO IN ('000015','000028') THEN 'Z' "
		cQuery 	+= "             WHEN C5_XOPER IN ('02') THEN 'E' "
		cQuery 	+= "             WHEN C5_XPRZMED = '000' AND C5_XOPER IN ('03')  AND C5_XVALENT = 0 THEN 'T' "
		//InÌcio SSI 13666
		cQuery 	+= "             WHEN C5_XOPER ='01' AND C5_XTPSEGM IN ('8') AND C6_PRODUTO NOT LIKE '407095%' Then 'SI' "
		cQuery 	+= "             WHEN C5_XOPER ='01' AND C5_XTPSEGM IN ('8') AND C6_PRODUTO     LIKE '407095%' Then 'ST' "
		//Fim SSI 13666
		cQuery 	+= "             WHEN C5_XVALENT <> 0 AND B1_XMODELO IN ('000015','000018') THEN 'S'  "
		cQuery 	+= "             WHEN C5_XPRZMED > '000' AND C5_XOPER IN ('03') AND C5_XTPSEGM IN ('3','4') AND C5_XVALENT = 0 THEN 'A' "
		cQuery 	+= "             WHEN C5_XVALENT <> 0 THEN 'A' "
		cQuery 	+= "             WHEN C5_XTPSEGM IN ('2','6') AND C5_XOPER IN ('03') AND C5_XPRZMED > '000' THEN 'C' "
		cQuery 	+= "             WHEN C5_XOPER IN ('05') THEN 'B' ELSE "
		cQuery 	+= "             CASE WHEN B1_XMODELO IN ('000015','000028') THEN CASE WHEN C5_XTPSEGM IN ('1','2','5','6','M','I') THEN 'Y' ELSE 'Z' END "
		cQuery 	+= "                  WHEN C5_XOPER IN ('08') THEN 'R' "
		cQuery 	+= "                  WHEN C5_XOPER IN ('16') THEN 'Z' "
		cQuery 	+= "                  ELSE"
		cQuery 	+= "                  CASE WHEN C5_XTPSEGM IN ('1','2','5','6','M','I') THEN 'V' "
		cQuery 	+= "                       WHEN C5_XTPSEGM IN ('3','4')     THEN 'F' "
		cQuery 	+= "                       ELSE 'X' END"
		cQuery 	+= "        END END QUEBRA "
		cQuery 	+= " FROM " + RetSqlName("SC5") +" SC5, " + RetSqlName("SA1") +" SA1, " + RetSqlName("SC6") + " SC6, "+ RetSqlName("SB1") + " SB1, "
		cQuery 	+= "  " + RetSqlName("SF4") +" SF4 ,  " + RetSqlName("SA3") +" SA3  "
		cQuery 	+= " WHERE C5_FILIAL 		= '"+ xFilial("SC5") +"' "
		cQuery 	+= "     AND C5_NUM IN " + cPeds
		cQuery 	+= "     AND SC5.D_E_L_E_T_ = ' ' "
		cQuery 	+= " 	 AND A1_FILIAL 		= '"+ xFilial("SA1") +"' "
		cQuery 	+= "     AND SB1.D_E_L_E_T_ = ' ' "
		cQuery 	+= " 	 AND B1_FILIAL 		= '"+ xFilial("SB1") +"' "
		cQuery 	+= " 	 AND C6_PRODUTO = B1_COD "
		cQuery 	+= "	 AND SF4.F4_FILIAL = '"+ xFilial("SF4") +"' "
		cQuery 	+= "	 AND SF4.D_E_L_E_T_ 	= ' ' "
		cQuery 	+= "	 AND F4_CODIGO    		= C6_TES "
		cQuery 	+= "	 AND SA3.A3_FILIAL = '"+ xFilial("SA3") +"' "
		cQuery 	+= "	 AND SA3.D_E_L_E_T_ 	= ' ' "
		cQuery 	+= "	 AND A3_COD    		= C5_VEND1 "
		cQuery 	+= "	 AND A1_COD 			= C5_CLIENT "
		cQuery 	+= "	 AND A1_LOJA 			= C5_LOJAENT "
		cQuery 	+= "	 AND SA1.D_E_L_E_T_ 	= ' ' "
		cQuery 	+= "	 AND C6_FILIAL 		= '"+ xFilial("SC6") +"' "
		cQuery 	+= "	 AND C6_NUM    		= C5_NUM "
		cQuery 	+= "	 AND SC6.D_E_L_E_T_ 	= ' ' "
		/*
		cQuery 	+= "	 AND C5_XOPER not in ('02','03','04','05','17','20' "
		If	SM0->M0_CODIGO	=	'03'
		cQuery 	+= ",07 "
		Endif
		cQuery 	+= " ) "	 //troca nao cobra frete
		If	SM0->M0_CODIGO	=	'03'
		cQuery 	+= "	 AND B1_XMODELO	<>	'000015' "
		Endif
		*/
		cQuery 	+= " GROUP BY C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI, A1_XPERFRE, C6_PRODUTO, C5_XOPER, C5_TIPO, B1_XMODELO, B1_IPI, C5_XPRZMED, C5_XVALENT, C5_XTPSEGM, F4_IPI " //SSI 13666
		cQuery 	+= " ORDER BY C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI "
		
		memowrit('C:\FRT.SQL',cQuery)
		
		TcQuery cQuery New Alias "CLIFRT"
		DbSelectArea('CLIFRT')
		DbGoTop()
		
		nValFret2	:= 0
		nPercTot2	:= 0
		_nTotPed	:= 0
		While CLIFRT->(!EOF())
			If	CLIFRT->QUEBRA = 'V' .Or. ;
				CLIFRT->QUEBRA = 'D' .Or. ;
				CLIFRT->QUEBRA = 'Y' .Or. ;
				CLIFRT->QUEBRA = 'Z' .Or. ;
				CLIFRT->QUEBRA = 'C' .Or. ;
				CLIFRT->QUEBRA = 'R' .Or. ;
				CLIFRT->QUEBRA = 'F' .OR. ;
				CLIFRT->QUEBRA = 'SI' .OR. ; //SSI 13666
				CLIFRT->QUEBRA = 'ST' //SSI 13666
				
				nValFret2 += CLIFRT->TOTPED * (CLIFRT->A1_XPERFRE/100)
				_nTotPed+=CLIFRT->TOTPED
				
			Endif
			CLIFRT->(DbSkip())
		Enddo
		//DbEVal({|| (nValFret2 += CLIFRT->TOTPED * (CLIFRT->A1_XPERFRE/100),_nTotPed+=CLIFRT->TOTPED) },{|| CLIFRT->(!EOF()) })
		//		Alert(nvalfret2)
		CLIFRT->(DBCloseArea())
		If	nValfret	>	0
			nPercTot2 := (nValFret/_nTotPed)*100
		Else
			nPercTot2 := (nValFret2/_nTotPed)*100
		Endif
		//		alert(nperctot2)
	endif
Endif
cPeds	:=	""
for j := 1 to len(aConfere)
	cPeds += iif(!empty(aConfere[j][1]), iif(!empty(cPeds), ",", "") + "'" + aConfere[j][1] + "'", "")
next j

If !empty(cPeds)
	cPeds := "(" + cPeds + ")"
Endif


If	!Empty(cPeds)
	if nTipo >= 4
		//		cQuery 	:= " SELECT C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI, A1_XPERFRE, CASE WHEN C5_XOPER IN ('07') THEN SUM((C6_PRCVEN*C6_QTDVEN)) ELSE SUM((C6_XPRUNIT*C6_QTDVEN)*(100-(C6_XGUELTA+C6_XRESSAR))/100) END TOTPED "
		If nTipo = 4
			cQuery 	:= " SELECT C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI, A1_XPERFRE, C6_PRODUTO, SUM(DECODE(C5_TIPO,'P',C6_VALOR,DECODE(C5_XOPER,'07',C6_PRCVEN*C6_QTDVEN,C6_PRCVEN*C6_QTDVEN))) TOTPED, " //SSi 13666
		Else
			cQuery 	:= " SELECT C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI, A1_XPERFRE, C6_PRODUTO, " //SUM(DECODE(C5_TIPO,'P',C6_VALOR,DECODE(C5_XOPER,'07',C6_PRCVEN*C6_QTDVEN,C6_PRCVEN*C6_QTDVEN))) TOTPED, " //SSi 13666
			
			cQuery 	+= "	SUM(DECODE(C5_TIPO, "
			cQuery 	+= "				'P', "
			cQuery 	+= "	           C6_VALOR, "
			cQuery 	+= "	           DECODE(C5_XOPER, "
			cQuery 	+= "	                  '07', "
			cQuery 	+= "	                  C6_PRCVEN * C6_QTDVEN, "
			cQuery 	+= "	                  (CASE "
			cQuery 	+= "	                   WHEN C5_XDESPRO = '1' AND B1_IPI > 0 AND F4_IPI = 'S' AND "
			cQuery 	+= "	                        C5_XEMBARQ <> ' ' "
			cQuery 	+= "	                   THEN "
			cQuery 	+= "	                   		C6_XPRUNIT "
			If cEmpAnt == '03' //Para igular ao atendimento da SSI 20803
				cQuery 	+= "	                   WHEN C5_XDESPRO = '2' AND B1_IPI > 0 AND F4_IPI = 'S' AND "
				cQuery 	+= "	                        C5_XEMBARQ <> ' ' AND C5_XTPSEGM = '2' AND  "
				cQuery 	+= "	                        A3_GEREN = 'G00150' AND "
				cQuery 	+= "	                        B1_POSIPI = '94035000' "
				
				cQuery 	+= "	                   THEN "
				cQuery 	+= "	                   		C6_PRUNIT "
				
			EndIF
			cQuery 	+= "	                   WHEN C5_XDESPRO = '2' AND B1_IPI > 0 AND F4_IPI = 'S' AND "
			cQuery 	+= "	                        C5_XEMBARQ <> ' ' AND C5_XTPSEGM IN ('1','5','M','I') "
			cQuery 	+= "	                   THEN "
			cQuery 	+= "	                   		C6_PRUNIT "
			cQuery 	+= "	                   ELSE "
			cQuery 	+= "	                    	C6_PRCVEN "
			cQuery 	+= "	                   END) * C6_QTDVEN))) TOTPED, "
		EndIF
		cQuery 	+= "		CASE WHEN C5_XOPER IN ('07') THEN 'D' "
		cQuery 	+= "             WHEN C5_XOPER IN ('06') THEN 'DV' "
		cQuery 	+= "             WHEN C5_XOPER IN ('22') THEN 'Q' "
		cQuery 	+= "             WHEN C5_XOPER IN ('17') THEN 'T' "
		cQuery 	+= "             WHEN C5_XOPER IN ('08') THEN 'R' "
		cQuery 	+= "             WHEN C5_XOPER IN ('02') AND B1_XMODELO IN ('000015','000028') THEN 'Z' "
		cQuery 	+= "             WHEN C5_XOPER IN ('02') THEN 'E' "
		cQuery 	+= "             WHEN C5_XPRZMED = '000' AND C5_XOPER IN ('03')  AND C5_XVALENT = 0 THEN 'T' "
		//InÌcio SSI 13666
		cQuery 	+= "             WHEN C5_XOPER ='01' AND C5_XTPSEGM IN ('8') AND C6_PRODUTO NOT LIKE '407095%' Then 'SI' "
		cQuery 	+= "             WHEN C5_XOPER ='01' AND C5_XTPSEGM IN ('8') AND C6_PRODUTO     LIKE '407095%' Then 'ST' "
		//Fim SSI 13666
		cQuery 	+= "             WHEN C5_XVALENT <> 0 AND B1_XMODELO IN ('000015','000028') THEN 'S'  "
		cQuery 	+= "             WHEN C5_XPRZMED > '000' AND C5_XOPER IN ('03') AND C5_XTPSEGM IN ('3','4') AND C5_XVALENT = 0 THEN 'A' "
		cQuery 	+= "             WHEN C5_XVALENT <> 0 THEN 'A' "
		cQuery 	+= "             WHEN C5_XTPSEGM IN ('2','6') AND C5_XOPER IN ('03') AND C5_XPRZMED > '000' THEN 'C' "
		cQuery 	+= "             WHEN C5_XOPER IN ('05') THEN 'B' ELSE "
		cQuery 	+= "             CASE WHEN B1_XMODELO IN ('000015','000028') THEN CASE WHEN C5_XTPSEGM IN ('1','2','5','6','M','I') THEN 'Y' ELSE 'Z' END "
		cQuery 	+= "                  WHEN C5_XOPER IN ('08') THEN 'R' "
		cQuery 	+= "                  WHEN C5_XOPER IN ('16') THEN 'Z' "
		cQuery 	+= "                  ELSE"
		cQuery 	+= "                  CASE WHEN C5_XTPSEGM IN ('1','2','5','6','M','I') THEN 'V' "
		cQuery 	+= "                       WHEN C5_XTPSEGM IN ('3','4')     THEN 'F' "
		cQuery 	+= "                       ELSE 'X' END"
		cQuery 	+= "        END END QUEBRA "
		cQuery 	+= " FROM " + RetSqlName("SC5") +" SC5, " + RetSqlName("SA1") +" SA1, " + RetSqlName("SC6") + " SC6, "+ RetSqlName("SB1") + " SB1, "
		cQuery 	+= "  " + RetSqlName("SF4") +" SF4,  " + RetSqlName("SA3") +" SA3  "
		cQuery 	+= " WHERE C5_FILIAL 		= '"+ xFilial("SC5") +"' "
		cQuery 	+= "     AND C5_NUM IN " + cPeds
		cQuery 	+= "     AND SC5.D_E_L_E_T_ = ' ' "
		cQuery 	+= " 	 AND A1_FILIAL 		= '"+ xFilial("SA1") +"' "
		cQuery 	+= "	 AND A1_COD 			= C5_CLIENT "
		cQuery 	+= "	 AND A1_LOJA 			= C5_LOJAENT "
		cQuery 	+= "	 AND SA1.D_E_L_E_T_ 	= ' ' "
		cQuery 	+= "	 AND SB1.B1_FILIAL = '"+ xFilial("SB1") +"' "
		cQuery 	+= "	 AND SB1.D_E_L_E_T_ 	= ' ' "
		cQuery 	+= "	 AND SF4.F4_FILIAL = '"+ xFilial("SF4") +"' "
		cQuery 	+= "	 AND SF4.D_E_L_E_T_ 	= ' ' "
		cQuery 	+= "	 AND F4_CODIGO    		= C6_TES "
		cQuery 	+= "	 AND SA3.A3_FILIAL = '"+ xFilial("SA3") +"' "
		cQuery 	+= "	 AND SA3.D_E_L_E_T_ 	= ' ' "
		cQuery 	+= "	 AND A3_COD    		= C5_VEND1 "
		cQuery 	+= "	 AND C6_FILIAL 		= '"+ xFilial("SC6") +"' "
		cQuery 	+= "	 AND C6_NUM    		= C5_NUM "
		cQuery 	+= "	 AND B1_COD    		= C6_PRODUTO "
		cQuery 	+= "	 AND SC6.D_E_L_E_T_ 	= ' ' "
		/*
		cQuery 	+= "	 AND C5_XOPER not in ('02','03','04','05','17','20' "
		If	SM0->M0_CODIGO	=	'03'
		cQuery 	+= ",07 "
		Endif
		cQuery 	+= " ) "	 //troca nao cobra frete
		If	SM0->M0_CODIGO	=	'03'
		cQuery 	+= "	 AND B1_XMODELO	<>	'000015' "
		Endif
		*/
		cQuery 	+= " GROUP BY C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI, A1_XPERFRE, C6_PRODUTO, C5_XOPER, C5_TIPO, B1_XMODELO, B1_IPI, C5_XPRZMED, C5_XVALENT, C5_XTPSEGM, F4_IPI " //SSI 13666
		cQuery 	+= " ORDER BY C5_XEMBARQ, C5_CLIENTE, C5_LOJACLI "
		
		memowrit('C:\FRT.SQL',cQuery)
		
		TcQuery cQuery New Alias "CLIFRT"
		DbSelectArea('CLIFRT')
		DbGoTop()
		
		nCValFret2	:= 0
		nPercTotN	:= 0
		_nTotPedN	:= 0
		
		While CLIFRT->(!EOF())
			If	CLIFRT->QUEBRA = 'V' .Or. ;
				CLIFRT->QUEBRA = 'D' .Or. ;
				CLIFRT->QUEBRA = 'Y' .Or. ;
				CLIFRT->QUEBRA = 'Z' .Or. ;
				CLIFRT->QUEBRA = 'C' .Or. ;
				CLIFRT->QUEBRA = 'R' .Or. ;
				CLIFRT->QUEBRA = 'F' .OR. ;
				CLIFRT->QUEBRA = 'SI' .OR. ; //SSI 13666
				CLIFRT->QUEBRA = 'ST' //SSI 13666
				
				nCValFret2 	+= CLIFRT->TOTPED * (CLIFRT->A1_XPERFRE/100)
				_nTotPedN	+=CLIFRT->TOTPED
				
			Endif
			CLIFRT->(DbSkip())
		Enddo
		
		//DbEVal({|| (nCValFret2 += CLIFRT->TOTPED * (CLIFRT->A1_XPERFRE/100),_nTotPedN+=CLIFRT->TOTPED) },{|| CLIFRT->(!EOF()) })
		
		CLIFRT->(DBCloseArea())
		
		If	nCValfret	>	0
			nPercTotN := (nCValFret/_nTotPedN)*100
		Else
			nPercTotN := (nCValFret2/_nTotPedN)*100
		Endif
		
		
	endif
Endif





If _lRecalcula
	Do Case
		case nPerFret > 0 .AND. (nTipo == 1 .OR. nTipo == 4)
			nKilomet := 0
			nValKm 	:= 0
			nValSAC	:= 0
			nValFret := (nValRem - nTotSAC) * (nPerFret/100)
			//			nPercTot := nPerFret
			
		case (nKilomet > 0 .or. nValKm > 0) .AND. (nTipo == 2 .OR. nTipo == 4)
			nPerFret := 0
			nValSAC	:= 0
			nValFret := nKilomet * nValKm
			if nValFret2==0
				nValFret2:=nKilomet * nValKm
			endif
			//			nPercTot := (nValFret / nValTot) * 100
			
		case nValSAC > 0 .AND. (nTipo == 3 .OR. nTipo == 4)
			nPerFret := 0
			nKilomet := 0
			nValKm 	:= 0
			nValFret := nValSAC * nPedSAC
			//			nPercTot := (nValFret / nValTot) * 100
			
		case nPerFret == 0 .and. nKilomet == 0 .and. nValKm == 0 .and. nValSAC == 0
			nValFret := 0
			//			nPercTot := 0
		case nTipo == 5
			DbSelectArea("SZQ")
			dbOrderNickName("CSZQ1")
			DbSeek(xFilial('SZQ')+cEmb)
			IF SZQ->ZQ_VALORKM>0
				fCalcFrete(2,.T.,.F.)
			elseif SZQ->ZQ_VALORSA>0
				fCalcFrete(3,.T.,.F.)
			else
				nValSAC	:= 0
				nKilomet:= 0
				nValKm 	:= 0
				nValFret:= 0
			endif
	EndCase
	
endif

If _lRecalcula
	Do Case
		case nCPerFret > 0 .AND. (nTipo == 1 .OR. nTipo == 4)
			nCKilomet := 0
			nCValKm 	:= 0
			nCValSAC	:= 0
			nCValFret := (nValconf - nCTotSAC) * (nCPerFret/100)
			//			nCValFret := (nCValTot - nCTotSAC) * (nCPerFret/100)
			//			nPercTot := nPerFret
			
		case (nCKilomet > 0 .or. nCValKm > 0) .AND. (nTipo == 2 .OR. nTipo == 4)
			nCPerFret := 0
			nCValSAC	:= 0
			nCValFret := nCKilomet * nCValKm
			if nCValFret2 > 0
				nCValFret := nCKilomet * nCValKm
			endif
			//			nPercTot := (nValFret / nValTot) * 100
			
		case nCValSAC > 0 .AND. (nTipo == 3 .OR. nTipo == 4)
			nCPerFret := 0
			nCKilomet := 0
			nCValKm 	:= 0
			nCValFret := nCValSAC * nCPedSAC
			//			nPercTot := (nValFret / nValTot) * 100
			
		case nCPerFret == 0 .and. nCKilomet == 0 .and. nCValKm == 0 .and. nCValSAC == 0
			nCValFret := 0
			//			nPercTot := 0
		case nTipo == 5
			DbSelectArea("SZQ")
			dbOrderNickName("CSZQ1")
			DbSeek(xFilial('SZQ')+cEmb)
			IF SZQ->ZQ_VALORKM>0
				fCalcFrete(2,.T.,.F.)
			elseif SZQ->ZQ_VALORSA>0
				fCalcFrete(3,.T.,.F.)
			else
				nCValSAC	:= 0
				nCKilomet:= 0
				nCValKm 	:= 0
				nCValFret:= 0
			endif
	EndCase
	
endif




if _lRefresh
	If nTipo < 4	// ConfirmaÁ„o da tela de frete
		//	oPerFret:Refresh()
		If nValRem > 0
			oKilomet:Refresh()
			oValKm:Refresh()
			oValSAC:Refresh()
			oValFret:Refresh()
			oValFret2:Refresh()
			//	oPercTot:Refresh()
			oPercTot2:Refresh()
		Endif
		If nValConf > 0
			oCKilomet:Refresh()
			oCValKm:Refresh()
			oCValSAC:Refresh()
			oCValFret:Refresh()
			oCValFret2:Refresh()
			//	oPercTot:Refresh()
			oCPercTot2:Refresh()
		Endif
	Else
		//	If empty(cCodTrans)
		//lRet := .F.
		//		lRet := .t.
		//		MsgAlert("Favor informar motorista no fechamento do embarque !!!", "AtenÁ„o !")
		//	EndIf
		//		If nValFret2 == 0 .and. nValFret == 0
		//			lRet := .F.
		//			MsgAlert("Dever· ser definido o valor do frete para confirmaÁ„o da tela !!!", "AtenÁ„o !")
		//	EndIf
	EndIf
endif

Return(lRet)


*********************************
Static Function ValidPerg(cPerg)
*********************************

DbSelectArea("SX1")
DbSetOrder(1) //NAO TROCAR

aRegs := {}

aAdd(aRegs,{cPerg,"01","Da Rota............:", "", "", "MV_CH1","C",06,0,0,"G","","mv_par01","" ,"","","","",;
""				,"","","","",""					,"","","","","","","","","","","","","","SZ3"	 ,"" ,"",""})
aAdd(aRegs,{cPerg,"02","Ate a Rota.........:", "", "", "MV_CH2","C",06,0,0,"G","","mv_par02","" ,"","","","",;
""				,"","","","",""					,"","","","","","","","","","","","","","SZ3"	 ,"" ,"",""})
aAdd(aRegs,{cPerg,"03","Da Data Entrega....:", "", "", "MV_CH3","D",08,0,0,"G","","mv_par03",""		 ,"","","","",;
""				,"","","","",""					,"","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Ate Data Entrega...:", "", "", "MV_CH4","D",08,0,0,"G","","mv_par04",""		 ,"","","","",;
""				,"","","","",""					,"","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Data Programacao...:", "", "", "MV_CH5","D",08,0,0,"G","Iif(lAltEmb .and. MV_PAR05 <> SZQ->ZQ_DTPREVE,.F.,.T.)","mv_par05",""		 ,"","","","",;
""				,"","","","",""					,"","","","","","","","","","","","","","","","",""})

aAdd(aRegs,{cPerg,"06","Espaco do Caminhao...:", "", "", "MV_CH6","N",8,3,0,"G","Iif(MV_PAR06 > 0,.T.,.F.)","mv_par06",""		 ,"","","","",;
""				,"","","","",""					,"","","","","","","","","","","","","","","","",""})
/*Aadd(aRegs,{cPerg,"06","Espaco do Caminhao ....:","","","MV_CH6","N" ,8,3,0,"C","Iif(MV_PAR06 > 0,.T.,.F.)","mv_par06","600","","","800","","1000","","","","","8","","","",;
"","8","","","","","","","","","",""}) //Pergunta combobox TESTE*/





//Cria Pergunta
cPerg := U_AjustaSx1(cPerg,aRegs)

Return

*********************************              
Static Function LocalizSel(__nTp)
********************************
Local nPos:=0
Local lRet:=.F.
if len(alltrim(cRemove))=0
	lRet:=.T.
else
	nPos:=ascan(aRemessa,{|x| x[1]==alltrim(cRemove)})
	if nPos > 0
		oRemessa:nAt:=nPos
		RemoveSel(@aRemessa,@oRemessa)
		cRemove:=space(7)
		oRemove:SetFocus()
		oRemove:Refresh()
	else
		nPos:=ascan(aRemessa,{|x| x[7]==alltrim(cRemove)})
		If nPos > 0
			oRemessa:nAt:=nPos
			RemoveSel(@aRemessa,@oRemessa)
			cRemove:=space(7)
			oRemove:SetFocus()
			oRemove:Refresh()
		Else
			nPos:=ascan(aConfere,{|x| x[1]==alltrim(cRemove)})
			if nPos > 0
				oConfere:nAt:=nPos
				RemoveSel(@aConfere,@oConfere)
				cRemove:=space(7)
				oRemove:SetFocus()
				oRemove:Refresh()
			else
				nPos:=ascan(aConfere,{|x| x[6]==alltrim(cRemove)})
				if nPos > 0
					oConfere:nAt:=nPos
					RemoveSel(@aConfere,@oConfere)
					cRemove:=space(7)
					oRemove:SetFocus()
					oRemove:Refresh()                                                 
				else
					MsgBox("Pedido nao selecionado para o embarque")
				endif
			endif
		endif
	endif
endif
Return(lRet)
******************************************
Static Function RemoveSel(aArray,oArray)
******************************************
Local aAux:={}
Local i:=0
Local cPedRem:=aArray[oArray:nAt,1]
Local nTam:=len(aArray)

If len(aArray) > 0 .and. !empty(aArray[1,1]) .and. !lVisu
	if Empty(aOrigem[1,1])
		aOrigem:={}
	endif
	aadd(aOrigem,{aArray[oArray:nAt,1],aArray[oArray:nAt,2],aArray[oArray:nAt,3],aArray[oArray:nAt,4],aArray[oArray:nAt,5],aArray[oArray:nAt,6],aArray[oArray:nAt,7]})
	//aOrigem:=aSort(aOrigem,,,{|x,y| x[1]<y[1]})
	aOrigem:=aSort(aOrigem,,,{|x,y| x[2]+x[1] < y[2] + y[1]})
	for i:=1 to len(aArray)
		if i <> oArray:nAt
			aadd(aAux,aArray[i])
		endif
	next
	aArray:=aAux
	if Len(aArray) < 1
		//		aArray:={{"","","","",0}}
		if nTam==6
			aArray :={{"","","","",0,"",,""}}
		else
			aArray :={{"","","","",0,"",""}}
		endif
		
	endif
	RefazRem()
	RefazConf()
	If	__nTp	=	1
		MsgBox("Pedido "+cPedRem+" excluido com sucesso","Pedido Excluido")
	Endif
	
	nPos:=ascan(_aPedRet,{|x| x[1]==cPedRem})
	
	If nPos	=	0
		AADD(_aPedRet,{cPedRem})
	Else
		Alert("Pedido j· selecionado excluido da carga")
	Endif
	
endif
Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Mensagem  ∫Autor  ≥Renato Lucena Neves ∫ Data ≥  03/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Chamada das rotinas da pontuaÁ„o cum a funcao MSGRUN       ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP8-Ortobom                                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function Mensagem1()

MsgRun("Calculando a pontuaÁ„o. Aguarde...",,{ || MontaTree() })

return

Static Function Mensagem2()

MsgRun("Selecionando os pedidos. Aguarde...",,{ || fconsTree() })

return

Static Function Mensagem3()

MsgRun("Selecionando o pedido. Aguarde...",,{ || fVerPedido() })

return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MontaTree ∫Autor  ≥Renato Lucena Neves ∫ Data ≥  08/27/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Tela com a arvore de pontuaÁ„o                             ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP8-Ortobom                                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
static function MontaTree()

Local _cDesc	:= ''
Local _cChavePri:= ''
Local _cChave	:= ''
Local _cChaveF	:= ''
Local _nI		:= 1
Local _cArq		:= ""
Local _cFolder1	:= ""
Local _cFolder2	:= ""

Private _nFatorSM	:= GetMV('MV_XPTOSM')
Private _aPedido	:= {}
Private _oDlg
PRIVATE _oTree
Private _oPanel
Private _oSetor
Private _oRecurso
Private _oMaxPto
Private _oTotPto
Private _oDifPto
Private _cMaxPto := Transform(0,"@E 9,999.999")
Private _cSetor  := ""
Private _cRecurso:= Transform(0,"@E 999,999")
Private _cTotPto := Transform(0,"@E 999,999.999")
Private _cDifPto := Transform(0,"@E 9,999.999")
Private aItensTree	:= {}


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Guarda os pedidos que est„o na memÛria≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For _nI:=1 to len(aRemessa)
	aAdd(_aPedido,aRemessa[_nI][1])
Next _nI
For _nI:=1 to len(aConfere)
	aAdd(_aPedido,aConfere[_nI][1])
Next _nI


_cArq:=u_Pontuacao(MV_PAR05,_aPedido)
If TMP1->(Eof())
	MsgStop('N„o existem dados para formaÁ„o da pontuaÁ„o!')
else
	DEFINE MSDIALOG _oDlg TITLE "Mapa da PontuaÁ„o" From 000,000 TO  600,800 OF oMainWnd PIXEL
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Montando a Arvore de pontuaÁ„o                 ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	_oTree := DbTree():New( 010, 010, 240 ,400 ,,,,.T.)
	
	_oTree:bLDBLClick:={|| mensagem2() }
	_oTree:bLClicked:={|| fRodaPe() }
	
	_cChavePri	:= StrZero(0,10)
	
	_oTree:Reset()
	While TMP1->(!EOF())
		
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒDø
		//≥Existem OPs em aberto e saldo em estoque para suprir a produÁ„o  ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒDŸ
		//		If TMP1->(OP+B2_QATU) >= TMP1->VENDIDO
		//			TMP1->(DbSkip())
		//			Loop
		//		endif
		
		_cDesc		:= TMP1->PA5_DESCR
		_cChave  	:= TMP1->PA5_CODIGO
		
		while TMP2->PA5_CODIGO<>TMP1->PA5_CODIGO
			TMP2->(DbSkip())
		enddo
		
		If TMP2->PTOPROD > TMP2->PTOMAX
			_cFolder1:="FOLDER7"
			_cFolder2:="FOLDER8"
		else
			_cFolder1:="FOLDER5"
			_cFolder2:="FOLDER6"
		endif
		_oTree:AddTree(_cDesc,.F.,_cFolder1,_cFolder2,,,_cChave)
		_cCodAnt:=TMP1->PA5_CODIGO
		
		
		While TMP1->(!EOF()) .and. TMP1->PA5_CODIGO==_cCodAnt
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒDø
			//≥Existem OPs em aberto e saldo em estoque para suprir a produÁ„o  ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒDŸ
			//			If TMP1->(OP+B2_QATU) >= TMP1->VENDIDO
			//				TMP1->(DbSkip())
			//				Loop
			//			endif
			
			//			_cProduto := GetAdvFVal('SB1','B1_DESC',xFilial('SB1')+(TMP1->PRODUTO),1,'')
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Verifica se e solteiro≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			_cProcesso := TMP1->ZR_DESC
			_cDesc:=_cProcesso
			IF TMP1->TAMANHO = 'B'
				_cDesc := alltrim(_cDesc)+" BERCO "
				_nPto  := TMP1->PAB_PTOBER   //_nQtd * Qry->PAB_PTOBER  //Qry->SOLTEIRO
			ElseIF TMP1->TAMANHO = 'S'  // .and. Qry->B1_XBIPART <> 'S'
				_cDesc := alltrim(_cDesc)+" SOLTEIRO"
				_nPto  := TMP1->PAB_PTOSOL   //_nQtd * Qry->PAB_PTOSOL  //Qry->SOLTEIRO
			Else
				_cDesc := alltrim(_cDesc)+" CASAL"
				_nPto  := TMP1->PAB_PTOCAS    //_nQtd * Qry->PAB_PTOCAS  //Qry->SOLTEIRO
			EndIf
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Verifica se e bi-partido≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IF TMP1->BIPARTIDO = 'S'
				_cDesc := alltrim(_cDesc)+" BI-PARTIDO"
				_nPto  := ( TMP1->PTOSOL * 2 )   //_nQtd * Qry->PTOSOL *2
			endif
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Verifica se e sob medida≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			IF TMP1->PADRAO = 'S'
				_cDesc := alltrim(_cDesc)+" (SM)"
				_nPto  *= _nFatorSM
			endif
			
			
			//			_cDesc	:=	TMP1->ZR_CODIGO+" - "+_cDesc
			_cChaveF:=	_cProcesso
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Adiciona o Produto                             ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			_oTree:AddTreeItem(_cDesc, _cFolder1,_cFolder2,_cChave+_cChaveF)
			
			AADD(aItensTree, {_cChave+_cChaveF,TMP1->PA5_DESCR, _cDesc, TMP2->PTOMAX, TMP1->PA5_QTREC, TMP2->PTOPROD, TMP1->PRODUZIR})
			
			
			TMP1->(DbSkip())
		enddo
		
		TMP2->(DbSkip())
		_otree:endTree()
		
	enddo
	
	_oTree:EndTree()
	_oTree:Refresh()
	_oTree:SetFocus()
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Monta o roda pÈ da tela≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	
	_oPanel := TPanel():New(240,005,"",_oDlg,,,,,RGB(245,245,245),400,060)
	
	@ 005,005 Say "Setor" pixel of _oPanel
	@ 015,005 Get _oSetor  var _cSetor     when .F. Size 250,10 pixel of _oPanel
	@ 030,005 Say "Recursos" pixel of _oPanel
	@ 040,005 Get _oRecurso  var _cRecurso when .F. Size 50,10 pixel of _oPanel
	@ 030,065 Say "Pontos Max." pixel of _oPanel
	@ 040,065 Get _oMaxPto  var _cMaxPto   when .F. Size 50,10 pixel of _oPanel
	@ 030,125 Say "Pontos Total" pixel of _oPanel
	@ 040,125 Get _oTotPto  var _cTotPto   when .F. Size 50,10 pixel of _oPanel
	@ 030,185 Say "Dif. Pontos" pixel of _oPanel
	@ 040,185 Get _oDifPto  var _cDifPto   when .F. Size 50,10 pixel of _oPanel
	@ 030,300 Button "Sair" Size 50,17 Action (fRodaPe(),_oDlg:end()) pixel	of _oPanel
	
	ACTIVATE MSDIALOG _oDlg CENTERED
endif

TMP1->(DbCLoseArea())
TMP2->(DbCLoseArea())

FErase(_cArq+GetDbExtension())

RestArea(_aArea)

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Pontuacao ∫Autor  ≥Renato Lucena Neves ∫ Data ≥  03/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Cria um Alias com a pontiacao                              ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function Pontuacao(_dEmbarque,_aPedido,_lParar)

Local _cQuery 	:= ""
Local _nI		:= 0
Local _cPedido	:= ""

For _nI:=1 to Len(_aPedido)
	if _lParar
		return
	endif
	_cPedido+="'"+_aPedido[_nI]+"',"
Next _nI

if len(_aPedido)>1
	_cPedido:=left(_cPedido,len(_cPedido)-1)
else
	_cPedido := "' '"
endif
_cPedido:=StrTran(_cPedido,"''","' '") //caso n„o tenha um espaÁo entre as aspas a query È zerada

_cOrdem:=" order by PA5_CODIGO, ZR_CODIGO, TAMANHO, BIPARTIDO, PADRAO "



_cQuery	:= " select ZR_CODIGO, ZR_DESC, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, PA5_CODIGO, PA5_DESCR,  "
_cQuery	+= " PA5_QTREC, PA5_PTOS, sum(VENDIDO-OP-ESTOQUE) PRODUZIR, BIPARTIDO, PADRAO, TAMANHO "
_cQuery	+= " from ( "
_cQuery	+= " select ZR_CODIGO, ZR_DESC, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, PA5_CODIGO, PA5_DESCR, "
_cQuery	+= " PA5_QTREC, PA5_PTOS, sum(VENDIDO) VENDIDO, BIPARTIDO, PADRAO, TAMANHO, B1_COD, ESTOQUE, "
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Aproveitamento de OP≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
_cQuery	+= " NVL((select sum((C2_QUANT-C2_QUJE)-(C2_XQTDPID+C2_XQTDNPD)) "
_cQuery	+= " from "+RetSqlName('SC2')+" where C2_FILIAL='"+xFilial('SC2')+"' and D_E_L_E_T_=' ' and C2_PRODUTO=B1_COD "
_cQuery	+= " and (C2_QUANT-C2_QUJE)-(C2_XQTDPID+C2_XQTDNPD)>0),0) OP "
_cQuery	+= " from (                                                                "
//---produtos ja programados, sem industrial (B1_COD not like ('2%'))
_cQuery	+= " select ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, B1_COD, NVL(B2_QATU,0) ESTOQUE ,"
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS, sum(C6_QTDVEN) VENDIDO, "
_cQuery	+= " CASE WHEN b1_xbipart = ' ' THEN 'N' ELSE b1_xbipart END BIPARTIDO,         "
_cQuery	+= " case when B1_COD=B1_XCODBAS or B1_XCODBAS=' ' then 'S' else 'N' end PADRAO,         "
_cQuery	+= " case when B1_XLARG<0.78 then 'B' when B1_XLARG<1.28 then 'S' else 'C' end TAMANHO "
_cQuery	+= " from "+RetSqlName('PA6')+" PA6, "+RetSqlName('SZR')+" ZR, "+RetSqlName('PAB')+" PAB, "+RetSqlName('PA5')+" PA5, "+RetSqlName('SB1')+" B1, "+RetSqlName('SC6')+" C6, "+RetSqlName('SC5')+" C5, "+RetSqlName('SZQ')+" ZQ , "+RetSqlName('SB2')+" B2 "
_cQuery	+= " where PA6_GRPPRO=ZR_CODIGO and PAB_PROCES=ZR_CODIGO and PA5_CODIGO=PAB_DEPART and B2_COD(+)=B1_COD "
_cQuery	+= " and B1_GRUPO=PA6_LINHA and C6_PRODUTO=B1_COD and C5_NUM=C6_NUM  and ZQ_EMBARQ=C5_XEMBARQ "
_cQuery	+= " and PA6_FILIAL='"+xFilial('PA6')+"' and ZR_FILIAL='"+xFilial('SZR')+"' and PAB_FILIAL='"+xFilial('PAB')+"' and PA5_FILIAL='"+xFilial('PA5')+"' "
_cQuery	+= " and B1_FILIAL='"+xFilial('SB1')+"' and C6_FILIAL='"+xFilial('SC6')+"' and C5_FILIAL='"+xFilial('SC5')+"' and ZQ_FILIAL='"+xFilial('SZQ')+"' and B2_FILIAL(+)='"+xFilial('SB2')+"' "
_cQuery	+= " and ZR.D_E_L_E_T_=' ' and PA6.D_E_L_E_T_=' ' and PAB.D_E_L_E_T_=' ' and PA5.D_E_L_E_T_=' ' "
_cQuery	+= " and B1.D_E_L_E_T_=' ' and C6.D_E_L_E_T_=' ' and C5.D_E_L_E_T_=' ' and ZQ.D_E_L_E_T_=' ' and B2.D_E_L_E_T_(+)=' '"
_cQuery	+= " and B1_COD not like ('2%') and AND B1_XMODELO NOT IN ('000015','000028') and ZQ_DTPREVE='"+dtos(_dEmbarque)+"' "
_cQuery	+= " and C5_NUM not in ("+_cPedido+") and B2_LOCAL(+)='18' and C5_XOPER not in ('04','20','21','96','99','98') "
_cQuery	+= " group by ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, B2_QATU, "
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS,b1_xbipart, B1_XCODBAS,B1_XLARG,B1_COD "
//---produtos ja programados, so industrial (B1_COD like ('2%'))
_cQuery	+= " union all "
_cQuery	+= " select ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, B1_COD, NVL(B2_QATU,0) ESTOQUE ,"
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS, sum(C6_QTDVEN) VENDIDO, "
_cQuery	+= " CASE WHEN b1_xbipart = ' ' THEN 'N' ELSE b1_xbipart END BIPARTIDO,         "
_cQuery	+= " case when B1_COD=B1_XCODBAS or B1_XCODBAS=' ' then 'S' else 'N' end PADRAO,         "
_cQuery	+= " case when B1_XLARG<0.78 then 'B' when B1_XLARG<1.28 then 'S' else 'C' end TAMANHO "
_cQuery	+= " from "+RetSqlName('PA6')+" PA6, "+RetSqlName('SZR')+" ZR, "+RetSqlName('PAB')+" PAB, "+RetSqlName('PA5')+" PA5, "+RetSqlName('SB1')+" B1, "+RetSqlName('SC6')+" C6, "+RetSqlName('SC5')+" C5, "+RetSqlName('SZQ')+" ZQ , "+RetSqlName('SB2')+" B2 "
_cQuery	+= " where PA6_GRPPRO=ZR_CODIGO and PAB_PROCES=ZR_CODIGO and PA5_CODIGO=PAB_DEPART and B2_COD(+)=B1_COD "
_cQuery	+= " and 'A'||substr(('0000'||to_char(B1_XALT*1000)),length('0000'||to_char(B1_XALT*1000))-2,4)=PA6_LINHA "
_cQuery	+= " and C6_PRODUTO=B1_COD and C5_NUM=C6_NUM  and ZQ_EMBARQ=C5_XEMBARQ "
_cQuery	+= " and PA6_FILIAL='"+xFilial('PA6')+"' and ZR_FILIAL='"+xFilial('SZR')+"' and PAB_FILIAL='"+xFilial('PAB')+"' and PA5_FILIAL='"+xFilial('PA5')+"' "
_cQuery	+= " and B1_FILIAL='"+xFilial('SB1')+"' and C6_FILIAL='"+xFilial('SC6')+"' and C5_FILIAL='"+xFilial('SC5')+"' and ZQ_FILIAL='"+xFilial('SZQ')+"' and B2_FILIAL(+)='"+xFilial('SB2')+"' "
_cQuery	+= " and ZR.D_E_L_E_T_=' ' and PA6.D_E_L_E_T_=' ' and PAB.D_E_L_E_T_=' ' and PA5.D_E_L_E_T_=' ' and C5_XOPER not in ('04','20','21','96','99','98')"
_cQuery	+= " and B1.D_E_L_E_T_=' ' and C6.D_E_L_E_T_=' ' and C5.D_E_L_E_T_=' ' and ZQ.D_E_L_E_T_=' ' and B2.D_E_L_E_T_(+)=' '"
_cQuery	+= " and B1_COD like ('2%') and ZQ_DTPREVE='"+dtos(_dEmbarque)+"' and C5_NUM not in ("+_cPedido+") and B2_LOCAL(+)='18' "
_cQuery	+= " group by ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, "
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS,b1_xbipart, B1_XCODBAS,B1_XLARG,B1_COD, B2_QATU"
//---produtos do embarque que esta sendo montado pelo usuario, sem industrial (B1_COD not like ('2%'))
_cQuery	+= " union all "
_cQuery	+= " select ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, B1_COD, NVL(B2_QATU,0) ESTOQUE, "
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS, sum(C6_QTDVEN) VENDIDO, "
_cQuery	+= " CASE WHEN b1_xbipart = ' ' THEN 'N' ELSE b1_xbipart END BIPARTIDO,         "
_cQuery	+= " case when B1_COD=B1_XCODBAS or B1_XCODBAS=' ' then 'S' else 'N' end PADRAO,         "
_cQuery	+= " case when B1_XLARG<0.78 then 'B' when B1_XLARG<1.28 then 'S' else 'C' end TAMANHO "
_cQuery	+= " from "+RetSqlName('PA6')+" PA6, "+RetSqlName('SZR')+" ZR, "+RetSqlName('PAB')+" PAB, "+RetSqlName('PA5')+" PA5, "+RetSqlName('SB1')+" B1, "+RetSqlName('SC6')+" C6, "+RetSqlName('SC5')+" C5 , "+RetSqlName('SB2')+" B2 "
_cQuery	+= " where PA6_GRPPRO=ZR_CODIGO and PAB_PROCES=ZR_CODIGO and PA5_CODIGO=PAB_DEPART and B2_COD(+)=B1_COD "
_cQuery	+= " and B1_GRUPO=PA6_LINHA and C6_PRODUTO=B1_COD and C5_NUM=C6_NUM "
_cQuery	+= " and PA6_FILIAL='"+xFilial('PA6')+"' and ZR_FILIAL='"+xFilial('SZR')+"' and PAB_FILIAL='"+xFilial('PAB')+"' and PA5_FILIAL='"+xFilial('PA5')+"' "
_cQuery	+= " and B1_FILIAL='"+xFilial('SB1')+"' and C6_FILIAL='"+xFilial('SC6')+"' and C5_FILIAL='"+xFilial('SC5')+"' and B2_FILIAL(+)='"+xFilial('SB2')+"' "
_cQuery	+= " and ZR.D_E_L_E_T_=' ' and PA6.D_E_L_E_T_=' ' and PAB.D_E_L_E_T_=' ' and PA5.D_E_L_E_T_=' ' "
_cQuery	+= " and B1.D_E_L_E_T_=' ' and C6.D_E_L_E_T_=' ' and C5.D_E_L_E_T_=' ' and B2.D_E_L_E_T_(+)=' ' and C5_XOPER not in ('04','20','21','96','99','98')"
_cQuery	+= " and B1_COD not like ('2%') and AND B1_XMODELO NOT IN ('000015','000028') and C5_NUM in ("+_cPedido+") and B2_LOCAL(+)='18' "
_cQuery	+= " group by ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, "
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS,b1_xbipart, B1_XCODBAS,B1_XLARG,B1_COD, B2_QATU "
//---produtos do embarque que esta sendo montado pelo usuario, so industrial (B1_COD like ('2%'))
_cQuery	+= " union all "
_cQuery	+= " select ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, B1_COD, NVL(B2_QATU,0) ESTOQUE , "
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS, sum(C6_QTDVEN) VENDIDO, "
_cQuery	+= " CASE WHEN b1_xbipart = ' ' THEN 'N' ELSE b1_xbipart END BIPARTIDO,         "
_cQuery	+= " case when B1_COD=B1_XCODBAS or B1_XCODBAS=' ' then 'S' else 'N' end PADRAO,         "
_cQuery	+= " case when B1_XLARG<0.78 then 'B' when B1_XLARG<1.28 then 'S' else 'C' end TAMANHO "
_cQuery	+= " from "+RetSqlName('PA6')+" PA6, "+RetSqlName('SZR')+" ZR, "+RetSqlName('PAB')+" PAB, "+RetSqlName('PA5')+" PA5, "+RetSqlName('SB1')+" B1, "+RetSqlName('SC6')+" C6, "+RetSqlName('SC5')+" C5 , "+RetSqlName('SB2')+" B2 "
_cQuery	+= " where PA6_GRPPRO=ZR_CODIGO and PAB_PROCES=ZR_CODIGO and PA5_CODIGO=PAB_DEPART and B2_COD(+)=B1_COD "
_cQuery	+= " and 'A'||substr(('0000'||to_char(B1_XALT*1000)),length('0000'||to_char(B1_XALT*1000))-2,4)=PA6_LINHA "
_cQuery	+= " and C6_PRODUTO=B1_COD and C5_NUM=C6_NUM "
_cQuery	+= " and PA6_FILIAL='"+xFilial('PA6')+"' and ZR_FILIAL='"+xFilial('SZR')+"' and PAB_FILIAL='"+xFilial('PAB')+"' and PA5_FILIAL='"+xFilial('PA5')+"' "
_cQuery	+= " and B1_FILIAL='"+xFilial('SB1')+"' and C6_FILIAL='"+xFilial('SC6')+"' and C5_FILIAL='"+xFilial('SC5')+"' and B2_FILIAL(+)='"+xFilial('SB2')+"' "
_cQuery	+= " and ZR.D_E_L_E_T_=' ' and PA6.D_E_L_E_T_=' ' and PAB.D_E_L_E_T_=' ' and PA5.D_E_L_E_T_=' ' "
_cQuery	+= " and B1.D_E_L_E_T_=' ' and C6.D_E_L_E_T_=' ' and C5.D_E_L_E_T_=' ' and B2.D_E_L_E_T_(+)=' '"
_cQuery	+= " and B1_COD like ('2%') and C5_NUM in ("+_cPedido+") and B2_LOCAL(+)='18' and C5_XOPER not in ('04','20','21','96','99','98') "
_cQuery	+= " group by ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, B2_QATU,"
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS,b1_xbipart, B1_XCODBAS,B1_XLARG,B1_COD )x "
_cQuery	+= " group by ZR_CODIGO, ZR_DESC, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, PA5_CODIGO, PA5_DESCR, "
_cQuery	+= " PA5_QTREC, PA5_PTOS, BIPARTIDO, PADRAO, TAMANHO, B1_COD, ESTOQUE "
_cQuery	+= " union all "
_cQuery	+= "  select ZR_CODIGO, ZR_DESC, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, PA5_CODIGO, PA5_DESCR,  "
_cQuery	+= "  PA5_QTREC, PA5_PTOS, sum(Vendido) Vendido, BIPARTIDO, PADRAO, TAMANHO, B1_COD, 0 ESTOQUE , 0 OP "
_cQuery	+= " from ( "
//---OP para estoque, sem industrial
_cQuery	+= " select ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, B1_COD, "
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS, sum(C2_QUANT-C2_QUJE) VENDIDO, "
_cQuery	+= " CASE WHEN b1_xbipart = ' ' THEN 'N' ELSE b1_xbipart END BIPARTIDO,         "
_cQuery	+= " case when B1_COD=B1_XCODBAS or B1_XCODBAS = ' ' then 'S' else 'N' end PADRAO,         "
_cQuery	+= " case when B1_XLARG<0.78 then 'B' when B1_XLARG<1.28 then 'S' else 'C' end TAMANHO "
_cQuery	+= " from "+RetSqlName('PA6')+" PA6, "+RetSqlName('SZR')+" ZR, "+RetSqlName('PAB')+" PAB, "+RetSqlName('PA5')+" PA5, "+RetSqlName('SB1')+" B1, "+RetSqlName('SC2')+" C2 "
_cQuery	+= " where PA6_GRPPRO=ZR_CODIGO and PAB_PROCES=ZR_CODIGO and PA5_CODIGO=PAB_DEPART "
_cQuery	+= " and B1_GRUPO=PA6_LINHA and C2_PRODUTO=B1_COD "
_cQuery	+= " and PA6_FILIAL='"+xFilial('PA6')+"' and ZR_FILIAL='"+xFilial('SZR')+"' and PAB_FILIAL='"+xFilial('PAB')+"' and PA5_FILIAL='"+xFilial('PA5')+"' "
_cQuery	+= " and B1_FILIAL='"+xFilial('SB1')+"' and C2_FILIAL='"+xFilial('SC2')+"' "
_cQuery	+= " and ZR.D_E_L_E_T_=' ' and PA6.D_E_L_E_T_=' ' and PAB.D_E_L_E_T_=' ' and PA5.D_E_L_E_T_=' ' "
_cQuery	+= " and B1.D_E_L_E_T_=' ' and C2.D_E_L_E_T_=' ' and C2_DATPRI='"+dtos(_dEmbarque)+"' "
_cQuery	+= " and B1_COD not like ('2%') and AND B1_XMODELO NOT IN ('000015','000028') and C2_PEDIDO <> 'PEDVEN' "
_cQuery	+= " group by ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, "
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS,b1_xbipart, B1_XCODBAS,B1_XLARG,B1_COD "
//---OP para estoque, so industrial
_cQuery	+= " union all "
_cQuery	+= " select ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, B1_COD, "
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS, sum(C2_QUANT-C2_QUJE) VENDIDO, "
_cQuery	+= " CASE WHEN b1_xbipart = ' ' THEN 'N' ELSE b1_xbipart END BIPARTIDO,         "
_cQuery	+= " case when B1_COD=B1_XCODBAS or B1_XCODBAS=' ' then 'S' else 'N' end PADRAO,         "
_cQuery	+= " case when B1_XLARG<0.78 then 'B' when B1_XLARG<1.28 then 'S' else 'C' end TAMANHO "
_cQuery	+= " from "+RetSqlName('PA6')+" PA6, "+RetSqlName('SZR')+" ZR, "+RetSqlName('PAB')+" PAB, "+RetSqlName('PA5')+" PA5, "+RetSqlName('SB1')+" B1, "+RetSqlName('SC2')+" C2 "
_cQuery	+= " where PA6_GRPPRO=ZR_CODIGO and PAB_PROCES=ZR_CODIGO and PA5_CODIGO=PAB_DEPART "
_cQuery	+= " and 'A'||substr(('0000'||to_char(B1_XALT*1000)),length('0000'||to_char(B1_XALT*1000))-2,4)=PA6_LINHA "
_cQuery	+= " and C2_PRODUTO=B1_COD and PA6_FILIAL='"+xFilial('PA6')+"' and ZR_FILIAL='"+xFilial('SZR')+"' and PAB_FILIAL='"+xFilial('PAB')+"' "
_cQuery	+= " and PA5_FILIAL='"+xFilial('PA5')+"' and B1_FILIAL='"+xFilial('SB1')+"' and C2_FILIAL='"+xFilial('SC2')+"' "
_cQuery	+= " and ZR.D_E_L_E_T_=' ' and PA6.D_E_L_E_T_=' ' and PAB.D_E_L_E_T_=' ' and PA5.D_E_L_E_T_=' ' "
_cQuery	+= " and B1.D_E_L_E_T_=' ' and C2.D_E_L_E_T_=' ' and C2_DATPRI='"+dtos(_dEmbarque)+"' "
_cQuery	+= " and B1_COD like ('2%') and C2_PEDIDO <> 'PEDVEN' "
_cQuery	+= " group by ZR_CODIGO, ZR_DESC, PA6_LINHA, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, "
_cQuery	+= " PA5_CODIGO, PA5_DESCR, PA5_QTREC, PA5_PTOS,b1_xbipart, B1_XCODBAS,B1_XLARG,B1_COD)"
_cQuery	+= " Group By ZR_CODIGO, ZR_DESC, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, PA5_CODIGO, PA5_DESCR, B1_COD, "
_cQuery	+= " PA5_QTREC, PA5_PTOS, BIPARTIDO, PADRAO, TAMANHO )"
_cQuery	+= "  where VENDIDO-OP-ESTOQUE>0 " //caso menor ou igual a zero nao sera produzido
_cQuery	+= " group by ZR_CODIGO, ZR_DESC, PAB_PTOBER, PAB_PTOSOL, PAB_PTOCAS, PA5_CODIGO, PA5_DESCR,  "
_cQuery	+= " PA5_QTREC, PA5_PTOS, BIPARTIDO, PADRAO, TAMANHO "+_cOrdem

MemoWrit('c:\Tree.Sql',_cQuery)

TcQuery _cQuery New Alias 'QRY1'
DbGoTop()

aEtrut:={{'ZR_CODIGO','C',6,0},{'ZR_DESC','C',30,0},{'PAB_PTOBER','N',18,3},{'PAB_PTOSOL','N',18,3},{'PAB_PTOCAS','N',18,3},;
{'PA5_CODIGO','C',3,0},{'PA5_DESCR','C',30,0},{'RECURSO','N',18,0},{'PONTO','N',18,3},{'PRODUZIR','N',18,3},;
{'BIPART','C',1,0},{'PADRAO','C',1,0},{'TAMANHO','C',1,0}}
_cArqTrb := CriaTrab(aEtrut,.T.)
Copy To &_cArqTrb

DbSelectArea('QRY1')
DbCloseArea()

dbUseArea(.T.,,_cArqTrb,"TMP1",.T.)
DbSelectArea('TMP1')


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Totaliza os pontos por departamento≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
_cQuery2:=" select PA5_CODIGO, PA5_PTOS*PA5_QTREC PTOMAX, "
_cQuery2+=" sum (PRODUZIR*(case when TAMANHO = 'S' and PADRAO='S' then PAB_PTOSOL "
_cQuery2+="      when TAMANHO = 'S' and PADRAO='N' then PAB_PTOSOL*"+str(_nFatorSM)
_cQuery2+="      when TAMANHO = 'B' and PADRAO='S' then PAB_PTOBER "
_cQuery2+="      when TAMANHO = 'B' and PADRAO='N' then PAB_PTOBER*"+str(_nFatorSM)
_cQuery2+="      when TAMANHO = 'C' and PADRAO='S' and BIPARTIDO='S' then 2*PAB_PTOSOL "
_cQuery2+="      when TAMANHO = 'C' and PADRAO='S' and BIPARTIDO='N' then PAB_PTOCAS "
_cQuery2+="      when TAMANHO = 'C' and PADRAO='N' and BIPARTIDO='S' then 2*PAB_PTOSOL*"+str(_nFatorSM)
_cQuery2+="      when TAMANHO = 'C' and PADRAO='N' and BIPARTIDO='N' then PAB_PTOCAS*"+str(_nFatorSM)+"  end)) PTOPROD "
_cQuery2+=" from ("+_cQuery
_cQuery2+=" ) group by PA5_CODIGO, PA5_PTOS,PA5_QTREC "
_cQuery2+=" order by PA5_CODIGO "

memowrit('c:\tree2.sql',_cQuery2)

TcQuery _cQuery2 New Alias 'TMP2'
DbGoTop()

//_cArqTrb2 := CriaTrab(NIL,.F.)
//Copy To &_cArqTrb2

//DbSelectArea('QRY1')
//DbCloseArea()

//dbUseArea(.T.,,_cArqTrb2,"TMP2",.T.)
DbSelectArea('TMP2')

Return _cArqTrb


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fConsTre  ∫Autor  ≥Renato Lucena Neves ∫ Data ≥  05/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Consulta um item da arvore. FunÁ„o disparada apÛs duplo    ∫±±
±±∫          ≥ clique em um item da arvore.                               ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function fConsTree()

Local _aArea	:= GetArea()
Local _cChave	:= _oTree:GetCargo()
Local _cQuery	:= ""
Local _cProcesso:= ""
Local _cPedido	:= ""
Local _cDpto	:= ""
Local _nI       :=0

Private _oDlgPont
Private _oPonto
Private _cPonto
Private _aList  := {}

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Monta string com os pedidos da carga q est· sendo montada≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
For _nI:=1 to Len(_aPedido)
	_cPedido+="'"+_aPedido[_nI]+"',"
Next _nI

if len(_aPedido)>1
	_cPedido:=left(_cPedido,len(_cPedido)-1)
else
	_cPedido := "' '"
endif
_cPedido:=StrTran(_cPedido,"''","' '") //caso n„o tenha um espaÁo entre as aspas a query È zerada

//data do embarque da carga q esta sendo montada
_dEmbarque:=MV_PAR05

//tipo da carga que esta sendo montada
_cTpCarga:='1'

DbSelectArea('TMP1')
IndRegua("TMP1",CriaTrab(Nil,.F.), "PA5_CODIGO+ZR_CODIGO",,,)
TMP1->(DbGoTop())
TMP1->(DbSeek(_cChave))

//cProduto2 := substr(_cChave,4,10)
_cDpto	  := left(_cChave,3)

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Monta string com todos os produtos a serem filtrados na query≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
While TMP1->(!EOF()) .AND. alltrim(_cDpto) = alltrim(TMP1->PA5_CODIGO)
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Caso foi clicado sobre o produto filtra apenas os pedidos que possuea o produto≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	//	If !Empty(cProduto2) .and. alltrim(cProduto2) <> alltrim(TMP1->PRODUTO)
	//		Exit
	//	endif
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒDø
	//≥Existem OPs em aberto e saldo em estoque para suprir a produÁ„o  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒDŸ
	//	If TMP1->(OP+B2_QATU) >= TMP1->VENDIDO
	//		TMP1->(DbSkip())
	//		Loop
	//	endif
	
	_cProcesso+="'"+TMP1->ZR_CODIGO+"',"
	TMP1->(DBSKIP())
enddo

If len(_cProcesso)>2
	
	_cProcesso:=left(_cProcesso,len(_cProcesso)-1) //tira a ultima virgula
	
	_cQuery := " select ZQ_EMBARQ,C5_NUM,ZR_DESC,C6_PRODUTO,B1_DESC, PA6_LINHA,C6_QTDVEN "
	_cQuery += " from "+RetSQLName('PA6')+" PA6,"+RetSQLName('SB1')+" B1,"+RetSQLName('SC6')+" C6,"+RetSQLName('SC5')+" C5,"+RetSQLName('SZQ')+" ZQ, "+RetSQLName('SZR')+" ZR "
	_cQuery += " where B1_GRUPO=PA6_LINHA and C6_PRODUTO=B1_COD and C5_NUM=C6_NUM and ZQ_EMBARQ=C5_XEMBARQ "
	_cQuery += " and ZR_CODIGO=PA6_GRPPRO "
	_cQuery += " and PA6_FILIAL='"+xFilial('PA6')+"' and PA6.D_E_L_E_T_=' ' and PA6_LINHA not like 'A%' "
	_cQuery += " and B1_FILIAL='"+xFilial('SB1')+"' and B1.D_E_L_E_T_=' ' and AND B1_XMODELO NOT IN ('000015','000028') "
	_cQuery += " and C6_FILIAL='"+xFilial('SC6')+"' and C6.D_E_L_E_T_=' ' "
	_cQuery += " and C5_FILIAL='"+xFilial('SC2')+"' and C5.D_E_L_E_T_=' ' and C5_XOPER not in ('04','20','21','96','99','98')"
	_cQuery += " and ZQ_FILIAL='"+xFilial('SZQ')+"' and ZQ.D_E_L_E_T_=' ' and ZQ_DTPREVE='"+dtos(_dEmbarque)+"' "
	_cQuery += " and ZR_FILIAL='"+xFilial('SZR')+"' and ZR.D_E_L_E_T_=' ' and ZR_CODIGO in ("+_cProcesso+") "
	_cQuery += " union all "
	_cQuery += " select ZQ_EMBARQ,C5_NUM,ZR_DESC,C6_PRODUTO,B1_DESC, PA6_LINHA,C6_QTDVEN "
	_cQuery += " from "+RetSQLName('PA6')+" PA6,"+RetSQLName('SB1')+" B1,"+RetSQLName('SC6')+" C6,"+RetSQLName('SC5')+" C5,"+RetSQLName('SZQ')+" ZQ, "+RetSQLName('SZR')+" ZR "
	_cQuery += " where 'A'||substr(('0000'||to_char(B1_XALT*1000)),length('0000'||to_char(B1_XALT*1000))-2,4)=PA6_LINHA "
	_cQuery += " and C6_PRODUTO=B1_COD and C5_NUM=C6_NUM  and ZQ_EMBARQ=C5_XEMBARQ and ZR_CODIGO=PA6_GRPPRO "
	_cQuery += " and PA6_FILIAL='"+xFilial('PA6')+"' and PA6.D_E_L_E_T_=' ' and PA6_LINHA like 'A%' "
	_cQuery += " and B1_FILIAL='"+xFilial('SB1')+"' and B1.D_E_L_E_T_=' ' and AND B1_XMODELO NOT IN ('000015','000028') "
	_cQuery += " and C6_FILIAL='"+xFilial('SC6')+"' and C6.D_E_L_E_T_=' ' "
	_cQuery += " and C5_FILIAL='"+xFilial('SC2')+"' and C5.D_E_L_E_T_=' ' and C5_XOPER not in ('04','20','21','96','99','98')"
	_cQuery += " and ZQ_FILIAL='"+xFilial('SZQ')+"' and ZQ.D_E_L_E_T_=' ' and ZQ_DTPREVE='"+dtos(_dEmbarque)+"' "
	_cQuery += " and ZR_FILIAL='"+xFilial('SZR')+"' and ZR.D_E_L_E_T_=' ' and ZR_CODIGO in ("+_cProcesso+") "
	_cQuery += " order by ZQ_EMBARQ, C5_NUM, ZR_DESC, C6_PRODUTO "
	
	
	MemoWrit('c:\TreeCons.sql',_cQuery)
	TcQuery _cQuery New Alias 'QRY1'
	DbSelectArea('QRY1')
	DbGoTop()
	While QRY1->(!EOF())
		
		aAdd(_aList,{QRY1->ZQ_EMBARQ,QRY1->C5_NUM, QRY1->ZR_DESC, QRY1->C6_PRODUTO, QRY1->B1_DESC,QRY1->C6_QTDVEN})
		
		QRY1->(DbSkip())
	enddo
	
	//	aSort(_aList,,,{|x,y| x[3]+x[1]+x[2]+x[4]>y[3]+y[1]+y[2]+y[4] })
	
	Define MSDialog _oDlgPont Title "Detalhes da PontuaÁ„o "+alltrim(aItensTree[_nI][2]) From 000,000 To 490,840 of oMainwnd Pixel
	
	@ 005,010 ListBox _oPonto Var _cPonto Fields HEADER "Carga","Pedido","Processo","Produto","Descricao", "Quantidade" FIELDSIZES 025,025,90,040,120,025 Size 400,220 OF _oDlgPont pixel ON dblClick(Mensagem3())
	
	@ 230,350 BmpButton Type 2 Action _oDlgPont:End()
	
	_oPonto:SetArray(_aList)
	_oPonto:nAt:=1
	_oPonto:bLine:={|| {_aList[_oPonto:nAt, 1],_aList[_oPonto:nAt, 2],_aList[_oPonto:nAt, 3],_aList[_oPonto:nAt, 4],;
	_aList[_oPonto:nAt, 5], Transform(_aList[_oPonto:nAt, 6],"@E 999,999.999")}}
	_oPonto:Refresh()
	Activate Dialog _oDlgPont //centered
	
	DbSelectArea('QRY1')
	DbCloseArea()
endif

RestArea(_aArea)
Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fRodaPe   ∫Autor  ≥Renato Lucena Neves ∫ Data ≥  04/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Atualiza os dados do rodape da tela da Tree                ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function fRodaPe()

Local _nPos		:= 0
Local _cChave	:= ""
Local _nRecurso	:= 0
Local _nMaxPto	:= 0
Local _nTotPto	:= 0
Local _nDifPto	:= 0

_cChave	:= left(_oTree:GetCargo(),3)
_nPos:=aScan(aItensTree, {|x| alltrim(left(x[1],3))==alltrim(_cChave) } )
//_cChave+_cChaveF,PA5_DESCR, PRODUTO, MAXPTO, RECURSO, PONTO, VENDIDO})

_nRecurso	:= aItensTree[_nPos][5]
_nMaxPto	:= aItensTree[_nPos][4]
_nTotPto	:= aItensTree[_nPos][6]
_nDifPto	:= _nMaxPto-_nTotPto

_cSetor		:= aItensTree[_nPos][2]
_cRecurso	:= Transform(_nRecurso,"@E 999,999")
_cMaxPto	:= Transform(_nMaxPto,"@E 9,999,999.999")
_cTotPto	:= Transform(_nTotPto,"@E 9,999,999.999")
_cDifPto	:= Transform(_nDifPto,"@E 9,999,999.999")

_oSetor:Refresh()
_oRecurso:Refresh()
_oMaxPto:Refresh()
_oTotPto:Refresh()
_oDifPto:Refresh()

Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fVerPedido∫Autor  ≥Renato Lucena Neves ∫ Data ≥  09/07/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Sigaauto para vizualisaÁ„o do pedido de venda. Rotina executada
±±∫          ≥ apÛs duplo click no list box de pedidos de venda           ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function fVerPedido()

Local _aArea:=GetArea()
Local _cPedido:= _aList[_oPonto:nAt][2]
Local _aCabPV := {}
Local _aItemPV:= {}

DbSelectArea("SC5")
dbOrderNickName("PSC51")
DbSeek(xFilial('SC5')+_cPedido)

_aCabPV:={{"C5_NUM"    ,_cPedido   ,Nil},; // Numero do pedido
{"C5_CLIENTE",SC5->C5_CLIENTE    ,Nil},; // Codigo do cliente
{"C5_LOJAENT",SC5->C5_LOJAENT    ,Nil},; // Loja para entrada
{"C5_LOJACLI",SC5->C5_LOJACLI    ,Nil},; // Loja do cliente
{"C5_EMISSAO",SC5->C5_EMISSAO    ,Nil},; // Data de emissao
{"C5_TIPO"   ,SC5->C5_TIPO       ,Nil}} // Tipo de pedido

DbSelectArea("SC6")
dbOrderNickName("PSC61")
DbSeek(xFilial('SC6')+_cPedido)

While xFilial('SC6')==SC6->C6_FILIAL .and. SC5->C5_NUM==_cPedido .and. SC6->(!EOF())
	
	aAdd(_aItemPV,{{"C6_NUM"   ,_cPedido         ,Nil},; // Numero do Pedido
	{"C6_ITEM"   ,SC6->C6_ITEM      ,Nil},; // Numero do Item no Pedido
	{"C6_PRODUTO",SC6->C6_PRODUTO   ,Nil},; // Codigo do Produto
	{"C6_UM"     ,SC6->C6_UM        ,Nil},; // Unidade de Medida Primar.
	{"C6_CLI"    ,SC6->C6_CLI       ,Nil},; // Cliente
	{"C6_LOJA"   ,SC6->C6_LOJA      ,Nil}})  // Loja do Cliente
	
	SC6->(DbSkip())
Enddo

lMsErroAuto:=.F.

MSExecAuto({|x,y,z|Mata410(x,y,z)},_aCabPv,_aItemPV,2)//visualiza

If lMsErroAuto
	DisarmTransaction()
	break
EndIf

RestArea(_aArea)
Return


Static Function fValidComp()
_aAreaVC	:=	GetArea()
If !Empty(cEmbComp)
	If cCombo = "Complementar"
		DbSelectArea("SZQ")
		dbOrderNickName("CSZQ1")
		DbSeek(xFilial("SZQ")+cEmbComp)
		
		If	!Found()
			Alert("Carga n„o encontrada!")
			
			Return(.F.)
		Else
			If	SZQ->ZQ_EMBCOMP	<>	" "
				Alert("A carga selecionada com principal j· È uma carga complementar!!")
				RestArea(_aAreaVC)
				Return(.F.)
			Endif
			
			//Verificar se a carga principal j· foi associada a outra carga complementar
			_cQuery	:=	"SELECT COUNT(ZQ_EMBCOMP) COUNT FROM "+RetSqlName("SZQ")+" WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' AND D_E_L_E_T_ = ' ' AND ZQ_EMBCOMP = '"+cEmbComp+"' "
			
			TCQUERY _cQuery ALIAS "TRBVC" NEW
			Dbselectarea("TRBVC")
			
			If	TRBVC->COUNT	>	0
				Alert("J· existe carga complementar associada a essa carga Principal!!")
				RestArea(_aAreaVC)
				DbSelectArea("TRBVC")
				DbCloseArea()
				Return(.F.)
			Endif
			
			DbSelectArea("TRBVC")
			DbCloseArea()
			
			RestArea(_aAreaVC)
			Return(.T.)
		Endif
		
	Else
		Alert("Tipo de Carga n„o È 'Complementar'!")
		Return(.F.)
	Endif
Else
	Return(.T.)
Endif


Static Function fPedRet(_cPedRet)
Local	_aTemp	:=	{}
Local i:=0
nPos:=ascan(_aPedRet,{|x| x[1]==_cPedRet})


If nPos	>	0
	_aTemp	:=	_aPedRet
	for i:=1 to Len(_aPedRet)
		If _aPedRet[i,1]<>_cPedRet
			AADD(_aTemp,{_aPedRet[i,1]})
		End if
		i++
	Next
	_aPedRet	:=	_aTemp
Endif

Return

Static Function	fRetLib(_cRetLib)

Local	_cQryLib	:=	""


If	!Empty(_cRetLib)
	_cQryLib	:=	"SELECT SC9.R_E_C_N_O_ REC	FROM "+RetSqlName("SC9")+" SC9 WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND SC9.D_E_L_E_T_ = ' ' AND C9_PEDIDO IN ("+_cRetLib+") AND C9_BLCRED <> '10' AND C9_BLEST <> '10' "
	
	MEMOWRIT("C:\RETLIB.SQL",_cQryLib)
	
	TCQUERY _cQryLib ALIAS "RETLIB" NEW
	
	DbSelectArea("RETLIB")
	
	While	!EOF()
		DbSelectArea("SC9")
		DbGoTo(RETLIB->REC)
		
		DbSelectArea("SB2")
		dbOrderNickName("PSB21")
		If !DBSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL)
			criasb2(SC9->C9_PRODUTO,SC9->C9_LOCAL)
		Endif
		
		DbSelectArea("SC9")
		
		
		a460Estorna()
		
		
		DbSelectArea("SB2")
		MsUnlock()
		DbSelectArea("SC9")
		MsUnlock()
		DbSelectArea("SC6")
		MsUnlock()
		
		
		
		DbSelectArea("RETLIB")
		DbSkip()
	Enddo
	
	DbSelectArea("RETLIB")
	DbCloseArea()
Endif
Return()



*****************************************
Static Function fValidaPed(__cPed,_nTpCg)
*****************************************
Local	_aArea		:=	GetArea()
Local	_lRetorno   :=	.T.
Local _cCli99Trb	:= ""
Local _cTpPed	:= "" //SSI 12080
Local _cBlq		:= "" //SSI 12080
Local _cEmail	:= "" //SSI 12080
Local cQuery	:= ""

DbSelectarea("SC5")
dbOrderNickName("PSC51")
DbSeek(xFilial("SC5")+__cPed)


If !Found()
	_lRetorno	:=	.F.
Endif

/*		//RETIRADO POR GERALDO EM 12/03/2019 - SSI 76424
// Valida preÁo de Residuo - Floco - Cascao  // Adriano S Dourado // 04/02/2019
If !fValidPrc(SC5->C5_NUM)
Alert("Este pedido contÈm produtos com preÁo abaixo do mÌnimo, verificar com auditoria.")
_lRetorno	:= .F.
EndIf
*/
// Verifica se o cliente est· bloqueado
//InÌcio SSI 12080
_cTpPed := Alltrim(SC5->C5_TIPO)
If _cTpPed == 'D' .OR. _cTpPed == 'B'
	_cQueryFB	:=	"SELECT A2.A2_MSBLQL, A2_EMAIL FROM "+RetSqlName("SA2")+" A2 WHERE A2_FILIAL = '"+xFilial("SA2")+"' AND A2_COD = '" + SC5->C5_CLIENTE + "' AND D_E_L_E_T_ = ' ' "
	TCQUERY _cQueryFB ALIAS "FORB" NEW
	DbSelectArea("FORB")
	_cBlq	:= '2' //FORB->A2_MSBLQL SSI 12153
	_cEmail := ALLTRIM(FORB->A2_EMAIL)
	FORB->(DbCloseArea())
Else
	//Fim SSI 12080
	_cQueryCB	:=	"SELECT A1.A1_MSBLQL, A1_EMAIL FROM "+RetSqlName("SA1")+" A1 WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = '" + SC5->C5_CLIENTE + "' AND D_E_L_E_T_ = ' ' "
	TCQUERY _cQueryCB ALIAS "CLIB" NEW
	DbSelectArea("CLIB")
	_cBlq	:= CLIB->A1_MSBLQL
	_cEmail := ALLTRIM(CLIB->A1_EMAIL)
	CLIB->(DbCloseArea()) //SSI 12080
EndIf//SSI 12080

cQuery	:= " SELECT SUBSTR(ZE_AUTORIZ, 1, 1) AS BLOQUEIO "
cQuery	+= "   FROM " + RetSqlName("SZE")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND ZE_FILIAL = '"+xFilial("SZE")+"' "
cQuery	+= "    AND ZE_PEDIDO = '"+SC5->C5_NUM+"' "
cQuery	+= "    AND ZE_AUTORIZ IN ('BLQLMA', 'BLQLCA', 'BLQLDO', 'BLQLNP') "
cQuery	+= "    AND ZE_USUARIO = '"+Space(GetSX3Cache("ZE_USUARIO","X3_TAMANHO"))+"' "
If !cEmpAnt$"22"
	
	cQuery	+= " UNION ALL "
	cQuery	+= " SELECT B.TIPO "
	cQuery	+= "   FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1, BLQSISLOJA B "
	cQuery	+= "  WHERE SC5.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SA1.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery	+= "    AND A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery	+= "    AND C5_NUM = '"+SC5->C5_NUM+"' "
	cQuery	+= "    AND A1_COD = C5_CLIENTE "
	cQuery	+= "    AND B.UNIDADE = '"+cEmpAnt+"' "
	cQuery	+= "    AND B.CNPJ = A1_CGC "
	
	If SC5->C5_XTPSEGM $ "3|4" .And. SC5->C5_XOPER == "04"
	   cQuery	+= "    AND (B.TIPO <> 'C' OR B.DATABL <= '"+DToS(DATE() - 5)+"') "
	   cQuery	+= "    AND B.DATALIB = '        ' "
	   cQuery	+= "    AND B.TIPO IN ('D', 'P') "	   
	Else       
	   cQuery	+= "    AND (B.TIPO <> 'C' OR B.DATABL <= '"+DToS(DATE() - 5)+"') "
	   cQuery	+= "    AND B.DATALIB = '        ' "
	   cQuery	+= "    AND B.TIPO IN ('M', 'C', 'D', 'P','F') "
	EndIf
Endif
cQuery	+= " UNION ALL "
cQuery	+= " SELECT 'D' "
cQuery	+= "   FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1 "
cQuery	+= "  WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery	+= "    AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery	+= "    AND C5_NUM = '"+SC5->C5_NUM+"' "
cQuery	+= "    AND A1_COD = C5_CLIENTE "
cQuery	+= "    AND A1_XBLQDOC = '1' "
U_ORTQUERY(cQuery, "ORTP002_BL")
If ORTP002_BL->(!EOF())
	Alert("Este pedido n„o pode ser programado pois constam bloqueios para a loja ("+ORTP002_BL->BLOQUEIO+").")
	_lRetorno	:= .F.
EndIf
ORTP002_BL->(dbCloseArea())

//If CLIB->A1_MSBLQL	==	"1" SSI 12080
If _cBlq	==	"1"
	//Alert("Este pedido n„o pode ser programado. CLIENTE BLOQUEADO") SSI 12080
	Alert("Este pedido n„o pode ser programado. "+IIf(_cTpPed == 'D' .OR. _cTpPed == 'B' , "FORNECEDOR BLOQUEADO", "CLIENTE BLOQUEADO"))
	_lRetorno	:=	.F.
ELSE
	//if !U_FValEmail(CLIB->A1_EMAIL) SSI 12080
	if !U_FValEmail(_cEmail)
		//Alert("Este pedido n„o pode ser programado. CLIENTE SEM EMAIL VALIDO") SSI 12080
		Alert("Este pedido n„o pode ser programado. "+IIf(_cTpPed == 'D' .OR. _cTpPed == 'B', "FORNECEDOR SEM EMAIL VALIDO", "CLIENTE SEM EMAIL VALIDO"))
		_lRetorno	:=.F.
	Endif
Endif
//CLIB->(DbCloseArea()) SSI 12080
// ----------


//Verifica se n„o tem grupo

__cQuery	:=	"SELECT COUNT(*) COUNT FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SC5")+" C5, "+RetSqlName("SB1")+" B1 "
__cQuery	+=	" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+__cPed+"' AND "
__cQuery	+=	"       C5.D_E_L_E_T_ = ' ' AND C6.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND "
__cQuery	+=	"       C5_NUM = C6_NUM AND C6_PRODUTO = B1_COD AND (B1_GRUPO = ' ' OR B1_GRUPO NOT IN (SELECT BM_GRUPO FROM "+RetSqlName("SBM")+" WHERE BM_FILIAL = '"+xFilial("SBM")+"' AND D_E_L_E_T_ = ' ')) "

TCQUERY __cQuery ALIAS "GRP" NEW

DbSelectArea("GRP")

If GRP->COUNT	>	0
	Alert("Verificar o pedido "+__cPed+", existe um produto cadastrado com grupo inexistente. B1_GRUPO / BM_GRUPO ")
	_lRetorno	:=	.F.
Endif

GRP->(DbCloseArea())

__cQuery := " SELECT A1_COD, A1_LOJA, A1_NOME "
__cQuery += "   FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1, SITEFISICO FIS "
__cQuery += "  WHERE SC5.D_E_L_E_T_ = ' ' "
__cQuery += "    AND SA1.D_E_L_E_T_ = ' ' "
__cQuery += "    AND C5_FILIAL = '"+xFilial("SC5")+"' "
__cQuery += "    AND A1_FILIAL = '"+xFilial("SA1")+"' "
__cQuery += "    AND A1_COD = C5_CLIENTE "
__cQuery += "    AND A1_LOJA = C5_LOJACLI "
__cQuery += "    AND A1_GRPTRIB = '999' "
__cQuery += "    AND FIS.UN = '"+cEmpAnt+"' "
__cQuery += "    AND FIS.FILIAL = '"+cFilAnt+"' "
__cQuery += "    AND FIS.PEDIDO = SC5.C5_XTALSAC "
__cQuery += "    AND SC5.C5_NUM = '"+SC5->C5_NUM+"' "
__cQuery += "  GROUP BY A1_COD, A1_LOJA, A1_NOME "
__cQuery += "  ORDER BY 1, 2 "

MEMOWRIT("C:\ORTP002_GRT99.SQL",__cQuery)

IF SELECT("A1GRTR99") > 0
	DbSelectArea("A1GRTR99")
	DBCLOSEAREA()
ENDIF

TCQUERY __cQuery ALIAS "A1GRTR99" NEW

_cCli99Trb	:= ""
While !EOF()
	_cCli99Trb += "'" + AllTrim(A1GRTR99->A1_COD) + "-"
	_cCli99Trb += AllTrim(A1GRTR99->A1_LOJA) + " "
	_cCli99Trb += AllTrim(A1GRTR99->A1_NOME) + "'"
	dbSkip()
EndDo

DBCLOSEAREA()
dbSelectArea("SC6")

If !Empty(_cCli99Trb)
	Alert("Este pedido È de site, e est· amarrado a um cliente com grupo tribut·rio 999: "+_cCli99Trb+". Verifique!")
	_lRetorno	:=	.F.
EndIf

// NAO DEIXA PROGRAMAR SE HOUVER DEVOLUCAO NO PAGAMENTO VIA MERCADOPAGO
// FABIO COSTA - 22/05/2020
If U_ORTP002D(SC5->C5_NUM) 
	_lRetorno	:=	.F.         
Endif
////////

If	_nTpCg	=	2
	__cQuery	:=	"SELECT COUNT(*) COUNT FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SC5")+" C5, "+RetSqlName("SB1")+" B1 "
	__cQuery	+=	" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+__cPed+"' AND "
	__cQuery	+=	"       C5.D_E_L_E_T_ = ' ' AND C6.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' AND "
	__cQuery	+=	"       C5_NUM = C6_NUM AND C6_PRODUTO = B1_COD AND B1_XMODELO IN ('000015','000028') "
	//	__cQuery	+=	"       C5_NUM = C6_NUM AND C5_XTPSEGM IN ('2','6') AND C6_PRODUTO = B1_COD AND B1_XMODELO = '000015' "
	//	Alterado por Dupim em 27/08/10
	
	IF SELECT("TER") > 0
		DbSelectArea("TER")
		DBCLOSEAREA()
	ENDIF
	
	//	TCQUERY __cQuery ALIAS "TER" NEW
	
	//	DbSelectArea("TER")
	
	TCQUERY __cQuery ALIAS "TER" NEW
	
	DbSelectArea("TER")
	
	If TER->COUNT	>	0
		if cfilemp <> "15"
			Alert("Este pedido n„o pode ser programado nesta modalidade. TERCEIRIZADO / COMERCIAL ")
			_lRetorno	:=	.F.
		endif
	Endif
	
	TER->(DbCloseArea())
Endif

__cQuery	:=	"SELECT COUNT(*) COUNT FROM "+RetSqlName("SC6")+" C6 WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+__cPed+"' AND (C6_PRCVEN = 0 OR C6_VALOR = 0) AND C6_BLQ <> 'R' AND D_E_L_E_T_ = ' ' "

TCQUERY __cQuery ALIAS "PRC0" NEW

DbSelectArea("PRC0")

If PRC0->COUNT	>	0
	Alert("Este pedido n„o pode ser programado. ITENS COM PRE«O ZERADO")
	_lRetorno	:=	.F.
Endif

PRC0->(DbCloseArea())

/* SSI 124340 - A pedido do Dupim.
IF GETNEWPAR("MV_XCUSTER","SIM") == "SIM"
	
	__cQuery	:=	"SELECT B1_COD FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SC5")+" C5, "+RetSqlName("SB1")+" B1 "
	__cQuery    +=	"WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5.D_E_L_E_T_ = ' ' AND C6_NUM = C5_NUM "
	__cQuery	+=	"AND C6_FILIAL = '"+xFilial("SC6")+"' AND B1_FILIAL = '"+xFilial("SB1")+"' AND C6_PRODUTO = B1_COD "
	__cQuery	+=	"AND C6_NUM = '"+__cPed+"' AND B1_XCUSTER = 0 AND B1.D_E_L_E_T_ = ' ' AND C6.D_E_L_E_T_ = ' ' AND B1_XMODELO IN ('000015','000028')  "
	__cQuery	+=	"AND C5_XTPSEGM = '3' "
	
	TCQUERY __cQuery ALIAS "PRC0" NEW
	
	DbSelectArea("PRC0")
	
	If !EOF()
		Alert("Este pedido n„o pode ser programado. Produto "+PRC0->B1_COD+" com valor de custo zerado")
		_lRetorno	:=	.F.
	Endif
	
	PRC0->(DbCloseArea())
	
ENDIF
*/
cQuery:="SELECT C6_PRODUTO, C2_NUM, C2_ITEM, C2_SEQUEN "
cQuery+="  FROM "+RetSQLName("SC2")+" SC2, "+RetSQLName("SC6")+" SC6 "
cQuery+=" WHERE SC2.D_E_L_E_T_ = ' ' "
cQuery+="   AND SC6.D_E_L_E_T_ = ' ' "
cQuery+="   AND SC2.C2_FILIAL = '"+xFilial("SC2")+"' "
cQuery+="   AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery+="   AND C2_PEDIDO = C6_NUM   "
cQuery+="   AND C2_ITEMPV = C6_ITEM  "
cQuery+="   AND C2_QUJE > 0          "
cQuery+="   AND C6_NUM = '"+__cPed + "' "

TCQUERY cQuery ALIAS "QRYSC2" NEW

cMesg:=""

dbselectarea("QRYSC2")
dbgotop()
do While !eof()
	cMesg+="Produto: "+QRYSC2->C6_PRODUTO+" OP: "+C2_NUM+C2_ITEM+C2_SEQUEN+CHR(13)+CHR(10)
	dbskip()
enddo
dbclosearea()


if !empty(cMesg)
	cMesg:="Os seguintes produtos possuem OP's apontadas: "+CHR(13)+CHR(10)+cMesg
	MsgBox(cMesg)
	_lRetorno	:=	.F.
Endif

//Verifica se n„o tem FCI

/*__cQuery	:=	"SELECT COUNT(*) COUNT FROM "+RetSqlName("SC6")+" C6, "+RetSqlName("SB1")+" B1 "
__cQuery	+=	" WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+__cPed+"' "
__cQuery	+=	"       AND C6.D_E_L_E_T_ = ' ' AND B1.D_E_L_E_T_ = ' ' AND B1_FILIAL = '"+xFilial("SB1")+"' "
__cQuery	+=	"       AND C6_PRODUTO = B1_COD AND  B1_XNUMFCI = ' ' AND B1_ORIGEM  = '5'   "

TCQUERY __cQuery ALIAS "FCI" NEW

DbSelectArea("FCI")

If FCI->COUNT	>	0
Alert("O Pedido:  "+__cPed+" possui Produto com CST que exige o cÛdigo de FCI "+__cPed+". Verifique o cadastro do Produto ou execute a rotina de GeraÁao da FCI.")
_lRetorno	:=	.F.
Endif

FCI->(DbCloseArea())*/
/*
if !cEmpAnt$"21|22|23|24" .and. (MV_PAR05>CtoD("16/02/2018") .or. (!cEmpAnt$"03|04|06|25" .and.  MV_PAR05>CtoD("31/01/2018"))) //.and.  FLibP52(cRem)
	MsgBox("Pedido Possui Produtos nao autorizados para producao")
	_lRetorno:=.F.
ENDIF
*/

cQuery:="SELECT C6_PRODUTO, B1_DESC "
cQuery+="  FROM "+RetSQLName("SB1")+" SB1, "+RetSQLName("SC6")+" SC6 "
cQuery+=" WHERE SB1.D_E_L_E_T_ = ' ' "
cQuery+="   AND SC6.D_E_L_E_T_ = ' ' "
cQuery+="   AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery+="   AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery+="   AND B1_COD = C6_PRODUTO   "
cQuery+="   AND B1_XMODELO IN ('000013','000020','000021') "
cQuery+="   AND B1_XCODBAS<> ' ' "
cQuery+="   AND C6_NUM = '"+__cPed + "' "

TCQUERY cQuery ALIAS "QRYFLO" NEW

IF !(QRYFLO->(EOF())) .AND. !EMPTY(QRYFLO->C6_PRODUTO)
	MsgBox("Pedido Possui Produtos nao autorizados para producao: "+QRYFLO->C6_PRODUTO+" - "+QRYFLO->B1_DESC)
	_lRetorno:=.F.
Endif
QRYFLO->(DbCloseArea())

RestArea(_aArea)
Return(_lRetorno)

//////////////////////////////////////////
//  Adriano Dourado   //    01/02/2019 	//
Static Function fConfOK()

Local	_lRet		:=	.T.

_lRet	:=	ConfEmb()

IF _lRet
	oDlgCarga:End()
Endif

//Abre novamente a tela de par‚mtros caso seja uma confirmaÁ„o de embarque proveniente de INCLUS√O e n„o houver erro algum na confirmaÁ„o
If	lIncEmb	.And.	_lRet
	aTabPAP := {}
	U_INCEMB()
Endif

Return(_lRet)


Static Function fPedMist(__cTipo,__CpED)

_cQ	:=	"SELECT COUNT(*) COUNT FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM IN ("+__cPed+") AND D_E_L_E_T_ = ' ' AND C5_XOPER IN ("+__cTipo+") "

TCQUERY _cQ ALIAS "CNRP" NEW

DbSelectArea("CNRP")

_nNRP	:=	CNRP->COUNT

CNRP->(DbCloseArea())

If	__cTipo	= '12'
	_cQ	:=	"SELECT COUNT(*) COUNT FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM IN ("+__cPed+") AND D_E_L_E_T_ = ' ' AND C5_XOPER IN ('04','20') "
Else
	_cQ	:=	"SELECT COUNT(*) COUNT FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM IN ("+__cPed+") AND D_E_L_E_T_ = ' ' AND C5_XOPER NOT IN ("+__cTipo+") "
Endif

TCQUERY _cQ ALIAS "CRP" NEW

DbSelectArea("CRP")

_nRP	:=	CRP->COUNT

CRP->(DbCloseArea())


If	_nNRP	>	0	.And.	_nRP	>	0
	
	_cQ	:=	"SELECT C5_NUM FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM IN ("+__cPed+") AND D_E_L_E_T_ = ' ' AND C5_XOPER IN ("+__cTipo+") "
	
	TCQUERY _cQ ALIAS "CNRP" NEW
	
	DbSelectArea("CNRP")
	
	_cAlert	:=	""
	While !EOF()
		If	Empty(_cAlert)
			_cAlert	:=	CNRP->C5_NUM
		Else
			_cAlert	+=	","+CNRP->C5_NUM
		Endif
		CNRP->(DbSkip())
	EndDo
	
	_cAlert	:=	"Os pedidos "+_cAlert+" s„o do tipo '"+__cTipo+"' e est„o misturados com pedidos de outro tipo!"
	
	CNRP->(DbCloseArea())
	
	Alert(_cAlert)
	
	Return(.F.)
	
Endif


Return (.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fValRota	∫Autor  ≥Eduardo Brust		 ∫ Data ≥  21/07/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna a quantidade de rotas na carga montada			  ∫±±
±±∫          ≥ 													          ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fValRota(__cPed)

local _cQuery	:= " "
local nRota := 0 //qtd de rotas

_cQuery += " SELECT COUNT(*) QTDROTA FROM "
_cQuery += " ( SELECT distinct(a1_xrota) ROTA "
_cQuery += " FROM " + RetSqlName("SC5")+" SC5, " + RetSqlName("SA1")+" SA1 "
_cQuery += " WHERE SC5.D_E_L_E_T_ = ' ' "
_cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
_cQuery += " AND C5_FILIAL = '"+xFilial("SC5")+"' "
_cQuery += " AND A1_FILIAL = '"+xFilial("SA1")+"' "
_cQuery += " AND c5_client = a1_cod "
_cQuery += " AND c5_lojaENT = a1_loja "
_cQuery += " AND C5_NUM IN ("+__cPed+")"
_cQuery += " GROUP BY A1_XROTA )"

MEMOWRIT("C:\ortp002_fvalrota.SQL",_cQuery)

TCQUERY _cQuery ALIAS "TMP1" NEW

DbSelectArea("TMP1")

nRota	:=	TMP1->QTDROTA

DbSelectArea("TMP1")
DbCloseArea()

Return (nRota)

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥fJustifica≥ Autor ≥ Eduardo Brust         ≥ Data ≥23/07/2010≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Locacao   ≥ Ortobom          ≥Contato ≥                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥                                                            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Analista Resp.≥  Data  ≥ Bops ≥ Manutencao Efetuada                    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥              ≥  /  /  ≥      ≥                                        ≥±±
±±≥              ≥  /  /  ≥      ≥                                        ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fJustifica()
// Variaveis Locais da Funcao
Local cEdit1	 := Space(125)
Local cEdit2	 := Space(125)
Local oEdit1
Local oEdit2

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.
Private INCLUI := .F.
Private ALTERA := .F.
Private DELETA := .F.
Private cLabel := "Carga: "

Define Font oFontGrd Name "Arial" Size 0,-12 Bold

DEFINE MSDIALOG _oDlg TITLE "Bloqueio de Cargas" FROM  178 , 181  TO  388 , 717  PIXEL

// Cria Componentes Padroes do Sistema
@  012 , 004  Say cLabel Size  017 , 008  COLOR CLR_BLUE PIXEL OF _oDlg
if nBlqCarga == 1 .OR. nBlqCarga == 3
	@  031 , 003  Say "Justicar Espaco:" Size  041 , 008  COLOR CLR_BLACK PIXEL OF _oDlg
	@  031 , 044  MsGet oEdit1 Var cEdit1 Size  214 , 009  COLOR CLR_BLACK PIXEL OF _oDlg
endif
if nBlqCarga == 2 .OR. nBlqCarga == 3
	@  047 , 044  MsGet oEdit2 Var cEdit2 Size  214 , 009  COLOR CLR_BLACK PIXEL OF _oDlg
	@  048 , 003  Say "Justificar Rota:" Size  037 , 008  COLOR CLR_BLACK PIXEL OF _oDlg
endif
@  080 , 090  Button "OK" Size  037 , 012  Action(Close(_oDlg),Processa({|lEnd| fGuardaJust("1",ALLTRIM(cEdit1),ALLTRIM(cEdit2),@lEnd)}, "Aguarde...","Gravando Justificativa.", .T. )) PIXEL OF _oDlg
@  080 , 152  Button "Cancelar" Size  037 , 012  Action(Close(_oDlg)) PIXEL OF _oDlg

ACTIVATE MSDIALOG _oDlg CENTERED

Return(.T.)

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa  ≥fGuardaJust Autor ≥ Eduardo Brust         ≥ Data ≥23/07/2010≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Locacao   ≥ Ortobom          ≥Contato ≥                                ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function fGuardaJust(cOP,cJustEsp,cJustRota,cEmbarque,cPedCarga)
//GUARDA INFORMACOES DA TABELA PAP
// EMPRESA/
Local aArea := Getarea()

if ALLTRIM(cOP) == "1"
	aTabPAP := {}
	AADD(aTabPAP,{CEMPANT,CUSERNAME,cJustEsp ,cJustRota} )
elseif ALLTRIM(cOP) == "2"
	
	//###BLOQUEIO AUTOMATICO DE PEDIDOS DE TROCA/SAC/BRINDE
	IF CEMPANT $ cEmpBlq   // ADD EMPRESAS
		
		//SO CRIA BLOQUEIO AUTOMATICO PRA CARGAS <> 04/22
		cQuery2  := ""
		cQuery2	+=" SELECT COUNT(*) TOT "
		cQuery2	+=" FROM " + RetSqlName("SC5")+" SC5  "
		cQuery2	+=" WHERE SC5.D_E_L_E_T_ = ' ' "
		cQuery2	+=" AND C5_FILIAL = '"+xFilial("SC5")+"'"
		cQuery2	+=" AND C5_NUM in ("+cPedCarga+") "
		cQuery2	+=" AND C5_XOPER NOT IN ('04','22')"
		
		If Select("TMPCARG") > 0
			dbSelectArea("TMPCARG")
			dbCloseArea()
		EndIf
		
		
		
		
		memowrite("c:\ORTP002_VERPEDQUIMICO.sql",cQuery2)
		TcQuery cQuery2 ALIAS "TMPCARG" NEW
		dbselectarea("TMPCARG")
		DBSELECTAREA("PAP")
		DBSETORDER(1)
		
		IF TMPCARG->TOT > 0
			if dbseek(xFilial("PAP")+cEmpAnt+cEmbarque) .and. PAP->PAP_MOTBLQ=="4"
				RECLOCK("PAP",.F.)
			else
				RECLOCK("PAP",.T.)
			endif
			PAP->PAP_FILIAL := XFILIAL("PAP")
			PAP->PAP_EMP 	:= CEMPANT
			PAP->PAP_EMBARQ := cEmbarque
			PAP->PAP_MOTBLQ := "4" // 1=BLOQUEIO ESPACO 2=ROTA 3=ESPACO/ROTA 4=BLOQUEIO AUTOMATICO
			PAP->PAP_JUSTIF := "BLOQUEIO AUTOMATICO DE PEDIDOS DE TROCA/SAC/BRINDE"
			PAP->PAP_USRJUS := CUSERNAME
			MSUNLOCK()
		ELSE
			if dbseek(xFilial("PAP")+cEmpAnt+cEmbarque) .and. PAP->PAP_MOTBLQ=="4"
				RECLOCK("PAP",.F.)
				DBDELETE()
				MSUNLOCK()
			endif
		ENDIF
		If Select("TMPCARG") > 0
			dbSelectArea("TMPCARG")
			dbCloseArea()
		EndIf
		
	ENDIF
	
	
	if len(aTabPAP) > 0
		
		_cmsg := ""
		if nBlqCarga == 1
			_cmsg := "Just.Espaco: " + aTabPAP[1][3]
		endif
		if nBlqCarga == 2
			_cmsg := "Just.Rota: " + aTabPAP[1][4]
		endif
		if nBlqCarga == 3
			_cmsg := "Just.Espaco: " + aTabPAP[1][3] + " | " + "Just.Rota: " + aTabPAP[1][4]
		endif
		IF nBlqCarga <> 0
			DBSELECTAREA("PAP")
			DBSETORDER(1)
			RECLOCK("PAP",.T.)
			PAP->PAP_FILIAL := XFILIAL("PAP")
			PAP->PAP_EMP 	:= CEMPANT
			PAP->PAP_EMBARQ := cEmbarque
			PAP->PAP_MOTBLQ := ALLTRIM(STR(nBlqCarga))
			PAP->PAP_JUSTIF := _cmsg
			PAP->PAP_USRJUS := CUSERNAME
			MSUNLOCK()
		ENDIF
	else
		DBSELECTAREA("PAP")
		DBSETORDER(1)
		if dbseek(xFilial("PAP")+cEmpAnt+cEmbarque) .and. PAP->PAP_MOTBLQ<>"4"
			RECLOCK("PAP",.F.)
			DBDELETE()
			MSUNLOCK()
		endif
	endif
	
endif
RestArea(aARea)
Return


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥LibCarga  ∫Autor  ≥Eduardo Brust		 ∫ Data ≥  02/08/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Selecao das cargas que serao liberadas		              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User function LibCarga()
Local cMarca	:= "XX" //GetMark()
local nOpca 	:= 0
local lInverte	:= .F.
Local oDlg
local _aRet		:= {}
Local aCampos	:= {{"PAP_OK","C",02,0 },{"PAP_EMBARQ","C",06,0 },{"ZQ_DTPREVE","D",08,0 },{"PAP_STATUS","C",1,0 },{"PAP_USRJUS","C",20,0 },{"PAP_MOTBLQ","C",1,0 },{"PAP_JUSTIF","C",250,0 }}
Local aCampos2 	:= {{"PAP_OK",,"  ",""},{"PAP_EMBARQ",,"Embarque","@X" },{"ZQ_DTPREVE",,"Data ProgamaÁ„o","@X"},{"PAP_STATUS",,"Status","@X"},{"PAP_USRJUS",,"Usuario Just","@X"},{"PAP_MOTBLQ",,"Mot.Bloq","@X"},{"PAP_JUSTIF",,"Justicativa","@X"}}
local _cArq 	:= CriaTrab(aCampos,.T.)
LOCAL cQuery := ""
Local aStatus := {" ","S=Aceito","N=Negado"}
Local n:=0
Private cStatus := " "
Private oDlg2
Private cImage  := "logorto3.jpg"
Private oEscNt
Private nRespNt := 0
Private cCarga := SPACE(6)
Private dDataPrev := STOD("  /  /  ")
Private _aRetLib := {}

_aRetLib := U_fValSenha("Liberacao de Cargas","Liberaca de Cargas","000062")  //senha pra liberacao de carga
//Vetor[1] = Retorna o valor lÛgico se o usu·rio est· no grupo de liberaÁ„o.
//Vetor[2] = Retorna o nome do usu·rio que fara a liberaÁ„o.

//if !U_fValSenha("Liberacao de Cargas","Liberaca de Cargas","000062")  //senha pra liberacao de carga
if !_aRetLib[1]
	return()
endif

Define MSDialog oDlg2 Title OemToAnsi("LiberaÁ„o de Cargas") From 000,000 To 200,360 Pixel
DEFINE Font oFont1 Name "Verdana" Size 0,-15 Bold
@ 005,005 to 100,180 Pixel
@ 008,055 Jpeg FILE cImage Size 150,150 PIXEL BORDER OF oDlg2 oBject oFigura
@ 045,015 Say OemToAnsi("Carga") Size 49,8 Pixel
@ 045,060 Get cCarga  PICTURE "@!" Size 76,10  Pixel
@ 060,015 Say OemToAnsi("Data Previs„o") Size 49,8 Pixel
@ 060,060 Get dDataPrev PICTURE "@!" Size 76,10  Pixel
@ 078,070 Button OemToAnsi("Confirmar")   Size 50,15   Action (nRespNt := 1,oDlg2:End()) Pixel of oDlg2

ACTIVATE MSDIALOG oDlg2 CENTERED

if nRespNt == 0
	return()
endif

if ( EMPTY(cCarga) .AND. EMPTY(dDataPrev) )
	aviso("LiberaÁ„o de Cargas"," Sem Dados para os par‚metros passados ! ",{"OK"})
	If Select("LIBCARGA") > 0
		dbSelectArea("LIBCARGA")
		dbCloseArea()
	EndIf
	return()
endif

dbUseArea(.T.,,_cArq,"LIBCARGA",.F.,.F.)
IndRegua("LIBCARGA",CriaTrab(NIL,.F.),"PAP_EMBARQ",,,"Indexando Cargas")

cQuery:=" SELECT * "
cQuery+=" FROM "+RetSqlName("SZQ")+" SZQ, "
cQuery+= RetSqlName("PAP")+" PAP "
cQuery+=" WHERE SZQ.D_E_L_E_T_ = ' ' "
cQuery+=" AND PAP.D_E_L_E_T_ = ' ' "
cQuery+=" AND ZQ_FILIAL = '"+xFilial("SZQ")+"' "
cQuery+=" AND PAP_FILIAL = '"+xFilial("PAP")+"' "
cQuery+=" AND ZQ_EMBARQ = PAP_EMBARQ "
cQuery+=" AND PAP_STATUS <> 'S' "
cQuery+=" AND PAP_MOTBLQ <> '4' "  // NAO TRAZER BLOQUEIO AUTOMATICO DA CARGA
cQuery+=" AND PAP_EMP = '"+CEMPANT+"' "
IF !EMPTY(cCarga)
	cQuery+=" AND PAP_EMBARQ = '" + cCarga + "'"
ENDIF
IF !EMPTY(dDataPrev)
	cQuery+=" AND ZQ_DTPREVE = '" + DTOS(dDataPrev) + "'"
ENDIF

If Select("TMP") > 0
	dbSelectArea("TMP")
	dbCloseArea()
EndIf
memowrite("c:\ORTP002_LIBCARGA.sql",cQuery)
TCQUERY cQuery ALIAS "TMP" NEW

dbselectarea("TMP")

// Carga do Alias LIBCARGA com os dados da Query
TMP->(dbgotop())
if TMP->(eof())
	aviso("LiberaÁ„o de Cargas"," Sem Dados para os par‚metros passados ! ",{"OK"})
	If Select("LIBCARGA") > 0
		dbSelectArea("LIBCARGA")
		dbCloseArea()
	EndIf
	return()
endif
while TMP->(!eof())
	
	RecLock("LIBCARGA",.T.)
	LIBCARGA->PAP_OK 		:= cMarca
	LIBCARGA->PAP_EMBARQ	:= TMP->PAP_EMBARQ
	LIBCARGA->ZQ_DTPREVE	:= STOD(TMP->ZQ_DTPREVE)
	LIBCARGA->PAP_JUSTIF	:= TMP->PAP_JUSTIF
	LIBCARGA->PAP_STATUS	:= TMP->PAP_STATUS
	LIBCARGA->PAP_USRJUS	:= TMP->PAP_USRJUS
	LIBCARGA->PAP_MOTBLQ	:= TMP->PAP_MOTBLQ
	MsUnlock()
	
	TMP->(dbskip())
enddo

If Select("TMP") > 0
	dbSelectArea("TMP")
	dbCloseArea()
EndIf

LIBCARGA->( dbGotop() )
DEFINE MSDIALOG oDlg TITLE "Selecione as cargas que ser„o Liberadas/Negadas" From 005,000 To 041,115 OF oMainWnd
oMark := MsSelect():New("LIBCARGA","PAP_OK","",aCampos2,@lInverte,@cMarca,{20,2,240,450})
oMark:oBrowse:bAllMark := {|| LIBCARGA->(DBEVAL({||RecLock("LIBCARGA",.F.),LIBCARGA->PAP_OK := iif(empty(LIBCARGA->PAP_OK),cMarca,""),MsUnlock()})), LIBCARGA->(dbgotop())}
@ 245,010 Say "################################" Size 300,008 COLOR CLR_BLUE PIXEL OF oDlg
@ 245,230 Say "LiberaÁ„o" Size 044,008 COLOR CLR_BLUE PIXEL OF oDlg
@ 245,150 Say "## Bloqueios ##" Size 044,008 COLOR CLR_RED PIXEL OF oDlg     //NOVO
@ 250,010 Say "# Para marcar tudo ou desmarcar tudo #" Size 300,008 COLOR CLR_BLUE PIXEL OF oDlg
@ 250,150 Say "1= Bloq. Espaco" Size 044,008 COLOR CLR_RED PIXEL OF oDlg     //NOVO
@ 255,010 Say "# clique no cabecalho da coluna           #" Size 300,008 COLOR CLR_BLUE PIXEL OF oDlg
@ 255,150 Say "2= Bloq. Rota" Size 044,008 COLOR CLR_RED PIXEL OF oDlg     //NOVO
@ 255,230 Combobox  cStatus ITEMS aStatus Size 80,50 Pixel
@ 260,010 Say "################################" Size 300,008 COLOR CLR_BLUE PIXEL OF oDlg
@ 260,150 Say "3= Bloq. Esp/Rota" Size 044,008 COLOR CLR_RED PIXEL OF oDlg     //NOVO

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,{|| IIF(EMPTY(cStatus),aviso("","Selecionar LiberaÁ„o !",{"OK"}) ,(nOpca := 1,oDlg:End()) ) } , {|| nOpca := 2,oDlg:End()}) CENTERED

if nOpca == 1 // Confirmou o processamento
	LIBCARGA->(dbgotop())
	while LIBCARGA->(!eof())
		dbselectarea("LIBCARGA")
		if IsMark("PAP_OK",cMarca,lInverte) // Se a empresa foi marcada, checa os modos de compartilhamento dos arquivos
			AADD( _aRet, {LIBCARGA->PAP_EMBARQ,SUBSTR(cStatus,1,1)})
		endif
		LIBCARGA->(dbskip())
	enddo
endif

If Select("LIBCARGA") > 0
	dbSelectArea("LIBCARGA")
	dbCloseArea()
EndIf

IF LEN(_aRet) > 0
	
	FOR n:= 1 to len(_aRet)
		
		cQuery := ""
		//		cQuery+=" UPDATE "+RetSqlName("PAP")+" PAP SET PAP_USUARI = '" +ALLTRIM(CUSERNAME)+"' ,"
		cQuery+=" UPDATE "+RetSqlName("PAP")+" PAP SET PAP_USUARI = '" +ALLTRIM(_aRetLib[2])+"' ,"		//_aRetLib[2] - Possui o nome do liberador.
		cQuery+=" PAP_STATUS = '"+SUBSTR(cStatus,1,1)+"' ,"
		cQuery+=" PAP_DTLIBE = '"+DTOS(date())+"'"
		cQUery+=" WHERE PAP_FILIAL = '"+xFilial("PAP")+"' AND PAP.D_E_L_E_T_ = ' ' AND PAP_MOTBLQ <> '4'"
		cQUery+=" AND PAP_EMP = '"+CEMPANT+"'"
		cQUery+=" AND PAP_EMBARQ = '"+ALLTRIM(_aRet[n][1])+"'"
		Begin Transaction
		TCSQLExec(cQuery)
		End Transaction
		
		/*
		// GLM: George: SSI: 23836: 19/09/2012
		// Envio de email com copia do pedido para o cliente
		_cMsg := "Sua carga foi montada e encontra-se em producao."
		
		cQuery := "  Select SC5.C5_NUM     As PEDIDO,  "
		cQuery += "         SC5.C5_CLIENTE As CLIENTE, "
		cQuery += "         SC5.C5_LOJACLI As LOJA,    "
		cQuery += "         SA1.A1_XEMAILC As EMAIL    "
		cQuery += "    From " + RETSQLNAME("SC5") + " SC5, "
		cQuery +=               RETSQLNAME("SA1") + " SA1  "
		cQuery += "   WHERE SC5.D_E_L_E_T_    = ' '                            "
		cQuery += "     AND SC5.C5_FILIAL     = '" + xFilial("SC5")       + "'"
		cQuery += "     AND SC5.C5_XEMBARQ    = '" + AllTrim(_aRet[n][1]) + "'"
		cQuery += "     AND SC5.C5_XOPER      = '01'                           "
		cQuery += "     AND SA1.D_E_L_E_T_    = ' '                            "
		cQuery += "     AND SA1.A1_FILIAL     = '" + xFilial("SA1")        + "'"
		cQuery += "     AND SA1.A1_COD        = SC5.C5_CLIENTE                 "
		cQuery += "     AND SA1.A1_LOJA       = SC5.C5_LOJACLI                 "
		cQuery += "     AND SA1.A1_XEMAILC LIKE '%@%'                          "
		cQuery += "Order By SC5.C5_CLIENTE, SC5.C5_LOJACLI "
		
		If Select("QRY1") > 0  ; (DbCloseArea())  ; Endif
		TcQuery cQuery Alias "QRY1" New
		
		u_fUserMWrite("ORTP005.sql",cQuery)
		
		QRY1->(DbGoTop())
		Do While QRY1->(!Eof())  // percorre todo o arquivo
		If cEmpAnt $ ('03|05|16|22')  // se empresa seleciona
		U_MONTAPEDHTML(QRY1->PEDIDO, QRY1->CLIENTE, QRY1->LOJA, QRY1->EMAIL, _cMsg)
		EndIf
		QRY1->(DbSkip())
		EndDo
		
		QRY1->(DbCloseArea())
		*/
		
	NEXT
	
ENDIF

return(.T.)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥VerPedTBS ∫Autor  ≥Eduardo Brust		 ∫ Data ≥  20/08/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Selecao dos Pedidos que serao liberados (Troca/Brinde/Sac) ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User function VerPedTBS()
Local i:=0
Private aHeader      := {}
Private aCols        := {}
Private aCampos      := {}

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.
Private INCLUI := .T.
Private ALTERA := .T.
Private DELETA := .F.
Private oFigura1
Private lConfirma := .F.

Define Font oFontGrd Name "Arial" Size 0,-12 Bold

aCampos := {"PB2_PEDIDO","A1_NOME","C5_XOPER","C5_XREGIAO","PB2_DTBLOQ","PB2_JUSTIF"}

For I:= 1 to Len(aCampos)
	DbSelectArea("SX3")
	DbSetOrder(2)//NAO TROCAR
	If DbSeek(aCampos[I])
		Aadd(aHeader,{X3Titulo(), X3_CAMPO, X3_PICTURE,X3_TAMANHO, ;
		X3_DECIMAL,X3_VLDUSER, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT} )
	EndIf
Next

//retorna pedidos com bloqueios
fRetPed()

ntam := len(acols)

IF ntam > 0
	
	DEFINE MSDIALOG _oDlg TITLE "Justificar Pedidos de Troca/Brinde/SAC" FROM 181,030 TO 566,1116 PIXEL
	
	@ 004,004 TO 170,542 MULTILINE MODIFY object oMultiPed
	
	
	@ 175,260 Button "&Confirma" Size 037,014 Action(fGravaPed(ntam)) Font oFontGrd PIXEL OF _oDlg
	
	@ 175,304 Button "Ca&ncela" Size 037,014 Action(if(MsgBox("Deseja Cancelar Digitacao?","ATENCAO","YESNO"),Close(_oDlg),)) Font oFontGrd PIXEL OF _oDlg
	
	ACTIVATE MSDIALOG _oDlg CENTERED
	
ENDIF

return(aCols)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fRetPed   ∫Autor  ≥Eduardo Brust		 ∫ Data ≥  20/08/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna Pedidos com bloqueio					              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fRetPed()
Private oDlg2
Private cImage  := "logorto3.jpg"
Private oEscNt
Private nRespNt := 0
Private cCarga := SPACE(6)
Private dDataPrev := STOD("  /  /  ")

Define MSDialog oDlg2 Title OemToAnsi("Pedidos Troca/Brinde/Sac") From 000,000 To 200,360 Pixel
DEFINE Font oFont1 Name "Verdana" Size 0,-15 Bold
@ 005,005 to 100,180 Pixel
@ 008,055 Jpeg FILE cImage Size 150,150 PIXEL BORDER OF oDlg2 oBject oFigura
@ 055,015 Say OemToAnsi("Data Previs„o") Size 49,8 Pixel
@ 055,060 Get dDataPrev PICTURE "@!" Size 76,10  Pixel
@ 078,070 Button OemToAnsi("Confirmar")   Size 50,15   Action (nRespNt := 1,oDlg2:End()) Pixel of oDlg2

ACTIVATE MSDIALOG oDlg2 CENTERED

if nRespNt == 0
	return()
endif

if  EMPTY(dDataPrev)
	aviso("Pedidos Troca/Brinde/SAC"," Sem Dados para os par‚metros passados ! ",{"OK"})
	return()
endif

//cQuery:=" SELECT C5_NUM,C5_CLIENTE,C5_EMISSAO,C5_XENTREF,A1_EST,A1_COD_MUN,A1_MUN,A1_BAIRRO,C5_XOPER,NVL(PB2_JUSTIF,LPAD(' ',200,' ')) JUSIF "
cQuery:=" SELECT C5_NUM,C5_CLIENTE,C5_EMISSAO,C5_XENTREF,C5_XREGIAO,C5_XOPER, A1_NOME, NVL(PB2_JUSTIF,LPAD(' ',200,' ')) JUSTIF, NVL(PB2_STATUS,'N') PB2_STATUS "
cQuery+=" FROM "+RetSqlName("SC5")+" SC5, "
cQuery+= RetSqlName("SA1")+" SA1,  "
cQuery+= RetSqlName("PB2")+" PB2  "
cQuery+=" WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery+=" AND SA1.D_E_L_E_T_ = ' ' "
cQuery+=" AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery+=" AND C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery+=" AND PB2.D_E_L_E_T_(+) = ' ' "
cQuery+=" AND PB2_FILIAL(+) = '"+xFilial("PB2")+"'"
cQuery+=" AND PB2_DTBLOQ(+) = '" + DTOS(dDataPrev) + "'"
cQuery+=" AND PB2_PEDIDO(+) = C5_NUM "
cQuery+=" AND SA1.A1_COD = C5_CLIENTE "
cQuery+=" AND SA1.A1_LOJA = C5_LOJACLI "
cQuery+=" AND C5_XEMBARQ = ' ' "
cQuery+=" AND C5_XACERTO = ' ' "
cQuery+=" AND C5_NOTA = ' '	   "
cQuery+=" AND C5_XOPER IN('02','03','17','05') "
cQuery+=" AND C5_XREGIAO <> ' ' "
cQuery+=" AND C5_XREGIAO IN (SELECT C5_XREGIAO "
cQuery+=" FROM "+RetSqlName("SC5")+" SC5, "
cQuery+= RetSqlName("SZQ")+" SZQ  "
cQuery+=" WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery+=" AND SZQ.D_E_L_E_T_ = ' ' "
cQuery+=" AND C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery+=" AND ZQ_FILIAL = '"+xFilial("SZQ")+"' "
cQuery+=" AND ZQ_EMBARQ = C5_XEMBARQ "
cQuery+=" AND C5_XACERTO = ' ' "
cQuery+=" AND C5_NOTA = ' '	   "
cQuery+=" AND C5_XEMBARQ <> ' ' "
cQuery+=" AND C5_XREGIAO <> ' ' "
cQuery+=" AND ZQ_DTPREVE = '" + dtos(dDataPrev) + "')"

If Select("TMPPED") > 0
	dbSelectArea("TMPPED")
	dbCloseArea()
EndIf

memowrite("c:\ORTP002_VERPEDTBS.sql",cQuery)
TCQUERY cQuery ALIAS "TMPPED" NEW
dbselectarea("TMPPED")

//CRIA DIRETORIO PARA EXPORTACAO DE PEDIDOS DE TROCA
MakeDir("C:\PEDIDO_TROCA")

cPedTroca := "PEDIDOS" + ENTER
WHILE !TMPPED->(eof())
	
	IF EMPTY(TMPPED->C5_XENTREF)
		
		cData := TMPPED->C5_EMISSAO
	ELSE
		cData := TMPPED->C5_XENTREF
	ENDIF
	
	IF STOD(cData) < dDataPrev -10 .and. TMPPED->PB2_STATUS<>"S"// 10 DIAS PRA TRAS
		AADD(ACOLS,{TMPPED->C5_NUM,alltrim(A1_NOME),alltrim(IF(TMPPED->C5_XOPER=="05","BRINDE",IF(TMPPED->C5_XOPER=="17","SAC","TROCA"))),alltrim(TMPPED->C5_XREGIAO),dDataPrev,TMPPED->JUSTIF,.F.})
		cPedTroca += TMPPED->C5_NUM + ENTER
	ENDIF
	TMPPED->(DBSKIP())
ENDDO

memowrite("C:\PEDIDO_TROCA\PEDIDOS_TROCA.TXT",cPedTroca)

// SE NAO TIVER PEDIDOS DE TROCA/BRINDE/SAC PRA ESTA DATA DE PROGRAMACAO RETIRA TRAVA AUTOMATICA
IF LEN(ACOLS) = 0
	//TIRA TRAVA AUTOMATICA DA CARGA
	
	cQuery  := ""
	cQuery	+=" SELECT COUNT(*) TOT "
	cQuery	+=" FROM " + RetSqlName("PB2")+" PB2  "
	cQuery	+=" WHERE PB2.D_E_L_E_T_ = ' ' "
	cQuery	+=" AND PB2_FILIAL = '"+xFilial("PB2")+"'"
	cQuery	+=" AND PB2_DTBLOQ = '" + DTOS(dDataPrev) + "'"
	cQuery	+=" AND PB2_STATUS = ' ' "
	
	If Select("TMPPED2") > 0
		dbSelectArea("TMPPED2")
		dbCloseArea()
	EndIf
	memowrite("c:\ORTP002_VERPEDTBS2.sql",cQuery)
	TCQUERY cQuery ALIAS "TMPPED2" NEW
	dbselectarea("TMPPED2")
	
	IF TMPPED2->TOT > 0
		Aviso("Aviso","Pedidos j· justificados. Entre na opcao 2)Lib. Ped T/B/S.", {"Ok"} )
	ELSE
		cQuery:=" UPDATE "+RetSqlName("PAP")+" PAP SET PAP_STATUS = 'S', "
		cQuery+=" PAP_DTLIBE = '"+ DTOS(date()) + "', PAP_USUARI = '"+ALLTRIM(CUSERNAME)+ "'"
		cQuery+=" WHERE PAP_FILIAL = '"+xFilial("PAP")+"' AND PAP.D_E_L_E_T_ = ' ' AND PAP_MOTBLQ = '4'"
		cQuery+=" AND PAP_EMP = '"+CEMPANT+"'"
		cQuery+=" AND PAP_EMBARQ IN (SELECT ZQ_EMBARQ "
		cQuery+=" FROM "+RETSQLNAME("SZQ")+ " SZQ "
		cQuery+=" WHERE SZQ.D_E_L_E_T_ = ' ' "
		cQuery+=" AND ZQ_FILIAL = '" + XFILIAL("SZQ") + "'"
		cQuery+=" AND ZQ_DTPREVE = '" + DTOS(dDataPrev) + "')"
		memowrite("c:\UPDDATE_PAP.sql",cQuery)
		Begin Transaction
		TCSQLExec(cQuery)
		End Transaction
		
		Aviso("Aviso","N„o h· pedidos com bloqueios para esta data de programaÁ„o!", {"Ok"} )
	ENDIF
	If Select("TMPPED2") > 0
		dbSelectArea("TMPPED2")
		dbCloseArea()
	EndIf
	
ENDIF

return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fGravaPed ∫Autor  ≥Eduardo Brust		 ∫ Data ≥  02/08/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Grava pedidos justificados					              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function fGravaPed(ntam)
Local nJust := 0
Local i:=0
FOR I:= 1 TO ntam
	IF EMPTY(ACOLS[I,6])  //VALIDA JUSTIFICATIVA
		nJust++
	ENDIF
NEXT
IF nJust = 1
	Aviso("Aviso","Existe " +ALLTRIM(STR(nJust))+" Pedido sem Justificativa !", {"Ok"} )
	//	return
ELSEIF nJust > 1
	Aviso("Aviso","Existem " +ALLTRIM(STR(nJust))+" Pedidos sem Justificativa !", {"Ok"} )
	//	return
ENDIF

FOR I:=1 TO ntam
	IF !EMPTY(ACOLS[I,1])
		DBSELECTAREA("PB2")
		DBSETORDER(1)
		IF DBSEEK(XFILIAL("PB2")+ACOLS[I,1]+DTOS(ACOLS[I,5]))
			RECLOCK("PB2",.F.)
		ELSE
			RECLOCK("PB2",.T.)
		ENDIF
		PB2->PB2_FILIAL := XFILIAL("PB2")
		PB2->PB2_PEDIDO := ACOLS[I,1]
		PB2->PB2_USRJUS := CUSERNAME
		PB2->PB2_DTBLOQ := ACOLS[I,5]
		PB2->PB2_JUSTIF := ACOLS[I,6]
		MSUNLOCK()
	ENDIF
NEXT

Aviso("Aviso","Justificativa Gravada com Sucesso!", {"Ok"} )
Close(_oDlg)
return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥LibPedTBS ∫Autor  ≥Eduardo Brust		 ∫ Data ≥  20/08/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Libera Pedidos justificados				Troca/Brinde/Sac) ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function LibPedTBS()
Private oDlgA,oLbx,oFont,oFontA
Private oOk      := LoadBitmap( GetResources(), "LBOK" 		)
Private oNo      := LoadBitmap( GetResources(), "LBNO" 		)
Private aPedTrav := {}
Private oDlg2
Private cImage  := "logorto3.jpg"
Private oEscNt
Private nRespNt := 0
Private cPedido := SPACE(6)
Private dDataPrev := STOD("  /  /  ")
Private _aRetLib := {}

_aRetLib := U_fValSenha("Liberacao de Cargas","Liberaca de Cargas","000062")  //senha pra liberacao de carga
//Vetor[1] = Retorna o valor lÛgico se o usu·rio est· no grupo de liberaÁ„o.
//Vetor[2] = Retorna o nome do usu·rio que fara a liberaÁ„o.

//if !U_fValSenha("Liberacao de Pedidos","Liberacao de Pedidos","000062")  //senha pra liberacao de carga
if !_aRetLib[1]
	return()
endif

Define MSDialog oDlg2 Title OemToAnsi("LiberaÁ„o de Pedidos (Troca/Brinde/SAC)") From 000,000 To 200,360 Pixel
DEFINE Font oFont1 Name "Verdana" Size 0,-15 Bold
@ 005,005 to 100,180 Pixel
@ 008,055 Jpeg FILE cImage Size 150,150 PIXEL BORDER OF oDlg2 oBject oFigura
@ 045,015 Say OemToAnsi("Pedido") Size 49,8 Pixel
@ 045,060 Get cPedido  PICTURE "@!" Size 76,10  Pixel
@ 060,015 Say OemToAnsi("Data Previs„o") Size 49,8 Pixel
@ 060,060 Get dDataPrev PICTURE "@!" Size 76,10  Pixel
@ 078,070 Button OemToAnsi("Confirmar")   Size 50,15   Action (nRespNt := 1,oDlg2:End()) Pixel of oDlg2

ACTIVATE MSDIALOG oDlg2 CENTERED

if nRespNt == 0
	return()
endif

if ( EMPTY(cPedido) .AND. EMPTY(dDataPrev) )
	aviso("LiberaÁ„o de Pedidos"," Sem Dados para os par‚metros passados ! ",{"OK"})
	
	return()
endif

Processa({||fBuscPed()},"Aguarde... buscando pedidos...")

fTelaLib()

return

****************************************
Static Function fBuscPed()
****************************************
Local cQuery:= ""

aPedTrav:= {}

cQuery+= " SELECT *  "
cQuery+= " FROM  "
cQuery+= RetSqlName("PB2")+" PB2  "
cQuery+= " WHERE PB2.D_E_L_E_T_ = ' ' "
cQuery+= "   AND PB2_FILIAL   = '"+xFilial("PB2")+"'"
cQuery+= "   AND PB2_STATUS   <> 'S'         		"
cQuery+= "   AND PB2_DTBLOQ   = '"+dtos(dDataPrev)+ "'"

memowrite("c:\ortp002_LibPedTBS.sql",cQuery)
TcQuery cQuery ALIAS "QRY" NEW

dbselectarea("QRY")
WHILE !(EOF())
	aAdd(aPedTrav,{.T.,QRY->PB2_PEDIDO,STOD(QRY->PB2_DTBLOQ),QRY->PB2_USRJUS,QRY->PB2_JUSTIF})
	dbSkip()
enddo
dbselectarea("QRY")
dbCloseArea()

return


*----------------------------*
Static Function fTelaLib()
*----------------------------*
cTitulo:= "LiberaÁ„o de Pedidos (Troca/Brinde/SAC)"

if len(aPedTrav) = 0
	MsgBox("N„o existem pedidos a serem liberados", "Liberar pedidos bloqueados", "INFO")
	return
endif


DEFINE MSDIALOG oDlgA TITLE cTitulo FROM 0,0 TO 500,800 PIXEL // DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO ALTURA,LARGURA PIXEL

@ 10,10 LISTBOX oLbx FIELDS HEADER "","Pedido","Data Just","Justificante","Justificativa" SIZE 380,220 OF oDlgA PIXEL

oLbx:SetArray( aPedTrav )
//lista o conteudo dos vetores, variavel nAt eh a linha pintada (foco) e o numero da coluna
oLbx:bLine := {|| {	Iif(aPedTrav[oLbx:nAt,1],oOK,oNo),;
aPedTrav[oLbx:nAt,2],; //Pedido
aPedTrav[oLbx:nAt,3],; //Data Justif
aPedTrav[oLbx:nAt,4],; //Justificante
aPedTrav[oLbx:nAt,5]}} //Justificativa

oLbx:bLDblClick := {|nRowPix, nColPix, nKeyFlags| fMarcaUm(oLbx:nAt), oLbx:Refresh()}

@ 233,10  BUTTON "&Liberar" SIZE 060,015 PIXEL OF oDlgA  ACTION (fGrvLibPed(),oDlgA:End())   //DEFINE SBUTTON FROM LINHA,COLUNA
@ 233,80  BUTTON "&Sair"    SIZE 060,015 PIXEL OF oDlgA  ACTION ( oDlgA:End() ) //DEFINE SBUTTON FROM LINHA,COLUNA
ACTIVATE MSDIALOG oDlgA CENTER


return


***************************
Static Function fMarcaUm(nAt)
***************************
if aPedTrav[nAt,1]
	aPedTrav[nAt,1]:= .F.
else
	aPedTrav[nAt,1]:= .T.
endif

return



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fGrvLibPed∫Autor  ≥Eduardo Brust		 ∫ Data ≥  20/08/10   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Grava Liberacao no Pedido				Troca/Brinde/Sac) ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function fGrvLibPed()
Local cDataPRev := ""
Local n:=0
IF LEN(aPedTrav) > 0
	
	FOR n:= 1 to len(aPedTrav)
		cDataPRev := aPedTrav[n,3]
		DBSELECTAREA("PB2")
		DBSETORDER(1)
		IF aPedTrav[n,1]
			
			/*
			IF DBSEEK(XFILIAL("PB2")+aPedTrav[n,2]+DTOS(aPedTrav[n,3]))
			cDataPRev := aPedTrav[n,3]
			RECLOCK("PB2",.F.)
			PB2->PB2_USUARI := CUSERNAME         //USUARIO QUE LIBEROU
			PB2->PB2_STATUS := "S" 				 // LIBERACAO
			PB2->PB2_DTLIBE := date()	         // DATA QUE LIBEROU
			MSUNLOCK()
			ENDIF
			*/
			cQuery := ""
			//			cQuery+=" UPDATE "+RetSqlName("PB2")+" PB2 SET PB2_USUARI = '" +ALLTRIM(CUSERNAME)+"' ,"
			cQuery+=" UPDATE "+RetSqlName("PB2")+" PB2 SET PB2_USUARI = '" +ALLTRIM(_aRetLib[2])+"' ,"
			cQuery+=" PB2_STATUS = 'S' ,"
			cQuery+=" PB2_DTLIBE = '"+DTOS(date())+"'"
			cQUery+=" WHERE PB2_FILIAL = '"+xFilial("PB2")+"' AND PB2.D_E_L_E_T_ = ' ' "
			cQUery+=" AND PB2_PEDIDO = '"+ALLTRIM(aPedTrav[n,2])+"'"
			Begin Transaction
			TCSQLExec(cQuery)
			End Transaction
		ENDIF
	NEXT
	cQuery := ""
	cQuery+=" SELECT COUNT(*) TOT "
	cQuery+=" FROM " + RetSqlName("PB2")+" PB2  "
	cQuery+=" WHERE PB2.D_E_L_E_T_ = ' ' "
	cQuery+=" AND PB2_FILIAL = '"+xFilial("PB2")+"'"
	cQuery+=" AND PB2_DTBLOQ = '" + DTOS(cDataPRev) + "'"
	cQuery+=" AND PB2_STATUS <> 'S'"
	
	TcQuery cQuery ALIAS "TEMPPB2" NEW
	
	ltrava := .T. // RETIRA TRAVA AUTOMATICA
	IF TEMPPB2->TOT > 0
		ltrava := .F.  //NAO RETIRA TRAVA
	ENDIF
	
	IF SELECT("TEMPPB2") > 0
		DBSELECTAREA("TEMPPB2")
		DBCLOSEAREA()
	ENDIF
	
	//TIRA TRAVA AUTOMATICA DA CARGA
	IF !empty(cDataPRev) .AND. ltrava
		cQuery:=" UPDATE "+RetSqlName("PAP")+" PAP SET PAP_STATUS = 'S', "
		//		cQuery+=" PAP_DTLIBE = '"+ DTOS(date()) + "', PAP_USUARI = '"+ALLTRIM(CUSERNAME)+ "'"
		cQuery+=" PAP_DTLIBE = '"+ DTOS(date()) + "', PAP_USUARI = '"+ALLTRIM(_aRetLib[2])+ "'"
		cQuery+=" WHERE PAP_FILIAL = '"+xFilial("PAP")+"' AND PAP.D_E_L_E_T_ = ' ' AND PAP_MOTBLQ = '4'"
		cQuery+=" AND PAP_EMP = '"+CEMPANT+"'"
		cQuery+=" AND PAP_EMBARQ IN (SELECT ZQ_EMBARQ "
		cQuery+=" FROM "+RETSQLNAME("SZQ")+ " SZQ "
		cQuery+=" WHERE SZQ.D_E_L_E_T_ = ' ' "
		cQuery+=" AND ZQ_FILIAL = '" + XFILIAL("SZQ") + "'"
		cQuery+=" AND ZQ_DTPREVE = '" + DTOS(cDataPRev) + "')"
		memowrite("c:\UPDDATE_PAP.sql",cQuery)
		Begin Transaction
		TCSQLExec(cQuery)
		End Transaction
	ENDIF
	Aviso("Aviso","Liberado!", {"Ok"} )
ENDIF
Return

//---------------------------|
// SSI 6321
Static Function fTemCob(cCli)
Local lRet		:= .F.
Local cQuery	:= ""

cQuery+=" SELECT COUNT(*) TOT "
cQuery+=" FROM COBR"+cEmpAnt+"0 "
cQuery+=" WHERE E1_CLIENTE = '"+cCli+"' "
cQuery+="   AND E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery+="   AND E1_SALDO > 0 "
cQuery+="   AND E1_VENCREA < '"+ DTOS(date()) + "'     "
cQuery+="   AND E1_TIPO IN ('DPC', 'DP', 'CH ', 'PEN') "

TcQuery cQuery ALIAS "TEMPCOB" NEW

IF TEMPCOB->TOT > 0
	lRet := .T.
	
	cQuery := "SELECT COUNT(*) AS TOT FROM SIGA.LOGROTINA WHERE UN = '"+cEmpAnt+"' AND ROTINA = 'ORTP002' AND DTLOG = '"+DTOC(dDatabase)+"' AND TRIM(OBSERV) = '"+cCli+"' "
	TcQuery cQuery ALIAS "TEMLIB" NEW
	
	IF TEMLIB->TOT > 0
		lRet := .F.
	ENDIF
ENDIF

IF SELECT("TEMPCOB") > 0
	DBSELECTAREA("TEMPCOB")
	DBCLOSEAREA()
ENDIF

IF SELECT("TEMLIB") > 0
	DBSELECTAREA("TEMLIB")
	DBCLOSEAREA()
ENDIF

Return lRet
********************************
Static Function FLibp52(cPed)
********************************
Local lRet:=.F.
Local cQuery:=""
Local aArea:=GetArea()
cQuery:="SELECT COUNT(*) TREG FROM "+RetSqlName("SC6")+" SC6, "+RetSqlName("SC5")+" SC5, "+RetSqlName("SB1")+" SB1 "
cQuery+=" WHERE SC6.D_E_L_E_T_ = ' ' "
cQuery+="   AND SB1.D_E_L_E_T_ = ' ' "
cQuery+="   AND SC5.D_E_L_E_T_ = ' ' "
cQuery+="   AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery+="   AND C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery+="   AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery+="   AND B1_COD    = C6_PRODUTO "
cQuery+="   AND C6_NUM = '"+cPed+"' "
cQuery+="   AND C6_NUM = C5_NUM "
cQuery+="   AND C6_BLQ <> 'R' "
cQuery+="   AND C5_XOPER <> '04' "
cQuery+="   AND EXISTS (SELECT 'X' FROM SIGA.P52@PROD WHERE COD = B1_COD OR COD = B1_XCODBAS)"
MEMOWRIT("C:\FLibp52.SQL",cQuery)
TCQuery cQuery Alias "P52" New
DbSelectArea("P52")
nCont:= P52->TREG
DbCloseArea()
RestArea(aArea)
If nCont>0
	lRet:=.T.
Endif
Return(lRet)

*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
User Function ORTP002O(_cEmbarq, _cPedClx)
Local _aArea := GetArea()
Local _lRet  := .F.

dbselectarea("SC5")
dbsetorder(1)
dbGoTop()
if dbseek(xFilial("SC5")+_cPedClx)
	If RecLock("SC5",.F.)
		SC5->C5_XREFPED := _cEmbarq // Ser· utilizado como Embarque
		SC5->(MsUnLock())
		_lRet  := .T.
	Endif
Endif

RestArea(_aArea)
Return(_lRet)
*'--------------------------------------------------------------------------------------------------'*


Static Function ChecaSite()
Local lRet 		:= .F.
Local cPedidos 	:= ""
Local cQuery	:= ""
Local cTemp  	:= ""

If !cEmpAnt $ "18|21|22" .and. cFilant == "02"
	
	cQuery	:= " SELECT PEDIDO,ARQUIVO FROM SIGA.SITEFISICO             "
	cQuery	+= " WHERE UN = '"+cEmpAnt+"'                       "
	cQuery	+= "   AND NUMPED = '      '                        "
	cQuery	+= "   AND CANCELA <> 'T'                           "
	cQuery	+= "   AND DTVENDA >= '20181201'                    "
	cQuery	+= "   AND MARKETPLACE IN ('SIT')                    "
	cQuery	+= "   AND NOT EXISTS (SELECT C5_XTALSAC            "
	cQuery	+= "          FROM SIGA."+RetSqlName("SC5")+" SC5   "
	cQuery	+= "         WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery	+= "           AND D_E_L_E_T_ = ' '                 "
	cQuery	+= "           AND C5_XTPSEGM = '8'                 "
	cQuery	+= "           AND C5_EMISSAO >= '20181201'         "
	cQuery	+= "           AND TRIM(C5_XTALSAC) = TRIM(PEDIDO)) "
	cQuery	+= "           ORDER BY PEDIDO						"
	
	U_ORTQUERY(cQuery, "ORTP002_ST")
	While !ORTP002_ST->(eof())
		cTemp := SUBSTR(ORTP002_ST->ARQUIVO,AT("\MOV_",ORTP002_ST->ARQUIVO)+5,8)  
		cTemp := SUBSTR(cTemp,7,2)+"/"+SUBSTR(cTemp,5,2) +"/"+SUBSTR(cTemp,1,4)  
		cPedidos += ORTP002_ST->PEDIDO + " - DT " + cTemp + CRLF
		lRet	 := .T.
		ORTP002_ST->(dbSkip())
	Enddo
	ORTP002_ST->(dbCloseArea())
	
	If lRet
		MsgBox("Pedidos do site pendentes de importaÁ„o: " + CRLF + cPedidos, "Pedidos Pendentes de ImportaÁ„o", "INFO")
	Endif
	
EndIf

Return lRet

// Verifica se houve cancelamento do pagamento no mercado pago
User Function ORTP002D(cPedido, lSuprime)
Local cQry := ""
Local lRet := .F.               
Default lSuprime := .F.

cQry := "SELECT C5_NUM,     "
cQry += "       ZK_NUMRTC,	"
cQry += "       ZK_VALOR,	"
cQry += "       PA7_AUTORI,	"
cQry += "       PA7_DTCANC,	"
cQry += "       PA7_VLCANC	"
cQry += "  FROM SIGA."+RetSqlName("SZK")+" SZK, "
cQry += "       SIGA."+RetSqlName("PA7")+" PA7, "
cQry += "       SIGA."+RetSqlName("SC5")+" SC5	"
cQry += " WHERE ZK_FILIAL  = '"+xFilial("SZK")+"' "
cQry += "   AND PA7_FILIAL = '"+xFilial("PA7")+"' "
cQry += "   AND C5_FILIAL  = '"+xFilial("SC5")+"' "   
cQry += "   AND SZK.D_E_L_E_T_ = ' ' "
cQry += "   AND PA7.D_E_L_E_T_ = ' ' "
cQry += "   AND SC5.D_E_L_E_T_ = ' ' "   
cQry += "   AND PA7_ADM IN ('40')    		"
cQry += "   AND PA7_EMPRES = '"+cEmpant+"'	"
cQry += "   AND PA7_VLCANC > 0				"      
cQry += "   AND C5_XOPER NOT IN ('96','99','98')		"
cQry += "   AND ZK_CARTAUT     = PA7_AUTORI "
cQry += "   AND SZK.R_E_C_N_O_ = PA7_RECNO  "
cQry += "   AND ZK_OPERAC = 'AT'			"
cQry += "   AND C5_EMISSAO >= '20200201'	"
cQry += "   AND ZK_PEDIDO = C5_NUM "
cQry += "   AND C5_NUM = '"+cPedido+"'		"

U_ORTQUERY(cQry, "ORTP002_CB")

While !ORTP002_CB->(eof())			
	If !lSuprime
		MsgBox("Existe um cancelamento no valor de R$" + Alltrim(Transform(ORTP002_CB->PA7_VLCANC, "@E 999,999,999.99")) + " do pagamento deste pedido: " + ORTP002_CB->C5_NUM + ".", "Pagamento Estornado", "INFO")		
	Endif
	
	lRet	 := .T.
	dbSkip()
Enddo

ORTP002_CB->(dbCloseArea())
  
Return lRet   

******************************
Static Function  fDescZF(cEmb)
******************************
Local nRet:=0

   cQry:=      "Select Sum(F2_DESCZFR) F2_DESCZFR"
   cQry+=ENTER+"From Siga." +RetSQLName("SF2")+ " F2" 
   cQry+=ENTER+"Where F2.D_E_L_E_T_ = ' '" 
   cQry+=ENTER+"AND F2_DOC In (Select C5_NOTA"
   cQry+=ENTER+"                From Siga." + RetSQLName("SC5")+ " C5"
   cQry+=ENTER+"                Where C5.D_E_L_E_T_ = ' '"
   cQry+=ENTER+"                  AND C5_XEMBARQ = '" +cEmb+ "')"

   MemoWrite("C:\fDescZFP002.TXT", cQry)

   If Select("QYRZF") > 0
      QRYZF->(DbCloseArea())
   EndIf
   DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry),"QRYZF", .F., .T.)
   QRYZF->(DbGoTop())
   If ! QRYZF->(Eof())
      nRet:=QRYZF->F2_DESCZFR
   EndIf
   QRYZF->(DbCloseArea())

Return(nRet)

Static Function RELPTF()

U_ORTR019() 

Return Nil


Static Function AGLUPED()

U_ORTA719() 

Return Nil

Static Function VLCAR()

U_ORTR063() 

Return Nil


