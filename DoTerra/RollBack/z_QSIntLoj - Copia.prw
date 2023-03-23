#DEFINE GD_INSERT 1
#DEFINE GD_UPDATE 2
#DEFINE GD_DELETE 4
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#include "Tbiconn.ch"

/*-----------------------------------------------------------------
|Função Montagem de Tela                                           |
|Tela de marcação e processamento dos pedidos para integração      |
|Desenvolvedo: Diogo Melo                                          |
|Data atualização: 09/05/2019                                      |
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

	PRIVATE cCadastro  := "Seleção de Pedidos"	//"Exclusao dos Documento de Saida"
	PRIVATE aRotina    := MenuDef()

	aAdd(aCores, {"SC5->C5_OK=='PA'",'BR_LARANJA'})
	aAdd(aCores, {"Empty(SC5->C5_MKOK)",'BR_BRANCO'})
	aAdd(aCores, {"!Empty(SC5->C5_MKOK) .and. SC5->C5_OK=='PA' .OR. !Empty(SC5->C5_MKOK) .and. Empty(SC5->C5_OK)",'BR_VERDE'})

	//--Pergunte sem SX1
	aAdd( aPergs ,{1,"Pedido : ",space(6),"@!",'.T.','SC5',".T.",50,.F.})
	aAdd( aPergs ,{1,"Emissão De : "    ,stod(space(8)),"@!",/*'.F.'*/,,".T.",50,.F.}) 
	aAdd( aPergs ,{1,"Emissão Ate : "   ,dDatabase,"@!",/*'.F.'*/,,".T.",50,.F.})
	aAdd( aPergs ,{1,"Cliente De : "    ,space(6),"@!",     ,'SA1',".T.",50,.F.}) 
	aAdd( aPergs ,{1,"Cliente Ate : "   ,Replicate("Z",TamSX3("C5_CLIENTE")[1]),"@!",/*'.F.'*/,     ,".T.",25,.F.}) 
	aAdd( aPergs ,{1,"Loja De: "        ,space(6),"@!",     ,'SA1',".T.",50,.F.})
	aAdd( aPergs ,{1,"Loja Ate : "      ,Replicate("Z",TamSX3("C5_LOJACLI")[1]),"@!",/*'.F.'*/,     ,".T.",25,.F.})  

	If ParamBox(aPergs ,"Seleção para Envio ",@aRet)      

		cPedido   := aRet[1]
		dDataDe   := DtoS(aRet[2])
		dDataAte  := DtoS(aRet[3])
		cCliDe    := aRet[4]
		cCliAte   := aRet[5]
		cLojaDe   := aRet[6]
		cLojaAte  := aRet[7]

	Else
		Msginfo("Seleção incorreta de títulos")    
		Return   
	EndIf

	If !lAutomato //Caso não precise de montar a tela

		SC5->(DBSetOrder(1))

		//Montagem da expressao de filtro
		cFilSC5 := " C5_FILIAL=='"+xFilial(cAlias)+"' .And. "
		cFilSC5 += " DtoS(C5_EMISSAO)>='"+dDataDe+"' .And. "
		cFilSC5 += " DtoS(C5_EMISSAO)<='"+dDataAte+" ' "
		cFilSC5 += " .and. C5_MKOK == '    ' "

		IF !Empty(cPedido)
			cFilSC5 += " .And. C5_NUM='"+cPedido+"'"
		EndIf

		cQrySC5 := " C5_FILIAL='"+xFilial(cAlias)+"' And "
		cQrySC5 += " C5_EMISSAO between '"+dDataDe+"' And '"+dDataAte+"' "
		cQrySC5 += " AND C5_OK NOT IN ('OK','IN','LJ') "
		cQrySC5 += " AND C5_NOTA = ' ' "
		cQrySC5 += " OR C5_LIBEROK = 'E'"
		cQrySC5 += " AND C5_BLQ = ' ' "

		IF !Empty(cPedido)
			cQrySC5 += " and C5_NUM ='"+cPedido+"' "
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
|Função padrão Menudef|
----------------------*/

Static Function MenuDef()

	PRIVATE aRotina    := { ;
	{ "Legenda" ,"u_BLegenda"   ,0,2,0 ,.F.},; //"Pesquisa" */
	{ "Importar","u_QSDOB001"     ,0,4,0 ,Nil},; //"Alterar"
	{ "Visualizar","u_nVisPed"     ,0,2,0 ,Nil}} //"Visualizar"

Return(aRotina)

User function nVisPed()

A410Visual("SC5",SC5->(Recno()),2)

Return

/*---------------------
|Função padrão Legenda|
----------------------*/

User Function BLegenda()

	Local aLegenda := {}
	AADD(aLegenda,{"BR_BRANCO" ,"Registro sem Marcação" })
	AADD(aLegenda,{"BR_VERDE" ,"Registro Marcado" })
	AADD(aLegenda,{"BR_LARANJA" ,"Baixado Parcialmente SigaLoja" })
	AADD(aLegenda,{"BR_AZUL" ,"A definir" })

	BrwLegenda(cCadastro, "Legenda", aLegenda)

Return

/*------------------------------------------
|Função de Tratamento da barra de progresso|
-------------------------------------------*/

User Function QSDOB001()

	Private oProcess
	Private lEnd := .F.
	//incluído o parâmetro lEnd para controlar o cancelamento da janela
	oProcess := MsNewProcess():New({|lEnd| u_ImpSc5(@oProcess, @lEnd) },"Montando Array","Lendo Registros do Pedido de Vendas",.T.) 
	oProcess:Activate()
Return  

/*-----------------------------------------------------------------
|Função de Processamento                                           |
|Gera Array com as informações para executar a inclusão no Sigaloja|
|Desenvolvedo: Diogo Melo                                          |
|Data atualização: 09/05/2019                                      |
-------------------------------------------------------------------*/

User Function ImpSc5()

	Local aCabDados := {}
	Local aItensDados := {}
	Local aItePed := {}
	Local lAutomato := .F. 
	Local nCountC5
	Local nB2Saldo := 0
	Local nTotal := 0
	Local cQrySC6 := ''

	dbSelectArea("SC5")
	SC5->(dbGoTop())

	nCountC5 := SC5->(RecCount()) //Contagem registro
	oProcess:SetRegua1(nCountC5) //Total de registro

	While SC5->(!EOF()) .and. SC5->C5_FILIAL == cFilAnt

		If lEnd	
			//houve cancelamento do processo		
			Exit	
		EndIf	

		If !Empty(SC5->C5_MKOK) .AND. SC5->C5_OK $ "  |PA|"

			oProcess:IncRegua1("Lendo Pedido de Venda:" + SC5->C5_FILIAL +" | "+SC5->C5_NUM)

			aAdd(aCabDados,{/**/;
			xFilial("SC5"),/*aCabDados[1][1]*/;
			SC5->C5_NUM,   /*aCabDados[1][2]*/;
			SC5->C5_CLIENTE,/*aCabDados[1][3]*/;
			SC5->C5_LOJACLI,/*aCabDados[1][4]*/;
			SC5->C5_TIPOCLI,/*aCabDados[1][5]*/;
			SC5->C5_DESCONT,/*aCabDados[1][6]*/;
			SC5->C5_EMISSAO,/*aCabDados[1][7]*/;
			SC5->C5_CONDPAG,/*aCabDados[1][8]*/;
			SC5->C5_VEND1,/*aCabDados[1][9]*/,;
			/*SL1->LQ_NUMMOV||aCabDados[1][10]*/'01',;
			SC5->C5_P_DTRAX }) //aCabDados[1][12]
		EndIf
		SC5->(dbSkip())
	EndDo

	/*SC6
	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(dbGotop())

	nCountC6 := SC6->(RecCount())
	oProcess:SetRegua2(nCountC6)
	*/

	For nX := 1 to Len(aCabDados)

		aItensDados := {}

		cQrySC6 := " Select C6_FILIAL, C6_NUM, C6_PRODUTO, C6_QTDVEN, C6_UM, C6_PRCVEN, C6_VALOR, C6_DESCRI, C6_LOCAL, "
		cQrySC6 += " C6_DESCONT, C6_VALDESC, C6_TES, C6_ITEM, C6_QTDENT, C6_NOTA from "+ RetSQLName("SC6") + " SC6 "
		cQrySC6 += " WHERE D_E_L_E_T_ != '*' "
		cQrySC6 += " AND C6_NUM = '"+aCabDados[nX][2]+"' "
		cQrySC6 += " AND C6_FILIAL = '"+aCabDados[nX][1]+"' "
		cQrySC6 += " AND C6_CLI = '"+aCabDados[nX][3]+"'" 
		cQrySC6 += " AND C6_LOJA = '"+aCabDados[nX][4]+"' "

		cSLQry := ChangeQuery(cQrySC6)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySC6),"cQrySC6", .F., .T.)

		dbSelectArea("cQrySC6")
		nCountC6 := cQrySC6->(RecCount())
		oProcess:SetRegua2(nCountC6)

		While cQrySC6->(!eof())

			oProcess:IncRegua2("Pedido: "+ cQrySC6->C6_NUM +" | Item: "+Alltrim(cQrySC6->C6_DESCRI))

			If cQrySC6->C6_QTDENT < cQrySC6->C6_QTDVEN .and. Empty(cQrySC6->C6_NOTA)

				nB2Saldo := RetSaldo(cQrySC6->C6_FILIAL,cQrySC6->C6_PRODUTO,cQrySC6->C6_LOCAL)

				IF nB2Saldo >= cQrySC6->C6_QTDVEN

					aAdd(aItensDados,{;
					cQrySC6->C6_FILIAL,/*aItensDados[1][1]*/;
					cQrySC6->C6_NUM,/*aItensDados[1][2]*/;
					cQrySC6->C6_PRODUTO,/*aItensDados[1][3]*/;
					cQrySC6->C6_QTDVEN,/*aItensDados[1][4]*/;
					cQrySC6->C6_UM,/*aItensDados[1][5]*/;
					cQrySC6->C6_PRCVEN,/*aItensDados[1][6]*/;
					cQrySC6->C6_VALOR,/*aItensDados[1][7]*/;
					cQrySC6->C6_DESCONT,/*aItensDados[1][8]*/;
					cQrySC6->C6_VALDESC,/*aItensDados[1][9]*/;
					cQrySC6->C6_TES,/*aItensDados[1][10]*/;
					cQrySC6->C6_ITEM/*aItensDados[1][11]*/})

				Else
					nTotal := nB2Saldo*cQrySC6->C6_PRCVEN

					aAdd(aItensDados,{;
					cQrySC6->C6_FILIAL,/*aItensDados[1][1]*/;
					cQrySC6->C6_NUM,/*aItensDados[1][2]*/;
					cQrySC6->C6_PRODUTO,/*aItensDados[1][3]*/;
					nB2Saldo,/*aItensDados[1][4]*/;
					cQrySC6->C6_UM,/*aItensDados[1][5]*/;
					cQrySC6->C6_PRCVEN,/*aItensDados[1][6]*/;
					nTotal,/*aItensDados[1][7]*/;
					cQrySC6->C6_DESCONT,/*aItensDados[1][8]*/;
					cQrySC6->C6_VALDESC,/*aItensDados[1][9]*/;
					cQrySC6->C6_TES,/*aItensDados[1][10]*/;
					cQrySC6->C6_ITEM/*aItensDados[1][11]*/})

				EndIf


			Else
				Conout("O produto "+cQrySC6->C6_PRODUTO+" Foi baixado parcialmente no pedido "+cQrySC6->C6_NUM)
			EndIf

			cQrySC6->(dbSkip())
		Enddo

		aAdd(aItePed,aItensDados)
		cQrySC6->(dbCloseArea())

	Next nX

	If !lAutomato
		//FWMsgRun(, {|oSay| u_MyLOJA701(,,,aCabDados,aItensDados) }, "Processando", "Processando a rotina...")
		u_MyLOJA701(,,,aCabDados,aItePed)
	Else
		u_MyLOJA701( , ,'',aCabDados,aItePed)
	Endif   

Return (aCabDados,aItePed)

/*------------------------------------------------------
|Consulta posição do estoque para importar apenas o que |
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

	Local _aCab := {} //Array do Cabeçalho do Orçamento
	Local _aItem := {} //Array dos Itens do Orçamento
	Local _aParcelas := {} //Array das Parcelas do Orçamento
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
	Private lMsErroAuto := .F. //Variavel que informa a ocorrência de erros no ExecAuto
	//Private INCLUI := .T. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão
	//Private ALTERA := .F. //Variavel necessária para o ExecAuto identificar que se trata de uma inclusão

	If lAutomato
		PREPARE ENVIRONMENT EMPRESA _cEmpresa FILIAL _cFilial MODULO "LOJA"
	EndIf

	//Indica inclusão
	lMsHelpAuto := .T.
	lMsErroAuto := .F.

	//Retorna o tamanho dos campos
	nTamProd   := TamSX3("LR_PRODUTO")[1]
	nTamUM     := TamSX3("LR_UM")[1]
	nTamTabela := TamSX3("LR_TABELA")[1]

	//Tabela de Preço
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
			lTemSL1 := BuscaSL1(cFilAnt,aCabDados[nX][2]) //Executa validação para inclusão

			If !lTemSL1
				_cVendedor := If(Empty(aCabDados[nX][9]),"1",aCabDados[nX][9]) //Codigo do Vendedor

				//Acerta o tamanho do codigo o Vendedor
				_cVendedor := StrZero(val(_cVendedor),TamSX3("A3_COD")[1])

				//***********************************
				// Monta cabeçalho do orçamento (SL2)
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
				// Monta Itens do orçamento (SL1)
				//***********************************
				_aItem := {} //Array dos Itens do Orçamento
				_aParcelas := {} //Array das Parcelas do Orçamento
				//----------
				// Item 01
				//----------
				If Len(aItePed) > 0

					nValTotal := 0 //Tratamento da condição de pagamento

					For nY := 1 to Len(aItePed)

						For nZ:= 1 to Len(aItePed[nY])

							If aCabDados[nX][1] == aItePed[nY][nZ][1] .and. aCabDados[nX][2] == aItePed[nY][nZ][2]

								If cReserva == '1'
									nLRTotal := aItePed[nY][nZ][4] * aItePed[nY][nZ][7]
									aAdd( _aItem, {} )
									aAdd( _aItem[Len(_aItem)], {"LR_ITEM", aItePed[nY][nZ][11] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_PRODUTO", PadR(aItePed[nY][nZ][3],nTamProd) , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_QUANT" , aItePed[nY][nZ][4] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VRUNIT" , aItePed[nY][nZ][7] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VRLRITEM" , nLRTotal , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_UM" , PadR(aItePed[nY][nZ][5],nTamUM) , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_DESC" , aItePed[nY][nZ][8] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VALDESC", aItePed[nY][nZ][9] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_TABELA" , PadR("1",nTamTabela) , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_DESCPRO", 0 , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VEND" , _cVendedor , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_ENTREGA", "3" , NIL} ) 
									aAdd( _aItem[Len(_aItem)], {"LR_PEDIDO", aItePed[nY][nZ][2] , NIL} ) 
									//3=Entrega (Qdo. informado o LR_ENTREGA = 3, deve ser informado também o campo "AUTRESERVA" no array de Cabecalho)

									//SB0->(MsSeek(xFilial("SL2")+aItensDados[nY][3]))
									//nValTotal += SB0->B0_PRV1

									//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
									SC6->(MsSeek(xFilial("SC6")+aCabDados[nX][2]+aItePed[nY][nZ][11]+PadR(aItePed[nY][nZ][3],nTamProd))) 
									nValTotal += SC6->C6_PRCVEN
								Else
									//----------
									// Item 02
									//----------
									nLRTotal := aItePed[nY][nZ][4] * aItePed[nY][nZ][7]
									aAdd( _aItem, {} )
									aAdd( _aItem[Len(_aItem)], {"LR_ITEM", aItePed[nY][nZ][11] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_PRODUTO", PadR(aItePed[nY][nZ][3],nTamProd) , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_QUANT" , aItePed[nY][nZ][4] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VRUNIT" , aItePed[nY][nZ][7] , NIL} )
									aAdd( _aItem[Len(_aItem)], {"LR_VRLRITEM" , nLRTotal , NIL} )
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
					aAdd( _aParcelas[Len(_aParcelas)], {"L4_FORMA" , "CC " , NIL} )
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

		If lAutomato
			RESET ENVIRONMENT
		EndIf
	Endif //Tratamento de validação SL1

Return

/*--------------------------
|Busca SL1                  |
|Desenvolvedor Diogo Melo   |
|Data: 15/05/2019           |
----------------------------*/

Static Function  BuscaSL1(cFil,cNumPv) //Executa validação para inclusão

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