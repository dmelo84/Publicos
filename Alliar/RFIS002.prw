#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

#Define EOL chr(13)+chr(10)


/*/{Protheus.doc} RFIS002
Relatorio de controle de notas entrada
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
User Function RFIS002()
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
	Local cPerg		:= "RFIS002"


	cDescRel	:= "Notas de Saída"+EOL
	cDescRel	+= "Apresenta controle de notas de entrada com CGC/CPF conforme parametros informados"

	oReport := TReport():New("RFIS002","Notas de Saída" , cPerg , {|oReport| PrintReport(oReport)} ,cDescRel)
	oReport:SetLandscape()

	oReport:SetTotalInLine(.F.)

	AjustSX1(cPerg)

	/*========================================================================
	| SETOR 1
	======================================================================== */
	oSection1 := TRSection():New(oReport,"Notas de Saida",{"SF2"})
	
	TRCell():New(oSection1,'A1_NOME', 'TSQL', 'CLIENTE',,TAMSX3('A1_NOME')[1],.F.)
	TRCell():New(oSection1,'A1_EST', 'TSQL', 'ESTADO',,TAMSX3('A1_EST')[1],.F.)
	TRCell():New(oSection1,'A1_COD_MUN', 'TSQL', 'MUNICIPIO',,TAMSX3('A1_EST')[1],.F.)
	TRCell():New(oSection1,'A1_MUN', 'TSQL', 'DESC MUNICIPIO',,TAMSX3('A1_EST')[1],.F.)
	TRCell():New(oSection1,'F2_FILIAL', 'TSQL', RETTITLE('F2_FILIAL'),,TAMSX3('F2_FILIAL')[1],.F.)	
	TRCell():New(oSection1,'A1_CGC', 'TSQL', RETTITLE('A1_CGC'),,TAMSX3('A1_CGC')[1],.F.)
	TRCell():New(oSection1,'E1_NATUREZ', 'TSQL', 'NATUREZA',,TAMSX3('E1_NATUREZ')[1],.F.)
	TRCell():New(oSection1,'ED_DESCRIC', 'TSQL', 'DESCRIÇÃO NATUREZA',,TAMSX3('ED_DESCRIC')[1],.F.)
	TRCell():New(oSection1,'D2_TES', 'TSQL', 'TES',,TAMSX3('D2_TES')[1],.F.)	
	TRCell():New(oSection1,'F2_ESPECIE', 'TSQL', 'TIPO DO DOCUMENTO',,TAMSX3('F2_ESPECIE')[1],.F.)
	TRCell():New(oSection1,'F2_DOC', 'TSQL', 'NOTA FISCAL',,TAMSX3('F2_DOC')[1],.F.)
	TRCell():New(oSection1,'F2_NFELETR', 'TSQL', 'NOTA FISCAL ELETRONICA',,TAMSX3('F2_NFELETR')[1],.F.)
	TRCell():New(oSection1,'F2_SERIE', 'TSQL', RETTITLE('F2_SERIE'),,TAMSX3('F2_SERIE')[1],.F.)	
	TRCell():New(oSection1,'F2_EMISSAO', 'TSQL', RETTITLE('F2_EMISSAO'),,TAMSX3('F2_EMISSAO')[1],.F.)
	TRCell():New(oSection1,'F2_COND', 'TSQL', RETTITLE('F2_COND'),,TAMSX3('F2_COND')[1],.F.)
	TRCell():New(oSection1,'F2_DTDIGIT', 'TSQL', RETTITLE('F2_DTDIGIT'),,TAMSX3('F2_DTDIGIT')[1],.F.)	
	TRCell():New(oSection1,'MIN_BAIXA', 'TSQL', "PRI.BAIXA",,TAMSX3('E1_BAIXA')[1],.F.)
	TRCell():New(oSection1,'MAX_BAIXA', 'TSQL', "ULT.BAIXA",,TAMSX3('E1_BAIXA')[1],.F.)	
	TRCell():New(oSection1,'D2_TOTAL', 'TSQL', RETTITLE('D2_TOTAL'),"@E 999,999,999.99",TAMSX3('D2_TOTAL')[1],.F.)
	TRCell():New(oSection1,'D2_BASEISS', 'TSQL', RETTITLE('D2_BASEISS'),"@E 999,999,999.99",TAMSX3('D2_BASEISS')[1],.F.)
	TRCell():New(oSection1,'D2_ALIQISS', 'TSQL', RETTITLE('D2_ALIQISS'),"@E 999,999,999.99",TAMSX3('D2_ALIQISS')[1],.F.)
	TRCell():New(oSection1,'D2_VALISS', 'TSQL', RETTITLE('D2_VALISS'),"@E 999,999,999.99",TAMSX3('D2_VALISS')[1],.F.)
	TRCell():New(oSection1,'E1_VRETISS', 'TSQL', RETTITLE('E1_VRETISS'),"@E 999,999,999.99",TAMSX3('D2_VALISS')[1],.F.)
	TRCell():New(oSection1,'D2_BASEIRR', 'TSQL', RETTITLE('D2_BASEIRR'),"@E 999,999,999.99",TAMSX3('D2_BASEIRR')[1],.F.)
	TRCell():New(oSection1,'D2_ALQIRRF', 'TSQL', RETTITLE('D2_ALQIRRF'),"@E 999,999,999.99",TAMSX3('D2_ALQIRRF')[1],.F.)
	TRCell():New(oSection1,'D2_VALIRRF', 'TSQL', RETTITLE('D2_VALIRRF'),"@E 999,999,999.99",TAMSX3('D2_VALIRRF')[1],.F.)
	TRCell():New(oSection1,'D2_BASEPIS', 'TSQL', RETTITLE('D2_BASEPIS'),"@E 999,999,999.99",TAMSX3('D2_BASEPIS')[1],.F.)
	TRCell():New(oSection1,'D2_ALQPIS', 'TSQL', RETTITLE('D2_ALQPIS'),"@E 999,999,999.99",TAMSX3('D2_ALQPIS')[1],.F.)
	TRCell():New(oSection1,'D2_VALPIS', 'TSQL', RETTITLE('D2_VALPIS'),"@E 999,999,999.99",TAMSX3('D2_VALPIS')[1],.F.)
	TRCell():New(oSection1,'D2_BASECOF', 'TSQL', RETTITLE('D2_BASECOF'),"@E 999,999,999.99",TAMSX3('D2_BASECOF')[1],.F.)
	TRCell():New(oSection1,'D2_ALQCOF', 'TSQL', RETTITLE('D2_ALQCOF'),"@E 999,999,999.99",TAMSX3('D2_ALQCOF')[1],.F.)
	TRCell():New(oSection1,'D2_VALCOF', 'TSQL', RETTITLE('D2_VALCOF'),"@E 999,999,999.99",TAMSX3('D2_VALCOF')[1],.F.)
	TRCell():New(oSection1,'D2_BASECSL', 'TSQL', RETTITLE('D2_BASECSL'),"@E 999,999,999.99",TAMSX3('D2_BASECSL')[1],.F.)
	TRCell():New(oSection1,'D2_ALQCSL', 'TSQL', RETTITLE('D2_ALQCSL'),"@E 999,999,999.99",TAMSX3('D2_ALQCSL')[1],.F.)
	TRCell():New(oSection1,'D2_VALCSL', 'TSQL', RETTITLE('D2_VALCSL'),"@E 999,999,999.99",TAMSX3('D2_VALCSL')[1],.F.)
	TRCell():New(oSection1,'D2_BASEINS', 'TSQL', RETTITLE('D2_BASEINS'),"@E 999,999,999.99",TAMSX3('D2_BASEINS')[1],.F.)
	TRCell():New(oSection1,'D2_ALIQINS', 'TSQL', RETTITLE('D2_ALIQINS'),"@E 999,999,999.99",TAMSX3('D2_ALIQINS')[1],.F.)
	TRCell():New(oSection1,'D2_VALINS', 'TSQL', RETTITLE('D2_VALINS'),"@E 999,999,999.99",TAMSX3('D2_VALINS')[1],.F.)
	TRCell():New(oSection1,'D2_DESCON', 'TSQL', RETTITLE('D2_DESCON'),"@E 999,999,999.99",TAMSX3('D2_DESCON')[1],.F.)
	TRCell():New(oSection1,'D2_VALFRE', 'TSQL', RETTITLE('D2_VALFRE'),"@E 999,999,999.99",TAMSX3('D2_VALFRE')[1],.F.)
	TRCell():New(oSection1,'D2_DESPESA', 'TSQL', RETTITLE('D2_DESPESA'),"@E 999,999,999.99",TAMSX3('D2_DESPESA')[1],.F.)
	TRCell():New(oSection1,'D2_SEGURO', 'TSQL', RETTITLE('D2_SEGURO'),"@E 999,999,999.99",TAMSX3('D2_SEGURO')[1],.F.)
	TRCell():New(oSection1,'TOTDESP', 'TSQL', 'Total Despesas',"@E 999,999,999.99",14,.F.)
	TRCell():New(oSection1,'VLRBAIXADO', 'TSQL', 'Valor Baixado',"@E 999,999,999.99",14,.F.)
	TRCell():New(oSection1,"F3_DESCRET"         ,"QRYCTR"	,RetTitle("F3_DESCRET")					,,40						,.F.)
	
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
@since 12/12/2017
@version 1.0
/*/
Static Function qEstTer()
	Local cQuery 	:= ""


	cQuery := " SELECT   "+CRLF
	cQuery += "  A1_NOME,  "+CRLF
	cQuery += "  A1_CGC,  "+CRLF
	cQuery += "  A1_EST,  "+CRLF
	cQuery += "  A1_COD_MUN,  "+CRLF
	cQuery += "  A1_MUN,  "+CRLF
	cQuery += "  E1_NATUREZ,  "+CRLF
	cQuery += "  ED_DESCRIC, "+CRLF
	cQuery += "   F2_FILIAL,  F2_DOC,  F2_SERIE, F2_CLIENTE, F2_COND , F2_LOJA, F2_NFELETR ,F2_COND ,   "+CRLF
	cQuery += "   D2_TES, F2_ESPECIE, F2_EMISSAO, F2_DTDIGIT, D2_BASEISS, D2_ALIQISS, D2_VALISS, E1_VRETISS,D2_BASEIRR, D2_ALQIRRF, D2_VALIRRF,   "+CRLF
	cQuery += "   D2_TOTAL, D2_BASEPIS, D2_ALQPIS, D2_VALPIS, D2_BASECOF, D2_ALQCOF, D2_VALCOF, D2_BASECSL, D2_ALQCSL, D2_VALCSL,  "+CRLF
	cQuery += "   D2_BASEINS, D2_ALIQINS, D2_VALINS, D2_DESCON,   "+CRLF
	cQuery += "   D2_VALFRE, D2_DESPESA, D2_SEGURO, TOTDESP, "+CRLF
	cQuery += "  E1_SALDO, E1_NATUREZ, F3_DESCRET, "+CRLF
	cQuery += "   (SELECT SUM(CASE WHEN E5_RECPAG = 'P' THEN E5_VALOR*-1 ELSE E5_VALOR END) AS E5_VALOR "+CRLF
	cQuery += " FROM "+Retsqlname("SE5")+" SE5  WITH(NOLOCK)  "+CRLF
	cQuery += " WHERE SE5.E5_FILIAL = F2_FILIAL "+CRLF
	cQuery += " AND SE5.E5_PREFIXO =F2_SERIE "+CRLF
	cQuery += " AND SE5.E5_NUMERO = F2_DOC "+CRLF
	cQuery += " AND SE5.E5_TIPO = 'NF' "+CRLF
	cQuery += " AND SE5.E5_CLIFOR =F2_CLIENTE "+CRLF
	cQuery += " AND SE5.E5_LOJA = F2_LOJA "+CRLF
	cQuery += " AND SE5.D_E_L_E_T_ = '') AS TOTALBX, "+CRLF
	cQuery += "   (SELECT MIN(E5_DATA) AS E5_BAIXA "+CRLF
	cQuery += " FROM "+Retsqlname("SE5")+" SE5  WITH(NOLOCK)  "+CRLF
	cQuery += " WHERE SE5.E5_FILIAL = F2_FILIAL "+CRLF
	cQuery += " AND SE5.E5_PREFIXO =F2_SERIE "+CRLF
	cQuery += " AND SE5.E5_NUMERO = F2_DOC "+CRLF
	cQuery += " AND SE5.E5_TIPO = 'NF' "+CRLF
	cQuery += " AND SE5.E5_CLIFOR =F2_CLIENTE "+CRLF
	cQuery += " AND SE5.E5_LOJA = F2_LOJA "+CRLF
	cQuery += " AND SE5.D_E_L_E_T_ = '') AS MIN_BAIXA, "+CRLF
	cQuery += " MAX_BAIXA "+CRLF
	cQuery += "  FROM ( "+CRLF
	cQuery += " 	 SELECT "+CRLF
	cQuery += " 	  F2_FILIAL,  F2_DOC,  F2_SERIE, F2_CLIENTE, F2_LOJA, F2_NFELETR,F2_COND ,   "+CRLF
	cQuery += " 	  D2_TES, F2_ESPECIE, F2_EMISSAO, F2_DTDIGIT, D2_BASEISS, D2_ALIQISS, D2_VALISS,E1_VRETISS, D2_BASEIRR, D2_ALQIRRF, D2_VALIRRF,   "+CRLF
	cQuery += " 	  D2_TOTAL, D2_BASEPIS, D2_ALQPIS, D2_VALPIS, D2_BASECOF, D2_ALQCOF, D2_VALCOF, D2_BASECSL, D2_ALQCSL, D2_VALCSL,  "+CRLF
	cQuery += " 	  D2_BASEINS, D2_ALIQINS, D2_VALINS, D2_DESCON,   "+CRLF
	cQuery += " 	  D2_VALFRE, D2_DESPESA, D2_SEGURO, TOTDESP, "+CRLF
	cQuery += " 	 SUM(E1_SALDO) AS E1_SALDO, MAX(E1_BAIXA) AS MAX_BAIXA, E1_NATUREZ, MAX(F3_DESCRET) AS F3_DESCRET "+CRLF
	cQuery += " 	 FROM (SELECT   "+CRLF
	cQuery += "  				F2_FILIAL,  "+CRLF
	cQuery += "  				F2_CLIENTE,   "+CRLF
	cQuery += "  				F2_LOJA,  "+CRLF
	cQuery += "  				F2_DOC,  "+CRLF
	cQuery += "  				F2_NFELETR,  "+CRLF
	cQuery += "  				F2_COND,  "+CRLF
	cQuery += "  				F2_SERIE,  "+CRLF
	cQuery += "  				MAX(D2_TES) AS D2_TES,  "+CRLF
	cQuery += "  				F2_ESPECIE,  "+CRLF
	cQuery += "  				F2_EMISSAO,  "+CRLF
	cQuery += "  				F2_DTDIGIT,  "+CRLF
	cQuery += "  				SUM(SD2.D2_TOTAL) AS D2_TOTAL,  "+CRLF
	cQuery += "  				SUM(SD2.D2_BASEISS) AS D2_BASEISS,  "+CRLF
	cQuery += "  				MAX(SD2.D2_ALIQISS) AS D2_ALIQISS,  "+CRLF
	cQuery += "  				SUM(SD2.D2_VALISS) AS D2_VALISS,  "+CRLF
	//cQuery += "                 SUM(SE1.E1_VRETISS)AS E1_VRETISS, "+CRLF
	cQuery += "  				SUM(SD2.D2_BASEIRR) AS D2_BASEIRR,  "+CRLF
	cQuery += "  				MAX(SD2.D2_ALQIRRF) AS D2_ALQIRRF,  "+CRLF
	cQuery += "  				SUM(SD2.D2_VALIRRF) AS D2_VALIRRF,  "+CRLF
	cQuery += "  				SUM(SD2.D2_BASEPIS) AS D2_BASEPIS,  "+CRLF
	cQuery += "  				MAX(SD2.D2_ALQPIS) AS D2_ALQPIS,  "+CRLF
	cQuery += "  				SUM(SD2.D2_VALPIS) AS D2_VALPIS,  "+CRLF
	cQuery += "  				SUM(SD2.D2_BASECOF) AS D2_BASECOF,  "+CRLF
	cQuery += "  				MAX(SD2.D2_ALQCOF) AS D2_ALQCOF,  "+CRLF
	cQuery += "  				SUM(SD2.D2_VALCOF) AS D2_VALCOF,  "+CRLF
	cQuery += "  				SUM(SD2.D2_BASECSL) AS D2_BASECSL,  "+CRLF
	cQuery += "  				MAX(SD2.D2_ALQCSL) AS D2_ALQCSL,  "+CRLF
	cQuery += "  				SUM(SD2.D2_VALCSL) AS D2_VALCSL,  "+CRLF
	cQuery += "  				SUM(SD2.D2_BASEINS) AS D2_BASEINS,  "+CRLF
	cQuery += "  				MAX(SD2.D2_ALIQINS) AS D2_ALIQINS,  "+CRLF
	cQuery += "  				SUM(SD2.D2_VALINS) AS D2_VALINS,  "+CRLF
	cQuery += "  				SUM(SD2.D2_DESCON) AS D2_DESCON,  "+CRLF
	cQuery += "  				SUM(SD2.D2_VALFRE) AS D2_VALFRE,  "+CRLF
	cQuery += "  				SUM(SD2.D2_DESPESA) AS D2_DESPESA,  "+CRLF
	cQuery += "  				SUM(SD2.D2_SEGURO) AS D2_SEGURO,  "+CRLF
	cQuery += " 	 (SUM(D2_SEGURO)+SUM(D2_DESPESA)+SUM(D2_VALFRE)) AS 'TOTDESP'  "+CRLF
	cQuery += "  		FROM "+Retsqlname("SF2")+" SF2 WITH (NOLOCK)  "+CRLF
	cQuery += "  		INNER JOIN "+Retsqlname("SD2")+" SD2  WITH(NOLOCK)  "+CRLF
	cQuery += "  			ON D2_FILIAL = F2_FILIAL  "+CRLF
	cQuery += "  			AND D2_DOC = F2_DOC   "+CRLF
	cQuery += "  			AND D2_SERIE = F2_SERIE  "+CRLF
	cQuery += "  			AND D2_CLIENTE = F2_CLIENTE  "+CRLF
	cQuery += "  			AND D2_LOJA = F2_LOJA  "+CRLF
	cQuery += "  			AND SD2.D_E_L_E_T_ = ''  "+CRLF
	cQuery += "	 		WHERE F2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
	cQuery += "	 		AND F2_EMISSAO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "+CRLF
//	cQuery += "	 		AND F2_DTDIGIT BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"' "+CRLF		
	cQuery += " 		AND F2_TIPO <> 'D' "+CRLF
	cQuery += "  		AND SF2.D_E_L_E_T_ = ''  "+CRLF
	cQuery += "  		GROUP BY F2_FILIAL,  "+CRLF
	cQuery += "  				F2_CLIENTE,   "+CRLF
	cQuery += "  				F2_LOJA,  "+CRLF
	cQuery += "  				F2_DOC,  "+CRLF
	cQuery += "  				F2_NFELETR,  "+CRLF
	cQuery += "  				F2_COND,  "+CRLF
	cQuery += "  				F2_SERIE,  "+CRLF
	cQuery += "  				F2_ESPECIE,  "+CRLF
	cQuery += "  				F2_EMISSAO,  "+CRLF
	cQuery += "  				F2_DTDIGIT) A  "+CRLF
	cQuery += " 	 INNER JOIN "+Retsqlname("SE1")+" SE1 WITH (NOLOCK)  "+CRLF
	cQuery += "  		ON E1_FILIAL = F2_FILIAL   "+CRLF
	cQuery += "  		AND E1_CLIENTE = F2_CLIENTE  "+CRLF
	cQuery += "  		AND E1_LOJA = F2_LOJA  "+CRLF
	cQuery += "  		AND E1_NUM = F2_DOC  "+CRLF
	cQuery += "  		AND E1_PREFIXO = F2_SERIE  "+CRLF
	cQuery += "  		AND E1_TIPO = 'NF'  "+CRLF
	cQuery += "         AND (E1_PARCELA='' OR E1_PARCELA='001') "+CRLF
	cQuery += "	 		AND E1_BAIXA BETWEEN '"+DTOS(MV_PAR05)+"'  AND '"+DTOS(MV_PAR06)+"' "+CRLF	
	cQuery += "  		AND SE1.D_E_L_E_T_ = ''  "+CRLF
	cQuery += " 	INNER JOIN "+Retsqlname("SF3")+" SF3 WITH(NOLOCK)  "+CRLF
	cQuery += " 		ON F2_FILIAL = F3_FILIAL              		     "+CRLF
	cQuery += " 		AND F2_CLIENTE = F3_CLIEFOR                 	 "+CRLF
	cQuery += " 		AND F2_LOJA = F3_LOJA                       	 "+CRLF
	cQuery += " 		AND F2_DOC = F3_NFISCAL               			 "+CRLF
	cQuery += " 		AND F2_SERIE = F3_SERIE               			 "+CRLF
	cQuery += " 		AND SF3.D_E_L_E_T_ = ''                   		 "+CRLF
	cQuery += " 	 GROUP BY  F2_FILIAL,  F2_DOC,  F2_SERIE, F2_CLIENTE, F2_LOJA, F2_COND ,F2_NFELETR,   "+CRLF
	cQuery += " 	  D2_TES, F2_ESPECIE, F2_EMISSAO, F2_DTDIGIT, D2_BASEISS, D2_ALIQISS, D2_VALISS,E1_VRETISS , D2_BASEIRR, D2_ALQIRRF, D2_VALIRRF,   "+CRLF
	cQuery += " 	  D2_TOTAL, D2_BASEPIS, D2_ALQPIS, D2_VALPIS, D2_BASECOF, D2_ALQCOF, D2_VALCOF, D2_BASECSL, D2_ALQCSL, D2_VALCSL,  "+CRLF
	cQuery += " 	  D2_BASEINS, D2_ALIQINS, D2_VALINS, D2_DESCON,   "+CRLF
	cQuery += " 	  D2_VALFRE, D2_DESPESA, D2_SEGURO, TOTDESP, E1_NATUREZ) B "+CRLF
	cQuery += " LEFT JOIN "+Retsqlname("SA1")+" SA1  WITH(NOLOCK)  "+CRLF
	cQuery += "  	ON A1_FILIAL = ''  "+CRLF
	cQuery += "  	AND A1_COD = F2_CLIENTE  "+CRLF
	cQuery += "  	AND A1_LOJA = F2_LOJA  "+CRLF
	cQuery += "  	AND SA1.D_E_L_E_T_ = ''  "+CRLF
	cQuery += " LEFT JOIN "+Retsqlname("SED")+" SED WITH (NOLOCK)  "+CRLF
	cQuery += "  	ON SED.ED_FILIAL = ''  "+CRLF
	cQuery += "  	AND E1_NATUREZ = ED_CODIGO  "+CRLF
	cQuery += "  	AND SED.D_E_L_E_T_ = ''  "+CRLF



	MemoWrite(GetTempPath(.T.) + "RFIS002.SQL", cQuery)		

	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TSQL", .F., .T.)

	TCSetField("TSQL","F2_EMISSAO","D",08,00)
	//TCSetField("TSQL","E1_BAIXA","D",08,00)
	TCSetField("TSQL","F2_DTDIGIT","D",08,00)
	TCSetField("TSQL","MIN_BAIXA","D",08,00)
	TCSetField("TSQL","MAX_BAIXA","D",08,00)


Return()


/*/{Protheus.doc} AjustSX1
Ajusta as Perguntas.  
@author Eduardo Duarte | Alliar
@since 12/08/2020
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
	PutSx1(cPerg,"03","Data Emissao De?"		 	,"Data Emissao De?"		,"Data Emissao De?"			,"mv_ch3","D",08,00,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )	

	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao Ate")
	PutSx1(cPerg,"04","Data Emissao Ate ?"			,"Data Emissao Ate?"	,"Data Emissao Ate?"		,"mv_ch4","D",08,00,0,"G","NaoVazio","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Data Baixa De")
	PutSx1(cPerg,"05","Data Baixa De?"		 	,"Data Baixa De?"		,"Data Baixa De?"	,"mv_ch5","D",08,00,0,"G","",""	,""	,"","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )	

	aHelpPor := {} ; Aadd( aHelpPor, "Data Baixa Ate")
	PutSx1(cPerg,"06","Data Baixa Ate ?"			,"Data Baixa Ate?"	,"Data Baixa Ate?"		,"mv_ch6","D",08,00,0,"G","NaoVazio",""	,""	,"","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )




Return()
