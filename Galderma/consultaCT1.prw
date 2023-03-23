//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 

#define _CRLF CHR(13)+CHR(10)

user function GetCT1()

Return .t.

/*==================================================================================================*/

WSRESTFUL PLANODECONTAS_CT1 DESCRIPTION "Consulta Plano de Contas"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / Plano de Contas"  WSSYNTAX "CT1"
//WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
Consulta codigo Municipios CT1
==============================*/

WSMETHOD GET WSRECEIVE cCod WSSERVICE PLANODECONTAS_CT1

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cCod		    AS CHARACTER
local cMsg          AS CHARACTER
Local nCount := 0

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea("CT1")
dbSetOrder(1)

 cMsg := '[' //Inicio Jason

    While CT1->(!eof()) 

        nCount++

            cMsg += '{'
            cMsg += '"codigo": "' + CT1->CT1_CONTA + '",'
            cMsg += '"descricao": "' + Alltrim(CT1->CT1_DESC01)  + '"'
            cMsg += "}"
            If nCount < CT1->(RecCount())
                cMsg += ','
            endif
           
        CT1->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
    else
        cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf   

dbCloseArea("CT1")
Return .T.
