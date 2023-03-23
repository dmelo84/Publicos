#include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"
#INCLUDE "RPTDEF.CH"  
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} RFIN005

Títulos a Pagar

@author Julio Teixeira - Compila
@since 29/05/2020
@version 12
@param param
@return return, return_description
/*/
USER FUNCTION RFIN005()

    Local oReport     
    Local aRet	:= {.T.,""}
    Private aLote	:= {}
    Private cProds := ""

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

    Local cPerg		:= "RFIN005"    
    Local cDescRel	:= "Relatório - Contas a Pagar" +CRLF
    Local cCampos   := ""
    Local aCampos   := {}
    Local nX        := 1 

    cCampos := "E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_NATUREZ,E2_FORNECE,E2_LOJA,E2_NOMFOR,"
    cCampos += "E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_VALOR,E2_VALLIQ,E2_ISS,E2_IRRF,E2_BAIXA,E2_HIST,E2_SALDO,"
    cCampos += "E2_DESCONT,E2_MULTA,E2_JUROS,E2_NUMBOR,E2_ACRESC,E2_INSS,E2_DECRESC,E2_USUALIB,E2_COFINS,E2_PIS,"
    cCampos += "E2_CSLL,E2_LINDIG,E2_CODBAR,E2_MDCONTR,E2_FORBCO,E2_FORAGE,E2_FAGEDV,E2_FORCTA,E2_FCTADV,E2_CCUSTO,"
    cCampos += "E2_FORMPAG,E2_XIDFLG,E2_XTPINT,E2_XTPDOC,E2_XCOMPME"

    aCampos := STRTOKARR( cCampos, "," )

    oReport := TReport():New("RFIN005"," Contas a Pagar" , cPerg , {|oReport| PrintRel(oReport)} ,cDescRel)

    oReport:SetLandscape()
    oReport:SetTotalInLine(.F.) 

    Pergunte(oReport:uParam,.F.)

    oSection1 := TRSection():New(oReport,"Contas a Pagar", {"SE2"})

    For nX := 1 to len(aCampos)
        If nX == 6
            TRCell():New(oSection1,"B1_DESC"	,	 ,"Descrição do serviços/produto"	,,15,.F., {|| left(cProds,250) } ) 
        Endif

        If nX == 14
           TRCell():New(oSection1,"E1_XVALLIQ"	,	 ,"Valor Liquido"	,,15,.F., {||  SE2->(E2_VLCRUZ+E2_VRETIRF+E2_ACRESC-E2_DECRESC-E2_PIS-E2_COFINS-E2_CSLL-E2_IRRF)} )                                                         
        Endif

        TRCell():New(oSection1, aCampos[nX], "SE2", FWSX3Util():GetDescription( aCampos[nX] ) ,,20,.F.)
    Next nX

Return oReport


Static Function PrintRel(oReport)

    Local oSection1 := oReport:Section(1)  	
    Local nCount  := 0  
    Private cFilialAtu	:= ""
    Private	cBanco 		:= ""
    Private cAg 		:=  ""
    Private cConta		:= ""

    MsgRun("Verificando Registros...",, {|| qBanco() } )

    IF E2REL->(!EOF())
        
        DBSelectArea("E2REL")
        E2REL->(DBGoTop())	
        E2REL->( dbEval( {|| nCount++ } ) )	
        E2REL->(DBGoTop())
        
        oReport:SetMeter(nCount)			 	
        oReport:StartPage()	
        
        oSection1:Init()

        WHILE E2REL->(!EOF()) 
            SE2->(DBGOTO( E2REL->(E2_RECNO) ))  
            cProds +=  Alltrim(E2REL->(B1_DESC))+", "
            E2REL->(DBSKIP())

            If SE2->(Recno()) != E2REL->(E2_RECNO)  
                
                While Right(cProds,1) == " " .OR. Right(cProds,1) == ","
                    cProds := Left(cProds, len(cProds)-1) 
                Enddo
                
                oReport:IncMeter()
                If oReport:Cancel()
                    Exit
                EndIf	
                oSection1:PrintLine()
                cProds := ""
            Endif   
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
Local aTipos := STRTOKARR( Alltrim(MV_PAR11), "," )
Local nX := 1

	cQuery := " SELECT ISNULL(B1_DESC,'') B1_DESC,"
    cQuery += " E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_NATUREZ, E2_FORNECE, E2_LOJA, E2_NOMFOR, "
    cQuery += " E2_EMISSAO, E2_VENCTO, E2_VENCREA, E2_VALOR, E2_VALLIQ, E2_ISS, E2_IRRF, E2_BAIXA, E2_HIST, E2_SALDO, "
    cQuery += " E2_DESCONT, E2_MULTA, E2_JUROS, E2_NUMBOR, E2_ACRESC, E2_INSS, E2_DECRESC, E2_USUALIB, E2_COFINS, E2_PIS, "
    cQuery += " E2_CSLL, E2_LINDIG, E2_CODBAR, E2_MDCONTR, E2_FORBCO, E2_FORAGE, E2_FAGEDV, E2_FORCTA, E2_FCTADV, E2_CCUSTO, "
    cQuery += " E2_FORMPAG, E2_XIDFLG, E2_XTPINT, E2_XTPDOC, E2_XCOMPME, SE2.R_E_C_N_O_ E2_RECNO "
    cQuery += " FROM "+RetSqlName("SE2")+" SE2 "
    cQuery += " LEFT JOIN "+RetSqlName("SD1")+" SD1 ON D1_ITEM = '0001' AND D1_DOC = E2_NUM AND D1_SERIE = E2_PREFIXO AND D1_FORNECE = E2_FORNECE AND D1_LOJA = E2_LOJA AND SD1.D_E_L_E_T_ = '' "
    cQuery += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON D1_COD = B1_COD AND SB1.D_E_L_E_T_ = '' "
    cQuery += " WHERE SE2.D_E_L_E_T_ = '' AND "
    cQuery += " E2_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
    cQuery += " E2_VENCREA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND "
    cQuery += " E2_FORNECE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR07+"' AND "
    cQuery += " E2_LOJA BETWEEN '"+MV_PAR06+"' AND '"+MV_PAR08+"' AND " 
    cQuery += " E2_NATUREZ BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"' "  
    If !Empty(MV_PAR11) 
        cQuery += " AND E2_TIPO NOT IN ( "
        For nX := 1 to len(aTipos)
            cQuery += "'"+aTipos[nX]+"'," 
        Next nX 
        cQuery += "'')"
    Endif
    cQuery += " order by E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA "+CRLF
	cQuery := ChangeQuery(cQuery)	

	If Select("E2REL") > 0
		E2REL->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQRY(,,cQuery),'E2REL')

	TCSetField("E2REL","E2_EMISSAO","D",08,00)
    TCSetField("E2REL","E2_VENCTO","D",08,00)
    TCSetField("E2REL","E2_VENCREA","D",08,00)
    TCSetField("E2REL","E2_BAIXA","D",08,00)

Return()