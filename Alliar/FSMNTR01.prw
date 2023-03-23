#Include 'Protheus.ch'

/*/{Protheus.doc} FSMNTR01
Ordem de Serviço Grafica modelo Alliar

@author claudiol
@since 16/11/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function FSMNTR01(aParam)

Local oPrint		:= aParam[1]
Local cDEPLANO	:= aParam[2]
Local cATEPLANO	:= aParam[3]
Local aMATOS		:= aParam[4]
Local nRecOs		:= aParam[5]

Local cCONDICAO := If(cDEPLANO = Nil,'stj->tj_situaca == "L"',;
                     	If(MV_PAR25==1,'stj->tj_situaca == "L"',;
	                    If(MV_PAR25==2,'stj->tj_situaca == "P"',;
                     'stj->tj_situaca <> "C"')))
Local xk := 0,xz := 0,nContador := 0
Local cLoc
Local lIdent		:= .F.
Local nContLinha	:= 1
Local nLinha		:= 0
Local lCabStl1		:= .T.
Local cT5Sequen	:= Space(TAMSX3("T5_SEQUENC")[1])
Local cDescSint 	:= Space(TAMSX3("TTB_DESSIN")[1])
Local cBloqPort 	:= Space(TAMSX3("TTB_BLOQPT")[1])
Local nXi			:= 0
Local cHorDif		:= ""

Private aBenseP	:= {}
Private li			:= 4000 ,m_pag := 1
Private nINDSTQ	:= 1 
Private aVETINR	:= {} 
Private cSEQWHI	:= If(lSEQSTL,"STL->TL_SEQRELA = '0  '","STL->TL_SEQUENC = 0")
Private cSEQSTL	:= If(lSEQSTL,"0  ",Str(0,2))

Private oFontPN 	:= TFont():New( "Times New Roman",,10,,.T.,,,,.F.,.F. ) //TFont():New("Courier New",13,13,,.T.,,,,.F.,.F.)
Private oFontMN 	:= TFont():New( "Times New Roman",,14,,.T.,,,,.F.,.F. ) //TFont():New("Courier New",18,18,,.T.,,,,.F.,.F.)
Private oFont16 	:= TFont():New( "Times New Roman",,16,,.T.,,,,.F.,.F. ) //TFont():New("Courier New",18,18,,.T.,,,,.F.,.F.)

Default nRecOs := 0

If !IsInCallStack("MNTA990")
	If MV_PAR25==2
		cCONDICAO := 'stj->tj_situaca == "P"' 
	EndIf
	cCONDICAO += ' .And. stj->tj_ccusto >= MV_PAR07 .And. stj->tj_ccusto <= MV_PAR08 .And. ';
    	         +'stj->tj_centrab >= MV_PAR09 .And. stj->tj_centrab <= MV_PAR10 .And. ';
        	     +'stj->tj_codarea >= MV_PAR11 .And. stj->tj_codarea <= MV_PAR12 .And.';
	             +'stj->tj_ordem >= MV_PAR13 .And. stj->tj_ordem <= MV_PAR14 .And. ';
    	         +'stj->tj_dtmpini >= MV_PAR15 .And. stj->tj_dtmpini <= MV_PAR16'
Else
	cCONDICAO := 'stj->tj_situaca <> "C" .And. stj->tj_ccusto >= MV_PAR07 .And. stj->tj_ccusto <= MV_PAR08 .And. ';
    	         +'stj->tj_centrab >= MV_PAR09 .And. stj->tj_centrab <= MV_PAR10 .And. ';
        	     +'stj->tj_codarea >= MV_PAR11 .And. stj->tj_codarea <= MV_PAR12 .And.';
        	     +'stj->tj_ordem >= MV_PAR13 .And. stj->tj_ordem <= MV_PAR14'
EndIf

aDBFR675 := {{"ORDEM"   ,"C", 06,0},;
             {"PLANO"   ,"C", 06,0},;
             {"SERVICO" ,"C", 06,0},;
             {"CODBEM"  ,"C", 16,0},;
             {"CCUSTO"  ,"C", Len(STJ->TJ_CCUSTO),0},;
             {"DATAOS"  ,"D", 08,0},;
             {"DIFFDT"  ,"N", 08,0},;
             {"BEMPAI"  ,"C", 16,0}}

If MV_PAR17 = 1      //Ordem
   vIND675 := {"ORDEM"}
ElseIf MV_PAR17 = 2  //Servico/Bem 
   vIND675 := {"SERVICO+CODBEM"}
ElseIf MV_PAR17 = 3  //Centro Custo 
   vIND675 := {"CCUSTO"}
ElseIf MV_PAR17 = 4  //Data da O.S.
   vIND675 := {"Dtos(DATAOS)"}
Else                 // Servico/Bem Pai
   vIND675 := {"SERVICO+BEMPAI"}
EndIf    
                  
cARQTR675 := NGCRIATRB(aDBFR675,vIND675,"TRB675")

If FindFunction("NGSEQETA")
   nINDSTQ := NGSEQETA("STQ",nINDSTQ)
EndIf 

lSEQETA := .F. 
DbSelectArea("STQ")
If FieldPos("TQ_SEQETA") > 0
   lSEQETA := .T.
EndIf 

If cDEPLANO == Nil .and. nRecOS == 0
	DbSelectArea("STI")
	DbSetOrder(01)
	DbSeek(xFilial("STI")+MV_PAR01)
	DbSelectArea("STJ")
	DbSetOrder(03)
	DbSeek(xFilial("STJ")+MV_PAR01,.T.)
	ProcRegua(LastRec())
	While !EoF() .And. STJ->TJ_FILIAL == xFilial("STJ") .And.;
		STJ->TJ_PLANO >= MV_PAR01 .And. STJ->TJ_PLANO <= MV_PAR02
		IncProc()
		If &(cCONDICAO)
			FGrvTrb()
		EndIf
		DbSelectArea("STJ")
		DbSkip()
	End
Elseif cDEPLANO == Nil .and. nRecOS <> 0
	dbSelectArea("STJ")
	dbGoTo(nRecOS)
	FGrvTrb()	
Else
	DbSelectArea("STJ")
	DbSetOrder(03)
	DbSeek(xFilial("STJ")+cDEPLANO,.T.)
	ProcRegua(LastRec())
	While !EoF() .And. STJ->TJ_FILIAL == xFilial("STJ") .And.;
		STJ->TJ_PLANO <= cATEPLANO
		
		IncProc()
		If &(cCONDICAO)
			
			nPosOs := aSCAN(aMATOS, {|x| x[1]+x[2] == STJ->TJ_PLANO+STJ->TJ_ORDEM})
			If nPosOs > 0
				nDiff := nil
				If Len(aMATOS[nPosOs]) >= 3
					nDiff := aMATOS[nPosOs,3] //Indica a quantidade de dias que as datas da OS serão deslocadas
				EndIf
				FGrvTrb( nDiff )
			EndIf
			
		EndIf
		DbSelectArea("STJ")
		DbSkip()
	EndDo
EndIf

Private INCLUI:= .F.

DbSelectArea("TRB675")   
DbGotop()
ProcRegua(LastRec())
While !EoF()
	IncProc()
   
	nPaG := 0
	DbSelectArea("STJ")
	DbSetOrder(01)
	If DbSeek(xFilial("STJ")+TRB675->ORDEM+TRB675->PLANO)

		aInsumos	:= {}
		aTrabalhos	:= {}
		aOcorren	:= {}

		//Carrega array de insumos e trabalhos
		FCarTrab(aInsumos,aTrabalhos)

		//Carrega array de ocorrencias
		FCarOcor(aOcorren)

		DbSelectArea("STF")
		DbSetOrder(01)
		cSEQSTF := If(lSEQSTF,STJ->TJ_SEQRELA,STR(STJ->TJ_SEQUENC,3))
		DbSeek(xFilial('STF')+STJ->TJ_CODBEM+STJ->TJ_SERVICO+cSEQSTF)

		If !Empty(STJ->TJ_SOLICI)
			lTQB:= .T.		
			TQB->(dbSetOrder(1)) //TQB_FILIAL+TQB_SOLICI
			TQB->(MsSeek(xFilial("TQB")+STJ->TJ_SOLICI))
		Else
			lTQB:= .F.		
		EndIf

		FLinCab(oPrint)

		FLinCab(oPrint)

		aPriori:= {"Alta","Media","Baixa"}

		oPrint:Say(li,15,"Emissão: " + Dtoc(Date()) + " " + Time(),oFonTPN)
		oPrint:Say(li,1000,"Encerramento: ",oFonTPN)
		FLinCab(oPrint)
		oPrint:Say(li,15,"Solicitante: " + Iif(lTQB,SubStr(UsrRetName(TQB->TQB_CDSOLI),1,15),""),oFonTPN)
		oPrint:Say(li,1000,"Criticidade: " + Iif(lTQB, aPriori[Val(TQB->TQB_PRIORI)],""),oFonTPN)
		FLinCab(oPrint)
		oPrint:Say(li,15,"Manutenção: " + STJ->TJ_TIPO + "-" + STE->(VDISP(STJ->TJ_TIPO,'TE_NOME')),oFonTPN)
		FLinCab(oPrint)
		oPrint:Say(li,15,"Serviço: " + STJ->TJ_SERVICO + "-" + ST4->(VDISP(STJ->TJ_SERVICO,'T4_NOME')),oFonTPN)
		FLinCab(oPrint)
		cMenAux:= "Solicitação de Atendimento: Número: " + STJ->TJ_SOLICI
		cMenAux+= "Data/Hora: " + Iif(lTQB, DtoC(TQB->TQB_DTABER),"") + Space(4) + Iif(lTQB, TQB->TQB_HOABER,"")
		oPrint:Say(li,15,cMenAux,oFonTPN)
		FLinCab(oPrint)
		oPrint:Say(li,15,"Descrição do Fluig:",oFonTPN)
		FLinCab(oPrint)
		cMenAux:= Iif(lTQB, MNT280REL("TQB_DESCSS"), "")
		FImpMen("",cMenAux,100,100,.F.)

		FLinCab(oPrint)

		//DESCRICAO DO EQUIPAMENTO
		ST9->(dbSetOrder(01))
		ST9->(MsSeek(xFilial("ST9")+STJ->TJ_CODBEM))

		FLinCab(oPrint)
		oPrint:Say(li,800,"DESCRIÇÃO DO EQUIPAMENTO",oFonTMN)
		FLinCab(oPrint)
		oPrint:Line(li,15,li,2335)
		
		FLinCab(oPrint)
		oPrint:Say(li,15  ,"Equipamento: "	+ ST9->T9_CODBEM + " "+ ST9->T9_NOME, oFonTPN)
		oPrint:Say(li,1700,"Patrimônio: " 	+ ST9->T9_CODIMOB, oFonTPN)
		
		FLinCab(oPrint)
		oPrint:Say(li,15  ,"Marca: " + ST6->(VDISP(ST9->T9_CODFAMI,'T6_NOME')), oFonTPN)
		oPrint:Say(li,1000,"Modelo: "+ ST9->T9_TIPMOD , oFonTPN)
		oPrint:Say(li,1700,"Nº de Série: "	+ ST9->T9_SERIE, oFonTPN)

		FLinCab(oPrint)
		oPrint:Say(li,15  ,"Contrato: "	+ ST9->T9_XCONTRA, oFonTPN)
		oPrint:Say(li,1000,"Fornecedor: " + SA2->(VDISP(ST9->T9_FORNECE+ST9->T9_LOJA,'A2_NOME')) , oFonTPN)

		FLinCab(oPrint)
		oPrint:Say(li,15  ,"Priorização: " + ST9->T9_PRIORID, oFonTPN)
		oPrint:Say(li,1000,"Garantia: "	+ Dtoc(ST9->T9_DTGARAN), oFonTPN)

		FLinCab(oPrint)
		oPrint:Say(li,15,"Acessórios:", oFonTPN)

		FLinCab(oPrint)
		FImpMen("",ST9->T9_XACESS,100,100,.F.)

		FLinCab(oPrint)

		//DESCRICAO DO BEM FILHO
		FLinCab(oPrint)
		oPrint:Say(li,800,"DESCRIÇÃO DO BEM FILHO",oFonTMN)
		FLinCab(oPrint)
		oPrint:Line(li,15,li,2335)

		STC->(dbSetOrder(01)) //TC_FILIAL+TC_CODBEM+TC_COMPONE+TC_TIPOEST+TC_LOCALIZ+TC_SEQRELA
		STC->(MsSeek(cSeek:=xFilial("ST9")+STJ->TJ_CODBEM))
		While STC->(!Eof()) .And. cSeek==STC->(TC_FILIAL+TC_CODBEM)

			ST9->(dbSetOrder(01))
			ST9->(MsSeek(xFilial("ST9")+STC->TC_COMPONE))
			
			FLinCab(oPrint)
			oPrint:Say(li,15  ,"Equipamento: "	+ ST9->T9_CODBEM + " "+ ST9->T9_NOME, oFonTPN)
			oPrint:Say(li,1700,"Patrimônio: " 	+ ST9->T9_CODIMOB, oFonTPN)
			
			FLinCab(oPrint)
			oPrint:Say(li,15  ,"Marca: " + ST6->(VDISP(ST9->T9_CODFAMI,'T6_NOME')), oFonTPN)
			oPrint:Say(li,1000,"Modelo: "+ ST9->T9_TIPMOD , oFonTPN)
			oPrint:Say(li,1700,"Nº de Série: "	+ ST9->T9_SERIE, oFonTPN)
			FLinCab(oPrint)
			oPrint:Say(li,15,"Acessórios:", oFonTPN)
	
			FLinCab(oPrint)
			FImpMen("",ST9->T9_XACESS,100,100,.F.)
			
			STC->(dbSkip())
		EndDo

		FLinCab(oPrint)

		//TRABALHOS REALIZADOS
		FLinCab(oPrint)
		oPrint:Say(li,800,"TRABALHOS REALIZADOS",oFonTMN)
		FLinCab(oPrint)
		oPrint:Line(li,15,li,2335)

		FLinCab(oPrint)
		nCol:= 15
		oPrint:Say(li,nCol,"INDICE", oFonTPN)
		oPrint:Say(li,nCol+=150,"TÉCNICO", oFonTPN)
		oPrint:Say(li,nCol+=650,"ATIVIDADE", oFonTPN)
		oPrint:Say(li,nCol+=600,"DT INICIO", oFonTPN)
		oPrint:Say(li,nCol+=250,"DT FIM", oFonTPN)
		oPrint:Say(li,nCol+=200,"HR INICIO", oFonTPN)
		oPrint:Say(li,nCol+=200,"HR FIM", oFonTPN)

		For nXi:= 1 To Len(aTrabalhos)
			FLinCab(oPrint)
			nCol:= 15
			oPrint:Say(li,nCol,cValToChar(nXi), oFonTPN)
			oPrint:Say(li,nCol+=150,aTrabalhos[nXi,1], oFonTPN)
			oPrint:Say(li,nCol+=650,aTrabalhos[nXi,2], oFonTPN)
			oPrint:Say(li,nCol+=600,Dtoc(aTrabalhos[nXi,3]), oFonTPN)
			oPrint:Say(li,nCol+=250,Dtoc(aTrabalhos[nXi,5]), oFonTPN)
			oPrint:Say(li,nCol+=200,aTrabalhos[nXi,4], oFonTPN)
			oPrint:Say(li,nCol+=200,aTrabalhos[nXi,6], oFonTPN)
		Next nXi

		FLinCab(oPrint)

		//DESCRIÇÃO DOS TRABALHOS REALIZADOS
		FLinCab(oPrint)
		oPrint:Say(li,800,"DESCRIÇÃO DOS TRABALHOS REALIZADOS",oFonTMN)
		FLinCab(oPrint)
		oPrint:Line(li,15,li,2335)
		FLinCab(oPrint)

		For nXi:= 1 To Len(aTrabalhos)
			oPrint:Say(li,15,cValToChar(nXi), oFonTPN)
			FImpMen("",aTrabalhos[nXi,7],100,100,.F.)
			FLinCab(oPrint)
		Next nXi 


		//INSUMOS
		FLinCab(oPrint)
		oPrint:Say(li,800,"INSUMOS",oFonTMN)

		FLinCab(oPrint)
		oPrint:Line(li,15,li,2335)

		FLinCab(oPrint)
		nCol:= 165
		oPrint:Say(li,nCol,"NOME", oFonTPN)
		oPrint:Say(li,nCol+=600,"CODIGO", oFonTPN)
		oPrint:Say(li,nCol+=350,"DESCRIÇÃO", oFonTPN)
		oPrint:Say(li,nCol+=800,"QTDE", oFonTPN)
		oPrint:Say(li,nCol+=200,"TECNICO", oFonTPN)

		For nXi:= 1 To Len(aInsumos)
			FLinCab(oPrint)
			nCol:= 15
			oPrint:Say(li,nCol,cValToChar(nXi), oFonTPN)
			oPrint:Say(li,nCol+=150,aInsumos[nXi,1], oFonTPN)
			oPrint:Say(li,nCol+=600,aInsumos[nXi,2], oFonTPN)
			oPrint:Say(li,nCol+=350,aInsumos[nXi,3], oFonTPN)
			oPrint:Say(li,nCol+=800,cValToChar(aInsumos[nXi,4]), oFonTPN)
			oPrint:Say(li,nCol+=200,aInsumos[nXi,5], oFonTPN)
		Next nXi

		FLinCab(oPrint)


		//DESCRIÇÃO DOS DEFEITOS ENCONTRADOS
		FLinCab(oPrint)
		oPrint:Say(li,800,"DESCRIÇÃO DOS DEFEITOS ENCONTRADOS",oFonTMN)
		FLinCab(oPrint)
		oPrint:Line(li,15,li,2335)
		FLinCab(oPrint)

		For nXi:= 1 To Len(aInsumos)
			oPrint:Say(li,15,cValToChar(nXi), oFonTPN)
			FImpMen("",aInsumos[nXi,6],100,100,.F.)
			FLinCab(oPrint)
		Next nXi 
		
		
		//OCORRENCIAS
		FLinCab(oPrint)
		oPrint:Say(li,800,"OCORRÊNCIAS",oFonTMN)
		FLinCab(oPrint)
		oPrint:Line(li,15,li,2335)

		FLinCab(oPrint)
		nCol:= 15
		oPrint:Say(li,nCol,"TAREFA", oFonTPN)
		oPrint:Say(li,nCol+=600,"OCORRENCIA", oFonTPN)
		oPrint:Say(li,nCol+=600,"CAUSA", oFonTPN)
		oPrint:Say(li,nCol+=600,"SOLUCAO", oFonTPN)

		For nXi:= 1 To Len(aOcorren)
			FLinCab(oPrint)
			nCol:= 15
			oPrint:Say(li,nCol,aOcorren[nXi,1], oFonTPN)
			oPrint:Say(li,nCol+=600,aOcorren[nXi,2], oFonTPN)
			oPrint:Say(li,nCol+=600,aOcorren[nXi,3], oFonTPN)
			oPrint:Say(li,nCol+=600,aOcorren[nXi,4], oFonTPN)
		Next nXi

		FLinCab(oPrint)
		

		//PARTE FINAL
		FLinCab(oPrint)
		cMenAux:= "RESPONSÁVEL PELO ATENDIMENTO: " + "_____________________________________________" //Iif(lTQB,TQB->TQB_CDEXEC,"__________________________________________")
		cMenAux+= "  ASS.: ____________________________________" 
		oPrint:Say(li,15,cMenAux,oFonTPN)

		FLinCab(oPrint)
		cMenAux:= "CONFIRMO QUE O EQUIPAMENTO ESTÁ SENDO ENTREGUE EM:"
		oPrint:Say(li,15,cMenAux,oFonTPN)

		FLinCab(oPrint)
		cMenAux:= "[  ] PERFEITO FUNCIONAMENTO   [  ] FUNCIONAMENTO PARCIAL   [  ] INOPERANTE"
		oPrint:Say(li,15,cMenAux,oFonTPN)

		FLinCab(oPrint)
		FLinCab(oPrint)
		cMenAux:= "Emissão: " + DtoC(STJ->TJ_DTMPINI) + Space(3) + STJ->TJ_HOMPINI 
		oPrint:Say(li,15,cMenAux,oFonTPN)
		cMenAux:= "Encerramento: " + DtoC(STJ->TJ_DTPRFIM) + Space(3) + STJ->TJ_HOPRFIM 
		oPrint:Say(li,1000,cMenAux,oFonTPN)

		//Calcula intervalo de horas
		If !Empty(STJ->TJ_DTMPINI) .And. !Empty(STJ->TJ_HOMPINI) .And. !Empty(STJ->TJ_DTPRFIM) .And. !Empty(STJ->TJ_HOPRFIM) 
			cHorDif:= U_FSCalInt(STJ->TJ_DTMPINI, STJ->TJ_DTPRFIM, STJ->TJ_HOMPINI, STJ->TJ_HOPRFIM)
		Else
			cHorDif:= ""
		EndIf

		FLinCab(oPrint)
		FLinCab(oPrint)
		cMenAux:= "Tempo para Reparo: " + cHorDif
		oPrint:Say(li,15,cMenAux,oFonTPN)

		FLinCab(oPrint)
		FLinCab(oPrint)
		cMenAux:= "NOME : ___________________________________________"
		oPrint:Say(li,15,cMenAux,oFonTPN)
		cMenAux:= "ASS: _____________________________________________"
		oPrint:Say(li,1100,cMenAux,oFonTPN)

		FLinCab(oPrint)
		cMenAux:= "SETOR: ___________________________________________"
		oPrint:Say(li,15,cMenAux,oFonTPN)
		cMenAux:= "DATA: ____________________________________________"
		oPrint:Say(li,1100,cMenAux,oFonTPN)

		FLinCab(oPrint)
		FLinCab(oPrint)
		cMenAux:= "PESQUISA DE SATISFAÇÃO SOBRE A QUALIDADE DO ATENDIMENTO E SERVIÇO PRESTADOS:"
		oPrint:Say(li,15,cMenAux,oFonTPN)

		FLinCab(oPrint)
		cMenAux:= "[ ]OTIMO   [ ]BOM   [ ]REGULAR   [ ]RUIM   [ ]PESSIMO"
		oPrint:Say(li,15,cMenAux,oFonTPN)

		FLinCab(oPrint)
		FLinCab(oPrint)
		oPrint:Say(li,15,"OBSERVAÇÃO:",oFonTPN)

		For nXi:= 1 To 5
			FLinCab(oPrint)
			oPrint:Say(li,15,Repl("_",120),oFonTPN)
		Next nXi

	EndIf

	DbSelectArea("TRB675")
	dbSkip()

	li := 4000

EndDO


//Deleta o arquivo temporario fisicamente 
NGDELETRB("TRB675",cARQTR675)    

oPrint:EndPage()
RetIndex('STJ')
Set Filter To
DbSetOrder(01)  

If MV_PAR22 = 1 //Em Disco
	oPrint:Preview()
Else // Via Spool
	oPrint:Print()
EndIf 

Return NIL


/*/{Protheus.doc} FGrvTrb
Grava registro em arquivo temporario

@type function
@author claudiol
@since 26/11/2015
@version 1.0
@param nDiffDias, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FGrvTrb( nDiffDias )

DbSelectArea("TRB675")
TRB675->(DbAppend())
TRB675->ORDEM   := STJ->TJ_ORDEM
TRB675->PLANO   := STJ->TJ_PLANO
TRB675->SERVICO := STJ->TJ_SERVICO
TRB675->CODBEM  := STJ->TJ_CODBEM
TRB675->CCUSTO  := STJ->TJ_CCUSTO
TRB675->DATAOS  := STJ->TJ_DTMPINI
If ValType(nDiffDias) == "N"
	TRB675->DIFFDT := nDiffDias
EndIf
nPosBP := aSCAN(aBenseP,{|x| x[1] == TRB675->CODBEM})
If nPosBP = 0
	TRB675->BEMPAI := NGBEMPAI(TRB675->CODBEM)
	Aadd(aBenseP,{TRB675->CODBEM,TRB675->BEMPAI})
Else
	TRB675->BEMPAI := aBenseP[nPosBP,2]
EndIf
Return


/*/{Protheus.doc} FImpMen
Imprime Campo Memo

@type function
@author claudiol
@since 26/11/2015
@version 1.0
@param cTITULO, character, (Descrição do parâmetro)
@param cDESCRI, character, (Descrição do parâmetro)
@param nCOLU, numérico, (Descrição do parâmetro)
@param nTAM, numérico, (Descrição do parâmetro)
@param lSOMLI, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FImpMen(cTITULO,cDESCRI,nCOLU,nTAM,lSOMLI)

Local lPrimeiro 	:= .T.
Local lSOMEILI	:= lSOMLI
Local nTotLin 	:= MLCOUNT(cDESCRI,nTAM)
Local nXi			:= 0

For nXi := 1 To nTotLin
	If !Empty((MemoLine(cDESCRI,nTAM,nXi)))
//		If lSOMEILI
//			FLinCab(oPrint)
//			lSOMEILI := .t.
//		Else
//			If Len(AllTrim(MemoLine(cDESCRI,nTAM,nXi))) > 0
//				FLinCab(oPrint)
//			EndIf
//		EndIf
		If lPrimeiro
			If !Empty(cTITULO)
				oPrint:Say(li,15 ,cTITULO,oFonTPN)
			EndIf
			lPrimeiro := .F.
		EndIf
		oPrint:Say(li,nCOLU,(MemoLine(cDESCRI,nTAM,nXi)),oFonTPN)
		FLinCab(oPrint)
	EndIf
Next nXi

Return .t.


/*/{Protheus.doc} FLinCab
Incrementa Linha,Cabecalho e Salto de Pagina

@type function
@author claudiol
@since 26/11/2015
@version 1.0
@param oPrint, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FLinCab(oPrint)

Local aTam		:= {630,400} //Tamanho da imagem
Local cCusto	:= ""

li += 50
If li > 3200
	lQuebra := .T.
	li := 100
	nPaG ++
	oPrint:EndPage()
	oPrint:StartPage()
	
	//Logo
	cLogo := U_FSIMGLOG("ImgAlliar.bmp")
	If File(cLogo)
		oPrint:SayBitMap(li-50,150,cLogo,aTam[1],aTam[2]) // ( < nLinha>, < nCol>, < cBitmap>, largura, altura ) 
	EndIf

	//Localizacao
	oPrint:Say(li,1100,"Localização: " + SM0->M0_FILIAL,oFonTPN)
	
	//Centro de Custo
	li += 50
	cCusto:= Alltrim(STJ->TJ_CCUSTO) + "-" + NGSEEK('SI3',STJ->TJ_CCUSTO,1,'SI3->I3_DESC')
	oPrint:Say(li,1100,"CCusto: " + cCusto,oFonTPN)
	
	//Endereco
	li += 50
	oPrint:Say(li,1100,"Endereço: " + Alltrim(SM0->M0_ENDCOB) + "-" + Alltrim(SM0->M0_COMPCOB) + "-" + Alltrim(SM0->M0_BAIRCOB),oFonTPN)
	li += 50
	oPrint:Say(li,1100,"CEP " + SM0->M0_CEPCOB + "-" + Alltrim(SM0->M0_CIDCOB) + "-" + SM0->M0_ESTCOB,oFonTPN)
	li += 50
	oPrint:Say(li,1100,"Telefone:" + SM0->M0_TEL,oFonTPN)

	//Ordem de Servico
	li += 100
	oPrint:Line(li,15,li,2335)
	oPrint:Say(li,800,"Ordem de Serviço N. "+STJ->TJ_ORDEM,oFont16)
	oPrint:Say(li,2050,"Pág: "+Str(nPag,2),oFonTPN)

	Li += 100
	oPrint:Line(li,15,li,2335)

EndIf

Return


/*/{Protheus.doc} FSImgLog
Monta caminho da imagem

@author claudiol
@since 25/11/2015
@version 
@param cArqImg, characters, descricao
@type function
/*/
User Function FSImgLog(cArqImg)

Local cBarras		:= If(isSRVunix(),"/","\")
Local cRootPath	:= Alltrim(GetSrvProfString("RootPath",cBarras))
Local cStartPath	:= AllTrim(GetSrvProfString("StartPath",cBarras))
Local cLogo 	 	:= ""

//Se StartPath NAO tiver barra no final, adiciona
If SubStr(AllTrim(cStartPath),Len(AllTrim(cStartPath))) != cBarras
	cStartPath += cBarras
EndIf

//Se StartPath NAO tiver barra no inicio, adiciona
If SubStr(AllTrim(cStartPath),1) != cBarras
	cStartPath = cBarras + cStartPath
EndIf

//Se RootPath tiver barra no final, exclui
If SubStr(AllTrim(cRootPath),Len(AllTrim(cRootPath))) == cBarras
	cRootPath = SubStr(AllTrim(cRootPath),1,Len(AllTrim(cRootPath))-1)
EndIf

If File(cRootPath+cStartPath+cArqImg)
   cLogo := cRootPath+cStartPath+cArqImg
ElseIf File(cStartPath+cArqImg)
   cLogo := cStartPath+cArqImg
ElseIf File(cArqImg)
	cLogo := cArqImg
Endif

Return (cLogo)


/*/{Protheus.doc} FCarTrab
(long_description)
@type function
@author claudiol
@since 02/12/2015
@version 1.0
@param aInsumos, array, (Descrição do parâmetro)
@param aTrabalhos, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FCarTrab(aInsumos, aTrabalhos)

Local cSeek:= ""
Local nXi	:= 0

STL->(DbSetOrder(03)) //TL_FILIAL+TL_ORDEM+TL_PLANO+TL_SEQRELA+TL_TAREFA+TL_TIPOREG+TL_CODIGO
STL->(Msseek(cSeek:= XFILIAL('STL')+STJ->TJ_ORDEM+STJ->TJ_PLANO))

While STL->(!EoF()) .And. cSeek==STL->(TL_FILIAL+TL_ORDEM+TL_PLANO)

	If STL->TL_REPFIM=="S"
		If STL->TL_TIPOREG=="P"
			Aadd(aInsumos, {;
				TIPREGBRW(STL->TL_TIPOREG),;
				STL->TL_CODIGO,;
				NOMINSBRW(STL->TL_TIPOREG,STL->TL_CODIGO),;
				STL->TL_QUANTID,;
				STL->TL_XTECN,;
				STL->TL_OBSERVA;
				})
		Else
			Aadd(aTrabalhos, {;
				STL->TL_XTECN,;
				STL->TL_XATIV,;
				STL->TL_DTINICI,;
				STL->TL_HOINICI,;
				STL->TL_DTFIM,;
				STL->TL_HOFIM,;
				STL->TL_OBSERVA;
				})
		EndIf
	EndIf

	STL->(Dbskip())
EndDo

If Empty(aInsumos)
	For nXi:= 1 To 3
		Aadd(aInsumos, {;
			Repl("_",40),;
			Repl("_",Len(STL->TL_CODIGO)),;
			Repl("_",40),;
			Repl("_",12),;
			Repl("_",Len(STL->TL_XTECN)),;
			Repl("_",100);
			})
	Next nXi
EndIf

If Empty(aTrabalhos)
	For nXi:= 1 To 3
		Aadd(aTrabalhos, {;
			Repl("_",Len(STL->TL_XTECN)),;
			Repl("_",Len(STL->TL_XATIV)),;
			Ctod(""),;
			Repl("_",Len(STL->TL_HOINICI)),;
			Ctod(""),;
			Repl("_",Len(STL->TL_HOFIM)),;
			Repl("_",100);
			})
	Next nXi
EndIf

Return


/*/{Protheus.doc} FCarOcor
Buscao ocorrencias

@type function
@author claudiol
@since 03/12/2015
@version 1.0
@param aOcorre, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FCarOcor(aOcorren)

Local cSeek:= ""
Local nXi:= 0

STN->(DbSetOrder(01)) //TN_FILIAL+TN_ORDEM+TN_PLANO+TN_TAREFA+TN_SEQRELA+TN_CODOCOR+TN_CAUSA+TN_SOLUCAO
STN->(Msseek(cSeek:= XFILIAL('STN')+STJ->TJ_ORDEM+STJ->TJ_PLANO))

While STN->(!EoF()) .And. cSeek==STN->(TN_FILIAL+TN_ORDEM+TN_PLANO)

	//STN->TN_TAREFA,; TN_NOMETAR 1a.campo ocorrencia

	Aadd(aOcorren, {;
		VSAY("09"),; 
		ST8->(VDISP(STN->TN_CODOCOR,'T8_NOME')),;
		ST8->(VDISP(STN->TN_CAUSA,'T8_NOME')),;
		ST8->(VDISP(STN->TN_SOLUCAO,'T8_NOME')),;
		STN->TN_DESCRIC;
		})

	STN->(Dbskip())
EndDo

If Empty(aOcorren)
	For nXi:= 1 To 3
		Aadd(aOcorren, {;
			Repl("_",20),;
			Repl("_",Len(ST8->T8_NOME)),;
			Repl("_",Len(ST8->T8_NOME)),;
			Repl("_",Len(ST8->T8_NOME)),;
			Repl("_",Len(STN->TN_DESCRIC));
			})
	Next nXi
EndIf

Return
