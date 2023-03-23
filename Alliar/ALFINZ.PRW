#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE 'TBICONN.CH'


/*
ALFINZ
atualziar dados da SZ7 (tabela que customizaram para a DIgitalMed) na SE1

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFINZ()
Local cSZ7Alias   := GetNextALias()
Local cSD2Alias   := GetNextALias()
Local cSF2Alias   := GetNextALias()
Local cSE1Alias   := GetNextALias()
Local lPrimeiro   := .T.
Local nVlrParc    := 0
Local lLocalizado := .F.
Local lDetectou   := .F.
Local cStr1       := ''
Local cStr2       := ''
Local nInd1       := 1
Local nInd2       := 1
Local nQtdParcelas:= 0
Local nContaParcs := 0

Local aRecSe1c	  := {}	
Local nI		  := 0 

BeginSql alias cSZ7Alias
		SELECT SZ7.* 	FROM %table:SZ7% SZ7 
	 	 WHERE SZ7.%notdel%    
		   AND SZ7.Z7_FILIAL  = %exp:(Fwxfilial("SZ7"))% 
		   AND SZ7.Z7_PEDIDO  = %exp:(  SC5->C5_NUM  )%
EndSql

If (cSZ7Alias) -> (!Eof())
		
		If lPrimeiro
			lPrimeiro := .F.
				
			BeginSql alias cSF2Alias
					SELECT SF2.* 	FROM %table:SF2% SF2 
				 	 WHERE SF2.%notdel%    
					   AND SF2.F2_FILIAL   = %exp:(Fwxfilial("SF2")   )% 
					   AND SF2.F2_DOC      = %exp:(  SC5->C5_NOTA      )% 
					   AND SF2.F2_SERIE    = %exp:(  SC5->C5_SERIE      )% 
					   AND SF2.F2_CLIENTE  = %exp:(  SC5->C5_CLIENTE  )% 
					   AND SF2.F2_LOJA     = %exp:(  SC5->C5_LOJACLI  )% 
		    EndSql
		    
		        
		    If (cSF2Alias) -> (!Eof())
		    	lLocalizado := .T.
		    	 
		    	DbSelectArea('SF2')
				SF2->(DbSetOrder(1) )
				SF2->( dbgoto( (cSF2Alias)->(R_E_C_N_O_) ) )
			EndIf
			    
		    (cSF2Alias) -> (DbCloseArea())
		EndIf
            
            
		While lLocalizado .And. (cSZ7Alias) -> (!Eof())

			If AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "CH" .or. AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "DH"   .or. AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "CD"
				nVlrParc := (cSZ7Alias) -> (Z7_VALOR) //<-- para estas duas formas de pagto sempre sera 1 unico titulo !!!
				nQtdParcelas := 1
			Else
				nVlrParc := (cSZ7Alias) -> (Z7_VALOR) / (cSZ7Alias) -> (Z7_QTDPAR)
				nQtdParcelas := (cSZ7Alias) -> (Z7_QTDPAR)
			EndIf
			nContaParcs  := 0	
		    
			
		    
		    
			/*
			//========= atualiza itens da nota =============================================
			BeginSql alias cSD2Alias
					SELECT SD2.* 	FROM %table:SD2% SD2 
				 	 WHERE SD2.%notdel%    
					   AND SD2.D2_FILIAL   = %exp:(Fwxfilial("SD2")   )% 
					   //AND SD2.D2_PEDIDO   = %exp:(  SC5->C5_NUM      )% 
					   AND SD2.D2_CLIENTE  = %exp:(  SC5->C5_CLIENTE  )% 
					   AND SD2.D2_LOJA     = %exp:(  SC5->C5_LOJACLI  )% 
					   AND SD2.D2_TOTAL    = %exp:(  nVlrParc         )%
					   AND SD2.D2_DOC      = %exp:(  SC5->C5_NOTA      )% 
					   AND SD2.D2_SERIE    = %exp:(  SC5->C5_SERIE      )% 
			EndSql
	
			acampos := getlastquery()
		    alert ("QUERY NA SD2 : " + acampos[2])
			
			While (cSD2Alias) -> (!Eof())
			    ALERT ("ACHANDO SD2 E ATUALIZANDO ELA")
				DbSelectArea('SD2')
				SD2->(DbSetOrder(1) )
				SD2->( dbgoto( (cSD2Alias)->(R_E_C_N_O_) ) )
					
				reclock('SD2',.F.)
				SD2->D2_XDCRT  := (cSZ7Alias) -> (Z7_FORMA)+ "-" + (cSZ7Alias) -> (Z7_BAND)
					
				If AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "CC"
					SD2->D2_XDAUD  := (cSZ7Alias) -> (Z7_IDTRAN)
				EndiF
					
				If AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "CH"
					SD2->D2_XDAUD  := (cSZ7Alias) -> (Z7_NUMCHQ)
				EndiF
					
				MsUnlock()
					
				(cSD2Alias) -> (DbSkip())
			End
	
			(cSD2Alias) -> (DbCloseArea())
            //============================================================================================
            */
            //========= atualiza parcelas do titulo =============================================
            lDetectou   := .F.
            cStr1       := ''
            cSTr2       := ''
            lPonto      := .F.
             
			BeginSql alias cSE1Alias
					SELECT SE1.* 	FROM %table:SE1% SE1 
				 	 WHERE SE1.%notdel%    
					   AND SE1.E1_FILIAL   = %exp:(Fwxfilial("SE1")   )%  
					   AND SE1.E1_CLIENTE  = %exp:(  SC5->C5_CLIENTE  )% 
					   AND SE1.E1_LOJA     = %exp:(  SC5->C5_LOJACLI  )% 
					   AND SE1.E1_VALOR    = %exp:(  nVlrParc         )% 
					   AND SE1.E1_NUM      = %exp:(  SF2->F2_DUPL      )%
					   AND SE1.E1_PREFIXO  = %exp:(  SF2->F2_PREFIXO   )% 
					   AND SE1.E1_XDCRT    = ''
					   AND SE1.E1_XDAUD    = ''  
			EndSql
			
			While (cSE1Alias) -> (!Eof())
				nContaParcs += 1
				If nContaParcs <= nQtdParcelas  
						
			
				    lDetectou   := .T.
					DbSelectArea('SE1')
					SE1->(DbSetOrder(1) )
					SE1->( dbgoto( (cSE1Alias)->(R_E_C_N_O_) ) )
						
					reclock('SE1',.F.)
					SE1->E1_XDCRT  := (cSZ7Alias) -> (Z7_FORMA) 
					
					
					If AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "CC"
					
						SE1->E1_XDCRT  := AllTrim(SE1->E1_XDCRT) + "-" + (cSZ7Alias) -> (Z7_BAND)
					EndIf
						
					If AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "CC" .OR. AllTrim((cSZ7Alias)->(Z7_FORMA)) == "CD"
						SE1->E1_XDAUD  := (cSZ7Alias) -> (Z7_IDTRAN)
					EndiF
						
					If AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "CH"
						SE1->E1_XDAUD  := (cSZ7Alias) -> (Z7_NUMCHQ)
					EndiF
					
					/*----------------------------------------
						15/11/2017 - Jonatas Oliveira - Compila
						Adiciona RECNO do SE1 para posterior 
						Ajuste de campos utilizados na conciliação
						de cartão de Crédito
					------------------------------------------*/
					IF aScan(aRecSe1c,{|x| x[1] == SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO)}) == 0					     						
						AADD(aRecSe1c,{SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO) , SE1->E1_FILIAL , SE1->E1_PREFIXO , SE1->E1_NUM , SE1->E1_TIPO })						
					ENDIF 
						
					MsUnlock()				 
				else
					exit
				EndIf
					
				(cSE1Alias) -> (DbSkip())
			End
	
			(cSE1Alias) -> (DbCloseArea())
			
			If lDetectou  == .F.//diferenca de arredondamento ou decimal
				cStr1 := STR(nVlrParc)
                				
				BeginSql alias cSE1Alias
						SELECT SE1.* 	FROM %table:SE1% SE1 
					 	 WHERE SE1.%notdel%    
						   AND SE1.E1_FILIAL   = %exp:(Fwxfilial("SE1")   )%  
						   AND SE1.E1_CLIENTE  = %exp:(  SC5->C5_CLIENTE  )% 
						   AND SE1.E1_LOJA     = %exp:(  SC5->C5_LOJACLI  )% 
						   AND SE1.E1_NUM      = %exp:(  SF2->F2_DUPL      )%
						   AND SE1.E1_PREFIXO  = %exp:(  SF2->F2_PREFIXO   )%
						   AND SE1.E1_XDCRT    = ''
						   AND SE1.E1_XDAUD    = ''  
				EndSql
		
				
				While (cSE1Alias) -> (!Eof())
				    
				    nValTit := (cSE1Alias) -> (E1_VALOR)
				    
				    cStr2 := STR(nValTit)
				    
				    cStr1 := AllTrim(cStr1)
				    cStr2 := AllTrim(cStr2)
				
				    
				    
				    For nInd1 := 1 to Len(cStr1)  
				    
				    	If substr(cStr1,nInd1,1) == "."
				    	    nInd1 := nInd1 - 1 
				    		exit
				    	EndIf
				    Next
				    
				    For nInd2 := 1 to Len(cStr2)  
				    
				    	If substr(cStr2,nInd2,1) == "."
				    	    nInd2 := nInd2 - 1 
				    		exit
				    	EndIf
				    Next
				    
				    
                    If nInd1 == nInd2
                       
	                    If Val(substr(cStr1,1,nInd1)) == Val(substr(cStr2,1,nInd2))
	                     	nContaParcs += 1
	                     	If nContaParcs <= nQtdParcelas  
		                     		
				
		                     	lDetectou   := .T.
								DbSelectArea('SE1')
								SE1->(DbSetOrder(1) )
								SE1->( dbgoto( (cSE1Alias)->(R_E_C_N_O_) ) )
									
								reclock('SE1',.F.)
								SE1->E1_XDCRT  := (cSZ7Alias) -> (Z7_FORMA) 
								
								If AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "CC"
									SE1->E1_XDCRT  := AllTrim(SE1->E1_XDCRT) + "-" + (cSZ7Alias) -> (Z7_BAND)
								EndIf
									
								If AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "CC" .OR. AllTrim((cSZ7Alias)->(Z7_FORMA)) == "CD"
									SE1->E1_XDAUD  := (cSZ7Alias) -> (Z7_IDTRAN)
								EndiF
									
								If AllTrim((cSZ7Alias) -> (Z7_FORMA)) == "CH"
									SE1->E1_XDAUD  := (cSZ7Alias) -> (Z7_NUMCHQ)
								EndiF
								
								/*----------------------------------------
									15/11/2017 - Jonatas Oliveira - Compila
									Adiciona RECNO do SE1 para posterior 
									Ajuste de campos utilizados na conciliação
									de cartão de Crédito
								------------------------------------------*/
								IF aScan(aRecSe1c,{|x| x[1] == SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO)}) == 0					     								
									AADD(aRecSe1c,{SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO),SE1->E1_FILIAL , SE1->E1_PREFIXO , SE1->E1_NUM , SE1->E1_TIPO })
								ENDIF 
								
									
								MsUnlock()
								
							Else
								exit
							EndIf
							
						EndIf
					EndIf
						
					(cSE1Alias) -> (DbSkip())
				End
		
				(cSE1Alias) -> (DbCloseArea())		
			EndIf
            //============================================================================================
            				
			(cSZ7Alias) -> (DbSkip())
		End
		
	EndIf
		
(cSZ7Alias) -> (DbCloseArea())

/*----------------------------------------
	15/11/2017 - Jonatas Oliveira - Compila
	Atualiza os dados da conciliação do 
	cartão de crédito 
------------------------------------------*/
For nI := 1 To Len(aRecSe1c)
	U_ALFINFP( .F.,  aRecSe1c[nI],)
Next nI 
 

Return  


/*/{Protheus.doc} ALFINFP
Função responsavel por atualizar base Legada
Atualiza campos E1_XFORMPG - Forma de pagamento e E1_XBAND - Bandeira 
com base nos registros da tabela SZ7 - FORMAS PAGTO PEDIDO VENDA
@author Jonatas Oliveira | www.compila.com.br
@since 21/10/2017
@version 1.0
@param lLegado, L, .T. Atualiza a base inteira(Legado) - .F. Apenas o registro enviado
@param aChvTit, A, 	aChvTit[1] - (E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO)
					aChvTit[2] - E1_FILIAL 
					aChvTit[3] - E1_PREFIXO
					aChvTit[4] - E1_NUM
					aChvTit[5] - E1_TIPO
/*/
User Function ALFINFP(lLegado,aChvTit )
Local cQuery	:= ""
Local cCodZC3 	:= ""

Private nCount	:= 0

Default aChvTit := {}
Default lLegado	:= .F. 

IF IIF(lLegado, .T., Len(aChvTit) == 5)

	cQuery += "  SELECT E1_FILIAL,"
	cQuery += "  	E1_PREFIXO	, "
	cQuery += "  	E1_NUM		, "
	cQuery += "  	E1_PARCELA	, "
	cQuery += "  	E1_TIPO		, "
	cQuery += "  	E1_VALOR	, "
	cQuery += "  	E1_PEDIDO	, "
	cQuery += "  	Z7_FILIAL	, "
	cQuery += "  	Z7_PEDIDO	, "
	cQuery += "  	Z7_FORMA	, "
	cQuery += "  	Z7_VALOR	, "
	cQuery += "  	Z7_QTDPAR	, "
	cQuery += "  	E1_XDAUD 	, "
	cQuery += "  	E1_XDCRT 	, "
	cQuery += "  	E1_XFORMPG 	, "
	cQuery += "  	E1_XBAND 	, "
	cQuery += "  	E1_XCODAUT 	, "
	cQuery += "  	E1_XCARMAS 	, "
	cQuery += "  	Z7_NUMCHQ 	, "
	cQuery += "  	Z7_BAND 	, "
	cQuery += "  	Z7_IDTRAN 	, "
	cQuery += "  	E1.R_E_C_N_O_ AS  RECSE1 "
	cQuery += "  FROM "+Retsqlname("SZ7")+" Z7 WITH(NOLOCK) "
	cQuery += "  INNER JOIN "+Retsqlname("SE1")+" E1 WITH(NOLOCK) "
	cQuery += "  	ON Z7_FILIAL = E1_FILIAL  "   
	cQuery += "   	AND Z7_PEDIDO = E1_PEDIDO "
	cQuery += "  	AND Z7_IDTRAN = E1_XDAUD "
	cQuery += "   	AND E1.D_E_L_E_T_ = '' "
	cQuery += "   	AND E1_XCODAUT = '' "
	
	IF !lLegado //.and. Len(aChvTit) == 5
		
		cQuery += "   	AND E1_FILIAL 	= '"+ aChvTit[2] +"' "
		cQuery += "   	AND E1_PREFIXO 	= '"+ aChvTit[3] +"' "
		cQuery += "   	AND E1_NUM 		= '"+ aChvTit[4] +"' "
		cQuery += "   	AND E1_TIPO 	= '"+ aChvTit[5] +"' "	
	ENDIF 
	
	cQuery += "  WHERE Z7.D_E_L_E_T_ = ''  "
	
	/*-----------------------------------------------
		Popula campos novos com informações
		do cartão de credito
	------------------------------------------------*/	
	IF lLegado
		cQuery += " AND Z7_FORMA IN ('CD','CC') "
		cQuery += " AND Z7_IDTRAN <> '' "
	ENDIF
	
	//cQuery += "  	AND Z7_FILIAL = '00101MG0006' "
	//cQuery += "  	AND Z7_PEDIDO = '001067' "		
	
	cQuery += "  ORDER BY E1_FILIAL,E1_PREFIXO,E1_NUM,Z7_IDTRAN,E1_VENCREA "
		
	If Select("QRYEXC") > 0
		QRYEXC->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYEXC')
	
	
	 Processa({|| ProcFpgt()},"Atualizando Dados de Pagamento")
	 
	 QRYEXC->(DbCloseArea())
ENDIF

Return()



/*/{Protheus.doc} ProcFpgt
Atualiza a tabela
@author Jonatas Oliveira | www.compila.com.br
@since 23/10/2017
@version 1.0
/*/
Static Function ProcFpgt()	
	Local nParcCC 	:= 0 
	Local cNumTran	:= ""
	
	DBSELECTAREA("SE1")
	SE1->(DBSETORDER(1))
	
	QRYEXC->(DBGoTop())	
	QRYEXC->( dbEval( {|| nCount++ } ) )	
	QRYEXC->(DBGoTop())

	ProcRegua(nCount)
	
	WHILE QRYEXC->(!EOF())
		IncProc()
		
		nParcCC := 0  
		cNumTran := ALLTRIM(QRYEXC->Z7_IDTRAN)
	
		WHILE QRYEXC->(!EOF()) .AND.  cNumTran == ALLTRIM(QRYEXC->Z7_IDTRAN)
			nParcCC ++ 
			
			cCodZC3 := ""
			
	 		SE1->(DBGOTO(QRYEXC->RECSE1))
			
			IF !EMPTY(QRYEXC->Z7_BAND)
				cCodZC3	:= U_CP113DEP("001", "PLE", QRYEXC->Z7_BAND)
			ENDIF 
			
					
			SE1->(RecLock("SE1",.F.))
				
				IF ALLTRIM(QRYEXC->Z7_FORMA) $ ("CD|CC")
					SE1->E1_XFORMPG	:=  QRYEXC->Z7_FORMA
					SE1->E1_XBAND	:= 	cCodZC3
					SE1->E1_XCODAUT :=  QRYEXC->Z7_IDTRAN
					SE1->E1_XCARMAS :=  QRYEXC->Z7_NUMCHQ
					IF QRYEXC->Z7_QTDPAR > 1
						SE1->E1_XPARCAR	:=  STRZERO(nParcCC,TAMSX3("E1_XPARCAR")[1])
					ENDIF
				ELSE
					SE1->E1_XBAND	:= 	""				
					SE1->E1_XCARMAS :=  ""	
					SE1->E1_XFORMPG	:= 	QRYEXC->Z7_FORMA
					SE1->E1_XCODAUT :=  ""				
				ENDIF 			 			
				
			SE1->(MsUnLock())
			
			QRYEXC->(DBSKIP())
		ENDDO
	ENDDO
Return()


User Function TSTFRCAR()
	Local aRecSe1c	:= {}
	Local nI 		:= 0 
	Local nPosSe1	:= 0 
	
	_cEmp		:= "01"	
	_cFilial	:= "00101MG0006"

	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
	
	DBSELECTAREA("SE1")
	SE1->(DBSETORDER(1))
	
	IF SE1->(DBSEEK("00101MG0006001000005004"))
		
		//SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO)
		IF Ascan(aRecSe1c,"00101MG0006001000005004NF ") == 0 
			AADD(aRecSe1c,{SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO), SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_TIPO })			
		ENDIF 
		
		For nI := 1 To Len(aRecSe1c)		
			IF aScan(aRecSe1c,{|x| x[1] == "00101MG0006001000005004NF "}) > 0 
				U_ALFINFP(.F.,aRecSe1c[nI])
			ENDIF
		Next nI 
	ENDIF 
RESET ENVIRONMENT

Return()