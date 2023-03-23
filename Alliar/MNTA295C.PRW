#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MNTA295C
Permite listar registros de todas as filiais do sistema em tela na tela : MNTA295C
@type function
@author totvs
@since 05/04/2016
@version 1.0
/*/

User Function MNTA295C()
Local aArea  := GetArea()
Local cRet   := "  "

restArea(aArea)
Return  cRet


