#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#INCLUDE "TBICONN.CH" 

User Function WSR_CONTAS_PAGAR()
Return



WSRESTFUL CONTAS_PAGAR DESCRIPTION "Serviço REST para interação com o Contas a Pagar"

WSMETHOD POST DESCRIPTION "Insere Titulo Contas a Pagar" WSSYNTAX "/CONTAS_PAGAR || /CONTAS_PAGAR/{}"

END WSRESTFUL


WSMETHOD POST  WSSERVICE CONTAS_PAGAR
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
		aRetAux	:= U_WSRCPADD(cBody)
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
User Function WSRCPADD(cJson)
Local aRet	:= {.f.,""}
Local oJson, cAutoLog, cMemo
lOCAL aTitulo	:= {}
Local cPrefixo	:= "ADT"
Local cNumTit	:= "" 
Local cTipo		:= "PA "
Local cFornece	:= ""
Local cLoja		:= "" 
Local cFilWSR	:= ""
Local dEmissao		:= ctod("  /  /  ")
Local nValor		:= 0
lOCAL _cCodEmp, _cCodFil, _cFilNew
Local cLog 			:= "" 
Local lEBlock		:= .F.
Local oErro 		:= ErrorBlock({|e| DisarmTransaction() ,lEBlock := .T., cLog := IIF(VALTYPE(e:Description)=="C", e:Description,"[WSRCPADD] Falha da rotina WSRCPADD")})
Local cBanco		:= ""
Local cAg			:= ""
Local cConta		:= ""

IF FWJsonDeserialize(cJson,@oJson)
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 01/02/2018 - 1:50:25 PM
		Estou utilizando a atribuiçõa campo a campo pois nesta versão da BUIL/LIB  a função
		ClassDataArr( < oObj >, [ lParent ] ) não funciona de maneira corrata.
	------------------------------------------------------------------------------------------*/
	IF AttIsMemberOf(oJson , "E2_FILIAL")
		cFilWSR	:= oJson:E2_FILIAL
		AADD(aTitulo,{"E2_FILIAL" 		,cFilWSR		, Nil})
	ENDIF	
	
	
	RESET ENVIRONMENT
	
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL cFilWSR		
	
	
	BEGIN SEQUENCE	
	
	IF !EMPTY(cFilWSR)
		
		

		
		
		AADD(aTitulo,{"E2_PREFIXO" 		,cPrefixo			, Nil})	
		
		IF AttIsMemberOf(oJson , "E2_NUM")
			cNumTit	:= PADL(ALLTRIM(oJson:E2_NUM),TAMSX3("E2_NUM")[1],"0")
			AADD(aTitulo,{"E2_NUM" 		,	cNumTit	, Nil})
			AADD(aTitulo,{"E2_XIDFLG" 	,ALLTRIM(oJson:E2_NUM)	, Nil}) //| ### CAMPO NOVO |
		ENDIF			
		
		AADD(aTitulo,{"E2_TIPO"    		,cTipo			, Nil})	
		
		IF AttIsMemberOf(oJson , "AUTBANCO")	
			cBanco	:= alltrim(oJson:AUTBANCO)
			AADD(aTitulo,{"AUTBANCO"    	,cBanco	, Nil})	
		ENDIF	
		IF AttIsMemberOf(oJson , "AUTAGENCIA")
			cAg		:= PADR(ALLTRIM(oJson:AUTAGENCIA),TAMSX3("A6_AGENCIA")[1])
			AADD(aTitulo,{"AUTAGENCIA"    	,cAg 			, Nil})	
		ENDIF	
		IF AttIsMemberOf(oJson , "AUTCONTA")
			cConta	:= PADR(ALLTRIM(oJson:AUTCONTA),TAMSX3("A6_NUMCON")[1])
			AADD(aTitulo,{"AUTCONTA"    	,cConta			, Nil})
		ENDIF	
		
		AADD(aTitulo,{"E2_NATUREZ"    	,"21010009"		, Nil})		
		
		IF AttIsMemberOf(oJson , "E2_FORNECE")	
			AADD(aTitulo,{"E2_FORNECE"		,oJson:E2_FORNECE			, Nil})
			cFornece	:= oJson:E2_FORNECE
		ENDIF	
		IF AttIsMemberOf(oJson , "E2_LOJA")
			AADD(aTitulo,{"E2_LOJA"    		,oJson:E2_LOJA			, Nil})
			cLoja		:= 	oJson:E2_LOJA
		ENDIF	
	
		
		
		IF AttIsMemberOf(oJson , "E2_VENCTO")
			dEmissao	:= STOD(oJson:E2_VENCTO)
			AADD(aTitulo,{"E2_EMISSAO"    	,dEmissao			, Nil})
			AADD(aTitulo,{"E2_VENCTO"    	,dEmissao			, Nil})			
		ENDIF	
		IF AttIsMemberOf(oJson , "E2_VALOR")
			nValor		:= val(oJson:E2_VALOR)
			AADD(aTitulo,{"E2_VALOR"    	, nValor			, Nil})	
		ENDIF
		IF AttIsMemberOf(oJson , "E2_CCUSTO")
			AADD(aTitulo,{"E2_CCUSTO"    	,oJson:E2_CCUSTO	, Nil})	
		ENDIF		
		IF AttIsMemberOf(oJson , "E2_HIST")
			AADD(aTitulo,{"E2_HIST"    	,oJson:E2_HIST			, Nil})	
		ENDIF	
		

		
		cParc	:= CRIAVAR("E2_PARCELA")
		DBSELECTAREA("SE2")
		SE2->(DBSETORDER(1)) //| 
		IF SE2->(!DBSEEK(cFilWSR+cPrefixo+cNumTit+cParc+cTipo+cFornece+cLoja)) 
			
			/*---------------------------------------
				Realiza a TROCA DA FILIAL CORRENTE 
			-----------------------------------------*/
			_cCodEmp 	:= SM0->M0_CODIGO
			_cCodFil	:= SM0->M0_CODFIL
			_cFilNew	:= cFilWSR //| CODIGO DA FILIAL DE DESTINO 
			
			IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
				CFILANT := _cFilNew
				opensm0(_cCodEmp+CFILANT)
			ENDIF
			
			DBSELECTAREA("SA6")
			SA6->(DBSETORDER(1)) //|
			SA6->(DBGOTOP())				
			IF SA6->(DBSEEK(PADR(LEFT(cFilWSR,5),TAMSX3("A6_FILIAL")[1])+cBanco+cAg+cConta ))
				CONOUT("WSRCPADD DBSEEK",SA6->A6_NUMCON)
			ENDIF
			
			SE2->(DBSEEK(cFilWSR))			
			
							
			BEGIN TRANSACTION  
			
			lMsErroAuto	:= .F.
			MSExecAuto({|x,y,z| Fina050(x,y,z)},aTitulo,3,3) 
			
			If lMsErroAuto .or. lEBlock
				DISARMTRANSACTION()
		
				cAutoLog	:= alltrim(NOMEAUTOLOG())
		
				cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
				cMemo := STRTRAN(cMemo,"'","")
				CONOUT("WSRCPADD",cMemo)
		
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
			
			
			END TRANSACTION
			
			/*---------------------------------------
				Restaura FILIAL  
			-----------------------------------------*/
			IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
				CFILANT := _cCodFil
				opensm0(_cCodEmp+CFILANT)			 			
			ENDIF
		
		ELSEIF dEmissao == SE2->E2_EMISSAO .and. nValor == SE2->E2_VALOR .AND. ALLTRIM(SE2->E2_XIDFLG) == ALLTRIM(oJson:E2_NUM)
			aRet[1] := .T.
		ELSE    
			aRet[2] := "Titulo já existente no Financeiro."
		ENDIF			
		
	ELSE 
		aRet[2] := "Filial não informada."
	ENDIF
	
	END SEQUENCE
	
ELSE
	aRet[2] := "Json Invalido"
ENDIF

ErrorBlock(oErro)

IF lEBlock
	aRet[1]	:= .F.
	aRet[2]	:= cLog
ENDIF

Return(aRet)

