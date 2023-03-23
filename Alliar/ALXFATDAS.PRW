#Include 'Protheus.ch'




/*/{Protheus.doc} alPerido
Retorna Array com periodos para Dashboard do Faturamento
Utilizado nas querys no Simple Export
@author Augusto Ribeiro | www.compila.com.br
@since 27/06/2017
@version version
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/


/*/{Protheus.doc} alPerido
Retorna Array com periodos para Dashboard do Faturamento
Utilizado nas querys no Simple Export
@author Augusto Ribeiro | www.compila.com.br
@since 27/06/2017
@version undefined
@param cPeriodo, DIARIO / SEMANAL / MENSAL
@param dDtIni, Data Inicial (Tambem aceita tipo "C" no Formato YYYYMMDD)
@param dDtFim, Data Final (Tambem aceita tipo "C" no Formato YYYYMMDD)
@param cTpRet, "C"(YYYYMMDD) ou "D"
@return aRet, {{dIniAtual, dFimAtual},{dIniAnt, dIniAnt}}
@example,
(examples)
@see (links_or_references)
/*/
User Function alPerido(cPeriodo, dDtIni, dDtFim)
Local aRet
Local nDias	
//Default cTpRet	:= "C"

//dDataBase	:= STOD("20170401")
/*------------------------------------------------------ Augusto Ribeiro | 30/06/2017 - 6:35:32 PM
	Parametro que altera a database  - UTILIZADO SOMENTE PARA TESTES
------------------------------------------------------------------------------------------*/

IF !EMPTY(dDtIni) .AND. !EMPTY(dDtFim)

	IF VALTYPE(dDtIni) == "C"
		dDtIni := STOD(dDtIni)
	ENDIF
	
	IF VALTYPE(dDtFim) == "C"
		dDtFim := STOD(dDtFim)
	ENDIF	
	
 	nDias	:= dDtFim-dDtIni

	aAtual	:= {DTOS(dDtIni), DTOS(dDtFim)}
	aAnter	:= {DTOS((dDtIni-1)-nDias), DTOS(dDtIni-1)}	
	
ELSEIF !EMPTY(cPeriodo)
	IF cPeriodo == "DIARIO"
	
		aAtual	:= {DTOS(dDataBase), DTOS(dDataBase)}
		aAnter	:= {DTOS(dDataBase-1), DTOS(dDataBase-1)}	
	
	ELSEIF cPeriodo == "SEMANAL"
	
		aAtual	:= {DTOS(dDataBase-6), DTOS(dDataBase)}
		aAnter	:= {DTOS(dDataBase-14), DTOS(dDataBase-7)}	
	ELSEIF cPeriodo == "MENSAL"		
			
		aAtual	:= {DTOS(dDataBase-30), DTOS(dDataBase)}
		aAnter	:= {DTOS(dDataBase-61), DTOS(dDataBase-31)}	
	ENDIF
ENDIF


aRet	:= {aAtual,aAnter}

Return(aRet)



/*/{Protheus.doc} alFilMar
Retornar filiais e marcas de acordo com o array passado.
Caso vazio, retornará todas as filiais
IMPORTANTE: Caso informado uma filial de uma marca também informada no parametro aCodMarca,
somente serão listadas as filiais existens no aCodFil.
Caso seja informada uma marca e uma filial pertencente a outra marca, serão retornarda todas filiais da marca
presente no parametro aCodMarca e a filial especificada no  aCodFil

@author Augusto Ribeiro | www.compila.com.br
@since 28/06/2017
@version version
@param aCodMarca, Array com código das marcas
@param aCodFil, Array com filiais
@return aRet, {cFilial}
@example
(examples)
@see (links_or_references)
/*/
User Function alFilMar(aCodMarca, aCodFil)
Local aRet			:= {}
Local aAreaSM0, nI
Local lNoFilter		:= .F.
Local aNoFil		:= {}
Local cNoFil	:= GetMV("ES_NOFILDA",.F.,"")
Local nRecSM0	:= 0

Default aCodMarca	:= {}
Default aCodFil		:= {}


/*------------------------------------------------------ Augusto Ribeiro | 17/07/2017 - 7:30:25 PM
	Filiais a serem desconsideradas no Filtro do DashBoard
------------------------------------------------------------------------------------------*/
IF !EMPTY(cNoFil)
	aNoFil	:= StrTokArr( cNoFil, "/" )
ENDIF


IF EMPTY(aCodMarca) .AND. EMPTY(aCodFil)
	lNoFilter	:= .T.
	
ELSE

	/*------------------------------------------------------ Augusto Ribeiro | 28/06/2017 - 4:06:52 PM
		Remove marcas que possuem filial especificada
	------------------------------------------------------------------------------------------*/
	FOR nI := 1 TO LEN(aCodFil)
	
		IF LEN(aCodMarca) > 0
			
			nPosAux	:= ASCAN(aCodMarca, LEFT(aCodFil[nI],3))
			IF nPosAux > 0
				ADEL(aCodMarca, nPosAux)
				ASIZE(aCodMarca, LEN(aCodMarca)-1)
			ENDIF
			
		ENDIF		
	NEXT nI
ENDIF


DBSELECTAREA("SM0")
aAreaSM0	:= GetArea("SM0")
nRecSM0		:= SM0->(RECNO())
SM0->(DBGOTOP())		
WHILE SM0->(!EOF())

	/*------------------------------------------------------ Augusto Ribeiro | 17/07/2017 - 7:33:04 PM
		Verifica se a Filial deve ser desconsiderada
	------------------------------------------------------------------------------------------*/
	IF IIF(!EMPTY(aNoFil), ASCAN(aNoFil, ALLTRIM(SM0->M0_CODFIL)) <= 0, .T.)

		IF lNoFilter
			AADD(aRet, SM0->M0_CODFIL)
		ELSE
		
			IF IIF(LEN(aCodMarca) > 0, ASCAN(aCodMarca, LEFT(SM0->M0_CODFIL,3)) > 0,.F.)
				AADD(aRet, SM0->M0_CODFIL)
			ENDIF
		
			IF IIF(LEN(aCodFil) > 0, ASCAN(aCodFil, ALLTRIM(SM0->M0_CODFIL)) > 0,.F.)
				AADD(aRet, SM0->M0_CODFIL)
			ENDIF
		ENDIF
	ENDIF


	SM0->(DBSKIP())	
ENDDO

SM0->(DBGOTO(nRecSM0))
RESTAREA(aAreaSM0)
	
Return(aRet)




