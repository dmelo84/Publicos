#include "PROTHEUS.CH"         



/*/{Protheus.doc} F260BUT
LOCALIZAÇÃO : Function MenuDef() - Responsável pelo menu Funcional. 
EM QUE PONTO : Ponto de Entrada 'F260BUT', utilizado para adicionar itens no menu principal do fonte FINA260.PRX

@author Augusto Ribeiro | www.compila.com.br
@since 18/04/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function F260BUT()
Local aRet := PARAMIXB

aAdd(aRet,{'Conc. Manual','U_AFIN001',0,2 })

Return aRet