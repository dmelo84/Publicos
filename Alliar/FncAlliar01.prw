#Include 'Protheus.ch'
#include "apwebsrv.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±FUNÇÃO     ³ GetG_E_F  ³ Autor  ³ Marcelo R. Ferrari     		  ³ Data ³ 10/08/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca dados de Grupos, empresas e filiais do usuario            		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetG_E_F( usuario, email )                                          	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ WebService  				                                    		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               		³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³PROGRAMADOR ³ DATA   ³CHAMADO/REQ     ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³																					³±±
±±³																					³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/
*/ 
User Function GetG_E_F(pUsr, pEmail )
   Local aGrpEmp := {}
   Local aUsuarios := {}
   Local aUsuario := {}
   lOCAL aTmp     := {}
   Local aMsg    := ""
   Local i := 0
   
  aUsuario := SeekUsuario(pUsr, pEmail)
  
  If empty(aUsuario)
     aAdd(aGrpEmp, {"ERRO", "Usuário/e-mail não encontrado ou sem permissão no cadastro."})
  Else
     /*If empty(aUsuario[2][6])
        aAdd(aGrpEmp, {"ERRO", "Usuário sem permissão no cadastro."})
     Else*/
     aGrpEmp := PesGrpEmp( aUsuario/*[2][6]*/ )
     //EndIf
  EndIf

Return  aGrpEmp

Static Function SeekUsuario(pUsr, pEmail)
Local aMeuUsr := {}
Local aRet := {}
Local cMeuId := ""
   
   If !empty(pUsr) 
      PswOrder(2)
      If PswSeek(pUsr  ,.T.)
         aMeuUsr := PswRet()
         cMeuId := aMeuUsr[1][1]
         aRet := FwUsrEMp(cMeuId)
      EndIf
   ElseIf !empty(pEmail)
      PswOrder(4)
      If PswSeek(pEmail  ,.T.)
         aMeuUsr := PswRet()
         cMeuId := aMeuUsr[1][1]
         aRet := FwUsrEMp(cMeuId)
      EndIf
   Else
      aMeuUsr := PswRet()
      cMeuId := aMeuUsr[1][1]
      aRet := FwUsrEMp(cMeuId)
   EndIf
   
Return aRet

Static Function PesGrpEmp( aEmp )
    Local aAllGrpCompany := FWAllGrpCompany()
    Local aAllCompany    := {}
    Local aRet := {}
    Local aTmp := {}
    Local aTmp2 := {}
    Local i := 0
    Local j := 0
    
    Default aEmp := NIL
    
	For i := 1 to len(aAllGrpCompany)
		aAdd(aAllCompany, {aAllGrpCompany[i], FWGrpName( aAllGrpCompany[i] )} )
		
		aTmp2 := PesFiliais( aAllGrpCompany[i], aEmp )
		If !empty(aTmp2)
			aAdd(aAllCompany[i], aTmp2 )
		Else
			aAdd(aAllCompany[i], {} )
		EndIF
	Next
	    
    aRet := aAllCompany
   
Return aRet

Static Function PesFiliais(cGrp, aEmp )
	Local aFils := {}
	Local aTmp := {}
	Local aRet := {}
	Local cFil := ""
	Local cEmp := ""
	Local i := 0
	Local j := 0
	Local k := 0
	
	aFils := FWLoadSM0()
	
	For i := 1 to Len(aFils)
		If aFils[i][1] == cGrp
			If aEmp[1] != "@@@@"
				cFil := aFils[i][1] + aFils[i][3] + aFils[i][5]
				For j := 1 to Len(aEmp)
					cEmp := aEmp[j]
					If cFil = cEmp
						if fExist(cFil, cGrp, aTmp)
							Loop
						endif
						aAdd(aTmp, {})
						k := k + 1
						aAdd(aTmp[k], aFils[i][1]) //Grupo
						aAdd(aTmp[k], aFils[i][6]) //Nome do Grupo
						
						aAdd(aTmp[k], aFils[i][3]) //Código da empresa
						aAdd(aTmp[k], aFils[i][19]) //Nome da empresa
						
						aAdd(aTmp[k], aFils[i][2]) //Código Filial completo
						aAdd(aTmp[k], aFils[i][5]) //Cod Filial
						aAdd(aTmp[k], aFils[i][7]) //Nome da Filial
					EndIf
				Next
			Else
				aAdd(aTmp, {})
				k := k + 1
				aAdd(aTmp[k], aFils[i][1]) //Grupo
				aAdd(aTmp[k], aFils[i][6]) //Nome do Grupo
				
				aAdd(aTmp[k], aFils[i][3]) //Código da empresa
				aAdd(aTmp[k], aFils[i][19]) //Nome da empresa
				
				aAdd(aTmp[k], aFils[i][2]) //Código Filial completo
				aAdd(aTmp[k], aFils[i][5]) //Cod Filial
				aAdd(aTmp[k], aFils[i][7]) //Nome da Filial
			EndIf
		EndIf
	Next
	
	i := 0
	aRet := aTmp
	
Return aRet

Static Function fExist( cFil, cGrp, aTmp )
	Local lRet := .F.
	Local i := 0
	Local cVal := ""
	
	//   varinfo("cFil", cFil)
	//   varInfo("cGrp", cGrp)
	//   varInfo("aTmp", aTmp)
	
	If empty(aTmp)
		Return .F.
	EndIf
	
	For i := 1 to len(aTmp)
		cVal := cGrp + aTmp[i][5]
		If cFil == cVal
			lRet := .T.
			Exit
		EndIf
	Next
Return lRet

Static Function PesUsuarios()
   Local aRet := {}
   aRet := FWSFALLUSERS()
Return aRet


User Function InicializaVar( oGrpEmp )
   oGrpEmp := Nil
   oGrpEmp := WSClassNew("FSEmpresa")
   
   oGrpEmp:cCodGrpEmp  := " "
   oGrpEmp:cNomeGrpEmp := " "
   oGrpEmp:cCodEmp     := " "
   oGrpEmp:cEmpresa    := " "
   oGrpEmp:cCodUnNeg   := " "
   oGrpEmp:cUnidNeg    := " "
   oGrpEmp:cCodFil     := " "
   oGrpEmp:cNomeFil    := " "
Return .T.