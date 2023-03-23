#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#Include 'RestFul.CH'
#INCLUDE 'TBICONN.CH'

#DEFINE EOL CHR(13)+CHR(10)


/*/{Protheus.doc} WSR_RELOCOR
REST busca as ultimas ocorrencias e envia por email
@author Jonatas Oliveira | www.compila.com.br
@since 27/06/2018
@version 1.0
/*/
User Function WSR_RELOCOR()
Return



WSRESTFUL RELOCOR DESCRIPTION "Serviço REST para manipulação de Relatorio Ocorrencias"



//WSMETHOD GET DESCRIPTION "Retorna o Ocorrencias informado na URL" WSSYNTAX "/Ocorrencias || /Ocorrencias/{crm}"
WSMETHOD POST DESCRIPTION "Solicita Relatorio Ocorrencias" WSSYNTAX " /RELOCOR/{}"

END WSRESTFUL




WSMETHOD POST  WSSERVICE RELOCOR
	Local oObjProd := Nil
	Local cStatus  := ""
	LOcal cBody		:= ""
	Local cJRetOK   := '{"code":200,"status":"success"}'
	Local oJson	
	Local aRet		:= {.F.,"", "", ""}
	Local lRet		:= .F.

	//Local aRetUsr := AllUsers()                            
	Local nI
	Local cUserPt := ""


	Local ADADOS	:= {}
	Local cMsgDeta	:= ""
	Local nOper		:= 0 //| 3- Inclusão, 4- Alteração, 5- Exclusão|
	Local cCdFluig	:= ""
	Local aRetGrv	:={}
	Local DDTAUX	
	Local cQuery	:= ""
	Local lContinua	:= .T.

	Private cCrmOc, cCRmUf , cMailEv

	::SetContentType("application/json")

	cBody := ::GetContent()
	IF !EMPTY(cBody)
		IF FWJsonDeserialize(cBody,@oJson)

			//	PswOrder(4)//|E-mail|
			//If PswSeek( alltrim(oJson:VIS_MAIL), .T. )
			cUserPt := PswRet( 1, .F. )[1][1]

			_cEmp		:= "01"
			_cFilial	:= "00101MG0001"//"00101MG0001"//"00303MG0001"

			PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial

			cCrmOc 		:= ALLTRIM(oJson:P_CRM)
			cCRmUf 		:= ALLTRIM(oJson:P_CRMUF)
			cMailEv		:= ALLTRIM(oJson:P_EMAIL)

			IF !EMPTY(cMailEv)
			
				aRet := U_RXTMK03E(cCrmOc, cCRmUf, cMailEv )
				
				IF aRet[1]
		
					cJRetOK   := '{"code":200,"status":"success",'+aRet[4]+'}'
					::SetResponse(cJRetOK)				
					
					lRet := .T.
	
					cAnexo := aRet[3]
	
					/*----------------------------------------
					27/09/2018 - Jonatas Oliveira - Compila
					Envia E-mail
					------------------------------------------*/
					GeraWF(cMailEv, cAnexo)
	
				ELSE
					SetRestFault(200, aRet[2])
				ENDIF 
			ELSE
				SetRestFault(200, "E-mail nao informado")	
			ENDIF 

		Endif 					

	ELSE
		SetRestFault(200, "Body Vazio")

	ENDIF
	
	
	IF aRet[1]
		aRet		:= {aRet[1],aRet[2],aRet[4]}
	ENDIF 
	
Return(lRet)





/*/{Protheus.doc} RXTMK03E
Gera Relatório
@author Jonatas Oliveira | www.compila.com.br
@since 27/09/2018
@version 1.0
/*/
User Function RXTMK03E(_cCrmOc, _cCRmUf, _cMailEv)
	Local oExcel 	:= FWMSEXCEL():New()
	Local cArquiv	:= "Ocorrencias" + "_" + DTOS(DATE())+ STRTRAN(TIME(),":","") + ".XLS"
	Local cPatchCP	:= "\DATA\COMPILA\"
	Local _cNome	:= ""
	Local cRetNome	:= ""

	Local cSheet	:= "Ocorrencias"
	Local cTable	:= "Ocorrencias"
	Local cQuery 	:= ""
	Local cMailVis	:= ""
	Local dDatIni, dDatFim, cCodVis, nTipoVis
	Local aRet		:= {.T., "", "", ""}
	Local cJson	:= ""
	Local nI, nTotCpo, cNameCpo, xDado

	

	_cNome	:= AllTrim(cPatchCP)+ cArquiv

//	cQuery += " SELECT SUC.R_E_C_N_O_ AS RECSUC "
//	cQuery += " FROM "+Retsqlname("SUC")+" SUC "	
//	cQuery += " INNER JOIN "+Retsqlname("Z03")+" Z03 "
//	cQuery += " 	ON Z03_FILIAL = '' "
//	cQuery += " 	AND SUC_CODVIS = Z03_CODVIS "
	
	cQuery += " SELECT TOP 10 UC_XCRM AS CRM,  "
	cQuery += " 	UC_XCRMUF AS UFCRM, "
	cQuery += " 	UC_XMEDICO AS MEDICO, "
	cQuery += " 	UC_DATA AS DT_ABERTURA, "
	cQuery += " 	UC_DTENCER AS DT_ENCERRA, "
	cQuery += " 	UC_XUNIDAD AS UNIDADE, "
	cQuery += " 	CASE WHEN UC_STATUS = '3' THEN 'ENCERRADO' ELSE 'ABERTO' END AS ST_OCORR, "
	cQuery += " 	UC_CODOBS as DESCRICAO, "
	cQuery += " 	R_E_C_N_O_ AS RECSUC "
	cQuery += " FROM "+RetSqlName("SUC")+" SUC WITH(NOLOCK) "
	cQuery += " WHERE UC_XCRM = '"+_cCrmOc+"' "
	cQuery += " AND UC_XCRMUF = '"+_cCRmUf+"' "
	cQuery += " AND SUC.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY UC_STATUS, UC_DATA "


	If Select("QRYOCO") > 0
		QRYOCO->(DbCloseArea())
	EndIf

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"QRYOCO", .F., .T.)
	
	TCSetField("QRYOCO","DT_ABERTURA"	,"D",08,00)
	TCSetField("QRYOCO","DT_ENCERRA"	,"D",08,00)

	IF QRYOCO->(!EOF())

		oExcel 	:= FWMSEXCEL():New()
		//_cNome	:= AllTrim(cPatchCP) + "_" + cArquiv + "_" + DTOS(DATE()) + "_" + STRTRAN(TIME(),":","_") +".XLS"

		//|Define a cor de preenchimento geral para todos os estilos da planilha
		oExcel:SetFrGeneralColor("#000000")

		oExcel:AddworkSheet(cSheet)

		oExcel:AddTable (cSheet,cTable)
		oExcel:SetTitleFrColor("#000000")
		oExcel:SetTitleBgColor("#E6E6E6")
		oExcel:SetHeaderBold(.F.)
		oExcel:SetFrColorHeader("#000000")
		oExcel:SetBgColorHeader("#F8F8F8")

		oExcel:SetLineBgColor("#000000")
		oExcel:SetLineBgColor("#FFFFFF")
		oExcel:Set2LineBgColor("#000000")
		oExcel:Set2LineBgColor("#FFFFFF")

		oExcel:AddColumn(cSheet ,cTable ,"CRM"						,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"UFCRM"					,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"MEDICO"					,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"DT_ABERTURA"				,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"DT_ENCERRA"				,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"UNIDADE"					,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"UC_STATUS"				,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"DESCRICAO"		  		,1,1)

		DBSELECTAREA("SUC")
		SUC->(DBSETORDER(1))
		
		cJson += '"DADOS":['
		
		IF QRYOCO->(!EOF())
		
			nTotCpo	:= QRYOCO->(FCOUNT()) - 1
			
			
			
			/*------------------------------------------------------ Augusto Ribeiro | 23/06/2017 - 6:25:42 PM
				Alimenta campos do cabecalho
			------------------------------------------------------------------------------------------*/
			aFields	:= {}
			For nI := 1 To nTotCpo
				cNameCpo	:= ALLTRIM(QRYOCO->(FIELDNAME(nI)))
				AADD(aFields,cNameCpo)
			Next nI	
			
			
			
			
			WHILE QRYOCO->(!EOF())
	
				SUC->(DBGOTO(QRYOCO->RECSUC))
	
				oExcel:AddRow(cSheet,cTable,{	SUC->UC_XCRM			,;
												SUC->UC_XCRMUF			,;
												SUC->UC_XMEDICO			,;
												DTOC(SUC->UC_DATA)		,;
												DTOC(SUC->UC_DTENCER)	,;
												SUC->UC_XUNIDAD			,;									
												QRYOCO->ST_OCORR		,;											
												MSMM(SUC->UC_CODOBS,80, ,,3, , ,"SUC","SUC->UC_CODOBS")})	
				cJson += '{'
				
				For nI := 1 To nTotCpo
					IF nI > 1
						cJson += ','
					ENDIF
					
					IF ALLTRIM(aFields[nI]) == "DESCRICAO"
						cJson += U_cpxToJson("DESCRICAO", STRTRAN(MSMM(SUC->UC_CODOBS,80, ,,3, , ,"SUC","SUC->UC_CODOBS"),'"', "") )
					ELSE					
						IF VALTYPE(QRYOCO->(FIELDGET(nI))) == "D"
							cJson += U_cpxToJson(aFields[nI], DTOC( QRYOCO->(FIELDGET(nI))) )
						ELSE
							cJson += U_cpxToJson(aFields[nI], QRYOCO->(FIELDGET(nI)) )
						ENDIF 
					ENDIF 
					
				Next nI						
				cJson += '}'
				
				
				QRYOCO->(DBSKIP())
				
				IF QRYOCO->(!EOF())
					cJson += ','
				ENDIF	
	
			ENDDO 	
				
		ENDIF 
		
		cJson += "]"

		oExcel:Activate()
		oExcel:GetXMLFile(_cNome)
		oExcel:DeActivate()

		aRet := {.T., "Sucesso", _cNome, cJson} 
	ELSE
		aRet := {.F., "Nao existem dados para os parametros informados", ""}
	ENDIF 
Return(aRet)


/*/{Protheus.doc} GeraWF
Envia e-mail com o relatorio 
@author Jonatas Oliveira | www.compila.com.br
@since 27/09/2018
@version 1.0
/*/
Static Function GeraWF(cEmail, cAnexo)
	Local cTipoDesc := ""
	Local cCodProc 		:= "STATUS_VT"
	Local cDescProc		:= "Relatorio Ocorrencia"
	Local cHTMLModelo	:= "\WORKFLOW\RXTMK03.htm"		
	Local cSubject		:= ""
	Local cFromName		:= "Relatorio de Ocorrencias"

	cSubject := cDescProc
	
	//|Cria Processo de Workflow|
	oProcess	:= TWFProcess():New(cCodProc,cDescProc)
	oProcess:NewTask(cDescProc,cHTMLModelo)

	oHtml 		:= oProcess:oHtml

	oProcess:ClientName(Subs(cUsuario,7,15))
	oProcess:cTo 		:= cEmail	

	oProcess:cSubject 	:= cSubject

	IF !EMPTY(cAnexo)
		oProcess:attachfile(cAnexo)
	ENDIF 

	//oProcess:cFromAddr := "financeiro@omnilink.com.br"
	oProcess:CFROMNAME 	:= cFromName

	oProcess:Start()
	oProcess:Free()

	CONOUT("### RXTMK02 - WF ENVIADO COM SUCESSO - "+cEmail)

Return()