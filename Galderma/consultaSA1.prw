//WS Rest
#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch" 
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

#define enter CHR(13)+CHR(10)

user function GetSA1()

Return .t.

/*==================================================================================================*/

WSRESTFUL CLIENTES_SA1 DESCRIPTION "Clientes - SA1"
/*
WSDATA cRet		AS STRING
WSDATA cDesc 	AS STRING
WSDATA cTipo	AS STRING
WSDATA cCod	 	AS STRING
*/
WSMETHOD GET   DESCRIPTION "GET / Clientes"  WSSYNTAX "SA1"
WSMETHOD POST  DESCRIPTION "POST / INCLUSÃO CLIENTES" WSSYNTAX ""
//WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
//WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""

END WSRESTFUL

/*=============================
    Consulta CPF/CNPJ
==============================*/

WSMETHOD GET WSRECEIVE CPFCNPJ WSSERVICE CLIENTES_SA1

local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cMsg          AS CHARACTER
Local nCount  := 0
Local aID := aClone(self:aquerystring)

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea("SA1")
dbSetOrder(3)

If len(aID) > 0
	If aID[1][1] == "ID.CLIENTE"
		if !empty(aID[1][2])
			If SA1->(dbSeek(xFilial("SA1")+aID[1][2]))
				::setResponse('{"erro":"Cliente ja cadastrado"}')
			endIf
		else
			::setResponse('{"erro":"Campo CPF/CGC nao informado"}')
		endif
	return .t.
	endIf
endIf

 cMsg := '[' //Inicio Jason

    While SA1->(!eof()) 

        nCount++

            cMsg += '{'
            cMsg += '"codigo": "' + SA1->A1_COD + '",'
			cMsg += '"loja": "' + SA1->A1_LOJA + '",'
            cMsg += '"nome": "' + Alltrim(SA1->A1_NREDUZ)  + '",'
			cMsg += '"nomeCompleto": "' + Alltrim(SA1->A1_NOME)  + '",'
			cMsg += '"cpf": "' + SA1->A1_CGC  + '",'
			cMsg += '"tipoPessoa": "' + SA1->A1_PESSOA  + '",'
			cMsg += '"tipoCliente": "' + SA1->A1_TIPO  + '",'
            cMsg += '},'
           
        SA1->(dbSkip())
    EndDo

    cMsg += ']' //Final Jason

    If nCount == 0
        setRestFault(002,"Produto não encontrado!")
    else
		cMsg := strtran(cMsg,",]","]")
        ::setResponse(cMsg)
    EndIf 

dbCloseArea("SA1")

Return .T.

//*************************************
// Inclui clientes via Ws            **
//************************************* 

WSMETHOD POST WSSERVICE CLIENTES_SA1

local oJson
Local oParseJSON
local cJson := ::GetContent()
local i
Local cRet := ''
Local aSA1Auto  := {}
Local aAI0Auto  := {}
Local lRet      :=  RpcSetEnv("99","01","Admin")
Local nOpcAuto  :=  MODEL_OPERATION_INSERT
Local cTable    := "SA1"

private lMsErroAuto 	:= .f.
private lAutoErrNoFile 	:= .t.

::setContentType("application/json")

oJson := FWJsonDeserialize(cJson, @oParseJSON)

Private cCodigo        := " " //strzero(SA1->(reccount()) +1,TAMSX3("A1_COD")[1])
Private cLoja          := oParseJSON:loja
Private cNomeCompleto  := oParseJSON:nomeCompleto
Private cNomeReduzido  := oParseJSON:nomeReduzido
Private cCPF           := Padr(oParseJSON:cpf,TAMSX3("A1_CGC")[1]) //Ajuste tamanho seek
Private cTipoPessoa    := oParseJSON:tipoPessoa
Private cTipoCliente   := oParseJSON:tipoCliente
Private cEndereco 	   := oParseJSON:endereco
Private cBairro        := oParseJSON:bairro
Private cCodMunicipio  := oParseJSON:codigoMunicipio
Private cEstado        := oParseJSON:estado
Private cMunicipio     := oParseJSON:municipio

DbSelectArea(cTable) 
DbSetOrder(3)
	
	If lRet

		If SA1->(MsSeek(xFilial("SA1")+oParseJSON:CODIGO+oParseJSON:loja))   
    		cCodigo := strzero(SA1->(reccount())+1,6)
		else
			cCodigo := oParseJSON:CODIGO
		endIf

		If ! SA1->(Msseek(xFilial("SA1")+cCPF))
		//----------------------------------
		// Dados do Cliente
		//----------------------------------

		aAdd(aSA1Auto,{"A1_COD"     ,cCod          ,Nil})
		aAdd(aSA1Auto,{"A1_LOJA"    ,cLoja         ,Nil})
		aAdd(aSA1Auto,{"A1_NOME"    ,cNomeCompleto ,Nil})
		aAdd(aSA1Auto,{"A1_NREDUZ"  ,cNomeReduzido ,Nil}) 
		aAdd(aSA1Auto,{"A1_CGC"     ,cCPF          ,Nil}) 
		aAdd(aSA1Auto,{"A1_PESSOA"  ,cTipoPessoa   ,Nil})
		aAdd(aSA1Auto,{"A1_TIPO"    ,cTipoCliente  ,Nil})
		aAdd(aSA1Auto,{"A1_END"     ,cEndereco     ,Nil}) 
		aAdd(aSA1Auto,{"A1_BAIRRO"  ,cBairro       ,Nil}) 
		aAdd(aSA1Auto,{"A1_EST"     ,cEstado       ,Nil})
		aAdd(aSA1Auto,{"A1_MUN"     ,cMunicipio    ,Nil})
		
		//---------------------------------------------------------
		// Dados do Complemento do Cliente
		//---------------------------------------------------------
		//aAdd(aAI0Auto,{"AI0_SALDO"  ,0            ,Nil})
		
		//------------------------------------
		// Chamada para cadastrar o cliente.
		//------------------------------------
		MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto, aAI0Auto)
		
						
			if !lMsErroAuto

				conOut(enter + oemToAnsi("Alterado com sucesso! ") + SA1->A1_NOME + enter)

				cOk := "Incluido"
				cMsg := "{"
				cMsg += '"Cliente": "' + SA1->A1_NREDUZ  + '",'
				cMsg += '"CPF": "' + SA1->A1_CGC  + '",'
				cMsg += '"Mensagem": "' +cOk+ '",'
				cMsg += "}"

				::setResponse( cMsg )	

			else

				conOut(OemToAnsi("Erro na Alteracao"))
				aLog := getAutoGRLog()
				cRet := 'ERRO' + enter
						
					for i := 1 to len(aLog)
						cRet += aLog[i] + enter
					next i
								
				conout(enter + cRet + enter)

				::setResponse('{') 
				::setResponse( 'Erro_encontrado : ' + cRet)
				::setResponse('}')

			endIf
		else
			cOk := "Cadastrado"
			cMsg := "{"
			cMsg += '"Cliente": "' + cNomeReduzido  + '",'
			cMsg += '"CPF": "' + cCPF  + '",'
			cMsg += '"Mensagem": "' +cOk+ '",'
			cMsg += "}"

			::setResponse( cMsg )
			
		endif
	endif

RpcClearEnv()

return lRet
