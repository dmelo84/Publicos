


/*/{Protheus.doc} TMKLINOK
Realiza validação da a exclusao da Linha. Utilizado este ponto de entrada pois nao existe um especifico para exclusao
@author Augusto Ribeiro | www.compila.com.br
@since 03/04/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function TMKLINOK()
Local lRet	:= .t.
Local nPosAli, nPosREC, nRecSUD

IF aCols[n,len(aCols[n])]
	 
	nPosAli	:= Ascan(aHeader, {|x|AllTrim(x[2]) == "UD_ALI_WT"})
	nPosREC	:= Ascan(aHeader, {|x|AllTrim(x[2]) == "UD_REC_WT"})
	IF nPosAli > 0 .AND. nPosREC > 0
		IF UPPER(ALLTRIM(aCols[n,nPosAli])) == "SUD"
			nRecSUD	:= aCols[n,nPosREC]
			IF nRecSUD > 0
				DBSELECTAREA("SUD")
				SUD->(DBGOTO(nRecSUD))
				IF !EMPTY(SUD->UD_XIDFLUI) .OR.  SUD->UD_STATUS == "2" //| Encerrado |
					lRet := .F.
					FwHelpShow("NoDelete","","Linha nao pode ser excluida pois movimento ja esta encerradou ou integrado com o Fluig","")
				ENDIF
			ENDIF			
		ENDIF
	ENDIF		
	 
ENDIF
	
Return(lRet)