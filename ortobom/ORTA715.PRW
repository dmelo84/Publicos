#Include "Totvs.ch"
#include "protheus.ch"
#INCLUDE 'TBICONN.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ORTA715 ºAutor  ³ ADRIANO DOURADO    º Data ³   03/10/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  TELA PARA IMPRESSÃO E MANUTENÇÃO DAS PROPOSTAS COMERCIAIS º±±
±±º          ³  E INDUSTRIAIS.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³  AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±			 ³															   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

************************
User Function ORTA715()
************************


Local aArea  		:= GetArea()
Private _cUsu 	  	:= RetCodUsr()
Private cFimLn 		:= Chr(13)+Chr(10)
Private cImage		:= "logorto3.jpg"
Private oDlg, oPrazoDe, oPrazoAte
Private oFont1,oFont1B
Private dPrazoDe	:= CtoD(Space(8))
Private dPrazoAte	:= CtoD(Space(8))
Private lDoc		:= .F.
Private lPed		:= .F.
Private lAltera		:= .F.
Private cProdSeg	:= ""
Private nSegmen		:= 0
Private cCodProj	:= ""
Private aDados		:= {} //{"","","","",0,0,0,0,0,0,0,0,0,0,0,0}
Private aTemp 		:= {}
Private nX			:= 0
 
//PREPARE ENVIRONMENT EMPRESA "15" FILIAL "02"

DEFINE MSDIALOG oDlg TITLE "Proposta Comercial e Industrial" FROM 0,0 TO 270,405 PIXEL

@ 012,020 Say "Confecção e Manutenção de Propostas Comerciais e Industriais." Size 200,8 Font oFont1B Pixel

@ 27,010 To 090,190 Pixel

@ 036,020 Button OemToAnsi("Comercial" )		Size 040,014	Action fOrtrPro(1)	Pixel of oDlg
@ 036,080 Button OemToAnsi("Comer. VPC")		Size 040,014	Action fOrtrPro(2)	Pixel of oDlg
@ 036,140 Button OemToAnsi("Industrial")		Size 040,014	Action fOrtrPro(3)	Pixel of oDlg

@ 066,020 Button OemToAnsi("Potencial Cliente")	Size 040,014	Action u_ortr787()	Pixel of oDlg
@ 066,080 Button OemToAnsi("Reimpressão")		Size 040,014	Action fReimp()		Pixel of oDlg
@ 066,140 Button OemToAnsi("Excluir Prop.")		Size 040,014	Action fExcluir()	Pixel of oDlg

@ 100,150 Button OemToAnsi("Sair")				Size 030,014	Action oDlg:End()	Pixel of oDlg


ACTIVATE MSDIALOG oDlg CENTERED

RestArea(aArea)

Return


******************************
Static Function fOrtrPro(nOp)
******************************

Local aVetor   := {}
Local oDlg     := Nil
Local oOk      := LoadBitmap( GetResources(), "LBOK" )
Local oNo      := LoadBitmap( GetResources(), "LBNO" )
Local _lRetCont:= .f.
Local _cQuery  := " "
Local cTitulo  := ""
Local dDtde    := Date()
Local dDtate   := Date()

Private cCodGru	 := " "
Private oFont1,oFont1B
Private oLbx     := Nil
Private aVetPed  := { }
Private aRotina  := {{"","AllWaysTrue",0,1}, {"","AllWaysTrue",0,2}, {"","AllWaysTrue",0,3}, {"","AllWaysTrue",0,4}}
Private aRet	 := {}
Private aPergs	 := {}

If nOp == 1
	cTitulo  := "Proposta Comercial"
Elseif nOp == 2
	cTitulo  := "Proposta Comercial com VPC"
Else	
	cTitulo  := "Proposta Industrial"
Endif	

Define Font oFont Name "Arial" Size 0,-12 Bold

aAdd( aPergs ,{9,"Parâmetros para seleção de pedidos.",200,,,.T.})
aAdd( aPergs ,{1,"Cliente/Grupo",Space(20),,,"SA1",,50,.T.})
aAdd( aPergs ,{1,"Data Digitação de",dDtde,"@d",'',"",'.T.',40,.F.})
aAdd( aPergs ,{1,"Data Digitação até",dDtate,"@d",'',"",'.T.',40,.F.})
aAdd( aPergs ,{1,"Pedido de" 	,Space(20),,,"SC5",,50,.F.})
aAdd( aPergs ,{1,"Pedido até"	,Space(20),,,"SC5",,50,.F.})

If !Parambox ( aPergs, cTitulo, aRet, /*bOk*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,"ORTR727"/*cLoad*/,.T./*lCanSave*/,/*lUserSave*/)
	Return
EndIf

DbSelectArea("SA1")
DbSetOrder(1)
DBSeek(xFilial("SA1")+Alltrim(MV_PAR02))
cCodGru	:= SA1->A1_XCODGRU

_cQuery := "SELECT C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_XTPSEGM, C5_XOPER, C5_XTPPGT, "
_cQuery += "       C5_CONDPAG, C5_XPRZMED, C5_EMISSAO,  C5_XEMBARQ, C5_VEND1, C5_XNICHO "
_cQuery += "   FROM "+RetSQLName("SC5")+" SC5 "
_cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
_cQuery += "   AND SC5.D_E_L_E_T_ = ' ' "
_cQuery += "   AND C5_CLIENTE IN (SELECT A1_COD FROM "+RetSQLName("SA1")+" SA1 WHERE A1_XCODGRU = '"+cCodGru+"') "
_cQuery += "   AND C5_XEMBARQ = ' ' "
_cQuery += "   AND C5_NOTA 	  = ' ' "
_cQuery += "   AND C5_XPRONUM =  0	"
_cQuery += "   AND C5_XOPER	 <> '99'"
If !(Empty(MV_PAR03)) .OR. !(Empty(MV_PAR04))
_cQuery	+= " AND C5_EMISSAO BETWEEN '"+DtoS(MV_PAR03)+"' AND '"+DtoS(MV_PAR04)+"' "
Endif
If !(Empty(MV_PAR05)) .OR. !(Empty(MV_PAR06))
	_cQuery	+= " AND C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
Endif
_cQuery += "ORDER BY C5_EMISSAO DESC, C5_NUM DESC, C5_XOPER  "

Memowrite("c:\qry\727ped.sql",_cQuery)

If Select("PED") > 0
	PED->(DbCloseArea())
Endif
TcQuery _cQuery Alias "PED" New
DbSelectArea("PED")
PED->(DbGoTop())

If PED->(EOF())
	Alert("Nenhum pedido localizado com os parâmetros informados!") 
	_lRetCont:= .F.
Else
	_lRetCont:= .T.

	Do While PED->(!EOF())
	
	aAdd( aVetPed ,{ .F., PED->C5_NUM, PED->C5_CLIENTE, PED->C5_LOJACLI, PED->C5_XTPSEGM, PED->C5_XOPER, PED->C5_XTPPGT, ;
	PED->C5_CONDPAG, PED->C5_XPRZMED, PED->C5_EMISSAO, PED->C5_VEND1, PED->C5_XNICHO})
	PED->(DbSkip())
	
	End Do
Endif

If _lRetCont
//+-----------------------------------------------+
//| Monta a tela para usuario visualizar consulta |
//+-----------------------------------------------+
DEFINE MSDIALOG oDlg TITLE "IMPRESSÃO DE PROPOSTA" FROM 0,0 TO 430,615 PIXEL

@ 010,005 Say "Escolha os Pedidos a serem incluídos na Proposta:"	Size 200,8 Font oFont1B 	Pixel
@ 025,005 LISTBOX oLbx FIELDS HEADER " ","Número","Cliente","Loja","Segm","Oper","Tp Pag","Cond Pag","Prazo","Emissao","Vendedor" ;
FIELDSIZES 10,25,25,15,15,15,15,20,20,25,25 SIZE 300,170 OF oDlg PIXEL

oLbx:SetArray( aVetPed )

oLbx:bLine := {|| {	Iif(aVetPed[oLbx:nAt,1],oOK,oNo),;        // Check
aVetPed[oLbx:nAt,02],;									      // Numero
aVetPed[oLbx:nAt,03],;                                        // Cliente
aVetPed[oLbx:nAt,04],;                                        // Loja
aVetPed[oLbx:nAt,05],;                                        // Segmento
aVetPed[oLbx:nAt,06],;							              // Operacao
aVetPed[oLbx:nAt,07],;                                        // Tipo Pagamento
aVetPed[oLbx:nAt,08],;         								  // Cond Pagamento
aVetPed[oLbx:nAt,09],;                                        // Prazo
StoD(aVetPed[oLbx:nAt,10]),;                                  // Emissao
aVetPed[oLbx:nAt,11],;                                        // Vendedor
aVetPed[oLbx:nAt,12]}}                                        // Nicho

oLbx:bLDblClick := {|nRowPix, nColPix, nKeyFlags| fMarcaUm(oLbx:nAt), oLbx:Refresh()}

@ 200,250 Button "Confirmar"	Font oFont Size 050,010 PIXEL OF oDlg Action Processa({|| Iif(nOp==1,U_ORTR727(aVetPed,MV_PAR02,MV_PAR03,MV_PAR04), (Iif(nOp==2, U_ORTR728(aVetPed), U_ORTR729(aVetPed) ))) , oDlg:End() },"Gerando Proposta...")
@ 200,010 Button "Sair"         Font oFont Size 050,010 PIXEL OF oDlg Action oDlg:End()

ACTIVATE MSDIALOG oDlg CENTERED

Else
	fOrtrPro(nOp)
Endif

Return(_lRetCont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FUNCAO MARCAR E DESMARCAR ATIVOS PARA AUTORIZAR					   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
******************************
Static Function fMarcaUm(nAt)
******************************
Local nPos:= 0

aVetPed[nAt,1] := If(aVetPed[nAt,1],.F.,.T.)

return


***************************
Static Function fExcluir()
***************************

Local 	oDlg, oProp
Private cPropE:=Space(8)

DEFINE MSDIALOG oDlg TITLE "Excluir Proposta" FROM 0,0 TO 200,250 PIXEL

@ 015,023 Say "Informe a proposta a ser excluída."	Size 200,8 Font oFont1B			Pixel

@ 035,043 MsGet oProp	Var cPropE	Size 040,005	Pixel of oDlg
//@ 27,010 To 090,190 Pixel

/*Processa({|| fIntSZB(), },"Verificando títulos...")*/      //Processa({|| U_ORTR727(aVetPed), },"Gerando Proposta...")
@ 070,020 Button OemToAnsi("Excluir" )	Size 030,014	Action Processa({ || fExcluiP(cPropE),},"Excluindo proposta...")	Pixel of oDlg

@ 070,080 Button OemToAnsi("Sair")	Size 030,014	Action oDlg:End()		Pixel of oDlg


ACTIVATE MSDIALOG oDlg CENTERED

Return()

********************************
Static Function fExcluiP(cPropE)
********************************
     
Local cQry	:=" "
Local nStatus := 0
Local lExc	:= .F.

cQry :=" SELECT C5_NUM, C5_XPRONUM "
cQry +=" 	FROM  "+RetSQLName("SC5")+" SC5	"
cQry +=" WHERE C5_XPRONUM 	= "+cValTochar(Val(cPropE))+" "
cQry +=" 	AND  C5_FILIAL 	= '"+xFilial("SC5")+"' "
cQry +=" 	AND  SC5.D_E_L_E_T_ = ' ' "
    
If Select("PRO") > 0
	PRO->(DbCloseArea())
Endif
TcQuery cQry Alias "PRO" New
DbSelectArea("PRO")
PRO->(DbGoTop())

If PRO->(EOF())
	Msginfo("Nenhuma proposta localizada com o número informado!") 
Else
	If MsgYesno("Confirma a exclusão da proposta "+cPropE+" ?")
	
		cQry :=" UPDATE "+RetSQLName("SC5")+" SC5 "
		cQry +=" 	SET C5_XPRONUM 	= 0 "
		cQry +=" WHERE C5_XPRONUM	= "+cValTochar(Val(cPropE))+" "
		cQry +=" 	AND  C5_FILIAL 	= '"+xFilial("SC5")+"' "
		cQry +="    AND SC5.D_E_L_E_T_ = ' ' "
		
		nStatus := TCSQLEXEC(cQry)
		nStatus := TCSQLEXEC("COMMIT")
		cQry :=" "
		                              
		cQry :=" UPDATE PROPNUM "
		cQry +=" 	SET STATUS 	= 2 ,"
		cQry +=" 	 USRCANC	= '"+_cUsu+"' "
		cQry +=" WHERE PROPOSTA	= "+cValTochar(Val(cPropE))+" "
		cQry +=" AND   FILIAL  	= '"+xFilial("SC5")+"' "
		
		nStatus := TCSQLEXEC(cQry)
		nStatus := TCSQLEXEC("COMMIT")
		cQry :=" "
		
		cQry :=" SELECT C5_NUM, C5_XPRONUM "
	  	cQry +=" 	FROM  "+RetSQLName("SC5")+" SC5	"
		cQry +=" WHERE C5_XPRONUM 	= "+cValTochar(Val(cPropE))+" "
		cQry +=" 	AND  C5_FILIAL 	= '"+xFilial("SC5")+"' "
		cQry +=" 	AND  SC5.D_E_L_E_T_ = ' ' "
	    
		If Select("PRO") > 0
			PRO->(DbCloseArea())
		Endif
		TcQuery cQry Alias "PRO" New
		DbSelectArea("PRO")
		PRO->(DbGoTop())
		
		If PRO->(EOF())
			lExc:=.T.
			Msginfo("Proposta excluída com sucesso!") 
		Else
	        Msginfo("Erro no processo de exclusão!")
	 	Endif
	 	
	 	cQry :=" select UN, Proposta from siga.propnum "
		cQry +=" where proposta = "+cValTochar(Val(cPropE))+" "
		cQry +=" 	AND  status = 2 "
		cQry +=" AND   FILIAL  	= '"+xFilial("SC5")+"' "
	    
	Else
		Msginfo("Cancelado pelo usuário!")
	Endif
Endif
		
Return

*************************
Static Function fReimp()
*************************

Local 	oDlg, oProp
Local	aTpProp:={"COMERCIAL","COMERCIAL VPC", "INDUSTRIAL"}
Local	cProp  :=Space(8)
Local	cTpProp:=" "

DEFINE MSDIALOG oDlg TITLE "Reimpressão de Proposta" FROM 0,0 TO 200,250 PIXEL

@ 015,025 Say "Selecione o tipo de Proposta:"	Size 200,8 Font oFont1B			Pixel
@ 025,025 ComboBox cTpProp Items aTpProp /*on change fTipo()*/  Size 080,008    Pixel

@ 045,016 Say "Num. Proposta:"		Size 100,8 Font oFont1B			Pixel
@ 045,055 MsGet oProp	Var cProp	Size 040,005	Pixel of oDlg

@ 070,080 Button OemToAnsi("Imprimir" )	Size 030,014	Action Processa({ || fReimpA(cTpProp,cProp),},"Reimprimindo Proposta...")	Pixel of oDlg

@ 070,020 Button OemToAnsi("Sair")	Size 030,014	Action oDlg:End()		Pixel of oDlg


ACTIVATE MSDIALOG oDlg CENTERED

Return()

***************************************
Static Function fReimpA(cTpProp,cProp)
***************************************

Local 	_cQuery :=" "
Private aVetPed :={}

_cQuery := "SELECT C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_XTPSEGM, C5_XOPER, C5_XTPPGT, "
_cQuery += "       C5_CONDPAG, C5_XPRZMED, C5_EMISSAO,  C5_XEMBARQ, C5_VEND1, C5_XNICHO "
_cQuery += "   FROM "+RetSQLName("SC5")+" SC5 "
_cQuery += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
_cQuery += "   AND SC5.D_E_L_E_T_ = ' ' "
_cQuery += "   AND C5_XPRONUM = "+cValtoChar(Val(cProp))+" "
_cQuery += "ORDER BY C5_EMISSAO DESC, C5_NUM DESC, C5_XOPER  "

Memowrite("c:\PedProp.sql",_cQuery)

If Select("PED") > 0
	PED->(DbCloseArea())
Endif
TcQuery _cQuery Alias "PED" New
DbSelectArea("PED")
PED->(DbGoTop())

If PED->(EOF())
	Alert("Nenhum pedido localizado com a proposta informada.")
Else
	Do While PED->(!EOF())		
		aAdd( aVetPed ,{ .T., PED->C5_NUM, PED->C5_CLIENTE, PED->C5_LOJACLI, PED->C5_XTPSEGM, PED->C5_XOPER, PED->C5_XTPPGT, ;
		PED->C5_CONDPAG, PED->C5_XPRZMED, PED->C5_EMISSAO, PED->C5_VEND1, PED->C5_XNICHO})
		PED->(DbSkip())		
	End Do
	
  Do Case
	Case cTpProp == "COMERCIAL"		
		Processa({|| U_ORTR727(aVetPed,MV_PAR02,MV_PAR03,MV_PAR04), },"Gerando Proposta...")
		
	Case cTpProp == "COMERCIAL VPC"	
		Processa({|| U_ORTR728(aVetPed), },"Gerando Proposta...")
	
	Case cTpProp == "INDUSTRIAL"	
    	Processa({|| U_ORTR729(aVetPed), },"Gerando Proposta...")
    	
    Otherwise
        Alert("Erro no tipo de proposta!")
  End case

Endif

Return()
