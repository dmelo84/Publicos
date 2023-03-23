#INCLUDE 'TOTVS.CH'
#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"

User Function M460MARK()
 	Local lRet				:= .T.
 	Local nOpc				:= 0
	Local cCliente 			:= SF2->F2_CLIENTE
	Local cLoja 			:= SF2->F2_LOJA
	Local cNota  			:= SF2->F2_DOC
	Local cSerie 			:= SF2->F2_SERIE
	Local cTribCli 			//:= Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja, "A1_XTRIBES")
	Local cBloq				:= SC5->C5_XBLQ
	Local lBlqFat			:= GetMV("AL_BLQFAT", .F., .T. )
 
	/*----------------------------------------
		20/06/2019 - Jonatas Oliveira - Compila
		Tratativa para verificar os tributos 
		variaveis na tabela ZZA antes de verificar
		no cadastro de clientes		
	------------------------------------------*/
	DbSelectArea('SA1')
	DbSetOrder(1)
	SA1->( DbSeek(xFilial("SA1") + cCliente + cLoja)  )
	
	DBSELECTAREA("ZZA")
	ZZA->(DBSETORDER(1))//|ZZA_FILIAL+ZZA_CODCLI+ZZA_LOJA|
	
	If ZZA->(DBSEEK(SC5->C5_FILIAL + cCliente + cLoja ))
		IF !EMPTY(ZZA->ZZA_XTRIBE)
			cTribCli := ZZA->ZZA_XTRIBE
		ELSE
			cTribCli := SA1->A1_XTRIBES
		ENDIF 
	Else
		cTribCli := SA1->A1_XTRIBES
	Endif
	
	If (Empty(cTribCli) .and. cBloq != "4")
		nOpc := Aviso("Atenção","Tipo de tratamento de Tributos retidos não definido no cad. cliente. Deseja Prosseguir ?", {"Sim","Nao"},1)
		
		If(nOpc == 2)
			lRet := .F.
		Endif

	Endif
		
	If(!Empty(cTribCli) .and. cBloq != "4")
		nOpc := Aviso("Atencao", "Tributos retidos na fonte nao informado. Deseja Prosseguir ?",{"Sim","Nao"},1)
		
		If(nOpc == 2)
			lRet := .F.
		Endif
		
	Endif
    
    If lRet .And. cBloq == "1"
    	nOpc := Aviso("Atencao", "Pedido pertence a um Cliente Novo. Deseja Prosseguir assim mesmo ?",{"Sim","Nao"},1)
		
		If(nOpc == 2)
			lRet := .F.
		Endif
	EndIf
	
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
	
	If lRet 
		If SC5->(Deleted())
			lRet := .f.
			ConOut("*********************************************************")
			ConOut("* Pedido "+SC5->C5_NUM+" deletedo! Verifique travamento *")
			ConOut("*********************************************************")
		Else		
			ConOut("*********************************************************")
			ConOut("* Pedido "+SC5->C5_NUM+" validado para a geracao de NF! *")
			ConOut("*********************************************************")
		Endif
	Endif	    
Return	lRet