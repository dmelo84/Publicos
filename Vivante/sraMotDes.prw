#Include "RWMAKE.CH" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

User Function sraMotDes

Local oModel   := FwModelActive() 
Local cMorDes  := SRA->RA_MOTDES

If oModel:GetValue('NT9DETAIL','NT9_ENTIDA') == 'SRA'
    If !Empty(dtos(SRA->RA_DEMISSA))
        //Preenche Codigo no Motivo
        If(Empty(cMorDes)) //Trata NT9_CODMOT em branco
            //oModel:loadValue('NT9DETAIL','NT9_CODMOT','0003')
            cMorDes := '00003'
        Else
            cMorDes := cMorDes
            //oModel:loadValue('NT9DETAIL','NT9_CODMOT',cMorDes)
        EndIf
            //
    else
        cMorDes := "00001"
    EndIf 
EndIf

Return cMorDes
