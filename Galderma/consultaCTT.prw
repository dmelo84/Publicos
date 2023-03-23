//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 

#define _CRLF CHR(13)+CHR(10)

user function GetCTT()

Return .t.

/*==================================================================================================*/

WSRESTFUL CENTROCUSTO_CTT DESCRIPTION "Consulta centro de custo"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / CENTRO DE CUSTO"  WSSYNTAX "CTT"
//WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
Consulta codigo Municipios CTT
==============================*/

WSMETHOD GET WSRECEIVE cCod WSSERVICE CENTROCUSTO_CTT

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cCod		    AS CHARACTER
local cMsg          AS CHARACTER
Local nCount := 0

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea("CTT")
dbSetOrder(1)

 cMsg := '[' //Inicio Jason

    While CTT->(!eof()) 

        nCount++

            cMsg += '{'
            cMsg += '"codigo": "' + CTT->CTT_CUSTO + '",'
            cMsg += '"descricao": "' + Alltrim(CTT->CTT_DESC01)  + '"'
            cMsg += "}"
            If nCount < CTT->(RecCount())
                cMsg += ','
            endif
           
        CTT->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
    else
        cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf   

dbCloseArea("CTT")
Return .T.
