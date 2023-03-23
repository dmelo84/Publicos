//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 

#define _CRLF CHR(13)+CHR(10)

user function GetCC2()

Return .t.

/*==================================================================================================*/

WSRESTFUL MUNICIPIOS_CC2 DESCRIPTION "Consulta de codigo IBGE Municipios"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / CODIGO IBGE"  WSSYNTAX "CC2"
//WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
Consulta codigo Municipios CC2
==============================*/

WSMETHOD GET WSRECEIVE cCod WSSERVICE MUNICIPIOS_CC2

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cCod		    AS CHARACTER
local cMsg          AS CHARACTER
Local nCount := 0

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea("CC2")
dbSetOrder(1)

 cMsg := '[' //Inicio Jason

    While CC2->(!eof()) 

        nCount++

            cMsg += '{'
            cMsg += '"UF": "' + CC2->CC2_EST + '",'
            cMsg += '"codigoMunicipio": "' + Alltrim(CC2->CC2_CODMUN)  + '",'
            cMsg += '"municipio": "' + alltrim(CC2->CC2_MUN)  + '",'
            cMsg += "}"
            If nCount < CC2->(RecCount())
                cMsg += ','
            endif
           
        CC2->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
    else
        cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf   

dbCloseArea("CC2")
Return .T.
