#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static lAtende 	:= .T.
Static oBrowse 	:= NIL
//-------------------------------------------------------------------
/*{Protheus.doc} ALTMKA01
Rotina de Atendimento de Telemarketing

@author Guilherme.Santos
@since 11/11/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALTMKA01()
	Local bTimer	:= {|| U_A01Timer()}
	Local bParam	:= {|| U_A01Param()}
	Local cEmail	:= GetMail()
	Local nSecs		:= SuperGetMV("FS_TIMRTMK", NIL, 1) * 1000
	Local bCorSTA 	:= {|| A01CORSTA()}
	Local bLegSTA 	:= {|| A01LEGSTA()}
	Local bCorSIT 	:= {|| A01CORSIT()}
	Local bLegSIT 	:= {|| A01LEGSIT()}
	Local aColSTA 	:= {"", bCorSTA, "C", "@BMP", 0, 1, 0, .F., {||.T.}, .T., bLegSTA, NIL, NIL, NIL, .F.}
	Local aColSIT 	:= {"", bCorSIT, "C", "@BMP", 0, 1, 0, .F., {||.T.}, .T., bLegSIT, NIL, NIL, NIL, .F.}
	
	If Empty(cEmail)
		Aviso("ALTMKA01", "E-Mail do Usuario não cadastrado.", {"Fechar"})
	Else
		oBrowse := FWMBrowse():New()
	
		oBrowse:SetAlias("SUC")
		oBrowse:SetMenuDef("ALTMKA01")
		oBrowse:SetDescription("Atendimento Telemarketing")
		oBrowse:DisableDetails()
		oBrowse:ForceQuitButton()
		oBrowse:DisableReport()
		oBrowse:SetParam(bParam)
		oBrowse:SetTimer(bTimer, nSecs)
		

		//Legendas Customizadas
		oBrowse:AddColumn(aColSTA)
		oBrowse:AddColumn(aColSIT)

		oBrowse:Activate()
	EndIf

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Definicao das Opcoes de Menu

@author Guilherme.Santos
@since 11/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
Return aRotina
//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef2
Definicao das Opcoes de Menu da Rotina do Call Center

@author Guilherme.Santos
@since 11/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MenuDef2()
	Local aRotina := {}

	aRotina	:= {	{ "Pesquisar",	"AxPesqui"        ,0,1 },;
					{ "Visualizar",	"TK271CallCenter" ,0,2 },;
					{ "Incluir",	"TK271CallCenter" ,0,3 },;
					{ "Alterar",	"TK271CallCenter" ,0,4 }}

Return aRotina
//-------------------------------------------------------------------
/*{Protheus.doc} A01Timer
Rotina de Atendimento das Chamadas

@author Guilherme Santos
@since 11/11/2016
@version P12
*/
//-------------------------------------------------------------------
User Function A01Timer()
	Local cCliente		:= ""
	Local cLojaCli		:= ""
	Local cEntidade		:= "AC4"
	Local cContato		:= ""
	Local nRegistro		:= 0
	Local cQuery		:= ""
	Local cTabQry		:= GetNextAlias()

	Private cCadastro 	:= "Atendimento"
	Private aRotina   	:= MenuDef2()
	Private lTk271Auto  := .F.
	Private aAutoCab	:= {}							// Campos de Cabecalho utilizados na rotina automatica
	Private aAutoItens  := {}							// Campos dos Itens utilizados na rotina automatica
	Private cAliasAuto	:= ""							// Alias para identificar qual sera a rotina de atendimento para entrada automatica
	Private INCLUI		:= .T. 
	Private ALTERA		:= .F.	

	If lAtende
		nRegistro := GetReg()

		If nRegistro > 0
			DbSelectArea("SZE")
			DbSetOrder(1)		//ZE_FILIAL, ZE_STATUS, ZE_OPERADO

			DbGoTo(nRegistro)
			
			U_A271SETR(nRegistro)

			cQuery += "SELECT	SU5.U5_CODCONT" + CRLF
			cQuery += ",		SU5.U5_CONTAT" + CRLF
			cQuery += ",		SU5.U5_CPF" + CRLF
			cQuery += ",		AC4.AC4_PARTNE" + CRLF
			cQuery += "FROM		" + RetSqlName("SU5") + " SU5" + CRLF
			cQuery += "			INNER JOIN" + CRLF
			cQuery += "			" + RetSqlName("AC8") + " AC8" + CRLF
			cQuery += "			ON		AC8.AC8_FILIAL = '" + xFilial("AC8") + "'" + CRLF
			cQuery += "			AND		AC8.AC8_CODCON = SU5.U5_CODCONT" + CRLF
			cQuery += "			AND		AC8.AC8_FILENT = SU5.U5_FILIAL" + CRLF
			cQuery += "			AND		AC8.AC8_ENTIDA = 'AC4'" + CRLF
			cQuery += "			AND		AC8.D_E_L_E_T_ = ''" + CRLF
			cQuery += "			INNER JOIN" + CRLF
			cQuery += "			" + RetSqlName("AC4") + " AC4" + CRLF
			cQuery += "			ON		AC4.AC4_FILIAL = '" + xFilial("AC4") + "'" + CRLF
			cQuery += "			AND		AC4.AC4_PARTNE = AC8.AC8_CODENT" + CRLF
			cQuery += "			AND		AC4.D_E_L_E_T_ = ''" + CRLF
			cQuery += "WHERE	SU5.U5_FILIAL = '" + xFilial("SU5") + "'" + CRLF
			cQuery += "AND		SU5.U5_CPF = '" + SZE->ZE_CPF + "'" + CRLF
			cQuery += "AND		SU5.D_E_L_E_T_ = ''" + CRLF

			cQuery := ChangeQuery(cQuery)
				
			DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
				
			While !(cTabQry)->(Eof())
				cCliente := (cTabQry)->AC4_PARTNE
				cLojaCli := ""
				cContato := (cTabQry)->U5_CODCONT
			
				(cTabQry)->(DbSkip())
			End
			
			If Select(cTabQry) > 0
				(cTabQry)->(DbCloseArea())
			EndIf

			DbSelectArea("SUC")
			DbSetOrder(1)		//UC_FILIAL, UC_CODIGO

			//Abre a Rotina de Atendimento do Call Center
			TK271CallCenter(	"SUC",		0,			3,			NIL,;
								cCliente,	cLojaCli,	cContato,	cEntidade,;
								NIL,		NIL,		NIL, 		NIL)
								
		EndIf
	EndIf

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} GetReg
Retorna o Registro pendente para atendimento

@author Guilherme Santos
@since 16/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function GetReg()
	Local aArea		:= GetArea()
	Local cQuery	:= ""
	Local cTabQry	:= GetNextAlias()
	Local nRetorno 	:= 0
	
	cQuery += "SELECT 	TOP 1 SZE.R_E_C_N_O_ REGSZE, SZE.ZE_TIPO,SZE.ZE_MARCA" + CRLF
	cQuery += "FROM		" + RetSqlName("SZE") + " SZE" + CRLF
	cQuery += "WHERE	SZE.ZE_FILIAL = '" + xFilial("SZE") + "'" + CRLF
	cQuery += "AND		SZE.ZE_OPERADO = '" + GetMail() + "'" + CRLF
	cQuery += "AND		SZE.ZE_STATUS = '1'" + CRLF
	cQuery += "AND		SZE.D_E_L_E_T_ = ''" + CRLF
	cQuery += "ORDER BY SZE.R_E_C_N_O_" + CRLF

	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
	MV_PAR59:=""
	MV_PAR60:=""		
	While !(cTabQry)->(Eof())
		nRetorno := (cTabQry)->REGSZE
		MV_PAR58:=StrZero(Val((cTabQry)->ZE_MARCA),3)
		MV_PAR59:=StrZero(Val((cTabQry)->ZE_TIPO),6)	
		(cTabQry)->(DbSkip())
	End
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf
	
	RestArea(aArea)

Return nRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} A01Param
Habilita ou Desabilita o Atendimento

@author Guilherme Santos
@since 11/11/2016
@version P12
*/
//-------------------------------------------------------------------
User Function A01Param()

	lAtende := !lAtende

	Aviso("A01Atende", "Atendimento automatico " + If(lAtende, "Habilitado", "Desabilitado") + ".", {"Fechar"})

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} GetMail
Retorna o Email do Usuario

@author Guilherme Santos
@since 16/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function GetMail()
	Local cEmail := ""

	//Pesquisa o E-Mail do Usuario
	PswOrder(1)		//ID
	
	If PswSeek(RetCodUsr())
		cEmail := PswRet(1)[1][14]
	EndIf

Return cEmail
//-------------------------------------------------------------------
/*{Protheus.doc} A01Entid
Retorna o Codigo de Paciente do Contato

@author Guilherme.Santos
@since 14/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function A01Entid(cContato, cEntidade, cDescri)
	Local cQuery		:= ""
	Local cTabQry		:= GetNextAlias()

	Default cEntidade	:= ""
	Default cDescri		:= ""
	
	cQuery += "SELECT	SU5.U5_CODCONT" + CRLF
	cQuery += ",		SU5.U5_CONTAT" + CRLF
	cQuery += ",		SU5.U5_CPF" + CRLF
	cQuery += ",		AC4.AC4_PARTNE" + CRLF
	cQuery += ",		AC4.AC4_NOME" + CRLF

	cQuery += "FROM		" + RetSqlName("SU5") + " SU5" + CRLF
	cQuery += "			INNER JOIN" + CRLF

	cQuery += "			" + RetSqlName("AC8") + " AC8" + CRLF
	cQuery += "			ON		AC8.AC8_FILIAL = '" + xFilial("AC8") + "'" + CRLF
	cQuery += "			AND		AC8.AC8_CODCON = SU5.U5_CODCONT" + CRLF
	cQuery += "			AND		AC8.AC8_FILENT = SU5.U5_FILIAL" + CRLF
	cQuery += "			AND		AC8.AC8_ENTIDA = 'AC4'" + CRLF
	cQuery += "			AND		AC8.D_E_L_E_T_ = ''" + CRLF

	cQuery += "			INNER JOIN" + CRLF
	cQuery += "			" + RetSqlName("AC4") + " AC4" + CRLF
	cQuery += "			ON		AC4.AC4_FILIAL = ''" + CRLF
	cQuery += "			AND		AC4.AC4_PARTNE = AC8.AC8_CODENT" + CRLF
	cQuery += "			AND		AC4.D_E_L_E_T_ = ''" + CRLF

	cQuery += "WHERE	SU5.U5_FILIAL = ''" + CRLF
	cQuery += "AND		SU5.U5_CODCONT = '" + cContato + "'" + CRLF
	cQuery += "AND		SU5.D_E_L_E_T_ = ''" + CRLF

	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		
	If !(cTabQry)->(Eof())
		cEntidade 	:= (cTabQry)->AC4_PARTNE
		cDescri		:= (cTabQry)->AC4_NOME
	EndIf
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} A01CORSTA
Rotina que devolve a Cor da Legenda de Acordo com o Status

@author Guilherme.Santos
@since 15/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function A01CORSTA()
	Local cRetorno := ""

	//Legenda Padrao do Atendimento do Call Center
	Do Case
	Case Empty(SUC->UC_CODCANC) .AND. Val(SUC->UC_STATUS) == 2		//Pendente
		cRetorno := "BR_VERMELHO"
	Case Empty(SUC->UC_CODCANC) .AND. Val(SUC->UC_STATUS) == 3		//Encerrado
		cRetorno := "BR_VERDE"
	Case Empty(SUC->UC_CODCANC) .AND. Val(SUC->UC_STATUS) == 1		//Planejada
		cRetorno := "BR_AZUL"
	Case !Empty(SUC->UC_CODCANC)									//Cancelado
		cRetorno := "BR_PRETO"
	Case !Empty(SUC->UC_CHAORIG)									//Compartilhamento
		cRetorno := "BR_CINZA"
	EndCase

Return cRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} A01LEGSTA
Rotina para exibicao das Cores da Legenda do Status

@author Guilherme.Santos
@since 15/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function A01LEGSLA()
	Local oLegenda  :=  FWLegend():New()
	
	//Legenda Padrao do Atendimento do Call Center
	oLegenda:Add("", "BR_VERMELHO"	, "Pendente")
	oLegenda:Add("", "BR_VERDE"		, "Encerrado")
	oLegenda:Add("", "BR_AZUL"		, "Planejada") 
	oLegenda:Add("", "BR_PRETO"		, "Cancelado")
	oLegenda:Add("", "BR_CINZA"		, "Compartilhamento")

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} A01CORSIT
Rotina que devolve a Cor da Legenda de Acordo com a Situacao do Chamado

@author Guilherme.Santos
@since 15/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function A01CORSIT()
	Local cRetorno := "BR_VERDE"

	//"UC_XSITUA"		//Definir Regra e as Cores

Return cRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} A01LEGSIT
Rotina para exibicao das Cores da Legenda da Situacao do Chamado

@author Guilherme.Santos
@since 15/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function A01LEGSIT()
	Local oLegenda  :=  FWLegend():New()
	
	//TODO - TROCAR PELAS REGRAS DA SITUACAO	//UC_XSITUA
	//Legenda Padrao do Atendimento do Call Center
	oLegenda:Add("", "BR_VERMELHO"	, "Pendente")
	oLegenda:Add("", "BR_VERDE"		, "Encerrado")
	oLegenda:Add("", "BR_AZUL"		, "Planejada") 
	oLegenda:Add("", "BR_PRETO"		, "Cancelado")
	oLegenda:Add("", "BR_CINZA"		, "Compartilhamento")

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return NIL
