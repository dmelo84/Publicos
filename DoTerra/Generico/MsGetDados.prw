#include "protheus.ch"
User Function Exemplo()
	Local nI
	Local oDlg
	Local oGetDados
	Local nUsado := 0
	Private lRefresh := .T.
	Private aHeader := {}
	Private aCols := {}
	Private aRotina := {{"Pesquisar", "AxPesqui", 0, 1},;                    
	{"Visualizar", "AxVisual", 0, 2},;                    
	{"Incluir", "AxInclui", 0, 3},;                    
	{"Alterar", "AxAltera", 0, 4},;
	{"Excluir", "AxDeleta", 0, 5}}
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SA1")
	While !Eof() .and. SX3->X3_ARQUIVO == "SA1"
		If X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL        
			nUsado++        
			Aadd(aHeader,{Trim(X3Titulo()),;
			SX3->X3_CAMPO,;                      
			SX3->X3_PICTURE,;                      
			SX3->X3_TAMANHO,;                      
			SX3->X3_DECIMAL,;                      
			SX3->X3_VALID,;                      
			"",;                      
			SX3->X3_TIPO,;                      
			"",;                      
			"" })
		EndIf
		DbSkip()
	End
	Aadd(aCols,Array(nUsado+1))
	For nI := 1 To nUsado    
		aCols[1][nI] := CriaVar(aHeader[nI][2])
	Next
	aCols[1][nUsado+1] := .F.
	DEFINE MSDIALOG oDlg TITLE "Exemplo" FROM 00,00 TO 300,400 PIXEL
	oGetDados := MsGetDados():New(05, 05, 145, 195, 4, "U_LINHAOK", "U_TUDOOK2", "+A1_COD", .T., {"A1_NOME"}, , .F., 200, "U_FIELDOK", "U_SUPERDE1", , "U_DELOK", oDlg)
	ACTIVATE MSDIALOG oDlg CENTERED
Return 
User Function LINHAOK()
	ApMsgStop("LINHAOK")
Return .T. 
User Function TUDOOK2()
	ApMsgStop("LINHAOK")
Return .T. 
User Function DELOK()
	ApMsgStop("DELOK")
Return .T. 
User Function SUPERDE1()
	ApMsgStop("SUPERDEL")
Return .T. 
User Function FIELDOK()
	ApMsgStop("FIELDOK")
Return .T.