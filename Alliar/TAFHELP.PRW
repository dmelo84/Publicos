#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"



/*/{Protheus.doc} TAFTRUNC
Realiza Truncate nas tabelas temporárias do TAF
@author Augusto Ribeiro | www.compila.com.br
@since 24/10/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function TAFTRUNC()
Local nOpcAviso	:= 0

nOpcAviso	:= Aviso("ZAP TAFST1 e TAFST2",;
								" Esta rotina realiizará o truncate das tabelas temporárias do TAF de acordo com a opção selecionada."+;
								"Qual tabela deseja realizar o TRUNCATE ?",{"TAFST1", "TAFST2", "Cancelar"},2)

IF nOpcAviso == 1

	cSqlExec	:= "TRUNCATE TABLE TAFST1"
	TcSqlExec( cSqlExec)
	
	Aviso("ZAP TAFST1", "COMANDO EXECUTADO COM SUCESSO!"+CRLF+cSqlExec,{"Fechar"},2)

ELSEIF nOpcAviso == 2
	
	cSqlExec	:= "TRUNCATE TABLE TAFST2"
	TcSqlExec( cSqlExec)
	
	Aviso("ZAP TAFST2", "COMANDO EXECUTADO COM SUCESSO!"+CRLF+cSqlExec,{"Fechar"},2)

ELSE 
	Aviso("Cancelado", "Nenhuma ação foi realizada",{"Fechar"},2)
ENDIF


Return()