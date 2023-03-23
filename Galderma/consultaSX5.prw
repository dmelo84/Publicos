//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 

#define _CRLF CHR(13)+CHR(10)

user function GetSX5()

Return .t.

/*==================================================================================================*/

WSRESTFUL CONSULTA_SX5 DESCRIPTION "Consulta Generica - SX5"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / GENERICA"  WSSYNTAX "SX5"
//WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
    Consulta natureza
==============================*/

WSMETHOD GET WSRECEIVE aTabela WSSERVICE CONSULTA_SX5

local cMsg          AS CHARACTER
Local nCount  := 0
Local aTabela := aClone(::aQueryString)

::setContentType("application/json")
/*
cJson := ::getContent()

lJson := FWJsonDeserialize(cJson, @oParseJSON)
*/
If len(aTabela) > 0
    cTabela := aTabela[1][2]
else
    setRestFault(002,"Consulta invalida.")
    return .F.
endIf
dbSelectArea("SX5")
dbSetOrder(1)

 cMsg := '[' //Inicio Jason

    While SX5->(!eof()) 
        nCount++

        If SX5->X5_TABELA == cTabela

            cMsg += '{'
            cMsg += '"tabela": "' + SX5->X5_TABELA + '",'
            cMsg += '"chave": "' + Alltrim(SX5->X5_CHAVE)  + '",'
            cMsg += '"descricao": "' + alltrim(SX5->X5_DESCRI)  + '"'
            cMsg += '}'
            If nCount > 1 .and. nCount < SX5->(reccount())
                cMsg += ','
            EndIf

        Endif   
        SX5->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
        return .F.
    else
        cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf 

dbCloseArea("SX5")
Return .T.
