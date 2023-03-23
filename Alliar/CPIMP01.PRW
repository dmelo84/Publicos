#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "fileio.ch"



#DEFINE COLUNA_LOG "LOG_IMPORTACAO"


/*/{Protheus.doc} CPIMP01
Realiza importaÁ„o CSV para Protheus v12
@author Augusto Ribeiro | www.compila.com.br
@since Dez 17, 2015
@version 1.0
@return NIL
@example
(examples)
@see (links_or_references)
/*/
User Function CPIMP01()

Local cFile
Local lAuto			:= .F.
Local aArqDir		:= {}
Local aArqFullPath	:= {} 

/*	
nImpXml	:= Aviso("Importa Movimento de Estoque"," Selecione o arquivo ou pasta a ser importada."+CRLF+;
 											"Ao selecionar uma pasta, todos os arquivos com extens„o .csv ser„o importados.",{"Imp. Arquivo",  "Cancelar"},2)	

*/
nImpXml	:= Aviso("ImportaÁ„o Cadastral"," Selecione o arquivo a ser importado. [*.csv]",{"Imp. Arquivo",  "Cancelar"},2)
	
IF nImpXml == 1	                                                                                 

	cFile := cGetFile('Arquivo CSV|*.csv','Selecione arquivo',0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)
	IF !EMPTY(cFile)
		aArqFullPath	:= {cFile}
	ENDIF
	/*
ELSEIF nImpXml == 2

	cFile	 := ALLTRIM(cGetFile('Pasta','Selecione a pasta',0,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY,.T.)	)

	IF !EMPTY(cFile)	
		aArqDir := Directory(cFile+"*.csv")		
		FOR nI := 1 TO LEN(aArqDir)    
			lAuto	:= .t.
			aadd(aArqFullPath,cFile + alltrim(aArqDir[nI,1]) ) 
		
		NEXT nI
	ENDIF	       
	*/
ENDIF  
                  

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Importa XML ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Processa({||  U_CPIMP01A(aArqFullPath) })		


Return()


/*/{Protheus.doc} AI01IMP
Importa dos os arquivos recebidos no Array
@author Augusto Ribeiro | www.compila.com.br
@since Dez 17, 2015
@version version
@param aPathXML, A, Array com caminho completo dos arquivos.
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CPIMP01A(aPathArq)
Local cMsgErro	:= ""
Local nTotArq, nI

/*---------------------------------------------------------------- Augusto Ribeiro | Oct 27, 2015
	Variaveis para gracao do Log
------------------------------------------------------------------------------------------*/
Private _cFileLog	 	:= ""    
Private _cLogPath		:= ""  
Private _Handle			:= "" 


IF !EMPTY(aPathArq)
	
	nTotArq	:= LEN(aPathArq)
	
	IF nTotArq >= 1  
		ProcRegua(nTotArq)

		cMsgErro	:= ""

		for nI := 1 to nTotArq
			IncProc("Importando Arquivos... "+TRANSFORM(nI, "@e 999,999,999",)+" de "+TRANSFORM(nTotArq,"@e 999,999,999"))
			
			aRetImp		:= impArq(aPathArq[nI])	
			IF aRetImp[1]	
				cMsgErro	+= "ARQUIVO: "+aPathArq[nI]+" | LOG: SUCESSO (TODOS OS REGISTROS FORAM PROCESSADOS COM SUCESSO). " + ALLTRIM(aRetImp[2])	+CRLF
			ELSE 
				cMsgErro	+= "ARQUIVO: "+aPathArq[nI]+" | LOG: "+aRetImp[2]+CRLF
			ENDIF
		 	
		next nI	
		
		IF !EMPTY(cMsgErro)
			AVISO("Log de processamento", "LOG de processamento"+CRLF+CRLF+cMsgErro, {"Fechar"},3)
		ENDIF
	ELSE	      
		AVISO("Aviso", "Nenhum arquivo foi selecionado [0].", {"Fechar"},2)
	endif
ELSE
	AVISO("Aviso", "Nenhum arquivo foi selecionado.", {"Fechar"},2)
ENDIF



Return()



/*/{Protheus.doc} CPIMP01B
Importa dos os arquivos recebidos no Array
@author Augusto Ribeiro | www.compila.com.br
@since Dez 17, 2015
@version version
@param aPathXML, A, Array com caminho completo dos arquivos.
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CPIMP01B(cPathPai, cPathFilho)
Local cMsgErro	:= ""
Local nTotArq, nI

/*---------------------------------------------------------------- Augusto Ribeiro | Oct 27, 2015
	Variaveis para gracao do Log
------------------------------------------------------------------------------------------*/
Private _cFileLog	 	:= ""    
Private _cLogPath		:= ""  
Private _Handle			:= "" 


IF !EMPTY(cPathPai)
	
			
	aRetImp		:= impPaiFil(cPathPai, cPathFilho)
		
	IF aRetImp[1]	
		cMsgErro	+= "ARQUIVO: "+cPathPai+" | LOG: SUCESSO (TODOS OS REGISTROS FORAM PROCESSADOS COM SUCESSO)"	+CRLF
	ELSE 
		cMsgErro	+= "ARQUIVO: "+cPathPai+" | LOG: "+aRetImp[2]+CRLF
	ENDIF
 	
			
	IF !EMPTY(cMsgErro)
		AVISO("Log de processamento", "LOG de processamento"+CRLF+CRLF+cMsgErro, {"Fechar"},3)
	ENDIF
	
ELSE
	AVISO("Aviso", "Nenhum arquivo foi selecionado.", {"Fechar"},2)
ENDIF



Return()




/*/{Protheus.doc} impArq
Importa Arquivo
@author Augusto Ribeiro | www.compila.com.br
@since Oct 27, 2015
@version version
@param cPathFull, C, Caminho Completo do arquivo 
@return aRet	:= {.F., cMsgErr, nCodErrp}
@example
(examples)
@see (links_or_references)
/*/
Static Function impArq(cPathFull)
Local aRet	:= {.F., ""}
Local cNomeArq
Local cPathTemp := DirTemp() //| Busca diretorio temporario |
Local cFullTemp	:= ""
Local cArqLog	:= ""
Local cAliasImp	:= ""
Local nI

Local nHdlArq, cLinha, aLinha, aDados, nTotLin,aItens, aItem
Local nHdlErro	:= 0
Local nReg	:= 0
Local lArqErro	:= .F.
Local cCabecArq, cCabecF
Local nPosErro	:= 0
Local xVarCpo
Local nRet	:= 0 //| 0=Valor Inicial, 1=Sucesso, 2=Erro |

Local _nPosFil 		:= 0
Local _nPosChv 		:= 0
Local _nPosChv2 	:= 0

Local nX3CAMPO 		:= SX3->(FIELDPOS("X3_CAMPO"))
Local nX3TIPO 		:= SX3->(FIELDPOS("X3_TIPO"))
Local nX3TAMANHO 	:= SX3->(FIELDPOS("X3_TAMANHO"))	


Private aCabecArq := {}
Private nCabecArq := {}

Private aCabecF := {}
Private nCabecF := {}


IF !EMPTY(cPathFull)
	cPathFull	:= Lower(cPathFull)			//| Todo o caminho deve ser minusco, evita problemas com Linux
	cNomeArq	:= alltrim(Lower(NomeArq(cPathFull)))		//| Retorna Nome do Arquivo
	
	IF !EMPTY(cPathFull) .AND. !EMPTY(cNomeArq)
	
		/*--------------------------
			Copia Arquivos para a Pasta Temp
		---------------------------*/		                               
		cFullTemp	:= ALLTRIM(cPathTemp+cNomeArq)
		IF cPathFull <> cFullTemp
			__CopyFile(cPathFull, cFullTemp)
		ENDIF
		
		
		/*--------------------------
			Monta nome do arquivo de log de erro
		---------------------------*/
		cArqLog	:= LEFT(cNomeArq,LEN(cNomeArq)-4)+"_LOG.CSV"
		
		
		//| Abre Arquivo|
		IF  (nHdlArq	:= FT_FUSE(cFullTemp) ) >= 0				
			
			
			/*--------------------------
				Verifica Quantas linha Possui o Arquivo
			---------------------------*/				
			nTotLin := FT_FLASTREC()				
			ProcRegua(nTotLin)      

			//| Posiciona na Primeira Linha do Arquivo
			FT_FGOTOP()
			
			
			/*-----------------------------------------------
				Primeira linha refere-se ao Cabecalho
			-------------------------------------------------------*/
			cCabecArq	:= FT_FREADLN()
			aCabecArq	:= StrTokArr2( cCabecArq, ";", .F.)
			nCabecArq	:= len(aCabecArq)
			
			
			/*-----------------------------------------------------------------
				Caso coluna de Log ja exista no arquivo, remove do cabecalho
			------------------------------------------------------------------*/
			nPosErro	:= aScan(aCabecArq, COLUNA_LOG)
			IF nPosErro > 0
				aDel(aCabecArq, nPosErro)
				nCabecArq--
				aSize(aCabecArq,nCabecArq)
			ENDIF
			
			//| Identificacao do Alias que esta sendo importado |
			DBSELECTAREA("SX3")
			SX3->(DBSETORDER(2)) //|CAMPO 
			IF SX3->(DBSEEK(ALLTRIM(UPPER(aCabecArq[1])))) 
				cAliasImp	:= SX3->(FIELDGET(FIELDPOS("X3_ARQUIVO")))						
			ENDIF
			
			
			/*--------------------------
				Array com Cabecalho e Tipo de Dados
			---------------------------*/
			DBSELECTAREA("SX3")
			SX3->(DBSETORDER(2)) //|CAMPO
			aCabecX3	:= {}
			for nI:= 1 to Len(aCabecArq)
				IF SX3->(DBSEEK(ALLTRIM(UPPER(aCabecArq[nI]))))
					AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3CAMPO))), SX3->(FIELDGET(nX3TIPO)), SX3->(FIELDGET(nX3TAMANHO))})
				ELSE
					AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3CAMPO))), "", 0 })										
				ENDIF
			next nI
			
					
			FT_FSKIP()
			                                          
			WHILE !FT_FEOF()
				nReg++					
				IncProc("Importanto registros... "+STRZERO(nReg,6)+" de "+STRZERO(nTotLin,6))					

				cErroLin	:= ""
				aDados		:= {}
				
				cLinha 		:= FT_FREADLN()			
				aLinha		:= StrTokArr2( cLinha, ";", .T.)
				nQtdeCol	:= LEN(aLinha)		
				IF nPosErro > 0	
					aDel(aLinha, nPosErro)//| Remove linha com LOG de ERRO|
					nQtdeCol--	
					aSize(aLinha,nQtdeCol)
				ENDIF
				
								
				/*------------------------------------------------------ Augusto Ribeiro | Oct 27, 2015 - 9:46:36 PM
					ARMAZENA VARIAVEIS CONFORME LAYOUT
				------------------------------------------------------------------------------------------*/
				IF nCabecArq == nQtdeCol
					IF cAliasImp <> "SN1"
						FOR nI := 1 to nCabecArq
							IF aCabecX3[nI,2] == "C" .OR. aCabecX3[nI,2] == "M" 
								xVarCpo	:= PADR(ALLTRIM(aLinha[nI]),aCabecX3[nI,3]) 
							ELSEIF aCabecX3[nI,2] == "N"
								xVarCpo	:= VAL(aLinha[nI])
							ELSEIF aCabecX3[nI,2] == "D"
								xVarCpo	:= STOD(aLinha[nI])
							ENDIF
							
							IF !EMPTY(xVarCpo)
								IF ALLTRIM(UPPER(aCabecArq[nI])) == "E2_TIPO"
									aaDD(aDados, {ALLTRIM(UPPER(aCabecArq[nI])), xVarCpo, .F.})
								ELSE
									aaDD(aDados, {ALLTRIM(UPPER(aCabecArq[nI])), xVarCpo, nil})
								ENDIF 
								/*
								IF ALLTRIM(aCabecArq[nI]) $ "E2_TIPO|E2_NATUREZ|E2_LOJA|E2_VALOR|E2_MOEDA|E2_BASEPIS|E2_BASECSL|E2_FRETISS|E2_CODISS|E2_BASEISS|E2_BASEIRF|E2_BASECOF|E2_BASEINS"//|E2_VALOR|E2_LOJA|"
								//"E2_TIPO|E2_NATUREZ|E2_LOJA|E2_FRETISS|E2_CODISS|"
								//"E2_TIPO|E2_NATUREZ|E2_LOJA|E2_VALOR|E2_MOEDA|E2_BASEPIS|E2_BASECSL|E2_FRETISS|E2_CODISS|E2_BASEISS|E2_BASEIRF|E2_BASECOF|E2_BASEINS"//|E2_VALOR|E2_LOJA|"
								
									aaDD(aDados, {aCabecArq[nI], xVarCpo, .F. })
								ELSE
									aaDD(aDados, {aCabecArq[nI], xVarCpo, nil})
								ENDIF
								 */	
							ENDIF
						NEXT nI
					ELSE
					
						aItem 	:= {}
						aItens	:= {}
						cDescEst	:= ""
						aDescEst	:= {}
																							
						FOR nI := 1 to nCabecArq
							IF aCabecX3[nI,2] == "C" .OR. aCabecX3[nI,2] == "M" 
								xVarCpo	:= aLinha[nI]
							ELSEIF aCabecX3[nI,2] == "N"
								xVarCpo	:= VAL(aLinha[nI])
							ELSEIF aCabecX3[nI,2] == "D"
								xVarCpo	:= STOD(aLinha[nI])
							ENDIF
																				
							IF !EMPTY(xVarCpo)
								IF LEFT(ALLTRIM(UPPER(aCabecArq[nI])),2) == "N1"  
									aaDD(aDados, {ALLTRIM(UPPER(aCabecArq[nI])), xVarCpo, nil})
								ELSE
									IF LEN(aitem) == 0
										_nPosFil 	:= aScan( aDados , { |x| AllTrim(x[01]) == "N1_FILIAL"		})
										_nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "N1_CBASE"		})
										_nPosChv2 	:= aScan( aDados , { |x| AllTrim(x[01]) == "N1_ITEM"		})									
																
										aaDD(aItem, {"N3_FILIAL"	, aDados[_nPosFil][2]	, nil})
										aaDD(aItem, {"N3_CBASE"		, aDados[_nPosChv][2]	, nil})
										aaDD(aItem, {"N3_ITEM"		, aDados[_nPosChv2][2]	, nil})
										
									ENDIF
									 

									//IF alltrim(aCabecArq[nI]) == "N3_DESCEST"
									//	cDescEst	:= ALLTRIM(xVarCpo)
										
									//aaDD(aItem, {aCabecArq[nI], xVarCpo, nil})
									
									IF alltrim(aCabecArq[nI]) <> 'N3_VMXDEPR'
										aaDD(aItem, {aCabecArq[nI], xVarCpo, nil})
									ELSE
										aaDD(aItem, {aCabecArq[nI], xVarCpo, .F.})
									ENDIF
									
								ENDIF 
							ENDIF
						NEXT nI
					
						aAdd( aItens , aItem)
		
				
					ENDIF 
					
															
					//| CHAMA ROTINA DE IMPORTACAO |
					aRetAux	:= U_CPIMP01X(cAliasImp,aDados,.F.,aItens)
					//aRetAux	:= U_CPIMP01X(cAliasImp,aDados,.T.,aItens)
					//aRetAux		:= {.t.,""}			
					IF aRetAux[1]
						/*
						IF cAliasImp == "SN1"
							IF !EMPTY(aDescEst)
								dbSelectArea('SN2')
								SN2->(dbSetOrder(1))
								lAlt := SN2->(dbSeek( SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO)))									
								Af160Grav('SN3' , cDescEst , lAlt)														
							ENDIF							
						ENDIF
						*/
					
						if nRet == 0
							nRet	:= 1
						endif
					else
						cErroLin	+= aRetAux[2]
					ENDIF
				
				ELSE
					cErroLin	+= "Quantidade de Colunas diverge do cabecalho do arquivo"
				ENDIF
				
								
				IF !EMPTY(cErroLin)
					nRet := 2 //| Erro 
					//GrvArqErro(@nHdlErro, cLinha, cErroLin, cArqLog, cPathTemp)
					GrvArqErro(@nHdlErro, cArqLog, aLinha, cErroLin)
				ENDIF
				
				FT_FSKIP()
			ENDDO

			IF nHdlErro > 0
				fClose(nHdlErro)
			ENDIF
		ELSE
			aRet[2]	:= "Falha na abertura do arquivo ["+cFullTemp+"]"
		ENDIF
	ELSE
		aRet[2]	:= "Caminho do arquivo invalido ou vazio ["+cPathFull+"]."
	ENDIF	
ELSE 
	aRet[2]	:= "Caminho do arquivo invalido ou vazio"
ENDIF


IF nRet == 1 //| Todos os registros foram processados com sucesso|
	aRet[1]	:= .T.
	aRet[2]	:= "Total de registros " + alltrim(STR(nTotLin)) + " Total Importado " + alltrim(STR(nReg))
ELSEIF nRet == 2
	aRet[1]	:= .F.
	aRet[2]	:= "Alguns registros foram processados com erro, por favor verifique o log de erro ["+cArqLog+"] Total de registros " + alltrim(STR(nTotLin)) + " Total Importado " + alltrim(STR(nReg))"
	
	/*--------------------------
		Copia Arquivos para a Pasta Temp
	---------------------------*/		    
	IF !EMPTY(cArqLog)   
	
	
		nPosBar	:= RAT("\",cPathFull)
		IF nPosBar > 0
			cPathOrig	:= SUBSTR(cPathFull, 1, nPosBar)
		ELSE
			cPathOrig	:= cPathFull
		ENDIF
		
		cPathOrig	:= ALLTRIM(cPathOrig)
		cPathTemp	:= ALLTRIM(cPathTemp)
		
		IF cPathOrig <> cPathTemp
			__CopyFile(cPathTemp+cArqLog, cPathOrig+cArqLog)
		ENDIF 
	ENDIF
ENDIF


Return(aRet)



/*/{Protheus.doc} GrvArqErro
Grava log de erro
@author Augusto Ribeiro | www.compila.com.br
@since Oct 30, 2015
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//Static Function GrvArqErro(nHdlErro, cLinha, cMsgErro, cNomeArq, cPathTemp)
Static Function GrvArqErro(nHdlErro, cNomeArq, aLinha, cMsgErro)
//Local cRet	:= ""
Local cPathTemp := DirTemp() //| Busca diretorio temporario |
Local nI		:= 0
Local cCabec	:= ""
Local cLinErro	:= ""

IF !EMPTY(cMsgErro)
	
	IF nHdlErro == 0
		cCurDir	:= CurDir()
		CurDir(cPathTemp)
		
		//cRet		:= LEFT(cNomeArq,LEN(cNomeArq)-4)+"_ERRO.CSV"
		nHdlErro	:= Fcreate(cNomeArq)
		lArqErro	:= .T.
		
		//| Rollback no diretorio corrente
		IF LEFT(cCurDir,1) <> "\"
			cCurDir	:= "\"+cCurDir
		ENDIF		
		CurDir(cCurDir)
		
		/*--------------------------
		Adiciona coluna de LOG
		---------------------------*/
		cCabec	:= ""
		FOR nI := 1 to nCabecArq
			cCabec += aCabecArq[nI]+";"
		next
		cCabec	+= COLUNA_LOG
		
		nAux	:= FWrite(nHdlErro, cCabec+CRLF)				 
	endif
	
	
	//| Tratamento para sempre gravar o log na coluna correta|
	cLinErro	:= ""
	nQtdeLin	:= len(aLinha)
	FOR nI := 1 to nCabecArq
		IF nQtdeLin >= nI
			cLinErro += aLinha[nI]+";"
		ELSE
			cLinErro += ";"
		ENDIF
	next
	cLinErro	+= cMsgErro	+CRLF

	nAux	:= FWrite(nHdlErro, cLinErro)
ENDIF


Return()



/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ NomeArq  ∫Autor  ≥ Augusto Ribeiro	 ∫ Data ≥  03/12/2010 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Retorna somente o nome do arquivo + extensao Ex.: Arq.xml  ∫±±
±±∫          ≥                                                            ∫±±
±±∫PARAMETROS≥ cFullPath = Caminho Completo do arquivo                    ∫±±
±±∫RETORNO   ≥ cRet	= Arquivo.ext                                         ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/


/*/{Protheus.doc} NomeArq
Retorna somente o nome do arquivo + extensao Ex.: Arq.xml 
@author Augusto Ribeiro | www.compila.com.br
@since Oct 27, 2015
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function NomeArq(cFullPath)
Local cRet	:= ""
Local nFullPath	:= 0      
Local nI	

	IF !EMPTY(cFullPath)    
		cFullPath	:= ALLTRIM(cFullPath)
		nFullPath	:= LEN(cFullPath)
		
		FOR nI := 1 to nFullPath
			IF LEFT(RIGHT(cFullPath,nI),1) == "\"
				cRet	:= RIGHT(cFullPath,nI-1)
				EXIT
			ENDIF					
		NEXT nI	    
		
		IF EMPTY(cRet)
			cRet	:= cFullPath
		ENDIF
	ENDIF 

Return(cRet)     







/*/{Protheus.doc} DirTemp
Retornar/Criar caminho para pasta temporaria
@author Augusto Ribeiro | www.compila.com.br
@since 27/10/2015
@version 1.0
@param ${dDataRef}, ${D}, ${Data de referencia - Utilizado para criar o diretorio onde ser armazenado o arquivo}
@return ${cRet}, ${Caminho de destino no arquivo}
/*/
Static Function DirTemp(dDataRef)
Local cRet				:= ""
Local cDirTemp			:= "\DATA_INTEGRACAO\TEMP\"
Local cAnoMes, cDirComp, cCurDir, nAux, aPastas
Local nI

IF ExistDir(cDirTemp)
	cRet	:= cDirTemp
ELSE

	cCurDir	:= CurDir()
	

	//aPastas	:= StrTokArr2(cDirTemp, "\", .F.)
	aPastas	:= StrTokArr2(cDirTemp,"\", .F.)
	

	/*--------------------------
		Cria pastas
	---------------------------*/
	CurDir("\")
	nAux	:= 0
	for nI := 1 to Len(aPastas)
		
		
		
		nAux	:= MakeDir(alltrim(aPastas[nI]))
		IF nAux <> 0
			CONOUT("### CPIMP01.PRW [DirTemp] | Nao foi possivel criar o diretorio ["+alltrim(aPastas[nI])+"]. Cod. Erro: "+alltrim(str(FError())) )
		ENDIF		
		
		CurDir("\"+alltrim(aPastas[nI]))
	next nI
	
	IF nAux == 0
		cRet	:= cDirTemp
	ENDIF
		
	//| Rollback no diretorio corrente
	IF LEFT(cCurDir,1) <> "\"
		cCurDir	:= "\"+cCurDir
	ENDIF		
	CurDir(cCurDir) 
ENDIF 

cRet	:= ALLTRIM(cRet)

Return(cRet)




/*/{Protheus.doc} ARR2AUTO 
Array para Execauto
@author Augusto Ribeiro | www.compila.com.br
@since 17/12/2015
@version version
@param aCabec, a, Array com Cabecalho
@param aDados, a, Array com Cabecalho
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/







/*/{Protheus.doc} impArq
Importa Arquivo
@author Augusto Ribeiro | www.compila.com.br
@since Oct 27, 2015
@version version
@param cPathFull, C, Caminho Completo do arquivo 
@return aRet	:= {.F., cMsgErr, nCodErrp}
@example
(examples)
@see (links_or_references)
/*/
//Static Function impArq(cPathFull)
Static Function impPaiFil(cPathFull, cPathFilho)
Local aRet	:= {.F., ""}
Local cNomeArq
Local cPathTemp := DirTemp() //| Busca diretorio temporario |
Local cFullTemp	:= ""
Local cArqLog	:= ""
Local cAliasImp	:= ""
Local nI, nY, nX

Local nHdlArq, cLinha, aLinha, aDados, nTotLin,aItens, aItem, aLinCabec
Local nHdlErro	:= 0
Local nReg	:= 0
Local lArqErro	:= .F.
Local cCabecArq
Local nPosErro	:= 0
Local xVarCpo
Local nRet	:= 0 //| 0=Valor Inicial, 1=Sucesso, 2=Erro |

Local _nPosFil 		:= 0
Local _nPosChv 		:= 0
Local _nPosChv2 	:= 0	

Local aFullCabec	:= {}
Local aFullItens	:= {}

Local nTotCabec	:= 0
Local nTotItens	:= 0
Local nCpoCabec	:= 0
Local nCpoItens	:= 0
Local lAbort	:= .F.

Local nX3CAMPO 		:= SX3->(FIELDPOS("X3_CAMPO"))
Local nX3TIPO 		:= SX3->(FIELDPOS("X3_TIPO"))

Private aCabecArq := {}
Private nCabecArq := {}



/*----------------------
	MONTA ARRAY
	ARQUIVO - PAI
------------------------*/

IF !EMPTY(cPathFull)
	cPathFull	:= Lower(cPathFull)			//| Todo o caminho deve ser minusco, evita problemas com Linux
	cNomeArq	:= alltrim(Lower(NomeArq(cPathFull)))		//| Retorna Nome do Arquivo
	
	IF !EMPTY(cPathFull) .AND. !EMPTY(cNomeArq)
	
		/*--------------------------
			Copia Arquivos para a Pasta Temp
		---------------------------*/		                               
		cFullTemp	:= ALLTRIM(cPathTemp+cNomeArq)
		IF cPathFull <> cFullTemp
			__CopyFile(cPathFull, cFullTemp)
		ENDIF
		
		
		/*--------------------------
			Monta nome do arquivo de log de erro
		---------------------------*/
		cArqLogPai	:= LEFT(cNomeArq,LEN(cNomeArq)-4)+"_LOG.CSV"
		
		
		//| Abre Arquivo|
		IF  (nHdlArq	:= FT_FUSE(cFullTemp) ) >= 0				
			
			
			/*--------------------------
				Verifica Quantas linha Possui o Arquivo
			---------------------------*/				
			nTotLin := FT_FLASTREC()				
			ProcRegua(nTotLin)      

			//| Posiciona na Primeira Linha do Arquivo
			FT_FGOTOP()
			
			
			/*-----------------------------------------------
				Primeira linha refere-se ao Cabecalho
			-------------------------------------------------------*/
			cCabecArq	:= FT_FREADLN()
			aCabecArq	:= StrTokArr2( cCabecArq, ";", .F.)
			nCabecArq	:= len(aCabecArq)
			
			
			/*-----------------------------------------------------------------
				Caso coluna de Log ja exista no arquivo, remove do cabecalho
			------------------------------------------------------------------*/
			nPosErro	:= aScan(aCabecArq, COLUNA_LOG)
			IF nPosErro > 0
				aDel(aCabecArq, nPosErro)
				nCabecArq--
				aSize(aCabecArq,nCabecArq)
			ENDIF
			
			//| Identificacao do Alias que esta sendo importado |
			DBSELECTAREA("SX3")
			SX3->(DBSETORDER(2)) //|CAMPO 
			IF SX3->(DBSEEK(ALLTRIM(UPPER(aCabecArq[1])))) 
				cAliasImp	:= SX3->(FIELDGET(FIELDPOS("X3_ARQUIVO")))						
			ENDIF
			
			
			/*--------------------------
				Array com Cabecalho e Tipo de Dados
			---------------------------*/
			DBSELECTAREA("SX3")
			SX3->(DBSETORDER(2)) //|CAMPO
			aCabecX3	:= {}
			for nI:= 1 to Len(aCabecArq)
				IF SX3->(DBSEEK(ALLTRIM(UPPER(aCabecArq[nI]))))
					AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3CAMPO))), SX3->(FIELDGET(nX3TIPO))})
				ELSE
					AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3CAMPO))), "" })										
				ENDIF
			next nI
			
					
			FT_FSKIP()
			                                          
			WHILE !FT_FEOF()
				nReg++					
				IncProc("Importanto registros... "+STRZERO(nReg,6)+" de "+STRZERO(nTotLin,6))					

				cErroLin	:= ""
				aDados		:= {}
				
				cLinha 		:= FT_FREADLN()			
				aLinha		:= StrTokArr2( cLinha, ";", .T.)				
				nQtdeCol	:= LEN(aLinha)		
				IF nPosErro > 0	
					aDel(aLinha, nPosErro)//| Remove linha com LOG de ERRO|
					nQtdeCol--	
					aSize(aLinha,nQtdeCol)
				ENDIF
				
								
				/*------------------------------------------------------ Augusto Ribeiro | Oct 27, 2015 - 9:46:36 PM
					ARMAZENA VARIAVEIS CONFORME LAYOUT
				------------------------------------------------------------------------------------------*/
				IF nCabecArq == nQtdeCol
					
					FOR nI := 1 to nCabecArq
						IF aCabecX3[nI,2] == "C" .OR. aCabecX3[nI,2] == "M" 
							xVarCpo	:= aLinha[nI]
						ELSEIF aCabecX3[nI,2] == "N"
							xVarCpo	:= VAL(aLinha[nI])
						ELSEIF aCabecX3[nI,2] == "D"
							xVarCpo	:= STOD(aLinha[nI])
						ENDIF
						
						//IF !EMPTY(xVarCpo)
							aaDD(aDados, {aCabecArq[nI], xVarCpo, nil})
						//ENDIF
					NEXT nI
					
					
					aadd(aFullCabec, aDados)
										
				ELSE
					cErroLin	+= "Quantidade de Colunas diverge do cabecalho do arquivo [PAI]"					
				ENDIF
				
								
				IF !EMPTY(cErroLin)
					nRet := 2 //| Erro 
					//GrvArqErro(@nHdlErro, cLinha, cErroLin, cArqLog, cPathTemp)
					GrvArqErro(@nHdlErro, cArqLogPai, aLinha, cErroLin)
				ENDIF
				
				FT_FSKIP()
			ENDDO

			IF nHdlErro > 0
				fClose(nHdlErro)
			ENDIF
		ELSE
			aRet[2]	:= "Falha na abertura do arquivo ["+cFullTemp+"]"
		ENDIF
	ELSE
		aRet[2]	:= "Caminho do arquivo invalido ou vazio ["+cPathFull+"]."
	ENDIF	
ELSE 
	aRet[2]	:= "Caminho do arquivo invalido ou vazio"
ENDIF




/*----------------------
	MONTA ARRAY
	ARQUIVO - FILHO
------------------------*/
IF !EMPTY(cPathFilho)
	cPathFilho	:= Lower(cPathFilho)			//| Todo o caminho deve ser minusco, evita problemas com Linux
	cNomeArq	:= alltrim(Lower(NomeArq(cPathFilho)))		//| Retorna Nome do Arquivo
	
	IF !EMPTY(cPathFilho) .AND. !EMPTY(cNomeArq)
	
		/*--------------------------
			Copia Arquivos para a Pasta Temp
		---------------------------*/		                               
		cFullTemp	:= ALLTRIM(cPathTemp+cNomeArq)
		IF cPathFilho <> cFullTemp
			__CopyFile(cPathFilho, cFullTemp)
		ENDIF
		
		
		/*--------------------------
			Monta nome do arquivo de log de erro
		---------------------------*/
		cArqLog	:= LEFT(cNomeArq,LEN(cNomeArq)-4)+"_LOG.CSV"
		
		
		//| Abre Arquivo|
		IF  (nHdlArq	:= FT_FUSE(cFullTemp) ) >= 0				
			
			
			/*--------------------------
				Verifica Quantas linha Possui o Arquivo
			---------------------------*/				
			nTotLin := FT_FLASTREC()				
			ProcRegua(nTotLin)      

			//| Posiciona na Primeira Linha do Arquivo
			FT_FGOTOP()
			
			
			/*-----------------------------------------------
				Primeira linha refere-se ao Cabecalho
			-------------------------------------------------------*/
			cCabecF	:= FT_FREADLN()
			aCabecF	:= StrTokArr2( cCabecF, ";", .F.)
			nCabecF	:= len(aCabecF)
			
			
			/*-----------------------------------------------------------------
				Caso coluna de Log ja exista no arquivo, remove do cabecalho
			------------------------------------------------------------------*/
			nPosErro	:= aScan(aCabecF, COLUNA_LOG)
			IF nPosErro > 0
				aDel(aCabecF, nPosErro)
				nCabecF--
				aSize(aCabecF,nCabecF)
			ENDIF
			
			//| Identificacao do Alias que esta sendo importado |
			DBSELECTAREA("SX3")
			SX3->(DBSETORDER(2)) //|CAMPO 
			IF SX3->(DBSEEK(ALLTRIM(UPPER(aCabecF[1])))) 
				cAliasImp	:= SX3->(FIELDGET(FIELDPOS("X3_ARQUIVO")))						
			ENDIF
			
			
			/*--------------------------
				Array com Cabecalho e Tipo de Dados
			---------------------------*/
			DBSELECTAREA("SX3")
			SX3->(DBSETORDER(2)) //|CAMPO
			aCabecX3	:= {}
			for nI:= 1 to Len(aCabecF)
				IF SX3->(DBSEEK(ALLTRIM(UPPER(aCabecF[nI]))))
					AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3CAMPO))), SX3->(FIELDGET(nX3TIPO))})
				ELSE
					AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3CAMPO))), "" })										
				ENDIF
			next nI
			
					
			FT_FSKIP()
			                                          
			WHILE !FT_FEOF()
				nReg++					
				IncProc("Importanto registros... "+STRZERO(nReg,6)+" de "+STRZERO(nTotLin,6))					

				cErroLin	:= ""
				aDados		:= {}
				
				cLinha 		:= FT_FREADLN()			
				aLinha		:= StrTokArr2( cLinha, ";", .T.)
				nQtdeCol	:= LEN(aLinha)		
				IF nPosErro > 0	
					aDel(aLinha, nPosErro)//| Remove linha com LOG de ERRO|
					nQtdeCol--	
					aSize(aLinha,nQtdeCol)
				ENDIF
				
								
				/*------------------------------------------------------ Augusto Ribeiro | Oct 27, 2015 - 9:46:36 PM
					ARMAZENA VARIAVEIS CONFORME LAYOUT
				------------------------------------------------------------------------------------------*/
				IF nCabecF == nQtdeCol
					
					FOR nI := 1 to nCabecF
						IF aCabecX3[nI,2] == "C" .OR. aCabecX3[nI,2] == "M" 
							xVarCpo	:= aLinha[nI]
						ELSEIF aCabecX3[nI,2] == "N"
							xVarCpo	:= VAL(aLinha[nI])
						ELSEIF aCabecX3[nI,2] == "D"
							xVarCpo	:= STOD(aLinha[nI])
						ENDIF
						
						//IF !EMPTY(xVarCpo)
							aaDD(aDados, {aCabecF[nI], xVarCpo, nil})
						//ENDIF
					NEXT nI
					
					
					aadd(aFullItens, aDados)
										
				ELSE
					cErroLin	+= "Quantidade de Colunas diverge do cabecalho do arquivo [PAI]"
					lAbort		:= .T.
				ENDIF
				
								
				IF !EMPTY(cErroLin)
					nRet := 2 //| Erro 
					//GrvArqErro(@nHdlErro, cLinha, cErroLin, cArqLog, cPathTemp)
					//GrvArqErro(@nHdlErro, cArqLog, aLinha, cErroLin)
				ENDIF
				
				FT_FSKIP()
			ENDDO

			IF nHdlErro > 0
				fClose(nHdlErro)
			ENDIF
		ELSE
			aRet[2]	:= "Falha na abertura do arquivo ["+cFullTemp+"]"
		ENDIF
	ELSE
		aRet[2]	:= "Caminho do arquivo invalido ou vazio ["+cPathFilho+"]."
	ENDIF	
ELSE 
	aRet[2]	:= "Caminho do arquivo invalido ou vazio"
ENDIF




IF empty(aRet[2])
	
	aSort(aFullCabec,,,{ |x,y| x[1,2]+x[2,2]+x[3,2]+x[4,2] < y[1,2]+y[2,2]+y[3,2]+y[4,2] })
	aSort(aFullItens,,,{ |x,y| x[1,2]+x[2,2]+x[3,2]+x[4,2]+x[5,2] < y[1,2]+y[2,2]+y[3,2]+y[4,2]+y[5,2] })
	
	nTotCabec	:= len(aFullCabec)
	nTotItens	:= len(aFullItens)
	
	nItemLido	:= 0
	
	IF nTotCabec >= 1
	
		PRIVATE oModFull := FWLoadModel( "GPEA001" )
	
		nCpoCabec	:= len(aFullCabec[1])
	
		IF nTotItens >= 1
			nCpoItens	:= len(aFullItens[1])
		ENDIF
	
		FOR nI := 1 to nTotCabec
	
			CONOUT("### impPaiFil | "+ALLTRIM(STR(nI)))
	
			aDados	:= {}
			aItens	:= {}
			aLinCabec	:= {}
			FOR nY := 1 to nCpoCabec
				IF !EMPTY(aFullCabec[nI,nY,2])
					AADD(aDados,{aFullCabec[nI,nY,1], aFullCabec[nI,nY,2], NIL})
					
					IF VALTYPE(aFullCabec[nI,nY,2]) == "C" .OR. aCabecX3[nI,2] == "M" 
						AADD(aLinCabec,  aFullCabec[nI,nY,2])
						
					ELSEIF VALTYPE(aFullCabec[nI,nY,2]) == "N"
						AADD(aLinCabec,  ALLTRIM(STR(aFullCabec[nI,nY,2])))
						
					ELSEIF VALTYPE(aFullCabec[nI,nY,2]) == "D"
						AADD(aLinCabec,  DTOS(aFullCabec[nI,nY,2]))
					ENDIF
				ELSE
					AADD(aLinCabec,  "")
				ENDIF
				
			NEXT nY
			
			
			
			 /*--------------------------
			 	VERIFICA SE EXISTE ITENS
			 ---------------------------*/
			IF nCpoItens > 0
			
				nPosItem	:= aScan(aFullItens, { |x| AllTrim(x[1,2]+x[2,2]+x[3,2]+x[4,2]) == aDados[1,2]+aDados[2,2]+aDados[3,2]+aDados[4,2]  })
				
				IF nPosItem > 0
					FOR nX := nPosItem to nTotItens
						IF aFullItens[nX,1,2]+aFullItens[nX,2,2]+aFullItens[nX,3,2]+aFullItens[nX,4,2] == aDados[1,2]+aDados[2,2]+aDados[3,2]+aDados[4,2]
							aItem	:= {}
							FOR nY := 1 to nCpoItens
								IF !EMPTY(aFullItens[nX,nY,2])
									AADD(aItem,{aFullItens[nX,nY,1], aFullItens[nX,nY,2], NIL})
								ENDIF 
							NEXT nY
							
							AADD(aItens, aItem)
						ENDIF
					NEXT nX
				ENDIF
			ENDIF
			
			
			IF LEN(aItens) > 0
				aItens	:= aItens
			ENDIF
		
		
		
			aRet	:= impRHK(aDados, aItens)
			IF aRet[1]
				nRet	:= 1
			ELSE
				nRet	:= 2
				GrvArqErro(@nHdlErro, cArqLogPai, aLinCabec, STRTRAN(aRet[2],CRLF,""))
			ENDIF
	
	
		
		
		NEXT nI
	
	
	ENDIF
ELSE
	nRet == 2
endif


IF nRet == 1 //| Todos os registros foram processados com sucesso|
	aRet[1]	:= .T.
ELSEIF nRet == 2
	aRet[1]	:= .F.
	aRet[2]	:= "Alguns registros foram processados com erro, por favor verifique o log de erro ["+cArqLog+"]"
	
	/*--------------------------
		Copia Arquivos para a Pasta Temp
	---------------------------*/		    
	IF !EMPTY(cArqLog)   
	
	
		IF nHdlErro > 0
			fClose(nHdlErro)
		ENDIF
				
		nPosBar	:= RAT("\",cPathFull)
		IF nPosBar > 0
			cPathOrig	:= SUBSTR(cPathFull, 1, nPosBar)
		ELSE
			cPathOrig	:= cPathFull
		ENDIF
		
		cPathOrig	:= ALLTRIM(cPathOrig)
		cPathTemp	:= ALLTRIM(cPathTemp)
		
		IF cPathOrig <> cPathTemp
			__CopyFile(cPathTemp+cArqLogPai, cPathOrig+cArqLogPai)
		ENDIF 
	ENDIF
ENDIF


Return(aRet)









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
Static Function impRHK(aRHK, aRHL)
Local aRet		:= {.F., ""}
local cWarn		:= ""
Local  oModRHK, oModRHL, oModel, oAux, oStruct
Local nI		:= 0
Local nY		:= 0
Local nPos 		:= 0
Local lRet 		:= .T.
Local aAux    	:= {}
Local aCampos	:= {}      
Local nPosItem	:= 0 


dbSelectArea( "SRA" )
dbSetOrder(1)


IF SRA->(DBSEEK(aRHK[1,2]+aRHK[2,2]))
//IF .T.

	
	

	oModFull:SetOperation( 4 )

	oModFull:Activate()


	oModSRA 	:= oModFull:GetModel( "GPEA001_MSRA" )
	/*
	oModSRA:SetValue("RA_MAT",		SRA->RA_MAT ) 
	oModSRA:SetValue("RA_NOME", 	SRA->RA_NOME ) 
	oModSRA:SetValue("RA_ADMISSA", 	SRA->RA_ADMISSA ) 
	*/
	
	
	oModRHK 	:= oModFull:GetModel( "GPEA001_MRHK" )
	oStruct 	:= oModRHK:GetStruct()
	aCampos  	:= oStruct:GetFields()


	//| Atribui Valores ao Model|
	oModRHK:AddLine()
	For nI := 1 To Len( aRHK )
		// Verifica se os campos passados existem na estrutura do modelo
		//If ( nPos := aScan(aDados,{|x| AllTrim( x[1] )== AllTrim(aCampos[nI][3]) } ) ) > 0
		If ( nPos := aScan(aCampos,{|x| AllTrim( x[3] )== AllTrim(aRHK[nI][1]) } ) ) > 0

			// » feita a atribuiÁ„o do dado ao campo do Model
			If !( lAux := oModRHK:SetValue(aRHK[nI][1], aRHK[nI][2] ) )
				// Caso a atribuiÁ„o n„o possa ser feita, por algum motivo (validaÁ„o, por 	exemplo)
				// o mÈtodo SetValue retorna .F.

				cWarn	+= aCampos[nI][1]+"- N„o foi possivel atribuir valor a este campo"
			EndIf
		ELSE
			cWarn	+= aCampos[nI][1]+"- N„o encontrado na entidade "+cAliasImp 
		EndIf
	Next nI


	IF LEN(aRHL) > 0
		oModRHL 	:= oModFull:GetModel( "GPEA001_MRHL" )
		oStruct 	:= oModRHL:GetStruct()
		aCampos  	:= oStruct:GetFields()
	
		//| Atribui Valores ao Model|
		For nY := 1 To Len( aRHL )        
			nPosItem := aScan(aRHL, { |x| AllTrim(x[1,2]+x[2,2]+x[3,2]+x[4,2]) == aDados[1,2]+aDados[2,2]+aDados[3,2]+aDados[4,2]  })
			oModRHL:AddLine() 
			For nI := 1 To Len( aRHL[nY] )
				// Verifica se os campos passados existem na estrutura do modelo
				//If ( nPos := aScan(aDados,{|x| AllTrim( x[1] )== AllTrim(aCampos[nI][3]) } ) ) > 0
				If ( nPos := aScan(aCampos,{|x| AllTrim( x[3] )== AllTrim(aRHL[nY,nI][1]) } ) ) > 0
		
					// » feita a atribuiÁ„o do dado ao campo do Model
					If !( lAux := oModRHL:SetValue(aRHL[nY,nI][1], aRHL[nY,nI][2] ) )
						// Caso a atribuiÁ„o n„o possa ser feita, por algum motivo (validaÁ„o, por 	exemplo)
						// o mÈtodo SetValue retorna .F.
		
						cWarn	+= aCampos[nI][1]+"- N„o foi possivel atribuir valor a este campo"
					EndIf
				ELSE
					cWarn	+= aCampos[nI][1]+"- N„o encontrado na entidade "+AllTrim(aRHL[nY,nI][1])  
				EndIf
			Next nI
		Next nY
	ENDIF




	If oModFull:VldData() 
		// Se o dados foram validados faz-se a gravaÁ„o efetiva dos dados (commit)
		IF oModFull:CommitData()
			aRet	:= {.T., cWarn}
		ELSE
			aRet[2]	:= oModFull:GetErrorMessage()[6]
		ENDIF
	ELSE

		aErro := oModFull:GetErrorMessage()
		// A estrutura do vetor com erro È:
		// [1] identificador (ID) do formul·rio de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formul·rio de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da soluÁ„o
		// [8] Valor atribuÌdo
		// [9] Valor anterior


		aRet[2]	:=  aErro[4]+"-"+aErro[6]
	EndIf



	oModFull:DeActivate()
ELSE
	aRet[2]	:= "Funcionario n„o localizado."
ENDIF


Return(aRet)