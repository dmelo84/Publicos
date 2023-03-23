//--------------------------------------------------------------------
/*/{Protheus.doc} MNTA4002
Finalização de OS

@author Larissa Thaís de Farias
@since 07/12/2015
@return Nil
/*/
//--------------------------------------------------------------------
User Function MNTA4002()
	//quando chegou aqui, creio que retornou o xid errado, VERRIFICAR
	Local aValores := {}
	Local aRetOs   := {}
	Local cT8Nome  := ''
	Local cT8Tipo  := ''
	Local cObserva := ''
	
	if !empty(STJ->TJ_SOLICI)
		If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
			cObserva := NGMEMOSYP(STJ->TJ_MMSYP)
		Else
			cObserva := STJ->TJ_OBSERVA
		EndIf
		
		//salva o posicionamento de tabelas por causa da ocorrência
		aRetOs := GetArea()
		
		aValores := U_MNTA280G(STJ->TJ_ORDEM)
		
		if(!empty(cObserva), aADD(aValores, {"TQB_DESCSS", cObserva}),)
	
		dbSelectArea("TQB")
		if dbSeek(xFilial("TQB") + STJ->TJ_SOLICI) .And. !empty(TQB->TQB_XIDFLG)
			U_MNTFLUIG(aValores, TQB->TQB_XIDFLG,)
		endif
	
		//restaura o posicionamento das tabelas
		RestArea(aRetOs)
	endif
Return