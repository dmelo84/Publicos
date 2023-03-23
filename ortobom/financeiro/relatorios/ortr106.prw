/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORTR106   ºAutor  ³ Ronaldo Pena              º Data ³  07/12/06 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELATORIO PARA EMISSAO DO FLUXO DE CAIXA POR FILIAL/GERAL       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ESPECIFICO ORTOBOM                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#include "PROTHEUS.ch"
#include "TopConn.ch"
#INCLUDE "RWMAKE.CH"

***********************
User Function ORTR106()
***********************
Private Cabec1       := "Relatorio de Fluxo de Caixa"
Private Cabec2       := " "
Private aOrd         := {}
Private cTitulo      := "Fluxo de Caixa "
Private nLin         := 0
Private cDesc1       := " "
Private cDesc2       := " "
Private cDesc3       := " "
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private nLimite      := 132
Private cTamanho     := "M"
Private cNomeprog    := "ORTR106"
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 1, 1, "", 1}
Private nLastKey     := 0
Private m_pag        := 01
Private wnrel        := "ORTR106"
Private cString      := "SE1"
Private nPag         := 0
Private cPerg   	   := "OTR106"

cArqTrb := "ORTR106"

ValidPerg(cPerg)
Pergunte(cPerg,.T.)

wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,cTamanho,,.T.)
If nLastKey == 27
	 Return
Endif

nTipo := If(aReturn[4]==1,15,18)
SetDefault(aReturn,cString)

Processa({|| fGeraTrb()},"Aguarde Processamento...")
//Return

If aReturn[5]==1
	DbCommitAll()
	Set Printer To
	OurSpool(wnrel)
Endif

Return

**************************
Static Function fGeraTrb()
**************************

If TcCanOpen(cArqTrb) ; TcDelFile(cArqTrb)   ; Endif
If Select("TRB") > 0  ; TRB->(DbCloseArea()) ; Endif
aCpoTrb := {{"DESCRI","C",30}}
dData   := mv_par03
While dData <= mv_par04
If Dow(dData) == 1 ; dData +=1 ; Endif
If Dow(dData) == 7 ; dData +=2 ; Endif
aAdd(aCpoTrb,{"D"+Dtos(dData),"N",12,2})
dData++
End

cChavTrb := "DESCRI"
DbCreate(cArqTrb,aCpoTrb)
DbUseArea(.T.,"DBFCDX",cArqTrb,'TRB',.F.,.F.)
TRB->(DbCreateIndex(cArqTrb, cChavTrb, {|| &cChavTrb},.F.))
TRB->(DbSetOrder(1))//nao trocar

****** Seleciona Titulos a Receber ******
cQry := " SELECT VENCTO, TOTCHQ, TOTDUP, TOTNP, TOTCRED, TOTCAR, TOTFIN, TOTMP, TOTDESP"
cQry += " FROM(
If mv_par01 == 1
cQry += " SELECT SE1.E1_VENCREA VENCTO, "
Else
	 cQry += " SELECT SE1.E1_XDTDIGI VENCTO, "
Endif
cQry += " SUM(CASE WHEN SE1.E1_TIPO IN ('CH', 'CHT') THEN E1_SALDO ELSE 0 END) TOTCHQ , "
cQry += " SUM(CASE WHEN SE1.E1_TIPO IN ('DP', 'DPC') THEN E1_SALDO ELSE 0 END) TOTDUP , "
cQry += " SUM(CASE WHEN SE1.E1_TIPO IN ('NP')        THEN E1_SALDO ELSE 0 END) TOTNP  , "
cQry += " SUM(CASE WHEN SE1.E1_TIPO IN ('CN')        THEN E1_SALDO ELSE 0 END) TOTCRED, "
cQry += " SUM(CASE WHEN SE1.E1_TIPO IN ('CC','CD')   THEN E1_SALDO ELSE 0 END) TOTCAR , "
cQry += " SUM(CASE WHEN SE1.E1_TIPO IN ('FI')        THEN E1_SALDO ELSE 0 END) TOTFIN , "
cQry += " 0                                                                    TOTMP  , "
cQry += " 0                                                                    TOTDESP  "
cQry += " FROM "+RetSqlName("SE1") +" SE1"
cQry += " WHERE SE1.D_E_L_E_T_ <> '*'"
cQry += "   AND SE1.E1_SALDO   >  0  "
If mv_par13 == 2
cQry += "   AND SE1.E1_FILIAL  = '"+xFilial("SE1")+"'"
Endif
If mv_par01 == 1
cQry += " AND SE1.E1_VENCREA BETWEEN '"+Dtos(mv_par03)+"' AND '"+Dtos(mv_par04)+"'"
Else
cQry += " AND SE1.E1_XDTDIGI BETWEEN '"+Dtos(mv_par03)+"' AND '"+Dtos(mv_par04)+"'"
Endif
If mv_par02 == 2
cQry += " AND SUBSTR(SE1.E1_NATUREZ,3,1) = '2' "
ElseIf mv_par02 == 3
cQry += " AND SUBSTR(SE1.E1_NATUREZ,3,1) = '1' "
Endif
cQry += " GROUP BY SE1.E1_VENCREA"
cQry += " UNION"

****** Seleciona Titulos a Pagar ******
If mv_par01 == 1
cQry += " SELECT SE2.E2_VENCREA,"
Else
cQry += " SELECT SE2.E2_XDTDIGI,"
Endif
cQry += "        0,
cQry += "        0,
cQry += "        0,
cQry += "        0,
cQry += "        0,
cQry += "        0,
cQry += "        SUM(CASE WHEN SUBSTR(SE2.E2_NATUREZ,1,8) = '03119082' THEN SE2.E2_SALDO ELSE 0 END),"
cQry += "        SUM(CASE WHEN SUBSTR(SE2.E2_NATUREZ,1,5) = '03115'    THEN SE2.E2_SALDO ELSE 0 END) "
cQry += " FROM "+RetSqlName("SE2")+" SE2"
cQry += " WHERE SE2.D_E_L_E_T_ <> '*'"
cQry += "   AND SE2.E2_SALDO   >  0  "

If mv_par13 == 2
cQry += "   AND SE2.E2_FILIAL  = '"+xFilial("SE2")+"'"
Endif

If mv_par01 == 1
cQry += " AND SE2.E2_VENCREA BETWEEN '"+Dtos(mv_par03)+"' AND '"+Dtos(mv_par04)+"'"
Else
cQry += " AND SE2.E2_XDTDIGI BETWEEN '"+Dtos(mv_par03)+"' AND '"+Dtos(mv_par04)+"'"
Endif

If mv_par02 == 2
cQry += " AND SUBSTR(SE2.E2_NATUREZ,3,1) = '2' "
ElseIf mv_par02 == 3
cQry += " AND SUBSTR(SE2.E2_NATUREZ,3,1) = '1' "
Endif
cQry += " GROUP BY SE2.E2_VENCREA)"
cQry += " ORDER BY VENCTO"

MemoWrite("C:\ORTR106.SQL",cQry)
If Select("QRY") > 0 ; QRY->(DbCloseArea()) ; Endif
DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),'QRY',.F.,.T.)

nSaldoIni := mv_par07
aGrava    := {{"SALDO INICIAL (S.I.)","nSaldoIni"   },;
{"CHEQUES"             ,"QRY->TOTCHQ" },;
{"DUPLICATAS"          ,"QRY->TOTDUP" },;
{"NOTA PROMISSORIA"    ,"QRY->TOTNP"  },;
{"CREDIARIO"           ,"QRY->TOTCRED"},;
{"CARTAO"              ,"QRY->TOTCAR" },;
{"FINANCEIRA"          ,"QRY->TOTFIN" },;
{"MATERIA PRIMA"       ,"QRY->TOTMP"  },;
{"DESPESAS GERAIS"     ,"QRY->TOTDESP"}}

QRY->(DbGoTop())
While QRY->(!Eof())
dData := Stod(QRY->VENCTO)
If Dow(dData) == 1 ; dData +=1 ; Endif
If Dow(dData) == 7 ; dData +=2 ; Endif

For L:=1 To Len(aGrava)
lOk := !TRB->(DbSeek(aGrava[L,1]))

TRB->(RecLock("TRB",lOk))
TRB->DESCRI := aGrava[L,1]
TRB->(FieldPut(FieldPos("D"+Dtos(dData)),&(aGrava[L,2])))
TRB->(MsUnLock())
Next
nSaldoIni += (QRY->(TOTCHQ+TOTDUP+TOTNP+TOTCRED+TOTCAR+TOTFIN-TOTMP-TOTDESP))
QRY->(DbSkip())
End
Return


***** Impressão *****
@ 0,0 psay AVALIMP(nLimite)

aMeses := {"Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"}
aDados := {}
TRB->(DbGoTop())
While TRB->(!Eof())
aAdd(aDados,{Subs(TRB->VENCTO,7,2)+"/"+aMeses[Val(Subs(TRB->VENCTO,5,2))]+"/"+Subs(TRB->VENCTO,3,2) ,;
TRB->TOTCHQ   ,;
TRB->TOTDUP   ,;
TRB->TOTNP    ,;
TRB->TOTCRED  ,;
TRB->TOTCAR   ,;
TRB->TOTFIN   ,;
TRB->TOTMP    ,;
TRB->TOTDESP  })

TRB->(DbSkip())
End

fCabec()
nBlocos := Round(Len(aDados)/5,0)
aColuns1:= {0,35,47,59,71,83,98}
aColuns2:= {0,33,45,57,69,83,93}

For B:=1 To nBlocos

For C:=1 To 5
@ nLin,aColuns1[1] PSay "CHEQUES"
@ nLin,aColuns1[2] PSay aDados[C*nBlocos]
Next

Next


Return

****************************
Static Function fCabec(nPar)
****************************

nLin := 0
@ nLin,00 PSay PadL("Previsão No. 06"          ,80)
@ nLin,00 PSay PadC("Previsão Financeira"      ,80)
@ nLin,00 PSay PadR("Emissao: "+Dtoc(dDataBase),80)

nLin++
@ nLin,00 PSay "Periodos: "+ Dtoc(mv_par03) +" a " + Dtoc(mv_par04)
@ nLin,30 PSay "Cobranca: "+ Dtoc(mv_par05) +" a " + Dtoc(mv_par06)
@ nLin,60 PSay "Cartao : " + Dtoc(mv_par10) +" a " + Dtoc(mv_par11)

nLin++
Return

************************************
Static Function validPerg()
************************************
Private aRegs := {}

//aAdd(aRegs,{"GRUPO", "ORDEM", "PERGUNT"                 , "VARIAVL", "TIPO", "TAMANHO","DECIMAL","GSC","VALID","VAR01"    , "F3" , "DEF01"        , "DEF02"           , "DEF03"  , "DEF04", "DEF05" })
aadd(aRegs,{cPerg  , "01" ,"Imprime Por Data......:","","","mv_ch1","N",01,0,0,"C","","mv_par01","Vencimento","","","","","Entrada","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "02" ,"Tipo de Relatorio.....:","","","mv_ch2","N",01,0,0,"C","","mv_par02","Geral","","","","","Conferencia","","","","","Remessa","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "03" ,"Periodo a listar  De..:","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "04" ,"Periodo a listar Ate..:","","","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "05" ,"Periodo Cobranca  De..:","","","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "06" ,"Periodo Cobranca Ate..:","","","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "07" ,"Saldo Inicial.........:","","","mv_ch7","N",12,2,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "08" ,"Dias Cobranca.........:","","","mv_ch8","N",03,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "09" ,"Dias Cartao...........:","","","mv_ch9","N",03,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "10" ,"Periodo Cartao  De....:","","","mv_cha","D",08,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "11" ,"Periodo Cartao Ate....:","","","mv_chb","D",08,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "12" ,"Materia Prima Por.....:","","","mv_chc","N",01,0,0,"C","","mv_par12","Vencimento","","","","","Entrada","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{cPerg  , "ZZ" ,"Emissao Por...........:","","","mv_chd","N",01,0,0,"C","","mv_par13","Todas Filiais","","","","","Filial Corrente","","","","","","","","","","","","","","","","","","","",""})

//Cria Pergunta
cPerg := U_AjustaSx1(cPerg,aRegs)

Return
