#Include "PROTHEUS.CH"



/*/{Protheus.doc} MT120GRV
Localização.: Function A120Pedido - Rotina de Inclusão, Alteração, Exclusão e Consulta dos Pedidos de Compras e Autorizações de Entrega.Finalidade...: 
O  ponto de entrada MT120GRV utilizado para continuar ou não a Inclusão, alteração ou exclusão do Pedido de Compra ou Autorização de Entrega.

ParamIxb[1]	Número do pedido										
ParamIxb[2]	Controla a inclusão										
ParamIxb[3]	Controla a alteração										
ParamIxb[4]	Controla a exclusão

@author Augusto Ribeiro | www.compila.com.br
@since 12/04/2018
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/


User Function MT120GRV()
Local lRet			:= .T.
Local cNum  		:= PARAMIXB[1]
Local lInclui 		:= PARAMIXB[2]
Local lAltera 		:= PARAMIXB[3]
Local lExclui 		:= PARAMIXB[4]
Local lVldCancPC	:= GETMV("AL_CANCPCF",.F.,.T.) //| Valida Cancelamento do PC no Fluig |



/*------------------------------------------------------ Augusto Ribeiro | 12/04/2018 - 5:30:43 PM
	Caso alteração ou exclusao e campo  IDFLUIG preenchido, primeiramente cancela
	solicitação no Fluig para seguir.
	caso solicitação não seja cancelada, não permite seguir com alteração no Prothues.
------------------------------------------------------------------------------------------*/
IF lAltera .OR. lExclui
	IF FnIdFlg(cNum) // !EMPTY(M->C7_XIDFLG) .AND. 
		lRet	:= .T.
	ELSE
		Help("CANFLUIG",1,"CANFLUIG",,"Não foi possivel cancelar a solicitação ["+SC7->C7_XIDFLG+"] no FLUIG. Alteração deste pedido não pode ser concluida.",4,5)
	ENDIF
ENDIF


Return(lRet)



/*/{Protheus.doc} FnIdFlg
Realiza cancalamento da solicitação Protheus no Fluig e limpa
campos de referencia no Protheus.
@author Augusto Ribeiro | www.compila.com.br
@since 12/04/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FnIdFlg(cC7_NUM)
Local lRet		:= .F.
Local cNumC7 := ""
Local cFilC7 := ""

dbSelectArea( "SC7" )
aAreaSC7	:= SC7->(GETAREA())

dbSetOrder(1)

If dbSeek(xFilial("SC7") + cC7_NUM)
	
	cNumC7 := SC7->C7_NUM
	cFilC7 := SC7->C7_FILIAL
	
	if !Empty(SC7->C7_XIDFLG)
		//Verifica se cancelou o processo aberto anteriormente no Fluig
		if FncCFlg(SC7->C7_XIDFLG)
			

			dbSelectArea( "SCR" )
			SCR->(dbSetOrder(1))
			
			If dbSeek(xFilial("SCR", cFilC7) + "PC" + cNumC7)
				While !SCR->(Eof()) .AND. SCR->CR_FILIAL == xFilial("SCR", cFilC7) .AND. ALLTRIM(SCR->CR_TIPO) == "PC" .AND. ALLTRIM(SCR->CR_NUM) == ALLTRIM(SC7->C7_NUM)  
					SCR->(RecLock("SCR", .F.))
					
					SCR->CR_XIDFLG := ""
					
					SCR->(MSUNLOCK())
					
					SCR->(dbSkip())
				End 
			EndIf

			//Atualiza a SC7 e SCR para o status igual a BRANCO
			dbSelectArea( "SC7" )
			SC7->(dbSetOrder(1))
			
			If SC7->(dbSeek(xFilial("SC7", cFilC7) + cNumC7)) .AND. SCR->(dbSeek(xFilial("SCR", cFilC7) + "PC" + cNumC7))
				While !SC7->(Eof()) .AND. ALLTRIM(SCR->CR_NUM) == ALLTRIM(SC7->C7_NUM)
					SC7->(RecLock("SC7", .F.))
					
					SC7->C7_XIDFLG := ""
					
					SC7->(MSUNLOCK())
					
					SC7->(dbSkip())
				End 
			EndIf
			
			lRet	:= .T.
		endif
	else
		lRet	:= .T.
	endif
else
	lRet	:= .T.
endif		
RestArea(aAreaSC7)		
		
					
Return lRet



/*/{Protheus.doc} FncCFlg
Realiza cancelamento da solicitação do Fluig
@author Augusto Ribeiro | www.compila.com.br
@since 12/04/2018
@version undefined
@param param
@return lRetorno, .t. = cancelamento com sucesso
@example
(examples)
@see (links_or_references)
/*/
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



/*
User Function tstPC(cNumPC)
Local lRotAuto	:= .F.

FncCFlg("340475")

//DBSELECTAREA("SC7")
//SC7->(DBSETORDER(1)) //| C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
//IF SC7->(DBSEEK(xfilial("SC7")+cNumPC)) 
//	alert("achou!")
//	WSDLDbgLevel(2) //| Debug|
//	ECFLG(lRotAuto)		
//ENDIF

Return()

*/