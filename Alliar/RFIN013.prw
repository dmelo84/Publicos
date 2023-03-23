#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

#Define EOL chr(13)+chr(10)


/*/{Protheus.doc} RFIN013
Relatorio de controle de notas entrada
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
User Function RFIN013()
Local oReport


/*========================================================================
|Interface de impressao
======================================================================== */
oReport := ReportDef()
If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf
oReport:PrintDialog()

Return


/*/{Protheus.doc} ReportDef
MONTA ESTRUTURA DO RELATORIO
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
Static Function ReportDef()

	Local oReport
	Local oSection1	
	Local oBreak
	Local cDescRel
	Local cPerg		:= "RFIN15"


	cDescRel	:= "Relatorio Bordero"+EOL
	cDescRel	+= "Apresenta detalhes dos titulos em Bordeiro"

	oReport := TReport():New("RFIN013","Relatorio Bordero" , cPerg , {|oReport| PrintReport(oReport)} ,cDescRel)
	oReport:SetLandscape()

	oReport:SetTotalInLine(.F.)

	AjustSX1(cPerg)

	/*========================================================================
	| SETOR 1
	======================================================================== */
	oSection1 := TRSection():New(oReport,"Relatorio Bordero",{"SE2"})
	
	TRCell():New(oSection1,'E2_FILIAL', 'TSQL', RETTITLE('E2_FILIAL'),,TAMSX3('E2_FILIAL')[1],.F.)
	TRCell():New(oSection1,'E2_NUM', 'TSQL', RETTITLE('E2_NUM'),,TAMSX3('E2_NUM')[1],.F.)
	TRCell():New(oSection1,'E2_NOMFOR', 'TSQL', RETTITLE('E2_NOMFOR'),,TAMSX3('E2_NOMFOR')[1],.F.)
	TRCell():New(oSection1,'E2_EMISSAO', 'TSQL', RETTITLE('E2_EMISSAO'),,TAMSX3('E2_EMISSAO')[1],.F.)	
	TRCell():New(oSection1,'E2_VENCREA', 'TSQL', RETTITLE('E2_VENCREA'),,TAMSX3('E2_VENCREA')[1],.F.)
	TRCell():New(oSection1,'E2_NUMBOR', 'TSQL', RETTITLE('E2_NUMBOR'),,TAMSX3('E2_NUMBOR')[1],.F.)
	TRCell():New(oSection1,'E2_VALLIQ', 'TSQL', 'Vlr Baixado',"@E 999,999,999.99",TAMSX3('E2_VALLIQ')[1],.F.)
	TRCell():New(oSection1,'E2_SALDO', 'TSQL', 'Vlr Saldo',"@E 999,999,999.99",TAMSX3('E2_VALLIQ')[1],.F.)
	TRCell():New(oSection1,'E2_VALOR', 'TSQL', 'Vlr Titulo',"@E 999,999,999.99",TAMSX3('E2_VALLIQ')[1],.F.)
	
	oSection1:SetTotalText(" ")
	oSection1:SetTotalInLine(.F.)

Return oReport


/*/{Protheus.doc} PrintReport
Faz a impressao do relatorio de acordo com os parametros definidos.
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
Static Function PrintReport(oReport)

	Local oSection1 	:= oReport:Section(1)

	Local nCount		:= 0
	Local nI			:= 1
	Local cCodPrd		:= ""


	Pergunte(oReport:uParam,.F.)


	MsgRun("Processando, Aguarde...","SQL", {|| qEstTer() } )	//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query

	DBSelectArea("TSQL")
	TSQL->(DBGoTop())
	//TSQL->( dbEval( {|| nCount++ } ) )
	//TSQL->(DBGoTop())

	oReport:SetMeter(nCount)

	oReport:SetTitle("Relatorio Controle de Bordero")
	oReport:StartPage()

	oSection1:Init()	

	While TSQL->( !Eof() ) 

		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf

		oSection1:PrintLine()			 							
		TSQL->(DBSKIP())
	ENDDO

	oSection1:Finish()	
	oReport:EndPage()

Return


/*/{Protheus.doc} qEstTer
Monta a Query
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
Static Function qEstTer()
	Local cQuery 	:= ""


	cQuery := " SELECT   "+CRLF
	cQuery += " E2_FILIAL ,   "+CRLF
	cQuery += " E2_NUM ,   "+CRLF
	cQuery += " E2_NOMFOR ,   "+CRLF
	cQuery += " E2_EMISSAO ,   "+CRLF
	cQuery += " E2_VENCREA ,   "+CRLF
	cQuery += " E2_NUMBOR ,   "+CRLF
	cQuery += " E2_VALLIQ,   "+CRLF
	cQuery += " E2_SALDO,   "+CRLF
	cQuery += " E2_VALOR   "+CRLF
	cQuery += " FROM "+CRLF
	cQuery += " SE2010 "+CRLF
	cQuery += " WHERE  "+CRLF
	cQuery += " E2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  "+CRLF
	cQuery += " AND E2_DTBORDE BETWEEN '"+DTOS(mv_par03)+"' AND '"+DTOS(mv_par04)+"' "+CRLF
	cQuery += " AND E2_NUMBOR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "+CRLF 
	cQuery += " AND D_E_L_E_T_ = '' "+CRLF
	cQuery += " ORDER BY E2_FILIAL , E2_NUM, E2_NUMBOR "+CRLF
	
	
	
	MemoWrite(GetTempPath(.T.) + "RFIN013.SQL", cQuery)		

	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TSQL", .F., .T.)

TCSetField("TSQL","E2_EMISSAO","D",08,00)
TCSetField("TSQL","E2_VENCREA","D",08,00)	

Return()


/*/{Protheus.doc} AjustSX1
Ajusta as Perguntas.  
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
Static Function AjustSX1(cPerg)
	Local aArea := GetArea()
	Local aHelpPor	:= {}
	Local aHelpEng 	:= {}
	Local aHelpSpa	:= {}

	aAdd( aHelpEng, "  ")
	aAdd( aHelpSpa, "  ")
	
	
	
	    aHelpPor := {} ; Aadd( aHelpPor, "Filial De")
		PutSx1( cPerg, "01","Filial De"	,"","","mv_ch1","C",len(xfilial()),0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
		
		aHelpPor := {} ; Aadd( aHelpPor, "Filial Ate")
		PutSx1( cPerg, "02","Filial Ate","","","mv_ch2","C",len(xfilial()),0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
		aHelpPor := {} ; Aadd( aHelpPor, "Dt. Bordero De")
		PutSx1(cPerg,"03","Data Bordero De?"		 	,"Data Bordero De?"		,"Data Bordero De?"			,"mv_ch1","D",08					,00,0,"G","NaoVazio"			,""		,""	,"","mv_par03",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
		aHelpPor := {} ; Aadd( aHelpPor, "Dt. Bordero Ate")
		PutSx1(cPerg,"04","Data Bordero Ate ?"			,"Data Bordero Ate?"	,"Data Bordero Ate?"		,"mv_ch2","D",08					,00,0,"G","NaoVazio"			,""		,""	,"","mv_par04",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
		
			
		aHelpPor := {} ; Aadd( aHelpPor, "Bordero De")
		PutSx1(cPerg,"05","Cod. Bordero De?"		 	,"Cod. Bordero De?"		,"Cod. Bordero De?"			,"mv_chg","C",TAMSX3("E2_NUMBOR")[1],00,0,"G",""					,""		,""	,"","mv_par05",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

		aHelpPor := {} ; Aadd( aHelpPor, "Bordero Ate")
		PutSx1(cPerg,"06","Cod. Bordero Ate?"		 	,"Cod. Bordero Ate?"	,"Cod. Bordero Ate?"		,"mv_chh","C",TAMSX3("E2_NUMBOR")[1],00,0,"G",""					,""		,""	,"","mv_par06",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )



Return()
