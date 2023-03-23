



/*/{Protheus.doc} CN120ENMED
Executa ponto de entrada para encerramento da medicao
@author Augusto Ribeiro | www.compila.com.br
@since 10/10/2017
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CN120ENMED()
Local aRetAux	:= {}
	
	/*---------------------------------
		FILA INTEGRADOR PROTHEUS
	----------------------------------*/
	
	//| ENCERRA MEDICAO - ASSUME SOLICITACAO FLUIG         |
	aRetAux	:= U_CP12ADD("000002", "CND", CND->(RECNO()), , )
	IF aRetAux[1]
		//| ENCERRA MEDICAO - ENCERRA SOLICITACAO FLUIG       |
		aRetAux	:= U_CP12ADD("000003", "CND", CND->(RECNO()),, aRetAux[3,1])
	ENDIF
	
	IF !EMPTY(CND->CND_NUMTIT)
		DBSELECTAREA("SE2")
		SE2->(DBSETORDER(1))
		
		IF SE2->(DBSEEK(CND->CND_FILIAL + GETMV("MV_CNPREMD") + CND->CND_NUMTIT))

			SE2->(RecLock("SE2",.F.))
				SE2->E2_XIDFLG := 	CND->CND_XIDFLG				
				SE2->E2_XCOMPME := 	CND->CND_COMPET				
			SE2->(MsUnLock())
		ENDIF 
	ENDIF 
	/*
	aRetAux	:= U_cpFTakeP(VAL(CND->CND_XIDFLG),GETMV("MV_ECMMAT",.F.,""))
	IF aRetAux[1]
		cCompFluig	:= "Medicao Encerrada Automaticamente. "
		IF !EMPTY(CND->CND_PEDIDO)
			cCompFluig += " PEDIDO: "+ALLTRIM(CND->CND_PEDIDO)
		ELSEIF !EMPTY(CND->CND_NUMTIT)
			cCompFluig += " TITULO: "+ALLTRIM(CND->CND_NUMTIT)
		ENDIF 
		
		aRetAux	:= U_cpFSSTsk(VAL(CND->CND_XIDFLG), GETMV("MV_ECMMAT",.F.,""), 19,cCompFluig, .T., .F., )
		IF !(aRetAux[1])
			CONOUT("CN120ENMED","Erro: "+aRetAux[2])
		ENDIF
	ELSE 
		CONOUT("CN120ENMED","Erro: "+aRetAux[2])
	ENDIF
	*/
	
Return()