//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 

#define _CRLF CHR(13)+CHR(10)

user function GetSBM()

Return .t.

/*==================================================================================================*/

WSRESTFUL GPRPRODUTO_SBM DESCRIPTION "Grupo de Produtos - SBM"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / GPRPRODUTO"  WSSYNTAX "SBM"
//WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
    Consulta natureza
==============================*/

WSMETHOD GET WSRECEIVE cCod WSSERVICE GPRPRODUTO_SBM

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cCod		    AS CHARACTER
local cMsg          AS CHARACTER
Local nCount  := 0

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea("SBM")
dbSetOrder(1)

 cMsg := '[' //Inicio Jason

    While SBM->(!eof()) 

        nCount++

            cMsg += '{'
            cMsg += '"codigo": "' + SBM->BM_GRUPO + '",'
            cMsg += '"descricao": "' + Alltrim(SBM->BM_DESC)  + '",'
            cMsg += '},'
           
        SBM->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
    else
        cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf 

dbCloseArea("SBM")
Return .T.
