//Bibliotecas
#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE 'TBICONN.CH'

#DEFINE PULA chr(13)+chr(10)
 
//Variáveis Estáticas
Static cTitulo := "Caixa Pleres"
 
/*/{Protheus.doc} Concil001
Função para cadastro de Grupo de Produtos (X01) e Produtos (X02), exemplo de Modelo 3 em MVC
@author Diogo Melo
@since 01/08/2021
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_Concil001()
    @obs Não se pode executar função MVC dentro do fórmulas
/*/
 
User Function Concil001()
    
    Local aArea   := GetArea()
    Local oBrowse
    
    //Menu
    //private aRotina := MenuDef()

    //Chama filtro inicial


    //Instânciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("X01")
    
    //Setando Menu
    oBrowse:SetMenuDef("Concil001")

    //Setando a descrição da rotina
    oBrowse:SetDescription(cTitulo)

    //Setando Filto
    //oBrowse:SetFilterDefault("X01_DTCONC != ctod('  /  /  ')")
     
    //Legendas
    oBrowse:AddLegend( "X01_DTCONC != ctod('  /  /  ')", "GREEN",  "Conciliado" )
    oBrowse:AddLegend( "X01_DTCONC == ctod('  /  /  ')", "RED"  ,  "Não Conciliado" )
     
    //Ativa a Browse
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Diogo Melo                                                   |
 | Data:  01/08/2021                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    //ADD OPTION aRot TITLE 'Visualizar'  ACTION 'VIEWDEF.Concil001'  OPERATION 2   ACCESS 0 //OPERATION 1
    //ADD OPTION aRot TITLE 'Imp. Vendas' ACTION 'u_impInfo'         OPERATION 3   ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Imp. Caixas' ACTION 'u_Concil02'         OPERATION 6   ACCESS 0 //OPERATION X
    ADD OPTION aRot TITLE 'Conciliar'   ACTION 'VIEWDEF.Concil001'  OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    //ADD OPTION aRot TITLE 'Incluir'     ACTION 'VIEWDEF.Concil001'  OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    //ADD OPTION aRot TITLE 'Excluir'     ACTION 'VIEWDEF.Concil001'  OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Daniel Atilio                                                |
 | Data:  17/08/2015                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()

    Local oModel         := Nil
    Local oStPai         := FWFormStruct(1, 'X01')
    Local oStFilho       := FWFormStruct(1, 'X02')
    //Local oStNeto      := FWFormStruct(1, 'SE2')
    Local aX02Rel        := {}
    //Local aSE2Rel      := {}
     
    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New('Concil01',/*bPre*/, {|oModel|auxValid(oModel)},/*bCommit*/,/*bCancel*/)
    oModel:AddFields('X01MASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('X02DETAIL','X01MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
    //oModel:AddGrid('SE2DETAIL','X01MASTER',oStNeto,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence 
    //Criação do addCalc
    oModel:AddCalc("MD_DETAILAUX", "X01MASTER", "X02DETAIL", "X02_VLRPGT", "X02_VLRPGT", "SUM", {|| .T.}, {|| 0}, "Total Dinheiro")
    //oModel:AddCalc("MD_DETAILAUY", "X01MASTER", "X02DETAIL", "X02CARTAO", "X02CARTAO", "FORMULA", /*{|| .T.}*/, /*{|| 0}*/, "Total Cartão",{|oModel,nVlrAtu,xValor,lSoma| calCart(oModel,nVlrAtu,xValor,lSoma,'X02CARTAO')}/*bFormula*/, 9 /*nTamanho*/, 2/*nDecimal*/)
    //Fazendo o relacionamento entre o Pai e Filho
    aAdd(aX02Rel, {'X02_FILIAL',    'X01_FILIAL'}) 
    aAdd(aX02Rel, {'X02_IDPROD',    'X01_ID'}) 

    //Fazendo relacionamento entre Filho e Neto
    //aAdd(aSE2Rel, {xFilial("SE2"),xFilial("SE2")})                  
    oModel:SetRelation('X02DETAIL', aX02Rel, X02->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
    oModel:GetModel('X02DETAIL'):SetUniqueLine({"X02_PLERES"})    //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({})

    // Necessário que haja alguma alteração na estrutura 
    //if oModel:GetOperation() != 2
    oModel:SetActivate( { | oModel | FwFldPut( "X01_DTATEN", altData(oModel),,oModel ) } )
    //endif     
    //Setando as descrições
    oModel:SetDescription("Vendas Pleres")
    oModel:GetModel('X01MASTER'):SetDescription('Modelo Unidade')
    oModel:GetModel('X02DETAIL'):SetDescription('Modelo Vendas')
    //oModel:GetModel('SE2DETAIL'):SetDescription('Titulos')

Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Diogo Melo                                                   |
 | Data:  01/08/2021                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()
    Local oView        := Nil
    Local oModel       := FWLoadModel('Concil001')
    Local oStPai       := FWFormStruct(2, 'X01')
    Local oStFilho     := FWFormStruct(2, 'X02')
    //Local oStNeto      := FWFormStruct(2, 'SE2')
    //AddCalc
    Local oStruAUX := FwCalcStruct(oModel:GetModel("MD_DETAILAUX"))
    //Local oStruAUY := FwCalcStruct(oModel:GetModel("MD_DETAILAUY"))
     
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_X01',oStPai, 'X01MASTER')
    oView:AddGrid('VIEW_X02',oStFilho,'X02DETAIL')
    //oView:AddGrid('VIEW_SE2',oStNeto, 'SE2DETAIL')
    
    //AddCalc
    oView:AddField("VW_DETAILAUX", oStruAUX, "MD_DETAILAUX")
    //oView:AddField("VW_DETAILAUY", oStruAUY, "MD_DETAILAUY")
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRIDS',60)
    oView:CreateHorizontalBox('CALC',10) //Campo Calc1 
    
    //Setando o dimensionamento de tamanho
    ///oView:CreateVerticalBox('GRID1',50,"GRIDS")
    ///oView:CreateVerticalBox('GRID2',50,"GRIDS")
    //Rodapé
    ///oView:CreateVerticalBox('CALC1',50,"CALC")
    ///oView:CreateVerticalBox('CALC2',50,"CALC")
    
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_X01','CABEC')
    oView:SetOwnerView("VIEW_X02", "GRIDS") 
    oView:SetOwnerView("VW_DETAILAUX", "CALC") //Campo Calc1//Campo Calc1
    //oView:SetOwnerView("VIEW_SE2", "GRID2") //Campo Calc2
    //oView:SetOwnerView("VW_DETAILAUX", "CALC1") //Campo Calc1
    //oView:SetOwnerView("VW_DETAILAUY", "CALC2") //Campo Calc2
     
    //Habilitando título
    oView:EnableTitleView('VIEW_X01','Unidade')
    oView:EnableTitleView('VIEW_X02','Pleres')
    //oView:EnableTitleView('VIEW_SE2','Titulos')
Return oView

 /*/{Protheus.doc} wsVendas
    (long_description)
    @type  Function
    @author Diogo Melo
    @since 23/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

user Function wsVendas(cUrl, cDominio, cIdProd, cPath, dData)

local oRestClient as object
local aHeadOut as array
Local cJson as char
Local lRet as logical
//Local oJson as object
 
//local oFile as object
default cDominio := "axial_homolog"
default cIdProd  :=  "13"
default cData    := dRetData()
default cUrl     := "http://pleres-api-hml.alliar.com"
default cPath    := "/operadoras/api/Protheus/"+Alltrim(cDominio)+"/ListarProducaoParticular/"+cIdProd+"/"+cData //2021-03-05/2021-03-05

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
        parseJsonObj(cJson) //Pega a string Json e monta um array
        lRet := .T.
    else
        cJson := oRestClient:GetLastError()
        conout(cJson)
        lRet := .F.
    endif
 
    FreeObj(oRestClient)
    //FreeObj(oJson)
//endif
 
//FreeObj(oFile)

//Desativa o Model para alterar a opção do menu
//oModel:DeActivate()
//

return lRet
 
//-------------------------------------------------------------------
/*/{Protheus.doc} parseJsonObj
Converte Json em Array para Listar listProdPart e montar a tela

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
  Local cAlias := 'X02'
  Local n
  Local lVez     := .F.
  Local aStatus
  Local nPosSta  := 0
  Local nPosRec  := 0
  Local cTpPagto := ""
 
  oJson := JsonObject():New()
  cTextJson := cJson
 
  ret := oJson:FromJson(cTextJson)
 
  if ValType(ret) == "C"
    conout("Falha ao transformar texto em objeto json. Erro: " + ret)
    return
  endif
 
 aResult := listProdPart(oJson) //Lista as listProdPart em array

 DbSelectArea(cAlias)
 (cAlias)->(dbSetOrder(1)) //X02_FILIAL+X02_PLERES

    for n:=1 to len(aResult)

        aStatus := selSe1(aResult[n][9],aResult[n][4])
        nPosSta := aScan( aStatus, { |x| AllTrim( x[1] ) $ "01|02|03|04|" } )
        nPosRec := aScan( aStatus, { |x| AllTrim( x[1] ) == "05" } )
        cTpPagto:= Alltrim(aResult[n][5])
        
        if cTpPagto == "DINHEIRO"

            if !(cAlias)->(dbSeek(xFilial("X02")+cValtoChar(aResult[n][9])))
                RecLock(cAlias, .T.)

                    replace X02_FILIAL with cFilAnt
                    replace X02_CNPJ   with Alltrim(aResult[n][1])
                    replace X02_VLRBRU with aResult[n][2]
                    replace X02_IDCX   with aResult[n][3]
                    replace X02_TPPAGT with aResult[n][5]
                    replace X02_DTATEN with aResult[n][6]
                    replace X02_STATUS with aResult[n][7]
                    replace X02_IDPROD with aResult[n][8]
                    replace X02_PLERES with aResult[n][9]
                    replace X02_VLRPGT with aResult[n][4]
                    replace X02_NOME   with aResult[n][11]
                    replace X02_NFE    with aResult[n][13]
                    replace X02_RPS    with aResult[n][12]
                    replace X02_CHAVE  with aResult[n][14]
                    replace X02_ATENDI with aResult[n][10]
                    replace X02_NOMEUN with aResult[n][15]
                    replace X02_INTEGR with iIf(nPosSta > 0,subs(aStatus[nPosSta][2],1,1),"3"/*Não conciliado*/)
                    replace X02_RECNO  with iIf(nPosRec > 0,aStatus[nPosRec][2],0)
                    
                MsUnlock()
            /*    
            else
                RecLock(cAlias, .F.)

                    replace X02_FILIAL with xFilial(cAlias)
                    replace X02_CNPJ   with Alltrim(aResult[n][1])
                    replace X02_VLRBRU with aResult[n][2]
                    replace X02_IDCX   with aResult[n][3]
                    replace X02_TPPAGT with aResult[n][5]
                    replace X02_DTATEN with aResult[n][6]
                    replace X02_STATUS with aResult[n][7]
                    replace X02_IDPROD with aResult[n][8]
                    replace X02_PLERES with aResult[n][9]
                    replace X02_VLRPGT with aResult[n][4]
                    replace X02_NOME   with aResult[n][11]
                    replace X02_NFE    with aResult[n][13]
                    replace X02_RPS    with aResult[n][12]
                    replace X02_CHAVE  with aResult[n][14]
                    replace X02_ATENDI with aResult[n][10]
                    replace X02_NOMEUN with aResult[n][15]
                    replace X02_INTEGR with iIf(nPosSta > 0,subs(aStatus[nPosSta][2],1,1),"3")
                    replace X02_RECNO  with iIf(nPosRec > 0,aStatus[nPosRec][2],0)
                                    
                MsUnlock() */
            endif

        endif
        dDataGrv := stod(subs(aResult[n][6],1,4)+subs(aResult[n][6],9,2)+subs(aResult[n][6],6,2))
        idProduc := aResult[n][8]
        if !lVez

            dbselectArea("X01")
            dbSetOrder(2) //X01_FILIAL+X01_ID+X01_DTIMP  

            if !X01->(dbseek(xfilial("X01")+idProduc+dtos(dDataGrv)))

                RecLock("X01", .T.)

                    replace X01_FILIAL  with  cFilAnt
                    replace X01_CNPJ    with  SM0->M0_CGC
                    replace X01_Nome    with  aResult[n][15]
                    replace X01_ID      with  aResult[n][8]
                    replace X01_DTATEN  with  aResult[n][6]
                    replace X01_DTIMP   with  stod(subs(aResult[n][6],1,4)+subs(aResult[n][6],9,2)+subs(aResult[n][6],6,2))

                MsUnlock()

            endif
        lVez := .T.
        X01->(dbCloseArea())
        endif

    next

 FreeObj(oJson)

return 

/*/{Protheus.doc} listProdPart
Lista as listProdPart para montar a tela

|Melhorei o Código - DMS|

@param cValue String contendo o conteúdo que será exibido
 
@sample showResult("Teste")
@author Diogo Melo
@since 22/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------

static function listProdPart(jsonObj)

  local u
  local chave
  local lenJson
  Local aResult := {}
 
  lenJson := len(jsonObj)
 
        if lenJson > 0

            chave := jsonObj[1]:getNames()

            if len(chave) > 0
                    
                for u := 1 to len(jsonObj)

                    ccnpj      := jsonObj[u][chave[1]]
                    nValBruto  := jsonObj[u][chave[3]]
                    nIdCaixa   := jsonObj[u][chave[2]]
                    nValPAgto  := jsonObj[u][chave[4]]
                    ctipoPagto := jsonObj[u][chave[5]]
                    cData      := jsonObj[u][chave[6]]
                    cStatusCx  := jsonObj[u][chave[7]]
                    cIdIunida  := cValtoChar(jsonObj[u][chave[8]])
                    nidPleres  := jsonObj[u][chave[9]]
                    cAtendPle  := jsonObj[u][chave[10]]
                    cNomeCli   := jsonObj[u][chave[11]]
                    cRPS       := jsonObj[u][chave[12]]
                    cNotaFis   := jsonObj[u][chave[13]]
                    cChaveFis  := jsonObj[u][chave[14]]
                    cNomUnPro  := jsonObj[u][chave[15]]

                aAdd(aResult,{ccnpj,nValBruto,nIdCaixa,nValPAgto,ctipoPagto,cData,cStatusCx,cIdIunida,nidPleres,;
                              cAtendPle,cNomeCli,cRPS,cNotaFis,cChaveFis,cNomUnPro})

                next
                    
            endif
            
        endif

       
return aResult

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author Diogo Melo
    @since 24/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function dRetData() //2021-03-05/2021-03-05 Exemplo do retorno da string

Local cData := ""
Local aPergs   := {}
Local dDataDe  := FirstDate(Date())
Local dDataAt  := LastDate(Date())
 
aAdd(aPergs, {1, "Data De",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
aAdd(aPergs, {1, "Data Até", dDataAt,  "", ".T.", "", ".T.", 80,  .T.})
 
If ParamBox(aPergs, "Informe os parâmetros")
    
    cDataDeA  := dtos(mv_par01)
    cDataAteA := dtos(mv_par02)
    cDataDe  := subs(cDatadeA,1,4)+"-"+subs(cDatadeA,7,2)+"-"+subs(cDatadeA,5,2)
    cDataAte := subs(cDataAteA,1,4)+"-"+subs(cDataAteA,7,2)+"-"+subs(cDataAteA,5,2)
    cData := cDataDe+'/'+cDataAte

EndIf
    
Return cData

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

User Function impInfo(cDominio, cUnidade) //Inativo

Local lret := .F.

Default cUnidade  := FWInputBox("Informe o Numero da Unidade", "13")
Default cDominio  := FWInputBox("Informe o Dominio", "axial_homolog")

lret := u_wsVendas(/*cUrl*/, alltrim(cDominio), Alltrim(cUnidade),/*cPath*/, /*dData*/)

if lRet
    MsgInfo("Dados Importados com Sucesso!", "Aviso.")
    CloseBrowse()
else
    Alert("WebService não retornou dados: wsVendas")
endif
    
Return 

/*/{Protheus.doc} selSe1
    (long_description)
    @type  Static Function
    @author Diogo Melo
    @since 03/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function selSe1(cPleres,nValor)

    Local cQry    := ""
    Local nStatus := 0
    Local cAlias  := getNextAlias()
    Local nCount  := 0
    Local cMsg    := ""
    Local aMsg    := {}
   
    DEFAULT cPleres = ""
    DEFAULT nValor  = 0

    cQry := "Select E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_XIDPLER, E1_NFELETR, E1_PEDIDO,* " +PULA
    cQry += "From "+retSqlName("SE1")+ " Se1 " +PULA
    cQry += "Where D_E_L_E_T_ != '*' " +PULA
    cQry += "And E1_XIDPLER = '"+cValtochar(cPleres)+"'" +PULA
    cQry += "And E1_FILIAL = '"+cFilAnt+"'"

    nStatus := TCSqlExec(cQry)

    if (nStatus < 0)
        conout("TCSQLError() " + TCSQLError())
        Msginfo("TCSQLError() " + TCSQLError())
        Return
    endif

    If select(cAlias) > 0
        cAlias->(dbCloseArea())
    EndIf

    TCQuery (cQry) ALIAS cAlias NEW
    //FWMsgRun(, {|oSay|},"Processando", "Lendo SB9")

    while cAlias->(!EOF())
    nCount++
       
        if Empty(cAlias->E1_NFELETR)
             cMsg := "1=Titulo sem NF."
             aAdd(aMsg,{"01",cMsg})
            if Empty(cAlias->E1_PEDIDO)
                cMsg := "2=Pedido não encontrado"
                aAdd(aMsg,{"02",cMsg})
            endif
        else
            if !Empty(cAlias->E1_PEDIDO)
                //cMsg := "Conciliado Pedido e Nota"
                //aAdd(aMsg,{"03",cMsg})
                if cAlias->E1_VALOR == nValor
                    cMsg := "4=Conciliado com Sucesso."
                else
                    cMsg := "3=Não Conciliado por valor"
                endif
                aAdd(aMsg,{"04",cMsg})
            endif
        endif

    nRec := cAlias->R_E_C_N_O_
    aAdd(aMsg,{"05",nRec})

    cAlias->(dbSkip())
    endDo
    
    if nCount == 0
        cMsg := "5=Titulo não encontrado."
        aAdd(aMsg,{"03",cMsg})
    endIf

cAlias->(dbCloseArea())

Return aMsg

/*/{Protheus.doc} validPos
    (long_description)
    @type  Static Function
    @author user
    @since 05/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

static function auxValid(oModel)

Private lRet := .F. 
   
    FWMsgRun(, {|oSay| validPos(oModel)},"Processando", "Lendo Titulos a receber")

return lRet

Static Function validPos(oModel)
//Local lRet   := .F.
Local aPergs := {}
Local cBco   := Space(TamSX3('A6_COD')[01])
Local cAge   := Space(TamSX3('A6_AGENCIA')[01])
Local cCta   := Space(TamSX3('A6_NUMCON')[01])
Local dReceb := dDataBase
Local nVlrRec := 0
Local oModelGrid := oModel:GetModel( "X02DETAIL" )
Local nLin := 0
Local nTipo := Space(2)
Local nRecno := 0
Local nOperation := oModel:GetOperation()
Local lVez := .F.
/*
Local dDataDe  := FirstDate(Date())
Local dDataAt  := LastDate(Date())
*/ 
if nOperation == 5 //Delete
    lRet := .t.
    return lRet
endIf

if oModel:GetValue('X01MASTER','X01_DTCONC') != cTod('  /  /  ')
        FWAlertError("Movimento já conciliado.", "Alerta!")
    return .F.
endif

aAdd(aPergs, {1, "Banco"  ,cBco,  "", ".T.", "SA6", ".T.", 25,  .F.})
aAdd(aPergs, {1, "Agencia",cAge,  "", ".T.", "", ".T.", 50,  .T.})
aAdd(aPergs, {1, "Agencia",cCta,  "", ".T.", "", ".T.", 50,  .T.})
aAdd(aPergs, {2, "Tipo Baixa", nTipo, {"","NOR=Normal"}, 100, ".T.", .F.})
aAdd(aPergs, {1, "Data Recebimento",dReceb,  "", ".T.", "", ".T.", 50,  .T.})

If ParamBox(aPergs, "Informe os parâmetros")
    
    cBco   := mv_par01
    cAge   := mv_par02
    cCta   := mv_par03
    cTpBx  := mv_par04
    dReceb := mv_par05

else
    FWAlertError("Erro no preenchimento dos parâmetros.", "Parâmetro")
    return .F.
EndIf

/* Calcula Grid */
nTotLin := oModelGrid:Length( .F. )

    For nLin := 1 To nTotLin  

        oModelGrid:Goline( nLin )

        If !oModelGrid:IsDeleted( /*nLin*/ )

            if alltrim(oModelGrid:getValue("X02_TPPAGT")) $ "DINHEIRO"
                nVlrRec := oModelGrid:getValue("X02_VLRPGT")
                nRecno  := oModelGrid:getValue("X02_RECNO")
                //
                lRet := BxTit(nRecno,cTpBx,cBco,cAge,cCta,nVlrRec,/*nVlrAjuste*/,dReceb)    
                //
                if lRet
                    oModelGrid:LoadValue("X02_DATAFE", ddataBase)
                    oModelGrid:LoadValue("X02_DTBX", dReceb)
                    if !lVez
                        DbSelectArea("X01")
                        dbSetOrder(2)
                        if X01->(dbSeek(xFilial("X01")+oModel:GetValue('X01MASTER','X01_ID')+dtos(oModel:GetValue('X01MASTER','X01_DTIMP'))))
                            RecLock("X01", .F.)
                                replace X01_DTCONC with dDataBase
                            MsUnlock()
                        endif
                        X01->(dbCloseArea())
                    lVez := .T.
                    endif
                endIf    
            endIf

        endif

    next
/*
oModel:DeActivate()
*/
Return lRet

/*/{Protheus.doc} altData
    (long_description)
    @type  Static Function
    @author Diogo Melo
    @since 05/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function altData(oModel)
Local cDataAtu := ''
Local cData := oModel:GetValue( 'X01MASTER', 'X01_DTATEN' )

cDataAtu := soma1(subs(cData,len(cData)-1,1))
cData := Subs(cData,1,len(cData)-1)+cDataAtu

Return cData

/*/{Protheus.doc} BxTit
Baixa titulo de acordo com os parametros passados
@author Augusto Ribeiro | www.compila.com.br
@since 29/11/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function BxTit(_nRecnoE1,_cMotBx,_cPortado,_cAgeDep,_cConta,_nVlRec,nVlrAjuste,_dDtRec)
	Local aRet			:= {.f.,""}
	Local aBaixa		:=	{}
	Local _aAreaAtu 	:= GetArea()
	Local _cCodFil  	:= cFilAnt
	Local _dDataBase	:= dDataBase
	Local cMemo, cAutoLog

	Default nVlrAjuste	:= 0

/*--------------------------
	Soma multa no valor recebido
---------------------------*/
	IF  nVlrAjuste > 0
	_nVlRec	:= _nVlRec+nVlrAjuste
	ENDIF

DbSelectArea("SE1")   
SE1->(DbGoTo(_nRecnoE1))
															
aAdd( aBaixa, { "E1_FILIAL" 	, SE1->E1_FILIAL						, Nil } )	// 01
aAdd( aBaixa, { "E1_PREFIXO" 	, SE1->E1_PREFIXO						, Nil } )	// 01
aAdd( aBaixa, { "E1_NUM"     	, SE1->E1_NUM		 					, Nil } )	// 02
aAdd( aBaixa, { "E1_PARCELA" 	, SE1->E1_PARCELA						, Nil } )	// 03
aAdd( aBaixa, { "E1_TIPO"    	, SE1->E1_TIPO							, Nil } )	// 04
aAdd( aBaixa, { "E1_CLIENTE"	, SE1->E1_CLIENTE						, Nil } )	// 05
aAdd( aBaixa, { "E1_LOJA"    	, SE1->E1_LOJA							, Nil } )	// 06
aAdd( aBaixa, { "AUTMOTBX"  	, _cMotBx								, Nil } )	// 07
aAdd( aBaixa, { "AUTBANCO"  	, _cPortado								, Nil } )	// 08
aAdd( aBaixa, { "AUTAGENCIA"	, PADR(_cAgeDep,TAMSX3("A6_AGENCIA")[1])								, Nil } )	// 09
aAdd( aBaixa, { "AUTCONTA"  	, PADR(_cConta,TAMSX3("A6_NUMCON")[1])								, Nil } )	// 10
aAdd( aBaixa, { "AUTDTBAIXA"	, _dDtRec			                	, Nil } )	// 11
aAdd( aBaixa, { "AUTDTCREDITO"	, _dDtRec              				    , Nil } )	// 11
aAdd( aBaixa, { "AUTHIST"   	, "BX INTGRACAO PLERES"                	, Nil } )	// 12
aAdd( aBaixa, { "AUTVALREC" 	, _nVlRec								, Nil } )	// 13

	IF nVlrAjuste < 0
	aAdd( aBaixa, { "AUTDESCONT" 	, nVlrAjuste*-1								, Nil } )	// 13
	ELSEIF nVlrAjuste > 0
	aAdd( aBaixa, { "AUTMULTA"		, nVlrAjuste								, Nil } )	// 14
	ENDIF
		  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na Filial para efetuar a baixa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cCodFil	:= cFilAnt
dDataBase   := _dDtRec
cFilAnt		:= SE1->E1_FILIAL

lMSErroAuto := .F.
lMSHelpAuto := .T.
MSExecAuto({|x, y| Fina070(x, y)}, aBaixa,3)  
cFilAnt := _cCodFil
dDataBase := _dDataBase
	If 	lMsErroAuto
    
	//MostraErro()
	cAutoLog	:= alltrim(NOMEAUTOLOG())

	cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
	CONOUT("Concil001 BxTit | "+DTOC(date())+" "+TIME(), cMemo)
	cMemo := STRTRAN(cMemo,"'","")

	//| Apaga arquivo de Log
	Ferase(cAutoLog)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le Log da Execauto e retorna mensagem amigavel ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aRet[2] := U_CPXERRO(cMemo)

		IF EMPTY(aRet[2])
		    aRet[2]	:= alltrim(cMemo)
            MsgInfo(cMemo, "Erro na Baixa")
		ENDIF

	ELSE
	
	aRet[1]	:= .t.
	Endif

RestArea(_aAreaAtu)

Return(aRet[1])

