#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "ALWSI003.CH"

User Function ALWSI003()
Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} wsRetFilial
Retorna filial da Tabela no Protheus

@author Totvs
@since 02/03/2016
@version P12
*/
//-------------------------------------------------------------------
WSSERVICE wsRetFilial DESCRIPTION "Retorna filial da Tabela no Protheus" NAMESPACE XNAMESPACE

	//Propriedades
	WsData cEmpSol				as String
	WsData cFilSol				as String
	WsData cTabela				as String
	WsData cToken				   as String
	WsData cRetorno				as String
	WsData xDadoFuncFil			as axDadoFuncFil
	WsData cCodEmpr				as String
	
	//Metodo para Retorno da Filial
	WSMethod RetFilial			Description "Retorna a Filial"
	WSMethod RetFuncFil         Description "Retorna Dados Fucnonarios\Filiais "

ENDWSSERVICE



WsStruct axDadoFuncFil
	WsData intDadoFuncFil	as Array of stDadoFuncFil
EndWsStruct


WsStruct stDadoFuncFil
	WsData cNome		As String
	WsData cEmail		As String
	WsData cCpf		As String
	WsData cCod		As String
	WsData cDescFil		As String
EndWSStruct


//-------------------------------------------------------------------
/*{Protheus.doc} RetFil
Consulta filial no Protheus

@author Oswaldo Leite
@since 02/03/2016
@version P12 
*/
//-------------------------------------------------------------------
WSMethod RetFilial WSReceive cEmpSol, cFilSol, cToken, cTabela WsSend cRetorno WSService wsRetFilial
	Local lRetorno 	:= .T.
	Local lVldToken	:= VldToken(::cToken)
	
	Console("Preparando Ambiente para RetFil - Empresa: " + ::cEmpSol + " - Filial: " + ::cFilSol)
	
	
	If lVldToken
	
		If VldEmpFil(::cEmpSol, ::cFilSol)

			RpcSetEnv(::cEmpSol, ::cFilSol, NIL, NIL, "EST", NIL, {::cTabela})
			
			//Altera as variaveis globais do protheus Empresa e Filial, pois apesar do RpcSetEnv o Protheus nao as setava
			cEmpAnt := ::cEmpSol
			cFilAnt := ::cFilSol

			//Retorno verdadeiro, buscará a filial
			lRetorno 		:= .T.
	
			//Recupera a Mensagem de Validacao
			::cRetorno		:= FWxfilial(cTabela)

		Else
			lRetorno		:= .F.
			::cRetorno		:= "Empresa + Filial Invalida."
		EndIf
	Else
		lRetorno		:= .F.
		::cRetorno		:= "Token Invalido."
	EndIf

	If !lRetorno
		Console(::cRetorno)
		SetSoapFault(XNOMEPROG, ::cRetorno)
	EndIf

	//	RPCClearEnv()  <--- foi preciso arrancar, pois (apesar de termos de usá-lo nas boas praticas) esta funcao abortava a thread do webservice e ocasionava erros

Return lRetorno



/*/{Protheus.doc} VldEmpFil

@author Jorge Heitor
@since 22/12/2015
@version 12.1.007
@description Função para validar a Empresa e Filial informadas na chamada do Método
@obs ALLIAR

@return Boolean, .T.
/*/
Static Function VldEmpFil(cEmp, cFil)
	
	Local lRet		:= .F.
	Local lSM0Open	:= (Select("SM0") > 0)
	Local aAreaSM0	:= Iif(lSM0Open ,SM0->(GetArea()), {})
	Local cAliasSM0	:= Iif(lSM0Open,"SM0","TSM0")
	
	//Se não tiver aberto o SM0, abre temporariamente 
	If !lSM0Open
		
		//dbUseArea( .T., , "SIGAMAT.EMP", cAliasSM0, .T., .F. )
		OpenSM0()
		
		dbSetIndex( "SIGAMAT.IND" )
		
		Sleep(500)
		
	EndIf
	
	dbSelectArea(cAliasSM0)
	dbSetOrder(1)
	
	(cAliasSM0)->(dbGoTop())
	
	If (cAliasSM0)->(DbSeek(cEmp + cFil))
		lRet 		:= .T.
		cFilAnt	:= cFil
	Else
		lRet := .F.
	EndIf
	
	If lSM0Open
		RestArea(aAreaSM0)
	EndIf
	
Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} VldToken
Valida o Token Informado

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Static Function VldToken(cToken )
	Local lRetorno := AllTrim(SuperGetMV("ES_TOKENWS", NIL, "XXX")) == cToken
Return lRetorno

//-------------------------------------------------------------------
/*{Protheus.doc} Console
Grava o Texto no Console do AppServer

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Static Function Console(cTexto)
	ConOut(XNOMEPROG + " - " + DtoC(Date()) + " - " + Time() + " - " + cTexto)
Return NIL


//-------------------------------------------------------------------
/*{Protheus.doc} RetFuncFil
Consulta funcionarios no Protheus. Método será utilizado em relatorio do fluig 

Ele nos fornece 001 e listamos todos os funcionarios cujo RA_FILIAL começa com 001
                  Exemplo:
                                                                                  00101MG001
                                                                                  00101MG002
                                                                                  00107MG001

@author Totvs
@since 02/03/2016
@version P12 
*/


//-------------------------------------------------------------------

WSMethod RetFuncFil WSReceive cEmpSol, cFilSol, cCodEmpr, cToken WsSend xDadoFuncFil WSService wsRetFilial
	Local lRetorno 	:= .T.
	Local cretorno := ''
	Local lVldToken	:= VldToken(::cToken)
	Local cTabQry
	Local cQuery := ""
	Local nSOma := 0
	
	Console("Preparando Ambiente para RetFil - Empresa: " + ::cEmpSol + " - Filial: " + ::cFilSol)
		
	If lVldToken
	
		If VldEmpFil(::cEmpSol, ::cFilSol)

		
			RpcSetEnv(::cEmpSol, ::cFilSol, NIL, NIL, "EST", NIL )
			
			//Altera as variaveis globais do protheus Empresa e Filial, pois apesar do RpcSetEnv o Protheus nao as setava
			cEmpAnt := ::cEmpSol
			cFilAnt := ::cFilSol

			//Retorno verdadeiro, buscará a filial
			lRetorno 		:= .T.
	
			//Recupera a Mensagem de Validacao
			
			cTabQry := GetNextAlias()
			cQuery := "SELECT SRA.RA_NOME, SRA.RA_EMAIL, SRA.RA_FILIAL, SRA.RA_CIC FROM " + RETSQLNAME("SRA") + " SRA "
			cQuery += "WHERE 				SRA.D_E_L_E_T_ = '' " + CRLF
	
			If !Empty(cCodEmpr)
				cQuery += " AND SUBSTRING(SRA.RA_FILIAL,1,3) = '" + ::cCodEmpr + "' " + CRLF
			EndIf
			
			cQuery += "ORDER BY SRA.RA_FILIAL, SRA.RA_NOME" + CRLF
	        
			cQuery := ChangeQuery(cQuery)
					
			DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
	
			While (cTabQry)->(!Eof())
				Aadd(::xDadoFuncFil:intDadoFuncFil, WSClassNew( "stDadoFuncFil" ))
				
				
				::xDadoFuncFil:intDadoFuncFil[Len(::xDadoFuncFil:intDadoFuncFil)]:cNome  := (cTabQry)->RA_NOME
				::xDadoFuncFil:intDadoFuncFil[Len(::xDadoFuncFil:intDadoFuncFil)]:cEmail := (cTabQry)->RA_EMAIL
				::xDadoFuncFil:intDadoFuncFil[Len(::xDadoFuncFil:intDadoFuncFil)]:cCpf   := (cTabQry)->RA_CIC
				::xDadoFuncFil:intDadoFuncFil[Len(::xDadoFuncFil:intDadoFuncFil)]:cCod   := (cTabQry)->RA_FILIAL
				::xDadoFuncFil:intDadoFuncFil[Len(::xDadoFuncFil:intDadoFuncFil)]:cDescFil   := FWFilialName(cEmpAnt, (cTabQry)->RA_FILIAL,1)
				
				(cTabQry)->(DbSkip())
			End 
			
			(cTabQry)->(DbCloseArea())	
		Else
			lRetorno		:= .F.
			cRetorno		:= ("Empresa + Filial Invalida." + ::cEmpSol + "... "+ ::cFilSol)
		EndIf
	Else
		lRetorno		:= .F.
		cRetorno		:= "Token Invalido."
	EndIf

	If !lRetorno
		Console(cRetorno)
		SetSoapFault(XNOMEPROG, cRetorno)
	EndIf

	//	RPCClearEnv()  <--- foi preciso arrancar, pois (apesar de termos de usá-lo nas boas praticas) esta funcao abortava a thread do webservice e ocasionava erros

Return lRetorno

