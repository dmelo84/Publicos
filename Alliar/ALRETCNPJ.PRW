#include "protheus.ch"



/*/{Protheus.doc} ALRETCNPJ(cFilRet)
// Descrição - Retorna cnpj da Filial no sigamat.emp
@author Sivaldo.santos@compila.com.br
@since 07/06/2017
@version undefined
//teste : = --------------------
// ALRETCNPJ("01101MG0001")
-----------------------------
@type function
/*/
User Function ALRETCNPJ(cFilRet)
 
Local aEmpresas := FWLoadSM0()
Local cCnpj     := ""
Local nX        := 0
 
 Default cFilRet := ""
 
 
For nX := 1 To len(aEmpresas) 

  If aEmpresas[nX,2] == cFilRet
     cCnpj := aEmpresas[nX,18]
     Exit
  EndIf    
 
Next
 
 
Return( cCnpj )

