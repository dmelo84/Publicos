#include "protheus.ch"
#include "rwmake.ch"
#include "TopConn.ch"
#include "report.ch"

#Define EOL chr(13)+chr(10)


/*/{Protheus.doc} RFIN003
Relatorio de controle de notas 
@author Jonatas Oliveira | www.compila.com.br
@since 27/10/2016
@version 1.0
/*/
User Function RFIN003()
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
@author Jonatas Oliveira | www.compila.com.br
@since 27/10/2016
@version 1.0
/*/
Static Function ReportDef()

	Local oReport
	Local oSection1	
	Local oBreak
	Local cDescRel
	Local cPerg		:= "RFIN003"


	cDescRel	:= "Relatorio de controle de notas"+EOL
	cDescRel	+= "Apresenta controle de notas conforme parametros informados"

	oReport := TReport():New("RFIN003","Relatorio de controle de notas" , cPerg , {|oReport| PrintReport(oReport)} ,cDescRel)
	oReport:SetLandscape()

	oReport:SetTotalInLine(.F.)

	AjustSX1(cPerg)

	/*========================================================================
	| SETOR 1
	======================================================================== */
	oSection1 := TRSection():New(oReport,"controle de notas",{"SF2"})
//	oSection1:NCLRBACK 	:= 13092807
	TRCell():New(oSection1,"C5_FILIAL"			,"QRYCTR"	,RetTitle("C5_FILIAL" )					,,20						,.F.)
	TRCell():New(oSection1,"C5_NUM"				,"QRYCTR"	,RetTitle("C5_NUM" )					,,20						,.F.)
	TRCell():New(oSection1,"F2_CLIENTE"         ,"QRYCTR"	,RetTitle("F2_CLIENTE")					,,TAMSX3("F2_CLIENTE")[1]	,.F.)
	TRCell():New(oSection1,"F2_LOJA"            ,"QRYCTR"	,RetTitle("F2_LOJA"   )					,,4							,.F.)
	TRCell():New(oSection1,"A1_NOME"            ,"QRYCTR"	,RetTitle("A1_NOME"   )					,,TAMSX3("A1_NOME"   )[1]	,.F.)
	TRCell():New(oSection1,"F2_XIDPLE"          ,"QRYCTR"	,RetTitle("F2_XIDPLE")					,,TAMSX3("F2_XIDPLE")[1]	,.F.)			
	TRCell():New(oSection1,"F2_EMISSAO"         ,"QRYCTR"	,RetTitle("F2_EMISSAO")					,,TAMSX3("F2_EMISSAO")[1]	,.F.)
	TRCell():New(oSection1,"F2_DOC"             ,"QRYCTR"	,RetTitle("F2_DOC"    )					,,15	,.F.)
	TRCell():New(oSection1,"F2_NFELETR"         ,"QRYCTR"	,RetTitle("F2_NFELETR")					,,TAMSX3("F2_NFELETR")[1]	,.F.)
	TRCell():New(oSection1,"F3_VALCONT"         ,"QRYCTR"	,RetTitle("F3_VALCONT")					,,TAMSX3("F3_VALCONT")[1]	,.F.)
	TRCell():New(oSection1,"F3_EMINFE"          ,"QRYCTR"	,RetTitle("F3_EMINFE")					,,TAMSX3("F3_EMINFE")[1]	,.F.)
	TRCell():New(oSection1,"F3_DTCANC"          ,"QRYCTR"	,RetTitle("F3_DTCANC")					,,TAMSX3("F3_DTCANC")[1]	,.F.)
	TRCell():New(oSection1,"F3_DESCRET"         ,"QRYCTR"	,RetTitle("F3_DESCRET")					,,40						,.F.)
	TRCell():New(oSection1,"E1_PREFIXO"         ,"QRYCTR"	,RetTitle("E1_PREFIXO")					,,TAMSX3("E1_PREFIXO")[1]	,.F.)
	TRCell():New(oSection1,"E1_NUM"         	,"QRYCTR"	,RetTitle("E1_NUM")						,,10						,.F.)
	TRCell():New(oSection1,"E1_TIPO"         	,"QRYCTR"	,RetTitle("E1_TIPO")					,,TAMSX3("E1_TIPO")[1]		,.F.)
	TRCell():New(oSection1,"E1_VENCTO"         	,"QRYCTR"	,RetTitle("E1_VENCTO")					,,TAMSX3("E1_VENCTO")[1]	,.F.)
	TRCell():New(oSection1,"QTDE_PARC"         	,"QRYCTR"	,"Parcelas"								,,5							,.F.)
	TRCell():New(oSection1,"E1_VALOR"         	,"QRYCTR"	,"Soma Parcelas"						,,TAMSX3("E1_VALOR")[1]		,.F.)
	//TRCell():New(oSection1,"E1_VALOR"         	,"QRYCTR"	,RetTitle("E1_VALOR")					,,TAMSX3("E1_VALOR")[1]		,.F.)
	//TRCell():New(oSection1,"CKO_DT_GER"         ,"QRYCTR"	,RetTitle("CKO_DT_GER")					,,TAMSX3("CKO_DT_GER")[1]	,.F.)

	oSection1:SetTotalText(" ")
	oSection1:SetTotalInLine(.F.)

Return oReport


/*/{Protheus.doc} PrintReport
Faz a impressao do relatorio de acordo com os parametros definidos.
@author Jonatas Oliveira | www.compila.com.br
@since 19/10/2016
@version 1.0
/*/
Static Function PrintReport(oReport)

	Local oSection1 	:= oReport:Section(1)
	
	Local nCount		:= 0
	Local nI			:= 1
	Local cCodPrd		:= ""


	Pergunte(oReport:uParam,.F.)


	MsgRun("Processando, Aguarde...","SQL", {|| qEstTer() } )	//Transforma parametros do tipo Range em expressao SQL para ser utilizada na query

	DBSelectArea("QRYCTR")
	QRYCTR->(DBGoTop())
	//QRYCTR->( dbEval( {|| nCount++ } ) )
	QRYCTR->(DBGoTop())

	oReport:SetMeter(nCount)

	oReport:SetTitle("Relatorio controle de notas")
	oReport:StartPage()

	oSection1:Init()	

	While QRYCTR->( !Eof() )
		
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf
	
		oSection1:PrintLine()			 							
		QRYCTR->(DBSKIP())
	ENDDO
	
	oSection1:Finish()	
	oReport:EndPage()

Return


/*/{Protheus.doc} qEstTer
Monta a Query
@author Jonatas Oliveira | www.compila.com.br
@since 19/10/2016
@version 1.0
/*/
Static Function qEstTer()
	Local cQuery 	:= ""

	cQuery += "	 SELECT *									  		"+CRLF
	cQuery += "	 FROM "+Retsqlname("SF2")+" F2 				        "+CRLF
	
	cQuery += "	INNER JOIN "+Retsqlname("SC5")+" SC5   				"+CRLF
	cQuery += "	 	ON F2_FILIAL = C5_FILIAL              		    "+CRLF
	cQuery += "	 	AND F2_DOC = C5_NOTA              		    	"+CRLF	
	cQuery += "	 	AND F2_CLIENTE = C5_CLIENTE                 	"+CRLF
	cQuery += "	 	AND F2_LOJA = C5_LOJACLI                       	"+CRLF	
	cQuery += "	 	AND SC5.D_E_L_E_T_ = ''                    		"+CRLF
	
	/*
	cQuery += "	 LEFT JOIN "+Retsqlname("CKO")+" CKO    "+CRLF
	cQuery += "	 	ON F2_SERIE + F2_DOC = LEFT(CKO_IDERP,12) 		"+CRLF
	cQuery += "	 	AND CKO.D_E_L_E_T_ = ''                   		"+CRLF
	*/
	cQuery += "	 LEFT JOIN (										"+CRLF
	cQuery += "	 			SELECT E1_FILIAL,						"+CRLF 
	cQuery += "	 				E1_PREFIXO,							"+CRLF
	cQuery += "	 				E1_NUM,								"+CRLF
	cQuery += "	 				E1_TIPO,							"+CRLF
	cQuery += "	 				E1_CLIENTE,							"+CRLF
	cQuery += "	 				E1_LOJA, 							"+CRLF
	cQuery += "	 				SUM(E1_VALOR)  AS E1_VALOR,			"+CRLF 
	cQuery += "	 				COUNT(*) AS QTDE_PARC, 				"+CRLF
	cQuery += "	 				MIN(E1_VENCTO) AS  E1_VENCTO		"+CRLF
	cQuery += "	 			FROM "+Retsqlname("SE1")+" 				"+CRLF
	cQuery += "	 			WHERE D_E_L_E_T_ = '' 					"+CRLF
	cQuery += "	 			GROUP BY E1_FILIAL, 					"+CRLF
	cQuery += "	 				E1_PREFIXO,							"+CRLF
	cQuery += "	 				E1_NUM,								"+CRLF
	cQuery += "	 				E1_CLIENTE,							"+CRLF
	cQuery += "	 				E1_LOJA,							"+CRLF
	cQuery += "	 				E1_TIPO ) A     					"+CRLF
	
	cQuery += "	 	ON F2_FILIAL = E1_FILIAL                  		"+CRLF
	cQuery += "	 	AND F2_SERIE = E1_PREFIXO                 		"+CRLF
	cQuery += "	 	AND F2_DOC = E1_NUM                       		"+CRLF
	cQuery += "	 	AND F2_CLIENTE = E1_CLIENTE               		"+CRLF
	cQuery += "	 	AND F2_LOJA = E1_LOJA                     		"+CRLF
	//cQuery += "	 	AND E1.D_E_L_E_T_ = ''                    		"+CRLF
	//cQuery += "	 	AND (E1_PARCELA = '' OR E1_PARCELA = '001')     "+CRLF
	cQuery += "	 	AND E1_TIPO = 'NF'  							"+CRLF
	
	cQuery += "	INNER JOIN "+Retsqlname("SF3")+" SF3   	"+CRLF
	cQuery += "	 	ON F2_FILIAL = F3_FILIAL              		    "+CRLF
	cQuery += "	 	AND F2_CLIENTE = F3_CLIEFOR                 	"+CRLF
	cQuery += "	 	AND F2_LOJA = F3_LOJA                       	"+CRLF
	cQuery += "	 	AND F2_DOC = F3_NFISCAL               			"+CRLF
	cQuery += "	 	AND F2_SERIE = F3_SERIE               			"+CRLF
	cQuery += "	 	AND SF3.D_E_L_E_T_ = ''                    		"+CRLF
		
	cQuery += "	INNER JOIN "+Retsqlname("SA1")+" SA1   	"+CRLF
	cQuery += "	 	ON A1_FILIAL = '"+ XFILIAL("SA1") +"'           "+CRLF
	cQuery += "	 	AND F2_CLIENTE = A1_COD                 		"+CRLF
	cQuery += "	 	AND F2_LOJA = A1_LOJA                       	"+CRLF
	cQuery += "	 	AND SA1.D_E_L_E_T_ = ''                    		"+CRLF
			
	cQuery += "	 WHERE F2.D_E_L_E_T_ = ''                    		"+CRLF
	cQuery += "	 	AND F2_DOC BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"'    "+CRLF
	cQuery += "	 	AND F2_SERIE BETWEEN '"+ MV_PAR05 +"' AND '"+ MV_PAR06 +"'  "+CRLF
	cQuery += "	 	AND F2_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"'  AND '"+DTOS(MV_PAR02)+"' "+CRLF
	cQuery += "	 	AND F2.D_E_L_E_T_ = ''                    		"+CRLF 
	
	
	MemoWrite(GetTempPath(.T.) + "RFIN003.SQL", cQuery)		

	If Select("QRYCTR") > 0
		QRYCTR->(DbCloseArea())
	EndIf

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"QRYCTR", .F., .T.)

	TCSetField("QRYCTR","F2_EMISSAO","D",08,00)
	//TCSetField("QRYCTR","E1_VENCREA","D",08,00)
	TCSetField("QRYCTR","E1_VENCTO","D",08,00)
	
	TCSetField("QRYCTR","F3_DTCANC","D",08,00)
	TCSetField("QRYCTR","F3_EMINFE","D",08,00)
	
	//TCSetField("QRYCTR","CKO_DT_GER","D",08,00)


Return()


/*/{Protheus.doc} AjustSX1
Ajusta as Perguntas.  
@author Jonatas Oliveira | www.compila.com.br
@since 19/10/2016
@version 1.0
/*/
Static Function AjustSX1(cPerg)
	Local aArea := GetArea()
	Local aHelpPor	:= {}
	Local aHelpEng 		:= {}
	Local aHelpSpa	:= {}

	aAdd( aHelpEng, "  ")
	aAdd( aHelpSpa, "  ")


	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao De")
	PutSx1(cPerg,"01","Data Emissao De?"		 	,"Data Emissao De?"		,"Data Emissao De?"			,"mv_ch1","D",08					,00,0,"G","NaoVazio"			,""		,""	,"","mv_par01",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )	
	
	aHelpPor := {} ; Aadd( aHelpPor, "Dt. Emissao Ate")
	PutSx1(cPerg,"02","Data Emissao Ate ?"			,"Data Emissao Ate?"	,"Data Emissao Ate?"		,"mv_ch2","D",08					,00,0,"G","NaoVazio"	,""		,""	,"","mv_par02",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
		
	aHelpPor := {} ; Aadd( aHelpPor, "Nota Fiscal De")
	PutSx1(cPerg,"03","Nota Fiscal De     ?"		,"Nota Fiscal De ?"		,"Nota Fiscal De ?"  		,"mv_ch3","C",TAMSX3("F2_DOC")[1]	,00,0,"G","" 			,"SF2" 	,""	,"","mv_par03",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Nota Fiscal Ate")
	PutSx1(cPerg,"04","Nota Fiscal Ate   ?"			,"Nota Fiscal Ate ?"	,"Nota Fiscal Ate ?"		,"mv_ch4","C",TAMSX3("F2_DOC")[1]	,00,0,"G","NaoVazio	" 	,"SF2"	,""	,"","mv_par04",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Serie NF De")
	PutSx1(cPerg,"05","Serie NF De   ?"				,"Serie NF De    ?"		,"Serie NF De   ?"			,"mv_ch5","C",TAMSX3("F2_SERIE")[1]	,00,0,"G","	" 			,""		,""	,"","mv_par05",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Serie NF Ate")
	PutSx1(cPerg,"06","Serie NF Ate  ?"				,"Serie NF Ate   ?"		,"Serie NF Ate  ?"			,"mv_ch6","C",TAMSX3("F2_SERIE")[1]	,00,0,"G","NaoVazio	" 	,""		,""	,"","mv_par06",""			,"","","",""	 			,"","","",""	,"","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	
Return()



