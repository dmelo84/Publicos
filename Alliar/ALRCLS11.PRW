#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALRCLS11
Funcao Generica para Compilacao

@author Guilherme.Santos
@since 25/11/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRCLS11()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} xEmail
Classe para Envio e Controle de Emails

@author Guilherme.Santos
@since 25/11/2016
@version P12
*/
//-------------------------------------------------------------------
Class xEmail
	Method New() Constructor
	Method Gravar()
	Method Enviar()
	Method Apagar()	
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Inicializacao do Objeto

@author Guilherme.Santos
@since 29/11/2016
@version P12
*/
//-------------------------------------------------------------------
Method New() Class xEmail
Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} Gravar
Gravacao do Conteudo do Email na Tabela de Log

@author Guilherme.Santos
@since 29/11/2016
@version P12
*/
//-------------------------------------------------------------------
Method Gravar() Class xEmail
	Local lRetorno := .T.
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} Enviar
Envio do E-Mail gravado na Tabela de Log

@author Guilherme.Santos
@since 29/11/2016
@version P12
*/
//-------------------------------------------------------------------
Method Enviar() Class xEmail
	Local lRetorno := .T.
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} Apagar
Exclusao dos E-Mails ja enviados da Tabela de Log

@author Guilherme.Santos
@since 29/11/2016
@version P12
*/
//-------------------------------------------------------------------
Method Apagar() Class xEmail
	Local lRetorno := .T.
Return lRetorno
