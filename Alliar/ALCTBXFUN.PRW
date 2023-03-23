#INCLUDE "TOTVS.CH"



/*/{Protheus.doc} alCtbVRe
Busca valor da base reduzida
@author Augusto Ribeiro | www.compila.com.br
@since 13/12/2018
@version undefined
@param cImp, Imposto "PIS","COFINS","CSLL","IR","INSS"
@param cVlr, "B" = BASE, "P" = PERCENTUAL, "V" =VALOR
@param nVlrDefault, Valor a ser retornado caso não exista base reduzida
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function alCtbVRe(cImp, cVlr, nVlrDefault)
Local nRet	:= 0
Local aRetAux	:= {}

aRetAux	:= U_ALRFAT04(.T.)
/*
*** aRetAux ****

		AADD(aRet, nBCPis)			//| 1
		AADD(aRet, nPerPis)	        //| 2
		AADD(aRet, nValPis)		    //| 3

		AADD(aRet, nBCCofins)       //| 4
		AADD(aRet, nPerCofins)      //| 5
		AADD(aRet, nValCofins)	    //| 6

		AADD(aRet, nBCCsll)         //| 7
		AADD(aRet, nPerCsll)        //| 8
		AADD(aRet, nValCsll)        //| 9

		AADD(aRet, nBCIr)	        //| 10
		AADD(aRet, nPerIr)	        //| 11
		AADD(aRet, nValIr)	        //| 12

		AADD(aRet, nBCInss)         //| 13
		AADD(aRet, nPerInss)        //| 14
		AADD(aRet, nValInss)        //| 15		
*/


IF LEN(aRetAux) > 0
	cImp	:= UPPER(ALLTRIM(cImp))
	IF cImp == "PIS"
		IF cVlr == "B"
			nRet	:= aRetAux[1]
		ELSEIF cVlr == "P"
			nRet	:= aRetAux[2]
		ELSEIF cVlr == "V"
			nRet	:= aRetAux[3]
		ENDIF
		
	ELSEIF cImp == "COFINS"
		IF cVlr == "B"
			nRet	:= aRetAux[4]
		ELSEIF cVlr == "P"
			nRet	:= aRetAux[5]
		ELSEIF cVlr == "V"
			nRet	:= aRetAux[6]
		ENDIF
	
	ELSEIF cImp == "CSLL"
		IF cVlr == "B"
			nRet	:= aRetAux[7]
		ELSEIF cVlr == "P"
			nRet	:= aRetAux[8]
		ELSEIF cVlr == "V"
			nRet	:= aRetAux[9]
		ENDIF
	
	ELSEIF cImp == "IR"
		IF cVlr == "B"
			nRet	:= aRetAux[10]
		ELSEIF cVlr == "P"
			nRet	:= aRetAux[11]
		ELSEIF cVlr == "V"
			nRet	:= aRetAux[12]
		ENDIF
	
	ELSEIF cImp == "INSS"
		IF cVlr == "B"
			nRet	:= aRetAux[13]
		ELSEIF cVlr == "P"
			nRet	:= aRetAux[14]
		ELSEIF cVlr == "V"
			nRet	:= aRetAux[15]
		ENDIF
	
	ENDIF
ENDIF

IF nRet <= 0
	nRet	:= nVlrDefault
ENDIF


Return(nRet)