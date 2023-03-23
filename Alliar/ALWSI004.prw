#INCLUDE "ALWSI004.CH"

Static cMsgLog := '' //|""
//-------------------------------------------------------------------
/*{Protheus.doc} ALWSI004
Funcao Generica para Compilacao

@author Guilherme Santos
@since 06/09/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALWSI004()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} wsIntegracaoSenior
Web Service de Integracao Protheus x Senior

@author Guilherme Santos
@since 06/09/2016
@version P12
*/
//-------------------------------------------------------------------
WSSERVICE wsIntegracaoSenior 	Description "Integração Protheus x Senior v2"
	WsData sCNPJ				as String
	WsData sUser				as String
	WsData sPassword			as String
	WsData sOperation			as String
	WsData sIDTran				as String
	WsData sReturn				as String
	WSData aInDataInt			as InDataInt
	WSData Contab				as CtbItemAux

	WsMethod TituloPagar		Description "Integração Titulo a Pagar"
	WsMethod Contabiliza		Description "Integração Contabilização"
EndWSService
//-------------------------------------------------------------------
/*{Protheus.doc} TituloPagar
Manutencao de Titulo a Pagar

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
WSMethod TituloPagar WSReceive sCNPJ, sUser, sPassword, sOperation, aInDataInt WsSend sReturn WSService wsIntegracaoSenior
	Local nTrans		:= 0
	Local nI			:= 0
	Local nJ			:= 0
	Local nK			:= 0

	Local lReturn		:= .T.

	Local oTitulo		:= NIL

	Local cCampo		:= ""
	Local xValor		:= ""

	Local nOpcao		:= 3
	
	Local nX3TIPO 		:= SX3->(FIELDPOS("X3_TIPO"))
	Local nX3TAMANHO 	:= SX3->(FIELDPOS("X3_TAMANHO"))

	Private INCLUI		:= .T.

	//RpcSetEnv("01", "00101MG0001", NIL, NIL, "FIN", NIL, {})
	RpcSetEnv("01", "01", NIL, NIL, "FIN", NIL, {})

	Console("Preparando Ambiente para Gravacao do Titulo - CNPJ Filial: " + ::sCNPJ, .F., .T.)

	If VldEmpFil(::sCNPJ)

		Console("Validando Usuario", .F., .T.)

		If VldUser(::sUser, ::sPassword)

			Console("Usuario Valido.", .F., .T.)

			If Empty(::aInDataInt) .OR. !::sOperation $ "INSERT|DELETE"
				::sReturn		:= "Dados invalidos"
				lReturn 		:= .F.
			Else
				Console("Validando ID Senior", .F., .T.)
				
				Do Case
				Case ::sOperation == "INSERT"
					nOpcao := 3
				Case ::sOperation == "DELETE"
					nOpcao := 5
				EndCase

				Console("Verificando dados recebidos para Integracao", .F., .T.)

				nTrans := Len(::aInDataInt:NewInInt)

				Console("Quantidade de Campos Recebidos: " + StrZero(nTrans, 3), .F., .T.)

				If nTrans > 0

					Console("Inicializando o Objeto para gravacao dos Titulos.", .F., .T.)

					oTitulo := uTitPagar():New()

					oTitulo:AddValues("EMPRESA"		, cEmpAnt)
					oTitulo:AddValues("E2_FILIAL"	, xFilial("SE2"))
					
					 
					 /*------------------------------------------------------ Augusto Ribeiro | 24/02/2017 - 9:57:01 AM
					 Realiza De - Para do Cadastro de Fornecedor
					 ------------------------------------------------------------------------------------------*/
					 //nPosCli := aScan(::aInDataInt:NewInInt, { |x| AllTrim(x[1]) == "E2_FORNECE" })  
					 //nPosLoja := aScan(::aInDataInt:NewInInt, { |x| AllTrim(x[1]) == "E2_LOJA" })
					 
					 cCodFor	:= ""
					 cLojaFor	:= ""
					 For nI := 1 to Len(::aInDataInt:NewInInt)
						cCampo	:= ::aInDataInt:NewInInt[nI]:cCpoInt
						xValor	:= ::aInDataInt:NewInInt[nI]:xVlrInt
						IF ALLTRIM(cCampo) == "E2_FORNECE"
							cCodFor	:= xValor
						ELSEIF ALLTRIM(cCampo) == "E2_LOJA"
							cLojaFor	:= xValor
						ENDIF 
					NEXT nI 
					 
					 IF !empty(cCodFor) .and. !empty(cLojaFor)
					 
						 DBSELECTAREA("SA2")
						 //SA2->(DbOrderNickName("CODALLIAR")) //|						 
						 SA2->(dbSetOrder(1))
						 IF SA2->(DBSEEK(xfilial("SA2")+cCodFor+cLojaFor  )) 
						 	oTitulo:AddValues("E2_FORNECE", SA2->A2_COD )
						 	oTitulo:AddValues("E2_LOJA",  SA2->A2_LOJA )		
						 	
							 
							Console("Adicionando dados do Titulo", .F., .T.)
		
							DbSelectArea("SX3")
							DbSetOrder(2)		//X3_CAMPO
							
							For nI := 1 to Len(::aInDataInt:NewInInt)
								cCampo		:= ::aInDataInt:NewInInt[nI]:cCpoInt
								IF ALLTRIM(cCampo) == "E2_FORNECE" .OR. ALLTRIM(cCampo) == "E2_LOJA"
									LOOP
								ENDIF
								
								cCampo		:= cCampo + Space(10 - Len(cCampo))
								xValor		:= alltrim(::aInDataInt:NewInInt[nI]:xVlrInt)
		
								Console("Campo: " + cCampo + "|xValor: " + xValor + "|", .F., .T.)
		
								If SX3->(DbSeek(cCampo))
									Do Case
										Case SX3->(FIELDGET(nX3TIPO)) == "N"
										xValor := Val(xValor)
										Case SX3->(FIELDGET(nX3TIPO)) == "D"
										xValor := CtoD(xValor)
										Case SX3->(FIELDGET(nX3TIPO)) == "C"
										IF EMPTY(xValor)
											LOOP
										ENDIF
										xValor := xValor + Space(SX3->(FIELDGET(nX3TAMANHO)) - Len(xValor))
									EndCase
								EndIf
								
								oTitulo:AddValues(cCampo, xValor)
							Next nI
		
							Console("Inicio da Gravacao do Titulo", .F., .T.)
		
							If oTitulo:Gravacao(nOpcao)
								::sReturn := oTitulo:GetPrefixo() + oTitulo:GetTitulo() + oTitulo:GetParcela() + oTitulo:GetTipo() + oTitulo:GetFornece() + oTitulo:GetLoja()
								Console(::sReturn, .F., .T.)
							Else
								::sReturn		:= "Erro na Gravacao do Titulo." + CRLF
								::sReturn		:= oTitulo:GetMensagem()
								lReturn 		:= .F.
								Console(::sReturn, .F., .T.)
							EndIf
					
		 		
		 				 else
							::sReturn := "Fornecedor nao localizado. "
							lReturn := .F.	
						 ENDIF
					else
						::sReturn := "Codigo ou Loja do Fornecedor esta vazio."
						lReturn := .F.							
					 ENDIF	
				
				EndIf

				FreeObj(oTitulo)
			EndIf
		Else
			::sReturn := "Usuario ou senha invalidos."
			lReturn := .F.
		EndIf
	Else
		::sReturn := "Empresa ou Filial invalidas."
		lReturn := .F.
	EndIf

	If !lReturn
		Console(::sReturn, .F., .T.)
		SetSoapFault(XNOMEPROG, ::sReturn)
	EndIf

	Console("TituloPagar", .T., .T.)

Return lReturn
//-------------------------------------------------------------------
/*{Protheus.doc} Contabiliza
Metodo para Integração da Contabilização

@author Guilherme Santos
@since 23/09/2016
@version P12
*/
//-------------------------------------------------------------------
WSMethod Contabiliza WSReceive sCNPJ, sUser, sPassword, sOperation, sIDTran, Contab WsSend sReturn WSService wsIntegracaoSenior
Local nTrans		:= 0
Local nI			:= 0
Local nJ			:= 0
Local nK			:= 0
Local nY			:= 0
LOCAL aItensWS	:= ::Contab:CtbItens
Local lReturn		:= .T.

Local cCampo		:= ""
Local xValor		:= ""

Local cMsgErro		:= ""

Local nOpcao		:= 0

Local cIdSenior	:= ""
Local cLogSenior	:= alltrim(GetMV("ES_CTBSENI",.F.,"")) //| Log de integraçao contabilizacao Senior. LOG=Grava log e processa chamada. ONLY_LOG=Somente grava loge NAO PROCESSA chamada -> teste


Local aCabec, aItens,  aLinha, cIDSen
Local nIDTRAN		:=  TamSX3("ZD_IDTRAN")[1]
Local nIDSEN		:= 	TamSX3("ZC_IDSEN")[1]
Local nObriga, aObriga	:= {}
Local aSZCSX3		:= {}

Local nHSemaf	:= 0
Local cSemaf		:= "alwsi004_ctb"

Local cLote		:= ""

Local nX3TIPO 		:= SX3->(FIELDPOS("X3_TIPO"))
Local nX3ARQUIVO 	:= SX3->(FIELDPOS("X3_ARQUIVO"))
Local nX3CAMPO 		:= SX3->(FIELDPOS("X3_CAMPO"))

/*---------------------------------------------------------------------
	FILA INTEGRADOR PROTHEUS - OBJETIVO É GERAR LOG DAS CHAMADAS
---------------------------------------------------------------------*/
IF cLogSenior == "LOG" .OR. cLogSenior == "ONLY_LOG"
	U_CP12ADD("000004", "SZC", 2, HttpOtherContent(), )
	IF cLogSenior == "ONLY_LOG"
		::sReturn	:= "Log gravado com sucesso."
		Return .T.
	ENDIF
ENDIF

/*--------------------------
	Campos obrigatórios
---------------------------*/
aadd(aObriga, "ZC_IDSEN")
aadd(aObriga, "ZC_DTLANC")
aadd(aObriga, "ZC_TIPO")
aadd(aObriga, "ZC_VALOR")

nObriga	:= LEN(aObriga)


/*--------------------------
	Busca SX3 SZC 
---------------------------*/
DbSelectArea("SX3")
DbSetOrder(1)		//X3_ARQUIVO 					
If SX3->(DbSeek("SZC"))	
	
	WHILE SX3->(!EOF()) .AND. SX3->(FIELDGET(nX3ARQUIVO)) == "SZC"
	
		AADD(aSZCSX3, {ALLTRIM(SX3->(FIELDGET(nX3CAMPO))), (FIELDGET(nX3TIPO))})
	
		SX3->(dbskip())
	ENDDO
EndIf
	

CONOUT("wsIntegracaoSenior Contabiliza ["+::sIDTran+"] | INICIO "+dtoc(dDataBase)+" "+time())

::sIDTran	:= ALLTRIM(::sIDTran)
cIdTran		:= PADR(::sIDTran, nIDTRAN)
If VldEmpFil(::sCNPJ)
	If VldUser(::sUser, ::sPassword)

		If Empty(::Contab) .OR. !(::sOperation $ "INSERT|DELETE") 
			::sReturn		:= "Dados invalidos"
			lReturn 		:= .F.
		Else
			
			/*------------------------------------------------------ Augusto Ribeiro | 22/03/2017 - 10:16:35 PM
				ABRE semaforo de processamento para evitar LOOp ENTRE INTEGRACAO DO FLUIG
			------------------------------------------------------------------------------------------*/
			cSemaf		:= cSemaf+alltrim(cIdTran)+ALLTRIM(::sCNPJ)+".lck"
			nHSemaf		:= U_CPXSEMAF("A", cSemaf, nHSemaf)	
			
			
			IF nHSemaf > 0
			
				//| Quantidade de Registros |				
				nQtdReg		:= Len(aItensWS)
				
	
				If nQtdReg > 0
					
					/*------------------------------------------------------ Augusto Ribeiro | 15/01/2018 - 6:10:03 PM
						Validações básicas de cabecalho
					------------------------------------------------------------------------------------------*/
					DbSelectArea("SZD")
					DbSetOrder(1)	//ZD_FILIAL, ZD_IDTRAN					
					If ::sOperation == "INSERT"
						nOpcao := MODEL_OPERATION_INSERT
						
						If SZD->(DbSeek(xFilial("SZD")+cIdTran))
							cMsgErro	:= "Registro já existe STATUS ["+alltrim(X3COMBO("ZD_STATUS", SZD->ZD_STATUS ))+"]"+CRLF
						ENDIF
						
					ELSEIF ::sOperation == "DELETE"				
						nOpcao := MODEL_OPERATION_DELETE
						
						If SZD->(DbSeek(xFilial("SZD")+cIdTran))
							IF SZD->ZD_STATUS == "2"
								cMsgErro	:= "Exclusão permitida STATUS ["+alltrim(X3COMBO("ZD_STATUS", SZD->ZD_STATUS ))+"]"+CRLF
							ENDIF
						ENDIF
					ENDIF
					
					
					
					IF EMPTY(cMsgErro)
					
						IF nOpcao == MODEL_OPERATION_INSERT
					
							aCabec	:= {}
							aItens	:= {}
													
							
							aadd(aCabec, {"ZD_FILIAL", XFILIAL("SZD")})
							aadd(aCabec, {"ZD_IDTRAN", cIdTran})
							aadd(aCabec, {"ZD_STATUS", "1"})
							aadd(aCabec, {"ZD_DTINC", dDatabase})
							aadd(aCabec, {"ZD_HRINC", Time()})
							aadd(aCabec, {"ZD_SISTEMA", "1"})
							
							//Busca lote contabil
							SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
							If SX5->(MsSeek(xFilial("SX5") + "09SEN"))
								cLote := AllTrim(X5Descri())
							Else
								cLote := "SEN "
							EndIf		
			
							//Executa um execblock			
							If At(UPPER("EXEC"),X5Descri()) > 0 .OR. At(Upper("U_"),SX5->(FIELDGET(FIELDPOS("X5_DESCRI")))) > 0
								cLote	:= &(X5Descri())
							EndIf
							
							AADD(aCabec, {"ZD_LOTE", cLote })
							
							FOR nI := 1 to nQtdReg						
							
								cIDSen	:= ""
								aLinha	:= {}
										
								AADD(aLinha, {"ZC_FILIAL", XFILIAL("SZC")})
								AADD(aLinha, {"ZC_IDTRAN", cIdTran})	
								AADD(aLinha, {"ZC_STATUS", "1"})	
								
								
								
								nTotCpo	:= Len(aItensWS[nI]:IT2)					
								
								FOR nY := 1 to nTotCpo
									
									cCampo		:= UPPER(alltrim(aItensWS[nI]:IT2[nY]:CPN))
									xValor		:= ALLTRIM(aItensWS[nI]:IT2[nY]:CPV)
									
									
									
									//| Busca informações do SX3 |
									nPosAux	:= aScan(aSZCSX3, { |x| AllTrim(x[1]) == cCampo })  
									IF nPosAux > 0
		    							Do Case
		    								Case aSZCSX3[nPosAux,2] == "N"
		    									xValor := Val(xValor)
		    								Case aSZCSX3[nPosAux, 2] == "D"
		    									xValor := CtoD(xValor)
		    							EndCase
		    						EndIf
		    						
		    						IF !EMPTY(xValor)
		    						
		    							/*--------------------------
		    								Adiciona registro na Linha
		    							---------------------------*/
		        						AADD(aLinha, {cCampo, xValor})
		        						
		        						IF cCampo == "ZC_IDSEN"
		        							cIDSen	:= xValor
		        						ENDIF
		        					ENDIF
								NEXT nY	
								
								/*------------------------------------------------------ Augusto Ribeiro | 15/01/2018 - 6:48:31 PM
									Valida se Registro já existe
								------------------------------------------------------------------------------------------*/
								IF !EMPTY(cIDSen)
									DbSelectArea("SZC")
									DbSetOrder(1)		//ZC_FILIAL, ZC_IDTRAN, ZC_IDSEN
									
									IF SZC->(DbSeek(xFilial("SZC")+cIdTran+PADR(cIDSen,nIDSEN) ))
										IF nOpcao == MODEL_OPERATION_INSERT
											cMsgErro	:=  "["+cIDSen+"] Registro informado já existe."+CRLF
										ENDIF
									ENDIF
									
									/*------------------------------------------------------ Augusto Ribeiro | 15/01/2018 - 6:48:31 PM
										Verifica se campos básicos foram informados
									------------------------------------------------------------------------------------------*/
									FOR nY := 1 to nObriga
										nPosAux	:= aScan(aLinha, { |x| AllTrim(x[1]) == aObriga[nY] })
										IF nPosAux	> 0
											IF EMPTY(aLinha[nPosAux,2])
												cMsgErro	:= "["+cIDSen+"] Campo Obrigatorio vazio ["+aObriga[nY]+"]"+CRLF
											ENDIF
										ELSE
											cMsgErro	:= "["+cIDSen+"] Campo Obrigatorio vazio ou nao informado ["+aObriga[nY]+"]"+CRLF									
										ENDIF
									NEXT nY
								ELSE
									cMsgErro	+= "[ZC_IDSEN] Vazio."+CRLF 
								ENDIF
															
								
								/*----------------------------------
									Adiciona Linhas aos Itens
								-----------------------------------*/
								aadd(aItens, aLinha)													
							NEXT nI
						ENDIF
						
						
						/*--------------------------------------------
							Realiza a Gração dos Registros
						---------------------------------------------*/
						IF EMPTY(cMsgErro)
							
							/*--------------------------
								INCLUSAO
							---------------------------*/
							IF nOpcao == MODEL_OPERATION_INSERT
							
								BEGIN TRANSACTION 
									//| Cabec
									DBSELECTAREA("SZD")
									RECLOCK("SZD",.T.)
										FOR nI := 1 to len(aCabec)
											FIELDPUT(FIELDPOS(aCabec[nI,1]), aCabec[nI,2])									
										NEXT nI
									MSUNLOCK()
									
									// Itens
									DBSELECTAREA("SZC")
									FOR nI := 1 to len(aItens)
										RECLOCK("SZC",.T.)									
											FOR nY := 1 to len(aItens[nI])
												FIELDPUT(FIELDPOS(aItens[nI,nY,1]), aItens[nI,nY,2] )
											NEXT nY									
										MSUNLOCK()	
									NEXT nI							
								END TRANSACTION
							
							/*--------------------------
								EXCLUSAO
							---------------------------*/							
							ELSEIF nOpcao == MODEL_OPERATION_DELETE
							
							
								DbSelectArea("SZD")
								DbSetOrder(1)	//ZD_FILIAL, ZD_IDTRAN		
								If SZD->(DbSeek(xFilial("SZD")+cIdTran))
									IF SZD->ZD_STATUS == "1" //| PENDENTE |
										
										BEGIN TRANSACTION
										
										DbSelectArea("SZC")
										DbSetOrder(1)		
										If SZC->(DbSeek(xFilial("SZC")+SZD->ZD_IDTRAN))		
										
											WHILE SZC->(!EOF()) .AND. SZC->ZC_IDTRAN == SZD->ZD_IDTRAN
												
												RECLOCK("SZC",.F.)
													SZC->(DBDELETE())
												MSUNLOCK()
											
												SZC->(DBSKIP())
											ENDDO											
										ENDIF
										
										RECLOCK("SZD",.F.)
											SZD->(DBDELETE())
										MSUNLOCK()	
										
										
										END TRANSACTION									
									ENDIF
								ELSE
									cMsgErro := "Registro nao localizado."
								ENDIF							
							
							ENDIF
						ENDIF					
					ENDIF
					
					/*------------------------------------------------------ Augusto Ribeiro | 22/03/2017 - 10:16:35 PM
					FECHA semaforo de processamento para evitar LOOp ENTRE INTEGRACAO DO FLUIG
					------------------------------------------------------------------------------------------*/		
					U_CPXSEMAF("F", cSemaf, nHSemaf)		
					
				ELSE
					cMsgErro := "Já existou processo em execucao sobre o IDTransacao ["+cIdTran+"]"
				ENDIF
				
			ELSEIF nOpcao <> MODEL_OPERATION_DELETE
				cMsgErro	:= "Nenhum item foi informado."
			EndIf
		EndIf
	Else
		cMsgErro := "Usuario ou senha invalidos."
	EndIf
Else
	cMsgErro := "Empresa ou Filial invalidas."
EndIf

If empty(cMsgErro)
	::sReturn := "Sucesso."
else
	lReturn := .F.
	::sReturn := cMsgErro
	Console(::sReturn, .F., .T.)
	SetSoapFault(XNOMEPROG, ::sReturn)
EndIf


// Remove objeto da memoria //
FreeObj(self:Contab)


CONOUT("wsIntegracaoSenior Contabiliza ["+::sIDTran+"]  | FIM "+dtoc(dDataBase)+" "+time())

Return lReturn

//-------------------------------------------------------------------
/*{Protheus.doc} VldEmpFil
Valida a Filial Informada

@author Guilherme Santos
@since 06/09/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function VldEmpFil(cCNPJ)
	Local lReturn := .F.

	DbSelectArea("SM0")
	DbSetOrder(1)		//M0_CODIGO, M0_CODFIL

	SM0->(DbGoTop())

	While !SM0->(Eof())

		If cCNPJ == SM0->M0_CGC
			lReturn := .T.
			cEmpAnt := SM0->M0_CODIGO
			cFilAnt := SM0->M0_CODFIL
			Exit
		EndIf

		SM0->(DbSkip())
	End

Return lReturn
//-------------------------------------------------------------------
/*{Protheus.doc} VldUser
Validacao do Usuario e Senha

@author Guilherme Santos
@since 06/09/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function VldUser(cUsuario, cPassword)
	Local lReturn	:= .T.

	PswOrder(2)

	//Verifica se o usuario é valido
	If !PswSeek(cUsuario, .T.)
		lReturn := .F.
	Else
		//Verifica se a senha é valida para o usuário
		If !PswName(cPassword)
			lReturn := .F.
		Endif
	Endif			

Return lReturn	
//-------------------------------------------------------------------
/*{Protheus.doc} Console
Grava o Texto no Console do AppServer

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Static Function Console(cTexto, lGrava, lNewLog)
	Default lGrava 	:= .F.
	Default lNewLog	:= .F.

//	If lNewLog
//		cMsgLog += XNOMEPROG + " - " + DtoC(Date()) + " - " + Time() + " - " + cTexto + CRLF
//
//		If lGrava
//			MemoWrite("ALWSI001_" + cTexto + "_" + DtoS(dDatabase) + "_" + StrTran(Time(), ":", "") + ".LOG", cMsgLog)
//			cMsgLog := ""
//		EndIf		
//	Else
		ConOut(XNOMEPROG + " - " + DtoC(Date()) + " - " + Time() + " - " + cTexto)
//	EndIf

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} GETXERR
Retorna a Mensagem de Erro do Model

@author Guilherme.Santos
@since 14/08/2015
@version P12
@param oModMsg, Objeto, Objeto de onde sera Retornada a Mensagem de Erro
@return cRetorno, Caracter, Mensagem de Erro do Objeto
*/
//-------------------------------------------------------------------
Static Function GETXERR(oModMsg)
	Local aMsgErro 	:= oModMsg:GetErrorMessage()
	Local cRetorno 	:= ""
	Local nI			:= 0

	For nI := 1 to Len(aMsgErro)
		Do Case
			Case ValType(aMsgErro[nI]) == "C"
			cRetorno += aMsgErro[nI] + Space(1)
			Case ValType(aMsgErro[nI]) == "N"
			cRetorno += AllTrim(Str(aMsgErro[nI])) + Space(1)
		EndCase
	Next nI

Return cRetorno


/*
-----------------------------------------------------------------------------------------------------
Colecao de Campos do Titulo para Integracao
-----------------------------------------------------------------------------------------------------	
*/
WSStruct InDataInt
	WSData NewInInt as Array Of InCpoInt
EndWSStruct


/*
DE			PARA
CTBITEM		IT1
INCTBITEM	IT2
INCPOINT	CP
CCPOINT		CPN
XVLRINT		CPV
*/


//Itens
WSStruct CtbItemAux
	WSData CtbItens as Array Of IT1 
EndWSStruct

//Item
WSStruct IT1
	WSData IT2 as Array Of CP
EndWSStruct

//|Campo Nome e Valor|
WSStruct CP
	WsData CPN		as String						//01 - Nome do Campo para Gravacao
	WsData CPV		as String						//02 - Conteudo do Campo para Gravacao
EndWSStruct

/*
-----------------------------------------------------------------------------------------------------
Campos do Titulo para Integracao
-----------------------------------------------------------------------------------------------------	
*/
WSStruct InCpoInt
	WsData cCpoInt		as String						//01 - Nome do Campo para Gravacao
	WsData xVlrInt		as String						//02 - Conteudo do Campo para Gravacao
EndWSStruct

User Function W004VldEmp(cCNPJ)
	If VldEmpFil(cCNPJ)
		Aviso("W004VldEmp", "Ok", {"Fechar"})
	Else
		Aviso("W004VldEmp", "Erro", {"Fechar"})
	EndIf
Return NIL
