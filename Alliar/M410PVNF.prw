
/*
MA410MNU 
tratamento para evitar gerar documento de saida pela tela de pedidos de venda dependendo da
situação do pedido

@since 09/12/2014
@version 1.0
*/

User Function M410PVNF()
Local lRet  := .T.
Local aArea := GetArea()
Local aAreaSC6 := SC6->(GetArea())
Local nTotPv 	:= 0 
Local lBlqFat	:= GetMV("AL_BLQFAT", .F., .T. )
//Local cFilCdb	:= "00201SP0001|00201SP0002|00201SP0003|00201SP0004|00201SP0005|00201SP0006|00201SP0007|00201SP0008|00201SP0009|00201SP0010|00201SP0011|00402SP0001|00201SP0012|00201SP0013|00201SP0014|00201SP0015|00201SP0016|00201SP0017|00201SP0018|00201SP0019|00201SP0020|"

If Findfunction("U_ALRFAT7")
	lRet := U_ALRFAT7()
EndIf

/*----------------------------------------
	05/01/2018 - Jonatas Oliveira - Compila
	Tratativa temporaria para bloqueio de 
	faturamento de pedidos de Motoboy - CDB
------------------------------------------*/
//IF SC5->C5_FILIAL $ cFilCdb .AND. SC5->C5_XMOTOB == "1"
IF SC5->C5_XMOTOB == "1"
//IF SC5->C5_XMOTOB == "1"
	lRet := .F.
			
	Help("Bloqueado",1,"Motoboy",,"Faturamento de Motoboy Bloqueado " ,4,5)	
ENDIF 

/*----------------------------------------
	17/04/2019 - Jonatas Oliveira - Compila
	Tratativa para impedir usuario gerar nota
	de pedido com o Faturamento Automatico 
	Habilitado
------------------------------------------*/
IF lBlqFat
	DBSELECTAREA("SZK")
	SZK->(DBSETORDER(1))
	
	DBSELECTAREA("SA1")
	SA1->(DBSETORDER(1))
	SA1->(DBSEEK( XFILIAL("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
	
	IF SZK->(DBSEEK(SM0->M0_CODIGO + SC5->C5_FILIAL)) .AND. SZK->ZK_FATPJAU == "S" .AND. !EMPTY(SC5->C5_XIDFLG) .AND. SA1->A1_PESSOA == "J" .AND. !EMPTY(SC5->C5_XIDPLE)
		lRet := .F.
			
		Help("Bloqueado",1,"Fat Automatico",,"Faturamento automatico habilitado.[AL_BLQFAT] " ,4,5)
	ENDIF 

ENDIF 


restArea(aAreaSC6)
restArea(aArea)
return lRet