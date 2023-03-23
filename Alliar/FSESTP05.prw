#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FSESTP05
Rotina atualiza variaval private com numero da requisicao

@author claudiol
@since 26/02/2016
@version undefined

@type function
/*/
user function FSESTP05(cOpcao)

//cOpcao  [1] Inclusao;[2] Alteracao;[3] Exclusao

If Type("cFsNumReq") <> "U"
	cFsNumReq:= cA105Num
EndIf
	
return
