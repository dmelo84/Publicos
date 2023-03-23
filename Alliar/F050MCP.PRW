#INCLUDE "PROTHEUS.CH"

User Function F050MCP()

Local cLibCmp := paramixb

AADD(cLibCmp,"E2_CCD")
AADD(cLibCmp,"E2_LINDIG")
AADD(cLibCmp,"E2_FORAGE")
AADD(cLibCmp,"E2_FAGEDV")
AADD(cLibCmp,"E2_FORCTA")
AADD(cLibCmp,"E2_FCTADV")
AADD(cLibCmp,"E2_FORBCO")
AADD(cLibCmp,"E2_FORMPAG") 
AADD(cLibCmp,"E2_DATAAGE")
AADD(cLibCmp,"E2_NATUREZ")
AADD(cLibCmp,"E2_VENCTO")    
AADD(cLibCmp,"E2_VENCREA")
AADD(cLibCmp,"E2_ACRESC")
AADD(cLibCmp,"E2_DECRESC")

Return cLibCmp