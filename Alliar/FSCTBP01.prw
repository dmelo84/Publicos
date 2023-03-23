#Include "Protheus.ch"

/*/{Protheus.doc} FSCTBP01
Rotina para gravacao dos dados Digital na tabela SZ4

@type function
@author Alex Teixeira de Souza
@since 08/01/2016
@version 1.0
@param cLogUsu, character, 	Codigo do usuario
@param cSenUsu, character, 	senha do usuario
@param cCNPJFil, character, 	CNPJ Filial que esta enviando a informacao
@param cRefer, character, 	Referencia formato AAAAMM
@param nValProd, numerico, 	Valor Producao
@param nValPerd, numero, 	Valor Perda
@return ${aRet}, ${Codigo do erro, Descricao do Erro}
@example
(examples)
@see (links_or_references)
/*/
User Function FSCTBP01(cLogUsu, cSenUsu,cCNPJFil, cRefer, nValProd,nValPerd, nValGlosa )
Local aRet		:= {"",""}
Local aRetCon	:= FRetFil(cCNPJFil) //Usado apenas para logar na primeira empresa
Local cEmpCon	:= aRetCon[1] 
Local cFilCon	:= aRetCon[2]
Local lJASM0	:= aRetCon[3] 

If !Empty(cEmpCon) .And. !Empty(cFilCon)
	If !lJASM0
		If RpcSetEnv(cEmpCon, cFilCon)
			cEmpAnt := cEmpCon
			cFilAnt := cFilCon
			Conout("Setando ambiente")
			If Emprok(cEmpCon + cFilCon) // Valida se a empresa está liberada pela Totvs
				If FVerPwd(cLogUsu,cSenUsu)
					Conout("Verificou senha")
					aRet := FGrvDad(cEmpCon, cFilCon, cLogUsu,cSenUsu,cRefer,nValProd, nValPerd, nValGlosa )
					Conout("Gravou registro")
				Else	
					aRet := {"-999","ERRO:USUARIO OU SENHA INVALIDO!"}
				Endif
			Else
				aRet:= {"-999","ERRO:FILIAL NAO ESTA LIBERADA PARA USO!"}
			Endif	
			//RpcClearEnv()
		Else
			aRet:= {"-999","ERRO:NAO ENCONTROU FILIAL PARA O CNPJ ENVIADO!"}
		EndIf
	Else	
		cEmpAnt := cEmpCon
		cFilAnt := cFilCon
		If Emprok(cEmpCon + cFilCon) // Valida se a empresa está liberada pela Totvs
			If FVerPwd(cLogUsu,cSenUsu)
				Conout("Verificou senha")
				aRet := FGrvDad(cEmpCon, cFilCon, cLogUsu,cSenUsu,cRefer,nValProd, nValPerd )
				Conout("Gravou registro")
			Else	
				aRet := {"-999","ERRO:USUARIO OU SENHA INVALIDO!"}
			Endif
		Else
			aRet:= {"-999","ERRO:FILIAL NAO ESTA LIBERADA PARA USO!"}
		Endif	
	Endif
Else	
	aRet:= {"-999","ERRO:NAO ENCONTROU FILIAL PARA O CNPJ ENVIADO!"}
EndIf

Conout("Retorno "+aRet[1]+" Mensagem "+aRet[2])

Return(aRet)


/*/{Protheus.doc} FGrvDad
Grava Dados tabela SZ4

@type function
@author Alex Teixeira de Souza
@since 08/012016
@version 1.0
@param cEmpCon, character, 	Codigo da empresa
@param cFilCon, character,  Codigo da filial do sistema
@param cLogUsu, character, 	Codigo do usuario
@param cSenUsu, character, 	senha do usuario
@param nValProd, numerico, 	Valor Producao
@param nValPerd, numero, 	Valor Perda
@param nValGlosa, numero, 	Valor Glosa
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FGrvDad(cEmpCon, cFilCon, cLogUsu,cSenUsu,cRefer,nValProd, nValPerd, nValGlosa)
	Local aRet		:= {"",""}
	Local cMesAnt	:= ""
	Local nSldGlo	:= 0

	//Contabilizacao da Glosa
	If Substr(cRefer, 5, 2) == "01"
		cMesAnt := "01/" + "12/" + Str(Val(Substr(cRefer, 1, 4)) - 1)
	Else
		cMesAnt := "01/"
		cMesAnt += StrZero(Val(Substr(cRefer, 5, 2)) - 1, 2) + "/"	//Mes de Referencia
		cMesAnt += Substr(cRefer, 1, 4)									//Ano de Referencia
	EndIf

	//Busca o Saldo Anterior da Glosa
	//nSldGlo	:= 	SaldoConta(SuperGetMV("ES_CTBGLO", .F., "103"), CtoD(cMesAnt), "01")

	DBSelectArea("SZ4")
	DbSetOrder(1)

	BeginTran()
			
		If !SZ4->(DBSeek(xFilial("SZ4")+cRefer))
			Conout("Gravando Novo registro em SZ4")
			RecLock("SZ4",.T.)  
			SZ4->Z4_FILIAL 	:= xFilial("SZ4")
			SZ4->Z4_ANOMES	:= cRefer
			SZ4->Z4_VALOR		:= nValProd		
			SZ4->Z4_PERDA		:= nValPerd
			SZ4->Z4_GLOSA		:= nValGlosa
			SZ4->Z4_GLOANT	:= nSldGlo
			SZ4->Z4_LA			:= "N"
			SZ4->Z4_APUR 		:= "N"
			SZ4->Z4_DIFER		:= 0
			SZ4->( MsUnlock() )
			aRet:= {"0","OK:REGISTRO INCLUIDO COM SUCESSO!"}
		Else
			If SZ4->Z4_LA != "S"
				Conout("Alterado registro em SZ4")
				RecLock("SZ4",.F.)  
				SZ4->Z4_VALOR		:= nValProd		
				SZ4->Z4_PERDA		:= nValPerd
				SZ4->Z4_GLOSA		:= nValGlosa
				SZ4->Z4_GLOANT	:= nSldGlo
				SZ4->Z4_APUR 		:= "N"
				SZ4->Z4_DIFER		:= 0
				SZ4->( MsUnlock() )
				aRet:= {"0","OK:REGISTRO ALTERADO COM SUCESSO!"}
			Else
				aRet:= {"-999","REGISTRO JA FOI CONTABILIZADO!"}
			Endif	
		Endif

		EndTran()
			
	MsUnlockAll()
			
Return(aRet)


/*/{Protheus.doc} FRetFil
Retorna uma filial valida para o CNPJ

@type function
@author Alex Teixeira de Souza
@since 08/01/2016
@version 1.0
@param cCNPJ, character, (CNPJ)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FRetFil(cCNPJ)
Local cEmpRet	:= ""
Local cFilRet	:= ""
Local nRec		:= 0
Local lJASM0	:= .f.

If Select("SM0")==0
	If U_FSOpenSm0(.T.)
		Conout("Abriu SM0")
		SM0->(dbGoTop())
	
		While !SM0->( EOF() )
			If Alltrim(SM0->M0_CGC) == Alltrim(U_FSISDIGIT(cCNPJ))
				cEmpRet:= SM0->M0_CODIGO
				cFilRet:= SM0->M0_CODFIL
				Conout("Localizou Empresa "+cEmpRet+" Filial "+cFilRet)
				Exit
			EndIf
	
			SM0->( dbSkip() )
		End
	
		SM0->( dbCloseArea() )
	EndIf
Else	
	Conout("SM0 Ja esta aberto")
	lJASM0 := .t.
	SM0->(dbGoTop())	
	While !SM0->( EOF() )
		If Alltrim(SM0->M0_CGC) == Alltrim(U_FSISDIGIT(cCNPJ))
			cEmpRet:= SM0->M0_CODIGO
			cFilRet:= SM0->M0_CODFIL
			Conout("Localizou Empresa "+cEmpRet+" Filial "+cFilRet)
			Exit
		EndIf
		SM0->( dbSkip() )
	End
EndIf

lJASM0 := .f.

Return({cEmpRet,cFilRet,lJASM0})

/*/{Protheus.doc} FVerPwd
Valida login e senha do usuario

@type function
@author Alex Teixeira de Souza
@since 08/01/2016
@version 1.0
@param cUsuario, character, Login Usuario
@param cPassword, character, Senha Usuario
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FVerPwd(cUsuario,cPassword)
Local lRet := .T.

	//Valida usuario existe
	PswOrder(2)
	If !PswSeek(cUsuario, .T.) // Verifica se o usuario é valido
		lRet := .f.
	Else
		If !PswName(cPassword) // Verifica se a senha é valida para o usuário
			lRet := .f.
		Endif
	Endif			

Return(lRet)	
