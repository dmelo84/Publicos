#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "RwMake.Ch"
#Include "SigaWin.Ch"
#include "colors.ch"
#include "font.ch"
#INCLUDE "JPEG.CH"
#INCLUDE "TBICONN.CH"
#Include "colors.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ ORTA575 ³ Autor ³ Victor Lopes          ³ Data ³ 15/10/15  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Locacao   ³                  ³Contato ³ vhrlopes@gmail.com             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Aprovação de comercialização                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³                                               ³±±
±±³              ³  /  /  ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function ORTA575()

Local cQuery	:= ""
Local aTabelas	:= {}
Local cAnoAtual	:= SubStr(DToS(dDataBase+7), 1, 4)
Local nRadio	:= 1

Private cNumProj	:= Space(GetSX3Cache("Z6_NUMPROJ","X3_TAMANHO"))
Private cCodTab		:= Space(GetSX3Cache("DA0_CODTAB","X3_TAMANHO"))
Private cRefTab		:= " "
Private nSegmen		:= 0

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
SetPrvt("oDlg1","oSay1","oSay2","oSay3","oRMenu1","oCBox1","oCBox2","oGet1","oBtn1")

cQuery := " SELECT DA0_CODTAB "
cQuery += "   FROM " + RetSqlName("DA0")
cQuery += "  WHERE D_E_L_E_T_ = ' ' "
cQuery += "    AND DA0_FILIAL = '"+xFilial("DA0")+"' "
cQuery += "    AND (('"+DToS(dDataBase)+"' BETWEEN DA0_DATDE AND DA0_DATATE) OR "
cQuery += "        DA0_DATDE > '"+DToS(dDataBase)+"') "
cQuery += "  ORDER BY 1 DESC "
U_ORTQUERY(cQuery, "ORTA575_X1")
aAdd(aTabelas, Space(GetSX3Cache("DA0_CODTAB","X3_TAMANHO")))
While ORTA575_X1->(!EOF())
	aAdd(aTabelas, PADR(ORTA575_X1->DA0_CODTAB,GetSX3Cache("DA0_CODTAB","X3_TAMANHO")))
	ORTA575_X1->(dbSkip())
EndDo
ORTA575_X1->(dbCloseArea())

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oDlg1      := MSDialog():New( 088,232,209,609,"Aprovação de Projeção",,,.F.,,,,,,.T.,,,.T. )
oSay1      := TSay():New( 008,076,{||"Marfil "+cAnoAtual},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay2      := TSay():New( 024,076,{||"Referência"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay3      := TSay():New( 040,076,{||"Projeção"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
GoRMenu1   := TGroup():New( 004,004,056,072,"Ação",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oRMenu1    := TRadMenu():New( 016,010,{"Incluir/Alterar","Consultar","Copiar Projeção"},,oDlg1,,,CLR_BLACK,CLR_WHITE,"",,,048,17,,.F.,.F.,.T. )
oRMenu1:bSetGet := {|u|Iif (PCount()==0,nRadio,nRadio:=u)}
oCBox1     := TComboBox():New( 008,112,,aTabelas,028,010,oDlg1,,,{||CarregaVar()},CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
oCBox2     := TComboBox():New( 024,112,,{" ","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"},028,010,oDlg1,,,{||CarregaVar()},CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,, )
oGet1      := TGet():New( 040,112,{|u| If(PCount()>0,cNumProj:=u,cNumProj)},oDlg1,072,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cNumProj",,)
oBtn1      := TButton():New( 008,144,"Ok",oDlg1,{||Processa({|| Efetiva(nRadio), oDlg1:End()},"Aguarde... processando comercialização '"+cNumProj+"'... ")},037,012,,,,.T.,,"",,,,.F. )

oDlg1:Activate(,,,.T.)

Return


**************************************************************************
Static Function CarregaVar()
**************************************************************************

Local nX		:= 0
Local lRet		:= .T.

cCodTab		:= Space(GetSX3Cache("DA0_CODTAB","X3_TAMANHO"))
cRefTab		:= " "

If lRet .And. (Len(oCBox2:aItems) * Len(oCBox2:aItems) == 0)
	lRet := .F.
	MsgStop("Tabela ou referência inválida")
EndIf

If lRet
	nX := oCBox1:nAt
	If Empty(nX)
		nX := 1
	EndIf
	cCodTab := PADR(oCBox1:aItems[nX], GetSX3Cache("DA0_CODTAB","X3_TAMANHO"))
EndIf

If lRet
	nX := oCBox2:nAt
	If Empty(nX)
		nX := 1
	EndIf
	cRefTab := PADR(oCBox2:aItems[nX], 01)
EndIf

If Empty(cCodTab) .Or. Empty(cRefTab)
	cNumProj	:= Space(GetSX3Cache("Z6_NUMPROJ","X3_TAMANHO"))
	oGet1:CtrlRefresh()
	Return .T.
EndIf

If lRet
	DA0->(dbOrderNickName("PDA01"))	//DA0_FILIAL+DA0_CODTAB
	lRet	:= DA0->(dbSeek(xFilial("DA0")+cCodTab))
EndIf

If lRet
	if SubStr(cCodTab, 2, 2) == '01'                                                                                         
		cNumProj := "1" + SubStr(cCodTab, 2, 2) + SubStr(DToS(DA0->DA0_DATATE), 3, 2) + cRefTab
	Else
		cNumProj := "1" + SubStr(cCodTab, 2, 2) + SubStr(DToS(DA0->DA0_DATDE), 3, 2) + cRefTab
	Endif
EndIf

If !lRet
	cNumProj	:= Space(GetSX3Cache("Z6_NUMPROJ","X3_TAMANHO"))
EndIf

oGet1:CtrlRefresh()

Return lRet


**************************************************************************
Static Function Efetiva(nRadio)
**************************************************************************

If nRadio == 1
	Inclui()
ElseIf nRadio == 2
	Consulta()
Else
	Copia()
EndIf

Return


**************************************************************************
Static Function Inclui(aProdsCop)
**************************************************************************

INCLUI	:= .T.
ALTERA	:= .T.

Tela(.T., aProdsCop)

Return


**************************************************************************
Static Function Consulta()
**************************************************************************

INCLUI	:= .F.
ALTERA	:= .F.

Tela(.F.)

Return


**************************************************************************
Static Function Copia()
**************************************************************************

Local aPergs	:= {}
Local aRet		:= {}
Local aProdsCop	:= {}

Local cQuery	:= ""
Local cTabCopia	:= Space(GetSX3Cache("DA0_CODTAB","X3_TAMANHO"))
Local cRefCopia	:= " "
Local cPrjCopia	:= ""
Local cAnoCopia	:= SubStr(DToS(dDataBase), 3, 2)
     
If upper(right(alltrim(cNumProj),1)) <> "A"
	alert("Só é permitido realizar copia da referência A")
	return
Endif              

aAdd( aPergs ,{1,"Tabela ......: ",cTabCopia,"@!",'.T.',"DA0",'.T.',40,.T.})
aAdd( aPergs ,{1,"Referência ..: ",cRefCopia,"@!",'.T.',,'.T.',40,.T.})
aAdd( aPergs ,{1,"Ano .........: ",cAnoCopia,"@!",'.T.',,'.T.',40,.T.})

If !Parambox ( aPergs, "Copiar projeção", aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTA551" + AllTrim(__cUserId) /* cLoad */, .F. /* lCanSave */, /* lUserSave */ )
	Return
EndIf

cTabCopia	:= MV_PAR01
cRefCopia	:= MV_PAR02
cAnoCopia	:= MV_PAR03

cPrjCopia	:= cNumProj
cNumProj	:= "1" + SubStr(cTabCopia, 2, 2) + cAnoCopia + cRefCopia
cCodTab     := cTabCopia
cRefTab     := cRefCopia

cQuery	:= " SELECT Z6_CODPROD, "
cQuery	+= "        MAX(ROUND(ROUND(DA1_PRCVEN * DECODE('"+cRefTab+"', "
cQuery	+= "                                            'A', "
cQuery	+= "                                            1.00, "
cQuery	+= "                                            'B', "
cQuery	+= "                                            1.05, "
cQuery	+= "                                            'C', "
cQuery	+= "                                            1.10, "
cQuery	+= "                                            'D', "
cQuery	+= "                                            1.15, "
cQuery	+= "                                            1.20), "
cQuery	+= "                        2) * (Z6_DESCPRO / 100 + 1), "
cQuery	+= "                  2)) AS PRECO "
cQuery	+= "   FROM "+RetSqlName("SZ6")+" SZ6, "+RetSqlName("DA1")+" DA1, "+RetSqlName("SB1")+" SB1, "+RetSqlName("SB5")+" SB5 "
cQuery	+= "  WHERE SZ6.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND DA1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SB1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SB5.D_E_L_E_T_(+) = ' ' "
cQuery	+= "    AND Z6_FILIAL = '"+xFilial("SZ6")+"' "
cQuery	+= "    AND DA1_FILIAL = '"+xFilial("DA1")+"' "
cQuery	+= "    AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery	+= "    AND B5_FILIAL(+) = '"+xFilial("SB5")+"' "
cQuery	+= "    AND Z6_NUMPROJ = '"+cPrjCopia+"' "
cQuery	+= "    AND DA1_CODTAB = '"+cCodTab+"' "
cQuery	+= "    AND DA1_CODPRO = Z6_CODPROD "
cQuery	+= "    AND B1_COD = Z6_CODPROD "
cQuery	+= "    AND B5_COD(+) = Z6_CODPROD "
cQuery	+= "    AND B1_XSEGMEN = '1' "
cQuery	+= "    AND B1_XCODBAS = '"+Space(GetSX3Cache("B1_COD", "X3_TAMANHO"))+"' "
cQuery	+= "    AND B1_XMODELO = '000011' "
//cQuery	+= "    AND Z6_DESCPRO <> 0 "
cQuery	+= "  GROUP BY Z6_CODPROD "
cQuery	+= "  ORDER BY 1 "
U_ORTQUERY(cQuery, "ORTA575_CP")
While ORTA575_CP->(!EOF())
	aAdd(aProdsCop, {PADR(ORTA575_CP->Z6_CODPROD, GetSX3Cache("B1_COD","X3_TAMANHO")), ORTA575_CP->PRECO})
	ORTA575_CP->(dbSkip())
EndDo
ORTA575_CP->(dbCloseArea())

If Empty(aProdsCop)
	MsgStop("Nenhum bloco industrial localizado na projeção '"+cPrjCopia+"'.")
	Return
EndIf

If !MsgYesNo("Os descontos e acréscimos aplicados na projeção '"+cPrjCopia+"' serão copiados para a projeção '"+cNumProj+"'. Prosseguir?")
	Return
EndIf

cQuery	:= " SELECT R_E_C_N_O_ AS ZREC "
cQuery	+= "   FROM " + RetSqlName("SZ6")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND Z6_FILIAL = '"+xFilial("SZ6")+"' "
cQuery	+= "    AND Z6_NUMPROJ = '"+cNumProj+"' "
U_ORTQUERY(cQuery, "ORTA575_C2")
While ORTA575_C2->(!EOF())
	SZ6->(dbGoTo(ORTA575_C2->ZREC))
	If SZ6->Z6_NUMPROJ == cNumProj
		RecLock("SZ6", .F.)
		SZ6->(dbDelete())
		MsUnLock()
	EndIf
	ORTA575_C2->(dbSkip())
EndDo
ORTA575_C2->(dbCloseArea())

Inclui(aProdsCop)

Return


**************************************************************************
Static Function Tela(lEdita, aProdsCop)
**************************************************************************

Local nOpc			:= 0

Private cProdPesq	:= Space(GetSX3Cache("B1_COD","X3_TAMANHO"))
Private dPerDe		:= CToD("  /  /  ")
Private dPerAte		:= CToD("  /  /  ")
Private aCoBrw1		:= {}
Private aHoBrw1		:= {}

Private nDQ			:= 0
Private nDF			:= 0
Private nDG			:= 0
Private lPulver		:= .T.
Private lEspecial	:= .T.
Private lSuperVert	:= .T.

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Declaração de Variaveis Private dos Objetos                             ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
SetPrvt("oFonteGrd","oDlg2","oSayProj","oBmp1","oBrw1","oGet2","oGet3","oGet4")
SetPrvt("oGet5","oSay4","oSay5","oSay6","oFonteGrd","oDlg2","oSayProj","oBmp1")
SetPrvt("oBrw1","oGet2","oGet3","oGet4","oGet5","oSay4","oSay5","oSay6","oSay7")
SetPrvt("oSay8","oSay9","oSay10","oSay11","oGet6","oGet7","oGet8","oCBox1","oCBox2","oCBox3")

If lEdita
	nOpc	:= GD_INSERT+GD_DELETE+GD_UPDATE
EndIf

dPerAte		:= FirstDay(dDataBase) - 1
dPerDe		:= FirstDay(FirstDay(FirstDay(dPerAte) - 1) - 1)

/*ÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ù±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
oFonteGrd  := TFont():New( "Arial",0,-17,,.T.,0,,700,.F.,.F.,,,,,, )
oDlg2      := MSDialog():New( 113,165,676,1113,"Mapa de Comercialização Industrial",,,.F.,,,,,,.T.,,,.T. )
oSayProj   := TSay():New( 012,028,{||"Consulta Projeção " + cNumProj },oDlg2,,oFonteGrd,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,108,008)
oBmp1      := TBitmap():New( 028,040,080,032,,"logorto3.jpg",.F.,oDlg2,,,.T.,.F.,,"",.T.,,.T.,,.F. )

@ 000, 144  TO 092, 145 OF oDlg2 COLOR 255,255,255  PIXEL

oSay5      := TSay():New( 008,152,{||"Tab.Preço"},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oSay6      := TSay():New( 020,152,{||"Referência"},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
oGet2      := TGet():New( 008,188,{|u| If(PCount()>0,cCodTab:=u,cCodTab)},oDlg2,028,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cCodTab",,)
oGet5      := TGet():New( 020,188,{|u| If(PCount()>0,cRefTab:=u,cRefTab)},oDlg2,028,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cRefTab",,)
oBtn4      := TButton():New( 032,188,"Marfil",oDlg2,{|| Processa({|| fCargaMarf(lEdita)},"Carregando comercialização...")},028,012,,,,.T.,,"",,,,.F. )

oSay7      := TSay():New( 052,152,{||"Desc. Quantitativo"},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)
oSay8      := TSay():New( 064,152,{||"Desc. Financeiro"},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
oSay9      := TSay():New( 076,152,{||"Desp. Gerais"},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,052,008)
oSay10     := TSay():New( 012,308,{||"Mapa de Comercialização"},oDlg2,,oFonteGrd,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,100,008)
oSay11     := TSay():New( 028,320,{||"I N D U S T R I A L"},oDlg2,,oFonteGrd,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,072,008)
oGet6      := TGet():New( 052,204,{|u| If(PCount()>0,nDQ:=u,nDQ)},oDlg2,028,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nDQ",,)
oGet7      := TGet():New( 064,204,{|u| If(PCount()>0,nDF:=u,nDF)},oDlg2,028,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nDF",,)
oGet8      := TGet():New( 076,204,{|u| If(PCount()>0,nDG:=u,nDG)},oDlg2,028,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nDG",,)
oCBox1     := TCheckBox():New( 052,256,"Pulverizado",{|u| If(PCount()>0,lPulver:=u,lPulver)},oDlg2,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, {|| .T.} )
oCBox2     := TCheckBox():New( 052,328,"Especial",{|u| If(PCount()>0,lEspecial:=u,lEspecial)},oDlg2,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, {|| .T.} )
oCBox3     := TCheckBox():New( 052,400,"Super Vertical",{|u| If(PCount()>0,lSuperVert:=u,lSuperVert)},oDlg2,048,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, {|| .T.} )

@ 092, 000  TO 093, 990 OF oDlg2 COLOR 255,255,255  PIXEL

Aadd(aHoBrw1,{ "Produto"		, "PRODUTO"		, "@!         "		, GetSX3Cache("B1_COD","X3_TAMANHO")	, 00, "U_ORTA575V()"	, "", "C", "SB1", "" } )
Aadd(aHoBrw1,{ "%(-)D/%(+)A"	, "VARIACAO"	, "@E 9,999.999999"	, 12									, 06, ""				, "", "N", ""	, "" } )
Aadd(aHoBrw1,{ "Descrição"		, "DESCRICAO"	, "@!         "		, GetSX3Cache("B1_COD","X3_TAMANHO") +	;
																	  GetSX3Cache("B1_XMED","X3_TAMANHO")+1	, 00, ""				, "", "C", ""	, "" } )
Aadd(aHoBrw1,{ "Preço Digitado"	, "PRECODIG"	, "@E 999,999.99"	, 10									, 02, "U_ORTA575P()"				, "", "N", ""	, "" } )
Aadd(aHoBrw1,{ "Preço Marfil"	, "MARFILVEND"	, "@E 999,999.99"	, 10									, 02, ""				, "", "N", ""	, "" } )
Aadd(aHoBrw1,{ "Custo"			, "MARFILCUST"	, "@E 999,999.99"	, 10									, 02, ""				, "", "N", ""	, "" } )
Aadd(aHoBrw1,{ "Mix"			, "MIX"			, "@E 999.99"		, 06									, 02, ""				, "", "N", ""	, "" } )
Aadd(aHoBrw1,{ "Peso"			, "PESO"		, "@E 999,999.9999"	, 12									, 04, ""				, "", "N", ""	, "" } )

Aadd(aCoBrw1,Array(Len(aHoBrw1)+1))
aCoBrw1[01,01] := Space(aHoBrw1[01,04])
aCoBrw1[01,02] := 0
aCoBrw1[01,03] := Space(aHoBrw1[03,04])
aCoBrw1[01,04] := 0
aCoBrw1[01,05] := 0
aCoBrw1[01,06] := 0
aCoBrw1[01,07] := 0
aCoBrw1[01,08] := 0
aCoBrw1[1][Len(aHoBrw1)+1] := .F.

oSay4      := TSay():New( 240,004,{||"Pesquisar Produto"},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)
oSay5      := TSay():New( 260,004,{||"Período"},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)
oSay6      := TSay():New( 260,108,{||"Até"},oDlg2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,012,008)
oBrw1      := MsNewGetDados():New(100,004,236,468,nOpc,'AllwaysTrue()','AllwaysTrue()','',{"PRODUTO","PRECODIG"},0,99,'AllwaysTrue()','','U_ORTA575D()',oDlg2,aHoBrw1,aCoBrw1 )
oGet2      := TGet():New( 240,056,{|u| If(PCount()>0,cProdPesq:=u,cProdPesq)},oDlg2,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SB1","cProdPesq",,)
oBtn1      := TButton():New( 240,120,"Pesquisar",oDlg2,{|| fPesqProd()},037,012,,,,.T.,,"",,,,.F. )
oGet4      := TGet():New( 260,056,{|u| If(PCount()>0,dPerDe:=u,dPerDe)},oDlg2,040,008,'@d',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dPerDe",,)
oGet5      := TGet():New( 260,124,{|u| If(PCount()>0,dPerAte:=u,dPerAte)},oDlg2,040,008,'@d',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dPerAte",,)
oBtn2      := TButton():New( 260,380,"Ok",oDlg2,{|| IIf(fOkTela(lEdita), oDlg2:End(), Nil), },037,012,,,,.T.,,"",,,,.F. )
oBtn3      := TButton():New( 260,424,"Cancelar",oDlg2,{|| oDlg2:End()},037,012,,,,.T.,,"",,,,.F. )

Processa({|| fCargaProj(aProdsCop)},"Carregando comercialização...")

oDlg2:Activate(,,,.T.)

Return




**************************************************************************
User Function ORTA575D()
**************************************************************************

Local nX	:= 0
Local lRet	:= .T.

If oBrw1:aCols[oBrw1:nAt,Len(aHoBrw1)+1]
	nX	:= AScan(oBrw1:aCols, {|x| AllTrim(x[1]) == AllTrim(SB1->B1_COD) .And. !x[Len(aHoBrw1)+1]})
	If nX > 0 .And. nX <> oBrw1:nAt
		lRet	:= .F.
		MsgStop("Não é permitido inserir registros duplicados na comercialização.")
	EndIf
EndIf

Return lRet




**************************************************************************
User Function ORTA575V()
**************************************************************************

Local nX		:= 0
Local nMarfVend	:= 0
Local nMarfCust	:= 0
Local nPeso		:= 0
Local lRet		:= .T.
Local cQuery	:= ""
Local cCodPro	:= &(ReadVar())

oBrw1:aCols[oBrw1:nAt,01] := Space(aHoBrw1[01,04])
oBrw1:aCols[oBrw1:nAt,02] := 0
oBrw1:aCols[oBrw1:nAt,03] := Space(aHoBrw1[03,04])
oBrw1:aCols[oBrw1:nAt,04] := 0
oBrw1:aCols[oBrw1:nAt,05] := 0
oBrw1:aCols[oBrw1:nAt,06] := 0
oBrw1:aCols[oBrw1:nAt,07] := 0

SB1->(dbOrderNickName("PSB11"))	//B1_FILIAL+B1_COD
If SB1->(!dbSeek(xFilial("SB1")+cCodPro))
	lRet	:= .F.
	MsgStop("Produto '"+AllTrim(cCodPro)+"' não localizado no sistema")
EndIf

If lRet
	nX	:= AScan(oBrw1:aCols, {|x| AllTrim(x[1]) == AllTrim(SB1->B1_COD) .And. !x[Len(aHoBrw1)+1]})
	If nX > 0 .And. nX <> oBrw1:nAt
		lRet	:= .F.
		MsgStop("Não é permitido inserir registros duplicados na comercialização.")
	EndIf
EndIf

If lRet .And. SB1->B1_XSEGMEN <> '1'
	lRet	:= .F.
	MsgStop("Só é permitido incluir produtos do segmento 1-Industrial. O produto '"+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+"' é do segmento '"+SB1->B1_XSEGMEN+"'")
EndIf

If lRet .And. !Empty(SB1->B1_XCODBAS)
	lRet	:= .F.
	MsgStop("Não é permitido incluir produtos sob-medida na comercialização industrial")
EndIf

If lRet .And. SB1->B1_XMODELO <> "000011"
	lRet	:= .F.
	MsgStop("Só é permitido incluir produtos do tipo BLOCO RETANGULAR, BLOCO CILINDRICO ou ESPUMA CONTÍNUA na comercialização industrual")
EndIf

If lRet
	cQuery	:= " SELECT ROUND(B1_XQTDEMB / NVL(B5_DENSID, B1_XQTDEMB), 4) AS PESO "
	cQuery	+= "   FROM "+RetSqlName("SB1")+" SB1, "+RetSqlName("SB5")+" SB5 "
	cQuery	+= "  WHERE SB1.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SB5.D_E_L_E_T_(+) = ' ' "
	cQuery	+= "    AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery	+= "    AND B5_FILIAL(+) = '"+xFilial("SB5")+"' "
	cQuery	+= "    AND B1_COD = '"+SB1->B1_COD+"' "
	cQuery	+= "    AND B5_COD(+) = B1_COD "
	U_ORTQUERY(cQuery, "ORTA575VQP")
	nPeso	:= 0
	If ORTA575VQP->(!EOF())
		nPeso	:= ORTA575VQP->PESO
	EndIf
	ORTA575VQP->(dbCloseArea())
	
	If nPeso <= 0
		lRet	:= .F.
		MsgStop("O produto '"+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+"' está sem peso cadastrado")
	EndIf
EndIf

If lRet .And. SB1->B1_XFORLIN >= dDataBase + 90 .And. !MsgYesNo("Atenção: O produto '"+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+"' está fora de linha. Deseja inseri-lo na comercialização?")
	lRet	:= .F.
EndIf

If lRet
	cQuery	:= " SELECT DA1_PRCVEN, DA1_XCUSTO "
	cQuery	+= "   FROM " + RetSqlName("DA1")
	cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND DA1_FILIAL = '"+xFilial("DA1")+"' "
	cQuery	+= "    AND DA1_CODTAB = '"+cCodTab+"' "
	cQuery	+= "    AND DA1_CODPRO = '"+SB1->B1_COD+"' "
	U_ORTQUERY(cQuery, "ORTA575VQ1")
	nMarfVend	:= 0
	nMarfCust	:= 0
	If ORTA575VQ1->(!EOF())
		nMarfVend	:= ORTA575VQ1->DA1_PRCVEN
		nMarfCust	:= ORTA575VQ1->DA1_XCUSTO
	EndIf
	ORTA575VQ1->(dbCloseArea())
	
	If Empty(nMarfVend) .Or. Empty(nMarfCust)
		lRet	:= .F.
		MsgStop("O produto '"+AllTrim(SB1->B1_COD)+"-"+AllTrim(SB1->B1_DESC)+"' deve possuir preço e custo marfil para que possa ser inserido na comercialização industrial")
	EndIf
EndIf

If lRet
	If cRefTab == "A"
		nMarfVend	:= Round(nMarfVend * 1.00, 2)
//		nMarfCust	:= Round(nMarfCust * 1.00, 2)
	ElseIf cRefTab == "B"
		nMarfVend	:= Round(nMarfVend * 1.05, 2)
//		nMarfCust	:= Round(nMarfCust * 1.05, 2)
	ElseIf cRefTab == "C"
		nMarfVend	:= Round(nMarfVend * 1.10, 2)
//		nMarfCust	:= Round(nMarfCust * 1.10, 2)
	ElseIf cRefTab == "D"
		nMarfVend	:= Round(nMarfVend * 1.15, 2)
//		nMarfCust	:= Round(nMarfCust * 1.15, 2)
	Else
		nMarfVend	:= Round(nMarfVend * 1.20, 2)
//		nMarfCust	:= Round(nMarfCust * 1.20, 2)
	EndIf
	
	oBrw1:aCols[oBrw1:nAt, 03]	:= PADR(AllTrim(SB1->B1_DESC) + " " + AllTrim(SB1->B1_XMED), aHoBrw1[03,04])
	
	oBrw1:aCols[oBrw1:nAt, 04]	:= nMarfVend
	oBrw1:aCols[oBrw1:nAt, 05]	:= nMarfVend
	oBrw1:aCols[oBrw1:nAt, 06]	:= nMarfCust
	
	AtuVar()
EndIf

dbSelectArea("SB1")

Return lRet


**************************************************************************
User Function ORTA575P()
**************************************************************************

Local nMarfil	:= 0
Local nCusto	:= 0
Local lRet		:= .T.
Local nValDig	:= &(ReadVar())
Local nLimite	:= 0.1
nMarfil	:= oBrw1:aCols[oBrw1:nAt, 05]
nCusto	:= oBrw1:aCols[oBrw1:nAt, 06]
           
if cEmpAnt == "18"
	nLimite	:= 0.2
endif

If nValDig <= 0
	lRet	:= .F.
	MsgStop("O preço digitado deve ser positivo")
ElseIf Round( (nValDig - nMarfil) / nMarfil, 6) > nLimite
	lRet	:= .F.
	MsgStop("Não é permitido inserir um acréscimo maior que 10% [Produto: " + oBrw1:aCols[oBrw1:nAt, 01] +"]")
EndIf

If lRet
	AtuVar(nValDig)
EndIf

dbSelectArea("SB1")

Return lRet


**************************************************************************
Static Function AtuVar(nValDig)
**************************************************************************

Local nMarfil	:= 0
Local nCusto	:= 0
Local nPrcDig	:= 0

nPrcDig	:= IIf(Empty(nValDig), oBrw1:aCols[oBrw1:nAt, 04], nValDig)
nMarfil	:= oBrw1:aCols[oBrw1:nAt, 05]
nCusto	:= oBrw1:aCols[oBrw1:nAt, 06]

oBrw1:aCols[oBrw1:nAt, 02]	:= Round(100 * (nPrcDig - nMarfil) / nMarfil, 6)
oBrw1:aCols[oBrw1:nAt, 07]	:= Round(100 * (nPrcDig - nCusto) / nPrcDig, 2)

Return


**************************************************************************
Static Function fPesqProd()
**************************************************************************

Local nX	:= 0

If Empty(cProdPesq)
	Return
EndIf

For nX := 1 To Len(oBrw1:aCols)
	If oBrw1:aCols[nX,01] == cProdPesq
		oBrw1:GoTo(nX)
		oBrw1:Refresh()
		Return
	EndIf
Next nX

MsgAlert("Produto '"+AllTrim(cProdPesq)+"' não localizado")

Return


**************************************************************************
Static Function fCargaMarf(lEdita)
**************************************************************************

Local nX		:= 0
Local cQuery	:= ""
Local aTabTmp	:= {}

If !lEdita .Or. !MsgYesNo("Atenção: Todos os preços serão sobrescritos pelo valor Marfil. Prosseguir?")
	Return
EndIf

cQuery	:= " SELECT B1_COD "
cQuery	+= "   FROM "+RetSqlName("DA1")+" DA1, "
cQuery	+= "        "+RetSqlName("SBM")+" SBM, "
cQuery	+= "        "+RetSqlName("SB1")+" SB1, "
cQuery	+= "        "+RetSqlName("SB5")+" SB5, "
cQuery	+= "        "+RetSqlName("SX5")+" SX5, "
cQuery	+= "        "+RetSqlName("DA0")+" DA0 "
cQuery	+= "  WHERE DA1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SB1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SB5.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SBM.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SX5.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND DA0.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery	+= "    AND B5_FILIAL = '"+xFilial("SB5")+"' "
cQuery	+= "    AND BM_FILIAL = '"+xFilial("SBM")+"' "
cQuery	+= "    AND DA1_FILIAL = '"+xFilial("DA1")+"' "
cQuery	+= "    AND DA1_FILIAL = '"+xFilial("DA0")+"' "
cQuery	+= "    AND X5_FILIAL = '"+xFilial("SX5")+"' "
cQuery	+= "    AND B1_COD = DA1_CODPRO "
cQuery	+= "    AND B1_COD = B5_COD "
cQuery	+= "    AND B1_GRUPO = BM_GRUPO "
cQuery	+= "    AND X5_TABELA = 'ZA' "
cQuery	+= "    AND BM_XSUBGRU = X5_CHAVE "
cQuery	+= "    AND (B1_XFORLIN = '        ' OR B1_XFORLIN > '"+DToS(dDataBase-90)+"') "
cQuery	+= "    AND B1_XSEGMEN = '1' "
cQuery	+= "    AND DA0_CODTAB = '"+cCodTab+"' "
cQuery	+= "    AND DA1_CODTAB = DA0_CODTAB "
cQuery	+= "    AND B1_XTABUN IN ('S', 'U') "
cQuery	+= "    AND B1_XCODBAS = '               ' "
cQuery	+= "    AND BM_XSUBGRU IN ('20001I', '20002I', '20009I') "
cQuery	+= "  GROUP BY B1_COD "
cQuery	+= "  ORDER BY B1_COD "
U_ORTQUERY(cQuery, "ORTA575_AL")
oBrw1:SetArray(aTabTmp, .T.)
While ORTA575_AL->(!EOF())
	M->PRODUTO	:= PADR(ORTA575_AL->B1_COD, GetSX3Cache("B1_COD","X3_TAMANHO"))
	__ReadVar	:= "M->PRODUTO"
	
	Aadd(oBrw1:aCols,Array(Len(aHoBrw1)+1))
	nX	:= Len(oBrw1:aCols)
	
	oBrw1:aCols[nX,01] := PADR(ORTA575_AL->B1_COD, GetSX3Cache("B1_COD","X3_TAMANHO"))
	oBrw1:aCols[nX,02] := 0
	oBrw1:aCols[nX,03] := Space(aHoBrw1[03,04])
	oBrw1:aCols[nX,04] := 0
	oBrw1:aCols[nX,05] := 0
	oBrw1:aCols[nX,06] := 0
	oBrw1:aCols[nX,07] := 0
	oBrw1:aCols[nX,Len(aHoBrw1)+1] := .F.
	
	oBrw1:GoTo(nX)
	&(aHoBrw1[01,06])
	
	oBrw1:aCols[nX,01] := PADR(ORTA575_AL->B1_COD, GetSX3Cache("B1_COD","X3_TAMANHO"))
	
	ORTA575_AL->(dbSkip())
EndDo
ORTA575_AL->(dbCloseArea())

oBrw1:GoTop()
oBrw1:Refresh()

Return


**************************************************************************
Static Function fOkTela(lEdita)
**************************************************************************

If !(lPulver .Or. lEspecial .Or. lSuperVert)
	MsgStop("É obrigatório escolher pelo menos um tipo de cliente (Pulverizado / Especial / Super Vertical")
	Return .F.
EndIf

If lEdita .And. MsgYesNo("Deseja salvar a comercialização?")
	Processa({|| fGravaCom()},"Gravando comercialização...")
EndIf

If MsgYesNo("Deseja emitir o relatório de comercialização?")
	RelComerc()
EndIf

Return .T.


**************************************************************************
Static Function fGravaCom()
**************************************************************************

Local cQuery	:= ""
Local nX		:= 0

Local z6FILIAL  := xFilial("SZ6")
Local z6DTGERA  := dDataBase
Local z6HRGERA  := Time()
Local z6CDUSUA  := RetCodUsr()
Local z6DTEMII  := dPerDe
Local z6DTEMIF  := dPerAte
Local z6VENDI   := PADR("", GetSX3Cache("Z6_VENDI", "X3_TAMANHO"), " ")
Local z6VENDF   := PADR("", GetSX3Cache("Z6_VENDF", "X3_TAMANHO"), "Z")
Local z6LINHAI  := PADR("", GetSX3Cache("Z6_LINHAI", "X3_TAMANHO"), " ")
Local z6LINHAF  := PADR("", GetSX3Cache("Z6_LINHAF", "X3_TAMANHO"), "Z")
Local z6UFINI   := PADR("", GetSX3Cache("Z6_UFINI", "X3_TAMANHO"), " ")
Local z6UFFIM   := PADR("", GetSX3Cache("Z6_UFFIM", "X3_TAMANHO"), "Z")
Local z6CIDINI  := PADR("", GetSX3Cache("Z6_CIDINI", "X3_TAMANHO"), " ")
Local z6CIDFIM  := PADR("", GetSX3Cache("Z6_CIDFIM", "X3_TAMANHO"), "Z")
Local z6CLIINI  := PADR("", GetSX3Cache("Z6_CLIINI", "X3_TAMANHO"), " ")
Local z6CLIFIM  := PADR("", GetSX3Cache("Z6_CLIFIM", "X3_TAMANHO"), "Z")
Local z6PARCEI  := PADR("", GetSX3Cache("Z6_PARCEI", "X3_TAMANHO"), " ")
Local z6PARCEF  := PADR("", GetSX3Cache("Z6_PARCEF", "X3_TAMANHO"), "Z")
Local z6DTPROJ  := dDataBase
Local z6CODPROD := Space(GetSX3Cache("Z6_CODPROD", "X3_TAMANHO"))

cQuery	:= " SELECT R_E_C_N_O_ AS RECNUM "
cQuery	+= "   FROM " + RetSqlName("SZ6")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND Z6_FILIAL = '"+xFilial("SZ6")+"' "
cQuery	+= "    AND Z6_NUMPROJ = '"+cNumProj+"' "
U_ORTQUERY(cQuery, "ORTA575_DL")
While ORTA575_DL->(!EOF())
	SZ6->(dbGoTo(ORTA575_DL->RECNUM))
	If SZ6->(Recno()) == ORTA575_DL->RECNUM
		RecLock("SZ6", .F.)
		SZ6->(dbDelete())
		MsUnLock()
	EndIf
	ORTA575_DL->(dbSkip())
EndDo
ORTA575_DL->(dbCloseArea())

RecLock("SZ6", .T.)
SZ6->Z6_FILIAL  := z6FILIAL
SZ6->Z6_DTGERA  := z6DTGERA
SZ6->Z6_HRGERA  := z6HRGERA
SZ6->Z6_CDUSUA  := z6CDUSUA
SZ6->Z6_DTEMII  := z6DTEMII
SZ6->Z6_DTEMIF  := z6DTEMIF
SZ6->Z6_VENDI   := z6VENDI
SZ6->Z6_VENDF   := z6VENDF
SZ6->Z6_LINHAI  := z6LINHAI
SZ6->Z6_LINHAF  := z6LINHAF
SZ6->Z6_UFINI   := z6UFINI
SZ6->Z6_UFFIM   := z6UFFIM
SZ6->Z6_CIDINI  := z6CIDINI
SZ6->Z6_CIDFIM  := z6CIDFIM
SZ6->Z6_CLIINI  := z6CLIINI
SZ6->Z6_CLIFIM  := z6CLIFIM
SZ6->Z6_PARCEI  := z6PARCEI
SZ6->Z6_PARCEF  := z6PARCEF
SZ6->Z6_DTPROJ  := z6DTPROJ
SZ6->Z6_PROJPR  := '1'
SZ6->Z6_TABVEN  := cCodTab
SZ6->Z6_REFTAB  := cRefTab
SZ6->Z6_NUMPROJ := cNumProj
SZ6->Z6_CODPROD := z6CODPROD
SZ6->Z6_DESCPRO := 0
SZ6->Z6_PRCDIG  := 0
SZ6->Z6_PRCDA1  := 0
SZ6->Z6_SEGMENT := "15"
SZ6->Z6_CUSTO   := 0
SZ6->Z6_MIX     := 0
MsUnLock()

ProcRegua(Len(oBrw1:aCols))

For nX := 1 To Len(oBrw1:aCols)
	IncProc()
	
	If oBrw1:aCols[nX,Len(aHoBrw1)+1]
		Loop
	EndIf
	
	If Empty(oBrw1:aCols[nX,01])
		Loop
	EndIf
	
	if type("INCLUI") == "L"
		if !INCLUI
			If Empty(oBrw1:aCols[nX,02])
				Loop
			EndIf
		endif
	endif	
	
	RecLock("SZ6", .T.)
	SZ6->Z6_FILIAL  := z6FILIAL
	SZ6->Z6_DTGERA  := z6DTGERA
	SZ6->Z6_HRGERA  := z6HRGERA
	SZ6->Z6_CDUSUA  := z6CDUSUA
	SZ6->Z6_DTEMII  := z6DTEMII
	SZ6->Z6_DTEMIF  := z6DTEMIF
	SZ6->Z6_VENDI   := z6VENDI
	SZ6->Z6_VENDF   := z6VENDF
	SZ6->Z6_LINHAI  := z6LINHAI
	SZ6->Z6_LINHAF  := z6LINHAF
	SZ6->Z6_UFINI   := z6UFINI
	SZ6->Z6_UFFIM   := z6UFFIM
	SZ6->Z6_CIDINI  := z6CIDINI
	SZ6->Z6_CIDFIM  := z6CIDFIM
	SZ6->Z6_CLIINI  := z6CLIINI
	SZ6->Z6_CLIFIM  := z6CLIFIM
	SZ6->Z6_PARCEI  := z6PARCEI
	SZ6->Z6_PARCEF  := z6PARCEF
	SZ6->Z6_DTPROJ  := z6DTPROJ
	SZ6->Z6_PROJPR  := '1'
	SZ6->Z6_TABVEN  := cCodTab
	SZ6->Z6_REFTAB  := cRefTab
	SZ6->Z6_NUMPROJ := cNumProj
	SZ6->Z6_CODPROD := oBrw1:aCols[nX,01]
	SZ6->Z6_DESCPRO := oBrw1:aCols[nX,02]
	SZ6->Z6_PRCDIG  := oBrw1:aCols[nX,04]
	SZ6->Z6_PRCDA1  := oBrw1:aCols[nX,05]
	SZ6->Z6_SEGMENT := "15"
	SZ6->Z6_CUSTO   := oBrw1:aCols[nX,06]
	SZ6->Z6_MIX     := oBrw1:aCols[nX,07]
	MsUnLock()
Next nX

MsgInfo("Projeção '"+cNumProj+"' gravada com sucesso")

Return


**************************************************************************
Static Function fCargaProj(aProdsCop)
**************************************************************************

Local nX		:= 0
Local nY		:= 0
Local cQuery	:= ""
Local aTabTmp	:= {}

If Empty(aProdsCop)
	aProdsCop	:= {}

	cQuery	:= " SELECT Z6_CODPROD, Z6_PRCDIG "
	cQuery	+= "   FROM "+RetSqlName("SZ6")+" SZ6, "+RetSqlName("SB1")+" SB1 "
	cQuery	+= "  WHERE SZ6.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SB1.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND Z6_FILIAL = '"+xFilial("SZ6")+"' "
	cQuery	+= "    AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery	+= "    AND Z6_NUMPROJ = '"+cNumProj+"' "
	cQuery	+= "    AND B1_COD = Z6_CODPROD "
	cQuery	+= "  ORDER BY 1 "
	U_ORTQUERY(cQuery, "ORTA575_CR")
	While ORTA575_CR->(!EOF())
		aAdd(aProdsCop, {PADR(ORTA575_CR->Z6_CODPROD, GetSX3Cache("B1_COD","X3_TAMANHO")), ORTA575_CR->Z6_PRCDIG})
		ORTA575_CR->(dbSkip())
	EndDo
	ORTA575_CR->(dbCloseArea())
EndIf

If !Empty(aProdsCop)
	oBrw1:SetArray(aTabTmp, .T.)
EndIf

For nX := 1 To Len(aProdsCop)
	M->PRODUTO	:= aProdsCop[nX,01]
	__ReadVar	:= "M->PRODUTO"
	
	Aadd(oBrw1:aCols,Array(Len(aHoBrw1)+1))
	nY	:= Len(oBrw1:aCols)
	
	oBrw1:aCols[nY,01] := aProdsCop[nX,01]
	oBrw1:aCols[nY,02] := 0
	oBrw1:aCols[nY,03] := Space(aHoBrw1[03,04])
	oBrw1:aCols[nY,04] := 0
	oBrw1:aCols[nY,05] := 0
	oBrw1:aCols[nY,06] := 0
	oBrw1:aCols[nY,07] := 0
	oBrw1:aCols[nY,Len(aHoBrw1)+1] := .F.
	
	oBrw1:GoTo(nY)
	&(aHoBrw1[01,06])
	
	oBrw1:aCols[nY,01] := aProdsCop[nX,01]
	
	M->PRECODIG	:= aProdsCop[nX,02]
	__ReadVar	:= "M->PRECODIG"
	oBrw1:aCols[nY,04] := aProdsCop[nX,02]
	U_ORTA575P()
	oBrw1:aCols[nY,04] := aProdsCop[nX,02]
Next nX

oBrw1:GoTop()
oBrw1:Refresh()

Return


**************************************************************************
Static Function RelComerc()
**************************************************************************

Private nPag	:= 0
Private nEsp	:= 50
Private nLin	:= 9999
Private cTitulo	:= "MAPA DE COMERCIALIZAÇÃO INDUSTRIAL"
Private Cabec1	:= ""
Private Cabec2	:= ""
Private oPrn	:= Nil
Private oFont1	:= Nil
Private oFont2	:= Nil

oFont1	:= TFont():New("Courier New",,11,,.T.)
oFont2	:= TFont():New("Courier New",,11,,.F.)
oPrn	:= TReport():New("ORTA575",cTitulo,,{|x| GeraRel(x)},cTitulo)

oPrn:HideHeader()
oPrn:HideFooter()
oPrn:SetLandscape()
oPrn:SetEdit(.F.)
oPrn:NoUserFilter()
oPrn:DisableOrietation()
oPrn:PrintDialog()

Return


**************************************************************************
Static Function GeraRel()
**************************************************************************

Local cQuery	:= ""
Local cDesAcr	:= ""
Local nX		:= 0

Local nPecasB	:= 0
Local nPecasL	:= 0
Local nPecasP	:= 0
Local nPecasE	:= 0
Local nPecasT	:= 0

Local nLarg1Kg	:= 0

Local nMarfilB	:= 0
Local nMarfilBT	:= 0
Local nPesoB	:= 0
Local nCustoB	:= 0
Local nMarkB	:= 0
Local nPrcComerB:= 0
Local nValDGB	:= 0
Local nLucroB	:= 0
Local nLucroTB	:= 0
Local nPercLucrB:= 0
Local nMkupComB	:= 0
Local nRentB	:= 0

Local nMarfilL	:= 0
Local nPesoL	:= 0
Local nCustoL	:= 0
Local nMarkL	:= 0
Local nPrcComerL:= 0
Local nValDGL	:= 0
Local nLucroL	:= 0
Local nLucroTL	:= 0
Local nPercLucrL:= 0
Local nMkupComL	:= 0
Local nRentL	:= 0

Local nMarfilP	:= 0
Local nPesoP	:= 0
Local nCustoP	:= 0
Local nMarkP	:= 0
Local nPrcComerP:= 0
Local nValDGP	:= 0
Local nLucroP	:= 0
Local nLucroTP	:= 0
Local nPercLucrP:= 0
Local nMkupComP	:= 0
Local nRentP	:= 0

Local nMarfilE	:= 0
Local nPesoE	:= 0
Local nCustoE	:= 0
Local nMarkE	:= 0
Local nPrcComerE:= 0
Local nValDGE	:= 0
Local nLucroE	:= 0
Local nLucroTE	:= 0
Local nPercLucrE:= 0
Local nMkupComE	:= 0
Local nRentE	:= 0

Local nLucroTT	:= 0
Local nMkupComT	:= 0
Local nRentT	:= 0
Local nPrcComerT:= 0
Local nCustoT	:= 0

Local aImprime	:= {}

cQuery	:= " SELECT BM_XSUBGRU, "
cQuery	+= "        B1_COD, "
cQuery	+= "        B1_DESC, "
cQuery	+= "        DA1_PRCVEN, "
cQuery	+= "        DA1_XCUSTO, "
cQuery	+= "        B1_XQTDEMB, "
cQuery	+= "        NVL(B5_DENSID, 0) AS B5_DENSID, "
cQuery	+= "        NVL(Z6_DESCPRO, 0) AS Z6_DESCPRO "
cQuery	+= "   FROM "+RetSqlName("DA1")+" DA1, "
cQuery	+= "        "+RetSqlName("SBM")+" SBM, "
cQuery	+= "        "+RetSqlName("SB1")+" SB1, "
cQuery	+= "        "+RetSqlName("SB5")+" SB5, "
cQuery	+= "        "+RetSqlName("SZ6")+" SZ6 "
cQuery	+= "  WHERE DA1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SB1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SB5.D_E_L_E_T_(+) = ' ' "
cQuery	+= "    AND SBM.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SZ6.D_E_L_E_T_(+) = ' ' "
cQuery	+= "    AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery	+= "    AND B5_FILIAL(+) = '"+xFilial("SB5")+"' "
cQuery	+= "    AND BM_FILIAL = '"+xFilial("SBM")+"' "
cQuery	+= "    AND DA1_FILIAL = '"+xFilial("DA1")+"' "
cQuery	+= "    AND Z6_FILIAL(+) = '"+xFilial("SZ6")+"' "
cQuery	+= "    AND B1_COD = DA1_CODPRO "
cQuery	+= "    AND B1_COD = B5_COD "
cQuery	+= "    AND B1_GRUPO = BM_GRUPO "
cQuery	+= "    AND (B1_XFORLIN = '        ' OR B1_XFORLIN > '"+DToS(dDataBase-90)+"') "
cQuery	+= "    AND B1_XSEGMEN = '1' "
cQuery	+= "    AND DA1_CODTAB = '"+cCodTab+"' "
cQuery	+= "    AND B1_XTABUN IN ('S', 'U') "
cQuery	+= "    AND B1_XCODBAS = '"+Space(GetSX3Cache("B1_COD","X3_TAMANHO"))+"' "
cQuery	+= "    AND BM_XSUBGRU IN ('20002I', '20001I', '20009I') "
cQuery	+= "    AND Z6_NUMPROJ(+) = '"+cNumProj+"' "
cQuery	+= "    AND Z6_CODPROD(+) = DA1_CODPRO "
cQuery	+= "  ORDER BY BM_XSUBGRU, B1_COD "
U_ORTQUERY(cQuery, "ORTA575_R1")
fCabec()
While ORTA575_R1->(!EOF())
	fQtdVen(PADR(ORTA575_R1->B1_COD, GetSX3Cache("B1_COD","X3_TAMANHO")), @nPecasB, @nPecasL, @nPecasP, @nPecasE)
	nPecasB		:= Round(nPecasB, 0)
	nPecasL		:= Round(nPecasL, 0)
	nPecasP		:= Round(nPecasP, 0)
	nPecasE		:= Round(nPecasE, 0)
	
	nMarfilB	:= ORTA575_R1->DA1_PRCVEN
	If cRefTab == "A" ; nMarfilB	:= Round(nMarfilB * 1.00, 2)
		ElseIf cRefTab == "B" ; nMarfilB	:= Round(nMarfilB * 1.05, 2)
		ElseIf cRefTab == "C" ; nMarfilB	:= Round(nMarfilB * 1.10, 2)
		ElseIf cRefTab == "D" ; nMarfilB	:= Round(nMarfilB * 1.15, 2)
		Else ; nMarfilB	:= Round(nMarfilB * 1.20, 2)
	EndIf
	nPesoB		:= Round(ORTA575_R1->B1_XQTDEMB / ORTA575_R1->B5_DENSID, 4)
	nMarfilBT	:= Round(nMarfilB, 2)
	nCustoB		:= Round(ORTA575_R1->DA1_XCUSTO, 2)
	nMarkB		:= Round(nMarfilB / nCustoB, 2)
	nPrcComerB	:= Round(;
					((100 - nDQ) / 100) * ;
					((100 - nDF) / 100) * ;
					((100 + ORTA575_R1->Z6_DESCPRO) / 100) * ;
					nMarfilB ;
				, 2)
	nValDGB		:= Round(nPrcComerB * nDG / 100, 2)
	nLucroB		:= nPrcComerB - nCustoB - nValDGB
	nLucroTB	:= nLucroB * nPecasB
	nPercLucrB	:= Round(100 * nLucroB / nPrcComerB, 2)
	nMkupComB	:= Round(nPrcComerB / nCustoB, 2)
	nRentB		:= Round(100 * (nPrcComerB - nCustoB) / nPrcComerB, 2)
	
	nLarg1Kg	:= Round(1 / (nPesoB * 1.9 * 0.01), 4)
	
	nCustoL		:= U_RoundUp(U_RoundUp(U_RoundUp(nCustoB * nPesoB, 2) * 1.08, 2) * nLarg1Kg * 1.9 * 0.01, 2)
	nMarkL		:= nMarkB
	nMarfilL	:= Round(nCustoL * nMarkL, 2)
	nPesoL		:= 1
	nPrcComerL	:= Round(;
					((100 - nDQ) / 100) * ;
					((100 - nDF) / 100) * ;
					((100 + ORTA575_R1->Z6_DESCPRO) / 100) * ;
					nMarfilL ;
				, 2)
	nValDGL		:= Round(nPrcComerL * nDG / 100, 2)
	nLucroL		:= nPrcComerL - nCustoL - nValDGL
	nLucroTL	:= nLucroL * nPecasL
	nPercLucrL	:= Round(100 * nLucroL / nPrcComerL, 2)
	nMkupComL	:= Round(nPrcComerL / nCustoL, 2)
	nRentL		:= Round(100 * (nPrcComerL - nCustoL) / nPrcComerL, 2)
	
	nCustoP		:= U_RoundUp(U_RoundUp(U_RoundUp(nCustoB * nPesoB, 2) * 1.10, 2) * nLarg1Kg * 1.9 * 0.01, 2)
	nMarkP		:= nMarkB
	nMarfilP	:= Round(nCustoP * nMarkP, 2)
	nPesoP		:= 1
	nPrcComerP	:= Round(;
					((100 - nDQ) / 100) * ;
					((100 - nDF) / 100) * ;
					((100 + ORTA575_R1->Z6_DESCPRO) / 100) * ;
					nMarfilP ;
				, 2)
	nValDGP		:= Round(nPrcComerP * nDG / 100, 2)
	nLucroP		:= nPrcComerP - nCustoP - nValDGP
	nLucroTP	:= nLucroP * nPecasP
	nPercLucrP	:= Round(100 * nLucroP / nPrcComerP, 2)
	nMkupComP	:= Round(nPrcComerP / nCustoP, 2)
	nRentP		:= Round(100 * (nPrcComerP - nCustoP) / nPrcComerP, 2)
	
	nCustoE		:= U_RoundUp(U_RoundUp(U_RoundUp(nCustoB * nPesoB, 2) * 1.17, 2) * nLarg1Kg * 1.9 * 0.01, 2)
	nMarkE		:= nMarkB
	nMarfilE	:= Round(nCustoE * nMarkE, 2)
	nPesoE		:= 1
	nPrcComerE	:= Round(;
					((100 - nDQ) / 100) * ;
					((100 - nDF) / 100) * ;
					((100 + ORTA575_R1->Z6_DESCPRO) / 100) * ;
					nMarfilE ;
				, 2)
	nValDGE		:= Round(nPrcComerE * nDG / 100, 2)
	nLucroE		:= nPrcComerE - nCustoE - nValDGE
	nLucroTP	:= nLucroE * nPecasP
	nPercLucrE	:= Round(100 * nLucroE / nPrcComerE, 2)
	nMkupComE	:= Round(nPrcComerE / nCustoE, 2)
	nRentE		:= Round(100 * (nPrcComerE - nCustoE) / nPrcComerE, 2)
	
	nPecasT		+= nPecasB + nPecasL + nPecasP + nPecasE
	nLucroTT	+= nLucroTB + nLucroTL + nLucroTP + nLucroTE
	nCustoT		+= nCustoB * nPecasB + nCustoL * nPecasL + nCustoP * nPecasP + nCustoE * nPecasE
	nPrcComerT	+= nPrcComerB * nPecasB + nPrcComerL * nPecasL + nPrcComerP * nPecasP + nPrcComerE * nPecasE
	
	aAdd(aImprime, {;
		PADR(AllTrim(ORTA575_R1->B1_COD)+"-"+AllTrim(ORTA575_R1->B1_DESC), 26),;
		nMarfilBT,;
		nPesoB,;
		nMarfilB,;
		nMarkB,;
		nDQ,;
		nDF,;
		nPecasB,;
		ORTA575_R1->Z6_DESCPRO,;
		nPrcComerB,;
		nCustoB,;
		nValDGB,;
		nLucroB,;
		nLucroTB,;
		nPercLucrB,;
		nMkupComB,;
		nRentB,;
		0;
	})
	
	aAdd(aImprime, {;
		Space(10)+"-LAMINADO",;
		Space(11),;
		nPesoL,;
		nMarfilL,;
		nMarkL,;
		nDQ,;
		nDF,;
		nPecasL,;
		ORTA575_R1->Z6_DESCPRO,;
		nPrcComerL,;
		nCustoL,;
		nValDGL,;
		nLucroL,;
		nLucroTL,;
		nPercLucrL,;
		nMkupComL,;
		nRentL,;
		0;
	})
	
	aAdd(aImprime, {;
		Space(10)+"-PERFILADO",;
		Space(11),;
		nPesoP,;
		nMarfilP,;
		nMarkP,;
		nDQ,;
		nDF,;
		nPecasP,;
		ORTA575_R1->Z6_DESCPRO,;
		nPrcComerP,;
		nCustoP,;
		nValDGP,;
		nLucroP,;
		nLucroTP,;
		nPercLucrP,;
		nMkupComP,;
		nRentP,;
		0;
	})
	
	aAdd(aImprime, {;
		Space(10)+"-PEÇA",;
		Space(11),;
		nPesoE,;
		nMarfilE,;
		nMarkE,;
		nDQ,;
		nDF,;
		nPecasE,;
		ORTA575_R1->Z6_DESCPRO,;
		nPrcComerE,;
		nCustoE,;
		nValDGE,;
		nLucroE,;
		nLucroTE,;
		nPercLucrE,;
		nMkupComE,;
		nRentE,;
		0;
	})
	
	ORTA575_R1->(dbSkip())
EndDo
ORTA575_R1->(dbCloseArea())

For nX := 1 To Len(aImprime)
	If nLin > 2300
		fCabec()
	EndIf
	
	If aImprime[nX,09] == 0
		cDesAcr	:= "  "
	ElseIf aImprime[nX,09] < 0
		cDesAcr	:= "D "
	Else
		cDesAcr	:= "A+"
	EndIf
	
	nColRel	:= 10
	nColDif	:= 20*(26+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,PADR(aImprime[nX,01], 26),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(09+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	If SubStr(aImprime[nX,01], 1, 1) == " "
		oPrn:Say(nLin,nColRel+10,Space(09),oFont1)
	Else
		oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,02],"@E 99,999.99"),oFont1)
	EndIf
	nColRel+=nColDif
	nColDif	:= 20*(10+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,03], "@E 9,999.9999"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(09+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,04], "@E 99,999.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(05+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,05], "@E 99.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(02+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,06], "@E 99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(02+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,07], "@E 99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(07+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,08], "@E 999,999"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(08+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,cDesAcr + Transform(aImprime[nX,09], "@E 999.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(10+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,10], "@E 999,999.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(09+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,11], "@E 99,999.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(06+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,12], "@E 999.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(06+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,13], "@E 999.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(14+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,14], "@E 999,999,999.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(06+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,15], "@E 999.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(05+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,16], "@E 99.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(06+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(aImprime[nX,17], "@E 999.99"),oFont1)
	nColRel+=nColDif
	nColDif	:= 20*(05+01)
	oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
	oPrn:Say(nLin,nColRel+10,Transform(100 * (aImprime[nX,08] * aImprime[nX,10]) / nPrcComerT, "@E 99.99"),oFont1)
	nColRel+=nColDif
	nLin += nEsp
	
	If aImprime[nX,01] == Space(10)+"-PEÇA"
		If nLin > 2300
			fCabec()
		EndIf
		oPrn:Box(nLin,0010,nLin+nEsp,3270)
		nLin += nEsp
	EndIf
Next nX

nMkupComT	:= Round(nPrcComerT / nCustoT, 2)
nRentT		:= Round(100 * (nPrcComerT - nCustoT) / nPrcComerT, 2)

nColRel	:= 10
nColDif	:= 20*(26+01)
nColRel+=nColDif
nColDif	:= 20*(09+01)
nColRel+=nColDif
nColDif	:= 20*(10+01)
nColRel+=nColDif
nColDif	:= 20*(09+01)
nColRel+=nColDif
nColDif	:= 20*(05+01)
nColRel+=nColDif
nColDif	:= 20*(02+01)
nColRel+=nColDif
nColDif	:= 20*(02+01)
nColRel+=nColDif
nColDif	:= 20*(07+01)
oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
oPrn:Say(nLin,nColRel+10,Transform(nPecasT, "@E 999,999"),oFont1)
nColRel+=nColDif
nColDif	:= 20*(08+01)
nColRel+=nColDif
nColDif	:= 20*(10+01)
nColRel+=nColDif
nColDif	:= 20*(09+01)
nColRel+=nColDif
nColDif	:= 20*(06+01)
nColRel+=nColDif
nColDif	:= 20*(06+01)
nColRel+=nColDif
nColDif	:= 20*(14+01)
oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
oPrn:Say(nLin,nColRel+10,Transform(nLucroTT, "@E 999,999,999.99"),oFont1)
nColRel+=nColDif
nColDif	:= 20*(06+01)
nColRel+=nColDif
nColDif	:= 20*(05+01)
oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
oPrn:Say(nLin,nColRel+10,Transform(nMkupComT, "@E 99.99"),oFont1)
nColRel+=nColDif
nColDif	:= 20*(06+01)
oPrn:Box(nLin,nColRel,nLin+nEsp,nColRel+nColDif)
oPrn:Say(nLin,nColRel+10,Transform(nRentT, "@E 999.99"),oFont1)
nColRel+=nColDif
nColDif	:= 20*(05+01)
nColRel+=nColDif
nLin += nEsp

Return


**************************************************************************
Static Function fCabec()
**************************************************************************

Local nColRel	:= 0
Local nColDif	:= 0

oPrn:EndPage()
oPrn:StartPage()
nLin := 50
oPrn:Box(nLin,0010,nLin+nEsp*4,3270)
nLin+=nEsp

nPag++

oPrn:Say(nLin,0015,"HORA: " + Time() + " - (ORTA575-"+UPPER(AllTrim(GetEnvServer()))+")",oFont1)
oPrn:Say(nLin,3010,"No FOLHA: " + StrZero(nPag,3,0),oFont1)
oPrn:Say(nLin,0000,PADC(cTitulo, 175),oFont1)
nLin += nEsp

oPrn:Say(nLin,0015,"EMPRESA: "+cEmpAnt + " / Filial: " + cFilAnt,oFont1)
oPrn:Say(nLin,2935,"EMISSAO: "+dtoc(DATE()),oFont1)
nLin += nEsp*2

oPrn:Box(nLin,0010,nLin+nEsp*3,3270)
nColRel	:= 10
nColDif	:= 20*(20+01)
oPrn:Say(nLin,nColRel+10,"PROJEÇÃO",oFont1)
nColRel+=nColDif
oPrn:Say(nLin,nColRel+10,cNumProj,oFont1)
nLin += nEsp
nColRel	:= 10
nColDif	:= 20*(20+01)
oPrn:Say(nLin,nColRel+10,"PERÍODO",oFont1)
nColRel+=nColDif
oPrn:Say(nLin,nColRel+10,DToC(dPerDe) + " ATÉ " + DToC(dPerAte),oFont1)
nLin += nEsp
nColRel	:= 10
nColDif	:= 20*(20+01)
oPrn:Say(nLin,nColRel+10,"TIPO DE CLIENTE",oFont1)
nColRel+=nColDif
oPrn:Say(nLin,nColRel+10,"PULVERIZADO ["+IIf(lPulver, "X", " ")+"] - ESPECIAL ["+IIf(lEspecial, "X", " ")+"] - SUPERVERTICAL ["+IIf(lSuperVert, "X", " ")+"]",oFont1)
nLin += nEsp

oPrn:Box(nLin,0010,nLin+nEsp*3,3270)
nColRel	:= 10
nColDif	:= 20*(20+01)
oPrn:Say(nLin,nColRel+10,"USUÁRIO",oFont1)
nColRel+=nColDif
oPrn:Say(nLin,nColRel+10,"GER. GERAL, GER. COMERCIAL E GESTOR DE PREÇOS",oFont1)
nLin += nEsp
nColRel	:= 10
nColDif	:= 20*(20+01)
oPrn:Say(nLin,nColRel+10,"OBJETIVO",oFont1)
nColRel+=nColDif
oPrn:Say(nLin,nColRel+10,"ESTE MAPA PROJETA O NOVO MIX DE ACORDO COM OS DESCONTOS E ACRÉSCIMOS PRATICADOS.",oFont1)
nLin += nEsp
nColRel	:= 10
nColDif	:= 20*(20+01)
oPrn:Say(nLin,nColRel+10,"PER. UTILIZAÇÃO",oFont1)
nColRel+=nColDif
oPrn:Say(nLin,nColRel+10,"SEMANAL",oFont1)
nLin += nEsp

nColRel	:= 10
nColDif	:= 20*(26+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADR("CÓDIGO", 10) + "- DESCRIÇÃO",oFont1)
nColRel+=nColDif
nColDif	:= 20*(09+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*0,nColRel+10,PADL("PREÇO", 09),oFont1)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("MARFIL", 09),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("(KG) "+cCodTab + " - " + cRefTab, 09),oFont1)
nColRel+=nColDif
nColDif	:= 20*(10+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("PESO", 10),oFont1)
nColRel+=nColDif
nColDif	:= 20*(09+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("PREÇO", 09),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("KG", 09),oFont1)
nColRel+=nColDif
nColDif	:= 20*(05+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("MARK", 05),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("UP", 05),oFont1)
nColRel+=nColDif
nColDif	:= 20*(02+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*0,nColRel+10,PADL("Q", 02),oFont1)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("U", 02),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("A", 02),oFont1)
nColRel+=nColDif
nColDif	:= 20*(02+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*0,nColRel+10,PADL("F", 02),oFont1)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("I", 02),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("N", 02),oFont1)
nColRel+=nColDif
nColDif	:= 20*(07+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("KG", 07),oFont1)
nColRel+=nColDif
nColDif	:= 20*(08+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("DES/ACR", 08),oFont1)
nColRel+=nColDif
nColDif	:= 20*(10+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*0,nColRel+10,PADC("PRC MARFIL", 10),oFont1)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADC("X", 10),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADC("COMERCIAL.", 10),oFont1)
nColRel+=nColDif
nColDif	:= 20*(09+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("CUSTO", 06),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("UNIT", 06),oFont1)
nColRel+=nColDif
nColDif	:= 20*(06+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("DG", 06),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL(Transform(nDG, "99.99") + "%", 06),oFont1)
nColRel+=nColDif
nColDif	:= 20*(06+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("LUCRO", 06),oFont1)
nColRel+=nColDif
nColDif	:= 20*(14+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("LUCRO", 14),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("TOTAL", 14),oFont1)
nColRel+=nColDif
nColDif	:= 20*(06+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("%", 06),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("LUCRO", 06),oFont1)
nColRel+=nColDif
nColDif	:= 20*(05+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("MARK", 05),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("UP", 05),oFont1)
nColRel+=nColDif
nColDif	:= 20*(06+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("RENT.", 06),oFont1)
nColRel+=nColDif
nColDif	:= 20*(05+01)
oPrn:Box(nLin,nColRel,nLin+nEsp*3,nColRel+nColDif)
oPrn:Say(nLin+nEsp*1,nColRel+10,PADL("PART", 05),oFont1)
oPrn:Say(nLin+nEsp*2,nColRel+10,PADL("FIN.", 05),oFont1)
nColRel+=nColDif
nLin += nEsp*3

Return nLin


**************************************************************************
Static Function fQtdVen(cCodProd, nQtdBloco, nPecasL, nPecasP, nPecasE)
**************************************************************************

Local cQuery	:= ""
Local cFilTpCli	:= ""
Local nMedPeri	:= 0

If lPulver ; cFilTpCli += IIf(Empty(cFilTpCli), "", ",") + "'P'" ; EndIf
If lEspecial ; cFilTpCli += IIf(Empty(cFilTpCli), "", ",") + "'E'" ; EndIf
If lSuperVert ; cFilTpCli += IIf(Empty(cFilTpCli), "", ",") + "'S'" ; EndIf

nMedPeri	:= 30 / (dPerAte - dPerDe)

cQuery	:= " SELECT ROUND(NVL(SUM(DECODE(B1_XMODELO, '000011', QTDVEN * B1_PESO, 0)), 0), 2) AS QTDBLO, "
cQuery	+= "        ROUND(NVL(SUM(DECODE(B1_XMODELO, '000008', QTDVEN * B1_PESO, '000018', QTDVEN * B1_PESO, 0)), 0), 2) AS QTDLAM, "
cQuery	+= "        ROUND(NVL(SUM(DECODE(B1_XMODELO, '000009', QTDVEN * B1_PESO, 0)), 0), 2) AS QTDPER, "
cQuery	+= "        ROUND(NVL(SUM(DECODE(B1_XMODELO, '000010', QTDVEN * B1_PESO, '000012', QTDVEN * B1_PESO, 0)), 0), 2) AS QTDPEC "
cQuery	+= "   FROM "+RetSqlName("SB1")+" SB1, MIX"+cEmpAnt+"0, "+RetSqlName("SA1")+" SA1 "
cQuery	+= "  WHERE SB1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery	+= "    AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery	+= "    AND B1_COD = COD "
cQuery	+= "    AND A1_COD = CLIENTE "
cQuery	+= "    AND A1_XTPCLI IN ("+cFilTpCli+") "
cQuery	+= "    AND OPER IN "
cQuery	+= "        ('01', '04', '10', '11', '15', '16', '20', '21', '19', '26', '27') "
cQuery	+= "    AND EMISSAO BETWEEN '"+DToS(dPerDe)+"' AND '"+DToS(dPerAte)+"' "
cQuery	+= "    AND TPSEGM IN ('1', '5') "
cQuery	+= "    AND (B1_COD = '"+cCodProd+"' OR B1_XCODBAS = '"+cCodProd+"') "
U_ORTQUERY(cQuery, "ORTA575_QT")
nQtdBloco	:= ORTA575_QT->QTDBLO * nMedPeri
nPecasL		:= ORTA575_QT->QTDLAM * nMedPeri
nPecasP		:= ORTA575_QT->QTDPER * nMedPeri
nPecasE		:= ORTA575_QT->QTDPEC * nMedPeri
ORTA575_QT->(dbCloseArea())

Return


***************************************************************************************************
/*
Calcula o preço de tabela de um corte industrial

Parâmetros:
cCodBloco	- Código do bloco
cTabela		- Código da tabela
cReferenci	- Referência da tabela
cModelo		- Modelo do corte
nAlt		- Altura do corte
nComp		- Comprimento do corte
nLarg		- Largura do corte
lDescRefer	- Aplica desconto da comercialização? (opcional)

Retorno
nPrcCalc	- Preço calculado
*/
User Function ORTA575C(cCodBloco, cTabela, cReferenci, cModelo, nAlt, nComp, nLarg, lDescRefer)
***************************************************************************************************

Local nPrcCalc	:= 0

If Type(lDescRefer) <> "L"
	lDescRefer	:= .T.
EndIf

Return nPrcCalc

