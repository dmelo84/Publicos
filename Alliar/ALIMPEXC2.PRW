#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"                                
#INCLUDE "DBSTRUCT.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALIMPEXC2
Importação de arquivos 

@author Itamar Gama.:
@since  23/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALIMPEXC2()
Local cTitulo	:=	"IMPORTAÇÃO ARQUIVOS EXCEL"
Local cText1	:=	"Rotina específica para importação de dados via Arquivo Excel (.CSV )que serão incrementados "
Local cText2	:=	"nas tabelas pertinentes ao módulo, verificar estrutura do arquivo de importação"

Local cNorma    := ""
Local cDest     := ""
Local cDir      := ""
Local cPerg		:= "ALIMPEX"
Local nOpcA		:= 0
Local aSays		:= {}
Local aButtons	:= {}
Local oDlg
Local nOpc	  	:=1	
Local nX		:= 0
Local lJob		:= .F.

Pergunte(cPerg,.F.)

AADD(aSays,OemToAnsi( cText1 ) )
AADD(aSays,OemToAnsi( cText2 ) )

AADD(aButtons, { 1,.T.,{|o| u_ALPrcImp2(),o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
FormBatch( cTitulo, aSays, aButtons )

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} ALProcImp
Ajustar SX1

@author Itamar Gama.:
@since  23/12/2016
@version P12
*/
//-------------------------------------------------------------------

USER Function ALPrcImp2()
     
Local cArq    		:= MV_PAR01
Local cTab			:= MV_PAR02
Local cLinha  		:= ""
Local lPrim   		:= .T.
Local aCampos 		:= {}
Local aDados 	 	:= {}
Local aCamposACH 	:= {}
Local aCamposSU5 	:= {}
Local aCamposAC8 	:= {}
Local aAuxDados		:= {}
Local i				:= 0 
Local i1			:= 0
Local i2			:= 0
Local aTelefone		:= {}
Local aEndereco		:= {}
Local lAtuMov		:= .f.
Private aErro 		:= {}
Private lMsErroAuto := .F.
Private lMsHelpAuto	:= .T. 
Private cOcorrencias:= ''

If !File(cArq)
   	MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","[ALProcImp] - ATENCAO")
   	Return
EndIf
     
 FT_FUSE(cArq)
 ProcRegua(FT_FLASTREC())
 FT_FGOTOP()
 
While !FT_FEOF()
	IncProc("Lendo arquivo texto...")
	cLinha := FT_FREADLN() 
	AADD(aDados,Separa(cLinha,";",.T.))
	FT_FSKIP()
EndDo
nPosCpoCAB:=AScan(aDados, {|x| AllTrim(x[1]) == "TABELAS"})



ProcRegua(Len(aDados))
	
For i:=nPosCpoCAB+1 to Len(aDados)-1
	
	aCamposACH :={}
	aCamposSU5 :={}
	aCamposAC8 :={}
	lMsErroAuto := .F.
    For i1:=2 to Len(aDados[i])
    	 aArray2 :={}
   		 aArray2 := StrTokArr( aDados[nPosCpoCAB][i1], ',')
   		 If Len(aArray2) > 0
   		    For i2:= 1 to Len(aArray2)
   		        aRetTam:={}
   		   		aRetTam:=TamSX3(Alltrim(aArray2[i2]))
   		   		If Len(aRetTam) > 0 
   		   			If aRetTam[1] > len(Alltrim(aDados[i][i1]))
   		   				aRetTam[1]:= len(Alltrim(aDados[i][i1]))
   		   			Endif
   		   			xConteudo:=''
   		   			If aRetTam[3] == "D"
   		   			  	aRetTam[1]:= aRetTam[1]+2	
   		   			  	xConteudo:=Ctod(Left(Alltrim(aDados[i][i1]),aRetTam[1]))
   		   			Else
   		   				xConteudo:=Left(Alltrim(aDados[i][i1]),aRetTam[1])
   		   			Endif	
	   		    	Do Case 
	   		    		Case Left(Alltrim(aArray2[i2]),4)= "ACH_"
	   		    			 Aadd(aCamposACH, {Alltrim(aArray2[i2]),xConteudo,Nil}) 
	   		    		Case Left(Alltrim(aArray2[i2]),3)= "U5_"
	 		    			 Aadd(aCamposSU5, {Alltrim(aArray2[i2]),xConteudo,Nil}) 
	   		    		Case Left(Alltrim(aArray2[i2]),4)= "AC8_"
	  		    			 Aadd(aCamposAC8, {Alltrim(aArray2[i2]),xConteudo,Nil})
	   		    	EndCase
	   			Endif    	
   		    Next i2	
   		 Endif
    Next i1
    cDescSeg:=upper(Alltrim(aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_DESSEG"}))][2]))
	dbSelectArea("AOV")
	dbSetOrder(2)
	If !DbSeek(xFilial("AOV")+cDescSeg)
		RecLock("AOV",.T.)
		AOV->AOV_FILIAL	:= xFilial("AOV")
		AOV->AOV_CODSEG	:= GetSxeNum("AOV","AOV_CODSEG","AOV_CODSEG",1)
		AOV->AOV_DESSEG	:= cDescSeg
		MsUnlock()
	Endif	
   	Aadd(aCamposACH, {"ACH_CODSEG",AOV->AOV_CODSEG,Nil})
   	AOV->(DbCloseArea())

   	cChavePesq:=PADR(Alltrim(xFilial("ACH")),11)
   	cChavePesq+=PADR(Alltrim(aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCONSE"}))][2]),10)
   	cChavePesq+=PADR(Alltrim(aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCRM"}))][2]),6)
   	cChavePesq+=PADR(Alltrim(aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCRMUF"}))][2]),2)
   	cChavePesq+=PADR(Alltrim(aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XMARCA"}))][2]),3)
   	cChavePesq+=PADR(Alltrim(aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CEP"}))][2]),8)

   	DbSelectArea("ACH")
   	//DbOrderNickName("ACHDUPL")
   	DbSetOrder(1)
   	
   	lAtuMov:=.f.
   	cACH_COD:=RetAchouCRM("ACH",aCamposACH)
   	//If ACH->(DbSeek(cChavePesq))
   	if !empty(cACH_COD)
   		if ACH->(DbSeek(xFilial('ACH')+cACH_COD)) 
   			lAtuMov:=.t.
   		endif
   	Endif
	lMsErroAuto:=.F.
	//Begin Transaction
	
	// Inclusao Médicos
   	Aadd(aCamposACH, {"ACH_FILIAL" 	,xFilial("ACH"),Nil})  
	//if primero se sim rola
    If !lAtuMov
    	//Cria ACH - MEDICOS
   		//DbSelectArea("ACH")
    	//DbSetOrder(1)
    	
    	//cACH_COD := GetSxeNum("ACH","ACH_CODIGO","ACH_CODIGO",1)
	  	cACH_COD := RetPrxNr("ACH")
		//Do While ACH->(DbSeek(cACH_COD))	
		//	cACH_COD := GetSxeNum("ACH","ACH_CODIGO","ACH_CODIGO",1)
		//Enddo    
		Aadd(aCamposACH, {"ACH_CODIGO"	,cACH_COD,Nil})
		Aadd(aCamposACH, {"ACH_LOJA"	,"0001",Nil})
		//alert("ach "+StrZero(i,3))
		//MsExecAuto({|x,y|TMKA341(x,y)},aCamposACH,3)
		RecLock("ACH",.T.)

		ACH->ACH_CODIGO:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CODIGO"}))][2]
		ACH->ACH_LOJA:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_LOJA"}))][2]

		ACH->ACH_XMARCA:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XMARCA"}))][2]
		ACH->ACH_VEND:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_VEND"}))][2]
		ACH->ACH_RAZAO:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_RAZAO"}))][2]
		ACH->ACH_NFANT:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_NFANT"}))][2]
		ACH->ACH_XCONSE:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCONSE"}))][2]
		ACH->ACH_CODSEG:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CODSEG"}))][2]
		//ACH->ACH_DESSEG:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_DESSEG"}))][2]
		ACH->ACH_XCRM:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCRM"}))][2]
		ACH->ACH_XCRMUF:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCRMUF"}))][2]
		ACH->ACH_XESP01:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XESP01"}))][2]
		ACH->ACH_XESP02:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XESP02"}))][2]
		ACH->ACH_XESP03:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XESP03"}))][2]
		ACH->ACH_XNIVER:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XNIVER"}))][2]
		ACH->ACH_END:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_END"}))][2]
		ACH->ACH_XCOMPL:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCOMPL"}))][2]
		ACH->ACH_BAIRRO:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_BAIRRO"}))][2]
		ACH->ACH_CIDADE:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CIDADE"}))][2]
		ACH->ACH_EST:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_EST"}))][2]
		ACH->ACH_CEP:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CEP"}))][2]
		ACH->ACH_DDD:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_DDD"}))][2]
		ACH->ACH_TEL:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_TEL"}))][2]
		ACH->ACH_XFONE1:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XFONE1"}))][2]
		ACH->ACH_XCEL:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCEL"}))][2]
		ACH->ACH_XCEL2:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCEL2"}))][2]
		ACH->ACH_EMAIL:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_EMAIL"}))][2]
		ACH->ACH_XHOBBY:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XHOBBY"}))][2]
		ACH->ACH_XCLUBE:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCLUBE"}))][2]
		ACH->ACH_TIPO:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_TIPO"}))][2]
		ACH->ACH_PESSOA:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_PESSOA"}))][2]
		ACH->ACH_STATUS:="0"
		ACH->(MSUNLOCK())		
	Else
		//ATUALIZA ACH - MEDICOS
		Aadd(aCamposACH, {"ACH_CODIGO"	,ACH->ACH_CODIGO,Nil})
		Aadd(aCamposACH, {"ACH_LOJA"	,ACH->ACH_LOJA,Nil})
		//alert("ach UPDATE"+StrZero(i,3))
		//MsExecAuto({|x,y|TMKA341(x,y)},aCamposACH,4)				
		RecLock("ACH",.F.)

		//ACH->ACH_CODIGO:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CODIGO"}))][2]
		//ACH->ACH_LOJA:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_LOJA"}))][2]

		ACH->ACH_XMARCA:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XMARCA"}))][2]
		ACH->ACH_VEND:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_VEND"}))][2]
		ACH->ACH_RAZAO:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_RAZAO"}))][2]
		ACH->ACH_NFANT:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_NFANT"}))][2]
		ACH->ACH_XCONSE:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCONSE"}))][2]
		ACH->ACH_CODSEG:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CODSEG"}))][2]
//		ACH->ACH_DESSEG:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_DESSEG"}))][2]
		ACH->ACH_XCRM:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCRM"}))][2]
		ACH->ACH_XCRMUF:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCRMUF"}))][2]
		ACH->ACH_XESP01:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XESP01"}))][2]
		ACH->ACH_XESP02:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XESP02"}))][2]
		ACH->ACH_XESP03:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XESP03"}))][2]
		ACH->ACH_XNIVER:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XNIVER"}))][2]
		ACH->ACH_END:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_END"}))][2]
		ACH->ACH_XCOMPL:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCOMPL"}))][2]
		ACH->ACH_BAIRRO:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_BAIRRO"}))][2]
		ACH->ACH_CIDADE:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CIDADE"}))][2]
		ACH->ACH_EST:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_EST"}))][2]
		ACH->ACH_CEP:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CEP"}))][2]
		ACH->ACH_DDD:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_DDD"}))][2]
		ACH->ACH_TEL:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_TEL"}))][2]
		ACH->ACH_XFONE1:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XFONE1"}))][2]
		ACH->ACH_XCEL:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCEL"}))][2]
		ACH->ACH_XCEL2:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCEL2"}))][2]
		ACH->ACH_EMAIL:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_EMAIL"}))][2]
		ACH->ACH_XHOBBY:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XHOBBY"}))][2]
		ACH->ACH_XCLUBE:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_XCLUBE"}))][2]
		ACH->ACH_TIPO:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_TIPO"}))][2]
		ACH->ACH_PESSOA:=aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_PESSOA"}))][2]
		ACH->ACH_STATUS:="0"
		ACH->(MSUNLOCK())		

	Endif
		
	//cOcorrencia:=MostraErro()
	If lMsErroAuto 
		//Alert("Erro ao incluir Médico."+StrZero(i,3))
		//MostraErro()
		//cOcorrencias:="Erro Médico Linha "+StrZero(i,3)
    Endif

	lMsErroAuto:=.F.
	If lMsErroAuto 
		//Alert("Erro ao incluir Médico.")
		//MostraErro()
		//cOcorrencias:="Erro Médico Linha "+StrZero(i,3)
	Else
	   //If Existe no SU5 exclui SU5 e AC8 E AGA E AGB 
	   //lAtuMov:=.f.
	    DbSelectArea("SU5")
	    //DbOrderNickName("SU5CUS")
	    DBSetOrder(1)
	    lAtuMov:=.f.
   		cSU5_COD:=RetAchouCRM("SU5",aCamposSU5)
   		//If ACH->(DbSeek(cChavePesq))
   		if !empty(cSU5_COD)
   			if SU5->(DbSeek(xFilial('SU5')+cSU5_COD)) 
   				lAtuMov:=.t.
   			endif
   		Endif
	    ///if DbSeek(cChavePesq)	   
	   	//	lAtuMov:=.t.
	    ///Endif		
		Aadd(aCamposSU5, {"U5_FILIAL" ,xFilial("SU5"),Nil})

		// Inclusao Contato, telefone e endereço
		If !lAtuMov
			//Aadd(aCamposSU5, {"U5_CODCONT",GetSxeNum("SU5","U5_CODCONT","U5_CODCONT",1),Nil})
			cSU5_COD := RetPrxNr("SU5")
			Aadd(aCamposSU5, {"U5_CODCONT",cSU5_COD,Nil})
		Else
			Aadd(aCamposSU5, {"U5_CODCONT",SU5->U5_CODCONT,Nil})
		Endif
		
		aEndereco :={}
		aTelefone := {}
		aAuxDados := {}
		AAdd(aAuxDados, {'AGA_TIPO', '1', Nil})
		AAdd(aAuxDados, {'AGA_PADRAO', '1', Nil})
		AAdd(aAuxDados, {'AGA_END', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_END"}))][2], Nil})
		AAdd(aAuxDados, {'AGA_CEP', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CEP"}))][2], Nil})
		AAdd(aAuxDados, {'AGA_BAIRRO', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_BAIRRO"}))][2], Nil})
		AAdd(aAuxDados, {'AGA_MUNDES', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_MUN"}))][2], Nil})
		AAdd(aAuxDados, {'AGA_EST', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_EST"}))][2], Nil})	
		AAdd(aEndereco, aAuxDados)	
		aAuxDados := {}	
		AAdd(aAuxDados, {'AGB_TIPO', '1', Nil})
		AAdd(aAuxDados, {'AGB_PADRAO', '1', Nil})
		AAdd(aAuxDados, {'AGB_DDI', '55', Nil})
		AAdd(aAuxDados, {'AGB_DDD', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2], Nil})
		AAdd(aAuxDados, {'AGB_TELEFO', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FCOM1"}))][2], Nil})
		AAdd(aTelefone, aAuxDados)

		If !lAtuMov
//			MSExecAuto({|x,y,z,a,b|TMKA070(x,y,z,a,b)},aCamposSU5,3,aEndereco,aTelefone, .F.) 	
//			MSExecAuto({|x,y,z,a,b|TMKA070(x,y,z,a,b)},aCamposSU5,3,{},{}, .F.) 	
///Inclui Contato
			RecLock("SU5",.T.)
			SU5->U5_FILIAL	:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FILIAL"}))][2]
			SU5->U5_CODCONT	:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CODCONT"}))][2]
			SU5->U5_XMARCA:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XMARCA"}))][2]
			SU5->U5_XNMESTB:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XNMESTB"}))][2]
			SU5->U5_CONTAT:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CONTAT"}))][2]
			SU5->U5_XCONSE:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCONSE"}))][2]
			SU5->U5_XCRM:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCRM"}))][2]
			SU5->U5_XCRMUF:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCRMUF"}))][2]
			SU5->U5_XESP01:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XESP01"}))][2]
			SU5->U5_XESP02:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XESP02"}))][2]
			SU5->U5_XESP03:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XESP03"}))][2]
			SU5->U5_NIVER:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_NIVER"}))][2]
			SU5->U5_END:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_END"}))][2]
			SU5->U5_XCOMPL:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCOMPL"}))][2]
			SU5->U5_BAIRRO:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_BAIRRO"}))][2]
			SU5->U5_MUN:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_MUN"}))][2]
			SU5->U5_EST:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_EST"}))][2]
			SU5->U5_CEP:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CEP"}))][2]
			SU5->U5_DDD:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2]
			SU5->U5_FCOM1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FCOM1"}))][2]
			SU5->U5_DDD:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2]
			SU5->U5_FCOM2:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FCOM2"}))][2]
			SU5->U5_DDD:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2]
			SU5->U5_CELULAR:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CELULAR"}))][2]
			SU5->U5_XCEL2:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCEL2"}))][2]
			SU5->U5_EMAIL:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_EMAIL"}))][2]
			SU5->U5_XEMAIL2:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XEMAIL2"}))][2]
			SU5->U5_XNSECR1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XNSECR1"}))][2]
			SU5->U5_XDNSEC1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XDNSEC1"}))][2]
			SU5->U5_DDD:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2]
			SU5->U5_XCELSC1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCELSC1"}))][2]
			SU5->U5_XMAI1S1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XMAI1S1"}))][2]
			SU5->U5_XCONVEN:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCONVEN"}))][2]
			SU5->U5_XTPESTB:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XTPESTB"}))][2]
			SU5->U5_XHOSPIT:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XHOSPIT"}))][2]
			SU5->U5_XPDPRES:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XPDPRES"}))][2]
			SU5->U5_DIAVIS:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DIAVIS"}))][2]
			SU5->U5_HORAV1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_HORAV1"}))][2]
			SU5->U5_HORAV2:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_HORAV2"}))][2]
			SU5->U5_XOBSVIS:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XOBSVIS"}))][2]
			SU5->U5_DIALIG:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DIALIG"}))][2]
			SU5->U5_HORA1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_HORA1"}))][2]
			SU5->U5_HORA2:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_HORA2"}))][2]
			SU5->(MsUnlock())
			//alert("su5 "+StrZero(i,3))
			If lMsErroAuto 
				//Alert("Erro ao incluir Contato")
				//MostraErro()
				cOcorrencias:="Erro Contato Linha "+StrZero(i,3)
			Endif
		    lAtuMov:=.f.
   			cSU5_COD:=RetAchouCRM("SU5",aCamposSU5)
   			//If ACH->(DbSeek(cChavePesq))
   			if !empty(cSU5_COD)
   				if SU5->(DbSeek(xFilial('SU5')+cSU5_COD)) 
   					lAtuMov:=.t.
   				endif
   			Endif

            //// gravação do endereço e telefone
            if lAtuMov
				RecLock("AGA",.T.)
 				AGA->AGA_FILIAL:=xFilial("AGA")
				AGA->AGA_CODIGO:=RetPrxNr("AGA")
				AGA->AGA_ENTIDA:="SU5"
				AGA->AGA_CODENT:=cSU5_COD
    
				AGA->AGA_TIPO:='1'
				AGA->AGA_PADRAO:='1'
				AGA->AGA_END:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_END"}))][2]
				AGA->AGA_CEP:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CEP"}))][2]
				AGA->AGA_BAIRRO:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_BAIRRO"}))][2]
				AGA->AGA_MUNDES:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_MUN"}))][2]
				AGA->AGA_EST:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_EST"}))][2]	
				AGA->(MsUnlock())
				
 				RecLock("AGB",.T.)
 				AGB->AGB_FILIAL:=xFilial("AGB")
				AGB->AGB_CODIGO:=RetPrxNr("AGB")
				AGB->AGB_ENTIDA:="SU5"
				AGB->AGB_CODENT:=cSU5_COD

				AGB->AGB_TIPO:='1'
				AGB->AGB_PADRAO:='1'
				AGB->AGB_DDI:='55'
				AGB->AGB_DDD:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2]
				AGB->AGB_TELEFO:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FCOM1"}))][2]
            	AGB->(MsUnlock())
    		ENDIF
            
		Else
			RecLock("SU5",.f.)
 //			SU5->U5_FILIAL	:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FILIAL"}))][2]
 //			SU5->U5_CODCONT	:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CODCONT"}))][2]
			SU5->U5_XMARCA:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XMARCA"}))][2]
			SU5->U5_XNMESTB:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XNMESTB"}))][2]
			SU5->U5_CONTAT:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CONTAT"}))][2]
			SU5->U5_XCONSE:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCONSE"}))][2]
			SU5->U5_XCRM:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCRM"}))][2]
			SU5->U5_XCRMUF:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCRMUF"}))][2]
			SU5->U5_XESP01:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XESP01"}))][2]
			SU5->U5_XESP02:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XESP02"}))][2]
			SU5->U5_XESP03:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XESP03"}))][2]
			SU5->U5_NIVER:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_NIVER"}))][2]
			SU5->U5_END:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_END"}))][2]
			SU5->U5_XCOMPL:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCOMPL"}))][2]
			SU5->U5_BAIRRO:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_BAIRRO"}))][2]
			SU5->U5_MUN:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_MUN"}))][2]
			SU5->U5_EST:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_EST"}))][2]
			SU5->U5_CEP:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CEP"}))][2]
			SU5->U5_DDD:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2]
			SU5->U5_FCOM1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FCOM1"}))][2]
			SU5->U5_DDD:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2]
			SU5->U5_FCOM2:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FCOM2"}))][2]
			SU5->U5_DDD:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2]
			SU5->U5_CELULAR:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CELULAR"}))][2]
			SU5->U5_XCEL2:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCEL2"}))][2]
			SU5->U5_EMAIL:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_EMAIL"}))][2]
			SU5->U5_XEMAIL2:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XEMAIL2"}))][2]
			SU5->U5_XNSECR1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XNSECR1"}))][2]
			SU5->U5_XDNSEC1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XDNSEC1"}))][2]
			SU5->U5_DDD:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2]
			SU5->U5_XCELSC1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCELSC1"}))][2]
			SU5->U5_XMAI1S1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XMAI1S1"}))][2]
			SU5->U5_XCONVEN:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XCONVEN"}))][2]
			SU5->U5_XTPESTB:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XTPESTB"}))][2]
			SU5->U5_XHOSPIT:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XHOSPIT"}))][2]
			SU5->U5_XPDPRES:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XPDPRES"}))][2]
			SU5->U5_DIAVIS:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DIAVIS"}))][2]
			SU5->U5_HORAV1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_HORAV1"}))][2]
			SU5->U5_HORAV2:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_HORAV2"}))][2]
			SU5->U5_XOBSVIS:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_XOBSVIS"}))][2]
			SU5->U5_DIALIG:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DIALIG"}))][2]
			SU5->U5_HORA1:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_HORA1"}))][2]
			SU5->U5_HORA2:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_HORA2"}))][2]
			SU5->(MsUnlock())

		 	DbSelectArea("AGA")
	   		DbSetOrder(1)
 		    IF AGA->(DbSeek(xFilial("AGA")+"SU5"+PADR(SU5->U5_CODCONT,25)+'1'))
			aEndereco :={}
			Do While ! AGA->(EOF()) .And. Alltrim(AGA->AGA_CODENT) == SU5->U5_CODCONT .AND. Alltrim(AGA->AGA_TIPO)='1'
	//			aAuxDados := {}
	//			AAdd(aAuxDados, {'AGA_FILIAL', AGA->AGA_FILIAL, Nil})
	//			AAdd(aAuxDados, {'AGA_ENTIDA', AGA->AGA_ENTIDA, Nil})
	//			AAdd(aAuxDados, {'AGA_CODENT', AGA->AGA_CODENT, Nil})
	//			AAdd(aAuxDados, {'AGA_TIPO', '1', Nil})
	//			AAdd(aAuxDados, {'AGA_PADRAO', '1', Nil})
	//			AAdd(aAuxDados, {'AGA_END', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_END"}))][2], Nil})
	//			AAdd(aAuxDados, {'AGA_CEP', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CEP"}))][2], Nil})
	//			AAdd(aAuxDados, {'AGA_BAIRRO', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_BAIRRO"}))][2], Nil})
	//			AAdd(aAuxDados, {'AGA_MUNDES', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_MUN"}))][2], Nil})
//				AAdd(aAuxDados, {'AGA_EST', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_EST"}))][2], Nil})	
//				AAdd(aEndereco, aAuxDados)	
				RecLock("AGA", .F.)
				AGA->(dbDelete())
				AGA->(MsUnLock())	
				AGA->(dbSkip())
			Enddo
			ENDIF
				RecLock("AGA",.T.)
 				AGA->AGA_FILIAL:=xFilial("AGA")
				AGA->AGA_CODIGO:=RetPrxNr("AGA")
				AGA->AGA_ENTIDA:="SU5"
				AGA->AGA_CODENT:=SU5->U5_CODCONT
    
				AGA->AGA_TIPO:='1'
				AGA->AGA_PADRAO:='1'
				AGA->AGA_END:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_END"}))][2]
				AGA->AGA_CEP:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CEP"}))][2]
				AGA->AGA_BAIRRO:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_BAIRRO"}))][2]
				AGA->AGA_MUNDES:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_MUN"}))][2]
				AGA->AGA_EST:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_EST"}))][2]	
				AGA->(MsUnlock())
				
            //ENDIF
		 	DbSelectArea("AGB")
	   		DbSetOrder(1)
 		    IF AGB->(DbSeek(xFilial("AGB")+"SU5"+PADR(SU5->U5_CODCONT,25)+'1'))
			aTelefone := {}
			Do While !AGB->(EOF()) .And. Alltrim(AGB->AGB_CODENT) == SU5->U5_CODCONT .AND. Alltrim(AGB->AGB_TIPO)='1'
				aAuxDados := {}	
//				AAdd(aAuxDados, {'AGB_FILIAL', AGB->AGB_FILIAL, Nil})
//				AAdd(aAuxDados, {'AGB_ENTIDA', AGB->AGB_ENTIDA, Nil})
//				AAdd(aAuxDados, {'AGB_CODENT', AGB->AGB_CODENT, Nil})
//				AAdd(aAuxDados, {'AGB_TIPO', '1', Nil})
//				AAdd(aAuxDados, {'AGB_PADRAO', '1', Nil})
//				AAdd(aAuxDados, {'AGB_DDI', '55', Nil})
//				AAdd(aAuxDados, {'AGB_DDD', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2], Nil})
//				AAdd(aAuxDados, {'AGB_TELEFO', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FCOM1"}))][2], Nil})
//				AAdd(aTelefone, aAuxDados)
				RecLock("AGB", .F.)
				AGB->(dbDelete())
				AGB->(MsUnLock())	
				AGB->(dbSkip())
			Enddo
			ENDIF
 				RecLock("AGB",.T.)
 				AGB->AGB_FILIAL:=xFilial("AGB")
				AGB->AGB_CODIGO:=RetPrxNr("AGB")
				AGB->AGB_ENTIDA:="SU5"
				AGB->AGB_CODENT:=SU5->U5_CODCONT

				AGB->AGB_TIPO:='1'
				AGB->AGB_PADRAO:='1'
				AGB->AGB_DDI:='55'
				AGB->AGB_DDD:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2]
				AGB->AGB_TELEFO:=aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FCOM1"}))][2]
            	AGB->(MsUnlock())
			
			//ENDIF
			//MSExecAuto({|x,y,z,a,b|TMKA070(x,y,z,a,b)},aCamposSU5,4,aEndereco,aTelefone, .F.)
			//alert("su5 update"+StrZero(i,3))	 					
		Endif	
		//cOcorrencia:=MostraErro()
		If lMsErroAuto .And. Len(cOcorrencia) == 0
			lMsErroAuto:=.F.
		Endif

		If lMsErroAuto
//			cOcorrencia:=MostraErro()
//			Alert("Erro ao incluir/Alterar Contato.")
//			MostraErro()
			cOcorrencias =+"Contato Linha "+StrZero(i,3)
		endif
		lMsErroAuto:=.F.

//		If lMsErroAuto
//			Alert("Erro ao incluir/Alterar Contato.")
//			MostraErro()
//			cOcorrencias =+"Contato Linha "+StrZero(i,3)
//		Else
		    //DbSelectArea("SU5")
		    //DbOrderNickName("SU5CUS")
		    //lAtuMov:=.f.
		    //if SU5->(DbSeek(cChavePesq))	   
		   	//	lAtuMov:=.t.
	    	///Endif		
		    //lAtuMov:=.f.
   			cACH_COD:=RetAchouCRM("ACH",aCamposACH)
   			cSU5_COD:=RetAchouCRM("SU5",aCamposSU5)
   			//If ACH->(DbSeek(cChavePesq))
   			//if !empty(cACH_SU5)
   			//	if SU5->(DbSeek(cSU5_COD)) 
   			//		lAtuMov:=.t.
   			//	endif
   			//Endif

  
			If !EMPTY(cACH_COD) .AND. !EMPTY(cSU5_COD) 

				// Inclusao Contato x Entidade VERIFICAR SE J[A NAO EXISTE REGISTRO EM DUPLICIDDE
				Aadd(aCamposAC8, {"AC8_CODENT" 	,aCamposACH[2][2]+"0001" ,Nil})
				Aadd(aCamposAC8, {"AC8_CODCON" 	,aCamposSU5[2][2] ,Nil})
				Aadd(aCamposAC8, {"AC8_FILIAL" 	,xFilial("AC8"),Nil})

				cChavAC8:=xFilial("AC8")+PADR(aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CODCONT"}))][2],6)+"ACH"+xFilial("ACH")+PADR(aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CODIGO"}))][2],8) + "0001"
				dbSelectArea("AC8")
				dbSetOrder(1)
				If !DbSeek(cChavAC8)
					RecLock("AC8",.T.)
					AC8->AC8_FILIAL	:=	xFilial("AC8")
					AC8->AC8_FILENT	:=	xFilial("ACH")
					AC8->AC8_ENTIDA	:=	"ACH"
					AC8->AC8_CODENT	:=	aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CODIGO"}))][2] + "0001"
					AC8->AC8_CODCON	:=	aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CODCONT"}))][2]
					MsUnlock()
				Endif
						//alert("ac8 "+StrZero(i,3))	 					
			else
						//alert("ac8 update "+StrZero(i,3))	 					
		
			Endif	

			
 //		Endif
	EndIf
	DbCommitAll()
Next i
DbCommitAll()
FT_FUSE()
If Len(Alltrim(cOcorrencias)) == 0
	ApMsgInfo("Importação dos ACH, U5 E ACH8 concluídas com sucesso!","[ALIMPEXEC] - SUCESSO")
Else
	Alert(cOcorrencias)
Endif
Return


//-------------------------------------------------------------------
/*{Protheus.doc} AbrirArq
Abrir Arquivo

@author Itamar Gama.:
@since  23/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function AbrirArq()

Local cSvAlias		:= Alias()
Local lAchou		:= .F.
Local cTipo			:= '*.*'												
Local cNewPathArq	:= cGetFile('Arquivo *|*.CSV|Arquivo CS|*.CSV','Selecione arquivo',0,'C:\',.T.,,.F.)
MV_PAR01:=cNewPathArq
MV_PAR02:=''
Return .T.

Static Function RetArq()
AXITA:=0
Return(MV_PAR01)

Static Function RetValid()
AXITA:=0
Return .t.

Static function RetPrxNr(cQAlias)
Local cRet := ""
Local cQry := ""
Local aArea := GetArea() // Preserva a área (tabela) no início da chamada
Local nTam:=0

If Select("TRB") > 0 
	Dbselectarea("TRB") 
	TRB->(DbClosearea()) 
EndIf 

IF cQAlias="ACH"
	cQry := "SELECT MAX (ACH_CODIGO) AS COD FROM ACH010 WHERE D_E_L_E_T_ = ' '"
	nTam:=TAMSX3("ACH_CODIGO")[1]
ELSEIF cQAlias="SU5"
	cQry := "SELECT MAX (U5_CODCONT) AS COD FROM SU5010 WHERE D_E_L_E_T_ = ' '"
	nTam:=TAMSX3("U5_CODCONT")[1]
ELSEIF cQAlias="AGA"
	cQry := "SELECT MAX (AGA_CODIGO) AS COD FROM AGA010 WHERE D_E_L_E_T_ = ' '"
	nTam:=TAMSX3("AGA_CODIGO")[1]
ELSEIF cQAlias="AGB"
	cQry := "SELECT MAX (AGB_CODIGO) AS COD FROM AGB010 WHERE D_E_L_E_T_ = ' '"
	nTam:=TAMSX3("AGB_CODIGO")[1]
ENDIF
//TcQuery cQry new alias "T03"
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB",.T.,.T.) 
TRB->(DBSELECTAREA("TRB")) 
TRB->(DBGOTOP()) 
cRet:=""
IF (!TRB->(Eof()))
	if !empty(alltrim(TRB->COD))
		cRet := strzero(val(TRB->COD)+1,nTam)
	else
		cRet:=""
	endif
ELSE
	cRet:=""	
ENDIF 
TRB->(DbCloseArea()) // fecha a consulta

RestArea(aArea) // Restaura area (alias) identificado no início

Return(cRet) // retorna o próximo número

//
   
Static function RetAChouCRM(cQAlias,aCampos)
Local aArea := GetArea() // Preserva a área (tabela) no início da chamada
Local cRet := ""
Local cQry := ""
Local nTam:=0
Local cXCONSE,cxCRM,cXCRMUF,cXMARCA:=""

If Select("TRB") > 0 
	Dbselectarea("TRB") 
	TRB->(DbClosearea()) 
EndIf 

IF cQAlias="ACH"
   	cXCONSE:=aCampos[(AScan(aCampos, {|x| AllTrim(x[1]) == "ACH_XCONSE"}))][2]
   	cXCRM:=aCampos[(AScan(aCampos, {|x| AllTrim(x[1]) == "ACH_XCRM"}))][2]
   	cXCRMUF:=aCampos[(AScan(aCampos, {|x| AllTrim(x[1]) == "ACH_XCRMUF"}))][2]
   	cXMARCA:=aCampos[(AScan(aCampos, {|x| AllTrim(x[1]) == "ACH_XMARCA"}))][2]

	cQry := "SELECT MAX (ACH_CODIGO) AS COD FROM ACH010 WHERE ACH_XCONSE='"+cXCONSE+"' AND ACH_XCRM='"+cXCRM+"' AND ACH_XCRMUF='"+cXCRMUF
	cQry +="' AND ACH_XMARCA='"+cXMARCA+"' AND D_E_L_E_T_ = ' ' "
ELSEIF cQAlias="SU5"
   	cXCONSE:=aCampos[(AScan(aCampos, {|x| AllTrim(x[1]) == "U5_XCONSE"}))][2]
   	cXCRM:=aCampos[(AScan(aCampos, {|x| AllTrim(x[1]) == "U5_XCRM"}))][2]
   	cXCRMUF:=aCampos[(AScan(aCampos, {|x| AllTrim(x[1]) == "U5_XCRMUF"}))][2]
   	cXMARCA:=aCampos[(AScan(aCampos, {|x| AllTrim(x[1]) == "U5_XMARCA"}))][2]
	cQry := "SELECT MAX (U5_CODCONT) AS COD FROM SU5010 WHERE U5_XCONSE='"+cXCONSE+"' AND U5_XCRM='"+cXCRM+"' AND U5_XCRMUF='"+cXCRMUF
	cQry +="' AND U5_XMARCA='"+cXMARCA+"' AND D_E_L_E_T_ = ' ' "
ENDIF
//TcQuery cQry new alias "T03"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB",.T.,.T.) 
TRB->(DBSELECTAREA("TRB")) 
TRB->(DBGOTOP()) 
cRet:=""
IF (!TRB->(Eof()))
	if !empty(alltrim(TRB->COD))
		cRet := TRB->COD
	else
		cRet:=""
	endif
ELSE
	cRet:=""	
ENDIF 
TRB->(DbCloseArea()) // fecha a consulta

RestArea(aArea) // Restaura area (alias) identificado no início

Return(cRet) // retorna o próximo número


