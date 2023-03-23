#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FSESTP02
Executa rotina de envio de cadastro de produto ao Pleres

@author claudiol
@since 24/02/2016
@version undefined

@type function
/*/
user function FSESTP02()

Local	aAreOld:= {SB1->(GetArea()), SBZ->(GetArea()), GetArea()}
Local	aEnvFil:= U_FSPrdSBZ(SB1->B1_COD)

If !Empty(aEnvFil)
	If ApMsgNoYes("Confirma envio dados do produto ao Pleres?",".:Confirma��o:.")
		U_FSESTP01("U") //Rotina de envio produto ao Pleres
	EndIf
Else
	ApMsgAlert("N�o existe cadastro de indicadores definido para ser integrado!",".:Aten��o:.")
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})
		
return