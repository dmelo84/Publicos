#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MA126FIL
Filtro Aglutinacao de Solicitacao de Compra

@author claudiol
@since 29/12/2015
@version undefined

@type function
/*/
user function MA126FIL()

Local cFiltro:= PARAMIXB[1]

//Monta filtro de usuario
cFiltro:= U_FSCOMP03("MATA126",cFiltro)

return(cFiltro)
