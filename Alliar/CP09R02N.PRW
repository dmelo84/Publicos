#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} CP09R02N
Movimentos e Extrato bancário 
@author Augusto Ribeiro/Sivaldo Santos | www.compila.com.br
@since 18/02/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
USER FUNCTION CP09R02N()

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

oReport := TReport():New("CP09R02","Movimento Extrato Bancario" , cPerg , {|oReport| PrintRel(oReport)} ,cDescRel)

oReport:SetLandscape()
oReport:SetTotalInLine(.F.) 

Pergunte(oReport:uParam,.F.)

oSection1 := TRSection():New(oReport,"Conta Bancaria","BREL")


TRCell():New(oSection1,"A6_COD"  	,	"BREL","BANCO" 			,,6,.F.)
TRCell():New(oSection1,"A6_AGENCIA"	,	"BREL","AGENCIA" 		,,5,.F.)
TRCell():New(oSection1,"A6_NUMCON"  ,	"BREL","CONTA" 			,,10,.F.)
TRCell():New(oSection1,"A6_NOME"  	,	"BREL","NOME BANCO" 	,,40,.F.)


oSection2 := TRSection():New(oSection1,"Movimento x Extrato Bancario","MREL")


TRCell():New(oSection2,"E5_FILIAL"	,	"MREL","EMPRESA" ,,14,.F.)
TRCell():New(oSection2,"E5_DATA"	,	"MREL","DATA MOVIMENTO" ,,10,.F.) //DT_MOVIMENTO
TRCell():New(oSection2,"E5_BANCO"	,	"MREL","BANCO" 		    ,,6,.F.)
TRCell():New(oSection2,"E5_AGENCIA"  ,	"MREL","AGENCIA" 		,,10,.F.)
TRCell():New(oSection2,"E5_CONTA"  	,	"MREL","CONTA" 			,,10,.F.)
TRCell():New(oSection2,"E5_NUMERO"	,	"MREL","DOCUMENTO" 		,,14,.F.)
TRCell():New(oSection2,"E5_HISTOR "	,	"MREL","HISTORICO" 		,,40,.F.)
TRCell():New(oSection2,"VLMOVTO"	,	"MREL","VALOR MOVIMENTO" 			,"@E 999,999,999.99",18,.F.) //VLR_MOVMTO
TRCell():New(oSection2,"VLEXTRATO"	,	"MREL","VALOR EXTRATO" 			,"@E 999,999,999.99",18,.F.) //VLR_EXTRAT
TRCell():New(oSection2,"E5_RECONC"	,	"MREL","CONCILIADO" 	,,11,.F.)
TRCell():New(oSection2,"ORIGEM"	    ,	"MREL","ORIGEM" 	    ,,11,.F.)

//


 
//TRFUNCTION():New(oCell,cName,cFunction,oBreak,cTitle,cPicture,uFormula,lEndSection,lEndReport,lEndPage,oParent,bCondition,lDisable,bCanPrint) 
TRFunction():New(oSection2:Cell("VLMOVTO"),nil,"SUM",,,,,.T.)	
TRFunction():New(oSection2:Cell("VLEXTRATO"),nil,"SUM",,,,,.T.)	
	
oSection2:SetTotalInLine(.F.)


Return oReport

Static Function PrintRel(oReport)


Local oSection1 := oReport:Section(1)  	
Local oSection2 := oReport:Section(1):Section(1)  	
//Local oSection3 := oReport:Section(1):Section(2)
 	
Local nCount  := 0  
Local nSaldo  := 0
Local nTotPos := 0
Local nTotNeg := 0
Private nTotalExtrato := 0
Private nTotalMovimento:= 0

Private cFilialAtu	:= ""
Private	cBanco 		:= ""
Private cAg 		:=  ""
Private cConta		:= ""


MsgRun("Verificando Registros...",, {|| qBancoN() } )

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
			MOVIMENTO X EXTRATO  BANCARIO SE5/ ZB2
		---------------------------*/
		qMovN()
		IF MREL->(!EOF())
			oReport:SkipLine()
		    oReport:PrintText("MOVIMENTO X EXTRATO",,120)
			oSection2:Init()
			WHILE MREL->(!EOF())
				If oReport:Cancel()
					Exit
				EndIf	
				
				IF MREL->ORIGEM =="EXTRATO"
				   nTotalExtrato += MREL->VLEXTRATO
				ELSE
				   nTotalMovimento += MREL->VLMOVTO
				ENDIF
				
				oSection2:PrintLine()
				
				MREL->(DBSKIP())
			ENDDO
			 oSection2:Finish()
		 ENDIF
		 		 
	
		 
		BREL->(DBSKIP())
		oSection1:Finish()
	ENDDO 
	
ENDIF

oReport:EndPage()

Return

/*/{Protheus.doc} qBancoN
Query busca bancos conforme parametross
@author Augusto Ribeiro / Sivaldo Santos | www.compila.com.br
@since 20/02/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qBancoN()
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

/*/{Protheus.doc} qMovN
Query busca Movimentos e Extrato conforme parametross
@author Augusto Ribeiro /Sivaldo Santos | www.compila.com.br
@since 20/02/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qMovN()
Local cQuery	:= ""


cQuery := " SELECT  "+CRLF
cQuery += "     E5_FILIAL, "+CRLF
cQuery += "  	E5_DATA,  "+CRLF
cQuery += "  	E5_NUMERO,   "+CRLF
cQuery += "     E5_BANCO, "+CRLF
cQuery += "  	E5_AGENCIA, "+CRLF
cQuery += "  	E5_CONTA ,	 "+CRLF
cQuery += "     E5_DTDISPO, "+CRLF
cQuery += "  	CASE WHEN E5_RECPAG = 'R' THEN E5_VALOR ELSE (E5_VALOR * -1) END AS VLMOVTO,  "+CRLF
cQuery += "		VLEXTRATO = 0,"+CRLF
cQuery += "  	E5_HISTOR, 	 "+CRLF
cQuery += "  	E5_NATUREZ,   "+CRLF
cQuery += "     ORIGEM = 'MOVIMENTO', "+CRLF
cQuery += "  	CASE WHEN E5_RECONC = 'x' THEN  'S' ELSE 'N' END AS E5_RECONC,  "+CRLF
cQuery += "  	SE5.R_E_C_N_O_ as SE5_RECNO  "+CRLF
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
//cQuery += " ORDER BY E5_DATA, SE5.R_E_C_N_O_ "+CRLF

cQuery += "UNION                      "+CRLF

cQuery += " SELECT                    "+CRLF
cQuery += "		ZB2_FILIAL,           "+CRLF
cQuery += "     ZB2_DATA,             "+CRLF
cQuery += "     ZB2_CODIGO,           "+CRLF
cQuery += "		ZB2_BANCO,            "+CRLF
cQuery += "		ZB2_AGENC,            "+CRLF
cQuery += "		ZB2_CONTA, 	          "+CRLF
cQuery += "		ZB2_TIPO =  '',       "+CRLF
cQuery += "		VLMOVTO = 0,          "+CRLF
cQuery += "		VLEXTRATO = ZB2_VALOR,"+CRLF
cQuery += "		ZB2_DESC,             "+CRLF
cQuery += "     NATRUZA = '',         "+CRLF
cQuery += "     ORIGEM = 'EXTRATO',   "+CRLF
cQuery += "		CASE WHEN ZB2_DTCONC = '' THEN 'N' ELSE 'S' END AS ZB2_DTCONC,"+CRLF
cQuery += "     ZB2.R_E_C_N_O_ AS RECNO     "+CRLF
cQuery += " FROM "+RetSqlName("ZB2")+" ZB2  "+CRLF
cQuery += " 	WHERE ZB2_FILIAL = ''       "+CRLF
cQuery += " 		AND ZB2_BANCO = '"+BREL->A6_COD+"' "+CRLF
cQuery += " 		AND ZB2_AGENC = '"+BREL->A6_AGENCIA+"' "+CRLF
cQuery += " 		AND ZB2_CONTA = '"+BREL->A6_NUMCON+"' "+CRLF	
cQuery += " 		AND ZB2_DATA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "+CRLF
	
	IF MV_PAR08 == 1
		cQuery += " AND ZB2_DTCONC <> '' "+CRLF
	ELSEIF  MV_PAR08 == 2
		cQuery += " AND ZB2_DTCONC = '' "+CRLF
	ENDIF
	
cQuery += " AND ZB2.D_E_L_E_T_ = '' "+CRLF
cQuery += " ORDER BY  E5_DATA "+CRLF



If Select("MREL") > 0
	MREL->(DbCloseArea())
EndIf


DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"MREL", .F., .T.)

TCSetField("MREL","E5_DATA","D",08,00)
//TCSetField("MREL","ZB2_DATA","D",08,00)
//TCSetField("MREL","E5_RECONC","D",08,00)


Return()
