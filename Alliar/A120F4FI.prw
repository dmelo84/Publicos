#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} A120F4FI
Filtro na escolha da solicitacao de compra por item

@author claudiol
@since 29/12/2015
@version undefined

@type function
/*/
user function A120F4FI()
	
Local aFiltro:= {}

//Monta filtro de usuario
aFiltro:= U_FSCOMP03("MATA120")
	
return(aFiltro)