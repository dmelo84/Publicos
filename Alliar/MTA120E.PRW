#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MTA120E
MATA120 - Valida exclusao

@author claudiol
@since 14/01/2016
@version undefined

@type function
/*/
User Function MTA120E()

	Local nOpcao  := PARAMIXB[1]
	Local cPedCom := PARAMIXB[2]
	Local lCopia  := IsInCallStack("A120Copia")
	Local lRet	  := .T.
	Local aAreOld := {SC1->(GetArea()),GetArea()}

	If (lRet:= U_FSVerPdc(nOpcao,cPedCom))
		If nOpcao == 1 .AND. !Inclui .AND. !Altera .AND. !lCopia
			FnIdFlg(cPedCom)
		Endif
	EndIf

	aEval(aAreOld, {|xAux| RestArea(xAux)})
	
Return(lRet)

Static Function FnIdFlg(cC7_NUM)
	Local cIdFlg := ""
	
	dbSelectArea( "SC7" )
	dbSetOrder(1)
	
	If dbSeek(xFilial("SC7") + cC7_NUM)
		cIdFlg := SC7->C7_XIDFLG
	EndIf
	
	if !Empty(cIdFlg)
		//Verifica se cancelou o processo aberto anteriormente no Fluig
		if FncCFlg(cIdFlg)
			
			//Atualiza a SC7 e SCR para o status igual a BRANCO
			dbSelectArea( "SC7" )
			dbSetOrder(1)
			
			If dbSeek(xFilial("SC7", SC7->C7_FILIAL) + SC7->C7_NUM)
				While !SC7->(Eof()) .AND. SCR->CR_NUM == cC7_NUM
					SC7->(RecLock("SC7", .F.))
					
					SC7->C7_XIDFLG := ""
					
					SC7->(MSUNLOCK())
					
					SC7->(dbSkip())
				End 
			EndIf
			
			dbSelectArea( "SCR" )
			dbSetOrder(1)
			
			If dbSeek(xFilial("SCR", SC7->C7_FILIAL) + "PC" + SC7->C7_NUM)
				While !SCR->(Eof()) .AND. SCR->CR_FILIAL == xFilial("SCR", SC7->C7_FILIAL) .AND. SCR->CR_TIPO == "PC" .AND. SCR->CR_NUM == SC7->C7_NUM  
					SCR->(RecLock("SCR", .F.))
					
					SCR->CR_XIDFLG := ""
					
					SCR->(MSUNLOCK())
					
					SCR->(dbSkip())
				End 
			EndIf
		endif
	endif
					
Return cIdFlg

//Cancela Solicitacao Fluig
Static Function FncCFlg(cIdFlg)
	Local FlgWS    := WSECMWorkflowEngineServiceService():new()
	Local lRetorno := .F. 
	
	FlgWs:_URL := SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	if FlgWS:cancelInstance(SuperGetMv("MV_ECMUSER"    ,NIL ,"integrador"),;
	                        SuperGetMv("MV_ECMPSW"     ,NIL ,"integrador"),;
	                        VAL(SuperGetMv("MV_ECMEMP" ,NIL ,1)),;
	                        VAL(cIdFlg),;
	                        SuperGetMv("MV_ECMMAT"),;
	                        "Processo cancelado através da integração com o Protheus") 
		//Se processamento ocorrer sem erros exibe o valor de retorno
		lRetorno := .T. 
	endif
	
Return lRetorno
