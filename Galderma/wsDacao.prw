#include "protheus.ch"
#include "restful.ch"
#include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"

#define enter chr(13) + chr(10)
/*
01 -  Galderma
02 -  Galderma Distribuidora do Brasil Ltda
03 -  INNEOV
*/
user function RestDacao

return .t.

WSRESTFUL BAIXA_TITULOS DESCRIPTION "Executa rotinas automáticas FINA080||FINA070 | Financeiro"

WSDATA alias	AS STRING
WSDATA empresa	AS STRING
WSDATA filial 	AS STRING
WSDATA prefixo	AS STRING
WSDATA numero 	AS STRING
WSDATA parcela 	AS STRING
WSDATA tipo     AS STRING
WSDATA fornece  AS STRING
WSDATA loja     AS STRING

WSMETHOD GET        DESCRIPTION "GET TITULOS"      			WSSYNTAX ""
/*
WSMETHOD POST       DESCRIPTION "POST / INCLUSÃƒO FORNECEDORES "       	WSSYNTAX ""
*/
WSMETHOD POST        DESCRIPTION "BAIXA TITULOS"        	WSSYNTAX ""
/*
WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""
*/
END WSRESTFUL

//***************************************
// MÃ‰TODO DE CONSULTA TITULO - SE2||SE2**
//***************************************

WSMETHOD GET WSRECEIVE Alias, empresa, filial, prefixo, numero, parcela, tipo, fornece, loja  WSSERVICE BAIXA_TITULOS

local cJson         	   AS CHARACTER
local oParseJSON    	   AS OBJECT
local Alias               AS CHARACTER
local lAberto := .F.       AS LOGICAL

Default Alias   := Iif(valtype(Self:Alias) == 'U',"SE2", Self:Alias)
Default fornece := Iif(valtype(self:fornece) == 'U', "", self:fornece)
Default loja    := Iif(valtype(self:loja) == "U","01",self:loja)
Default empresa := Iif(valtype(self:empresa) == "U","99",self:empresa)
Default filial  := Iif(valtype(self:filial) == "U","01",self:filial)

If !empty(empresa) 
	RpcClearEnv() //Se tiver aberto, fecha o ambiente
	RPCSetType(3)  //Nao consome licensas
	lAberto := RpcSetEnv(empresa,filial,,,,GetEnvServer(),{ })
EndIf

cJson       := ::getContent()
oParseJSON	:= nil
//lRet		:= .f.
nCount      := 0
cMsg        := ''
cQry        := ''
cTable      := Iif(Alias == "SE2","TMPSE2","TMPSE2")
cParc       := Iif(valtype(Self:parcela) == 'U',Space(TAMSX3("E2_PARCELA")[1]),Self:parcela)

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

If !empty(::prefixo) .or. !empty(::numero) .or. !empty(::tipo)
	dbSelectArea(alias)

	(alias)->(dbSetOrder(1))
	(alias)->(dbGoTop())

    If alias == "SE2"
    
        If (Alias)->(dbSeek(xFilial(Alias) + ::prefixo+ ::numero+ parcela+ ::tipo+ ::fornece+ ::loja))
        //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
        		nCount++
        		cData := Subs(dtos((cAlias)->E2_VENCREA),1,4)+"-"+Subs(dtos((cAlias)->E2_VENCREA),5,2)+"-"+Subs(dtos((cAlias)->E2_VENCREA),7,2)
	            cMsg += '{'
	            cMsg += '"Codigo": "' +  (cAlias)->E2_FILIAL + '",'
	            cMsg += '"Prefixo": "' + (cAlias)->E2_PREFIXO  + '",'
	            cMsg += '"Numero": "' +  (cAlias)->E2_NUM  + '",'
	            cMsg += '"Parcela": "' + (cAlias)->E2_PARCELA  + '",'
	            cMsg += '"Tipo": "' +    (cAlias)->E2_TIPO  + '",'
	            cMsg += '"Nome": "' +    (cAlias)->E2_NOMFOR  + '",'
	            cMsg += '"Valor": "' +    cValtoChar((cAlias)->E2_VALOR)  + '",'
	            cMsg += '"Vencimento": "' + cData  + '"'
	            cMsg += '}' 
                ::setResponse(cMsg)
        EndIf
    EndIf   
   
Else   
	
	if Alias == 'SE2' 

		cQry += "SELECT E2_FILIAL, E2_FILORIG, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_VALOR, E2_VENCTO," +enter
		cQry += "E2_VENCREA, E2_FORNECE, E2_LOJA, E2_NOMFOR FROM "+RetSqlName("SE2")+" SE2 " +enter
		cQry += "WHERE SE2.D_E_L_E_T_ != '*'" +enter
		cQry += "AND E2_SALDO >0" +enter
		cQry += "and E2_TIPO NOT IN ('TX','CH','INS', 'PR','NCC')" +enter
		cQry += "and E2_VENCREA <=  '"+dtos(dDatabase+180)+"' " +enter
		cQry += "and E2_VENCREA >=  '"+dtos(dDatabase-180)+"' " +enter
		If !empty(fornece)
			cQry += "and E2_CLIENTE ='"+fornece+"'"
		endIf
				
		nStatus := TCSqlExec(cQry)
		conout("Tabela:"+RetSqlName("SE2")+" - "+cQry)
	EndIf
	//
	if (nStatus < 0)
		conout("TCSQLError() " + TCSQLError())
		Msginfo("TCSQLError() " + TCSQLError())
		
		SetRestFault(403,'Titulos nao encontrados.')
		Return .F.
		
	endif

	If select(cTable) > 0
		cTable->(dbCloseArea())
	EndIf
	//
	TCQuery (cQry) ALIAS cTable NEW
	//
	cMsg := '[' //Inicio Jason

	While cTable->(!eof())
	
		nCount++

		if Alias == 'SE2' 
				cData := Subs(cTable->E2_VENCREA,7,2)+"/"+Subs(cTable->E2_VENCREA,5,2)+"/"+Subs(cTable->E2_VENCREA,1,4)
				cData1 := Subs(cTable->E2_VENCTO,7,2)+"/"+Subs(cTable->E2_VENCTO,5,2)+"/"+Subs(cTable->E2_VENCTO,1,4)
	            cMsg += '{'
	            cMsg += '"Codigo": "' + Iif(FWCodEmp() == '01', "01-Galderma",Iif(FWCodEmp() == "02", "02-Galderma Distribuidora","99-Desenvolvimento")) + '",'
				cMsg += '"Filial": "' + cTable->E2_FILORIG + '",'
	            cMsg += '"Prefixo": "' + cTable->E2_PREFIXO  + '",'
	            cMsg += '"Numero": "' + cTable->E2_NUM  + '",'
	            cMsg += '"Parcela": "' + cTable->E2_PARCELA  + '",'
	            cMsg += '"Tipo": "' + cTable->E2_TIPO  + '",'
	            cMsg += '"Nome": "' + cTable->E2_NOMFOR  + '",'
	            //cMsg += '"ValorConvertido": "' + Transform( cTable->E2_VALOR, "@E 9,999,999.99")  + '",'
				cMsg += '"Valor": "' + cValtochar(cTable->E2_VALOR)  + '",'
	            cMsg += '"Vencimento": "' + cData  + '",'
				cMsg += '"VencimentoReal": "' + cData1  + '",'
				cMsg += '"codigoFornece": "' + cTable->E2_FORNECE  + '",'
				cMsg += '"lojaFornece": "' + cTable->E2_LOJA  + '"'
	            cMsg += "},"
	    endIf
	    cTable->(dbSkip())
    EndDo
    cTable->(dbCloseArea())
 
    	If nCount == 0
			SetRestFault(404,'Titulos nao encontrados.')
			Return .F.
		Else
			cMsg += ']' //Final Json
			cMsg := strtran(cMsg,",]","]")
			::setResponse(cMsg)
	    EndIf 
	    
EndIf

/*Libera o Ambiente*/
If lAberto 
	RpcClearEnv()
EndIf
//
return .T.

//*************************************
// METODO BAIXA DE TITULO - SE2||SE2**
/* json
{
	"empresa":"99",
	"filial":"01",
	"prefixo":"002",
	"numero":"000000001",
	"parcela": "A ",
	"tipo": "NF ",
	"valor": 312.5,
	"alias": "SE2",
	"processo":"113",
	"atividade":"4"
}
*/
//************************************* 

WSMETHOD POST WSSERVICE BAIXA_TITULOS

local cJson         := ::getContent()
local oParseJSON    := nil

Local cChave     := ""
Local lRet       := .T.
Local lExibeLanc := .F. //Exibe Lancamento
Local lOnline    := .F. //Lancamento online?
Local cRet       := ''
Local i := 0

//Operação a ser realizada (3 = Baixa, 5 = cancelamento, 6 = Exclusão)
Local nOpc := 3
//Valor a ser baixado
Local nVlrPag := 0
//Sequência de baixa a ser cancelada.
Local nSeqBx := 1

private lMsErroAuto 	:= .f.
private lAutoErrNoFile 	:= .t.

::setContentType("application/json")

lJson := FWJsonDeserialize(cJson, @oParseJSON)

Private empresa  := Subs(oParseJSON:empresa,1,2)
Private filial   := oParseJSON:filial
Private prefixo  := If(Empty(oParseJSON:prefixo),Space(TAMSX3("E2_PREFIXO")[1]),oParseJSON:prefixo)
Private numero   := oParseJSON:numero//Iif(Len(oParseJSON:CNUM)>=1, oParseJSON:CNUM[1],oParseJSON:CNUM )
Private parcela  := If(Empty(oParseJSON:parcela),Space(TAMSX3("E2_PARCELA")[1]),oParseJSON:parcela)
Private tipo     := oParseJSON:tipo
Private valor    := oParseJSON:valor
Private tabela   := oParseJSON:alias
Private processo := oParseJSON:processo
Private atividade:= oParseJSON:atividade
Private cHistBaixa := "Integração Fluig - Processo: "+oParseJSON:processo+" ||Atividade: "+oParseJSON:atividade

if !lJson
	cRet := 'Objeto invalido, verifique o Json enviado!'
	::setResponse('{') 
	::setResponse( '"nOK": "' + cRet + '"')
	::setResponse('}')
endIf

If !empty(empresa) 
	RPCSetType(3)  //Nao consome licensas
	RpcSetEnv( empresa,"01",,,"FIN")
	lAberto := .t.
	conout("Entrou no ambiente: "+FWCodEmp()+" e Filial:"+cFilant)
Else
	lAberto := .f.
	conout("Não entrou na empresa "+oParseJSON:empresa+ " Estou na empresa:"+FWCodEmp()+" e Filial:"+cFilant)
EndIf

DbSelectArea(tabela)
    (tabela)->(dbSetOrder(1))
    (tabela)->(dbGoTop())
    (tabela)->(DbSeek(xFilial(tabela) + prefixo + numero + parcela + tipo))

	cChave := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
	conout("Chave de pesquisa: "+cChave)
	
	/*############################################	
	//AlteraÃ§Ã£o titulos a receber
	#############################################*/

	If SE2->(dbSeek(cChave))

		conout("Achou a chave: "+cChave)

        If nOpc == 3
            If lRet := (nVlrPag + SE2->E2_SALDO) > 0
                nVlrPag := If(nVlrPag > 0, nVlrPag, SE2->E2_SALDO)
            EndIf
        ElseIf SE2->E2_VALOR >= SE2->E2_SALDO
            nVlrPag := 0
        EndIf
     
        If lRet
            aBaixa := {}        
         
            Aadd(aBaixa, {"E2_FILIAL", filial,   nil})
            Aadd(aBaixa, {"E2_PREFIXO", prefixo, nil})
            Aadd(aBaixa, {"E2_NUM", numero,      nil})
            Aadd(aBaixa, {"E2_PARCELA", parcela, nil})
            Aadd(aBaixa, {"E2_TIPO", tipo,       nil})
            Aadd(aBaixa, {"E2_FORNECE", SE2->E2_FORNECE,  nil})
            Aadd(aBaixa, {"E2_LOJA", SE2->E2_LOJA ,       nil})
            Aadd(aBaixa, {"AUTMOTBX", "DAC",              nil})
            Aadd(aBaixa, {"AUTBANCO", /*banco*/"",          nil})
            Aadd(aBaixa, {"AUTAGENCIA", /*agencia*/"",      nil})
            Aadd(aBaixa, {"AUTCONTA", /*conta*/"",          nil})
            Aadd(aBaixa, {"AUTDTBAIXA", dDataBase,        nil})
            Aadd(aBaixa, {"AUTDTCREDITO", dDataBase,      nil})
            Aadd(aBaixa, {"AUTHIST", cHistBaixa,          nil})
            Aadd(aBaixa, {"AUTVLRPG", nVlrPag,            nil})
 
            //Pergunte da rotina
             AcessaPerg("FINA080", .F.)                  
         
            //Chama a execauto da rotina de baixa manual (FINA080)
            MsExecauto({|a,b,c,d,e,f,| FINA080(a,b,c,d,e,f)}, aBaixa, nOpc, .F., nSeqBx, lExibeLanc, lOnline)
			
			if !lMsErroAuto
				conOut(enter + oemToAnsi("Alterado com sucesso! ") + SE2->E2_NUM + enter)
				cRet := "Alterado com sucesso " + SE2->E2_NUM

				::setResponse('{') 
				::setResponse( '"OK": "' + cRet + '"')
				::setResponse('}')	
			else
				conOut(OemToAnsi("Erro na Alteracao"))
				aLog := getAutoGRLog()
				cRet := 'ERRO' + enter
				
				for i := 1 to len(aLog)
					cRet += aLog[i] + enter
				next i
					
				conout(enter + cRet + enter)

				SetRestFault(406,cRet)
				Return .F.
			endIf
			
		EndIf
	Else
			SetRestFault(405,"Titulo nao encontrado")
			Return .F.	
	EndIf

If lAberto 
	RpcClearEnv()
EndIf

return .t.
