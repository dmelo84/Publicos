#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"




/*/{Protheus.doc} CP07R01
Relatório Reembolso de Despesa
@author Augusto Ribeiro | www.compila.com.br
@since 16/02/2015
@version 1.0
/*/
User Function CP07R01() 
	
Local oReport     
Local aRet	:= {.T.,""}

Private cDespRef	:= U_CP07002G("20", "ALIASDESP", "SED")
// Private aOrdem  := {STR0015,STR0016,STR0019,STR0023}		//" Por Tipo           "###" Por Grupo        "###"Por descrição do produto"###"Por produto"

oReport := ReportDef()
If !Empty(oReport:uParam)
	Pergunte(oReport:uParam,.F.)
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
Local oBreak
Local cPerg		:= "CP07R01"    
Local cDescRel	:= ""

cDescRel	:= "Reembolso de Despesa"
//cDescRel	+= "IMPORTANTE: Este relatório foi desenvolvido para ser impresso no formato A4. Por limitações físicas de espaço "
///cDescRel	+= "na página, na sessão EVENTO, será impresso no máximo 99999 bytes/comandos (5 caracteres) em cada coluna."

oReport := TReport():New("CP07R01","Reembolso de Despesa" , cPerg , {|oReport| U_CP07R01P(oReport)} ,cDescRel)
oReport:SetLandscape()
oReport:SetTotalInLine(.F.) 


AjustSX1(cPerg)
Pergunte(oReport:uParam,.F.)

//TRCell():New(Objeto,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ DADOS DO USUARIO - SETOR 1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,"USUARIO","ZA0", {"Status, Codigo", "Status, Dt.Despesa"})
oSection1:NCLRBACK 	:= 13092807 

TRCell():New(oSection1,"ZAF_CODUSR"	,"TSQL", "COD.USUARIO" 		,,13,.F.)
TRCell():New(oSection1,"ZA0_NOME"		,"TSQL", "NOME	"			,,25,.F. )
TRCell():New(oSection1,"ZA0_CODFOR"	,"TSQL", "COD. FORNEC."		,,13,.F. )
TRCell():New(oSection1,"ZA0_LOJFOR"	,"TSQL", "LOJA"				,,5,.F. )
TRCell():New(oSection1,"A2_NOME"		,"TSQL", "FORNECEDOR"		,,50,.F. )

TRPosition():New(oSection1,"ZA0",1,{|| xFilial("ZA0") + TSQL->ZAF_CODUSR })
TRPosition():New(oSection1,"SA2",1,{|| xFilial("SA2") + TSQL->(ZA0_CODFOR+ZA0_LOJFOR) })

/*

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ STATUS - SETOR 2 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1,"STATUS")
//oSection2:NCLRBACK 	:= 13092807

TRCell():New(oSection2,"STATUS"			,"TSQL","STATUS"		,,20,.F., {|| X3COMBO("ZA1_STATUS", TSQL->ZA1_STATUS) } )
   */
   
                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ DESPESAS - SETOR 3 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1,"DESPESAS", "ZAF")

//METHOD New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore) CLASS TRCell
//TRCell():New(oSection3,"EVENTO"		,"TRB","EVENTO"		,,07,.F. )
TRCell():New(oSection2,"ZAF_STATUS"	,"TSQL","STATUS"		,,15,.F., {|| X3COMBO("ZAF_STATUS", TSQL->ZAF_STATUS) } )
TRCell():New(oSection2,"ZAF_CODIGO"	,"TSQL","CODIGO"	,,7,.F. )
TRCell():New(oSection2,"DT.DESPESA"	,"TSQL","DT.DESPESA"	,,11,.F., {|| DTOC(TSQL->ZAF_DTDESP) } )

IF cDespRef == "SED"
	TRCell():New(oSection2,"ZAF_CODNAT"	,"TSQL","COD.NATUREZA"	,,18,.F. )
ELSEIF cDespRef == "SB1"
	TRCell():New(oSection2,"ZAF_CODPRO"	,"TSQL","COD.PRODUTO"	,,18,.F. )
ENDIF

TRCell():New(oSection2,"DESCDESP"		,"TSQL", "DESCRICAO"		,,41,.F.)
TRCell():New(oSection2,"ZAF_UM"			,"TSQL", "UM"				,,3,.F. )
TRCell():New(oSection2,"ZAF_QTDE"		,"TSQL", "QUANT."			,PESQPICT("ZAF","ZAF_QTDE") ,12,.F. ) 
TRCell():New(oSection2,"ZAF_VLRUNI"	,"TSQL", "VLR.UNITARIO"	,PESQPICT("ZAF","ZAF_VLRUNI")	,12,.F. )
TRCell():New(oSection2,"ZAF_VLRTOT"	,"TSQL", "VLR.TOTAL"		,PESQPICT("ZAF","ZAF_VLRTOT")	,12,.F. )
//TRCell():New(oSection2,"ZAC_DTAPROV"	,"TSQL", "DT.APROV."		,,10,.F. )
//TRCell():New(oSection2,"ZAD_VENCTO"	,"TSQL", "DT.VENC."		,,10,.F. )

TRPosition():New(oSection2,"ZAF",1,{|| xFilial("ZAF") + TSQL->ZAF_CODIGO })

oSection2:SetTotalText(" ")
oSection2:SetTotalInLine(.F.)

//TRFunction():New(oSection3:Cell("DESCRICAO"),NIL,"COUNT")
//	TRFunction():New(oTabZ68:Cell("Z68_ITEM"),NIL,"COUNT",,,,,lEndSection,lEndReport,lEndPage)    
TRFunction():New(oSection2:Cell("CODIGO")		,NIL,"COUNT",,,,,.T.,.T.,.F.)	
TRFunction():New(oSection2:Cell("VLR.TOTAL")	,NIL,"SUM",,,,,.T.,.T.,.F.)	

                                          

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VINCULOS - SETOR 4 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection3 := TRSection():New(oSection2,"VINCULOS","ZA3")

TRCell():New(oSection3,"ZA3_ALIAS"		,"ZA3","COD.TAB."				,,7,.F., )
TRCell():New(oSection3,"ZA3_DESTAB"	,"ZA3","TABELA"				,,15,.F., {|| POSICIONE("SX2",1,ZA3->ZA3_ALIAS,"X2_NOME") } )
TRCell():New(oSection3,"ZA3_DESC"		,"ZA3","DESC. REGISTRO"		,,50,.F., {|| U_CP701DES(TSQL->ZAF_CODREG,ZA3->ZA3_ALIAS,ZA3->ZA3_RECREG) })
TRCell():New(oSection3,"ZA3_INDICE"	,"ZA3","INDICE"				,,2,.F., )
TRCell():New(oSection3,"ZA3_CHVREG"	,"ZA3","CHAVE REGISTRO"		,,25,.F., )


//TRFunction():New(oSection4:Cell("VLRTOT"),"@E 999,999.99","SUM")
//TRFunction():New(oSection4:Cell("QTDUSADA"),"@E 999,999.99","SUM")

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO4     ºAutor  ³Microsiga           º Data ³  11/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a impressao do relatorio de acordo com os parametros    º±±
±±º          ³definos.                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CP07R01P(oReport)

Local oSection1 	:= oReport:Section(1)
Local oSection2 	:= oReport:Section(1):Section(1)
Local oSection3  	:= oReport:Section(1):Section(1):Section(1)
//Local oSection4  	:= oReport:Section(1):Section(1):Section(1):Section(1)
Local aResumo[07]                                       
Local nTotCobrado
Local cAlias
Local nCount		:= 0
Local cAux1			:= "" 
Local cUserFiter	:= ""  
Local nTotCli		:= 0   
Local nQtdEquip		:= 0   
Local nWidth		:= 0  
//| Parametros
Local dDtIni, dDtFim, cUsrDe, cUsrAte, cDespDe, cDespAte, cStatus, nVinculos

/*------------------------------------------------------------|  Augusto Ribeiro - 16/02/2015
	PARAMETROS - Visa faciliatar manutencao caso exista troca da ordem das pergundas.
-------------------------------------------------------------------------------------------*/
Pergunte(oReport:uParam,.F.)

dDtIni		:= MV_PAR01
dDtFim		:= MV_PAR02
cUsrDe		:= MV_PAR03
cUsrAte	:= MV_PAR04
cDespDe	:= MV_PAR05
cDespAte	:= MV_PAR06
cStatus	:= MV_PAR07
nVinculos 	:= MV_PAR08 //| 1=SIM;2=NAO

nVinculos := IIF(EMPTY(nVinculos),1,nVinculos)  

DBSELECTAREA("ZA3")
ZA3->(DBSETORDER(1)) //| ZA3_FILIAL, ZA3_CODIGO, ZA3_ITEM, R_E_C_N_O_, D_E_L_E_T_


LJMsgRun("Verificando Registros..",, {|| qGeral(oSection1:nOrder) } )

DBSelectArea("TSQL")
TSQL->(DBGoTop())	
TSQL->( dbEval( {|| nCount++ } ) )	
TSQL->(DBGoTop())

oReport:SetMeter(nCount)

//cAux1	:= TCLI->CLIENTE+TCLI->LOJA    

oReport:SetTitle("REEMBOLSO DE DESPESA - PERIODO "+DTOC(dDtIni)+"  - "+DTOC(dDtFim))
oReport:StartPage()	

While TSQL->( !Eof() )
	
	If oReport:Cancel()
		Exit
	EndIf
	
	
	oSection1:Init()
	oSection1:PrintLine()		

	//| QUEBRA POR USUARIOS
	cCodUsr	:= TSQL->ZAF_CODUSR
	
	oSection2:Init()
	While !oReport:Cancel() .AND. TSQL->( !Eof() ) .AND.  cCodUsr == TSQL->ZAF_CODUSR
		/*
			
		//| QUEBRA POR STATUS
		// oSection2:Init()
		cStatus	:= 	TSQL->ZA1_STATUS	
		While !oReport:Cancel() .AND. TSQL->( !Eof() ) .AND.;
			 cCodUsr == TSQL->ZA1_CODUSR .AND.;
			 cStatus == TSQL->ZA1_STATUS
			
			oSection2:PrintLine()
			
			
			
			
			 
			TSQL->(dbskip())
		ENDDO	
		//	oSection2:Finish()
		*/
		
		oSection2:PrintLine()
		
		
		/*------------------------------------------------------------|  Augusto Ribeiro - 16/02/2015
			SETOR 3 - VINCULOS
		-------------------------------------------------------------------------------------------*/
		IF nVinculos == 1
			ZA3->(DBGOTOP())
			IF ZA3->(DBSEEK(xfilial("ZA3")+TSQL->ZAF_CODIGO)) 
				oSection3:Init()
				WHILE ZA3->(!EOF()) .AND. ZA3->ZA3_CODIGO == TSQL->ZAF_CODIGO
					
					oSection3:PrintLine()
				
					ZA3->(DBSKIP()) 
				ENDDO				
				oSection3:Finish()	
				oReport:ThinLine()
				oReport:SkipLine()
			ENDIF
		ENDIF
		
		
		
		TSQL->(dbskip())
	ENDDO	
	
	oSection2:Finish()
	
	oSection1:Finish()
	
	oReport:EndPage()
	
EndDo


Return




/*/{Protheus.doc} qGeral
Query para composição do relatorio.
@author Augusto Ribeiro | www.compila.com.br
@since 16/02/2015
@version 1.0
@param nOrder, N,  Order by a ser utilizado
@return ${return}, ${return_description}
/*/
Static Function qGeral(nOrder)
Local cQuery 	:= ""
Local aDtComp	:= {} 

Default nOrder	 := 1


dDtIni		:= MV_PAR01
dDtFim		:= MV_PAR02
cUsrDe		:= MV_PAR03
cUsrAte	:= MV_PAR04
cDespDe	:= MV_PAR05
cDespAte	:= MV_PAR06
cStatus	:= MV_PAR07
nVinculos 	:= MV_PAR08 //| 1=SIM;2=NAO

                                
cQuery := " SELECT ZAF_CODUSR, ZA0_NOME, ZA0_CODFOR, ZA0_LOJFOR, A2_NOME, "+CRLF
cQuery += " 		ZAF_STATUS, "+CRLF
cQuery += " 		ZAF_CODIGO, ZAF_DTDESP, ZAF_CODPRO, ZAF_CODNAT,
IF cDespRef == "SED" 
	cQuery += " 		SED.ED_DESCRIC AS DESCDESP,  "+CRLF
ELSEIF cDespRef == "SB1"
	cQuery += " 		SB1.B1_DESC AS DESCDESP,  "+CRLF
ENDIF
cQuery += " 		ZAF_UM, ZAF_QTDE, ZAF_VLRUNI, ZAF_VLRTOT, "+CRLF
cQuery += " 		ZAF_CODREG "+CRLF
cQuery += " FROM "+RetSqlName("ZAF")+" ZAF "+CRLF
cQuery += " INNER JOIN "+RetSqlName("ZA0")+" ZA0 "+CRLF
cQuery += " 	ON ZA0_FILIAL = '"+XFILIAL("ZA0")+"' "+CRLF
cQuery += " 	AND ZA0_CODIGO = ZAF_CODUSR "+CRLF
cQuery += " 	AND ZA0.D_E_L_E_T_ = '' "+CRLF
cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 "+CRLF
cQuery += " 	ON A2_FILIAL = '"+XFILIAL("SA2")+"' "+CRLF
cQuery += " 	AND A2_COD = ZA0_CODFOR "+CRLF
cQuery += " 	AND A2_LOJA = ZA0_LOJFOR "+CRLF
cQuery += " 	AND SA2.D_E_L_E_T_ = '' "+CRLF

IF cDespRef == "SED" 
	cQuery += " LEFT JOIN "+RetSqlName("SED")+" SED "+CRLF
	cQuery += " 	ON SED.ED_FILIAL = '"+XFILIAL("SED")+"' "+CRLF
	cQuery += " 	AND SED.ED_CODIGO = ZAF_CODNAT "+CRLF
	cQuery += " 	AND SED.D_E_L_E_T_ = '' "+CRLF
ELSEIF cDespRef == "SB1"
	cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 "+CRLF
	cQuery += " 	ON SB1.B1_FILIAL = '"+XFILIAL("SB1")+"' "+CRLF
	cQuery += " 	AND SB1.B1_COD = ZAF_CODPRO "+CRLF
	cQuery += " 	AND SB1.D_E_L_E_T_ = '' "+CRLF
ENDIF

cQuery += " WHERE ZAF_FILIAL =  '"+XFILIAL("ZA0")+"' "+CRLF
cQuery += " AND ZAF_DTDESP BETWEEN '"+DTOS(dDtIni)+"' AND  '"+DTOS(dDtFim)+"' "
cQuery += " AND ZAF_CODUSR BETWEEN '"+cUsrDe+"' AND  '"+cUsrAte+"' "

IF cDespRef == "SED"
	cQuery += " AND ZAF_CODNAT BETWEEN '"+cDespDe+"' AND  '"+cDespAte+"' "
ELSEIF cDespRef == "SB1"
	cQuery += " AND ZAF_CODPRO BETWEEN '"+cDespDe+"' AND  '"+cDespAte+"' "
ENDIF



IF !EMPTY(cStatus)
	cQuery += " AND ZAF.ZAF_STATUS IN "+INQuery(cStatus, ,1)
ENDIF



cQuery += " AND ZAF.D_E_L_E_T_ = '' "+CRLF

IF nOrder == 1
	cQuery += " ORDER BY ZAF_STATUS, ZAF_CODUSR, ZAF_CODIGO  "+CRLF
ELSEIF nOrder == 2
	cQuery += " ORDER BY ZAF_STATUS, ZAF_CODUSR, ZAF_DTDESP  "+CRLF
ENDIF


//AVISO("tESTE", cQuery, {"Sim", "Não"},3,"TESTE")

If Select("TSQL") > 0
	TSQL->(DbCloseArea())
EndIf

DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TSQL", .F., .T.)
                         
TCSetField("TSQL","ZAF_DTDESP","D",08,00)


Return
                      



/*/{Protheus.doc} CP07R01Z
Chama Browser do SX1 
@author Augusto Ribeiro | www.compila.com.br
@since 16/02/2015
@version 1.0
@return cRet, Retorno do Item selecionado
@example
(examples)
@see (links_or_references)
/*/
User Function CP07R01Z()
Local cRet		:= ""                   
Local aStatus	:= {}
Local aOpcoes := {}
Local cOpcao	:= ""
Local aArea	:= SX3->(GetArea())

Local nI 		:= 1



DBSELECTAREA("SX3")
SX3->(dbsetorder(2))
SX3->(DBGOTOP())

IF SX3->(DBSEEK("ZAF_STATUS"))
	aOpcoes	:= StrTokArr(SX3->X3_CBOX,";")


	FOR nI := 1 to len(aOpcoes)
		
		cOpcao	:= alltrim(aOpcoes[nI])
		aadd(aStatus,{LEFT(cOpcao,1), ALLTRIM(RIGHT(cOpcao,LEN(cOpcao)-2))} )
	
	NEXT nI 

	
ENDIF

cRet := U_CPXBrwX1("Status", aStatus)
   
      
RestArea(aArea)

Return(cRet)       



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AUGUSTO RIBEIRO                                  ³   
//³                                                  ³
//³ Recebe String separa por caracter "X"            ³
//³ ou Numero de Caractres para "quebra" _nCaracX)   ³
//³ Retorna String pronta para IN em selects         ³
//³ Ex.: Retorn: ('A','C','F')                       ³
//³                                                  ³
//³ PARAMETROS:  _cString, _cCaracX                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function INQuery(_cString, _cCaracX, _nCaracX)
Local _cRet	:= ""                  
Local _cString, _cCaracX, _nCaracX, nY
Local _aString	:= {}                            
Default	_nCaracX := 0                   
                                                                  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida Informacoes Basicas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    IF !EMPTY(_cString) .AND. (!EMPTY(_cCaracX) .OR. _nCaracX > 0)
                                
    	nString	:= LEN(_cString)
    	
		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza Separacao por Numero de Caracteres ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF _nCaracX > 0
			FOR nY := 1 TO nString STEP _nCaracX
			
				AADD(_aString, SUBSTR(_cString,nY, _nCaracX) )
			
			Next nY
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza Separacao por caracter especifico ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ELSE
			_aString	:= WFTokenChar(_cString, _cCaracX)		
		ENDIF
	                


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta String para utilizar com IN em querys³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cRet	+=  "('"		
		FOR _nI := 1 TO Len(_aString)
			IF _nI > 1
				_cRet	+= ",'"
			ENDIF
			_cRet += ALLTRIM(_aString[_nI])+"'"	
		Next _nI
		_cRet += ") "  
		
	ENDIF

Return(_cRet) 




/*/{Protheus.doc} AjustSX1
Criar perguntas
@author Augusto Ribeiro | www.compila.com.br
@since 16/02/2015
@version 1.0
@param cPerg, C, Nome do grupo de perguntas
/*/
Static Function AjustSX1(cPerg)

Local aArea := GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

aAdd( aHelpEng, "  ")
aAdd( aHelpSpa, "  ")



aHelpPor := {} ; Aadd( aHelpPor, "Data Despesa De")
xPutSx1( cPerg, "01","Data Despesa De","","","mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Data Despesa Ate")
xPutSx1( cPerg, "02","Data Despesa Ate","","","mv_ch2","D",08,0,0,"G","NaoVazio","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Código do usuario De")
xPutSx1( cPerg, "03","Usuario De"	,"","","mv_ch3","C",6,0,0,"G","","ZA0","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Código do usuario Ate")
xPutSx1( cPerg, "04","Usuario Ate"	,"","","mv_ch4","C",6,0,0,"G","NaoVazio","ZA0","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Codigo da Despesa De")
xPutSx1( cPerg, "05","Cod. Natueza De"	,"","","mv_ch5","C",6,0,0,"G","","SED","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Codigo da Despesa Ate")
xPutSx1( cPerg, "06","Cod. Natureza Ate","","","mv_ch6","C",6,0,0,"G","NaoVazio","SED","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Status do Reembolso")
xPutSx1( cPerg, "07","Status","","","mv_ch7","C",6,0,0,"G","U_CP07R01Z","","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Imprimir Vinculos")
xPutSx1( cPerg, "08","Imprimir Vinculos","","","mv_ch8","N",01,0,0,"C","","","","","mv_par08","Sim","","","","Nao","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

Return()




/*/{Protheus.doc} xPutSX1
Ajusta Perguntas - SX1
@author Fabio Sales | www.compila.com.br
@since 05/11/2018
@version 1.0
/*/

Static Function xPutSX1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp, cPicture)

	Local aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa  := .f.
	Local lIngl := .f. 

	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme           == Nil, " ", cPyme        )
	cF3      := Iif( cF3             == NIl, " ", cF3          )
	cGrpSxg  := Iif( cGrpSxg  == Nil, " ", cGrpSxg      )
	cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01       )
	cHelp := Iif( cHelp            == Nil, "" , cHelp        )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

	// Ajusta o tamanho do grupo. Ajuste emergencial para validaÃ§Ã£o dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt	:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa		:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng		:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01

		If cGSC == "C"                   // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP  With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		SX1->X1_PICTURE				:= cPicture

		MsUnlock()
	Else

		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

		If lPort .Or. lSpa .Or. lIngl
			If lPort 
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf

			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf

			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif
	
	

	RestArea( aArea )

Return


