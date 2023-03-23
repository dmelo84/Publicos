#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"

/*-----------------------------------------------------------------
|Criação de tabela temporária                                      |
|Cria a tabela temporária no banco de dados para processo          |
|Desenvolvedo: Diogo Melo                                          |
|Data atualização: 09/05/2019                                      |
-------------------------------------------------------------------*/

User Function QSdoB002()

	Local aFields := {}
	Local oTempTable
	Local nI
	Local cAlias := GetNextAlias()
	Local cQuery := ''

	Local nTamItem := TamSX3("L2_ITEM")[1]
	Local nTamCod  := TamSX3("L2_PRODUTO")[1] 
	Local nTamCodBr:= TamSX3("B1_CODBAR")[1]
	Local nTamDescr:= TamSX3("L2_DESCRI")[1]
	Local nTamVrUni:= TamSX3("L2_VRUNIT")[1]
	Local nTamVrQtd:= TamSX3("L2_QUANT")[1]

	Private cNumSL2 := SL1->L1_NUM

	If SL1->L1_TIPO == "V" .AND. SL1->L1_SITUA == "OK" .or. SL1->L1_DTLIM < dDatabase
		Help(NIL, NIL, "Bloqueio", NIL, "Orçamento inválido", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Selecione um orçamento com legenda verde"})
		Return
	EndIf

	//-------------------
	//Criação do objeto
	//-------------------
	oTempTable := FWTemporaryTable():New( cAlias )

	//--------------------------
	//Monta os campos da tabela
	//--------------------------
	aadd(aFields,{"Item","C",nTamItem,0})
	aadd(aFields,{"Codigo","C",nTamCod,1})
	aadd(aFields,{"Descricao","C",nTamDescr,0})
	aadd(aFields,{"Quantidade","N",nTamVrQtd,0})
	aadd(aFields,{"CodBarra","C",nTamCodBr,0})
	aadd(aFields,{"Valor","N",nTamVrUni,2})
	aadd(aFields,{"POK","N",nTamVrUni,2})

	oTemptable:SetFields( aFields )
	oTempTable:AddIndex("indice1", {"Item"} )
	oTempTable:AddIndex("indice2", {"Item", "Codigo"} )
	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()

	//------------------------------------
	//Executa query para leitura da tabela
	//------------------------------------
	cTable := oTempTable:GetRealName()

	cQuery += " select L2_ITEM, L2_PRODUTO, L2_DESCRI, L2_QUANT, ' 'L2_CODBAR, L2_VRUNIT, L2_POK from " + RETSQLNAME("SL2") + ' SL2 '
	cQuery += " WHERE SL2.D_E_L_E_T_ <> '*' "
	cQuery += " AND L2_FILIAL = '"+xFilial("SL2") +" ' "
	cQuery += " AND L2_NUM = '"+cNumSL2+" ' "

	MPSysOpenQuery( cQuery, 'QRYTMP' )

	DbSelectArea('QRYTMP')

	while QRYTMP->(!eof())
		Reclock(cAlias,.T.)
			Item      := QRYTMP->L2_ITEM
			Codigo    := QRYTMP->L2_PRODUTO
			Descricao := QRYTMP->L2_DESCRI
			Quantidade:= QRYTMP->L2_QUANT
			CodBarra  := QRYTMP->L2_CODBAR
			Valor     := QRYTMP->L2_VRUNIT
			POK       := QRYTMP->L2_POK
		MsunLock()
		QRYTMP->(dbskip())
	Enddo

	FWMsgRun(, {|oSay| U_PickList(cAlias) }, "Processando", "Processando a rotina...")

	//---------------------------------
	//Exclui a tabela 
	//---------------------------------
	oTempTable:Delete() 

Return

/*-----------------------------------------------------------------
|Monta a MsGetDados para digitação do código de barra              |
|Desenvolvedo: Diogo Melo                                          |
|Data atualização: 09/05/2019                                      |
-------------------------------------------------------------------*/

User Function PickList(cTabela)

	Local nI
	Local oDlg
	Local oGetDados
	Local nUsado := 0

	Private lRefresh := .T.
	Private aHeader := {}
	Private aCols := {}

	Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;                    
	{"Visualizar", "AxVisual", 0, 2},;                    
	{"Incluir", "AxInclui", 0, 3},;                    
	{"Alterar", "AxAltera", 0, 4},;
	{"Excluir", "AxDeleta", 0, 5}}

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SL2")

	While SX3->(!Eof()) .and. SX3->X3_ARQUIVO == "SL2"
		If X3Uso(SX3->X3_USADO) .and. SX3->X3_CAMPO $ "|L2_ITEM   |L2_QUANT  |L2_CODBAR |L2_VRUNIT |L2_DESCRI |L2_PRODUTO|L2_POK    | "  //cNivel >= SX3->X3_NIVEL        
			nUsado++        
			Aadd(aHeader,{Trim(X3Titulo()),;
			SX3->X3_CAMPO,;                      
			SX3->X3_PICTURE,;                      
			SX3->X3_TAMANHO,;                      
			SX3->X3_DECIMAL,;                      
			SX3->X3_VALID,;                      
			"",;                      
			SX3->X3_TIPO,;                      
			"",;
			"" })
		EndIf
		DbSkip()
	EndDo

	dbSelectArea(cTabela)
	(cTabela)->(dbGoTop())

	While (cTabela)->(!Eof())
		Aadd(aCols,{(cTabela)->Codigo,;
		(cTabela)->Item,;
		(cTabela)->Descricao,;
		(cTabela)->Quantidade,;
		(cTabela)->Valor,;
		(cTabela)->CodBarra,;
		(cTabela)->POK,;
		.F. })

		(cTabela)->(dbSkip())
	EndDo


	DEFINE MSDIALOG oDlg TITLE "Rotina Pick List" FROM 00,00 TO 400,800 PIXEL
	oGetDados := MsGetDados():New(40, 5, 145, 400, 4, "U_LINHAOK1", /*"U_aTUDOOK1"*/, "L2_ITEM   ", .T.,{"L2_CODBAR"}, , .F., 200,"U_FIELDOK1", /*"U_SUPERDEL"*/, , /*"U_DELOK1"*/,	oDlg)
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| ExecVenda() },{|| oDlg:End() })

Return


static Function ExecVenda()

	If MsgYesNo( 'Confirma?', 'Prossegue com a Venda?' )
		MsgRun("Processando", "Loja701", {|| LJ7Venda("SL1", SL1->(Recno()), 4, Nil, Nil, Nil, "")})
	Else
		MsgInfo( 'Voltar!', 'Retorna' )
	Endif

Return

User Function LINHAOK1()
	Local  nQuant := aCols[N][4] //Validar quantidade do produto
	Local  lRet := .F.

	If acols[N][7] != nQuant
		MsgInfo("A quantidade de leitura dos codigos deverão se iguais as quantidades do produto!")
	Else
		lRet := AlwaysTrue()
	Endif
	GETDREFRESH()
Return lRet 

User Function FIELDOK1()

	Local  nPos := N 
	Local  nTamFil := TamSX3("L2_FILIAL")[1]
	Local  lRet
	Local  nQuant := aCols[nPos][4] 
	Local  nY := 0
	Local  aColsCodBar := L2_CODBAR //Depois que posiciona na linha 202 perde a referencia.

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD

	SB1->(MsSeek(Space(nTamFil)+aCols[nPos][1]))
	cCodBar := Alltrim(SB1->B1_CODBAR)

	If Alltrim(aColsCodBar) == cCodBar .and. !Empty(cCodBar)

		dbSelectArea("SL2")
		SL2->(dbSetOrder(1)) //L2_FILIAL+L2_NUM+L2_ITEM+L2_PRODUTO
		SL2->(MsSeek(xFilial("SL2")+cNumSL2+aCols[nPos][2]+aCols[nPos][1]))

		If Empty(SL2->L2_CODBAR) .or. Empty(SL2->L2_SITUA)
			Reclock("SL2",.F.)
			SL2->L2_SITUA := "KO"
			SL2->L2_CODBAR := cCodBar
			MsUnLock()
		EndIf

		If acols[nPos][7] < nQuant .and. SL2->L2_POK < SL2->L2_QUANT

			acols[nPos][7] += 1
			lRet := .F.

			Reclock("SL2", .F.)
			SL2->L2_POK := acols[nPos][7] 
			MsUnlock()

			GETDREFRESH()
		Else
			lRet := .T.
			acols[nPos][6] := 'Pick OK'
			GETDREFRESH()
		EndIf
	Else
		If Empty(cCodBar)
			Help(NIL, NIL, "Bloqueio", NIL, "Codigo de barra do cadastro de produto está em branco.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Atualize o cadastro do produto."})
			lRet := .F.
		Else
			Alert("Codigo de barras inválido.")
			lRet := .F.
		EndIf
	EndIf

	dbCloseArea("SL2")
	dbCloseArea("SB1")

Return lRet





