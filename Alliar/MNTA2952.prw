//--------------------------------------------------------------------
/*/{Protheus.doc} MNTA2952
Criação de OS através de SS

@author Larissa Thaís de Farias
@since 07/12/2015
@return Nil
/*/
//--------------------------------------------------------------------
User Function MNTA2952()
	
	Local aValores := {}
	Local cObserva := ''
	
	If NGCADICBASE("TJ_MMSYP","A","STJ",.F.)
		cObserva := NGMEMOSYP(STJ->TJ_MMSYP)
	Else
		cObserva := STJ->TJ_OBSERVA
	EndIf
	
	if(!empty(TQB->TQB_ORDEM), aADD(aValores, {"TQB_ORDEM" ,STJ->TJ_ORDEM}),)
	if(!empty(cObserva)      , aADD(aValores, {"TQB_DESCSS",cObserva}),)
	
	if !empty(TQB->TQB_XIDFLG)
		U_MNTFLUIG(aValores, TQB->TQB_XIDFLG,)
	endif
	
Return 