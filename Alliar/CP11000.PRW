#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
/*/{Protheus.doc} CP11000
Funcoes Genéricas utilizadas em todo o Projeto de Baixa de Cartão de Crédito	
@author Augusto Ribeiro - www.compila.com.br
@since 14/10/2017
@version version
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/

/*--------------------------
	Motivo de Baixa
---------------------------*/
#DEFINE MOTBX_NORMAL "NOR"
#DEFINE MOTBX_TAXA "TXC"


#DEFINE VLR_TOLERA_ESTORNO  0.10

/*-----------------------------------------------------------------
	Codigo da Adquirentes
------------------------------------------------------------------*/
#DEFINE ADQ_BIN  "001"
#DEFINE ADQ_CIELO  "002"
#DEFINE ADQ_GETNET  "003"
#DEFINE ADQ_REDE  "004"

/*-----------------------------------------------------------------
	Tipo de Movimento 	
------------------------------------------------------------------*/
#DEFINE ZCA_TPMOV_PAGAMENTO 	"1"
#DEFINE ZCA_TPMOV_ESTORNO 		"2"
#DEFINE ZCA_TPMOV_TAXA 			"3"



/*-----------------------------------------------------------------
	Status de Processamento do Arquivo 	
------------------------------------------------------------------*/
#DEFINE ZC4_STATUS_PENDENTE  "1"
#DEFINE ZC4_STATUS_PARCIAL  "2"
#DEFINE ZC4_STATUS_PROCESSADO "3"
#DEFINE ZC4_STATUS_DESCONSIDERADO "4"
#DEFINE ZC4_STATUS_FALHA "5"


/*-----------------------------------------------------------------
	STATUS | ZCA Mov. Unificado
------------------------------------------------------------------*/
#DEFINE ZCA_STATUS_PENDENTE			"1"
#DEFINE ZCA_STATUS_PARCIAL 			"2"
#DEFINE ZCA_STATUS_CONCLUIDO 		"3"
#DEFINE ZCA_STATUS_INCONSISTENCIA 	"4"
#DEFINE ZCA_STATUS_FALHA 			"5"
#DEFINE ZCA_STATUS_DESCONSIDERADO	"6"


/*-----------------------------------------------------------------
	TIPO OPERACAO | ZCB - Mov. Unificado x Financeiro SE1, SE5
------------------------------------------------------------------*/
#DEFINE ZCB_TPOPER_BAIXA 			"1"
#DEFINE ZCB_TPOPER_MOV_BANCARIO 	"2"
#DEFINE ZCB_TPOPER_ESTORNO			"3"


/*-----------------------------------------------------------------
	RELACAO DE TABELAS - DE PARA
------------------------------------------------------------------*/
#DEFINE DEPARA_BANDEIRA "001"
#DEFINE DEPARA_DEBITO_CREDITO "002"
#DEFINE DEPARA_ORIGEM_AJUSTE "003"



/*------------------------------------------------------ Augusto Ribeiro | 18/10/2017 - 4:12:48 PM
	SEMAFORO
------------------------------------------------------------------------------------------*/
#DEFINE NOME_SEMAFORO "CP11000_"



/*--------------------------
	RAZAO STATUS
---------------------------*/
#DEFINE RAZ_NAO_LOCALIZADO		"001" //| TITULO NAO LOCALIZADO |
#DEFINE RAZ_JA_BAIXADO 			"002" //| TITULO JA BAIXADO |
#DEFINE RAZ_DIVERGENCIA_SALDO 	"003" //| SALDO DO TITULO DIVERGENTE DO MOVIMENTO ADQUIRENTE |
#DEFINE RAZ_CONTA_NAO_LOCAZ		"004" //| CONTA NAO LOCALIZADA NO CADASTRO DE BANCOS [E6_XCONCAR]                                             |
#DEFINE RAZ_PV_NAO_FATURADO		"005" //| PEDIDO DE VENDA NAO FATURADO
#DEFINE RAZ_PARAMETRIZACAO		"006" //| PARAMETROS EM BRANCO OU CONTEUDO INVALIDO
#DEFINE RAZ_DT_PGTO_FUTURA		"007" //| DATA BAIXA FUTURA
#DEFINE RAZ_DIF_PARCELA			"008" //| DIVERGENCIA DE PARCELA
#DEFINE RAZ_DIF_FILIAL			"009" //| DIVERGENCIA DE FILIAL
#DEFINE RAZ_NF_NAO_EMITIDA		"010" //| NOTA FISCAL NÃO EMITIDA
#DEFINE RAZ_MARCA				"011" //| MARCA DO BANCO NÃO CORRESPONDE COM A FILIAL

#DEFINE RAZ_S01		"S01" //| ROTEIRO 1  |
#DEFINE RAZ_S02		"S02" //| ROTEIRO 2  |
#DEFINE RAZ_S03		"S03" //| ROTEIRO 3 |
#DEFINE RAZ_T01		"T01" //| ROTEIRO TAXA 1  |
#DEFINE RAZ_E01		"E01" //| ROTEIRO ESTORNO 1  |



/*/{Protheus.doc} CP11VLBX
Calcula valores de cada baixa que será realizada em cada titulo
proporcionalmente de acordo com o registro de Mov. Unificado (ZCA)
IMPORTANTE: Esta função NAO realiza a baixa, somente calcula os valores.
DESTALHES DO RETORNO: 
	lRet	 = Processado com Sucesso
	lBxTotal = True todos os titulos serão baixados em sua totalidade ou seja, soma dos Saldos condizem com o total bruto do movimento
	cMsgErro = Mensagem de Erro
	aValores = {{nRecTit,nVlrBx_NORMAL, nVlrBx_TAXA}}Valores de cada baixa e seu respectivo motivo
	nSaldoMA = Saldo Restante no Movimento da Adquirente
@author Augusto Ribeiro | www.compila.com.br
@since 21/10/2017
@version 6
@param nRecMov, Recno do Movimento (ZCA)
@param aRecTit, {{Recno dos Titulos que serão baixados, Vlr Desconto / Acrescimo}}} 
@return aRet, {lRet, lBxTotal, aValores, nSaldoMA}  | aValores = {{aRecTit[nI],nVBxNOR, nVBxTX, nVlrAcerto}}  Valor do Acerto deve incidir somente sobre a baixa normal
@example
(examples)
@see (links_or_references)
/*/
User Function CP11VLBX(nRecMov, aRecTit)
	Local lRet		:= .F.
	Local lBxTotal	:= .F.
	Local cMsgErro	:= ""
	Local aValores	:= {}
	Local nSaldoMA	:= 0
	Local nI, nVBxNOR, nVBxTX, nSaldoMA
	Local nVlrBase	:= 0
	Local aRet 		:= {}
	Local nZCBRECALI	:= TAMSX3("ZCB_RECALI")[1]
	Local nVlrAcerto	:= 0
	Local nVlrTotBx	:= 0
	Local nSaldoTit	:= 0
	Local nAuxSaldo	:= 0
	Local nAbat := 0

	IF !EMPTY(nRecMov) .AND. !EMPTY(aRecTit)
		DBSELECTAREA("ZCB")
		ZCB->(DBSETORDER(2)) //| ZCB_FILIAL, ZCB_CODMOV, ZCB_ALIAS, ZCB_RECALI, ZCB_TPOPER, ZCB_MOTBX, R_E_C_N_O_, D_E_L_E_T_


		dbSelectArea("ZCA")
		ZCA->(DBGOTO(nRecMov))

		nSaldoMA	:= ZCA->ZCA_SALDO
		nPercTaxa	:= ((ZCA->ZCA_VTAXA*-1)*100)/ZCA->ZCA_VBRUTO


		DBSELECTAREA("SE1")
		lBxTotal	:= .T.
		FOR nI := 1 to len(aRecTit)

		/*------------------------------------------------------ Augusto Ribeiro | 31/10/2017 - 7:09:01 PM
			Controle para baixa considerar valor das baixas já existentes
		------------------------------------------------------------------------------------------*/
		nJaNor		:= 0
		nJaTaxa	:= 0
		
		cChvZCB	:= ZCA->ZCA_CODIGO+"SE1"+PADL(ALLTRIM(STR(aRecTit[nI,1])),nZCBRECALI)
			IF ZCB->(DBSEEK(xfilial("ZCB")+cChvZCB ))

				WHILE ZCB->(!EOF()) .AND. cChvZCB == ZCB->ZCB_CODMOV+"SE1"+PADL(ALLTRIM(STR(ZCB->ZCB_RECALI)),nZCBRECALI)
			
					IF ZCB->ZCB_TPOPER == ZCB_TPOPER_BAIXA
						IF ZCB->ZCB_MOTBX == MOTBX_NORMAL
						nJaNor		+= ZCB->ZCB_VLRMOV
						ELSEIF ZCB->ZCB_MOTBX == MOTBX_TAXA
						nJaTaxa	+= ZCB->ZCB_VLRMOV
						ENDIF
					ENDIF
				
				
				ZCB->(DBSKIP()) 
				ENDDO
			
			
			/*------------------------------------------------------ Augusto Ribeiro | 31/10/2017 - 7:41:21 PM
				Soma valores já baixados para alterar a base de calculo, e abate no final, de modo 
				que não seja alterado o percentual da taxa sobre o titulo e movimento.
			------------------------------------------------------------------------------------------*/
			//nSaldoMA	+= nJaNor+nJaTaxa		
			ENDIF
		
	
	
		/*------------------------------------------------------ Augusto Ribeiro | 31/10/2017 - 7:25:59 PM
			Calcula valores da taxa e do baixa normal.
		------------------------------------------------------------------------------------------*/
		SE1->(DBGOTO(aRecTit[nI,1]))
		nSaldoTit	:= SE1->E1_SALDO
		nVlrBase	:= 0

		nAbat   := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", SE1->E1_MOEDA, dDataBase, SE1->E1_CLIENTE, SE1->E1_LOJA, xFilial("SE1", SE1->E1_FILORIG), dDataBase, SE1->E1_TIPO)
			If nAbat > 0
			cMsgErro := "O título selecionado possui abatimentos e portanto não poderá ser baixado através do conciliador."
			EXIT
			Endif

			IF nSaldoMA < SE1->E1_SALDO
			nVlrBase	:= nSaldoMA
			lBxTotal	:= .F.
			ELSE
			nVlrBase	:= SE1->E1_SALDO
			ENDIF
		nVBxTX	:= ROUND(nVlrBase*(nPercTaxa/100),2)
		nVBxNOR	:= nVlrBase - nVBxTX
		
		
		/*------------------------------------------------------ Augusto Ribeiro | 31/10/2017 - 7:28:39 PM
			Indica que existem lançamentos orfaos, realizando ajuste de valor da taxa ou bx normal
		------------------------------------------------------------------------------------------*/
			IF (nJaNor > 0 .OR. nJaTaxa > 0) .AND.  (nJaNor == 0 .OR. nJaTaxa == 0)
				IF nJaTaxa > 0
					IF nJaTaxa >= nVBxTX
					nVBxTX	:=	0
					ELSE
					nVBxTX	:=	nVBxTX-nJaTaxa
					ENDIF
			
			
				nVBxNOR	:= nVlrBase - nVBxTX
			 
				ELSEIF nJaNor > 0
					IF nJaNor >= nVBxNOR
					nVBxNOR	:=	0
					ELSE
					nVBxNOR	:=	nVBxNOR-nJaNor
					ENDIF
				
				nVBxTX	:= ROUND((nJaNor+nVlrBase)*(nPercTaxa/100),2)
				
				ENDIF
			
			ENDIF
		

		/*------------------------------------------------------ Augusto Ribeiro | 15/11/2017 - 3:05:07 PM
			Calculos abaixo visam impedir que valores de desconto ou acrescimo sejam incoerentes 
			com o saldo do titulo ou movimento adquirente
		------------------------------------------------------------------------------------------*/
		nVlrAcerto	:= aRecTit[nI,2]
			IF !EMPTY(nVlrAcerto)
				IF nVlrAcerto > 0
				nAuxSaldo	:= nSaldoMA-(nVBxNOR+nVBxTX)
					IF  nAuxSaldo > 0
						IF nAuxSaldo <= nVlrAcerto
						nVlrAcerto	:= nAuxSaldo
						ENDIF
					ELSE
					nVlrAcerto	:= 0
					ENDIF
			
				ELSE
				//| Inverte valor para calculo correto|
				nVlrAcerto	:= nVlrAcerto*-1
				
					IF nVlrAcerto < nVBxNOR
				
					/*----------------------------------------------------------------------------------------
						Verifica se titulo terá saldo para incorporar o desconto solicitado 
						Desconto maximo é o resto do saldo do titulo (caso desconto solicitado seja maior)
					--------------------------------------------------------------------------------------*/
					nRestSaldo	:= nSaldoTit - (nVBxNOR+nVBxTX)	
						IF nRestSaldo > 0
							IF nRestSaldo <= nVlrAcerto
							nVlrAcerto		:= nRestSaldo
							ENDIF
						ELSE
						//nVlrAcerto	:= 0
						nVBxNOR	:= nVBxNOR-nVlrAcerto //| Altera valor da baixa normal para não conflitar na saldo na hora da baixa|						
						ENDIF
								
					nVlrAcerto	:= nVlrAcerto*-1
					ELSE
					cMsgErro	:= "Valor do desconto supera o valor da baixa normal."
					EXIT
					ENDIF
				ENDIF
			ENDIF
						

		
		
		/*------------------------------------------------------ Augusto Ribeiro | 21/10/2017 - 4:34:39 PM
			Caso nSaldoMA , seja igual ao Valor to Titulo
			aValores {RECNO, VLR BAIXA NORMAL, VALOR TAXA, VALOR DESCONTO/ACRESCIMO}
		------------------------------------------------------------------------------------------*/		
		AADD(aValores,{aRecTit[nI,1], nVBxNOR, nVBxTX, nVlrAcerto })
		
	
		//nVlrTotBx	+= nVBxNOR+nVBxTX+nVlrAcerto
			IF nVlrAcerto > 0
			nSaldoMA	:= nSaldoMA-(nVBxNOR+nVBxTX+nVlrAcerto)
			ELSE
			nSaldoMA	:= nSaldoMA-(nVBxNOR+nVBxTX)//+(nVlrAcerto*-1))
				IF nSaldoMA < 0
				nSaldoMA := 0
				ENDIF
			ENDIF
		
			IF nSaldoMA-nVlrTotBx <= 0
			EXIT			
			ENDIF
		
		NEXT nI
	ELSE
	cMsgErro	:= "Parametros inválidos [CP11VLBX]"
	ENDIF

	if empty(cMsgErro)
	lRet		:= .T.
	ELSE
	aValores	:= {}
	endif

aRet 		:= {lRet, lBxTotal, cMsgErro, aClone(aValores), nSaldoMA}

Return(aRet)



/*/{Protheus.doc} CP11BAIX
Realiza a Baixa de Titulo com base dno Movimento Unificado
@author Augusto Ribeiro | www.compila.com.br
@since 14/10/2017
@version 6
@param nRecMov, Recno do Movimento (ZCA)
@param aRegCR, Recno Contas a Receber (SE1) {{nRecSE1, nVlrAjuste}} |Acrescimo ou Decrescimo|
@param aTitBaixa, Dados a serem baixados - {{nRecTit, cMotBx, nVlrBaixa}}
@param cCodRazao, Cod. Razao gravado na ZCA
@return aRet, {lRet, cMsgErro}
@example
(examples)
@see (links_or_references)
/*/
User Function CP11BAIX(nRecZCA, aRegCR, cCodRazao, dDtProc, cHrProc, aDadosEnv)

	Local aRetAux, aTit, aTitBaixa
	Local nI
	Local oError	:= ErrorBlock( {|e| CP11ErrFor(e) } )

	Private aRet	:= {.f., ""}

	Default aDadosEnv := {}

	BEGIN SEQUENCE
		IF !EMPTY(nRecZCA) .AND. !EMPTY(aRegCR)
			// ----------------------------------------
			//	Calcula Valores a Serem Baixados
			//-----------------------------------------
			aRetAux	:= U_CP11VLBX(nRecZCA,aRegCR)
			IF aRetAux[1]

				aTit	:= ACLONE(aRetAux[4])
				FOR nI := 1 to LEN(aTit)

					aTitBaixa	:= {}
					IF !EMPTY(aTit[nI,2])
						AADD(aTitBaixa, {aTit[nI,1], MOTBX_NORMAL, aTit[nI,2], aTit[nI,4]})
					ENDIF
					IF !EMPTY(aTit[nI,3])
						AADD(aTitBaixa, {aTit[nI,1], MOTBX_TAXA, aTit[nI,3], 0})
					ENDIF
					// ------------------------------------------------------ Augusto Ribeiro | 21/10/2017 - 5:22:02 PM
					//	Realiza a baixa dos titulos e mov. unificado adquirente
					//------------------------------------------------------------------------------------------
					aRetAux	:= U_CP11BXE1(nRecZCA, aTitBaixa, cCodRazao, dDtProc, cHrProc)

					IF !(aRetAux[1])
						aRet[2] := aRetAux[2]
						EXIT
					ENDIF
				NEXT nI
			ELSE
				aRet[2] := aRetAux[3]
			ENDIF


			IF EMPTY(aRet[2])
				aRet[1]	:= .T.
			ENDIF
		ELSE
			aRet[2] := "Parametros inválidos [CP11BAIX]"
		ENDIF

	END SEQUENCE

	ErrorBlock( oError )

Return(aRet)






/*/{Protheus.doc} CP11BXE1
Realiza a Baixa de Titulo com base dno Movimento Unificado, motivo de baixa e Valores passados.
@author Augusto Ribeiro | www.compila.com.br
@since 14/10/2017
@version 6
@param nRecMov, Recno do Movimento (ZCA)
@param aTitBaixa, Dados a serem baixados - {{nRecTit, cMotBx, nVlrBaixa, nVlrAjus (Desconto, Multa)}} 
@return aRet, {lRet, cMsgErro}
@example
(examples)
@see (links_or_references)
/*/
User Function CP11BXE1(nRecMov, aTitBaixa, cCodRazao, dDtProc, cHrProc)
	Local aRet		:= {.F., "", ""}
	Local cIncons	:= ""
	Local cMsgErro	:= ""
	Local cQuery	:= ""
	Local nI, aRetAux, cChvTit
	Local aDadoZCB	:= {}
	Local cBanco, cAgencia, cConta
	Local nDesconto, nMulta
	Local cCodIncon	:= ""
	Local cFilBCO	:= ""



	Local _cCodEmp, _cCodFil, _cFilNew

//| ### ADICIONAR SEMAFORO |

	#DEFINE D_RECTIT	1
	#DEFINE D_MOTBX		2
	#DEFINE D_VLRBX		3
	#DEFINE D_VLRAJUSTE		4


	IF !EMPTY(nRecMov) .AND. !EMPTY(aTitBaixa)

		DBSELECTAREA("ZCA")
		ZCA->(DBGOTO(nRecMov))


		IF ZCA->ZCA_STATUS <> ZCA_STATUS_CONCLUIDO



			//	/*--------------------------------------------------------------------------
			//		Dados bancários para localizado do banco através de campo  customizado
			//	---------------------------------------------------------------------------------------*/
			aRetAux	:= U_CP11BCO(ZCA->ZCA_BANCO, ZCA->ZCA_AGENC, ZCA->ZCA_CONTA)

			IF !EMPTY(aRetAux)

				// /*--------------------------------------------------------------------------
				//	Dados bancários para baixa do titulo
				// ---------------------------------------------------------------------------------------*/
				cFilBCO		:= aRetAux[4]
				cBanco		:= aRetAux[1]
				cAgencia	:= aRetAux[2]
				cConta		:= aRetAux[3]

				BEGIN TRANSACTION

					DBSELECTAREA("SE1")
					FOR nI := 1 TO Len(aTitBaixa)

						//| Desconsidera valor Zerado |
						IF aTitBaixa[nI, D_VLRBX] <= 0
							LOOP
						ENDIF


						//		/*----------------------------------
						//			Valida Saldo do Movimento
						//		-----------------------------------*/
						IF ZCA->ZCA_SALDO >= aTitBaixa[nI, D_VLRBX]

							//			/*----------------------------------
							//				POSICIONA NO TITULO
							//			-----------------------------------*/
							SE1->(DBGOTO(aTitBaixa[nI, D_RECTIT]))
							cChvTit	:= SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)

							//		/*------------------------------------------------------ Augusto Ribeiro | 20/11/2017 - 7:48:56 PM
							//			Verifica se conta existe na filial no qual o titulo pertence.
							//		------------------------------------------------------------------------------------------*/
							IF LEFT(SE1->E1_FILIAL,LEN(cFilBCO)) == cFilBCO


								//				/*---------------------------------------
								//					Realiza a TROCA DA FILIAL CORRENTE
								//				-----------------------------------------*/
								_cCodEmp 	:= SM0->M0_CODIGO
								_cCodFil	:= SM0->M0_CODFIL
								_cFilNew	:= SE1->E1_FILIAL //| CODIGO DA FILIAL DE DESTINO

								IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
									CFILANT := _cFilNew
									opensm0(_cCodEmp+CFILANT)
								ENDIF


								//		/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 11:51:30 AM
								//
								//				*** REALIZA A BAIXA DO TITULO ***
								//
								//			------------------------------------------------------------------------------------------*/
								aRetAux	:= BxTit(aTitBaixa[nI, D_RECTIT],aTitBaixa[nI, D_MOTBX], cBanco, cAgencia, cConta,aTitBaixa[nI, D_VLRBX],aTitBaixa[nI, D_VLRAJUSTE],ZCA->ZCA_DTPAG )

								IF aRetAux[1]

							/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 11:37:13 AM
								Grava ZCB - Rastreabilidade de Mov. Unificado x Titulo
							------------------------------------------------------------------------------------------*/
							aDadoZCB	:= {}
							AADD(aDadoZCB, {"ZCB_CODMOV", ZCA->ZCA_CODIGO})
							AADD(aDadoZCB, {"ZCB_ALIAS", "SE1"})
							AADD(aDadoZCB, {"ZCB_RECALI", aTitBaixa[nI, D_RECTIT]})
							AADD(aDadoZCB, {"ZCB_INDALI", 1})
							AADD(aDadoZCB, {"ZCB_CHVALI", cChvTit})
							AADD(aDadoZCB, {"ZCB_VLRMOV", aTitBaixa[nI, D_VLRBX]})
							AADD(aDadoZCB, {"ZCB_MOTBX", aTitBaixa[nI, D_MOTBX]})
							AADD(aDadoZCB, {"ZCB_TPOPER", ZCB_TPOPER_BAIXA })
							AADD(aDadoZCB, {"ZCB_DTMOV", ZCA->ZCA_DTPAG})
							AADD(aDadoZCB, {"ZCB_VAJUST", aTitBaixa[nI, D_VLRAJUSTE]})
							
							aRetAux	:= U_CPXGRV("ZCB", 1, aDadoZCB, .T., 3)
							
									IF aRetAux[1]
							
								/*--------------------------------
									Abate Saldo do Movimento
								---------------------------------*/
								RECLOCK("ZCA",.F.)
									
										IF aTitBaixa[nI, D_VLRAJUSTE] > 0
										ZCA->ZCA_SALDO	:= ZCA->ZCA_SALDO-(aTitBaixa[nI, D_VLRBX]+aTitBaixa[nI, D_VLRAJUSTE])
										ELSE
										ZCA->ZCA_SALDO	:= ZCA->ZCA_SALDO-aTitBaixa[nI, D_VLRBX]
										ENDIF
									ZCA->ZCA_LOG	:= ""
									
										IF ZCA->ZCA_SALDO > 0
										ZCA->ZCA_STATUS	:= ZCA_STATUS_PARCIAL
										ELSE
										ZCA->ZCA_STATUS	:= ZCA_STATUS_CONCLUIDO
										ENDIF
									
									/*------------------------------------------------------ Augusto Ribeiro | 06/11/2017 - 9:13:49 AM
										Caso não seja enviado a Razao do Status, Zera Razao
									------------------------------------------------------------------------------------------*/
										IF !EMPTY(cCodRazao)
										ZCA->ZCA_CODRAZ	:= cCodRazao
										ELSEIF !EMPTY(ZCA->ZCA_CODRAZ)
										ZCA->ZCA_CODRAZ	:= ""
										ENDIF
									
										IF !EMPTY(dDtProc)
										ZCA->ZCA_DTPROC	:= dDtProc
										ZCA->ZCA_HRPROC	:= cHrProc
										ELSE
										ZCA->ZCA_DTPROC	:= DATE()
										ZCA->ZCA_HRPROC	:= TIME()
										ENDIF
									
									
								MSUNLOCK()				
									ELSE
								DISARMTRANSACTION()
								cMsgErro	:= aRetAux[2]+"."//| Concatena ponto para evitar falso positivo carro erro venha vazio|
									ENDIF
								ELSE
							DISARMTRANSACTION()
							cMsgErro	:= aRetAux[2]+"."//| Concatena ponto para evitar falso positivo carro erro venha vazio|	
								ENDIF
						
						
						/*---------------------------------------
							Restaura FILIAL  
						-----------------------------------------*/
								IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
							CFILANT := _cCodFil
							opensm0(_cCodEmp+CFILANT)			 			
								ENDIF
							ELSE
						DISARMTRANSACTION()
						cIncons		:= "Banco, Agencia e Conta pertence a Filial ["+cFilBCO+"] Diferente do Titulo ["+cChvTit+"]"
						cCodIncon	:= 	RAZ_DIF_FILIAL							
							ENDIF
						ELSE
					DISARMTRANSACTION()
					cIncons		:= "Saldo do Movimento insuficiente. SALDO ["+ALLTRIM(STR(ZCA->ZCA_SALDO))+"] - VALOR BAIXA["+ALLTRIM(STR(aTitBaixa[nI, D_VLRBX]))+"]"
					cCodIncon	:= 	RAZ_DIVERGENCIA_SALDO	
						ENDIF
				
				
				/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 11:34:53 AM
					EXIT esta aqui pois é necessário restaurar a FILIAL antes de sair do Loop em caso de erro
				------------------------------------------------------------------------------------------*/		
						IF !EMPTY(cMsgErro)
					EXIT
						ENDIF
					NEXT nI
			
				END TRANSACTION

			ELSE
			cIncons		:= "Banco + Agencia + Conta ["+ZCA->ZCA_BANCO+ZCA->ZCA_AGENC+ZCA->ZCA_CONTA+"] não localizado. Verifique se a numero da conta recebida da adquirente esta vinculado no cadastros de bancos (A6_XCONCAR)."
			cCodIncon	:= RAZ_CONTA_NAO_LOCAZ
			ENDIF
		ELSE
		cIncons	:= "Este registro nao pode sofre alteracao. Status CONCLUIDOS [CP11BAIX]."
		ENDIF
	ELSE
	cMsgErro	:= "Parametros invalidos [CP11BAIX]."
	ENDIF



	IF EMPTY(cMsgErro) .AND. EMPTY(cIncons)
	aRet[1]	:= .T. 
	ELSE
	aRet[2]	:= cMsgErro+" "+cIncons
	
		IF !EMPTY(cMsgErro)
		cStMov	:= ZCA_STATUS_FALHA
		ELSEIF !EMPTY(cIncons)
		cStMov	:= ZCA_STATUS_INCONSISTENCIA
		ENDIF
	
	/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 3:02:20 PM
		Registra LOG e STATUS FALHA/INCONSISTENCIA no movimento unificado
	------------------------------------------------------------------------------------------*/
	RECLOCK("ZCA",.F.)
		ZCA->ZCA_STATUS	:= cStMov
		ZCA->ZCA_LOG	:= aRet[2]
		IF !empty(cCodIncon)
			ZCA->ZCA_CODRAZ	:=  cCodIncon
		ENDIF
		IF !EMPTY(dDtProc)
			ZCA->ZCA_DTPROC	:= dDtProc
			ZCA->ZCA_HRPROC	:= cHrProc
		ELSE
			ZCA->ZCA_DTPROC	:= DATE()
			ZCA->ZCA_HRPROC	:= TIME()
		ENDIF
	MSUNLOCK()
	ENDIF
	
Return(aRet)




 
/*/{Protheus.doc} BxTit
Baixa titulo de acordo com os parametros passados
@author Augusto Ribeiro | www.compila.com.br
@since 29/11/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function BxTit(_nRecnoE1,_cMotBx,_cPortado,_cAgeDep,_cConta,_nVlRec,nVlrAjuste,_dDtRec)
	Local aRet			:= {.f.,""}
	Local aBaixa		:=	{}
	Local _aAreaAtu 	:= GetArea()
	Local _cCodFil  	:= cFilAnt
	Local _dDataBase	:= dDataBase
	Local cMemo, cAutoLog

	Default nVlrAjuste	:= 0

/*--------------------------
	Soma multa no valor recebido
---------------------------*/
	IF  nVlrAjuste > 0
	_nVlRec	:= _nVlRec+nVlrAjuste
	ENDIF

DbSelectArea("SE1")   
SE1->(DbGoTo(_nRecnoE1))
															
aAdd( aBaixa, { "E1_FILIAL" 	, SE1->E1_FILIAL						, Nil } )	// 01
aAdd( aBaixa, { "E1_PREFIXO" 	, SE1->E1_PREFIXO						, Nil } )	// 01
aAdd( aBaixa, { "E1_NUM"     	, SE1->E1_NUM		 					, Nil } )	// 02
aAdd( aBaixa, { "E1_PARCELA" 	, SE1->E1_PARCELA						, Nil } )	// 03
aAdd( aBaixa, { "E1_TIPO"    	, SE1->E1_TIPO							, Nil } )	// 04
aAdd( aBaixa, { "E1_CLIENTE"	, SE1->E1_CLIENTE						, Nil } )	// 05
aAdd( aBaixa, { "E1_LOJA"    	, SE1->E1_LOJA							, Nil } )	// 06
aAdd( aBaixa, { "AUTMOTBX"  	, _cMotBx								, Nil } )	// 07
aAdd( aBaixa, { "AUTBANCO"  	, _cPortado								, Nil } )	// 08
aAdd( aBaixa, { "AUTAGENCIA"	, PADR(_cAgeDep,TAMSX3("A6_AGENCIA")[1])								, Nil } )	// 09
aAdd( aBaixa, { "AUTCONTA"  	, PADR(_cConta,TAMSX3("A6_NUMCON")[1])								, Nil } )	// 10
aAdd( aBaixa, { "AUTDTBAIXA"	, _dDtRec			                	, Nil } )	// 11
aAdd( aBaixa, { "AUTDTCREDITO"	, _dDtRec              				    , Nil } )	// 11
aAdd( aBaixa, { "AUTHIST"   	, "BX AUT CARTAO "                  	, Nil } )	// 12
aAdd( aBaixa, { "AUTVALREC" 	, _nVlRec								, Nil } )	// 13

	IF nVlrAjuste < 0
	aAdd( aBaixa, { "AUTDESCONT" 	, nVlrAjuste*-1								, Nil } )	// 13
	ELSEIF nVlrAjuste > 0
	aAdd( aBaixa, { "AUTMULTA"		, nVlrAjuste								, Nil } )	// 14
	ENDIF
		  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na Filial para efetuar a baixa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cCodFil	:= cFilAnt
dDataBase   := _dDtRec
cFilAnt		:= SE1->E1_FILIAL

lMSErroAuto := .F.
lMSHelpAuto := .T.
MSExecAuto({|x, y| Fina070(x, y)}, aBaixa,3)  
cFilAnt := _cCodFil
dDataBase := _dDataBase
	If 	lMsErroAuto
    
	//MostraErro()
	cAutoLog	:= alltrim(NOMEAUTOLOG())

	cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
	CONOUT("CP11000 BxTit | "+DTOC(date())+" "+TIME(), cMemo)
	cMemo := STRTRAN(cMemo,"'","")

	//| Apaga arquivo de Log
	Ferase(cAutoLog)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le Log da Execauto e retorna mensagem amigavel ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRet[2] := U_CPXERRO(cMemo)

		IF EMPTY(aRet[2])
		aRet[2]	:= alltrim(cMemo)
		ENDIF

	ELSE
	
	aRet[1]	:= .t.
	Endif

RestArea(_aAreaAtu)

Return(aRet)





/*/{Protheus.doc} CP11ESTF
Estorna movimentações financerias.
Utilizada no cancelamento de Baixa e Estorno Mov. Bancaria
@author Augusto Ribeiro | www.compila.com.br
@since 30/10/2017
@version 6
@param cAliRef, Alias de Referencia
@param nRecAli, Recno do Alias
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP11ESTF(cAliRef, nRecAli, cMotBx, nVlrEst)
	Local aRet		:= {.F.,""}
	Local aArea		:= GetArea()
	Local nDifSaldo, aAreaZCB
	Local aX3VLRMOV		:= TAMSX3("ZCB_VLRMOV")

	Default cAliRef	:= ""
	Default cMotBx	:= ""

	IF !EMPTY(nRecAli)
		IF cAliRef == "SE1"

			//IF !EMPTY(cMotBx)

			DBSELECTAREA("SE1")
			aAreaSE1	:= SE1->(GetArea())
			SE1->(DBGOTO(nRecAli))

			cQuery := " SELECT ZCB.R_E_C_N_O_ AS ZCB_RECNO "+CRLF
			cQuery += " FROM "+RetSqlName("ZCB")+" ZCB "+CRLF
			cQuery += " WHERE ZCB_ALIAS = 'SE1' "+CRLF
			cQuery += " AND ZCB_RECALI = "+alltrim(str(nRecAli))+CRLF
			cQuery += " AND ZCB_MOTBX = '"+cMotBx+"' "+CRLF
			cQuery += " AND ZCB_TPOPER = '"+ZCB_TPOPER_BAIXA+"' "+CRLF
			//| Necessário o tratamento abaixo para correto vinculo quando baixa possui desconto ou acrescimo |
			IF ALLTRIM(SE1->E1_TIPO) == "RA"
				cQuery += " AND ZCB_VLRMOV = "+alltrim(str(nVlrEst))+CRLF
			ELSE
				//cQuery += " AND CASE WHEN ZCB_VAJUST > 0 THEN ZCB_VLRMOV+ZCB_VAJUST ELSE ZCB_VLRMOV END = "+alltrim(str(nVlrEst))+CRLF
				cQuery += " AND CASE WHEN ZCB_VAJUST > 0 THEN CONVERT(DECIMAL("+ALLTRIM(STR(aX3VLRMOV[1]))+","+ALLTRIM(STR(aX3VLRMOV[2]))+"), ZCB_VLRMOV+ZCB_VAJUST) ELSE ZCB_VLRMOV END = "+alltrim(str(nVlrEst))+CRLF
			ENDIF
			cQuery += " AND ZCB.D_E_L_E_T_ = '' "+CRLF

			If Select("TZCB") > 0
				TZCB->(DbCloseArea())
			EndIf

			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TZCB",.F., .T.)


			IF TZCB->(!EOF())

				DBSELECTAREA("ZCB")
				ZCB->(DBGOTO(TZCB->ZCB_RECNO))

				DBSELECTAREA("ZCA")
				ZCA->(DBSETORDER(1)) //| ZCA_FILIAL, ZCA_CODIGO, R_E_C_N_O_, D_E_L_E_T_
				IF ZCA->(DBSEEK(xfilial("ZCA")+ZCB->ZCB_CODMOV))

					BEGIN TRANSACTION

					/*------------------------------------------------------ Augusto Ribeiro | 30/10/2017 - 5:32:51 PM
						Estorna movimento na tabela de rastreabilidade.
					------------------------------------------------------------------------------------------*/
					RECLOCK("ZCB",.F.)
						ZCB->ZCB_TPOPER	:= ZCB_TPOPER_ESTORNO
						ZCB->ZCB_DTEST	:= DDATABASE
						ZCB->ZCB_HREST	:= TIME()			
					MSUNLOCK()		
					
					/*------------------------------------------------------ Augusto Ribeiro | 30/10/2017 - 5:32:15 PM
						Estorna valor do movimento unificado
						Altera Status					
					------------------------------------------------------------------------------------------*/
					RECLOCK("ZCA",.F.)
						IF ZCB->ZCB_VAJUST > 0
							ZCA->ZCA_SALDO 	:= ZCA->ZCA_SALDO+ZCB->ZCB_VLRMOV+ZCB->ZCB_VAJUST
						ELSE
							ZCA->ZCA_SALDO 	:= ZCA->ZCA_SALDO+ZCB->ZCB_VLRMOV
						ENDIF
						
						/*------------------------------------------------------ Augusto Ribeiro | 02/01/2018 - 2:29:06 PM
							Tratametno para diferenças no saldo quando estorno.
							Em alguns casos, fica um saldo de centavos em função do arredondamento deixando
							o movimento com status parcial.
							Melhoria visa contornar este problema de arredondamento
						------------------------------------------------------------------------------------------*/
						lAllEst	:= .F.
						nDifSaldo	:= ZCA->ZCA_SALDO - ZCA->ZCA_VBRUTO
						IF nDifSaldo <> 0 .AND. (nDifSaldo <= VLR_TOLERA_ESTORNO .AND. nDifSaldo >= (VLR_TOLERA_ESTORNO * -1) )
							
							DBSELECTAREA("ZCB")
							aAreaZCB	:= ZCB->(GETAREA())
							ZCB->(DBSETORDER(2)) //| ZCB_FILIAL, ZCB_CODMOV, ZCB_ALIAS, ZCB_RECALI, ZCB_TPOPER, ZCB_MOTBX, R_E_C_N_O_, D_E_L_E_T_
							IF ZCB->(DBSEEK(xfilial("ZCB")+ZCA->ZCA_CODIGO))
								
								WHILE ZCB->(!EOF()) .AND. ZCB->ZCB_CODMOV == ZCA->ZCA_CODIGO
									
									IF ZCB->ZCB_TPOPER == ZCB_TPOPER_ESTORNO
										lAllEst	:= .T.
									ELSE
										lAllEst	:= .F.
										EXIT
									ENDIF
								
									ZCB->(DBSKIP()) 
								ENDDO
									
							ENDIF
							RESTAREA(aAreaZCB)	//| Restaura posição do ZCB |					
						ENDIF
						
						
						IF nDifSaldo == 0 .OR. lAllEst
							ZCA->ZCA_STATUS	:= ZCA_STATUS_PENDENTE
							ZCA->ZCA_SALDO	:= ZCA->ZCA_VBRUTO
						ELSE
							ZCA->ZCA_STATUS	:= ZCA_STATUS_PARCIAL
						ENDIF
					MSUNLOCK()
									

					
				
					END TRANSACTION
					
					aRet[1]	:= .T.
				ELSE
					aRet[2]	:= "Registro de Mov. Unificado não localizado ["+ZCB->ZCB_CODMOV+"]."
				ENDIF
			ELSE
				aRet[2]	:= "Registro para estorno não localizado."
			ENDIF
			
			RestArea(aAreaSE1)
		/*
		ELSE
			aRet[2]	:= "Motivo de baixa não informado para estorno da movimentação"
		ENDIF
		*/

	ELSEIF cAliRef == "SE5"

		DBSELECTAREA("SE5")
		SE5->(DBGOTO(nRecAli))

		cQuery := " SELECT ZCB.R_E_C_N_O_ AS ZCB_RECNO "+CRLF
		cQuery += " FROM "+RetSqlName("ZCB")+" ZCB "+CRLF
		cQuery += " WHERE ZCB_ALIAS = 'SE5' "+CRLF
		cQuery += " AND ZCB_RECALI = "+alltrim(str(nRecAli))+CRLF
		cQuery += " AND ZCB_TPOPER = '"+ZCB_TPOPER_MOV_BANCARIO+"' "+CRLF
		//cQuery += " AND ZCB_VLRMOV = "+alltrim(str(nVlrEst))+CRLF
		cQuery += " AND ZCB.D_E_L_E_T_ = '' "+CRLF

		If Select("TZCB") > 0
			TZCB->(DbCloseArea())
		EndIf

		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TZCB",.F., .T.)


		IF TZCB->(!EOF())

			DBSELECTAREA("ZCB")
			ZCB->(DBGOTO(TZCB->ZCB_RECNO))

			DBSELECTAREA("ZCA")
			ZCA->(DBSETORDER(1)) //| ZCA_FILIAL, ZCA_CODIGO, R_E_C_N_O_, D_E_L_E_T_
			IF ZCA->(DBSEEK(xfilial("ZCA")+ZCB->ZCB_CODMOV))

				BEGIN TRANSACTION

				/*------------------------------------------------------ Augusto Ribeiro | 30/10/2017 - 5:32:15 PM
					Estorna valor do movimento unificado
					Altera Status					
				------------------------------------------------------------------------------------------*/
				RECLOCK("ZCA",.F.)
					ZCA->ZCA_SALDO 	:= ZCA->ZCA_SALDO+ZCB->ZCB_VLRMOV
					IF ZCA->ZCA_SALDO == ZCA->ZCA_VLIQ //ZCA->ZCA_VBRUTO
						ZCA->ZCA_SALDO 	:= ZCA->ZCA_VBRUTO  
						ZCA->ZCA_STATUS	:= ZCA_STATUS_PENDENTE
					ELSE
						ZCA->ZCA_STATUS	:= ZCA_STATUS_PARCIAL
					ENDIF
				MSUNLOCK()
								
				/*------------------------------------------------------ Augusto Ribeiro | 30/10/2017 - 5:32:51 PM
					Estorna movimento na tabela de rastreabilidade.
				------------------------------------------------------------------------------------------*/
				RECLOCK("ZCB",.F.)
					ZCB->ZCB_TPOPER	:= ZCB_TPOPER_ESTORNO
					ZCB->ZCB_DTEST	:= DDATABASE
					ZCB->ZCB_HREST	:= TIME()			
				MSUNLOCK()
				
			
				END TRANSACTION
				
				aRet[1]	:= .T.
			ELSE
				aRet[2]	:= "Registro de Mov. Unificado não localizado ["+ZCB->ZCB_CODMOV+"]."
			ENDIF
		ELSE
			aRet[2]	:= "Registro para estorno não localizado."
		ENDIF
	
	ELSE
		aRet[2]	:= "Alias para estorno invalido ["+cAliRef+"]"
	ENDIF
ELSE
	aRet[2]	:= "Recno do registro vazio ["+alltrim(str(nRecAli))+"]"
ENDIF

RestArea(aArea)

Return(aRet)





/*/{Protheus.doc} CP11CIEL
Funcao responsável por transferir registros da tabela especifica ZC6 para tabela de moviment unificado ZAC
@author Augusto Ribeiro | www.compila.com.br
@since 18/10/2017
@version version
@param param
@return aRet {cStZCA, cMsgErro}
@example
(examples)
@see (links_or_references)
/*/
User Function CP11CIEL(cCodArq)
	Local aRet		:= {ZC4_STATUS_FALHA, ""}
	Local cMsgErro	:= ""
	Local cQuery	:= ""
	Local nCount	:= 0
	Local nTamConta	:= TAMSX3("ZCA_CONTA")[1]
	Local nTamBco	:= TAMSX3("ZCA_BANCO")[1]
	Local nTamAg	:= TAMSX3("ZCA_AGENC")[1]
	Local aMov, aExt, cAux, cSemaf, cCodBand, cForma, cDescAjust

	IF !EMPTY(cCodArq)

		DBSELECTAREA("ZC4")
		ZC4->(DBSETORDER(1)) //|
		IF ZC4->(DBSEEK(xfilial("ZC4")+cCodArq))

			IF ZC4->ZC4_STATUS == ZC4_STATUS_PENDENTE .OR.;
					ZC4->ZC4_STATUS == ZC4_STATUS_PARCIAL .OR.;
					ZC4->ZC4_STATUS == ZC4_STATUS_FALHA

				cTpArq		:= LEFT(ALLTRIM(ZC4->ZC4_TPARQ),2)

			/*------------------------------------------------------ Augusto Ribeiro | 27/10/2017 - 4:15:43 PM
				Complementa descrição do Arquivo
			------------------------------------------------------------------------------------------*/
				IF LEN(ALLTRIM(ZC4->ZC4_TPARQ)) == 2
				cDescTpArq	:= "DESCONHECIDO"
					IF cTpArq == "03"
					cDescTpArq	:= "VENDAS COM PLANO PARCELADO"
					ELSEIF cTpArq == "04"
					cDescTpArq	:= "PAGAMENTOS"
					ELSEIF cTpArq == "06"
					cDescTpArq	:= "ANTECIPACAO DE RECEBIVEIS"
					ELSEIF cTpArq == "07"
					cDescTpArq	:= "CESSAO DE RECEBIVEIS"
					ELSEIF cTpArq == "08"
					cDescTpArq	:= "PARCELAS PENDENTES"
					ELSEIF cTpArq == "09"
					cDescTpArq	:= "SALDO EM ABERTO"
					ENDIF
	
				RECLOCK("ZC4",.F.)
					ZC4->ZC4_TPARQ	:= ALLTRIM(ZC4->ZC4_TPARQ)+"-"+cDescTpArq
				MSUNLOCK()
				ENDIF
			
			/*------------------------------------------------------ Augusto Ribeiro | 27/10/2017 - 4:16:53 PM
				Somente processa arquivos de PAGAMENTOS
			------------------------------------------------------------------------------------------*/
				IF cTpArq <> "04" .AND. cTpArq <> "06"
				aRet[1]	:= ZC4_STATUS_DESCONSIDERADO
				//aRet[2]	:= "Tipo de arquivo irrelevante para baixa dos títulos." 
				aRet[2]	:= "Tipo de arquivo não corresponde a movimentação financeira realizada."
				ENDIF
			ELSE
			aRet[1]	:= ZC4->ZC4_STATUS
			aRet[2]	:= "Este registro não pode ser processado - Status do arquivo ["+X3COMBO("ZC4_STATUS",ZC4->ZC4_STATUS)+"]"
			ENDIF
			
			
			IF EMPTY(aRet[2])
	
			cQuery := " SELECT ZC61.ZC6_CODIGO,  "+CRLF
			cQuery += " 		 ZC61.ZC6_BANDEI,  "+CRLF
			cQuery += " 		 ZC61.ZC6_CODEST,  "+CRLF
			cQuery += " 		ZC62.ZC6_CODAUT, "+CRLF
			cQuery += " 		ZC61.ZC6_QTDPAR,  "+CRLF
			cQuery += " 		ZC61.ZC6_PARCEL, "+CRLF
			cQuery += " 		ZC62.ZC6_NUMCC, "+CRLF
			cQuery += " 		ZC62.ZC6_DTCAPT, "+CRLF
			cQuery += " 		ZC61.ZC6_DTMOV, "+CRLF
			cQuery += " 		ZC62.ZC6_VBRUTV, "+CRLF
			cQuery += " 		CASE WHEN ZC61.ZC6_VBRUTV <> ZC62.ZC6_VBRUTV THEN (ZC62.ZC6_VBRUTV*(ZC61.ZC6_PERTAX/100))*-1 ELSE ZC61.ZC6_VTAXAV END AS  ZC6_VTAXAV, "+CRLF
			cQuery += " 		CASE WHEN ZC61.ZC6_VBRUTV <> ZC62.ZC6_VBRUTV THEN ZC62.ZC6_VBRUTV-(ZC62.ZC6_VBRUTV*(ZC61.ZC6_PERTAX/100))  ELSE ZC61.ZC6_VLIQV END AS  ZC6_VLIQV, "+CRLF
			cQuery += " 		ZC61.ZC6_PERTAX, "+CRLF			
			cQuery += " 		ZC61.ZC6_BANCO, "+CRLF
			cQuery += " 		ZC61.ZC6_AGENC, "+CRLF
			cQuery += " 		ZC61.ZC6_CONTA,   "+CRLF
			cQuery += " 		ZC61.ZC6_CODPRO,   "+CRLF
			cQuery += " 		ZC61.ZC6_TPTRAN,   "+CRLF
			cQuery += " 		ZC61.ZC6_ORIAJU,   "+CRLF
			cQuery += " 		ZC61.R_E_C_N_O_ AS ZC61_RECNO, "+CRLF
			cQuery += " 		ZC62.R_E_C_N_O_ AS ZC62_RECNO "+CRLF		
			cQuery += " FROM "+RetSqlName("ZC6")+" ZC62 "+CRLF
			cQuery += " INNER JOIN "+RetSqlName("ZC6")+" ZC61 "+CRLF
			cQuery += " 	ON ZC61.ZC6_NUNIRO = ZC62.ZC6_NUNIRO "+CRLF
			cQuery += " 	AND ZC61.ZC6_CODARQ = ZC62.ZC6_CODARQ  "+CRLF
			cQuery += " 	AND ZC61.ZC6_STPGTO = '01' "+CRLF
			cQuery += " 	AND (ZC61.ZC6_NOPANT = '' OR  ZC61.ZC6_NOPANT = '000000000') "+CRLF
			cQuery += " 	AND ZC61.ZC6_TPRARQ = '1' "+CRLF
			cQuery += " 	AND ZC61.ZC6_STATUS = '1' "+CRLF
			//cQuery += " 	AND ZC61.ZC6_TPTRAN NOT IN ('03','04')"+CRLF
			cQuery += " 	AND ZC61.D_E_L_E_T_ = '' "+CRLF
			cQuery += " WHERE ZC62.ZC6_FILIAL = '' "+CRLF
			cQuery += " AND ZC62.ZC6_STATUS = '1' "+CRLF	
			cQuery += " AND ZC62.ZC6_CODARQ = '"+cCodArq+"' "+CRLF
			cQuery += " AND ZC62.ZC6_TPRARQ = '2' "+CRLF
			//cQuery += " AND ZC62.ZC6_TPTRAN NOT IN ('03','04') "+CRLF
			cQuery += " AND ZC62.D_E_L_E_T_ = '' "+CRLF		
			cQuery += " UNION ALL "+CRLF
			/*------------------------------------------------------ Augusto Ribeiro | 07/11/2017 - 6:55:36 PM
				Tratamento para planos CIELO E AJUSTES
			------------------------------------------------------------------------------------------*/
			cQuery += " SELECT ZC61.ZC6_CODIGO,   "+CRLF
			cQuery += " 		ZC61.ZC6_BANDEI,   "+CRLF
			cQuery += " 		ZC61.ZC6_CODEST,   "+CRLF
			cQuery += " 	ZC61.ZC6_CODAUT,  "+CRLF
			cQuery += " 	ZC61.ZC6_QTDPAR,   "+CRLF
			cQuery += " 	ZC61.ZC6_PARCEL,  "+CRLF
			cQuery += " 	ZC61.ZC6_NUMCC,  "+CRLF
			cQuery += " 	ZC61.ZC6_DTCAPT,  "+CRLF
			cQuery += " 	ZC61.ZC6_DTMOV,  "+CRLF
			cQuery += " 	ZC61.ZC6_VBRUTV,  "+CRLF
			cQuery += " 	ZC61.ZC6_VTAXAV, "+CRLF
			cQuery += " 	ZC61.ZC6_VLIQV, "+CRLF
			cQuery += " 	ZC61.ZC6_PERTAX, 			 "+CRLF
			cQuery += " 	ZC61.ZC6_BANCO,  "+CRLF
			cQuery += " 	ZC61.ZC6_AGENC,  "+CRLF
			cQuery += " 	ZC61.ZC6_CONTA,    "+CRLF
			cQuery += " 	ZC61.ZC6_CODPRO,    "+CRLF
			cQuery += " 	ZC61.ZC6_TPTRAN,   "+CRLF 
			cQuery += " 	ZC61.ZC6_ORIAJU,   "+CRLF
			cQuery += " 	ZC61.R_E_C_N_O_ AS ZC61_RECNO, "+CRLF
			cQuery += " 	0 AS ZC62_RECNO	 "+CRLF
			cQuery += " FROM "+RetSqlName("ZC6")+" ZC61 "+CRLF
			cQuery += " WHERE ZC61.ZC6_FILIAL = ''  "+CRLF
			cQuery += " AND ZC61.ZC6_STATUS = '1' 	 "+CRLF
			cQuery += " AND ZC61.ZC6_CODARQ = '"+cCodArq+"'  "+CRLF
			cQuery += " AND ZC61.ZC6_STPGTO = '01'  "+CRLF
			cQuery += " AND (ZC61.ZC6_NOPANT = '' OR  ZC61.ZC6_NOPANT = '000000000')  "+CRLF
			cQuery += " AND ZC61.ZC6_TPRARQ = '1'  "+CRLF
			cQuery += " AND ZC61.ZC6_TPTRAN IN ('03','04') "+CRLF
			cQuery += " AND ZC61.D_E_L_E_T_ = ''  "+CRLF
			cQuery += "  AND NOT EXISTS ( SELECT 1 AS 'A' "+CRLF
			cQuery += " 			FROM "+RetSqlName("ZC6")+" ZC62 "+CRLF
			cQuery += "  			WHERE ZC61.ZC6_NUNIRO = ZC62.ZC6_NUNIRO  "+CRLF
			cQuery += "  			AND ZC61.ZC6_CODARQ = ZC62.ZC6_CODARQ   "+CRLF
			cQuery += "  			AND ZC62.ZC6_TPRARQ = '2'  "+CRLF
			cQuery += "  			AND ZC62.ZC6_STATUS = '1'  "+CRLF
			cQuery += "  			AND ZC62.D_E_L_E_T_ = '' )  "+CRLF
			cQuery += " UNION ALL "+CRLF			
			/*------------------------------------------------------ Augusto Ribeiro | 26/12/2017 - 11:11:58 AM
				TRATAMENTO PARA ANTECIPAÇÕES
			------------------------------------------------------------------------------------------*/
			cQuery += " SELECT ZC66.ZC6_CODIGO,   "+CRLF
			cQuery += " 		ZC66.ZC6_BANDEI,   "+CRLF
			cQuery += " 		ZC66.ZC6_CODEST,   "+CRLF
			cQuery += " 	ZC62.ZC6_CODAUT,  "+CRLF
			cQuery += " 	ZC66.ZC6_QTDPAR,   "+CRLF
			cQuery += " 	ZC66.ZC6_PARCEL,  "+CRLF
			cQuery += " 	ZC62.ZC6_NUMCC,  "+CRLF
			cQuery += " 	ZC62.ZC6_DTCAPT,  "+CRLF
			cQuery += " 	ZC65.ZC6_DTMOV,  "+CRLF
			cQuery += " 	ZC62.ZC6_VBRUTV,  "+CRLF
			cQuery += " 	CASE WHEN ZC66.ZC6_VBRUTV <> ZC62.ZC6_VBRUTV THEN  (ROUND(ZC62.ZC6_VBRUTV *((100-((ZC66.ZC6_VLIQV*100)/ZC66.ZC6_VBRUTV))/100),2))*-1 ELSE (ZC66.ZC6_VBRUTV-ZC66.ZC6_VLIQV)*-1 END AS  ZC6_VTAXAV,  "+CRLF
			cQuery += " 	CASE WHEN ZC66.ZC6_VBRUTV <> ZC62.ZC6_VBRUTV THEN ZC62.ZC6_VBRUTV-ROUND(ZC62.ZC6_VBRUTV *((100-((ZC66.ZC6_VLIQV*100)/ZC66.ZC6_VBRUTV))/100),2)  ELSE ZC66.ZC6_VLIQV END AS  ZC6_VLIQV,  "+CRLF
			cQuery += " 	ROUND(100-((ZC66.ZC6_VLIQV*100)/ZC66.ZC6_VBRUTV),2) AS ZC6_PERTAX, "+CRLF
			cQuery += " 	ZC65.ZC6_BANCO,  "+CRLF
			cQuery += " 	ZC65.ZC6_AGENC,  "+CRLF
			cQuery += " 	ZC65.ZC6_CONTA,    "+CRLF
			cQuery += " 	ZC66.ZC6_CODPRO,    "+CRLF
			cQuery += " 	ZC66.ZC6_TPTRAN,    "+CRLF
			cQuery += " 	ZC66.ZC6_ORIAJU,    "+CRLF
			cQuery += " 	ZC66.R_E_C_N_O_ AS ZC66_RECNO,  "+CRLF
			cQuery += " 	ZC62.R_E_C_N_O_ AS ZC62_RECNO "+CRLF
			cQuery += " FROM "+RetSqlName("ZC6")+" ZC62  "+CRLF
			cQuery += " INNER JOIN "+RetSqlName("ZC6")+" ZC66  "+CRLF
			cQuery += " 	ON ZC66.ZC6_NUNIRO = ZC62.ZC6_NUNIRO  "+CRLF
			cQuery += " 	AND ZC66.ZC6_CODARQ = ZC62.ZC6_CODARQ   "+CRLF
			cQuery += " 	AND ZC66.ZC6_TPRARQ = '6'  "+CRLF
			cQuery += " 	AND ZC66.ZC6_STATUS = '1'  "+CRLF
			cQuery += " 	AND ZC66.D_E_L_E_T_ = ''  "+CRLF
			cQuery += " INNER JOIN "+RetSqlName("ZC6")+" ZC65 "+CRLF
			cQuery += " 	ON ZC65.ZC6_CODARQ = ZC66.ZC6_CODARQ   "+CRLF
			cQuery += " 	AND ZC65.ZC6_NOPANT  = ZC66.ZC6_NOPANT  "+CRLF
			cQuery += " 	AND ZC65.ZC6_TPRARQ = '5'  "+CRLF
			cQuery += " 	AND ZC65.ZC6_STATUS = '1'  "+CRLF
			cQuery += " 	AND ZC65.D_E_L_E_T_ = ''  "+CRLF
			cQuery += " AND ZC66.ZC6_LINARQ > ZC65.ZC6_LINARQ "+CRLF
			cQuery += " AND ZC66.ZC6_LINARQ < (SELECT ISNULL(MIN(ZC65A.ZC6_LINARQ),999999) "+CRLF
			cQuery += " 						FROM "+RetSqlName("ZC6")+" ZC65A "+CRLF 
			cQuery += " 						WHERE ZC65A.ZC6_CODARQ = ZC65.ZC6_CODARQ "+CRLF 
			cQuery += " 						AND ZC65A.ZC6_NOPANT  = ZC65.ZC6_NOPANT "+CRLF
			cQuery += " 						AND ZC65A.ZC6_TPRARQ = '5' "+CRLF 
			cQuery += " 						AND ZC65A.ZC6_CODIGO <>  ZC65.ZC6_CODIGO "+CRLF 
			cQuery += " 						AND ZC65A.ZC6_LINARQ > ZC65.ZC6_LINARQ "+CRLF
			cQuery += " 						AND ZC65A.D_E_L_E_T_ = ''  ) "+CRLF			
			cQuery += " WHERE ZC62.ZC6_FILIAL = ''  "+CRLF
			cQuery += " AND ZC62.ZC6_STATUS = '1' "+CRLF
			cQuery += " AND ZC62.ZC6_CODARQ = '"+cCodArq+"'  "+CRLF
			cQuery += " AND ZC62.ZC6_TPRARQ = '2'  "+CRLF
			cQuery += " AND ZC62.D_E_L_E_T_ = '' "+CRLF
			
			
			
				If Select("TSQL") > 0
				TSQL->(DbCloseArea())
				EndIf
			
			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						

				IF TSQL->(!EOF())
				
				cSemaf	:= NOME_SEMAFORO+ZC4->ZC4_CODIGO
			
				/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
					Abre semaforo de Processamento
				------------------------------------------------------------------------------------------*/
				nHSemafaro	:= U_CPXSEMAF("A", cSemaf)
				
					IF nHSemafaro > 0
					cMsgErro	:= ""
						WHILE TSQL->(!EOF())
						//IncProc("Processando Arq. Cielo ["+ZC4->ZC4_CODIGO+"]...")
						
						aMov	:= {}	
						aExt	:= {}
						cDescAjust	:= ""
						
						cCodBand	:= U_CP113DEP(DEPARA_BANDEIRA,ADQ_CIELO,TSQL->ZC6_BANDEI)
						cForma		:= U_CP113DEP(DEPARA_DEBITO_CREDITO,ADQ_CIELO,TSQL->ZC6_CODPRO)
							IF !EMPTY(TSQL->ZC6_ORIAJU)
							cDescAjust	:= U_CP113DEP(DEPARA_ORIGEM_AJUSTE,ADQ_CIELO,TSQL->ZC6_ORIAJU)
							ENDIF
							IF !EMPTY(cCodBand)

							aadd(aMov, {"ZCA_CODADQ", ADQ_CIELO })
							aadd(aMov, {"ZCA_CODBAN", cCodBand })
								IF !EMPTY(cForma)
								aadd(aMov, {"ZCA_FORMA", cForma })
								endif
							aadd(aMov, {"ZCA_CODAUT", TSQL->ZC6_CODAUT })
							aadd(aMov, {"ZCA_QTDPAR", val(TSQL->ZC6_QTDPAR) })
							aadd(aMov, {"ZCA_NUMPAC", val(TSQL->ZC6_PARCEL) })
							aadd(aMov, {"ZCA_CARMAS", TSQL->ZC6_NUMCC })
							aadd(aMov, {"ZCA_DTVEND", TSQL->ZC6_DTCAPT })
							aadd(aMov, {"ZCA_DTPAG", TSQL->ZC6_DTMOV })
								IF TSQL->ZC6_TPTRAN == "04"//| Plano Cielo |
								aadd(aMov, {"ZCA_TPMOV", ZCA_TPMOV_TAXA })
								ELSEIF TSQL->ZC6_TPTRAN == "03"//| Ajuste a Debito |
								aadd(aMov, {"ZCA_TPMOV", ZCA_TPMOV_ESTORNO }) 
								ELSE
								aadd(aMov, {"ZCA_TPMOV", ZCA_TPMOV_PAGAMENTO }) 
								ENDIF
								IF !EMPTY(cDescAjust)
								aadd(aMov, {"ZCA_OBS",  cDescAjust})
								ENDIF
							aadd(aMov, {"ZCA_VBRUTO", TSQL->ZC6_VBRUTV })
							aadd(aMov, {"ZCA_VTAXA", TSQL->ZC6_VTAXAV })
							aadd(aMov, {"ZCA_PTAXA", TSQL->ZC6_PERTAX })
							aadd(aMov, {"ZCA_VLIQ", TSQL->ZC6_VLIQV })
							aadd(aMov, {"ZCA_BANCO", RIGHT(ALLTRIM(TSQL->ZC6_BANCO),nTamBco) })
							aadd(aMov, {"ZCA_AGENC", RIGHT(ALLTRIM(TSQL->ZC6_AGENC),nTamAg) })
							aadd(aMov, {"ZCA_CONTA", PADL(ALLTRIM(TSQL->ZC6_CONTA),nTamConta, "0") })
							aadd(aMov, {"ZCA_CODEST", TSQL->ZC6_CODEST })							
							
							AADD(aExt, TSQL->ZC61_RECNO)
								IF !EMPTY(TSQL->ZC62_RECNO)
								AADD(aExt, TSQL->ZC62_RECNO)
								ENDIF
							
							aRetAux	:= U_CP1110IN(aMov, "ZC6", aExt)
							
								IF !(aRetAux[1])
								cMsgErro	+= aRetAux[2]+CRLF					
								ENDIF
							
							ELSE
							cMsgErro += "[DEPARA] Bandeira nao localizada ["+TSQL->ZC6_BANDEI+"] ZC6["+TSQL->ZC6_CODIGO+"]"+CRLF
							ENDIF
					
						TSQL->(DBSKIP()) 
						ENDDO
					
						IF EMPTY(cMsgErro)
						aRet[1]	:= ZC4_STATUS_PROCESSADO
						aRet[2]	:= ""					
						ELSE
						aRet[1]	:= ZC4_STATUS_PARCIAL
						aRet[2]	:= cMsgErro					
						ENDIF
					
					
					/*--------------------------
					FECHA SEMAFORO
					---------------------------*/
					U_CPXSEMAF("F", cSemaf,nHSemafaro)				
					ELSE
					aRet[1]	:= ZC4_STATUS_FALHA
					aRet[2]	:= "Não foi possivel abrir o semaforo["+cSemaf+"]"
					ENDIF
				ELSE
				aRet[1]	:= ZC4_STATUS_PROCESSADO
				aRet[2]	:= "Nao existem dados a serem processados"				
				ENDIF
			ENDIF
		ELSE
		aRet[1]	:= ZC4_STATUS_FALHA
		aRet[2]	:= "Arquivo não localizado"
		ENDIF
	ELSE
	aRet[1]	:= ZC4_STATUS_FALHA
	aRet[2]	:= "Parametros inválidos [CP11CIEL]"
	ENDIF

/*
	IF EMPTY(cMsgErro)
	aRet[1]	:= .T. 
	ELSE
	aRet[2]	:= cMsgErro	
	ENDIF
*/

Return(aRet)


/*/{Protheus.doc} CP11BIN
Funcao responsável por transferir registros da tabela especifica ZC5 para tabela de moviment unificado ZAC
@author Fabio Sales | www.compila.com.br
@since 21/10/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function CP11BIN(cCodArq)
	Local aRet		:= {ZC4_STATUS_FALHA, ""}
	Local cMsgErro	:= ""
	Local cQuery	:= ""
	Local nCount	:= 0
	Local nTamConta	:= TAMSX3("ZCA_CONTA")[1]
	Local nTamBco	:= TAMSX3("ZCA_BANCO")[1]
	Local nTamAg	:= TAMSX3("ZCA_AGENC")[1]
	Local aMov, aExt, cAux, cSemaf, cTipoMov

	IF !EMPTY(cCodArq)

		DBSELECTAREA("ZC4")
		ZC4->(DBSETORDER(1)) //|
		IF ZC4->(DBSEEK(xfilial("ZC4")+cCodArq))

			IF ZC4->ZC4_STATUS == ZC4_STATUS_PENDENTE .OR.;
					ZC4->ZC4_STATUS == ZC4_STATUS_PARCIAL .OR.;
					ZC4->ZC4_STATUS == ZC4_STATUS_FALHA


				IF ALLTRIM(ZC4->ZC4_TPARQ) == "MOVIMENTACAO FINANCEIRA"




					//| Query para filtrar as vendas a crédito Não parcelados.

					cQuery := " SELECT
					cQuery += " 		ZC526.ZC5_CODARQ  "+CRLF
					cQuery += " 		,ZC524.ZC5_CODBAN  "+CRLF
					cQuery += " 		,ZC524.ZC5_CODEST  "+CRLF
					cQuery += " 		,'C' AS TIP_OP     "+CRLF
					cQuery += " 		,ZC526.ZC5_CODAUT  "+CRLF
					cQuery += " 		,ZC526.ZC5_QTPARC  "+CRLF
					cQuery += " 		,ZC526.ZC5_PARCEL  "+CRLF
					cQuery += " 		,ZC526.ZC5_NUMCC  "+CRLF
					cQuery += " 		,ZC524.ZC5_DTCAPT  "+CRLF
					cQuery += " 		,ZC526.ZC5_DTMOV  "+CRLF
					cQuery += " 		,ZC526.ZC5_STPGTO  "+CRLF
					cQuery += " 		,ROUND(ZC526.ZC5_VTAXAD / CAST(ZC526.ZC5_QTPARC AS INT),2) ZC5_VTAXAD "+CRLF
					cQuery += " 		,ROUND(ZC526.ZC5_VBRUT  / CAST(ZC526.ZC5_QTPARC AS INT),2) ZC5_VBRUT "+CRLF
					cQuery += " 		,ZC526.ZC5_VLIQ "+CRLF
					cQuery += " 		,ZC524.ZC5_BANCO "+CRLF
					cQuery += " 		,ZC524.ZC5_AGENC "+CRLF
					cQuery += " 		,ZC524.ZC5_CONTA "+CRLF
					cQuery += " 		,ZC524.ZC5_TPRARQ "+CRLF
					cQuery += " 		,'' AS ZC5_CODAJU "+CRLF
					cQuery += " 		,'' AS ZC5_DESAJU "+CRLF
					cQuery += " 		,ZC524.R_E_C_N_O_ AS ZC5CAB_RECNO "+CRLF
					cQuery += " 		,ZC526.R_E_C_N_O_ AS ZC5ITE_RECNO "+CRLF
					cQuery += " FROM "+RetSqlName("ZC5")+" ZC524 WITH(NOLOCK) "+CRLF
					cQuery += " INNER JOIN "+RetSqlName("ZC5")+" ZC526 WITH(NOLOCK) "+CRLF
					cQuery += " 		ON ZC524.ZC5_FILIAL=ZC526.ZC5_FILIAL "+CRLF
					cQuery += " 		AND ZC524.ZC5_CODARQ=ZC526.ZC5_CODARQ "+CRLF
					cQuery += " 		AND ZC524.ZC5_NUMRES=ZC526.ZC5_NUMRES  "+CRLF
					cQuery += " 		AND ZC526.ZC5_TPRARQ ='026' "+CRLF
					cQuery += " 		AND ZC526.ZC5_STATUS = '1' "+CRLF
					cQuery += " 		AND ZC526.D_E_L_E_T_ = '' "+CRLF
					cQuery += " WHERE ZC524.ZC5_TPRARQ ='024' "+CRLF
					cQuery += " 		AND ZC524.ZC5_CODARQ = '"+cCodArq+"' "+CRLF
					cQuery += " 		AND ZC524.ZC5_STPGTO ='0' "+CRLF
					cQuery += " 		AND ZC524.ZC5_STATUS = '1' "+CRLF
					cQuery += " 		AND ZC524.D_E_L_E_T_ = '' "+CRLF

					cQuery += " UNION ALL "+CRLF

					//| Query para filtrar as vendas a crédito Parcelados


					cQuery += " SELECT "+CRLF
					cQuery += " 		ZC523.ZC5_CODARQ  "+CRLF
					cQuery += " 		,ZC522.ZC5_CODBAN  "+CRLF
					cQuery += " 		,ZC522.ZC5_CODEST  "+CRLF
					cQuery += " 		,'C' AS TIP_OP  "+CRLF
					cQuery += " 		,ZC523.ZC5_CODAUT  "+CRLF
					cQuery += " 		,ZC523.ZC5_QTPARC  "+CRLF
					cQuery += " 		,ZC523.ZC5_PARCEL  "+CRLF
					cQuery += " 		,ZC523.ZC5_NUMCC  "+CRLF
					cQuery += " 		,ZC522.ZC5_DTCAPT  "+CRLF
					cQuery += " 		,ZC523.ZC5_DTMOV  "+CRLF
					cQuery += " 		,ZC523.ZC5_STPGTO  "+CRLF
					cQuery += " 		,ZC523.ZC5_VTAXAD  "+CRLF
					cQuery += " 		,ZC523.ZC5_VBRUT    "+CRLF
					cQuery += " 		,ZC523.ZC5_VLIQ  "+CRLF
					cQuery += " 		,ZC522.ZC5_BANCO  "+CRLF
					cQuery += " 		,ZC522.ZC5_AGENC "+CRLF
					cQuery += " 		,ZC522.ZC5_CONTA "+CRLF
					cQuery += " 		,ZC522.ZC5_TPRARQ "+CRLF
					cQuery += " 		,'' AS ZC5_CODAJU "+CRLF
					cQuery += " 		,'' AS ZC5_DESAJU "+CRLF
					cQuery += " 		,ZC522.R_E_C_N_O_ AS ZC5CAB_RECNO "+CRLF
					cQuery += " 		,ZC523.R_E_C_N_O_ AS ZC5ITE_RECNO "+CRLF
					cQuery += " FROM "+RetSqlName("ZC5")+" ZC522 WITH(NOLOCK) "+CRLF
					cQuery += " INNER JOIN "+RetSqlName("ZC5")+" ZC523 WITH(NOLOCK) "+CRLF
					cQuery += " 		ON ZC522.ZC5_FILIAL=ZC523.ZC5_FILIAL "+CRLF
					cQuery += " 		AND ZC522.ZC5_CODARQ=ZC523.ZC5_CODARQ "+CRLF
					cQuery += " 		AND ZC522.ZC5_NUMRES=ZC523.ZC5_NUMRES  "+CRLF
					cQuery += " 		AND ZC523.ZC5_TPRARQ ='023' "+CRLF
					cQuery += " 		AND ZC523.ZC5_STATUS = '1' "+CRLF
					cQuery += " 		AND ZC523.D_E_L_E_T_ = '' "+CRLF
					cQuery += " WHERE ZC522.ZC5_TPRARQ ='022' "+CRLF
					cQuery += " 		AND ZC522.ZC5_CODARQ = '"+cCodArq+"' "+CRLF
					cQuery += " 		AND ZC522.ZC5_STPGTO ='0' "+CRLF
					cQuery += " 		AND ZC522.ZC5_STATUS = '1' "+CRLF
					cQuery += " 		AND ZC522.D_E_L_E_T_ = '' "+CRLF

					cQuery += " UNION ALL "+CRLF

					//| Transações realizadas a débito.

					cQuery += " SELECT "+CRLF
					cQuery += " 		ZC521.ZC5_CODARQ  "+CRLF
					cQuery += " 		,ZC520.ZC5_CODBAN  "+CRLF
					cQuery += " 		,ZC520.ZC5_CODEST  "+CRLF
					cQuery += " 		,'D' AS TIP_OP  "+CRLF
					cQuery += " 		,ZC521.ZC5_CODAUT  "+CRLF
					cQuery += " 		,ZC521.ZC5_QTPARC  "+CRLF
					cQuery += " 		,ZC521.ZC5_PARCEL  "+CRLF
					cQuery += " 		,ZC521.ZC5_NUMCC  "+CRLF
					cQuery += " 		,ZC520.ZC5_DTCAPT  "+CRLF
					cQuery += " 		,ZC521.ZC5_DTMOV  "+CRLF
					cQuery += " 		,ZC521.ZC5_STPGTO  "+CRLF
					cQuery += " 		,ZC521.ZC5_VTAXAD  "+CRLF
					cQuery += " 		,ZC521.ZC5_VBRUT    "+CRLF
					cQuery += " 		,ZC521.ZC5_VLIQ  "+CRLF
					cQuery += " 		,ZC520.ZC5_BANCO  "+CRLF
					cQuery += " 		,ZC520.ZC5_AGENC "+CRLF
					cQuery += " 		,ZC520.ZC5_CONTA "+CRLF
					cQuery += " 		,ZC520.ZC5_TPRARQ "+CRLF
					cQuery += " 		,'' AS ZC5_CODAJU "+CRLF
					cQuery += " 		,'' AS ZC5_DESAJU "+CRLF
					cQuery += " 		,ZC520.R_E_C_N_O_ AS ZC5CAB_RECNO "+CRLF
					cQuery += " 		,ZC521.R_E_C_N_O_ AS ZC5ITE_RECNO "+CRLF
					cQuery += " FROM "+RetSqlName("ZC5")+" ZC520 WITH(NOLOCK) "+CRLF
					cQuery += " INNER JOIN "+RetSqlName("ZC5")+" ZC521 WITH(NOLOCK) "+CRLF
					cQuery += " 		ON ZC520.ZC5_FILIAL=ZC521.ZC5_FILIAL "+CRLF
					cQuery += " 		AND ZC520.ZC5_CODARQ=ZC521.ZC5_CODARQ "+CRLF
					cQuery += " 		AND ZC520.ZC5_NUMRES=ZC521.ZC5_NUMRES  "+CRLF
					cQuery += " 		AND ZC521.ZC5_TPRARQ ='021' "+CRLF
					cQuery += " 		AND ZC521.ZC5_STATUS = '1' "+CRLF
					cQuery += " 		AND ZC521.D_E_L_E_T_ = '' "+CRLF
					cQuery += " WHERE ZC520.ZC5_TPRARQ ='020' "+CRLF
					cQuery += " 		AND ZC520.ZC5_CODARQ = '"+cCodArq+"' "+CRLF
					cQuery += " 		AND ZC520.ZC5_STPGTO ='0' "+CRLF
					cQuery += " 		AND ZC520.ZC5_STATUS = '1' "+CRLF
					cQuery += " 		AND ZC520.D_E_L_E_T_ = '' "+CRLF

					cQuery += " UNION ALL "+CRLF

				/*------------------------------------------------------ Augusto Ribeiro | 11/01/2018 - 6:03:59 PM
					Tratamento para registros de ajuste como Taxa da Maquineta
				------------------------------------------------------------------------------------------*/				
								
				cQuery += " SELECT ZC530.ZC5_CODARQ   "+CRLF
				cQuery += " ,ZC530.ZC5_CODBAN   "+CRLF
				cQuery += " ,ZC530.ZC5_CODEST   "+CRLF
				cQuery += " ,ZC530.ZC5_TIPOP AS TIP_OP  				 "+CRLF
				cQuery += " ,ZC530.ZC5_CODAUT   "+CRLF
				cQuery += " ,ZC530.ZC5_QTPARC   "+CRLF
				cQuery += " ,ZC530.ZC5_PARCEL   "+CRLF
				cQuery += " ,ZC530.ZC5_NUMCC   "+CRLF
				cQuery += " ,ZC530.ZC5_DTCAPT   "+CRLF
				cQuery += " ,ZC530.ZC5_DTMOV   "+CRLF
				cQuery += " ,'0' AS ZC5_STPGTO   "+CRLF
				cQuery += " ,ZC530.ZC5_VTAXAD   "+CRLF
				cQuery += " ,CASE WHEN ZC530.ZC5_TIPOP = 'D' THEN ZC530.ZC5_VBRUT*-1 ELSE ZC530.ZC5_VBRUT END AS ZC5_VBRUT "+CRLF
				cQuery += " ,CASE WHEN ZC530.ZC5_TIPOP = 'D' THEN ZC530.ZC5_VLIQ*-1 ELSE ZC530.ZC5_VLIQ END AS ZC5_VLIQ "+CRLF
				cQuery += " ,CASE WHEN ZC530.ZC5_BANCO = '' THEN (SELECT ZC5_BANCO "+CRLF
				cQuery += " 										FROM "+RetSqlName("ZC5")+" ZC5 "+CRLF
				cQuery += " 										INNER JOIN (SELECT MAX(A.ZC5_CODIGO) AS ZC5_CODIGO "+CRLF
				cQuery += " 													FROM "+RetSqlName("ZC5")+" A "+CRLF
				cQuery += " 													WHERE A.ZC5_CODEST = ZC530.ZC5_CODEST "+CRLF
				cQuery += " 													AND A.ZC5_BANCO <> '' "+CRLF
				cQuery += " 													AND A.D_E_L_E_T_ = '') B "+CRLF
				cQuery += " 										ON ZC5.ZC5_CODIGO = B.ZC5_CODIGO "+CRLF
				cQuery += " 										)  "+CRLF
				cQuery += " 								ELSE ZC530.ZC5_BANCO END ZC5_BANCO "+CRLF
				cQuery += " ,CASE WHEN ZC530.ZC5_BANCO = '' THEN (SELECT ZC5_AGENC "+CRLF
				cQuery += " 										FROM "+RetSqlName("ZC5")+" ZC5 "+CRLF
				cQuery += " 										INNER JOIN (SELECT MAX(A.ZC5_CODIGO) AS ZC5_CODIGO "+CRLF
				cQuery += " 													FROM "+RetSqlName("ZC5")+" A "+CRLF
				cQuery += " 													WHERE A.ZC5_CODEST = ZC530.ZC5_CODEST "+CRLF
				cQuery += " 													AND A.ZC5_BANCO <> '' "+CRLF
				cQuery += " 													AND A.D_E_L_E_T_ = '') B "+CRLF
				cQuery += " 										ON ZC5.ZC5_CODIGO = B.ZC5_CODIGO "+CRLF
				cQuery += " 										)  "+CRLF
				cQuery += " 								ELSE ZC530.ZC5_AGENC END ZC5_AGENC "+CRLF
				cQuery += " ,CASE WHEN ZC530.ZC5_BANCO = '' THEN (SELECT ZC5_CONTA "+CRLF
				cQuery += " 										FROM "+RetSqlName("ZC5")+" ZC5 "+CRLF
				cQuery += " 										INNER JOIN (SELECT MAX(A.ZC5_CODIGO) AS ZC5_CODIGO "+CRLF
				cQuery += " 													FROM "+RetSqlName("ZC5")+" A "+CRLF
				cQuery += " 													WHERE A.ZC5_CODEST = ZC530.ZC5_CODEST "+CRLF
				cQuery += " 													AND A.ZC5_BANCO <> '' "+CRLF
				cQuery += " 													AND A.D_E_L_E_T_ = '') B "+CRLF
				cQuery += " 										ON ZC5.ZC5_CODIGO = B.ZC5_CODIGO "+CRLF
				cQuery += " 										)  "+CRLF
				cQuery += " 								ELSE ZC530.ZC5_CONTA END ZC5_CONTA "+CRLF
				cQuery += " ,ZC530.ZC5_TPRARQ "+CRLF
				cQuery += " ,ZC530.ZC5_CODAJU "+CRLF
				cQuery += " ,ZC530.ZC5_DESAJU "+CRLF
				cQuery += " ,ZC530.R_E_C_N_O_ AS ZC5CAB_RECNO  "+CRLF
				cQuery += " ,0 AS ZC5ITE_RECNO  "+CRLF
				cQuery += " FROM "+RetSqlName("ZC5")+" ZC530 "+CRLF
				cQuery += " WHERE ZC530.ZC5_FILIAL = '' "+CRLF
				cQuery += " AND ZC530.ZC5_CODARQ = '"+cCodArq+"' "+CRLF
				cQuery += " AND ZC530.ZC5_TPRARQ = '030' "+CRLF
				cQuery += " AND ZC530.ZC5_STATUS = '1' "+CRLF	
				cQuery += " AND ZC530.D_E_L_E_T_ = '' "+CRLF				
					
				//MemoWrite(GetTempPath(.T.) + "CP11000_CP11BIN.SQL", cQuery)
				
					If Select("TSQL") > 0
					TSQL->(DbCloseArea())
					EndIf
				
				DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						
				
				/*
				TSQL->(DBGoTop())	
				TSQL->( dbEval( {|| nCount++ } ) )	
				TSQL->(DBGoTop())
				
				ProcRegua(nCount)
				*/
					IF TSQL->(!EOF())

						cSemaf	:= NOME_SEMAFORO+ZC4->ZC4_CODIGO

					/*------------------------------------------------------ Fabio Sales | 21/10/2017 - 7:01:42 PM
						Abre semaforo de Processamento
					------------------------------------------------------------------------------------------*/
					nHSemafaro	:= U_CPXSEMAF("A", cSemaf)
					
						IF nHSemafaro > 0
						
							WHILE TSQL->(!EOF())
							//IncProc("Processando Arq. BIN ["+ZC4->ZC4_CODIGO+"]...")
							
							aMov		:= {}	
							aExt		:= {}
							
							cTipoMov	:= ZCA_TPMOV_PAGAMENTO
								IF TSQL->ZC5_TPRARQ == "030"
								cTipoMov	:= ZCA_TPMOV_TAXA
								ENDIF
							
							cCodBand	:= U_CP113DEP(DEPARA_BANDEIRA,ADQ_BIN,TSQL->ZC5_CODBAN)
								IF !EMPTY(cCodBand) .OR. cTipoMov == ZCA_TPMOV_TAXA
								
								aadd(aMov, {"ZCA_CODADQ", ADQ_BIN })
								aadd(aMov, {"ZCA_CODBAN", cCodBand })
								aadd(aMov, {"ZCA_FORMA", TSQL->TIP_OP })
								aadd(aMov, {"ZCA_CODAUT", TSQL->ZC5_CODAUT })
								aadd(aMov, {"ZCA_QTDPAR", val(TSQL->ZC5_QTPARC) })
								aadd(aMov, {"ZCA_NUMPAC", val(TSQL->ZC5_PARCEL) })
								aadd(aMov, {"ZCA_CARMAS", TSQL->ZC5_NUMCC })
								aadd(aMov, {"ZCA_DTVEND", TSQL->ZC5_DTCAPT })
								aadd(aMov, {"ZCA_DTPAG",  TSQL->ZC5_DTMOV })
								aadd(aMov, {"ZCA_TPMOV", cTipoMov})
								aadd(aMov, {"ZCA_VBRUTO", TSQL->ZC5_VBRUT })
								aadd(aMov, {"ZCA_VTAXA",  TSQL->ZC5_VTAXAD * -1 })
								aadd(aMov, {"ZCA_PTAXA",  (TSQL->ZC5_VTAXAD*100)/TSQL->ZC5_VBRUT })
								aadd(aMov, {"ZCA_VLIQ",   TSQL->ZC5_VLIQ })							
								aadd(aMov, {"ZCA_BANCO", RIGHT(ALLTRIM(TSQL->ZC5_BANCO),nTamBco) })
								aadd(aMov, {"ZCA_AGENC", RIGHT(ALLTRIM(TSQL->ZC5_AGENC),nTamAg) })														
								aadd(aMov, {"ZCA_CONTA", PADL(ALLTRIM(TSQL->ZC5_CONTA),nTamConta, "0") })
								aadd(aMov, {"ZCA_CODEST", TSQL->ZC5_CODEST })	
								aadd(aMov, {"ZCA_OBS",  TSQL->ZC5_DESAJU})
								
								AADD(aExt, TSQL->ZC5CAB_RECNO)
									IF !EMPTY(TSQL->ZC5ITE_RECNO)
									AADD(aExt, TSQL->ZC5ITE_RECNO)
									ENDIF
		
								aRetAux	:= U_CP1110IN(aMov, "ZC5", aExt)
								
									IF !(aRetAux[1])
									cMsgErro	+= aRetAux[2]+CRLF					
									ENDIF
								
								ELSE
								cMsgErro += "[DEPARA] Bandeira nao localizada ["+TSQL->ZC5_CODBAN+"]"
								ENDIF
						
							TSQL->(DBSKIP()) 
							ENDDO
						
						
							IF EMPTY(cMsgErro)
							aRet[1]	:= ZC4_STATUS_PROCESSADO
							aRet[2]	:= ""					
							ELSE
							aRet[1]	:= ZC4_STATUS_PARCIAL
							aRet[2]	:= cMsgErro					
							ENDIF
						
						
						/*--------------------------
						FECHA SEMAFORO
						---------------------------*/
						U_CPXSEMAF("F", cSemaf,nHSemafaro)				
						ELSE
						aRet[1]	:= ZC4_STATUS_FALHA
						aRet[2]	:= "Não foi possivel abrir o semaforo["+cSemaf+"]"
						ENDIF
					ELSE
					aRet[1]	:= ZC4_STATUS_PROCESSADO
					aRet[2]	:= "Nao existem dados a serem processados"		
					ENDIF
				ELSE
				aRet[1]	:= ZC4_STATUS_DESCONSIDERADO
				aRet[2]	:= "Tipo de arquivo não corresponde a movimentação financeira realizada."			
				ENDIF
			ELSE
			aRet[1]	:= ZC4->ZC4_STATUS
			aRet[2]	:= "Este registro não pode ser processado - Status do arquivo ["+X3COMBO("ZC4_STATUS",ZC4->ZC4_STATUS)+"]"
			ENDIF
		ELSE
		aRet[1]	:= ZC4_STATUS_FALHA
		aRet[2]	:= "Arquivo não localizado"
		ENDIF
	ELSE
	aRet[1]	:= ZC4_STATUS_FALHA
	aRet[2]	:= "Parametros inválidos [CP11BIN]"	
	ENDIF

Return(aRet)







/*/{Protheus.doc} CP11GETN
Funcao responsável por transferir registros da tabela especifica ZC7 para tabela de moviment unificado ZAC
@author Fabio Sales | www.compila.com.br
@since 02/11/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function CP11GETN(cCodArq)
	Local aRet		:= {ZC4_STATUS_FALHA, ""}
	Local cMsgErro	:= ""
	Local cQuery	:= ""
	Local nCount	:= 0
	Local nTamConta	:= TAMSX3("ZCA_CONTA")[1]
	Local nTamBco	:= TAMSX3("ZCA_BANCO")[1]
	Local nTamAg	:= TAMSX3("ZCA_AGENC")[1]
	Local aMov, aExt, cAux, cSemaf,cForma

	IF !EMPTY(cCodArq)

		DBSELECTAREA("ZC4")
		ZC4->(DBSETORDER(1)) //|
		IF ZC4->(DBSEEK(xfilial("ZC4")+cCodArq))

			IF ZC4->ZC4_STATUS == ZC4_STATUS_PENDENTE .OR.;
					ZC4->ZC4_STATUS == ZC4_STATUS_PARCIAL .OR.;
					ZC4->ZC4_STATUS == ZC4_STATUS_FALHA


				IF ALLTRIM(ZC4->ZC4_TPARQ) == "CEADM100"

					cQuery :="  SELECT " +CRLF
					cQuery +=" 		ZC71.ZC7_CODARQ  " +CRLF
					cQuery +=" 		,ZC71.ZC7_BANDEI " +CRLF
					cQuery +=" 		,ZC71.ZC7_NUMEST " +CRLF
					cQuery +=" 		,ZC72.ZC7_CODAUT " +CRLF
					cQuery +=" 		,ZC72.ZC7_QTDPAR " +CRLF
					cQuery +=" 		,ZC72.ZC7_PARCEL " +CRLF
					cQuery +=" 		,ZC72.ZC7_NUMCC  " +CRLF
					cQuery +=" 		,ZC72.ZC7_DTCAPT " +CRLF
					cQuery +=" 		,ZC72.ZC7_DTMOV  " +CRLF
					cQuery +=" 		,ZC71.ZC7_VTAXAD " +CRLF
					cQuery +=" 		,CASE WHEN  ZC71.ZC7_VTAXAD > 0 AND ZC71.ZC7_VBRUT > 0  THEN ROUND(ZC71.ZC7_VTAXAD / ZC71.ZC7_VBRUT * ZC72.ZC7_VLIQ,2) ELSE 0 END AS TAXA " +CRLF
					cQuery +=" 		,CASE WHEN ZC71.ZC7_VLIQ > 0 AND ZC71.ZC7_VBRUT > 0 THEN ROUND(ZC71.ZC7_VLIQ/ZC71.ZC7_VBRUT * ZC72.ZC7_VLIQ,2) ELSE 0 END AS ZC7_VLIQ " +CRLF
					cQuery +=" 		,ZC72.ZC7_VBRUT " +CRLF
					cQuery +=" 		,ZC71.ZC7_BANCO " +CRLF
					cQuery +=" 		,ZC71.ZC7_AGENC " +CRLF
					cQuery +=" 		,ZC71.ZC7_CONTA " +CRLF
					cQuery +=" 		,ZC72.ZC7_MOTAJU " +CRLF
					cQuery +=" 		,ZC71.R_E_C_N_O_ AS ZC7_CABEC " +CRLF
					cQuery +=" 		,ZC72.R_E_C_N_O_ AS ZC7_ITEM " +CRLF
					cQuery +="  FROM "+RetSqlName("ZC7")+" ZC71 WITH(NOLOCK) " +CRLF
					cQuery +=" INNER JOIN "+RetSqlName("ZC7")+" ZC72 WITH(NOLOCK) " +CRLF
					cQuery +="		ON ZC71.ZC7_FILIAL =ZC72.ZC7_FILIAL " +CRLF
					cQuery += " 	AND ZC71.ZC7_CODARQ=ZC72.ZC7_CODARQ "+CRLF
					cQuery +="		AND ZC71.ZC7_NUMEST=ZC72.ZC7_NUMEST " +CRLF
					cQuery +="		AND ZC71.ZC7_NUMRV =ZC72.ZC7_NUMRV  " +CRLF
					cQuery +="		AND ZC71.ZC7_QTDPAR=ZC72.ZC7_QTDPAR " +CRLF
					cQuery +="		AND ZC71.ZC7_PARCEL=ZC72.ZC7_PARCEL " +CRLF
					cQuery +="		AND ZC72.D_E_L_E_T_='' " +CRLF
					cQuery +="		AND ZC72.ZC7_TPRARQ='2' " +CRLF
					cQuery += " 	AND ZC72.ZC7_STATUS = '1' "+CRLF
					cQuery +=" WHERE ZC71.ZC7_TPRARQ='1' " +CRLF
					cQuery += " 	AND ZC71.ZC7_CODARQ = '"+cCodArq+"' "+CRLF
					cQuery +=" 	    AND ZC71.ZC7_INDPG ='PG' "+CRLF
					cQuery +=" 		AND ZC71.D_E_L_E_T_='' " +CRLF
					cQuery += " 		AND ZC71.ZC7_STATUS = '1' "+CRLF
					//cQuery +=" 		AND ZC71.ZC7_BANDEI ='ED' "

					cQuery +=" 		UNION ALL  " +CRLF

					cQuery +="  SELECT " +CRLF
					cQuery +=" 		ZC71.ZC7_CODARQ  " +CRLF
					cQuery +=" 		,ZC71.ZC7_BANDEI " +CRLF
					cQuery +=" 		,ZC71.ZC7_NUMEST " +CRLF
					cQuery +=" 		,ZC73.ZC7_CODAUT " +CRLF
					cQuery +=" 		,ZC73.ZC7_QTDPAR " +CRLF
					cQuery +=" 		,ZC73.ZC7_PARCEL " +CRLF
					cQuery +=" 		,ZC73.ZC7_NUMCC  " +CRLF
					cQuery +=" 		,ZC73.ZC7_DTCAPT " +CRLF
					cQuery +=" 		,ZC73.ZC7_DTMOV  " +CRLF
					cQuery +=" 		,ZC71.ZC7_VTAXAD " +CRLF
					cQuery +=" 		,ZC73.ZC7_VTAXAD AS TAXA " +CRLF
					cQuery +=" 		,ZC73.ZC7_VLIQ " +CRLF
					cQuery +=" 		,ZC73.ZC7_VBRUT " +CRLF
					cQuery +=" 		,ZC71.ZC7_BANCO " +CRLF
					cQuery +=" 		,ZC71.ZC7_AGENC " +CRLF
					cQuery +=" 		,ZC71.ZC7_CONTA " +CRLF
					cQuery +=" 		,ZC73.ZC7_MOTAJU " +CRLF
					cQuery +=" 		,ZC71.R_E_C_N_O_ AS ZC7_CABEC " +CRLF
					cQuery +=" 		,ZC73.R_E_C_N_O_ AS ZC7_ITEM " +CRLF
					cQuery +="  FROM "+RetSqlName("ZC7")+" ZC71 WITH(NOLOCK) " +CRLF
					cQuery +=" INNER JOIN "+RetSqlName("ZC7")+" ZC73 WITH(NOLOCK) " +CRLF
					cQuery +="		ON ZC71.ZC7_FILIAL =ZC73.ZC7_FILIAL " +CRLF
					cQuery += " 	AND ZC71.ZC7_CODARQ=ZC73.ZC7_CODARQ "+CRLF
					cQuery +="		AND ZC71.ZC7_NUMEST=ZC73.ZC7_NUMEST " +CRLF
					cQuery +="		AND ZC71.ZC7_NUMRV =ZC73.ZC7_NUMRV  " +CRLF
					cQuery +="		AND ZC73.D_E_L_E_T_='' " +CRLF
					cQuery +="		AND ZC73.ZC7_TPRARQ='3' " +CRLF
					cQuery += " 	AND ZC73.ZC7_STATUS = '1' "+CRLF
					cQuery +=" WHERE ZC71.ZC7_TPRARQ='1' " +CRLF
					cQuery += " 	AND ZC71.ZC7_CODARQ = '"+cCodArq+"' "+CRLF
					cQuery +=" 	    AND ZC71.ZC7_INDPG ='PG' "+CRLF
					cQuery +=" 		AND ZC71.D_E_L_E_T_='' " +CRLF
					cQuery += " 	AND ZC71.ZC7_STATUS = '1' "+CRLF
					cQuery += " 	AND ZC71.ZC7_IDBSRV = '' "+CRLF
					//cQuery +=" 		AND ZC71.ZC7_BANDEI ='ED' "

					cQuery +=" 		UNION ALL  " +CRLF

				/*------------------------------------------------------ Augusto Ribeiro | 29/06/2018 - 5:50:53 PM
					Tratamento para antecipações 
				------------------------------------------------------------------------------------------*/
				cQuery += " SELECT "+CRLF
				cQuery += " 	ZC71.ZC7_CODARQ   "+CRLF
				cQuery += " 	,ZC71.ZC7_BANDEI  "+CRLF
				cQuery += " 	,ZC71.ZC7_NUMEST   "+CRLF
				cQuery += " 	,MAX(ZC72.ZC7_CODAUT) AS ZC7_CODAUT "+CRLF
				cQuery += " 	,ZC71.ZC7_QTDPAR  "+CRLF
				cQuery += " 	,ZC71.ZC7_PARCEL  "+CRLF
				cQuery += " 	,MAX(ZC72.ZC7_NUMCC) AS ZC7_NUMCC "+CRLF
				cQuery += " 	,MAX(ZC72.ZC7_DTCAPT) AS ZC7_DTCAPT "+CRLF
				cQuery += " 	,ZC71.ZC7_DTMOV   "+CRLF
				cQuery += " 	,ZC71.ZC7_VTAXAD 								 "+CRLF
				cQuery += " 	,ZC71.ZC7_VTAXAD as TAXA  "+CRLF
				cQuery += " 	,ZC71.ZC7_VLIQ 			 "+CRLF
				cQuery += " 	,ZC71.ZC7_VBRUT 			 "+CRLF
				cQuery += " 	,ZC71.ZC7_BANCO  "+CRLF
				cQuery += " 	,ZC71.ZC7_AGENC  "+CRLF
				cQuery += " 	,ZC71.ZC7_CONTA  "+CRLF
				cQuery += " 	,ZC71.ZC7_MOTAJU  "+CRLF
				cQuery += " 	,ZC71.R_E_C_N_O_ AS ZC7_CABEC  "+CRLF
				cQuery += " 	,0 AS ZC7_ITEM  "+CRLF
				cQuery += " FROM "+RetSqlName("ZC7")+" ZC71 WITH(NOLOCK)  "+CRLF
				cQuery += " INNER JOIN "+RetSqlName("ZC7")+" ZC72 WITH(NOLOCK)  "+CRLF
				cQuery += " 	ON ZC71.ZC7_FILIAL =ZC72.ZC7_FILIAL 	 "+CRLF
				cQuery += " 	AND ZC71.ZC7_NUMEST=ZC72.ZC7_NUMEST  "+CRLF
				cQuery += " 	AND ZC71.ZC7_NUMRV =ZC72.ZC7_NUMRV   "+CRLF
				cQuery += " 	AND ZC71.ZC7_QTDPAR=ZC72.ZC7_QTDPAR	 "+CRLF
				cQuery += " 	AND ZC72.D_E_L_E_T_=''  "+CRLF
				cQuery += " 	AND ZC72.ZC7_TPRARQ='2' 	 "+CRLF
				cQuery += " WHERE ZC71.ZC7_TPRARQ='1'  "+CRLF
				cQuery += " 	AND ZC71.ZC7_CODARQ = '"+cCodArq+"' "+CRLF
				cQuery += "     AND ZC71.ZC7_INDPG ='AC'  "+CRLF
				cQuery += " 	AND ZC71.D_E_L_E_T_=''  "+CRLF
				cQuery += " 	AND ZC71.ZC7_VCRED > 0 "+CRLF
				cQuery += " 	AND ZC71.ZC7_STATUS = '1' "+CRLF
				cQuery += " GROUP BY ZC71.ZC7_CODARQ   "+CRLF
				cQuery += " 	,ZC71.ZC7_BANDEI  "+CRLF
				cQuery += " 	,ZC71.ZC7_NUMEST   "+CRLF
				cQuery += " 	,ZC71.ZC7_QTDPAR  "+CRLF
				cQuery += " 	,ZC71.ZC7_PARCEL  "+CRLF
				cQuery += " 	,ZC71.ZC7_DTMOV   "+CRLF
				cQuery += " 	,ZC71.ZC7_VTAXAD "+CRLF
				cQuery += " 	,ZC71.ZC7_VTAXAD  "+CRLF
				cQuery += " 	,ZC71.ZC7_VLIQ 	"+CRLF
				cQuery += " 	,ZC71.ZC7_VBRUT "+CRLF
				cQuery += " 	,ZC71.ZC7_BANCO  "+CRLF
				cQuery += " 	,ZC71.ZC7_AGENC  "+CRLF
				cQuery += " 	,ZC71.ZC7_CONTA  "+CRLF
				cQuery += " 	,ZC71.ZC7_MOTAJU  "+CRLF
				cQuery += " 	,ZC71.R_E_C_N_O_ "+CRLF				
				

				
					If Select("TSQL") > 0
					TSQL->(DbCloseArea())
					EndIf
				
				DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						
				
				/*
				TSQL->(DBGoTop())	
				TSQL->( dbEval( {|| nCount++ } ) )	
				TSQL->(DBGoTop())
				
				ProcRegua(nCount)
				*/
					IF TSQL->(!EOF())

						cSemaf	:= NOME_SEMAFORO+ZC4->ZC4_CODIGO

					/*------------------------------------------------------ Fabio Sales | 21/10/2017 - 7:01:42 PM
						Abre semaforo de Processamento
					------------------------------------------------------------------------------------------*/
					nHSemafaro	:= U_CPXSEMAF("A", cSemaf)
					
						IF nHSemafaro > 0
						
							WHILE TSQL->(!EOF())
							//IncProc("Processando Arq. GET ["+ZC4->ZC4_CODIGO+"]...")
							
							aMov	:= {}	
							aExt	:= {}
							
							
							cDescAjust	:= ""
								IF !EMPTY(TSQL->ZC7_MOTAJU)
								cDescAjust	:= U_CP113DEP(DEPARA_ORIGEM_AJUSTE, ADQ_GETNET,TSQL->ZC7_MOTAJU)
								ENDIF
							
							cCodBand	:= U_CP113DEP(DEPARA_BANDEIRA,ADQ_GETNET,TSQL->ZC7_BANDEI)
							cForma		:= U_CP113DEP(DEPARA_DEBITO_CREDITO,ADQ_GETNET,TSQL->ZC7_BANDEI)
							
								IF !EMPTY(cCodBand)
								
								aadd(aMov, {"ZCA_CODADQ", ADQ_GETNET })
								aadd(aMov, {"ZCA_CODBAN", cCodBand })
								
									IF !EMPTY(cForma)
									aadd(aMov, {"ZCA_FORMA", cForma })
									endif
																
								aadd(aMov, {"ZCA_CODAUT", RIGHT(Alltrim(TSQL->ZC7_CODAUT),6) })
								aadd(aMov, {"ZCA_QTDPAR", val(TSQL->ZC7_QTDPAR) })
								aadd(aMov, {"ZCA_CODEST", TSQL->ZC7_NUMEST })
								aadd(aMov, {"ZCA_NUMPAC", val(TSQL->ZC7_PARCEL) })
								aadd(aMov, {"ZCA_CARMAS", TSQL->ZC7_NUMCC })
								aadd(aMov, {"ZCA_DTVEND", TSQL->ZC7_DTCAPT })
								aadd(aMov, {"ZCA_DTPAG",  TSQL->ZC7_DTMOV })
								
								
									IF TSQL->ZC7_MOTAJU == "02" .OR.;
									TSQL->ZC7_MOTAJU == "05" .OR.;
									TSQL->ZC7_MOTAJU == "06" .OR.;
									TSQL->ZC7_MOTAJU == "07" .OR.;
									TSQL->ZC7_MOTAJU == "08"
									
									aadd(aMov, {"ZCA_TPMOV", ZCA_TPMOV_TAXA })
										ELSEIF TSQL->ZC7_VLIQ < 0
									aadd(aMov, {"ZCA_TPMOV", ZCA_TPMOV_ESTORNO }) 
									ELSE
									aadd(aMov, {"ZCA_TPMOV", ZCA_TPMOV_PAGAMENTO }) 
									ENDIF
								
								
								//aadd(aMov, {"ZCA_TPMOV",  "1" })
								aadd(aMov, {"ZCA_VBRUTO", TSQL->TAXA + TSQL->ZC7_VLIQ})
								aadd(aMov, {"ZCA_VTAXA",  TSQL->TAXA * -1 })
								aadd(aMov, {"ZCA_PTAXA",  (TSQL->TAXA*100)/(TSQL->TAXA + TSQL->ZC7_VLIQ) })
								aadd(aMov, {"ZCA_VLIQ",   TSQL->ZC7_VLIQ })							
								aadd(aMov, {"ZCA_BANCO", RIGHT(ALLTRIM(TSQL->ZC7_BANCO),nTamBco) })
								aadd(aMov, {"ZCA_AGENC", RIGHT(ALLTRIM(TSQL->ZC7_AGENC),nTamAg) })														
								aadd(aMov, {"ZCA_CONTA", PADL(ALLTRIM(TSQL->ZC7_CONTA),nTamConta, "0") })
								
									IF !EMPTY(cDescAjust)
									aadd(aMov, {"ZCA_OBS",  cDescAjust})
									ENDIF
								
								AADD(aExt, TSQL->ZC7_CABEC)
									IF !EMPTY(TSQL->ZC7_ITEM)
									AADD(aExt, TSQL->ZC7_ITEM)
									ENDIF
		
								aRetAux	:= U_CP1110IN(aMov, "ZC7", aExt)
								
									IF !(aRetAux[1])
									cMsgErro	+= aRetAux[2]+CRLF					
									ENDIF
								
								ELSE
								cMsgErro += "[DEPARA] Bandeira nao localizada ["+TSQL->ZC7_BANDEI+"]"
								ENDIF
						
							TSQL->(DBSKIP()) 
							ENDDO
												
							IF EMPTY(cMsgErro)
							aRet[1]	:= ZC4_STATUS_PROCESSADO
							aRet[2]	:= ""					
							ELSE
							aRet[1]	:= ZC4_STATUS_PARCIAL
							aRet[2]	:= cMsgErro					
							ENDIF
						
						
						/*--------------------------
						FECHA SEMAFORO
						---------------------------*/
						U_CPXSEMAF("F", cSemaf,nHSemafaro)				
						ELSE
						aRet[1]	:= ZC4_STATUS_FALHA
						aRet[2]	:= "Não foi possivel abrir o semaforo["+cSemaf+"]"
						ENDIF
					ELSE
					aRet[1]	:= ZC4_STATUS_PROCESSADO
					aRet[2]	:= "Nao existem dados a serem processados"		
					ENDIF
				ELSE
				aRet[1]	:= ZC4_STATUS_DESCONSIDERADO
				aRet[2]	:= "Tipo de arquivo não corresponde a movimentação financeira realizada."			
				ENDIF
			ELSE
			aRet[1]	:= ZC4->ZC4_STATUS
			aRet[2]	:= "Este registro não pode ser processado - Status do arquivo ["+X3COMBO("ZC4_STATUS",ZC4->ZC4_STATUS)+"]"
			ENDIF
		ELSE
		aRet[1]	:= ZC4_STATUS_FALHA
		aRet[2]	:= "Arquivo não localizado"
		ENDIF
	ELSE
	aRet[1]	:= ZC4_STATUS_FALHA
	aRet[2]	:= "Parametros inválidos [CP11GETN]"	
	ENDIF

Return(aRet)


/*/{Protheus.doc} CP11VISU
Função para visualizar titulos e notas fiscais
@author Jonatas Oliveira | www.compila.com.br
@since 21/10/2017
@version 1.0
@param cTipo, C, 1="Titulo" para visualizar o titulo, 2=Nota Fiscal para visualizar a nota fiscal de saida
@param nRecno, N, Recno do titulo(SE1)  
/*/
User Function CP11VISU(cTipo, nRecno)
	Local _cCodEmp	:= ""
	Local _cCodFil	:= ""
	Local _cFilNew	:= ""

	Private CCADASTRO := ""

	IF cTipo == "1"
		CCADASTRO := "Contas a Receber"

		SE1->(DBGOTO(nRecno ))

		MaMakeView( "SE1" )

	ELSEIF cTipo =="2"
		CCADASTRO := "Nota Fiscal Saida"

		SE1->(DBGOTO(nRecno))

		DBSELECTAREA("SF2")
		SF2->(DBSETORDER(1))//|F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA|

		DBSELECTAREA("SD2")
		SD2->(DBSETORDER(3))//|D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA|

		IF SF2->(DBSEEK(SE1->(E1_FILIAL + E1_NUM + E1_PREFIXO + E1_CLIENTE + E1_LOJA)))
			IF SD2->(DBSEEK(SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))

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

				Mc090Visual("SD2")									

				/*---------------------------------------
				Restaura FILIAL  
				-----------------------------------------*/
				IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
					CFILANT := _cCodFil
					opensm0(_cCodEmp+CFILANT)			 			
				ENDIF
			ELSE
				AVISO("Itens Nota Fiscal", "Itens da Nota Fiscal não localizada",{"FECHAR"},3)
			ENDIF
		ELSE
			AVISO("Nota Fiscal", "Nota Fiscal Não localizada",{"FECHAR"},3)
		ENDIF

	ENDIF
	
Return()




/*/{Protheus.doc} CP11BCO
Busca BANCO "SA6" cadastrado no Protheus.
IMPORTANTE: deixa posicionado no SA6 caso banco localizado.
@author Augusto Ribeiro | www.compila.com.br
@since 02/11/2017
@version version
@param cBanco, Banco
@param cAgencia, Agencia
@param cConta, Conta
@return aRet	:= {SA6->A6_COD, SA6->A6_AGENCIA, SA6->A6_NUMCON}
@example
(examples)
@see (links_or_references)
/*/
User Function CP11BCO(cBanco, cAgencia, cConta)
	Local nA6COD		:= TAMSX3("A6_COD")[1]
	Local nA6AGENCIA	:= TAMSX3("A6_AGENCIA")[1]
	Local nA6XCONCAR 	:= TAMSX3("A6_XCONCAR")[1]
	Local aRet	:= {}
	Local nRecSA6	:= 0

	IF !EMPTY(cBanco) .AND. !EMPTY(cAgencia) .AND. !EMPTY(cConta)

	/*--------------------------------------------------------------------------
		Dados bancários para localizado do banco através de campo  customizado
	---------------------------------------------------------------------------------------*/
	cBanco		:= PADR(RIGHT(ALLTRIM(cBanco),nA6COD),nA6COD)
	cAgencia	:= PADR(RIGHT(ALLTRIM(cAgencia),nA6AGENCIA),nA6AGENCIA)
	cConta		:= PADR(RIGHT(ALLTRIM(cConta),nA6XCONCAR),nA6XCONCAR)
	
	
	DBSELECTAREA("SA6")
	SA6->(DbOrderNickName("CONTACART")) //| A6_COD, A6_AGENCIA, A6_XCONCAR, R_E_C_N_O_, D_E_L_E_T_
		IF SA6->(DBSEEK(cBanco+cAgencia+cConta))
		/*--------------------------------------------------------------------------
			Dados bancários
		---------------------------------------------------------------------------------------*/		
		aRet	:= {SA6->A6_COD, SA6->A6_AGENCIA, SA6->A6_NUMCON, alltrim(SA6->A6_FILIAL)}
		nRecSA6	:= SA6->(RECNO())
		SA6->(DBSETORDER(1))
		SA6->(DBGOTO(nRecSA6))
		ENDIF

	ENDIF
Return(aRet)




/*/{Protheus.doc} CP11INC5
Inclui movimentação bancária
@author Augusto Ribeiro | www.compila.com.br
@since 02/01/2017
@version 6
@param cOpc, cOpc == "PAGAR", cOpc == "RECEBER"
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP11INC5(nValor, cHist, cBanco, cAgenc, cConta, cNatOper, cCcusto)
	Local aRet	:= {.f.,""}
	Local nOpc := 0
	Local aFINA100 := {}
//Local cNaturez	:= "D002" //| ### |
	Local cAutoLog, cMemo

	Default cCcusto	:= ""

	Private lMsErroAuto := .F.


	cNaturez	:= cNatOper


	IF nValor <> 0 .AND. !EMPTY(cBanco) .AND. !EMPTY(cAgenc) .AND. !EMPTY(cConta)


		IF nValor > 0
			nOpc := 2
		ELSE
			nOpc := 1
		ENDIF

		If nOpc == 1 .or. nOpc == 2

			lMsErroAuto := .F.

			If nOpc == 1

				aFINA100 := { {"E5_DATA" ,dDataBase ,Nil},;
					{"E5_MOEDA" ,"M1" ,Nil},;
					{"E5_VALOR" ,nValor*-1 ,Nil},;
					{"E5_NATUREZ" ,cNaturez,Nil},;
					{"E5_BANCO" ,cBanco ,Nil},;
					{"E5_AGENCIA" ,cAgenc ,Nil},;
					{"E5_CONTA" ,cConta ,Nil},;
					{"E5_CCUSTO" ,cCcusto ,Nil},;
					{"E5_BENEF" ,"" ,Nil},;
					{"E5_HISTOR" ,cHist ,Nil}}

				MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3)

			ElseIf nOpc == 2

				aFINA100 := { {"E5_DATA" ,dDataBase ,Nil},;
					{"E5_MOEDA" ,"M1" ,Nil},;
					{"E5_VALOR" ,nValor ,Nil},;
					{"E5_NATUREZ" ,cNaturez,Nil},;
					{"E5_BANCO" ,cBanco ,Nil},;
					{"E5_AGENCIA" ,cAgenc ,Nil},;
					{"E5_CONTA" ,cConta ,Nil},;
					{"E5_CCUSTO" ,cCcusto ,Nil},;
					{"E5_HISTOR" ,cHist ,Nil}}


				MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,4)

			ENDIF

			If 	lMsErroAuto
				//MostraErro()
				cAutoLog	:= alltrim(NOMEAUTOLOG())

				cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
				cMemo := STRTRAN(cMemo,"'","")

				//| Apaga arquivo de Log
				Ferase(cAutoLog)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Le Log da Execauto e retorna mensagem amigavel ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aRet[2] := U_CPXERRO(cMemo)

				IF EMPTY(aRet[2])
					aRet[2]	:= alltrim(cMemo)
				ENDIF

			Else
				aRet[1]	:= .T.
			EndIf
		endif

	ELSE
		aRet[2]	:= "Parametros inválidos. Valor = 0 ou Banco, agencia e conta não informado. [CP11INC5]"
	ENDIF



Return(aRet)





/*/{Protheus.doc} CP11MOVB
Gera movimentação bancária
@author Augusto Ribeiro | www.compila.com.br
@since 02/01/2017
@version 6
@param cOpc, cOpc == "PAGAR", cOpc == "RECEBER"
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP11MOVB(cFilMov, nRecZCA, cNatOper, cCcusto, dDtProc, cHrProc)
	Local aRet	:= {.F., ""}
	Local dDataAnt


	IF !EMPTY(cFilMov) .AND. !EMPTY(nRecZCA) .AND. !EMPTY(cNatOper)// .AND. !EMPTY(cCcusto)

	/*------------------------------------------------------ Augusto Ribeiro | 03/11/2017 - 4:23:48 PM
		Posiciona na ZCA
	------------------------------------------------------------------------------------------*/
	DBSELECTAREA("ZCA")
	ZCA->(DBGOTO(nRecZCA))


	/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE 
	-----------------------------------------*/
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	_cFilNew	:= PADR(cFilMov,12) 
	
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
		ENDIF
	
	//| Altera data para gerar movimentacao|
	dDataAnt	:= DDATABASE
	DDATABASE	:= ZCA->ZCA_DTPAG
	
	
	/*--------------------------------------------------------------------------
		Dados bancários para localizado do banco através de campo  customizado
	---------------------------------------------------------------------------------------*/
	aRetBco		:= U_CP11BCO(ZCA->ZCA_BANCO, ZCA->ZCA_AGENC, ZCA->ZCA_CONTA)
	
		IF !EMPTY(aRetBco)
		
			IF ALLTRIM(SA6->A6_FILIAL) == LEFT(CFILANT,LEN(ALLTRIM(SA6->A6_FILIAL)))
		
				BEGIN TRANSACTION
			
		 	/*--------------------------
	 			Gera movimento bancario
	 		---------------------------*/
	 		cHistSE5	:= ALLTRIM(POSICIONE("ZC1",1,XFILIAL("ZC1")+ZCA->ZCA_CODADQ,"ZC1_DESC"))
					IF EMPTY(ZCA->ZCA_OBS)
	 			cHistSE5	+= "AJUSTE CARTOES"
					ELSE
	 			cHistSE5	+= " "+ALLTRIM(ZCA->ZCA_OBS)
					ENDIF
	 		aRetAux	:= U_CP11INC5(ZCA->ZCA_VLIQ, cHistSE5, alltrim(aRetBco[1]), alltrim(aRetBco[2]), alltrim(aRetBco[3]), alltrim(cNatOper), alltrim(cCcusto))
 		
					IF aRetAux[1]
	 			
				/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 11:37:13 AM
					Grava ZCB - Rastreabilidade de Mov. Unificado x Titulo
				------------------------------------------------------------------------------------------*/
				aDadoZCB	:= {}
				cChvSE5		:= SE5->(E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)+DTOS(SE5->E5_DATA)+SE5->(E5_CLIFOR+E5_LOJA+E5_SEQ)
				
				AADD(aDadoZCB, {"ZCB_CODMOV", ZCA->ZCA_CODIGO})
				AADD(aDadoZCB, {"ZCB_ALIAS", "SE5"})
				AADD(aDadoZCB, {"ZCB_RECALI", SE5->(recno()) })
				AADD(aDadoZCB, {"ZCB_INDALI", 2})
				AADD(aDadoZCB, {"ZCB_CHVALI", cChvSE5})
				AADD(aDadoZCB, {"ZCB_VLRMOV", ZCA->ZCA_VLIQ})
				//AADD(aDadoZCB, {"ZCB_MOTBX", aTitBaixa[nI, D_MOTBX]})
				AADD(aDadoZCB, {"ZCB_TPOPER", ZCB_TPOPER_MOV_BANCARIO })
				AADD(aDadoZCB, {"ZCB_DTMOV", dDataBase})
				
				
				aRetAux	:= U_CPXGRV("ZCB", 1, aDadoZCB, .T., 3)
				
						IF aRetAux[1]
				
					/*--------------------------------
						Abate Saldo do Movimento
					---------------------------------*/
					RECLOCK("ZCA",.F.)
					
						ZCA->ZCA_SALDO	:= 0
						ZCA->ZCA_STATUS	:= ZCA_STATUS_CONCLUIDO
						ZCA->ZCA_CODRAZ	:= ""
						ZCA->ZCA_LOG	:= ""
				
							IF !EMPTY(dDtProc)
							ZCA->ZCA_DTPROC	:= dDtProc
							ZCA->ZCA_HRPROC	:= cHrProc
							ELSE
							ZCA->ZCA_DTPROC	:= DATE()
							ZCA->ZCA_HRPROC	:= TIME()
							ENDIF
												
						
					MSUNLOCK()	
					
					aRet[1]	:= .T.		
						ELSE
					DISARMTRANSACTION()
					aRet[2] += aRetAux[2]+"."+CRLF //| Concatena ponto para evitar falso positivo carro erro venha vazio|
						ENDIF
					ELSE
	 			aRet[2] += aRetAux[2]+CRLF
					Endif
	 		
				END TRANSACTION
		
			ELSE
			aRet[2]	:= "Banco + Agencia + Conta Não pertence a filial ["+CFILANT+"]."
			ENDIF
		ELSE
 		aRet[2]	:= "Banco + Agencia + Conta ["+ZCA->ZCA_BANCO+ZCA->ZCA_AGENC+ZCA->ZCA_CONTA+"] não localizado. Verifique se a numero da conta recebida da adquirente esta vinculado no cadastros de bancos (A6_XCONCAR)."+CRLF
		ENDIF


	//| Restaura a Data|
	DDATABASE	:= dDataAnt
			 	
	/*---------------------------------------
		Restaura FILIAL  
	-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)			 			
		ENDIF
	ELSE
   	aRet[2]	:= "Parametros inválidos [CP11MOVB]."
	ENDIF


Return(aRet)








/*/{Protheus.doc} CP11BXAT
Baixa titulos automaticamente com base cod de autorização.
@author Augusto Ribeiro | www.compila.com.br
@since 04/11/2017
@version 6
@param lReproc, Reprocessa Inconsistencias (.F. = Default)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP11BXAT(lReproc, cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim)
	Local aRet		:= {.F., ""}
	Local cQuery	:= ""
	Local nI, nY, nCount, nVlrTol, nX
	Local cLog		:= ""
	Local cAux		:= ""
	Local aQryInc1	:= {RAZ_CONTA_NAO_LOCAZ, RAZ_PV_NAO_FATURADO, RAZ_NF_NAO_EMITIDA, RAZ_NAO_LOCALIZADO,RAZ_MARCA}
//Local aQryInc1	:= {RAZ_CONTA_NAO_LOCAZ, RAZ_NF_NAO_EMITIDA, RAZ_NAO_LOCALIZADO} //| ### TESTE LOCAL|
	Local aQryInc2	:= {RAZ_DIF_PARCELA}
	Local aQryBaixa	:= {RAZ_S01, RAZ_S02}
	Local aQryMov	:= {RAZ_T01, RAZ_E01}
	Local dDtProc	:= DATE() //| Grava todos os registros processados neste 'lote' para facilitar a indentificao dos mesmos|
	Local cHrProc	:= time() //| Grava todos os registros processados neste 'lote' para facilitar a indentificao dos mesmos|
	Local cZCASALDO	:= PesqPict("ZCA", "ZCA_SALDO")
	Local cE1SALDO	:= PesqPict("SE1", "E1_SALDO")
	Local aRetBco	:= {}
	Local nRecAux	:= 0
	Local cAdqAux	:= ""
	lOCAL cSemaf, nHSemafaro
	Local aTitBx := {}
	Local aDadosEnv := {}
	Local aRetAux

	Default lReproc := .F.

	DBSELECTAREA("SE1")
	DBSELECTAREA("ZCA")
	ProcRegua(4)

	cAdqAux	:= cCodAdq

/*------------------------------------------------------ Augusto Ribeiro | 02/04/2018 - 3:29:25 PM
	Melhoria para que semaforo de baixa automática seja por adquirente
------------------------------------------------------------------------------------------*/
DBSELECTAREA("ZC1")
ZC1->(DBSETORDER(1)) //| 
ZC1->(DBGOTOP())
	WHILE ZC1->(!EOF())

	aAreaZC1	:= ZC1->(GETAREA())
	
		IF EMPTY(cAdqAux)
		cCodAdq	:= ZC1->ZC1_CODIGO
		ELSE
			IF ZC1->ZC1_CODIGO <> cAdqAux
			ZC1->(DBSKIP())
			LOOP
			ENDIF
		ENDIF
		
	//| Abre semaforo por adquirente |
	cSemaf	:= NOME_SEMAFORO+"CP11BXAT_"+UPPER(ALLTRIM(cCodAdq))
	
	/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
		Abre semaforo de Processamento
	------------------------------------------------------------------------------------------*/
	nHSemafaro	:= U_CPXSEMAF("A", cSemaf)
	
		IF nHSemafaro > 0
	
		
		/*------------------------------------------------------ Augusto Ribeiro | 04/11/2017 - 3:50:40 PM
			** PRE-VALIDACAO 
			REGISTRA INCONSISTENCIAS EXPLICIDAS
		------------------------------------------------------------------------------------------*/
			FOR nI := 1 to len(aQryInc1)
		
			IncProc("Verificando inconsistencias PRE ["+aQryInc1[nI]+"]...")
		
			/*------------------------------------------------------ Augusto Ribeiro | 04/11/2017 - 3:46:52 PM
				Retorna Query de acordo com o codigo de roteiro passado.
			------------------------------------------------------------------------------------------*/
			cQuery	:= qIncons(lReproc, aQryInc1[nI], cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim, dDtProc, cHrProc)
			
				If Select("TBXAUT") > 0
				TBXAUT->(DbCloseArea())
				EndIf
			
			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TBXAUT",.F., .T.)		
		
			
				WHILE TBXAUT->(!EOF())

					ZCA->(DBGOTO(TBXAUT->ZCA_RECNO))
					IF ZCA->ZCA_STATUS == ZCA_STATUS_CONCLUIDO .OR. ZCA->ZCA_STATUS == ZCA_STATUS_DESCONSIDERADO
						TBXAUT->(DBSKIP())
						LOOP
					ENDIF

				cLog	:= ""
					IF aQryInc1[nI] == RAZ_PV_NAO_FATURADO
					cLog	:= "FILIAL: "+TBXAUT->Z7_FILIAL+" PV: "+TBXAUT->Z7_PEDIDO
					ELSEIF aQryInc1[nI] == RAZ_NF_NAO_EMITIDA
					cLog	:= "FILIAL: "+TBXAUT->F2_FILIAL+" SERIE: "+TBXAUT->F2_SERIE+" RPS: "+TBXAUT->F2_DOC
					ELSEIF 	aQryInc1[nI] == RAZ_MARCA
					cLog 	:= "Marca da conta: "+TBXAUT->A6_XCODMAR+", Marca da filial de origem do título: "+U_GetMarca(TBXAUT->E1_FILORIG) 
					ENDIF
				GrvSTZCA(TBXAUT->ZCA_RECNO, ZCA_STATUS_INCONSISTENCIA, aQryInc1[nI], cLog, dDtProc, cHrProc)
				
				TBXAUT->(DBSKIP()) 
				ENDDO
			
			TBXAUT->(DbCloseArea())
				
			NEXT
		
		
		DBSELECTAREA("ZCA")

		/*------------------------------------------------------ Augusto Ribeiro | 04/11/2017 - 3:47:21 PM
			** BAIXA DE TITULOS **
			
			Executa mais de uma query para conciliação para priorizar baixa de 
			registros no qual o vinculo com o financeiro é mais acertivo.	
		------------------------------------------------------------------------------------------*/
			FOR nI := 1 to len(aQryBaixa)
		
			IncProc("Processando baixas ["+aQryBaixa[nI]+"]...")
			
			/*------------------------------------------------------ Augusto Ribeiro | 04/11/2017 - 3:46:52 PM
				Retorna Query de acordo com o codigo de roteiro passado.
			------------------------------------------------------------------------------------------*/
			cQuery	:= qBaixa(aQryBaixa[nI], cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim, dDtProc, cHrProc, lReproc)
			
			
				If Select("TBXAUT") > 0
				TBXAUT->(DbCloseArea())
				EndIf
			
			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TBXAUT",.F., .T.)						
			
			TCSetField("TBXAUT","ZCA_DTPAG","D",08,00)
			
				WHILE TBXAUT->(!EOF())
				
					ZCA->(DBGOTO(TBXAUT->ZCA_RECNO))
					IF ZCA->ZCA_STATUS == ZCA_STATUS_CONCLUIDO .OR. ZCA->ZCA_STATUS == ZCA_STATUS_DESCONSIDERADO
						TBXAUT->(DBSKIP())   //hfp+Augusto - ajustou por aqui. 
						LOOP
					ENDIF
		
				/*--------------------------
					Inconsistencias
				---------------------------*/
					IF TBXAUT->E1_SALDO <= 0
				
					SE1->(DBGOTO(TBXAUT->SE1_RECNO))
					cAux	:= "TITULO: "+alltrim(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
				
					GrvSTZCA(TBXAUT->ZCA_RECNO, ZCA_STATUS_INCONSISTENCIA, RAZ_JA_BAIXADO, aQryBaixa[nI]+" "+cAux, dDtProc, cHrProc)
				
					ELSEIF  TBXAUT->ZCA_DTPAG > DDATABASE
		
					cAux	:= "Este movimento será baixado na data de "+DTOC(TBXAUT->ZCA_DTPAG)+" conforme informado pela adquirente."	
						
					GrvSTZCA(TBXAUT->ZCA_RECNO, ZCA_STATUS_INCONSISTENCIA, RAZ_DT_PGTO_FUTURA, aQryBaixa[nI]+" "+cAux, dDtProc, cHrProc)
					
					ELSE
					/*------------------------------------------------------ Augusto Ribeiro | 15/11/2017 - 11:15:13 AM
						Busca tolerancia cadastrada para a Filial
					------------------------------------------------------------------------------------------*/
					nVlrTol	:= SUPERGETMV("CP11_BXTOL",.F.,0.05, TBXAUT->E1_FILIAL)
					nDif	:= TBXAUT->ZCA_SALDO - TBXAUT->E1_SALDO
					aTitBx := {}

						If nDif > 0
						aTitBx	:= getTrans(TBXAUT->SE1_RECNO,nDif)
							If len(aTitBx) > 1
							nDif := 0
							Endif
						Else
						aAdd(aTitBx,{TBXAUT->SE1_RECNO,nDif})	
						Endif

						IF nDif == 0 .OR.;
					 	(nDif < 0 .AND. nDif >= (nVlrTol*-1)) .OR.;
					 	(nDif > 0 .AND. nDif <= nVlrTol)

						/*---------------------------------------------------------------- 
							** BAIXA **
							 Para estas querys mais acertivas, a baixa é 1 para 1
						--------------------------------------------------------------*/
						aRetAux	:= U_CP11BAIX(TBXAUT->ZCA_RECNO , aTitBx , "", dDtProc, cHrProc)

								IF !(aRetAux[1]) .AND. ZCA->ZCA_HRPROC <> cHrProc //| Somente grava com falha caso rotina de baixa não execute sua ação.|
							GrvSTZCA(TBXAUT->ZCA_RECNO, ZCA_STATUS_FALHA, "", aQryBaixa[nI]+" "+aRetAux[2], dDtProc, cHrProc)
							ENDIF
						
						ELSE
						/*--------------------------
							Inconsistencias
						---------------------------*/
						SE1->(DBGOTO(TBXAUT->SE1_RECNO))
						cAux	:= "TITULO: "+alltrim(SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO))
						cAux	+= " CARTAO: "+ ALLTRIM(TRANSFORM(TBXAUT->ZCA_SALDO, cZCASALDO))
						cAux	+= " TITULO: "+ ALLTRIM(TRANSFORM(TBXAUT->E1_SALDO, cE1SALDO))
						cAux	+= " DIF.: "+ ALLTRIM(TRANSFORM(TBXAUT->ZCA_SALDO-TBXAUT->E1_SALDO, cE1SALDO))
						
						GrvSTZCA(TBXAUT->ZCA_RECNO, ZCA_STATUS_INCONSISTENCIA, RAZ_DIVERGENCIA_SALDO, aQryBaixa[nI]+" "+cAux, dDtProc, cHrProc)			
						ENDIF
						
					ENDIF
				
				
				TBXAUT->(DBSKIP()) 
				ENDDO
			
			TBXAUT->(DbCloseArea())
				
			NEXT
		
		
		/*------------------------------------------------------ Augusto Ribeiro | 04/11/2017 - 3:50:40 PM
			** POS-VALIDACAO 
			REGISTRA INCONSISTENCIAS EXPLICIDAS
		------------------------------------------------------------------------------------------*/
			FOR nI := 1 to len(aQryInc2)
		
			IncProc("Verificando inconsistencias POS ["+aQryInc2[nI]+"]...")
		
			/*------------------------------------------------------ Augusto Ribeiro | 04/11/2017 - 3:46:52 PM
				Retorna Query de acordo com o codigo de roteiro passado.
			------------------------------------------------------------------------------------------*/
			cQuery	:= qIncons(lReproc, aQryInc2[nI], cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim, dDtProc, cHrProc)
			
				If Select("TBXAUT") > 0
				TBXAUT->(DbCloseArea())
				EndIf
			
			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TBXAUT",.F., .T.)		
		
			nRecAux	:= 0
				WHILE TBXAUT->(!EOF())

					ZCA->(DBGOTO(TBXAUT->ZCA_RECNO))
					IF ZCA->ZCA_STATUS == ZCA_STATUS_CONCLUIDO .OR. ZCA->ZCA_STATUS == ZCA_STATUS_DESCONSIDERADO
						TBXAUT->(DBSKIP())
						LOOP
					ENDIF
			
					IF nRecAux <> TBXAUT->ZCA_RECNO
					nRecAux	:= TBXAUT->ZCA_RECNO	
			
					cLog	:= ""
						IF aQryInc2[nI] == RAZ_DIF_PARCELA
				
						/*----------------------------------
							POSICIONA NO TITULO
						-----------------------------------*/			
						SE1->(DBGOTO(TBXAUT->SE1_RECNO))
						cLog	:= "TITULO: "+SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)					
						ENDIF
					GrvSTZCA(TBXAUT->ZCA_RECNO, ZCA_STATUS_INCONSISTENCIA, aQryInc2[nI], cLog, dDtProc, cHrProc)
					endif
				TBXAUT->(DBSKIP()) 
				ENDDO
			
			TBXAUT->(DbCloseArea())
			NEXT
		
		
		
		/*------------------------------------------------------ Augusto Ribeiro | 04/11/2017 - 3:47:21 PM
			** MOVIMENTACAO BANCARIA **
			
			Executa mais de uma query para tratar lançamentos de taxa diretamente
			na movimentacao bancaria 
		------------------------------------------------------------------------------------------*/
			FOR nI := 1 to len(aQryMov)
		
			IncProc("Processando baixas ["+aQryMov[nI]+"]...")
			
			/*------------------------------------------------------ Augusto Ribeiro | 04/11/2017 - 3:46:52 PM
				Retorna Query de acordo com o codigo de roteiro passado.
			------------------------------------------------------------------------------------------*/
			cQuery	:= qMovBanc(aQryMov[nI], cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim, dDtProc, cHrProc)
			
			
				If Select("TBXAUT") > 0
				TBXAUT->(DbCloseArea())
				EndIf
			
			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TBXAUT",.F., .T.)						
			
				IF TBXAUT->(!EOF())
			
			
				/*
				//------------------------------------------------------ Augusto Ribeiro | 16/11/2017 - 6:48:44 PM
					Cria array com filiais para ordenar corretamente
				------------------------------------------------------------------------------------------
				*/
					aFilSM0	:= {}
					DBSELECTAREA("SM0")
					nRecSM0	:= SM0->(RECNO())
					SM0->(DBGOTOP())
					WHILE SM0->(!EOF())

						AADD(aFilSM0, SM0->M0_CODFIL)

						SM0->(DBSKIP())
					ENDDO
					SM0->(DBGOTO(nRecSM0))

					aSort(aFilSM0)

					WHILE TBXAUT->(!EOF())

						ZCA->(DBGOTO(TBXAUT->ZCA_RECNO))
						IF ZCA->ZCA_STATUS == ZCA_STATUS_CONCLUIDO .OR. ZCA->ZCA_STATUS == ZCA_STATUS_DESCONSIDERADO
							TBXAUT->(DBSKIP())

							LOOP
						ENDIF

					/*--------------------------------------------------------------------
						Definição da Filial onde será gerado o mov. bancário é definida
						pela primeira filial no qual o banco, ag e conta esta cadastrado
					---------------------------------------------------------------------*/
					aRetBco		:= U_CP11BCO(ZCA->ZCA_BANCO, ZCA->ZCA_AGENC, ZCA->ZCA_CONTA)
						IF LEN(aRetBco) > 0
						cFilSA6	:= ALLTRIM(SA6->A6_FILIAL)
						nFilSA6	:= LEN(cFilSA6) 
							FOR nY := 1 to len(aFilSM0)
						
								IF LEFT(aFilSM0[nY],nFilSA6) == cFilSA6
								cFilMov	 := aFilSM0[nY]
								EXIT
								ENDIF
						
							NEXT nY
						
						
						cCcusto		:= SUPERGETMV("CP11_TXCC",.F.,"", cFilMov)
						
							IF ZCA->ZCA_TPMOV == ZCA_TPMOV_TAXA
							cNatOper	:= SUPERGETMV("CP11_TXNAT",.F.,"", cFilMov)
							ELSEIF ZCA->ZCA_TPMOV == ZCA_TPMOV_ESTORNO
							cNatOper	:= SUPERGETMV("CP11_ESNAT",.F.,"", cFilMov)
							ENDIF
						
						
							IF !EMPTY(cNatOper)
						
							aRetAux	:= U_CP11MOVB(cFilMov, TBXAUT->ZCA_RECNO , cNatOper, cCcusto, dDtProc, cHrProc)
							
								IF !(aRetAux[1])
								GrvSTZCA(TBXAUT->ZCA_RECNO, ZCA_STATUS_FALHA, "", aQryMov[nI]+" "+aRetAux[2], dDtProc, cHrProc)
								ENDIF
							ELSE
							cAux	:= "Natureza não informada no parametro [CP11_TXNAT]."
							GrvSTZCA(TBXAUT->ZCA_RECNO, ZCA_STATUS_INCONSISTENCIA, RAZ_PARAMETRIZACAO, cAux, dDtProc, cHrProc)			 					
							ENDIF
						ELSE
						cAux	:= "Banco + Agencia + Conta ["+ZCA->ZCA_BANCO+ZCA->ZCA_AGENC+ZCA->ZCA_CONTA+"] não localizado. Verifique se a numero da conta recebida da adquirente esta vinculado no cadastros de bancos (A6_XCONCAR)."
						GrvSTZCA(TBXAUT->ZCA_RECNO, ZCA_STATUS_INCONSISTENCIA, RAZ_CONTA_NAO_LOCAZ, cAux, dDtProc, cHrProc)			 
						ENDIF
					
					TBXAUT->(DBSKIP()) 
					ENDDO
					
				ENDIF
			
			TBXAUT->(DbCloseArea())
				
			NEXT
		
		/*--------------------------
			FECHA SEMAFORO
		---------------------------*/
		U_CPXSEMAF("F", cSemaf,nHSemafaro)	
		ELSE
		aRet[2]	:= "Já existe outra instancia em execução. Não foi possivel abrir o semaforo["+cSemaf+"]"
		ENDIF
	
	
	
	//| Recupera a area da ZC1 por seguranca |
	RestArea(aAreaZC1)
	
	ZC1->(DBSKIP()) 
	ENDDO

Return(aRet)




/*/{Protheus.doc} qBaixa
Retorna Query para baixa roteiro 1
@author Augusto Ribeiro | www.compila.com.br
@since 04/11/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qBaixa(cCodRoteiro, cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim, dDtProc, cHrProc, lReproc)
	Local cQuery	:= ""
	Local cWhereZCA	:= ""


/*------------------------------------------------------ Augusto Ribeiro | 06/11/2017 - 9:32:13 AM
	Where padrão da ZCA conforme parametros.
------------------------------------------------------------------------------------------*/
cWhereZCA += " WHERE ZCA_FILIAL = '' "+CRLF
	IF !EMPTY(cCodBand)
	cWhereZCA += " AND ZCA_CODBAN = '"+cCodBand+"' "+CRLF
	ENDIF
	IF !EMPTY(cCodAdq)
	cWhereZCA += " AND ZCA_CODADQ = '"+cCodAdq+"' "+CRLF
	ENDIF

	IF !EMPTY(dDtVdIni) .AND. !EMPTY(dDtVdFim)
	cWhereZCA += " AND ZCA_DTVEND BETWEEN '"+DTOS(dDtVdIni)+"' AND '"+DTOS(dDtVdFim)+"' "+CRLF
	ELSEIF !EMPTY(dDtVdIni)
	cWhereZCA += " AND ZCA_DTVEND  >= '"+DTOS(dDtVdIni)+"' 
	ELSEIF !EMPTY(dDtVdFim)
	cWhereZCA += " AND ZCA_DTVEND  <= '"+DTOS(dDtVdFim)+"'
	ENDIF


	IF !EMPTY(dDtPgIni) .AND. !EMPTY(dPgFim)
	cWhereZCA += " AND ZCA_DTPAG BETWEEN '"+DTOS(dDtPgIni)+"' AND '"+DTOS(dPgFim)+"' "+CRLF
	ELSEIF !EMPTY(dDtPgIni)
	cWhereZCA += " AND ZCA_DTPAG  >= '"+DTOS(dDtPgIni)+"' 
	ELSEIF !EMPTY(dDtVdFim)
	cWhereZCA += " AND ZCA_DTPAG  <= '"+DTOS(dPgFim)+"'
	ENDIF
cWhereZCA += " AND ZCA_SALDO > 0 "+CRLF
//cWhereZCA += " AND ZCA_STATUS <> '"+ZCA_STATUS_CONCLUIDO+"' "+CRLF
cWhereZCA += "  AND ZCA_STATUS NOT IN  ('"+ZCA_STATUS_CONCLUIDO+"','"+ZCA_STATUS_DESCONSIDERADO+"') "+CRLF

	If !lReproc
	cWhereZCA += " AND ZCA_STATUS <> '"+ZCA_STATUS_INCONSISTENCIA+"'"+CRLF
	Endif

	IF !EMPTY(cStatus)
	cWhereZCA += " AND ZCA_STATUS = '"+cStatus+"' "+CRLF
	ENDIF
/*------------------------------------------------------ Augusto Ribeiro | 06/11/2017 - 10:48:45 AM
	Desconsidera registros da mesma DATA E HORA de processamento para evitar 
	unico razao de status.
------------------------------------------------------------------------------------------*/
	IF !EMPTY(dDtProc)
	cWhereZCA += " AND NOT (ZCA_DTPROC = '"+DTOS(dDtProc)+"' AND ZCA_HRPROC = '"+cHrProc+"') "	
	ENDIF
cWhereZCA += " AND ZCA.ZCA_TPMOV = '"+ZCA_TPMOV_PAGAMENTO+"' "+CRLF
cWhereZCA += " AND ZCA.D_E_L_E_T_ = '' "+CRLF

/*------------------------------------------------------ Augusto Ribeiro | 11/01/2018 - 6:33:00 PM
	Desconsidera Movimentos no qual tiveram a baixa ou mov. bancaria estornada
------------------------------------------------------------------------------------------*/
	IF GETMV("CP11_DBXES",.F.,.T.)
	cWhereZCA += "  AND NOT EXISTS (SELECT 1 AS 'A' "+CRLF
	cWhereZCA += "  				FROM "+RetSqlName("ZCB")+" ZCB "+CRLF
	cWhereZCA += " 				WHERE ZCB_FILIAL= '' "+CRLF
	cWhereZCA += " 				AND ZCB_CODMOV = ZCA_CODIGO "+CRLF
	cWhereZCA += " 				and ZCB_TPOPER = '3' "+CRLF
	cWhereZCA += " 				AND ZCB.D_E_L_E_T_ = '' ) "+CRLF
	ENDIF


cQuery := " SELECT ZCA.R_E_C_N_O_ AS ZCA_RECNO, "+CRLF
cQuery += " 		SE1.R_E_C_N_O_ AS SE1_RECNO, "+CRLF
cQuery += " 		ZCA.ZCA_SALDO, "+CRLF
cQuery += " 		ZCA.ZCA_DTPAG, "+CRLF
cQuery += " 		SE1.E1_SALDO, "+CRLF
cQuery += " 		SE1.E1_FILIAL "+CRLF
cQuery += " FROM "+RetSqlName("ZCA")+" ZCA WITH(NOLOCK) "+CRLF
cQuery += " INNER JOIN "+RetSqlName("SE1")+" SE1  WITH(NOLOCK) "+CRLF
cQuery += " 	ON  SE1.E1_EMISSAO >= ZCA_DTVEND "+CRLF
	IF cCodRoteiro == RAZ_S01
	cQuery += " 	AND SE1.E1_XBAND = ZCA_CODBAN "+CRLF
	ELSEIF cCodRoteiro == RAZ_S02
	cQuery += " 	AND SE1.E1_XBAND <> ZCA_CODBAN "+CRLF
	ENDIF
cQuery += " 	AND SE1.E1_XCODAUT = ZCA_CODAUT "+CRLF
//cQuery += " 	AND SE1.E1_XPARCAR = CASE WHEN ZCA_NUMPAC > 0 THEN  RIGHT('000'+CONVERT(VARCHAR, ZCA_NUMPAC) ,3) ELSE '' END "+CRLF
cQuery += " 	AND SE1.E1_XPARCAR = CASE WHEN ZCA_NUMPAC > 0 AND ZCA_QTDPAR > 1 THEN  RIGHT('000'+CONVERT(VARCHAR, ZCA_NUMPAC) ,3) ELSE '' END "+CRLF
//cQuery += " 	AND SE1.E1_SALDO = ZCA_SALDO "+CRLF
cQuery += " 	AND SE1.D_E_L_E_T_  =  ''  "+CRLF


cQuery += cWhereZCA
cQuery += " ORDER BY ZCA_STATUS, ZCA_CODIGO "+CRLF

	IF !(ISBLIND())
	MemoWrite(GetTempPath(.T.) + "CP11000_qBaixa_"+cCodRoteiro+".SQL", cQuery)
	ENDIF

Return(cQuery)





/*/{Protheus.doc} qMovBanc
Query da movimentacao bancaria
@author Augusto Ribeiro | www.compila.com.br
@since 04/11/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qMovBanc(cCodRoteiro, cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim, dDtProc, cHrProc)
	Local cQuery	:= ""
	Local cWhereZCA	:= ""


/*------------------------------------------------------ Augusto Ribeiro | 06/11/2017 - 9:32:13 AM
	Where padrão da ZCA conforme parametros.
------------------------------------------------------------------------------------------*/
cWhereZCA += " WHERE ZCA_FILIAL = '' "+CRLF
	IF !EMPTY(cCodBand)
	cWhereZCA += " AND ZCA_CODBAN = '"+cCodBand+"' "+CRLF
	ENDIF
	IF !EMPTY(cCodAdq)
	cWhereZCA += " AND ZCA_CODADQ = '"+cCodAdq+"' "+CRLF
	ENDIF

	IF !EMPTY(dDtVdIni) .AND. !EMPTY(dDtVdFim)
	cWhereZCA += " AND ZCA_DTVEND BETWEEN '"+DTOS(dDtVdIni)+"' AND '"+DTOS(dDtVdFim)+"' "+CRLF
	ELSEIF !EMPTY(dDtVdIni)
	cWhereZCA += " AND ZCA_DTVEND  >= '"+DTOS(dDtVdIni)+"' 
	ELSEIF !EMPTY(dDtVdFim)
	cWhereZCA += " AND ZCA_DTVEND  <= '"+DTOS(dDtVdFim)+"'
	ENDIF


	IF !EMPTY(dDtPgIni) .AND. !EMPTY(dPgFim)
	cWhereZCA += " AND ZCA_DTPAG BETWEEN '"+DTOS(dDtPgIni)+"' AND '"+DTOS(dPgFim)+"' "+CRLF
	ELSEIF !EMPTY(dDtPgIni)
	cWhereZCA += " AND ZCA_DTPAG  >= '"+DTOS(dDtPgIni)+"' 
	ELSEIF !EMPTY(dDtVdFim)
	cWhereZCA += " AND ZCA_DTPAG  <= '"+DTOS(dPgFim)+"'
	ENDIF
cWhereZCA += " AND ZCA_SALDO < 0 "+CRLF
//cWhereZCA += " AND ZCA_STATUS <> '"+ZCA_STATUS_CONCLUIDO+"' "+CRLF
cWhereZCA += "  AND ZCA_STATUS NOT IN  ('"+ZCA_STATUS_CONCLUIDO+"','"+ZCA_STATUS_DESCONSIDERADO+"') "+CRLF

	IF !EMPTY(cStatus)
	cWhereZCA += " AND ZCA_STATUS = '"+cStatus+"' "+CRLF
	ENDIF
/*------------------------------------------------------ Augusto Ribeiro | 06/11/2017 - 10:48:45 AM
	Desconsidera registros da mesma DATA E HORA de processamento para evitar 
	unico razao de status.
------------------------------------------------------------------------------------------*/
	IF !EMPTY(dDtProc)
	cWhereZCA += " AND NOT (ZCA_DTPROC = '"+DTOS(dDtProc)+"' AND ZCA_HRPROC = '"+cHrProc+"') "	
	ENDIF

	IF cCodRoteiro == RAZ_T01
	cWhereZCA += " AND ZCA.ZCA_TPMOV = '"+ZCA_TPMOV_TAXA+"' "+CRLF
	ELSEIF cCodRoteiro == RAZ_E01
	cWhereZCA += " AND ZCA.ZCA_TPMOV = '"+ZCA_TPMOV_ESTORNO+"' "+CRLF	
	ELSE
	/*----------------------------------------
		Caso nao seja identificado o roteiro,
		por seguranca processa somente taxa
	-----------------------------------------*/
	cWhereZCA += " AND ZCA.ZCA_TPMOV = '"+ZCA_TPMOV_TAXA+"' "+CRLF
	ENDIF

cWhereZCA += " AND ZCA.D_E_L_E_T_ = '' "+CRLF

/*------------------------------------------------------ Augusto Ribeiro | 11/01/2018 - 6:33:00 PM
	Desconsidera Movimentos no qual tiveram a baixa ou mov. bancaria estornada
------------------------------------------------------------------------------------------*/
	IF GETMV("CP11_DBXES",.F.,.T.)
	cWhereZCA += "  AND NOT EXISTS (SELECT 1 AS 'A' "+CRLF
	cWhereZCA += "  				FROM "+RetSqlName("ZCB")+" ZCB "+CRLF
	cWhereZCA += " 				WHERE ZCB_FILIAL= '' "+CRLF
	cWhereZCA += " 				AND ZCB_CODMOV = ZCA_CODIGO "+CRLF
	cWhereZCA += " 				and ZCB_TPOPER = '3' "+CRLF
	cWhereZCA += " 				AND ZCB.D_E_L_E_T_ = '' ) "+CRLF
	ENDIF



cQuery := " SELECT ZCA.R_E_C_N_O_ AS ZCA_RECNO, "+CRLF
cQuery += " 		ZCA.ZCA_SALDO "+CRLF
cQuery += " FROM "+RetSqlName("ZCA")+" ZCA WITH(NOLOCK) "+CRLF

cQuery += cWhereZCA
cQuery += " ORDER BY ZCA_CODIGO "+CRLF

	IF !(ISBLIND())
	MemoWrite(GetTempPath(.T.) + "CP11000_qMovBanc_"+cCodRoteiro+".SQL", cQuery)
	ENDIF

Return(cQuery)





/*/{Protheus.doc} qIncons
Retorna querys para tratamento de inconsistencias
@author Augusto Ribeiro | www.compila.com.br
@since 04/11/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qIncons(lReproc, cCodRoteiro, cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim, dDtProc, cHrProc)
	Local cQuery	:= ""
	Local cWhereZCA	:= "" //|Where padrão da ZCA conforme parametros.
	Local cSerMot	:= Upper(alltrim(GetMV("ES_SERMOT",.f.,"MOT"))) //| Serie motoboy, não necessita de NF.|


	IF !EMPTY(cCodRoteiro)


	/*------------------------------------------------------ Augusto Ribeiro | 06/11/2017 - 9:32:13 AM
		Where padrão da ZCA conforme parametros.
	------------------------------------------------------------------------------------------*/
	cWhereZCA := " WHERE ZCA_FILIAL = '' "+CRLF		
		IF !EMPTY(cCodBand)
		cWhereZCA += " AND ZCA_CODBAN = '"+cCodBand+"' "+CRLF
		ENDIF
		IF !EMPTY(cCodAdq)
		cWhereZCA += " AND ZCA_CODADQ = '"+cCodAdq+"' "+CRLF
		ENDIF
	
		IF !EMPTY(dDtVdIni) .AND. !EMPTY(dDtVdFim)
		cWhereZCA += " AND ZCA_DTVEND BETWEEN '"+DTOS(dDtVdIni)+"' AND '"+DTOS(dDtVdFim)+"' "+CRLF
		ELSEIF !EMPTY(dDtVdIni)
		cWhereZCA += " AND ZCA_DTVEND  >= '"+DTOS(dDtVdIni)+"' 
		ELSEIF !EMPTY(dDtVdFim)
		cWhereZCA += " AND ZCA_DTVEND  <= '"+DTOS(dDtVdFim)+"'
		ENDIF
		IF !EMPTY(dDtPgIni) .AND. !EMPTY(dPgFim)
		cWhereZCA += " AND ZCA_DTPAG BETWEEN '"+DTOS(dDtPgIni)+"' AND '"+DTOS(dPgFim)+"' "+CRLF
		ELSEIF !EMPTY(dDtPgIni)
		cWhereZCA += " AND ZCA_DTPAG  >= '"+DTOS(dDtPgIni)+"' 
		ELSEIF !EMPTY(dDtVdFim)
		cWhereZCA += " AND ZCA_DTPAG  <= '"+DTOS(dPgFim)+"'
		ENDIF
	
	cWhereZCA += " AND ZCA_SALDO > 0 "+CRLF
	//cWhereZCA += " AND ZCA_STATUS <> '"+ZCA_STATUS_CONCLUIDO+"' "+CRLF
	cWhereZCA += "  AND ZCA_STATUS NOT IN  ('"+ZCA_STATUS_CONCLUIDO+"','"+ZCA_STATUS_DESCONSIDERADO+"') "+CRLF
		IF !(lReproc)
		cWhereZCA += " AND ZCA_STATUS <> '"+ZCA_STATUS_INCONSISTENCIA+"' "+CRLF
		ENDIF
		IF !EMPTY(cStatus)
		cWhereZCA += " AND ZCA_STATUS = '"+cStatus+"' "+CRLF
		ENDIF
	/*------------------------------------------------------ Augusto Ribeiro | 06/11/2017 - 10:48:45 AM
		Desconsidera registros da mesma DATA E HORA de processamento para evitar 
		unico razao de status.
	------------------------------------------------------------------------------------------*/
		IF !EMPTY(dDtProc)
		cWhereZCA += " AND NOT (ZCA_DTPROC = '"+DTOS(dDtProc)+"' AND ZCA_HRPROC = '"+cHrProc+"') "
		ENDIF
	cWhereZCA += " AND ZCA.ZCA_TPMOV = '"+ZCA_TPMOV_PAGAMENTO+"' "+CRLF
	cWhereZCA += " AND ZCA.D_E_L_E_T_ = '' "+CRLF
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 06/11/2017 - 9:33:40 AM
		Inconsistências para Analise
	------------------------------------------------------------------------------------------*/
		IF cCodRoteiro == RAZ_CONTA_NAO_LOCAZ
		
		cQuery := " SELECT ZCA.R_E_C_N_O_ AS ZCA_RECNO
		cQuery += " FROM "+RetSqlName("ZCA")+" ZCA WITH(NOLOCK) "+CRLF

		cQuery += cWhereZCA	 
		
		cQuery += " AND NOT EXISTS (SELECT 1 AS 'A' "+CRLF
		cQuery += " 				FROM "+RetSqlName("SA6")+" SA6 "+CRLF
		cQuery += " 				WHERE A6_COD = ZCA_BANCO "+CRLF
		cQuery += " 				AND A6_AGENCIA = ZCA_AGENC "+CRLF
		cQuery += " 				AND A6_XCONCAR = ZCA_CONTA "+CRLF
		cQuery += " 				AND SA6.D_E_L_E_T_ = '') "+CRLF
		
		ELSEIF cCodRoteiro == RAZ_NAO_LOCALIZADO
	
		cQuery := "  SELECT ZCA.R_E_C_N_O_ AS ZCA_RECNO "+CRLF
		cQuery += "  FROM "+RetSqlName("ZCA")+" ZCA WITH(NOLOCK)  "+CRLF
		
		cQuery += cWhereZCA
			
		cQuery += "  AND NOT EXISTS (SELECT 1 AS 'A' "+CRLF
		cQuery += " 				FROM "+RetSqlName("SE1")+" SE1 "+CRLF
		cQuery += " 				WHERE E1_XCODAUT = ZCA_CODAUT  "+CRLF
		 cQuery += " 				AND SE1.E1_EMISSAO >= ZCA_DTVEND "+CRLF
		cQuery += " 				AND SE1.D_E_L_E_T_ = '') "+CRLF

		ELSEIF cCodRoteiro == RAZ_PV_NAO_FATURADO
	
		cQuery := " SELECT ZCA.R_E_C_N_O_ AS ZCA_RECNO, Z7_FILIAL, Z7_PEDIDO "+CRLF
		cQuery += "  FROM "+RetSqlName("ZCA")+" ZCA WITH(NOLOCK)  "+CRLF		

		cQuery += " INNER JOIN "+RetSqlName("SZ7")+" SZ7 "+CRLF
		cQuery += " 	ON Z7_FORMA IN ('CC','CD') "+CRLF
		cQuery += " 	AND Z7_IDTRAN = ZCA_CODAUT "+CRLF
		cQuery += " 	AND Z7_PAGTO >= ZCA_DTVEND "+CRLF
		cQuery += " 	AND SZ7.D_E_L_E_T_ = '' "+CRLF		
		cQuery += " INNER JOIN "+RetSqlName("SC5")+" SC5 "+CRLF
		cQuery += " 	ON C5_FILIAL = Z7_FILIAL "+CRLF
		cQuery += " 	AND C5_NUM = Z7_PEDIDO "+CRLF
		cQuery += " 	AND C5_XBLQ <> '6' "+CRLF
		cQuery += " 	AND SC5.D_E_L_E_T_ = '' "+CRLF
		
		cQuery += cWhereZCA
		cQuery += " AND NOT EXISTS (SELECT 1 AS 'A' "+CRLF
		cQuery += " 				FROM "+RetSqlName("SD2")+" SD2 "+CRLF
		cQuery += " 				WHERE D2_FILIAL = Z7_FILIAL "+CRLF
		cQuery += " 				AND D2_PEDIDO = Z7_PEDIDO "+CRLF
		cQuery += " 				AND SD2.D_E_L_E_T_ = '')  "+CRLF
		
		ELSEIF cCodRoteiro == RAZ_DIF_PARCELA

		cQuery := " SELECT ZCA.R_E_C_N_O_ AS ZCA_RECNO, MIN(SE1.R_E_C_N_O_) as SE1_RECNO "+CRLF
		cQuery += "  FROM "+RetSqlName("ZCA")+" ZCA WITH(NOLOCK)  "+CRLF	

		cQuery += "  INNER JOIN "+RetSqlName("SE1")+" SE1  WITH(NOLOCK)  "+CRLF
		cQuery += "  	ON  SE1.E1_EMISSAO >= ZCA_DTVEND  "+CRLF
		cQuery += "  	AND SE1.E1_XCODAUT = ZCA_CODAUT  "+CRLF
		cQuery += " 	AND ((E1_XPARCAR = '' AND ZCA_QTDPAR > 1) "+CRLF
		cQuery += " 		OR "+CRLF
		cQuery += " 		(E1_XPARCAR <> '' AND ZCA_QTDPAR <= 1) "+CRLF
		cQuery += " 		OR "+CRLF
		cQuery += " 		(ZCA_STATUS IN  ('1','4')  AND E1_XPARCAR <> CASE WHEN ZCA_NUMPAC > 0 AND ZCA_QTDPAR > 1 THEN  RIGHT('000'+CONVERT(VARCHAR, ZCA_NUMPAC) ,3) ELSE '' END  ))  "+CRLF
		cQuery += "  	AND SE1.D_E_L_E_T_  =  ''   "+CRLF
		cQuery += cWhereZCA
		cQuery += " GROUP BY ZCA.R_E_C_N_O_ "+CRLF 
		cQuery += " ORDER BY 1 "
		
		ELSEIF cCodRoteiro == RAZ_NF_NAO_EMITIDA

		cQuery := " SELECT ZCA.R_E_C_N_O_ AS ZCA_RECNO, SE1.R_E_C_N_O_ as SE1_RECNO, F2_FILIAL, F2_SERIE, F2_DOC "+CRLF
		cQuery += "  FROM "+RetSqlName("ZCA")+" ZCA WITH(NOLOCK)  "+CRLF	

		cQuery += "  INNER JOIN "+RetSqlName("SE1")+" SE1  WITH(NOLOCK)  "+CRLF
		cQuery += "  	ON  SE1.E1_EMISSAO >= ZCA_DTVEND  "+CRLF
		cQuery += "  	AND SE1.E1_XCODAUT = ZCA_CODAUT  "+CRLF
		cQuery += " 	AND SE1.E1_XPARCAR = CASE WHEN ZCA_NUMPAC > 0 AND ZCA_QTDPAR > 1 THEN  RIGHT('000'+CONVERT(VARCHAR, ZCA_NUMPAC) ,3) ELSE '' END "+CRLF		
		cQuery += "  	AND SE1.D_E_L_E_T_  =  ''   "+CRLF
		/*--------------------------------------------------------------------------- Augusto Ribeiro | 20/06/2019 
			Adicionada regra para desconsiderar prefeituras com emissao off-line 
		------------------------------------------------------------------------------------------*/
		cQuery += "  	AND NOT EXISTS (SELECT 1 AS A  "+CRLF
		cQuery += "  						FROM "+RetSqlName("SZK")+" SZK "+CRLF
		cQuery += "  						WHERE ZK_CODIGO = '"+SM0->M0_CODIGO+"' "+CRLF
		cQuery += "  						AND ZK_CODFIL = SE1.E1_FILIAL "+CRLF
		cQuery += "  						AND ZK_NFSOFF =  '1' "+CRLF
		cQuery += "  						AND SZK.D_E_L_E_T_ = '') "+CRLF	
		
		cQuery += "  INNER JOIN "+RetSqlName("SF2")+" SF2  WITH(NOLOCK)  "+CRLF
		cQuery += "  	ON SF2.F2_FILIAL = SE1.E1_FILIAL "+CRLF
		cQuery += "  	AND SF2.F2_DOC = SE1.E1_NUM "+CRLF
		cQuery += "  	AND SF2.F2_SERIE = SE1.E1_PREFIXO "+CRLF
		cQuery += "  	AND ( "
		cQuery += "  SF2.F2_NFELETR = '' "+CRLF
			IF !EMPTY(cSerMot)
			cQuery += " AND SF2.F2_SERIE <> '"+cSerMot+"' "
			ENDIF
		cQuery += " ) "
		cQuery += "  	AND SF2.D_E_L_E_T_ = '' "+CRLF
		
		cQuery += cWhereZCA	
		ELSEIF cCodRoteiro == RAZ_MARCA

		cQuery := " SELECT ZCA.R_E_C_N_O_ AS ZCA_RECNO, A6_XCODMAR, E1_FILORIG
		cQuery += " FROM "+RetSqlName("ZCA")+" ZCA WITH(NOLOCK) "+CRLF

		cQuery += " INNER JOIN "+RetSqlName("SA6")+" SA6  WITH(NOLOCK)  "+CRLF
		cQuery += " ON A6_COD = ZCA_BANCO "+CRLF
		cQuery += " AND A6_AGENCIA = ZCA_AGENC "+CRLF
		cQuery += " AND A6_XCONCAR = ZCA_CONTA "+CRLF
		cQuery += " AND SA6.D_E_L_E_T_ = '' "+CRLF

		cQuery += "  INNER JOIN "+RetSqlName("SE1")+" SE1  WITH(NOLOCK)  "+CRLF
		cQuery += "  	ON  SE1.E1_EMISSAO >= ZCA_DTVEND  "+CRLF
		cQuery += "  	AND SE1.E1_XCODAUT = ZCA_CODAUT  "+CRLF
		cQuery += " 	AND SE1.E1_XPARCAR = CASE WHEN ZCA_NUMPAC > 0 AND ZCA_QTDPAR > 1 THEN  RIGHT('000'+CONVERT(VARCHAR, ZCA_NUMPAC) ,3) ELSE '' END "+CRLF		
		cQuery += "  	AND SE1.D_E_L_E_T_  =  ''   "+CRLF
		cQuery += "  	AND SE1.E1_FILORIG  NOT IN ( SELECT ZK_CODFIL FROM "+RetSqlName("SZK")+" SZK  WITH(NOLOCK) WHERE ZK_XCODMAR = SA6.A6_XCODMAR )   "+CRLF

		cQuery += cWhereZCA
		
		ENDIF
		IF !(ISBLIND())
		MemoWrite(GetTempPath(.T.) + "CP11000_qIncons_"+cCodRoteiro+".SQL", cQuery)
		ENDIF
		
	ENDIF



Return(cQuery)




/*/{Protheus.doc} GrvSTZCA
@author Augusto Ribeiro | www.compila.com.br
@since 06/11/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvSTZCA(nRecZCA, cStatus, cCodRazao, cLog, dDtProc, cHrProc)

	Default cLog		:= ""
	Default cCodRazao	:= ""


	DBSELECTAREA("ZCA")
	ZCA->(DBGOTO(nRecZCA))

	RECLOCK("ZCA",.F.)
	ZCA->ZCA_STATUS	:= cStatus
	ZCA->ZCA_CODRAZ	:= cCodRazao
	ZCA->ZCA_LOG	:= cLog
	IF !EMPTY(dDtProc)
		ZCA->ZCA_DTPROC	:= dDtProc
		ZCA->ZCA_HRPROC	:= cHrProc
	ELSE
		ZCA->ZCA_DTPROC	:= DATE()
		ZCA->ZCA_HRPROC	:= TIME()
	ENDIF

	MSUNLOCK()

Return()




/*/{Protheus.doc} CP11MVRA
Gera movimento RA com base no movimento unificado ZCA passado
@author Augusto Ribeiro | www.compila.com.br
@since 16/11/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP11MVRA(nRecZCA, cFilRA, cCodCli, cLoja)
	Local aRet		:= {.F., ""}
	Local cQuery	:= ""
	Local nI
	Local aRetRA	:= {}
	Local cBanco, cAgenc, cConta, cNumRA, aRetBco
	Local nVlrAjus, nVlrRA

	IF !EMPTY(nRecZCA) .AND.;
			!EMPTY(cFilRA) .AND.;
			!EMPTY(cCodCli) .AND.;
			!EMPTY(cLoja)


		DBSELECTAREA("ZCA")
		ZCA->(DBGOTO(nRecZCA))

		cNumRA		:= RIGHT(ALLTRIM(ZCA->ZCA_CODIGO), 9)
		aRetBco		:= U_CP11BCO(ZCA->ZCA_BANCO, ZCA->ZCA_AGENC, ZCA->ZCA_CONTA)
		IF LEN(aRetBco) > 0

			cBanco		:= aRetBco[1]
			cAgenc		:= aRetBco[2]
			cConta		:= aRetBco[3]

			nVlrAjus	:= ZCA->ZCA_SALDO - ZCA->ZCA_VBRUTO
			IF nVlrAjus >= -0.1 .AND. nVlrAjus <= 0.1
				nVlrAjus	:= ZCA->ZCA_SALDO-ZCA->ZCA_VLIQ
				nVlrRA		:= ZCA->ZCA_VLIQ
			ELSE
				nVlrAjus	:= round(((ZCA->ZCA_PTAXA/100)*ZCA->ZCA_SALDO),2)
				nVlrRA		:= ZCA->ZCA_SALDO-nVlrAjus
			ENDIF



			BEGIN TRANSACTION

				aRetRA	:= U_CP11RA(cFilRA, cNumRA, cCodCli, cLoja, nVlrRA, ZCA->ZCA_DTPAG, cBanco, cAgenc, cConta)

				IF aRetRA[1]

					DBSELECTAREA("SE1")
					SE1->(DBGOTO(aRetRA[3]))
					cChvTit	:= SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)

 			/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 11:37:13 AM
				Grava ZCB - Rastreabilidade de Mov. Unificado x Titulo
			------------------------------------------------------------------------------------------*/
			aDadoZCB	:= {}
			AADD(aDadoZCB, {"ZCB_CODMOV", ZCA->ZCA_CODIGO})
			AADD(aDadoZCB, {"ZCB_ALIAS",  "SE1"})
			AADD(aDadoZCB, {"ZCB_RECALI", SE1->(RECNO())})
			AADD(aDadoZCB, {"ZCB_INDALI", 1})
			AADD(aDadoZCB, {"ZCB_CHVALI", cChvTit})
			AADD(aDadoZCB, {"ZCB_VLRMOV", nVlrRA})
			AADD(aDadoZCB, {"ZCB_TPOPER", ZCB_TPOPER_BAIXA })
			AADD(aDadoZCB, {"ZCB_DTMOV",  ZCA->ZCA_DTPAG})
			AADD(aDadoZCB, {"ZCB_VAJUST", nVlrAjus})
			
			aRetAux	:= U_CPXGRV("ZCB", 1, aDadoZCB, .T., 3)
			
					IF aRetAux[1]
			
				/*--------------------------------
					Abate Saldo do Movimento
				---------------------------------*/
				RECLOCK("ZCA",.F.)
					ZCA->ZCA_SALDO	:= 0				
					ZCA->ZCA_LOG	:= ""
					ZCA->ZCA_STATUS	:= ZCA_STATUS_CONCLUIDO
					ZCA->ZCA_CODRAZ	:= ""
					ZCA->ZCA_DTPROC	:= DATE()
					ZCA->ZCA_HRPROC	:= TIME()				
				MSUNLOCK()	
				
				aRet[1]	:= .T.			
					ELSE
				DISARMTRANSACTION()
				aRet[2]	:= aRetAux[2]+"."//| Concatena ponto para evitar falso positivo carro erro venha vazio|
					ENDIF
 		
				ELSE
 			DisarmTransaction()
 			aRet[2] := aRetRA[2]+"." 			
				ENDIF
 		
			END TRANSACTION
 		
		ELSE
 	 	aRet[2] := "CONTA NAO LOCALIZADA NO CADASTRO DE BANCOS [E6_XCONCAR]"
		ENDIF
	ELSE
	aRet[2] := "Parametros inválidos. [CP11MVRA]"
	ENDIF
	
	
Return(aRet)



/*/{Protheus.doc} CP11RA
Inclui RA no Contas a Receber
@author Augusto Ribeiro | www.compila.com.br
@since 15/11/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP11RA(cFilRA, cNumRA, cCodCli, cLoja, nValor, dData, cBanco, cAgenc, cConta)
	Local aRet		:= {.F., "", 0}
	Local aTtAuto	:= {}
	Local dDataAnt	:= dDataBase
	Local _cFilNew, cPref, cNatRA
	Local cAutoLog, cMemo



	IF !EMPTY(cFilRA) .AND.;
			!EMPTY(cNumRA) .AND.;
			!EMPTY(cCodCli) .AND.;
			!EMPTY(cLoja) .AND.;
			!EMPTY(nValor) .AND.;
			!EMPTY(dData) .AND.;
			!EMPTY(cBanco) .AND.;
			!EMPTY(cAgenc) .AND.;
			!EMPTY(cConta)

		//| Normaliza para não dar erro na execauto|
		cBanco	:= PADR(alltrim(cBanco),TAMSX3("E1_PORTADO")[1])
		cAgenc	:= PADR(alltrim(cAgenc),TAMSX3("E1_AGEDEP")[1])
		cConta	:= PADR(alltrim(cConta),TAMSX3("E1_CONTA")[1])

	/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE 
	-----------------------------------------*/
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= xfilial("SE1")
	_cFilNew	:= PADR(cFilRA,12) //| CODIGO DA FILIAL DE DESTINO 
	
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
		ENDIF

	
	DBSELECTAREA("SE1")
	SE1->(DBSETORDER(1))
	SE1->(DBSEEK(CFILANT))
		IF LEN(ALLTRIM(cFilRA)) < 12
		cFilRA	:= SE1->E1_FILIAL
		ENDIF
	
	
	cPref		:= SUPERGETMV("CP11_RAPRE",.F.,"")
	cNatRA		:= SUPERGETMV("CP11_RANAT",.F.,"")

	dDataBase	:= dData
	
	AADD(aTtAuto , {"E1_FILIAL"		, cFilRA											, NIL})						
	AADD(aTtAuto , {"E1_PREFIXO"	, cPref												, NIL})
	AADD(aTtAuto , {"E1_NUM"    	, cNumRA											, NIL})	
	AADD(aTtAuto , {"E1_TIPO"   	, "RA"												, NIL})
	AADD(aTtAuto , {"E1_PORTADO"  	, cBanco											, NIL})
	AADD(aTtAuto , {"E1_AGEDEP"  	, cAgenc											, NIL})
	AADD(aTtAuto , {"E1_CONTA"  	, cConta											, NIL})	
	AADD(aTtAuto , {"E1_NATUREZ"	, cNatRA											, NIL})
	AADD(aTtAuto , {"E1_VENCTO" 	, DDATABASE											, NIL})
	AADD(aTtAuto , {"E1_VENCREA"	, DataValida(DDATABASE,.T.)							, NIL})
	AADD(aTtAuto , {"E1_VENCORI"	, DataValida(DDATABASE,.T.)							, NIL})
	AADD(aTtAuto , {"E1_EMISSAO"	, dDataBase											, NIL})
	AADD(aTtAuto , {"E1_EMIS1"		, dDataBase											, NIL})
	AADD(aTtAuto , {"E1_CLIENTE"	, cCodCli											, NIL})
	AADD(aTtAuto , {"E1_LOJA"   	, cLoja												, NIL})
	AADD(aTtAuto , {"E1_VALOR"  	, nValor											, NIL})

	//AADD(aTtAuto , {"E1_ORIGEM"  	, "AFIN081"			
	
	lMSHelpAuto := .T. //.F. // para nao mostrar os erro na tela
	lMSErroAuto := .F. //.F. // inicializa como falso, se voltar verdadeiro e' que deu erro

	MsExecAuto( { |x,y| FINA040(x,y)} , aTtAuto, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	
		If lMsErroAuto
		//MostraErro()
		cAutoLog	:= alltrim(NOMEAUTOLOG())

		cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
		cMemo := STRTRAN(cMemo,"'","")

		//| Apaga arquivo de Log
		Ferase(cAutoLog)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Le Log da Execauto e retorna mensagem amigavel ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet[2] := U_CPXERRO(cMemo)

			IF EMPTY(aRet[2])
			aRet[2]	:= alltrim(cMemo)
			ENDIF

		DisarmTransaction()		
		ELSE
		aRet[1] 	:= .T.
		aRet[3] 	:=  SE1->(RECNO())		
		ENDIF
	
	
	/*---------------------------------------
		Restaura FILIAL  
	-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)			 			
		ENDIF
	
	//| Restaura database |
	dDataBase	:= dDataAnt
	ELSE
	aRet[2]	:= "Parametros Invalidos [CP11GRA]"
	ENDIF

 
Return(aRet)


/*/{Protheus.doc} GetMarca
@author Julio Teixeira | www.compila.com.br
@since 14/05/2020
@version 12
@param cFilMarca - Filial atual
@return cMarca - Marca da filial corrente
/*/
User Function GetMarca(cFilMarca)

	Local aArea := GetArea()
	Local cMarca := ""

	Default cFilMarca := cFilAnt

	DbSelectArea("SZK")
	SZK->(DbSetOrder(1))

	If SZK->(MsSeek(cEmpAnt+cFilMarca))
		cMarca := SZK->ZK_XCODMAR
	Endif

	RestArea(aArea)

Return cMarca


/*/{Protheus.doc} getTrans
	Busca títulos com o mesmo código de autorização
	@type  Static Function
	@author Julio Teixeira
	@since 20/05/2020
	@version 12
	@param Recno SE1, 
	@return aRet {Recno, Diferença}
/*/
Static Function getTrans(nRec, nDif)

	Local cQuery := ""
	Local cAliasTmp := GetNextAlias()
	Local aRet := {}
	Local aArea := GetArea()
	Local nSoma := 0

	Default nRec := 0
	Default nDif := 0

	If nRec > 0
		DbSelectArea("SE1")
		SE1->(DbGoTo(nRec))

		cQuery := " SELECT R_E_C_N_O_ E1_RECNO, E1_SALDO "
		cQuery += " FROM "+RetSqlName("SE1")+" SE1"
		cQuery += " WHERE  D_E_L_E_T_ = '' "
		cQuery += " AND E1_XPARCAR = '"+SE1->E1_XPARCAR+"' "
		cQuery += " AND E1_XBAND = '"+SE1->E1_XBAND+"' "
		cQuery += " AND E1_XCODAUT = '"+SE1->E1_XCODAUT+"' "
		cQuery += " AND E1_SALDO > 0 "

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.F.)

		//Posiciona no inicio do arquivo temporario
		(cAliasTmp)->(dbGoTop())

		While (cAliasTmp)->(!EOF())
			nSoma += (cAliasTmp)->E1_SALDO
			aAdd(aRet,{(cAliasTmp)->E1_RECNO, 0})
			(cAliasTmp)->(DbSkip())
		Enddo

		If (nSoma > nDif+SE1->E1_SALDO .OR. nSoma == SE1->E1_SALDO) .AND. nSoma != (SE1->E1_SALDO + nDif)
			aRet := {{nRec, nDif}}
		Endif
	Else
		aRet := {{nRec, nDif}}
	Endif

	RestArea(aArea)

Return aClone(aRet)

Static Function CP11ErrFor(e)
	Local cMessage := e:Description

	aRetAux := { .F. , cMessage }
	Break

Return
