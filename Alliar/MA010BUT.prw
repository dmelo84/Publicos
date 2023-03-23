#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MA010BUT
MATA010-Inclusão de botao

@author claudiol
@since 04/03/2016
@version undefined

@type function
/*/
user function MA010BUT()

If ALTERA
	U_FSSetSB1() //Guarda dados atuais a serem enviados ao Pleres para avaliar se teve alteracao
EndIf
	
return
