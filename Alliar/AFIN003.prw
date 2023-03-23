#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"


//| TABELA
#DEFINE D_ALIAS 'Z06'
#DEFINE D_TITULO 'Desempenho Medico'
#DEFINE D_ROTINA 'AFIN003'
#DEFINE D_MODEL 'Z06MODEL'
#DEFINE D_MODELMASTER 'Z06MASTER'
#DEFINE D_VIEWMASTER 'VIEW_Z06'

#DEFINE N_CONSELHO 1
#DEFINE N_CRM 2
#DEFINE N_CRMUF 3
#DEFINE N_SEGMENTO 4
#DEFINE N_DATA 5
#DEFINE N_MARCA 6
#DEFINE N_NOME 7
#DEFINE N_QTDEEXAME 8
#DEFINE N_QTDEPACIE 9
#DEFINE N_VALORFAT 10

/*/{Protheus.doc} AFIN003
Importação Desempenho Medico
@author Jonatas Oliveira | www.compila.com.br
@since 24/06/2017
@version 1.0
/*/
User Function AFIN003(aParam)
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(D_ALIAS)
	oBrowse:SetDescription(D_TITULO)
	
	oBrowse:AddLegend( "Z06->Z06_ATUALI == 'S'"	, "BR_VERDE"	, "Cadastro Medico Atualizado" )    
	oBrowse:AddLegend( "Z06->Z06_ATUALI == 'N'"	, "BR_AMARELO"	, "Cadastro Medico Pendente" )

	oBrowse:DisableDetails()

	oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef
Botoes do MBrowser
@author Jonatas Oliveira | www.compila.com.br
@since 24/06/2017
@version 1.0
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'           OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Importacao' ACTION 'U_AFIN03I()'		 OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
	
	ADD OPTION aRotina TITLE 'Atualiza Segmento'  ACTION 'U_AFIN03S()'	 OPERATION 4 ACCESS 0  
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
Return aRotina

/*/{Protheus.doc} ModelDef
Definicoes do Model
@author Jonatas Oliveira | www.compila.com.br
@since 24/06/2017
@version 1.0
/*/
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruct := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
	//Local oStruZG7 := FWFormStruct( 1, 'ZG7', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New(D_MODEL, /*bPreValidacao*/, /*bPosValidacao*/,  /*bCommit*/ , /*bCancel*/ )

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

/*/{Protheus.doc} ViewDef
Definicoes da View
@author Jonatas Oliveira | www.compila.com.br
@since  24/06/2017
@version 1.0
/*/
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



/*/{Protheus.doc} AFIN03I
Importação de arquivo Desempenho Medico
@author Jonatas Oliveira | www.compila.com.br
@since 25/06/2017
@version 1.0
/*/
User Function AFIN03I()
	Local lProcessa		:= .F.
	Local lConsulta
	Local cType			:= "Arquivo CSV | *.CSV"
	Local aArqDir		:= {}
	Local aArqFullPath	:= {} 

	Default lConsulta	:= .F.

	Private cWhereP04	:= ""

	Private cCadastro 	:= "Leitura de Desempenho Medico"
	Private cTitulo		:= cCadastro
	Private aBotoes		:= {}
	Private cPathArq	:= ""

	aSay	:= {"Leitura de Desempenho Medico",;
	"  ",;
	" Esta rotina tem como objetivo Ler Desempenho ",;
	" Medico.  ",;
	"  ",;
	"   ",;
	"                                                                                                                                       v1.0"}


	cPathArq	:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa Log ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogIni( aBotoes )

	aAdd(aBotoes, { 5,.T.,{|| cPathArq := cGetFile(cType, ("Selecione arquivo "+Subs(cType,1,7) ) ) }})
	aAdd(aBotoes, { 1,.T.,{|| lProcessa := .T., FechaBatch() }} )
	aAdd(aBotoes, { 2,.T.,{|| lProcessa := .F., FechaBatch()  }} )

	FormBatch( cCadastro, aSay, aBotoes ,,240,510)


	IF lProcessa		
		IF EMPTY(cPathArq)
			cPathArq := cGetFile('Arquivo CSV|*.csv','Selecione arquivo',0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)
		ENDIF

		IF !EMPTY(cPathArq)

			aArqFullPath	:= {cPathArq}

			IF MsgYesNo("Confirma a importação do arquivo "+alltrim(cPathArq)+" ?" ) 						
				//RptStatus({|| ImpDes(aArqFullPath,cPathArq)}, "Desempenho Medico")//({|lEnd| U_TestRel(@lEnd,wnRel,cString,Tamanho,NomeProg)},titulo)
				Processa( {|| ImpDes(aArqFullPath,cPathArq) }, "Aguarde...", "Desempenho Medico...",.F.)
			ENDIF		 
		ELSE
			AVISO("Vazio", "Nenhum arquivo foi localizado", {"OK"}, 1)
		ENDIF
	ENDIF

Return()



/*/{Protheus.doc} ImpDes
Executa leitura do arquivo CSV e Importa para as tabelas
@author Jonatas Oliveira | www.compila.com.br
@since 25/06/2017
@version 1.0
/*/
Static Function ImpDes(aPathArq,cPathFull)
	Local cMsgErro	:= ""
	Local nTotArq, nI
	Local aRet	:= {.F., ""}
	Local cNomeArq
	Local cPathTemp := DirTemp() //| Busca diretorio temporario |
	Local cFullTemp	:= ""
	Local cArqLog	:= ""
	Local cAliasImp	:= ""

	Local nHdlArq, cLinha, aLinha, aDados, nTotLin,aItens, aItem
	Local nHdlErro	:= 0
	Local nReg	:= 0
	Local lArqErro	:= .F.
	Local cCabecArq, cCabecF
	Local nPosErro	:= 0
	Local xVarCpo
	Local nRet	:= 0 //| 0=Valor Inicial, 1=Sucesso, 2=Erro |
	Local BOK		:= {|| (.T.)}


	/*---------------------------------------------------------------- Augusto Ribeiro | Oct 27, 2015
	Variaveis para gracao do Log
	------------------------------------------------------------------------------------------*/
	Private _cFileLog	 	:= ""    
	Private _cLogPath		:= ""  
	Private _Handle			:= "" 

	IF !EMPTY(aPathArq)
		nTotArq	:= LEN(aPathArq)

		IF nTotArq >= 1
			nTotLin := FT_FLASTREC()
			//ProcRegua(nTotArq)

			FT_FGOTOP()

			cMsgErro	:= ""

			DBSELECTAREA("Z06")
			Z06->(DBSETORDER(1))

			cNomeArq	:= NomeArq(cPathArq)
			cFullPath	:= cPathTemp+cNomeArq

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Copia arquivo da maquina do usuario para o servidor ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			__CopyFile(cPathArq , cFullPath)

			nHandle	:= FT_FUse(cFullPath)

			cArqLog	:= LEFT(cNomeArq,LEN(cPathArq)-4)+"_LOG.CSV"

			/*-----------------------------------------------
			Primeira linha refere-se ao Cabecalho
			-------------------------------------------------------*/
			cCabecArq	:= FT_FREADLN()
			aCabecArq	:= StrTokArr2( cCabecArq, ";", .F.)
			nCabecArq	:= len(aCabecArq)

			FT_FSKIP()

			cLinha 		:= FT_FREADLN()			
			aLinha		:= StrTokArr2( cLinha, ";", .T.)
			nQtdeCol	:= LEN(aLinha)
			nCabecArq 	:= nQtdeCol

			//IncProc("Importando Arquivos... "+TRANSFORM(nI, "@e 999,999,999",)+" de "+TRANSFORM(nTotArq,"@e 999,999,999"))
			ProcRegua(nTotLin)
			
			cErroLin	:= ""

			WHILE !FT_FEOF()
				nReg++		

				IncProc("Importanto registros... "+STR(nReg))					
				//IncProc()
//				IncRegua() 

				cErroLin := ""

				cLinha 		:= FT_FREADLN()			
				aLinha		:= StrTokArr2( cLinha, ";", .T.)
				nQtdeCol	:= LEN(aLinha)
				nCabecArq 	:= nQtdeCol

				cErroLin := GrvZ06(aLinha)
				
				
				IF !EMPTY(cErroLin)
					nRet := 2 //| Erro 
					GrvArqErro(@nHdlErro, cArqLog, aLinha, cErroLin)
				ENDIF

				FT_FSKIP()
			ENDDO
			
			IF nHdlErro > 0
				fClose(nHdlErro)
			ENDIF

			IF !EMPTY(cErroLin)
				cMsgErro := "Processado com erros. Verifique o arquivo de log:  " + cPathArq + cArqLog
			ELSE
				cMsgErro := " Todos os registros foram processados."
			ENDIF 

			IF !EMPTY(cMsgErro)
				AVISO("Log de processamento", "LOG de processamento"+CRLF+CRLF+cMsgErro, {"Fechar"},3)
			ENDIF
		ELSE
			AVISO("Aviso", "Nenhum arquivo foi selecionado.", {"Fechar"},2)
		ENDIF 

	ENDIF


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

Return()


/*/{Protheus.doc} GrvZ06
Grava dados na tabela Z06
@author Jonatas Oliveira | www.compila.com.br
@since 25/06/2017
@version 1.0
/*/
Static Function GrvZ06(aDadZ06)
	Local cRet 	:= ""
	Local nY	:= 0 
	Local aSegment	:= {"",""}
	Local nValFat	:= 0 
	Local nQtdeEx	:= 0 
	Local nQtdePc	:= 0 
	
	//For nY := 1 To Len(aDadZ06)
		/*
		RecLock("Z06",.T.)	
	
		Z06->Z06_FILIAL := xFilial("Z06")
		Z06->Z06_CONSEL := aDadZ06[N_CONSELHO]
		Z06->Z06_CRM 	:= aDadZ06[N_CRM]
		Z06->Z06_CRMUF 	:= aDadZ06[N_CRMUF]
		Z06->Z06_SEGMEN := aDadZ06[N_SEGMENTO]
		Z06->Z06_DATA 	:= CTOD(aDadZ06[N_DATA])
		Z06->Z06_MARCA 	:= aDadZ06[N_MARCA]
		Z06->Z06_NOME 	:= aDadZ06[N_NOME]
		Z06->Z06_QTDE 	:= VAL(aDadZ06[N_QTDEEXAME])
		Z06->Z06_QTDPAC := VAL(aDadZ06[N_QTDEPACIE])
		Z06->Z06_VALOR 	:= VAL(aDadZ06[N_VALORFAT])
		Z06->Z06_AQUIV 	:= ALLTRIM(cPathArq)
		Z06->Z06_AQUIV 	:= ALLTRIM(cPathArq)
		Z06->Z06_AQUIV 	:= ALLTRIM(cPathArq)
		
		Z06->(MsUnLock())
		
		DBSELECTAREA("Z06")
		Z06->(DBSETORDER(1))
		*/
		IF VALTYPE(aDadZ06[N_VALORFAT]) == "C"
			nValFat := VAL(STRTRAN(STRTRAN(ALLTRIM(aDadZ06[N_VALORFAT]), ".", ""), ",","."))
		ELSE
			nValFat := VAL(aDadZ06[N_VALORFAT])
		ENDIF 

		IF VALTYPE(aDadZ06[N_QTDEEXAME]) == "C"
			nQtdeEx := VAL(STRTRAN(STRTRAN(ALLTRIM(aDadZ06[N_QTDEEXAME]), ".", ""), ",","."))
		ELSE
			nQtdeEx := VAL(aDadZ06[N_QTDEEXAME])
		ENDIF 		
		
		IF VALTYPE(aDadZ06[N_QTDEPACIE]) == "C"
			nQtdePc := VAL(STRTRAN(STRTRAN(ALLTRIM(aDadZ06[N_QTDEPACIE]), ".", ""), ",","."))
		ELSE
			nQtdePc := VAL(aDadZ06[N_QTDEPACIE])
		ENDIF 		
				
		
		
			
		aSegment := AtuSegm(nValFat)
		
		
		nTotCpo	:= Z06->(FCount())
		
		RegToMemory("Z06",.T.)
		
		M->Z06_FILIAL 	:= xFilial("Z06")
		M->Z06_CONSEL 	:= aDadZ06[N_CONSELHO]
		M->Z06_CRM 		:= aDadZ06[N_CRM]
		M->Z06_CRMUF 	:= aDadZ06[N_CRMUF]
		M->Z06_CODSEG 	:= aSegment[1]
		M->Z06_SEGMEN 	:= aSegment[2]
		M->Z06_DATA 	:= CTOD(aDadZ06[N_DATA])
		M->Z06_MARCA 	:= aDadZ06[N_MARCA]
		M->Z06_NOME 	:= aDadZ06[N_NOME]
		M->Z06_QTDE 	:= nQtdeEx
		M->Z06_QTDPAC 	:= nQtdePc
		M->Z06_VALOR 	:= nValFat
		M->Z06_AQUIV 	:= ALLTRIM(cPathArq)
		
		RECLOCK("Z06",.T.)
		
		For nI := 1 To nTotCpo
			FieldPut(nI, M->&(FIELDNAME(nI)) )
		Next nI
		
		MSUNLOCK()
		CONFIRMSX8()
	
	//Next nY
	
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

		aPastas	:= StrTokArr2(cDirTemp,"\", .F.)

		/*--------------------------
		Cria pastas
		---------------------------*/
		CurDir("\")
		nAux	:= 0
		for nI := 1 to Len(aPastas)



			nAux	:= MakeDir(alltrim(aPastas[nI]))
			//IF nAux <> 0
				//CONOUT("### CPIMP01.PRW [DirTemp] | Nao foi possivel criar o diretorio ["+alltrim(aPastas[nI])+"]. Cod. Erro: "+alltrim(str(FError())) )
			//ENDIF		

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




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Augusto Ribeiro    30/06/09³
//³                            ³
//³ Retorna o Nome do Arquivo  ³
//³ Parametro: cFullPath       ³
//³ Retorno: Arquivo.ext       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RemovCharºAutor  ³ Augusto Ribeiro	 º Data ³  08/06/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Remove caracter especial                                   ±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC Function RemovChar(cRet)
	Local cRet

	cRet	:= upper(cRet)

	cRet	:= STRTRAN(cRet,"Á","A")
	cRet	:= STRTRAN(cRet,"É","E")
	cRet	:= STRTRAN(cRet,"Í","I")
	cRet	:= STRTRAN(cRet,"Ó","O")
	cRet	:= STRTRAN(cRet,"Ú","U")
	cRet	:= STRTRAN(cRet,"À","A")
	cRet	:= STRTRAN(cRet,"È","E")
	cRet	:= STRTRAN(cRet,"Ì","I")
	cRet	:= STRTRAN(cRet,"Ò","O")
	cRet	:= STRTRAN(cRet,"Ù","U")
	cRet	:= STRTRAN(cRet,"Ã","A")
	cRet	:= STRTRAN(cRet,"Õ","O")
	cRet	:= STRTRAN(cRet,"Ä","A")
	cRet	:= STRTRAN(cRet,"Ë","E")
	cRet	:= STRTRAN(cRet,"Ï","I")
	cRet	:= STRTRAN(cRet,"Ö","O")
	cRet	:= STRTRAN(cRet,"Ü","U")
	cRet	:= STRTRAN(cRet,"Â","A")
	cRet	:= STRTRAN(cRet,"Ê","E")
	cRet	:= STRTRAN(cRet,"Î","I")
	cRet	:= STRTRAN(cRet,"Ô","O")
	cRet	:= STRTRAN(cRet,"Û","U")
	cRet	:= STRTRAN(cRet,"Ç","C")
	cRet	:= STRTRAN(cRet,"º"," ")
	cRet	:= STRTRAN(cRet,"-","")
	cRet	:= STRTRAN(cRet,".","")
	cRet	:= STRTRAN(cRet,"R$","")
	cRet	:= STRTRAN(cRet,"NULL","")


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
Static Function GrvArqErro(nHdlErro, cNomeArq, aLinha, cMsgErro)
	Local cPathTemp := DirTemp() //| Busca diretorio temporario |
	Local nI		:= 0
	Local cCabec	:= ""
	Local cLinErro	:= ""

	IF !EMPTY(cMsgErro)

		IF nHdlErro == 0
			cCurDir	:= CurDir()
			CurDir(cPathTemp)

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
				IF VALTYPE(aLinha[nI]) == "N"
					cLinErro += ALLTRIM(STR(aLinha[nI]))+";"
				ELSEIF  VALTYPE(aLinha[nI]) == "D"
					cLinErro += DTOC(aLinha[nI])+";"	
				ELSE
					cLinErro += aLinha[nI]+";"
				ENDIF
			ELSE
				cLinErro += ";"
			ENDIF
		next
		cLinErro	+= cMsgErro	+CRLF

		nAux	:= FWrite(nHdlErro, cLinErro)
	ENDIF


Return()


/*/{Protheus.doc} AtuSegm
Atualiza o segmento conforme valor
@author Jonatas Oliveira | www.compila.com.br
@since 06/02/2018
@version 1.0
/*/
Static Function AtuSegm(nVlrCont)
	Local aRet 	:= {"",""}
	
	/*
	Ouro – faturamento acima de 15 mil/ mês
	Prata – faturamento entre 7 mil e 14.999,99/ mês
	Bronze – faturamento entre 1 mil e 6.999,99/ mês
	*/
	
	DBSELECTAREA("AOV")
	AOV->(DBSETORDER(1))
	AOV->(DBGOTOP())
	
	WHILE AOV->(!EOF())
		IF AOV->AOV_VLRFIM > 0 
			IF nVlrCont >= AOV->AOV_VLRINI .AND. nVlrCont <= AOV->AOV_VLRFIM
				aRet[1]	:=  AOV->AOV_CODSEG
				aRet[2]	:=  AOV->AOV_DESSEG
			ENDIF  
		ENDIF 

		IF !EMPTY(aRet[1])
			EXIT
		ENDIF 
		
		AOV->(DBSKIP())
	ENDDO
	
	
Return(aRet)

/*/{Protheus.doc} AFIN03S
Atualiza segmento no cadastro do médico
@author Jonatas Oliveira | www.compila.com.br
@since 06/02/2018
@version 1.0
/*/
User Function AFIN03S()
	Local aArea		:= GetArea()
	Local cPerg 	:= "AFIN03S"
	Local _lPerg 	:= .F.
	Local lProcessa	:= .F.


	Private cCadastro 	:= "Atualiza Segmento Medico"
	Private aBotoes		:= {}

	//____________________________________________
	//³ Parametros do Usuario ³
	//____________________________________________
	//AjustSX1(cPerg)


	aSay	:= {"Segmento Medico",;
				"  ",;
				" Esta rotina atualiza o segmento no cadastro do médico. ",;
				" Informe o periodo para atualização. ",;
				"  ",;
				"  ",;
				" Para prosseguir, seleciona um dos botões abaixo. ",;
				"   ",;
				"  v1.0"}



	ProcLogIni( aBotoes )

	aAdd(aBotoes, { 5,.T.,{|| _lPerg := PERGUNTE(cPerg,.T.)}})
	aAdd(aBotoes, { 1,.T.,{|| lProcessa := .T., FechaBatch() }} )
	aAdd(aBotoes, { 2,.T.,{|| lProcessa := .F., FechaBatch()  }} )

	FormBatch( cCadastro, aSay, aBotoes )//,,240,510)

	//_______________________________________________________________
	//³Forca o preenchimento das perguntas caso clique em Confirmar³
	//_______________________________________________________________
	IF !_lPerg .AND.  lProcessa
		_lPerg := PERGUNTE(cPerg,.T.)

	ENDIF


	IF lProcessa .and. _lPerg
		AFIN03P()
	Endif 
	
Return()

/*/{Protheus.doc} AFIN03P
Filtra registros conforme parametro
@author Jonatas Oliveira | www.compila.com.br
@since 06/02/2018
@version 1.0
/*/
Static Function AFIN03P()
	Local cQuery	:= ""
	
	Private _cFileLog	:= ""
	Private _cLogPath	:= ""
	Private _Handle		:= ""
	
	cQuery += " SELECT * "
	cQuery += " FROM "+Retsqlname("Z06")+" "
	cQuery += " WHERE D_E_L_E_T_ = '' "
	cQuery += " 	AND Z06_DATA BETWEEN '"+ DTOS(MV_PAR01) +"' AND '"+ DTOS(MV_PAR02) +"' "
	cQuery += " 	AND Z06_ATUALI <> 'S' "
	
	If Select("TSQSEG") > 0
		TSQSEG->(DbCloseArea())
	EndIf
	
	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TSQSEG", .F., .T.) 
	
	fGrvLog(1,"Log de atualização de segmento . "+TIME()+". "+ DToC(ddatabase)  )
	
	IF TSQSEG->(!EOF())
		Processa({|| AFIN03A()},"Atualizando Segmento...")
	ELSE
		Help("Segmento",1,"Não Localizado",,"Verifique os parametros informados. " ,4,5)	
		fGrvLog(2,"Nenhum registro localizado. Verifique os parametros informados.")
	ENDIF 
	
	fGrvLog(3,"Fim da Gravação . "+TIME()+". "+ DToC(ddatabase))
	
Return()

/*/{Protheus.doc} AFIN03A
Atualiza o segmento no cadastro de médicos ACH
@author Jonatas Oliveira | www.compila.com.br
@since 06/02/2018
@version 1.0
/*/
Static Function AFIN03A()
	
	DBSELECTAREA("ACH")
	ACH->(DBSETORDER(7))//|ACH_FILIAL+ACH_XCRM+ACH_XCRMUF|
	
	DBSELECTAREA("Z06")
	Z06->(DBSETORDER(1))
	
	WHILE TSQSEG->(!EOF())
		IF ACH->(DBSEEK(XFILIAL("ACH") + ALLTRIM(TSQSEG->(Z06_CRM)) + SPACE(TAMSX3("Z06_CRM")[1] - LEN(ALLTRIM(TSQSEG->(Z06_CRM)))) + TSQSEG->(Z06_CRMUF )))
			
			ACH->(RecLock("ACH",.F.))
				ACH->ACH_CODSEG	:= 	TSQSEG->Z06_CODSEG			
			ACH->(MsUnLock())
			
			Z06->(DBGOTO(TSQSEG->R_E_C_N_O_ ))
			
			Z06->(RecLock("Z06",.F.))
				Z06->Z06_ATUALI	:= 	"S"		
			Z06->(MsUnLock())
			
			fGrvLog(2,"Medico Atualizado : " + TSQSEG->Z06_CRM + " - " + TSQSEG->Z06_CRMUF + " " + TSQSEG->Z06_NOME  )
		ELSE
			fGrvLog(2,"Medico NAO LOCALIZADO : " + TSQSEG->Z06_CRM + " - " + TSQSEG->Z06_CRMUF + " " + TSQSEG->Z06_NOME  )
		ENDIF 
		
		TSQSEG->(DBSKIP())
	ENDDO
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

Default _nOpc		:= 0
Default _cTxtLog 	:= ""
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
