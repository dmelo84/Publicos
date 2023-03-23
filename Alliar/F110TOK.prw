#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} F110TOK
    Ponto de entrada TUDO OK baixa automática
    @type  User Function
    @author Julio Teixeira
    @since 03/04/2020
    @version 12
    @param lRet, lógico, Retorno se a validação teve sucesso ou não
/*/
User Function F110TOK()
        
    Local lRet := .T.    

    If ExistFunc("U_ALPEFIN")
        lRet := U_ALPEFIN("F110TOK")
    Endif    

Return lRet