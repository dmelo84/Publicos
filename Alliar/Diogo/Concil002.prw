#include "protheus.ch"
#INCLUDE 'totvs.ch'
#INCLUDE 'restful.ch'
#include "fwmvcdef.ch"

user function Concil02()

    //Declarar variaveis locais
    Local aSeek   	:= {}
    Local aFields 	:= {}
    Local aIndex  	:= {}
    Local aFieFilter:= {}
    //Local aArea     := GetArea()
  
    //Declarar variaveis privadas
    Private oBrowse 	:= Nil
    Private cCadastro   := "Unidade a Conciliar"
    Private aRotina	 	:= {}
    //aRotina
    AADD(aRotina, { 'Imp. Movimentos', 'u_fAuxImp', 0, 3 })
    //AADD(aRotina, { 'Conciliar', 'u_Concil001', 0, 4 })
    
    //Cria e popula a tabela temporária
    cAlias := tempTab()
        
//    cQuery := "select * from "+ oTable:GetRealName()
//    FWMsgRun(, {|oSay| MPSysOpenQuery( cQuery, 'QRYTMP' ) },"Processando", "Importando Unidades")
    
    

    //Campos que serão exibidos no browse
    Aadd(aFields,{"Unidade"     ,"Unidade" 	,"C"  ,2   ,0 ,/*PESQPICT("SX5","X5_TABELA")*/})
    Aadd(aFields,{"Nome"		,"Nome"    	,"C"  ,20  ,0 ,/*PESQPICT("SX5","X5_CHAVE")*/})
    Aadd(aFields,{"CNPJ"		,"CNPJ"	    ,"C"  ,18  ,0 ,/*PESQPICT("SX5","X5_DESCRI")*/})
    Aadd(aFields,{"Filial"	    ,"Filial"	,"C"  ,11  ,0 ,/*PESQPICT("SX5","X5_DESCENG")*/})
    Aadd(aFields,{"Dominio"	    ,"Dominio"	,"C"  ,15  ,0 ,/*PESQPICT("SX5","X5_DESCENG")*/})
    Aadd(aFields,{"URL"	        ,"URL"	    ,"C"  ,250 ,0 ,/*PESQPICT("SX5","X5_DESCSPA")*/})
    
 
    //Campos que irão compor a tela de filtro
    Aadd(aFieFilter,{"Unidade"	, "Unidade"  	, "C", 2  , 0,/*PESQPICT("SX5","X5_CHAVE")*/})
    Aadd(aFieFilter,{"Nome"	    , "Nome"		, "C", 20 , 0,/*PESQPICT("SX5","X5_DESCRI")*/})
    Aadd(aFieFilter,{"CNPJ"	    , "CNPJ"	    , "C", 18 , 0,/*PESQPICT("SX5","X5_DESCSPA")*/})
 
//    DbSelectArea('QRYTMP')
    dbselectArea(cAlias)
    dbGoTop()
 
    //Campo da pesquisa
    Aadd(aSeek  , {"Unidade"	, {{"","C", 2	, 0 , 1, "Unidade"}} } )
    Aadd(aSeek  , {"Nome"		, {{"","C", 20	, 0 , 2, "Nome"}} } )
    Aadd(aSeek  , {"CNPJ"	    , {{"","C", 18	, 0 , 3, "CNPJ"}} } )
 
    //Indice de pesquisa
    Aadd( aIndex, "Unidade" )
    Aadd( aIndex, "Nome" )
    Aadd( aIndex, "CNPJ" )
    
    // Deleta a Tabela
    //oTable:Delete() 
 
    oBrowse := FWMBrowse():New()
    //Seta aRotina
    oBrowse:SetMenuDef('Concil001')
    oBrowse:SetDescription( cCadastro )
    //oBrowse:SetAlias('QRYTMP')
    oBrowse:SetAlias(cAlias) 
    oBrowse:SetQueryIndex(aIndex)
    oBrowse:SetTemporary(.T.)
    //oBrowse:SetDataTable(.t.)
    //oBrowse:SetSeek(.F.,aSeek)
    oBrowse:SetFields(aFields)
    //oBrowse:DisableConfig()
    //oBrowse:SetFieldFilter(aFieFilter)
    oBrowse:SetFilterDefault("")
    //oBrowse:SetDBFFilter(.T.)
    //oBrowse:SetUseFilter(.T.)
    //oBrowse:SetLocate()
    //oBrowse:ForceQuitButton()
    oBrowse:Activate()

//RestArea(aArea)
(cAlias)->(dbCloseArea())
Return

/* Tabela Temporária */

static Function tempTab()

Local aFields := {}
Local oTempTable
Local n,x := 0
Local cAlias := getNextAlias()
//PUTMV("MV_CXPDOM", "axial_homolog")
Local cDominio  := Alltrim(superGetMV('MV_CXPDOM',.F.,"axial_homolog")) 
Local cCnpj := ""
Local lvez := .F.

//Local cQuery
//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New( cAlias )

//--------------------------
//Monta os campos da tabela
//--------------------------
aadd(aFields,{"Unidade","C",2,0})
aadd(aFields,{"Nome","C",20,0})
aadd(aFields,{"CNPJ","C",18,0})
aadd(aFields,{"Filial","C",11,0})
aadd(aFields,{"Dominio","C",15,0})
aadd(aFields,{"URL","C",250,0})

oTemptable:SetFields( aFields )
oTempTable:AddIndex("01", {"Unidade"} )
oTempTable:AddIndex("02", {"Nome", "CNPJ"} )
//------------------
//Criação da tabela
//------------------
oTempTable:Create()
conout(oTempTable:GetRealName())
//------------------------------------
//Executa query para leitura da tabela
//------------------------------------
aDados := u_wsListUni(cDominio)

dbselectArea(cAlias)
dbSetOrder(1)

if len(aDados) > 0

    for n:= 1 to len(aDados)
        
        if !lVez
            cCnpj := aDados[n][3]
            for x := 1 to len(cCnpj)
                if at(".",subs(cCnpj,x,1)) > 0
                    cCnpj := StrTran(cCnpj,".","" )
                elseif at("/",subs(cCnpj,x,1)) > 0
                    cCnpj := StrTran(cCnpj,"/","" )
                elseif at("-",subs(cCnpj,x,1)) > 0
                    cCnpj := StrTran(cCnpj,"-","" )
                endif
            next
        //   lVez := .T.
        endif

        if SM0->M0_CGC == cCnpj //Alterar
            Reclock(cAlias,.T.)
                (cAlias)->Unidade   := cValToChar(aDados[n][1])
                (cAlias)->Nome      := aDados[n][2]
                (cAlias)->CNPJ      := aDados[n][3]
                (cAlias)->URL       := "http://pleres-api-hml.alliar.com/operadoras/api/Protheus/"+cDominio+"/ListarUnidades"
                (cAlias)->Filial    := cFilAnt
                (cAlias)->Dominio   := cDominio
            MsUnlock()
        endif
    next

    (cAlias)->(dbGoTop())
//    (cAlias)->(dbCloseArea())

endif
//---------------------------------
//Exclui a tabela
//---------------------------------

//oTempTable:Delete()

return cAlias

/*/{Protheus.doc} User Function impInfo
    (long_description)
    @type  Function
    @author Diogo Melo
    @since 26/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
user function fAuxImp()
    
    FWMsgRun(, {|oSay| impCX(Dominio, Unidade)},"Processando", "Importando Movimentos")

return

static Function impCX(Dominio,Unidade)

Local lret := .F.

//Fechar browse inicial para ficar só o mvc aberto
//oBrowse:DeActivate()
//FreeObj(oBrowse)
//

lret := u_wsVendas(/*cUrl*/, Dominio, Unidade,/*cPath*/, /*dData*/)

if lRet
    MsgInfo("Registros atualizados com sucesso!", "Aviso!")
    CloseBrowse()
else
    Alert("WebService não retornou dados: Vendas")
endif
    
Return 

 
//-------------------------------------------------------------------
/*/{Protheus.doc} x16165
Função para post na API /api/batch/contratos em
https://seusite.com.br, utilizando da classe
@sample ListUni()
@author Diogo Melo
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
        MsgInfo("ListarUnidades", "Erro no retorno do WS!")
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
@author Diogo Melo
@since 22/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------

static function parseJsonObj(cJson)

  local oJson
  local cTextJson
  local ret
  Local aResult := {}
//  Local cAlias := 'X01'
//  Local n
 
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
@author Diogo Melo
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

