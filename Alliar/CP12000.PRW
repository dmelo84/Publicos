#INCLUDE "TOTVS.CH" 
#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE "TBICONN.CH" 


/*------------------------------------------------------ Augusto Ribeiro | 18/10/2017 - 4:12:48 PM
	SEMAFORO
------------------------------------------------------------------------------------------*/
#DEFINE NOME_SEMAFORO "CP12000_"

/*--------------------------------------------------
	STATUS ZD1
---------------------------------------------------*/
#DEFINE ZD1_STATUS_PENDENTE			"1"
#DEFINE ZD1_STATUS_DEPENDENCIA		"2"
#DEFINE ZD1_STATUS_PROCESSADO		"3"
#DEFINE ZD1_STATUS_FALHA			"4"
#DEFINE ZD1_STATUS_DESCONSIDERADO	"5"

#DEFINE N_DIAS_PROC_DEPENDENCIA 	10 //| Numero de dias que rotina tentara processar dependencias |

/*/{Protheus.doc} CP12ADD
Adiciona registros na Fila de Processamento
@author Augusto Ribeiro | www.compila.com.br
@since 13/12/2017
@version version
@param param
@return aRet		:= {.F., cMsgErro, aCodFila ZD1}
@example
(examples)
@see (links_or_references)
/*/
User Function CP12ADD(cCodConf, cAliReg, nRecReg, cDados, cCodDep, cCodTip, cIdInt )
Local aRet		:= {.F., "", {}}
Local aCodConf	:= {}
Local nI, nY, aDadosInc
Local nTotCpo	:= ZD1->(FCOUNT()) 


Default	cAliReg	:= ""
Default nRecReg	:= 0
Default cCodDep	:= ""
Default cCodTip	:= ""
Default cIdInt	:= ""

IF !EMPTY(cCodConf)
	
	DBSELECTAREA("ZD2")
	ZD2->(DBSETORDER(1)) //| 
	IF ZD2->(DBSEEK(xfilial("ZD2")+cCodConf))
	 	IF ZD2->ZD2_MSBLQL <> "1"
	 		aadd(aCodConf, {ZD2->ZD2_CODIGO,ZD2->ZD2_CODFIL})
	 	ENDIF
	ENDIF

ELSEIF !EMPTY(cAliReg)

	cAliReg	:= ALLTRIM(UPPER(cAliReg))
	
	DBSELECTAREA("ZD2")
	ZD2->(DBSETORDER(2)) //| ZD2_FILIAL+ZD2_ALIAS+ZD2_CODIGO                                                                                                                                 
	IF ZD2->(DBSEEK(xfilial("ZD2")+cAliReg))
 
		WHILE ZD2->(!EOF()) .AND. ZD2->ZD2_ALIAS == cAliReg
		
		 	IF ZD2->ZD2_MSBLQL <> "1"
		 		aadd(aCodConf, {ZD2->ZD2_CODIGO,ZD2->ZD2_CODFIL})
		 	ENDIF
		 	ZD2->(DBSKIP())
	 	ENDDO
	ENDIF	

ENDIF


DBSELECTAREA("ZD1")
FOR nY := 1 to len (aCodConf)
	
	RegToMemory("ZD1", .T., .F.)
	ZD1->(CONFIRMSX8())
	
	RecLock("ZD1", .T.)
	
	M->ZD1_CODCON	:= aCodConf[nY,1]
	M->ZD1_CODFIL	:= aCodConf[nY,2]
	M->ZD1_ALIAS	:= cAliReg
	M->ZD1_RECALI	:= nRecReg
	IF !EMPTY(cDados)
		M->ZD1_DADOS	:= cDados
	ENDIF
	M->ZD1_CODDEP	:= cCodDep
	
	IF !EMPTY(cCodTip)
		M->ZD1_TIPO	:= cCodTip
	ENDIF 
	
	IF !EMPTY(cIdInt)
		M->ZD1_IDINTE	:= cIdInt
	ENDIF 
	
	For nI := 1 To nTotCpo
		cNameCpo	:= ALLTRIM(ZD1->(FIELDNAME(nI)))
		FieldPut(nI, M->&(cNameCpo) )
	Next nI
	
	ZD1->(MsUnLock())		
	
	aRet[1]		:= .T.
	AADD(aRet[3],ZD1->ZD1_CODIGO)

NEXT nY

 

Return(aRet)



/*/{Protheus.doc} CP12PJOB
Processamento da Fila via JOB.
@author Augusto Ribeiro | www.compila.com.br
@since 15/12/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP12PJOB(aParam)
Local aRet			:= {.F., ""}
Local cQuery		:= ""
Local nI, _cEmp, _cFilial
Local lProcFalha	:= .F.

Default aParam	:= {"01","00101MG0001"}


IF !empty(aParam)
	_cEmp		:= aParam[1]
	_cFilial	:= aParam[2]
	IF LEN(aParam) >= 3
		lProcFalha	:= aParam[3]
	ENDIF
	
	
	
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
	
	 	U_CP12ALL(lProcFalha)

	RESET ENVIRONMENT
ELSE
	//CONOUT("### CP12PJOB: Parametros inválidos")
ENDIF
	
Return(aRet)



/*/{Protheus.doc} CP12ALL
Processa todas as filas
@author Augusto Ribeiro | www.compila.com.br
@since 14/12/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP12ALL(lProcFalha)
Local aRet		:= {.F., ""}
Local cQuery	:= ""
Local nI
Local cSemaf, nHSemafaro

Default lProcFalha	:= .F.


DBSELECTAREA("ZD3")


DBSELECTAREA("ZD3")
ZD3->(DBSETORDER(1)) //| 

WHILE ZD3->(!EOF())
	
	IF ZD3->ZD3_MSBLQL <> "1"
	
		cSemaf	:= "CP12ALL_"+ZD3->ZD3_CODIGO
		
		/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
			Abre semaforo de Processamento
		------------------------------------------------------------------------------------------*/
		nHSemafaro	:= U_CPXSEMAF("A", cSemaf)
		
		
		IF nHSemafaro > 0
		
		
			//| Limpa Registros |
			U_CP12LIMP(ZD3->ZD3_CODIGO)
			
			//| Processa fila |
			U_CP12PROC(ZD3->ZD3_CODIGO, , , lProcFalha)
	
			/*--------------------------
			FECHA SEMAFORO
			---------------------------*/
			U_CPXSEMAF("F", cSemaf,nHSemafaro)	
			
			aRet[1]	:= .T.			
		ELSE
			aRet[2]	:= "Não foi possivel abrir o semaforo["+cSemaf+"]"
		ENDIF	
	ENDIF


	ZD3->(DBSKIP()) 
ENDDO
	
	
Return(aRet)



/*/{Protheus.doc} CP12LIMP
Limpa lixo dos registros configurados para integrar somente o mais recente
@author Augusto Ribeiro | www.compila.com.br
@since 13/12/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP12LIMP(cCodFil, cCodConf)
Local aRet		:= {.F., ""}
Local cQuery	:= ""
Local nI
Local cConf, cAliReg, nRecAli
Local cSemaf, nHSemafaro

IF !EMPTY(cCodFil)

	cSemaf	:= "CP12LIMP_"+cCodFil

	/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
		Abre semaforo de Processamento
	------------------------------------------------------------------------------------------*/
	nHSemafaro	:= U_CPXSEMAF("A", cSemaf)
	
	
	IF nHSemafaro > 0

		cQuery := " SELECT ZD1_CODCON, ZD1_ALIAS, ZD1_RECALI, ZD1.R_E_C_N_O_ as ZD1_RECNO "+CRLF
		cQuery += " FROM "+RetSqlName("ZD1")+" ZD1 WITH(NOLOCK) "+CRLF
		cQuery += " INNER JOIN "+RetSqlName("ZD2")+" ZD2 WITH(NOLOCK) "+CRLF
		cQuery += " 	ON ZD1.ZD1_FILIAL = ZD2.ZD2_FILIAL "+CRLF
		IF !EMPTY(cCodConf)
			cQuery += " 	AND ZD2.ZD2_CODIGO = '"+cCodConf+"' "+CRLF
		ENDIF
		cQuery += " 	AND ZD1.ZD1_CODCON = ZD2.ZD2_CODIGO "+CRLF
		cQuery += " 	AND ZD2.ZD2_MSBLQL <> '1' "+CRLF
		cQuery += " 	AND ZD2.ZD2_INTEG = '1' "+CRLF
		cQuery += " 	AND ZD2.ZD2_SEQINT = '2' "+CRLF
		cQuery += " 	AND ZD2.D_E_L_E_T_ = '' "+CRLF
		cQuery += " WHERE ZD1.ZD1_CODFIL = '"+cCodFil+"' "+CRLF
		cQuery += " AND ZD1.ZD1_STATUS <> '"+ZD1_STATUS_PROCESSADO+"' "+CRLF
		cQuery += " AND ZD1.D_E_L_E_T_ = '' "+CRLF
		cQuery += " ORDER BY 1,2,3,4 DESC"+CRLF
		
		If Select("TSQL") > 0
			TSQL->(DbCloseArea())
		EndIf
		
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						
		
		cConf	:= ""
		cAliReg	:= ""
		nRecAli	:= ""
		WHILE TSQL->(!EOF())
		
			IF cConf == TSQL->ZD1_CODCON .AND.;
				cAliReg == TSQL->ZD1_ALIAS .AND.;
				nRecAli == TSQL->ZD1_RECALI
	
				//| Atualiza Status ZD1 |
				UpdStZD1(TSQL->ZD1_RECNO, ZD1_STATUS_DESCONSIDERADO, "Registro obsoleto.")
				
			ELSE					
				cConf	:= TSQL->ZD1_CODCON
				cAliReg	:= TSQL->ZD1_ALIAS
				nRecAli	:= TSQL->ZD1_RECALI		
			ENDIF
					
			
			TSQL->(DBSKIP()) 
		ENDDO	
	
		TSQL->(DbCloseArea())
		
		/*--------------------------
		FECHA SEMAFORO
		---------------------------*/
		U_CPXSEMAF("F", cSemaf,nHSemafaro)				
	ELSE
		aRet[2]	:= "Não foi possivel abrir o semaforo["+cSemaf+"]"
	ENDIF		
	
ELSE
	aRet[2] := "Parametros Inválidos [CP12LIMP]"
ENDIF

	
Return(aRet)




/*/{Protheus.doc} CP12PROC
Processa registro da Fila
@author Augusto Ribeiro | www.compila.com.br
@since 13/12/2017
@version 6
@param cFila, Codigo Fila de Processamento
@param cCodConf, Codigo de configuração
@param cCodFila, Codigo do registro unico da Fila de processamento
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP12PROC(cFila, cCodConf, cCodFila, lProcFalha)
Local aRet			:= {.F., ""}
Local cQuery		:= ""
Local nI, cStatus
Local cLog			:= ""
LOCAL nCount		:= 0
Local cSemaf, nHSemafaro, cCodDep
Local cCoringa		:= ALLTRIM(GETMV("CP12_SMPRO",.F.,"")) //| Coringa para altera nome do semafora caso o mesmo fique preso.| 
Local lEBlock		:= .F.
Local oErro 		:= ErrorBlock({|e| DisarmTransaction() ,lEBlock := .T., cLog := IIF(VALTYPE(e:Description)=="C", e:Description,"[CP12PROC] Falha na execucao da funcao cadastrada no configurador da fila") })


Default lProcFalha	:= .F.



IF !EMPTY(cFila)

	cSemaf	:= "CP12PROC_"+cFila+cCoringa

	/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
		Abre semaforo de Processamento
	------------------------------------------------------------------------------------------*/
	nHSemafaro	:= U_CPXSEMAF("A", cSemaf)
	
	
	IF nHSemafaro > 0

		cQuery := " SELECT ZD1.R_E_C_N_O_ AS ZD1_RECNO, ZD2.ZD2_FUNCAO "+CRLF
		cQuery += " FROM "+RetSqlName("ZD1")+" ZD1 WITH(NOLOCK) "+CRLF
		cQuery += " INNER JOIN "+RetSqlName("ZD2")+" ZD2 WITH(NOLOCK) "+CRLF
		cQuery += " 	ON ZD1.ZD1_FILIAL = ZD2.ZD2_FILIAL "+CRLF
		cQuery += " 	AND ZD1.ZD1_CODCON = ZD2.ZD2_CODIGO "+CRLF
		IF !EMPTY(cCodConf)
			cQuery += " 	AND ZD2.ZD2_CODIGO = '"+cCodConf+"' "+CRLF
		ENDIF	
		cQuery += " 	AND ZD2.ZD2_MSBLQL <> '1' "+CRLF
		cQuery += " 	AND ZD2.ZD2_INTEG = '1' "+CRLF
		cQuery += " 	AND ZD2.ZD2_FUNCAO  <> '' "+CRLF
		cQuery += " 	AND ZD2.D_E_L_E_T_ = '' "+CRLF
		cQuery += " WHERE ZD1.ZD1_CODFIL = '"+cFila+"' "+CRLF
		
		/*------------------------------------------------------ Augusto Ribeiro | 13/12/2017 - 7:15:43 PM
			Quando informado o codigo exato do registro, desconsidera status, e não processa
			somente caso ele ja esteja concluido.
		------------------------------------------------------------------------------------------*/
		IF !EMPTY(cCodFila)
			cQuery += " AND ZD1.ZD1_CODIGO = '"+cCodFila+"' "+CRLF
			cQuery += " AND ZD1.ZD1_STATUS <> '"+ZD1_STATUS_PROCESSADO+"' "+CRLF	
		ELSE
			IF lProcFalha
				cQuery += " AND ZD1.ZD1_STATUS IN ('"+ZD1_STATUS_FALHA+"') "+CRLF	
			ELSE
				//cQuery += " AND ZD1.ZD1_STATUS IN ('"+ZD1_STATUS_PENDENTE+"','"+ZD1_STATUS_DEPENDENCIA+"') "+CRLF
				cQuery += " AND ( ( ZD1.ZD1_STATUS = '"+ZD1_STATUS_PENDENTE+"' "
				cQuery += " 		OR (ZD1.ZD1_STATUS = '"+ZD1_STATUS_DEPENDENCIA+"' AND ZD1_DTREG >= '"+DTOS(DDATABASE-N_DIAS_PROC_DEPENDENCIA)+"') )"+CRLF
				cQuery += " 	OR (ZD1.ZD1_STATUS = '"+ZD1_STATUS_FALHA+"' AND ZD2.ZD2_QTDTEN > 0  AND ZD2.ZD2_QTDTEN > ZD1.ZD1_QTDTEN)  )"+CRLF	
			ENDIF
		ENDIF
		cQuery += " AND ZD1.D_E_L_E_T_ = '' "+CRLF
		cQuery += " ORDER BY ZD1_CODIGO "+CRLF
	
	
		
		If Select("TFILA") > 0
			TFILA->(DbCloseArea())
		EndIf
		
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TFILA",.F., .T.)						
		
		IF !(ISBLIND())
			TFILA->(DBGoTop())	
			TFILA->( dbEval( {|| nCount++ } ) )	
			TFILA->(DBGoTop())
			
			ProcRegua(nCount)			
		ENDIF
		
		DBSELECTAREA("ZD1")
		WHILE TFILA->(!EOF())
			incProc("Processando... ")
			cStatus	:= ZD1_STATUS_FALHA
			cLog	:= ""
			 lEBlock	:= .F.
			
			ZD1->(DBGOTO(TFILA->ZD1_RECNO))
			nRecZD1	:= TFILA->ZD1_RECNO
			
			
			IF ZD1->ZD1_STATUS <> ZD1_STATUS_PROCESSADO
			
			
				/*------------------------------------------------------ Augusto Ribeiro | 15/12/2017 - 11:01:10 AM
					Valida se dependencia foi processada com sucesso
				------------------------------------------------------------------------------------------*/
				IF !EMPTY(ZD1->ZD1_CODDEP)
					cCodDep		:= ZD1->ZD1_CODDEP
					ZD1->(DBSETORDER(1)) //| 
					IF ZD1->(DBSEEK(xfilial("ZD1")+ZD1->ZD1_CODDEP)) 
						IF ZD1->ZD1_STATUS <> ZD1_STATUS_PROCESSADO
							cLog	:= "Aguardando processamento do registro ["+cCodDep+"]"
							cStatus	:= ZD1_STATUS_DEPENDENCIA
						ENDIF						
					ENDIF
					
					// Retorna para registro posicionado no Loop
					ZD1->(DBGOTO(nRecZD1))
				ENDIF			
			
				IF EMPTY(cLog)
				
					BEGIN SEQUENCE 
					
					aRetAux	:= &(alltrim(TFILA->ZD2_FUNCAO))
					
					IF !(lEBlock) 
					
						IF VALTYPE(aRetAux) == "A"
							IF LEN(aRetAux) >= 2
								IF VALTYPE(aRetAux[1]) == "L"
									
									IF aRetAux[1] 
										cStatus	:= ZD1_STATUS_PROCESSADO	
													
									ELSE
										IF VALTYPE( aRetAux[2] ) == "C"
											cLog	:= ALLTRIM(aRetAux[2])
										ELSE
											cLog	:= "Erro indeterminado. Não foi retornado log pela rotina  ["+alltrim(TFILA->ZD2_FUNCAO)+"]."						
										ENDIF 
									ENDIF					
								ELSE
									cLog	:= "Retorno invalido, primeira posicao do retorno deve ser logico ["+alltrim(TFILA->ZD2_FUNCAO)+"]. Verifique o configurador de Fila do Integrador"
								ENDIF
							ELSE
								cLog	:= "Retorno invalido, array inferior a 2 posicoes ["+alltrim(TFILA->ZD2_FUNCAO)+"]. Verifique o configurador de Fila do Integrador"
							ENDIF
						ELSE
							cLog	:= "Retorno invalido da funcao ["+alltrim(TFILA->ZD2_FUNCAO)+"]. Verifique o configurador de Fila do Integrador"
						ENDIF
					ENDIF
					
					END SEQUENCE				
	
				ENDIF
				
				
				/*--------------------------
					Atualiza status da fila
				---------------------------*/
				UpdStZD1(TFILA->ZD1_RECNO, cStatus, cLog)
				
				
				TFILA->(DBSKIP())
			ELSE
				//CONOUT("Já processado ["+ZD1->ZD1_CODIGO+"]")
			ENDIF
		ENDDO	
		//| ErrorBlock Deve ficar fora do Loop |
		ErrorBlock(oErro)		
	
		TFILA->(DbCloseArea())
		/*--------------------------
		FECHA SEMAFORO
		---------------------------*/
		U_CPXSEMAF("F", cSemaf,nHSemafaro)				
	ELSE
		aRet[2]	:= "Não foi possivel abrir o semaforo["+cSemaf+"]"
	ENDIF

ELSE
	aRet[2] := "Parametros Inválidos [CP12PROC]"
ENDIF

aRet[2]	+= cLog

IF EMPTY(aRet[2])
	aRet[1]	:= .T.
ELSE
	//CONOUT("CP12PROC",aRet[2])
ENDIF

	
Return(aRet)




/*/{Protheus.doc} UpdStZD1
Altera Status da ZD1
@author Augusto Ribeiro | www.compila.com.br
@since 13/12/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function UpdStZD1(nRecZD1, cStatus, cLog)
Local aRet		:= {.F., ""}

IF !EMPTY(nRecZD1)

	DBSELECTAREA("ZD1")
	ZD1->(DBGOTO(nRecZD1))
	RECLOCK("ZD1",.F.)
		
		ZD1->ZD1_STATUS := cStatus
		ZD1->ZD1_DTPRO	:= DATE()
		ZD1->ZD1_HRPRO	:= TIME()
		IF !EMPTY(cLog)
			ZD1->ZD1_LOG	:= cLog
		ELSEIF !EMPTY(ZD1->ZD1_LOG)
			ZD1->ZD1_LOG	:= ""
		ENDIF
		
		IF cStatus == ZD1_STATUS_FALHA
			ZD1->ZD1_QTDTEN	:= ZD1->ZD1_QTDTEN+1
		ENDIF
		
	MSUNLOCK()
ELSE
	aRet[2] := "Parametros Inválidos [UpdStZD1]"
ENDIF


Return(aRet)


/*/{Protheus.doc} CP12W2D
Integrador generido de WS Rest
Define funcao que sera chamada para integracao
@author Augusto Ribeiro
@since 16/03/2018
@version 6
@example
(examples)
@see (links_or_references)
/*/

User Function CP12W2D(cJson)

	Local nStCode	:= 400
	Local cMsgRet	:= ""
	Local cIdRet	:= ""
	Local cCusRet	:= ""	
	Local cEmpJs	:= ""
	Local cFilJs	:= ""
	Local cTabJs	:= ""
	Local cSisJs	:= ""
	Local cOperJs	:= ""
	Local alCabec	:= {}
	Local alJSCabec	:= {}
	Local alItens	:= {}
	Local alJSItens	:= {}
		
	Local nOption	:= 0
	Local alRet		:= {.F.,"",""}	
	Local nI, oJson	//, oJsnCbc	
	Local oErro 	:= ErrorBlock({|e| DisarmTransaction(), lError := .T.,cMsgRet := "[WSRMEDGR e] "+IIF(VALTYPE(e:Description)=="C", e:Description,"Falha na execucao ")+CRLF+"ERROR STACK"+IIF(VALTYPE(e:Description)=="C",e:ERRORSTACK,"")  })	
	
	Local nX3TIPO   := SX3->(FIELDPOS("X3_TIPO"))
	
	Default cJson	:= ""	

	BEGIN SEQUENCE 
	
	IF !EMPTY(cJson)	
		
		IF FWJsonDeserialize(cJson,@oJson)
			
			//| Bloco de validação dos campos 
			
			IF AttIsMemberOf(oJson, "EMP")
				cEmpJs	:= oJson:EMP
			ENDIF
			
			IF AttIsMemberOf(oJson, "FILIAL")
				cFilJs	:= oJson:FILIAL
			ENDIF
			 
			IF AttIsMemberOf(oJson, "TABELA")
				cTabJs	:= oJson:TABELA
			ENDIF
			
			IF AttIsMemberOf(oJson, "SISTEMA")
				cSisJs	:= oJson:SISTEMA
			ENDIF
			
			IF AttIsMemberOf(oJson, "OPERACAO")
				cOperJs	:= oJson:OPERACAO
			ENDIF											
			
			IF !Empty(cEmpJs) .AND. !Empty(cFilJs) .AND. !Empty(cTabJs) .AND. !Empty(cSisJs) .AND. !Empty(cOperJs)
				
				IF AttIsMemberOf(oJson, "CABEC")
//					oJsnCbc := oJson:cabec
														
					alCabec := ClassDataArr(oJson:cabec)					
//					alCabec := oJson:cabec				
					
					IF LEN(alCabec) > 0	
					
						//| Ordeno o Array pelo o ID do Jason.
						
						ASORT(alCabec, , , { | x,y | x[3] < y[3] } )
						
						//| Alimentanto e validando os dados que serão enviados aos Execauto.										
																	
						For nI := 1 to LEN(alCabec)
																																								
							//| Tratativa para os campos de data.
							
							DBSELECTAREA("SX3")
							SX3->(DBSETORDER(2)) //|X3_CAMPO
							
							IF SX3->(DBSEEK(alCabec[nI,1]))
								
								IF SX3->(FIELDGET(nX3TIPO)) == "D" .AND. VALTYPE(alCabec[nI,2]) <> "D"
									
									alCabec[nI,2]:= STOD(alCabec[nI,2])
								
								ENDIF
								
							ENDIF								
							
							AADD(alJSCabec,{alCabec[nI,1],alCabec[nI,2],Nil})
							
						NEXT nI
						
						//| Verica se o Json possui itens.
						
						IF AttIsMemberOf(oJson, "ITENS")
							
							IF valtype(oJson:itens) == "A"								
								
								//| Organizo as informações do array.
								
								For nJ := 1 To Len(oJson:itens)
																																									
									AADD(alItens,ClassDataArr(oJson:itens[nJ]))
									
									ASORT(alItens[nJ], , , { | x,y | x[3] < y[3] } ) //| Ordena pela 3° posição do Array que se refere ao ID do Json.
																		
									//| Adapta o Array para a ExecAuto.
									
									nH := 0
									
									For nH := 1 To Len(alItens[nJ])
									
										alItens[nJ][nH][3]:= Nil 
										
										DBSELECTAREA("SX3")
										SX3->(DBSETORDER(2)) //|X3_CAMPO
										
										IF SX3->(DBSEEK(alItens[nJ][nH][1]))
											
											IF SX3->(FIELDGET(nX3TIPO)) == "D" .AND. VALTYPE(alItens[nJ][nH][2]) <> "D"
												
												alItens[nJ][nH][2]:= STOD(alItens[nJ][nH][2])
											
											ENDIF
											
										ENDIF								
										
										
									Next nH
																		
									AADD(alJSItens,alItens[nJ])
																																																																																			
								Next nJ																						
																																												
							ENDIF
													
						ENDIF
						
						
						IF LEN(alJSCabec) > 0
																		
							IF cSisJs == "GESPLAN" 							
							
								IF cTabJs $ "SE1|SE2" //| Contas a Receber e a pagar respectivamente.
																																												
									alRet := U_CP12004A(cTabJs,alJSCabec,cOperJs,cFilJs)
									
								ELSEIF cTabJs == "SZD" //| Entidade contábil custtomizada
									
									alRet := U_CP12004B(cTabJs,alJSCabec,alJSItens,cOperJs,cFilJs)
									
								ELSE												
									alRet[2]:= "Tabela não implementada. [CP12W2D]"
								ENDIF
								
							ELSEIF cSisJs == "FLUIG"
								IF cTabJs == "SE2" //| Contas a pagar
									
									alRet := U_CP12004C(cTabJs,alJSCabec,cOperJs,cFilJs)
									
								/*
									{
									    "EMP":"01",
									    "FILIAL":"00101MG0001",
									    "TABELA":"SE2",
									    "SISTEMA":"FLUIG",
									    "OPERACAO":"I",
									    "CABEC":{
									        "E2_FILIAL": "00101MG0001",
									        "E2_FORNECE": "09022249",
									        "E2_LOJA": "0001",
									        "E2_TIPO":"NF",
									        "E2_VALOR":  200.00,
									        "E2_VENCTO": "20181228",
									        "E2_NUM": "08121850",
									        "E2_CCUSTO": "90101",
									        "E2_HIST": "TESTES",
									        "E2_XIDFLG":"101",
									        "RATEIO_NATUREZA":[
									            {
									                "EV_NATUREZ":"21010031",
									                "EV_VALOR":20.00,
									                "EV_PERC":10
									            },
									            {
									                "EV_NATUREZ":"21010032",
									                "EV_VALOR":180.00,
									                "EV_PERC":90
									            }        
									        ]        
									    }
									}								
								*/
									
									
								 
								ELSE												
									alRet[2]:= "Tabela não implementada. [CP12W2D]"								 
								ENDIF								
							ELSE															
								alRet[2]:= "Sistema não definido. [CP12W2D]"																						
							ENDIF
																				
							/* ---------------Tratativas de retorno ---------------							
								alRet[1] - .T. Sucesso, .F. Falha 
								alRet[2] - Mensagem do erro em caso de falha
								alRet[3] - Chave da tabela inserida.
							-----------------------------------------------------*/
							
							IF alRet[1] //| Se Obteve Sucesso na Operação.
							
								nStCode	:= 200							
								cIdRet	:= alRet[3]									
								
							ELSE
							
								cMsgRet	:= alRet[2]	
								
							ENDIF
							
						ENDIF												
					
					ELSE
					
						cMsgRet:= "Cabeçalho vazio.[CP12W2D]"
						
					ENDIF
																												
				ELSE
					
					cMsgRet:= "Cabeçalho inexistente. [CP12W2D]"
				
				ENDIF
				
			ELSE
				
				cMsgRet:= "Empresa, Filial, Tabela, systema e Operação nçao pode esta vazio. [CP12W2D]"
				
			ENDIF
			
		ELSE
		
			cMsgRet:= "Não foi poossível desserializar o objeto. [CP12W2D]"
					
		ENDIF
		
	ELSE
	
		cMsgRet:= "Parâmetro Vazio, não contém dados de Json. [CP12W2D]"
		
	ENDIF
	
	END SEQUENCE

	ErrorBlock(oErro)
	
	//| Quando for sucesso, Limpo a mensagem, pois percebi que mesmo com o ErrorBlock 
	//| o programa continua com a operação.
	
	IF nStCode==200
		cMsgRet := ""
	ENDIF	
			
	aRet	:= {nStCode, cMsgRet, cIdRet, cCusRet}
	
Return(aRet)





/*/{Protheus.doc} CP12W2G
Funcao generica para retorno de dados enviados via GET
@author Augusto Ribeiro | www.compila.com.br
@since 18/12/2018
@version undefined
@param param
@return aRet, {lRet, cMsgErro, cJsonRet}
@example
(examples)
@see (links_or_references)
/*/
User Function CP12W2G(cOpcao, aParam)
Local aRet		:= {.f.,"",""}
Local cJsonRet	:= ""
Local nErro		:= 0


IF !EMPTY(cOpcao)

	cOpcao	:= UPPER(ALLTRIM(cOpcao))
	IF cOpcao == "COND_PGTO"

		IF !EMPTY(aParam[1]) .AND. !EMPTY(aParam[2])
		
			aRetAux	:= CONDICAO(val(aParam[1]), aParam[2])
			IF LEN(aRetAux) > 0
				
				cJsonRet	:= "["
			
				FOR nI := 1 to len(aRetAux)
					IF nI > 1
						cJsonRet	+= ","
					ENDIF
					
					cJsonRet += "{"
					cJsonRet += U_cpxToJson("PARC", STRZERO(nI,3))+","
					cJsonRet += U_cpxToJson("VENCTO", aRetAux[nI,1])+","
					cJsonRet += U_cpxToJson("VALOR", aRetAux[nI,2])
					cJsonRet += "}"				
				NEXT nI
				cJsonRet	+= "]"
				
				
				aRet[1]	:= .T.
				aRet[3]	:= cJsonRet
			ENDIF			
			
		ELSE
			aRet[2] :=  "["+cOpcao+"] parametros invalidos "
		ENDIF
	ELSE
		aRet[2] := "Opcao ["+cOpcao+"] nao implementada "
	ENDIF
ELSE
	aRet[2] := "Parametro ROTINA, nao localizado "

ENDIF


Return(aRet)

/*/{Protheus.doc} CP12LFIL
	job que realiza limpeza da fila de integração excluindo os registros de acordo com a quantidade de dias informado no campo ZD2_QDIAEX
	@type User Function
	@author Julio Teixeira - Compila
	@since 12/06/2020
	@version 12
/*/
User Function CP12LFIL(aParam)

Local _cEmp
Local _cFilial

Default aParam	:= {"01","00101MG0001"}

IF !empty(aParam)
	_cEmp		:= aParam[1]
	_cFilial	:= aParam[2]
	
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
	
	 	LimpaFila()

	RESET ENVIRONMENT
ENDIF
	
Return 

/*/{Protheus.doc} LimpaFila
	
	Realiza delete nos registros vencidos de acordo com a quantidade de dias informado no campo ZD2_QDIAEX

	@type  Static Function
	@author Julio Teixeira - Compila
	@since 12/06/2020
	@version 12
	@return aRet
/*/
Static Function LimpaFila()

Local cAliasQry := ""
Local cAlias := GetNextAlias()
Local aArea := GetArea()
Local aAreaZD1 := ZD1->(GetArea())

cAliasQry := " SELECT ZD1.R_E_C_N_O_ ZD1_RECNO, ZD2_QDIAEX, ZD1_DTREG FROM "+RetSqlName("ZD1")+" ZD1 "
cAliasQry += " INNER JOIN "+RetSqlName("ZD2")+" ZD2  ON ZD1_CODCON = ZD2_CODIGO AND ZD1.D_E_L_E_T_ = '' AND ZD2_QDIAEX > 0 " 
cAliasQry += " WHERE ZD1.D_E_L_E_T_ = '' "

cAliasQry := ChangeQuery(cAliasQry)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cAliasQry),cAlias,.T.,.T.)

DbSelectArea("ZD1")

While (cAlias)->(!EOF())
		If Stod((cAlias)->ZD1_DTREG)+(cAlias)->ZD2_QDIAEX < Date()
			DbGoTo((cAlias)->ZD1_RECNO)
			RecLock("ZD1",.F.)
				ZD1->(DBDELETE())
			ZD1->(MsUnlock())	
		Endif	
	(cAlias)->(DbSkip())
Enddo

RestArea(aArea)
RestArea(aAreaZD1)

Return Nil