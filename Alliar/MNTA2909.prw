//--------------------------------------------------------------------
/*/{Protheus.doc} MNTA2909
Fechamento de SS

@author Larissa Thaís de Farias
@since 07/12/2015
@return Nil
/*/
//--------------------------------------------------------------------
User Function MNTA2909()
	
	Local aValores := {}
//	Local cDescSS  := MSMM(,,, M->TQB_DESCSS, 3,,, "TQB", "TQB_CODMSS" )
//	Local cDescSO  := MSMM(,,, M->TQB_DESCSO, 3,,, "TQB", "TQB_CODMSS" )
	
//	if(!empty(cDescSS)        , aADD(aValores, {"TQB_DESCSS",cDescSS}),)
	
	if !empty(M->TQB_DTFECH) .and. !empty(M->TQB_HOFECH)

		if(!empty(M->TQB_DESCSO), aADD(aValores, {"TQB_DESCSO",M->TQB_DESCSO}),)	//aADD(aValores, {"TQB_DESCSS",M->TQB_DESCSS}),)
		if(!empty(M->TQB_DTFECH), aADD(aValores, {"TQB_DTFECH",DTOC(M->TQB_DTFECH)}),)
		if(!empty(M->TQB_HOFECH), aADD(aValores, {"TQB_HOFECH",M->TQB_HOFECH}),)
		if(!empty(M->TQB_TEMPO) , aADD(aValores, {"TQB_TEMPO" ,M->TQB_TEMPO}),)
		
		if !empty(M->TQB_XIDFLG)
			U_MNTFLUIG(aValores, M->TQB_XIDFLG,)
		endif
	endif
	
Return 