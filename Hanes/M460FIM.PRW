#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#include "Tbiconn.ch"

/*-----------------------------------------------------------------
|Ponto de entrada para geração de Bordero e envio de boleto        |
|Esta rotina rotornará a infomações da Nota fiscal para geração de |
|bordero                                                           |
|Desenvolvedo: Diogo Melo                                          |
|Data atualização: 05/09/2019                                      |
-------------------------------------------------------------------*/

user function M460FIM 

Local nOpc := 3
Local n := 0
Local cSeqSF2 := SF2->F2_DOC

If !Empty(SC5->C5_XMPPEDI)

    Do CASE
        Case SC5->C5_PARC1 > 0
            nValor := SC5->C5_PARC1
            dData  := SC5->C5_DATA1
            n++
            cNumSE1 := SomaSE1(cSeqSF2, strzero(n,3))

            aSF2 := {}
            aAdd(aSF2, {"E1_FILIAL",  FWxFilial("SE1"),  Nil})
            aAdd(aSF2, {"E1_NUM",     cNumSE1,           Nil})
            aAdd(aSF2, {"E1_PREFIXO", IiF(empty(SF2->F2_PREFIXO),"EC0",SF2->F2_PREFIXO),          Nil})
            aAdd(aSF2, {"E1_PARCELA", strzero(n,3),     Nil})
            aAdd(aSF2, {"E1_TIPO",    If(SE4->E4_CODIGO == "001", "FI ","CC "),             Nil})
            aAdd(aSF2, {"E1_NATUREZ", If(SE4->E4_CODIGO == "001", "FINAN","CARTAO"),         Nil})
            aAdd(aSF2, {"E1_PORTADO", "C08",         Nil})
            aAdd(aSF2, {"E1_AGEDEP",  ".  ",           Nil})
            aAdd(aSF2, {"E1_CLIENTE", If(Empty(SC5->C5_XMPPEDI),"E06","E09"),          Nil})
            //aAdd(aSF2, {"E1_LOJA",    "01",             Nil})
            aAdd(aSF2, {"E1_EMISSAO", SF2->F2_EMISSAO,          Nil})
            aAdd(aSF2, {"E1_VENCTO",  dData,           Nil})
            //aAdd(aSF2, {"E1_VENCREA", dVencReal,         Nil})
            aAdd(aSF2, {"E1_VALOR",   nValor,            Nil})
            //aAdd(aSF2, {"E1_VALJUR",  nValJuros,         Nil})
            //aAdd(aSF2, {"E1_PORCJUR", nPorcJuros,        Nil})
            aAdd(aSF2, {"E1_HIST","Titulo criado pela rotina M460FIM",   Nil})
            aAdd(aSF2, {"E1_MOEDA",   1,                 Nil})
            
            //Inicia o controle de transaï¿½ï¿½o
            Begin Transaction
                //Chama a rotina automï¿½tica
                lMsErroAuto := .F.
                MSExecAuto({|x,y| FINA040(x,y)}, aSF2, nOpc)
                
                //Se houve erro, mostra o erro ao usuï¿½rio e desarma a transaï¿½ï¿½o
                If lMsErroAuto
                    MostraErro()
                    DisarmTransaction() //Caso gere em massa ï¿½ necessï¿½rio comentar esta linha.
                    //Substituir por estas abaixo
                    //cMsgErro := "/autocom/logs/"
					//cArqErro := SC5->C5_NUM+'.log'
					//cMsg2Erro:= MostraErro(cMsgErro, cArqErro ) 
                Else
                    //SF2->(dbGoto(SF2->( LASTREC())))
                    SF2->(dbGoto(SF2->( Recno())))
                    RecLock("SF2", .F.)
                        SF2->F2_DUPL := cNumSE1
                        SF2->F2_PREFIXO := "EC0"
                    MsUnlock()
                EndIf
            //Finaliza a transaï¿½ï¿½o
            End Transaction

        Case SC5->C5_PARC2 > 0
            nValor := SC5->C5_PARC2
            dData  := stod(SC5->C5_DATA2)
            n++
            cNumSE1 := SomaSE1(cSeqSF2, strzero(n,3))

            aSF2 := {}
            aAdd(aSF2, {"E1_FILIAL",  FWxFilial("SE1"),  Nil})
            aAdd(aSF2, {"E1_NUM",     cNumSE1,           Nil})
            aAdd(aSF2, {"E1_PREFIXO", IiF(empty(SF2->F2_PREFIXO),"EC0",SF2->F2_PREFIXO),          Nil})
            aAdd(aSF2, {"E1_PARCELA", strzero(n,3),     Nil})
            aAdd(aSF2, {"E1_TIPO",    If(SE4->E4_CODIGO == "001", "FI ","CC "),             Nil})
            aAdd(aSF2, {"E1_NATUREZ", If(SE4->E4_CODIGO == "001", "FINAN","CARTAO"),         Nil})
            aAdd(aSF2, {"E1_PORTADO", "C08",         Nil})
            aAdd(aSF2, {"E1_AGEDEP",  ".  ",           Nil})
            aAdd(aSF2, {"E1_CLIENTE", If(Empty(SC5->C5_XMPPEDI),"E06","E09"),          Nil})
            //aAdd(aSF2, {"E1_LOJA",    '01',             Nil})
            aAdd(aSF2, {"E1_EMISSAO", SF2->F2_EMISSAO,          Nil})
            aAdd(aSF2, {"E1_VENCTO",  dData,           Nil})
            //aAdd(aSF2, {"E1_VENCREA", dVencReal,         Nil})
            aAdd(aSF2, {"E1_VALOR",   nValor,            Nil})
            //aAdd(aSF2, {"E1_VALJUR",  nValJuros,         Nil})
            //aAdd(aSF2, {"E1_PORCJUR", nPorcJuros,        Nil})
            aAdd(aSF2, {"E1_HIST","Titulo criado pela rotina M460FIM",   Nil})
            aAdd(aSF2, {"E1_MOEDA",   1,                 Nil})
            
            //Inicia o controle de transaï¿½ï¿½o
            Begin Transaction
                //Chama a rotina automï¿½tica
                lMsErroAuto := .F.
                MSExecAuto({|x,y| FINA040(x,y)}, aSF2, nOpc)
                
                //Se houve erro, mostra o erro ao usuï¿½rio e desarma a transaï¿½ï¿½o
                If lMsErroAuto
                    MostraErro()
                    DisarmTransaction()//Caso gere em massa ï¿½ necessï¿½rio comentar esta linha.
                    //Substituir por estas abaixo
                    //cMsgErro := "/autocom/logs/"
					//cArqErro := SC5->C5_NUM+'.log'
                    //cMsg2Erro:= MostraErro(cMsgErro, cArqErro )
                Else
                 //SF2->(dbGoto(SF2->( LASTREC())))
                    SF2->(dbGoto(SF2->( Recno())))
                    RecLock("SF2", .F.)
                        SF2->F2_DUPL := cNumSE1
                        SF2->F2_PREFIXO := "EC0"
                    MsUnlock()
                EndIf
            //Finaliza a transaï¿½ï¿½o
            End Transaction

        Case SC5->C5_PARC3 > 0
            nValor := SC5->C5_PARC3
            dData  := stod(SC5->C5_DATA3)
            n++
            cNumSE1 := SomaSE1(cSeqSF2, strzero(n,3))

            aSF2 := {}
            aAdd(aSF2, {"E1_FILIAL",  FWxFilial("SE1"),  Nil})
            aAdd(aSF2, {"E1_NUM",     cNumSE1,           Nil})
            aAdd(aSF2, {"E1_PREFIXO", IiF(empty(SF2->F2_PREFIXO),"EC0",SF2->F2_PREFIXO),          Nil})
            aAdd(aSF2, {"E1_PARCELA", strzero(n,3),     Nil})
            aAdd(aSF2, {"E1_TIPO",    If(SE4->E4_CODIGO == "001", "FI ","CC "),             Nil})
            aAdd(aSF2, {"E1_NATUREZ", If(SE4->E4_CODIGO == "001", "FINAN","CARTAO"),         Nil})
            aAdd(aSF2, {"E1_PORTADO", "C08",         Nil})
            aAdd(aSF2, {"E1_AGEDEP",  ".  ",           Nil})
            aAdd(aSF2, {"E1_CLIENTE", If(Empty(SC5->C5_XMPPEDI),"E06","E09"),          Nil})
            //aAdd(aSF2, {"E1_LOJA",    "01",             Nil})
            aAdd(aSF2, {"E1_EMISSAO", SF2->F2_EMISSAO,          Nil})
            aAdd(aSF2, {"E1_VENCTO",  dData,           Nil})
            //aAdd(aSF2, {"E1_VENCREA", dVencReal,         Nil})
            aAdd(aSF2, {"E1_VALOR",   nValor,            Nil})
            //aAdd(aSF2, {"E1_VALJUR",  nValJuros,         Nil})
            //aAdd(aSF2, {"E1_PORCJUR", nPorcJuros,        Nil})
            aAdd(aSF2, {"E1_HIST","Titulo criado pela rotina M460FIM",   Nil})
            aAdd(aSF2, {"E1_MOEDA",   1,                 Nil})
            
            //Inicia o controle de transaï¿½ï¿½o
            Begin Transaction
                //Chama a rotina automï¿½tica
                lMsErroAuto := .F.
                MSExecAuto({|x,y| FINA040(x,y)}, aSF2, nOpc)
                
                //Se houve erro, mostra o erro ao usuï¿½rio e desarma a transaï¿½ï¿½o
                If lMsErroAuto
                    MostraErro()
                    DisarmTransaction()//Caso gere em massa ï¿½ necessï¿½rio comentar esta linha.
                    //Substituir por estas abaixo
                    //cMsgErro := "/autocom/logs/"
					//cArqErro := SC5->C5_NUM+'.log'
                    //cMsg2Erro:= MostraErro(cMsgErro, cArqErro ) 
                Else
                 //SF2->(dbGoto(SF2->( LASTREC())))
                    SF2->(dbGoto(SF2->( Recno())))
                    RecLock("SF2", .F.)
                        SF2->F2_DUPL := cNumSE1
                        SF2->F2_PREFIXO := "EC0"
                    MsUnlock()

                EndIf
            //Finaliza a transaï¿½ï¿½o
            End Transaction
            
    ENDCASE

EndIf   

Return

/*/{Protheus.doc} SomaSE1
    (long_description)
    @type  Static Function
    @author diogo melo  
    @since 10/09/2019
    /*/
 Static Function SomaSE1(cSeqSF2, cParc)

 Local cQry := ''
 
 cQry := " Select E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA "
 cQry += " from "+ RetSqlName("SE1")+ " SE1 "
 cQry += " WHERE E1_PREFIXO = 'EC0' "
 cQry += " AND D_E_L_E_T_ != '*'"
 
 cQry := ChangeQuery( cQry )
 cInd1:= CriaTrab(Nil,.F.)
 dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),'SE1TMP',.T.,.T.)

    dbSelectArea("SE1TMP")
    
    While SE1TMP->(!eof())
        If cSeqSF2 == strzero(val(SE1TMP->E1_NUM),9) .and. cParc == SE1TMP->E1_PARCELA
            cSeqSF2 := Soma1(SE1TMP->E1_NUM)
        Else 
            cSeqSF2 := cSeqSF2
        EndIf
	       SE1TMP->(dbSkip())
    ENDDO
    
    SE1TMP->(dbCloseArea())


 return (cSeqSF2)