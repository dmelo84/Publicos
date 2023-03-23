
/*/{Protheus.doc} A103VCTO
Recalcula os vencimentos com base na nova condição de pagamento
@author Fabio Sales | www.compila.com.br
@since 01/09/2017
@version 1.0
/*/	

User Function A103VCTO()
Local aParam1		:= PARAMIXB[1]
Local nlValNF 		:= PARAMIXB[2]
Local clConPgto		:= PARAMIXB[3]
Local nlValIPI 		:= PARAMIXB[4]
Local dlEmissao 	:= PARAMIXB[5]
Local nlValSol		:= PARAMIXB[6]	
Local aVencto 		:= nil
Local llVldCdPg,aLinha
Local nI, nY
Local aArea		:= GetArea()
Local nRecZ01		:= 0
Local nQtdeParc		:= 0  
Loca lFirst			:= .T.

IF !EMPTY(clConPgto)

	aVencto	:= Condicao(nlValNF,clConPgto,nlValIPI,dlEmissao,nlValSol)
	IF EMPTY(aParam1)		
		lFirst	:= .T.
	ELSE 
		IF EMPTY(aParam1[1,2])
			lFirst	:= .T.
		ELSE
			IF LEN(aParam1) == LEN(aVencto)
				lFirst	:= .F.
				
				aVencto := {}
				FOR nI := 1 TO LEN(aParam1)
				
					aLinha	:= {}
					FOR nY := 2 TO 3
						
						aadd(aLinha, aParam1[nI,nY])
					NEXT nY
					
					aadd(aVencto, aClone(aLinha))
				NEXT nI
			ELSE 
				aVencto := Condicao(nlValNF,clConPgto,nlValIPI,dlEmissao,nlValSol)
				lFirst	:= .T.			
			ENDIF
		ENDIF
	ENDIF
	
	
	llVldCdPg		:= GetNewPar("AL_XVLDCON",.T.) //| Habilita recalculo da condicao de pgto |
	IF llVldCdPg .AND. lFirst 
	
	
		IF clConPgto == "001" .AND. !EMPTY(SF1->F1_XVENC) .AND. l103Class
			aVencto[1][1]:= SF1->F1_XVENC
		ELSE
		
			/*------------------------------------------------------ Augusto Ribeiro | 18/12/2018 - 5:36:36 PM
				Utiliza vencimentos e valores informados pelo usuário. 
			------------------------------------------------------------------------------------------*/
			DBSELECTAREA("Z01")
			Z01->(DBSETORDER(1))//| Z01_FILIAL+Z01_DOC+Z01_SERIE+Z01_FORNEC+Z01_LOJA+Z01_PARC
			IF Z01->(DBSEEK(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
				nRecZ01		:= Z01->(RECNO())
				aParcZ01	:= {}
				WHILE Z01->(!EOF()) .AND. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == Z01->(Z01_FILIAL+Z01_DOC+Z01_SERIE+Z01_FORNEC+Z01_LOJA)
				
					AADD(aParcZ01, {Z01->Z01_VENCTO, Z01->Z01_VALOR} )
					
					Z01->(DBSKIP())
				ENDDO 
				
			
				IF LEN(aParcZ01) == LEN(aVencto)
					aVencto := {}
					FOR nI := 1 TO LEN(aParcZ01)
					
						aLinha	:= {}
						FOR nY := 1 TO 2
							
							aadd(aLinha, aParcZ01[nI,nY])
						NEXT nY
						
						aadd(aVencto, aClone(aLinha))
					NEXT nI
				ENDIF			

			ENDIF
		ENDIF
	ENDIF
ENDIF
	


RestArea(aArea)
Return(aVencto)

