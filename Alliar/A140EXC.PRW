#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} A140EXC
P.E. na exclusao do documento de entrada.
@author Augusto Ribeiro | www.compila.com.br
@since 27/02/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User function A140EXC()
Local lRet	:= .t.
Local aParam	:= ParamIxb
Local aCardData	:= {}
Local aRetAux	:= {.F.,""}
Local lIntFluig	:= .T.
Local nRDelSF1	:= 0

Local nHSemaf	:= 0
Local cFile		:= "DELSF1"
Local aArea		:= GetArea()
Local aAreaSD1	:= SD1->(GetArea())

Local nAtivFluig

/*------------------------------------------------------ Augusto Ribeiro | 27/02/2017 - 9:53:31 AM
	FLUIG - Retorna Atividade Processo na exclusao da pre-nota
------------------------------------------------------------------------------------------*/

IF !EMPTY(SF1->F1_XIDFLG)

	IF TYPE("lWSFluig") == "L"
		IF lWSFluig
			lIntFluig	:= .F.
		ENDIF
	ENDIF

	IF lIntFluig
		

		
		/*------------------------------------------------------ Augusto Ribeiro | 22/03/2017 - 10:16:35 PM
			ABRE semaforo de processamento para evitar LOOp ENTRE INTEGRACAO DO FLUIG
		------------------------------------------------------------------------------------------*/
		nRDelSF1	:= SF1->(RECNO())
		cFile		:= cFile+alltrim(nRDelSF1)+".lck"
		nHSemaf		:= U_CPXSEMAF("A", cFile, nHSemaf)		
		
		IF nHSemaf > 0
			
			/*------------------------------------------------------ Augusto Ribeiro | 24/08/2017 - 2:37:47 PM
				Tratamento para processo de concessionárias
			------------------------------------------------------------------------------------------*/
			nAtivFluig	:= 54 //| Atividade me analise|
			
			DBSELECTAREA("SD1")
			SD1->(DBSETORDER(1)) //| 
			IF SD1->(DBSEEK( SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA),.f. )) 
				IF Empty(SD1->D1_PEDIDO) 
					nAtivFluig	:= 5
				endif						
			ENDIF
		
			IF ISBLIND()
				aRetAux	:= U_cpFSSTsk(VAL(SF1->F1_XIDFLG), SF1->F1_USERID, nAtivFluig,"Pre-Nota excluida no Protheus ("+ALLTRIM(UsrFullName(__CUSERID))+")" , .T., .F., /* aCardData */)		
			ELSE
				MsgRun( "Integrando NF com Fluig...", "Integração Fluig", {|| aRetAux	:= U_cpFSSTsk(VAL(SF1->F1_XIDFLG), SF1->F1_USERID, nAtivFluig,"Pre-Nota excluida no Protheus ("+ALLTRIM(UsrFullName(__CUSERID))+")" , .T., .F., /* aCardData */) } )	
			ENDIF 
					
			IF !(aRetAux[1])
				Conout("A140EXC", "ERRO: "+aRetAux[2])
				//Help(" ",1,"A140EXC",,aRetAux[2],4,5)
				//lRet	:= .F.
			ENDIF	
		ENDIF

		/*------------------------------------------------------ Augusto Ribeiro | 22/03/2017 - 10:16:35 PM
		FECHA semaforo de processamento para evitar LOOp ENTRE INTEGRACAO DO FLUIG
		------------------------------------------------------------------------------------------*/		
		U_CPXSEMAF("F", cFile, nHSemaf)					
		
	ENDIF

ENDIF


RestArea(aAreaSD1)
RestArea(aArea)

Return(lRet)