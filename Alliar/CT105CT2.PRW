#INCLUDE "protheus.ch"



/*/{Protheus.doc} CT105CT2
Habilita gravação de novos campo sno CT2. 
ATENÇÃO: Somente contempla campos com inicio CT2_X e CTK_X
Ponto de entrada utilizadao para contornar falha existente na versão 12.1.7
@author Augusto Ribeiro | www.compila.com.br
@since 08/08/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CT105CT2()
Local nI, nPos
Local nCpoCT2	:= CT2->(FCOUNT())
Local nCpoCTK	:= CTK->(FCOUNT())
Local aCpoCTK	:= {}

Local lCT2X		:= GetMV("AL_CT2COMP",.F.,.F.)


/*------------------------------------------------------ Augusto Ribeiro | 08/08/2017 - 6:54:46 PM
	Habilita gravação de novos campo sno CT2. 
	ATENÇÃO: Somente contempla campos com inicio CT2_X e CTK_X
------------------------------------------------------------------------------------------*/
IF lCT2X
	FOR nI := 1 to nCpoCTK
		cNomeCpo	:= ALLTRIM(CTK->(FIELDNAME(nI)))
		IF LEFT(cNomeCpo,5)=="CTK_X"
			aadd(aCpoCTK, cNomeCpo)
		ENDIF
		
	
	NEXT nI
	
	/*------------------------------------------------------ Augusto Ribeiro | 08/08/2017 - 6:17:01 PM
		Grava dados complementares no CT2 de campos customizados.
	------------------------------------------------------------------------------------------*/
	IF LEN(aCpoCTK) > 0	
		FOR nI := 1 to nCpoCT2
			cNomeCpo	:= ALLTRIM(CT2->(FIELDNAME(nI)))			
			IF LEFT(cNomeCpo,5)=="CT2_X" .and. EMPTY( CT2->(FIELDGET(FIELDPOS(cNomeCpo))) )
				nPos	:= ASCAN(aCpoCTK, "CTK_"+RIGHT(cNomeCpo,LEN(cNomeCpo)-4)) 
				
				IF nPos > 0
					CT2->(FIELDPUT(nI, CTK->(FIELDGET(FIELDPOS(aCpoCTK[nPos]))) ))
				endif
			ENDIF
		NEXT nI		
	ENDIF
ENDIF
	

Return()