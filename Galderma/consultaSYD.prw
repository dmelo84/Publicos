//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 

#define _CRLF CHR(13)+CHR(10)

user function GetSYD()

Return .t.

/*==================================================================================================*/

WSRESTFUL NCM_SYD DESCRIPTION "Consulta de codigo IBGE Municipios"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / NCM"  WSSYNTAX "SYD"
//WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO PRODUTOS" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
Consulta codigo Municipios CC2
==============================*/

WSMETHOD GET WSRECEIVE cCod WSSERVICE NCM_SYD

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cCod		    AS CHARACTER
local cMsg          AS CHARACTER
Local nCount := 0

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea("SYD")
dbSetOrder(1)

 cMsg := '[' //Inicio Jason

    While SYD->(!eof()) 

        nCount++
            
        //Retirando caracteres
        cConteudo := Alltrim(SYD->YD_DESC_P)
        cConteudo := StrTran(cConteudo, "'", "")
        cConteudo := StrTran(cConteudo, "#", "")
        cConteudo := StrTran(cConteudo, "%", "")
        cConteudo := StrTran(cConteudo, "*", "")
        cConteudo := StrTran(cConteudo, "&", "E")
        cConteudo := StrTran(cConteudo, ">", "")
        cConteudo := StrTran(cConteudo, "<", "")
        cConteudo := StrTran(cConteudo, "!", "")
        cConteudo := StrTran(cConteudo, "@", "")
        cConteudo := StrTran(cConteudo, "$", "")
        cConteudo := StrTran(cConteudo, "(", "")
        cConteudo := StrTran(cConteudo, ")", "")
        cConteudo := StrTran(cConteudo, "_", "")
        cConteudo := StrTran(cConteudo, "=", "")
        cConteudo := StrTran(cConteudo, "+", "")
        cConteudo := StrTran(cConteudo, "{", "")
        cConteudo := StrTran(cConteudo, "}", "")
        cConteudo := StrTran(cConteudo, "[", "")
        cConteudo := StrTran(cConteudo, "]", "")
        cConteudo := StrTran(cConteudo, "/", "")
        cConteudo := StrTran(cConteudo, "?", "")
        cConteudo := StrTran(cConteudo, ".", "")
        cConteudo := StrTran(cConteudo, "\", "")
        cConteudo := StrTran(cConteudo, "|", "")
        cConteudo := StrTran(cConteudo, ":", "")
        cConteudo := StrTran(cConteudo, ";", "")
        cConteudo := StrTran(cConteudo, '"', '')
        cConteudo := StrTran(cConteudo, '°', '')
        cConteudo := StrTran(cConteudo, 'ª', '')

            cMsg += '{'
            cMsg += '"codigo": "' + SYD->YD_TEC + '",'
            cMsg += '"descricao": "' + Alltrim(cConteudo)  + '",'
            cMsg += "}"
            If nCount < SYD->(RecCount())
                cMsg += ','
            endif
           
        SYD->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
        return .f.
    else
        cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf   

dbCloseArea("SYD")
Return .T.
