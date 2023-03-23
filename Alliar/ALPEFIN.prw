#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} ALPEFIN
    
    Fun��o que executa as funcionalidades e valida��es de acordo com o ponto de entrada recebido

    @type  Function
    @author Julio Teixeira - Compila
    @since 03/04/2020
    @version version
    @param cNomePE, C, Nome do ponto de entrada que foi chamado
    @return lRet
/*/
User Function ALPEFIN(cNomePE)
    
    Local lRet := .T.
    Local lVldMarcR := SuperGetMV("AL_VLDMCR",.F.,.F.)
    Local lVldMarcP := SuperGetMV("AL_VLDMCP",.F.,.F.)

    Default cNomePE := ""

    DO CASE
        CASE cNomePE == "F070BTOK"
            If lVldMarcR
                lRet := VldMarca(cBanco+cAgencia+cConta,SE1->E1_FILORIG)
            Endif
        CASE cNomePE == "F110TOK"
            If lVldMarcR
                lRet := VldMarca(Paramixb[1]+Paramixb[2]+Paramixb[3])
            Endif 
        CASE cNomePE == "FA080BCO"
            If lVldMarcP
                lRet := VldMarca(Paramixb[1]+Paramixb[2]+Paramixb[3],SE2->E2_FILORIG)
            Endif
        CASE cNomePE == "FA090TIT"
            If lVldMarcP
                lRet := VldMarca(Paramixb[1]+Paramixb[2]+Paramixb[3],SE2->E2_FILORIG)
            Endif
        OTHERWISE
    ENDCASE

Return lRet


/*/{Protheus.doc} VldMarca

    Fun��o respons�vel por validar a marca do banco verificando se corresponde com a marca da filial

    @type  Static Function
    @author Julio Teixeira - Compila
    @since 03/04/2020
    @version 12
    @param cBank - C�digo do banco SA6, cFilChk - C�digo da filial do t�tulo 
    @return lRet - verdadeiro ou falso de acordo com valida��o
    /*/
Static Function VldMarca(cBank,cFilChk)

Local lRet := .T.
Local cMarcaBanc := ""
Local aArea := GetArea()
Local cMsgErro := ""
Default cBank := ""
Default cFilChk := cFilAnt 

If !Empty(cBank) 
    DbSelectArea("SA6")
    SA6->(DbSetOrder(1))
    If SA6->(MsSeek(xFilial("SA6")+cBank))
        cMarcaBanc := SA6->A6_XCODMAR
        DbSelectArea("SZK")
        SZK->(DbSetOrder(1))
        If SZK->(MsSeek(cEmpAnt+cFilChk))
            If cMarcaBanc != SZK->ZK_XCODMAR
                lRet := .F.//Apenas deve ser utilizado bancos com a mesma marca da filial
                cMsgErro := "N�o � permitido utilizar a conta banc�ria "+SA6->A6_NUMCON
                cMsgErro += ", para esta filial "+cFilChk 
                cMsgErro += ". Necess�rio selecionar outra conta."
                If IsBlind()
                    Help("",1,"ALPEFIN",,cMsgErro,1,0)    
                Else    
                    FwHelpShow("ALPEFIN","",cMsgErro,"Utilize outra conta.")
                Endif
            Endif
        Endif
    Endif
Endif
    
RestArea(aArea)

Return lRet
