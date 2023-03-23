#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define EOL chr(13)+chr(10)


/*/{Protheus.doc} RELREINF
Relatorio de controle de notas entrada
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
User Function RELREINF()
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
	Local cPerg		:= "RELREINF"


	cDescRel	:= "REINF"+EOL
	cDescRel	+= "Apresenta dados para validação da REFIN"

	oReport := TReport():New("RELREINF","Relatorio Reinf" , cPerg , {|oReport| PrintReport(oReport)} ,cDescRel)
	oReport:SetLandscape()

	oReport:SetTotalInLine(.F.)

	AjustSX1(cPerg)

	/*========================================================================
	| SETOR 1
	======================================================================== */
	oSection1 := TRSection():New(oReport,"REINF",{"T95"})


	TRCell():New(oSection1,'T95_FILIAL', 'TSQL', RETTITLE('T95_FILIAL'),,TAMSX3('T95_FILIAL')[1],.F.)
	TRCell():New(oSection1,'T95_VERSAO', 'TSQL', RETTITLE('T95_VERSAO'),,TAMSX3('T95_VERSAO')[1],.F.)
	TRCell():New(oSection1,'T97_NUMDOC', 'TSQL', RETTITLE('T97_NUMDOC'),,TAMSX3('T97_NUMDOC')[1],.F.)
	TRCell():New(oSection1,'T97_TPSERV', 'TSQL', RETTITLE('T97_TPSERV'),,TAMSX3('T97_TPSERV')[1],.F.)
	TRCell():New(oSection1,'T97_CODSER', 'TSQL', RETTITLE('T97_CODSER'),,TAMSX3('T97_CODSER')[1],.F.)
	TRCell():New(oSection1,'T95_PERAPU', 'TSQL', RETTITLE('T95_PERAPU'),,TAMSX3('T95_PERAPU')[1],.F.)
	TRCell():New(oSection1,'T97_DTPSER', 'TSQL', RETTITLE('T97_DTPSER'),,TAMSX3('T97_DTPSER')[1],.F.)
	TRCell():New(oSection1,'T97_VLRBAS', 'TSQL', RETTITLE('T97_VLRBAS'),"@E 999,999,999.99",TAMSX3('T97_VLRBAS')[1],.F.)
	TRCell():New(oSection1,'T97_VLRRET', 'TSQL', RETTITLE('T97_VLRRET'),"@E 999,999,999.99",TAMSX3('T97_VLRRET')[1],.F.)
	TRCell():New(oSection1,'T97_VLRS25 ', 'TSQL', RETTITLE('T97_VLRS25 '),"@E 999,999,999.99",TAMSX3('T97_VLRS25 ')[1],.F.)


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

	oReport:SetTitle("Relatorio Reinf")
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

    cQuery:=" SELECT DISTINCT "+CRLF
    cQuery += " T95_FILIAL,      "+CRLF
	cQuery += " T95_VERSAO,      "+CRLF
	cQuery += " T97_NUMDOC,   "+CRLF
	cQuery += " T97_TPSERV,  "+CRLF
	cQuery += " T97_CODSER,  "+CRLF
	cQuery += " T97_DTPSER, "+CRLF
	cQuery += " T97_VLRBAS,   "+CRLF
	cQuery += " T97_VLRRET,     "+CRLF
	cQuery += " T95_PERAPU,   "+CRLF
	cQuery += " T97_VLRS25   "+CRLF
	cQuery += " FROM T97010 "+CRLF
	cQuery += " INNER JOIN T95010 "+CRLF
	cQuery += " ON T95_VERSAO =T97_VERSAO    "+CRLF
	cQuery += " AND T97_FILIAL = T95_FILIAL     "+CRLF
	cQuery += " WHERE T95_PERAPU='"+MV_PAR03+"' AND T95_ATIVO='1' AND T95010.D_E_L_E_T_='' AND T97010.D_E_L_E_T_=''      "+CRLF
	cQuery += "	 AND T95_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
	cQuery += " ORDER BY  T95_FILIAL, T97_NUMDOC   "+CRLF



	MemoWrite(GetTempPath(.T.) + "RELTAF.SQL", cQuery)


	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TSQL", .F., .T.)



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

	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao De")
	PutSx1(cPerg,"03","Periodo Apu ?"		 	,"Periodo Apu"		,"Periodo Apu"			,"mv_ch3","D",06,00,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )



Return()
