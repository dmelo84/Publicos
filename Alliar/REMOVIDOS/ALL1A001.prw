#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#DEFINE _nVersao 4 //Versão do fonte
//-------------------------------------------------------------------
/*/{Protheus.doc} ALL1A001
Plano de Manutenção por Empresas

@author Maria Elisandra de Paula
@since 04/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
User Function ALL1A001()
	Local aNGBEGINPRM := NGBEGINPRM(_nVersao)
	Local oBrowse
	Private _CODRET := ""
	
	oBrowse := FWmBrowse():New()
		oBrowse:SetAlias('ZNA')
		oBrowse:SetDescription('Plano de Manutenção por Empresas')
		oBrowse:SetMenuDef('ALL1A001')
		oBrowse:Activate()
	
	NGRETURNPRM(aNGBEGINPRM)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Maria Elisandra de Paula
@since 04/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title 'Incluir'    		Action 'VIEWDEF.ALL1A001' OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Liberar/Alterar'  Action 'U_ALL1ALT()' OPERATION 4 ACCESS 0
	
Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Maria Elisandra de Paula
@since 04/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruct 	:= FWFormStruct(1,"ZNA")
	
	// Cria o objeto do Modelo de Dados
	Local oModel := MPFormModel():New("MODELZNA", /*bPre*/,/* {|oModel| ValidInfo(oModel) }*/ ,{|oModel| CommitInfo(oModel)}, /*bCancel*/)

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields("U_ALL1A001_ZNA", Nil, oStruct,/*bPre*/,/*bPost*/,/*bLoad*/)
	
	//oModel:SetPrimaryKey({ 'ZNA_FILIAL', 'ZNA_CODIGO' })
	
	oModel:SetDescription('Plano de Manutenção por Empresas')

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Maria Elisandra de Paula
@since 04/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel :=  ModelDef()
	Local oView  := FWFormView():New()

	// Objeto do model a se associar a view.
	oView:SetModel(oModel)

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( "U_ALL1A001_ZNA" , FWFormStruct(2,"ZNA"), /*cLinkID*/ )	//

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )

	// Associa um View a um box
	oView:SetOwnerView( "U_ALL1A001_ZNA" , "MASTER" )
	

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} CommitInfo
Validações finais ao confirmação da tela

@author Maria Elisandra de Paula
@since 07/12/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CommitInfo(oModel)
	Local aArea		:= GetArea()
	Local aAreaSm0  := SM0->(GetArea())
	Local cEmpAte 	:= If(Empty(M->ZNA_EMPFIM),Replicate("Z", Len(ZNA->ZNA_EMPFIM)),M->ZNA_EMPFIM)
	Local nPos	  	:= 0		
	Local aEmp 	  	:= {} 
	Local cFilOld   := cFilAnt
	Local cAliasQry := ""
	Local cQuery	:= ""		
	
	//variáveis Private necessárias para função a330GRAVA
	Private cCondicao := "ST4->T4_LUBRIFI <> 'S'" // If(cPlano == "L","ST4->T4_LUBRIFI = 'S'","ST4->T4_LUBRIFI <> 'S'")
	Private aTELA[0][0],aGETS[0],aHEADER[0],CONTINUA,nUSADO:=0
	Private lFiltBem := .F.
	Private lModBe := .t.
	Private cPla := "M"
	Private _DTPROX, dREAL, _CONPROX, _HHPROX
	Private _lFirstOS := .F. // Indica se é a primeira O.S. do cálculo da Próxima Manutenção (ocorre normalmente quando não há ordens de serviço para a manutenção)
	Private lLubrif := .t.,lEstrut := .f.
	Private lCEstru := NGCADICBASE("TI_ESTRUTU","A","STI",.F.)
	Private lMVMOINP := If(GetNewPar("MV_NGMOINP","2")=="1",.T.,.F.)  //Mostra Inconsistencias do Plano
	Private aIndSTI := {}
	Private aBensTrb := {} // Indica bens marcados pelo filtro de bens
	
	// INICIO
	// Variaveis usadas na geracao de solicitacao de compras
	// NAO MEXER....
	Private aDataOPC1 := {}, aDataOPC7 := {}, aOPC1 := {}, aOPC7 := {}, vVetP  := {}, aNumSC1 := {}
	Private cNumSC1   := Space(Len(SC1->C1_NUM)),cNuISC1 := 0, lconsterc := .t., lconsNPT  := .t.
	// FIM
	
	Private lForTPG := NGCADICBASE("TG_FORNEC","A","STG",.F.)
	
	Begin Transaction
	
		If oModel:GetOperation() == 3 
			// Grava informações do Model ZNA
			FwFormCommit(oModel)
		EndIf	
		
		//Busca todas as filiais selecionadas	
		dbSelectArea("SM0")
		dbSetOrder(1)
		dbGoTop()
		While !Eof()
	
			If SM0->M0_CODIGO + SM0->M0_CODFIL < M->ZNA_EMPINI .Or. SM0->M0_CODIGO + SM0->M0_CODFIL > cEmpAte
				dbSkip()
				Loop
			EndIf
			
			nPos := aScan(aEmp,{|x| x[1] == SM0->M0_CODIGO})
			If nPos == 0
				aAdd(aEmp,{SM0->M0_CODIGO,{Substr(SM0->M0_CODFIL,1,SM0->M0_SIZEFIL)}})
			Else
				aAdd(aEmp[nPos][2],Substr(SM0->M0_CODFIL,1,SM0->M0_SIZEFIL))
			EndIf
						
			dbSelectArea("SM0")			
			dbSkip()
		EndDo
		
		
		
		//Grava STI nas filiais selecionadas 
		For nPos := 1 To Len(aEmp[1][2])
		
			cFilAnt := aEmp[1][2][nPos]
			
			dbSelectArea("SM0")
			dbSetOrder(1)
			dbSeek(cEmpAnt + cFilAnt )
			
			//----------------------------------------------
			// Retorna o próximo código de plano disponível
			//----------------------------------------------
			cA330NUM := StaticCall(MNTA330,LockPlano)
			
			M->TI_FILIAL	:= xFilial("STI", aEmp[1][2][nPos])
			M->TI_PLANO	    := cA330NUM 
			M->TI_DATAPLA   := M->ZNA_DTPLAN
			M->TI_DESCRIC	:= M->ZNA_DESCRI
			M->TI_DATAINI	:= M->ZNA_DTINI
			M->TI_DATAFIM 	:= M->ZNA_DTFIM
			M->TI_SERVINI	:= M->ZNA_SERINI
			M->TI_SERVFIM	:= M->ZNA_SERFIM
			M->TI_FAMIINI	:= M->ZNA_FAMINI
			M->TI_FAMIFIM	:= M->ZNA_FAMFIM
			M->TI_BEMINI	:= M->ZNA_BEMINI
			M->TI_BEMFIM	:= M->ZNA_BEMFIM
			M->TI_TIPMODI	:= M->ZNA_MODINI
			M->TI_TIPMODF	:= M->ZNA_MODFIM		
			M->TI_USUARIO	:= M->ZNA_USUARI
			M->TI_XCODZNA 	:= M->ZNA_CODIGO
			//campos que tem na STI e não tem na ZNA :
			M->TI_ESTRUTU := "N"
			M->TI_CCUSINI := Space(Len(STI->TI_CCUSINI))
			M->TI_CCUSFIM := Replicate("Z",Len(STI->TI_CCUSFIM))
			M->TI_CTRAINI := Space(Len(STI->TI_CTRAINI))
			M->TI_CTRAFIM := Replicate("Z",Len(STI->TI_CTRAFIM))
			M->TI_AREAINI := Space(Len(STI->TI_AREAINI))
			M->TI_AREAFIM := Replicate("Z",Len(STI->TI_AREAFIM))
			M->TI_TIPOINI := Space(Len(STI->TI_TIPOINI))
			M->TI_TIPOFIM := Replicate("Z",Len(STI->TI_TIPOFIM))
			M->TI_BLOQITE := "S" // bloqueia item 
			M->TI_BLOQFUN := "S" // bloqueia funcionário
			M->TI_BLOQFER := "S" // bloqueia ferramenta
			M->TI_ATRASAD := "S" // considera manutenção atrasada
			M->TI_SITUACA := "P"
			M->TI_TERMINO := "N"
			M->TI_TIPOMDO := "F" // Tipo de alocação MDO - F=Funcionario;E=Especialidade;
			M->TI_LUBRIFI := "N"
			M->TI_TIPACOM := "7"
			M->TI_TOLEPER := 0
				
			Processa({|lCanc330| a330GRAVA("STI",3,@lCanc330)},,,.T.)// Gravação dos Planos
			
			StaticCall(MNTA330,UnLockPlano,cA330NUM)// Elimina bloqueio feito pelo LockPlano
			 
		Next nPos
	
	End Transaction
	
	//----verifica se existe pelo menos 1 registro de STI com o código da zna senão apaga ZNA
	
	cQuery := " SELECT COUNT(*) AS QUANT FROM " + RetSqlName("STI") + " WHERE TI_XCODZNA = " + ValToSql(M->ZNA_CODIGO) + " AND D_E_L_E_T_ <> '*' "
	
	cAliasQry := GetNextAlias()
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	If (cAliasQry)->QUANT == 0
		dbSelectArea("ZNA")
		dbSetOrder(1)
		If dbSeek(xFilial("ZNA")+ M->ZNA_CODIGO)
			RecLock("ZNA",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	EndIf
	
	(cAliasQry)->(dbCloseArea())	
	
	//----end------verifica se existe pelo menos 1 registro de STI com o código da zna senão apaga ZNA
	
	cFilAnt := cFilOld 
	RestArea(aAreaSm0)
	RestArea(aArea)
Return .t.	 
//---------------------------------------------------------------------
/*/{Protheus.doc} ALL1ALT
Monta MarkBrowse para realizar alterações de Ordens de Serviço (Datas e Situação)
  
@author Maria Elisandra de Paula
@since 07/12/2015
@version P12
/*/
//------------------------------------------------------------------
User Function ALL1ALT()
	
	Local aArea:= GetArea()
	Local aCpos	:= {}
	Local aDBF	:= {}
	Local lOk   := .F.
	Local cMarca    
	
	Local aPesq := {}
	Local aCoors:= FWGetDialogSize(oMainWnd)
	Local cTrb  := GetNextAlias()
	Local oDlg, oMarkSTJ
	Local cQuery := ""
	
	//Vetor SetFields
	aAdd(aCpos,{"Filial"		,"TJ_FILIAL"	,"C",TAMSX3('TJ_FILIAL')[1]	,0})
	aAdd(aCpos,{"Ordem"			,"TJ_ORDEM"		,"C",TAMSX3('TJ_ORDEM')[1]	,0})
	aAdd(aCpos,{"Plano"			,"TJ_PLANO"		,"C",TAMSX3('TJ_PLANO')[1]	,0})
	aAdd(aCpos,{"Situação"		,"STATUS"	 	,"C",10,0}) // campo descritivo da situação - apenas visual
	aAdd(aCpos,{"Bem"			,"TJ_CODBEM"	,"C",TAMSX3('TJ_CODBEM')[1]	,0})
	aAdd(aCpos,{"Nome do Bem"	,"T9_NOME"		,"C",TAMSX3('T9_NOME')[1]	,0})
	aAdd(aCpos,{"Serviço"		,"TJ_SERVICO"	,"C",TAMSX3('TJ_SERVICO')[1],0})
	aAdd(aCpos,{"Nome do Serviço","T4_NOME"		,"C",TAMSX3('T4_NOME')[1]	,0})	
	aAdd(aCpos,{"Sequencia"		,"TJ_SEQRELA"	,"C",TAMSX3('TJ_SEQRELA')[1],0})
	aAdd(aCpos,{"Data Inicial"	,"TJ_DTMPINI"	,"D",TAMSX3('TJ_DTMPINI')[1],0,,,.t.})
	aAdd(aCpos,{"Data Final"	,"TJ_DTMPFIM"	,"D",TAMSX3('TJ_DTMPFIM')[1],0})
	aAdd(aCpos,{"Data Alterada"	,"TJ_XDATALT"	,"C",3,0})
	aAdd(aCpos,{"Dt. Inicial Anterior" ,"TJ_XDTINIC"	,"D",TAMSX3('TJ_XDTINIC')[1],0,,,.t.})
	aAdd(aCpos,{"Dt. Final Anterior "	 ,"TJ_XDTFIM"	,"D",TAMSX3('TJ_XDTFIM')[1],0})

	//Vetor SetSeek
	aAdd(aPesq,{"Filial" 			,{{"TJ_FILIAL+TJ_PLANO+TJ_ORDEM+TJ_CODBEM"	,"C" , TAMSX3('TJ_FILIAL')[1] 	, 0 ,"","@!"}}})
	aAdd(aPesq,{"Ordem" 			,{{"TJ_ORDEM"	,"C" , TAMSX3('TJ_ORDEM')[1] 	, 0 ,"","@!"}}})
	aAdd(aPesq,{"Plano" 			,{{"TJ_PLANO"	,"C" , TAMSX3('TJ_PLANO')[1] 	, 0 ,"","@!"}}})
	aAdd(aPesq,{"Bem"				,{{"TJ_CODBEM"	,"C" , TAMSX3('TJ_CODBEM')[1] 	, 0 ,"","@!"}}})
	aAdd(aPesq,{"Serviço"			,{{"TJ_SERVICO" ,"C" , TAMSX3('TJ_SERVICO')[1]	, 0 ,"","@!"}}})
	aAdd(aPesq,{"Data Inicial"		,{{"TJ_DTMPINI" ,"D" , TAMSX3('TJ_DTMPINI')[1]	, 0 ,"","99/99/9999"}}})
	aAdd(aPesq,{"Data Final"		,{{"TJ_DTMPFIM" ,"D" , TAMSX3('TJ_DTMPFIM')[1]	, 0 ,"","99/99/9999"}}})
	
	//Vetor NGCRIATRB
	aAdd(aDBF,{ "OK"		, "C" ,01, 0,"" })
	aAdd(aDBF,{ "TJ_FILIAL"	, "C" ,TAMSX3('TJ_FILIAL')[1]	, 0,""})
	aAdd(aDBF,{ "TJ_ORDEM"	, "C" ,TAMSX3('TJ_ORDEM')[1]	, 0,""})
	aAdd(aDBF,{ "TJ_PLANO"	, "C" ,TAMSX3('TJ_PLANO')[1]	, 0,""})
	aAdd(aDBF,{ "TJ_SITUACA", "C" ,1, 0,""})
	aAdd(aDBF,{ "STATUS"	, "C" ,10, 0,""})
	aAdd(aDBF,{ "TJ_CODBEM"	, "C" ,TAMSX3('TJ_CODBEM')[1]	, 0,""})
	aAdd(aDBF,{ "T9_NOME"	, "C" ,TAMSX3('T9_NOME')[1]		, 0,""})
	aAdd(aDBF,{ "TJ_SERVICO", "C" ,TAMSX3('TJ_SERVICO')[1]	, 0,""})
	aAdd(aDBF,{ "T4_NOME"	, "C" ,TAMSX3('T4_NOME')[1]		, 0,""})	
	aAdd(aDBF,{ "TJ_SEQRELA", "C" ,TAMSX3('TJ_SEQRELA')[1]	, 0,""})
	aAdd(aDBF,{ "TJ_DTMPINI", "D" ,TAMSX3('TJ_DTMPINI')[1]	, 0,""})
	aAdd(aDBF,{ "TJ_DTMPFIM", "D" ,TAMSX3('TJ_DTMPFIM')[1]	, 0,""})
	aAdd(aDBF,{ "MODIFIC", "C" ,1	, 0,""})
	aAdd(aDBF,{ "ALTERDATA" , "C" ,1	, 0,""})
	aAdd(aDBF,{ "TJ_XDATALT", "C" ,3	, 0,""})		
	aAdd(aDBF,{ "TJ_XDTINIC", "D" ,TAMSX3('TJ_DTMPINI')[1]	, 0,""})
	aAdd(aDBF,{ "TJ_XDTFIM", "D"  ,TAMSX3('TJ_DTMPINI')[1]	, 0,""})
	
	
	cQuery := " SELECT TJ_FILIAL,TJ_ORDEM, TJ_PLANO, TJ_CODBEM, T9_NOME,TJ_SERVICO, T4_NOME, TJ_SEQRELA, TJ_DTMPINI, TJ_DTMPFIM , TJ_SITUACA,"
	cQuery += "  ' ' AS OK , 'Pendente' AS STATUS , 'N' AS MODIFIC , 'N' AS ALTERDATA,   " 
	cQuery += "  CASE WHEN TJ_XDATALT = '1' THEN 'Sim'  ELSE 'NÃO' END AS TJ_XDATALT , "
	
	cQuery += "  CASE WHEN TJ_XDTINIC = '' THEN TJ_DTMPINI ELSE TJ_XDTINIC END AS TJ_XDTINIC, "
	cQuery += "  CASE WHEN TJ_XDTFIM = '' THEN TJ_DTMPFIM ELSE TJ_XDTFIM END AS TJ_XDTFIM "
	   
	cQuery += " FROM " + RetSqlName("STJ") + " STJ "
	cQuery += " 	JOIN " + RetSqlName("ST9") + " ST9 ON T9_CODBEM = TJ_CODBEM AND ST9.D_E_L_E_T_ = '' AND TJ_FILIAL = T9_FILIAL " 
	cQuery += " 	JOIN " + RetSqlName("ST4") + " ST4 ON TJ_SERVICO = T4_SERVICO AND ST4.D_E_L_E_T_ = '' "  
	cQuery += " 	JOIN " + RetSqlName("STI") + " STI ON TI_PLANO = TJ_PLANO AND STI.D_E_L_E_T_ = '' AND  TJ_FILIAL = TI_FILIAL "
	cQuery += " 	AND STI.TI_XCODZNA = " + ValToSql(ZNA->ZNA_CODIGO)
	cQuery += " WHERE STJ.D_E_L_E_T_ = '' AND TJ_SITUACA = 'P' AND TJ_TERMINO = 'N'" 
	
	cARQ   := NGCRIATRB(aDBF,{	"TJ_FILIAL+TJ_PLANO+TJ_ORDEM+TJ_SERVICO+TJ_CODBEM",;
								"TJ_ORDEM",;
								"TJ_PLANO",;
								"TJ_CODBEM", ;
								"TJ_SERVICO", ;
								"DTOS(TJ_DTMPINI)",;
								"DTOS(TJ_DTMPFIM)",;
								"MODIFIC"},cTrb)
	
	SqlToTrb(cQuery,aDBF,cTrb)
	
	
	//Monta MarkBrowse de acordo com dados da query
	(cTrb)->(dbGoTop())
	
	Define Font oFontA Name "Arial" Size 07,20 BOLD 
	Define Font oFont Name "Arial" Size 30,10 BOLD
	Define MsDialog oDlg Title 'Ordens de Serviço' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oDlg:lEscClose := .F.//não permite fechar a tela com a tecla esc
		
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlg,.F.,.T.)
		
		oFWLayer:AddLine( "ALLLINE" , 100 , .F. )
		oFWLayer:AddCollumn( "ALLCOL", 100, .F., "ALLLINE" )
		oPanel := oFWLayer:getColPanel( "ALLCOL" , "ALLLINE" )
	
		oMarkSTJ := FWMarkBrowse():New()
			oMarkSTJ:SetOwner(oPanel)
			oMarkSTJ:SetAlias(cTrb)
			oMarkSTJ:SetTemporary(.T.)
			oMarkSTJ:SetDescription('Ordens de Serviço')
			oMarkSTJ:SetMenuDef('')
			oMarkSTJ:SetFieldMark('OK')//Indica o campo que deverá ser atualizado com a marca no registro
			oMarkSTJ:SetFields(aCpos)
			oMarkSTJ:SetSeek(.T.,aPesq)
			oMarkSTJ:SetWalkThru(.F.)
			oMarkSTJ:SetAmbiente(.F.)
			oMarkSTJ:SetAllMark({|| oMarkSTJ:AllMark()})
			oMarkSTJ:DisableSaveConfig()
			oMarkSTJ:DisableConfig()
			oMarkSTJ:AddButton("Alterar Data"	, {||fAlterar(oMarkSTJ,cTrb )}					,,3,(cTrb)->(Recno()))
			oMarkSTJ:AddButton("Liberar O.S"	, {||fSituaca(oMarkSTJ,cTrb,"L","Liberada")}	,,4,(cTrb)->(Recno()))
			oMarkSTJ:AddButton("Cancelar O.S"	, {||fSituaca(oMarkSTJ,cTrb,"C","Cancelada")}	,,2,(cTrb)->(Recno()))
			oMarkSTJ:AddButton("Confirmar"		, {||fGravacao(oMarkSTJ,cTrb) .And. oDlg:End() },,3,(cTrb)->(Recno()))


		oMarkSTJ:Activate()
				
	ACTIVATE MsDIALOG oDlg 

	(cTrb)->(dbCloseArea())
	RestArea(aArea)
Return 
//---------------------------------------------------------------------
/*/{Protheus.doc} fSituaca
Altera a situação das ordens de serviço para ('Liberada' ou 'Cancelada') ou 'Pendente' 

@author Maria Elisandra de Paula
@since 07/12/2015
@version 2
/*/
//------------------------------------------------------------------
Static Function fSituaca(oMarkSTJ, cTrb,cSituaca,cDescri)
	
	Local aArea := (cTrb)->(GetArea())
	Local nCount:= 0
	
	cMarca   := oMarkSTJ:Mark() 
	dbSelectArea(cTrb)
	dbGoTop()
	While !Eof()
		If oMarkSTJ:IsMark(cMarca) 
			nCount++
			If (ctrb)->TJ_SITUACA  <> cSituaca
			
				//Altera situação das ordens marcadas e as desmarca 
				RecLock(ctrb, .f.)
				(ctrb)->TJ_SITUACA  := cSituaca
				(ctrb)->STATUS      := cDescri
				(ctrb)->OK          := " "
				(ctrb)->MODIFIC     := "S"
				MsUnLock()
			Else
				
				RecLock(ctrb, .f.)
				(ctrb)->TJ_SITUACA  := "P"
				(ctrb)->STATUS      := "Pendente"
				(ctrb)->OK          := " "
				
				If (ctrb)->ALTERDATA == 'N'
					(ctrb)->MODIFIC     := "N"
				EndIf
				MsUnLock()
			EndIf					
		EndIf
	   (cTrb)->(dbSkip())
	EndDo
	If nCount > 0
		RestArea(aArea)
		oMarkSTJ:Refresh(.t.)
	Else
		MsgInfo("Não há ordens pendentes selecionadas!")
		RestArea(aArea)
	EndIf
Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} fAlterar
Monta tela para alterar data da ordem de serviço selecionada (altera na TRB)

@author Maria Elisandra de Paula
@since 09/12/2015
@version P12
/*/
//---------------------------------------------------------------------
Static Function fAlterar(oMarkSTJ,cTrb)
	Local aArea := (cTrb)->(GetArea())
	Local oDlg 
	Local lOk := .f.
	
	M->TJ_DTMPINI := (cTrb)->TJ_DTMPINI
	M->TJ_DTMPFIM := (cTrb)->TJ_DTMPFIM
	
	dbSelectArea(cTrb)
		
	Define MsDialog oDlg Title "Alterar Data O.S:" + (cTrb)->TJ_ORDEM From 000,000 To 90,350 Pixel
	
		@ 12,03 Say "Data Inicial" Of oDlg Pixel  	
		@ 09,33  MsGet M->TJ_DTMPINI Picture "99/99/9999" Valid NaoVazio() size 50,07 Of oDlg Pixel HasButton
				
		@ 12,93 Say "Data Final"  Of oDlg Pixel	 
		@ 09,123 MsGet M->TJ_DTMPFIM Picture "99/99/9999" Valid NaoVazio() size 50,07 Of oDlg Pixel HasButton
		
		TButton():New(30, 65 ,"Confirmar", oDlg,{||If(lOk := fValData(),oDlg:End(),'')} , 50 , 12 ,,,,.T.,,,,,,)
		TButton():New(30, 120,"Sair"	 , oDlg,{|| oDlg:End()} , 50 , 12 ,,,,.T.,,,,,,)
	ACTIVATE MSDIALOG oDlg Center
	
	//se tiver alteração de alguma data altera a trb
	If lOk .And. ((ctrb)->TJ_DTMPINI <> M->TJ_DTMPINI .or. (ctrb)->TJ_DTMPFIM <> M->TJ_DTMPFIM)    
		
		RecLock(ctrb, .f.)
		(ctrb)->TJ_DTMPINI := M->TJ_DTMPINI
		(ctrb)->TJ_DTMPFIM := M->TJ_DTMPFIM
		(ctrb)->MODIFIC    := "S"
		(ctrb)->ALTERDATA  := "S"
		MsUnLock()

	EndIf
	
	RestArea(aArea) 	
	oMarkSTJ:Refresh(.t.)
Return .t.
//--------------------------------------------------------------------------------------
/*/{Protheus.doc} fGravacao
Verifica na TRB quais registros foram alterados e realiza as gravações no banco de dados 

@author Maria Elisandra de Paula
@since 11/12/2015
@version P12
/*/
//---------------------------------------------------------------------
Static Function fGravacao(MarkSTJ,cTrb)
	
	Local aArea:= GetArea()
	Local aModific := {}		
	Local cFilOld  := cFilAnt
	Local nDifData := 0
	Local i := 1
	Local aSIM	   := {} 
	Local lTemTTY := NGCADICBASE("TTY_ORDEM","A","TTY",.F.)
	//variáveis para impressão do log	
	Private cNomPro := "Plano de Manutenção"
	Private cTitulo := "Ordens de Serviço Modificadas"   
	Private cCabec1 := {{"Empresa",45},{"O.S",900},{"Bem",1100},{"Nome do Bem",1300},{"Serviço",1800},{"Nome do Serviço",2000},{"Status",2500}, {"Data Prevista",2800}}
	Private cCabec2 := {}
	
	//inicio das alterações das ordens modificadas na MarkBrowse
	Begin Transaction				
		dbSelectArea(cTrb)
		dbSetOrder(8)
		dbGoTop()
		dbSeek("S")
		While .Not. (cTrb)->(EOF()) .And. (cTrb)->MODIFIC == "S"
			
			dbSelectArea("STJ")
			dbSetOrder(01)
			If dbSeek((cTrb)->TJ_FILIAL + (cTrb)->TJ_ORDEM + (cTrb)->TJ_PLANO)
				
				//vetor aModific utilizado para impressão das ordens modificadas
				aAdd(aModific,{	(cTrb)->TJ_FILIAL, (cTrb)->TJ_ORDEM,(cTrb)->TJ_CODBEM,(cTrb)->T9_NOME,(cTrb)->TJ_SERVICO, ;
								(cTrb)->T4_NOME,(cTrb)->STATUS,(cTrb)->TJ_DTMPINI,(cTrb)->TJ_DTMPFIM})

						
				cFilAnt  := (cTrb)->TJ_FILIAL
				
				If (cTrb)->TJ_SITUACA == "C"  
				
					If NGDELETOS(STJ->TJ_ORDEM,STJ->TJ_PLANO,"Cancelamento de O.S. pela rotina:" + "U_ALL1A001")
			
						//Deleta o historico do contador 1 e 2 se tiver registro relacionado a OS
						If STJ->TJ_POSCONT > 0 .And. !Empty(STJ->TJ_HORACO1)
							MNT470EXCO(STJ->TJ_CODBEM,STJ->TJ_DTORIGI,STJ->TJ_HORACO1,1)
						EndIf
			   
						If STJ->TJ_POSCON2 > 0 .And. !Empty(STJ->TJ_HORACO2)
							MNT470EXCO(STJ->TJ_CODBEM,STJ->TJ_DTORIGI,STJ->TJ_HORACO2,2)
						EndIf
		
					EndIf
				
				Else
					
					nDifData := 0
					nDifData := (cTrb)->TJ_DTMPINI - STJ->TJ_DTMPINI
					
					//variáveis utilizadas na função A340ASIM			
					M->TI_PLANO   := (cTrb)->TJ_PLANO
					M->TI_DATAPLA := ZNA->ZNA_DTPLAN
	
					//Vetor utilizado na função A340ASIM para armazenar as ordens que serão modificadas
					aSIM := {}
			
					//realiza gravação das datas 
					RecLock("STJ",.F.)
			
					If (ctrb)->ALTERDATA == "S"
						STJ->TJ_XDTINIC := STJ->TJ_DTMPINI // campo para armazenar a data antes de ser modificadas
						STJ->TJ_XDTFIM  := STJ->TJ_DTMPFIM // campo para armazenar a data antes de ser modificadas
						STJ->TJ_XDATALT := "1"
					Endif
			
					STJ->TJ_DTMPINI := (cTrb)->TJ_DTMPINI
					STJ->TJ_DTMPFIM := (cTrb)->TJ_DTMPFIM
					
					STJ->(MsUnlock())
		   															
					Aadd(aSIM,{STJ->TJ_ORDEM,STJ->TJ_CODBEM ,STJ->TJ_CCUSTO,STJ->TJ_DTMPINI,nDifData,0,;
							"cORDEM",STJ->TJ_DTMPFIM,STJ->TJ_SERVICO,STJ->TJ_SEQRELA,STJ->TJ_DTORIGI," "})
			
					//Inicio dos processos para liberação
					If (cTrb)->TJ_SITUACA == "L"     
						
						//função para processar a liberação das ordens de serviço
						PROCESSA({|lEND| A340ASIM(aSIM)})
						
					Else
						//realiza alterações nas stl
						//inicio - cópia do mnta340
						
						//---------------------------------------------------------------
					  	// Muda o Numero da Ordem do STL                               
					  	//---------------------------------------------------------------
					  	dbSelectArea("STL")
					  	dbSetOrder(1)
						dbSeek(xFILIAL('STL')+aSIM[i][1]+M->TI_PLANO)
					
					  	While !Eof() .And. STL->TL_FILIAL == xFILIAL('STL') .And.;
					    	STL->TL_ORDEM == aSIM[i][1] .And. STL->TL_PLANO == M->TI_PLANO
					
					     	dbSelectArea("STL")
					     	RecLock("STL",.F.)
					     	STL->TL_DTINICI := STL->TL_DTINICI + aSIM[i][5]
					     	STL->TL_HOINICI := MTOH(HTOM(STL->TL_HOINICI) + aSIM[i][6])
					     	If STL->TL_TIPOREG != "P"
					    		STL->TL_DTFIM := STL->TL_DTFIM + aSIM[i][5]
						        STL->TL_HOFIM := MTOH(HTOM(STL->TL_HOFIM) + aSIM[i][6])
					     	Else
					        	STL->TL_DTFIM := STL->TL_DTINICI
					        	STL->TL_HOFIM := STL->TL_HOINICI
					     	Endif
					     	MsUnLock("STL")
					     	STL->(Dbskip())
					  	EndDo
					
						//---------------------------------------------------------------
	  					// Muda o Numero da O.S.  do STK                               
	  					//---------------------------------------------------------------
						dbSelectArea("STK")
						dbSetOrder(1)
						dbSeek(xFILIAL('STK')+aSIM[i][1]+M->TI_PLANO)
						While !Eof() .And. STK->TK_FILIAL == xFILIAL('STK') .And.;
								STK->TK_ORDEM == aSIM[i][1] .And. STK->TK_PLANO == M->TI_PLANO
							dbSelectArea("STK")
							RecLock("STK",.F.)
							STK->TK_DATAINI := STK->TK_DATAINI + aSIM[i][5]
							STK->TK_HORAINI := MTOH(HTOM(STK->TK_HORAINI) + aSIM[i][6])
							STK->TK_DATAFIM := STK->TK_DATAFIM + aSIM[i][5]
							STK->TK_HORAFIM := MTOH(HTOM(STK->TK_HORAFIM) + aSIM[i][6])
							MsUnLock("STK")
							STK->(Dbskip())
						EndDo
					
					  	//---------------------------------------------------------------
					  	// Muda o Numero da O.S.  do TTY                               
					  	//---------------------------------------------------------------
						If lTemTTY
							dbSelectArea("TTY")
							dbSetOrder(1)
							dbSeek(xFILIAL("TTY")+aSIM[i][1]+M->TI_PLANO)
							While !Eof() .And. TTY->TTY_FILIAL == xFILIAL("TTY") .And.;
								TTY->TTY_ORDEM == aSIM[i][1] .And. TTY->TTY_PLANO == M->TI_PLANO
								dbSelectArea("TTY")
								RecLock("TTY",.F.)
								TTY->TTY_DTINI := TTY->TTY_DTINI + aSIM[i][5]
								TTY->TTY_HRINI := MTOH(HTOM(TTY->TTY_HRINI) + aSIM[i][6])
								TTY->TTY_DTFIM := TTY->TTY_DTFIM + aSIM[i][5]
								TTY->TTY_HRFIM := MTOH(HTOM(TTY->TTY_HRFIM) + aSIM[i][6])
								MsUnLock("TTY")
								TTY->(Dbskip())
							EndDo
						Endif
					
					  	//---------------------------------------------------------------
					  	// Muda o Numero da O.S.  do ST3                               
					  	//---------------------------------------------------------------
						
						dbSelectArea("ST3")
						dbSetOrder(2)
						dbSeek(xFilial('ST3') + aSIM[i][1] + m->TI_PLANO)
						While !Eof() .And. ST3->T3_FILIAL == xFILIAL("ST3") .And.;
							ST3->T3_ORDEM == aSIM[i][1] .And. ST3->T3_PLANO == M->TI_PLANO
							
							dbSelectArea("ST3")
							RecLock("ST3",.F.)
							ST3->T3_DTINI := ST3->T3_DTINI + aSIM[i][5]
							ST3->T3_HRINI := MTOH(HTOM(ST3->T3_HRINI) + aSIM[i][6])
							ST3->T3_DTFIM := ST3->T3_DTFIM + aSIM[i][5]
							ST3->T3_HRFIM := MTOH(HTOM(ST3->T3_HRFIM) + aSIM[i][6])
							MsUnLock("ST3")
							ST3->(Dbskip())
						EndDo
					  //fim - cóppia do mnta340
					EndIf
				EndIf
			EndIf
			
			(cTrb)->(dbSkip())
		EndDo
	End Transaction
	
	If Len(aModific) > 0 	
		If MsgYesNo("Deseja imprimir o relatório de registros alterados?")
			NGIMPRGRAFI({|| fImprimir(aModific)},.t.) 	
		EndIf
	Else
		MsgInfo("Não há alterações a realizar!")
	Endif
	cFilAnt := cFilOld
	RestArea(aArea)
Return .t. 
//---------------------------------------------------------------------
/*/{Protheus.doc} fImprimir
Imprime as ordens modificadas 

@author Maria Elisandra de Paula
@since 14/12/2015
@version P12
/*/
//---------------------------------------------------------------------
Static Function fImprimir(aModific)
	Local nImp
	Local cFilDesc := ""
	
	For nImp := 1 To Len(aModific)
		
		cFilDesc := ""
		If Len(NGSEEKSM0(cEmpAnt + aModific[nImp][1],{"M0_FILIAL"})) > 0
			cFilDesc := NGSEEKSM0(cEmpAnt + aModific[nImp][1],{"M0_FILIAL"})[1]
		EndIf
		
		NGCABECEMP()
		
		oPrint:Say(Li,45,aModific[nImp][1] + " - " + cFilDesc ,oCouNew10) // Filial    	
	   	oPrint:Say(Li,900,aModific[nImp][2],oCouNew10) // OS 
	   	oPrint:Say(Li,1100,aModific[nImp][3],oCouNew10) // Bem 
	   	oPrint:Say(Li,1300,Alltrim(aModific[nImp][4]),oCouNew10) // Nome do Bem 
	   	oPrint:Say(Li,1800,aModific[nImp][5],oCouNew10)//Serviço
	   	oPrint:Say(Li,2000,Alltrim(aModific[nImp][6]),oCouNew10) //Nome do Serviço
	   	oPrint:Say(Li,2500,aModific[nImp][7],oCouNew10) //Status
	   	oPrint:Say(Li,2800,Dtoc(aModific[nImp][8] ) + " - " + Dtoc(aModific[nImp][9]),oCouNew10)// Data Prevista
	   	
	Next nImp
	
Return .t.
//---------------------------------------------------------------------
/*/{Protheus.doc} ALL1AVAL()
- Valida campo bem  - ZNA_BEMINI e  ZNA_BEMFIM 
- Carrega campos visuais ZNA_DBEMIN e ZNA_DBEMFI

@param 	nParam - 1 (parametro inicial) 2(parametro final)  
		cParam1 - conteúdo do campo 'inicio' a ser validado
		cParam2 - conteúdo do campo 'fim' a ser validado
		
@author Maria Elisandra de Paula
@since 14/12/2015
@version P12
/*/
//---------------------------------------------------------------------
User Function ALL1AVAL(nParam,cParam1,cParam2,cTab)
	
	Local aArea      := GetArea()
	Local lOk        := .t.
	Local cCodigo    := If(nParam == 1,cParam1,cParam2)
	Local cQuery 	:= ""
	Local cAliasQry := ""
	
	If nParam == 1 
		If Empty(cCodigo)
			Return .t.
		 EndIf
	Else
		If NaoVazio() .And. cCodigo == REPLICATE("Z",Len(cCodigo))
			Return .t.
		Endif 
	EndIf

	If cTab == 'SM0'
		dbSelectArea('SM0') 
		dbSetOrder(1)
		If !dbSeek(cCodigo)
			lOk := .F.
		EndIf
	Else	
		
		If cTab == "ST9"
			cCampo := "T9_CODBEM"
		ElseIf cTab == "ST4"
			cCampo := "T4_SERVICO" 
		ElseIf cTab == "ST6"
			cCampo := "T6_CODFAMI" 
		ElseIf cTab == "TQR" 
			cCampo := "TQR_TIPMOD"  
		EndIf

		cAliasQry := GetNextAlias() 

		cQuery    := " SELECT COUNT(*) QUANT FROM " + RetSqlName(cTab) + " WHERE " + cCampo + " = " + ValtoSql(cCodigo) + " AND D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

		If (cAliasQry)->QUANT == 0
			lOk := .F.
		EndIf
		
		(cAliasQry)->(dbCloseArea())
		
	EndIf		
	
	If lOk 
		If cParam1 > cParam2
			lOk := .F.
			If nParam == 1 
				ShowHelpDlg("Atenção",{"Valor deste campo é maior que o campo posterior correspondente."},1,{"Informe um valor correto."},2)
			Else
				ShowHelpDlg("Atenção",{"Valor deste campo é menor que o campo anterior correspondente."},1,{"Informe um valor correto."},2)
			EndIf
		EndIf
	Else	
		Help(" ",1,"REGNOIS")
	
	EndIf
	
	RestArea(aArea)

Return lOk
//---------------------------------------------------------------------
/*/{Protheus.doc} ALLNOME()
Retorna descrição do código

@param 	cTab - Tabela a ser pesquisada
		cCodigo - campo a ser pesquisado
	
@author Maria Elisandra de Paula
@since 14/12/2015
@version P12
/*/
//---------------------------------------------------------------------
User Function ALLNOME(cTab,cCodigo)
	
	Local aArea     := GetArea()
	Local cNome   	:= "" 			
	Local cQuery    := ""
	Local cAliasQry := GetNextAlias() 
	
	If cTab == "ST9"
		cQuery    := " SELECT T9_NOME NOME FROM " + RetSqlName("ST9") + " WHERE T9_CODBEM = " + ValtoSql(cCodigo) + " AND D_E_L_E_T_ <> '*' "
	ElseIf cTab == "ST4"
		cQuery    := " SELECT T4_NOME NOME FROM " + RetSqlName("ST4") + " WHERE T4_SERVICO = " + ValtoSql(cCodigo) + " AND D_E_L_E_T_ <> '*' "
	ElseIf cTab == "ST6"
		cQuery    := " SELECT T6_NOME NOME FROM " + RetSqlName("ST6") + " WHERE T6_CODFAMI = " + ValtoSql(cCodigo) + " AND D_E_L_E_T_ <> '*' "
	ElseIf cTab == "TQR" 
		cQuery    := " SELECT TQR_DESMOD NOME FROM " + RetSqlName("TQR") + " WHERE TQR_TIPMOD = " + ValtoSql(cCodigo) + " AND D_E_L_E_T_ <> '*' "
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
	
	If .Not. Eof() 
		cNome := (cAliasQry)->NOME
	EndIf
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return cNome
//---------------------------------------------------------------------
/*/{Protheus.doc} fValData()
Valida data da tela de alteração 
	
@author Maria Elisandra de Paula
@since 07/01/16
@version 1
/*/
//---------------------------------------------------------------------
Static Function fValData()
	Local lRet := .t.
	
	If M->TJ_DTMPINI > M->TJ_DTMPFIM
		MsgAlert("A Data Final deve ser maior ou igual a Data Inicial.")
		lRet := .f.
	EndIf

Return lRet
//---------------------------------------------------------------------
/*/{Protheus.doc} ALL001GN
Função para montar a tela da consulta padrão

@author William Rozin Gaspar
@author Maria Elisandra de paula
@since 11/09/2014
/*/
//---------------------------------------------------------------------
User Function ALL001GN()
 
    Local cQuery := ""
    Local aColums := {}
    Local oDialog, oPnlPai, oFWBrowse
    Local aPesq	:= {}
 	
    Private cAliasTemp := GetNextAlias()
	
	aadd(aPesq,{"Filial+Cod.Bem",{{"T9_FILIAL+T9_CODBEM","C" ,TAMSX3('T9_FILIAL')[1] + TAMSX3('T9_CODBEM')[1],0,"","@!"}}})
	aadd(aPesq,{"Código do Bem",{{"T9_CODBEM","C" ,TAMSX3('T9_CODBEM')[1],0,"","@!"}}})
	aadd(aPesq,{"Descrição",{{"T9_NOME","C" ,TAMSX3('T9_NOME')[1],0,"","@!"}}})
		       		
    cQuery := " SELECT T9_FILIAL , T9_CODBEM , T9_NOME  FROM " + RetSqlName("ST9") + " WHERE "
	cQuery += " T9_FILIAL BETWEEN " + ValtoSql(Substr((M->ZNA_EMPINI),3,TAMSX3("ZNA_EMPINI")[1])) 
	cQuery += " AND " + ValtoSql(Substr((M->ZNA_EMPFIM),3,TAMSX3("ZNA_EMPFIM")[1]))
	cQuery += " AND D_E_L_E_T_ <> '*' "
    cQuery := ChangeQuery(cQuery)
    
    DEFINE MSDIALOG oDialog TITLE "Bens" FROM 0,0 TO 500,700 PIXEL OF oMainWnd
    
        oPnlPai := TPanel():New(,,,oDialog,,,,,,,,.F.,.F.)
            oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT
            
            //Monta o Browse
            DEFINE FWBROWSE oFWBrowse DATA QUERY ALIAS cAliasTemp QUERY cQuery INDEXQUERY {'T9_FILIAL+T9_CODBEM','T9_CODBEM','T9_NOME'} of oPnlPai
            	oFWBrowse:DisableConfig()//Desabilita botao de configuracao
				oFWBrowse:DisableReport()                      
               	oFWBrowse:SetSeek(,aPesq)
                oFWBrowse:SetDoubleClick({|| _CODRET := (cAliasTemp)->T9_CODBEM, oDialog:End()})                
            	
            	ADD COLUMN oColumn DATA {|| (cAliasTemp)->T9_FILIAL}	Title "Filial"		PICTURE '@!' 	SIZE TAMSX3('T9_FILIAL')[1]	TYPE 'C' Of oFWBrowse
            	ADD COLUMN oColumn DATA {|| (cAliasTemp)->T9_CODBEM}	Title "Código"		PICTURE '@!' 	SIZE TAMSX3('T9_CODBEM')[1]	TYPE 'C' Of oFWBrowse
                ADD COLUMN oColumn DATA {|| (cAliasTemp)->T9_NOME}		Title "Descrição"	PICTURE '@!' 	SIZE TAMSX3('T9_NOME')[1]	TYPE 'C' Of oFWBrowse
                 
			ACTIVATE FWBROWSE oFWBrowse
    Activate Dialog oDialog On Init EnchoiceBar(oDialog,/*confirma*/{|| _CODRET := (cAliasTemp)->T9_CODBEM, oDialog:End()},/*Cancela*/ {|| _CODRET := Space(16), oDialog:End()}) Centered 
    
Return .T.
