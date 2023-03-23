#Include 'Protheus.ch'

//-------------------------------------------------------------------------------------------------------------------------------------------------
/*
@author Breno Ferreira Menezes
@since 29/02/2016
@version P11
@Param Não Possui
@Return Active da Tela
@obs
Relatório Requisição Solicitado x Atendido

Programador     Data       Motivo

/*/
//-------------------------------------------------------------------------------------------------------------------------------------------------
User Function FSESTR01()

Local   oBreak
Local   oBreak1
Local 	aArea  		:= GetArea()

Private oReport
Private cAliasQry   := GetNextAlias()
Private cPerg       := "FSESTR01" //nome da pergunta
Private aDad		:= {}

Private nTQtdSol 	:= 0
Private nTQtdAte 	:= 0
Private	nTQtdPie 	:= 0
Private	nTConPie 	:= 0

Private nCQtdSol 	:= 0
Private nCQtdAte 	:= 0
Private	nCQtdPie 	:= 0
Private	nCConPie 	:= 0

Private nFQtdSol 	:= 0
Private nFQtdAte 	:= 0
Private	nFQtdPie 	:= 0
Private	nFConPie 	:= 0

Private cFilSCP		:= ""
//Private cFilSB1		:= ""

FCriaPerg()
If !Pergunte(cPerg,.T.)
	Return
EndIf

oReport := TReport():New("FSESTR01","Requisicao Solicitado x Atendido",,{|oReport| FPrintReport()},"Requisicao Solicitado x Atendido")
oReport:nFontBody := 8
oReport:SetLandScape()

oSection1 := TRSection():New(oReport,"Cab",{cAliasQry,"SCP"})
TRCell():New(oSection1,"QUEBRA"				,cAliasQry,""       					,,1)
TRCell():New(oSection1,"CODIGO"				,cAliasQry,"Codigo"   					,,10)
TRCell():New(oSection1,"CENTROCUSTO"		,cAliasQry,"Centro de Custo"   			,,200)

oSection2 := TRSection():New(oReport,"TFam",{cAliasQry,"SCP"})
TRCell():New(oSection2,"FAMILIA"			,cAliasQry,"Familia"					,,60,,,,.T.,,,,,,,,.f.,,)
oSection2:SetLineStyle()

oSection3 := TRSection():New(oReport,"Fam",{cAliasQry,"SCP"})
TRCell():new(oSection3,"QUEBRA1"			,,"","@!",5,/*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,.f.)
TRCell():New(oSection3,"PRODUTO"			,cAliasQry,"Produto"  				,,30,,,,.f.,,,,,,,,.f.,,)
TRCell():New(oSection3,"DESCRICAO"			,cAliasQry,"Descr"  					,,60)
TRCell():New(oSection3,"UNIDADE"			,cAliasQry,"UN"	 	 				,,4)
TRCell():New(oSection3,"QUANTSOL"			,cAliasQry,"Qtd Solic."				,PesqPict("SCP","CP_QUANT"),30)
TRCell():New(oSection3,"QUANTATE"			,cAliasQry,"Qtd Atend."				,PesqPict("SCP","CP_QUANT"),30)
TRCell():New(oSection3,"QUANTPIERE"		,cAliasQry,"Qtd Emp Est Pleres"  	,PesqPict("SCP","CP_QUANT"),30)
TRCell():New(oSection3,"CONSPIERE"			,cAliasQry,"Qtd Cons.Pleres"		,PesqPict("SCP","CP_QUANT"),30)

oSection3:SetLeftMargin(20)

//Retorno de filtros de usuário
cFilSCP := oReport:Section(1):GetSqlExp("SCP")
//cFilSB1 := oReport:Section(1):GetSqlExp("SB1")

//Totalizador

oBreak1 := TRBreak():New(oSection2,oSection2:Cell("FAMILIA"),"Total Familia",.F.)
TRFunction():New(oSection3:Cell("QUANTSOL")		,,"ONPRINT",oBreak1,,PesqPict("SCP","CP_QUANT"),{|| nFQtdSol },.F.,.F.,.F.)
TRFunction():New(oSection3:Cell("QUANTATE")		,,"ONPRINT",oBreak1,,PesqPict("SCP","CP_QUANT"),{|| nFQtdAte },.F.,.F.,.F.)
TRFunction():New(oSection3:Cell("QUANTPIERE")	,,"ONPRINT",oBreak1,,PesqPict("SCP","CP_QUANT"),{|| nFQtdPie },.F.,.F.,.F.)
TRFunction():New(oSection3:Cell("CONSPIERE")	,,"ONPRINT",oBreak1,,PesqPict("SCP","CP_QUANT"),{|| nFConPie },.F.,.F.,.F.)
oSection2:SetLeftMargin(10)

oBreak := TRBreak():New(oSection1,oSection1:Cell("CODIGO"),"Total CC",.F.)
TRFunction():New(oSection3:Cell("QUANTSOL")		,,"ONPRINT",oBreak,,PesqPict("SCP","CP_QUANT"),{|| nCQtdSol },.F.,.F.,.F.)
TRFunction():New(oSection3:Cell("QUANTATE")		,,"ONPRINT",oBreak,,PesqPict("SCP","CP_QUANT"),{|| nCQtdAte },.F.,.F.,.F.)
TRFunction():New(oSection3:Cell("QUANTPIERE")	,,"ONPRINT",oBreak,,PesqPict("SCP","CP_QUANT"),{|| nCQtdPie },.F.,.F.,.F.)
TRFunction():New(oSection3:Cell("CONSPIERE")	,,"ONPRINT",oBreak,,PesqPict("SCP","CP_QUANT"),{|| nCConPie },.F.,.F.,.F.)


oSectionT := TRSection():New (oReport, "Total Geral", {""} )
oCell := TRCell():New(oSectionT, "BREAK", "", "Break"        , "@!", 16, .T./*lPixel*/, /*code-block de impressao*/ )
oBreakT := TRBreak():New(oSectionT,oSectionT:Cell("BREAK"),"Total Geral",.F.)
TRFunction():New(oSection3:Cell("QUANTSOL")		,,"ONPRINT",oBreakT,,PesqPict("SCP","CP_QUANT"),{|| nTQtdSol },.F.,.F.,.F.)
TRFunction():New(oSection3:Cell("QUANTATE")		,,"ONPRINT",oBreakT,,PesqPict("SCP","CP_QUANT"),{|| nTQtdAte },.F.,.F.,.F.)
TRFunction():New(oSection3:Cell("QUANTPIERE")	,,"ONPRINT",oBreakT,,PesqPict("SCP","CP_QUANT"),{|| nTQtdPie },.F.,.F.,.F.)
TRFunction():New(oSection3:Cell("CONSPIERE")	,,"ONPRINT",oBreakT,,PesqPict("SCP","CP_QUANT"),{|| nTConPie },.F.,.F.,.F.)


oSection1:AutoSize()
oSection2:AutoSize()
oSection3:AutoSize()

//o Objeto oReport faz a chamada da Janela de Dialogo da Impressão
oReport:PrintDialog()

If (Select(cAliasQry)!= 0)
	dbSelectArea(cAliasQry)
	dbCloseArea()
EndIf

RestArea(aArea)
		
Return



//-------------------------------------------------------------------------------------------------------------------------------------------------
/*
@author Breno Ferreira Menezes
@since 29/02/2016
@version P11
@Param Não Possui
@Return Active da Tela
@obs
Função para criar as perguntas de filtragem do relatório Requisição Solicitado x Atendido.

Programador     Data       Motivo

/*/
//-------------------------------------------------------------------------------------------------------------------------------------------------
Static Function FCriaPerg()

//criacao de algumas variaveis para a inclusao das perguntas no sistema

Local aArea := GetArea()
Local cHelp := {"Tipo Ativo separado por virgula!"}
Local aHelpPor :={} 
Local aHelpEng :={} 
Local aHelpSpa :={} 
	
aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}

/*-----------------------MV_PAR01--------------------------*/
Aadd( aHelpPor, "Filtra o Centro de Custo Inicial" )
Aadd( aHelpEng, "Filters the Initial Cost Center" )
Aadd( aHelpSpa, "Filtra el centro de coste inicial" )

PutSx1( cPerg, "01","C.Custo de?"  	,"C.Custo de?"  ,"C.Custo de? "	,"mv_ch1","C",TamSX3("CP_CC")[1],0,0,"G","","CTT"	,"004","N","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}

/*-----------------------MV_PAR02--------------------------*/
Aadd( aHelpPor, "Filtra o Centro de Custo Final" )
Aadd( aHelpEng, "Filters the Cost Center Final" )
Aadd( aHelpSpa, "Filtra el Centro de Costo final" )

PutSx1( cPerg, "02","C.Custo ate?" 	,"C.Custo ate?" ,"C.Custo ate?"	,"mv_ch2","C",TamSX3("CP_CC")[1],0,0,"G","","CTT"	,"004","N","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}

/*-----------------------MV_PAR03--------------------------*/
Aadd( aHelpPor, "Filtra o Código do Grupo Inicial" )
Aadd( aHelpEng, "Filters the Home Group Code" )
Aadd( aHelpSpa, "Filtra el Código de Grupo Hogar" )

PutSx1( cPerg, "03","Grupo de?" 	,"Grupo de?" 	,"Grupo de?"	,"mv_ch3","C",TamSX3("B1_GRUPO")[1],0,0,"G","","SBM"	,"","N","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}

/*-----------------------MV_PAR04--------------------------*/
Aadd( aHelpPor, "Filtra o Código do Grupo Final" )
Aadd( aHelpEng, "Filters the Group Code Final" )
Aadd( aHelpSpa, "Filtra el código final del Grupo" )

PutSx1( cPerg, "04","Grupo ate?" 	,"Grupo ate?" 	,"Grupo ate?"	,"mv_ch4","C",TamSX3("B1_GRUPO")[1],0,0,"G","","SBM"	,"","N","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}

/*-----------------------MV_PAR05--------------------------*/
Aadd( aHelpPor, "Filtra a Data da Movimentação Inicial" )
Aadd( aHelpEng, "Filtering the Date Drive Home" )
Aadd( aHelpSpa, "Filtrado de la Fecha de Inicio de unidad" )


PutSx1( cPerg, "05","Dt.Mov. de? " 	,"Dt.Mov. de? " ,"Dt.Mov. de? "	,"mv_ch5","D",08,0,0,"G","","" 		,"","" ,"mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

aHelpPor := {}
aHelpEng := {}
aHelpSpa := {}

/*-----------------------MV_PAR06--------------------------*/
Aadd( aHelpPor, "Filtra a Data da Movimentação Final" )
Aadd( aHelpEng, "Filtering the Date of Final Drive" )
Aadd( aHelpSpa, "Filtrado de la Fecha de Transmisión final" )

PutSx1( cPerg, "06","Dt.Mov. Ate? "	,"Dt.Mov. Ate? ","Dt.Mov. Ate?"	,"mv_ch6","D",08,0,0,"G","",""   	,"","" ,"mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
//PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,cTipo,nTamanho,nDecimal,nPresel,cGSC,cValid,cF3,cGrpSxg,cPyme,;
//                            cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,cDef02,cDefSpa2,cDefEng2,cDef03,cDefSpa3,cDefEng3,cDef04,cDefSpa4,cDefEng4,;
//                           cDef05,cDefSpa5,cDefEng5,aHelpPor,aHelpEng,aHelpSpa,cHelp)

RestArea(aArea)

Return



//-------------------------------------------------------------------------------------------------------------------------------------------------
/*
@author Breno Ferreira Menezes
@since 29/02/2016
@version P11
@Param Não Possui
@Return Não Possui
@obs
Função para efetuar a impressão do relatório conforme selecionado pelo usuário.

Programador     Data       Motivo

/*/
//-------------------------------------------------------------------------------------------------------------------------------------------------
Static Function FPrintReport()

Local oSection1 := oReport:Section(1)
Local aArea   	:= GetArea()
Local cQuery	:= 	""
Local aImp      := .f.
Local nI		:= 0
Local cCC		:= ""
Local cFam		:= ""

Processa({||FSeleDados()})

//seleciono o arquivo de trabalho gerado pela query e coloco no inicio
dbSelectArea(cAliasQry)
dbGoTop()

//Seta o contador da regua
oReport:SetMeter((cAliasQry)->(RecCount()))

//Inicializa a Seção
oSection1:Init()

oSection3:Init()

For nI := 1 to Len(aDad)
	If aDad[nI,01] <> cCC
		
		If nI <> 1
			/*Salta uma linha baseado na altura da linha informada pelo usuário*/
			oReport:SkipLine()
			
			oSection2:Finish()
			
			oSection3:Finish()
			nFQtdSol := 0
			nFQtdAte := 0
			nFQtdPie := 0
			nFConPie := 0			
		EndIf
		
		oSection1:Finish()
		nCQtdSol := 0
		nCQtdAte := 0
		nCQtdPie := 0
		nCConPie := 0
		oSection1:Init()
		oSection1:Cell("QUEBRA"):Disable()
		oSection1:Cell("CODIGO"):SetBlock		( { ||aDad[nI,01]} )
		oSection1:Cell("CENTROCUSTO"):SetBlock	( { ||aDad[nI,02]} )
		oSection1:PrintLine()
		
		oSection2:Init()
		oSection2:Cell("FAMILIA"):SetBlock		( { ||aDad[nI,03]} )
		oSection2:PrintLine()
		
		If nI <> 1
			oSection3:Init()
		EndIf
		oSection3:Cell("PRODUTO"):SetBlock		( { ||aDad[nI,04]} )
		oSection3:Cell("DESCRICAO"):SetBlock	( { ||aDad[nI,05]} )
		oSection3:Cell("UNIDADE"):SetBlock		( { ||aDad[nI,06]} )
		oSection3:Cell("QUANTSOL"):SetBlock		( { ||aDad[nI,07]} )
		oSection3:Cell("QUANTATE"):SetBlock		( { ||aDad[nI,08]} )
		oSection3:Cell("QUANTPIERE"):SetBlock	( { ||aDad[nI,09]} )
		oSection3:Cell("CONSPIERE"):SetBlock	( { ||aDad[nI,10]} )
		oSection3:PrintLine()
		
		cCC := aDad[nI,01]
		cFam:= aDad[nI,01]+aDad[nI,03]
		
	Else
		If aDad[nI,01]+aDad[nI,03] <> cFam
			
			oSection2:Finish()
			oSection3:Finish()
			
			nFQtdSol := 0
			nFQtdAte := 0
			nFQtdPie := 0
			nFConPie := 0
			
			oSection2:Init()
			oSection2:Cell("FAMILIA"):SetBlock		( { ||aDad[nI,03]} )
			oSection2:Cell("FAMILIA"):SetBorder(0, 0,, .F.)
			oSection2:PrintLine()
			
			oSection3:Init()
			oSection3:Cell("PRODUTO"):SetBlock		( { ||aDad[nI,04]} )
			oSection3:Cell("DESCRICAO"):SetBlock	( { ||aDad[nI,05]} )
			oSection3:Cell("UNIDADE"):SetBlock		( { ||aDad[nI,06]} )
			oSection3:Cell("QUANTSOL"):SetBlock		( { ||aDad[nI,07]} )
			oSection3:Cell("QUANTATE"):SetBlock		( { ||aDad[nI,08]} )
			oSection3:Cell("QUANTPIERE"):SetBlock	( { ||aDad[nI,09]} )
			oSection3:Cell("CONSPIERE"):SetBlock	( { ||aDad[nI,10]} )
			oSection3:PrintLine()
		Else
			oSection3:Cell("PRODUTO"):SetBlock		( { ||aDad[nI,04]} )
			oSection3:Cell("DESCRICAO"):SetBlock	( { ||aDad[nI,05]} )
			oSection3:Cell("UNIDADE"):SetBlock		( { ||aDad[nI,06]} )
			oSection3:Cell("QUANTSOL"):SetBlock		( { ||aDad[nI,07]} )
			oSection3:Cell("QUANTATE"):SetBlock		( { ||aDad[nI,08]} )
			oSection3:Cell("QUANTPIERE"):SetBlock	( { ||aDad[nI,09]} )
			oSection3:Cell("CONSPIERE"):SetBlock	( { ||aDad[nI,10]} )
			oSection3:PrintLine()
		EndIf
		cFam:= aDad[nI,01]+aDad[nI,03]
	EndIf
	
	nFQtdSol += aDad[nI,07]
	nFQtdAte += aDad[nI,08]
	nFQtdPie += aDad[nI,09]
	nFConPie += aDad[nI,10]
	
	nCQtdSol += aDad[nI,07]
	nCQtdAte += aDad[nI,08]
	nCQtdPie += aDad[nI,09]
	nCConPie += aDad[nI,10]
	
	nTQtdSol += aDad[nI,07]
	nTQtdAte += aDad[nI,08]
	nTQtdPie += aDad[nI,09]
	nTConPie += aDad[nI,10]	
Next

/*Finaliza seção inicializada pelo método Init.*/
oSection3:Finish()

oSection2:Finish()

oSection1:Finish()

oSectionT:Init()
oSectionT:Finish()

/*Salta uma linha baseado na altura da linha informada pelo usuário*/
oReport:SkipLine()

/*Incrementa a régua da tela de processamento do relatório*/
oReport:IncMeter()

RestArea(aArea)
	
Return



//-------------------------------------------------------------------------------------------------------------------------------------------------
/*
@author Breno Ferreira Menezes
@since 01/03/2016
@version P11
@Param Não Possui
@Return Não Possui
@obs
Função para selecionar os registros retornados pela query

Programador     Data       Motivo

/*/
//-------------------------------------------------------------------------------------------------------------------------------------------------
Static Function FSeleDados()

Local	cQuery	:= " "
Local	oSection1
Local nPos		:= 0
Local cProduto:= ""
Local cDescPrd:= ""
Local cGrupo	:= ""
Local cUM		:= ""

If Select(cAliasQry) <> 0
	dbSelectArea(cAliasQry)
	dbCloseArea()
EndIf

cQuery	:=	"SELECT "
cQuery	+=		"SCP.CP_PRODUTO, "
cQuery	+=		"SB1X.B1_DESC B1X_DESC, "
cQuery	+=		"SB1X.B1_GRUPO B1X_GRUPO, "
cQuery	+=		"SCP.CP_CC, "
cQuery	+=		"CTT.CTT_DESC01, "
cQuery	+=		"SCP.CP_UM, "
cQuery	+=		"SCP.CP_QUANT  AS 'QUANTSOLIC', "
cQuery	+=		"SCP.CP_QUJE   AS 'QUANTATEN', "

cQuery	+=		"SZ9.Z9_PRODUTO, "
cQuery	+=		"SB1.B1_DESC, "
cQuery	+=		"SB1.B1_GRUPO, "
cQuery	+=		"SB1.B1_UM, "
cQuery	+=		"SZ9.Z9_QUANT  AS 'ESTPIER', "
cQuery	+=		"SZ9.Z9_QTDCON AS 'CONSPIER' "

cQuery	+=	"FROM " + RetSqlName("SZ9") + " SZ9 "
cQuery	+=	"FULL OUTER JOIN " + RetSqlName("SCP") + " SCP "
cQuery	+=		"ON  SZ9.Z9_PRODUTO = SCP.CP_PRODUTO "
cQuery	+=		"AND SCP.D_E_L_E_T_ <>'*' "
cQuery	+=		"AND SCP.CP_FILIAL = '"+xFilial("SCP")+"' "
cQuery	+=		"AND SZ9.D_E_L_E_T_ <> '*' "
cQuery	+=		"AND SZ9.Z9_FILIAL = '"+xFilial("SZ9")+"'	"
cQuery	+=		"AND SCP.CP_CC BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
cQuery	+=		"AND SCP.CP_EMISSAO BETWEEN '"+DToS(MV_PAR05)+"' AND '"+DToS(MV_PAR06)+"' "
cQuery	+=		"AND SCP.CP_XIDPLE <> ' ' "
If !Empty(cFilSCP)
	cQuery	+=	"AND " + cFilSCP + " "
EndIf
cQuery	+=	"LEFT OUTER JOIN " + RetSqlName("CTT") + " CTT "
cQuery	+=		"ON  SCP.CP_CC = CTT.CTT_CUSTO "
cQuery	+=		"AND CTT.D_E_L_E_T_ <> '*' "
cQuery	+=		"AND CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "
cQuery	+=	"LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1 "
cQuery	+=		"ON  SZ9.Z9_PRODUTO = SB1.B1_COD "
cQuery	+=		"AND SB1.D_E_L_E_T_ <> '*' "
cQuery	+=		"AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery	+=		"AND SB1.B1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
cQuery	+=	"LEFT OUTER JOIN " + RetSqlName("SB1") + " SB1X "
cQuery	+=		"ON  SCP.CP_PRODUTO = SB1X.B1_COD "
cQuery	+=		"AND SB1X.D_E_L_E_T_ <> '*' "
cQuery	+=		"AND SB1X.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery	+=		"AND SB1X.B1_GRUPO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "

cQuery	+=	"WHERE "
cQuery	+=		"(SCP.CP_FILIAL IS NOT NULL AND SZ9.Z9_FILIAL IS NOT NULL) OR "
cQuery	+=		"(SCP.CP_FILIAL IS NOT NULL AND SZ9.Z9_FILIAL IS NULL AND SCP.CP_XIDPLE <> ' ') OR "
cQuery	+=		"(SCP.CP_FILIAL IS NULL AND SZ9.Z9_FILIAL IS NOT NULL) "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.T.,.T.)


(cAliasQry)->(dbGoTop())

Do While !(cAliasQry)->(EOF())

	If !Empty((cAliasQry)->B1_GRUPO)
		cGrupo:= (cAliasQry)->B1_GRUPO
	ElseIf !Empty((cAliasQry)->B1X_GRUPO)
		cGrupo:= (cAliasQry)->B1X_GRUPO
	EndIf
	
	If !Empty(cGrupo)
		SBM->(dbSetOrder(1))
		SBM->(MsSeek(xFilial("SBM")+cGrupo))
		If SBM->(!Eof())
			cFamilia:= SBM->(BM_GRUPO + ' - ' + BM_DESC)
		EndIf
	EndIf

	If !Empty((cAliasQry)->CP_PRODUTO)
		cProduto:= (cAliasQry)->CP_PRODUTO
		cDescPrd:= (cAliasQry)->B1X_DESC
		cUM		 := (cAliasQry)->CP_UM
	ElseIf !Empty((cAliasQry)->Z9_PRODUTO)
		cProduto:= (cAliasQry)->Z9_PRODUTO
		cDescPrd:= (cAliasQry)->B1_DESC
		cUM		:= (cAliasQry)->B1_UM
	EndIf

	If (nPos:= aScan(aDad, {|x| x[1]+x[4] == (cAliasQry)->CP_CC + cProduto})) <> 0
		aDad[nPos,7]  += (cAliasQry)->QUANTSOLIC
		aDad[nPos,8]  += (cAliasQry)->QUANTATEN
		aDad[nPos,9]  += (cAliasQry)->ESTPIER
		aDad[nPos,10] += (cAliasQry)->CONSPIER
	Else
		aDadAux:= {}
		aAdd(aDadAux,(cAliasQry)->CP_CC )
		aAdd(aDadAux,(cAliasQry)->CTT_DESC01 )
		aAdd(aDadAux,cFamilia )
		aAdd(aDadAux,cProduto )
		aAdd(aDadAux,cDescPrd )
		aAdd(aDadAux,cUm )
		aAdd(aDadAux,(cAliasQry)->QUANTSOLIC )
		aAdd(aDadAux,(cAliasQry)->QUANTATEN )
		aAdd(aDadAux,(cAliasQry)->ESTPIER )
		aAdd(aDadAux,(cAliasQry)->CONSPIER )	
		aAdd(aDad, aDadAux)
	EndIf

	(cAliasQry)->(dbSkip())
EndDo

aSort( aDad,,, { |x,y| x[1]+x[3]+x[4] < y[1]+y[3]+[4] } )

Return
