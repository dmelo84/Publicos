#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "fileio.ch"



#DEFINE COLUNA_LOG "LOG_IMPORTACAO"   


#DEFINE aCpoCabec	{"Z15_COD","Z15_DATA", "Z15_ARQ" , "Z15_USER"}

//| TABELA
#DEFINE D_ALIAS 'Z15'
#DEFINE D_TITULO 'Importacao Medicos'
#DEFINE D_ROTINA 'ATMK003'
#DEFINE D_MODEL 'Z15MODEL'
#DEFINE D_MODELMASTER 'Z15MASTER'
#DEFINE D_VIEWMASTER 'VIEW_Z15'

/* - TABELAS ENVOLVIDAS
	Z15
	ACH
	SU5
	AGB
	AGA
	AC8
	AO4	
*/

/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclusão;
MODEL_OPERATION_UPDATE para alteração;
MODEL_OPERATION_DELETE para exclusão.
*/

/*/{Protheus.doc} ATMK003
Interface de importação de cadastro médicos
@author Jonatas Oliveira | www.compila.com.br
@since 01/04/2019
@version 1.0
/*/
User function ATMK003()
	Local oBrowse

	Private lDesOper	:= .F.
	Private lDesAmbi	:= .F.

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(D_ALIAS)
	oBrowse:SetDescription(D_TITULO)

	oBrowse:Activate()

Return(NIL)


/*/{Protheus.doc} MenuDef
Botoes do MBrowser
@author Jonatas Oliveira | www.compila.com.br
@since 02/04/2019
@version 1.0
/*/
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
	ADD OPTION aRotina TITLE 'Importar'  ACTION  'U_ATMK03I()' OPERATION 3 ACCESS 0  	
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Cadastra Medicos'    ACTION 'U_ATMK03M(Z15->Z15_COD)' OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
	//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
	//ADD OPTION aRotina TITLE 'Legenda'  ACTION 'eval(oBrowse:aColumns[1]:GetDoubleClick())'             OPERATION 1 ACCESS 0



Return(aRotina)


/*/{Protheus.doc} ModelDef
Definicoes do Model
@author Jonatas Oliveira | www.compila.com.br
@since 02/04/2019
@version 1.0
/*/
Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZ15 := FWFormStruct( 1, D_ALIAS, { |cCampo| CPOCABEC(cCampo) } /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStItemZ15 := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel, nI  



	/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 5:40:45 PM
	Altera inicializador Padrão dos itens para não apresentar erro de campo
	obrigatorio nao preenchido
	------------------------------------------------------------------------------------------*/
	//FOR nI := 1 to len(aCpoCabec)
	//	oStItemZ15:SetProperty(aCpoCabec[nI], MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
	//NEXT nI



	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New(D_ROTINA+'MODEL',/*bPreValidacao*/, {  |oModel| POSMODEL( oModel ) },{  |oModel| GRVDADOS( oModel ) }  , {||RollbackSX8(), .T.} )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'Z15MASTER', /*cOwner*/, oStruZ15, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	oModel:AddGrid( 'Z15ITENS', 'Z15MASTER', oStItemZ15, /* { |oModel, nLine, cAction, cField| PRELZZA(oModel, nLine, cAction, cField) } */ , /*{ |oModel, nLine, cAction, cField| POSLZZA(oModel, nLine, cAction, cField) } bLinePost*/, /*bPreVal*/,	 /*bPosVal*/, /*BLoad*/ )

	//oModel:SetRelation( 'ZA3VALEMP',	{{ 'ZA3_FILIAL', 'ZA1_FILIAL' }, { 'ZA3_CODIGO', 'ZA1_CODIGO' } , { 'ZA3_REV', 'ZA1_REV' }},"ZA3_FILIAL+ZA3_CODIGO+ZA3_REV" )
	oModel:SetRelation( 'Z15ITENS',	{{ 'Z15_FILIAL', 'XFILIAL("Z15")' }, { 'Z15_COD', 'Z15_COD' } },  "Z15_FILIAL+Z15_COD" )

	// Liga o controle de nao repeticao de linha
	oModel:GetModel( 'Z15MASTER' ):SetPrimaryKey( { 'Z15_FILIAL', 'Z15_COD'} )

	//Se torna a apenas visual o contéudo da Linha do Grid informado
	oModel:GetModel( 'Z15MASTER' ):SetOnlyView ( .T. )   

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( D_TITULO )

	oStItemZ15:SetProperty( 'Z15_COD' , MODEL_FIELD_WHEN   , {|| .T.})


Return(oModel)


/*/{Protheus.doc} ViewDef
Definicoes da View 
@author Jonatas Oliveira | www.compila.com.br
@since 02/04/2019
@version 1.0
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( D_ROTINA )
	// Para a interface (View) a função FWFormStruct, traz para a estrutura os campos conforme o nível, uso ou módulo. 
	Local oStruZ15 := FWFormStruct( 2, D_ALIAS,  { |cCampo| CPOCABEC(cCampo) })
	Local oStItemZ15 := FWFormStruct( 2, D_ALIAS, { |cCampo| !CPOCABEC(cCampo) })

	Local oView, cOrdemCpo, nI
	Local aCpoView 	:= {} 

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Cria o objeto de Estrutura 

	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( D_VIEWMASTER , oStruZ15 , D_MODELMASTER )
	oView:AddGrid ( 'VIEW_Z15ITEM'   , oStItemZ15 , 'Z15ITENS' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR'  , 30   )    
	oView:CreateHorizontalBox( 'INFERIOR'  , 70   )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( D_VIEWMASTER, 'SUPERIOR' )
	oView:SetOwnerView( "VIEW_Z15ITEM"  ,  'INFERIOR' )
	
	oView:AddIncrementField( 'VIEW_Z15ITEM', 'Z15_ITEM' )

	// Informa os titulos dos box da View
	oView:EnableTitleView(D_VIEWMASTER,'Cabecalho')
	oView:EnableTitleView('VIEW_Z15ITEM','Itens')

	oView:SetCloseOnOk({||.T.})

Return(oView)



/*/{Protheus.doc} GRVDADOS
@version 1.0
/*/
Static Function GRVDADOS(oModel)
	Local lRet	:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oModCabec	:= oModel:GetModel(D_MODELMASTER)
	Local oModItem		:= oModel:GetModel('Z15ITENS')
	Local nI, nY

	IF nOperation == 3 .OR. nOperation == 4
		FOR nI := 1 to oModItem:Length()

			oModItem:GoLine( nI )

			FOR nY := 1 TO LEN(aCpoCabec)	
				oModItem:LOADVALUE(aCpoCabec[nY], oModCabec:GetValue(aCpoCabec[nY]))	
			NEXT nY

		next nI
	ENDIF

	aRet	:= GRVMODEL(oModItem)

Return(lRet)



/*/{Protheus.doc} POSMODEL
(long_description)
@version 1.0
/*/
Static Function POSMODEL(oModel)
	Local lRet	:= .T.
	Local nY, nAux
	Local nOperation	:= oModel:GetOperation()


Return(lRet)


/*/{Protheus.doc} POSMODEL
Grava dados da Model no banco  
@version 1.0
/*/
Static Function GRVMODEL(oObjeto)
	Local aRet	:= {.F.,""}
	Local nOperation := oObjeto:GetOperation()
	Local cOldAlias	:= ""
	Local bBefore,bAfter,nOperation,oSuperObjeto, bAfterSTTS
	Local nY, nX, nLen, cAlias

	bBefore 	:= {|| .T.}
	bAfter		:= {|| .T.}
	bAfterSTTS	:= {|| .T.}

	cAlias	:= oObjeto:oFormModelStruct:GetTable()[FORM_STRUCT_TABLE_ALIAS_ID]

	IF !EMPTY(cAlias)

		aRelation := oObjeto:GetRelation()
		aDados    := oObjeto:GetData()
		aStruct   := oObjeto:oFormModelStruct:GetFields()
		IF ALLTRIM(oObjeto:ClassName()) == "FWFORMGRID"

			If (nOperation == MODEL_OPERATION_INSERT) .OR. (nOperation == MODEL_OPERATION_UPDATE)

				For nY := 1 To Len(aDados)
					oObjeto:GoLine(nY)
					lLock     := .F.
					nNextOper := 0
					//--------------------------------------------------------------------
					//Verifica o tipo de atualicao ( Insert ou Update )
					//--------------------------------------------------------------------
					If aDados[nY][MODEL_GRID_ID] <> 0
						//--------------------------------------------------------------------
						//Verifica se uma das linhas foi atualizada
						//--------------------------------------------------------------------
						For nX := 1 To Len(aStruct)
							If aDados[nY][MODEL_GRID_DATA][MODEL_GRIDLINE_UPDATE][nX]
								lLock := .T.
								Exit
							EndIf
						Next nX
						If aDados[nY][MODEL_GRID_DELETE] .Or. lLock
							(cAlias)->(MsGoto(aDados[nY][MODEL_GRID_ID]))
							RecLock(cAlias,.F.)
							lLock     := .T.
						EndIf
						nNextOper := nOperation
						If aDados[nY][MODEL_GRID_DELETE]
							nNextOper := MODEL_OPERATION_DELETE
						EndIf
					Else				
						For nX := 1 To Len(aStruct)
							If aDados[nY][MODEL_GRID_DATA][MODEL_GRIDLINE_UPDATE][nX] .And. !aDados[nY][MODEL_GRID_DELETE]
								lLock     := .T.
								nNextOper := nOperation
								Exit
							EndIf
						Next nX
						If lLock
							//--------------------------------------------------------------------
							//Quando as estruturas sao da mesma tabela - Modelo 2
							//--------------------------------------------------------------------
							If (nY == 1 .And. cAlias == cOldAlias)
								RecLock(cAlias,.F.)
							Else
								RecLock(cAlias,.T.)
							EndIf
						EndIf
					EndIf
					If lLock
						//--------------------------------------------------------------------
						//Executa o bloco de código de Pre-atualização
						//--------------------------------------------------------------------
						If !Empty(bBefore)
							(cAlias)->(Eval(bBefore,oObjeto,oObjeto:cID,cAlias))
						EndIf
						//--------------------------------------------------------------------
						//Verifica se a linha foi deletada
						//--------------------------------------------------------------------
						If aDados[nY][MODEL_GRID_DELETE]
							(cAlias)->(dbDelete())
						Else
							//--------------------------------------------------------------------
							//Efetua a gravacao dos campos                    
							//--------------------------------------------------------------------
							For nX := 1 To Len(aStruct)
								If aDados[nY][MODEL_GRID_DATA][MODEL_GRIDLINE_UPDATE][nX] .Or. aDados[nY][MODEL_GRID_ID] == 0
									If (cAlias)->(FieldPos(aStruct[nX][MODEL_FIELD_IDFIELD])) > 0
										(cAlias)->(FieldPut(FieldPos(aStruct[nX][MODEL_FIELD_IDFIELD]),aDados[nY][MODEL_GRID_DATA][MODEL_GRIDLINE_VALUE][nX]))
									EndIf
								EndIf
							Next nX
							If (cAlias)->(FieldPos(PrefixoCpo(cAlias)+"_FILIAL")) > 0 .And. nOperation == MODEL_OPERATION_INSERT .And. !Empty(xFilial(cAlias))
								(cAlias)->(FieldPut(FieldPos(PrefixoCpo(cAlias)+"_FILIAL"),xFilial(cAlias)))
							EndIf
							//--------------------------------------------------------------------
							//Efetua a gravacao das chaves estrangeiras       
							//--------------------------------------------------------------------
							For nX := 1 To Len(aRelation[MODEL_RELATION_RULES])
								oModel := Nil							
								If oObjeto:GetModel():GetIdField(aRelation[MODEL_RELATION_RULES][nX][MODEL_RELATION_RULES_TARGET],@oModel) == 0
									xValue := &(aRelation[MODEL_RELATION_RULES][nX][MODEL_RELATION_RULES_TARGET])
								Else								
									xValue := oModel:GetValue(aRelation[MODEL_RELATION_RULES][nX][MODEL_RELATION_RULES_TARGET])
								EndIf
								(cAlias)->(FieldPut(FieldPos(aRelation[MODEL_RELATION_RULES][nX][MODEL_RELATION_RULES_ORIGEM]),xValue))
							Next nX
							//--------------------------------------------------------------------
							//Efetua a gravacao do modelo 2                   
							//--------------------------------------------------------------------
							If (nY <> 1 .And. cAlias == cOldAlias)
								aOldDados := oSuperObjeto:GetData()
								For nX := 1 To Len(aOldDados)
									If aOldDados[nX][MODEL_DATA_UPDATE] .Or. (nOperation == MODEL_OPERATION_INSERT)
										If (cAlias)->(FieldPos(aOldDados[nX][MODEL_DATA_IDFIELD])) > 0
											(cAlias)->(FieldPut(FieldPos(aOldDados[nX][MODEL_DATA_IDFIELD]),aOldDados[nX][MODEL_DATA_VALUE]))
										EndIf
									EndIf
								Next nX						
							EndIf
						EndIf
						//--------------------------------------------------------------------
						//Efetua a gravacao do bloco de código de pos-validação
						//--------------------------------------------------------------------
						(cAlias)->(Eval(bAfter,oObjeto,oObjeto:cID,cAlias))
					EndIf
					//--------------------------------------------------------------------
					//Seleciona o modelos em que este é proprietário.
					//--------------------------------------------------------------------
					/*If nNextOper <> 0
					For nX := 1 To Len(aModel[MODEL_STRUCT_OWNER])
					ExFormCommit(aModel[MODEL_STRUCT_OWNER][nX],bBefore,bAfter,nNextOper,oObjeto)						
					Next nX
					EndIf*/
				Next nY


				aRet	:= {.T.,""}


			ELSE

				If oObjeto:ClassName()=="FWFORMGRID"
					//--------------------------------------------------------------------
					//Efetua a gravacao da estrutura FWFORMGRID
					//--------------------------------------------------------------------
					If !Empty(cAlias)
						For nY := 1 To Len(aDados)
							lLock     := .F.
							oObjeto:GoLine(nY)
							//--------------------------------------------------------------------
							//Verifica o tipo de atualicao ( Insert ou Update )
							//--------------------------------------------------------------------
							If aDados[nY][MODEL_GRID_ID] <> 0
								(cAlias)->(MsGoto(aDados[nY][MODEL_GRID_ID]))
								RecLock(cAlias,.F.)
								lLock     := .T.
							EndIf
							If lLock
								/*
								//--------------------------------------------------------------------
								//Seleciona o modelos em que este é proprietário.
								//--------------------------------------------------------------------
								For nX := 1 To Len(aModel[MODEL_STRUCT_OWNER])
								ExFormCommit(aModel[MODEL_STRUCT_OWNER][nX],bBefore,bAfter,nNextOper,oObjeto)
								Next nX
								//--------------------------------------------------------------------
								//Executa o bloco de código de Pre-atualização
								//--------------------------------------------------------------------
								If !Empty(bBefore)
								(cAlias)->(Eval(bBefore,oObjeto,oObjeto:cID,cAlias))
								EndIf
								*/
								//--------------------------------------------------------------------
								//Efetua a gravacao dos campos                    
								//--------------------------------------------------------------------
								(cAlias)->(dbDelete())
								//--------------------------------------------------------------------
								//Efetua a gravacao do bloco de código de pos-validação
								//--------------------------------------------------------------------
								(cAlias)->(Eval(bAfter,oObjeto,oObjeto:cID,cAlias))
							EndIf
						Next nY
					EndIf	
				EndIf		


				aRet	:= {.T.,""}
			ENDIF

		ELSEIF ALLTRIM(oModCabec:ClassName())  == "FWFORMFIELDS"
			aRet[2] := "FWFORMFIELDS nao implementada." 
		ENDIF
	ENDIF


Return(aRet)



/*/{Protheus.doc} CPOCABEC
(long_description)
@author Augusto Ribeiro | www.compila.com.br
@since 12/10/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function CPOCABEC(cCampo)
	Local lRet	:= .F.

	Default cCampo	:= ""

	cCampo	:= ALLTRIM(cCampo)


	IF ASCAN(aCpoCabec, cCampo) > 0
		lRet	:= .T.
	ENDIF

Return(lRet)


/*/{Protheus.doc} ATMK03I
Rotina para selecionar arquivo
@author Jonatas Oliveira | www.compila.com.br
@since 02/04/2019
@version 1.0
/*/
User Function ATMK03I()
	Local cFile
	Local lAuto			:= .F.
	Local aArqDir		:= {}
	Local aArqFullPath	:= {} 


	nImpXml	:= Aviso("Importação Médicos"," Selecione o arquivo a ser importado. [*.csv]",{"Imp. Arquivo",  "Cancelar"},2)

	IF nImpXml == 1	                                                                                 

		cFile := cGetFile('Arquivo CSV|*.csv','Selecione arquivo',0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)
		IF !EMPTY(cFile)
			aArqFullPath	:= {cFile}
		ENDIF

	ENDIF  

	//|Importa Arquivo|
	Processa({||  U_ATMK03A(aArqFullPath) })		


	Return()
Return()

/*/{Protheus.doc} ATMK03A
Importa Arquivo
@author Jonatas Oliveira | www.compila.com.br
@since 02/04/2019
@version 1.0
/*/
User Function ATMK03A(aPathArq)
	Local cMsgErro	:= ""
	Local nTotArq, nI
	Local aArea		:= GetArea()


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


	RestArea(aArea)
Return()


/*/{Protheus.doc} ATMK03M
Efetiva cadastro de medicos
@author Jonatas Oliveira | www.compila.com.br
@since 02/04/2019
@version 1.0
/*/
User Function ATMK03M(_cLote)
	IF Aviso("Cadastro de Médicos.","Confirma a efetivação do cadastro de médicos para o lote " + _cLote + " ?",{"SIM","Cancelar"}) == 1
		Processa({|| ATMK03M(_cLote)},"Mensagem")
	
	Endif 
Return()

/*/{Protheus.doc} ATMK03M
Efetiva cadastro de medicos
@author Jonatas Oliveira | www.compila.com.br
@since 02/04/2019
@version 1.0
/*/
Static Function ATMK03M(_cLote)
	Local aRet		:= {"0", ""}
	Local lRet		:= .T.
	Local nOpcPac	:= 0 
	Local cCRM		:= ""
	Local cUFCRM	:= ""

	Local aMedicos	:= {}
	Local aContato	:= {}
	Local aEndereco := {}
	Local aTelefone := {}
	Local aAuxDados := {}
	Local nReg		:= 0 
	Local nTotLin	:= 0 


	DBSELECTAREA("ACH")
	ACH->(DbOrderNickName("XCRM")) //| ACH_FILIAL+ACH_XCRM+ACH_XCRMUF |

	DBSELECTAREA("Z15")
	Z15->(DBSETORDER(1))
	Z15->(DBGOTOP())

	IF Z15->(DBSEEK(XFILIAL("Z15") + _cLote ))
	
		WHILE Z15->(!EOF()) .AND. Z15->(Z15_FILIAL + Z15_COD) == XFILIAL("Z15") + _cLote
			nTotLin ++
			
			Z15->(DBSKIP())
		ENDDO
		
		Z15->(DBGOTOP())

		Z15->(DBSEEK(XFILIAL("Z15") + _cLote ))

		WHILE Z15->(!EOF()) .AND. Z15->(Z15_FILIAL + Z15_COD) == XFILIAL("Z15") + _cLote
			nReg ++
			IncProc("Importanto registros... "+STRZERO(nReg,6)+" de "+STRZERO(nTotLin,6))

			IF Z15->Z15_STATUS <> "2"
			
				aMedicos	:= {}
				aContato	:= {}
				aEndereco 	:= {}
				aTelefone 	:= {}
				aAuxDados 	:= {}
			
				cCRM	:= PADR(FwNoAccent(ALLTRIM(Z15->Z15_XCRM)), TAMSX3("ACH_XCRM")[1])
				cUFCRM	:= PADR(FwNoAccent(ALLTRIM(Z15->Z15_XCRMUF)), TAMSX3("ACH_XCRMUF")[1])

				IF ACH->(DBSEEK(XFILIAL("ACH") + cCRM + cUFCRM))
					aRet[1] := "-1"
					aRet[2]	:= "CRM já cadastrado."
				ELSE
					AAdd(aMedicos ,{"ACH_LOJA"	, "0001"				, .F.} )
					AAdd(aMedicos ,{"ACH_FILIAL"	, XFILIAL("ACH")	, .F.} )

					nOpcPac := 3 //|INSERT|
					INCLUI	:= .T.
					ALTER	:= .F.


					/*--------------------------
					MEDICO
					---------------------------*/				
					AAdd(aMedicos ,{"ACH_XCRM"		, ALLTRIM(Z15->Z15_XCRM)									, .F.} )
					AAdd(aMedicos ,{"ACH_XCRMUF"	, ALLTRIM(Z15->Z15_XCRMUF)									, .F.} )
					AADD(aMedicos, {"ACH_CGC"		, ALLTRIM(Z15->Z15_CGC)										, .F.} )
					AADD(aMedicos, {"ACH_RAZAO "	, FwNoAccent(ALLTRIM(EncodeUtf8(Z15->Z15_RAZAO)))			, .F.} )
					AADD(aMedicos, {"ACH_END"		, FwNoAccent(ALLTRIM(Z15->Z15_END))							, .F.} )
					AADD(aMedicos, {"ACH_XCOMPL"	, FwNoAccent(ALLTRIM(Z15->Z15_XCOMPL))						, .F.} )
					AADD(aMedicos, {"ACH_EST"		, ALLTRIM(Z15->Z15_EST)										, .F.} )
					AADD(aMedicos, {"ACH_CODMUN"	, ALLTRIM(Z15->Z15_CODMUN)									, .F.} )
					AADD(aMedicos, {"ACH_BAIRRO"	, FwNoAccent(ALLTRIM(Z15->Z15_BAIRRO))						, .F.} )
					AADD(aMedicos, {"ACH_CIDADE"	, FwNoAccent(ALLTRIM(Z15->Z15_CIDADE))						, .F.} )
					AAdd(aMedicos, {"ACH_CEP"		, ALLTRIM(Z15->Z15_CEP)										, Nil} )
					AADD(aMedicos, {"ACH_DDI"		, "55"														, .F.} )
					AADD(aMedicos, {"ACH_DDD"		, ALLTRIM(Z15->Z15_DDD)										, .F.} )
					AADD(aMedicos, {"ACH_TEL"		, ALLTRIM(Z15->Z15_TEL)										, .F.} )
					AADD(aMedicos, {"ACH_EMAIL"		, ALLTRIM(Z15->Z15_EMAIL)									, .F.} )
					AADD(aMedicos, {"ACH_XNIVER"	, CTOD(ALLTRIM(Z15->Z15_XNIVER))							, .F.} )
					AADD(aMedicos, {"ACH_XESP01"	, FwNoAccent(ALLTRIM(Z15->Z15_XESP01))						, .F.} )
					AADD(aMedicos, {"ACH_XCONSE"	, ALLTRIM(Z15->Z15_XCONSE)									, .F.} )
					AADD(aMedicos, {"ACH_SEGMEN"	, ALLTRIM(Z15->Z15_SEGMEN)									, .F.} )


					/*--------------------------
					CONTATO
					---------------------------*/
					AAdd(aContato ,{"U5_FILIAL"		, xFilial("SU5")							, Nil} )
					AAdd(aContato ,{"U5_CONTAT"		, FwNoAccent(ALLTRIM(Z15->Z15_RAZAO))		, Nil} )
					AAdd(aContato ,{"U5_XCRM"		, ALLTRIM(Z15->Z15_XCRM)					, Nil} )
					AAdd(aContato ,{"U5_XCRMUF"		, ALLTRIM(Z15->Z15_XCRMUF)					, Nil} )				
					AADD(aContato, {"U5_BAIRRO"		, FwNoAccent(ALLTRIM(Z15->Z15_BAIRRO))		, Nil} )
					AADD(aContato, {"U5_CPF"		, ALLTRIM(Z15->Z15_CGC)						, Nil} )
					AADD(aContato, {"U5_DDD"		, ALLTRIM(Z15->Z15_DDD)						, Nil} )
					AADD(aContato, {"U5_EMAIL"		, ALLTRIM(Z15->Z15_EMAIL)					, Nil} )
					AADD(aContato, {"U5_END"		, FwNoAccent(ALLTRIM(Z15->Z15_END))			, Nil} )
					AADD(aContato, {"U5_FONE"		, ALLTRIM(Z15->Z15_TEL)						, Nil} )
					AADD(aContato, {"U5_MUN"		, FwNoAccent(ALLTRIM(Z15->Z15_CIDADE))		, Nil} )
					AADD(aContato, {"U5_XNIVER"		, CTOD(ALLTRIM(Z15->Z15_XNIVER))			, Nil} )
					AADD(aContato, {"U5_XCOMPL"		, FwNoAccent(ALLTRIM(Z15->Z15_XCOMPL))		, Nil} )
					AADD(aContato, {"U5_XESP01"		, FwNoAccent(ALLTRIM(Z15->Z15_XESP01))		, Nil} )

					AAdd(aAuxDados, {"AGB_TIPO"		, "1"						, Nil})
					AAdd(aAuxDados, {"AGB_PADRAO"	, "1"						, Nil})
					AAdd(aAuxDados, {"AGB_DDI"		, "55"						, Nil})
					AAdd(aAuxDados, {"AGB_DDD"		, ALLTRIM(Z15->Z15_DDD)		, Nil})
					AAdd(aAuxDados, {"AGB_TELEFO"	, ALLTRIM(Z15->Z15_TEL)		, Nil})

					AAdd(aTelefone, aAuxDados)

					aAuxDados := {}

					AAdd(aAuxDados, {"AGA_TIPO"		, "1"										, Nil})
					AAdd(aAuxDados, {"AGA_PADRAO"	, "1"										, Nil})
					AAdd(aAuxDados, {"AGA_END"		, FwNoAccent(ALLTRIM(Z15->Z15_END))			, Nil})
					AAdd(aAuxDados, {"AGA_CEP"		, ALLTRIM(Z15->Z15_CEP)						, Nil})
					AAdd(aAuxDados, {"AGA_BAIRRO"	, FwNoAccent(ALLTRIM(Z15->Z15_BAIRRO))		, Nil})
					AAdd(aAuxDados, {"AGA_MUNDES"	, FwNoAccent(ALLTRIM(Z15->Z15_CIDADE))		, Nil})
					AAdd(aAuxDados, {"AGA_EST"		, ALLTRIM(Z15->Z15_EST)						, Nil})

					AAdd(aEndereco, aAuxDados)

					aRet := U_AFAT003(aMedicos, nOpcPac)

				ENDIF 

				IF aRet[1] == "0"
					cChvMed	:= aRet[2]				

					DBSELECTAREA("SU5")
					SU5->(DbOrderNickName("SU5U5E")) // U5_FILIAL+U5_XCRM+U5_XCRMUF  
					// SU5U5E    
					// U5_FILIAL+U5_XCRM+U5_XCRMUF                                                                                                                                     

					cCRM	:= PADR(ALLTRIM(cCRM), TAMSX3("U5_XCRM")[1])
					cUFCRM	:= PADR(ALLTRIM(cUFCRM), TAMSX3("U5_XCRMUF")[1])

					IF SU5->(DBSEEK(XFILIAL("SU5") + cCRM + cUFCRM ))
						nOpcPac := 4 //|UPDATE|
					ELSE
						nOpcPac := 3 //|INSERT|
					ENDIF 	

					aRet := U_AFAT03C(aContato,aEndereco,aTelefone, nOpcPac)

					IF aRet[1] == "0"
						/*------------------------------------------------------ Augusto Ribeiro | 13/09/2017 - 4:16:43 PM
						Vincula Paciente ao Contato
						------------------------------------------------------------------------------------------*/
						IF nOpcPac == 3

							DBSELECTAREA("AC8")
							RECLOCK("AC8",.T.)
								AC8->AC8_ENTIDA := "ACH"
								AC8->AC8_CODENT	:= cChvMed
								AC8->AC8_CODCON	:= SU5->U5_CODCONT
							MSUNLOCK()

						ENDIF

						Z15->(RecLock("Z15",.F.))
						Z15->Z15_STATUS := "2"				
						Z15->(MsUnLock())		

					ELSE

						Z15->(RecLock("Z15",.F.))
							Z15->Z15_STATUS := "3"	
							Z15->Z15_LOG	:= aRet[2]	
						Z15->(MsUnLock())		
						
					ENDIF 				

				ELSE
					Z15->(RecLock("Z15",.F.))
						Z15->Z15_STATUS := "3"	
						Z15->Z15_LOG	:= aRet[2]				
					Z15->(MsUnLock())								
						
				ENDIF 
			ENDIF 

			Z15->(DBSKIP())
		ENDDO	
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
	
	Local nX3CAMPO   := SX3->(FIELDPOS("X3_CAMPO"))
	Local nX3TIPO	 := SX3->(FIELDPOS("X3_TIPO"))
	Local nX3TAMANHO := SX3->(FIELDPOS("X3_TAMANHO"))


	Private aCabecArq := {}
	Private nCabecArq := {}

	Private aCabecF := {}
	Private nCabecF := {}

	Private nItem	:= 0 
	Private _cLote	:= ""


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

				_cLote := GetSx8Num("Z15", "Z15_COD")
				ConfirmSX8()
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
								xVarCpo	:= PADR(ALLTRIM(aLinha[nI]),aCabecX3[nI,3]) 
							ELSEIF aCabecX3[nI,2] == "N"
								xVarCpo	:= VAL(aLinha[nI])
							ELSEIF aCabecX3[nI,2] == "D"
								xVarCpo	:= STOD(aLinha[nI])
							ENDIF

							aaDD(aDados, {aCabecArq[nI], xVarCpo, nil})

						NEXT nI

						nItem ++ 


						//| CHAMA ROTINA DE IMPORTACAO |
						aRetAux	:= U_ATMK03X(cAliasImp,aDados,.F., nItem, cPathFull)

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


/*/{Protheus.doc} ATMK03X
Processa importação do arquivo
@author Jonatas Oliveira | www.compila.com.br
@since 02/04/2019
@version 1.0
/*/
User Function ATMK03X(_cAliasT,aDados,lAltera, nItZ15, cPathAr)
	Local aRet		:= {.T., ""}
	Local nPosCrm	:= 0 
	Local nPosUfC	:= 0
	Local aDePara	:= {}
	Local nI		:= 0 
	Local nY		:= 0 

	AADD(aDePara,{"Z15_XCRM"	  , "ACH_XCRM"		 })
	AADD(aDePara,{"Z15_XCRMUF"    , "ACH_XCRMUF"      })
	AADD(aDePara,{"Z15_CGC"       , "ACH_CGC"        })
	AADD(aDePara,{"Z15_RAZAO"     , "ACH_RAZAO"      })
	AADD(aDePara,{"Z15_END"       , "ACH_END"        })
	AADD(aDePara,{"Z15_XCOMPL"    , "ACH_XCOMPL"     })
	AADD(aDePara,{"Z15_EST"       , "ACH_EST"        })
	AADD(aDePara,{"Z15_CODMUN"    , "ACH_CODMUN"     })
	AADD(aDePara,{"Z15_BAIRRO"    , "ACH_BAIRRO"     })
	AADD(aDePara,{"Z15_CIDADE"    , "ACH_CIDADE"     })
	AADD(aDePara,{"Z15_CEP"       , "ACH_CEP"        })
	AADD(aDePara,{"Z15_DDI"       , "ACH_DDI"        })
	AADD(aDePara,{"Z15_DDD"       , "ACH_DDD"        })
	AADD(aDePara,{"Z15_TEL"       , "ACH_TEL"        })
	AADD(aDePara,{"Z15_EMAIL"     , "ACH_EMAIL"      })
	AADD(aDePara,{"Z15_XNIVER"    , "ACH_XNIVER"     })
	AADD(aDePara,{"Z15_XESP01"    , "ACH_XESP01"     })
	AADD(aDePara,{"Z15_XCONSE"    , "ACH_XCONSE"     })
	AADD(aDePara,{"Z15_CODSEG"    , "ACH_CODSEG"     })


	nPosCrm 	:= aScan( aDados , { |x| AllTrim(x[01]) == "ACH_XCRM"		})
	nPosUfC 	:= aScan( aDados , { |x| AllTrim(x[01]) == "ACH_XCRMUF"		})


	IF nPosCrm > 0 .AND. nPosUfC > 0 
		cChave	:= ALLTRIM( aDados[nPosCrm][2]) + SPACE( TAMSX3("ACH_XCRM")[1] - LEN( ALLTRIM( aDados[nPosCrm][2])) ) + ALLTRIM(aDados[nPosUfC][2])		
	ELSE
		aRet[1]	:= .F.
		aRet[2]	:= "Chave Principal não localizada [ACH]->[ACH_XCRM][ACH_XCRMUF]"
	ENDIF 

	IF aRet[1]
		DBSELECTAREA("Z15")
		Z15->(DBSETORDER(2))
		IF Z15->(DBSEEK(cChave))
			aRet[1]	:= .F.
			aRet[2]	:= "Chave já existente"
		ENDIF 
	ENDIF 

	If aRet[1]

		DBSELECTAREA("Z15")
		Z15->(DBSETORDER(1))

		nTotCpo	:= Z15->(FCount())

		RegToMemory("Z15",.T.)

		M->Z15_COD 		:= _cLote
		M->Z15_ITEM		:= STRZERO(nItZ15,TAMSX3("Z15_ITEM")[1])
		M->Z15_DATA     := DDATABASE
		M->Z15_ARQ      := cPathAr
		M->Z15_USER     := ALLTRIM(UsrRetName(__CUSERID))
		M->Z15_STATUS   := "1"

		For nY := 1 To Len(aDados)
			nPosAux := 0 
			nPosAux := aScan( aDePara , { |x| AllTrim(x[02]) == aDados[nY][1] })

			IF nPosAux > 0 
				M->&(aDePara[nY][1]) := aDados[nY][2]
			ENDIF 

		Next nY

		RECLOCK("Z15",.T.)

		For nI := 1 To nTotCpo
			FieldPut(nI, M->&(FIELDNAME(nI)) )
		Next nI

		MSUNLOCK()
		CONFIRMSX8()

	Endif 


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