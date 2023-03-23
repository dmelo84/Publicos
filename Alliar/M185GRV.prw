#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} M185GRV
MATA185-Chamado apos gerar a requisicao

@author claudiol
@since 29/02/2016
@version undefined

@type function
/*/
user function M185GRV()

Local	aAreOld	:= {SCP->(GetArea()), SCQ->(GetArea()), GetArea()}
Local cMsgErro	:= ""
Local lRetorno	:= .T.

If ValType(l185Auto) == "L" .AND. !l185Auto
	If FindFunction("U_E06UPDFL")
		If SCP->(FieldPos("CP_XIDFLG")) > 0 .AND. !Empty(SCP->CP_XIDFLG)

			MsAguarde({|| lRetorno := U_E06UPDFL(SCP->CP_NUM, @cMsgErro)}, "Atualizando processo no Fluig...")

			If !lRetorno
				DisarmTransaction()
				Aviso("M185GRV", cMsgErro, {"Fechar"})
			EndIf
		EndIf
	EndIf
EndIf


If lRetorno .AND. FindFunction("U_FSESTP06")
	U_FSESTP06()
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})
	
return
