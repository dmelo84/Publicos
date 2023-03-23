#include "Protheus.ch"
//-----------------------------------
/*/
@Autor   : Francisco Lopes Junior
@Empresa : Compila
@Ponto Entrada : FA090POS
@Data    : 22/03/2017
@Objetivo: Escolha do Banco Favorito para Baixa Aut CP
*/*

User function FA090POS()
Local lRet		:= .T.
Local _cBanco	:= ""
Local _cAgencia	:= ""
Local _cConta	:= ""
Local _lAchei	:= .F.
Local _aAreaSA6 := SA6->(GetArea())
Local cFilSA6	:= LEFT(XFILIAL("SE2"),5)
//Local aParam	:= PARAMIXB
Local cBco090	:= PARAMIXB[1]
Local cAge090	:= PARAMIXB[2]
Local cCta090	:= PARAMIXB[3]
local cCheq090	:= PARAMIXB[4]

SA6->(DBSETORDER(1))
SA6->(DbGotop())
IF SA6->(DBSEEK(cFilSA6))
	Do while !SA6->(Eof()) .and. SA6->A6_FILIAL == fwxFilial("SA6")  
		If SA6->A6_XBANFVP == '1' 
			If !_lAchei																			// pega somente o primeiro banco favorito CP
				_cBanco 	:= SA6->A6_COD
				_cAgencia	:= SA6->A6_AGENCIA
				_cConta		:= SA6->A6_NUMCON
				_lAchei		:= .T.
			Else 
				Reclock("SA6",.F.)                                                              // Nao pode ter mais que um favorito.
				SA6->A6_XBANFVP := '2'
				MsUnlock()
			End if
		End if
		SA6->(DbSkip())
	End do
endif

if _lAchei
	cBco090 := _cBanco
	cAge090	:= _cAgencia
	cCta090 := _cConta
Endif

RestArea(_aAreaSA6)
Return({cBco090, cAge090, cCta090, cCheq090})


   																	

//----------------------------------------------------------
/*/
@Autor   : Francisco Lopes Junior
@Empresa : Compila
@Funcao  : Co_VerBcof()
@Data    : 22/03/2017
@Objetivo: Validacao para aceitar um unico Banco Favorito
*/*

User Function Co_VerBcof()   																	// funcao para aceitar unico banco favorito

Local 	_lRet 		:= .T.
Local 	_aAreaSA6	:= SA6->(GetArea())
Local 	_cRecno 	:= Recno()
Local cFilSA6		:= M->A6_FILIAL

SA6->(DBSETORDER(1))
SA6->(Dbgotop())

If M->A6_XBANFVP == '1'
	IF SA6->(DBSEEK(cFilSA6))
		While !SA6->(Eof()) .and. SA6->A6_FILIAL == cFilSA6
			if SA6->A6_XBANFVP == '1' .and. Recno() <> _cRecno
			     Help(" ",1,"FINVERBCOF")
				_lRet := .F.
				Exit
			Endif
			SA6->(DbSkip())
		Enddo
	endif
Endif 

RestArea(_aAreaSA6)

Return _lRet




	
			