#Include "RWMAKE.CH" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

User Function sraMatri

Local oModel   := FwModelActive()  
Local cMatr    := ""

If oModel:GetValue('NT9DETAIL','NT9_ENTIDA') == 'SRA'
    cMatr := SRA->RA_MATMIG
EndIf

Return cMatr
