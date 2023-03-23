 #INCLUDE "TOTVS.CH"
 
 /*/{Protheus.doc} FA090TIT
    Ponto de entrada validação do banco contas a pagar
    @type  User Function
    @author Julio Teixeira - Compila
    @since 06/04/2020
    @version 12
    @param lRet, lógico, Retorno se a validação teve sucesso ou não
/*/
User Function FA090TIT()
        
    Local lRet := .T.    

    If ExistFunc("U_ALPEFIN")
        lRet := U_ALPEFIN("FA090TIT")
    Endif    

Return lRet