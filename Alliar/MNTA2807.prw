//--------------------------------------------------------------------
/*/{Protheus.doc} MNTA2807
Alteração de SS no Protheus

@author Larissa Thaís de Farias
@since 07/12/2015
@return Nil
/*/
//--------------------------------------------------------------------
User Function MNTA2807()

	Local aValores := {}
	
	if altera
		if(!empty(TQB->TQB_RAMAL) , aADD(aValores, {"TQB_RAMAL" ,TQB->TQB_RAMAL}),)
		if(!empty(M->TQB_DESCSS), aADD(aValores, {"TQB_DESCSS",M->TQB_DESCSS}),)
		
		if !empty(TQB->TQB_XIDFLG)
			U_MNTFLUIG(aValores, TQB->TQB_XIDFLG,)
		endif
	endif
	
Return 