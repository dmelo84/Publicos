#INCLUDE  'TBICONN.CH'
#INCLUDE  'TOPCONN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE   'RWMAKE.CH'
#INCLUDE     'JPEG.CH'
#INCLUDE     'FONT.CH'

/*/
//*****************************************************************************
//*+-------------------------------------------------------------------------+*
//*|Funcao      | OrtA065  | Autor |  Cleverson Luiz Schaefer                |*
//*+------------+------------------------------------------------------------+*
//*|Data        | 11.12.2006                                                 |*
//*+------------+------------------------------------------------------------+*
//*|Descricao   | Tela de consulta de pedidos e impressao da consulta. Uti-  |*
//*|            | lizada para averiguar o Status do Pedido.                  |*
//*+------------+------------------------------------------------------------+*
//*|Orcamento   | 0153-06/2006                                               |*
//*+-------------------------------------------------------------------------+*
//*|Alterado por| Henrique                | Data | 15/07/2014                |*
//*+-------------------------------------------------------------------------+*
//*|Descricao   | SSI 3029 - Ajuste no campo "Obs. Diversas" para que  sejam |*
//*|            |            exibidas todas as notas fiscais envolvidas.     |*
//*+-------------------------------------------------------------------------+*
//*****************************************************************************
/*/

User Function ORTA065()
***********************
Local cImage    := "logorto3.jpg"         //Arquivo .JPG gravado no diretorio \SYSTEM do servidor
Local nAjusTela := 15

SetKey(12,{|| fLimpVar()})
SetKey(16,{|| fImpCons()})
**************************** RETIRAR APOS TESTE **********************
//PREPARE ENVIRONMENT EMPRESA "04" FILIAL "02"
**********************************************************************

Private cCarga	 := Space(25)
//incluido Antonio CArmo 26/06/07
Private dDtAct	 := CtoD("/ /")
Private cMotor	 := Space(35)
Private cTpRcb	 := Space(100)
Private dDtBxP	 := CtoD("/ /")
Private cNuRtc	 := Space(25)

Private cCNPJ	 := Space(25)
Private cMotCanc := Space(25)
Private cNomCli	 := Space(25)
Private cNomVend := Space(25)
Private cNumNF	 := Space(25)
Private cNumPed	 := Space(6)
Private cNumPedC := Space(7)
Private cNumTQ	 := Space(6)
Private cObs1	 := Space(10)
Private cObs2	 := ""
Private cSituac	 := Space(25)
Private cVend	 := Space(25)
Private dDtCanc	 := CtoD("/ /")
Private dDtLib	 := CtoD("/ /")
Private dDtPrg	 := CtoD("/ /")
Private dDtSai	 := CtoD("/ /")
Private dDtPed	 := CtoD("/ /")
Private dDtVend	 := CtoD("/ /")
Private cCodCli  := Space(6)
Private cLojCli  := Space(2)
Private cSerNf   := Space(3)
Private aButtons := {}
Private oCarga
//Incluido Antonio Carmo
Private oDtAct
Private oMotor
Private oTpRcb
Private oDtBxP
Private oNuRtc

Private oCNPJ
Private oDtCanc
Private oDtLib
Private oDtPrg
Private oDtSai
Private oMotCanc
Private oNomCli
Private oNomVend
Private oNumNF
Private oNumPed
Private oNumPedC
Private oNumTQ
Private oObs1
Private oObs2
Private oObsDev
Private oSituac
Private oVend
Private oDlgCPed
Private oDtPed
Private oDtVend
Private oBtnSair
Private oCodCli
Private oLojCli
Private oSerNf
Private __cCanc
Private _cObsDev


Define Font oFontGrd Name "TAHOMA" Size 0,-12 Bold
Define Font oFontNeg Name "ARIAL" Size 0,-12 Bold

// Array utilizado para incluir botoes ao EnchoiceBar
Aadd(aButtons,{"IMPRESSAO_OCEAN",{|| fImpCons()},"Imprime Consulta - <CTRL+P>","Imprimir"})
Aadd(aButtons,{"TK_HISTORY"     ,{|| fLimpVar()},"Limpar as Variaveis - <CTRL+L>","Limpar"})

DEFINE MSDIALOG oDlgCPed TITLE "Consulta de Pedidos" FROM 158,248+nAjusTela TO 710,897+nAjusTela PIXEL

oDlgCPed:bStart := {|| (ENCHOICEBAR(oDlgCPed,{|| fGrvObs(),fLimpVar()},{|| oDlgCPed:End()},,aButtons))}

// Cria as Groups do Sistema
@ 015,004 TO 275,313 PIXEL OF oDlgCPed

// Imagem
//@ 017,230 Jpeg FILE cImage Size 040,015 PIXEL NOBORDER OF oDlgCPed oBject oFigura1

// Textos

@ 025+nAjusTela,010 Say "Pedido"               Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 025+nAjusTela,130 Say __cCanc      		     Size 067,010 COLOR CLR_RED   Font oFontGrd PIXEL OF oDlgCPed
@ 025+nAjusTela,180 Say "Pedido Cobol"         Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 040+nAjusTela,010 Say "Situação"             Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 055+nAjusTela,010 Say "CGC/CNPJ"             Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 055+nAjusTela,175 Say "Código/Loja Cliente"  Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 070+nAjusTela,010 Say "Nome do Cliente"      Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 085+nAjusTela,010 Say "Data do Pedido"       Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 085+nAjusTela,125 Say "Data Venda"           Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 085+nAjusTela,218 Say "Data Liberação"       Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 100+nAjusTela,010 Say "Data Cancelamento"    Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 115+nAjusTela,010 Say "Data Programação"     Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 115+nAjusTela,125 Say "Número da Carga"      Size 067,008 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 115+nAjusTela,223 Say "Data Acerto"          Size 067,008 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed	//Incluido Antonio Carmo
@ 130+nAjusTela,010 Say "Data da Saída"        Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 130+nAjusTela,125 Say "Nome Motorista"       Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed //Incluido Antonio Carmo
@ 145+nAjusTela,010 Say "Tipo Recebimento"     Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed //Incluido Antonio Carmo
@ 160+nAjusTela,010 Say "Número da TQ"         Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 160+nAjusTela,175 Say "Nota Fiscal/Serie"    Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 175+nAjusTela,010 Say "Obs. Internas"        Size 067,010 COLOR CLR_BLACK Font oFontGrd PIXEL OF oDlgCPed
@ 205+nAjusTela,010 Say "Vendedor"             Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 220+nAjusTela,010 Say "Obs. Comercial"       Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed
@ 250+nAjusTela,010 Say "Obs. Diversas "       Size 067,010 COLOR CLR_BLUE  Font oFontGrd PIXEL OF oDlgCPed

// Gets
@ 023+nAjusTela,082 MsGet oNumPed  Var cNumPed    Size 041,010 Valid(fBusPed(cNumPed))  COLOR CLR_BLUE  Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 023+nAjusTela,242 MsGet oNumPedC Var cNumPedC   Size 041,010 Valid(fBusPed(strzero(val(cNumpedc),7)))  COLOR CLR_BLUE  Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 038+nAjusTela,082 MsGet oSituac  Var cSituac    Size 085,010                   COLOR CLR_RED   Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 053+nAjusTela,082 MsGet oCNPJ    Var cCNPJ      Size 085,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 053+nAjusTela,245 MsGet oCodCli  Var cCodCli    Size 030,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 053+nAjusTela,277 MsGet oLojCli  Var cLojCli    Size 010,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 068+nAjusTela,082 MsGet oNomCli  Var cNomCli    Size 160,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 083+nAjusTela,082 MsGet oDtPed   Var dDtPed     Size 041,010                   COLOR CLR_BLACK Font oFontNeg Picture "@D 99/99/9999" PIXEL OF oDlgCPed
@ 083+nAjusTela,165 MsGet oDtVend  Var dDtVend    Size 041,010                   COLOR CLR_BLACK Font oFontNeg Picture "@D 99/99/9999" PIXEL OF oDlgCPed
@ 083+nAjusTela,266 MsGet oDtLib   Var dDtLib     Size 041,010                   COLOR CLR_BLACK Font oFontNeg Picture "@D 99/99/9999" PIXEL OF oDlgCPed
@ 098+nAjusTela,082 MsGet oDtCanc  Var dDtCanc    Size 041,010                   COLOR CLR_BLACK Font oFontNeg Picture "@D 99/99/9999" PIXEL OF oDlgCPed
@ 098+nAjusTela,125 MsGet oMotCanc Var cMotCanc   Size 181,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 113+nAjusTela,082 MsGet oDtPrg   Var dDtPrg     Size 041,010                   COLOR CLR_BLACK Font oFontNeg Picture "@D 99/99/9999" PIXEL OF oDlgCPed
@ 113+nAjusTela,185 MsGet oCarga   Var cCarga     Size 030,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 113+nAjusTela,266 MsGet oDtAct   Var dDtAct     Size 041,010                   COLOR CLR_BLACK Font oFontNeg Picture "@D 99/99/9999" PIXEL OF oDlgCPed
@ 128+nAjusTela,082 MsGet oDtSai   Var dDtSai     Size 041,010                   COLOR CLR_BLACK Font oFontNeg Picture "@D 99/99/9999" PIXEL OF oDlgCPed
@ 128+nAjusTela,185 MsGet oMotor   Var cMotor     Size 121,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 143+nAjusTela,082 MsGet oTpRcb   Var cTpRcb     Size 223,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 158+nAjusTela,082 MsGet oNumTQ   Var cNumTQ     Size 041,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 158+nAjusTela,230 MsGet oNumNF   Var cNumNF     Size 045,010 Valid(fValNF())   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 158+nAjusTela,277 MsGet oSerNF   Var cSerNF     Size 010,010 Valid(fValNF())   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 173+nAjusTela,082 GET oObs1      Var cObs1 MEMO Size 223,027 Valid(fValMemo())                 Font oFontNeg                         PIXEL OF oDlgCPed
@ 203+nAjusTela,082 MsGet oVend    Var cVend      Size 041,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 203+nAjusTela,125 MsGet oNomVend Var cNomVend   Size 181,010                   COLOR CLR_BLACK Font oFontNeg Picture "@!"            PIXEL OF oDlgCPed
@ 218+nAjusTela,082 GET oObs2      Var cObs2 MEMO Size 223,027 READONLY                          Font oFontGrd                         PIXEL OF oDlgCPed
&&@ 248,082 Get oObsDev    Var _cObsDev MEMO  Size 223,025               COLOR CLR_RED   Font oFontGrd Picture "@!"            PIXEL OF oDlgCPed
oMGetObsDv := TMultiGet():New( 248,082,{|u| If(PCount()>0,_cObsDev:=u,_cObsDev)},oDlgCPed,223,025,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,)
          

// Cria ExecBlocks dos Componentes Padroes do Sistema
oSituac:lReadOnly     := .T.
oCNPJ:lReadOnly       := .T.
oNomCli:lReadOnly     := .T.
oDtPed:lReadOnly      := .T.
oDtVend:lReadOnly     := .T.
oDtLib:lReadOnly      := .T.
oDtCanc:lReadOnly     := .T.
oMotCanc:lReadOnly    := .T.
oDtPrg:lReadOnly      := .T.
oCarga:lReadOnly      := .T.

oDtAct:lReadOnly      := .T.
oMotor:lReadOnly      := .T.
//oTpRcb:lReadOnly    := .T.
//oDtBxP:lReadOnly    := .T.
//oNuRtc:lReadOnly    := .T.

oDtSai:lReadOnly      := .T.
oNumTQ:lReadOnly      := .T.
oNumNF:lReadOnly      := .T.
oVend:lReadOnly       := .T.
oNomVend:lReadOnly    := .T.

ACTIVATE MSDIALOG oDlgCPed CENTERED

SetKey(12,Nil)
SetKey(16,Nil)

Return(.T.)




*+-------------------------------------------------------------------------+*
*|Funcao      | fBusPed  | Autor |  Cleverson Luiz Schaefer                |*
*+------------+------------------------------------------------------------+*
*|Data        | 11.12.2006                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Funcao para buscar as informacoes do pedido e apresenta-   |*
*|            | las na tela.                                               |*
*+------------+------------------------------------------------------------+*

Static Function fBusPed(pNumPed)
*************************
Local aArea    := GetArea()
Local cQuery1  := ""
Local cEol     := CHR(13)+CHR(10)

If Empty(pNumPed)
	RestArea(aArea)
	//oBtnSair:SetFocus()
	Return(.T.)
EndIf

cQuery1 := "SELECT SC5.C5_NUM    , " + cEol
cQuery1 += "       SA1.A1_COD    , " + cEol
cQuery1 += "       SC5.C5_XNPVORT, " + cEol
cQuery1 += "       SA1.A1_LOJA   , " + cEol
cQuery1 += "       SA1.A1_CGC    , " + cEol
cQuery1 += "       SA1.A1_NOME   , " + cEol
cQuery1 += "       SC5.C5_EMISSAO, " + cEol
cQuery1 += "       SC5.C5_XDTVEND, " + cEol
cQuery1 += "       SC5.C5_XDTLIB , " + cEol
cQuery1 += "       SC5.C5_XEMBARQ, " + cEol
cQuery1 += "       SC5.C5_XACERTO, " + cEol
cQuery1 += "       SC5.C5_XDTFECH, " + cEol
//cQuery1 += "     SC5.C5_NOTA   , " + cEol
//cQuery1 += "     SC5.C5_SERIE  , " + cEol

cQuery1 += "   (SELECT MAX(D2_DOC)                               " + cEol
cQuery1 += "    FROM SIGA."          + RETSQLNAME('SD2') + " SD2 " + cEol
cQuery1 += "   WHERE D_E_L_E_T_ = ' '                            " + cEol
cQuery1 += "     AND D2_FILIAL  = '" +    xFilial('SD2') + "'    " + cEol
cQuery1 += "     AND D2_PEDIDO  = SC5.C5_NUM) C5_NOTA,           " + cEol

cQuery1 += "   (SELECT MAX(D2_SERIE)                             " + cEol
cQuery1 += "    FROM SIGA."          + RETSQLNAME('SD2') + " SD2 " + cEol
cQuery1 += "   WHERE D_E_L_E_T_ = ' '                            " + cEol
cQuery1 += "     AND D2_FILIAL  = '" +    xFilial('SD2') + "'    " + cEol
cQuery1 += "     AND D2_PEDIDO  = SC5.C5_NUM) C5_SERIE,          " + cEol

cQuery1 += "         SC5.C5_VEND1             , " + cEol
cQuery1 += "         SC5.C5_XTELEMK           , " + cEol
cQuery1 += "         SC5.C5_XOPER             , " + cEol
cQuery1 += "         SC5.C5_XTPSEGM           , " + cEol
cQuery1 += "         SC5.C5_XOBSCAN           , " + cEol
cQuery1 += "         SC5.C5_XOBSADI           , " + cEol
cQuery1 += "         SC5.C5_XPEDREC           , " + cEol
cQuery1 += "         NVL(ZK_NUMRTC,' ') RTCATC, " + cEol
cQuery1 += "         SA3.A3_NOME              , " + cEol
cQuery1 += "	     SX5.X5_CHAVE             , " + cEol
cQuery1 += "         SX5.X5_DESCRI            , " + cEol

cQuery1 += "         NVL((SELECT SZE.R_E_C_N_O_                                       "
cQuery1 += "                FROM SIGA."                   + RETSQLNAME('SZE') + " SZE "
cQuery1 += "               WHERE D_E_L_E_T_          = ' '                            "
cQuery1 += "                 AND ZE_FILIAL           = '" +    XFILIAL('SZE') + "'    "
cQuery1 += "                 AND ZE_PEDIDO           = SC5.C5_NUM                     "
cQuery1 += "                 AND ZE_AUTORIZ          = 'BLQPNV'                       "
cQuery1 += "                 AND SUBSTR(ZE_OBS,1,12) = 'PROGRAMACAO!'),0) BLQPNV ,    "
cQuery1 += "         CASE WHEN C5_XTPSEGM = '7' THEN '2' ELSE '0' END ORDEM           "
cQuery1 += "    FROM SIGA." + RETSQLNAME('SC5') + " SC5,           "
cQuery1 += "         SIGA." + RETSQLNAME('SA1') + " SA1,           "
cQuery1 += "         SIGA." + RETSQLNAME('SZK') + " SZK,           "
cQuery1 += "         SIGA." + RETSQLNAME('SA3') + " SA3,           "
cQuery1 += "   	     SIGA." + RETSQLNAME('SX5') + " SX5            " + cEol
cQuery1 += "   WHERE SC5.D_E_L_E_T_   = ' '                          " + cEol
cQuery1 += "     AND SA1.D_E_L_E_T_   = ' '                          " + cEol
cQuery1 += "     AND SA3.D_E_L_E_T_(+)= ' '                          " + cEol
cQuery1 += "     AND SC5.C5_FILIAL    = '" + xFilial("SC5") + "'     " + cEol
cQuery1 += "     AND SA1.A1_FILIAL    = '" + xFilial("SA1") + "'     " + cEol
cQuery1 += "     AND SA3.A3_FILIAL(+) = '" + xFilial("SA3") + "'     " + cEol
if len(Alltrim(pNumPed))==6
	cQuery1 += " AND SC5.C5_NUM         = '" + pNumPed    + "'     " + cEol
else
	cQuery1 += " AND SC5.C5_XNPVORT     = '" + pNumPed    + "'     " + cEol
endif
// ------------------------------------------------------------------
cQuery1 += "     AND SC5.C5_TIPO       <> 'D'                      " + cEol
// ------------------------------------------------------------------
cQuery1 += "     AND SA1.A1_COD         = SC5.C5_CLIENTE           " + cEol
cQuery1 += "     AND SA1.A1_LOJA        = SC5.C5_LOJACLI           " + cEol
cQuery1 += "     AND SA3.A3_COD(+)      = SC5.C5_VEND1             "
cQuery1 += "     AND SZK.D_E_L_E_T_(+) <> '*'                      " + cEol
cQuery1 += "     AND SC5.C5_XMOTCAN     = X5_CHAVE (+)             "
cQuery1 += "     AND SX5.X5_TABELA (+)  = 'ZS'                     "
cQuery1 += "     AND ZK_FILIAL (+)      = '" + xFilial('SZK') + "' "
cQuery1 += "     AND ZK_PEDIDO (+)      = C5_NUM                   "
cQuery1 += "     AND ZK_cliente(+)      = C5_CLIENTE               "
cQuery1 += "     AND ZK_loja   (+)      = C5_LOJACLI               "
cQuery1 += "     AND ZK_OPERAC (+)      = 'AP'                     "
cQuery1 += "   UNION ALL                                           "
cQuery1 += "   SELECT SC5.C5_NUM        ,                          " + cEol
cQuery1 += "         SA2.A2_COD A1_COD  ,                          " + cEol
cQuery1 += "         SC5.C5_XNPVORT     ,                          " + cEol
cQuery1 += "         SA2.A2_LOJA A1_LOJA,                          " + cEol
cQuery1 += "         SA2.A2_CGC A1_CGC  ,                          " + cEol
cQuery1 += "         SA2.A2_NOME A1_NOME,                          " + cEol
cQuery1 += "         SC5.C5_EMISSAO     ,                          " + cEol
cQuery1 += "         SC5.C5_XDTVEND     ,                          " + cEol
cQuery1 += "         SC5.C5_XDTLIB      ,                          " + cEol
cQuery1 += "         SC5.C5_XEMBARQ     ,                          " + cEol
cQuery1 += "         SC5.C5_XACERTO     ,                          " + cEol
cQuery1 += "         SC5.C5_XDTFECH     ,                          " + cEol
//cQuery1 += "       SC5.C5_NOTA        ,                          " + cEol
//cQuery1 += "       SC5.C5_SERIE       ,                          " + cEol

cQuery1 += "   (SELECT MAX(D2_DOC)                                 " + cEol
cQuery1 += "    FROM SIGA."          + RETSQLNAME('SD2') + " SD2   " + cEol
cQuery1 += "   WHERE D_E_L_E_T_ = ' '                              " + cEol
cQuery1 += "     AND D2_FILIAL  = '" +    xFilial('SD2') + "'      " + cEol
cQuery1 += "     AND D2_PEDIDO  = SC5.C5_NUM) C5_NOTA,             " + cEol

cQuery1 += "   (SELECT MAX(D2_SERIE)                               " + cEol
cQuery1 += "    FROM SIGA."          + RETSQLNAME('SD2') + " SD2   " + cEol
cQuery1 += "   WHERE D_E_L_E_T_ = ' '                              " + cEol
cQuery1 += "     AND D2_FILIAL  = '" +    xFilial('SD2') + "'      " + cEol
cQuery1 += "     AND D2_PEDIDO  = SC5.C5_NUM) C5_SERIE,            " + cEol

cQuery1 += "         SC5.C5_VEND1  ,                               " + cEol
cQuery1 += "         SC5.C5_XTELEMK,                               " + cEol
cQuery1 += "         SC5.C5_XOPER  ,                               " + cEol
cQuery1 += "         SC5.C5_XTPSEGM,                               " + cEol
cQuery1 += "         SC5.C5_XOBSCAN,                               " + cEol
cQuery1 += "         SC5.C5_XOBSADI,                               " + cEol
cQuery1 += "         SC5.C5_XPEDREC,                               " + cEol
cQuery1 += "         NVL(ZK_NUMRTC ,' ') RTCATC,                   " + cEol
cQuery1 += "         SA3.A3_NOME   ,                               " + cEol
cQuery1 += "  	     SX5.X5_CHAVE  ,                               " + cEol
cQuery1 += "         SX5.X5_DESCRI ,                               " + cEol
cQuery1 += "         0 BLQPNV , '1' ORDEM                          "
cQuery1 += "    FROM SIGA." + RETSQLNAME('SC5') + " SC5,           "
cQuery1 += "         SIGA." + RETSQLNAME('SA2') + " SA2,           "
cQuery1 += "         SIGA." + RETSQLNAME('SZK') + " SZK,           "
cQuery1 += "         SIGA." + RETSQLNAME('SA3') + " SA3,           "
cQuery1 += "         SIGA." + RETSQLNAME('SX5') + " SX5            " + cEol
cQuery1 += "   WHERE SC5.D_E_L_E_T_     = ' '                      " + cEol
cQuery1 += "     AND SA2.D_E_L_E_T_     = ' '                      " + cEol
cQuery1 += "     AND SA3.D_E_L_E_T_(+)  = ' '                      " + cEol
cQuery1 += "     AND SC5.C5_FILIAL      = '" + xFilial('SC5') + "' " + cEol
cQuery1 += "     AND SA2.A2_FILIAL      = '" + xFilial('SA2') + "' " + cEol
cQuery1 += "     AND SA3.A3_FILIAL(+)   = '" + xFilial('SA3') + "' " + cEol
if len(Alltrim(pNumPed))==6
	cQuery1 += " AND SC5.C5_NUM         = '" + pNumPed        + "' " + cEol
else
	cQuery1 += " AND SC5.C5_XNPVORT     = '" + pNumPed        + "' " + cEol
endif
// ------------------------------------------------------------------
cQuery1 += "     AND SC5.C5_TIPO        = 'D'                      " + cEol
// ------------------------------------------------------------------
cQuery1 += "     AND SA2.A2_COD         = SC5.C5_CLIENTE           " + cEol
cQuery1 += "     AND SA2.A2_LOJA        = SC5.C5_LOJACLI           " + cEol
cQuery1 += "     AND SA3.A3_COD(+)      = SC5.C5_VEND1             "
cQuery1 += "     AND SZK.D_E_L_E_T_(+) <> '*'                      " + cEol
cQuery1 += "     AND SC5.C5_XMOTCAN     = X5_CHAVE (+)             "
cQuery1 += "     AND SX5.X5_TABELA (+)  = 'ZS'                     "
cQuery1 += "     AND ZK_FILIAL (+)      = '" + xFilial('SZK') + "' "
cQuery1 += "     AND ZK_PEDIDO (+)      = C5_NUM                   "
cQuery1 += "     AND ZK_cliente(+)      = C5_CLIENTE               "
cQuery1 += "     AND ZK_loja   (+)      = C5_LOJACLI               "
cQuery1 += "     AND ZK_OPERAC (+)      = 'AP' ORDER BY ORDEM      "

If Select("TSC5") > 0
	TSC5->(DbCloseArea())
EndIf

MemoWrite("C:\ORTA065A.sql",cQuery1)

TCQUERY cQuery1 ALIAS "TSC5" NEW
                                                            
fLimpVar()
Dbselectarea("TSC5")
If Eof()
	MsgBox("Pedido Invalido! Verifique...","Atencao","ALERT")
	Return(.F.)
EndIf

//Verifica se houve devolução
//Esta query está com erro
/*
cQry:="SELECT D1_DOC, D1_SERIE, QTDVEND, nvl(SUM(D1_QUANT),0) QTDDEV, D1_DTDIGIT, "
cQry+="       SUM(CASE WHEN D1_TES IN ("+GETNEWPAR("MV_XTESNCA","'350','351'")+") THEN 1 ELSE 0 END) TOTNCA  "
cQry+="  FROM (SELECT D2_SERIE,                                          "
cQry+="               D2_DOC,                                            "
cQry+="               D2_ITEM,                                           "
cQry+="               d2_cliente,                                        "
cQry+="               d2_loja,                                           "
cQry+="               SUM(D2_QUANT) QTDVEND                              "
cQry+="          FROM SD2030                                             "
cQry+="         WHERE D_E_L_E_T_ = ' '                                   "
cQry+="           AND D2_FILIAL = '02'                                   "
cQry+="           AND D2_PEDIDO = '"+TSC5->C5_NUM+"' "                   "
cQry+="         GROUP BY D2_SERIE, D2_DOC, D2_ITEM, d2_cliente, d2_loja),"
cQry+="       SD1030                                                     "
cQry+="WHERE d2_doc = d1_nfori(+)                                        "
cQry+="  AND d2_serie = d1_seriori(+)                                    "
cQry+="  AND d2_item = d1_itemori(+)                                     "
cQry+="  AND d2_cliente = d1_fornece(+)                                  "
cQry+="  AND d2_loja = d1_loja(+)                                        "
cQry+="GROUP BY D1_DOC, D1_SERIE, QTDVEND, D1_DTDIGIT                    "
*/
__cQry	:=	"SELECT d1_doc,d1_serie,d1_dtdigit, f1_doc, f1_serie, f1_tipo,f1_especie,f1_emissao,(CASE WHEN D1_TES IN ("+GETNEWPAR("MV_XTESNCA","'350','351'")+") THEN 1 ELSE 0 END) TOTNCA , "
__cQry	+=	"       (SELECT SUM (d1_total+d1_icmsret+d1_valipi) "
__cQry	+=	"          FROM Siga."+RetSqlName("SD1")
__cQry	+=	"         WHERE d1_filial = '"+xFilial("SD1")+"' "
__cQry	+=	"           AND d_e_l_e_t_ = ' ' "
__cQry	+=	"           AND d1_doc = d1.d1_doc "
__cQry	+=	"           AND d1_serie = d1.d1_serie "
__cQry	+=	"           AND d1_fornece = d1.d1_fornece "
__cQry	+=	"           AND d1_loja = d1.d1_loja) valdev, "
__cQry	+=	"       (SELECT SUM (d1_quant) "
__cQry	+=	"          FROM Siga."+RetSqlName("SD1")
__cQry	+=	"         WHERE d1_filial = '"+xFilial("SD1")+"' "
__cQry	+=	"           AND d_e_l_e_t_ = ' ' "
__cQry	+=	"           AND d1_doc = d1.d1_doc "
__cQry	+=	"           AND d1_serie = d1.d1_serie "
__cQry	+=	"           AND d1_fornece = d1.d1_fornece "
__cQry	+=	"           AND d1_loja = d1.d1_loja) qtddev, "
__cQry	+=	"       (SELECT SUM (d2_quant) "
__cQry	+=	"          FROM Siga."+RetSqlName("SD2")
__cQry	+=	"         WHERE d2_filial = '"+xFilial("SD2")+"' "
__cQry	+=	"           AND d_e_l_e_t_ = ' ' "
__cQry	+=	"           AND d2_doc = d2.d2_doc "
__cQry	+=	"           AND d2_serie = d2.d2_serie "
__cQry	+=	"           AND d2_cliente = d2.d2_cliente "
__cQry	+=	"           AND d2_loja = d2.d2_loja) qtdvend "
__cQry	+=	"  FROM Siga."+RetSqlName("SD2")+" d2, Siga."+RetSqlName("SD1")+" d1, Siga."+RetSqlName("SF1")+" f1 "
__cQry	+=	" WHERE d1_filial = '"+xFilial("SD1")+"' "
__cQry	+=	"   AND f1_filial = '"+xFilial("SF1")+"' "
__cQry	+=	"   AND d2_filial = '"+xFilial("SD2")+"' "
__cQry	+=	"   AND d2.d_e_l_e_t_ = ' ' "
__cQry	+=	"   AND d1.d_e_l_e_t_ = ' ' "
__cQry	+=	"   AND f1.d_e_l_e_t_ = ' ' "
__cQry	+=	"   AND d2_pedido = '"+TSC5->C5_NUM+"' "
__cQry	+=	"   AND d1_dtdigit <= '"+TSC5->C5_XDTFECH+"' "
__cQry	+=	"   AND d2_doc = d1_nfori "
__cQry	+=	"   AND d2_serie = d1_seriori "
__cQry	+=	"   AND d2_item = d1_itemori "
__cQry	+=	"   AND d2_cliente = d1_fornece "
__cQry	+=	"   AND d2_loja = d1_loja "
__cQry	+=	"   AND d1_doc = f1_doc "
__cQry	+=	"   AND d1_serie = f1_serie "
__cQry	+=	"   AND d1_fornece = f1_fornece "
__cQry	+=	"   AND d1_loja = f1_loja "
&&__cQry	+=	"   AND ROWNUM = 1 "
MemoWrite("C:\ORTA065Dev.sql",__cQry)

If Select("DEV") > 0
	DEV->(dbCloseArea())
EndIf

TCQUERY __cQry ALIAS "DEV" NEW

DbSelectArea("DEV")

_cObsDev:=""
While ! DEV->(EOF())
	If	DEV->QTDDEV = DEV->QTDVEND
		If DEV->TOTNCA > 0
			_cObsDev += "Não Carregado Total (NF: "+DEV->D1_DOC+"-"+DEV->D1_SERIE+"-"+DTOC(STOD(DEV->D1_DTDIGIT))+") Valor: "+Transform(DEV->VALDEV,"@E 999,999,999.99") + cEol
		Else
			_cObsDev += "Devolução Total (NF: "+DEV->D1_DOC+"-"+DEV->D1_SERIE+"-"+DTOC(STOD(DEV->D1_DTDIGIT))+") Valor: "+Transform(DEV->VALDEV,"@E 999,999,999.99") + cEol
		Endif
	Else
		If DEV->TOTNCA > 0
			_cObsDev += "Não Carregado Parcial NC (NF: "+DEV->D1_DOC+"-"+DEV->D1_SERIE+"-"+DTOC(STOD(DEV->D1_DTDIGIT))+") Valor: "+Transform(DEV->VALDEV,"@E 999,999,999.99") + cEol
		Else
			_cObsDev += "Devolução Parcial (NF: "+DEV->D1_DOC+"-"+DEV->D1_SERIE+"-"+DTOC(STOD(DEV->D1_DTDIGIT))+") Valor: "+Transform(DEV->VALDEV,"@E 999,999,999.99") + cEol
		Endif
    Endif
    DEV->(DbSkip())
End


DEV->(DbCloseArea())


Dbselectarea("TSC5")

cNumPed  := TSC5->C5_NUM
cNumPedC := TSC5->C5_XNPVORT
cCodCli  := TSC5->A1_COD
cLojCli  := TSC5->A1_LOJA
dDtPed	 := STOD(TSC5->C5_EMISSAO)
dDtVend	 := STOD(TSC5->C5_XDTVEND)
cCNPJ	 := TRANSFORM(TSC5->A1_CGC,"@R 99.999.999/9999-99")
cNomCli	 := SUBSTR(TSC5->A1_NOME,1,30)
cNomVend := SUBSTR(TSC5->A3_NOME,1,22)+"-"+TSC5->C5_XTELEMK
cNumNF	 := TSC5->C5_NOTA
cSerNF   := SUBSTR(TSC5->C5_SERIE,1,3)
cObs1	 := AllTrim(TSC5->C5_XOBSCAN) +IIf(Len(AllTrim(TSC5->C5_XOBSCAN))>0,cEol,"")+ AllTrim(TSC5->C5_XOBSADI)

if TSC5->BLQPNV > 0
	_cObsDev+= iif(!empty(_cObsDev),cEol,"")+"Retorno da Programação com PEN vencida a mais de 21 dias."
endif

cNumTQ	 := POSICIONE("SE3",4,XFILIAL("SE3") + TSC5->C5_NUM,"E3_XNUMGER")

cQuery := " SELECT E3_XNUMGER FROM SIGA."+RETSQLNAME("SE3")+" SE3 "
cQuery += " WHERE D_E_L_E_T_ = ' ' "
cQuery += " AND E3_FILIAL = '"+XFILIAL("SE3")+"'"
cQuery += " AND E3_PEDIDO = '"+TSC5->C5_NUM+"'  "
cQuery += " AND E3_CODCLI = '"+TSC5->A1_COD+"'  "   
cQuery += " AND E3_LOJA   = '"+TSC5->A1_LOJA+"' "   
//cQuery += " AND E3_VEND   = '"+TSC5->C5_VEND1+"'"
If Select("TE3") > 0
	TE3->(DbCloseArea())
EndIf
		
TCQUERY cQuery ALIAS "TE3" NEW

IF !EOF()
	cNumTQ := TE3->E3_XNUMGER
ENDIF

DBSELECTAREA("TE3")
DBCLOSEAREA()

	
cObs2	 := ""
cSituac	 := SUBSTR(POSICIONE("SX5",1,XFILIAL("SX5") + "DJ" + TSC5->C5_XOPER,"X5_DESCRI"),1,20)
cVend	 := SUBSTR(TSC5->C5_VEND1,1,6)

dDtAct	 := STOD(TSC5->C5_XACERTO) //Incluido Antonio Carmo

If ALLTRIM(TSC5->C5_XOPER) == "99"
	dDtCanc	 := STOD(TSC5->C5_XDTLIB)
	cMotCanc := trim(TSC5->X5_CHAVE) + " - " +Capital(Trim(TSC5->X5_DESCRI))
Else
	dDtLib	 := STOD(TSC5->C5_XDTLIB)
EndIf
CMOTOR:=""
DbSelectArea("SZQ")
dbOrderNickName("CSZQ1")
If DbSeek(xFilial("SZQ") + TSC5->C5_XEMBARQ)
	dDtPrg	 := SZQ->ZQ_DTPREVE
	dDtSai	 := SZQ->ZQ_DTEMBAR
	cCarga	 := SZQ->ZQ_EMBARQ
	IF !EMPTY(SZQ->ZQ_TRANSP)
	cMotor	 := POSICIONE("SA4",1,xFilial("SA4")+SZQ->ZQ_TRANSP,"A4_COD")
	cMotor	 += " - "+ALLTRIM(POSICIONE("SA4",1,xFilial("SA4")+SZQ->ZQ_TRANSP,"A4_NOME"))
	cMotor	 := SUBSTR(cMotor,1,35)
	ENDIF
EndIf




IF  TSC5->C5_XDTFECH <> ' '
	IF TSC5->C5_XTPSEGM $('3','4') .AND. TSC5->C5_XOPER $ ('01','04','10','12','13')
		cQuery := "SELECT COUNT(SD1.R_E_C_N_O_) DEV FROM "+RetSqlName("SD1")+" SD1 "
		cQuery += "WHERE SD1.D_E_L_E_T_ = ' ' AND SD1.D1_FILIAL = '"+xFilial("SD1")+"' "
		cQuery += "AND D1_NFORI = '"+TSC5->C5_NOTA+"' AND D1_SERIORI = '"+TSC5->C5_SERIE+"' "
		cQuery += "AND D1_FORNECE = '"+TSC5->A1_COD+"' AND D1_LOJA = '"+TSC5->A1_LOJA+"' "
		cQuery += "AND D1_TIPO IN('B',   'D')    "
		
		If Select("TD1") > 0
			TD1->(DbCloseArea())
		EndIf
		
		TCQUERY cQuery ALIAS "TD1" NEW
		
		IF TD1->DEV > 0
			cTpRcb := "DEVOLUÇÃO LOJA - ACERTO FECHADO EM "+DTOC(STOD(TSC5->C5_XDTFECH))	
		ELSE
		   cTpRcb := "LOJA - ACERTO FECHADO EM "+DTOC(STOD(TSC5->C5_XDTFECH))	
		ENDIF


	ELSEIF TSC5->C5_XOPER $ ('02','03','17')
		cQuery := "SELECT COUNT(SD1.R_E_C_N_O_) DEV FROM "+RetSqlName("SD1")+" SD1 "
		cQuery += "WHERE SD1.D_E_L_E_T_ = ' ' AND SD1.D1_FILIAL = '"+xFilial("SD1")+"' "
		cQuery += "AND D1_NFORI = '"+TSC5->C5_NOTA+"' AND D1_SERIORI = '"+TSC5->C5_SERIE+"' "
		cQuery += "AND D1_FORNECE = '"+TSC5->A1_COD+"' AND D1_LOJA = '"+TSC5->A1_LOJA+"' "
		cQuery += "AND D1_TIPO = 'D'    "
//		cQuery += "AND D1_TIPO IN('B',   'D')    " // Alterado por dupim em 08/12/09 Notas do tipo B sao para troca efetuada
		
		If Select("TD1") > 0
			TD1->(DbCloseArea())
		EndIf
		
		TCQUERY cQuery ALIAS "TD1" NEW
		
		IF TD1->DEV > 0
			cTpRcb := "DEVOLUÇÃO TROCA - ACERTO FECHADO EM "+DTOC(STOD(TSC5->C5_XDTFECH))	
		ELSE
			cTpRcb := "TROCA - ACERTO FECHADO EM "+DTOC(STOD(TSC5->C5_XDTFECH))	
		ENDIF
	ELSEIF TSC5->C5_XOPER = '07'
		cTpRcb := "CONSIGNAÇÃO - ACERTO FECHADO EM "+DTOC(STOD(TSC5->C5_XDTFECH))	
	ELSEIF TSC5->c5_XOPER == '08'
		cTpRcb = "REPOSIÇÃO - ACERTO FECHADO EM "+DTOC(STOD(TSC5->C5_XDTFECH))	
	ELSEIF TSC5->c5_XOPER == '05'
		cTpRcb = "BONIFICAÇÃO - ACERTO FECHADO EM "+DTOC(STOD(TSC5->C5_XDTFECH))	
	ELSEIF TSC5->c5_XPEDREC <> " "
		cTpRcb = "PEDIDO RECEBEDOR "+TSC5->c5_XPEDREC+" - ACERTO FECHADO EM "+DTOC(STOD(TSC5->C5_XDTFECH))	
	ELSEIF TSC5->RTCATC <> " "
		cTpRcb = "PEDIDO ANTECIPADO RTC: "+TSC5->RTCATC+" - ACERTADO FECHADO EM "+DTOC(STOD(TSC5->C5_XDTFECH))	
	ELSE
		DbSelectArea("SZB")
dbOrderNickName("CSZB4")
		If DbSeek(xFilial("SZB") + TSC5->C5_NUM)
			cTpRcb	 := SUBSTR(POSICIONE("SX5",1,XFILIAL("SX5") + "05" + SZB->ZB_TPOPER,"X5_DESCRI"),1,20)+" - ACERTO FECHADO EM "+DTOC(STOD(TSC5->C5_XDTFECH))	
			IF SZB->ZB_TPOPER = "PEN"
				cQuery := "SELECT E1_BAIXA,ZK_NUMRTC,E1_SALDO,E1_VALOR "
				cQuery += "  FROM "+RetSqlName("SE1")+" SE1, "+RetSQLName("SZK")+" SZK "
				cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "
				cQuery += "   AND SZK.D_E_L_E_T_ = ' ' "
				cQuery += "   AND E1_FILIAL = '"+xFilial("SE1")+"' "
				cQuery += "   AND ZK_FILIAL = '"+xFilial("SZK")+"' "
				cQuery += "   AND E1_TIPO = 'PEN'
				cQuery += "   AND E1_BAIXA <> ' '
				cQuery += "   AND E1_PEDIDO = '"+TSC5->C5_NUM+"' "
				cQuery += "   AND ZK_FILIAL = E1_FILIAL
				cQuery += "   AND ZK_PREFIXO = E1_PREFIXO "
				cQuery += "   AND ZK_NUMTIT = E1_NUM "
				cQuery += "   AND ZK_TIPO = E1_TIPO "
				
				If Select("TE1") > 0
					TE1->(DbCloseArea())
				EndIf
				
				TCQUERY cQuery ALIAS "TE1" NEW
				
				if TE1->E1_BAIXA <> ' '
					IF TE1->E1_SALDO < TE1->E1_VALOR .AND. TE1->E1_SALDO > 0
						cTpRcb := alltrim(cTpRcb)+" BAIXADO PARCIAL EM: "+DTOC(STOD(TE1->E1_BAIXA))+" RTC: "+TE1->ZK_NUMRTC
					ENDIF
					IF TE1->E1_SALDO = 0
						cTpRcb := alltrim(cTpRcb)+" BAIXADO EM: "+DTOC(STOD(TE1->E1_BAIXA))+" RTC: "+TE1->ZK_NUMRTC
					ENDIF
				ELSE
					cTpRcb := alltrim(cTpRcb)+" NAO BAIXADO"
				ENDIF
			ENDIF
		EndIf
	ENDIF
ELSE
	IF  TSC5->C5_XACERTO = ' '	.And. !EMPTY(CMOTOR)
		CTPRCB := "ACERTO NAO REALIZADO "
	ElseIf	TSC5->C5_XDTFECH = ' '	.And.	TSC5->C5_XACERTO <> ' '
		CTPRCB := "FECHAMENTO DO ACERTO NAO REALIZADO "
	Else
		CTPRCB := " "
	Endif
ENDIF


DbSelectArea("SC6")
dbOrderNickName("PSC61")
DbSeek(xFilial("SC6") + cNumPed)
While !Eof() .And. ALLTRIM(SC6->C6_NUM) == ALLTRIM(cNumPed)
	If !Empty(SC6->C6_XOBS)
		cObs2 += ALLTRIM(SC6->C6_XOBS) + CHR(13) + CHR(10)
	EndIf
	DbSkip()
EndDo


Dbselectarea("TSC5")

TSC5->(DbCloseArea())

If	Val(cCarga)	>= 500000
	__cCanc	:=	"Cancelado"
	cNumNF  := "******"
	cSerNF  := "***"
Else
	__cCanc	:=	""
Endif
oDlgCPed:Refresh()
oObs1:SetFocus()
RestArea(aAreA)
Return




*+-------------------------------------------------------------------------+*
*|Funcao      | fValMemo | Autor |  Cleverson Luiz Schaefer                |*
*+------------+------------------------------------------------------------+*
*|Data        | 11.12.2006                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Funcao para validar o numero de caracteres digitados no    |*
*|            | campo de Observacoes, que esta habilitado para digitacao.  |*
*+------------+------------------------------------------------------------+*

Static Function fValMemo()
**************************
Local aArea    := GetArea()
If Len(Alltrim(cObs1)) > 500
	MsgBox("Numero de caracteres " + ALLTRIM(STR(Len(Alltrim(cObs1)))) + " excedeu ao permitido(500)! Favor verificar...","Alerta","ALERT")
	RestArea(aArea)
	Return(.F.)
EndIf
RestArea(aArea)
Return(.T.)




*+-------------------------------------------------------------------------+*
*|Funcao      | fGrvObs  | Autor |  Cleverson Luiz Schaefer                |*
*+------------+------------------------------------------------------------+*
*|Data        | 11.12.2006                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Funcao que executa a gravacao das observacoes digitadas    |*
*|            | durante a consulta.                                        |*
*+------------+------------------------------------------------------------+*

Static Function fGrvObs()
*************************
Local aArea    := GetArea()
DbSelectArea("SC5")
dbOrderNickName("PSC51")
If DbSeek(xFilial("SC5") + cNumPed)
	RecLock("SC5",.F.)
	SC5->C5_XOBSADI := Alltrim(cObs1)
	MsUnLock()
EndIf
RestArea(aArea)
Return(.T.)




*+-------------------------------------------------------------------------+*
*|Funcao      | fLimpVar | Autor |  Cleverson Luiz Schaefer                |*
*+------------+------------------------------------------------------------+*
*|Data        | 11.12.2006                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Funcao para limpar o buffer das variaveis de memoria uti-  |*
*|            | lizadas na tela de consulta.                               |*
*+------------+------------------------------------------------------------+*

Static Function fLimpVar()
**************************
cCarga	 := Space(25)
cCNPJ	 := Space(25)
cMotCanc := Space(25)
cNomCli	 := Space(25)
cNomVend := Space(25)
cNumNF	 := Space(25)
cNumTQ	 := Space(6)
cNumPed  := Space(6)
cNumPedC := Space(7)
cObs1	 := ""
cObs2	 := ""
cSituac	 := Space(25)
cVend	 := Space(25)
dDtCanc	 := CtoD("/ /")
dDtLib	 := CtoD("/ /")
dDtPrg	 := CtoD("/ /")
dDtSai	 := CtoD("/ /")
dDtPed	 := CtoD("/ /")
dDtVend	 := CtoD("/ /")
cCodCli  := Space(6)
cLojCli  := Space(2)
cSerNF   := Space(3)
dDtAct	 := CtoD("/ /")
cMotor	 := Space(35)
cTpRcb	 := Space(100)
__cCanc	 :=	""
_cObsDev := ""	
oNumPed  :SetFocus()
Return



*+-------------------------------------------------------------------------+*
*|Funcao      | fImpCons | Autor |  Cleverson Luiz Schaefer                |*
*+------------+------------------------------------------------------------+*
*|Data        | 18.12.2006                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Funcao que imprime a consulta de tela executada.           |*
*|            |                                                            |*
*+------------+------------------------------------------------------------+*

Static Function fImpCons()
**************************
If Empty(cNumPed)
	MsgBox("O campo PEDIDO esta em branco ou é inválido! Não será possivel imprimir a Consulta","Atenção","ALERT")
	Return()
EndIf

Private cDesc1       := "Impressao das informacoes da tela de consulta de"
Private cDesc2       := "Pedidos."
Private cDesc3       := ""
Private cPict        := ""
Private titulo       := "Consulta de Pedidos"
Private imprime      := .T.
Private aOrd         := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private nlimite      := 80
Private tamanho      := "P"
Private nomeprog     := "ORTA065"
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "ORTA006"
Private cString      := ""
Private Cabec1       := ""
Private Cabec2	     := ""
Private lAvalImp     := .T.
Private cpedido

Private cString 	:= "SC6"
Private nPdf		:= 0
Private nPdf2		:= 0
Private nLin        := 3200 //2300 paisagem e 3200 retrato
Private nEsp		:= 50   //espacamento entre linhas
Private nEsp2		:= 60   //espacamento entre linhas
Private nEsp3		:= 75   //espacamento entre linhas
Private MaxLin		:= 3200 //limite para salto de pagina 2300 paisagem e 3200 retrato
Private cNomFil		:= ""
Private oPrn
Private nPag		:= 1

dbSelectArea("SM0")
dbSeek(cEmpAnt)
cNomFil := SM0->M0_FILIAL

oFont1:= TFont():New("Courier New",,11,,.T.)
oFont2:= TFont():New("Courier New",,14,,.T.)
oFont3:= TFont():New("Courier New",,12,,.T.)
oFont4:= TFont():New("Courier New",,16,,.T.)
oPrn:= TReport():New("ORTA065",Titulo,,{|oPrn| RunReport(oPrn)},Titulo)
oPrn:HideHeader() //oculta cabeçalho
oPrn:HideFooter() //oculta rodapé
//oPrn:SetLandscape()    //   SETA A PAGINA COMO PADRAO PAISAGEM
oPrn:SetPortrait()    //   SETA A PAGINA COMO PADRAO PAISAGEM
oPrn:oPage:nPaperSize == 9
//oPrn:DisableOrietation()
oPrn:SetEdit(.F.)         // Bloqueia personalizar
oPrn:NoUserFilter()       // nao permite criar FIltro de usuario
oPrn:PrintDialog()

if oPrn:Cancel()
	Return
EndIf

FreeObj(oPrn)
oPrn := Nil
Return

/*
wnrel := SetPrint(cString,NomeProg,,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,,Tamanho)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport() },Titulo)
Return
*/


*+-------------------------------------------------------------------------+*
*|Funcao      | RunReport | Autor |  Cleverson Luiz Schaefer               |*
*+------------+------------------------------------------------------------+*
*|Data        | 18.12.2006                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Funcao que executa o processamento da impressao.           |*
*|            |                                                            |*
*+------------+------------------------------------------------------------+*

Static Function RunReport()
***************************
Local cOBsImp := ""
Local nI := 0

nLin := fCabec()

oPrn:Say(nLin,0010,"Pedido               : "  + Substr(cNumPed,1,6),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Situacao             : "  + Substr(cSituac,1,20),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"CGC/CNPJ             : "  + Substr(cCNPJ,1,18),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Codigo/Loja Cliente  : "  + Substr(cCodCli,1,6) + " / " + Substr(cLojCli,1,2),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Nome do Cliente      : "  + Substr(cNomCli,1,40),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Data do Pedido       : "  + DTOC(dDtPed),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Data da Venda        : "  + DTOC(dDtVend),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Data da Liberacao    : "  + DTOC(dDtLib),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Data do Cancelamento : "  + DTOC(dDtCanc),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Motivo Cancelamento  : "  + Substr(cMotCanc,1,55),oFont2)
If Len(ALLTRIM(Substr(cMotCanc,56,55))) > 0
nLin += nEsp
	oPrn:Say(nLin,0500,Substr(cMotCanc,56,55),oFont2)
EndIf
nLin += nEsp
oPrn:Say(nLin,0010,"Data da Programacao  : "  + DTOC(dDtPrg),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Numero da Carga      : "  + Substr(cCarga,1,6),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Tipo de Recebimento  : "  + alltrim(cTpRcb),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Data da Saida        : "  + DTOC(dDtSai),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Numero da TQ         : "  + Substr(cNumTQ,1,6),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Nota Fiscal/Serie    : "  + alltrim(Substr(cNumNf,1,9)) + " / " + Substr(cSerNf,1,3),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Observ. Internas     : ",oFont2)

nCol := 24*20
cObsImp := ALLTRIM(cObs1)

For nI := 1 To Len(cObsImp)
	If Substr(cObsImp,nI,1) <> CHR(13) .And. Substr(cObsImp,nI,1) <> CHR(10)
		oPrn:Say(nLin,nCol,UPPER(Substr(cObsImp,nI,1)),oFont2)
		nCol += 20
	Else
		If Substr(cObsImp,nI,2) = CHR(13)+CHR(10)
			nLin += nEsp
			nCol := 20
		EndIf
	EndIf
	If nCol > 2000
		nCol := 20
		nLin += nEsp
	EndIf
Next

nLin += nEsp*2
oPrn:Say(nLin,0010,"Vendedor             : "  + Substr(cVend,1,6) + "  " + Substr(cNomVend,1,30),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"Observ. Comercial    : "  + UPPER(Substr(cObs2,1,55)),oFont2)
If Len(ALLTRIM(Substr(cObs2,56,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(cObs2,56,80)),oFont2)
EndIf
If Len(ALLTRIM(Substr(cObs2,136,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(cObs2,136,80)),oFont2)
EndIf
If Len(ALLTRIM(Substr(cObs2,216,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(cObs2,216,80)),oFont2)
EndIf
If Len(ALLTRIM(Substr(cObs2,296,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(cObs2,296,80)),oFont2)
EndIf
If Len(ALLTRIM(Substr(cObs2,376,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(cObs2,376,80)),oFont2)
EndIf
If Len(ALLTRIM(Substr(cObs2,456,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(cObs2,456,80)),oFont2)
EndIf          

///////////////
// ssi 20827 //     
///////////////
nLin += nEsp*2

oPrn:Say(nLin,0010,"Observ. Diversas     : "  + UPPER(Substr(_cObsDev,1,55)),oFont2)
If Len(ALLTRIM(Substr(_cObsDev,56,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(_cObsDev,56,80)),oFont2)
EndIf
If Len(ALLTRIM(Substr(_cObsDev,136,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(_cObsDev,136,80)),oFont2)
EndIf
If Len(ALLTRIM(Substr(_cObsDev,216,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(_cObsDev,216,80)),oFont2)
EndIf
If Len(ALLTRIM(Substr(_cObsDev,296,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(_cObsDev,296,80)),oFont2)
EndIf
If Len(ALLTRIM(Substr(_cObsDev,376,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(_cObsDev,376,80)),oFont2)
EndIf
If Len(ALLTRIM(Substr(_cObsDev,456,80))) > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,UPPER(Substr(_cObsDev,456,80)),oFont2)
EndIf     

///

SET DEVICE TO SCREEN
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return
*+-------------------------------------------------------------------------+*
*|Funcao      | fBusPed  | Autor |  Cleverson Luiz Schaefer                |*
*+------------+------------------------------------------------------------+*
*|Data        | 11.12.2006                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Funcao para buscar as informacoes do pedido e apresenta-   |*
*|            | las na tela.                                               |*
*+------------+------------------------------------------------------------+*

Static Function fBusNf()
*************************
Local aArea    := GetArea()
Local cQuery1  := ""
Local cEol     := CHR(13)+CHR(10)

If Empty(cNota)
	RestArea(aArea)
	Return(.T.)
EndIf


cQuery1 := "SELECT DISTINCT D2_PEDIDO " + cEol
cQuery1 += "  FROM " + RETSQLNAME("SD2") + " SD2 "
cQuery1 += " WHERE SD2.D_E_L_E_T_ <> '*'" + cEol
cQuery1 += "   AND SD2.D2_FILIAL = '"+xFilial("SD2")+"'" + cEol
cQuery1 += "   AND SD2.D2_SERIE  = '"+cSerie+"'" + cEol
cQuery1 += "   AND SD2.D2_DOC    = '"+cNota+"'" + cEol

If Select("TSD2") > 0
	TSC5->(DbCloseArea())
EndIf

TCQUERY cQuery1 ALIAS "TSD2" NEW

Dbselectarea("TSD2")
If Eof() .and. !empty(cSerie) .and. !empty(cNota)
	MsgBox("Nota Fiscal Invalida! Verifique...","Atencao","ALERT")
	lRet:=.F.
else
if !eof()
cNumPed:=TSD2->D2_PEDIDO
lRet:=fBusPed(cNumPed)
endif	
EndIf
Return(lRet)



******************************
Static Function fCabec()
******************************
oPrn:EndPage()
oPrn:StartPage()
nLin := 50
oPrn:Box(nLin,0005,nLin+nEsp*4,2325)
nLin+=nEsp

oPrn:Say(nLin,0010,"HORA: " + Time() + " - (" + Nomeprog + ")",oFont2)
oPrn:Say(nLin,2015,"No FOLHA: " + strzero(nPag,3,0),oFont2)

nLin += nEsp
oPrn:Say(nLin,0100,PADC(titulo,100),oFont2)

oPrn:Say(nLin,0010,"EMPRESA: "+CEMPANT + " / Filial: " + substr(cNomFil,1,2),oFont2)
oPrn:Say(nLin,1910,"EMISSAO: "+dtoc(ddatabase),oFont2)
nLin += nEsp

nLin := 350
nPag+=1
Return(nLin)




