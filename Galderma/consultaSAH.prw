//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 

#define _CRLF CHR(13)+CHR(10)

user function GetSAH()

Return .t.

/*==================================================================================================*/

WSRESTFUL UNIDADEMEDIDA_SAH DESCRIPTION "Unidade de Medida - SAH"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / UNIDADEMEDIDA"  WSSYNTAX "SAH"
//WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
    Consulta natureza
==============================*/

WSMETHOD GET WSRECEIVE cCod WSSERVICE UNIDADEMEDIDA_SAH

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cCod		    AS CHARACTER
local cMsg          AS CHARACTER
Local nCount  := 0

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea("SAH")
dbSetOrder(1)

 cMsg := '[' //Inicio Jason

    While SAH->(!eof()) 

        nCount++

            cMsg += '{'
            cMsg += '"codigo": "' + SAH->AH_UNIMED + '",'
            cMsg += '"descricao": "' + Alltrim(SAH->AH_DESCPO)  + '",'
            cMsg += '},'
           
        SAH->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
    else
        cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf 

dbCloseArea("SAH")
Return .T.
