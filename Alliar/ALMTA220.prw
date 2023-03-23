#include 'protheus.ch'
#INCLUDE 'TBICONN.CH'
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "fileio.ch"

#DEFINE COLUNA_LOG "LOG_IMPORTACAO"

/*/{Protheus.doc} ALTESTE
Rotina para testes unitários e pontuais.
@author Fabio Sales | www.compila.com.br
@since 19/09/2019
@version 1
@see (links_or_references)
/*/


USER FUNCTION ALTESTE()

	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '00101MG0001' MODULO 'EST' FUNNAME 'ALMTA220'


	//u_OMMTA001()
		/*
			//| Saldos iniciais.
			alSB9 :={"100087","01",date(),150,2000}
			
			alert("teste1")
			
			//| Rateio do Lote
			
			alSD5:= {}
			AADD(alSD5,{"100087","01",DDATABASE,50,"FSALES01",DDATABASE + 60})
			AADD(alSD5,{"100087","01",DDATABASE,45,"FSALES02",DDATABASE + 60})
			AADD(alSD5,{"100087","01",DDATABASE,55,"FSALES03",DDATABASE + 60})
			
			ALTESTE := U_ALMTA220(alSB9,alSD5)
		*/

	//U_ALMT220B({"E:\ALLIAR\60_SABEDOTTI_v2.csv"})
	U_ALMT220B({"E:\ALLIAR\arq2.csv"})

	RESET ENVIRONMENT

RETURN()


/*/{Protheus.doc} ALMTA220
Importação de saldos Iniciais com lotes com base na planilha
@author Fabio Sales | www.compila.com.br
@since 19/09/2019
@version 1
@see (links_or_references)
/*/

USER FUNCTION ALMTA220()

	Local nlOpc	:= 0
	Local cFile	:= ""
	Local cMSg := ""

	cMSg	:= " Selecione o arquivo a ser importado. [*.csv]"+CRLF
	cMSg	+= " Importante: "+CRLF
	cMSg	+= " - Quebra de linha CR+LF "+CRLF
	cMSg	+= " - Não utilizar separador de MILHAR. "+CRLF
	cMSg	+= " - Utilizar ponto (.) para separador de DECIMAL. "+CRLF

	nlOpc	:= Aviso("Importação de Saldos Iniciais",cMSg,{"Imp. Arquivo","Cancelar"},2)

	IF nlOpc == 1

		cFile := cGetFile('Arquivo CSV|*.csv','Selecione arquivo',0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)

		IF !EMPTY(cFile)

			aArqFullPath	:= {cFile}

		ENDIF

	ENDIF

	IF nlOpc == 1 .AND. !EMPTY(cFile)

		Processa({||  U_ALMT220B(aArqFullPath) })

	ENDIF

RETURN()


/*/{Protheus.doc} CP12004
Importação de saldos Iniciais com lotes
@author Fabio Sales | www.compila.com.br
@since 19/09/2019
@version 1
@param alSB9 , A, Array com os saldos Iniciais(SB9)
@param alSD5 , A, Array com o rateio das movimentações do lote(SD5)
@return alRet, Retorna um Array com mensagem de erro ou sucesso.
@example
(examples)
@see (links_or_references)
/*/

USER FUNCTION ALMT220A(alSB9,alSD5)


	Local alRet 	:= {.T.,""}
	//Local clDoc  	:= ""
	Local alVetSB9	:= {}
	//Local alVetSD5	:= {}
	//Local nlI		:= 0
	Local clAutoLog	:= ""
	Local clMemo	:= ""
	Local alArea	:= GetArea()
	Local alLinha	:= {}
	Local nlQtde	:= 0

	Local nI

	Default alSB9 	:= {}
	Default alSD5 	:= {}

	Private	_xSD5Itens	:= {}

	IF LEN(alSB9) > 0

		//| Alimenta Array que será utilizado no ponto de entrada MT220TOK

		DBSELECTAREA("SB1")
		SB1->(DBSETORDER(1)) //| B1_FILIAL, B1_COD, R_E_C_N_O_, D_E_L_E_T_
		IF SB1->(DBSEEK(XFILIAL("SB1") + Alltrim(alSB9[2])))

			IF SB1->B1_RASTRO <> "N"

				nlQtde	:= LEN(alSD5)

				IF nlQtde > 0

					FOR nI:= 1 TO nlQtde

						alLinha := {}
						aadd(alLinha, alSD5[nI][1]) //| Produto
						aadd(alLinha, alSD5[nI][2]) //| Local
						aadd(alLinha, alSD5[nI][3])	//| Data da movimentação
						aadd(alLinha, alSD5[nI][4])	//| Quantidade
						aadd(alLinha, 0) 			//| qtde 2ª unidade|
						aadd(alLinha, alSD5[nI][5])	//| Numero do Lote
						aadd(alLinha, "") 			//| SubLote |
						aadd(alLinha, alSD5[nI][6]) //| Data de Validade
						aadd(alLinha, 0 ) 			//| potencia
						aadd(alLinha, .F. ) 		//|

						aadd(_xSD5Itens, aClone(alLinha))

					NEXT nI

				ENDIF

			ENDIF


			DbSelectArea("SB9")
			SB9->(DbSetOrder(1)) //B9_FILIAL+B9_COD+B9_LOCAL+DTOS(B9_DATA)
			/*
			alVetSB9 := {{"B9_COD"	, alSB9[2] , Nil},; //| Produto
			    		 {"B9_LOCAL", alSB9[3] , Nil},; //| Armazém
			    		 {"B9_DATA"	, alSB9[4] , Nil},; //| Data
			    		 {"B9_QINI"	, alSB9[5] , Nil},; //| Qtde Inicial
			    		 {"B9_VINI1", alSB9[6] , Nil}}  //| Vlr Inicial
			  */

			alVetSB9 := {{"B9_COD"	, alSB9[2] , Nil},; //| Produto
			{"B9_LOCAL", alSB9[3] , Nil},; //| Armazém
			{"B9_QINI"	, alSB9[5] , Nil},; //| Qtde Inicial
			{"B9_VINI1", alSB9[6] , Nil}}  //| Vlr Inicial

			//Iniciando transação e executando saldos iniciais

			BEGIN TRANSACTION

				lMsErroAuto := .F.
				MSExecAuto({|x, y| Mata220(x, y)}, alVetSB9, 3)

				//Se houve erro, mostra mensagem

				If lMsErroAuto

					//MostraErro()

					DisarmTransaction()

					clAutoLog	:= alltrim(NOMEAUTOLOG())

					clMemo := STRTRAN(MemoRead(clAutoLog),'"',"")
					clMemo := STRTRAN(clMemo,"'","")

					//| Apaga arquivo de Log

					Ferase(clAutoLog)

					//| Le Log da Execauto e retorna mensagem amigavel

					alRet[1]	:= .F.
					alRet[2] := U_CPXERRO(clMemo)

					IF EMPTY(alRet[2])

						alRet[2]	:= alltrim(clMemo)

					ENDIF

				ENDIF

			END TRANSACTION

		ELSE

			alRet[1]	:= .F.
			alRet[2]	:= "Produto não cadastrado. " + alSB9[2]

		ENDIF

	ELSE

		alRet[1]	:= .F.
		alRet[2]	:= "Preencha os dados de inserção"

	ENDIF

	RestArea(alArea)

RETURN(alRet)




/*/{Protheus.doc} ALMT220B
Importa dos os arquivos recebidos no Array
@author Fabio Sales | www.compila.com.br
@since Set 21, 2019
@version version
@param aPathArq, A, Array com caminho completo dos arquivos.
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function ALMT220B(aPathArq)

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
	
			FOR nI := 1 to nTotArq
			
				IncProc("Importando Arquivos... "+TRANSFORM(nI, "@e 999,999,999")+" de "+TRANSFORM(nTotArq,"@e 999,999,999"))
				
				aRetImp		:= impArq(aPathArq[nI])	
				
				IF aRetImp[1]
					cMsgErro	+= "ARQUIVO: "+aPathArq[nI]+" | LOG: SUCESSO (TODOS OS REGISTROS FORAM PROCESSADOS COM SUCESSO). " + ALLTRIM(aRetImp[2])	+CRLF
				ELSE
					cMsgErro	+= "ARQUIVO: "+aPathArq[nI]+" | LOG: "+aRetImp[2]+CRLF
				ENDIF
			 	
			NEXT nI
			
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
	//Local llUltimo	:= .F.

	//Local nHdlArq, cLinha, aLinha, aDados, nTotLin,aItens, aItem
	Local nHdlErro	:= 0
	Local nReg	:= 0
	//Local lArqErro	:= .F.
	//Local cCabecArq, cCabecF
	Local nPosErro	:= 0
	Local xVarCpo
	Local nRet	:= 0 //| 0=Valor Inicial, 1=Sucesso, 2=Erro |

	Local _nPosFil 		:= 0
	//Local _nPosChv 		:= 0
	//Local _nPosChv2 	:= 0

Local nj

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
				
				FOR nI:= 1 to Len(aCabecArq)
				
					IF SX3->(DBSEEK(ALLTRIM(UPPER(aCabecArq[nI]))))

						AADD( aCabecX3, {;
							alltrim( SX3->( FIELDGET( FIELDPOS("X3_CAMPO") ) ) ) ,;
					 		SX3->( FIELDGET( FIELDPOS("X3_TIPO") ) ) ,;
						 	SX3->( FIELDGET( FIELDPOS("X3_TAMANHO") ) );
						 	})

					ELSE
						AADD(aCabecX3, {alltrim(SX3->(FIELDGET(FIELDPOS("X3_CAMPO")))), "", 0 })										
					ENDIF
					
				NEXT nI
				
						
				FT_FSKIP()
				
				aDados	:= {}
								
				WHILE !FT_FEOF()
				
					nReg++					
					IncProc("Processando registro... "+STRZERO(nReg,6)+" de "+STRZERO(nTotLin,6))					
	
					cErroLin	:= ""
					
					//|aDados		:= {}
					
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
						
						
						/*
						Cria um array com a mesma qtde de colunas
						que o cabeçalho.
						*/

						alDads	:= Array(nCabecArq)

						FOR nI := 1 to nCabecArq

							IF aCabecX3[nI,2] == "C" .OR. aCabecX3[nI,2] == "M"
								xVarCpo	:= PADR(ALLTRIM(aLinha[nI]),aCabecX3[nI,3])
							ELSEIF aCabecX3[nI,2] == "N"
								xVarCpo	:= VAL(STRTRAN(aLinha[nI],',','.'))
							ELSEIF aCabecX3[nI,2] == "D"
								xVarCpo	:= CTOD(aLinha[nI])
							ENDIF

							alDads[nI] := xVarCpo

						NEXT nI

						AADD(aDados,ACLONE(alDads))

					ELSE
						cErroLin	+= "Quantidade de Colunas diverge do cabecalho do arquivo"
					ENDIF


					FT_FSKIP()
				ENDDO

			ELSE
				aRet[2]	:= "Falha na abertura do arquivo ["+cFullTemp+"]"
			ENDIF
		ELSE
			aRet[2]	:= "Caminho do arquivo invalido ou vazio ["+cPathFull+"]."
		ENDIF
	ELSE
		aRet[2]	:= "Caminho do arquivo invalido ou vazio"
	ENDIF

	//| Pega as posiçõões dos campos chaves.

	_nPosFil := aScan(aCabecX3, { |x| AllTrim(x[1]) == "B9_FILIAL"})
	_nPosCod := aScan(aCabecX3, { |x| AllTrim(x[1]) == "B9_COD"})
	_nPosLoc := aScan(aCabecX3, { |x| AllTrim(x[1]) == "B9_LOCAL"})

	_nPosQin := aScan(aCabecX3, { |x| AllTrim(x[1]) == "B9_QINI"})
	_nPosTin := aScan(aCabecX3, { |x| AllTrim(x[1]) == "B9_VINI1"})
	_nPosLot := aScan(aCabecX3, { |x| AllTrim(x[1]) == "D5_LOTECTL"})
	_nPosDatV:= aScan(aCabecX3, { |x| AllTrim(x[1]) == "D5_DTVALID"})

	//| Ordena o Array por Filial + Produto + Local

	aSort(aDados,NIL,NIL,{|x,y|x[_nPosFil] + x[_nPosCod] + x[_nPosLoc] < y[_nPosFil] + y[_nPosCod] + y[_nPosLoc]})

	alSD5 		:= {}
	alSB9		:= {"","","",,0,0}
	AlLog		:= {}
	nlQtde		:= Len(aDados)

	nlQtde := nlQtde + 1

	ProcRegua(nlQtde)

	nJ := 0
	FOR nJ := 1 TO nlQtde

		//| Controle para poder processar o Último produto do Array aDados

		IF nlQtde > LEN(aDados)

			AADD(aDados,Array(nCabecArq))

		ENDIF

		IncProc("Importando Resgistro... "+TRANSFORM(nJ, "@e 999,999,999")+" de "+TRANSFORM(nlQtde,"@e 999,999,999"))

		IF AllTrim(aDados[Nj,_nPosFil]) == alltrim(alSB9[_nPosFil]) .AND. AllTrim(aDados[Nj,_nPosCod]) == alltrim(alSB9[_nPosCod]) .AND. AllTrim(aDados[Nj,_nPosLoc]) == alltrim(alSB9[_nPosLoc])


			//| Preenche o Array das movimentações do lote. são possições fixas.
			AADD(alSD5,{aDados[Nj,_nPosCod],aDados[Nj,_nPosLoc],DDATABASE,aDados[Nj,_nPosQin],aDados[Nj,_nPosLot],aDados[Nj,_nPosDatV]})
			AADD(AlLog,aDados[Nj])

			alSB9[5] :=  alSB9[5] + aDados[Nj,_nPosQin] //| Quantidade Iniciai
			alSB9[6] :=  alSB9[6] + aDados[Nj,_nPosTin]	//| Valor Inicial

			LOOP

		ELSE

			IF (AllTrim(aDados[Nj,_nPosFil]) <> alltrim(alSB9[_nPosFil]) .OR. AllTrim(aDados[Nj,_nPosCod]) <> alltrim(alSB9[_nPosCod]) .OR. AllTrim(aDados[Nj,_nPosLoc]) <> alltrim(alSB9[_nPosLoc])) .AND. !EMPTY(alSB9[_nPosCod])

				/*
				DBSELECTAREA("NNR")
				NNR->(DBSETORDER(1))
				IF !NNR->(DBSEEK(XFILIAL("NNR") + ALLTRIM(alSB9[_nPosLoc] )))
				
					NNR->(RECLOCK("NNR",.T.))
					
					NNR->(MsUnLock())
				
				ENDIF
				*/



				/*---------------------------------------
					Realiza a TROCA DA FILIAL CORRENTE 
				-----------------------------------------*/
				
				_cCodEmp 	:= SM0->M0_CODIGO
				_cCodFil	:= SM0->M0_CODFIL
				_cFilNew	:= ALLTRIM(alSB9[_nPosFil]) //| CODIGO DA FILIAL DE DESTINO 
				
				IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
					CFILANT := _cFilNew
					opensm0(_cCodEmp+CFILANT)
				ENDIF
				
				
				aRetAux := U_ALMT220A(alSB9,alSD5)
				
				
				/*---------------------------------------
					Restaura FILIAL  
				-----------------------------------------*/
				IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
					CFILANT := _cCodFil
					opensm0(_cCodEmp+CFILANT)			 			
				ENDIF
				
						
				IF aRetAux[1]
				
					IF nRet == 0
					
						nRet	:= 1
						
					ENDIF
					
				ELSE
					cErroLin	+= aRetAux[2]
				ENDIF
						
				IF !EMPTY(cErroLin)
				
					nRet := 2 //| Erro
					
					nI:= 0
					FOR nI := 1 TO Len(AlLog)
										
						GrvArqErro(@nHdlErro, cArqLog,AlLog[nI], cErroLin)
					
					NEXT nI
					nI:= 0
					
				ENDIF
				
				cErroLin := ""
				alSD5	:= {}
				AlLog	:= {}
				
								
				alSB9 := {aDados[Nj,_nPosFil],aDados[Nj,_nPosCod],aDados[Nj,_nPosLoc],DDATABASE,aDados[Nj,_nPosQin],aDados[Nj,_nPosTin]}
				AADD(alSD5,{aDados[Nj,_nPosCod],aDados[Nj,_nPosLoc],DDATABASE,aDados[Nj,_nPosQin],aDados[Nj,_nPosLot],aDados[Nj,_nPosDatV]})				
				AADD(AlLog,aDados[Nj])
				
			ELSE
			 
			 	//| Preenche o Array das movimentações do lote. são possições fixas.
			 	AADD(alSD5,{aDados[Nj,_nPosCod],aDados[Nj,_nPosLoc],DDATABASE,aDados[Nj,_nPosQin],aDados[Nj,_nPosLot],aDados[Nj,_nPosDatV]})			 	
				alSB9 := {aDados[Nj,_nPosFil],aDados[Nj,_nPosCod],aDados[Nj,_nPosLoc],DDATABASE,aDados[Nj,_nPosQin],aDados[Nj,_nPosTin]}
				AADD(AlLog,aDados[Nj])
														
			ENDIF
			
		ENDIF
	
	NEXT nJ
	nJ := 0
	nlQtde:= 0
	
	IF nHdlErro > 0
		fClose(nHdlErro)
	ENDIF
	
	IF nRet == 1 //| Todos os registros foram processados com sucesso|
		aRet[1]	:= .T.
		aRet[2]	:= "Total de registros " + alltrim(STR(nTotLin)) + " Total Importado " + alltrim(STR(nReg))
	ELSEIF nRet == 2
		aRet[1]	:= .F.
		aRet[2]	:= "Alguns registros foram processados com erro, por favor verifique o log de erro ["+cArqLog+"] Total de registros " + alltrim(STR(nTotLin)) + " Total Processado " + alltrim(STR(nReg))"
		
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
	//Local cAnoMes, cDirComp, cCurDir, nAux, aPastas
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
		nI:= 0
			FOR nI := 1 to nCabecArq
			cCabec += aCabecArq[nI]+";"
			next nI
		nI:= 0
		cCabec	+= COLUNA_LOG
		
		nAux	:= FWrite(nHdlErro, cCabec+CRLF)				 
		endif
	
	
	//| Tratamento para sempre gravar o log na coluna correta|
	cLinErro	:= ""
	nQtdeLin	:= len(aLinha)
	
	nI:= 0
		FOR nI := 1 to nCabecArq
	
			IF nQtdeLin >= nI
			
				IF VALTYPE(aLinha[nI]) == "N"
			
				aLinha[nI]:= strtran(cvaltochar(aLinha[nI]),'.',',')
				
				ELSEIF VALTYPE(aLinha[nI]) == "D"
			
				aLinha[nI] := dtos(aLinha[nI])
				aLinha[nI] := subs(aLinha[nI],7,2) + "/" + subs(aLinha[nI],5,2) + "/" + LEFT(aLinha[nI],4) 
				
				ENDIF
			
			cLinErro += aLinha[nI] + ";"

			ELSE
			cLinErro += ";"
			ENDIF
		
		next nI
	nI:= 0
	
	cLinErro	+= cMsgErro	+CRLF

	nAux	:= FWrite(nHdlErro, cLinErro)
	ENDIF


Return()
