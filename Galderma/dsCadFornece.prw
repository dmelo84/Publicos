#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"
#Include "RwMake.ch"

#define enter chr(13) + chr(10)

user function RestSA2()

return

WSRESTFUL FORNECEDORES_SA2 DESCRIPTION "Executa rotina automática MATA020 | Inclusao de Fornecedores"

WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING


WSMETHOD GET        DESCRIPTION "GET FORNECEDORES"      			WSSYNTAX ""
WSMETHOD POST       DESCRIPTION "POST / INCLUSÃO FORNECEDORES "       	WSSYNTAX ""
/*
WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""
*/
END WSRESTFUL

//--------------------------------------------------------------------------------------//

// MÉTODO DE CONSULTA PRODUTO - SA2 
WSMETHOD GET WSRECEIVE cCod WSSERVICE FORNECEDORES_SA2

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cCod			AS CHARACTER
local lRet			AS LOGICAL

cJson       := ::getContent()
oParseJSON	:= nil
lRet		:= .f.
nCount      := 0
cMsg        := ''
cQry        := ''
aID := aClone(self:aquerystring)

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

	
dbSelectArea("SA2")

SA2->(dbSetOrder(1))
SA2->(dbGoTop())

If len(aID) > 0
	If aID[1][1] == "ID.FORNECEDOR"
		if !empty(aID[1][2])
			If SA2->(dbSeek(xFilial("SA2")+aID[1][2]))
				::setResponse('{"erro":"Cliente ja cadastrado"}')
			else
                ::setResponse('{"erro":"prossiga."}')
            endif
		else
			::setResponse('{"erro":"Campo CPF/CGC nao informado"}')
		endif
	return .t.
	endIf
endIf

If !empty(::cCod)

    If SA2->(dbSeek(xFilial("SA2") + ::cCod))
            ::setResponse('[{') 
            ::setResponse( '"Codigo": "' + SA2->A2_COD + '",')
            ::setResponse( '"Loja": "' + SA2->A2_LOJA + '",')
            ::setResponse( '"Nome": "' + SA2->A2_NOME  + '"')
            ::setResponse('}]')
    EndIf    

Else   

    cMsg := '[' //Inicio Jason
    
    //Query COntratos//
cQry := " select top 300 CNA_CONTRA, CNA_FORNEC, CNA_LJFORN, A2_NREDUZ from "+RetSqlName("CNA") +" CNA"
cQry += " inner Join "+RetSqlName("SA2") + " SA2"
cQry += " on A2_COD = CNA_FORNEC"
cQry += " and A2_LOJA = CNA_LJFORN"
cQry += " where CNA.D_E_L_E_T_ != '*'"
cQry += " And SA2.D_E_L_E_T_ != '*'"
cQry += " and A2_MSBLQL != '1'"
cQry += " order by CNA.R_E_C_N_O_ desc"

nStatus := TCSqlExec(cQry)

	if (nStatus < 0)
		conout("TCSQLError() " + TCSQLError())
		Return
	endif

	If select('TMP') > 0
		TMP->(dbCloseArea())
	EndIf

	TCQuery (cQry) ALIAS "TMP" NEW

    While TMP->(!eof()) 

    //    if SA2->A2_MSBLQL != '1' 
        nCount++
            cMsg += '{'
            cMsg += '"Contrato": "'+TMP->CNA_CONTRA +'",'
            cMsg += '"Codigo": "' +TMP->CNA_FORNEC + '",'
            cMsg += '"Loja": "'+TMP->CNA_LJFORN+'",'
            cMsg += '"Nome": "' +TMP->A2_NREDUZ  + '"'
            cMsg += '},'
            /*
            ::setResponse('{') 
            ::setResponse( '"Codigo ": "' + SA2->A2_COD + '",')
            ::setResponse( '"Nome ": "' + SA2->A2_NOME  + '"')
            ::setResponse('}')
            */
        /*
        else
            //::setResponse('{') 
            //::setResponse( '"Erro" : "Produto nao encontrado"')
            //::setResponse('}')

            setRestFault(002,"Fornecedor bloqueado!")	
        */    
    //    endIf
        TMP->(dbSkip())
    EndDo
    cMsg += ']' //Final Jason
    cMsg := strtran(cMsg,",]","]")
    ::setResponse(cMsg)
EndIf

If nCount == 0
    setRestFault(002,"Fornecedores não encontrados!")
EndIf    

return .T.

/*=====================================
        Post Inclusão de Fornecedor
=======================================*/
WSMETHOD POST WSRECEIVE cCod WSSERVICE FORNECEDORES_SA2

local oJson
Local oParseJSON
local cJson := ::GetContent()
local nOpc := 3 //Inclusão
Local oModel := Nil

private lMsErroAuto 	:= .f.
private lAutoErrNoFile 	:= .t.
private lDeuCerto := .f.
private cTable := "SA2"

::setContentType("application/json")

oJson := FWJsonDeserialize(cJson, @oParseJSON)

cEmp    := oParseJSON:empresa //Codigo Empresa
cFil    := oParseJSON:filial 
cCodigo := oParseJSON:codigo
cLoja   := oParseJSON:loja
cCGC    := oParseJSON:cgc
cErro   := ""

If !empty(cEmp) 
	RPCSetType(3)  //Nao consome licensas
	RpcSetEnv( cEmp,cFil,,,"FIN")
	lAberto := .t.
	conout("Entrou no ambiente: "+FWCodEmp()+" e Filial:"+cFilant)
Else
	lAberto := .f.
	conout("Não entrou na empresa "+cEmp+ " Estou na empresa:"+FWCodEmp()+" e Filial:"+cFilant)
    SetRestFault(400,'Erro na autencicacao.')
	Return .F.
EndIf

DbSelectArea(cTable) 
DbSetOrder(3)

If oJson

    If SA2->(MsSeek(xFilial("SA2")+ Padr(ccodigo,tamsx3("A2_COD")[1])+Padr(cLoja,tamsx3("A2_LOJA")[1])))   
    	cCodigo := oParseJSON:CODIGO
	else
		cCodigo := strzero(SA2->(reccount())+1,6)
	endIf

    If ! SA2->(Msseek(xFilial("SA2")+Padr(cCGC,tamsx3("A2_CGC")[1])))

        //cCodigo       := strzero(SA2->(reccount()),6)
        cLoja         := oParseJSON:loja
        cNome         := oParseJSON:nomeCompleto
        cNReduz       := oParseJSON:nomeReduzido
        cEndereco     := oParseJSON:endereco
        cBairro       := OEMTOANSI(oParseJSON:bairro)
        cTipo         := oParseJSON:tipoPessoa
        cEstado       := oParseJSON:estado
        cCodMunicipio := oParseJSON:codMunicipio[1]
        cMunicipio    := oParseJSON:municipio
        cCep          := oParseJSON:cep
        cIE           := oParseJSON:IE
        cCodPais      := oParseJSON:codPais
        cPais         := oParseJSON:pais
        cEMail        := oParseJSON:email
        cDDD          := oParseJSON:ddd
        cTelefone     := oParseJSON:telefone
    //    cTipPessoa    := oParseJSON:tpessoa
        cPaisBac      := oParseJSON:paisBacen
        cBlqSA2       := oParseJSON:msblql
    //  cTpFornecedor := oParseJSON:tipoFornece
        
        oModel := FWLoadModel('MATA020M')

        oModel:SetOperation(nOpc)
        oModel:Activate()

        //Model SA2
        oSA2Mod:= oModel:getModel("SA2MASTER")
        //Pegando o model dos campos da SA2
        oSA2Mod:= oModel:getModel("SA2MASTER")
        //Cabeçalho
        oSA2Mod:setValue("A2_COD",    Padr(ccodigo,tamsx3("A2_COD")[1])           ) // Codigo 
        oSA2Mod:setValue("A2_LOJA",   Padr(cLoja,tamsx3("A2_LOJA")[1])            ) // Loja
        oSA2Mod:setValue("A2_NOME",   Padr(cNome,tamsx3("A2_NOME")[1])            ) // Nome             
        oSA2Mod:setValue("A2_NREDUZ", Padr(cNReduz,tamsx3("A2_NREDUZ")[1])        ) // Nome reduz. 
        oSA2Mod:setValue("A2_END",    Padr(cEndereco,tamsx3("A2_END")[1])         ) // Endereco
        oSA2Mod:setValue("A2_BAIRRO", Padr(cBairro,tamsx3("A2_BAIRRO")[1])        ) // Bairro
        oSA2Mod:setValue("A2_TIPO",   Padr(cTipo,tamsx3("A2_TIPO")[1])            ) // Tipo 
        oSA2Mod:setValue("A2_EST",    Padr(cEstado,tamsx3("A2_EST")[1])           ) // Estado
        oSA2Mod:setValue("A2_COD_MUN",Padr(cCodMunicipio,tamsx3("A2_COD_MUN")[1]) ) // Codigo Municipio                
        oSA2Mod:setValue("A2_MUN",    Padr(cMunicipio,tamsx3("A2_MUN")[1])        ) // Municipio
        oSA2Mod:setValue("A2_CEP",    Padr(cCep,tamsx3("A2_CEP")[1])              ) // CEP
        oSA2Mod:setValue("A2_INSCR",  Padr(cIE,tamsx3("A2_INSCR")[1])             ) // Inscricao Estadual
        oSA2Mod:setValue("A2_CGC",    Padr(cCGC,tamsx3("A2_CGC")[1])              ) // CNPJ/CPF            
        oSA2Mod:setValue("A2_PAIS",   Padr(cCodPais,tamsx3("A2_PAIS")[1])         ) // Pais  
        oSA2Mod:setValue("A2_PAISDES",Padr(cPais,tamsx3("A2_PAISDES")[1])         ) // Descrição Pais          
        oSA2Mod:setValue("A2_EMAIL",  Padr(cEMail,tamsx3("A2_EMAIL")[1])          ) // E-Mail
        oSA2Mod:setValue("A2_DDD",    Padr(cDDD,tamsx3("A2_DDD")[1])              ) // DDD            
        oSA2Mod:setValue("A2_TEL",    Padr(cTelefone,tamsx3("A2_TEL")[1])         ) // Fone                        
//    oSA2Mod:setValue("A2_TPESSOA",   cTipPessoa       ) // Tipo Pessoa
        If !Empty(cPaisBac)
            oSA2Mod:setValue("A2_CODPAIS",Padr(cPaisBac,tamsx3("A2_CODPAIS")[1])      ) // Pais Bacen
        endIf
        oSA2Mod:setValue("A2_MSBLQL", Padr(cBlqSA2,tamsx3("A2_MSBLQL")[1])        ) // Bloqueado

        //Se conseguir validar as informações
        If oModel:VldData()
            
            //Tenta realizar o Commit
            If oModel:CommitData()
                lDeuCerto := .T.
                
            //Se não deu certo, altera a variável para false
            Else
                lDeuCerto := .F.
            EndIf
            
        //Se não conseguir validar as informações, altera a variável para false
        Else
            lDeuCerto := .F.
        EndIf

        if lDeuCerto

            conOut(enter + oemToAnsi("Alterado com sucesso! ") + SA2->A2_NOME + enter)

            cOk := "Incluido"
            cMsg := "{"
           cMsg += '"Cliente": "' + SA2->A2_NREDUZ  + '",'
           cMsg += '"CPF": "' + SA2->A2_CGC  + '",'
           cMsg += '"Mensagem": "' +cOk+ '",'
           cMsg += "}"

           ::setResponse( cMsg )	

        else

        //Busca o Erro do Modelo de Dados
        aErro := oModel:GetErrorMessage()
        
        conout("Erro Commit")
        For n := 1 to len(aErro)
            cErro += AllToChar(aErro[n])+ "|" + enter
        next
        conout(cErro)
        conout("FIM")

        /*/Monta o Texto que será mostrado na tela
        AutoGrLog("Id do formulário de origem:"  + ' [' + AllToChar(aErro[01]) + ']')
        AutoGrLog("Id do campo de origem: "      + ' [' + AllToChar(aErro[02]) + ']')
        AutoGrLog("Id do formulário de erro: "   + ' [' + AllToChar(aErro[03]) + ']')
        AutoGrLog("Id do campo de erro: "        + ' [' + AllToChar(aErro[04]) + ']')
        AutoGrLog("Id do erro: "                 + ' [' + AllToChar(aErro[05]) + ']')
        AutoGrLog("Mensagem do erro: "           + ' [' + AllToChar(aErro[06]) + ']')
        AutoGrLog("Mensagem da solução: "        + ' [' + AllToChar(aErro[07]) + ']')
        AutoGrLog("Valor atribuído: "            + ' [' + AllToChar(aErro[08]) + ']')
        AutoGrLog("Valor anterior: "             + ' [' + AllToChar(aErro[09]) + ']')
        /*/

        //Mostra a mensagem de Erro
        SetRestFault(003,cErro)
        Return .F.
        Endif
    else
        SetRestFault(400,'CPF/CNPJ Cadastrado.')
	    Return .F.
    endif
else
    SetRestFault(400,'Erro no objeto.')
	Return .F.
endIf

SA2->(dbCloseArea())

oModel:DeActivate()
//oModel:Destroy()

If lAberto 
	RpcClearEnv()
EndIf

return .t.
