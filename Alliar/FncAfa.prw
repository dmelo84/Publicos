#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBSRV.CH"
#include "TOPCONN.CH"

User Function FncNumDia(aAfastamento, cMsg, nR8_DURACAO,  nR8_DIASEMP, nR8_DPAGAR, cR8_CONTINU, cR8_CONTAFA, nR8_SDPAGAR, nR8_DPAGOS)

	Local aPerAtual     := {}
	Local aPerAberto    := {}
	Local aPerFechado   := {}
	Local cContin       := ""
	Local cContAfa      := ""
	Local cPeriodo      := ""
	Local cNumPago      := ""
	Local lRet          := .T.
	Local nDuracao      := 0
	Local nDiasEmp      := 0
	Local nDiasPagar    := 0  
	Local nLenGrid      := 0
	Local nLinAtual     := 0
	Local nX            := 0
	Local nPos          := 0
	Local lSetDuracao   := .T. 
	Local cSeq          := "" 
	
    DbSelectArea("SRA") 
	DbSetOrder(1)
	DbSeek(aAfastamento:R8_FILIAL + aAfastamento:R8_MAT)
    
	If !Empty(aAfastamento:R8_DATAINI) .AND.;
	   Empty(aAfastamento:R8_DATAFIM)
	   If aAfastamento:R8_DATAINI < SRA->RA_ADMISSA
	   		cMsg := "Data inicial não pode ser menor que data de admissão do funcionário."
		    
	    	Return(.F.)
	   Endif
	EndIf   
    
	If !Empty(aAfastamento:R8_DATAINI) .AND.;
	   Empty(aAfastamento:R8_DATAFIM)
		If !Empty(aAfastamento:R8_DATAINI)
			fGetPerAtual( @aPerAtual, aAfastamento:R8_FILIAL, SRA->RA_PROCES, If (SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar()) )
        
			If aScan( aPerAtual, { |x| x[6] > aAfastamento:R8_DATAINI } ) > 0
				cMsg := "Data inicial deve ser maior que data final do último período fechado."
            
				lRet := .F.
			EndIf        
        
			If lRet
				aPerFechado:= {}
				aPerAberto := {}
				fRetPerComp( Month2Str( aAfastamento:R8_DATAINI ), Year2Str( aAfastamento:R8_DATAINI ), Nil, SRA->RA_PROCES, If (SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar()), @aPerAberto, @aPerFechado)
        
				nPos := aScan( aPerAberto, { |x| aAfastamento:R8_DATAINI >= x[5] .and. aAfastamento:R8_DATAINI <= x[6] } )
				
				if nPos > 0 
					cPeriodo := aPerAberto[nPos,1]
					cNumPago := aPerAberto[nPos,2]
				EndIf
			EndIf
			
			If lRet
				If !Empty(nR8_DURACAO)
					nR8_DURACAO := 0
				EndIf
			EndIf
		EndIf
	EndIf

    If lRet .AND.;
       !Empty(aAfastamento:R8_DATAFIM)
       If Empty(aPerAtual)
       		fGetPerAtual( @aPerAtual, aAfastamento:R8_FILIAL, SRA->RA_PROCES, If (SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar()) )
       EndIf
       		
       If aScan( aPerAtual, { |x| x[6] > aAfastamento:R8_DATAFIM } ) > 0
       		cMsg := "Data final deve ser maior que data final do último período fechado."
       			
       		Return(.F.)
       EndIf
       		
       If aAfastamento:R8_DATAFIM < aAfastamento:R8_DATAINI
       		cMsg := "Data final deve ser maior que data inicial."

       		Return(.F.)         
       	EndIf

       FncAtuDia(aAfastamento:R8_DATAINI,aAfastamento:R8_DATAFIM,@cContin,@cContAfa,aAfastamento:R8_TIPOAFA,@nDuracao,@nDiasEmp,@nDiasPagar)
    
       If lSetDuracao 
       		nR8_DURACAO := nDuracao
       EndIf
       
       lSetDuracao := .T.
       
       nR8_DIASEMP := nDiasEmp
       nR8_DPAGAR  := nDiasPagar
       cR8_CONTINU := cContin
    
       If cR8_CONTAFA <> cContAfa
       		cR8_CONTAFA := cContAfa
       EndIf
       
           
       If !Empty(aAfastamento:R8_DATAFIM) .AND.;
          !(nR8_SDPAGAR == 0)
          If !Empty(nR8_DPAGOS)
          		nR8_SDPAGAR := Max(0,nDiasPagar - nR8_DPAGOS)
          Else
          		nR8_SDPAGAR := nDiasPagar
          EndIf        
       EndIf
       
       //Retorna Sequencia	   
	   cSeq := PADL(cVALTOCHAR(Val(U_FncAfaSq(aAfastamento)) + 1), 03, "0")
		       
	   If aAfastamento:R8_TIPOAFA $ "003|004" .AND.;
          cR8_CONTAFA == cSeq //Tipo 003 e 004 sao afastamento por acidente de trabalho e doenca
          nDuracao    := 0
          nDiasEmp    := 0
          nDiasPagar    := 0  
        
          FncAtuDia(aAfastamento:R8_DATAINI,aAfastamento:R8_DATAFIM,@cContin,@cContAfa,aAfastamento:R8_TIPOAFA,@nDuracao,@nDiasEmp,@nDiasPagar, cSeq)  
          
          nR8_DURACAO := nDuracao
          nR8_DIASEMP := nDiasEmp
          nR8_DPAGAR  := nDiasPagar
       EndIf
    EndIf

Return(lRet)

Static Function FncAtuDia(dDtIni,dDtFim,cContin,cContAfa,cTipo,nDuracao,nDiasEmp,nDiasPagar, cSeq)
	Local nLinha    := 0
	Local nLinAtual := 0
	Local nLenGrid  := 0
	Local nPosMater := 0 
	Local dDtMater  := 0

	nDiasEmp := gp240RetCont("RCM"                                             ,; // cAlias
                             1                                                 ,; // nIndex
                             xFilial("RCM") + cTipo                            ,; // cKey
                             "RCM_DIASEM"                                      ,; // Coluna retorno
                             "(RCM->RCM_TIPO = '" + cTipo + "')")                 // Filtro         

    If !Empty(dDtFim)
    	nDuracao:= (dDtFim-dDtIni)+1
    Else
    	nDuracao:= nDiasEmp
    EndIf

    If nDiasEmp > 0 
    	If Empty(cContAfa)  // nao e continuacao de afastamento
    		nDiasPagar     := If( nDuracao > nDiasEmp, nDiasEmp,nDuracao)

    		If cPaisLoc == "PAR"
    			//No Paraguai, se o func. se afastar mais do que 3 dias, o IPS paga para o func.
    			nDiasPagar     := If( nDuracao > nDiasEmp, 0,nDuracao)
    		EndIf
    	Else    
    		If cSeq == cContAfa
    			If dDtIni - dDtFim > 60
    				//Verifica se o afastamento foi interrompido por licenca maternidade
    				If cTipo $ "006|007|008" 
    					dDtMater := dDtFim +1
    				    
    					If dDtIni  == dDtMater .AND.;
    					   dDtFim + 1 == dDtIni
    					   nDiasEmp := 0
    					EndIf
    				EndIf                           
    			Else    
    				nDiasEmp    := nDiasEmp - nDiasPagar
    			EndIf 
    			   
    			nDiasPagar     := If( nDuracao > nDiasEmp, nDiasEmp,nDuracao)
    		EndIf
    	EndIf                    
    Else
    	If !(cPaisLoc == "BRA" .AND.;
    	   cTipo $ "006|007|008|010|011|012")
    	   cContin := "2"
    	   cContAfa:= Space(03)    
    	EndIf    
    EndIf
                          
Return

User Function FncAfaSq(aAfastamento)
	Local cSeq := "" 

	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(CAST(SR8.R8_SEQ AS INTEGER)) INCREMENTO "
	cQuery += "  FROM " + RetSqlName("SR8")+" SR8 "
	cQuery += " WHERE SR8.R8_FILIAL = '" + xFilial("SR8" ,aAfastamento:R8_FILIAL) + "'"
	cQuery += "   AND SR8.R8_MAT = '" + aAfastamento:R8_MAT + "'"
	cQuery += "   AND SR8.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)
	dbGoTop()
	
	If !Eof()
		//Sequencial
		if Empty((cAliasQry)->INCREMENTO)
			cSeq := PADL("0", 03, "0")
		else
			//Incrementa Sequencial
			cSeq := PADL(cVALTOCHAR((cAliasQry)->INCREMENTO), 03, "0")
		endif 
	else
		cSeq := PADL("0", 03, "0")   
	endif
	
	(cAliasQry)->(dbCloseArea())
Return (cSeq) 

User Function FncAfaVl(aAfastamento, cMsg)
	Local nRetorno := 1
	
	//Valida se já existe o registro
	if (aAfastamento:OPERACAO == 3) 
		if (U_RegExiste("SR8", aAfastamento:R8_FILIAL + aAfastamento:R8_MAT + DTOS(aAfastamento:R8_DATAINI), 1))
			nRetorno := 3 //Erro
			cMsg     := "Afastamento já cadastrado para a matrícula nesta data"
		
			Return (nRetorno)
		endif
	endif
	
	//Valida Matricula
	if (!Empty(aAfastamento:R8_MAT)) .AND.;
	   (U_RegExiste("SRA", aAfastamento:R8_FILIAL + aAfastamento:R8_MAT, 1)) .AND.;
	   (Val(aAfastamento:R8_MAT) > 0)
	else
		nRetorno := 3 //Erro
	    cMsg     := "R8_MAT inválida"
		
		Return(nRetorno)
    endif
	
	//Valida Código da ausência
	if (!Empty(aAfastamento:R8_TIPOAFA)) .AND.;
	   (ExistCpo("RCM", aAfastamento:R8_TIPOAFA))
	else
		nRetorno := 3 //Erro
	    cMsg     := "R8_TIPOAFA inválida"
		
	    Return(nRetorno)
    endif
	
	//Valida Código verba
	if (!Empty(aAfastamento:R8_PD)) .OR.;
	   (ExistCpo("SRV", aAfastamento:R8_PD))
	else
		nRetorno := 3 //Erro
	    cMsg     := "R8_PD inválida"
		
	    Return(nRetorno)
	endif
	      
	//Valida Data afastamento
	if (!Empty(aAfastamento:R8_DATAINI))
	else
		nRetorno := 3 //Erro
	    cMsg     := "R8_DATAINI inválida"
		
	    Return(nRetorno)
	endif
	
Return (nRetorno)