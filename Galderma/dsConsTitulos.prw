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
user function RestFina

return

WSRESTFUL TITULOS_FINANCEIRO DESCRIPTION "Executa rotinaS automática FINA040|FINA050 | Financeiro"

WSDATA cPref	AS STRING
WSDATA cNum 	AS STRING
WSDATA cParc	AS STRING
WSDATA cTipo 	AS STRING
WSDATA cAlias 	AS STRING
WSDATA cEmp     AS STRING
WSDATA cFil     AS STRING
WSDATA cFilAtu  AS STRING
WSDATA cCliente AS STRING

WSMETHOD GET        DESCRIPTION "GET TITULOS"      			WSSYNTAX ""
/*
WSMETHOD POST       DESCRIPTION "POST / INCLUSÃO FORNECEDORES "       	WSSYNTAX ""
*/
WSMETHOD POST        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
/*
WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""
*/
END WSRESTFUL

//***************************************
// MÉTODO DE CONSULTA TITULO - SE1||SE2**
//***************************************

WSMETHOD GET WSRECEIVE cAlias, cPref, cNum, cParc, cTipo, cEmp,cFil, cFilAtu, cCliente WSSERVICE TITULOS_FINANCEIRO

local cJson         	   AS CHARACTER
local oParseJSON    	   AS OBJECT
local cAlias               AS CHARACTER
local lAberto := .F.       AS LOGICAL

Default cAlias   := Iif(valtype(Self:cAlias) == 'U',"SE1", Self:cAlias)
Default cCliente := Iif(valtype(self:cCliente) == 'U', "", strtran(self:cCliente,"'",""))
Default cFil     := Iif(valtype(self:cFil) == "U","01",self:cFil)
Default cEmp     := strtran(Iif(valtype(self:cEmp) == "U","99",self:cEmp),"'","")

If !empty(cEmp) 
	RpcClearEnv() //Se tiver aberto, fecha o ambiente
	RPCSetType(3)  //Nao consome licensas
	lAberto := RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })
EndIf

cJson       := ::getContent()
oParseJSON	:= nil
//lRet		:= .f.
nCount      := 0
cMsg        := ''
cQry        := ''
cTable      := Iif(cAlias == "SE1","TMPSE1","TMPSE2")
cParc       := Iif(valtype(Self:cParc) == 'U',Space(TAMSX3("E1_PARCELA")[1]),Self:cParc)

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

If !empty(::cPref) .or. !empty(::cNum) .or. !empty(::cTipo)
	dbSelectArea(cAlias)

	(cAlias)->(dbSetOrder(1))
	(cAlias)->(dbGoTop())

    If cAlias == "SE1"
    
        If (cAlias)->(dbSeek(xFilial(cAlias) + ::cPref+ ::cNum+ cParc+ ::cTipo))
        //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
        		nCount++
        		cData := Subs(dtos((cAlias)->E1_VENCREA),1,4)+"-"+Subs(dtos((cAlias)->E1_VENCREA),5,2)+"-"+Subs(dtos((cAlias)->E1_VENCREA),7,2)
	            cMsg += '{'
	            cMsg += '"Codigo": "' +  (cAlias)->E1_FILIAL + '",'
	            cMsg += '"Prefixo": "' + (cAlias)->E1_PREFIXO  + '",'
	            cMsg += '"Numero": "' +  (cAlias)->E1_NUM  + '",'
	            cMsg += '"Parcela": "' + (cAlias)->E1_PARCELA  + '",'
	            cMsg += '"Tipo": "' +    (cAlias)->E1_TIPO  + '",'
	            cMsg += '"Nome": "' +    (cAlias)->E1_NOMCLI  + '",'
	            cMsg += '"Valor": "' +    cValtoChar((cAlias)->E1_VALOR)  + '",'
	            cMsg += '"Vencimento": "' + cData  + '"'
	            cMsg += '}' 
                ::setResponse(cMsg)
        EndIf
    EndIf   
   
Else   
	
	if cAlias == 'SE1' 

		cQry += "SELECT E1_FILIAL, E1_FILORIG, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR, E1_VENCTO," +enter
		cQry += "E1_VENCREA, E1_CLIENTE, E1_LOJA, E1_NOMCLI FROM "+RetSqlName("SE1")+" SE1 " +enter
		cQry += "WHERE SE1.D_E_L_E_T_ != '*'" +enter
		cQry += "AND E1_SALDO >0" +enter
		cQry += "and E1_TIPO NOT IN ('TX','CH','INS', 'PR','NCC')" +enter
		cQry += "and E1_VENCREA <=  '"+dtos(dDatabase+180)+"' " +enter
		cQry += "and E1_VENCREA >=  '"+dtos(dDatabase-180)+"' " +enter
		If !empty(cCliente)
			cQry += "and E1_CLIENTE ='"+cCliente+"'"
		endIf
				
		nStatus := TCSqlExec(cQry)
		conout("Tabela:"+RetSqlName("SE1")+" - "+cQry)
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

		if cAlias == 'SE1' 
				cData := Subs(cTable->E1_VENCREA,7,2)+"/"+Subs(cTable->E1_VENCREA,5,2)+"/"+Subs(cTable->E1_VENCREA,1,4)
				cData1 := Subs(cTable->E1_VENCTO,7,2)+"/"+Subs(cTable->E1_VENCTO,5,2)+"/"+Subs(cTable->E1_VENCTO,1,4)
	            cMsg += '{'
	            cMsg += '"Codigo": "' + Iif(FWCodEmp() == '01', "01-Galderma",Iif(FWCodEmp() == "02", "02-Galderma Distribuidora","99-Desenvolvimento")) + '",'
				cMsg += '"Filial": "' + cTable->E1_FILORIG + '",'
	            cMsg += '"Prefixo": "' + cTable->E1_PREFIXO  + '",'
	            cMsg += '"Numero": "' + cTable->E1_NUM  + '",'
	            cMsg += '"Parcela": "' + cTable->E1_PARCELA  + '",'
	            cMsg += '"Tipo": "' + cTable->E1_TIPO  + '",'
	            cMsg += '"Nome": "' + cTable->E1_NOMCLI  + '",'
	            //cMsg += '"ValorConvertido": "' + Transform( cTable->E1_VALOR, "@E 9,999,999.99")  + '",'
				cMsg += '"Valor": "' + cValtochar(cTable->E1_VALOR)  + '",'
	            cMsg += '"Vencimento": "' + cData  + '",'
				cMsg += '"VencimentoReal": "' + cData1  + '",'
				cMsg += '"codigoCliente": "' + cTable->E1_CLIENTE  + '",'
				cMsg += '"lojaCliente": "' + cTable->E1_LOJA  + '"'
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
// MÉTODO DE ALTERA TITULO - SE1||SE2**
//************************************* 

WSMETHOD POST WSSERVICE TITULOS_FINANCEIRO

local cJson         := ::getContent()
local oParseJSON    := nil
local i
Local aArray := {}
Local cRet := ''

private lMsErroAuto 	:= .f.
private lAutoErrNoFile 	:= .t.

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

Private dVencto := CtoD(oParseJSON:DDATA)//stod(strtran(oParseJSON:DDATA,'-',''))
Private nValAtu := oParseJSON:NVALOR
Private cParc   := If(Empty(oParseJSON:CPARC),Space(TAMSX3("E1_PARCELA")[1]),oParseJSON:CPARC)
Private cNum    := oParseJSON:CNUM//Iif(Len(oParseJSON:CNUM)>=1, oParseJSON:CNUM[1],oParseJSON:CNUM )
Private cTable  := oParseJSON:CTABLE
Private cEmp    := Subs(oParseJSON:CEMP,1,2)

If !empty(cEmp) 
	RPCSetType(3)  //Nao consome licensas
	RpcSetEnv( cEmp,"01",,,"FIN")
	lAberto := .t.
	conout("Entrou no ambiente: "+FWCodEmp()+" e Filial:"+cFilant)
Else
	lAberto := .f.
	conout("N�o entrou na empresa "+oParseJSON:CEMP+ " Estou na empresa:"+FWCodEmp()+" e Filial:"+cFilant)
EndIf

DbSelectArea(cTable) 
DbSetOrder(1)
	
	/*############################################	
	//Alteração titulos a receber
	#############################################*/

	If cTable == "SE1"
	
		If DbSeek(xFilial(cTable)+oParseJSON:CPREF+cNum+cParc+oParseJSON:CTIPO) //Exclusão deve ter o registro SE2 posicionado
			//Trata os pontos do retorno
			while at(".",nValAtu) > 0
				nValAtu := strtran(nValAtu,".","")
			endDo
			//S� altera se tiver virgula nas casas decimais
			nValAtu := strtran(nValAtu,",",".")

			aArray := { { "E1_PREFIXO" , oParseJSON:CPREF, NIL },;
						{ "E1_NUM" , cNum, NIL },;
						{ "E1_PARCELA" , cParc, NIL },;
						{ "E1_TIPO" , oParseJSON:CTIPO, NIL },;
						{ "E1_VENCREA" , dVencto, NIL },;
			            { "E1_VALOR"   , Val(nValAtu), NIL } }
			 
			MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 4)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
			
			if !lMsErroAuto
				conOut(enter + oemToAnsi("Alterado com sucesso! ") + SE1->E1_NUM + enter)
				cRet := "Alterado com sucesso " + SE1->E1_NUM

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
			
		Else
			SetRestFault(405,"Titulo nao encontrado")
			Return .F.
		EndIf
		
	EndIf

If lAberto 
	RpcClearEnv()
EndIf

return .t.

