#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} M410AGRV
Este ponto de entrada pertence � rotina de pedidos de venda, MATA410(). 
Est� localizado na rotina de grava��o do pedido, A410GRAVA(). � executado antes da grava��o das altera��es.
@author Jonatas Oliveira | www.compila.com.br
@since 08/07/2019
@version 1.0
/*/
user function M410AGRV()
	Local _nOper := PARAMIXB[1]
	Local aRet	:= { .F.,""}

	IF _nOper == 2//|altera��o|
		IF !EMPTY(SC5->C5_XIDFLG) .AND. !EMPTY(SC5->C5_XIDPLE) .AND. SC5->C5_XBLQ == "8"
		
			//|Assume a Solicita��o pelo Integrador|
			aRet := U_cpFTakeP(VAL(SC5->C5_XIDFLG), GETMV("MV_ECMMAT",.F.,""))
			
			IF aRet[1]
				//|Cancela Solicita��o Fluig|
				aRet :=  U_cpCnFlg(VAL(SC5->C5_XIDFLG), GETMV("MV_ECMMAT",.F.,""), " ALTERACAO DE PEDIDO")
				IF aRet[1]
					SC5->(RecLock("SC5",.F.))
//						SC5->C5_XBLQ 	:= "3"
						SC5->C5_XIDFLG 	:= ""	
//						SC5->C5_XIDPLE	:= ""					
					SC5->(MsUnLock())
					
//					/*----------------------------------------
//					28/08/2018 - Jonatas Oliveira - Compila
//					Quando faturamento pessoa Jur�dica, cria 
//					solicita��o no Fluig. 
//					------------------------------------------*/
//					DBSELECTAREA("SA1")
//					SA1->(DBSETORDER(1))
//					SA1->(DBSEEK( XFILIAL("SA1") + SC5->( C5_CLIENTE + C5_LOJACLI ) ))
//					
//					IF SA1->A1_PESSOA == "J"
//				
//						//|Cria Fila de Processamento Solicita��o de Nota|
//						DBSELECTAREA("SZK")
//						SZK->(DBSETORDER(1)) //| 
//						IF SZK->(DBSEEK(SM0->M0_CODIGO + SC5->C5_FILIAL)) 
//							IF SZK->ZK_FATPJAU == "S"
//								IF EMPTY(SC5->C5_XIDFLG) .and. !EMPTY(SC5->C5_XIDPLE)
//									U_CP12ADD("000019", "SC5", SC5->(RECNO()), 		, 		 , "02",  SC5->C5_XIDPLE )
//								ENDIF 
//							ENDIF
//						ENDIF
//						
//						
//					ENDIF 
				ELSE
					Help("Atencao",1,"Faturamento",,"N�o foi possivel atualizar Solicita��o Fluig " + Alltrim(aRet[2]) ,4,5)		
				ENDIF 
			ELSE
				Help("Atencao",1,"Faturamento",,"N�o foi possivel Assumir/atualizar Solicita��o Fluig " + Alltrim(aRet[2]) ,4,5)		
			ENDIF 
		ENDIF 	

	ENDIF 

return()