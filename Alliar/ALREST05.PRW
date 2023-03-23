#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALREST05
Cadastro CD x Filiais

@author Guilherme.Santos
@since 28/01/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALREST05()
	Local oBrowse	:= FWMBrowse():New()

	oBrowse:SetAlias("SZA")
	oBrowse:SetMenuDef("ALREST05")
	oBrowse:SetDescription("CD x Filiais")

	oBrowse:Activate()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Definicao das Opcoes de Menu

@author Guilherme.Santos
@since 28/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE "Pesquisar"	ACTION "PesqBrw"				OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"	ACTION "VIEWDEF.ALREST05"	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.ALREST05"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.ALREST05"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.ALREST05"	OPERATION 5 ACCESS 0

Return aRotina
//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo de Dados

@author Guilherme.Santos
@since 28/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local bLoadHead 	:= {|| {fLoadCpo("M0EMPFIL"), fLoadCpo("M0NOMFIL")}}
	Local oModel 		:= MPFormModel():New("X_ALREST05")
	Local oStrHea 	:= StrModHea()
	Local oStrDet		:= StrModDet()


	oModel:AddFields("SZAHEADER", NIL, oStrHea, NIL, NIL, bLoadHead)
	oModel:AddGrid("SZADETAIL", "SZAHEADER", oStrDet)

	oModel:SetRelation("SZADETAIL", {{"ZA_FILIAL", "xFilial('SZA')"}, {"ZA_FILCD" , "M0EMPFIL"}, {"ZA_NOMCD" , "M0NOMFIL"}} , SZA->(IndexKey()))

	oModel:SetPrimaryKey({"ZA_FILIAL", "ZA_FILCD", "ZA_FILDES"})

	oModel:GetModel("SZAHEADER"):SetDescription("CD")
	oModel:GetModel("SZADETAIL"):SetDescription("Filiais Destino")

	oModel:GetModel("SZAHEADER"):SetOnlyQuery(.T.)

	oModel:SetDescription("CD x Filiais")
	
Return oModel
//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da View

@author Guilherme.Santos
@since 28/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel		:= FWLoadModel("ALREST05")
	Local oView		:= FWFormView():New()

	Local oStrHea		:= StrVieHea()
	Local oStrDet		:= StrVieDet()

	oView:SetModel(oModel)
	oView:AddField("VIEW_HEADER", oStrHea, "SZAHEADER")
	oView:AddGrid("VIEW_DETAIL", oStrDet, "SZADETAIL")

	oView:CreateHorizontalBox("SUPERIOR", 15)
	oView:CreateHorizontalBox("INFERIOR", 85)

	oView:SetOwnerView("VIEW_HEADER", "SUPERIOR")
	oView:SetOwnerView("VIEW_DETAIL", "INFERIOR")

	oStrDet:RemoveField("ZA_FILCD")
	oStrDet:RemoveField("ZA_NOMCD")

Return oView
//-------------------------------------------------------------------
/*{Protheus.doc} StrModHea
Retorna a Estrutura do Header

@author Guilherme.Santos
@since 28/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function StrModHea()
	Local aGatilho	:= {}
	Local bVldCpo		:= {|oModel, cCampo, cValue, cOldVal| fVldCpo(oModel, cCampo, cValue, cOldVal)}
	Local oStruct		:= FWFormModelStruct():New()

	oStruct:AddTable("   ", {" "}, " ")

	AddCpoMod(oStruct, "Filial Origem",	"M0EMPFIL", "C", FWSizeFilial(),		0, bVldCpo, 	NIL, NIL, .T., {|| fLoadCpo("M0EMPFIL")},	.F., .F., .F.)
	AddCpoMod(oStruct, "Nome Origem", 		"M0NOMFIL", "C", Len(SM0->M0_FILIAL),	0, NIL, 		NIL, NIL, .T., {|| fLoadCpo("M0NOMFIL")},	.F., .F., .F.)

	aGatilho := FwStruTrigger("M0EMPFIL", "M0NOMFIL", "U_REST05GAT('1')", NIL, NIL, NIL, NIL, "!Empty(FwFldGet('M0EMPFIL'))")
	oStruct:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

Return oStruct
//-------------------------------------------------------------------
/*{Protheus.doc} StrModDet
Retorna a Estrutura do Detail

@author Guilherme Santos
@since 28/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function StrModDet()
	Local aGatilho	:= {}
	Local bVldCpo		:= {|oModel, cCampo, cValue, cOldVal| fVldCpo(oModel, cCampo, cValue, cOldVal)}
	Local oStruct		:= FWFormStruct(1, "SZA")

	oStruct:SetProperty("ZA_FILDES", MODEL_FIELD_VALID, bVldCpo)

	aGatilho := FwStruTrigger("ZA_FILDES", "ZA_NOMDES", "U_REST05GAT('2')", NIL, NIL, NIL, NIL, "!Empty(FwFldGet('ZA_FILDES'))")
	oStruct:AddTrigger(aGatilho[1], aGatilho[2], aGatilho[3], aGatilho[4])

Return oStruct
//-------------------------------------------------------------------
/*{Protheus.doc} StrVieHea
Retorna a Estrutura do Header da View

@author Guilherme Santos
@since 28/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function StrVieHea()
	Local lVirtual	:= .F.
	Local oStruct 	:= FWFormViewStruct():New()

	AddCpoView(oStruct,	"M0EMPFIL",	"01",	"Filial Origem", 	"C",	"SM0",	.T.,	.F.)
	AddCpoView(oStruct,	"M0NOMFIL",	"02",	"Nome Origem", 	"C",	"", 	.F.,	.F.)

Return oStruct
//-------------------------------------------------------------------
/*{Protheus.doc} StrVieDet
Retorna a Estrutura do Detail da View

@author Guilherme Santos
@since 28/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function StrVieDet()
	Local oStruct 	:= FWFormStruct(2, "SZA")

Return oStruct
//-------------------------------------------------------------------
/*{Protheus.doc} AddCpoMod
Adiciona um Campo a Estrutura do Model

@author Guilherme Santos
@since 29/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function AddCpoMod(oStruct, cDescri, cCampo, cTipo, nTamanho, nDecimal, bVldCpo, bWhen, aCombo, lObrig, bLoad, lChave, lUpdate, lVirtual)

	oStruct:AddField(		cDescri		,;	//[01]  C   Titulo do campo
							cDescri		,;	//[02]  C   ToolTip do campo
							cCampo			,;	//[03]  C   Id do Field
							cTipo			,;	//[04]  C   Tipo do campo
							nTamanho		,;	//[05]  N   Tamanho do campo - Usar: TamSX3("XXX_CAMPO")[1] quando necessario
							nDecimal		,;	//[06]  N   Decimal do campo - Usar: TamSX3("XXX_CAMPO")[2] quando necessario
							bVldCpo		,;	//[07]  B   Code-block de validação do campo
							bWhen			,;	//[08]  B   Code-block de validação When do campo
							aCombo			,;	//[09]  A   Lista de valores permitido do campo - Combo. Ex.: "S=Sim;N=Nao"
							lObrig			,;	//[10]  L   Indica se o campo tem preenchimento obrigatório
							bLoad			,;	//[11]  B   Code-block de inicializacao do campo
							lChave			,;	//[12]  L   Indica se trata-se de um campo chave
							lUpdate		,;	//[13]  L   Indica se o campo pode receber valor em uma operação de update.
							lVirtual		)	//[14]  L   Indica se o campo é virtual

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} AddCpoView
Adiciona um Campo a Estrutura da View

@author Guilherme Santos
@since 28/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function AddCpoView(oStruct, cCampo, cOrdem, cDescri, cTipo, cConsF3, lAltera, lVirtual)

	oStruct:AddField(	cCampo							,;	// [01]  C   Nome do Campo
						cOrdem							,;	// [02]  C   Ordem
						cDescri						,;	// [03]  C   Titulo do campo
						cDescri						,;	// [04]  C   Descricao do campo
						NIL								,;	// [05]  A   Array com Help
						cTipo							,;	// [06]  C   Tipo do campo
						NIL								,;	// [07]  C   Picture
						NIL								,;	// [08]  B   Bloco de Picture Var
						cConsF3						,;	// [09]  C   Consulta F3
						lAltera						,;	// [10]  L   Indica se o campo é alteravel
						NIL								,;	// [11]  C   Pasta do campo
						NIL								,;	// [12]  C   Agrupamento do campo
						NIL								,;	// [13]  A   Lista de valores permitido do campo (Combo)
						NIL								,;	// [14]  N   Tamanho maximo da maior opção do combo
						NIL								,;	// [15]  C   Inicializador de Browse
						lVirtual						,;	// [16]  L   Indica se o campo é virtual
						NIL								,;	// [17]  C   Picture Variavel
						NIL								)	// [18]  L   Indica pulo de linha após o campo

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} fLoadCpo
Retorna o Conteudo do Campo do Cabecalho na Alteracao

@author Guilherme Santos
@since 18/02/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fLoadCpo(cCampo)
	Local xRetorno := NIL

	Do Case
	Case cCampo == "M0EMPFIL"
		xRetorno	:= SZA->ZA_FILCD	
	Case cCampo == "M0NOMFIL"
		xRetorno	:= SZA->ZA_NOMCD
	EndCase
Return xRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} fVldCpo
Validacao dos Campos do Cliente de Destino e da Filial Selecionada

@author Guilherme.Santos
@since 28/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fVldCpo(oModel, cCampo, xValue, xOldVal)
	Local aArea		:= GetArea()
	Local aAreaSM0	:= SM0->(GetArea())
	Local aAreaSZA	:= SZA->(GetArea())
	Local aSaveLines 	:= FWSaveRows()
	Local cMsgErro	:= ""
	Local nPosAtu		:= 0
	Local cFilAtu		:= ""
	Local nI			:= 0

	Local lRetorno 	:= .T.

	Do Case
	Case cCampo == "M0EMPFIL"
		DbSelectArea("SM0")
		DbSetOrder(1)		//M0_CODIGO, M0_CODFIL
		
		If SM0->(DbSeek(cEmpAnt + xValue))
			DbSelectArea("SZA")
			DbSetOrder(1)		//ZA_FILIAL, ZA_FILCD, ZA_FILDES
			
			If SZA->(DbSeek(xFilial("SZA") + xValue))
				lRetorno 	:= .F.
				cMsgErro	:= "Filial de Origem já cadastrada."
			EndIf
		Else
			lRetorno 	:= .F.
			cMsgErro	:= "Filial não cadastrada no Arquivo de Empresas."
		EndIf
	Case cCampo == "ZA_FILDES"
		DbSelectArea("SM0")
		DbSetOrder(1)		//M0_CODIGO, M0_CODFIL
		
		If SM0->(DbSeek(cEmpAnt + xValue))
			DbSelectArea("SZA")
			DbSetOrder(2)		//ZA_FILIAL, ZA_FILDES, ZA_FILCD
			
			If SZA->(DbSeek(xFilial("SZA") + xValue))
				lRetorno 	:= .F.
				cMsgErro	:= "Filial de Destino já cadastrada para o CD: " + SZA->ZA_FILCD
			Else
				cFilAtu	:= oModel:GetValue("ZA_FILDES")
				nPosAtu	:= oModel:GetLine()

				For nI := 1 to oModel:Length()
					If nI <> nPosAtu
						oModel:GoLine(nI)
						
						If oModel:GetValue("ZA_FILDES") == cFilAtu
							lRetorno := .F.
							cMsgErro := "Filial já cadastrada."
							Exit
						EndIf
					EndIf
				Next nI

				oModel:GoLine(nPosAtu)
			EndIf
		Else
			lRetorno 	:= .F.
			cMsgErro	:= "Filial não cadastrada no Arquivo de Empresas."
		EndIf
	EndCase

	If !lRetorno
		Help(" ", 1, "Help", "fVldCpo", cMsgErro, 3, 0)
	EndIf

	FWRestRows(aSaveLines)
	RestArea(aAreaSZA)
	RestArea(aAreaSM0)
	RestArea(aArea)
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} REST05GAT
Retorna o Nome da Filial

@author Guilherme Santos
@since 18/02/2016
@version P12
*/
//-------------------------------------------------------------------
User Function REST05GAT(cCpoOri)
	Local aArea		:= GetArea()
	Local aAreaSM0	:= SM0->(GetArea())
	Local cRetorno 	:= ""

	If cCpoOri == "1"
		cRetorno := Posicione("SM0", 1, cEmpAnt + FwFldGet("M0EMPFIL"), "M0_FILIAL")
	Else
		cRetorno := Posicione("SM0", 1, cEmpAnt + FwFldGet("ZA_FILDES"), "M0_FILIAL")
	EndIf

	RestArea(aAreaSM0)
	RestArea(aArea)
Return cRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} R05Fil
Retorna a Filial para Gravacao da Solicitacao ao Armazem

@author Guilherme Santos
@since 29/02/2016
@version P12
*/
//-------------------------------------------------------------------
User Function R05Fil(cFilOri)
	Local cFilGrv := cFilOri

	DbSelectArea("SZA")
	DbSetOrder(2)		//ZA_FILIAL, ZA_FILDES, ZA_FILCD

	If SZA->(DbSeek(xFilial("SZA") + cFilOri))
		cFilGrv := SZA->ZA_FILCD
	EndIf

Return cFilGrv
