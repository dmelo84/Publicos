#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'


User Function WSR_MONITOR_FATURAMENTO()
Return


WSRESTFUL FAT_DASHBOARD DESCRIPTION "Serviço REST retorno dados para DashBoard de Faturamento"

WSDATA TIPO AS STRING  //| TOTAIS/SUCESSO_FALHA/PRINCIPAIS_FALHAS/PV_ABERTO/FALHAS_EMPRESA |
WSDATA PERIODO AS STRING  //| DIARIO/SEMANAL/MENSAL |
 

WSMETHOD GET DESCRIPTION "Retorna dados para DashBoard de Faturamento (TOTAIS/SUCESSO_FALHA/PRINCIPAIS_FALHAS/PV_ABERTO/FALHAS_EMPRESA)" WSSYNTAX "/FAT_DASHBOARD || /MEDICOS/{crm}"


END WSRESTFUL



WSMETHOD GET WSRECEIVE TIPO, PERIODO WSSERVICE FAT_DASHBOARD
LOCAL cJson := ""
Local dAtual, dAnter
Local aAtual, aAnter
Local cQuery	:= ""
Local aVlrAtu	:= {} 
Local aVlrAnt	:= {}
Local nI, nX, nPerc

::SetContentType("application/json")

dDataBase	:= stod("20170401") //| ### remover |
//SELF:PERIODO := "SAMPLE" //| ### remover |

/*------------------------------------------------------ Augusto Ribeiro | 14/06/2017 - 5:39:52 PM
	Calculo dos períodos
------------------------------------------------------------------------------------------*/
IF !EMPTY(SELF:PERIODO)
	SELF:PERIODO	:= UPPER(SELF:PERIODO)
	IF SELF:PERIODO == "DIARIO"
		dAtual	:= dDataBase
		dAnter	:= dDataBase-1
	ELSEIF  SELF:PERIODO == "SEMANAL"
		aAtual	:= {dDataBase-6, dDataBase}
		aAnter	:= {dDataBase-14, dDataBase-7}		
	
	ELSEIF  SELF:PERIODO == "MENSAL"
		aAtual	:= {dDataBase-30, dDataBase}
		aAnter	:= {dDataBase-61, dDataBase-31}		
	ENDIF
ENDIF



IF SELF:PERIODO == "DIARIO" .OR.;
	SELF:PERIODO == "SEMANAL" .OR.;
	SELF:PERIODO == "MENSAL"
	


	IF SELF:TIPO == "TOTAIS"

		cQuery := "  SELECT PERIODO,  "+CRLF
		cQuery += "       SUM(F2_VALBRUT) AS VLR_EMITIDA,  "+CRLF
		cQuery += "  	COUNT(F2_VALBRUT) AS QTD_EMITIDA,  "+CRLF
		cQuery += "  	AVG(TEMPO_TRANS) AS TEMPO_TRANS,  "+CRLF
		cQuery += "  	SUM(QTD_CANC) AS QTD_CANC,   "+CRLF
		cQuery += "  	SUM(QTD_EM_TRANS) AS QTD_EM_TRANS, "+CRLF
		cQuery += "     SUM(NAO_TRANS) AS QTD_NAO_TRANS, "+CRLF
		cQuery += "     SUM(QTD_PEND_RIS) AS QTD_PEND_RIS, "+CRLF
		cQuery += "     SUM(RECUSA_PREF) AS RECUSA_PREF "+CRLF
		cQuery += "  	FROM   "+CRLF
		cQuery += "  (  "+CRLF
		cQuery += "  SELECT CASE  "+CRLF
		cQuery += "             WHEN SF3.F3_NFELETR <> '' AND F3_DTCANC = '' THEN F2_VALBRUT "+CRLF
		cQuery += "             ELSE NULL "+CRLF
		cQuery += "         END AS F2_VALBRUT,  "+CRLF
		cQuery += "         CASE  "+CRLF
		IF SELF:PERIODO == "DIARIO"			
			cQuery += "             WHEN SF3.F3_EMISSAO = '"+DTOS(dAnter)+"' THEN 'ANTERIOR'  "+CRLF
			cQuery += "             WHEN SF3.F3_EMISSAO = '"+DTOS(dAtual)+"' THEN 'ATUAL' "+CRLF
		ELSEIF SELF:PERIODO == "SEMANAL" .OR. SELF:PERIODO == "MENSAL"
			cQuery += "             WHEN SF3.F3_EMISSAO BETWEEN '"+DTOS(aAnter[1])+"' AND '"+DTOS(aAnter[2])+"' THEN 'ANTERIOR' "+CRLF
			cQuery += "             WHEN SF3.F3_EMISSAO BETWEEN '"+DTOS(aAtual[1])+"' AND '"+DTOS(aAtual[2])+"' THEN 'ATUAL'  "+CRLF		
		ENDIF		
		cQuery += "         END AS PERIODO, "+CRLF
		cQuery += "  		CASE  "+CRLF
		cQuery += "             WHEN SF3.F3_NFELETR <> '' AND DATEDIFF(MINUTE, CONVERT(DATETIME,  F2_EMISSAO+' '+F2_HORA), CONVERT(DATETIME,  F2_EMINFE+' '+F2_HORNFE)) > 0  "+CRLF
		cQuery += "             THEN DATEDIFF(MINUTE, CONVERT(DATETIME,  F2_EMISSAO+' '+F2_HORA), CONVERT(DATETIME,  F2_EMINFE+' '+F2_HORNFE))  "+CRLF
		cQuery += "             ELSE 0 "+CRLF
		cQuery += "         END as TEMPO_TRANS,  "+CRLF
		cQuery += "  		CASE WHEN F3_DTCANC <> '' THEN 1 ELSE 0 END QTD_CANC,  "+CRLF
		cQuery += "  		CASE WHEN SF3.F3_NFELETR = '' AND SF3.F3_CODRET = 'T' THEN 1 ELSE 0 END QTD_EM_TRANS, "+CRLF
		cQuery += "          CASE WHEN SF3.F3_NFELETR = '' AND SF3.F3_CODRET = '' THEN 1 ELSE 0 END NAO_TRANS, "+CRLF
		cQuery += "          CASE WHEN SF2.F2_XINTPLE = '1' AND SF2.F2_CODNFE <> '' THEN 1 ELSE 0 END QTD_PEND_RIS, "+CRLF		
		cQuery += "          CASE WHEN SF3.F3_NFELETR = '' AND SF3.F3_CODRET <> 'T' AND SF3.F3_CODRET <> '' AND F3_DTCANC = '' THEN 1 ELSE 0 END RECUSA_PREF "+CRLF
		cQuery += " FROM "+RetSqlName("SF3")+" SF3 WITH(NOLOCK) "+CRLF
		cQuery += " LEFT JOIN "+RetSqlName("SF2")+" SF2 WITH(NOLOCK) "+CRLF
		cQuery += "    ON F3_FILIAL = F2_FILIAL "+CRLF
		cQuery += "    AND F3_NFISCAL = F2_DOC  "+CRLF
		cQuery += "    AND F3_SERIE = F2_SERIE  "+CRLF
		cQuery += "    AND F3_CLIEFOR = F2_CLIENTE  "+CRLF
		cQuery += "    AND F3_LOJA = F2_LOJA  "+CRLF
		cQuery += "    AND F2_NFELETR <> '' "+CRLF
		cQuery += "    AND SF2.D_E_L_E_T_ = '' "+CRLF
		IF SELF:PERIODO == "DIARIO"
			cQuery += " WHERE (SF3.F3_EMISSAO = '"+DTOS(dAnter)+"' OR SF3.F3_EMISSAO = '"+DTOS(dAtual)+"' ) "+CRLF
		ELSEIF SELF:PERIODO == "SEMANAL" .OR. SELF:PERIODO == "MENSAL"
			cQuery += " WHERE ( (SF3.F3_EMISSAO BETWEEN '"+DTOS(aAnter[1])+"' AND '"+DTOS(aAnter[2])+"') OR (SF3.F3_EMISSAO BETWEEN '"+DTOS(aAtual[1])+"' AND  '"+DTOS(aAtual[2])+"' ) ) "+CRLF
		ENDIF
		//cQuery += " AND (SF3.F3_NFELETR <> '' OR (SF3.F3_NFELETR = '' AND SF3.F3_CODRET = 'T' and F3_DTCANC = '')) "+CRLF
		cQuery += " AND SF3.D_E_L_E_T_ ='') A  "+CRLF
		cQuery += " GROUP BY PERIODO "+CRLF
			//::SetResponse(	cQuery)
		If Select("TSQL") > 0
			TSQL->(DbCloseArea())
		EndIf
		
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						
				
				
		#DEFINE D_VLR_EMITIDA 1
		#DEFINE D_QTD_EMITIDA 2
		#DEFINE D_TEMPO_TRANS 3
		#DEFINE D_QTD_CANC 4
		#DEFINE D_QTD_EM_TRANS 5
		#DEFINE D_QTD_PEND_RIS 6
		#DEFINE D_QTD_NAO_TRANS 7
					
			

		IF TSQL->(!EOF())
			WHILE TSQL->(!EOF())
	
				IF alltrim(TSQL->PERIODO) == "ATUAL"
					aVlrAtu	:= Array(7)
					aVlrAtu[D_VLR_EMITIDA]	:= TSQL->VLR_EMITIDA
					aVlrAtu[D_QTD_EMITIDA]	:= TSQL->QTD_EMITIDA
					aVlrAtu[D_TEMPO_TRANS]	:= TSQL->TEMPO_TRANS
					aVlrAtu[D_QTD_CANC]		:= TSQL->QTD_CANC
					aVlrAtu[D_QTD_EM_TRANS]	:= TSQL->QTD_EM_TRANS
					aVlrAtu[D_QTD_PEND_RIS]	:= TSQL->QTD_PEND_RIS					
					aVlrAtu[D_QTD_NAO_TRANS]	:= TSQL->QTD_NAO_TRANS
					
					
				ELSEIF alltrim(TSQL->PERIODO) == "ANTERIOR"
					aVlrAnt	:= Array(7)
					aVlrAnt[D_VLR_EMITIDA]	:= TSQL->VLR_EMITIDA
					aVlrAnt[D_QTD_EMITIDA]	:= TSQL->QTD_EMITIDA
					aVlrAnt[D_TEMPO_TRANS]	:= TSQL->TEMPO_TRANS
					aVlrAnt[D_QTD_CANC]		:= TSQL->QTD_CANC
					aVlrAnt[D_QTD_EM_TRANS]	:= TSQL->QTD_EM_TRANS
					aVlrAnt[D_QTD_PEND_RIS]	:= TSQL->QTD_PEND_RIS
					aVlrAnt[D_QTD_NAO_TRANS]	:= TSQL->QTD_NAO_TRANS
						
				ENDIF
			
				TSQL->(DBSKIP()) 
			ENDDO
			
			IF !EMPTY(aVlrAtu)
				/*------------------------------------------------------ Augusto Ribeiro | 14/06/2017 - 6:27:31 PM
					Controle para evitar erro.
					Caso valor anterior esteja vazio, preenche array com zero
				------------------------------------------------------------------------------------------*/
				IF EMPTY(aVlrAnt)
					aVlrAnt	:= Array(7)
					FOR nI := 1 to len(aVlrAnt)
						aVlrAnt[nI] := 0
					NEXT nI
				ENDIF
				
				IF SELF:PERIODO == "DIARIO"
					nMedAtu	:= aVlrAtu[D_QTD_EMITIDA]
					nMedAnt	:= aVlrAnt[D_QTD_EMITIDA]
					
				ELSEIF SELF:PERIODO == "SEMANAL" 					
					nMedAtu	:= aVlrAtu[D_QTD_EMITIDA]/7
					nMedAnt	:= aVlrAnt[D_QTD_EMITIDA]/7			
				ELSEIF SELF:PERIODO == "MENSAL"
					nMedAtu	:= aVlrAtu[D_QTD_EMITIDA]/30
					nMedAnt	:= aVlrAnt[D_QTD_EMITIDA]/30				
				ENDIF 				
			
				cJson := ' {'
				cJson += '     "TOTAIS": [{'
				cJson += '         "QTD_MEDIA": { '
				cJson += '             "VALOR": '+ALLTRIM(STR(ROUND(nMedAtu,0)))+','
				cJson += '             "COMP": '+ALLTRIM(STR( ROUND((nMedAnt*100)/nMedAtu,0)))
	
				cJson += '         },'
				cJson += '         "VLR_EMITIDA": { '
				cJson += '             "VALOR": '+ALLTRIM(STR(ROUND(aVlrAtu[D_VLR_EMITIDA],2)))+','
				cJson += '             "COMP": '+ALLTRIM(STR( ROUND((aVlrAnt[D_VLR_EMITIDA]*100)/aVlrAtu[D_VLR_EMITIDA],2) ))
				cJson += '         },'
				cJson += '         "QTD_EMITIDA": { '
				cJson += '             "VALOR": '+ALLTRIM(STR(aVlrAtu[D_QTD_EMITIDA]))+','
				cJson += '             "COMP": '+ALLTRIM(STR( ROUND((aVlrAnt[D_QTD_EMITIDA]*100)/aVlrAtu[D_QTD_EMITIDA] ,2)))
				cJson += '         },'
				cJson += '         "TEMPO_MEDIO_EMISSAO": { '
				IF aVlrAtu[D_TEMPO_TRANS] < 60
					cJson += '             "VALOR": "'+ALLTRIM(STR(ROUND(aVlrAtu[D_TEMPO_TRANS],2)))+' min",'
				ELSE
					cJson += '             "VALOR": "'+ALLTRIM(Transform(ROUND(aVlrAtu[D_TEMPO_TRANS]/60,2), "@E 999,999.99"))+' h",'
				ENDIF
				cJson += '             "COMP": '+ALLTRIM(STR( ROUND((aVlrAnt[D_TEMPO_TRANS]*100)/aVlrAtu[D_TEMPO_TRANS],2) ))
				cJson += '         },'
				cJson += '         "QTD_CANCELADA": {'
				cJson += '             "VALOR": '+ALLTRIM(STR(ROUND(aVlrAtu[D_QTD_CANC],2)))+','
				cJson += '             "COMP": '+ALLTRIM(STR( ROUND((aVlrAnt[D_QTD_CANC]*100)/aVlrAtu[D_QTD_CANC],2) ))
				cJson += '         },'
				/*
				cJson += '         "QTD_EM_TRANSMISSAO": {'
				cJson += '             "VALOR": '+ALLTRIM(STR(ROUND(aVlrAtu[D_QTD_EM_TRANS],2)))
				cJson += '         },'
				*/
				cJson += '         "QTD_PENDENTE_RIS": { '
				cJson += '             "VALOR": '+ALLTRIM(STR(ROUND(aVlrAtu[D_QTD_PEND_RIS],2)))+','
				cJson += '             "COMP": '+ALLTRIM(STR( ROUND((aVlrAnt[D_QTD_PEND_RIS]*100)/aVlrAtu[D_QTD_PEND_RIS],2) ))
				cJson += '         },'
				cJson += '         "QTD_AGUARDANDO_PREFEITURA": {'
				cJson += '             "VALOR": '+ALLTRIM(STR(ROUND(aVlrAtu[D_QTD_EM_TRANS],2)))+','
				cJson += '             "COMP": '+ALLTRIM(STR( ROUND((aVlrAnt[D_QTD_EM_TRANS]*100)/aVlrAtu[D_QTD_EM_TRANS],2) ))
				cJson += '         },'
				cJson += '         "QTD_RPS_NAO_TRANS": {'
				cJson += '             "VALOR": '+ALLTRIM(STR(ROUND(aVlrAtu[D_QTD_NAO_TRANS],2)))+','
				cJson += '             "COMP": '+ALLTRIM(STR( ROUND((aVlrAnt[D_QTD_NAO_TRANS]*100)/aVlrAtu[D_QTD_NAO_TRANS],2) ))
				cJson += '         } '
				cJson += '     }]'
				cJson += ' }'
				
			ENDIF			
		ENDIF
		TSQL->(DbCloseArea())
	
	
	ELSEIF SELF:TIPO == "SUCESSO_FALHA"
	
		cQuery := " SELECT  "+CRLF
		cQuery += " DESC_REGUA,  "+CRLF
		cQuery += " SUM(SUCESSO) AS SUCESSO, "+CRLF
		cQuery += " SUM(FALHA) AS FALHA "+CRLF
		cQuery += " FROM ( "+CRLF
		cQuery += "  SELECT  "+CRLF
		IF SELF:PERIODO == "DIARIO"
			cQuery += "     LEFT(F2_HORA,2) AS DESC_REGUA, "+CRLF
		ELSEIF SELF:PERIODO == "SEMANAL" .OR. SELF:PERIODO == "MENSAL"
			cQuery += "     F3_EMISSAO AS DESC_REGUA, "+CRLF
		ENDIF
		cQuery += "         CASE  WHEN SF3.F3_NFELETR <> '' AND F3_DTCANC = '' THEN 1 ELSE 0 END AS SUCESSO,           "+CRLF
		cQuery += "          CASE WHEN SF3.F3_NFELETR = '' AND SF3.F3_CODRET <> 'T' AND SF3.F3_CODRET <> '' AND F3_DTCANC = '' THEN 1 ELSE 0 END FALHA "+CRLF
		cQuery += "  FROM  "+RetSqlName("SF3")+" SF3 WITH(NOLOCK)  "+CRLF
		cQuery += "  INNER JOIN  "+RetSqlName("SF2")+" SF2 WITH(NOLOCK)  "+CRLF
		cQuery += "     ON F3_FILIAL = F2_FILIAL  "+CRLF
		cQuery += "     AND F3_NFISCAL = F2_DOC   "+CRLF
		cQuery += "     AND F3_SERIE = F2_SERIE   "+CRLF
		cQuery += "     AND F3_CLIEFOR = F2_CLIENTE   "+CRLF
		cQuery += "     AND F3_LOJA = F2_LOJA   "+CRLF
		cQuery += "     AND SF2.D_E_L_E_T_ = ''  "+CRLF
		IF SELF:PERIODO == "DIARIO"
			cQuery += " WHERE SF3.F3_EMISSAO = '"+DTOS(dAtual)+"' "+CRLF
		ELSEIF SELF:PERIODO == "SEMANAL" .OR. SELF:PERIODO == "MENSAL"
			cQuery += " WHERE SF3.F3_EMISSAO BETWEEN '"+DTOS(aAtual[1])+"' AND '"+DTOS(aAtual[2])+"' "+CRLF
		ENDIF		
		cQuery += "  AND F3_CFO >= '5000' "+CRLF
		cQuery += "  AND SF3.D_E_L_E_T_ ='') A "+CRLF
		cQuery += "  GROUP BY DESC_REGUA "+CRLF
		cQuery += "  ORDER BY 1 "+CRLF	
	
	
		 If Select("TSQL") > 0
		 	TSQL->(DbCloseArea())
		 EndIf
		 
		 DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						
		 IF TSQL->(!EOF())

			cJson := '{'
			cJson += '	"SUCESSO_FALHA": ['			
 
		 
			 WHILE TSQL->(!EOF())
			 
			 		cJson += '{'
			 		IF SELF:PERIODO == "SEMANAL" .OR. SELF:PERIODO == "MENSAL"
			 			cJson += U_cpxToJson("LABEL", STOD(TSQL->DESC_REGUA))+","
			 		ELSE
			 			cJson += U_cpxToJson("LABEL", ALLTRIM(TSQL->DESC_REGUA)+":00")+","			 			
			 		ENDIF
			 		cJson += '"VALOR":{'
			 		cJson += U_cpxToJson("FALHA", TSQL->FALHA)+","
			 		cJson += U_cpxToJson("SUCESSO", TSQL->SUCESSO)		 		
			 		cJson += '}}'		 
			 
			 	TSQL->(DBSKIP())
			 	
			 	IF TSQL->(!EOF())
			 		cJson += "," 
			 	ENDIF 
			 ENDDO	
			 
			cJson += '	]'
			cJson += '}'
					 
		 ENDIF

		 TSQL->(DbCloseArea())
	
	ELSEIF SELF:TIPO == "PRINCIPAIS_FALHAS"
		SELF:PERIODO := "SAMPLE"	
	ELSEIF SELF:TIPO == "PV_ABERTO"


		cQuery := " SELECT TOP 5 C5_FILIAL, COUNT(*) AS QTDE "+CRLF
		cQuery += " FROM "+RetSqlName("SC5")+" SC5 with(nolock) "+CRLF
				
		IF SELF:PERIODO == "DIARIO"			
			cQuery += " WHERE C5_EMISSAO = '"+DTOS(dAtual)+"' "+CRLF
		ELSEIF SELF:PERIODO == "SEMANAL" .OR. SELF:PERIODO == "MENSAL"
			cQuery += " WHERE C5_EMISSAO BETWEEN '"+DTOS(aAtual[1])+"' AND '"+DTOS(aAtual[2])+"' "+CRLF
		ENDIF				
		
		cQuery += " AND SC5.D_E_L_E_T_ = '' "+CRLF
		cQuery += " AND NOT EXISTS (SELECT 1 AS A  "+CRLF
		cQuery += "                 FROM "+RetSqlName("SD2")+" SD2 with(nolock) "+CRLF
		cQuery += "                 WHERE D2_FILIAL = C5_FILIAL "+CRLF
		cQuery += "                 AND D2_PEDIDO = C5_NUM "+CRLF
		cQuery += "                 AND SD2.D_E_L_E_T_ = '') "+CRLF
		cQuery += " GROUP BY C5_FILIAL "+CRLF
		cQuery += " ORDER BY 2 DESC "+CRLF
		
		If Select("TSQL") > 0
			TSQL->(DbCloseArea())
		EndIf
		
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						
		IF TSQL->(!EOF())
		
			nTotal	:= 0 
			WHILE TSQL->(!EOF())
				nTotal	+= TSQL->QTDE
				TSQL->(DBSKIP()) 
			ENDDO
			TSQL->(DBGOTOP())
		
			cJson := '{'
			cJson += '	"PV_ABERTO": [{'
			
			nI	:= 0
			WHILE TSQL->(!EOF())
				nI++
		 		cJson += '"TOP'+ALLTRIM(STR(nI))+'":{'
		 		
		 		
		 		cJson += U_cpxToJson("DESC", ALLTRIM(FWFilName("01",TSQL->C5_FILIAL))  )+","
		 		cJson += U_cpxToJson("QTDE", TSQL->QTDE)+","
		 		cJson += U_cpxToJson("PERC", round((TSQL->QTDE*100)/nTotal,2))
		 		cJson += '}'
			
				TSQL->(DBSKIP()) 
				
			 	IF TSQL->(!EOF())
			 		cJson += "," 
			 	ENDIF
			ENDDO
			
			/*
			FOR nX := nI to 5
				IF nI > 0
			 		cJson += "," 
			 	ENDIF
				
				cJson += U_cpxToJson("DESC", "")+","
		 		cJson += U_cpxToJson("QTDE", 0)+","
		 		cJson += U_cpxToJson("PERC", 0)
		 		cJson += '}'			
			
			NEXT nX
			*/
			
			
			cJson += '	}]'
			cJson += '}'			
		ENDIF	
		
		
		TSQL->(DbCloseArea())
		

		
	ELSEIF SELF:TIPO == "FALHAS_EMPRESA"	
		
		cQuery := " SELECT TOP 5 F3_FILIAL, COUNT(*) AS QTDE "+CRLF
		cQuery += " FROM "+RetSqlName("SF3")+" SF3 WITH(NOLOCK) "+CRLF
		IF SELF:PERIODO == "DIARIO"			
			cQuery += " WHERE SF3.F3_EMISSAO = '"+DTOS(dAtual)+"' "+CRLF
		ELSEIF SELF:PERIODO == "SEMANAL" .OR. SELF:PERIODO == "MENSAL"
			cQuery += " WHERE SF3.F3_EMISSAO BETWEEN '"+DTOS(aAtual[1])+"' AND '"+DTOS(aAtual[2])+"' "+CRLF
		ENDIF					
		cQuery += " AND F3_CFO >= '5000' "+CRLF
		cQuery += " AND SF3.F3_NFELETR = ''  "+CRLF
		cQuery += " AND SF3.F3_CODRET <> 'T' "+CRLF
		cQuery += " AND SF3.F3_CODRET <> '' "+CRLF
		cQuery += " AND F3_DTCANC = '' "+CRLF
		cQuery += " AND SF3.D_E_L_E_T_ ='' "+CRLF
		cQuery += " GROUP BY F3_FILIAL "+CRLF
		cQuery += " ORDER BY 2 DESC "+CRLF		
		
		
		If Select("TSQL") > 0
			TSQL->(DbCloseArea())
		EndIf
		
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						
		IF TSQL->(!EOF())
		
			nTotal	:= 0 
			WHILE TSQL->(!EOF())
				nTotal	+= TSQL->QTDE
				TSQL->(DBSKIP()) 
			ENDDO
			TSQL->(DBGOTOP())
		
			cJson := '{'
			cJson += '	"FALHAS_EMPRESA": [{'
			
			nI	:= 0
			WHILE TSQL->(!EOF())
				nI++
		 		cJson += '"TOP'+ALLTRIM(STR(nI))+'":{'
		 		
		 		
		 		cJson += U_cpxToJson("DESC", ALLTRIM(FWFilName("01",TSQL->F3_FILIAL))  )+","
		 		cJson += U_cpxToJson("QTDE", TSQL->QTDE)+","
		 		cJson += U_cpxToJson("PERC", round((TSQL->QTDE*100)/nTotal,2))
		 		cJson += '}'
			
				TSQL->(DBSKIP()) 
				
			 	IF TSQL->(!EOF())
			 		cJson += "," 
			 	ENDIF
			ENDDO
			
			
			cJson += '	}]'
			cJson += '}'			
		ENDIF	
		
		
		TSQL->(DbCloseArea())	
		
	ELSEIF SELF:TIPO == "PERC_SUCESSO"	
	
		cQuery := " SELECT  "+CRLF
		cQuery += " ISNULL(SUM(SUCESSO),0) AS SUCESSO, "+CRLF
		cQuery += " ISNULL(SUM(FALHA),0) AS FALHA "+CRLF
		cQuery += " FROM ( "+CRLF
		cQuery += "      SELECT      "+CRLF
		cQuery += "         CASE  WHEN SF3.F3_NFELETR <> '' AND F3_DTCANC = '' THEN 1 ELSE 0 END AS SUCESSO,           "+CRLF
		cQuery += "          CASE WHEN SF3.F3_NFELETR = '' AND SF3.F3_CODRET <> 'T' AND SF3.F3_CODRET <> '' AND F3_DTCANC = '' THEN 1 ELSE 0 END FALHA "+CRLF
		cQuery += "     FROM "+RetSqlName("SF3")+" SF3 WITH(NOLOCK) "+CRLF
		IF SELF:PERIODO == "DIARIO"			
			cQuery += " WHERE SF3.F3_EMISSAO = '"+DTOS(dAtual)+"' "+CRLF
		ELSEIF SELF:PERIODO == "SEMANAL" .OR. SELF:PERIODO == "MENSAL"
			cQuery += " WHERE SF3.F3_EMISSAO BETWEEN '"+DTOS(aAtual[1])+"' AND '"+DTOS(aAtual[2])+"' "+CRLF
		ENDIF
		cQuery += "     AND F3_CFO >= '5000' "+CRLF
		cQuery += "     AND F3_DTCANC = '' "+CRLF
		cQuery += "     AND SF3.D_E_L_E_T_ ='') A "+CRLF
	
			
		If Select("TSQL") > 0
			TSQL->(DbCloseArea())
		EndIf
		
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						
		
	
		
		IF TSQL->(!EOF())
		
			cJson += '{'			
			cJson += U_cpxToJson("PERC_SUCESSO", ROUND(100-((TSQL->FALHA*100)/TSQL->SUCESSO),2)  )
			cJson += '}'	
		
		
			TSQL->(DBSKIP()) 
		ENDIF		
		
		TSQL->(DbCloseArea())
	ENDIF

ENDIF


IF SELF:PERIODO == "SAMPLE"
	IF SELF:TIPO == "TOTAIS"
	 
		cJson := ' {'
		cJson += '     "TOTAIS": [{'
		cJson += '         "QTD_MEDIA": { '
		cJson += '             "VALOR": 250.45,'
		cJson += '             "COMP": 4'
		cJson += '         },'
		cJson += '         "VLR_EMITIDA": { '
		cJson += '             "VALOR": 12250.45,'
		cJson += '             "COMP": -2 '
		cJson += '         },'
		cJson += '         "QTD_EMITIDA": { '
		cJson += '             "VALOR": 234,'
		cJson += '             "COMP": 34 '
		cJson += '         },'
		cJson += '         "TEMPO_MEDIO_EMISSAO": { '
		cJson += '             "VALOR": 234,'
		cJson += '             "COMP": 34 '
		cJson += '         },'
		cJson += '         "QTD_CANCELADA": {'
		cJson += '             "VALOR": 234,'
		cJson += '             "COMP": 34 '
		cJson += '         },'
		cJson += '         "QTD_EM_TRANSMISSAO": {'
		cJson += '             "VALOR": 45'
		cJson += '         },'
		cJson += '         "QTD_PENDENTE_RIS": { '
		cJson += '             "VALOR": 45, '
		cJson += '             "COMP": 34 '
		cJson += '         },'
		cJson += '         "QTD_AGUARDANDO_PREFEITURA": {'
		cJson += '             "VALOR": 45, '
		cJson += '             "COMP": 34 '
		cJson += '         },'
		cJson += '         "QTD_RPS_NAO_TRANS": {'
		cJson += '             "VALOR": 45, '
		cJson += '             "COMP": 34 '
		cJson += '         } '
		cJson += '     }]'
		cJson += ' }'
	
	ELSEIF SELF:TIPO == "SUCESSO_FALHA"
			
		cJson := '{'
		cJson += '"SUCESSO_FALHA": '
		cJson += '    ['
		cJson += '    {'
		cJson += '        "LABEL":"JANEIRO",'
		cJson += '        "VALOR":['
		cJson += '            {'
		cJson += '                "FALHA":10'
		cJson += '            },'
		cJson += '            {'
		cJson += '                "SUCESSO":950'
		cJson += '            }'
		cJson += '        ]'
		cJson += '    },'
		cJson += '    {'
		cJson += '        "LABEL":"FEVEREIRO",'
		cJson += '        "VALOR":['
		cJson += '            {'
		cJson += '                "FALHA":40'
		cJson += '            },'
		cJson += '            {'
		cJson += '                "SUCESSO":560'
		cJson += '            }'
		cJson += '        ]'
		cJson += '    },'
		cJson += '    {'
		cJson += '        "LABEL":"MARCO",'
		cJson += '        "VALOR":['
		cJson += '            {'
		cJson += '                "FALHA":30'
		cJson += '            },'
		cJson += '            {'
		cJson += '                "SUCESSO":430'
		cJson += '            }'
		cJson += '        ]'
		cJson += '    },'
		cJson += '    {'
		cJson += '        "LABEL":"ABRIL",'
		cJson += '        "VALOR":['
		cJson += '            {'
		cJson += '                "FALHA":23'
		cJson += '            },'
		cJson += '            {'
		cJson += '                "SUCESSO":150'
		cJson += '            }'
		cJson += '        ]'
		cJson += '    }'
		cJson += '    ]'
		cJson += '}'
	
	ELSEIF SELF:TIPO == "PRINCIPAIS_FALHAS"	
		
		cJson := '{'
		cJson += '	"PRINCIPAIS_FALHAS": [{'
		cJson += '		"TOP1": {'
		cJson += '			"DESC":"Descricaoo de servico nao informada",'
		cJson += '			"QTDE": 120,'
		cJson += '			"PERC": 60'
		cJson += '		},'
		cJson += '		"TOP2": {'
		cJson += '			"DESC":"RPS enviado fora de ordem",'
		cJson += '			"QTDE": 84,'
		cJson += '			"PERC": 15'
		cJson += '		},'
		cJson += '		"TOP3": {'
		cJson += '			"DESC":"Cancelamento nao autorizado",'
		cJson += '			"QTDE": 52,'
		cJson += '			"PERC": 10'
		cJson += '		},'
		cJson += '		"TOP4": {'
		cJson += '			"DESC":"Cadastro de cliente incorreto",'
		cJson += '			"QTDE": 40,'
		cJson += '			"PERC": 5'
		cJson += '		},'
		cJson += '		"TOP5": {'
		cJson += '			"DESC":"Email invalido",'
		cJson += '			"QTDE": 20,'
		cJson += '			"PERC": 5'
		cJson += '		}'
		cJson += '	}]'
		cJson += '}'
		
	ELSEIF SELF:TIPO == "PV_ABERTO"		
		
		cJson := '{'
		cJson += '	"PV_ABERTO": [{'
		cJson += '		"TOP1": {'
		cJson += '			"DESC":"CSD",'
		cJson += '			"QTDE": 120,'
		cJson += '			"PERC": 65'
		cJson += '		},'
		cJson += '		"TOP2": {'
		cJson += '			"DESC":"CEDIMAGEM",'
		cJson += '			"QTDE": 84,'
		cJson += '			"PERC": 10'
		cJson += '		},'
		cJson += '		"TOP3": {'
		cJson += '			"DESC":"UMDI",'
		cJson += '			"QTDE": 52,'
		cJson += '			"PERC": 10'
		cJson += '		},'
		cJson += '		"TOP4": {'
		cJson += '			"DESC":"SABEDOTTI",'
		cJson += '			"QTDE": 40,'
		cJson += '			"PERC": 7'
		cJson += '		},'
		cJson += '		"TOP5": {'
		cJson += '			"DESC":"CDI",'
		cJson += '			"QTDE": 20,'
		cJson += '			"PERC": 3'
		cJson += '		}'
		cJson += '	}]'
		cJson += '}'
		
	ELSEIF SELF:TIPO == "FALHAS_EMPRESA"	
		
		cJson := '{'
		cJson += '	"FALHAS_EMPRESA": [{'
		cJson += '		"TOP1": {'
		cJson += '			"DESC":"CSD",'
		cJson += '			"QTDE": 120,'
		cJson += '			"PERC": 70'
		cJson += '		},'
		cJson += '		"TOP2": {'
		cJson += '			"DESC":"CEDIMAGEM",'
		cJson += '			"QTDE": 84,'
		cJson += '			"PERC": 20'
		cJson += '		},'
		cJson += '		"TOP3": {'
		cJson += '			"DESC":"UMDI",'
		cJson += '			"QTDE": 52,'
		cJson += '			"PERC": 5'
		cJson += '		},'
		cJson += '		"TOP4": {'
		cJson += '			"DESC":"SABEDOTTI",'
		cJson += '			"QTDE": 40,'
		cJson += '			"PERC": 3'
		cJson += '		},'
		cJson += '		"TOP5": {'
		cJson += '			"DESC":"CDI",'
		cJson += '			"QTDE": 20,'
		cJson += '			"PERC": 2'
		cJson += '		}'
		cJson += '	}]'
		cJson += '}'
			
	ENDIF
ENDIF

::SetResponse(cJson)


Return(.T.)
