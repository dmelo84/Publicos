#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define EOL chr(13)+chr(10)


/*/{Protheus.doc} RFIS001
Relatorio de controle de notas entrada
@author Eduardo Duarte Ferreira
@since 31/12/2016
@version 1.0
/*/
User Function RFIS001()
Local oReport


/*========================================================================
|Interface de impressao
========================================================================*/
oReport := ReportDef()
If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf
oReport:PrintDialog()

Return


/*/{Protheus.doc} ReportDef
MONTA ESTRUTURA DO RELATORIO
@author Eduardo Duarte | Alliar
@since 03/01/2018
@version 1.0
/*/
Static Function ReportDef()

	Local oReport
	Local oSection1
	Local oBreak
	Local cDescRel
	Local cPerg		:= "RFIS001"


	cDescRel	:= "Notas de Entrada"+EOL
	cDescRel	+= "Apresenta controle de notas de entrada com CGC/CPF conforme parametros informados"

	oReport := TReport():New("RFIS001","Notas de Entrada" , cPerg , {|oReport| PrintReport(oReport)} ,cDescRel)
	oReport:SetLandscape()

	oReport:SetTotalInLine(.F.)

	AjustSX1(cPerg)

	/*========================================================================
	| SETOR 1
	======================================================================== */
	oSection1 := TRSection():New(oReport,"Notas de Entrada",{"SF1"})

	TRCell():New(oSection1,'F1_XIDFLG', 'TSQL', RETTITLE('F1_XIDFLG'),,TAMSX3('F1_XIDFLG')[1],.F.)
	TRCell():New(oSection1,'A2_NOME', 'TSQL', 'FORNECEDOR',,TAMSX3('A2_NOME')[1],.F.)
	TRCell():New(oSection1,'A2_EST', 'TSQL', 'Estadp',,TAMSX3('A2_EST')[1],.F.)
	TRCell():New(oSection1,'A2_COD_MUN', 'TSQL', 'Cod.Municipio',,TAMSX3('A2_COD_MUN')[1],.F.)
	TRCell():New(oSection1,'A2_MUN', 'TSQL', 'Desc Municipio',,TAMSX3('A2_MUN')[1],.F.)
	TRCell():New(oSection1,'F1_FILIAL', 'TSQL', RETTITLE('F1_FILIAL'),,TAMSX3('F1_FILIAL')[1],.F.)
	TRCell():New(oSection1,'A2_CGC', 'TSQL', RETTITLE('A2_CGC'),,TAMSX3('A2_CGC')[1],.F.)
	TRCell():New(oSection1,'E2_NATUREZ', 'TSQL', 'NATUREZA',,TAMSX3('E2_NATUREZ')[1],.F.)
	TRCell():New(oSection1,'ED_DESCRIC', 'TSQL', 'DESCRIÇÃO NATUREZA',,TAMSX3('ED_DESCRIC')[1],.F.)
	TRCell():New(oSection1,'D1_TES', 'TSQL', 'TES',,TAMSX3('D1_TES')[1],.F.)
	TRCell():New(oSection1,'D1_COD', 'TSQL', 'COD',,TAMSX3('D1_COD')[1],.F.)
	TRCell():New(oSection1,'F1_ESPECIE', 'TSQL', 'TIPO DO DOCUMENTO',,TAMSX3('F1_ESPECIE')[1],.F.)
	TRCell():New(oSection1,'F1_DOC', 'TSQL', 'NOTA FISCAL',,TAMSX3('F1_DOC')[1],.F.)
	//TRCell():New(oSection1,'F1_SERIE', 'TSQL', RETTITLE('F1_SERIE'),,TAMSX3('F1_SERIE')[1],.F.)
	TRCell():New(oSection1,'E2_CODRET', 'TSQL', RETTITLE('E2_CODRET'),,TAMSX3('E2_CODRET')[1],.F.)
	TRCell():New(oSection1,'F1_EMISSAO', 'TSQL', RETTITLE('F1_EMISSAO'),,TAMSX3('F1_EMISSAO')[1],.F.)
	TRCell():New(oSection1,'F1_DTDIGIT', 'TSQL', RETTITLE('F1_DTDIGIT'),,TAMSX3('F1_DTDIGIT')[1],.F.)
	TRCell():New(oSection1,'E2_BAIXA', 'TSQL', RETTITLE('E2_BAIXA'),,TAMSX3('E2_BAIXA')[1],.F.)
	TRCell():New(oSection1,'D1_TOTAL', 'TSQL', RETTITLE('D1_TOTAL'),"@E 999,999,999.99",TAMSX3('D1_TOTAL')[1],.F.)
	TRCell():New(oSection1,'E2_BASEISS', 'TSQL', RETTITLE('E2_BASEISS'),"@E 999,999,999.99",TAMSX3('E2_BASEISS')[1],.F.)
	TRCell():New(oSection1,'D1_ALIQISS', 'TSQL', RETTITLE('D1_ALIQISS'),"@E 999,999,999.99",TAMSX3('D1_ALIQISS')[1],.F.)
	TRCell():New(oSection1,'E2_VRETISS', 'TSQL', RETTITLE('E2_VRETISS'),"@E 999,999,999.99",TAMSX3('E2_VRETISS')[1],.F.)
	TRCell():New(oSection1,'D1_BASEIRR', 'TSQL', RETTITLE('D1_BASEIRR'),"@E 999,999,999.99",TAMSX3('D1_BASEIRR')[1],.F.)
	TRCell():New(oSection1,'D1_ALIQIRR', 'TSQL', RETTITLE('D1_ALIQIRR'),"@E 999,999,999.99",TAMSX3('D1_ALIQIRR')[1],.F.)
	TRCell():New(oSection1,'D1_VALIRR', 'TSQL', RETTITLE('D1_VALIRR'),"@E 999,999,999.99",TAMSX3('D1_VALIRR')[1],.F.)
	TRCell():New(oSection1,'D1_BASEPIS', 'TSQL', RETTITLE('D1_BASEPIS'),"@E 999,999,999.99",TAMSX3('D1_BASEPIS')[1],.F.)
	TRCell():New(oSection1,'D1_ALQPIS', 'TSQL', RETTITLE('D1_ALQPIS'),"@E 999,999,999.99",TAMSX3('D1_ALQPIS')[1],.F.)
	TRCell():New(oSection1,'D1_VALPIS', 'TSQL', RETTITLE('D1_VALPIS'),"@E 999,999,999.99",TAMSX3('D1_VALPIS')[1],.F.)
	TRCell():New(oSection1,'D1_BASECOF', 'TSQL', RETTITLE('D1_BASECOF'),"@E 999,999,999.99",TAMSX3('D1_BASECOF')[1],.F.)
	TRCell():New(oSection1,'D1_ALQCOF', 'TSQL', RETTITLE('D1_ALQCOF'),"@E 999,999,999.99",TAMSX3('D1_ALQCOF')[1],.F.)
	TRCell():New(oSection1,'D1_VALCOF', 'TSQL', RETTITLE('D1_VALCOF'),"@E 999,999,999.99",TAMSX3('D1_VALCOF')[1],.F.)
	TRCell():New(oSection1,'D1_BASECSL', 'TSQL', RETTITLE('D1_BASECSL'),"@E 999,999,999.99",TAMSX3('D1_BASECSL')[1],.F.)
	TRCell():New(oSection1,'D1_ALQCSL', 'TSQL', RETTITLE('D1_ALQCSL'),"@E 999,999,999.99",TAMSX3('D1_ALQCSL')[1],.F.)
	TRCell():New(oSection1,'D1_VALCSL', 'TSQL', RETTITLE('D1_VALCSL'),"@E 999,999,999.99",TAMSX3('D1_VALCSL')[1],.F.)
	TRCell():New(oSection1,'D1_BASEINS', 'TSQL', RETTITLE('D1_BASEINS'),"@E 999,999,999.99",TAMSX3('D1_BASEINS')[1],.F.)
	TRCell():New(oSection1,'D1_ALIQINS', 'TSQL', RETTITLE('D1_ALIQINS'),"@E 999,999,999.99",TAMSX3('D1_ALIQINS')[1],.F.)
	TRCell():New(oSection1,'D1_VALINS', 'TSQL', RETTITLE('D1_VALINS'),"@E 999,999,999.99",TAMSX3('D1_VALINS')[1],.F.)
	TRCell():New(oSection1,'D1_VALDESC', 'TSQL', RETTITLE('D1_VALDESC'),"@E 999,999,999.99",TAMSX3('D1_VALDESC')[1],.F.)
	TRCell():New(oSection1,'D1_VALFRE', 'TSQL', RETTITLE('D1_VALFRE'),"@E 999,999,999.99",TAMSX3('D1_VALFRE')[1],.F.)
	TRCell():New(oSection1,'D1_DESPESA', 'TSQL', RETTITLE('D1_DESPESA'),"@E 999,999,999.99",TAMSX3('D1_DESPESA')[1],.F.)
	TRCell():New(oSection1,'D1_SEGURO', 'TSQL', RETTITLE('D1_SEGURO'),"@E 999,999,999.99",TAMSX3('D1_SEGURO')[1],.F.)
	TRCell():New(oSection1,'TOTDESP', 'TSQL', 'Total Despesas',"@E 999,999,999.99",14,.F.)
	TRCell():New(oSection1,'VLRBAIXADO', 'TSQL', 'Valor Baixado',"@E 999,999,999.99",14,.F.)

	oSection1:SetTotalText(" ")
	oSection1:SetTotalInLine(.F.)

Return oReport

/*/{Protheus.doc} PrintReport
Faz a impressao do relatorio de acordo com os parametros definidos.
@author Eduardo Duarte | Alliar
@since 03/01/2018
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
	TSQL->(DBGoTop())

	oReport:SetMeter(nCount)

	oReport:SetTitle("Relatorio controle de notas")
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
@since 03/01/2018
@version 1.0
/*/
Static Function qEstTer()
	Local cQuery 	:= ""

	cQuery := " SELECT F1_XIDFLG, "+CRLF
	cQuery += " A2_NOME, "+CRLF
	cQuery += " A2_EST, "+CRLF
	cQuery += " A2_COD_MUN, "+CRLF
	cQuery += " A2_MUN, "+CRLF
	cQuery += " A2_CGC, "+CRLF
	cQuery += " E2_NATUREZ, "+CRLF
	cQuery += " ED_DESCRIC, "+CRLF
	cQuery += " MAX(E2_CODRET) AS E2_CODRET, "+CRLF
	cQuery += " MAX(E2_BAIXA) AS E2_BAIXA, "+CRLF
	cQuery += " F1_FILIAL, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, D1_TES, F1_ESPECIE, F1_EMISSAO, F1_DTDIGIT, D1_COD, D1_TOTAL, E2_BASEISS, D1_ALIQISS, E2_VRETISS, D1_BASEIRR, D1_ALIQIRR, D1_VALIRR, D1_BASEPIS, D1_ALQPIS, D1_VALPIS, D1_BASECOF, D1_ALQCOF, D1_VALCOF, D1_BASECSL, D1_ALQCSL, D1_VALCSL, D1_BASEINS, D1_ALIQINS, D1_VALINS, D1_VALDESC, D1_VALFRE, D1_DESPESA, D1_SEGURO, TOTDESP, "+CRLF
	//cQuery += " SUM(E2_VALLIQ)  AS 'VLRBAIXADO', "+CRLF

	cQuery += "   (SELECT SUM(CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR*-1 ELSE E5_VALOR END) AS E5_VALOR "+CRLF
	cQuery += " FROM "+Retsqlname("SE5")+" SE5  WITH(NOLOCK)  "+CRLF
	cQuery += " WHERE SE5.E5_FILIAL = F1_FILIAL "+CRLF
	cQuery += " AND SE5.E5_PREFIXO =F1_SERIE "+CRLF
	cQuery += " AND SE5.E5_NUMERO = F1_DOC "+CRLF
	cQuery += " AND SE5.E5_TIPO = 'NF' "+CRLF
	cQuery += " AND SE5.E5_CLIFOR =F1_FORNECE "+CRLF
	cQuery += " AND SE5.E5_LOJA = F1_LOJA "+CRLF
	cQuery += " AND SE5.D_E_L_E_T_ = '') AS VLRBAIXADO, "+CRLF

	cQuery += " SUM(E2_SALDO) "+CRLF
	cQuery += " FROM ( "+CRLF
	cQuery += " 	SELECT F1_XIDFLG, "+CRLF
	cQuery += " 			F1_FILIAL, "+CRLF
	cQuery += " 			F1_FORNECE,  "+CRLF
	cQuery += " 			F1_LOJA, "+CRLF
	cQuery += " 			F1_DOC, "+CRLF
	cQuery += " 			F1_SERIE, "+CRLF
	cQuery += " 			MAX(D1_TES) AS D1_TES, "+CRLF
	cQuery += " 			F1_ESPECIE, "+CRLF
	cQuery += " 			MAX(D1_COD)AS D1_COD, "+CRLF
	cQuery += " 			F1_EMISSAO, "+CRLF
	cQuery += " 			F1_DTDIGIT, "+CRLF
	cQuery += " 			SUM(SD1.D1_TOTAL) AS D1_TOTAL, "+CRLF
	//cQuery += " 			SUM(SE2.E2_BASEISS) AS E2_BASEISS, "+CRLF
	cQuery += " 			MAX(SD1.D1_ALIQISS) AS D1_ALIQISS, "+CRLF
	//cQuery += " 			SUM(SE2.E2_VRETISS) AS E2_VRETISS, "+CRLF
	cQuery += " 			SUM(SD1.D1_BASEIRR) AS D1_BASEIRR, "+CRLF
	cQuery += " 			MAX(SD1.D1_ALIQIRR) AS D1_ALIQIRR, "+CRLF
	cQuery += " 			SUM(SD1.D1_VALIRR) AS D1_VALIRR, "+CRLF
	cQuery += " 			SUM(SD1.D1_BASEPIS) AS D1_BASEPIS, "+CRLF
	cQuery += " 			MAX(SD1.D1_ALQPIS) AS D1_ALQPIS, "+CRLF
	cQuery += " 			SUM(SD1.D1_VALPIS) AS D1_VALPIS, "+CRLF
	cQuery += " 			SUM(SD1.D1_BASECOF) AS D1_BASECOF, "+CRLF
	cQuery += " 			MAX(SD1.D1_ALQCOF) AS D1_ALQCOF, "+CRLF
	cQuery += " 			SUM(SD1.D1_VALCOF) AS D1_VALCOF, "+CRLF
	cQuery += " 			SUM(SD1.D1_BASECSL) AS D1_BASECSL, "+CRLF
	cQuery += " 			MAX(SD1.D1_ALQCSL) AS D1_ALQCSL, "+CRLF
	cQuery += " 			SUM(SD1.D1_VALCSL) AS D1_VALCSL, "+CRLF
	cQuery += " 			SUM(SD1.D1_BASEINS) AS D1_BASEINS, "+CRLF
	cQuery += " 			MAX(SD1.D1_ALIQINS) AS D1_ALIQINS, "+CRLF
	cQuery += " 			SUM(SD1.D1_VALINS) AS D1_VALINS, "+CRLF
	cQuery += " 			SUM(SD1.D1_VALDESC) AS D1_VALDESC, "+CRLF
	cQuery += " 			SUM(SD1.D1_VALFRE) AS D1_VALFRE, "+CRLF
	cQuery += " 			SUM(SD1.D1_DESPESA) AS D1_DESPESA, "+CRLF
	cQuery += " 			SUM(SD1.D1_SEGURO) AS D1_SEGURO, "+CRLF
	cQuery += " 			(SUM(D1_SEGURO)+SUM(D1_DESPESA)+SUM(D1_VALFRE)) AS 'TOTDESP' "+CRLF
	cQuery += " 	FROM "+RetSqlName("SF1")+" SF1 WITH (NOLOCK) "+CRLF
	cQuery += " 	INNER JOIN "+RetSqlName("SD1")+" SD1  WITH(NOLOCK) "+CRLF
	cQuery += " 		ON D1_FILIAL = F1_FILIAL "+CRLF
	cQuery += " 		AND D1_DOC = F1_DOC  "+CRLF
	cQuery += " 		AND D1_SERIE = F1_SERIE "+CRLF
	cQuery += " 		AND D1_FORNECE = F1_FORNECE "+CRLF
	cQuery += " 		AND D1_LOJA = F1_LOJA "+CRLF
	cQuery += " 		AND SD1.D_E_L_E_T_ = '' "+CRLF
	cQuery += "	 	WHERE F1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
	cQuery += "	 	AND F1_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "+CRLF
	cQuery += "	 	AND F1_DTDIGIT BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' "+CRLF
	cQuery += " 	AND F1_TIPO <> 'D' "+CRLF
	cQuery += " 	AND SF1.D_E_L_E_T_ = '' "+CRLF
	cQuery += " 	GROUP BY F1_XIDFLG,  "+CRLF
	cQuery += " 			F1_FILIAL, "+CRLF
	cQuery += " 			F1_FORNECE,  "+CRLF
	cQuery += " 			F1_LOJA, "+CRLF
	cQuery += " 			F1_DOC, "+CRLF
	cQuery += " 			F1_SERIE, "+CRLF
	cQuery += " 			F1_ESPECIE, "+CRLF
	cQuery += " 			F1_DOC, "+CRLF
	cQuery += " 			F1_EMISSAO, "+CRLF
	cQuery += " 			F1_DTDIGIT) A "+CRLF
	cQuery += " 	LEFT JOIN "+RetSqlName("SA2")+" SA2  WITH(NOLOCK)  "+CRLF
	cQuery += " 		ON A2_FILIAL = '' "+CRLF
	cQuery += " 		AND A2_COD = F1_FORNECE "+CRLF
	cQuery += " 		AND A2_LOJA = F1_LOJA "+CRLF
	cQuery += " 		AND SA2.D_E_L_E_T_ = '' "+CRLF
	cQuery += " INNER JOIN "+RetSqlName("SE2")+" SE2 WITH (NOLOCK) "+CRLF
	cQuery += " 	ON E2_FILIAL = F1_FILIAL  "+CRLF
	cQuery += " 	AND E2_FORNECE = F1_FORNECE "+CRLF
	cQuery += " 	AND E2_LOJA = F1_LOJA "+CRLF
	cQuery += " 	AND E2_NUM = F1_DOC "+CRLF
	cQuery += " 	AND E2_PREFIXO = F1_SERIE "+CRLF
	cQuery += " 	AND E2_TIPO = 'NF' "+CRLF
	cQuery += "	 	AND E2_BAIXA BETWEEN '"+DTOS(MV_PAR07)+"'  AND '"+DTOS(MV_PAR08)+"' "+CRLF
	cQuery += " 	AND SE2.D_E_L_E_T_ = '' "+CRLF
	cQuery += " LEFT JOIN "+RetSqlName("SED")+" SED WITH (NOLOCK) "+CRLF
	cQuery += " 	ON SED.ED_FILIAL = '' "+CRLF
	cQuery += " 	AND E2_NATUREZ = ED_CODIGO "+CRLF
	cQuery += " 	AND SED.D_E_L_E_T_ = '' "+CRLF
	cQuery += " GROUP BY F1_XIDFLG,  "+CRLF
	cQuery += " A2_NOME, "+CRLF
	cQuery += " A2_EST, "+CRLF
	cQuery += " A2_COD_MUN, "+CRLF
	cQuery += "A2_MUN,      "+CRLF
	cQuery += " A2_CGC, "+CRLF
	cQuery += " E2_NATUREZ, "+CRLF
	cQuery += " ED_DESCRIC, "+CRLF
	cQuery += " F1_FILIAL, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE, D1_TES, F1_ESPECIE, F1_EMISSAO, F1_DTDIGIT, D1_COD, D1_TOTAL, E2_BASEISS, D1_ALIQISS, E2_VRETISS, D1_BASEIRR, D1_ALIQIRR, D1_VALIRR, D1_BASEPIS, D1_ALQPIS, D1_VALPIS, D1_BASECOF, D1_ALQCOF, D1_VALCOF, D1_BASECSL, D1_ALQCSL, D1_VALCSL, D1_BASEINS, D1_ALIQINS, D1_VALINS, D1_VALDESC, D1_VALFRE, D1_DESPESA, D1_SEGURO, TOTDESP "+CRLF
	cQuery += " ORDER BY F1_EMISSAO, F1_FORNECE, F1_LOJA, F1_DOC, F1_SERIE "+CRLF


	MemoWrite(GetTempPath(.T.) + "RFIS001.SQL", cQuery)

	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TSQL", .F., .T.)

	TCSetField("TSQL","F1_EMISSAO","D",08,00)
	TCSetField("TSQL","F1_DTDIGIT","D",08,00)
	TCSetField("TSQL","E2_BAIXA","D",08,00)


Return()


/*/{Protheus.doc} AjustSX1
Ajusta as Perguntas.
@author Eduardo Duarte | Alliar
@since 02/08/2018
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
	PutSx1(cPerg,"03","Data Emissao De?"		 	,"Data Emissao De?"		,"Data Emissao De?"			,"mv_ch3","D",08					,00,0,"G",""			,""		,""	,"","mv_par03",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao Ate")
	PutSx1(cPerg,"04","Data Emissao Ate ?"			,"Data Emissao Ate?"	,"Data Emissao Ate?"		,"mv_ch4","D",08					,00,0,"G","NaoVazio"	,""		,""	,"","mv_par04",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Data Digitacao Dee")
	PutSx1(cPerg,"05","Data Digitacao De?"		 	,"Data Digitacao De?"		,"Data Digitacao De?"			,"mv_ch5","D",08					,00,0,"G",""			,""		,""	,"","mv_par05",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Data Digitacao Ate")
	PutSx1(cPerg,"06","Data Digitacao Ate ?"			,"Data Digitacao Ate?"	,"Data Digitacao Ate?"		,"mv_ch6","D",08					,00,0,"G","NaoVazio"	,""		,""	,"","mv_par06",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Data Baixa De")
	PutSx1(cPerg,"07","Data Baixa De?"		 	,"Data Baixa De?"		,"Data Baixa De?"	,"mv_ch7","D",08					,00,0,"G",""			,""		,""	,"","mv_par07",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Data Digitacao Ate")
	PutSx1(cPerg,"08","Data Baixa Ate ?"			,"Data Baixa Ate?"	,"Data Baixa Ate?"		,"mv_ch8","D",08					,00,0,"G","NaoVazio"	,""		,""	,"","mv_par08",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )




Return()
