#INCLUDE "TOTVS.CH"


// P.E após a gravação do Ped Venda
User Function M410STTS()

	Local aArea 	:= GetArea()
	Local aAreaSC6 	:= SC6->(GetArea())
	Local nTotPv 	:= 0 
//	Local cFilCdb	:= "00201SP0001|00201SP0002|00201SP0003|00201SP0004|00201SP0005|00201SP0006|00201SP0007|00201SP0008|00201SP0009|00201SP0010|00201SP0011|00402SP0001|00201SP0012|00201SP0013|00201SP0014|00201SP0015|00201SP0016|00201SP0017|00201SP0018|00201SP0019|00201SP0020|"
	Local lPrdMot 	:= .F. 
	Local cTribCli	:= ""
	
	IF !(LEFT(ALLTRIM(SC5->C5_XIDPLE),1) $ "V|R|U")

		U_ALRFAT06()
		
		/*----------------------------------------
		28/08/2018 - Jonatas Oliveira - Compila
		Quando faturamento pessoa Jurídica, cria 
		solicitação no Fluig. 
		------------------------------------------*/
		DBSELECTAREA("SA1")
		SA1->(DBSETORDER(1))
		SA1->(DBSEEK( XFILIAL("SA1") + SC5->( C5_CLIENTE + C5_LOJACLI ) ))
		
		IF SA1->A1_PESSOA == "J"

			//|Cria Fila de Processamento Solicitação de Nota|
			DBSELECTAREA("SZK")
			SZK->(DBSETORDER(1)) //| 
			IF SZK->(DBSEEK(SM0->M0_CODIGO + SC5->C5_FILIAL)) 
				IF SZK->ZK_FATPJAU == "S"
					IF EMPTY(SC5->C5_XIDFLG) .and. !EMPTY(SC5->C5_XIDPLE) .OR. altera//.OR. (!EMPTY(SC5->C5_XIDPLE) .AND. )
						U_CP12ADD("000019", "SC5", SC5->(RECNO()), 		, 		 , "02",  SC5->C5_XIDPLE )
																				
						/*----------------------------------------
							20/06/2019 - Jonatas Oliveira - Compila
								Tratativa para verificar os tributos 
								variaveis na tabela ZZA antes de verificar
								no cadastro de clientes		
						------------------------------------------*/
						DBSELECTAREA("ZZA")
						ZZA->(DBSETORDER(1))//|ZZA_FILIAL+ZZA_CODCLI+ZZA_LOJA|
						
						IF  ZZA->(DBSEEK( SC5->( C5_FILIAL + C5_CLIENTE + C5_LOJACLI ) ))
							IF !EMPTY(ZZA->ZZA_XTRIBE)
								cTribCli := ZZA->ZZA_XTRIBE
							ELSE
								cTribCli := SA1->A1_XTRIBES
							ENDIF 
						ELSE
							cTribCli := SA1->A1_XTRIBES										
						ENDIF
						
						IF cTribCli == "V"	
							RecLock("SC5",.F.)					
							SC5->C5_XBLQ := "8"//|Bloq.: Aguard Complemento Fluig|					
							SC5->(MsUnLock())						
						ENDIF 
					ENDIF 
				ENDIF
			ENDIF
			
			
		ENDIF  

		/*----------------------------------------
			05/01/2018 - Jonatas Oliveira - Compila
			Tratativa temporaria para bloqueio de 
			faturamento de pedidos de Motoboy - CDB
		------------------------------------------*/
		/*----------------------------------------
			10/12/2018 - Jonatas Oliveira - Compila
			Alteração da tratativa de motoboy para 
			considerar valor e produto
		------------------------------------------*/
	//	IF SC5->C5_FILIAL $ cFilCdb
		
		IF !GetMV("ES_HABMOT")//|Se a trataiva de motoboy estiver desabiltada Executa|
			DBSELECTAREA("SC6")
			SC6->(DBSETORDER(1))
			IF SC6->(DBSEEK(SC5->(C5_FILIAL + C5_NUM)))

				WHILE SC6->(!EOF()) .AND. SC5->(C5_FILIAL + C5_NUM) == SC6->(C6_FILIAL + C6_NUM)
					nTotPv += SC6->C6_VALOR
					IF ALLTRIM(SC6->C6_PRODUTO) == GetMV("ES_PRDMOT", .F., "23000004")
						lPrdMot	:= .T.
					ENDIF 
					SC6->(DBSKIP())
				ENDDO
				
				/*----------------------------------------
					30/01/2019 - Jonatas Oliveira - Compila
					Verifica se filial está habilitada para 
					Motoboy com o valor do parametro ES_VALMOT
				------------------------------------------*/
				IF !lPrdMot
					DBSELECTAREA("SZK")
					SZK->(DBSETORDER(1))
					
					IF SZK->(DBSEEK(SM0->M0_CODIGO + cFil ))
						IF SZK->ZK_XMOTOB == "S" .AND. nTotPv == GetMV("ES_VALMOT",.F., 12) 
							lPrdMot := .T.
						ENDIF 
					ENDIF
				ENDIF 
				
				IF lPrdMot
					U_ALBLMOT(SC5->(RECNO()))	
				ENDIF 

			ENDIF 
		ENDIF
	
	ENDIF  


	restArea(aAreaSC6)
	restArea(aArea)	

Return


