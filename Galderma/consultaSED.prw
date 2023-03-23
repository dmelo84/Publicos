//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 

#define _CRLF CHR(13)+CHR(10)

user function GetSED()

Return .t.

/*==================================================================================================*/

WSRESTFUL NATUREZAS_SED DESCRIPTION "Natureza financeira protheus - SED"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / NATUREZAS"  WSSYNTAX "SED"
//WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
    Consulta natureza
==============================*/

WSMETHOD GET WSRECEIVE cCod WSSERVICE NATUREZAS_SED

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cCod		    AS CHARACTER
local cMsg          AS CHARACTER
Local nCount  := 0

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea("SED")
dbSetOrder(1)

 cMsg := '[' //Inicio Jason

    While SED->(!eof()) 

        nCount++

            cMsg += '{'
            cMsg += '"codigo": "' + SED->ED_CODIGO + '",'
            cMsg += '"descricao": "' + SED->ED_DESCRIC  + '",'
            cMsg += '},'
           
        SED->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
    else
        cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf 

dbCloseArea("SED")
Return .T.
