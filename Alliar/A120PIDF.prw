#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} A120PIDF
Filtro na selecao da solicitacao de compra

@author claudiol
@since 29/12/2015
@version undefined

@type function
/*/
user function A120PIDF()

Local aFiltro:= {}

//Monta filtro de usuario
aFiltro:= U_FSCOMP03("MATA120")

return(aFiltro)
