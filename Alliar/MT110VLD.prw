#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT110VLD
Valida o registro na Solicita��o de Compras

@author claudiol
@since 29/12/2015
@version undefined

@type function
/*/
user function MT110VLD()

Local lRet:= .T.
Local nOpcao:= PARAMIXB[1] //3- Inclus�o, 4- Altera��o, 8- Copia, 6- Exclus�o.

If nOpcao<>3
	lRet:= U_FSCOMP03("MATA110")
EndIf
	
return(lRet)
