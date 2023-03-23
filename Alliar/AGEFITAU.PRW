#include "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AGEITAU   º                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ INFOR. A AGENCIA DO FORNECEDOR PARA CNAB A PAGAR DO BANCO  º±±
±±º          ³ ITAU (SISPAG).USADO GRUPO ALLIAR                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function AGEFITAU

Local _cAgen
Local _cNumCon
Local _cDac

_cAgen		:= ""
_cAg        := IIF(!EMPTY(SE2->E2_FORAGE),ALLTRIM(SE2->E2_FORAGE),"")
_cDaca		:= IIF(!EMPTY(SE2->E2_FAGEDV),ALLTRIM(SE2->E2_FAGEDV),"0")
_cConta	    := IIF(!EMPTY(SE2->E2_FORCTA),ALLTRIM(SE2->E2_FORCTA),"") //ALLTRIM(SA2->A2_NUMCON)
_cDac		:= IIF(!EMPTY(SE2->E2_FCTADV),ALLTRIM(SE2->E2_FCTADV)," ")  //ALLTRIM(SA2->A2_DVCTA)

If SE2->E2_FORBCO $ ("341/409")   .and. EMPTY(SE2->E2_FCTADV)
	cTaprc 	 := len(_cConta) -1
	_cNumCon := Left(_cConta,cTaprc)
	_cDac    := right(_cConta,1)
Else
	_cNumCon := _cConta
Endif

Do Case
	
	Case SE2->E2_FORBCO == "341/409" .AND. SEA->EA_MODELO $ "02/10"
		_cAgen := "0" + StrZero(Val(_cAg),4)+ " " + REPLICATE("0",6) +StrZero(Val(_cNumCon),6)+" "+"0"
		Return(_cAgen)
		
	Case SE2->E2_FORBCO == "341/409" .AND. ! SEA->EA_MODELO $ "02/10"
		_cAgen := "0" + StrZero(Val(_cAg),4)+ " "  + REPLICATE("0",6) +StrZero(Val(_cNumCon),6)+" "+_cDac
		Return(_cAgen)
		
	Case SE2->E2_FORBCO <> "341/409" .and. len(alltrim(_cDac))==1
		_cAgen := StrZero(Val(_cAg),5)+ " "  +"00"+StrZero(Val(_cNumCon),10)+" "+_cDac
		Return(_cAgen)
		
	OtherWise
		_cAgen := StrZero(Val(_cAg),5)+ " "  +"00"+StrZero(Val(_cNumCon),10)+_cDac
		Return(_cAgen)
		
EndCase

Return
