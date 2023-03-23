/*/{Protheus.doc} FA070TIT
Fun��o para validar o desconto concedido na baixa manual.
@type function
@version 
@author Valdemar Merlim
@since 09/12/2020
@return Logico, Valida ou n�o a baixa manual
/*/
User Function FA070TIT()
    Local _aArea := GetArea()
    Local _lRet  := .T.

    If cEmpAnt="14"
        If !Empty(SE1->E1_XPRODES) .AND. NDESCONT >= 5000 // Desconto de 1000 reais e depois ser� Desconto de 15 centavos acima n�o deixa passar, porem a menor deixa aplicar desconto pois � sobra de centavos - Chamado Suzara/Gustavo 20210827 isso depois de equalizar os titulos
            If nDescont > 0 
                MsgStop("***ATEN��O***, Este titulo j� sofreu a baixa com desconto, favor zerar o campo '-Descontos' para executar a baixa.")
                _lRet := .F.
            EndIf
        EndIf
    EndIf

    RestArea(_aArea)
Return(_lRet)
