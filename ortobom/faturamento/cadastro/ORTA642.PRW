#include "Rwmake.ch"
#include "TbiConn.ch"
#include "TopConn.ch"
#Include "TOTVS.ch"
#INCLUDE "JPEG.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORTA642   º Autor ³ FÁBIO COSTA        º Data ³  20/12/2016 º±±                            
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±     
±±ºDescricao ³ Desmembramento de pedidos								  º±±
±±º          ³ SSI 34531 - Flexfoam, Allfibra, Flexcoil, Ciaplast. 		  º±±                                
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ativo Fixo				                                  º±±                                       
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAlteracao ³ 		                                 º Data ³    / / 	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ 															  º±±                              
±±º          ³ 									   						  º±±                                    
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORTA642   º Autor ³ Márcio Sobreira    º Data ³  13/03/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Desmembramento de pedidos Origem (Pela Importação) 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento				                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ORTA642R  º Autor ³ Márcio Sobreira    º Data ³  09/11/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Reprocessar o Desmembramento no pedido Origem (OPER. 13)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento				                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

*---------------------*
User Function ORTA642()
*---------------------*

Private oDlgB,oLbxB,oFont,oFontA,oOC,oDlgB,oLbxB,oFont,oFontA ,oDlg,oForn,oBtnOK,oDlgA,oLbx,oLbx2,oOcompra,oSay3,oCodCli,oCifFob,oDtEntr,oPedCli,oUnDest,oTotEspD, oTotEspP
Private aVetAtf	 := {}
Private oOk      := LoadBitmap( GetResources(), "LBOK" 		)
Private oNo      := LoadBitmap( GetResources(), "LBNO" 		)
Private aVetAtf  := {{.F.,"","","",0.0}}
Private cPed     := space(06)
Private cCodCli  := space(06)
//Private dDtEntr  := CTOD("")
Private cCifFob  := space(03)
Private cOC      := space(06) //Ordem de Compra
Private aCoBrw1  := {}
Private aHoBrw1  := {}
Private _aItens	 := {}
Private noBrw1   := 0
Private cSegm    := ""
Private cOper    := ""
Private cCodtab  := ""
Private cReftab  := ""
Private cConPag  := ""
Private cTpPgt   := ""
Private cPrzMed  := ""
Private dEmissao := DDATABASE
Private dEntrega := DDATABASE
Private dDtLib   := DDATABASE
Private dDtVen   := DDATABASE
Private cVend    := ""
Private nVol     := 0
Private nPeso    := 0
Private nPesBru  := 0                                                                           
Private cTpCarga := ""
Private cPedCli  := ""
Private xPedCli  := ""
Private cPedClx  := ""
Private xPedClx  := ""
Private cUn      := ""
Private cProduto := ""
Private cDesc    := ""
Private cObs     := ""
Private cUM      := ""
Private cSEGUM   := ""
Private cMed     := ""
Private cTes 	 := ""
Private cLocal   := ""
Private cCFOP    := ""
Private cClasFis := ""
Private cCliente := ""
Private cLoja	 := ""
Private cOper    := ""
Private nQtdVen  := 0
Private nQtdSeg  := 0
Private nPrcVen  := 0
Private cProNum  := 0

Private nPrcUni  := 0
Private nDescont := 0
Private nValDesc := 0
*'Grava corretamente C6_XFEILOJ conforme quantidade (Bahia)'*
Private nFeiLoj  := 0
*'Grava corretamente C6_XFEILOJ conforme quantidade (Bahia)'*
Private nValor   := 0
Private nCusto   := 0
Private cTipoCli := ""
Private NPED     := 0
Private cNumped  := ""
Private nxPrcVen := 0
Private nzPrcVen := 0
Private nSaldo   := 0
Private aRelImp  := {}
Private nomeprog := "ORTA642"
Private nVolume  := 0
Private nPesoN   := 0
Private nCont    := 0
Private cNPed	 := space(06)
Private cNumDev  := ""
Private dEntreg  := ctod("  /  /  ")
Private dEntref  := ctod("  /  /  ")
Private cUnDest  := "  "
Private nTotEspD := 0
Private nTotEspP := 0
Private cAprGf   := " "
Private cXTeleMk := " "
Private cXobsadi := " " 
Private cXNicho  := " "

Private nVerRep  := 0
Private nVerExt  := 0
Private lPedEun  := .F.  

Private nTotEsp  := GetNewPar("MV_XTOTESP",0) // Limite espaço no caminhao por unidade

Private cC5_MENNOTA:="" // Henrique 09/03/2021 - SSI 112583

//If !(SubStr(upper(alltrim(GetEnvServer())), 1, 7) == "HOMOLOG")
//	alert("Função disponivel somente no ambiente de homologação.")
//	return
//endif
/*
if !CEMPANT $ "18|21|22|23|24"
alert("Acesso Somente para as unidades: Flexfoam, Allfibra, Flexcoil, Ciaplast e Ortofio.")
return
endif
*/

If !U_ORTGRUPO("ALTDESMAE")
	MsgBox("Usuário sem acesso a esta rotina [ALTDESMAE]", "Sem Acesso", "INFO")
	return
Endif

fListaItem()

Return

*****************************
Static Function fValPed()
*****************************

Local lRet  := .T.
Local _cQry := ""
Local _cTrb := ""

nTotEspP := 0
oTotEspP:Refresh()
nTotEspD := 0
oTotEspD:Refresh()

if !empty(cPed)
	dbselectarea("SC5")
	dbsetorder(1)
	if dbseek(xFilial("SC5")+cPed)
		
/*
		If cEmpAnt == "22"
			If SUBSTR(SC5->C5_XOBSADI, 1, 5) = 'ORTP1'		
				Return .f.			
			Endif
		Endif
*/		

		// Validação desconto IPI
		if SC5->C5_XOPER == "13" .and. SC5->C5_XUNDEST $ "21/22/23/24" .and. SC5->C5_XDESPRO $ "1/2"
			_cTexto := "O pedido lançado possui desconto do IPI e a unidade de destino não possui esta prática."
			_cTexto += " Ajustar o pedido para não haver desconrto para que o mesmo possa ser incluído!"
			MsgAlert(_cTexto)
			Return(.F.)                              
		Endif					

*'-- Solicitação DUPIM - 10/10/2019 ------------------------------------------------------------------------'*	
		If SC5->C5_XOPER == "14" .and. SC5->C5_XUNORI == "07" .and. Empty(SC5->C5_XPEDCLX)
			MsgBox("Pedido vindo da Bahia não pode ser desmembrado!")
			lRet:=.F.
		endif
*'-- Solicitação DUPIM - 10/10/2019 ------------------------------------------------------------------------'*	

		if SC5->C5_XOPER == "13" .and. SC5->C5_RESREM == "S"
			MsgBox("Pedido foi importado para a unidade ["+SC5->C5_XUNDEST+"]. Não pode ser desmembrado!")
			lRet:=.F.
		endif
		
		if SC5->C5_XOPER == "99"
			MsgBox("Este Pedido esta Cancelado")
			lRet:=.F.
		endif

		If SC5->C5_XPEDMAE
			MsgBox("Pedido de Franquia não pode ser desmembrado!")
			lRet:=.F.		
		Endif
		
		if !empty(SC5->C5_NOTA)
			MsgBox("Pedido Já Faturado")
			lRet:=.F.
		endif
		
		// Peder Munksgaard - 06/11/2018
		// Para o pedido ser desmembrado basta que o mesmo tenha aprovação 
		// da Comercial. 
		
*'Removido por solicitação do DUPIM - 04-12-18 -----------------------------------------------------------------'*
/*
		_cQry := " SELECT SUM(APRV) APRV                                                               " + CRLF
		_cQry += "   FROM (SELECT NVL(COUNT(*), 0) APRV                                                " + CRLF
		_cQry += "           FROM SIGA." + RetSqlName("SZE") + " SZE                                   " + CRLF
		_cQry += "          WHERE SZE.D_E_L_E_T_ = ' '                                                 " + CRLF
		_cQry += "            AND SZE.ZE_DTAUT <> ' '                                                  " + CRLF
		_cQry += "            AND SZE.ZE_USUARIO <> ' '                                                " + CRLF
		_cQry += "            AND SUBSTR(SZE.ZE_AUTORIZ,1,3) = 'BLQ'                                   " + CRLF
		_cQry += "            AND SZE.ZE_PEDIDO = '" + SC5->C5_NUM + "'                                " + CRLF
		_cQry += "            AND SZE.ZE_FILIAL = '" + FWxFilial("SZE") + "'                           " + CRLF
		_cQry += "         UNION ALL                                                                   " + CRLF
		_cQry += "         SELECT NVL(COUNT(*), 0) APRV                                                " + CRLF
		_cQry += "           FROM SIGA." + RetSqlName("SC5") + " SC5                                   " + CRLF
		_cQry += "          WHERE SC5.D_E_L_E_T_ = ' '                                                 " + CRLF
		_cQry += "            AND SC5.C5_XDTLIB <> ' '                                                 " + CRLF
		_cQry += "            AND SC5.C5_NUM = '" + SC5->C5_NUM + "'                                   " + CRLF
		_cQry += "            AND SC5.C5_FILIAL = '" + FWxFilial("SC5") + "')                          " + CRLF
		_cQry += "                                                                                     " + CRLF
				
		_cTrb := MpSysOpenQuery(_cQry)
		
		If (_cTrb)->APRV == 0 
		
			MsgBox("Este Pedido não está Liberado")
			lRet := .F. 
			
		Endif
		
		If Select((_cTrb)) > 0; (_cTrb)->(dbCloseArea()); Endif
*/		
*'Removido por solicitação do DUPIM - 04-12-18 -----------------------------------------------------------------'*
		/*
		if empty(SC5->C5_XDTLIB)
			MsgBox("Este Pedido não está Liberado")
			lRet:=.F.
		endif
		*/
		//
		
		if !empty(SC5->C5_XEMBARQ)
			MsgBox("Pedido Já Programado")
			lRet:=.F.
		endif
		
		if !empty(SC5->C5_XPEDDES)
			MsgBox("Pedido originado de um desmembramento")
			lRet:=.F.
		endif
		
*'Removido por solicitação do DUPIM - 26-12-18 -----------------------------------------------------------------'*
/*		If !Empty(SC5->C5_XFUNCAO)
			MsgBox("Pedido já foi exportado para o Cobol")
			lRet:=.F.
		endif*/
*'Removido por solicitação do DUPIM - 26-12-18 -----------------------------------------------------------------'*
		                                                                                                             
		If !Empty(SC5->C5_XACERTO)
			MsgBox("Pedido Já Acertado.")
			lRet:=.F.
		endif
		
		dbselectarea("SC9")
		dbsetorder(1)
		dbseek(xFilial("SC9")+SC5->C5_NUM)
		if SC9->C9_PEDIDO==SC5->C5_NUM
			MsgBox("Pedido já possui efetivacao, utilize a opcao Libera pedido exclusao")
			lRet:=.F.
		endif
		
		if !lRet
			return .f.
		endif
		
		cCodCli:= SC5->C5_CLIENTE                                                             
		oCodCli:Refresh()
		
		xPedCli:= SC5->C5_XPEDCLI
		oPedCli:Refresh()
		
		//		dDtEntr := SC5->C5_XENTREG
		//		oDtEntr:Refresh()
		
		cUnDest:= SC5->C5_XUNDEST
		oUnDest:Refresh()
		
		cCifFob := IIF(SC5->C5_TPFRETE == "C","CIF","FOB")
		oCifFob:Refresh()
		
		dbselectarea("SC6")
		dbsetorder(1)
		dbseek(xFilial("SC6")+SC5->C5_NUM)
		aVetAtf:={}
		aCoBrw1:={}
		
		_lFaltaE := .F.
		do while !eof() .and. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM
			_nB1XESP := POSICIONE("SB1",1,XFILIAL("SB1")+SC6->C6_PRODUTO,"B1_XESPACO")
			If _nB1XESP <= 0
				_lFaltaE := .T.
			Endif	
			nTotEspP += (_nB1XESP * SC6->C6_QTDVEN)
			aadd(aVetAtf,{.F.,SC6->C6_ITEM,SC6->C6_PRODUTO,SC6->C6_DESCRI,SC6->C6_QTDVEN,SC5->C5_XENTREG,SC5->C5_XENTREF})
			aadd(aCoBrw1,{SC6->C6_PRODUTO,SC6->C6_ITEM,SC6->C6_DESCRI,SC6->C6_QTDVEN,0,SC6->C6_PRCVEN,SC5->C5_XENTREG,SC5->C5_XENTREF,.F.})
			SC6->(dbskip())
		enddo
		nTotEspP := ROUND(nTotEspP,2)
		oTotEspP:Refresh()		

		If _lFaltaE
			MsgBox("Há produto(s) sem espaço informado!")
		Endif

		// Verifica se Pedido possui 2 Códigos de Produto iguais
		If Len(aCoBrw1) > 0
			For _Nz := 1 to Len(aCoBrw1)
				For _Nv := 1 to Len(aCoBrw1)
					If aCoBrw1[_Nz,1] == aCoBrw1[_Nv,1] .and. aCoBrw1[_Nz,2] <> aCoBrw1[_Nv,2]
						MsgBox("Pedido possui 2 códigos de produto ["+AllTrim(aCoBrw1[_Nz,1])+"] em duplicidade. Desmembramento não permitido!")
						Return(.F.)	    
					Endif
				Next		
			Next
		Endif	
		
		if Len(aCoBrw1)>=1
			oBrw1:aCols := aCoBrw1
			oBrw1:oBrowse:Refresh(.t.)
			oDlg1:Refresh()
		else
			if Len(aVetAtf)==1
				MsgBox("O pedido "+SC5->C5_NUM+" só possui um item, a divisão não é possivel")
			else
				MsgBox("Problemas no pedido "+SC5->C5_NUM+" Informe o setor de T.I.")
			endif
			aVetAtf  := {{.F.,"","","",0.0,ctod("  /  /  "),ctod("  /  /  ")}}
			lRet:=.F.
		endif
		
        // Validação do RPC na Unidade de Origem antes do desmembramento
		_cPedClx := AllTrim(SC5->C5_XPEDCLX)
		If !Empty(_cPedClx)
			// Localiza a Unidde de Origem
			cUnOri  := SC5->C5_XUNORI
			If !Empty(cUnOri)
				aIps:=U_FRetUnidades()
				nPos:= aScan(aIps,{|x| x[1]==cUnOri})
				if nPos==0
					Alert("Unidade de origem Invalida")
					Return()
				Else
					oSrv:=rpcconnect(aIps[nPos,2], aIps[nPos,3], aIps[nPos,4], aIps[nPos,5], aIps[nPos,6])
					if valtype(oSrv) <> "O"
						Alert("Pedido [EUN]. Problemas na conexao com a unidade de Origem "+aIps[nPos,1]+". O Desmembramento não será realizado!")
						Return(.F.)                              
					Else
						rpcdisconnect(oSrv)						
					Endif
				Endif
			Endif
		Endif		

	else
		MsgBox("Pedido não encontrado!")
		lRet:=.F.
	endif
Endif
Return(lRet)


***************************
Static Function fDivPed
***************************
Local nIt:=0
Local aEstru:={}
Local aCopia:={}

Local cCampo:=""
for i:=1 to len(aVetAtf)
	if aVetAtf[i,1]
		nIt++
	endif
next
if nIt == 0 .or. nIt == len(aVetAtf)
	MsgBox("Selecao invalida para divisao")
else
	
	fListaItem() //CARREGA ITEM PARA SELECIONAR AS QUANTIDADES
	
endif
return()


*----------------------------*
Static Function fListaItem()
*----------------------------*
Local nOpc    	 := GD_DELETE+GD_UPDATE
Private c_CodFor := space(6)
Private aCodGrp  := {}
Private cCombo	 := ""
Private oCBoxGrp

cTitulo:= "Desmembramento de Pedido de Venda   |  Pedido Nº - " + cPed

SetPrvt("oDlg1","oGrp1","oSay1","oSay6","oSay7","oSay8","oSay9","oSay10","oBtn1","oBtn2","oBtn3","oBrw1")

oDlg1      := MSDialog():New( 090,230,615,1125,":: Desmembramento de Pedido de Venda ::" ,,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 002,002,244,444," Itens do Pedido de Venda ",oDlg1,CLR_BLUE,CLR_WHITE,.T.,.F. )

oBtn1      := TButton():New( 248,360,"Gerar",oGrp1,{|| fImpRel()  },037,012,,,,.T.,,"",,,,.F. )
oBtn2      := TButton():New( 248,400,"Sair",oGrp1,{|| oDlg1:end()  },037,012,,,,.T.,,"",,,,.F. )
oSay2      := TSay():New( 017,006, {||"Nº PEDIDO:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,145,015)

// Cliente
oBtn2      := TButton():New( 015,185,"Mudar Cliente",oGrp1,{|| fListCli()  },037,012,,,,.T.,,"",,,,.F. )
oSay6      := TSay():New( 017,106, {||"Cliente Atual:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,145,015)

// Pedido Cliente
oSay7      := TSay():New( 017,240, {||"Ped. Cliente:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,145,015)
oPedCLi    := TGet():New( 015,280, {|u| If(PCount()>0,xPedCli:=u,xPedCli) }	,oGrp1, 050, 010,,                       ,,,,,,.T.,,, ,,,,   ,.F.,     ,"xPedCli")

// CIF / FOB
oSay6      := TSay():New( 017,345, {||"Tp. Frete:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,145,015)
oCifFob    := TComboBox():New( 015,380,{|u| If(PCount()>0,cCifFob:=u,cCifFob)},{"CIF","FOB"},060,010,oDlg,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cCifFob )

oCodCli    := TGet():New( 015,140, {|u| If(PCount()>0,cCodCli:=u,cCodCli) }	,oDlg, 040, 010,,                       ,,,,,,.T.,,, ,,,,.T.,.F.,     ,"cCodCli")
oCodFor    := TGet():New( 015,050, {|u| If(PCount()>0,cPed:=u   ,cPed   ) } ,oDlg, 040, 010,,{|| fValPed()  }		,,,,,,.T.,,, ,,,,   ,.F.,"SC5","cPed"   )

// Unidade Destino
oSay8      := TSay():New( 248,006, {||"Unidade Destino:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,145,015)
oUnDest    := TGet():New( 248,060, {|u| If(PCount()>0,cunDest:=u,cUnDest) }	,oGrp1, 015, 010,,                       ,,,,,,.T.,,, ,,,,   ,.F.,     ,"cUnDest")

// Total Epspaço Pedido
oSay9      := TSay():New( 248,090, {||"Tot.Espaço Pedido:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,145,015)
oTotEspP   := TGet():New( 248,140, {|u| If(PCount()>0,nTotEspP:=u,nTotEspP) }	,oGrp1, 045, 010,"@E 999,999",                       ,,,,,,.T.,,, ,,,,.T.,.F.,     ,"nTotEspP")

// Total Epspaço Desmembradoo
oSay10     := TSay():New( 248,220, {||"Tot.Espaço Desmem.:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,145,015)
oTotEspD   := TGet():New( 248,280, {|u| If(PCount()>0,nTotEspD:=u,nTotEspD) }	,oGrp1, 045, 010,"@E 999,999",                       ,,,,,,.T.,,, ,,,,.T.,.F.,     ,"nTotEspD")

//oGtUsr     := TGet():New( 019,040, {|u| If(PCount()>0,cGtUsr  :=u,cGtUsr) } ,oGrp1,035, 008,,{|| ottGetLogin}       ,,,,,,.T.,,, ,,,,lEdita,.F.,"GAVUSU","cGtUsr" ,,)
//oCodFor    := TGet():New( 015,050, {|u| If(PCount()>0,cPed:=u,cPed) }	,oDlg, 040, 010,,{|| fValPed()  }		,,,,,,.t.,,, ,,,,,.F.,"SC5","cPed")

MHoBrw1()
oBrw1      := MsNewGetDados():New(034,005,239,450,nOpc,'AllwaysTrue()','AllwaysTrue()','',{"C6_QTDENT","C5_XENTREG","C5_XENTREF"},0,200,'AllwaysTrue()','','AllwaysTrue()',oGrp1,aHoBrw1,aCoBrw1 )

oDlg1:Activate(,,,.T.)

Return

*----------------------------*
Static Function fListCli()
*----------------------------*
Local nOpc2    	 := GD_DELETE+GD_UPDATE

aCodGrp  := fBuscCli(SC5->C5_CLIENTE)
cCombo	 := aCodGrp[1]

cTitulo:= "Grupo de Clientes"

SetPrvt("oDlg2","oSay4","oBtn4","oBtn5")

oDlg2      := MSDialog():New( 090,230,185,650,":: Grupo Clientes ::" ,,,.F.,,,,,,.T.,,,.T. )
oGrp2      := TGroup():New( 002,002,070,300," Cliente ",oDlg2,CLR_BLUE,CLR_WHITE,.T.,.F. )

oBtn4      := TButton():New( 030,170,"Confirmar",oGrp2,{|| cCodCli := SUBSTR(cCombo,1,6), oDlg2:end()  },037,012,,,,.T.,,"",,,,.F. )
oSay4      := TSay():New( 017,006, {||"CLIENTE:"},oGrp2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,145,015)
oCBoxGrp   := TComboBox():New( 015,035,{|u|if(PCount()>0,cCombo:=u,cCombo)},aCodGrp,172,010,oGrp2,,,,CLR_BLACK,CLR_WHITE,.T.,,,,,,,,,"cCombo" )

oDlg2:Activate(,,,.T.)

Return

/*ÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Function  ³ MHoBrw1() - Monta aHeader da MsNewGetDados para o Alias:
ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
Static Function MHoBrw1()
Local nX		:= 0
Local cTitu     := ""
Local aCampos	:= {"C6_PRODUTO","C6_ITEM","C6_DESCRI","C6_QTDVEN","C6_QTDENT","C6_PRCVEN","C5_XENTREG","C5_XENTREF"}

DbSelectArea("SX3")
DbSetOrder(2)
For nX := 1 To Len(aCampos)
	If dbSeek(aCampos[nX])
		If aCampos[nX] == "C6_PRODUTO"
			cTitu := "Código"
		Endif
		If aCampos[nX] == "C6_ITEM"
			cTitu := "Item"
		Endif
		If aCampos[nX] == "C6_DESCRI"
			cTitu := "Descrição"
		Endif
		If aCampos[nX] == "C6_QTDVEN"
			cTitu := "Quantidade"
		Endif
		If aCampos[nX] == "C6_QTDENT"
			cTitu := "Qtd a Gerar"
		Endif
		If aCampos[nX] == "C6_PRCVEN"
			cTitu := "Preço"
		Endif
		If aCampos[nX] == "C5_XENTREG"
			cTitu := "Entr.Inicio"
		Endif
		If aCampos[nX] == "C5_XENTREF"
			cTitu := "Entr.Final"
		Endif
		
		noBrw1++
		Aadd(aHoBrw1,{cTitu,;
		SX3->X3_CAMPO,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		IIF(Alltrim(aCampos[nX]) <> "C6_QTDENT",SX3->X3_VALID,"U_ORTA642V()")  ,;
		"",;
		SX3->X3_TIPO,;
		"",;
		"" } )
	EndIf
Next nX

Return


**************************
Static Function fImpRel()
**************************
Local aRelator:={}
Local cMesg

_aItens:={}

for i:=1 to len(oBrw1:aCols)
	If !oBrw1:aCols[i][9]
		aadd(_aItens,{oBrw1:aCols[i][1],oBrw1:aCols[i][2], oBrw1:aCols[i][3],oBrw1:aCols[i][4],oBrw1:aCols[i][5],oBrw1:aCols[i][6],oBrw1:aCols[i][7],oBrw1:aCols[i][8],.F. })
	Endif
next

Asort(_aItens,,,{|x,y| x[2] < y[2]})

For _nImp := 1 to len(_aItens)
	
	If _aItens[_nImp][5]>0
		aAdd(aRelator,{_aItens[_NiMP][1], _aItens[_nImp][2]+SPACE(2), substr(_aItens[_nImp][3],1,25),Transform(_aItens[_nImp][5],"@E 9,999,999"),Transform(_aItens[_nImp][4]-_aItens[_nImp][5],"@E 9,999,999"),Transform(_aItens[_nImp][6],"@E 999,999.99"),"  "+dtoc(_aItens[_NiMP][7])+"  "," "+dtoc(_aItens[_NiMP][8])+" "})
	Endif
Next

If Len(aRelator) <=0
	Alert("Não existem itens a serem gerados")
	Return
Endif

// Verifica o Tp. Frete
DbSelectArea("SC5")
dbOrderNickName("PSC51")
If dbseek(xFilial("SC5")+cPed)
	// Pedido Entre Unidades
	If SC5->C5_XOPER <> "13"
		If SC5->C5_XOPER == "01"
			If Empty(cUnDest)
				If MsgBox("Este pedido será enviado para outra unidade produzir e entregar por Você?","ATENCAO","YESNO")
					lPedEun := .T.                                               
				Endif
			Else
				lPedEun := .T.
			Endif
		Endif
	Else
		lPedEun := .T.
	Endif
	
	If lPedEun .and. Empty(cUnDest)
		Alert("Pedido entre Unidades. Preencha o campo [Unidade Destino]!")
		Return
	Endif
	
	IF SUBSTR(cCifFob,1,1) == "C" .and. SC5->C5_TPFRETE == "F"
		Alert("Tipo de Frete não pode ser alterado de FOB para CIF")
		RETURN
	Endif

//	IF lPedEun .and. (cUnDest == cEmpAnt .or. !(AllTrim(cUnDest) $ "02/03/18/04/25/06/07/23/24/08/09/10/11/26/15/21/22"))
	IF lPedEun .and. (cUnDest == cEmpAnt .or. !(AllTrim(cUnDest) $ "02/03/18/04/05/06/07/23/24/08/09/10/11/26/15/21/22"))
		Alert("Unidade de destino é inválida!")
		RETURN
	Endif

	// Validação desconto IPI
	if lPedEun .and. cUnDest $ "21/22/23/24" .and. SC5->C5_XDESPRO $ "1/2"
		_cTexto := "O pedido lançado possui desconto do IPI e a unidade de destino não possui esta prática."
		_cTexto += " Ajustar o pedido para não haver desconrto para que o mesmo possa ser incluído!"
		MsgAlert(_cTexto)
		Return
	Endif					
Endif

U_ORTR538(nomeprog,"Relatório Itens a Gerar", {"CODIGO","ITEM","PRODUTO","QUANTIDADE","SALDO","PRECO","ENTR.INICIAL","ENTR.FINAL"}, aRelator, .F., .T.)

if !MsgBox("Deseja gerar um Pedido para os Produtos selecionados ?","ATENCAO","YESNO")
	Return()
else
	U_JobCInfo("ORTA642.PRW", "PEDIDO: '"+cPed+"' - GERADO PELO USUARIO '"+Alltrim(UsrRetName(__CUSERID))+"'", 1)
	Processa({|lEnd| fGravaPed(cPed)},"Gerando Pedido","Processando...")
Endif

Return


*-------------------------*
Static Function fGravaPed(cPedOrig)
*-------------------------*
Local cQry:=""
Local _aItens2:={}
Local nConta := 0
Private oSrv := Nil

nVolume := 0
nPesoN  := 0
nPed	:= 0

// Desmebramento não pode na sua totalidade
_nResta := 0
For _nImp := 1 to len(_aItens)
	If _aItens[_nImp][4] > 0
		_nResta += (_aItens[_nImp][4] - _aItens[_nImp][5])
	Endif
Next

If _nResta <= 0
	Alert("O Pedido não pode ser desmembrado na totalidade!")
	RETURN
Endif

nTotEspD := 0
For _nImp := 1 to len(_aItens)
	If _aItens[_nImp][5] > 0
		aAdd(_aItens2,{_aItens[_NiMP][1], _aItens[_nImp][2], _aItens[_nImp][3],_aItens[_nImp][4],_aItens[_nImp][5],_aItens[_nImp][6],_aItens[_nImp][7],_aItens[_nImp][8]})

		_nPosPro := 1 //aScan( aHeader, { |x| AllTrim ( x[2] ) == "C6_PRODUTO" } )
		_nB1XESP := POSICIONE("SB1",1,XFILIAL("SB1")+_aItens[_NiMP][_nPosPro],"B1_XESPACO")
		nTotEspD += (_nB1XESP * _aItens[_nImp][5])
	Endif	
Next
nTotEspD := ROUND(nTotEspD,2)
oTotEspD:Refresh()

If nTotEsp <> 0
	If nTotEspD > nTotEsp
		Alert("Limite do caminhão atingido neste desmembramento! Verifique!")
		RETURN
	Endif
Endif

If Len(_aItens2) >0
	_aItens:=_aItens2
Else
	Alert("O Pedido não pode ser desmembrado na totalidade, ou não foi selecionado quantidade a ser gerado")
	RETURN
Endif

For i:=1 to len(_aItens)
	cQry := "SELECT *  "
	cQry += "  FROM siga."+RetSqlName("SC5")+" SC5, siga."+RetSqlName("SC6")+" SC6, siga."+RetSqlName("SB1")+" SB1"
	cQry += " WHERE SC5.D_E_L_E_T_ = ' '   "
	cQry += "   AND SC6.D_E_L_E_T_ = ' '   "
	cQry += "   AND SB1.D_E_L_E_T_ = ' '   "
	cQry += "   AND C5_FILIAL = '"+xFilial("SC5")+"'"
	cQry += "   AND C6_FILIAL = '"+xFilial("SC6")+"'"
	cQry += "   AND B1_FILIAL = '"+xFilial("SB1")+"'"
	cQry += "   AND C5_NUM = C6_NUM     "
	cQry += "   AND C5_CLIENTE = C6_CLI "
	cQry += "   AND C6_PRODUTO = B1_COD "
	cQry += "   AND C5_NUM = '"+cPedOrig+"' "
	cQry += "   AND C6_PRODUTO = '"+_aItens[i][1]+"'"
	cQry += "   AND C6_ITEM = '"+_aItens[i][2]+"'"
	Memowrite("C:\ORTABJ.SQL", cQry)
	If Select("QRY") > 0
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf
	TcQuery cQry ALIAS "QRY" NEW
	dbSelectArea("QRY")
	dbGoTop()
	If EOF()
		MsgBox("Não existe para este pedido","Atencao")
		Return
	Else
		If nPed=0
			cCliente:= cCodCli //QRY->C5_CLIENTE
			cLoja	:= QRY->C5_LOJACLI
			cSegm   := QRY->C5_XTPSEGM
			cOper   := IIF(!lPedEun,QRY->C5_XOPER,"13")
			cCodtab := QRY->C5_TABELA
			cReftab := QRY->C5_XREFTAB
			cConPag := QRY->C5_CONDPAG
			cTpPgt  := QRY->C5_XTPPGT
			cPrzMed := QRY->C5_XPRZMED
			dEmissao:= STOD(QRY->C5_EMISSAO) //DDATABASE
			dDtLib  := STOD(QRY->C5_XDTLIB)  //DDATABASE
			dDtVen  := STOD(QRY->C5_XDTVEND) //DDATABASE
			cVend   := QRY->C5_VEND1
			nVol    := QRY->C5_VOLUME1
			nPeso   := QRY->C5_PESOL
			nPesBru := QRY->C5_PBRUTO
			cTpCarga:= QRY->C5_TPCARGA
			cPedClx := xPedClx // Campo de Relacionamento EUN
			cPedCli := xPedCli // QRY->C5_XPEDCLI
			cUn     := QRY->C5_XUNORI
			cTipoCli:= QRY->C5_TIPOCLI
			cTpFrete:= IIF(SUBSTR(cCifFob,1,1) <> QRY->C5_TPFRETE .and. QRY->C5_TPFRETE <> "F",SUBSTR(cCifFob,1,1),QRY->C5_TPFRETE)
			cDespro := QRY->C5_XDESPRO
			cCpfVen := QRY->C5_XCPFVEN
			cTxmoed := QRY->C5_TXMOEDA
			cFeirao := QRY->C5_XFEIRAO
			cMenpad := QRY->C5_MENPAD
			cXnpvor := QRY->C5_XNPVORT
			cLibero := QRY->C5_LIBEROK
			cTiplib := QRY->C5_TIPLIB
			cXespac := QRY->C5_XESPACO
			cXmix   := QRY->C5_XMIX
			cXregi  := QRY->C5_XREGIAO
			nVerRep := QRY->C5_XVERREP
			nVerExt := QRY->C5_XVEREXT
			cAprGf  := QRY->C5_XAPRGF
			cXTeleMk:= QRY->C5_XTELEMK
			cXobsadi:= QRY->C5_XOBSADI
			cXNicho := QRY->C5_XNICHO
			cProNum := QRY->C5_XPRONUM
			cC5_MENNOTA:=QRY->C5_MENNOTA // Henrique 09/03/2021 - SSI 112583
			// Buscar Verba de Repasse e Verba Extra do Cliente
/*
			DbSelectArea("SZH")
			DbSetorder(1)
			DbGoTOP()
			If DbSeek(XFILIAL("SZH")+cCliente+cLoja)//+cSegm)
				If SZH->ZH_VERBREP <> 0
					nVerRep := SZH->ZH_VERBREP
				Endif	
				If SZH->ZH_VERBEXT <> 0
					nVerExt := SZH->ZH_VERBEXT
				Endif	
			Endif
*/			
			GravaCab(.F.,"")
			dbSelectArea("QRY")
		Endif
		
		While !QRY->(EOF())
			nCont+=1
			
			//ALIMENTA AS VARIAVEIS PARA GRAVACAO DOS ITENS - SC6
			cProduto:= QRY->C6_PRODUTO
			If cCLiente <> QRY->C5_CLIENTE
				cEstCli  := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_EST")
				_aTes    := U_ORTA646T(cCliente, cLoja, cEstCli, QRY->C5_XOPER, cProduto)
				If !Empty(_aTes[1])
					cTes 	 := _aTes[1]
					cCFOP    := _aTes[2]
					cClasFis := _aTes[3]
				Else
					cTes 	:= QRY->C6_TES
					cCFOP   := QRY->C6_CF
					cClasFis:= QRY->C6_CLASFIS
				Endif
			Else
				cTes 	:= QRY->C6_TES
				cCFOP   := QRY->C6_CF
				cClasFis:= QRY->C6_CLASFIS
			Endif
			
			cDesc   := QRY->C6_DESCRI
			cObs    := QRY->C6_XOBS
			cUM     := QRY->C6_UM
			cSEGUM  := QRY->C6_SEGUM
			cMed    := QRY->C6_XMED
			cLocal  := QRY->C6_LOCAL
			
			cLoja	:= QRY->C6_LOJA
			cOper   := QRY->C6_XOPER
			nQtdVen := _aItens[I][5]
			If QRY->B1_TIPCONV == "M"
				nQtdSeg := _aItens[I][5] * QRY->B1_CONV
			ElseIf QRY->B1_TIPCONV == "D"
				nQtdSeg := _aItens[I][5] / QRY->B1_CONV
			Else
				nQtdSeg := _aItens[I][5]
			EndIf
			nPrcVen := QRY->C6_PRCVEN

			nPrcUni := QRY->C6_PRUNIT
			nDescont:= QRY->C6_DESCONT
			nValDesc:= (QRY->C6_VALDESC / QRY->C6_QTDVEN) * nQtdVen // Proporcional

*'Grava corretamente C6_XFEILOJ conforme quantidade (Bahia)'*
			nFeiLoj	:= 0
			If cEmpAnt $ "07/23/24" 
				If QRY->C6_XFEILOJ > 0
					nFeiLoj := ((nPrcUni * nQtdVen) * 11.828) / 100			
				Endif	
			Endif	
*'Grava corretamente C6_XFEILOJ conforme quantidade (Bahia)'*

			nValor  := nPrcVen * nQtdVen
			nCusto  := QRY->C6_XCUSTO
			nxPrcVen:= QRY->C6_XPRUNIT
			nzPrcVen:= QRY->C6_XPRCVEN
			nSaldo  := _aItens[I][4]-_aItens[I][5]
			nVolume += _aItens[I][5]
			nPesoN   += _aItens[I][5]*QRY->B1_PESO
			if !Empty(dEntreg) .or. !Empty(dEntref)
				if dEntreg <> _aItens[I][7] .or. dEntref <> _aItens[I][8]
					GravaCab(.F.,"")
					dbSelectArea("QRY")
				Endif
			Endif
			dEntrega:= STOD(QRY->C6_ENTREG)
			dEntreg := _aItens[I][7]
			dEntref := _aItens[I][8]
			GravaItem(cPedOrig, .t.)
			dbSelectArea("QRY")
			Dbskip()
		End
		
	Endif
Next
If nPed>0
	
	DbSelectArea("SC6")
	dbOrderNickName("PSC61")
	dbseek(xFilial("SC6")+cPedOrig)
	do while !eof() .and. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+cPedOrig
		nConta += SC6->C6_QTDVEN
		dbskip()
	enddo
	
	if nConta > 0
		DbSelectArea("SC5")
		dbOrderNickName("PSC51")
		If dbseek(xFilial("SC5")+cPedOrig)
			/*
			Reclock("SC5",.F.)
			SC5->C5_VOLUME1:= nVolume
			SC5->C5_PESOL  := nPesoN
			SC5->C5_PBRUTO := nPesoN
			If nSaldo = 0
			SC5->C5_XOPER:="99"
			SC5->C5_XOBSCAN:="PEDIDO MAE UTILIZADO NA TOTALIDADE"
			Endif
			msunlock()
			*/
		Endif
	Endif
	nConta := 0
Endif

U_ORTR538(nomeprog,"Pedidos Gerados", {"PEDIDO","PRODUTO","QTD   ","PRECO ","ENTR.INICIAL","ENTR.FINAL"}, aRelImp, .F., .T.)
aRelImp		:={}
aCoBrw1		:={{"","","",0,0,0,ctod("  /  /  "),ctod("  /  /  "),.F.}}
cPed		:=SPACE(6)
cCodCli     :=SPACE(6)
nCont		:=0
oBrw1:aCols := aCoBrw1
oBrw1:oBrowse:Refresh(.t.)
oDlg1:Refresh()


*'Importação pedidos - Márcio Sobreira -------------------------------------------------------------'*
dbselectarea("SC5")
dbsetorder(1)
dbgotop()
If dbseek(xFilial("SC5")+cPedOrig)
	_cPedClx := AllTrim(SC5->C5_XPEDCLX)
	If !Empty(_cPedClx)
		// Localiza a Unidde de Origem
		cUnOri  := SC5->C5_XUNORI
		If !Empty(cUnOri)
			_cRetx  := ""
			cCnpj	 := ""
			If cCliente <> SC5->C5_CLIENTE
				cCnpj	 := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_CGC") // Só envia o CNPJ se Cliente for Diferente
			Endif
			
			aIps:=U_FRetUnidades()
			//	 		aIps:=FRetUnidades() 					// Márcio - Recolocar esta Linha
			nPos:= aScan(aIps,{|x| x[1]==cUnOri})
			if nPos==0
				Alert("Unidade de origem Invalida")
				Return()
			Else
				oSrv:=rpcconnect(aIps[nPos,2], aIps[nPos,3], aIps[nPos,4], aIps[nPos,5], aIps[nPos,6])
				if valtype(oSrv)=="O"
					_cRetx := oSrv:CallProc( 'U_ORTA658', _aItens, _cPedClx, cCnpj)
					rpcdisconnect(oSrv)
				Else
					Alert("Problemas na conexao com a unidade "+aIps[nPos,1])
				Endif
			Endif
			
			//			_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA658",{_aItens,_cPedCli},.T.) // Não envia Array
			//			_lRetx  := U_ORTA658(_aItens, _cPedCli)
			If !Empty(_cRetx)
				dbselectarea("SC5")
				dbsetorder(1)
				dbgotop()
				If dbseek(xFilial("SC5")+cNumPed)
					If RecLock("SC5",.F.)
						SC5->C5_XPEDCLX := _cRetx
						SC5->(MsUnLock())
					Endif
				Endif
				Aviso("Atenção", "Desmembramento realizado com sucesso no Pedido ["+_cPedClx+"] da Empresa Origem ["+cUnOri+"]", { "Sair" } )
			Else
				Aviso("Atenção", "Desmembramento não realizado no Pedido ["+_cPedClx+"] da Empresa Origem ["+cUnOri+"]", { "Sair" } )
			Endif
		Endif
	Endif
Endif
*'--------------------------------------------------------------------------------------------------'*

_fGeraSZK("AP", cPedOrig, .T., cNumped)

// Tratativa Simbahia para a UN07
If cEmpAnt == "07"
	
	_fGeraSZK("SB", cPedOrig, .T., cNumped)
	
Endif
//

*'- Atualização da Tabela SZE ----------------------------------------------------------------------'*
dbselectarea("SC5")
dbsetorder(1)
dbgotop()
If dbseek(xFilial("SC5")+cPedOrig)
	_aDados := fBuscSZE(SC5->C5_CLIENTE, SC5->C5_NUM)
	
	//ZE_AUTORIZ, ZE_USUARIO, ZE_DTAUT, ZE_OBS, ZE_MEDTRI, ZE_MED30D, ZE_VALPED, ZE_ULTMES, ZE_CUSTRI, ZE_CUSMD30, ZE_CUSPED, ZE_CUSULTM
	If Len(_aDados) > 0
		For _Nz := 1 to len(_aDados)
			reclock("SZE",.T.)
			SZE->ZE_FILIAL  := XFILIAL("SZE")
			SZE->ZE_PEDIDO  := cNumped
			
			SZE->ZE_AUTORIZ := _aDados[_Nz,1]
			SZE->ZE_USUARIO := _aDados[_Nz,2]
			SZE->ZE_DTAUT   := STOD(_aDados[_Nz,3])
			SZE->ZE_OBS     := _aDados[_Nz,4]
			SZE->ZE_MEDTRI	:= _aDados[_Nz,5]
			SZE->ZE_MED30D	:= _aDados[_Nz,6]
			SZE->ZE_VALPED	:= _aDados[_Nz,7]
			SZE->ZE_ULTMES	:= _aDados[_Nz,8]
			SZE->ZE_CUSTRI	:= _aDados[_Nz,9]
			SZE->ZE_CUSMD30	:= _aDados[_Nz,10]
			SZE->ZE_CUSPED	:= _aDados[_Nz,11]
			SZE->ZE_CUSULTM	:= _aDados[_Nz,12]
			
			SZE->(msunlock())
		Next
	Endif
Endif
*'--------------------------------------------------------------------------------------------------'*
Return

***************************
Static Function GravaCab(lDev, cPedDev)
***************************
Local aArea := GetArea()
If nPed=0
	cNumPed:=GetSXENum("SC5")
	DbSelectArea("SC5")
	dbOrderNickName("PSC51")
	dbseek(xFilial("SC5")+cNumPed)
	do while found()
		confirmSX8()
		cNumPed:=GetSXENum("SC5")
		dbgotop()
		dbseek(xFilial("SC5")+cNumPed)
	enddo
Endif
Reclock("SC5",.T.)
SC5->C5_FILIAL :=xFilial("SC5")
SC5->C5_NUM    :=cNumPed
SC5->C5_TIPO   :="N"
SC5->C5_CLIENTE:=cCliente
SC5->C5_CLIENT :=cCliente
SC5->C5_LOJACLI:=cLoja
SC5->C5_LOJAENT:=cLoja
SC5->C5_XTPSEGM:=cSegm
SC5->C5_XOPER  :=cOper
SC5->C5_TABELA :=cCodTab
SC5->C5_XREFTAB:=cRefTab
SC5->C5_CONDPAG:=cConPag
SC5->C5_XTPPGT :=cTpPgt
SC5->C5_XPRZMED:=cPrzMed
SC5->C5_VEND1  :=cVend
SC5->C5_TIPOCLI:=cTipoCli
SC5->C5_TPCARGA:=cTpCarga
SC5->C5_XNREPOR:=.F.
SC5->C5_MOEDA  := 1
SC5->C5_XPEDCLX:=xPedClx
SC5->C5_XPEDCLI:=cPedCli
SC5->C5_TPFRETE:=cTpFrete
SC5->C5_XPEDFIC:=cNumPed
SC5->C5_EMISSAO:= dEmissao //DDATABASE
SC5->C5_XDTVEND:= dDtVen   //DDATABASE
SC5->C5_XDTLIB := dDtLib   //DDATABASE
SC5->C5_ESPECI1:="UNIDADE"
IF !lDev // SE NAO FOR PEDIDO DEVOLVIDO
   If cEmpAnt == "22" .and. SUBSTR(cXobsadi,1,5) == "ORTP1" // Processo automatico importação AllFibra
	  SC5->C5_XOBSADI := cXobsadi
   Else
	  SC5->C5_XOBSADI:="ORTA642 - PEDIDO DESMEMBRADO - PEDIDO ORIGINAL - " + cPed
   Endif
	SC5->C5_XPEDDES:=cPed
	SC5->C5_MENNOTA:="PEDIDO ORIGINAL - " + cPed
ELSE
    SC5->C5_MENNOTA:=cC5_MENNOTA // Henrique 09/03/2021 - SSI 112583
	SC5->C5_XPEDFIC:=cPedFic
	SC5->C5_XOBSADI:="PEDIDO DEVOLVIDO - " + cPedDev
	SC5->C5_XPEDDES:=cNumDev // nao preencha
	SC5->C5_XOBSCAN:="GERADO ATRAVÉS DA DEVOLUÇÃO DO PEDIDO: " + cPedDev
ENDIF
SC5->C5_XNICHO := cXNicho
SC5->C5_VOLUME1:= nVol
SC5->C5_PESOL  := nPeso
SC5->C5_PBRUTO := nPesBru
If !(cEmpAnt $ "24")  		//SSI 123429
	SC5->C5_XUNORI := cUn
EndIf
SC5->C5_XESPACO:= 1
SC5->C5_XDESPRO:= cDespro
SC5->C5_XCPFVEN:= cCpfVen
SC5->C5_TXMOEDA:= cTxmoed

SC5->C5_XFEIRAO	:= cFeirao
SC5->C5_MENPAD	:= cMenpad
SC5->C5_XNPVORT	:= cXnpvor
SC5->C5_LIBEROK	:= cLibero
SC5->C5_TIPLIB	:= cTiplib
SC5->C5_XESPACO	:= cXespac
SC5->C5_XMIX	:= cXmix
SC5->C5_XREGIAO	:= cXregi

// Verba Repasse e Extra
SC5->C5_XVERREP := nVerRep
SC5->C5_XPRONUM := cProNum
SC5->C5_XVEREXT := nVerExt

SC5->C5_XMENPA2:=Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_MENSAGE")
// Grava pedidos entre Unidades
SC5->C5_XUNDEST := cUnDest
SC5->C5_XAPRGF  := cAprGf
SC5->C5_XTELEMK := cXTeleMk
*'Não vai para Quarentena se desmembrado'*
SC5->C5_XQUAREN := "2"
*'Não vai para Quarentena se desmembrado'*

nPed++
msunlock()
confirmSX8()

RestArea( aArea )

RETURN

********************************
Static Function GravaItem(cPedO,lAtu)
********************************
Local aArea := GetArea()

DbSelectArea("SC6")
RecLock("SC6",.T.)
SC6->C6_FILIAL :=xFilial("SC6")
SC6->C6_NUM    :=cNumped
SC6->C6_ITEM   :=Strzero(nCont,2)
SC6->C6_PRODUTO:=cProduto
SC6->C6_DESCRI :=cDesc
SC6->C6_UM     :=cUM
SC6->C6_SEGUM  :=cSEGUM
SC6->C6_QTDVEN :=nQtdVen
SC6->C6_XCUSTO :=nCusto
SC6->C6_XPRUNIT:=round(nxPrcVen,4)
SC6->C6_LOCAL  :=cLocal
SC6->C6_TES    :=cTes
SC6->C6_CF     :=cCFOP
SC6->C6_CLASFIS:=cClasFis
SC6->C6_CLI    :=cCliente
SC6->C6_LOJA   :=cLoja
SC6->C6_XOPER  :=cOper
Sc6->C6_PEDCLI :=cPedCli
SC6->C6_VALOR  := nQtdVen * round(nPrcVen,4)
SC6->C6_XMIX   :=U_FMIX(nPrcVen,SC6->C6_XCUSTO)
SC6->C6_XMARKUP:=U_FMKP(nPrcVen,SC6->C6_XCUSTO)
SC6->C6_XPRCVEN:=round(nzPrcVen,4)
SC6->C6_PRCVEN :=round(nPrcVen,4)

SC6->C6_PRUNIT :=round(nPrcUni,4)
SC6->C6_DESCONT:=nDescont
SC6->C6_VALDESC:=nValDesc 

*'Grava corretamente C6_XFEILOJ conforme quantidade (Bahia)'*
If cEmpAnt $ "07/23/24"
	SC6->C6_XFEILOJ := nFeiLoj
Endif
*'Grava corretamente C6_XFEILOJ conforme quantidade (Bahia)'*

SC6->C6_UNSVEN :=nQtdSeg
SC6->C6_XMED   :=cMed
SC6->C6_ENTREG := dEntrega //DDATABASE
SC6->C6_TPOP   := "F"
SC6->C6_XOBS   := cObs
SC6->(msunlock())

dbselectarea("SC5")
dbsetorder(1)
If dbseek(xFilial("SC5")+cNumPed)
	reclock("SC5",.F.)
	SC5->C5_XENTREG:=dEntreg
	SC5->C5_XENTREF:=dEntreF
	SC5->C5_XQUAREN:='2'
	MsUnlock()
Endif                                                                                               
aadd(aRelImp, {cNumPed,cProduto,Transform(nQtdVen,"@E 999,999"),Transform(round(nPrcVen,2),"@E 9,999.99"),"  "+dtoc(dEntreg)+"  "," "+dtoc(dEntref)+" "})

//ATUALIZA ITEM DO PEDIDO MAE
if lAtu
	// Posiciona no Produto
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbGoTop()
	DbSeek(XFILIAL("SB1")+cProduto)

	DbSelectArea("SC6")
	dbOrderNickName("PSC62")
	If dbseek(xFilial("SC6")+cProduto+cPedO)
		RecLock("SC6",.F.)
//		SC6->C6_VALDESC:= (SC6->C6_VALDESC / SC6->C6_QTDVEN) * (SC6->C6_QTDVEN - nQtdVen)
		SC6->C6_QTDVEN := (SC6->C6_QTDVEN - nQtdVen) //nSaldo
		
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
		
		SC6->C6_VALOR  := SC6->C6_QTDVEN * SC6->C6_PRCVEN
*'Passa a Deletar caso toda quantidade do produto seja utilizada - 10/05/21 - DUPIM'*
		If SC6->C6_QTDVEN <= 0
			SC6->(DbDelete())
		Endif
*'Passa a Deletar caso toda quantidade do produto seja utilizada - 10/05/21 - DUPIM'*
		SC6->(msunlock())
*'---------------------------------------------------------------------------------------------------------------------------'*
If cEmpAnt == "22" .and. SUBSTR(cXobsadi,1,5) == "ORTP1" // Processo automatico importação AllFibra
		// Ajusa PEDIDOALL com desemembramento /////////////////////////////////////////////////////////////////////
		// (UN, NUMSC522, NUMSC5  , NUMSC7 , COD        , QTDVEN,  CUSTO)

		cQuery:="SELECT * FROM PEDIDOALL WHERE UN = '"+cUn+"' AND NUMSC522 = '"+cPedO+"' AND RTRIM(COD) = '"+Alltrim(cProduto)+"' "
		cQuery+="ORDER BY QTDVEN "
		CONOUT("cQuery PEDIDOAL_SELECT: " + cQuery)                         
		cTrb := MpSysOpenQuery(cQuery)
		
        _aLinhas := {}
		While !(cTrb)->(EOF()) 
			AADD(_aLinhas,{(cTrb)->UN, (cTrb)->NUMSC522, (cTrb)->NUMSC5, (cTrb)->NUMSC7, (cTrb)->COD, (cTrb)->QTDVEN, (cTrb)->CUSTO})
			(cTrb)->(DbSkip())
		End
		(cTrb)->(DbCloseArea())
		
		//cPedO   = Pedido N
		//cNumped = Pedido desmembrado
		//nQtdVen = Qtd. Item Pedido desmembrado
		//cProduto= Produto

		_nQtdPrc := 0 // Quantidade Processada		
		_nQtdInc := 0 // Quantidade a ser incluida
		For _Nm := 1 to Len(_aLinhas)
			_nQtdPrc += _aLinhas[_Nm,6]
			If _nQtdPrc <= nQtdVen
				Begin Transaction
					// (UN, NUMSC522, NUMSC5  , NUMSC7 , COD        , QTDVEN,  CUSTO)
					cQuery := " UPDATE PEDIDOALL  "
					cQuery += " SET NUMSC522 = '"+cNumPed+"' " //', CUSTO = "+AllTrim(Str(_aItens[J,5]))
					cQuery += " WHERE RTRIM(NUMSC5) = '"+AllTrim(_aLinhas[_Nm,3])+"' AND "
					cQuery += " RTRIM(COD) = '"+AllTrim(_aLinhas[_Nm,5])+"' AND "
					cQuery += " UN = '"+cUn+"' "
					
					CONOUT("cQuery UPDATE :" + cQuery)
					TcSqlExec(cQuery)
				End Transaction				 
			Else
				Begin Transaction
					// (UN, NUMSC522, NUMSC5  , NUMSC7 , COD        , QTDVEN,  CUSTO)
					_nQtdAlt := nQtdVen - (_nQtdPrc - _aLinhas[_Nm,6]) 
					cQuery := " UPDATE PEDIDOALL  "
					cQuery += " SET NUMSC522 = '"+cNumPed+"' , QTDVEN = " +Transform(_nQtdAlt,"999999999.99")
					cQuery += " WHERE RTRIM(NUMSC5) = '"+AllTrim(_aLinhas[_Nm,3])+"' AND "
					cQuery += " RTRIM(COD) = '"+AllTrim(_aLinhas[_Nm,5])+"' AND "
					cQuery += " UN = '"+cUn+"' "
					
					CONOUT("cQuery UPDATE :" + cQuery)
					TcSqlExec(cQuery)
				End Transaction				 

				_nQtdInc := _nQtdPrc - nQtdVen
			Endif	

			If _nQtdInc > 0                                                       
				Begin Transaction
					// (UN, NUMSC522, NUMSC5  , NUMSC7 , COD        , QTDVEN,  CUSTO)
					cQuery:="INSERT INTO PEDIDOALL (UN, NUMSC522, NUMSC5, NUMSC7, COD, QTDVEN, CUSTO) VALUES ('"+_aLinhas[_Nm,1]+"','"+_aLinhas[_Nm,2]+"','"
					cQuery+=_aLinhas[_Nm,3]+"','"+_aLinhas[_Nm,4]+"','"+_aLinhas[_Nm,5]+"',"+Transform(_nQtdInc,"999999999.99")+","
					cQuery+=Transform(_aLinhas[_Nm,7],"999999999.99")+")"  
		
					CONOUT("cQuery INSERT :" + cQuery)
					TcSqlExec(cQuery)
				End Transaction		
				Exit // Assim que inserir um alinha, irá sair 
			Endif		
			
			// Se Já Ajuste PEDIDOAL por completo, sai.
			If nQtdVen == _nQtdPrc
				Exit			
			Endif			
		Next
Endif
*'---------------------------------------------------------------------------------------------------------------------------'*
	Else
		Alert("ERRO NA ATUALIZACAO DO PEDIDO ORIGINAL")
	Endif
Endif

RestArea( aArea )

return

// ========================================|
// RECRIA OS PEDIDOS DEVOLVIDOS            |
// ========================================|

User Function ORTA642G(_cEmbarq)
Local cQuery 	:= ""
Local aArea		:= GetArea()
Private aRelImp := {}
Private _c5Num	:= ""
private cCliente:= ""
private cLoja	:= ""
private cSegm   := ""
private cOper   := ""
private cCodtab := ""
private cReftab := ""
private cConPag := ""
private cTpPgt  := ""
private cPrzMed := ""
private dEmissao:= DDATABASE
private dEntrega:= DDATABASE
private cVend   := ""
private nVol    := 0
private nPeso   := 0
private nPesBru := 0
private cTpCarga:= ""
private cPedCli := ""
private xPedCli := ""
private cUn     := ""
private cTipoCli:= ""
private cTpFrete:= ""
private cDespro := ""
private cCpfVen := ""
private cTxmoed := ""
private cFeirao := ""
private cMenpad := ""
private cXnpvor := ""
private cLibero := ""
private cTiplib := ""
private cXespac := ""
private cXmix   := ""
private cXregi  := ""
//
Private cProduto:= ""
Private cDesc   := ""
Private cObs    := ""
Private cUM     := ""
Private cSEGUM     := ""
Private cMed    := ""
Private cTes 	:= ""
Private cLocal  := ""
Private cCFOP   := ""
Private cLoja	:= ""
Private cOper   := ""
Private nQtdVen := 0
Private nQtdSeg := 0
Private nPrcVen := 0

Private nPrcUni := 0
Private nDescont:= 0
Private nValDesc:= 0

Private nValor  := 0
Private nCusto  := 0
Private nxPrcVen:= 0
Private nzPrcVen:= 0
Private nVolume := 0
Private nPesoN  := 0
//
Private nCont   := 0
Private nPed    := 0
Private cNumped := ""
Private cNumDev := ""
Private cPedFic	:= ""


cQuery	:= " SELECT * "
cQuery	+= "   FROM SIGA."+RetSqlName("SC5")+" SC5, "
cQuery	+= "        SIGA."+RetSqlName("SC6")+" SC6, "
cQuery	+= "        SIGA."+RetSqlName("SB1")+" SB1, "
cQuery	+= "        SIGA."+RetSqlName("SD2")+" SD2 "
cQuery	+= "  WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SC6.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SB1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SD2.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND C5_FILIAL 	= '"+xFilial("SC5")+"' "
cQuery	+= "    AND C6_FILIAL 	= '"+xFilial("SC6")+"' "
cQuery	+= "    AND B1_FILIAL 	= '"+xFilial("SB1")+"' "
cQuery	+= "    AND D2_FILIAL 	= '"+xFilial("SD2")+"' "
cQuery	+= "    AND C6_NUM		= C5_NUM     "
cQuery	+= "    AND D2_PEDIDO	= C6_NUM     "
cQuery	+= "    AND B1_COD		= C6_PRODUTO "
cQuery	+= "    AND D2_ITEMPV	= C6_ITEM    "
cQuery	+= "    AND D2_QTDEDEV 	> 0 "
cQuery	+= "  	AND C5_XTPSEGM IN ('1','2') "
cQuery	+= "    AND C5_XEMBARQ 	= '"+_cEmbarq+"' "
cQuery	+= " ORDER BY C5_FILIAL, C5_NUM, C6_ITEM "

U_ORTQUERY(cQuery, "ORTA034R")

While !(ORTA034R->(EOF()))
	
	_c5Num	:= ORTA034R->C5_NUM
	
	cCliente:= ORTA034R->C5_CLIENTE
	cLoja	:= ORTA034R->C5_LOJACLI
	cSegm   := ORTA034R->C5_XTPSEGM
	cOper   := ORTA034R->C5_XOPER
	cCodtab := ORTA034R->C5_TABELA
	cReftab := ORTA034R->C5_XREFTAB
	cConPag := ORTA034R->C5_CONDPAG
	cTpPgt  := ORTA034R->C5_XTPPGT
	cPrzMed := ORTA034R->C5_XPRZMED
	dEmissao:= ORTA034R->C5_XPRZMED //DDATABASE
	dDtLib  := ORTA034R->C5_XDTLIB  //DDATABASE
	cVend   := ORTA034R->C5_VEND1
	nVol    := ORTA034R->C5_VOLUME1
	nPeso   := ORTA034R->C5_PESOL
	nPesBru := ORTA034R->C5_PBRUTO
	cTpCarga:= ORTA034R->C5_TPCARGA
	cPedClx := xPedClx
	cPedCli := ORTA034R->C5_XPEDCLI
	cUn     := ORTA034R->C5_XUNORI
	cTipoCli:= ORTA034R->C5_TIPOCLI
	cTpFrete:= ORTA034R->C5_TPFRETE
	cDespro := ORTA034R->C5_XDESPRO
	cCpfVen := ORTA034R->C5_XCPFVEN
	cTxmoed := ORTA034R->C5_TXMOEDA
	cFeirao := ORTA034R->C5_XFEIRAO
	cMenpad := ORTA034R->C5_MENPAD
	cXnpvor := ORTA034R->C5_XNPVORT
	cLibero := ORTA034R->C5_LIBEROK
	cTiplib := ORTA034R->C5_TIPLIB
	cXespac := ORTA034R->C5_XESPACO
	cXmix   := ORTA034R->C5_XMIX
	cXregi  := ORTA034R->C5_XREGIAO
	cNumDev := ORTA034R->C5_XPEDDES
	cPedFic := ORTA034R->C5_XPEDFIC
	GravaCab(.T.,ORTA034R->C5_NUM)
	
	dbSelectArea("ORTA034R")
	// VARRE OS ITENS DO C5/C6 PARA O PEDIDO
	While ORTA034R->C5_NUM == _c5Num
		nCont+=1
		cProduto:= ORTA034R->C6_PRODUTO
		cDesc   := ORTA034R->C6_DESCRI
		cUM     := ORTA034R->C6_UM
		cSEGUM  := ORTA034R->C6_SEGUM
		cMed    := ORTA034R->C6_XMED
		cTes 	:= ORTA034R->C6_TES
		cLocal  := ORTA034R->C6_LOCAL
		cCFOP   := ORTA034R->C6_CF
		cLoja	:= ORTA034R->C6_LOJA
		cOper   := ORTA034R->C6_XOPER
		nQtdVen := ORTA034R->D2_QTDEDEV // #
		If ORTA034R->B1_TIPCONV == "M"
			nQtdSeg := ORTA034R->D2_QTDEDEV * ORTA034R->B1_CONV
		ElseIf ORTA034R->B1_TIPCONV == "D"
			nQtdSeg := ORTA034R->D2_QTDEDEV / ORTA034R->B1_CONV
		Else
			nQtdSeg := ORTA034R->D2_QTDEDEV
		EndIf
		nPrcVen := ORTA034R->C6_PRCVEN

		nPrcUni := ORTA034R->C6_PRUNIT
		nDescont:= ORTA034R->C6_DESCONT
		nValDesc:= (ORTA034R->C6_VALDESC / ORTA034R->C6_QTDVEN) * nQtdVen

		nValor  := nPrcven * nQtdVen
		nCusto  := ORTA034R->C6_XCUSTO
		nxPrcVen:= ORTA034R->C6_XPRUNIT
		nzPrcVen:= ORTA034R->C6_XPRCVEN
		nVolume += ORTA034R->D2_QTDEDEV // #
		nPesoN  += ORTA034R->D2_QTDEDEV*ORTA034R->B1_PESO// #
		cObs    := ORTA034R->C6_XOBS
		GravaItem("", .f.)
		dbSelectArea("ORTA034R")
		ORTA034R->(dbSkip())
	EndDo
	
	// ATUALIZA O VOLUME E PESO DO PEDIDO
	// DEPOIS DE CRIAR OS ITENS
	nCont:= 0
	DbSelectArea("SC5")
	dbOrderNickName("PSC51")
	If dbseek(xFilial("SC5")+cNumPed)
		Reclock("SC5",.F.)
		SC5->C5_VOLUME1	:= nVolume
		SC5->C5_PESOL	:= nPesoN
		SC5->C5_PBRUTO	:= nPesoN
		msunlock()
	Endif
	nPed := 0
	//ORTA034R->(dbSkip())
EndDo

ORTA034R->(dbCloseArea())     

RestArea(aArea)
Return


*------------------------------------------*
Static Function FRetUnidades( _aIPs, _nPorta, _cAmb )

*------------------------------------------*
//Default _nPorta := 1235
Default _aIPs   := {}
Default _cAmb   := " "

//Lista de Servidores Remotos ( Unidades )
aAdd( _aIPs, { "03", "10.0.100.76", _nPorta, "ORTORJ" , "03", "02", "Rio de Janeiro	","RJ", "RJ" } )
aAdd( _aIPs, { "18", "10.0.100.76", _nPorta, "ORTORJ" , "18", "02", "Queimados		","RJ", "QM" } )
if !Empty(_cAmb)
	for i:=1 to Len(_aIPs)
		_aIps[i,4]:=_cAmb
	Next
Endif
Return _aIPs

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function ORTA642V()
Local _aArea     := GetArea()
Local _lRet      := .T.
Local _nQuant    := M->C6_QTDENT
Local _nPosQtd	 := aScan( aHeader, { |x| AllTrim ( x[2] ) == "C6_QTDVEN" } )
Local _nPosEnt	 := aScan( aHeader, { |x| AllTrim ( x[2] ) == "C6_QTDENT" } )
Local _nPosPro	 := aScan( aHeader, { |x| AllTrim ( x[2] ) == "C6_PRODUTO" } )

nTotEspD := 0
For _Nx:= 1 to Len(aCols)
	If !oBrw1:aCols[_Nx][9]
		_nB1XESP := POSICIONE("SB1",1,XFILIAL("SB1")+aCols[_Nx,_nPosPro],"B1_XESPACO")
		nTotEspD += (_nB1XESP * If(_Nx <> n, aCols[_Nx,_nPosEnt],_nQuant))
	Endif	
Next
nTotEspD := ROUND(nTotEspD,2)
oTotEspD:Refresh()

// Valida se quantidade é maior do que a disponpivel
If _nQuant > aCols[n,_nPosQtd] .or. _nQuant < 0
	Aviso( "Atenção", "Quantidade Digitada maior do que a disponível!", { "Ok" } )
	_lRet    := .F.
Endif

RestArea(_aArea)
Return(_lRet)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fMudaGrp
//Alert("Teste")
Return(.T.)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fBuscCli(_cCodigo)
Local _aRet := {}

// Somente o proprio codigo
_cQryCli	:=	" SELECT DISTINCT A1_COD, A1_NOME "
_cQryCli    +=  " FROM "+RetSqlName("SA1")+" SA1 "
_cQryCli    +=  " WHERE A1_FILIAL    = '"+xFilial("SA1")+"' "
_cQryCli    +=  " AND SA1.D_E_L_E_T_ = ' ' "
_cQryCli    +=  " AND SA1.A1_COD = '"+ _cCodigo     +"' "

_cQryCli    +=  " UNION ALL "

// Clientes que ele está como GRUPO
_cQryCli	+=	" SELECT DISTINCT A1_COD, A1_NOME	"
_cQryCli    +=  " FROM "+RetSqlName("SA1")+" SA1 "
_cQryCli    +=  " WHERE A1_FILIAL    = '"+xFilial("SA1")+"' "
_cQryCli    +=  " AND SA1.D_E_L_E_T_ = ' ' "
_cQryCli    +=  " AND SA1.A1_MSBLQL <> '1' "
_cQryCli    +=  " AND (SA1.A1_XCODGRU = '"+ _cCodigo     +"' "
_cQryCli    +=  " AND SA1.A1_COD <> '"+ _cCodigo     +"') "

_cQryCli    +=  " UNION ALL "

// Clientes que o Cod. do Grupo dele está como GRUPO
_cQryCli	+=	" SELECT DISTINCT A1_COD, A1_NOME "
_cQryCli    +=  " FROM "+RetSqlName("SA1")+" SA1 "
_cQryCli    +=  " WHERE A1_FILIAL    = '"+xFilial("SA1")+"' "
_cQryCli    +=  " AND SA1.D_E_L_E_T_ = ' ' "
_cQryCli	+=	" AND SA1.A1_XCODGRU = (SELECT SAX.A1_XCODGRU "
_cQryCli    +=  " 						FROM "+RetSqlName("SA1")+" SAX "
_cQryCli	+=	"                       WHERE SAX.A1_FILIAL = '  ' "
_cQryCli	+=	"                       AND SAX.D_E_L_E_T_  = ' ' "
_cQryCli	+=	"                       AND SAX.A1_COD = '"+ _cCodigo     +"')"
_cQryCli    +=  " AND SA1.A1_COD <> '"+ _cCodigo     +"' "

MEMOWRIT("C:\AAA\FBUSCCLI.SQL",_cQryCli)
If Select("RETCLI") > 0
	dbSelectArea("RETCLI")
	dbCloseArea()
EndIf
TCQUERY _cQryCli ALIAS "RETCLI" NEW

DbSelectArea("RETCLI")

//AADD(_aRet,_cCodigo)
While !RETCLI->(eof())
	AADD(_aRet,RETCLI->A1_COD + " - " + AllTrim(RETCLI->A1_NOME))
	RETCLI->(DbSkip())
End

Return(_aRet)

*************************************
Static Function fBuscSZE(_cCliente, _cNumero)
*************************************
Local _aRet  := {}
Local _aArea := GetArea()

cQuerySZE := " SELECT * "
cQuerySZE += " FROM  " + RetSqlName("SZE") + " "
cQuerySZE += " WHERE ZE_FILIAL = '"+XFILIAL("SZE")+"' "
cQuerySZE += " AND D_E_L_E_T_  = ' ' "
cQuerySZE += " AND ZE_PEDIDO   = '" + _cNumero + "' "

CONOUT("cQuerySZE: " + cQuerySZE)
memowrite("c:\aaa\fBuscSZE.SQL",cQuerySZE)

IF SELECT("TMPSZE") > 0
	DBSELECTAREA("TMPSZE")
	DBCLOSEAREA()
ENDIF

TcQuery cQuerySZE ALIAS "TMPSZE" NEW

While !TMPSZE->(EOF())
	AADD(_aRet,{TMPSZE->ZE_AUTORIZ, TMPSZE->ZE_USUARIO, TMPSZE->ZE_DTAUT, TMPSZE->ZE_OBS, TMPSZE->ZE_MEDTRI, TMPSZE->ZE_MED30D, TMPSZE->ZE_VALPED,;
	TMPSZE->ZE_ULTMES, TMPSZE->ZE_CUSTRI, TMPSZE->ZE_CUSMD30, TMPSZE->ZE_CUSPED, TMPSZE->ZE_CUSULTM})
	TMPSZE->(dbSkip())
End

dbCloseArea("TMPSZE")

RestArea(_aArea)
Return(_aRet)

/*/{Protheus.doc} fGeraSZK

//TODO Função auxiliar criada para retornar determinado
tipo de registro da tabela SZK, ou gerar um novo
registro.

@author Peder Munksgaard
@since 05/09/2018
@version 1.0
@return ${return}, ${"Se _lGera, retorno lógico, senão retorno array"}
@param _cOper  , , Operação desejada da SZK (ZK_OPERAC)
@param _cNumPed, , Número do pedido de vendas (ZK_PEDIDO)
@param _lGera  , , Gera novo registro na SZK?
@param _cNewPed, , Número do novo pedido de vendas a ser gerado (ZK_PEDIDO)
@type function
/*/
Static Function _fGeraSZK(_cOper, _cNumPed, _lGera, _cNewPed)

Local   _xRet

Local   _aArea   := GetArea()
Local   _aStru   := SZK->(dbStruct())

Local   _cQry    := ""
Local   _cTrb    := ""
Local   _cNItem  := ""

Local   _nX      := 0
Local   _nVlNped := 0
Local   _nVlOped := 0
Local   _nVlDped := 0

Default _cOper   := "AP"
Default _cNumPed := ""
Default _lGera   := .F.
Default _cNewPed := ""

If (!Empty(_cNumPed) .And. !_lGera) .Or. (!Empty(_cNumPed) .And. _lGera .And. !Empty(_cNewPed))
	
	If _lGera
		
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
		_cQry += " AND   SC5.C5_XOPER   NOT IN ('99','98')                                                       " + CRLF
		_cQry += " AND   SC5.C5_NUM     = '" + _cNewPed + "'                                                     " + CRLF
		_cQry += " AND   SC5.C5_NUM     = SC6.C6_NUM                                                             " + CRLF
		_cQry += " AND   SC5.C5_FILIAL  = SC6.C6_FILIAL                                                          " + CRLF
		_cQry += " AND   SC5.C5_FILIAL  = '" + FWxFilial("SC5") + "'                                             " + CRLF
		
		_cTrb := MpSysOpenQuery(_cQry)
		
		_nVlNped := (_cTrb)->VALOR
		
		_nVlDped := Abs(_nVlOped - _nVlNped)
		
	Endif
	
	_cQry := "SELECT MAX(ZK_ITEM) MAXIT FROM " + RetSqlName("SZK") + " SZK " + CRLF
	_cQry += "WHERE SZK.D_E_L_E_T_ = ' '                                   " + CRLF
	_cQry += "AND   SZK.ZK_PEDIDO  = '" + _cNumPed + "'                    " + CRLF
	_cQry += "AND   SZK.ZK_FILIAL  = '" + FWxFilial("SZK") + "'            " + CRLF
	
	_cTrb := MpSysOpenQuery(_cQry)
	
	_cNItem := Soma1((_cTrb)->MAXIT)
	
	_cQry := "SELECT * FROM " + RetSqlName("SZK") + " SZK       " + CRLF
	_cQry += "WHERE SZK.D_E_L_E_T_ = ' '                        " + CRLF
	
	If _cOper <> "*"
		
		_cQry += "AND   SZK.ZK_OPERAC  = '" + _cOper   + "'         " + CRLF
		
	Endif
	
	_cQry += "AND   SZK.ZK_PEDIDO  = '" + _cNumPed + "'         " + CRLF
	_cQry += "AND   SZK.ZK_FILIAL  = '" + FWxFilial("SZK") + "' " + CRLF
	
	_cTrb := MpSysOpenQuery(_cQry,,_aStru)
	
	While (_cTrb)->(!Eof())
		
		If _lGera .And. _nVlNped > 0 .And. _nVlOped > 0
			
			dbSelectArea("SZK")
			SZK->(dbSetOrder(8))
			
			Begin Transaction
			
			If SZK->(MsSeek((_cTrb)->(ZK_FILIAL+ZK_PEDIDO+ZK_OPERAC+ZK_CLIENTE+ZK_LOJA)))
				
				Reclock("SZK",!_lGera)
				If _cOper == "SB"				
					Replace ZK_VALOR With (_nVlOped * 11.828) / 100 //_nVlDped				
				Else
					Replace ZK_VALOR With _nVlOped //_nVlDped
				Endif	
				SZK->(Msunlock())
				
			Endif
			
			Reclock("SZK",_lGera)
			
			For _nX := 1 to Len(_aStru)
				
				If _aStru[_nX][1] == "ZK_PEDIDO"
					
					Replace ZK_PEDIDO With _cNewPed
					
				Elseif _aStru[_nX][1] == "ZK_EMISSAO"
					
					Replace ZK_EMISSAO With dDataBase
					
				Elseif _aStru[_nX][1] == "ZK_ITEM"
					
					Replace ZK_ITEM    With _cNItem
					
//				Elseif _aStru[_nX][1] == "ZK_XPEDREF" // Impede que a baixa de pedidos Antecipados funcione corretamente para Tipo (AP)
					
//					Replace ZK_XPEDREF With _cNumPed
					
				Elseif _aStru[_nX][1] == "ZK_VALOR"
					
					If _cOper == "SB"
						Replace ZK_VALOR   With (_nVlNped * 11.828) / 100
					Else	
						Replace ZK_VALOR   With _nVlNped
					Endif						        
					
				Else
					
					Replace &(_aStru[_nX][1]) With (_cTrb)->&(_aStru[_nX][1])
					
				Endif
				
			Next _nX
			
			SZK->(Msunlock())
			
			End Transaction
			
			_xRet := .T.
			
		Else
			
			If ValType(_xRet) <> "A" ; _xRet := {} ; Endif
			
			For _nX := 1 to Len(_aStru)
				
				aAdd(_xRet, {_aStru[_nX][1], (_cTrb)->&(_aStru[_nX][1])})
				
			Next _nX
			
		Endif
		
		(_cTrb)->(dbSkip())
		
	End
	
	(_cTrb)->(dbCloseArea())
	
Else
	
	_xRet := .F.
	
Endif

RestArea(_aArea)

Return _xRet

*'-T E S T E -------------------------------------------------------------------------------------'*
**************************************************
User FUNCTION ORTA642T
**************************************************
	Processa( {|| ORTA642M() },"Aguarde...","Ajustando Unidade...")
Return                                                                                              
*'-T E S T E -------------------------------------------------------------------------------------'*

*'-J O B -----------------------------------------------------------------------------------------'*
**************************************************
USER FUNCTION ORTA642D(cEmpExec, cFilExec, xParJob)
**************************************************

_aUnid	:= U_ORTPJOBU(cEmpExec, cFilExec)

cAnexos:=""
For _Ny := 1 To Len(_aUnid)
	CONOUT("Len(_aUnid): " + AllTrim(Str(Len(_aUnid))))

	PREPARE ENVIRONMENT EMPRESA _aUnid[_Ny][1] FILIAL _aUnid[_Ny][2]
	CONOUT("EMPRESA: " + cEmpAnt + " FILIAL: "+ cFilAnt)
	ErrorBlock({|e| U_JobCInfo("ORTR642V.PRW", StrTran(StrTran(e:ErrorStack, CHR(10), " "), CHR(13), " "), 0), UserException(e:ErrorStack) })
	
	U_ORTPJOBM(xParJob)
	
	CONOUT("ORTA642V.PRW - Inicio")
	U_JobCInfo("ORTA642V.PRW", "Inicio", 2)

	If cEmpAnt <> "26" .and. cFilAnt <> "02"
		RESET ENVIRONMENT
		RPCSetType(3)
		Loop
	Endif	

	cBody := "<html><title> [INICIADO] - DESMEMBRAR ORIGEM PEDIDO DE VENDA ENTRE UNIDADES </title>"
	cBody += "<style type='text/css'>"
	cBody += "p {font: 13pt courier new, courier;}"
	cBody += "</style><body><p>"
	cBody += " [INICIADO] DESMEMBRARORIGEM PEDIDO DE VENDA ENTRE UNIDADES AJUSTE AUTOMATICO "
	cBody += "</p></body>"
	EnvMail("terceirizado.ti@ortobom.com.br;gabriel.rezende@ortobom.com.br",cBody)
	
	_aIps := U_FRetUnidades()

	For _Nx := 1 to len(_aIPs)
		If _aIPs[_Nx,1] == "02"
			Loop
		Endif	
		
		cEnv := _aIPs[_Nx,4]
		oRpcSrv := TRpc():New( cEnv )
		
		// Conecta no ambiente
		cServer := _aIPs[_Nx,2]
		nPort   := _aIPs[_Nx,3]
		If ( oRpcSrv:Connect( cServer, nPort ) )
		
			oRpcSrv:CallProcEX('U_ORTA642J', _aIPs[_Nx,5], _aIPs[_Nx,6], "")
			
			// Fecha conexão
			oRpcSrv:Disconnect()
		Else
			CONOUT('Conexão RPC com {'+_aIPs[_Nx,5]+'} falhou... Unidade ['+_aIPs[_Nx,1]+']')
		Endif
	Next _Nx

	U_ORTPJOBC()
	
	ErrorBlock()

	CONOUT("ORTA642V.PRW - Fim")
	U_JobCInfo("ORTA642V.PRW", "Fim", 2)

	RESET ENVIRONMENT
	RPCSetType(3)
	
*'Processa apenas 1 vez'*
	Exit
*'---------------------'*
Next _Ny

Return		
*'-J O B -----------------------------------------------------------------------------------------'*

*************************************
Static Function ORTA642M
*************************************

cBody := "<html><title> [INICIADO] - DESMEMBRAR ORIGEM PEDIDO DE VENDA ENTRE UNIDADES </title>"
cBody += "<style type='text/css'>"
cBody += "p {font: 13pt courier new, courier;}"
cBody += "</style><body><p>"
cBody += " [INICIADO] DESMEMBRARORIGEM PEDIDO DE VENDA ENTRE UNIDADES AJUSTE AUTOMATICO "
cBody += "</p></body>"
EnvMail("terceirizado.ti@ortobom.com.br",cBody)

_aIps := U_FRetUnidades()

ProcRegua(0)
INCPROC("Ajustando Unidade...")
INCPROC("Ajustando Unidade...")

For _Nx := 1 to len(_aIPs)
	If _aIPs[_Nx,1] == "02"
		Loop
	Endif	

	INCPROC("Ajustando Unidade..." + _aIPs[_Nx,1])

	cEnv := _aIPs[_Nx,4]
	oRpcSrv := TRpc():New( cEnv )
	
	// Conecta no ambiente
	cServer := _aIPs[_Nx,2]
	nPort   := _aIPs[_Nx,3]
	If ( oRpcSrv:Connect( cServer, nPort ) )
	
		oRpcSrv:CallProcEX('U_ORTA642J', _aIPs[_Nx,5], _aIPs[_Nx,6], "")
	
		// Fecha conexão
		oRpcSrv:Disconnect()
	Else
		CONOUT('Conexão RPC com {'+_aIPs[_Nx,5]+'} falhou... Unidade ['+_aIPs[_Nx,1]+']')
		MsgInfo('Conexão RPC com {'+_aIPs[_Nx,5]+'} falhou... Unidade ['+_aIPs[_Nx,1]+']',"Error")
	Endif
Next

Return		

*************************************
User Function ORTA642J(cEmpExec, cFilExec, xParJob)
*************************************
_aUnid	:= U_ORTPJOBU(cEmpExec, cFilExec)

cAnexos:=""
For _Nx := 1 To Len(_aUnid)
	CONOUT("Len(_aUnid): " + AllTrim(Str(Len(_aUnid))))

	PREPARE ENVIRONMENT EMPRESA _aUnid[_Nx][1] FILIAL _aUnid[_Nx][2]
	CONOUT("EMPRESA: " + cEmpAnt + " FILIAL: "+ cFilAnt)
	ErrorBlock({|e| U_JobCInfo("ORTA642J.PRW", StrTran(StrTran(e:ErrorStack, CHR(10), " "), CHR(13), " "), 0), UserException(e:ErrorStack) })
	
	U_ORTPJOBM(xParJob)
	
	CONOUT("ORTA642J.PRW - Inicio")
	U_JobCInfo("ORTA642J.PRW", "Inicio", 2)

	If cEmpAnt <> "26" .and. cFilAnt <> "02"
		RESET ENVIRONMENT
		RPCSetType(3)
		Loop
	Endif	

	cNumPed   := ""
	cPedOrig  := ""
	_aItens   := {}                                 
	cCliente  := ""
	cLoja     := ""
	
	*'Reprocessa o Desemembramento na Unidade de Origem para Operação 13 -------------------------------'*
	cQry := " SELECT C5_XUNORI, C5_NUM, C5_XPEDDES, C5_CLIENTE, C5_LOJACLI, C6_PRODUTO, C6_ITEM, C6_DESCRI, C6_QTDVEN, C6_PRCVEN, C5_XENTREG, C5_XENTREF, "
	cQry += " (SELECT C6_ITEM FROM SIGA."+RetSqlName("SC6")+" SCX WHERE SCX.D_E_L_E_T_ = ' ' AND SCX.C6_FILIAL = '"+xFilial("SC6")+"' AND SCX.C6_NUM = SUBSTR(SC5.C5_XPEDDES,1,6) AND SCX.C6_PRODUTO = SC6.C6_PRODUTO) AS ITEM_ORI "
	cQry += " FROM siga."+RetSqlName("SC5")+" SC5, siga."+RetSqlName("SC6")+" SC6 "
	cQry += " WHERE SC5.D_E_L_E_T_ = ' ' "
	cQry += " AND C5_FILIAL   = '"+xFilial("SC5")+"'"
	cQry += " AND SC6.D_E_L_E_T_ = ' ' "
	cQry += " AND C6_FILIAL   = '"+xFilial("SC6")+"'"
	cQry += " AND C6_NUM      = C5_NUM "	
	cQry += " AND C5_XOPER    = '14' "
	cQry += " AND C5_XPEDDES <> ' ' "
	cQry += " AND C5_XPEDCLX  = ' ' "
	cQry += " AND C5_XUNORI = '02'  " // Somente São Paulo
	cQry += " AND C5_XACERTO >= '20210216' "
	//cQry += " AND C5_NUM = '038059' "
	cQry += " ORDER BY C5_NUM, C6_ITEM " 
	
	Memowrite("C:\AAA\ORTA642R.SQL", cQry)
	If Select("QRY") > 0
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf
	
	TcQuery cQry ALIAS "QRY" NEW
	dbSelectArea("QRY")
	dbGoTop()
	
	If !QRY->(EOF())
		_nPedidos := 0
		cNumPed   := ""
		_cUnOri   := ""
		While !QRY->(EOF())
			If QRY->C5_NUM <> cNumPed
				_cUnOri += IIf(!(QRY->C5_XUNORI $ _cUnOri),QRY->C5_XUNORI+",","")
				cNumPed := QRY->C5_NUM
				_nPedidos++
			Endif	
			QRY->(DbSkip())
		End                
		dbGoTop()
	
		cNumPed   := QRY->C5_NUM
		cPedOrig  := AllTrim(QRY->C5_XPEDDES)
		_aItens   := {}
		cCliente  := QRY->C5_CLIENTE
		cLoja     := QRY->C5_LOJACLI
	
		While !QRY->(EOF())
	
			If cNumped <> QRY->C5_NUM
	
				fProcRep()
	
				cNumPed  := QRY->C5_NUM
				cPedOrig  := AllTrim(QRY->C5_XPEDDES)
				_aItens   := {}		
				cCliente  := QRY->C5_CLIENTE
				cLoja     := QRY->C5_LOJACLI						
				
			Endif				
	
			aadd(_aItens,{QRY->C6_PRODUTO,QRY->ITEM_ORI,QRY->C6_DESCRI,0,QRY->C6_QTDVEN,QRY->C6_PRCVEN,QRY->C5_XENTREG,QRY->C5_XENTREF})
	
			QRY->(DbSkip())
		End               
	
		// Ultimo processo	
		fProcRep()		                                                                            
	Endif	

	U_ORTPJOBC()
	
	ErrorBlock()

	CONOUT("ORTA642J.PRW - Fim")
	U_JobCInfo("ORTA642J.PRW", "Fim", 2)

	RESET ENVIRONMENT
	RPCSetType(3)
	
*'Processa apenas 1 vez'*
	Exit
*'---------------------'*
Next _nX

Return

*************************************
Static Function fprocRep
*************************************
dbselectarea("SC5")
dbsetorder(1)
dbgotop()
If dbseek(xFilial("SC5")+cPedOrig)
	_cPedClx := AllTrim(SC5->C5_XPEDCLX)
	If !Empty(_cPedClx)
		// Localiza a Unidde de Origem
		cUnOri  := SC5->C5_XUNORI
		If !Empty(cUnOri)
			_cRetx  := ""
			cCnpj	 := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_CGC") // Só envia o CNPJ se Cliente for Diferente
			
			aIps:=U_FRetUnidades()
			nPos:= aScan(aIps,{|x| x[1]==cUnOri})
			if nPos==0
//				If !_lJob
//					Alert("Unidade de origem Invalida")
//				Endif	
				Return()
			Else
				oSrv:=rpcconnect(aIps[nPos,2], aIps[nPos,3], aIps[nPos,4], aIps[nPos,5], aIps[nPos,6])
				if valtype(oSrv)=="O"
					_cRetx := oSrv:CallProc( 'U_ORTA658', _aItens, _cPedClx, cCnpj)
					rpcdisconnect(oSrv)
				Else
//					If !_lJob
//						Alert("Problemas na conexao com a unidade "+aIps[nPos,1])
//					Endif	
				Endif
			Endif
			
			If !Empty(_cRetx)
				dbselectarea("SC5")
				dbsetorder(1)
				dbgotop()
				If dbseek(xFilial("SC5")+cNumPed)
					If RecLock("SC5",.F.)
						SC5->C5_XPEDCLX := _cRetx
						SC5->(MsUnLock())
					Endif
				Endif
//				If !_lJob
//					Aviso("Atenção", "Desmembramento realizado com sucesso no Pedido ["+_cPedClx+"] da Empresa Origem ["+cUnOri+"]", { "Sair" } )
//				Endif	
			Else
//				If !_lJob
//					Aviso("Atenção", "Desmembramento não realizado no Pedido ["+_cPedClx+"] da Empresa Origem ["+cUnOri+"]", { "Sair" } )
//				Endif	
			Endif
		Endif
	Endif
Endif

Return
*'--------------------------------------------------------------------------------------------------'*

***************************************
Static Function EnvMail(cMail,cBody,cAnexos)
***************************************
Local cServer  :="10.0.100.102"
Local cAccount :="sistema"
Local cPassword:="sis7823@w"
Local cFrom    :="sistema@ortobom.com.br"
Local cTo      :=cMail
Local cSubject :="[sigo] - Ajuste Desmembramento Pedidos EUN [oper.13] UN." + cEmpAnt
Local ccc      :=""

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk
If lOk
	if !MailAuth(cAccount,cPassword)
		CONOUT("Erro de Autenticação")
		DISCONNECT SMTP SERVER
		CONOUT("Servidor de e-mail desconectado!")
	else
		If !Empty(cAnexos)
			SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody ATTACHMENT cAnexos Result lOk
		Else
			SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody Result lOk
		EndIf
		If !lOk
			GET MAIL ERROR cMensagem
			CONOUT(cMensagem)
			CONOUT("Problemas no envio para o email: "+cTo)
		EndIf
	EndIf                                                                 
Else
	CONOUT("Problemas na conexão com o servidor de email")
EndIf

DISCONNECT SMTP SERVER

Return()