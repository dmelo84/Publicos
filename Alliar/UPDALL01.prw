//--------------------------------------------------------------------
/*/{Protheus.doc} UPDALL01
Update de inclusão do campo TQB_XIDFLG

@author Larissa Thaís de Farias
@since 09/12/2015
@return Nil
/*/
//--------------------------------------------------------------------
User Function UPDALL01()
	
	Local cModulo := "MNT" 
	Local bPrepar := { || NGUPD() } 
	Local nVersao := 1
	Local cObs := Nil
	
	NGCriaUpd( cModulo , bPrepar , nVersao ,  ,  , cObs )
	
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} NGUPD
Corpo do update

@author Larissa Thaís de Farias
@since 09/12/2015
@return Nil
/*/
//--------------------------------------------------------------------
Static Function NGUPD()
    
	aSX3 := {}

	aAdd ( aSX3 , { "TQB" , Nil , "TQB_XIDFLG" , "C" , 15 , 0 , ;		// Alias , Ordem , Campo , Tipo , Tamanho , Decimais
					"Id Fluig", "Id Fluig", "Id Fluig", ;				// Tit. Port. , Tit.Esp. , Tit.Ing. | ## "Filial"
					"Id Fluig", "Id Fluig", "Id Fluig", ;				// Desc. Port. , Desc.Esp. , Desc.Ing. | ## "Filial do Sistema"
					"@!" , ;											// Picture
					" " , ;												// Valid
					X3_NAOUSADO_USADO , ;								// Usado
					"" , ;												// Relacao
					" " , 1 , X3_NAOUSADO_RESERV , " " , " " , ;		// F3 , Nivel , Reserv , Check , Trigger
					"S" , "N" , "V" , "R" , "" , ;						// Propri , Browse , Visual , Context , Obrigat
					" " , ;												// VldUser
					" " , " " , " " , ;									// Box Port. , Box Esp. , Box Ing.
					" " , " " , "" , " " , " " , ;						// PictVar , When , Ini BRW , GRP SXG , Folder
					"S" , "" , "" , "" , "N" , " " } )					// Pyme , CondSQL , ChkSQL , IdxSrv , Ortogra , IdXFld
Return