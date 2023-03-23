#include "Protheus.ch"


/*/{Protheus.doc} FA070BCO
O Ponto de Entrada:FA070BCO faz validações adicionais de banco
@author Augusto Ribeiro | www.compila.com.br
@since 05/06/2017
@version version
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function FA070BCO()
Local lRet	:= .T.
Local lBcoFav	:= Getmv("ES_BCOFAV",.F.,.T.)
Local aAreaSA6 := SA6->(GetArea())
Local cChvSA6, cVarBco
Local lAchou	:= .F.

IF lBcoFav .AND. Funname() $ "FINA740|FINA070" 


	cVarBco	:= UPPER(ALLTRIM(READVAR()))
	IF VALTYPE(cVarBco) <> "C"
		cVarBco	:= ""
	ENDIF

	/*------------------------------------------------------ Augusto Ribeiro | 05/06/2017 - 7:01:32 PM
		Somente gatilha no campo banco
	------------------------------------------------------------------------------------------*/
	IF (cVarBco == "CBANCO" .and. TYPE("CBANCO") == "C") .OR.;
		(cVarBco == "CBAN070" .and. TYPE("CBAN070") == "C") .OR.;
		(cVarBco == "CBANCO740" .and. TYPE("CBANCO740") == "C") .OR.;
		(cVarBco == "CBANCOLT" .and. TYPE("CBANCOLT") == "C")
		
		cBanco	:= &cVarBco
	
		/*------------------------------------------------------ Augusto Ribeiro | 05/06/2017 - 7:25:17 PM
			Somente executa quando chamada NÃO for originada pelo F3
		------------------------------------------------------------------------------------------*/
		IF TYPE("ACPORET") == "U"
			DBSELECTAREA("SA6")
			SA6->(DBSETORDER(1)) //| 
			
			cChvSA6	:= xfilial("SA6")+cBanco
			IF SA6->(DBSEEK(cChvSA6)) 
				
				WHILE SA6->(!EOF()) .and. cChvSA6 == SA6->(A6_FILIAL+A6_COD)
				
					IF SA6->A6_XBANFVR == "1"
						cBanco		:= SA6->A6_COD 
						cAgencia	:= SA6->A6_AGENCIA
						cConta		:= SA6->A6_NUMCON
						
						lAchou		:= .T.
							
						EXIT
					ENDIF
					
					SA6->(DBSKIP()) 
				ENDDO
				
				
				IF lAchou				
					IF cVarBco == "CBAN070"
						cBan070	:= cBanco 
						cAge070	:= cAgencia
						cCta070	:= cConta
					ELSEIF cVarBco == "CBANCO740"
						cBanco740	:= cBanco 
						cAgenc740	:= cAgencia
						cConta740	:= cConta		
					ELSEIF cVarBco == "CBANCOLT"
						cBancoLT	:= cBanco 
						cAgenciaLT	:= cAgencia
						cConta740	:= cConta						
					ENDIF
				ENDIF
				
			ENDIF
		ENDIF
	ENDIF
ENDIF


RestArea(aAreaSA6)
Return(lRet)