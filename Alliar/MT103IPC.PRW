#Include "RwMake.ch"
User Function MT103IPC()
***********************************************************************************
*
*
*
*******

Local aAreaOLD  := GetArea()
Local aAreaSD1  := GetArea("SD1")
Local aAreaSB1  := GetArea("SB1")

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+GDFieldGet("D1_COD",paramixb[1]))
GDFieldPut("D1_XDESC",SB1->B1_DESC,paramixb[1])

RestArea(aAreaSB1)
RestArea(aAreaSD1)
RestArea(aAreaOLD)

Return
