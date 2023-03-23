#include "protheus.ch"
#include "totvs.ch"
#include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"

#define enter chr(13) + chr(10)

user function alteraTituloSE1(cEmp,cFil)

Default cFil     := cFilAnt //"01"
Default cEmp     := cEmpAnt //"99"

If !empty(cEmp) 
	RpcClearEnv() //Se tiver aberto, fecha o ambiente
	RPCSetType(3)  //Nao consome licensas
	lAberto := RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })
EndIf

dbselectArea("SF2")
SF2->(dbGoTop())
dbSelectArea("SE1")
SE1->(dbGoTop())

while SF2->(!eof())

    dDataSF2  := SF2->F2_XDTENTR
    cPrefSF2  := SF2->F2_PREFIXO
    cDuplSF2 := SF2->F2_DUPL 
    cCliSF2   := SF2->F2_CLIENTE
    cLjSF2    := SF2->F2_LOJA

    while SE1->(!eof())

        dDataSE1  := SE1->E1_VENCTO
        cPrefSE1  := SE1->E1_PREFIXO
        cDuplSE1  := SE1->E1_NUM
        cCliSE1   := SE1->E1_CLIENTE
        cLjSE1    := SE1->E1_LOJA
        AtuTitSE1 := SE1->E1_ATUTIT
        
        if cPrefSF2 == cPrefSE1 .and. cDuplSF2 == cDuplSE1 .and. cCliSF2 == cCliSE1 .and. cLjSF2 == cLjSE1

            cCondPg := posicione("SA1",1,xFilial("SA1")+cCliSE1+cLjSE1,'A1_COND')
            aDtAtu := condicao(SE1->E1_VALOR,cCondPg,,dDataBase)

            if abs(dDataSF2 - dDataSE1) <= 10 .and. AtuTitSE1 != "S"
                u_simpleStartProcess(cPrefSE1,;
                                    SE1->E1_PARCELA,;
                                    cDuplSE1,;
                                    SE1->E1_TIPO,;
                                    cCliSE1,;
                                    SE1->E1_NOMCLI,;
                                    Transform( SE1->E1_VALOR, "@E 9,999,999.99"),;
                                    dtoc(aDtAtu[1][1]),;
                                    dtoc(SE1->E1_VENCTO),;
                                    "Solicitação inserida via WebService")
                Reclock("SE1",.F.)
                    replace SE1->E1_ATUTIT with "S"
                MsUnlock()
            endif

        endif

    SE1->(dbSkip())
    EndDo
        
       
SF2->(dbSkip())
EndDo

SF2->(dbCloseArea())
SE1->(dbCloseArea())

return
