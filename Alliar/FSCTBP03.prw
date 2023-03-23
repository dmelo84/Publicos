#Include 'Protheus.ch'
#Include "TOTVS.CH"
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} FSCTBP03
Rotina para apuração e contabilização da produção/perda do mes de referencia

@type function
@author Alex Teixeira de Souza
@since 08/01/2016
@version 1.0
@return ${aRet}, ${Codigo do erro, Descricao do Erro}
@example
(examples)
@see (links_or_references)
/*/

User Function FSCTBP03()
Local aCoors 	:= FWGetDialogSize( oMainWnd )
Local nSpaceL 	:= 5
Local nSpaceT 	:= 5

Private oFWLayer
Private oWndRef
Private oWndApu
Private oFont
Private oSayRef
Private oGetRef
Private oMrkBrowse	:= nil
Private oFWLegend	:= nil
Private aRotina 	:= MenuDef()	// Monta menu da Browse
Private cAliasTmp	:= GetNextAlias()
Private oDialog		:= Nil
Private cDtRef		:= MV_PAR01
Private aColumns	:= {}
Private cAlias
Private oProcess

DbSelectArea('SZ4')		//Campos da tabela
SZ4->( DbSetOrder(1) )	//X3_CAMPO
SZ4->(dbSetFilter( {|| SZ4->Z4_ANOMES == cDtRef }, "SZ4->Z4_ANOMES == cDtRef" ))

CriaTabTmp()   

AAdd(aColumns,FWBrwColumn():New())
aColumns[len(aColumns)]:SetData( &("{|| cArqTmp->FILIAL }") )
aColumns[len(aColumns)]:SetTitle( "Filial" )
aColumns[len(aColumns)]:SetSize(TamSX3("Z4_FILIAL")[1]  )
aColumns[len(aColumns)]:SetDecimal(TamSX3("Z4_FILIAL")[2]  )
aColumns[len(aColumns)]:SetPicture(PesqPict("SZ4","Z4_FILIAL" ))

AAdd(aColumns,FWBrwColumn():New())
aColumns[len(aColumns)]:SetData( &("{|| cArqTmp->VALOR }") )
aColumns[len(aColumns)]:SetTitle( "Produção" )
aColumns[len(aColumns)]:SetSize(TamSX3("Z4_VALOR")[1]  )
aColumns[len(aColumns)]:SetDecimal(TamSX3("Z4_VALOR")[2]  )
aColumns[len(aColumns)]:SetPicture(PesqPict("SZ4","Z4_VALOR" ))

AAdd(aColumns,FWBrwColumn():New())
aColumns[len(aColumns)]:SetData( &("{|| cArqTmp->FATURA } ") )
aColumns[len(aColumns)]:SetTitle( "Receita Faturada " )
aColumns[len(aColumns)]:SetSize(TamSX3("Z4_RECFAT")[1]  )
aColumns[len(aColumns)]:SetDecimal(TamSX3("Z4_RECFAT")[2]  )
aColumns[len(aColumns)]:SetPicture(PesqPict("SZ4","Z4_RECFAT" ))

AAdd(aColumns,FWBrwColumn():New())
aColumns[len(aColumns)]:SetData( &("{|| cArqTmp->AFATUR } ") )
aColumns[len(aColumns)]:SetTitle( "Receita a Faturar" )
aColumns[len(aColumns)]:SetSize(TamSX3("Z4_RECAFAT")[1]  )
aColumns[len(aColumns)]:SetDecimal(TamSX3("Z4_RECAFAT")[2]  )
aColumns[len(aColumns)]:SetPicture(PesqPict("SZ4","Z4_RECAFAT" ))

AAdd(aColumns,FWBrwColumn():New())
aColumns[len(aColumns)]:SetData( &("{|| cArqTmp->DIFER }") )
aColumns[len(aColumns)]:SetTitle( "Diferença" )
aColumns[len(aColumns)]:SetSize(TamSX3("Z4_VALOR")[1]  )
aColumns[len(aColumns)]:SetDecimal(TamSX3("Z4_VALOR")[2]  )
aColumns[len(aColumns)]:SetPicture(PesqPict("SZ4","Z4_VALOR" ))
 

AAdd(aColumns,FWBrwColumn():New())
aColumns[len(aColumns)]:SetData( &("{|| cArqTmp->PERDA }") )
aColumns[len(aColumns)]:SetTitle( "Perda" )
aColumns[len(aColumns)]:SetSize(TamSX3("Z4_PERDA")[1]  )
aColumns[len(aColumns)]:SetDecimal(TamSX3("Z4_PERDA")[2]  )
aColumns[len(aColumns)]:SetPicture(PesqPict("SZ4","Z4_PERDA" ))

AAdd(aColumns,FWBrwColumn():New())
aColumns[len(aColumns)]:SetData( &("{|| cArqTmp->GLOSA }") )
aColumns[len(aColumns)]:SetTitle( "Glosa" )
aColumns[len(aColumns)]:SetSize(TamSX3("Z4_GLOSA")[1]  )
aColumns[len(aColumns)]:SetDecimal(TamSX3("Z4_GLOSA")[2]  )
aColumns[len(aColumns)]:SetPicture(PesqPict("SZ4","Z4_GLOSA" ))

AAdd(aColumns,FWBrwColumn():New())
aColumns[len(aColumns)]:SetData( &("{|| cArqTmp->GLOANT }") )
aColumns[len(aColumns)]:SetTitle( "Saldo Glosa" )
aColumns[len(aColumns)]:SetSize(TamSX3("Z4_GLOANT")[1]  )
aColumns[len(aColumns)]:SetDecimal(TamSX3("Z4_GLOANT")[2]  )
aColumns[len(aColumns)]:SetPicture(PesqPict("SZ4","Z4_GLOANT" ))

AAdd(aColumns,FWBrwColumn():New())
aColumns[len(aColumns)]:SetData( &("{|| cArqTmp->LOTE}") )
aColumns[len(aColumns)]:SetTitle( "Lote Contab." )
aColumns[len(aColumns)]:SetSize(TamSX3("Z4_LOTE")[1]  )
aColumns[len(aColumns)]:SetDecimal(TamSX3("Z4_LOTE")[2]  )
aColumns[len(aColumns)]:SetPicture(PesqPict("SZ4","Z4_LOTE" ))


oFont := TFont():New('Arial',,15,.T.)
oDialog := MsDialog():New( aCoors[1], aCoors[2], aCoors[3], aCoors[4], "Apuracao para Contabilizacao de Producao", , , , , , , , oMainWnd, .T. )
//
// Conteiner onde serão colocados os gets e browses
//
oFWLayer := FWLayer():New()
oFWLayer:Init( oDialog, .F., .T. )
oFWLayer:AddLine( 'LI1', 25, .F. ) // Cria uma "linha" com 25% da tela
oFWLayer:AddLine( 'LI2', 75, .F. ) // Cria uma "linha" com 75% da tela
oFWLayer:addCollumn( 'ClLI1', 100,,'LI1') 
oFWLayer:addCollumn( 'ClLI2', 100,,'LI2')

oFWLayer:addWindow( 'ClLI1' , "WIN1",			 		, 100, .F., .F., {||  }, 'LI1' ) // "Referencia
oFWLayer:addWindow( 'ClLI2' , "WIN2","Dados apuracao"	, 100, .F., .F., {||  }, 'LI2' ) // "Apuracao

oWndRef	:= oFWLayer:getWinPanel('ClLI1',"WIN1",'LI1')  
oWndApu	:= oFWLayer:getWinPanel('ClLI2',"WIN2",'LI2')

oSayRef := TSay():New( 012,010,{||"Referência"},oWndRef,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oGetRef := TGet():New( 011,050,{|u| If(PCount()>0,cDtRef:=u,cDtRef)},oWndRef,040,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. },.F.,.F.,,.T.,.F.,"","cDtRef",,)
 	

// Painel da Legenda
oFWLegend := FWLegend():New()
oFWLegend:Add( "", "GREEN"  , "Integrado (recebido pela Pleres)" )
oFWLegend:Add( "", "ORANGE" , "Apurado dados de acordo com sistema ERP" )
oFWLegend:Add( "", "RED", "Contabilizado" ) 

oFWLegend:Activate()

//------------------------------------------
//Criação da MarkBrowse no Layer 
//------------------------------------------
oMrkBrowse:= FWMarkBrowse():New()
oMrkBrowse:SetSeeAll(.T.)
oMrkBrowse:SetFieldMark("OK")
oMrkBrowse:SetOwner(oWndApu)
oMrkBrowse:SetAlias("cArqTmp")
oMrkBrowse:SetDataQuery(.F.)
oMrkBrowse:SetDataTable(.T.)
oMrkBrowse:AddLegend( "LA != 'S' .AND. APUR != 'S' " , "GREEN", "Integrado (recebido pela Pleres)" ) 
oMrkBrowse:AddLegend( "LA != 'S' .AND. APUR == 'S' " , "ORANGE","Apurado dados de acordo com sistema ERP" )
oMrkBrowse:AddLegend( "LA == 'S'" , "RED", "Contabilizado" ) 
oMrkBrowse:SetColumns(aColumns)

oMrkBrowse:SetDoubleClick( { || FMrkOne( oMrkBrowse ) } )
oMrkBrowse:SetAllMark({|| FMrkAll( oMrkBrowse ) })

oMrkBrowse:AddButton("Apurar",{|| ExeProc(1) },,3,, .F., 2 ) 			
oMrkBrowse:AddButton("Estornar",{|| ExeProc(3) },,2,, .F., 2 ) 		
oMrkBrowse:AddButton("Contabilizar",{|| ExeProc(2) },,4,, .F., 2 ) 	
oMrkBrowse:AddButton("Legendas", { || oFWLegend:View() },,1,, .F., 2 )

oMrkBrowse:Activate()

oDialog:Activate( ,,,.T.,,, )

SZ4->(dbClearFilter())
MsUnlockAll()
	
Return Nil 


/*/{Protheus.doc} MenuDef
Monta Menu

@author Alex T. Soiza
@since 17/12/2015
@version 1.0
@return aRot
@example  MenuDef()
/*/
//-------------------------------------------------------------------

Static Function MenuDef()     
Local aRot := {}

ADD OPTION aRot TITLE "Sair" ACTION "oDialog:End()"   OPERATION 4 ACCESS 0          //"Sair

Return(Aclone(aRot))



/*/{Protheus.doc} CriaTabTmp
Cria Tabela Temporari

@author Alex T. Soiza
@since 17/12/2015
@version 1.0
@return aRot
@example  MenuDef()
/*/
//-------------------------------------------------------------------
Static Function CriaTabTmp()     
Local aCampos	:= {}
Local oTempTable
Local cArqTmp	:= GetNextAlias()


	If Select(cArqTmp) > 0
		dbSelectArea(cArqTmp)
		(cArqTmp)->(DbCloseArea())
	Endif	

	oTempTable := FWTemporaryTable():New(cArqTmp)

	DbSelectArea('SZ4')		//Campos da tabela
	SZ4->( DbSetOrder(1) )	//X3_CAMPO

	aAdd(aCampos,{"OK"		, "C" , TamSX3("Z4_OK")[1]		,TamSX3("Z4_OK")[2]})
	aAdd(aCampos,{"FILIAL"  , "C" , TamSX3("Z4_FILIAL")[1]	,TamSX3("Z4_FILIAL")[2]})
	aAdd(aCampos,{"ANOMES" 	, "C" , TamSX3("Z4_ANOMES")[1]	,TamSX3("Z4_ANOMES")[2]})
	aAdd(aCampos,{"VALOR"  	, "N" , TamSX3("Z4_VALOR")[1]	,TamSX3("Z4_VALOR")[2]})
	aAdd(aCampos,{"FATURA"  , "N" , TamSX3("Z4_RECFAT")[1]	,TamSX3("Z4_RECFAT")[2]})
	aAdd(aCampos,{"AFATUR"  , "N" , TamSX3("Z4_RECAFAT")[1]	,TamSX3("Z4_RECAFAT")[2]})
	aAdd(aCampos,{"DIFER"  	, "N" , TamSX3("Z4_VALOR")[1]	,TamSX3("Z4_VALOR")[2]})
	aAdd(aCampos,{"PERDA"  	, "N" , TamSX3("Z4_VALOR")[1]	,TamSX3("Z4_VALOR")[2]})
	aAdd(aCampos,{"GLOSA"  	, "N" , TamSX3("Z4_GLOSA")[1]	,TamSX3("Z4_GLOSA")[2]})
	aAdd(aCampos,{"GLOANT"  , "N" , TamSX3("Z4_GLOANT")[1]	,TamSX3("Z4_GLOANT")[2]})
	aAdd(aCampos,{"LOTE"	, "C" , TamSX3("Z4_LOTE")[1]	,TamSX3("Z4_LOTE")[2]})
	aAdd(aCampos,{"LA"		, "C" , TamSX3("Z4_LA")[1]		,TamSX3("Z4_LA")[2]})
	aAdd(aCampos,{"APUR"	, "C" , TamSX3("Z4_APUR")[1]	,TamSX3("Z4_APUR")[2]})
	
	oTemptable:SetFields( aCampos )
		
	//Criação da tabela
	
	oTempTable:Create()
	
	//|IndRegua ( "cArqTmp",cArqTmp,"FILIAL+ANOMES",,,OemToAnsi( "Selecionando Registros...")) // "Selecionando Registros..."
		
	SZ4->(DBGotop())
	Do While !SZ4->(Eof())
	
		(cArqTmp)->(DBAppend())
		(cArqTmp)->FILIAL 	:= SZ4->Z4_FILIAL
		(cArqTmp)->ANOMES	:= SZ4->Z4_ANOMES
		(cArqTmp)->VALOR	:= SZ4->Z4_VALOR
		(cArqTmp)->PERDA	:= SZ4->Z4_PERDA
		(cArqTmp)->GLOSA	:= SZ4->Z4_GLOSA
		(cArqTmp)->GLOANT	:= SZ4->Z4_GLOANT
		(cArqTmp)->LOTE		:= SZ4->Z4_LOTE
		(cArqTmp)->LA		:= SZ4->Z4_LA
		(cArqTmp)->APUR		:= SZ4->Z4_APUR
		(cArqTmp)->DIFER	:= SZ4->Z4_DIFER
		(cArqTmp)->FATURA	:= SZ4->Z4_RECFAT
		(cArqTmp)->AFATUR	:= SZ4->Z4_RECAFAT
		(cArqTmp)->(DBCommit())

		SZ4->(DBSkip())
	EndDo 

MsUnlockAll()
		
Return


/*/{Protheus.doc} ExeProc
Executa Processamento

@author Alex T. Soiza
@since 17/12/2015
@version 1.0
@return aRot
@example  MenuDef()
/*/
//-------------------------------------------------------------------
Static Function ExeProc(nQual)     

Local lRet:= .T.

If nQual==1
	cMensAux:= "Confirma a apuração dos dados?"
ElseIf nQual==2
	cMensAux:= "Confirma a contabilizacao?"
	lRet:= FVldDat()
ElseIf nQual==3
	cMensAux:= "Confirma o estorno da contabilização?"
	lRet:= FVldDat()
EndIf

If lRet
	lRet:= ApMsgNoYes(cMensAux, ".:Confirmação:.")
EndIf

If lRet
	Do Case
		Case nQual == 1
			oProcess := MsNewProcess():New({|lEnd| CalcSldCta() },OemToAnsi("Processando"),OemToAnsi("Aguarde! Realizando Apuração..."),.F.)
			oProcess:Activate()
	
		Case nQual == 2
			oProcess := MsNewProcess():New({|lEnd| FEfeCtb() },OemToAnsi("Processando"),OemToAnsi("Aguarde! Contabilizando ..."),.F.)
			oProcess:Activate()
			
		Case nQual == 3
			oProcess := MsNewProcess():New({|lEnd| FEDelCtb() },OemToAnsi("Processando"),OemToAnsi("Aguarde! Excluindo Contabilização ..."),.F.)
			oProcess:Activate()
	EndCase
EndIf

Pergunte("FSCTBP02",.F.)

Return


/*/{Protheus.doc} CalcSldCta
Apuração

@author Alex T. Soiza
@since 17/12/2015
@version 1.0
@return aRot
@example  MenuDef()
/*/
//-------------------------------------------------------------------
Static Function CalcSldCta()

Local dDtMesAnt := 	LastDay(CtoD("01/"+Substr(MV_PAR01,5,2)+"/"+Substr(MV_PAR01,1,4))-1)
Local dDtMesAtu	:=	LastDay(CtoD("01/"+Substr(MV_PAR01,5,2)+"/"+Substr(MV_PAR01,1,4)))
Local nFtrMAnt	:= 0
Local nFtrMAtu	:= 0
Local nAFtrMAnt	:= 0
Local nAFtrMAtu	:= 0
Local cFilBkp		:= cFilAnt
Local _cMark 		:= oMrkBrowse:Mark()
Local nGloAnt		:= 0

//Define quantidade de reguas de progressao
oProcess:SetRegua1(2)

//Primeira regua
oProcess:IncRegua1("Apurando valores!")

oProcess:SetRegua2(cArqTmp->(Reccount()))
cArqTmp->(DBGotop())

Do while !cArqTmp->(Eof())
	
	oProcess:IncRegua2(OemToAnsi("Processando Apuração..."))	
	
	if oMrkBrowse:IsMark(_cMark) .and. cArqTmp->LA != 'S' 
	
		cFilAnt := cArqTmp->FILIAL
	
		nFtrMAnt	:= SaldoConta(MV_PAR02,dDtMesAnt,"01")
		nFtrMAtu	:= SaldoConta(MV_PAR02,dDtMesAtu,"01")

		nAFtrMAnt	:= SaldoConta(MV_PAR03,dDtMesAnt,"01")
		nAFtrMAtu	:= SaldoConta(MV_PAR03,dDtMesAtu,"01")
			
		nGloAnt	:= SaldoConta(MV_PAR04,dDtMesAnt,"01")

		nSldMAnt	:= Abs(nFtrMAtu)   //nFtrMAnt //+nAFtrMAnt
		nSldMAtu	:= Abs(nAFtrMAtu) //(nFtrMAtu - nFtrMAnt) + (nAFtrMAtu - nAFtrMAnt)
		
		nDifer		:= cArqTmp->VALOR - (nSldMAnt + nSldMAtu)
	
		Reclock( "cArqTmp" , .f. )	 
		cArqTmp->DIFER	:= nDifer
		cArqTmp->FATURA	:= nSldMAnt
		cArqTmp->AFATUR	:= nSldMAtu
		cArqTmp->GLOANT	:= nGloAnt
		cArqTmp->APUR	:= "S"
		cArqTmp->(msUnlock())
		
		If SZ4->(DBSeek(cArqTmp->FILIAL+cDtRef))
			Reclock( "SZ4" , .f. )
			SZ4->Z4_APUR 		:= "S"
			SZ4->Z4_RECFAT	:= nSldMAnt
			SZ4->Z4_RECAFAT	:= nSldMAtu
			SZ4->Z4_DIFER  	:= nDifer 
			SZ4->Z4_GLOANT  	:= nGloAnt 
			// gravar registros da diferenca e apuracao
			SZ4->(msUnlock())
		Endif
	Endif

	cArqTmp->(DBSkip())
EndDo
	
//Seta cFilAnt e SM0
U_FSMudFil(cFilBkp)

oMrkBrowse:oBrowse:Refresh()
	
Return .t.	
	
	
//------------------------------------------------------------------- 
/*/{Protheus.doc} FEfeCtb
Efetivando Contabilizacao
          
@author 	Alex T. de Souza
@since 	11/01/2016 
@version 	P11
@obs  
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------                             
Static Function FEfeCtb()
Local cArquivo	:= ""
Local nHdlPrv		:= 0
Local nFSTotal		:= 0
Local _cMark 		:= oMrkBrowse:Mark()
Local cConta		:= ""
Local lDigita		:= .f.
Local lAglut 		:= .f.
Local cLote			:= ""
Local cFilBkp		:= cFilAnt
Local cCTBP01	:=	SuperGetMV("ES_CTBPD1",.F.,"100")
Local cCTBP02	:=	SuperGetMV("ES_CTBPD2",.F.,"101")
Local cCTBPER	:=	SuperGetMV("ES_CTBPER",.F.,"102")
Local cCTBGLO	:= SuperGetMV("ES_CTBGLO", .F., "103")
Local lContab	:= .f.
Local nSldGlo	:= 0
Local cMesAnt := ""

//Busca lote contabil
SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
If SX5->(MsSeek(xFilial("SX5")+"09CON"))
	cLote:= AllTrim(X5Descri())
Else
	cLote:= "CON "
EndIf		

If At(UPPER("EXEC"),X5Descri()) > 0 .Or. At(Upper("U_"),SX5->(FIELDGET(FIELDPOS("X5_DESCRI")))) > 0	// Executa um execblock
	cLote:= &(X5Descri())
EndIf				


//Define quantidade de reguas de progressao
oProcess:SetRegua1(2)

//Primeira regua
oProcess:IncRegua1("Contabilizando valores!")
oProcess:SetRegua2(cArqTmp->(Reccount()))
cArqTmp->(DBGotop())

DbSelectArea('SZ4')		//Campos da tabela
SZ4->( DbSetOrder(1) )	//X3_CAMPODbSelectArea('SZ4')		//Campos da tabela

Do while !cArqTmp->(Eof())

	oProcess:IncRegua2(OemToAnsi("Processando Contabilização..."))

	If oMrkBrowse:IsMark(_cMark) .and. cArqTmp->LA != "S" .and. cArqTmp->APUR == "S"
		If SZ4->(DBSeek(cArqTmp->FILIAL+cDtRef))
		
 			//Seta cFilAnt e SM0
			U_FSMudFil(cArqTmp->FILIAL)
 			
			nHdlPrv	:= 0
			nFSTotal	:= 0
			cArquivo	:= ""
			
			cChaveBusca := SZ4->Z4_FILIAL+SZ4->Z4_ANOMES

			//Cabecalho da contabilizacao
			nHdlPrv:=HeadProva(cLote,"FSCTBP03",Substr(cUserName,1,6),@cArquivo,.f.)
			lContab	:= .t.

			//Detalhe da contabilizacao
			If SZ4->Z4_DIFER > 0
				nFSTotal+=DetProva(nHdlPrv,cCTBP01,"FSCTBP03",cLote,,,,,cChaveBusca)
			Else
				nFSTotal+=DetProva(nHdlPrv,cCTBP02,"FSCTBP03",cLote,,,,,cChaveBusca)
			Endif
			
			//Detalhe da contabilizacao
			If SZ4->Z4_PERDA > 0
				nFSTotal+=DetProva(nHdlPrv,cCTBPER,"FSCTBP03",cLote,,,,,cChaveBusca)
			Endif			

			//Faz o Lancamento zerando a Conta da Glosa
			nFSTotal += DetProva(nHdlPrv,cCTBGLO,"FSCTBP03",cLote,,,,,cChaveBusca)
			
			//Rodape da contabilizacao
			RodaProva(nHdlPrv,nFSTotal)
			
			if nFSTotal > 0
				Reclock( "SZ4" , .f. )
				SZ4->Z4_LA 		:= "S"
				SZ4->Z4_LOTE 	:= Alltrim(cLote) 
				SZ4->(msUnlock())
				
				Reclock( "cArqTmp" , .F. )
				cArqTmp->LA		:= "S"
				cArqTmp->OK		:= ""
				cArqTmp->(msUnlock())
			Endif			

			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)

		Endif

	Endif
	cArqTmp->(DBSkip())
EndDo

oMrkBrowse:oBrowse:Refresh()

//Seta cFilAnt e SM0
U_FSMudFil(cFilBkp)

Return .t.


//------------------------------------------------------------------- 
/*/{Protheus.doc} FEDelCtb
Deleta Contabilizacao
          
@author 	Alex T. de Souza
@since 	11/01/2016 
@version 	P11
@obs  
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------                             
Static Function FEDelCtb()
Local _cMark 		:= oMrkBrowse:Mark()
Local cLote			:= ""
Local cFilBkp		:= cFilAnt
Local lContab		:= .f.
Local aCab			:= {}
Local aTotItem		:= {}

Private lMsErroAuto := .F.

//Define quantidade de reguas de progressao
oProcess:SetRegua1(2)

//Primeira regua
oProcess:IncRegua1("Excluindo Lancamentos Contabeis!")
oProcess:SetRegua2(cArqTmp->(Reccount()))
cArqTmp->(DBGotop())

DbSelectArea('CT2')		
CT2->( DbSetOrder(1) )	

DbSelectArea('SZ4')		
SZ4->( DbSetOrder(1) )	

Do while !cArqTmp->(Eof())

	oProcess:IncRegua2(OemToAnsi("Excluindo Contabilização..."))

	If oMrkBrowse:IsMark(_cMark) .and. cArqTmp->LA == "S"  
		If SZ4->(DBSeek(cArqTmp->FILIAL+cDtRef))

 			//Seta cFilAnt e SM0
			U_FSMudFil(cArqTmp->FILIAL)
			
			if (nRec := FEBuscaCT2()) > 0
			
				CT2->(DBgoto(nRec))
			
				aCab		:= {}
				aTotItem	:= {}
							
				aCab := {;
					{"dDataLanc",CT2->CT2_DATA	,NIL},;
					{"cLote"	,CT2->CT2_LOTE	,NIL},;
					{"cSubLote"	,CT2->CT2_SBLOTE,NIL},;
					{"cDoc"		,CT2->CT2_DOC   ,NIL};
				}
				
			 	Aadd(aTotItem, {;
					{"CT2_LINHA"	,CT2->CT2_LINHA		,NIL},;
					{"LINPOS"		,"CT2_LINHA"		,CT2->CT2_LINHA};
				})
				
				nModAux:= nModulo
				nModulo:= 34
				MSExecAuto({|x,y,Z| Ctba102(x,y,Z)},aCab,aTotItem,5) 
				nModulo:= nModAux

				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
					Return .F.
				Else
					Reclock( "SZ4" , .f. )
					SZ4->Z4_LA 		:= "N"
					SZ4->Z4_LOTE 	:= Alltrim(cLote) 
					SZ4->(msUnlock())
					
					Reclock( "cArqTmp" , .F. )
					cArqTmp->LA		:= "N"
					cArqTmp->OK		:= ""
					cArqTmp->(msUnlock())			
				Endif
			Endif			
		Endif

	Endif
	cArqTmp->(DBSkip())
EndDo

oMrkBrowse:oBrowse:Refresh()
cFilAnt := cFilBkp		 

Return .t.


//------------------------------------------------------------------- 
/*/{Protheus.doc} FEBuscaCT2
Busca registro na CT2 pelo campo CT2_KEY
          
@author 	Alex T. de Souza
@since 	11/01/2016 
@version 	P11
@obs  
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------                             
Static Function FEBuscaCT2()
Local cQuery 	:= ""
Local nRec		:= 0
Local aArea  	:= GetArea()

	cQuery += "SELECT CT2.R_E_C_N_O_ CT2REC FROM "+RetSqlName("CT2")+" CT2 "
	cQuery += "WHERE CT2.CT2_KEY = '"+Padr(SZ4->Z4_FILIAL+SZ4->Z4_ANOMES,TamSx3("CT2_KEY")[1])+"' AND CT2.D_E_L_E_T_ <> '*'"
	
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QTMP",.F.,.T.)
	

	If !QTMP->(Eof())
		nRec := QTMP->CT2REC
	Endif	

	QTMP->(dbCloseArea())	
	
	RestArea(aArea)

Return nRec
	
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author alex.teixeira

@since 11/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()

oView := FWFormView():New()

oView:SetModel(oModel)

Return oView


/*/{Protheus.doc} FMrkAll
(long_description)
@type function
@author claudiol
@since 17/02/2016
@version 1.0
@param oObjMark, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FMrkAll( oObjMark )

cArqTmp->(DbGoTop())
While cArqTmp->(!Eof())
	FMrkOne( oObjMark )
	
	cArqTmp->(DbSkip())
End
cArqTmp->(DbGoTop())

//Tratamento para forçar refresh
//metodo refresh do objeto limpa campo de marca
oObjMark:GoBottom()
oObjMark:GoTop(.T.)

Return


/*/{Protheus.doc} FMrkOne
(long_description)
@type function
@author claudiol
@since 17/02/2016
@version 1.0
@param oObjMark, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FMrkOne( oObjMark )

Local _cMark 		:= oObjMark:Mark()

Default oObjMark := Nil

If oObjMark <> Nil
	Reclock( "cArqTmp" , .F. )
	cArqTmp->OK := Iif(oObjMark:IsMark(_cMark),"",	oObjMark:Mark())
	cArqTmp->(MsUnlock())
EndIf

Return


/*/{Protheus.doc} FVldDat
Valida data de contabilizacao
@type function
@author claudiol
@since 07/04/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FVldDat()

Local lRet:= (Left(Dtos(dDatabase),6) == MV_PAR01)

If !lRet
	ApMsgStop("Data do Sistema tem que estar no mesma mes/ano da data de referência!",".:Atenção:.")
EndIf

Return(lRet)
