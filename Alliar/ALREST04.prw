#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALREST04
Funcao para Compilacao da Classe

@author TOTVS
@since 26/01/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALREST04()
Return NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} uPodeSolicitar
Classe para consulta de permissao para Solicitante x Produto
@type class
@author JorgeHeitor
@since 24/01/2016
@version 1.0
@obs Classe chamada para consulta dos dados via WebService, retornando se o produto pode ou n�o ser solicitado pelo usuario em quest�o
/*/
//-------------------------------------------------------------------
Class uPodeSolicitar
	Data cMsgRet
	
	Method New()
	Method Consultar()
	Method GetMensagem()
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Inicializacao do Objeto

@author JorgeHeitor
@since 26/01/2016
@version P12
*/
//-------------------------------------------------------------------
Method New() Class uPodeSolicitar
	::cMsgRet		:= ""
Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} Consultar
Valida se o Usuario pode Solicitar o Produto

@author Jorge Heitor
@since 26/01/2016
@version P12
*/
//-------------------------------------------------------------------
Method Consultar(cEmailUsr, cProduto) Class uPodeSolicitar
	Local aArea		:= GetArea()
	Local aDetUsr		:= {}
	Local aGrupos		:= {}
	
	Local cCodUsr		:= ""
	Local cRestSol	:= GetMV("MV_RESTSOL")
	
	Local lAprovSC	:= GetMV("MV_APROVSC")
	Local lChkSoli	:= GetMV("MV_CHKSOLI")
	Local lRet			:= .T.
	
	Private l110Auto	:= .F.

	::cMsgRet			:= ""

	//Se houver restri��o de solicita��es, n�o controlar aprova��o de SC e for para checar solicitante
	If cRestSol == "S" .AND. !lAprovSC .AND. lChkSoli
		DbSelectArea("SB1")
		DbSetOrder(1)		//B1_FILIAL, B1_COD
		
		If SB1->(DbSeek(FwxFilial("SB1") + cProduto + Space(TamSX3("B1_COD")[1] - Len(cProduto))))
			//Se o Produto tem Solicita��o controlada
			If SB1->B1_SOLICIT == "S"
				//Busca Usu�rio pelo e-mail
				PswOrder(4)
		
				If PswSeek(cEmailUsr, .T.)
					aDetUsr := PswRet()
					aGrupos := aClone(aDetUsr[1][10])
					cCodUsr := AllTrim(aDetUsr[1][1])
					
					If A110Restr(cProduto, aGrupos, cCodUsr, .F.)
						::cMsgRet	:= "ALREST04 - Solicita��o permitida para o Produto " + AllTrim(cProduto)
						lRet 		:= .T.
					Else
						::cMsgRet	:= "ALREST04 - Solicita��o n�o permitida para o Produto " + AllTrim(cProduto)
						lRet 		:= .F.
					EndIf
				Else
					::cMsgRet	:= "ALREST04 - Usuario nao encontrado para o e-mail "+ AllTrim(cEmailUsr)
					lRet		:= .F.
				EndIf
			Else
				::cMsgRet 	:= "ALREST04 - Produto sem Solicita��o controlada."
				lRet		:= .T.
			EndIf
		Else
			::cMsgRet	:= "ALREST04 - Produto n�o Cadastrado."
			lRet		:= .F.
		EndIf
	Else
		::cMsgRet	:= "ALREST04 - Aprova��o de Solicita��o de Compras n�o habilitada."
		lRet 		:= .F.
	EndIf
	
	RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} GetMensagem
Retorna a Mensagem

@author Guilherme Santos
@since 26/01/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetMensagem() Class uPodeSolicitar
Return ::cMsgRet
