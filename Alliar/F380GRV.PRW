
#Include "Protheus.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} F380GRV
O ponto de entrada F380GRV sera executado apos confirmar a tela de reconciliacao bancaria e apos gravar a marcacao do registro selecionado (E5_RECONC) - loop de gravação. Neste ponto o registro já está destravado.
@author Augusto Ribeiro | www.compila.com.br
@since 16/02/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function F380GRV()


IF EMPTY(SE5->E5_RECONC)
	U_CP09DCON(,SE5->(RECNO()))
ENDIF
	
Return()