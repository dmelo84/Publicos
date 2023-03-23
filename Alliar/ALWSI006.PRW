#INCLUDE "ALWSI006.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALWSI006
Funcao Generica para Compilacao

@author Guilherme Santos
@since 29/11/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALWSI006()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} wsIntegraPleres
Web Service de Integracao Protheus x Pleres

@author Guilherme Santos
@since 29/11/2016
@version P12
*/
//-------------------------------------------------------------------
WSSERVICE wsIntegraPleres 		Description "Integração Protheus x Pleres"
	WsData sCNPJ				as String
	WsData sUser				as String
	WsData sPassword			as String
	WsData sOperation			as String
	WsData sReturn				as String
	WsData sIDTran				as String
	WSData aInDataPle			as InDataPle

	WsMethod IncluiMedico		Description "Inclusao do Medico"
	WsMethod IncluiPaciente		Description "Inclusao do Paciente"
EndWSService
//-------------------------------------------------------------------
/*{Protheus.doc} IncluiMedico
Metodo para Integração do Medico

@author Guilherme Santos
@since 29/11/2016
@version P12
*/
//-------------------------------------------------------------------
WSMethod IncluiMedico WSReceive sCNPJ, sUser, sPassword, sOperation, sIDTran, aInDataPle WsSend sReturn WSService wsIntegraPleres
	Local lRetorno		:= .T.

	Local nTrans		:= 0
	Local nI			:= 0
	Local nJ			:= 0
	Local nK			:= 0

	Local oMedico		:= NIL

	Local cCampo		:= ""
	Local xValor		:= ""
	
	Local aMedico 		:= {}
	Local aContatos		:= {}
	Local aAux			:= {}
	
	Local cCPFMed 		:= ""
	Local cCRMMed 		:= ""
	Local cEstCRM 		:= ""

	Local cMsgErro		:= ""

	Local nLine			:= 0
	Local nOpcao		:= 0
	
	Local cIdPleres		:= ""

	Console("Preparando Ambiente para Gravacao do Medico - ID Pleres: " + ::sIDTran, .F., .T.)

	Console("CNPJ da Filial para Inclusão " + ::sCNPJ, .F., .T.)

	If VldEmpFil(::sCNPJ)

		Console("Validando Usuario", .F., .T.)

		If VldUser(::sUser, ::sPassword)

			Console("Usuario Valido.", .F., .T.)

			If Empty(::aInDataInt) .OR. !(::sOperation == "INSERT") 
				::sReturn		:= "Dados invalidos"
				lRetorno 		:= .F.
			Else
				Console("Verificando dados recebidos para Integracao", .F., .T.)

				nTrans := Len(::aInDataInt:NewInInt)

				Console("Quantidade de Campos Recebidos: " + StrZero(nTrans, 3), .F., .T.)

				If nTrans > 0
					aMedico 	:= {}
					aContatos	:= {}
					aAux		:= {}

					For nI := 1 to Len(::aInDataInt:NewInInt)
						cCampo		:= ::aInDataInt:NewInInt[nI]:cCpoInt + Space(10 - Len(::aInDataInt:NewInInt[nI]:cCpoInt))
						xValor		:= ::aInDataInt:NewInInt[nI]:xVlrInt

						Console("Campo: |" + cCampo + "| xValor: |" + xValor + "|", .F., .T.)

						If SX3->(DbSeek(cCampo))
							Do Case
							Case SX3->X3_TIPO == "N"
								xValor := Val(xValor)
							Case SX3->X3_TIPO == "D"
								xValor := CtoD(xValor)
							Case SX3->X3_TIPO == "C"
								xValor := xValor + Space(SX3->X3_TAMANHO - Len(xValor))
							EndCase
						EndIf

						Do Case
						Case "ACH_" $ cCampo
							Aadd(aMedico, {cCampo, xValor})

							Do Case
							Case AllTrim(cCampo) == "ACH_CGC"
								cCPFMed := xValor
							Case AllTrim(cCampo) == "ACH_XCRMUF"
								cEstCRM := xValor
							Case AllTrim(cCampo) == "ACH_XCRM"
								cCRMMed := xValor
							EndCase

						Case "ITEM" == cCampo
							If !Empty(aAux)
								Aadd(aContatos, AClone(aAux))
								aAux := {}
							EndIf
						Case "SU5_" $ cCampo
							Aadd(aAux, {cCampo, xValor})
						EndCase

						If nI == Len(::aInDataInt:NewInInt)
							If !Empty(aAux)
								Aadd(aContatos, AClone(aAux))
								aAux := {}
							EndIf
						EndIf
					Next nI

					If Empty(cCPFMed) .AND. (Empty(cEstCRM) .OR. Empty(cCRMMed))
						lRetorno	:= .F.
						::sReturn	:= "Chave de Busca do Medico (CPF ou CRM) invalidas."
					Else 
						//Procura o Medico pelo CPF
						DbSelectArea("ACH")
						DbSetOrder(2)		//ACH_FILIAL, ACH_CGC
						
						If ACH->(DbSeek(xFilial("ACH") + cCPFMed))
							nOpcao := MODEL_OPERATION_UPDATE
						Else
							//Procura o Medico pelo Estado + CRM
							DbSelectArea("ACH")
							DbOrderNickName("ACHCRM")
	
							If ACH->(DbSeek(xFilial("ACH") + cEstCRM + cCRMMed))
								nOpcao := MODEL_OPERATION_UPDATE
							Else
								nOpcao := MODEL_OPERATION_INSERT
							EndIf 
						EndIf
					EndIf

					If lRetorno
						Console("Carregando Modelo de Dados da Integracao do Medico.", .F., .T.)
	
						oMedico		:= FWLoadModel("ALTMKA03")
						lRetorno	:= lRetorno .AND. oMedico:SetOperation(nOpcao)
						lRetorno	:= lRetorno .AND. oMedico:Activate()
	
						Console("Adicionando dados do Medico", .F., .T.)

    					If nOpcao == MODEL_OPERATION_INSERT
							For nI := 1 to Len(aMedico)
								lRetorno := lRetorno .AND. oMedico:SetValue("ACHHEADER", aMedico[nI][01], aMedico[nI][02])
							Next nI

							For nI := 1 to Len(aContatos)
								If lRetorno
									If nI > 1
										nLine := oMedico:GetModel("SU5DETAIL"):AddLine()
										
										If nLine > 0
											oMedico:GetModel("SU5DETAIL"):GoLine(nLine)
										Else
											lRetorno := .F.
										EndIf
									EndIf
	
									If lRetorno
										For nJ := 1 to Len(aContatos[nI])
											lRetorno := lRetorno .AND. oMedico:SetValue("SU5DETAIL", aContatos[nI][nJ][01], aContatos[nI][nJ][02])
										Next nJ
									EndIf
								EndIf
							Next nI
						ElseIf nOpcao == MODEL_OPERATION_UPDATE
							For nI := 1 to Len(aMedico)
								lRetorno := lRetorno .AND. oMedico:SetValue("ACHHEADER", aMedico[nI][01], aMedico[nI][02])
							Next nI

							//Procurar o Contato pelo CPF e pelo Estado + CRM
							nPosCon := MTFindMVC(oMedico:GetModel("SU5DETAIL"), {{"U5_FILIAL", FWxFilial("SU5")}, {"U5_CPF", cCPFMed}})

							If nPosCon > 0
								oMedico:GetModel("SU5DETAIL"):GoLine(nPosCon)
							Else
								nPosCon := MTFindMVC(oMedico:GetModel("SU5DETAIL"), {{"U5_FILIAL", FWxFilial("SU5")}, {"U5_XCRMUF", cEstCRM}, {"ACH_XCRM", cCRMMed}})

								If nPosCon > 0 
									oMedico:GetModel("SU5DETAIL"):GoLine(nPosCon)
								Else
									nPosCon := oMedico:GetModel("SU5DETAIL"):AddLine()
									
									If nPosCon > 0
										oMedico:GetModel("SU5DETAIL"):GoLine(nPosCon)
									Else
										lRetorno := .F.
									EndIf
								EndIf
							EndIf													

							If lRetorno
								For nJ := 1 to Len(aContatos[nI])
									lRetorno := lRetorno .AND. oMedico:SetValue("SU5DETAIL", aContatos[nI][nJ][01], aContatos[nI][nJ][02])
								Next nJ
							EndIf
						EndIf
					EndIf

                	//Valida os Dados carregados para Gravacao
                	If lRetorno
                		Console("Validando dados do Medico", .F., .T.)
                		
                		lRetorno := oMedico:VldData()
                	EndIf
                
                	//Grava o Medico e os Contatos
                	If lRetorno
                		Console("Gravacao do Medico e Contatos", .F., .T.)

                		lRetorno := oMedico:CommitData()
                	EndIf

                	//Se gravou o Medico
                	If lRetorno
						::sReturn := "Medico Gravado com Sucesso."
                	Else
						If Empty(::sReturn)
	            			//Exibe as Mensagens de Erro durante a Validacao ou Gravacao do Model
							::sReturn	:= "Erro na Gravacao do Medico." + CRLF
	            			::sReturn	+= GETXERR(oMedico)
	                	EndIf
                	EndIf
                
                	//Libera a Memoria
                	oMedico:DeActivate()
                	oMedico:Destroy()
                	FreeObj(oMedico)
   				EndIf
			EndIf
		Else
			::sReturn := "Usuario ou senha invalidos."
			lRetorno := .F.
		EndIf
	Else
		::sReturn := "Empresa ou Filial invalidas."
		lRetorno := .F.
	EndIf

	If !lRetorno
		Console(::sReturn, .F., .T.)
		SetSoapFault(XNOMEPROG, ::sReturn)
	EndIf

	Console("Medico", .T., .T.)

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} IncluiPaciente
Inclusao do Paciente

@author Guilherme.Santos
@since 29/11/2016
@version P12
*/
//-------------------------------------------------------------------
WSMethod IncluiPaciente WSReceive sCNPJ, sUser, sPassword, sOperation, sIDTran, aInDataPle WsSend sReturn WSService wsIntegraPleres
	Local lRetorno := .T.

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} VldEmpFil
Valida a Filial Informada

@author Guilherme Santos
@since 06/09/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function VldEmpFil(cCNPJ)
	Local lRetorno := .F.

	DbSelectArea("SM0")
	DbSetOrder(1)		//M0_CODIGO, M0_CODFIL

	SM0->(DbGoTop())

	While !SM0->(Eof())

		If cCNPJ == SM0->M0_CGC
			lRetorno := .T.
			cEmpAnt := SM0->M0_CODIGO
			cFilAnt := SM0->M0_CODFIL
			Exit
		EndIf

		SM0->(DbSkip())
	End

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} VldUser
Validacao do Usuario e Senha

@author Guilherme Santos
@since 06/09/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function VldUser(cUsuario, cPassword)
	Local lRetorno	:= .T.

	PswOrder(2)

	//Verifica se o usuario é valido
	If !PswSeek(cUsuario, .T.)
		lRetorno := .F.
	Else
		//Verifica se a senha é valida para o usuário
		If !PswName(cPassword)
			lRetorno := .F.
		Endif
	Endif			

Return lRetorno	
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

	ConOut(XNOMEPROG + " - " + DtoC(Date()) + " - " + Time() + " - " + cTexto)

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
Colecao de Campos do Medico para Integracao
-----------------------------------------------------------------------------------------------------	
*/
WSStruct InDataPle
	WSData NewInPle as Array Of InCpoPle
EndWSStruct
/*
-----------------------------------------------------------------------------------------------------
Campos do Medico para Integracao
-----------------------------------------------------------------------------------------------------	
*/
WSStruct InCpoPle
	WsData cCpoInt		as String						//01 - Nome do Campo para Gravacao
	WsData xVlrInt		as String						//02 - Conteudo do Campo para Gravacao
EndWSStruct
