#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} M110MONT
PE Validacoes diversas na montagem da tela de compras

@author claudiol
@since 30/12/2015
@version undefined

@type function
/*/
user function M110MONT()

Local cNumSC1 	:= PARAMIXB[1]
Local nOpc 		:= PARAMIXB[2]
Local lCopia 	:= PARAMIXB[3]
 
If lCopia
	//Limpa campos customizados na copia
	U_FSCOMP03("MATA110C")
EndIf

Return
