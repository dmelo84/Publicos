#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} REST001

Saldos por lote 

@author Julio Teixeira - Compila
@since 29/04/2020
@version undefined
@param param
@return return, return_description
/*/
USER FUNCTION REST001()

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
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º MONTA ESTRUTURA DO RELATORIO                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local oReport
Local oSection1

Local cPerg		:= "REST001"    
Local cDescRel	:= ""

cDescRel	:= "Saldos por lote" +CRLF

oReport := TReport():New("REST001"," Saldos por Lote" , cPerg , {|oReport| PrintRel(oReport)} ,cDescRel)

oReport:SetLandscape()
oReport:SetTotalInLine(.F.) 

Pergunte(oReport:uParam,.F.)

oSection1 := TRSection():New(oReport,"Saldos por Lote","B8REL")

TRCell():New(oSection1,"B1_COD"  	,	"B8REL","Produto" 		,,30,.F.)
TRCell():New(oSection1,"B1_TIPO"	,	"B8REL","Tipo" 			,,5,.F.)
TRCell():New(oSection1,"B1_GRUPO"   ,	"B8REL","Grupo" 		,,20,.F.)
TRCell():New(oSection1,"B1_DESC"  	,	"B8REL","Descrição" 	,,50,.F.)
TRCell():New(oSection1,"B1_UM"  	,	"B8REL","U.M." 			,,5,.F.)
TRCell():New(oSection1,"B2_FILIAL"  ,	"B8REL","Filial" 		,,10,.F.)
TRCell():New(oSection1,"B2_LOCAL"  	,	"B8REL","Armazem" 		,,5,.F.)
TRCell():New(oSection1,"B2_QATU"  	,	"B8REL","Saldo Estoque" ,,20,.F.)
TRCell():New(oSection1,"B8_LOTECTL" ,	"B8REL","Lote" 			,,20,.F.)
TRCell():New(oSection1,"B8_DTVALID" ,	"B8REL","Validade" 		,,10,.F.)
TRCell():New(oSection1,"B8_SALDO"  	,	"B8REL","Saldo Lote" 	,,20,.F.)

Return oReport

Static Function PrintRel(oReport)

Local oSection1 := oReport:Section(1)  	
 	
Local nCount  := 0  

Private cFilialAtu	:= ""
Private	cBanco 		:= ""
Private cAg 		:=  ""
Private cConta		:= ""

MsgRun("Verificando Registros...",, {|| qBanco() } )

IF B8REL->(!EOF())
	
	DBSelectArea("B8REL")
	B8REL->(DBGoTop())	
	B8REL->( dbEval( {|| nCount++ } ) )	
	B8REL->(DBGoTop())
	
	oReport:SetMeter(nCount)			 	
	oReport:StartPage()	
	
	oSection1:Init()

	WHILE B8REL->(!EOF())
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf	
			
		oSection1:PrintLine()
		 
		B8REL->(DBSKIP())
	ENDDO 
	
	oSection1:Finish()	
ENDIF

oReport:EndPage()

Return

/*/{Protheus.doc} qBanco
Query busca saldos conforme parametross
@author Julio Teixeira - Compila | www.compila.com.br
@since 29/04/2020
@version 12
@param param
@return return, return_description
/*/
Static Function qBanco()
Local cQuery	:= ""

	cQuery := " SELECT "
	cQuery += " SB1.B1_COD, SB1.B1_TIPO, SB1.B1_GRUPO, SB1.B1_DESC, SB1.B1_UM, "+CRLF
	cQuery += " SB2.B2_LOCAL, SB2.B2_QATU, SB2.B2_FILIAL, "+CRLF
	cQuery += " ISNULL(SB8.B8_LOTECTL,'') B8_LOTECTL, ISNULL(SB8.B8_DTVALID,'') B8_DTVALID , ISNULL(SB8.B8_SALDO,0) B8_SALDO  "+CRLF
	cQuery += " FROM "+RetSqlName("SB2")+" SB2 "+CRLF
	cQuery += " LEFT JOIN "+RetSqlName("SB8")+" SB8 ON SB8.B8_FILIAL = SB2.B2_FILIAL AND SB8.B8_PRODUTO = SB2.B2_COD AND SB8.B8_LOCAL = SB2.B2_LOCAL "+CRLF
	cQuery += " AND SB8.B8_LOTECTL >= '"+MV_PAR09+"' AND SB8.B8_LOTECTL <= '"+MV_PAR10+"' "+CRLF
	If MV_PAR11 == 2
		cQuery += " AND SB8.B8_SALDO > 0 "+CRLF
	Endif
	cQuery += " AND SB8.D_E_L_E_T_ = '' "+CRLF
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD = SB2.B2_COD"+CRLF
	cQuery += " WHERE SB2.B2_LOCAL >= '"+MV_PAR03+"' AND SB2.B2_LOCAL <=  '"+MV_PAR04+"' "+CRLF
	cQuery += " AND SB2.B2_FILIAL >= '"+MV_PAR01+"' AND SB2.B2_FILIAL <=  '"+MV_PAR02+"' "+CRLF
	cQuery += " AND SB2.B2_COD >= '"+MV_PAR05+"' AND SB2.B2_COD <= '"+MV_PAR06+"' "+CRLF
	cQuery += " AND SB1.B1_GRUPO >= '"+MV_PAR07+"' AND SB1.B1_GRUPO <= '"+MV_PAR08+"' "+CRLF
	If MV_PAR11 == 2
		cQuery += " AND SB2.B2_QATU > 0 "+CRLF
	Endif
	cQuery += " AND SB1.D_E_L_E_T_ = '' "+CRLF
	cQuery += " AND SB2.D_E_L_E_T_ = '' "+CRLF
	cQuery += " ORDER BY B2_FILIAL, SB1.B1_COD,  B2_LOCAL, SB1.B1_UM, B8_LOTECTL"

	cQuery := ChangeQuery(cQuery)	

	If Select("B8REL") > 0
		B8REL->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQRY(,,cQuery),'B8REL')

	TCSetField("B8REL","B8_DTVALID","D",08,00)

Return()