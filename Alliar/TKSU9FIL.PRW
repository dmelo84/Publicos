#Include "Protheus.ch"
//-------------------------------------------------------------------
/*{Protheus.doc} TMSU9FIL
Incluir cláusula de filtro

@author  Itamar Gama .:
@since   04/04/2017
@version P12
*/
//-------------------------------------------------------------------
User Function TMSU9FIL()
Local aNewItems :={}
Local nPos     := 0                                                 // Posicao no array
Local nPAssunto:= Ascan(aHeader,{|x| AllTrim(x[2])=="UD_ASSUNTO"})	// Assunto
Local cAssunto := Acols[n][nPAssunto]	        				    // Código do Assunto
Local nPosTPA  := Ascan(aHeader,{|x| AllTrim(x[2])=="UD_XCODTPO"})	// Tipo Ocorrencia
Local cTPAAssn := Acols[n][nPosTPA]	            				    // Código Ocorrência
Local aArea    := GetArea()									    	// Area atual 

DbSelectarea("SU9")
DbSetorder(3)
DbSeek(xFilial("SU9")+cTPAAssn)
While !Eof() .AND. (xFilial("SU9") == SU9->U9_FILIAL) .AND. (SU9->U9_TIPOOCO == cTPAAssn)
	If !Empty(SU9->U9_CODIGO) .AND. (SU9->U9_VALIDO == "1") .AND. (SU9->U9_ASSUNTO == cAssunto)                  
		Aadd(aNewItems,{SU9->U9_CODIGO,;    //Codigo
						SU9->U9_DESC,;      //Descricao
						SU9->U9_PRAZO})     //Prazo
	Endif	
	DbSkip()
End  
RestArea(aArea)
Return(aNewItems)
