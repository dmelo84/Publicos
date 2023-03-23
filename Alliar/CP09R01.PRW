#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} CP09R01
Resumo em Excel do Lote de Faturamnto Antecipado Zatix.
@author Augusto Ribeiro | www.compila.com.br
@since 17/12/2016
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
USER FUNCTION CP09R01()

Local oReport     
Local aRet	:= {.T.,""}
Private aLote	:= {}


oReport := ReportDef()


If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf				
			
oReport:PrintDialog()

Return(aRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ MONTA ESTRUTURA DO RELATORIO                                          บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()

Local oReport
Local oSection1

Local cPerg		:= "CP09R01"    
Local cDescRel	:= ""

cDescRel	:= "Lan็amentos do Extrato nใo conciliado"

oReport := TReport():New("CP09R01","Nใo conciliados - Extrato Bancario" , cPerg , {|oReport| PrintRel(oReport)} ,cDescRel)
oReport:SetLandscape()
oReport:SetTotalInLine(.F.) 

Pergunte(oReport:uParam,.F.)

oSection1 := TRSection():New(oReport,"Extrato Bancแrio","TREL") 

/*
TRCell():New(oSection1,"NOME"		,"TCLI","CLIENTE" 		,,40,.F.)
TRCell():New(oSection1,"CGC"		,"TCLI","CPF/CNPJ"		,,14,.F. )
TRCell():New(oSection1,"DTATIVA"	,"TCLI","DT ATIVACAO"	,,10,.F.,{|| DTOCY(STOD(TCLI->DTATIVA)) } )
TRCell():New(oSection1,"NSERIE"		,"TCLI","NUM SERIR" 	,,24,.F.)
TRCell():New(oSection1,"TECNO"		,"TCLI","TECNOLOGIA"	,,40,.F. )
TRCell():New(oSection1,"DOCORIG"	,"TCLI","NF ORIGEM"		,,10,.F. )
*/

TRCell():New(oSection1,"ZB2_TIPO",	"TREL","TIPO" 					,,6,.F.)
TRCell():New(oSection1,"ZB2_DATA",	"TREL","DATA MOVIMENTO" 		,,14,.F.)
TRCell():New(oSection1,"ZB2_VALOR",		"TREL","VALOR" 				,"@E 999,999,999.99",16,.F.)
TRCell():New(oSection1,"ZB2_DESC",		"TREL","DESCRICAO" 			,,40,.F.)
TRCell():New(oSection1,"ZB2_DTCONC",	"TREL","DATA CONCILIAวรO" 	,,10,.F.)

Return oReport



Static Function PrintRel(oReport)


	Local oSection1 := oReport:Section(1)  	
	Local nCount	:= 0  
  

	MsgRun("Verificando Registros...",, {|| qConc() } )

	
	DBSelectArea("TREL")
	TREL->(DBGoTop())	
	TREL->( dbEval( {|| nCount++ } ) )	
	TREL->(DBGoTop())
	
	oReport:SetMeter(nCount)			 	
	oReport:StartPage()	
	oSection1:Init()
	
	While TREL->( !Eof() )
		
		If oReport:Cancel()
			Exit
		EndIf		
		
		oSection1:PrintLine()								
				
		TREL->( dbSkip() )	
	EndDo
	oSection1:Finish()
	oReport:EndPage()
	
Return



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบ SELECIONA TODAS AS ANTENAS DO CLIENTE DEFINIDO NO PARAMETRO           บฑฑ
ฑฑศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function qConc()
Local cQuery 	:= ""
Local cDigConta	:= ""

	/*------------------------------------------------------ Augusto Ribeiro | 14/01/2017 - 4:28:50 PM
		Busca digito da conta para contactenar na busca
	------------------------------------------------------------------------------------------*/
	cQuery := " SELECT A6_DVCTA "+CRLF
	cQuery += " FROM "+RetSqlName("SA6")+" SA6 "+CRLF
	cQuery += " WHERE A6_COD = '"+MV_PAR01+"' "+CRLF
	cQuery += " AND A6_AGENCIA = '"+MV_PAR02+"' "+CRLF
	cQuery += " AND A6_NUMCON = '"+MV_PAR03+"' "+CRLF
	cQuery += " AND A6_BLOCKED <> '1' "+CRLF
	cQuery += " AND A6_DVCTA <> '' "+CRLF
	cQuery += " AND SA6.D_E_L_E_T_= '' "+CRLF 
	
	
	If Select("TREL") > 0
		TREL->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQRY(,,cQuery),'TREL')
	IF TREL->(!EOF())
		cDigConta	:=  TREL->A6_DVCTA
	ENDIF
	
	TREL->(DbCloseArea())
	
	

	cQuery := " SELECT ZB2_TIPO, ZB2_DATA, ZB2_VALOR, ZB2_DESC, ZB2_DTCONC "+CRLF
	cQuery += " FROM "+RetSqlName("ZB2")+" ZB2 "+CRLF
	cQuery += " WHERE ZB2_FILIAL = '"+XFILIAL("ZB2")+"' "+CRLF
	cQuery += " AND ZB2_BANCO IN ('"+PADL(MV_PAR01,TAMSX3("ZB2_BANCO")[1],"0")+"', '"+MV_PAR01+"') "+CRLF
	cQuery += " AND ZB2_AGENC = '"+MV_PAR02+"' "+CRLF
	cQuery += " AND CONVERT(INT, ZB2_CONTA) =  "+ALLTRIM(STR(val(alltrim(MV_PAR03)+cDigConta)))+" "+CRLF
	cQuery += " AND ZB2_DATA BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' "+CRLF
	IF MV_PAR06 == 1
		cQuery += " AND ZB2_DTCONC <> '' "+CRLF
	ELSEIF  MV_PAR06 == 2
		cQuery += " AND ZB2_DTCONC = '' "+CRLF
	ENDIF
	cQuery += " AND ZB2.D_E_L_E_T_ = '' "+CRLF
	cQuery += " ORDER BY ZB2_DATA, ZB2_FITID "+CRLF
	
	

	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TREL", .F., .T.)
	
	TCSetField("TREL","ZB2_DATA","D",08,00)
	TCSetField("TREL","ZB2_DTCONC","D",08,00)
	
Return
