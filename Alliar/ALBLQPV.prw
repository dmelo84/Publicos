#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "fileio.ch"

#DEFINE COLUNA_LOG "LOG_IMPORTACAO"

User Function ALBLQPV()
	Local cFile
	Local lAuto			:= .F.
	Local aArqDir		:= {}
	Local aArqFullPath	:= {} 
	Local aPathArq		:= {}
	Local cMsgErro	:= ""
	Local nTotArq, nI
	
	/*---------------------------------------------------------------- Augusto Ribeiro | Oct 27, 2015
	Variaveis para gracao do Log
	------------------------------------------------------------------------------------------*/
	Private _cFileLog	 	:= ""    
	Private _cLogPath		:= ""  
	Private _Handle			:= "" 
	
	Private aRetImp		:= {.F. ,""}
	Private aRetAux		:= {.F. ,""}
	
	nImpXml	:= Aviso("Pedidos Motoboy para Bloqueio"," Selecione o arquivo a ser importado. [*.csv]",{"Imp. Arquivo",  "Cancelar"},2)

	IF nImpXml == 1	                                                                                 

		cFile := cGetFile('Arquivo CSV|*.csv','Selecione arquivo',0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)
		IF !EMPTY(cFile)
			aArqFullPath	:= {cFile}
		ENDIF

	ENDIF  
	
	aPathArq := aArqFullPath
	
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
	
Return



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

	Local _nPosIdP 		:= 0
	Local _nPosFil 		:= 0
	Local _nPosPv	 	:= 0	
	Local _nPosRecC5 	:= 0	

	Local nX3_CAMPO := SX3->(FIELDPOS("X3_CAMPO"))
	Local nX3_TIPO := SX3->(FIELDPOS("X3_TIPO"))
	Local nX3_TAMANHO := SX3->(FIELDPOS("X3_TAMANHO"))

	Private aCabecArq := {}
	Private nCabecArq := {}

	Private aCabecF := {}
	Private nCabecF := {}
	
	
	//AADD(aCabecX3, {alltrim(SX3->X3_CAMPO), SX3->X3_TIPO, SX3->X3_TAMANHO})

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
						//AADD(aCabecX3, {alltrim(SX3->X3_CAMPO), SX3->X3_TIPO, SX3->X3_TAMANHO})
						AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3_CAMPO))), SX3->(FIELDGET(nX3_TIPO)), SX3->(FIELDGET(nX3_TAMANHO))})
					ELSE
						IF ALLTRIM(UPPER(aCabecArq[nI])) == "RECSC5"
							AADD(aCabecX3, {"RECSC5", "N", 0})
						ELSE
							AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3_CAMPO))), "", 0 })
						ENDIF 										
					ENDIF
				next nI
				
				_nPosIdP 	:= aScan(aCabecX3	, {|x| x[1] == "C5_XIDPLE" })
				_nPosFil 	:= aScan(aCabecX3	, {|x| x[1] == "C5_FILIAL" })
				_nPosPv 	:= aScan(aCabecX3	, {|x| x[1] == "C5_NUM" })
				_nPosRecC5 	:= aScan(aCabecX3	, {|x| x[1] == "RECSC5" })
				
				IF _nPosRecC5 > 0 
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
	
								IF !EMPTY(xVarCpo)
									aaDD(aDados, {aCabecArq[nI], xVarCpo, nil})
								ENDIF
							NEXT nI			
	
							//| CHAMA ROTINA BLOQUEIO |
							aRetAux	:= U_ALBLMOT(aDados[_nPosRecC5][2])
	
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
				ELSE
					aRet[2]	:= "Falha: Coluna RECSC5 não localizada ["+cFullTemp+"]"
				ENDIF 
				
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

User Function ALBLMOT(nRecSc5)
	Local aRetPrc	:= {.T.,""}
	Local _cCodEmp, _cCodFil, _cFilNew

	DBSELECTAREA("SC5")
	SC5->(DBGOTO(nRecSc5))
	
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	
	IF EMPTY(SC5->C5_NOTA) .AND. EMPTY(SC5->C5_SERIE) 
		DBSELECTAREA("SC6")
		SC6->(DBSETORDER(1))
		
		IF SC6->(DBSEEK(SC5->(C5_FILIAL + C5_NUM )))
			IF EMPTY(SC6->C6_NOTA) .AND. EMPTY(SC6->C6_SERIE) 
				
				WHILE SC6->(!EOF()) .AND. SC5->(C5_FILIAL + C5_NUM ) == SC6->(C6_FILIAL + C6_NUM )
					/*---------------------------------------
					Realiza a TROCA DA FILIAL CORRENTE SPO
					-----------------------------------------*/
					_cFilNew	:= SC5->C5_FILIAL
					
					IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
						CFILANT := _cFilNew
						opensm0(_cCodEmp+CFILANT)
					ENDIF
					
					MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,,,.T.,.T.,.F.,.F.) 
					
					DBSELECTAREA("SC9")
					SC9->(DBSETORDER(1))//|C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO|
					
					IF SC9->(DBSEEK(SC6->(C6_FILIAL + C6_NUM + C6_ITEM )))
						SC5->(RecLock("SC5",.F.))
							SC5->C5_NOTA	:= "MOTOBOY"
							SC5->C5_SERIE	:= "MOT"					
						SC5->(MsUnLock())
						
						SC6->(RecLock("SC6",.F.))
							SC6->C6_NOTA	:= "MOTOBOY"
							SC6->C6_SERIE	:= "MOT"					
						SC6->(MsUnLock())
						
						SC9->(RecLock("SC9",.F.))
							SC9->C9_NFISCAL	:= "MOTOBOY"
							SC9->C9_SERIENF	:= "MOT"
							SC9->C9_BLEST	:= "10"		
							SC9->C9_BLCRED	:= "10"			
						SC6->(MsUnLock())			
					ELSE
						aRetPrc[1] := .F.
						aRetPrc[2] += " Liberação Item Não localizado"
					ENDIF
					
					/*---------------------------------------
						Restaura FILIAL  
					-----------------------------------------*/
					IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
						CFILANT := _cCodFil
						opensm0(_cCodEmp+CFILANT)			 			
					ENDIF  
					
					SC6->(DBSKIP())
				ENDDO 
			ELSE
				aRetPrc[1] := .F.
				aRetPrc[2] += " Item Pedido Já finalizado"
			ENDIF 
		ELSE
			aRetPrc[1] := .F.
			aRetPrc[2] += " Item Não localizado"
		ENDIF
		
	ELSE
		aRetPrc[1] := .F.
		aRetPrc[2] += " Pedido Já finalizado"
	ENDIF 

Return(aRetPrc)


/*/{Protheus.doc} ALDLMOT
Realiza o desbloqueio temporario de
pedidos de venda de Motoboy
@author Jonatas Oliveira | www.compila.com.br
@since 19/01/2018
@version 1.0
/*/
User Function ALDLMOT(cTipo)
	Local cQuery	:= ""
	Local aRetPrc	:= {.T.,""}
	Local _cCodEmp, _cCodFil, _cFilNew
	Local cPrdMot	:= GetMV("ES_PRDMOT", .F., "23000004") 
	Local cTesMot	:= GetMV("ES_TESMOT",.F.,"509")
	Local cAutoLog, cMemo
	Local aRetBx	:= {.F.,""}
	Local aCabec := {}
	Local aItens := {}
	Local aLinha := {}
	
	Private _cFileLog
	Private _cLogPath
	Private _Handle
	
	Default cTipo := "1"
	
	
	cQuery += " SELECT C5.R_E_C_N_O_ AS C5RECNO,C6.R_E_C_N_O_ AS C6RECNO "
	cQuery += " FROM SC5010 C5                                                                    "
	cQuery += " INNER JOIN SC6010 C6                                                              "
	cQuery += " 	ON C5_FILIAL = C6.C6_FILIAL                                                   "
	cQuery += " 	AND C5_NUM = C6.C6_NUM                                                        "
	cQuery += " 	AND C6.D_E_L_E_T_ = ''                                                        "
	/*	
	cQuery += " INNER JOIN SC9010 C9                                                              "
	cQuery += " 	ON C5_FILIAL = C9_FILIAL                                                      "
	cQuery += " 	AND C5_NUM = C9_PEDIDO                                                        "
	cQuery += " 	AND C6.D_E_L_E_T_ = ''                                                        "
	*/
	
	IF cTipo == "1"
		cQuery += " WHERE C5.D_E_L_E_T_ = ''                                                          "
		cQuery += " 	AND C5_FILIAL BETWEEN '00201SP0001' AND '00201SP0020'                         "
		cQuery += " 	AND C5_NOTA = 'MOTOBOY'														  "
	ELSE
		cQuery += " 	AND C6_VALOR = 12          "
		cQuery += " WHERE C5.D_E_L_E_T_ = ''                                                          "
		cQuery += " 	AND C5_FILIAL BETWEEN '00201SP0001' AND '00201SP0020'                         "
		cQuery += " 	AND C5_XDATAI >= '20180119'													  "
		cQuery += " 	AND C5_NOTA = ''  "
		cQuery += " 	AND C5_XMOTOB <> '1'  "
	ENDIF 
	
	If Select("QRYDBL") > 0
		QRYDBL->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYDBL')
	
	DBSELECTAREA("SC5")
	DBSELECTAREA("SC6")
	DBSELECTAREA("SC9")
	SC9->(DBSETORDER(1))
	
	fGrvLog(1,"INICIO GRAVACAO" )	//||Opcao:  1= Cria Arquivo de Log, 2= Grava Log, 3 = Apresenta Log
	
	WHILE QRYDBL->(!EOF())
		SC5->(DBGOTO(QRYDBL->C5RECNO))
		SC6->(DBGOTO(QRYDBL->C6RECNO))
		
		
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
				
		/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE SPO
		-----------------------------------------*/
		_cFilNew	:= SC5->C5_FILIAL
		
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF
		
//		MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,,,.T.,.T.,.F.,.F.) 
		
		DBSELECTAREA("SC9")
		SC9->(DBSETORDER(1))//|C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO|
		
		BEGIN TRANSACTION
			SC5->(RecLock("SC5",.F.))
				SC5->C5_NOTA	:= ""
				SC5->C5_SERIE	:= ""	
				SC5->C5_XMOTOB	:= "1"				
			SC5->(MsUnLock())
			
			SC6->(RecLock("SC6",.F.))
				SC6->C6_NOTA	:= ""
				SC6->C6_SERIE	:= ""	
				/*
				SC6->C6_PRODUTO	:= cPrdMot		
				SC6->C6_TES		:= cTesMot
				SC6->C6_DESCRI	:= posicione("SB1",1,XFILIAL("SB1") + cPrdMot,"B1_DESC")
				*/
			SC6->(MsUnLock())
			
			IF SC9->(DBSEEK(SC6->(C6_FILIAL + C6_NUM )))
				WHILE SC9->(!EOF()) .AND. SC9->(C9_FILIAL + C9_PEDIDO ) == SC5->(C5_FILIAL + C5_NUM )
					SC9->(RecLock("SC9",.F.))
						SC9->(DbDelete())		
					SC9->(MsUnLock())	
					SC9->(DBSKIP())
				ENDDO	
			ENDIF 	
			
			
			aCabec := {}
		    aItens := {}
		    aadd(aCabec,{"C5_NUM"		,SC5->C5_NUM		,Nil})
		    aadd(aCabec,{"C5_TIPO"		,SC5->C5_TIPO		,Nil})
		    aadd(aCabec,{"C5_CLIENTE"	,SC5->C5_CLIENTE	,Nil})
		    aadd(aCabec,{"C5_LOJACLI"	,SC5->C5_LOJACLI	,Nil})
		    aadd(aCabec,{"C5_LOJAENT"	,SC5->C5_LOJAENT	,Nil})
		    aadd(aCabec,{"C5_CONDPAG"	,SC5->C5_CONDPAG	,Nil})		    
		            
	        aLinha := {}
	        aadd(aLinha,{"LINPOS"		,"C6_ITEM"			,SC6->C6_ITEM})
	        aadd(aLinha,{"AUTDELETA"	,"N"				,Nil})
	        aadd(aLinha,{"C6_PRODUTO"	,cPrdMot			,Nil})
	        aadd(aLinha,{"C6_QTDVEN"	,SC6->C6_QTDVEN		,Nil})
	        aadd(aLinha,{"C6_PRCVEN"	,SC6->C6_PRCVEN		,Nil})
	        aadd(aLinha,{"C6_PRUNIT"	,SC6->C6_PRUNIT		,Nil})
	        aadd(aLinha,{"C6_VALOR"		,SC6->C6_VALOR		,Nil})
	        aadd(aLinha,{"C6_TES"		,cTesMot			,Nil})
	        aadd(aItens,aLinha)
	        
	        lMSErroAuto := .F.
	        
			MATA410(aCabec,aItens,4)
			
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

				fGrvLog(2, "FALHA AO ALTERAR O PEDIDO: " + SC5->(C5_FILIAL + C5_NUM) + " ERRO: " + aRetBx[2])
				
				aRetBx[1] := .F.

				DisarmTransaction()		
			else
				SC5->(RecLock("SC5",.F.))
					SC5->C5_NOTA	:= ""
					SC5->C5_SERIE	:= ""	
					SC5->C5_XMOTOB	:= "1"				
				SC5->(MsUnLock())
				
				SC6->(RecLock("SC6",.F.))
					SC6->C6_NOTA	:= ""
					SC6->C6_SERIE	:= ""	
				SC6->(MsUnLock())
				
				fGrvLog(2, "PEDIDO DISPONIVEL PARA FATURAMENTO: " + SC5->(C5_FILIAL + C5_NUM))
			EndIf
			
			//DISARMTRANSACTION()
		END TRANSACTION 
				

		
		
		/*---------------------------------------
			Restaura FILIAL  
		-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF  
		
		
		QRYDBL->(DBSKIP())
	ENDDO
	
	fGrvLog(3,"FINAL DE GRAVACAO")
Return 



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
