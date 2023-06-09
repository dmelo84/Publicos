#Include "PROTHEUS.CH"



/*/{Protheus.doc} MT120GRV
Localiza��o.: Function A120Pedido - Rotina de Inclus�o, Altera��o, Exclus�o e Consulta dos Pedidos de Compras e Autoriza��es de Entrega.Finalidade...: 
O  ponto de entrada MT120GRV utilizado para continuar ou n�o a Inclus�o, altera��o ou exclus�o do Pedido de Compra ou Autoriza��o de Entrega.

ParamIxb[1]	N�mero do pedido										
ParamIxb[2]	Controla a inclus�o										
ParamIxb[3]	Controla a altera��o										
ParamIxb[4]	Controla a exclus�o

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
	Caso altera��o ou exclusao e campo  IDFLUIG preenchido, primeiramente cancela
	solicita��o no Fluig para seguir.
	caso solicita��o n�o seja cancelada, n�o permite seguir com altera��o no Prothues.
------------------------------------------------------------------------------------------*/
IF lAltera .OR. lExclui
	IF FnIdFlg(cNum) // !EMPTY(M->C7_XIDFLG) .AND. 
		lRet	:= .T.
	ELSE
		Help("CANFLUIG",1,"CANFLUIG",,"N�o foi possivel cancelar a solicita��o ["+SC7->C7_XIDFLG+"] no FLUIG. Altera��o deste pedido n�o pode ser concluida.",4,5)
	ENDIF
ENDIF


Return(lRet)



/*/{Protheus.doc} FnIdFlg
Realiza cancalamento da solicita��o Protheus no Fluig e limpa
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
Realiza cancelamento da solicita��o do Fluig
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
                        "Processo cancelado atrav�s da integra��o com o Protheus") 
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