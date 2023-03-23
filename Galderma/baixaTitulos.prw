#Include 'Protheus.ch'
#include "restful.ch"
#include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"

user function bxTitulos(cFil, cEmp)

Default cFil     := cFilAnt //"01"
Default cEmp     := cEmpAnt //"99"

    If !empty(cEmp) 
        RpcClearEnv() //Se tiver aberto, fecha o ambiente
        RPCSetType(3)  //Nao consome licensas
        lAberto := RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })
    EndIf

return

static Function BxFINA080(nOpc, nVlrPag, nSeqBx)

    Local cChave     := ""
    Local lRet       := .T.
    Local lExibeLanc := .T.
    Local lOnline    := .T.
 
    //Operação a ser realizada (3 = Baixa, 5 = cancelamento, 6 = Exclusão)
    Default nOpc := 3
    //Valor a ser baixado
    Default nVlrPag := 0
    //Sequência de baixa a ser cancelada.
    Default nSeqBx := 1
 
    Private lMsErroAuto := .F.
    Private cHistBaixa := "Teste exclusão fina080"
 
    DbSelectArea("SE2")
    SE2->(dbSetOrder(1))
    SE2->(dbGoTop())
    SE2->(DbSeek(xFilial("SE2") + "FIN" + "052600002"))
 
    cChave := SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
 
    If SE2->(dbSeek(cChave))
        If nOpc == 3
            If lRet := (nVlrPag + SE2->E2_SALDO) > 0
                nVlrPag := If(nVlrPag > 0, nVlrPag, SE2->E2_SALDO)
            EndIf
        ElseIf SE2->E2_VALOR >= SE2->E2_SALDO
            nVlrPag := 0
        EndIf
     
        If lRet
            aBaixa := {}        
         
            Aadd(aBaixa, {"E2_FILIAL", SE2->E2_FILIAL,  nil})
            Aadd(aBaixa, {"E2_PREFIXO", SE2->E2_PREFIXO,  nil})
            Aadd(aBaixa, {"E2_NUM", SE2->E2_NUM,      nil})
            Aadd(aBaixa, {"E2_PARCELA", SE2->E2_PARCELA,  nil})
            Aadd(aBaixa, {"E2_TIPO", SE2->E2_TIPO,     nil})
            Aadd(aBaixa, {"E2_FORNECE", SE2->E2_FORNECE,  nil})
            Aadd(aBaixa, {"E2_LOJA", SE2->E2_LOJA ,    nil})
            Aadd(aBaixa, {"AUTMOTBX", "NOR",            nil})
            Aadd(aBaixa, {"AUTBANCO", "001",            nil})
            Aadd(aBaixa, {"AUTAGENCIA", "AG001",          nil})
            Aadd(aBaixa, {"AUTCONTA", "CTA001 ",     nil})
            Aadd(aBaixa, {"AUTDTBAIXA", dDataBase,        nil})
            Aadd(aBaixa, {"AUTDTCREDITO", dDataBase,        nil})
            Aadd(aBaixa, {"AUTHIST", cHistBaixa,       nil})
            Aadd(aBaixa, {"AUTVLRPG", nVlrPag,          nil})
 
            //Pergunte da rotina
             AcessaPerg("FINA080", .F.)                  
         
            //Chama a execauto da rotina de baixa manual (FINA080)
            MsExecauto({|a,b,c,d,e,f,| FINA080(a,b,c,d,e,f)}, aBaixa, nOpc, .F., nSeqBx, lExibeLanc, lOnline)
         
            If lMsErroAuto
                MostraErro()
            Else
                If nOpc == 3
                    Alert("Baixa efetuada com sucesso")
                Else
                    Alert("Exclusão realizada com sucesso")
                EndIf
            EndIf
        Else
            Alert("O título não possui saldo a pagar em aberto")
        EndIf
    Else
        Alert("O título a pagar não foi localizado")
    EndIf
 
Return
