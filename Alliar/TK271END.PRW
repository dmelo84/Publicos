#INCLUDE 'PROTHEUS.CH'

Static nRegSZE := 0
//-------------------------------------------------------------------
/*{Protheus.doc} TK271END
Ponto de Entrada no Final da Gravacao do Atendimento do Call Center

@author Guilherme Santos
@since 21/11/2016
@version P12
*/
//-------------------------------------------------------------------
User Function TK271END()

	If IsInCallStack("U_ALTMKA01")
		DbSelectArea("SZE")
		DbSetOrder(1)
		
		SZE->(DbGoTo(nRegSZE))
		
		If nRegSZE == SZE->(Recno())
			RecLock("SZE")
				SZE->ZE_STATUS := "2"
			MsUnlock()		
		EndIf
	EndIf

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} A271SETR
Guarda o Numero do Registro da SZE

@author Guilherme Santos
@since 21/11/2016
@version P12
*/
//-------------------------------------------------------------------
User Function A271SETR(nRegistro)
	nRegSZE := nRegistro
Return Nil
