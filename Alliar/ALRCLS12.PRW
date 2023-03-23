#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
/*
-----------------------------------------------------------------------------------------------------
	Variaveis Estaticas
-----------------------------------------------------------------------------------------------------	
*/
Static oDialog		:= NIL
Static oEnchoice	:= NIL
Static oGetDados	:= NIL
//-------------------------------------------------------------------
/*{Protheus.doc} ALRCLS12
Funcao Generica para Compilacao

@author Guilherme.Santos
@since 01/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRCLS12()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} uModelo2
Monta um Cadastro Modelo 2

@author Guilherme.Santos
@since 01/12/2016
@version P12
*/
//-------------------------------------------------------------------
Class uModelo2
	Data aInfo						//Utilizada para posicionamento dos Objetos na Tela
	Data aObjects					//Utilizada para posicionamento dos Objetos na Tela
	Data aPosGet					//Utilizada para posicionamento dos Objetos na Tela
	Data aPosObj					//Utilizada para posicionamento dos Objetos na Tela
	Data aSize						//Utilizada para posicionamento dos Objetos na Tela

	Data aRotina					//Rotinas no Menu da MBrowse
	Data aButtons					//Botoes da Rotina de Manutencao
	Data cDlgTit					//Titulo da Dialog					
	Data cAliasCab					//Alias do Cabecalho
	Data cAliasItem					//Alias do Item
	Data cKeyCab					//Chave Primaria do Cabecalho
	Data cKeyItem					//Chave Primaria do Item
	Data cDelOk				   		//Nome da Rotina para Validacao na Exclusao de Linhas
	Data cLinhaOk					//Nome da Rotina para Validacao na Inclusao ou Alteracao de Linhas
	Data cRotGrv					//Nome da Rotina para Gravacao dos dados na Confirmacao
	Data cTitulo					//Titulo da Rotina
	Data cTudoOk					//Nome da Rotina para Validacao na Confirmacao
	Data cVldItem					//Nome da Rotina para Validacao do Item
	Data cFldOk				   		//Validacao do Campo
	Data nColFreze					//Coluna fixa
	Data nGetLin					//Posicao da Get
	Data nOpcEnc					//Opcao Selecionada na Enchoice
	Data lFreze				   		//Congela coluna especificada pelo parametro nColFreeze
	Data nQtdGet					//Quantidade de Linhas da GetDados

	Method New(cDlgTit, cAliasCab, cAliasItem, aRotina, aKeyCab, aKeyItem,cTudoOk, cLinhaOk, cDelOk, cVldItem, cFldOk, nQtdGet)
	Method Open()
	Method ShowMan(cAlias, nReg, nOpcao)
	Method SetEnch(nOpcao)
	Method SetGetD(nOpcao)
	Method C()
    Method Refresh()
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Inicializa o Objeto

@author Guilherme.Santos
@since 01/12/2016
@version P12
*/
//-------------------------------------------------------------------
Method New(cDlgTit, cAliasCab, cAliasItem, aRotina, aKeyCab, aKeyItem, cTudoOk, cLinhaOk, cDelOk, cRotGrv, cVldItem, cFldOk, nQtdGet) Class uModelo2

	Local nX		:= 0

	::aRotina		:= aClone(aRotina)
	::cDlgTit		:= cDlgTit
	::cAliasCab		:= cAliasCab
	::cAliasItem	:= cAliasItem
	::cKeyCab		:= ""
	::cKeyItem		:= ""

	::aButtons		:= {}

	::cTudoOk		:= cTudoOk
	::cLinhaOk		:= cLinhaOk
	::cDelOk		:= cDelOk
	::cRotGrv		:= cRotGrv
	::cVldItem		:= cVldItem
	::cFldOk		:= cFldOk
	::lFreze		:= .T.
	::nColFreze		:= 1
	
	::nQtdGet		:= nQtdGet
	/*
	-----------------------------------------------------------------------------------------------------
		Faz o calculo automatico de dimensoes de objetos
	-----------------------------------------------------------------------------------------------------	
	*/
	::aObjects		:= {}

 	Aadd(::aObjects, {100, 100, .T., .T.})
	Aadd(::aObjects, {100, 100, .T., .T.})
	Aadd(::aObjects, {100, 015, .T., .F.})

	::aSize			:= MsAdvSize()
	::aInfo			:= {::aSize[01], ::aSize[02], ::aSize[03], ::aSize[04], 03, 03}
	::aPosObj		:= MsObjSize(::aInfo, ::aObjects)
	::aPosGet		:= MsObjGetPos(::aSize[03] - ::aSize[01], 315, {{003, 033, 160, 200, 240, 263}})

	For nX := 1 to Len(aKeyCab)
		::cKeyCab += aKeyCab[nX]
		If nX <> Len(aKeyCab)
			::cKeyCab += "+"
		EndIf
	Next nX
	
	For nX := 1 to Len(aKeyItem)
		::cKeyItem += aKeyItem[nX]
		If nX <> Len(aKeyItem)
			::cKeyItem += "+"
		EndIf
	Next nX

Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} Open
Inicializa a MBrowse com base na Tabela de Cabecalho

@author Guilherme.Santos
@since 01/12/2016
@version P12
*/
//-------------------------------------------------------------------
Method Open() Class uModelo2
	Private aRotina		:= aClone(::aRotina)
	Private cCadastro	:= ::cDlgTit

	MBrowse(006, 001, 022, 075, ::cAliasCab)
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} ShowMan
Inicializa a Tela de Manutencao de Registros

@author Guilherme.Santos
@since 01/12/2016
@version P12
*/
//-------------------------------------------------------------------
Method ShowMan(cAlias, nReg, nOpcao) Class uModelo2

	Local aButtons	:= If(!Empty(::aButtons), aClone(::aButtons), NIL)
	Local nOpcEnc	:= 0
	Local lRetorno	:= .F.

	Local bOk		:= {|| lRetorno := &(::cTudoOk), If(lRetorno, oDialog:End(), NIL), If(lRetorno, nOpcEnc := 1, nOpcEnc := 0) }
	Local bCancel	:= {|| nOpcEnc := 0, oDialog:End()}

	If nOpcao == 2
		VISUAL := .T.
	Else
		If nOpcao == 3
			INCLUI := .T.
		Else
			If nOpcao == 4
				ALTERA := .T.
			Else
				If nOpcao == 5
					EXCLUI := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	Do Case
		Case nOpcao == 3		//Inclusao
			RegToMemory(::cAliasCab, .T. , .T.)
		Case nOpcao == 4		//Alteracao
			RegToMemory(::cAliasCab, .F. , .T.)
		Otherwise		//Visualizacao ou Exclusao
			RegToMemory(::cAliasCab, .F. , .F.)
	EndCase

		DEFINE MSDIALOG oDialog TITLE ::cDlgTit FROM ::aSize[07], 000  TO ::aSize[06], ::aSize[05] OF GETWNDDEFAULT() PIXEL
			::SetEnch(nOpcao)
			::SetGetD(nOpcao)
	 	ACTIVATE MSDIALOG oDialog CENTERED ON INIT EnchoiceBar(oDialog, bOk, bCancel, NIL, aButtons)
	
		If nOpcEnc == 1
			&(::cRotGrv)
		EndIf

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} SetEnch
Inicializa a Enchoice com a Estrutura da Tabela de Cabecalho

@author Guilherme.Santos
@since 01/12/2016
@version P12
*/
//-------------------------------------------------------------------
Method SetEnch(nOpcao) Class uModelo2
	Local aFields	:= {}
	Local aAlter	:= {}
	
	//Campos para consultar sx3	
	Local nX3CAMPO   := SX3->(FIELDPOS("X3_CAMPO"))
	Local nX3ARQUIVO := SX3->(FIELDPOS("X3_ARQUIVO"))
	Local nX3USADO 	 := SX3->(FIELDPOS("X3_USADO"))
	Local nX3NIVEL 	 := SX3->(FIELDPOS("X3_NIVEL"))
	Local nX3VISUAL  := SX3->(FIELDPOS("X3_VISUAL"))
	Local nX3CONTEXT  := SX3->(FIELDPOS("X3_CONTEXT"))

	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))	//X3_ARQUIVO + X3_ORDEM

	If SX3->(DbSeek(::cAliasCab))
		While !SX3->(Eof()) .AND. ::cAliasCab == SX3->(FIELDGET(nX3ARQUIVO))
			If X3Uso(SX3->(FIELDGET(nX3USADO))) .AND. cNivel >= SX3->(FIELDGET(nX3NIVEL))

				Aadd(aFields, SX3->(FIELDGET(nX3CAMPO)))

				If SX3->(FIELDGET(nX3VISUAL)) <> "V" .AND. SX3->(FIELDGET(nX3CONTEXT)) <> "V"
					Aadd(aAlter, SX3->(FIELDGET(nX3CAMPO)))
				EndIf
			EndIf

			SX3->(DbSkip())
		End
	EndIf

	oEnchoice := MsMGet():New(::cAliasCab, 0, nOpcao, NIL, NIL, NIL, aFields, ::aPosObj[01], If(nOpcao==4, aAlter, NIL), 3, NIL, NIL, NIL, oDialog, NIL, .T.)
 
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} SetGetD
Inicializa a GetDados com base na Tabela de Itens

@author Guilherme.Santos
@since 01/12/2016
@version P12
*/
//-------------------------------------------------------------------
Method SetGetD(nOpcao) Class uModelo2
	Local nX		:= 0
	Local aColsAux	:= {}
	Local aAlter	:= {}
	Local cKeyPesq	:= (::cAliasCab)->(&(::cKeyCab))

	aCols		:= {}
	aHeader		:= {}
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))	//X3_ARQUIVO + X3_ORDEM

	If SX3->(DbSeek(::cAliasItem))
		While !SX3->(Eof()) .AND. ::cAliasItem == SX3->(FIELDGET(FIELDPOS("X3_ARQUIVO")))

			If X3Uso(SX3->(FIELDGET(FIELDPOS("X3_USADO")))) .AND. cNivel >= SX3->(FIELDGET(FIELDPOS("X3_NIVEL")))

				Aadd(aHeader, 	{	AllTrim(X3Titulo()),	SX3->(FIELDGET(FIELDPOS("X3_CAMPO"))),		SX3->(FIELDGET(FIELDPOS("X3_PICTURE"))),	SX3->(FIELDGET(FIELDPOS("X3_TAMANHO"))),;
									SX3->(FIELDGET(FIELDPOS("X3_DECIMAL"))), SX3->(FIELDGET(FIELDPOS("X3_VALID"))),	SX3->(FIELDGET(FIELDPOS("X3_USADO"))), SX3->(FIELDGET(FIELDPOS("X3_TIPO"))),;
									SX3->(FIELDGET(FIELDPOS("X3_F3"))),	SX3->(FIELDGET(FIELDPOS("X3_CONTEXT"))), SX3->(FIELDGET(FIELDPOS("X3_CBOX"))), SX3->(FIELDGET(FIELDPOS("X3_RELACAO")))})

				If SX3->(FIELDGET(FIELDPOS("X3_VISUAL"))) <> "V" .AND. SX3->(FIELDGET(FIELDPOS("X3_CONTEXT"))) <> "V"
					Aadd(aAlter, SX3->(FIELDGET(FIELDPOS("X3_CAMPO"))))
				EndIf
			EndIf

			SX3->(DbSkip())
		End
	EndIf
	
	If nOpcao == 3
		/*
		-----------------------------------------------------------------------------------------------------
			Na Inclusao cria uma linha do aCols em branco.
		-----------------------------------------------------------------------------------------------------	
		*/
		For nX := 1 to Len(aHeader)
			If "_ITEM" $ aHeader[nX][02]
				Aadd(aColsAux, "01")
			Else
				Aadd(aColsAux, CriaVar(aHeader[nX][02]))
			EndIf
		Next nX
	
		Aadd(aColsAux, .F.)
		Aadd(aCols, aColsAux)
	Else
		/*
		-----------------------------------------------------------------------------------------------------
			Alimenta o aCols de acordo com a Chave de Pesquisa.
		-----------------------------------------------------------------------------------------------------	
		*/

		DbSelectArea(::cAliasItem)
		DbSetOrder(1)
		
		If (::cAliasItem)->(DbSeek(xFilial(::cAliasItem) + cKeyPesq))
			While !(::cAliasItem)->(Eof()) .AND. xFilial(::cAliasItem) + cKeyPesq == xFilial(::cAliasItem) + (::cAliasItem)->(&(::cKeyItem))
				For nX := 1 to Len(aHeader)
					Aadd(aColsAux, (::cAliasItem)->(&(aHeader[nX][02])))
				Next nX
			
				Aadd(aColsAux, .F.)
				Aadd(aCols, aColsAux)
				aColsAux := {}

				(::cAliasItem)->(DbSkip())
			End
		EndIf
	EndIf

	oGetDados	:= MsGetDados():New(	::aPosObj[02, 01],	::aPosObj[02, 02],	::aPosObj[02, 03],	::aPosObj[02, 04],;
										nOpcao,				::cLinhaOk,			::cTudoOk,			::cVldItem,;
										.T.,				aAlter,				::nColFreze,		NIL,;
										::nQtdGet,			::cFldOk,			NIL,				NIL,;
										::cDelOk,			NIL,				::lFreze)

Return Nil
//-----------------------------------------------------------------------------------------------
/*{Protheus.doc} C
Funcao responsavel por manter o Layout independente da resolucao horizontal do Monitor do Usuario

@author Guilherme.Santos
@since 01/12/2016
@version P12
*/
//-----------------------------------------------------------------------------------------------
Method C(nTam) Class uModelo2
	Local nHRes	:=	GetScreenRes()[1]	//Resolucao horizontal do monitor

	Do Case
	Case nHRes == 640	//Resolucao 640x480
		nTam *= 0.8
	Case nHRes == 800	//Resolucao 800x600
		nTam *= 1
	OtherWise			//Resolucao 1024x768 e acima
		nTam *= 1.28
	End Case
	/*
	-----------------------------------------------------------------------------------------------------
		Tratamento para tema Flat
	-----------------------------------------------------------------------------------------------------	
	*/
	If (Alltrim(GetTheme()) == "FLAT").Or. SetMdiChild()
		nTam *= 0.90
	EndIf
Return Int(nTam)
//-------------------------------------------------------------------
/*{Protheus.doc} Refresh
Atualiza os Objetos da Tela

@author Guilherme.Santos
@since 01/12/2016
@version P12
*/
//-------------------------------------------------------------------
Method Refresh() Class uModelo2
	oDialog:Refresh()
	oEnchoice:Refresh()	
	oGetDados:Refresh()
Return NIL
