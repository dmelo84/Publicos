#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} M130PROC
Filtro Cotacao

@author claudiol
@since 30/12/2015
@version undefined

@type function
/*/
user function M130PROC()
	
Local cFiltro:= PARAMIXB[1]

//Monta filtro de usuario
cFiltro:= U_FSCOMP03("MATA130",cFiltro)

return(cFiltro)
