#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT120EXC
O ponto se encontra no final do evento 3 da MaAvalPc (Exclusão do PC) antes dos eventos de contabilização

@author claudiol
@since 11/01/2016
@version undefined

@type function
/*/
user function MT120EXC()

//Limpa flag no SC de origem
If !Empty(SC7->C7_XNUMPDC)
	U_FSCOMP03("MATA120E")
EndIf

return
