#Include "rwmake.Ch"
#Include "TopConn.Ch"
#Include "Protheus.Ch"
#INCLUDE "TBICONN.CH" 

/*/{Protheus.doc} AFAT001
Rotina de chamada de impressão e envio por email da RPS
@param nEnvMail, 0=Não Envia;1=Envia Para e-mail do Cliente;2=Envia somente para e-mail do cMail3=Ambos (E-mail do cliente e cMail)
@author Jonatas Oliveira | www.compila.com.br
@since 15/04/2017
@version 1.0
/*/
User Function AFAT001(nRecSF2, cFilNf, cNota, cSerie, cFullPath, nEnvMail, cMail)
	Local lRet	:= .f.
	Private cArqPdf	:= ""
	
	cArqPdf	:=	U_RFAT001(nRecSF2, cFilNf, cNota, cSerie, cFullPath)
	
	IF !EMPTY(cArqPdf)
		lRet	:= GeraWFP(nRecSF2, cFilNf, cNota, cSerie, nEnvMail, cMail)
	ENDIF 
	
Return(lRet)

/*/{Protheus.doc} GeraWFP
Envio de email de aviso
@author Jonatas Oliveira | www.compila.com.br
@since 20/06/2016
@version 1.0
/*/
Static Function GeraWFP(nRecSF2, cFilNf, cNota, cSerie, nEnvMail, cMail)
	Local lRet			:= .f.
	Local cTipoDesc := ""
	Local cCodProc 		:= "STATUS_PF"
	Local cDescProc		:= "RPS Cliente"
	Local cHTMLModelo	:= "\WORKFLOW\AFAT001.htm"

	Local cDestinat		
	Local cSubject		:= "Recibo Provisório de Serviço"
	Local cFromName		:= "Recibo Provisório de Serviço"
	Local cDescrServ	:= ""
	Local _cCodEmp, _cCodFil, _cFilNew
	
	Default nEnvMail 	:= 0 
	Default nRecSF2		:= 0
	Default cFilNf		:= ""
	Default cNota		:= ""
	Default cSerie		:= ""
	Default cMail		:= ""
	
	
	/*
		Onde nEnvMail pode ser
		0=Não Envia;
		1=Envia Para e-mail do Cliente;
		2=Envia somente para e-mail do cMail
		3=Ambos (E-mail do cliente e cMail)
	*/
	
	
	IF nRecSF2 > 0 .OR. (!EMPTY(cFilNf) .AND. !EMPTY(cNota) .AND. !EMPTY(cSerie))
	 	lRelAuto	:= .T.
	 	
	 	DBSELECTAREA("SF2")
	 	SF2->(DBSETORDER(1))//|F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO|
	 	
	 	IF nRecSF2 > 0
	 		SF2->(DBGOTO(nRecSF2))
	 	ELSE
	 		IF SF2->(!DBSEEK(cFilNf+cNota+cSerie ))
	 			Return
	 			
	 		ENDIF 
	 	ENDIF 
	ENDIF 
	
	IF nEnvMail <> 0 
	
		
		/*---------------------------------------
			Realiza a TROCA DA FILIAL CORRENTE 
		-----------------------------------------*/
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= SF2->F2_FILIAL //| CODIGO DA FILIAL DE DESTINO 
		
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF
		
	
		
		DBSELECTAREA("SA1")
	 	SA1->(DBSETORDER(1))
	 	
	 	IF SA1->(DBSEEK(XFILIAL("SA1") + SF2->(F2_CLIENTE + F2_LOJA)))
		
			IF nEnvMail == 1
				cDestinat	:= ALLTRIM(SA1->A1_EMAIL)
				
			ELSEIF nEnvMail == 2 .AND. !EMPTY(cMail)
				cDestinat	:= ALLTRIM(cMail)
				
			ELSEIF nEnvMail == 3
				cDestinat	:= ALLTRIM(cMail) + ";" + ALLTRIM(SA1->A1_EMAIL)
				
			ENDIF 
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Cria Processo de Workflow ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess	:= TWFProcess():New(cCodProc,cDescProc)
			oProcess:NewTask(cDescProc,cHTMLModelo)
		
			oHtml 		:= oProcess:oHtml

			oHtml:ValByName( "logohtml" 	, LOWER(U_alLogo(SF2->F2_FILIAL,"WEB")))
			oHtml:ValByName( "ccliente" 	, CAPITAL(ALLTRIM(SA1->A1_NOME)))
			oHtml:ValByName( "cEmpresa" 	, CAPITAL(ALLTRIM(SM0->M0_NOMECOM)))	
			oHtml:ValByName( "cCNPJEMP" 	, Transform(SM0->M0_CGC,"@r 99.999.999/9999-99") )
			oHtml:ValByName( "cCidade" 		, CAPITAL(ALLTRIM(SM0->M0_CIDCOB)))
			
			If SD2->(dbSeek(SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
				dbSelectArea("CCQ")
				CCQ->(dbSetOrder(1))
				If CCQ->(dbSeek(xFilial("CCQ")+ALLTRIM(SD2->D2_CODISS)))
					cDescrServ := CCQ->CCQ_DESC
				Endif				
			ENDIF			
			
			aadd((oHtml:ValByName( "item.dtemissao")), SF2->F2_EMISSAO)
			aadd((oHtml:ValByName( "item.descserv")), cDescrServ)
			aadd((oHtml:ValByName( "item.rps")), SF2->F2_DOC )
			aadd((oHtml:ValByName( "item.nfe")), SF2->F2_NFELETR )
			aadd((oHtml:ValByName( "item.chave")), ALLTRIM(if(EMPTY(SF2->F2_XCVNFS), SF2->F2_CODNFE, SF2->F2_XCVNFS) ))
			aadd((oHtml:ValByName( "item.valor")), Transform(SF2->F2_VALBRUT ,PesqPict("SF2","F2_VALBRUT")) )
				
			cDestRepo	:= GetMv("ES_REPORPS",.F.) //| E-mail Repositorio para envio em copia|
			
			oProcess:ClientName(Subs(cUsuario,7,15))
			oProcess:cTo 		:= cDestinat
			IF !EMPTY(cDestRepo)
				oProcess:cBCC		:= cDestRepo
			ENDIF
			oProcess:cSubject 	:= cSubject
			oProcess:attachfile(cArqPdf)
			oProcess:CFROMNAME 	:= cFromName
		
			cIDTaks	:= oProcess:Start()
			oProcess:Free()
			
			lRet	:= .t.
		ENDIF
		
				
		/*---------------------------------------
			Restaura FILIAL  
		-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF   		
	
	ENDIF 
	
	//CONOUT("### AFAT001 - WF ENVIADO COM SUCESSO - "+cDestinat)

Return(lRet)


User Function AFATTST()
	
	_cEmp		:= "99"
	//_cFilial	:= "62500620" //SAO GONCALO
	_cFilial	:= "01"


	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
	
	U_AFAT001(7, , , , "\DATA\RPS_TESTE_"+STRTRAN(TIME(),":","")+".PDF",1) 
	RESET ENVIRONMENT 

Return





/*/{Protheus.doc} AFAT01JOB
Processa envio automático das RPS por e-mail
@author Augusto Ribeiro | www.compila.com.br
@since 31/05/2017
@version undefined
@param aParam, [cCodEmp, cCodFil]
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function AFAT01JOB(aParam)
Local _cEmp		:= "01"
Local _cFilial	:= "00101MG0001"
Local cQuery	:= ""
Local aFilSend, cFilSend, cMarcaSend
Local dDataCorte, aRecReg, nI

Local nHSemaf	:= 0
Local cAbreFecha, cFSemaf


IF !empty(aParam)
	_cEmp		:= aParam[1]
	_cFilial	:= aParam[2]
ENDIF

//CONOUT("### AFAT01JOB: INICIO "+DTOC(DATE())+" "+TIME())

cFSemaf	:= "AFAT01JOB"
nHSemaf	:= U_CPXSEMAF("A", cFSemaf, nHSemaf)

IF nHSemaf > 0

	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial


		cFilSend	:= GETMV("ES_SENDRPS",.F.,"") //| Filias com envio automatico de RPS ativado|
		dDataCorte	:= GetMv("ES_DTRPSWF",.F.,STOD("20170531")) //| Data de Corte para envio da RPS|
		
		/*------------------------------------------------------ Augusto Ribeiro | 23/08/2017 - 7:18:45 PM
			Caso parametro das filiais estaja vazio, busca marcas ativas para envio da RPS
		------------------------------------------------------------------------------------------*/
		IF EMPTY(cFilSend)
			cMarcaSend	:= GETMV("ES_MARSRPS",.F.,"") //| Marcas que possuem o envio da RPP habilitado|
			IF !EMPTY(cMarcaSend)
				aMarcaSend	:= StrTokArr2( cMarcaSend, ";", .F. )
				aFilSend	:= U_alFilMar(aMarcaSend) //| Retorna Array das Filiais que emitem RPS|
			ENDIF
		ELSE
			aFilSend	:= StrTokArr2( cFilSend, ";", .F. )
		ENDIF
		
		//aFilSend	:= {'00401SP0001','00401SP0004'} //| #### |
		IF !EMPTY(aFilSend)
			
			cQuery := "  SELECT SF2.R_E_C_N_O_ AS SF2_RECNO, SF3.R_E_C_N_O_ AS SF3_RECNO "+CRLF
			cQuery += "  FROM "+RetSqlName("SF2")+" SF2 "+CRLF
			cQuery += "  INNER JOIN "+RetSqlName("SF3")+" SF3 "+CRLF
			cQuery += "     ON F3_FILIAL = F2_FILIAL "+CRLF
			cQuery += "     AND F3_NFISCAL = F2_DOC "+CRLF
			cQuery += "     AND F3_SERIE = F2_SERIE "+CRLF
			cQuery += "     AND F3_CLIEFOR = F2_CLIENTE "+CRLF
			cQuery += "     AND F3_LOJA = F2_LOJA "+CRLF
			cQuery += "     AND F3_XDTSRPS = '' "+CRLF
			cQuery += "     AND SF3.D_E_L_E_T_ = '' "+CRLF
			cQuery += "  WHERE SF2.F2_FILIAL IN  "+U_cpxINQRY(aFilSend)
			cQuery += "  AND SF2.F2_EMISSAO >= '"+DTOS(dDataCorte)+"' "+CRLF
			cQuery += "  AND SF2.F2_CODNFE <> '' "+CRLF
			cQuery += "  AND SF2.D_E_L_E_T_ = '' "+CRLF
			cQuery += " ORDER BY F2_FILIAL, F2_DOC  "+CRLF					
			
			If Select("TRPS") > 0
				TRPS->(DbCloseArea())
			EndIf
			
			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRPS",.F., .T.)						
			
			IF TRPS->(!EOF())
				
				aRecReg	:= {}
				WHILE TRPS->(!EOF())
					
					aadd(aRecReg, {TRPS->SF2_RECNO, TRPS->SF3_RECNO})
				
					TRPS->(DBSKIP()) 
				ENDDO	
				
				TRPS->(DbCloseArea())
			
				
				FOR nI := 1 to len(aRecReg)
				
					if U_AFAT001(aRecReg[nI,1], , , , , 1)//, "augusto.ribeiro@compila.com.br,andre.lay@alliar.com")
					//if U_AFAT001(TRPS->SF2_RECNO, , , , , 2, "augusto.ribeiro@compila.com.br")
						
						DBSELECTAREA("SF3")
						SF3->(DBGOTO(aRecReg[nI,2]))
						
						RECLOCK("SF3",.F.)					
							SF3->F3_XDTSRPS	:= DDATABASE
							SF3->F3_XHRSRPS	:= TIME()						
						MSUNLOCK()
					
					endif
				
				
				Next nI
			ELSE
				//CONOUT("### AFAT01JOB: Não existem dados a serem processados.")
			ENDIF
		ELSE
			//CONOUT("### AFAT01JOB: Nenhuma filial esta ativa.")
		ENDIF
		

	RESET ENVIRONMENT
ELSE 
	//CONOUT("### AFAT01JOB: JÁ EXISTE UMA INSTANCIA DA ROTINA EM EXECUCAO")
ENDIF

/*------------------------------------------------------ Augusto Ribeiro | 28/08/2017 - 10:35:02 AM
	Fecha Semaforo
------------------------------------------------------------------------------------------*/
IF nHSemaf > 0
	U_CPXSEMAF("F", cFSemaf, nHSemaf)
ENDIF	
 

//CONOUT("### AFAT01JOB: FIM "+DTOC(DATE())+" "+TIME())

	
Return()







/*/{Protheus.doc} AFAT01DEL
Rotina para exclusao dos PDF temporarios gerados para envio do Workflow.
@author Augusto Ribeiro | www.compila.com.br
@since 31/05/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function AFAT01DEL(aParam)
Local _cEmp		:= "01"
Local _cFilial	:= "00101MG0001"
Local nDiasDel	:= 3
Local aDir, nI


	IF !empty(aParam)
		_cEmp		:= aParam[1]
		_cFilial	:= aParam[2]
		nDiasDel	:= aParam[3]
	ENDIF

	//CONOUT("### AFAT01DEL: INICIO "+DTOC(DATE())+" "+TIME())


	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial

		aDir	:= directory("\data\temp\rps_*.pdf")
		
		FOR nI := 1 to len(aDir)
			IF aDir[nI,3] <= dDataBase-nDiasDel
				
				/*------------------------------------------------------ Augusto Ribeiro | 22/08/2017 - 7:13:42 PM
					Double Check na extenção do arquivo
				------------------------------------------------------------------------------------------*/
				IF lower(RIGHT(ALLTRIM(aDir[nI,1]),3)) == "pdf"
					FERASE("\data\temp\"+aDir[nI,1])
				ENDIF
			ENDIF		
		Next nI

	RESET ENVIRONMENT

	//CONOUT("### AFAT01DEL: FIM "+DTOC(DATE())+" "+TIME())
	
	
Return()
