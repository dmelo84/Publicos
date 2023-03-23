#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT105FIM
MATA105-Apos gravacao

@author claudiol
@since 26/02/2016
@version undefined

@type function
/*/
user function MT105FIM()

Local cOpcao:= PARAMIXB //[1] Inclusao;[2] Alteracao;[3] Exclusao

U_FSESTP05(cOpcao) 

return
