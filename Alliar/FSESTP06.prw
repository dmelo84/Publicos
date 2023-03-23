#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FSESTP06
Marca flag Pleres para envio de baixa

@author claudiol
@since 29/02/2016
@version undefined

@type function
/*/
user function FSESTP06()

If SCP->(FieldPos("CP_XIDPLE")) > 0 .AND. SD3->(FieldPos("D3_XFLGPLE")) > 0
	If !Empty(SD3->D3_NUMSA) .And. !Empty(SD3->D3_ITEMSA) .And. !Empty(SCP->CP_XIDPLE)
		If Reclock("SD3",.F.)
			SD3->D3_XFLGPLE:= "B" //B=Baixado;E=Enviado
			SD3->(MsUnlock())
		EndIf
	EndIf
EndIf
	
return
