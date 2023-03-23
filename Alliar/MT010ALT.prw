#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT010ALT
MATA010-Apos alteracao produto dentro da transacao

@author claudiol
@since 23/02/2016
@version undefined

@type function
/*/
user function MT010ALT()

Local	aAreOld	:= {SB1->(GetArea()), SBZ->(GetArea()), GetArea()}

U_FSESTP01("U",!l010Auto) //Rotina de envio produto ao Pleres

aEval(aAreOld, {|xAux| RestArea(xAux)})
	
return