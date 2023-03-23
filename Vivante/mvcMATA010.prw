#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "JPEG.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "SHELL.CH"   

#define _CRLF CHR(13)+CHR(10)

/*=========================
 MVC com envio de email
==========================*/
/*------------------------------------------------------------------------
EXEMPLO DE INCLUSÃO NA TABELA SB5 UTILIZANDO MVC
------------------------------------------------------------------------*/

User Function ITEM

/*Padrão do ponto*/
    Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj     
    Local cIdPonto   := ""
    Local cIdModel   := ""
    Local lIsGrid    := .F.
/*======================*/ 
    Local cMsg       := ""
    Local nOpc
    Local aInfo := {}
    Local lCadMail    := GetMv("MV_CADMAIL")
    Local cMsg := ""
    Local cQry := ''
    Local nCount := 0
    Local cListMail := ''
    Local lEnviou := .F.
/*=======================*/  
   Local Contato := "Vivante S.A"
   Local Assunto := "Inclusão de Reclamação Trabalhista"

    /*============================
    Tratativa no envio via lista
    ==============================*/
      If lCadMail
      cMsg += "Parâmetro MV_CADMAIL está igual a .T. para que inclua os emails dos destinatarios do aviso." +_CRLF
      cMsg += "Após o cadastro dos emails o paramêtro grava .F. .Sendo assim, para novos cadastros o usuário do T.I deverá " +_CRLF
      cMsg += "habilitar o parametro via configurador."
      Aviso("Cadastro Email",cMsg,{"Entendido."},3)
         u_xCadEmail()
      PutMv("MV_CADMAIL", .F.)
      EndIf

    /*=====================================
    Leitura da lista de email cadastrados
    =====================================*/
If Empty(cListMail)

   cQry := "Select * from "+RetSqlName("Z03") +_CRLF
   cQry += "Where D_E_L_E_T_ != '*' " +_CRLF
   cQry += "and Z03_MSBLQL != 'S' "

   nStatus := TCSqlExec(cQry)

    if (nStatus < 0)
        conout("TCSQLError() " + TCSQLError())
        Msginfo("TCSQLError() " + TCSQLError())
        Return
    endif

    If select('TMP') > 0
        TMP->(dbCloseArea())
    EndIf

   TCQuery (cQry) ALIAS "TMP" NEW

   While TMP->(!eof())
      nCount++
         iF nCount > 1
            cListMail += ";"+Alltrim(TMP->Z03_EMAIL)
         else
            cListMail := alltrim(TMP->Z03_EMAIL)
         endif
   TMP->(dbSkip())
   EndDo
EndIf   

    If (aParam <> NIL)
        oObj     := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid  := (Len(aParam) > 3)

        nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO

        If (cIdPonto =="MODELCOMMITTTS")
            //   MsgInfo("Chamada após a gravação total do modelo e dentro da transação.")
               cCodigo := oObj:GetValue("SB1MASTER", "B1_COD")
               cDescri := oObj:GetValue("SB1MASTER", "B1_DESC")
               cLocal  := oObj:GetValue("SB1MASTER", "B1_LOCPAD")
               aAdd(aInfo,{cCodigo,cDescri,cLocal})

            /*=================
               Destinatários
            ===================*/
            If !empty(cListMail)
                  _cPara := cListMail
            Else 
                  cMsg := "Lista de email não preenchida, altere o parâmento MV_CADMAIL para .T. via configurador para cadastrar."
                  Aviso("Cadastro Email",cMsg,{"Entendido."},3)
            EndIf
            /*==============
            Chamada do email
            ==============*/

            lEnviou := EnvMail(Contato, Assunto, /*_cDE*/"", _cPara, "", /*_cMemo*/"", .F., /*_bCC*/"", /*_cPathHtm*/"", aInfo)	
            If !lEnviou
                  Msginfo("Email não enviado. Verifique as configurações de rede.")
            EndIf
         EndIf
   EndIf 
Return (xRet)

/*==========================
  Função de chamada do email
============================*/

static Function EnvMail(_cContato, _cAssunto, _cDE, _cPara, _cCC, _cMemo, _lAnexo, _bCC, _cPathHtm, aInfo)	

Local aArea    := GetArea()
Local cServer  := GetMV("MV_RELSERV")  // Nome do servidor de e-mail           
Local cConta   := GetMV("MV_RELACNT")  // Nome da conta a ser usada no e-mail  
Local cPaswd   := GetMV("MV_RELPSW")   // Senha                                
//Local lOk      := .F.

Private _cDE   := Iif(Empty(alltrim(lower(_cDE))),cConta,_cDE)
Private _cPara := alltrim(lower(_cPara))
Private _cCC   := alltrim(lower(_cCC))
Private _bCC   := alltrim(lower(_bCC))
Private _cMemo := Iif(!Empty(_cMemo), _cMemo, " ")

Private cNome          := aInfo[1][1]
Private cCPF           := aInfo[1][2]
Private dDataAdmissao  := dDatabase
Private dDataDemiss    := dDatabase
Private cFuncao        := aInfo[1][3]
Private cDiretoria     := ""
Private cGerenciamento := ""
Private cCotrato       := ""
Private cProcesso      := ""

//Tabela CSS/HTML
//Monta Html
_cMemo := "<!DOCTYPE html>"+_CRLF 
_cMemo += "<html>"+_CRLF 
_cMemo += "<head>"+_CRLF 
_cMemo += "<style>"+_CRLF 
_cMemo += "table {"+_CRLF 
_cMemo +=    "border-collapse: collapse;"+_CRLF 
_cMemo +=    "width: 100%;"+_CRLF 
_cMemo += "}"+_CRLF 
_cMemo += "th, td {"+_CRLF 
_cMemo +=    "text-align: left;"+_CRLF 
_cMemo +=    "padding: 8px;"+_CRLF 
_cMemo += "}"+_CRLF 
_cMemo += "tr:nth-child(even){background-color: #f2f2f2}"+_CRLF 
_cMemo += "th {"+_CRLF 
_cMemo +=    "background-color: #b052ba;"+_CRLF 
_cMemo +=    "color: white;"+_CRLF 
_cMemo += "}"+_CRLF 
_cMemo += "</style>"+_CRLF 
_cMemo += "</head>"+_CRLF 
_cMemo += "<H4>Prezados(as)</h4>"+_CRLF 
_cMemo += "<body>"+_CRLF 
_cMemo += "<h2>Nova Reclamação Trabalhista</h2>"+_CRLF 
_cMemo += "<table>"+_CRLF 
_cMemo +=  "<tr>"+_CRLF 
_cMemo +=			"<th>Nome</th>"+_CRLF 
_cMemo +=			"<th>CPF</th>"+_CRLF 
_cMemo +=			"<th>DataAdmissao</th>"+_CRLF 
_cMemo +=			"<th>DataDemissao</th>"+_CRLF 
_cMemo +=			"<th>Funcao</th>"+_CRLF 
_cMemo +=			"<th>Diretoria</th>"+_CRLF 
_cMemo +=			"<th>Gerente</th>"+_CRLF 
_cMemo +=			"<th>Contrato</th>"+_CRLF 
_cMemo +=			"<th>NroProcesso</th>"+_CRLF 
_cMemo +=  "</tr>"+_CRLF 
_cMemo +=  "<tr>"+_CRLF 
_cMemo +=	"<td>"+cNome+"</td>"+_CRLF 
_cMemo +=    "<td>"+cCPF+"</td>"+_CRLF 
_cMemo +=    "<td>"+dtoc(dDataAdmissao)+"</td>"+_CRLF 
_cMemo +=    "<td>"+dtoc(dDataDemiss)+"</td>"+_CRLF 
_cMemo +=	"<td>"+cFuncao+"</td>"+_CRLF 
_cMemo +=	"<td>"+cDiretoria+"</td>"+_CRLF 
_cMemo +=	"<td>"+cGerenciamento+"</td>"+_CRLF 
_cMemo +=	"<td>"+cCotrato+"</td>"+_CRLF 
_cMemo +=	"<td>"+cProcesso+"</td>"+_CRLF 
_cMemo +=  "</tr>"+_CRLF 
_cMemo += "</table>"+_CRLF 
_cMemo += "</body>"+_CRLF 
_cMemo += "</html>"+_CRLF 
//--

If !Empty(cServer) .And. !Empty(cConta) .And. !Empty(cPaswd) .And. !Empty(_cPara) .And. !Empty(_cMemo)
   CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cPaswd RESULT lOk
   If lOk
      MailAuth( cConta, cPaswd ) //realiza a autenticacao no servidor de e-mail.
      If !_lAnexo
         SEND MAIL FROM _cDE TO (alltrim(_cPara)+";"+alltrim(_cCC)) BCC _bCC SUBJECT _cAssunto BODY _cMemo RESULT lSendOk FORMAT TEXT
      Else
         SEND MAIL FROM _cDE TO (alltrim(_cPara)+";"+alltrim(_cCC)) BCC _bCC SUBJECT _cAssunto BODY _cMemo ATTACHMENT (alltrim(_cPathHtm))  RESULT lSendOk FORMAT TEXT
      Endif
      If !lSendOk
         GET MAIL ERROR cError
         Aviso("Erro no envio do e-Mail",cError,{"Fechar"},2)
      EndIf
   Else
      GET MAIL ERROR cError
      Aviso("Erro no envio do e-Mail",cError,{"Fechar"},2)
   EndIf
   If lOk
      DISCONNECT SMTP SERVER
   EndIf
EndIf
//
//ShellExecute('open',(alltrim(_cCaminho)),'','',SW_SHOWMAXIMIZED)
//
RestArea( aArea )
//
Return lOk


