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
user function RestFin

return

WSRESTFUL TITULOS_FINANCEIRO DESCRIPTION "Executa rotinaS automática FINA040|FINA050 | Financeiro"

WSDATA cPref	AS STRING
WSDATA cNum 	AS STRING
WSDATA cParc	AS STRING
WSDATA cTipo 	AS STRING
WSDATA cAlias 	AS STRING
WSDATA cEmp     AS STRING
WSDATA cFilAtu     AS STRING

WSMETHOD GET        DESCRIPTION "GET TITULOS"      			WSSYNTAX ""
/*
WSMETHOD POST       DESCRIPTION "POST / INCLUSÃO FORNECEDORES "       	WSSYNTAX ""
*/
WSMETHOD PUT        DESCRIPTION "PUT/ALTERACAO FORNECEDORES"        	WSSYNTAX ""
/*
WSMETHOD DELETE     DESCRIPTION "DELETE FORNECEDORES"    				WSSYNTAX ""
*/
END WSRESTFUL

//***************************************
// MÉTODO DE CONSULTA TITULO - SE1||SE2**
//***************************************

WSMETHOD GET WSRECEIVE cAlias, cPref, cNum, cParc, cTipo, cEmp, cFilAtu WSSERVICE TITULOS_FINANCEIRO


local cJson         AS CHARACTER
local oParseJSON    AS OBJECT
local cPref			AS CHARACTER
local cNum			AS CHARACTER
local cPar          AS CHARACTER
local cTipo         AS CHARACTER
local cAlias        AS CHARACTER
local lAberto       AS LOGICAL

Default cAlias := Iif(Empty(Self:cAlias),"SE1", Self:cAlias)

If !empty(self:cEmp) 
	RPCSetType(3)  //Nao consome licensas
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })
	lAberto := .t.
Else
	lAberto := .f.
EndIf

cJson       := ::getContent()
oParseJSON	:= nil
//lRet		:= .f.
nCount      := 0
cMsg        := ''
cQry        := ''
cTable      := Iif(cAlias == "SE1","TMPSE1","TMPSE2")
cParc       := Iif(Empty(Self:cParc),Space(TAMSX3("E1_PARCELA")[1]),Self:cParc)

::setContentType("application/json")

FWJsonDeserialize(cJson, @oParseJSON)

dbSelectArea(cAlias)

(cAlias)->(dbSetOrder(1))
(cAlias)->(dbGoTop())

If !empty(::cPref) .or. !empty(::cNum) .or. !empty(::cTipo)

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

    If cAlias == "SE2"
    
        If (cAlias)->(dbSeek(xFilial(cAlias) + ::cPref+ ::cNum+ cParc+ ::cTipo))
        //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
                nCount++
                cData := Subs(dtos((cAlias)->E2_VENCREA),1,4)+"-"+Subs(dtos((cAlias)->E2_VENCREA),5,2)+"-"+Subs(dtos((cAlias)->E2_VENCREA),7,2)
	            cMsg += '{'
	            cMsg += '"Codigo": "' + (cAlias)->E2_FILIAL + '",'
	            cMsg += '"Prefixo": "' + (cAlias)->E2_PREFIXO  + '",'
	            cMsg += '"Numero": "' + (cAlias)->E2_NUM  + '",'
	            cMsg += '"Parcela": "' + (cAlias)->E2_PARCELA  + '",'
	            cMsg += '"Tipo": "' + (cAlias)->E2_TIPO  + '",'
	            cMsg += '"Nome": "' + (cAlias)->E2_NOMFOR  + '",'
	            cMsg += '"Valor": "' + cValtoChar((cAlias)->E2_VALOR)  + '",'
	            cMsg += '"Vencimento": "' + cData  + '"'
	            cMsg += '}' 
	            ::setResponse(cMsg)
        EndIf
        
    EndIf
   
Else   
	
	if cAlias == 'SE1' 
		cQry += "SELECT '01' as E1_cEmp, E1_FILIAL, E1_FILORIG, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR, E1_VENCTO," +enter
		cQry += "E1_VENCREA, E1_CLIENTE, E1_LOJA, E1_NOMCLI    FROM SE1010 SE1010" +enter
		cQry += "WHERE SE1010.D_E_L_E_T_ != '*'" +enter
		cQry += "AND E1_SALDO >0" +enter
		cQry += "and E1_TIPO NOT IN ('TX','CH','INS', 'PR')" +enter
		cQry += "and E1_VENCREA <=  '"+dtos(dDatabase+30)+"' " +enter
		cQry += "and E1_VENCREA >=  '"+dtos(dDatabase-180)+"' " +enter
		cQry += "UNION ALL" +enter
		cQry += "SELECT '02' as E1_cEmp, E1_FILIAL, E1_FILORIG, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR," +enter
		cQry += "E1_VENCTO, E1_VENCREA, E1_CLIENTE, E1_LOJA, E1_NOMCLI    FROM SE1020 SE1020" +enter
		cQry += "WHERE SE1020.D_E_L_E_T_ != '*'" +enter
		cQry += "AND E1_SALDO >0" +enter
		cQry += "and E1_TIPO NOT IN ('TX','CH','INS', 'PR')" +enter
		cQry += "and E1_VENCREA <=  '"+dtos(dDatabase+30)+"' " +enter
		cQry += "and E1_VENCREA >=  '"+dtos(dDatabase-180)+"' "+enter
		
		
		nStatus := TCSqlExec(cQry)
	EndIf
	//
	if cAlias == 'SE2' 
		cQry := "Select * from "+ RetSqlName("SE2")+ " SE2 "
		cQry += "Where SE2.D_E_L_E_T_ !='*' "
		cQry += "and E2_SALDO > 0 "
		cQry += "and E2_VENCREA <=  '"+dtos(dDatabase+30)+"' "
		cQry += "and E2_VENCREA >=  '"+dtos(dDatabase-180)+"' "
		cQry += "and E2_TIPO NOT IN ('TX','CH','INS', 'PR') "
		
		nStatus := TCSqlExec(cQry)
	EndIf
	
	if (nStatus < 0)
		conout("TCSQLError() " + TCSQLError())
		Msginfo("TCSQLError() " + TCSQLError())
		
		cMsg := "{'erro':'Consulta não executada.'}"
		Conout(cMsg)
		::setResponse(cMsg)
		Return .t.
		
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
				//cData := Subs(cTable->E1_VENCREA,1,4)+"-"+Subs(cTable->E1_VENCREA,5,2)+"-"+Subs(cTable->E1_VENCREA,7,2)
				cData := Subs(cTable->E1_VENCREA,7,2)+"/"+Subs(cTable->E1_VENCREA,5,2)+"/"+Subs(cTable->E1_VENCREA,1,4)
	            cMsg += '{'
	            cMsg += '"Codigo": "' + Iif(cTable->E1_cEmp == '01', "01-Galderma", "02-Galderma Distribuidora") + '",'
				cMsg += '"Filial": "' + cTable->E1_FILORIG + '",'
	            cMsg += '"Prefixo": "' + cTable->E1_PREFIXO  + '",'
	            cMsg += '"Numero": "' + cTable->E1_NUM  + '",'
	            cMsg += '"Parcela": "' + cTable->E1_PARCELA  + '",'
	            cMsg += '"Tipo": "' + cTable->E1_TIPO  + '",'
	            cMsg += '"Nome": "' + cTable->E1_NOMCLI  + '",'
	            cMsg += '"Valor": "' + cValtoChar(cTable->E1_VALOR)  + '",'
	            cMsg += '"Vencimento": "' + cData  + '"'
	            cMsg += "},"
	    endIf
	    
	    if cAlias == 'SE2' 
	    		cData := Subs(cTable->E2_VENCREA,1,4)+"-"+Subs(cTable->E2_VENCREA,5,2)+"-"+Subs(cTable->E2_VENCREA,7,2)
	            cMsg += '{'
	            cMsg += '"Codigo": "' + cTable->E2_FILORIG + '",'
	            cMsg += '"Prefixo": "' + cTable->E2_PREFIXO  + '",'
	            cMsg += '"Numero": "' + cTable->E2_NUM  + '",'
	            cMsg += '"Parcela": "' + cTable->E2_PARCELA  + '",'
	            cMsg += '"Tipo": "' + cTable->E2_TIPO  + '",'
	            cMsg += '"Nome": "' + cTable->E2_NOMFOR  + '",'
	            cMsg += '"Valor": "' + cValtoChar(cTable->E2_VALOR)  + '",'
	            cMsg += '"Vencimento": "' + cData  + '"'
	            cMsg += "},"
	    endIf
	    cTable->(dbSkip())
    EndDo
    cTable->(dbCloseArea())
 
    	If nCount == 0
		    //setRestFault(001,"{erro: Titulo nao encontrado}")
		    cMsg += "{'erro':'Titulos nao encontrados'}"
		    cMsg += ']' //Final Json
		    ::setResponse(cMsg)
		    Return .t.
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

WSMETHOD PUT WSSERVICE TITULOS_FINANCEIRO

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
Private nValAtu := Val(oParseJSON:NVALOR)
Private cParc   := If(Empty(oParseJSON:CPARC),Space(TAMSX3("E1_PARCELA")[1]),oParseJSON:CPARC)
Private cNum    := oParseJSON:CNUM//Iif(Len(oParseJSON:CNUM)>=1, oParseJSON:CNUM[1],oParseJSON:CNUM )
Private cTable  := oParseJSON:CTABLE
Private cEmp    := Subs(oParseJSON:CEMP,1,2)
Private cFil    := "02"

If !empty(cEmp) 
	RPCSetType(3)  //Nao consome licensas
	RpcSetEnv( cEmp,cFil,,,"FIN")
	lAberto := .t.
	conout("Entrou no ambiente: "+FWCodEmp()+" e Filial:"+cFilant)
Else
	lAberto := .f.
	conout("Não entrou na empresa "+oParseJSON:CEMP+ " Estou na empresa:"+FWCodEmp()+" e Filial:"+cFilant)
EndIf

DbSelectArea(cTable) 
DbSetOrder(1)
	
	If cTable == "SE2"
	
			If DbSeek(xFilial(cTable)+oParseJSON:CPREF+cNum+cParc+oParseJSON:CTIPO) //Exclusão deve ter o registro SE2 posicionado
	                                
					aArray := { { "E2_PREFIXO" , oParseJSON:CPREF, NIL },;
								{ "E2_NUM" , cNum, NIL },;
								{ "E2_PARCELA" , cParc, NIL },;
								{ "E2_TIPO" , oParseJSON:CTIPO, NIL },;
								{ "E2_VENCREA" , dVencto, NIL },;
					            { "E2_VALOR"   , nValAtu     , NIL } }
					 
					MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 4)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão 
					
					if !lMsErroAuto
						conOut(enter + oemToAnsi("Alterado com sucesso! ") + SE2->E2_NUM + enter)
						cRet := "Alterado com sucesso " + SE2->E2_NUM	
					else
						conOut(OemToAnsi("Erro na Alteracao"))
						aLog := getAutoGRLog()
						cRet := 'ERRO' + enter
						
						for i := 1 to len(aLog)
							cRet += aLog[i] + enter
						next i
							
						conout(enter + cRet + enter)
					endIf
					
					::setResponse('{') 
					::setResponse( '"Retorno_ok": "' + cRet + '"')
					::setResponse('}')
					
			Else
				::setResponse('{') 
				::setResponse( '"Erro_encontrado": "' + xFilial("SE2")+oParseJSON:CPREF+cNum+cParc+oParseJSON:CTIPO + '"')
				::setResponse('}')
			EndIf
	EndIf

	/*############################################	
	//Alteração titulos a receber
	#############################################*/

	If cTable == "SE1"
	
		If DbSeek(xFilial(cTable)+oParseJSON:CPREF+cNum+cParc+oParseJSON:CTIPO) //Exclusão deve ter o registro SE2 posicionado
		
			aArray := { { "E1_PREFIXO" , oParseJSON:CPREF, NIL },;
						{ "E1_NUM" , cNum, NIL },;
						{ "E1_PARCELA" , cParc, NIL },;
						{ "E1_TIPO" , oParseJSON:CTIPO, NIL },;
						{ "E1_VENCREA" , dVencto, NIL },;
			            { "E1_VALOR"   , nValAtu     , NIL } }
			 
			MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 4)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
			
			if !lMsErroAuto
				conOut(enter + oemToAnsi("Alterado com sucesso! ") + SE1->E1_NUM + enter)
				cRet := "Alterado com sucesso " + SE1->E1_NUM	
			else
				conOut(OemToAnsi("Erro na Alteracao"))
				aLog := getAutoGRLog()
				cRet := 'ERRO' + enter
				
				for i := 1 to len(aLog)
					cRet += aLog[i] + enter
				next i
					
				conout(enter + cRet + enter)
			endIf
			
			::setResponse('{') 
			::setResponse( '"Retorno_ok": "' + cRet + '"')
			::setResponse('}')
		Else
			::setResponse('{') 
			::setResponse( '"Erro_encontrado": "' + xFilial(cTable)+oParseJSON:CPREF+cNum+cParc+oParseJSON:CTIPO + '"')
			::setResponse('}')
		EndIf
		
	EndIf

If lAberto 
	RpcClearEnv()
EndIf

return .t.
