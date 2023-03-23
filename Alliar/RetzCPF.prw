#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

User Function RetZCPF()
Local cRet := ""

cRet := IF((SA2->A2_ZMICROE)=="1",strzero(Val(SA2->A2_ZCPF),11),IF(!EMPTY(SA2->A2_CGC),strzero(Val(SA2->A2_CGC),14),STRZERO(0,14)))
        
Return cRet
