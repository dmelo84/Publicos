#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE 'TBICONN.CH'
#include 'parmtype.ch'
#INCLUDE "RPTDEF.CH"




/*/{Protheus.doc} ALFATPJ
Função responsavel pela Criação da solicitação
de Nota fiscal de Faturamento PJ no Fluig
@author Jonatas Oliveira | www.compila.com.br
@since 24/08/2018
@version 1.0
@return aRet,Array, com status do processamento, mensagem de falha e codigo do ID Fluig
/*/
User Function ALFATPJ(nRecSC5)
	Local cUserFluig	:= GETMV("MV_ECMMAT",.F.,"") //"nr8n5w2c98gxgh1j1457025211780"
	Local nTaskDest		:= 0
	Local cComments		:= "EmissaoNFFaturamento"
	Local lComplete		:= .T.
	Local lManager		:= .F.
	Local aCardData		:= {}
	Local aRetFluig		:= {}
	Local nCompID		:= 1
	Local nChooSt		:= 5
	Local cProcId		:= "EmissaoNFFaturamento"
	Local oFluig  		:= WSECMWorkflowEngineServiceService():new()
	Local nI, nY, xValor
	Local aVencto		:= {}
	Local aRet			:= { .F. ,"", ""}
	Local nRet			:= 0 
	Local cProces		:= ""
	Local nItem			:= 0 
	Local _cCodEmp		:= ""
	Local _cCodFil		:= ""
	Local _cFilNew		:= ""
	Local nValIss		:= 0 
	Local lPrefOn		:= .F.
//	Local nPosDTFt		:= 0 
//	Local nPosDTPg		:= 0 
	Local cTribCli		:= "" 
	
	Local nAlqCOF	:= 0							 
	Local nAlqCSl	:= 0			
	Local nAlqINS	:= 0			 
	Local nAlqIRF	:= 0				 
	Local nAlqPIS	:= 0

	IF nRecSC5 > 0 

		DBSELECTAREA("SC5")
		SC5->(DBSETORDER(1))
		SC5->(DBGOTO(nRecSC5))


		//|Garanto que está posicionado no Registro Correto|
		IF SC5->(RECNO()) == nRecSC5
		
		
			/*---------------------------------------
			Realiza a TROCA DA FILIAL CORRENTE 
			-----------------------------------------*/
			_cCodEmp 	:= SM0->M0_CODIGO
			_cCodFil	:= SM0->M0_CODFIL
			_cFilNew	:= SF2->F2_FILIAL //| CODIGO DA FILIAL DE DESTINO 
		
			IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
				CFILANT := _cFilNew
				opensm0(_cCodEmp+CFILANT)
			ENDIF
			
			DBSELECTAREA("SC6")
			SC6->(DBSETORDER(1))
			SC6->(DBSEEK(SC5->(C5_FILIAL + C5_NUM)))

			DBSELECTAREA("SA1")
			SA1->(DBSETORDER(1))
			SA1->(DBSEEK(XFILIAL("SA1") + SC5->(C5_CLIENTE + C5_LOJACLI )))
			
			DBSELECTAREA("SB1")
			SB1->(DBSETORDER(1))
			
			DBSELECTAREA("SZK")
			SZK->(DBSETORDER(1)) //| 
			IF SZK->(DBSEEK(SM0->M0_CODIGO + SC5->C5_FILIAL)) .AND. SZK->ZK_FATPJAU == "S" .AND. SZK->ZK_PREFONL == "S"
				lPrefOn := .T.
			ENDIF 
			
			aVencto:= Condicao(SC6->C6_VALOR,SC5->C5_CONDPAG,0,SC5->C5_EMISSAO)

			Aadd(aCardData, {"M0_CODIGO"           		,  "01"			})
			Aadd(aCardData, {"M0_NOME"   				,  "ALLIAR"		})
			Aadd(aCardData, {"M0_CODFIL"            	,  SC5->C5_FILIAL		})
			Aadd(aCardData, {"M0_FILIAL"            	,  FWFilialName("01", SC5->C5_FILIAL ,1)})
			Aadd(aCardData, {"A1_COD"         			,  SC5->C5_CLIENTE		})
			Aadd(aCardData, {"A1_NOME"         			,  ALLTRIM(SA1->A1_NOME)		})
			Aadd(aCardData, {"A1_LOJA"         			,  SC5->C5_LOJACLI		})
			Aadd(aCardData, {"dtFaturamento"        	,  DTOC( DDATABASE ) })
			
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
				
				IF cTribCli == "F"
					/*Aliquotas*/			
					nAlqCOF	:= ZZA->ZZA_XALCOF  							 
					nAlqCSl	:= ZZA->ZZA_XALCSL				
					nAlqINS	:= ZZA->ZZA_XALINS				 
					nAlqIRF	:= ZZA->ZZA_XALIRF				 
					nAlqPIS	:= ZZA->ZZA_XALPIS		
				ENDIF 		
							
			ELSE
				cTribCli := SA1->A1_XTRIBES		
				
				IF cTribCli == "F"
					/*Aliquotas*/			
					nAlqCOF	:= SA1->A1_XALCOF   							 
					nAlqCSl	:= SA1->A1_XALCSL 				
					nAlqINS	:= SA1->A1_XALINS				 
					nAlqIRF	:= SA1->A1_XALIRF				 
					nAlqPIS	:= SA1->A1_XALPIS		
				ENDIF 	
												
			ENDIF 
			
			DBSELECTARE("SED")
			SED->(DBSETORDER(1))
			IF SED->( DBSEEK(XFILIAL("SED") +  SC5->C5_NATUREZ))
						
				IF nAlqCOF == 0 
					nAlqCOF := SED->ED_PERCCOF
				ENDIF 
				
				IF nAlqCSl == 0 
					nAlqCSl := SED->ED_PERCCSL
				ENDIF 
	
				IF nAlqINS == 0 
					nAlqINS := SED->ED_PERCINS
				ENDIF 			
	
				IF nAlqPIS == 0 
					nAlqPIS := SED->ED_PERCPIS
				ENDIF 
	
				IF nAlqIRF == 0 
					nAlqIRF := SED->ED_PERCIRF
				ENDIF 			
			ENDIF 
					
			Aadd(aCardData, {"mvulmes"        			,  DTOC( GetNewPar( "MV_ULMES" , "",  SC5->C5_FILIAL ))		})	
			Aadd(aCardData, {"tribvar"        			,  Lower(cTribCli)		})	
			
			IF VALTYPE(aVencto[1][1]) == "C"
				Aadd(aCardData, {"dtProvPag"         		,  aVencto[1][1]		})
			ELSEIF VALTYPE(aVencto[1][1]) == "D"
				Aadd(aCardData, {"dtProvPag"         		,  DTOC(aVencto[1][1])		})
			ENDIF 
						
			Aadd(aCardData, {"idIntegracao"         	,  SC5->C5_XIDPLE		})
			Aadd(aCardData, {"slMetodoFaturamento"      ,  IIF(lPrefOn,"1","2")		})

			WHILE SC6->(!EOF()) .AND. SC5->(C5_FILIAL + C5_NUM ) == SC6->(C6_FILIAL + C6_NUM )
				nItem ++ 
				
				SB1->(DBSEEK(XFILIAL("SB1") + SC6->C6_PRODUTO))

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Calculo do ISS                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DBSELECTAREA("SF4")
				SF4->(dbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4") + SC6->C6_TES ))

//				If ( SF4->F4_ISS=="S" )
//					nAliqISS := MaAliqISS(nItem)
//					nVMercAux := SC6->C6_VALOR
//					nPrcLsAux := SC6->C6_VALOR
//					nPrcLista := a410Arred(SC6->C6_VALOR/(1-(nAliqISS/100)),"D2_PRCVEN")
//					nValMerc  := a410Arred(SC6->C6_VALOR/(1-(nAliqISS/100)),"D2_PRCVEN")
//					MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
//					MaFisAlt("IT_VALMERC",nValMerc,nItem)
//				EndIf
				
				IF cTribCli == "F"
					/*----------------------------------------
						29/07/2019 - Jonatas Oliveira - Compila
						Atualiza impostos da Tributação Fixa
					------------------------------------------*/
					SC6->(RecLock("SC6",.F.))
					
						/*Aliquotas*/
						SC6->C6_XALCOF	:= nAlqCOF
						SC6->C6_XALCSL	:= nAlqCSl
						SC6->C6_XALINS	:= nAlqINS	
						SC6->C6_XALIRF	:= nAlqIRF
						SC6->C6_XALPIS	:= nAlqPIS		
						
						/*Bases*/
						SC6->C6_XBSCOF 	:= 	SC6->C6_VALOR
						SC6->C6_XBSCSL 	:= 	SC6->C6_VALOR
						SC6->C6_XBSINS 	:= 	SC6->C6_VALOR
						SC6->C6_XBSIRF 	:= 	SC6->C6_VALOR
						SC6->C6_XBSPIS 	:= 	SC6->C6_VALOR
						
						/*Valores Calculados*/
						SC6->C6_XVTRCOF := 	(SC6->C6_VALOR / 100) * nAlqCOF
						SC6->C6_XVTRCSL := 	(SC6->C6_VALOR / 100) * nAlqCSl
						SC6->C6_XVTRINS := 	(SC6->C6_VALOR / 100) * nAlqINS	
						SC6->C6_XVTRIRF := 	(SC6->C6_VALOR / 100) * nAlqIRF
						SC6->C6_XVTRPIS := 	(SC6->C6_VALOR / 100) * nAlqPIS	
																
					SC6->(MsUnLock())
				ENDIF 
				
				Aadd(aCardData, {"B1_COD"      				,  SC6->C6_PRODUTO		})
				Aadd(aCardData, {"B1_DESC"   				,  ALLTRIM(posicione("SB1",1, XFILIAL("SB1") + SC6->C6_PRODUTO ,"B1_DESC"))		})				
				Aadd(aCardData, {"vlBruto"         			,  SC6->C6_VALOR		})
//				Aadd(aCardData, {"vlLiquido"         		,  SC6->C6_VALOR		})	
				
				//|Valores de Impostos|
				Aadd(aCardData, {"pis"         				,  SC6->C6_XVTRPIS		})
				Aadd(aCardData, {"cofins"         			,  SC6->C6_XVTRCOF		})
				Aadd(aCardData, {"csll"         			,  SC6->C6_XVTRCSL		})
				Aadd(aCardData, {"ir"         				,  SC6->C6_XVTRIRF		})
				Aadd(aCardData, {"inss"         			,  SC6->C6_XVTRINS		})
				
				//|Base de Calculo de Impostos|
				Aadd(aCardData, {"pis_calculo"         		,  SC6->C6_XBSPIS		})
				Aadd(aCardData, {"cofins_calculo"         	,  SC6->C6_XBSCOF		})
				Aadd(aCardData, {"csll_calculo"         	,  SC6->C6_XBSCSL		})
				Aadd(aCardData, {"ir_calculo"         		,  SC6->C6_XBSIRF		})
				Aadd(aCardData, {"inss_calculo"         	,  SC6->C6_XBSINS		})
				
				//|Percentuais de Impostos|
				Aadd(aCardData, {"pis_percent"         		,  (SC6->C6_XVTRPIS * 100)/	SC6->C6_XBSPIS })
				Aadd(aCardData, {"cofins_percent"         	,  (SC6->C6_XVTRCOF * 100)/	SC6->C6_XBSCOF})
				Aadd(aCardData, {"csll_percent"         	,  (SC6->C6_XVTRCSL * 100)/	SC6->C6_XBSCSL})
				Aadd(aCardData, {"ir_percent"         		,  (SC6->C6_XVTRIRF * 100)/	SC6->C6_XBSIRF})
				Aadd(aCardData, {"inss_percent"         	,  (SC6->C6_XVTRINS * 100)/	SC6->C6_XBSINS})
				
				IF SC5->C5_RECISS = "1"
					IF SB1->B1_ALIQISS > 0 
						Aadd(aCardData, {"iss"         				,  ROUND( ( ( SC6->C6_VALOR/100) * SB1->B1_ALIQISS),2)			})
						nValIss	:= ROUND( ( ( SC6->C6_VALOR/100) * SB1->B1_ALIQISS),2)
					ELSE
						Aadd(aCardData, {"iss"         				,  ROUND( (SC6->C6_VALOR/100) * GETMV("MV_ALIQISS",.F.,3),2)	})
						nValIss	:= ROUND( (SC6->C6_VALOR/100) * GETMV("MV_ALIQISS",.F.,3),2)
					ENDIF 
				ELSE
					Aadd(aCardData, {"iss"         				,  0					})
					nValIss	:= 0
				ENDIF 
				
				Aadd(aCardData, {"vlLiquido"				,  SC6->C6_VALOR  - (SC6->C6_XVTRPIS + SC6->C6_XVTRCOF + SC6->C6_XVTRCSL + SC6->C6_XVTRINS + nValIss)})
				
				
				Aadd(aCardData, {"outros"         			,  0					})

				SC6->(DBSKIP())
			ENDDO

			Aadd(aCardData, {"observacao"         		,  SC5->C5_MENNOTA		})
			Aadd(aCardData, {"mensagem"         		,  SC5->C5_MENNOTA		})
		
			/*---------------------------------------
			Restaura FILIAL  
			-----------------------------------------*/
			IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
				CFILANT := _cCodFil
				opensm0(_cCodEmp+CFILANT)			 			
			ENDIF 
				
		ENDIF 

	ENDIF 


	IF !EMPTY(aCardData)


		WSDLDbgLevel(2)  

		aRetAux	:= U_cpFNewTsk(cProcId, cUserFluig, nTaskDest, cComments, lComplete, lManager, aCardData)

		IF aRetAux[1]


			aRet[1]	:= .T.
			aRetAux	:= aRetAux

		ELSE
			aRet[2] := aRetAux[2]
		ENDIF		

	ELSE
		//oFluig:oWSstartprocessCardData := oFluig:oWSGetInstanceCardDataCardData //AtualizaCardData do método startprocess
	ENDIF

	
	IF aRet[1] .AND. !EMPTY(aRetAux[3])
		RecLock("SC5",.F.)				
		SC5->C5_XIDFLG :=  aRetAux[3]		
		IF cTribCli == "V"		
			SC5->C5_XBLQ := "8"//|Bloq.: Aguard Complemento Fluig|
		ELSEIF cTribCli == "F"
			SC5->C5_XBLQ := "4"//|Liberado|
		ENDIF 
		SC5->(MsUnLock())	
	ENDIF 	

Return(aRet)

/*/{Protheus.doc} ALFTAPJ
Atualiza solicitação do Fluig com Nota Emitida
@author Jonatas Oliveira | www.compila.com.br
@since 28/08/2018
@version 1.0
/*/
User Function ALFTAPJ(nRecSf2 , lEncerra, nAtivFluig)
	Local aRet			:= { .F. ,"", ""}
	Local aCardData	:= {}
	Local aRetAux	:= {.F.,""}
	Local lIntFluig	:= .T.
	
	Local nvlBruto		:= 0 
	Local nvlLiquido	:= 0 
	Local npis			:= 0 
	Local ncofins		:= 0 
	Local ncsll			:= 0 
	Local nir			:= 0 
	Local niss			:= 0 
	Local ninss			:= 0 
	Local _cCodEmp		:= ""
	Local _cCodFil		:= ""
	Local _cFilNew		:= ""
	
	Local nVlIss := 0 
	Local nVlCsL := 0 
	Local nVlIrr := 0 
	Local nVlCof := 0 
	Local nVlPis := 0 
	Local nVlIns := 0 

	Default lEncerra	:= .T.
	Default nAtivFluig	:= 19


	DBSELECTAREA("SF2")
	SF2->(DBGOTO(nRecSf2))

	IF nAtivFluig == 15//|Atualiza dados nota fiscal eletronica|
		aRetAux[1] := .T.
		lEncerra := .T.
	ELSEIF lEncerra
		aRetAux	:= U_cpFTakeP(VAL(SF2->F2_XIDFLG), GETMV("MV_ECMMAT",.F.,""))
	ELSE
		aRetAux[1] := .T.
		nAtivFluig := 15
	ENDIF 

	/*---------------------------------------
	Realiza a TROCA DA FILIAL CORRENTE 
	-----------------------------------------*/
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	_cFilNew	:= SF2->F2_FILIAL //| CODIGO DA FILIAL DE DESTINO 

	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
	ENDIF	

	/*----------------------------------------
	01/02/2018 - Jonatas Oliveira - Compila
	Movimenta a medição
	------------------------------------------*/
	IF aRetAux[1]
		Aadd(aCardData, {"serie"         			,  SF2->F2_SERIE		})
		Aadd(aCardData, {"notaFiscal"         		,  SF2->F2_DOC			})
		Aadd(aCardData, {"notaFiscalEletronica"     ,  SF2->F2_NFELETR		})
		
		IF !EMPTY(SF2->F2_XIDPLE)
			Aadd(aCardData, {"idIntegracao"         	,  SF2->F2_XIDPLE		})
		ENDIF 
		
		nVlIss := 0 
		nVlCsL := 0 
		nVlIrr := 0 
		nVlCof := 0 
		nVlPis := 0 
		nVlIns := 0 
		
		DBSELECTAREA("SE1")
		SE1->(DBSETORDER(2)) //|E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO|
		IF SE1->(DBSEEK(SF2->(F2_FILIAL + F2_CLIENTE + F2_LOJA + F2_SERIE + F2_DOC )))
			WHILE SE1->(!EOF()) .AND. SF2->(F2_FILIAL + F2_CLIENTE + F2_LOJA + F2_SERIE + F2_DOC ) == SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM)
				IF ALLTRIM(SE1->E1_TIPO) == "NF"

					Aadd(aCardData, {"vlLiquido"  ,  SF2->F2_VALBRUT - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,,SE1->E1_FILIAL) - SF2->( F2_VALPIS + F2_VALCOFI + F2_VALCSLL + F2_VALINSS)	})

					EXIT
				ENDIF 

				SE1->(DBSKIP())
			ENDDO 
		ENDIF 

		Aadd(aCardData, {"vlBruto"         			,  SF2->F2_VALBRUT		})
		//		Aadd(aCardData, {"vlLiquido"         		,  SF2->F2_VALFAT		})
		
		//|Valores de Impostos|
		Aadd(aCardData, {"pis"         				,  SF2->F2_VALPIS		})
		Aadd(aCardData, {"cofins"         			,  SF2->F2_VALCOFI		})
		Aadd(aCardData, {"csll"         			,  SF2->F2_VALCSLL		})
		Aadd(aCardData, {"ir"         				,  SF2->F2_VALIRRF		})
		Aadd(aCardData, {"iss"         				,  SF2->F2_VALISS		})
		Aadd(aCardData, {"inss"         			,  SF2->F2_VALINSS		})
		Aadd(aCardData, {"outros"         			,  0					})
		
		//|Base de Calculo de Impostos|
		Aadd(aCardData, {"pis_calculo"         			,  SF2->F2_BASPIS		})
		Aadd(aCardData, {"cofins_calculo"         		,  SF2->F2_BASCOFI		})
		Aadd(aCardData, {"csll_calculo"         		,  SF2->F2_BASCSLL		})
		Aadd(aCardData, {"ir_calculo"         			,  SF2->F2_BASEIRR		})
		Aadd(aCardData, {"inss_calculo"         		,  SF2->F2_BASEINS		})
		Aadd(aCardData, {"iss_calculo"         			,  SF2->F2_BASEISS		})
		
		//|Percentuais de Impostos|
		Aadd(aCardData, {"pis_percent"         			,  (SF2->F2_VALPIS  * 100)/	SF2->F2_BASPIS })
		Aadd(aCardData, {"cofins_percent"         		,  (SF2->F2_VALCOFI * 100)/	SF2->F2_BASCOFI})
		Aadd(aCardData, {"csll_percent"         		,  (SF2->F2_VALCSLL * 100)/	SF2->F2_BASCSLL})
		Aadd(aCardData, {"ir_percent"         			,  (SF2->F2_VALIRRF * 100)/	SF2->F2_BASEIRR})
		Aadd(aCardData, {"inss_percent"         		,  (SF2->F2_VALINSS * 100)/	SF2->F2_BASEINS})
		Aadd(aCardData, {"iss_percent"         			,  (SF2->F2_VALISS  * 100)/	SF2->F2_BASEISS })
		

		/*
		IF !lEncerra
			nAtivFluig := 4
		ENDIF 
		*/

		WSDLDbgLevel(2)  

		aRetAux	:= U_cpFSSTsk(VAL(SF2->F2_XIDFLG), GETMV("MV_ECMMAT",.F.,""), nAtivFluig,"Nota Fiscal Gerada", lEncerra, .F.,aCardData )	
	ENDIF 
	
	/*---------------------------------------
	Restaura FILIAL  
	-----------------------------------------*/
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)			 			
	ENDIF 


Return(aRetAux) 


User Function TST_FAT()
	lOCAL cTeste	:= ''
	lOCAL aTeste	:= {}
	Local lRetAux
	Local nCount	:= 0 
	Local nI

	_cEmp		:= "01"
	_cFilial	:= "00101MG0001" //01704BA0001-DELFIN SAJ MEDICOS  
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
	U_ALFTAPJ(411859 , .F.)

	RESET ENVIRONMENT
Return()




/*/{Protheus.doc} ALFATPJE
Atualiza Fluig com Exclusao do documento de saída
@author Augusto Ribeiro | www.compila.com.br
@since 30/10/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function ALFATPJE(nRecSf2, nAtividade)
Local aRet		:= { .F. ,"", ""}
Local aRetAux	:= {}

Default nAtividade := 5 //| Automacao faturamento - Emitir NF |
	
	/*--------------------------
		Assume atividade 
	---------------------------*/
	aRetAux	:= U_cpFTakeP(VAL(ZD1->ZD1_IDINTE), GETMV("MV_ECMMAT",.F.,""))
	IF aRetAux[1]
		
		aRetAux	:= U_cpFSSTsk(VAL(ZD1->ZD1_IDINTE), GETMV("MV_ECMMAT",.F.,""), nAtividade,"Nota Fiscal Excluida", .T., .F.,/*aCardData*/ )
		IF aRetAux[1]
			aRet[1]	:= .T.
		ELSE
			aRet[2]	:= aRetAux[2]
		ENDIF
	
	ELSE 
		aRet[2]	:= aRetAux[2]
	ENDIF
	

Return(aRet)


