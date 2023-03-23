#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "RwMake.Ch"
#Include "SigaWin.Ch"
#include "colors.ch"
#include "font.ch"
#INCLUDE "JPEG.CH"
#INCLUDE "TBICONN.CH"


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ORTA349   ∫ Autor ≥ Antonio Carmo      ∫ Data ≥  26/01/07   ∫±±
±±                        Autor ≥ Wanderley Andrade  ∫ Data ≥  14/02/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ RelatÛrio de Mapa de comercializaÁ„o, desenvolvido conforme∫±±
±±∫          ≥ documentaÁ„o do cliente. COMERCIAL                         ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ Faturamento                                                ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function ORTA349


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Declaracao de Variaveis                                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "MAPA DE COMERCIALIZACAO"
Local cPict          := ""
Local titulo         := "MAPA COMERCIALIZACAO (COMERCIAL) "
Local imprime        := .T.
Local _cTab          := ""
Local _ctabela       := ""
Local _nPliq         := 0
Local _Sobrou        := 0

Local oGet1
Local oGroup1
Local oRadMenu1
Local oSay1
Local oSButton1
Local oSButton2

Local lF3SZ6PIL		:= .F.
Local cProj  		:= Space(6)
Local cGDTudoOk

Private aGets
Private aTela
Private cCadastro	:= titulo
Private cTudoOk := "AllwaysTrue" 

Private oFnt1:= TFont():New( "Arial",,-12,,.T.,,,,,.F. )
Private oFnt2:= TFont():New( "Arial",,-10,,.T.,,,,,.F. )


Private cPerg       := "ORTR048"
Private aOrd        := {"Por Codigo do Produto","Por DescriÁ„o do Produto","Por Medida"}
Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 220
Private tamanho     := "G"
Private nomeprog    := "ORTA349" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 15
Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "ORTA349" // Coloque aqui o nome do arquivo usado para impressao em disco
Private nControle   := .F.
Private nTVenda     := 0
Private nPreco      := 0
Private nPPrat      := 0
Private nTPrat      := 0
Private nPartFin    := 0
Private tnPartFin	:= 0.00
Private TtnPartFin	:= 0.00
Private nqtdmip 	:= 0.00
Private tnqtdmip 	:= 0.00
Private Ttnqtdmip	:= 0.00
Private nRentab1    := 0
Private nContrb1    := 0
Private aHeader	    := {}
Private aCols       := {}           
Private oGetD

Private oDlg01
Private aVetor      := {}
Private nTTotal     := 0
Private nTTTotal    := 0
Private nTQuant     := 0
Private nTTQuant    := 0
Private nTTVenda    := 0
Private nTTTVenda   := 0
Private nTPreco     := 0
Private nTPPrat     := 0
Private nTTPrat     := 0
Private nTTTPrat    := 0
Private nTPartFin   := 0
Private nTTPartFin  := 0
Private nTRentab1   := 0
Private nTContrb1   := 0
Private nTCusto     := 0
Private nTTCusto    := 0

Private cSegm       := ""
Private cSegment    := ""
Private aXProjecao  := {}
Private aXProjOrd   := {}
Private lAchou      := .F.
Private lAchou2     := .F.
Private nCount      := 0
Private nCount2     := 0

Private nRProj      := 0
Private nCProj      := 0
Private nPFProj     := 0

Private nTRProj     := 0
Private nTCProj     := 0
Private nTPFProj    := 0

Private nPartFin    := 0
Private nRentab1    := 0
Private nContrb1    := 0

Private nTTRProj    := 0
Private nTTCProj    := 0
Private nTTPFProj   := 0

Private nTTPProj    := 0
Private nTTPProj2   := 0
Private nTTVProj    := 0
Private nTTFProj    := 0

Private nTTTPProj   := 0
Private nTTTPProj2  := 0
Private nTTTVProj   := 0
Private nDifValor   := 0
Private nLin        := 050

Private nPosic      := 0
Private cTipo       := ""
//                 "|   CODIGO   |         DESCRICAO        | MEDIDA       | PECAS |"+MV_PAR28+" - "+MV_PAR29+"| A| N| D| FABRICA |    MP   |   (LB)   | "+MV_PAR21+"% |   FINAL |   PV | FIN. |RENTxO |MARKUP|PRECO   |DES/ACR|MARKUP|PRECO   |          |   DG    |   LUCRO  |LUCRO%|"
Private cLinha1 	:= "_____________________________________________________________________________________________________________________________________________________________________________________________________________________________________"
Private cLinha2 	:= "|            |                          |              |       |  PRECO  | F| Q|     PRECO  |         |          |        |         |      |      |       |      |        |                         PROJECAO                         |"
Private cLinha3 	:= "|            |                          |              |       |MARFIL   | I| U|    LIQUIDO |  CUSTO  |  SOBROU  |   DG   |   LUCRO |LUCRO%|PART. |CONTRIB|      |        |__________________________________________________________|"
//Private cLinha4 := "|   CODIGO   |         DESCRICAO        | MEDIDA       | PECAS |    -    | A| N| D| FABRICA |    MP   |   (LB)   |        |   FINAL |   PV | FIN. |RENTxO |MARKUP|PRECO   |DES/ACR|MARKUP|  PRECO |          |   DG    |   LUCRO  |LUCRO%|"
Private cLinha4 	:= "|   CODIGO   |         DESCRICAO        | MEDIDA       | PECAS |"+MV_PAR28+" - "+MV_PAR29+"  | N| A| D| FABRICA |    MP   |   (LB)   | "+TRAN(MV_PAR17,'@ER 99.99')+"% |   FINAL |   PV | FIN. |RENTxO |MARKUP|PRECO   |DES/ACR|MARKUP|  PRECO |          |   DG    |   LUCRO  |LUCRO%|"
Private cLinha5 	:= "|            |                          |              |       |(LIQUIDA)| N|  | E|         |         |          |        |         |      |      |       |      |UNITARIO|       | NOVO |UNITARIO|   SOBRA  | 47,35%  |   FINAL  |  PV  |"
Private cLinha6 	:= "|A)          |B)                        |C)            |D)     |E)       |F)|G)|H)|I)       |J)       |K)=I-J    |L)=IxDG |M)=K-L   |N)=M/I|(O)   |P)     |Q)=I/J|R)      |S)     |T)    |U)=RxS  |V)=U-J    |W)       |X)=V-L    |Y)=X/U|"
Private	cLinha7 	:= "__________________________________________________________________________________________________________________________________________________________________________________________________________________________________________"
//         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Private cString 	:= "SD2"

Private Odlg
Private oGetProj , oOpt
Private lInc , lCons:= .F.
Private cImage 	    := "logorto3.jpg"
Private aOpt   		:= {"Incluir","Consultar","Copiar ProjeÁ„o"}
Private nOpt   		:= 2

Private INCLUI 	   	:= .T.				// Variavel incluida devido ao gatilho do campo B1_COD
Private oMultiLine
Private aVetor    	:={}
Private aCols      	:={}
Private aHeader    	:={}


Private Ate
Private btok
Private oButton2
Private oChkCom
Private lChkCom 	:= .F.
Private oChkEsp
Private lChkEsp 	:= .F.
Private oChkInd
Private lChkInd 	:= .F.
Private oChkLExc
Private lChkLExc 	:= .F. //
Private oChkLoja
Private lChkLoja 	:= .t. //.F.
Private oChkOCom
Private lChkOCom 	:= .F.
Private oChkOInd
Private lChkOInd 	:= .F.
Private oChkSP
Private lChkSP 		:= .F.
Private oChkSBM
Private lChkSBM 	:= .F.
Private oChkFC
Private lChkFC 		:= .F.
Private oChkFL
Private lChkFL 		:= .T.
Private oImpDif
Private lImpDif		:= .f.

Private oChkRes
Private lChkRes 	:= .F.

Private oChkLRes
Private lChkLRes    := .F.

Private oMedper
Private lMedper     := .F. //mostra qtd media

Private oQtdZero
Private lQtdZero    := .F. //oculta itens com qtd zerada

Private oImptot
Private lImptot     := .F. //somente totais 

Private oChkPul
Private lChkPul 	:= .F.
Private oGetdT1
Private dEmis1 		:= stod(space(8))
Private oGet1Uf2
Private cUf2 		:= SPACE(2)
Private oGetAss
Private cAssis   	:= SPACE(6)
Private oGetCid1
Private cCid1 		:= SPACE(6)
Private oGetCid2
Private cCid2 		:= SPACE(6)
Private oGetCli1
Private cCli1 		:= SPACE(6)
Private oGetCli2
Private cCli2 		:= SPACE(6)
Private oGetDG
Private nDG 		:= 0
Private oGetDt2
Private dEmis2 		:= stod(space(8))
Private oGetExt
Private nDescExt 	:= 0
Private oGetFin
Private nFin 		:= 0
Private oGetParc1
Private cParc1 		:= SPACE(6)
Private oGetParc2
Private cParc2 		:= SPACE(6)
Private oGetProd1
Private cProd1 		:= SPACE(4)
Private oGetProd2
Private cProd2 		:= SPACE(4)
Private oGetQtd
Private nQtd 		:= 0
Private oGetRef
Private cRef 		:= SPACE(1)
Private oGetSegm1
Private cSegm1 		:= SPACE(1)
Private oGetSegm2
Private cSegm2 		:= SPACE(1)
Private oGetTab
Private cTab 		:= SPACE(3)
Private oGetUf1
Private cUf1 		:= SPACE(2)
Private oGetVend1
Private cVend1 		:= SPACE(6)
Private oGetVend2
Private cVend2      := SPACE(6)
Private oSay1       
Private oSay10
Private oSay11
Private oSay12
Private oSay13
Private oSay14
Private oSay15
Private oSay16
Private oSay26
Private oSay17
Private oSay18
Private oSay19
Private oSay2
Private oSay20
Private oSay21
Private oSay22
Private oSay23
Private oSay24
Private oSay25
Private oSay3
Private oSay4
Private oSay5
Private oSay6
Private oSay7
Private oSay8
Private oSay9
Private Produtos
Private Segmento
Private nX := 0
Private oDlgT
Private aGetAux1    := {"Z6_CODPROD","B1_XDESCEX","PB1_DESPRO","Z6_PRCDIG","Z6_PRCDA1","Z6_CUSTO","Z6_GUERES","Z6_MIX","B1_GRUPO"} //:= {"Z6_CODPROD","Z6_PRCDIG"}     //:= {"Z6_CODPROD","B1_XDESCEX","PB1_DESPRO","Z6_PRCDIG","Z6_PRCDA1"} //:= {"B1_COD","B1_XDESCEX","B1_DESC"} ","
Private aCpoGDa     := aGetAux1 //{"Z6_CODPROD","Z6_PRCDIG"}     //aGetAux1
Private aAlter     	:= {"Z6_CODPROD","Z6_PRCDIG"}     //aGetAux1

Private aResumo     := {}

Private cTp         := " "  // incluido dia 09/11/11

Private aRotina     := {}
       
Private nquantVd    := 0.00    
Private nvalupme    := 25.85
Private nZ6DESCPRO  :=  0.00 
Private ntotfinp    :=  0.00              
Private nnomegru    := space(15)
Private aitens      := {}
Private cfilemp     := substr(cNumEmp,1,2)+"0" 
                           
Private nmedper     := 0.00
Private nqtdgrup    := 0                

Private nttqtg      := 0.00 
Private nqtdsubgrup := 0                
      
Private cTpg        := " "

Private __cTab
Private __cRef
Private	aTConItens:= {}


Define Font oFont14Grd Name "Arial" Size 0,-18 Bold

aAdd( aRotina, {" "    		,'u_ORTB048',0,1})
aAdd( aRotina, {" "    		,'u_ORTB048',0,2})
aAdd( aRotina, {"Incluir"   ,'u_ORTB048',0,3})
aAdd( aRotina, {" "    		,'u_ORTB048',0,4})
aAdd( aRotina, {" "    		,'u_ORTB048',0,5})

//ValidPerg(cPerg)

/*
ValidPerg(cPerg)
pergunte(cPerg,.f.)


dEmis1 := MV_PAR01
dEmis2 := MV_PAR02
cAssis := MV_PAR03
cVend1 := MV_PAR04
cVend2 := MV_PAR05
cProd1 := MV_PAR06
cProd2 := MV_PAR07
cUf1   := MV_PAR08
cUf2   := MV_PAR09
cCid1  := MV_PAR10
cCid2  := MV_PAR11
cCli1  := MV_PAR12
cCli2  := MV_PAR13
cParc1 := MV_PAR14
cParc2 := MV_PAR15
nDg    := MV_PAR17
nFin   := MV_PAR18
nQtd   := MV_PAR19
nDescExt := MV_PAR20    // DESCONTO EXTRA
cTipo  := MV_PAR23
cTab   := MV_PAR24
cRef   := MV_PAR25
cProj  := MV_PAR26


/*
Define MsDialog oDlg Title OemToAnsi("Mapa de Comercializacao") From 000,000 to 180,400 Pixel
@ 003,005 to 060,190 Pixel
@ 007,009 RADIO aOpt var nOpt object oInc
@ 007,070 Say "Num. Projecao" Size 50,10 Pixel
@ 007,115 MsGet oGetProj Var cProj  PICTURE "@!" Size 020,008 valid fConsProj(cProj)  Pixel
@ 070,110 BmpButton Type 01 Action(iif((empty(cProj) .and. nOpt <> 3),Alert("Informe o numero da ProjeÁ„o, para consultas ou inclusoes, ou selecione a opÁ„o simular!"),u_MCONTATELA48(cProj,nOpt)))
@ 070,150 BmpButton Type 02 Action(Close(oDlg))

Activate Dialog oDlg centered
*/

SXB->( dbSetOrder( 1 ) ) //XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA
lF3SZ6PIL := SXB->( MsSeek("SZ6PIL" , .F. ) )

DEFINE MSDIALOG oDlg TITLE "Mapa de Comercializacao" FROM 000, 000  TO 200, 250 COLORS 0, 16777215 PIXEL

@ 006, 007 GROUP oGroup1 TO 053, 117 PROMPT "AÁ„o" OF oDlg COLOR 0, 16777215 PIXEL
@ 015, 011 RADIO oRadMenu1 VAR nOpt ITEMS "Incluir","Consultar/Alterar","Copiar ProjeÁ„o","Imprimir" SIZE 100, 032 OF oDlg COLOR 0, 16777215 PIXEL
@ 058, 040 MSGET oGet1 VAR cProj PICTURE "@!" SIZE 060, 012 valid fConsProj(cProj) OF oDlg COLORS 0, 16777215 PIXEL
IF (lF3SZ6PIL)
	oGet1:cF3 := "SZ6PIL"
EndIF
@ 060, 011 SAY oSay1 PROMPT "ProjeÁ„o" Font oFnt1 SIZE 025, 012 OF oDlg COLORS 0, 16777215 PIXEL
@ 075, 006 SAY oSay1 PROMPT "[9] Comercial - [99] Tabela - [99] Ano - [X] Ref." Font oFnt2 SIZE 180, 012 OF oDlg COLORS 0, 16777215 PIXEL

DEFINE SBUTTON oSButton2 FROM 086, 094 TYPE 01 Action(iif((empty(cProj) .and. nOpt <> 3),Alert("Informe o numero da ProjeÁ„o, para consultas ou inclusoes, ou selecione a opÁ„o Copiar!"),(close(oDlg),U_MCONTATELA48(cProj,nOpt)))) OF oDlg ENABLE
DEFINE SBUTTON oSButton1 FROM 086, 061 TYPE 02 Action(Close(oDlg)) OF oDlg ENABLE

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( UniqueKey() )

Return

Static Function ValidPerg(cPerg)

Local j:= 0
Local i:= 0
_sAlias := Alias()
aRegs := {}   //cria vetor em branco



AADD(aRegs,{"GRUPO","ORDEM","PERGUNT"                    ,"VARIAVL","TIPO","TAMANHO","DECIMAL","GSC","VALID","VAR01"   ,"F3" ,"GRPSXG","DEF01" ,"DEF02","DEF03","DEF04","DEF05"})
//aAdd(aRegs,{cPerg  ,"01"   ,"Data Emissao de :"          ,"MV_CH1" ,"D"   ,08       ,0        ,"G"  ,""     ,"mv_par01",""   ,""      ,""      ,""     ,""     ,""     ,""     })

aadd(aRegs,{cPerg  ,"01"   ,"Periodo de"                 ,"mv_ch1" ,"D"   ,08       ,0        ,"G"  ,""     ,"mv_par01",""   ,""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"02"   ,"Periodo ate"                ,"mv_ch2" ,"D"   ,08       ,0        ,"G"  ,""     ,"mv_par02",""   ,""      ,""      ,""     ,""     ,""     ,""     })

//----Incluido em 27/08/2007---------------------------------------------------------------------------------------------------------------------------------------------------------------------
aadd(aRegs,{cPerg  ,"03"   ,"Assistente"                 ,"mv_ch3" ,"C"   ,06       ,0        ,"G"  ,""     ,"mv_par03","SA3",""      ,""      ,""     ,""     ,""     ,""     })
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

aadd(aRegs,{cPerg  ,"04"   ,"Vendedor de"                ,"mv_ch4" ,"C"   ,06       ,0        ,"G"  ,""     ,"mv_par04","SA3",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"05"   ,"Vendedor ate"               ,"mv_ch5" ,"C"   ,06       ,0        ,"G"  ,""     ,"mv_par05","SA3",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"06"   ,"Linha Produto de"           ,"mv_ch6" ,"C"   ,04       ,0        ,"G"  ,""     ,"mv_par06","SBM",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"07"   ,"Linha Produto ate"          ,"mv_ch7" ,"C"   ,04       ,0        ,"G"  ,""     ,"mv_par07","SBM",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"08"   ,"U.F. de"                    ,"mv_ch8" ,"C"   ,02       ,0        ,"G"  ,""     ,"mv_par08","12" ,""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"09"   ,"U.F. ate"                   ,"mv_ch9" ,"C"   ,02       ,0        ,"G"  ,""     ,"mv_par09","12" ,""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"10"   ,"Cidade de"                  ,"mv_cha" ,"C"   ,06       ,0        ,"G"  ,""     ,"mv_par10","SZN",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"112"  ,"Cidade ate"                 ,"mv_chb" ,"C"   ,06       ,0        ,"G"  ,""     ,"mv_par11","SZN",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"12"   ,"Cliente de"                 ,"mv_chc" ,"C"   ,06       ,0        ,"G"  ,""     ,"mv_par12","SA1",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"13"   ,"Cliente ate"                ,"mv_chd" ,"C"   ,06       ,0        ,"G"  ,""     ,"mv_par13","SA1",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"14"   ,"Parceiro de"                ,"mv_che" ,"C"   ,06       ,0        ,"G"  ,""     ,"mv_par14","SA3",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"15"   ,"Parceiro ate"               ,"mv_chf" ,"C"   ,06       ,0        ,"G"  ,""     ,"mv_par15","SA3",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"16"   ,"Selecioar Prod.(S/N)"       ,"mv_chg" ,"N"   ,01       ,0        ,"C"  ,"IIF(MV_PAR16 == 1, U_pcar048(8, 'SB1'), .T.)","mv_par16" ,"","","Sim","N„o","","",""})

//----Incluido em 27/08/2007---------------------------------------------------------------------------------------------------------------------------------------------------------------------
aadd(aRegs,{cPerg  ,"17"   ,"Desconto Despesas Gerais %" ,"mv_chh" ,"N"   ,06       ,2        ,"G"  ,""     ,"mv_par17",""   ,""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"18"   ,"Desconto Financeiro      %" ,"mv_chi" ,"N"   ,02       ,0        ,"G"  ,""     ,"mv_par18",""   ,""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"19"   ,"Desconto Quantitavivo    %" ,"mv_chj" ,"N"   ,02       ,0        ,"G"  ,""     ,"mv_par19",""   ,""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"20"   ,"Desconto Extra           %" ,"mv_chk" ,"N"   ,02       ,0        ,"G"  ,""     ,"mv_par20",""   ,""      ,""      ,""     ,""     ,""     ,""     })
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
aadd(aRegs,{cPerg  ,"21"   ,"Segmento de"                ,"mv_chl" ,"C"   ,01       ,0        ,"G"  ,""     ,"mv_par21","SZA",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"22"   ,"Segmento ate"               ,"mv_chm" ,"C"   ,01       ,0        ,"G"  ,""     ,"mv_par22","SZA",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"23"   ,"Tipo de Produtos"           ,"mv_chn" ,"C"   ,05       ,0        ,"G"  ,"IIF(Empty(mv_par23), U_scelpro(), .T.)"      ,"mv_par23" ,"","","","","","",""})
aadd(aRegs,{cPerg  ,"24"   ,"Tabela de Vendas"           ,"mv_cho" ,"C"   ,03       ,0        ,"G"  ,""     ,"mv_par24","DA0",""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"25"   ,"Referencia da Tab.de Vendas","mv_chp" ,"C"   ,01       ,0        ,"G"  ,""     ,"mv_par25",""   ,""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"26"   ,"Numero da Projecao"         ,"mv_chq" ,"C"   ,06       ,0        ,"G"  ,""     ,"mv_par26",""   ,""      ,""      ,""     ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"27"   ,"Pulverizado"                ,"mv_chr" ,"N"   ,01       ,0        ,"C"  ,""     ,"mv_par27",""   ,""      ,"Sim"   ,"N„o"  ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"28"   ,"Especial"                   ,"mv_chs" ,"N"   ,01       ,0        ,"C"  ,""     ,"mv_par28",""   ,""      ,"Sim"   ,"N„o"  ,""     ,""     ,""     })
aadd(aRegs,{cPerg  ,"29"   ,"Super Vertical"             ,"mv_cht" ,"N"   ,01       ,0        ,"C"  ,""     ,"mv_par29",""   ,""      ,"Sim"   ,"N„o"  ,""     ,""     ,""     })
                                                               
//aadd(aRegs,{cPerg  ,"30"   ,"Somente Totais"             ,"mv_chu" ,"N"   ,01       ,0        ,"C"  ,""     ,"mv_par30",""   ,""      ,"Sim"   ,"N„o"  ,""     ,""     ,""     })

dbSelectArea("SX1")
dbSetOrder(1)

fCriaSx1(cPerg,aRegs)
//u__fAtuSx1(padr(cPerg,len(sx1->x1_grupo)),aRegs)
//cPerg := U_AjustaSx1(cPerg,aRegs)

dbSelectArea(_sAlias)

Return





************************************
Static Function fCriaSx1(cPerg,aSx1)
************************************
Local aArea   := GetArea()
Local aSx1B   := {}
Local aCampos := {}

Local nLin    := 1
Local nCol    := 1
Local nPar    := 0
Local nTam    := 0

Local lIgual  := .T.

Local cCampo  := ""

dbSelectArea("SX1")
SX1->(DbSetOrder(1))

If SX1->(dbSeek(cPerg))
	AADD( aSx1B, aSx1[1] )
	While SX1->(!Eof()) .And. AllTrim(cPerg) == AllTrim(SX1->X1_GRUPO)
		aCampos := {}
		For nCol := 1 To Len(aSX1[1])
			cCampo := "X1_"+aSX1[1,nCol]
			If cCampo == Nil
				Alert(aSX1[1,nCol])
			Else
				AADD(aCampos, &("SX1->"+cCampo) )
			EndIf
		Next
		
		AADD( aSx1B, aCampos )
		SX1->(dbSkip())
	End
	nPar := Len(aSx1B)
	nTam := Len(aSx1B[1])
	If Len(aSx1) == nPar
		For nLin := 1 To nPar
			For nCol := 1 To nTam
				If IF(VALTYPE(aSx1[nLin, nCol])=="C", AllTrim(aSx1[nLin, nCol]), aSx1[nLin, nCol]) <> IF(VALTYPE(aSx1B[nLin, nCol])=="C", AllTrim(aSx1B[nLin, nCol]), aSx1B[nLin, nCol])
					lIgual := .F.
					nCol   := nTam + 1
					nLin   := nPar + 1
				EndIf
			Next
		Next
	Else
		lIgual := .F.
	EndIf
	If !lIgual
		If dbSeek(cPerg)
			While SX1->(!Eof()) .And. AllTrim(cPerg) == AllTrim(SX1->X1_GRUPO)
				SX1->(RecLock("SX1", .F.))
				SX1->(dbDelete())
				SX1->(MsUnlock())
				SX1->(dbSkip())
			End
			For nLin := 2 To Len(aSX1)
				SX1->(RecLock("SX1",.T.))
				For nCol := 1 To Len(aSX1[1])
					cCampo := "X1_"+aSX1[1,nCol]
					SX1->(FieldPut(SX1->(FieldPos(cCampo)),aSx1[nLin,nCol] ))
				Next
				SX1->(MsUnLock())
			Next
		Endif
	EndIf
Else
	For nLin := 2 To Len(aSX1)
		SX1->(RecLock("SX1",.T.))
		For nCol := 1 To Len(aSX1[1])
			cCampo := "X1_"+aSX1[1,nCol]
			SX1->(FieldPut(SX1->(FieldPos(cCampo)),aSx1[nLin,nCol] ))
		Next
		SX1->(MsUnLock())
	Next
Endif
RestArea(aArea)
Return

**************************
Static Function fValProj(cProj,cProj2)
**************************
Local cMsg:=""
Local lRet:= .T.
Local cseg:= substr(cproj,1,1)
Local cref:= substr(cproj,6,1)
Local cref2:= substr(cproj2,6,1)

If cref <> "A" //.Or. cref2 <> "A"
	alert("Por determinaÁ„o da diretoria sÛ ser· permitido copiar a referÍncia A. Refencia Invalida: "+cRef+". PosiÁ„o 6")
	lRet:=.F.
EndIf

If empty(cProj) .and. !empty(cProj2)
	cMsg := "Informe a ProjeÁ„o de origem"
	ApMsgInfo(cMsg,"A T E N « √ O !!!")
	lRet:=.F.
ElseIf len(alltrim(cproj)) <> 6
	cMsg := "ProjeÁ„o de origem invalida"
	ApMsgInfo(cMsg,"A T E N « √ O !!!")
	lRet:=.F.
ElseIf len(alltrim(cproj2)) <> 6
	cMsg := "ProjeÁ„o de destino invalida"
	ApMsgInfo(cMsg,"A T E N « √ O !!!")
	lRet:=.F.
ElseIf substr(cProj,1,1)<>substr(cProj2,1,1)
	cMsg := "ProjeÁıes nao podem ser de segmentos diferentes"
	ApMsgInfo(cMsg,"A T E N « √ O !!!")
	lRet:=.F.
ElseIf cProj==cProj2
	cMsg := "Informe ProjeÁıes Diferentes"
	ApMsgInfo(cMsg,"A T E N « √ O !!!")
	lRet:=.F.
ElseIf cEmpAnt $ "23"
	If !(cref $ "A|B|C|D|E|F|G|H") .Or. !(cref2 $ "A|B|C|D|E|F|G|H")
		alert("O Segmento Comercial (2), apenas utilizam referencias A,B,C,D,E,F,G,H. Referencia Invalida!")
		lRet:=.F.
	EndIf
ElseIf cseg <> "4" .And. !(cref $ "A|B|C|D|E|M|N")
	alert("O Segmento Comercial (2), apenas utilizam referencias A,B,C,D e F. Referencia Invalida: "+cref+".")
	lRet:=.F.
ElseIf cseg <> "4" .And. !(cref2 $ "A|B|C|D|E|M|N")
	alert("O Segmento Comercial (2), apenas utilizam referencias A,B,C,D e F. Referencia Invalida: "+cref2+".")
	lRet:=.F.
ElseIf cseg == "4" .And. !(cref $ "F|G|H|I|J|K|L|M|N")
	alert("O Segmento de Exclusiva (4), apenas utilizam referencias F,G,H,I,J,K,L,M e N. Referencia Invalida: "+cref+".")
	lRet:=.F.
ElseIf cseg == "4" .And. !(cref2 $ "F|G|H|I|J|K|L|M|N")
	alert("O Segmento de Exclusiva (4), apenas utilizam referencias F,G,H,I,J,K,L,M e N. Referencia Invalida: "+cref2+".")
	lRet:=.F.
EndIf

Return(lRet)
*********************************************************************************
* Funcao : pcar048  * Autor : Jeferson Couto * Data : 21/09/2006                 *
*********************************************************************************
* Descricao : FunÁ„o com o Objetivo de obter parametros de forma aleatoria,     *
*			  possibilitando a seleÁ„o de mais de um item sem ser por intervalo *
*			  dos seguintes parametros: 										*
*				(1)vendedor, 													*
*				(2)gerente, 													*
*				(3)linha,														*
*				(4)estado,														*
*				(5)cidade, 														*
*				(6)cliente,														*
*				(7)p.comercial,													*
*				(8)projecao														*
*********************************************************************************
* Uso       : OrtR048                                                           *
*********************************************************************************
user Function pcar048(nPar, cF3)

// Variaveis deste Form
Local nX			:= 0
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Cria o Cabecalho da GetDados com todos os Campos do Alias ≥
//≥ Caso queira IGNORAR algum Campo basta substituir o Nil    ≥
//≥ por uma array com os campos Ex. {"A1_NOME","A1_LC"}		  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Local aGetAux1	  := IIF(nPar == 1, {"A3_COD","A3_NOME"}, ;
IIF(nPar == 2, {"A3_COD","A3_NOME"}, ;
IIF(nPar == 3, {"X5_CHAVE", "X5_DESCRI"}, ;
IIF(nPar == 4, {"X5_CHAVE", "X5_DESCRI"}, ;
IIF(nPar == 5, {"ZN_CODIGO", "ZN_CIDADE"}, ;
IIF(nPar == 6, {"A1_COD", "A1_NOME"}, ;
IIF(nPar == 7, {"A3_COD","A3_NOME"}, ;
IIF(nPar == 8, {"B1_COD", "B1_XESPACO","B1_XVAREST"}, {}))))))))

// Fim da Criacao do Cabecalho --------------------------------
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis da MsNewGetDados()      ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
// Vetor responsavel pela montagem da aHeader
Local aGetAux1      := {"Z6_CODPROD","B1_XDESCEX","Z6_DESCR","Z6_PRCDIG","Z6_PRCDA1","Z6_CUSTO","Z6_GUERES","Z6_MIX","B1_GRUPO"}  //"Z6_CODPROD","B1_XDESCEX","PB1_DESPRO"
Local aCpoGDa       := aGetAux1 //{"Z6_DESCR","Z6_PRCDIG"}     //aGetAux1
// Vetor com os campos que poderao ser alterados
Local aAlter       	:= {"Z6_CODPROD","Z6_PRCDIG"}     // := aGetAux1
Local nSuperior    	:= 005           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 005           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 150           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 192           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia
Local nOpc         	:= GD_INSERT+GD_DELETE+GD_UPDATE
Local cLinhaOk     	:= "O349LinOK"		//"AllwaysTrue"   // Funcao executada para validar o contexto da linha atual do aCols
Local cTudoOk      	:= "AllwaysTrue"   // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""              // Nome dos campos do tipo caracter que utilizarao incremento automatico.
// Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do
// segundo campo>+..."
Local nFreeze      	:= 000             // Campos estaticos na GetDados.
Local nMax         	:= 999             // Numero maximo de linhas permitidas. Valor padrao 99
Local cCampoOk     	:= "AllwaysTrue"  // Funcao executada na validacao do campo
Local cSuperApagar 	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cApagaOk     	:= "AllwaysTrue"   // Funcao executada para validar a exclusao de uma linha do aCols
// Objeto no qual a MsNewGetDados sera criada

Local oWnd

Private oGetPar 						// Objeto MsNewGetDados
//Private aHeader    	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
//Private aCols      	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols
Private INCLUI 		:= .T.				// Variavel incluida devido ao gatilho do campo B1_COD
Private oMultiLine
Private Odlg



DbSelectArea("SX3")
SX3->(DbSetOrder(2)) // Campo
For nX := 1 to Len(aCpoGDa)
	If SX3->(DbSeek(aCpoGDa[nX]))

//			"U_FCCPO048("+alltrim(str(nPar))+", M->" + alltrim(aCpoGDa[nX]) + ")",;  Z6_CODPROD
		
		If aCpoGDa[nX] $ "Z6_CODPROD" //"Z6_CODPROD","B1_XDESCEX",""
			Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			"IIF(Len(AllTrim(Z6_CODPROD))==4,EXISTCPO('SBM',,1),EXISTCPO('SB1',,1)) .AND. U_LCERCODPR()",;			
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		endif
		
		If aCpoGDa[nX] == "B1_XDESCEX"
			Aadd(aHeader,{ "%(-)D/%(+)A",;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID  ,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 	,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		endif
		
		If aCpoGDa[nX] == "PB1_DESPRO"
			Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID   ,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		EndIf
//oDlgt
		If aCpoGDa[nX] == "Z6_PRCDIG"
			Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			"U_LCERORTR48()",;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		EndIf

		If aCpoGDa[nX] == "Z6_PRCDA1"
			Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID   ,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		EndIf

		If aCpoGDa[nX] == "Z6_CUSTO"
			Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID   ,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		EndIf                      
		
		If aCpoGDa[nX] == "Z6_GUERES"
			Aadd(aHeader,{ "Restituicao(%)",;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID   ,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		EndIf                       
		
		If aCpoGDa[nX] == "Z6_MIX"
			Aadd(aHeader,{ "MIX (%)",;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID   ,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		EndIf

		If aCpoGDa[nX] == "B1_GRUPO"
			Aadd(aHeader,{ "Grupo",;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE ,;
			SX3->X3_TAMANHO ,;
			SX3->X3_DECIMAL ,;
			SX3->X3_VALID   ,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 		,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO})
		EndIf

	Endif
Next nX



// Carregue aqui a Montagem da sua aCol
aAux := {}

if Len(aVetor) < 1
	
	For nX := 1 to Len(aCpoGDa)
		If DbSeek(aCpoGDa[nX])
			Aadd(aAux,CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aAux,.F.)
	Aadd(aCols,aAux)
endif

DEFINE MSDIALOG oDlg TITLE OemToAnsi("Projecao de Produtos") FROM 208, 329 TO 580,750 PIXEL

@ 005,010 TO 145,210 MULTILINE Modify Delete 

@ 155,125 Button "Confirma" Size 037,012 Action {U_FCSTR048(nPar,aCols), (Close(oDlg))}
@ 155,165 Button "Cancela" Size 037,012 Action (Close(oDlg))

ACTIVATE DIALOG oDlg CENTERED
Return



User Function scelpro()

aCabec :={"","Cod.","Tipo de Produtos"}

bOk	:= {||U_FCRETVAR(),oDlg01:End()}
bCancel := {||oDlg01:End()}

oDlg01:=MsDialog():New(00,00,200,350,"Selecione os Tipo de Produtos",,,,,,,,,.T.)
oDlg01:bStart:={||EnchoiceBar(oDlg01,bOk,bCancel)}
oBrw:=TWBrowse():New(15,1,200,120,,aCabec,{10,20,50},oDlg01,,,,,,,,,,,,.F.,,.T.,,,)
oBrw:SetArray(aItens1)
oBrw:bLine:={|| aItens1[oBrw:nAt]}
oBrw:lHScroll:=.F.
oBrw:bLDblClick:= {|| If(Empty(aItens1[oBrw:nAt,1]), aItens1[oBrw:nAt,1]:="X", aItens1[oBrw:nAt,1]:="" ),;
oBrw:Refresh()}

oDlg01:Activate(,,,.T.)

Return


***********************
User Function FCRETVAR()
***********************
Local I := 0
Public cRet := ""

For I := 1 to Len(aItens1)
	If !Empty(aItens1[I,1])
		cRet += iif(Len(cRet)>0,","+aItens1[I,2],aItens1[I,2])
		//		If I > 1 .and. I <> Len(aItens)
		//		If Len(aItens1) > 1 .and. I < Len(aItens1)
		//			cRet := cRet +","
		//		Endif
	Endif
Next
mv_par23 := cRet
Return

*******************************************************************************
* Funcao : FCSTR048  * Autor : Jeferson Couto * Data : 21/09/2006             *
*******************************************************************************
* Descricao : FunÁ„o com o Objetivo de montar a string de seleÁ„o para select *
*				(1)vendedor, 												  *
*				(2)gerente, 												  *
*				(3)linha,													  *
*				(4)estado,													  *
*				(5)cidade, 													  *
*				(6)cliente,													  *
*				(7)p.comercial,												  *
*				(8)projecao													  *
*******************************************************************************
* Uso       : OrtR048                                                         *
*******************************************************************************
User Function FCSTR048(nTipo, aVet)

// Variaveis privadas da rotina ORTR072 para serem utilizadas na select principal
//	Private cXVends    := ""
//	Private cXGerens   := ""
//	Private cXLinhas   := ""
//	Private cXEstados  := ""
//	Private cXCidades  := ""
//	Private cXClientes := ""
//	Private cXPComerc  := ""
//	Private aXProjecao := {}

Do case
	Case nTipo == 1	// Parametro Vendedores
		For j := 1 to Len(aVet)
			cXVends += IIF(!EMPTY(alltrim(aVet[j][1])), iif(!empty(cXVends), ",", "") + "'" + alltrim(aVet[j][1]) + "'", "")
		Next j
		
		If !empty(cXVends)
			cXVends := "(" + cXVends + ")"
		EndIf
		
	Case nTipo == 2	// Parametro Gerentes
		For j := 1 to Len(aVet)
			cXGerens += IIF(!EMPTY(alltrim(aVet[j][1])), iif(!empty(cXGerens), ",", "") + "'" + alltrim(aVet[j][1]) + "'", "")
		Next j
		
		If !empty(cXGerens)
			cXGerens := "(" + cXGerens + ")"
		EndIf
		
	Case nTipo == 3 // Parametro Linhas de Produto
		For j := 1 to Len(aVet)
			cXLinhas += IIF(!EMPTY(alltrim(aVet[j][1])), iif(!empty(cXLinhas), ",", "") + "'" + alltrim(aVet[j][1]) + "'", "")
		Next j
		
		If !empty(cXLinhas)
			cXLinhas := "(" + cXLinhas + ")"
		EndIf
		
	Case nTipo == 4 // Parametro Estados
		For j := 1 to Len(aVet)
			cXEstados += IIF(!EMPTY(alltrim(aVet[j][1])), iif(!empty(cXEstados), ",", "") + "'" + alltrim(aVet[j][1]) + "'", "")
		Next j
		
		If !empty(cXEstados)
			cXEstados := "(" + cXEstados + ")"
		EndIf
		
	Case nTipo == 5 // Parametro Cidades
		For j := 1 to Len(aVet)
			cXCidades += IIF(!EMPTY(alltrim(aVet[j][1])), iif(!empty(cXCidades), ",", "") + "'" + alltrim(aVet[j][1]) + "'", "")
		Next j
		
		If !empty(cXCidades)
			cXCidades := "(" + cXCidades + ")"
		EndIf
		
	Case nTipo == 6 // Parametro Clientes
		For j := 1 to Len(aVet)
			cXClientes += IIF(!EMPTY(alltrim(aVet[j][1])), iif(!empty(cXClientes), ",", "") + "'" + alltrim(aVet[j][1]) + "'", "")
		Next j
		
		If !empty(cXClientes)
			cXClientes := "(" + cXClientes + ")"
		EndIf
		
	Case nTipo == 7 // Parametro P.Comercial
		For j := 1 to Len(aVet)
			cXPComerc += IIF(!EMPTY(alltrim(aVet[j][1])), iif(!empty(cXPComerc), ",", "") + "'" + alltrim(aVet[j][1]) + "'", "")
		Next j
		
		If !empty(cXPComerc)
			cXPComerc := "(" + cXPComerc + ")"
		EndIf
		
	Case nTipo == 8 // Parametro Projecao dos Produtos
		aXProjecao := aClone(aVet)
EndCase
Return(.T.)




*******************************************************************************
* Funcao : FCCPO048  * Autor : Jeferson Couto * Data : 21/09/2006              *
*******************************************************************************
* Descricao : FunÁ„o com o Objetivo de verificar se o registro selecionado    *
*			  no objeto oGetPar da funÁ„o SelPar existe                       *
*				(1)vendedor, 												  *
*				(2)gerente, 												  *
*				(3)linha,													  *
*				(4)estado,													  *
*				(5)cidade, 													  *
*				(6)cliente,													  *
*				(7)p.comercial,												  *
*				(8)projecao													  *
*******************************************************************************
* Uso       : OrtR048                                                         *
*******************************************************************************
Static Function FCCPO048(nPar, cCodigo)

Local aArea := GetArea()
Local lRet  := .T.

If !empty(cCodigo)
	
	Do Case
		Case nPar == 1		// Parametro Vendedores
			DbSelectArea("SA3")
			DbSetOrder(1)
			If !DbSeek(xFilial("SA3") + ALLTRIM(cCodigo))
				MsgBox("Vendedor n„o encontrado !","Atencao","ALERT")
				lRet := .F.
			Else
				oGetPar:aCols[oGetPar:nAt, 2] := SA3->A3_NOME
			EndIf
			
		Case nPar == 2		// Parametro Gerentes
			DbSelectArea("SA3")
			DbSetOrder(1)
			If !DbSeek(xFilial("SA3") + ALLTRIM(cCodigo))
				MsgBox("Gerente n„o encontrado !","Atencao","ALERT")
				lRet := .F.
			Else
				oGetPar:aCols[oGetPar:nAt, 2] := SA3->A3_NOME
			EndIf
			
		Case nPar == 3		// Parametro Linha dos Produtos
			DbSelectArea("SX5")
			DbSetOrder(1)
			If !DbSeek(xFilial("SX5") + "ZA" + ALLTRIM(cCodigo))
				MsgBox("Linha n„o encontrada !","Atencao","ALERT")
				lRet := .F.
			Else
				oGetPar:aCols[oGetPar:nAt, 2] := SX5->X5_DESCRI
			EndIf
			
		Case nPar == 4		// Parametro Estados
			DbSelectArea("SX5")
			DbSetOrder(1)
			If !DbSeek(xFilial("SX5") + "12" + ALLTRIM(cCodigo))
				MsgBox("Estado n„o encontrado !","Atencao","ALERT")
				lRet := .F.
			Else
				oGetPar:aCols[oGetPar:nAt, 2] := SX5->X5_DESCRI
			EndIf
			
		Case nPar == 5		// Parametro Cidades
			DbSelectArea("SZN")
			DbSetOrder(1)
			If !DbSeek(xFilial("SZN") + ALLTRIM(cCodigo))
				MsgBox("Cidade n„o encontrada !","Atencao","ALERT")
				lRet := .F.
			Else
				oGetPar:aCols[oGetPar:nAt, 2] := SZN->ZN_CIDADE
			EndIf
			
		Case nPar == 6		// Parametro Clientes
			DbSelectArea("SA1")
			DbSetOrder(1)
			If !DbSeek(xFilial("SA1") + ALLTRIM(cCodigo))
				MsgBox("Cliente n„o encontrado !","Atencao","ALERT")
				lRet := .F.
			Else
				oGetPar:aCols[oGetPar:nAt, 2] := SA1->A1_NOME
			EndIf
			
		Case nPar == 7		// Parametro P.Comercial
			DbSelectArea("SA3")
			DbSetOrder(1)
			If !DbSeek(xFilial("SA3") + ALLTRIM(cCodigo))
				MsgBox("Vendedor n„o encontrado !","Atencao","ALERT")
				lRet := .F.
			Else
				If Left(M->A3_COD,1) <> 'P'
					MsgBox("Este vendedor n„o È um Parceiro Comercial !","Atencao","ALERT")
					lRet := .F.
				Else
					oGetPar:aCols[oGetPar:nAt, 2] := SA3->A3_NOME
				EndIf
			EndIf
			
			/*	Trecho desabilitado pois n„o sera necessario o uso da descricao do item
			Case nPar == 7		// Projecao dos Produtos
			DbSelectArea("SB1")
			DbSetOrder(1)
			If !DbSeek(xFilial("SB1") + ALLTRIM(M->B1_COD))
			MsgBox("Produto n„o encontrado !","Atencao","ALERT")
			lRet := .F.
			Else
			oGetPar:aCols[oGetPar:nAt, 3] := SB1->B1_DESC
			EndIf
			*/
	EndCase
EndIf

RestArea(aArea)
Return(lRet)

*******************************************************************************
* Funcao : GrvParam()   * Autor : Luzio Tavares      8     * Data : 02/10/2007 *
*******************************************************************************
* Descricao : Grava na tabela SZ6 osparamentros informados para a emissao     *
*             do relatorio para ser visualiuzado posteriormente               *
*********************************************************	**********************
* Uso       : ORTR048                                                         *
*******************************************************************************

Static Function GrvParam(lDel,cProj)
***********************************************************************
Local aArea := GetArea()
Local aVet  :={}


//@ 016, 110 CHECKBOX oChkPul VAR lChkPul PROMPT "Pulverizado"     SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL  incluidor dia 09/11/11
//@ 028, 110 CHECKBOX oChkEsp VAR lChkEsp PROMPT "Especial"        SIZE 041, 008 OF oDlgt COLORS 0, 16777215 PIXEL
//@ 040, 110 CHECKBOX oChkSP  VAR lChkSP  PROMPT "Super Vertical"  SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL
//@ 052, 110 CHECKBOX oChkSBM VAR lChkSBM PROMPT "Sob Medida"      SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL
//@ 064, 110 CHECKBOX oChkFL  VAR lChkFL  PROMPT "Fora de Linha"   SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL

cTpg := "" // linhas abaixo incluido dia 09/11/11
if lChkPul
	cTpg+="P"
ENDIF
if lChkEsp
	cTpg+="E"
ENDIF
if LCHKSP
	cTpg+="S"
ENDIF




if lChkSBM
	cTipo+="1,"
endif

if lChkFL
	cTipo+="2,"
endif

if lChkFC
	cTipo+="3,"
endif

cSegment := ""

**************************           
//lChkCom  := .f.                        
lChkLoja := .t. //gilvan mudar para falso
lChkLExc := .f.
**************************           

if lChkCom
	cSegment += "26"
endif

if lChkLoja
	cSegment += "3"
endif

if lChkLExc
	cSegment += "4"
endif

//SSI 56804 - ReferÍncia atÈ H
If cEmpAnt == "18"
	aRefer  := {"A","B","C"}
ElseIf cEmpAnt == "22"
	aRefer  := {"A","B","C","D","E"}
ElseIf cEmpAnt == "23"
	aRefer  := {"A","B","C","D","E","F"}
ElseIf cEmpAnt == "24"
	aRefer  := {"A"}
Else
	aRefer  := {"A","B","C","D","E","F","G","H"}
EndIf

cProjOri:= cProj
cRefOri := cRef

if lDel  // Deleta a projecao
	
	For nRef := 1 To Len(aRefer)
		dbSelectArea("SZ6")
		nSZ6Order := RetOrder("SZ6","Z6_FILIAL+Z6_NUMPROJ")
	    SZ6->( dbSetOrder( nSZ6Order ) )
		SZ6->( dbSeek(xFilial("SZ6")+SubStr(cProjOri,1,5)+aRefer[nRef]) )
		while SZ6->( !EOF() .and. ALLTRIM(Z6_NUMPROJ) == SubStr(cProjOri,1,5)+aRefer[nRef] )
			IF SZ6->( reclock("SZ6",.F.) )
				SZ6->( dbDelete() )
				SZ6->( msunlock() )
			EndIF	
			SZ6->(dbSKIP())
		END
	Next nRef
		
endif

for i:=1 to len(aCols)
	if aCols[i][10] == .F.
		aAdd(aVet,{aCols[i][1],aCols[i][2]," ",aCols[i][4],aCols[i][5],aCols[i][6],aCols[i][7],aCols[i][8],aCols[i][9]})
	endif
next

if len(aVet) > 0  // alterado no dia 09/11/11
	For i:=1 to len(aVet)

		For nRef := 1 To Len(aRefer)
			If nRef == 1
				nPreco := aVet[i][5]
				nCusto := aVet[i][6]
				cProj  := cProjOri
				cRef   := cRefOri
			Else
				cRef   := aRefer[nRef]
				cProj  := SubStr(cProjOri,1,5)+cRef
				nPreco := aVet[i][5] * (1+gvaria(cRef))
				nCusto := aVet[i][6]
			EndIf
		
			Begin Transaction
			dbSelectArea("SZ6")
			dbSetOrder(1)
			SZ6->( RecLock("SZ6",.T.) )
			SZ6->Z6_FILIAL  := xFilial("SZ6")
			SZ6->Z6_DTGERA  := dDataBase
			SZ6->Z6_HRGERA  := Time()
			SZ6->Z6_CDUSUA  := RetCodUsr()   //substr(cUsuario,7,15)
			SZ6->Z6_DTEMII  := dEmis1
			SZ6->Z6_DTEMIF  := dEmis2
			SZ6->Z6_ASSISTE := cAssis
			SZ6->Z6_VENDI   := cVend1
			SZ6->Z6_VENDF   := cVend2
			SZ6->Z6_LINHAI  := cProd1
			SZ6->Z6_LINHAF  := cProd2
			SZ6->Z6_UFINI   := cUf1
			SZ6->Z6_UFFIM   := cUf2
			SZ6->Z6_CIDINI  := cCid1
			SZ6->Z6_CIDFIM  := cCid2
			SZ6->Z6_CLIINI  := cCli1
			SZ6->Z6_CLIFIM  := cCli2
			SZ6->Z6_PARCEI  := cParc1
			SZ6->Z6_PARCEF  := cParc2
			SZ6->Z6_DTPROJ  := ddatabase
			
			SZ6->Z6_PROJPR  := '1'
			SZ6->Z6_DESCDG  := nDg
			SZ6->Z6_DESFIN  := nFin
			SZ6->Z6_DESQTD  := nQtd
			SZ6->Z6_DESFID  := nDescExt  // DESCONTO EXTRA
			SZ6->Z6_TIPPRO  := cTpg //substr(cTipo,1,len(cTipo)-1) alterado no dia 09/11/11
			SZ6->Z6_TABVEN  := cTab
			SZ6->Z6_REFTAB  := cRef
			SZ6->Z6_NUMPROJ := cProj
			SZ6->Z6_CODPROD := aVet[i][1]
//			SZ6->Z6_DESCR   := aVet[i][3]
			SZ6->Z6_DESCPRO := aVet[i][2]
			SZ6->Z6_SEGMENT := "26" //cSegment
			SZ6->Z6_GUERES  := aVet[i][7] // RETIRADO NO DIA 29/11/11 Pois nao tem os campos na base de producao e base de teste desativada
			
			If nRef == 1
				SZ6->Z6_PRCDIG  := aVet[i][4] // INCLUIDO NO DIA 21/11/11 WFA  // RETIRADO NO DIA 29/11/11 Pois nao tem os campos na base de producao e base de teste desativada
				SZ6->Z6_PRCDA1  := aVet[i][5] // INCLUIDO NO DIA 21/11/11 WFA  // RETIRADO NO DIA 29/11/11 Pois nao tem os campos na base de producao e base de teste desativada
				SZ6->Z6_CUSTO   := aVet[i][6] // RETIRADO NO DIA 29/11/11 Pois nao tem os campos na base de producao e base de teste desativada
				SZ6->Z6_MIX     := aVet[i][8] // RETIRADO NO DIA 29/11/11 Pois nao tem os campos na base de producao e base de teste desativada
			Else
				SZ6->Z6_PRCDIG 	:= 	nPreco+round(nPreco*SZ6->Z6_DESCPRO/100,2)
				SZ6->Z6_PRCDA1 	:= 	nPreco
				SZ6->Z6_CUSTO   :=  nCusto
				SZ6->Z6_MIX 	:= 	round(((nPreco+round(nPreco*SZ6->Z6_DESCPRO/100,2)-nCusto)/(nPreco+round(nPreco*SZ6->Z6_DESCPRO/100,2)))*100,2)
			EndIf

			//		SZ6->Z6_SEGMENT:= substr(CSEGMENT,1,len(CSEGMENT)-1)
			
			SZ6->( MsUnLock() )
			dbSelectArea("SZ6")
			DbCloseArea()
			End Transaction
		Next nRef
	Next i
	RestArea(aArea)
	
else
	dbSelectArea("SZ6")
	dbSetOrder(1)
	SZ6->( RecLock("SZ6",.T.) )
	SZ6->Z6_FILIAL  := xFilial("SZ6")
	SZ6->Z6_DTGERA  := dDataBase
	SZ6->Z6_HRGERA  := Time()
	SZ6->Z6_CDUSUA  := RetCodUsr()   //substr(cUsuario,7,15)
	SZ6->Z6_DTEMII  := dEmis1
	SZ6->Z6_DTEMIF  := dEmis2
	SZ6->Z6_ASSISTE := cAssis
	SZ6->Z6_VENDI   := cVend1
	SZ6->Z6_VENDF   := cVend2
	SZ6->Z6_LINHAI  := cProd1
	SZ6->Z6_LINHAF  := cProd2
	SZ6->Z6_UFINI   := cUf1
	SZ6->Z6_UFFIM   := cUf2
	SZ6->Z6_CIDINI  := cCid1
	SZ6->Z6_CIDFIM  := cCid2
	SZ6->Z6_CLIINI  := cCli1
	SZ6->Z6_CLIFIM  := cCli2
	SZ6->Z6_PARCEI  := cParc1
	SZ6->Z6_PARCEF  := cParc2
	SZ6->Z6_PROJPR  := '2'
	SZ6->Z6_DESCDG  := nDg
	SZ6->Z6_DESFIN  := nFin
	SZ6->Z6_DESQTD  := nQtd
	SZ6->Z6_DESFID  := nDescExt  // DESCONTO EXTRA
	//	SZ6->Z6_SEGINI  := cSegm1
	//	SZ6->Z6_SEGFIN  := cSegm2
	SZ6->Z6_TIPPRO  := cTpg //substr(cTipo,1,len(cTipo)-1) alterado dia 09/11/11
	SZ6->Z6_TABVEN  := cTab
	SZ6->Z6_REFTAB  := cRef
	SZ6->Z6_NUMPROJ := cProj
	SZ6->Z6_DTPROJ  := ddatabase
	SZ6->Z6_SEGMENT := "26" //cSegment
	
	SZ6->( MsUnLock() )
	dbSelectArea("SZ6")
	DbCloseArea()
	
endif

cProj := cProjOri
cRef  := cRefOri

Return

*******************************************************************************
* Funcao : ImpCabec  * Autor : Luzio Tavares  * Data : 21/09/2007             *
*******************************************************************************
* Descricao : Imprimir cabecalho                                              *
*******************************************************************************
* Uso       : OrtR048                                                         *
*******************************************************************************
Static Function ImpCabec(Cabec1,Cabec2,Titulo)

Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
//Imprime o cabeÁalho do relatÛrio conforme modelo do cliente.
//nLin := 6
@nlin,0 PSAY "USUARIO         : GER. GERAL, GER. LOJA E GESTOR DE PRECOS."
nLin++
@nlin,0 PSAY "OBJETIVO        : ESTE MAPA PROJETA O NOVO MIX DE ACORDO COM OS DESCONTOS E ACRESCIMOS PRATICADOS."
nLin++
@nlin,0 PSAY "PER. UTILIZACAO : QUINZENAL E/OU MENSAL."
nLin++

/*
@nlin,0 PSAY REPLICATE("_",220) //cLinha1
nLin++
//							   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//					  1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
@nlin,0 PSAY "|          |                    |              |      |   PRECO  |Q|F|F|  PRECO   |          |         |          |          |     |      |      |      |                        P R O J E C A O                           |"
nLin++
@nlin,0 PSAY "|          |                    |              |      |  MARFIL  |U|I|I| LIQUIDO  |   CUSTO  | SOBROU  |    D G   |   LUCRO  |LUCRO|PART. |CONTR | MARK-|__________________________________________________________________|"
nLin++
@nlin,0 PSAY "|  CODIGO  |     DESCRICAO      | MEDIDA       |PECAS |  "+MV_PAR28+" - "+MV_PAR29+" |A|N|D| FABRICA  |     MP   |  (LB)   |  "+TRAN(MV_PAR21,'@ER 99.99')+"%  |   FINAL  |  %  | FIN. |RENT. |  U P | DES/ | MARK-|  PRECO   |          |   D G   |   LUCRO  |  LUCRO% |"
nLin++
@nlin,0 PSAY "|          |                    |              |      | (LIQUIDA)|N| |E|          |          |         |          |          | P V |      |      |      | ACR  |  U P | UNITARIO |  SOBRA   |  "+TRAN(MV_PAR21,'@ER 99.99')+"% |   FINAL  |   P V   |"
nLin++
@nlin,0 PSAY "|          |                    |              |      |          |%|%|%|          |          |         |          |          |     |      |      |      |      | NOVO |          |          |         |          |         |"
//					  |xxxxxxxxxx|xxxxxxxxxxxxxxxxxxxx|xxxxxxxxxxxxxx|99.999|999.999,99|9|9|9|999.999,99|999.999,99|99.999,99|999.999,99|999.999,99|99,99|999,99|999,99|999,99|999,99|999,99|999.999,99|999.999,99|99.999,99|999.999,99|99.999,99|
nLin++
@nlin,0 PSAY "|"+REPLICATE("-",218)+"|" //cLinha5
nLin++
*/

//   	   1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22        23        24
//123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
@nlin,0 PSAY "________________________________________________________________________________________________________________________________________________________________________________________________________________________________________"
nLin++
@nlin,0 PSAY "|          |                              |              |     |  PRECO  | Q| F| F|  PRECO  |         |         |        |         |      |      |       |      |        |                         PROJECAO                            |"
nLin++
@nlin,0 PSAY "|          |                              |              |     |MARFIL-31| U| I| I| LIQUIDO |  CUSTO  |  SOBROU |   DG   |   LUCRO |LUCRO%|PART. |CONTRIB|MARKUP|        |_____________________________________________________________|"
nLin++
//@nlin,0 PSAY "|   CODIGO |         DESCRICAO            | MEDIDA       |PECAS|         | A| N| D| FABRICA |    MP   |   (LB)  |        |   FINAL |   PV | FIN. |RENTxO |MARKUP|PRECO   |DES/ACR|MARKUP|  PRECO |   SOBRA  |   DG    |   LUCRO  |LUCRO%|"
//@nlin,0 PSAY "|   CODIGO |         DESCRICAO            | MEDIDA       |PECAS|    -    | A| N| D| FABRICA |    MP   |   (LB)  |        |   FINAL |   PV | FIN. |RENTxO |MARKUP|PRECO   |DES/ACR|MARKUP|  PRECO |          |   DG    |   LUCRO  |LUCRO%|"
@nlin,0 PSAY "|   CODIGO |         DESCRICAO            | MEDIDA       |PECAS|"+MV_PAR27+" - "+MV_PAR28+"  | A| N| D| FABRICA |    MP   |   (LB)  | "+TRAN(MV_PAR21,'@ER 99.99')+"% |   FINAL |   PV | FIN. |RENTxO |MARKUP|PRECO   |DES/ACR|MARKUP|  PRECO |   SOBRA  |   DG    |   LUCRO  |LUCRO%|"
nLin++
@nlin,0 PSAY "|          |                              |              |     |(LIQUIDA)|  |  |  |         |         |         |        |         |      |      |       |      |UNITARIO|       | NOVO |UNITARIO|          | "+TRAN(MV_PAR21,'@ER 99.99')+"% |   FINAL  |  PV  |"
nLin++
@nlin,0 PSAY "|A)        |B)                            |C)            |D)   |E)       |F)|G)|H)|I)       |J)       |K)=I-J   |L)=IxDG |M)=K-L   |N)=M/I|O)    |P)     |Q)=I/J|R)      |S)     |T)    |U)=RxS  |V)=U-J    |W)      |X)=V-L    |Y)=X/U|"
//            |xxxxxxxxxx|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|xxxxxxxxxxxxxx|99999|999999,99|99|99|99|999999,99|999999,99|999999,99|99999,99|999999,99|9999,9|999,99|9999,99|999,99|99999,99|9999,99|999,99|99999,99|9999999,99|99999,99|9999999,99|999,99|
nLin++
@nlin,0 PSAY "________________________________________________________________________________________________________________________________________________________________________________________________________________________________________"
nLin++


Return()

//-----------------------------------------------------------------MONTAGEM DO LAYOUT DO RELATORIO---------------------------------------------------------------------------
/*
1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
"|          |                    |              |      |   PRECO  |Q|F|F|  PRECO   |          |         |          |          |     |      |      |      |                        P R O J E C A O                           |"
"|          |                    |              |      |  MARFIL  |U|I|I| LIQUIDO  |   CUSTO  | SOBROU  |    D G   |   LUCRO  |LUCRO|PART. |CONTR | MARK-|__________________________________________________________________|"
"|  CODIGO  |     DESCRICAO      | MEDIDA       |PECAS |  "+MV_PAR28+" - "+MV_PAR29+" |A|N|D| FABRICA  |     MP   |  (LB)   |  "+TRAN(MV_PAR21,'@ER 99.99')+"%  |   FINAL  |  %  | FIN. |RENT. |  U P | DES/ | MARK-|  PRECO   |          |   D G   |   LUCRO  |  LUCRO% |"
"|          |                    |              |      | (LIQUIDA)|N| |E|          |          |         |          |          | P V |      |      |      | ACR  |  U P | UNITARIO |  SOBRA   |  "+TRAN(MV_PAR21,'@ER 99.99')+"% |   FINAL  |   P V   |"
"|          |                    |              |      |          |%|%|%|          |          |         |          |          |     |      |      |      |      | NOVO |          |          |         |          |         |"
|xxxxxxxxxx|xxxxxxxxxxxxxxxxxxxx|xxxxxxxxxxxxxx|99.999|999.999,99|9|9|9|999.999,99|999.999,99|99.999,99|999.999,99|999.999,99|99,99|999,99|999,99|999,99|999,99|999,99|999.999,99|999.999,99|99.999,99|999.999,99|99.999,99|"
1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
*/

***********************************
Static Function fConsProj(cProj)
***********************************

Local cTab
Local cRef
Local cAno

Local cQuery := ""
Local lRet   := .T.

__cTab	:= NIL
__cRef	:= NIL

csegg6 := substr(cProj,1,1)

IF .NOT.(csegg6$"12")
	alert("CÛdigo do Segmento Inv·lido. O Primeiro Caractere da ProjeÁ„o dever· ser (1) ou (2).","A T E N « √ O!!!")
	Return(.F.)
ENDIF

cTab	:= substr(cProj,2,2)
IF .NOT.(Empty(cTab))
	IF .NOT.( ExistCpo("DA0",PADL(cTab,TamSX3("DA0_CODTAB")[1],"0") , NIL , "Tabela Inv·lida." , .T. ) )
		Return(.F.)
	EndIF
EndIF

cAno := substr(cProj,4,2)
IF .NOT.("00"$cAno)
	IF (Val(cAno)==0)
		alert("Ano Inv·lido. Informe um valor v·lido para o Ano","A T E N « √ O!!!")
		Return(.F.)
	EndIF
EndIF	

cRef   := substr(cProj,6,1)
IF Empty(cRef)
	alert("ReferÍncia Inv·lida. Invorme um valor v·lido para a ReferÍncia. PosiÁ„o 6","A T E N « √ O!!!")
	Return(.F.)
EndIF

if cRef <> "A" .And. nOpt <> 4
	alert("Por determinaÁ„o da diretoria sÛ ser· permitido incluir/alterar a referÍncia A. Refencia Invalida: "+cRef+". PosiÁ„o 6")
	Return(.F.)
endif

If cEmpAnt == "23"
	if .NOT.(cRef $ "ABCDEFG" )
		alert("Apenas s„o utilizadas referencias A,B,C,D,E,F,G. Refencia Invalida: "+cRef+". PosiÁ„o 6")
		Return(.F.)
	endif
Else
	if .NOT.(cRef $ "ABCDEMN" )
		alert("O Segmento de Industrial/Loja, apenas utilizam referencias A,B,C,D,E,M,N. Refencia Invalida: "+cRef+". PosiÁ„o 6")
		Return(.F.)
	endif
EndIf

cQuery:=" SELECT COUNT(*) QTD FROM "+RETSQLNAME("SZ6")+" SZ6 "
cQuery+=" WHERE D_E_L_E_T_ = ' ' "
cQuery+=" AND Z6_FILIAL = '"+XFILIAL("SZ6")+"' "
cQuery+=" AND Z6_NUMPROJ = '"+cProj+"' "
TcQuery cQuery Alias "QRY" New
DBSELECTAREA("QRY")

IF nOpt == 1
	IF QRY->QTD > 0
		MSGBOX("Projecao ja cadastrada !","ORTR048","INFO")
		lRet := .F.
	ENDIF
ELSEIF nOpt == 2 .or. nOpt == 3
	if QRY->QTD = 0
		MSGBOX("Projecao n„o encontrada, informe uma projeÁ„o v·lida !","ORTR048","INFO")
		lRet := .F.
	endif
ENDIF

DBSELECTAREA("QRY")
dbCloseArea()

IF ( lRet )

	__cTab	:= cTab
	__cRef	:= cRef

EndIF

return lRet



********************************
Static Function fPreenchePar(cProj)
********************************
Local cDesPro
//Local nSZ6Order	:= RetOrder("SZ6","Z6_FILIAL+Z6_NUMPROJ")

DBSELECTAREA("SZ6")
//SZ6->( dbSetOrder( nSZ6Order ) )
dbOrderNickName("CSZ62")
SZ6->( dbSeek(xFilial("SZ6")+cProj))

dEmis1 := SZ6->Z6_DTEMII
dEmis2 := SZ6->Z6_DTEMIF
cAssis := SZ6->Z6_ASSISTE
cVend1 := SZ6->Z6_VENDI
cVend2 := SZ6->Z6_VENDF
cProd1 := SZ6->Z6_LINHAI
cProd2 := SZ6->Z6_LINHAF
cUf1   := SZ6->Z6_UFINI
cUf2   := SZ6->Z6_UFFIM
cCid1  := SZ6->Z6_CIDINI
cCid2  := SZ6->Z6_CIDFIM
cCli1  := SZ6->Z6_CLIINI
cCli2  := SZ6->Z6_CLIFIM
cParc1 := SZ6->Z6_PARCEI
cParc2 := SZ6->Z6_PARCEF
nDG    := SZ6->Z6_DESCDG
nFin   := SZ6->Z6_DESFIN
nQtd   := SZ6->Z6_DESQTD
nDescExt:= SZ6->Z6_DESFID  // DESCONTO EXTRA
//cSegment:= SZ6->Z6_SEGMENT+","

while len(cSegment) > 0
	//	if substr(cTipo,1,at(",",cSegment)-1) == '1'
	//		lChkInd := .T.
	if substr(cTipo,1,at(",",cSegment)-1) $ "2|6"
		**************************           
//		lChkCom  := .f.                        
		lChkLoja := .f.
		lChkLExc := .f.
		**************************           
		
		lChkCom := .f. //.T.
	elseif substr(cTipo,1,at(",",cSegment)-1) == '3'
		lChkLoja := .T.
	elseif substr(cTipo,1,at(",",cSegment)-1) == '4'
		lChkLExc := .F. // .T.
	endif
	//	elseif substr(cTipo,1,at(",",cSegment)-1) == '5'
	//		lChkOInd := .T.
	//	elseif substr(cTipo,1,at(",",cSegment)-1) == '6'
	//		lChkOCom := .T.
	
	cSegment := alltrim(substr(cSegment,at(",",cSegment)+1,len(cSegment)))
end

cTipo    := SZ6->Z6_TIPPRO+","
while len(cTipo) > 0
	if substr(cTipo,1,at(",",cTipo)-1) == '1'
		lChkSBM := .T.
	elseif substr(cTipo,1,at(",",cTipo)-1) == '2'
		lChkFC := .T.
	elseif substr(cTipo,1,at(",",cTipo)-1) == '3'
		lChkFL := .T.
	endif
	cTipo := alltrim(substr(cTipo,at(",",cTipo)+1,len(cTipo)))
end

// Tipo pulverizado especial - 09/11/11

cTpl   := ""
cTpl   := SZ6->Z6_TIPPRO

nlChkPul := substr(cTpl,at("P",cTpl),1)
if nlChkPul = 'P'
	lChkPul := .T.
endif

nlChkEsp := substr(cTpl,at("E",cTpl),1)
if nlChkEsp = 'E'
	lChkEsp := .T.
endif

nLCHKSP := substr(cTpl,at("S",cTpl),1)
if nLCHKSP = 'S'
	LCHKSP := .T.
endif


csegm6   := ""
csegm6   := "26" //SZ6->Z6_SEGMENT


nlChkCom := substr(csegm6,at("2",csegm6),1)
if nlChkCom = '2'
	lChkCom := .f. //.T.
	**************************           
//	lChkCom  := .f.                        
	lChkLoja := .f.
	lChkLExc := .f.
	**************************           
	
endif

nlChkLoja := substr(csegm6,at("3",csegm6),1)
if nlChkLoja = '3'
	lChkLoja := .T.
endif

nlChkLExc := substr(csegm6,at("4",csegm6),1)
if nlChkLExc = '4'
	lChkLExc := .F. //.T.
endif


cTab := SZ6->Z6_TABVEN
padl(cTab,3,'0')
cref := SZ6->Z6_REFTAB

while SZ6->( !Eof() .and. Z6_NUMPROJ == cProj )
	IF !Empty(SZ6->Z6_CODPROD)
		cdespro := ""
		cCodGru := ""
		if Len(Alltrim(SZ6->Z6_CODPROD))==4
			DBSELECTAREA("SBM")
			DbSetOrder(1)
			if dbSeek(xFilial("SBM")+SZ6->Z6_CODPROD)
				cdespro := SBM->BM_DESC + " SOB-MEDIDA M3"
				cCodGru := AllTrim(SZ6->Z6_CODPROD)+"_"
			EndIf
		Else
			DBSELECTAREA("SB1")
			DbSetOrder(1)
			if dbSeek(xFilial("SB1")+SZ6->Z6_CODPROD)
				cdespro := SB1->B1_DESC + " " + SB1->B1_XMED
				cCodGru := SB1->B1_GRUPO
			EndIf
		EndIf
		AADD(aVetor,{SZ6->Z6_CODPROD,SZ6->Z6_DESCPRO,cdespro,SZ6->Z6_PRCDIG,SZ6->Z6_PRCDA1,SZ6->Z6_CUSTO,SZ6->Z6_GUERES,SZ6->Z6_MIX,cCodGru})
	EndIF
	DBSELECTAREA("SZ6")
	DBSKIP()
	
END
aSort(aVetor,,, {|x,y| x[9]+ x[1] < y[9]+ y[1] })
for i:=1 to len(aVetor)
	aAdd(aCols,{aVetor[i][1],aVetor[i][2],aVetor[i][3],aVetor[i][4],aVetor[i][5],aVetor[i][6],aVetor[i][7],aVetor[i][8],aVetor[i][9],.F.})
next

return .T.


************************************
USer Function MCONTATELA48(cProj,nOpt)
************************************

Local nOpcNewGd			:= ( GD_INSERT + GD_UPDATE + GD_DELETE	)

Local oBTNGDPesq


if nOpt = 4
	lChkPul := .T.
	lChkSP  := .T.
	lChkSBM := .T.
	lChkFL  := .F.
	lChkFC  := .F.
	lChkEsp := .F.
	cref := substr(cProj,6,1)
	ctab := "0"+substr(cProj,2,2)
	fOR048(cProj)
	Return
Endif

if nOpt = 3
   RotCopia(cProj)   
   Return
Endif

if nOpt == 2
	fPreenchePar(cProj)
endif

DbSelectArea("SX3")
SX3->(DbSetOrder(2)) // Campo
For nX := 1 to Len(aCpoGDa)
	If SX3->(DbSeek(aCpoGDa[nX]))
//			"U_FCCPO048("+alltrim(str(8))+", M->" + alltrim(aCpoGDa[nX]) + ")",;

		If aCpoGDa[nX] $ "Z6_CODPROD"
			Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			"IIF(Len(AllTrim(Z6_CODPROD))==4,EXISTCPO('SBM',,1),EXISTCPO('SB1',,1)) .AND. U_LCERCODPR()",;			
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 	,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO,;
			"",;
			"",;
			"",;
			"",;
			.F.})
		endif
		
		If aCpoGDa[nX] == "B1_XDESCEX"
			Aadd(aHeader,{ "%(-)D/%(+)A",;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID  ,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 	,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO,;
			"",;
			"",;
			"",;
			"",;
			.F.})
		endif
		
		If aCpoGDa[nX] $ "PB1_DESPRO"
			Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 	,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO,;
			"",;
			"",;
			"",;
			"",;
			.F.})
		EndIf                  
		
//		U_SimItemAlt(oBrwLt:nAT)     oDlgt 			"U_LCERORTR48(oDlgt:nAT)",;

		
		If aCpoGDa[nX] $ "Z6_PRCDIG"
			Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			"U_LCERORTR48()",;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 	,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO,;
			"",;
			"",;
			"",;
			"",;
			.F.})
		EndIf                        

		If aCpoGDa[nX] $ "Z6_PRCDA1"
			Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 	,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO,;
			"",;
			"",;
			"",;
			"",;
			.F.})
		EndIf                        

		If aCpoGDa[nX] $ "Z6_CUSTO"
			Aadd(aHeader,{ AllTrim(X3Titulo()),;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 	,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO,;
			"",;
			"",;
			"",;
			"",;
			.F.})
		EndIf                     
		
		If aCpoGDa[nX] $ "Z6_GUERES"
			Aadd(aHeader,{ "Restituicao(%)",;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 	,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO,;
			"",;
			"",;
			"",;
			"",;
			.F.})
		EndIf                        
   
		If aCpoGDa[nX] $ "Z6_MIX"
			Aadd(aHeader,{ "MIX (%) ",;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 	,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO,;
			"",;
			"",;
			"",;
			"",;
			.F.})
		EndIf                        
		
		If aCpoGDa[nX] == "B1_GRUPO"
			Aadd(aHeader,{ "Grupo",;
			SX3->X3_CAMPO	,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO	,;
			SX3->X3_TIPO	,;
			SX3->X3_F3 	,;
			SX3->X3_CONTEXT,;
			SX3->X3_CBOX	,;
			SX3->X3_RELACAO,;
			"",;
			"",;
			"",;
			"",;
			.F.})
		EndIf
	Endif

Next nX


aAux := {}

if Len(aVetor) < 1
	
	For nX := 1 to Len(aCpoGDa)
		If DbSeek(aCpoGDa[nX])
			Aadd(aAux,CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aAux,.F.)
	Aadd(aCols,aAux)
endif

if nOpt == 2
		cMsg:= "Consulta Projecao: "//+cProj
elseif nOPt == 1
	IF .NOT.(Empty(__cTab))
		cTab := __cTab
	EndIF
	IF .NOT.(Empty(__cRef))
		cRef := __cRef
	EndIF	
	cMsg:= "Inclusao da Projecao: "//+cProj
elseif nOPt == 3
	cMsg:= " Copia de Projecao"
endif
                                                                            //650
DEFINE MSDIALOG oDlgt TITLE "Mapa de Comercialiazacao" FROM 000, 000  TO 500, 980 COLORS 0, 16777215 PIXEL
                 

@ 025,010 Say cMsg  Size 300,010 COLOR CLR_BLUE Font oFont14Grd PIXEL OF oDlgt
@ 025,110 Say cProj Size 300,010 COLOR CLR_BLUE Font oFont14Grd PIXEL OF oDlgt



@ 015,320 Say "   Mapa de Comercializacao" Size 300,010 COLOR CLR_BLUE Font oFont14Grd PIXEL OF oDlgt

@ 030,320 Say "          C O M E R C I A L"    Size 300,010 COLOR CLR_BLUE Font oFont14Grd PIXEL OF oDlgt

//@ 003, 135 SAY Segmento PROMPT cMsg Font oFnt1 SIZE 100, 009 OF oDlgt COLORS CLR_BLUE PIXEL

//@ 014, 285 SAY oSay14 PROMPT "ProjeÁ„o" SIZE 052, 007 OF oDlgt COLORS 0, 16777215 PIXEL
*****************************
// retirado no dia 30/12/11 - apedido do marcio rocha o mapa ser somente franquia e lojas excluisivas @ 016, 011 CHECKBOX oChkCom  VAR lChkCom  PROMPT "Comercial"      SIZE 075, 008 OF oDlgt COLORS 0, 16777215 PIXEL
//@ 072, 010 CHECKBOX oChkLoja VAR lChkLoja PROMPT "Loja"           SIZE 075, 008 OF oDlgt COLORS 0, 16777215 PIXEL

//@ 072, 055 CHECKBOX oChkLExc VAR lChkLExc PROMPT "Loja Exclusiva" SIZE 075, 008 OF oDlgt COLORS 0, 16777215 PIXEL

@ 072, 010 CHECKBOX oChkLRes VAR lChkLRes PROMPT "Incluir Trav.Flocos/Acrilon" SIZE 075, 008 OF oDlgt COLORS 0, 16777215 PIXEL
**************************           
//lChkCom  := .f.                        
lChkLoja := .f.
lChkLExc := .f.
**************************           
           
               
//@ 072, 010 CHECKBOX oChkCom  VAR lChkCom  PROMPT "Comercial" SIZE 075, 008 Valid (precom())OF oDlgt COLORS 0, 16777215 PIXEL
//@ 072, 055 CHECKBOX oChkOInd VAR lChkOInd PROMPT "Industrial" SIZE 075, 008 OF oDlgt COLORS 0, 16777215 PIXEL

//@ 040, 011 CHECKBOX oChkLoja VAR lChkLoja PROMPT "Loja" SIZE 075, 008 Valid (preloj()) OF oDlgt COLORS 0, 16777215 PIXEL
//@ 064, 011 CHECKBOX oChkLExc VAR lChkLExc PROMPT "Loja Exclusiva" SIZE 075, 008 Valid (preexc()) OF oDlgt COLORS 0, 16777215 PIXEL
*****************************
//@ 072, 010 CHECKBOX oChkOInd VAR lChkOInd PROMPT "Ortoclass Industrial" SIZE 075, 008 OF oDlgt COLORS 0, 16777215 PIXEL
//@ 072, 055 CHECKBOX oChkOCom VAR lChkOCom PROMPT "Ortoclass Comercial" SIZE 075, 008 OF oDlgt COLORS 0, 16777215 PIXEL

@ 016, 200 SAY oSay8 PROMPT "Tab. Preco" SIZE 030, 008 OF oDlgt COLORS 0, 16777215 PIXEL
@ 016, 250 MSGET oGetTab VAR cTab SIZE 030, 008 OF oDlgt PICTURE "99" COLORS 0, 16777215 PIXEL
@ 028, 200 SAY oSay9 PROMPT "Ref. Tabela" SIZE 030, 011 OF oDlgt COLORS 0, 16777215 PIXEL
@ 028, 250 MSGET oGetRef VAR cRef SIZE 030, 008 OF oDlgt PICTURE "@!" COLORS 0, 16777215 PIXEL
//@ 040, 200 SAY oSay10 PROMPT "Desc. Extra" SIZE 036, 007 OF oDlgt COLORS 0, 16777215 PIXEL
//@ 040, 250 MSGET oGetExt VAR nDescExt SIZE 042, 008 OF oDlgt PICTURE "999.99" COLORS 0, 16777215 PIXEL
@ 052, 200 SAY oSay12 PROMPT "Desc. Quantitativo" SIZE 046, 008 OF oDlgt COLORS 0, 16777215 PIXEL
@ 052, 250 MSGET oGetQtd VAR nQtd SIZE 042, 008 OF oDlgt PICTURE "999.99" COLORS 0, 16777215 PIXEL

@ 064, 200 SAY oSay11 PROMPT "Desc. Financeiro" SIZE 044, 007 OF oDlgt COLORS 0, 16777215 PIXEL
@ 064, 250 MSGET oGetFin VAR nFin SIZE 042, 008 OF oDlgt PICTURE "999.99" COLORS 0, 16777215 PIXEL

@ 076, 200 SAY oSay13 PROMPT "Desp. Gerais" SIZE 052, 008 OF oDlgt COLORS 0, 16777215 PIXEL
@ 076, 250 MSGET oGetDG VAR nDG SIZE 042, 008 OF oDlgt PICTURE "999.99" COLORS 0, 16777215 PIXEL
/*
@ 052, 320 CHECKBOX oMedper  VAR lMedper   PROMPT "Media Periodo"     SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL
@ 052, 370 CHECKBOX oQtdZero VAR lQtdZero  PROMPT "Mostra Qtd Zero"   SIZE 055, 008 OF oDlgt COLORS 0, 16777215 PIXEL
@ 052, 430 CHECKBOX oImptot  VAR lImptot   PROMPT "Somente Totais"  SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL
*/
@ 052, 320 CHECKBOX oChkPul VAR lChkPul PROMPT "Pulverizado"     SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL
@ 052, 370 CHECKBOX oChkEsp VAR lChkEsp PROMPT "Especial"        SIZE 055, 008 OF oDlgt COLORS 0, 16777215 PIXEL
@ 052, 430 CHECKBOX oChkSP  VAR lChkSP  PROMPT "Super Vertical"  SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL
/*
@ 064, 320 CHECKBOX oMedper  VAR lMedper   PROMPT "Media Periodo"   SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL
@ 064, 370 CHECKBOX oQtdZero VAR lQtdZero  PROMPT "Mostra Qtd Zero" SIZE 041, 008 OF oDlgt COLORS 0, 16777215 PIXEL
@ 064, 430 CHECKBOX oImptot  VAR lImptot   PROMPT "Somente Totais"  SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL
*/
@ 076, 320 CHECKBOX oImpDif VAR lImpDif PROMPT "Imp. DiferenÁa Tab. Anterior"     SIZE 078, 008 OF oDlgt COLORS 0, 16777215 PIXEL

@ 052, 010 CHECKBOX oChkSBM VAR lChkSBM PROMPT "Sob Medida"      SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL
@ 052, 055 CHECKBOX oChkFL  VAR lChkFL  PROMPT "Fora Linha"   SIZE 048, 008 OF oDlgt COLORS 0, 16777215 PIXEL

@ 052, 100 CHECKBOX oChkFC  VAR lChkFC  PROMPT "Terceiro" SIZE 041, 008 OF oDlgt COLORS 0, 16777215 PIXEL

cVend1 := space(6)
cVend2 := "ZZZZZZ"

cCli1  := space(6)
cCli2  := "ZZZZZZ"

cParc1 := space(6)
cParc2 := "ZZZZZZ"

cCid1  := space(6)
cCid2  := "ZZZZZZ"

cUf1   := space(2)
cUf2   := "ZZ"

cProd1 := space(4)
cProd2 := "ZZZZ"

cAssis := space(6)


/* Excluido no dia 09/11/11
@ 104, 011 SAY oSay19 PROMPT "Vendedor"  SIZE 025, 011 OF oDlgt COLORS 0, 16777215 PIXEL
@ 10	4, 046 MSGET oGetVend1 VAR cVend1 f3 "SA3" SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 104, 084 SAY Ate PROMPT "Ate" SIZE 010, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 104, 098 MSGET oGetVend2 VAR cVend2 f3 "SA3" SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL

@ 119, 011 SAY oSay20 PROMPT "Cliente"  SIZE 025, 011 OF oDlgt COLORS 0, 16777215 PIXEL
@ 119, 046 MSGET oGetCli1 VAR cCli1 f3 "SA1" SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 119, 084 SAY oSay1 PROMPT "Ate" SIZE 010, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 119, 098 MSGET oGetCli2 VAR cCli2 f3 "SA1" SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL

@ 134, 011 SAY oSay21 PROMPT "Parceiro" SIZE 025, 011 OF oDlgt COLORS 0, 16777215 PIXEL
@ 134, 046 MSGET oGetParc1 VAR cParc1 f3 "SA1" SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 134, 084 SAY oSay5 PROMPT "Ate" SIZE 010, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 134, 098 MSGET oGetParc2 VAR cParc2 f3 "SA1" SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL

@ 149, 011 SAY oSay22 PROMPT "Cidade" SIZE 025, 011 OF oDlgt COLORS 0, 16777215 PIXEL
@ 149, 046 MSGET oGetCid1 VAR cCid1 SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 149, 084 SAY oSay6 PROMPT "Ate" SIZE 010, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 149, 098 MSGET oGetCid2 VAR cCid2 SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL

@ 164, 011 SAY oSay23 PROMPT "U.F." SIZE 025, 011 OF oDlgt COLORS 0, 16777215 PIXEL
@ 164, 046 MSGET oGetUf1 VAR cUf1 SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 164, 084 SAY oSay7 PROMPT "Ate" SIZE 010, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 164, 098 MSGET oGet1Uf2 VAR cUf2 SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL

//@ 179, 011 SAY oSay26 PROMPT "Segmento" SIZE 025, 011 OF oDlgt COLORS 0, 16777215 PIXEL
//@ 179, 046 MSGET oGetSegm1 VAR cSegm1 SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL
//@ 179, 084 SAY oSay2 PROMPT "Ate" SIZE 010, 010 OF oDlgt COLORS 0, 16777215 PIXEL
//@ 179, 098 MSGET oGetSegm2 VAR cSegm2 SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL

@ 179, 011 SAY oSay25 PROMPT "Linha" SIZE 025, 011 OF oDlgt COLORS 0, 16777215 PIXEL
@ 179, 046 MSGET oGetProd1 VAR cProd1 SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 179, 084 SAY oSay3 PROMPT "Ate" SIZE 010, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 179, 098 MSGET oGetProd2 VAR cProd2 SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL

@ 194, 011 SAY oSay18 PROMPT "Assistente" SIZE 025, 011 OF oDlgt COLORS 0, 16777215 PIXEL
@ 194, 046 MSGET oGetAss VAR cAssis SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL
*/
// SSI 9496
@ 230, 011 SAY oSay17 PROMPT "PerÌodo (⁄ltimos 3 meses):" SIZE 090, 007 OF oDlgt COLORS 0, 16777215 PIXEL
@ 230, 080 MSGET oGetDt1 VAR dEmis1 SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 230, 123 SAY Ate PROMPT "Ate" SIZE 010, 010 OF oDlgt COLORS 0, 16777215 PIXEL
@ 230, 140 MSGET oGetDt2 VAR dEmis2 SIZE 030, 010 OF oDlgt COLORS 0, 16777215 PIXEL

@ 100, 100 SAY Produtos PROMPT "ProjeÁ„o de Produtos" Font oFnt1 SIZE 100, 011 OF oDlgt COLORS CLR_BLUE PIXEL

//390
//oGetD := MSGetDados():New(155,020,280,460,3,"u_bLinOk()","u_bTudOk()",,.T.,aAltCpo,,,999999)   
//oGetD := MSGetDados():New(111,05 ,220,490,3,,,,.T.,aAlter,,,999999)   
oGetD := MsNewGetDados():New(111,05,220,490,nOpcNewGd,{||U_Orta349LOk()},{||U_Orta349TOk()},"",aAlter,0,999999,NIL	,NIL,{||.T.},oDlgt,aHeader,aCols)

//oGetD := MSGetDados():New(111,05 ,220,490,3,"U_Orta348LOk","U_Orta348TOk",,.T.,aAlter,,,999999)   

//@ 111, 05 TO 220,390 MULTILINE Modify Delete


//160  20        310
//@ 230, 011 CHECKBOX oChkRes  VAR lChkRes  PROMPT "Somente Resumo"   SIZE 060, 008 OF oDlgt COLORS 0, 16777215 PIXEL

@ 010, 095  TO  096, 088  OF oDlgt COLOR 255,255,255  PIXEL
@ 010, 180  TO  087, 181  OF oDlgt COLOR 255,255,255  PIXEL
@ 093, 008  TO  094, 700  OF oDlgt COLOR 255,255,255  PIXEL
//@ 105, 145  TO  315, 146  OF oDlgt COLOR 255,255,255  PIXEL


@ 230, 200 BUTTON oBTNGDPesq PROMPT OemToAnsi("&Pesquisar") SIZE 080,010 ACTION { || MyGdSeek( @oGetD , "Pesquisar" , oGetD:aHeader, oGetD:aCols , .T. ) } OF oDlgt PIXEL

//@ 230, 310 BmpButton Type 01 Action(IF(oGetD:TudoOk(),(Close(oDlgt),(aCols:=oGetD:aCols,fOR048())),.F.))
//cGDTudoOk	:= oGetD:cTudoOk
//@ 230, 310 BmpButton Type 01 Action(IF(&cGDTudoOk.(oGetD:oBrowse,),(Close(oDlgt),fOR048()),.F.))

@ 230, 310 BmpButton Type 01 Action(IF(oGetD:TudoOk(),(Close(oDlgt),aCols:=oGetD:aCols,fOR048(cProj)),.F.))

@ 230, 361 BmpButton Type 02 Action(Close(oDlgt))

ACTIVATE MSDIALOG oDlgt CENTERED

Return

Static Function MyGDSeek(oGD,cTitle,aHeader,aCols,lOrdena)
	Local bErrorblock	:= Errorblock({|e|Break(e)})
	Local lOk			:= .T.
	BEGIN SEQUENCE
		GdSeek(@oGD,@cTitle,@aHeader,@aCols,@lOrdena)
	RECOVER
		lOk				:= .F.
	END SEQUENCE	
	ErrorBlock(bErrorBlock)
Return(lOk)

**************************
Static Function AtuMvPar(cProj)
**************************

//ValidPerg(cPerg)


if lChkSBM
	cTipo+="1,"
endif

if lChkFL
	cTipo+="2,"
endif

if lChkFC
	cTipo+="3,"
endif

MV_PAR01  := dEmis1
MV_PAR02  := dEmis2
MV_PAR03  := cAssis
MV_PAR04  := cVend1
MV_PAR05  := cVend2
MV_PAR06  := cProd1
MV_PAR07  := cProd2
MV_PAR08  := cUf1
MV_PAR09  := cUf2
MV_PAR10  := cCid1
MV_PAR11  := cCid2
MV_PAR12  := cCli1
MV_PAR13  := cCli2
MV_PAR14  := cParc1
MV_PAR15  := cParc2
MV_PAR17  := nDg
MV_PAR18  := nFin
MV_PAR19  := nQtd
MV_PAR20  := nDescExt // DESCONTO EXTRA
MV_PAR23  := substr(cTipo,1,len(cTipo)-1)
MV_PAR24  := padl(cTab,3,'0')
MV_PAR25  := cRef
MV_PAR26  := cProj
MV_PAR30  := lImptot  //somente totais
MV_PAR31  := lQtdZero //oculta itens com qtd zero
MV_PAR32  := lMedper  //mostra qtd media



/*
for _nVez:=1 to 26
_cVez:=strzero(_nVez,2)
_xValor:='mv_par'+_cVez
_xValor:=&_xValor
_cConteudo:=''
if sx1->(dbseek(padr(cPerg,len(sx1->x1_grupo))+_cVez,.f.).and.reclock(alias(),.f.))
if sx1->x1_tipo=='D'
_cConteudo:="'"+dtoc(_xValor)+"'"
elseif sx1->(x1_tipo=='N')//.and.x1_gsc<>'G')
_cConteudo:=alltrim(str(_xValor,14,5))
// Elimina os zeros ‡ direita depois do ponto decimal
do while .t.
if right(_cConteudo,1)=='0'
_cConteudo:=left(_cConteudo,len(_cConteudo)-1)
else
exit
endif
enddo
endif
if sx1->x1_gsc=='C'
sx1->x1_presel:=_xValor
elseif sx1->x1_tipo$'DN'
sx1->x1_cnt01:=_cConteudo
else
sx1->x1_cnt01:=_xValor
endif
sx1->(msunlock())
endif
next
*/

RETURN .T.



User Function LCERORTR48()
local npmarfil := 0
                   
areact := getarea()

If empty(ctab) 
  Alert("Tabela em branco. Favor preencher o codigo da tabela.")
  return(.f.)
endif

cprod      := aCols[N,1]
cdescpro   := aCols[N,3]
nprcdig    := M->Z6_PRCDIG
npmarfil   := aCols[N,5]   

// 04/02/2015 - Fabio Costa - solicitaÁ„o do Sr.Rubens
if nprcdig > npmarfil+(npmarfil*0.1)+(npmarfil*gvaria(cRef))
  Alert("O PreÁo n„o pode possuir mais de 10% de variaÁ„o alÈm do previsto em relaÁ„o a Marfil")
  return(.f.)
endif                       

If Len(Alltrim(cProd))==4
	cQuery44 := "SELECT ZV_VENDA DA1_PRCVEN, ZV_CUSTO DA1_XCUSTO, 0 B1_XGUELMT, 0 B1_XRESSAR "
	cQuery44 += "  FROM "+RETSQLNAME("SZV")+" SZV "
	cQuery44 += " WHERE SZV.D_E_L_E_T_ = ' '"
	cQuery44 += "   AND ZV_TABELA = '0"+ctab+"' "
	cQuery44 += "   AND ZV_GRUPO  = '"+cprod+"' "
	cQuery44 += "   AND ZV_FILIAL = '"+xfilial("SZV")+"' "
Else
	cQuery44 := "SELECT DA1_PRCVEN,DA1_XCUSTO,B1_XGUELMT,B1_XRESSAR "
	cQuery44 += "  FROM "+RETSQLNAME("DA1")+" DA1, "+RETSQLNAME("SB1")+" SB1 "
	cQuery44 += " WHERE DA1.d_e_l_e_t_ = ' '  AND SB1.d_e_l_e_t_ = ' ' "
	cQuery44 += "   AND DA1_CODTAB = '0"+ctab+"' "
	cQuery44 += "   AND DA1_CODPRO = '"+cprod+"' "
	cQuery44 += "   AND DA1_FILIAL = '"+xfilial("DA1")+"' "
	cQuery44 += "   AND B1_FILIAL  = '"+xfilial("SB1")+"' "
	cQuery44 += "   AND B1_COD     = DA1_CODPRO "
Endif
If Select("T44") > 0
	T44->(DbCloseArea())
EndIf
memowrit("c:\ORTA349_LCERORTR48.sql",cQuery44)
TcQuery cQuery44 Alias "T44" New
dbselectarea("T44")
//dbgotop()

If EOF()
  T44->(dbCloseArea())
  restarea(areact)
  Alert("O produto '"+AllTrim(cprod)+"' n„o existe na tabela marfil '0"+AllTrim(ctab)+"'.")
  return(.f.)
EndIf

if Len(Alltrim(cProd))>4       
   nmarfil    := T44->DA1_PRCVEN * (1+gvaria(cRef))
Else
   nmarfil    := T44->DA1_PRCVEN
Endif
nguelta    := T44->B1_XGUELMT

nresar     := T44->B1_XRESSAR                                                          

nguelta    := 0.00

nresar     := 0.00

                             
nvaldig    := M->Z6_PRCDIG //aCols[N,4]

aCols[N,5] := nmarfil


nxperc := ((100 * nprcdig ) / nmarfil ) - 100
         
aCols[N,2] := nxperc

*********** calculo do MIX *************************************************


n0         := ( nvaldig * (nguelta + nresar ) ) / 100
n0         := 0.00 //( nvaldig * (nguelta + nresar ) ) / 100
         
n00        := nvaldig - n0

n1         := n00 / T44->DA1_XCUSTO

n2         := n1 - 1

n3         := (n2 / n1) * 100
                      
                        
aCols[N,8] := n3 


*****************************************************************************

If Len(Alltrim(cProd))==4
	aCols[N,9] := AllTrim(cProd)+"_"
Else
	aCols[N,9] := Posicione("SB1",1,xFilial("SB1")+padr(cProd,15),"B1_GRUPO")
EndIf
                               
If Len(Alltrim(cProd))==4
	aDesGrp := {}

	For nDes := 1 To Len(aCols)
		If Alltrim(aCols[nDes,9]) == Alltrim(cProd) .And. aCols[nDes,2] < 0
			aAdd(aDesGrp, aCols[nDes,2])
		EndIf
	Next nDes
	                  
	If Len(aDesGrp) > 0 .And. nxperc < 0
		aDesGrp := aSort(aDesGrp,,, {|x,y| x > y }) 
		nDesGrp := aDesGrp[1]
		
		If Abs(nxperc) > Abs(nDesGrp) .And. nDesGrp <> 0
			Alert("O PreÁo de produto sob medida n„o pode possuir desconto maior que o produto referencia.")
			aCols[N,2]   := nDesGrp
			M->Z6_PRCDIG := aCols[N,5] + (aCols[N,5] * (nDesGrp/100))
		EndIf
	Endif
Endif

dbselectarea("T44")
T44->(dbCloseArea())

oDlgt:Refresh()

restarea(areact)     

Return(.t.)                                                 
                                         




User Function LCERCODPR()

Local cReadVar
Local aFieldPos	:= Array(0)
Local cQuery:=""
areact := getarea()

If empty(ctab)
	Alert("Tabela em branco. Favor preencher o codigo da tabela.")
	return(.f.)
endif

cprod      := M->Z6_CODPROD //Z6_PRCDIG //aCols[N,1]
cdescpro   := aCols[N,3]
nprcdig    := 0.00 //M->Z6_PRCDIG
if Len(Alltrim(cProd))>4
	//cQuery := "select DA1_PRCVEN,DA1_XCUSTO,B1_COD,B1_XGUELMT,B1_XRESSAR,B1_DESC "
	//cQuery += "  from siga."+RETSQLNAME("DA1")+" DA, siga."+RETSQLNAME("SB1")+" SB1 "
	//cQuery += "  where DA1.d_e_l_e_t_ = ' '  AND SB1.d_e_l_e_t_ = ' ' "
	//cQuery += "  and DA1_CODTAB = '0"+ctab+"' "
	//cQuery += "  AND DA1_CODPRO = '"+cprod+"' "
	//cQuery += "  AND DA1_FILIAL = '"+xfilial("DA1")+"' "
	//cQuery += "  AND B1_FILIAL  = '"+xfilial("SB1")+"' "
	//cQuery += "  AND B1_COD     = DA1_CODPRO "
	cChave:=xFilial("DA1")+"0"+cTab+cProd
	DbSelectArea("DA1")
	DbSetOrder(1)
	DbSeek(cChave)
	if Alltrim(DA1->DA1_FILIAL+DA1_CODTAB+DA1_CODPRO)==Alltrim(cChave)
		nPreco:=DA1->DA1_PRCVEN
		nCusto:=DA1->DA1_XCUSTO
	Else
		nPreco:=0
		nCusto:=0
	Endif
    aCols[N,3] := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")
    nPreco *= (1+gvaria(cRef))
	aCols[N,9] := Posicione("SB1",1,xFilial("SB1")+padr(cProd,15),"B1_GRUPO")
Else
	cChave:=xFilial("SZV")+"0"+cTab+cProd
	DbSelectArea("SZV")
	DbSetOrder(1)
	DbSeek(cChave)
	if Alltrim(SZV->ZV_FILIAL+ZV_TABELA+ZV_GRUPO)==Alltrim(cChave)
		nPreco:=SZV->ZV_VENDA
		nCusto:=SZV->ZV_CUSTO
	Else
		nPreco:=0
		nCusto:=0
	Endif
    aCols[N,3] := Posicione("SBM",1,xFilial("SBM")+cProd,"BM_DESC") + " SOB-MEDIDA M3"
	aCols[N,9] := cProd
Endif
aCols[N,5] := nPreco
aCols[N,6] := nCusto
aCols[N,7] := 0.00
aCols[N,8] := 0.00

oDlgt:Refresh()

IF IsInCallStack("U_ORTA349b")  	
	aAdd( aFieldPos , { "Z6_CODPROD" , "Z6_PRCDIG" } )
	cReadVar := ReadVar()
	GdGoToCol(@oGetD:oBrowse,@cReadVar,@aFieldPos)
EndIF

restarea(areact)
Return(.t.)   

Static Function RotCopia(cProj)
                                               
Local aArea  			:= GetArea()
Local oDlgp
Local cImage          := "logorto3.jpg"
Local oProj,oTab,oArea,oRef,oProj2
//Local cProj           := IF(Type("cProj")=="C".and.!Empty(cProj),cProj,space(6))
Local cProj2          := space(6) 
Local cTab            := space(3)
Local cArea           := Space(1)
Local cRef            := Space(1)
Local nDESCEXT        := 0
Local lAutoriz        := ""
Local cprojseg        := space(6)
Local cprorseg        := space(20)
Local lF3SZ6PIL		  := .F.

Local oTGroup1
Local oTGroup2
Local oJPGOrto

SXB->( dbSetOrder( 1 ) ) //XB_ALIAS+XB_TIPO+XB_SEQ+XB_COLUNA
lF3SZ6PIL := SXB->( MsSeek("SZ6PIL" , .F. ) )

DEFINE Font oFont1 Name "Arial" Size 0,-13
Define MSDialog oDlgp Title OemToAnsi("Copia de Projecao do Mapa de ComercializaÁ„o.") From 000,000 To 230,390 Pixel

oTGroup1 := TGroup():New(000,002,085,197,"",oDlgp,NIL,NIL,.T.,NIL)

//@ 015,010 Say "Tabela    :"  Size 80,10 Font oFont1 Pixel of oTGroup1
//@ 015,048 MsGet OTab  Var cTab Size 25,10 Font oFont1 F3 "DA0" Pixel of oTGroup1 VALID ExistCpo("DA0",cTab)
//@ 035,010 Say "Nova Ref. :"  Size 80,10 Font oFont1 Pixel of oTGroup1
//@ 035,048 MsGet ORef Var cRef PICTURE "@!" Size 15,10 Font oFont1 Pixel of oTGroup1
@ 015,010 Say "N∫ Projecao Antiga:"  Size 100,10 Font oFont1 Pixel of oTGroup1
@ 015,088 MsGet OPROJ Var cProj PICTURE "@!"  Size 35,10 Font oFont1 valid fValProj(cProj,cProj2) Pixel of oTGroup1
IF (lF3SZ6PIL)
	OPROJ:cF3 := "SZ6PIL"
EndIF
@ 022,006 SAY oSay1 PROMPT "[2] Comercial - [99] Tabela - [99] Ano - [X] Ref." Font oFnt2 SIZE 180, 012 OF oDlg COLORS 0, 16777215 PIXEL

@ 035,010 Say "N∫ Projecao Nova:"    Size 100,10 Font oFont1 Pixel of oTGroup1
@ 035,088 MsGet OPROJ2 Var cProj2 PICTURE "@!"  Size 35,10 Font oFont1 valid fValProj(cProj,cProj2) Pixel of oTGroup1
IF (lF3SZ6PIL)
	OPROJ2:cF3 := "SZ6PIL"
EndIF
@ 040,006 SAY oSay1 PROMPT "[2] Comercial - [99] Tabela - [99] Ano - [X] Ref." Font oFnt2 SIZE 180, 012 OF oDlg COLORS 0, 16777215 PIXEL

If cEmpAnt $ "23"
	@ 060,025 Say "A -  0% / B -  5% / C - 10% / D - 15% / E - 20% / F - 25% / G - 30% / H - 35% / I - 40%"    Size 150,10 Font oFont1 Pixel of oTGroup1
Else
	@ 060,025 Say "A -  0% / B -  5% / C - 10% / D - 15% / E - 20% / F - 25% / G - 30% / H - 35% / I - 40%"    Size 150,10 Font oFont1 Pixel of oTGroup1
EndIf

oTGroup2 := TGroup():New(086,002,115,197,"",oDlgp,NIL,NIL,.T.,NIL)
                                                                //LerZ6_DA1(cTab,cRef)
@ 091,100 Button OemToAnsi("OK")   Size 040,020 Action ( Processa({|lEnd| Gr_Copia(cProj,cProj2)}, "Aguarde...","Gerando Copia da Projecao...", .T. ),Close(oDlgp)) Pixel of oTGroup2
@ 091,148 Button OemToAnsi("Sair") Size 040,020 Action ( Close(oDlgp)) Pixel of oTGroup2

IF File(cImage)
	@ 087,003 BITMAP oJPGOrto FILE cImage SIZE 005,005 PIXEL BORDER OF oTGroup2
	oJPGOrto:lAutoSize   := .T.
	oJPGOrto:lStretch    := .F.
	oJPGOrto:Refresh()
EndIF

OPROJ2:SetFocus()

ACTIVATE MSDIALOG oDlgp CENTERED ON INIT ( UniqueKey() )

RETURN


Return
                                                    


Static Function Gr_Copia(cproj,cproj2)
                                                
Local cref:= substr(cproj2,6,1)
Local ctab:= "0"+substr(cproj2,2,2)
		nSZ6Order:= RetOrder("SZ6","Z6_FILIAL+Z6_NUMPROJ")
		SZ6->(dbSetOrder( nSZ6Order ))
		IF SZ6->(dbSeek( xFilial("SZ6")+cproj2 , .F. ) )
			If MsgYesNo("Nova Projecao Ja Existe. Deseja sobrescrever?")
				cQuery:="DELETE "+RetSQLName("SZ6")+" WHERE Z6_NUMPROJ = '"+cproj2+"' "
				TCSQLExec(cQuery)
			else
				Return()
			endif
		EndIF


Alert("Inicio da Copia. Projecao Antiga: "+cproj+" - Projecao Nova: "+cproj2) 
                               
cQy := "SELECT  "
cQy += " Z6_DTEMII , "
cQy += " Z6_DTEMIF , "
cQy += " Z6_ASSISTE,  "
cQy += " Z6_VENDI , "
cQy += " Z6_VENDF , "
cQy += " Z6_LINHAI , "
cQy += " Z6_LINHAF , "
cQy += " Z6_UFINI , "
cQy += " Z6_UFFIM , "
cQy += " Z6_CIDINI , "
cQy += " Z6_CIDFIM , "
cQy += " Z6_CLIINI , "
cQy += " Z6_CLIFIM , "
cQy += " Z6_PARCEI , "
cQy += " Z6_PARCEF , "
cQy += " Z6_DTPROJ , "
cQy += " Z6_PROJPR , "
cQy += " Z6_DESCDG , "
cQy += " Z6_SEGINI , "
cQy += " Z6_SEGFIN , "
cQy += " Z6_TIPPRO , "
cQy += " Z6_TABVEN , "
cQy += " Z6_REFTAB , "
cQy += " Z6_SEMPRO , "
cQy += " Z6_ULTPRO , "
cQy += " Z6_NOVPRO , "
cQy += " Z6_DESFIN , "
cQy += " Z6_DESQTD , "
cQy += " Z6_DESFID , "
cQy += " Z6_CODPROD , "
cQy += " Z6_NUMPROJ , "
cQy += " Z6_DESCPRO , "
cQy += " Z6_USERLGI , "
cQy += " Z6_USERLGA , "
cQy += " Z6_PRCDIG , "
cQy += " Z6_CUSTO , "
cQy += " Z6_GUERES, " 
cQy += " Z6_MIX , "
cQy += " Z6_PRCDA1 , "
cQy += " Z6_SEGMENT  "
cQy += " FROM "+RETSQLNAME("SZ6")+" Z6  "
cQy += " WHERE Z6_FILIAL   = '"+xFilial("SZ6")+"' "
cQy += " AND Z6_NUMPROJ    = '"+cproj+"' "
cQy += " AND Z6.D_E_L_E_T_ = ' ' "
cQy += " AND Z6_CODPROD   <> ' ' "
memowrit("c:\ORTA348_copia.txt",cQy)
TcQuery cQy Alias "TZ6" New
dbselectarea("TZ6")
dbgotop()

while !TZ6->(eof())
	aSZ6={}
	aadd(aSZ6,Tz6->Z6_Codprod)  //01
	aadd(aSZ6,Tz6->Z6_Dtemii)   //02
	aadd(aSZ6,Tz6->Z6_Dtemif)   //03
	aadd(aSZ6,Tz6->Z6_Assiste)  //04
	aadd(aSZ6,Tz6->Z6_Vendi)    //05
	aadd(aSZ6,Tz6->Z6_Vendf)    //06
	aadd(aSZ6,Tz6->Z6_Linhai)   //07
	aadd(aSZ6,Tz6->Z6_Linhaf)   //08
	aadd(aSZ6,Tz6->Z6_Ufini)    //09
	aadd(aSZ6,Tz6->Z6_Uffim)    //10
	aadd(aSZ6,Tz6->Z6_Cidini)   //11
	aadd(aSZ6,Tz6->Z6_Cidfim)   //12
	aadd(aSZ6,Tz6->Z6_Cliini)   //13
	aadd(aSZ6,Tz6->Z6_Clifim)   //14
	aadd(aSZ6,Tz6->Z6_Parcei)   //15
	aadd(aSZ6,Tz6->Z6_Parcef)   //16
	aadd(aSZ6,Tz6->Z6_Dtproj)   //17
	aadd(aSZ6,Tz6->Z6_Projpr)   //18
	aadd(aSZ6,Tz6->Z6_Descdg)   //19
	aadd(aSZ6,Tz6->Z6_Segini)   //20
	aadd(aSZ6,Tz6->Z6_Segfin)   //21
	aadd(aSZ6,Tz6->Z6_Tippro)   //22
	aadd(aSZ6,Tz6->Z6_Sempro)   //23
	aadd(aSZ6,Tz6->Z6_Ultpro)   //24
	aadd(aSZ6,Tz6->Z6_Novpro)   //25
	aadd(aSZ6,Tz6->Z6_Desfin)   //26
	aadd(aSZ6,Tz6->Z6_Desqtd)   //27
	aadd(aSZ6,Tz6->Z6_Desfid)   //28
	aadd(aSZ6,Tz6->Z6_Gueres)   //29
	aadd(aSZ6,Tz6->Z6_Segment)  //30            
	aadd(aSZ6,Tz6->Z6_Descpro)  //31

/*    naum := 0
	If cEmpAnt $ "23"
		If AllTrim(cRef) $ "A"
			naum	:= 00
		ElseIf AllTrim(cRef) $ "B"
			naum	:= 05
		ElseIf AllTrim(cRef) $ "C"
			naum	:= 10
		ElseIf AllTrim(cRef) $ "D"
			naum	:= 15
		ElseIf AllTrim(cRef) $ "E"
			naum	:= 20
		ElseIf AllTrim(cRef) $ "F"
			naum	:= 25
		Else
			naum	:= 30
		Endif
	Else
		If AllTrim(cRef) $ "A|F|M"
			naum	:= 00
		ElseIf AllTrim(cRef) $ "B|G"
			naum	:= 05
		ElseIf AllTrim(cRef) $ "C|H"
			naum	:= 10
		ElseIf AllTrim(cRef) $ "D|I"
			naum	:= 15
		Else
			naum	:= 20
		Endif
	EndIf*/
    
	if len(AllTrim(aSZ6[1]))==4
		ccq6 := "SELECT ZV_GRUPO DA1_CODPRO, ZV_VENDA DA1_PRCVEN, ZV_CUSTO DA1_XCUSTO   "
		ccq6 += "  FROM "+RETSQLNAME("SZV")+"  "
		ccq6 += " WHERE D_E_L_E_T_ =  ' ' "
		ccq6 += "	AND ZV_GRUPO =  '"+aSZ6[1]+"' " 
		ccq6 += "	AND ZV_TABELA =  '"+cTab+"' "
		ccq6 += "	AND ZV_FILIAL =  '"+xfilial("SZV")+"' "
	else
		ccq6 := "SELECT DA1_CODPRO,DA1_PRCVEN,DA1_XCUSTO   "
		ccq6 += "  FROM SIGA."+RETSQLNAME("DA1")+"  "
		ccq6 += " WHERE D_E_L_E_T_ = ' ' "
		ccq6 += "	AND DA1_CODPRO =  '"+aSZ6[1]+"' " //1041522856' "
		ccq6 += "	AND DA1_CODTAB =  '"+cTab+"' "
		ccq6 += "	AND DA1_FILIAL =  '"+xfilial("DA1")+"' "
	Endif
	TcQuery ccq6 Alias "MF6" New
	dbselectarea("MF6")
	dbgotop()	                                            
	nPreco := MF6->DA1_PRCVEN * ( 1 + gvaria(cRef) )

/*    If len(AllTrim(aSZ6[1]))>4
	   nPreco := MF6->DA1_PRCVEN + ( ( MF6->DA1_PRCVEN * naum ) / 100 )
	Else
	   nPreco := MF6->DA1_PRCVEN
	Endif*/
	nCusto := MF6->DA1_XCUSTO
	dbselectarea("MF6")
	MF6->(dbCloseArea())			

	If Len(AllTrim(aSZ6[1])) > 4
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1") + ALLTRIM(aSZ6[1]))
			If AllTrim(SB1->B1_XTABUN) == 'N'
				dbselectarea("TZ6")
				TZ6->( dbskip() )
				Loop
			EndIf
		EndIf
	EndIf

	dbselectarea("TZ6")
	RecLock("SZ6",.T.)
	SZ6->Z6_FILIAL  := xFilial("SZ6")
	SZ6->Z6_DTGERA 	:= dDatabase
	SZ6->Z6_HRGERA 	:= time()
	SZ6->Z6_CDUSUA 	:= RetCodUsr()
	SZ6->Z6_NMUSUA  := substr(cUsuario,7,15)
	SZ6->Z6_TABVEN 	:= substr(cTab,2,2)
    SZ6->Z6_CODPROD	:= aSZ6[01]
	SZ6->Z6_DTEMII 	:= stod(aSZ6[02])
	SZ6->Z6_DTEMIF 	:= stod(aSZ6[03])
		sz6->Z6_Assiste := 	aSZ6[04]
		sz6->Z6_Vendi 	:= 	aSZ6[05]
		sz6->Z6_Vendf 	:= 	aSZ6[06]
		sz6->Z6_Linhai 	:= 	aSZ6[07]
		sz6->Z6_Linhaf 	:= 	aSZ6[08]
		sz6->Z6_Ufini 	:= 	aSZ6[09]
		sz6->Z6_Uffim 	:= 	aSZ6[10]
		sz6->Z6_Cidini 	:= 	aSZ6[11]
		sz6->Z6_Cidfim 	:= 	aSZ6[12]
		sz6->Z6_Cliini 	:= 	aSZ6[13]
		sz6->Z6_Clifim 	:= 	aSZ6[14]
		sz6->Z6_Parcei 	:= 	aSZ6[15]
		sz6->Z6_Parcef 	:= 	aSZ6[16]
		sz6->Z6_Dtproj 	:= 	stod(aSZ6[17])
		sz6->Z6_Projpr 	:= 	aSZ6[18]
		sz6->Z6_Descdg 	:= 	aSZ6[19]
		sz6->Z6_Segini 	:= 	aSZ6[20]
		sz6->Z6_Segfin 	:= 	aSZ6[21]
		sz6->Z6_Tippro 	:= 	aSZ6[22]
		sz6->Z6_Sempro 	:= 	aSZ6[23]
		sz6->Z6_Ultpro 	:= 	aSZ6[24]
		sz6->Z6_Novpro 	:= 	aSZ6[25]
		sz6->Z6_Desfin 	:= 	aSZ6[26]
		sz6->Z6_Desqtd 	:= 	aSZ6[27]
		sz6->Z6_Desfid 	:= 	aSZ6[28]
		sz6->Z6_Gueres 	:= 	aSZ6[29]
		sz6->Z6_Segment	:= 	aSZ6[30]
		sz6->Z6_Descpro	:= 	aSZ6[31]
		sz6->Z6_Reftab 	:= 	cRef
		sz6->Z6_Numproj	:= 	cProj2
		sz6->Z6_Prcdig 	:= 	nPreco+round(nPreco*aSZ6[31]/100,2)
		sz6->Z6_Mix 	:= 	round(((nPreco+round(nPreco*aSZ6[31]/100,2)-nCusto)/(nPreco+round(nPreco*aSZ6[31]/100,2)))*100,2)
		sz6->Z6_Prcda1 	:= 	nPreco
		SZ6->Z6_CUSTO   :=  nCusto
		SZ6->( MsUnLock() )
    
	TZ6->( dbskip() )
	
Enddo

dbselectarea("TZ6")
TZ6->(dbCloseArea())

Alert("Fim da Copia. Projecao Nova: "+cproj2) 


Return




******************************
Static Function fOR048(cProj)
******************************

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "MAPA DE COMERCIALIZACAO"
Local cPict          := ""
Local titulo         := "MAPA COMERCIALIZACAO    C O M E R C I A L"

Local imprime        := .T.
Local _cTab          := ""
Local _ctabela       := ""
Local _nPliq         := 0
Local _Sobrou        := 0
Local lPerg          := .T.

Private oPrn

dbSelectArea("SD2")
dbSetOrder(1)

**************************           
//lChkCom  := .f.                        
lChkLoja := .f.
lChkLExc := .f.
**************************           

if empty(cTab) .and. empty(cRef) .and. ( !lchkcom .or. !lckloja .or. !lchklExc)
	MsgBox("Informe a tabela de preco / referencia e/ou escolha um dos segmentos.!","Atencao","ALERT")
	return .t.
endif

if nOpt == 1
	GrvParam(.F.,cProj)
elseif nOpt == 2
	If MsgYesNo("Deseja sobrescrever a projeÁ„o ?")
		GrvParam(.T.,cProj)
	endif
endif

If !MsgYesNo("Deseja emitir o relatÛrio de comercializaÁ„o?")
	Return
EndIf

AtuMvPar(cProj)
oPrn := TReport():New("0RTA349",Titulo,,{|oPrn| RunRReport(oPrn,cProj)},Titulo)
oPrn:SetLandScape()
oPrn:HideHeader() //oculta cabeÁalho
oPrn:HideFooter() //oculta rodapÈ
oPrn:oPage:nPaperSize == 9
oPrn:SetEdit(.F.)         // Bloqueia personalizar
oPrn:NoUserFilter()       // nao permite criar FIltro de usuario
oPrn:PrintDialog()
oPrn:StartPage()
/*
//wnRel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

nTipo := If(aReturn[4]==1,GetMv('MV_COMP'),GetMv('MV_NORM'))

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif
*/
//RptStatus({|lEnd| RunRReport(@lEnd,wnRel,Tamanho,Titulo)},Titulo)

Return Nil




Static Function RunRReport(oPrn,cProj)
Local nOrdem
Local lSobMedida := .f.

Private Cabec1 := ""
Private Cabec2 := ""
Private nVlMoeda := 0
Private _nLucroFinal := 0
Private _nLucroPV := 0
Private dDataIni := mv_par01
Private dDataFim := mv_par02
Private nTPMarfil  := 0
Private nTPrcFab   := 0
Private nTCusto    := 0
Private nTTPrat    := 0
Private nTPrcUni   := 0
Private nTPreco    := 0
Private nTPPrat    := 0
Private nTRentab1  := 0
Private nTPartFin  := 0
Private nTContrb1  := 0
Private nTTQuant   := 0
Private nTTPMarfil := 0
Private nTTCusto   := 0
Private nTTPrcFab  := 0
Private nTTMarkup  := 0
Private nTTPartFin := 0
Private nTTTPrat   := 0
Private nTTTVenda  := 0
Private nTTTotal   := 0

Private nSMQuant      := 0
Private nSMPMarfil    := 0
Private nSMPLIQ       := 0
Private nSMCusto      := 0
Private nSMSobrou     := 0
Private nSMPartFin    := 0
Private nSMRentab1    := 0
Private nSMMarkup     := 0
Private nSMPrecoUni   := 0
Private nSMDescAcr    := 0
Private nSMNPrcUni    := 0
Private nSMNMarkup    := 0
Private nSMSobra      := 0
Private nSMDG         := 0
Private nSMLucroFinal := 0
Private nSMLucroPV    := 0

nVlMoeda:= 25.85

Private oCouNew12	:= TFont():New( "Courier New",,11,,.T.,,,,,.F.)
Private oCouNew09	:= TFont():New( "Courier New",,10,,.T.,,,,,.F.)
Private oCouNew11	:= TFont():New( "Courier New",,11,,.T.,,,,,.F.)
Private oCouNew10	:= TFont():New( "Courier New",,10,,.T.,,,,,.F.)
Private MaxLin 		:= 2300
Private MaxCol 		:= 3300
Private lTot	    := .f.
Private lTot2	    := .f.
Private titulo		:= ""
Private aConItens   := {}
Private aTConItens  := {}
Private aImpDif		:= {}
Private aImpItens	:= {}
Private aTotItens	:= {}

Private nMarkup		:= 0.00
Private nPrecoUni	:= 0.00
Private nmarknovo	:= 0.00
Private nsobprnov	:= 0.00
Private ndgproj		:= 0.00
Private nlucfipr	:= 0.00
Private nMarcacao	:= 0.00
Private nRent		:= 0.00

Private tnLucro		:= 0.00
Private tnlucrotot	:= 0.00
Private tnlucroper	:= 0.00
Private tnlucfipr	:= 0.00
Private tnlucfiprt 	:= 0.00
Private tnlucprno	:= 0.00
Private tnMarcacao	:= 0.00
Private tnPMarfCom	:= 0.00
Private tnRent		:= 0.00
Private tVLRLUCRO	:= 0.00

Private	Ttnlucfipr	:= 0.00
Private	Ttnlucfiprt	:= 0.00
Private	Ttnlucprno	:= 0.00
Private	Ttmarcacao	:= 0.00
Private	Ttrent		:= 0.00

Private	TtnPMarfCom	:= 0.00	// preÁo marfil X comercializaÁ„o
Private	Ttnlucro	:= 0.00	// lucro
Private	Ttnlucrotot	:= 0.00 // lucro total
Private	Ttnlucroper	:= 0.00	// %lucro
Private	TtnMarcacao	:= 0.00	// MARC UP
Private	TtnRent 	:= 0.00	// Rent
Private TtVLRLUCRO 	:= 0.00
Private tnPMARF		:= 0.00
Private tnPMarfXCo  := 0.00
Private tnQtd		:= 0.00


Private nlucprno	:= 0.00
Private nprunipro	:= 0.00
Private tipocab		:= .t.
Private desacr		:= ""

Private nRefCom__A	:= GetMV("MV_XCOMA", .F., 1.00)
Private nRefCom__B	:= GetMV("MV_XCOMB", .F., 1.05)
Private nRefCom__C	:= GetMV("MV_XCOMC", .F., 1.10)
Private nRefCom__D	:= GetMV("MV_XCOMD", .F., 1.15)
Private nRefCom__E	:= GetMV("MV_XCOME", .F., 1.20)

nRefCom__F	:= 1.25
nRefCom__G	:= 1.30
nRefCom__H	:= 1.35
nRefCom__I	:= 1.40

Private nPag 		:= 1
Private cLogo := "lgrl" + cEmpAnt + ".bmp"


If !File(cLogo)
	cLogo := "lgrl" + cFilAnt + ".bmp"
EndIf

//oPrn := TReport():New("0RTA349",Titulo,,{|oPrn| GeraRel(oPrn)},Titulo)
//oPrn:Setup()
//oPrn:SetSize(297, 210)
cLogo := Iif(cLogo == Nil, ""  , cLogo)

dbSelectArea(cString)

nOrdem := aReturn[8]
dbSetOrder(nOrdem)

Titulo := ALLTRIM(Titulo)+" NO PERIODO DE "+dtoc(dEmis1)+" A "+dtoc(dEmis2)

cTab    := padl(Alltrim(cTab),3,'0')
_ctabela := padl(Alltrim(cTab),5,'0')+cRef
cSegm    :=""
cSegment :=""

**************************
//lChkCom  := .f.
lChkLoja := .f.
lChkLExc := .f.
**************************

if lChkCom
	//	cSegm += "'2','6',"
	//	cSegment+= "2,6,"
endif

if lChkLoja
	cSegm += "'3',"
	cSegment += "3,"
endif

if lChkLExc
	cSegm += "'4',"
	cSegment += "4,"
endif

cSegm    := substr(cSegm,1,len(cSegm)-1)
cSegment := substr(cSegment,1,len(cSegment)-1)

*************************

cSegm    :=""

**************************
//lChkCom  := .f.
lChkLoja := .f.
lChkLExc := .f.
**************************

if lChkCom
	cSegm += "'2','6',"
endif

if lChkLoja
	cSegm += "'3',"
endif

if lChkLExc
	cSegm += "'4',"
endif

cSegm    := substr(cSegm,1,len(cSegm)-1)
LeUPME()


ctpclii  := ""
ctpcliin := ""


if lchkpul 
   ctpclii := ctpclii + "'P',"
endif
               
if lchkesp 
   ctpclii := ctpclii +  "'E',"
endif
                 
if lchksp 
   ctpclii := ctpclii +  "'S',"
endif
               
cc1        := alltrim(ctpclii)
ctpcliin   := ""	
IF .NOT.(Empty(cc1))
	cc2        := substr(ctpclii,1,len(cc1)-1)
	ctpcliin   := "("+cc2+")"
EndIF

*********************************


nmedper := 0.00
nmedper := (mv_par02 - mv_par01)/30

cSql:= " SELECT * FROM ("
cSql+= "SELECT B1_GRUPO, B1_COD, B1_DESC, B1_XLARG, "
cSql+= "       B1_XCOMP, B1_XALT, DA1_CODTAB, DA1_CODPRO, DA1_PRCVEN, DA1_XCUSTO, BM_GRUPO, BM_XSUBGRU, BM_XORDMIX, X5_DESCRI, "
cSql+= "       BM_DESC, NVL(Z6_DESCPRO,0) Z6_DESCPRO, NVL(Z6_PRCDIG,ACP_XPRECO) PRCDIG, DA1_XCUSTO CUSTO, "
cSql+= "       NVL((SELECT SUM(QTDVEN) QTD "
cSql+= "              FROM V_MIX"+cfilemp+", "+RETSQLNAME("SA1")+" SA1 "
cSql+= "             WHERE SA1.D_E_L_E_T_ = ' ' "
cSql+= "               AND EMISSAO BETWEEN '"+DTOS(DEMIS1)+"' and '"+DTOS(DEMIS2)+"' "
cSql+= "               AND COD = SB1.B1_COD  "
cSql+= "               AND OPER IN ('01')    "
cSql+= "               AND A1_FILIAL = '"+XFILIAL("SA1")+"' "
If !Empty(ctpcliin)
	cSql += "          AND A1_XTPCLI IN "+ctpcliin+" "
EndIf
cSql+= "               AND A1_COD = CLIENTE),0) QTDVEN "
cSql+= "  FROM "+RETSQLNAME("SB1")+" SB1, "+RETSQLNAME("DA1")+" DA1, "+RETSQLNAME("SBM")+" SBM, "+RETSQLNAME("SX5")+" SX5, "
cSql+= "       "+RETSQLNAME("ACP")+" ACP, "+RETSQLNAME("SZ6")+" SZ6 "
cSql+= "  WHERE SB1.D_E_L_E_T_ = ' ' "
cSql+= "    AND DA1.D_E_L_E_T_ = ' ' "
cSql+= "    AND SBM.D_E_L_E_T_ = ' ' "
cSql+= "    AND SX5.D_E_L_E_T_ = ' ' "
cSql+= "    AND ACP.D_E_L_E_T_(+) = ' ' "
cSql+= "    AND SZ6.D_E_L_E_T_(+) = ' ' "
cSql+= "    AND DA1_FILIAL     = '"+XFILIAL("DA1")+"' "
cSql+= "    AND ACP_FILIAL(+)  = '"+XFILIAL("ACP")+"' "
cSql+= "    AND Z6_FILIAL(+)   = '"+XFILIAL("SZ6")+"' "
cSql+= "    AND B1_FILIAL      = '"+XFILIAL("SB1")+"' "
cSql+= "    AND BM_FILIAL      = '"+XFILIAL("SBM")+"' "
cSql+= "    AND X5_FILIAL      = '"+XFILIAL("SX5")+"' "
if cEmpAnt <> "22"
   cSql+= " AND B1_XSEGMEN IN ('2','6') "
endif
cSql+= "    AND B1_MSBLQL     = '2' "
cSql+= "    AND SUBSTR(B1_COD,1,1) in ('1', '4') "
cSql+= "    AND B1_TIPO IN ('TC', 'PA') "
cSql+= "    AND DA1_CODTAB    = '"+cTab+"' "
cSql+= "    AND B1_COD        = DA1_CODPRO "
cSql+= "    AND B1_XCODBAS    = ' ' "
cSql+= "    AND DA1_CODPRO    <> ' ' "
cSql+= "    AND B1_GRUPO      <> ' ' "
cSql+= "    AND B1_GRUPO      = BM_GRUPO "
cSql+= "    AND B1_XTABUN     = 'S' "
cSql+= "    AND BM_XSUBGRU    = X5_CHAVE "
cSql+= "    AND X5_TABELA     = 'ZA' "    
cSql+= "    AND DA1_CODPRO    = Z6_CODPROD(+) "    
cSql+= "    AND DA1_CODPRO    = ACP_CODPRO(+) "    
cSql+= "    AND ACP_CODREG(+) = '"+_cTabela+"' "
cSql+= "    AND Z6_NUMPROJ(+) = '"+cProj+"' "
If cEmpAnt=="10" //COLOCADO POR DUPIM NA EMERGENCIA DEPOIS TEM QUE VERIFICAR COMO FAZER COM PRODUTOS ENTRE UNIDADES
	cSql+= "    AND B1_COD NOT IN ('1090710101','1090710100') "
ENDIF
If !lChkFL
	cSql+= "    AND (B1_XFORLIN = '        ' OR B1_XFORLIN > '"+DToS(dDataBase-90)+"') "
endif
If !lchkfc
	cSql+= "    AND B1_XMODELO NOT IN ('000015','000017','000028','000029') "	 // ssi 38777
endif
If lChkSBM
	cSql+= " UNION "
	
	cSql+= " SELECT B1_GRUPO, '9999999999' B1_COD, BM_DESC B1_DESC, 0 B1_XLARG, 0 B1_XCOMP, 0 B1_XALT, ZV_TABELA, ZV_GRUPO, ZV_VENDA, ZV_CUSTO, "
	cSql+= "        BM_GRUPO, BM_XSUBGRU, BM_XORDMIX, X5_DESCRI, BM_DESC, NVL(Z6_DESCPRO, 0) Z6_DESCPRO, NVL(Z6_PRCDIG, ZV_VENDA) PRCDIG, "
	cSql+= "        ZV_CUSTO CUSTO, SUM(NVL((SELECT SUM(QTDVEN) QTD      "
	cSql+= "                                   FROM V_MIX"+cfilemp+", "+RETSQLNAME("SA1")+" SA1 "
	cSql+= "                                  WHERE SA1.D_E_L_E_T_ = ' ' "
	cSql+= "                                    AND EMISSAO BETWEEN '20170129' and '20171129' "
	cSql+= "                                    AND COD = SB1.B1_COD "
	cSql+= "                                    AND OPER IN ('01') "
	cSql+= "                                    AND A1_FILIAL = '"+XFILIAL("SA1")+"' "
	If !Empty(ctpcliin)
		cSql += "                               AND A1_XTPCLI IN "+ctpcliin+" "
	EndIf
	cSql+= "                                    AND A1_COD = CLIENTE),0)) QTDVEN "
	cSql+= "   FROM "+RETSQLNAME("SB1")+" SB1, "+RETSQLNAME("SZV")+" SZV, "+RETSQLNAME("SBM")+" SBM, "+RETSQLNAME("SX5")+" SX5, "
	cSql+=            RETSQLNAME("SZ6")+" SZ6 "
	cSql+= "  WHERE SB1.D_E_L_E_T_ = ' ' "
	cSql+= "    AND SZV.D_E_L_E_T_ = ' ' "
	cSql+= "    AND SBM.D_E_L_E_T_ = ' ' "
	cSql+= "    AND SX5.D_E_L_E_T_ = ' ' "
	cSql+= "    AND SZ6.D_E_L_E_T_(+) = ' ' "
	cSql+= "    AND ZV_FILIAL    = '  ' "
	cSql+= "    AND Z6_FILIAL(+) = '  ' "
	cSql+= "    AND B1_FILIAL    = '  ' "
	cSql+= "    AND BM_FILIAL    = '  ' "
	cSql+= "    AND X5_FILIAL    = '  ' "
	cSql+= "    AND SUBSTR(B1_COD, 1, 1) in ('1', '4') "
	cSql+= "    AND B1_XSEGMEN IN ('2', '6') "
	cSql+= "    AND B1_TIPO IN ('TC', 'PA') "
	cSql+= "    AND B1_MSBLQL    = '2' "
	cSql+= "    AND B1_GRUPO     = ZV_GRUPO "
	cSql+= "    AND B1_GRUPO     = Z6_CODPROD(+) "
	cSql+= "    AND B1_XTABUN    = 'S' "
	cSql+= "    AND B1_XCODBAS  <> ' ' "
	cSql+= "    AND ZV_GRUPO    <> ' ' "
	cSql+= "    AND B1_GRUPO    <> ' ' "
	cSql+= "    AND B1_GRUPO     = BM_GRUPO "
	cSql+= "    AND BM_XSUBGRU   = X5_CHAVE "
	cSql+= "    AND X5_TABELA    = 'ZA' "
	cSql+= "    AND ZV_TABELA    = '"+cTab+"' "
	cSql+= "    AND Z6_NUMPROJ(+) = '"+cProj+"' "
	cSql+= "    AND B1_XMODELO NOT IN ('000015', '000017', '000028', '000029') "
	cSql+= "  GROUP BY B1_GRUPO, BM_DESC, ZV_TABELA, ZV_GRUPO, ZV_VENDA, ZV_CUSTO, BM_GRUPO, BM_XSUBGRU, BM_XORDMIX, X5_DESCRI, BM_DESC, Z6_DESCPRO, "
	cSql+= "           Z6_PRCDIG, ZV_CUSTO "
EndIf
cSql+= "  ORDER BY BM_XORDMIX,BM_XSUBGRU,BM_GRUPO,B1_COD "
cSql+= ")  "

*********************************
memowrit("C:\pasta\ORTR048_com_V2.sql", cSql)
                     
TcQuery cSql Alias "TD2" New

TTnquantVd     := 0.00 //TTnquantVd     + TnquantVd 		//0.00 //TnquantVd + nquantVd
TTnPMARFIL     := 0.00 //TTnPMARFIL     + TnPMARFIL 		//0.00 //TnPMARFIL + nPMARFIL
TTncusto       := 0.00 //TTncusto       + Tncusto   		//0.00 //Tncusto + ncusto
TT_nSobrou     := 0.00 //TT_nSobrou     + T_nSobrou 		//0.00 //T_nSobrou + _nSobrou
TT_nPLIQ       := 0.00 //TT_nPLIQ       + T_nPLIQ 			//0.00 //T_nPLIQ + _nPLIQ
Ttvalndg       := 0.00 //Ttvalndg       + tvalndg0.00 		//tvalndg + valndg
Tt_nLucroFinal := 0.00 //Tt_nLucroFinal + t_nLucroFinal 	//0.00 //t_nLucroFinal + _nLucroFinal
TtnPMarfCom	   := 0.00 //TtnPMarfCom	+ tnPMarfCom	// preÁo marfil X comercializaÁ„o
Ttnlucro	   := 0.00 //TtnLucro	+ tnLucro			// lucro
Ttnlucrotot	   := 0.00 //(Ttnlucro*TTnquantVd)		// lucro total
Ttnlucroper	   := 0.00 //(tnLucro/tnPMarfCom)*100 	// % lucro
TtnMarcacao	   := 0.00 //(TtnPMarfCom/Ttncusto)		// MARC UP
TtnRent 	   := 0.00 //((TtnPMarfCom-Ttncusto)/TtnPMarfCom)*100 // Rent
TtVLRLUCRO	   := 0.00
//TtnPartFin	   := 0.00
TotFin()
dbSelectArea("TD2")

nitttensn       := 0
ntttotpreun     := 0.00

ntitttensn      := 0
nvaltitttensn   := 0.00

ntotiproj       := 0
ntotpiipr       := 0.00
nttoaaqqpro     := 0

ntotuniproj     := 0.00
nprpjunipro     := 0.00
nttprun         := 0.00
ntprun          := 0.00

nLin := fCabec(cProj)

//QtdTotPC()
oPrn:SetMeter(TD2->(RecCount()))

While TD2->(!EOF())

	If 	lAchou
//		nLin:=nLin+50
		oPrn:Box(nLin,010,nLin+50,3330)   //linha
		nLin:=nLin+50
	endif

	If lAbortPrint
		@Prow()+1,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//	If nLin > 65
	**************************
	//	lChkCom  := .f.
	lChkLoja := .f.
	lChkLExc := .f.
	**************************
	
	//	Endif
	
	cLinha        := TD2->B1_GRUPO
	
	TnquantVd     := 0.00 //TnquantVd + nquantVd
	TnPMARFIL     := 0.00 //TnPMARFIL + nPMARFIL
	Tncusto       := 0.00 //Tncusto + ncusto
	T_nSobrou     := 0.00 //T_nSobrou + _nSobrou
	T_nPLIQ       := 0.00 //T_nPLIQ + _nPLIQ
	tvalndg       := 0.00 //tvalndg + valndg
	t_nLucroFinal := 0.00 //t_nLucroFinal + _nLucroFinal
	nmarprknovo   := 0.00 //
	nsobproprnov  := 0.00
	ndgproproj    := 0.00
	nlucprofipr   := 0.00
	nlucproprno   := 0.00
	
	tnlucro		  := 0.00
	tnlucroper	  := 0.00
	tnlucfipr	  := 0.00
	tnlucfiprt 	  := 0.00
	tnlucprno	  := 0.00
	tnMarcacao	  := 0.00
	tnPMarfCom	  := 0.00
	trent		  := 0.00
	tVLRLUCRO	  := 0.00
	tnPartFin	  := 0.00
	tnqtdmip	  := 0.00
	
	If cEmpAnt == "26"
		nnomegru := StrTran(TD2->BM_DESC,'BASE','BOX')
	Else
		nnomegru := TD2->BM_DESC
	EndIf
	
	cnomsubgru    := TD2->X5_DESCRI
	ccodsubgru    := TD2->BM_XSUBGRU
	nntemdesasc   := 0.00
	nitensn       := 0
	ntotpreun     := 0.00
	nttoqqpro     := 0.00
	
	nqtdgrup      := 0.00
	
	nvalpord := 0.00
	
	ngtotfinp := 0.00

	lAchou  := .F.
	While TD2->B1_GRUPO == cLinha  //.and. !eof()
		
		nquantVd := 0.00
		nquantVd := TD2->QTDVEN
		
		If Alltrim(TD2->B1_COD) <> "9999999999"
		
			cSqlQ:= " SELECT SUM(NVL(QTDVEN,0)) QTDVEN"
			cSqlQ+= "  FROM V_MIX"+cfilemp+", "+RETSQLNAME("SA1")+" SA1, SIGA.CONVP52"+IIF(cEmpAnt <> "03" .and. !(cEmpAnt == "18" .and. cFilant == "03"), "@DB03", "")
			cSqlQ+= "  WHERE SA1.D_E_L_E_T_ = ' ' "
			cSqlQ+= "   AND EMISSAO BETWEEN '"+DTOS(DEMIS1)+"' AND '"+DTOS(DEMIS2)+"' "
			cSqlQ+= "   AND COD = DE "
			cSqlQ+= "   AND PARA = '"+Alltrim(TD2->B1_COD)+"'  "
			cSqlQ+= "   AND OPER IN ('01')    "
			cSqlQ+= "   AND A1_FILIAL = '"+XFILIAL("SA1")+"' "
			If !Empty(ctpcliin)
				cSqlQ += "  AND A1_XTPCLI IN "+ctpcliin+" "
			EndIf
			cSqlQ+= "   AND A1_COD = CLIENTE "
			
			TcQuery cSqlQ Alias "QTD" New
			
			nquantVd := TD2->QTDVEN + QTD->QTDVEN
			dbSelectArea("QTD")
			dbCloseArea()

		EndIf

		ndesasc := 0.00
		ndesasc := td2->Z6_DESCPRO
	
		if nquantVd >= 0  .and. !lQtdZero  //.and. ndesasc <> 0
			
			TnquantVd := TnquantVd + nquantVd
			**************************************************************************************************
			nmarfil66    := 0.00
			nmarfil66    := TD2->DA1_PRCVEN
			if alltrim(cref) $ "A"
				nmarfil66 := nmarfil66 * nRefCom__A
			elseif alltrim(cref) $ "B"
				nmarfil66 := nmarfil66 * nRefCom__B
			elseif alltrim(cref) $ "C"
				nmarfil66 := nmarfil66 * nRefCom__C
			elseif alltrim(cref) $ "D"
				nmarfil66 := nmarfil66 * nRefCom__D
			elseif alltrim(cref) $ "E"
				nmarfil66 := nmarfil66 * nRefCom__E
			elseif alltrim(cref) $ "F"
				nmarfil66 := nmarfil66 * nRefCom__F
			elseif alltrim(cref) $ "G"
				nmarfil66 := nmarfil66 * nRefCom__G
			elseif alltrim(cref) $ "H"
				nmarfil66 := nmarfil66 * nRefCom__H
			else
				nmarfil66 := nmarfil66 * nRefCom__I
			Endif
			**************************************************************************************************
//			nPMARFIL := (nmarfil66 * nquantVd )         
//          AlteraÁ„o em 07/03/2014 por Rubens para colocar o valor em Reais e n„o multitplicar pela quantidade de peÁas.
			nPMARFIL  := nmarfil66 
			nPMARFILT := (nmarfil66 * nquantVd )
			**************************************************************************************************
			TnPMARFIL := TnPMARFIL + nPMARFILT
        	_nPLIQ := (nPMARFIL - ( nPMARFIL*nqtd/100))
	        _nPLIQ := (_nPLIQ   - ( _nPLIQ*nfin/100 ))			
			_nPLIQT := (nPMARFILT  - (nPMARFILT*nqtd/100))
			_nPLIQT := (_nPLIQT   -  (_nPLIQT*nfin/100))
			
			T_nPLIQ := T_nPLIQ + _nPLIQT

//          AlteraÁ„o em 07/03/2014 por Rubens para colocar o valor em Reais e n„o multitplicar pela quantidade de peÁas.			
			ncustoT := ((TD2->DA1_XCUSTO*nquantVd))
			ncusto := (TD2->DA1_XCUSTO)			
			Tncusto := Tncusto + ncustoT
			
			_nSobrou := (_nPLIQ - ncusto)
			T_nSobrou := T_nSobrou + _nSobrou
			
			valndg := 0.00
			valndg := ((_nPLIQ * nDg) /100)
//			tvalndg := tvalndg + valndg
//			tvalndg := tvalndg + ndgproj2
			
			_nLucroFinal  := 0.00
			_nLucroFinal  := _nSobrou - valndg
			t_nLucroFinal := t_nLucroFinal + _nLucroFinal
			
			_nLucroPV := 0.00
			_nLucroPV := (_nLucroFinal / _nPLIQ) * 100
			
			nPartFin  := 0.00
			nRentab1  := 0.00
			nMarkup   := 0.00
			nPrecoUni := 0.00
//			nMarkup   := _nPLIQ / ncusto
			nPartFin  := ( _nPLIQ  / ntotfinp ) * 100
			nqtdmip   := _nLucroFinal / nlucfipr
			
			nRentab1  := 0.00
			nRentab1  := ( ( (_nSobrou / _nPLIQ) * 100 ) * nPartFin ) / 100
			
			nPrecoUni := _nPLIQ / nquantVd
			
			if ndesasc = 0
				ntotpreun := ntotpreun + nPrecoUni
				nvalpord := nvalpord + ( ( _nPLIQ / ngtotfinp) * nPrecoUni )
				ntprun   += (round(nPrecoUni,2) * nquantVd)
				nttprun  += (round(nPrecoUni,2) * nquantVd)
			else
				nntemdesasc   := nntemdesasc + 1
				if ndesasc < 0.00
					desacr := "D"
				else
					desacr := "A"
				endif
				nprunipro := 0.00
				if ndesasc < 0.00
					nprunipro := nPrecoUni - ((nPrecoUni * (ndesasc * -1)) /100 )
				else
					nprunipro := nPrecoUni + ((nPrecoUni * (ndesasc ))     /100 )
				endif
				
				ntprun    += round(nprunipro,2)*nquantVd
				nttprun   += round(nprunipro,2)*nquantVd
				
				nvalpord := nvalpord + ( ( _nPLIQ / ngtotfinp) * nprunipro )
				
				nmarknovo := 0.00
				nmarknovo := nprunipro / TD2->DA1_XCUSTO
				
				nsobprnov := 0.00
				nsobprnov := nprunipro - TD2->DA1_XCUSTO
				
				ndgproj := 0.00
				ndgproj := (nprunipro * ndg) / 100
				
				nlucfipr := 0.00
				nlucfipr := nsobprnov - ndgproj
				
				nlucprno := 0.00
				nlucprno := (nlucfipr / nprunipro ) * 100
				
				nttoqqpro := nttoqqpro + (_nLucroFinal / nlucfipr)
				ntotpreun := ntotpreun + nprunipro
				
				nitttensn := nitttensn   + 1
				
				ntotiproj := ntotiproj + 1
				ntotpiipr := ntotpiipr + nprunipro
				
			endif

			nitensn := nitensn + 1

//			nPMarfComT		:= ((ndesasc+100)*(_nPLIQ*/100))
//			nPMarfComT		:= ((ndesasc+100)*(_nPLIQ*nquantVd/100))			
			nPMarfComT		:= ((ndesasc+100)*(_nPLIQT/100))						
			nPMarfCom		:= ((ndesasc+100)*(_nPLIQ/100))			
//			nPMarfCom		:= ((ndesasc+100)*(nPMARFIL/100))			
			nMarkup         := nPMarfCom / ncusto //_nPLIQ / ncusto
			tnPMarfCom		:= tnPMarfCom + nPMarfComT 			
//			tnPMarfCom		:= tnPMarfCom + (nPMarfCom * nquantVd)
			ndgproj2		:= (nPMarfCom*nDG)/100
			ndgproj2T		:= (nPMarfComT*nDG)/100			
			nLucro			:= nPMarfCom - (ncusto + ndgproj2)
			nLucroT			:= nPMarfComT - (ncustoT + ndgproj2T)			
			tvalndg 		:= tvalndg + ndgproj2T
			
			tnPrecoUni 		:= T_nPLIQ / TnquantVd
			tnMarkup   		:= tnPrecoUni / (Tncusto/TnquantVd)
			nPrpjunipro 	:= ntprun/TnquantVd
			nmarprknovo 	:= nprpjunipro / (Tncusto / TnquantVd)
			nsobproprnov	:= nprpjunipro - (Tncusto / TnquantVd)
			ndgproproj 		:= (nprpjunipro * ndg) / 100
			nlucprofipr 	:= nsobproprnov - ndgproproj
			nlucproprno 	:= (nlucprofipr / nprpjunipro ) * 100
			nlucroper		:= (nLucro/nPMarfCom)*100
			nMarcacao		:= (nPMarfCom/ncusto)
//			nRent			:= ((nPMarfCom-ncusto)/nPMarfCom)*100
			nRent			:= ((nPMarfComT-ncustoT)/nPMarfComT)*100			
			
//			tnlucro			:= tnlucro + nlucro	   //total lucro
			tnlucro			:= tnlucro + nlucroT	   //total lucro			
			tnlucroper		:= (tnLucro/tnPMarfCom)*100  //% lucro
//			tnlucrotot		:= (Tnlucro*TnquantVd) //
			tnlucrotot		:= Tnlucro //			
			tnlucfiprt 		:= tnlucfiprt + (nlucfipr*nquantVd) 
			tnlucprno		:= tnlucprno + nlucprno
			tnMarcacao		:= (tnPMarfCom/Tncusto) //marc up
			tnRent			:= ((TnPMarfCom-Tncusto)/TnPMarfCom)*100 //rent
			tVLRLUCRO		:= tVLRLUCRO + (TD2->QTDVEN*((TD2->PRCDIG*0.6)-TD2->CUSTO))
			tnqtdmip   		:= tnqtdmip + nqtdmip
//			nPartFin		:= ((nQuantVd*nPMarfCom)/(tnQtd*tnPMarfXCo))*100


			if !lImptot  //.and. ndesasc <> 0
				
				oPrn:Box(nLin,0010,nLin+50,550)  //CODIGO
				If Alltrim(TD2->B1_COD)=="9999999999"
				   oPrn:Say(nLin,0010,"SOB MEDIDA-"+substr(nnomegru,1,16),oCouNew12,0)
				Else
				   oPrn:Say(nLin,0010,substr(alltrim(TD2->B1_COD),1,10)+"-"+substr(nnomegru,1,16),oCouNew12,0)
                Endif
				oPrn:Box(nLin,0550,nLin+50,770)   //MEDIDA
				oPrn:Say(nLin,0550,LEFT(strzero(TD2->B1_XLARG*100,3)+"X"+strzero(TD2->B1_XCOMP*100,3)+"X"+strzero(TD2->B1_XALT*100,3),11),oCouNew12,0)

				oPrn:Box(nLin,0770,nLin+50,1015)   //PRECO MARFIL
//				oPrn:Say(nLin,0770,"9,999,999.99",oCouNew11,0)
				oPrn:Say(nLin,0770,TRANSFORM(nPMARFIL,"@E 9,999,999.99"),oCouNew11,0)

				oPrn:Box(nLin,1015,nLin+50,1130)   //Markup
//				oPrn:Say(nLin,1010,"999.99",oCouNew11,0)
				oPrn:Say(nLin,1010,TRANSFORM(nMarkup, "@E 999.99"),oCouNew11,0)

				oPrn:Box(nLin,1130,nLin+50,1180)   //QUA
//				oPrn:Say(nLin,1130,"99",oCouNew11,0)
				oPrn:Say(nLin,1130,TRANSFORM(nQtd,"@ER 99"),oCouNew11,0)

				oPrn:Box(nLin,1180,nLin+50,1240)   //FIN
//				oPrn:Say(nLin,1190,"99",oCouNew11,0)
				oPrn:Say(nLin,1190,TRANSFORM(nFin,"@ER 99"),oCouNew11,0)

				oPrn:Box(nLin,1240,nLin+50,1360)   //PECAS
				If !lMedper
//					oPrn:Say(nLin,1240,"99,999",oCouNew11,0)
					oPrn:Say(nLin,1240,TRANSFORM(nquantVd,"@E 99,999"),oCouNew11,0)
				Else  
					oPrn:Say(nLin,1240,TRANSFORM((nquantVd/round(nmedper,2)),"@E 99,999"),oCouNew11,0)
				Endif
				
				oPrn:Box(nLin,1360,nLin+50,1510)
//				oPrn:Say(nLin,1370,"D999.99", oCouNew11,,,, 0) //DES ACR  R)
				oPrn:Say(nLin,1370,desacr + TRANSFORM(ndesasc,"@E 999.99"), oCouNew11,,,, 0) //DES ACR  R)

				oPrn:Box(nLin,1510,nLin+50,1720)
//				oPrn:Say(nLin,1520,"999,999.99", oCouNew11,,,, 0) //08
				oPrn:Say(nLin,1520,TRANSFORM(nPMarfCom, "@E 999,999.99"), oCouNew11,,,, 0) //08
				
				oPrn:Box(nLin,1720,nLin+50,1905)   //  09
//				oPrn:Say(nLin,1720,"99,999.99",oCouNew11,0)
				oPrn:Say(nLin,1720,TRANSFORM(ncusto,"@E 99,999.99"),oCouNew11,0)

				oPrn:Box(nLin,1905,nLin+50,2110)   //  10 DG -  (PRECO LIQUIDO * DG (MV_PAR21))
//				oPrn:Say(nLin,1900,"999,999.99",oCouNew11,0)
				oPrn:Say(nLin,1905,TRANSFORM(ndgproj2,"@E 999,999.99"),oCouNew11,0)
//				oPrn:Say(nLin,2360,TRANSFORM(valndg,"@E 999,999.99"),oCouNew11,0)

				oPrn:Box(nLin,2110,nLin+50,2325)   // 11 lucro
				oPrn:Say(nLin,2110,TRANSFORM(nlucro,"@E 999,999.99"),oCouNew11,0)

				oPrn:Box(nLin,2325,nLin+50,2610)   //12 lucro total
				oPrn:Say(nLin,2325,TRANSFORM(nLucro*nquantVd,"@E 999,999,999.99"),oCouNew11,0)

				oPrn:Box(nLin,2610,nLin+50,2750)   //13 % lucro
				oPrn:Say(nLin,2615,TRANSFORM(nlucroper,"@E 999.99"),oCouNew11,0)

				oPrn:Box(nLin,2750,nLin+50,2890)   //14 marc up
				oPrn:Say(nLin,2750,TRANSFORM(nMarcacao,"@E 999.99"),oCouNew11,0)

				oPrn:Box(nLin,2890,nLin+50,3050)   //15  rent
				oPrn:Say(nLin,2915,TRANSFORM(nRent, "@E 999.99"),oCouNew11,0)

				oPrn:Box(nLin,3050,nLin+50,3200)   //16  part Fin
				oPrn:Say(nLin,3050,transform(nPartFin, "@E 999.999"),oCouNew11,0)

				oPrn:Box(nLin,3200,nLin+50,3330)   //17  qtd min
				oPrn:Say(nLin,3190,transform(nqtdmip, "@E 999,999"),oCouNew11,0)

				lAchou  := .T.
		 		nLin += 50

				aAdd(aImpItens,{substr(alltrim(TD2->B1_COD),1,10),substr(nnomegru,1,16),LEFT(strzero(TD2->B1_XLARG*100,3)+"X"+strzero(TD2->B1_XCOMP*100,3)+"X"+strzero(TD2->B1_XALT*100,3),11),nMarkup,nQtd,nFIn,nquantVd,(desacr+TRANSFORM(ndesasc,"@E 999.99")),nPMarfCom,ncusto,ndgproj2,nLucro,(nLucro*nquantVd),nlucroper,nMarcacao,nRent,(TD2->QTDVEN*((TD2->PRCDIG*0.6)-TD2->CUSTO))})


				if nLin >= MaxLin //.or. EOF()
					lTot := .T.
					oPrn:EndPage()
					nLin := fCabec(cProj)
					aConItens:= {}
					aTConItens:= {}
				Endif
			endif
			if nLin >= MaxLin //.or. EOF()
				lTot := .T.
				oPrn:EndPage()
				nLin := fCabec(cProj)
				aConItens:= {}
				aTConItens:= {}
			Endif
			If lImpDif
				aAdd(aImpDif, {substr(alltrim(TD2->B1_COD),1,10)})
			Endif
		EndIf
		
		dbSelectArea("TD2")
		TD2->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	    oPrn:IncMeter(1)		
	EndDo
	
	if 	TnquantVd <> 0
	
		T_nLucroPV := 0.00
		T_nLucroPV := (t_nLucroFinal / T_nPLIQ) * 100
		nPartFin  := ( T_nPLIQ  / ntotfinp ) * 100
		tnRentab1  := 0.00
		tnRentab1  := ( ( (t_nSobrou / t_nPLIQ) * 100 ) * nPartFin ) / 100
		tnPrecoUni := T_nPLIQ / TnquantVd
		tnMarkup   := tnPrecoUni / (Tncusto/TnquantVd)
		tnPartFin  := tnPartFin + nPartFin
//		tnqtdmip   := tnqtdmip + nqtdmip

		oPrn:Box(nLin,0010,nLin+50,550)  //CODIGO
		
//		oPrn:Box(nLin,280,nLin+50,770)  //NOME DO GRUPO"
		oPrn:Say(nLin,010,space(11)+substr(nnomegru,1,16),oCouNew12,0)
		
		oPrn:Box(nLin,0550,nLin+50,770)   //MEDIDA

		oPrn:Box(nLin,0770,nLin+50,1015)   //PRECO MARFIL
		oPrn:Say(nLin,0770,TRANSFORM(TnPMARFIL,"@E 9,999,999.99"),oCouNew11,100)

		oPrn:Box(nLin,1015,nLin+50,1130)   //Markup
		oPrn:Say(nLin,1010,TRANSFORM(tnMarkup,"@E 999.99"),oCouNew11,0)

		oPrn:Box(nLin,1130,nLin+50,1180)   //QUA
		oPrn:Box(nLin,1180,nLin+50,1240)   //FIN

		oPrn:Box(nLin,1240,nLin+50,1360)   //PECAS
		If !lMedper
			oPrn:Say(nLin,1240,TRANSFORM(TnquantVd,"@E 99,999"),oCouNew11,100)
		else
			oPrn:Say(nLin,1240,TRANSFORM((TnquantVd/round(nmedper,2)),"@E 99,999"),oCouNew11,100)
		Endif
	
		oPrn:Box(nLin,1360,nLin+50,1510)

		oPrn:Box(nLin,1510,nLin+50,1720)   //08 preÁo marfil X comercializaÁ„o
		oPrn:Say(nLin,1520,TRANSFORM(tnPMarfCom, "@E 999,999.99"), oCouNew11,,,, 0) //08

		oPrn:Box(nLin,1720,nLin+50,1905)   // 09 custo
		oPrn:Say(nLin,1720,TRANSFORM(Tncusto,"@E 99,999.99"),oCouNew11,0)

		oPrn:Box(nLin,1905,nLin+50,2110)   //  10 DG -  (PRECO LIQUIDO * DG (MV_PAR21))
		oPrn:Say(nLin,1905,TRANSFORM(tvalndg,"@E 999,999.99"),oCouNew11,0)

		oPrn:Box(nLin,2110,nLin+50,2325)   // 11 lucro
//		oPrn:Say(nLin,2110,TRANSFORM(tnlucro,"@E 999,999.99"),oCouNew11,0)
		
		oPrn:Box(nLin,2325,nLin+50,2610)   //12 lucro total
		oPrn:Say(nLin,2325,TRANSFORM(tnlucrotot,"@E 999,999,999.99"),oCouNew11,0)
		
		oPrn:Box(nLin,2610,nLin+50,2750)   //13 % lucro
		oPrn:Say(nLin,2615,TRANSFORM(tnlucroper,"@E 999.99"),oCouNew11,0)
		
		oPrn:Box(nLin,2750,nLin+50,2890)   //14 marc up
		oPrn:Say(nLin,2750,TRANSFORM(tnMarcacao,"@E 999.99"),oCouNew11,0)		
		
		oPrn:Box(nLin,2890,nLin+50,3050)   //15  rent
		oPrn:Say(nLin,2915,TRANSFORM(tnRent, "@E 999.99"),oCouNew11,0)

		oPrn:Box(nLin,3050,nLin+50,3200)   //16  part Fin
		oPrn:Say(nLin,3050,transform(tnPartFin, "@E 999.999"),oCouNew11,0)

		oPrn:Box(nLin,3200,nLin+50,3330)   //17  qtd min
		oPrn:Say(nLin,3190,transform(tnqtdmip, "@E 999,999"),oCouNew11,0)
		
		***************************************
		if nntemdesasc = 0
			@nLin,168 PSAY SPACE(06)+"|"
			@nLin,175 PSAY SPACE(09)+"|"
			@nLin,185 PSAY SPACE(06)+"|"
			@nLin,192 PSAY SPACE(09)+"|"
			@nLin,202 PSAY SPACE(06)+"|"
			@nLin,209 PSAY SPACE(06)+"|"
			@nLin,216 PSAY SPACE(06)+"|"
			@nLin,224 PSAY SPACE(04)+"|"
			//                               1					2			3			4		5		6		7			8				9		10			11		12			13			14		 15         16          17            18            19     20              21
//			Aadd (aitens,{substr(nnomegru,1,20),TnquantVd ,TnPMARFIL ,T_nPLIQ ,Tncusto ,T_nSobrou , tvalndg,t_nLucroFinal , T_nLucroPV,nPartFin,tnMarkup,tnPrecoUni,ccodsubgru,cnomsubgru,0,0,0,0,0,0,0 })
			
		else
			
			@nLin,168 PSAY space(06)+"|" // DES/ACR
			
			nprpjunipro := 0.00
			nPrpjunipro := ntprun/TnquantVd
			
			@nLin,175 PSAY TRANSFORM( nprpjunipro, "@E 99,999.99")+"|" // DES/ACR
			
			nmarprknovo := 0.00
			nmarprknovo := nprpjunipro / (Tncusto / TnquantVd)
			@nLin,185 PSAY TRANSFORM( nmarprknovo, "@E 999.99")+"|" // DES/ACR
			
			nsobproprnov := 0.00
			nsobproprnov := nprpjunipro - (Tncusto / TnquantVd)
			
			@nLin,192 PSAY TRANSFORM( nsobproprnov, "@E 99,999.99")+"|" // DES/ACR
			
			ndgproproj := 0.00
			ndgproproj := (nprpjunipro * ndg) / 100
			
			@nLin,202 PSAY TRANSFORM( ndgproproj, "@E 999.99")+"|" // DES/ACR
			
			
			nlucprofipr := 0.00
			nlucprofipr := nsobproprnov - ndgproproj
			
			@nLin,209 PSAY TRANSFORM( nlucprofipr, "@E 999.99")+"|" // DES/ACR
			
			nlucproprno := 0.00
			nlucproprno := (nlucprofipr / nprpjunipro ) * 100
			
			@nLin,216 PSAY TRANSFORM( nlucproprno, "@E 999.99")+"|" // DES/ACR
			
			//				@nLin,224 PSAY TRANSFORM(nttoqqpro, "@E 9999")+"|"
			@nLin,224 PSAY space(4)+"|"
			
			nttoaaqqpro := nttoaaqqpro + nttoqqpro
//			Aadd (aitens,{substr(nnomegru,1,20),TnquantVd ,TnPMARFIL ,T_nPLIQ ,Tncusto ,T_nSobrou , tvalndg,t_nLucroFinal , T_nLucroPV,nPartFin,tnMarkup,tnPrecoUni,ccodsubgru,cnomsubgru,nprpjunipro,nmarprknovo,nsobproprnov,ndgproproj,nlucprofipr,nlucproprno,nttoqqpro })
			
		endif
		
		NTPRUN:=0
		
		**********************************************************************************************************************************************************************
		aAdd(aImpItens,{"",substr(nnomegru,1,20),"",TnMarkup,"","",TnquantVd,"",TnPMarfCom,Tncusto,tvalndg,TnLucro,TnLucrotot,Tnlucroper,TnMarcacao,TnRent,""})
		aAdd(aTotItens,{substr(nnomegru,1,20),TnquantVd,TnPMarfCom})
//		aAdd(aConItens,{"",substr(nnomegru,1,20),"",TRANSFORM(tnMarkup, "@E 999.99"),TRANSFORM(tnPrecoUni, "@E 99,999.99"),"",TRANSFORM( nprpjunipro, "@E 99,999.99"),TRANSFORM( nmarprknovo, "@E 999.99"),TRANSFORM( nsobproprnov, "@E 99,999.99"),TRANSFORM( ndgproproj, "@E 999.99"),TRANSFORM( nlucprofipr,"@E 999.99"),TRANSFORM( nlucproprno, "@E 999.99"),""})
		
		
		TTnquantVd     := TTnquantVd     + TnquantVd 		//0.00 //TnquantVd + nquantVd
		TTnPMARFIL     := TTnPMARFIL     + TnPMARFIL 		//0.00 //TnPMARFIL + nPMARFIL
		TTncusto       := TTncusto       + Tncusto   		//0.00 //Tncusto + ncusto
		TT_nSobrou     := TT_nSobrou     + T_nSobrou 		//0.00 //T_nSobrou + _nSobrou
		TT_nPLIQ       := TT_nPLIQ       + T_nPLIQ 			//0.00 //T_nPLIQ + _nPLIQ
		Ttvalndg       := Ttvalndg       + tvalndg   		//tvalndg + valndg
		Tt_nLucroFinal := Tt_nLucroFinal + t_nLucroFinal 	//0.00 //t_nLucroFinal + _nLucroFinal

		Ttnlucfipr		:= Ttnlucfipr	+ tnlucfipr
		Ttnlucfiprt		:= Ttnlucfiprt	+ tnlucfiprt
		Ttnlucprno		:= Ttnlucprno	+ tnlucprno
		Ttmarcacao		:= Ttmarcacao	+ tnmarcacao

		TtnPMarfCom		:= TtnPMarfCom	+ tnPMarfCom	// preÁo marfil X comercializaÁ„o
		Ttnlucro		:= TtnLucro	+ tnLucro			// lucro
		Ttnlucrotot		:= (Ttnlucro*TTnquantVd)		// lucro total
		Ttnlucroper		:= (TtnLucro/TtnPMarfCom)*100 	// % lucro
		TtnMarcacao		:= (TtnPMarfCom/Ttncusto)		// MARC UP
		TtnRent 		:= ((TtnPMarfCom-Ttncusto)/TtnPMarfCom)*100 // Rent
		TtnPartFin		:= TtnPartFin + tnPartFin
		Ttnqtdmip		:= Ttnqtdmip + tnqtdmip
		
		npontgprod := 0.00
		npontgprod := (TnquantVd / nttqtg ) * 100
		
		ntotuniproj := ntotuniproj + ( npontgprod * nprpjunipro )
		nLin:=nLin+50

	endif
	dbSelectArea("TD2")
EndDo


TT_nLucroPV := 0.00
TT_nLucroPV := (Tt_nLucroFinal / TT_nPLIQ) * 100
nPartFin  := ( TT_nPLIQ  / ntotfinp ) * 100
TtnRentab1  := 0.00
TtnRentab1  := ( ( (Tt_nSobrou / Tt_nPLIQ) * 100 ) * nPartFin ) / 100

ttnPrecoUni     := tT_nPLIQ / tTnquantVd
ttnMarkup       := ttnPrecoUni / (tTncusto/tTnquantVd)

nprpjunipro     := 0.00
nprpjunipro     := nttprun / TTnquantVd

nmarttprknovo   := 0.00
nmarttprknovo   := nprpjunipro / (TTncusto / TTnquantVd)

nsobtaproprnov := 0.00
nsobtaproprnov := nprpjunipro - (TTncusto / TTnquantVd)

ndgaaproproj := 0.00
ndgaaproproj := (nprpjunipro * ndg) / 100

nlucaaprofipr := 0.00
nlucaaprofipr := nsobtaproprnov - ndgaaproproj

nluaacproprno := 0.00
nluaacproprno := (nlucaaprofipr / nprpjunipro ) * 100


nLin += 50
oPrn:Box(nLin,010,nLin+50,3330)   //linha
nLin += 50

oPrn:Box(nLin,010,nLin+50,770)  //BOX CODIGO
			
//oPrn:Box(nLin,280,nLin+50,770)   //DESCRI«√O
oPrn:Say(nLin,010,space(11)+"TOTALIZACAO",oCouNew11,0)

oPrn:Box(nLin,0770,nLin+50,1015)   //PRECO MARFIL
oPrn:Say(nLin,0770,TRANSFORM(TTnPMARFIL,"@E 9,999,999.99"),oCouNew09,100)

oPrn:Box(nLin,1015,nLin+50,1130)   //Markup
oPrn:Say(nLin,1010,TRANSFORM(TtnMarkup,"@E 999.99"),oCouNew11,0)

oPrn:Box(nLin,1130,nLin+50,1180)   //QUA
oPrn:Box(nLin,1180,nLin+50,1240)   //FIN

oPrn:Box(nLin,1240,nLin+50,1360)   //PECAS
If !lMedper
	oPrn:Say(nLin,1240,TRANSFORM(TTnquantVd,"@E 99,999"),oCouNew10,100)
else
	oPrn:Say(nLin,1240,TRANSFORM((TTnquantVd/round(nmedper,2)),"@E 99,999"),oCouNew10,100)
Endif

oPrn:Box(nLin,1360,nLin+50,1510)

oPrn:Box(nLin,1510,nLin+50,1720)   //08 preÁo marfil X comercializaÁ„o
oPrn:Say(nLin,1520,TRANSFORM(TtnPMarfCom, "@E 999,999.99"), oCouNew09,,,, 0) //08

oPrn:Box(nLin,1720,nLin+50,1905)   // 09 custo
oPrn:Say(nLin,1725,TRANSFORM(Ttncusto,"@E 999,999.99"),oCouNew09,0)
//oPrn:Say(nLin,1720,TRANSFORM(Ttncusto,"@E 999,999.99"),oCouNew09,0)

oPrn:Box(nLin,1905,nLin+50,2110)   //  10 DG -  (PRECO LIQUIDO * DG (MV_PAR21))
oPrn:Say(nLin,1905,TRANSFORM(Ttvalndg,"@E 999,999.99"),oCouNew09,0)

oPrn:Box(nLin,2110,nLin+50,2325)   // 11 lucro
oPrn:Say(nLin,2110,TRANSFORM(Ttnlucro,"@E 999,999.99"),oCouNew10,0)
		
oPrn:Box(nLin,2325,nLin+50,2610)   //12 lucro total
//oPrn:Say(nLin,2300,TRANSFORM(Ttnlucrotot,"@E 999,999,999.99"),oCouNew10,0)
oPrn:Say(nLin,2325,TRANSFORM(Ttnlucrotot,"@E 99,999,999,999.99"),oCouNew09,0)
		
oPrn:Box(nLin,2610,nLin+50,2750)   //13 % lucro
oPrn:Say(nLin,2615,TRANSFORM(Ttnlucroper,"@E 999.99"),oCouNew11,0)
		
oPrn:Box(nLin,2610,nLin+50,2890)   //14 marc up
oPrn:Say(nLin,2760,TRANSFORM(TtnMarcacao,"@E 999.99"),oCouNew11,0)		
		
oPrn:Box(nLin,2890,nLin+50,3050)   //15  rent
oPrn:Say(nLin,2880,TRANSFORM(TtnRent, "@E 999.99"),oCouNew11,0)

oPrn:Box(nLin,3050,nLin+50,3200)   //16  part Fin
oPrn:Say(nLin,3050,transform(TtnPartFin, "@E 999.999"),oCouNew11,0)

oPrn:Box(nLin,3200,nLin+50,3330)   //17  qtd min
oPrn:Say(nLin,3200,transform(Ttnqtdmip, "@E 999,999"),oCouNew11,0)

MaxCol := 3300
lTot := .f.

dbSelectArea("TD2")
dbCloseArea()

nttoprjt := 0

If lImpDif
	fImpDif(aImpDif,cTab,cRef,cProj)
Endif

SET DEVICE TO SCREEN


If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()
Return
                                       

****************************************************
Static Function fConItens(aConItens,nLin,aTConItens,lTot) //,aTConItens
****************************************************
                                              
Local GrpPro:= ""
Local nmarkup := 0
Local nlinha :=0     

nLin:= 2300
if nLin >= MaxLin
	tipocab:=.f.
	oPrn:EndPage()
	nLin := fCabec(cProj)
	tipocab:=.t.
Endif

for I :=1 to len(aConItens)

	oPrn:Box(nLin,010,nLin+50,300)
	If aConItens=="9999999999"
       oPrn:Say(nLin,010,"SOBMEDIDA", oCouNew11,,,, 0) //CODIGO  A)
	Else
	   oPrn:Say(nLin,010,aConItens[I][1], oCouNew11,,,, 0) //CODIGO  A)
	Endif
	oPrn:Box(nLin,300,nLin+50,800)
	oPrn:Say(nLin,300,aConItens[I][2], oCouNew11,,,, 0) //DESCRICAO  B)
	
	oPrn:Box(nLin,800,nLin+50,1100)
	oPrn:Say(nLin,800,aConItens[I][3], oCouNew11,,,, 0) //MEDIDA  C)
	
	oPrn:Box(nLin,1100,nLin+50,1240)
	oPrn:Say(nLin,1100,aConItens[I][4], oCouNew11,,,, 0) //MARK UP  P)
	
	oPrn:Box(nLin,1240,nLin+50,1450)
	oPrn:Say(nLin,1225,aConItens[I][5], oCouNew11,,,, 0) //PRECO UNIT   Q)
	
	oPrn:Box(nLin,1450,nLin+50,1700)
	oPrn:Say(nLin,1500,aConItens[I][6], oCouNew11,,,, 0) //DES ACR  R)
	
	oPrn:Box(nLin,1700,nLin+50,1900)
	oPrn:Say(nLin,1650,aConItens[I][7], oCouNew11,,,, 0) //PRECO UNIT  S)
	
	oPrn:Box(nLin,1900,nLin+50,2050)
	oPrn:Say(nLin,1900,aConItens[I][8], oCouNew11,,,, 0) //MARK UP UNIT T)
	
	oPrn:Box(nLin,2050,nLin+50,2300)
	oPrn:Say(nLin,2050,aConItens[I][9], oCouNew11,,,, 0) //SOBRA  U)
	
	oPrn:Box(nLin,2300,nLin+50,2450)
	oPrn:Say(nLin,2300,aConItens[I][10], oCouNew11,,,, 0) //DG  V)
	
	oPrn:Box(nLin,2450,nLin+50,2600)
	oPrn:Say(nLin,2450,aConItens[I][11], oCouNew11,,,, 0) //LUCRO FINAL  W)
	
	oPrn:Box(nLin,2600,nLin+50,2750)
	oPrn:Say(nLin,2600,aConItens[I][12], oCouNew11,,,, 0) //LUCRO % PV  X)
	
	oPrn:Box(nLin,2750,nLin+50,3330)
	
	nLin:=nLin+50
	oPrn:Box(nLin,010,nLin+50,3330)   //linha
	If !lImptot
	    if empty(aConItens[i][13])
     		oPrn:Box(650,2750,900,3330)
    	    nLin+=50
	    endif
    eNDIF
next I

RETURN nLin










/*/TRATAMENTO PARA IMPRESS√O DE CABECALHO/*/
Static Function fCabec(cProj)

Private titulo	:= ""

oPrn:StartPage()

oPrn:Box(050,010,300,3330)
oPrn:SayBitmap(100,075,cLogo,200,075)	   	                        // Impressao do Logotipo.
oPrn:Say(150,075,"/SIGA/" + AllTrim(FunName()), oCouNew11,,,, 0)		// Impressao do Nome da rotina do relatorio.
oPrn:Say(200,075,"Hora  :" + Time() + " - Empresa: " + cfilemp, oCouNew11,,,, 3)	// Impressao da hora de impressao.


oPrn:Say(100,2910,"Pagina :    " + strzero(nPag,3,0), oCouNew11,,,,3)  // Impressao do Numero da Pagina.
oPrn:Say(150,2910,"Data   :"     + DtoC(dDataBase)  , oCouNew11,,,, 3)	// Impressao da data de impressao.
oPrn:Say(200,2910,"Emissao:"     + DtoC(dDataBase)  , oCouNew11,,,, 3)	// Impressao da data de impressao.

titulo := "MAPA COMERCIALIZACAO  C O M E R C I A L NO PERIODO DE "+dtoc(dEmis1)+" A "+dtoc(dEmis2)


oPrn:Say(150, 800, titulo, oCouNew12,,,, 0)

oPrn:Box(300,010,650,3330)
oPrn:Say(300,010,"PROJE«√O         : "+CPROJ+   " PERIODO : "+ DTOC(DEMIS1)+" ATE "+ DTOC(DEMIS2), oCouNew11,,,, 0)
oPrn:Say(400,010,"SEGMENTO         : LOJAS COMERCIAS ", oCouNew11,,,, 0) // INDUSTRIAL " //COMERCIAL ["+IIF(LCHKCOM,'X',' ')+"]    LOJA ["+IIF(LCHKLOJA,'X',' ')+"]   LOJA EXCLUSIVA ["+IIF(LCHKLEXC,'X',' ')+"]   "
oPrn:Say(450,010,"USUARIO          : GER. GERAL, GER. LOJA E GESTOR DE PRECOS.", oCouNew11,,,, 0)
oPrn:Say(500,010,"OBJETIVO         : ESTE MAPA PROJETA O NOVO MIX DE ACORDO COM OS DESCONTOS E ACRESCIMOS PRATICADOS.", oCouNew11,,,, 0)
oPrn:Say(550,010,"PER. UTILIZACAO  : QUINZENAL E/OU MENSAL.", oCouNew11,,,, 0)

cslchkpul := " "
if lchkpul
	cslchkpul := "X"
endif

cslchkesp := " "
if lchkesp
	cslchkesp := "X"
endif

cslchksp := " "
if lchksp
	cslchksp := "X"
endif
oPrn:Say(600,010,"TIPO DE CLIENTE  : PULVERIZADO ["+cslchkpul+"] - ESPECIAL ["+cslchkesp+"] - SUPERVERTICAL ["+cslchksp+"]", oCouNew11,,,, 0)

oPrn:Box(650,010,900,550)   //CODIGO
oPrn:Say(750,015,"CODIGO   -",oCouNew11,0)
oPrn:Say(750,255,"DESCRICAO",oCouNew11,0)

oPrn:Box(650,0550,900,770)   //MEDIDA
oPrn:Say(750,0555,"MEDIDA",oCouNew11,0)

//If tipocab

	oPrn:Box(650,0770,900,1015)   //PRECO MARFIL
	oPrn:Say(650,0775,"PRECO",oCouNew11,0)
	oPrn:Say(700,0775,"MARFIL",oCouNew11,0)
	oPrn:Say(750,0775,MV_PAR24+" - "+MV_PAR25,oCouNew11,0)

	oPrn:Box(650,1015,900,1130)   //Markup
	oPrn:Say(700,1020,"MARK",oCouNew11,0)
	oPrn:Say(750,1020,"UP",oCouNew11,0)

	oPrn:Box(650,1130,900,1180)   //QUA
	oPrn:Say(650,1140,"Q",oCouNew11,0)
	oPrn:Say(700,1140,"U",oCouNew11,0)
	oPrn:Say(750,1140,"A",oCouNew11,0)

	oPrn:Box(650,1180,900,1240)   //FIN
	oPrn:Say(650,1190,"F",oCouNew11,0)
	oPrn:Say(700,1190,"I",oCouNew11,0)
	oPrn:Say(750,1190,"N",oCouNew11,0)

	oPrn:Box(650,1240,900,1360)   //PECAS
	oPrn:Say(750,1245,"PECAS",oCouNew11,0)

	oPrn:Box(650,1360,900,1510)   //DES/ACR   R)
	oPrn:Say(750,1365,"DES/ACR",oCouNew11,0)
	
	oPrn:Box(650,1510,900,1720)
	oPrn:Say(650,1515,"PRC MARFIL",oCouNew11,0)
	oPrn:Say(700,1515,"    X     ",oCouNew11,0)
	oPrn:Say(750,1515,"COMERCIAL.",oCouNew11,0)
	
	oPrn:Box(650,1720,900,1905)   //  09 CUSTO UNITARIO
	oPrn:Say(700,1725,"CUSTO",oCouNew11,0)
	oPrn:Say(750,1725,"UNIT",oCouNew11,0)

	oPrn:Box(650,1905,900,2110)   //  10 DG
	oPrn:Say(700,1910,"DG",oCouNew11,0)
	oPrn:Say(750,1910,TRAN(MV_PAR17,'@ER 99.99')+"%",oCouNew11,0)
	
	oPrn:Box(650,2110,900,2325)   // 11 lucro
	oPrn:Say(700,2115,"LUCRO",oCouNew11,0)

	oPrn:Box(650,2325,900,2610)   //12 lucro total
	oPrn:Say(700,2330,"LUCRO",oCouNew11,0)
	oPrn:Say(750,2330,"TOTAL",oCouNew11,0)
	
	oPrn:Box(650,2610,900,2750)   //13 % lucro
	oPrn:Say(700,2615,"%",oCouNew11,0)
	oPrn:Say(750,2615,"LUCRO",oCouNew11,0)

	oPrn:Box(650,2750,900,2890)   //14 marc up
	oPrn:Say(700,2755,"MARC",oCouNew11,0)
	oPrn:Say(750,2755,"UP",oCouNew11,0)
	
	oPrn:Box(650,2890,900,3050)   //15  rent
	oPrn:Say(700,2895,"RENT.",oCouNew11,0)

	oPrn:Box(650,3050,900,3200)   //16  part Fin
	oPrn:Say(700,3055,"PART",oCouNew11,0)
	oPrn:Say(750,3055,"FIN.",oCouNew11,0)

	oPrn:Box(650,3200,900,3330)   //17  qtd min
	oPrn:Say(700,3205,"QTD",oCouNew11,0)
	oPrn:Say(750,3205,"MIN.",oCouNew11,0)

//endif

nLin:= 900
nPag += 1
Return(nLin)





Static Function lervenda(cprod6)

Local ctpcliin

ctpclii := ""

if lchkpul 
   ctpclii := ctpclii + "'P',"
endif
               
if lchkesp 
   ctpclii := ctpclii +  "'E',"
endif
                 
if lchksp 
   ctpclii := ctpclii +  "'S',"
endif
               
cc1        := alltrim(ctpclii)
ctpcliin   := ""	
IF .NOT.(Empty(cc1))
	//alert(cc1)
	//alert(len(cc1))
	cc2        := substr(ctpclii,1,len(cc1)-1)
	ctpcliin   := "("+cc2+")"
	//alert(ctpcliin)
EndIF

cSq2 := "select COD CODIGO,B1_COD, "
cSq2 += "        SUM(QTDVEN) QTD, "
cSq2 += "        SUM((QTDVEN * PRUNIT) * (1 - ((GUELTA + RESSARC) / 100))) VENDALIQ, "
cSq2 += "        SUM((QTDVEN * PRUNIT)) VENDABRU "
cSq2 += "   from siga.V_MIX"+cfilemp+"  , SIGA."+RETSQLNAME("SB1")+" SB1, siga."+RETSQLNAME("SA1")+" SA1 "
cSq2 += "  WHERE SB1.D_E_L_E_T_ = ' ' AND SA1.D_E_L_E_T_ = ' ' "
cSq2 += "    AND EMISSAO >= '"+DTOS(DEMIS1)+"' "
cSq2 += "    AND EMISSAO <= '"+DTOS(DEMIS2)+"' "
cSq2 += "    AND COD IN ('"+cprod6+"') "
//--   and OPER IN ('01','99')
cSq2 += "    and OPER IN ('01') "
//--   and OPER IN ('01','05','13','04', '14', '15', '16', '20', '21')
cSq2 += "    AND B1_FILIAL = '  ' "         
cSq2 += "    AND A1_FILIAL = '  ' "           

IF .NOT.(Empty(ctpcliin))
	cSq2 += "   and A1_XTPCLI IN "+ctpcliin+" " //('S','P','E') "
EndIF	
cSq2 += "   AND A1_COD = CLIENTE "

cSq2 += "   AND B1_COD not in ('1040710635','1090710088','1090710070') " // Nao aparecer o produto COLCH C/LOGO P/ ACAD - wfa - 26/03/12 - a pedido do Sr. Jose Antonio

//cSq2 += "    AND B1_XCODBAS = ' ' "
if !lChkSBM                                       
   cSq2  += " and B1_XCODBAS    = ' ' "
Endif                 


cSq2 += "    AND B1_COD = COD "
cSq2 += "  GROUP BY COD,B1_COD "
//cSq2 += " GROUP BY COD "

//  01 Venda            
//  05 brinde      
//  13 filial entrega
//  14 entrega fora do estado ou praca
//  04 nao repor
//  15 entrega pela fabrica
//  16 tercerizados
//  20 nao repor sem comissao e guelta
//  21 nao repos sem comissao com guelta                   

                                              
*************************
memowrit("C:\pasta\lervenda.sql", cSq2)

TcQuery cSq2 Alias "TDV" New

TD2->(dbSelectArea(1))

//IncProc(RecCount("TDV"))
//TDV->(dbGoTop())
    
nquantVd  :=  TDV->QTD

dbSelectArea("TDV")
dbCloseArea()

Return



Static Function LeUPME()

cSqU := "select M2_DATA,M2_MOEDA5 "
cSqU += " from siga."+RETSQLNAME("SM2")+" "
cSqU += " WHERE D_E_L_E_T_ = ' ' "
cSqU += " AND M2_DATA = '"+DTOS(DDATABASE)+"' "
                                             
*************************
memowrit("C:\pasta\lervenda_V2.sql", cSqU)

TcQuery cSqU Alias "TUU" New
                       
//IncProc(RecCount("TUU"))
//TUU->(dbGoTop())
    
nvalupme  := 0.00
nvalupme  := TUU->M2_MOEDA5
//nvalupme  := 1.00

dbSelectArea("TUU")
dbCloseArea()

//nvalupme  :=  25.85

Return
                                     



Static Function Lerz6p(cpro6n,cProj)

cSqZ6 := "select Z6_CODPROD,Z6_NUMPROJ,Z6_DESCPRO,Z6_TABVEN,Z6_REFTAB,Z6_DTPROJ "
cSqZ6 += " from siga."+RETSQLNAME("SZ6")+"  "
cSqZ6 += " WHERE D_E_L_E_T_ = ' ' "
cSqZ6 += " AND Z6_CODPROD = '"+cpro6n+"   ' "       
cSqZ6 += " and Z6_NUMPROJ = '"+cProj+"' "
memowrit("C:\pasta\Lerz6p.sql", cSqZ6)
TcQuery cSqZ6 Alias "T66" New
                       
//IncProc(RecCount("T66"))
//T66->(dbGoTop())
nZ6DESCPRO  :=  0.00 
nZ6DESCPRO  :=  T66->Z6_DESCPRO

dbSelectArea("T66")
dbCloseArea()

Return
              


Static Function TotFin()

dbSelectArea("TD2")
//TD2->(dbGoTop())

ntotfinp := 0.00
nttqtg   := 0

While !eof()
	
	nquantVd := 0.00
	//		lervenda(TD2->B1_COD)
	nquantVd := TD2->QTDVEN
	dbSelectArea("TD2")
	
	nPMARFIL := (TD2->DA1_PRCVEN * nquantVd )


	_nPLIQ := (nPMARFIL - ( nPMARFIL*nqtd/100))
	_nPLIQ := (_nPLIQ   - ( _nPLIQ*nfin/100 ))
	ntotfinp := ntotfinp + _nPLIQ
	
	TD2->(dbSkip()) // Avanca o ponteiro do registro no arquivo
	nttqtg   := nttqtg   + nquantVd
	
EndDo
//alert(ntotfinp)
//alert(nttqtg)
dbSelectArea("TD2")
TD2->(dbGoTop())

Return
                                             


Static Function Lergrupo(cgrp6)

cSqZg := "SELECT BM_GRUPO,BM_DESC "
cSqZg += " FROM SIGA.SBM200 "
cSqZg += " WHERE D_E_L_E_T_ = ' ' "
cSqZg += " and BM_GRUPO = '"+cgrp6+"' "
memowrit("C:\pasta\Lerz6p.sql", cSqZg)
TcQuery cSqZg Alias "T6G" New
                       
If !IsBlind() ; IncProc(RecCount("T6G")) ; EndIf
//T6G->(dbGoTop())
                 
nnomegru := space(15)                        
nnomegru := T6G->BM_DESC + " SOB-MEDIDA M3"

dbSelectArea("T6G")
dbCloseArea()
                          
Return


Static Function precom()

//lChkCom  := .f. //.t.
lChkLoja := .t. // .f.
lChkLExc := .f.

**************************           
//lChkCom  := .f.                        
lChkLoja := .f.
lChkLExc := .f.
**************************           
       
oChkCom:Refresh()                     
//oChkLoja:Refresh()
//oChkLExc:Refresh()

Return 

Static Function preloj()

//lChkCom  := .f. //.f.
lChkLoja := .t.
lChkLExc := .f.

**************************           
//lChkCom  := .f.                        
lChkLoja := .f.
lChkLExc := .f.
**************************           

              
oChkCom:Refresh()                     
oChkLoja:Refresh()
oChkLExc:Refresh()

Return        

Static Function preexc()

//lChkCom  := .f.
lChkLoja := .t. // .f.
lChkLExc := .F. //.t.
**************************           
//lChkCom  := .f.                        
lChkLoja := .f.
lChkLExc := .f.
**************************           

              
oChkCom:Refresh()                     
oChkLoja:Refresh()
oChkLExc:Refresh()

Return        
                                                             


Static Function lerqtgru(cgrupo6)

cSqZ4 := "select  "
cSqZ4 += "      SUM(QTDVEN) / 1.00 QTD "
cSqZ4 += "   from siga.V_MIX"+cfilemp+", SIGA."+RETSQLNAME("SB1")+" SB1 "
cSqZ4 += "  WHERE SB1.D_E_L_E_T_ = ' ' "
cSqZ4 += "    AND EMISSAO >= '"+DTOS(DEMIS1)+"' "
cSqZ4 += "    AND EMISSAO <= '"+DTOS(DEMIS2)+"' "
cSqZ4 += "    and OPER IN ('01') "
cSqZ4 += "    AND B1_FILIAL = '  ' "
cSqZ4 += "    AND B1_XCODBAS = ' ' "
cSqZ4 += "    AND B1_COD = COD "
cSqZ4 += "    AND B1_COD not in ('1040710635','1090710088','1090710070') " // Nao aparecer o produto COLCH C/LOGO P/ ACAD - wfa - 26/03/12 - a pedido do Sr. Jose Antonio

cSqZ4 += "    AND B1_GRUPO = '"+cgrupo6+"' "
TcQuery cSqZ4 Alias "T64" New
                       
//IncProc(RecCount("T64"))
//T64->(dbGoTop())

nqtdgrup := 0                
nqtdgrup := T64->QTD                


dbSelectArea("T64")
dbCloseArea()


Return 
                                               

Static Function lerxsugt(csuxgru)

cSqZ5 := "select SBM.BM_XSUBGRU,SUM(QTDVEN) / 1.00 QTD  "
cSqZ5 += "  from siga.V_MIX"+cfilemp+" M, SIGA."+RETSQLNAME("SB1")+" SB1 , SIGA."+RETSQLNAME("SBM")+" SBM "
cSqZ5 += "     WHERE SB1.D_E_L_E_T_ = ' ' AND SBM.D_E_L_E_T_ = ' '   "
cSqZ5 += "     AND M.EMISSAO    >= '"+DTOS(DEMIS1)+"' "
cSqZ5 += "     AND M.EMISSAO    <= '"+DTOS(DEMIS2)+"' "
cSqZ5 += "     and M.OPER IN ('01')  "
cSqZ5 += "     AND SB1.B1_FILIAL  = '  '  "
cSqZ5 += "     AND SB1.B1_XCODBAS = ' '  "
cSqZ5 += "     AND SB1.B1_COD     = M.COD "
cSqZ5 += "     AND SB1.B1_GRUPO   = BM_GRUPO "    
cSqZ5 += "     AND SBM.BM_FILIAL  = '  ' "
cSqZ5 += "     AND SBM.BM_XSUBGRU = '"+csuxgru+"' "
//cSqZ5 += "     AND SB1.B1_GRUPO in ('9324' ,'9270','9296') "

cSqZ5 += "    AND SB1.B1_COD not in ('1040710635','1090710088','1090710070') " // Nao aparecer o produto COLCH C/LOGO P/ ACAD - wfa - 26/03/12 - a pedido do Sr. Jose Antonio
                           

cSqZ5  += "    AND SB1.B1_XSEGMEN IN ("+cSegm+") "
cSqZ5  += "    AND SB1.B1_MSBLQL     = '2' "      
cSqZ5  += "    AND (SUBSTR( SB1.B1_COD,1,1) = '1' OR SUBSTR( SB1.B1_COD,1,1) = '5') "
cSqZ5  += "    AND SB1.B1_TIPO IN ('TC', 'PA') "


cSqZ5 += " GROUP BY SBM.BM_XSUBGRU "
                                                         
TcQuery cSqZ5 Alias "T65" New
                       
//IncProc(RecCount("T65"))
//T65->(dbGoTop())

nqtdsubgrup := 0                
nqtdsubgrup := T65->QTD                
                 
//alert("ddd"+csuxgru)
//alert(nqtdsubgrup)

dbSelectArea("T65")
dbCloseArea()


Return


**************************************************
*** Participacao do Grupo ************************
**************************************************

                                                  
Static Function TotFingrupo(grup6)

cSqlg  := "SELECT B1_GRUPO, "
cSqlg  += "        B1_COD, "
cSqlg  += "        B1_DESC, "
cSqlg  += "        B1_XMED, "
cSqlg  += "        "+str(nqtd,6,0)+" as B1_XRESSAR, "
cSqlg  += "        "+str(nfin,6,0)+" as B1_XGUELMT, "
cSqlg  += "        B1_MSBLQL, "
cSqlg  += "        B1_TIPO, "
cSqlg  += "        B1_XLARG, "
cSqlg  += "        B1_XCOMP, "
cSqlg  += "        B1_XALT, "
cSqlg  += "        DA1_CODTAB, "
cSqlg  += "        DA1_CODPRO, "
cSqlg  += "        DA1_PRCVEN / "+str(nvalupme,8,2)+", "
cSqlg  += "        DA1_TPOPER, "
cSqlg  += "        DA1_XCUSTO / "+str(nvalupme,8,2)+", "
cSqlg  += "        BM_GRUPO,BM_XSUBGRU,BM_XORDMIX,X5_DESCRI "
cSqlg  += "   FROM SIGA."+RETSQLNAME("SB1")+" SB1, SIGA."+RETSQLNAME("DA1")+" DA1, SIGA."+RETSQLNAME("SBM")+" SBM, SIGA."+RETSQLNAME("SX5")+" SX5 "
cSqlg  += "  WHERE SB1.D_E_L_E_T_  = ' ' "
cSqlg  += "    AND DA1.D_E_L_E_T_(+) = ' ' "
cSqlg  += "    AND SBM.D_E_L_E_T_    = ' ' "
cSqlg  += "    AND SX5.D_E_L_E_T_    = ' ' "
cSqlg  += "    AND DA1_FILIAL(+) = '"+XFILIAL("DA1")+"' "
cSqlg  += "    AND B1_FILIAL     = '"+XFILIAL("SB1")+"' "
cSqlg  += "    AND BM_FILIAL     = '"+XFILIAL("SBM")+"' "
cSqlg  += "    AND X5_FILIAL     = '"+XFILIAL("SX5")+"' "
cSegm := "'2','6'"  // Incluido esta opcao somente franqueado e excluisva pelo fato deste mapa comercializacao ser somente para Franquias e Lojas Exclusivas WFA 30/12/11
cSqlg  += "    AND B1_XSEGMEN IN ("+cSegm+") "
cSqlg  += "    AND B1_MSBLQL     = '2' "      
cSqlg  += "    AND (SUBSTR( B1_COD,1,1) = '1' OR SUBSTR( B1_COD,1,1) = '5') "
cSqlg  += "    AND B1_TIPO IN ('TC', 'PA') "
cSqlg  += "    AND DA1_CODTAB(+) = '"+cTab+"' "
cSqlg  += "    AND B1_COD        = DA1_CODPRO(+) "
cSqlg  += "    AND B1_XCODBAS    = ' ' "
cSqlg  += "    AND DA1_CODPRO    <> ' ' "
cSqlg  += "    AND B1_GRUPO      <> ' ' "
cSqlg  += "    AND B1_GRUPO      = BM_GRUPO "
//cSql  += "    AND B1_GRUPO in ('9324' ,'9270','9296') " //,'9327') " // ,'7050','9293','9297') "
cSqlg  += "    AND BM_XSUBGRU    = X5_CHAVE "
cSqlg  += "    AND X5_TABELA     = 'ZA' "

if !lChkFL
   cSqlg  += "    AND (B1_XFORLIN = '        ' OR B1_XFORLIN > '"+DToS(dDataBase-90)+"') "
endif

if !lChkSBM                                       
   cSqlg  += " and B1_XCODBAS    = ' ' "
Endif
                                  
if !lchkfc
	cSqlg  += "    AND B1_XMODELO NOT IN ('000015') "
endif

//cSqlg  += "    AND B1_COD <> '1040710635' " // Nao aparecer o produto COLCH C/LOGO P/ ACAD - wfa - 26/03/12 - a pedido do Sr. Jose Antonio
cSqlg  += "    AND B1_COD not in ('1040710635','1090710088','1090710070') " // Nao aparecer o produto COLCH C/LOGO P/ ACAD - wfa - 26/03/12 - a pedido do Sr. Jose Antonio

/*if !lChkLRes
cSqlg  += "    AND B1_COD <> '1090710088' " // Nao aparecer o produto TRAV ACRILON ATACADA - wfa - 26/03/12 - a pedido do Sr. Jose Antonio
cSqlg  += "    AND B1_COD <> '1090710070' " // Nao aparecer o produto TRAVESSEIRO FLOCOS - wfa - 26/03/12 - a pedido do Sr. Jose Antonio
endif*/
                     
cSqlg  += "    AND B1_GRUPO  = '"+grup6+"'  "
cSqlg  += "  order by BM_XORDMIX,BM_XSUBGRU,BM_GRUPO,B1_COD "

memowrit("C:\pasta\ORTR048grupo_com_V2.sql", cSqlg)
TcQuery cSqlg Alias "TGG" New

dbSelectArea("TGG")
//TGG->(dbGoTop())
    
ngtotfinp := 0.00      
ngttqtg   := 0

While !eof()                

			nquantVd := 0.00                 
			        
		//	lervenda(TGG->B1_COD)
			nquantVd := TD2->QTDVEN 
			dbSelectArea("TGG")

			nPMARFIL := (TGG->DA1_PRCVEN * nquantVd )
//			TD2->DA1_PRCVEN

            _nPLIQ := (nPMARFIL - ( (nPMARFIL * (TGG->B1_XRESSAR ))/100 ))

            _nPLIQ := (_nPLIQ   - ( (_nPLIQ   * (TGG->B1_XGUELMT ))/100 ))
            
            ngtotfinp := ngtotfinp + _nPLIQ

			TGG->(dbSkip()) // Avanca o ponteiro do registro no arquivo

			ngttqtg   := ngttqtg   + nquantVd
EndDo                                     
                   
dbSelectArea("TGG")
dbCloseArea()

Return


/***********************************************************************************
** FunÁ„o criada para iprimir a diferenÁa entre o preÁo da tabela anterio a atual **
***********************************************************************************/

Static Function fImpDif(aImpDif,cTab,cRef,cProj)

Local _cTabRef 	:= cTab+cRef
Local _cTabRef2 := 0
Local nLinha	:= 2350
Local cCod 		:=  ""

_cTabRef2 := STRZERO(val(cTab)-1,3)+cRef

cCod := "("
     For _nI := 1 To Len(aImpDif) 
		cCod += "'"+aImpDif[_nI][1]+"',"
     Next _nI
cCod := Substr(cCod,1,len(cCod)-1) + ")"

cQuery := " select ACP_CODPRO, "
cQuery += "        b1_desc, "
cQuery += "        XPRCATU, "
cQuery += "        XPRCANT, "
cQuery += "        round(((XPRCATU - XPRCANT) / XPRCANT) * 100, 4) AS VARIAC "
cQuery += "   FROM (select ACP_CODPRO, "
cQuery += "                SB1.B1_DESC, "

if substr(cProj,6,1) $ "A"
	cQuery += "                NVL(Z6_PRCDIG,NVL(ACP_XPRECO,DA1_PRCVEN*"+AllTrim(Str(nRefCom__A))+")) AS XPRCATU, "
elseif substr(cProj,6,1) $ "B"
	cQuery += "                NVL(Z6_PRCDIG,NVL(ACP_XPRECO,DA1_PRCVEN*"+AllTrim(Str(nRefCom__B))+")) AS XPRCATU, "
elseif substr(cProj,6,1) $ "C"
	cQuery += "                NVL(Z6_PRCDIG,NVL(ACP_XPRECO,DA1_PRCVEN*"+AllTrim(Str(nRefCom__C))+")) AS XPRCATU, "
elseif substr(cProj,6,1) $ "D"
	cQuery += "                NVL(Z6_PRCDIG,NVL(ACP_XPRECO,DA1_PRCVEN*"+AllTrim(Str(nRefCom__D))+")) AS XPRCATU, "
elseif substr(cProj,6,1) $ "E"
	cQuery += "                NVL(Z6_PRCDIG,NVL(ACP_XPRECO,DA1_PRCVEN*"+AllTrim(Str(nRefCom__E))+")) AS XPRCATU, "
elseif substr(cProj,6,1) $ "F"
	cQuery += "                NVL(Z6_PRCDIG,NVL(ACP_XPRECO,DA1_PRCVEN*"+AllTrim(Str(nRefCom__F))+")) AS XPRCATU, "
elseif substr(cProj,6,1) $ "G"
	cQuery += "                NVL(Z6_PRCDIG,NVL(ACP_XPRECO,DA1_PRCVEN*"+AllTrim(Str(nRefCom__G))+")) AS XPRCATU, "
elseif substr(cProj,6,1) $ "H"
	cQuery += "                NVL(Z6_PRCDIG,NVL(ACP_XPRECO,DA1_PRCVEN*"+AllTrim(Str(nRefCom__H))+")) AS XPRCATU, "
else
	cQuery += "                NVL(Z6_PRCDIG,NVL(ACP_XPRECO,DA1_PRCVEN*"+AllTrim(Str(nRefCom__I))+")) AS XPRCATU, "
Endif

cQuery += "                (select ACP_XPRECO AS XPRCANT "
cQuery += "                   from siga." + RetSQLName("ACP") + " ACP "
cQuery += "                  WHERE D_E_L_E_T_ = ' ' "
cQuery += "                    and ACP_FILIAL = ' ' "
cQuery += "                    AND ACP_CODPRO = sb1.b1_cod "
cQuery += "                    AND SUBSTR(ACP_CODREG, 3, 4) = ('"+_cTabRef2+"')) AS XPRCANT "
cQuery += "           from SIGA." + RetSQLName("ACP") + " ACP, SIGA." + RetSQLName("SB1") + " SB1, SIGA." + RetSQLName("SZ6") + " SZ6,  SIGA." + RetSQLName("DA1") + " DA1 "
cQuery += "          WHERE ACP.D_E_L_E_T_(+) = ' ' "
cQuery += "            AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "            AND SZ6.D_E_L_E_T_(+) = ' ' "
cQuery += "            and ACP_FILIAL(+) = ' ' "
cQuery += "            and B1_FILIAL = ' ' "
cQuery += "            AND DA1_FILIAL = ' ' "
cQuery += "            AND Z6_FILIAL(+) = ' ' "
cQuery += "            and B1_COD = DA1_CODPRO "
cQuery += "            AND DA1_CODPRO  IN "+cCod
cQuery += "            AND DA1_CODPRO = Z6_CODPROD(+) "
cQuery += "            AND DA1_CODPRO = ACP_CODPRO(+) "
cQuery += "            AND DA1_CODTAB = '"+cTab+"' "
cQuery += "            AND Z6_NUMPROJ(+) = '"+cProj+"' "
cQuery += "            AND SUBSTR(ACP_CODREG(+), 3, 4) = ('"+_cTabRef+"')) "
cQuery += "  ORDER BY 5 "

MemoWrite("C:\ORTA349_DIF.SQL",cQuery)
TcQuery cQuery Alias "QRYDIF" New

DbSelectArea("QRYDIF")
//DbGoTop()
If Eof()
	DbCloseArea()
	Return
Else
	while !Eof()
		if nLinha >= 2350
			oPrn:EndPage()
			nLinha := fCabDif()
		Endif

		If (QRYDIF->XPRCATU-QRYDIF->XPRCANT) <> 0
			oPrn:Say(nLinha,0055,QRYDIF->ACP_CODPRO,oCouNew11)
			oPrn:Say(nLinha,0305,QRYDIF->B1_DESC,oCouNew11)
			oPrn:Say(nLinha,0960,TRANSFORM(QRYDIF->XPRCATU,"@E 99,999.99"),oCouNew11)
			oPrn:Say(nLinha,1280,TRANSFORM(QRYDIF->XPRCANT,"@E 99,999.99"),oCouNew11)
			oPrn:Say(nLinha,1580,TRANSFORM(QRYDIF->XPRCATU-QRYDIF->XPRCANT,"@E 99,999.99"),oCouNew11)
			oPrn:Say(nLinha,1905,TRANSFORM(QRYDIF->VARIAC,"@E 99,999.99")+" %",oCouNew11)
			nLinha += 50
		Endif
		dbskip()
	Enddo
EndIf
DbSelectArea("QRYDIF")
DbCloseArea()
Return





Static Function fCabDif()

Private titulo         := "MAPA COMERCIALIZACAO (COMERCIAL) "

oPrn:StartPage()

oPrn:Box(050,010,300,3330)
oPrn:SayBitmap(100,075,cLogo,200,075)	   	                        // Impressao do Logotipo.
oPrn:Say(150,075,"/SIGA/" + AllTrim(FunName()), oCouNew11,,,, 0)		// Impressao do Nome da rotina do relatorio.
oPrn:Say(200,075,"Hora  :" + Time() + " - Empresa: " + cfilemp, oCouNew11,,,, 3)	// Impressao da hora de impressao.


oPrn:Say(100,2910,"Pagina :    " + strzero(nPag,3,0), oCouNew11,,,,3)  // Impressao do Numero da Pagina.
oPrn:Say(150,2910,"Data   :"     + DtoC(dDataBase)  , oCouNew11,,,, 3)	// Impressao da data de impressao.
oPrn:Say(200,2910,"Emissao:"     + DtoC(dDataBase)  , oCouNew11,,,, 3)	// Impressao da data de impressao.

titulo := "MAPA COMERCIALIZACAO  C O M E R C I A L NO PERIODO DE "+dtoc(dEmis1)+" A "+dtoc(dEmis2)


oPrn:Say(150, 800, titulo, oCouNew12,,,, 0)

oPrn:Box(300,010,650,3330)
oPrn:Say(300,010,"PROJE«√O         : "+CPROJ+   " PERIODO : "+ DTOC(DEMIS1)+" ATE "+ DTOC(DEMIS2), oCouNew11,,,, 0)
oPrn:Say(400,010,"SEGMENTO         : LOJAS COMERCIAS ", oCouNew11,,,, 0) // INDUSTRIAL " //COMERCIAL ["+IIF(LCHKCOM,'X',' ')+"]    LOJA ["+IIF(LCHKLOJA,'X',' ')+"]   LOJA EXCLUSIVA ["+IIF(LCHKLEXC,'X',' ')+"]   "
oPrn:Say(450,010,"USUARIO          : GER. GERAL, GER. LOJA E GESTOR DE PRECOS.", oCouNew11,,,, 0)
oPrn:Say(500,010,"OBJETIVO         : ESTE MAPA PROJETA O NOVO MIX DE ACORDO COM OS DESCONTOS E ACRESCIMOS PRATICADOS.", oCouNew11,,,, 0)
oPrn:Say(550,010,"PER. UTILIZACAO  : QUINZENAL E/OU MENSAL.", oCouNew11,,,, 0)

cslchkpul := " "
if lchkpul
	cslchkpul := "X"
endif

cslchkesp := " "
if lchkesp
	cslchkesp := "X"
endif

cslchksp := " "
if lchksp
	cslchksp := "X"
endif

oPrn:Say(600,010,"TIPO DE CLIENTE  : PULVERIZADO ["+cslchkpul+"] - ESPECIAL ["+cslchkesp+"] - SUPERVERTICAL ["+cslchksp+"]", oCouNew11,,,, 0)

oPrn:Say(700,015,"CODIGO",oCouNew11,0)

oPrn:Say(700,305,"DESCRICAO",oCouNew11,0)

oPrn:Say(700,955,"PRC ATUAL",oCouNew11,0)

oPrn:Say(700,1225,"PRC ANTERIOR",oCouNew11,0)

oPrn:Say(700,1575,"DIFEREN«A",oCouNew11,0)

oPrn:Say(700,1935,"VARIA«√O",oCouNew11,0)


oPrn:Box(650,010,750,3330)

nLin:= 800
nPag += 1
Return(nLin)


Static Function QtdTotPC()

tnQtd	:= 0.00

cQuery := "  SELECT SUM ((select SUM(QTDVEN) QTD "
cQuery += "   			   from siga.V_MIX"+cfilemp+"  , siga."+RETSQLNAME("SA1")+" SA1 "
cQuery += "              WHERE SA1.D_E_L_E_T_ = ' ' "
cQuery += "    			   AND EMISSAO between '"+DTOS(DEMIS1)+"' and '"+DTOS(DEMIS2)+"' "
cQuery += "                AND COD = SB1.B1_COD "
cQuery += "                and OPER IN ('01') "
cQuery += "                AND A1_FILIAL = '"+XFILIAL("SA1")+"' "
IF .NOT.(Empty(ctpcliin))
	cQuery += "   and A1_XTPCLI IN "+ctpcliin+" " //('S','P','E') "
EndIF	

cQuery += "                AND A1_COD = CLIENTE "
cQuery += "                AND QTDVEN <> 0 "
cQuery += "              GROUP BY COD)) QTDTOTPC "
cQuery += "   FROM SIGA."+RETSQLNAME("SB1")+" SB1, SIGA."+RETSQLNAME("DA1")+" DA1, SIGA."+RETSQLNAME("SBM")+" SBM, SIGA."+RETSQLNAME("SX5")+" SX5 "
cQuery += "  WHERE SB1.D_E_L_E_T_ = ' ' "
cQuery += "    AND DA1.D_E_L_E_T_(+) = ' ' "
cQuery += "    AND SBM.D_E_L_E_T_ = ' ' "
cQuery += "    AND SX5.D_E_L_E_T_ = ' ' "
cQuery += "    AND DA1_FILIAL(+) = '"+XFILIAL("DA1")+"' "
cQuery += "    AND B1_FILIAL     = '"+XFILIAL("SB1")+"' "
cQuery += "    AND BM_FILIAL     = '"+XFILIAL("SBM")+"' "
cQuery += "    AND X5_FILIAL     = '"+XFILIAL("SX5")+"' "
cQuery += "    AND B1_XSEGMEN IN ("+cSegm+") "
cQuery += "    AND B1_MSBLQL = '2' "
cQuery += "    AND SUBSTR(B1_COD, 1, 1) in ('1', '4') "
cQuery += "    AND B1_TIPO IN ('TC', 'PA') "
cQuery += "    AND DA1_CODTAB(+) = '"+cTab+"' "
cQuery += "    AND B1_COD = DA1_CODPRO(+) "
cQuery += "    AND B1_XCODBAS = ' ' "
cQuery += "    AND DA1_CODPRO <> ' ' "
cQuery += "    AND B1_GRUPO <> ' ' "
cQuery += "    AND B1_GRUPO = BM_GRUPO "
cQuery += "    AND BM_XSUBGRU = X5_CHAVE "
cQuery += "    AND X5_TABELA = 'ZA'  "
cQuery += "    and B1_XCODBAS = ' ' "
cQuery += "    AND B1_XMODELO NOT IN ('000015') "
cQuery += "    AND B1_COD not in ('1040710635', '1090710088', '1090710070') "

MemoWrite("C:\ORTA349qtdtotpcs.SQL",cQuery)
TcQuery cQuery Alias "QTDTOT" New

tnQtd	:= QTDTOT->QTDTOTPC

dbSelectArea("QTDTOT")
dbCloseArea()

Return


**************************************************
User Function Orta349LOk(nParLin)
Local nX		:= 0
Local nPosCplOk	:= 0
Local lLinOk	:= .T.
Local aHeadLok	:= oGetD:aHeader
Local aColsLok	:= oGetD:aCols
Local nPosLok	:= oGetD:nAt
Local nprcdig   := 0
Local npmarfil  := 0

If !Empty(nParLin)
	nPosLok	:= nParLin
EndIf

aColsLok	:= aColsLok[nPosLok]
cMsg :=""

If oGetD:aCols[nPosLok,Len(oGetD:aCols[nPosLok])]
	Return(lLinOk)
endif

If lLinOk
	nPosCplOk	:= AScan(aHeadLok, {|x| AllTrim(x[2]) == "Z6_CODPROD"})
	If nPosCplOk > 0 .and. len(Alltrim(aColsLok[nPosCplOk]))==4
		lLinOk	:= ExistCpo("SBM", aColsLok[nPosCplOk], 1)
		cMsg:= "O Sob-Medida da linha "
	Else
		lLinOk	:= ExistCpo("SB1", aColsLok[nPosCplOk], 1)
		cMsg:= "O Produto "
	EndIf
EndIf

If lLinOk
	nPosCplOk	:= AScan(aHeadLok, {|x| AllTrim(x[2]) == "Z6_PRCDIG"})
	If nPosCplOk > 0
		lLinOk	:= (aColsLok[nPosCplOk] > 0)
		If !lLinOk
			MsgStop(cMsg+AllTrim(aColsLok[AScan(aHeadLok, {|x| AllTrim(x[2]) == "Z6_CODPROD"})])+" est· sem preÁo digitado! Este produto n„o pode pertencer a projeÁ„o.")
		EndIf
	EndIf
EndIf

If lLinOk
	nPosCplOk	:= AScan(aHeadLok, {|x| AllTrim(x[2]) == "Z6_PRCDA1"})
	If nPosCplOk > 0
		lLinOk	:= (aColsLok[nPosCplOk] > 0)
		If !lLinOk
			MsgStop(cMsg+AllTrim(aColsLok[AScan(aHeadLok, {|x| AllTrim(x[2]) == "Z6_CODPROD"})])+" est· sem preÁo marfil! Este produto n„o pode pertencer a projeÁ„o.")
		EndIf
	EndIf
EndIf

// 04/02/2015 - Fabio Costa - solicitaÁ„o do Sr.Rubens
nprcdig   := aColsLok[AScan(aHeadLok, {|x| AllTrim(x[2]) == "Z6_PRCDIG"})]   
npmarfil  := aColsLok[AScan(aHeadLok, {|x| AllTrim(x[2]) == "Z6_PRCDA1"})]

if nprcdig > npmarfil+(npmarfil*0.1)+(npmarfil*gvaria(cRef))
	lLinOk	:= .F.
	MsgStop(cMsg+AllTrim(aColsLok[AScan(aHeadLok, {|x| AllTrim(x[2]) == "Z6_CODPROD"})])+" possui mais de 10% de variaÁ„o em relaÁ„o a prevista da Marfil.")
endif                

/*If lLinOk
	nPosCplOk	:= AScan(aHeadLok, {|x| AllTrim(x[2]) == "Z6_CODPROD"})
	If nPosCplOk > 0 .and. len(Alltrim(aColsLok[nPosCplOk]))>4
		aAdd(oGetD:aCols,{aColsLok[9],aColsLok[2],aColsLok[3],aColsLok[4],aColsLok[5],aColsLok[6],aColsLok[7],aColsLok[8],AllTrim(aColsLok[9])+"_"})
	EndIf
EndIf*/

Return(lLinOk)

**************************************************
User Function Orta349TOk()
Local nX		:= 0
Local nY		:= 0
Local lTudOk	:= .T.
Local aColsTok	:= oGetD:aCols
Local nPosCplOk	:= 0
Local cProdTOk	:= ""
Local aColsTTmp	:= {}

If lTudOk
	nPosCplOk	:= AScan(oGetD:aHeader, {|x| AllTrim(x[2]) == "Z6_CODPROD"})
	For nX := 1 To Len(oGetD:aCols)
		If !oGetD:aCols[nX,Len(oGetD:aCols[nX])]
			cProdTOk	:= PADR(oGetD:aCols[nX,nPosCplOk],GetSx3Cache("B1_COD","X3_TAMANHO"))
			nY	:= AScan(aColsTTmp, cProdTOk)
			If nY <> 0
				lTudOk	:= .F.
				If Len(AllTrim(oGetD:aCols[nX,nPosCplOk]))==4
					MsgStop("O Sob-Medida '"+AllTrim(oGetD:aCols[nX,nPosCplOk])+"' est· duplicado!")
				Else
					MsgStop("O produto '"+AllTrim(oGetD:aCols[nX,nPosCplOk])+"' est· duplicado!")
				Endif
				Exit
			EndIf
			aAdd( aColsTTmp, cProdTOk )
		EndIf
	Next nX
EndIf

If lTudOk
	For nX := 1 To Len(aColsTok)
		lTudOk	:= U_Orta349LOk(nX)
		If !lTudOk
			Exit
		EndIf
	Next nX
EndIf

Return lTudOk

Static Procedure GdGoToCol(oBrowse,cReadVar,aFieldPos)
Return(StaticCall(ORTA348,GdGoToCol,@oBrowse,@cReadVar,@aFieldPos))

// =========================
Static Function gvaria(cRef)
_nvaria := 0
_cRef 	:= Upper(alltrim(cRef))

If cEmpAnt $ "23"
	If _cRef == "A"
		_nvaria	:= 0.00
	ElseIf _cRef == "B"
		_nvaria	:= 0.05
	ElseIf _cRef == "C"
		_nvaria	:= 0.10
	ElseIf _cRef == "D"
		_nvaria	:= 0.15
	ElseIf _cRef == "E"
		_nvaria	:= 0.20
	ElseIf _cRef == "F"
		_nvaria	:= 0.25
	ElseIf _cRef == "G"
		_nvaria	:= 0.30
	ElseIf _cRef == "H"
		_nvaria	:= 0.35
	ElseIf _cRef == "I"
		_nvaria	:= 0.40
	EndIf
Else
	if _cRef == "B"
		_nvaria := 0.05
	endif
	if _cRef == "C"
		_nvaria := 0.1
	endif
	if _cRef == "D"
		_nvaria := 0.15
	endif
	if _cRef $ "EN" 
		_nvaria := 0.2
	endif
	if _cRef == "F"
		_nvaria := 0.25
	endif
	if _cRef == "G"
		_nvaria := 0.3
	endif
	if _cRef == "H"
		_nvaria := 0.35
	endif
	if _cRef == "I"
		_nvaria := 0.4
	endif
EndIf

return _nvaria

