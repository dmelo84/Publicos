#Include "Protheus.Ch"
#INCLUDE "TOPCONN.CH"  
#INCLUDE 'TBICONN.CH'
#INCLUDE "fileio.ch"


#DEFINE NOME_SEMAFORO "AFIN002"
#DEFINE DIR_PENDENTE "\data_custom\cnab\pendente\"
#DEFINE DIR_PROCESSADO "\data_custom\cnab\processado\"
#DEFINE DIR_FALHA "\data_custom\cnab\falha\"


/*/{Protheus.doc} FIN02JOB
Executa JOB para processamento dos arquivos de DDA movendo-os para pasta correta.
@author Augusto Ribeiro | www.compila.com.br
@since 11/06/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function FIN02JOB(aParam)
Local _cEmp		//:= "99"
Local _cFilial	//:= "01"

Default aParam	:= {"01","00101MG0001"}



//CONOUT("### FIN02JOB: INICIO "+DTOC(DATE())+" "+TIME())

IF !empty(aParam)
	_cEmp		:= aParam[1]
	_cFilial	:= aParam[2]
	
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
	
	
	//aRetAux	:= U_FIN02IMP("E:\ALLIAR_DDA\VS12048A.RET")
	//aRetAux	:= U_FIN02IMP("\data_custom\cnab\pendente\VS12048A.RET")
	aRetAux	:= u_FIN02DIR(DIR_PENDENTE)
	
	
	RESET ENVIRONMENT
ELSE
	//CONOUT("### FIN02JOB: Parametros inválidos")
ENDIF

//CONOUT("### FIN02JOB: FIM "+DTOC(DATE())+" "+TIME())
	
	
	
Return()


/*/{Protheus.doc} FIN02DIR
Importa todos os arquivos do diretorio
@author Augusto Ribeiro | www.compila.com.br
@since 12/06/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function FIN02DIR(cFile)
Local aArqTXT	:= {}
Local nQtdeArq, cFile, aRetAux, cLogProc
Local aRet		:= {.f.,""}
Local aArqDir	:= {}

IF !EMPTY(cFile)	
	aArqDir := Directory(cFile+"*.ret")		
	FOR nI := 1 TO LEN(aArqDir)    

		aadd(aArqTXT,cFile + alltrim(aArqDir[nI,1]) ) 
	
	NEXT nI
ENDIF	
       
IF !EMPTY(aArqTXT)
		
		
	cLogProc	:= "Log Processamento"+CRLF
	
	nQtdeArq	:= len(aArqTXT)
	ProcRegua(nQtdeArq)
	For nI := 1 to nQtdeArq
		IncProc("Importando.. ["+alltrim(str(nI))+" de "+alltrim(str(nQtdeArq))+"]...")
		//Processa({|| aRetAux	:= U_CP114IMP(aArqTXT[nI]) }, "Processando "+aArqTXT[nI])
		
		aRetAux	:= U_FIN02IMP(aArqTXT[nI])
		
		IF aRetAux[1]
			cLogProc	+= ALLTRIM(aArqTXT[nI])+ "| IMPORTADO COM SUCESSO "+CRLF
		ELSE
			cLogProc	+= ALLTRIM(aArqTXT[nI])+ "| FALHA: "+aRetAux[2]+CRLF
		ENDIF
	Next nI		
	
	//CONOUT(cLogProc)
	//AVISO("Log de Processamento",cLogProc,{"Fechar"},3, "",,,.T.)	
ELSE 
	//Help(" ",1,"Arq. Conciliação",,"Nenhum arquivo selecionado.",4,5)
	aRet[2] := "Nenhum arquivo selecionado."
ENDIF

Return(.t.)





/*/{Protheus.doc} FIN02IMP
importa arquivo de DDA 
@author Augusto Ribeiro | www.compila.com.br
@since 11/06/2018
@version version
@param param
@return aRet, {lRet, cMsgErro}
@example
(examples)
@see (links_or_references)
/*/
User Function FIN02IMP(cFullOrig)
Local aRet		:= {.F., ""}
Local cQuery	:= ""

Local cPerg		:= "AFI430"
Local cLinha	:= ""
Local cEmpDDA	:= ""
Local cFilDDA	:= ""
Local _cCodEmp, _cCodFil, _cFilNew
Local cPathTemp
Local cFullProc	
Local cFullOrig
Local lMovFalha	:= .F.

Private aFa205R		:= {}
PRIVATE cCadastro := OemToAnsi( "Retorno CNAB Pagar" )  //"Retorno CNAB Pagar"
Private aTit  
Private cTipoBx  := ""
Private nVlrCnab := 0
Private lMVCNBImpg := GetNewPar("MV_CNBIMPG",.F.)
Private aMsgSch := {}

// Retorno Automatico via Job
// parametro que controla execucao via Job utilizado para pontos de entrada que nao tem como passar o parametro
Private lExecJob := ExecSchedule()



IF !empty(cFullOrig)

	IF FILE(cFullOrig)
	
		/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
			Abre semaforo de Processamento
		------------------------------------------------------------------------------------------*/
		nHSemafaro	:= U_CPXSEMAF("A", NOME_SEMAFORO)
			
		IF nHSemafaro > 0
			
			
			/*------------------------------------------------------ Augusto Ribeiro 
				Identifica a que filial pertence o arquivo
			------------------------------------------------------------------------------------------*/
			//| Abre o arquivo.
			FT_FUSE(cFullOrig)
			FT_FGOTOP()
			cLinha	:= FT_FREADLN() //| Obtém a linha corrente do Arquivo.
			cCnpjFil	:= SUBSTR(cLinha,19,14)
			//| Fecha arquivo aberto|
			FT_FUSE()
	
			IF !EMPTY(cCnpjFil)
			
				DBSELECTAREA("SZK")
				SZK->(DBSETORDER(2)) //| 
				IF SZK->(DBSEEK(cCnpjFil)) 
					
					cEmpDDA	:= SZK->ZK_CODIGO
					cFilDDA	:= SZK->ZK_CODFIL
						
				ENDIF
				
			ENDIF
			
			IF !EMPTY(cEmpDDA) .AND. !EMPTY(cFilDDA)
			
				/*---------------------------------------
					Realiza a TROCA DA FILIAL CORRENTE 
				-----------------------------------------*/
				_cCodEmp 	:= SM0->M0_CODIGO
				_cCodFil	:= SM0->M0_CODFIL
				_cFilNew	:= cFilDDA //| CODIGO DA FILIAL DE DESTINO 
				
				IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
					CFILANT := _cFilNew
					opensm0(_cCodEmp+CFILANT)
				ENDIF
				
				
				
				/*************************************************************
				 Verifica as perguntas selecionadas                 
				                                                    
				 Parametros                                         
				                                                    
				 MV_PAR01: Mostra Lanc. Contab  ? Sim Nao           
				 MV_PAR02: Aglutina Lanc. Contab? Sim Nao           
				 MV_PAR03: Arquivo de Entrada   ?                   
				 MV_PAR04: Arquivo de Config    ?                   
				 MV_PAR05: Banco                ?                   
				 MV_PAR06: Agencia              ?                   
				 MV_PAR07: Conta                ?                   
				 MV_PAR08: SubConta             ?                   
				 MV_PAR09: Contabiliza          ?                   
				 MV_PAR10: Padrao Cnab          ? Modelo1 Modelo 2  
				 MV_PAR11: Processa filiais     ? Modelo1 Modelo 2  
				 MV_PAR12: Considera Multiplas Nat. ?  Sim Nao      
				
				*************************************************************/
				
				A460FSA2()	//Aplica Filtro na tabela de Fornecedores (SA2)
				
				lPergunte := Pergunte(cPerg,.F.,Nil,Nil,Nil,.F.)  // carrega as perguntas que foram atualizadas pelo FINA435
				//	lPergunte := .T.
				
				//	If lPergunte
				//	alert(_cArqDDa)
				
				MV_PAR01	:= 2
				MV_PAR02    := 2
				MV_PAR03    := UPPER(cFullOrig)
				MV_PAR04    := "dda.2pr"
				/*------------------------------------------------------ 
					IMPORTANTE: Para processamento da Varredura DDA, pode ser utilizada qualquer
					banco agencia e conta da filial pois na FIG não e alimentado o banco no padrao
				------------------------------------------------------------------------------------------*/
				MV_PAR05    := GetMv("AL_BCODDA",.T.,"")
				MV_PAR06    := PADR(ALLTRIM(GetMv("AL_AGENDDA",.T.,"")),TAMSX3("A6_AGENCIA")[1])
				MV_PAR07    := PADR(ALLTRIM(GetMv("AL_CTADDA",.T.,"")),TAMSX3("A6_NUMCON")[1])
				MV_PAR08    := "002"
				MV_PAR09    := 2
				MV_PAR10    := 2
				MV_PAR11    := 2
				MV_PAR12    := 2
				
				IF !EMPTY(MV_PAR05) .AND. !EMPTY(MV_PAR06) .AND. !EMPTY(MV_PAR07)
					
	
					dbSelectArea("SE2")
					dbSetOrder(1)
					
					ProcLogAtu("INICIO")
					fa430gera("SE2")
					
					
					ProcLogAtu("FIM")
					
					dbSelectArea("SE2")
					dbSetOrder(1)
					
					/*---------------------------------------
						Restaura FILIAL  
					-----------------------------------------*/
					IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
						CFILANT := _cCodFil
						opensm0(_cCodEmp+CFILANT)			 			
					ENDIF   			
	
					aRetAux		:= DirSave(DIR_PROCESSADO) 
					IF aRetAux[1]
					
						cNomeArq	:= NomeArq(cFullOrig) //| Retira somente nome do arquivo do caminho completo					 
						cNovoNome	:= NovoNome(DTOS(DDATABASE), STRTRAN(TIME(),":",""), cNomeArq) //| Altera nome para padrao de armazenamento				
					
						cDirDest	:= aRetAux[3]
						cFullProc	:= ALLTRIM(cDirDest+cNovoNome)
						
						/*------------------------------------------------------ 
							Move arquivo para a pasta processados.
						------------------------------------------------------------------------------------------*/
						__CopyFile(cFullOrig, cFullProc)
						IF FILE(cFullProc)
							FErase(cFullOrig)
							aRet[1]	:= .T.	
						ELSE						
							//| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
							aRet[2]	:= "Falha na copia do arquivo para pasta processados "
						ENDIF
					ENDIF
				ELSE
					lMovFalha	:= .T.
					aRet[2]	:= "Banco vazio. verifique os parametros AL_BCODDA, AL_AGENDDA, AL_CTADDA"
				ENDIF
			ELSE
				lMovFalha	:= .T.
				aRet[2]	:= "Empresa e Filial nao localizada [cnpj "+cCnpjFil+"]"
			ENDIF
				
			/*--------------------------
			FECHA SEMAFORO
			---------------------------*/
			U_CPXSEMAF("F", NOME_SEMAFORO,nHSemafaro)			
		ELSE	
			aRet[2]	:= "Não foi possivel abrir o semaforo["+NOME_SEMAFORO+"]"
		ENDIF			
	ELSE
		aRet[2]	:= "Arquivo não encontrado ["+cFullOrig+"]"
	ENDIF

ELSE
	aRet[2]	:= "Nenhum arquivo foi informado."
ENDIF
	
	
/*------------------------------------------------------ 
	Move arquivo para a pasta processados.
------------------------------------------------------------------------------------------*/
IF lMovFalha
	cNomeArq	:= NomeArq(cFullOrig) //| Retira somente nome do arquivo do caminho completo	
	cFullFalha	:= ALLTRIM(DIR_FALHA+cNomeArq)
	
	/*------------------------------------------------------ 
		Move arquivo para a pasta falha.
	------------------------------------------------------------------------------------------*/
	__CopyFile(cFullOrig, cFullFalha)
	IF FILE(cFullFalha)
		FErase(cFullOrig)
	ENDIF	
ENDIF

Return(aRet)




/*/{Protheus.doc} ExecSchedule
Retorna se o programa esta sendo executado via schedule
@author Aldo Barbosa dos Santos  
@since 21/12/10
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function ExecSchedule()
	Local lRetorno := .T.

	lRetorno := IsBlind()

Return( lRetorno )


/*/
{Protheus.doc} A460FSA2
Aplicar Filtro na Tabela de Fornecedores (Campo reservado A2_MSBLQL)

@author norbertom
@since 02/02/2016
@version 1.0
@param nil
@return nil
/*/
Static Function A460FSA2()
	Local cFilter  := SA2->(dbFilter())
	Local cFilBlq  := " !SA2->A2_MSBLQL == '1' "
	Local aGetArea := GETAREA()

	dbSelectArea("SA2")
	If SA2->(FieldPos("A2_MSBLQL")) > 0
		If !'A2_MSBLQL' $ cFilter
			If !Empty(cFilter)
				cFilter += " .AND. "
			EndIf
			cFilter += cFilBlq
			SA2->(dbSetFilter({||&cFilter},cFilter))
		EndIf
	EndIf

	RESTAREA(aGetArea)
Return nil




/*/{Protheus.doc} DirSave
Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
@author Augusto Ribeiro | www.compila.com.br
@since 14/01/2015
@version 1.0
@param ${dDataRef}, ${D}, ${Data de referencia - Utilizado para criar o diretorio onde ser armazenado o arquivo}
@return aRet,  {.F., cMsgErro, cPaths}
/*/
Static Function DirSave(cPath)
Local aRet			:= {.F., "", ""}
Local cAnoMes, cDirComp, cCurDir, nAux
Local aPath, nI
Local cNewPath, aNewPath


/*
#DEFINE DIR_TEMP "\data_braspag\temp\"
#DEFINE DIR_IMPORTADO "\data_braspag\importado\"
*/

IF !EMPTY(cPath)

	cNewPath	:= ALLTRIM(cPath)+LEFT(DTOS(DDATABASE),6)
	
	
	cCurDir	:= CurDir()
	CurDir("\")
	/*------------------------------------------------------ Augusto Ribeiro | 27/11/2016 - 12:42:46 PM
		Verifica se o caminho existe, caso não, cria as patas
	------------------------------------------------------------------------------------------*/
	IF !ExistDir(cNewPath)
	
		aNewPath	:= StrTokArr(cNewPath, "\" )
		
		FOR nI := 1 to len(aNewPath)
		
			IF ExistDir(aNewPath[nI])
				CurDir(aNewPath[nI])
			ELSE
				nAux	:= MakeDir(aNewPath[nI])
				IF nAux == 0
					CurDir(aNewPath[nI])
				ELSE
					aRet[2] := "Nao foi possivel criar o diretorio ["+CurDir()+"\"+aNewPath[nI]+"]. Cod. Erro: "+alltrim(str(FError()))
					//CONOUT("### AFIN002.PRW [DirSave] | "+aRet[2] )
					EXIT
				ENDIF			
			ENDIF
		
		NEXT nI	
	
	ENDIF
	
	
	IF ExistDir(cNewPath)
		aRet[1]	:= .t.
		aRet[3]	:= cNewPath+"\"
	ELSE
		aRet[2] := "Não foi possivel localiar o diretorio ["+cNewPath+"]"
	ENDIF

	CurDir(cCurDir) 	
ENDIF


Return(aRet)




/*/{Protheus.doc} NomeArq
Retorna nome do arquivo com a extensão
@author Augusto Ribeiro | www.compila.com.br
@since 09/01/2015
@version 1.0
@param ${cFullPath}, ${c}, ${Caminho completo do arquivo}
@return ${cRet}, ${Nome do Arquivo sem extensão }
/*/
Static Function NomeArq(cFullPath)
Local cRet	:= ""
Local nPosBar

cFullPath	:= ALLTRIM(cFullPath)
nPosBar	:= rat("\",cFullPath)

IF nPosBar > 0
	cRet := SUBSTR(cFullPath, nPosBar+1, LEN(cFullPath)-nPosBar )
ENDIF

Return(cRet)





/*/{Protheus.doc} NovoNome
Altera nome do arquivo para seguir padrao para cada item.
@author Augusto Ribeiro | www.compila.com.br
@since 12/01/2015
@version 1.0
@param ${cCodigo}, ${c}, ${Codigo do reembolso de despesa}
@param ${cItem}, ${c}, ${Item do reembolso de despesa}
@param ${cArquivo}, ${c}, ${Nome do arquivo do reembolso}
@return ${cRet}, ${Novo nome do arquivo seguindo padrao de armazenamento}
/*/
Static Function NOVONOME(cCodigo, cItem, cArquivo)
Local cRet	:= ""

IF !EMPTY(cCodigo) .AND. !EMPTY(cItem) .AND. !EMPTY(cArquivo)
	cRet	:= LOWER(cCodigo+"_"+cItem+"_"+STRTRAN(cArquivo," ","_"))
ENDIF


Return(cRet)


