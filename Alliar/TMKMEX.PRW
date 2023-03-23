#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} TMKMEX
Ponto de Entrada depois do cancelamento do atendimento 

@author Guilherme.Santos
@since 03/02/2017
@version P12 verificar nOpcao
*/  
//-------------------------------------------------------------------
User Function TMKMEX( nOpcA )
    Local aArea     := GetArea()
	Local cCanTxt   := ""
	Local cRetWS	:= ""
	Local nItem		:= 0
	Local nPosIDFl	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XIDFLUI"})
	Local nPosStat	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_STATUS"})
	Local nPosDele	:= Len(aHeader) + 1
	Local lRetorno	:= .T. 
      
    DBSELECTAREA("SUD")                                                    
    SUD->(DBSETORDER(1))   //Filial+Num Atendimento
    SUD->(DBGOTOP())    
    SUD->(DBSEEK(xFilial("SUD") + SUC->UC_CODIGO))
    While (SUD->(!EOF()) .AND. SUD->UD_CODIGO = SUC->UC_CODIGO)
       
       IF SUD->UD_STATUS = "1" 
	      Aviso("TMKVEX", "Este atendimmento não pode ser encerrado, existem registros pendentes.", {"Fechar"})       
          lRetorno := .F.
       ENDIF
            
       SUD->(DBSKIP())
    End
      
	
/*	If lRetorno 
		For nItem := 1 to Len(aCols)
        //	If !aCOLS[n][nUsado+1] 	// SE não deletado
			If !aCols[nItem][nPosDele]
				If aCols[nItem][nPosStat] == "1"
					If nPosIDFl <> SPACE(06)
						//
						//-----------------------------------------------------------------------------------------------------
						//	Encerra atendimento no Fluig
						//-----------------------------------------------------------------------------------------------------	
						//
						
						cCanTxt := MSMM(SUC->UC_OBSCANC,80, ,,3, , ,"SUC","UC_OBSCANC")  
						cCanTxt += SUC->UC_XUSUFIM 						
						
						If U_TMKENCF(nPosIDFl, 10, @cRetWS)
							//Enviar mensagem de encerramento para o Fluig
							aCols[nItem][nPosIDFl] := VAL(cRetWS)
						Else
							Aviso("TMKMDC ", cRetWS, {"Fechar"})
							lRetorno := .F.
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		Next nItem
	EndIf
*/
RestArea( aArea )
Return lRetorno