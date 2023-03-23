#include "rwmake.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MT120TEL        ³ Totvs      ³ Data ³ 24/04/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de Entrada p/ incluir FOLDER NO PEDIDO              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Chamada padrao para programas em RDMake.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/
User Function MT120TEL()
	Local nOpcx     := PARAMIXB[4]   //hfp abax 
	Local aPosGet := PARAMIXB[2]     //hfp abax 
	Local oDlg      := PARAMIXB[1] //hfp abax
	Local lEdit     := IIF(nOpcx == 3 .Or. nOpcx == 4 .Or. nOpcx ==  6, .T., .F.) //Somente será editável, na Inclusão, Alteração e Cópia
	Local oXAux
	Local aCombo:={}
	Local aTmp
   Public cXAux := ""

	If FindFunction("U_ALCO14")
		U_ALCO14()
	EndIf


//task 22238395
//by hfp  abax
//AAdd( aTitles, 'Alliar' )  //adiciona folder no rodape
aTmp := RetSX3Box(GetSX3Cache("C7_XTPDOC", "X3_CBOX"),,,1)
Aeval(aTmp,{|x| aadd(aCombo,x[1]) } )

	If nOpcx == 3
		cXAux := CriaVar("C7_XTPDOC",.F.)
	Else
		cXAux := SC7->C7_XTPDOC
	EndIf

	//Criando na janela o campo OBS
	@ 062, aPosGet[1,08] - 012 SAY Alltrim(RetTitle("C7_XTPDOC")) OF oDlg PIXEL SIZE 050,006
	@ 061, aPosGet[1,09] - 006 COMBOBOX oXAux VAR cXAux ITEMS aCombo SIZE 70, 006 OF oDlg COLORS 0, 16777215  PIXEL
	

	//Se não houver edição, desabilita os gets
	If !lEdit
		oXAux:lActive := .F.
	EndIf

// end abax



Return

