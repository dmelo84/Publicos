*****************************************************************************
* Programas Contidos neste Fonte                                            *
*****************************************************************************
* User Functions                                                            *
*---------------------------------------------------------------------------*
* OrtA032()      |                |                |                        *
*---------------------------------------------------------------------------*
* Static Functions                                                          *
*---------------------------------------------------------------------------*
* .              | .              | .              | .                      *
*****************************************************************************
* Tabelas (SC5, SC6, SE1, SZA, SC9)                                         *
*****************************************************************************
* Parametros:                                                               *                     
*****************************************************************************

*****************************************************************************     
*+-------------------------------------------------------------------------+*
*|Funcao      | OrtA032  | Autor |  Cleverson Luiz Schaefer                |*                      
*+------------+------------------------------------------------------------+*                       
*|Data        | 24.03.2006                                                 |*                        
*+------------+------------------------------------------------------------+*
*|Descricao   | Cancelamento e Estorno de cancelamento pedidos             |*
*|            |                                    |						*
*+-------------------------------------------------------------------------+*
*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | OrtA106  | Autor |  Márcio Sobreira (Criare)	           |*
*+------------+------------------------------------------------------------+*
*|Data        | 28.05.2018                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Retorno da Quantidade para para o Pedido Original          |*
*|            |                                    |						*
*+-------------------------------------------------------------------------+*
*****************************************************************************

#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "RwMake.Ch"
#Include "SigaWin.Ch"
#include "colors.ch"
#include "font.ch"
#INCLUDE "JPEG.CH"
#INCLUDE "TBICONN.CH"

User Function ORTA106()

Local cTitulo    := "Preparando Base"
Local aVetor     := {}
Local oCombo     := Nil
Private oDlg     := Nil
Private cObscan  := SPACE(100)
Private cUsucan  := Space(50)
Private cCombo   := Space(10)
Private lNCanc   := .T.
Private cPedido  := Space(06)
Private a_InfoUser := {}
Private aAllGrp  := AllGroups()
Private cCanTrc  := Alltrim(aAllGrp[ascan(aAllGrp,{|X| ALLTRIM(x[1,2]) == "AUTCANTRC"}),1,1]) //Autorização para Cancelamento de troca
Private cCanPrg  := Alltrim(aAllGrp[ascan(aAllGrp,{|X| ALLTRIM(x[1,2]) == "CANCPRG"}),1,1])   //Autorização para Cancelamento de troca
Private cCanPUnd := Alltrim(aAllGrp[ascan(aAllGrp,{|X| ALLTRIM(x[1,2]) == "CANCPUND"}),1,1])  //Autorização para Cancelamento de Pedidos entre Unidade
Private cAUTBPC  := Alltrim(aAllGrp[ascan(aAllGrp,{|X| ALLTRIM(x[1,2]) == "AUTBPC"}),1,1]) //Somente usuários que possam descancelar os pedidos com bloqueios da comercial
private lRet     :=.T.
Private lRTCAT   :=.F.
Private cLocPad  := iif(cEmpAnt$"18","01","18")
Private _lEUN    := .F.
Private lPedNFat := .F.

If Empty(a_InfoUser)
	PswOrder(1)
	PswSeek(__cUserID, .T.)
	a_InfoUser := PswRet(1)
EndIf

//PREPARE ENVIRONMENT EMPRESA "03" FILIAL "02"
dbSelectArea("SX5")
dbOrderNickName("PSX51")
dbSeek(xFilial("SX5")+"ZS")
CursorWait()
While !Eof() .And. X5_FILIAL == xFilial("SX5") .And. X5_TABELA=="ZS"
	aAdd( aVetor, Trim(X5_CHAVE)+" - "+Capital(Trim(X5_DESCRI)) )
	dbSkip()
End
CursorArrow()
If Len( aVetor ) == 0
	Aviso( cTitulo, "Nao existem dados a consultar", {"Ok"} )
	Return
Endif

DEFINE MSDIALOG oDlg TITLE "Cancelamento do Pedido de Venda" FROM 0,0 TO 250,400 OF oDlg PIXEL

@ 10, 10 Say "Pedido " SIZE  65, 8 PIXEL of oDlg
@ 10, 50 Msget cPedido PICTURE "@!" Valid ValPed()  Size 50,10 Pixel of oDlg
@ 25, 10 SAY "Motivo de Cancelamento"            SIZE  65, 8 PIXEL of oDlg
@ 35, 10 COMBOBOX oCombo VAR cCombo ITEMS aVETOR SIZE 181,10 PIXEL of oDlg WHEN lNCanc
@ 50, 10 Say OemToAnsi("Observacoes/Justificativa") Size 75,8 Pixel of oDlg
@ 60, 10 MSGet cObscan  PICTURE "@!" Size 181,10  WHEN lNCanc Pixel of oDlg
@ 75, 10 Say OemToAnsi("Solicitante do cancelamento") Size 75,8 Pixel of oDlg
@ 85, 10 MSGet cUsucan  PICTURE "@!" Size 181,10 WHEN lNCanc Pixel of oDlg
@ 104,060 BUTTON "&Relatorio"         SIZE 40,15 ACTION u_ortr066() Pixel of oDlg
@ 105,120 BMPBUTTON TYPE 01 ACTION ProcessaCanc()
//@ 105,150 BUTTON "&Sair"   SIZE 40,15 PIXEL ACTION oDlg:End()
@ 105,165 BMPBUTTON TYPE 02 ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg CENTER

Return()

************************
Static Function ValPed()
************************

Local cNumRtc := ""
lRet:=.T.


if !empty(cPedido)
	DbSelectArea("SC5")
	dbOrderNickName("PSC51")
	if DbSeek(xFilial("SC5") + cPedido)

		If cEmpAnt == "22" .And. !U_VerGrupo("CANCPUND")
			If SUBSTR(SC5->C5_XOBSADI, 1, 5) = 'ORTP1' .and. !Empty(C5_XPEDDES) 
				Return .f.			
			Endif
		Endif			  

/*
		// Se estiver no ALTDESMAE, ou seja, se pode desmembrar, não pode cancelar.
		If U_ORTGRUPO("ALTDESMAE")
			MsgBox("Usuário sem acesso a esta rotina, pertence ao [ALTDESMAE]", "Sem Acesso", "INFO")
			return(.F.)
		Endif
*/

*'INICIO - Márcio Sobreira - Não permite cancelamento se Pedido N já foi faturado - 02/10/2018 '*
		lPedNFat := .F.
		If !Empty(SC5->C5_XPEDDES)
			CQRY := "SELECT COUNT(*) NREG "
			CQRY += "	FROM "+RetSqlName("SC5")+" SC5 "
			CQRY += "  WHERE C5_FILIAL = '"+xfilial("SC5")+"' "
			CQRY += "	AND  SC5.D_E_L_E_T_ = ' ' "
			CQRY += "	AND  SC5.C5_NOTA <> ' ' "		
			CQRY += "	AND  SC5.C5_NUM = '" + SC5->C5_XPEDDES  + "' "
			
			If Select("QRY") > 0  ; QRY->(DbCloseArea())  ; Endif
			MEMOWRIT("C:\ORTA106_PEDN.SQL",cQry)
			TcQuery cQry NEW ALIAS "QRY"
			dbSelectArea("QRY")
			If QRY->NREG > 0
				lPedNFat := .T.
			EndIf
			dbCloseArea()                 
		Endif
*'FIM    - Márcio Sobreira -------------------------------------------------------- 02/10/2018 '*

		//Consulta se é um pedido entre unidades.
		CQRY := "SELECT COUNT(*) NREG "
		CQRY += "	FROM "+RetSqlName("SC5")+" SC5 "
		CQRY += "  WHERE C5_FILIAL = '"+xfilial("SC5")+"' "
		CQRY += "	AND  SC5.D_E_L_E_T_ = ' ' "
//		CQRY += "	AND  C5_EMISSAO = '" + DTOS(SC5->C5_EMISSAO)  + "' "
		CQRY += "	AND  C5_XPEDDES = '" + SC5->C5_NUM  + "' "
		//CQRY += "	AND A1_CGC = M0_CGC "
		
		
		If Select("QRY") > 0  ; QRY->(DbCloseArea())  ; Endif
		MEMOWRIT("C:\ORTA106_PEDNEG.SQL",cQry)                                       
		TcQuery cQry NEW ALIAS "QRY"
		dbSelectArea("QRY")
		If QRY->NREG > 0
			lPedNeg :=.T.
		Else
			lPedNeg :=.F.
		EndIf
		dbCloseArea()
		
		DbSelectArea("SC5")
		if !empty(SC5->C5_XACERTO)
			lRet:=.F.
			MsgBox("Pedido Ja Foi acertado.","ORTA106 - Cancelamento Nao Permitido")
		elseif SC5->C5_XOPER=='97'
			lRet:=.F.
			_lEUN    := .T.
			MsgBox("Pedido ja transferido para outra unidade.","ORTA106 - Cancelamento Nao Permitido")
		elseif lPedNeg .and. !U_VerGrupo("AUTCNEG")	// elseif (!empty(SC5->C5_XPEDDES) .or. lPedNeg) .and. !U_VerGrupo("AUTCNEG") - Pedidos filhos de negociação não podem ser cancelados porque altera a caracterisitica da negociação (pode diminuir o valor da negociação).
			lRet:=.F.
			MsgBox("Pedido de Negociação.","ORTA106 - Cancelamento Nao Permitido")
		elseif !empty(SC5->C5_XEMBARQ).and. !U_VerGrupo("CANCPRG") //.or. !Empty(SC5->C5_XUNORI))//.and. !lPedUn //.or. SC5->C5_XSERASA <> "S") // Acrescentado em 17/01/12 por Dupim para so permitir cancelar pedidos que tenha sido bloquados pelo SERASA
			lRet:=.F.
			MsgBox("Pedido Ja Foi Programado.","ORTA106 - Cancelamento Nao Permitido")
		elseif  (!empty(SC5->C5_NOTA) .and. !empty(SC5->C5_SERIE)) //BRUNO:06/12/2011 NAO PERMITIR O CANCELAMENTO DE PEDIDOS PARA PEDIDOS FATURADOS.
			lRet:=.F.
			MsgBox("Pedido Ja Foi Faturado.","ORTA106 - Cancelamento Nao Permitido")
		elseif SC5->C5_XOPER $ ("03/02/17") .and. !U_VerGrupo("AUTCANTRC") //Adicionado por Bruno a pedido do Sr. Seixas para não permitir cancelamentos de pedidos de troca.
			lRet:=.F.
			MsgBox("Cancelamento nao permitido para pedido de troca.","ORTA106 - Cancelamento Nao Permitido")
		elseif SC5->C5_XOPER == "99" .And. SC5->C5_XOPERAN == "98"
			lRet:=.F.
			MsgBox("Operação não permitida. Digitar o pedido novamente.","ORTA106 - Nao Permitido")
		elseif SC5->C5_XOPER <> "99" .And. SC5->C5_XPEDMAE .and. Empty(SC5->C5_XEMBARQ) .and. !U_VerGrupo("CANCMAE")
			lRet:=.F.
			MsgBox("Cancelamento nao permitido para pedido mae.","ORTA106 - Cancelamento Nao Permitido")
		elseif SC5->C5_XOPER == "99" .And. SC5->C5_XPEDMAE .and. Empty(SC5->C5_XEMBARQ) .and. !U_VerGrupo("ESTCMAE")
			lRet:=.F.
			MsgBox("Estorno de cancelamento nao permitido para pedido mae.","ORTA106 - Cancelamento Nao Permitido")
		elseif cEmpAnt $ "06|10|22|23|24|"  .And. !Empty(SC5->C5_XUNORI) .AND. SC5->C5_XOPER <> "13" .And. !U_VerGrupo("CANCPUND")	  // Permitir cancelamento de pedido entre unidade. [Brasileiro:03/09/2013]
			lRet:= .F.
			MsgBox("Pedido entre Unidades, USUÁRIO sem permissão para cancelamento !!!","ORTA106 - ATENCAO")
		elseif SC5->C5_XOPER == "13" .And. fVerTQ(SC5->C5_NUM)
			lRet:=.F.
			MsgBox("Cancelamento nao permitido! TQ Fora do Estado Gerado!","ORTA106 - Cancelamento Nao Permitido") 
			
			//		elseif UPPER(ALLTRIM(SC5->C5_XMOTCAN)) == "98" .and.
			//			lRet:=.F.
			//			MsgBox("Pedido com bloqueio da comercial, cancelamento nao permitido por esta rotina.","Cancelamento Nao Permitido")
		elseif lPedNFat // Pedido N já foi faturado
		    
			//Edilson Leal: Permite se for Allfibra e o pedido de compra foi cancelado na Unidade de origem (SSI 123623).
			If cEmpAnt == "22" .And. U_VerGrupo("CANCPUND")
			   
			   aXUnid := U_FRetUnidades()
			   cXTRBA := GetNextAlias()
			   cXTRBB := GetNextAlias()
			   lPedAberto := .F. 
			   
			   cQry := "SELECT * FROM PEDIDOALL PED"
			   cQry += " INNER JOIN "+RetSqlName("SC6")+" SC6"
			   cQry += " ON SC6.D_E_L_E_T_ = ' '"			    
			   cQry += " AND C6_FILIAL    = '"+xFilial("SC6")+"'"
               cQry += " AND TRIM(C6_NUM) = TRIM(NUMSC522)" 
               cQry += " WHERE TRIM(NUMSC522) = '"+SC5->C5_NUM+"'"
			   			   		   
               DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry), cXTRBA, .F., .T.)
               (cXTRBA)->(DbGoTop())

			   If (cXTRBA)->(!Eof())
			      
				  cxIP := aXUnid[Ascan(aXUnid, {|x| x[1] == (cXTRBA)->UN }),2]
				  cXDb := aXUnid[Ascan(aXUnid, {|x| x[2] == cxIP}),1]
                  
				  While (cXTRBA)->(!Eof())

			         cQry := "SELECT C7_NUM, C7_PRODUTO FROM SIGA.SC7"+Alltrim((cXTRBA)->UN)+"0@DB"+cXDb+" WHERE D_E_L_E_T_ = ' ' AND C7_FILIAL = '02' AND C7_NUM = '"+Alltrim((cXTRBA)->NUMSC7)+"' AND C7_PRODUTO = '"+Alltrim((cXTRBA)->C6_PRODUTO)+"' AND C7_RESIDUO <> 'S'" 
			         					 
					 DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry), cXTRBB, .F., .T.)
                     (cXTRBB)->(DbGoTop())

					 If (cXTRBB)->(!Eof())
                         lPedAberto := .T.
					 EndIF
                     (cXTRBB)->(DbCloseArea())
                 
				     (cXTRBA)->(DbSkip())

				  End   
                  (cXTRBA)->(DbCloseArea())
                  
				  If lPedAberto //Nao permitir se o pedido de compra ainda consta em aberto na Unidade de origem.
				     lRet:=.F.
			         MsgBox("Cancelamento nao permitido! Pedido N já foi faturado e pedido de compra ainda existe na unidade de origem","ORTA106 - ATENCAO")
                  EndIf
				  

			   Else
                  lRet:=.F.
			      MsgBox("Cancelamento nao permitido! Pedido N já foi faturado","ORTA106 - ATENCAO")
			   EndIf

			Else 
			   lRet:=.F.
			   MsgBox("Cancelamento nao permitido! Pedido N já foi faturado","ORTA106 - ATENCAO")
			EndIf
		else
			
			if SC5->C5_XOPER=="99" .and. empty(SC5->C5_XEMBARQ)
				//	  	    MsgBox("Pedido Cancelado.","Estrono Nao Permitido")
				//	  	    lRet:=.F.
				lNCanc:=.F.
				dbSelectArea("SX5")
				dbOrderNickName("PSX51")
				if dbSeek(xFilial("SX5")+"ZS"+SC5->C5_XMOTCAN)
					cCombo := Trim(X5_CHAVE)+" - "+Capital(Trim(X5_DESCRI))
				endif
				dbselectarea("SC5")
				cObscan:=SC5->C5_XOBSCAN
				cUsucan:=SC5->C5_XMENNF1
			else
				lNCanc  :=.T.
				cObscan := SPACE(100)
				cUsucan := SPACE(50)
			endif
		endif

		If SC5->C5_XOPER == "13" .And. !Empty(SC5->C5_XUNDEST) .and. !Empty(SC5->C5_RESREM)
			lRet:=.F.  
			_lEUN    := .T.
			MsgBox("Cancelamento nao permitido! Pedido {Operação 13} já foi importado para a unidade ["+SC5->C5_XUNDEST+"]!","ORTA106 - Atenção!!!")
		Endif	

		If SC5->C5_XOPER == "99" .and. SC5->C5_XOPERAN == "99" .and. !Empty(SC5->C5_XUNORI) .and. !Empty(SC5->C5_XPEDCLX)
			lRet:=.F.      
			_lEUN    := .T.
			MsgBox("Estorno cancelamento nao permitido! Pedido {Operação 14} é entre unidades!","ORTA106 - Atenção!!!")
		Endif	

		If SC5->C5_XOPER == "99" .and. !Empty(SC5->C5_XUNDEST) .and. !Empty(SC5->C5_RESREM)
			lRet:=.F.      
			_lEUN    := .T.
			MsgBox("Estorno cancelamento nao permitido! Pedido {Operação 13} é entre unidades!","ORTA106 - Atenção!!!")
		Endif	
		
		/*If cEmpAnt $ "06|10|22|24"
		If SC5->C5_XPEDCLI <> ' ' .AND. SC5->C5_XUNORI <> ' ' .AND. lRet
		CQRY := "SELECT * FROM SIGA.SC7"+ALLTRIM(SC5->C5_XUNORI)+"0
		CQRY += " WHERE D_E_L_E_T_ = ' '
		CQRY += "   AND C7_FILIAL = '"+xfilial("SC7")+"' "
		CQRY += "   AND C7_QUJE > 0 "
		CQRY += "   AND C7_RESIDUO = ' ' "
		CQRY += "   AND C7_NUM = '"+ALLTRIM(SC5->C5_XPEDCLI)+"'"
		If Select("QRY") > 0  ; QRY->(DbCloseArea())  ; Endif
		MEMOWRIT("C:\ORTA106_PEDUN.SQL",cQry)
		TcQuery cQry NEW ALIAS "QRY"
		dbSelectArea("QRY")
		If !EOF()
		lRet:=.F.
		DbCloseArea()
		MsgBox("Pedido de compra ja atendido ou parcialmente atendido ","Cancelamento Nao Permitido")
		Endif
		Endif
		Endif
		*/
		DbSelectArea("SZK")
		DbSetOrder(8)
		if DbSeek(xFilial("SZK") + cPedido)
			cNumRtc := SZK->ZK_NUMRTC
			if empty(SC5->C5_XACERTO) .And. (SZK->ZK_CLIENTE == SC5->C5_CLIENTE) .and. SZK->ZK_OPERAC$("AP|AT") .and. SC5->C5_XOPER <> "99"
				
				CQRY := "SELECT COUNT(*) TOT FROM PEDFLIB WHERE UNIDADE = '"+cEmpAnt+"' AND PEDIDO = '"+ALLTRIM(SC5->C5_NUM)+"' "
				CQRY += " AND TPLIB = 'AT' "
				If Select("QRY") > 0  ; QRY->(DbCloseArea())  ; Endif
				
				MEMOWRIT("C:\ORTA106_PEDAT.SQL",cQry)
				TcQuery cQry NEW ALIAS "QRY"
				dbSelectArea("QRY")
				If QRY->TOT > 0
					lRTCAT := .T.
				Else
					lRet:=.F.
					MsgBox("Este Pedido possui RTC.","ORTA106 - Cancelamento Nao Permitido")
				Endif
			Endif
		Endif

		// Verifica se Regional e permite a exclusão
//		If cEmpAnt $ "03" .and. !lRet .and. !lPedNFat .and. !_lEun
		If !lRet .and. !_lEun // Permite Cancelamento mesmo se já Faturado
			_lPerm := .F.

			If U_VerGrupo("CANCPEDN")
				_lPerm := .T.
			Endif	
/*
			If cEmpAnt $ "03"
//				If UPPER(AllTrim(cUserName)) $ "BRUNNO.20/ALEXANDRE.20/SANTANA.20/MARCUSVINICIUS.20/ALESSANDRO.20/FERREIRAMATTOS.20/PEDROPASTORE.20/FERNANDES.20/ROGERIOCARDOSO.20/DAVID.20"
				If U_VerGrupo("CANCPEDN")
					_lPerm := .T.
				Endif	
			ElseIf cEmpAnt $ "07"
//				If UPPER(AllTrim(cUserName)) $ "LUCAS.30/UILIAM.30/RAFAEL.30/WELLINGTON.30/CARVALHO.30"
				If U_VerGrupo("CANCPEDN")
					_lPerm := .T.
				Endif					
			Endif
*/
			If _lPerm
				If msgbox("Confirma o Cancelamento do Pedido mesmo com restrição?","ORTA106 - Atencao","YESNO")
					lRet := .T.		
				Endif
			Endif	
	    Endif
		///////////////////////////////////////////

	else
		MsgBox("Pedido Inexistente")
		lRet:=.F.
	endif
	
endif
Return(lRet)


****************************
Static Function ProcessaCanc()
****************************
If Empty(cPedido)
	MsgBox("Informe o pedido","ORTA106 - ATENCAO")
	lRet:= .F.
elseif Empty(cObscan) .and. lNCanc  //Observação de cancelamento obrigatório. [BRUNO:20/03/2012]
	MsgBox("Informe a justificativa do cancelamento!!!","ORTA106 - ATENCAO")
	lRet:= .F.
else
	if Empty(cUsucan) .and. lNCanc //Solicitante do cancelamento obrigatório. [BRUNO:20/03/2012]
		MsgBox("Informe quem solicitou o cancelamento!!!","ORTA106 - ATENCAO")
		lRet:= .F.
	else
		if lRet
			if lNCanc
				GravaCanc()
			else
				EstCanc()
			endif
		endif
	endif
endif
Return()

****************************
Static Function GravaCanc()
****************************
Local lFranquia := .F.

DbSelectArea("SC5")
dbOrderNickName("PSC51")
if DbSeek(xFilial("SC5") + cPedido)

	If SC5->C5_XTPSEGM $ '3|4' .AND. !EMPTY(SC5->C5_XEMBARQ) .AND. SC5->C5_XPEDMAE
		lFranquia := .T.
	Endif                     
		
	if SC5->C5_TIPO == "B" .or. SC5->C5_TIPO == "D"
		dbselectarea("SA2")
		dbOrderNickName("PSA21")
		dbseek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		cNome:=A2_NOME
	else
		dbselectarea("SA1")
		dbOrderNickName("PSA11")
		dbseek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		cNome:=A1_NOME
	endif
	If cEmpAnt $ "02|03|04|05|06|07|08|09|10|11|15" .And. SC5->C5_XTPSEGM == '8' .And. .F.
		MsgStop("Não é permitido cancelar pedidos do segmento site através do microsiga. Solicite o cancelamento via site.")
	ElseIf msgbox("Confirma Cancelamento do Pedido "+cPedido+" Cliente: "+cNome,"ORTA106 - Atencao","YESNO")
		DbSelectArea("SC5")
		//		If Empty(SC5->C5_XDTLIB)    
		RecLock("SC5",.F.)
		cCarga  := SC5->C5_XEMBARQ
		cPedDes := SC5->C5_XPEDDES
			If fVerPLib(SC5->C5_NUM)
				Alert("Este pedido está liberado para faturamento. Solicite ao Faturista para executar a rotina Libera Pedido Exclusão. Após a execução tente novamente.")
				Return()
			EndIf
		if !Empty(SC5->C5_XEMBARQ)
			SC5->C5_XOBSLIB := "PEDIDO DA CARGA "+SC5->C5_XEMBARQ+"CANCELADO EM " + DTOC(dDataBase) + " PELO USUARIO " + UPPER(SUBSTR(cUsuario,7,15))
			SC5->C5_XDTLIB	:= dDataBase
			If !lFranquia //.and. Empty(SC5->C5_XUNORI)
				SC5->C5_XOPER   := "99"    // EVALDO: 25/04/2006
				SC5->C5_XOPERAN := "99"    // Forçãr Gravação para não poder Estornar
			Endif
			SC5->C5_XEMBARQ := " "
			SC5->C5_XPEDDES := " "
			// Henrique - 12/11/2021 - Em antendimento a SSI 129083
			If SC5->C5_XTPSEGM $ "3/4"
			   SC5->C5_LIBEROK:=""
			EndIf
			MsUnLock()

			//Atualiza o valor do SZQ após o cancelamento definitivo do pedido. Marcos Furtado - 26/09/2013
			CQRY := "UPDATE siga."+RetSqlName("SZQ") +" SZQ "
			CQRY += "  SET ZQ_VALOR = NVL((SELECT SUM(DECODE(C5_XVALENT,"
			CQRY += "                                         0,"
			CQRY += "                                         D2_TOTAL + D2_VALIPI,"
			CQRY += "                                         C6_XPRUNIT * D2_QUANT) + DECODE(C5_TIPO, 'I', 0, D2_ICMSRET))"
			CQRY += "                         FROM siga."+RetSqlName("SC5") +"  SC5,"
			CQRY += "                              siga."+RetSqlName("SD2") +"  SD2,"
			CQRY += "                              siga."+RetSqlName("SC6") +"  SC6"
			CQRY += "                        WHERE SC5.D_E_L_E_T_ = ' '"
			CQRY += "                          AND SC6.D_E_L_E_T_ = ' '"
			CQRY += "                          AND SD2.D_E_L_E_T_ = ' '"
			CQRY += "                          AND C5_FILIAL = '"+xFilial("SC5")+"' "
			CQRY += "                          AND C6_FILIAL = '"+xFilial("SC6")+"' "
			CQRY += "                          AND D2_FILIAL = '"+xFilial("SD2")+"' "
			CQRY += "                          AND C5_NUM = D2_PEDIDO"
			CQRY += "                          AND C6_NUM = D2_PEDIDO"
			CQRY += "                          AND C6_ITEM = D2_ITEMPV"
			CQRY += "                          AND C5_XEMBARQ = ZQ_EMBARQ) -"
			CQRY += "                      nvl((SELECT SUM(C5_XVALENT)"
			CQRY += "                            FROM siga."+RetSqlName("SC5") +" SC5"
			CQRY += "                           WHERE SC5.D_E_L_E_T_ = ' '"
			CQRY += "                             AND C5_FILIAL = '"+xFilial("SC5")+"' "
			CQRY += "                             AND C5_XEMBARQ = ZQ_EMBARQ), "
			CQRY += "                          0),"
			CQRY += "                      ZQ_VALOR)"
			CQRY += " WHERE D_E_L_E_T_ = ' ' "
			CQRY += "   AND zq_filial = '"+xFilial("SZQ")+"' "
			CQRY += "   AND ZQ_EMBARQ =  '"+cCarga+"' "
			//CQRY += "   AND zq_dtpreve = '20130918';
			MEMOWRIT("C:\ORTA106_UPDSZQ.SQL",cQry)
			TCSQLEXEC(CQRY)
			TCSQLEXEC("COMMIT")
			//_fExcSZK("AP", SC5->C5_NUM, SC5->C5_XPEDDES)
			
			_lProdPed := .F.
			_lProdPed := fVerPRO(SC5->C5_NUM)
			
			dbselectarea("SC6")
			dbsetorder(1)
			dbseek(xFilial("SC6")+SC5->C5_NUM)
			while !eof() .AND. XFILIAL("SC6") == SC6->C6_FILIAL .AND. SC6->C6_NUM = SC5->C5_NUM
				IF SC6->C6_BLQ <> "R" .AND. POSICIONE("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_ESTOQUE")=="S"
					//Testa a variável _lProdPed que controla se houve produção para o pedido ou
					//se houve transferência de quantidades do armazem 18 para o 05.
					If _lProdPed .Or. SC6->c6_xqtdtrf > 0
						//_lRetTrf := U_ORT_TRF(SC6->C6_PRODUTO,SC6->C6_QTDVEN,"05",POSICIONE("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_LOCPAD"),dDatabase,SC6->C6_PRODUTO,"TRANSFERENCIA CANCELAMENTO PEDIDO: "+SC6->C6_NUM)                       
						_lRetTrf := U_ORT_TRF(SC6->C6_PRODUTO,SC6->C6_QTDVEN,"05",IIF(Alltrim(SC6->C6_CF)$'5918|6918|5919|6919|','03',POSICIONE("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_LOCPAD")),dDatabase,SC6->C6_PRODUTO,"TRANSFERENCIA CANCELAMENTO PEDIDO: "+SC6->C6_NUM)
						If _lRetTrf
							DbSelectArea("PA1")
							dbOrderNickName("CPA11")
							DbSeek(xFilial("PA1")+SC6->C6_NUM+SC6->C6_ITEM+SC6->C6_PRODUTO)							
							While !EOF() .And. SC6->C6_NUM == PA1->PA1_PEDIDO .And. PA1->PA1_ITEM == SC6->C6_ITEM
								DbSelectArea("PA1")
								RecLock("PA1",.F.)
								DbDelete()
								MsunLock()
								DbSKip()
							Enddo							
							DbSelectarea("SC6")
							RecLock("SC6",.F.)
							SC6->C6_BLQ := "R"
							SC6->C6_XQTDTRF := 0
							fLimpaOrig()
							MsUnLock()
 					        // Henrique - 12/11/2021 - Em atendimento a SSI 129083
					        If SC5->C5_XTPSEGM $ "3/4"
					           If RecLock("SC6",.F.)
			                      SC6->C6_BLQ:=""
			                      MsUnLock()
			                   EndIf
			                EndIf
						Else	
							Alert("O cancelamento deste pedido nao pode ser realizado! Houve problema na transferência. Favor entrar em contato com o CPD.")
							Return()
						Endif
					Else
						DbSelectarea("SC6")
						RecLock("SC6",.F.)
						SC6->C6_BLQ := "R"
						fLimpaOrig()
						MsUnLock()
					EndIF
					// Henrique - 12/11/2021 - Em atendimento a SSI 129083
					If SC5->C5_XTPSEGM $ "3/4"
					   If RecLock("SC6",.F.)
			              SC6->C6_BLQ:=""
			              MsUnLock()
			           EndIf
			        EndIf
					
					*'INICIO - Márcio Sobreira - Retorno da Quantidade para para o Pedido Original ------- 28/05/2018 - SSI: XXXXX --'*
					// Restorna Saldo para o Pedido Original se o mesmo foi Desmembrado
					If !Empty(cPedDes) .and. !lPedNFat
						fRestSld(cPedDes, SC6->C6_PRODUTO, SC6->C6_QTDVEN, "INC")
					Endif
					*'F I M  ----------------------------------------------------------------------------- 28/05/2018 - SSI: XXXXX --'*
				EndIf
				dbselectarea("SC6")
				dbskip()
			enddo
			
		else
			SC5->C5_XOBSLIB := "PEDIDO CANCELADO EM " + DTOC(dDataBase) + " PELO USUARIO " + UPPER(SUBSTR(cUsuario,7,15))
			SC5->C5_XDTLIB  := dDataBase
			If !lFranquia  //.and. Empty(SC5->C5_XUNORI)
				SC5->C5_XOPERAN := SC5->C5_XOPER
				SC5->C5_XOPER   := "99"    // EVALDO: 25/04/2006
			Endif
			// Forçar gravação para não poder estornar se Pedido for desmembramento
			If !Empty(SC5->C5_XPEDDES) .or. !Empty(SC5->C5_XPEDCLX)
				SC5->C5_XOPERAN := "99"    // Forçar gravação para não poder estornar
				SC5->C5_XPEDDES := " "
			Endif
            // Henrique - 12/11/2021 - Em atendimento a SSI 129083
			If SC5->C5_XTPSEGM $ "3/4"
			   SC5->C5_LIBEROK:=""
			EndIf
			///////////////////////////////////////////////////////////////////////
			MsUnLock()
			
			DbSelectArea("SC6")
			dbOrderNickName("PSC61")
			DbSeek(xFilial("SC6") + cPedido)
			While !Eof() .And. SC6->C6_NUM == cPedido
				RecLock("SC6",.F.)
				If !lFranquia
				    If RecLock("SC6",.F.)
					   SC6->C6_BLQ:= "R"
					   MsUnLock()
					EndIf
				Endif
				// Henrique - 12/11/2021 - Em atendimento a SSI 129083
				If SC5->C5_XTPSEGM $ "3/4"
				   If RecLock("SC6",.F.)
		              SC6->C6_BLQ:=""
		              MsUnLock()
		           EndIf
		        EndIf
				MsUnLock()
				
				*'INICIO - Márcio Sobreira - Retorno da Quantidade para para o Pedido Original ------- 28/05/2018 - SSI: XXXXX --'*
				// Restorna Saldo para o Pedido Original se o mesmo foi Desmembrado
				If !Empty(cPedDes) .and. !lPedNFat
					fRestSld(cPedDes, SC6->C6_PRODUTO, SC6->C6_QTDVEN, "INC")
				Endif
				*'F I M  ----------------------------------------------------------------------------- 28/05/2018 - SSI: XXXXX --'*
				
				DbSelectArea("SC6")
				DbSkip()
			EndDo

		endif
		DbSelectArea("SC5")
		RecLock("SC5",.F.)
		SC5->C5_XMOTCAN := substr(cCombo,1,2)
		SC5->C5_XOBSCAN := cObscan
		SC5->C5_XMENNF1 := cUsucan //ADICIONADO PARA ATENDER SSI 23731. [BRUNO:22/12/2012]
		MsUnLock()
		
		if !empty(SC5->C5_XEMBARQ)
			//Busco se houve produção através de OP para o Pedido
			//_fExcSZK("AP", SC5->C5_NUM, SC5->C5_XPEDDES)
			//U_fGeraSZK("AP", cPedOrig, .T., cNumped)
			
		endif
		if !empty(cCarga)
		    U_SPEXEC("VALCARGA"+cEMPANT+"0",{cCarga})
			cQuery:="SELECT COUNT(*) tot FROM PEDCG"+cEmpAnt+"0 WHERE CARGA = '"+cCarga+"' AND FILIAL = '"+cFilAnt+"' "
			TCQUERY cQuery Alias "QRYCG" NEW
			if QRYCG->TOT == 0
				dbselectarea("SZQ")
				dbsetorder(1)
				if dbseek(xFilial("SZQ")+cCarga)
					reclock("SZQ",.F.)
					SZQ->ZQ_SITUACA:="C"
					msunlock()
				endif
			endif
			dbselectarea("QRYCG")
			dbclosearea()
		endif
		//		EndIf
		//ELIMINA RESIDUO DAS ORDENS DE COMPRA QUANDO PEDIDO FOR DE UNIDADES
/*
		If cEmpAnt $ "06|10|22|23|24"
			If SC5->C5_XPEDCLI <> ' ' .AND. SC5->C5_XUNORI <> ' '
				CQRY := "UPDATE SC7"+ALLTRIM(SC5->C5_XUNORI)+"0 SET C7_RESIDUO = 'S' "
				CQRY += " WHERE D_E_L_E_T_ = ' ' "
				CQRY += "   AND C7_FILIAL = '02' "
				CQRY += "   AND C7_NUM = '"+ALLTRIM(SC5->C5_XPEDCLI)+"'"
				alert(TCSQLExec(CQRY))
				TCSQLEXEC("COMMIT")
			Endif
		Endif
*/		
		If lRTCAT
			cQuery:="  UPDATE SIGA." + RetSqlName("SZK")
			cQuery+="  SET " + /*ZK_PEDIDO = ' ',*/ " ZK_OBS = TRIM(ZK_OBS) || ' PEDIDO: " + SC5->C5_NUM +" '"  // Solicitação Márcio da Cobrança - Não mais apagar o campo Pedido da RTC
			cQuery+="  WHERE ZK_FILIAL = '"+ xFilial("SZK") + "' "
			cQuery+="  AND D_E_L_E_T_ = ' ' "
			cQuery+="  AND ZK_PEDIDO = '"+ SC5->C5_NUM +"' "
			TCSQLExec(cQuery)                                       
			MemoWrit('C:\ORTA106_UPDAT.sql',cQuery)
			lRTCAT := .F.
		Endif
		
		*'Importação pedidos - Márcio Sobreira -------------------------------------------------------------'*
		_cPedClx := AllTrim(SC5->C5_XPEDCLX)
		If !Empty(_cPedClx)
			// Localiza a Unidde de Origem
			cUnOri  := SC5->C5_XUNORI
			If !Empty(cUnOri)
				_cRetx := "Ação não realizada"
				
				aIps:=U_FRetUnidades()
				//	 		aIps:=FRetUnidades() 					// Márcio - Recolocar esta Linha
				nPos:= aScan(aIps,{|x| x[1]==cUnOri})
				If nPos==0
					Alert("Unidade de origem Invalida")
					Return()
				Else
					oSrv:=rpcconnect(aIps[nPos,2], aIps[nPos,3], aIps[nPos,4], aIps[nPos,5], aIps[nPos,6])
					if valtype(oSrv)=="O"
						_cRetx := oSrv:CallProc( 'U_ORTA668', _cPedClx, cCombo, cObscan, cUsucan, IIF(lNCanc,"C","E"),IIF(lPedNFat,"S","N"))
						rpcdisconnect(oSrv)
					Else
						Alert("Problemas na conexao com a unidade "+aIps[nPos,1])
					Endif
				Endif
				
				//			_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA658",{_aItens,_cPedCli},.T.) // Não envia Array
				//				_cRetx  := U_ORTA668(_cPedCli, cCombo, cObscan, cUsucan, IIF(lNCanc,"C","E"))
				CONOUT("_cRetx: " + _cRetx)
				If SUBSTR(_cRetx,1,2) == "OK"
					Aviso("Atenção", IIF(lNCanc,"Cancelamento","Estorno") + " também realizado com sucesso no Pedido {Operação 13} ["+_cPedClx+"] da Unidade Origem ["+cUnOri+"].", { "Sair" } )
				Else
					Aviso("Atenção", "Erro: " + _cRetx + " da Unidade Origem ["+cUnOri+"] ", { "Sair" } )
				Endif
			Endif
		Endif
		*'--------------------------------------------------------------------------------------------------'*
		_fExcSZK("AP", Right(SC5->C5_XNPVORT,6), SC5->C5_NUM)
		
		// Tratativa Simbahia para a UN07
		If cEmpAnt == "07"
		
			_fExcSZK("SB", Right(SC5->C5_XNPVORT,6), SC5->C5_NUM)
			
		Endif
		//
		
		MsgBox("Pedido "+cPedido+" Cancelado!")
		
	endif
endif
cPedido:=space(6)
cObscan := SPACE(100)
cUsuCan := SPACE(50)
Return()


****************************
Static Function EstCanc()
****************************
If Empty(a_InfoUser)
	PswOrder(1)
	PswSeek(__cUserID, .T.)
	a_InfoUser := PswRet(1)
EndIf

if ascan(a_InfoUser[1,10],alltrim(cAUTBPC)) == 0
		msgbox("Usuario sem autorização para estorno de cancelamento.")
		return
endif
DbSelectArea("SC5")
dbOrderNickName("PSC51")
if DbSeek(xFilial("SC5") + cPedido)
	if SC5->C5_TIPO == "B" .or. SC5->C5_TIPO == "D"
		dbselectarea("SA2")
		dbOrderNickName("PSA21")
		dbseek(xFilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		cNome:=A2_NOME
	else
		dbselectarea("SA1")
		dbOrderNickName("PSA11")
		dbseek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
		cNome:=A1_NOME
	endif
	if msgbox("Confirma ESTORNO do Cancelamento do Pedido "+cPedido+" Cliente: "+cNome,"ORTA106 - Atencao","YESNO")
		If SC5->C5_XOPER == "99" .And. SC5->C5_XOPERAN == "98"
			MsgBox("Estorno não permitido. Digitar o pedido novamente.","ORTA106 - Estorno Não Permitido")
			Return()
		EndIf
		If SC5->C5_XOPERAN == "99"
			msgbox("Estorno não permitido! Pedido cancelado por decurso de prazo.","ORTA106 - Atencao")
			cPedido:=space(6)
			cPedido:=space(6)
			cObscan:= SPACE(100)
			cUsuCan:= SPACE(50)
			lNCanc :=.T.
			Return()
		Endif
		DbSelectArea("SC5")
		//		If Empty(SC5->C5_XDTLIB)
		RecLock("SC5",.F.)
		If !(SC5->C5_XTPSEGM $ '3|4') .or. (SC5->C5_XOPER $ '07|08')
			SC5->C5_XDTLIB  := stod(space(8))
		EndIf
		SC5->C5_XOBSLIB := "ESTORNO CANCELAMENTO EM " + DTOC(dDataBase) + " PELO USUARIO " + UPPER(SUBSTR(cUsuario,7,15))
		SC5->C5_XOPER   := SC5->C5_XOPERAN
		SC5->C5_XMOTCAN := " "
		SC5->C5_XOBSCAN := "ESTORNO CANCELAMENTO EM " + DTOC(dDataBase) + " PELO USUARIO " + UPPER(SUBSTR(cUsuario,7,15)) // " "
		SC5->C5_XESTCAN := dDataBase
		SC5->C5_XMENNF1 := " " //ADICIONADO PARA ATENDER SSI 23731. [BRUNO:22/12/2012]
		
		MsUnLock()
		//		EndIf
		DbSelectArea("SC6")
		dbOrderNickName("PSC61")
		IF DbSeek(xFilial("SC6") + cPedido)
			While !Eof() .And. SC6->C6_NUM == cPedido
				RecLock("SC6",.F.)
				If SC6->C6_QTDVEN > 0
					SC6->C6_BLQ    := " "
				Endif
				MsUnLock()
				
				*'INICIO - Márcio Sobreira - Retorno da Quantidade para para o Pedido Original ------- 28/05/2018 - SSI: XXXXX --'*
				// Restorna Saldo para o Pedido Original se o mesmo foi Desmembrado
				If !Empty(SC5->C5_XPEDDES) .and. !lPedNFat
					fRestSld(SC5->C5_XPEDDES, SC6->C6_PRODUTO, SC6->C6_QTDVEN, "EXC")
				Endif
				*'F I M  ----------------------------------------------------------------------------- 28/05/2018 - SSI: XXXXX --'*
				
				DbSelectArea("SC6")
				DbSkip()
			EndDo
		Else
			u_ortsmail("comercial.sigo@ortobom.com.br","Problema no estorno de cancelamento :" +cEmpAnt+cPedido+" "+SC5->C5_NUM ,"Cancelamento Pedido "+cEmpAnt,"")
		EndIF
		//SE FOR PEDIDO ENTRE UNIDADES, ESTORNA CANCELAMENTO DA ORDEM DE COMPRA
/*
		If cEmpAnt $ "06|10|22|23|24"
			If SC5->C5_XPEDCLI <> ' ' .AND. SC5->C5_XUNORI <> ' '
				CQRY := "UPDATE SC7"+ALLTRIM(SC5->C5_XUNORI)+"0 SET C7_RESIDUO = ' ' "
				CQRY += " WHERE D_E_L_E_T_ = ' ' "
				CQRY += "   AND C7_FILIAL = '02' "
				CQRY += "   AND C7_NUM = '"+ALLTRIM(SC5->C5_XPEDCLI)+"'"
				alert(TCSQLExec(CQRY))
				TCSQLEXEC("COMMIT")
			Endif
		Endif
*/		
		*'Importação pedidos - Márcio Sobreira -------------------------------------------------------------'*
		_cPedClx := AllTrim(SC5->C5_XPEDCLX)
		If !Empty(_cPedClx)
			// Localiza a Unidde de Origem
			cUnOri  := SC5->C5_XUNORI
			If !Empty(cUnOri)
				_cRetx := "Ação não realizada"
				
				aIps:=U_FRetUnidades()
				//	 		aIps:=FRetUnidades() 					// Márcio - Recolocar esta Linha
				nPos:= aScan(aIps,{|x| x[1]==cUnOri})
				If nPos==0
					Alert("Unidade de origem Invalida")
					Return()
				Else
					oSrv:=rpcconnect(aIps[nPos,2], aIps[nPos,3], aIps[nPos,4], aIps[nPos,5], aIps[nPos,6])
					if valtype(oSrv)=="O"
						_cRetx := oSrv:CallProc( 'U_ORTA668', _cPedClx, cCombo, cObscan, cUsucan, IIF(lNCanc,"C","E"),IIF(lPedNFat,"S","N")) 
						rpcdisconnect(oSrv)
					Else
						Alert("Problemas na conexao com a unidade "+aIps[nPos,1])
					Endif
				Endif
				
				//			_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA658",{_aItens,_cPedCli},.T.) // Não envia Array
				//				_cRetx  := U_ORTA668(_cPedCli, cCombo, cObscan, cUsucan, IIF(lNCanc,"C","E"))
				CONOUT("_cRetx: " + _cRetx)
				If SUBSTR(_cRetx,1,2) == "OK"
					Aviso("Atenção", IIF(lNCanc,"Cancelamento","Estorno") + " também realizado com sucesso no Pedido {Operação 13} ["+_cPedClx+"] da Unidade Origem ["+cUnOri+"].", { "Sair" } )
				Else
					Aviso("Atenção", "Erro: " + _cRetx + " da Unidade Origem ["+cUnOri+"] ", { "Sair" } )
				Endif
			Endif
		Endif
		*'--------------------------------------------------------------------------------------------------'*
		
		MsgBox("Cancelamento pedido "+cpedido+" estornado")
		
	endif
endif
cPedido:=space(6)
cPedido:=space(6)
cObscan:= SPACE(100)
cUsuCan:= SPACE(50)
lNCanc :=.T.
Return()


**********************************************************
*Função: fVerTQ()		Marcos Furtado	 Data: 28/12/2015*
**********************************************************
*Descrição: Função para verificar se há                  *
*           TQ gerado para pedido Fora do Estado         *
**********************************************************

Static Function fVerTQ(_cNumPed)

Local _lRet := .F.
//Geração do ressarcimento.

cQuery := " select E3_XNUMGER "
cQuery += " FROM SIGA."+RetSqlName("SE3")+" SE3 "
cQuery += " WHERE E3_FILIAL = '"+xFilial("SE3")+"'"
cQuery += " AND SE3.D_E_L_E_T_ = ' ' "
cQuery += " AND E3_PEDIDO = '"+_cNumPed+"' "
cQuery += " ORDER BY E3_XNUMGER"
MEMOWRITE("C:\fVerTQ.SQL",cQuery)
If Select("TRB") > 0 ; TRB->(DbCloseArea()) ; Endif
TcQuery cQuery Alias "TRB" New

DbSelectArea("TRB")

If !EOF() .And. Empty(TRB->E3_XNUMGER)
	Alert("O TQ " + TRB->E3_XNUMGER + " foi gerado para o Pedido " + _cNumPed +" .")
	_lRet := .T.
Endif
DbSelectArea("TRB")
DbCloseArea()

Return(_lRet)


/*********************************************************
*Função: fVerPRO()		Marcos Furtado	 Data: 06/04/2016*
**********************************************************
*Descrição: Função para verificar se há                  *
*           produção das op do pedido.                   *
*********************************************************/

Static Function fVerPRO(_cNumPed)

Local _lRet := .F.
//Geração do ressarcimento.

//Com a consulta assumo a produção do pedido uma vez que encontro um C2_QUJE > 0, uma vez que uma OP
//pode conter mais de um pedido e aglutinar produtos iguais.
If cEmpant == "24"
	cQuery := " select COUNT(*) COUNTPRO "
	cQuery += " from siga."+RetSqlName("SC5")+" sc5, siga."+RetSqlName("SC6")+" sc6,  "
	cQuery += " siga."+RetSqlName("SC2")+" sc2 "
	cQuery += " where c5_filial = '"+xFilial("SC5")+"'"
	cQuery += " and c6_filial = '"+xFilial("SC6")+"'"
	cQuery += " and c5_num = c6_num "
	cQuery += " and c2_quje > 0 "
	cQuery += " and c5_num = '"+_cNumPed+"' "
	cQuery += " and c2_num = c6_numop "
	cQuery += " and c6_produto = C2_PRODUTO "
	cQuery += " and c2_filial = '"+xFilial("SC2")+"'"
	
Else
	cQuery := " select COUNT(*) COUNTPRO "
	cQuery += " from siga."+RetSqlName("SC5")+" sc5, siga."+RetSqlName("SC6")+" sc6,  "
	cQuery += " siga."+RetSqlName("PA1")+" pa1 , siga."+RetSqlName("SC2")+" sc2 "
	cQuery += " where c5_filial = '"+xFilial("SC5")+"'"
	cQuery += " and c6_filial = '"+xFilial("SC6")+"'"
	cQuery += " and c5_num = c6_num "
	cQuery += " and pa1_filial = '"+xFilial("PA1")+"'"
	cQuery += " and c5_num = '"+_cNumPed+"' "
	cQuery += " and pa1_pedido = c5_num "
	cQuery += " and pa1_produt = c6_produto "
	cQuery += " and pa1_item = c6_item "
	cQuery += " and c2_num = pa1_numop "
	cQuery += " and pa1_produt = C2_PRODUTO "
	cQuery += " and c2_filial = '"+xFilial("SC2")+"'"
EndIF
MEMOWRITE("C:\fVerPRO.SQL",cQuery)
If Select("TRB") > 0 ; TRB->(DbCloseArea()) ; Endif
TcQuery cQuery Alias "TRB" New

DbSelectArea("TRB")

If !EOF() .And. TRB->COUNTPRO > 0
	_lRet := .T.
Endif
DbSelectArea("TRB")
DbCloseArea()

Return(_lRet)

/*********************************************************
*Função: fVerPLib()		Marcos Furtado	 Data: 08/04/2016*
**********************************************************
*Descrição: Função para verificar se há                  *
*           pedido liberado.                             *
*********************************************************/

Static Function fVerPLib(_cNumPed)

Local _lRet := .F.

_cQryLib	:=	"SELECT COUNT(*) REC	"
_cQryLib    +=  " FROM "+RetSqlName("SC9")+" SC9, "+RetSqlName("SC5")+" SC5 "
_cQryLib    +=  " WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
_cQryLib    +=  " AND SC9.D_E_L_E_T_ = ' ' "
_cQryLib    +=  " AND C5_FILIAL = '"+xFilial("SC5")+"' "
_cQryLib    +=  " AND SC5.D_E_L_E_T_ = ' '"
_cQryLib    +=  " AND C5_NUM = C9_PEDIDO "
_cQryLib    +=  " AND C5_NUM ='"+_cNumPed+"' "


MEMOWRIT("C:\RETLIB.SQL",_cQryLib)
If Select("RETLIB") > 0
	dbSelectArea("RETLIB")
	dbCloseArea()
EndIf
TCQUERY _cQryLib ALIAS "RETLIB" NEW

DbSelectArea("RETLIB")

If !eof() .and. RETLIB->REC>0
	_lRet := .T.
EndIf

Return(_lRet)

****************************
Static Function fLimpaOrig()
****************************

&& Henrique - 11/05/2017
&& Incluido IF para limpar os campos da nota fiscal de origem no cancelamento de uma
&& nota de devolução
&& C5_TIPO='D' Indica pedido de devolução
&& C5_XOPER # '04' indica diferente de não repor

If SC5->C5_TIPO = 'D' .OR. (SC5->C5_XOPER # '04' .AND. !Empty(SC6->C6_NFORI))
	SC6->C6_NFORI  :=""
	SC6->C6_SERIORI:=""
	SC6->C6_ITEMORI:=""
EndIf

Return(NIL)

*'INICIO - Márcio Sobreira - Retorno da Quantidade para para o Pedido Original ------- 28/05/2018 - SSI: XXXXX --'*
Static Function fRestSld(_cPedido, _cProduto, _nQuant, _cOper)
Local _aArea	:= GetArea()
Local _lRet		:= .F.

// Posiciona no Produto
DbSelectArea("SB1")
DbSetOrder(1)
DbGoTop()
DbSeek(XFILIAL("SB1")+_cProduto)

DbSelectArea("SC6")
dbOrderNickName("PSC62")
DbGoTop()
*'Passa a Restaurar Registro caso toda quantidade do produto seja utilizada - 10/05/21 - DUPIM'*
If !DbSeek(XFILIAL("SC6")+_cProduto+_cPedido)
	_cQry := " UPDATE " + RetSqlName("SC6") 																   + CRLF
	_cQry += " SET D_E_L_E_T_ = ' ', C6_BLQ = ' ' 															 " + CRLF
	_cQry += " WHERE D_E_L_E_T_ = '*'	                                                                     " + CRLF
	_cQry += " AND   C6_NUM     = '" + _cPedido + "'           		                                         " + CRLF
	_cQry += " AND   C6_FILIAL  = '" + xFilial("SC6") + "'   	     	                                     " + CRLF
	_cQry += " AND   C6_QTDVEN  = 0																             " + CRLF	
	TCSQLEXEC(_cQry)
	TCSQLEXEC("COMMIT")
Endif
*'Passa a Restaurar Registro caso toda quantidade do produto seja utilizada - 10/05/21 - DUPIM'*

DbSelectArea("SC6")
dbOrderNickName("PSC62")
DbGoTop()
If DbSeek(XFILIAL("SC6")+_cProduto+_cPedido)

	_lRet := .T.
	If RecLock("SC6",.F.)
		SC6->C6_QTDVEN	:= IIF(_cOper == "INC", SC6->C6_QTDVEN + _nQuant, SC6->C6_QTDVEN - _nQuant)

*'Grava corretamente C6_XFEILOJ conforme quantidade (Bahia)'*
		If cEmpAnt $ "07/23/24"
			If SC6->C6_XFEILOJ <> 0
				SC6->C6_XFEILOJ := ((SC6->C6_PRUNIT * SC6->C6_QTDVEN) * 11.828) / 100
			Endif	
		Endif
*'Grava corretamente C6_XFEILOJ conforme quantidade (Bahia)'*

		If SB1->B1_TIPCONV == "M"
			SC6->C6_UNSVEN := SC6->C6_QTDVEN * SB1->B1_CONV
		ElseIf SB1->B1_TIPCONV == "D"
			SC6->C6_UNSVEN := SC6->C6_QTDVEN / SB1->B1_CONV
		Else
			SC6->C6_UNSVEN := SC6->C6_QTDVEN
		EndIf				
				
//		SC6->C6_UNSVEN  := SC6->C6_QTDVEN
		SC6->C6_VALOR   := (SC6->C6_PRCVEN * SC6->C6_QTDVEN)
		If SC6->C6_QTDVEN > 0
			SC6->C6_BLQ    := " "
		Endif
*'Passa a Deletar caso toda quantidade do produto seja utilizada - 10/05/21 - DUPIM'*
		If SC6->C6_QTDVEN <= 0
			SC6->(DbDelete())
		Endif
*'Passa a Deletar caso toda quantidade do produto seja utilizada - 10/05/21 - DUPIM'*
		SC6->(MsUnLock())
	Endif
Endif

RestArea(_aArea)
Return(_lRet)
*'F I M  ----------------------------------------------------------------------------- 28/05/2018 - SSI: XXXXX --'*

/*/{Protheus.doc} _fExcSZK

//TODO Função auxiliar criada para excluir o desmembramento
       na tabela SZK.

@author Peder Munksgaard
@since 06/09/2018
@version 1.0
@return ${return}, ${"Se _lGera, retorno lógico, senão retorno array"}
@param _cOper  , , Operação desejada da SZK (ZK_OPERAC)
@param _cNumPed, , Número do pedido de vendas (C5_XNPVORT)
@param _cNumDes, , Número do pedido de vendas desmembrado (C5_NUM).
@type function
/*/
Static Function _fExcSZK(_cOper, _cNumPed, _cNumDes)

	Local   _xRet  

	Local   _aArea   := GetArea()

	Local   _cQry    := ""
	Local   _cTrb    := ""

	Local   _nVlNped := 0
	Local   _nVlOped := 0
	Local   _nVlDped := 0

	Default _cOper   := "AP"
	Default _cNumPed := ""
	Default _cNumDes := ""

	If !Empty(_cNumPed) .And. !Empty(_cNumDes)
		
		//_cOper := "AP"
		
		_cQry := " SELECT SUM(C6_VALOR) VALOR FROM " + RetSqlName("SC6") + " SC6, " + RetSqlName("SC5") + " SC5  " + CRLF
		_cQry += " WHERE SC6.D_E_L_E_T_ = ' '                                                                    " + CRLF
		_cQry += " AND   SC5.D_E_L_E_T_ = ' '                                                                    " + CRLF
		_cQry += " AND   SC5.C5_XOPER   NOT IN ('99','98')                                                       " + CRLF
		_cQry += " AND   SC5.C5_NUM     = '" + _cNumPed + "'                                                     " + CRLF
		_cQry += " AND   SC5.C5_NUM     = SC6.C6_NUM                                                             " + CRLF
		_cQry += " AND   SC5.C5_FILIAL  = SC6.C6_FILIAL                                                          " + CRLF
		_cQry += " AND   SC5.C5_FILIAL  = '" + FWxFilial("SC5") + "'                                             " + CRLF

		_cTrb := MpSysOpenQuery(_cQry)

		_nVlOped := (_cTrb)->VALOR

		_cQry := " SELECT SUM(C6_VALOR) VALOR FROM " + RetSqlName("SC6") + " SC6, " + RetSqlName("SC5") + " SC5  " + CRLF
		_cQry += " WHERE SC6.D_E_L_E_T_ = ' '                                                                    " + CRLF
		_cQry += " AND   SC5.D_E_L_E_T_ = ' '                                                                    " + CRLF
		_cQry += " AND   SC5.C5_XOPER   IN ('99','98')                                                           " + CRLF
		_cQry += " AND   SC5.C5_NUM     = '" + _cNumDes + "'                                                     " + CRLF
		_cQry += " AND   SC5.C5_NUM     = SC6.C6_NUM                                                             " + CRLF
		_cQry += " AND   SC5.C5_FILIAL  = SC6.C6_FILIAL                                                          " + CRLF
		_cQry += " AND   SC5.C5_FILIAL  = '" + FWxFilial("SC5") + "'                                             " + CRLF

		_cTrb := MpSysOpenQuery(_cQry)

		_nVlNped := (_cTrb)->VALOR

		_nVlDped := Abs(_nVlOped + _nVlNped)
/*
		_cQry := "SELECT MAX(ZK_ITEM) MAXIT FROM " + RetSqlName("SZK") + " SZK " + CRLF
		_cQry += "WHERE SZK.D_E_L_E_T_ = ' '                                   " + CRLF
		_cQry += "AND   SZK.ZK_PEDIDO  = '" + _cNumPed + "'                    " + CRLF
		_cQry += "AND   SZK.ZK_FILIAL  = '" + FWxFilial("SZK") + "'            " + CRLF

		_cTrb := MpSysOpenQuery(_cQry)
		
		_cNItem := Soma1((_cTrb)->MAXIT)
*/		
		_cQry := "SELECT * FROM " + RetSqlName("SZK") + " SZK       " + CRLF
		_cQry += "WHERE SZK.D_E_L_E_T_ = ' '                        " + CRLF

		If _cOper <> "*"

			_cQry += "AND   SZK.ZK_OPERAC  = '" + _cOper   + "'         " + CRLF

		Endif

		_cQry += "AND   SZK.ZK_PEDIDO  IN ('" + _cNumDes + "', '" + _cNumPed + "')     " + CRLF
		_cQry += "AND   SZK.ZK_FILIAL  = '" + FWxFilial("SZK") + "' " + CRLF

		_cTrb := MpSysOpenQuery(_cQry)

		While (_cTrb)->(!Eof())
		
			If _nVlDped > 0
			
				dbSelectArea("SZK")
				SZK->(dbSetOrder(8))
				
				Begin Transaction 
				
					If SZK->(MsSeek((_cTrb)->(ZK_FILIAL+_cNumPed+ZK_OPERAC+ZK_CLIENTE+ZK_LOJA)))
					
						Reclock("SZK",.F.)
						Replace ZK_VALOR With _nVlDped
						SZK->(Msunlock())
						
					Endif
					
					If SZK->(MsSeek((_cTrb)->(ZK_FILIAL+_cNumDes+ZK_OPERAC+ZK_CLIENTE+ZK_LOJA)))
					    
						Reclock("SZK",.F.)
     						If _cNumDes <> _cNumPed .and. _nVlOped > 0
	     					   SZK->(dbDelete())
							Else
							   SZK->ZK_OBS   :="PEDIDO "+_cNumDes+" CANCELADO PELO USUARIO: "+cUserName
							   SZK->ZK_PEDIDO:=" "
							Endif
						SZK->(Msunlock())
						
					Endif
					
				End Transaction
				
				_xRet := .T.
				
			Endif
			
			(_cTrb)->(dbSkip())
			
		End                                                                                           
		
		(_cTrb)->(dbCloseArea())
		
	Else
	
		_xRet := .F.
		
	Endif 

	RestArea(_aArea)

Return _xRet
