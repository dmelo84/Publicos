#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function WSRSIGAGCT()
Return



WSRESTFUL CONTRATO_SIGAGCT DESCRIPTION "Inclusao e cadastro de contrato"


WSMETHOD POST DESCRIPTION "Inclusao / Alteracao de Contrato" WSSYNTAX "/CONTRATO_SIGAGCT"

END WSRESTFUL




WSMETHOD POST  WSSERVICE CONTRATO_SIGAGCT
Local cAutBasic		:= ""
Local cJsonRet		:= ""
Local lRet			:= .f.
Local cBody			:= ""
Local aRetAux

::SetContentType("application/json")

/*------------------------------------------------------ Augusto Ribeiro | 18/01/2018 - 9:36:31 PM
	Bloco de Autorização 
------------------------------------------------------------------------------------------*/

cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46|
	
CONOUT("CONTRATO_SIGAGCT "+DTOC(DDATABASE)+" "+TIME())
IF U_CPxAuWSR(cAutBasic)

	cBody := ::GetContent()
	
	IF cBody == Nil
		cBody := ""
	EndIf
	
	IF !EMPTY(cBody)
	
	
		aRetAux	:= U_WSRUPGCT(cBody)
		IF aRetAux[1]
			::SetResponse('{"code":200,"status":"success"}')
			lRet	:= .t.			
		ELSE
			SetRestFault(401, "Falha "+aRetAux[2])
		ENDIF

	ENDIF
	

ELSE
	SetRestFault(401, "Authentication Required")
ENDIF

Return(lRet)






/*/{Protheus.doc} WSRUPGCT
Inclusão / Alteracao de contrato
@author Augusto Ribeiro | www.compila.com.br
@since 17/01/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function WSRUPGCT(cJson)
Local aRet	:= {.f.,""}
Local cJson
Local cMsgRet := ""
Local aFornec, aPlan
Local _cCodEmp, _cCodFil, _cFilNew
Local nOperMVC	:= 3
Local oModel, oCN9, oCNC, oCNA
Local nI, nY, oJson, aDadosObj

IF !EMPTY(cJson)	
	
	IF FWJsonDeserialize(cJson,@oJson)
		IF AttIsMemberOf(oJson, "FORNECEDOR")
			aFornec	:= oJson:FORNECEDOR
		ENDIF
		
		IF AttIsMemberOf(oJson, "PLANILHA")
			aPlan	:= oJson:PLANILHA
		ENDIF
		
		
		
		IF !EMPTY(aFornec) .AND. !EMPTY(aPlan)
		

			/*---------------------------------------
				Realiza a TROCA DA FILIAL CORRENTE 
			-----------------------------------------*/
			_cCodEmp 	:= SM0->M0_CODIGO
			_cCodFil	:= SM0->M0_CODFIL
			_cFilNew	:= oJson:CN9_FILIAL //| CODIGO DA FILIAL DE DESTINO 
			
			IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
				CFILANT := _cFilNew
				opensm0(_cCodEmp+CFILANT)
			ENDIF		
					
					
					
			IF !EMPTY(ALLTRIM(oJson:CN9_NUMERO))
				DBSELECTAREA("CN9")
				CN9->(DBSETORDER(1)) //| 
				IF CN9->(DBSEEK(xfilial("CN9")+oJson:CN9_NUMERO)) 
					nOperMVC	:= 4						
				ENDIF
			ENDIF
		
			oModel := FWLoadModel("CNTA300")
			oModel:SetOperation(nOperMVC)
			oModel:Activate()
			 
			
			oCN9	:= oModel:GetModel("CN9MASTER") // Cabec
			oCNC	:= oModel:GetModel("CNCDETAIL") // Fornecedor
			oCNA	:= oModel:GetModel("CNADETAIL")	// Planilha			
		
			aDadosObj	:= ClassDataArr(oJson)
			
			/*--------------------------
				CABECALHO
			---------------------------*/			
			FOR nI := 1 TO Len(aDadosObj)
				IF LEFT(ALLTRIM(aDadosObj[nI,1]),3) == "CN9"
					IF !EMPTY(aDadosObj[nI,2])
						oCN9:SetValue(aDadosObj[nI,1], ConvDado(aDadosObj[nI,1],aDadosObj[nI,2]))
					ENDIF
				ENDIF	
			
			NEXT nI 
			oCN9:SetValue("CN9_SITUAC","05")
			
			/*--------------------------
				FORNECEDORES
			---------------------------*/
			FOR nY := 1 TO Len(oJson:FORNECEDOR)
				aDadosObj	:= ClassDataArr(oJson:FORNECEDOR[nY])
				
				oCNC:AddLine()
				FOR nI := 1 TO Len(aDadosObj)
					IF LEFT(ALLTRIM(aDadosObj[nI,1]),3) == "CNC"
						IF !EMPTY(aDadosObj[nI,2])
							oCNC:SetValue(aDadosObj[nI,1], ConvDado(aDadosObj[nI,1],aDadosObj[nI,2]))
						ENDIF
					ENDIF				
				NEXT nI 
			
			NEXT nY		
			
			/*--------------------------
				PLANILHA
			---------------------------*/
			FOR nY := 1 TO Len(oJson:PLANILHA)
				aDadosObj	:= ClassDataArr(oJson:PLANILHA[nY])
				
				oCNA:AddLine()
				FOR nI := 1 TO Len(aDadosObj)
					IF LEFT(ALLTRIM(aDadosObj[nI,1]),3) == "CNA"
						IF !EMPTY(aDadosObj[nI,2])
							oCNA:SetValue(aDadosObj[nI,1], ConvDado(aDadosObj[nI,1],aDadosObj[nI,2]))
						ENDIF
					ENDIF				
				NEXT nI 
			
			NEXT nY					
			
			
			FWFormCommit(oModel)
			
			
			
			/*---------------------------------------
				Restaura FILIAL  
			-----------------------------------------*/
			IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
				CFILANT := _cCodFil
				opensm0(_cCodEmp+CFILANT)			 			
			ENDIF  			
		
		ELSE
			cMsgRet:= "Json incompleto, verifique os parametros passados. [WSRUPGCT]"
		ENDIF					
		
	ELSE
		cMsgRet:= "Não foi poossível desserializar o objeto. [WSRUPGCT]"
	ENDIF
	
ELSE
	cMsgRet:= "Parâmetro Vazio, não contém dados de Json. [WSRUPGCT]"
ENDIF
	
	
IF EMPTY(cMsgRet)
	aRet[1] := .T.
ELSE
	aRet[2] := cMsgRet
ENDIF

Return(aRet)





/*/{Protheus.doc} X3TIPO
Retorna Tipo do SX3
@author Augusto Ribeiro | www.compila.com.br
@since 18/01/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function X3TIPO(cCampo)
Local cRet	:= ""


/*--------------------------
	Array com Cabecalho e Tipo de Dados
---------------------------*/
DBSELECTAREA("SX3")
SX3->(DBSETORDER(2)) //|CAMPO
aCabecX3	:= {}
IF SX3->(DBSEEK(ALLTRIM(UPPER(cCampo))))
	cRet	:= SX3->(FIELDGET(FIELDPOS("X3_TIPO")))
ENDIF

Return(cRet)


/*/{Protheus.doc} ConvDado
Realiza conversao do dado de acordo com o Campo e valor passado
@author Augusto Ribeiro | www.compila.com.br
@since 18/01/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ConvDado(cCampo, xValor)
Local xRet, cTipo


cTipo	:= X3TIPO(cCampo)
IF cTipo == "C" .OR. cTipo == "M" 
	xRet	:= ALLTRIM(xValor)
ELSEIF cTipo == "D"
	xRet	:= STOD(xValor)
ELSEIF cTipo == "N"
	xRet	:= VAL(xValor)
ENDIF


Return(xRet)


