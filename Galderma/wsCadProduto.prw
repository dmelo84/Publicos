#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "colors.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "JPEG.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "SHELL.CH"  
//WS Rest
#include "protheus.ch"
#include "restful.ch"

#define _CRLF CHR(13)+CHR(10)

user function RestSB1()

alert("Para MultiThread")

Return .t.

/*==================================================================================================*/

WSRESTFUL PRODUTOS_SB1 DESCRIPTION "Executa rotina automática MATA010 | PRODUTOS"

WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING

WSMETHOD GET   DESCRIPTION "GET / CONSULTA PRODUTOS"  WSSYNTAX ""
WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
/*
WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""
*/
END WSRESTFUL

/*================================================
GET - PRODUTOS
==================================================*/

WSMETHOD GET WSRECEIVE cCod WSSERVICE PRODUTOS_SB1

//local cJson         AS CHARACTER
//local oParseJSON    AS OBJECT
//local cCod		AS CHARACTER

::setContentType("application/json")

Private cCod := Iif(valtype(::cCod) == "U","",cCod)
Private cJson       := ::getContent()
Private oParseJSON	:= nil
Private nCount      := 0
Private cMsg        := ''
/*
::setContentType("application/json")
*/
FWJsonDeserialize(cJson, @oParseJSON)


dbSelectArea("SA2")

SB1->(dbSetOrder(1))
SB1->(dbGoTop())

If !empty(cCod)

    If SB1->(dbSeek(xFilial("SB1") + ::cCod))
            ::setResponse('{') 
            ::setResponse( '"Codigo ": "' + SB1->B1_COD + '",')
            ::setResponse( '"Nome ": "' + SB1->B1_DESC  + '"')
            ::setResponse('}')
    EndIf    

Else   

    cMsg := '[' //Inicio Jason

    While SB1->(!eof()) 

        if SB1->B1_MSBLQL != '1' 
        nCount++

            cMsg += '{'
            cMsg += '"Codigo": "' + SB1->B1_COD + '",'
            cMsg += '"Descricao": "' + SB1->B1_DESC  + '",'
            cMsg += '"Tipo": "' + SB1->B1_TIPO  + '",'
            cMsg += '"UM": "' + SB1->B1_UM  + '",'
            cMsg += '"Armazem": "' + SB1->B1_LOCPAD  + '",'
            cMsg += '},'
           
        endIf
        SB1->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason
    cMsg := strtran(cMsg,",]","]")
    ::setResponse(cMsg)
EndIf

If nCount == 0
    setRestFault(002,"Produto não encontrado!")
EndIf    

Return .T.

/*================================================
POST - PRODUTOS
==================================================*/

WSMETHOD POST WSRECEIVE cCod, cDesc, cTipo, cUM, cLocPad  WSSERVICE PRODUTOS_SB1

::setContentType("application/json")

Private cJson       := ::getContent()
Private oParseJSON	:= nil

FWJsonDeserialize(cJson, @oParseJSON)

//Pegando o modelo de dados, setando a operação de inclusão
oModel := FWLoadModel("MATA010")
oModel:SetOperation(3)
oModel:Activate()
   
//Pegando o model e setando os campos
oSB1Mod := oModel:GetModel("SB1MASTER")

If SB1->(MsSeek(xFilial("SB1")+oParseJSON:CODIGO+oParseJSON:Armazem))   
    cCodigo := strzero(SB1->(reccount())+1,6)
else
    cCodigo := oParseJSON:CODIGO
endIf

oSB1Mod:SetValue("B1_COD"     , oParseJSON:CODIGO) 
oSB1Mod:SetValue("B1_DESC"    , oParseJSON:DESCRICAO) 
oSB1Mod:SetValue("B1_TIPO"    , oParseJSON:TIPO) 
oSB1Mod:SetValue("B1_UM"      , oParseJSON:uniMedida) 
oSB1Mod:SetValue("B1_LOCPAD"  , oParseJSON:ARMAZEM) 
oSB1Mod:SetValue("B1_XORIGEM" , oParseJSON:ORGGALDERMA) 
oSB1Mod:SetValue("B1_XTIPO"   , oParseJSON:TIPOGALDERMA) 
oSB1Mod:SetValue("B1_GRUPO"   , oParseJSON:GRUPOPRODUTO) 
oSB1Mod:SetValue("B1_XSUBGPR" , oParseJSON:SUBGRUPO) 
oSB1Mod:SetValue("B1_XTIPGAL" , oParseJSON:TIPOPRODUTO) 
oSB1Mod:SetValue("B1_PRV1"    , oParseJSON:PRECOVENDA) 
oSB1Mod:SetValue("B1_CONTA"   , oParseJSON:CONTACONTABIL) 
oSB1Mod:SetValue("B1_CC"      , oParseJSON:CENTROCUSTO) 
oSB1Mod:SetValue("B1_XTPVEN"  , oParseJSON:TIPOVENDA) 
oSB1Mod:SetValue("B1_POSIPI"  , oParseJSON:NCM) 
oSB1Mod:SetValue("B1_ORIGEM"  , oParseJSON:ARMAZEM) 
oSB1Mod:SetValue("B1_USAFEFO" , oParseJSON:FEFO)
 
//Setando o complemento do produto
oSB5Mod := oModel:GetModel("SB5DETAIL")
If oSB5Mod != Nil
    oSB5Mod:SetValue("B5_CEME"   , oParseJSON:DESCRICAO     )
EndIf
   
//Se conseguir validar as informações
If oModel:VldData()
       
    //Tenta realizar o Commit
    If oModel:CommitData()
        lOk := .T.
           
    //Se não deu certo, altera a variável para false
    Else
        lOk := .F.
    EndIf
       
//Se não conseguir validar as informações, altera a variável para false
Else
    lOk := .F.
EndIf
   
//Se não deu certo a inclusão, mostra a mensagem de erro
If ! lOk
    //Busca o Erro do Modelo de Dados
    aErro := oModel:GetErrorMessage()
       
    //Monta o Texto que será mostrado na tela
    cMessage := "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], ' +_CRLF 
    cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], ' +_CRLF
    cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], ' +_CRLF
    cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], ' +_CRLF
    cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], ' +_CRLF
    cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], ' +_CRLF
    cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], ' +_CRLF
    cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], ' +_CRLF
    cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
     
    //Mostra mensagem de erro
    lRet := .F.
    ConOut("Erro: " + cMessage)
Else
    lRet := .T.
    ConOut("Produto incluido!")
EndIf
   
//Desativa o modelo de dados
oModel:DeActivate()

return .t.
