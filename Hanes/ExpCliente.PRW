#INCLUDE "PROTHEUS.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"



/*/{Protheus.doc} JobExpCliente
Job de exporta��o de clientes
@author Iago Bernardes
@since 17/08/2018
@version 1.0
@return lRet, .T. se execu��o bem sucedida; .F. caso contr�rio
@param cEmp, characters, c�digo do grupo de empresas para preparar o ambiente
@param cFil, characters, c�digo da filial para preparar o ambiente
@type function
/*/
User Function JobExpCliente(cEmp, cFil)

	Local lRet		:= .F.
	Local lContinua	:= .F.

	Private lJob	:= .T.

	Default cEmp	:= ""
	Default cFil	:= ""

	ConOut("Inicio do Processamento JobExpCliente")

	If Empty(cEmp) .Or. Empty(cFil)

		cEmp := "01"
		cFil := "0103"
	EndIf

	// Inicia Ambiente
	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp, cFil, Nil, Nil, "FAT", Nil, {"SA1", "SX3"})

	// Controle de Semaforo
	lContinua := LockbyName("U_JobExpCliente", .T.)

	If !lContinua

		AVISO("", "Processo j� em uso por outro usu�rio... ", {"OK"}, 1, "Finalizando!")

		RESET ENVIRONMENT

		Return .F.
	EndIf

	lRet := ProcDados(.T.)

	ConOut("Fim do Processamento JobExpCliente")

	RESET ENVIRONMENT

	// Desbloqueando Sem�foro
	UnLockbyName("U_JobExpCliente", .T.)

Return lRet



/*/{Protheus.doc} JobExpCliente
Fun��o de exporta��o de clientes
@author Iago Bernardes
@since 17/08/2018
@version 1.0
@return .T. se execu��o bem sucedida; .F. caso contr�rio
@type function
/*/
User Function ExpCliente()

	Local lProcess	:= .F.
	Local lContinua	:= .F.

	Local cTitulo	:= "Integra��o Ciashop - v1.0 - Exporta��o de Clientes"
	Local cPerg		:= PadR("SX1INTCIA", Len(SX1->X1_GRUPO))

	Local aSay		:= {}
	Local aBotoes	:= {}

	Private lJob	:= .F.

	// Controle de Sem�foro
	lContinua := LockbyName("U_JobExpCliente", .T.)

	If !lContinua

		// Desbloqueando Semaforo
		UnLockbyName("U_JobExpCliente", .T.)

		Return .F.

	EndIf

	lContinua := .F.

	aSay	:=	{ ; 
	" Gera��o de arquivos .csv ", ; 
	" ", ; 
	" Esta rotina ir� executar a exporta��o dos registros de clientes", ; 
	" para serem importados no sistema DataSul, conforme os dados informados", ; 
	" nos parametros.", ; 
	" ", ; 
	"Antes de Clicar em OK Clicar em PARAMETROS", ; 
	" ", ; 
	"                                                                    "; 
	}

	aAdd(aBotoes, {5, .T., {|| AjustPerg(cPerg, @lContinua, @lProcess)}})
	aAdd(aBotoes, {1, .T., {|| lProcess := .T., FechaBatch()}})
	aAdd(aBotoes, {2, .T., {|| lProcess := .F., FechaBatch()}})

	FormBatch(cTitulo, aSay, aBotoes, , 240, 510)

	If lProcess .And. lContinua

		MsgRun("Aguarde enquanto os clientes s�o exportados", "Processando...", {|| ProcDados(lProcess)})
	ElseIf lProcess .And. !lContinua

		Alert("Atencao os parametros nao foram informados! A rotina nao sera processada.")
	Else

		AVISO("", "Processo encerrado pelo usuario... ", {"OK"}, 1, "Finalizando!")
	EndIf

	// Desbloqueando Sem�foro
	UnLockbyName("U_JobExpCliente", .T.)

Return .T.



/*/{Protheus.doc} ProcDados
Exporta em um arquivo de formato CSV os clientes associados �s notas fiscais
geradas dentro do per�odo de tempo definido antes da execu��o da rotina
@author Iago Bernardes
@since 17/08/2018
@version 1.0
@return .T. se execu��o bem sucedida; .F. caso contr�rio
@param lOK, logical, realiza o processamento dos dados; deve ser sempre .T.
@type function
/*/
Static Function ProcDados(lOK)

	Local nHandle		:= 0
	Local nX			:= 0

	Local lContinua		:= .F.
	Local lFiltraEC		:= .F.

	Local cAux			:= ""
	Local cHead			:= ""
	Local cCols			:= ""
	Local cQry			:= ""

	Local aHead			:= {}
	Local aArea			:= {}

	Private cLogMsg		:= ""
	Private cPathExp	:= ""
	Private cBarra		:= If(isSrvUnix(), "/", "\")
	Private cTime		:= FWTimeStamp(1)

	Default lOk := .T.

	cLogMsg += "[" + FWTimeStamp(2) + "] -- " + " ====== = ====== IN�CIO ====== = ====== " + CRLF + CRLF

	If !lOK

		Return .F.
	EndIf

	If !ChckPaths()

		Return .F.
	EndIf

	If lJob

		MV_PAR01	:= (Date())
		MV_PAR02	:= (Date())
		lFiltraEC	:= .F.
	Else
		// Verifica filtro de pedidos E-Commerce
		If (MV_PAR03 == 1, lFiltraEC := .T., lFiltraEC:= .F.)
	EndIf

	// Gera arquivo gravando cabecalho
	ConOut("[" + FWTimeStamp(2) + "] -- " + " Criando arquivos .csv <SA1> ")

	// Cria arquivo
	nHandle := FCreate(cPathExp + DToS(Date()) + StrTran(Time(), ":", "") + "SA1.csv", FC_NORMAL)

	If nHandle == -1

		ConOut("[" + FWTimeStamp(2) + "] -- " + " O Arquivo <SA1> n�o foi criado.")
		cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! O Arquivo (SA1) n�o foi criado: " + Str(FError()) + CRLF
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "Abortando Opera��o" + CRLF

		U_CstmLogMsg(cLogMsg, "exportacao_clientes", cTime)

		Break

		Return .F.
	Else

		// Montagem do aHead conforme SX3
		DBSelectArea("SX3")
		SX3->(DBSetOrder(1))
		SX3->(DBSeek("SA1"))

		While SX3->(!EOF() .And. X3_ARQUIVO == "SA1")

			If AllTrim(SX3->X3_CONTEXT) <> "V"

				// Ignora os campos do tipo MEMO
				If SX3->X3_TIPO != "M"

					aAdd(aHead, {SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
					cAux += AllTrim(SX3->X3_CAMPO) + ";"
				EndIf
			EndIf

			SX3->(DBSkip())
		EndDo

		// Grava cabe�alho no arquivo
		cHead	:= SubStr(cAux, 1, Len(cAux) - 1)
		cAux	:= ""

		If FWrite(nHandle, cHead) < 0

			ConOut("[" + FWTimeStamp(2) + "] -- " + " Erro na grava��o do arquivo (SA1) - Error: " + Str(FError()))
			cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! Erro na grava��o do arquivo <SA1> -- Error: " + Str(FError()) + CRLF

			If !lJob

				MsgAlert("Erro de grava��o: " + Str(FError()))
			EndIf
		EndIf

		FWrite(nHandle, CRLF)

		// Recupera clientes da tabela SA1
		cAliasQry := "TMPSA1"

		cQry := " SELECT " + AllTrim(StrTran(cHead, ";", ",")) + " " + CRLF
		cQry += " FROM " + RetSQLName("SA1") + " AS SA1 (NOLOCK) " + CRLF
		cQry += " INNER JOIN ( " + CRLF
		cQry += "	SELECT DISTINCT Q1.CLIENTE, Q1.LOJA " + CRLF
		cQry += "	FROM ( " + CRLF
		cQry += "		SELECT DISTINCT SE1.E1_CLIENTE AS CLIENTE, " + CRLF
		cQry += "			SE1.E1_LOJA AS LOJA " + CRLF
		cQry += "		FROM " + RetSQLName("SE1") + " AS SE1 (NOLOCK) " + CRLF
		cQry += "			WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' " + CRLF

		// Filtra somente pedidos E-Commerce
		If lFiltraEC
			cQry += "				AND SE1.E1_PREFIXO = '" + AllTrim(GetMV("MV_LJECOM5")) + "' " + CRLF
		EndIf

		cQry += "				AND SE1.D_E_L_E_T_ = '' " + CRLF
		cQry += "		UNION ALL " + CRLF
		cQry += "		SELECT DISTINCT SF2.F2_CLIENTE AS CLIENTE, " + CRLF
		cQry += "			SF2.F2_LOJA AS LOJA " + CRLF
		cQry += "		FROM " + RetSQLName("SF2") + " AS SF2 (NOLOCK) " + CRLF
		cQry += "			WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' " + CRLF
		cQry += "				AND SF2.F2_EMISSAO BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "' " + CRLF

		// Filtra somente pedidos E-Commerce
		If lFiltraEC
			cQry += "				AND SF2.F2_PREFIXO = '" + AllTrim(GetMV("MV_LJECOM5")) + "' " + CRLF
		EndIf

		cQry += "				AND SF2.D_E_L_E_T_ = '' " + CRLF
		cQry += "		) AS Q1 " + CRLF
		cQry += "	) AS Q2 " + CRLF
		cQry += " ON Q2.CLIENTE = SA1.A1_COD " + CRLF
		cQry += " AND Q2.LOJA = SA1.A1_LOJA " + CRLF
		cQry += " WHERE SA1.D_E_L_E_T_ = ''"

		If Select(cAliasQry) > 0

			(cAliasQry)->(DBCloseArea())
		EndIf

		// Ajusta a Query retirando espacos e tabulacoes
		cQry := ChangeQuery(cQry)

		MemoWrite("QryExpClientes_SA1.sql", cQry)
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "AVISO! Query de extra��o da tabela <SA1> montada. Ver arquivo 'QryExpCliente_SA1.sql'" + CRLF

		ConOut("[" + FWTimeStamp(2) + "]" + " Query de extra��o da tabela <SA1> montada. Ver arquivo 'QryExpClientes_SA1.sql' ")

		// Executa a Query definindo o RecordSet como uma nova area de trabalho
		DBUseArea(.T., 'TOPCONN', TcGenQry(, , cQry), cAliasQry, .T., .T.)

		//		aArea := GetArea() //DMS

		DBSelectArea(cAliasQry)
		(cAliasQry)->(DBGoTop())

		ConOut("[" + FWTimeStamp(2) + "] -- " + " Iniciando a exportacao dos clientes ")
		cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "AVISO! Iniciando a exporta��o dos clientes" + CRLF

		While (cAliasQry)->(!EOF())

			For nX := 1 To Len(aHead)

				If Valtype((cAliasQry)->&(aHead[nX][1])) == "N" // aHead[nX][2] == "N"

					cCols += AllTrim(Transform((cAliasQry)->&(aHead[nX][1]), aHead[nX][5])) + "; "
				ElseIf Valtype((cAliasQry)->&(aHead[nX][1])) == "D"

					cCols += AllTrim(DtoC((cAliasQry)->&(aHead[nX][1]))) + "; "
				ElseIf Valtype((cAliasQry)->&(aHead[nX][1])) == "C"

					cCols += AllTrim((cAliasQry)->&(aHead[nX][1])) + "; "
				EndIf
			Next nX

			cCols += CRLF

			(cAliasQry)->(DBSkip())
		EndDo

		(cAliasQry)->(DBCloseArea())

		//RestArea(aArea) //DMS

		If FWrite(nHandle, cCols) < 0

			ConOut("[" + FWTimeStamp(2) + "] -- " + " Erro na gravacao do arquivo (SA1) - Error: " + Str(FError()))
			cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! Erro na grava��o do arquivo <SA1> -- Error: " + Str(FError()) + CRLF

			If !lJob

				MsgAlert("Erro de gravacao: " + Str(FError()))
			EndIf
		EndIf

		// Apos arquivo gravado, seta a variavel de cabe�alho
		cHead := ""
		aHead := {}

		// Fecha o arquivo
		FCLOSE(nHandle)
	EndIf

	If !lJob

		AVISO("Sucesso!", "Fim da exportacao do arquivo!", {"OK"}, 1, "Finalizando...")
	EndIf

	U_CstmLogMsg(cLogMsg, "exportacao_clientes", cTime)

Return .T.



Static Function AjustPerg(cPerg, lContinua, lProcess)

	Default lContinua	:= .F.
	Default lProcess	:= .F.

	If(PERGUNTE(cPerg, .T.), lProcess := .T., lProcess := .F.)

	lContinua := lProcess

Return



Static Function ChckPaths()

	Local lOk		:= .F.
	Local lErro		:= .F.
	Local lShowMsg	:= .F.

	Local nX		:= 0

	Local cPath		:= ""

	Local aArqOld	:= {}
	//	Local aDirect	:=	{	"integracao_pdv_ciashop" + cBarra + "exportacao_clientes" + cBarra + "processados", ;
	//							"integracao_pdv_ciashop" + cBarra + "exportacao_clientes" + cBarra + "nao_processados";
	//						}
	Local aDirect	:=	{	"integrapdv" + cBarra + "exportacao" + cBarra + "processados", ;
	"integrapdv" + cBarra + "exportacao" + cBarra + "nao_processados";
	}

	// Captura o RootPath do sistema
	cPath := GetSrvProfString("Path", "") + If(Right(GetSrvProfString("Path", ""), 1) == cBarra, "", cBarra)

	For nX := 1 To Len(aDirect)

		If ExistDir(cPath + aDirect[nx])

			If lJob

				ConOut("[" + FWTimeStamp(2) + "] -- " + " OK! Diretorio existente <" + cPath + aDirect[nx] + ">")
			Else

				cLogMsg += "[" + FWTimeStamp(2) + "]" + " OK! Diretorio existente <" + cPath + aDirect[nX] + ">"
			EndIf
		Else

			If lJob

				ConOut("[" + FWTimeStamp(2) + "] -- " + " Criando diretorio <" + cPath + aDirect[nx] + ">")
			Else

				cLogMsg += "[" + FWTimeStamp(2) + "]" + " OK! Diretorio existente <" + cPath + aDirect[nX] + ">"
			EndIf

			lOk := FwMakeDir(cPath + aDirect[nx], lShowMsg)

			If lOk

				If lJob

					ConOut("[" + FWTimeStamp(2) + "] -- " + " Diretorio criado... ")
				Else

					cLogMsg += "[" + FWTimeStamp(2) + "]" + " Diretorio criado... " + "|"
				EndIf
			Else

				If lJob

					ConOut(Repl("-", 80))
					ConOut("")
					ConOut("JobExpCliente - MAKEDIR ERROR: " + Str(FError()))
					ConOut("")
					ConOut(Repl("-", 80))
				Else

					cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO! Makedir Error: " + Str(FError()) + CRLF + CRLF
				EndIf

				lErro := .T.
			EndIf
		EndIf
	Next nX

	If !lErro

		// Path de exportacao
		cPathExp := Alltrim(cPath + aDirect[2] + cBarra)

		ConOut("[" + FWTimeStamp(2) + "]" + " Preparando Path para exportacao <" + cPathExp + ">")

		// Verifica e renomeia arquivos n�o transferidos gerados com erro
		If File(cPathExp + "*.csv")

			aArqOld := Directory(cPathExp + "*.csv")

			For nX := 1 To Len(aArqOld)

				If !("OLD" $ aArqOld[nX][1]) .And. ("SA1.CSV" $ aArqOld[nX][1])

					ConOut("[" + FWTimeStamp(2) + "]" + " Renomeando arquivos .csv <" + aArqOld[nX][1] + "> ")
					FRename(cPathExp + aArqOld[nX][1], cPathExp + "OLD_" + aArqOld[nX][1])
				EndIf
			Next nX
		EndIf
	EndIf 

Return !lErro  