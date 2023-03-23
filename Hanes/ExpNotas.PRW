#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FileIO.CH"



/*/{Protheus.doc} JobExpNotas
Job de exportação de notas ficais, títulos financeiros e redução Z
@author Iago Bernardes
@since 17/08/2018
@version 1.0
@return lRet, .T. se execução bem sucedida; .F. caso contrário
@param cEmp, characters, código do grupo de empresas para preparar o ambiente
@param cFil, characters, código da filial para preparar o ambiente
@type function
/*/
User Function JobExpNotas(cEmp, cFil)

	Local aArea := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSE1 := SE1->(GetArea())
	Local aAreaSF1 := SF1->(GetArea())
	Local aAreaSD1 := SD1->(GetArea())
	Local aAreaSF2 := SF2->(GetArea())
	Local aAreaSD2 := SD2->(GetArea())
	Local aAreaSF3 := SF3->(GetArea())
	Local aAreaSFI := SFI->(GetArea())
	Local aAreaSFT := SFT->(GetArea())
	Local aAreaSX3 := SX3->(GetArea())
	
	Local lRet		:= .F.
	Local lContinua := .F.

	Private lJob	:= .T.

	Default cEmp	:= ""
	Default cFil	:= ""

	ConOut("Inicio do Processamento JobExpNotas")

	If Empty(cEmp) .Or. Empty(cFil)

		cEmp := "01"
		cFil := "0103"
	EndIf

	// Inicia Ambiente
	RpcClearEnv()
	RPCSetType(3)
	RpcSetEnv(cEmp, cFil, Nil, Nil, "FAT", Nil, {"SC5", "SE1", "SF1", "SD1", "SF2", "SD2", "SF3", "SFI", "SFT", "SX3"})

	// Controle de Semaforo
	lContinua := LockbyName("U_JobExpNotas", .T.)

	If !lContinua

		RESET ENVIRONMENT

		// Desbloqueando Semaforo
		UnLockbyName("U_JobExpNotas", .T.)
		
		RestArea(aAreaSC5)
		RestArea(aAreaSE1)
		RestArea(aAreaSF1)
		RestArea(aAreaSD1)
		RestArea(aAreaSF2)
		RestArea(aAreaSD2)
		RestArea(aAreaSF3)
		RestArea(aAreaSFI)
		RestArea(aAreaSFT)
		RestArea(aAreaSX3)
		RestArea(aArea)
		
		Return .F.
	EndIf

	lRet := ProcDados(.T.)
		
	ConOut("Fim do Processamento JobExpNotas")

	RESET ENVIRONMENT

	// Desbloqueando Semáforo
	UnLockbyName("U_JobExpNotas", .T.)
	
	RestArea(aAreaSC5)
	RestArea(aAreaSE1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaSF3)
	RestArea(aAreaSFI)
	RestArea(aAreaSFT)
	RestArea(aAreaSX3)
	RestArea(aArea)

Return lRet



/*/{Protheus.doc} ExpNotas
Função de exportação de notas fiscais, títulos financeiros e redução Z
@author Iago Bernardes
@since 17/08/2018
@version 1.0
@return .T. se execução bem sucedida; .F. caso contrário
@type function
/*/
User Function ExpNotas()

	Local aArea := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSE1 := SE1->(GetArea())
	Local aAreaSF1 := SF1->(GetArea())
	Local aAreaSD1 := SD1->(GetArea())
	Local aAreaSF2 := SF2->(GetArea())
	Local aAreaSD2 := SD2->(GetArea())
	Local aAreaSF3 := SF3->(GetArea())
	Local aAreaSFI := SFI->(GetArea())
	Local aAreaSFT := SFT->(GetArea())
	Local aAreaSX3 := SX3->(GetArea())
	
	Local lProcess	:= .F.
	Local lContinua	:= .F.

	Local cTitulo	:= "Integração PDVxDTS - v1.0 - Exportação de Notas e Títulos"
	Local cPerg		:= PadR("SX1INTPDV", Len(SX1->X1_GRUPO))

	Local aSay		:= {}
	Local aBotoes	:= {} 

	Private lJob	:= .F.

	// Controle de Semáforo
	lContinua := LockbyName("U_JobExpNotas", .T.)

	If !lContinua

		AVISO("", "Processo já em uso por outro usuário... ", {"OK"}, 1, "Finalizando!")

		RestArea(aAreaSC5)
		RestArea(aAreaSE1)
		RestArea(aAreaSF1)
		RestArea(aAreaSD1)
		RestArea(aAreaSF2)
		RestArea(aAreaSD2)
		RestArea(aAreaSF3)
		RestArea(aAreaSFI)
		RestArea(aAreaSFT)
		RestArea(aAreaSX3)
		RestArea(aArea)
		
		Return .F.
	EndIf

	lContinua := .F.

	aSay	:=	{ ;
				" Geração de arquivos .csv ", ;
				" ", ;
				" Esta rotina irá executar a exportação dos registros de notas e títulos", ;
				" para serem importados no sistema DataSul, conforme os dados informados", ;
				" nos parametros.", ;
				" ", ;
				"Antes de Clicar em OK Clicar em PARAMETROS", ;
				" ", ;
				" "; 
				}

	aAdd(aBotoes, {5, .T., {|| AjustPerg(cPerg, @lContinua, @lProcess)}})
	aAdd(aBotoes, {1, .T., {|| lProcess := .T., FechaBatch()}})
	aAdd(aBotoes, {2, .T., {|| lProcess := .F., FechaBatch()}})

	FormBatch(cTitulo, aSay, aBotoes, , 240, 510)

	If lProcess .And. lContinua

		MsgRun("Aguarde enquanto as notas são exportadas", "Processando...", {|| ProcDados(lProcess)})
	ElseIf lProcess .And. !lContinua

		Alert("Atenção os parâmetros não foram informados! A rotina não será processada.")
	Else

		AVISO("", "Processo encerrado pelo usuário... ", {"OK"}, 1, "Finalizando!")
	EndIf

	// Desbloqueando Semáforo
	UnLockbyName("U_JobExpNotas", .T.)
	
	RestArea(aAreaSC5)
	RestArea(aAreaSE1)
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaSF3)
	RestArea(aAreaSFI)
	RestArea(aAreaSFT)
	RestArea(aAreaSX3)
	RestArea(aArea)

Return .T.



/*/{Protheus.doc} ProcDados
Exporta em um arquivo de formato CSV as notas fiscais, títulos financeiros
e reduções Z geradas dentro do período de tempo definido antes da execução
da rotina
@author Iago Bernardes
@since 17/08/2018
@version 1.0
@return .T. se execução bem sucedida; .F. caso contrário
@param lOK, logical, realiza o processamento dos dados; deve ser sempre .T.
@type function
/*/
Static Function ProcDados(lOk)
 
	Local nHandle	:= 0
	Local nX		:= 0
	Local nY		:= 0

	Local lContinua	:= .F.

	Local cQry		:= ""
	Local cCodSD	:= ""
	Local cCols		:= ""
	Local cAux		:= ""
	Local cAux2		:= ""
	Local cPath		:= ""
	Local cHead		:= ""
	Local cF3NFiscal:= ""
	Local cF3Serie	:= ""
	Local cAliasQry	:= ""
	Local cTmpQry	:= ""

	Local aNameArq	:= {}
	Local aHead		:= {}
	Local aArea		:= {}
	Local aAreaQry	:= {}

	Local aAliasExp	:=	{"SE1", "SF1", "SD1", "SF2", "SD2", "SFI", "SFT"}

	Private cLogMsg		:= ""
	Private cPathExp	:= ""
	Private cBarra		:= If(isSrvUnix(), "/", "\")
	Private cTime		:= FWTimeStamp(1)

	If !lOk

		Return .F.
	EndIf

	If !ChckPaths()

		Return .F.
	EndIf
	
	If lJob

		MV_PAR01 := Date()
		MV_PAR02 := Date()
		MV_PAR03 := 2 // Por padrão, exporta somente notas fiscais
	EndIf

	// Inicia gravação dos arquivos
	For nX := 1 To Len(aAliasExp)

		aAdd(aNameArq, DtoS(Date()) + StrTran(Time(), ":", "") + aAliasExp[nX] + ".csv")

		ConOut("[" + FWTimeStamp(2) + "]" + " Criando arquivos .csv <" + aNameArq[nX] + "> ")

		// Cria arquivo
		nHandle := FCREATE(cPathExp + aNameArq[nX], FC_NORMAL)

		If nHandle == -1

			ConOut("[" + FWTimeStamp(2) + "]" + " O Arquivo <" + aNameArq[nX] + "> não foi criado.")
			cLogMsg += ("[" + FWTimeStamp(2) + "]" + " O Arquivo (" + aNameArq[nX] + ") não foi criado: " + STR(FERROR())) + "|"
			cLogMsg += ("[" + FWTimeStamp(2) + "]" + " Abortando Operação... ") + "|"

			U_CstmLogMsg(cLogMsg, "exportacao_notas", cTime)

			BREAK 

			Return .F.
		Else

			// Gravação do cabeçalho
//			cCpoExclui := "D2_ITEM"

			ConOut("[" + FWTimeStamp(2) + "]" + " Iniciando a montagem do cabecalho do arquivo de Alias <" + aAliasExp[nX] + ">")
			
			DBSelectArea("SX3")
			SX3->(DBSetOrder(1)) 
			SX3->(DBSeek(aAliasExp[nX]))
			
			While SX3->(!EOF() .And. X3_ARQUIVO == aAliasExp[nX])

				If Alltrim(SX3->X3_CONTEXT) <> "V"

//					If X3_CAMPO <> cCpoExclui .And. X3_TIPO <> "M"
					If X3_TIPO <> "M"

						aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })
						cAux += Alltrim(SX3->X3_CAMPO) + ";"
					EndIf
				EndIf

				SX3->(dbSkip())
			EndDo

			If aAliasExp[nX] == "SF1" .Or. aAliasExp[nX] == "SF2"

				SX3->(DBSetOrder(2))
				
				SX3->(DBSeek("F3_CHVNFE"))
				aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })
				
				SX3->(DBSeek("F3_PROTOC"))
				aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })
				
				SX3->(DBSeek("F3_OBSERV"))
				aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })

				SX3->(DBSeek("F3_ICMSCOM"))
				aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })

				SX3->(DBSeek("F3_BASEDES"))
				aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })

				SX3->(DBSeek("F3_DIFAL"))
				aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })
				
				// Adição dos campos adicionais de dados da NF: chave, protocolo e mensagem retornados pela SeFaz
				cAux += "F3_CHVNFE;F3_PROTOC;F3_OBSERV;F3_ICMSCOM;F3_BASEDES;F3_DIFAL;"

				// Adição dos campos adicionais de dados da NF: situação e tipo de emissão
				// Adição dos campos adicionais de Marketplace: nome do marketplace, código do pedido no marketplace e nome da loja marketplace 
				// Adição do campo adicional de pedido de venda: número do pedido Ciashop
				cAux2 := cAux + "SITUACAO;TIPO_EMIS;C5_NUM;C5_XMPNOME;C5_XMPPEDI;C5_XMPLOJA;C5_PEDECOM;C5_XTRANID;C5_XPAYMID;"

				// Grava cabeçalho no arquivo com as informações adicionais da NF para as tabelas SF1 e SF2
				cHead	:= SubStr(cAux2, 1, Len(cAux2) - 1)
				cAux2	:= ""

				If FWrite(nHandle, cHead) < 0

					ConOut("[" + FWTimeStamp(2) + "]" + " Erro na gravação do arquivo (" + aNameArq[nX] + ") - Error: " + STR(FERROR()))
					cLogMsg += CRLF + ("[" + FWTimeStamp(2) + "]" + " Erro na gravação do arquivo (" + aNameArq[nX] + ") - Error: " + STR(FERROR())) + "|"
					
					If !lJob

						MsgAlert("Erro de gravação: " + STR(FERROR()))
					EndIf
				EndIf

				FWrite(nHandle, CRLF)

				// Altera o cabeçalho para evitar erros na query
				cHead	:= SubStr(cAux, 1, Len(cAux)-1)
				cAux	:= ""
			Else

				If aAliasExp[nX] == "SD1" .Or. aAliasExp[nX] == "SD2"

					SX3->(DBSetOrder(2))
					
					SX3->(DBSeek("FT_BASEPIS"))
					aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })
					
					SX3->(DBSeek("FT_ALIQPIS"))
					aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })
					
					SX3->(DBSeek("FT_VALPIS"))
					aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })

					SX3->(DBSeek("FT_CSTPIS"))
					aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })

					SX3->(DBSeek("FT_BASECOF"))
					aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })

					SX3->(DBSeek("FT_ALIQCOF"))
					aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })

					SX3->(DBSeek("FT_VALCOF"))
					aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })

					SX3->(DBSeek("FT_CSTCOF"))
					aAdd(aHead, { SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE })
					
					// Adição dos campos adicionais de dados fiscais de PIS e COFINS
					cAux += "FT_BASEPIS;FT_ALIQPIS;FT_VALPIS;FT_CSTPIS;FT_BASECOF;FT_ALIQCOF;FT_VALCOF;FT_CSTCOF;"
				EndIf

				// Grava cabeçalho no arquivo
				cHead	:= SubStr(cAux, 1, Len(cAux)-1)
				cAux	:= ""

				If FWrite(nHandle, cHead) < 0

					ConOut("[" + FWTimeStamp(2) + "]" + " Erro na gravação do arquivo (" + aNameArq[nX] + ") - Error: " + STR(FERROR()))
					cLogMsg += CRLF + ("[" + FWTimeStamp(2) + "]" + " Erro na gravação do arquivo (" + aNameArq[nX] + ") - Error: " + STR(FERROR())) + "|"
					
					If !lJob

						MsgAlert("Erro de gravação: " + STR(FERROR()))
					EndIf
				EndIf

				FWrite(nHandle, CRLF)
			EndIf

			//Query de geração de dados para o conteúdo do arquivo .CSV
			cAliasQry := "TMP" + aAliasExp[nX]

			ConOut("[" + FWTimeStamp(2) + "]" + " Iniciando a query (" + cAliasQry + ")")

			cQry := "SELECT " + Alltrim(StrTran(cHead, ";", ", ")) + CRLF
			cQry += "FROM " + RetSqlName(aAliasExp[nX]) + " " + SubStr(aAliasExp[nX], 2, 3) + CRLF

			If aAliasExp[nX] == "SD1"

				cQry += "	INNER JOIN " + RetSqlName("SF1") + " F1 (NOLOCK) " + CRLF
				cQry += "		ON F1_FILIAL = D1_FILIAL "	+ CRLF
				cQry += "			AND F1_DOC = D1_DOC "	+ CRLF
				cQry += "			AND F1_SERIE = D1_SERIE "	+ CRLF
				cQry += "			AND F1_FORNECE = D1_FORNECE "	+ CRLF
				cQry += "			AND F1_LOJA = D1_LOJA "		+ CRLF
				
//				If MV_PAR03 == 2 // Filtra somente notas fiscais transmitidas
//					cQry +=	"					AND F1_CHVNFE <> ''" + CRLF
//				EndIf
			ElseIf aAliasExp[nX] == "SD2"

				cQry += "	INNER JOIN " + RetSqlName("SF2") + " F2 (NOLOCK) "	+ CRLF
				cQry += "		ON F2_FILIAL = D2_FILIAL "	+ CRLF
				cQry += "			AND F2_DOC = D2_DOC "	+ CRLF
				cQry += "			AND F2_SERIE = D2_SERIE "	+ CRLF
				cQry += "			AND F2_CLIENTE = D2_CLIENTE " + CRLF
				cQry += "			AND F2_LOJA = D2_LOJA "		+ CRLF
				
//				If MV_PAR03 == 2 // Filtra somente notas fiscais transmitidas
//					cQry +=	"					AND F2_CHVNFE <> ''" + CRLF
//				EndIf
			ElseIf aAliasExp[nX] == "SF1" .Or. aAliasExp[nX] == "SF2"

				cQry += "INNER JOIN " + RetSqlName("SF3") + " F3 (NOLOCK)"	+ CRLF
				cQry += "	ON F3_FILIAL = " + SubStr(aAliasExp[nX], 2, 3) + "_FILIAL "	+ CRLF
				cQry += "	AND F3_NFISCAL = " + SubStr(aAliasExp[nX], 2, 3) + "_DOC "	+ CRLF
				cQry += "	AND F3_SERIE = " + SubStr(aAliasExp[nX], 2, 3) + "_SERIE "	+ CRLF
				cQry += "	AND F3_CLIEFOR = " + If(aAliasExp[nX] == "SF1", "F1_FORNECE ", "F2_CLIENTE ") + CRLF
				cQry += "	AND F3_LOJA = " + SubStr(aAliasExp[nX], 2, 3) + "_LOJA "		+ CRLF
			ElseIf aAliasExp[nX] == "SE1"

				cQry += "INNER JOIN ( " + CRLF
				cQry +=	"	SELECT F1_FILIAL, F1_DUPL, F1_PREFIXO FROM SF1010 F1 (NOLOCK)" + CRLF
				cQry +=	"	INNER JOIN SF3010 F3 (NOLOCK)" + CRLF
				cQry += "		ON F3_FILIAL = F1_FILIAL "	+ CRLF
				cQry += "		AND F3_NFISCAL = F1_DOC "	+ CRLF
				cQry += "		AND F3_SERIE = F1_SERIE "	+ CRLF
				cQry += "		AND F3_CLIEFOR = F1_FORNECE " + CRLF
				cQry += "		AND F3_LOJA = F1_LOJA "		+ CRLF
				cQry +=	"		WHERE F1_DUPL <> ''" + CRLF
				
				If MV_PAR03 == 1 // Filtra somente cupons fiscais
					cQry +=	"					AND F1_SERIE LIKE 'C0%'" + CRLF
				ElseIf MV_PAR03 == 2 // Filtra somente notas fiscais transmitidas
					cQry +=	"					AND F1_SERIE = '30'" + CRLF
					cQry += "					AND ( F3_CODRSEF = '102' OR F1_CHVNFE <> '' )" + CRLF
				EndIf
				
				cQry +=	"			AND F1_DTDIGIT BETWEEN '" + DtoS(MV_PAR01) + "' and '" + DtoS(MV_PAR02) + "'" + CRLF
				cQry +=	"	) AS T1" + CRLF
				cQry +=	"		ON E1_FILIAL = T1.F1_FILIAL" + CRLF
				cQry +=	"			AND E1_PREFIXO = T1.F1_PREFIXO" + CRLF
				cQry +=	"			AND E1_NUM = T1.F1_DUPL" + CRLF
				cQry +=	"UNION" + CRLF
				cQry +=	"SELECT " + Alltrim(StrTran(cHead, ";", ", ")) + CRLF
				cQry += "FROM SE1010 E1 (NOLOCK)" + CRLF
				cQry +=	"		INNER JOIN (" + CRLF
				cQry +=	"			SELECT F2_FILIAL, F2_DUPL, F2_PREFIXO FROM SF2010 F2 (NOLOCK)" + CRLF
				cQry += "			INNER JOIN " + RetSqlName("SF3") + " F3 (NOLOCK)"	+ CRLF
				cQry += "				ON F3_FILIAL = F2_FILIAL "	+ CRLF
				cQry += "				AND F3_NFISCAL = F2_DOC "	+ CRLF
				cQry += "				AND F3_SERIE = F2_SERIE "	+ CRLF
				cQry += "				AND F3_CLIEFOR = F2_CLIENTE " + CRLF
				cQry += "				AND F3_LOJA = F2_LOJA "		+ CRLF
				cQry +=	"				WHERE F2_DUPL <> ''" + CRLF

				If MV_PAR03 == 1 // Filtra somente cupons fiscais
					cQry +=	"					AND F2_SERIE LIKE 'C0%'" + CRLF
				ElseIf MV_PAR03 == 2 // Filtra somente notas fiscais transmitidas
					cQry +=	"					AND F2_SERIE = '30'" + CRLF
					cQry += "					AND ( F3_CODRSEF = '102' OR F2_CHVNFE <> '' )" + CRLF
				EndIf

				cQry +=	"					AND F2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' and '" + DtoS(MV_PAR02) + "'" + CRLF
				cQry +=	"	) AS T2" + CRLF
				cQry +=	"		ON E1_FILIAL = T2.F2_FILIAL" + CRLF
				cQry +=	"			AND E1_PREFIXO = T2.F2_PREFIXO" + CRLF
				cQry +=	"			AND E1_NUM = T2.F2_DUPL" + CRLF
			ElseIf aAliasExp[nX] == "SFT"

				cQry += "INNER JOIN " + RetSqlName("SF3") + " F3 (NOLOCK)"	+ CRLF
				cQry += "	ON F3_FILIAL = FT_FILIAL "	+ CRLF
				cQry += "	AND F3_NFISCAL = FT_NFISCAL "	+ CRLF
				cQry += "	AND F3_SERIE = FT_SERIE "	+ CRLF
				cQry += "	AND F3_CLIEFOR = FT_CLIEFOR " + CRLF
				cQry += "	AND F3_LOJA = FT_LOJA "		+ CRLF
			EndIf

			If aAliasExp[nX] == "SD1" .Or. aAliasExp[nX] == "SD2"

				cQry += " Inner Join " + RetSqlName("SFT") + " FT (NOLOCK)"	+ CRLF
				cQry += " 			ON FT_Filial = " + SubStr(aAliasExp[nX], 2, 3) + "_Filial " + CRLF
				cQry += " 			and FT_Nfiscal = " + SubStr(aAliasExp[nX], 2, 3) + "_Doc " + CRLF
				cQry += " 			and FT_Serie = " + SubStr(aAliasExp[nX], 2, 3) + "_Serie " + CRLF
				cQry += " 			and FT_Item = " + SubStr(aAliasExp[nX], 2, 3) + "_Item " + CRLF
			EndIf

			cQry += " Where " + SubStr(aAliasExp[nX], 2, 3) + "_Filial = '" + xFilial(aAliasExp[nX]) + "' " + CRLF

			// SF1/ SD1 - Gerar somente as devolucoes no periodo
			If aAliasExp[nX] == "SD1" .Or. aAliasExp[nX] == "SF1"

				If MV_PAR03 == 1 // Filtra somente cupons fiscais
					cQry += "	and " + SubStr(aAliasExp[nX], 2, 3) + "_Serie LIKE 'C0%' " + CRLF
				ElseIf MV_PAR03 == 2 // Filtra somente notas fiscais transmitidas
					cQry += "	and " + SubStr(aAliasExp[nX], 2, 3) + "_Serie = '30' " + CRLF
					
					If aAliasExp[nX] == "SF1"
						cQry += "	and ( F3_CODRSEF = '102' OR F1_CHVNFE <> '' )" + CRLF
					EndIf
				EndIf
				
//				cQry += "	and " + SubStr(aAliasExp[nX], 2, 3) + "_Tipo = 'D' " + CRLF
				cQry += "	and " + SubStr(aAliasExp[nX], 2, 3) + "_Dtdigit Between '" + DtoS(MV_PAR01) + "' and '" + DtoS(MV_PAR02) + "' " + CRLF
			// SFI - Gerar todos os registros no periodo
			ElseIf aAliasExp[nX] == "SFI"

				cQry += "	and FI_Dtredz Between '" + DtoS(MV_PAR01) + "' and '" + DtoS(MV_PAR02) + "' " + CRLF
			// SFT - Gerar somente vendas e devolucoes no periodo
			ElseIf aAliasExp[nX] == "SFT"

				If MV_PAR03 == 1 // Filtra somente cupons fiscais
					cQry +=	"					AND FT_SERIE LIKE 'C0%'" + CRLF
				ElseIf MV_PAR03 == 2 // Filtra somente notas fiscais transmitidas
					cQry +=	"					AND FT_SERIE = '30'" + CRLF
					cQry +=	"					AND (F3_CODRSEF = '102' OR FT_CHVNFE <> '')" + CRLF
				EndIf

				cQry += "	and FT_Emissao Between '" + DtoS(MV_PAR01) + "' and '" + DtoS(MV_PAR02) + "' " + CRLF
			// SF2/ SD2 - Gerar somente vendas no periodo
			ElseIf aAliasExp[nX] == "SF2" .Or. aAliasExp[nX] == "SD2"

				If MV_PAR03 == 1 // Filtra somente cupons fiscais
					cQry += "	and " + SubStr(aAliasExp[nX], 2, 3) + "_Serie LIKE 'C0%' " + CRLF
				ElseIf MV_PAR03 == 2 // Filtra somente notas fiscais transmitidas
					cQry += "	and " + SubStr(aAliasExp[nX], 2, 3) + "_Serie = '30' " + CRLF
					
					If aAliasExp[nX] == "SF2"
						cQry += "	and ( F3_CODRSEF = '102' OR F2_CHVNFE <> '' )" + CRLF
					EndIf
				EndIf

//				cQry += "	and " + SubStr(aAliasExp[nX], 2, 3) + "_Tipo = 'N' " + CRLF
				cQry += "	and " + SubStr(aAliasExp[nX], 2, 3) + "_Emissao Between '" + DtoS(MV_PAR01) + "' and '" + DtoS(MV_PAR02) + "' " + CRLF
			EndIf

			// Mantém arquivos excluídos para poder recuperar as notas canceladas
			If aAliasExp[nX] != "SF1" .And. aAliasExp[nX] != "SF2" .And. aAliasExp[nX] != "SFT" .And. aAliasExp[nX] != "SD1" .And. aAliasExp[nX] != "SD2"

				cQry += "	and " + SubStr(aAliasExp[nX], 2, 3) + ".D_E_L_E_T_ <> '*' " + CRLF
			EndIf

			// Ordena por ordem de período
			If aAliasExp[nX] == "SD1" .Or. aAliasExp[nX] == "SF1"

				cQry += " Order by " + SubStr(aAliasExp[nX], 2, 3) + "_Dtdigit "
			ElseIf aAliasExp[nX] == "SFI"

				cQry += " Order by " + SubStr(aAliasExp[nX], 2, 3) + "_Dtredz "
			ElseIf aAliasExp[nX] == "SF2" .Or. aAliasExp[nX] == "SD2" .Or. aAliasExp[nX] == "SFT" .Or. aAliasExp[nX] == "SE1"

				cQry += " Order by " + SubStr(aAliasExp[nX], 2, 3) + "_Emissao "
			EndIf

			If Select(cAliasQry) > 0

				(cAliasQry)->(DbCloseArea())
			EndIf

			// Ajusta a Query retirando espacos e tabulacoes
			cQry := ChangeQuery(cQry)
			
			MemoWrite("QryExpNotas_" + aAliasExp[nX] + ".sql", cQry)
			cLogMsg += "[" + FWTimeStamp(2) + "] -- " + "AVISO! Query de extração da tabela <" + aAliasExp[nX] + "> montada. Ver arquivo 'QryExpNotas_" + aAliasExp[nX] + ".sql'" + CRLF
			
			ConOut("[" + FWTimeStamp(2) + "]" + " Query de extração da tabela <" + aAliasExp[nX] + "> montada. Ver arquivo 'QryExpNotas_" + aAliasExp[nX] + ".sql' ")
			
			// Executa a Query definindo o RecordSet como uma nova area de trabalho
			DBUseArea(.T., 'TOPCONN', TcGenQry(, , cQry), cAliasQry, .T., .T.)
			
			DBSelectArea(cAliasQry)
			(cAliasQry)->(DbGoTop())

			ConOut("[" + FWTimeStamp(2) + "]" + " Iniciando a exportacao... ")
			cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + "AVISO! Iniciando a exportação das notas" + CRLF

			While (cAliasQry)->(!EOF()) 

				For nY := 1 To Len(aHead)

					// Verifica se é o campo D1_COD ou D2_COD
					If (aAliasExp[nX] == "SD1" .Or. aAliasExp[nX] == "SD2") .And. Alltrim((cAliasQry)->(aHead[nY][1])) == Alltrim(SubStr(aAliasExp[nX], 2, 3) + "_COD")

						// Recupera o código do produto na SD1 ou SD2
						cCodSD := (cAliasQry)->&(aHead[nY][1])

						aAreaQry := GetArea() 

						// Altera o código dos itens das notas para o código original Datasul	
						SB1->(DBSetOrder(1))
						SB1->(DbGoTop())

						If SB1->(DBSeek(xFilial("SB1") + cCodSD))

							cCols += Alltrim(SB1->B1_XCDORI) + ";"
						Else

							cCols += Alltrim((cAliasQry)->&(aHead[nY][1])) + ";"
						EndIf

						RestArea(aAreaQry)
					ElseIf aAliasExp[nX] == "SFT" .And. Alltrim((cAliasQry)->(aHead[nY][1])) == Alltrim("FT_PRODUTO")

						// Recupera o código do produto na SFT
						cCodSD := (cAliasQry)->&(aHead[nY][1])

						aAreaQry := GetArea()

						// Altera o código dos itens das notas para o código original Datasul	
						SB1->(DBSetOrder(1))
						SB1->(DbGoTop())

						If SB1->(DBSeek(xFilial("SB1") + cCodSD))

							cCols += Alltrim(SB1->B1_XCDORI) + ";"
						Else

							cCols += Alltrim((cAliasQry)->&(aHead[nY][1])) + ";"
						EndIf

						RestArea(aAreaQry)
					ElseIf Valtype((cAliasQry)->&(aHead[nY][1])) == "N" //aHead[nY][2] == "N"

						cCols += Alltrim(Transform((cAliasQry)->&(aHead[nY][1]), aHead[nY][5])) + ";"
					ElseIf Valtype((cAliasQry)->&(aHead[nY][1])) == "D"

						cCols += Alltrim(DtoC((cAliasQry)->&(aHead[nY][1]))) + ";"
					ElseIf Valtype((cAliasQry)->&(aHead[nY][1])) == "C"

						cCols += Alltrim((cAliasQry)->&(aHead[nY][1])) + ";"
					EndIf

					// Armazena o número e a série da nota fiscal para tabelas SF1 e SF2
					If (aAliasExp[nX] == "SF1" .Or. aAliasExp[nX] == "SF2")

						If Alltrim((cAliasQry)->(aHead[nY][1])) == Alltrim(SubStr(aAliasExp[nX], 2, 3) + "_DOC")

							cF3NFiscal	:= (cAliasQry)->&(aHead[nY][1])
						ElseIf Alltrim((cAliasQry)->(aHead[nY][1])) == Alltrim(SubStr(aAliasExp[nX], 2, 3) + "_SERIE")

							cF3Serie	:= (cAliasQry)->&(aHead[nY][1])
						EndIf
					EndIf
				Next nY

				// Verifica se é a tabela SF1 ou SF2 para adicionar os dados de situação e tipo de emissão e dados marketplace
				If aAliasExp[nX] == "SF1" .Or. aAliasExp[nX] == "SF2"

					aAreaQry := GetArea()

					// Verifica a situação da nota
					DBSelectArea("SF3")
					SF3->(DBSetOrder(6)) // F3_FILIAL + F3_NFISCAL + F3_SERIE
					SF3->(DbGoTop())

					If SF3->(DBSeek(xFilial("SF3") + cF3NFiscal + cF3Serie))

						If SF3->F3_CODRSEF $ xFunCodSef({"D"})

							cCols += "Denegada;"
						ElseIf SF3->F3_CODRSEF $ xFunCodSef({"I"})

							cCols += "Inutilizada;"
						ElseIf SF3->F3_CODRSEF $ xFunCodSef({"A"})

							cCols += "Autorizada;"
						ElseIf SF3->F3_CODRSEF $ xFunCodSef({"R"})

							cCols += "Rejeitada;"
						ElseIf SF3->F3_CODRSEF $ xFunCodSef({"C"})

							cCols += "Fora de prazo;"
						Else

							cCols += ";"
						EndIf
					Else

						cCols += ";"
					EndIf

					// Verifica o tipo de emissão da nota (contingência ou não)
					cCols += "Normal;" // Não é utilizado o tipo "contingência"
					
					// Recupera os dados do marketplace do pedido relacionado à esta nota fiscal
					cQry := "SELECT C5_NUM, C5_XMPNOME, C5_XMPPEDI, C5_XMPLOJA, C5_PEDECOM," + CRLF
					cQry += "C5_XTRANID, C5_XPAYMID " + CRLF
					cQry += "FROM " + RetSqlName(aAliasExp[nX]) + " " + SubStr(aAliasExp[nX], 2, 3) + CRLF
					cQry += "INNER JOIN " + RetSqlName("SC5") + " C5 (NOLOCK)"	+ CRLF
					cQry += "	ON C5_FILIAL = " + SubStr(aAliasExp[nX], 2, 3) + "_FILIAL "	+ CRLF
					cQry += "	AND C5_NOTA = '" + cF3NFiscal + "'" + CRLF
					cQry += "	AND C5_SERIE = '" + cF3Serie + "'" + CRLF
					cQry += "	AND C5_NOTA = " + SubStr(aAliasExp[nX], 2, 3) + "_DOC " + CRLF
					cQry += "	AND C5_SERIE = " + SubStr(aAliasExp[nX], 2, 3) + "_SERIE "	+ CRLF
					
					cQry := ChangeQuery(cQry)
					
					cTmpQry := GetNextAlias()
					DbUseArea(.T., "TOPCONN", TcGenQry(, , cQry), cTmpQry, .T., .T.)
					(cTmpQry)->(DbGoTop())
					
					If !(cTmpQry)->(EOF())
						
						// Adiciona as colunas resultantes da query na linha atual
						cCols += (cTmpQry)->C5_NUM + ";"
						cCols += (cTmpQry)->C5_XMPNOME + ";"
						cCols += (cTmpQry)->C5_XMPPEDI + ";"
						cCols += (cTmpQry)->C5_XMPLOJA + ";"
						cCols += (cTmpQry)->C5_PEDECOM + ";"
						cCols += (cTmpQry)->C5_XTRANID + ";"
						cCols += (cTmpQry)->C5_XPAYMID + ";"
					Else
						cCols += " ; ; ; ; ;"
					EndIf
					
					(cTmpQry)->(DbCloseArea())

					RestArea(aAreaQry)
				EndIf

				cCols += CRLF

				(cAliasQry)->(DbSkip())
			EndDo

			(cAliasQry)->(DbCloseArea())

			If FWRITE(nHandle, cCols) < 0

				ConOut("[" + FWTimeStamp(2) + "]" + " Erro na gravacao do arquivo (" + aNameArq[nX] + ") - Error: " + STR(FERROR()))
				cLogMsg += CRLF + ("[" + FWTimeStamp(2) + "]" + " Erro na gravação do arquivo (" + aNameArq[nX] + ") - Error: " + STR(FERROR())) + "|"

				If !lJob 

					MsgAlert("Erro de gravação: " + STR(FERROR()))
				EndIf
			EndIf

			// Após arquivo gravado, define a variável de cabeçalho
			cHead := ""
			aHead := {}

			// Fecha o arquivo
			FCLOSE(nHandle)
		EndIf

		cCols := ""
	Next nX

	If !lJob

		AVISO("Sucesso!", "Fim da exportação dos arquivos!", {"OK"}, 2, "Finalizando...")
	EndIf

	U_CstmLogMsg(cLogMsg, "exportacao_notas", cTime)

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
//	Local aDirect	:=	{	"integracao_pdv_ciashop" + cBarra + "exportacao_notas" + cBarra + "processados", ;
//							"integracao_pdv_ciashop" + cBarra + "exportacao_notas" + cBarra + "nao_processados";
//						}
	Local aDirect	:=	{	"integrapdv" + cBarra + "exportacao" + cBarra + "processados", ;
							"integrapdv" + cBarra + "exportacao" + cBarra + "nao_processados";
						}

	// Captura o RootPath do sistema
	cPath := GetSrvProfString("Path", "") + If(Right(GetSrvProfString("Path", ""), 1) == cBarra, "", cBarra)

	For nX := 1 To Len(aDirect)
		
		If ExistDir(cPath + aDirect[nX])

			If lJob

				ConOut("[" + FWTimeStamp(2) + "]" + " OK! Diretorio existente <" + cPath + aDirect[nX] + ">")
			Else

				cLogMsg += "[" + FWTimeStamp(2) + "]" + " OK! Diretorio existente <" + cPath + aDirect[nX] + ">"
			EndIf
		Else

			If lJob

				ConOut("[" + FWTimeStamp(2) + "]" + " Criando diretorio <" + cPath + aDirect[nX] + ">")
			Else
 
				cLogMsg += "[" + FWTimeStamp(2) + "]" + " Criando diretorio <" + cPath + aDirect[nX] + ">" + "|"
			EndIf

			lOk := FwMakeDir(cPath + aDirect[nX], lShowMsg)
			
			If lOk

				If lJob

					ConOut("[" + FWTimeStamp(2) + "]" + " Diretorio criado... ")
				Else

					cLogMsg += "[" + FWTimeStamp(2) + "]" + " Diretorio criado... " + "|"
				EndIf
			Else

				If lJob

					ConOut(Repl("-", 80))
					ConOut("")
					ConOut("JobExpNotas - MAKEDIR ERROR: " + Str(FError())) 
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
		
		// Verifica e renomeia arquivos não transferidos gerados com erro
		If File(cPathExp + "*.csv")

			aArqOld := Directory(cPathExp + "*.csv")

			For nX := 1 To Len(aArqOld)

				If !("OLD" $ aArqOld[nX][1]) .And. ("SE1.CSV" $ aArqOld[nX][1] .Or. "SF1.CSV" $ aArqOld[nX][1] .Or. "SD1.CSV" $ aArqOld[nX][1] ;
													.Or. "SF2.CSV" $ aArqOld[nX][1] .Or. "SD2.CSV" $ aArqOld[nX][1] ;
													.Or. "SFI.CSV" $ aArqOld[nX][1] .Or. "SFT.CSV" $ aArqOld[nX][1])

					ConOut("[" + FWTimeStamp(2) + "]" + " Renomeando arquivos .csv <" + aArqOld[nX][1] + "> ")
					FRename(cPathExp + aArqOld[nX][1], cPathExp + "OLD_" + aArqOld[nX][1])
				EndIf
			Next nX
		EndIf
	EndIf 

Return !lErro 