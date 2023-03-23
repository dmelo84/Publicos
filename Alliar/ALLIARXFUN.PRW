#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*------------------------------------------------------------------------------------------
		
		FUNÇÕES GENÉRICAS UTILIZADAS NA ALLIAR
		
------------------------------------------------------------------------------------------*/


/*/{Protheus.doc} alVldCEP
Realiza validação do CEP no cadastro de cliente
através de faixa cadastrada no CC2
@author Augusto Ribeiro | www.compila.com.br
@since 17/12/2018
@version undefined
@param nDig, 0=Valida Campo CEP, 1= Valida A1_COD_MUN
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function alVldCEP(cCpoVld)
Local aArea := GetArea()
Local lRet := .T.

Default cCpoVld	:= "A1_CEP"
//Default  nDig := 0


/*------------------------------------------------------
	Parametro para verificar se validação esta ativa
--------------------------------------------------------*/
IF GETMV("AL_VLDCEP",.F.,.F.) //| Valida CEP por Faixa na CC2 no cadastro de cliente |
	
	cCpoVld	:= upper(ALLTRIM(cCpoVld))
	
	IF INCLUI .OR. ALTERA 
	
		//| Somente executa validaçao caso CEP este preenchido|
		IF !EMPTY(M->A1_CEP) 
		
		
			dbSelectArea("CC2")
			CC2->(dbSetOrder(1))  // CC2_FILIAL+CC2_EST+CC2_CODMUN
			
			If	CC2->(DBSeek(xFilial("CC2")+ M->A1_EST + M->A1_COD_MUN ))
			  
		  
			  If  !Empty(CC2->CC2_XCPINI) .AND.  !Empty(CC2->CC2_XCPFIM)
			  
			  	
			  		IF !(M->A1_CEP >= CC2->CC2_XCPINI .AND. M->A1_CEP <= CC2->CC2_XCPFIM)
			  			
			  			lRet		:= .F.
			  			IF cCpoVld == "A1_COD_MUN"
			  				M->A1_CEP	:= CRIAVAR("A1_CEP",.F.)
			  				lRet		:= .F.			  								  		
				  		ENDIF
				  		Help( NIL, NIL, "CEP inválido para o município "+alltrim(M->A1_MUN)+"-"+M->A1_EST+". Permitido entre "+ CC2->CC2_XCPINI + " e " + CC2->CC2_XCPFIM +"." ,;
						 	  NIL, "Faixa de CEP", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Corrija o CEP, respeintando Estado e codigo do municipio"})				  				  		
			  		ENDIF			  	
			  	ENDIF			  
			  ENDIF		
		ENDIF
	ENDIF
ELSE
	lRet	:= .T.
ENDIF

//| ------> Augusto Ribeiro - 02/02/2021
//| Atribui na variavel private criada no fonte FSLIBPLE para contornar erro do padrão do Protheus.
//| Onde nao lMsErroAuto esta retornando .F. mesmo falhando a validação do PE MA030TOK
IF TYPE("_aAlErro") == "A"
	IF LEN(_aAlErro) == 1
		_aAlErro[1]	:= !(lRet)
	ENDIF
ENDIF

RestArea(aArea)

Return(lRet)
