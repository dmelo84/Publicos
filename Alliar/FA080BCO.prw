 #INCLUDE "TOTVS.CH"
 
 /*/{Protheus.doc} FA080BCO
    Ponto de entrada valida��o do banco contas a pagar
    @type  User Function
    @author Julio Teixeira - Compila
    @since 06/04/2020
    @version 12
    @param lRet, l�gico, Retorno se a valida��o teve sucesso ou n�o
/*/
User Function FA080BCO()
        
    Local lRet := .T.    

    If ExistFunc("U_ALPEFIN")
        lRet := U_ALPEFIN("FA080BCO")
    Endif    

Return lRet