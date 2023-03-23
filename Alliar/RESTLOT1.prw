#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define EOL chr(13)+chr(10)


/*/{Protheus.doc} RESTLOT1
Relatorio de controle lote
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
User Function RESTLOT1()
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
	Local cPerg		:= "RESTLOT"


	cDescRel	:= "Controle de Lote"+EOL
	cDescRel	+= "Apresenta controle de LOTE conforme parametros informados"

	oReport := TReport():New("RESTLOT","Controle de lote" , cPerg , {|oReport| PrintReport(oReport)} ,cDescRel)
	oReport:SetLandscape()

	oReport:SetTotalInLine(.F.)

	AjustSX1(cPerg)

	/*========================================================================
	| SETOR 1
	======================================================================== */
	oSection1 := TRSection():New(oReport,"S.A x Lote",{"SB8"})

	TRCell():New(oSection1,'CP_FILIAL', 'TSQL', RETTITLE('CP_FILIAL'),,TAMSX3('CP_FILIAL')[1],.F.)
	TRCell():New(oSection1,'CP_NUM', 'TSQL', RETTITLE('CP_NUM'),,TAMSX3('CP_NUM')[1],.F.)
	TRCell():New(oSection1,'CP_EMISSAO', 'TSQL', RETTITLE('CP_EMISSAO'),,TAMSX3('CP_EMISSAO')[1],.F.)
	TRCell():New(oSection1,'CP_CC', 'TSQL', RETTITLE('CP_CC'),,TAMSX3('CP_CC')[1],.F.)
	TRCell():New(oSection1,'CTT_DESC01', 'TSQL', RETTITLE('CTT_DESC01'),,TAMSX3('CTT_DESC01')[1],.F.)
	TRCell():New(oSection1,'CP_STATUS', 'TSQL', RETTITLE('CP_STATUS'),,TAMSX3('CP_STATUS')[1],.F.)
	TRCell():New(oSection1,'CP_PRODUTO', 'TSQL', RETTITLE('CP_PRODUTO'),,TAMSX3('CP_PRODUTO')[1],.F.)
	TRCell():New(oSection1,'CP_DESCRI', 'TSQL', RETTITLE('CP_DESCRI'),,TAMSX3('CP_DESCRI')[1],.F.)
	TRCell():New(oSection1,'CP_UM', 'TSQL', RETTITLE('CP_UM'),,TAMSX3('CP_UM')[1],.F.)
	TRCell():New(oSection1,'CP_QUANT', 'TSQL', RETTITLE('CP_QUANT'),,TAMSX3('CP_QUANT')[1],.F.)
	TRCell():New(oSection1,'B8_QTDORI', 'TSQL', RETTITLE('B8_QTDORI'),,TAMSX3('B8_QTDORI')[1],.F.)
	TRCell():New(oSection1,'B8_LOTECTL', 'TSQL', RETTITLE('B8_LOTECTL'),,TAMSX3('B8_LOTECTL')[1],.F.)
	TRCell():New(oSection1,'B8_DTVALID', 'TSQL', RETTITLE('B8_DTVALID'),,TAMSX3('B8_DTVALID')[1],.F.)
	TRCell():New(oSection1,'B8_LOTEFOR', 'TSQL', RETTITLE('B8_LOTEFOR'),,TAMSX3('B8_LOTEFOR')[1],.F.)
	TRCell():New(oSection1,'B8_SALDO', 'TSQL', RETTITLE('B8_SALDO'),,TAMSX3('B8_SALDO')[1],.F.)
	TRCell():New(oSection1,'CP_QUJE', 'TSQL', RETTITLE('CP_QUJE'),,TAMSX3('CP_QUJE')[1],.F.)


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

	oReport:SetTitle("Relatorio controle de LOTE")
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
	cQuery :=  "  SELECT      CP_FILIAL,                                                                 "+CRLF
	cQuery +=  "	          CP_NUM,                                                                 "+CRLF
	cQuery +=  "	          CP_EMISSAO,                                                             "+CRLF
	cQuery +=  "	          CP_CC,                                                                  "+CRLF
	cQuery +=  "	          CTT_DESC01,                                                             "+CRLF
	cQuery +=  "	          CP_STATUS,                                                              "+CRLF
	cQuery +=  "	   	   CP_PRODUTO,                                                              "+CRLF
	cQuery +=  "	   	   CP_DESCRI,                                                               "+CRLF
	cQuery +=  "	   	   CP_UM,                                                                   "+CRLF
	cQuery +=  "	   	   CP_QUANT,                                                                "+CRLF
	cQuery +=  "	   	   B8_QTDORI,                                                               "+CRLF
	cQuery +=  "	          B8_LOTECTL,                                                             "+CRLF
	cQuery +=  "	          B8_DTVALID,                                                             "+CRLF
	cQuery +=  "	          B8_LOTEFOR,                                                             "+CRLF
	cQuery +=  "	          B8_SALDO,                                                               "+CRLF
	cQuery +=  "	          CP_QUJE                                                                 "+CRLF
	cQuery +=  "	                                                                                  "+CRLF
	cQuery +=  "	    FROM SCP010 LEFT JOIN SB8010                                                  "+CRLF
	cQuery +=  "	     ON B8_FILIAL=CP_FILIAL AND                                                   "+CRLF
	cQuery +=  "	   		B8_PRODUTO=CP_PRODUTO AND                                               "+CRLF
	cQuery +=  "	   		CP_LOCAL=B8_LOCAL AND SB8010.D_E_L_E_T_=''                              "+CRLF
	cQuery +=  "	                                                                                  "+CRLF
	cQuery +=  "	      LEFT JOIN CTT010                                                            "+CRLF
	cQuery +=  "	       ON CP_CC=CTT_CUSTO AND                                                     "+CRLF
	cQuery +=  "	          CTT_FILIAL=CP_FILIAL AND CTT010.D_E_L_E_T_=''                           "+CRLF
	cQuery +=  "	       LEFT JOIN SB2010                                                           "+CRLF
	cQuery +=  "	       ON B2_FILIAL=CP_FILIAL AND                                                 "+CRLF
	cQuery +=  "	          B2_COD=CP_PRODUTO AND                                                   "+CRLF
	cQuery +=  "	         CP_LOCAL=B2_LOCAL AND SB2010.D_E_L_E_T_=''                               "+CRLF
	cQuery +=  "	                                                                                  "+CRLF
	cQuery += "	 		WHERE CP_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' 						"+CRLF
	cQuery += "	 		AND CP_NUM BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'		            "+CRLF
	cQuery += "	 		AND CP_EMISSAO BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"'    "+CRLF




	MemoWrite(GetTempPath(.T.) + "RESTLOT1.SQL", cQuery)

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

	aHelpPor := {} ; Aadd( aHelpPor, "Num SC De ? ")
	PutSx1(cPerg,"03","Num SC De?"		 	,"Num SA De?"		,"Num SA De?"			,"mv_ch3","C",06,00,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Num SC Ate")
	PutSx1(cPerg,"04","Num SC Ate?"			,"Num SA Ate?"	,"Num SA Ate?"		,"mv_ch4","C",06,00,0,"G","NaoVazio","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao De")
	PutSx1(cPerg,"05","Data Emissao De?"		 	,"Data Emissao De?"		,"Data Emissao De?"			,"mv_ch5","D",08,00,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao Ate")
	PutSx1(cPerg,"06","Data Emissao Ate ?"			,"Data Emissao Ate?"	,"Data Emissao Ate?"		,"mv_ch6","D",08,00,0,"G","NaoVazio","","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )




Return()
