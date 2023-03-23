//--------------------------------------------------------------------
/*/{Protheus.doc} MNTA4204
Modificação da observação da O.S.

@author Larissa Thaís de Farias
@since 07/12/2015
@return Nil
/*/
//--------------------------------------------------------------------
User Function MNTA4204()
	
	Local aValores := {}
	Local aRetOs   := {}
	Local cObserva := ''
	
	if Altera
		If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
			cObserva := NGMEMOSYP(STJ->TJ_MMSYP)
		Else
			cObserva := STJ->TJ_OBSERVA
		EndIf
		
		if(!empty(cObserva), aADD(aValores, {"TQB_DESCSS",cObserva}),)
		
		//salva o posicionamento de tabelas
		aRetOs := GetArea()
		
		dbSelectArea("TQB")
		if dbSeek(xFilial("TQB") + STJ->TJ_SOLICI) .And. !empty(TQB->TQB_XIDFLG)
			U_MNTFLUIG(aValores, TQB->TQB_XIDFLG,)
		endif
		
		//restaura o posicionamento das tabelas
		RestArea(aRetOs)
	endif
	
Return 