#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc}ZMAKESBZ
Acelerador para os cadastros da SBZ à partir do cadastro do produto

@author Edson Melo | www.compila.com.br
@since 01/12/2016
@example
(examples)
@see (links_or_references)
/*/
user function ZMAKESBZ()
	
	Local _aArea    := GetArea()
	Local _aAreaSM0 := SM0->(GetArea())
	Local _aFil 	:= {}
	Local _aCampos 	:= {}
	Local _aMkCpos  := {}
	Local aOpcX1 	:= {}
	Local aDados   := {}
	
	Local nTam      := 0
	
	Local cArqTemp  := ""
	Local MvParDef	:= ""	
	Local cRet      := ""
	
	Private aSit	:= 	{}
	
	//Carrega Array com todas as filiais
	SM0->(dbGoTop())
	SBZ->(dbSetOrder(1)) //BZ_FILIAL + BZ_COD
	SM0->(dbSetOrder(1))
	nTam := Len(SM0->M0_CODFIL)
	
	While SM0->(!EOF()) .And. SM0->M0_CODIGO == cEmpAnt
		
		If !( SBZ->(dbSeek(Alltrim(SM0->M0_CODFIL)+SB1->B1_COD)) )
			
			aadd(aSit, SM0->M0_CODFIL+" - "+SM0->M0_NOMECOM)				
			MvParDef += SM0->M0_CODFIL
			
		Endif
		
		SM0->(dbSkip())
	EndDo
	RestArea(_aAreaSM0)
    
	If !f_Opcoes(@(cRet := ""),"selecione as filiais para replicação dos indicadores",aSit,MvParDef,12,49,.F.,nTam, Len(MvParDef))
		Aviso('Acelerador','Opção cancelada. Nenhum dado foi gravado.',{'Ok'})
		Return
	EndIf
	
	//Separa filiais selecionadas
	_aFilGrv := {}
	_lFirst := .T.
	
	While !empty(cRet)
		If LEFT(cRet,Len(SM0->M0_CODFIL)) <> Replicate("*", Len(SM0->M0_CODFIL))
			If !empty(cRet)
				If !_lFirst 
					if aScan(_aFilGrv,{|x| x[1] == LEFT(cRet,Len(SM0->M0_CODFIL)) }) <= 0
						aadd(_aFilGrv, {LEFT(cRet,Len(SM0->M0_CODFIL)),"N"} )
					Endif
				Else
					aadd(_aFilGrv, {LEFT(cRet,Len(SM0->M0_CODFIL)),"N"} )
				EndIf
				_lFirst := .F.
			Endif
		EndIf
		cRet := Stuff(cRet, 1, Len(SM0->M0_CODFIL),"" )
	Enddo
	
	
	//Apresenta novamente apenas filiais selecionadas, que permitirá o usuário determinar quais deseja marcar o Int. Pleres com ""SIM""
	If !Empty(_aFilGrv)
		aSit 	 := {} 
		MvParDef := ""
		cRet     := ""
		nTam := LEN(SM0->M0_CODFIL)
		SM0->(dbGoTop())
		SBZ->(dbSetOrder(1)) //BZ_FILIAL + BZ_COD
		SM0->(dbSetOrder(1))
		
		While SM0->(!EOF()) .And. SM0->M0_CODIGO == cEmpAnt
			
			If aScan(_aFilGrv, {|x| alltrim(x[1]) == alltrim(SM0->M0_CODFIL)}) > 0
				aadd(aSit, SM0->M0_CODFIL+" - "+SM0->M0_NOMECOM)
				MvParDef += SM0->M0_CODFIL
			Endif
			
			SM0->(dbSkip())
		EndDo
		RestArea(_aAreaSM0)
		If !f_Opcoes(@cRet,"Int. Pleres - Selecione os marcados com SIM",aSit,MvParDef,15,60,.F.,nTam, len(MvParDef))
			Aviso('Acelerador','Opção cancelada. Nenhum dado foi gravado.',{'Ok'})
			Return
		EndIf
		
		//Atualiza _aFilGrv com as filiais que o usuário marcou como sim
		While !empty(cRet)
			If LEFT(cRet,Len(SM0->M0_CODFIL)) <> Replicate("*", Len(SM0->M0_CODFIL))
				If !empty(cRet)
					If (_nPos := aScan(_aFilGrv, {|x| x[1] == LEFT(cRet,Len(SM0->M0_CODFIL))}  )) > 0
						_aFilGrv[_nPos,2] := "S" //SIM
					Endif 
				Endif
			EndIf
			cRet := Stuff(cRet, 1, Len(SM0->M0_CODFIL),"" )
		Enddo
		
		/*
		For _nI := 1 To Len(_aFilGrv)
			Alert(_aFilGrv[_nI,1]+'-'+_aFilGrv[_nI,2])
		Next
		*/
		
		
		BEGIN TRANSACTION 
		//Tratamento para gravação dos dados na SBZ
		For _nCnt := 1 To Len(_aFilGrv)
			aDados := {}
			aadd(aDados, {"BZ_FILIAL"	,_aFilGrv[_nCnt,1]})
		    aadd(aDados, {"BZ_COD"		,SB1->B1_COD})
		    aadd(aDados, {"BZ_LOCPAD"	,SB1->B1_LOCPAD})
		    aadd(aDados, {"BZ_TE"		,SB1->B1_TE})
		    aadd(aDados, {"BZ_XINTPLE"	,_aFilGrv[_nCnt,2]})
		    
		    //Execauto para gravação dos dados
		    GrvDados(aDados)
		    
		Next
		END TRANSACTION
		
		Aviso('Acelerador','Indicadores gerados com sucesso.',{'Ok'})
		
	EndIf
	
	
	RestArea(_aArea)
	
return

/*/{Protheus.doc}GrvDados
Gravação de dados na SBZ utilizando RegToMemory

@author Edson Melo | www.compila.com.br
@since 01/12/2016
@example
(examples)
@see (links_or_references)
/*/
static function GrvDados(aDados)

Local aDadosInc := {}

RegToMemory("SBZ",.T.,.F.)
RecLock("SBZ", .T.)
	
	For _nI := 1 To Len(aDados)
		M->&(aDados[_nI,1]) := aDados[_nI,2]
	Next
	
	nTotCpo	:= SBZ->(FCOUNT()) 
	For nI := 1 To nTotCpo
		cNameCpo := ALLTRIM(SBZ->(FIELDNAME(nI)))
		nPosAux	 := aScan(aDadosInc, { |x| AllTrim(x[1]) == cNameCpo })  
		IF nPosAux > 0
			FieldPut(nI, aDadosInc[nPosAux, 2])
		ELSE
			FieldPut(nI, M->&(cNameCpo) )
		ENDIF
	Next nI
	
	
SBZ->(MsUnLock())

return

