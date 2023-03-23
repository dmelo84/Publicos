#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} MTA110MNU
//LOCALIZA��O : Executado pela rotina MATA110 ( Rotina de atualizacao manual das solicitacoes de compra).FINALIDADE : O ponto de entrada 'MTA110MNU' � utilizado para adicionar bot�es ao Menu Principal atrav�s do array aRotina.
Programa Fonte
MATA110.PRX
@author Thiago Compila
@since 02/01/2020
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function MTA110MNU()
	aadd(AROTINA,{'Limp Integra��o Bionexo','U_LIMPBIO' , 0 , 3,0,NIL})
Return(AROTINA)

/*/{Protheus.doc} LIMPBIO
//Fun��o onde limpa os campo C1_XSTABIO e C1_XNUMPDC campos integrador com Bionexo.
@author Thiago Compila
@since 02/01/2020
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function LIMPBIO()
	LOCAL cNUmsc	:= SC1->C1_NUM
	LOCAL cfilsc1	:= SC1->C1_FILIAL
	//LOCAL cNUMPDC	:= SC1->C1_XNUMPDC
	LOCAL aAreaAnt 	:= GETAREA()
	
	
	
	IF !EMPTY(SC1->C1_XNUMPDC)
		IF MSGYESNO( "Limpar Integra��o com Bionexo?", "Limpar Bionexo" )
			IF ALLTRIM(SC1->C1_PEDIDO) == "" 
				dbselectArea("SC1")
				dbGoTop()
				dbsetOrder(1)
				IF dbSeek(cfilsc1 + cNUmsc)
					WHILE  SC1->(!EOF()) .AND. SC1->C1_fILIAL = cfilsc1 .and. SC1->C1_NUM = cNUmsc
						RecLock("SC1", .F.)
							//SC1->C1_QUANT := 4
							SC1->C1_XSTABIO := ""
							SC1->C1_XNUMPDC := ""
						MsUnLock()
						SC1->(dbSkip())
					ENDDO
					MSGINFO("SOLICITA��O DE COMPRA LIBERADA.", "SUCESSO")
				ELSE				
					ALERT("SOLICITA��O N�O ENCONTRADA")
				ENDIF	
				
				
			ELSE
				ALERT("N�O PODE LIBERAR SOLICITA��O "+cNUmsc+" J� EXISTE PEDIDO DE COMPRAS")
			ENDIF 
			
		
		ENDIF
	ELSE
		ALERT("SOLICITACAO DE COMPRA NAO INTEGRADA AO BIONEXO")
	ENDIF
	
	
	RESTAREA(aAreaAnt)

Return Nil