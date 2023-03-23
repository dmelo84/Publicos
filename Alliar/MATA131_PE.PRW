#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} MATA131

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Alliar 
 
@return Boolean
/*/

User Function MATA131 ()
	Local xRetorno	    := .T.
	
	Local oObjMod		//:= PARAMIXB[1]	//Objeto com o Model
	Local cAction		//:= PARAMIXB[2]	//Id da Acao
	Local cIdForm		//:= PARAMIXB[3]	//Id do Formulario
	local oObjetinho
	LOcal nLin := 1
	static aLstSC1 := {}

	If PARAMIXB <> Nil
		oObjMod		:= PARAMIXB[1]
		cAction		:= PARAMIXB[2]	//Id da Acao
	    cIdForm		:= PARAMIXB[3]	//Id do Formulario
	
	
	    If oObjMod:GetOperation() == 3 .or. oObjMod:GetOperation() == 4
		
	    //		If AllTrim(cIdForm) == "SC1DETAIL" .And.  cAction == "FORMPOS" 
	    	If AllTrim(cIdForm) == "MATA131" .And.  cAction == "MODELPOS" 

	    		If FIndFUnction("U_ALCO10")
	    			xretorno := U_ALCO10(aLstSc1, oObjMod)

	    			If xRetorno == .F.

	    				aLstSc1 := Nil 
	    		         aLstSc1 := {}
	    		    EndIf

	    		EndIf
		
	    	EndIf
	    EndIf
	
	EndIf
	
RETURN xretorno

