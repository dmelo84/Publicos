#include "protheus.ch"
#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'
#include "fwmvcdef.ch"

 
//-------------------------------------------------------------------
/*/{Protheus.doc} x16165
Função para post na API /api/batch/contratos em
https://seusite.com.br, utilizando da classe
@sample wsListuni()
@author Daniel Mendes
@since 22/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
user function wsListUni(cDominio)

local oRestClient as object
local cUrl as char
local cPath as char
local aHeadOut as array
Local cJson as char
Local aResult as array
//Local oJson as object
 
//local oFile as object
Default cDominio := "axial_homolog"

cUrl     := "http://pleres-api-hml.alliar.com"
cPath    := "/operadoras/api/Protheus/"+cDominio+"/ListarUnidades"
aHeadOut := {}
cJson    := ''
//oJson    := JsonObject():New()
 
//Aadd(aHeadOut, "Authorization: Basic " + Encode64("app01:fTdUlDgdQQ4MRQhLahykiKhON6k97Zfly5SV6fwpa5zCE"))
Aadd(aHeadOut, "x-api-key: kZUZOwn4NZ47MEpX3LJioGStU0K07TGk" )
Aadd(aHeadOut, "Content-Type: application/json")
//Aadd(aHeadOut, "Content-Encoding: gzip") //Serve para enviar arquivos
 
//oFile := FwFileReader():New("\contratos_20190316.gz")
 
//if oFile:Open()
    oRestClient := FWRest():New(cUrl)
 
    oRestClient:SetPath(cPath)
//    oRestClient:SetPostParams(Encode64(oFile:FullRead()))
 
//    oFile:Close()
 
    if oRestClient:Post(aHeadOut)
        cJson := oRestClient:GetResult()
        aResult := parseJsonObj(cJson) //Pega a string Json e monta um array
    else
        cJson := oRestClient:GetLastError()
        conout(cJson)
    endif
 
    FreeObj(oRestClient)
    //FreeObj(oJson)
//endif
 
//FreeObj(oFile)
 
return aResult
 
//-------------------------------------------------------------------
/*/{Protheus.doc} parseJsonObj
Converte Json em Array para Listar Unidades e montar a tela

@param cValue String contendo o conteúdo que será exibido
 
@sample showResult("Teste")
@author Daniel Mendes
@since 22/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------

static function parseJsonObj(cJson)

  local oJson
  local cTextJson
  local ret
  Local aResult := {}
  Local cAlias := 'Z02'
  Local n
 
  oJson := JsonObject():New()
  cTextJson := cJson
 
  ret := oJson:FromJson(cTextJson)
 
  if ValType(ret) == "C"
    conout("Falha ao transformar texto em objeto json. Erro: " + ret)
    return
  endif
 
 aResult := unidades(oJson) //Lista as unidades em array
 
/*
 DbSelectArea(cAlias)
 (cAlias)->(dbSetOrder(1))

    for n:=1 to len(aResult)

        if (cAlias)->(dbSeek(cValTochar(aResult[n][1])))
            RecLock(cAlias, .F.)
               replace Z02_ID   with cValtochar(aResult[n][1])
               replace Z02_NOME with aResult[n][2]
               replace Z02_CNPJ with aResult[n][3]
            MsUnlock()
        else
            RecLock(cAlias, .T.)
               replace Z02_ID   with cValtochar(aResult[n][1])
               replace Z02_NOME with aResult[n][2]
               replace Z02_CNPJ with aResult[n][3]
            MsUnlock()
        endif

    next
*/
 FreeObj(oJson)

return aResult


 //-------------------------------------------------------------------
/*/{Protheus.doc} unidades
Lista as unidades para montar a tela

|Melhorei o Código - DMS|

@param cValue String contendo o conteúdo que será exibido
 
@sample showResult("Teste")
@author Daniel Mendes
@since 22/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------

static function unidades(jsonObj)

  local u
  local chave
  local lenJson
  local item
  Local aResult := {}
 
  lenJson := len(jsonObj)
 
        if lenJson > 0

            chave := jsonObj[1]:getNames()

            if len(chave) > 0
                    
                for u := 1 to len(jsonObj)

                    idLista   := jsonObj[u][chave[3]]
                    nomeLista := jsonObj[u][chave[1]]
                    item      := jsonObj[u][chave[2]]
                aAdd(aResult,{idLista,nomeLista,item})

                next
                    
            endif
            
        endif
     
return aResult

