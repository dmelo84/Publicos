#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE "TBICONN.CH" 

/*----------------------------------------
	01/02/2018 - Jonatas Oliveira - Compila
	Funções criadas com base nos fontes 
	Classe02
	Classe00
	
------------------------------------------*/

/*/{Protheus.doc} ALMED001
(long_description)
@author Jonatas Oliveira | www.compila.com.br
@since 01/02/2018
@version 1.0
@param cAbreFecha, C, A="Abre" semaforo (cria arquivo e o mantem aberto), F=Fecha (Libera semaforo para utilizacao)
@param cFile, C, Nome do Semaforo (arquivo fisivo sera criado)
@param nHSemafaro, N, Numero do Handle do arquivo a ser fechado.
@return nRet, Handle do arquivo de semaforo criado. Quando MAIOR que ZERO, semaforo aberto com sucesso, MENOR ou IGUAL a Zero = nao foi possivel abrir o semaforo.
/*/
User Function ALMED001()
	Private aTabelas		:= {"CN9", "CNC", "CNA", "CNB", "CND", "CNE", "CN1", "CNF", "CNS", "CNZ"}
	Private cContrato	:= ""
	Private cRevisao		:= ""
	Private cFileLog		:= "CNTA120.LOG"
Return()


/*/{Protheus.doc} ALMED01C
Atribui campos cabeçalho
@author Jonatas Oliveira | www.compila.com.br
@since 01/02/2018
@version 1.0
@param cCampo, C, Campo
@param xValor, X, Conteudo
@param xValid, X, Validação do Campo
/*/
User Function ALMED01C(cCampo, xValor, xValid)
	Local lAdiciona := .T.
	Default xValid := NIL
	
	Do Case
		Case cCampo == "CND_CONTRA"
			cContrato 	:= xValor
		Case cCampo == "CND_REVISA"
			cRevisao		:= xValor
		Case cCampo == "CND_XIDFLG"
			If CND->(FieldPos("CND_XIDFLG")) == 0
				lAdiciona := .F.
			Else 
				xIdFluig := xValor
			EndIf
			
		Case cCampo == "CND_DTVENC"
			xValor := dDataBase
	EndCase

	If lAdiciona
		//Tratamentos Adicionais
		AADD(aContrato , {cCampo, xValor, xValid})
//		_Super:AddCabec(cCampo, xValor, xValid)
	EndIf
Return()

/*/{Protheus.doc} ALMED01I
(long_description)
@author Jonatas Oliveira | www.compila.com.br
@since 01/02/2018
@version 1.0
@param cCampo, C, Campo
@param xValor, X, Conteudo
@param xValid, X, Validação do Campo
/*/
User Function ALMED01I(cCampo, xValor, xValid)
	If AllTrim(cCampo) == "CNE_DTENT"
		If xValor < dDatabase
			xValor := dDatabase
		EndIf	
	EndIf

	//Tratamentos Adicionais
//	_Super:AddItem(cCampo, xValor, xValid)
	AADD(aItemCtr , {cCampo, xValor, xValid})
Return()





/*/{Protheus.doc} ALMED01G
(long_description)
@author Jonatas Oliveira | www.compila.com.br
@since 01/02/2018
@version 1.0
@param lEncerra, L, ndica se medição sera finalizada automaticamente
@param nMeuOper, N, Opção ExecAuto
@param xIdFluig, C, Id Fluig
@return lRetorno,  L, Sucesso ou Falha
/*/
User Function ALMED01G(lEncerra, nMeuOper, xIdFluig)
	Local lRetorno		:= .T.
	Local cErro := ''
	Local nIndx := 0
	Local aCabec := {}
	Local aItem  := {}
	//Local aCabec, aItens, aLinha, nI
	Private lMsHelpAuto 	:= .T.
	Private lMsErroAuto	:= .F.
	Private cWsMedIdent := "1"
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 04/10/2017 - 6:07:05 PM
	Parametro que indica se medição sera finalizada automaticamente.
	------------------------------------------------------------------------------------------*/
	lEncerra	:= Getmv("ES_ENCMED",.F.,.T.)
	
	xCritMed := ""
	U_ALMEDENV(1, "GCT")

	DbSelectArea("CN9")
	DbSetOrder(1)		//CN9_FILIAL, CN9_NUMERO, CN9_REVISA
	
	If CN9->(DbSeek(xFilial("CN9") + cContrato + cRevisao)) 

		cErro := ContrFixoCronog(aContrato, aItnsCtr)
		
		If !Empty(cErro)
			cMensagem := cErro
			lRetorno := .F.
		EndIf
		
		/*
		-----------------------------------------------------------------------------------------------------
			Executa rotina automatica para gerar as medicoes
		-----------------------------------------------------------------------------------------------------	
		*/
		If lRetorno
			DBSELECTAREA("CND")
			CND->(DbOrderNickName("FLUIG"))
//			CND->(DBSETORDER(6))//|CND_XIDFLG|
			
			/*----------------------------------------
				11/01/2018 - Jonatas Oliveira - Compila
				Se já existir a medição exclui para gerar
				nova
			------------------------------------------*/			
			IF CND->(DBSEEK(xIdFluig))
				
				IF !Empty(CND->CND_DTFIM).AND. CND->CND_AUTFRN == '1' 	.AND. CND->CND_SERVIC == '1'
					lRetorno := .F.
					cMensagem := "Medicao Encerrada"
				ELSE
					lMsErroAuto	:= .F.
					
					cDoc := CND->CND_NUMMED	
					aAdd(aCabec,{"CND_FILIAL"	,CND->CND_FILIAL	,NIL})	
					aAdd(aCabec,{"CND_CONTRA"	,CND->CND_CONTRA	,NIL})	
					aAdd(aCabec,{"CND_REVISA"	,CND->CND_REVISA	,NIL})	
					aAdd(aCabec,{"CND_NUMERO"	,CND->CND_NUMERO	,NIL})	
					aAdd(aCabec,{"CND_NUMMED"	,CND->CND_NUMMED	,NIL})
					aAdd(aCabec,{"CND_DTVENC"	,dDatabase			,NIL})
					
					CNTA120(aCabec, aItem, 5, .F.)
					
					If lMsErroAuto

						lRetorno := .F.
				
						If lExibeTela
							MostraErro()
						EndIf
							
						If lGravaLog
							cMensagem := MostraErro(cPathLog, cFileLog)
						EndIf
					Else
						IF CND->CND_DTVENC < DDATABASE
							CND->(RecLock("CND",.F.))
								CND->CND_DTVENC :=  DDATABASE				
							CND->(MsUnLock())
						ENDIF
					EndIf
				ENDIF 
			ENDIF 
			
			IF lRetorno

				lMsErroAuto	:= .F.
				
				CNTA120(aContrato, aItnsCtr, nMeuOper, .F.)
				
				If lMsErroAuto
					lRetorno := .F.
			
					If lExibeTela
						MostraErro()
					EndIf
						
					If lGravaLog
						cMensagem := MostraErro(cPathLog, cFileLog)
					EndIf
				Else
					IF CND->CND_DTVENC < DDATABASE
						CND->(RecLock("CND",.F.))
							CND->CND_DTVENC :=  DDATABASE				
						CND->(MsUnLock())
					ENDIF	
				EndIf
			ENDIF 
				
			If lRetorno .AND. lEncerra
			//IF .T. 
				/*
				-----------------------------------------------------------------------------------------------------
					Executa rotina automatica para encerrar as medicoes
				-----------------------------------------------------------------------------------------------------	
				*/
				//CNTA120(::aCabec, ::aItens, 6, .F.)
				lMsErroAuto	:= .F.
				//lRetAux		:= STARTJOB("U_CL02ENC",GetEnvServer(), .F., {"01",CND->CND_FILIAL,CND->CND_NUMMED})
				
				/*---------------------------------
					FILA INTEGRADOR PROTHEUS
				----------------------------------*/
				U_CP12ADD("000001", "CND", CND->(RECNO()), , )
			
			EndIf
		
		Else
			xCritMed := " (Contrato: '" + cContrato + "' Revisao: '" + cRevisao + "' )"
			lRetorno := .F.
		EndIf
	Else
		xCritMed := " (Contrato: '" + cContrato + "' Revisao: '" + cRevisao + "' )"
	
		cMensagem := "Contrato nao localizado."
		//Console("Contrato nao localizado.")
		lRetorno := .F.
	EndIf

	U_ALMEDENV(2, "GCT")

Return lRetorno

//-------------------------------------------------------------------
/*{Protheus.doc} ContrFixoCronog
Verifica se é contrato fixo com cronograma

@author Oswaldo.Leite
@since 28/12/2015
@version P12
*/
//-------------------------------------------------------------------
Static function ContrFixoCronog(aLstCabec, aLstItens) 

Local cErrMensagem := ''
Local cCN1alias := GetNextAlias()
Local cCNFalias := GetNextAlias()
Local nPerc := 0
Local nVlrDe := 0
Local nVlrAte := 0
Local nIdx1  := 0
Local nIdx2  := 0
Local nIdx3  := 0
Local nIdx4  := 0
Local nIdx5  := 0
LOcal nCnt := 0
LOcal nSomaCNEs := 0
Local nVlrMenorAte := 0
Local lForaIntervalo := .T.
Local cQuery

BeginSql Alias cCN1alias
		SELECT CN1.* FROM %table:CN1% CN1 WHERE              
		CN1.CN1_FILIAL     = %xFilial:CN1%
		AND CN1.%NotDel%    AND CN1.CN1_CODIGO     = %EXP:( CN9->CN9_TPCTO )%        
EndSql
		
							
If (cCN1alias)->(!Eof()) .And. AllTrim((cCN1alias)->(CN1_CODIGO)) == AllTrim(CN9->CN9_TPCTO) 	
 	If AllTrim((cCN1alias)->(CN1_MEDEVE)) == "2"  .And. AllTrim((cCN1alias)->(CN1_MEDAUT)) == "1"  .And.  	   AllTrim((cCN1alias)->(CN1_CTRFIX)) == "1"  .ANd. AllTrim((cCN1alias)->(CN1_VLRPRV)) == "1"

 	   nIdx1 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_SERVIC'})
 	   nIdx2 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_CONTRA'})
	   nIdx3 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_COMPET'})
	   nIdx4 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_NUMERO'})
	   nIdx5 := aScan(ALSTITENS[1],{|x| AllTrim(x[1]) == 'CNE_VLTOT'})
						
	   If nIdx1 > 0 .And. nIdx2 > 0 .And. nIdx3 > 0 .And. nIdx4 > 0 .And. nIdx5 > 0
	   
	   	/*
		    BeginSql Alias cCNFalias
								
			SELECT CNF.* FROM %table:CNF% CNF WHERE              
			CNF.CNF_FILIAL     = %xFilial:CNF%
			AND CNF.%NotDel%    
			AND CNF.CNF_FILIAL     = %EXP:( Fwxfilial('CNF') )%
			AND CNF.CNF_CONTRA     = %EXP:( aLSTCabec[nIdx2][2] )%
			AND CNF.CNF_NUMPLA     = %EXP:( aLSTCabec[nIdx4][2] )%
			AND CNF.CNF_COMPET     = %EXP:( aLSTCabec[nIdx3][2] )%        
								                
			EndSql
		*/
			
			/*------------------------------------------------------ Augusto Ribeiro | 23/10/2017 - 11:52:30 AM
				Correção de erro que não considerava revisão vigente do contrato
			------------------------------------------------------------------------------------------*/		
			cQuery := " SELECT CNF.* "+CRLF
			cQuery += " FROM "+RetSqlName("CNF")+" CNF "+CRLF
			cQuery += " INNER JOIN "+RetSqlName("CN9")+" CN9 "+CRLF
			cQuery += "     ON CN9_FILIAL = CNF_FILIAL "+CRLF
			cQuery += "     AND CN9_NUMERO = CNF_CONTRA "+CRLF
			cQuery += "     AND CN9_SITUAC= '05' "+CRLF
			cQuery += "     AND CN9_REVISA = CNF_REVISA "+CRLF
			cQuery += "     AND CN9.D_E_L_E_T_ = '' "+CRLF
			cQuery += " WHERE CNF_FILIAL = '"+Fwxfilial('CNF')+"' "+CRLF
			cQuery += " AND CNF_CONTRA = '"+aLSTCabec[nIdx2][2]+"' "+CRLF
			cQuery += " AND CNF_NUMPLA = '"+aLSTCabec[nIdx4][2]+"' "+CRLF
			cQuery += " AND CNF_COMPET =  '"+aLSTCabec[nIdx3][2]+"' "+CRLF
			cQuery += " AND CNF.D_E_L_E_T_ = '' "+CRLF
			
			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cCNFalias,.F., .T.)						
			
								
			If (cCNFalias)->(!Eof()) .And. AllTrim((cCNFalias)->(CNF_CONTRA)) == AllTrim(aLSTCabec[nIdx2][2]) .And. ;
			    AllTrim((cCNFalias)->(CNF_NUMPLA)) == AllTrim(aLSTCabec[nIdx4][2]) .ANd. ; 	
			    AllTrim((cCNFalias)->(CNF_COMPET)) == AllTrim(aLSTCabec[nIdx3][2]) 

		   
			    For nCnt := 1 to Len(ALSTITENS)
			    	nSomaCNEs +=  ALSTITENS[nCnt][nIdx5][2]
		   		Next
		        
		   		If AllTrim(aLSTCABEC[nIdx1][2]) == '1'//Nao
		   			If nSomaCNEs > (cCNFalias)->(CNF_VLPREV)
			   			cErrMensagem := "Valor total da medição (" + AllTrim( Transform(nSomaCNEs,"@E 9999,999,999.99")  ) +") maior que o valor (" + AllTrim(   Transform((cCNFalias)->(CNF_VLPREV),"@E 9999,999,999.99")       ) + ")  do Cronograma " + AllTrim((cCNFalias)->(CNF_NUMERO)) + " !"
		   			ENdIf
				Else		 	
					nPerc := (cCN1alias)->(CN1_LMTMED)
					nVlrDe := (cCNFalias)->(CNF_VLPREV)
					nVlrAte := (cCNFalias)->(CNF_VLPREV) + ((nVlrDe * nPerc)/100 )
					nVlrMenorAte := (cCNFalias)->(CNF_VLPREV) - ((nVlrDe * nPerc)/100 )
					lForaIntervalo := .T.

					//If (nSomaCNEs < nVlrDe) .or. (nSomaCNEs > nVlrAte)
					If (nSomaCNEs >= nVlrDe) .And. (nSomaCNEs <= nVlrAte)
						lForaIntervalo := .F.
					EndIf

					If (nSomaCNEs >= nVlrMenorAte) .And. (nSomaCNEs <= nVlrDe)
						lForaIntervalo := .F.
					EndIf
					
					If lForaIntervalo
						cErrMensagem := ">>> Valor total da medição (" + AllTrim(Transform(nSomaCNEs,"@E 9999,999,999.99")) +") não corresponde a margem de valores ( de " + AllTrim( Transform(nVlrDe,"@E 9999,999,999.99")  )  + " até " + AllTrim( Transform(nVlrAte,"@E 9999,999,999.99")  ) + ") "  
						cErrMensagem += " ou a margem ( de " + AllTrim( Transform(nVlrMenorAte,"@E 9999,999,999.99")  )  + " até " + AllTrim( Transform(nVlrDe,"@E 9999,999,999.99")  ) + ")  "
						cErrMensagem += " deste Cronograma " + AllTrim((cCNFalias)->(CNF_NUMERO)) + " !"
					EndIf
		   		EndIf
		   	Else
		   		cErrMensagem := "Cronograma não localizado no sistema (tabela CNF)!"
	   		EndIf
	   		
	   		(cCNFalias)->(DbCLoseArea())
 	   EndIf
 	   
 	EndIf
	
EndIf
						
(cCN1alias)->(DbCLoseArea())


Return cErrMensagem


/*/{Protheus.doc} ALMEDENV
Prepara o Ambiente para Gravacao na Empresa Correta
@author Jonatas Oliveira | www.compila.com.br
@since 01/02/2018
@version 1.0
/*/
User Function ALMEDENV(nOpcao, cModulo)
	Local	nTamEmp	:= Len(cEmpGrv)
	Default cModulo	:= "FAT"

	If nTamEmp > 2
		cEmpGrv := Substr(cEmpGrv, 1, 2)
	EndIf

	If nOpcao == 1
		If !Empty(cEmpGrv) .AND. !Empty(cFilGrv)
			cEmpBkp := cEmpAnt
			cFilBkp := cFilAnt
			
			If cEmpGrv <> cEmpBkp .OR. cFilGrv <> cFilBkp
				RpcClearEnv()
				RPCSetType(3)
				RpcSetEnv(cEmpGrv, cFilGrv, NIL, NIL, cModulo, NIL, aTabelas)
			EndIf
		EndIf
	Else
		If !Empty(cEmpBkp) .AND. !Empty(cFilBkp)
			If cEmpBkp <> cEmpAnt .OR. cFilBkp <> cFilAnt
				RPCSetType(3)
				RpcSetEnv(cEmpBkp, cFilBkp, NIL, NIL, cModulo, NIL, aTabelas)
			EndIf
		EndIf
	EndIf

	lExibeTela	:= SuperGetMV("CL_SHOWERR", NIL, .F.)
	lGravaLog	:= SuperGetMV("CL_GRVLOG", NIL, .T.)

Return Nil



