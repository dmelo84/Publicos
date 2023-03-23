#Include "Protheus.Ch"
//#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE 'TBICONN.CH'
#INCLUDE "fileio.ch"

/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclusão;
MODEL_OPERATION_UPDATE para alteração;
MODEL_OPERATION_DELETE para exclusão.
MODEL_OPERATION_VIEW para visualizacao.
*/


#DEFINE NOME_SEMAFORO "CP09001"

/*------------------------------
	Diretorios BASE onde serao salvo os arquivos
-------------------------------*/
#DEFINE DIR_RAIZ "\data_custom\ofx\"
#DEFINE DIR_TEMP "\data_custom\ofx\temp\"
#DEFINE DIR_IMPORTADO "\data_custom\ofx\importado\"
#DEFINE DIR_DESCARTADO "\data_custom\ofx\descartado\"


#DEFINE D_TITULO 'Arq. Extrato Bancario'
#DEFINE D_ROTINA 'CP09001' 


/*/{Protheus.doc} CP09001
Conciliador Bancário
@author Augusto Ribeiro | www.compila.com.br
@since 31/03/2016
@version 6
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User function CP09001() 
//Local oBrowse  
Local cQuery 		:= ""
Private lGeraLote	:= .F.
Private lManut		:= .F.
Private lExclui		:= .F.

Private c_CODCLI		:= ""
Private c_LOJACLI		:= ""

Private _LCOPIA		:= .F.
Private aUserAccess := {}  
Private lTeste


oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ZB1')                         
//oBrowse:SetMenuDef( "ATEC204" )                   // Define de onde virao os botoes deste browse
oBrowse:SetDescription(D_TITULO)


/*
oBrowse:AddLegend( "ZB1->ZB1_STATUS == '1'", "BR_BRANCO", "Pendente" )
oBrowse:AddLegend( "ZB1->ZB1_STATUS == '2'", "BR_AMARELO", "Conciliação Parcial" )
oBrowse:AddLegend( "ZB1->ZB1_STATUS == '3'", "BR_VERDE", "Conciliação Total" )
oBrowse:AddLegend( "ZB1->ZB1_STATUS == '4'", "BR_PRETO", "Desconsiderado" )
 
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC00'", "BR_BRANCO", "Não Atribuído" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC01'", "BR_AMARELO", "Pendente CEF" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC02'", "BR_PRETO", "Compras" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC03'", "BR_MARROM", "Quarterizado" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC04'", "BR_PINK", "Orçamento" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC05'", "BR_CINZA", "Em Execução" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC06'", "BR_LARANJA", "A Agendar" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC07'", "BR_AZUL", "Agendado" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC08'", "BR_VERMELHO", "Pendente PSAA" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC09'", "BR_VERDE_ESCURO", "Fechado Sem Homologação" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC10'", "BR_VERDE", "Fechado Com Homologação" )
*/


//oBrowse:DisableDetails()
	
oBrowse:Activate()

Return NIL

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP09001  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Botoes do MBrowser                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function MenuDef()
Local aRotina := {}


ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
//ADD OPTION aRotina TITLE 'Incluir'  ACTION 'VIE7DEF.'+D_ROTINA OPERATION 3 ACCESS 0  	
ADD OPTION aRotina TITLE 'Importar Arquivo'  ACTION 'U_CP901MNU("IMPORTA")' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Abrir Arq. Extrato'  ACTION 'U_CP901MNU("ABRIR_OFX")' OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0
//ADD OPTION aRotina TITLE 'TESTE'     ACTION 'U_FAT01TST()' OPERATION 9 ACCESS 0

Return aRotina







/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP09001  ºAutor  ³Augusto Ribeiro     º Data ³ 19/11/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes do Model                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZB1 := FWFormStruct( 1, 'ZB1', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZB2 := FWFormStruct( 1, 'ZB2', /*bAvalCampo*/,/*lViewUsado*/ )

Local oModel   


// Cria o objeto do Mod elo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL', /*bPreValidacao*/,   /*bPosValidacao*/,  /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('ATEC204MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZB1ARQUIVO', /*cOwner*/, oStruZB1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'ZB2EXTRATO', 'ZB1ARQUIVO', oStruZB2,  /*LINPRE*/, /*LINPOS*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


// Faz relaciomaneto entre os compomentes do model                                                                           
oModel:SetRelation( 'ZB2EXTRATO',		{{ 'ZB2_FILIAL', 'XFILIAL("ZB2")' }, { 'ZB2_CODARQ', 'ZB1_CODIGO' } }, ZB2->(IndexKey(3)) ) //| ZB2_FILIAL+ZB2_CODARQ+ZB2_CODIGO 
 


// Indica que é opcional ter dados informados na Grid
 //oModel:GetModel( 'ZB1ARQUIVO' ):SetOptional(.T.) //| Removido Serviços Executados - Sol. Adriano
 //oModel:GetModel( 'ZB2EXTRATO' ):SetOptional(.T.) //| Removido Serviços Executados - Sol. Adriano
  

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(D_TITULO)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZB1ARQUIVO' ):SetDescription( 'Arquivo' )
oModel:GetModel( 'ZB2EXTRATO' ):SetDescription( 'Extrato' )      


/// oModel:GetModel( 'ZA6SERV' ):SetDescription( 'Serviços' ) //| Removido Serviços Executados - Sol. Adriano
      
// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel,cAcao| U_FAT01VLD('MODEL_ACTIVE', oModel) } )

Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP09001  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes da View                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruZB1 := FWFormStruct( 2, 'ZB1' )
Local oStruZB2 := FWFormStruct( 2, 'ZB2' )
Local oView   

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel
                                   

//oStruCSW:RemoveField( 'CSW_ENT' )
                        
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField( 'VIEW_ZB1', oStruZB1, 'ZB1ARQUIVO' )
oView:AddGrid( 'VIEW_ZB2', oStruZB2, 'ZB2EXTRATO' )
				

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 30 )
oView:CreateHorizontalBox( 'INFERIOR'	, 70) 	  



// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZB1', 'SUPERIOR')
oView:SetOwnerView( 'VIEW_ZB2', 'INFERIOR')


// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_ZEH', 'ZEH_CODITE' )

//oView:AddOtherObject("ABAIXO_CAL", {|oPanel| U_FAT01BCAL(oPanel)})
//oView:SetOwnerView("ABAIXO_CAL",'RIGHT_SUP2')



// Criar novo botao na barra de botoes no antigo Enchoice Bar            
//oView:AddUserButton( 'Imprimir', 'IMPRESSAO', { |oView| U_RTEC001(oView,.T.) } )
//oView:AddUserButton( 'Gera calendario', 'CALENDARIO', { |oView| ALTER("TESTE") } )

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_ZEG','Lote de Faturamento')
//oView:EnableTitleView('VIEW_ZEH','Itens do Lote')
oView:EnableTitleView('VIEW_ZB1')
oView:EnableTitleView('VIEW_ZB2')
	
	
	// Liga a Edição de Campos na FormGrid
	//oView:SetViewProperty( 'VIEW_ZA5'		, "ENABLEDGRIDDETAIL", { 60 } )   


//oView:SetFieldAction(  'ZEG_DTINI',  {  |oView,  cIDView,  cField,  xValue| FAction(  oView,  cIDView, cField, xValue ) } )

//oView:SetCloseOnOk({||.T.})
  
Return oView




/*/{Protheus.doc} CP901CPO
Validacao de usuários
@author Augusto Ribeiro | www.compila.com.br
@since 28/10/16
@version version
@param cCampo C, Nome do Campo
@param cTipo, C,  V = Validacao, W = When 
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/  
User Function CP901CPO(cCampo, cTipo)
Local lRet := .T.
Local nPosCpo, nI
Local oModel := FWModelActive()
Local nOperation := oModel:GetOperation()
Local aAreaZEG := {}

Local oModeZEG, cCodRot

Default cCampo		:= ''
Default cTipo		:= "V"

cCampo := alltrim(cCampo)

/*-------------------
  VALIDACAO
--------------------*/
IF cTipo == "V"


	
/*-------------------
 MODO DE EDICAO - WHEN
--------------------*/
ELSEIF cTipo == "W"

ENDIF


Return(lRet)






          
/*/{Protheus.doc} CP901MNU
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
User Function CP901MNU(cAcao)
Local aRet			:= {.F., ""}
Local cLogProc		:= ""
Local oView 		:= FWViewActive()
Local cMsgAviso		:= ""
Local nHSemafaro	:= 0
Local aRetAux, nI, cNomeArq
Local lRet			:= .T.
Local cArq			:= "" 
Local nOpcAviso		:= 0
Local aArqOFX		:= {}
Local cTemp			:= ""
Local cMsgParam		:= ""

IF cAcao == "IMPORTA"

	IF GETMV("CP9_NAODIA",.F., .T.)
		cMsgParam	:= CRLF+CRLF+"ATENÇÃO: Caso OFX contenha lançamentos do dia "+dtoc(dDataBase)+", estes registros serão desconsiderados [SX6: CP9_NAODIA = .T.]"
	ENDIF


	nOpcAviso	:= Aviso("Importa Extrato OFX / CNAB 240"," Selecione o arquivo ou pasta a ser importada."+CRLF+;
 											"Ao selecionar uma pasta, todos os arquivos com extensão .ofx ou .ret serão importados."+cMsgParam,{"Imp. Arquivo", "Imp. Pasta", "Cancelar"},2)
	
		
	
	IF nOpcAviso == 1	                                                                                 
	
		cFile := cGetFile('Extrato OFX|*.ofx|Extrato 240|*.ret','Selecione arquivo',0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)
		IF !EMPTY(cFile)
			aArqOFX	:= {cFile}
		ENDIF
		
	ELSEIF nOpcAviso == 2
	
		cFile	 := ALLTRIM(cGetFile('Pasta','Selecione a pasta',0,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY,.T.)	)
	
		IF !EMPTY(cFile)	
			aArqDir := Directory(cFile+"*.ofx")		
			FOR nI := 1 TO LEN(aArqDir)    

				aadd(aArqOFX,cFile + alltrim(aArqDir[nI,1]) ) 
			
			NEXT nI
			aArqDir := Directory(cFile+"*.ret")		
			FOR nI := 1 TO LEN(aArqDir)    

				aadd(aArqOFX,cFile + alltrim(aArqDir[nI,1]) ) 
			
			NEXT nI			
		ENDIF	
	       
	ENDIF		



	IF !EMPTY(aArqOFX)
		
		
		cLogProc	:= "Log Processamento"+CRLF
		
		For nI := 1 to len(aArqOFX)
		
			Processa({|| aRetAux	:= U_CP901IMP(aArqOFX[nI]) }, "Processando "+aArqOFX[nI])
			IF aRetAux[1]
				cLogProc	+= ALLTRIM(aArqOFX[nI])+ "| IMPORTADO COM SUCESSO "+CRLF
			ELSE
				cLogProc	+= ALLTRIM(aArqOFX[nI])+ "| FALHA: "+aRetAux[2]+CRLF
			ENDIF
		Next nI
	
	ELSE 
		//Help(" ",1,"Arq. Conciliação",,"Nenhum arquivo selecionado.",4,5)
		aRet[2] := "Nenhum arquivo selecionado."
	ENDIF


	/*
	cMsgAviso	:= "Esta rotina realiza a importação arquivo de conciliação bancaria (OFX)."+CRLF+CRLF
	cMsgAviso	+= "DESEJA CONTINUAR ?"
	
	IF AVISO("Conciliação Bancaria OFX", cMsgAviso, {"NÃO", "SIM"},2) == 2
		cArq	:= U_CP901ARQ()
		
		IF !EMPTY(cArq)
			//aRetAux	:= U_CP901IMP(cArq)
			Processa({|| aRetAux	:= U_CP901IMP(cArq) }, "Processando... ")
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
	
	
	IF EMPTY(aRet[2])
		aRet[1]	:= .T.
		Aviso("Log de Processamento",cLogProc,{"Fechar"},3, "",,,.T.)
	ELSE
		Help(" ",1,"Arq. Conciliação",,aRet[2],4,5)			
	ENDIF
	
ELSEIF cAcao == 'ABRIR_OFX'

	cTemp		:= GetTempPath(.T.)
	
	cNomeArq	:= NomeArq(alltrim(ZB1->ZB1_ARQUIV))
	
	MSGRUN( "Copiando Arquivo "+cNomeArq, "Copiando arquivo para visualização", {|| __CopyFile(ZB1->ZB1_ARQUIVO, cTemp+cNomeArq)})
	
	
	
	//| Abre Arquivo OFX|
	WinExec('explorer.exe '+cTemp+cNomeArq,2)
	
ENDIF

Return(lRet)





/*/{Protheus.doc} CP901IMP
Realiza a importacao do arquivos passado
@author Augusto Ribeiro | www.compila.com.br
@since 27/11/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP901IMP(cFullOrig,lDelOrig)
Local aRet	:= {.F., ""}
Local cNomeArq, cDirLixo, cFullOrig, cFullDest, cFullTemp
Local nFullDest, nFullTemp
Local nHSemafaro
Local nZB1ARQUIVO	:= TAMSX3("ZB1_ARQUIVO")[1]
Local nReg		:= 0
Local nDescon	:= 0
Local nHdlArq, cLinha
Local aLinha
Local cNameCpo, nPosAux, nI
Local nCpoZB1, nCpoZB2
Local nTotImp	:= 0
Local lNaoImp	:= GETMV("CP9_NAODIA",.F., .T.) //| Parametro que define se lançamentos do mesmo data base serao importados|
Local cACCTID, cBanco, cAgencia, cConta, dDtIni, dDtFim

Default lDelOrig	:= .F.


IF !empty(cFullOrig)

	cFullOrig	:= lower(cFullOrig)
	IF FILE(cFullOrig)
	
		/*--------------------------
			ABRE SEMAFORO
		---------------------------*/
		nHSemafaro	:= U_CPXSEMAF("A", NOME_SEMAFORO)			
		IF nHSemafaro > 0
			
			RegToMemory("ZB1", .T., .F.)
		
			cNomeArq	:= ALLTRIM(NomeArq(cFullOrig)) //| Retira somente nome do arquivo do caminho completo					 
			cNovoNome	:= NovoNome(M->ZB1_CODIGO, STRTRAN(TIME(),":",""), cNomeArq) //| Altera nome para padrao de armazenamento
			aRetAux		:= DirSave(DIR_TEMP) //| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
			
			IF aRetAux[1]
			
				cDirDest	:= aRetAux[3]
			
				cFullTemp	:= ALLTRIM(cDirDest+cNovoNome)
				nFullTemp := LEN(cFullTemp)
			
				//| Verifica se nome do arquivo nao ultrapassou o tamanho máximo
				IF nFullTemp <= nZB1ARQUIVO
				
					MSGRUN( "Copiando Arquivo "+cNomeArq, "Armazenando arq. Conciliação ", {|| __CopyFile(cFullOrig, cFullTemp) })
					IF FILE(cFullTemp)
					
					
					
						IF RIGHT(cNomeArq,4) == ".ofx"
							aRet	:= ImpOFX(cFullTemp)
						ELSEIF RIGHT(cNomeArq,4) == ".ret"
							aRet	:= Imp240(cFullTemp)
						ELSE
							aRet[2]	:= "Tipo de Arquivo inválido. Somente Arquivos OFX ou Extrato Febraban 240 posições"
						ENDIF 
					
					
						
						
						/*------------------------------------------------------ Augusto Ribeiro | 22/10/2018 - 11:04:33 AM
							Exclui Arquivo de Origem - Utilizado quando funcao executada via JOB
						------------------------------------------------------------------------------------------*/
						IF lDelOrig
							FErase(cFullOrig)
						ENDIF											
						
					ELSE 
						aRet[2] := "Falha na copia do arquivo["+cFullOrig+"]"
					ENDIF
				ELSE
					cMaxNome	:= alltrim(str( (nZB1ARQUIVO-LEN(cDirDest))-1 ))
				
					//FwHelpShow("Nome Arquivo Invalido",,"O nome do arquivo ultrapassa o limite de ["+cMaxNome+"] caracteres","Renomeie o arquivo antes de processeguir")
					aRet[2]	:= "O nome do arquivo ultrapassa o limite de ["+cMaxNome+"] caracteres."
				ENDIF
				
				/*--------------------------
					FECHA SEMAFORO
				---------------------------*/
				U_CPXSEMAF("F", NOME_SEMAFORO, nHSemafaro)
			ELSE
				aRet[2]	:= aRetAux[2]
			ENDIF
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



/*/{Protheus.doc} CP901ARQ
Seleciona arquivo para importacao
@author Augusto Ribeiro | www.compila.com.br
@since 10/12/2014
@version 1.0
@return cRet, Patch do arquivo
@example
(examples)
@see (links_or_references)
/*/  
User Function CP901ARQ()
Local cRet		:= ""
//Local cType		:= "*.TXT"
Local cType		:= "Arquivos OFX|*.OFX"

cRet	:= cGetFile(cType, "Selecione um Arquivo... "+right(cType,5),,,.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F. ) // "Selecione arquivo "

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



/*/{Protheus.doc} Bra2Date
Convert String ddmmyyyy em formato data
@author Augusto Ribeiro | www.compila.com.br
@since 27/11/2016
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function Bra2Date(cData) 
Local dRet		:= CTOD("  /  /  ")
LOcal cNewFormat	:= ""
IF !EMPTY(cData)
	cData	:= ALLTRIM(cData)
	
	cNewFormat	:= RIGHT(cData,4) 
	cNewFormat	+= SUBSTR(cData,3,2)
	cNewFormat	+= LEFT(cData,2)
	
	dRet	:= STOD(cNewFormat)
	
ENDIF

Return(dRet)








/*/{Protheus.doc} Bra2Time
Convert String HHMMSS em formato TIME
@author Augusto Ribeiro | www.compila.com.br
@since 27/11/2016
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function Bra2Time(cTime) 
Local cRet

IF !EMPTY(cTime)
	cTime	:= ALLTRIM(cTime)
	
	cRet	:= SUBSTR(cTime,1,2)+":"
	cRet	+= SUBSTR(cTime,3,2)+":"
	cRet	+= SUBSTR(cTime,5,2)	
ENDIF

Return(cRet)




/*/{Protheus.doc} retDado
Retorna o conteudo que esta presente entre <> </>
@author Augusto Ribeiro | www.compila.com.br
@since 31/01/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function retDado(cTexto) 
Local cRet	:= ""
Local nPosIni	:= 0
Local nPosFim	:= 0 

IF !EMPTY(cTexto)

	nPosIni	:= AT(">", cTexto)+1
	nPosFim	:= AT("<", cTexto, nPosIni)
	
	IF EMPTY(nPosFim)
		nPosFim	:= LEN(cTexto)+1
	ENDIF
	
	cRet	:= SUBSTR(cTexto, nPosIni, nPosFim-nPosIni)

ENDIF

Return(cRet)





/*/{Protheus.doc} CP901OFX
Importa Arquivo OFX
@author Augusto Ribeiro | www.compila.com.br
@since 10/09/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//User Function CP901OFX(cFullTemp)
Static Function ImpOFX(cFullTemp)
Local aRet	:= {.F.,""}
Local nHdlArq, nTotLin, nI
Local cACCTID		:= ""
Local cBanco		:= ""
Local cAgencia		:= ""
Local cConta		:= ""
Local dDtIni		:= CTOD("  /  /  ")
Local dDtFim		:= CTOD("  /  /  ")
Local nFITID	:= TAMSX3("ZB2_FITID")[1]
Local nBANCO	:= TAMSX3("ZB2_BANCO")[1]
Local nAGENC	:= TAMSX3("ZB2_AGENC")[1]
Local nCONTA	:= TAMSX3("ZB2_CONTA")[1]
Local nDESC		:= TAMSX3("ZB2_DESC")[1]
Local nCpoVlr	:= TAMSX3("ZB2_VALOR")[1]
Local nReg		:= 0
Local nDescon	:= 0
Local nTotImp	:= 0
Local lNaoImp	:= GETMV("CP9_NAODIA",.F., .T.) //| Parametro que define se lançamentos do mesmo data base serao importados|

//| Abre Arquivo|
IF  (nHdlArq	:= FT_FUSE(cFullTemp) ) >= 0	




	/*--------------------------
		Verifica Quantas linha Possui o Arquivo
	---------------------------*/				
	nTotLin := FT_FLASTREC()				
	ProcRegua(nTotLin)      

	//| Posiciona na Primeira Linha do Arquivo
	FT_FGOTOP()
											

	

	/*------------------------------------------------------ Augusto Ribeiro | 24/12/2016 - 10:04:56 AM
		Busca dados do Cabecalho
	------------------------------------------------------------------------------------------*/
	WHILE !FT_FEOF()
	
		cLinha	:= ALLTRIM(STRTRAN(FT_FREADLN(),"	",""))
		nLinha	:= len(cLinha)
		IF nLinha > 0 		
			/*
			IF LEFT(cLinha, 8) == "<BANKID>"
				cBanco	:= retDado(cLinha)
				
			ELSEIF LEFT(cLinha, 8) == "<ACCTID>"
				cAux	:= alltrim(retDado(cLinha))
				cAgencia	:= alltrim(LEFT(cAux, 4))
				cConta	:= alltrim(SUBSTR(cAux,5,13))
				*/
			IF LEFT(cLinha, 8) == "<ACCTID>"
					cACCTID	:= alltrim(retDado(cLinha))
					
			ELSEIF LEFT(cLinha, 9) == "<DTSTART>"
				dDtIni	:= STOD(retDado(cLinha))
				
			
			ELSEIF LEFT(cLinha, 7) == "<DTEND>"	
				dDtFim	:= STOD(retDado(cLinha))
			
				EXIT
			ENDIF
		ENDIF
		
		FT_FSKIP()
	ENDDO
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 01/02/2017 - 4:35:55 PM
		Posiciona no banco correspondente no SA6 em função
		do ACCTID
	------------------------------------------------------------------------------------------*/
	IF !EMPTY(cACCTID)
		DBSELECTAREA("SA6")
		SA6->(DbOrderNickName("ACCTID")) //| 
		IF SA6->(DBSEEK(cACCTID)) 
			cBanco		:= SA6->A6_COD
			cAgencia	:= SA6->A6_AGENCIA
			cConta		:= SA6->A6_NUMCON									
		ENDIF
	ENDIF
	

	nCpoZB1	:= ZB1->(FCOUNT())
	nCpoZB2	:= ZB2->(FCOUNT())
	
	BEGIN TRANSACTION
	
	IF !EMPTY(cBanco) .AND.  !EMPTY(cAgencia) .AND. !EMPTY(cConta) //.AND. !EMPTY(dDtIni) .AND. !EMPTY(dDtFim)
		
		//RegToMemory("ZB1", .T., .F.)
		aDadosInc	:= {}										
		AADD(aDadosInc, {"ZB1_BANCO", cBanco})
		AADD(aDadosInc, {"ZB1_AGENC", cAgencia})
		AADD(aDadosInc, {"ZB1_CONTA", cConta})
		AADD(aDadosInc, {"ZB1_DTINI", dDtIni})
		AADD(aDadosInc, {"ZB1_DTFIM", dDtFim})
		AADD(aDadosInc, {"ZB1_ARQUIV", cFullTemp})

		
		/*---------------------------------------------------------------
			Grava cabec arquivos importados
		----------------------------------------------------------------*/
		DBSELECTAREA("ZB1")
		RecLock("ZB1", .T.)
		 
		For nI := 1 To nCpoZB1
			cNameCpo	:= ALLTRIM(ZB1->(FIELDNAME(nI)))
			nPosAux	:= aScan(aDadosInc, { |x| AllTrim(x[1]) == cNameCpo })  
			IF nPosAux > 0
				FieldPut(nI, aDadosInc[nPosAux, 2])
			ELSE
				FieldPut(nI, M->&(cNameCpo) )
			ENDIF
		Next nI
		
		ZB1->(MsUnLock())		
		CONFIRMSX8()
		
		
		
		cTipo		:= ""
		dDtEvento	:= ctod("  /  /  ")
		nValor		:= 0
		cFitID		:= ""
		cDesc		:= ""
		
		DBSELECTAREA("ZB2")
		ZB2->(DBSETORDER(4)) // ZB2_FILIAL+ZB2_BANCO+ZB2_AGENC+ZB2_CONTA+ZB2_DATA+ZB2_VALOR+ZB2_DESC
									
		WHILE !FT_FEOF()							
			nReg++					
			IncProc("Importanto registros... "+STRZERO(nReg,6)+" de "+STRZERO(nTotLin,6))									
	
			cLinha	:= ALLTRIM(STRTRAN(FT_FREADLN(),"	",""))
			nLinha	:= len(cLinha)
			IF nLinha > 0 						
			
			
				/*------------------------------------------------------ Augusto Ribeiro | 24/12/2016 - 10:59:57 AM
					Quando inicia um registro, zera variaveis
				------------------------------------------------------------------------------------------*/
				IF LEFT(cLinha, 9) == "<STMTTRN>"
					cTipo		:= ""
					dDtEvento	:= ctod("  /  /  ")
					nValor		:= 0
					cFitID		:= ""
					cDesc		:= ""
					
				ELSEIF LEFT(cLinha, 9) == "<TRNTYPE>"
					cTipo	:= alltrim(retDado(cLinha))
					
				ELSEIF LEFT(cLinha, 10) == "<DTPOSTED>"
					dDtEvento	:= STOD(retDado(cLinha))
				
				ELSEIF LEFT(cLinha, 8) == "<TRNAMT>"
					nValor	:= VAL( STRTRAN(retDado(cLinha),",","."))										
				
				ELSEIF LEFT(cLinha, 7) == "<FITID>"
					cFitID	:= alltrim(retDado(cLinha))										
				
				ELSEIF LEFT(cLinha, 6) == "<MEMO>"
					cDesc	:= UPPER(alltrim(retDado(cLinha)))										

				ENDIF	



				/*------------------------------------------------------ Augusto Ribeiro | 24/12/2016 - 10:48:40 AM
					Indica fim do registro.
					Realiza a gravacao
				------------------------------------------------------------------------------------------*/
				IF LEFT(cLinha, 10) == "</STMTTRN>"
				
					cFitID		:= PADR(cFitID, nFITID)
					cBanco		:= PADR(cBanco, nBANCO)
					cAgencia	:= PADR(cAgencia, nAGENC)
					cConta		:= PADR(cConta, nCONTA)
					cValor		:= PADR(ALLTRIM(STR(nValor)), nCpoVlr)
					
				
					/*------------------------------------------------------ Augusto Ribeiro | 07/02/2017 - 6:04:50 PM
						Evita inclusao em duplicidade caso arquivo seja reimportado
					------------------------------------------------------------------------------------------*/
					lGrvReg	:= .T.
					//  ZB2_FILIAL+ZB2_BANCO+ZB2_AGENC+ZB2_CONTA+ZB2_DATA+ZB2_VALOR+ZB2_DESC
					IF ZB2->(DBSEEK(XFILIAL("ZB2")+cBanco+cAgencia+cConta+DTOS(dDtEvento)+cValor+cDesc))
				
						WHILE ZB2->(!EOF()) .AND.;
						 	ZB2->(ZB2_FILIAL+ZB2_BANCO+ZB2_AGENC+ZB2_CONTA)+DTOS(ZB2->ZB2_DATA)+PADR(ALLTRIM(STR(ZB2->ZB2_VALOR)), nCpoVlr)+ALLTRIM(ZB2->ZB2_DESC) == XFILIAL("ZB2")+cBanco+cAgencia+cConta+DTOS(dDtEvento)+cValor+cDesc
						
							IF ZB2->ZB2_CODARQ <> ZB1->ZB1_CODIGO
							 	
								nDescon++
								lGrvReg	:= .F.
								EXIT
							ENDIF
							
							ZB2->(DBSKIP())
						ENDDO
					ENDIF	
					
					/*------------------------------------------------------ Augusto Ribeiro | 15/02/2017 - 2:20:24 PM
						Não importa registros lançados no mesmo dia.
					------------------------------------------------------------------------------------------*/
					IF dDtEvento == DDATABASE .AND. lNaoImp
						nDescon++
						lGrvReg	:= .F.
					ENDIF
					
							
					/*------------------------------------------------------ Augusto Ribeiro | 07/02/2017 - 6:05:15 PM
						Tratamentos especificos por banco.
					------------------------------------------------------------------------------------------*/
					IF lGrvReg
						IF cBanco == "756" .OR.  cBanco == "748"
							cAux	:= RIGHT(cDesc,7)													
							IF LEFT(cAux, 5) == "BLOQ." .AND. IsDigit(SUBSTR(cAux, 6,1)) .AND. RIGHT(cAux,1) == "D"
								nDescon++
								lGrvReg	:= .F.														
							ENDIF												
						ENDIF
					ENDIF
				
					/*
					IF ZB2->(DBSEEK(XFILIAL("ZB2")+cFitID+cBanco+cAgencia+cConta))
						nDescon++
					else
					*/
					IF lGrvReg											
						aDadosInc	:= {}
						AADD(aDadosInc, {"ZB2_BANCO", cBanco})
						AADD(aDadosInc, {"ZB2_AGENC", cAgencia})
						AADD(aDadosInc, {"ZB2_CONTA", cConta})
						AADD(aDadosInc, {"ZB2_TIPO", cTipo})
						AADD(aDadosInc, {"ZB2_DATA", dDtEvento})
						AADD(aDadosInc, {"ZB2_VALOR", nValor})
						AADD(aDadosInc, {"ZB2_FITID", cFitID})
						AADD(aDadosInc, {"ZB2_DESC", cDesc})
						AADD(aDadosInc, {"ZB2_CODARQ", ZB1->ZB1_CODIGO})
						AADD(aDadosInc, {"ZB2_ORIGEM", "1"})
					
						/*---------------------------------------------------------------
							Grava cabec arquivos importados
						----------------------------------------------------------------*/
						RegToMemory("ZB2", .T., .F.)
						DBSELECTAREA("ZB2")
						RecLock("ZB2", .T.)
						 
						For nI := 1 To nCpoZB2
							cNameCpo	:= ALLTRIM(ZB2->(FIELDNAME(nI)))
							nPosAux	:= aScan(aDadosInc, { |x| AllTrim(x[1]) == cNameCpo })  
							IF nPosAux > 0
								FieldPut(nI, aDadosInc[nPosAux, 2])
							ELSE
								FieldPut(nI, M->&(cNameCpo) )
							ENDIF
						Next nI
						
						ZB2->(MsUnLock())		
						CONFIRMSX8()										
					
						nTotImp++
					ENDIF
				ENDIF
			
			ENDIF	
	
			FT_FSKIP()
		ENDDO
	
		
	ELSE
		aRet[2]	:= "Banco, Agencia ou Conta não localizados no arquivo"
	ENDIF
	
	

		
	


	/*------------------------------------------------------ Augusto Ribeiro | 27/11/2016 - 3:59:35 PM
		Caso tenha incluido registro de arquivo,
		move arquivo para pasta importado e atualiza ZB1						
	------------------------------------------------------------------------------------------*/
	IF nTotImp > 0 //.AND. EMPTY(ZB1->ZB1_ARQUIV)
		
		
		
		//cDirDest	:= DirSave(DIR_IMPORTADO) //| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
		
		aRetAux	:= DirSave(DIR_IMPORTADO) //| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
		
		IF aRetAux[1]
		
			cDirDest	:= aRetAux[3]								
			cFullDest	:= ALLTRIM(cDirDest+cNovoNome)
										
			IF __CopyFile(cFullTemp, cFullDest)
				RECLOCK("ZB1",.F.)
					ZB1->ZB1_ARQUIV	:= cFullDest
				MSUNLOCK()										
			ENDIF
			

		
		
			aRet[1]	:= .T.
		ELSE
			aRet[2] := "Falha na copia do arquivo["+cFullDest+"]"
			DISARMTRANSACTION()
		ENDIF
	ELSEIF EMPTY(aRet[2])
		aRet[2] := "Nenhum registro foi importado. "+alltrim(transform(nDescon,"@E 99,999,999,999" ))+" registros foram descartados pois já haviam sido importados anteriormente."
		DISARMTRANSACTION()
	ENDIF
	
	
	END TRANSACTION 
	

	IF nHdlArq > 0
		FT_FUSE()
	ENDIF
	IF !EMPTY(cFullTemp)
		//| Apaga o carquio Temp |
		FErase(cFullTemp)
	ENDIF								
else
	aRet[2] := "Falha na abertura do arquivo["+cFullOrig+"]"
endif

Return(aRet)





/*/{Protheus.doc} CP901RET
Importa Arquivo RET - CNAB 240 Posicoes
@author Augusto Ribeiro | www.compila.com.br
@since 10/09/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//User Function CP901RET(cFullTemp)
Static Function imp240(cFullTemp)
Local aRet			:= {.F.,""}
Local lExtrato		:= .F.
Local nHdlArq, nTotLin, cValor, nValor
Local cACCTID		:= ""
Local cBanco		:= ""
Local cAgencia		:= ""
Local cConta		:= ""
Local dDtIni		:= CTOD("  /  /  ")
Local dDtFim		:= CTOD("  /  /  ")
Local nFITID		:= TAMSX3("ZB2_FITID")[1]
Local nBANCO		:= TAMSX3("ZB2_BANCO")[1]
Local nAGENC		:= TAMSX3("ZB2_AGENC")[1]
Local nCONTA		:= TAMSX3("ZB2_CONTA")[1]
Local nDESC			:= TAMSX3("ZB2_DESC")[1]
Local nCpoVlr		:= TAMSX3("ZB2_VALOR")[1]
Local lZB1GRV		:= .F.
Local cSeqExtrato	:= ""
Local nTotImp		:= 0
Local nDescon		:= 0
Local cErroConta	:= ""
Local nI

//| Abre Arquivo|
IF  (nHdlArq	:= FT_FUSE(cFullTemp) ) >= 0	




	/*--------------------------
		Verifica Quantas linha Possui o Arquivo
	---------------------------*/				
	nTotLin := FT_FLASTREC()				
	ProcRegua(nTotLin)      

	//| Posiciona na Primeira Linha do Arquivo
	FT_FGOTOP()

	BEGIN TRANSACTION
	
	/*------------------------------------------------------ Augusto Ribeiro | 24/12/2016 - 10:04:56 AM
		Busca dados do Cabecalho
	------------------------------------------------------------------------------------------*/
	WHILE !FT_FEOF()
	
		cLinha	:= FT_FREADLN()
		nLinha	:= len(cLinha)
		IF nLinha == 240 		

			cTpOper		:= SUBSTR(cLinha,8,4)
			cSeqExtrato	:= ""
			
			/*--------------------------
				HEADER DO LOTE EXTRATO
			---------------------------*/
			IF cTpOper	== "1E04" //|1=Header E=Extrato para Conciliaçã -'04' = Conciliação Bancária
			
			
				cACCTID		:= ""
				cBanco		:= ""
				cAgencia	:= ""
				cConta		:= ""
				dDtIni		:= CTOD("  /  /  ")
				dDtFim		:= CTOD("  /  /  ")			
					
				
				DBSELECTAREA("ZB2")
				ZB2->(DBSETORDER(4)) // ZB2_FILIAL+ZB2_BANCO+ZB2_AGENC+ZB2_CONTA+ZB2_DATA+ZB2_VALOR+ZB2_DESC
								
			
				lExtrato	:= .T.
				
				cACCTID		:= LEFT(cLinha,3)+SUBSTR(cLinha,53,19) //| Banco, Agencia e Conta |
				cSeqExtrato	:= SUBSTR(cLinha,174,5)	//| UTULIZADO PARA COMPOR A CHAVE UNICA DO REGISTRO |
			
				
				/*------------------------------------------------------ Augusto Ribeiro | 01/02/2017 - 4:35:55 PM
					Posiciona no banco correspondente no SA6 em função
					do ACCTID
				------------------------------------------------------------------------------------------*/
				IF !EMPTY(cACCTID)
					DBSELECTAREA("SA6")
					SA6->(DbOrderNickName("ID240")) //| 
					IF SA6->(DBSEEK(cACCTID)) 
						cBanco		:= SA6->A6_COD
						cAgencia	:= SA6->A6_AGENCIA
						cConta		:= SA6->A6_NUMCON									
					ENDIF
				ENDIF
				

				nCpoZB1	:= ZB1->(FCOUNT())
				nCpoZB2	:= ZB2->(FCOUNT())
				
				
				
				IF !EMPTY(cBanco) .AND.  !EMPTY(cAgencia) .AND. !EMPTY(cConta) //.AND. !EMPTY(dDtIni) .AND. !EMPTY(dDtFim)
					
					IF !(lZB1GRV)
						
						cDtAux	:= SUBSTR(cLinha,143,8) // DDMMAAAA
						dDtIni	:= STOD(RIGHT(cDtAux,4)+SUBSTR(cDtAux,3,2)+LEFT(cDtAux,2))					
						
						//RegToMemory("ZB1", .T., .F.)
						aDadosInc	:= {}										
						AADD(aDadosInc, {"ZB1_BANCO", cBanco})
						AADD(aDadosInc, {"ZB1_AGENC", cAgencia})
						AADD(aDadosInc, {"ZB1_CONTA", cConta})
						AADD(aDadosInc, {"ZB1_DTINI", dDtIni})
						AADD(aDadosInc, {"ZB1_DTFIM", dDtFim})
						AADD(aDadosInc, {"ZB1_ARQUIV", cFullTemp})
	
						
						/*---------------------------------------------------------------
							Grava cabec arquivos importados
						----------------------------------------------------------------*/
						DBSELECTAREA("ZB1")
						RecLock("ZB1", .T.)
						 
						For nI := 1 To nCpoZB1
							cNameCpo	:= ALLTRIM(ZB1->(FIELDNAME(nI)))
							nPosAux	:= aScan(aDadosInc, { |x| AllTrim(x[1]) == cNameCpo })  
							IF nPosAux > 0
								FieldPut(nI, aDadosInc[nPosAux, 2])
							ELSE
								FieldPut(nI, M->&(cNameCpo) )
							ENDIF
						Next nI
						
						ZB1->(MsUnLock())		
						CONFIRMSX8()
						lZB1GRV	:= .t.
					ENDIF
					
					FT_FSKIP()
					cLinha	:= FT_FREADLN()					
					cTpReg	:= SUBSTR(cLinha,8,1) //| Tipo de Registro |
					cCodSeg	:= SUBSTR(cLinha,14,1) //| Código Segmento do Reg. Detalhe |
					
					/*--------------------------
						DETALHE DO LOTE EXTRATO
					---------------------------*/						
					WHILE !FT_FEOF() .AND. cTpReg == "3" .and. cCodSeg == "E"
						
						
						
						cFitID		:= cSeqExtrato+SUBSTR(cLinha,9,5)
						
						cDtAux		:= SUBSTR(cLinha,143,8) // DDMMAAAA
						dDtEvento	:= STOD(RIGHT(cDtAux,4)+SUBSTR(cDtAux,3,2)+LEFT(cDtAux,2))	
						
						cValor		:= SUBSTR(cLinha,151,18)
						nValor		:= val(cValor)/100
						

						cTipo		:=	SUBSTR(cLinha,169,1)
						IF cTipo == "C"
							cTipo	:= "CREDIT"
						ELSEIF cTipo == "D"
							cTipo	:= "DEBIT"
							nValor	:= nValor*-1
						ENDIF				
						
						IF !EMPTY(cTipo)
							
							cValor		:= PADR(ALLTRIM(STR(nValor)), nCpoVlr)
									
							//cDesc		:= ALLTRIM(SUBSTR(cLinha,177,25))
							cDesc		:= ALLTRIM(SUBSTR(cLinha,177,64))
						
							
							aDadosInc	:= {}
							AADD(aDadosInc, {"ZB2_BANCO", cBanco})
							AADD(aDadosInc, {"ZB2_AGENC", cAgencia})
							AADD(aDadosInc, {"ZB2_CONTA", cConta})
							AADD(aDadosInc, {"ZB2_TIPO", cTipo})
							AADD(aDadosInc, {"ZB2_DATA", dDtEvento})
							AADD(aDadosInc, {"ZB2_VALOR", nValor})
							AADD(aDadosInc, {"ZB2_FITID", cFitID})
							AADD(aDadosInc, {"ZB2_DESC", cDesc})
							AADD(aDadosInc, {"ZB2_CODARQ", ZB1->ZB1_CODIGO})
							AADD(aDadosInc, {"ZB2_ORIGEM", "1"})
						
						
						
						
							/*------------------------------------------------------ Augusto Ribeiro | 07/02/2017 - 6:04:50 PM
								Evita inclusao em duplicidade caso arquivo seja reimportado
							------------------------------------------------------------------------------------------*/
							lGrvReg	:= .T.
							//  ZB2_FILIAL+ZB2_BANCO+ZB2_AGENC+ZB2_CONTA+ZB2_DATA+ZB2_VALOR+ZB2_DESC
							IF ZB2->(DBSEEK(XFILIAL("ZB2")+cBanco+cAgencia+cConta+DTOS(dDtEvento)+cValor+cDesc))
						
								WHILE ZB2->(!EOF()) .AND.;
								 	ZB2->(ZB2_FILIAL+ZB2_BANCO+ZB2_AGENC+ZB2_CONTA)+DTOS(ZB2->ZB2_DATA)+PADR(ALLTRIM(STR(ZB2->ZB2_VALOR)), nCpoVlr)+ALLTRIM(ZB2->ZB2_DESC) == XFILIAL("ZB2")+cBanco+cAgencia+cConta+DTOS(dDtEvento)+cValor+cDesc
								
									IF ZB2->ZB2_CODARQ <> ZB1->ZB1_CODIGO
									 	
										nDescon++
										lGrvReg	:= .F.
										EXIT
									ENDIF
									
									ZB2->(DBSKIP())
								ENDDO
							ENDIF						
						
						
							IF lGrvReg
								/*---------------------------------------------------------------
									Grava cabec arquivos importados
								----------------------------------------------------------------*/
								RegToMemory("ZB2", .T., .F.)
								DBSELECTAREA("ZB2")
								RecLock("ZB2", .T.)
								 
								For nI := 1 To nCpoZB2
									cNameCpo	:= ALLTRIM(ZB2->(FIELDNAME(nI)))
									nPosAux	:= aScan(aDadosInc, { |x| AllTrim(x[1]) == cNameCpo })  
									IF nPosAux > 0
										FieldPut(nI, aDadosInc[nPosAux, 2])
									ELSE
										FieldPut(nI, M->&(cNameCpo) )
									ENDIF
								Next nI
								
								ZB2->(MsUnLock())		
								CONFIRMSX8()										
							
								nTotImp++	
							ENDIF		
						ENDIF		
					
						
						FT_FSKIP()
						
						IF  !FT_FEOF()
							cLinha		:= FT_FREADLN()
							cTpReg	:= SUBSTR(cLinha,8,1) //| Tipo de Registro |
							cCodSeg	:= SUBSTR(cLinha,14,1) //| Código Segmento do Reg. Detalhe |
						ENDIF						
					ENDDO					
					
					
					
					/*------------------------------------------------------ Augusto Ribeiro | 11/09/2018 - 11:03:02 AM
						Realiza Leitura do Trailer para buscar data final
					------------------------------------------------------------------------------------------*/
					cTpReg	:= SUBSTR(cLinha,8,1) //| Tipo de Registro |
					IF cTpReg == '5' //| Trailer DO LOTE |
						cDtAux		:= SUBSTR(cLinha,143,8) // DDMMAAAA
						dDtFim	:= STOD(RIGHT(cDtAux,4)+SUBSTR(cDtAux,3,2)+LEFT(cDtAux,2))	
					ENDIF
					
					
					
				ELSE
					//aRet[2]	:= "Banco, Agencia ou Conta não localizados no arquivo ["+cACCTID+"]"
					cErroConta	+= cACCTID+"/"
				ENDIF
								
					
				//END TRANSACTION
				
			ENDIF

		ELSE
			aRet[2] := "Arquivos não corresponde a Febraban 240"
		ENDIF
		
		FT_FSKIP()
	ENDDO
	
	
	IF !(lExtrato)
		
		aRet[2] := "Arquivos não possui segmento de extrato (E04) Febraban 240"
	ENDIF
	

	IF EMPTY(cErroConta)

		/*------------------------------------------------------ Augusto Ribeiro | 27/11/2016 - 3:59:35 PM
			Caso tenha incluido registro de arquivo,
			move arquivo para pasta importado e atualiza ZB1						
		------------------------------------------------------------------------------------------*/
		IF nTotImp > 0 //.AND. EMPTY(ZB1->ZB1_ARQUIV)
			
			
			
			//cDirDest	:= DirSave(DIR_IMPORTADO) //| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
			
			aRetAux	:= DirSave(DIR_IMPORTADO) //| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
			
			IF aRetAux[1]
			
				cDirDest	:= aRetAux[3]								
				cFullDest	:= ALLTRIM(cDirDest+cNovoNome)
											
				IF __CopyFile(cFullTemp, cFullDest)
					RECLOCK("ZB1",.F.)
						ZB1->ZB1_ARQUIV	:= cFullDest
						IF !EMPTY(dDtFim)
						ZB1->ZB1_DTFIM	:= dDtFim
						ENDIF
					MSUNLOCK()										
				ENDIF
				
	
			
			
				aRet[1]	:= .T.
			ELSE
				aRet[2] := "Falha na copia do arquivo["+cFullDest+"]"
				DISARMTRANSACTION()
			ENDIF
		ELSE
		
			IF EMPTY(aRet[2])
				aRet[2] := "Nenhum registro foi importado. "+alltrim(transform(nDescon,"@E 99,999,999,999" ))+" registros foram descartados pois já haviam sido importados anteriormente."
			ENDIF
			
			aRetAux	:= DirSave(DIR_DESCARTADO) //| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
			IF aRetAux[1]
				cDirDest	:= aRetAux[3]								
				cFullDest	:= ALLTRIM(cDirDest+cNovoNome)
				
				IF !(__CopyFile(cFullTemp, cFullDest))
				ENDIF
			ENDIF		
			
			DISARMTRANSACTION()
			
		ENDIF
	ELSE
		aRet[2] := "Banco, Agencia ou Conta não localizados no arquivo ["+cErroConta+"]"
		DISARMTRANSACTION()
	ENDIF
	
	END TRANSACTION 
	

	IF nHdlArq > 0
		FT_FUSE()
	ENDIF
	IF !EMPTY(cFullTemp)
		//| Apaga o carquio Temp |
		FErase(cFullTemp)
	ENDIF								
else
	aRet[2] := "Falha na abertura do arquivo["+cFullOrig+"]"
endif

Return(aRet)











/*/{Protheus.doc} CP901JOB
Job para importação dos arquivos de extrato
@author Augusto Ribeiro | www.compila.com.br
@since 19/10/2018
@version version
@param aParam, {cCodEmpresa, cFilial, cEmpBuscaSA6, cEmpBuscaSA6, ...}
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP901JOB(aParam)
Local cPathArq		:= ""
Local nHSemafaro	:= 0
Local cNomeSemaf	:= "cp901job"
Local aSA6XEMP		:= {}
Local aArqTXT, cFile, cDirAtu, aArqDir, cLogArq
Local nI, nQtdeArq
Local aEmpExtrato	:= ""
Local cEmpAtu		:= ""
Local lMultEmp		:= .F.								
Local cEmpArq		:= ""
Local cFilArq		:= ""
Local cLogProc		:= ""
lOCAL nHldLog		:= 0

	
Default aParam	:= {"01","00101MG0001",{"01"}}

IF !empty(aParam)


	/*--------------------------
		ABRE SEMAFORO
	---------------------------*/
	nHSemafaro	:= U_CPXSEMAF("A", cNomeSemaf)			
	IF nHSemafaro > 0

		_cEmp		:= aParam[1]
		_cFilial	:= aParam[2]
		
		PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
		
		cEmpArq		:= SM0->M0_CODIGO
		cFilArq		:= SM0->M0_CODFIL
		
		
		//| Path dos arquivos |
		cPathArq	:= GETMV("CP9_ARQEXT",.F.,"")
		IF !EMPTY(cPathArq)
			
			/*------------------------------------------------------ Augusto Ribeiro | 19/10/2018 - 5:43:15 PM
				Caso seja informada mais de uma empresa, realiza busca pelo identificador do banco
				presente no estrato em todas as empresas para identificação de qual empresa deverá
				ser importado o arquivo.
			------------------------------------------------------------------------------------------*/
			IF LEN(aParam) > 2
				lMultEmp	:= .T.
			
				//| Busca Relação ID's das contas x empresas cadastradas |
				aSA6XEMP	:= SA6XEMP(aParam[3])
				IF EMPTY(aSA6XEMP)	
					Return()
				ENDIF			
			ENDIF
			
			
			
			
			aArqTXT	:= {}
						
			//| Posiciona no diretorio dos arquivos |
			cDirAtu	:= Curdir()
			Curdir("\")
			Curdir(cPathArq)	
			IF !EMPTY(cPathArq)	
				aArqDir := Directory("*.ret")		
				FOR nI := 1 TO LEN(aArqDir)    
			
					aadd(aArqTXT,cPathArq + alltrim(aArqDir[nI,1]) ) 
				
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
					aRetAux := {.f., ""}
					IF lMultEmp
						/*--------------------------------------------------------
							Busca identifica empresa no qual pertence a conta. 
						---------------------------------------------------------*/
						aEmpExtrato	:= EmpxArq(aSA6xEmp, aArqTXT[nI])
											
						IF aEmpExtrato[1] //!EMPTY(aEmpExtrato)
														
							/*------------------------------------------------------ Augusto Ribeiro | 22/10/2018 - 10:35:59 AM
							 Realiza a troca de empresa caso necessário
							------------------------------------------------------------------------------------------*/
							IF cEmpArq	<> aEmpExtrato[3,1]
								
								cEmpArq	:= aEmpExtrato[3,1]
								cFilArq	:= aEmpExtrato[3,2]
		
								dbCloseAll() //Fecho todos os arquivos abertos
								OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
								dbSelectArea("SM0") //Abro a SM0
								SM0->(dbSetOrder(1))
								SM0->(dbSeek(cEmpArq+cFilArq,.T.)) //Posiciona Empresa
								cEmpAnt := SM0->M0_CODIGO //Seto as variaveis de ambiente
								cFilAnt := SM0->M0_CODFIL
								OpenFile(cEmpAnt + cFilAnt) //Abro a empresa que eu desejo trabalhar
							ENDIF
						
							aRetAux	:= U_CP901IMP(aArqTXT[nI], .T.) 
						ELSE
							aRetAux[2] := "Banco, Agencia e Conta presente no arquivo não localizada no Protheus "
							IF VALTYPE(aEmpExtrato[3]) == "C"
								aRetAux[2] += "["+aEmpExtrato[3]+"] "
							ENDIF
							aRetAux[2] += aEmpExtrato[2]	
						ENDIF					
					ELSE
						aRetAux	:= U_CP901IMP(aArqTXT[nI], .T.) 
					ENDIF					
					

					IF aRetAux[1]
						cLogProc	+= ALLTRIM(aArqTXT[nI])+ "| IMPORTADO COM SUCESSO "+CRLF
					ELSE
						cLogProc	+= ALLTRIM(aArqTXT[nI])+ "| FALHA: "+aRetAux[2]+CRLF
					ENDIF
				Next nI				
			
			ELSE
				cLogProc	:= "Não Existem arquivos a serem importados"	
			ENDIF
		ELSE
			cLogProc	:= "Path dos arquivos não localizado. Verifique o parametro."		
		ENDIF
		
		
		RESET ENVIRONMENT		
			
		/*--------------------------
			FECHA SEMAFORO
		---------------------------*/
		U_CPXSEMAF("F", cNomeSemaf, nHSemafaro)	
	ELSE
		cLogProc	:= "Não foi possivel abrir o semaforo"
	ENDIF

ELSE
	cLogProc	:= "Parametros inválidos"
ENDIF


cLogArq	:= DIR_RAIZ+cNomeSemaf+".log"

IF FILE(cLogArq)
	nHldLog	:= FOpen(cLogArq,2)
ELSE
	nHldLog	:= FCreate( cLogArq )
ENDIF
IF nHldLog > 0
	/*
	nTLinLog	:= FT_FLastRec()
	FT_FGoto( nTLinLog )
	*/
	cLogProc	:= CRLF+"*** LOG "+DTOC(DATE())+" "+TIME()+" ***"+CRLF+cLogProc
	FSeek( nHldLog, 1, 2)
	FWrite( nHldLog, cLogProc, LEN(cLogProc) )
	
	FClose()
ENDIF

Return()




/*/{Protheus.doc} SA6XEMP
Busca Banco x Filial
@author Augusto Ribeiro | www.compila.com.br
@since 19/10/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SA6XEMP(aParam)
Local aRet		:= {}
Local cQuery	:= ""
Local nI, aAreaSM0
Local cCodEmp	:= ""
Local cCodFil	:= ""

IF !empty(aParam)


	FOR nI := 1 TO LEN(aParam)
	
		IF !EMPTY(cQuery)
			cQuery	+= " UNION "
		ENDIF
		cQuery += " SELECT '"+aParam[nI]+"' AS EMP, A6_XID240 "+CRLF
		cQuery += " FROM SA6"+aParam[nI]+"0 SA6 "+CRLF
		cQuery += " WHERE SA6.A6_XID240 <> '' "+CRLF
		cQuery += " AND SA6.D_E_L_E_T_ = '' "+CRLF
			
	
	NEXT nI
	
	IF !EMPTY(cQuery)
	
		cQuery += " ORDER BY 1,2 "+CRLF	
		
		If Select("TSA6") > 0
			TSA6->(DbCloseArea())
		EndIf
		
		cQuery	:= changeQuery(cQuery)
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSA6",.F., .T.)
		
		IF TSA6->(!EOF())
			
			DBSELECTAREA("SM0")
			aAreaSM0	:= SM0->(GETAREA())
			SM0->(DBGOTOP())
		
			WHILE TSA6->(!EOF())
			
			
				/*------------------------------------------------------ Augusto Ribeiro | 22/10/2018 - 10:31:34 AM
					POSICIONA NO SM0 PARA BUSCAR FILIAL DA EMPRESA
				------------------------------------------------------------------------------------------*/
				IF ALLTRIM(TSA6->EMP) <> ALLTRIM(SM0->M0_CODIGO)
					cCodEmp	:= ""
					cCodFil	:= ""
					
					SM0->(DBGOTOP())
					WHILE SM0->(!EOF())						
						IF ALLTRIM(SM0->M0_CODIGO) == ALLTRIM(TSA6->EMP)
							cCodEmp	:= ALLTRIM(SM0->M0_CODIGO)
							cCodFil	:= ALLTRIM(SM0->M0_CODFIL)
							EXIT
						ENDIF
									
						SM0->(DBSKIP()) 
					ENDDO
				ELSE
					cCodEmp	:= ALLTRIM(SM0->M0_CODIGO)
					cCodFil	:= ALLTRIM(SM0->M0_CODFIL)
				ENDIF
			
				IF !EMPTY(cCodFil)
					AADD(aRet,{cCodEmp, cCodFil, TSA6->A6_XID240})
				ENDIF
				
				TSA6->(DBSKIP()) 
			ENDDO
			
			RESTAREA(aAreaSM0)
		ENDIF	
		
		TSA6->(DbCloseArea())
	ENDIF

ENDIF

Return(aRet)




/*/{Protheus.doc} EmpxArq
Retorna empresa no qual o ID da conta presente no arquivo
possui agencia cadastra
@author Augusto Ribeiro | www.compila.com.br
@since 19/10/2018
@version undefined
@param param
@return cRet, Codigo da Empresa
@example
(examples)
@see (links_or_references)
/*/
Static Function EmpxArq(aSA6xEmp, cFullArq)
Local aRet	:= {.F.,"",{}}
Local cLinha, nLinha, cTpOper, cSeqExtrato
Local cACCTID, nPosAux



IF  (nHdlArq	:= FT_FUSE(cFullArq) ) >= 0	

	//| Posiciona na Primeira Linha do Arquivo
	FT_FGOTOP()

	/*------------------------------------------------------ Augusto Ribeiro | 24/12/2016 - 10:04:56 AM
		Busca dados do Cabecalho
	------------------------------------------------------------------------------------------*/
	WHILE !FT_FEOF()
	
		/*------------------------------------------------------ Augusto Ribeiro | 24/12/2016 - 10:04:56 AM
			Busca dados do Cabecalho
		------------------------------------------------------------------------------------------*/
		cLinha	:= FT_FREADLN()
		nLinha	:= len(cLinha)
		IF nLinha == 240 		
	
			cTpOper		:= SUBSTR(cLinha,8,4)
			cSeqExtrato	:= ""
			
			/*--------------------------
				HEADER DO LOTE EXTRATO
			---------------------------*/
			IF cTpOper	== "1E04" //|1=Header E=Extrato para Conciliaçã -'04' = Conciliação Bancária
	
				cACCTID		:= ALLTRIM(LEFT(cLinha,3)+SUBSTR(cLinha,53,19)) //| Banco, Agencia e Conta |
				
				nPosAux	:= aScan(aSA6xEmp, { |x| AllTrim(x[3]) == cACCTID })
				
				IF nPosAux > 0
					aRet	:= {.T.,"",{aSA6xEmp[nPosAux,1], aSA6xEmp[nPosAux,2]}}
				ELSE
					aRet	:= {.F.,"",cACCTID}
				ENDIF
				EXIT
			ENDIF
		ENDIF
		
		FT_FSKIP()
	ENDDO
	
	FT_FUSE()
ENDIF


Return(aRet)



