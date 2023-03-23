#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} CstmLogMsg
Gera��o de log de importa��o
@author Iago Bernardes
@since 17/08/2018
@version 1.0
@return lErro, .T. se erro na execu��o da fun��o; .F. caso contr�rio
@param cLogMsg, characters, mensagem a ser gravada no log
@param cFile, characters, nome do arquivo de log
@param cTime, characters, data/hora a ser gravada no arquivo
@param lFim, logical, adiciona marcador de final de arquivo
@type function
/*/
User Function CstmLogMsg(cLogMsg, cFile, cTime, lFim)

	Local lErro		:= .F.

	Local cPath		:= ""
	Local cBarra	:= If(IsSrvUnix(), "/", "\")

	Local nHandle 	:= 0
	
	Default lFim	:= .T.
	
	Default cLogMsg	:= ""
	Default cFile	:= "default"
	Default cTime	:= FWTimeStamp(1)

	// Continua se existir um log a ser gravado
	If Empty(cLogMsg)
		
		Return(!lErro)
	EndIf
	
	// Adiciona data da integra��o no nome do arquivo
	cFile += cTime

	// Captura o RootPath do sistema
	cPath := GetSrvProfString("Path", "") + If(Right(GetSrvProfString("Path", ""), 1) == cBarra, "", cBarra) + "log" + cBarra

	// Se n�o existe o diret�rio, cria-o
	If !ExistDir(cPath)
		// Continua se conseguir criar o diret�rio
		If !FwMakeDir(cPath)
			AVISO("", "Makedir Error: " + Str(FError()), {"OK"}, 1, "Finalizando!")

			lErro := .T.
		EndIf
	EndIf

	If !lErro
		If lFim
			cLogMsg += CRLF + "[" + FWTimeStamp(2) + "] -- " + " ====== = ====== FIM ====== = ====== " + CRLF + CRLF
		EndIf

		// Tenta abrir o arquivo de log
		nHandle := FOpen(cPath + cFile + ".txt" , FO_READWRITE + FO_SHARED)
		
		If nHandle >= 0
			// Posiciona no fim do arquivo
			FSeek(nHandle, 0, FS_END)
			
			// Grava o log
			If FWrite(nHandle, cLogMsg, LEN(cLogMsg)) < 0
				lErro := .T.
			EndIf
		
			// Fecha o arquivo
			FClose(nHandle)
		Else
			// Cria arquivo de log
			nHandle := FCreate(cPath + cFile + ".txt", FC_NORMAL)
			
			// Se n�o conseguir criar o arquivo
			If nHandle < 0
				Break

				Return .F.
			Else
				If FWrite(nHandle, cLogMsg, Len(cLogMsg)) < 0

					lErro := .T.
				EndIf

				// Fecha o arquivo
				FClose(nHandle)
			EndIf
		EndIf
	EndIf

Return(!lErro)