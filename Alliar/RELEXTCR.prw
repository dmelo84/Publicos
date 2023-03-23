#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define EOL chr(13)+chr(10)


/*/{Protheus.doc} RELEXTCR
Relatorio de controle lote
@author Eduardo Duarte | Alliar
@since 12/12/2017
@version 1.0
/*/
User Function RELEXTCR()
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
	Local cPerg		:= "RELEXTCR"


	cDescRel	:= "RELEXTCR "+EOL
	cDescRel	+= "Apresenta Resumo do extrato importado "

	oReport := TReport():New("RELEXTCR","Resumo de extrato CR" , cPerg , {|oReport| PrintReport(oReport)} ,cDescRel)
	oReport:SetLandscape()

	oReport:SetTotalInLine(.F.)

	AjustSX1(cPerg)

	/*========================================================================
	| SETOR 1
	======================================================================== */
	oSection1 := TRSection():New(oReport,"Extrato imp resumo CR",{"ZB2"})

	TRCell():New(oSection1,'A6_FILIAL', 'TSQL', RETTITLE('A6_FILIAL'),,TAMSX3('A6_FILIAL')[1],.F.)
	TRCell():New(oSection1,'ZB2_BANCO', 'TSQL', RETTITLE('ZB2_BANCO'),,TAMSX3('ZB2_BANCO')[1],.F.)
	TRCell():New(oSection1,'ZB2_AGENC', 'TSQL', RETTITLE('ZB2_AGENC'),,TAMSX3('ZB2_AGENC')[1],.F.)
	TRCell():New(oSection1,'ZB2_CONTA', 'TSQL', RETTITLE('ZB2_CONTA'),,TAMSX3('ZB2_CONTA')[1],.F.)
	TRCell():New(oSection1,'ZB2_TIPO', 'TSQL', RETTITLE('ZB2_TIPO'),,TAMSX3('ZB2_TIPO')[1],.F.)
	TRCell():New(oSection1,'ZB2_DATA', 'TSQL', RETTITLE('ZB2_DATA'),,TAMSX3('ZB2_DATA')[1],.F.)
	TRCell():New(oSection1,'ZB2_VALOR', 'TSQL', RETTITLE('ZB2_VALOR'),,TAMSX3('ZB2_VALOR')[1],.F.)
	TRCell():New(oSection1,'ZB2_DESC', 'TSQL', RETTITLE('ZB2_DESC'),,TAMSX3('ZB2_DESC')[1],.F.)
	TRCell():New(oSection1,'ZB2_DTCONC', 'TSQL', RETTITLE('ZB2_DTCONC'),,TAMSX3('ZB2_DTCONC')[1],.F.)



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

	oReport:SetTitle("Relatorio extrato CR")
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
	cQuery :=  "   SELECT  A6_FILIAL,                                    "+CRLF
	cQuery +=  "    ZB2_BANCO, ZB2_AGENC,                                "+CRLF
	cQuery +=  "    ZB2_CONTA, ZB2_TIPO,                                "+CRLF
	cQuery +=  "    ZB2_DATA, ZB2_VALOR,           	                     "+CRLF
	cQuery +=  "    ZB2_DESC, ZB2_DTCONC                                "+CRLF
	cQuery +=  "    FROM ZB2010           		  	                    		"+CRLF
	cQuery +=  "    LEFT JOIN SA6010 ON            	                    								"+CRLF
	cQuery +=  "    ZB2_AGENC = A6_AGENCIA AND                           								   "+CRLF
	cQuery +=  "    ZB2_CONTA = A6_NUMCON AND       									 "+CRLF
	cQuery +=  "    ZB2_BANCO = A6_COD AND       									   "+CRLF
	cQuery +=  "    ZB2010.D_E_L_E_T_='' AND        								   "+CRLF
	cQuery +=  "    SA6010.D_E_L_E_T_=''         									   "+CRLF
	cQuery +=  "   WHERE            														"+CRLF
	cQuery +=  "    A6_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'    AND            "+CRLF
	cQuery +=  "    ZB2_BANCO BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  AND            "+CRLF
	cQuery +=  "   ZB2_AGENC BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  AND            "+CRLF
	cQuery +=  "   ZB2_CONTA BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'  AND            "+CRLF
	cQuery +=  "   ZB2_DATA BETWEEN '"+DTOS(MV_PAR09)+"' AND '"+DTOS(MV_PAR10)+"'          "+CRLF





	MemoWrite(GetTempPath(.T.) + "RELEXTCR.SQL", cQuery)

	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TSQL", .F., .T.)
	TCSetField("TSQL","ZB2_DATA","D",08,00)
	TCSetField("TSQL","ZB2_DTCONC","D",08,00)



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


	aHelpPor := {} ; Aadd( aHelpPor, "Raiz Filial De")
	PutSx1( cPerg, "01"," Raiz Filial De"	,"","","mv_ch1","C",5,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Filial Ate")
	PutSx1( cPerg, "02"," Raiz Filial Ate","","","mv_ch2","C",5,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Banco de ? ")
	PutSx1(cPerg,"03","Banco De?"		 	,"Banco de ?"		,"Banco  De?"			,"mv_ch3","C",03,00,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Banco Ate")
	PutSx1(cPerg,"04","Banco Ate?"			,"Banco Ate?"	,"Banco Ate?"		,"mv_ch4","C",03,00,0,"G","NaoVazio","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

    aHelpPor := {} ; Aadd( aHelpPor, "Agencia De ? ")
	PutSx1(cPerg,"03","Agencia De?"		 	,"Agencia De  ?"		,"Agencia De ?"			,"mv_ch5","C",05,00,0,"G","","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Agencia Ate")
	PutSx1(cPerg,"04","Agencia Ate?"			,"Agencia Ate?"	,"Agencia Ate?"		,"mv_ch6","C",05,00,0,"G","NaoVazio","","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

    aHelpPor := {} ; Aadd( aHelpPor, "Conta  De ? ")
	PutSx1(cPerg,"03","Agencia De?"		 	,"Agencia De  ?"		,"Conta De ?"			,"mv_ch7","C",10,00,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Conta Ate")
	PutSx1(cPerg,"04","Conta Ate?"			,"Conta Ate?"	,"Conta Ate?"		,"mv_ch8","C",10,00,0,"G","NaoVazio","","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao De")
	PutSx1(cPerg,"05","Data De?"		 	,"Data Emissao De?"		,"Data Emissao De?"			,"mv_ch9","D",08,00,0,"G","","","","","mv_par09","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao Ate")
	PutSx1(cPerg,"06","Data  Ate ?"			,"Data Emissao Ate?"	,"Data Emissao Ate?"		,"mv_chp","D",08,00,0,"G","NaoVazio","","","","mv_par10","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )




Return()
