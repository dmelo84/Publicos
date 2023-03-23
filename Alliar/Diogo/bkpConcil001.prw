User Function Concil001()
    
     //Declarar variaveis locais
    Local aSeek   	:= {}
    Local aFields 	:= {}
    Local aIndex  	:= {}
    Local aFieFilter:= {}
  
    //Declarar variaveis privadas
    Private oBrowse 	:= Nil
    Private cCadastro   := "Unidades a Conciliar"
    Private aRotina	 	:= {}
    //aRotina
    //AADD(aRotina, { 'Imp. Caixas', 'u_impInfo', 0, 3 })
    //AADD(aRotina, { 'Conciliar', 'u_Concil001', 0, 3 })
    
    //Cria e popula a tabela temporária
    oTable := tempTab()
        
    cQuery := "select * from "+ oTable:GetRealName()
    FWMsgRun(, {|oSay| MPSysOpenQuery( cQuery, 'QRYTMP' ) },"Processando", "Importando Unidades")
    
    DbSelectArea('QRYTMP')
    dbGoTop()

    oTable:Delete() // Deleta a Tabela

    //Campos que serão exibidos no browse
    Aadd(aFields,{"Unidade"     ,"Unidade" 	,"C"  ,2   ,0 ,/*PESQPICT("SX5","X5_TABELA")*/})
    Aadd(aFields,{"Nome"		,"Nome"    	,"C"  ,20  ,0 ,/*PESQPICT("SX5","X5_CHAVE")*/})
    Aadd(aFields,{"CNPJ"		,"CNPJ"	    ,"C"  ,18  ,0 ,/*PESQPICT("SX5","X5_DESCRI")*/})
    Aadd(aFields,{"Filial"	    ,"Filial"	,"C"  ,10  ,0 ,/*PESQPICT("SX5","X5_DESCENG")*/})
    Aadd(aFields,{"Dominio"	    ,"Dominio"	,"C"  ,15  ,0 ,/*PESQPICT("SX5","X5_DESCENG")*/})
    Aadd(aFields,{"URL"	        ,"URL"	    ,"C"  ,250 ,0 ,/*PESQPICT("SX5","X5_DESCSPA")*/})
    //Aadd(aFields,{"DataDe"	    ,"DataDe"	,"D"  ,8   ,0 ,/*PESQPICT("SX5","X5_DESCENG")*/})
    //Aadd(aFields,{"DataAte"	    ,"DataAte"	,"D"  ,8   ,0 ,/*PESQPICT("SX5","X5_DESCENG")*/})
 
    //Campos que irão compor a tela de filtro
    Aadd(aFieFilter,{"Unidade"	, "Unidade"  	, "C", 2  , 0,/*PESQPICT("SX5","X5_CHAVE")*/})
    Aadd(aFieFilter,{"Nome"	    , "Nome"		, "C", 20 , 0,/*PESQPICT("SX5","X5_DESCRI")*/})
    Aadd(aFieFilter,{"CNPJ"	    , "CNPJ"	    , "C", 18 , 0,/*PESQPICT("SX5","X5_DESCSPA")*/})
 
    //DbSelectArea(cTable)
    //dbGoTop()
 
    //Campo da pesquisa
    Aadd(aSeek  , {"Unidade"	, {{"","C", 2	, 0 , 1, "Unidade"}} } )
    Aadd(aSeek  , {"Nome"		, {{"","C", 20	, 0 , 2, "Nome"}} } )
    Aadd(aSeek  , {"CNPJ"	    , {{"","C", 18	, 0 , 3, "CNPJ"}} } )
 
    //Indice de pesquisa
    Aadd( aIndex, "Unidade" )
    Aadd( aIndex, "Nome" )
    Aadd( aIndex, "CNPJ" )
 
    //aStruct := TRB-&gt;(DBStruct())
    //aStructCon := aClone(aStruct)
 
    oBrowse := FWMBrowse():New()
    //Seta aRotina
    //oBrowse:SetMenuDef('Concil001')
    oBrowse:SetDescription( cCadastro )
    oBrowse:SetAlias('QRYTMP')
    oBrowse:SetQueryIndex(aIndex)
    oBrowse:SetTemporary(.T.)
    oBrowse:SetSeek(.F.,aSeek)
    oBrowse:SetFields(aFields)
    oBrowse:DisableConfig()
    oBrowse:SetFieldFilter(aFieFilter)
    oBrowse:SetFilterDefault("")
    oBrowse:SetDBFFilter(.T.)
    oBrowse:SetUseFilter(.T.)
    oBrowse:SetLocate()
    oBrowse:ForceQuitButton()
    oBrowse:Activate()

Return

/* Tabela Temporária */

static Function tempTab()

Local aFields := {}
Local oTempTable
Local n
Local cAlias := getNextAlias()
Local cDominio  := FWInputBox("Informe o Dominio", "axial_homolog")
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
aadd(aFields,{"Filial","C",10,0})
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

//FWMsgRun(, {|oSay| sleep(3)},"Processando", "Importando Unidades")

dbselectArea(cAlias)
dbSetOrder(1)

for n:=1 to len(aDados)
    Reclock(cAlias,.T.)
        (cAlias)->Unidade := cValToChar(aDados[n][1])
        (cAlias)->Nome      := aDados[n][2]
        (cAlias)->CNPJ      := aDados[n][3]
        (cAlias)->URL       := "http://pleres-api-hml.alliar.com/operadoras/api/Protheus/"+cDominio+"/ListarUnidades"
        (cAlias)->Filial    := cFilAnt
        (cAlias)->Dominio   := cDominio
    MsUnlock()
next
(cAlias)->(dbCloseArea())

//---------------------------------
//Exclui a tabela
//---------------------------------

//oTempTable:Delete()

return oTempTable
