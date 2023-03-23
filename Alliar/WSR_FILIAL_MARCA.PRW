#Include 'Protheus.ch'
#Include 'RestFul.CH'


User Function WSR_FILIAL_MARCA()
Return


WSRESTFUL FILIAL_MARCA DESCRIPTION "Serviço REST retorna Filiais das Marcas de empresas"


WSMETHOD POST DESCRIPTION "Retorna todas as marcas do grupo de empresa " WSSYNTAX "/FILIAL_MARCA{[CODMARCA1,CODMARCA2]}"


END WSRESTFUL


/*
{
    "MARCAS":["002","014"],
    "INVERSO":true
}

*/

/*/{Protheus.doc} POST
JSON
{
    "MARCAS":["002","014"],
    "INVERTE":false
}

INVERTE = Inverter Filtro

@author aribeiro
@since 28/06/2017
@version undefined
@example
(examples)
@see (links_or_references)
/*/
WSMETHOD POST  WSSERVICE FILIAL_MARCA
Local lRet		:= .f.
Local cJson 	:= ""
Local cBody		:= ""
Local lFilMarca	:= .F.
Local nI		:= 0
Local lInverso	:= .F.
 
Private oWSJson

::SetContentType("application/json")

cBody := ::GetContent()
IF !EMPTY(cBody)
	IF FWJsonDeserialize(cBody,@oWSJson)
	
		IF TYPE("oWSJson:MARCAS") == "A"
			IF !EMPTY(oWSJson:MARCAS)
				lFilMarca	:= .T.
			ENDIF
		ENDIF
		
		IF TYPE("oWSJson:INVERTE") == "L"
			lInverso	:= oWSJson:INVERTE
		ENDIF
	ELSE
	   SetRestFault(402, "Invalid Json")
	   RETURN(lRet)
	ENDIF
		
ENDIF
		

cJson += '{"FILIAIS":['		

DBSELECTAREA("SM0")
aAreaSM0	:= GetArea("SM0")
SM0->(DBGOTOP())		
WHILE SM0->(!EOF())
			
	/*------------------------------------------------------ Augusto Ribeiro | 27/06/2017 - 5:30:59 PM
		Realiza o filtro de marca
	------------------------------------------------------------------------------------------*/
	IF lFilMarca
		IF (!lInverso .and. ASCAN(oWSJson:MARCAS, LEFT(SM0->M0_CODFIL,3)) <= 0) .or.;
			(lInverso .and. ASCAN(oWSJson:MARCAS, LEFT(SM0->M0_CODFIL,3)) > 0)
			SM0->(DBSKIP()) 
			LOOP
		ENDIF
	ENDIF
	
	if nI > 0
		cJson += ','
	ENDIF
	nI++
	
	cJson += '{'
	cJson += U_cpxToJson("COD", SM0->M0_CODFIL )+","
	cJson += U_cpxToJson("DESC", SM0->M0_FILIAL)			
	cJson += '}'			

	SM0->(DBSKIP())			

ENDDO

cJson += ']}'

RESTAREA(aAreaSM0)



//SetRestFault(200, "TUDO OK")
::SetResponse(cJson)
lRet	:= .T.

Return(.T.)
