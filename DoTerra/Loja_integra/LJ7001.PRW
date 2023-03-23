#include 'protheus.ch'
#include 'parmtype.ch'

/*------------------------------------------------------
|Ponto de Entrada - Gravação de campo na SC5 antes de   |
|efetivar a venda.                                      |
|Desenvolvedor Diogo Melo                               |
|Data: 06/05/2019                                       |
--------------------------------------------------------*/

User Function LJ7001

	Local aCols1  := aClone(aCols)
	Local nY := 0
	Local lRetorno  := .F.
	Local lRet1 	:= .T.
	Local lRet2 	:= .F.
	Local cPula     := CHR(13)+CHR(10)
	Local cMsg      := ''
//Desativa Validação
	lRetorno := .T.
	Return
//-------------------
    If Len(aCols1) > 0 .and. nRotina == 3
		lRetorno := .T.
    Else
		cMsg := "Valide os itens novamente."+cPula
        If Len(aCols1) > 0
			For nY := 1 to Len(aCols1)

				If aCols1[nY][26] == aCols1[nY][4]
				lRet2 := .T.
				Else

					If Empty(aCols1[nY][15]) .or. aCols1[nY][26] != aCols1[nY][4] .and. !(ACOLS1[nY][29]) 
					/*POK*/                       /*Quantidade*/	                     /*Deletado*/    
						cMsg += aCols1[nY][1]+" - "+aCols1[nY][3] + cPula  
						//lRet1 := .F.
					Else
						lRet2 := .T.
					EndIf

				ENDIF
            Next
		 EndIf
		 
        If lRet1 == lRet2
			lRetorno := .T.
		Else
			cMsg += IIF(lRet1, aCols1[1][1]+" - "+aCols1[1][3] + cPula, "") 	
			Help(NIL, NIL, "Bloqueio", NIL, "Os itens não foram validados na rotina de separação.", 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsg})
			lRetorno := .F.
		EndIf
		
    EndIf
Return lRetorno