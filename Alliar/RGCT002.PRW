#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define EOL chr(13)+chr(10)


/*/{Protheus.doc} RGCT002
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
User Function RGCT002()
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
	Local cPerg		:= "RGCT002"


	//CriaSx1(cPerg)

	cDescRel	:= "Relatorio de Contratos"+EOL
	cDescRel	+= "Apresenta dados conforme parametros informados"

	oReport := TReport():New("RGCT002","Relatorio Contratos" , cPerg , {|oReport| PrintReport(oReport)} ,cDescRel)
	oReport:SetLandscape()

	oReport:SetTotalInLine(.F.)


	/*========================================================================
	| SETOR 1
	======================================================================== */
	oSection1 := TRSection():New(oReport,"CN9",{"CN9"})


	TRCell():New(oSection1,'CN9_FILIAL', 'TSQL',RETTITLE('CN9_FILIAL'),,TAMSX3('CN9_FILIAL')[1],.F.)
	TRCell():New(oSection1,'ZK_FILNOM', 'TSQL',RETTITLE('ZK_FILNOM'),,TAMSX3('ZK_FILNOM')[1],.F.)
	TRCell():New(oSection1,'CN9_NUMERO', 'TSQL',RETTITLE('CN9_NUMERO'),,TAMSX3('CN9_NUMERO')[1],.F.)
	TRCell():New(oSection1,'CN9_DTINIC', 'TSQL',RETTITLE('CN9_DTINIC'),,TAMSX3('CN9_DTINIC')[1],.F.)
	TRCell():New(oSection1,'CN9_TPCTO', 'TSQL',RETTITLE('CN9_TPCTO'),,TAMSX3('CN9_TPCTO')[1],.F.)
	TRCell():New(oSection1,'CN1_DESCRI', 'TSQL',RETTITLE('CN1_DESCRI'),,TAMSX3('CN1_DESCRI')[1],.F.)
	TRCell():New(oSection1,'CNA_FORNEC', 'TSQL',RETTITLE('CNA_FORNEC'),,TAMSX3('CNA_FORNEC')[1],.F.)
	TRCell():New(oSection1,'CNA_LJFORN', 'TSQL',RETTITLE('CNA_LJFORN'),,TAMSX3('CNA_LJFORN')[1],.F.)
	TRCell():New(oSection1,'A2_NOME', 'TSQL',RETTITLE('A2_NOME'),,TAMSX3('A2_NOME')[1],.F.)



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

	oReport:SetTitle("Aniversario de Contratos")
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

//	MV_PAR01 := ""
//	MV_PAR02 := "ZZZZZZZZZZZZZZZZ"
//	MV_PAR03 := ""
//	MV_PAR04 := "ZZZZZZZZZZZ"
//	MV_PAR05 := DDATABASE
//	MV_PAR06 := DDATABASE

	MV_PAR06 := DaySub( MV_PAR06 , 275 )
	MV_PAR05 := DaySub( MV_PAR05 , 275 )

	cQuery := " SELECT "+CRLF
	cQuery += " 	CN9_FILIAL, "+CRLF
	cQuery += " 	ZK_FILNOM, "+CRLF
	cQuery += " 	CN9_NUMERO, "+CRLF
	cQuery += " 	CN9_DTINIC, "+CRLF
	cQuery += " 	CN9_TPCTO, "+CRLF
	cQuery += " 	CN1_DESCRI, "+CRLF
	cQuery += " 	CNA_FORNEC, "+CRLF
	cQuery += " 	CNA_LJFORN, "+CRLF
	cQuery += " 	A2_NOME "+CRLF

	cQuery += " FROM CN9010 CN9 "+CRLF

	cQuery += " LEFT JOIN CNA010 CNA "+CRLF
	cQuery += " 	ON CNA_FILIAL = CN9_FILIAL "+CRLF
	cQuery += " 	AND CNA_CONTRA = CN9_NUMERO "+CRLF
	cQuery += " 	AND CNA_REVISA = CN9_REVISA "+CRLF
	cQuery += " 	AND CNA.D_E_L_E_T_ = '' "+CRLF

	cQuery += " INNER JOIN SA2010 A2 "+CRLF
	cQuery += " 	ON CNA_FORNEC = A2_COD"+CRLF
	cQuery += " 	AND CNA_LJFORN = A2_LOJA "+CRLF
	cQuery += " 	AND A2.D_E_L_E_T_ = '' "+CRLF

    cQuery += "LEFT JOIN CN1010 CN1           "+CRLF
    cQuery += "	ON CN1_CODIGO = CN9_TPCTO    "+CRLF
    cQuery += "	AND CN1.D_E_L_E_T_=''      "+CRLF

    cQuery += "LEFT JOIN SZK010 SZK           "+CRLF
    cQuery += "	ON ZK_CODFIL =CN9_FILIAL   "+CRLF
    cQuery += "	AND SZK.D_E_L_E_T_=''      "+CRLF



	cQuery += " WHERE CN9_UNVIGE = '4'"+CRLF
	cQuery += " 	AND CN9_DTINIC BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' "+CRLF
	cQuery += " 	AND CN9_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF

	//		cQuery := ChangeQuery(cQuery)

	MemoWrite(GetTempPath(.T.) + "RGCT002.SQL", cQuery)

	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TSQL", .F., .T.)

	TCSetField("TSQL","CN9_DTINIC","D",08,00)




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

	aHelpPor := {} ; Aadd( aHelpPor, "Num.Contrato")
	PutSx1(cPerg,"03","Num.Contrato De?"		 	,"Num.Contrato De?"		,"Num.Contrato De?"			,"mv_ch3","G",15,00,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Num.Contrato Ate")
	PutSx1(cPerg,"04","Num.Contrato Ate ?"			,"Num.Contrato Ate?"	,"Num.Contrato Ate?"		,"mv_ch4","G",15,00,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Referencia De")
	PutSx1(cPerg,"03","Data Referencia De?"		 	,"Data Referencia De?"		,"Data Referencia De?"			,"mv_ch5","D",08,00,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Referencia Ate")
	PutSx1(cPerg,"04","Data Referencia Ate ?"			,"Data Referencia Ate?"	,"Data Referencia Ate?"		,"mv_ch6","D",08,00,0,"G","NaoVazio","","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )


Return()

