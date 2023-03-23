#INCLUDE "PROTHEUS.CH"

Static cNumSol := ""
//-------------------------------------------------------------------
/*{Protheus.doc} MT106QRY
Ponto de Entrada na Geracao da Pre-Requisicao ao Armazem para
Manipulacao da Query dos Registros da SCP que deverão ser Processados

@author Guilherme Santos
@since 19/02/2016
@version P12
*/
//-------------------------------------------------------------------
User Function MT106QRY()
	Local cRetorno 	:= ""
	Local lRotAuto	:= PARAMIXB[1]

	If lRotAuto
		cRetorno += " AND CP_NUM = '" + cNumSol + "' "
	EndIf

Return cRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} M106SETN
Atribuicao do Numero da Solicitacao ao Armazem que gerará a 
Pre-Requisicao

@author Guilherme Santos
@since 19/02/2016
@version P12
*/
//-------------------------------------------------------------------
User Function M106SETN(cNumero)
	cNumSol := cNumero
Return NIL
