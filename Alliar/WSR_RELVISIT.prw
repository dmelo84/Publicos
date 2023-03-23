#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#Include 'RestFul.CH'
#INCLUDE 'TBICONN.CH'

#DEFINE EOL CHR(13)+CHR(10)



User Function WSR_RELVISIT()
Return



WSRESTFUL RELVISIT DESCRIPTION "Serviço REST para manipulação de Relatorio VISITAS"



//WSMETHOD GET DESCRIPTION "Retorna o VISITAS informado na URL" WSSYNTAX "/VISITAS || /VISITAS/{crm}"
WSMETHOD POST DESCRIPTION "Solicita Relatorio VISITAS" WSSYNTAX " /RELVISIT/{}"

END WSRESTFUL




WSMETHOD POST  WSSERVICE RELVISIT
	Local oObjProd := Nil
	Local cStatus  := ""
	LOcal cBody		:= ""
	Local cJRetOK   := '{"code":200,"status":"success"}'
	Local oJson	
	Local aRet		:= {.F.,""}

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

	Private dDatInF, dDatFiF, cCodViF, nTipoViF, cMailEnv,cAnexo 

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

			dDatInF 	:= CTOD(oJson:VIS_DTINI)
			dDatFiF 	:= CTOD(oJson:VIS_DTFIM)
			cCodViF		:= ALLTRIM(oJson:VIS_MAIL)
			nTipoViF	:= VAL(oJson:VIS_TIPO)
			cMailEnv	:= ALLTRIM(oJson:VIS_MAILENVIO)

			cQuery += " SELECT R_E_C_N_O_ AS RECNZ03, * "
			cQuery += " FROM "+Retsqlname("Z03")+" "
			cQuery += " WHERE D_E_L_E_T_ = '' "
			cQuery += " 	AND Z03_EMAIL = '"+ cCodViF +"' "

			If Select("QRYEXC") > 0
				QRYEXC->(DbCloseArea())
			EndIf

			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYEXC')

			IF QRYEXC->(!EOF())								
				aRet := U_RXTMK02E(.T. , dDatInF, dDatFiF, cCodViF, nTipoViF )
				IF aRet[1]
					::SetResponse(cJRetOK)

					cAnexo := aRet[3]

					/*----------------------------------------
					17/11/2017 - Jonatas Oliveira - Compila
					Envia E-mail
					------------------------------------------*/
					GeraWF(cMailEnv, cAnexo)

				ELSE
					SetRestFault(200, aRet[2])
				ENDIF 
			ELSE

				SetRestFault(200, "E-mail nao informado ou usuario nao encontrato ["+alltrim(cCodViF)+"]")
			ENDIF 
		Endif 					

	ELSE
		SetRestFault(200, "Body Vazio")

	ENDIF

Return(aRet[1])






/*/{Protheus.doc} RXTMK02
Relatório de visitas 
@author Jonatas Oliveira | www.compila.com.br
@since 17/11/2017
@version 1.0
/*/
User Function RXTMK02()
	Local cPerg := "RXTMK02"
	Local _lProcess	:= .F.
	Local _aSay			:= {}
	Local _aBotoes		:= {}

	Private oOk      := LoadBitmap( GetResources(), "LBOK" ) 
	Private oNo      := LoadBitmap( GetResources(), "LBNO" ) 

	Private cTitulo  := "Relatorio de Visitas"


	/*===================== 
	| Parametros do Usuário
	=======================*/
	AjustaSx1(cPerg)

	_aSay	:= {cTitulo,;
	"  ",;
	" Este programa tem como objetivo gerar apresentar Relatorio  ",;
	" de Visitas .",;
	" Preencha os parametros para que os dados sejam corretamente selecionados.",;
	" ",;
	" Compila - Versão 1.1"}

	aAdd(_aBotoes, { 5,.T.,{|| PERGUNTE(cPerg,.T.)}})
	aAdd(_aBotoes, { 1,.T.,{|| _lProcess := .T., FechaBatch() }} )
	aAdd(_aBotoes, { 2,.T.,{|| _lProcess := .F., FechaBatch()  }} )

	FormBatch( cTitulo, _aSay, _aBotoes ,,240,510)

	Pergunte(cPerg,.F.)

	IF _lProcess
		RptStatus({|| U_RXTMK02E()}, cTitulo)
	ENDIF
Return





/*/{Protheus.doc} RXTMK02E
Gera Relatório
@author Jonatas Oliveira | www.compila.com.br
@since 17/11/2017
@version 1.0
/*/
User Function RXTMK02E(lAuto , dDatInF, dDatFiF, cCodViF, nTipoViF )
	Local oExcel 	:= FWMSEXCEL():New()
	Local cArquiv	:= "Visitas" + "_" + DTOS(DATE())+ STRTRAN(TIME(),":","") + ".XLS"
	Local cPatchCP	:= "" //"C:\TEMP\"//GetTempPath(.T.)//ALLTRIM(U_ATEC200G("19", "DIR_RELAT"))
	Local _cNome	:= ""
	Local cRetNome	:= ""

	Local cSheet	:= "Visitas"
	Local cTable	:= "Visitas"
	Local cQuery 	:= ""
	Local cMailVis	:= ""
	Local dDatIni, dDatFim, cCodVis, nTipoVis
	Local aRet		:= {.T., ""}

	Default lAuto	:= .F.


	IF !lAuto
		cPatchCP	:= GetTempPath(.T.)

		dDatIni		:= MV_PAR01
		dDatFim		:= MV_PAR02
		cCodVis		:= MV_PAR03
		nTipoVis	:= MV_PAR04
	ELSE
		cPatchCP	:= "\DATA\COMPILA\"

		dDatIni		:= dDatInF	
		dDatFim		:= dDatFiF	
		cCodVis		:= cCodViF	
		nTipoVis	:= nTipoViF 	
	ENDIF 

	_cNome	:= AllTrim(cPatchCP)+ cArquiv

	cQuery += " SELECT Z05.R_E_C_N_O_ AS RECZ05 "
	cQuery += " FROM "+Retsqlname("Z05")+" Z05 "	
	cQuery += " INNER JOIN "+Retsqlname("Z03")+" Z03 "
	cQuery += " 	ON Z03_FILIAL = '' "
	cQuery += " 	AND Z05_CODVIS = Z03_CODVIS "

	IF !EMPTY(cCodVis)
		IF !lAuto
			cMailVis := posicione("Z03",1,XFILIAL("Z03") + cCodVis ,"Z03_EMAIL")
		ELSE
			cMailVis := cCodVis
		ENDIF

		cQuery += " 	AND Z03_EMAIL = '"+ cMailVis +"' "
	ENDIF  

	cQuery += " 	AND Z05_DTPREV BETWEEN '"+ DTOS(dDatIni) +"' AND '"+ DTOS(dDatFim) +"' "
	cQuery += " WHERE Z05.D_E_L_E_T_ = '' "

	IF nTipoVis == 1 .OR. nTipoVis == 2 
		cQuery += " 	AND Z05_REUNIA = '"+ ALLTRIM(STR(nTipoVis)) +"' "
	ENDIF

	cQuery += " ORDER BY Z03_EMAIL,Z05_DTPREV, Z05_HRPREV "

	If Select("QRYVIS") > 0
		QRYVIS->(DbCloseArea())
	EndIf

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"QRYVIS", .F., .T.)

	IF QRYVIS->(!EOF())

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

		oExcel:AddColumn(cSheet ,cTable ,"Visitadora"			,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Dia"				  	,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Segmento"				,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Médico"				,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Endereço"				,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Especialidade"		,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Horário"				,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Detalhamento"		  	,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Reuniao Realizada"  	,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Reuniao Com Medico"  	,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Reuniao Com Secretaria"  	,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"FeedBack"			  	,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"Clinica?"			  	,1,1)
		oExcel:AddColumn(cSheet ,cTable ,"ID FLUIG"			,1,1)

		DBSELECTAREA("Z05")
		Z05->(DBSETORDER(1))


		WHILE QRYVIS->(!EOF())

			Z05->(DBGOTO(QRYVIS->RECZ05))

			oExcel:AddRow(cSheet,cTable,{	Z05->Z05_VISITA	,;
											DTOC(IIF(Z05->Z05_REUNIA == "2",Z05->Z05_DTPREV, Z05->Z05_DTIN ))	,;
											Z05->Z05_SEGMEN		,;
											Z05->Z05_CRM + " - " + Z05->Z05_NOME 		,;
											ALLTRIM(Z05->Z05_ENDER) + " - " + ALLTRIM(Z05->Z05_BAIRRO) + " - " + Z05->Z05_UF 		,;
											Z05->Z05_ESPECI		,;
											IIF(Z05->Z05_REUNIA == "2",Z05->Z05_HRPREV + " - " + Z05->Z05_HRFIMP, Z05->Z05_HRIN + " - " + Z05->Z05_HRFIM )	,;											
											Z05->Z05_DETALH		,;											
											X3COMBO("Z05_REUNIA", Z05->Z05_REUNIA),;
											X3COMBO("Z05_REUMED", Z05->Z05_REUMED),;
											X3COMBO("Z05_REUSEC", Z05->Z05_REUSEC),;
											X3COMBO("Z05_FEEDB", Z05->Z05_FEEDB),;
											IIF(EMPTY(Z05->Z05_CLINIC), "Não" ,X3COMBO("Z05_CLINIC", Z05->Z05_CLINIC)),;
											Z05->Z05_IDFLUI})		


			QRYVIS->(DBSKIP())

		ENDDO 		


		oExcel:Activate()
		oExcel:GetXMLFile(_cNome)
		oExcel:DeActivate()

		IF !lAuto
			/*=====================
			| Abre arquivo gerado  |
			=======================*/
			ShellExecute("open","excel.exe",_cNome,"", 1 )
		ELSE
			aRet := {.T., "Sucesso", _cNome}

		ENDIF 
	ELSE
		IF !lAuto 
			AVISO("SEM DADOS","Não existem dados para os parametros informados",{"Fechar"}, 1)
		ELSE
			aRet := {.F., "Nao existem dados para os parametros informados", ""}
		ENDIF 
	ENDIF 
Return(aRet)


/*========================================================================
| Função...: AjustaSx1
| Descrição: Ajusta as Perguntas. 
|
| Nota.....:
|
| ========================================================================
| Desenvolvido por: Jonatas Oliveira
======================================================================== */
Static Function AjustaSx1(cPerg)

	Local aArea := GetArea()
	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}

	aAdd( aHelpEng, "  ")
	aAdd( aHelpSpa, "  ")


	aHelpPor := {} ; Aadd( aHelpPor, "Data De")
	PutSx1( cPerg, "01","Data De"	,"","","mv_ch1"	,"D",08,0,0,"G",""		 	,""		,"","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Data Ate")
	PutSx1( cPerg, "02","Data Ate" ,"","","mv_ch2","D",08,0,0,"G","NaoVazio"	,""		,"","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Informe a Visitadora. Para apresentar todas deixar Vazio.")
	PutSx1( cPerg, "03","Visitadora"	,"","","mv_ch3"	,"C",06,0,0,"G",""			,"Z03"	,"","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Tipo")
	PutSx1( cPerg, "04","Tipo","","","mv_ch4","N",01,0,0,"C","","","","","mv_par04","Realizado","","","","Previsto","","","AMBOS","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
Return()



/*/{Protheus.doc} GeraWF
Envia e-mail com o relatorio 
@author Jonatas Oliveira | www.compila.com.br
@since 17/11/2017
@version 1.0
/*/
Static Function GeraWF(cEmail, cAnexo)
	Local cTipoDesc := ""
	Local cCodProc 		:= "STATUS_VT"
	Local cDescProc		:= "Relatorio Visita"
	Local cHTMLModelo	:= "\WORKFLOW\RXTMK02.htm"		
	Local cSubject		:= ""
	Local cFromName		:= "Relatorio de Visitas"
	
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