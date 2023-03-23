 #INCLUDE "TOTVS.CH"
 
 /*/{Protheus.doc} F070BTOK
    Ponto de entrada TUDO OK baixa manual
    @type  User Function
    @author Julio Teixeira
    @since 03/04/2020
    @version 12
    @param lRet, l�gico, Retorno se a valida��o teve sucesso ou n�o
/*/
User Function F070BTOK()
        
    Local lRet := .T.    

    If ExistFunc("U_ALPEFIN")
        lRet := U_ALPEFIN("F070BTOK")
    Endif    

Return lRet