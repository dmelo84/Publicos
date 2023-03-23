#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} MT120ISC
Copia dados da SC1 exibida na telinha F4 do ações relacionadas da tela do pedido de compra para o browse do SC7

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Alliar
 
@return Boolean
/*/

User Function MT120ISC ()
Local aArea := GetArea()

If FIndFunction("U_ALCOM5")
	U_ALCOM5()
ENdIf


//ABAX   HFP    
If nTipoPed <> 2  //SOMENTE PEDIDO COMPRA
	//aCols[n][gdFieldPos("C7_JUSTCOM")] := SC1->C1_JUSTSOL
	aCols[n][gdFieldPos("C7_XBUDGET")] := SC1->C1_XBUDGET  //abax
	aCols[n][gdFieldPos("C7_XMOTBUD")] := SC1->C1_XMOTBUD  //abax
	//PREENCHER TB A DESCRICAO, POIS NAO ESTA TRAZENDO QDO VEM DA SOLICITACAO
	aCols[n][gdFieldPos("C7_XDESESP ")] :=  POSICIONE("SB1", 1, XFILIAL("SB1")+ SC1->c1_produto,"B1_ESPECIF")                              

ENDIF


restArea(aArea)
Return ()

