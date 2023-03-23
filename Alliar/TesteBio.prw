#Include 'Protheus.ch'

User Function TesteBio()
	Local oBionexo 	:= WSBionexoBeanService():New()
	Local cMsgErro	:= ""
	
	oBionexo:clogin             := "totvs.csc"
	oBionexo:cpassword          := "12345"
	oBionexo:coperation         := "WMG" 
	oBionexo:cparameters        := "LAYOUT=WM;ISO=1; CNPJ=123456" 

	If oBionexo:Request()
		ConOut("************************************************************")
		ConOut("TESTEBIO - " + DtoC(Date()) + " - " + Time())
		ConOut("Conexao OK")
		ConOut("************************************************************")
	Else
		cMsgErro := "Erro ao Efetuar a Conexão ao Bionexo:" + CRLF
		cMsgErro += GetWSCError()

		ConOut("************************************************************")
		ConOut("TESTEBIO - " + DtoC(Date()) + " - " + Time())
		ConOut(cMsgErro)
		ConOut("************************************************************")
	EndIf

Return NIL
