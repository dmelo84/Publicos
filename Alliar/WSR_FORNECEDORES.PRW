#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function WSR_FORNECEDORES()
Return



WSRESTFUL FORNECEDORES DESCRIPTION "Serviço REST para interação com cadastro de fornecedores"

WSMETHOD POST DESCRIPTION "Insere/altera Cadastro de Fornecedor Titulo Contas a Pagar" WSSYNTAX "/FORNECEDORES "//"|| /CONTAS_PAGAR/{}"

END WSRESTFUL


WSMETHOD POST  WSSERVICE FORNECEDORES
Local oObjProd := Nil
Local cStatus  := ""
LOcal cBody		:= ""
Local cJRetOK   := '{"code":200,"status":"success"}'
Local oJson	
Local lRet		:= .F.

Local aMedicos	:= {}
Local aContato	:= {}
Local aEndereco := {}
Local aTelefone := {}
Local aAuxDados := {}
Local cCRM		:= ""
Local cUFCRM	:= ""
Local cChvMed	:= ""
Local aRetAux


Local cAutBasic		:= ""
Local lAutorizado	:= .F.	


Local nOpcPac	:= 0 //|3- Inclusão, 4- Alteração, 5- Exclusão|

Private cVisitad

::SetContentType("application/json")

/*------------------------------------------------------ Augusto Ribeiro | 18/01/2018 - 9:36:31 PM
	Bloco de Autorização 
------------------------------------------------------------------------------------------*/

cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46|
	

IF U_CPxAuWSR(cAutBasic)

	cBody := ::GetContent()
	IF !EMPTY(cBody)
	

		//IF FWJsonDeserialize(cBody,@oJson)
		CONOUT(cBody)
		aRetAux	:= U_WSRFOR(cBody)
		if aRetAux[1]
			::SetResponse('{"errorCode":200,"errorMessage":"Sucesso"}')
			lRet	:= .t.
		else
			SetRestFault(400, aRetAux[2])	
		endif
	ELSE
		SetRestFault(400, "Empty Body")	
	ENDIF
ELSE
	SetRestFault(401, "Authentication Required")
ENDIF


Return(lRet)


/*/{Protheus.doc} WSRCPADD
Insere registro no contas a receber a partir do JSON
@author Augusto Ribeiro | www.compila.com.br
@since 18/01/2018
@version undefined
@param cJson
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function WSRFOR(cJson)
Local aRet	:= {.f.,""}
Local oJson, cAutoLog, cMemo
lOCAL _cCodEmp, _cCodFil, _cFilNew
lOCAL lError	:= .F.
Local cMsgErro	:= ""
Local oErro 	:= ErrorBlock({|e| lError := .T., cMsgErro := "[WSR_FORNECEDORES e] "+IIF(VALTYPE(e:Description)=="C", e:Description,"Falha na execucao ")+CRLF+"ERROR STACK"+IIF(VALTYPE(e:ERRORSTACK)=="C",e:ERRORSTACK,"")})//, BREAK  })
Local aCadFor	:= {}
Local aBcoFor	:= {}
Local aBanco	:= {}
Local aCpoSA2	:= {}
/*--------------------------
	CAMPOOS INTEGRADOS
---------------------------*/
AADD(aCpoSA2,"A2_COD"    )
AADD(aCpoSA2,"A2_LOJA"   )
AADD(aCpoSA2,"A2_TIPO"   )
AADD(aCpoSA2,"A2_CGC"    )
AADD(aCpoSA2,"A2_NOME"   )
AADD(aCpoSA2,"A2_NREDUZ" )
AADD(aCpoSA2,"A2_END"    )
AADD(aCpoSA2,"A2_BAIRRO" )
AADD(aCpoSA2,"A2_EST"    )
AADD(aCpoSA2,"A2_COD_MUN")
AADD(aCpoSA2,"A2_MUN"    )
AADD(aCpoSA2,"A2_CEP"    )
AADD(aCpoSA2,"A2_DDD"    )
AADD(aCpoSA2,"A2_TEL"    )
AADD(aCpoSA2,"A2_FAX"    )
AADD(aCpoSA2,"A2_INSCR"  )
AADD(aCpoSA2,"A2_INSCRM" )
AADD(aCpoSA2,"A2_PAIS"   )
AADD(aCpoSA2,"A2_PAISDES")
AADD(aCpoSA2,"A2_EMAIL"  )
AADD(aCpoSA2,"A2_HPAGE"  )
AADD(aCpoSA2,"A2_BANCO"  )
AADD(aCpoSA2,"A2_AGENCIA")
AADD(aCpoSA2,"A2_NUMCON" )
AADD(aCpoSA2,"A2_COND"   )
AADD(aCpoSA2,"A2_NATUREZ")
AADD(aCpoSA2,"A2_RECPIS" )
AADD(aCpoSA2,"A2_RECCOFI")
AADD(aCpoSA2,"A2_RECCSLL")
AADD(aCpoSA2,"A2_RECISS" )
AADD(aCpoSA2,"A2_CALCIRF")
AADD(aCpoSA2,"A2_SIMPNAC")
AADD(aCpoSA2,"A2_TPJ"    )
AADD(aCpoSA2,"A2_CODPAIS")
AADD(aCpoSA2,"A2_XIDFLG" )
AADD(aCpoSA2,"A2_DVCTA"  )
AADD(aCpoSA2,"A2_DVAGE"  )
AADD(aCpoSA2,"A2_COMPLEM")
AADD(aCpoSA2,"A2_XCLM0"  )    


IF FWJsonDeserialize(cJson,@oJson)
	
	/*------------------------------------------------------ Augusto Ribeiro | 01/02/2018 - 1:50:25 PM
		Estou utilizando a atribuiçõa campo a campo pois nesta versão da BUIL/LIB  a função
		ClassDataArr( < oObj >, [ lParent ] ) não funciona de maneira correta.
	------------------------------------------------------------------------------------------*/
	//IF AttIsMemberOf(oJson , "E2_NUM")
	
	Begin Sequence  
	
	aCadFor		:= {}
	FOR nI := 1 to len(aCpoSA2)
		IF AttIsMemberOf(oJson:CABEC , aCpoSA2[nI])
			
			IF oJson:OPERACAO == 3 .AND. (aCpoSA2[nI] == "A2_COD" .OR. aCpoSA2[nI] == "A2_LOJA")
				LOOP
			ENDIF		
			xValor	:= &("oJson:CABEC:"+alltrim(aCpoSA2[nI]))
			AADD(aCadFor,{aCpoSA2[nI],  xValor, nil})	
		endif	
	NEXT nI
	

	aBcoFor	:= {}
	
	FOR nI := 1 TO LEN(oJson:BANCOS)
		aBanco	:= {}
	 
		aadd(aBanco, {"OPERACAO",oJson:BANCOS[nI]:OPERACAO,NIL})
		aadd(aBanco, {"FIL_BANCO",oJson:BANCOS[nI]:FIL_BANCO,NIL})
		aadd(aBanco, {"FIL_AGENCI",oJson:BANCOS[nI]:FIL_AGENCI,NIL})
		aadd(aBanco, {"FIL_DVAGE",oJson:BANCOS[nI]:FIL_DVAGE,NIL})
		aadd(aBanco, {"FIL_CONTA",oJson:BANCOS[nI]:FIL_CONTA,NIL})
		aadd(aBanco, {"FIL_DVCTA",oJson:BANCOS[nI]:FIL_DVCTA,NIL})
		aadd(aBanco, {"FIL_TIPO",oJson:BANCOS[nI]:FIL_TIPO,NIL})
		aadd(aBanco, {"FIL_TIPCTA",oJson:BANCOS[nI]:FIL_TIPCTA,NIL})
		
		AADD(aBcoFor, aBanco)
	NEXT nI
	
	
	
	IF lError
		BREAK
	ENDIF
	
	
	aRet	:= U_CadForV2(oJson:OPERACAO, aCadFor, aBcoFor)

	End Sequence

	ErrorBlock(oErro)
	
	
	
	 
	 /*
	 
	lMsErroAuto	:= .F.
	MSExecAuto({|x,y,z| Fina050(x,y,z)},aTitulo,3,3) 

	If lMsErroAuto

		cAutoLog	:= alltrim(NOMEAUTOLOG())

		cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
		cMemo := STRTRAN(cMemo,"'","")

		//| Apaga arquivo de Log
		Ferase(cAutoLog)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Le Log da Execauto e retorna mensagem amigavel ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet[1]	:= .F.
		aRet[2] := U_CPXERRO(cMemo)
		IF EMPTY(aRet[2])
			aRet[2]	:= alltrim(cMemo)
		ENDIF
	ELSE
		aRet[1]	:= .T.		
	EndIf
	*/

ELSE
	aRet[2] := "Json Invalido"
ENDIF

IF !EMPTY(cMsgErro)
	aRet[2] := cMsgErro
ENDIF


Return(aRet)

