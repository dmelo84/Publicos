#Include "Protheus.ch"
//-------------------------------------------------------------------
/*{Protheus.doc} TMKBARLA
Inclus�o de bot�o de intera��o imediata

@author  Itamar Gama .:
@since   29/03/2017
@version P12
*/
//-------------------------------------------------------------------
User Function TMKBARLA(aBotao, aTitulo)

If !IsInCallStack("U_ALTMKA01")
	aAdd(aBotao,{"AVG_IADD"  , {|| U_ALTMKA10()} ,"Intera��o Imediata"})	
Endif
Return( aBotao )