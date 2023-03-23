#DEFINE GD_INSERT 1
#DEFINE GD_UPDATE 2
#DEFINE GD_DELETE 4
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#include "Tbiconn.ch"

/*-----------------------------------------------------------------
|Funo Montagem de Tela                                           |
|Tela de marcao e processamento dos pedidos para integrao      |
|Desenvolvedo: Diogo Melo                                          |
|Data atualizao: 09/05/2019                                      |
-------------------------------------------------------------------*/

User Function QSIntLoj(lAutomato,cAlias,cMarca,nOpc)

	Local aArea     := GetArea()
	Local aIndSC5   := {}
	Local aPergs    := {}
	Local aRet      := {}
	Local cFilSC5   := ""
	Local cBakSC5   := ""
	Local cQrySC5   := ""
	Local lInverte  := .F.
	Local cTexto    := ''
	Local nReg 	    := 1
	Local lRet      := .F.
	Local aCores := {}
	/*
	Local aCores := {{"Empty(SC5->C5_MKOK)",'BR_BRANCO' },;  //Registro Marca Em Branco
	{"!Empty(SC5->C5_MKOK)",'BR_VERDE'},;   //Registro Marcado
	{"!Empty(SC5->C5_MKOK) .and. 'PA' $ SC5->C5_OK" ,'BR_LARANJA'},;	//Importado Parcial
	{"!Empty(SC5->C5_NOTA).Or.C5_LIBEROK=='E' .And. Empty(C5_BLQ)" ,'DISABLE'}}		//Faturado
	*/					   

	Default lAutomato	:= .F.
	Default cAlias 		:= "SC5"
	Default cMarca		:= ""
	Default nOpc		:= 1

	PRIVATE bFiltraBrw := {|| Nil}
	PRIVATE bEndFilBrw := {|| EndFilBrw(cAlias,aIndSC5),aIndSC5:={}}

	PRIVATE cCadastro  := "Seleo de Pedidos"	//"Exclusao dos Documento de Saida"
	PRIVATE aRotina    := MenuDef()

	aAdd(aCores, {"SC5->C5_OK=='PA'",'BR_LARANJA'})
	aAdd(aCores, {"Empty(SC5->C5_MKOK)",'BR_BRANCO'})
	aAdd(aCores, {"!Empty(SC5->C5_MKOK) .and. SC5->C5_OK=='PA' .OR. !Empty(SC5->C5_MKOK) .and. Empty(SC5->C5_OK)",'BR_VERDE'})

	//--Pergunte sem SX1
	aAdd( aPergs ,{1,"Emisso De : "    ,stod(space(8)),"@!",/*'.F.'*/,,".T.",50,.F.}) 
	aAdd( aPergs ,{1,"Emisso Ate : "   ,dDatabase,"@!",/*'.F.'*/,,".T.",50,.F.})
	aAdd( aPergs ,{1,"Id Datatrax : "   ,space(8),"@!",'.T.',/*'SC5'*/,".T.",75,.F.})
	aAdd( aPergs ,{1,"ID Cliente : "    ,space(8),"@!",     ,/*'SA1'*/,".T.",75,.F.}) 
	//aAdd( aPergs ,{1,"Cliente Ate : "   ,Replicate("Z",TamSX3("C5_CLIENTE")[1]),"@!",/*'.F.'*/,     ,".T.",25,.F.}) 
	//aAdd( aPergs ,{1,"Loja De: "        ,space(6),"@!",     ,'SA1',".T.",50,.F.})
	//aAdd( aPergs ,{1,"Loja Ate : "      ,Replicate("Z",TamSX3("C5_LOJACLI")[1]),"@!",/*'.F.'*/,     ,".T.",25,.F.})  

	If ParamBox(aPergs ,"Seleo para Envio ",@aRet)      

		dDataDe   := DtoS(aRet[1])
		dDataAte  := DtoS(aRet[2])
		cIdTrax   := aRet[3]
		cCliDe    := IIF(!Empty(aRet[4]),ID_MEMBER(aRet[4])," ")
		//cCliAte   := aRet[5]
		//cLojaDe   := aRet[6]
		//cLojaAte  := aRet[7]

	Else
		Msginfo("Seleo incorreta de ttulos")    
		Return   
	EndIf

	If !lAutomato //Caso no precise de montar a tela

		SC5->(DBSetOrder(1))
		/*		
		//Montagem da expressao de filtro
		cFilSC5 := " C5_FILIAL=='"+xFilial(cAlias)+"' .And. "
		cFilSC5 += " DtoS(C5_EMISSAO)>='"+dDataDe+"' .And. "
		cFilSC5 += " DtoS(C5_EMISSAO)<='"+dDataAte+" ' "
		cFilSC5 += " .and. C5_MKOK == '    ' "

		IF !Empty(cIdTrax)
		cFilSC5 += " .And. C5_P_DTRAX='"+Alltrim(cIdTrax)+"'"
		EndIf
		*/		
		IF !Empty(cIdTrax)
			cQrySC5 += " C5_P_DTRAX ='"+Alltrim(cIdTrax)+"' "
			/*
			ElseIf !Empty(cCliDe) .or. !Empty(cCliAte) .and. Empty(cIdTrax)
			dbSelectArea("SA1")
			dbSetOrder(1)
			SA1->(MsSeek(cFilAnt+cCliDe+cLojaDe))
			*/
		ElseIf !Empty(cCliDe)
			cQrySC5 += " C5_CLIENTE = '"+cCliDe+"'"

		Else
			cQrySC5 := " C5_FILIAL='"+xFilial(cAlias)+"' And "
			cQrySC5 += " C5_EMISSAO between '"+dDataDe+"' And '"+dDataAte+"' "
			cQrySC5 += " AND C5_OK NOT IN ('OK','IN','LJ') "
			cQrySC5 += " AND C5_NOTA = ' ' "
			cQrySC5 += " OR C5_LIBEROK = 'E'"
			cQrySC5 += " AND C5_BLQ = ' ' "
			cQrySC5 += " AND C5_P_AG = 0 "

		EndIf
		cBakSC5 := cFilSC5

		//realiza a Filtragem

		bFiltraBrw := {|x,y|IIf(x==Nil,FilBrowse(cAlias,@aIndSC5,@cFilSC5),IIf(x==1,{cBakSC5,cQrySC5},IIf(x==2,aIndSC5,cFilSC5:=y))) }

		If nOpc == 1
			// Insere um SetKey                                     
			SetKey(VK_F12, {|| MsgAlert( "A tecla F12 foi pressionada" )})
			MarkBrow(cAlias,"C5_MKOK",/*cCpo*/,/*aCampos*/,lInverte,GetMark(,cAlias,"C5_MKOK"),/*cCtrlM*/,/*uPar8*/,/*cExpIni*/,/*cExpFim*/,/*dbclick*/,/*Bloco de codigo*/,cQrySC5,/*uPar14*/,aCores,/*uPar16*/,,Nil)
		ElseIf nOpc == 2
			// Insere um SetKey
			SetKey(VK_F12,{||MsgAlert( "A tecla F12 foi pressionada" )})
			mBrowse(7,4,20,74,cAlias,,,,,,aCores,,,,,,,,cQrySC5)
		EndIf

	EndIf

	//Restaura a integridade da rotina?

	EndFilBrw(cAlias,aIndSC5)
	RetIndex(cAlias)
	RestArea(aArea)
Return lRet

/*---------------------
|Funo padro Menudef|
----------------------*/

Static Function MenuDef()

	PRIVATE aRotina    := { ;
	{ "Legenda" ,"u_BLegenda"   ,0,2,0 ,.F.},; //"Pesquisa" */
	{ "Importar","u_QSDOB001"     ,0,4,0 ,Nil},; //"Alterar"
	{ "Visualizar","u_nVisPed"     ,0,2,0 ,Nil}} //"Visualizar"

Return(aRotina)

/*------------------------
|Visualizao de Pedidos  |
-------------------------*/

User function nVisPed()

	A410Visual("SC5",SC5->(Recno()),2)

Return

/*---------------------
|Funo padro Legenda|
----------------------*/

User Function BLegenda()

	Local aLegenda := {}
	AADD(aLegenda,{"BR_BRANCO" ,"Registro sem Marcao" })
	AADD(aLegenda,{"BR_VERDE" ,"Registro Marcado" })
	AADD(aLegenda,{"BR_LARANJA" ,"Baixado Parcialmente SigaLoja" })
	//AADD(aLegenda,{"BR_AZUL" ,"A definir" })

	BrwLegenda(cCadastro, "Legenda", aLegenda)

Return

/*------------------------------------------
|Funo de Tratamento da barra de progresso|
-------------------------------------------*/

User Function QSDOB001()

	Private oProcess
	Private lEnd := .F.
	//includo o parmetro lEnd para controlar o cancelamento da janela
	oProcess := MsNewProcess():New({|lEnd| u_ImpSc5(@oProcess, @lEnd) },"Montando Array","Lendo Registros do Pedido de Vendas",.T.) 
	oProcess:Activate()
Return  

/*------------------------------------------
|Funo consulta ID_MEMBER                 |
-------------------------------------------*/

static function ID_MEMBER(cId)

	Local cQry
	Local cCli

	cQry := " Select A1_P_DTRAX, A1_NOME, A1_COD, A1_LOJA from "+RetSqlName("SA1")+ " SA1 " 
	cQry += " WHERE D_E_L_E_T_ <> '*' "
	cQry += "And A1_P_DTRAX = '"+cId+"' "

	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"cAliasSA1", .F., .T.)

	While cAliasSA1->(!EOF())

		cCli := cAliasSA1->A1_COD

		cAliasSA1->(dbSkip())
	EndDo
	cAliasSA1->(dbCloseArea())
Return cCli

/*-----------------------------------------------------------------
|Funo de Processamento                                           |
|Gera Array com as informaes para executar a incluso no Sigaloja|
|Desenvolvedo: Diogo Melo                                          |
|Data atualizao: 09/05/2019                                      |
-------------------------------------------------------------------*/

User Function ImpSc5()

	Local aCabDados := {}
	Local aItensDados := {}
	Local aItePed := {}
	Local lAutomato := .F. 
	Local nCountC5
	Local nB2Saldo := 0
	Local nTotal := 0

	Local cAliasSC5 := GetNextAlias()
	Local cSC5Qry := ''
	Local cAliasSC6 := GetNextAlias()
	Local cQrySC6 := ''

	cSC5Qry := " Select C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_TIPOCLI, C5_DESCONT, C5_EMISSAO,"
	cSC5Qry += " C5_CONDPAG, C5_VEND1,C5_P_DTRAX, C5_MKOK, C5_OK" 
	cSC5Qry += " FROM "+ RETSQLNAME("SC5") + " SC5 "
	cSC5Qry += " WHERE D_E_L_E_T_ != '*'"
	cSC5Qry += " AND C5_MKOK != ' '"
	cSC5Qry += " AND C5_OK = ' '"
	//cSC5Qry += " AND C5_NOTA != ' ' OR C5_LIBEROK = 'E'"
	cSC5Qry += " AND C5_BLQ = ' ' AND C5_FILIAL ='"+cFilAnt+"'"

	cSC5Qry := ChangeQuery(cSC5Qry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSC5Qry),cAliasSC5, .F., .T.)

	dbSelectArea(cAliasSC5)
	(cAliasSC5)->(dbGoTop())
	nCountC5 := (cAliasSC5)->(RecCount())
	oProcess:SetRegua1(nCountC5)

	While (cAliasSC5)->(!EOF())

		If lEnd	
			//houve cancelamento do processo		
			Exit	
		EndIf	

		If !Empty((cAliasSC5)->C5_MKOK) .AND. (cAliasSC5)->C5_OK $ "  |PA|"

			oProcess:IncRegua1("Lendo Pedido de Venda:" + (cAliasSC5)->C5_FILIAL +" | "+(cAliasSC5)->C5_NUM)

			aAdd(aCabDados,{/**/;
			xFilial("SC5"),/*aCabDados[1][1]*/;
			(cAliasSC5)->C5_NUM,   /*aCabDados[1][2]*/;
			(cAliasSC5)->C5_CLIENTE,/*aCabDados[1][3]*/;
			(cAliasSC5)->C5_LOJACLI,/*aCabDados[1][4]*/;
			(cAliasSC5)->C5_TIPOCLI,/*aCabDados[1][5]*/;
			(cAliasSC5)->C5_DESCONT,/*aCabDados[1][6]*/;
			(cAliasSC5)->C5_EMISSAO,/*aCabDados[1][7]*/;
			(cAliasSC5)->C5_CONDPAG,/*aCabDados[1][8]*/;
			(cAliasSC5)->C5_VEND1,/*aCabDados[1][9]*/,;
			/*SL1->LQ_NUMMOV||aCabDados[1][10]*/'01',;
			(cAliasSC5)->C5_P_DTRAX }) //aCabDados[1][12]
		EndIf
		(cAliasSC5)->(dbSkip())
	EndDo


	For nX := 1 to Len(aCabDados)

		aItensDados := {}

		cQrySC6 := " Select C6_FILIAL, C6_NUM, C6_PRODUTO, C6_QTDVEN, C6_UM, C6_PRCVEN, C6_VALOR, C6_DESCRI, C6_LOCAL, "
		cQrySC6 += " C6_DESCONT, C6_VALDESC, C6_TES, C6_ITEM, C6_QTDENT, C6_NOTA from "+ RetSQLName("SC6") + " SC6 "
		cQrySC6 += " WHERE D_E_L_E_T_ != '*' "
		cQrySC6 += " AND C6_NUM = '"+aCabDados[nX][2]+"' "
		cQrySC6 += " AND C6_FILIAL = '"+aCabDados[nX][1]+"' "
		cQrySC6 += " AND C6_CLI = '"+aCabDados[nX][3]+"'" 
		cQrySC6 += " AND C6_LOJA = '"+aCabDados[nX][4]+"' "

		cQrySC6 := ChangeQuery(cQrySC6)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySC6),cAliasSC6, .F., .T.)

		dbSelectArea(cAliasSC6)
		nCountC6 := (cAliasSC6)->(RecCount())
		oProcess:SetRegua2(nCountC6)

		While (cAliasSC6)->(!eof())

			oProcess:IncRegua2("Pedido: "+ (cAliasSC6)->C6_NUM +" | Item: "+Alltrim((cAliasSC6)->C6_DESCRI))

			If (cAliasSC6)->C6_QTDENT < (cAliasSC6)->C6_QTDVEN .and. Empty((cAliasSC6)->C6_NOTA)

				nB2Saldo := RetSaldo((cAliasSC6)->C6_FILIAL,(cAliasSC6)->C6_PRODUTO,(cAliasSC6)->C6_LOCAL)

				IF nB2Saldo >= (cAliasSC6)->C6_QTDVEN

					aAdd(aItensDados,{;
					(cAliasSC6)->C6_FILIAL,/*aItensDados[1][1]*/;
					(cAliasSC6)->C6_NUM,/*aItensDados[1][2]*/;
					(cAliasSC6)->C6_PRODUTO,/*aItensDados[1][3]*/;
					(cAliasSC6)->C6_QTDVEN,/*aItensDados[1][4]*/;
					(cAliasSC6)->C6_UM,/*aItensDados[1][5]*/;
					(cAliasSC6)->C6_PRCVEN,/*aItensDados[1][6]*/;
					(cAliasSC6)->C6_VALOR,/*aItensDados[1][7]*/;
					(cAliasSC6)->C6_DESCONT,/*aItensDados[1][8]*/;
					(cAliasSC6)->C6_VALDESC,/*aItensDados[1][9]*/;
					(cAliasSC6)->C6_TES,/*aItensDados[1][10]*/;
					(cAliasSC6)->C6_ITEM/*aItensDados[1][11]*/})

				Else
					nTotal := nB2Saldo*(cAliasSC6)->C6_PRCVEN

					aAdd(aItensDados,{;
					(cAliasSC6)->C6_FILIAL,/*aItensDados[1][1]*/;
					(cAliasSC6)->C6_NUM,/*aItensDados[1][2]*/;
					(cAliasSC6)->C6_PRODUTO,/*aItensDados[1][3]*/;
					nB2Saldo,/*aItensDados[1][4]*/;
					(cAliasSC6)->C6_UM,/*aItensDados[1][5]*/;
					(cAliasSC6)->C6_PRCVEN,/*aItensDados[1][6]*/;
					nTotal,/*aItensDados[1][7]*/;
					(cAliasSC6)->C6_DESCONT,/*aItensDados[1][8]*/;
					(cAliasSC6)->C6_VALDESC,/*aItensDados[1][9]*/;
					(cAliasSC6)->C6_TES,/*aItensDados[1][10]*/;
					(cAliasSC6)->C6_ITEM/*aItensDados[1][11]*/})

				EndIf

			Else
				Conout("O produto "+(cAliasSC6)->C6_PRODUTO+" Foi baixado parcialmente no pedido "+(cAliasSC6)->C6_NUM)
			EndIf

			(cAliasSC6)->(dbSkip())
		Enddo

		aAdd(aItePed,aItensDados)
		(cAliasSC6)->(dbCloseArea())

	Next nX

	If !lAutomato
		//FWMsgRun(, {|oSay| u_MyLOJA701(,,,aCabDados,aItensDados) }, "Processando", "Processando a rotina...")
		u_MyLOJA701(,,,aCabDados,aItePed)
	Else
		u_MyLOJA701( , ,'',aCabDados,aItePed)
	Endif
	dbCloseArea(cAliasSC5) 
	dbCloseArea(cAliasSC6) 
Return (aCabDados,aItePed)

/*------------------------------------------------------
|Consulta posio do estoque para importar apenas o que |
|tem saldo                                              |
|Desenvolvedor Diogo Melo                               |
|Data: 02/06/2019                                       |
--------------------------------------------------------*/


Static Function RetSaldo(cEmp, cCodigo, cLocal)
	Local nSaldo := 0

	dbSelectArea("SB2")
	dbSetOrder(1)
	SB2->(MsSeek(cEmp+cCodigo+cLocal))
	nSaldo := SB2->B2_QATU
	SB2->(dbCloseArea())

Return nSaldo

/*------------------------------------------------------
|Execauto Loja701                                       |
|Desenvolvedor Diogo Melo                               |
|Data: 06/05/2019                                       |
--------------------------------------------------------*/

User Function MyLOJA701(oSay,lAutomato,cReserva,aCabDados,aItePed)

	Local _aCab := {} //Array do Cabealho do Oramento
	Local _aItem := {} //Array dos Itens do Oramento
	Local _aParcelas := {} //Array das Parcelas do Oramento
	Local _cEmpresa := FWCodEmp("SLR") //Codigo da Empresa que deseja incluir o orcamento
	Local _cFilial := cFilant //Codigo da Filial que deseja incluir o orcamento
	Local _cVendedor := "" //Codigo do Vendedor
	Local  cMsgErro  := ""
	Local nTamProd   := 0
	Local nTamUM     := 0
	Local nTamTabela := 0
	Local nX         := 0
	Local nY         := 0
	Local xI         := 0
	Local lTemSL1    := .F.
	Local nLRTotal   := 0
	//Local nTamLR_ITEM:= TamSX3("LR_ITEM")[1]		//Variavel que guarda o tamanho do campo LR_ITEM

	Default cReserva := "2"
	Default lAutomato  := .F.
	Default oSay := Nil

	Private lMsHelpAuto := .T. //Variavel de controle interno do ExecAuto
	Private lMsErroAuto := .F. //Variavel que informa a ocorrncia de erros no ExecAuto
	Private INCLUI := .T. //Variavel necessria para o ExecAuto identificar que se trata de uma incluso
	Private ALTERA := .F. //Variavel necessria para o ExecAuto identificar que se trata de uma incluso
	/*
	If lAutomato
	PREPARE ENVIRONMENT EMPRESA _cEmpresa FILIAL _cFilial MODULO "LOJA"
	EndIf
	*/
	//Indica incluso
	lMsHelpAuto := .T.
	lMsErroAuto := .F.

	//Retorna o tamanho dos campos
	nTamProd   := TamSX3("LR_PRODUTO")[1]
	nTamUM     := TamSX3("LR_UM")[1]
	nTamTabela := TamSX3("LR_TABELA")[1]

	//Tabela de Preo
	dbSelectArea("SB0")
	dbSetOrder(1)

	//Tabela de Pedido
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))

	//Itens do Pedido
	dbSelectArea("SC6")
	dbSetOrder(1)

	If Len(aCabDados) > 0
		For nX := 1 to Len(aCabDados)
			lTemSL1 := BuscaSL1(cFilAnt,aCabDados[nX][2]) //Executa validao para incluso

			If !lTemSL1
				_cVendedor := If(Empty(aCabDados[nX][9]),"1",aCabDados[nX][9]) //Codigo do Vendedor

				//Acerta o tamanho do codigo o Vendedor
				_cVendedor := StrZero(val(_cVendedor),TamSX3("A3_COD")[1])

				//***********************************
				// Monta cabealho do oramento (SL2)
				//***********************************
				aAdd( _aCab, {"LQ_VEND" , _cVendedor , NIL} )
				aAdd( _aCab, {"LQ_COMIS" , 0 , NIL} )
				aAdd( _aCab, {"LQ_CLIENTE" , aCabDados[nX][3] , NIL} )
				aAdd( _aCab, {"LQ_LOJA" , aCabDados[nX][4] , NIL} )
				aAdd( _aCab, {"LQ_TIPOCLI" , aCabDados[nX][5] , NIL} )
				aAdd( _aCab, {"LQ_DESCONT" , aCabDados[nX][6] , NIL} )
				aAdd( _aCab, {"LQ_DTLIM" , dDatabase , NIL} )
				aAdd( _aCab, {"LQ_EMISSAO" , dDatabase , NIL} )
				aAdd( _aCab, {"LQ_CONDPG" , aCabDados[nX][8] , NIL} )
				aAdd( _aCab, {"LQ_NUMMOV" , "1 " , NIL} )
				aAdd( _aCab, {"LQ_PEDIDO" , aCabDados[nX][2] , NIL} ) 
				aAdd( _aCab, {"LQ_P_DTRAX" , aCabDados[nX][12] , NIL} ) 
				IF cReserva == '1'
					aAdd( _aCab, {"AUTRESERVA" , "000001" , NIL} ) 
					//Codigo da Loja (Campo SLJ->LJ_CODIGO) que deseja efetuar a reserva quando existir item(s) que for do tipo entrega (LR_ENTREGA = 3)
				EndIf

				//***********************************
				// Monta Itens do oramento (SL1)
				//***********************************
				_aItem := {} //Array dos Itens do Oramento
				_aParcelas := {} //Array das Parcelas do Oramento
				//----------
				// Item 01
				//----------
				If Len(aItePed) > 0

					nValTotal := 0 //Tratamento da condio de pagamento

					For nY := 1 to Len(aItePed)

						For nZ:= 1 to Len(aItePed[nY])

							If aCabDados[nX][1] == aItePed[nY][nZ][1] .and. aCabDados[nX][2] == aItePed[nY][nZ][2]

								If cReserva == '1'
									nLRTotal := aItePed[nY][nZ][4] * aItePed[nY][nZ][6]
									aAdd( _aItem, {} )
									aAdd( _aItem[Len(_aItem)], {"LR_ITEM", aItePed[nY][nZ][11] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_PRODUTO", PadR(aItePed[nY][nZ][3],nTamProd) , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_QUANT" , aItePed[nY][nZ][4] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VRUNIT" , aItePed[nY][nZ][6] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VLRITEM" , nLRTotal , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_UM" , PadR(aItePed[nY][nZ][5],nTamUM) , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_DESC" , aItePed[nY][nZ][8] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VALDESC", aItePed[nY][nZ][9] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_TABELA" , PadR("1",nTamTabela) , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_DESCPRO", 0 , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VEND" , _cVendedor , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_ENTREGA", "3" , NIL} ) 
									aAdd( _aItem[Len(_aItem)], {"LR_PEDIDO", aItePed[nY][nZ][2] , NIL} ) 
									//3=Entrega (Qdo. informado o LR_ENTREGA = 3, deve ser informado tambm o campo "AUTRESERVA" no array de Cabecalho)

									//SB0->(MsSeek(xFilial("SL2")+aItensDados[nY][3]))
									//nValTotal += SB0->B0_PRV1

									//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
									SC6->(MsSeek(xFilial("SC6")+aCabDados[nX][2]+aItePed[nY][nZ][11]+PadR(aItePed[nY][nZ][3],nTamProd))) 
									nValTotal += SC6->C6_PRCVEN
								Else
									//----------
									// Item 02
									//----------
									nLRTotal := aItePed[nY][nZ][4] * aItePed[nY][nZ][6]
									aAdd( _aItem, {} )
									aAdd( _aItem[Len(_aItem)], {"LR_ITEM", aItePed[nY][nZ][11] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_PRODUTO", PadR(aItePed[nY][nZ][3],nTamProd) , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_QUANT" , aItePed[nY][nZ][4] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VRUNIT" , aItePed[nY][nZ][6] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VLRITEM" , nLRTotal , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_UM" , PadR(aItePed[nY][nZ][5],nTamUM) , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_DESC" , aItePed[nY][nZ][8] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VALDESC", aItePed[nY][nZ][9] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_TABELA" , PadR("1",nTamTabela) , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_DESCPRO", 0 , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VEND" , _cVendedor , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_PEDIDO", aItePed[nY][nZ][2] , NIL} ) 

									//SB0->(MsSeek(xFilial("SL2")+aItensDados[nY][3]))
									//nValTotal += SB0->B0_PRV1

									//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
									SC6->(MsSeek(xFilial("SC6")+aCabDados[nX][2]+aItePed[nY][nZ][11]+PadR(aItePed[nY][nZ][3],nTamProd))) 
									nValTotal += SC6->C6_PRCVEN
								EndIf
							Endif

						Next nZ

					Next nY

					//************************************************
					// Monta o Pagamento do orçamento (aPagtos) (SL4)
					//************************************************
					aAdd( _aParcelas, {} )
					aAdd( _aParcelas[Len(_aParcelas)], {"L4_DATA" , dDatabase , NIL} )
					aAdd( _aParcelas[Len(_aParcelas)], {"L4_VALOR" , nValTotal , NIL} )
					aAdd( _aParcelas[Len(_aParcelas)], {"L4_FORMA" , "CC" , NIL} )
					aAdd( _aParcelas[Len(_aParcelas)], {"L4_ADMINIS" , " " , NIL} )
					aAdd( _aParcelas[Len(_aParcelas)], {"L4_NUMCART" , " " , NIL} )
					aAdd( _aParcelas[Len(_aParcelas)], {"L4_FORMAID" , " " , NIL} )
					aAdd( _aParcelas[Len(_aParcelas)], {"L4_MOEDA" , 0 , NIL} )


					SetFunName("LOJA701")

					MSExecAuto({|a,b,c,d,e,f,g,h| Loja701(a,b,c,d,e,f,g,h)},.F.,3,"","",{},_aCab,_aItem ,_aParcelas)

				Endif
			Endif
		Next nX

		If lMsErroAuto
			If lAutomato
				Conout("Erro na importação")
			Else
				Alert("Erro na importação")
			EndIf
			cMsgErro := MostraErro()
			DisarmTransaction()
			Conout(cMsgErro) 
		Else
			//---Tratamento integração---
			For xI := 1 to Len(aCabDados)
				If SC5->(MsSeek(aCabDados[xI][1] + aCabDados[xI][2])) //C5_FILIAL+C5_NUM
					Reclock("SC5",.F.)
					SC5->C5_OK := "IN"
					SC5->C5_NOTA := 'Integrado' //Bloquear Pedido de venda para no
					SC5->C5_SERIE := 'INT'      //ser faturado pelo mdulo 05
					SC5->C5_ORIGEM := "QSIntLoj"
					MsUnlock()
				EndIf
			Next
			//---------------------------
			
			If lAutomato
				Conout("Sucesso - Pedidos importados")
			Else
				Conout("Sucesso - Pedidos importados")
			Endif
		EndIf
		/*
		If lAutomato
		RESET ENVIRONMENT
		EndIf
		*/
	Endif //Tratamento de validao SL1

Return

/*--------------------------
|Busca SL1                  |
|Desenvolvedor Diogo Melo   |
|Data: 15/05/2019           |
----------------------------*/

Static Function  BuscaSL1(cFil,cNumPv) //Executa validao para incluso

	Local cSLQry := '' 
	Local lRet := .F.
	Local nCountL1 := 0

	cSLQry += " Select L1_FILIAL, L1_PEDIDO From "+ RetSqlName("SL1") + ' SL1 '
	cSLQry += " WHERE SL1.D_E_L_E_T_ <> '*' "
	cSLQry += " AND L1_FILIAL = '"+cFil+"' " 
	cSLQry += " AND L1_PEDIDO = '"+cNumPv+"' "

	cSLQry := ChangeQuery(cSLQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSLQry),"cAliasSL1", .F., .T.)

	dbSelectArea("cAliasSL1")
	nCountL1 := cAliasSL1->(RecCount())

	If nCountL1 > 0
		lRet := .T.
	Else
		lRet := .F.
	EndIf
	dbCloseArea("cAliasSL1")
Return lRet