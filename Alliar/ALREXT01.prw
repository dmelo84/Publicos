#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"   
#INCLUDE "FILEIO.CH"
#INCLUDE "RWMAKE.CH"




/*/{Protheus.doc} ALREXT01
Executa instrucoes SQL no banco de Dados 
@author Leandro Oliveira
@since 08/12/2015
@version 1.0
/*/

User Function ALREXT01()

	Private oLeTxt	
	Private cFile 	:= Space(0)
	Private cDataIni	:= ""
	Private cDataFim	:= ""
	Private aResps 	:= {}
	

	DEFINE MSDIALOG oLeTxt TITLE "SQL EXECUTE" FROM 0,0 TO 175,370 PIXEL
	@ 05,05 TO 55,180 PIXEL
	@ 07,07 Say "Cuidado! Este programa executa instruções SQL no Banco de dados"
		
	@ 70,06 BUTTON "Arquivo SQL" Size 40,12 PIXEL OF oLeTxt ACTION getArq()
	@ 70,94 BUTTON "Cancelar" SIZE 40,12 PIXEL OF oLeTxt ACTION Close(oLeTxt)
	@ 70,140 BUTTON "OK" SIZE 40,12 PIXEL OF oLeTxt ACTION execView()
	ACTIVATE MSDIALOG oLeTxt CENTER

Return



Static Function getArq()
	Local cSql		:= "Consulta SQL (*.sql) |*.sql| Todos os Arquivos (*.*) |*.*"
	cFile 	:= cGetFile(cSql, "Seleção da View" , 0 , "\views\" , .T. , GETF_LOCALHARD, .T.,.T.)
Return



Static Function execView()
		
	Local nTamFile:= 0
	Local nTamLin	:= 0
	Local cBuffer	:= ""
	Local nBtLidos:= ""
	Local cLin		:= ""
	Local cCpo		:= ""
	Local nX		:= 0
	Local cQryTeste := ""
	Local lAlterView := .T.
	Private View 	:= ""
	Private nHdl	:= fOpen(cFile,68)
	Private cEOL	:= CHR(13)+CHR(10)
	
	
	If nHdl == -1
		MsgAlert("O arquivo "+cFile+" não pode ser aberto. Verifique os parametros.","Atencao")
		Return
	Endif
	
	View := pegaView(cFile)
		
	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)       					
	cBuffer  := Space(nTamFile)
	nBtLidos := fRead(nHdl,@cBuffer,nTamFile)	
	cBuffer := upper(strtran(cBuffer,cEol," ")) 

	 
	If At("UPDATE ",cBuffer) > 0 .or. At("DELETE ",cBuffer) > 0 .or. At("ALTER ",cBuffer) > 0 .or. At("DROP ",cBuffer) > 0
		MsgBox("Operação não permitida","Atenção")
		Return
	Endif
	
	If(At("CDATAINI",cBuffer) > 0)
		pegaDatas()		
		cBuffer := StrTran(cBuffer, "CDATAINI", cDataIni)			
		cBuffer := StrTran(cBuffer, "CDATAFIM", cDataFim)
	EndIf
	
	If(At("#", cBuffer) > 0)
		pegaResp(cBuffer)
		pegaVerbas()
		salvaIni()
		For nX := 1 to Len(aResps)
			cBuffer := StrTran(cBuffer, "#"+aResps[nX][1]+"#", TRIM(aResps[nX][2]))
		Next
	Endif
	
	
	// Testa se View ja existe, caso exista altera pra ALTER no lugar de CREATE	
	If (TCSQLExec("SELECT * FROM " + Upper(View)) < 0, lAlterView := .F., lAlterView := .T.)
	If lAlterView
		cBuffer := StrTran(cBuffer, "CREATE VIEW", "ALTER VIEW")
	Endif
	
		
	If (At("MSSQL",alltrim(upper(TcGetDb())))>0)  
		
		If (TCSQLExec(cBuffer) < 0)
			MsgBox("Erro ao executar query."+cEOL+TCSQLError())
			Return
		Endif
		MsgInfo("Instruções executadas no Banco de dados com sucesso!","Sucesso")
	Endif	
Return



Static Function salvaIni()
	Local cIni 	:= StrTran(cFile, ".sql", ".ini")
	Local cArq		:= fOpen(cIni, FO_WRITE)
	Local nX := 0
	Local nCont	:= ""
	
	For nX := 1 to Len(aResps)
		nCont += aResps[nX][1]+"="+aResps[nX][2]+cEOL
	Next

	fSeek(cArq,0,0)
	fWrite(cArq, nCont, Len(nCont))
	
	If !fClose(cArq)
		alert( "Erro ao fechar arquivo: ", fError())
	EndIf
	
Return



Static Function pegaResp(cBuffer)
	Local aTemp 	:= {}
	Local cIni 	:= StrTran(cFile, ".sql", ".ini")
	Local cArqIni := fOpen(cIni,68)
	Local nX	  	:= 0
	Local nTamFile:= 0
	Local cTexto 	:= ""
	Local nBtLidos:= 0
	
	nTamFile := fSeek(cArqIni,0,2)
	fSeek(cArqIni,0,0)       						
	cTexto  := Space(nTamFile)
	nBtLidos := fRead(cArqIni,@cTexto,nTamFile)

	If(nBtLidos < 0)
		Alert("Erro na leitura do arquivo de configuracao")
		Return
	EndIf
		
	aTemp	:= StrTokArr(cTexto, cEOL)  
	
	For nX := 1 to Len(aTemp)
		aadd(aResps, {StrTokArr(aTemp[nX],"=")[1], StrTokArr(aTemp[nX],"=")[2]}) 
	Next
		
	If !fClose(cArqIni)
		alert( "Erro ao fechar arquivo: ", fError())
	EndIf
Return



Static Function pegaView(arq)
	Local ViewName := ""
	Local posPonto := 0  
	Local aDirs := {}  
	
	aDirs := StrTokArr( arq, "\" )
	ViewName := aDirs[len(aDirs)]
	posPonto := at(".", ViewName)-1  
	ViewName := Substr(ViewName, 1, posPonto)
Return ViewName



Static Function pegaDatas()
	Local aRet := {}
	Local aParamBox := {}
	Private cCadastro := "SELECIONE: "

	aAdd(aParamBox,{1,"Data Inicial"  ,Ctod(Space(8)),"","","","",50,.F.}) 
	aAdd(aParamBox,{1,"Data Final"  ,Ctod(Space(8)),"","","","",50,.F.}) 
	
	If ParamBox(aParamBox,"Selecionar Datas",@aRet)
		cDataIni := DtoS(aRet[1])
		cDataFim := DtoS(aRet[2])
	Endif	
Return



Static Function pegaVerbas()
	Local aRet := {}
	Local aParamBox := {}
	Local nX := 0
	Local nY := 0
	Local cCompl := "                                                                                                                       "
	Local cCompleta := ""
	Private cCadastro := "Favor: "

	For nX:= 1 to Len(aResps)
		cCompleta := substring(cCompl, Len(aResps[nX][2]), 120)
		aAdd(aParamBox,{1, aResps[nX][1], aResps[nX][2]+cCompleta,"","","","",110,.F.})	
	Next
	
	If ParamBox(aParamBox,"Informar os codigos de verbas",@aRet)
		For nY := 1 to Len(aResps)
			aResps[nY][2] := Trim(aRet[nY])
		Next
	Endif	
Return