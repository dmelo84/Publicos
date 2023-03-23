#Include "Protheus.Ch"
#Include 'RestFul.CH'
#INCLUDE "TOPCONN.CH"
//#Include 'RestFul.CH'



#DEFINE JSON_LISTA "1"
#DEFINE JSON_CHAVE_VALOR "2"

/*------------------------------------------------------ Augusto Ribeiro | 23/06/2017 - 6:12:52 PM
	FUNÇÕES GENÉRICAS UTILIZADAS NO SIMPLE EXPORT
------------------------------------------------------------------------------------------*/


/*/{Protheus.doc} CP10QRYJSO
Exporta Query para formato Json
@author Augusto Ribeiro | www.compila.com.br
@since 23/06/2017
@version 6
@param cQuery, Query
@param cTipoExp, Formado do Json de Saída
@return aRet, @return aRet, {lOK, cMsgErro, cJson}
@example
(examples)
@see (links_or_references)
/*/
User Function CP10QRYJSO(cQuery, cTipoExp)
Local aRet		:= {.F., "", ""}
Local nI, nTotCpo, cNameCpo, xDado
Local aFields	:= {}
Local cJson	:= ""

Local oErro := ErrorBlock({|e| lError := .T., aRet[2] := IIF(VALTYPE(e:Description)=="C", "[CP10WSQRY]"+e:Description,"[CP10WSQRY] Falha na montagem da consulta")  })
Local lError	:= .F.

BEGIN SEQUENCE 

IF !EMPTY(cQuery) .AND. (cTipoExp == JSON_LISTA .OR. cTipoExp == JSON_CHAVE_VALOR)


	If Select("TSEXP") > 0
		TSEXP->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSEXP",.F., .T.)	
	
	IF IIF(lError,.F., TSEXP->(!EOF()))
	
		nTotCpo	:= TSEXP->(FCOUNT())
	
	
	
		/*------------------------------------------------------ Augusto Ribeiro | 23/06/2017 - 6:49:10 PM
			EXPORTACAO DO TIPO LISTA
		------------------------------------------------------------------------------------------*/
		IF cTipoExp == JSON_LISTA
		
			/*------------------------------------------------------ Augusto Ribeiro | 23/06/2017 - 6:25:42 PM
				Alimenta campos do cabecalho
			------------------------------------------------------------------------------------------*/
			cJson += '{"CABEC":['
			For nI := 1 To nTotCpo
				cNameCpo	:= ALLTRIM(TSEXP->(FIELDNAME(nI)))
			
				IF nI > 1
					cJson += ','
				ENDIF
			
				cJson += '"'+cNameCpo+'"'
			Next nI			
			cJson += '],' 
			
			cJson += '"ITENS":['
			WHILE TSEXP->(!EOF())
				
				cJson += '['
					For nI := 1 To nTotCpo
						xDado	:= TSEXP->(FIELDGET(nI))
						
						IF nI > 1
							cJson += ','
						ENDIF
					
						IF VALTYPE(xDado) == "C"
							cJson += '"'+ALLTRIM(xDado)+'"'
						ELSEIF VALTYPE(xDado) == "N"
							cJson += ALLTRIM(STR(xDado))
						ENDIF
					

					Next nI						
				cJson += ']'
			
				
				TSEXP->(DBSKIP())
				
				IF TSEXP->(!EOF())
					cJson += ','
				ENDIF				 
			ENDDO
			
			cJson += "]}"
			
			aRet[1]	:= .T.
			aRet[3]	:= cJson

		/*------------------------------------------------------ Augusto Ribeiro | 23/06/2017 - 6:49:10 PM
			EXPORTACAO DO TIPO CHAVE VALOR
		------------------------------------------------------------------------------------------*/
		ELSEIF cTipoExp == JSON_CHAVE_VALOR		
		
		
			/*------------------------------------------------------ Augusto Ribeiro | 23/06/2017 - 6:25:42 PM
				Alimenta campos do cabecalho
			------------------------------------------------------------------------------------------*/
			aFields	:= {}
			For nI := 1 To nTotCpo
				cNameCpo	:= ALLTRIM(TSEXP->(FIELDNAME(nI)))
				AADD(aFields,cNameCpo)
			Next nI			
			
			
			cJson += '{"DADOS":['
			WHILE TSEXP->(!EOF())
				
				cJson += '{'
				For nI := 1 To nTotCpo
					IF nI > 1
						cJson += ','
					ENDIF
				
					cJson += U_cpxToJson(aFields[nI], TSEXP->(FIELDGET(nI)) )
				Next nI						
				cJson += '}'
			
				
				TSEXP->(DBSKIP())
				
				IF TSEXP->(!EOF())
					cJson += ','
				ENDIF				 
			ENDDO
			
			cJson += "]}"
			
			aRet[1]	:= .T.
			aRet[3]	:= cJson
		
		
		ENDIF
	ELSE	
	
		IF EMPTY(aRet[2])
			aRet[1] := .T.
			aRet[3] := '{"DADOS":[]}'
		ENDIF
	ENDIF
	
	If Select("TSEXP") > 0
		TSEXP->(DbCloseArea())
	EndIf	
ELSE
	aRet[2] := "Parametros Inválidos"
ENDIF
 

End Sequence

ErrorBlock(oErro)
	 
	
Return(aRet)





/*/{Protheus.doc} CP10WSQRY
Localiza consulta pelo ID e retorna query pronta para execução
@author Augusto Ribeiro | www.compila.com.br
@since 27/06/2017
@version version
@param cIDWS, IDWS para identificação do parametro
@param oJson, Objeto Json com a chamada
@return aRet,  {lOK, cMsgErro, Query, cTipoRetJson (Z40_TPJSON)
@example
(examples)
@see (links_or_references)
/*/
User Function CP10WSQRY(cIDWS, oJson)
Local aRet		:= {.F., "", "", ""}
Local cQuery	:= ""
Local nI, cParam,xParam, cTypeParam, cQuery
Local oErro := ErrorBlock({|e| lError := .T., aRet[2] := IIF(VALTYPE(e:Description)=="C", "[CP10WSQRY]"+e:Description,"[CP10WSQRY] Falha na montagem da consulta")  })
Local lError	:= .F.

Private oCpJson	:= oJson

Begin Sequence

IF !EMPTY(cIDWS)

	DBSELECTAREA("Z40")
	Z40->(DBSETORDER(2)) //| 
	IF Z40->(DBSEEK(xfilial("Z40")+cIDWS)) 
		IF Z40->Z40_MSBLQL <> '1'
		
			aRet[4] := Z40->Z40_TPJSON
		
			DBSELECTAREA("Z41")
			Z41->(DBSETORDER(1)) //| 
			IF Z41->(DBSEEK(Z40->(Z40_FILIAL+Z40_CODIGO))) 		
		
				WHILE Z41->(!EOF()) .AND. Z40->(Z40_FILIAL+Z40_CODIGO) == Z41->(Z41_FILIAL+Z41_CODIGO)
					cParam		:= ALLTRIM(Z41->Z41_PARAM)
					cTypeParam	:= TYPE("oCpJson:"+cParam)
					
					IF cTypeParam $ "CNDA"
						
						xParam	:= &("oCpJson:"+cParam)
						 
						
						
						IF EMPTY(xParam) .AND. Z41->Z41_OBRIGA == "1"
							aRet[2]		:= "parameter required. ["+cParam+"].	
							EXIT						
						ENDIF
						
						
							
						IF (Z41->Z41_TIPO == "C" .OR. Z41->Z41_TIPO == "D") .AND. cTypeParam == "C"
							IF !EMPTY(xParam)
								&cParam	:= xParam
							ELSE
								&cParam	:= ""
							ENDIF
						ELSEIF Z41->Z41_TIPO == "N" .AND. cTypeParam == "N"
							IF !EMPTY(xParam)
								&cParam	:= alltrim(str(xParam))
							ELSE
								&cParam	:= 0
							ENDIF							
						ELSEIF Z41->Z41_TIPO == "A" .AND. cTypeParam == "A"
							IF !EMPTY(xParam)
								&cParam	:= U_cpxINQRY(xParam)
							ELSE
								&cParam	:= {}
							ENDIF
						ELSEIF Z41->Z41_TIPO == "V"
							IF !EMPTY(xParam)
								&cParam	:= xParam
							ELSE
								&cParam	:= ""
							ENDIF							
						ENDIF

						
						
						IF !EMPTY(Z41->Z41_FUNC)
							&cParam	:= &(Z41->Z41_FUNC)
						ENDIF
					ELSE
					
						IF cTypeParam <> "U" .AND. Z41->Z41_TIPO == "V"
							&cParam	:= xParam
						ENDIF
					
					
						IF !EMPTY(Z41->Z41_PADRAO)
							&cParam	:= &(Z41->Z41_PADRAO)
						ELSEIF !EMPTY(Z41->Z41_FUNC)
							&cParam	:= &(Z41->Z41_FUNC)
						ELSE
							IF Z41->Z41_OBRIGA == "1"
								aRet[2]		:= "parameter required ["+cParam+"].
							ELSE
								aRet[2]		:= "Invalid type parameter ["+cParam+"]. Received ["+cTypeParam+"] Expected ["+Z41->Z41_TIPO+"]"
							ENDIF
							EXIT
						ENDIF										
					ENDIF
					
				
					Z41->(DBSKIP()) 
				ENDDO
				
				
				IF EMPTY(aRet[2])
					cQuery	:= STRTRAN(Z40->Z40_QUERY, CRLF, " ")				
					cQuery	:= &(cQuery)
					//cQuery	:=	cQuery
					
					IF !(lError)
						aRet[1]	:= .T.	
						aRet[3]	:= cQuery
					ENDIF
				ENDIF
				
			ELSE
				aRet[2]		:= "Configuração incorreta da consulta, consulte o administrador. ["+cIDWS+" "+ALLTRIM(Z40->Z40_DESC)+"]"
			ENDIF			
		ELSE
			aRet[2]		:= "Consulta bloqueado para uso pelo administrador. ["+cIDWS+" "+ALLTRIM(Z40->Z40_DESC)+"]"
		ENDIF
	ELSE
		aRet[2]		:= "Consulta não localizada. ["+cIDWS+"]"
	ENDIF
	
ELSE
	aRet[2]		:= "Parametros invalidos [CP10WSQRY]"
ENDIF

End Sequence

ErrorBlock(oErro)
	
Return(aRet)







/*/{Protheus.doc} CP10WSJSON
Processa Json recebido pelo REST
@author Augusto Ribeiro | www.compila.com.br
@since 28/06/2017
@version version
@param cJson, JSON recebido na consulta
@param cTeste, Parametro de Teste
@return aRet, {nCodRet (200=OK, > 400=erro), cMsgErro, cJsonRet}
@example
(examples)
@see (links_or_references)
/*/
User Function CP10WSJSON(cJson, cTeste)
Local aRet		:= {400, "Erro Indeterminado", ""}
Local cQuery	:= ""
Local nI, aRetAux

Default cTeste	:= ""

Private oWSJson //| Variavel deve ser do escopo Private para funcao TYPE funcionar corretamente|

IF FWJsonDeserialize(cJson,@oWSJson)


	IF VALTYPE(oWSJson) == "O"
		IF TYPE("oWSJson:IDWS") == "C"
			/*------------------------------------------------------ Augusto Ribeiro | 28/06/2017 - 6:21:21 PM
				Localiza consulta pelo ID e retorna query pronta para execução
			------------------------------------------------------------------------------------------*/
			aRetAux	:= U_CP10WSQRY(oWSJson:IDWS, oWSJson)
			IF aRetAux[1]
				
				/*--------------------------
					Quanto teste Query, retorna query
				---------------------------*/
				IF cTeste == "QUERY"
					aRet[1]	:= 200
					aRet[3]	:= aRetAux[3]
					
				/*------------------------------------------------------ Augusto Ribeiro | 30/06/2017 - 10:44:00 AM
					DADOS FIXO
				------------------------------------------------------------------------------------------*/
				ELSEIF Z40->Z40_TPJSON == "3"
					aRet[1]	:= 200
					aRet[3]	:= aRetAux[3]									
				ELSE
					
					/*------------------------------------------------------ Augusto Ribeiro | 28/06/2017 - 6:21:36 PM
						Exporta Query para formato Json
					------------------------------------------------------------------------------------------*/					
					aRetAux	:= U_CP10QRYJSO(aRetAux[3], aRetAux[4])
					IF aRetAux[1]
						aRet[1]	:= 200
						aRet[3]	:= aRetAux[3]
					ELSE		
						aRet[1]	:= 498
						aRet[2]	:= aRetAux[2]					
					ENDIF
				ENDIF
			ELSE
				aRet[1]	:= 499
				aRet[2]	:= aRetAux[2]
			ENDIF				
		ELSE
			aRet[1]	:= 403
			aRet[2]	:= "Invalid parameters. IDWS not found or invalid type"
		ENDIF
	ELSE
		aRet[1]	:= 402
		aRet[2]	:= "Invalid Json"
	ENDIF		
	//SetRestFault(200, "TUDO OK")
ELSE
   aRet[1]	:= 402
   aRet[2]	:= "Invalid Json"
ENDIF
	
Return(aRet)






