#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"  

Static dLastPcc  := CTOD("22/06/2015")

/*/{Protheus.doc} alValLiq
Retorna os valores a receber do título, o mesmo do campo recebido.
Alguns trechos desta rotina foram baseadas na rotina de baixa padrão.
na tela de baixa.
@author Fabio Sales | www.compila.com.br
@since 18/04/2018
@version version
@param clTable , C , Tabela de parâmetro
@return nVal
@example alValLiq("SE1")
@see (links_or_references)
/*/

USER FUNCTION alValLiq(clTable)

	Local nValDec 		:= 0 
	Local nValJuros		:= 0
	Local nTotAbImp		:= 0
	Local nPis			:= 0 
	Local nCofins		:= 0
	Local nCsll			:= 0
	Local nVal 			:= 0	
	Local _cCodEmp 		:= ""
	Local _cCodFil		:= ""
	Local _cFilNew		:= ""
	Local nTotAdto		:= 0
	Local nVlrBaixa		:= 0
	Local lBaixaAbat	:= .F.
	Local lBxCec		:= .F.	
	Local lBxLiq		:= .F.
	Local lTipBxCP		:= .F.	
	Local lSigaloja		:= .F.
	Local nTotMult		:= 0
	Local lPccBxCr		:= FPccBxCr()
	Local lIrPjBxCr		:= FIrPjBxCr()	//| Controla IRPJ na baixa
			
	Private lRaRtImp	:= FRaRtImp()	//| Define se ha retencao de impostos PCC/IRPJ no R.A
	Private nParciais	:= 0
	Private aBaixaSE5	:= {}
	
	lBQ10925 := SuperGetMV("MV_BQ10925",,"2") == "1" .And. !lRaRtImp		
					
	IF clTable == "SE1" //| Calculo do Valor Líquido para campo customizado.
	
	
		
		
		IF SE1->E1_SALDO == 0 //| Títutlo Totalmente baixado.
			
			IF 	SE1->E1_TIPO <> "NF"
			
				nVal := SE1->E1_VALOR 
			
			ELSE
				
				//| Calcula o Valor líquido do titulo totalmente baixado.
				
				clQuery := " SELECT " 
				clQuery += "	(SUM(VALOR + MULTA+ SDACRES) - SUM(COF + CSLL + PIS + IRFF + ISS + SDDECRE )) VAL_LIQ "
				clQuery += " FROM "
				clQuery += "	( "
				clQuery += "		SELECT  E1_FILIAL "
				clQuery += "			,E1_PREFIXO "
				clQuery += "			,E1_NUM "
				clQuery += "			,E1_TIPO "
				clQuery += "			,CASE WHEN E1_TIPO ='COF' THEN SUM(E1_VALOR)   ELSE 0 END COF	"
				clQuery += "			,CASE WHEN E1_TIPO ='CSL' THEN SUM(E1_VALOR)   ELSE 0 END CSLL	"
				clQuery += "			,CASE WHEN E1_TIPO ='PIS' THEN SUM(E1_VALOR)   ELSE 0 END PIS 	"
				clQuery += "			,CASE WHEN E1_TIPO ='IR-' THEN SUM(E1_VALOR)   ELSE 0 END IRFF	"
				clQuery += "			,CASE WHEN E1_TIPO ='IS-' THEN SUM(E1_VALOR)   ELSE 0 END ISS 	"
				clQuery += "			,CASE WHEN E1_TIPO ='NF'  THEN SUM(E1_VALOR)   ELSE 0 END VALOR	"
				clQuery += "			,CASE WHEN E1_TIPO ='NF'  THEN SUM(E1_MULTA)   ELSE 0 END MULTA	"
				clQuery += "			,CASE WHEN E1_TIPO ='NF'  THEN SUM(E1_SDDECRE) ELSE 0 END SDDECRE "
				clQuery += "			,CASE WHEN E1_TIPO ='NF'  THEN SUM(E1_SDACRES) ELSE 0 END SDACRES "
				clQuery += "		FROM SE1010 SE1 WITH(NOLOCK)"
				clQuery += "		WHERE E1_FILIAL='"+ SE1->E1_FILIAL +"' " 
				clQuery += "			AND E1_NUM ='"+SE1->E1_NUM+"' " 
				clQuery += "			AND E1_PREFIXO='"+SE1->E1_PREFIXO+"' " 
				clQuery += "			AND SE1.D_E_L_E_T_='' "
				clQuery += "			AND E1_SALDO=0 "
				clQuery += "		GROUP BY E1_FILIAL "
				clQuery += "			,E1_PREFIXO "
				clQuery += "			,E1_NUM "
				clQuery += "			,E1_TIPO "
				clQuery += "	) TRB "	
				
				IF SELECT("VALLIQ") <> 0
					VALLIQ->(DBCLOSEAREA()) 
				ENDIF	
				
				TCQUERY clQuery NEW ALIAS "VALLIQ"
									
				IF !VALLIQ->(EOF())
				
					nVal := VALLIQ->VAL_LIQ
					
				ENDIF	
			
			ENDIF
			
		ELSE
		
			/*---------------------------------------
			Realiza a TROCA DA FILIAL CORRENTE 
			-----------------------------------------*/
				
			_cCodEmp 	:= SM0->M0_CODIGO
			_cCodFil	:= SM0->M0_CODFIL
			_cFilNew	:= SE1->E1_FILIAL //| CODIGO DA FILIAL DE DESTINO
					
			IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
				CFILANT := _cFilNew
				opensm0(_cCodEmp+CFILANT)
			ENDIF	
			
			nVal	:= xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,,2)
													
			nTotAbImp := 0
			
			nTxMoeda 	:= If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(ddatabase,SE1->E1_MOEDA)),0)
			
			SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",ddatabase,@nTotAbImp,,,,,,SE1->E1_FILIAL, nTxMoeda)								
			
			If (SE1->E1_VALOR > SE1->E1_SALDO) .And. Empty(SE1->E1_TIPOLIQ)
				
				//| Procura pelas baixas deste título
	
				lTipBxCP:=lRaRtImp
				
				aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,@nTotAdto, @lBaixaAbat,SE1->E1_CLIENTE,SE1->E1_LOJA, @nVlrBaixa, , @lBxCec, @lBxLiq ,@lSigaloja, @lTipBxCP)
					
				For x := 1 To Len(aBaixaSE5)
				
					nParciais += aBaixaSE5[x][8]
					
		   			If lPccBxCR .And. lRaRtImp
		   			 
					   nParciais += aBaixaSE5[x][18]+aBaixaSE5[x][19]+aBaixaSE5[x][20]+aBaixaSE5[x][30]// somar impostos PCC
					    
					Elseif lIrPjBxCr .And. lRaRtImp
					  
				  		nParciais += aBaixaSE5[x][30]
				  	
					Endif  
					 
					nTotMult	 += (aBaixaSE5[x][14]+aBaixaSE5[x][15])  // Soma Acrescimo mais Multa
					   
					If lRaRtImp
					
				 		nParciais += aBaixaSE5[x][32]+aBaixaSE5[x][33]
				 		nTotAbat  -= aBaixaSE5[x][32]+aBaixaSE5[x][33]
				 		
					Endif
					
				Next
				
				nParciais += nTotAdto
				
				//| Soma valor de decrescimo em baixas parciais, para evitar
				//| diferencas entre valor original e valor recebido
				
				If SE1->E1_SDDECRE <> SE1->E1_DECRESC
					nParciais += ( SE1->E1_DECRESC - SE1->E1_SDDECRE )
				EndIf
				
			Else
				nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
			Endif	
			
			If "RA" $ SE1->E1_TIPO
				nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
			Endif	
			
			nVal := SE1->E1_VALOR -	nParciais														
			
			//|nValAbati	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL,,)
			
			nValDec		:= SE1->E1_SDDECRE		
			nValJuros	:= SE1->E1_SDACRES
			
			//| Simula o calculo do Pis, Cofins e cll como se fosse na baixa.
															
			If lPccBxCR .AND. nVal > 0 .AND.  ddatabase > dLastPcc .AND. SE1->E1_TIPO # MVRECANT
			
				aPcc	:= newMinPcc(ddatabase, nVal,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
				nPis	:= aPcc[2]
				nCofins	:= aPcc[3]
				nCsll	:= aPcc[4]
				
				//|nVal	:= nVal - (nPis + nCofins + nCsll)
				
				nPcc :=  nPis + nCofins + nCsll				
				
				nVal	:= SE1->E1_SALDO - nPcc 
				
			EndIf
			
			nVal := nVal - nValDec + nValJuros - nTotAbImp //| Saldo Líquido pendente de Baixa
			
			nVal := nVal + nParciais //| Devolvo o valor parcial baixado para compor o Valor líquido original.
			
			/*---------------------------------------
				Restaura FILIAL  
			-----------------------------------------*/
			
			IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
				CFILANT := _cCodFil
				opensm0(_cCodEmp+CFILANT)			 			
			ENDIF 												
					
		ENDIF
		
	ENDIF
		
	
Return(nVal)

