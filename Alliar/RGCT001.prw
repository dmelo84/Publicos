#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define EOL chr(13)+chr(10)


/*/{Protheus.doc} RELSE1
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
User Function RGCT001()
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
	Local cPerg		:= "RGCT001"


	//CriaSx1(cPerg)

	cDescRel	:= "Relatorio de Contratos"+EOL
	cDescRel	+= "Apresenta dados conforme parametros informados"

	oReport := TReport():New("RGCT001","Relatorio Contratos" , cPerg , {|oReport| PrintReport(oReport)} ,cDescRel)
	oReport:SetLandscape()

	oReport:SetTotalInLine(.F.)


	/*========================================================================
	| SETOR 1
	======================================================================== */
	oSection1 := TRSection():New(oReport,"CN9",{"CN9"})


	TRCell():New(oSection1,'CN9_FILIAL ', 'TSQL',RETTITLE('CN9_FILIAL '),,TAMSX3('CN9_FILIAL  ')[1],.F.)
	TRCell():New(oSection1,'CN9_NUMERO  ', 'TSQL',RETTITLE('CN9_NUMERO'),,TAMSX3('CN9_NUMERO')[1],.F.)
	TRCell():New(oSection1,'CN9_DTINIC ', 'TSQL',RETTITLE('CN9_DTINIC '),,TAMSX3('CN9_DTINIC ')[1],.F.)
	TRCell():New(oSection1,'CN9_DTFIM  ', 'TSQL',RETTITLE('CN9_DTFIM  '),,TAMSX3('CN9_DTFIM  ')[1],.F.)
	TRCell():New(oSection1,'CN1_CODIGO', 'TSQL',RETTITLE('CN1_CODIGO '),,TAMSX3('CN1_CODIGO ')[1],.F.)
	TRCell():New(oSection1,'CN1_DESCRI', 'TSQL',RETTITLE('CN1_DESCRI '),,TAMSX3('CN1_DESCRI ')[1],.F.)
	TRCell():New(oSection1,'CN9_NATURE', 'TSQL',RETTITLE('CN9_NATURE '),,TAMSX3('CN9_NATURE ')[1],.F.)
	TRCell():New(oSection1,'ED_DESCRIC', 'TSQL',RETTITLE('ED_DESCRIC '),,TAMSX3('ED_DESCRIC ')[1],.F.)
	TRCell():New(oSection1,'CN9_UNVIGE', 'TSQL',RETTITLE('CN9_UNVIGE '),,TAMSX3('CN9_UNVIGE ')[1],.F.) //VERIFICAR TIPO
	TRCell():New(oSection1,'CN9_VIGE', 'TSQL',RETTITLE('CN9_VIGE'),,TAMSX3('CN9_VIGE')[1],.F.)
	TRCell():New(oSection1,'CNA_VLTOT', 'TSQL',RETTITLE('CNA_VLTOT'),"@E 999,999,999.99",TAMSX3('CNA_VLTOT')[1],.F.)
	TRCell():New(oSection1,'CN9_SALDO', 'TSQL','SALDO CN9',"@E 999,999,999.99",TAMSX3('CN9_SALDO')[1],.F.)
	TRCell():New(oSection1,'CN9_SITUAC', 'TSQL',RETTITLE('CN9_SITUAC'),,TAMSX3('CN9_SITUAC ')[1],.F.)
	TRCell():New(oSection1,'CNA_SALDO', 'TSQL','SALDO CNA',"@E 999,999,999.99",TAMSX3('CNA_SALDO')[1],.F.)
	TRCell():New(oSection1,'CNA_FORNEC', 'TSQL',RETTITLE('CNA_FORNEC '),,TAMSX3('CNA_FORNEC ')[1],.F.)
	TRCell():New(oSection1,'CNA_LJFORN', 'TSQL',RETTITLE('CNA_LJFORN '),,TAMSX3('CNA_LJFORN ')[1],.F.)
	TRCell():New(oSection1,'A2_NOME', 'TSQL',RETTITLE('A2_NOME'),,TAMSX3('A2_NOME')[1],.F.)
	TRCell():New(oSection1,'CN9_DTREV', 'TSQL',RETTITLE('CN9_DTREV '),,TAMSX3('CN9_DTREV')[1],.F.)
	TRCell():New(oSection1,'CNA_NUMERO', 'TSQL',RETTITLE('CNA_NUMERO'),,TAMSX3('CNA_NUMERO')[1],.F.)
	TRCell():New(oSection1,'CNA_CRONOG', 'TSQL',RETTITLE('CNA_CRONOG '),,TAMSX3('CNA_CRONOG ')[1],.F.)


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

	oReport:SetTitle("Relatorio Contratos")
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


    cQuery := " SELECT 										                                     "+CRLF
    cQuery += " CN9_FILIAL,                                                                      "+CRLF
	cQuery += "	CN9_NUMERO,                                                                      "+CRLF
	cQuery += "	CN9_REVISA,                                                                      "+CRLF
	cQuery += "	CN9_DTINIC ,                                                                     "+CRLF
	cQuery += "	CN9_DTFIM ,                                                                      "+CRLF
	cQuery += "	CN1_CODIGO ,CN1_DESCRI,                                                          "+CRLF
	cQuery += "	CN9_NATURE,                                                                      "+CRLF
	cQuery += "	ED_DESCRIC,                                                                      "+CRLF
	cQuery += "	CASE CN9_UNVIGE                                                                  "+CRLF
	cQuery += "		WHEN 1 THEN 'DIAS'                                                           "+CRLF
	cQuery += "		WHEN 2 THEN 'MESES'                                                          "+CRLF
	cQuery += "		ELSE 'ANOS'                                                                  "+CRLF
	cQuery += "	END CN9_UNVIGE,                                                                  "+CRLF
	cQuery += "	CN9_VIGE,                                                                        "+CRLF
	cQuery += "	CNA_VLTOT,                                                                       "+CRLF
	cQuery += "	CN9_SALDO ,                                                                      "+CRLF
	cQuery += "	CASE CN9_SITUAC                                                                  "+CRLF
	cQuery += "		WHEN '01' THEN 'Cancelado'                                                   "+CRLF
	cQuery += "		WHEN '02' THEN 'Elaboração'                                                  "+CRLF
	cQuery += "		WHEN '03' THEN 'Emitido'                                                     "+CRLF
	cQuery += "		WHEN '04' THEN 'Aprovação'                                                   "+CRLF
	cQuery += "		WHEN '05' THEN 'Vigente'                                                     "+CRLF
	cQuery += "		WHEN '06' THEN 'Paralisa.'                                                   "+CRLF
	cQuery += "		WHEN '07' THEN 'Sol. Finalização'                                            "+CRLF
	cQuery += "		WHEN '08' THEN 'Finali.'                                                     "+CRLF
	cQuery += "		WHEN '09' THEN 'Revisão'                                                     "+CRLF
	cQuery += "		ELSE 'Revisado'                                                              "+CRLF
	cQuery += "	END CN9_SITUAC,                                                                  "+CRLF
	cQuery += "	CNA.CNA_SALDO CNA_SALDO,                                                         "+CRLF
	cQuery += "	CNA.CNA_FORNEC,                                                                  "+CRLF
	cQuery += "	CNA.CNA_LJFORN,                                                                  "+CRLF
	cQuery += "	SA2.A2_NOME,                                                                     "+CRLF
	cQuery += "	CN9_DTREV,                                                                       "+CRLF
	cQuery += "	CNA.CNA_NUMERO CNA_NUMERO,                                                       "+CRLF
	cQuery += "	CNA.CNA_CRONOG                                                                   "+CRLF
	cQuery += "	FROM CN9010 CN9                                                                  "+CRLF
	cQuery += "	     LEFT JOIN CN1010 CN1 ON                                                     "+CRLF
	cQuery += "		 CN1.CN1_CODIGO= CN9.CN9_TPCTO AND                                           "+CRLF
	cQuery += "		 CN1.D_E_L_E_T_=''                                                           "+CRLF
	cQuery += "		LEFT JOIN CNA010 CNA ON                                                      "+CRLF
	cQuery += "			CNA.CNA_FILIAL = CN9.CN9_FILIAL AND                                      "+CRLF
	cQuery += "	        CNA.CNA_CONTRA = CN9.CN9_NUMERO AND                                      "+CRLF
	cQuery += "	        CNA.CNA_REVISA = CN9.CN9_REVISA AND                                      "+CRLF
	cQuery += "			CNA.D_E_L_E_T_ =''	                                                     "+CRLF
	cQuery += "		LEFT JOIN SA2010 SA2 ON                                                      "+CRLF
	cQuery += "			CNA.CNA_FORNEC = SA2.A2_COD AND                                          "+CRLF
	cQuery += "			CNA.CNA_LJFORN = SA2.A2_LOJA AND                                         "+CRLF
	cQuery += "			SA2.D_E_L_E_T_ =''                                                       "+CRLF
	cQuery += "		LEFT JOIN SED010 SED ON                                                      "+CRLF
	cQuery += "	    SED.ED_CODIGO = CN9.CN9_NATURE AND                                      	     "+CRLF
	cQuery += "	    SED.D_E_L_E_T_=''   	                                                		     "+CRLF
	cQuery += "				WHERE CN9.D_E_L_E_T_ =''AND CN9.CN9_FILIAL BETWEEN '"+MV_PAR01+"'AND '"+MV_PAR02+"'  AND    "+CRLF
	cQuery += "                                         CN9.CN9_NUMERO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND     "+CRLF
    cQuery += "				 (CN9.CN9_REVISA =(SELECT MAX(CN9_REVISA)                           	 "+CRLF
	cQuery += "										FROM CN9010 A                                "+CRLF
	cQuery += "										WHERE A.CN9_FILIAL =CN9.CN9_FILIAL           "+CRLF
	cQuery += "										AND A.CN9_NUMERO =CN9.CN9_NUMERO             "+CRLF
	cQuery += "										AND A.CN9_REVISA= CN9.CN9_REVISA )           "+CRLF
	cQuery += "				)                                                                    "+CRLF


  	MemoWrite(GetTempPath(.T.) + "RGCT001.SQL", cQuery)

	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TSQL", .F., .T.)

	TCSetField("TSQL","CN9_DTFIM","D",08,00)
	TCSetField("TSQL","CN9_DTINIC","D",08,00)
	TCSetField("TSQL","CN9_DTREV","D",08,00)



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



Return()

