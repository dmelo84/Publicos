#include "protheus.ch"
#include "rwmake.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "TBICONN.CH"

#Define EOL chr(13)+chr(10)


/*/{Protheus.doc} RTMK001
Relatorio Tipo Ocor x Ocorrencia x Ação
@author Jonatas Oliveira | www.compila.com.br
@since 15/04/2019
@version 1.0
/*/
User Function RTMK001()
	Local oReport
	
	/*========================================================================
	|Interface de impressao
	|
	======================================================================== */
	oReport := ReportDef()
	If !Empty(oReport:uParam)
		Pergunte(oReport:uParam,.F.)
	EndIf
	oReport:PrintDialog()
	
	
Return


/*========================================================================
| Descrição: MONTA ESTRUTURA DO RELATORIO
|
| Nota.....:
|
| ========================================================================
| Desenvolvido por: Jonatas Oliveira
======================================================================== */
Static Function ReportDef()
	
	Local oReport
	Local oSection1
	Local cDescRel
	Local cPerg		:= "RTMK001"

	cDescRel	:= "Relatorio Tipo Ocor x Ocorrencia x Ação"+EOL
	cDescRel	+= "Apresenta Tipo Ocor x Ocorrencia x Ação conforme parametros informados"
	
	oReport := TReport():New("RTMK001","Relatorio Tipo Ocor x Ocorrencia x Ação" , cPerg , {|oReport| PrintReport(oReport)} ,cDescRel)
	oReport:SetLandscape() // SetLandscape() SetPortrait()
	
	oReport:SetTotalInLine(.T.)
	
	/*========================================================================
	|SETOR 1 - UNICO
	|
	======================================================================== */		
	oSection1 := TRSection():New(oReport,"Tipo Ocor x Ocorrencia x Ação",{"Z21"})
	TRCell():New(oSection1,"U9_TIPOOCO"	 	,"QRYTMK","Cod. Tp Ocorrencia" 			,,20,.F.)
	TRCell():New(oSection1,"UX_DESTOC"	 	,"QRYTMK","Tipo Ocorrencia" 			,,50,.F.)
	TRCell():New(oSection1,"UR_CODREC"	  	,"QRYTMK","Cod. Ocorrencia"	 			,,20,.F.)
	TRCell():New(oSection1,"U9_DESC"		,"QRYTMK","Ocorrencia"	 				,,50,.F.)
	TRCell():New(oSection1,"UR_CODSOL"	 	,"QRYTMK","Cod. Acao" 					,,15,.F.)
	TRCell():New(oSection1,"UQ_DESC"		,"QRYTMK","Acao"						,,50,.F.)
	
//	oSection1:SetTotalText("Totais")
//	oSection1:SetTotalInLine(.T.)
	
Return oReport

/*========================================================================
| Descrição: Faz a impressao do relatorio de acordo com os parametros definos.
|
| Nota.....:
|
| ========================================================================
| Desenvolvido por: Jonatas Oliveira
======================================================================== */
Static Function PrintReport(oReport)
	
	Local oSection1 	:= oReport:Section(1)	
	Local nCount		:= 0

	Pergunte(oReport:uParam,.F.)
	
	MsgRun("Processando, Aguarde...","SQL", {|| qFatOS() } )	//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query
	
	DBSelectArea("QRYTMK")
	QRYTMK->(DBGoTop())
	QRYTMK->( dbEval( {|| nCount++ } ) )
	QRYTMK->(DBGoTop())
	
	oReport:SetMeter(nCount)
	
	oReport:SetTitle("Tipo Ocor x Ocorrencia x Ação")
	oReport:StartPage()
	
	
	oSection1:Init()
	
	While QRYTMK->( !Eof() )
		
		If oReport:Cancel()
			Exit
		EndIf

		         	
		oSection1:PrintLine()
		oReport:IncMeter()
		
		QRYTMK->( dbSkip() )
		
	EndDo
		
	oSection1:Finish()
	oReport:SkipLine()
	oReport:SkipLine()
	oReport:EndPage()
	oSection1:Finish()
	oReport:EndPage()
	
Return


/*========================================================================
| Descrição: Monta a Query
|
| Nota.....:
|
| ========================================================================
| Desenvolvido por: Jonatas Oliveira
======================================================================== */
Static Function qFatOS()
	Local cQuery 	:= ""

	cQuery += " SELECT   "+CRLF
	cQuery += " 	U9_TIPOOCO ,  "+CRLF
	cQuery += " 	UX_DESTOC ,  "+CRLF
	cQuery += " 	UR_CODREC,  "+CRLF
	cQuery += " 	U9_DESC,	  "+CRLF
	cQuery += " 	UR_CODSOL,  "+CRLF
	cQuery += " 	UQ_DESC  "+CRLF
	cQuery += " FROM SU9010 U9   "+CRLF
	cQuery += " INNER JOIN SUX010 UX  "+CRLF
	cQuery += " 	ON U9_FILIAL = UX_FILIAL  "+CRLF
	cQuery += " 	AND U9_TIPOOCO = UX_CODTPO  "+CRLF
	cQuery += " 	AND UX.D_E_L_E_T_ = ''  "+CRLF
	cQuery += " 	AND U9_TIPOOCO BETWEEN '"+ MV_PAR01 +"' AND '" +MV_PAR02+ "'  "+CRLF
	cQuery += " INNER JOIN SUR010 UR  "+CRLF
	cQuery += " 	ON UR.D_E_L_E_T_ = ''  "+CRLF
	cQuery += " 	AND U9_FILIAL = UR_FILIAL  "+CRLF
	cQuery += " 	AND U9_CODIGO = UR_CODREC  "+CRLF
	cQuery += " 	AND UR_CODREC BETWEEN '"+ MV_PAR03 +"' AND '" +MV_PAR04+ "'  "+CRLF
	cQuery += " INNER JOIN SUQ010 UQ   "+CRLF
	cQuery += " 	ON UQ.D_E_L_E_T_ = ''  "+CRLF
	cQuery += " 	AND UR_FILIAL = UQ_FILIAL  "+CRLF
	cQuery += " 	AND UR_CODSOL = UQ_SOLUCAO  "+CRLF
	cQuery += " WHERE U9.D_E_L_E_T_ = ''  "+CRLF
	
		
	If Select("QRYTMK") > 0
		QRYTMK->(DbCloseArea())
	EndIf
	
	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"QRYTMK", .F., .T.)

	
	
Return()
