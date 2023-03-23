//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 

#define _CRLF CHR(13)+CHR(10)

user function GetSA3()

Return .t.

/*==================================================================================================*/

WSRESTFUL VENDEDORES_SA3 DESCRIPTION "Vendedores - SA3"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / VENDEDORES"  WSSYNTAX "SA3"
//WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
    Consulta natureza
==============================*/

WSMETHOD GET WSRECEIVE cCod WSSERVICE VENDEDORES_SA3

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cCod		    AS CHARACTER
local cMsg          AS CHARACTER
Local nCount  := 0

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea("SA3")
dbSetOrder(1)

 cMsg := '[' //Inicio Jason

    While SA3->(!eof()) 

        nCount++

            cMsg += '{'
            cMsg += '"codigo": "' + SA3->A3_COD + '",'
            cMsg += '"nome": "' + Alltrim(SA3->A3_NREDUZ)  + '",'
            cMsg += '},'
           
        SA3->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
    else
        cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf 

dbCloseArea("SA3")
Return .T.
