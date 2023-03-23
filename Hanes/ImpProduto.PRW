#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

#DEFINE COD 	1
#DEFINE CEME 	2
#DEFINE ECTITU 	3
#DEFINE PESO 	4
#DEFINE ECCOMP 	5
#DEFINE ECLARGU 6
#DEFINE ECPROFU 7
#DEFINE ECDESCR 8
#DEFINE ECINDIC 9
#DEFINE ECCARAC 10
#DEFINE ECBENFI 11
#DEFINE ECAPRES 12
#DEFINE PRODPAI 13


/*/{Protheus.doc} JobImpProduto
	Rotina de importação de produtos e tabelas de preço.
	
	Rotina para ser utilizada no Scheduler.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return lRet, .T. se executado com sucesso, .F. caso contrário
@param cEmp, characters, Código da empresa
@param cFil, characters, Código da filial
@type function
/*/
User Function JobImpProduto(cEmp, cFil)

	Local lRet		:= .F.
	Local lContinua	:= .T.

	Private lJob	:= .T.

	Default cEmp	:= ""
	Default cFil	:= ""

	ConOut("Inicio do Processamento JobImpProduto")
	
	// Considera a empresa 01 e a filial 0103 como padrões
	If Empty(cEmp) .Or. Empty(cFil)
		cEmp := "01"
		cFil := "0103"
	EndIf

	// Inicia Ambiente
	RpcClearEnv()
	RpcSetType(3)	// Informa que não irá consumir licenças
	RpcSetEnv(cEmp, cFil, Nil, Nil, "FAT", Nil, {"ACU", "ACV", "DA0", "DA1", "SA5", "SLK", "SB0", "SB1", "SB4", "SB5", "SBV", "SX3"})

	// Controle de Semáforo
	lContinua := LockByName("U_JobImpProduto", .T.)

	If !lContinua
		RESET ENVIRONMENT
		Return .T.
	EndIf
		
	lRet := ProcDados()

	ConOut("Fim do Processamento JobImpProduto")

	RESET ENVIRONMENT

	// Desbloqueando Semáforo
	UnLockByName("U_JobImpProduto", .T.)

Return lRet



/*/{Protheus.doc} ImpProduto
	Rotina de importação de produtos e tabelas de preço.
	
	Rotina para ser utilizada no menu.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return lRet, .T. se executado com sucesso, .F. caso contrário

@type function
/*/
User Function ImpProduto()

	Local lRet		:= .F.
	Local lProcess	:= .F.
	Local lContinua	:= .T.

	Local cTitulo	:= "Integração Ciashop - v1.0 - Importação de Produtos"

	Local aSay		:= {}
	Local aBotoes	:= {}

	Private lJob	:= .F.

	// Controle de Semáforo
	lContinua := LockbyName("U_JobImpProduto", .T.)

	If !lContinua
		AVISO("", "Processo já em uso por outro usuário... ", {"OK"}, 1, "Finalizando!")
		Return .F.
	EndIf

	aSay	:=	{	" Importação de arquivos .csv ", ; 
					" ", ; 
					" Esta rotina irá executar a importação dos produtos vindos do", ; 
					" sistema DataSul, conforme os dados informados nos parametros.", ; 
					" ", ;
					"                                                                    "; 
				}
	aAdd(aBotoes, {1, .T., {|| lProcess := .T., FechaBatch()}})
	aAdd(aBotoes, {2, .T., {|| lProcess := .F., FechaBatch()}})
	FormBatch(cTitulo, aSay, aBotoes, , 240, 510)

	If lProcess
		MsgRun("Aguarde enquanto os produtos são importados", "Processando...", {|lRet| lRet := ProcDados()})
	Else
		AVISO("", "Processo encerrado pelo usuario... ", {"OK"}, 1, "Finalizando!")
	EndIf

	// Desbloqueando Semáforo
	UnLockbyName("U_JobImpProduto", .T.)

Return lRet



/*/{Protheus.doc} ProcDados
	Função para importação dos produtos e tabelas de preço vindos do Datasul.
	Altera o código original (SKU) do Datasul para suportar a estrutura de grade
de produtos do Protheus, com o layout AAAAAABBBCCCDDD, onde:
		AAAAAA	= código da família do produto;
		BBB		= código do tipo de embalagem do produto;
		CCC		= código do tamanho do produto;
		DDD		= código da cor do produto.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return .T. se executado com sucesso, .F. caso contrário

@type function
/*/
Static Function ProcDados()

	Local lErro			:= .F.
	Local lEcomm		:= .F.
	Local lCabec		:= .F.

	Local cAux			:= ""

	Local nStatus		:= 0
	Local nPosCod		:= 0
	Local nY			:= 0
	Local nX			:= 0
	Local nHandle		:= 0

	Local aArea			:= {}
	Local aCabProd		:= {}

	Private lContinua	:= .F.

	Private aProduto	:= {}
	Private aStruX3		:= {}
	Private aCamposSB1	:= {}
	Private aArqImpSB0	:= {}
	Private aArqImpSB1	:= {}
	Private aTabPreco	:= {}

	Private cPathImpP	:= ""
	Private cPathImpNP	:= ""
	Private cLogMsg		:= ""
	Private cTime		:= FWTimeStamp(1)

	cLogMsg += "[" + FWTimeStamp(2) + "] -- " + " ====== = ====== INÍCIO ====== = ====== " + CRLF + CRLF

	// Verifica se as pastas e arquivos de importação são válidos
	If !ChckPaths()
		If !lJob
			Alert("[" + FWTimeStamp(2) + "] -- " + " Diretorios de importação inexistentes no Protheus. Consulte o Log da rotina! A operação será abortada.")
		EndIf

		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO! Diretórios de importação inexistentes no Protheus. Operação abortada" + CRLF
		ConOut("[" + FWTimeStamp(2) + "] -- " + " Diretorios de importacao inexistentes no Protheus. Operacao abortada...")

		// FIM DO PROGRAMA
		U_CstmLogMsg(cLogMsg, "importacao_produtos", cTime)
		Return .F.
	EndIf

	If !ChckFiles()
		// FIM DO PROGRAMA
		U_CstmLogMsg(cLogMsg, "importacao_produtos", cTime)
		Return .F.
	EndIf

	// Inicializa array com campos E-Commerce
	aCamposSB1 :=	{	"B1_XECDESC",	"B1_PRV1",		"B1_XECFLAG",									; //	"B1_DESC",		"B1_PRV1",		"B1_XECFLAG",									;
						"B1_XFAM",		"B1_XEMB",		"B1_XTAM",		"B1_XCOR",						;
						"B1_XDESCFA",	"B1_XDESCEM",	"B1_XDESTAM",	"B1_XDESCOR",					;
						"B1_XMARCA",	"B1_XCAT",		"B1_XSUBCAT",									;
						"B1_PESO",		"B1_XECLARG",	"B1_XECALTU",	"B1_XECCOMP",					;
						"B1_XECDCOM",	"B1_XECINDI",	"B1_XECCARA",	"B1_XECBENE",	"B1_XECAPRE"	; //	"B1_XECDESC",	"B1_XECINDI",	"B1_XECCARA",	"B1_XECBENE",	"B1_XECAPRE"	;
					}

	// Inicializa array com tabelas de preços
	aAdd(aTabPreco, {SuperGetMV("MV_LJECOMQ", .F., "001"), "TABELA PADRAO E-COMMERCE"})	// Tabela de Preço Padrão Ciashop
	aAdd(aTabPreco, {"002", "TABELA PADRAO LOJA"})	// Tabela de Preço Padrão Loja
	aAdd(aTabPreco, {SuperGetMV("MV_XMKTPLC", .F., "901"), "TABELA PADRAO MARKETPLACE"})	// Tabela de Preço Padrão Market Place

	// Início da rotina de importação dos dados de produtos
	ConOut("Inicio da importacao das tabelas SB0 e SB1")
	cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "AVISO! Início da importação das tabelas SB0 e SB1" + CRLF + CRLF
	
	For nX := 1 To 2
		// Garante que o arquivo SB1 será aberto antes do SB0
		If(nX == 1, cAlias := "SB1", cAlias := "SB0")

		If cAlias == "SB1"
			cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "AVISO! Início da importação do arquivo <SB1>" + CRLF + CRLF
			aStruX3 := {}

			// Processa SB1
			nHandle := FT_FUse(cPathImpNP + aArqImpSB1[1][1])

			// Se houver erro de abertura abandona processamento
			If nHandle = -1
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Erro na abertura do arquivo... <" + aArqImpSB1[1][1] + ">")

				If !lJob
					MsgStop('Erro de abertura : FError ' + Str(FError()))
				EndIf

				// FIM DO PROGRAMA
				U_CstmLogMsg(cLogMsg, "importacao_produtos", cTime)
				Return .F.
			EndIf

			// Posiciona na primeira linha
			FT_FGoTop()
			
			cCabec	:= ""
			cTipo	:= If(SubStr(FT_FReadLn(), 1, 1) == "C", "C", "I") // "C"abecalho ;  "I"tem
			
			While cTipo == "C"
				cCabec += FT_FReadLn()

				// Pula para próxima linha
				FT_FSKIP()

				cTipo := If("B1_" $ FT_FReadLn(), "C", "I") // "C"abecalho ;  "I"tem
				lCabec := .T.
			EndDo
			
			// Valida se campos do cabecalho existem no dicionario de dados
			If lCabec
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Verificando cabecalho do arquivo <SB1>... ")

				cAux := SubStr(cCabec, 3, Len(cCabec)) // cAux := Primeira linha inteira, exceto primeiros dois caracteres "C; "

				// Retorna a linha corrente
				aCabProd := StrToKArr(cAux, ";") // aCabProd := array com os nomes dos campos da tabela no CSV

				SX3->(DBSetOrder(2)) // X3_CAMPO

				For nY := 1 To Len(aCabProd)

					If SX3->(DBSeek(Alltrim(aCabProd[nY])))
						aAdd(aStruX3, {AllTrim(SX3->X3_CAMPO), AllTrim(SX3->X3_TIPO)})
					Else
						ConOut("[" + FWTimeStamp(2) + "] -- " + "Cabecalho do arquivo SB1.CSV esta inconsistente! Verifique se o campo " + Alltrim(aCabProd[nY]) + " existe na base de dados")

						cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "Cabecalho do arquivo SB1.CSV esta inconsistente! Verifique se o campo " + Alltrim(aCabProd[nY]) + " existe na base de dados"
						If !lJob
							MsgStop('Cabecalho do arquivo SB1.CSV esta inconsistente! Verifique se o campo " + aCabProd[nY] + " existe na base de dados')
						EndIf

						// FIM DO PROGRAMA
						U_CstmLogMsg(cLogMsg, "importacao_produtos", cTime)
						Return .F.
					EndIf
				Next nY
/*				
				// Limpa tabela SB0
				cUpd := " Update " + RetSQLName("SB0") + CRLF
				cUpd += " Set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " + CRLF
				cUpd += " Where D_E_L_E_T_ <> '*' " + CRLF
				nStatus := TcSqlExec (cUpd)

				If nStatus < 0
					ConOut("TCSQLError(): " + TCSQLError())
					cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
				EndIf
				
				// Trava a tabela SB1
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Reservando tabela <SB1>")

				cUpd := " Update " + RetSQLName("SB1") + CRLF
				cUpd += " Set B1_MSBLQL = '1' " + CRLF
				cUpd += " Where D_E_L_E_T_ <> '*' " + CRLF
				nStatus := TcSQLExec(cUpd)

				If nStatus < 0
					ConOut("TCSQLError(): " + TCSQLError())
					cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
				EndIf
				
				// Limpa a tabela SB4
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Reservando tabela <SB4>")

				cUpd := " Update " + RetSQLName("SB4") + CRLF
				cUpd += " Set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " + CRLF
				cUpd += " Where D_E_L_E_T_ <> '*' " + CRLF
				nStatus := TcSQLExec(cUpd)

				If nStatus < 0
					ConOut("TCSQLError(): " + TCSQLError())
					cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
				EndIf
				
				// Limpa a tabela SB5
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Reservando tabela <SB5>")

				cUpd := " Update " + RetSQLName("SB5") + CRLF
				cUpd += " Set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " + CRLF
				cUpd += " Where D_E_L_E_T_ <> '*' " + CRLF
				nStatus := TcSQLExec(cUpd)

				If nStatus < 0
					ConOut("TCSQLError(): " + TCSQLError())
					cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
				EndIf
				
				// Limpa a tabela SBV
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Reservando tabela <SBV>")

				cUpd := " Update " + RetSQLName("SBV") + CRLF
				cUpd += " Set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " + CRLF
				cUpd += " Where D_E_L_E_T_ <> '*' " + CRLF
				nStatus := TcSQLExec(cUpd)

				If nStatus < 0
					ConOut("TCSQLError(): " + TCSQLError())
					cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
				EndIf
				
				// Limpa a tabela SA5
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Reservando tabela <SA5>")

				cUpd := " Update " + RetSQLName("SA5") + CRLF
				cUpd += " Set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " + CRLF
				cUpd += " Where D_E_L_E_T_ <> '*' " + CRLF
				nStatus := TcSQLExec(cUpd)

				If nStatus < 0
					ConOut("TCSQLError(): " + TCSQLError())
					cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
				EndIf
				
				// Limpa a tabela SLK
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Reservando tabela <SLK>")

				cUpd := " Update " + RetSQLName("SLK") + CRLF
				cUpd += " Set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " + CRLF
				cUpd += " Where D_E_L_E_T_ <> '*' " + CRLF
				nStatus := TcSQLExec(cUpd)

				If nStatus < 0
					ConOut("TCSQLError(): " + TCSQLError())
					cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
				EndIf

				// Limpa a tabela DA1
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Reservando tabela <DA1>")

				cUpd := " Update " + RetSQLName("DA1") + CRLF
				cUpd += " Set D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ " + CRLF
				cUpd += " Where D_E_L_E_T_ <> '*' " + CRLF
				nStatus := TcSQLExec(cUpd)

				If nStatus < 0
					ConOut("TCSQLError(): " + TCSQLError())
					cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
				EndIf */	
			EndIf
		
			ConOut("[" + FWTimeStamp(2) + "] -- " + " Iniciando o processamento dos registros... ")

			cItem := ""

			While !FT_FEOF()
				lNewProd	:= .F.
				lEcomm		:= .F.
				
				While !lNewProd .And. !FT_FEOF()
					cX := FT_FReadLn()	// cX := Cada linha com dados do produto

					// Verifica se não houve quebra de linha
					If SubStr(cX, 2, 1) == 'I'
						cItem := cX
					Else
						cItem += FT_FReadLn()
					EndIf

					// Pula para próxima linha
					FT_FSkip()

					If SubStr(FT_FReadLn(), 2, 1) == 'I'
						lNewProd := .T.
					EndIf
				EndDo
				
				lCabec		:= .F.
				cAux 		:= SubStr(cItem, At('";"', cItem) + 3, Len(cItem)) // Ignora os primeiros caraceteres "C; " ou "I; "

				// Retira aspas duplas antes de separar o array
				aProduto	:= StrToKArr(StrTran(StrTran(cAux, '""', '" "'), '"', ''), ";")
				
				UpdSB1()

				U_CstmLogMsg(cLogMsg, "importacao_produtos", cTime, .F.)

				cLogMsg	:= ""

			EndDo
			
			// Verifica erros nas famílias de produtos
			ChckFamilias()
			
			U_CstmLogMsg(cLogMsg, "importacao_produtos", cTime, .F.)

			cLogMsg	:= ""

			// Fecha o arquivo
			FT_FUSE()

			ConOut("[" + FWTimeStamp(2) + "] -- " + " Encerrando arquivo de importacao da tabela <SB1>")				
			ConOut("[" + FWTimeStamp(2) + "] -- " + " Renomeando arquivos .csv <" + aArqImpSB1[1][1] + "> para <processado_" + aArqImpSB1[1][1])

			// Verifica se o arquivo já existente na pasta de arquivos processados
			If File(cPathImpP + "processado_" + aArqImpSB1[1][1])
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Apagando arquivo importado 'processado_" + aArqImpSB1[1][1] + "'")

				// Apaga o arquivo caso já exista
				FErase(cPathImpP + "processado_" + aArqImpSB1[1][1])
			EndIf

			FRename(cPathImpNP + aArqImpSB1[1][1], cPathImpP + "processado_" + aArqImpSB1[1][1])

		ElseIf cAlias == "SB0"
			aStruX3 := {}
			cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "AVISO! Início da importação do arquivo <SB0>" + CRLF + CRLF

			// Processa SB0
			nHandle := FT_FUse(cPathImpNP + aArqImpSB0[1][1])
			
			// Se houver erro de abertura abandona processamento
			If nHandle = -1 
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Erro na abertura do arquivo... <" + aArqImpSB0[1][1] + ">")
				cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! Erro na abertura do arquivo <" + aArqImpSB0[1][1] + ">" + CRLF
				cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "Error: " + Str(FError()) + CRLF

				If !lJob
					MsgStop('Erro de abertura : FError ' + Str(FError()))
				EndIf

				// FIM DO PROGRAMA
				U_CstmLogMsg(cLogMsg, "importacao_produtos", cTime)
				Return .F.
			EndIf

			// Verifica tabela DA0
			UpdDA0()

			// Posiciona na primeira linha
			FT_FGoTop()
			
			cCabec := ""
			cTipo := If(SubStr(FT_FReadLn(), 1, 1) == "C", "C", "I") // "C"abecalho ;  "I"tem
			
			While cTipo == "C"
				cCabec += FT_FReadLn()

				// Pula para próxima linha
				FT_FSkip()

				cTipo := If("B0_" $ FT_FReadLn(), "C", "I") // "C"abecalho ;  "I"tem
				lCabec := .T.
			EndDo
			
			// Valida se campos do cabecalho existem no dicionario de dados
			If lCabec	
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Verificando cabecalho do arquivo <SB0>... ")

				cAux := SubStr(cCabec, 3, Len(cCabec)) // cAux := Primeira linha inteira, exceto primeiros dois caracteres "C; "

				// Retorna a linha corrente
				aCabProd := StrToKArr(cAux, ";") // aCabProd := array com os nomes dos campos da tabela no CSV

				SX3->(DBSetOrder(2)) // X3_CAMPO

				For nY := 1 To Len(aCabProd)

					If SX3->(DBSeek(Alltrim(aCabProd[nY])))
						aAdd(aStruX3, {AllTrim(SX3->X3_CAMPO), AllTrim(SX3->X3_TIPO)})
					Else
						ConOut("[" + FWTimeStamp(2) + "] -- " + "Cabecalho do arquivo SB1.CSV esta inconsistente! Verifique se o campo " + Alltrim(aCabProd[nY]) + " existe na base de dados")

						cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "Cabecalho do arquivo SB1.CSV esta inconsistente! Verifique se o campo " + Alltrim(aCabProd[nY]) + " existe na base de dados"
						If !lJob
							MsgStop('Cabecalho do arquivo SB1.CSV esta inconsistente! Verifique se o campo " + aCabProd[nY] + " existe na base de dados')
						EndIf

						// FIM DO PROGRAMA
						U_CstmLogMsg(cLogMsg, "importacao_produtos", cTime)
						Return .F.
					EndIf
				Next nY

			EndIf
			
			ConOut("[" + FWTimeStamp(2) + "] -- " + " Iniciando o processamento dos registros... ")

			cItem 	 := ""

			While !FT_FEOF()
				lNewProd	:= .F.
				
				While !lNewProd .And. !FT_FEOF()
					cX := FT_FReadLn()	// cX := Cada linha com dados do produto

					// Verifica se não houve quebra de linha
					If SubStr(cX, 2, 1) == "I"
						cItem := FT_FReadLn()
					Else
						cItem += FT_FReadLn()
					EndIf

					// Pula para próxima linha
					FT_FSkip()

					If SubStr(FT_FReadLn(), 2, 1) == "I"
						lNewProd := .T.
					EndIf
				EndDo
				
				If cTipo == "I"
					lCabec		:= .F.
					cAux 		:= SubStr(cItem, At('";"', cItem) + 3, Len(cItem)) // Ignora os primeiros caraceteres "C; " ou "I; "

					// Retira aspas duplas antes de separar o array
					aProduto	:= StrToKArr(StrTran(StrTran(cAux, '""', '" "'), '"', ''), ";")

					// Atualiza SB0
					UpdSB0()

					U_CstmLogMsg(cLogMsg, "importacao_produtos", cTime, .F.)

					cLogMsg	:= ""

				EndIf
			EndDo

			// Fecha o arquivo
			FT_FUSE()
			ConOut("[" + FWTimeStamp(2) + "] -- " + " Encerrando arquivo de importacao da tabela <SB0>")
			ConOut("[" + FWTimeStamp(2) + "] -- " + " Renomeando arquivos .csv <" + aArqImpSB0[1][1] + "> para < processado_" + aArqImpSB0[1][1])

			// Verifica se o arquivo já existente na pasta de arquivos processados
			If File(cPathImpP + "processado_" + aArqImpSB0[1][1])
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Apagando arquivo importado 'processado_" + aArqImpSB0[1][1] + "'")

				// Apaga o arquivo caso já exista
				FErase(cPathImpP + "processado_" + aArqImpSB0[1][1])
			EndIf

			FRename(cPathImpNP + aArqImpSB0[1][1], cPathImpP + "processado_" + aArqImpSB0[1][1])

		EndIf
	Next nX

	// FIM DO PROGRAMA
	If !lJob
		AVISO("", "Importação realizada com sucesso!", {"OK"}, 2, "Finalizando a rotina...")
	EndIf
	
	cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "SUCESSO! Importação realizada com sucesso! Finalizando a rotina" + CRLF
	ConOut("[" + FWTimeStamp(2) + "] -- " + " Importacao realizada com sucesso!")

	U_CstmLogMsg(cLogMsg, "importacao_produtos", cTime)

Return .T.



/*/{Protheus.doc} UpdSB0
	Atualiza os campos de preço dos produtos.
	Considera que os produtos já existem e são válidos na base dados.
	
	Deve ser utilizada somente após a execução da função UpdSB1().
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil

@type function
/*/
Static Function UpdSB0()

	Local lEcomm		:= .F.
	
	Local aArea			:= {}
	Local aAreaSB0		:= {}
	Local aTamX3		:= {}

	Local cCampo		:= ""
	Local cTipoCampo	:= ""
	Local cCod			:= ""
	Local cCodOri		:= ""

	Local nI			:= 0
	Local nPrvLj		:= 0
	Local nPrv			:= 0
	Local nPrvMkt		:= 0

	aArea		:= GetArea()
	aAreaSB0	:= SB0->(GetArea())

	// Recupera o código original Datasul do produto
	cCodOri		:= Upper(AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B0_COD"})]))
	
	// Pesquisa pelo código original
	SB0->(DBOrderNickname("XCDORIG")) // B0_FILIAL + B0_XCDORI

	If SB0->(DBSeek(xFilial("SB0") + AvKey(cCodOri, "B0_XCDORI")))

		cCod := Upper(SB0->B0_COD)

		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + " Atualizando registro " + cCod + " na tabela <SB0>. Codigo Datasul: <" + cCodOri + ">" + CRLF
		
		If SB0->B0_ECFLAG == "1"
			lEcomm	:= .T.
		EndIf

		RecLock("SB0", .F.)
		
		For nI := 1 To Len(aStruX3)
			cCampo		:= AllTrim(aStruX3[nI][1])
			cTipoCampo	:= AllTrim(aStruX3[nI][2])
	
			// Recupera o preço E-Commerce
			If cCampo == "B0_PRV1"
				nPrvLj			:= Val(aProduto[nI])
				SB0->B0_PRV1	:= nPrvLj
			ElseIf cCampo == "B0_PRV2"
				nPrv			:= Val(aProduto[nI])
				SB0->B0_PRV2	:= nPrv
			ElseIf cCampo == "B0_PRV3"
				nPrvMkt			:= Val(aProduto[nI])
				SB0->B0_PRV3	:= nPrvMkt
			ElseIf cTipoCampo == "N"
				SB0->&(cCampo) := Val(aProduto[nI])
//				FieldPut(FieldPos(cCampo), Val(aProduto[nI]))
			ElseIf cTipoCampo == "D"
				SB0->&(cCampo) := CToD(aProduto[nI])
//				FieldPut(FieldPos(cCampo), CToD(aProduto[nI]))
			ElseIf !(cCampo == "B0_FILIAL") .And. !(cCampo == "B0_COD")	// Evita a atualização indevida do código do produto

				// Substitui pipes por quebras de linha
				SB0->&(cCampo) := AllTrim(StrTran(aProduto[nI], "|", CRLF))
//				FieldPut(FieldPos(cCampo), AllTrim(StrTran(aProduto[nI], "|", CRLF)))
			EndIf
		Next nI
		
		SB0->(MsUnLock())

		// Atualiza tabela de preço padrão E-Commerce
		UpdDA1(cCod, nPrv, aTabPreco[1][1])

		// Atualiza tabela de preço padrão Loja
		UpdDA1(cCod, nPrvLj, aTabPreco[2][1])

		// Atualiza tabela de preço padrão Market Place
		UpdDA1(cCod, nPrvMkt, aTabPreco[3][1])

		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "SUCESSO! Os preços do produto Datasul " + cCodOri + " foram importados com sucesso na tabela <SB0> para o novo código " + cCod + CRLF
	Else
		ConOut("[" + FWTimeStamp(2) + "] -- " + " Produto nao encontrado na SB0. Codigo Datasul: " + cCodOri + ". Verifique se o produto foi corretamente importado do arquivo <SB1>.")
		cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! O produto de código Datasul " + cCodOri + " não foi encontrado na tabela <SB0>."
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "Verifique se o produto foi corretamente importado do arquivo <SB1>." + CRLF + CRLF
	EndIf

	RestArea(aAreaSB0)
	RestArea(aArea)

Return



/*/{Protheus.doc} UpdSB1
	Atualiza os detalhes dos produtos.
	Considera todas as tabelas e campos necessários para a integração com o Ciashop.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil

@type function
/*/
Static Function UpdSB1()

	Local lEcomm		:= .F.
	Local lNovoProd		:= .F.
	Local lContinua		:= .F.
	Local lAtuProdEC	:= .F.
	Local lCampoIgual	:= .F.

	Local aArea			:= {}
	Local aAreaSB0		:= {}
	Local aAreaSB1		:= {}
	Local aAreaSB5		:= {}
	Local aAreaTmp		:= {}
	Local aSB5			:= {}

	Local cConteudo		:= ""
	Local cCampo		:= ""
	Local cTipoCampo	:= ""
	Local cUpd			:= ""
	Local cCod			:= ""
	Local cCodAnt		:= ""
	Local cEAN			:= ""
	Local cCodFam		:= ""
	Local cCodEmb		:= ""
	Local cCodTam		:= ""
	Local cCodCor		:= ""
	Local cCodPai		:= ""
	Local cDesc			:= ""
	Local cCat			:= ""
	Local cCatFilha		:= ""
	Local cCatNeta		:= ""
	Local cFam			:= ""
	Local cEmb			:= ""
	Local cTam			:= ""
	Local cCor			:= ""
	Local cDescFa		:= ""
	Local cDescTam		:= ""
	Local cDescCor		:= ""
	Local cECDesc		:= ""
	Local cECIndi		:= ""
	Local cECCara		:= ""
	Local cECBene		:= ""
	Local cECApre		:= ""
	Local cCodOri		:= ""
	Local cMascGrd		:= SuperGetMV("MV_MASCGRD", .F., "9,3,3")

	Local nECComp		:= 0
	Local nECLarg		:= 0
	Local nECAltu		:= 0
	Local nStatus		:= 0
	Local nPosCod		:= 0
	Local nI			:= 0
	Local nPeso			:= 0
	Local nPreco		:= 0
	Local nPosFam		:= 0
	Local nFam			:= 0
	Local nEmb			:= 0
	Local nTam			:= 0
	Local nCor			:= 0
	Local nPosCampo		:= 0
	Local nRecNoSB0		:= 0
	Local nRecNoSB1		:= 0

	Local cContSB1		:= ""

	aArea		:= GetArea()
	aAreaSB0	:= SB0->(GetArea())
	aAreaSB1	:= SB1->(GetArea())

	// Recupera o código de barras do produto
	cEAN	:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_CODBAR"})])

	// Recupera o tamanho dos campos de Família, Embalagem, Tamanho e Cor, considerando 5 caracteres para Família e 4 para Embalagem
	nFam	:= 5
	nEmb	:= 4
	nTam	:= Val(Substr(cMascGrd, At(",", cMascGrd) + 1, RAt(",", cMascGrd) - At(",", cMascGrd) - 1))
	nCor	:= Val(Substr(cMascGrd, RAt(",", cMascGrd) + 1))

	// Recupera as informações para montagem do código do produto
	cFam	:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XFAM"})])
	cEmb	:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XEMB"})])
	cTam	:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XTAM"})])
	cCor	:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XCOR"})])

	// Recupera o código original Datasul do produto
	cCodOri	:= Upper(AllTrim(aProduto[aScan(aStruX3, {|x| x[1] = "B1_COD"})]))

	// Monta o novo código do produto
	cCodFam	:= Upper(If(Len(cFam) > nFam, SubStr(cFam, Len(cFam) - nFam + 1), PadL(cFam, nFam, "0")))
	cCodEmb	:= Upper(If(Len(cEmb) > nEmb, SubStr(cEmb, Len(cEmb) - nEmb + 1), PadL(cEmb, nEmb, "0")))
	cCodTam	:= Upper(If(Len(cTam) > nTam, SubStr(cTam, Len(cTam) - nTam + 1), PadL(cTam, nTam, "0")))
	cCodCor	:= Upper(If(Len(cCor) > nCor, SubStr(cCor, Len(cCor) - nCor + 1), PadL(cCor, nCor, "0")))
	cCod	:= Alltrim(cCodFam + cCodEmb + cCodTam + cCodCor)

	// Pesquisa somente por produtos não deletados
	SET DELETED ON

	// Pesquisa pelo código original
	SB1->(DBOrderNickname("XCDORIGIN")) // B1_FILIAL + B1_XCDORI
	
	// Se o item já existe, atualiza, senão, insere
	If SB1->(DBSeek(xFilial("SB1") + AvKey(cCodOri, "B1_XCDORI")))

		lContinua := .T.

		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + " Atualizando registro na tabela <SB1>. Codigo Datasul: <" + cCodOri + ">" + CRLF

		lNovoProd := .F.

		/*
			Realiza as alteraçõs necessárias ao alterar o código do produto
		*/
		// Verifica se a SKU no Protheus precisará ser alterada (caso haja alteração de embalagem, tamanho ou cor)
		If (Alltrim(SB1->B1_COD) == cCod)
			nRecNoSB1 := SB1->(RecNo())
		Else

			// Considera o produto como novo
			lNovoProd := .T.

			// Recupera o código da SKU antiga
			cCodAnt := Alltrim(SB1->B1_COD)

			cLogMsg += "[" + FWTimeStamp(2) + "] -- " + " Registro com alterações de SKU por alteração de embalagem, tamanho ou cor: <" + cCodOri + ">. O registro atual será apagado e um novo será criado." + CRLF

			// Apaga o produto atual da base de dados
			RecLock("SB1", .F.)
//				SB1->B1_XNEWSKU := cCod // Armazena a SKU nova que foi recebida para o produto
//				SB1->B1_XDTHRNS	:= FWTimeStamp(2)
				SB1->(DBDelete()) // Se o novo código já existe em outro produto, apaga este produto
			SB1->(MsUnlock())

			// Verifica se o novo código já existe na base de dados
			aAreaTmp := SB1->(GetArea())
			
			SB1->(DBSetOrder(1)) // B1_FILIAL + B1_COD

			// Se o novo código já existe em outros produtos, apaga estes produtos para evitar conflitos
			If SB1->(DBSeek(xFilial("SB1") + AvKey(cCod, "B1_COD")))
				While !SB1->(EOF()) .And. SB1->B1_FILIAL == xFilial("SB1") .And. SB1->B1_COD == AvKey(cCod, "B1_COD")
					RecLock("SB1", .F.)
						SB1->(DBDelete())
					SB1->(MsUnlock())

					SB1->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			// Pesquisa também por produtos deletados
			SET DELETED OFF

			// Pesquisa pela SKU antiga na SB0 e a altera para a nova
			aAreaTmp := SB0->(GetArea())

			SB0->(DBSetOrder(1)) // B0_FILIAL + B0_COD

			If SB0->(DBSeek(xFilial("SB0") + AvKey(cCodAnt, "B0_COD")))

				cXFilial  := SB0->B0_FILIAL
				nXprv2 	  := SB0->B0_PRV1
				nXprv3    := SB0->B0_PRV2 
				nXecprv   := SB0->B0_ECPRV
				cXectitu  := SB0->B0_ECTITU
				nXecprofu := SB0->B0_ECPROFU
				nXeccomp  := SB0->B0_ECCOMP
				nXeclargu := SB0->B0_ECLARGU
				dData1    := SB0->B0_DATA1
				dData2    := SB0->B0_DATA2
				dData3    := SB0->B0_DATA3
				cXCDORI   := SB0->B0_XCDORI
				
				While !SB0->(EOF()) .And. SB0->B0_FILIAL == xFilial("SB0") .And. SB0->B0_COD == AvKey(cCodAnt, "B0_COD")
					
					//Deleta o cCodAnt posicionado
					RecLock("SB0", .F.)
						SB0->(DBDelete())
					SB0->(MsUnlock())

					//Posiciona no novo registro cCod

	    //Proteção	aSB0bkp := SB0->(GetArea())

					If SB0->(DBSeek(xFilial("SB0") + AvKey(cCod, "B0_COD")))
						lLock := .F. //Se achou Altera
					else
						lLock := .T. //Se não achou Inclui
					EndIf
					
						RecLock("SB0", lLock)
							SB0->B0_FILIAL  := cXFilial
							If lLock
								SB0->B0_COD     := cCod // Altera o SKU na SB0
							EndIf
							SB0->B0_PRV1    := nXprv2 	  
							SB0->B0_PRV2    := nXprv3    
							SB0->B0_ECPRV   := nXecprv   
							SB0->B0_ECTITU  := cXectitu  
							SB0->B0_ECPROFU := nXecprofu 
							SB0->B0_ECCOMP  := nXeccomp   
							SB0->B0_ECLARGU := nXeclargu 
							SB0->B0_DATA1   := dData1     
							SB0->B0_DATA2   := dData2    
							SB0->B0_DATA3 	:= dData3    
							SB0->B0_XCDORI  := cXCDORI    
							SB0->B0_ECDTEX  := ""
							SB0->B0_ECSEQ   := ""
						SB0->(MsUnlock())

		//Proteção	RestArea(aSB0bkp)
					
					SB0->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			// Pesquisa pela SKU antiga na SB5 e a altera para a nova
			aAreaTmp := SB5->(GetArea())

			SB5->(DBSetOrder(1)) // B5_FILIAL + B5_COD

			If SB5->(DBSeek(xFilial("SB5") + AvKey(cCodAnt, "B5_COD")))
				
				While !SB5->(EOF()) .And. SB5->B5_FILIAL == xFilial("SB5") .And. SB5->B5_COD == AvKey(cCodAnt, "B5_COD")
					RecLock("SB5", .F.)
						SB5->B5_COD := cCod // Altera o SKU na SB5
						SB5->B5_ECDTEX := ""
						SB5->B5_ECSEQ := ""
					SB5->(MsUnlock())

					SB5->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			// Verifica se o produto que foi alterado era produto-pai de alguma família, atualizando se for o caso
			aAreaTmp := SB4->(GetArea())

			SB4->(DBSetOrder(1)) // B4_FILIAL + B4_COD

			If SB4->(DBSeek(xFilial("SB4") + AvKey(cCodFam + cCodEmb, "B4_COD")))

				While !SB4->(EOF()) .And. SB4->B4_FILIAL == xFilial("SB4") .And. SB4->B4_COD == AvKey(cCodFam + cCodEmb, "B4_COD")

					// Se o código do produto-pai da família era o código que foi alterado, atualiza para o novo
					If Alltrim(SB4->B4_XPROPAI) == cCodAnt

						RecLock("SB4", .F.)
							SB4->B4_XPROPAI := cCod
						SB4->(MsUnlock())
					EndIf

					SB4->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			// Atualiza os preços dos produtos com a SKU antiga para a SKU atual na DA1
			aAreaTmp := DA1->(GetArea())

			DA1->(DBSetOrder(2)) // DA1_FILIAL + DA1_CODPRO + DA1_CODTAB + DA1_ITEM

			If DA1->(DBSeek(xFilial("DA1") + AvKey(cCodAnt, "DA1_CODPRO")))

				While !DA1->(EOF()) .And. DA1->DA1_FILIAL == xFilial("DA1") .And. DA1->DA1_CODPRO == AvKey(cCodAnt, "DA1_CODPRO")

					RecLock("DA1", .F.)
						DA1->DA1_CODPRO := cCod
						DA1->DA1_ECDTEX := ""
						DA1->DA1_ECSEQ := ""
					DA1->(MsUnlock())

					DA1->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			// Pesquisa somente por produtos não deletados
			SET DELETED ON

			// Verifica se o novo código já existe amarrado a alguma categoria na base de dados
			aAreaTmp := ACV->(GetArea())
			
			ACV->(DBSetOrder(5)) // ACV_FILIAL + ACV_CODPRO + ACV_CATEGO

			// Se o novo código já existe em outras amarrações, apaga estas amarrações para evitar conflitos
			If ACV->(DBSeek(xFilial("ACV") + AvKey(cCod, "ACV_CODPRO")))
				While !ACV->(EOF()) .And. ACV->ACV_FILIAL == xFilial("ACV") .And. ACV->ACV_CODPRO == AvKey(cCod, "ACV_CODPRO")
					RecLock("ACV", .F.)
						ACV->(DBDelete())
					ACV->(MsUnlock())

					ACV->(DBSkip())
				EndDo
			EndIf

			// Atualiza os produtos com a SKU antiga para a SKU atual na ACV
			If ACV->(DBSeek(xFilial("ACV") + AvKey(cCodAnt, "ACV_CODPRO")))

				While !ACV->(EOF()) .And. ACV->ACV_FILIAL == xFilial("ACV") .And. ACV->ACV_CODPRO == AvKey(cCodAnt, "ACV_CODPRO")

					RecLock("ACV", .F.)
						ACV->ACV_CODPRO := cCod
						ACV->ACV_ECDTEX := ""
						ACV->ACV_ECSEQ := ""
					ACV->(MsUnlock())

					ACV->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			// Verifica existência da SKU antiga do produto nas tabelas de localização, alterando o SKU para todos os locais
			aAreaTmp := SBF->(GetArea())

			SBF->(DBSetOrder(2)) // BF_FILIAL + BF_PRODUTO + BF_LOCAL + BF_LOTECTL + BF_NUMLOTE + BF_PRIOR + BF_LOCALIZ + BF_NUMSERI

			// Se o novo código já existe em outros registros, apaga para evitar conflitos
			If SBF->(DBSeek(xFilial("SBF") + AvKey(cCod, "BF_PRODUTO")))
				While !SBF->(EOF()) .And. SBF->BF_FILIAL == xFilial("SBF") .And. SBF->BF_PRODUTO == AvKey(cCod, "BF_PRODUTO")
					RecLock("SBF", .F.)
						SBF->(DBDelete())
					SBF->(MsUnlock())

					SBF->(DBSkip())
				EndDo
			EndIf

			If SBF->(DBSeek(xFilial("SBF") + AvKey(cCodAnt, "BF_PRODUTO")))

				While !SBF->(EOF()) .And. SBF->BF_FILIAL == xFilial("SBF") .And. SBF->BF_PRODUTO == AvKey(cCodAnt, "BF_PRODUTO")

					RecLock("SBF", .F.)
						SBF->BF_PRODUTO := cCod
					SBF->(MsUnlock())

					SBF->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			// Verifica existência da SKU antiga do produto nas tabelas de estoque e movimentações, alterando o SKU para todos os locais
			aAreaTmp := SB2->(GetArea())

			SB2->(DBSetOrder(1)) // B2_FILIAL + B2_COD + B2_LOCAL

			// Se o novo código já existe em outros registros, apaga para evitar conflitos
			If SB2->(DBSeek(xFilial("SB2") + AvKey(cCod, "B2_COD")))
				While !SB2->(EOF()) .And. SB2->B2_FILIAL == xFilial("SB2") .And. SB2->B2_COD == AvKey(cCod, "B2_COD")
					RecLock("SB2", .F.)
						SB2->(DBDelete())
					SB2->(MsUnlock())

					SB2->(DBSkip())
				EndDo
			EndIf

			// Atualiza os produtos com a SKU antiga para a SKU atual
			If SB2->(DBSeek(xFilial("SB2") + AvKey(cCodAnt, "B2_COD")))

				While !SB2->(EOF()) .And. SB2->B2_FILIAL == xFilial("SB2") .And. SB2->B2_COD == AvKey(cCodAnt, "B2_COD")

					RecLock("SB2", .F.)
						SB2->B2_COD := cCod
						SB2->B2_ECSALDO := 0
					SB2->(MsUnlock())

					SB2->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			aAreaTmp := SB9->(GetArea())

			SB9->(DBSetOrder(1)) // B9_FILIAL + B9_COD + B9_LOCAL + DTOS(B9_DATA)

			// Se o novo código já existe em outros registros, apaga para evitar conflitos
			If SB9->(DBSeek(xFilial("SB9") + AvKey(cCod, "B9_COD")))
				While !SB9->(EOF()) .And. SB9->B9_FILIAL == xFilial("SB9") .And. SB9->B9_COD == AvKey(cCod, "B9_COD")
					RecLock("SB9", .F.)
						SB9->(DBDelete())
					SB9->(MsUnlock())

					SB9->(DBSkip())
				EndDo
			EndIf

			If SB9->(DBSeek(xFilial("SB9") + AvKey(cCodAnt, "B9_COD")))

				While !SB9->(EOF()) .And. SB9->B9_FILIAL == xFilial("SB9") .And. SB9->B9_COD == AvKey(cCodAnt, "B9_COD")

					RecLock("SB9", .F.)
						SB9->B9_COD := cCod
					SB9->(MsUnlock())

					SB9->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			aAreaTmp := SBK->(GetArea())

			SBK->(DBSetOrder(1)) // BK_FILIAL + BK_COD + BK_LOCAL + BK_LOTECTL + BK_NUMLOTE + BK_LOCALIZ + BK_NUMSERI + DTOS(BK_DATA)

			// Se o novo código já existe em outros registros, apaga para evitar conflitos
			If SBK->(DBSeek(xFilial("SBK") + AvKey(cCod, "BK_COD")))
				While !SBK->(EOF()) .And. SBK->BK_FILIAL == xFilial("SBK") .And. SBK->BK_COD == AvKey(cCod, "BK_COD")
					RecLock("SBK", .F.)
						SBK->(DBDelete())
					SBK->(MsUnlock())

					SBK->(DBSkip())
				EndDo
			EndIf

			If SBK->(DBSeek(xFilial("SBK") + AvKey(cCodAnt, "BK_COD")))

				While !SBK->(EOF()) .And. SBK->BK_FILIAL == xFilial("SBK") .And. SBK->BK_COD == AvKey(cCodAnt, "BK_COD")

					RecLock("SBK", .F.)
						SBK->BK_COD := cCod
					SBK->(MsUnlock())

					SBK->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			aAreaTmp := SB3->(GetArea())

			SB3->(DBSetOrder(1)) // B3_FILIAL + B3_COD

			// Se o novo código já existe em outros registros, apaga para evitar conflitos
			If SB3->(DBSeek(xFilial("SB3") + AvKey(cCod, "B3_COD")))
				While !SB3->(EOF()) .And. SB3->B3_FILIAL == xFilial("SB3") .And. SB3->B3_COD == AvKey(cCod, "B3_COD")
					RecLock("SB3", .F.)
						SB3->(DBDelete())
					SB3->(MsUnlock())

					SB3->(DBSkip())
				EndDo
			EndIf

			If SB3->(DBSeek(xFilial("SB3") + AvKey(cCodAnt, "B3_COD")))

				While !SB3->(EOF()) .And. SB3->B3_FILIAL == xFilial("SB3") .And. SB3->B3_COD == AvKey(cCodAnt, "B3_COD")

					RecLock("SB3", .F.)
						SB3->B3_COD := cCod
					SB3->(MsUnlock())

					SB3->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			aAreaTmp := SDA->(GetArea())

			SDA->(DBSetOrder(1)) // DA_FILIAL + DA_PRODUTO + DA_LOCAL + DA_NUMSEQ + DA_DOC + DA_SERIE + DA_CLIFOR + DA_LOJA

			// Se o novo código já existe em outros registros, apaga para evitar conflitos
			If SDA->(DBSeek(xFilial("SDA") + AvKey(cCod, "DA_PRODUTO")))
				While !SDA->(EOF()) .And. SDA->DA_FILIAL == xFilial("SDA") .And. SDA->DA_PRODUTO == AvKey(cCod, "DA_PRODUTO")
					RecLock("SDA", .F.)
						SDA->(DBDelete())
					SDA->(MsUnlock())

					SDA->(DBSkip())
				EndDo
			EndIf

			If SDA->(DBSeek(xFilial("SDA") + AvKey(cCodAnt, "DA_PRODUTO")))

				While !SDA->(EOF()) .And. SDA->DA_FILIAL == xFilial("SDA") .And. SDA->DA_PRODUTO == AvKey(cCodAnt, "DA_PRODUTO")

					RecLock("SDA", .F.)
						SDA->DA_PRODUTO := cCod
					SDA->(MsUnlock())

					SDA->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			aAreaTmp := SDB->(GetArea())

			SDB->(DBSetOrder(1)) // DB_FILIAL + DB_PRODUTO + DB_LOCAL + DB_NUMSEQ + DB_DOC + DB_SERIE + DB_CLIFOR + DB_LOJA + DB_ITEM

			// Se o novo código já existe em outros registros, apaga para evitar conflitos
			If SDB->(DBSeek(xFilial("SDB") + AvKey(cCod, "DB_PRODUTO")))
				While !SDB->(EOF()) .And. SDB->DB_FILIAL == xFilial("SDB") .And. SDB->DB_PRODUTO == AvKey(cCod, "DB_PRODUTO")
					RecLock("SDB", .F.)
						SDB->(DBDelete())
					SDB->(MsUnlock())

					SDB->(DBSkip())
				EndDo
			EndIf

			If SDB->(DBSeek(xFilial("SDB") + AvKey(cCodAnt, "DB_PRODUTO")))

				While !SDB->(EOF()) .And. SDB->DB_FILIAL == xFilial("SDB") .And. SDB->DB_PRODUTO == AvKey(cCodAnt, "DB_PRODUTO")

					RecLock("SDB", .F.)
						SDB->DB_PRODUTO := cCod
					SDB->(MsUnlock())

					SDB->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)

			aAreaTmp := SDC->(GetArea())

			SDC->(DBSetOrder(1)) // DC_FILIAL + DC_PRODUTO + DC_LOCAL + DC_ORIGEM + DC_PEDIDO + DC_ITEM + DC_SEQ + DC_LOTCTL + DC_NUMLOTE + DC_LOCALIZ + DC_NUMSERI

			// Se o novo código já existe em outros registros, apaga para evitar conflitos
			If SDC->(DBSeek(xFilial("SDC") + AvKey(cCod, "DC_PRODUTO")))
				While !SDC->(EOF()) .And. SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PRODUTO == AvKey(cCod, "DC_PRODUTO")
					RecLock("SDC", .F.)
						SDC->(DBDelete())
					SDC->(MsUnlock())

					SDC->(DBSkip())
				EndDo
			EndIf

			If SDC->(DBSeek(xFilial("SDC") + AvKey(cCodAnt, "DC_PRODUTO")))

				While !SDC->(EOF()) .And. SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PRODUTO == AvKey(cCodAnt, "DC_PRODUTO")

					RecLock("SDC", .F.)
						SDC->DC_PRODUTO := cCod
					SDC->(MsUnlock())

					SDC->(DBSkip())
				EndDo
			EndIf

			RestArea(aAreaTmp)
		EndIf
		/*
			Fim das alteraçõs necessárias ao alterar o código do produto
		*/
	Else
		// Verifica se o produto já não possui cadastro na base de dados para evitar códigos duplicados
		SB1->(DBSetOrder(1)) // B1_FILIAL + B1_COD

		If !SB1->(DBSeek(xFilial("SB1") + AvKey(cCod, "B1_COD")))

			// Verifica se o EAN do produto já existe na base de dados para evitar códigos duplicados
			SB1->(DBSetOrder(5)) // B1_FILIAL + B1_CODBAR

			If !SB1->(DBSeek(xFilial("SB1") + AvKey(cEAN, "B1_CODBAR")))

				lContinua := .T.

				cLogMsg += "[" + FWTimeStamp(2) + "] -- " + " Inserindo registro na tabela <SB1>. Codigo Datasul: <" + cCodOri + ">" + CRLF

				lNovoProd := .T.
			Else
				lContinua := .F.

				cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! Código EAN " + cEAN + " duplicado na <SB1>! Código original Datasul: " + cCodOri + ". Código Protheus: " + cCod + " Este registro será ignorado." + CRLF
				cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "Verifique se o EAN não está repetido em outro produto." + CRLF + CRLF
			EndIf
		Else
			lContinua := .F.

			cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! Código " + cCod + " duplicado na <SB1>! Código original Datasul: " + cCodOri + ". Este registro será ignorado." + CRLF
			cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "Verifique se os códigos de família, embalagem, tamanho e cor não estão repetidos em outro produto." + CRLF + CRLF
		EndIf		
	EndIf

	If lContinua
		// Recupera informações adicionais do produto
//		cDesc		:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_DESC"})])
		cDesc		:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XECDESC"})])
//		cCat		:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XMARCA"})])
		cCat		:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XCAT"})])
		cCatFilha	:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XSUBCAT"})])
		cCatNeta	:= "" // TODO
		cDescFa		:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XDESCFA"})])
		cDescTam	:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XDESTAM"})])
		cDescCor	:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XDESCOR"})])
		nPeso		:= Val(aProduto[aScan(aStruX3, {|x| x[1] == "B1_PESO"})])
		nPreco		:= Val(aProduto[aScan(aStruX3, {|x| x[1] == "B1_PRV1"})])
		
		// Substitui pipes por quebras de linha nos campos descritivos
		cECDesc		:= StrTran(AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XECDCOM"})]), "|", CRLF)
		cECIndi		:= StrTran(AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XECINDI"})]), "|", CRLF)
		cECCara		:= StrTran(AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XECCARA"})]), "|", CRLF)
		cECBene		:= StrTran(AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XECBENE"})]), "|", CRLF)
		cECApre		:= StrTran(AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XECAPRE"})]), "|", CRLF)

		// Transforma as medidas em centímetros
		nECLarg		:= Val(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XECLARG"})]) / 100
		nECAltu		:= Val(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XECALTU"})]) / 100
		nECComp		:= Val(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XECCOMP"})]) / 100

//		TODO -> Criar campo para importação da categoria neta no arquivo de importação para o Datasul
//		cCatNeta	:= AllTrim(aProduto[aScan(aStruX3, {|x| x[1] == "B1_XCATNET"})]) 

		// Caso o produto esteja marcado para ser enviado para o E-Commerce
		If AllTrim(aProduto[aScan(aStruX3, {|x| x[1] = "B1_XECFLAG"})]) == "sim"
			lEcomm		:= .T.
		EndIf

		// Trava o registro na SB1
		RecLock("SB1", lNovoProd) // If(lNovoProd, RecLock("SB1", .T.), RecLock("SB1", .F.))

		// Atualiza os dados do produto
		For nI := 1 To Len(aStruX3)
			cConteudo	:= aProduto[nI]
			cCampo		:= AllTrim(aStruX3[nI][1])
			cTipoCampo	:= AllTrim(aStruX3[nI][2])
			cContSB1	:= SB1->(&cCampo)

			If(cCampo == "B1_XFAM", cConteudo := cCodFam, )
			If(cCampo == "B1_XEMB", cConteudo := cCodEmb, )
			If(cCampo == "B1_XTAM", cConteudo := cCodTam, )
			If(cCampo == "B1_XCOR", cConteudo := cCodCor, )

			// Verifica se o campo é relacionado à exportação E-Commerce
			nPosCampo	:= aScan(aCamposSB1, cCampo)

			If cCampo == "B1_FILIAL"
				SB1->B1_FILIAL	:= xFilial("SB1")
			ElseIf cCampo == "B1_COD"
				SB1->B1_XCDORI	:= cConteudo
			ElseIf cCampo == "B1_XECFLAG"
				If !lNovoProd .And. !lAtuProdEC .And. !(SB1->B1_XECFLAG == If(lEcomm, "1", "2"))
					lAtuProdEC := .T.
				EndIf

				SB1->B1_XECFLAG := If(lEcomm, "1", "2")
			ElseIf cTipoCampo == "N"
				If !lNovoProd .And. !lAtuProdEC .And. nPosCampo > 0 .And. Val(cConteudo) != cContSB1
					lAtuProdEC := .T.		 
				EndIf

				SB1->(&cCampo) := Val(cConteudo)
//				FieldPut(FieldPos(cCampo), Val(cConteudo))
			ElseIf cTipoCampo == "D"
				If !lNovoProd .And. !lAtuProdEC .And. nPosCampo > 0 .And. !(CToD(cConteudo) == cContSB1)
					lAtuProdEC := .T.	 
				EndIf

				SB1->(&cCampo) := CToD(cConteudo)				
//				FieldPut(FieldPos(cCampo), CToD(cConteudo))
			ElseIf !(cCampo == "B1_COD") .And. !(cCampo == "B1_PRODPAI")	// Evita a atualização indevida do código do produto e do código do produto pai
				// Atualiza somente se o conteúdo a ser inserido OU o conteúdo atual não forem vazios
				If !Empty(cContSB1) .Or. !Empty(StrTran(cConteudo, "|", CRLF))
					// Verifica se o conteúdo dos campos são iguais
					lCampoIgual := AllTrim(cContSB1) == AllTrim(StrTran(cConteudo, "|", CRLF))

					// Se os campos forem diferentes, marca para atualização E-commerce
					If !lNovoProd .And. !lAtuProdEC .And. nPosCampo > 0 .And. !lCampoIgual
						lAtuProdEC := .T.
					EndIf

					// Substitui pipes por quebras de linha
					SB1->(&cCampo) := AllTrim(StrTran(cConteudo, "|", CRLF))	
//					FieldPut(FieldPos(cCampo), AllTrim(StrTran(cConteudo, "|", CRLF)))
				EndIf
			EndIf
		Next nI

		// Verifica se o produto é novo ou se está com o código em branco
		If lNovoProd .Or. Empty(SB1->B1_COD)
			// Armazena o código do produto no registro da tabela
			SB1->B1_COD := cCod
		EndIf

		// Atualiza campo B1_LOCALIZ
		SB1->B1_LOCALIZ	:= "S"

		SB1->(MsUnLock())

		// Trata os produtos a serem enviados para o E-Commerce
		If lEcomm
			// Atualiza tabelas de grade com as informações de tamanho e cor do produto
			UpdSBV(cCodTam, cDescTam, cCodCor, cDescCor)

			// Pesquisa também por produtos deletados
			SET DELETED OFF

			// Verifica se a grade de produto já existe com a família e embalagem do produto
			SB4->(DBSetOrder(1)) // B4_FILIAL + B4_COD

			// Se não existir a família
			If !SB4->(DBSeek(xFilial("SB4") + AvKey(cCodFam + cCodEmb, "B4_COD")))
				// Como é o primeiro produto da família a ser encontrado, será considerado como produto-pai
				cCodPai := cCod

				// Verifica se o produto-pai possui todas as características corretamente preenchidas.
				If Empty(nPeso) .Or. Empty(AllTrim(cDescFa)) .Or. Empty(AllTrim(cECDesc))
					cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! A família de produtos " + cCodFam + cCodEmb + " contém falhas e não será levada ao Ciashop." + CRLF
					cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "Verifique se os campos B1_PESO (peso), B1_XDESCFA (descrição da família) e B1_XECDCOM (descrição comercial E-Commerce) foram corretamente preenchidos no produto-pai " + cCodPai + CRLF + CRLF
				EndIf
			Else
				
				// Recupera o código do produto-pai atual da família
				cCodPai := Alltrim(SB4->B4_XPROPAI)
			EndIf

			// Atualiza grade de produto com o produto pai da família e amarra a família e embalagem com o código do produto-pai
			UpdSB4(cCodPai, cDescFa)

			// Atualiza categorias do produto para a nova família
			UpdCateg(cCodPai, cCat, cCatFilha, cCatNeta)

			// Amarra o produto com a categoria "Todos"
			UpdCateg(cCodPai, "Todos")
			
			// Pesquisa somente por produtos não deletados
			SET DELETED ON
			
			// Atualiza código do produto-pai no produto atual
			SB1->(DBSetOrder(1)) // B1_FILIAL + B1_COD

			If SB1->(DBSeek(xFilial("SB1") + AvKey(cCod, "B1_COD")))
				// Armazena o código do produto-pai no registro, e indica que faz parte de uma grade
				RecLock("SB1", .F.)

					SB1->B1_GRADE	:= "S"
					SB1->B1_PRODPAI := cCodPai

				SB1->(MsUnLock())
			EndIf

			// Verifica o produto-pai da família do produto. Caso exista e não seja o produto atual, envia a família novamente para incluir o produto atual
			// Caso o produto atual não seja novo mas tenha sido modificado, também atualiza o produto-pai
			If (lNovoProd .Or. lAtuProdEC) .And. !(cCodPai == cCod)
				aAreaSB5 := SB5->(GetArea())

				// Pesquisa pelo produto-pai
				SB5->(DBSetOrder(1)) // B5_FILIAL + B5_COD

				If SB5->(DBSeek(xFilial("SB5") + AvKey(cCodPai, "B5_COD")))
					RecLock("SB5", .F.)

						// Libera a família para ser exportada ao Ciashop
						SB5->B5_ECDTEX	:= ""
						SB5->B5_ECSEQ	:= ""

						If SB5->(FieldPos("B5_ECDTEX2")) > 0
							SB5->B5_ECDTEX2	:= ""
						EndIf

						If SB5->(FieldPos("B5_ECSEQ2")) > 0
							SB5->B5_ECSEQ2	:= ""
						EndIf

					SB5->(MsUnlock())
				EndIf

				RestArea(aAreaSB5)
			EndIf
		EndIf

		// Adiciona as informações do produto no array aSB5
		// OBEDECER A ORDEM DEFINIDA NO INÍCIO DO CÓDIGO (#DEFINE)
		aSB5	:=	{	cCod,		cDescFa,	cDesc,		nPeso,		;
						nECComp,	nECLarg,	nECAltu,	cECDesc,	;
						cECIndi,	cECCara,	cECBene,	cECApre		;
					}

		// Atualiza a tabela SB5
		UpdSB5(aSB5, lAtuProdEC)

		// Amarra os códigos novos com os originais Datasul
		UpdSLK(cCod, cCodOri)

		// Amarra os códigos novos e originais Datasul com o fornecedor do produto
		UpdSA5(cCod, cCodOri)

		// Pesquisa também por produtos deletados
		SET DELETED OFF
	
		// Pesquisa pelo novo código
		SB0->(DBSetOrder(1)) // B0_FILIAL + B0_COD

		If SB0->(DBSeek(xFilial("SB0") + AvKey(cCod, "B0_COD")))
			RecLock("SB0", .F.)

			nRecNoSB0 := SB0->(RecNo())
		Else
			RecLock("SB0", .T.)
		EndIf

		// Atualiza dados E-Commerce na tabela SB0
		SB0->B0_FILIAL	:= xFilial("SB0")
		SB0->B0_COD		:= cCod
		SB0->B0_XCDORI	:= cCodOri
		SB0->B0_ECFLAG	:= If(lEcomm, "1", "2")
		SB0->B0_ECTITU	:= If(lEcomm, cDesc, "")
		SB0->B0_ECCOMP	:= nECComp
		SB0->B0_ECLARGU	:= nECLarg
		SB0->B0_ECPROFU	:= nECAltu
		SB0->B0_DATA1	:= DATE()

		// Libera registro para envio ao Ciashop
		If lEcomm .And. (lAtuProdEC .Or. lNovoProd)
			SB0->B0_ECDTEX := ""
		EndIf

		SB0->(MsUnLock())
		
		cUpd := " Update " + RetSQLName("SB0") + CRLF
		cUpd += " Set D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = '0' " + CRLF
		cUpd += " Where D_E_L_E_T_ = '*' " + CRLF
		cUpd += " And B0_COD = '" + cCod + "' " + CRLF
		cUpd += " And B0_XCDORI = '" + cCodOri + "' " + CRLF
		If nRecNoSB0 != 0
			cUpd += " And R_E_C_N_O_ = '" + cValToChar(nRecNoSB0) + "' " + CRLF
		EndIf
		nStatus := TcSqlExec(cUpd)

		If nStatus < 0
			ConOut("TCSQLError(): " + TCSQLError())
			cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
		EndIf

		// Libera registro do produto-pai para envio ao Ciashop
		If lEcomm .And. (lAtuProdEC .Or. lNovoProd)
			If SB0->(DBSeek(xFilial("SB0") + AvKey(cCodPai, "B0_COD")))
				RecLock("SB0", .F.)
				
				SB0->B0_ECDTEX := ""

				SB0->(MsUnLock())
			EndIf
		EndIf
		
		// Pesquisa somente por produtos não deletados
		SET DELETED ON

		// Destrava o produto para uso
		If !lNovoProd
			cUpd := " Update " + RetSQLName("SB1") + CRLF
			cUpd += " Set B1_MSBLQL = '2'" + CRLF
			cUpd += " Where D_E_L_E_T_ <> '*' " + CRLF
			cUpd += " And B1_COD = '" + cCod + "' " + CRLF
			cUpd += " And B1_XCDORI = '" + cCodOri + "' " + CRLF
			If nRecNoSB1 != 0
				cUpd += " And R_E_C_N_O_ = '" + cValToChar(nRecNoSB1) + "' " + CRLF
			EndIf
			nStatus := TcSQLExec (cUpd)

			If nStatus < 0
				ConOut("TCSQLError(): " + TCSQLError())
				cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
			EndIf
		EndIf

		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "SUCESSO! O produto Datasul " + cCodOri + " foi importado na tabela <SB1> com o código " + cCod + CRLF
	EndIf

	RestArea(aAreaSB1)
	RestArea(aAreaSB0)
	RestArea(aArea)

Return



/*/{Protheus.doc} UpdSB4
	Atualiza a tabela de registros de grades de produtos.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil
@param cCodPai, characters, Código do produto pai da grade
@param cDescFa, characters, Descrição da família (grade)

@type function
/*/
Static Function UpdSB4(cCodPai, cDescFa)

	Local aArea		:= {}
	Local aAreaSB1	:= {}
	Local aAreaSB4	:= {}

	Local cCod		:= ""
	Local cUpd		:= ""

	Local nStatus	:= 0
	Local nRecNo	:= 0

	aArea		:= GetArea()
	aAreaSB1	:= SB1->(GetArea())
	aAreaSB4	:= SB4->(GetArea())

	cCod := Upper(SubStr(cCodPai, 1, 9))

	// Pesquisa pelo produto pai
	SB1->(DBSetOrder(1)) // B1_FILIAL + B1_COD
	
	If SB1->(DBSeek(xFilial("SB1") + AvKey(cCodPai, "B1_COD")))
		
		// Pesquisa também por produtos deletados
		SET DELETED OFF
		
		// Cria a grade de produto se não existir
		SB4->(DBSetOrder(1)) // B4_FILIAL + B4_COD

		If SB4->(DBSeek(xFilial("SB4") + AvKey(cCod, "B4_COD")))
			RecLock("SB4", .F.)

			nRecNo := SB4->(RecNo())
		Else
			RecLock("SB4", .T.)
		EndIf

			SB4->B4_FILIAL	:= xFilial("SB4")
			SB4->B4_COD		:= cCod
			SB4->B4_DESC	:= cDescFa
			SB4->B4_LINHA	:= "01"
			SB4->B4_COLUNA	:= "02"
			SB4->B4_TIPO	:= SB1->B1_TIPO
			SB4->B4_UM		:= SB1->B1_UM
			SB4->B4_LOCPAD	:= SB1->B1_LOCPAD
			SB4->B4_TIPCONV	:= SB1->B1_TIPCONV
			SB4->B4_RASTRO	:= SB1->B1_RASTRO
			SB4->B4_LOCALIZ	:= SB1->B1_LOCALIZ
			SB4->B4_GRUPO	:= SB1->B1_GRUPO
			SB4->B4_TE		:= SB1->B1_TE
			SB4->B4_TS		:= SB1->B1_TS
			SB4->B4_SEGUM	:= SB1->B1_SEGUM
			SB4->B4_CONV	:= SB1->B1_CONV
			SB4->B4_PRV1	:= SB1->B1_PRV1
			SB4->B4_PESO	:= SB1->B1_PESO
			SB4->B4_FORAEST	:= SB1->B1_FORAEST
			SB4->B4_PICM	:= SB1->B1_PICM
			SB4->B4_IPI		:= SB1->B1_IPI
			SB4->B4_POSIPI	:= SB1->B1_POSIPI
			SB4->B4_ALIQISS	:= SB1->B1_ALIQISS
			SB4->B4_CODISS	:= SB1->B1_CODISS
			SB4->B4_PICMRET	:= SB1->B1_PICMRET
			SB4->B4_PICMENT	:= SB1->B1_PICMENT
			SB4->B4_CLASFIS	:= SB1->B1_CLASFIS
			SB4->B4_IRRF	:= SB1->B1_IRRF
			SB4->B4_BITMAP	:= SB1->B1_BITMAP
			SB4->B4_XPROPAI	:= cCodPai

		SB4->(MsUnLock())
		
		cUpd := " Update " + RetSQLName("SB4") + CRLF
		cUpd += " Set D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = '0' " + CRLF
		cUpd += " Where D_E_L_E_T_ = '*' " + CRLF
		cUpd += " And B4_COD = '" + cCod + "' " + CRLF
		If nRecNo != 0
			cUpd += " And R_E_C_N_O_ = '" + cValToChar(nRecNo) + "' " + CRLF
		EndIf
		nStatus := TcSqlExec (cUpd)

		If nStatus < 0
			ConOut("TCSQLError(): " + TCSQLError())
			cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
		EndIf
		
		// Pesquisa somente por produtos não deletados
		SET DELETED ON
	Else
		cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! O produto-pai " + cCodPai + " não foi encontrado na tabela <SB1>. Não foi gerado o registro na SB4." + CRLF + CRLF
	EndIf

	RestArea(aAreaSB4)
	RestArea(aAreaSB1)
	RestArea(aArea)

Return



/*/{Protheus.doc} UpdSB5
	Atualiza campos adicionais dos protudos.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil
@param aSB5, array, Array com campos do produto
@param lAtuProdEC, logic, Atualiza campos E-Commerce?

@type function
/*/
Static Function UpdSB5(aSB5, lAtuProdEC)

	Local aArea		:= {}
	Local aAreaSB5	:= {}
	
	Local cUpd		:= ""

	Local nRecNo	:= 0
	Local nStatus	:= 0

	aArea			:= GetArea()
	aAreaSB5		:= SB5->(GetArea())

	// Pesquisa também por produtos deletados
	SET DELETED OFF
		
	// Atualiza SB5
	SB5->(DBSetOrder(1)) // B5_FILIAL + B5_COD

	// Se o registro já existir na base de dados, trava a tabela para alteração, senão trava para inserção
	If SB5->(DBSeek(xFilial("SB5") + AvKey(aSB5[1], "B5_COD")))
		RecLock("SB5", .F.)

		nRecNo := SB5->(RecNo())
	Else
		RecLock("SB5", .T.)
	EndIf

	SB5->B5_FILIAL	:= xFilial("SB5")
	SB5->B5_COD		:= aSB5[COD]		// Código do Produto
	SB5->B5_CEME	:= aSB5[CEME]		// Nome científico SB5
	SB5->B5_ECTITU	:= aSB5[ECTITU]		// Título E-Commerce
	SB5->B5_PESO	:= aSB5[PESO]		// Peso
	SB5->B5_ECCOMP	:= aSB5[ECCOMP]		// Comprimento
	SB5->B5_ECLARGU	:= aSB5[ECLARGU]	// Largura
	SB5->B5_ECPROFU	:= aSB5[ECPROFU]	// Altura
	SB5->B5_ECDESCR	:= aSB5[ECDESCR]	// Descrição E-Commerce
	SB5->B5_ECINDIC	:= aSB5[ECINDIC]	// Indicação E-Commerce
	SB5->B5_ECCARAC	:= aSB5[ECCARAC]	// Características E-Commerce
	SB5->B5_ECBENFI	:= aSB5[ECBENFI]	// Benefício E-Commerce
	SB5->B5_ECAPRES	:= aSB5[ECAPRES]	// Apresentação E-Commerce
	SB5->B5_ECFLAG	:= "1"				// Flag E-Commerce
	SB5->B5_UMIND	:= "1"				// Unidade de medida industrial (campo obrigatório Protheus)
	SB5->B5_TIPO	:= "1"				// Tipo (1 - Material;  2 - Serviço)
	SB5->B5_EAN144	:= 6
	SB5->B5_EAN145	:= 12
	

	If lAtuProdEC
		SB5->B5_ECDTEX	:= " "		// Libera data de exportação E-Commerce
		SB5->B5_ECSEQ	:= ""

		If SB5->(FieldPos("B5_ECDTEX2")) > 0
			SB5->B5_ECDTEX2	:= ""			// Libera data de exportação Ciashop
		EndIf
	EndIf

	SB5->(MsUnLock())

	cUpd := " Update " + RetSQLName("SB5") + CRLF
	cUpd += " Set D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = '0' " + CRLF
	cUpd += " Where D_E_L_E_T_ = '*' " + CRLF
	cUpd += " And B5_COD = '" + aSB5[COD] + "' " + CRLF
	If nRecNo != 0
		cUpd += " And R_E_C_N_O_ = '" + cValToChar(nRecNo) + "' " + CRLF
	EndIf
	nStatus := TcSqlExec (cUpd)

	If nStatus < 0
		ConOut("TCSQLError(): " + TCSQLError())
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
	EndIf
	
	// Pesquisa somente por produtos não deletados
	SET DELETED ON

	RestArea(aAreaSB5)
	RestArea(aArea)

Return



/*/{Protheus.doc} UpdSA5
	Atualiza campos com fornecedor dos protudos e realiza amarração do código Protheus com
a SKU original do Datasul.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil
@param cCod, characters, Código do produto no Protheus
@param cCodOri, characters, Código do produto no Datasul

@type function
/*/
Static Function UpdSA5(cCod, cCodOri)

	Local aArea		:= {}
	Local aAreaSA5	:= {}

	Local cForn		:= ""
	Local cUpd		:= ""

	Local nRecNo	:= 0
	Local nStatus	:= 0

	aArea		:= GetArea()
	aAreaSA5	:= SA5->(GetArea())

	cForn := SuperGetMV("MV_XFORNEC", .F., "ABCDEF12")

	// Pesquisa também por produtos deletados
	SET DELETED OFF
	
	// Atualiza tabela SA5
	SA5->(DBSetOrder(2)) // A5_FILIAL + A5_PRODUTO + A5_FORNECE + A5_LOJA

	If SA5->(DBSeek(xFilial("SA5") + AvKey(cCod, "A5_PRODUTO")))
		RecLock("SA5", .F.)

		nRecNo := SA5->(RecNo())
	Else
		RecLock("SA5", .T.)
	EndIf

		SA5->A5_FILIAL	:= xFilial("SA5")
		SA5->A5_PRODUTO	:= cCod
		SA5->A5_CODPRF	:= cCodOri
		SA5->A5_FORNECE	:= SubStr(cForn, 1, 6)
		SA5->A5_LOJA	:= SubStr(cForn, 7, 2)

	SA5->(MsUnLock())
	
	cUpd := " Update " + RetSQLName("SA5") + CRLF
	cUpd += " Set D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = '0' " + CRLF
	cUpd += " Where D_E_L_E_T_ = '*' " + CRLF
	cUpd += " And A5_PRODUTO = '" + cCod + "' " + CRLF
	cUpd += " And A5_CODPRF = '" + cCodOri + "' " + CRLF
	If nRecNo != 0
		cUpd += " And R_E_C_N_O_ = '" + cValToChar(nRecNo) + "' " + CRLF
	EndIf
	nStatus := TcSqlExec (cUpd)

	If nStatus < 0
		ConOut("TCSQLError(): " + TCSQLError())
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
	EndIf
	
	// Pesquisa somente por produtos não deletados
	SET DELETED ON

	RestArea(aAreaSA5)
	RestArea(aArea)

Return



/*/{Protheus.doc} UpdSLK
	Realiza amarração do código Protheus com a SKU original do Datasul.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil
@param cCod, characters, Código do produto no Protheus
@param cCodOri, characters, Código do produto no Datasul

@type function
/*/
Static Function UpdSLK(cCod, cCodOri)

	Local aArea		:= {}
	Local aAreaSLK	:= {}
	
	Local cUpd		:= ""

	Local nRecNo	:= 0
	Local nStatus	:= 0

	aArea		:= GetArea()
	aAreaSLK	:= SLK->(GetArea())

	// Pesquisa também por produtos deletados
	SET DELETED OFF
	
	// Atualiza tabela SLK
	SLK->(DBSetOrder(1)) // LK_FILIAL + LK_CODIGO + LK_CODBAR

	If !SLK->(DBSeek(xFilial("SLK") + AvKey(cCodOri, "LK_CODBAR")))
		RecLock("SLK", .T.)

			SLK->LK_FILIAL	:= xFilial("SLK")
			SLK->LK_CODBAR	:= cCodOri
			SLK->LK_CODIGO	:= cCod
			SLK->LK_QUANT	:= 1

		SLK->(MsUnLock())
	Else
		nRecNo := SLK->(RecNo())

		If !(SLK->LK_CODIGO == cCod)
			cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "AVISO! O produto " + cCodOri + " teve sua SKU Protheus alterada de " + SLK->LK_CODIGO + " para " + cCod + CRLF

			RecLock("SLK", .F.)

				SLK->LK_CODIGO	:= cCod

			SLK->(MsUnLock())
		EndIf
	EndIf

	cUpd := " Update " + RetSQLName("SLK") + CRLF
	cUpd += " Set D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = '0' " + CRLF
	cUpd += " Where D_E_L_E_T_ = '*' " + CRLF
	cUpd += " And LK_CODBAR = '" + cCodOri + "' " + CRLF
	cUpd += " And LK_CODIGO = '" + cCod + "' " + CRLF
	If nRecNo != 0
		cUpd += " And R_E_C_N_O_ = '" + cValToChar(nRecNo) + "' " + CRLF
	EndIf
	nStatus := TcSqlExec (cUpd)

	If nStatus < 0
		ConOut("TCSQLError(): " + TCSQLError())
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
	EndIf
	
	// Pesquisa somente por produtos não deletados
	SET DELETED ON

	RestArea(aAreaSLK)
	RestArea(aArea)

Return



/*/{Protheus.doc} UpdSBV
	Atualiza tabelas de grade de produto.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil
@param cCodTam, characters, Código do tamanho do produto
@param cDescTam, characters, Descrição do tamanho do produto
@param cCodCor, characters, Código da cor do produto
@param cDescCor, characters, Descrição da cor do produto

@type function
/*/
Static Function UpdSBV(cCodTam, cDescTam, cCodCor, cDescCor)

	Local aArea		:= {}
	Local aAreaSBV	:= {}

	Local cChave	:= ""
	Local cMascGrd	:= SuperGetMV("MV_MASCGRD", .F., "9,3,3")
	Local cUpd		:= ""
	
	Local nStatus	:= 0
	Local nTamChave	:= 0

	aArea		:= GetArea()
	aAreaSBV	:= SBV->(GetArea())

	// Recupera o tamanho do campo TAMANHO
	nTamChave	:= Val(Substr(cMascGrd, At(",", cMascGrd) + 1, RAt(",", cMascGrd) - At(",", cMascGrd) - 1))
	cChave		:= PadL(cCodTam, nTamChave, "0")

	// Pesquisa também por produtos deletados
	SET DELETED OFF
	
	SBV->(DBSetOrder(1)) // BV_FILIAL + BV_TABELA + BV_CHAVE

	// Verifica se o tamanho já existe nas tabelas de grade
	If !SBV->(DBSeek(xFilial("SBV") + AvKey("01", "BV_TABELA") + cChave))
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "AVISO! Cadastrando TAMANHO " + cChave + " - " + cDescTam + CRLF

		RecLock("SBV", .T.)

		SBV->BV_FILIAL	:= xFilial("SBV")
		SBV->BV_TABELA	:= "01"
		SBV->BV_DESCTAB	:= "TAMANHO"
		SBV->BV_CHAVE	:= cChave
		SBV->BV_DESCRI	:= cDescTam
		SBV->BV_TIPO	:= "1"

		SBV->(MsUnLock())
	ElseIf !(AllTrim(SBV->BV_DESCRI) == cDescTam)
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "AVISO! Atualizando descrição de TAMANHO: " + cChave + " - De: '" + AllTrim(SBV->BV_DESCRI) + "' Para: '" + cDescTam + "'" + CRLF

		RecLock("SBV", .F.)

		SBV->BV_DESCRI	:= cDescTam

		SBV->(MsUnLock())
	EndIf
	
	cUpd := " Update " + RetSQLName("SBV") + CRLF
	cUpd += " Set D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = '0' " + CRLF
	cUpd += " Where D_E_L_E_T_ = '*' " + CRLF
	cUpd += " And BV_TABELA = '01' " + CRLF
	cUpd += " And BV_CHAVE = '" + cChave + "' " + CRLF
	nStatus := TcSqlExec (cUpd)

	If nStatus < 0
		ConOut("TCSQLError(): " + TCSQLError())
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
	EndIf

	// Recupera o tamanho do campo COR
	nTamChave	:= Val(Substr(cMascGrd, RAt(",", cMascGrd) + 1))
	cChave		:= PadL(cCodCor, nTamChave, "0")

	// Verifica se a cor já existe nas tabelas de grade
	If !SBV->(DBSeek(xFilial("SBV") + AvKey("02", "BV_TABELA") + cChave))
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "AVISO! Cadastrando COR " + cChave + " - " + cDescCor + CRLF

		RecLock("SBV", .T.)

		SBV->BV_FILIAL	:= xFilial("SBV")
		SBV->BV_TABELA	:= "02"
		SBV->BV_DESCTAB	:= "COR"
		SBV->BV_CHAVE	:= cChave
		SBV->BV_DESCRI	:= cDescCor
		SBV->BV_TIPO	:= "2"

		SBV->(MsUnLock())
	ElseIf !(AllTrim(SBV->BV_DESCRI) == cDescCor)
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "AVISO! Atualizando descrição de COR: " + cChave + " - De: '" + AllTrim(SBV->BV_DESCRI) + "' Para: '" + cDescCor + "'" + CRLF

		RecLock("SBV", .F.)

		SBV->BV_DESCRI	:= cDescCor

		SBV->(MsUnLock())
	EndIf
	
	cUpd := " Update " + RetSQLName("SBV") + CRLF
	cUpd += " Set D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = '0' " + CRLF
	cUpd += " Where D_E_L_E_T_ = '*' " + CRLF
	cUpd += " And BV_TABELA = '02' " + CRLF
	cUpd += " And BV_CHAVE = '" + cChave + "' " + CRLF
	nStatus := TcSqlExec (cUpd)

	If nStatus < 0
		ConOut("TCSQLError(): " + TCSQLError())
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
	EndIf
	
	// Pesquisa somente por produtos não deletados
	SET DELETED ON

	RestArea(aAreaSBV)
	RestArea(aArea)

Return



/*/{Protheus.doc} UpdDA0
	Atualiza cabeçalho das tabelas de preço.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil

@type function
/*/
Static Function UpdDA0()

	Local nX	:= 0

	ConOut("[" + FWTimeStamp(2) + "] -- " + " Verificando tabela <DA0>")

	For nX := 1 To Len(aTabPreco)
		DA0->(DBSetOrder(1)) // DA0_FILIAL + DA0_CODTAB

		If DA0->(DBSeek(xFilial("DA0") + AvKey(aTabPreco[nX][1], "DA0_CODTAB")))
			RecLock("DA0", .F.)
		Else
			RecLock("DA0", .T.)

			DA0->DA0_DATDE	:= DATE()
		EndIf

		DA0->DA0_CODTAB	:= AvKey(aTabPreco[nX][1], "DA0_CODTAB")
		DA0->DA0_DESCRI	:= aTabPreco[nX][2]
		DA0->DA0_HORADE	:= "00:00"
		DA0->DA0_HORATE	:= "23:59"
		DA0->DA0_TPHORA	:= "1"
		DA0->DA0_ATIVO	:= "1"
		DA0->DA0_FILIAL	:= xFilial("DA0")
		DA0->DA0_ECFLAG	:= "1"

		DA0->(MsUnlock())
	Next nX

Return



/*/{Protheus.doc} UpdDA1
	Atualiza o preço do produto na tabela de preços.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil
@param cCod, characters, Código do produto
@param nPrv, numeric, Preço de venda
@param cTabPre, characters, Código da tabela de preços

@type function
/*/
Static Function UpdDA1(cCod, nPrv, cTabPre)

	Local aArea			:= {}
	Local aAreaDA1		:= {}
	Local aTamX3		:= {}

	Local cItTabPre	:= ""
	Local cUpd		:= ""
	Local cQry		:= ""
	Local cAliasDA1	:= ""

	Local nRecNo	:= 0
	Local nStatus	:= 0

	aArea		:= GetArea()
	aAreaDA1	:= DA1->(GetArea())

	// Pesquisa também por produtos deletados
	SET DELETED OFF
	
	DA1->(DBSetOrder(1)) // DA1_FILIAL + DA1_CODTAB + DA1_CODPRO + DA1_INDLOT + DA1_ITEM

	If DA1->(DBSeek(xFilial("DA1") + AvKey(cTabPre, "DA1_CODTAB") + AvKey(cCod, "DA1_CODPRO")))

		nRecNo := DA1->(RecNo())

		If DA1->DA1_PRCVEN != nPrv
			// Atualiza tabela de preços
			RecLock("DA1", .F.)

			DA1->DA1_PRCVEN	:= nPrv

			DA1->DA1_ECDTEX := ""

			DA1->(MsUnLock())
		EndIf

		cUpd := " Update " + RetSQLName("DA1") + CRLF
		cUpd += " Set D_E_L_E_T_ = ' ', R_E_C_D_E_L_ = '0' " + CRLF
		cUpd += " Where D_E_L_E_T_ = '*' " + CRLF
		cUpd += " And DA1_CODTAB = '" + AvKey(cTabPre, "DA1_CODTAB") + "' " + CRLF
		cUpd += " And DA1_CODPRO = '" + AvKey(cCod, "DA1_CODPRO") + "' " + CRLF
		If nRecNo != 0
			cUpd += " And R_E_C_N_O_ = '" + cValToChar(nRecNo) + "' " + CRLF
		EndIf
		nStatus := TcSqlExec(cUpd)

		If nStatus < 0
			ConOut("TCSQLError(): " + TCSQLError())
			cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO SQL! " + TCSQLError() + CRLF + CRLF
		EndIf
	Else
		// Recupera o índice do último item da tabela de preços
		cAliasDA1	:= GetNextAlias()

		cQry := " Select MAX(DA1_ITEM) As DA1_ITEM " + CRLF
		cQry += " From " + RetSQLName("DA1") + CRLF
		cQry += " Where DA1_CODTAB = '" + AvKey(cTabPre, "DA1_CODTAB") + "' " + CRLF
		
		cQry := ChangeQuery(cQry)

		DBUseArea(.T., "TOPCONN", TcGenQry(, , cQry), cAliasDA1, .T., .T.)

		// Se a tabela de preços não possuir produtos amarrados, cria o primeiro produto com índice 1 
		If (cAliasDA1)->(EOF())
			// Cria índice 1 para o produto na amarração com a tabela de preços
			aTamX3		:= TamSX3("DA1_ITEM")
			cItTabPre	:= PadL("1", aTamX3[1], "0")
		Else
			// Recupera o próximo código sequencial de item da tabela de preço
			cItTabPre	:= Soma1((cAliasDA1)->DA1_ITEM)
		EndIf

		(cAliasDA1)->(DBCloseArea())

		// Insere o produto na tabela de preços
		RecLock("DA1", .T.)

		DA1->DA1_FILIAl := xFilial("DA1")
		DA1->DA1_CODTAB	:= AvKey(cTabPre, "DA1_CODTAB")
		DA1->DA1_ITEM	:= cItTabPre
		DA1->DA1_CODPRO	:= AvKey(cCod, "DA1_CODPRO")
		DA1->DA1_PRCVEN	:= nPrv
		DA1->DA1_ATIVO	:= "1"
		DA1->DA1_TPOPER	:= "4"
		DA1->DA1_QTDLOT	:= 999999.99
		DA1->DA1_INDLOT	:= "000000000999999.99 "
		DA1->DA1_MOEDA	:= 1
		DA1->DA1_DATVIG	:= DATE()

		DA1->(MsUnLock())
	EndIf
	
	// Pesquisa somente por produtos não deletados
	SET DELETED ON

	RestArea(aAreaDA1)
	RestArea(aArea)

Return



/*/{Protheus.doc} UpdCateg
	Atualiza as categorias do produto e suas amarrações.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil
@param cCod, characters, Código do produto
@param cCat, characters, Descrição da categoria pai
@param cCatFilha, characters, Descrição da categoria filha (se existir)
@param cCatNeta, characters, Descrição da categoria neta (se existir)

@type function
/*/
Static Function UpdCateg(cCod, cCat, cCatFilha, cCatNeta)

	Local aArea			:= {}
	Local aAreaACU		:= {}
	Local aAreaACV		:= {}
	Local aTamX3		:= {}

	Local lIntegrado	:= .F.
	
	Local cCatAvo		:= ""
	Local cCatPai		:= ""
	Local cCodCat		:= ""
	Local cCodTodos		:= ""
	Local cSeqPrd		:= ""
	Local cQry			:= ""
	Local cAliasACV		:= ""

	aArea		:= GetArea()
	aAreaACU	:= ACU->(GetArea())
	aAreaACV	:= ACV->(GetArea())

	If Empty(cCat) .And. Empty(cCatFilha) .And. Empty(cCatNeta)
		cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! Produto de código novo " + cCod + " não possui categoria cadastrada. A família " + SubStr(cCod, 1, 9) + " não será levada ao Ciashop." + CRLF

		Return
	EndIf

	ACU->(DBOrderNickname("XDESC")) // ACU_FILIAL + ACU_DESC

	// Recupera o código da categoria "Todos". Se não existir, cria-o
	If cCat != "Todos"

		If ACU->(DBSeek(xFilial("ACU") + AvKey("Todos", "ACU_DESC")))

			cCodTodos := ACU->ACU_COD
		Else

			cCodTodos := GetSX8Num("ACU", "ACU_COD")

			RecLock("ACU", .T.)

			ACU->ACU_FILIAL	:= xFilial("ACU")
			ACU->ACU_COD	:= cCodTodos
			ACU->ACU_DESC	:= "Todos"
			ACU->ACU_MSBLQL	:= "2"
			ACU->ACU_ECFLAG	:= "1"

			ACU->(MsUnLock())

			ConfirmSX8()
		EndIf
	EndIf

	// Recupera o código da categoria. Se não existir, cria-o
	If !Empty(cCat) .And. !Empty(cCatFilha) .And. !Empty(cCatNeta)

		While !lIntegrado

			If ACU->(DBSeek(xFilial("ACU") + AvKey(cCat, "ACU_DESC")))
				cCatAvo := ACU->ACU_COD

				If ACU->(DBSeek(xFilial("ACU") + AvKey(cCatFilha, "ACU_DESC")))
					While ACU->(!EOF()) .And. AllTrim(ACU->ACU_DESC) == AllTrim(cCatFilha) .And. ACU->ACU_CODPAI != cCatAvo
						ACU->(DBSkip())
					EndDo

					If ACU->(!EOF()) .And. AllTrim(ACU->ACU_DESC) == AllTrim(cCatFilha) .And. ACU->ACU_CODPAI == cCatAvo
						cCatPai := ACU->ACU_COD

						If ACU->(DBSeek(xFilial("ACU") + AvKey(cCatNeta, "ACU_DESC")))
							While ACU->(!EOF()) .And. AllTrim(ACU->ACU_DESC) == AllTrim(cCatNeta) .And. ACU->ACU_CODPAI != cCatPai
								ACU->(DBSkip())
							EndDo

							If ACU->(!EOF()) .And. AllTrim(ACU->ACU_DESC) == AllTrim(cCatNeta) .And. ACU->ACU_CODPAI == cCatPai
								cCodCat := ACU->ACU_COD
							Else
								cCodCat := GetSX8Num("ACU", "ACU_COD")

								RecLock("ACU", .T.)

								ACU->ACU_FILIAL	:= xFilial("ACU")
								ACU->ACU_COD	:= cCodCat
								ACU->ACU_CODPAI	:= cCatPai
								ACU->ACU_DESC	:= cCatNeta
								ACU->ACU_MSBLQL	:= "2"
								ACU->ACU_ECFLAG	:= "1"

								ACU->(MsUnLock())

								ConfirmSX8()
							EndIf
						Else
							cCodCat := GetSX8Num("ACU", "ACU_COD")

							RecLock("ACU", .T.)

							ACU->ACU_FILIAL	:= xFilial("ACU")
							ACU->ACU_COD	:= cCodCat
							ACU->ACU_CODPAI	:= cCatPai
							ACU->ACU_DESC	:= cCatNeta
							ACU->ACU_MSBLQL	:= "2"
							ACU->ACU_ECFLAG	:= "1"

							ACU->(MsUnLock())

							ConfirmSX8()
						EndIf

						lIntegrado := .T.
					Else
						cCodCat := GetSX8Num("ACU", "ACU_COD")

						RecLock("ACU", .T.)

						ACU->ACU_FILIAL	:= xFilial("ACU")
						ACU->ACU_COD	:= cCodCat
						ACU->ACU_CODPAI	:= cCatAvo
						ACU->ACU_DESC	:= cCatFilha
						ACU->ACU_MSBLQL	:= "2"
						ACU->ACU_ECFLAG	:= "1"

						ACU->(MsUnLock())

						ConfirmSX8()
					EndIf
				Else
					cCodCat := GetSX8Num("ACU", "ACU_COD")

					RecLock("ACU", .T.)

					ACU->ACU_FILIAL	:= xFilial("ACU")
					ACU->ACU_COD	:= cCodCat
					ACU->ACU_CODPAI	:= cCatAvo
					ACU->ACU_DESC	:= cCatFilha
					ACU->ACU_MSBLQL	:= "2"
					ACU->ACU_ECFLAG	:= "1"

					ACU->(MsUnLock())

					ConfirmSX8()
				EndIf
			Else
				cCodCat := GetSX8Num("ACU", "ACU_COD")

				RecLock("ACU", .T.)

				ACU->ACU_FILIAL	:= xFilial("ACU")
				ACU->ACU_COD	:= cCodCat
				ACU->ACU_DESC	:= cCat
				ACU->ACU_MSBLQL	:= "2"
				ACU->ACU_ECFLAG	:= "1"

				ACU->(MsUnLock())

				ConfirmSX8()
			EndIf
		EndDo
	ElseIf !Empty(cCat) .And. !Empty(cCatFilha) .And. Empty(cCatNeta)
		While !lIntegrado

			If ACU->(DBSeek(xFilial("ACU") + AvKey(cCat, "ACU_DESC")))
				cCatPai := ACU->ACU_COD

				If ACU->(DBSeek(xFilial("ACU") + AvKey(cCatFilha, "ACU_DESC")))
					While ACU->(!EOF()) .And. AllTrim(ACU->ACU_DESC) == AllTrim(cCatFilha) .And. ACU->ACU_CODPAI != cCatPai
						ACU->(DBSkip())
					EndDo

					If ACU->(!EOF()) .And. AllTrim(ACU->ACU_DESC) == AllTrim(cCatFilha) .And. ACU->ACU_CODPAI == cCatPai
						cCodCat := ACU->ACU_COD
					Else
						cCodCat := GetSX8Num("ACU", "ACU_COD")

						RecLock("ACU", .T.)

						ACU->ACU_FILIAL	:= xFilial("ACU")
						ACU->ACU_COD	:= cCodCat
						ACU->ACU_CODPAI	:= cCatPai
						ACU->ACU_DESC	:= cCatFilha
						ACU->ACU_MSBLQL	:= "2"
						ACU->ACU_ECFLAG	:= "1"

						ACU->(MsUnLock())
						ConfirmSX8()
					EndIf
				Else
					cCodCat := GetSX8Num("ACU", "ACU_COD")

					RecLock("ACU", .T.)

					ACU->ACU_FILIAL	:= xFilial("ACU")
					ACU->ACU_COD	:= cCodCat
					ACU->ACU_CODPAI	:= cCatPai
					ACU->ACU_DESC	:= cCatFilha
					ACU->ACU_MSBLQL	:= "2"
					ACU->ACU_ECFLAG	:= "1"

					ACU->(MsUnLock())

					ConfirmSX8()
				EndIf

				lIntegrado := .T.
			Else
				cCodCat := GetSX8Num("ACU", "ACU_COD")

				RecLock("ACU", .T.)

				ACU->ACU_FILIAL	:= xFilial("ACU")
				ACU->ACU_COD	:= cCodCat
				ACU->ACU_DESC	:= cCat
				ACU->ACU_MSBLQL	:= "2"
				ACU->ACU_ECFLAG	:= "1"

				ACU->(MsUnLock())

				ConfirmSX8()
			EndIf
		EndDo
	ElseIf !Empty(cCat) .And. Empty(cCatFilha) .And. Empty(cCatNeta)

		If ACU->(DBSeek(xFilial("ACU") + AvKey(cCat, "ACU_DESC")))
			cCodCat := ACU->ACU_COD
		Else
			cCodCat := GetSX8Num("ACU", "ACU_COD")

			RecLock("ACU", .T.)

			ACU->ACU_FILIAL	:= xFilial("ACU")
			ACU->ACU_COD	:= cCodCat
			ACU->ACU_DESC	:= cCat
			ACU->ACU_MSBLQL	:= "2"
			ACU->ACU_ECFLAG	:= "1"

			ACU->(MsUnLock())

			ConfirmSX8()
		EndIf
	Else
//		cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! Produto de código novo " + cCod + " não possui categorias cadastradas corretamente. Favor observar a hierarquia Marca -> Categoria -> Subcategoria" + CRLF
		cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! Produto de código novo " + cCod + " não possui categorias cadastradas corretamente. Favor observar a hierarquia Categoria -> Subcategoria" + CRLF

		Return
	EndIf

	// Recupera o índice do último produto da categoria
	cAliasACV := GetNextAlias()

	cQry := " Select MAX(ACV_SEQPRD) As ACV_SEQPRD " + CRLF
	cQry += " From " + RetSQLName("ACV") + CRLF
	cQry += " Where ACV_CATEGO = '" + AvKey(cCodCat, "ACV_CATEGO") + "' " + CRLF
	
	cQry := ChangeQuery(cQry)

	DBUseArea(.T., "TOPCONN", TcGenQry(, , cQry), cAliasACV, .T., .T.)

	// Se a categoria não possuir produtos amarrados, cria o primeiro produto com índice 1 
	If (cAliasACV)->(EOF())
		// Cria índice 1 para o produto na amarração com a categoria
		aTamX3	:= TamSX3("ACV_SEQPRD")
		cSeqPrd	:= PadL("1", aTamX3[1], "0")
	Else
		// Recupera o próximo código sequencial de produto da categoria
		cSeqPrd	:= Soma1((cAliasACV)->ACV_SEQPRD)
	EndIf

	(cAliasACV)->(DBCloseArea())

	// Cadastra a amarração da categoria com o produto
	ACV->(DBSetOrder(5)) // ACV_FILIAL + ACV_CODPRO + ACV_CATEGO

	// Limpa amarrações erradas de categorias
	If cCat != "Todos"

		If ACV->(DBSeek(xFilial("ACV") + AvKey(cCod, "ACV_CODPRO")))

			While Alltrim(ACV->ACV_CODPRO) == Alltrim(cCod)

				If ACV->ACV_CATEGO != AvKey(cCodCat, "ACV_CATEGO") .And. ACV->ACV_CATEGO != AvKey(cCodTodos, "ACV_CATEGO")

					RecLock("ACV", .F.)
					ACV->(DBDelete())
					ACV->(MsUnlock())
				EndIf
				
				ACV->(DBSkip())
			EndDo
		EndIf
	EndIf

	// Verifica se a amarração com a categoria já existe na base dados
	If !ACV->(DBSeek(xFilial("ACV") + AvKey(cCod, "ACV_CODPRO") + AvKey(cCodCat, "ACV_CATEGO")))

		RecLock("ACV", .T.)

		ACV->ACV_FILIAL	:= xFilial("ACV")
		ACV->ACV_CATEGO	:= cCodCat
		ACV->ACV_CODPRO	:= cCod
		ACV->ACV_SEQPRD	:= cSeqPrd

		ACV->(MsUnLock())
	EndIf

	RestArea(aAreaACV)
	RestArea(aAreaACU)
	RestArea(aArea)

Return



/*/{Protheus.doc} ChckFamilias
	Verifica se as famílias de produtos estão com os produtos-pais válidos na base
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return Nil

@type function
/*/
Static Function ChckFamilias()

	Local aArea		:= {}
	Local aAreaSB1	:= {}
	Local aAreaSB4	:= {}
	
	Local cFam		:= ""
	Local cCod		:= ""
	Local cCodPai	:= ""
	
	Local nPosFam	:= 0
	Local nI		:= 0
	
	aArea		:= GetArea()
	aAreaSB1	:= SB1->(GetArea())
	aAreaSB4	:= SB4->(GetArea())
	
	SB1->(DBSetOrder(1))
	SB4->(DBSetOrder(1))
	SB4->(DBGoTop())
	
	cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + " Verificando famílias de produtos" + CRLF
	ConOut("[" + FWTimeStamp(2) + "] -- " + " Verificando familias de produtos")
	
	While SB4->(!EOF())
		cFam	:= Alltrim(SB4->B4_COD)
		cCodPai	:= Alltrim(SB4->B4_XPROPAI)

		If !SB1->(DBSeek(xFilial("SB1") + AvKey(cCodPai, "B1_COD")))
			cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + " ERRO! A família " + cFam + " apresenta erros. O produto-pai não existe na base dados. A família não irá para o Ciashop." + CRLF
			ConOut("[" + FWTimeStamp(2) + "] -- " + " ERRO! A familia " + cFam + " apresenta erros. O produto-pai não existe na base dados. A família não irá para o Ciashop.")
		ElseIf SB1->B1_MSBLQL = "1"
			cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + " ERRO! A família " + cFam + " apresenta erros. O produto-pai está bloqueado. A família não irá para o Ciashop." + CRLF
			ConOut("[" + FWTimeStamp(2) + "] -- " + " ERRO! A familia " + cFam + " apresenta erros. O produto-pai está bloqueado. A família não irá para o Ciashop.")
		ElseIf Empty(SB1->B1_PESO) .Or. Empty(SB1->B1_XDESCFA) .Or. Empty(SB1->B1_XECDCOM)
			cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + " ERRO! A família " + cFam + " apresenta erros. Verifique se os campos B1_PESO (peso), B1_XDESCFA (descrição da família) e B1_XECDCOM (descrição comercial E-Commerce) foram corretamente preenchidos no produto-pai " + cCodPai + ". A família não irá para o Ciashop." + CRLF
			ConOut("[" + FWTimeStamp(2) + "] -- " + " ERRO! A familia " + cFam + " apresenta erros. Verifique se os campos B1_PESO (peso), B1_XDESCFA (descrição da família) e B1_XECDCOM (descrição comercial E-Commerce) foram corretamente preenchidos no produto-pai " + cCodPai + ". A família não irá para o Ciashop.") 
		EndIf

		SB4->(DBSkip())
	EndDo
	
	RestArea(aAreaSB4)
	RestArea(aAreaSB1)
	RestArea(aArea)

Return



/*/{Protheus.doc} ChckPaths
	Verifica existência dos caminhos de pastas de importação dos produtos.
	Caso o caminho não exista, tenta criá-lo.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return .F. caso ocorra algum erro de leitura ou criação dos caminhos, .T. caso contrário

@type function
/*/
Static Function ChckPaths()

	Local lErro		:= .F.
	Local nX		:= 0

	Local cPath		:= ""
	Local cBarra	:= If(IsSrvUnix(), "/", "\")

//	Local aDirect	:=	{	"integracao_pdv_ciashop" + cBarra + "importacao_produtos" + cBarra + "processados", ; 
//							"integracao_pdv_ciashop" + cBarra + "importacao_produtos" + cBarra + "nao_processados" ;
//						}
	Local aDirect	:=	{	"integrapdv" + cBarra + "importacao" + cBarra + "processados", ;
							"integrapdv" + cBarra + "importacao" + cBarra + "nao_processados";
						}

	// Captura o RootPath do sistema
	cPath := GetSrvProfString("Path", "") + If(Right(GetSrvProfString("Path", ""), 1) == cBarra, "", cBarra) 

	For nX := 1 To Len(aDirect)
		If ExistDir(cPath + aDirect[nX])
			If lJob
				ConOut("[" + FWTimeStamp(2) + "] -- " + " OK! Diretorio existente <" + cPath + aDirect[nX] + ">")
			EndIf
		Else
			If lJob
				ConOut("[" + FWTimeStamp(2) + "] -- " + " Criando diretorio <" + cPath + aDirect[nX] + ">")
			EndIf

			If FwMakeDir(cPath + aDirect[nX])
				If lJob
					ConOut("[" + FWTimeStamp(2) + "] -- " + " Diretorio " + cPath + aDirect[nX] + " criado... ")
				EndIf
			Else
				If lJob
					ConOut("JobImpProduto - MAKEDIR ERROR: " + Str(FError()))
				Else
					cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "ERRO! Makedir Error: " + Str(FError()) + CRLF + CRLF
				EndIf

				lErro := .T.
			EndIf
		EndIf
	Next nX
	
	If !lErro
		If(ExistDir(cPath + aDirect[1]), lErro := .F., lErro := .T.)
		If(ExistDir(cPath + aDirect[2]), lErro := .F., lErro := .T.)

		cPathImpP	:= AllTrim(cPath + aDirect[1] + cBarra)
		cPathImpNP	:= AllTrim(cPath + aDirect[2] + cBarra)
	EndIf

Return !lErro



/*/{Protheus.doc} ChckFiles
	Verifica existência e unicidade dos arquivos de importação dos produtos.
@author Iago Bernardes
@since 25/04/2018
@version 1.0
@return .F. caso ocorra algum erro de abertura dos arquivos, .T. caso contrário

@type function
/*/
Static Function ChckFiles()

	Local nX		:= 0

	ConOut("[" + FWTimeStamp(2) + "] -- " + " Verificando se existem arquivos para processar...")

	// Verifica a existência de arquivos SB0.CSV
	If !File(cPathImpNP + "*sb0.csv")
		ConOut("[" + FWTimeStamp(2) + "] -- " + " Arquivo SB0 inexistente no diretorio de importacao!")
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO! Arquivo SB0 inexistente no diretório de importação!" + CRLF

		If !lJob
			AVISO("", "Arquivo SB0 inexistente no diretorio de importacao!", {"OK"}, 2, "Finalizando a rotina...")
		EndIf

		Return .F.
	EndIf

	aArqImpSB0 := Directory(cPathImpNP + "*sb0.csv")

	For nX := Len(aArqImpSB0) To 1 Step -1
		// Verifica tamanho do nome do arquivo
		If Len(aArqImpSB0[nX][1]) != 21
			aDel(aArqImpSB0, nX)
		EndIf
	Next nX

	// Verifica se o nome do arquivo SB0 é válido
	If aArqImpSB0 == Nil .Or. Len(aArqImpSB0) < 1 .Or. aArqImpSB0[1] == Nil
		ConOut("[" + FWTimeStamp(2) + "] -- " + " Arquivo SB0 invalido no diretorio de importacao!")
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO! Arquivo SB0 invalido no diretório de importação!" + CRLF

		If !lJob
			AVISO("", "Arquivo SB0 invalido no diretorio de importacao!", {"OK"}, 2, "Finalizando a rotina...")
		EndIf

		Return .F.
	// Verifica se o arquivo SB0 é único
	ElseIf Len(aArqImpSB0) > 1 .And. aArqImpSB0[2] != Nil
		ConOut("[" + FWTimeStamp(2) + "] -- " + " Existe mais de um arquivo SB0 no diretorio de importacao!")
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO! Existe mais de um arquivo SB0 no diretório de importação!" + CRLF

		If !lJob
			AVISO("", "Existe mais de um arquivo SB0 no diretorio de importacao!", {"OK"}, 2, "Finalizando a rotina...")
		EndIf

		Return .F.
	EndIf

	// Verifica a existência do arquivo SB1.CSV
	If !File(cPathImpNP + "*sb1.csv")
		ConOut("[" + FWTimeStamp(2) + "] -- " + " Arquivo SB1 inexistente no diretorio de importacao!")
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO! Arquivo SB1 inexistente no diretório de importação!" + CRLF

		If !lJob
			AVISO("", "Arquivo SB1 inexistente no diretorio de importacao!", {"OK"}, 2, "Finalizando a rotina...")
		EndIf

		Return .F.
	EndIf

	aArqImpSB1 := Directory(cPathImpNP + "*sb1.csv")

	For nX := Len(aArqImpSB1) To 1 Step -1
		// Verifica tamanho do nome do arquivo
		If Len(aArqImpSB1[nX][1]) != 21
			aDel(aArqImpSB1, nX)
		EndIf
	Next nX

	// Verifica se o nome do arquivo SB1 é válido
	If aArqImpSB1 == Nil .Or. Len(aArqImpSB1) < 1 .Or. aArqImpSB1[1] == Nil
		ConOut("[" + FWTimeStamp(2) + "] -- " + " Arquivo SB1 invalido no diretorio de importacao!")
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO! Arquivo SB1 invalido no diretório de importação!" + CRLF

		If !lJob
			AVISO("", "Arquivo SB1 invalido no diretorio de importacao!", {"OK"}, 2, "Finalizando a rotina...")
		EndIf

		Return .F.
	// Verifica se o arquivo SB1 é único
	ElseIf Len(aArqImpSB1) > 1 .And. aArqImpSB1[2] != Nil
		ConOut("[" + FWTimeStamp(2) + "] -- " + " Existe mais de um arquivo SB1 no diretorio de importacao!")
		cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "ERRO! Existe mais de um arquivo SB1 no diretório de importação!" + CRLF

		If !lJob
			AVISO("", "Existe mais de um arquivo SB1 no diretorio de importacao!", {"OK"}, 2, "Finalizando a rotina...")
		EndIf

		Return .F.
	EndIf

Return .T.