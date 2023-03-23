#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE "TBICONN.CH" 




/*-----------------------------------------------------------------
	ZC4_STATUS 
------------------------------------------------------------------*/
#DEFINE ZC4_STATUS_PENDENTE "1"
#DEFINE ZC4_STATUS_PARCIAL "2"
#DEFINE ZC4_STATUS_PROCESSADO "3"
#DEFINE ZC4_STATUS_DESCONSIDERADO "4"
#DEFINE ZC4_STATUS_FALHA "5"


/*-----------------------------------------------------------------
	Codigo da Adquirentes
------------------------------------------------------------------*/
#DEFINE ADQ_BIN  "001"
#DEFINE ADQ_CIELO  "002"
#DEFINE ADQ_GETNET  "003"
#DEFINE ADQ_REDE  "004"


#DEFINE NOME_SEMAFORO "CP11004"


/*------------------------------
	Diretorios BASE onde serao salvo os arquivos
-------------------------------*/
#DEFINE DIR_TEMP "\data_custom\cartoes\temp\"
#DEFINE DIR_IMPORTADO "\data_custom\cartoes\importado\"
#DEFINE DIR_DESCARTADO "\data_custom\cartoes\descartado\"


//| TABELA
#DEFINE D_ALIAS 'ZC4'
#DEFINE D_TITULO 'Painel de Arquivos - Extratos Eletronicos Adquirentes'
#DEFINE D_ROTINA 'CP11004'
#DEFINE D_MODEL 'ZC4MODEL'
#DEFINE D_MODELMASTER 'ZC4MASTER'
#DEFINE D_VIEWMASTER 'VIEW_ZC4'

/*/{Protheus.doc} ${CP11004}
Painel de Arquivos
@author Augusto Ribeiro | www.compila.com.br
@since 02/11/2013 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/  
User Function CP11004(aParam)
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(D_ALIAS)
oBrowse:SetDescription(D_TITULO)

oBrowse:AddLegend( "ZC4_STATUS=='1'", "BR_AMARELO"  , "Pendente"  )
oBrowse:AddLegend( "ZC4_STATUS=='2'", "BR_AZUL"  , "Proc. Parcial"  )
oBrowse:AddLegend( "ZC4_STATUS=='3'", "BR_VERDE"  , "Processado"  )
oBrowse:AddLegend( "ZC4_STATUS=='4'", "BR_CINZA"  , "Desconsiderado"  )
oBrowse:AddLegend( "ZC4_STATUS=='5'", "BR_VERMELHO"  , "Falha"  )

//oBrowse:AddLegend( "ZA0_TIPO=='I'", "BLUE"  , "Interprete"  )
//oBrowse:SetFilterDefault( "ZA0_TIPO=='C'" )
//oBrowse:SetFilterDefault( "Empty(ZA0_DTAFAL)" )
oBrowse:DisableDetails()

oBrowse:Activate()

Return NIL

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP11004  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Botoes do MBrowser                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Importar Arquivo'  ACTION 'Processa({|| U_CP114MNU("IMPORTA")}, "Importando Arquivos.")' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Processar'  ACTION ' U_CP114MNU("PROCESSA") ' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Obter Arquivo'  ACTION ' U_CP114MNU("ARQUIVO") ' OPERATION 3 ACCESS 0
//ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0
//ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
//ADD OPTION aRotina TITLE 'Reprocessar'   ACTION 'U_PCON04RP()' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CP11004' OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CP11004' OPERATION 9 ACCESS 0
Return aRotina




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP11004  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes do Model                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruct := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
//Local oStruZG7 := FWFormStruct( 1, 'ZG7', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New(D_MODEL, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( D_MODELMASTER, /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )  

// Adiciona ao modelo uma estrutura de formulário de edição por grid
//oModel:AddGrid( 'ZG7DETAIL', 'ZK7MASTER', oStruZG7, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
//oModel:SetRelation( 'ZG7DETAIL', { { 'ZG7_FILIAL', 'ZK7_FILIAL' }, { 'ZG7_CODIGO', 'ZK7_CODIGO' } }, 'ZG7_FILIAL + ZG7_CODIGO' )

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'ZG7DETAIL' ):SetUniqueLine( { 'ZG7_CHAVE' } )

// Indica que é opcional ter dados informados na Grid
//oModel:GetModel( 'ZG7DETAIL' ):SetOptional(.T.)


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( D_TITULO )

// Adiciona a descricao do Componente do Modelo de Dados
//oModel:GetModel( 'ZK7MASTER' ):SetDescription( 'Cadastro de função de representantes' )
//oModel:GetModel( 'ZG7DETAIL' ):SetDescription( 'Config. Sistemas Protheus Connector'  )

// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )

Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP11004  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes da View                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruct := FWFormStruct( 2, D_ALIAS )
//Local oStruZK7 := FWFormStruct( 2, 'ZK7', { |cCampo| COMP11STRU(cCampo) } )
Local oView   

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel

//oStruCSW:RemoveField( 'CSW_ENT' )

//oModel:SetPrimaryKey({"ZK7_CODIGO"})

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( D_VIEWMASTER, oStruct, D_MODELMASTER )
                                                     
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 100 )    

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( D_VIEWMASTER, 'SUPERIOR' )

oView:SetCloseOnOk({||.T.})

  

// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_ZG7', 'ZG7_ITEM' )


// Criar novo botao na barra de botoes no antigo Enchoice Bar
// oView:AddUserButton( 'Inclui Linha', 'CLIPS', { |oView| VldDados() } )

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_ZG7','UNIDADES')                    

// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZG7', "ENABLEDGRIDDETAIL", { 60 } )

Return oView




/*/{Protheus.doc} CP801MNU
Chamadas de Menu para Faturamento
@author Augusto Ribeiro | www.compila.com.br
@since 29/10/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/  
User Function CP114MNU(cAcao)
Local oView 		:= FWViewActive()
Local cMsgAviso		:= ""
Local nHSemafaro	:= 0
Local aRetAux, nQtdeArq
Local aRet			:= {.T.,""}
//Local lRet			:= .T.
Local cArq			:= "" 
Local aArqTXT		:= {}
Local cQuery
Local nCount		:= 0
Local aAreaZCA		:= ZCA->(GETAREA())
Local cPathTemp

IF cAcao == "IMPORTA"

	cMsgAviso	:= "Esta rotina realiza a importação de arquivo de EXTRATO ELETRONICO (TXT) das adquirentes"+CRLF
	cMsgAviso	+= "de cartoes (BIN, CIELO, GETNET e REDE)."+CRLF+CRLF
	cMsgAviso	+= "Selecione o arquivo ou pasta a ser importada."+CRLF
	cMsgAviso	+= "Ao selecionar uma pasta, todos os arquivos com extensão .txt serão importados."
	
	nOpcAviso	:= AVISO("Baixa Cartões", cMsgAviso,{"Imp. Arquivo", "Imp. Pasta", "Cancelar"},2)
	
	
	
	IF nOpcAviso == 1	                                                                                 
	
		cFile := cGetFile('Arquivo TXT|*.txt','Selecione arquivo',0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)
		IF !EMPTY(cFile)
			aArqTXT	:= {cFile}
		ENDIF
		
	ELSEIF nOpcAviso == 2
	
		cFile	 := ALLTRIM(cGetFile('Pasta','Selecione a pasta',0,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY,.T.)	)
	
		IF !EMPTY(cFile)	
			aArqDir := Directory(cFile+"*.txt")		
			FOR nI := 1 TO LEN(aArqDir)    

				aadd(aArqTXT,cFile + alltrim(aArqDir[nI,1]) ) 
			
			NEXT nI
		ENDIF	
	       
	ENDIF		
	
	
	

	if (nOpcAviso == 1 .or. nOpcAviso == 2)
		IF !EMPTY(aArqTXT)
			
			
			cLogProc	:= "Log Processamento"+CRLF
			
			nQtdeArq	:= len(aArqTXT)
			ProcRegua(nQtdeArq)
			For nI := 1 to nQtdeArq
				IncProc("Importando.. ["+alltrim(str(nI))+" de "+alltrim(str(nQtdeArq))+"]...")
				//Processa({|| aRetAux	:= U_CP114IMP(aArqTXT[nI]) }, "Processando "+aArqTXT[nI])
				
				aRetAux	:= U_CP114IMP(aArqTXT[nI])
				
				IF aRetAux[1]
					cLogProc	+= ALLTRIM(aArqTXT[nI])+ "| IMPORTADO COM SUCESSO "+CRLF
				ELSE
					cLogProc	+= ALLTRIM(aArqTXT[nI])+ "| FALHA: "+aRetAux[2]+CRLF
				ENDIF
			Next nI		
			
			AVISO("Log de Processamento",cLogProc,{"Fechar"},3, "",,,.T.)	
		ELSE 
			//Help(" ",1,"Arq. Conciliação",,"Nenhum arquivo selecionado.",4,5)
			aRet[2] := "Nenhum arquivo selecionado."
		ENDIF
	endif
	
		
	
	/*
	if
		cArq	:= U_CP801ARQ()
		
		IF !EMPTY(cArq)
			//aRetAux	:= U_CP114IMP(cArq)
			Processa({|| aRetAux	:= U_CP114IMP(cArq) }, "Processando... ")
			IF aRetAux[1]
				lRet	:= .T.
			ELSE
				Help(" ",1,"Arq. Conciliação",,aRetAux[2],4,5)
			ENDIF
		ELSE
			lRet	:= .F.
			Help(" ",1,"Arq. Conciliação",,"Nenhum arquivo selecionado.",4,5)
		ENDIF
	ENDIF
	*/
ELSEIF cAcao == "PROCESSA"

	cMsgAviso	:= "Esta rotina realiza processamento Extrato da Adquirente para Movimento Unificado"+CRLF
	cMsgAviso	+= "para posterior conciliação financeira"+CRLF+CRLF
	cMsgAviso	+= "Qual registro deseja processar ?"+CRLF+CRLF
	
	nOpcAviso	:= AVISO("Extrato Adquirente x Moviment Unificado", cMsgAviso,{"Posicionado","Todos", "Cancelar"},2)
			
	IF nOpcAviso == 1 .OR. nOpcAviso == 2
		
		Processa({|| aRetAux	:= ProcArq(nOpcAviso) }, "Processando... ")
		
		IF aRetAux[1]
			AVISO("Log de Processamento","Todos os registros foram processados com SUCESSO!",{"Fechar"},3, "",,,.T.)
		else
			AVISO("Log de Processamento","Alguns Registros não foram processados."+CRLF+aRetAux[2],{"Fechar"},3, "",,,.T.)
		ENDIF
		
		RESTAREA(aAreaZCA)
	ENDIF
	
	
ELSEIF cAcao == "ARQUIVO"


	cMsgAviso	:= "Esta rotina recupera o arquivo original recebido da adquirente"+CRLF
	cMsgAviso	+= "salvo no servidor, para a maquina do usuário."+CRLF+CRLF
	cMsgAviso	+= "Deseja Continuar ?"+CRLF+CRLF
	
	nOpcAviso	:= AVISO("Arquivo Original", cMsgAviso,{"Abrir Arq.", "Cancelar"},2)
		
		
	IF nOpcAviso == 1 
	
		IF !EMPTY(ZC4->ZC4_ARQUIV)
			
			cPathTemp	:= GetTempPath(.T.)+NomeArq(ZC4->ZC4_ARQUIV)			
			__CopyFile(ZC4->ZC4_ARQUIV, cPathTemp)
			
			IF FILE(cPathTemp)
				WinExec("Explorer "+cPathTemp)
			ELSE		
				FwHelpShow(,"Arquivo inválido","Arquivo não encontrado.","Verifique se o arquivo realmente encontra-se em ["+cPathTemp+"]")
			ENDIF			
		
		ELSE

			FwHelpShow("NAO ENCONTRADO","NAO ENCONTRADO","Arquivo não localizado","")
		ENDIF
	
	ENDIF 	
	
	
	
ENDIF


Return(aRet[1])







/*/{Protheus.doc} CP114IMP
Realiza a importacao do arquivos passado
@author Augusto Ribeiro | www.compila.com.br
@since 27/11/2016
@version 6
@param cFullOrig, Caminho completo do arquivo a ser importado.
@param lDelOrig, Exclui arquivo de origem (Default .F.) 
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP114IMP(cFullOrig, lDelOrig)
Local aRet	:= {.F., ""}
Local cNomeArq, cDirLixo, cFullOrig, cFullDest, cFullTemp
Local nFullDest, nFullTemp
Local nHSemafaro
Local nZC4ARQUIV	:= TAMSX3("ZC4_ARQUIV")[1]
Local nReg	:= 0
Local nHdlArq	:= 0
Local  cLinha
Local aLinha
Local cNameCpo, nPosAux, nI
Local nCpoZFA, nCpoZFB, nCpoZFC, nCpoZFD
Local lRegTconc := .F.
Local nCpoZC4	:= ZC4->(FCOUNT())

Default lDelOrig	:= .F.

IF !empty(cFullOrig)

	IF FILE(cFullOrig)
	
		/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
			Abre semaforo de Processamento
		------------------------------------------------------------------------------------------*/
		nHSemafaro	:= U_CPXSEMAF("A", NOME_SEMAFORO)
			
		IF nHSemafaro > 0
			
			RegToMemory("ZC4", .T., .F.)
		
			cNomeArq	:= NomeArq(cFullOrig) //| Retira somente nome do arquivo do caminho completo					 
			cNovoNome	:= NovoNome(M->ZC4_CODIGO, STRTRAN(TIME(),":",""), cNomeArq) //| Altera nome para padrao de armazenamento
			aRetAux		:= DirSave(DIR_TEMP) //| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
			
			IF aRetAux[1]
			
				cDirDest	:= aRetAux[3]
			
				cFullTemp	:= ALLTRIM(cDirDest+cNovoNome)
				nFullTemp := LEN(cFullTemp)
			
				//| Verifica se nome do arquivo nao ultrapassou o tamanho máximo
				IF nFullTemp <= nZC4ARQUIV
				
					//MSGRUN( "Copiando Arquivo "+cNomeArq, "Armazenando arq. Conciliação ", {|| __CopyFile(cFullOrig, cFullTemp) })
					__CopyFile(cFullOrig, cFullTemp)
					IF FILE(cFullTemp)
						
						BEGIN TRANSACTION 
						
						/*---------------------------------------------------------------
							Grava registro do painel de arquivos
						----------------------------------------------------------------*/
						DBSELECTAREA("ZC4")
						RecLock("ZC4", .T.)
						 
						 aDadosInc	:= {}
						 
						For nI := 1 To nCpoZC4
							cNameCpo	:= ALLTRIM(ZC4->(FIELDNAME(nI)))
							nPosAux	:= aScan(aDadosInc, { |x| AllTrim(x[1]) == cNameCpo })  
							IF nPosAux > 0
								FieldPut(nI, aDadosInc[nPosAux, 2])
							ELSE
								FieldPut(nI, M->&(cNameCpo) )
							ENDIF
						Next nI
						
						ZC4->(MsUnLock())		
						CONFIRMSX8()
						
						/*------------------------------------------------------ Augusto Ribeiro | 18/10/2017 - 3:13:44 PM
							Realiza a importacao da tabela conforme layout
						------------------------------------------------------------------------------------------*/
						aRetAux	:= U_CP11005(ZC4->ZC4_CODIGO,cFullTemp)						
						
					
						/*------------------------------------------------------ Augusto Ribeiro | 27/11/2016 - 3:59:35 PM
							Caso tenha incluido registro de arquivo,
							move arquivo para pasta importado e atualiza ZFA						
						------------------------------------------------------------------------------------------*/
						//IF EMPTY(ZFA->ZFA_ARQUIV)
						IF aRetAux[1]
							fClose(nHdlArq)
						
							/*------------------------------------------------------ Augusto Ribeiro | 18/10/2017 - 3:45:34 PM
								Complementa Registro do arquivo
							------------------------------------------------------------------------------------------*/
							DBSELECTAREA("ZC4")
							RecLock("ZC4", .F.)
							FOR nI := 1 to len(aRetAux[3])
								FieldPut(FieldPos(aRetAux[3,nI,1]),aRetAux[3,nI,2])
							NEXT nI
							ZC4->(MsUnLock())
							
							
							
							
							aRetAux	:= DirSave(DIR_IMPORTADO) //| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
							
							//aRetAux	:= DirSave(DIR_TEMP) //| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
							
							IF aRetAux[1]
							
								cDirDest	:= aRetAux[3]								
								cFullDest	:= ALLTRIM(cDirDest+cNovoNome)
								
							 	__CopyFile(cFullTemp, cFullDest)
								
								
								
								RECLOCK("ZC4",.F.)
									ZC4->ZC4_ARQUIV	:= cFullDest
								MSUNLOCK()									
								
								
								//| Apaga o carquio Temp |
								FErase(cFullTemp)
								
								/*------------------------------------------------------ Augusto Ribeiro | 28/11/2017 - 1:42:50 PM
									Excluir arquivo de Origem
								------------------------------------------------------------------------------------------*/
								IF lDelOrig
									FErase(cFullOrig)
								ENDIF
							
								aRet[1]	:= .T.
							ELSE
								aRet[2] := "Falha na copia do arquivo["+cFullDest+"]"
								DISARMTRANSACTION()
							ENDIF
						ELSE
							//aRet[2] := "Falha na importacao do arquivo[CP114IMP]. "+aRetAux[2]
							aRet[2] := "[CP114IMP] "+aRetAux[2]
							
							IF aRetAux[4] == "ARQINVALIDO" .OR.  aRetAux[4] == "JAEXISTE"
								FErase(cFullTemp)

								IF lDelOrig
									FErase(cFullOrig)
								ENDIF
							ELSEIF  aRetAux[4] == "TIPOARQ"
							
								/*------------------------------------
									Move arquivo para descartado
								-------------------------------------*/
								aRetAux	:= DirSave(DIR_DESCARTADO)
								IF aRetAux[1]
								
									cDirDest	:= aRetAux[3]								
									cFullDest	:= ALLTRIM(cDirDest+cNovoNome)
									
								 	__CopyFile(cFullTemp, cFullDest)
								 	
								 	
									FErase(cFullTemp)
	
									IF lDelOrig
										FErase(cFullOrig)
									ENDIF								
								ENDIF
							
							ENDIF
							
							DISARMTRANSACTION()
						ENDIF
						
						
						END TRANSACTION 
						
			
						IF nHdlArq > 0
							fClose(nHdlArq)
						ENDIF
									
						
					ELSE 
						aRet[2] := "Falha na copia do arquivo["+cFullOrig+"]"
					ENDIF
				ELSE
					cMaxNome	:= alltrim(str( (nZC4ARQUIV-LEN(cDirDest))-1 ))
				
					//FwHelpShow("Nome Arquivo Invalido",,"O nome do arquivo ultrapassa o limite de ["+cMaxNome+"] caracteres","Renomeie o arquivo antes de processeguir")
					aRet[2]	:= "O nome do arquivo ultrapassa o limite de ["+cMaxNome+"] caracteres."
				ENDIF

			ELSE
				aRet[2]	:= aRetAux[2]
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

	
Return (aRet)





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


/*/{Protheus.doc} ProcArq
Processa arquivos com status pendente / parcial
funcao criada para correto andamento do procregua
@author Augusto Ribeiro | www.compila.com.br
@since 24/10/2017
@version 6
@param nOpca, 1 = Posicionado, 2 = Todos
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ProcArq(nOpca)
Local aRet	:= {.F., ""}
Local cQuery
Local nCount	:= 0
Local cMsgErro	:= "LOG DE PROCESSAMENTO"+CRLF+CRLF
Local lAllOk	:= .F.

cQuery := " SELECT ZC4.ZC4_CODIGO, ZC4.R_E_C_N_O_ AS ZC4_RECNO "+CRLF
cQuery += " FROM "+RetSqlName("ZC4")+" ZC4 with(NOLOCK)  "+CRLF

IF nOpca == 1
	cQuery += " WHERE ZC4_CODIGO = '"+ZC4->ZC4_CODIGO+"' "+CRLF
ELSEIF nOpca == 2
	cQuery += " WHERE ZC4_STATUS IN ('1','2') "+CRLF
ENDIF

cQuery += " AND ZC4.D_E_L_E_T_ = '' "+CRLF


If Select("TZC4") > 0
	TZC4->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TZC4",.F., .T.)						

IF TZC4->(!EOF())

	TZC4->(DBGoTop())	
	TZC4->( dbEval( {|| nCount++ } ) )	
	TZC4->(DBGoTop())

	ProcRegua(nCount)
	
	DBSELECTAREA("ZC4")
	lAllOk	:= .T.
	WHILE TZC4->(!EOF())	
		
		IncProc("Normalizando dados... ["+TZC4->ZC4_CODIGO+"]...")
		
		
		aRetAux	:= U_CP114PRO(TZC4->ZC4_RECNO)
		
		IF aRetAux[1] == ZC4_STATUS_PROCESSADO
			cMsgErro += TZC4->ZC4_CODIGO+" - SUCESSO"+CRLF
		ELSE
			cMsgErro += TZC4->ZC4_CODIGO+" - "+aRetAux[2]+CRLF
			lAllOk	:= .F.
		ENDIF
		
		TZC4->(DBSKIP()) 
	ENDDO
ELSE
	aRet[2]	:= "Não existem registros a serem processados."
ENDIF

TZC4->(DbCloseArea())

IF lAllOk
	aRet[1]	:= .T.
ELSE
	aRet[2] := cMsgErro
ENDIF


Return(aRet)




/*/{Protheus.doc} CP114PRO
Processa arquivo normalizando e enviando para a ZAC (MOVIMENTO UNIFICADO)
@author Augusto Ribeiro | www.compila.com.br
@since 24/10/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP114PRO(nRecZC4)
Local aRet		:= {ZC4_STATUS_FALHA, ""}
Local cQuery	:= ""
Local nI
Local aRetAux	:= {ZC4_STATUS_FALHA,"Erro indeterminado"}
Local nHSemafaro	
Local cNomeSemaf	:= "CP114PRO_"

IF !EMPTY(nRecZC4)
	DBSELECTAREA("ZC4")
	ZC4->(DBGOTO(nRecZC4))
	

	/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
		Abre semaforo de Processamento
	------------------------------------------------------------------------------------------*/
	cNomeSemaf	:= cNomeSemaf+ZC4->ZC4_CODIGO
	nHSemafaro	:= U_CPXSEMAF("A", cNomeSemaf)	
	
	IF nHSemafaro > 0 
	
		IF ZC4->ZC4_CODADQ == ADQ_BIN
							
			//Processa({|| aRetAux	:= U_CP11BIN(ZC4->ZC4_CODIGO) }, "Processando... ")
			
			aRetAux	:= U_CP11BIN(ZC4->ZC4_CODIGO) 
			
		ELSEIF ZC4->ZC4_CODADQ == ADQ_CIELO
			
			//Processa({|| aRetAux	:= U_CP11CIEL(ZC4->ZC4_CODIGO) }, "Processando... ")
			aRetAux	:= U_CP11CIEL(ZC4->ZC4_CODIGO)
	
		ELSEIF ZC4->ZC4_CODADQ == ADQ_GETNET	
		
				aRetAux	:= U_CP11GETN(ZC4->ZC4_CODIGO) 
			
		ELSEIF ZC4->ZC4_CODADQ == ADQ_REDE
			aRetAux[2]	:= "Adquirente GETNET não implementada. "
		ENDIF
		
		/*------------------------------------
			Reposiciona por segurança
		-------------------------------------*/
		ZC4->(DBGOTO(nRecZC4))
		
		
		IF ZC4->ZC4_STATUS <> ZC4_STATUS_PROCESSADO .AND.;
			ZC4->ZC4_STATUS <> ZC4_STATUS_DESCONSIDERADO
			 
			RECLOCK("ZC4",.F.)			
				ZC4->ZC4_STATUS	:= aRetAux[1]
				ZC4->ZC4_LOG	:= aRetAux[2]
			MSUNLOCK()
		ENDIF
			
		aRet	:= aClone(aRetAux)
		
		/*--------------------------
		FECHA SEMAFORO
		---------------------------*/
		U_CPXSEMAF("F", cNomeSemaf,nHSemafaro)			
	ELSE
		aRet[2]	:= "Este registro já esta sendo processado por outro usuário - Semaforo ["+cNomeSemaf+"]"
	ENDIF
ELSE
	aRet[2]	:= "Registro nao localizado [CP114PRO]"
ENDIF	

	
Return(aRet)




/*/{Protheus.doc} CP114JOB
Job para importacao de registros
@author Augusto Ribeiro | www.compila.com.br
@since 08/11/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP114JOB(aParam)
Local _cEmp		//:= "99"
Local _cFilial	//:= "01"
Local nHSemaf	:= 0
Local cAbreFecha, cFSemaf, nI, nY 
Local aArqTXT	:= {}
Local cLogProc	:= ""
Local aPathEdi	:= {}
Local cDirAtu

Default aParam	:= {"01","00101MG0001"}

//aParam	:= {"99","01"} //| ### TESTE |

IF !empty(aParam)
	_cEmp		:= aParam[1]
	_cFilial	:= aParam[2]
	
	
	
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
	
	
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 28/11/2017 - 2:17:11 PM
		
		**** IMPORTAÇÃO DOS ARQUIVOS ****
		
	------------------------------------------------------------------------------------------*/
	
	
	aadd(aPathEdi, "\data_custom\cartoes\edi\bin\") 
	aadd(aPathEdi, "\data_custom\cartoes\edi\cielo\")
	aadd(aPathEdi, "\data_custom\cartoes\edi\getnet\") 
	//aadd(aPathEdi, "\data_custom\cartoes\edi\rede\")
	//aadd(aPathEdi, "\data_custom\cartoes\edi\global\")
	
	FOR nY := 1 to len(aPathEdi)
	
		aArqTXT	:= {}
		cFile	:= aPathEdi[nY]
		
		//| Posiciona no diretorio dos arquivos |
		cDirAtu	:= Curdir()
		Curdir(cFile)
	
		//cFile	 := ALLTRIM(cGetFile('Pasta','Selecione a pasta',0,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY,.T.)	)
		
		IF !EMPTY(cFile)	
			aArqDir := Directory("*.txt")		
			FOR nI := 1 TO LEN(aArqDir)    
		
				aadd(aArqTXT,cFile + alltrim(aArqDir[nI,1]) ) 
			
			NEXT nI
		ENDIF
		
		//| Restaura diretorio padrao|
		Curdir("\")
		Curdir(cDirAtu)	
		
		
		
		IF !EMPTY(aArqTXT)
		
			nQtdeArq	:= len(aArqTXT)
			ProcRegua(nQtdeArq)
			For nI := 1 to nQtdeArq
				IncProc("Importando.. ["+alltrim(str(nI))+" de "+alltrim(str(nQtdeArq))+"]...")
				//Processa({|| aRetAux	:= U_CP114IMP(aArqTXT[nI]) }, "Processando "+aArqTXT[nI])
				
				aRetAux	:= U_CP114IMP(aArqTXT[nI], .T.)
				
				IF aRetAux[1]
					cLogProc	+= ALLTRIM(aArqTXT[nI])+ "| IMPORTADO COM SUCESSO "+CRLF
				ELSE
					cLogProc	+= ALLTRIM(aArqTXT[nI])+ "| FALHA: "+aRetAux[2]+CRLF
				ENDIF
			Next nI			
		ELSE 
			//Help(" ",1,"Arq. Conciliação",,"Nenhum arquivo selecionado.",4,5)
			cLogProc	+=  "Nenhum arquivo selecionado ["+ALLTRIM(cFile)+"]."+CRLF
		ENDIF	
	
	NEXT nY
	
	
	
	//IF !EMPTY(cLogProc)
		//CONOUT("### CP114JOB ARQUIVOS", cLogProc)
	//ENDIF
	cLogProc	:= ""
	
	/*------------------------------------------------------ Augusto Ribeiro | 28/11/2017 - 2:17:11 PM
		
		**** NORMALIZAÇÃO DOS DADOS ****
		
	------------------------------------------------------------------------------------------*/
	aRetAux	:= ProcArq(2)
	IF aRetAux[1]
		cLogProc	:= "Normalização dos dados realizada com SUCESSO!"
	ELSE
		cLogProc	:= "FALHA na Normalização dos dados: "+aRetAux[2]
	ENDIF
	
	//IF !EMPTY(cLogProc)
		//CONOUT("### CP114JOB NORMALIZACAO", cLogProc)
	//ENDIF
	cLogProc	:= ""
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 28/11/2017 - 2:17:11 PM
		
		**** BAIXA AUTOMÁTICA ****
		
	------------------------------------------------------------------------------------------*/
	lReproc		:= .T.
	cStatus		:= ""
	cCodBand 	:= ""
	cCodAdq 	:= ""
	dDtVdIni 	:= CTOD("  /  /  ") 
	dDtVdFim 	:= dDataBase
	dDtPgIni 	:= dDataBase-60
	dPgFim	 	:= dDataBase 
	
		
	aRetAux	:= U_CP11BXAT(lReproc, cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim)
	IF aRetAux[1]
		cLogProc	:= "Baixa automática realizada com SUCESSO!"
	ELSE
		cLogProc	:= "FALHA na Baixa Automática: "+aRetAux[2]
	ENDIF
	
	//IF !EMPTY(cLogProc)
		//CONOUT("### CP114JOB BAIXA AUTOMATICA LOG", cLogProc)
	//ENDIF
	cLogProc	:= ""
	
	RESET ENVIRONMENT
ELSE
	//CONOUT("### CP114JOB: Parametros inválidos")
ENDIF

Return()


