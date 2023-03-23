#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALRCLS07
Funcao para Compilacao da Classe

@author Guilherme Santos
@since 19/04/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRCLS07()
	Local cRetorno	:= ""
	Local oGrpFluig	:= FluigGroup():New()

	If oGrpFluig:QueryGroups()
		If oGrpFluig:SelectGroup()
			cRetorno 	:= oGrpFluig:GetGroup()
		EndIf
	Else
		Aviso("ALRCLS07", oGrpFluig:GetError(), {"Fechar"})
	EndIf

Return cRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} FluigGroup
Classe para Selecao dos Grupos do Fluig

@author Guilherme Santos
@since 19/04/2016
@version P12
*/
//-------------------------------------------------------------------
Class FluigGroup
	Data aGroups
	Data cGroupFluig
	Data cMsgErro

	Method New()
	Method QueryGroups()
	Method SelectGroup()
	Method GetGroup()
	Method GetError()
	Method Search()
	Method C()
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Inicializa o Objeto

@author Guilherme Santos
@since 19/04/2016
@version P12
*/
//-------------------------------------------------------------------
Method New() Class FluigGroup
	::aGroups 		:= {}
	::cGroupFluig	:= ""
	::cMsgErro		:= ""
Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} QueryGroups
Conexao ao Web Service do Fluig e Recuperacao dos Grupos para Selecao

@author Guilherme Santos
@since 19/04/2016
@version P12
*/
//-------------------------------------------------------------------
Method QueryGroups() Class FluigGroup
	Local cConteudo	:= ""
	Local cIDGrp		:= ""
	Local cGrpDes		:= ""

	Local nAtPipe		:= 0
	Local nI			:= 0

	Local lRetorno	:= .T.

	Local oDataset	:= WSECMDatasetServiceService():New()
	/*
	-----------------------------------------------------------------------------------------------------
		Parametros do DataSet
	-----------------------------------------------------------------------------------------------------	
	*/
	oDataset:nCompanyId		:= Val(SuperGetMv("MV_ECMEMP", NIL, 1))
	oDataset:cUserName		:= SuperGetMv("MV_ECMUSER", NIL, "integradors3@alliar.com")
	oDataset:cPassword		:= SuperGetMv("MV_ECMPSW", NIL, "Supra03@")
	oDataset:cName			:= "ds_grupos_fluig"
	oDataset:_Url 			:= SuperGetMV("MV_ECMURL") + "ECMDatasetService"

	If oDataset:getDataset()
		For nI := 1 to Len(oDataSet:oWSgetDatasetdataset:oWSValues)
			cConteudo	:= oDataSet:oWSgetDatasetdataset:oWSValues[nI]:oWSValue[1]:Text
			nAtPipe	:= At("|", cConteudo)
			cIDGrp		:= Substr(cConteudo, 1, nAtPipe - 1)
			cGrpDes	:= Substr(cConteudo, nAtPipe + 1, Len(cConteudo))

			Aadd(::aGroups, {cIDGrp, cGrpDes})
		Next nI
	Else
		lRetorno		:= .F.
		::cMsgErro		:= "Erro na Comunicação com o Fluig"
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} SelectGroup
Selecao do Grupo do Fluig

@author Guilherme Santos
@since 19/04/2016
@version P12
*/
//-------------------------------------------------------------------
Method SelectGroup() Class FluigGroup
	Local cPesquisa	:= Space(30)
	Local nSelect		:= 0
	Local lRetorno 	:= .T.
	Local oDialog		:= NIL
	Local oGetPesq	:= NIL
	Local oSayPesq	:= NIL

	If Empty(::aGroups)
		::cMsgErro		:= "Não existem Grupos do Fluig para Seleção."
		lRetorno		:= .F.
	Else

		//Ordena os Grupos por Descrição
		aSort( ::aGroups, NIL, NIL, { |x, y| x[2] < y[2] })

		DEFINE MSDIALOG oDialog TITLE "Grupos do Fluig" FROM ::C(001), ::C(001) TO ::C(385), ::C(537) PIXEL
		
			@ ::C(008), ::C(005) SAY oSayPesq PROMPT "Pesquisa" SIZE ::C(089), ::C(007) OF oDialog PIXEL
			@ ::C(005), ::C(035) MSGET oGetPesq VAR cPesquisa SIZE ::C(180), ::C(010) OF oDialog PIXEL
			@ ::C(005), ::C(230) BUTTON "&Pesquisar" SIZE ::C(027), ::C(012) ACTION (oListBox:nAt := ::Search(cPesquisa, oListBox:nAt)) PIXEL OF oDialog

			@ ::C(023), ::C(007) LISTBOX oListBox FIELDS HEADER "ID", "Descrição" SIZE ::C(256), ::C(149) OF oDialog PIXEL COLSIZES ::C(50), ::C(80)
	
			oListBox:SetArray(::aGroups)
	
			oListBox:bLine := {|| {	::aGroups[oListBox:nAT][01],;
										::aGroups[oListBox:nAT][02]}}
					
			oListBox:bLDblClick := {|| (nSelect := oListBox:nAt, oDialog:End()) }
			
			@ ::C(177), ::C(230) BUTTON "&Ok" SIZE ::C(027), ::C(012) ACTION (nSelect := oListBox:nAt, oDialog:End()) PIXEL OF oDialog

		ACTIVATE MSDIALOG oDialog CENTERED

		If nSelect > 0
			::cGroupFluig	:= ::aGroups[nSelect][01]
		Else
			::cMsgErro		:= "Nenhum Grupo do Fluig Selecionado."
			lRetorno		:= .F.		
		EndIf
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} ::GetGroup
Retorna o Grupo do Fluig Selecionado

@author Guilherme Santos
@since 20/04/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetGroup() Class FluigGroup
Return ::cGroupFluig
//-------------------------------------------------------------------
/*{Protheus.doc} GetError
Retorna a Mensagem de Erro da Consulta de Grupos do Fluig

@author Guilherme Santos
@since 20/04/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetError() Class FluigGroup
Return ::cMsgErro
//-------------------------------------------------------------------
/*{Protheus.doc} Search
Pesquisa o Grupo do Fluig

@author Guilherme Santos
@since 20/04/2016
@version P12
*/
//-------------------------------------------------------------------
Method Search(cPesquisa, nPosAtu) Class FluigGroup
	Local nPosReg := Ascan(::aGroups, {|x| Upper(AllTrim(cPesquisa)) $ AllTrim(Upper(x[02]))})

	If nPosReg == 0
		nPosReg := nPosAtu
	EndIf
Return nPosReg
//-------------------------------------------------------------------
/*{Protheus.doc} C
Funcao responsavel por manter o Layout independente 
da resolucao horizontal do Monitor do Usuario.

@author Norbert/Ernani/Mansano
@since 10/05/2005
@version P12
*/
//-------------------------------------------------------------------
Method C(nTam) Class FluigGroup
	Local nHRes	:=	oMainWnd:nClientWidth		//Resolucao horizontal do monitor
	
	If nHRes == 640									// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798) .OR. (nHRes == 800)		// Resolucao 800x600
		nTam *= 1
	Else												// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf
	/*
	-----------------------------------------------------------------------------------------------------
		Tratamento para tema "Flat"
	-----------------------------------------------------------------------------------------------------	
	*/
	If "MP8" $ oApp:cVersion .OR. "P10" $ oApp:cVersion
		If (Alltrim(GetTheme()) $ "FLAT/TEMAP10") .OR. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)
