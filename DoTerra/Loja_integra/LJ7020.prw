#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'rwmake.ch'

/*------------------------------------------------------
|Ponto de Entrada - Alteração condição de pagamento     |
|efetivar a venda.                                      |
|Desenvolvedor Diogo Melo                               |
|Data: 01/09/2019                                       |
--------------------------------------------------------*/

User Function LJ7020()

Local cUsrPag   := SUPERGETMV("MV_XUSRPAG",.T.,"000000" ) //PDV01 000985
Local cUsuario := UsrRetName(cUsrPag)

If cUsuario  $  UsrRetName(RetCodUsr())

Return ( ParamIXB[01] == 'CONVENIO' ;
    .OR. ParamIXB[01] == 'VALES' ;
    .OR. ParamIXB[01] == 'CARTAO DE CREDITO'; 
    .OR. ParamIXB[01] == 'CARTAO DE DEBITO AUTOMATICO'; 
    .OR. ParamIXB[01] == 'TRANFERENCIA BANCARIA'; 
    .OR. ParamIXB[01] == 'CHEQUE';
    .OR. ParamIXB[01] == 'COND.NEGOCIADA';
    .OR. ParamIXB[01] == 'ZERAR PAGAMENTOS';   
    .OR. ParamIXB[01] == "DINHEIRO"; 
    .OR. ParamIXB[01] == 'FINANCIADO' )

else

    Return !( ParamIXB[01] == 'CONVENIO' ;
    .OR. ParamIXB[01] == 'VALES' ;
    .OR. ParamIXB[01] == 'CARTAO DE DEBITO AUTOMATICO'; 
    .OR. ParamIXB[01] == 'TRANFERENCIA BANCARIA'; 
    .OR. ParamIXB[01] == 'CHEQUE';
    .OR. ParamIXB[01] == 'COND. NEGOCIADA';
    .OR. ParamIXB[01] == "DINHEIRO"; 
    .OR. ParamIXB[01] == "TRANSFERENCIA BANCARIA"; 
    .OR. ParamIXB[01] == "COND.NEGOCIADA"; 
    .OR. ParamIXB[01] == 'FINANCIADO' ) 

EndIf