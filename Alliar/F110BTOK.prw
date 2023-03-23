 #INCLUDE "TOTVS.CH"
 
 /*/{Protheus.doc} F110BTOK
    Ponto de entrada TUDO OK baixa automática
    @type  User Function
    @author Julio Teixeira
    @since 03/04/2020
    @version 12
    @param lRet, lógico, Retorno se a validação teve sucesso ou não
/*/
User Function F110BTOK()
        
    Local lRet := .T.    

    If ExistFunc("U_ALPEFIN")
        lRet := U_ALPEFIN("F110BTOK")
    Endif    

Return lRet