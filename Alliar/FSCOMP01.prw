#Include 'Protheus.ch'
#Include "FwMvcDef.ch"

#Define _RTBIOSTA 1
#Define _RTBIODAT 2
#Define _RTBIOMSG 3

Static lTipMark 	:= .T.  //Variavel statica de todos marcados/desmarcados

/*/{Protheus.doc} FSCOMP01
Tela de Envio de Solicitações de Compra para Bionexo

@type function
@author claudiol
@since 17/12/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function FSCOMP01()

Local aAreOld	:= {SC1->(GetArea()),GetArea()}

Local oLayer		:= Nil
Local oPanel		:= Nil
Local oDlgManut	:= Nil
Local oBtnAtu		:= Nil

Local cAliasTmp	:= GetNextAlias()
Local aSize		:= FWGetDialogSize( oMainWnd )

Local aQrySCs		:= {}

Local bAcaoAtu	:= { || aQrySCs := FMntQry(), FAtuBrw( oBrwList, aQrySCs[1] ) }
Local bAcaoLim	:= { || FLimFil() }
Local bAcaoExp	:= { || oProcess := MsNewProcess():New({|lEnd| FGerExp(oBrwList)},OemToAnsi("Processando"),OemToAnsi("Enviando Bionexo. Aguarde..."),.F.), oProcess:Activate() }

//Private aRotina 	:= MenuDef()	// Monta menu da Browse
Private cCadastro	:= "Solicitações de Compra a Enviar para BIONEXO"
Private oBrwList	:= Nil
Private oDialog	:= Nil
Private oProcess	:= Nil

Private cGetTipCot:= Space(4)
Private cGetConPag:= Criavar("E4_CODIGO",.F.)
Private dGetDatVen:= CtoD(" ")
Private cGetHorVen:= Space(8)
Private cMGObs	:= ""

Private cGetSCDe  := Criavar("C1_NUM",.F.)
Private cGetSCAte := Criavar("C1_NUM",.F.)
Private dGetEmiDe := CtoD(" ")
Private dGetEmiAte:= CtoD(" ")
Private cGetCatBio:= Criavar("Z2_CODIGO",.F.)
Private cCBAgrup	:= "Não"  

SetPrvt("oDialog","oScroll","oGrpDados","oSayTipCot","oSayConPag","oSayHorVen","oSayDatVen","oSayObs","oGetConPag")
SetPrvt("oGetDatVen","oMGObs","oGetTipCot","oGrpFiltro","oSaySCDe","oSaySCAte","oSayEmiAte","oSayEmiDe")
SetPrvt("oSayCatBio","oGetSCDe","oGetSCAte","oGetEmiAte","oGetEmiDe","oGetCatBio","oBtnFil","oBtnLim")

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
	oScroll := TScrollArea():New(oDlgManut,01,01,oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.32 ,.T.,.T.,.T.)
	oScroll:Align := CONTROL_ALIGN_TOP

	//PanelTop
	oPanelTop 	:= TPanel():New( 0, 0, '', oScroll,,,,,, oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.32 )
	oPanelTop:Align := CONTROL_ALIGN_TOP

	// Define objeto painel como filho do scroll
	oScroll:SetFrame( oPanelTop )

	oGrpDados  := TGroup():New( 004,aSize[2],040,aSize[4],"Dados PDC",oPanelTop,CLR_BLACK,CLR_WHITE,.T.,.F. )

	oSayTipCot := TSay():New( 012,013,{||"Tipo de Cotação"},oGrpDados,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,039,008)
	oGetTipCot := TGet():New( 010,062,{|u| If(PCount()>0,cGetTipCot:=u,cGetTipCot)},oGrpDados,040,008,'',{||Vazio() .Or. ExistCpo("SZ3",cGetTipCot)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SZ3","cGetTipCot",,)

	oSayConPag := TSay():New( 013,109,{||"Condição de Pagamento"},oGrpDados,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,059,008)
	oGetConPag := TGet():New( 012,171,{|u| If(PCount()>0,cGetConPag:=u,cGetConPag)},oGrpDados,040,008,'',{||Vazio() .Or. ExistCpo("SE4",cGetConPag) .And. FVldConPag(cGetConPag)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SE4","cGetConPag",,)

	oSayDatVen := TSay():New( 023,013,{||"Data de Vencimento"},oGrpDados,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,051,008)
	oGetDatVen := TGet():New( 022,062,{|u| If(PCount()>0,dGetDatVen:=u,dGetDatVen)},oGrpDados,041,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGetDatVen",,)

	oSayHorVen := TSay():New( 024,109,{||"Hora de Vencimento"},oGrpDados,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,051,008)
	oGetHorVen := TGet():New( 023,171,{|u| If(PCount()>0,cGetHorVen:=u,cGetHorVen)},oGrpDados,040,008,'99:99',{||Vazio() .Or. StrHora(cGetHorVen)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGetHorVen",,)

	oSayObs    := TSay():New( 007,217,{||"Observação"},oGrpDados,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,038,008)
	oMGObs     := TMultiGet():New( 016,216,{|u| If(PCount()>0,cMGObs:=u,cMGObs)},oGrpDados,143,017,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
	

	oGrpFiltro := TGroup():New( 040,aSize[2],84,aSize[4],"Filtro",oPanelTop,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSaySCDe   := TSay():New( 048,013,{||"Solicitação de Compra"},oGrpFiltro,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,055,008)
	oGetSCDe   := TGet():New( 047,074,{|u| If(PCount()>0,cGetSCDe:=u,cGetSCDe)},oGrpFiltro,041,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SC1","cGetSCDe",,)

	oSaySCAte  := TSay():New( 049,121,{||"Até"},oGrpFiltro,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
	oGetSCAte  := TGet():New( 048,139,{|u| If(PCount()>0,cGetSCAte:=u,cGetSCAte)},oGrpFiltro,040,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SC1","cGetSCAte",,)

	oSayEmiDe  := TSay():New( 060,013,{||"Data de Emissão"},oGrpFiltro,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,051,008)
	oGetEmiDe  := TGet():New( 059,074,{|u| If(PCount()>0,dGetEmiDe:=u,dGetEmiDe)},oGrpFiltro,041,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGetEmiDe",,)

	oSayEmiAte := TSay():New( 060,117,{||"Até"},oGrpFiltro,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
	oGetEmiAte := TGet():New( 059,139,{|u| If(PCount()>0,dGetEmiAte:=u,dGetEmiAte)},oGrpFiltro,040,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","dGetEmiAte",,)

	oSayCatBio := TSay():New( 071,013,{||"Categoria"},oGrpFiltro,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,038,008)
	oGetCatBio := TGet():New( 070,074,{|u| If(PCount()>0,cGetCatBio:=u,cGetCatBio)},oGrpFiltro,041,008,'',{||Vazio() .Or. ExistCpo("SZ2",cGetCatBio)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SZ2","cGetCatBio",,)

	oSayAgrup  := TSay():New( 072,121,{||"Considera Agrupamento"},oGrpFiltro,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,063,008)
	oCBAgrup   := TComboBox():New( 070,188,{|u| If(PCount()>0,cCBAgrup:=u,cCBAgrup)},{"Sim","Não"},040,010,oGrpFiltro,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cCBAgrup )


	oBtnLim    := TButton():New( 068,264,"Limpar",oGrpFiltro,bAcaoLim,044,012,,,,.T.,,"Limpa os filtros informados!",,,,.F. )
	oBtnFil    := TButton():New( 068,312,"Filtrar",oGrpFiltro,bAcaoAtu,044,012,,,,.T.,,"Executa filtro dos dados!",,,,.F. )

	
	//PanelBot
	oPanelBot 	:= TPanel():New( 0, 0, '', oDlgManut,,,,,, oDlgManut:nWidth, ( oDlgManut:nHeight / 2 ) * 0.68 )	
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
//	oBrwList:DisableDetails()
	oBrwList:SetEditDetail( .T. )
//	oBrwList: SetEditDetail ( [ lEditDetail], [ oModel] ) 

	oBrwList:AddButton( "Visualizar Solicitação", { || FVisSol(oBrwList)},,2,, .F., 2 )
	oBrwList:AddButton( "Confirmar", { || FConfirma(bAcaoExp,bAcaoAtu,oBrwList) },,3,, .F., 2 )
//	oBrwList:AddButton( "Informa Marca", SetKey ( VK_F10, {||  FMarca(oBrwList) } ),,3,, .F., 2 )
	oBrwList:AddButton( "Informa Marca", {||  FMarca(oBrwList) } ,,3,, .F., 2 )
	oBrwList:AddButton( "Sair", { || oDialog:End() },,2,, .F., 2 )
	
//	SetKey ( VK_F10, {||  FMarca(oBrwList) } )

	oBrwList:aColumns[1]:bHeaderClick := {|| FMrkAll( oBrwList ) }
	oBrwList:SetDoubleClick( {|| FMrkOne( oBrwList ) } )

	oBrwList:bCustomLDBLClick:= {|| FMrkOne( oBrwList ) }

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
Static Function FConfirma(bAcaoExp,bAcaoAtu,oObjMark)

Local cMsgAux	:= ""
Local cAliTmp	:= oObjMark:cAlias
Local nXi		:= 0
Local aRegMar	:= {}

If (cAliTmp)->(Reccount())==0
	cMsgAux:= "Não existem registros a processar. Verifique!"
EndIf

//Valida campos obrigatórios
If Empty(cMsgAux)
	If Empty(cGetTipCot)
		cMsgAux:= "É obrigatório informar o tipo de cotação. Verifique!"
	ElseIf Empty(cGetConPag)
		cMsgAux:= "É obrigatório informar a condição de pagamento. Verifique!"
	ElseIf Empty(dGetDatVen)
		cMsgAux:= "É obrigatório informar a data de vencimento. Verifique!"
	ElseIf Empty(cGetHorVen)
		cMsgAux:= "É obrigatório informar a hora de vencimento. Verifique!"
	EndIf
EndIf

//Valida itens marcados
If Empty(cMsgAux)
	aRegMar:= {}
	//Verifica quantidade de registros marcados
	(cAliTmp)->(dbEval({|| Iif((cAliTmp)->C1_OK==1,Aadd(aRegMar,(cAliTmp)->C1RECNO),Nil)}))

	If Empty(Len(aRegMar))
		cMsgAux:= "Não existem itens marcados. Verifique!"
	EndIf
EndIf 

If Empty(cMsgAux)
	Eval(bAcaoExp)
Else
	ApMsgStop(cMsgAux,".:Atenção:.")
EndIf

Eval(bAcaoAtu)

Return

/*/{Protheus.doc} FMarca
Realiza a inclusão de Marca na SC
@author Jonatas Oliveira | www.compila.com.br
@since 28/01/2019
@version 1.0
/*/
Static Function FMarca(oObjMark)

Local aAreOld	:= {SC1->(GetArea()),GetArea()}
Local cAlias	:= "SC1"
Local cCadAux	:= cCadastro
Local cAliTmp 	:= ''
Local cMarca	:= SPACE(50)
Local aParam1	:= {}
Local bOkParam	:=  {|| .T. }

Default oObjMark := Nil

If oObjMark <> Nil
	cAliTmp := oObjMark:cAlias
	
	If !Empty((cAliTmp)->C1RECNO)
//		Private cCadastro:= "Solicitação de Compra - VISUALIZA"
		
		dbSelectArea(cAlias)
		(cAlias)->(dbGoto((cAliTmp)->C1RECNO))
		
		If	ParamBox( {	{1,"Informe a Marca",cMarca,"@x","","","",,.F.} },"Informe a Marca",@aParam1,bOkParam,,.T.,,)
			cMarca := aParam1[01]
			
			SC1->(RecLock("SC1",.F.))
				SC1->C1_XMARPRE := 	cMarca				
			SC1->(MsUnLock())
		Else
			Return(.F.)
		EndIf

//		cCadastro:= cCadAux
	EndIf
EndIf
	
aEval(aAreOld, {|xAux| RestArea(xAux)})
oObjMark:Refresh(.T.) 
Return


/*/{Protheus.doc} FAtuBrw
Atualiza o objeto Browse com a Query recebida.

@author claudiol
@since 17/12/2015
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
@since 17/12/2015
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

//Campos utilizados
//Campo C1_OK e inicializado com valor default na query
AAdd( aCampos, 'C1_NUM' )
AAdd( aCampos, 'C1_ITEM' )
AAdd( aCampos, 'C1_EMISSAO' )
AAdd( aCampos, 'C1_PRODUTO' )
AAdd( aCampos, 'C1_DESCRI' )
AAdd( aCampos, 'C1_QUANT' )
AAdd( aCampos, 'BM_XCATBIO' )
AAdd( aCampos, 'C1_FILENT' )
AAdd( aCampos, 'C1_XMARPRE' )

// Campos não visualizados na Browse
AAdd( aNoFields, 'C1_OK' )
AAdd( aNoFields, 'C1RECNO' )

// Monta consulta de dados da grid
cQuery := "SELECT "

//Carrega campos que a consulta deve retornar
For nXi := 1 To Len(aCampos)
	cQuery += Iif(nXi > 1, ', ', '')
	cQuery += aCampos[nXi]
Next nXi

cQuery += ", 0 AS C1_OK, SC1.R_E_C_N_O_ C1RECNO"
cQuery += " FROM " + RetSQLName("SC1") + " SC1"
cQuery += " JOIN " + RetSQLName("SB1") + " SB1"
cQuery +=    	" ON  SC1.C1_PRODUTO = SB1.B1_COD"
cQuery +=    	" AND SB1.D_E_L_E_T_ <> '*' "
cQuery +=    	" AND SB1.B1_FILIAL='"+xFilial("SB1")+"'"
cQuery += " JOIN " + RetSQLName("SBM") + " SBM"
cQuery +=    	" ON  SBM.BM_GRUPO = SB1.B1_GRUPO"
cQuery +=    	" AND SBM.D_E_L_E_T_ <> '*' "
cQuery +=    	" AND SBM.BM_FILIAL='"+xFilial("SBM")+"'"
cQuery += " WHERE SC1.D_E_L_E_T_ <> '*' "
cQuery += 		" AND SC1.C1_FILIAL = '"+xFilial("SC1")+"'"

//Filtro para rotinas padrao
cQuery += 		" AND SC1.C1_QUJE = 0 "
cQuery += 		" AND SC1.C1_COTACAO = ' '"
cQuery += 		" AND SC1.C1_PEDIDO  = ' '"
cQuery += 		" AND SC1.C1_RESIDUO = ' '"
cQuery += 		" AND (SC1.C1_APROV = 'L' OR SC1.C1_APROV = ' ')"

//Filtros Bionexo
cQuery += 		" AND SC1.C1_XSTABIO IN ('0','3')" //0=Nao Enviado;3=Cancelado Envio
cQuery += 		" AND SC1.C1_XNUMPDC = ' '" //Numero PDC Bionexo

If !Empty(cGetSCDe) .And. !Empty(cGetSCAte)
	cQuery += " AND ( C1_NUM >= '" + cGetSCDe + "' AND C1_NUM <= '" + cGetSCAte + "' )"
EndIf
	
If !Empty(dGetEmiDe) .And. !Empty(dGetEmiAte)
	cQuery += " AND ( C1_EMISSAO >= '" + DToS(dGetEmiDe) + "' AND C1_EMISSAO <= '" + DToS(dGetEmiAte) + "' )"
EndIf

//Se marcado para nao apresentar pedidos ja exportados
If Upper(cCBAgrup)=="SIM"
	cGrupo:= SuperGetMv("ES_BIOCAT",.F.,"")
	If (Alltrim(cGetCatBio) $ cGrupo)
		//Separa os agrupamentos 
	 	aAgrup:= StrToKarr(cGrupo,";")
	 	//Separa os grupos
	 	For nXi:= 1 To Len(aAgrup)
	 		If (Alltrim(cGetCatBio) $ aAgrup[nXi])
				cQuery += " AND SBM.BM_XCATBIO IN "+ FormatIn(AllTrim(aAgrup[nXi]),"-")
				Exit
			EndIf
		Next nXi
	Else
		cQuery += " AND SBM.BM_XCATBIO = '"+ cGetCatBio +"'" 
	EndIf
Else
	cQuery += " AND SBM.BM_XCATBIO = '"+ cGetCatBio +"'" 
EndIf

//Ordenação da Query
cQuery += "ORDER BY C1_FILIAL, C1_NUM, C1_ITEM "


// Cria estrutura dos campos da grid
AAdd( aCampos, 'C1_OK' )

nXj := 1
For nXi := 1 To Len(aCampos)
	If ( AScan( aNoFields, aCampos[nXi] ) == 0 )
		
		aArrAux := U_FSRetSX3(aCampos[nXi])
		
		AAdd( aColumns, FWBrwColumn():New() )
		If ( aCampos[nXi] $( 'C1_EMISSAO|' ) )
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
@since 17/12/2015
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
@since 17/12/2015
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


/*/{Protheus.doc} FVisSol
Visualiza Solicitacao de Compra

@author claudiol
@since 17/12/2015
@version 1.0
/*/
Static Function FVisSol(oObjMark)

Local aAreOld	:= {SC1->(GetArea()),GetArea()}
Local cAlias	:= "SC1"
Local cCadAux	:= cCadastro
Local cAliTmp 	:= ''

Default oObjMark := Nil

If oObjMark <> Nil
	cAliTmp := oObjMark:cAlias
	
	If !Empty((cAliTmp)->C1RECNO)
		Private cCadastro:= "Solicitação de Compra - VISUALIZA"
		
		dbSelectArea(cAlias)
		(cAlias)->(dbGoto((cAliTmp)->C1RECNO))
		
		A110Visual(cAlias,(cAlias)->(Recno()),2)

		cCadastro:= cCadAux
	EndIf
EndIf
	
aEval(aAreOld, {|xAux| RestArea(xAux)})

Return


/*/{Protheus.doc} FLimFil
Limpa filtros informados

@author claudiol
@since 17/12/2015
@version 1.0
@example FlimFil()
/*/
Static Function FLimFil() 

//Dados
cGetTipCot:= Space(4)
cGetConPag:= Criavar("E4_CODIGO",.F.)
dGetDatVen:= CtoD(" ")
cGetHorVen:= Space(8)
cMGObs	:= ""

//Filtro
cGetSCDe   	:= Criavar("C1_NUM",.F.)
cGetSCAte  	:= Criavar("C1_NUM",.F.)
dGetEmiDe  	:= CtoD(" ")
dGetEmiAte 	:= CtoD(" ")
cGetCatBio 	:= Criavar("Z2_CODIGO",.F.)
cCBAgrup		:= "Não"  

//Atualiza objeto atual
GetdRefresh()

Return


/*/{Protheus.doc} FVldConPag
Validação da Condição de Pagamento
@author claudiol
@since 28/12/2015
@version undefined
@param cGetConPag, characters, descricao
@type function
/*/
Static Function FVldConPag(cGetConPag)

Local lRet:= .T.

If Empty(SE4->E4_XFPGBIO)
	ApMsgStop("Forma de pagamento Bionexo não informado na condição de pagamento!",".:Atenção:.")
	lRet:= .F.
EndIf

Return(lRet)


/*/{Protheus.doc} FGerExp
Gera Delivery PDC

@author claudiol
@since 17/12/2015
@version 1.0
@param oObjMark, objeto, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function FGerExp(oObjMark)

Local aAreOld	:= {SC1->(GetArea()),GetArea()}
Local cAliTmp 	:= ''
Local nQtdReg	:= 0
Local aRecSC1	:= {}
Local aProdutos:= {}
Local cNumReq	:= ""

Default oObjMark := Nil

If oObjMark <> Nil
	cAliTmp := oObjMark:cAlias

	//Verifica quantidade de registros marcados
	(cAliTmp)->(dbEval({|| Iif((cAliTmp)->C1_OK==1,nQtdReg++,Nil)}))

	oProcess:SetRegua1(2)
	oProcess:IncRegua1("Processando Solicitações de Compra a Enviar!")
	oProcess:SetRegua2(nQtdReg)
	
	If !Empty(nQtdReg)
	
		//Processa registros marcados
		(cAliTmp)->(DbGoTop())
		While (cAliTmp)->(!Eof())
			oProcess:IncRegua2(OemToAnsi("Processando Sol.Compra: "+(cAliTmp)->C1_NUM +" " +(cAliTmp)->C1_ITEM))
	
			If (cAliTmp)->C1_OK == 1  //Se Item marcado
				//Recno dos registros a enviar
				Aadd(aRecSC1,(cAliTmp)->C1RECNO)

				//Carrega array com todos os produtos
				If (nPos:=Ascan(aProdutos,(cAliTmp)->C1_PRODUTO)) == 0
					aAdd(aProdutos,(cAliTmp)->C1_PRODUTO)
				EndIf
			EndIf
			(cAliTmp)->(DbSkip())
		EndDo

		//Gera Numero de Controle
		U_FSGerReq("G",@cNumReq)

		//Envia dados para Bionexo
		oProcess:IncRegua1("Enviando Bionexo!")
		aRet:= U_FSEnvPDC(aProdutos,aRecSC1,cNumReq)

		//Atualiza registros
		If aRet[_RTBIOSTA] == "1" //-1=Erro; 0=Sem Dados;1=Ok

			BeginTran()

				//Grava historico, status e numero PDC
				If(lRet:= U_FSGrvSC1("E",aRecSC1,aRet,cNumReq))
					U_FSGerReq("L",cNumReq)
				EndIf

				If lRet
					//Efetiva transacao
					EndTran()
				Else
					//Disarmo a transação
					DisarmTransaction ()
				EndIF
			
			MsUnlockAll()

		EndIf

		//Atualiza variavel statica de controle de todos marcados/desmarcados
		lTipMark := .T.
		
	Else
	
		ApMsgAlert("Não existem itens marcados!",".:Atenção:.")
				
	EndIf
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return
