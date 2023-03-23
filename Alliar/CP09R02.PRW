#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} CP09R02
Movimentos e Extrato bancário 
@author Augusto Ribeiro/Sivalo Santos | www.compila.com.br
@since 18/02/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
USER FUNCTION CP09R02()

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
Local oSection2
Local oSection3 

Local cPerg		:= "CP09R02"    
Local cDescRel	:= ""

cDescRel	:= "Conciliador Movimento x Extrato " +CRLF
cDescRel	+= "IMPORTANTE: Este relatório foi desenvolvido para ser impresso no formato A4. Por limitações físicas de espaço "

oReport := TReport():New("CP09R02"," Extrato Bancario" , cPerg , {|oReport| PrintRel(oReport)} ,cDescRel)

oReport:SetLandscape()
oReport:SetTotalInLine(.F.) 

AjustSX1(cPerg)
Pergunte(oReport:uParam,.F.)

oSection1 := TRSection():New(oReport,"Conta Bancária","BREL")


TRCell():New(oSection1,"A6_COD"  	,	"BREL","BANCO" 			,,6,.F.)
TRCell():New(oSection1,"A6_AGENCIA"	,	"BREL","AGENCIA" 		,,5,.F.)
TRCell():New(oSection1,"A6_NUMCON"  ,	"BREL","CONTA" 			,,10,.F.)
TRCell():New(oSection1,"A6_NOME"  	,	"BREL","NOME BANCO" 	,,40,.F.)


oSection2 := TRSection():New(oSection1,"Movimento Bancário","MREL")

TRCell():New(oSection2,"E5_DATA"	,	"MREL","DATA MOVIMENTO" ,,10,.F.)
TRCell():New(oSection2,"E5_NUMERO"	,	"MREL","DOCUMENTO" 		,,14,.F.)
TRCell():New(oSection2,"E5_HISTOR "	,	"MREL","HISTORICO" 		,,40,.F.)
TRCell():New(oSection2,"E5_VALOR"	,	"MREL","VALOR" 			,"@E 999,999,999.99",16,.F.)
TRCell():New(oSection2,"E5_RECONC"	,	"MREL","CONCILIADO" 	,,11,.F.)

TRFunction():New(oSection2:Cell("E5_VALOR"),NIL,"SUM",,,,,.T.)	
	
oSection2:SetTotalInLine(.F.)

oSection3 := TRSection():New(oSection1,"Extrato Bancário","EREL")

TRCell():New(oSection3,"ZB2_DATA"  ,	"EREL","DATA EXTRATO" 	,,10,.F.)
TRCell():New(oSection3,"ZB2_CODIGO",	"EREL","DOCUMENTO" 		,,14,.F.)
TRCell():New(oSection3,"ZB2_DESC"  ,	"EREL","DESCRICAO" 		,,40,.F.)
TRCell():New(oSection3,"ZB2_VALOR" ,	"EREL","VALOR" 			,"@E 999,999,999.99",16,.F.)
TRCell():New(oSection3,"ZB2_DTCONC",	"EREL","CONCILIADO" 	,,11,.F.)

TRFunction():New(oSection3:Cell("ZB2_VALOR"),NIL,"SUM",,,,,.T.)	
	
oSection3:SetTotalInLine(.F.)

Return oReport

Static Function PrintRel(oReport)


Local oSection1 := oReport:Section(1)  	
Local oSection2 := oReport:Section(1):Section(1)  	
Local oSection3 := oReport:Section(1):Section(2)
 	
Local nCount  := 0  
Local nSaldo  := 0
Local nTotPos := 0
Local nTotNeg := 0

Private cFilialAtu	:= ""
Private	cBanco 		:= ""
Private cAg 		:=  ""
Private cConta		:= ""


MsgRun("Verificando Registros...",, {|| qBanco() } )

IF BREL->(!EOF())
	
	DBSelectArea("BREL")
	BREL->(DBGoTop())	
	BREL->( dbEval( {|| nCount++ } ) )	
	BREL->(DBGoTop())
	
	oReport:SetMeter(nCount)			 	
	oReport:StartPage()	
		
	//| BANCOS |
	
	WHILE BREL->(!EOF())
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf	
		
		oReport:PrintText("BANCO",,120)
		oReport:SkipLine()
		oSection1:Init()
		oSection1:PrintLine()
		
		/*--------------------------
			MOVIMENTO BANCARIO SE5
		---------------------------*/
		qMov()
		IF MREL->(!EOF())
			oReport:SkipLine()
		    oReport:PrintText("MOVIMENTO",,120)
			oSection2:Init()
			WHILE MREL->(!EOF())
				If oReport:Cancel()
					Exit
				EndIf	
				
				oSection2:PrintLine()
				
				MREL->(DBSKIP())
			ENDDO
			 oSection2:Finish()
		 ENDIF
		 		 
		/*--------------------------
			EXTRATO BANCARIO - ZB2
		---------------------------*/
		qExtrato()
		IF EREL->(!EOF())
			oReport:SkipLine()
		    oReport:PrintText("EXTRATO",,120)
		 	oSection3:Init()
			WHILE EREL->(!EOF())
				
				If oReport:Cancel()
					Exit
				EndIf	
				
				oSection3:PrintLine()
				
				EREL->(DBSKIP())
			ENDDO
			 oSection3:Finish()
		 ENDIF	 
		 
		BREL->(DBSKIP())
		oSection1:Finish()
	ENDDO 
	
ENDIF

oReport:EndPage()

Return

/*/{Protheus.doc} qBanco
Query busca bancos conforme parametross
@author Augusto Ribeiro | www.compila.com.br
@since 20/02/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qBanco()
Local cQuery	:= ""


	cQuery := " SELECT A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME "+CRLF
	cQuery += " FROM "+RetSqlName("SA6")+" SA6 "+CRLF
	cQuery += " WHERE A6_FILIAL BETWEEN  '"+LEFT(MV_PAR01,5)+"' AND '"+LEFT(MV_PAR02,5)+"' "+CRLF
	if !empty(MV_PAR05)
		cQuery += " AND A6_COD = '"+MV_PAR05+"' "+CRLF
	endif
	if !empty(MV_PAR06)
		cQuery += " AND A6_AGENCIA = '"+MV_PAR06+"' "+CRLF
	endif
	if !empty(MV_PAR07)
		cQuery += " AND A6_NUMCON = '"+MV_PAR07+"' "+CRLF
	endif
	cQuery += " AND SA6.D_E_L_E_T_= '' "+CRLF 
	cQuery += " ORDER BY  A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON "+CRLF
	
	
	
	If Select("BREL") > 0
		BREL->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQRY(,,cQuery),'BREL')

Return()

/*/{Protheus.doc} qMov
Query busca Movimentos conforme parametross
@author Augusto Ribeiro | www.compila.com.br
@since 20/02/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qMov()
Local cQuery	:= ""


cQuery := " SELECT  E5_DATA, E5_NUMERO,  E5_DTDISPO,  "+CRLF
cQuery += "       CASE WHEN E5_RECPAG = 'R' THEN E5_VALOR ELSE (E5_VALOR * -1) END AS E5_VALOR,  "+CRLF
cQuery += "       E5_HISTOR, E5_FILIAL,E5_BANCO,E5_AGENCIA, E5_CONTA ,E5_NATUREZ,  CASE WHEN E5_RECONC = 'x' THEN  'S' ELSE 'N' END AS E5_RECONC, "   +CRLF               
cQuery += "       SE5.R_E_C_N_O_ as SE5_RECNO "+CRLF
cQuery += " FROM "+RetSqlName("SE5")+" SE5 "+CRLF
cQuery += " WHERE E5_FILIAL BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQuery += " AND E5_DTDISPO BETWEEN '"+DTOS(mv_par03)+"' AND '"+DTOS(mv_par04)+"' "+CRLF

cQuery += " AND E5_BANCO = '"+BREL->A6_COD+"' "+CRLF
cQuery += " AND E5_AGENCIA = '"+BREL->A6_AGENCIA+"' "+CRLF
cQuery += " AND E5_CONTA = '"+BREL->A6_NUMCON+"' "+CRLF
   	
//cQuery += " AND E5_TIPODOC NOT IN ('JR','DC') "+CRLF
cQuery += " AND (E5_TIPODOC NOT IN ('JR','DC','MT')  OR   (E5_TIPODOC = '' AND E5_LOTE = '')) "+CRLF

If mv_par08 = 1
  cQuery += " AND E5_RECONC ='x' "+CRLF
ElseIf  mv_par08 = 2
  cQuery += " AND E5_RECONC ='' "+CRLF
EndIf 
	 
cQuery += " AND E5_SITUACA <> 'C' "+CRLF
cQuery += " AND UPPER(E5_HISTOR) NOT LIKE 'BX RET CNAB LOTE:%' "+CRLF
cQuery += " AND SE5.D_E_L_E_T_ = '' "+CRLF
cQuery += " ORDER BY E5_DATA, SE5.R_E_C_N_O_ "+CRLF


If Select("MREL") > 0
	MREL->(DbCloseArea())
EndIf


DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"MREL", .F., .T.)

TCSetField("MREL","E5_DATA","D",08,00)
//TCSetField("MREL","E5_RECONC","D",08,00)


Return()

/*/{Protheus.doc} qExtrato
Query busca extrato conforme parametross
@author Augusto Ribeiro | www.compila.com.br
@since 20/02/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qExtrato()
Local cQuery	:= ""


	cQuery := " SELECT ZB2_TIPO, ZB2_DATA,ZB2_CODIGO, ZB2_VALOR, ZB2_DESC, CASE WHEN ZB2_DTCONC = '' THEN 'N' ELSE 'S' END AS ZB2_DTCONC "+CRLF
	cQuery += " FROM "+RetSqlName("ZB2")+" ZB2 "+CRLF
	cQuery += " WHERE ZB2_FILIAL = '' "+CRLF
	cQuery += " AND ZB2_BANCO = '"+BREL->A6_COD+"' "+CRLF
	cQuery += " AND ZB2_AGENC = '"+BREL->A6_AGENCIA+"' "+CRLF
	cQuery += " AND ZB2_CONTA = '"+BREL->A6_NUMCON+"' "+CRLF	
	cQuery += " AND ZB2_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "+CRLF
	IF MV_PAR08 == 1
		cQuery += " AND ZB2_DTCONC <> '' "+CRLF
	ELSEIF  MV_PAR08 == 2
		cQuery += " AND ZB2_DTCONC = '' "+CRLF
	ENDIF
	cQuery += " AND ZB2.D_E_L_E_T_ = '' "+CRLF
	cQuery += " ORDER BY ZB2_DATA, ZB2_FITID "+CRLF
	
	
	If Select("EREL") > 0
		EREL->(DbCloseArea())
	EndIf
	
		
	DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"EREL", .F., .T.)
	
	TCSetField("EREL","ZB2_DATA","D",08,00)
	//TCSetField("EREL","ZB2_DTCONC","D",08,00)
	

Return()

/*/{Protheus.doc} AjustSX1
Cria perguntas no SX1
@author Augusto Ribeiro/Sivaldo Santos | www.compila.com.br
@since 26/12/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AjustSX1(cPerg)

Local aArea := GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

aAdd( aHelpEng, "  ")
aAdd( aHelpSpa, "  ")

aHelpPor := {} ; Aadd( aHelpPor, "Banco")
PutSx1( cPerg, "01","Filial De"	,"","","mv_ch1","C",11,0,0,"G","","SM0","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Banco")
PutSx1( cPerg, "02","FiliaL Ate"	,"","","mv_ch2","C",11,0,0,"G","","SM0","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Data Mov. De")
PutSx1( cPerg, "03","Data Mov. De","","","mv_ch3","D",08,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Data Mov. Ate")
PutSx1( cPerg, "04","Data Mov. Ate","","","mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Banco")
PutSx1( cPerg, "05","Banco"	,"","","mv_ch5","C",TAMSX3("A6_COD")[1],0,0,"G","","SA6CP9","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Agencia")
PutSx1( cPerg, "06","Agencia"	,"","","mv_ch6","C",TAMSX3("A6_AGENCIA")[1],0,0,"G","","","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Conta")
PutSx1( cPerg, "07","Conta"	,"","","mv_ch7","C",TAMSX3("A6_NUMCON")[1],0,0,"G","","","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Conciliação")
PutSx1( cPerg, "08","Conciliação","","","mv_ch8","N",01,0,0,"C","","","","","mv_par08","Conciliados","","","","Não Conciliados","","","Ambos","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

Return()

