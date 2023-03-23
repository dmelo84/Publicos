#Include 'Protheus.ch'
#Include "FwMvcDef.ch"

#Define _RTBIOSTA 1
#Define _RTBIODAT 2
#Define _RTBIOMSG 3

Static lTipMark 	:= .T.  //Variavel statica de todos marcados/desmarcados

/*/{Protheus.doc} FSCOMP02
Tela de Retorno/Cancelmento envio Bionexo

@type function
@author claudiol
@since 24/12/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function FSCOMP02()

Local aAreOld	:= {SC1->(GetArea()),GetArea()}

Local oLayer		:= Nil
Local oDlgManut	:= Nil

Local cAliasTmp	:= GetNextAlias()
Local aSize		:= FWGetDialogSize( oMainWnd )

Local aQrySCs		:= {}

Local bAcaoAtu	:= { || aQrySCs := FMntQry(), FAtuBrw( oBrwList, aQrySCs[1] ) }
Local bAcaoLim	:= { || FLimFil() }
Local bAcaoExp	:= { || oProcess := MsNewProcess():New({|lEnd| FGerExp(oBrwList)},OemToAnsi("Processando"),OemToAnsi("Retornando PDC (BIONEXO). Aguarde..."),.F.), oProcess:Activate() }
Local bAcaoCan	:= { || oProcess := MsNewProcess():New({|lEnd| FGerExp(oBrwList,.T.)},OemToAnsi("Processando"),OemToAnsi("Cancelando Envio PDC (BIONEXO). Aguarde..."),.F.), oProcess:Activate() }

//Private aRotina 	:= MenuDef()	// Monta menu da Browse
Private cCadastro	:= "PDC´s em Aberto"
Private oBrwList	:= Nil
Private oDialog	:= Nil
Private oProcess	:= Nil

Private cGetSCDe  := Criavar("C1_XNUMPDC",.F.)
Private cGetSCAte := Criavar("C1_XNUMPDC",.F.)
Private cGetCatBio:= Criavar("Z2_CODIGO",.F.)

Private cMensLog	:= ""

SetPrvt("oScroll","oFont1","oGrpFiltro","oSaySCDe","oSaySCAte","oSayCatBio","oSay1","oGetSCDe","oGetSCAte")
SetPrvt("oBtnFil","oBtnLim")


//Executa bloco de codigo para inicializar as variaveis de filtro
Eval(bAcaoLim)

//Monta query
aQrySCs:= FMntQry()


//Tela de selecao
oDialog := MsDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , , , , , oMainWnd, .T. )

	oLayer := FWLayer():New()
	oLayer:Init( oDialog, .F.)
	
	oLayer:AddLine( 'Linha', 100)
	oLayer:AddColumn( 'Coluna', 100, .T., 'Linha' )
	oLayer:AddWindow( 'Coluna', 'oDlgManut', cCadastro, 100, .F., .F., {||}, 'Linha' )
	oDlgManut := oLayer:GetWinPanel( 'Coluna', 'oDlgManut', 'Linha' )

	// Cria objeto Scroll
	oScroll := TScrollArea():New(oDlgManut,01,01,oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.20 ,.T.,.T.,.T.)
	oScroll:Align := CONTROL_ALIGN_TOP

	//PanelTop
	oPanelTop 	:= TPanel():New( 0, 0, '', oScroll,,,,,, oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.20 )
	oPanelTop:Align := CONTROL_ALIGN_TOP

	// Define objeto painel como filho do scroll
	oScroll:SetFrame( oPanelTop )

	oFont1     := TFont():New( "MS Sans Serif",0,-11,,.T.,0,,700,.F.,.F.,,,,,, )

	oGrpFiltro := TGroup():New( 004,aSize[2],052,aSize[4],"Filtro",oPanelTop,CLR_BLACK,CLR_WHITE,.T.,.F. )

	oSaySCDe   := TSay():New( 013,013,{||"Pedido de Compra Bionexo (PDC):"},oGrpFiltro,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,087,009)
	oSaySCAte  := TSay():New( 013,149,{||"Até"},oGrpFiltro,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
	oSayCatBio := TSay():New( 027,013,{||"Categoria Bionexo:"},oGrpFiltro,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,067,008)
	oSay1      := TSay():New( 042,013,{||"Se não informado filtro, considera todos em aberto."},oGrpFiltro,,oFont1,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,160,008)
	
	oGetSCDe   := TGet():New( 011,102,{|u| If(PCount()>0,cGetSCDe:=u,cGetSCDe)},oGrpFiltro,041,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"cGetSCDe",,)
	oGetSCAte  := TGet():New( 012,167,{|u| If(PCount()>0,cGetSCAte:=u,cGetSCAte)},oGrpFiltro,040,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,,"cGetSCAte",,)
	oGetCatBio := TGet():New( 026,102,{|u| If(PCount()>0,cGetCatBio:=u,cGetCatBio)},oGrpFiltro,041,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SZ2","cGetCatBio",,)

	oBtnLim    := TButton():New( 036,212,"Limpar",oGrpFiltro,bAcaoLim,044,012,,,,.T.,,"Limpa os filtros informados!",,,,.F. )
	oBtnFil    := TButton():New( 036,260,"Filtrar",oGrpFiltro,bAcaoAtu,044,012,,,,.T.,,"Executa filtro dos dados!",,,,.F. )

	
	//PanelBot
	oPanelBot 	:= TPanel():New( 0, 0, '', oDlgManut,,,,,, oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.80 )
	oPanelBot:Align := CONTROL_ALIGN_BOTTOM

	//Browse
	oBrwList := FWFormBrowse():New()
	oBrwList:SetOwner( oPanelBot )
	oBrwList:AddMarkColumns( { || IIf( (cAliasTmp)->C1_OK == 1, "LBOK", "LBNO" ) }, { || IIf( (cAliasTmp)->C1_OK == 0,(cAliasTmp)->C1_OK := 1, (cAliasTmp)->C1_OK := 0 ) } )
	oBrwList:SetDataQuery(.T.)
	oBrwList:SetQuery( aQrySCs[1] )
	oBrwList:SetAlias( cAliasTmp )
	oBrwList:SetColumns( aQrySCs[2] )
	oBrwList:SetUseFilter( .T. )
	oBrwList:DisableConfig()
	oBrwList:DisableReport()
	oBrwList:DisableDetails()

	oBrwList:AddButton( "Confirmar", { || FConfirma(bAcaoExp,bAcaoAtu,oBrwList) },,3,, .F., 2 )
	oBrwList:AddButton( "Cancelar Envio", { || FConfirma(bAcaoCan,bAcaoAtu,oBrwList,.T.)},,2,, .F., 2 )
	oBrwList:AddButton( "Sair", { || oDialog:End() },,2,, .F., 2 )

	oBrwList:aColumns[1]:bHeaderClick := {|| FMrkAll( oBrwList ) }
	oBrwList:SetDoubleClick( {|| FMrkOne( oBrwList ) } )
	oBrwList:Activate()	
	
oDialog:Activate( ,,,.T.,,, )


aEval(aAreOld, {|xAux| RestArea(xAux)})

Return


/*/{Protheus.doc} FConfirma
Confirma execução para os registros marcados

@author claudiol
@since 23/12/2015
@version undefined

@type function
/*/
Static Function FConfirma(bAcaoExp,bAcaoAtu,oObjMark,lCancel)

Local cMsgAux	:= ""
Local cAliTmp	:= ""
Local nQtdReg	:= 0
Local lConfirm	:= .T.

Default lCancel:= .F.

//Valida itens marcados
cAliTmp := oObjMark:cAlias

//Verifica quantidade de registros marcados
(cAliTmp)->(dbEval({|| Iif((cAliTmp)->C1_OK==1,nQtdReg++,Nil)}))

If (cAliTmp)->(Reccount())==0
	cMsgAux:= "Não existem registros a processar. Verifique!"
ElseIf Empty(nQtdReg)
	cMsgAux:= "Não existem itens marcados. Verifique!"
EndIf

If Empty(cMsgAux)
	If lCancel
		cMsgAux:= "O cancelamento do envio somente limpa o status de envio para o Bionexo." + CRLF
		cMsgAux+= "O cancelamento no Portal Bionexo deverá ser efetuado de forma MANUAL."  + CRLF  + CRLF
		cMsgAux+= "Confirma Cancelamento de Envio?"
		lConfirm:= ApMsgNoYes(cMsgAux,".:Confirmação:.")
	EndIf
	
	If lConfirm
		Eval(bAcaoExp)
		Eval(bAcaoAtu)
	EndIf
Else
	ApMsgStop(cMsgAux,".:Atenção:.")
EndIf

(cAliTmp)->(DbGoTop())

Return


/*/{Protheus.doc} FAtuBrw
Atualiza o objeto Browse com a Query recebida.

@author claudiol
@since 24/12/2015
@version 1.0
@param oBrowse, objeto, Objeto do tipo FWBrowse
@param cQuery, character, Consulta SQL para atualizar a Browse
@example FAtuBrw( oBrowse, cQuery )
/*/
Static Function FAtuBrw( oBrowse, cQuery )

Local lRet	:= .T.

oBrowse:Data():DeActivate()
oBrowse:SetQuery( cQuery )
oBrowse:Data():Activate()
oBrowse:UpdateBrowse(.T.)
oBrowse:GoBottom()
oBrowse:GoTo(1, .T.)
oBrowse:Refresh(.T.)

lTipMark := .T.

Return lRet


/*/{Protheus.doc} FMntQry
Monta a query dos dados a serem apresentados

@author claudiol
@since 24/12/2015
@version 1.0
@return aRet, [1] cQuery - Consulta no padrao SQL 	[2] aCampos - Estrutura dos campos da consulta
@example  FMntQry()
/*/
Static Function FMntQry()

Local aArea		:= GetArea()
Local cQuery		:= ''
Local aColumns	:= {}
Local aRet			:= {}
Local aArrAux	 	:= {}
Local aCampos		:= {}
Local aNoFields 	:= {}
Local nXi			:= 0
Local nXj			:= 0
Local cGrupo		:= ""

//Campos utilizados
//Campo C1_OK e inicializado com valor default na query
AAdd( aCampos, 'C1_XNUMPDC' )
AAdd( aCampos, 'C1_XTIPPDC' )
AAdd( aCampos, 'Z3_DESCRIC' )
AAdd( aCampos, 'C1_XDATVEN' )
AAdd( aCampos, 'C1_XHORVEN' )

// Campos não visualizados na Browse
AAdd( aNoFields, 'C1_OK' )

// Monta consulta de dados da grid
cQuery := "SELECT DISTINCT "

//Carrega campos que a consulta deve retornar
For nXi := 1 To Len(aCampos)
	cQuery += Iif(nXi > 1, ', ', '')
	cQuery += aCampos[nXi]
Next nXi

cQuery += ", 0 AS C1_OK"
cQuery += " FROM " + RetSQLName("SC1") + " SC1"
cQuery += " JOIN " + RetSQLName("SB1") + " SB1"
cQuery +=    	" ON  SC1.C1_PRODUTO = SB1.B1_COD"
cQuery +=    	" AND SB1.D_E_L_E_T_ <> '*' "
cQuery +=    	" AND SB1.B1_FILIAL='"+xFilial("SB1")+"'"
cQuery += " LEFT OUTER JOIN " + RetSQLName("SZ3") + " SZ3"
cQuery +=    	" ON  SC1.C1_XTIPPDC = SZ3.Z3_CODIGO"
cQuery +=    	" AND SZ3.D_E_L_E_T_ <> '*' "
cQuery +=    	" AND SZ3.Z3_FILIAL='"+xFilial("SZ3")+"'"
cQuery += " JOIN " + RetSQLName("SBM") + " SBM"
cQuery +=    	" ON  SBM.BM_GRUPO = SB1.B1_GRUPO"
cQuery +=    	" AND SBM.D_E_L_E_T_ <> '*' "
cQuery +=    	" AND SBM.BM_FILIAL='"+xFilial("SBM")+"'"
cQuery += " WHERE SC1.D_E_L_E_T_ <> '*' "
cQuery += 		" AND SC1.C1_FILIAL = '"+xFilial("SC1")+"'"

//Filtros Bionexo
cQuery += 		" AND SC1.C1_XSTABIO ='1'" //1=Enviado
cQuery += 		" AND SC1.C1_XNUMPDC <> ' '" //Numero PDC Bionexo

If !Empty(cGetSCDe) .Or. !Empty(cGetSCAte)
	cQuery += " AND ( C1_XNUMPDC >= '" + cGetSCDe + "' AND C1_XNUMPDC <= '" + cGetSCAte + "' )"
EndIf

//Tratamento Categoria
If !Empty(cGetCatBio)
	cGrupo:= SuperGetMv("ES_BIOCAT",.F.,"")
	If (cGetCatBio $ cGrupo)
		//Separa os agrupamentos 
	 	aAgrup:= StrToKarr(cGrupo,";")
	 	//Separa os grupos
	 	For nXi:= 1 To Len(aAgrup)
	 		If (cGetCatBio $ aAgrup[nXi])
				cQuery += " AND SBM.BM_XCATBIO IN '"+ FormatIn(AllTrim(aAgrup[nXi]),"-") +"'"
				Exit
			EndIf
		Next nXi
	Else
		cQuery += " AND SBM.BM_XCATBIO = '"+ cGetCatBio +"'" 
	EndIf
EndIf

//Tratamento para caso tenha gerado mais de um pedido de compra e for cancelado somente um 
//nao permitir o retorno
cQuery += "AND ("
cQuery += "SELECT COUNT(SC1X.C1_XNUMPDC) "
cQuery += "FROM " + RetSQLName("SC1") + " SC1X "
cQuery += "WHERE SC1X.D_E_L_E_T_ <> '*' "
cQuery += 		"AND SC1X.C1_FILIAL = '"+xFilial("SC1")+"'"
cQuery += 		"AND SC1X.C1_XNUMPDC = SC1.C1_XNUMPDC "
cQuery += 		"AND SC1X.C1_XSTABIO NOT IN ('1','3')"
cQuery += 		") = 0 "

//Ordenação da Query
cQuery += "ORDER BY SC1.C1_XNUMPDC "

// Cria estrutura dos campos da grid
AAdd( aCampos, 'C1_OK' )

nXj := 1
For nXi := 1 To Len(aCampos)
	If ( AScan( aNoFields, aCampos[nXi] ) == 0 )
		
		aArrAux := U_FSRetSX3(aCampos[nXi])
		
		AAdd( aColumns, FWBrwColumn():New() )
		If ( aCampos[nXi] $( 'C1_XDATVEN|' ) )
			aColumns[nXj]:SetData( &("{||SToD(" + aCampos[nXi] + ")}") )
		Else
			aColumns[nXj]:SetData( &("{||" + aCampos[nXi] + "}") )
		EndIf	
		aColumns[nXj]:SetTitle( aArrAux[1] )
		aColumns[nXj]:SetSize( aArrAux[3] )
		aColumns[nXj]:SetDecimal( aArrAux[4] )
		aColumns[nXj]:SetPicture( aArrAux[5] )
		nXj++
	EndIf
Next nXi

//Retorna query e colunas do grid
AAdd( aRet, cQuery )
AAdd( aRet, aColumns )

RestArea( aArea )

Return aRet


/*/{Protheus.doc} FMrkAll
Marca os registros da tabela temporária quando ocorrer o clique no header do
campo de flag

@author claudiol
@since 24/12/2015
@version 1.0
@param oObjMark, objeto, Objeto da classe FwFormBrowse para identificação do Alias e	Atualização da interface
@example FMrkAll( oMarkABB )
/*/
Static Function FMrkAll( oObjMark )

Local cAliTmp 	:= ''
Local nTipMark:= If( lTipMark, 1, 0 )

Default oObjMark := Nil

If oObjMark <> Nil
	cAliTmp := oObjMark:cAlias
	(cAliTmp)->(DbGoTop())
	While (cAliTmp)->(!Eof())
		(cAliTmp)->C1_OK := nTipMark
		(cAliTmp)->(DbSkip())
	End
	(cAliTmp)->(DbGoTop())

	//Tratamento para forçar refresh
	//metodo refresh do objeto limpa campo de marca
	oObjMark:GoBottom()
	oObjMark:GoTop(.T.)

	//Atualiza variavel statica de controle de todos marcados/desmarcados
	lTipMark := !lTipMark
EndIf

Return


/*/{Protheus.doc} FMrkOne
Marca o registro posicionado quando realizar enter ou duplo clique na linha

@author claudiol
@since 24/12/2015
@version 1.0
@param oObjMark, objeto, Objeto da classe FwFormBrowse para identificação do Alias e	Atualização da interface
@example
FMrkOne( oMarkABB )
/*/
Static Function FMrkOne( oObjMark )

Local cAliTmp := ''

Default oObjMark := Nil

If oObjMark <> Nil
	cAliTmp := oObjMark:cAlias
	If (cAliTmp)->C1_OK == 1
		(cAliTmp)->C1_OK := 0
	Else
		(cAliTmp)->C1_OK := 1
	EndIf
EndIf

Return


/*/{Protheus.doc} FLimFil
Limpa filtros informados

@author claudiol
@since 24/12/2015
@version 1.0
@example FlimFil()
/*/
Static Function FLimFil() 

cGetSCDe  := Criavar("C1_XNUMPDC",.F.)
cGetSCAte := Criavar("C1_XNUMPDC",.F.)
cGetCatBio:= Criavar("Z2_CODIGO",.F.)

//Atualiza objeto atual
GetdRefresh()

Return


/*/{Protheus.doc} FGerExp
Gera Delivery PDC

@author claudiol
@since 24/12/2015
@version 1.0
@param oObjMark, objeto, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function FGerExp(oObjMark, lCancel)

Local aAreOld		:= {SC1->(GetArea()),GetArea()}
Local cAliTmp 		:= ''
Local lRet			:= .T.
Local nQtdReg		:= 0
Local nXi			:= 0
Local aFornece		:= {}
Local aItensPDC	:= {}
Local aRecSC1		:= {}
Local aRecAll		:= {}
Local aRecNok		:= {}								

Default oObjMark 	:= Nil
Default lCancel	:= .F.

If oObjMark <> Nil
	cAliTmp := oObjMark:cAlias

	//Verifica quantidade de registros marcados
	(cAliTmp)->(dbEval({|| Iif((cAliTmp)->C1_OK==1,nQtdReg++,Nil)}))

	If !Empty(nQtdReg)
		//Processa registros marcados
		oProcess:SetRegua1(nQtdReg)

		(cAliTmp)->(DbGoTop())
		While (cAliTmp)->(!Eof())

			If (cAliTmp)->C1_OK == 1  //Se marcado

				oProcess:IncRegua1(OemToAnsi("Processando PDC: "+(cAliTmp)->C1_XNUMPDC))
				
				cMensLog+= "=> PDC: " + (cAliTmp)->C1_XNUMPDC + CRLF

				//Inicializa variaveis
				aFornece		:= {}
				aItensPDC	:= {}
				aRecSC1		:= {}

				If !lCancel

					oProcess:SetRegua2(4)
					oProcess:IncRegua2("Buscando PDC!")

					//Retorna PDC
					aRet:= U_FSRetPDC((cAliTmp)->C1_XNUMPDC)
		
					If aRet[_RTBIOSTA] == "1" //-1=Erro; 0=Sem Dados;1=Ok
	
						BeginTran()
		
							//Busca itens ganhadores
							oProcess:IncRegua2("Verificando Fornecedores Ganhadores!")
							If (lRet:= U_FSItensOK(aRet[_RTBIOMSG],aFornece,aItensPDC,@cMensLog))
								lRet:= U_FSRetFor(aFornece,@cMensLog)
							EndIf
		
							oProcess:IncRegua2("Criando Pedido(s) de Compra!")
							If lRet
								lRet:= U_FSGerPDC(aItensPDC,aRecSC1,@cMensLog)
							EndIf
			
							oProcess:IncRegua2("Atualizando Solicitações de Compra do PDC!")
							If lRet
								//Grava historico, status e numero PDC
								aRet:= {"0", Dtoc(Date())+" "+Time(), (cAliTmp)->C1_XNUMPDC}
								U_FSGrvSC1("R", aRecSC1, aRet, Nil, Nil, @cMensLog)
	
								//Carrega todas as SCs do PDC
								aRecAll:= {}
								aRecNok:= {}								
								U_FSBusSC1((cAliTmp)->C1_XNUMPDC, aRecAll)
								//Verifica SCs sem retorno
								For nXi:= 1 To Len(aRecAll)
									If aScan(aRecSC1, aRecAll[nXi]) == 0
										Aadd(aRecNok, aRecAll[nXi])
									EndIf
								Next nXi

								//Grava historico, status e numero PDC
								If !Empty(aRecNOk)
									U_FSGrvSC1("R", aRecNok, aRet, Nil, " Item nao foi selecionado.", @cMensLog)
								EndIf
							EndIf
		
							If lRet
								cMensLog+= "Processado com Sucesso." + CRLF
								//Efetiva transacao
								EndTran()
							Else
								//Disarmo a transação
								DisarmTransaction ()
							EndIF
						
						MsUnlockAll()
		
					Else
						//Monta mensagem de log
						If aRet[_RTBIOSTA] == "0" //-1=Erro; 0=Sem Dados;1=Ok
							cMensLog+= "Não existe retorno." + CRLF
						Else
							cMensLog+= aRet[_RTBIOMSG] + CRLF
						EndIf
	
					EndIf
	
				Else

					oProcess:SetRegua2(2)
					oProcess:IncRegua2("Solicitações de Compra do PDC!")

					BeginTran()

						//Carrega todos as SCs do PDC
						If (lRet:= U_FSBusSC1((cAliTmp)->C1_XNUMPDC, aRecSC1, @cMensLog))
	
							oProcess:IncRegua2("Atualizando Solicitações de Compra do PDC!")
	
							aRet:= {"0", Dtoc(Date())+" "+Time(), (cAliTmp)->C1_XNUMPDC}
							U_FSGrvSC1("C", aRecSC1, aRet)
						EndIf

						If lRet
							cMensLog+= "Processado com Sucesso." + CRLF
							//Efetiva transacao
							EndTran()
						Else
							//Disarmo a transação
							DisarmTransaction ()
						EndIF
					
					MsUnlockAll()
				
				EndIf

				cMensLog+= Replicate("=",70) + CRLF

			EndIf

			(cAliTmp)->(DbSkip())

		EndDo

		//Atualiza variavel statica de controle de todos marcados/desmarcados
		lTipMark := .T.
		
		//Janela com ocorrencias
		If !Empty(cMensLog)
			U_FSMosTxt(,cMensLog)
			cMensLog:= ""
		EndIf
		
	Else
		ApMsgAlert("Não existem itens marcados!",".:Atenção:.")		
	EndIf
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return
