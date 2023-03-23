#INCLUDE "TOTVS.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

user function envioWF(nomeProcesso, endHTML, empresa, filial, cMsgReprova, cCodDespesa)

Local oProcess
Local oHtml

Default nomeProcesso := "REPROVA_REEMB"
Default endHTML := "\WORKFLOW\REPROVACAO.htm"
Default empresa := cEmpAnt
Default filial := cFilAnt
Default cMsgReprova := 'Schedule'
Default cCodDespesa := '11977145286'

If !empty(empresa) 
	RpcClearEnv() //Se tiver aberto, fecha o ambiente
	RPCSetType(3)  //Nao consome licensas
	lAberto := RpcSetEnv(empresa,filial,,,,GetEnvServer(),{ })
EndIf

oProcess   := TWFProcess():New( "REPROVA_REEMB","Reprova豫o de Reembolso.")
oProcess:NewTask( nomeProcesso, endHTML)
            
    oHtml       := oProcess:oHtml
    oHtml:ValByName( "NREEMBOLSO", cCodDespesa)
    oHtml:ValByName( "INFO" , "Solicita豫o de reembolso rejeitada. Motivo: "+cMsgReprova  )

    //oHtml:ValByName( "COBS"     , "Observa寤es")
    //oHtml:ValByName( "COBS"     , VarInfo("",{"INC_PEDIDO",{aCabPV,aItemPV}},,.F.,.F.))

    oProcess:cTo        := SUPERGETMV("MV_wfTo", .T., "diogo.melo@compila.com.br")
    oProcess:cSubject   := SUPERGETMV("MV_wfSubje", .T., "Rejei豫o de Reembolso")
    oProcess:CFROMNAME  := SUPERGETMV("MV_wfRemet", .T., "No-Reply")
    oProcess:Start()
    oProcess:Free()

return

/*Fun豫o de envio de email*/

User Function oSndMail(cFrom, cBody, cSubJect, cTo, cCC, cBCC, cFileAttach, aInfo )

Local oServer
Local oMessage
Local lEnviado      := .t.
Local cError        := ''

Local endHTML       := GetNewPar("MV_ENDHTML","\WORKFLOW\REPROVACAO.htm")

LOCAL nPOPPort  := GetNewPar("MV_PORPOP3",995)
LOCAL nSMTPPort := GetNewPar("MV_PORSMTP",587)
LOCAL cPopAddr  := GetNewPar("MV_WFPOP3","")
LOCAL cSMTPAddr := GetNewPar("MV_RELSERV","smtp.skymail.net.br")
LOCAL cUser     := GetNewPar("MV_RELAUSR","")
LOCAL cPass     := GetNewPar("MV_RELPSW","")
LOCAL nSMTPTime := GetNewPar("MV_RELTIME",120)
LOCAL lSSLTLS 	:= GetNewPar("MV_RELTLS",.F.)
LOCAL lAutentica:= GetNewPar("MV_RELAUTH",.F.)

//Default cFrom       := If(Empty(cFrom) .Or. cFrom == Nil,cUser, cFrom ) //SuperGetMV( "MV_RELFROM"  )
Default cCC         := ''
Default cBCC        := ''
Default cFileAttach := ''
Default cFrom       := "No-Reply"
Default cBody       := MemoRead(endHTML) //Le o html de dentro da pasta especifica.
Default cSubJect    := "Envio de email - Protheus -"
Default cTo         := Alltrim(Iif(empty(ZA0->ZA0_EMAIL),"lucas.silva@compila.com.br",ZA0->ZA0_EMAIL))
Default aInfo       := {}

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿣erifica se e para autenticar e pega so o nome do usuario
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If lAutentica
	//	cUser := Subs(cUser,1,At("@",cUser)-1)
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿚bj de Mail
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oServer := tMailManager():New()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿢sa SSL na conexao
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oServer:setUseSSL(lSSLTLS)
oServer:SetUseTLS( .T. )
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿔nicializa
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oServer:init(cPopAddr, cSMTPAddr, cUser, cPass, nPOPPort, nSMTPPort)
//oServer:init(cPopAddr, cSMTPAddr, cUser, cPass)
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿏efine o Timeout SMTP
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
If oServer:SetSMTPTimeout(nSMTPTime) != 0
	Conout( "Falha ao setar o time out" )
	cError += "Falha ao setar o time out "+Chr(13)
	lEnviado := .f.
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿎onecta ao servidor
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
nErr := oServer:smtpConnect()
If nErr <> 0
	Conout( "Falha ao conectar" + str(nErr,6) , oServer:getErrorString(nErr) )
	cError += "Falha ao conectar" + str(nErr,6) + oServer:getErrorString(nErr)+Chr(13)
	lEnviado := .f.
	
	oServer:SMTPDisconnect()
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿝ealiza autenticacao no servidor
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
nErr := oServer:smtpAuth(cUser, cPass)
If nErr <> 0
	
	conout("[AUTH] FAIL TRY with ACCOUNT() and PASS()")
	conout("[AUTH][ERROR] " + str(nErr,6) , oServer:getErrorString(nErr))
	
	cError += "[AUTH][ERROR] " + str(nErr,6) + oServer:getErrorString(nErr)+Chr(13)
	
	conout("[AUTH] TRY with USER() and PASS()")
	lEnviado := .f.
	oServer:SMTPDisconnect()
	
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿎ria uma nova mensagem (TMailMessage)
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oMessage := tMailMessage():new()
oMessage:clear()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿏ados da mensagem
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oMessage:cFrom    := cUser
oMessage:cTo      := cTo
oMessage:cCc      := cCC
oMessage:cBcc     := cBCC
oMessage:cSubject := cSubject
/* Tratativa para substitui豫o de paramentro html*/
If len(aInfo) > 0
	cBody := strtran(cBody,"!nreembolso!", aInfo[1])
	cBody := strtran(cBody,"!info!", aInfo[2])
endIf
/**/
oMessage:cBody    := cBody
If !Empty( cFileAttach )
	oMessage:AttachFile( cFileAttach )
EndIf

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿐nvia a mensagem
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
nErr := oMessage:send(oServer)

If nErr <> 0
	Conout( "Erro ao enviar o e-mail" )
	cError += "Erro ao enviar o e-mail: "+oServer:getErrorString(nErr)+Chr(13)
	lEnviado := .f.
	
	oServer:SMTPDisconnect()
	
else
	Conout( "enviado e-mail" )
EndIf
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿏isconecta do Servidor
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
oServer:smtpDisconnect()

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
//쿑im do Metodo
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

Return({lEnviado, cError })

