#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "RwMake.Ch"
#Include "SigaWin.Ch"
#include "colors.ch"
#include "font.ch"
#INCLUDE "JPEG.CH"
#INCLUDE "TBICONN.CH"
#Include "colors.ch"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±∫Programa  ≥ ORTA646  ∫ Autor ≥ Cesar Dupim / M·rcio Sobreira      ∫ Data ≥  23/02/18   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ ImportaÁ„o de Pedidos Entre Unidades     	             				  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±              
±±∫Uso       ≥ Faturamento                                              				  ∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ                    
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function ORTA646()
Local cImage         := "logorto3.jpg"

Define MSDialog oDlg Title OemToAnsi("ImportaÁ„o de Pedidos Entre Unidades") From 000,000 To 290,230 Pixel
DEFINE Font oFont1 Name "Arial" Size 0,-13
@ 005,005 to 100,110 Pixel
@ 008,017 Jpeg FILE cImage Size 150,290 PIXEL BORDER OF oDlg oBject oFigura
@ 050,010 Say "Esta rotina tem por objetivo " Size 100,10 Font oFont1 Pixel of odlg
@ 060,010 Say "importar os pedidos de outra " Size 100,10 Font oFont1 Pixel of odlg
@ 070,010 Say "unidade (OperaÁ„o 13) a serem" Size 100,10 Font oFont1 Pixel of odlg
@ 080,010 Say "fabricados e entregues  pela " Size 100,10 Font oFont1 Pixel of odlg
@ 090,010 Say "unidade corrente             " Size 100,10 Font oFont1 Pixel of odlg
@ 110,010 Button OemToAnsi("Importar")        Size 33,12 Action (Processa({|lEnd| Fprocessa(@lEnd)}, "Aguarde...","Processando...", .T.)) Pixel of oDlg
@ 110,045 Button OemToAnsi("Relatorio")       Size 33,12 Action (Processa({|lEnd| REL_GERAD(@lEnd)}, "Aguarde...","Imprimindo....", .T.)) Pixel of oDlg //SSI - 90737 - Claudio Rocha 
@ 110,080 Button OemToAnsi("Sair")            Size 33,12 Action Close(oDlg) Pixel of oDlg

ACTIVATE MSDIALOG oDlg CENTERED

RETURN

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FProcessa(lEnd)
Local aPergs :={}
Local aRet   :={}
Local aIps:=U_FRetUnidades()
Local cUnOri := "  "
Local aPed:={}
Local i, j

aAdd( aIps, { "27", "10.0.200.63", 1235, "ORTORJ" , "18", "03", "Queimados		    ","RJ", "QM" } )

aAdd( aPergs ,{1,"Unidade Origem: ",cUnOri,"@99",'.T.',,'.T.',2,.F.})
If !Parambox ( aPergs, "Entre Unidades", aRet,,,,,,,"Entre Unidades",.F.,)
	Return
EndIf
cUnOri:=MV_PAR01

// N„o permite unidade 25
if Val(MV_PAR01) == 25
	Alert("Unidade Invalida. Digite a unidade [05]!")
	Return()
Endif

nPos:= aScan(aIps,{|x| x[1]==cUnOri})
if nPos==0
	Alert("Unidade Invalida")
	Return()
Else
	_aAreaAtu := GetArea()
	SaveInter()
	If cEmpAnt == '18' .And. cFilAnt == '03'
		aPed := U_ORTXRPC(cUnOri, "U_ORTA646A",{'27'})
	elseif cEmpAnt == '18' .And. cFilAnt == '04'  			//DMS - 14/01/2021
		aPed := U_ORTXRPC(cUnOri, "U_ORTA646A",{'28'})
	Else
		aPed := U_ORTXRPC(cUnOri, "U_ORTA646A",{cEmpAnt})  // M·rcio - Remover o .T.
	EndIf
	RestInter()
	RestArea(_aAreaAtu)
	If ValType(aPed)<>"A"
		Alert("Problemas na conexao com a unidade de Origem ["+cUnOri+"]")
	Else
		If Len(aPed) > 0
			If	MsgYesNo("Confirma a ImportaÁ„o de ["+Alltrim(STR(Len(aPed)))+"] pedido(s)? [S/N]?")
				GravaPed(aPed, cUnOri,.F.)
			Else
				For I:=1 to Len(aPed)
					For J:=1 to Len(aPed[i,1])
						If AllTrim(aPed[i,1,j,1])=="C5_NUM"
							_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(aPed[i,1,j,2])})  // Remover Flag
						Endif
					Next
				Next
			Endif
		Else
			Aviso("AtenÁ„o", "Nenhum pedido localizado para esta empresa!", { "Sair" } )
		Endif
		
	Endif
Endif
Return()

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function ORTA646A(cUniDest)
Local cQuery :=""
Local cPed   :=""
Local aRet   :={}
Local nPed   := 0
Local aSX3SC5:={}
Local aSX3SA1:={}
Local aSX3SA3:={}
Local aSX3SC6:={}
Local nItem  := 0
Local cPedBlq:=""
Local aPedidos:={}
Local i, _Nx

conout("[ORTA646] - Inicio RPC")
// Adicionar B1_XCODBAS e B1_XMED
DbSelectArea("SX3")
Dbsetorder(2)

DbSeek("B1_XCODBAS")
aadd(aSX3SC6,{SX3->X3_CAMPO,SX3->X3_TIPO})
DbSeek("B1_XMED   ")
aadd(aSX3SC6,{SX3->X3_CAMPO,SX3->X3_TIPO})
DbSeek("C6_PRODUTO")
aadd(aSX3SC6,{SX3->X3_CAMPO,SX3->X3_TIPO})
DbSeek("DA1_XCUSTO")
aadd(aSX3SC6,{SX3->X3_CAMPO,SX3->X3_TIPO})

Dbsetorder(1)
DbSeek("SC5")
Do While SX3->X3_ARQUIVO=="SC5"
	if SX3->X3_CONTEXT<>"V" .and. SX3->X3_TIPO<>"M"
		aadd(aSX3SC5,{SX3->X3_CAMPO,SX3->X3_TIPO})
	Endif
	DbSkip()
Enddo

DbSeek("SC6")
Do While SX3->X3_ARQUIVO=="SC6"
	if SX3->X3_CONTEXT<>"V" .and. SX3->X3_TIPO<>"M"
		aadd(aSX3SC6,{SX3->X3_CAMPO,SX3->X3_TIPO})
	Endif
	DbSkip()
Enddo

Dbsetorder(1)
DbSeek("SA1")
Do While SX3->X3_ARQUIVO=="SA1"
	if SX3->X3_CONTEXT<>"V" .and. SX3->X3_TIPO<>"M"
		If (SX3->X3_CAMPO $ "A1_CGC    /A1_FILIAL ")
//		If (SX3->X3_CAMPO $ "A1_CGC    /A1_FILIAL " .and. cEmpAnt == "03") .or. cEmpAnt <> "03"
			aadd(aSX3SA1,{SX3->X3_CAMPO,SX3->X3_TIPO})
		Endif
	Endif
	DbSkip()
Enddo

Dbsetorder(1)
DbSeek("SA3")
Do While SX3->X3_ARQUIVO=="SA3"
	if SX3->X3_CONTEXT<>"V" .and. SX3->X3_TIPO<>"M"
		aadd(aSX3SA3,{SX3->X3_CAMPO,SX3->X3_TIPO})
	Endif
	DbSkip()
Enddo

cQuery:=" SELECT B1_XCODBAS, B1_XMED, C6_PRODUTO, "
cQuery+=" (SELECT A1_CGC "
cQuery+="  FROM "+RetSqlName("SA1")+" SA1X "
cQuery+="  WHERE SA1X.A1_FILIAL = '"+XFILIAL("SA1")+"' "
cQuery+="  AND SA1X.D_E_L_E_T_ = ' ' "
cQuery+="  AND SA1X.A1_COD = SC5.C5_CLIENT) CNPJ_CLIENT, "
cQuery+="(SELECT DA1.DA1_XCUSTO "
cQuery+="        FROM "+RetSqlName("DA1")+" DA1 "
cQuery+="        WHERE DA1_FILIAL   = '"+xFilial("DA1")+"' "
cQuery+="        AND DA1.D_E_L_E_T_ = ' ' "
cQuery+="        AND DA1.DA1_CODPRO = C6_PRODUTO "
cQuery+="        AND DA1.DA1_CODTAB = C5_TABELA) DA1_XCUSTO, "
cQuery+=" SC5.*, SC6.*, SA1.A1_CGC, SA1.A1_FILIAL, SA3.* "
//cQuery+=" SC5.*, SC6.*, "+ IIF(cEmpAnt <> "03","SA1.*","SA1.A1_CGC, SA1.A1_FILIAL")+", SA3.* "
cQuery+=" FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SB1")+" SB1, "
cQuery+=  RetSqlName("DA0")+" DA0, "+RetSqlName("SA1")+" SA1, "+RetSqlName("SA3")+" SA3 "
cQuery+=" WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery+="  AND C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery+="  AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery+="  AND DA0_FILIAL = '"+xFilial("DA0")+"' "
cQuery+="  AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery+="  AND A3_FILIAL = '"+xFilial("SA3")+"' "
cQuery+="  AND SC5.D_E_L_E_T_ = ' '  "
cQuery+="  AND SC6.D_E_L_E_T_ = ' '  "
cQuery+="  AND SB1.D_E_L_E_T_ = ' '  "
cQuery+="  AND DA0.D_E_L_E_T_ = ' '  "
cQuery+="  AND SA1.D_E_L_E_T_ = ' '  "
cQuery+="  AND SA3.D_E_L_E_T_ = ' '  "
cQuery+="  AND A3_COD = C5_VEND1     "
cQuery+="  AND A1_COD = C5_CLIENTE   "
cQuery+="  AND C5_NUM = C6_NUM  "
cQuery+="  AND B1_COD = C6_PRODUTO  "
cQuery+="  AND DA0_CODTAB = C5_TABELA  "
cQuery+="  AND C5_XPEDCLX = ' '  "
cQuery+="  AND C5_XOPER   = '13'  " // Origem
cQuery+="  AND C5_XEMBARQ = ' '  "
cQuery+="  AND C5_NOTA    = ' '  "
cQuery+="  AND C5_EMISSAO BETWEEN DA0_DATDE AND DA0_DATATE "
cQuery+="  AND C5_EMISSAO >= '20171001' " 		// Data de Corte para buscar de Dados
cQuery+="  AND C5_XUNDEST IN ('"+IIF(cUniDest$"05/25","05','25",cUniDest)+"') "    // Identifica a Empresa que pode importar
cQuery+="  AND C5_RESREM  = ' ' "    			// Identifica Se Pedido j· foi importado
//cQuery+="  AND C5_NUM     IN ('770493') " // Remover
cQuery+="  ORDER BY C5_NUM, C6_ITEM "
conout("[ORTA646] - Query: "+cQuery)
memowrite("C:\ORTA646A.SQL",cQuery)

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQuery cQuery Alias "QRY" NEW
DbSelectArea("QRY")
Do While !eof()
	If cPed<>QRY->C5_NUM
		cPed:=QRY->C5_NUM
		
		aadd(aPedidos,cPed) // Gravando para Flagar Depois como importado
		
		aadd(aRet,{{},{},{},{},{},{},{},{}}) //{Pedido,Itens,CNPJ,Tabela,Tipo/Cond,Bloqueios,Vendedor,CNPJ C5_CLIENT}
		nPed++
		nItem:=0
		For i:=1 to Len(aSX3SC5)
			cCmp:="QRY->"+aSX3SC5[i,1]
			//            conout("[ORTA646] - SC5: "+cCmp+": "+IIF(aSX3SC5[i,2]=="N",Str(&cCmp),&cCmp))
			If aSX3SC5[i,2]=="D"
				aadd(aRet[nPed,1],{aSX3SC5[i,1],StoD(&cCmp)})
			Else
				If aSX3SC5[i,2]=="L"
					aadd(aRet[nPed,1],{aSX3SC5[i,1],&cCmp=="T"})
				Else
					aadd(aRet[nPed,1],{aSX3SC5[i,1],&cCmp})
				Endif
			Endif
		Next
		
		// Cliente ////////////////////////////////////////
		For i:=1 to Len(aSX3SA1)
			cCmp:="QRY->"+aSX3SA1[i,1]
			If aSX3SA1[i,2]=="D"
				aadd(aRet[nPed,3],{aSX3SA1[i,1],StoD(&cCmp)})
			Else
				If aSX3SA1[i,2]=="L"
					aadd(aRet[nPed,3],{aSX3SA1[i,1],&cCmp=="T"})
				Else
					aadd(aRet[nPed,3],{aSX3SA1[i,1],&cCmp})
				Endif
			Endif
		Next
		///////////////////////////////////////////////////
		
		// Vendedor ///////////////////////////////////////
		For i:=1 to Len(aSX3SA3)
			cCmp:="QRY->"+aSX3SA3[i,1]
			If aSX3SA3[i,2]=="D"
				aadd(aRet[nPed,7],{aSX3SA3[i,1],StoD(&cCmp)})
			Else
				If aSX3SA3[i,2]=="L"
					aadd(aRet[nPed,7],{aSX3SA3[i,1],&cCmp=="T"})
				Else
					aadd(aRet[nPed,7],{aSX3SA3[i,1],&cCmp})
				Endif
			Endif
		Next
		///////////////////////////////////////////////////
		
		// Adiciona Tabela ////////////////////////////////
		aadd(aRet[nPed,4],"")
		aRet[nPed,4,1] := QRY->C5_TABELA
		///////////////////////////////////////////////////
		
		// Adiciona CNPJ do C5_CLIENT /////////////////////
		aadd(aRet[nPed,8],"")
		aRet[nPed,8,1] := QRY->CNPJ_CLIENT
		///////////////////////////////////////////////////
		
		// Adiciona os dados da condiÁ„o //////////////////
		_cCond := QRY->C5_CONDPAG
		DbSelectArea("SE4")
		DbSetOrder(1)
		DbGoTop()
		If DbSeek(XFILIAL("SE4")+_cCond)
			aadd(aRet[nPed,5],SE4->E4_CODIGO)
			aadd(aRet[nPed,5],SE4->E4_TIPO)
			aadd(aRet[nPed,5],SE4->E4_COND)
			aadd(aRet[nPed,5],SE4->E4_DDD)
		Endif
		///////////////////////////////////////////////////
		
		// Verifica se Pedido possui Bloqueios comerciais
		aPedBlq := fBuscBlq(QRY->C5_NUM)
		aadd(aRet[nPed,6],aPedBlq[1]) // Possui bloqueios Comerciais?
		aadd(aRet[nPed,6],aPedBlq[2]) // Est· liberado?
		
	EndIf
	nItem++
	aadd(aRet[nPed,2],{})
	For i:=1 to Len(aSX3SC6)
		cCmp:="QRY->"+aSX3SC6[i,1]
		//        conout("[ORTA646] - SC6: "+cCmp+": "+IIF(aSX3SC6[i,2]=="N",Str(&cCmp),&cCmp))
		If aSX3SC6[i,2]=="D"
			aadd(aRet[nPed,2,nItem],{aSX3SC6[i,1],StoD(&cCmp)})
		Else
			If aSX3SC6[i,2]=="L"
				aadd(aRet[nPed,2,nItem],{aSX3SC6[i,1],&cCmp=="T"})
			Else
				aadd(aRet[nPed,2,nItem],{aSX3SC6[i,1],&cCmp})
			Endif
		Endif
	Next
	
	DbSelectArea("QRY")
	DbSkip()
EndDo

*'-- Inicio - Flagar no ato da busca dos dados para importar - 31/10/19 - M·rcio Sobreira'*
If Len(aPedidos) > 0
	dbselectarea("SC5")
	dbsetorder(1)
	dbGoTop()
	For _Nx := 1 to len(aPedidos)
		if dbseek(xFilial("SC5")+aPedidos[_Nx])
			If RecLock("SC5",.F.)
				SC5->C5_RESREM := "S"
				SC5->(MsUnLock())
				_lRet  := .T.
			Endif
		Endif
	Next
Endif
*'-- Fim   - Flagar no ato da busca dos dados para importar - 31/10/19 - M·rcio Sobreira'*

conout("[ORTA646] - Final Rpc")
Return(aRet)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function ORTA646P(cProduto)
Local cQuery :=""
Local aRet   :={}
Local aSX3SB1:={}
Local nCod   :=0
Local i

conout("[ORTA646P] - Inicio RPC")

DbSelectArea("SX3")
Dbsetorder(1)
DbSeek("SB1")
Do While SX3->X3_ARQUIVO=="SB1"
	if SX3->X3_CONTEXT<>"V" .and. SX3->X3_TIPO<>"M"
		aadd(aSX3SB1,{SX3->X3_CAMPO,SX3->X3_TIPO})
	Endif
	DbSkip()
Enddo

// Adicionar B5_CEME
DbSelectArea("SX3")
Dbsetorder(2)
DbSeek("B5_CEME   ")
aadd(aSX3SB1,{SX3->X3_CAMPO,SX3->X3_TIPO})

cQuery:=" SELECT SB1.*, B5_CEME "
cQuery+=" FROM "+RetSqlName("SB1")+" SB1 "

cQuery+=" LEFT JOIN "+RetSqlName("SB5")+" SB5 ON
cQuery+=" SB5.D_E_L_E_T_   = ' '
cQuery+=" AND SB5.B5_FILIAL    = ' '
cQuery+=" AND SB5.B5_COD       = SB1.B1_COD

cQuery+=" WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery+=" AND SB1.D_E_L_E_T_ = ' '
cQuery+=" AND SB1.B1_COD       = '" + cProduto + "' "

conout("[ORTA646P] - Query: "+cQuery)
memowrite("C:\ORTA646P.SQL",cQuery)

If Select("QRY") > 0
	QRY->(dbCloseArea())
EndIf

TCQuery cQuery Alias "QRY" NEW
DbSelectArea("QRY")

If !eof()
	
	aadd(aRet,{{}})  //{Produto
	nCod++
	
	For i:=1 to Len(aSX3SB1)
		cCmp:="QRY->"+aSX3SB1[i,1]
		//            conout("[ORTA646] - SC5: "+cCmp+": "+IIF(aSX3SC5[i,2]=="N",Str(&cCmp),&cCmp))
		If aSX3SB1[i,2]=="D"
			aadd(aRet[nCod,1],{aSX3SB1[i,1],StoD(&cCmp)})
		Else
			If aSX3SB1[i,2]=="L"
				aadd(aRet[nCod,1],{aSX3SB1[i,1],&cCmp=="T"})
			Else
				aadd(aRet[nCod,1],{aSX3SB1[i,1],&cCmp})
			Endif
		Endif
	Next
	
Endif

conout("[ORTA646P] - Final Rpc")
Return(aRet)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function GravaPed(aPed, cUnOri, _lJob)
Local i:=1
Local j:=1
Local k:=1
local y:=1
Local aCabPv   :={}
Local aItemPv  :={}
Local cPed     :=""
Local aRet     :={}
Local _aLogRet := {}
Local _nTotPed := 0
Local aBlq     := {}
Local aSZH	   := {}
Local cCnpjTes :=""
Local _lGeraCli:= .F.
Local _cCliente2 := Space(6)
local _Nr, i, j, y, _Nx, _Nz
Private _xPedAnt  := ""
Private cTabPr    := ""
Private _nVerbRep := 0
Private lAnMarket := .F.

For I:=1 to Len(aPed)
	_lErro := .F.
	_lAjuTExp  := .F.
	
	lAnMarket := .F.
	For y:=1 to Len(aPed[i,1])
		if AllTrim(aPed[i,1,y,1]) == "C5_COTACAO"
			if AllTrim(aPed[i,1,y,2]) $ "ORTP156/OTP156"
				lAnMarket := .T.
			endif
		endif
	next y
	
	For J:=1 to Len(aPed[i,1])
		
		if AllTrim(aPed[i,1,j,1])=="C5_NUM"
			_lAjuTExp  := .F.
			_dDtExpAte := CTOD("")
			_xTabela   := aPed[i,4,1]
			
			If AllTrim(aPed[i,3,aScan(aPed[i][3],{|x|Alltrim(x[1])=="A1_CGC"}),2]) <> AllTrim(aPed[i,8,1]) .and. !Empty(AllTrim(aPed[i,8,1]))
				// Verifica se CNPJ do C5_CLIENT existe na Empresa Destino /////////////////
				DbSelectArea('SA1')
				DbSetOrder(3)
				DbGoTop()
				If !Dbseek(xFilial('SA1') + aPed[i,8,1]) // CNPJ do C5_CLIENT
					aRetCli := U_ORTXRPC(cUnOri, "U_ORTA646G",{aPed[i,8,1]})
					aRetCod := U_ORTA646C(aRetCli[1],"N",cUnOri) // Gera automaticamente no Cliente
					_cCLiente2 := aRetCod[1]                                                        
				Else
					_cCLiente2	:= SA1->A1_COD
                Endif
            Endif
             
			// Verifica se CNPJ Existe na Empresa Destino /////////////////
			DbSelectArea('SA1')
			DbSetOrder(3)
			DbGoTop()
			If !Dbseek(xFilial('SA1') + aPed[i,3,aScan(aPed[i][3],{|x|Alltrim(x[1])=="A1_CGC"}),2]) // CNPJ
				aRetCli   := U_ORTXRPC(cUnOri, "U_ORTA646G",{aPed[i,3,aScan(aPed[i][3],{|x|Alltrim(x[1])=="A1_CGC"}),2]})
				aRetCod   := U_ORTA646C(aRetCli[1],"N",cUnOri) // Gera automaticamente no Cliente
//				aRetCod   := U_ORTA646C(aPed[i,3],"N",cUnOri) // Gera automaticamente no Cliente
				_cCLiente := aRetCod[1]
				_lGeraCli:= .T.
				
				// Gera Serasa
				//				aRetSZ4 := U_ORTXRPC(cUnOri, "U_ORTA64Z4",{aPed[i,3,aScan(aPed[i][3],{|x|Alltrim(x[1])=="A1_CGC"}),2]})
				//				fGeraSZ4(_cCLiente, aRetSZ4)
				
				//				aRetSZ5 := U_ORTXRPC(cUnOri, "U_ORTA64Z5",{aPed[i,3,aScan(aPed[i][3],{|x|Alltrim(x[1])=="A1_CGC"}),2]})
				//				fGeraSZ5(_cCLiente, aRetSZ5)
				
				DbSelectArea('SA1')
				DbSetOrder(3)
				DbGoTop()
				Dbseek(xFilial('SA1') + aPed[i,3,aScan(aPed[i][3],{|x|Alltrim(x[1])=="A1_CGC"}),2]) // CNPJ
			Endif
			_cCLiente	:= SA1->A1_COD
			If AllTrim(aPed[i,3,aScan(aPed[i][3],{|x|Alltrim(x[1])=="A1_CGC"}),2]) == AllTrim(aPed[i,8,1])
				_cCLiente2 := _cCliente
			Endif
			_cCNPJ   	:= SA1->A1_CGC
			_cLoja		:= SA1->A1_LOJA
			_cEstCli    := SA1->A1_EST
			_cVendedor  := SA1->A1_VEND
			_cGrpCli    := SA1->A1_GRPTRIB
			
			IF cUnOri == "24" .and. cEmpAnt == "23"
				_cSegmen    := "1" // Fixar sempre como Industrial
			Else
				_cSegmen    := SA1->A1_XTIPO
			Endif
			_cSegmDes := _cSegmen
			
			If empty(_cSegmen)
				_cSegmen := U_ORTXRPC(cUnOri, "U_ORTA646F",{SA1->A1_CGC})
				DbSelectArea("SA1")
				dbOrderNickName("PSA11")
				dbSeek(xFilial("SA1") + _cCLiente)
				
				RecLock("SA1",.F.)
				SA1->A1_XTIPO = _cSegmen
				MsUnlock()
			Endif

            // Verifica se Dados do endereÁo da Origem est· igual ao Destino e Ajusta se necess·rio /////////////    
			If lAnMarket
				If _cCliente <> _cCliente2
					_aCliProc := {_cCliente,_cCliente2}
				Else
					_aCliProc := {_cCliente}
				Endif	
	
				For _Nr := 1 to len(_aCliproc)
					_cCgc := POSICIONE("SA1",1,XFILIAL("SA1")+_aCliProc[_Nr],"A1_CGC")
					aRetCli := U_ORTXRPC(cUnOri, "U_ORTA646G",{_cCgc})
					If Type( "aRetCli" ) <> "U"					
						_aDadosz := aRetCli[1]
						_cEnd    := _aDadosz[aScan(_aDadosz,{|x|Alltrim(x[1])=="A1_END"})][2]					
						_cBairro := _aDadosz[aScan(_aDadosz,{|x|Alltrim(x[1])=="A1_BAIRRO"})][2]					
						_cMun    := _aDadosz[aScan(_aDadosz,{|x|Alltrim(x[1])=="A1_MUN"})][2]										
						_cCod_Mun:= _aDadosz[aScan(_aDadosz,{|x|Alltrim(x[1])=="A1_COD_MUN"})][2]	
						_cCep    := _aDadosz[aScan(_aDadosz,{|x|Alltrim(x[1])=="A1_CEP"})][2]															
						_cEst	 := _aDadosz[aScan(_aDadosz,{|x|Alltrim(x[1])=="A1_EST"})][2]	
						_cCmp	 := _aDadosz[aScan(_aDadosz,{|x|Alltrim(x[1])=="A1_XCMPEND"})][2]	
						
						DbSelectArea("SA1")
						DbSetOrder(1)
						If DbSeek(XFILIAL("SA1")+_aCliProc[_Nr])
							If AllTrim(SA1->A1_END)     <> AllTrim(_cEnd)     .or. AllTrim(SA1->A1_BAIRRO) <> AllTrim(_cBairro) .or. AllTrim(SA1->A1_MUN) <> AllTrim(_cMun) .or. ;
		 					   AllTrim(SA1->A1_COD_MUN) <> AllTrim(_cCod_Mun) .or. AllTrim(SA1->A1_CEP)    <> AllTrim(_cCep)    .or. AllTrim(SA1->A1_EST) <> AllTrim(_cEst) .or. ;
							   AllTrim(SA1->A1_XCMPEND) <> AllTrim(_cCmp) /* SSIs 118756, 131257 e 130992 */ .OR. AllTrim(SA1->A1_XCIDADE) == "000000" .OR. AllTrim(SA1->A1_XROTA) == "000000" .OR. SA1->A1_XPERFRE == 0 /* SSIs 118756, 131257 e 130992 */
		
								If RecLock("SA1",.F.)
									SA1->A1_END		:= _cEnd
									SA1->A1_BAIRRO  := _cBairro
									SA1->A1_MUN		:= _cMun
									SA1->A1_COD_MUN := _cCod_Mun
									SA1->A1_CEP     := _cCep
									SA1->A1_EST     := _cEst
								    SA1->A1_XCMPEND := _cCmp
									/* SSIs 118756, 131257 e 130992 */
									If AllTrim(SA1->A1_XTIPO) == "2" .AND. AllTrim(SA1->A1_XNICHO) == "00004" .AND. AllTrim(SA1->A1_PESSOA) == "F"
										_cXCidade := U_ORTP043N(AllTrim(SA1->A1_EST), AllTrim(SA1->A1_MUN))
										If AllTrim(SA1->A1_XCIDADE) == "000000"
											SA1->A1_XCIDADE := _cXCidade
			   							EndIf
										If AllTrim(SA1->A1_XROTA) == "000000" .OR. SA1->A1_XPERFRE == 0
											cQry := "SELECT		Z3_CODIGO, Z3_DESC, Z3_FRETE1, Z3_FRETE2, ZN_CODIGO, ZN_CIDADE, ZN_ESTADO" + CRLF
											cQry += "FROM		" + RetSQLName("SZ3") + " SZ3, " + RetSQLName("SZN") + " SZN" + CRLF
											cQry += "WHERE		Z3_FILIAL = '" + xFilial("SZ3") + "'" + CRLF
											cQry += "AND		ZN_FILIAL = '" + xFilial("SZN") + "'" + CRLF
											cQry += "AND		SZ3.D_E_L_E_T_ = ' '" + CRLF
											cQry += "AND		SZN.D_E_L_E_T_ = ' '" + CRLF
											cQry += "AND		ZN_ROTA = Z3_CODIGO" + CRLF
											cQry += "AND		ZN_CODIGO = '" +_cXCidade+ "'" + CRLF
											cQry += "ORDER BY	1,5"

											U_ORTQUERY(cQry, "ORTA646ZA")

											If !EOF()
												U_JobCInfo("ORTA646.PRW", "ATUALIZADO O PERCENTUAL DO FRETE E A ROTA PARA A CIDADE: " + _cXCidade, 2)

												SA1->A1_XPERFRE	:= IIF(ORTA646ZA->Z3_FRETE2 > 0, ORTA646ZA->Z3_FRETE2, ORTA646ZA->Z3_FRETE1)
												SA1->A1_XROTA	:= ORTA646ZA->Z3_CODIGO
											Else
												U_JobCInfo("ORTA646.PRW", "N√O H¡ ROTA CADASTRADA PARA A CIDADE: " + _cXCidade + ". N√O … POSSÕVEL ATUALIZAR O PERCENTUAL DE FRETE E A ROTA DOS CLIENTES" , 1)
											EndIf

											ORTA646ZA->(dbCloseArea())
										EndIF										
									EndIf
									/* SSIs 118756, 131257 e 130992 */
									SA1->(MsUnLock())
								Endif																	
							Endif	
						Endif
					Endif
				Next
			Endif	
            //////////////////////////////////////////////////////////////////////////////////////////////////////
			
			/*
			If empty(_cVendedor) .or. LEN(alltrim(_cVendedor)) < 6
			_cVendedor := U_ORTXRPC(cUnOri, "U_ORTA646V",{SA1->A1_CGC})
			_cVendedor := substr(_cVendedor,1,1)+"7"+substr(_cVendedor,3,4)
			DbSelectArea("SA1")
			dbOrderNickName("PSA11")
			dbSeek(xFilial("SA1") + _cCLiente)
			
			RecLock("SA1",.F.)
			SA1->A1_VEND = _cVendedor
			MsUnlock()
			Endif
			*/
			///////////////////////////////////////////////////////////////
			
			// Verifica se CondiÁ„o de Pagamento Existe ///////////////////
			_cCodCond := fBusCond(aPed[i,5,2], aPed[i,5,3], aPed[i,5,4])
			If Empty(_cCodCond)
				//				Aviso("AtenÁ„o", "Cond. Pagamento ["+aPed[i,5,2]+"/"+AllTrim(aPed[i,5,3])+"/"+aPed[i,5,4]+"] no Pedido ["+aPed[i,1,j,2]+"] n„o existe na Unidade Destino!", { "Sair" } )
				aadd(_aLogRet,{cUnOri,cEmpAnt,aPed[i,1,j,2],"",0,0,aPed[i,4,1],"Cond.:"+aPed[i,5,2]+"/"+AllTrim(aPed[i,5,3])+"/"+aPed[i,5,4],"",CTOD(""),dDataBase, "Cond.Pg.n„o Existe"})
				fGrvlog("ORTA646", "Erro", "Cond.Pg.n„o Existe: " +aPed[i,5,2]+"/"+AllTrim(aPed[i,5,3])+"/"+aPed[i,5,4], cEmpAnt, cUnOri, "", aPed[i,1,j,2])
				*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
				If !Empty(cUnOri)
					_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(aPed[i,1,j,2])})  // Remover Flag
				Endif
				_lErro := .T.
				Exit
			Endif
			///////////////////////////////////////////////////////////////
			
			// Verifica se Tabela est· na Vigencia ////////////////////////
			DbSelectArea('DA0')
			DbSetOrder(1)
			DbGoTop()
			If Dbseek(xFilial('DA0') + aPed[i,4,1]) // Tabela
				If DA0->DA0_DATATE < dDatabase
					//					Aviso("AtenÁ„o", "Tabela ["+aPed[i,4,1]+"] no Pedido ["+aPed[i,1,j,2]+"] expirou a Data Limite para uso!", { "Sair" } )
					// Ajusta temporariamente a DataAte da Tabela para que seja possÌvel a importaÁ„o (AtÈ 90 dias)
					If DA0->DA0_DATATE + 90 >= dDatabase
						_lAjuTExp  := .T.
						_dDtExpAte := DA0->DA0_DATATE
						If RecLock("DA0",.F.)
							DA0->DA0_DATATE := dDataBase
							CONOUT("Ajustou Tabela Expirada ["+DA0->DA0_CODTAB+"] Dt. AtÈ para : " + DTOC(dDataBase))
							DA0->(MsUnLock())
						Endif
					Else
						aadd(_aLogRet,{cUnOri,cEmpAnt,aPed[i,1,j,2],"",0,0,aPed[i,4,1],"CNPJ:"+_cCnpj,"",CTOD(""),dDataBase, "Tabela expirada"})
						fGrvlog("ORTA646", "Erro", "Tabela expirada : " +aPed[i,4,1], cEmpAnt, cUnOri, "", aPed[i,1,j,2])
						*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
						If !Empty(cUnOri)
							_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(aPed[i,1,j,2])})  // Remover Flag
						Endif
						_lErro := .T.
						Exit
					Endif
				Endif
			Else
				//				Aviso("AtenÁ„o", "Tabela ["+aPed[i,4,1]+"] no Pedido ["+aPed[i,1,j,2]+"] n„o localizada na Empresa Atual["+cEmpAnt+"]!", { "Sair" } )
				aadd(_aLogRet,{cUnOri,cEmpAnt,aPed[i,1,j,2],"",0,0,aPed[i,4,1],"CNPJ:"+_cCnpj,"",CTOD(""),dDataBase, "Tabela n„o Existe"})
				fGrvlog("ORTA646", "Erro", "Tabela n„o Existe : " +aPed[i,4,1], cEmpAnt, cUnOri, "", aPed[i,1,j,2])
				*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
				If !Empty(cUnOri)
					_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(aPed[i,1,j,2])})  // Remover Flag
				Endif
				_lErro := .T.
				Exit
			Endif
			///////////////////////////////////////////////////////////////
			
			cTabPr := DA0->DA0_CODTAB
			cPed:=GetSxeNum("SC5","C5_NUM")
			DbSelectArea('SC5')
			dbOrderNickName('PSC51')
			dbseek(xFilial('SC5') + cPed)
			do while found()
				confirmSX8()
				cPed:=GetSXENum('SC5','C5_NUM')
				dbgotop()
				dbseek(xFilial('SC5') + cPed)
			enddo
			
			_xPedAnt:=aPed[i,1,j,2]

			aPed[i,1,j,2]:=cPed

			// Verifica se j· existe vinculado ao Pedido Destino //////////

	        _cNumDes := fBuscClx(_xPedAnt)

			If !Empty(_cNumDes)
				//				Aviso("AtenÁ„o", "Pedido ["+cUnOri+"]["+AllTrim(aPed[i,1,j,2])+"] possui Bloqueio por BLQMIX/BLQPRZ/BQLSBM!", { "Sair" } )
				aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,"{"+_cNumDes+"}",0,0,aPed[i,4,1],"CNPJ:"+_cCnpj,"",CTOD(""),dDataBase, "Ped.Ori j· Importado"})
				fGrvlog("ORTA646", "Erro", "Pedido Origem ["+_xPedAnt+"] j· existe vinculado ao Pedido Destino ["+_cNumDes+"]", cEmpAnt, cUnOri, "", aPed[i,1,j,2])
//				If !Empty(cUnOri)
//					_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(aPed[i,1,j,2])})  // Remover Flag
//				Endif
				_lErro := .T.
				Exit
			Endif
			///////////////////////////////////////////////////////////////
			
			// Verifica se possui bloqueio Comercial //////////////////////
			/* Deixar passar e criar automaticamente conforme regra padr„o no Destino - 07/10/21 - Gabriel
			If !aPed[i,6,2]
				//				Aviso("AtenÁ„o", "Pedido ["+cUnOri+"]["+AllTrim(aPed[i,1,j,2])+"] possui Bloqueio por BLQMIX/BLQPRZ/BQLSBM!", { "Sair" } )
				aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,"",0,0,aPed[i,4,1],"CNPJ:"+_cCnpj,"",CTOD(""),dDataBase, "Bloqueio na Origem"})
				fGrvlog("ORTA646", "Erro", "Bloqueio na Origem - CNPJ : "+_cCnpj, cEmpAnt, cUnOri, "", aPed[i,1,j,2])
				*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
				If !Empty(cUnOri)
					_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(_xPedAnt)})  // Remover Flag
				Endif
				_lErro := .T.
				Exit
			Endif
			*/ 
			///////////////////////////////////////////////////////////////
			
			// Verifica se È Comercial ////////////////////////////////////
			If aPed[i,6,1]
				_aAreaAtu := GetArea()
				SaveInter()
				aBlq := U_ORTXRPC(cUnOri, "U_ORTA646Z",{_xPedAnt})
				RestInter()
				RestArea(_aAreaAtu)
				If ValType(aBlq)<>"A"
					aBlq := {}
				Endif
			Endif
			///////////////////////////////////////////////////////////////
		Endif
		
		// Grava a Data de Emissao
		If AllTrim(aPed[i,1,j,1])=="C5_EMISSAO"
			_dEmissao     := aPed[i,1,j,2]
			If aPed[i,1,j,2] < dDataBase
				aPed[i,1,j,2] := dDataBase
			Endif
		Endif
		
		// Grava Dt. Lib. em branco
		If AllTrim(aPed[i,1,j,1])=="C5_XDTLIB"
			aPed[i,1,j,2] := CTOD("")
		Endif
		
		// Grava o Cliente Correto
		If AllTrim(aPed[i,1,j,1])=="C5_CLIENTE"
			_cCliOri := aPed[i,1,j,2]
			aPed[i,1,j,2] := _cCliente
		Endif
		
		// Grava o Cliente Correto
		If AllTrim(aPed[i,1,j,1])=="C5_CLIENT"
			If cEmpAnt == "07"
				aPed[i,1,j,2] := _cCliente
			Else
				aPed[i,1,j,2] := _cCliente2
			Endif
		Endif
		
		// Grava a Loja Correta
		If AllTrim(aPed[i,1,j,1])=="C5_LOJACLI
			_cLojOri := aPed[i,1,j,2]
			aPed[i,1,j,2] := _cLoja
		Endif
		
		// SSI 68424 - Peder Munksgaard - 10/09/2018
		If AllTrim(aPed[i,1,j,1])=="C5_XCLITRO" .And. Empty(AllTrim(aPed[i,1,j,2]))
			aPed[i,1,j,2]:=_cCliente
		Endif
		
		If AllTrim(aPed[i,1,j,1])=="C5_XLOJATR" .And. Empty(AllTrim(aPed[i,1,j,2]))
			aPed[i,1,j,2]:=_cLoja
		Endif
		//Fim SSI 68424
		
		// Gravando Pedido Ficha com o Numero do Pedido
		If AllTrim(aPed[i,1,j,1])=="C5_XPEDFIC"
			aPed[i,1,j,2]:=cPed
		Endif
		
		
		// Grava Unidade de Origem
		If AllTrim(aPed[i,1,j,1])=="C5_XUNORI"
			aPed[i,1,j,2]:=cUnOri
		Endif
		
		// Grava Campo Unidade de Destino em Branco
		If AllTrim(aPed[i,1,j,1])=="C5_XUNDEST"
			aPed[i,1,j,2]:="  "
		Endif
		
		// Repetindo Pedido C5_NUM
		If AllTrim(aPed[i,1,j,1]) $ "C5_XPEDCLX"
			aPed[i,1,j,2]:=_xPedAnt
		Endif
		
		// Grava Cond. pag.
		If AllTrim(aPed[i,1,j,1]) $ "C5_CONDPAG"
			aPed[i,1,j,2]:= _cCodCond
		Endif

		// Armazena Segmento do pedido
		If AllTrim(aPed[i,1,j,1])=="C5_XTPSEGM"
			_cSegmDes := aPed[i,1,j,2]
		Endif
		
		// Buscar Vendedor Padr„o
		If AllTrim(aPed[i,1,j,1]) $ "C5_VEND1"
			_cCodVenO := aPed[i,1,j,2]
			DbSelectArea("SZH")
			DbSetorder(1)
			DbGoTOP()
			If DbSeek(XFILIAL("SZH")+_cCLiente+_cLoja+IIF(cEmpAnt == '18' .And. cFilAnt == '03' .And. _cSegmDes == "1","M",_cSegmDes)) //_cSegmen) //_cSegmen
				aPed[i,1,j,2]:= SZH->ZH_VEND
			Else
				_cCodFind := fGeraVen(aPed[i,7,aScan(aPed[i][7],{|x|Alltrim(x[1])=="A3_CGC"}),2],aPed[i,7])
				aPed[i,1,j,2] := U_ORTA646B(cunOri, _cCNPJ, aPed[i,1,j,2],_cCliente,_cCodFind,_cSegmDes)
				
				DbSelectArea("SA1")
				dbOrderNickName("PSA11")
				dbSeek(xFilial("SA1") + _cCLiente)
				If RecLock("SA1",.F.)
					SA1->A1_VEND = _cCodFind
					MsUnlock()
				Endif
				
				//				aPed[i,1,j,2] := U_ORTA646B(cunOri, _cCNPJ,aPed[i,1][aScan(aPed[i,1],{|x|Alltrim(x[1])=="C5_VEND1"})][2])
				
				/*
				aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,"",0,0,aPed[i,4,1],"Vendedor:["+SZH->ZH_VEND+"]","",CTOD(""),dDataBase, "Vendedor n„o Existe"})
				fGrvlog("ORTA646", "Erro", "Vendedor n„o Existe :["+SZH->ZH_VEND+"]", cEmpAnt, cUnOri, "", _xPedAnt)
				*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
				If !Empty(cUnOri)
				_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(_xPedAnt)})  // Remover Flag
				Endif
				_lErro := .T.
				Exit
				
				Endif
				*/
			Endif
		Endif
		
		// Buscar Verba de Repasse e Verba Extra do Cliente
		If AllTrim(aPed[i,1,j,1]) $ "C5_XVERREP/C5_XVEREXT"
			If AllTrim(aPed[i,1,j,1]) $ "C5_XVERREP
				_nVerbRep := 0
			Else	
				_nVerbExt := 0			
			Endif	
			DbSelectArea("SZH")
			DbSetorder(1)
			DbGoTOP()
			If DbSeek(XFILIAL("SZH")+_cCLiente+_cLoja+IIF(cEmpAnt == '18' .And. cFilAnt == '03' .And. _cSegmDes == "1","M","")) //+_cSegmen
				If SZH->ZH_VERBREP == 0
					aVerRep := U_ORTXRPC(cUnOri, "U_ORTA646N",{_cCNPJ,_cCodVenO})
					While !SZH->(EOF()) .and. SZH->ZH_CLIENTE == _cCliente

						If (SZH->ZH_VERBREP == 0 .and. aVerRep[1] <> 0) .or. (SZH->ZH_VERBEXT == 0 .and. aVerRep[2] <> 0)
							If RecLock("SZH",.F.)
								If SZH->ZH_VERBREP == 0 .and. aVerRep[1] <> 0
									SZH->ZH_VERBREP := aVerRep[1]
								Endif	
								If SZH->ZH_VERBEXT == 0 .and. aVerRep[2] <> 0
									SZH->ZH_VERBEXT	:= aVerRep[2]
								Endif	
								SZH->(MsUnLock())
							Endif
						Endif

						If AllTrim(aPed[i,1,j,1]) $ "C5_XVERREP"
							If _nVerbRep == 0
								_nVerbRep := aVerRep[1] //SZH->ZH_VERBREP
							Endif
						Else
							If _nVerbExt == 0
								_nVerbExt := aVerRep[2] //SZH->ZH_VERBEXT
							Endif
						Endif
						
						SZH->(DbSkip())
					End
				Else
					If AllTrim(aPed[i,1,j,1]) $ "C5_XVERREP"
						If _nVerbRep == 0
							_nVerbRep := SZH->ZH_VERBREP //SZH->ZH_VERBREP
						Endif
					Else
						If _nVerbExt == 0
							_nVerbExt := SZH->ZH_VERBEXT //SZH->ZH_VERBEXT
						Endif
					Endif
				Endif
				
				aPed[i,1,j,2]:= IIF(AllTrim(aPed[i,1,j,1]) $ "C5_XVERREP",_nVerbRep,_nVerbExt)
				CONOUT(IIF(AllTrim(aPed[i,1,j,1]) $ "C5_XVERREP","SZH->ZH_VERBREP: " + AllTrim(Str(SZH->ZH_VERBREP)),"SZH->ZH_VERBEXT: " + Alltrim(Str(SZH->ZH_VERBEXT))))
			Endif
		Endif
		
		// Fixa como Destino C5_XOPER
		If AllTrim(aPed[i,1,j,1]) $ "C5_XOPER"
			aPed[i,1,j,2]:="14" // Destino
		Endif
		
		// Fixa C5_MENPAD
		If AllTrim(aPed[i,1,j,1]) $ "C5_MENPAD"
			aPed[i,1,j,2]:="   " // Destino
		Endif
		
		// Fixa "1" quando Destinok = 23 e Origem = 24
		If AllTrim(aPed[i,1,j,1]) $ "C5_XTPSEGM"
			If cUnOri == "24" .and. cEmpAnt == "23"
				aPed[i,1,j,2]:="1" // Segmento     
			ElseIf cEmpAnt == "18" .and. cFilAnt == "03" .and. _cSegmDes == "1" // SolicitaÁ„o Gabriel 03/12/21 (Unidade 27)
				aPed[i,1,j,2]:="M" // Segmento M (Sempre que segmento de ORIGEM for "1")				
			Endif
			// Se Venda Site ou MKTP
			If aPed[i,1,j,2] == "8" .and. _cSegmen <> aPed[i,1,j,2]
				DbSelectArea("SZH")
				DbSetorder(1)
				DbGoTOP()
				// Se n„o achar
				If !DbSeek(XFILIAL("SZH")+_cCLiente+_cLoja+"8")
					DbSelectArea("SZH")
					DbSetorder(1)
					DbGoTOP()
					// Copia do que achar
					If DbSeek(XFILIAL("SZH")+_cCLiente+_cLoja)
						_cItiner := SZH->ZH_ITINER
						_cDespro := SZH->ZH_DESCPRO
						_cVend   := SZH->ZH_VEND
						_cRefTab := SZH->ZH_REFTAB
						If RecLock("SZH",.T.)
							SZH->ZH_FILIAL := xFilial("SZH")
							SZH->ZH_CLIENTE:= _cCLiente
							SZH->ZH_LOJA   := _cLoja
							SZH->ZH_ITINER := _cItiner
							SZH->ZH_SEGMENT:= "8"
							SZH->ZH_DESCPRO:= _cDespro
							SZH->ZH_VEND   := _cVend
							SZH->ZH_REFTAB := _cRefTab
							
							SZH->(MsUnlock())
						Endif
					Endif
				Endif
			Endif
		Endif
		
		// Fixa C5_XQUAREN
		If AllTrim(aPed[i,1,j,1]) $ "C5_XQUAREN"
			If Empty(aPed[i,1,j,2])
				aPed[i,1,j,2] := "2" // N„o
			Endif
		Endif
		
		cValid := nil
		If Alltrim(aPed[i,1,j,1]) $ "C5_GERAWMS/C5_XMENPA2/C5_XMENPA3/C5_XMENPA4/C5_EMISSAO/C5_XTELEMK/C5_MENPAD/C5_XPEDFIC/C5_XCLITRO/C5_BANCO/C5_CLIENT"
			cValid := ".T."
		Endif
		
		*'Remover ValidaÁ„o C6_QTDVEN na Unidade 18----------------'*
		If Alltrim(aPed[i,1,j,1]) $ "C5_TPCOMPL/C5_MSBLQL/C5_SLENVT/C5_RET20G" .and. cEmpAnt $ "02/03/18/04/05/06/07/23/08/09/10/11/26/15/22" // N„o Valida dados do campo
			cValid := ".T."
		Endif
		*'Remover ValidaÁ„o C6_QTDVEN na Unidade 18----------------'*
		
		aadd(aCabPv,{aPed[i,1,j,1],aPed[i,1,j,2],cValid})
	Next

	If _lErro
		aCabPv:={}
		aItemPv:={}
		Loop
	Endif
	
	_nTotPed := 0
	For J:=1 to Len(aPed[i,2])
		_nQtdVen := 0
		_nPrcVen := 0
		_aTes    := {"   ","    ","   "}
		_xCusto  := 0
		_lProd   := .T.
		aadd(aItemPv,{})
		For K:=1 to len(aPed[i,2,j])
			cValid := nil                                                     
			If Alltrim(aPed[i,2,j,k,1]) $ "C6_IPIDEV/C6_BLQ/C6_LOTECTL/C6_NUMLOTE/C6_LOCALIZ/C6_CNATREC/C6_XTPMED/C6_ENTREG/C6_VALOR" // N„o Valida dados do campo
				cValid := ".T."
			Endif
			
			*'Remover ValidaÁ„o C6_QTDVEN na Unidade 18----------------'*
			If Alltrim(aPed[i,2,j,k,1]) $ "C6_QTDVEN/C6_PEDCOM/C6_INTROT/C6_VDMOST/C6_ALMTERC/C6_TPPROD/C6_CONTA" .and. cEmpAnt $ "02/03/18/04/05/06/07/23/08/09/10/11/26/15/21/22" // N„o Valida dados do campo
				cValid := ".T."
			Endif
			*'Remover ValidaÁ„o C6_QTDVEN na Unidade 18----------------'*
			
			// Grava o CÛdigo de Barra correto
			If Alltrim(aPed[i,2,j,k,1]) == "B1_XCODBAS"
				_cXCodBas := aPed[i,2,j,k,2]
				//				aPed[i,2,j,k,2] := "2010210179     "
			Endif
			
			// Grava a Medida Correta
			If Alltrim(aPed[i,2,j,k,1]) == "B1_XMED"
				_cXMed    := aPed[i,2,j,k,2]
			Endif
			
			// Produto
			If Alltrim(aPed[i,2,j,k,1]) == "C6_PRODUTO"
				If !_lProd // Pula na segunda vez que for processar o campo C6_PRODUTO
					Loop
				Endif
				_lProd := .F.
				_cProduto := aPed[i,2,j,k,2]
				_cCorte   := SUBSTR(_cProduto,7,1)
				
				If !Empty(_cXCodBas)
					// Verifica se J· Existe relacionamento B1_XCODBAS + B1_XMED
					if cEmpAnt=="24"
						_cNovoCod := ORTA646U()
						aPed[i,2,j,k,2]	:= _cNovoCod
					Else
						_cProdBus := fBuscRel(_cXCodBas, _cXMed, _cCorte)
						// Se Encontrou usa o novo cÛdigo
						If !Empty(_cProdBus)
							_cProduto       := _cProdBus
							aPed[i,2,j,k,2]	:= _cProduto
						Else
							// Se n„o, gera um novo codigo
							_cProdBus := fGeraCod(cUnOri,_cProduto, _lJob)
							If SUBSTR(_cProdBus,1,2) == "OK"
								_cProduto := PADR(SUBSTR(_cProdBus,3,Len(_cProdBus)),TAMSX3("B1_COD")[1])
								aPed[i,2,j,k,2]	:= _cProduto
							Endif
						Endif
					Endif
				Endif
				
				// Valida o TES Inteligente
				cCliTES:=_cCliente
				cLojTES:=_cLoja
				_cCnpj2:=_cCnpj
				_cGrpCli2:=_cGrpCli
				If !Empty(_cCliente2) .AND. _cCliente2 # _cCliente
					cCliTES  :=_cCliente2
					cLojTES  :=Posicione("SA1",01,xFilial("SA1")+_cCliente2,"A1_LOJA")
					_cEstCli :=Posicione("SA1",01,xFilial("SA1")+_cCliente2,"A1_EST" )
					_cCnpj2  :=Posicione("SA1",01,xFilial("SA1")+_cCliente2,"A1_CGC" )
					_cGrpCli2:=Posicione("SA1",01,xFilial("SA1")+_cCliente2,"A1_GRPTRIB" )
				EndIf
				
				_aTes := U_ORTA646T(cCliTES, cLojTES, _cEstCli, "14", _cProduto)
				
				DbSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+_cProduto))
				
				If Empty(_aTes[1])
					//					Aviso("AtenÁ„o", "T.E.S. Inteligente n„o Localizado para o Produto ["+_cProduto+"] do Pedido ["+_xPedAnt+"]!", { "Sair" } )
					aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,"",0,0,aPed[i,4,1],"CNPJ:"+_cCnpj2,"",CTOD(""),dDataBase, "TES Inteligente Op:"+"14"+" GrCli:"+_cGrpCli2+" GrPrd:"+SB1->B1_GRTRIB+" Produto: "+SB1->B1_COD})
					fGrvlog("ORTA646", "Erro", "TES Inteligente Op:"+"14"+" GrCli:"+_cGrpCli2+" GrPrd:"+SB1->B1_GRTRIB+" Produto: "+SB1->B1_COD, cEmpAnt, cUnOri, "", _xPedAnt)
					*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
					If !Empty(cUnOri)
						_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(_xPedAnt)})  // Remover Flag
					Endif
					_lErro := .T.
					Exit
				Endif
			Endif
			
			If Alltrim(aPed[i,2,j,k,1]) == "C6_DESCRI"
				_xDescri := Alltrim(Posicione("SB1",1,FWxFilial("SB1")+_cProduto,"B1_DESC"))
				_xMed	 := Alltrim(Posicione("SB1",1,FWxFilial("SB1")+_cProduto,"B1_XMED"))
				aPed[i,2,j,k,1]	:= _xDescri + " " + _xMed
			Endif
			
			// Grava o Custo Correto
			If Alltrim(aPed[i,2,j,k,1]) == "DA1_XCUSTO"
				/*
				n_XCUSTO := aPed[i,2,j,k,2]
				If ValType(n_XCUSTO) == "N"
				CONOUT("n_XCUSTO: " + AlLTrim(STR(n_XCUSTO)))
				If n_XCUSTO <> 0
				_xCusto   := n_XCUSTO
				Else
				aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,"",0,0,aPed[i,4,1],"CNPJ:"+aPed[i,3,1],"",CTOD(""),dDataBase, "Prod.["+AllTrim(_cProduto)+"] Custo zero(Orig)"})
				_lErro := .T.
				Endif
				Else
				aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,"",0,0,aPed[i,4,1],"CNPJ:"+aPed[i,3,1],"",CTOD(""),dDataBase, "Prod. ["+AllTrim(_cProduto)+"] sem Custo(Orig)"})
				_lErro := .T.
				Endif
				*/
			Endif
			
			// Regrava o Custo Correto
			If Alltrim(aPed[i,2,j,k,1]) == "C6_XCUSTO"
				DbSelectArea('DA1')
				DbSetOrder(1)
				DbGoTop()
				If Dbseek(xFilial('DA1') + _xTabela + _cProduto) // Tabela de PreÁo do produto
					If DA1->DA1_XCUSTO <> 0
						aPed[i,2,j,k,2] := DA1->DA1_XCUSTO
					Else
						aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,"",0,0,aPed[i,4,1],"CNPJ:"+_cCnpj,"",CTOD(""),dDataBase, "Prod.["+AllTrim(_cProduto)+"] s/Custo(Dest)"})
						fGrvlog("ORTA646", "Erro", "Prod.["+AllTrim(_cProduto)+"] s/Custo(Dest)", cEmpAnt, cUnOri, "", _xPedAnt)
						*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
						If !Empty(cUnOri)
							_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(_xPedAnt)})  // Remover Flag
						Endif
						_lErro := .T.
					Endif
				Endif
			Endif
			
			// Grava o Cliente Correto
			If Alltrim(aPed[i,2,j,k,1]) == "C6_CLI"
				aPed[i,2,j,k,2] := _cCliente
			Endif
			
			// Grava o Loja Correta
			If Alltrim(aPed[i,2,j,k,1]) == "C6_LOJA"
				aPed[i,2,j,k,2] := _cLoja
			Endif
			
			// Armazena a Qtd. Venda
			If Alltrim(aPed[i,2,j,k,1]) == "C6_QTDVEN"
				_nQtdVen := aPed[i,2,j,k,2]
			Endif
			
			// Armazena o PreÁo de Venda
			If Alltrim(aPed[i,2,j,k,1]) == "C6_PRCVEN"
				
				DbSelectArea('DA1')
				DbSetOrder(1)
				DbGoTop()
				If Dbseek(xFilial('DA1') + _xTabela + _cProduto) // Tabela de PreÁo do produto
					If DA1_PRCVEN == 0
						aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,"",0,0,aPed[i,4,1],"CNPJ:"+_cCnpj,"",CTOD(""),dDataBase, "Prod.["+AllTrim(_cProduto)+"] s/Prc(Dest)"})
						fGrvlog("ORTA646", "Erro", "Prod.["+AllTrim(_cProduto)+"] s/Prc(Dest)", cEmpAnt, cUnOri, "", _xPedAnt)
						*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
						If !Empty(cUnOri)
							_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(_xPedAnt)})  // Remover Flag
						Endif
						_lErro := .T.
					Endif
					//				Else
					//					aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,"",0,0,aPed[i,4,1],"CNPJ:"+aPed[i,3,1],"",CTOD(""),dDataBase, "Prod.["+AllTrim(_cProduto)+"] s/Tab(Dest)"})
					//					_lErro := .T.
				Endif
				
				_nPrcVen := aPed[i,2,j,k,2]
			Endif
			
			// Regrava o TES Inteligente
			If Alltrim(aPed[i,2,j,k,1]) == "C6_TES"
				aPed[i,2,j,k,2] := _aTes[1]
			Endif
			
			// Regrava o CF
			If Alltrim(aPed[i,2,j,k,1]) == "C6_CF"
				aPed[i,2,j,k,2] := _aTes[2]
			Endif
			
			// Regrava o CLasFis
			If Alltrim(aPed[i,2,j,k,1]) == "C6_CLASFIS"
				aPed[i,2,j,k,2] := _aTes[3]
			Endif
			
			// Regrava a Dt. Entrega
			If Alltrim(aPed[i,2,j,k,1]) == "C6_ENTREG"
				If aPed[i,2,j,k,2] < dDataBase
					aPed[i,2,j,k,2] := dDataBase
				Endif
			Endif
			
			// SSI 68922 - Peder Munksgaard - 13/09/2018
			
			If AllTrim(aPed[i,2,j,k,1])=="C6_SEGUM" .And. Empty(AllTrim(aPed[i,2,j,k,2]))
				
				_cSegUM := Posicione("SB1",1,FWxFilial("SB1")+_cProduto,"B1_SEGUM")
				
				If !Empty(_cSegUM)
					
					aPed[i,2,j,k,2] := _cSegUM
					
				Else
					
					aPed[i,2,j,k,2] := Posicione("SB1",1,FWxFilial("SB1")+_cProduto,"B1_UM")
					
				Endif
				
			Endif
			
			// Fim SSI 68922
			
			
			If !(Alltrim(aPed[i,2,j,k,1]) $ "B1_XCODBAS/B1_XMED/DA1_XCUSTO")
				aadd(aItemPv[j],{aPed[i,2,j,k,1],aPed[i,2,j,k,2],cValid})
			Endif
		Next
		
		If _nQtdVen <> 0 .and. _nPrcVen <> 0
			_nTotPed += (_nQtdVen * _nPrcVen)
		Endif
	Next
	
	If !_lErro
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPV,aItemPv,3)
		
		*'Se Encontrar o Pedido de Venda na Unidade de Destino, n„o considerar um erro... um AVISO() no MT410TOK() retorna como erro, mas, cria o pedido.'*
		dbselectarea("SC5")
		dbsetorder(1)
		dbGoTop()
		If dbseek(xFilial("SC5")+cPed)
			lMsErroAuto := .F.
		Endif
		
		If lMSErroAuto
			MostraErro()
			*'Grava LOG no ato da CriaÁ„o do pedido ------------------------------------------------------------------------------'*
			fGrvlog("ORTA646", "Erro", "EXECAUTO - Problema com a inclus„o do pedido ["+cPed+"]", cEmpAnt, cUnOri, cPed, _xPedAnt)
			
			_cTabelaEx := aPed[i,4,1] + IIF(_lAjuTExp,"-E","")
			
			aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,cPed,_nTotPed,Len(aPed[i,2]),_cTabelaEx,_cCliOri+"-"+_cLojOri,_cCliente+"-"+_cLoja,_dEmissao,dDataBase, "Erro ImportaÁ„o"})
			
			*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
			If !Empty(cUnOri)
				_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{" ", AllTrim(_xPedAnt)})  // Remover Flag
			Endif
			*'--------------------------------------------------------------------------------------------------'*
		Else
			ConfirmSx8() && Henrique-06/11/2018 - Nao estava atualizando a numeracao na SXE/SXF
			// Flag
			dbselectarea("SC5")
			dbsetorder(1)
			if dbseek(xFilial("SC5")+cPed)
				if lAnMarket
					libPed(cPed)
				endif	
				If RecLock("SC5",.F.)
					//SC5->C5_XDTLIB := IIF(lAnMarket,dDataBase,CTOD("")) // Dt. Lib
					If _nVerbRep <> 0 .and. SC5->C5_XVERREP == 0
						SC5->C5_XVERREP:= _nVerbRep
					Endif
					If cEmpAnt == "07" .and. _cCLiente <> _cCliente2
						SC5->C5_CLIENT := _cCliente2
					Endif
					SC5->(MsUnLock())
				Endif
			Endif
			
			*'Grava LOG no ato da CriaÁ„o do pedido ------------------------------------------------------------------------------'*
			fGrvlog("ORTA646", "OK", "ImportaÁ„o OK",cUnOri,cPed, cEmpAnt, cUnOri, cPed, _xPedAnt)
			
			*'InÌcio - Ajusta Dados do Item do Pedido de Destino - M·rcio Sobreira -----------------------------------------------'*
			If cEmpAnt $ "21/22"
				For _Nx := 1 to len(aItemPV)
					DbSelectArea("SC6")
					DbSetOrder(1)
					DbGoTop()
					nPos:= aScan(aItemPV[_Nx],{|x| AllTrim(x[1])=="C6_ITEM"})
					If DbSeek(XFILIAL("SC6")+cPed+aItemPV[_Nx,nPos,2])
						If RecLock("SC6",.F.)
							nPos:= aScan(aItemPV[_Nx],{|x| AllTrim(x[1])=="C6_PRCVEN"})
							SC6->C6_PRCVEN  := aItemPV[_Nx,nPos,2]
							nPos:= aScan(aItemPV[_Nx],{|x| AllTrim(x[1])=="C6_VALOR"})
							SC6->C6_VALOR   := aItemPV[_Nx,nPos,2]
							SC6->C6_XMIX    := U_FMIX(SC6->C6_PRCVEN, SC6->C6_XCUSTO)
							SC6->C6_XMARKUP := U_FMKP(SC6->C6_PRCVEN,SC6->C6_XCUSTO)
							SC6->(MsUnLock())
						Endif
					Endif
				Next
			Endif
			*'Fim    - Ajusta Dados do Item do Pedido de Destino - M·rcio Sobreira -----------------------------------------------'*
			
			_cTabelaEx := aPed[i,4,1] + IIF(_lAjuTExp,"-E","")
			
			aadd(_aLogRet,{cUnOri,cEmpAnt,_xPedAnt,cPed,_nTotPed,Len(aPed[i,2]),_cTabelaEx,_cCliOri+"-"+_cLojOri,_cCliente+"-"+_cLoja,_dEmissao,dDataBase, "ImportaÁ„o OK"})
			
			// Verifica se existe e Deleta BLQMIX, BLQPRZ e BLQSBM
			dbSelectArea("SZE")
			dbOrderNickName("CSZE3")
			If dbSeek(xFilial("SZE")+cPed)
				While !SZE->(EOF()) .and. SZE->ZE_PEDIDO == cPed
					If SZE->ZE_AUTORIZ $ "BLQMIX/BLQPRZ/BQLSBM"
						reclock("SZE",.F.)
						SZE->(DbDELETE())
						SZE->(MsUnLock())
					Endif
					SZE->(DbSkip())
				End
			Endif
			
			// Grava dados da SZE vindo do Pedido Original ////////////////////
			If Len(aBlq) > 0
				For _Nz := 1 to len(aBlq)
					reclock("SZE",.T.)
					SZE->ZE_FILIAL  := XFILIAL("SZE")
					SZE->ZE_PEDIDO  := cPed          // Pedido Atual
					
					SZE->ZE_AUTORIZ := aBlq[_Nz,1]
					SZE->ZE_USUARIO := aBlq[_Nz,2]
					SZE->ZE_DTAUT   := STOD(aBlq[_Nz,3])
					SZE->ZE_OBS     := aBlq[_Nz,4]
					SZE->ZE_MEDTRI	:= aBlq[_Nz,5]
					SZE->ZE_MED30D	:= aBlq[_Nz,6]
					SZE->ZE_VALPED	:= aBlq[_Nz,7]
					SZE->ZE_ULTMES	:= aBlq[_Nz,8]
					SZE->ZE_CUSTRI	:= aBlq[_Nz,9]
					SZE->ZE_CUSMD30	:= aBlq[_Nz,10]
					SZE->ZE_CUSPED	:= aBlq[_Nz,11]
					SZE->ZE_CUSULTM	:= aBlq[_Nz,12]
					
					SZE->(msunlock())
				Next
			Endif
			///////////////////////////////////////////////////////////////////
			
			*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
			//			If !Empty(cUnOri)
			//				_lRetx  := U_ORTXRPC(cUnOri, "U_ORTA646O",{"S", AllTrim(_xPedAnt)})  // M·rcio - Remover o .T.
			//				//			U_ORTA646O("S", AllTrim(_xPedAnt))
			//			Endif
			*'--------------------------------------------------------------------------------------------------'*
			
		EndIf
		
		*'Ajusta Dados da Tabela Expirada se necess·rio - M·rcio Sobreira ----------------------------------'*
		If _lAjuTExp
			DbSelectArea('DA0')
			DbSetOrder(1)
			DbGoTop()
			If Dbseek(xFilial('DA0') + aPed[i,4,1]) // Tabela
				_lAjuTExp  := .F.
				If RecLock("DA0",.F.)
					DA0->DA0_DATATE := _dDtExpAte
					CONOUT("Retornou Tabela Expirada ["+DA0->DA0_CODTAB+"] Dt. AtÈ para : " + DTOC(_dDtExpAte))
					DA0->(MsUnLock())
				Endif
			Endif
		Endif
		*'--------------------------------------------------------------------------------------------------'*
	Endif
	aCabPv:={}
	aItemPv:={}
Next

// Chama RelatÛrio de ImportaÁ„o
If Len(_aLogRet) > 0 .and. !_lJob
	ORTA646R(_aLogRet)
Endif

Return(_aLogRet)

*'Ajusta Dados do Pedido de origem - M·rcio Sobreira -----------------------------------------------'*
User Function ORTA646O(_cFlag, _cPedClx)
Local _aArea := GetArea()
Local _lRet  := .F.

dbselectarea("SC5")
dbsetorder(1)
dbGoTop()
if dbseek(xFilial("SC5")+_cPedClx)
	If RecLock("SC5",.F.)
		SC5->C5_RESREM := _cFlag // Ser· utilizado como Flag
		SC5->(MsUnLock())
		_lRet  := .T.
	Endif
Endif

RestArea(_aArea)
Return(_lRet)
*'--------------------------------------------------------------------------------------------------'*

/*
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ RelatÛrio ImportaÁ„o de pedidos			                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
*/
*******************************************************************************************************
Static FUNCTION ORTA646R(_aDadRel)  // RelatÛrio ImportaÁ„o de pedidos
*******************************************************************************************************
Private cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Private cDesc2       := "de acordo com os parametros informados pelo usuario."
Private cDesc3       := ""
Private cPict        := ""
Private titulo       := "RelatÛrio ImportaÁ„o de pedidos"
Private nLin         := 3200
//                       00        10        20	       30	     40        50	     60	       70        80        90        100       110       120      130
//                       012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901

//                         |0050| 0150| 0250|0350| 0450| 0550| 0650| 0750| 0850|0950|1050|1150|1250|1350|1450|1550|1650|1750|1850|1950|2050|2150|2250|2350|2450|
// POS.	treport			|000 |100  |200  |300  |400  |500  |600  |700  |800  |900 |1000|1100|1200|1300|1400|1500|1600|1700|1800|1900|2000|2100|2200|2300|2400|
Private Cabec1       := "UNIDADE    |* P E D I D O *|              |      |       | ** C L I E N T E ** | ** E M I S S A O ** |                         |"
Private Cabec2       := "ORIG.|DEST.|ORIG.  |DEST.  |TOTAL         |ITENS |TABELA |ORIG.     |DEST.     |ORIG.     |DEST.     |OBSERVA«¬O               |"
Private imprime      := .T.
Private aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "ORTR646"  // Coloque aqui o nome do programa para impressao no cabecalho
///Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "G", 1}
Private nLastKey     := 0
///Private cbtxt        := Space(10)
///Private cbcont       := 00
///Private CONTFL       := 01
///Private m_pag        := 1
Private wnrel        := "ORTR646"  // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg        := "ORT646____"
Private cString      := "SC5"
Private oPrn,oFont1
Private nPag         := 0
Private nEsp         := 40
Private aBox := {   0005,; // Unidade Origem
0100,; // Unidade Destino
0220,; // Pedido Origem
0360,; // Pedido Destino
0520,; // Total
0800,; // Itens
0930,; // Tabela
1050,; // Cliente Origem
1250,; // Cliente Destino
1450,; // Emiss„o Origem
1650,; // Emiss„o Destino
1850}  // ObservaÁ„o


//oFont1:= TFont():New("ARIAL",,12,,.T.)
oFont1:= TFont():New("Courier New",,10,,.T.)
oPrn := TReport():New("0RTA646",Titulo,,{|oPrn| GeraRel(oPrn,_aDadRel)},"RelatÛrio ImportaÁ„o de pedidos")
oPrn:PrintDialog()

Return NIL  // retorno da funcao

******************************************************************************************************
Static Function GeraRel(oPrn,_aDadRel)
******************************************************************************************************
Local nTTNF   := 0
Local nTTICMS := 0
Local nTTANT  := 0
Local _Nx

oPrn:SetPortrait()

//_cDate1 := SUBSTR(DTOS(MV_PAR01),7,2)+"/"+SUBSTR(DTOS(MV_PAR01),5,2)+"/"+SUBSTR(DTOS(MV_PAR01),3,2)
//_cDate2 := SUBSTR(DTOS(MV_PAR02),7,2)+"/"+SUBSTR(DTOS(MV_PAR02),5,2)+"/"+SUBSTR(DTOS(MV_PAR02),3,2)

For _Nx := 1 to Len(_aDadRel)  // percorre todo o arquivo
	
	If nLin > 3000
		ImpCab(oPrn,.T.)
	Endif
	
	oPrn:Say(nLin,aBox[1],_aDadRel[_Nx,1],oFont1)
	oPrn:Say(nLin,aBox[2],"("+_aDadRel[_Nx,2]+")",oFont1)
	oPrn:Say(nLin,aBox[3],_aDadRel[_Nx,3],oFont1)
	oPrn:Say(nLin,aBox[4],"("+_aDadRel[_Nx,4]+")",oFont1)
	
	oPrn:Say(nLin,aBox[5],Transform(round(_aDadRel[_Nx,5],2),"@E 9,999,999.99"),oFont1)
	oPrn:Say(nLin,aBox[6],Transform(round(_aDadRel[_Nx,6],2),"@E 9999"),oFont1)
	
	oPrn:Say(nLin,aBox[7],_aDadRel[_Nx,7],oFont1)
	oPrn:Say(nLin,aBox[8],_aDadRel[_Nx,8],oFont1)
	oPrn:Say(nLin,aBox[9],_aDadRel[_Nx,9],oFont1)
	oPrn:Say(nLin,aBox[10],DTOC(_aDadRel[_Nx,10]),oFont1)
	oPrn:Say(nLin,aBox[11],DTOC(_aDadRel[_Nx,11]),oFont1)
	If Len(Alltrim(_aDadRel[_Nx,12])) <= 35
		oPrn:Say(nLin,aBox[12],_aDadRel[_Nx,12],oFont1)
	Else
		oPrn:Say(nLin,aBox[12],SUBSTR(_aDadRel[_Nx,12],1 ,32),oFont1)
		nLin += nEsp
		oPrn:Say(nLin,aBox[12],SUBSTR(_aDadRel[_Nx,12],33,65),oFont1)
	Endif
	/*
	// ObservaÁ„o
	oPrn:Say(nLin,aBox[5],SUBSTR(Alltrim(QRY1->OBSERV),1,67),oFont1)
	If AllTrim(SUBSTR(Alltrim(QRY1->OBSERV),68,67)) <> ""
	nLin += nEsp
	oPrn:Say(nLin,aBox[5],SUBSTR(Alltrim(QRY1->OBSERV),68,67),oFont1)
	Endif
	If AllTrim(SUBSTR(Alltrim(QRY1->OBSERV),136,67)) <> ""
	nLin += nEsp
	oPrn:Say(nLin,aBox[5],SUBSTR(Alltrim(QRY1->OBSERV),136,67),oFont1)
	Endif
	*/
	
	nLin += nEsp
	
Next

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return  // retorno da funÁ„o

*******************************************************************************************************
Static Function ImpCab(oPrn,lFlag)  //FUNCAO DE IMPRESSAO DO CABECALHO
*******************************************************************************************************
nPag+=1
oPrn:EndPage()
oPrn:SetPortrait()
oPrn:StartPage()
nLin:= 210

oPrn:Say(nLin,00059,Replicate("-",127),oFont1)
nLin+=nEsp
oPrn:Say(nLin,0005,Cabec1,oFont1)
nLin+=nEsp
oPrn:Say(nLin,0005,Cabec2,oFont1)
nLin+=nEsp
oPrn:Say(nLin,0005,Replicate("-",127),oFont1)
nLin+=nEsp

Return(oPrn)

*******************************************************************************************************
User Function ORTA646T(cCliente, cLojaCli, cEstCli, cXOper, cProduto)
*******************************************************************************************************
Local cAreaAtu  := GetArea()
Local cCF       := "    "
Local cTES      := "   "
Local cAliasQRY	:= "TMPTES"


cQuery := ""
cQuery += "SELECT FM_TS, FM_TE, B1_ORIGEM FROM "
cQuery += "	"+RetSqlName("SFM")+" FM ,"
cQuery += "	"+RetSqlName("SB1")+" B1 ,"
cQuery += "	"+RetSqlName("SA1")+" A1 "
cQuery += "	WHERE   FM.D_E_L_E_T_ <> '*' "
cQuery += "		AND B1.D_E_L_E_T_ <> '*' "
cQuery += "		AND A1.D_E_L_E_T_ <> '*'
cQuery += "		AND A1_COD    = '"+cCliente+"' "
cQuery += "		AND A1_LOJA   = '"+cLojaCli+"' "
cQuery += "		AND B1_COD    = '"+cProduto+"' "
cQuery += "		AND FM_TIPO   = '"+cXOper  +"' "
cQuery += "		AND FM_GRTRIB = A1_GRPTRIB "
cQuery += "		AND FM_GRPROD = B1_GRTRIB "
memowrite("C:\ORTA646T.SQL",cQuery)
// TcQuery cQuery Alias cAliasQRY New
if select(cAliasQry) > 0
	(cAliasQRY)->(DbCloseArea())
endif
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), (cAliasQRY), .F., .T.)
DbSelectArea(cAliasQRY)
DbGoTop()

If Eof()
	cTES    := "   "
	cOrigem := " "
	//	MsgBox("TES Inteligente N√O parametrizado para esta OperaÁ„o+Cliente+Produto","Aviso","INFO")
Else
	cTES    := (cAliasQRY)->FM_TS
	cOrigem := (cAliasQRY)->B1_ORIGEM
EndIf

DbSelectArea(cAliasQRY)
(cAliasQRY)->(DbCloseArea())

// Regrava o CF
If cEstCli == GetMV("MV_ESTADO")
	cCF := "5"
ElseIf cEstCli == "EX"
	cCF := "7"
Else
	cCF := "6"
EndIf
cCF += SubStr(Posicione("SF4",1,xFilial("SF4")+cTES,"F4_CF"), 2, 3)

cSitTrib := cOrigem + Posicione("SF4",1,xFilial("SF4")+cTES,"F4_SITTRIB") // B1_ORIGEM + F4_SITTRIB

RestArea(cAreaAtu)

Return({cTES,cCF,cSitTrib})


*************************************
Static Function fBuscRel(_cXCodBas, _cXMed, _cCorte)
*************************************
Local _cNovoCod := ""
Local cAreaAtu  := GetArea()
Local cAliasQRY	:= "TMPPRO"

cQuery := ""
cQuery += " SELECT B1_COD "
cQuery += "	FROM "+RetSqlName("SB1")
cQuery += "	WHERE D_E_L_E_T_ = ' ' "
cQuery += "	AND B1_FILIAL  = '" + XFILIAL("SB1") + "' "
cQuery += "	AND B1_XCODBAS = '" + _cXCodBas + "' "
cQuery += "	AND B1_XMED    = '" + _cXMed    + "' "
If cEmpAnt == "18"
	If _cCorte == "L"
		cQuery += "	AND B1_COD LIKE '%L%' "
	ElseIf _cCorte == "P"
		cQuery += "	AND B1_COD LIKE '%P%' "
	Else
		cQuery += "	AND (B1_COD LIKE '%L%' OR B1_COD LIKE '%P%') "
	Endif
Endif

CONOUT("cQuery: " + cQuery)
memowrite("C:\fBuscRel.SQL",cQuery)
// TcQuery cQuery Alias cAliasQRY New
if select(cAliasQry) > 0
	(cAliasQRY)->(DbCloseArea())
endif
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), (cAliasQRY), .F., .T.)
DbSelectArea(cAliasQRY)
DbGoTop()

If !Eof()
	_cNovoCod := (cAliasQRY)->(B1_COD)
EndIf

DbSelectArea(cAliasQRY)
(cAliasQRY)->(DbCloseArea())

RestArea(cAreaAtu)

Return(_cNovoCod)


*************************************
Static Function fGeraCod(cUnOri, cProduto, _lJob)
*************************************
Local _aArea    := GetArea()
Local _cNovoCod := ""

_aAreaAtu := GetArea()
SaveInter()
aRet := U_ORTXRPC(cUnOri, "U_ORTA646P",{cProduto})  // M·rcio - Remover o .T.
//aRet := U_ORTA646P(cProduto)
RestInter()
RestArea(_aAreaAtu)

If ValType(aRet)<>"A" .and. !_lJob
	Alert("Problemas na conexao com a unidade de Origem ["+cUnOri+"]")
Else
	If Len(aRet) > 0
		If cEmpAnt == '18'
			_cBase  := aRet[1][1][ascan(aRet[1][1], {|X| AllTrim(x[1]) =="B1_XCODBAS"})][2]
			_cMed   := aRet[1][1][ascan(aRet[1][1], {|X| AllTrim(x[1]) =="B1_XMED"})   ][2]
			//_cCorte := Separa( aRet[1][1][ascan(aRet[1][1], {|X| AllTrim(x[1]) =="B1_DESC"})][2]," ")[1]
			_cCorte := U_ORTA646Q(aRet[1][1][ascan(aRet[1][1], {|X| AllTrim(x[1]) =="B1_DESC"})][2])
			If _cCorte == "PECA"
				_cCorte == "PE«A"
			EndIf
			_cNovoCod := "OK"+U_GeraNovoCod(_cBase,_cMed,.f.,SPACE(40),_cCorte,0,SPACE(08))
		ELse
			_cNovoCod := fGrvCod(aRet)
		Endif
	Else
		If !_lJob
			Aviso("AtenÁ„o", "Nenhum dado localizado para este produto!", { "Sair" } )
		Endif
	Endif
Endif

RestArea(_aArea)
Return(_cNovoCod)


*************************************
Static Function fGrvCod(aProd)
*************************************
Local _aArea    := GetArea()
Local _aVetor   := {}
Local _cCodProd := ""
Local _cCeme    := ""
Local J

Private lMsErroAuto := .F.

_cCodProd := fBuscMax()

DbSelectArea("SB1")  // Seleciona arquivo de produtos
SB1->(DbOrderNickName("PSB11"))  // Muda a ordem do Ìndice
If SB1->(!DbSeek(xFilial("SB1")+_cCodProd))  // Posiciona registro
	
	_cXMed   := ""
	
	DbSelectArea("SB1")
	RecLock("SB1",.T.)
	
	For J:=1 to Len(aProd[1,1])
		cValid	:= nil
		
		/*
		// Montagem de array para gravaÁ„o dos produtos
		aVetor := {	{"B1_FILIAL" , xFilial("SB1")    , Nil},;  // Filial
		{"B1_COD"    , _cCodprod         , Nil},;  // CÛdigo do produto
		{"B1_GRUPO"  , aProd[_Ln][3][2]  , Nil},;  // CÛdigo do grupo do produto
		{"B1_TIPO"   , aProd[_Ln][4][2]  , Nil},;  // Tipo do produto
		{"B1_DESC"   , aProd[_Ln][5][2]  , Nil},;  // DescriÁ„o do produto
		{"B1_UM"     , aProd[_Ln][6][2]  , Nil},;  // 1a unidade de medida
		{"B1_SEGUM"  , aProd[_Ln][7][2]  , Nil},;  // 2a unidade de medida
		{"B1_CONV"   , aProd[_Ln][8][2]  , Nil},;  // Fator de convers„o
		{"B1_TIPCONV", aProd[_Ln][9][2]  , Nil},;  // Tipo de convers„o
		{"B1_LOCPAD" , aProd[_Ln][10][2] , Nil},;  // ArmazÈm padr„o
		{"B1_XCOMIND", aProd[_Ln][11][2] , Nil},;  // Com. I
		{"B1_XRESSAR", aProd[_Ln][12][2] , Nil},;  // R. PC
		{"B1_XGUELTA", aProd[_Ln][13][2] , Nil},;  // R. VL
		{"B1_XCOMCOM", aProd[_Ln][14][2] , Nil},;  // R. VC
		{"B1_XBIPART", aProd[_Ln][15][2] , Nil},;  // Bi-Partido
		{"B1_XDIRIGI", aProd[_Ln][16][2] , Nil},;  // Venda dirigida
		{"B1_PESO"   , aProd[_Ln][17][2] , Nil},;  // Peso lÌquido
		{"B1_PESBRU" , aProd[_Ln][18][2] , Nil},;  // Peso bruto
		{"B1_XDENSEQ", aProd[_Ln][19][2] , Nil},;  // Densidade
		{"B1_XFORLI2", aProd[_Ln][20][2] , Nil},;  // Fora de linha
		{"B1_XFORLIN", aProd[_Ln][21][2] , Nil},;  // Data do fora de linha
		{"B1_XSEQIMP", aProd[_Ln][22][2] , Nil},;  // Sequencia de impress„o
		{"B1_XMARKUP", aProd[_Ln][23][2] , Nil},;  // % mark-Up (1)
		{"B1_XGRPTAB", aProd[_Ln][24][2] , Nil},;  // CÛdigo da linha de tabela
		{"B1_XTIPTAB", aProd[_Ln][25][2] , Nil},;  // CÛdigo da tabela
		{"B1_XESPACO", aProd[_Ln][26][2] , Nil},;  // EspaÁo
		{"B1_XPILLOW", aProd[_Ln][27][2] , Nil},;  // Quantidade de pillows
		{"B1_XTPORTO", aProd[_Ln][28][2] , Nil},;  // CÛdigo do tipo de produto ortobom
		{"B1_XLARG"  , aProd[_Ln][29][2] , Nil},;  // Largura padr„o
		{"B1_XCOMP"  , aProd[_Ln][30][2] , Nil},;  // Comprimento padr„o
		{"B1_XALT"   , aProd[_Ln][31][2] , Nil},;  // Altura padr„o
		{"B1_XMED"   , aProd[_Ln][32][2] , Nil},;  // Medida padr„o
		{"B1_XLARGMI", aProd[_Ln][33][2] , Nil},;  // Largura mÌnima
		{"B1_XLARGMA", aProd[_Ln][34][2] , Nil},;  // Largura m·xima
		{"B1_XCOMPMI", aProd[_Ln][35][2] , Nil},;  // Comprimento mÌnimo
		{"B1_XCOMPMA", aProd[_Ln][36][2] , Nil},;  // Comprimento m·ximo
		{"B1_XALTMIN", aProd[_Ln][37][2] , Nil},;  // Altura mÌnima
		{"B1_XALTMAX", aProd[_Ln][38][2] , Nil},;  // Altura m·xima
		{"B1_PRV1"   , aProd[_Ln][39][2] , Nil},;  // PreÁo de venda
		{"B1_MCUSTD" , aProd[_Ln][40][2] , Nil},;  // Moeda do custo
		{"B1_CUSTD"  , aProd[_Ln][41][2] , Nil},;  // Custo standart
		{"B1_XCUSTER", aProd[_Ln][42][2] , Nil},;  // Custo terceiros
		{"B1_XDTINCL", aProd[_Ln][43][2] , Nil},;  // Data de inclus„o do registro
		{"B1_POSIPI" , aProd[_Ln][44][2] , Nil},;  // PosiÁ„o IPI/NCM
		{"B1_ORIGEM" , aProd[_Ln][45][2] , Nil},;  // Origem
		{"B1_GRTRIB" , aProd[_Ln][46][2] , Nil},;  // Grupo de tributaÁ„o
		{"B1_XMODELO", aProd[_Ln][47][2] , Nil},;  // Modelo
		{"B1_XSEGMEN", aProd[_Ln][48][2] , Nil},;  // Segmento
		{"B1_XTPSEGM", aProd[_Ln][49][2] , Nil},;  // Tipo de segmentos
		{"B1_XCODBAS", aProd[_Ln][50][2] , Nil},;  // CÛdigo base
		{"B1_XDESCVE", aProd[_Ln][51][2] , Nil},;  // Nome comercial
		{"B1_XCODUNI", aProd[_Ln][52][2] , Nil},;  // FÛrmula - Unidade de criaÁ„o do produto
		{"B1_RASTRO" , aProd[_Ln][53][2] , Nil},;  // Indica se o produto est· ativo
		{"B1_CODITE" , aProd[_Ln][54][2] , Nil},;  // Indica se o produto est· bloqueado
		{"B1_REQUIS" , aProd[_Ln][55][2] , Nil},;  // Indica se o produto est· bloqueado
		{"B1_ATIVO"  , aProd[_Ln][56][2] , Nil},;  // Indica se o produto est· ativo
		{"B1_MSBLQL" , aProd[_Ln][57][2] , Nil}}   // Indica se o produto est· bloqueado
		*/
		
		// N„o validar os campos
		If Alltrim(aProd[1,1,J,1]) $ "B1_COD/B1_PRODSBP/B1_TPDP/B1_XCODBAS/B1_CONTA/B1_PRODSBP"
			cValid	:= ".T."
		Endif
		
		/*
		// Ignorar os campos
		If cEmpAnt $ "18" .and. Alltrim(aProd[1,1,J,1]) $ "B1_CODISS/B1_MONO/B1_GRADE/B1_OK/B1_FRETISS/B1_CODLAN/B1_DCI/B1_DCRE/B1_DCRII/B1_COEFDCR/B1_XDENSID/B1_PRODSBP"
		Loop
		Endif
		*/
		
		// Regrava o Codigo do produto
		If Alltrim(aProd[1,1,J,1]) == "B1_COD"
			aProd[1,1,J,2] := _cCodProd
		Endif
		
		If !(Alltrim(aProd[1,1,J,1]) $ "B5_CEME/B1_CONTA")
			If Alltrim(aProd[1,1,J,1]) $ "B1_XMED"
				_cXMed := aProd[1,1,j,2]
			Endif
			FieldPut(FieldPos(aProd[1,1,j,1]),aProd[1,1,j,2])
			//			aadd(_aVetor,{aProd[1,1,j,1],aProd[1,1,j,2],cValid})
		Else
			If Alltrim(aProd[1,1,J,1]) == "B5_CEME"
				_cCeme := aProd[1,1,j,2]
			ElseIf Alltrim(aProd[1,1,J,1]) == "B1_CONTA"
				FieldPut(FieldPos(aProd[1,1,j,1]),space(20))
				//				aadd(_aVetor,{aProd[1,1,j,1],space(20),cValid})
			Endif
		Endif
		
	Next
	
	MsUnlock()
	lMsErroAuto := .F.
	
	//	MSExecAuto({|x,y| MATA010(x,y)},_aVetor,3)  // Inclus„o
	If lMsErroAuto
		MostraErro()
	Else
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbGoTop()
		If DbSeek(XFILIAL("SB1")+_cCodProd)
			If !Empty(_cXMed)
				If RecLock("SB1",.F.)
					SB1->B1_XMED   := _cXMed
					SB1->(MsUnLock())
				Endif
			Endif
		Endif
		
		// Cria registro na SB5
		If !Empty(_cCeme)
			DbSelectArea("SB5")
			If RecLock("SB5",.T.)
				SB5->B5_FILIAL := XFILIAL("SB5")
				SB5->B5_COD    := _cCodProd
				SB5->B5_CEME   := _cCeme
				SB5->(MsUnLock())
			Endif
		Endif
	EndIf
Endif

Return(IIF(!lMsErroAuto,"OK","Er") + _cCodProd)

*************************************
Static Function fBuscMax(cCodBase, cCorte, cModelo)
*************************************
Local _cNovoCod := ""
Local _aArea    := GetArea()
Default cCodBase:= "1"
Default cCorte  := "MANTA"
Default cModelo := "000014"

//aAdd(aCorte, "LAMINADO")
//aAdd(aModelo,"000008")


if cCorte == nil .or. cCorte == "COLCH√O"
	cCod1:=substr(cCodBase,1,6)
else
	nDens:= 1  //SB1->B1_XDENSEQ
	if cCorte =="MANTA" .AND. cEmpAnt == "22"
		cCod1:="104011"
		nDens:=1
	elseIf Substr(cCorte,1,4) =="SACO" .or. Substr(cCorte,1,6) =="BOBINA" //BOB E SACO CIAPLAST
		cCod1:="101010"
		nDens:=0.922
	elseIf Substr(cCorte,1,7) =="LAMINA ".or. Substr(cCorte,1,5) =="FILME" // LAMINA CIAPLAST
		cCod1:="101020"
		nDens:=0.922
	Else
		if cCorte == "LAMINADO" .or. cCorte == "PLACA"
			if nDens>22
				cCod1:="202011"
			else
				cCod1:="202021"
			endif
		else
			if cCorte =="BLOCO"
				if nDens>22
					cCod1:="201011"
				else
					cCod1:="201021"
				endif
			else
				
				if cCorte =="TORNEADO"
					if nDens>22
						cCod1:="203011"
					else
						cCod1:="203021"
					endif
				else
					if cCorte =="PROTETORES"
						cCod1:="104071"
					else //PECA e CHANFRADO
						if nDens>22
							cCod1:="210011"
						else
							cCod1:="210021"
						endif
					endif
				endif
			endif
		endif
	endif
endif

cQuerySB1 := "SELECT MAX(B1_COD) B1_COD "
cQuerySB1 += "       FROM " + RetSqlName("SB1") + " "
cQuerySB1 += "       WHERE D_E_L_E_T_ = ' '"
cQuerySB1 += "       	   AND B1_FILIAL = '" + XFILIAL("SB1") + "' "
cQuerySB1 += "       	   AND B1_XCODBAS <> ' ' "
cQuerySB1 += "       	   AND B1_XMED    <> ' ' "
If cEmpAnt == "22" .and. cCorte == "MANTA" .and. cModelo == "000014"
	cQuerySB1 += "       	   AND SUBSTR(B1_COD,1,6) IN ('104012') "
Endif
CONOUT("cQuerySB1: " + cQuerySB1)
memowrite("C:\fBuscMax.SQL",cQuerySB1)

IF SELECT("TMPSB1") > 0
	DBSELECTAREA("TMPSB1")
	DBCLOSEAREA()
ENDIF

TcQuery cQuerySB1 ALIAS "TMPSB1" NEW

If !EOF()
	cCod1:=substr(TMPSB1->B1_COD,1,6)
	cCod2:=substr(TMPSB1->B1_COD,7,4)
	If SubStr(cCod2,1,1) $ "1234567890"
		cCod2 := "A000"
	Endif
	
	if SubStr(cCod2,2,3) == "999"
		cCod2 := soma1(SubStr(cCod2,1,1))+"001"
	Else
		dbselectarea("SB1")
		dbOrderNickName("PSB11")
		cCod2 := SubStr(cCod2,1,1)+soma1(SubStr(cCod2,2,3))
		while dbseek(xFilial("SB1")+cCod1+cCod2+SPACE(5))
			cCod2 := SubStr(cCod2,1,1)+soma1(SubStr(cCod2,2,3))
		enddo
	EndIf
	
	_cCod := cCod1+cCod2
	
	_cNovoCod := PADR(_cCod,TAMSX3("B1_COD")[1])
	CONOUT("_cNovoCod:" + _cNovoCod)
Endif

dbCloseArea("TMPSB1")

RestArea(_aArea)
Return(_cNovoCod)

*************************************
Static Function fBusCond(_cTipo, _cCond, _cDDD)
*************************************
Local _cCodCond := ""
Local _aArea    := GetArea()

cQuerySE4 := " SELECT E4_CODIGO "
cQuerySE4 += " FROM  " + RetSqlName("SE4") + " "
cQuerySE4 += " WHERE E4_FILIAL = '  '
cQuerySE4 += " AND D_E_L_E_T_ = ' '
cQuerySE4 += " AND E4_TIPO = '"+_cTipo+"'
cQuerySE4 += " AND E4_COND = '"+_cCond+"'
cQuerySE4 += " AND E4_DDD  = '"+_cDDD +"'
CONOUT("cQuerySE4: " + cQuerySE4)
memowrite("C:\fBusCond.SQL",cQuerySE4)

IF SELECT("TMPSE4") > 0
	DBSELECTAREA("TMPSE4")
	DBCLOSEAREA()
ENDIF

TcQuery cQuerySE4 ALIAS "TMPSE4" NEW

If !EOF()
	_cCodCond := TMPSE4->E4_CODIGO
Endif

dbCloseArea("TMPSE4")

RestArea(_aArea)
Return(_cCodCond)

*************************************
Static Function fBuscBlq(_cNumero)
*************************************
Local _aRet  := {.F.,.T.} // .F. Possui bloqueios comerciais? // .T. Liberado Bloqueio?
Local _aArea := GetArea()

cQuerySZE := " SELECT * "
cQuerySZE += " FROM  " + RetSqlName("SZE") + " "
cQuerySZE += " WHERE ZE_FILIAL = '"+XFILIAL("SZE")+"' "
cQuerySZE += " AND D_E_L_E_T_  = ' ' "
cQuerySZE += " AND ZE_PEDIDO   = '" + _cNumero + "' "
CONOUT("fBuscBlq: " + cQuerySZE)
memowrite("C:\fBuscBlq.SQL",cQuerySZE)
IF SELECT("TMPSZE") > 0
	DBSELECTAREA("TMPSZE")
	DBCLOSEAREA()
ENDIF

TcQuery cQuerySZE ALIAS "TMPSZE" NEW

If !TMPSZE->(EOF())
	While !TMPSZE->(EOF())
		If TMPSZE->ZE_AUTORIZ $ "BLQMIX/BLQPRZ/BQLSBM"
			_aRet[1] := .T.
			If Empty(TMPSZE->ZE_DTAUT)
				_aRet[2] := .F.
			Endif
		Endif
		TMPSZE->(DbSkip())
	End
End

dbCloseArea("TMPSZE")
RestArea(_aArea)
Return(_aRet)

*************************************
User Function ORTA646Z(_cNumero)
*************************************
Local _aRet  := {}
Local _aArea := GetArea()

cQuerySZE := " SELECT * "
cQuerySZE += " FROM  " + RetSqlName("SZE") + " "
cQuerySZE += " WHERE ZE_FILIAL = '"+XFILIAL("SZE")+"' "
cQuerySZE += " AND D_E_L_E_T_  = ' ' "
cQuerySZE += " AND ZE_PEDIDO   = '" + _cNumero + "' "
cQuerySZE += " AND ZE_AUTORIZ IN ('BLQMIX','BLQPRZ','BQLSBM') "

CONOUT("ORTA646Z: " + cQuerySZE)
memowrite("C:\ORTA646Z.SQL",cQuerySZE)

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

**************************************************
User FUNCTION ORTA646J(cEmpExec, cFilExec, xParJob)
**************************************************
Local _aDadRel  := {}
Local _nX, _Nb, _Nc 
Local cDesc1	:= "Este programa tem como objetivo Importar automaticamente os "
Local cDesc2	:= "Pedidos [EUN] Oper.13(Origem) -> Oper. 14(Destino) "
Local cDesc3	:= ""
Local _aUnid	:= {}
//Local _aUniOri  := {"02","04"}	// Unidades de Origem
Local _aUniOri  := {"02","03","18","04","05","06","07","23","24","08","09","10","11","26","15","21","22"}	// Unidades de Origem

_aUnid	:= U_ORTPJOBU(cEmpExec, cFilExec)

cAnexos:=""
For _Nx := 1 To Len(_aUnid)
	CONOUT("Len(_aUnid): " + AllTrim(Str(Len(_aUnid))))
	U_JobCInfo("ORTA646.PRW", "Len(_aUnid): " + AllTrim(Str(Len(_aUnid))), 2)
	
	PREPARE ENVIRONMENT EMPRESA _aUnid[_Nx][1] FILIAL _aUnid[_Nx][2]
	CONOUT("EMPRESA: " + cEmpAnt + " FILIAL: "+ cFilAnt)
	U_JobCInfo("ORTA646.PRW", "EMPRESA: " + cEmpAnt + " FILIAL: "+ cFilAnt, 2)
	
	ErrorBlock({|e| U_JobCInfo("ORTA646.PRW", StrTran(StrTran(e:ErrorStack, CHR(10), " "), CHR(13), " "), 0), UserException(e:ErrorStack) })
	
	U_ORTPJOBM(xParJob)
	
	CONOUT("ORTA646.PRW - Inicio")
	U_JobCInfo("ORTA646.PRW", "Inicio", 2)
	
	// InÌcio Processo --------------------------------------------------
	For _Nb := 1 to len(_aUniOri)
		_aDadRel := U_ORTA646S(_aUniOri[_Nb])
		
		If ValType(_aDadRel)<>"A"
			CONOUT("Problemas na conexao com a unidade de Origem ["+_aUniOri[_Nb]+"]")
			U_JobCInfo("ORTA646.PRW", "Problemas na conexao com a unidade de Origem ["+_aUniOri[_Nb]+"]", 2)
		Else
			If Len(_aDadRel) >= 1
				CONOUT("Achou dados na Empresa: " + cEmpAnt)
				U_JobCInfo("ORTA646.PRW", "Achou dados na Empresa: " + cEmpAnt, 2)
				_cPedidos := ""
				
				cBody := ""
				cBody := "<html><title> IMPORTA«¬O DE PEDIDO DE VENDA ENTRE UNIDADES </title>"
				cBody += "<style type='text/css'>"
				cBody += "p {font: 13pt courier new, courier;}"
				cBody += "</style><body><p>"
				cBody += Repl("&nbsp",40)+" PEDIDOS DE VENDA ENTRE UNIDADES IMPORTADOS AUTOMATICAMENTE"
				cBody += "<br>"
				cBody += "  "+Replicate("-",132)
				cBody += "<br>"
				cBody += "|UNIDADE"+Repl("&nbsp",4)+"|* P E D I D O *|"+Repl("&nbsp",14)+"|"+Repl("&nbsp",6)+"|"+Repl("&nbsp",7)+"| ** C L I E N T E ** | ** E M I S S A O ** |"+Repl("&nbsp",25)+"|"
				cBody += "<br>"
				cBody += "|ORIG.|DEST.|ORIG."+Repl("&nbsp",2)+"|DEST."+Repl("&nbsp",2)+"|TOTAL"+Repl("&nbsp",9)+"|ITENS |TABELA |ORIG."+Repl("&nbsp",5)+"|DEST."+Repl("&nbsp",5)+"|ORIG."+Repl("&nbsp",5)+"|DEST."+Repl("&nbsp",5)+"|OBSERVA«¬O"+Repl("&nbsp",15)+"|"
				cBody += "<br>"
				cBody += Replicate("-",132)
				
				For _Nc := 1 to Len(_aDadRel)  // percorre todo o arquivo
					// Linha
					cBody += "<br>"
					cBody += _aDadRel[_Nc,1] + Repl("&nbsp",5) + _aDadRel[_Nc,2] + Repl("&nbsp",4) + _aDadRel[_Nc,3] + Repl("&nbsp",2) + _aDadRel[_Nc,4] + Repl("&nbsp",5)
					cBody += Transform(round(_aDadRel[_Nc,5],2),"@E 9,999,999.99")  + Repl("&nbsp",5)
					cBody += Transform(round(_aDadRel[_Nc,6],2),"@E 9999")  + Repl("&nbsp",5)
					cBody += _aDadRel[_Nc,7] + Repl("&nbsp",5)
					cBody += _aDadRel[_Nc,8] + Repl("&nbsp",2)
					cBody += _aDadRel[_Nc,9] + Repl("&nbsp",2)
					cBody += DTOC(_aDadRel[_Nc,10]) + Repl("&nbsp",3)
					cBody += DTOC(_aDadRel[_Nc,11]) + Repl("&nbsp",3)
					cBody += _aDadRel[_Nc,12]
				Next
				
				cBody += "</p></body>"
				MemoWrit("pedidos_eun_de_"+_aUniOri[_Nb]+"_para_"+cEmpAnt+".htm",cBody)
				//					Memowrit("c:\aaa\pedidos_eun_de"+_aUniOri[_Nb]+"_para_"+cEmpAnt+".htm",cBody)
				cAnexos+="/system/pedidos_eun_de_"+_aUniOri[_Nb]+"_para_"+cEmpAnt+".htm;"
			Endif
		Endif
		
	Next
	
	cBody  :="Segue em anexo a RelaÁ„o dos pedidos entre Unidade (EUN) Unid.: " + cEmpAnt+CHR(13)+CHR(10)
	cBody  += "<br>"
	
	If 	   cEmpAnt == "02"
		_cUsuarios :=   "rodrigo.cruz@ortobom.com.br;"+;
		"cleiton.lacerda@ortobom.com.br;"+;
		"wellington.soares@ortobom.com.br;"+;
		"bruno.machado@ortobom.com.br;"+;
		"comercialsp@ortobom.com.br;"+;
		"comercialsp02@ortobom.com.br;"+;
		"comercialsp03@ortobom.com.br;"+;
		"marcel.andrade@ortobom.com.br;"+;
		"magazinesp@ortobom.com.br"
	ElseIf cEmpAnt == "03"
		_cUsuarios := 	"magazinerj@ortobom.com.br;"+;
		"comercialrj01@ortobom.com.br;"+;
		"ricardo.green@ortobom.com.br"
	ElseIf cEmpAnt == "18"
		_cUsuarios := 	"vinicius.machado@flexfoam.com.br;"+;
		"comercial@flexfoam.com.br"
	ElseIf cEmpAnt == "04"
		_cUsuarios := 	"sirlandioferreira@ortobom.com.br;"+;
		"marcelocorrea@ortobom.com.br;"+;
		"diegosilva@ortobom.com.br;"+;
		"comercialmg01@ortobom.com.br;"+;
		"comercialmg02@ortobom.com.br;"+;
		"supervisormg01@ortobom.com.br"
	ElseIf cEmpAnt == "05"
		_cUsuarios := 	"kleberdourado@ortobom.com.br;"+;
		"cachoeira@ortobom.com.br;"+;
		"heitor.santos@ortobom.com.br;"+;
		"erlon.dias@ortobom.com.br;"+;
		"wallyson.morais@ortobom.com.br;"+;
		"maurilio.santos@ortobom.com.br;"+;
		"comercialgo04@ortobom.com.br;"+;
		"comercialgo01@ortobom.com.br;"+;
		"comercialgo03@ortobom.com.br;"+;
		"comercialgo02@ortobom.com.br;"+;
		"wesley.pereira@ortobom.com.br;"+;
		"bruno.nunes@ortobom.com.br;"+;
		"cleomar.pereira@ortobom.com.br"
	ElseIf cEmpAnt == "06"
		_cUsuarios := 	"juliosantos@ortobom.com.br;"+;
		"cezarzysko@ortobom.com.br;"+;
		"tiago.santos@ortobom.com.br;"+;
		"comercialmt03@ortobom.com.br;"+;
		"comercialmt@ortobom.com.br;"+;
		"comercialmt01@ortobom.com.br;"+;
		"diomaralves@ortobom.com.br;"+;
		"comercialmt02@ortobom.com.br"
	ElseIf cEmpAnt == "07"
		_cUsuarios := 	"fernandocorreia@ortobom.com.br;"+;
		"romuloserrano@ortobom.com.br;"+;
		"eduardobaqueiro@ortobom.com.br;"+;
		"adrianogidi@ortobom.com.br;"+;
		"comercialba01@ortobom.com.br;"+;
		"comercialba04@ortobom.com.br;"+;
		"comercialba02@ortobom.com.br;"+;
		"comercialba05@ortobom.com.br;"+;
		"italo.rego@ortobom.com.br;"+;
		"elton.alves@ortobom.com.br;"+;
		"thiago.ruben@ortobom.com.br;"+;
		"danilo.roma@ortobom.com.br"
	ElseIf cEmpAnt == "23"
		_cUsuarios := 	"erley.vieira@flexcoil.com.br;"+;
		"alan.cerqueira@flexcoil.com.br;"+;
		"mario.augusto@flexcoil.com.br;"+;
		"comercial@flexcoil.com.br"
	ElseIf cEmpAnt == "24"
		_cUsuarios := 	"alexandre.marino@ciaplast.com.br;"+;
		"jose.carlos@ciaplast.com.br;"+;
		"comercial@ciaplast.com.br"
	ElseIf cEmpAnt == "08"
		_cUsuarios := 	"rafaelportella@ortobom.com.br;"+;
		"fernando.nascimento@ortobom.com.br;"+;
		"aureo.monteiro@ortobom.com.br;"+;
		"pablo.cristian@ortobom.com.br;"+;
		"robertomendes@ortobom.com.br;"+;
		"comerciape01@ortobom.com.br;"+;
		"comercialpe02@ortobom.com.br;"+;
		"comercialpe04@ortobom.com.br;"+;
		"stenio.okita@ortobom.com.br;"+;
		"renato.vasconselos@ortobom.com.br;"+;
		"erivelton.oliveira@ortobom.com.br"
	ElseIf cEmpAnt == "09"
		_cUsuarios := 	"raphael.villela@ortobom.com.br;"+;
		"rafael.aldir@ortobom.com.br;"+;
		"leandro.rios@ortobom.com.br;"+;
		"roberto.teixeira@ortobom.com.br;"+;
		"luiz.moura@ortobom.com.br;"+;
		"comercialce02@ortobom.com.br;"+;
		"comercialce03@ortobom.com.br;"+;
		"claudio.augusto@ortobom.com.br;"+;
		"paulo.esdras@ortobom.com.br"
	ElseIf cEmpAnt == "10"
		_cUsuarios := 	"guilhermegoes@ortobom.com.br;"+;
		"carloslopes@ortobom.com.br;"+;
		"antonio.edson@ortobom.com.br;"+;
		"edmilson.perandre@ortobom.com.br;"+;
		"comercialpr02@ortobom.com.br;"+;
		"comercialpr01@ortobom.com.br;"+;
		"comercialpr04@ortobom.com.br;"+;
		"comercialpr03@ortobom.com.br"
	ElseIf cEmpAnt == "11"
		_cUsuarios := 	"ramon.reis@ortobom.com.br;"+;
		"thiago.conde@ortobom.com.br;"+;
		"jefferson.matias@ortobom.com.br;"+;
		"antony.monteiro@ortobom.com.br;"+;
		"comercialpa01@ortobom.com.br;"+;
		"sandro.souza@ortobom.com.br;"+;
		"odirlei.almeida@ortobom.com.br"
	ElseIf cEmpAnt == "26"
		_cUsuarios := 	"rafael.desouza@ortobom.com.br;"+;
		"joao.lopes@ortobom.com.br;"+;
		"lucas.xavier@ortobom.com.br;"+;
		"comercialam@ortobom.com.br"
	ElseIf cEmpAnt == "15"
		_cUsuarios := 	"hamiltonmeirelles@ortobom.com.br;"+;
		"rodrigo.oliveira@ortobom.com.br;"+;
		"rubineigossler@ortobom.com.br;"+;
		"eduardo.doutrelepont@ortobom.com.br;"+;
		"adriano.maica@ortobom.com.br;"+;
		"comercialrs02@ortobom.com.br;"+;
		"comercialrs@ortobom.com.br;"+;
		"comercialrs@ortobom.com.br;"+;
		"comercialrs03@ortobom.com.br;"+;
		"comercialrs01@ortobom.com.br"
	ElseIf cEmpAnt == "21"
		_cUsuarios := 	"ortofio@ortofio.com.br;"+;
		"paulo.henrique@ortofio.com.br"
	ElseIf cEmpAnt == "22"
		_cUsuarios := 	"sergiovalim@allfibra.com.br;"+;
		"heberpereira@allfibra.com.br;"+;
		"eduardo.henrique@allfibra.com.br"
	Endif
	
	// Envia o E-mail
	EnvMail(_cUsuarios,cBody,SUBSTR(cAnexos,1,Len(cAnexos)-1))
	
	CONOUT("ORTA646.PRW - Fim")
	U_JobCInfo("ORTA646.PRW", "Fim", 2)
	
	// Fim Processo --------------------------------------------------
	U_ORTPJOBC()
	
	ErrorBlock()
	RESET ENVIRONMENT
	RPCSetType(3)
	
	*'Processa apenas 1 vez'*
	Exit
	*'---------------------'*
Next

Return

***************************************
Static Function AlinHtm(cVar,nTam,cAl)
***************************************
Local cRet:=alltrim(cVar)
Local i:=0
if cAl==Nil
	cAl:="E"
endif
if cAl=="E"
	cRet:=" "+cRet
	for i:=len(cRet) to nTam-1
		cRet:="&nbsp"+cRet
	next
else
	for i:=len(cRet) to nTam
		cRet+="&nbsp"
	next
endif
Return(cRet)

***************************************
Static Function EnvMail(cMail,cBody,cAnexos)
***************************************
Local cServer  :="10.0.100.102"
Local cAccount :="sistema"
Local cPassword:="sis7823@w"
Local cFrom    :="sistema@ortobom.com.br"
Local cTo      :=cMail
Local cSubject :="[sigo] - ImportaÁ„o Pedidos EUN Unid.: " + cEmpAnt
Local ccc      :=""

CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk
If lOk
	if !MailAuth(cAccount,cPassword)
		CONOUT("Erro de AutenticaÁ„o")
		U_JobCInfo("ORTA646.PRW", "Erro de AutenticaÁ„o", 2)
		DISCONNECT SMTP SERVER
		CONOUT("Servidor de e-mail desconectado!")
		U_JobCInfo("ORTA646.PRW", "Servidor de e-mail desconectado!", 2)
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
			U_JobCInfo("ORTA646.PRW", "Problemas no envio para o email: "+cTo, 2)
		EndIf
	EndIf
Else
	CONOUT("Problemas na conex„o com o servidor de email")
	U_JobCInfo("ORTA646.PRW", "Problemas na conex„o com o servidor de email", 2)
EndIf

DISCONNECT SMTP SERVER

Return

**************************************************
User Function ORTA646S(cUnOri)
**************************************************
Local aPergs  := {}
Local aRet    := {}
Local aIps    := U_FRetUnidades()
Local _aLogPed := {}

CONOUT("cUnOri: " + cUnOri)
U_JobCInfo("ORTA646.PRW", "cUnOri: " + cUnOri, 2)

nPos:= aScan(aIps,{|x| x[1]==cUnOri})
if nPos==0
	CONOUT("Unidade Invalida")
	U_JobCInfo("ORTA646.PRW", "Unidade Invalida", 2)
	Return()
Else
	//	_aAreaAtu := GetArea()
	//	SaveInter()
	aPed := U_ORTXRPC(cUnOri, "U_ORTA646A",{cEmpAnt})  // M·rcio - Remover o .T.
	//	RestInter()
	//	RestArea(_aAreaAtu)
	
	If ValType(aPed)<>"A"
		CONOUT("Problemas na conexao com a unidade de Origem ["+cUnOri+"]")
		U_JobCInfo("ORTA646.PRW", "Problemas na conexao com a unidade de Origem ["+cUnOri+"]", 2)
	Else
		If Len(aPed) > 0
			_aLogPed := GravaPed(aPed, cUnOri,.T.)
		Else
			CONOUT("Nenhum pedido localizado para esta empresa de Origem!")
			U_JobCInfo("ORTA646.PRW", "Nenhum pedido localizado para esta empresa de Origem!", 2)
		Endif
	Endif
	
Endif
Return(_aLogPed)

**************************************************
Static Function fGrvlog(_cRotina, _cStatus, _cObserv, _cUnDes, _cUnOri, _cPedDes, _cPedOri)
**************************************************
Local _aArea := GetArea()

DbSelectArea("ZZI")
If RecLock("ZZI",.T.)
	ZZI->ZZI_FILIAL := XFILIAL("ZZI")
	ZZI->ZZI_USU    := cUserName
	ZZI->ZZI_DTLOG  := dDataBase
	ZZI->ZZI_HORA   := SUBSTR(TIME(),1,5)
	ZZI->ZZI_ROTINA := _cRotina
	ZZI->ZZI_STATUS := _cStatus
	ZZI->ZZI_OBSERV := _cObserv
	ZZI->ZZI_UNDES  := _cUnDes
	ZZI->ZZI_UNORI  := _cUnOri
	ZZI->ZZI_PEDDES := _cPedDes
	ZZI->ZZI_PEDORI := _cPedOri
	ZZI->(MsUnLock())
Endif

RestArea(_aArea)
Return

*'-T E S T E -------------------------------------------------------------------------------------'*
**************************************************
User FUNCTION ORTA646X(_cUnid)
**************************************************
Processa( {|| ORTA646W(_cUnid) },"Aguarde...","Importando Unidade...")
Return

**************************************************
Static FUNCTION ORTA646W(_cUnid)
**************************************************

_aIps := U_FRetUnidades()

nPos:= aScan(_aIps,{|x| x[1]==_cUnid})

cEnv := _aIps[nPos,4] //"COMPRJ"
oRpcSrv := TRpc():New( cEnv )

// Conecta no ambiente
cServer := _aIps[nPos,2]
nPort   := _aIps[nPos,3]

If ( oRpcSrv:Connect( cServer, nPort ) )
	ProcRegua(0)
	INCPROC("Importando Unidade...")
	INCPROC("Importando Unidade...")
	
	INCPROC("Importando Unidade..." + _aIPs[nPos,1])
	
	Processa({|| oRpcSrv:CallProcEX('U_ORTA646J', _aIps[nPos,5], _aIps[nPos,6], "") },"Importando Pedidos...")
	
	// Fecha conex„o
	oRpcSrv:Disconnect()
Else
	UserException('Conex„o RPC com Regional falhou...')
Endif

Return
*'-T E S T E -------------------------------------------------------------------------------------'*

**************************************************
User Function ORTA646Q(cProduto)
**************************************************
Local aPCorte	:= {}
Local cCorte	:= ""
Local ix		:= 1

aAdd(aPCorte, "MANTA")
aAdd(aPCorte, "COLCHAO")
aAdd(aPCorte, "COLCH√O")
aAdd(aPCorte, "LAMINADO")
aAdd(aPCorte, "PECA")
aAdd(aPCorte, "PE«A")
aAdd(aPCorte, "TORNEADO")
aAdd(aPCorte, "BLOCO")
aAdd(aPCorte, "CHANFRADO")
aAdd(aPCorte, "PROTETORES")
aAdd(aPCorte, "PLACA")
aAdd(aPCorte, "ROLETE")
aAdd(aPCorte, "PERFILADO")
aAdd(aPCorte, "TRAVESSEIRO")

For ix := 1 to len(aPCorte)
	If AT( aPCorte[ix], cProduto ) > 0
		cCorte := aPCorte[ix]
		exit
	Endif
Next ix

Return cCorte

// Verifica se CNPJ Existe na Empresa Destino ///////////////////////////////////////////////
User Function ORTA646K(aDados,_cRpc,cUnOri,cCnpj)
Local _aRet 	:= {"OK",""}

DbSelectArea('SA1')
DbSetOrder(3)
DbGoTop()
If !Dbseek(xFilial('SA1') + cCnpj) // CNPJ
	CONOUT("ORTA646K: n„o existe ["+cCnpj+"] na Unidade ["+cUnOri+"] criando...")
	_aRet := U_ORTA646C(aDados,_cRpc,cUnOri)
Else
	CONOUT("ORTA646K: Existe ["+cCnpj+"] na Unidade ["+cUnOri+"] ")
Endif

Return(_aRet)

**************************************************
User Function ORTA646C(aDados,_cRpc,cUnOri)
**************************************************
Local cCodCli	:= GetSXENum("SA1","A1_COD")
Local cNovoVend := ""
Local lOutros   := .T.
Local _aArea := getArea()
Local nPos := 0
Local _cA1Est := ""
Local _cA1Pessoa := ""
Local _cA1GrTrib := ""
Local _nx

DbSelectArea("SA1")
dbOrderNickName("PSA11")
dbSeek(xFilial("SA1") + cCodCli)
Do While Found()
	confirmSX8()
	cCodCli := GetSXENum("SA1","A1_COD")
	dbGoTop()
	dbseek(xFilial("SA1")+cCodCli)
EndDo

CONOUT("ORTA646C: novo CÛdigo ["+cCodCli+"] cliente")

cNovoVend   := "000001"                                                                               
if !empty(alltrim(aDados[aScan(aDados,{|x|Alltrim(x[1])=="A1_XORIENT"})][2]))
	cNovoOrient := "000001"
Else
	cNovoOrient := space(6)
Endif

if type("lAnMarket") <> 'L'
	lAnMarket := .f.
endif
if !lAnMarket
	_cA1Mes := U_ORTA704G(aDados[aScan(aDados,{|x|Alltrim(x[1])=="A1_MENSAGE"})][2])
endif

nPos := Ascan(aDados,{|x| alltrim(x[1]) == "A1_EST"})
_cA1Est := ""
if nPos > 0
	_cA1Est := aDados[nPos,2]
endif
nPos := Ascan(aDados,{|x| alltrim(x[1]) == "A1_PESSOA"})
_cA1Pessoa := ""
if nPos > 0
	_cA1Pessoa := aDados[nPos,2]
endif
_cA1GrTrib := U_ORTP043G(_cA1Est,_cA1Pessoa,cEmpAnt)

DbSelectArea("SA1")
RecLock("SA1",.T.)

For _nx := 1 To Len(aDados)
	
	If Alltrim(aDados[_nx][1]) == "A1_FILIAL"
		FieldPut(FieldPos(aDados[_nx][1]),xFilial("SA1"))
		lOutros   := .F.
	endif
	If Alltrim(aDados[_nx][1]) == "A1_COD"
		FieldPut(FieldPos(aDados[_nx][1]),cCodCli)
		lOutros   := .F.
	endif
	If Alltrim(aDados[_nx][1]) == "A1_XCODGRU"
		FieldPut(FieldPos(aDados[_nx][1]),cCodCli)
		lOutros   := .F.
	endif
	If Alltrim(aDados[_nx][1]) == "A1_XCGC"
		FieldPut(FieldPos(aDados[_nx][1]),"IMPORTACAO07")
		lOutros   := .F.
	endif
	if !lAnMarket
		If Alltrim(aDados[_nx][1]) == "A1_MENSAGE"
			FieldPut(FieldPos(aDados[_nx][1]), _cA1Mes)
			//SA1->A1_MENSAGE := U_ORTA704G(aDados[_nx][2])
			lOutros   := .F.
		endif
	endif
		
	If Alltrim(aDados[_nx][1]) == "A1_VEND"
		FieldPut(FieldPos(aDados[_nx][1]),cNovoVend)
		lOutros   := .F.
	endif
	If Alltrim(aDados[_nx][1]) == "A1_XORIENT"
		FieldPut(FieldPos(aDados[_nx][1]),cNovoOrient)
		lOutros   := .F.
	endif
	If Alltrim(aDados[_nx][1]) == "A1_CODPAIS"
		FieldPut(FieldPos(aDados[_nx][1]),"01058")
		lOutros   := .F.
	Endif
	If Alltrim(aDados[_nx][1]) == "A1_XDTCRIA"
		FieldPut(FieldPos(aDados[_nx][1]),dDataBase)
		lOutros   := .F.
	Endif
	If Alltrim(aDados[_nx][1]) == "A1_XROTA"
		FieldPut(FieldPos(aDados[_nx][1]),"000000")
		lOutros   := .F.
	Endif
	If Alltrim(aDados[_nx][1]) == "A1_NROCOM"
		FieldPut(FieldPos(aDados[_nx][1]),1)
		lOutros   := .F.
	Endif
	
	CONOUT("FUNNAME " + FUNNAME())
	If "RPC:JOB" $ FUNNAME()
		lAnMarket := .F.
	Endif	

	if lAnMarket .and. !Empty(_cA1GrTrib)
		If cEmpAnt=="09"
			If Alltrim(aDados[_nx][1]) == "A1_TIPO"
				FieldPut(FieldPos(aDados[_nx][1]),"R")
				lOutros   := .F.
			Endif
			If Alltrim(aDados[_nx][1]) == "A1_CONTRIB"
				FieldPut(FieldPos(aDados[_nx][1]),"1")
				lOutros   := .F.
			Endif
		endif
		If Alltrim(aDados[_nx][1]) == "A1_GRPTRIB"
			FieldPut(FieldPos(aDados[_nx][1]),_cA1GrTrib)
			lOutros := .F.
		Endif
	else
		If cEmpAnt=="09"
			If Alltrim(aDados[_nx][1]) == "A1_TIPO"
				FieldPut(FieldPos(aDados[_nx][1]),"R")
				lOutros   := .F.
			Endif
			If Alltrim(aDados[_nx][1]) == "A1_GRPTRIB"
				FieldPut(FieldPos(aDados[_nx][1]),"001")
				lOutros   := .F.
			Endif
			If Alltrim(aDados[_nx][1]) == "A1_CONTRIB"
				FieldPut(FieldPos(aDados[_nx][1]),"1")
				lOutros   := .F.
			Endif
		Else
			If Alltrim(aDados[_nx][1]) == "A1_GRPTRIB"
				FieldPut(FieldPos(aDados[_nx][1]),"999")
				lOutros   := .F.
			Endif
			
		Endif
	Endif
	
	IF lOutros
		FieldPut(FieldPos(aDados[_nx][1]),aDados[_nx][2])
	Endif
	
	lOutros   := .T.
Next _nx

U_JobCInfo("ORTA646.PRW", "CLIENTE: " + aDados[aScan(aDados,{|x|Alltrim(x[1])=="A1_COD"})][2] + "/" + cCodCli, 2)

MsUnlock()

_cSegmen := ""
IF cUnOri == "24" .and. cEmpAnt == "23"
	_cSegmen    := "1" // Fixar sempre como Industrial
Else
	_cSegmen    := SA1->A1_XTIPO
Endif

If empty(_cSegmen)
	_cSegmen := U_ORTXRPC(cUnOri, "U_ORTA646F",{SA1->A1_CGC})
	
	RecLock("SA1",.F.)
	SA1->A1_XTIPO = _cSegmen
	MsUnlock()
Endif

_cVendedor := cNovoVend

/* SSIs 118756, 131257 e 130992 */
//If SA1->A1_XTIPO == "8"
If AllTrim(SA1->A1_XTIPO) == "8" .OR. (AllTrim(SA1->A1_XTIPO) == "2" .AND. AllTrim(SA1->A1_XNICHO) == "00004" .AND. AllTrim(SA1->A1_PESSOA) == "F")
/* SSIs 118756, 131257 e 130992 */
	U_ORTP043Z(SA1->A1_XCIDADE)
Endif

/*
If empty(_cVendedor) .or. LEN(alltrim(_cVendedor)) < 6
_cVendedor := U_ORTXRPC(cUnOri, "U_ORTA646V",{SA1->A1_CGC})
_cVendedor := substr(_cVendedor,1,1)+"7"+substr(_cVendedor,3,4)

RecLock("SA1",.F.)
SA1->A1_VEND = _cVendedor
MsUnlock()
Endif

// Verifica se SZH existe
If _cRpc == "S"
DbSelectArea("SZH")
DbSetorder(1)
DbGoTOP()
If !DbSeek(XFILIAL("SZH")+SA1->A1_COD+SA1->A1_LOJA+SA1->A1_XTIPO)
CONOUT("ORTA646C: Vai Gerar SZH")
U_ORTA646B(cUnori, SA1->A1_CGC,SA1->A1_VEND,SA1->A1_COD,"      ")
Endif
Endif
*/

CONOUT("ORTA646C: novo CÛdigo ["+cNovoVend+"] Vendedor")

RestArea(_aArea)
RETURN {cCodCli,cNovoVend}

// ===============================
// pega o vendedor
/*
**************************************************
User Function ORTA646V(cCLi)
**************************************************
Local cVend := ""
Local cQuery:= ""
Local _aArea := getArea()

cQuery:="SELECT A1_VEND FROM "+RetSqlName("SA1")+" "
cQuery+=" WHERE D_E_L_E_T_ = ' ' "
cQuery+="   AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery+="   AND A1_CGC = '"+cCLi+"' "

cAliasQry:="RETSA1"

U_ORTQUERY(cQuery,cAliasQry)

While !(cAliasQry)->(EOF())
cVend := (cAliasQry)->A1_VEND
(cAliasQry)->(DbSkip())
Enddo
(cAliasQry)->(DbCloseArea())

RestArea(_aArea)
Return cVend
*/

// ===============================
// pega o SEGMENTO
**************************************************
User Function ORTA646F(cCLi)
**************************************************
Local _aArea := getArea()
Local cSegme := ""
Local cQuery := ""

cQuery:="SELECT A1_XTIPO FROM "+RetSqlName("SA1")+" "
cQuery+=" WHERE D_E_L_E_T_ = ' ' "
cQuery+="   AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery+="   AND A1_CGC = '"+cCLi+"' "

cAliasQry:="RETSA1"

U_ORTQUERY(cQuery,cAliasQry)

While !(cAliasQry)->(EOF())
	cSegme := (cAliasQry)->A1_XTIPO
	(cAliasQry)->(DbSkip())
Enddo
(cAliasQry)->(DbCloseArea())

RestArea(_aArea)
Return cSegme

// ===============================
// pega a szh
**************************************************
User Function ORTA646H(cCNPJ,cVend)
**************************************************
Local _aArea := getArea()

Local aSX3SZH:={}
Local aRet:={}
Local aRet2:={}
Local i

DbSelectArea("SX3")
Dbsetorder(1)
DbSeek("SZH")
Do While SX3->X3_ARQUIVO=="SZH"
	if SX3->X3_CONTEXT<>"V" .and. SX3->X3_TIPO<>"M"
		aadd(aSX3SZH,{SX3->X3_CAMPO,SX3->X3_TIPO})
	Endif
	DbSkip()
Enddo

cQuery:="SELECT H.* FROM "+RetSqlName("SZH")+" H, "+RetSqlName("SA1")+" A "
cQuery+=" WHERE H.D_E_L_E_T_ = ' ' "
cQuery+="   AND A.D_E_L_E_T_ = ' ' "
cQuery+="   AND ZH_FILIAL = '"+xFilial("SZH")+"' "
cQuery+="   AND A1_FILIAL = '"+xFilial("SA1")+"' "
//cQuery+="   AND ZH_VEND = '"+cVend+"'    "
cQuery+="   AND ZH_MSBLQL <> '1' "
cQuery+="   AND ZH_VEND NOT LIKE 'L%' "
cQuery+="   AND A1_CGC     = '"+cCNPJ+"' "
cQuery+="   AND ZH_CLIENTE = A1_COD "

cAliasQry:="RETSZH"

U_ORTQUERY(cQuery,cAliasQry)

While !(cAliasQry)->(EOF())
	For i:=1 to Len(aSX3SZH)
		cCmp:=cAliasQry+"->"+aSX3SZH[i,1]
		If aSX3SZH[i,2]=="D"
			aadd(aRet,{aSX3SZH[i,1],StoD(&cCmp)})
		Else
			If aSX3SZH[i,2]=="L"
				aadd(aRet,{aSX3SZH[i,1],&cCmp=="T"})
			Else
				aadd(aRet,{aSX3SZH[i,1],&cCmp})
			Endif
		Endif
	Next
	aadd(aRet2,aRet)
	aRet := {}
	(cAliasQry)->(DbSkip())
Enddo
(cAliasQry)->(DbCloseArea())

RestArea(_aArea)
Return(aRet2)

// ===============================
// pega Verba de Repasse da szh
**************************************************
User Function ORTA646N(cCNPJ,cVend)
**************************************************
Local _aArea := getArea()
Local aRet:={}

cQuery:="SELECT H.* FROM "+RetSqlName("SZH")+" H, "+RetSqlName("SA1")+" A "
cQuery+=" WHERE H.D_E_L_E_T_ = ' ' "
cQuery+="   AND A.D_E_L_E_T_ = ' ' "
cQuery+="   AND ZH_FILIAL = '"+xFilial("SZH")+"' "
cQuery+="   AND A1_FILIAL = '"+xFilial("SA1")+"' "
//cQuery+="   AND ZH_VEND = '"+cVend+"'    "
cQuery+="   AND ZH_MSBLQL <> '1' "
cQuery+="   AND ZH_VEND NOT LIKE 'L%' "
cQuery+="   AND A1_CGC     = '"+cCNPJ+"' "
cQuery+="   AND ZH_CLIENTE = A1_COD "

CONOUT("cQueryxxx: " + cQuery)

cAliasQry:="RETSZH"

U_ORTQUERY(cQuery,cAliasQry)

If !(cAliasQry)->(EOF())
	aRet := {(cAliasQry)->ZH_VERBREP, (cAliasQry)->ZH_VERBEXT}
Endif
(cAliasQry)->(DbCloseArea())

RestArea(_aArea)
Return(aRet)

// Gera SZH se necess·rio
**************************************************
User Function ORTA646B(cUnOri, _cCnpj, _cVend, _cCliente, _cVendNovo,_cSegmDes)
**************************************************
Local _aArea := getArea()
Local _nx, _nI
Default _cVendNovo := space(6)

aSZH := U_ORTXRPC(cUnOri, "U_ORTA646H",{_cCNPJ,_cVend})
_cVendedor := _cVend
DbSelectArea("SZH")

For _nI := 1 To Len(aSZH)
	
	xSegm := aSZH[_nI][aScan(aSZH[_nI],{|x|Alltrim(x[1])=="ZH_SEGMENT"})][2]
	CONOUT("xSegm: " + xSegm)
	xVend := aSZH[_nI][aScan(aSZH[_nI],{|x|Alltrim(x[1])=="ZH_VEND"})][2]
	CONOUT("xVend: " + xVend)
	
	//	xVend := substr(xVend,1,1)+"7"+substr(xVend,3,4)
	CONOUT("_cVendNovo: " + _cVendNovo)
	dbselectarea("SZH")
	dbOrderNickName('CSZH1')
	
	If dbseek(xFilial("SZH")+_cCLiente+'01'+xSegm)
		If SZH->ZH_VEND <> _cVendNovo
			RecLock("SZH",.F.)
			SZH->(DbDELETE())
			SZH->(MsUnLock())
		Endif
	Endif
	
	dbselectarea("SZH")
	dbOrderNickName('CSZH1')
	
	If !dbseek(xFilial("SZH")+_cCLiente+'01'+IIf(cEmpAnt == "18" .and. cFilAnt == "03" .and. _cSegmDes == "1","M",xSegm))
		CONOUT("ORTA646B: novo registro Segmento")
		CONOUT("Len(aSZH[_nI]): " + Alltrim(Str(Len(aSZH[_nI]))))
		RecLock("SZH",.T.)
		For _nx := 1 To Len(aSZH[_nI])
			If Alltrim(aSZH[_nI,_nx][1]) == "ZH_CLIENTE"
				FieldPut(FieldPos(aSZH[_nI,_nx][1]),_cCLiente)
			Else
				If Alltrim(aSZH[_nI,_nx][1]) == "ZH_VEND"
					If Empty(_cVendNovo)
						IF empty(aSZH[_nI,_nx][2])
							_cVend := _cVendedor
						else
							_cVend := substr(aSZH[_nI,_nx][2],1,1)+"7"+substr(aSZH[_nI,_nx][2],3,4)
						endif
						FieldPut(FieldPos(aSZH[_nI,_nx][1]),_cVend)
					Else
						FieldPut(FieldPos(aSZH[_nI,_nx][1]),_cVendNovo)
					Endif
				Else
					FieldPut(FieldPos(aSZH[_nI,_nx][1]),aSZH[_nI,_nx][2])
				Endif
			Endif
		Next _nx 
		If cEmpAnt == "18" .and. cFilAnt == "03" .and. _cSegmDes == "1"
			SZH->ZH_SEGMENT := "M"
		Endif	
		SZH->(MsUnlock())
	Else
		CONOUT("ORTA646B: n„o gerou novo registro Segmento")
	Endif
	
	_cVendRet := SZH->ZH_VEND
	
Next _nI
CONOUT("ORTA646B: novo CÛdigo 2 ["+_cVendRet+"] Vendedor")

RestArea(_aArea)
Return(_cVendRet)

*--------------------------*
Static Function fMaxVen()
*--------------------------*
Local cCodigo	:= Space(6)
Local cQuery	:= ""
Local _cAreaC	:= GetArea()

cQuery	:= " SELECT NVL(MAX(A3_COD), 'C00000') AS MAXCOD "
cQuery	+= "   FROM " + RetSqlName("SA3")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND A3_FILIAL = '"+xFilial("SA3")+"' "
cQuery	+= "    AND A3_COD LIKE 'C%' "

U_ORTQUERY(cQuery, "ORTP133COD")
cCodigo	:= Soma1(PADR(ORTP133COD->MAXCOD, GetSX3Cache("A3_COD","X3_TAMANHO")))
ORTP133COD->(dbCloseArea())

RestArea(_cAreaC)

Return cCodigo

*--------------------------*
Static Function fGeraVen(cCPF, aDados)
*--------------------------*
Local cCodigo	:= Space(6)
Local cQuery	:= ""
Local _cAreaC	:= GetArea()
Local _Nz
//Local cCodVend	:= GetSXENum("SA3")

// VERIFICAR SE JA EXISTE CADASTRO PARA O CPF NA BASE
_cQry := " SELECT A3_COD, A3_NOME, A3_MSBLQL, A3_XCLIENT, R_E_C_N_O_ AS REG "
_cQry += " FROM SIGA."+RetSqlName("SA3")+" "
_cQry += " WHERE A3_FILIAL = '"+xFilial("SA3")+"' "
_cQry += " AND D_E_L_E_T_  = ' ' 	  "
_cQry += " AND A3_COD      LIKE 'C%'		  "
_cQry += " AND A3_CGC      = '"+cCPF+"' "

U_ORTQUERY(_cQry, "ORTV010_1")

// SE O VENDEDOR EXISTIR NO MICROSIGA...
If ORTV010_1->(!EOF())
	_aArea	:= GetArea()
	DbSelectArea("SA3")
	SA3->(DbGoto(ORTV010_1->REG))
	cCodVen := SA3->A3_COD
	CONOUT("ORTA646C: CÛdigo ["+cCodVen+"] Vendedor encontrado")
Else
	
	// Vendedor Padr„o
	
	If cEmpAnt <> "18"
		cCodVen := "000001"
		CONOUT("ORTA646C: Usou CÛdigo ["+cCodVen+"] Vendedor Padr„o")
	Else
		
		cCodVen := fMaxVen()
		
		//	DbSelectArea("SA3")
		//	dbOrderNickName("PSA31")
		//	dbSeek(xFilial("SA3") + cCodVend)
		//	Do While Found()
		//		confirmSX8()
		//		cCodVend := GetSXENum("SA3")
		//		dbGoTop()
		//		dbseek(xFilial("SA3")+cCodVend)
		//	EndDo
		
		CONOUT("ORTA646C: novo CÛdigo ["+cCodVen+"] Vendedor")
		
		DbSelectArea("SA3")
		RecLock("SA3",.T.)
		
		For _Nz := 1 to Len(aDados)
			//		If Alltrim(aDados[_Nz][1]) $ "A3_NOME/A3_CGC"
			FieldPut(FieldPos(aDados[_Nz][1]),aDados[_Nz][2])
			//		Endif
		Next
		SA3->A3_COD		:= cCodVen
		
		SA3->(MsUnLock())
	Endif
	
Endif

RestArea(_cAreaC)

Return cCodVen

// ===============================
// pega o C5_CLIENT
**************************************************
User Function ORTA646G(cCNPJ)
**************************************************
Local _aArea := getArea()

Local aSX3SA1:={}
Local aRet   :={}
Local aRet2  :={}
Local i

DbSelectArea("SX3")
Dbsetorder(1)
DbSeek("SA1")
Do While SX3->X3_ARQUIVO=="SA1"
	if SX3->X3_CONTEXT<>"V" .and. SX3->X3_TIPO<>"M"
		aadd(aSX3SA1,{SX3->X3_CAMPO,SX3->X3_TIPO})
	Endif
	DbSkip()
Enddo

cQuery:="SELECT * FROM "+RetSqlName("SA1")
cQuery+=" WHERE D_E_L_E_T_ = ' ' "
cQuery+="   AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery+="   AND A1_CGC    = '"+cCNPJ+"' "

cAliasQry:="RETSA1"

U_ORTQUERY(cQuery,cAliasQry)

While !(cAliasQry)->(EOF())
	For i:=1 to Len(aSX3SA1)
		cCmp:=cAliasQry+"->"+aSX3SA1[i,1]
		If aSX3SA1[i,2]=="D"
			aadd(aRet,{aSX3SA1[i,1],StoD(&cCmp)})
		Else
			If aSX3SA1[i,2]=="L"
				aadd(aRet,{aSX3SA1[i,1],&cCmp=="T"})
			Else
				aadd(aRet,{aSX3SA1[i,1],&cCmp})
			Endif
		Endif
	Next
	aadd(aRet2,aRet)
	aRet := {}
	(cAliasQry)->(DbSkip())
Enddo
(cAliasQry)->(DbCloseArea())

RestArea(_aArea)
Return(aRet2)
******************************
Static Function ORTA646U()
******************************
Local aProd:={}
Local i
SaveInter()
aProd := U_ORTXRPC(cUnOri, "U_ORTA646V",{_cProduto})
RestInter()
RestArea(_aAreaAtu)
If ValType(aPed)<>"A"
	Alert("Problemas na conexao com a unidade de Origem ["+cUnOri+"]")
Else
	DbSelectArea("SB1")
	DbSetOrder(1)
	if Empty(aProd[1,10]) .and. DbSeek(xFilial("SB1")+aProd[1,1])
		for i:=2 to Len(aProd)
			cQuery:=" SELECT B1_COD, A7_CLIENTE "
			cQuery+=" FROM "+RetSqlName("SA7")+ " SA7, "+RetSqlName("SB1")+" SB1 "
			cQuery+=" WHERE SA7.D_E_L_E_T_ = ' ' "
			cQuery+=" AND SB1.D_E_L_E_T_ = ' ' "
			cQuery+=" AND A7_FILIAL = ' ' "
			cQuery+=" AND B1_FILIAL = ' ' "
			cQuery+=" AND A7_CLIENTE = '"+_cCLiente+"'"
			cQuery+=" AND A7_PRODUTO = B1_COD"
			cQuery+=" AND B1_XLARG = "+cValtochar(aProd[i,3])
			cQuery+=" AND B1_XALT = "+cValtochar(aProd[i,4])
			cQuery+=" AND B1_XCOMP = "+cValtochar(aProd[i,5])
			cQuery+=" AND B1_XMODELO ='"+aProd[i,6]+"'"
			cQuery+=" AND B1_XCHANFR = "+cValtochar(aProd[i,7]) // Sanfona
			cQuery+=" AND B1_XPERSON = '"+aProd[i,8]+"'" // Sanfona
			cQuery+=" AND B1_GCCUSTO = '"+aProd[i,9]+"' " //equipamento
			cQuery+=" AND B1_XCODBAS = '"+aProd[i,10]+"'" //SobMedida com o mesmo CÛdigo Base.
			memowrit("c:\prodcli.SQL",cQuery)
			TCQUERY cQuery New Alias "TRBCLIPRD"
			If Eof()
				cNovoCod:=U_GeraNovoCod(aProd[i,10],aProd[i,11],!Empty(aProd[i,8]),aProd[i,8],aProd[i,6],aProd[i,7],aProd[i,9])
				if Len(aProd)>i
					aProd[i+1,10]:=cNovoCod
				Endif
				dbSelectArea("SA7")
				Reclock("SA7",.T.)
				SA7->A7_FILIAL := xFilial("SA7")
				SA7->A7_PRODUTO:= cNovoCod
				SA7->A7_CLIENTE:= cCliente
				SA7->A7_LOJA   := "01"
				SA7->A7_DTREF01:= dDataBase
				MsUnlock()
			Else
				//Caso exista a medida refaz o preÁo.
				U_ORTG017(TRBCLIPRD->B1_COD,cTabPr,.T.,@nVenda24,@nCusto27)
				//Caso exista a medida refaz a estrutura.
				if !U_GeraEstru(aProd[i,10],TRBCLIPRD->B1_COD,cCorte)
					Alert("N„o Existe estrutura para o produto base: "+aProd[i,10] )
					lRet:=.F.
					return()
				EndIF
				If nCusto27 = 0 .Or. nVenda24 = 0
					DbSelectArea("TRBCLIPRD")
					DbCloseArea()
					lFlag:= .F.
					Aviso("A T E N « √ O !","Sob medida com problema de preÁo na tatela! Produto: "+TRBCLIPRD->B1_COD,{"OK"})
					return()
				EndIf
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+TRBCLIPRD->B1_COD)
			EndIf
			DbSelectArea("TRBCLIPRD")
			DbCloseArea()
		Next
	EndIf
EndIf
Return(cCod)

******************************
User Function ORTA646V(cProduto)
******************************
Local cQuery:=""
Local aRet  :={}
cQuery:=" SELECT D.B1_COD CODD, D.B1_DESC DESCD, D.B1_XLARG LARGD, D.B1_XALT ALTD, D.B1_XCOMP COMPD, D.B1_XMODELO MODELOC, D.B1_XCHANFR CHANFRC, "
cQuery+="        D.B1_XPERSON PERSOND, D.B1_GCCUSTO GCUSTOD, NVL(C.B1_XCODBAS,'XXXXXXXXXX') CODBASD, D.B1_XMED MEDD, A.*  "
cQuery+="   FROM ( "
cQuery+=" SELECT C.B1_COD CODC, C.B1_DESC DESCC, C.B1_XLARG LARGC, C.B1_XALT ALTC, C.B1_XCOMP COMPC, C.B1_XMODELO MODELOC, C.B1_XCHANFR CHANFRC, "
cQuery+="        C.B1_XPERSON PERSONC, C.B1_GCCUSTO GCUSTOC, NVL(C.B1_XCODBAS,'XXXXXXXXXX') CODBASC, C.B1_XMED MEDC A.*  "
cQuery+="   FROM (SELECT A.B1_COD CODA, A.B1_DESC DESCA, A.B1_XLARG LARGA, A.B1_XALT ALTA, A.B1_XCOMP COMPA, A.B1_XMODELO MODELOA, "
cQuery+="                A.B1_XCHANFR CHANFRA, A.B1_XPERSON PERSONA, A.B1_GCCUSTO GCUSTOA, A.B1_XCODBAS CODBASA, A.B1_XMED MEDA"
cQuery+="                B.B1_COD CODB, B.B1_DESC DESCB, B.B1_XLARG LARGB, B.B1_XALT ALTB, B.B1_XCOMP COMPB, B.B1_XMODELO MODELOB, "
cQuery+="                B.B1_XCHANFR CHANFRB, B.B1_XPERSON PERSONB, B.B1_GCCUSTO GCUSTOB, NVL(B.B1_XCODBAS,'XXXXXXXXXX') CODBASB  "
cQuery+="                B.B1_XMED MEDB "
cQuery+="  FROM "+RetSqlName("SB1")+" A, "+RetSqlName("SB1")+" B, "+RetSqlName("SB1")+" C "
cQuery+=" WHERE A.D_E_L_E_T_    = ' ' "
cQuery+="   AND B.D_E_L_E_T_(+) = ' ' "
cQuery+="   AND C.D_E_L_E_T_(+) = ' ' "
cQuery+="   AND A.B1_FILIAL     = '"+xFilial("SB1")+"' "
cQuery+="   AND B.B1_FILIAL(+)  = '"+xFilial("SB1")+"' "
cQuery+="   AND C.B1_FILIAL(+)  = '"+xFilial("SB1")+"' "
cQuery+="   AND A.B1_XCODBAS    = B.B1_COD(+) "
cQuery+="   AND A.B1_COD        = '"+cProduto+"') A, "
cQuery+=RetSqlName("SB1")+" C "
cQuery+=" WHERE C.D_E_L_E_T_(+) = ' ' "
cQuery+="   AND C.B1_FILIAL(+)  = '"+xFilial("SB1")+"' "
cQuery+="   AND A.XCODBASB    = C.B1_COD(+)) A, "
cQuery+=RetSqlName("SB1")+" D "
cQuery+=" WHERE D.D_E_L_E_T_(+) = ' ' "
cQuery+="   AND D.B1_FILIAL(+)  = '"+xFilial("SB1")+"' "
cQuery+="   AND A.XCODBASC    = D.B1_COD(+) " "
TCQuery cQuery ALIAS "QRY" New
DbSelectArea("QRY")
If !eof()
	if !empty(QRY->CODD)
		aadd(aRet,{CODD, DESCD, LARGD, ALTD, COMPD, MODELOD, CHANFRD, PERSOND, GCUSTOD, CODBASD, MEDD})
	Endif
	if !empty(QRY->CODC)
		aadd(aRet,{CODC, DESCC, LARGC, ALTC, COMPC, MODELOC, CHANFRC, PERSONC, GCUSTOC, CODBASC, MEDC})
	Endif
	if !empty(QRY->CODB)
		aadd(aRet,{CODB, DESCB, LARGB, ALTB, COMPB, MODELOB, CHANFRB, PERSONB, GCUSTOB, CODBASB, MEDB})
	Endif
	aadd(aRet,{CODA, DESCA, LARGA, ALTA, COMPA, MODELOA, CHANFRA, PERSONA, GCUSTOA, CODBASA, MEDA})
Endif
DbCloseArea()
Return(aRet)

// ===============================
// pega a sz4
**************************************************
User Function ORTA64Z4(cCnpj)
**************************************************
Local _aArea := getArea()

Local aSX3SZ4:={}
Local aRet:={}
Local aRet2:={}
Local i

DbSelectArea('SA1')
DbSetOrder(3)
DbGoTop()
Dbseek(xFilial('SA1') + cCnpj) // CNPJ do C5_CLIENT
cCodCli := SA1->A1_COD

DbSelectArea("SX3")
Dbsetorder(1)
DbSeek("SZ4")
Do While SX3->X3_ARQUIVO=="SZ4"
	if SX3->X3_CONTEXT<>"V" .and. SX3->X3_TIPO<>"M"
		aadd(aSX3SZ4,{SX3->X3_CAMPO,SX3->X3_TIPO})
	Endif
	DbSkip()
Enddo

cQuery:="SELECT SZ4.* FROM "+RetSqlName("SZ4")+" SZ4 "
cQuery+=" WHERE SZ4.D_E_L_E_T_ = ' ' "
cQuery+="   AND SZ4.Z4_FILIAL  = '"+xFilial("SZ4")+"' "
cQuery+="   AND SZ4.Z4_CLIENTE = '"+cCodCli+"' "
cQuery+="   AND SZ4.Z4_LOJA    = '01' "

cAliasQry:="RETSZ4"

U_ORTQUERY(cQuery,cAliasQry)

While !(cAliasQry)->(EOF())
	For i:=1 to Len(aSX3SZ4)
		cCmp:=cAliasQry+"->"+aSX3SZ4[i,1]
		If aSX3SZ4[i,2]=="D"
			aadd(aRet,{aSX3SZ4[i,1],StoD(&cCmp)})
		Else
			If aSX3SZ4[i,2]=="L"
				aadd(aRet,{aSX3SZ4[i,1],&cCmp=="T"})
			Else
				aadd(aRet,{aSX3SZ4[i,1],&cCmp})
			Endif
		Endif
	Next
	aadd(aRet2,aRet)
	aRet := {}
	(cAliasQry)->(DbSkip())
Enddo
(cAliasQry)->(DbCloseArea())

RestArea(_aArea)
Return(aRet2)

// ===============================
// pega a sz5
**************************************************
User Function ORTA64Z5(cCnpj)
**************************************************
Local _aArea := getArea()

Local aSX3SZ5:={}
Local aRet:={}
Local aRet2:={}
Local i

DbSelectArea('SA1')
DbSetOrder(3)
DbGoTop()
Dbseek(xFilial('SA1') + cCnpj) // CNPJ do C5_CLIENT
cCodCli := SA1->A1_COD

DbSelectArea("SX3")
Dbsetorder(1)
DbSeek("SZ5")
Do While SX3->X3_ARQUIVO=="SZ5"
	if SX3->X3_CONTEXT<>"V" .and. SX3->X3_TIPO<>"M"
		aadd(aSX3SZ5,{SX3->X3_CAMPO,SX3->X3_TIPO})
	Endif
	DbSkip()
Enddo

cQuery:="SELECT SZ5.* FROM "+RetSqlName("SZ5")+" SZ5 "
cQuery+=" WHERE SZ5.D_E_L_E_T_ = ' ' "
cQuery+="   AND SZ5.Z5_FILIAL  = '"+xFilial("SZ5")+"' "
cQuery+="   AND SZ5.Z5_CLIENTE = '"+cCodCli+"' "
cQuery+="   AND SZ5.Z5_LOJA    = '01' "

cAliasQry:="RETSZ5"

U_ORTQUERY(cQuery,cAliasQry)

While !(cAliasQry)->(EOF())
	For i:=1 to Len(aSX3SZ5)
		cCmp:=cAliasQry+"->"+aSX3SZ5[i,1]
		If aSX3SZ5[i,2]=="D"
			aadd(aRet,{aSX3SZ5[i,1],StoD(&cCmp)})
		Else
			If aSX3SZ5[i,2]=="L"
				aadd(aRet,{aSX3SZ5[i,1],&cCmp=="T"})
			Else
				aadd(aRet,{aSX3SZ5[i,1],&cCmp})
			Endif
		Endif
	Next
	aadd(aRet2,aRet)
	aRet := {}
	(cAliasQry)->(DbSkip())
Enddo
(cAliasQry)->(DbCloseArea())

RestArea(_aArea)
Return(aRet2)

*--------------------------*
Static Function fGeraSZ4(cCodCli, aDados)
*--------------------------*
Local cCodigo	:= Space(6)
Local cQuery	:= ""
Local _cAreaC	:= GetArea()
Local _Nz

// VERIFICAR SE JA EXISTE CADASTRO PARA O CPF NA BASE
cQuery:="SELECT SZ4.* FROM "+RetSqlName("SZ4")+" SZ4 "
cQuery+=" WHERE SZ4.D_E_L_E_T_ = ' ' "
cQuery+="   AND SZ4.Z4_FILIAL  = '"+xFilial("SZ4")+"' "
cQuery+="   AND SZ4.Z4_CLIENTE = '"+cCodCli+"' "
cQuery+="   AND SZ4.Z4_LOJA    = '01' "

U_ORTQUERY(cQuery, "ORTV011_1")

// SE O VENDEDOR EXISTIR NO MICROSIGA...
If ORTV011_1->(EOF())
	CONOUT("ORTA646C: novo CÛdigo ["+cCodVen+"] Vendedor")
	
	DbSelectArea("SZ4")
	RecLock("SZ4",.T.)
	
	For _Nz := 1 to Len(aDados)
		FieldPut(FieldPos(aDados[_Nz][1]),aDados[_Nz][2])
	Next
	
	SZ4->(MsUnLock())
	
Endif

ORTV011_1->(DbCloseArea())

RestArea(_cAreaC)

Return cCodVen

*--------------------------*
Static Function fGeraSZ5(cCodCli, aDados)
*--------------------------*
Local cCodigo	:= Space(6)
Local cQuery	:= ""
Local _cAreaC	:= GetArea()

// VERIFICAR SE JA EXISTE CADASTRO PARA O CPF NA BASE
cQuery:="SELECT SZ5.* FROM "+RetSqlName("SZ5")+" SZ5 "
cQuery+=" WHERE SZ5.D_E_L_E_T_ = ' ' "
cQuery+="   AND SZ5.Z5_FILIAL  = '"+xFilial("SZ5")+"' "
cQuery+="   AND SZ5.Z5_CLIENTE = '"+cCodCli+"' "
cQuery+="   AND SZ5.Z5_LOJA    = '01' "

U_ORTQUERY(cQuery, "ORTV012_1")

// SE O VENDEDOR EXISTIR NO MICROSIGA...
If ORTV012_1->(EOF())
	CONOUT("ORTA646C: novo CÛdigo ["+cCodVen+"] Vendedor")
	
	DbSelectArea("SZ5")
	RecLock("SZ5",.T.)
	
	For _Nz := 1 to Len(aDados)
		FieldPut(FieldPos(aDados[_Nz][1]),aDados[_Nz][2])
	Next
	
	SZ5->(MsUnLock())
	
Endif

ORTV012_1->(DbCloseArea())

RestArea(_cAreaC)

Return cCodVen

*--------------------------*
Static Function fBuscClx(_cPedClx)
*--------------------------*
Local cRet	    := ""
Local cQuery	:= ""
Local _cAreaC	:= GetArea()

// VERIFICAR SE JA EXISTE CADASTRO PARA O CPF NA BASE
cQuery:="SELECT C5_NUM FROM "+RetSqlName("SC5")+" SC5 "
cQuery+=" WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery+="   AND SC5.C5_FILIAL  = '"+xFilial("SC5")+"' "
cQuery+="   AND SC5.C5_XPEDCLX = '"+_cPedClx+"' "
cQuery+="   AND SC5.C5_EMISSAO >= '20210101' "
cQuery+="   AND SC5.C5_XOPER = '14' "

U_ORTQUERY(cQuery, "ORTV012_5")

// SE O VENDEDOR EXISTIR NO MICROSIGA...
If !ORTV012_5->(EOF())
	cRet := ORTV012_5->C5_NUM
Endif

ORTV012_5->(DbCloseArea())

RestArea(_cAreaC)

Return cRet


// LIBERA PEDIDO NA SZE POR PRAZO - somente para pedidos anymarket
Static Function libPed(cPedSigo)

SZE->(Dbsetorder(3))
If SZE->(DBSEEK(XFILIAL("SZE")+cPedSigo)) 
	While !SZE->(EOF()) .and. SZE->ZE_PEDIDO == cPedSigo
		If Alltrim(SZE->ZE_AUTORIZ) <> "LIBMIX"
			SZE->(Reclock("SZE",.F.))	
			SZE->ZE_USUARIO := "ORTP156"
			SZE->ZE_DTAUT   := dDataBase
			SZE->(msUnlock())	
		Endif
		SZE->(DbSkip())
	End
Endif
SC5->(Dbsetorder(1))
If SC5->(dbseek(xFilial("SC5")+cPedSigo))
	SC5->(RecLock("SC5",.f.))
	SC5->C5_XDTLIB := DDATABASE
	SC5->(MSUNLOCK())
Endif	
Return

//**************** SSI - 90737 - Claudio Rocha *********************************************


/*
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ RelatÛrio ImportaÁ„o de pedidos			                  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
*/
*******************************************************************************************************
Static FUNCTION REL_GERAD()  // RelatÛrio ImportaÁ„o de pedidos
*******************************************************************************************************
Local aPergs 		 := {}
Local aRet   		 := {}
Local cUnOri 		 := "  "

Private cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Private cDesc2       := "de acordo com os parametros informados pelo usuario."
Private cDesc3       := ""
Private cPict        := ""
Private titulo       := "RelatÛrio ImportaÁ„o de pedidos"
Private nLin         := 3200
//                       00        10        20	       30	     40        50	     60	       70        80        90        100       110       120      130
//                       012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901

//                         |0050| 0150| 0250|0350| 0450| 0550| 0650| 0750| 0850|0950|1050|1150|1250|1350|1450|1550|1650|1750|1850|1950|2050|2150|2250|2350|2450|
// POS.	treport			|000 |100  |200  |300  |400  |500  |600  |700  |800  |900 |1000|1100|1200|1300|1400|1500|1600|1700|1800|1900|2000|2100|2200|2300|2400|
Private Cabec1       := "UNIDADE    |* P E D I D O *|              |      |       | ** C L I E N T E ** | ** E M I S S A O ** |                         |"
Private Cabec2       := "ORIG.|DEST.|ORIG.  |DEST.  |TOTAL         |ITENS |TABELA |ORIG.     |DEST.     |ORIG.     |DEST.     |OBSERVA«¬O               |"
Private imprime      := .T.
Private aOrd 		 := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "ORTR646"  // Coloque aqui o nome do programa para impressao no cabecalho
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "G", 1}
Private nLastKey     := 0
Private wnrel        := "ORTR646"  // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg        := "ORT646____"
Private cString      := "SC5"
Private oPrn,oFont1
Private nPag         := 0
Private nEsp         := 40
Private aBox 		 := {   0005,; // Unidade Origem
							0100,; // Unidade Destino
							0185,; // Pedido Origem
							0290,; // Pedido Destino 360
							0460,; // Total 520
							0670,; // Itens 800
							0810,; // Tabela 930
							0920,; // Cliente Origem 1050
							1140,; // Cliente Destino 1250
							1260,; // Emiss„o Origem 1450
							1440,; // Emiss„o Destino 1650
							1550}  // ObservaÁ„o 

Private aParamBox:= {}
Private aRetParam:= {}

aAdd(aParamBox,{1,"Emiss„o De "   	,CriaVar("C5_EMISSAO") 	,"99/99/99" ,""		,"   "	,""		,08	,.F.})
aAdd(aParamBox,{1,"Emiss„o Ate "  	,CriaVar("C5_EMISSAO") 	,"99/99/99" ,""		,"   "	,""		,08	,.F.})  
aAdd(aParamBox,{1,"Unidade Origem: ",cUnOri					,"@99"		,'.T.'	,		,'.T.'	,2	,.F.})

If !( ParamBox(aParamBox , "RelatÛrio ImportaÁ„o de pedidos" , @aRetParam) )
	Return
Endif

oFont1:= TFont():New("Courier New",,10,,.T.)
oPrn := TReport():New("0RTA646",Titulo,,{|oPrn| GeraRel2(oPrn)},"RelatÛrio ImportaÁ„o de pedidos")
oPrn:PrintDialog()



Return NIL  // retorno da funcao

******************************************************************************************************
Static Function GeraRel2(oPrn)
******************************************************************************************************
Local nTTNF   := 0
Local nTTICMS := 0
Local nTTANT  := 0

oPrn:SetPortrait()

cQuery:=" SELECT B1_XCODBAS, B1_XMED, C6_PRODUTO, "									+chr(13)+chr(10)
cQuery+="       (SELECT COUNT(C6_ITEM) "											+chr(13)+chr(10)
cQuery+="		FROM "+RetSqlName("SC6")+" SC6Z "									+chr(13)+chr(10)
cQuery+="		WHERE C6_NUM 			= C5_NUM "									+chr(13)+chr(10)
cQuery+="		  AND C6_CLI 			= C5_CLIENTE "								+chr(13)+chr(10)
cQuery+="		  AND C6_FILIAL 		= C5_FILIAL "								+chr(13)+chr(10)
cQuery+="		  AND SC6Z.D_E_L_E_T_ 	= ' '  "									+chr(13)+chr(10)
cQuery+="		  GROUP BY C6_NUM) AS ITENS, "										+chr(13)+chr(10)
cQuery+=" 		(SELECT A1_CGC "													+chr(13)+chr(10)
cQuery+="  		 FROM "+RetSqlName("SA1")+" SA1X "									+chr(13)+chr(10)
cQuery+="  		 WHERE SA1X.A1_FILIAL 	= '"+XFILIAL("SA1")+"' "					+chr(13)+chr(10)
cQuery+="  		   AND SA1X.D_E_L_E_T_ 	= ' ' "										+chr(13)+chr(10)
cQuery+="  		   AND SA1X.A1_COD = SC5.C5_CLIENT) CNPJ_CLIENT, "					+chr(13)+chr(10)
cQuery+=" 		(SELECT DA1.DA1_XCUSTO "											+chr(13)+chr(10)
cQuery+="        FROM "+RetSqlName("DA1")+" DA1 "									+chr(13)+chr(10)
cQuery+="        WHERE DA1_FILIAL   	= '"+xFilial("DA1")+"' "					+chr(13)+chr(10)
cQuery+="          AND DA1.D_E_L_E_T_ 	= ' ' "										+chr(13)+chr(10)
cQuery+="          AND DA1.DA1_CODPRO 	= C6_PRODUTO "								+chr(13)+chr(10)
cQuery+="          AND DA1.DA1_CODTAB 	= C5_TABELA) DA1_XCUSTO, "					+chr(13)+chr(10)
cQuery+=" 		SC5.*, SC6.*, SA1.A1_CGC, SA1.A1_FILIAL, SA3.* "					+chr(13)+chr(10)
cQuery+=" FROM "+RetSqlName("SC5")+" SC5, "											+chr(13)+chr(10)
cQuery+=  		 RetSqlName("SC6")+" SC6, "											+chr(13)+chr(10)
cQuery+=  		 RetSqlName("SB1")+" SB1, "											+chr(13)+chr(10)
cQuery+=  		 RetSqlName("DA0")+" DA0, "											+chr(13)+chr(10)
cQuery+=  		 RetSqlName("SA1")+" SA1, "											+chr(13)+chr(10)
cQuery+=  		 RetSqlName("SA3")+" SA3  "											+chr(13)+chr(10)
cQuery+=" WHERE C5_FILIAL 		= '"+xFilial("SC5")+"' "							+chr(13)+chr(10)
cQuery+="   AND C6_FILIAL 		= '"+xFilial("SC6")+"' "							+chr(13)+chr(10)
cQuery+="   AND B1_FILIAL 		= '"+xFilial("SB1")+"' "							+chr(13)+chr(10)
cQuery+="   AND DA0_FILIAL 		= '"+xFilial("DA0")+"' "							+chr(13)+chr(10)
cQuery+="   AND A1_FILIAL 		= '"+xFilial("SA1")+"' "							+chr(13)+chr(10)
cQuery+="   AND A3_FILIAL 		= '"+xFilial("SA3")+"' "							+chr(13)+chr(10)
cQuery+="   AND SC5.D_E_L_E_T_ 	= ' '  "											+chr(13)+chr(10)
cQuery+="   AND SC6.D_E_L_E_T_ 	= ' '  "											+chr(13)+chr(10)
cQuery+="   AND SB1.D_E_L_E_T_ 	= ' '  "											+chr(13)+chr(10)
cQuery+="   AND DA0.D_E_L_E_T_ 	= ' '  "											+chr(13)+chr(10)
cQuery+="   AND SA1.D_E_L_E_T_ 	= ' '  "											+chr(13)+chr(10)
cQuery+="   AND SA3.D_E_L_E_T_ 	= ' '  "											+chr(13)+chr(10)
cQuery+="   AND A3_COD 			= C5_VEND1     "									+chr(13)+chr(10)
cQuery+="   AND A1_COD 			= C5_CLIENTE   "									+chr(13)+chr(10)
cQuery+="   AND C5_NUM 			= C6_NUM  "											+chr(13)+chr(10)
cQuery+="   AND B1_COD 			= C6_PRODUTO  "										+chr(13)+chr(10)
cQuery+="   AND DA0_CODTAB 		= C5_TABELA  "										+chr(13)+chr(10)
cQuery+="   AND C5_XPEDCLX 		= ' '  "											+chr(13)+chr(10)
cQuery+="   AND C5_XOPER   		= '13'  " 											+chr(13)+chr(10)
cQuery+="   AND C5_XEMBARQ 		= ' '  "											+chr(13)+chr(10)
cQuery+="   AND C5_NOTA    		= ' '  "											+chr(13)+chr(10)
cQuery+="   AND C5_EMISSAO 		BETWEEN DA0_DATDE AND DA0_DATATE "					+chr(13)+chr(10)
cQuery+="   AND C5_EMISSAO 		>= '20171001' " 									+chr(13)+chr(10)
cQuery+="   AND C5_XUNDEST 		IN ('"+IIF(Mv_Par03$"05/25","05','25",Mv_Par03)+"') " +chr(13)+chr(10)
cQuery+="   AND C5_RESREM 		= 'S' "												+chr(13)+chr(10)
cQuery+="   AND C5_XDTLIB 		BETWEEN '"+DTOS(Mv_Par01)+"'AND'"+DTOS(Mv_Par02)+"' "+chr(13)+chr(10)						+chr(13)+chr(10)
cQuery+=" ORDER BY C5_NUM, C6_ITEM "												+chr(13)+chr(10)

memowrite("C:\ORTA646B.SQL",cQuery)

If Select("QRY1") > 0
	QRY1->(dbCloseArea())
EndIf

TCQuery cQuery Alias "QRY1" NEW
DbSelectArea("QRY1")

Do While QRY1->(!eof())
	
	If nLin > 3000
		ImpCab(oPrn,.T.)
	Endif
	
	oPrn:Say(nLin,aBox[1]	,		MV_PAR03										,oFont1)
	oPrn:Say(nLin,aBox[2]	,"("+	cEmpAnt		+")"								,oFont1)
	oPrn:Say(nLin,aBox[3]	,		QRY1->C5_XPEDCLX								,oFont1)
	oPrn:Say(nLin,aBox[4]	,"("+	QRY1->C5_NUM+")"								,oFont1)
	
	oPrn:Say(nLin,aBox[5]	,Transform(round((QRY1->C6_QTDVEN*QRY1->C6_PRCVEN),2),"@E 9,999,999.99")	,oFont1)
	oPrn:Say(nLin,aBox[6]	,Transform(QRY1->ITENS,"@E 9999")						,oFont1)
	
	oPrn:Say(nLin,aBox[7]	,		QRY1->C5_TABELA									,oFont1)
	oPrn:Say(nLin,aBox[8]	,		QRY1->C5_CLIENTE								,oFont1)
	//oPrn:Say(nLin,aBox[9]	,		QRY1->C5_LOJACLI								,oFont1)
	oPrn:Say(nLin,aBox[10]	,DTOC(	STOD(QRY1->C5_EMISSAO ) )						,oFont1)
	oPrn:Say(nLin,aBox[11]	,DTOC(	STOD(QRY1->C5_XDTLIB ) )						,oFont1)

	If Len(Alltrim(QRY1->C5_XMENLIB)) <= 35
		oPrn:Say(nLin,aBox[12],QRY1->C5_XMENLIB										,oFont1)
	Else
		oPrn:Say(nLin,aBox[12],SUBSTR(QRY1->C5_XMENLIB,1 ,32)						,oFont1)
		nLin += nEsp
		oPrn:Say(nLin,aBox[12],SUBSTR(QRY1->C5_XMENLIB,33,65)						,oFont1)
	Endif

	QRY1->(dbskip())

	nLin += nEsp
	
End

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return  // retorno da funÁ„o

