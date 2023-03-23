#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} FA100CA2
Executado após a confirmação da Exclusão da Movimentação Bancária, antes de efetuar a exclusão e a contabilização.
@author Augusto Ribeiro | www.compila.com.br
@since 04/11/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function FA100CA2()
Local aParam	:= PARAMIXB
Local aRetAux	:= {}


IF IIF(VALTYPE(aParam) == "A",LEN(aParam) > 0,.F.)
	IF aParam[1] == 5 .OR. aParam[1] == 6 
		aRetAux	:= U_CP11ESTF("SE5", SE5->(RECNO()), , SE5->E5_VALOR)
		//IF !(aRetAux[1])
			//CONOUT("FA100CA2 [CP11ESTF]",aRetAux[2])
		//ENDIF
	ENDIF
ENDIF


Return(.t.)