#include "totvs.ch"
#INCLUDE "PROTHEUS.CH"                                
#INCLUDE "DBSTRUCT.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALIMPEXEC
Importação de arquivos 

@author Itamar Gama.:
@since  23/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALIMPEXEC()
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

AADD(aButtons, { 1,.T.,{|o| u_ALProcImp(),o:oWnd:End()}} )
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

User Function ALProcImp()
     
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
	
For i:=nPosCpoCAB+1 to Len(aDados)
	
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
    cDescSeg:=Alltrim(aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_DESSEG"}))][2])
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
   	cChavePesq+=PADR(Alltrim(aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CEP"}))][2]),6)
   	DbSelectArea("ACH")
   	DbOrderNickName("ACHDUPL")
   	lAtuMov:=.f.
   	If DbSeek(cChavePesq)	   
   		lAtuMov:=.t.
   	Endif
	lMsErroAuto:=.F.
	//Begin Transaction
	
	// Inclusao Médicos
   	Aadd(aCamposACH, {"ACH_FILIAL" 	,xFilial("ACH"),Nil})  
	//if primero se sim rola
    If !lAtuMov
    	//Cria ACH - MEDICOS
   		DbSelectArea("ACH")
    	DbSetOrder(1)
    	cACH_COD := GetSxeNum("ACH","ACH_CODIGO","ACH_CODIGO",1)
		Do While DbSeek(cACH_COD)	
			cACH_COD := GetSxeNum("ACH","ACH_CODIGO","ACH_CODIGO",1)
		Enddo    
		Aadd(aCamposACH, {"ACH_CODIGO"	,cACH_COD,Nil})
		Aadd(aCamposACH, {"ACH_LOJA"	,"01",Nil})
	
		MsExecAuto({|x,y|TMKA341(x,y)},aCamposACH,3)
	Else
		//ATUALIZA ACH - MEDICOS
		Aadd(aCamposACH, {"ACH_CODIGO"	,ACH_CODIGO,Nil})
		Aadd(aCamposACH, {"ACH_LOJA"	,ACH->ACH_LOJA,Nil})
		MsExecAuto({|x,y|TMKA341(x,y)},aCamposACH,4)				
	Endif
		
//	cOcorrencia:=MostraErro()
	If lMsErroAuto 
//		Alert("Erro ao incluir Médico.")
//		MostraErro()
		cOcorrencias:="Erro Médico Linha "+StrZero(i,3)
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
	    DbOrderNickName("SU5CUS")
	    lAtuMov:=.f.
	    if DbSeek(cChavePesq)	   
	   		lAtuMov:=.t.
	    Endif		
		Aadd(aCamposSU5, {"U5_FILIAL" ,xFilial("SU5"),Nil})

		// Inclusao Contato, telefone e endereço
		If !lAtuMov
			Aadd(aCamposSU5, {"U5_CODCONT",GetSxeNum("SU5","U5_CODCONT","U5_CODCONT",1),Nil})
		Else
			Aadd(aCamposSU5, {"U5_CODCONT",SU5->U5_CODCONT,Nil})
		Endif
		
		aEndereco :={}
		aAuxDados := {}
		AAdd(aAuxDados, {'AGA_TIPO', '1', Nil})
		AAdd(aAuxDados, {'AGA_PADRAO', '1', Nil})
		AAdd(aAuxDados, {'AGA_END', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_END"}))][2], Nil})
		AAdd(aAuxDados, {'AGA_CEP', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CEP"}))][2], Nil})
		AAdd(aAuxDados, {'AGA_BAIRRO', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_BAIRRO"}))][2], Nil})
		AAdd(aAuxDados, {'AGA_MUNDES', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_MUN"}))][2], Nil})
		AAdd(aAuxDados, {'AGA_EST', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_EST"}))][2], Nil})	
		AAdd(aEndereco, aAuxDados)	

		If !lAtuMov
			MSExecAuto({|x,y,z,a,b|TMKA070(x,y,z,a,b)},aCamposSU5,3,aEndereco,aTelefone, .F.) 	
			If lMsErroAuto 
//				Alert("Erro ao incluir Contato")
//				MostraErro()
				cOcorrencias:="Erro Contato Linha "+StrZero(i,3)
			Endif
		Else
		 	DbSelectArea("AGA")
	   		DbSetOrder(1)
 		    DbSeek(xFilial("AGA")+"SU5"+SU5->U5_CODCONT)
			aEndereco :={}
			Do While ! AGA->(EOF()) .And. Alltrim(AGA->AGA_CODENT) == SU5->U5_CODCONT
				aAuxDados := {}
				AAdd(aAuxDados, {'AGA_FILIAL', AGA->AGA_FILIAL, Nil})
				AAdd(aAuxDados, {'AGA_ENTIDA', AGA->AGA_ENTIDA, Nil})
				AAdd(aAuxDados, {'AGA_CODENT', AGA->AGA_CODENT, Nil})
				AAdd(aAuxDados, {'AGA_TIPO', '1', Nil})
				AAdd(aAuxDados, {'AGA_PADRAO', '1', Nil})
				AAdd(aAuxDados, {'AGA_END', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_END"}))][2], Nil})
				AAdd(aAuxDados, {'AGA_CEP', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CEP"}))][2], Nil})
				AAdd(aAuxDados, {'AGA_BAIRRO', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_BAIRRO"}))][2], Nil})
				AAdd(aAuxDados, {'AGA_MUNDES', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_MUN"}))][2], Nil})
				AAdd(aAuxDados, {'AGA_EST', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_EST"}))][2], Nil})	
				AAdd(aEndereco, aAuxDados)	
				RecLock("AGA", .F.)
				AGA->(dbDelete())
				MsUnLock()	
				AGA->(dbSkip())
			Enddo

		 	DbSelectArea("AGB")
	   		DbSetOrder(1)
 		    DbSeek(xFilial("AGB")+"SU5"+SU5->U5_CODCONT)
			aTelefone := {}
			Do While !AGB->(EOF()) .And. Alltrim(AGB->AGB_CODENT) == SU5->U5_CODCONT
				aAuxDados := {}	
				AAdd(aAuxDados, {'AGB_FILIAL', AGB->AGB_FILIAL, Nil})
				AAdd(aAuxDados, {'AGB_ENTIDA', AGB->AGB_ENTIDA, Nil})
				AAdd(aAuxDados, {'AGB_CODENT', AGB->AGB_CODENT, Nil})
				AAdd(aAuxDados, {'AGB_TIPO', '1', Nil})
				AAdd(aAuxDados, {'AGB_PADRAO', '1', Nil})
				AAdd(aAuxDados, {'AGB_DDI', '55', Nil})
				AAdd(aAuxDados, {'AGB_DDD', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_DDD"}))][2], Nil})
				AAdd(aAuxDados, {'AGB_TELEFO', aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_FCOM1"}))][2], Nil})
				AAdd(aTelefone, aAuxDados)
				RecLock("AGB", .F.)
				AGB->(dbDelete())
				MsUnLock()	
				AGB->(dbSkip())
			Enddo
			MSExecAuto({|x,y,z,a,b|TMKA070(x,y,z,a,b)},aCamposSU5,4,aEndereco,aTelefone, .F.)
			 					
		Endif	
		cOcorrencia:=MostraErro()
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
		    DbSelectArea("SU5")
		    DbOrderNickName("SU5CUS")
		    lAtuMov:=.f.
		    if DbSeek(cChavePesq)	   
		   		lAtuMov:=.t.
	    	Endif		
			If lAtuMov

				// Inclusao Contato x Entidade VERIFICAR SE J[A NAO EXISTE REGISTRO EM DUPLICIDDE
				Aadd(aCamposAC8, {"AC8_CODENT" 	,aCamposACH[2][2]+"01" ,Nil})
				Aadd(aCamposAC8, {"AC8_CODCON" 	,aCamposSU5[2][2] ,Nil})
				Aadd(aCamposAC8, {"AC8_FILIAL" 	,xFilial("AC8"),Nil})

				cChavAC8:=xFilial("AC8")+PADR(aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CODCONT"}))][2],6)+"ACH"+xFilial("ACH")+PADR(aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CODIGO"}))][2],8) + "01"
				dbSelectArea("AC8")
				dbSetOrder(1)
				If !DbSeek(cChavAC8)
					RecLock("AC8",.T.)
					AC8->AC8_FILIAL	:=	xFilial("AC8")
					AC8->AC8_FILENT	:=	xFilial("ACH")
					AC8->AC8_ENTIDA	:=	"ACH"
					AC8->AC8_CODENT	:=	aCamposACH[(AScan(aCamposACH, {|x| AllTrim(x[1]) == "ACH_CODIGO"}))][2] + "01"
					AC8->AC8_CODCON	:=	aCamposSU5[(AScan(aCamposSU5, {|x| AllTrim(x[1]) == "U5_CODCONT"}))][2]
					MsUnlock()
				Endif	
			Endif	
 //		Endif
	EndIf
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
User Function AbrirArq()

Local cSvAlias		:= Alias()
Local lAchou		:= .F.
Local cTipo			:= '*.*'												
Local cNewPathArq	:= cGetFile('Arquivo *|*.CSV|Arquivo CS|*.CSV','Selecione arquivo',0,'C:\',.T.,,.F.)
MV_PAR01:=cNewPathArq
MV_PAR02:=''
Return .T.

User Function RetArq()
AXITA:=0
Return(MV_PAR01)

User Function RetValid()
AXITA:=0
Return .t.

