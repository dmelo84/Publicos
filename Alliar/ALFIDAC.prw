#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "fileio.ch"

#DEFINE COLUNA_LOG "LOG_IMPORTACAO"


/*/{Protheus.doc} ALFIDAC
Realiza importação CSV para Protheus v12
@author Jonatas Oliveira | www.compila.com.br
@since 01/12/2017
@version 1.0
/*/
User Function ALFIDAC()

	Local cFile
	Local lAuto			:= .F.
	Local aArqDir		:= {}
	Local aArqFullPath	:= {} 

	nImpXml	:= Aviso("Titulos para baixa Dacao"," Selecione o arquivo a ser importado. [*.csv]",{"Imp. Arquivo",  "Cancelar"},2)

	IF nImpXml == 1	                                                                                 

		cFile := cGetFile('Arquivo CSV|*.csv','Selecione arquivo',0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)
		IF !EMPTY(cFile)
			aArqFullPath	:= {cFile}
		ENDIF

	ENDIF  

	Processa({||  U_ALFIDCP(aArqFullPath) })		


Return()

/*/{Protheus.doc} ALFIDCP
Cria Log e importa registros
@author Jonatas Oliveira | www.compila.com.br
@since 01/12/2017
@version 1.0
/*/
User Function ALFIDCP(aPathArq)
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


/*/{Protheus.doc} ALFIDCB
Identifica campos, tabelas e Índices
@author Jonatas Oliveira | www.compila.com.br
@since 01/12/2017
@version 1.0
/*/
User Function ALFIDCB(_cAliasT,aDados,lAltera,aItens)
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
	Local nPosBaix	:= 0
	

	Local aDadosAux	:= {}
	Local nI		:= 0
	Local cModeloImp	:= ""
	Local aParam := {}

	Local _cCodEmp 	:= ""
	Local _cCodFil	:= ""
	Local _cFilNew	:= ""
	Local cParcel	:= ""

	Local dDataAnt	:= DDATABASE 
	Local dDataBx, nPosHist
	Local _nOpc		:= 0 //|3- Inclusão, 4- Alteração, 5- Exclusão|
	Local cHist		:= "BX AUT CSV"
	Private _cRotina	:= ""

	DEFAULT lAltera	:= .T.
	/*----------------------------------------
		01/12/2017 - Jonatas Oliveira - Compila
		IMPORTANTE - ATRIBUIR DATA DA BAIXA dDataBx
	------------------------------------------*/
	IF LEN(aDados) > 0
	
		/*----------------------------------------
			01/12/2017 - Jonatas Oliveira - Compila
			IMPORTANTE - ATRIBUIR DATA DA BAIXA dDataBx
		------------------------------------------*/

		IF _cAliasT == "SE1"	

			nIndice		:= 2 //|E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO|		

			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_FILIAL"		})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_CLIENTE"		})
			nPosChv2	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_LOJA"		})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_PREFIXO"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_NUM"			})
			nPosChv5 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_PARCELA"		})
			nPosChv6 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_TIPO"		})
			
			nPosBaix 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_BAIXA"		})
			nPosHist 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E1_HIST"		})

			_cRotina	:= "FINA070"

			IF nPosChv > 0 
				cChave	:= aDados[nPosChv][2] + aDados[nPosChv1][2] + aDados[nPosChv2][2] + aDados[nPosChv3][2] + aDados[nPosChv4][2] + aDados[nPosChv5][2] + aDados[nPosChv6][2]
				
				DBSELECTAREA("SE1")
				SE1->(DBSETORDER(nIndice))
				IF SE1->(!DBSEEK( cChave ))
					aRet[1]	:= .F.
					aRet[2]	:= "Título Não Localizado "
				ENDIF 
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SE1][E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO]"
			ENDIF 
			
			If nPosBaix > 0 
				dDataBx := aDados[nPosBaix][2] //STOD(aDados[nPosBaix][2]) 
			Else 
				aRet[1]	:= .F.
				aRet[2]	:= "Data da Baixa Não informada "
			Endif 
			
			IF nPosHist > 0
				cHist := aDados[nPosHist][2] //STOD(aDados[nPosBaix][2])
			ENDIF
			
			IF aRet[1]	
				aRet := BxTitCR(SE1->(RECNO()), dDataBx, cHist)
			ENDIF
		ELSEIF _cAliasT == "SE2"
		
			/*----------------------------------------
				01/12/2017 - Jonatas Oliveira - Compila
				IMPORTANTE - ATRIBUIR DATA DA BAIXA dDataBx
			------------------------------------------*/
			nIndice		:= 1 //|E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA|		

			nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_FILIAL"		})
			nPosChv1 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_PREFIXO"		})
			nPosChv2	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_NUM"		})
			nPosChv3 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_PARCELA"		})
			nPosChv4 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_TIPO"			})
			nPosChv5 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_FORNECE"		})
			nPosChv6 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_LOJA"		})
			
			nPosBaix 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_BAIXA"		})
			nPosHist 	:= aScan( aDados , { |x| AllTrim(x[01]) == "E2_HIST"		})

			_cRotina	:= "FINA080"

			IF nPosChv > 0 
				cChave	:= aDados[nPosChv][2] + aDados[nPosChv1][2] + aDados[nPosChv2][2] + aDados[nPosChv3][2] + aDados[nPosChv4][2] + aDados[nPosChv5][2] + aDados[nPosChv6][2]
				
				DBSELECTAREA("SE2")
				SE2->(DBSETORDER(nIndice))
				IF SE2->(!DBSEEK( cChave ))
					aRet[1]	:= .F.
					aRet[2]	:= "Título Não Localizado "
				ENDIF 
			ELSE
				aRet[1]	:= .F.
				aRet[2]	:= "Chave Principal não localizada [SE2][E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA]"
			ENDIF 
			
			If nPosBaix > 0 
				dDataBx := aDados[nPosBaix][2] //STOD(aDados[nPosBaix][2]) 
			Else 
				aRet[1]	:= .F.
				aRet[2]	:= "Data da Baixa Não informada "
			Endif 
			
			IF nPosHist > 0
				cHist := aDados[nPosHist][2] //STOD(aDados[nPosBaix][2])
			ENDIF
			
			IF aRet[1]	
				aRet := BxTitCP(SE2->(RECNO()), dDataBx, cHist)
			ENDIF
		ENDIF 

		
	ELSE
		aRet[1]	:= .F.
		aRet[2]	:= "Array Vazio"
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
	
	Local nX3_CAMPO := SX3->(FIELDPOS("X3_CAMPO"))
	Local nX3_TIPO := SX3->(FIELDPOS("X3_TIPO"))
	Local nX3_TAMANHO := SX3->(FIELDPOS("X3_TAMANHO"))	


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
						AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3_CAMPO))), SX3->(FIELDGET(nX3_TIPO)), SX3->(FIELDGET(nX3_TAMANHO))})
					ELSE
						AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3_CAMPO))), "", 0 })										
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


						aItem 	:= {}
						aItens	:= {}
						cDescEst	:= ""
						aDescEst	:= {}

						FOR nI := 1 to nCabecArq
							IF aCabecX3[nI,2] == "C" .OR. aCabecX3[nI,2] == "M" 
								xVarCpo	:= PADR(ALLTRIM(aLinha[nI]),aCabecX3[nI,3]) 
							ELSEIF aCabecX3[nI,2] == "N"
								xVarCpo	:= VAL(aLinha[nI])
							ELSEIF aCabecX3[nI,2] == "D"
								xVarCpo	:= STOD(aLinha[nI])
							ENDIF

							IF EMPTY(xVarCpo)
								aaDD(aDados, {aCabecArq[nI], CRIAVAR(aCabecArq[nI],.F.), nil})
							ELSE
								aaDD(aDados, {aCabecArq[nI], xVarCpo, nil})
							ENDIF
						NEXT nI			

						//| CHAMA ROTINA DE BAIXA DACAO |
						aRetAux	:= U_ALFIDCB(cAliasImp,aDados,.F.)

						IF aRetAux[1]
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


/*/{Protheus.doc} BxTitCR
Realiza baixa(DAÇÃO) conforme os dados enviados
@author Jonatas Oliveira | www.compila.com.br
@since 01/12/2017
@version 1.0
/*/
Static Function BxTitCR(_nRecnoSe1,_dDtRec, cHist)
	//Local lBaixou	:= .F.
	Local aBaixa := {}
	Local aRetBx	:= {.F.,""}
	Local cAutoLog, cMemo
	Local nSaldo 	:= 0 
	Local nAbatim 	:= 0 
	Local _cCodEmp, _cCodFil, _cFilNew
	Local _aAreaAtu := GetArea()
	Local _cMotBx	:= "DAC"
	Local dDataAnt	:= DDATABASE
	
	Default _dDtRec	:= DDATABASE	
	Default cHist	:= ""
 
	 
	//| Altera a Data Base|
	DDATABASE	:= _dDtRec
	
	
	//Private lMsErroAuto := .F.

	dbSelectArea("SE1")
	SE1->(dbSetOrder(1))
	SE1->(dbGoTo(_nRecnoSe1))

	/*---------------------------------------
	Realiza a TROCA DA FILIAL CORRENTE SPO
	-----------------------------------------*/
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	_cFilNew	:= SE1->E1_FILIAL //| CODIGO DA FILIAL DE DESTINO 

	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
	ENDIF

	nAbatim	 := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	nSaldo :=	SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE - IIf(SE1->E1_SALDO > 0,nAbatim,0)

	If nSaldo > 0

		aAdd( aBaixa, { "E1_FILIAL" 	, SE1->E1_FILIAL						, Nil } )	// 01
		aAdd( aBaixa, { "E1_PREFIXO" 	, SE1->E1_PREFIXO						, Nil } )	// 01
		aAdd( aBaixa, { "E1_NUM"     	, SE1->E1_NUM		 					, Nil } )	// 02
		aAdd( aBaixa, { "E1_PARCELA" 	, SE1->E1_PARCELA						, Nil } )	// 03
		aAdd( aBaixa, { "E1_TIPO"    	, SE1->E1_TIPO							, Nil } )	// 04
		aAdd( aBaixa, { "E1_CLIENTE"	, SE1->E1_CLIENTE						, Nil } )	// 05
		aAdd( aBaixa, { "E1_LOJA"    	, SE1->E1_LOJA							, Nil } )	// 06
		aAdd( aBaixa, { "AUTMOTBX"  	, _cMotBx								, Nil } )	// 07
		aAdd( aBaixa, { "AUTDTBAIXA"	, _dDtRec			                	, Nil } )	// 11
		aAdd( aBaixa, { "AUTDTCREDITO"	, _dDtRec              				    , Nil } )	// 11
		aAdd( aBaixa, { "AUTHIST"   	, cHist				                 	, Nil } )	// 12
		aAdd( aBaixa, { "AUTVALREC" 	, nSaldo								, Nil } )


		lMSHelpAuto := .T. //.F. // para nao mostrar os erro na tela
		lMSErroAuto := .F.
		//lAutoErrNoFile := .T.

		Begin Transaction
			DBSELECTAREA("SE5")
			MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)

			If lMsErroAuto
				//MOSTRAERRO()
				cAutoLog	:= alltrim(NOMEAUTOLOG())

				cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
				cMemo := STRTRAN(cMemo,"'","")

				//| Apaga arquivo de Log
				Ferase(cAutoLog)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Le Log da Execauto e retorna mensagem amigavel ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//|*******COMPILAXFUN.PRW*******|
				aRetBx[2] := U_CPXERRO(cMemo)
				IF EMPTY(aRetBx[2])
					aRetBx[2]	:= alltrim(cMemo)
				ENDIF


				aRetBx[1] := .F.

				DisarmTransaction()		
			else
				aRetBx[1] := .T.
			EndIf
		End Transaction

	EndIf


	/*---------------------------------------
	Restaura FILIAL  
	-----------------------------------------*/
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)			 			
	ENDIF  


	DDATABASE	:= dDataAnt
	
	RestArea(_aAreaAtu)

Return(aRetBx)	

/*/{Protheus.doc} BxTitCP
Baixa título do contas a pagar.
@author Augusto Ribeiro | www.compila.com.br
@since 29/11/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function BxTitCP(nRecSE2, _dDtRec, cHist)
	Local aRet		:= {.F.,""}
	Local aBaixa	:=	{}
	Local _aAreaAtu := GetArea()
	Local _cCodFil  := cFilAnt
	Local _lRetBx   := .T.
	Local _cCodEmp, _cCodFil, _cFilNew
	Local cAutoLog, cMemo
	Local dDataAnt	:= DDATABASE

	Local cMotBx	:= "DAC"
	Local nOpc		:= 3//| Baixa| 
	Local nSaldo	:= 0 
	Local dDtMov	
	
	Default _dDtRec	:= DDATABASE	
	Default cHist	:= ""	
	

	DbSelectArea("SE2")   
	SE2->(DbGoTo(nRecSE2))
	
	//| Altera a Data Base|
	DDATABASE	:= _dDtRec	

	/*---------------------------------------
	Realiza a TROCA DA FILIAL CORRENTE SPO
	-----------------------------------------*/
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	_cFilNew	:= SE2->E2_FILIAL //| CODIGO DA FILIAL DE DESTINO 

	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
	ENDIF
	
	nAbatim	:= SomaAbat(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA,"R",SE2->E2_MOEDA,,SE2->E2_FORNECE,SE2->E2_LOJA)
	nSaldo 	:= SE2->E2_SALDO + SE2->E2_SDACRES - SE2->E2_SDDECRE - IIf(SE2->E2_SALDO > 0,nAbatim,0)

	aAdd( aBaixa, { "E2_FILIAL" 	, SE2->E2_FILIAL						, Nil } )	// 01
	aAdd( aBaixa, { "E2_PREFIXO" 	, SE2->E2_PREFIXO						, Nil } )	// 01
	aAdd( aBaixa, { "E2_NUM"     	, SE2->E2_NUM		 					, Nil } )	// 02
	aAdd( aBaixa, { "E2_PARCELA" 	, SE2->E2_PARCELA						, Nil } )	// 03
	aAdd( aBaixa, { "E2_TIPO"    	, SE2->E2_TIPO							, Nil } )	// 04
	aAdd( aBaixa, { "E2_FORNECE"	, SE2->E2_FORNECE						, Nil } )	// 05
	aAdd( aBaixa, { "E2_LOJA"    	, SE2->E2_LOJA							, Nil } )	// 06
	aAdd( aBaixa, { "AUTMOTBX"  	, cMotBx								, Nil } )	// 07
	aAdd( aBaixa, { "AUTDTBAIXA"	, _dDtRec			                	, Nil } )	// 11
	aAdd( aBaixa, { "AUTDTCREDITO"	, _dDtRec              				    , Nil } )	// 11
	aAdd( aBaixa, { "AUTHIST"   	, cHist					, Nil } )	// 12
	aAdd( aBaixa, { "AUTVLRPG" 		, nSaldo								, Nil } )	// 13
	aAdd( aBaixa, { "AUTVALREC" 	, nSaldo								, Nil } )	// 13

	lMSErroAuto := .F.
	lMSHelpAuto := .T.
	//MSExecAuto({|x, y| Fina080(x, y)}, aBaixa,nOpc)
	nOpbaixa	:= 1
	MSExecAuto({|x,y,z,a| FINA080(x,y,z,a)},aBaixa,nOpc,,nOpbaixa)  


	If 	lMsErroAuto
		_lRetBx := .F.
		//Mostraerro()

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

	ELSE

		aRet[1]	:= .T.
	Endif


	/*---------------------------------------
	Restaura FILIAL  
	-----------------------------------------*/
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)			 			
	ENDIF   
	
	DDATABASE	:= dDataAnt

	RestArea(_aAreaAtu)

Return(aRet)