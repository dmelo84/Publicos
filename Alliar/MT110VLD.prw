#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT110VLD
Valida o registro na Solicitação de Compras

@author claudiol
@since 29/12/2015
@version undefined

@type function
/*/
user function MT110VLD()

Local lRet:= .T.
Local nOpcao:= PARAMIXB[1] //3- Inclusão, 4- Alteração, 8- Copia, 6- Exclusão.

If nOpcao<>3
	lRet:= U_FSCOMP03("MATA110")
EndIf
	
return(lRet)
