

/*/{Protheus.doc} TK271SQL
Ponto de entrada para Filtro do Browser de ocorrencias
@author Augusto Ribeiro | www.compila.com.br
@since 10/04/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function TK271SQL()
Local cRet	:= ""
//Local aParam	:= Paramixb
Local nI, nTotFil, aDadoUsr
Local cFilSAC	:= ""


IF GETMV("AL_FILMSAC",.F.,.T.)
	
	PswOrder(1)//|E-mail|
	If PswSeek(__CUSERID, .T. )
		aDadoUsr		:= PswRet( 2, .F. )
	
		nTotFil	:= len(aDadoUsr[1,6])
		
		IF nTotFil > 0
			IF nTotFil == 1
				IF alltrim(aDadoUsr[1,6,1]) <> "@@@@" //| Acesso a todas as filiais|
					cFilSAC	:= "'"+substr(aDadoUsr[1,6,1],3,11)+"'"			
				ENDIF
			ELSE
				FOR nI := 1 to nTotFil
					IF !EMPTY(cFilSAC)
						cFilSAC	+= ","
					ENDIF
					cFilSAC	+= "'"+substr(aDadoUsr[1,6,nI],3,11)+"'"
				NEXT 
			ENDIF
			IF !EMPTY(cFilSAC)
				cRet	:= "UC_XCODUNI IN ("+cFilSAC+")"
			ENDIF
		ENDIF
	ELSE
		CONOUT("[TK271SQL] Usuario nao localizado")
	ENDIF
ENDIF

Return(cRet)