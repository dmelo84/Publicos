#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"

#DEFINE EOL Chr(13)+Chr(10)

/*/{Protheus.doc} CPIMP01X
Função generica para importação de cadastros 
@author Jonatas Oliveira | www.compila.com.br
@since 15/12/2015
@version 1.0
@param _cAliasT, C, Alias da tabela 
@param aDados,A,Dados à ser importado
@param lAltera,L,Altera registro existente 
@return aRet, Retorno contendo se foi executado e mensagem de recusa
/*/
User Function CPIMP01X(_cAliasT,aDados,lAltera,aItens)
	Local aRet		:= {.T., ""}
	Local cChave 	:= ""
	Local nIndice	:= 0
	Local nPosChv	:= 0
	Local nPosFil	:= 0 
	Local nPosChv2	:= 0
	Local nPosChv3	:= 0 
	Local nPosChv4	:= 0 
	Local nPosChv5	:= 0 
	Local nPosChv6	:= 0 
	Local nPosChv7	:= 0
	Local nPosE1Ems	:= 0
	Local nPosE1Vnc	:= 0
	    
	Local aDadosAux	:= {}
	Local nI		:= 0
	Local cModeloImp	:= ""
	Local aParam := {}

	Local _cCodEmp 	:= ""
	Local _cCodFil	:= ""
	Local _cFilNew	:= ""
	Local cParcel	:= ""
		 
	Local dDataAnt	:= DDATABASE 

	Local _nOpc		:= 0 //|3- Inclusão, 4- Alteração, 5- Exclusão|
	Private _cRotina	:= ""

	DEFAULT lAltera	:= .T.

	IF LEN(aDados) > 0

		IF _cAliasT == "SA1"	
			cModeloImp	:= "EXECAUTO"
			nIndice		:= 3 //|A1_FILIAL+A1_CGC|		
									
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "A1_CGC"		})
						
			//nIndice		:= 1 //|A1_FILIAL+A1_CGC|
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "A1_COD"		})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "A1_LOJA"		})
			
			_cRotina	:= "MATA030"

			IF nPosChv > 0 
				cChave	:= XFILIAL(_cAliasT)+aDados[nPosChv][2]
				//cChave	:= XFILIAL(_cAliasT) + aDados[nPosChv][2] + aDados[nPosChv1][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SA1][A1_CGC]"
			ENDIF 

		ELSEIF _cAliasT == "FIL"	
			cModeloImp	:= "RECLOCK"
			nIndice		:= 1 //|FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_TIPO+FIL_BANCO+FIL_AGENCI+FIL_CONTA|

			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "FIL_FORNEC"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "FIL_LOJA"		})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "FIL_TIPO"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "FIL_BANCO"		})
			nPosChv5 	:= aScan( aDados , { |x| AllTrim(x[01]) == "FIL_AGENCI"		})
			nPosChv6 	:= aScan( aDados , { |x| AllTrim(x[01]) == "FIL_CONTA"		})		



			_cRotina	:= "MATA020"

			IF nPosChv > 0 
				cChave	:= XFILIAL(_cAliasT)+aDados[nPosChv][2]+aDados[nPosChv2][2]+aDados[nPosChv3][2]+aDados[nPosChv4][2]+aDados[nPosChv5][2] +aDados[nPosChv6][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [FIL][FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_TIPO+FIL_BANCO+FIL_AGENCI+FIL_CONTA]"
			ENDIF 	

		ELSEIF _cAliasT == "SA2"
			cModeloImp	:= "EXECAUTO"	
			nIndice		:= 3 //|A2_FILIAL+A2_CGC|
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "A2_CGC"		})
			_cRotina	:= "MATA020"

			IF nPosChv > 0 
				cChave	:= XFILIAL(_cAliasT)+aDados[nPosChv][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SA2][A2_CGC]"
			ENDIF	

		ELSEIF _cAliasT == "SB1"
			cModeloImp	:= "EXECAUTO"	
			nIndice		:= 1 //|B1_FILIAL+B1_COD|
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "B1_COD"		})
			_cRotina	:= "MATA010"

			IF nPosChv > 0 
				cChave	:= XFILIAL(_cAliasT)+aDados[nPosChv][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SB1][B1_COD]"
			ENDIF	
		ELSEIF _cAliasT == "SB5"	
			cModeloImp	:= "EXECAUTO"
			nIndice		:= 1 //|B5_FILIAL+B5_COD|
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "B5_COD"		})
			_cRotina	:= "MATA180"

			IF nPosChv > 0 
				cChave	:= XFILIAL(_cAliasT)+aDados[nPosChv][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SB5][B5_COD]"
			ENDIF	

		ELSEIF _cAliasT == "SRV"	
			cModeloImp	:= "MVC"
			nIndice		:= 1 //| RV_FILIAL+RV_COD
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RV_COD"		})
			_cRotina	:= "GPEA040"

			IF nPosChv > 0 
				cChave	:= XFILIAL(_cAliasT)+aDados[nPosChv][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SRV][RV_COD]"
			ENDIF 
			
		ELSEIF _cAliasT == "RHK"	
			//cModeloImp	:= "MVC3"
			cModeloImp	:= "RECLOCK"
			
			nIndice		:= 1 //| RHK_FILIAL, RHK_MAT, RHK_TPFORN, RHK_CODFOR
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RHK_FILIAL"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RHK_MAT"		})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RHK_TPFORN"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RHK_CODFOR"		})
			_cRotina	:= "GPEA001"

			IF nPosChv1 > 0 .AND. nPosChv2 > 0 .AND. nPosChv3 > 0 .AND. nPosChv4 > 0
				cChave	:=aDados[nPosChv1][2] + aDados[nPosChv2][2] + aDados[nPosChv3][2] + aDados[nPosChv4][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [RHK][RHK_MAT][RHK_TPFORN][RHK_CODFOR]"
			ENDIF  		  
					 	
		ELSEIF _cAliasT == "RHL"	
			//cModeloImp	:= "MVC3"
			cModeloImp	:= "RECLOCK"			
			nIndice		:= 1 //| RHK_FILIAL, RHK_MAT, RHK_TPFORN, RHK_CODFOR
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RHL_FILIAL"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RHL_MAT"		})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RHL_TPFORN"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RHL_CODFOR"		})
			nPosChv5 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RHL_CODIGO"		})
			
			_cRotina	:= "GPEA001"

			IF nPosChv1 > 0 .AND. nPosChv2 > 0 .AND. nPosChv3 > 0 .AND. nPosChv4 > 0 .AND. nPosChv5 > 0
				cChave	:=aDados[nPosChv1][2] + aDados[nPosChv2][2] + aDados[nPosChv3][2] + aDados[nPosChv4][2] + " " + aDados[nPosChv5][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [RHL][RHL_MAT][RHL_TPFORN][RHL_CODFOR]"
			ENDIF  		
		ELSEIF _cAliasT == "SR0"	
			cModeloImp	:= "RECLOCK"
			nIndice		:= 1 //| R0_FILIAL+R0_MAT+R0_CODIGO+R0_TPVALE
			//nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RV_COD"		})

			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R0_FILIAL"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R0_MAT"			})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R0_CODIGO"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R0_TPVALE"		})


			_cRotina	:= "GPEA140"

			IF nPosChv2 > 0 .AND.  nPosChv3 > 0 .AND.  nPosChv4 > 0  
				//!EMPTY(aDados[nPosChv2][2]) .AND. !EMPTY(aDados[nPosChv3][2]) .AND. !EMPTY(aDados[nPosChv4][2]) 		 

				IF nPosChv > 0 
					cChave	:= aDados[nPosChv][2] + aDados[nPosChv2][2] + aDados[nPosChv3][2] + aDados[nPosChv4][2] 
				ELSE
					aRet[1]	:= .F.
					aRet[2]	:= "Chave Principal não localizada [SR0][R0_FILIAL]"
				ENDIF
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Campos da Chave Principal vazios"
			ENDIF 
		
		ELSEIF _cAliasT == "SPI"	
			cModeloImp	:= "RECLOCK"
			nIndice		:= 1 //| PI_FILIAL+PI_MAT+PI_PD+Dtos(PI_DATA)
			//nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RV_COD"		})

			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "PI_FILIAL"	})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "PI_MAT"		})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "PI_PD"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "PI_DATA"	})


			_cRotina	:= "GPEA140"

			IF nPosChv2 > 0 .AND.  nPosChv3 > 0 .AND.  nPosChv4 > 0  
				//!EMPTY(aDados[nPosChv2][2]) .AND. !EMPTY(aDados[nPosChv3][2]) .AND. !EMPTY(aDados[nPosChv4][2]) 		 

				IF nPosChv > 0 
					cChave	:= aDados[nPosChv][2] + aDados[nPosChv2][2] + aDados[nPosChv3][2] + DTOS(aDados[nPosChv4][2]) 
				ELSE
					aRet[1]	:= .F.
					aRet[2]	:= "Chave Principal não localizada [SPI][PI_FILIAL]"
				ENDIF
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Campos da Chave Principal vazios"
			ENDIF 
			
		ELSEIF _cAliasT == "SR3"	
			cModeloImp	:= "RECLOCK"
			//|R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_SEQ+R3_TIPO+R3_PD|
			nIndice		:= 1 //| R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_SEQ+R3_TIPO+R3_PD
			//nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RV_COD"		})

			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R3_FILIAL"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R3_MAT"			})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R3_DATA"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R3_SEQ"			})
			nPosChv5 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R3_TIPO"		})
			nPosChv6 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R3_PD"			})


			_cRotina	:= "GPEA250"

			IF nPosChv > 0 .AND. nPosChv2 > 0 .AND. nPosChv3 > 0 .AND.  nPosChv4 > 0  .AND.  nPosChv5 > 0  .AND.  nPosChv6 > 0 
				//!EMPTY(aDados[nPosChv2][2]) .AND. !EMPTY(aDados[nPosChv3][2]) .AND. !EMPTY(aDados[nPosChv4][2]) 		 

				IF nPosChv > 0 
					cChave	:= aDados[nPosChv][2] + aDados[nPosChv2][2] + DTOS(aDados[nPosChv3][2]) + aDados[nPosChv4][2] + aDados[nPosChv5][2] + aDados[nPosChv6][2] 
				ELSE
					aRet[1]	:= .F.
					aRet[2]	:= "Chave Principal não localizada [SR3][R3_FILIAL]"
				ENDIF
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Campos da Chave Principal vazios"
			ENDIF 

		ELSEIF _cAliasT == "SR8"	
			cModeloImp	:= "RECLOCK"
			//|R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_SEQ+R3_TIPO+R3_PD|
			nIndice		:= 6 //| R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPOAFA
			//nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RV_COD"		})

			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R8_FILIAL"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R8_MAT"			})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R8_DATAINI"		})		
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "R8_TIPOAFA"		})

			_cRotina	:= "GPEA240"

			IF nPosChv > 0 .AND. nPosChv2 > 0 .AND. nPosChv3 > 0 .AND.  nPosChv4 > 0   
				//!EMPTY(aDados[nPosChv2][2]) .AND. !EMPTY(aDados[nPosChv3][2]) .AND. !EMPTY(aDados[nPosChv4][2]) 		 

				IF nPosChv > 0 
					cChave	:= aDados[nPosChv][2] + aDados[nPosChv2][2] + DTOS(aDados[nPosChv3][2]) + aDados[nPosChv4][2]  
				ELSE
					aRet[1]	:= .F.
					aRet[2]	:= "Chave Principal não localizada [SR8][R8_FILIAL]"
				ENDIF
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Campos da Chave Principal vazios"
			ENDIF 	

		ELSEIF _cAliasT == "SN1"	
			cModeloImp	:= "EXECAUTO2"
			nIndice		:= 1 //|N1_FILIAL+N1_CBASE+N1_ITEM|
			nPosFil 	:= aScan( aDados , { |x| AllTrim(x[01]) == "N1_FILIAL"		})
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "N1_CBASE"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "N1_ITEM"		})
			_cRotina	:= "ATFA012"

			IF nPosFil > 0 .AND. nPosChv > 0 .AND. nPosChv2 > 0  
				cChave	:= aDados[nPosFil][2] + aDados[nPosChv][2] + aDados[nPosChv2][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SN1][N1_CBASE][N1_ITEM]"
			ENDIF		


		ELSEIF _cAliasT == "SRA"
			cModeloImp	:= "EXECAUTO3"	
			nIndice		:=  1//|RA_FILIAL, RA_MAT|

			nPosFil 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RA_FILIAL"		})
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RA_MAT"		})

			_cRotina	:= "GPEA010"



			IF nPosChv > 0 
				cChave	:= aDados[nPosFil][2]+aDados[nPosChv][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SRA][RA_MAT]"
			ENDIF	
			

		ELSEIF _cAliasT == "SRG"
			cModeloImp	:= "RECLOCK"	
			nIndice		:=  1//|RA_FILIAL, RA_MAT|

			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RG_FILIAL"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RG_MAT"			})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RG_DTGERAR"		})

			//_cRotina	:= "GPEA010"



			IF nPosChv1 > 0 .AND. nPosChv2 > 0 .AND. nPosChv3 > 0
 				cChave	:= aDados[nPosChv1][2]+aDados[nPosChv2][2]+DTOS(aDados[nPosChv3][2])
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SRG][RG_FILIAL][RG_MAT][RG_DTGERAR]"
			ENDIF	


		ELSEIF _cAliasT == "SRR"
			cModeloImp	:= "RECLOCK"	
			nIndice		:=  1//|RR_FILIAL, RR_MAT, RR_TIPO3, RR_DATA, RR_PD, RR_CC

			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RR_FILIAL"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RR_MAT"		})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RR_TIPO3"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RR_DATA"		})
			nPosChv5 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RR_PD"		})
			nPosChv6 	:= aScan( aDados , { |x| AllTrim(x[01]) == "RR_CC"		})

			//_cRotina	:= "GPEA010"



			IF nPosChv1 > 0 .AND. nPosChv2 > 0 .AND. nPosChv3 > 0  .AND. nPosChv4 > 0 .AND. nPosChv5 > 0 .AND. nPosChv6 > 0
				cChave	:= aDados[nPosChv1][2] + aDados[nPosChv2][2] + aDados[nPosChv3][2] + DTOS(aDados[nPosChv4][2]) + aDados[nPosChv5][2] + aDados[nPosChv6][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SRR][RR_FILIAL][RR_MAT][RR_TIPO3][RR_DATA] [RR_PD] [RR_CC]"
			ENDIF
		
		ELSEIF _cAliasT == "SB9"	
			cModeloImp	:= "EXECAUTO"
			nIndice		:= 1 //|B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)|
			nPosFil 	:= aScan( aDados , { |x| AllTrim(x[01]) == "B9_FILIAL"		})
			//nPosFil		:= nPosChv
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "B9_COD"		})
			nPosChv2	:= aScan( aDados , { |x| AllTrim(x[01]) == "B9_LOCAL"		})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "B9_DATA"		})                                                                          
			
			_cRotina	:= "MATA220"

			IF nPosFil > 0 .AND. nPosChv1 > 0 .AND. nPosChv2 > 0 .AND. nPosChv3 > 0
				cChave	:=	aDados[nPosFil][2] + ;
							ALLTRIM(aDados[nPosChv1][2]) + SPACE(TAMSX3("B1_COD")[1] 	- LEN(ALLTRIM(aDados[nPosChv1][2]))) +	;
							ALLTRIM(aDados[nPosChv2][2]) + SPACE(TAMSX3("B9_LOCAL")[1] 	- LEN(ALLTRIM(aDados[nPosChv2][2]))) + 	;
							DTOS(aDados[nPosChv3][2])
												
				//cChave	:= aDados[nPosChv][2] + aDados[nPosChv1][2] + aDados[nPosChv2][2] + DTOS(aDados[nPosChv3][2])
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SB9][B9_FILIAL][B9_COD][B9_LOCAL][B9_DATA]"
			ENDIF 
		
		ELSEIF _cAliasT == "SBZ"	
			cModeloImp	:= "RECLOCK"
			nIndice		:= 1 //|BZ_FILIAL+BZ_COD|
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "BZ_FILIAL"		})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "BZ_COD"		})
			_cRotina	:= "MATA018"

			IF nPosChv > 0 
				cChave	:= aDados[nPosChv][2] + aDados[nPosChv1][2]
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SBZ][BZ_FILIAL][BZ_COD]"
			ENDIF 
		
		ELSEIF _cAliasT == "SA6"	
			cModeloImp	:= "RECLOCK"
			nIndice		:= 1 //|A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON|
			nPosFil		:= aScan( aDados , { |x| AllTrim(x[01]) == "A6_FILIAL"	})
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "A6_COD"		})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "A6_AGENCIA"	})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "A6_NUMCON"	})
			
			_cRotina	:= "MATA070"
									
			IF nPosChv > 0 .AND. nPosChv1 > 0 .AND. nPosChv2 > 0
				cChave	:= ALLTRIM(aDados[nPosFil][2]) + (SPACE(TAMSX3("A6_FILIAL")[1] - LEN(ALLTRIM(aDados[nPosFil][2])))) + aDados[nPosChv][2] + ALLTRIM(aDados[nPosChv1][2]) + (SPACE(TAMSX3("A6_AGENCIA")[1] - LEN(ALLTRIM(aDados[nPosChv1][2]))))  + (ALLTRIM(aDados[nPosChv2][2]) + SPACE(TAMSX3("A6_NUMCON")[1] - LEN(ALLTRIM(aDados[nPosChv2][2]))))
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SA6][A6_COD][A6_AGENCIA][A6_NUMCON]"
			ENDIF

		ELSEIF _cAliasT == "SAL"	
			cModeloImp	:= "RECLOCK"
			nIndice		:= 1 //|AL_FILIAL+AL_COD+AL_ITEM|
			
			nPosFil		:= aScan( aDados , { |x| AllTrim(x[01]) == "AL_FILIAL"	})
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "AL_COD"		})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "AL_ITEM"	})
			
			
			_cRotina	:= "MATA114"
									
			IF nPosFil > 0 .AND. nPosChv > 0 .AND. nPosChv1 > 0 
				cChave	:= ALLTRIM(aDados[nPosFil][2]) +  ALLTRIM(aDados[nPosChv][2]) + ALLTRIM(aDados[nPosChv1][2])
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SAL][AL_FILIAL][AL_COD][AL_ITEM]"
			ENDIF
		
		ELSEIF _cAliasT == "SAI"	
			cModeloImp	:= "RECLOCK"
			nIndice		:= 3 //|AI_FILIAL+AI_GRUSER+AI_USER+AI_ITEM|
			
			nPosFil		:= aScan( aDados , { |x| AllTrim(x[01]) == "AI_FILIAL"	})
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "AI_GRUSER"	})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "AI_USER"	})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "AI_ITEM"	})
			
			
			_cRotina	:= "MATA114"
									
			IF nPosFil > 0 .AND. nPosChv1 > 0 .AND. nPosChv2 > 0 
				cChave	:= ALLTRIM(aDados[nPosFil][2]) + SPACE(TAMSX3("AI_GRUSER")[1])   + ALLTRIM(aDados[nPosChv1][2]) + ALLTRIM(aDados[nPosChv2][2])
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SAI][AI_FILIAL][AI_GRUSER][AI_USER][AI_ITEM]"
			ENDIF
		

			
		ELSEIF _cAliasT == "CN7"	
			cModeloImp	:= "RECLOCK"
			nIndice		:= 2 //|CN7_FILIAL+CN7_CODIGO+CN7_COMPET|
			//nPosFil		:= aScan( aDados , { |x| AllTrim(x[01]) == "A6_FILIAL"	})
			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "CN7_CODIGO"		})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "CN7_COMPET"	})
			
			
			_cRotina	:= "MATA070"
									
			IF nPosChv > 0 .AND. nPosChv1 > 0 
				cChave	:= XFILIAL("CN7") + ALLTRIM(aDados[nPosChv][2]) + (SPACE(TAMSX3("CN7_CODIGO")[1] - LEN(ALLTRIM(aDados[nPosChv][2]))))  +  ALLTRIM(aDados[nPosChv1][2]) + (SPACE(TAMSX3("CN7_COMPET")[1] - LEN(ALLTRIM(aDados[nPosChv1][2]))))
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [CN7][CN7_CODIGO][CN7_COMPET]"
			ENDIF	
			
		ELSEIF _cAliasT == "SE1"	
			cModeloImp	:= "EXECAUTO"
			nIndice		:= 1 //|E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO|
			nPosFil 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_FILIAL"		})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_PREFIXO"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_NUM"			})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_PARCELA"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_TIPO"		})
			
			nPosE1Ems	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_EMISSAO"		})
			
			_cRotina	:= "FINA040"
			
			cParcel := SPACE(TAMSX3("E2_PARCELA")[1])
			
			IF nPosChv3 > 0 
		 		cParcel	:= ALLTRIM(aDados[nPosChv3][2]) + SPACE(TAMSX3("E1_PARCELA")[1] 	- LEN(ALLTRIM(aDados[nPosChv3][2])))		 	
		 	ENDIF 

			IF nPosFil > 0 .AND. nPosChv1 > 0  .AND. nPosChv2 > 0 .AND. nPosChv4 > 0 .AND. nPosE1Ems > 0 
			
				IF LEN(ALLTRIM(aDados[nPosChv2][2])) > TAMSX3("E1_NUM")[1]
					aRet[1]	:= .F.
					aRet[2]	:= "Tamanho do campo de numero de titulo maior que o permitido "
				ELSE
					cChave	:= 	  aDados[nPosFil][2] ;
					 			+ ALLTRIM(aDados[nPosChv1][2]) + SPACE(TAMSX3("E1_PREFIXO")[1] 	- LEN(ALLTRIM(aDados[nPosChv1][2]))) ;							
								+ ALLTRIM(aDados[nPosChv2][2]) + SPACE(TAMSX3("E1_NUM")[1] 		- LEN(ALLTRIM(aDados[nPosChv2][2]))) ;
								+ cParcel ;
								+ ALLTRIM(aDados[nPosChv4][2]) + SPACE(TAMSX3("E1_TIPO")[1] 	- LEN(ALLTRIM(aDados[nPosChv4][2]))) 
				ENDIF			 
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SE1][E1_FILIAL] [E1_PREFIXO] [E1_NUM] [E1_PARCELA] [E1_TIPO]"
			ENDIF	
		
		ELSEIF _cAliasT == "SE2"	
			cModeloImp	:= "EXECAUTO"
			nIndice		:= 1 //|E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO|
			nPosFil 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_FILIAL"		})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_PREFIXO"		})
			nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_NUM"			})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_PARCELA"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_TIPO"		})
			
			nPosE1Ems	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_EMISSAO"		})
			
			_cRotina	:= "FINA050"

			IF nPosFil > 0 .AND. nPosChv1 > 0  .AND. nPosChv2 > 0  .AND. nPosChv4 > 0 .AND. nPosE1Ems > 0
			
				IF LEN(ALLTRIM(aDados[nPosChv2][2])) > TAMSX3("E2_NUM")[1]
					aRet[1]	:= .F.
					aRet[2]	:= "Tamanho do campo de numero de titulo maior que o permitido "
				ELSE
					cParcel := SPACE(TAMSX3("E2_PARCELA")[1])
				
				 	IF nPosChv3 > 0 
				 		cParcel	:= ALLTRIM(aDados[nPosChv3][2]) + SPACE(TAMSX3("E2_PARCELA")[1] 	- LEN(ALLTRIM(aDados[nPosChv3][2])))			 	
				 	ENDIF 
				 	
					cChave	:= 	  aDados[nPosFil][2] ;
					 			+ ALLTRIM(aDados[nPosChv1][2]) + SPACE(TAMSX3("E2_PREFIXO")[1] 	- LEN(ALLTRIM(aDados[nPosChv1][2]))) ;							
								+ ALLTRIM(aDados[nPosChv2][2]) + SPACE(TAMSX3("E2_NUM")[1] 		- LEN(ALLTRIM(aDados[nPosChv2][2]))) ;
								+ cParcel ;
								+ ALLTRIM(aDados[nPosChv4][2]) + SPACE(TAMSX3("E2_TIPO")[1] 	- LEN(ALLTRIM(aDados[nPosChv4][2])))
				
				ENDIF 			 
							 
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SE2][E2_FILIAL] [E2_PREFIXO] [E2_NUM] [E2_PARCELA] [E2_TIPO]"
			ENDIF
			
		ELSEIF _cAliasT == "CTT"	
			cModeloImp	:= "EXECAUTO"
			nIndice		:= 1 //|CTT_FILIAL+CTT_CUSTO|		
															
			nPosFil 	:= aScan( aDados , { |x| AllTrim(x[01]) == "CTT_FILIAL"		})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "CTT_CUSTO"		})
			
			_cRotina	:= "CTBA030"

			IF nPosFil > 0 .AND. nPosChv1 > 0 
				cChave	:= aDados[nPosFil][2] + aDados[nPosChv1][2]
				
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [CTT]->[CTT_FILIAL][CTT_CUSTO]"
			ENDIF 	
							
		ENDIF

		IF aRet[1]

			/*-------------------------------------------------------
			Jonatas Oliveira | www.compila.com.br
			15/12/2015
			Rotina Generica para MSExecAuto Tabelas Modelo1
			--------------------------------------------------------*/	
			IF nIndice > 0  
				DBSELECTAREA(_cAliasT)
				DBSETORDER(nIndice)

				IF DBSEEK(cChave) .AND. _cAliasT <> "SRR"  .AND. _cAliasT <> "RHK"

					IF lAltera
						_nOpc := 4
					ELSE
						aRet[1]	:= .F.
						aRet[2]	:= "Chave já existente"
					ENDIF

				ELSE
					_nOpc := 3
				ENDIF 
				
				If aRet[1]

					//BEGIN TRANSACTION  
	
					/*--------------------------
					EXECAUTO
					---------------------------*/
					IF cModeloImp == "EXECAUTO"
						lMsErroAuto := .F. // Variavel que informa a ocorrência de erros no ExecAuto
						lMSHelpAuto := .F.// Variavel de controle interno do ExecAuto
						lAutoErrNoFile := .T.    
						
						/*---------------------------------------
						Realiza a TROCA DA FILIAL CORRENTE 
						-----------------------------------------*/
						_cCodEmp 	:= SM0->M0_CODIGO
						_cCodFil	:= SM0->M0_CODFIL
						
						IF nPosFil > 0 
							_cFilNew	:= aDados[nPosFil][2] //| CODIGO DA FILIAL DE DESTINO 
						ELSE
							_cFilNew	:= _cCodFil
						ENDIF 
						
						IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
							CFILANT := _cFilNew
							opensm0(_cCodEmp+CFILANT)
						ENDIF	
						
						IF (_cAliasT == "SE1" .OR. _cAliasT == "SE2") .AND. nPosE1Ems > 0 
							IF DDATABASE <> aDados[nPosE1Ems][2]
								dDataAnt := DDATABASE
								DDATABASE := aDados[nPosE1Ems][2] 
							ENDIF 
						ENDIF 
						
						//Chamada de rotina de automatica de cadastro
						IF _cAliasT == "SE2" 
							MsExecAuto(&("{|x,y,z| "+_cRotina+"(x,y,z)}"), aDados, _nOpc)
						ELSE
							MsExecAuto(&("{|x,y| "+_cRotina+"(x,y)}"), aDados, _nOpc)
						ENDIF 
	
						If lMsErroAuto
							aRet [1] := .F.
							aRet [2] := "Falha na Alteração: "+ XCONVERRLOG(GetAutoGrLog()) +" ."  
						Else		  						
							aRet [1] := .T.
							aRet [2] := ""          
	
						Endif			
						
						IF DDATABASE <> dDataAnt
							DDATABASE := dDataAnt
						ENDIF 
	
					ELSEIF cModeloImp == "EXECAUTO2"
	
						/*---------------------------------------
						Realiza a TROCA DA FILIAL CORRENTE 
						-----------------------------------------*/
						_cCodEmp 	:= SM0->M0_CODIGO
						_cCodFil	:= SM0->M0_CODFIL
						_cFilNew	:= aDados[nPosFil][2] //| CODIGO DA FILIAL DE DESTINO 
	
						IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
							CFILANT := _cFilNew
							opensm0(_cCodEmp+CFILANT)
						ENDIF	
	
	
						lMsErroAuto := .F. // Variavel que informa a ocorrência de erros no ExecAuto
						lMSHelpAuto := .F.// Variavel de controle interno do ExecAuto
						lAutoErrNoFile := .T.
						INCLUI := .T.
	
						//Chamada de rotina de automatica de cadastro
						MsExecAuto(&("{|x,y,z| "+_cRotina+"(x,y,z)}"), aDados,aItens, _nOpc,aParam)
						//MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)
						If lMsErroAuto
							aRet [1] := .F.
							aRet [2] := "Falha na Alteração: "+ XCONVERRLOG(GetAutoGrLog()) +" ."  
						Else		  						
							aRet [1] := .T.
							aRet [2] := ""          
	
						Endif			
	
						/*---------------------------------------
						Restaura FILIAL  
						-----------------------------------------*/
						IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
							CFILANT := _cCodFil
							opensm0(_cCodEmp+CFILANT)			 			
						ENDIF 
	
	
					ELSEIF cModeloImp == "EXECAUTO3"
	
	
	
						lMsErroAuto := .F. // Variavel que informa a ocorrência de erros no ExecAuto
						lMSHelpAuto := .F.// Variavel de controle interno do ExecAuto
						lAutoErrNoFile := .T.
	
						//Chamada de rotina de automatica de cadastro
						MsExecAuto(&("{|x,y,k,w| "+_cRotina+"(x,y,k,w)}"),NIL,NIL, aDados, _nOpc)
						//MSExecAuto({|x,y,k,w| GPEA010(x,y,k,w)},NIL,NIL,aCabec,3)
	
						If lMsErroAuto
							aRet [1] := .F.
							aRet [2] := "Falha na Alteração: "+ XCONVERRLOG(GetAutoGrLog()) +" ."  
						Else		  						
							aRet [1] := .T.
							aRet [2] := ""          
	
						Endif		
	
	
						/*--------------------------
						MVC
						---------------------------*/
					ELSEIF cModeloImp == "MVC"
	
						aRet := aClone(impMVC(_cAliasT, nIndice, aDados, _nOpc,_cRotina))
					
					/*--------------------------
						MVC3 - MVC modelo 3
					---------------------------*/
					ELSEIF cModeloImp == "MVC3"
	
						aRet := aClone(impMVC3(_cAliasT, nIndice, _nOpc, aDados, _cRotina, aItens))					
	
					ELSEIF 	cModeloImp == "RECLOCK" .AND. aRet[1]
						aRet := aClone(impREC(_cAliasT, nIndice, aDados, _nOpc))
					ENDIF
					
				Endif 
				//END TRANSACTION
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Parametros Inválidos"
			ENDIF
		ENDIF
	ELSE
		aRet[1]	:= .F.
		aRet[2]	:= "Array Vazio"
	ENDIF 

Return(aRet)



/*-------------------------------------------------------
Converte Log para texto amigavel
--------------------------------------------------------*/	
STATIC FUNCTION XCONVERRLOG(aAutoErro)

	LOCAL cRet := ""
	LOCAL nX := 1

	FOR nX := 1 to Len(aAutoErro)
		cRet += aAutoErro[nX]+CHR(13)+CHR(10)
	NEXT nX

	cRet := STRTRAN(cRet,CHR(13)+CHR(10),"  ")                                          

RETURN cRet



/*/{Protheus.doc} impMVC
Importa registro via MVC
@author Augusto Ribeiro | www.compila.com.br
@since 05/01/2016
@version 
@param cAliasImp, C, Alias
@param nIndice, n, Indice
@param aDados, a, Dados
@param nOper, n, Operacao
@param cModel, C, Modelo de dados
@return aRet, {.F., ""}
@example
(examples)
@see (links_or_references)
/*/
Static Function impMVC(cAliasImp, nIndice, aDados, nOper,cModel)
	Local aRet		:= {.F., ""}
	local cWarn		:= ""
	Local oModel, oAux, oStruct
	Local nI		:= 0
	Local nPos 		:= 0
	Local lRet 		:= .T.
	Local aAux    	:= {}
	Local aCampos	:= {}


	dbSelectArea( cAliasImp )
	dbSetOrder( nIndice )



	oModFull := FWLoadModel( cModel )

	oModFull:SetOperation( nOper )

	oModFull:Activate()



	oModel 		:= oModFull:GetModel( cAliasImp + 'MASTER' )
	oStruct 	:= oModel:GetStruct()

	aCampos  	:= oStruct:GetFields()


	//| Atribui Valores ao Model|
	For nI := 1 To Len( aDados )
		// Verifica se os campos passados existem na estrutura do modelo
		//If ( nPos := aScan(aDados,{|x| AllTrim( x[1] )== AllTrim(aCampos[nI][3]) } ) ) > 0
		If ( nPos := aScan(aCampos,{|x| AllTrim( x[3] )== AllTrim(aDados[nI][1]) } ) ) > 0

			// È feita a atribuição do dado ao campo do Model
			If !( lAux := oModel:SetValue(aDados[nI][1], aDados[nI][2] ) )
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por 	exemplo)
				// o método SetValue retorna .F.

				cWarn	+= aCampos[nI][1]+"- Não foi possivel atribuir valor a este campo"
			EndIf
		ELSE
			cWarn	+= aCampos[nI][1]+"- Não encontrado na entidade "+cAliasImp 
		EndIf
	Next nI




	If oModFull:VldData() 
		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		IF oModFull:CommitData()
			aRet	:= {.T., cWarn}
		ELSE
			aRet[2]	:= oModFull:GetErrorMessage()[6]
		ENDIF
	ELSE

		aErro := oModFull:GetErrorMessage()
		// A estrutura do vetor com erro é:
		// [1] identificador (ID) do formulário de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formulário de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solução
		// [8] Valor atribuído
		// [9] Valor anterior


		aRet[2]	:=  aErro[4]+"-"+aErro[6]
	EndIf



	oModFull:DeActivate()


Return(aRet)



Static Function ImpRec(_cAliasT, nIndice, aDados, _nOpc)
	Local aRet		:= {.F., ""}
	Local cFilSra	:= ""
	Local cMatSra	:= "" 
	Local cFilSR7	:= ""
	Local cMatSR7	:= ""
	Local dDatSR7	:= ""
	Local cSeqSR7	:= ""
	Local cTipSR7	:= ""
	Local cPdSR3	:= ""
	Local cMemSr8	:= ""
	local nPosMem	:= 0 
	Local lIncAlt	:= .T. 

	IF _nOpc == 4
		lIncAlt := .F.
	ENDIF 

	DBSELECTAREA(_cAliasT)

	IF _nOpc == 3

		IF 	_cAliasT == "SR3"

			For nI := 1 To Len( aDados )

				IF ALLTRIM(aDados[nI,1]) == "R3_FILIAL"
					cFilSR7	:= aDados[nI,2]						
					cFilSra	:= aDados[nI,2]

				ELSEIF 	ALLTRIM(aDados[nI,1]) == "R3_MAT"
					cMatSR7	:= aDados[nI,2]	
					cMatSra	:= aDados[nI,2]

				ELSEIF 	ALLTRIM(aDados[nI,1]) == "R3_DATA"
					dDatSR7 := aDados[nI,2]

				ELSEIF 	ALLTRIM(aDados[nI,1]) == "R3_SEQ"
					cSeqSR7	:= 	aDados[nI,2]

				ELSEIF 	ALLTRIM(aDados[nI,1]) == "R3_TIPO"
					cTipSR7 := aDados[nI,2]		
				ELSEIF 	ALLTRIM(aDados[nI,1]) == "R3_PD"
					cPdSR3 := aDados[nI,2]							
				ENDIF 	

			Next nI

			DBSELECTAREA("SR7")
			SR7->(DBSETORDER(2))//|R7_FILIAL+R7_MAT+DTOS(R7_DATA)+R7_SEQ+R7_TIPO|

			IF SR7->(DBSEEK(cFilSR7 + cMatSR7 + DTOS(dDatSR7) + cSeqSR7 + cTipSR7))



				DBSELECTAREA("SRA")
				SRA->(DBSETORDER(1))//|RA_FILIAL+RA_MAT|	

				SRA->(DBSEEK(cFilSra + cMatSra ))

				DBSELECTAREA("SR3")
				SR3->(DBSETORDER(2))//|R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_SEQ+R3_TIPO+R3_PD|	
				IF SR3->(!DBSEEK(cFilSR7 + cMatSR7 + DTOS(dDatSR7) + cSeqSR7 + cTipSR7 + cPdSR3 ))
				
					BEGIN TRANSACTION
						RegToMemory(_cAliasT,lIncAlt)
	
						For nI := 1 To Len( aDados )
							M->&(ALLTRIM(aDados[nI,1]))		:= aDados[nI,2]	
						Next nI
	
	
						DBSELECTAREA(_cAliasT)
						RECLOCK(_cAliasT,.T.)
	
						For nY := 1 To SR3->(FCOUNT())
							FieldPut(nY, M->&(FieldName(nY)) )
						Next nY
	
	
						SR3->(MSUNLOCK())
	
					END TRANSACTION
				ENDIF 
			ELSE
				RegToMemory("SR7",.T.)
				
				M->R7_FILIAL	:= cFilSR7
				M->R7_MAT		:= cMatSR7
				M->R7_DATA		:= dDatSR7
				M->R7_SEQ		:= cSeqSR7
				M->R7_TIPO		:= cTipSR7

				

				DBSELECTAREA("SRA")
				SRA->(DBSETORDER(1))//|RA_FILIAL+RA_MAT|	

				SRA->(DBSEEK(cFilSra + cMatSra ))

				M->R7_FUNCAO 	:= SRA->RA_CODFUNC
				M->R7_DESCFUN	:= POSICIONE("SRJ",1,XFILIAL("SRJ")+SRA->RA_CODFUNC,"RJ_DESC")
				M->R7_CARGO 	:= SRA->RA_CARGO				
				M->R7_DESCCAR	:= POSICIONE("SQ3",1,XFILIAL("SQ3")+SRA->RA_CARGO,"Q3_DESCSUM")




				BEGIN TRANSACTION
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava Cabecalho ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DBSELECTAREA("SR7")
					RECLOCK("SR7",.T.)

					For nY := 1 To SR7->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY

					SR7->(MSUNLOCK())

					DBSELECTAREA("SR3")
					SR3->(DBSETORDER(2))//|R3_FILIAL+R3_MAT+DTOS(R3_DATA)+R3_SEQ+R3_TIPO+R3_PD|	
					
					IF SR3->(!DBSEEK(cFilSR7 + cMatSR7 + DTOS(dDatSR7) + cSeqSR7 + cTipSR7 + cPdSR3 ))
						RegToMemory(_cAliasT,lIncAlt)
	
						For nI := 1 To Len( aDados )
							M->&(ALLTRIM(aDados[nI,1]))		:= aDados[nI,2]	
						Next nI
	
	
						DBSELECTAREA(_cAliasT)
						RECLOCK(_cAliasT,lIncAlt)
	
						For nY := 1 To SR3->(FCOUNT())
							FieldPut(nY, M->&(FieldName(nY)) )
						Next nY
	
						SR3->(MSUNLOCK())
					ENDIF 	
				END TRANSACTION
			ENDIF
			CONFIRMSX8()

		ELSE

			RegToMemory(_cAliasT,lIncAlt)

			For nI := 1 To Len( aDados )
				M->&(ALLTRIM(aDados[nI,1]))		:= aDados[nI,2]	
			Next nI


			BEGIN TRANSACTION

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava Cabecalho ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DBSELECTAREA(_cAliasT)
				RECLOCK(_cAliasT,.T.)

				IF _cAliasT == "FIL"
					For nY := 1 To FIL->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					FIL->(MSUNLOCK())

				ELSEIF 	_cAliasT == "SR0"
					For nY := 1 To SR0->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					SR0->(MSUNLOCK())
					/*
					ELSEIF 	_cAliasT == "SR3"
					For nY := 1 To SR3->(FCOUNT())
					FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					SR3->(MSUNLOCK())
					*/		
				ELSEIF 	_cAliasT == "SR8"
					For nY := 1 To SR8->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					
					nPosMem := aScan( aDados , { |x| AllTrim(x[01]) == "R8_MEMO"		})
					
					IF nPosMem > 0 .AND. VALTYPE(adados[nPosMem][2]) == "C"													    
						dbselectarea("SYP")
						MSMM(,,,adados[nPosMem][2],1,,.T.,"SR8","R8_CODMEMO")
						
						//|CORRIGIR A FILIAL|
						/*
						RECLOCK("SYP",.F.)
							SYP->YP_FILIAL	:= adados[1][2]
						SYP->(MSUNLOCK())
						*/
					ENDIF	
															
					SR8->(MSUNLOCK())	
				
				ELSEIF 	_cAliasT == "SPI"
					For nY := 1 To SPI->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					SPI->(MSUNLOCK())
				ELSEIF 	_cAliasT == "SRG"
					For nY := 1 To SRG->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					SRG->(MSUNLOCK())			
				ELSEIF 	_cAliasT == "SRR"
					For nY := 1 To SRR->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					SRR->(MSUNLOCK())						
				ELSEIF 	_cAliasT == "RHK"
					For nY := 1 To RHK->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					RHK->(MSUNLOCK())		
				ELSEIF 	_cAliasT == "RHL"
					For nY := 1 To RHL->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					RHL->(MSUNLOCK())	
				ELSEIF 	_cAliasT == "SBZ"
					For nY := 1 To SBZ->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					SBZ->(MSUNLOCK())	
				ELSEIF 	_cAliasT == "SA6"
					For nY := 1 To SA6->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					SA6->(MSUNLOCK())	
				ELSEIF 	_cAliasT == "SAL"
					For nY := 1 To SAL->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					SAL->(MSUNLOCK())
				ELSEIF 	_cAliasT == "SAI"
					For nY := 1 To SAI->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					SAI->(MSUNLOCK())			
				ELSEIF 	_cAliasT == "CN7"
					For nY := 1 To CN7->(FCOUNT())
						FieldPut(nY, M->&(FieldName(nY)) )
					Next nY
					CN7->(MSUNLOCK())	
				ENDIF


			END TRANSACTION

			CONFIRMSX8()

		ENDIF 
	ENDIF 	

Return(aRet)		



/*/{Protheus.doc} CPIM01A
Atualiza dados bancarios de acordo com a tabela FIL
@author Jonatas Oliveira | www.compila.com.br
@since 29/07/2016
@version 1.0
@param cAbreFecha, C, A="Abre" semaforo (cria arquivo e o mantem aberto), F=Fecha (Libera semaforo para utilizacao)
@param cFile, C, Nome do Semaforo (arquivo fisivo sera criado)
@param nHSemafaro, N, Numero do Handle do arquivo a ser fechado.
@return nRet, Handle do arquivo de semaforo criado. Quando MAIOR que ZERO, semaforo aberto com sucesso, MENOR ou IGUAL a Zero = nao foi possivel abrir o semaforo.
/*/
User Function CPIM01A()
	Local cQuery := ""
	
	Private _cFileLog
	Private _cLogPath
	Private _Handle
	
	cQuery += " SELECT A2.R_E_C_N_O_ AS RECNOA2, FIL.R_E_C_N_O_ AS RECNFIL  "
	cQuery += " FROM "+Retsqlname("SA2")+" A2                "
	cQuery += " INNER JOIN "+Retsqlname("FIL")+" FIL         "
	cQuery += " 	ON A2_FILIAL = FIL_FILIAL "
	cQuery += " 	AND A2_COD = FIL_FORNEC   "
	cQuery += " 	AND A2_LOJA = FIL_LOJA    "
	cQuery += " 	AND FIL.D_E_L_E_T_ = ''   "
	cQuery += " 	AND FIL_TIPO = '1'        "
	cQuery += " WHERE A2.D_E_L_E_T_ = ''      "
	cQuery += " ORDER BY A2_COD,A2_LOJA       "
	
	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)
	
	DBSELECTAREA("SA2")
	DBSELECTAREA("FIL")
	
	fGrvLog(1,"INICIO GRAVACAO" )
	
	WHILE TSQL->(!EOF())
		SA2->(DBGOTO(TSQL->RECNOA2))
		FIL->(DBGOTO(TSQL->RECNFIL))
		
		IF SA2->(A2_COD + A2_LOJA) == FIL->(FIL_FORNEC + FIL_LOJA)
			//IF EMPTY(SA2->A2_BANCO) .AND. EMPTY(SA2->A2_AGENCIA) .AND. EMPTY(SA2->A2_NUMCON)
				RECLOCK("SA2",.F.)
					SA2->A2_BANCO 	:= FIL->FIL_BANCO
					SA2->A2_AGENCIA := FIL->FIL_AGENCI
					SA2->A2_DVAGE	:= FIL->FIL_DVAGE
					SA2->A2_DVCTA  	:= FIL->FIL_DVCTA
					SA2->A2_NUMCON 	:= FIL->FIL_CONTA
				SA2->(MSUNLOCK())
				
				fGrvLog(2, "ATUALIZADO COM SUCESSO : " + SA2->(A2_COD + A2_LOJA) + " | " + ALLTRIM(SA2->A2_NOME))
			/*	
			ELSE
				fGrvLog(2, "NÃO ATUALIZADO PREENCHIDOS ANTERIORMENTE : " + SA2->(A2_COD + A2_LOJA) + " | " + ALLTRIM(SA2->A2_NOME))
				
			ENDIF
			*/ 
		ELSE
			fGrvLog(2, "NÃO ATUALIZADO REGISTROS NÃO COMBINADOS : " + SA2->(A2_COD + A2_LOJA) + " | " + ALLTRIM(SA2->A2_NOME))
		ENDIF 
		
		TSQL->(DBSKIP())
	ENDDO
	fGrvLog(3,"FINAL DE GRAVACAO")
	
Return()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a Criação, Gravacao, Apresentacao do Log de acordo com o Pametro passado ³
//³                                                                                  ³
//³ PARAMETRO	DESCRICAO                                                            ³
//³ _nOpc		Opcao:  1= Cria Arquivo de Log, 2= Grava Log, 3 = Apresenta Log      ³
//³ _cTxtLog	Log a ser gravado                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fGrvLog(_nOpc, _cTxtLog)
Local _lRet	:= Nil
Local _nOpc, _cTxtLog
Local _EOL	:= chr(13)+chr(10)

//Default _nOpc		:= 0
//Default _cTxtLog 	:= ""
_cTxtLog += _EOL
Do Case
	Case _nOpc == 1
		_cFileLog	 	:= Criatrab(,.F.)
		_cLogPath		:= AllTrim(GetTempPath())+_cFileLog+".txt"
		_Handle			:= FCREATE(_cLogPath,0)	//| Arquivo de Log
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		
	Case _nOpc == 2
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		
	Case _nOpc == 3
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		FCLOSE(_Handle)
		WINEXEC("NOTEPAD "+_cLogPath)
EndCase

Return(_lRet)
