#include "totvs.ch"
#INCLUDE "PROTHEUS.CH"                                
#INCLUDE "DBSTRUCT.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALTMKM02
Importa��o de arquivos excel segmentos

@author Itamar Gama.:
@since  16/03/2017
@version P12
*/
//-------------------------------------------------------------------
User Function ALTMKM02()
Local cTitulo	:=	"IMPORTA��O ARQUIVOS EXCEL - SEGMENTOS"
Local cText1	:=	"Rotina espec�fica para importa��o de dados via Arquivo Excel (.CSV )que ser�o
Local cText2	:=	"incrementados na tabela de segmentos "

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

AADD(aButtons, { 1,.T.,{|o| U_ALTMKSG(),o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
FormBatch( cTitulo, aSays, aButtons )

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} ALTMKSG

@author Itamar Gama.:
@since  16/03/2017
@version P12
*/
//-------------------------------------------------------------------

User Function ALTMKSG()
     
Local cArq    		:= MV_PAR01
Local cLinha  		:= ""
Local lPrim   		:= .T.
Local aCampos 		:= {}
Local aDados 	 	:= {}
Local aCamposAOV 	:= {}
Local aAuxDados		:= {}
Local i				:= 0 
Private aErro 		:= {}
Private lMsErroAuto := .F.

If !File(cArq)
   	MsgStop("O arquivo " +cArq + " n�o foi encontrado. A importa��o ser� abortada!","[ALTMKSG] - ATENCAO")
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

ProcRegua(Len(aDados))
aCamposAOV :={}
For i:=1 to Len(aDados)
	dbSelectArea("AOV")
	dbSetOrder(2)
	If !DbSeek(xFilial("AOV")+(Alltrim(aDados[i][4])))
		dbSetOrder(1)
		cAOV_CODSEG	:= GetSxeNum("AOV","AOV_CODSEG","AOV_CODSEG",1)
		Do While DbSeek(xFilial("AOV")+cAOV_CODSEG)
			cAOV_CODSEG	:= GetSxeNum("AOV","AOV_CODSEG","AOV_CODSEG",1)
		Enddo
		dbSetOrder(2)	
		RecLock("AOV",.T.)
		AOV->AOV_FILIAL	:= xFilial("AOV")
		AOV->AOV_CODSEG	:= cAOV_CODSEG
		AOV->AOV_DESSEG	:= Alltrim(aDados[i][4])	
		MsUnlock()
	Endif
    DbSelectArea("ACH")
    DbOrderNickName("ACHDUPL")
	cChavePesq := xFilial("ACH")+PADR(Alltrim(aDados[i][1]),10)+PADR(Alltrim(aDados[i][2]),6)+PADR(Alltrim(aDados[i][3]),2)
	If DbSeek(cChavePesq)	   
   		RecLock("ACH",.F.)
		ACH->ACH_CODSEG	:= AOV->AOV_CODSEG
		MsUnlock()
	Else
		Alert("Registro Chave "+Alltrim(aDados[i][1])+" "+Alltrim(aDados[i][2])+" "+Alltrim(aDados[i][3])+" n�o encontrado")
   	Endif	
Next i
FT_FUSE()
ApMsgInfo("Importa��o dos Segmentos conclu�da com sucesso!","[ALMKM02] - SUCESSO")
Return
