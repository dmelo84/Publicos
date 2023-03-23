//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 

#define _CRLF CHR(13)+CHR(10)

user function GetNNR()

Return .t.

/*==================================================================================================*/

WSRESTFUL ARMAZEM_NNR DESCRIPTION "Armazem padrão - NNR"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / ARMAZEM"  WSSYNTAX "NNR"
//WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
    Consulta natureza
==============================*/

WSMETHOD GET WSRECEIVE cCod WSSERVICE ARMAZEM_NNR

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cCod		    AS CHARACTER
local cMsg          AS CHARACTER
Local nCount  := 0

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea("NNR")
dbSetOrder(1)

 cMsg := '[' //Inicio Jason

    While NNR->(!eof()) 

        nCount++

            cMsg += '{'
            cMsg += '"codigo": "' + NNR->NNR_CODIGO + '",'
            cMsg += '"descricao": "' + Alltrim(NNR->NNR_DESCRI)  + '",'
            cMsg += '},'
           
        NNR->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
    else
        cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf 

dbCloseArea("NNR")
Return .T.
