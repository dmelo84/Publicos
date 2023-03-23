 #INCLUDE "TOTVS.CH"
 
 /*/{Protheus.doc} FA080BCO
    Ponto de entrada validação do banco contas a pagar
    @type  User Function
    @author Julio Teixeira - Compila
    @since 06/04/2020
    @version 12
    @param lRet, lógico, Retorno se a validação teve sucesso ou não
/*/
User Function FA080BCO()
        
    Local lRet := .T.    

    If ExistFunc("U_ALPEFIN")
        lRet := U_ALPEFIN("FA080BCO")
    Endif    

Return lRet