#INCLUDE "TOTVS.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"  

/*-----------------------------
	Rotinas execução via JOB
------------------------------*/


User Function CPJOB001(aParam)


//Default aParam	:= {"02","0101"}

CONOUT("CPJOB001 - INICIO " + DTOC( DATE() ) + " " + TIME() )

_cEmp		:= aParam[1]
_cFilial	:= aParam[2]                      

PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial

	GeraBord()		//gera bordero

RESET ENVIRONMENT 

CONOUT("CPJOB001 - FIM " + DTOC( DATE() ) + " " + TIME() ) 

Return()





//gera bordero
Static Function GeraBord()
Local cFSemaf
Local nHSemaf
Local cQuery
Local cJoin		:= ""
Local cWhere	:= ""
Local aRetPE
Local aTitBord 	:= {}
Local aLinha
Local aInfBord
Local aRetAux
Local lJ001Qry 	:= ExistBlock("J001QRY")
Local aRet		:= { .T., "" }
Local nI


 /*--------------------------
	Abre Semaforo
---------------------------*/
cFSemaf	:= "J001_gerabord"
nHSemaf	:= U_CPXSEMAF("A", cFSemaf)	

IF nHSemaf > 0
	
	cQuery := " SELECT	A1_COD, A1_LOJA, A1_EMAIL, A1_XEMFIS, A1_XEMFIN, E1_FILIAL, "					+ CRLF
	cQuery += " 		E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1.R_E_C_N_O_ AS E1_RECNO  "			+ CRLF
	cQuery += " FROM 	" + RetSqlName("SE1") + " E1 "													+ CRLF
	//cQuery 	+= " FROM 	SE1020 SE1 "																	+ CRLF

	cJoin += " INNER 	JOIN " + RetSqlName("SA1") + " A1 "												+ CRLF
	//cJoin += " INNER 	JOIN SA1020 SA1 "																+ CRLF
	cJoin += " 			ON	A1.D_E_L_E_T_ 	<> '*' "													+ CRLF
	cJoin += "				AND A1_COD 			= E1_CLIENTE "											+ CRLF
	cJoin += " 				AND A1_LOJA			= E1_LOJA "												+ CRLF
	cJoin += " 				AND	(	"																	+ CRLF
	cJoin += " 						A1_EMAIL 	<> '' OR "												+ CRLF	//ema8il cliente
	//cJoin += " 					A1_XEMFIS 	<> '' OR "												+ CRLF	//email fisco
	//cJoin += " 					A1_XEMFIN 	<> '' OR "												+ CRLF	//email financeiro
	cJoin += "						'" + AllTrim( GetMv( "CP15_WFHOM",.F.,""  ) ) + "' <> '' "			+ CRLF 	//email homologacao
	cJoin += " 					) "																		+ CRLF

	cJoin += " INNER 	JOIN " + RetSqlName("SF2") + " F2 "												+ CRLF
	cJoin += " 			ON	F2.D_E_L_E_T_ 	<> '*' "													+ CRLF
	cJoin += " 				AND F2_CHVNFE 	<> '' "														+ CRLF	//autorizada a nota fiscal
	cJoin += " 				AND F2_XDTSNF 	= '' "														+ CRLF	//enviado email NF e boleto
	cJoin += " 				AND F2_DOC 		= E1.E1_NUM "
	cJoin += "              AND F2_SERIE 	= E1.E1_PREFIXO "
	
	cWhere += "	WHERE 	E1.D_E_L_E_T_	<> '*'  "														+ CRLF
	//cWhere += " 		AND E1_EMISSAO 	>= '" + Dtos( GetMv( "CP_DTCJ001", .F., dDatabase-5 ) ) + "' "	+ CRLF	//data de corte do job 001
	cWhere += "     	AND E1_TIPO 	= 'NF' "														+ CRLF
	cWhere += "      	AND E1_NUMBOR 	= '' "															+ CRLF	//bordero não gerado

	cWhere += "			AND  E1_NUM IN ( '000025598', '000025596' ) "		//validando

	IF lJ001QRY
	
		aRetPE	:= ExecBlock( "J001QRY", .f., .f., { @cJoin, @cWhere } )
		
		cJoin	:= aRetPE[1]
		cWhere	:= aRetPE[2]
	ENDIF

	cQuery += " " + cJoin + " " + cWhere
	
	cQuery += " ORDER BY A1_COD, A1_LOJA, F2.F2_FILIAL, F2_DOC, F2_SERIE "									+ CRLF
	

	If Select("TSQL") > 0
		TSQL->( DbCloseArea() )
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry( ,, cQuery ), "TSQL", .F., .T. )						
		
	IF TSQL->( !EOF() )
		aTitBord		:= {}
		aLinha		:= {}
		Do While TSQL->( !Eof() )
			
			aAdd( aLinha	, {"E1_FILIAL"	,  	TSQL->E1_FILIAL } )
			aAdd( aLinha	, {"E1_PREFIXO"	,	TSQL->E1_PREFIXO } ) 
			aAdd( aLinha	, {"E1_NUM" 	,	TSQL->E1_NUM } )
			aAdd( aLinha	, {"E1_PARCELA"	,  	TSQL->E1_PARCELA } ) 
			aAdd( aLinha	, {"E1_TIPO" 	,	TSQL->E1_TIPO } )
			
			DbSkip()
		EndDo
		aAdd( aTitBord	, aClone( aLinha ) )

	ENDIF
	TSQL->( DbCloseArea() )

	//teste
	cBanco 		:= "341"
	cAgencia	:= "3114"
	cConta		:= "56999"


	aInfBord	:= {}
	aAdd( aInfBord, { "AUTBANCO"	, cBanco	} )
	aAdd( aInfBord, { "AUTAGENCIA" 	, cAgencia } )
	aAdd( aInfBord, { "AUTCONTA" 	, cConta } )	
	aAdd( aInfBord, { "AUTSITUACA"	, "1" } )
	aAdd( aInfBord, { "AUTCONTRAT" 	, "" } )		
	
	/*--------------------------
		Gera Bordero
	---------------------------*/
	aRetAux		:= U_CP15BORD( aInfBord, aTitBord )	
	IF !Empty( aRetAux[2] )
		aRet	:= { .F., "Falha ao gerar Bordero. " + aRetAux[2] }
	ENDIF	

	If Len( aTitBord ) > 0
		For nI := 1 To Len( aTitBord )
			DbSelectArea( "SE1" )
			DbSetOrder(1)
			If DbSeek( aTitBord[nI][1][2] + aTitBord[nI][2][2] + aTitBord[nI][3][2] + aTitBord[nI][4][2] )
				U_CP15IDCN()		//gera idcnab
				U_CP15NOSS()		//gera nosso número
				NFBolMail()			//gera boleto e danfe	
			EndIf
		Next 
	EndIf

	/*------------------------------------------------------ Augusto Ribeiro | 28/08/2017 - 10:35:02 AM
		Fecha Semaforo
	------------------------------------------------------------------------------------------*/
	IF nHSemaf > 0
		U_CPXSEMAF("F", cFSemaf, nHSemaf)
	ENDIF	
ELSE 
	aRet := { .F., "Não foi possivel abrir o semáforo [" + cFSemaf + "]" }
ENDIF

Return(aRet)






/*/{Protheus.doc} NFBolMail
Envia Nota Fiscal + Boleto por e-mail
@author Augusto Ribeiro | www.compila.com.br
@since 07/09/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function NFBolMail()
Local aRet			:= {.f.,""}
Local cQuery 		:= ""
Local cJoin 		:= ""
Local cWhere 		:= ""
Local dDtCorte	//	:= 
Local cPathPDF		:= GETMV( "CP15_PDFNF", .F., "\data_custom\pdf_nf_boleto\" )
Local cNewPath		:= ""
Local aRetAux
Local cFSemaf, nHSemaf
Local aDirSave
Local oSetup
Local nDevice		:= IMP_PDF
Local cFileName		:= "DANFE_" + Alltrim( UPPER( cUserName ) ) + "_"+dtos(dDataBase) + "_"+SUBSTR(TIME(), 1, 2) + SUBSTR(TIME(), 4, 2) + SUBSTR(TIME(), 7, 2) + ".PDF"
Local lViewPDF		:= .F.
Local lDisabeSetup	:= .T.
Local cSession     	:= GetPrinterSession()
Local oAux			:= oMainWnd
Local oPrint 
Local lCP15VAUT 	:= EXISTBLOCK("CP15VAUT")
Local lCP15JQRY		:= EXISTBLOCK("CP15JQRY")
Local aRetPE		:= {}

 /*--------------------------
	Abre Semaforo
---------------------------*/
cFSemaf	:= "cp15_nfbolmail"
nHSemaf	:= U_CPXSEMAF( "A", cFSemaf )	

IF nHSemaf > 0
	
	cQuery := " SELECT	A1_COD, A1_LOJA, A1_EMAIL, F2.F2_FILIAL, F2_DOC, F2_SERIE, "			+ CRLF
	cQuery += " 			F2.R_E_C_N_O_ AS SF2_RECNO, F2_XPDFNF, F2_XDTSNF  "				+ CRLF
	cQuery += " FROM 		" + RetSqlName("SF2") + " F2 "										+ CRLF
	
	cJoin += " INNER 	JOIN " + RetSqlName("SA1") + " A1 "									+ CRLF
	cJoin += " 			ON	A1_COD 					= F2_CLIENTE "								+ CRLF
	cJoin += " 			AND A1_LOJA 			= F2_LOJA "										+ CRLF
	cJoin += " 			AND A1_EMAIL 			<> '' "											+ CRLF
	cJoin += " 			AND A1.D_E_L_E_T_ 	<> '*' "												+ CRLF
	
	//cWhere += " WHERE	F2_EMISSAO >= '"+DTOS(GETMV("CP15_WDTNF",.F.,DDATABASE-5))	+	"' "	+ CRLF
	//simulação
	cWhere += " WHERE	F2_EMISSAO >= '20201016' "	+ CRLF
	cWhere += " 		AND F2_CHVNFE 			<> '' "														+ CRLF	//autorizada a nota fiscal
	cWhere += " 		AND F2_XDTSNF 			= '' "														+ CRLF
	//cWhere += " 		AND F2_DOC 				= '065646' "												+ CRLF 	//| ### remover|
	cWhere += " 		AND F2.D_E_L_E_T_ 	<> '*' "														+ CRLF
	cWhere += " 		AND EXISTS (	SELECT 1 AS 'A'  "												+ CRLF
	cWhere += "             			FROM " + RetSqlName( "SE1" ) + " E1   "				+ CRLF
	cWhere += "             			WHERE E1_FILIAL 				= F2_FILIAL  "			+ CRLF
	cWhere += "             					AND E1_NUM 				= F2_DUPL  "					+ CRLF
	cWhere += "             					AND E1_SERIE 			= F2_PREFIXO  "			+ CRLF
	cWhere += "             					AND E1_CLIENTE			= F2_CLIENTE  "			+ CRLF
	cWhere += "             					AND E1_LOJA 			= F2_LOJA  "			+ CRLF
	cWhere += "             					AND E1_TIPO 			= 'NF'  "				+ CRLF
	cWhere += "             					AND E1_IDCNAB 			<> ''  "				+ CRLF	//gerado o bordero
	cWhere += "             					AND E1_NUMBOR 			<> ''  "				+ CRLF	
	cWhere += "             					AND E1_NUMBCO 			<> ''  "				+ CRLF	//gerado o nosso número
	cWhere += "             					AND E1.D_E_L_E_T_ 	<> '*') "					+ CRLF
	
	IF lCP15JQRY
		/*-----------------------------------
			P.E. para alteração da Query
		------------------------------------*/
		aRetPE	:= ExecBlock( "CP15JQRY", .F., .F., { @cJoin, @cWhere } )
		
		cJoin		:= aRetPE[1]
		cWhere	:= aRetPE[2]
	ENDIF
	
	cQuery := cQuery + " " + cJoin + " " + cWhere								+ CRLF
	cQuery += " ORDER BY A1_COD, A1_LOJA, F2.F2_FILIAL, F2_DOC, F2_SERIE "		+ CRLF
	

	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry( ,, cQuery ), "TSQL", .F., .T. )						
		
	IF TSQL->( !EOF() )
		
		Do WHILE TSQL->( !EOF() )
				
			/*------------------------------------------------------ Augusto Ribeiro | 28/10/2019 - 4:55:12 PM
				Ponto de entrada para validar se a NF de gerar boleto automaticamente
			------------------------------------------------------------------------------------------*/
			SF2->( DBGOTO( TSQL->SF2_RECNO ) )
			IF lCP15VAUT
				IF !( ExecBlock( "CP15VAUT", .F., .F. ) )
					TSQL->( DBSKIP() )
					LOOP
				ENDIF
			ENDIF
			
			cFileName		:= "DANFE_" + Alltrim( UPPER( TSQL->F2_DOC ) ) + "_" + dtos( ddatabase ) + "_" + SUBSTR( TIME(), 1, 2 ) + SUBSTR( TIME(), 4, 2 ) + SUBSTR( TIME(), 7, 2 ) + ".PDF"						
			oPrint			:= nil
			oSetup			:= nil
			
			/*--------------------------------------------------------
				GERA NOTA FISCAL E REGISTRA BOLETO
			---------------------------------------------------------*/
			IF EMPTY( TSQL->F2_XPDFNF )
			
				aDirSave		:= DirSave( cPathPDF )
				//aDirSave	:= {.t.,"",cPathPDF}
				IF aDirSave[1]
				
					cNewPath	:= aDirSave[3]
				
					oPrint := FWMSPrinter():New( cFileName, nDevice,.F., cNewPath, lDisabeSetup, @oSetup , , , , , , lViewPDF,  )
					oPrint:SetResolution( 78 ) 	//Tamanho estipulado para a Danfe
					oPrint:SetPortrait()
					oPrint:SetPaperSize( DMPAPER_A4 )
					oPrint:SetMargin( 60, 60, 60, 60 )				 	
					
					
					aDevice	:= {}
					AADD( aDevice, "DISCO" ) // 1
					AADD( aDevice, "SPOOL" ) // 2
					AADD( aDevice, "EMAIL" ) // 3
					AADD( aDevice, "EXCEL" ) // 4
					AADD( aDevice, "HTML"  ) // 5
					AADD( aDevice, "PDF"   ) // 6
				
					nLocal       	:= If( fwGetProfString( cSession, "LOCAL","SERVER", .T. ) 				== "SERVER"		, 1, 2 )
					nOrientation 	:= If( fwGetProfString( cSession, "ORIENTATION", "PORTRAIT", .T. )	== "PORTRAIT"	, 1, 2 )
					cDevice     	:= If( Empty( fwGetProfString( cSession,"PRINTTYPE","SPOOL", .T. ) ), "PDF", fwGetProfString( cSession, "PRINTTYPE", "SPOOL", .T. ) )
					nPrintType     	:= aScan( aDevice,{ |x| x == cDevice } )
										
					nFlags 			:= PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
					
					//gera boleto e danfe
					U_CP15R02A( TSQL->SF2_RECNO, .F., @oPrint, @oSetup, cNewPath )
				
					oPrint:nDevice	:= nDevice
					oPrint:cPathPDF	:= cNewPath
					oPrint:nDevice  := IMP_PDF
				
					oPrint:Print()
				
					IF FILE( cNewPath + cFileName )
					
						DBSELECTAREA( "SF2" )
						SF2->( DBGOTO( TSQL->SF2_RECNO ) )
						
						RECLOCK( "SF2", .F. )				
							SF2->F2_XPDFNF	:= cNewPath + cFileName				
						MSUNLOCK()
						
					ELSE
						aRet[2] := "Falha na geração do arquivo. [NFBolMail]"
					ENDIF
										
				ELSE
					aRet[2] := aDirSave[2]
				ENDIF
			ENDIF
			
			
			
			/*-----------------------------
				ENVIA O BOLETO POR E-MAIL
			------------------------------*/	
			IF EMPTY(TSQL->F2_XDTSNF)
			
		
				aRetAux	:= CP15WNF( TSQL->SF2_RECNO )
				IF aRetAux[1]
					RECLOCK( "SF2", .F. )
						SF2->F2_XDTSNF	:= DATE()
					MSUNLOCK()
				ENDIF
			ELSE
				aRet[1] := .T. 
				aRet[2] := "Nota Fiscal e Boleto enviado. [NFBolMail]"
			ENDIF
			
			TSQL->( DBSKIP() )
		ENDDO 
			
	ELSE	
		aRet[2] := "Nao existem NFs a serem enviadas [NFBolMail]"
	ENDIF
	
	TSQL->( DbCloseArea() )
	
	/*------------------------------------------------------ Augusto Ribeiro | 28/08/2017 - 10:35:02 AM
		Fecha Semaforo
	------------------------------------------------------------------------------------------*/
	IF nHSemaf > 0
		U_CPXSEMAF( "F", cFSemaf, nHSemaf )
	ENDIF	
ELSE 
	aRet[2]	:= "Não foi possivel abrir o semaforo ["+cFSemaf+"]. [NFBolMail]"
ENDIF

Return( aRet )








/*/{Protheus.doc} DirSave
Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
@author Augusto Ribeiro | www.compila.com.br
@since 14/01/2015
@version 1.0
@param ${dDataRef}, ${D}, ${Data de referencia - Utilizado para criar o diretorio onde ser armazenado o arquivo}
@return aRet,  {.F., cMsgErro, cPaths}
/*/
Static Function DirSave(cPath)
Local aRet			:= {.F., "", ""}
Local cAnoMes, cDirComp, cCurDir, nAux
Local aPath, nI
Local cNewPath, aNewPath


/*
#DEFINE DIR_TEMP "\data_braspag\temp\"
#DEFINE DIR_IMPORTADO "\data_braspag\importado\"
*/

IF !EMPTY(cPath)

	cNewPath	:= ALLTRIM(cPath)+LEFT(DTOS(DDATABASE),6)
	
	
	cCurDir	:= CurDir()
	CurDir("\")
	/*------------------------------------------------------ Augusto Ribeiro | 27/11/2016 - 12:42:46 PM
		Verifica se o caminho existe, caso não, cria as pastas
	------------------------------------------------------------------------------------------*/
	IF !ExistDir(cNewPath)
	
		aNewPath	:= StrTokArr(cNewPath, "\" )
		
		FOR nI := 1 to len(aNewPath)
		
			IF ExistDir(aNewPath[nI])
				CurDir(aNewPath[nI])
			ELSE
				nAux	:= MakeDir(aNewPath[nI])
				IF nAux == 0
					CurDir(aNewPath[nI])
				ELSE
					aRet[2] := "Nao foi possivel criar o diretorio ["+CurDir()+"\"+aNewPath[nI]+"]. Cod. Erro: "+alltrim(str(FError()))
					CONOUT("CP15JOB.PRW [DirSave] | "+aRet[2] )
					EXIT
				ENDIF			
			ENDIF
		
		NEXT nI	
	
	ENDIF
	
	
	IF ExistDir(cNewPath)
		aRet[1]	:= .t.
		aRet[3]	:= cNewPath+"\"
	ELSE
		aRet[2] := "Não foi possivel localiar o diretorio ["+cNewPath+"]"
	ENDIF

	CurDir(cCurDir) 	
ENDIF


Return(aRet)

/*/{Protheus.doc} CP15WNF
Funcao para envio da Nota Fiscal e boleto por e-mail
@author Augusto Ribeiro | www.compila.com.br
@since 08/10/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function CP15WNF( nRecSf2, cEmail )
Local aRet			:= { .F., "" }
Local cTipoDesc 	:= ""
Local cCodProc 		:= "CP15_NFBOL"
Local cDescProc		:= "CP15 - Nota Fiscal com boleto"
Local cHTMLModelo	:= "\WORKFLOW\cp15nfbol.html"
Local cSubject		:= GETMV( "CP15_WFTIT",.F., "Nota Fiscal" )
Local cFromName		:= GETMV( "CP15_WFFRO",.F., "NO-REPLY" )
Local cMailAudit	:= GetMv( "CP15_WFAUD",.F.,""  )
Local cMailHom		:= GetMv( "CP15_WFHOM",.F.,"mauro.nagata@compila.com.br"  )
Local cMailLogo		:= GetMv( "CP15_WFLGO",.F.,"http://compila.com.br/wp-content/uploads/2017/07/Logo-10-anos-xs.png"  )
Local lEnvia		:= .F.
Local cQryZ1		:= ""
Local cStatus		:= ""
Local cMesAnt		:= STRZERO( MONTH( DDATABASE )-1, 2 ) 	
Local cMesAtu		:= STRZERO( MONTH( DDATABASE ), 2 )
Local cAno 			:= ALLTRIM( STR( YEAR( DDATABASE ) ) )
Local nY			:= 0 
Local nQtdParc		:= 0 
Local nTotalNeg		:= 0 
Local cMailDest 	:= "" 
Local cQryFil		:= ""
Local cPlacas		:= ""	
Local oProcess, oHtml
Local cFormPg		:= ""
Local lValor		:= .T.

IF nRecSf2 > 0 

	DBSELECTAREA( "SF2" )
	SF2->( DBGOTO( nRecSf2 ) )
	
	IF !EMPTY( SF2->F2_XPDFNF )
	
		cAnexo	:= alltrim( SF2->F2_XPDFNF )

		DBSELECTAREA( "SA1" )
		SA1->( DBSETORDER(1) ) 
		IF SA1->( DBSEEK( xFilial( "SA1" ) + SF2->( F2_CLIENTE + F2_LOJA ) ) ) 
	
		
			IF EMPTY( cMailHom )
				IF !EMPTY( cEmail )
					cMailDest	:= cEmail
				ELSE
					cMailDest 	:= ALLTRIM( SA1->A1_EMAIL )
					If !Empty( cEmailFis )
						cMailDest += ";" + cEmailFis
					EndIf
					If !Empty( cEmailFin )
						cMailDest += ";" + cEmailFin
					EndIf
					
				ENDIF
			ELSE
				cMailDest		:= cMailHom	 //| E-mail de homologacao |
			ENDIF
	
			/*----------------------------------------
				14/03/2017 - Jonatas Oliveira - Compila
				Cria Processo de Workflow
			------------------------------------------*/
			oProcess	:= TWFProcess():New( cCodProc,cDescProc )
			oProcess:NewTask( cDescProc, cHTMLModelo )
	
			oHtml 		:= oProcess:oHtml
			
			oHtml:ValByName( "logoempresa"	,	alltrim( cMailLogo ) )
			oHtml:ValByName( "CCLIENTE"		,	CAPITAL( ALLTRIM( SA1->A1_NOME ) ) )
			oHtml:ValByName( "CPF"			,	IIF( SA1->A1_PESSOA == "J", TRANSFORM( SA1->A1_CGC, "@R 99.999.999/9999-99" ), TRANSFORM( SA1->A1_CGC, "@R 999.999.999-99" ) ) ) 
			oHtml:ValByName( "CODIGO"		,	SA1->( A1_COD + A1_LOJA ) )
	
			oProcess:ClientName( Subs( cUsuario, 7, 15 ) )
			oProcess:cTo 		:= cMailDest
			
			IF !EMPTY(cMailAudit)
				oProcess:cBCC 	:= cMailAudit
			ENDIF 
	
	
			oProcess:cSubject 	:= cSubject
			oProcess:CFROMNAME	:= cFromName
			oProcess:attachfile( cAnexo )
			oProcess:Start()
			oProcess:Free()
			
			aRet[1] := .T.
		ELSE
			aRet[2]	:= "Cliente não localizado"
		ENDIF
	ELSE
		aRet[2]	:= "Não existe PDF gerado para esta NF"
	ENDIF
ELSE
	aRet[2]	:= "Nota Fiscal não localizada"
ENDIF

Return(aRet)


