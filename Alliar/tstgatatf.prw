#Include 'Protheus.ch'

User Function tstgatatf()

local oModelx
local cRet := ""

oModelx := FWModelActive() //Carregando Model Ativo

oModelxDet := oModelx:GetModel('SN1MASTER') //Carregando Master de dados a partir o ID que foi instanciado no fonte.

OMODELXDET:ADATAMODEL[1][7][2] := STRZERO(VAL(M->N1_ITEM),5)

oView := FwViewActive()

oView:Refresh()


Return STRZERO(VAL(M->N1_ITEM),5)
