#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} Classe03
Funcao Generica para Compilacao

@author Guilherme Santos
@since 19/02/2016
@version P12
*/
//-------------------------------------------------------------------
User Function Classe03()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} uSolArmazem
Classe para Gravacao das Solicitacoes ao Armazem via ExecAuto

@author Guilherme Santos
@since 19/02/2016
@version P12
*/
//-------------------------------------------------------------------
Class uSolArmazem From uExecAuto
	Data cNumero										//Numero da Solicitacao ao Armazem
	Data cIDFluig										//ID do Processo no Fluig

	Method New()
	Method AddCabec(cCampo, xValor, xValid)		//Adiciona dados ao Cabecalho
	Method AddItem(cCampo, xValor, xValid)			//Adiciona dados ao Item
	Method Gravacao(nOpcao)							//Gravacao da Solicitacao ao Armazem via ExecAuto
	Method GetNumero()								//Retorna o Numero da Solicitacao ao Armazem
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Inicializa o Objeto

@author Guilherme Santos
@since 19/02/2016
@version P12
*/
//-------------------------------------------------------------------
Method New() Class uSolArmazem
	_Super:New()

	::aTabelas		:= {"SCP", "SCQ"}
	::cFileLog		:= "MATA105.LOG"
	::cIDFluig		:= ""
	::cNumero		:= ""
Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} AddCabec
Adiciona os Dados do Cabecalho da Solicitacao ao Armazem

@author Guilherme Santos
@since 19/02/2016
@version P12
*/
//-------------------------------------------------------------------
Method AddCabec(cCampo, xValor, xValid) Class uSolArmazem
	Default xValid	:= NIL

	Do Case
	Case cCampo == "CP_NUM"
		::cNumero	:= xValor
	Case cCampo == "CP_XIDFLG"
		::cIDFluig	:= xValor
	EndCase

	_Super:AddCabec(cCampo, xValor, xValid)
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} AddItem
Adiciona os dados dos Itens da Solicitacao ao Armazem

@author Guilherme Santos
@since 19/02/2016
@version P12
*/
//-------------------------------------------------------------------
Method AddItem(cCampo, xValor, xValid) Class uSolArmazem
	Default xValid	:= NIL

	_Super:AddItem(cCampo, xValor, xValid)
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} Gravacao
Gravacao da Solicitacao ao Armazem

@author Guilherme Santos
@since 19/02/2016
@version P12
*/
//-------------------------------------------------------------------
Method Gravacao(nOpcao) Class uSolArmazem
	Local lReserva		:= .F.
	Local lRetorno 		:= .T.
	Private lMsErroAuto	:= .F.

	::SetEnv(1, "EST")

	Do Case
	Case nOpcao == 3
		DbSelectArea("SCP")
		DbOrderNickName("CPXIDFLG")		//CP_FILIAL, CP_XIDFLG, CP_ITEM
		
		If SCP->(DbSeek(xFilial("SCP") + ::cIDFluig))
			::cMensagem	:= "A Solicitação (" + SCP->CP_NUM + ") referente a este ID Fluig já foi incluida."
			lRetorno 		:= .F.
		Else
			If Empty(::cNumero)
				::AddCabec("CP_NUM", GetSX8Num("SCP", "CP_NUM"), NIL)

				DbSelectArea("SCP")
				DbSetOrder(1)		//CP_FILIAL, CP_NUM
	
				While SCP->(DbSeek(xFilial("SCP") + ::cNumero))
					ConfirmSX8()
					
					::AddCabec("CP_NUM", GetSX8Num("SCP", "CP_NUM"), NIL)
				End

				lReserva	:= .T.
			EndIf
		EndIf
	Otherwise
		If Empty(::cNumero)
			::cMensagem	:= "Numero da Solicitação não informado."
			lRetorno		:= .F.
		Else
			DbSelectArea("SCP")
			DbSetOrder(1)		//CP_FILIAL, CP_NUM

			If !SCP->(DbSeek(xFilial("SCP") + ::cNumero))
				::cMensagem	:= "Solicitação não localizada."
				lRetorno 		:= .F.
			EndIf
		EndIf
	EndCase	

	If lRetorno
		//Gravacao do Titulo a Pagar
		MSExecAuto({|a, b, c| MATA105(a, b, c)}, ::aCabec, ::aItens, nOpcao)

		If lMsErroAuto
			lRetorno := .F.

			If lReserva
				RollBackSx8()
			EndIf
	
			If ::lExibeTela
				MostraErro()
			EndIf
			
			If ::lGravaLog
				::cMensagem := MostraErro(::cPathLog, ::cFileLog)
			EndIf
		Else
			If lReserva
				ConfirmSx8()
			EndIf
		EndIf
	EndIf

	::SetEnv(2, "EST")

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} GetNumero
Retorna o Numero da Solicitacao ao Armazem

@author Guilherme Santos
@since 19/02/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetNumero() Class uSolArmazem
Return ::cNumero
