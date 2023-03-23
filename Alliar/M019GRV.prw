#Include 'Protheus.ch'

/*/{Protheus.doc} M019GRV
PE Apos gravação da baixa de pre-requisicao
@type function
@author claudiol
@since 18/03/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function M019GRV()

Local aAreOld	:= {SBZ->(GetArea()), GetArea()}
Local aHead019 := Paramixb[1] //aHeader
Local aCols019 := Paramixb[2] //aCols

U_FSESTP01("X",.T.,aHead019,aCols019)

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return
