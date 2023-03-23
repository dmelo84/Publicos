
/*/{Protheus.doc} FINBENEF
Este Ponto  permite ao  cliente fazer a alteração no campo beneficiario, 
no momento da transferência bancaria, caso o mesmo não queria pegar do cadastro de empresa 
como faz hoje no padrão.
@author Augusto Ribeiro | www.compila.com.br
@since 05/06/2017
@version version
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function FINBENEF()
Local lRet	:= .T.
Local lBcoFav	:= Getmv("ES_BCOFAV",.F.,.T.)
Local aAreaSA6 := SA6->(GetArea())
Local cChvSA6, cVarBco
Local lAchou	:= .F.

IF lBcoFav .AND. Funname() $ "FINA090|FINA750|FINA110|FINA080|FINA740|FINA070" 


	cVarBco	:= UPPER(ALLTRIM(READVAR()))
	IF VALTYPE(cVarBco) <> "C"
		cVarBco	:= ""
	ENDIF

	/*------------------------------------------------------ Augusto Ribeiro | 05/06/2017 - 7:01:32 PM
		Somente gatilha no campo banco
	------------------------------------------------------------------------------------------*/
	IF (cVarBco == "CBANCO" .and. TYPE("CBANCO") == "C") .OR.;
		(cVarBco == "CBCO090" .and. TYPE("CBCO090") == "C") .OR.;
		(cVarBco == "CBCO110" .and. TYPE("CBCO110") == "C")
		
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
					IF cVarBco == "CBCO090"
						cBco090	:= cBanco 
						cAge090	:= cAgencia
						cCta090	:= cConta
					ELSEIF cVarBco == "CBCO110"
						cBco110	:= cBanco 
						cAge110	:= cAgencia
						cCta110	:= cConta					
					ENDIF
				
				ENDIF
					
			ENDIF
			
			
		ENDIF
	ENDIF
ENDIF


RestArea(aAreaSA6)
Return(lRet)

/*------------------------------------------------------------------------------------------------------------
@Autor   : Francisco Lopes Junior
@Empresa : Compila
@Funcao  : Co_VerBcoR()
@Data    : 22/03/2017
@Objetivo: Validacao para aceitar um unico Banco Favorito CR
------------------------------------------------------------------------------------------------------------*/

User Function Co_VerRBco()   																	// funcao para aceitar unico banco favorito

Local _lRet 		:= .T.
Local _aAreaSA6		:= SA6->(GetArea())
Local _cRecno 		:= Recno()
Local _cFilSA6		:= fwxFilial("SA6")
Local _cBanco		:= ""
Local _cBcoFvR		:= ""

_cBanco := m->A6_COD

SA6->(DBSETORDER(1))
SA6->(Dbgotop())

If x3Usado("A6_XBANFVR") 

	If M->A6_XBANFVR == '1'
		IF SA6->(DBSEEK(_cFilSA6 + _cBanco))
			While !SA6->(Eof()) .and. SA6->A6_FILIAL == _cFilSA6  .and. SA6->A6_COD == _cBanco
				if SA6->A6_XBANFVR == '1' .and. Recno() <> _cRecno
				     Help(" ",1,"FINVERBCOR")
					_lRet := .F.
					Exit
				Endif
				SA6->(DbSkip())
			Enddo
		Endif
	Endif 
	
Endif

RestArea(_aAreaSA6)

Return _lRet