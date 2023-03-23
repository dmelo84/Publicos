*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | FUNCOES  | Autor |  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx     |*
*+------------+------------------------------------------------------------+*
*|Data        | 30.12.2005                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Funcoes genericas                                          |*
*+-------------------------------------------------------------------------+*
*****************************************************************************
#include "protheus.ch"
#INCLUDE "TOTVS.CH"
#include "Rwmake.ch"
#include "TopConn.ch"
#include "Protheus.ch"
#include "sigawin.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "jpeg.CH"
#INCLUDE "XMLXFUN.CH"
#Define	 ENTER CHR(13) + CHR(10)
*------------------------------------------*
User Function xCriaSx1(cPerg,aSx1, nIncAlt)
	Local X1, Z
	* cPar01 = Nome do grupo de Pergunta
	* aPar02 = Array com Definicao das Perguntas
	* aPar03 = Define se È para Criar ou Alterar
	*------------------------------------------*
	SX1->(DbSetOrder(1))//nao trocar

	If nIncAlt <> 2     // Gerar SX1
		If !SX1->(DbSeek(cPerg+aSx1[Len(aSx1),2]))
			SX1->(DbSeek(cPerg))
			While !SX1->(Eof()) .And. Alltrim(SX1->X1_GRUPO) == cPerg
				SX1->(RecLock("SX1",.F.,.F.))
				SX1->(DbDelete())
				SX1->(MsunLock())
				SX1->(DbSkip())
			End
			For X1:=2 To Len(aSX1)
				SX1->(RecLock("SX1",.T.))
				For Z:=1 To Len(aSX1[1])
					cCampo := "X1_"+aSX1[1,Z]
					SX1->(FieldPut(SX1->(FieldPos(cCampo)),aSx1[X1,Z] ))
				Next
				SX1->(MsUnLock())
			Next X1
		Endif
	Else
		xTamSX := Len(aSX1)

		If SX1->(DbSeek(cPerg))
			For Z:=1 To xTamSX
				SX1->(RecLock("SX1",.F.))
				cCampo := "X1_CNT01"
				SX1->(FieldPut(SX1->(FieldPos(cCampo)), aSx1[Z, 3] ))
				SX1->(MsunLock())
				SX1->(DbSkip())
			Next
		End

	Endif

Return

	*-----------------------------------*
User Function TxtToArr(cTexto,cDelim)
	*-----------------------------------*
	aRet    := {}
	cFinal  := ""
	nPosIni := 1
	nTamTxt := Len(cTexto)
	While .T.
		nCol := At( cDelim , SubStr( cTexto , nPosIni , nTamTxt ) )
		If nCol == 0
			cFinal := Upper( SubStr( cTexto , nPosIni , nTamTxt ) )
			If Empty( cFinal )
				Exit
			EndIf
		EndIf
		nPosFim := If( Empty( cFinal ) , nCol - 1 , Len(cFinal) )
		AAdd( aRet , Upper( SubStr( cTexto , nPosIni , nPosFim ) ) )
		nPosIni += If( Empty( cFinal ) , nCol , Len(cFinal) )
	End

Return(aRet)

	*******************************************************************************
	* FunÁ„o......: ValPed()                                                      *
	* Programador.: Cesar Dupim                                                   *
	* Finalidade..: ValidaÁ„o de Talon·rio. Posiciona SZ1,SA1,SA3                 *
	*                                                                             *
	* Data........: 09/01/06                                                      *
	******************************************************************************
User Function ValPed(cPed,lInc,lMsg)
	Local lRet:=.F.
	dbselectarea("SZ1")
	dbOrderNickName("CSZ11")
	dbseek(xFilial("SZ1")+cPed)
	if found() .and. SZ1->Z1_STATUS $ "AP"   //Tal„o Novo = A ou Tal„o em uso = P
		dbselectarea("SA1")
		dbOrderNickName("PSA11")
		dbseek(xFilial("SA1")+SZ1->Z1_CLIENTE+SZ1->Z1_LOJA)
		if found()
			//dbselectarea("SA3")
			//dbsetorder(1)
			//dbseek(xFilial("SA3")+SA1->A1_VEND)
			//if found()
			if lInc
				dbselectarea("SZ1")
				reclock("SZ1",.F.)
				if SZ1->Z1_PROX < SZ1->Z1_SEQ2
					SZ1->Z1_STATUS = "P"
					SZ1->Z1_PROX:=StrZero(Val(SZ1->Z1_PROX)+1,7)
				else
					SZ1->Z1_STATUS = "F"  //Tal„o Concluido
				endif
				msunlock()
				lRet:=.T.
			else
				lret:=.T.
			endif
			//endif
		endif
	else
		cQUery:="SELECT Z1_CLIENTE, Z1_LOJA FROM "+RetSQLName("SZ1")+" "
		cQUery+="WHERE D_E_L_E_T_ <> '*' AND '"+cPed+"' BETWEEN Z1_SEQ1 AND Z1_SEQ2 " //AND Z1_PROX > '"+cPed+"' "
		TCQUERY cQuery ALIAS "VALTAL" NEW
		dbselectarea("VALTAL")
		if !eof() .AND. VALTAL->Z1_CLIENTE <> " "
			dbselectarea("SA1")
			dbOrderNickName("PSA11")
			if dbseek(xFilial("SA1")+VALTAL->Z1_CLIENTE+VALTAL->Z1_LOJA)
				lRet:=.T.
			else
				if lMsg = nil .or. lMsg
					Alert("Pedido n„o encontrado ou fora da sequÍncia!")
				endif
			endif
		else
			if lMsg = nil .or. lMsg
				Alert("Pedido n„o encontrado ou fora da sequÍncia!")
			endif
		endif
		dbselectarea("VALTAL")
		dbclosearea()
		dbselectarea("SA1")
		//	restarea(aArea)
	endif
return(lRet)

	*******************************************************************************
	* FunÁ„o......: GeraNovoCod()                                                 *
	* Programador.: Cesar Dupim                                                   *
	* Finalidade..: Gera Copia do cadastro de produto a partir do codigo informado*
	*               com as novas medidas                                          *
	* Data........: 23/01/06                                                      *
	*******************************************************************************
	* AlteraÁ„o...: Antonio Carmo							Data.....: 24/04/2007 *
	* Inclus„o do cÛdigo base para Protetores									  *
	*                                                                             *
	*******************************************************************************
//Peder Munksgaard - 18/09/2018
//SSI 68717 - LiberaÁ„o Manta sobmedida UN03.

User Function GeraNovoCod(cCodBase,cMed,lPerson,cDesc,cCorte,nChanfro,cCodEquip,lCia)
	Local i:=0
	Local aCopia:={}
	Local aCampos:={}
	Local aSB1:={}
	Local cCod:=""
	Local cCod1:=substr(cCodBase,1,6)
	Local cCod2:="999A"
	Local cQuery:=""
	Local nCusto:=0
	Local cCodAux:=""
	Local cPrefix:=substr(cCorte,1,1)
	Local _nI
	Default lCia:=.F.

	cMed:=Upper(cMed)
	if nChanfro==Nil
		nChanfro:=0
	endif
	if cCodEquip==Nil
		cCodEquip:=""
	endif

	Public LXALTSB1 := .T.

	dbselectarea("SB1")
	aSB1:=GetArea()
	dbOrderNickName("PSB11")
	dbseek(xFilial("SB1")+cCodBase)

//O bloco abaixo È utilizado para pegar o produto base de acordo com o modelo do corte.
	If cEmpAnt="24" .or. lCia
		cDesc := ""
		cCodAux := cCodBase
		//If Substr(cCorte,1,4) =="SACO" .AND. SB1->B1_XMODELO < "001000"


		If aModelo[ascan(aCorte,cCorte)] <> SB1->B1_XMODELO .Or. Val(cCodEquip) > 3 //Para equipamentos apos o corte e solda

			cQuery:=" SELECT MIN(B1_COD) B1_COD FROM "+RetSqlName("SB1")+" SB1 "
			cQuery+=" WHERE D_E_L_E_T_ = ' ' "
			cQuery+=" AND B1_FILIAL = ' '"
			cQuery+=" AND B1_XCODBAS = ' ' "
			cQuery+=" AND B1_XMODELO = '"+aModelo[ascan(aCorte,cCorte)]+"'"
			If Alltrim(aModelo[ascan(aCorte,cCorte)]) $ ('240128|240129|240130|240131|240132|240136|240137|240138|240145')
				cQuery += "                          AND B1_COD LIKE '203021%'"
			Else
				cQuery += "                          AND (B1_COD LIKE '1010%' )"
			EndIf

			TcQuery cQuery New Alias "TRBCODBAS"

			dbselectarea("SB1")
			dbOrderNickName("PSB11")

			If !TRBCODBAS->(Eof()) .And. !Empty(TRBCODBAS->B1_COD) .And. dbseek(xFilial("SB1")+TRBCODBAS->B1_COD)
				cCodBase := SB1->B1_COD
			Else
				Alert("Nao encontrado produto com o modelo especificado!")
			EndIf

			DbSelectarea("TRBCODBAS")
			DbCloseArea()

			dbselectarea("SB1")
			aSB1:=GetArea()
			dbOrderNickName("PSB11")
			dbseek(xFilial("SB1")+cCodBase)

		EndIf
	EndIf


	if cCorte == nil .or. cCorte == "COLCH√O" .or. cCorte == "MOLA"
		cCod1:=substr(cCodBase,1,6)
	else
		nDens:=SB1->B1_XDENSEQ
		if cCorte =="MANTA"
			cCod1:="104011"
			nDens:=1
		elseIf Substr(cCorte,1,4) =="SACO" .or. Substr(cCorte,1,3) =="BOB" //BOB E SACO CIAPLAST
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

	while cCod2=="9999" .or. select("QRYAUX")==0
		if select("QRYAUX")>0
			QRYAUX->(DbCloseArea())
		endif
		cQuery:="SELECT MAX(B1_COD) COD FROM "+RetSqlName("SB1")+" "
		cQuery+="WHERE D_E_L_E_T_ <> '*' AND B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD LIKE '"+cCod1+"%' "
		TCQUERY cQuery ALIAS "QRYAUX" NEW
		cCod2:=substr(QRYAUX->COD,7,4)

		If	Empty(cCod2)	.And.	!Empty(cCod1) .and. cEmpAnt $ "18" // executa para a un.18
			cCod2	:=	cPrefix+"001"
		Elseif cPrefix <> SUBSTR(cCod2,1,1) .AND. cEmpAnt $ "18"
			cCod2	:=	cPrefix+"001"
		ElseIf cEmpAnt $ "18"
			cCod2 := cPrefix + SUBSTR(cCod2,2,4)
		Endif

		If	(Empty(cCod2) .or. cCod2<="9999")	.And.	!Empty(cCod1) .and. cEmpAnt # "18"
			cCod2	:=	"A001"
		Endif

		if SubStr(cCod2,2,3) == "999"
			//dbselectarea("QRYAUX")
			//dbclosearea()
			cCod2 := soma1(SubStr(cCod2,1,1))+"001"
		Else
			dbselectarea("SB1")
			dbOrderNickName("PSB11")
			//cCod2 := SubStr(cCod2,1,1)+soma1(SubStr(cCod2,2,3))
			while dbseek(xFilial("SB1")+cCod1+cCod2+SPACE(5))
				cCod2 := SubStr(cCod2,1,1)+soma1(SubStr(cCod2,2,3))
			enddo
		EndIf

	enddo
	If cEmpAnt $ "02|03|04|05|25|06|07|08|09|10|11|15|18|22|26" .AND. cCorte <> "MANTA" .and. !lCia
		nAlt:=val(substr(cMed,01,5))/10000
//SSI 68717
	Elseif cEmpAnt == "03" .And. cCorte == "MANTA"
		nAlt:=val(substr(cMed,01,5))/10000
	Else
//
		nAlt:=val(substr(cMed,11,5))/10000
	EndIf
	dbselectarea("QRYAUX")
	cCod:=cCod1+cCod2
//U_JobCInfo("FUNCOES.PRW", "GERANDO SOBMEDIDA : " + cCod, 0)

	dbclosearea()
	dbselectarea("SB1")
	dbOrderNickName("PSB11")
	dbseek(xFilial("SB1")+cCodBase)
	aCampos:=Dbstruct()
	nQtdEmb:=1
	cEspVol:="01"
	if found()
		if cCorte == "PE«A" .or. cCorte == "PECA" .or. cCorte == "LAMINADO" .or. cCorte == "ALMOFADA" .or. cCorte == "CHANFRADO" .or. cCorte == "PLACA"
			cUM:="UN"
		Elseif Substr(cCorte,1,4) = "SACO" .OR. Substr(cCorte,1,7) = "LAMINA "
			cUM:="ML"
			cSegUM :="KG"
		Elseif Substr(cCorte,1,3) = "BOB" .OR. Substr(cCorte,1,5) =="FILME"
			cUM:="KG"
			cSegUM :="KG"
		else
			if cCorte == "TORNEADO"
				cUM:="MT"
			else
				cUM:=SB1->B1_UM
			endif
		endif
		if cCorte == "LAMINADO" .or. cCorte == "PLACA"
			cSegUM   :="MT"
			cTipConv :="M"
			nConv    :=5
			IF nAlt < 0.02
				nQtdEmb:=25
			else
				if nAlt < 0.03
					nQtdEmb:=20
				else
					if nAlt < 0.04
						nQtdEmb:=15
					else
						if nAlt < 0.05
							nqtdemb:=10
						else
							nQtdEmb:=5
						endif
					endif
				endif
			endif
			cEspVol:="05"
		else
			cSegUM   :=IIf(cCorte == "TORNEADO" .And. AllTrim(cCodBase) == "2010112520", "M2", SB1->B1_SEGUM)	//Conforme solicitaÁ„o de Reinaldo Sales (Un 09-CE), este bloco deve produzir torneados em M2
			cTipConv :=SB1->B1_TIPCONV
			nConv    :=SB1->B1_CONV
		endif
		if nConv==0
			nConv:=1
		endif
		if Empty(cSegUm)
			cSegum:=cUm
		endif

		cGrTrib :=SB1->B1_GRTRIB
		nAliqIpi:=SB1->B1_IPI
		cCodFis :=SB1->B1_POSIPI

		if cCorte == "MANTA"
			cModelo :="000011" //Laminado
			cboGrTrib :=SB1->B1_GRTRIB
			nAliqIpi:=SB1->B1_IPI
			cCodFis :=SB1->B1_POSIPI
		ElseIf Substr(cCorte,1,4) == "SACO"
			Do Case
			case cCorte == "SACO TRANSP"
				cModelo :="240048" //Laminado
				cDesc   :="SC TRANSP LISO SM"
			case cCorte == "SACO COLORIDO"
				cModelo :="240049
				cDesc   :="SC COLOR SM"
			case cCorte == "SACO REC"
				cModelo :="240050"
				cDesc   :="SC REC SM"
			case cCorte == "SACO REC COLOR"
				cModelo :="240051"
				cDesc   :="SC REC COLOR SM "
			case cCorte == "SACO LEIT LISO"
				cModelo :="240052"
				cDesc   :="SC LEITOSO LISO SM"
			case cCorte == "SACO TRANSP IMP"
				cModelo :="240059"
				cDesc   :="SC TRANSP IMP SM"
			case cCorte == "SACO COLORIDO IMP"
				cModelo :="240060"
				cDesc   :="SC COLOR IMP SM"
			case cCorte == "SACO REC IMP"
				cModelo :="240061"
				cDesc   :="SC REC IMP SM"
			case cCorte == "SACO REC COLOR IMP"
				cModelo :="240062"
				cDesc   :="SC REC COLOR IMP SM"
			case cCorte == "SACO LEIT IMP"
				cModelo :="240063"
				cDesc   :="SC LEITOSO IMP SM"
			case cCorte == "SACO REC ALL FIBRA"
				cModelo :="240064"
				cDesc   := "SC REC SM"//"SC REC ALL FRIBRA SM"
			case cCorte == "SACO TRANSP IMP AMAN"
				cModelo :="240065"
				cDesc   := "SC TRANSP IMP SM" //"SC TRANSP IMP AMAN SM"
			case cCorte == "SACO IMP ASFIXIA"
				cModelo :="240067"
				cDesc   := "SC TRANSP IMP AFX"
			case cCorte == "SACO SHRINK IMP"
				cModelo :="240068"
				cDesc   := "SC SHRINK IMP"
			case cCorte == "SACO SHRINK TRANSP"
				cModelo :="240069"
				cDesc   := "SC SHRINK TRANSP"
			otherwise
				cDesc   :=alltrim(cCorte)
				cModelo :=aModelo[ascan(aCorte,cCorte)]
			EndCase

			cGrTrib :=SB1->B1_GRTRIB
			nAliqIpi:=SB1->B1_IPI
			cCodFis :=SB1->B1_POSIPI

		ElseIf Substr(cCorte,1,7) == "LAMINA "
		    If cCorte=="LAMINA TRANSP"
				cModelo :="001028"
			Else
				cModelo :=aModelo[ascan(aCorte,cCorte)]
			Endif
			cGrTrib :=SB1->B1_GRTRIB
			nAliqIpi:=SB1->B1_IPI
			cCodFis :=SB1->B1_POSIPI

		ElseIf Substr(cCorte,1,5) == 'FILME'
			Do Case
			case cCorte == "FILME TRANSP"
				cDesc   :="FILME TRANSP SM "
				cModelo :="240007" //Laminado
			case cCorte == "FILME LEIT LISO"
				//cDesc   :="FILME LEITOSO IMPRES SM"
				cDesc   :="FILME LEITOSO LISO SM" //SSI 58153 - 19/01/18
				cModelo :="240008"
			case cCorte == "FILME LEIT LISO BANNER"
				cDesc   :="FILME LEITOSO LISO BANNER SM "
				cModelo :="240009"
			case cCorte == "FILME REC"
				cDesc   :="FILME REC SM "
				cModelo :="240010"
			case cCorte == "FILME REC COLOR"
				cDesc   :="FILME REC COLOR SM"
				cModelo :="240011"
			case cCorte == "FILME TEC"
				cDesc   :="FILME TEC SM"
				cModelo :="240012"
			case cCorte == "FILME TEC LEITOSO"
				cDesc   :="FILME TEC LEITOSO SM"
				cModelo :="240013"
			case cCorte == "FILME SHIRINK"
				cDesc   :="FILME SHIRINK TRANSP SM "
				cModelo :="240014"
			case cCorte == "FILME ENF TRANSP"
				cDesc   :="FILME ENF TRANSP SM"
				cModelo :="240015"
			case cCorte == "FILME ENF IMP"
				cDesc   :="FILME ENF IMP SM"
				cModelo :="240016"
			case cCorte == "FILME SHIRINK IMP"
				cDesc   :="FILME SHIRINK IMP SM"
				cModelo :="240017"
			case cCorte == "FILME TRANSP IMP"
				cDesc   :="FILME TRANSP IMP SM"
				cModelo :="240028"
			case cCorte == "FILME LEIT IMPRES"
				cDesc   :="FILME LEITOSO IMP SM"
				cModelo :="240029"
			case cCorte == "FILME LEIT IMPRES BANNER"
				cDesc   :="FILME LEITOSO IMP BANNER SM"
				cModelo :="240030"
			otherwise
				cDesc   :=alltrim(cCorte)
				cModelo :=aModelo[ascan(aCorte,cCorte)]
			EndCase

			cGrTrib :=SB1->B1_GRTRIB
			nAliqIpi:=SB1->B1_IPI
			cCodFis :=SB1->B1_POSIPI

		ElseIf Substr(cCorte,1,3) == "BOB"

			Do Case
			case cCorte == "BOB TRANSP"
				cModelo := "240002" //Laminado
				cDesc   := "BOB TRANSP SM"
			case cCorte == "BOB COLOR"
				cModelo := "240003"
				cDesc   := "BOB COLOR SM "
			case cCorte == "BOB RECICLADA"
				cModelo := "240004"
				cDesc   := "BOB REC SM "
			case cCorte == "BOB REC COL"
				cModelo := "240005"
				cDesc   := "BOB REC COLOR SM"
			case cCorte == "BOB TRANSP IMP"
				cModelo := "240018"
				cDesc   := "BOB TRANSP IMP SM "
			case cCorte == "BOB COL IMP"
				cModelo := "240019"
				cDesc   := "BOB COLOR IMP SM "
			case cCorte == "BOB REC IMP"
				cModelo := "240020"
				cDesc   := "BOB REC IMP SM "
			case cCorte == "BOB REC COL IMP"
				cModelo := "240021"
				cDesc   := "BOB REC COLOR IMP SM "
			case cCorte == "BOB LEIT LISA"
				cModelo := "240006"
				cDesc   := "BOB LEITOSA LISA SM"
			case cCorte == "BOB LEIT IMP"
				cModelo := "240022"
				cDesc   := "BOB LEITOSA IMP SM"
			case cCorte == "BOB FILME TRANSP (SEMI ACAB)"
				cModelo := "240026"
				cDesc   := "BOB FILME TRANSP"
			case cCorte == "BOB FILME ENF TRANSP (SEMI ACABADO)"
				cModelo := "240031"
				cDesc   := "BOB FILME ENF TRANSP"
			case cCorte == "BOB FILME SHRINK TRANSP(SEMI ACABADO)"
				cModelo := "240032"
				cDesc   := "BOB FILME SHRINK TRANSP"
			case cCorte == "BOB REC ALL FIBRA"
				cModelo := "240034"
				cDesc   := "BOB REC SM" //"BOB REC ALL FIBRA SM "
			case cCorte == "BOB TRANSP (SEMI ACAB)"
				cModelo := "240023"
				cDesc   := "BOB TRANSP SA" //"BOB REC ALL FIBRA SM "
			otherwise
				cDesc   :=alltrim(cCorte)
				cModelo :=aModelo[ascan(aCorte,cCorte)]
			EndCase

			cGrTrib :=SB1->B1_GRTRIB
			nAliqIpi:=SB1->B1_IPI
			cCodFis :=SB1->B1_POSIPI
		else
			if cCorte == "LAMINADO"
				cModelo :="000008" //Laminado
				If cEmpAnt <> "18"
					cGrTrib :=GetMV("MV_XGRTLAM")
					nAliqIpi:=GetMV("MV_XIPILAM")
					cCodFis :=GetMV("MV_XCFLAM")
				Endif
			else
				if cCorte == "PLACA"

					cModelo :="000008" //Laminado
					cGrTrib :=GetNewPar("MV_XGRTPLA",'001')
					nAliqIpi:=GetNewPar("MV_XIPIPLA",0)
					cCodFis :=GetNewPar("MV_XCFPLA",'94042100')
				else
					if cCorte == "TORNEADO"
						cModelo:="000009" //Torneado
						cGrTrib :=GetMV("MV_XGRTTOR")
						nAliqIpi:=GetMV("MV_XIPITOR")
						cCodFis :=GetMV("MV_XCFTOR")
					else
						if cCorte == "PE«A"
							cModelo:="000010" //PeÁa
							If cEmpAnt <> "18"
								cGrTrib :=GetMV("MV_XGRTPEC")
								nAliqIpi:=GetMV("MV_XIPIPEC")
								cCodFis :=GetMV("MV_XCFPEC")
							Endif
						else
							if cCorte == "ALMOFADA"
								cModelo:="000011" //Almofada
								cGrTrib :=GetMV("MV_XGRTALM")
								nAliqIpi:=GetMV("MV_XIPIALM")
								cCodFis :=GetMV("MV_XCFALM")
							else
								if cCorte == "PERFILADO"
									cModelo :="000018" //PeÁa
									If cEmpAnt <> "18"
										cGrTrib :=GetnewPar("MV_XGRTPER","002")
										nAliqIpi:=GetnewPar("MV_XIPIPER",0)
										cCodFis :=GetnewPar("MV_XCFPER","39211390")
									Endif
								else
									cModelo:=SB1->B1_XMODELO //Demais
									cGrTrib :=SB1->B1_GRTRIB
									nAliqIpi:=SB1->B1_IPI
									cCodFis :=SB1->B1_POSIPI
								endif
							endif
						endif
					endif
				endif
			endif
		endif
		If cEmpAnt $ "02|03|04|05|25|06|07|08|09|10|11|15|18|26" .and. !lCia
			if cCorte == "LAMINADO"
				nEsp:=(val(substr(cMed,7,4))/1000)*(val(substr(cMed,1,5))/10000)*13
				//SSI 68717
			Elseif cCorte == "MANTA" .And. cEmpAnt == "03"
				nEsp:=(val(substr(cMed,7,4))/1000)*(val(substr(cMed,1,5))/10000)*13
			else
				//
				nEsp:=(val(substr(cMed,12,4))/1000)*(val(substr(cMed,7,4))/1000)*(val(substr(cMed,1,5))/10000)*10
			endif
		Else
			if cCorte == "LAMINADO"
				If cEmpAnt$"22"
					nEsp:=(val(substr(cMed,7,4))/1000)*(val(substr(cMed,1,5))/10000)*13
				Else
					nEsp:=(val(substr(cMed,6,4))/1000)*(val(substr(cMed,11,5))/10000)*13
				Endif
			else
				nEsp:=(val(substr(cMed,1,4))/1000)*(val(substr(cMed,6,4))/1000)*(val(substr(cMed,11,5))/10000)*10
			endif
		EndIf
		if cCorte <> Nil .and. cCorte <> "COLCH√O"  .and. cCorte <> "MOLA"  .and. cCorte <> "BLOCO" .and. cCorte <> "MANTA" .and. cCorte <> " " .And.;
				Substr(cCorte,1,4) <> 'SACO' .AND. Substr(cCorte,1,3) <> 'SC ' .AND. Substr(cCorte,1,3) <> 'BOB' .AND.;
				Substr(cCorte,1,7) <> 'LAMINA ' .and. Substr(cCorte,1,5) <> 'FILME'
			if SB1->B1_XDENSEQ == 0
				MsgBox("Bloco com densidade zerada. Preencha  o campo peso bruto","Erro Calculo de custo")
			endif
			nCusto:=SB1->B1_CUSTD
			nDens :=round(SB1->B1_XQTDEMB/ROUND(SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP,2),2)
			nDensEqu:=SB1->B1_XDENSEQ
			If cEmpAnt $ "02|03|04|05|25|06|07|08|09|10|11|15|18|26" .and. !lCia
				if (val(substr(cMed,7,4))/1000) == 1.9
					nCompAux:=1.93
				else
					nCompAux:=   (val(substr(cMed,7,4))/1000)
				endif
				if cCorte == "CHANFRADO"
					nVol  :=(val(substr(cMed,12,4))/1000)*nCompAux*((val(substr(cMed,1,5))/10000)+nChanfro)*2
				elseIf cCorte == "TORNEADO" .And. SB1->B1_COD == "2010112520"	//Conforme solicitaÁ„o de Rinaldo Sales (unidade 09), o c·lculo de volume para este bloco deve considerar somente duas dimensıes
					nVol  :=nCompAux*(val(substr(cMed,1,5))/10000)
				else
					nVol  :=(val(substr(cMed,12,4))/1000)*nCompAux*(val(substr(cMed,1,5))/10000)
				endif
			Else
				if (val(substr(cMed,6,4))/1000) == 1.9
					nCompAux:=1.93
				else
					nCompAux:=   (val(substr(cMed,6,4))/1000)
				endif
				if cCorte == "CHANFRADO"
					nVol  :=(val(substr(cMed,1,4))/1000)*nCompAux*((val(substr(cMed,11,5))/10000)+nChanfro)*2
				elseIf cCorte == "TORNEADO" .And. SB1->B1_COD == "2010112520"	//Conforme solicitaÁ„o de Rinaldo Sales (unidade 09), o c·lculo de volume para este bloco deve considerar somente duas dimensıes
					nVol  :=nCompAux*(val(substr(cMed,11,5))/10000)
				else
					nVol  :=(val(substr(cMed,1,4))/1000)*nCompAux*(val(substr(cMed,11,5))/10000)
				endif
			EndIf
			nCusto:=nCUSTO*nDensEqu*nVol
			nQB   :=1
		else
			nQB   :=SB1->B1_QB
			If Empty(cUm)
			   cUM   :=SB1->B1_UM
			End if
			If cEmpAnt $ "02|03|04|05|25|06|07|08|09|10|11|15|18|22|26" .AND. cCorte <> "MANTA" .and. !lCia
				nCusto:=SB1->B1_CUSTD*(val(substr(cMed,12,4))/1000)*(val(substr(cMed,7,4))/1000)*(val(substr(cMed,1,5))/10000)
				//SSI 68717
			Elseif cEmpAnt == "03" .And. cCorte == "MANTA"
				nCusto:=SB1->B1_CUSTD*(val(substr(cMed,12,4))/1000)*(val(substr(cMed,7,4))/1000)*(val(substr(cMed,1,5))/10000)
			Else
				//
				nCusto:=SB1->B1_CUSTD*(val(substr(cMed,1,4))/1000)*(val(substr(cMed,6,4))/1000)*(val(substr(cMed,11,5))/10000)
			EndIf
			nCusto/=(SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP)

			If Substr(cCorte,1,3) = 'BOB' .OR.  Substr(cCorte,1,5) = 'FILME'
				//Atualiza os valores de custo e preÁo de acordo com a tabela de preÁo.
				dbselectarea("DA1")
				DbSetOrder(1)
				if dbseek(xFilial("DA1")+cTabPr+SB1->B1_COD)
					nValCus 	:= DA1->DA1_XCUSTO
					nPrVen      := DA1->DA1_PRCVEN
				EndIf

				nCusto:=SB1->B1_CUSTD

				//Atualiza o peso da bobina. Peso padr„o 1kg
				nxPeso:= 1
				cAuxMed:= substr(cMed,1,3)+"X"+substr(cMed,6,3)+"X"+substr(cMed,13,3)

			ElseIf Substr(cCorte,1,4) = 'SACO' .or. Substr(cCorte,1,4) = 'SC ' 
				//Atualiza os valores de custo e preÁo de acordo com o fator do valor do KG e da tabela de preÁo.

				nLarg:= val(substr(cMed,1,4))/10
				nComp:= val(substr(cMed,6,4))/10
				nAlt := val(substr(cMed,11,5))/10000

				nxPeso:= (nLarg*nComp*nAlt*0.922)
				nConv := (nLarg*nComp*nAlt*0.922) //Grava o fator de convers„o

				cAuxMed:= substr(cMed,1,3)+"X"+substr(cMed,6,3)+"X"+substr(cMed,13,3)

				dbselectarea("DA1")
				DbSetOrder(1)
				if dbseek(xFilial("DA1")+cTabPr+SB1->B1_COD)

					nKgMl    := Round(DA1->DA1_XCUSTO / ((SB1->B1_XLARG*100)*(SB1->B1_XCOMP*100)*SB1->B1_XALT*0.922),2)
					nValCus  := Round(nKgMl*(nLarg*nComp*nAlt*0.922),2)

					nKgMl    := Round(DA1->DA1_PRCVEN / ((SB1->B1_XLARG*100)*(SB1->B1_XCOMP*100)*SB1->B1_XALT*0.922),2)
					nPrVen   := Round(nKgMl*(nLarg*nComp*nAlt*0.922),2)
				EndIf

				nKgMl := Round(SB1->B1_CUSTD / ((SB1->B1_XLARG*100)*(SB1->B1_XCOMP*100)*SB1->B1_XALT*0.922),2)
				nCusto:= Round(nKgMl*(nLarg*nComp*nAlt*0.922),2)

				//SSI 68717
				//ElseIf	Substr(cCorte,1,7) = 'LAMINA '
			ElseIf	Substr(cCorte,1,7) = 'LAMINA ' .Or. (cCorte == "MANTA" .And. cEmpAnt == "03")
				//Atualiza os valores de custo e preÁo de acordo com o fator do valor do KG e da tabela de preÁo.

				nLarg:= val(substr(cMed,1,4))/1000
				nComp:= val(substr(cMed,6,4))/1000
				nAlt := val(substr(cMed,11,5))/10000

				//SSI 68717
				If (cCorte == "MANTA" .And. cEmpAnt == "03")
					nxPeso:= (nLarg*nComp*nAlt*1)
				Else
					nxPeso:= (nLarg*nComp*nAlt*9220)
				Endif
				//
				//cAuxMed:= substr(cMed,12,3)+"X"+substr(cMed,7,3)+"X"+substr(cMed,3,3)
				cAuxMed:= substr(cMed,1,3)+"X"+substr(cMed,6,3)+"X"+substr(cMed,13,3)

				dbselectarea("DA1")
				DbSetOrder(1)
				if dbseek(xFilial("DA1")+cTabPr+SB1->B1_COD)

					//SSI 68717
					If (cCorte == "MANTA" .And. cEmpAnt == "03")
						//nKgMl    := Round(DA1->DA1_XCUSTO / ((SB1->B1_XLARG*100)*(SB1->B1_XCOMP*100)*SB1->B1_XALT*0.922),2)
						nValCus  := Round(DA1->DA1_XCUSTO*(nLarg*nComp*nAlt*1),2)

						//nKgMl    := Round(DA1->DA1_PRCVEN / ((SB1->B1_XLARG*100)*(SB1->B1_XCOMP*100)*SB1->B1_XALT*0.922),2)
						nPrVen   := Round(DA1->DA1_PRCVEN*(nLarg*nComp*nAlt*1),2)
					Else
						//nKgMl    := Round(DA1->DA1_XCUSTO / ((SB1->B1_XLARG*100)*(SB1->B1_XCOMP*100)*SB1->B1_XALT*0.922),2)
						nValCus  := Round(DA1->DA1_XCUSTO*(nLarg*nComp*nAlt*0.922),2)

						//nKgMl    := Round(DA1->DA1_PRCVEN / ((SB1->B1_XLARG*100)*(SB1->B1_XCOMP*100)*SB1->B1_XALT*0.922),2)
						nPrVen   := Round(DA1->DA1_PRCVEN*(nLarg*nComp*nAlt*0.922),2)
					Endif

				EndIf

				//SSI 68717
				//nKgMl := Round(SB1->B1_CUSTD / ((SB1->B1_XLARG*100)*(SB1->B1_XCOMP*100)*SB1->B1_XALT*0.922),2)
				If (cCorte == "MANTA" .And. cEmpAnt == "03")
					nCusto:= Round(SB1->B1_CUSTD*(nLarg*nComp*nAlt*0.922),2)
				Else
					nCusto:= Round(SB1->B1_CUSTD*(nLarg*nComp*nAlt*0.922),2)
				Endif
			EndIf

			DbSelectArea("SB1")
		endif
		If cEmpAnt ==  '18'
			Do Case
			Case AllTrim(cCorte)=="BLOCO"
				cCorte18:="B"
			Case AllTrim(cCorte)=="LAMINADO"
				cCorte18:="L"
			Case AllTrim(cCorte)=="LAMINA"
				cCorte18:="N"
			Case AllTrim(cCorte)=="PE«A"
				cCorte18:="P"
			Case AllTrim(cCorte)=="PECA"
				cCorte18:="P"
			Case AllTrim(cCorte)=="CHANFRADO"
				cCorte18:="C"
			Case AllTrim(cCorte)=="PERFILADO"
				cCorte18:="R"
			Otherwise
				cCorte18:=cCorte
			EndCase
			IF CCORTE <> "COLCH√O" .and. CCORTE <> "MOLA"
				if at("BLOCO ",SB1->B1_DESC)>0
					cDesc   := "BLOCO " + cCorte18+ " " + AllTrim(SubStr(SB1->B1_DESC,at("BLOCO ",SB1->B1_DESC)+6,20))
				else
					cDesc   := "BLOCO " + cCorte18+ " " + AllTrim(SB1->B1_DESC)
				endif
			ELSE
				iF Empty(cDesc)
					cDesc   := alltrim(substr(SB1->B1_DESC,1,27)) + " SM"
				EndIf
			ENDIF
			Do Case
			Case 'AMARELO' $ cDesc
				cDesc := StrTran(cDesc,'AMARELO','AM')
			Case 'AZUL' $ cDesc
				cDesc := StrTran(cDesc,'AZUL','AZ')
			Case 'BEGE' $ cDesc
				cDesc := StrTran(cDesc,'BEGE','BE')
			Case 'BRANCO' $ cDesc
				cDesc := StrTran(cDesc,'BRANCO','BR')
			Case 'GRAFITE' $ cDesc
				cDesc := StrTran(cDesc,'GRAFITE','GR')
			Case 'LARANJA' $ cDesc
				cDesc := StrTran(cDesc,'LARANJA','LA')
			Case 'LILAS' $ cDesc
				cDesc := StrTran(cDesc,'LILAS','LI')
			Case 'MARROM' $ cDesc
				cDesc := StrTran(cDesc,'MARROM','MA')
			Case 'ROSA' $ cDesc
				cDesc := StrTran(cDesc,'ROSA','RO')
			Case 'VERDE' $ cDesc
				cDesc := StrTran(cDesc,'VERDE','VE')
			EndCase
		Else
			IF CCORTE <> "COLCH√O" .And. cEmpAnt <> '24' .and. !lCia .and. CCORTE <> "MOLA"
				if cCorte=="PE«A"
					cMV_PAR:="MV_XPECA"
				else
					cMV_PAR:="MV_X"+SUBSTR(cCorte,1,5)
				endif
				cDescAux:=GETNEWPAR(cMV_PAR," ")
				if empty(cDescAux)
					if at("BLOCO ",SB1->B1_DESC)>0
						cDesc   :=cCorte+" "+substr(SB1->B1_DESC,at("BLOCO ",SB1->B1_DESC)+6,20)
					else
					    if at(cCorte,SB1->B1_DESC) > 0
        					cDesc   :=cCorte+" "+substr(SB1->B1_DESC,at(cCorte,SB1->B1_DESC)+len(ccorte),20)
						else
						   cDesc   :=cCorte+" "+alltrim(SB1->B1_DESC)
						endif
					endif
				else
					if at("BLOCO ",SB1->B1_DESC)>0
						cDesc   :=cDescAux+" "+substr(SB1->B1_DESC,at("BLOCO ",SB1->B1_DESC)+6,20)
					else
						cDesc   :=cDescAux+" "+alltrim(SB1->B1_DESC)
					endif
				endif
			ELSE
				iF Empty(cDesc)
					cDesc   :=alltrim(substr(SB1->B1_DESC,1,27))+" SM"
				EndIf
			ENDIF
		Endif

		If cEmpAnt == "18"
			nAliqIpi:=SB1->B1_IPI
			cCodFis :=SB1->B1_POSIPI
		Endif

		If cEmpAnt == "24" .or. lCia		//SSI 77326
			nAliqIpi:= 15
		Endif

		for i:=1 to len(aCampos)
			cCampo:=aCampos[i,1]
			do case
			case aCampos[i,1] == "B1_UM"
				aadd(aCopia,{aCampos[i,1],cUM,Nil})
			case aCampos[i,1] == "B1_MSBLQL"
				aadd(aCopia,{aCampos[i,1],"2",Nil})
			case aCampos[i,1] == "B1_CODBAR"
				aadd(aCopia,{aCampos[i,1],"",Nil})
			case aCampos[i,1] == "B1_XDESCVE"
				aadd(aCopia,{aCampos[i,1]," ",Nil})
			case aCampos[i,1] == "B1_FILIAL"
				aadd(aCopia,{aCampos[i,1],xFilial("SB1"),Nil})
			case aCampos[i,1] == "B1_QB"
				aadd(aCopia,{aCampos[i,1],nQB,Nil})
			case aCampos[i,1] == "B1_XDTINCL"
				aadd(aCopia,{aCampos[i,1],DDATABASE,Nil})
			case aCampos[i,1] == "B1_COD"
				aadd(aCopia,{aCampos[i,1],cCod,Nil})
			case aCampos[i,1] == "B1_XESPVOL"
				aadd(aCopia,{aCampos[i,1],cEspVol,Nil})
			case aCampos[i,1] == "B1_XQTDEMB"
				aadd(aCopia,{aCampos[i,1],nQtdEmb,Nil})
			case aCampos[i,1] == "B1_DESC"
				aadd(aCopia,{aCampos[i,1],cDesc,Nil})
			case aCampos[i,1] == "B1_XESPACO"
				aadd(aCopia,{aCampos[i,1],nEsp,Nil})
			case aCampos[i,1] == "B1_XMED"
				If cEmpAnt = '24' .or. lCia
					aadd(aCopia,{aCampos[i,1],cAuxMed,Nil})
				Else
					aadd(aCopia,{aCampos[i,1],cMed,Nil})
				EndIf
			case aCampos[i,1] == "B1_XLARG"
				If cEmpAnt $ "02|03|04|05|25|06|07|08|09|10|11|15|18|22|26" .AND. cCorte <> "MANTA" .and. !lCia
					aadd(aCopia,{aCampos[i,1],val(substr(cMed,12,4))/1000,Nil})
					//SSI 68717
				Elseif cEmpAnt == "03" .And. cCorte == "MANTA"
					aadd(aCopia,{aCampos[i,1],val(substr(cMed,12,4))/1000,Nil})
				Else
					//
					aadd(aCopia,{aCampos[i,1],val(substr(cMed,1,4))/1000,Nil})
				EndIf
			case aCampos[i,1] == "B1_XCOMP"
				If cEmpAnt $ "02|03|04|05|25|06|07|08|09|10|11|15|18|22|26" .AND. cCorte <> "MANTA" .and. !lCia
					aadd(aCopia,{aCampos[i,1],val(substr(cMed,7,4))/1000,Nil})
					//SSI 68717
				Elseif cEmpAnt == "03" .And. cCorte == "MANTA"
					aadd(aCopia,{aCampos[i,1],val(substr(cMed,7,4))/1000,Nil})
				Else
					//
					aadd(aCopia,{aCampos[i,1],val(substr(cMed,6,4))/1000,Nil})
				EndIf
			case aCampos[i,1] == "B1_XALT"
				If cEmpAnt $ "02|03|04|05|25|06|07|08|09|10|11|15|18|22|26" .AND. cCorte <> "MANTA" .and. !lCia
					aadd(aCopia,{aCampos[i,1],val(substr(cMed,1,5))/10000,Nil})
					//SSI 68717
				Elseif cEmpAnt == "03" .And. cCorte == "MANTA"
					aadd(aCopia,{aCampos[i,1],val(substr(cMed,1,5))/10000,Nil})
				Else
					//
					aadd(aCopia,{aCampos[i,1],val(substr(cMed,11,5))/10000,Nil})
				EndIf
			case aCampos[i,1] == "B1_XCHANFR" .and. (cEmpAnt == '24' .or. lCia)
				aadd(aCopia,{aCampos[i,1],nChanfro,Nil})
			case aCampos[i,1] == "B1_LE" .and. cEmpAnt = '18'
				aadd(aCopia,{aCampos[i,1],0,Nil})
			case (aCampos[i,1] == "B1_PESO" .or. aCampos[i,1] == "B1_PESBRU") .and. (cEmpAnt == '24' .or. lCia)
				aadd(aCopia,{aCampos[i,1],nxPeso,Nil})
			case aCampos[i,1] == "B1_XTPCOLC" .AND. cCorte <> "MANTA"
				If cEmpAnt $ "02|03|04|05|25|06|07|08|09|10|11|15|18|26" .and. !lCia
					if val(substr(cMed,12,4))/1000 <= 0.7
						aadd(aCopia,{aCampos[i,1],"B",Nil})
					else

						if val(substr(cMed,12,4))/1000 <= 1.2
							aadd(aCopia,{aCampos[i,1],"S",Nil})
						else
							aadd(aCopia,{aCampos[i,1],"C",Nil})
						endif
					endif
				Else
					if val(substr(cMed,12,4))/1000 <= 0.7
						aadd(aCopia,{aCampos[i,1],"B",Nil})
					else

						if val(substr(cMed,12,4))/1000 <= 1.2
							aadd(aCopia,{aCampos[i,1],"S",Nil})
						else
							aadd(aCopia,{aCampos[i,1],"C",Nil})
						endif
					endif
				EndIf
			case cCorte <> "COLCH√O" .and. aCampos[i,1] == "B1_XTPORTO"  .and. CCORTE <> "MOLA"
				if cCorte == "TORNEADO"
					aadd(aCopia,{aCampos[i,1],"R",Nil})
				else
					if cCorte == "MANTA" .or. cCorte == "LAMINADO"
						aadd(aCopia,{aCampos[i,1],"P",Nil})
					ElseIf Substr(cCorte,1,4) == "SACO"
						aadd(aCopia,{aCampos[i,1],"G",Nil})
					ElseIf Substr(cCorte,1,3) == "BOB"
						aadd(aCopia,{aCampos[i,1],"H",Nil})
					ElseIf Substr(cCorte,1,7) == "LAMINA "
						aadd(aCopia,{aCampos[i,1],"Q",Nil})
					ElseIf Substr(cCorte,1,5) == "FILME"
						aadd(aCopia,{aCampos[i,1],"N",Nil})
					else
						aadd(aCopia,{aCampos[i,1],"E",Nil})
					endif
				endif

			case aCampos[i,1] == "B1_XCODBAS"
				aadd(aCopia,{aCampos[i,1],IIf( cEmpAnt == "24" .or. lCia, cCodAux, cCodBase ),Nil})
//				aadd(aCopia,{aCampos[i,1], cCodBase,Nil})
			case aCampos[i,1] == "B1_XSOBMED"
				aadd(aCopia,{aCampos[i,1],.T.,Nil})
			case aCampos[i,1] == "B1_CUSTD"
				aadd(aCopia,{aCampos[i,1],nCusto,Nil})
			case aCampos[i,1] == "B1_SEGUM"
				aadd(aCopia,{aCampos[i,1],cSEGUM,Nil})
			case aCampos[i,1] == "B1_TIPCONV"
				aadd(aCopia,{aCampos[i,1],cTipConv ,Nil})
			case aCampos[i,1] == "B1_CONV"
				aadd(aCopia,{aCampos[i,1],nConv,Nil})
			case aCampos[i,1] == "B1_XMODELO"
				aadd(aCopia,{aCampos[i,1],cModelo,Nil})
			case aCampos[i,1] == "B1_GRTRIB"
				aadd(aCopia,{aCampos[i,1],cGrTrib,Nil})
			case aCampos[i,1] == "B1_IPI"
				aadd(aCopia,{aCampos[i,1],nAliqIpi,Nil})
			case aCampos[i,1] == "B1_POSIPI"
				aadd(aCopia,{aCampos[i,1],cCodFis,Nil})
			case aCampos[i,1] == "B1_XANT420"
				aadd(aCopia,{aCampos[i,1],"2",Nil})
			case lPerson <> nil .and. lPerson .and. aCampos[i,1] == "B1_XPERSON"
				If IsInCallStack("U_ORTA334") .And. Type("cDescPerson") == "C" .And. !Empty(cDescPerson)
					aadd(aCopia,{aCampos[i,1],PADR(cDescPerson, GetSX3Cache("B1_XPERSON","X3_TAMANHO")),Nil})
				ElseIf !IsInCallStack("U_ORTA334")
					aadd(aCopia,{aCampos[i,1],cDesc,Nil})
				EndIf
			case aCampos[i,1] <> "B1_XNUMFCI"
				aadd(aCopia,{aCampos[i,1],&cCampo,Nil})
			endcase
		next

		If Alltrim(cVersao) <> "P10" // se for a versao 11...
			If FieldPos("B1_TPDP") > 0
				tpdppos := ASCAN(aCopia,{ |X| ALLTRIM(X[1]) == "B1_TPDP" })
				aCopia[tpdppos][2] := "2"
				//aadd(aCopia,{"B1_TPDP",2,Nil})
			Endif
		EndIf

		DbSelectArea("SB1")
		RecLock("SB1",.T.)
		For _nI := 1 To Len(aCopia)
			FieldPut(FieldPos(aCopia[_nI,1]),aCopia[_nI,2])
		Next
		MsUnlock()

		lMSErroAuto:=.F.
		//MSExecAuto({|x,y| Mata010(x,y)},aCopia,3) //Inclusao
		If lMSErroAuto
			MostraErro()
			cCod:=""
		else
			//U_JobCInfo("FUNCOES.PRW", "GRAVOU SOBMEDIDA : " + cCod, 0)
			If cEmpAnt ="24" .or. lCia// Volta o codigo base para gerar a estutura do saco com a bobina no componente.
				cCodBase := cCodAux
				RecLock("SB1",.F.)
				SB1->B1_GCCUSTO := cCodEquip
				MsUnlock()

			EndIf

			if !U_GeraEstru(cCodBase,cCod,cCorte, lCia)
				Alert("N„o Existe estrutura para o produto base!!")
				lMSErroAuto:=.F.
				MSExecAuto({|x,y| Mata010(x,y)},aCopia,5) //Exclus„o
				If lMSErroAuto
					MostraErro()
				Else
					cCod:=""
				Endif
			endif
		endif
	else
		cCod:=""
	endif
	if cCorte <> nil .and. cCorte <> 'COLCH√O' .AND. cCorte <> "MANTA" .AND. cEmpant <> '24' .and. !lCia  .and. CCORTE <> "MOLA"
		U_AceProd(cCodBase,cCod,cCorte,ctabpr)
	ElseIf (cEmpant == '24' .or. lCia) .And. Substr(cCorte,1,4) = 'SACO' .And. !Empty(cCod)
		DBSELECTAREA("SB1")
		DbSetOrder(1)
		If DbSeek(xFilial("SB1")+cCod)
			DBSELECTAREA("SB5")
			dbOrderNickName("PSB51")
			IF DBSEEK(XFILIAL("SB5")+SB1->B1_COD)
				RECLOCK("SB5",.F.)
			ELSE
				RECLOCK("SB5",.T.)
				SB5->B5_FILIAL:=XFILIAL("SB5")
				SB5->B5_COD   :=SB1->B1_COD
				SB5->B5_DESCNFE := SB1->B1_DESC + " " + SB1->B1_XMED
			ENDIF
			SB5->B5_CEME   :=SB1->B1_DESC
			SB5->B5_CONVDIP:= 1 //N„o alterar para B1_PESO], pois n„o unidade 24 trabalha-se de forma diferente. Para o caso de faturamento na segunda unidade de medida deve alimentar o fator de convers„o somente do produto desejado no cadastro de complemento de produto.
			SB5->B5_UMDIPI :=SB1->B1_SEGUM
			SB5->B5_QUAL   :="2"
			SB5->B5_INSPAT :="1"
			SB5->B5_CODATIV:=SB1->B1_POSIPI
			MSUNLOCK()
		EndIF
	endif
return(cCod)
	*******************************************************************************
	* FunÁ„o......: GeraEstru()                                                   *
	* Programador.: Cesar Dupim                                                   *
	* Finalidade..: Gera Estrutura de um produto sob encomenda a partir de um     *
	*               produto base                                                  *
	* Data........: 16/01/06                                                      *
	******************************************************************************
User Function GeraEstru(cCodBase,cCodEnc,cCorte, lCia)
	Local aArea    :=GetArea()
	Local nQtdKg   := 0
	Local nVolBase :=0
	Local nAreaBase:=0
	Local nVolEnc  :=0
	Local nAreaEnc :=0
	Local nProp    :=0
	Local nQB      :=0
	Local aAreaSG1 :={}
	Local cQuery   :=""
	Local lRet     :=.F.
	Local aSG1     :={}
	Local i        :=0
	Local lEstru   := .F.
	Local _nI
	Default lCia:=.F.
	cCodBase := Alltrim(cCodBase)
	cCodEnc  := Alltrim(cCodEnc)

	If cCorte <> nil .and. cCorte <> "COLCH√O"  .and. CCORTE <> "MOLA"
		dbselectarea("SB1")
		dbOrderNickName("PSB11")
		dbseek(xFilial("SB1")+cCodBase)
		nPesoM3:=SB1->B1_QB/(SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP)
		dbgotop()
		dbseek(xFilial("SB1")+cCodEnc)
		if found()
			dbselectarea("SG1")
			dbOrderNickName("PSG11")
			dbseek(xFilial("SG1")+cCodEnc) //Apaga Estrutura anterior se houver
			do while !eof() .and. Alltrim(SG1->G1_COD) == Alltrim(cCodEnc)
				reclock("SG1",.F.)
				delete
				msunlock()
				dbskip()
			enddo

			nQtdKg := 1
			If cEmpAnt == "24" .or. lCia
				cQuery := " SELECT SB1PARA.B1_XALT * SB1PARA.B1_XLARG * 100 * SB1PARA.B1_XCOMP * 100 * " + CRLF
				cQuery += "        0.922 AS PESO " + CRLF
				cQuery += "   FROM "+RetSqlName("SB1")+" SB1DE, "+RetSqlName("SB1")+" SB1PARA " + CRLF
				cQuery += "  WHERE SB1DE.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "    AND SB1PARA.D_E_L_E_T_ = ' ' " + CRLF
				cQuery += "    AND SB1DE.B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
				cQuery += "    AND SB1PARA.B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
				cQuery += "    AND SB1DE.B1_COD = '"+cCodEnc+"' " + CRLF
				cQuery += "    AND SB1DE.B1_GCCUSTO = '00000003' " + CRLF
				cQuery += "    AND SB1PARA.B1_COD = '"+cCodBase+"' " + CRLF
				cQuery += "    AND SB1DE.B1_UM = 'ML' " + CRLF
				cQuery += "    AND SB1PARA.B1_UM = 'KG' " + CRLF

				If Select("CONVMLKG") > 0
					CONVMLKG->(dbCloseArea())
				EndIf
				//memowrit("c:\CONVMLKG.SQL",cQuery)
				TCQUERY cQuery ALIAS "CONVMLKG" NEW
				If !( CONVMLKG->(EOF()) )
					nQtdKg := CONVMLKG->PESO
				EndIf
				CONVMLKG->(dbCloseArea())
			EndIf


/*		If cEmpAnt == '24' .And. Alltrim(cRebobina) == "SIM"
			RecLock("SB1",.F.)
			SB1->B1_GCCUSTO := '00000004' //Rebobinadeira
			MsUnlock()
		EndIF	*/

		If (cEmpAnt == '24' .or. lCia) .And. SB1->B1_GCCUSTO <= '00000001' //Para equipamentos de extrus„o

				//000023 -	BOBINA TRANSP
				//000025 -	BOBINA RECICLADA
					//000026 - 	BOBINA REC COL
				//000027 -	BOBINA LEIT LISA
				//000128	BOBINA TRANSP (SEMI ACAB)
				//000129	BOBINA LEIT (SEMI ACAB)
				//000130	BOBINA RECICLADA (SEMI ACAB)
				//000131	BOBINA FILME TRANSP (SEMI ACAB)
				//000132	BOBINA RECICL COLOR (SEMI ACAB)
				//000136	BOBINA FILME ENF TRANSP (SEMI ACABADO)
				//000137	BOBINA FILME SHIRINK TRANSP(SEMI ACABADO)
				//000138	BOBINA REC ALL FIBRA (SEMI ACABADO)
				//000033 -	FILME TRANSP
				//000034	FILME LEIT LISO
				//000036 -	FILME RECICL
				//000037	FILME REC COLOR
				//000040	FILME SHIRINK
				//000041 -	FILME ENF TRANSP
				//000139 -  BOBINA REC ALL FIBRA
				//000123 -  BOBINA TRANSP IMP
				//001131 -  SACO IMP ASFIXIA

			cQuery := "SELECT * "
			cQuery += "  FROM "+RetSqlName("SG1")+"  SG1 " 
			cQuery += " WHERE G1_FILIAL = '"+xFilial("SG1")+"' "
			cQuery += "   AND D_E_L_E_T_ = ' ' "
			cQuery += "   AND G1_COMP LIKE '0%' "
			cQuery += "   AND G1_COD = '" + cCodBase +"' "

			If Select("CPESTRU") > 0
				CPESTRU->(dbCloseArea())
			EndIf
			memowrit("c:\CPESTRU_1.SQL",cQuery)
			TCQUERY cQuery ALIAS "CPESTRU" NEW
			While !( CPESTRU->(EOF()) )
					DbSelectArea("SG1")
					reclock("SG1",.T.)
					SG1->G1_FILIAL  :=xFilial("SG1")
					SG1->G1_COD     := cCodEnc
					SG1->G1_COMP    := CPESTRU->G1_COMP
					SG1->G1_QUANT   := CPESTRU->G1_QUANT
					SG1->G1_INI     := STOD(CPESTRU->G1_INI)
					SG1->G1_FIM     := STOD("20491231")
					SG1->G1_FIXVAR  := "V"
					msunlock()
					DbSelectArea("CPESTRU")
					DbSkip()
					lEstru := .T.
			End
			DbSelectArea("CPESTRU")
			DbCloseArea()

			If !lEstru
				//Caso n„o tenha resina do produto base a extrusar procuto nos produtos intermedi·rios da estrutura.
				cQuery := "SELECT sg1_1.g1_cod G1_COD1, sg1_1.g1_comp G1_COMP1, sg1_1.g1_QUANT G1_QUANT1, " + CRLF
				cQuery += "sg1_1.g1_INI g1_INI1 , sg1_1.g1_FIM G1_FIM1 , "+ CRLF
				cQuery += "nvl(sg1_2.g1_cod,' ') G1_COD2, sg1_2.g1_comp G1_COMP2, sg1_2.g1_QUANT G1_QUANT2, "+ CRLF
				cQuery += "sg1_2.g1_INI g1_INI2 , sg1_2.g1_FIM G1_FIM2 "+ CRLF
				cQuery += " from siga."+RetSqlName("SG1")+"  sg1_1, siga."+RetSqlName("SG1")+"  sg1_2, "+ CRLF
				cQuery += " siga."+RetSqlName("SB1")+"  SB1"+ CRLF
				cQuery += "where sg1_1.g1_filial = '"+xFilial("SG1")+"' " + CRLF
				cQuery += "and sg1_2.g1_filial(+) = '"+xFilial("SG1")+"' " + CRLF
				cQuery += "and sB1.B1_filial = '"+xFilial("SB1")+"' " + CRLF
				cQuery += "and sg1_1.d_e_l_e_t_ = ' ' "+ CRLF
				cQuery += "and SB1.d_e_l_e_t_ = ' ' "+ CRLF
				cQuery += "AND sg1_2.g1_comp IS NOT NULL "
				cQuery += "and sg1_2.d_e_l_e_t_(+) = ' '"+ CRLF
				cQuery += "and sg1_2.g1_cod(+) = sg1_1.g1_comp "+ CRLF
				cQuery += "AND sg1_1.g1_cod = '" + cCodBase +"' "+ CRLF
				cQuery += "AND SB1.B1_COD = sg1_2.G1_COD "+ CRLF
				cQuery += "AND SB1.B1_TIPO = 'PI' "+ CRLF


				If Select("CPESTRU") > 0
					CPESTRU->(dbCloseArea())
				EndIf
				memowrit("c:\CPESTRU_2.SQL",cQuery)
				TCQUERY cQuery ALIAS "CPESTRU" NEW

				While !( CPESTRU->(EOF()) )
					DbSelectArea("SG1")
					reclock("SG1",.T.)
					SG1->G1_FILIAL  :=xFilial("SG1")
					SG1->G1_COD     := cCodEnc
					SG1->G1_COMP    := CPESTRU->G1_COMP2
					SG1->G1_QUANT   := CPESTRU->G1_QUANT2
					SG1->G1_INI     := STOD(CPESTRU->G1_INI2)
					SG1->G1_FIM     := STOD(CPESTRU->G1_FIM2)
					SG1->G1_FIXVAR  := "V"
					msunlock()
					DbSelectArea("CPESTRU")
					DbSkip()
					lEstru := .T.
				End
			EndIF


		Else

			reclock("SG1",.T.)
			SG1->G1_FILIAL  :=xFilial("SG1")
			SG1->G1_COD     := cCodEnc
			SG1->G1_COMP    := cCodBase
			If Substr(cCorte,1,3) = "SC " .or. Substr(cCorte,1,4) = "SACO" .or. Substr(cCorte,1,7) = "LAMINA "
				SG1->G1_QUANT := SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP*9220
				SG1->G1_INI   := STOD("20050901")
				SG1->G1_FIM   := STOD("20490101")

			ElseIf (Substr(cCorte,1,3) = "BOB" .OR. Substr(cCorte,1,5) = 'FILME')  .and. (cEmpAnt ='24' .or. lCia)
				SG1->G1_QUANT := nQtdKg
				SG1->G1_INI   := STOD("20050901")
				SG1->G1_FIM   := STOD("20490101")
			Else
				SG1->G1_QUANT := (SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP)*nPesoM3
				SG1->G1_INI   := STOD("20050901")
				SG1->G1_FIM   := STOD("20050101")
			EndIf
			SG1->G1_FIXVAR  := "V"
			msunlock()
		EndIf
		//Determina indice de perda de producao sacos Ciaplast
		//5% - Extrusao, Impressao, Corte e solda
		//3% - Extrusao, Corte e Solda
		If (cEmpAnt == "24" .or. lCia) .And. Substr(cCorte,1,4) == "SACO"
			cQuery := " SELECT SG1.R_E_C_N_O_ AS RECNO, 2.91 AS PERDA "
			cQuery += "   FROM "+RetSqlName("SB1")+" SB1CORTE, "+RetSqlName("SB1")+" SB1EXTR, "+RetSqlName("SG1")+" SG1 "
			cQuery += "  WHERE SB1CORTE.D_E_L_E_T_ = ' ' "
			cQuery += "    AND SB1EXTR.D_E_L_E_T_ = ' ' "
			cQuery += "    AND SG1.D_E_L_E_T_ = ' ' "
			cQuery += "    AND SB1CORTE.B1_FILIAL = '"+xFilial("SB1")+"' "
			cQuery += "    AND SB1EXTR.B1_FILIAL = '"+xFilial("SB1")+"' "
			cQuery += "    AND SG1.G1_FILIAL = '"+xFilial("SG1")+"' "
			cQuery += "    AND SB1CORTE.B1_COD = '"+cCodEnc+"' "
			cQuery += "    AND SB1CORTE.B1_GCCUSTO = '00000003' "
			cQuery += "    AND SB1EXTR.B1_COD = '"+cCodBase+"' "
			cQuery += "    AND SB1EXTR.B1_COD = SB1CORTE.B1_XCODBAS "
			cQuery += "    AND SB1EXTR.B1_GCCUSTO = '00000001' "
			cQuery += "    AND SG1.G1_COD = SB1CORTE.B1_COD "
			cQuery += "    AND SG1.G1_COMP = SB1EXTR.B1_COD "
			cQuery += " UNION "
			cQuery += " SELECT SG1.R_E_C_N_O_, 4.76 "
			cQuery += "   FROM "+RetSqlName("SB1")+" SB1CORTE, "
			cQuery += "        "+RetSqlName("SB1")+" SB1IMP, "
			cQuery += "        "+RetSqlName("SB1")+" SB1EXTR, "
			cQuery += "        "+RetSqlName("SG1")+" SG1 "
			cQuery += "  WHERE SB1CORTE.D_E_L_E_T_ = ' ' "
			cQuery += "    AND SB1IMP.D_E_L_E_T_ = ' ' "
			cQuery += "    AND SB1EXTR.D_E_L_E_T_ = ' ' "
			cQuery += "    AND SG1.D_E_L_E_T_ = ' ' "
			cQuery += "    AND SB1CORTE.B1_FILIAL = '"+xFilial("SB1")+"' "
			cQuery += "    AND SB1IMP.B1_FILIAL = '"+xFilial("SB1")+"' "
			cQuery += "    AND SB1EXTR.B1_FILIAL = '"+xFilial("SB1")+"' "
			cQuery += "    AND SG1.G1_FILIAL = '"+xFilial("SG1")+"' "
			cQuery += "    AND SB1CORTE.B1_COD = '"+cCodEnc+"' "
			cQuery += "    AND SB1CORTE.B1_GCCUSTO = '00000003' "
			cQuery += "    AND SB1IMP.B1_COD = '"+cCodBase+"' "
			cQuery += "    AND SB1IMP.B1_COD = SB1CORTE.B1_XCODBAS "
			cQuery += "    AND SB1IMP.B1_GCCUSTO = '00000002' "
			cQuery += "    AND SB1EXTR.B1_COD = SB1IMP.B1_XCODBAS "
			cQuery += "    AND SB1EXTR.B1_GCCUSTO = '00000001' "
			cQuery += "    AND SG1.G1_COD = SB1CORTE.B1_COD "
			cQuery += "    AND SG1.G1_COMP = SB1IMP.B1_COD "
//			cQuery += "    AND SG1.G1_COD = SB1IMP.B1_COD "
//			cQuery += "    AND SG1.G1_COMP = SB1EXTR.B1_COD "


			If Select("GEREST") > 0
				GEREST->(dbCloseArea())
			EndIf
			memowrit("c:\GEREST.SQL",cQuery)
			TCQUERY cQuery ALIAS "GEREST" NEW
			If !( GEREST->(EOF()) )
				aAreaSG1 := SG1->(GetArea())
				SG1->(dbGoTo(GEREST->RECNO))
				RecLock("SG1",.F.)
				SG1->G1_PERDA := GEREST->PERDA
				MsUnLock()
				RestArea(aAreaSG1)
			EndIf
			GEREST->(dbCloseArea())
		EndIf

		lRet:=.T.
	endif
else
	dbselectarea("SB1")
	dbOrderNickName("PSB11")
	dbseek(xFilial("SB1")+cCodBase)
	if found()
		nVolBase  := SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP
		nAreaBase := SB1->B1_XLARG*SB1->B1_XCOMP
		nQB       := SB1->B1_QB
		dbselectarea("SG1")
		dbOrderNickName("PSG11")
		dbseek(xFilial("SG1")+cCodBase,.T.)
		if ALLTRIM(SG1->G1_COD) == cCodBase
			dbselectarea("SB1")
			dbseek(xFilial("SB1")+cCodEnc)
			if found() .or. (FunName()=="MATA010" .and. Inclui)
				lRet:=.T.
				if FunName()=="MATA010"
					nVolEnc       := M->B1_XALT*M->B1_XLARG*M->B1_XCOMP
					nAreaEnc      := M->B1_XLARG*M->B1_XCOMP
					M->B1_QB      := nQB
					M->B1_XCODBAS := cCodBase
				else
					nVolEnc  := SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP
					nAreaEnc := SB1->B1_XLARG*SB1->B1_XCOMP
					reclock("SB1",.F.)
					SB1->B1_QB      := nQB
					SB1->B1_XCODBAS := cCodBase
					msunlock()
				endif
				dbselectarea("SG1")
				dbOrderNickName("PSG11")
				dbseek(xFilial("SG1")+cCodBase)
				do while !eof() .and. Alltrim(SG1->G1_COD) == cCodBase
					dbselectarea("SB1")
					dbseek(xFilial("SB1")+SG1->G1_COMP)
					if found()
						// ALTERADO POR MARCELO LUIS HRUSCHKA, EM 22/08/2006
						If SB1->B1_TIPO == 'PI' .AND. SB1->B1_XVAREST == "G"
							// grava em array os campos do SB1
							_aCampos := {}
							For _nI := 1 to fCount()
								If !("B1_COD" $ FieldName(_nI))
									AADD(_aCampos,{FieldName(_nI),&(FieldName(_nI))})
								Endif
							Next
							// cria um novo codigo para o PI
							_cCompPI   := SB1->B1_COD
							_cCodigoPI := fProxPI(SB1->B1_COD)
							DbSelectArea("SB1")
							RecLock("SB1",.T.)
							For _nI := 1 To Len(_aCampos)
								FieldPut(FieldPos(_aCampos[_nI,1]),_aCampos[_nI,2])
							Next
							SB1->B1_COD := _cCodigoPI
							MsUnlock()
							MsgInfo("Codigo PI criado: " + _cCodigoPI)
							// cria nova estrutura
							_aAreaSG1 := SG1->(GetArea())
							DbSelectArea("SG1")
							dbOrderNickName("PSG11")
							DbSeek(xFilial("SG1")+_cCompPI)
							While !SG1->(EOF()) .And. SG1->G1_COD == _cCompPI
								_aCampos := {}
								For _nI := 1 To fCount()
									If !("G1_COD" $ FieldName(_nI))
										AADD(_aCampos,{FieldName(_nI),&(FieldName(_nI))})
									Endif
								Next
								_nBkpReg := SG1->(RECNO())
								// cria registro novo
								DbSelectArea("SG1")
								RecLock("SG1",.T.)
								For _nI := 1 To Len(_aCampos)
									FieldPut(FieldPos(_aCampos[_nI,1]),_aCampos[_nI,2])
								Next
								SG1->G1_COD := _cCodigoPI
								MsUnlock()
								// proximo registro
								SG1->(DbGoTo(_nBkpReg))
								SG1->(DbSkip())
							End
							// retonra area
							RestArea(_aAreaSG1)
						Else
							If SB1->B1_XVAREST == "V"
								nProp:=nVolEnc/nVolBase
							Else
								if SB1->B1_XVAREST == "A"
									nProp:=nAreaEnc/nAreaBase
								else
									nProp:=1
								endif
							Endif
							aadd(aSG1,{SB1->B1_COD,SG1->G1_TRT,SG1->G1_QUANT*nProp,SG1->G1_PERDA,SG1->G1_INI,;
							SG1->G1_FIM,SG1->G1_OBSERV,SG1->G1_FIXVAR,SG1->G1_GROPC,SG1->G1_OPC,SG1->G1_REVINI,;
							SG1->G1_REVFIM,SG1->G1_POTENCI})
						Endif
					endif
					dbselectarea("SG1")
					dbskip()
				enddo
				dbselectarea("SG1")
				dbOrderNickName("PSG11")
				dbseek(xFilial("SG1")+cCodEnc) //Apaga Estrutura anterior se houver
				do while !eof() .and. Alltrim(SG1->G1_COD) == Alltrim(cCodEnc)
					reclock("SG1",.F.)
					delete
					msunlock()
					dbskip()
				enddo
				for i:=1 to len(aSG1)
					reclock("SG1",.T.)
					SG1->G1_FILIAL  :=xFilial("SG1")
					SG1->G1_COD     := cCodEnc
					SG1->G1_COMP    := aSG1[i,01]
					SG1->G1_TRT     := aSG1[i,02]
					SG1->G1_QUANT   := aSG1[i,03]
					SG1->G1_PERDA   := aSG1[i,04]
					SG1->G1_INI     := aSG1[i,05]
					SG1->G1_FIM     := aSG1[i,06]
					SG1->G1_OBSERV  := aSG1[i,07]
					SG1->G1_FIXVAR  := aSG1[i,08]
					SG1->G1_GROPC   := aSG1[i,09]
					SG1->G1_OPC     := aSG1[i,10]
					SG1->G1_REVINI  := aSG1[i,11]
					SG1->G1_REVFIM  := aSG1[i,12]
					SG1->G1_POTENCI := aSG1[i,13]
					msunlock()
				next
			endif
		endif
	endif
endif
restarea(aArea)
Return(lRet)


*******************************************************************************
* FunÁ„o......: PrzMedio                                                      *
* Programador.: Evaldo Mufalani                                               *
* Finalidade..: Calcula o Prazo MÈdio                                         *
* UtilizaÁ„o..: Cadastro de CondiÁıes de Pagamento                            *
* Data........: 09/01/06                                                      *
*******************************************************************************
User Function PrzMedio(cParcelas, nDias)

Local nPrzMed, cPrzMed, nFor, nParc

nParc 	:= Val(cParcelas)
xPrzMed	:= nPrzMed := 0
cPrzMed	:= "000"

	For nFor := 1 to nParc
	nPrzMed += nDias
	xPrzMed += nPrzMed
	Next

cPrzMed := StrZero(xPrzMed / nParc, 3)

Return(cPrzMed)


*******************************************************************************
* FunÁ„o......: PesqVar                                                       *
* Programador.: Evaldo Mufalani                                               *
* Finalidade..: Pesquisa a variavel no Browse passada no par‚metro            *
* UtilizaÁ„o..: Gatilhos em Browse¥s                                          *
* Data........: 09/01/06                                                      *
*******************************************************************************
User Function PesqVar(cVar)

Local xCampo := ""

xCampo := aCols[ n, ASCAN(AHEADER,{|X| ALLTRIM(X[2]) == cVar  })]

Return(xCampo)


*******************************************************************************
* FunÁ„o......: PrcVenda                                                      *
* Programador.: Evaldo Mufalani                                               *
* Finalidade..: Calcular PreÁos de Vendas, Decontos e Juros de Parcelas       *
* UtilizaÁ„o..: Pedidos de Venda, RelatÛrio Tabelas de PreÁos                 *
* Data........: 09/01/06                                                      *
*******************************************************************************
* Par‚metros:                                                                 *
*     cRotina =>  F = Filho  /  C = Comercial / Industrial                    *
*******************************************************************************

//User Function PrcVenda(nTipo, cTabela, cProduto, cCliente, cQtdParc, lExibe, cRotina, cGrupoTab)
//User Function PrcVenda(nTipo, cTabela, cProduto, cCliente, cQtdParc, lExibe, cRotina, cGrupoTab, nPrzMed)
User Function PrcVenda(nTipo, cTabela, cProduto, cCliente, cQtdParc, lExibe, cRotina, cGrupoTab, nPrzMed, cTpPreco)

Local nVret := 0, nFator := 0
Local aArea := GetArea()
Local aSA1  := {}

Private nRefCom__A	:= GetMV("MV_XCOMA", .F., 1.00)
Private nRefCom__B	:= GetMV("MV_XCOMB", .F., 1.05)
Private nRefCom__C	:= GetMV("MV_XCOMC", .F., 1.10)
Private nRefCom__D	:= GetMV("MV_XCOMD", .F., 1.15)
Private nRefCom__E	:= GetMV("MV_XCOME", .F., 1.20)

Private lSegmenCom	:= .F.

/*
Valores possÌveis de nRet:
1 - PreÁo da Tabela
22 - PreÁo com Desconto
3 - PreÁo com Fator da Tabela
*/
	DBSelectArea("SB1")
	aSB1:=GetArea()
	dbOrderNickName("PSB11")
	if dbseek(xFilial("SB1")+cProduto) .and. !empty(SB1->B1_XCODBAS)
		lSobMed:=.T.
		lSegmenCom := (SB1->B1_XSEGMEN $ "261")
	else
		lSobMed:=.F.
	endif
	DBSelectArea("SA1")
	aSA1:=GetArea()
	dbOrderNickName("PSA11")
	if dbseek(xFilial("SA1")+cCliente+"01") .AND. SA1->A1_XTIPO=="4" .and. alltrim(cProduto) <> "4070955511"
		nPerLE:=GetNewPar("MV_XPERCLE",60)/100

		//if cEmpAnt $ ('07|08|09|11') .AND. nPrzMed <> NIL
		if nPrzMed <> NIL

			if nPrzMed <= 30
				cQtdParc := '1'
			elseif nPrzMed <= 45
				cQtdParc := '2'
			elseif nPrzMed <= 60
				cQtdParc := '3'
			elseif nPrzMed <= 75
				cQtdParc := '4'
			elseif nPrzMed <= 90
				cQtdParc := '5'
			elseif nPrzMed <= 105
				cQtdParc := '6'
			elseif nPrzMed <= 120
				cQtdParc := '7'
			elseif nPrzMed <= 135
				cQtdParc := '8'
			elseif nPrzMed <= 150
				cQtdParc := '9'
			elseif nPrzMed <= 165
				cQtdParc := '10'
			elseif nPrzMed <= 180
				cQtdParc := '11'
			elseif nPrzMed <= 195
				cQtdParc := '12'
			elseif nPrzMed <= 210
				cQtdParc := '13'
			elseif nPrzMed <= 225
				cQtdParc := '14'
			elseif nPrzMed <= 240
				cQtdParc := '15'
			elseif nPrzMed <= 255
				cQtdParc := '16'
			elseif nPrzMed <= 270
				cQtdParc := '17'
			elseif nPrzMed <= 285
				cQtdParc := '18'
			elseif nPrzMed <= 300
				cQtdParc := '19'
			endif

			cQtdParc := strzero(val(cQtdParc),3)
		endif

	else
		nPerLE:=1
	endif

	If FunName() = "IMPSC5"
		Return(nVret)
	EndIf

	if cGrupoTab==Nil
		cGrupoTab:="0"
	endif

	if val(cQtdParc) = 0
		cQtdParc := "1"
	endif

//TRATAMENTO PARA UNIDADE 22
	lCestaBasica := .F.
	IF  cEmpAnt = "22" .AND. substr(cProduto,1,6) == "001313" //CODIGO DO PRODUTO COME«ANDO POR 001313
		lCestaBasica := .T.
		nVret := 1
	ELSEIF cEmpAnt = "22" .AND. substr(cProduto,1,6) == "000777" //CODIGO DO PRODUTO COME«ANDO POR 000777
		lCestaBasica := .T.
		nVret := 1
	ENDIF

//Tratameento para operaÁ„o 25
	If FunName() = "MATA410"
		lCestaBasica := .F.
		IF  M->C5_XOPER = "25" .AND. substr(cProduto,1,1) == "0" //CODIGO DO PRODUTO COME«ANDO POR 001313
			lCestaBasica := .T.
			nVret := 1
		ENDIF
	EndIf

	if cGrupoTab= "0"  .OR. lCestaBasica
		if !lCestaBasica
			dbSelectArea("DA1")
			dbOrderNickName("CDA14")
			If !dbSeek(xFilial("DA1") + cTabela + cProduto) .or. DA1->DA1_PRCVEN <= 0
				If lExibe = Nil .Or. lExibe
					if cEmpAnt <> "22"
						MsgBox("Produto com preÁo de venda igual a zero.","ATEN«√O!","INFO")
					endif
				EndIf
				nVret := 0
			Else
				nVret := DA1->DA1_PRCVEN
			Endif
		endif
	else
		dbSelectArea("ACP")
		dbOrderNickName("CACP3")
		If !dbSeek(xFilial("ACP") + "00"+cTabela+alltrim(cGrupoTab)+cProduto) //.or. (ACP->ACP_XPRECO > 0 .and. ACP->ACP_PERDES > 0)
		/*
		dbSelectArea("DA1")
		dbOrderNickName("CDA14")
			If !dbSeek(xFilial("DA1") + cTabela + cProduto) .or. DA1->DA1_PRCVEN <= 0
				If lExibe = Nil .Or. lExibe
					if cEmpAnt <> "22"
		MsgBox("Produto com preÁo de venda igual a zero.","ATEN«√O!","INFO")
					endif
				EndIf
		nVret := 0
			Else
		nVret := DA1->DA1_PRCVEN
			Endif
		*/ // Retirado por Dupim em 28/09/2010 se produto nao estiver na referancia sera
			if lSobMed
				dbSelectArea("DA1")
				dbOrderNickName("CDA14")
				If !dbSeek(xFilial("DA1") + cTabela + cProduto) .or. DA1->DA1_PRCVEN <= 0
					If lExibe = Nil .Or. lExibe
						if cEmpAnt <> "22"
							MsgBox("Produto com preÁo de venda igual a zero.","ATEN«√O!","INFO")
						endif
					EndIf
					nVret := 0
				Else
					nVret := DA1->DA1_PRCVEN
					If lSegmenCom
						if cGrupoTab $ "AF"
							nVret:=round(nVret*nRefCom__A,2)
						elseif cGrupoTab $ "BG"
							nVret:=round(nVret*nRefCom__B,2)
						elseif cGrupoTab $ "CH"
							nVret:=round(nVret*nRefCom__C,2)
						elseif cGrupoTab $ "DI"
							nVret:=round(nVret*nRefCom__D,2)
						elseif cGrupoTab $ "EJ"
							nVret:=round(nVret*nRefCom__E,2)
						endif
					Else
						if cGrupoTab $ "BG"
							nVret:=round(nVret*1.05,2)
						elseif cGrupoTab $ "CH"
							nVret:=round(nVret*1.10,2)
						elseif cGrupoTab $ "DI"
							nVret:=round(nVret*1.15,2)
						elseif cGrupoTab $ "EJ"
							nVret:=round(nVret*1.20,2)
						endif
					EndIf
				Endif
			ElseIf Type("M->C5_XOPER") == "C" .And. M->C5_XOPER == "13"
				dbSelectArea("DA1")
				dbOrderNickName("CDA14")
				If !dbSeek(xFilial("DA1") + cTabela + cProduto) .or. DA1->DA1_PRCVEN <= 0
					MsgBox("Produto ["+Alltrim(cProduto)+"] nao possui preco de venda nessa referencia ["+cTabela+"]","ATEN«√O!","INFO")
					nVret	:= 0
				Else
					nVret	:= DA1->DA1_PRCVEN
				EndIf
			else
				If lExibe = Nil .Or. lExibe
					If cEmpAnt == "21"
						nVRet:=0
						If Left(cProduto,3) == "000"
							If SB1->B1_XPRCRU == 0
								MsgBox("Produto n„o possui preÁo informado.","ATEN«√O!","INFO")
							Else
								nVRet:=SB1->B1_XPRCRU
							EndIf
						EndIf
					Else
						MsgBox("Produto ["+Alltrim(cProduto)+"] nao possui preco de venda nessa referencia ["+cTabela+"]","ATEN«√O!","INFO")
						nVret := 0
					EndIf
				EndIf
			endif
		else
			if ACP->ACP_XPRECO > 0
				nVRet:=ACP->ACP_XPRECO
			else
				//			If ACP->ACP_PERDES > 0
				//				nVret := nVret  *  ACP->ACP_PERDES
				//			else
				If lExibe = Nil .Or. lExibe
					if cEmpAnt <> "22"
						MsgBox("Produto com preÁo de venda igual a zero.","ATEN«√O!","INFO")
					EndIf
				EndIf
				//			Endif
			endif
		Endif
	endif


	If nTipo > 2 .And. nVret > 0 //.AND. nPerLe = 1

		// Aplica fator baseado no fator de PROMOCAO
		//	if val(cGrupoTab) > 2 //Inclus„o de emergecia
		//TRATAMENTO PARA  FATOR
		dbSelectArea("SZ9")
		dbOrderNickName("CSZ91")
		//	If dbSeek( xFilial("SZ9")+padr(cProduto,15)+ctabela )
		If dbSeek( xFilial("SZ9")+padr(cProduto,15)) //Alterado por Luciano em 17/10/12
			// GLM: George: SSI: 22417: 27/09/2012
			// Inclusao da critica de liberacao de produtos de comercializacao especial
			//		If Empty(SZ9->Z9_DTVAL) .Or. SZ9->Z9_DTVAL < dDataBase  // valida se data informada menor que data base
			//Aviso("Atencao","Produto de comercializacao especial nao liberado. Desconto nao podera ser concedido!", {"Ok"} )
			//nVret := 0
			//		Else
			//			If Val(SZ9->Z9_CONDPAG) >= Val(cQtdParc) .And. SZ9->Z9_VALIDAD >= dDatabase .and. alltrim(cGrupoTab)$SZ9->Z9_REFTAB
			If !Empty(SZ9->Z9_DTVAL) .and. SZ9->Z9_DTVAL >= dDataBase  // valida se data informada menor que data base
				If Val(SZ9->Z9_CONDPAG) >= Val(cQtdParc) .And. SZ9->Z9_DTVAL >= dDatabase .and. alltrim(cGrupoTab)$SZ9->Z9_REFTAB
					nFator := 1//SZ9->Z9_FATOR Retirado por dupim em 18/05/11 pra ver no que da... o desconto tem que vir da tabela
					If nFator <> 0
						nVret := ROUND(ROUND(nVret * nFator,4)/Val(cQtdParc),4)*Val(cQtdParc)
					Endif
				Endif
			EndIf
		else
			dbgotop()
			//		If dbSeek( xFilial("SZ9")+padr(cProduto,15)+"   ")
			If dbSeek( xFilial("SZ9")+padr(cProduto,15)) //Alterado por Luciano em 17/10/12
				// GLM: George: SSI: 22417: 27/09/2012
				// Inclusao da critica de liberacao de produtos de comercializacao especial
				//			If Empty(SZ9->Z9_DTVAL) .Or. SZ9->Z9_DTVAL < dDataBase  // valida se data informada menor que data base
				//				Aviso("Atencao","Produto de comercializacao especial nao liberado. Desconto nao podera ser concedido!", {"Ok"} )
				//				nVret := 0
				//			Else
				//				If Val(SZ9->Z9_CONDPAG) >= Val(cQtdParc) .And. SZ9->Z9_VALIDAD >= dDatabase .and. alltrim(cGrupoTab)$SZ9->Z9_REFTAB
				If !Empty(SZ9->Z9_DTVAL) .and. SZ9->Z9_DTVAL >= dDataBase  // valida se data informada menor que data base
					If Val(SZ9->Z9_CONDPAG) >= Val(cQtdParc) .And. SZ9->Z9_DTVAL >= dDatabase .and. alltrim(cGrupoTab)$SZ9->Z9_REFTAB
						nFator := 1//SZ9->Z9_FATOR Retirado por dupim em 18/05/11 pra ver no que da... o desconto tem que vir da tabela
						If nFator <> 0
							nVret := ROUND(ROUND(nVret * nFator,4)/Val(cQtdParc),4)*Val(cQtdParc)
						Endif
					Endif
				EndIf
			ENDIF
		Endif

		If nFator == 0
			dbSelectArea("SE4")
			dbOrderNickName("PSE41")
			if dbSeek(xFilial("SE4")+cQtdParc)
				If cRotina == "C"
					nFator := SE4->E4_XVARCOM
				Else
					//Se rotina for digitaÁ„o de Pedido Filho e produto for terceirizado nao calcula juros. Bruno 10/08/2009
					//Retirado por dupim em 12/12/11 em conversa com Seixas
					//if cRotina == "L" .and. Substr(cProduto,1,6) == "407095"
					//	nFator := 0
					//else
					if !empty(SE4->E4_XTABANT) .and. !empty(SE4->E4_XANOANT) .and. cTabela < SE4->E4_XTABANT .and. year(date()) == val(SE4->E4_XANOANT)
						nFator := SE4->E4_XVARANT
					else
						nFator := SE4->E4_XVARPAR
					endif
					//endif
				EndIf

				If nFator <> 0
					nVret := ROUND(ROUND(ROUND(nVret * nFator,4)/Val(cQtdParc),4)*Val(cQtdParc),2)
				Endif
			Endif
		endif
	endif
	nVret*=nPerLe
/*
	IF nPerLE <> 1
nVRet*=nPerLE
		IF nPrzMed <> NIL .and. nPrzMed > 1

			if (cEmpAnt<>"07" .and. cEmpAnt<>"11" .and. cEmpAnt<>"08" .and. cEmpAnt <> "09") .or. nPrzMed>165 .or. cTabela > "047" .or. dtos(dDataBase)>"20111231"  //Feito por dupim em 23/09/10 odeio isso mas e ordem do Sr. Alcindo
dbSelectArea("SZ9")
dbOrderNickName("CSZ91")
				If dbSeek( xFilial("SZ9")+padr(cProduto,15)+ctabela )
					If Val(SZ9->Z9_CONDPAG) >= Val(cQtdParc) .And. SZ9->Z9_VALIDAD >= dDatabase .and. alltrim(cGrupoTab)$SZ9->Z9_REFTAB
nFator := SZ9->Z9_FATOR
						If nFator <> 0
nVret := ROUND(ROUND(nVret * nFator,4)/Val(cQtdParc),4)*Val(cQtdParc)
						Endif
					Endif
				else
dbgotop()
					If dbSeek( xFilial("SZ9")+padr(cProduto,15)+"   ")

						If Val(SZ9->Z9_CONDPAG) >= Val(cQtdParc) .And. SZ9->Z9_VALIDAD >= dDatabase .and. alltrim(cGrupoTab)$SZ9->Z9_REFTAB
nFator := SZ9->Z9_FATOR
							If nFator <> 0
nVret := ROUND(ROUND(nVret * nFator,4)/Val(cQtdParc),4)*Val(cQtdParc)
							Endif
						Endif
					else
						if nPrzMed>=105
nVret*=1+((nPrzMed*(2.25/30))/100)
						else
nVret*=1+((nPrzMed*(1.75/30))/100)
						endif
					ENDIF
				Endif
			Endif
		ENDIF
	ENDIF
*/
	RestArea(aArea)
Return(nVret)


	********************************************
	* Funcao: fCalCusto()                      *
	*         Calcula custo do produto atraves *
	*         da estrutura.                    *
	********************************************

User Function fCalCusto(cProduto)

	Local cAreaAtu := GetArea()
	Local nCusto   := 0

// Busca estrutura do produto, calcula o custo de cada item e
// grava no SB1

	cQuerySG1 := "SELECT G1_COD, G1_COMP, G1_QUANT, B1_CUSTD, (g1_quant * b1_custd) Total"
	cQuerySG1 += "       FROM " + RetSqlName("SG1") + " SG1, " + RetSqlName("SB1") + " SB1"
	cQuerySG1 += "       WHERE SG1.D_E_L_E_T_ <> '*'"
	cQuerySG1 += "             AND SB1.D_E_L_E_T_ <> '*'"
	cQuerySG1 += "             AND SG1.G1_COD = '" + cProduto + "'"
	cQuerySG1 += "             AND SB1.B1_COD = SG1.G1_COMP"
	cQuerySG1 += "       ORDER BY G1_COMP"

	TcQuery cQuerySG1 ALIAS "TMPSG1" NEW

	TcSetField("TMPSG1","G1_QUANT","N",12,6)
	TcSetField("TMPSG1","B1_CUSTD","N",12,2)
	TcSetField("TMPSG1","TOTAL"   ,"N",12,2)

	dbGoTop()

	While !Eof()
		nCusto += TMPSG1->TOTAL
		dbSkip()
	EndDo

	TMPSG1->(dbCloseArea())

	If nCusto <> 0
		dbSelectArea("SB1")
		// Grava Custo acrescido de 15%
		If dbSeek(xFilial("SB1") + cProduto)
			RecLock("SB1",.F.)
			Replace SB1->B1_CUSTD with nCusto * 1.15
			MsUnLock()
		Endif
	Endif

	RestArea(cAreaAtu)
Return(nCusto)

	*-----------------------------------------------------------------------------*
	* FunÁ„o......: Ort18Calc()                                                   *
	* Programador.: Vanessa Herrmann                                              *
	* Finalidade..: Ajusta valor pago em cheque e cart„o de crÈdito dos consumido *
	*               res finais                                                    *
	* Data........: 08/02/06                                                      *
	******************************************************************************
	*------------------------------------------------*
User Function Ort18Calc(cCNPJ,nValor, nNum, cTipo)
	*------------------------------------------------*
	Local aArea:= GetArea()

	DbSelectArea("SZD")
	dbOrderNickName("CSZD1")
	If DbSeek(xFilial("SZD")+cCNPJ)
		RecLock("SZD",.F.)
		If cTipo = 'CH'
			SZD->ZD_VLCHQ  += nValor
			SZD->ZD_NUMCHQ += nNum
		ElseIf cTipo = 'CC'
			SZD->ZD_VLCC   += nValor
			SZD->ZD_NUMCC  += nNum
		EndIf
	Else
		RecLock("SZD",.T.)
		SZD->ZD_FILIAL := xFilial("SZD")
		SZD->ZD_CGC := cCNPJ
		If cTipo = 'CH'
			SZD->ZD_VLCHQ  := nValor
			SZD->ZD_NUMCHQ := nNum
		ElseIf cTipo = 'CC'
			SZD->ZD_VLCC   := nValor
			SZD->ZD_NUMCC  := nNum
		EndIf
	EndIf
	MsUnLock()

	RestArea(aArea)
Return

	*-----------------------------------------------------------------------------*
	* FunÁ„o......: CalcPrzMed()                                                  *
	* Programador.: Cesar Dupim                                                   *
	* Finalidade..: Calcula o prazo MÈdio para a condiÁ„o de pagamento passada via*
	*               par‚metro             					      *
	* Data........: 23/03/06                                                      *
	*-----------------------------------------------------------------------------*
	*-------------------------------------*
User Function CalcPrzMed(ConPag)
	*-------------------------------------*
	Local aArea   := GetArea()
	Local aCond   := {}
	Local nPrzMed := 0
	Local cPrazo  := "001"       // Evaldo: 23/03/2006 13:11h
	Local i       := 0

	aCond:=condicao(1000,ConPag,0,dDatabase,0)

	for i:=1 to Len(aCond)
		nPrzMed += (aCond[i,1] - dDataBase)
	next
	if nPrzMed > 0
		nPrzMed /= Len(aCond)
		//else  //Dupim dia 17/10/06
		//	nPrzMed:=1
	endif
	if nPrzMed > 999
		MsgBox("Condicao de Pagamento Invalida")
		cPrazo:="   "
	else
		cPrazo := StrZero(nPrzMed, 3)
	endif
	RestArea(aArea)

Return(cPrazo)



	*-----------------------------------------------------------------------------*
	* FunÁ„o......: fPrazoM()                                                     *
	* Programador.: Vanessa Herrmann                                              *
	* Finalidade..: Calcula o valor do Prazo MÈdio utilizando o n˙mero de parcelas*
	*               e o total financiado.  										  *
	*               Vari·vel lFlag = Com(.T.)/Sem(.F.) Entrada                    *
	* Data........: 15/02/06                                                      *
	*-----------------------------------------------------------------------------*
	*-------------------------------------*
User Function fPrazoM(nParc,nTot,lFlag)
	*-------------------------------------*
	Local nPrazo := 0
	Local nInic  := Iif(lFlag,0,1)
	Local nfim   := Iif(lFlag,nParc-1,nParc)
	Local j
	If nParc = 0
		nPrazo := 0
	Else
		For J:= nInic to nFim
			nPrazo += (30 * J)
		Next
		nPrazo := (nPrazo / nParc) * nTot
	EndIf

Return(nPrazo)

	***************************************************************************************
	* Programa....: FMIX                                                              	  *
	* Autor.......: Cesar Dupim                                                           *
	* Objetivo    : Calculo do Mix. Se invalido retorna 0                                 *
	* Data........: 06/04/2006                                                            *
	***************************************************************************************
	* Revisıes....:                                                                       *
	* Motivo......:                                                                       *
	* Data........:                                                                       *
	***************************************************************************************
User Function FMIX(nPV,nPC)
	Local nRet:=0
	if nPV > nPC
		nRet:=round(((nPV-NPC)/nPv)*100,2)
		if nRet > 99.99
			nRet:=0
		endif
	endif
Return(nRet)

	***************************************************************************************
	* Programa....: FMKP                                                              	  *
	* Autor.......: Evaldo Mufalani                                                       *
	* Objetivo    : Calculo do Markup / MarcaÁ„o. Se invalido retorna 0                   *
	* Data........: 11/04/2006                                                            *
	***************************************************************************************
	* Revisıes....:                                                                       *
	* Motivo......:                                                                       *
	* Data........:                                                                       *
	***************************************************************************************
	* Par‚metros:                                                                         *
	*    xPRT => Preco de Tabela                                                          *
	*    xPRC => Preco de Custo                                                           *
	***************************************************************************************

User Function FMKP(nPRT, nPRC )

	Local nRet := 0

	If nPRT > 0

		nRet := round( nPRT / nPRC, 2)

		If nRet > 9.99
			nRet := 0
		endif

	Endif

Return(nRet)


	***************************************************************************************
	* Programa....: PROXTIT                                                            	  *
	* Autor.......: Cleverson Luiz Schaefer                                               *
	* Objetivo    : Busca de proximo numero para geracao de titulos a receber.            *
	* Data........: 18/04/2006                                                            *
	***************************************************************************************
	* Revisıes....:                                                                       *
	* Motivo......:                                                                       *
	* Data........:                                                                       *
	***************************************************************************************
	* Par‚metros:                                                                         *
	***************************************************************************************

User Function PROXTIT()
	Local aArea:=GetArea()
	Local aSe1 :={}
	Local cNumTit:=GetMV("MV_XNUMTIT")
	if Len(alltrim(cNumTit))<12
		cNumTit:="000000000001"
	endif
	dbselectarea("SE1")
	aSe1:=GetArea()
	dbsetorder(1)
	dbseek(xFilial("SE1")+cNumTit)
	do while SE1->E1_PREFIXO+SE1->E1_NUM == cNumtit
		dbskip()
		cNumTit:=soma1(cNumTit,12)
	enddo
	PutMv("MV_XNUMTIT",soma1(cNumTit))
	restarea(aSe1)
	restarea(aArea)
Return(cNumTit)
	**************************************
User Function FMarks( PMv, PConsul)
	**************************************

	Local oAll       := ""
	Local lAll       := .T.
	Local oListMnu   := ""
	Private A_VetTmp := {}

	&PMv      := ""
	cQueryTMP := ""

	If PConsul != "FPG" .AND. PConsul != "TES" .AND. PConsul != "TOPER" .AND. PConsul != "SEGM" .AND. PConsul != "UNID"
		Alert("Este tipo de consulta n„o est· preparada")
		Return()
	Endif

	If PConsul == "FPG"  // SeleÁ„o por Formas de Pagamento

		V_Sx5     := RETSQLNAME("SX5")
		cQueryTMP   = "SELECT "
		cQueryTMP  += " X5_FILIAL, X5_CHAVE, X5_TABELA, X5_DESCRI "

		cQueryTMP  += " FROM "+V_SX5

		cQueryTMP  += " WHERE X5_FILIAL  =  '" +XFILIAL("SX5") +"' AND "
		cQueryTMP  += "       X5_TABELA  =  'Z4' AND "
		cQueryTMP  += "       X5_CHAVE   BETWEEN '01' AND '99' AND "
		cQueryTMP  += "       D_E_L_E_T_ <> '*' "
		cQueryTMP  += " ORDER BY X5_CHAVE"

	ElseIf PConsul == "TOPER"  // SeleÁ„o por Tipos de OperaÁıes

		V_Sx5     := RETSQLNAME("SX5")
		cQueryTMP   = "SELECT "
		cQueryTMP  += " X5_FILIAL, X5_CHAVE, X5_TABELA, X5_DESCRI "

		cQueryTMP  += " FROM "+V_SX5

		cQueryTMP  += " WHERE X5_FILIAL  =  '" +XFILIAL("SX5") +"' AND "
		cQueryTMP  += "       X5_TABELA  =  'DJ' AND "
		cQueryTMP  += "       X5_CHAVE   BETWEEN '01' AND '99' AND "
		cQueryTMP  += "       D_E_L_E_T_ <> '*' "
		cQueryTMP  += " ORDER BY X5_CHAVE"

	ElseIf PConsul == "TES"
		V_Sf4     := RETSQLNAME("SF4")
		cQueryTMP   = "SELECT "
		cQueryTMP  += " F4_FILIAL, F4_CODIGO, F4_TEXTO, F4_BLOQ, F4_GENERIC"
		cQueryTMP  += " FROM "+V_SF4
		cQueryTMP  += " WHERE F4_FILIAL  =  '" +XFILIAL("SF4") +"' AND "
		cQueryTMP  += "       F4_CODIGO  >  '500' AND F4_BLOQ <> 'S' AND "
		cQueryTMP  += "       D_E_L_E_T_ <> '*' "
		cQueryTMP  += " ORDER BY F4_CODIGO"

	ElseIf PConsul == "SEGM"
		V_SZA     := RETSQLNAME("SZA")
		cQueryTMP   = "SELECT "
		cQueryTMP  += " ZA_FILIAL, ZA_CODIGO, ZA_DESC"
		cQueryTMP  += " FROM "+V_SZA
		cQueryTMP  += " WHERE ZA_FILIAL  =  '" +XFILIAL("SZA") +"' AND "
		cQueryTMP  += "       D_E_L_E_T_ <> '*' "
		cQueryTMP  += " ORDER BY ZA_CODIGO"

	ElseIf PConsul == "UNID"  // SeleÁ„o de Unidades



	Else
		Return()
	Endif

	if PConsul <> "UNID"

		TCQuery cQueryTMP ALIAS "TRBTMP" New

		DbSelectArea("TRBTMP")
		ProcRegua(Lastrec())
		DbGotop()

		Do While !Eof()

			If PConsul == "FPG" .Or. PConsul == "TES" .Or. PConsul == "TOPER" .Or. PConsul == "SEGM"

				If PConsul == "FPG"
					Aadd(A_VetTmp,{.T.,;
						TRBTMP->X5_DESCRI,;
						""               ,;
						00               ,;
						TRBTMP->X5_CHAVE})

				ElseIf PConsul == "TOPER"
					Aadd(A_VetTmp,{.T.,;
						TRBTMP->X5_DESCRI,;
						""               ,;
						00               ,;
						TRBTMP->X5_CHAVE})

				ElseIf PConsul == "TES"
					Aadd(A_VetTmp,{.T.,;
						TRBTMP->F4_TEXTO+''+TRBTMP->F4_GENERIC,;
						""               ,;
						00               ,;
						TRBTMP->F4_CODIGO})

				ElseIf PConsul == "SEGM"
					Aadd(A_VetTmp,{.T.,;
						TRBTMP->ZA_DESC,;
						""               ,;
						00               ,;
						TRBTMP->ZA_CODIGO})
				Endif

			Endif

			DbSelectArea("TRBTMP")
			DbSkip()

		Enddo

	else

		Aadd(A_VetTmp,{.T.,"02","",00,""})
		Aadd(A_VetTmp,{.T.,"03","",00,""})
		Aadd(A_VetTmp,{.T.,"04","",00,""})
		Aadd(A_VetTmp,{.T.,"05","",00,""})
		Aadd(A_VetTmp,{.T.,"06","",00,""})
		Aadd(A_VetTmp,{.T.,"07","",00,""})
		Aadd(A_VetTmp,{.T.,"08","",00,""})
		Aadd(A_VetTmp,{.T.,"09","",00,""})
		Aadd(A_VetTmp,{.T.,"10","",00,""})
		Aadd(A_VetTmp,{.T.,"11","",00,""})
		Aadd(A_VetTmp,{.T.,"15","",00,""})
		Aadd(A_VetTmp,{.T.,"22","",00,""})
		Aadd(A_VetTmp,{.T.,"23","",00,""})
		Aadd(A_VetTmp,{.T.,"24","",00,""})
		Aadd(A_VetTmp,{.T.,"26","",00,""})

	endif

	If Len(A_VetTmp) = 0
		Alert("Arquivo para este tipo de consulta est· vazio.")
		DbSelectArea("TRBTMP")
		DbCloseArea()
		Return .t.
	Endif

	oDlgList := ""
	oOk      := LoadBitmap(GetResources(), "LBOK")
	oNo      := LoadBitmap(GetResources(), "LBNO")
	bLine    := {|| {If(A_VetTmp[oListMnu:nAt,1],oOk,oNo), A_VetTmp[oListMnu:nAt,2], A_VetTmp[oListMnu:nAt,5]}}

	If PConsul == "FPG"
		V_TitTela := "Selecione as Formas de Pagamento"
	ElseIf PConsul == "TOPER"
		V_TitTela := "Selecione as Tipos de OperaÁıes"
	ElseIf PConsul == "TES"
		V_TitTela := "Selecione os TES"
	ElseIf PConsul == "SEGM"
		V_TitTela := "Selecione os Segmentos"
	ElseIf PConsul == "UNID"
		V_TitTela := "Selecione as Unidades"
	Endif

	DEFINE MSDIALOG oDlgList TITLE V_TitTela FROM 0,0 TO 245,410 OF oMainWnd PIXEL

	@ 05,05 LISTBOX oListMnu FIELDS HEADER "","Descricao","Codigo" FIELDSIZES 14, 100,50 SIZE 160, 102 PIXEL OF oDlgList

	oListMnu:SetArray(A_VetTmp)
	oListMnu:bLine := bLine
	oListMnu:bLDblClick := {|nRowPix, nColPix, nKeyFlags| ValSelection(@A_VetTmp,oListMnu),oListMnu:Refresh(),;
		IIf(lAll,(lAll := .F., oAll:Refresh()),)}

	@110,06 CHECKBOX oAll VAR lAll PROMPT "Todos os Itens" FONT oDlgList:oFont PIXEL SIZE 80, 09 OF oDlgList ;
		ON CLICK (Aeval(A_VetTmp,{|x,y| A_VetTmp[y][1] := If(A_VetTmp[y][4] == 99,.F.,lAll)}), oListMnu:Refresh())

	DEFINE SBUTTON FROM 05,170 TYPE 1 ENABLE OF oDlgList;
		ACTION (FGeraStr(PMv),oDlgList:End())

	DEFINE SBUTTON FROM 20,170 TYPE 2 ENABLE OF oDlgList ACTION oDlgList:End()

	DEFINE SBUTTON FROM 35,170 TYPE 15 ENABLE OF oDlgList ACTION FindMenu(@oListMnu,A_VetTmp) ONSTOP OemToAnsi("Localizar")

	ACTIVATE DIALOG oDlgList CENTERED

	If Select("TRBTMP") > 0
		DbSelectArea("TRBTMP")
		DbCloseArea()
	endif

Return()

	*****************************
// Complemento de FMARKS
Static Function FGeraStr(PMv)
	*****************************
	Local V_Tmp1
	V_TmpStr := ""

	For V_Tmp1 := 1 to Len(A_VetTmp)

		If A_VetTmp[V_Tmp1,1] == .T.

			If V_Tmp1 < Len(A_VetTmp)
				// V_TmpStr := V_TmpStr + "'"+Alltrim(A_VetTmp[V_Tmp1,5])+"'" + ","
				V_TmpStr := V_TmpStr + Alltrim(A_VetTmp[V_Tmp1,5]) + ","
			Else
				// V_TmpStr := V_TmpStr + "'" + Alltrim(A_VetTmp[V_Tmp1,5]) + "'"
				V_TmpStr := V_TmpStr + Alltrim(A_VetTmp[V_Tmp1,5])
			Endif
		Endif

	Next

	V_TmpStr := Alltrim( V_TmpStr )
/*
//Verifica se o Primeiro Caracter È "'"
	If !Empty( V_TmpStr ) .And. Left( V_TmpStr, 1 ) != "'"
V_TmpStr	:= "'" + V_TmpStr
	EndIf
*/

//Verifica se o ultimo caracter È ","
	If !Empty( V_TmpStr ) .And. Right( V_TmpStr, 1 ) == ","
		V_TmpStr	:= Left( V_TmpStr, Len(V_TmpStr) -1 )
	EndIf
/*
//Verifica se o ˙ltimo Pics("'") foi colocado
	If !Empty( V_TmpStr ) .And. Right( V_TmpStr, 1 ) != "'"
V_TmpStr += "'"
	EndIf
*/

	&PMv := Alltrim(V_TmpStr)

Return()

	************************************************
// Complemento de FMARKS
Static Function ValSelection(A_VetTmp,oListMnu)
	************************************************

	Local i
	Local nAt := oListMnu:nAt

	A_VetTmp[nAt,1] := !A_VetTmp[nAt,1]

	If (A_VetTmp[nAt,4] == 99)
		If A_VetTmp[nAt,1]
			For i := 1 To Len(A_VetTmp)
				If i <> nAt
					A_VetTmp[i,1] := .F.
				EndIf
			Next
		EndIf
	Else
		If (i := Ascan(A_VetTmp,{|x| x[4] == 99})) <> 0
			A_VetTmp[i,1] := .F.
		EndIf
	EndIf

Return()

	********************************************
// Complemento de FMARKS
Static Function FindMenu(oListMnu,A_VetTmp)
	********************************************
	Local oDlgSeek
	Local cSeek := Space(20)
	Local lCase := .F.
	Local lWord := .F.
	Local nPos := oListMnu:nAt
	Local aSeek := {}

	Aeval(A_VetTmp,{|x,y| Aadd(aSeek,x[2])})

	DEFINE MSDIALOG oDlgSeek FROM 00,00 TO 105,370 TITLE OemtoAnsi("Pesquisa") PIXEL

	@07,02 SAY OemToAnsi("Pesquisar")+":" OF oDlgSeek PIXEL //"Pesquisar"
	@05,30 GET cSeek OF oDlgSeek PIXEL SIZE 100,9

	@20,02 TO 51,130 LABEL OemtoAnsi("OpÁıes") PIXEL OF oDlgSeek
	@27,05 CHECKBOX lCase PROMPT OemtoAnsi("Coincidir mai˙sc./min˙sc")   FONT oDlgSeek:oFont PIXEL SIZE 80,09
	@38,05 CHECKBOX lWord PROMPT OemtoAnsi("Localizar palavra &inteira") FONT oDlgSeek:oFont PIXEL SIZE 80,09 //"Localizar palavra &inteira"

	@05,135 BUTTON OemtoAnsi("&PrÛximo") PIXEL OF oDlgSeek SIZE 44,11; //"&PrÛximo"
	ACTION (nPos := FastSeek(cSeek,nPos,aSeek,lCase,lWord),oListMnu:nAt := nPos,oListMnu:Refresh())

	@18,135 BUTTON OemtoAnsi("&Cancelar") PIXEL ACTION oDlgSeek:End() OF oDlgSeek SIZE 44,11 //"&Cancelar"

	ACTIVATE MSDIALOG oDlgSeek CENTERED

Return()

	***********************************************************
// Complemento de FMARKS
Static Function FastSeek(cGet,nLastSeek,aArray,lCase,lWord)
	***********************************************************

	Local nSearch := 0
	Local bSearch

	cGet := Trim(cGet)

	If ( lCase .And. lWord )
		bSearch := {|x| Trim(x) == cGet}
	ElseIf ( !lCase .And. !lWord )
		bSearch := {|x| Trim(Upper(SubStr(x,1,Len(cGet)))) == Upper(cGet)}
	ElseIf ( lCase .And. !lWord )
		bSearch := {|x| Trim(SubStr(x,1,Len(cGet))) == cGet}
	ElseIf ( !lCase .And. lWord )
		bSearch := {|x| Trim(Upper(x)) == Upper(cGet)}
	EndIf

	nSearch := Ascan(aArray,bSearch,nLastSeek+1)
	If ( nSearch == 0 )
		nSearch := Ascan(aArray,bSearch)
		If ( nSearch == 0 )
			nSearch := nLastSeek
		EndIf
	EndIf
Return nSearch

///////////////////////////////////////////////////////
// Marcelo Luis Hruschka
// 22/08/2006 - busca numero do proximo PI
Static Function fProxPI(_cCodigo)
// declaracao de variaveis
	Local _aArea    := GetArea()
	Local _aAreaSB1 := SB1->(GetArea())
	Local _cRet     := AllTrim(_cCodigo)
// busca se codigo existe, e busca um codigo que ainda nao exista para nova estrutura
	DbSelectArea("SB1")
	dbOrderNickName("PSB11")
	While DbSeek(xFilial("SB1")+_cRet)
		_cRet := Soma1(_cRet)
	End
// retorna
	RestArea(_aAreaSB1)
	RestArea(_aArea)
Return(_cRet)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function rfRecCount(_cAlias)
	Local _nRet := 0
	DbSelectArea(_cAlias)
	DbGoTop()
	While !EOF()
		_nRet++
		DbSkip()
	End
	DbGoTop()
Return(_nRet)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	*-----------------------*
User Function fUltDepr()
	*-----------------------*
	Local aArea := GetArea()

// PutMV("MV_ULTDEPR",dDatabase-1) // Alterado por solicitaÁ„o do Gabriel

	RestArea(aArea)
Return
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

User Function PosAC8(Codigo)
	Local aArea := GetArea()
	DbSelectArea("AC8")
	dbOrderNickName("PAC82")
	DbSeek(xFilial("AC8")+"SA1"+xFilial("SU5")+Codigo)

	_cChave := AC8->AC8_CODCON

	DbSelectArea("SU5")
	dbOrderNickName("PSU51")
	DbSeek(xFilial("SU5")+_cChave)
	_Retorno := SU5->U5_CONTAT
	M->ZO_ANIVCLI := SU5->U5_NIVER
	M->ZO_TELCLI := SA1->A1_DDD + " " + SA1->A1_TEL
	RestArea(aArea)
Return(_Retorno)




	***************************************************************************************
	* Programa....: fValCMC7                                                          	  *
	* Autor.......: Cleverson Luiz Schaefer                                               *
	* Objetivo    : Validar o CMC7 do cheque digitado.                                    *
	* Data........: 09/10/2006                                                            *
	***************************************************************************************
	* Revisıes....:                                                                       *
	* Motivo......:                                                                       *
	* Data........:                                                                       *
	***************************************************************************************

User Function fValCMC7(cCmc7)
	*****************************
	Local ni
	Private  vRetorno := .F.
	Private  vCalculo := 0
	Private  vTotal   := 0
	Private  pCmc7  := Alltrim(cCmc7)
	Private  vPos2  := vPos3  := vPos4  := vPos5  := vPos6  := vPos7  := vPos8  := vPos9  := vPos11 := vPos12 := 0
	Private  vPos13 := vPos14 := vPos15 := vPos16 := vPos17 := vPos18 := vPos19 := vPos20 := vPos22 := 0
	Private  vPos23 := vPos24 := vPos25 := vPos26 := vPos27 := vPos28 := vPos29 := vPos30 := vPos31 := 0
	Private  vPos32 := vPos33 := 0

	IF len(pcmc7)=34
		vPos2  := Val(substr(pcmc7,2,1))
		vPos3  := Val(substr(pcmc7,3,1))
		vPos4  := Val(substr(pcmc7,4,1))
		vPos5  := Val(substr(pcmc7,5,1))
		vPos6  := Val(substr(pcmc7,6,1))
		vPos7  := Val(substr(pcmc7,7,1))
		vPos8  := Val(substr(pcmc7,8,1))
		vPos9  := Val(substr(pcmc7,9,1))
		vPos11 := Val(substr(pcmc7,11,1))
		vPos12 := Val(substr(pcmc7,12,1))
		vPos13 := Val(substr(pcmc7,13,1))
		vPos14 := Val(substr(pcmc7,14,1))
		vPos15 := Val(substr(pcmc7,15,1))
		vPos16 := Val(substr(pcmc7,16,1))
		vPos17 := Val(substr(pcmc7,17,1))
		vPos18 := Val(substr(pcmc7,18,1))
		vPos19 := Val(substr(pcmc7,19,1))
		vPos20 := Val(substr(pcmc7,20,1))
		vPos22 := Val(substr(pcmc7,22,1))
		vPos23 := Val(substr(pcmc7,23,1))
		vPos24 := Val(substr(pcmc7,24,1))
		vPos25 := Val(substr(pcmc7,25,1))
		vPos26 := Val(substr(pcmc7,26,1))
		vPos27 := Val(substr(pcmc7,27,1))
		vPos28 := Val(substr(pcmc7,28,1))
		vPos29 := Val(substr(pcmc7,29,1))
		vPos30 := Val(substr(pcmc7,30,1))
		vPos31 := Val(substr(pcmc7,31,1))
		vPos32 := Val(substr(pcmc7,32,1))
		vPos33 := Val(substr(pcmc7,33,1))

		vTotal   := 0
		vCalculo := 2*vPos2
		If vCalculo > 9
			vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
		EndIf

		vTotal := vTotal + vCalculo

		vCalculo := 1*vPos3
		If vCalculo>9
			vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
		EndIf

		vTotal := vTotal + vCalculo
		vCalculo := 2*vPos4
		If vCalculo>9
			vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
		EndIf

		vTotal := vTotal + vCalculo
		vCalculo := 1*vPos5
		If vCalculo>9
			vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
		EndIf

		vTotal := vTotal + vCalculo
		vCalculo := 2*vPos6
		If vCalculo>9
			vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
		EndIf

		vTotal := vTotal + vCalculo
		vCalculo := 1*vPos7
		If vCalculo>9
			vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
		EndIf

		vTotal := vTotal + vCalculo
		vCalculo := 2*vPos8
		If vCalculo>9
			vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
		EndIf

		vTotal := vTotal + vCalculo
		IF vPos22 = Val(substr(STRZERO(10-Val(substr(STRZERO(vTotal,2),2,1)),2),2,1))

		/* Calculo da segunda parte */
			vTotal   := 0
			vCalculo := 1*vPos11
			If vCalculo>9
				vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
			EndIf

			vTotal := vTotal + vCalculo
			vCalculo := 2*vPos12
			If vCalculo>9
				vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
			EndIf

			vTotal := vTotal + vCalculo
			vCalculo := 1*vPos13
			If vCalculo>9
				vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
			EndIf

			vTotal := vTotal + vCalculo
			vCalculo := 2*vPos14
			If vCalculo>9
				vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
			EndIf

			vTotal := vTotal + vCalculo
			vCalculo := 1*vPos15
			If vCalculo>9
				vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
			EndIf

			vTotal := vTotal + vCalculo
			vCalculo := 2*vPos16
			If vCalculo>9
				vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
			EndIf

			vTotal := vTotal + vCalculo
			vCalculo := 1*vPos17
			If vCalculo>9
				vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
			EndIf

			vTotal := vTotal + vCalculo
			vCalculo := 2*vPos18
			If vCalculo>9
				vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
			EndIf

			vTotal := vTotal + vCalculo
			vCalculo := 1*vPos19
			If vCalculo>9
				vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
			EndIf

			vTotal := vTotal + vCalculo
			vCalculo := 2*vPos20
			If vCalculo>9
				vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
			EndIf

			vTotal := vTotal + vCalculo
			//IF vPos9 = Val(substr(trim(to_char((10-Val(substr(trim(to_char(vTotal,'00')),2,1))),'00')),2,1)) THEN
			If vPos9 = Val(substr(STRZERO(10-Val(substr(STRZERO(vTotal,2),2,1)),2),2,1))

			/* Calculo da terceira parte */
				vTotal   := 0
				vCalculo := 1*vPos23

				IF vCalculo>9
					vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
				EndIf

				vTotal := vTotal + vCalculo
				vCalculo := 2*vPos24
				IF vCalculo>9
					vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
				EndIf

				vTotal := vTotal + vCalculo
				vCalculo := 1*vPos25
				IF vCalculo>9
					vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
				EndIf

				vTotal := vTotal + vCalculo
				vCalculo := 2*vPos26
				IF vCalculo>9
					vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
				EndIf

				vTotal := vTotal + vCalculo
				vCalculo := 1*vPos27
				IF vCalculo>9
					vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
				EndIf

				vTotal := vTotal + vCalculo
				vCalculo := 2*vPos28
				IF vCalculo>9
					vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
				EndIf

				vTotal := vTotal + vCalculo
				vCalculo := 1*vPos29
				IF vCalculo>9
					vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
				EndIf

				vTotal := vTotal + vCalculo
				vCalculo := 2*vPos30
				IF vCalculo>9
					vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
				EndIf

				vTotal := vTotal + vCalculo
				vCalculo := 1*vPos31
				IF vCalculo>9
					vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
				EndIf

				vTotal := vTotal + vCalculo
				vCalculo := 2*vPos32

				IF vCalculo>9
					vCalculo := Val(substr(STRZERO(vCalculo,2),1,1))+Val(substr(STRZERO(vCalculo,2),2,1))
				EndIf

				vTotal := vTotal + vCalculo
				//IF vPos33 = Val(substr(trim(to_char((10-Val(substr(trim(to_char(vTotal,'00')),2,1))),'00')),2,1))
				IF vPos33 = Val(substr(STRZERO(10-Val(substr(STRZERO(vTotal,2),2,1)),2),2,1))
					vRetorno := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	For nI := 1 to Len(cCmc7)
		If (nI >= 2  .And. nI <= 9 )  .Or. ;
				(nI >= 11 .And. nI <= 20 ) .Or. ;
				(nI >= 22 .And. nI <= 33)
			If !Substr(cCmc7,nI,1) $ ("0|1|2|3|4|5|6|7|8|9")
				vRetorno := .F.
			EndIf
		EndIf
	Next


RETURN vRetorno

/*
show errors;
select funcvericmc7('>27500300>0090108845>500087055182>') from dual;
*/

	************************************************************
User Function fGeraBor(cOrigem,aTitulos,cBancoBor,aDadosBor)
	************************************************************
	Local T
// Ronaldo Pena (Korus Konsultoria Ltda)
// FunÁ„o para geraÁ„o de Bordero a partir das Rotinas :
// RTC (RenegociaÁ„o de Titulos
// AFC (Acerto Financeiro da Carga
// DP  (Duplicatas para Bradesco
// 1o Parametro - Origem da Chamada
// 2o Parametro - Vetor de Titulos
//                [1] PREFIXO
//                [2] NUMERO
//                [3] PARCELA
//                [4] TIPO
// 3o Parametro - Banco do Bordero
// 4o Parametro - Dados adicionais do Bordero
//                [1] Prazo do cheque {D,B,A}
//                [2] N=> Nominal ; O=> Outros
//                [3] R=> Remessa ; C=> Conferencia
//                [4] Sequencia do Bordero
//                [5] 1=>Renegociado ; 2=>Nao Renegociado ; T=>Todos
//                [6] 1=>Com Emprestimo Lojista ; 2=>Sem Emprestimo Lojista

	If ValType(cOrigem)   <> "C" ; MsgStop("NaoExist - 1o Parametro da FunÁ„o fGeraBor inv·lido !!!") ; Return(.F.) ; Endif
		If ValType(aTitulos)  <> "A" ; MsgStop("NaoExist - 2o Parametro da FunÁ„o fGeraBor inv·lido !!!") ; Return(.F.) ; Endif
			If ValType(cBancoBor) <> "C" ; MsgStop("NaoExist - 3o Parametro da FunÁ„o fGeraBor inv·lido !!!") ; Return(.F.) ; Endif
				If ValType(aDadosBor) <> "A" ; MsgStop("NaoExist - 4o Parametro da FunÁ„o fGeraBor inv·lido !!!") ; Return(.F.) ; Endif

					If !cOrigem $ ("RTC|AFC")    ; MsgStop("Erro  - 1o Parametro da FunÁ„o fGeraBor inv·lido !!!")    ; Return(.F.) ; Endif
						If Len(aTitulos[1]) < 4      ; MsgStop("Erro  - 2o Parametro da FunÁ„o fGeraBor inv·lido !!!")    ; Return(.F.) ; Endif
							If Empty(cBancoBor)          ; MsgStop("Erro  - 3o Parametro da FunÁ„o fGeraBor inv·lido !!!")    ; Return(.F.) ; Endif
								If Len(aDadosBor) < 6        ; MsgStop("Erro  - 4o Parametro da FunÁ„o fGeraBor inv·lido !!!")    ; Return(.F.) ; Endif

									aBancos := U_FRetBancos()

									nPosBco   := Ascan(aBancos , {|X| X[1] == SM0->M0_CODEMP .And. X[2] == cBancoBor})
									cCodAgen  := aBancos[nPosBco,3]
									cDigAgen  := aBancos[nPosBco,4]
									cCodConta := aBancos[nPosBco,5]
									cDigConta := aBancos[nPosBco,6]

									lOkBord := .T.
									aRecnos := {}
									SE1->(dbOrderNickName("PSE11"))

									For T:=1 To Len(aTiTulos)
										If SE1->(DbSeek(xFilial("SE1")+aTitulos[T,1]+aTitulos[T,2]+aTitulos[T,3]+aTitulos[T,4]))
											aAdd( aRecnos , SE1->(Recno()) )
										Else
											lOkBor := .F. ; Exit
										Endif
									Next

									If !lOkBord ; MsgStop("Bordero nao gerado. Existem Titulos n„o localizados !!!") ; Return(.F.) ; Endif

										If Alltrim(cOrigem) == "RTC"
											cSeqBor := Soma1(GetMv("MV_XBORRTC"),3)
											cSeqBor := If(cSeqBor == '999','001',cSeqBor)
											cNumBor := "02"+nSeqBor
										Endif

										If Alltrim(cOrigem) == "AFC"
											cSeqBor := Soma1(GetMv("MV_XBORAFC"),3)
											cSeqBor := If(cSeqBor == '999','001',cSeqBor)
											cNumBor := "01"+nSeqBor
										Endif

										If Alltrim(cOrigem) == "DP"
											cNumBor := Soma1(GetMv("MV_NUMBORC"))
										Endif

										For T:=1 To Len(aRecnos)

											SE1->(DbGoTo(aRecnos[T]))

											SEA->(Reclock("SEA",.T.))
											SEA->EA_FILIAL   := xFilial("SEA")
											SEA->EA_NUMBOR   := cNumBor
											SEA->EA_DATABOR  := dDataBase
											SEA->EA_PORTADO  := cBancoBor
											SEA->EA_AGEDEP   := cCodAgen  + cDigAgen
											SEA->EA_NUMCON   := cCodConta + cDigConta
											SEA->EA_PREFIXO  := SE1->E1_PREFIXO
											SEA->EA_NUM      := SE1->E1_NUM
											SEA->EA_PARCELA  := SE1->E1_PARCELA
											SEA->EA_TIPO     := SE1->E1_TIPO
											SEA->EA_CART     := 'R'
											SEA->EA_SITUACA  := '1'
											SEA->EA_FILORIG  := xFilial("SEA")
											SEA->EA_XORIGEM  := cOrigem
											SEA->EA_XPRZCHQ  := aDadosBor[1]
											SEA->EA_XNOMCHQ  := aDadosBor[2]
											SEA->EA_XTIPMOV  := aDadosBor[3]
											SEA->EA_XSEQBOR  := aDadosBor[4]
											SEA->EA_XNEGCHQ  := aDadosBor[5]
											SEA->EA_XEMPCHQ  := aDadosBor[6]
											SEA->(MsUnLock())

											SE1->(RecLock("SE1",.F.))
											SE1->E1_NUMBOR  := SEA->EA_NUMBOR
											SE1->E1_DATABOR := SEA->EA_DATABOR
											SE1->E1_PORTADO := SEA->EA_PORTADO
											SE1->E1_AGEDEP  := SEA->EA_AGEDEP
											SE1->E1_CONTA   := SEA->EA_NUMCON
											SE1->E1_SITUACA := SEA->EA_SITUACA
											SE1->E1_MOVIMEN := SEA->EA_DATABOR
											SE1->(MsUnLock())

										Next
										Return(.T.)

										**************************
User Function fRetBancos()
	**************************

	aRet := {{ "Empresa" , "Banco" , "Agencia" , "Dg Agen" , "Conta"  , "Dg Conta" } ,;
		{ "03"      , "237"   , "3378"    , "2"       , "6483"   , "1"        } ,;
		{ "04"      , "237"   , "3378"    , "2"       , "3674"   , "9"        } ,;
		{ "05"      , "237"   , "3378"    , "2"       , "3675"   , "7"        } ,;
		{ "06"      , "237"   , "3378"    , "2"       , "3676"   , "5"        } ,;
		{ "10"      , "237"   , "3378"    , "2"       , "3677"   , "3"        } ,;
		{ "12"      , "237"   , "3378"    , "2"       , "6482"   , "3"        } ,;
		{ "15"      , "237"   , "3378"    , "2"       , "6485"   , "8"        } ,;
		{ "22"      , "237"   , "3378"    , "2"       , "0486"   , "3"        } ,;
		{ "16"      , "237"   , "3378"    , "2"       , "0540"   , "1"        } ,;
		{ "03"      , "422"   , "0060"    , "0"       , "850467" , "5"        } ,;
		{ "04"      , "422"   , "0060"    , "0"       , "850468" , "3"        } ,;
		{ "05"      , "422"   , "0060"    , "0"       , "850469" , "1"        } ,;
		{ "06"      , "422"   , "0060"    , "0"       , "850473" , "0"        } ,;
		{ "10"      , "422"   , "0060"    , "0"       , "850470" , "5"        } ,;
		{ "12"      , "422"   , "0060"    , "0"       , "850471" , "3"        } ,;
		{ "15"      , "422"   , "0060"    , "0"       , "850472" , "1"        }  }

Return(aRet)




//
// ORT_TRF
// Funcao para efetuar transferencia de mercadorias
//
// Parametros :
// 1) Produto a ser transferido
// 2) Quantidade a ser transferida
// 3) Almoxarifado de Origem
// 4) Almoxarifado Destino
//
// Retorno : .T. -> Transferencia OK
//           .F. -> Transferencia nao efetuada
//


User function ORT_TRF(_cCodPrd,_nQtd,_cOri,_cDest,_dData,cCodDest,_cObserv)
	local _aAreaX001 := getArea()

	Local 	_cDesc
	Local 	_cUm
	Local 	_nQtSeg	    := 	0
	Local 	_cEstor	    := 	space(1)
	Local 	_cNumSeq    := 	ProxNum()
	Local 	_cLocaliz   := 	SPACE(15)
	Local 	_cNumSer    := 	space(20)
	Local 	_cLoteCTL   := 	SPACE(10)
	Local 	_cNLote	    := 	space(10)
	Local 	_dVal		:= 	stod("")
	Local 	_nPotenc	:= 	0
	Local   _lRet       := .T.
	Default _dData		:=	dDatabase
	Default _cObserv	:=	" "

	if cCodDest==nil
		cCodDest:=_cCodPrd
	endif

	DbSelectArea("SB1")
	dbOrderNickName("PSB11")
	If DbSeek(xFilial("SB1") + _ccodprd)
		_cDesc := SB1->B1_DESC
		_cUM   := SB1->B1_UM
	EndIf

	_nqtSeg := _nQtd

	dDataval := "01/01/37"

	cDocto := U_ORT_DOCD3()

	_aTransfer := {{cDocto,_dData}}		//Criacao da 1a. linha do array com o documento e data


	lMSErroAuto := .f.

	aAdd(_aTransfer,{_cCodPrd,_cDesc,_cUm,_cOri,_cLocaliz,cCodDest,_cDesc,_cUm,_cDest,_cLocaliz,_cNumSer,;
		_cLoteCTL,_cNLote,_dVal,_nPotenc,_nQtd,_nQtSeg,_cEstor,_cNumSeq,_cLoteCTL })
//if Alltrim(cVersao) == "P10"
	aadd(_aTransfer[2],_dVal)
	aadd(_aTransfer[2],space(03))
	If cVersao!="11"
		aadd(_aTransfer[2], CriaVar("D3_OBSERVA") )
	EndIf
//endif

/*********************************************
** Verifica se existe armazem               **
** Se nao existir antes de transferir criar **
*********************************************/

DbSelectArea("SB2")
dbOrderNickName("PSB21")
	If !DbSeek(xFilial("SB2") + _cCodPrd+_cDest)
	criasb2(_cCodPrd,_cDest)
	endif

/****************************************************
* Inicio da transferencia de um armazem para outro *
****************************************************/
MsExecAuto({|x,y| mata261(x,y)},_aTransfer,3)//incluir
nLastRec:=SD3->(LastRec())
SD3->(DbGoTo(nLastRec))
	if lMSErroAuto
	_lRet := .F.
	mostraerro()
	U_JobcInfo("funcoes.prw","Erro na transferÍncia. Produto: " + _cCodPrd + " -> "+cCodDest+". AMZ: " +_cOri+" ->" +_cDest + ".",0)
	Else
	ConfirmSx8()
	cDocto  :=SD3->D3_DOC
	_cNumSeq:=SD3->D3_NUMSEQ
	_lRet := .T.
		if !Empty(_cObserv)
	   DbSelectArea("SD3")
	   aAreaSD3:=GetArea()
	   DbSetOrder(8)
	   cChave:=xFilial("SD3")+cDocto+_cNumSeq
	   dbSeek(cChave)
			Do While !eof() .AND. SD3->D3_FILIAL+SD3->D3_DOC+SD3->D3_NUMSEQ==cChave
	      reclock("SD3",.F.)
	      SD3->D3_XOBSERV:=AllTrim(SubStr(_cObserv,1,250))
	      msunlock()
	      DbSkip()
			EndDo
	   RestArea(aAreaSD3)
//	   cQuery:="UPDATE "+RetSqlName("SD3")+" SET D3_XOBSERV = '"+AllTrim(SubStr(_cObserv,1,250))+"' "
//	   cQuery+=" WHERE D_E_L_E_T_ = ' ' "
//	   cQuery+="   AND D3_FILIAL = '"+xFilial("SD3")+"' "
//	   cQuery+="   AND D3_DOC = '"+cDocto+"' "
//	   cQuery+="   AND D3_NUMSEQ = '"+_cNumSeq+"' "
//	   TCSqlExec(cQuery)
		Endif
	endif

restarea(_aAreaX001)
Return(_lRet)

// ORT_DOCD3
// Pega proximo numero disponivel para movimentacao interna
//
// Parametros 	: nenhum
// Retorno 		: _cDocRet -> Proxima numeracao do SD3 Disponivel
// OBS			: Na rotina, apos terminar a movimentacao interna, usar a rotina CONFIRMSX8
//
User Function ORT_DOCD3
Local _cDocRet

	Do While .t.
	//Chamada conforme padr„o do sistema
//	_cDocRet := NextNumero("SD3",2,'D3_DOC',.T.)
//	_cDocRet := A261RetInv(_cDocRet)
	_cDocRet :=GetSXENum("SD3","D3_DOC")
	_cQ := "SELECT COUNT(1) QTD FROM "+RetSqlName("SD3")+" WHERE D3_FILIAL='"+XFilial("SD3")+"' AND D3_DOC='"+_cDocRet+"' AND D_E_L_E_T_=' '"
	ConfirmSx8()
	TCQuery _cQ New Alias "TD3"
		If TD3->QTD==0
		TD3->(dbCloseArea())
		Exit
		Endif
	TD3->(dbCloseArea())
	dbselectarea("SD3")
	Enddo
Return(_cDocRet)


****************************
User Function AceProd(cCodBase,cCodSmed,cCorte,ctab)
****************************
Local cUM  :=""
Local aArea:=GetArea()
Local nCompAux:=0
Local nAlt :=0
dbselectarea("SB1")
dbOrderNickName("PSB11")
	if dbseek(xFilial("SB1")+padr(cCodBase,15))
	nCusto:=Posicione("DA1",1,xFilial("DA1")+cTAB+padr(cCodBase,15),"DA1_XCUSTO")
	nVol    :=round(SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP,2)
	nPeso   :=SB1->B1_XQTDEMB
	nDens   :=round(nPeso/nVol,2)
	nDensEqu:=SB1->B1_XDENSEQ
	nMark   :=SB1->B1_XMARKUP
	nAlt    :=SB1->B1_XALT
	nQtdEmb :=1
	cEspVol :="01"
		if nDensEqu == 0
		MsgBox("Bloco com densidade zerada. Preencha  o campo peso bruto","Erro Calculo de custo")
		endif
	//dbgotop()
	dbseek(xFilial("SB1")+padr(cCodSMed,15))
		if cCorte == "TORNEADO"
		cUM  :="MT"
		else
			if cCorte == "PE«A" .or. cCorte == "LAMINADO" .or. cCorte == "ALMOFADA" .or. cCorte == "CHANFRADO"
			cUM:="UN"
			else
			cUM:="KG"
			endif
		endif
		if SB1->B1_XCOMP==1.9 .AND. cCorte <> "BLOCO"
		nCompAux:=1.93
		else
		nCompAux:=SB1->B1_XCOMP
		endif
	RecLock("SB1",.F.)
	SB1->B1_UM     :=cUM
	SB1->B1_QB     :=1
	SB1->B1_PESO   :=(SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP)*nDens
	SB1->B1_XDENSEQ:=nDensEqu
		if cCorte == "CHANFRADO"
		SB1->B1_CUSTD  := nCUSTO*nCompAux*SB1->B1_XLARG*((SB1->B1_XALT+SB1->B1_XCHANFR)/2) //nCUSTO*nCompAux*SB1->B1_XLARG*(SB1->B1_XALT+SB1->B1_XCHANFRO)*2*nDensEqu
		elseIf cCorte == "TORNEADO" .And. cCodBase == "2010112520"	//Conforme solicitaÁ„o de Rinaldo Sales (unidade 09), o c·lculo de volume para este bloco deve considerar somente duas dimensıes
		SB1->B1_CUSTD  :=nCUSTO*nCompAux*SB1->B1_XALT*nDensEqu
		else
		SB1->B1_CUSTD  :=nCUSTO*nCompAux*SB1->B1_XLARG*SB1->B1_XALT*nDensEqu
		endif
	SB1->B1_XMARKUP:=nMark
		if cCorte == "LAMINADO"
	//DE ACORDO COM A CI 012 - INDUSTRIAL/CORTE DE ESPUMA
			IF cEmpAnt$'07|08|09|11|23'
				if  nAlt <= 0.007
				nQtdEmb:=10
				else
					if  nAlt < 0.02
					nQtdEmb:=5
					else
						if  nAlt <= 0.025
						nQtdEmb:=4
						else
							if  nAlt <= 0.04
							nQtdEmb:=2
							else
							nQtdEmb:=1
							endif
						endif
					endif
				endif
			ELSE
				IF nAlt < 0.02
				nQtdEmb:=25
				else
					if nAlt < 0.03
					nQtdEmb:=20
					else
						if nAlt < 0.04
						nQtdEmb:=15
						else
							if nAlt < 0.05
							nqtdemb:=10
							else
							nQtdEmb:=5
							endif
						endif
					endif
				endif
			endif
		cEspVol:="05"
		SB1->B1_SEGUM  :="MT"
		SB1->B1_CONV   :=5
		SB1->B1_TIPCONV:="M"
		SB1->B1_XMODELO:="000008" //Laminado
		SB1->B1_GRTRIB :=GetMV("MV_XGRTLAM")
			if cEmpAnt <> "18"
			SB1->B1_IPI    :=GetMV("MV_XIPILAM")
			SB1->B1_POSIPI :=GetMV("MV_XCFLAM")
			endif
		SB1->B1_XESPACO:=SB1->B1_XALT*B1_XLARG*B1_XCOMP*13/5
		else
			if cCorte == "PLACA"
				IF nAlt < 0.02
				nQtdEmp:=25
				else
					if nAlt < 0.03
					nQtdEm:=20
					else
						if nAlt < 0.04
						nQtdEmb:=15
						else
							if nAlt < 0.05

							nqtdemb:=10
							else
							nQtdEmb:=5
							endif
						endif
					endif
				endif
			cEspVol:="05"
			SB1->B1_SEGUM  :="MT"
			SB1->B1_CONV   :=5
			SB1->B1_TIPCONV:="M"
			SB1->B1_XMODELO:="000008" //Laminado
				If cEmpAnt$"22" .AND. cCorte <> "MANTA"
				SB1->B1_GRTRIB :=GetNewPar("MV_XGRTPLA",'002')
				Else
				SB1->B1_GRTRIB :=GetNewPar("MV_XGRTPLA",'001')
				Endif
			SB1->B1_IPI    :=GetNewPar("MV_XIPIPLA",0)
			SB1->B1_POSIPI :=GetNewPar("MV_XCFPLA",'94042100')
			SB1->B1_XESPACO:=SB1->B1_XALT*B1_XLARG*B1_XCOMP*13/5
			else
				if cCorte == "TORNEADO"
				SB1->B1_XMODELO:="000009" //Torneado
				SB1->B1_GRTRIB :=GetMV("MV_XGRTTOR")
				SB1->B1_IPI    :=GetMV("MV_XIPITOR")
				SB1->B1_POSIPI :=GetMV("MV_XCFTOR")
				SB1->B1_XESPACO:=SB1->B1_XALT*B1_XLARG*B1_XCOMP*13/5
				SB1->B1_CONV   :=1
				SB1->B1_TIPCONV:="M"
				else
					if cCorte == "PE«A"
					SB1->B1_XMODELO:="000010" //PeÁa
					SB1->B1_GRTRIB :=GetMV("MV_XGRTPEC")
						if cEmpAnt <> "18"
						SB1->B1_IPI    :=GetMV("MV_XIPIPEC")
						SB1->B1_POSIPI :=GetMV("MV_XCFPEC")
						endif
					SB1->B1_XESPACO:=SB1->B1_XALT*B1_XLARG*B1_XCOMP*10
					SB1->B1_CONV   :=1
					SB1->B1_TIPCONV:="M"
					else
						if cCorte == "ALMOFADA"
						SB1->B1_XMODELO:="000010" //Almofada
						SB1->B1_GRTRIB :=GetMV("MV_XGRTALM")
						SB1->B1_IPI    :=GetMV("MV_XIPIALM")
						SB1->B1_POSIPI :=GetMV("MV_XCFALM")
						SB1->B1_XESPACO:=SB1->B1_XALT*B1_XLARG*B1_XCOMP*10
						SB1->B1_CONV   :=1
						SB1->B1_TIPCONV:="M"
						else
							if cCorte == "CHANFRADO"
							SB1->B1_XMODELO:="000012" //Peca Chanfrada
							SB1->B1_GRTRIB  :=GetMV("MV_XGRTPEC")
							SB1->B1_IPI     :=GetMV("MV_XIPIPEC")
							SB1->B1_POSIPI  :=GetMV("MV_XCFPEC")
							SB1->B1_XCHANFR :=IIf(ValType(nChanfro) == "N",nChanfro,0)
							SB1->B1_CONV   :=1
							SB1->B1_TIPCONV:="M"
							SB1->B1_XESPACO:=SB1->B1_XALT*B1_XLARG*B1_XCOMP*10
							else
							SB1->B1_XMODELO:="000011" //BLOCO
							SB1->B1_CUSTD  :=nCusto
							SB1->B1_QB     :=nPeso
							SB1->B1_GRTRIB :=GetMV("MV_XGRTBLO")
							SB1->B1_IPI    :=GetMV("MV_XIPIBLO")
							SB1->B1_POSIPI :=GetMV("MV_XCFBLO")
							SB1->B1_CONV   :=nDens
							SB1->B1_TIPCONV:="D"
							SB1->B1_XESPACO:=SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP*10
							endif
						endif
					Endif
				Endif
			Endif
		endif
	SB1->B1_XESPVOL:=cEspVol
	SB1->B1_XQTDEMB:=nQtdEmb
	SB1->(MsUnlock())

		if cCorte == "LAMINADO"
		DBSELECTAREA("SB5")
		dbOrderNickName("PSB51")
			IF DBSEEK(XFILIAL("SB5")+SB1->B1_COD)
			RECLOCK("SB5",.F.)
			ELSE
			RECLOCK("SB5",.T.)
			SB5->B5_FILIAL:=XFILIAL("SB5")
			SB5->B5_COD   :=SB1->B1_COD
			SB5->B5_DESCNFE := SB1->B1_DESC + " " + SB1->B1_XMED
			ENDIF
		SB5->B5_CEME   := SB1->B1_DESC
		SB5->B5_UMDIPI :="MT"
		SB5->B5_CONVDIP:=5
		SB5->B5_CARPER :="2"
		SB5->B5_ROTACAO:="2"
		SB5->B5_UMIND  :="1"
		SB5->(MSUNLOCK())
		RESTAREA(aArea)
		else
			if cCorte == "PLACA"
				IF nAlt < 0.02
				nQtdEmp:=25
				else
					if nAlt < 0.03
					nQtdEm:=20
					else
						if nAlt < 0.04
						nQtdEmb:=15
						else
							if nAlt < 0.05

							nqtdemb:=10
							else
							nQtdEmb:=5
							endif
						endif
					endif
				endif
			cEspVol:="05"
			aarea:=GetArea()
			DBSELECTAREA("SB5")
			dbOrderNickName("PSB51")
				IF DBSEEK(XFILIAL("SB5")+SB1->B1_COD)
				RECLOCK("SB5",.F.)
				ELSE
				RECLOCK("SB5",.T.)
				SB5->B5_FILIAL:=XFILIAL("SB5")
				SB5->B5_COD   :=SB1->B1_COD
				SB5->B5_DESCNFE := SB1->B1_DESC + " " + SB1->B1_XMED
				ENDIF
			SB5->B5_CEME   := SB1->B1_DESC
			SB5->B5_UMDIPI :="MT"
			SB5->B5_CONVDIP:=5
			SB5->B5_CARPER :="2"
			SB5->B5_ROTACAO:="2"
			SB5->B5_UMIND  :="1"
			SB5->(MSUNLOCK())
			RESTAREA(aArea)
			endif
		endif



	endif
RestArea(aArea)
Return()


*********************************
User Function BandCob(cBandSiga,cTipoCart)
*********************************

***************************************************************************
// alterado por DECIO em  21.03.13  - inclusao da bandeira  26 - cielo
// alterado por DECIO em  30.04.13  - inclusao da bandeira  25 - elo
// alterado por DECIO em  14.10.13  - inclusao das bandeiras 14 - banpara
//                                                           22 - credishop
// Alterado por ADRIANO em 11.09.18 - inclusao da bandeira  44 - BLU
****************************************************************************

Local cBand

	if cBandSiga $ "11/26/25"
		if cTipoCart == "2"
		cBand := "01"
		else
		cBand := "05"
		endif
	elseif cBandSiga == "10"
		if cTipoCart == "2"
		cBand := "09"
		else
		cBand := "02"
		endif
	elseif cBandSiga == "12"
		if cTipoCart == "2"
		cBand := "08"
		else
		cBand := "03"
		endif
	elseif cBandSiga == "18"
	cBand := "07"
	elseif cBandSiga == "13"
	cBand := "04"
	elseif cBandSiga == "19"
	cBand := "06"
	elseif cBandSiga == "16"
	cBand := "11"
//elseif cBandSiga $ "14/15"
//	cBand := "12"
	elseif cBandSiga $ "14"
	cBand := "21"
	elseif cBandSiga == "17"
	cBand := "13"
	elseif cBandSiga == "21"
	cBand := "14"
	elseif cBandSiga == "22"
	cBand := "22"
	elseif cBandSiga == "31"
	cBand := "31"
	elseif cBandSiga == "33"
	cBand := "33"
	elseif cBandSiga == "15"
	cBand := "15"
	elseif cBandSiga == "23"
	cBand := "23"
	elseif cBandSiga == "24"
	cBand := "24"
	elseif cBandSiga == "44"
	cBand := "44"
	//Inclus„o da Bandeira Stone - Vagner Almeida - 23/11/20 - Inicio
	elseif cBandSiga == "42"	
	cBand := "42"
	//Inclus„o da Bandeira Stone - Vagner Almeida - 23/11/20 - Final
	elseif cBandSiga == "40"
	cBand := "40"	
	elseif cBandSiga == "45" // ZipBank - 16/12/21 Fabio Costa
		cBand := "45"	
	else
	cBand := "99"
	endif

Return(cBand)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥fEstrut   ∫Autor  ≥Renato Lucena Neves ∫ Data ≥  24/05/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁ„o para buscar os componentes e quantidades da estrutura±±
±±∫          ≥ de um produto.                                             ∫±±
±±∫          ≥ OBS. A rotina que chamar a fEstrut() deve conter uma variavel±
±±∫          ≥  private com o nome _aESTRUT do tipo array onde sera gravado±±
±±∫          ≥  a estrutura do produto                                    o±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP8-Ortobom                                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User function fESTRUT(_cProduto,_nQtd)

	Local _aArea:=GetArea()

	SB1->(DbSeek(xFilial('SB1')+_cProduto))

	DbSelectArea('SG1')
	dbOrderNickName("PSG11")
	IF DbSeek(xFilial('SG1')+_cProduto)
		while SG1->(!EOF()) .and. alltrim(SG1->G1_COD)==alltrim(_cProduto)
			aAdd(_aEstrut,{SG1->G1_COMP,(_nQtd*SG1->G1_QUANT)/SB1->B1_QB,SG1->G1_COD})
			u_fEstrut(SG1->G1_COMP,SG1->G1_QUANT)
			SB1->(DbSeek(xFilial('SB1')+_cProduto))
			SG1->(DbSkip())
		enddo
	endif

	RestArea(_aArea)
return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ValTransp ∫Autor  ≥Cesar Dupim         ∫ Data ≥  20/09/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁ„o para Validar se transportadora ja possui 2 cargas    ±±
±±∫          ≥ em transito                                                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP8-Ortobom                                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function ValTransp(cTransp,cCarga,lAcerto)
	Local cQuery
	Local aArea:=GetArea()
	Local cMesg:=""
	Local lRet:=.F.
	Local nCont:=0
	Local	_aArea	:=	GetArea()
	Local	_cCargaComp	:=	.F.
	Local nMaxCarga := 0


	DbSelectArea("SZQ")
	dbOrderNickName("CSZQ1")
	if cTransp==nil
		cTransp:=M->ZQ_TRANSP
	endif
	if cCarga==nil
		cCarga:=M->ZQ_EMBARQ
	endif

	DBSeek(xFilial('SZQ')+AllTrim(cCarga))

	If	SZQ->ZQ_EMBCOMP	<>	' '
		_cCargaComp	:=	.T.
	Endif

	RestArea(_aArea)

	nMaxCarga := POSICIONE("SA4",1,xFilial("SA4")+cTransp,"A4_XNUMEMB")
	if nMaxCarga == 0
		nMaxCarga := GetNewPar("MV_XNUMEMB",2)
	Endif
	dbselectarea("SC5")
	dbsetorder(5)
	if dbseek(xFilial("SC5")+cCarga) .and. !Empty(SC5->C5_XDTFECH)
		lFech:=.T.
	else
		lFech:=.F.
	endif

	If cTransp$(GetNewPar("MV_XTRLIB"," ")) .Or. _cCargaComp .or. lFech;//.or. cEmpAnt == "06" Retirado a exceÁ„o de trava para un.06 autorizado pelo Sr. Seixas. [01/11/2010] //Autorizado pelo Sr. Augusto Saisse via email no dia 19/02/09
		.or. cEmpAnt $ "21|24"  //Empresa 24 possui uma carga por pedido.
		lRet:=.T.
	Else
		cQuery:="SELECT COUNT(DISTINCT SUBSTR(ZQ_EMBARQ,2,5)) TOTCARGA FROM "
		cQuery+=RetSqlName("SZQ")+" SZQ, "+RetSqlName("SC5")+" SC5 "
		cQuery+="WHERE SZQ.D_E_L_E_T_ = ' ' "
		cQuery+="  AND SC5.D_E_L_E_T_ = ' ' "
		cQuery+="  AND C5_FILIAL  = '"+xFilial("SC5")+"' "
		cQuery+="  AND ZQ_FILIAL  = '"+xFilial("SZQ")+"' "
		cQuery+="  AND ZQ_EMBARQ  = C5_XEMBARQ           "
		cQuery+="  AND ZQ_TRANSP  = '"+cTransp+"'        "
		cQuery+="  AND SUBSTR(ZQ_EMBARQ,2,5) <> '"+SUBSTR(cCarga,2,5)+"'        "
		//	if date() <= stod('20070930')
		if lAcerto
			//	cQuery+="  AND C5_XACERTO <> ' '   "
			cQuery+="  AND C5_XDTFECH = ' '   "
		else
			cQuery+="  AND C5_XACERTO = ' '                  "
		endif
		cQuery+="  AND ZQ_EMBCOMP = ' ' "
		//	else
		//		cQuery+="  AND C5_XDTFECH = ' '                  "
		//	endif
		TCQUERY cQuery ALIAS "QRYTR" New
		dbselectarea("QRYTR")
		dbgotop()
		if QRYTR->TOTCARGA >= nMaxCarga
			dbclosearea()
			cQuery:="SELECT DISTINCT ZQ_EMBARQ FROM "
			cQuery+=RetSqlName("SZQ")+" SZQ, "+RetSqlName("SC5")+" SC5 "
			cQuery+="WHERE SZQ.D_E_L_E_T_ = ' ' "
			cQuery+="  AND SC5.D_E_L_E_T_ = ' ' "
			cQuery+="  AND C5_FILIAL  = '"+xFilial("SC5")+"' "
			cQuery+="  AND ZQ_FILIAL  = '"+xFilial("SZQ")+"' "
			cQuery+="  AND ZQ_EMBARQ  = C5_XEMBARQ           "
			//		cQuery+="  AND (SUBSTR(ZQ_EMBARQ,2,5) <> '"+SUBSTR(cCarga,2,5)+"' OR SUBSTR(ZQ_EMBCOMP,2,5) <> '"+SUBSTR(cCarga,2,5)+"')"    MOSTRA CARGAS COMPLEMENTARES
			cQuery+="  AND SUBSTR(ZQ_EMBARQ,2,5) <> '"+SUBSTR(cCarga,2,5)+"' "  //MOSTRA SOMENTE CARGAS PRINCIPAIS
			cQuery+="  AND ZQ_TRANSP  = '"+cTransp+"'        "
			//		if date() <= stod('20070930')
			if lAcerto
				cQuery+="  AND C5_XACERTO <> ' '   "
				cQuery+="  AND C5_XDTFECH = ' '   "
			else
				cQuery+="  AND C5_XACERTO = ' '                  "
			endif
			//		else
			//			cQuery+="  AND C5_XDTFECH = ' '                  "
			//		endif
			TCQUERY cQuery ALIAS "QRYTR" New
			cMesg:="Esta transportadora possui as seguintes cargas principais embarcadas:"+chr(13)+chr(10)
			dbselectarea("QRYTR")
			dbgotop()
			do while !eof()
				if nCont > 5
					cMesg+=chr(13)+chr(10)
				else
					if nCont > 0
						cMesg+=" - "
					else
						cMesg+=" "
					endif
				endif
				cMesg+=QRYTR->ZQ_EMBARQ
				nCont++
				dbskip()
			enddo
			msgbox(cMesg,"ERRO")
		else
			lRet:=.T.
		endif
		dbclosearea()
	endif
	restarea(aArea)
Return(lRet)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥PROXIMO   ∫Autor  ≥Renato Lucena Neves ∫ Data ≥  22/09/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Pega o proximo numero do campo passado pelo parametro      ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP8-Ortobom                                               ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
User Function PROXIMO(_cAlias,_cCampo)

	Local _aArea	:= GetArea()
	Local _cQuery	:= ""
	Local _cProximo	:= replicate('0',TamSx3(_cCampo)[2])
	Local _cCpoFil	:= ""

	If left(_cAlias,1)=='S'
		_cCpoFil:=right(alltrim(_cAlias),2)+"_FILIAL"
	else
		_cCpoFil:=alltrim(_cAlias)+"_FILIAL"
	endif

	_cQuery := "Select Max("+_cCampo+") ULTIMO from "+RetSqlName(_cAlias)
	_cQuery += " where D_E_L_E_T_=' ' and "+_cCpoFil+"='"+xFilial(_cAlias)+"'"

	TcQuery _cQuery New Alias "QRY1"
	DbSelectArea('QRY1')
	DbGoTop()

	IF QRY1->(!EOF())
		_cProximo:=QRY1->ULTIMO
	endif
	QRY1->(DbCloseArea())

	_cProximo:=soma1(_cProximo)

	RestArea(_aArea)
Return _cProximo

	************************************************
User Function ValLoja(cCliente,cLoja)
	************************************************
	local lRet:=.T.
	Local aArea:=GetArea()
	Local aSA1 :={}
	dbselectarea("SA1")
	aSA1:=GetArea()
	dbOrderNickName("PSA11")
	dbseek(xFilial("SA1")+cCliente+cLoja)
	if !found()
		MsgBox("Cliente Inexistente")
		lRet:=.F.
	else
		dbselectArea("SZA")
		dbOrderNickName("CSZA1")
		if !dbseek(xFilial("SZA")+SA1->A1_XTIPO) .or. SZA->ZA_TIPSEGM<>'1'
			lRet:=.F.
			MsgBox("Cliente n„o esta cadastrado como loja."+chr(13)+chr(10)+;
				"Verifique o cadastro do cliente campo segmento de negocio")
		else
			if empty(SA1->A1_VEND)
				lRet:=.F.
				MsgBox("Loja n„o possui franqueado ou proprietario."+chr(13)+chr(10)+;
					"Preencha o campo parceiro no cadastro do clientes")
			else
				dbselectarea("SZH")
				dbOrderNickName("CSZH5")
				dbseek(xFilial("SZH")+SA1->A1_VEND+SA1->A1_COD+SA1->A1_LOJA+SA1->A1_XTIPO)
				if !found()
					MsgBox("Cliente n„o possui cadastro Cliente X Segmento para o parceiro."+chr(13)+chr(10)+;
						"Verifique o cadastro Cliente X Segmento e o campo Parceiro no cadastro de Clientes")
					lRet:=.F.
				endif
			endif
		endif
	endif
	restarea(aSA1)
	restarea(aArea)
return(lRet)
	**************************************************
	* Valida se usuario pertence a determinado grupo *
	**************************************************
	* FunÁ„o     : VerGrupo                          *
	**************************************************
	* Responsavel: Cesar Dupim      Data: 18/07/08   *
	**************************************************
User Function VerGrupo(cGrupo,lInclui)
	Local aUser   := {}
	Local aAllGrp := AllGroups()
	Local cUsu    := alltrim(CUSERNAME)
	Local lRet    := .F.
	Local nPos:=ascan(aAllGrp,{|X| ALLTRIM(x[1,2]) == cGrupo})

	if Alltrim(cUsu)=="Administrador" .or. Alltrim(cUsu)=="dupim"
		lRet:=.T.
	else

		PswOrder(1)
		PswSeek(__cUserID ,.T. )
		aUser   := PswRet()


		if nPos > 0
			cGrupo:=aAllGrp[nPos,1,1] //Autoriza MIX
/*		If cVersao = '11'
			IF FWGrpAcess(cGrupo)=="S"
				lRet:=.T.
			Else
				if lInclui <> nil .and. Inclui   //Permite informar o campo se for inclusao e o parametro lInclui
					lRet:=.T.			         //informado
				endif
			EndIf
		Else*/

			if len(aUser[1,10])>0 .and. ascan(aUser[1,10],AllTrim(cGrupo)) > 0
			lRet:=.T.
			else
				if lInclui <> nil .and. Inclui   //Permite informar o campo se for inclusao e o parametro lInclui
				lRet:=.T.			         //informado
				endif
			endif
//		EndIf
		else
		lRet:=.F.
		endif
	endif
Return(lRet)
**************************************************
* Valida se usuario pode acessar o sistema a par-*
* tir daquele IP                                 *
**************************************************
* FunÁ„o     : ValUsu                            *
**************************************************
* Responsavel: Cesar Dupim      Data: 05/08/08   *
**************************************************
User Function ValUsu()
Local cUsu   :=alltrim(cUserName)
Local aUser  :={}
Local aAllGrp:= AllGroups()
Local nPos   := 0
Local aVarLib:={}
Local cVar   :=""
Local i
Local _cAmbiente := upper(alltrim(GetEnvServer()))

Public LXALTSB1		//LALTSB1

Public lAltSB1
Public lAutSbm
Public lAltVend
Public lAltForn
Public lAlttpsgsa1
Public lAutAgru
Public lAutpco
Public lAutdpr
Public lAltFrt
Public lAltFrtAdt
Public lAltAce
Public lAutPen
Public lAutNP
Public lAltComis
Public lAltTpPg  //Controla alteraÁ„o do campo Forma de Pagamento A1_XFORMPG
Public lAutReqCom //Acesso ilimitado para geraÁ„o de solicitaÁıes - SSI 4661 - Thais
Public lRegFrq
Public lCboxAq
Public lAltMatSb1 //Controla alteraÁ„o do campo B1_QE (Qtd de Embalagem de compra) feito pelos usuario da matriz
Public lAltSZH //Marcela Coimbra - Descricao: SSI 52927 - Importar para o Caixa os valores do Movimento de verba de repasse
Public _V11OwnerBD := "SIGA."
Public _OwnerBD    := "SIGA."

aadd(aVarLib,{"lCboxAq","CBOXAQ"})
aadd(aVarLib,{"lAltComis","ALTCOMIS"})
aadd(aVarLib,{"lAltVend","ALTVEND"})
aadd(aVarLib,{"lAutNP","AUTNP"})
aadd(aVarLib,{"lAltForn","AUTFORNEC"})
aadd(aVarLib,{"lRegFrq","REGFRQ"})
aadd(aVarLib,{"lAlttpsgsa1","ALTTPSGSA1"})
aadd(aVarLib,{"lAutAgru","AUTAGRU"})
aadd(aVarLib,{"lAutpco","AUTPCO"})
aadd(aVarLib,{"lAutdpr","AUTDPR"})
aadd(aVarLib,{"lAutSbm","AUTSBM"})
aadd(aVarLib,{"lAltFrt","ALTFRT"})
aadd(aVarLib,{"lAltFrtAdt","ALTFRTADT"})
aadd(aVarLib,{"lAltAce","ALTACE"})
aadd(aVarLib,{"lAutPen","AUTPEN"})
aadd(aVarLib,{"lAltTpPg","ALTTPPG"})
aadd(aVarLib,{"lAutReqCom","AUTREQCOM"})
aadd(aVarLib,{"lAltMatSb1","ALTMATSB1"})
IIF(cVersao == "11",aadd(aVarLib,{"lAltSb1","ALTSB1"}),aadd(aVarLib,{"lxAltSb1","ALTSB1"}))

aadd(aVarLib,{"lAltSZH","VERBREP"}) //Marcela Coimbra - Descricao: SSI 52927 - Importar para o Caixa os valores do Movimento de verba de repasse

	if LXALTSB1 == nil
	PswOrder(1)
	PswSeek(__cUserID ,.T. )
	aUser   := PswRet()
		if len(aUser[1,10])>0 .and. ascan(aUser[1,10],"000042") > 0  .or. Alltrim(cUsu)=="Administrador" .or. Alltrim(cUsu)=="dupim"
		LXALTSB1:=.T.
		else
		LXALTSB1:=.F.
		endif
	endif

	if lAltSZH == nil .and. cVersao <> "11"
	PswOrder(1)
	PswSeek(__cUserID ,.T. )
	aUser   := PswRet()
		if len(aUser[1,10])>0 .and. ascan(aUser[1,10],"000140") > 0  .or. Alltrim(cUsu)=="Administrador" .or. Alltrim(cUsu)=="dupim"
		lAltSZH:=.T.
		else
		lAltSZH:=.F.
		endif
	endif

	If lAutpco==Nil .and. cVersao <> "11"
	PswOrder(1)
	PswSeek(__cUserID ,.T. )
	aUser   := PswRet()
		if (len(aUser[1,10])>0 .and. ascan(aUser[1,10],"000031") > 0 )  .or. Alltrim(cUsu)=="Administrador" .or. Alltrim(cUsu)=="dupim"
		lAltPCO:=.T.
		else
		lAltPCO:=.F.
		endif
	EndIf

	If lAutdpr==Nil .and. cVersao <> "11"
	PswOrder(1)
	PswSeek(__cUserID ,.T. )
	aUser   := PswRet()
		if (len(aUser[1,10])>0 .and. ascan(aUser[1,10],"000031") > 0 )  .or. Alltrim(cUsu)=="Administrador" .or. Alltrim(cUsu)=="dupim"
		lAutdpr:=.T.
		else
		lAutdpr:=.F.
		endif
	EndIf

	if lAltAce== Nil
		if Alltrim(cUsu)=="Administrador" .or. Alltrim(cUsu)=="dupim"
			for i:=1 to Len(aVarLib)
			cVar:=aVarLib[i,1]
			&cVar:=.T.
			Next
		else
		PswOrder(1)
		PswSeek(__cUserID ,.T. )
		aUser   := PswRet()
			for i:=1 to Len(aVarLib)
			nPos:=ascan(aAllGrp,{|X| ALLTRIM(x[1,2]) == aVarLib[i,2]})
			cVar:=aVarLib[i,1]
				if nPos > 0
				cGrupo:=aAllGrp[nPos,1,1] //Autoriza MIX
					if len(aUser[1,10])>0 .and. ascan(aUser[1,10],AllTrim(cGrupo)) > 0
					&cVar:=.T.
					else
    				&cVar:=.F.
					endif
				else
				&cVar:=.F.
				endif
			Next
		endif
		
	if "FOLHA" $ _cAmbiente .or. "COMP12" $ _cAmbiente .or. "COMPREG" $ _cAmbiente
		return
	endif
		
	cQuery:="SELECT COUNT(*) TOT "
	cQuery+="  FROM USULIB "
	cQuery+=" WHERE USU = '"+Upper(Alltrim(cusu))+"' "

	memowrit("c:\usulib.sql",cQuery)

	TCQUERY cQuery ALIAS "USU" new
	nTot:=USU->TOT
	USU->(DBCLOSEAREA())

		Do Case
		//TESTA EMPRESAS QUE USAM O AMBIENTE ORTOBOM
		case cEmpAnt$("02")  .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOSP" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGSP"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOSP")
			endif
		case cEmpAnt$("03|58") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTORJ" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGRJ" .and.  upper(alltrim(GetEnvServer()))<>"SAC"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTORJ")
			endif
		case  cEmpAnt$("04") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOMG" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGMG"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOMG")
			endif
		case  cEmpAnt$("05") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOGO" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGGO" .and.  upper(alltrim(GetEnvServer()))<>"CLOUD"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOGO")
			endif
		case cEmpAnt$("06") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOMT" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGMT"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOMT")
			endif
		case cEmpAnt$("07") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOBA" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGBA"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOBA")
			endif
		case cEmpAnt$("08") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOPE" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGPE"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOPE")
			endif
		case cEmpAnt$("09") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOCE" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGCE"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOCE")
			endif
		case cEmpAnt$("10") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOPR" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGPR"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOPR")
			endif
		case cEmpAnt$("11") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOPA" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGPA"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOPA")
			endif
		case cEmpAnt$("15")  .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTORS" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGRS"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTORS")
			endif
		case cEmpAnt$("16")  .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOAF" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGAF"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTORS")
			endif
		case cEmpAnt$("22")  .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOAF" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGAF"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTORS")
			endif
		case cEmpAnt$("23") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOBA" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGBA"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOBA")
			endif
		case cEmpAnt$("24") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOBA" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGBA"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOBA")
			endif
		case cEmpAnt$("66") .and. nTot==0
			if upper(alltrim(GetEnvServer()))<>"ORTOBA" .and.  upper(alltrim(GetEnvServer()))<>"HOMOLOGBA"
				final("Acesso Nao Autorizado","Por Favor Utilizar o ambiente ORTOBA")
			endif
		endcase

		If SubStr(upper(alltrim(GetEnvServer())), 1, 7) == "HOMOLOG" .And. !U_ORTVLCPD()
		cQuery	:= " SELECT COUNT(*) AS TOT "
		cQuery	+= "   FROM HOMOLIB "
		cQuery	+= "  WHERE UNIDADE = '"+cEmpAnt+"' "
		cQuery	+= "    AND UPPER(USUARIO) = '"+UPPER(cUsu)+"' "
		cQuery	+= "    AND DATA >= '"+DToS(DATE())+"' "
		cQuery	+= "    AND HORA >= '"+TIME()+"' "
		U_ORTQUERY(cQuery, "VALUSUHOMO")
			If Empty(VALUSUHOMO->TOT)
			VALUSUHOMO->(dbCloseArea())
			Final("Acesso Nao Autorizado","Solicite liberacao ao CPD Regional para utilizacao do ambiente de homologacao")
			EndIf
		VALUSUHOMO->(dbCloseArea())
		EndIf

	/*
		if Alltrim(cUsu)<>"Administrador" .and. Alltrim(cUsu)<>"dupim"
			if at('.',cUsu)==0
	final("Acesso Nao Autorizado","Usuario "+Alltrim(cUsu)+" com acesso nao autorizado")
			else
	cFaixa:=substr(cIp,at('.',cIp)+1)
	cFaixa:=substr(cFaixa,at('.',cFaixa)+1)
	cFaixa:=substr(cFaixa,1,at('.',cFaixa)-1)
	cUsu  :=alltrim(substr(cUsu,at('.',cUsu)+1))
				if val(cUsu)<>val(cFaixa) .and. (cUsu<>'20' .or. cFaixa <>'60') .and. cUsu<>'06'
	final("Acesso Nao Autorizado","Usuario com acesso nao autorizado desse local")
				endif
			endif
		endif
	*/
	Endif
Return()
	**************************************************
	* Validacao de usuarios logo apos login Modulo   *
	* Faturamento                                    *
	**************************************************
	* FunÁ„o     : Funcao de validacoes de modulos   *
	**************************************************
	* Responsavel: Cesar Dupim      Data: 05/08/08   *
	**************************************************
User Function Sigaatf()
	U_ValUsu()
Return()
User Function Sigacom()
	U_ValUsu()
Return()
User Function Sigactb()
	U_ValUsu()
Return()
User Function Sigaest()
	U_ValUsu()
Return()
User Function Sigafat()
	U_ValUsu()
Return()
User Function Sigafin()
	U_ValUsu()
//if type("l_ortp089") == "U"
//   public l_ortp089 := .f.
//endif
//if !l_ortp089
//   l_ortp089 := u_ortp089()
//endif
Return()
User Function Sigafis()
	U_ValUsu()
Return()
User Function Sigapcp()
	U_ValUsu()
Return()

User Function Sigajur() // Marcela Coimbra - Liberar cadastro no SIGAJURI
	U_ValUsu()
Return()

//PONTO DE ENTRADA DA FOLHA
User Function Sigagpe() 

local aPergs	:= {}
local cLoad	    := "XALERFOL" + cEmpAnt + cFilAnt
local cFileName := RetCodUsr() +"_"+ cLoad
local cxMV_PAR01:= MV_PAR01
local cxMV_PAR02:= MV_PAR02

U_ValUsu()

public cFil := cFilAnt

MV_PAR01 := dtos(stod(""))
MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)

if MV_PAR01 <> dtos(Date())
	U_ORTR038()
	MV_PAR01 := dtos(Date()) 
	aAdd( aPergs ,{1,"Data Exec",MV_PAR01,"",".t.",'','.T.',50,.F.})	
	ParamSave(cFileName,aPergs,"1")
endif	

MV_PAR01:= cxMV_PAR01
MV_PAR02:= cxMV_PAR02

//Baixa atestados pendentes
// STARTJOB("GPEM026B",GetEnvServer(),.F.,{cEmpAnt,cFilAnt})
Return()

User Function Sigapon()
	U_ValUsu()
Return()
	**************************************************
	* Validacao se usuarios pode acessar sigamdi    *
	**************************************************
	* FunÁ„o     : MdiOK                             *
	**************************************************
	* Responsavel: Cesar Dupim      Data: 05/08/08   *
	**************************************************
User Function MDIOK()
	Local aUsu:={}
	Local lret:=.T.
	PswOrder(1)
	if PswSeek(__cUserId,.T.)
		aUsu:=PswRet()
		if aUsu[1,15] > 0 .and. aUsu[1,15] < 2
			lRet:=.F.
			final("Acesso SIGAMDI Nao Autorizado","Utilize SIGAADV na abertura do sistema")
		endif
	endif
Return(lRet)

User function ValidPedagio()

	local lRet := .T.
	If M->PAH_PEDAGI > M->PAH_PEDMAX
		alert("Valor do Ped·gio maior que o maximo permitido para esse Vendedor/Roteiro...")
		lRet := .F.
	endif
return lRet

User function ValidKm()

	local lRet := .T.
	If M->PAH_KM > M->PAH_KMMAX
		alert("Total de Km maior que o maximo permitido para esse Vendedor/Roteiro...")
		lRet := .F.
	endif
return lRet
	**************************************************
	* Validacao do campo ZH_REFTAB                   *
	*                                                *
	**************************************************
	* FunÁ„o     : Funcao de validacoes de Campo     *
	**************************************************
	* Responsavel: Cesar Dupim      Data: 05/08/08   *
	**************************************************
User Function ValReftab()
	Local aArea:=GetArea()
	Local cQuery:=""
	Local cQry  :=""
	Local lRet  :=.F.
	cQuery:="SELECT COUNT(*) TOTREG "
	cQuery+="  FROM "+RetSqlName("SZH")+" SZH "
	cQuery+=" WHERE D_E_L_E_T_ = ' ' "
	cQuery+="   AND ZH_FILIAL  = '"+xFilial("SZH")+"' "
	cQuery+="   AND ZH_VEND    = '"+M->ZH_VEND+"' "
	cQuery+="   AND ZH_CLIENTE<> '"+M->ZH_CLIENTE+"' "
	cQuery+="   AND ZH_REFTAB <> '"+M->ZH_REFTAB+"' "
	cQuery+="   AND ZH_REFTAB <> ' ' "
	cQuery+="   AND ZH_ITINER  = '"+M->ZH_ITINER+"' "
	memowrit("c:\ValReftab.sql",cQuery)
	TCQUERY cQuery ALIAS "QRY" NEW
	dbselectarea("QRY")
	if QRY->TOTREG > 0
		if MsgBox("Ja existem clientes para esse vendedor nesse Roteiro com outra Referencia"+chr(13)+chr(10)+;
				"Deseja alterar todos?","ATEN«¬O","YESNO")
			dbclosearea()
			cQuery:="SELECT COUNT(*) TOTREG "
			cQuery+="  FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SZH")+" SZH "
			cQuery+=" WHERE SC5.D_E_L_E_T_ = ' ' "
			cQuery+="   AND SZH.D_E_L_E_T_ = ' ' "
			cQuery+="   AND ZH_FILIAL  = '"+xFilial("SZH")+"' "
			cQuery+="   AND C5_FILIAL  = '"+xFilial("SC5")+"' "
			cQuery+="   AND C5_VEND1   = '"+M->ZH_VEND+"' "
			cQuery+="   AND ZH_VEND    = '"+M->ZH_VEND+"' "
			cQuery+="   AND C5_CLIENTE = ZH_CLIENTE "
			cQuery+="   AND C5_EMISSAO > '20080902' "
			cQuery+="   AND ZH_REFTAB <> '"+M->ZH_REFTAB+"' "
			cQuery+="   AND ZH_ITINER  = '"+M->ZH_ITINER+"' "
			memowrit("c:\ValReftab2.sql",cQuery)
			TCQUERY cQuery ALIAS "QRY" NEW
			dbselectarea("QRY")
			if QRY->TOTREG > 0
				MsgBox("Ja existem pedidos para esse vendedor nesse Roteiro com outra Referencia","ALTERA«√O INVALIDA")
				lRet:=.F.
			else
				cQry:="UPDATE "+RetSqlName("SZH")+" SET ZH_REFTAB = '"+M->ZH_REFTAB+"' "
				cQry+=" WHERE D_E_L_E_T_ = ' ' "
				cQry+="   AND ZH_FILIAL  = '"+xFilial("SZH")+"' "
				cQry+="   AND ZH_VEND    = '"+M->ZH_VEND+"' "
				cQry+="   AND ZH_REFTAB <> '"+M->ZH_REFTAB+"' "
				cQry+="   AND ZH_ITINER  = '"+M->ZH_ITINER+"' "
				Begin Transaction
					TCSQLExec(cQry)
				End Transaction
				lRet:=.T.
			endif
		else
			lRet:=.F.
		endif
	else
		cQry:="UPDATE "+RetSqlName("SZH")+" SET ZH_REFTAB = '"+M->ZH_REFTAB+"' "
		cQry+=" WHERE D_E_L_E_T_ = ' ' "
		cQry+="   AND ZH_FILIAL  = '"+xFilial("SZH")+"' "
		cQry+="   AND ZH_VEND    = '"+M->ZH_VEND+"' "
		cQry+="   AND ZH_REFTAB  = ' ' "
		cQry+="   AND ZH_ITINER  = '"+M->ZH_ITINER+"' "
		Begin Transaction
			TCSQLExec(cQry)
		End Transaction
		lRet:=.T.
	endif
	dbclosearea()
	restarea(aArea)
Return(lRet)

User Function fChkMIX(aNumPed)
	**************************************************
	Local cQuery:=""
	Local lRet  :=.F.
	Local nRet  :=0
	Local nRetVp:=0
	Local cNumPed := ""
	local _Nx:=0
	Private cAtf  	    := GetMv("MV_XEXCATF")  // excecoes ativo fixo
	Private cExc        := GETMV("MV_XEXCEC")   // excecoes
	Private cTrav	    := GetMV("MV_XEXCTRA")  // excecoes travesseiros

	*'M·rcio Sobreira - Mix Ponderado ------------------------------------------------------------------------------'*
	If ValType(aNumPed) == "A"
		For _Nx := 1 to Len(aNumPed)
			cNumPed += aNumped[_Nx] + IIF(_Nx <> Len(aNumPed),"|","")
		Next
	Else
		cNumPed := aNumPed
	Endif
	*'M·rcio Sobreira - Mix Ponderado ------------------------------------------------------------------------------'*

/*
	if Empty(cExc)
MsgBox("AtenÁ„o flocos e similares est„o sendo considerados para bloqueio de mix","INFORME SETOR DE T.I.")
	endif
*/
	if Empty(cAtf)
		MsgBox("AtenÁ„o bens imobilizados est„o sendo considerados para bloqueio de mix","INFORME SETOR DE T.I.")
	endif

	cQuery	:= " SELECT DECODE(SUM(VALOR),0,0,ROUND(100 * (SUM(VALOR) - SUM(CUSTO)) / SUM(VALOR), 2)) AS MIX, "
	cQuery	+= "        ROUND(SUM(PRZMED*VALOR) / SUM(VALOR), 2) AS PRZMED, "
	cQuery	+= "        ROUND(100 * "
	cQuery	+= "              (SUM(VALOR * (100 - NVL(C5_XVERREP, 0) - NVL(C5_XVEREXT, 0)) / 100) - SUM(CUSTO)) / "
	cQuery	+= "              (SUM(VALOR * (100 - NVL(C5_XVERREP, 0) - NVL(C5_XVEREXT, 0)) / 100)), "
	cQuery	+= "             2) AS MIXREP, COUNT(*) TOTPED "
	cQuery	+= "  FROM (SELECT C5_NUM, C5_XVERREP, C5_XVEREXT,C5_XOPER, C5_XPRZMED PRZMED, 
	cQuery	+= "               DECODE(C5_XOPER,'05',0,SUM(C6_QTDVEN * C6_XPRUNIT)) AS VALOR, "
	cQuery	+= "               SUM(C6_QTDVEN * C6_XCUSTO) AS CUSTO "
	cQuery	+= "          FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6 "
	cQuery	+= "         WHERE SC5.D_E_L_E_T_ = ' ' "
	cQuery	+= "           AND SC6.D_E_L_E_T_ = ' ' "
	cQuery	+= "           AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery	+= "           AND C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery	+= "           AND C5_NUM IN "+FormatIn(cNumPed,"|")
	cQuery  += "           AND C5_XOPER NOT IN ('02','03','06','22') "
	cQuery	+= "           AND C6_NUM = C5_NUM "
	If !Empty(cAtf)
		cQuery	+= "           AND C6_TES NOT IN "+cAtf+" "
	Endif
	cQuery	+= "         GROUP BY C5_NUM, C5_XVERREP, C5_XVEREXT,C5_XOPER, C5_XPRZMED) "

	U_ORTQUERY(cQuery, "FCHKMIX")

	If FCHKMIX->(EOF()) 
		lRet	:= .F.
		nRet	:= 0
		nRetVp	:= 0
	    nTotPed := 0
	Else
		lRet	:= .T.
		nRet	:= FCHKMIX->MIX
		nRetVp	:= FCHKMIX->MIXREP
		nPrzMed := FCHKMIX->PRZMED
		nTotPed := 0
	EndIf
	FCHKMIX->(dbCloseArea())

Return({lRet,nRet,nRetVp,nTotPed,nPrzmed})
	************************************
User Function fMedTri(cCli,cLoja,dDatap)
	************************************
	Local aRet:={}
	Default dDatap:=dDatabase
// MEDIA DO trimestre
	cQuery:="SELECT ( SUM(CASE WHEN TO_DATE(SC5.C5_EMISSAO, 'YYYYMMDD') BETWEEN "
	cQuery+="                  TRUNC(ADD_MONTHS(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'),-3), 'MM') "
	cQuery+="                  AND TRUNC(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'),'MM')-1  "
	cQuery+="                  AND M2_MOEDA5 > 0 AND SC5.C5_XOPER <> '05'"
	cQuery+="                THEN "
	cQuery+="               ((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5) "
	cQuery+="               ELSE  "
	cQuery+="                0    "
	cQuery+="           END)) / 3 NVALTRI, "


// MEDIA DO CUSTO DO TRIMESTRE
	cQuery+="     SUM(CASE WHEN TO_DATE(SC5.C5_EMISSAO, 'YYYYMMDD') BETWEEN "
	cQuery+="                  TRUNC(ADD_MONTHS(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'),-3), 'MM') "
	cQuery+="                  AND TRUNC(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'),'MM')-1  "
	cQuery+="                  AND M2_MOEDA5 > 0 "
	cQuery+="                THEN "
	cQuery+="               ((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO  / M2_MOEDA5) "
	cQuery+="               ELSE  "
	cQuery+="                0    "
	cQuery+="           END) / 3 NCUSTRI, "


// MEDIA DOS ULTIMOS 30 DIAS
	cQuery+="    SUM(CASE "
	cQuery+="             WHEN TO_DATE(SC5.C5_EMISSAO,'YYYYMMDD') BETWEEN TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD')-30 "
	cQuery+="               AND TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD')  "
	cQuery+="               AND M2_MOEDA5 > 0 AND SC5.C5_XOPER <> '05'"
	cQuery+="                THEN "
	cQuery+="               ((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5)     "
	cQuery+="             ELSE  "
	cQuery+="              0 "
	cQuery+="           END) NVALCUR , "


// CUSTO DOS ULTIMOS 30 DIAS
	cQuery+="    SUM(CASE "
	cQuery+="             WHEN TO_DATE(SC5.C5_EMISSAO,'YYYYMMDD') BETWEEN TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD')-30 "
	cQuery+="               AND TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD')  "
	cQuery+="               AND M2_MOEDA5 > 0 "
	cQuery+="                THEN "
	cQuery+="               ((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5)     "
	cQuery+="             ELSE  "
	cQuery+="              0 "
	cQuery+="           END) NCUSCUR , "


// MEDIA DO ULTIMO MES FECHADO
	cQuery+="    SUM(CASE "
	cQuery+="             WHEN TO_DATE(SC5.C5_EMISSAO,'YYYYMMDD') BETWEEN TRUNC(ADD_MONTHS(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'),-1),'MM')   "
	cQuery+="                 AND TRUNC(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'),'MM')-1  "
	cQuery+="                  AND M2_MOEDA5 > 0 AND SC5.C5_XOPER <> '05'"
	cQuery+="                THEN  "
	cQuery+="               ((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5)    "
	cQuery+="             ELSE "
	cQuery+="              0  "
	cQuery+="           END) NVALMES, "

// CUSTO DO ULTIMO MES FECHADO
	cQuery+="    SUM(CASE "
	cQuery+="             WHEN TO_DATE(SC5.C5_EMISSAO,'YYYYMMDD') BETWEEN TRUNC(ADD_MONTHS(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'),-1),'MM')   "
	cQuery+="                 AND TRUNC(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'),'MM')-1  "
	cQuery+="                  AND M2_MOEDA5 > 0 "
	cQuery+="                THEN  "
	cQuery+="               ((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5)    "
	cQuery+="             ELSE "
	cQuery+="              0  "
	cQuery+="           END) NCUSMES, "


// VALOR DO DIA
	cQuery+="       SUM(CASE  "
	cQuery+="             WHEN SC5.C5_EMISSAO = TO_CHAR(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'),'YYYYMMDD') "
	cQuery+="                  AND M2_MOEDA5 > 0 AND SC5.C5_XOPER <> '05'"
	cQuery+="                THEN "
	cQuery+="               ((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5)    "
	cQuery+="             ELSE "
	cQuery+="        0         "
	cQuery+="  END) NVALDIA,    "


// CUSTO DO DIA
	cQuery+="       SUM(CASE  "
	cQuery+="             WHEN SC5.C5_EMISSAO = TO_CHAR(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'),'YYYYMMDD') "
	cQuery+="                  AND M2_MOEDA5 > 0 "
	cQuery+="                THEN "
	cQuery+="               ((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5)    "
	cQuery+="             ELSE "
	cQuery+="        0         "
	cQuery+="  END) NCUSDIA    "

	cQuery+="  FROM "+RetSQLName("SC5")+" SC5, "+RetSQLName("SC6")+" SC6, "+RetSQLName("SA1")+" SA1,"
	cQuery+="       "+RetSQLName("SM2")+" SM2, "+RetSQLName("SD2")+" SD2 "
	cQuery+=" WHERE SD2.D2_PEDIDO(+)  = SC6.C6_NUM   "
	cQuery+="   AND SD2.D2_ITEM(+)    = SC6.C6_ITEM "
	cQuery+="   AND SD2.D2_COD(+)     = SC6.C6_PRODUTO "
	cQuery+="   AND SC5.C5_NUM        = SC6.C6_NUM  "
	cQuery+="   AND SC5.C5_CLIENTE    = SA1.A1_COD "
	cQuery+="   AND SC5.C5_LOJACLI    = SA1.A1_LOJA"
	cQuery+="   AND SC5.D_E_L_E_T_    = ' ' "
	cQuery+="   AND SC6.D_E_L_E_T_    = ' ' "
	cQuery+="   AND SA1.D_E_L_E_T_    = ' ' "
	cQuery+="   AND SM2.D_E_L_E_T_    = ' ' "
	cQuery+="   AND SD2.D_E_L_E_T_(+) = ' ' "
	cQuery+="   AND SM2.M2_DATA       = SC5.C5_EMISSAO "
	cQuery+="   AND SC5.C5_FILIAL     = '"+xFilial("SC5")+"' "
	cQuery+="   AND SC6.C6_FILIAL     = '"+xFilial("SC6")+"' "
	cQuery+="   AND SA1.A1_FILIAL     = '"+xFilial("SA1")+"' "
	cQuery+="   AND SD2.D2_FILIAL(+)  = '"+xFilial("SD2")+"' "
	cQuery+="   AND SA1.A1_XCODCOM    = '"+POSICIONE("SA1",1,XFILIAL("SA1")+cCli,"A1_XCODCOM")+"' "
	cQuery+="   AND SC5.C5_XOPER      IN ('01','04','05','14','15','16','20','21','99') "
	cQuery+="   AND SC5.C5_XTPSEGM    IN ('1','2','5','6' ) "
	cQuery+="   AND SC5.C5_XOPERAN    <> '99'"
	cQuery+="   AND SC5.C5_XMOTCAN    IN ('98', '  ')"
	cQuery+="   AND TO_DATE(SC5.C5_EMISSAO, 'YYYYMMDD') >=                                                      "
	cQuery+="       TRUNC(ADD_MONTHS(TO_DATE('"+dtos(ddatap)+"', 'YYYYMMDD'), -3), 'MM')                                                   "
	U_ORTQUERY(cQuery,"CLACLI")
	aAdd(aRet,CLACLI->NVALTRI)
	aAdd(aRet,CLACLI->NVALCUR)
	aAdd(aRet,CLACLI->NVALMES)
	aAdd(aRet,CLACLI->NVALDIA)
	aAdd(aRet,CLACLI->NCUSTRI)
	aAdd(aRet,CLACLI->NCUSCUR)
	aAdd(aRet,CLACLI->NCUSMES)
	aAdd(aRet,CLACLI->NCUSDIA)
	aAdd(aRet,0)
	aAdd(aRet,0)
	dbclosearea()
Return(aRet)
*******************************************
User Function AtuSZE(lInc,cBlq,cMesg,aMedTri)
*******************************************
	if aMedTri==Nil
		aMedTri:={}
	endif
	if len(aMedtri) == 4
		aadd(aMedtri,0)
	endif
	SZE->(DbSetOrder(3))
	if lInc
		if !SZE->(DBSEEK(XFILIAL("SZE")+SC5->C5_NUM+cBlq))
			reclock("SZE",.T.)
			SZE->ZE_FILIAL  := XFILIAL("SZE")
			SZE->ZE_PEDIDO  :=SC5->C5_NUM
			SZE->ZE_AUTORIZ :=cBlq
			SZE->ZE_OBS     :=cMesg
			if len(aMedTri)>1
				SZE->ZE_MEDTRI	:=aMedTri[1]
				SZE->ZE_MED30D	:=aMedTri[2]
				SZE->ZE_ULTMES	:=aMedTri[3]
				SZE->ZE_VALPED	:=aMedTri[9] //SZE->ZE_VALPED	:=aMedTri[5]  -->  	//Alterado por Luiz Otavio SSI 23688

				//Adicionado por Luiz Otavio SSI 23688
				SZE->ZE_CUSTRI	:=aMedTri[5]
				SZE->ZE_CUSMD30	:=aMedTri[6]
				SZE->ZE_CUSULTM	:=aMedTri[7]

				If len(aMedTri)>9
					SZE->ZE_CUSPED	:=aMedTri[10]
				EndIf
				//************ Fim da Alteracao *************************
			endif
			IF cBlq=="LIBMIX"
				SZE->ZE_USUARIO:=Iif(Empty(cUserName),"XXXXXXXXXXXXXXX",alltrim(cUserName))
				SZE->ZE_DTAUT  :=dDataBase
			EndIf
			msunlock()
		else//if !(cBlq == "BLQPNV" .AND. SUBSTR(ZE_OBS,1,12) == "PROGRAMACAO!")
			reclock("SZE",.F.)
			SZE->ZE_OBS     :=cMesg
			if len(aMedTri)>1
				SZE->ZE_MEDTRI	:=aMedTri[1]
				SZE->ZE_MED30D	:=aMedTri[2]
				SZE->ZE_ULTMES	:=aMedTri[3]
				SZE->ZE_VALPED	:=aMedTri[9] //SZE->ZE_VALPED	:=aMedTri[5]  -->  	//Alterado por Luiz Otavio SSI 23688

				// *****Adicionado por Luiz Otavio SSI 23688 ***********
				SZE->ZE_CUSTRI	:=aMedTri[5]
				SZE->ZE_CUSMD30	:=aMedTri[6]
				SZE->ZE_CUSULTM	:=aMedTri[7]
				SZE->ZE_CUSPED	:=aMedTri[10]
				//************ Fim da Alteracao *************************
			endif
			msunlock()
		endif
	ELSE
		if SZE->(DBSEEK(XFILIAL("SZE")+SC5->C5_NUM+cBlq)) .and. (Empty(SZE->ZE_USUARIO)  .or. cBlq=="LIBMIX")//.AND. !(cBlq == "BLQPNV" .AND. SUBSTR(ZE_OBS,1,12) == "PROGRAMACAO!")
			reclock("SZE",.F.)
			delete
			msunlock()
		endif
	endif
Return()

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ESTCIVGPE ∫ Autor ≥ Diego Bueno - Chaus∫ Data ≥  22/06/09   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Retorna o estado civÌl de acordo com layout CNAB Banpar·.  ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ CNAB Banpar· - Ortobom Unidade 11                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function EstCivGPE(matricula)

	Local cEstCivi := ""

	dbSelectArea("SRA")
//dbSetOrder(1)
//If dbSeek(xFilial("SRA")+matricula)
	cEstCivi := IIF(SRA->RA_ESTCIVI=='S',"01",IIF(SRA->RA_ESTCIVI=='C',"02",IIF(SRA->RA_ESTCIVI=='D',"03","04")))
//EndIf
Return(cEstCivi)

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥GETConjuge∫ Autor ≥ Diego Bueno - Chaus∫ Data ≥  22/06/09   ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥ Retorna conjuge do funcionario para layout CNAB Banpar·.   ∫±±
	±±∫          ≥                                                            ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Uso       ≥ CNAB Banpar· - Ortobom Unidade 11                          ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function GETConjuge(matricula)

	Local cConjuge := ""

	dbSelectArea("SRA")
//dbSetOrder(1)
//If dbSeek(xFilial("SRA")+matricula,.F.)
	cConjuge := IIF(U_ESTCIVGPE(matricula) == "02",IIF(POSICIONE("SRB",1,XFILIAL("SRB")+SRA->RA_MAT,"RB_GRAUPAR") == 'C',POSICIONE("SRB",1,XFILIAL("SRB")+SRA->RA_MAT,"RB_NOME")," "),""+SPACE(40))
//EndIf
return(cConjuge)

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥GetGrauGPE∫ Autor ≥ Diego Bueno - Chaus∫ Data ≥  22/06/09   ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥ Retorna o grau de instruÁao para layout CNAB Banpar·.      ∫±±
	±±∫          ≥                                                            ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Uso       ≥ CNAB Banpar· - Ortobom Unidade 11                          ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function GetGrauGPE(matricula)

/*

CNAB BanPara
"01" - Analfabeto
"02" - 1∫ Grau incompleto
"03" - 1∫ Grau completo
"04" - 2∫ Grau incompleto
"05" - 2∫ Grau completo
"06" - Superior incompleto
"07" - Superior completo

SX5
10 ANALFABETO   01
20 ATE A 4 INC    02
25 COM 4 COM        02
30 PRIMEIRO GRAU INC    02
35 PRIMEIRO GRAU COMPLETO    03
40 SEGUN GRAU INC           04
45 SEGUND GRAU COMP         05
50 SUPERIOR INCOMPL          06
55 SUPERIOR COMP             07
65 MESTRADO COMPLETO         07
75 DOUTORA COMP              07

*/
	Local cGrau := ""

	dbSelectArea("SRA")
//dbSetOrder(1)
//If dbSeek(xFilial("SRA")+matricula)
	DO CASE
	CASE SRA->RA_GRINRAI == "10"
		cGrau := "01"
	CASE SRA->RA_GRINRAI == "20"
		cGrau := "02"
	CASE SRA->RA_GRINRAI == "25"
		cGrau := "02"
	CASE SRA->RA_GRINRAI == "30"
		cGrau := "02"
	CASE SRA->RA_GRINRAI == "35"
		cGrau := "03"
	CASE SRA->RA_GRINRAI == "40"
		cGrau := "04"
	CASE SRA->RA_GRINRAI == "45"
		cGrau := "05"
	CASE SRA->RA_GRINRAI == "50"
		cGrau := "06"
	CASE SRA->RA_GRINRAI == "55"
		cGrau := "07"
	CASE SRA->RA_GRINRAI == "65"
		cGrau := "07"
	CASE SRA->RA_GRINRAI == "75"
		cGrau := "07"
	OTHERWISE
		cGrau := "  "
	EndCase
//EndIf
return cGrau

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥GetSituacaoGPE∫ Autor ≥ Diego Bueno    ∫ Data ≥  22/06/09   ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥ Retorna a situaÁ„o do funcinonario para o CNAB Banpar·.    ∫±±
	±±∫          ≥                                                            ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Uso       ≥ CNAB Banpar· - Ortobom Unidade 11                          ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function GetSituacaoGPE(matricula)

/*
CNAB BanPara
"00" - N„o afastado
"01" - Afastado temporariamente
"02" - Afastado definitivamente

SX5
SITUACAO NORMAL
A 	AFASTADO TEMP.
D 	DEMITIDO
F	FERIAS
T	TRANSFERIDO


*/
	Local cSituacao := ""

	dbSelectArea("SRA")
//dbSetOrder(1)
//If dbSeek(xFilial("SRA")+matricula)
	DO CASE
	CASE Empty(SRA->RA_SITFOLH)
		cSituacao := "00"
	CASE SRA->RA_SITFOLH == "A"
		cSituacao := "01"
	CASE SRA->RA_SITFOLH == "D"
		cSituacao := "02"
	CASE SRA->RA_SITFOLH == "F"
		cSituacao := "00"
	CASE SRA->RA_SITFOLH == "T"
		cSituacao := "02"
	OTHERWISE
		cSituacao := "  "
	EndCase
	If !Empty(SRA->RA_DEMISSA)
		cSituacao := "02"
	EndIf
//EndIf

return(cSituacao)


	*****************************
	*Formula para Preenchimento *
	*Nota Fiscal UN. 06         *
	*****************************
User Function Form06(cPedItem)
	Local cTes :=""
	Local cTexto:=""
	Local lPrim :=.T.
	Local aArea :=GetArea()
	Local aSC6  :={}
	Local aIpi  :={}
	dbselectarea("SC6")
	aSC6:=GetArea()

//Retirado para trazer os dados por produto, antes estava trazendo somente os dados do primeiro produto
//dbOrderNickName("PSC61")
//dbseek(XFILIAL("SC6")+SC5->C5_NUM)

	if Empty(cPedItem)
		Return("")
	Endif

//dbOrderNickName("PSC61")  // ---> Henrique - 02/04/2018 - Retirado o NickName por esta dando problema na NFe 4.0
	SC6->(DbSetOrder(1))
//alert(cPedItem)
	dbseek(XFILIAL("SC6")+cPedItem)
//dbseek(XFILIAL("SC6")+SC5->C5_NUM)
	cTes:=SC6->C6_TES
	cCF :=SC6->C6_CF
	cProd:=SC6->C6_PRODUTO
	nValDesc:=SC6->C6_DESCONT
	IF SUBSTR(cCF,2,3)=="910"
		cTexto+="BRINDE\ "
	endif
	nValZfr:=SF2->F2_DESCZFR//Posicione("SF3",4,xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE,"F3_DESCZFR")
	nValZfp:=0
	nAliqPisCof := 0
	nAliqPisCof := GETMV("MV_TXPIS")+GETMV("MV_TXCOFIN") //PEGAR ALIQ DO PIS/COFINS [ SOLICITADO POR WANDERLEY/KATIA(UNID 11)]
	if nValZfr>0
		cQuery:="SELECT SUM(D2_DESCZFP+D2_DESCZFC) DESCZFP FROM "+RetSqlName("SD2")+" WHERE D_E_L_E_T_ = ' ' AND D2_FILIAL = '"+xFilial("SD2")+"' AND D2_DOC = '"+SF2->F2_DOC+"' AND D2_SERIE = '"+SF2->F2_SERIE+"' "
		TCQUERY cQuery ALIAS DESCZFP NEW
		dbselectarea("DESCZFP")
		nValZFp:=DESCZFP->DESCZFP
		dbclosearea()
	endif

	cQuery:="SELECT COUNT(*) TOTREG"
	cQuery+="  FROM "+RetSqlName("SD2")+" SD2, "+RetSqlName("SB1")+" SB1 "
	cQuery+=" WHERE SD2.D_E_L_E_T_ = ' ' "
	cQuery+="   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery+="   AND D2_FILIAL = '"+xFilial("SD2")+"' "
	cQuery+="   AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery+="   AND D2_DOC = '"+SF2->F2_DOC+"' "
	cQuery+="   AND D2_SERIE = '"+SF2->F2_SERIE+"' "
	cQuery+="   AND B1_COD = D2_COD "
	cQuery+="   AND B1_POSIPI = '94035000' "
	TCQUERY cQuery ALIAS IPIN NEW
	dbselectarea("IPIN")
	nTotReg:=IPIN->TOTREG
	dbclosearea()

	dbselectarea("SF4")
	aAreaSF4:=GetArea()
	dbsetorder(1)
	dbseek(xFilial("SF4")+cTes)
	cSitTrib:=SF4->F4_SITTRIB
	nPIcmDif:=SF4->F4_PICMDIF
	DBSELECTAREA("SM4")
	DBSETORDER(1)
	if !empty(SC5->C5_MENPAD)
		if dbseek(xFilial("SM4")+SC5->C5_MENPAD) .and. ALLTRIM(SM4->M4_FORMULA) <> "U_FORM06()"
			cTexto+=ALLTRIM(FORMULA(SC5->C5_MENPAD))+"\"
		endif
	endif
	if nTotReg > 0 .and. dbseek(xFilial("SM4")+"CAM")
		cTexto+=ALLTRIM(FORMULA("CAM"))+"\"
	endif
	if SC5->C5_XTPSEGM$'34' .and. !SC5->C5_XOPER$"02|03|07|08|17" .and. dbseek(xFilial("SM4")+"PGA")
		cTexto+=FORMULA("PGA")+"\"
	endif
	if SF4->F4_TRFICM=="2" .and. nPIcmDif <> 100 .and. nPIcmDif <> 0 .and. dbseek(xFilial("SM4")+"DIF")
		cTexto+=FORMULA("DIF")+"\"
	endif
	If !Empty(SC5->C5_XMENPA2) .AND. SC5->C5_XMENPA2 # SC5->C5_MENPAD .And. ValType(formula(SC5->C5_XMENPA2)) == "C"
		cTexto+=formula(SC5->C5_XMENPA2)+"\"
	Endif
	If !Empty(SC5->C5_XMENPA3) .AND. SC5->C5_XMENPA3 # SC5->C5_MENPAD .And. ValType(formula(SC5->C5_XMENPA3)) == "C"
		cTexto+=formula(SC5->C5_XMENPA3)+"\"
	Endif
	If !Empty(SC5->C5_MENNOTA)
		cTexto+=ALLTRIM(SC5->C5_MENNOTA)+"\"
	Endif
	If !Empty(SC5->C5_XMENNF1)
		cTexto+=ALLTRIM(SC5->C5_XMENNF1)+"\"
	Endif
	If !Empty(SC5->C5_XMENNF2)
		cTexto+=ALLTRIM(SC5->C5_XMENNF2)+"\"
	Endif
	If !Empty(SC5->C5_XMENNF3)
		cTexto+=ALLTRIM(SC5->C5_XMENNF3)+"\"
	Endif
	IF cSitTrib=="40"
		if dbseek(xFilial("SM4")+"IIC")
			cTexto+=alltrim(FORMULA("IIC"))+"\"
		endif
	endif
	dbgotop()
	IF cSitTrib=="50"
		if dbseek(xFilial("SM4")+"ICZ")
			cTexto+=alltrim(FORMULA("ICZ"))+"\"
		endif
	endif
	dbgotop()
	IF cSitTrib=="10"
		if dbseek(xFilial("SM4")+"STB")
			cTexto+=alltrim(FORMULA("STB"))+"\"
		endif
	endif
	dbgotop()
	IF cSitTrib=="70"
		if dbseek(xFilial("SM4")+"RST")
			cTexto+=alltrim(FORMULA("RST"))+"\"
		endif
	endif
	IF cSitTrib=="70" .or. cSitTrib=="20"
		if dbseek(xFilial("SM4")+"SIN")
			cTexto+=Alltrim(U_AjuSin())
		endif
	endif
	IF nPIcmDif <> 100 .and. nPIcmDif <> 0
		if dbseek(xFilial("SM4")+"DIF")
			cTexto+=alltrim(FORMULA("DIF"))+"\"
		endif
	endif
	if dbseek(xFilial("SM4")+"STR")
		cTexto+=ALLTRIM(FORMULA("STR"))+"\"
	endif
	if nValDesc==11.828 .AND. dbseek(xFilial("SM4")+"SIM")
		cTexto+=ALLTRIM(FORMULA("SIM"))+"\"
	endif

	if dbseek(xFilial("SM4")+"IPI")
		//IF POSICIONE("SF4",1,XFILIAL("SF4")+CTES,"F4_CTIPI")=="51"

		// SSI 30599 - Se o cliente for industria calÁadista
		If Posicione("SA1",1,XFILIAL("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, "A1_GRPTRIB") == "133"

			cQuery:="SELECT COUNT(*) TOT from SIGA."+RetSqlName("SC6")+", SIGA."+RetSqlName("SB1")+" "
			cQuery+="WHERE C6_NUM = '"+SC5->C5_NUM+"' AND B1_COD = C6_PRODUTO AND B1_XMODELO IN('000008','000010')"
			aIpi:=GetArea()
			TCQUERY cQuery ALIAS TPPROD NEW
			dbselectarea("TPPROD")
			nTots:=TPPROD->TOT
			dbclosearea()
			RestArea(aIpi)

			// se dentro do pedido existir algum produto tipo bloco laminado ou peÁa industrial
			// exibe o aviso de IPI suspenso
			if nTots > 0
				cTexto+=FORMULA("IPI")+"\"
			endif

		EndIf
		//endif
	EndIF
	if dbseek(xFilial("SM4")+"NTR")
		IF cSitTrib=="41" .AND. !EMPTY(FORMULA("NTR"))
			cTexto+=FORMULA("NTR")+"\"
		endif
	EndIF
	if dbseek(xFilial("SM4")+"IPZ")
		IF POSICIONE("SF4",1,XFILIAL("SF4")+CTES,"F4_CTIPI")$"52|53"
			cTexto+=FORMULA("IPZ")+"\"
		endif
	EndIF
	if dbseek(xFilial("SM4")+"IPS")
		IF POSICIONE("SF4",1,XFILIAL("SF4")+CTES,"F4_CTIPI")=="55"
			cTexto+=FORMULA("IPS")+"\"
		endif
	EndIF
	IF cSitTrib=="20"
		if dbseek(xFilial("SM4")+"RBC")
			cTexto+=FORMULA("RBC")+"\"
		endif
	EndIF
	if SC5->C5_TPFRETE == "C"
		if dbseek(xFilial("SM4")+"VLF")
			cTexto+=FORMULA("VLF")+"\"
		endif
		dbgotop()
	endif
	if SM4->(dbseek(xFilial("SM4")+"VLC"))
		cTexto+=FORMULA("VLC")+"\"
	endif
	if SM4->(dbseek(xFilial("SM4")+"SSC")) .and. Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_GRPTRIB")=="105"
		cTexto+=FORMULA("SSC")+"\"
	endif

	IF SUBSTR(cCF,2,3)=="916" .and. SM4->(dbseek(xFilial("SM4")+"RCN"))
		cTexto+=FORMULA("RCN")+"\"
	endif
	dbgotop()
	if dbseek(xFilial("SM4")+"MT3")
		cQry:="SELECT SUM(C6_QTDVEN*B1_XALT*B1_XLARG*B1_XCOMP) VOLUME FROM "+RetSqlName("SC6")+" SC6, "+RetSqlName("SB1")+" SB1 "
		cQry+=" WHERE SC6.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND B1_COD = C6_PRODUTO "
		cQry+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
		cQry+="   AND B1_FILIAL = '"+xFilial("SB1")+"' "
		cQry+="   AND C6_NUM = '"+SC5->C5_NUM+"' "
		TCQUERY cQry ALIAS "PESO" NEW
		dbselectarea("PESO")
		cTexto+="M3: "+Transform(PESO->VOLUME,"@E 999,999.99")+"\"
		dbclosearea()
		dbselectarea("SM4")
	EndIF
	dbgotop()
	nValBrut := SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_DESCZFR-SF2->F2_DESCONT //soma o valor da mercadoria +impostos-desconto
	IF nValZfr>0
		cTexto+=alltrim(FORMULA("008"))
		cTexto+="\Valor total dos produtos "+Transform(nValBrut,"@E 999,999,999.99")
		nValZfi:=round(nValZfr-nValzfp,2)
		if nValZfP > 0 //round((SF2->F2_VALBRUT+nValZfr)*0.12,2)
			//nPDesc:=((nValZfr/(SF2->F2_VALBRUT+nValZfr))*100)-9.25 //pis cofins
			//	    if nPdesc > 10
			//   		   cTexto+="\Valor desconto ref. 12% ICMS "+Transform(round((SF2->F2_VALBRUT+nValZfr)*0.12,2),"@E 999,999,999.99")
			If cEmpAnt # "21" && condiÁ„o incluida por Henrique-12/01/2016 conforme solicitaÁ„o do Furtado
				nPDesc:=round(((nValZfp/(nValBrut))*100),2)
				cTexto+="\Valor desconto ref. "+transform(nAliqPisCof,"@ 99.99")+"% PIS/COFINS"+Transform(nValZFP,"@E 999,999,999.99")
			EndIf

			//   		else
			//   		   cTexto+="\Valor desconto ref. 7% ICMS "+Transform(round((SF2->F2_VALBRUT+nValZfr)*0.07,2),"@E 999,999,999.99")
			//           cTexto+="\Valor desconto ref. PIS/COFINS"+Transform(NVALZFR-(round((SF2->F2_VALBRUT+nValZFR)*0.07,2)),"@E 999,999,999.99")
			//   		endif
			//	else
			//		cTexto+="\Valor desconto ref. 12% ICMS "+Transform(nValZfr,"@E 999,999,999.99")+"\"
		endif
		nPDesc:=round(((nValZfi/(nValBrut))*100),0)
		if nPDesc==11 //Gambiarra devido ao desconto do pis antes do icms
			nPDesc:=12
		endif
		If cEmpAnt <> '21'
			cTexto+="\Valor desconto ref. "+transform(nPDesc,"@ 99")+"% ICMS "+Transform(nValZFi,"@E 999,999,999.99")
		EndIf
		IF CEMPANT $ "11" .AND.  SF2->F2_ICMSRET > 0
			cTexto+="\Valor total com desconto da A.L.C.M.S.: "+Transform(SF2->F2_VALMERC,"@E 999,999,999.99")+"\"
		ELSE
			cTexto+="\Valor total com desconto: "+Transform(SF2->F2_VALBRUT,"@E 999,999,999.99")+"\"
		ENDIF
	endif
	if dbseek(xFilial("SM4")+"CPC")
		cTexto+=ALLTRIM(FORMULA("CPC"))+"\"
	endif

	if SC5->C5_XOPER=="04" .and. dbseek(xFilial("SM4")+"NRP")
		nTam:=len(ALLTRIM(FORMULA("NRP")))
		cTexto+=ALLTRIM(FORMULA("NRP"))
		dbselectarea("SC6")
		dbOrderNickName("PSC61")
		dbseek(xFilial("SC6")+SC5->C5_NUM)
		do while !eof() .and. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM
			if !empty(SC6->C6_NFORI)
				cTexto+=" "+alltrim(SC6->C6_NFORI)+"-"+alltrim(SC6->C6_SERIORI)+" DE "+dtoc(SC6->C6_XDTVEND)
				nTam+=Len(" "+alltrim(SC6->C6_NFORI)+"-"+alltrim(SC6->C6_SERIORI)+" DE "+dtoc(SC6->C6_XDTVEND))
				if nTam>=110
					cTexto+="\"
					nTam:=0
				endif
			endif
			dbskip()
		enddo
		cTexto+="\"
	endif
	dbgotop()
	if cempant=="06"
		if SC5->C5_XOPER=="03" .or. SC5->C5_XOPER=="02" .or. SC5->C5_XOPER=="17"
			dbselectarea("SC6")
			dbOrderNickName("PSC61")
			dbseek(xFilial("SC6")+SC5->C5_NUM)
			do while !eof() .and. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM
				if !empty(SC6->C6_XOBS)
					if lPrim
						cTexto+=ALLTRIM(cTexto)+"TROCA REF. NF. "
						lPrim:=.F.
					else
						cTexto+=" - "
					endif
					cTexto+=alltrim(SC6->C6_XOBS)
				endif
				dbskip()
			enddo
			cTexto+="\"
		endif
	endif
	If !Empty(SC5->C5_XPEDCLI) .and. cEmpAnt=="07"
		cTexto+="Pedido de compra: "+SC5->C5_XPEDCLI+"\"
	EndIf
	If !Empty(SC5->C5_XPEDCLI) .AND. cEmpAnt=="02" .AND. AllTrim(SC5->C5_COTACAO)=="IMPPDA" && 01/02/2020 Henrique - SSI 90285
		cTexto+="Pedido de compra: "+SC5->C5_XPEDCLI+"\"
	EndIf

	restarea(aSC6)
	restarea(aArea)
Return(alltrim(cTexto))
	****************************
User Function AjuSin()
	****************************
	Local aArea:=GetArea()
	Local cTxt:=""
	Local cQuery:=""
	cQuery:="SELECT B1_POSIPI, SUM((D2_TOTAL-D2_BASEICM)*(D2_VALICM/DECODE(D2_BASEICM,0,1,D2_BASEICM))) DESICM, "
	cQuery+="       SUM(((D2_BRICMS*100/DECODE(F4_BSICMST,0,100,F4_BSICMST))*"
	cQuery+="        ((D2_ICMSRET+D2_VALICM)/DECODE(D2_BRICMS,0,1,D2_BRICMS)))-(D2_ICMSRET+D2_VALICM)) DESST "
	cQuery+="  FROM "+RetSQLName("SD2")+" SD2, "+RetSQLName("SF4")+" SF4, "+RetSQLName("SB1")+" SB1 "
	cQuery+=" WHERE SD2.D_E_L_E_T_ = ' ' "
	cQuery+="   AND SF4.D_E_L_E_T_ = ' ' "
	cQuery+="   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery+="   AND D2_FILIAL = '"+XFILIAL("SD2")+"' "
	cQuery+="   AND F4_FILIAL = '"+XFILIAL("SF4")+"' "
	cQuery+="   AND B1_FILIAL = '"+XFILIAL("SB1")+"' "
	cQuery+="   AND D2_TES = F4_CODIGO "
	cQuery+="   AND D2_COD = B1_COD "
	cQuery+="   AND D2_PEDIDO = '"+SC5->C5_NUM+"' "
	cQuery+=" GROUP BY B1_POSIPI "
	tcquery cQuery  alias "AJUSIN" new
	dbselectarea("AJUSIN")
	dbgotop()
	do While !eof()
		if AJUSIN->DESICM>0
			cTxt+=alltrim(AJUSIN->B1_POSIPI)+" VLR.DISP.R$ "+alltrim(Transform(AJUSIN->DESICM,"@E 999,999,999.99"))
			if cEmpAnt=="03"
				cTxt+=" MOT.DES.:DEC.36.451/04"
			else
				cTxt+=" MOT.DES.:"
			endif
			IF AJUSIN->DESST>0
				cTxt+=" VLR.DISP.R$ "+alltrim(Transform(AJUSIN->DESST,"@E 999,999,999.99"))
				cTxt+=" MOT.DES.:DEC.43.213/11\"
			else
				cTxt+="\"
			ENDIF
		ELSE
			if AJUSIN->DESST>0
				cTxt+=alltrim(AJUSIN->B1_POSIPI)+" VLR.DISP.R$ "+alltrim(Transform(AJUSIN->DESST,"@E 999,999,999.99"))
				cTxt+=" MOT.DES.:DEC.43.213/11\"
			endif
		endif
		dbskip()
	enddo
	dbclosearea()
	restarea(aArea)
Return(cTxt)

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥ATUSZT    ∫ Autor ≥ Eduardo Brust      ∫ Data ≥ 27/07/09	  ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥ATUALIZACAO DA TABELA SZT A PARTIR DO CONSUMO NA TABELA SD3 ∫±±
	±±∫          ≥SOMENTE SE MAX(ZT_DATA) FOR INFERIOR A DATA ATUAL			  ∫±±
	±±∫          ≥															  ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Uso       ≥ORTOBOM			                                          ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function ATUSZT(cCodPro,cDataAte)
	Local aArea	:= GetArea() // guardo area ativa
	Local cSql	:= ""
//Local cDataIni := ""
//Local cDataFim := ""
	Local lPeriodo  := .F. // indica se ira usar periodo
	Local cDataIni  := ""
	Local cDataFim	:= cDataAte

// SZTTMP030
	cSql += " SELECT  COUNT(*) TOT " 		 + ENTER
	cSql += " FROM SZTTMP"+CEMPANT+"0" 		 + ENTER
	cSql += " WHERE ZT_COD = '"+cCodPro+"'" + ENTER

	IF Select("TMPSZT") > 0
		dbSelectArea("TMPSZT")
		dbCloseArea()
	ENDIF
	memowrite("c:\ATUSZTa.sql",cSql)
	TCQUERY cSql ALIAS "TMPSZT" NEW

	dbselectarea("TMPSZT")

// VERIFICA SE MES CORRENTE JA FOI GRAVADO NA SZT
	IF TMPSZT->TOT > 0
		lPeriodo 	:= .T.
		cDataIni 	:= cDataFim - 15 // PEGO OS ULTIMOS 7 DIAS
	ENDIF

//INSERE REGISTROS NA SZT
	if lPeriodo
		cSql := " DELETE SZTTMP"+CEMPANT+"0 WHERE ZT_DATA < TO_CHAR(ADD_MONTHS(TRUNC(SYSDATE,'MM'),-12),'YYYYMMDD') "
		nRet := tcsqlexec(cSql)
	endif


	cSql := ""
	cSql += " MERGE INTO SZTTMP"+CEMPANT+"0 USING "+"( SELECT D3_COD, D3_EMISSAO,   " 	+ ENTER
	cSql += " SUM(D3_QUANT) QUANT  " 												+ ENTER
	cSql += " FROM " + RetSqlName("SD3")+ " SD3 " 					 				+ ENTER
	cSql += " WHERE D3_TM > '500' " 				 	 							+ ENTER
	cSql += " AND D3_TM <> '502' " 					 	 							+ ENTER
	cSql += " AND D3_TM <> '800' " 					 	 							+ ENTER
	cSql += " AND D3_TM <> '998' " 					 	 							+ ENTER
	cSql += " AND D3_TM <> '997' " 					 	 							+ ENTER
	cSql += " AND D3_CF LIKE 'RE%' " 				 	 							+ ENTER
	cSql += " AND D3_CF NOT IN ('RE4', 'DE4') " 	 	 							+ ENTER
	cSql += " AND D3_LOCAL NOT IN ('05','40','98') "     					 		+ ENTER //Edilson Leal 28/09/20 SSI 102986 - Nao considerar armazem 98 conforme autorizado pelo Dupim 
	cSql += " AND D3_ESTORNO <> 'S' " 				 	 					 		+ ENTER
	if lPeriodo
		cSql += " AND D3_EMISSAO BETWEEN '" + dtos(cDataIni)+ "' AND '" + dtos(cDataFim) + "'" 	+ ENTER
	endif
	cSql += " AND SD3.D_E_L_E_T_ = ' ' " 				 							+ ENTER
	cSql += " AND D3_FILIAL = '" + XFILIAL("SD3")+ "'" 								+ ENTER
	cSql += " AND D3_COD = '" + cCodPro+ "'" 	    						 		+ ENTER
	cSql += " GROUP BY D3_COD, D3_EMISSAO ) " 										+ ENTER
	cSql += " ON (D3_COD = ZT_COD AND D3_EMISSAO = ZT_DATA)"						+ ENTER
	cSql += " WHEN MATCHED THEN UPDATE SET ZT_QUANT = QUANT " 						+ ENTER
	cSql += " WHEN NOT MATCHED THEN INSERT (ZT_COD, ZT_DATA, ZT_QUANT) " 			+ ENTER
	cSql += " VALUES (D3_COD, D3_EMISSAO, QUANT) " 		  							+ ENTER
	memowrite("c:\ATUSZTB.sql",cSql)

	Begin Transaction
		TCSQLExec(cSql)
	End Transaction

	RestArea(aARea)
Return

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥AjustaSx1	∫ Autor ≥ Eduardo Brust      ∫ Data ≥ 16/11/09	  ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥AJUSTA PERGUNTE DAS ROTINAS DE ACORDO COM TAMANHO DO SX1	  ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Uso       ≥ORTOBOM			                                          ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function AjustaSx1(cPerg,aRegs)
	Local aArea	:= GetArea() // guardo area ativa
	Local nTamSx1 := 6    // default
	Local j,i :=0
// RETORNA O TAMANHO ATUAL DO GRUPO DE PERGUNTAS
	DBSELECTAREA("SX1")
	DBSETORDER(1) //NAO TROCAR
	DBSEEK("A")
	nTamSx1 := LEN(SX1->X1_GRUPO)
	cPerg := PADR(cperg,nTamSx1)

// POSICIONA NO SX1
	DbSelectArea("SX1")
	dbSetOrder(1)//NAO TROCAR

	if Len(aRegs) > 0
		For i := 1 to Len(aRegs)
			aRegs[i,2] := PADR(aRegs[i,2],nTamSx1)
			If !dbSeek(cPerg+aRegs[i,2])
				RecLock("SX1",.T.)
				For j:=1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next
				MsUnlock()
				dbskip()
			Else
				If !(ALLTRIM(aRegs[i,3]) == ALLTRIM(SX1->X1_PERGUNT))
					RecLock("SX1",.F.)
					For j:=1 to FCount()
						If j <= Len(aRegs[i])
							FieldPut(j,aRegs[i,j])
						Endif
					Next
					MsUnlock()
				Endif
				dbskip()
				do while alltrim(cPerg)==alltrim(SX1->X1_GRUPO) .and. alltrim(aRegs[i,2]) == alltrim(SX1->X1_ORDEM)
					RecLock("SX1",.F.)
					delete
					MsUnlock()
					dbskip()
				enddo
			Endif
		Next
		do while cPerg==SX1->X1_GRUPO
			RecLock("SX1",.F.)
			delete
			MsUnlock()
			dbskip()
		enddo
	endif

	RestArea(aARea)
Return cPerg

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥POSNICK	∫ Autor ≥ Eduardo Brust      ∫ Data ≥ 11/01/10	  ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥SUBSTITUI O PERGUNTE DO PADRAO							  ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Uso       ≥ORTOBOM			                                          ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function POSNICK(cAlias,cIndice,cChave,cRetorno)
	Local aArea	:= GetArea() // guardo area ativa
	Local cRetorno2
	Local cNickName := ""
	Local cvar := ""
	Local cCampo := " "
	Private cIndice2 := cIndice
	Private cTipo := ALLTRIM(type("cIndice2"))

//cAlias = TABELA A SER LOCALIZADA EX: SC5
//cIndice = INDICE QUE SERA USADO EX : 1
//cChave = CHAVE DE PESQUISA EX: xFilial("SC5")+SC9->C9_PEDIDO
//cRetorno = CAMPO QUE SERA RETORNADO EX: C5_CLIENTE
cCampo := ALLTRIM(cAlias) + "->" + cRetorno

//Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"")
	IF cTipo == "N"
		cvar := ALLTRIM(STR(cIndice2))
	ELSE
		cvar := ALLTRIM(cIndice2)
	ENDIF

	dbSelectArea("SIX")
	dbSetOrder(1)
	if dbseek(ALLTRIM(cAlias)+cvar)
		cNickName := SIX->NICKNAME
	endif

	DBSELECTAREA(cAlias)
	DBORDERNICKNAME(cNickName)
	DBSEEK(cChave)
	cRetorno2 := &cCampo

	RestArea(aARea)
Return cRetorno2

	*---------------------------------------*
User Function cf_PutSx1(cPerg,aSx1,lExcl)
	*---------------------------------------*
	Local nLin,nCol,cCampo
	lExcl := If( lExcl==Nil , .F. , lExcl )
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	SX1->(DbSetOrder(1))

	If !lExcl.And.SX1->(DbSeek(cPerg+aSx1[Len(aSx1),2]))
		Return
	EndIf

	SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. Alltrim(SX1->X1_GRUPO) == cPerg
		SX1->(RecLock("SX1",.F.,.F.))
		SX1->(DbDelete())
		SX1->(MsUnLock())
		SX1->(DbSkip())
	End
	For nLin := 2 To Len(aSX1)
		SX1->(RecLock("SX1",.T.))
		For nCol := 1 To Len(aSX1[1])
			cCampo := "X1_"+aSX1[1,nCol]
			SX1->(FieldPut(SX1->(FieldPos(cCampo)),aSx1[nLin,nCol] ))
		Next nCol
		SX1->(MsUnLock())
	Next nLin
Return

	*-------------------------------------------------------------------------*
User Function cf_PrnGrafic(oPrn,cLogo,aCab,aLin1,aLin2,aLin3,aLin4,aBox,;
		aCabBox,cForm,lGrid,lPageDeAte,lLandScape,lEnd,;
		oBrush,lSubTit,aGrpBox,aCabFnt)
	*-------------------------------------------------------------------------*
	Local nLinhas := 0
	Local nCntPag,nCntBox, nCntCab := 0
	Local lAjuste := .F.
	Local nCnt,nCntLin,aDadLin
	Local aMargens, aBTit, aBPag

	cLogo      := If(cLogo      == Nil, ""              , cLogo      )
	aCab       := If(aCab       == Nil, {""}            , aCab       )
	cForm      := If(cForm      == Nil, "FOR XXXX R.00" , cForm      )
	lLandScape := If(lLandScape == Nil, .F.             , lLandScape )
	lPageDeAte := If(lPageDeAte == Nil, .F.             , lPageDeAte )
	lBox       := If(aBox       == Nil, .F.             , .T.        )
	lCabBox    := If(aCabBox    == Nil, .F.             , .T.        )
	lGrid      := If(lGrid      == Nil, .F.             , lGrid      )
	lEnd       := If(lEnd       == Nil, .F.             , lEnd       )
	lSubTit    := If(lSubTit    == Nil, .F.             , lSubTit    )
	nLinhas    += If(aLin1      == Nil, 0               , 1          )
	nLinhas    += If(aLin2      == Nil, 0               , 1          )
	nLinhas    += If(aLin3      == Nil, 0               , 1          )
	nLinhas    += If(aLin4      == Nil, 0               , 1          )
	aGrpBox    := If(aGrpBox    == Nil, {}              , aGrpBox    )

	oFnt08  := TFont():New("Arial",,08,,.F.,,,,.F.,.F.)
	oFnt10  := TFont():New("Arial",,10,,.F.,,,,.F.,.F.)
	oFnt10N := TFont():New("Arial",,10,,.T.,,,,.F.,.F.)
	oFnt12N := TFont():New("Arial",,12,,.T.,,,,.F.,.F.)
	oFnt14N := TFont():New("Arial",,14,,.T.,,,,.F.,.F.)

	aCabFnt    := If(aCabFnt == Nil, {oFnt10N,100} , aCabFnt )
	oFntCab    := aCabFnt[1]
	nLenCab    := aCabFnt[2]

	If lLandScape
		oPrn:SetLandScape()
		aMargens := {0050, 0050, 2300, 3300}
		aBTit    := {0455, 0220, 2895, 1675}
		aBPag    := {2900, 0220, 0115, 3097}
	Else
		oPrn:SetPortrait()
		aMargens := {0050, 0050, 3300, 2300}
		aBTit    := {0455, 0220, 1895, 1150}
		aBPag    := {1900, 0220, 0115, 2097}
	EndIf

	m_pag++

	If !lEnd
		cNumPag := "PAG: "+StrZero(m_pag,4)+If(lPageDeAte,"/"+StrZero(nPages,4),"")
		oPrn:StartPage()
	Else
		For nCntPag := 1 To oPrn:nPage
			oPrn:SetPage(nCntPag)
			cNumPag := "PAG: "+StrZero(nCntPag,4)+If(lPageDeAte,"/"+StrZero(oPrn:nPage,4),"")
			oPrn:Say(aBPag[3], aBPag[4], cNumPag, oFnt10N,,,,2)             //Impressao do Numero da Pagina.
		Next //nCntPag
		Return(nLin)
	EndIf

	oPrn:Box(aMargens[1], aMargens[2], aMargens[3], aMargens[4])    //Box da Pagina
	oPrn:Box(aMargens[1]+5, aMargens[2]+5, 0220, 0450)              //Box do Logotipo
//oPrn:SayBitmap(0060, 0090, cLogo, 0300, 0150)                   //Impressao do Logotipo
	oPrn:Say(0115, 0175, FunName(), oFnt10N,,,,2)             //Impressao do Numero da Pagina.
	oPrn:Box(aMargens[1]+5, aBTit[1], aBTit[2], aBTit[3])           //Box do Titulo do Relatorio

	nLin :=If(Len(aCab)>1,25,50)

	For nCnt := 1 To Len(aCab)
		nLin+=60
		oPrn:Say(nLin,aBTit[4],aCab[nCnt],oFnt12N,,,,2)             //Impressao do Titulo
	Next nCnt

	oPrn:Box(aMargens[1]+5, aBPag[1], aBPag[2], aMargens[4]-5)      //Box do Numero da Pagina
	If !lEnd
		oPrn:Say(aBPag[3], aBPag[4], cNumPag, oFnt10N,,,,2)             //Impressao do Numero da Pagina.
	EndIf

	nLin := 220

	For nCntLin := 1 To nLinhas
		aDadLin := AClone(&("aLin"+Str(nCntLin,1)))
		If !aDadLin[1][Len(aDadLin[1])-1] .And. m_pag != 1
			lAjuste := .T.
			Loop
		EndIf
		lAjuste := .F.
		nLin += If(aDadLin[1][Len(aDadLin[1])],5,0)
		nLinFim := nLin + 20
		nLinDir := nLinFim
		nLinEsq := nLinFim
		lSomDir := .F.
		lSomEsq := .F.
		For nCnt := 1 To Len(aDadLin)
			nLinFim+=40
			If aDadLin[nCnt][Len(aDadLin[nCnt])]
				If Empty(aDadLin[nCnt][1])
					lSomDir := .T.
				EndIf
				If Empty(aDadLin[nCnt][2])
					lSomEsq := .T.
				EndIf
			Else
				lSomDir := .F.
				lSomEsq := .F.
			EndIf
		Next nCnt
		nLinFim += 40
		If aDadLin[1][Len(aDadLin[1])]
			oPrn:Box(nLin, aMargens[1]+5, nLinFim, aMargens[4]/2)   //Box da linha 1 (1 Metade)
			oPrn:Box(nLin, aMargens[4]/2, nLinFim, aMargens[4]-5)   //Box da linha 1 (2 Metade)
		Else
			oPrn:Box(nLin, aMargens[1]+5, nLinFim, aMargens[4]-5)   //Box da linha 1 (Inteira)
		EndIf
		nLinDir+= If(lSomDir,30,10)
		nLinEsq+= If(lSomEsq,30,10)
		For nCnt := 1 To Len(aDadLin)
			If aDadLin[nCnt][Len(aDadLin[nCnt])]
				oPrn:Say(nLinDir, aMargens[1]+15    , aDadLin[nCnt][1], oFnt10N,,,,)
				oPrn:Say(nLinEsq, (aMargens[4]/2)+10, aDadLin[nCnt][2], oFnt10N,,,,)
			Else
				oPrn:Say(nLinDir, aMargens[1]+15, aDadLin[nCnt][1], oFnt10N,,,,)
				nLinDir+= 20
				nLinEsq+= 20
			EndIf
			nLinDir+= 40
			nLinEsq+= 40
		Next nCnt
		nLin:=nLinFim+If(nCntLin!=1,5,0)
	Next nCntLin

	nLin+=If(lAjuste,5,0)
	nLinAnt := nLin
	If lGrid
		For nCntBox := 1 To Len(aBox)
			For nCnt := 1 To Len(aBox[nCntBox])-1
				oPrn:Box(nLin, aBox[nCntBox][nCnt], nLin+nLenCab, aBox[nCntBox][nCnt+1])
				If oBrush != Nil
					oPrn:FillRect({nLin+2,aBox[nCntBox][nCnt]+02,nLin+(nLenCab-1),aBox[nCntBox][nCnt+1]-02}, oBrush )
				EndIf
			Next nCnt
			nLin += If( Len(aBox) > 1 .And. nCntBox < Len(aBox) .And. lSubTit , (nLenCab+5) , 0 )
		Next nCntBox
	EndIf
	nLin     := nLinAnt
	nSkipLin := (nLenCab/3)
	If lCabBox
		nLin+= nSkipLin
		For nCntCab := 1 To Len(aCabBox)
			For nCnt := 1 To Len(aCabBox[nCntCab])
				If ValType(aCabBox[nCntCab][nCnt])=="A"
					cFileBmp := If(File(aCabBox[nCntCab][nCnt][1]),aCabBox[nCntCab][nCnt][1],"FALTA.BMP")
					oPrn:SayBitmap(nLinAnt,aBox[nCntCab][nCnt],cFileBmp, aCabBox[nCntCab][nCnt][2], aCabBox[nCntCab][nCnt][3])
				Else
					oPrn:Say(nLin,(aBox[nCntCab][nCnt]+aBox[nCntCab][nCnt+1])/2 ,aCabBox[nCntCab][nCnt],oFntCab,,,,2)
				EndIf
			Next nCnt
			nLin += If( Len(aCabBox) > 1 .And. nCntCab < Len(aCabBox) .And. lSubTit , (nLenCab+5) , 0 )
		Next nCntCab
	EndIf
	nLin+= (nLenCab-5)-nSkipLin //65
	If lGrid
		For nCntBox := If(Len(aBox)>1.And.lSubTit,Len(aBox),1) To Len(aBox)
			For nCnt := 1 To Len(aBox[nCntBox])-1
				oPrn:Box(nLin,aBox[nCntBox][nCnt],aMargens[3]-5,aBox[nCntBox][nCnt+1])
			Next nCnt
		Next nCntBox
		For nCnt := 1 To Len(aGrpBox)
			oPrn:FillRect({nLinAnt       ,aGrpBox[nCnt][1]   ,aMargens[3]-5,aGrpBox[nCnt][1]+10},aGrpBox[nCnt][3])
			If nCnt == Len(aGrpBox)
				oPrn:FillRect({nLinAnt       ,aGrpBox[nCnt][2]-10,aMargens[3]-5,aGrpBox[nCnt][2]   },aGrpBox[nCnt][3])
			EndIf

			oPrn:FillRect({nLinAnt       ,aGrpBox[nCnt][1]   ,nLinAnt+10   ,aGrpBox[nCnt][2]   },aGrpBox[nCnt][3])
			oPrn:FillRect({aMargens[3]-15,aGrpBox[nCnt][1]   ,aMargens[3]-5,aGrpBox[nCnt][2]   },aGrpBox[nCnt][3])

			oPrn:FillRect({nLin          ,aGrpBox[nCnt][1]   ,nLin+10      ,aGrpBox[nCnt][2]   },aGrpBox[nCnt][3])
		Next nCnt
		nLin+=20
	EndIf

	oPrn:Say(aMargens[3]+10,055,cForm,oFnt08)
Return(nLin)
	*********************************
User Function PICTIE(cIE,cEST)
	*********************************
	if cEST=="SP"
		cIE:=Transform(cIE,"@R 999.999.999.999")
	else
		if cEST=="MT"
			cIE:=Transform(cIE,"@R 99.999.999-9")
		endif
	endif
Return(cIE)

	*********************************
User Function TABPAR(cUsu,cPrg,aPar)
	*********************************
	Local cQry:=""
	Local i   :=0
	if len(aPar)>0
		cQry:="MERGE INTO TABPAR USING DUAL ON (USU = '"+cUSU+"' AND PRG = '"+cPrg+"')
		cQry+="WHEN MATCHED THEN UPDATE SET "
		for i:=1 to len(aPar)
			cQry+=" MV_PAR"+strzero(i,2)+" = '"+aPar[i]+"'"
			if i < len(aPar)
				cQry+=", "
			endif
		next
		cQry+=" WHEN NOT MATCHED THEN INSERT (USU, PRG"
		for i:=1 to len(aPar)
			cQry+=", MV_PAR"+strzero(i,2)
		next
		cQry+=") VALUES ('"+cUSU+"','"+cPrg+"'
		for i:=1 to len(aPar)
			cQry+=", '"+aPar[i]+"' "
		next
		cQry+=") "
		memowrit("c:\tabpar.sql",cQry)
		Begin Transaction
			TCSQLExec(cQry)
		End Transaction
	endif
Return()
	*************************************
User Function DELPAR(cUsu,cPrg)
	*************************************
	Local cQry:="DELETE TABPAR WHERE USU = '"+cUSU+"' AND PRG = '"+cPrg+"'"
	Begin Transaction
		TCSQLExec(cQry)
	End Transaction
Return()
	*************************************
User Function LIBCOBOL()
	*************************************
//PREPARE ENVIRONMENT EMPRESA "05" FILIAL "02"
	Local aArea:=GetArea()
	Local aSC5 :=GetArea()
	Local i:=0
	dbselectarea("SC5")
	aSC5 :=GetArea()
	dbsetorder(1)
	_aDir := DIRECTORY('\cobol\cobol\'+cEmpAnt+"\msiga\exc*.txt","S")
	for i:=1 to len(_aDir)
		cPed:=substr(_aDir[i,1],4,6)
		if dbseek(xFilial("SC5")+cPed)
			reclock("SC5",.F.)
			SC5->C5_XFUNCAO:=" "
			SC5->C5_XDTLIB :=ctod("  /  /  ")
			msunlock()
		endif
		ferase("\cobol\cobol\"+cEmpAnt+"\msiga\exc"+alltrim(cped)+".txt ")
	next
	_aDir := DIRECTORY('\cobol\cobol\'+cEmpAnt+"\msiga\can*.txt","S")
	for i:=1 to len(_aDir)
		cPed:=substr(_aDir[i,1],4,6)
		dbselectarea("SC5")
		dbsetorder(1)
		if dbseek(xFilial("SC5")+cPed) .AND. SC5->C5_XOPER <> "99"
			reclock("SC5",.F.)
			SC5->C5_XOPERAN :=SC5->C5_XOPER
			SC5->C5_XOPER   :="99"
			SC5->C5_XDTLIB  := dDataBase
			SC5->C5_XOBSLIB := "PEDIDO CANCELADO EM " + DTOC(dDataBase) + " PELO AQUIVO " + _aDir[i,1]
			MsUnLock()
			DbSelectArea("SC6")
			dbOrderNickName("PSC61")
			DbSeek(xFilial("SC6") + cPed)
			While !Eof() .And. SC6->C6_NUM == cPed
				RecLock("SC6",.F.)
				SC6->C6_BLQ     := "R"
				MsUnLock()
				DbSkip()
			EndDo
		endif
		ferase("\cobol\cobol\"+cEmpAnt+"\msiga\can"+alltrim(cped)+".txt ")
	next
	_aDir := DIRECTORY('\cobol\cobol\'+cEmpAnt+"\msiga\des*.txt","S")
	for i:=1 to len(_aDir)
		cPed:=substr(_aDir[i,1],4,6)
		dbselectarea("SC5")
		dbsetorder(1)
		if dbseek(xFilial("SC5")+cPed) .AND. SC5->C5_XOPERAN <> "99" .AND. SC5->C5_XOPERAN <> "  "
			reclock("SC5",.F.)
			SC5->C5_XOPER   :=SC5->C5_XOPERAN
			SC5->C5_XDTLIB  :=ctod("  /  /  ")
			SC5->C5_XOBSLIB := "PEDIDO RECUPERADO EM " + DTOC(dDataBase) + " PELO AQUIVO " + _aDir[i,1]
			MsUnLock()
			DbSelectArea("SC6")
			dbOrderNickName("PSC61")
			DbSeek(xFilial("SC6") + cPed)
			While !Eof() .And. SC6->C6_NUM == cPed
				RecLock("SC6",.F.)
				SC6->C6_BLQ     := " "
				MsUnLock()
				DbSkip()
			EndDo
		endif
		ferase("\cobol\cobol\"+cEmpAnt+"\msiga\des"+alltrim(cped)+".txt ")
	next

	_aDir := DIRECTORY('\cobol\cobol\'+cEmpAnt+"\msiga\lib*.txt","S")
	for i:=1 to len(_aDir)
		cPed:=substr(_aDir[i,1],4,6)
		dbselectarea("SC5")
		dbsetorder(1)
		nHdl:=fcreate('\cobol\cobol\'+cEmpAnt+"\msiga\lib"+cPed+".read")
		fclose(nHdl)
		if dbseek(xFilial("SC5")+cPed)
			nHdl:=fcreate('\cobol\cobol\'+cEmpAnt+"\msiga\lib"+cPed+".found")
			fclose(nHdl)
			reclock("SC5",.F.)
			SC5->C5_XDTLIB  :=dDataBase
			if SC5->C5_XOPER == "99" .and. !empty(SC5->C5_XOPERAN)
				SC5->C5_XOPER := SC5->C5_XOPERAN
			endif
			SC5->C5_XOBSLIB :="LIBERADO PELO COBOL EM " + DTOC(dDataBase) + " PELO AQUIVO " + _aDir[i,1]
			MsUnLock()
			DbSelectArea("SC6")
			dbOrderNickName("PSC61")
			DbSeek(xFilial("SC6") + cPed)
			While !Eof() .And. SC6->C6_NUM == cPed
				RecLock("SC6",.F.)
				SC6->C6_BLQ     := " "
				MsUnLock()
				DbSkip()
			EndDo
		endif
		nHdl:=fcreate('\cobol\cobol\'+cEmpAnt+"\msiga\lib"+cPed+".erase")
		fclose(nHdl)
		ferase("\cobol\cobol\"+cEmpAnt+"\msiga\lib"+alltrim(cped)+".txt ")
	next

	_aDir := DIRECTORY('\cobol\cobol\'+cEmpAnt+"\msiga\lit*.txt","S")
	for i:=1 to len(_aDir)
		cPed:=substr(_aDir[i,1],4,6)
		dbselectarea("SC5")
		dbsetorder(1)
		nHdl:=fcreate('\cobol\cobol\'+cEmpAnt+"\msiga\lit"+cPed+".read")
		fclose(nHdl)
		if dbseek(xFilial("SC5")+cPed)
			nHdl:=fcreate('\cobol\cobol\'+cEmpAnt+"\msiga\lit"+cPed+".found")
			fclose(nHdl)
			reclock("SC5",.F.)
			SC5->C5_XDTLIB  :=ctod("  /  /  ")
			SC5->C5_XOBSLIB :="ESTORNO DE LIBERACAO PELO COBOL EM " + DTOC(dDataBase) + " PELO AQUIVO " + _aDir[i,1]
			MsUnLock()
		endif
		nHdl:=fcreate('\cobol\cobol\'+cEmpAnt+"\msiga\lit"+cPed+".erase")
		fclose(nHdl)
		ferase("\cobol\cobol\"+cEmpAnt+"\msiga\lit"+alltrim(cped)+".txt ")
	next


	RestArea(aSC5)
	RestArea(aArea)
Return()

	***************************
User Function CalFrt5(cCarga,cNota,lRetArray)
	***************************
	Local cMsg  :=""
	Local nFrete:=0
	Local nBase :=0
	Local nICM  :=0
	Local _aret := {}
	Local aArea:=GetArea()
	Default lRetArray := .F.

	dbselectarea("SZQ")
	dbsetorder(1)
	if dbseek(xFilial("SZQ")+cCarga) .and. SZQ->ZQ_VALOR > 0
		if SZQ->ZQ_KILOMET > 0 .and. SZQ->ZQ_VALORKM > 0
			nFrete:=Round((SF2->F2_VALBRUT/SZQ->ZQ_VALOR)*(SZQ->ZQ_KILOMET*SZQ->ZQ_VALORKM),2)
		else
			nFrete:=Round((SF2->F2_VALBRUT/SZQ->ZQ_VALOR)*(SZQ->ZQ_VALOR*SZQ->ZQ_PERFRET/100),2)
		endif
		if nFrete > 0
			IF SF2->F2_BASEICM < SF2->F2_VALMERC
				nBase :=round(nFrete*0.5883,2)
			else
				nBase :=nFrete
			endif
			_lContrib := .T.
			If SF2->F2_TIPO $ ('B|D')
				IF SA2->(FieldPos("A2_CONTRIB")) > 0 .And. SA2->A2_CONTRIB == '2'
					_lContrib := .F.
				EndIF
			Else
				IF SA1->(FieldPos("A1_CONTRIB")) > 0 .And. SA1->A1_CONTRIB == '2'
					_lContrib := .F.
				EndIF
			EndIf

			cPerf := "17%"

			//SSI 35368
			IF SUBSTR(SF3->F3_CFO,1,1) $ "6" .And. _lContrib
				nPerf := 12 //FORA DO ESTADO 12%
//			nICM  :=Round(nBase*0.12,2) //FORA DO ESTADO 12%
				cPerf := "12%"
			ELSE //IF !_lContrib
				nPerf := 17
//			nICM  :=Round(nBase*0.17,2)//DENTRO DO ESTADO 17%
				cPerf := "17%"
			ENDIF
			nICM  :=Round(nBase*nPerf/100,2) //FORA DO ESTADO 12%
			If nICM > 0
				// Henrique - 20/04/2017
				// Includo IF para atender a SSI 36996
				If !cEmpAnt$"05|25" .OR. (cEmpAnt$"05|25" .AND. _lContrib)
					cMsg:="Valor Frete: "+Transform(nFrete,"@E 999,999.99")+" Base Calculo: "+Transform(nBase,"@E 999,999.99")+" Aliquota ICMS: "+cPerf+" Valor Icms: "+Transform(nICM,"@E 999,999.99")
				EndIf
			EndIF

			IF SUBSTR(SF3->F3_CFO,1,1) <> "6" .And. _lContrib
				_aret := {0,0,0,0}
			Else
				_aret := {nFrete,nBase,nPerf,nICM}
			EndIF
		endif
	endif
	RestArea(aArea)

	If len(_aret) = 0
		_aret := {0,0,0,0}
	EndIF

	If lRetArray
		Return(_aret)
	EndIF
Return(cMsg)


//CALCULO DE FRETE PARA UNIDADE 06
//29/07/11 CONFORME SSI 19515-SOLICITADO PELO EMANUAL(UNID 06) [ EDUARDO BRUST]
	***************************
User Function fCalf06(cCarga,cNota)
	***************************
	Local cMsg  :=""
	Local nFrete:=0
	Local nBase :=0
	Local nICM  :=0
	Local aArea:=GetArea()
	Local cQuery := ""
	dbselectarea("SZQ")
	dbsetorder(1)

	if dbseek(xFilial("SZQ")+cCarga) .and. SZQ->ZQ_VALOR > 0 .And. Alltrim(SF2->F2_TPFRETE) <> "F"

		cQuery:="SELECT SUM(F2_VALMERC) VALMERC "
		cQuery+="FROM SIGA."+RetSQLName("SF2")+" SF2, SIGA."+RetSQLName("SZQ")+" SZQ, SIGA."+RetSQLName("SC5")+" SC5 "
		cQuery+="WHERE ZQ_FILIAL = '"+xFilial("SZQ")+"' "
		cQuery+="AND F2_FILIAL = '"+xFilial("SF2")+"' "
		cQuery+="AND C5_FILIAL = '"+xFilial("SC5")+"' "
		cQuery+="AND SF2.D_E_L_E_T_ = ' '  "
		cQuery+="AND SZQ.D_E_L_E_T_ = ' ' "
		cQuery+="AND SC5.D_E_L_E_T_ = ' ' "
		cQuery+="AND C5_NOTA = F2_DOC "
		cQuery+="AND C5_SERIE = F2_SERIE "
		cQuery+="AND C5_XEMBARQ = '"+cCarga+"' "
		cQuery+="AND C5_XEMBARQ = ZQ_EMBARQ "
		memowrit("C:\calcfrt06.sql",cQuery)
		tcQuery cQuery alias "QRYFRE" new
		dbselectarea("QRYFRE")

		If SZQ->ZQ_KILOMET > 0 .and. SZQ->ZQ_VALORKM > 0
			//nFrete:=Round((SF2->F2_VALBRUT/SZQ->ZQ_VALOR)*(SZQ->ZQ_KILOMET*SZQ->ZQ_VALORKM),2)
			nFrete:=Round((SF2->F2_VALMERC/QRYFRE->VALMERC)*(SZQ->ZQ_KILOMET*SZQ->ZQ_VALORKM),2)

		else
//		nFrete:=Round((SF2->F2_VALBRUT/SZQ->ZQ_VALOR)*(SZQ->ZQ_VALOR*SZQ->ZQ_PERFRET/100),2)
//		nFrete:=Round((SF2->F2_VALBRUT/SZQ->ZQ_VALOR)*SZQ->ZQ_VALFRET,2)		//'01' - PRACA SSI-4477
			nFrete:=Round((SF2->F2_VALMERC/QRYFRE->VALMERC)*SZQ->ZQ_VALFRET,2)		//SSI 19393
		endif
		if nFrete > 0
			nBase :=nFrete
			cPerf := "17%"
			//CONFORME SSI 25713 APROVADA PELO SR CRUZ
			IF SUBSTR(SF3->F3_CFO,1,1) $ "6"
				nICM  :=Round(nBase*0.12,2) //FORA DO ESTADO 12%
				cPerf := "12%"
			ELSE
				nICM  :=Round(nBase*0.17,2)//DENTRO DO ESTADO 17%
				cPerf := "17%"
			ENDIF
			cMsg:="Valor Frete.: "+Transform(nFrete,"@E 999,999.99")+" Base Calculo: "+Transform(nBase,"@E 999,999.99")+" Aliquota ICMS: "+cPerf+" Valor Icms: "+Transform(nICM,"@E 999,999.99")
		endif
		dbselectarea("QRYFRE")
		DbCloseArea()
	endif
	RestArea(aArea)
Return(cMsg)


	***************************
User Function FCFrt04(cCarga,cNota)
	***************************
	Local cMsg  :=""
	Local nFrete:=0
	Local nBase :=0
	Local nICM  :=0
	Local aArea:=GetArea()
	dbselectarea("SZQ")
	dbsetorder(1)
	if dbseek(xFilial("SZQ")+cCarga) .and. SZQ->ZQ_VALOR > 0
		if SZQ->ZQ_KILOMET > 0 .and. SZQ->ZQ_VALORKM > 0
			nFrete:=Round((SF2->F2_VALBRUT/SZQ->ZQ_VALOR)*(SZQ->ZQ_KILOMET*SZQ->ZQ_VALORKM),2)
		else
			nFrete:=Round((SF2->F2_VALBRUT/SZQ->ZQ_VALOR)*(SZQ->ZQ_VALOR*SZQ->ZQ_PERFRET/100),2)
		endif
		if nFrete > 0
			nBase :=round(nFrete*0.8,2)
			nICM  :=Round(nBase*0.18,2)
			cMsg:="ICMS relativo a prestacao de responsabilidade do remetente conforme artigo 4 anexo XV RICMS/02 \"
			cMsg+="Valor Frete: "+Transform(nFrete,"@E 999,999.99")+" Base Calculo: "+Transform(nBase,"@E 999,999.99")+" Aliquota ICMS: 18% Valor Icms: "+Transform(nICM,"@E 999,999.99")
		endif
	endif
	RestArea(aArea)
Return(cMsg)

	***************************
User Function FCFrt06(cPed)
	***************************
	Local cMsg  :=""
	Local nBase :=0
	Local nICM  :=0
	Local aArea:=GetArea()
	Local cQuery:="SELECT SUM(ROUND( (D2_TOTAL * A1_XPERFRE/100) * (100-D2_PICM)/100, 2)) VLFRE, SUM(D2_TOTAL) VLRNF, D2_PICM, D2_EST   "
	cQuery+="   FROM "+RetSQLName("SA1")+" SA1, "+RetSQLName("SD2")+" SD2, "+RetSQLName("SC5")+" SC5 "
	cQuery+="  WHERE SA1.D_E_L_E_T_ = ' '                                                        "
	cQuery+="    AND SD2.D_E_L_E_T_ = ' '                                                        "
	cQuery+="    AND SC5.D_E_L_E_T_ = ' '                                                        "
	cQuery+="    AND C5_NUM = "+cPed+" "
	cQuery+="    AND C5_TPFRETE = 'C' "
	cQuery+="    AND C5_NUM = D2_PEDIDO   "
	cQuery+="    AND C5_CLIENTE = A1_COD  "
	cQuery+="    AND C5_LOJACLI = A1_LOJA  "
	cQuery+="    AND D2_FILIAL  = '"+xFilial("SD2")+"'                                       "
	cQuery+="    AND A1_FILIAL  = '"+xFilial("SA1")+"'                                       "
	cQuery+="    AND C5_FILIAL  = '"+xFilial("SC5")+"'                                       "
	cQuery+="   GROUP BY D2_PICM, D2_EST "
	memowrit("C:\calcfrt05.sql",cQuery)
	tcQuery cQuery alias "QRYFRE" new
	dbselectarea("QRYFRE")
	dbgotop()
	nBase :=QRYFRE->VLFRE
	nAliq :=QRYFRE->D2_PICM
	cEst  :=QRYFRE->D2_EST
	dbclosearea()
	RestArea(aArea)
	if nBase > 0
		if nAliq==0
			if cEst=="MT"
				nAliq:=17
			else
				nAliq:=12
			endif
		endif
		nICM  :=Round(nBase*nAliq/100,2)
		cMsg:="Valor Frete: "+Transform(nBase,"@E 999,999.99")+" Base Calculo: "+Transform(nBase,"@E 999,999.99")+" Aliquota ICMS: "+Transform(nAliq,"@E 99")+"% Valor Icms: "+Transform(nICM,"@E 999,999.99")
	endif
	RestArea(aArea)
Return(cMsg)


/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥VALITISZH ∫ Autor ≥ MARCIO WILLIAM     ∫ Data ≥  13/07/10   ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥ LIMPA O CAMPO ZH_REFTAB TODA VEZ QUE O CAMPO ZH_ITINER     ∫±±
	±±∫          ≥ FOR ALTERADO.                                              ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

User Function VALITISZH()


	dbSelectArea("SZH")

	if altera

		IF M->ZH_ITINER <> SZH->ZH_ITINER
			RecLock("SZH",.F.)
			M->ZH_REFTAB :=" "
			MSUNLOCK()

		ENDIF
	endif

return .T.

	*************************
User Function ValForm()
	*************************
	Local lRet:=.F.
	Local cUsu:=alltrim(cUserName)
	if cUsu == "Admin" .or. cUsu <> "alessandro.03" .or. cUsu <> "andre.20" .or. cUsu <> "brust.20" .or. cUsu <> "dupim"
		lRet:=.T.
	else
		if at('.OR.',UPPER(M->M4_FORMULA))==0 .and. at('.AND.',UPPER(M->M4_FORMULA))==0
			if substr(M->M4_FORMULA,1,1)=='"' .and. substr(M->M4_FORMULA,len(alltrim(M->M4_FORMULA)),1)=='"'
				lRet:=.T.
			else
				if substr(M->M4_FORMULA,1,1)=="'" .and. substr(M->M4_FORMULA,len(alltrim(M->M4_FORMULA)),1)=="'"
					lRet:=.T.
				endif
			endif
		endif
	endif
Return(lRet)

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥fValSenha ∫ Autor ≥ EDUARDO BRUST      ∫ Data ≥  13/07/10   ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥ Funcao que valida senha para liberacao de rotinas 	      ∫±±
	±±∫          ≥ 				                                              ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
	*************************************
User Function fValSenha(cTitulo,cTexto,_cGrpLib2)
	*************************************
	Local cMsg := SUBSTR(cTexto,1,30)
	Private _cCadastro	:= cTitulo
	Private _nOpc 		:= 1
	Private _xLib 		:= .F.
	Private _cUserLib	:= Space(20)
	Private _cPassLib	:= Space(50)
	Private _cGrpLib    := _cGrpLib2 // grupo que sera liberado
	Private _vRet       := .F.
	Private oDialUsu


	DEFINE MSDIALOG oDialUsu TITLE OemToAnsi(_cCadastro) FROM 200,1 TO 370,340 PIXEL

	@ 02,10 TO 065,160
	@ 10,018 Say "Informe o Usuario e Senha para Liberacao de digitacao" PIXEL OF oDialUsu
	@ 18,018 Say cMsg PIXEL OF oDialUsu
	@ 35,018 Say " Usuario "  PIXEL OF oDialUsu
	@ 50,018 Say " Senha   "  PIXEL OF oDialUsu
	@ 34,045 GET _cUserLib          Picture "@X" SIZE 50,10 PIXEL OF oDialUsu
	@ 49,045 GET _cPassLib PASSWORD Picture "@X" SIZE 40,10 PIXEL OF oDialUsu

	@ 70,095 BUTTON "&OK"      Size 030,010 ACTION fSenhaDig() PIXEL OF oDialUsu
	@ 70,130 BUTTON "Ca&ncela" Size 030,010 ACTION oDialUsu:End() PIXEL OF oDialUsu

	Activate Dialog oDialUsu Centered

Return ({_vRet,_cUserLib})

	***************************
Static Function fSenhaDig()
	***************************
	If fUsuLib()
		oDialUsu:End()
		_vRet := .T.
		Return(.T.)
	EndIf

Return(.F.)

	*******************************************************************************
	* Funcao : fUsuLib()    		* Autor : Cleverson Luiz Schaefer * Data : 15/09/2006 *
	*******************************************************************************
	* Descricao : Tela para validaÁ„o por senha de usu·rio Superior caso consu-   *
	*******************************************************************************

Static Function fUsuLib()
	*************************

	Local _aGrupo, _nI, _aInfoUser

	_aInfoUser := {}
	_aGrupo    := {}
	fUser      := .F.
	fGroup     := .F.

	_cOldUsrId 	:= __cUserId //PswID()
	_cNewUsrId 	:= Space(6)

	If ( _cVldSenha( _cUserLib, _cPassLib ) )

		_aInfoUser := PswRet(1)

		// posicao no array para descobrir grupo
		_aGrupo := _aInfoUser[1,10]

		PswOrder(2)

		For _nI := 1 To Len(_aGrupo)
			If _aGrupo[_nI] == _cGrpLib  // Grupo Liberacao
				fGroup := .T.
				Exit
			Endif
		Next
	Else
		fUser := .F.
		MsgBox("Usu·rio ou Senha Inv·lidos: ", "Liberacao de DigitaÁ„o", "INFO")
	Endif

	If !fGroup
		fUser := .F.
		MsgBox("O usuario nao pertence ao grupo de Liberacao :" +_cGrpLib, "Liberacao de DigitaÁ„o", "INFO")
	EndIf


	PswOrder(1)
	PswSeek( _cOldUsrId, .T. )

Return(fUser)

	*******************************************************************************
	* Funcao : _cVldSenha   * Autor : Cleverson Luiz Schaefer * Data : 15/09/2006 *
	*******************************************************************************
	* Descricao : Rotina que valida senha de usuario.                             *
	*******************************************************************************

Static Function _cVldSenha( _cUserLib, _cPassLib )
	**************************************************

	fuser := .F.

	PswOrder(2)

// Pesquisa por usu·rio
	If PswSeek( _cUserLib, .T. )
		fuser := PswName( _cPassLib )
	EndIf

Return(fuser)
	*******************************************************************************
	* Funcao : fBusParc   * Autor : Cesar Dupim                        * Data : 25/08/2010 *
	*******************************************************************************
	* Descricao : Busca Condicao de Pagamento  *
	*******************************************************************************

User Function fBusParc(cParc)
	**************************************************
	Local cBusCp:=""
	Local cQuery:=""
	Local cRec:=""
	Local cCond:=""
	cParc:=Alltrim(cParc)
	if len(cParc) > 3 .and. at(',',cParc)==0
		while len(cParc)>1
			cBuscp+=substr(cParc,1,1)
			cParc :=substr(cParc,2)
			if Len(cParc)%3==0
				cBuscp+=","
			endif
		end
		cBuscp+=substr(cParc,1,1)
	else
		cBusCp:=cParc
	endif
	cQuery := " SELECT R_E_C_N_O_ REC FROM "+RetSqlName("SE4")+" "  //CondiÁ„o de Pagamento
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += "    AND E4_FILIAL  = '" + xFilial("SE4") + "' "
	cQuery += "    AND E4_XCOND    = '" + cBusCP        + "' "
	TCQUERY cQuery ALIAS "QRYSE4" NEW
	DbSelectArea("QRYSE4")
	DbGotop()
	If Eof()
		Alert("Condicao de pagamento inexistente!")
		cRec:=0
	Else
		cRec:=QRYSE4->REC
	endif
	QRYSE4->(DbCloseArea())
	dbselectarea("SE4")
	if cRec>0
		dbgoto(cRec)
		cCond:=SE4->E4_CODIGO
	else
		dbgobottom()
		dbskip()
	endif
Return(cCond)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MarkPA7   ∫Autor  ≥Bruno Costa	     ∫ Data ≥  01/11/07   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Marca tabela de cartoes online com recno de uso, para      ∫±±
±±∫          ≥ saber quais cartoes ja foram usados no sistema.            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫OBS       ≥ Uso deve ser feito antes dos registros serem alterados     ∫±±
±±∫          ≥ pois sera utilizado caso haja alteraÁ„o de cartoes.        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

User Function MarkPA7(cAdm,cAutoriz,cCartao,nOper,cCodCli,cLjCli,nRecno,cOrigem)
	Local aArea := GetArea()
	Local cQry  := ""

	cQry:= " SELECT R_E_C_N_O_ RECNOPA7 "
//cQry+= "   FROM "+RETSQLNAME("PA7")
	cQry+= "   FROM V_PA7UNI "
	cQry+= "  WHERE D_E_L_E_T_ = ' ' "
	cQry+= "    AND PA7_FILIAL = '"+XFILIAL("PA7")+"'"
	cQry+= "    AND PA7_ADM = '"+cAdm+"'"
	cQry+= "    AND PA7_AUTORI = '"+cAutoriz+"'"
	cQry+= "    AND PA7_CARTAO = '"+cCartao+"'"

	MemoWrit("c:\MarkPa7.sql",cQry)

	If Select("TPA7") > 0
		dbSelectArea("TPA7")
		dbCloseArea()
	EndIf

	TcQuery cQry Alias "TPA7" NEW
	dbselectarea("TPA7")

	if !(eof())
		dbSelectArea("PA7")
		PA7->(DbGoto(TPA7->RECNOPA7))
		If nOper == 3
			If !EOF() .And. ( PA7->PA7_EMPRES <> cEmpAnt .Or. PA7->PA7_CODCLI <> cCodCli .Or. PA7->PA7_LOJCLI <> cLjCli .Or. PA7->PA7_RECNO <> nRecno .Or. PA7->PA7_ORIGEM <> cOrigem )
//			TCSPEXEC("REPLICA.SP_REPREC@PROD",TPA7->RECNOPA7)
				RECLOCK("PA7",.F.)
				PA7->PA7_EMPRES:= cEmpAnt
				PA7->PA7_CODCLI:= cCodCli
				PA7->PA7_LOJCLI:= cLjCli
				PA7->PA7_RECNO := nRecno
				PA7->PA7_ORIGEM:= cOrigem
				MSUNLOCK()
			EndIf
		ElseIf nOper ==5
			If !EOF() .And. (!Empty(PA7->PA7_EMPRES) .Or. !Empty(PA7->PA7_CODCLI) .Or. !Empty(PA7->PA7_LOJCLI) .Or. !Empty(PA7->PA7_RECNO) .Or. !Empty(PA7->PA7_ORIGEM))
//			TCSPEXEC("REPLICA.SP_REPREC@PROD",TPA7->RECNOPA7)
				RECLOCK("PA7",.F.)
				PA7->PA7_EMPRES:= ""
				PA7->PA7_CODCLI:= ""
				PA7->PA7_LOJCLI:= ""
				PA7->PA7_RECNO := 0
				PA7->PA7_ORIGEM:= ""
				MSUNLOCK()
			ElseIf EOF()
				//consultando o registro para incluir novamente na PA7.
				cQry:= " SELECT * "
				cQry+= "   FROM SIGA.PA7USA "
				cQry+= "   WHERE D_E_L_E_T_ = ' ' "
				cQry+= "   AND R_E_C_N_O_ = "+aLLTRIM(STR(TPA7->RECNOPA7))+" "

				MemoWrit("c:\MarkPa7.sql",cQry)

				If Select("TPA7I") > 0
					dbSelectArea("TPA7I")
					dbCloseArea()
				EndIf

				TcQuery cQry Alias "TPA7I" NEW
				dbselectarea("TPA7I")
				If !Eof()
					RECLOCK("PA7",.T.)
					PA7->PA7_FILIAL := XFILIAL("PA7")
					PA7->PA7_ADM    := TPA7I->PA7_ADM
					PA7->PA7_AUTORI := TPA7I->PA7_AUTORI
					PA7->PA7_CARTAO := TPA7I->PA7_CARTAO
					PA7->PA7_PV	    := TPA7I->PA7_PV
					PA7->PA7_NOMARQ := TPA7I->PA7_NOMARQ
					PA7->PA7_VALOR  := TPA7I->PA7_VALOR
					PA7->PA7_DESCRI := TPA7I->PA7_DESCRI
					PA7->PA7_DTVEND := STOD(TPA7I->PA7_DTVEND)    //ctod(aRegPA7[I,6])
					PA7->PA7_TOTPAR := TPA7I->PA7_TOTPAR
					PA7->PA7_ADMORI := TPA7I->PA7_ADMORI
					PA7->PA7_POS	:= TPA7I->PA7_POS
					PA7->PA7_RESUMO := TPA7I->PA7_RESUMO
					PA7->PA7_EMPRES:= ""
					PA7->PA7_CODCLI:= ""
					PA7->PA7_LOJCLI:= ""
					PA7->PA7_RECNO := 0
					PA7->PA7_ORIGEM:= ""
					MSUNLOCK()
				Endif

				DbSelectArea("TPA7I")
				DbCloseArea()
				//Deletando o registro da PA7
				cQry:=" DELETE PA7USA  "
				cQry+=" WHERE D_E_L_E_T_ = ' ' "
				cQry+=" AND R_E_C_N_O_ = "+aLLTRIM(STR(TPA7->RECNOPA7))+" "
				TCSQLExec(cQry)
			EndIf
		EndIf
	EndIf

	dbselectarea("TPA7")
	DbCloseArea()

	RestArea(aArea)

Return()


	**********************************
User Function fMixOrdem(cNumPed,lPed)
	**********************************
	Local cQuery:=""
	Local lRet  :=.F.
	Local nRet  :=0
	Private cAtf  	    := GetMv("MV_XEXCATF")  // excecoes ativo fixo
	Private cExc        := GETMV("MV_XEXCEC")   // excecoes
	Private cTrav	    := GetMV("MV_XEXCTRA")  // excecoes travesseiros

	if Empty(cAtf)
		MsgBox("AtenÁ„o bens imobilizados est„o sendo considerados para bloqueio de mix","INFORME SETOR DE T.I.")
	endif

	cQuery:="SELECT COUNT(*) TOTREG, "
//cQuery+="       ROUND(SUM(CASE WHEN C5_XOPER = '05' THEN (C6_QTDVEN *C6_XCUSTO) ELSE (C6_QTDVEN * ( C6_PRCVEN - C6_XCUSTO)) END )/SUM((C6_QTDVEN * C6_PRCVEN)),4)*100  MIX "
	cQuery+=" SUM(CASE WHEN C5_XOPER <> '05' AND C5_XOPERAN <> '05' THEN C6_QTDVEN * C6_PRCVEN ELSE 0 END) VENDA, "
	cQuery+=" SUM(C6_QTDVEN * C6_XCUSTO) CUSTO "

	cQuery+="FROM "+RetSQLName("SC6")+" SC6, "+RetSQLName("SB1")+" SB1, "+RetSQLName("SBM")+" SBM , "+RETSQLNAME("SC5")+" SC5 "
	cQuery+="WHERE SC6.D_E_L_E_T_ = ' ' "
	cQuery+="  AND SB1.D_E_L_E_T_ = ' ' "
	cQuery+="  AND SC5.D_E_L_E_T_ = ' ' "
	cQuery+="  AND SBM.D_E_L_E_T_ = ' ' "
	cQuery+="  AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery+="  AND SC5.C5_FILIAL = '"+xFilial("SC6")+"' "
	cQuery+="  AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery+="  AND SBM.BM_FILIAL = '"+xFilial("SBM")+"' "
	cQuery+="  AND C5_NUM = C6_NUM "
	cQuery+="  AND C5_CLIENTE = C6_CLI "
	cQuery+="  AND C5_LOJACLI = C6_LOJA"
	cQuery+="  AND C6_PRODUTO = B1_COD "
	cQuery+="  AND B1_GRUPO = BM_GRUPO "

	if lPed
		cQuery+="  AND C6_NUM = '"+cNumPed+"'"
	else
		cQuery+="  AND C5_XORDCOM = '"+cNumPed+"'"
		cQuery+="  AND C5_EMISSAO > '"+DTOS(DDATABASE-30)+"' "
	endif

	cQuery+="  AND C6_QTDVEN * C6_PRCVEN>0 "

	if !empty(cAtf)
		cQuery+="  AND C6_TES NOT IN "+cAtf+" "
	endif

/*if !empty(cTrav)
cQuery+="  AND BM_GRUPO NOT IN "+cTrav+" "
endif
if !empty(cExc)
cQuery+="  AND BM_XSUBGRU NOT IN "+cExc+" "
endif
cQuery+="  AND B1_XMODELO <> '000015' "
*/
MemoWrit("C:\ORTALIBC2.SQL",cQuery)
TCQUERY cQuery ALIAS	 "QRY" NEW
dbselectarea("QRY")
dbgotop()
if QRY->TOTREG > 0
	//	if QRY->MIX < SZA->ZA_MIX
	NLB := QRY->VENDA / QRY->CUSTO
	lRet:=.T.
	nRet:= (NLB-1)/NLB
	nRet*=100
	//	endif
endif
dbclosearea()
Return({lRet,nRet})



/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥MATA410   ∫Autor  ≥MARCIO WILLIAM	     ∫ Data ≥  17/01/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Valida o numero da ordem de compra. Campo C5_XORDCOM afim  ∫±±
±±∫          ≥ de forÁar o usuario a gerar uma numeracao na tela ORTA319  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
*******************************
User Function ValOrdCom(cOrdem)
	*******************************

	Local lRes := .F.

	if cOrdem <= GetMV("MV_XNUMORD")
		lres := .T.
	else
		MsgBox("NegociaÁ„o n„o gerada, por favor utilize a rotina de geraÁ„o de negociaÁ„o para gerar uma numeraÁ„o v·lida.","AVISO","INFO")
	endif

return lres

	**********************************************
User Function VerQbrCH(dDataFin,dDataIni,cOrigem)
	**********************************************
	Local cQuebra:=""
	Local nQCH:=0
	Local aQuebra:={}
	Local i:=0
	Local nPos:=0
	Local lAchou:=.F.
	Local cRet:=""
	if cOrigem=="L"
		cQuebra:=GetNewPar("MV_XDIACHL","001D030B090CA") //Padrao para Quebra de Cheque
	else
		cQuebra:=GetNewPar("MV_XDIACHA","001D010B999CA") //Padrao para Quebra de Cheque
	endif
	nQCH:=Len(cQuebra)
	nQCH--
	for i:=1 to nQCH/4
		nPos:=i*4
		aadd(aQuebra,{val(substr(cQuebra,nPos-3,3)),substr(cQuebra,nPos,1)})
	next
	aadd(aQuebra,{0,substr(cQuebra,len(cQuebra),1)})
	i:=1
	while !lachou .and. i<len(aQuebra)
		if dDataFin-dDataIni <= aQuebra[i,1]
			cRet:=aQuebra[i,2]
			lAchou:=.T.
		endif
		i++
	enddo
	if !lAchou
		cRet:=aQuebra[len(aQuebra),2]
	endif
Return(cRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Validacao ∫Autor  ≥MARCIO WILLIAM	     ∫ Data ≥  01/02/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Valida o campo C5_xentreg, para nao permitir a digitacao   ∫±±
±±∫          ≥ de uma data menor que a data de emissao.                   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
	****************************************
User Function VEntIni(dEmis,dEnt)
	****************************************

	Local lret := .T.

	if dEmis > dEnt
		MsgBox("Data de entrega menor que a data de emissao, verifique!","ATEN«√O!","ERRO")
		lRet := .F.
	endif

return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥Validacao ∫Autor  ≥MARCIO WILLIAM	     ∫ Data ≥  01/02/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Valida o campo C5_xentref, para nao permitir a digitacao   ∫±±
±±∫          ≥ de uma data menor que a data de entrega inicial.           ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫          ≥                                                            ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

	**************************************
User Function VEntFim(dEnt,dFin,nCampo)
	**************************************

/*
nCampo = 1 - Validacao do Campo C5_XENTREF com o C5_EMISSAO
nCampo = 2 - Validacao do Campo C5_XENTREF com o C5_XENTREG
*/

	Local lret := .T.

	if nCampo == 1

		if dEnt > dFin
			MsgBox("Periodo de entrega inv·lido, data inicial menor que a de emissao do pedido. Verifique!","ATEN«√O!","ERRO")
			lRet := .F.
		endif

	else

		if dEnt > dFin
			MsgBox("Periodo de entrega inv·lido, data final menor que a data inicial de entrega. Verifique!","ATEN«√O!","ERRO")
			lRet := .F.
		endif


	endif

return lRet

// GLM: George: SSI: 23836: 19/09/2012
// Inclus„o do parametro: _cMsg
	*********************************************************
User Function MontaPedHTML(cPed, cCliente, cLoja, cemail, _cMsg)
///User Function MontaPedHTML(cPed, cCliente, cLoja, cemail)
	*********************************************************

	Local cQry  := ""
	Local cAnexo:= ""

	Local cServer  :="10.0.100.102"
	Local cAccount :="matcompras"
	Local cPassword:="mat9910"

	Local cTel:= ""

/*
Local cServer  :="10.0.100.101"
Local cAccount :="matcompras@uol.com.br"
Local cPassword:="metalo56"
*/

// GLM: George: SSI: 23836: 19/09/2012
// Incluido temporariamente para o dupim verificar o recebimento do email
	Local cCC      := "dupim@ortobom.com.br"
///Local cCC      := ""
	Local cFrom    := "ortobom@ortobom.com.br" //CPD-Regional"
	Local cTo      := cemail//"suportesigo@ortobom.com.br"
	Local cSubject := "[sigo] - Acompanhamento de Pedidos - Colchoes Ortobom" //"RELACAO DE PEDIDO DE COMPRA EM ABERTO "
	Local lOk      :=.F.
	Local cAnexos  :=""
	Local nTot     := 0


	if cEmpant = "03"
		cTel  := " (21) 2107 - 8300"
	endif

	if cEmpant = "05"
		cTel  := " (62) 3265 - 0000"
	endif

	if cEmpant = "06"
		cTel  := " (65) 2123 - 1000"
	endif

	if cEmpant = "16"
		cTel  := " (16) 3352 - 5400"
	endif

	if cEmpant = "22"
		cTel  := " (16) 3352 - 7400"
	endif


	if empty(cped) .or. empty(cCliente) .or. empty(cEmail)
		msgbox("Informe todos os parametros.","ATENCAO","INFO")
		return
	endif

	cQry := " SELECT CASE WHEN B1_XMODELO = '000008' THEN C6_XPRUNIT/5 ELSE C6_XPRUNIT END C6_XPRUNIT , C5_XENTREF , C5_XENTREG, "
	cQry += " C5_NUM , C5_XPEDFIC , A3_COD   , A3_NOME , C6_QTDVEN , C6_PRODUTO , B1_DESC , B1_XMED   , C5_XDTVEND , "
	cQry += " A1_COD , A1_NOME    , A1_END   , A1_CEP  , A1_MUN    , A1_TEL     , A1_DDD  , A1_BAIRRO , A1_EMAIL   "
	cQry += "  FROM "+RETSQLNAME("SA1")+" SA1, "+RETSQLNAME("SB1")+" SB1 , "+RETSQLNAME("SC5")+" SC5,   "
	cQry += " "+RETSQLNAME("SC6")+" SC6 , "+RETSQLNAME("SA3")+" SA3 "
	cQry += " WHERE C5_CLIENTE = A1_COD "
	cQry += " AND C5_LOJACLI = A1_LOJA"
	cQry += " AND C5_NUM = C6_NUM "
	cQry += " AND C5_CLIENTE = C6_CLI "
	cQry += " AND C5_LOJACLI = C6_LOJA"
	cQry += " AND C6_PRODUTO = B1_COD "
	cQry += " AND C5_VEND1   = A3_COD "
	cQry += " AND SA1.D_E_L_E_T_ = ' '"
	cQry += " AND SC5.D_E_L_E_T_ = ' '"
	cQry += " AND SC6.D_E_L_E_T_ = ' '"
	cQry += " AND SB1.D_E_L_E_T_ = ' '"
	cQry += " AND SA3.D_E_L_E_T_ = ' '"
	cQry += " AND A1_FILIAL = '"+XFILIAL("SA1")+"' "
	cQry += " AND A3_FILIAL = '"+XFILIAL("SA3")+"' "
	cQry += " AND B1_FILIAL = '"+XFILIAL("SB1")+"' "
	cQry += " AND C5_FILIAL = '"+XFILIAL("SC5")+"' "
	cQry += " AND C6_FILIAL = '"+XFILIAL("SC5")+"' "
	cQry += " AND C5_NUM = '"+CPED+"'    "
	cQry += " AND A1_COD = '"+CCLIENTE+"'"
	cQry += " AND A1_LOJA= '"+CLOJA+"'   "
	memowrit("c:\envmail.sql",cQry)
	TCQuery cQry New alias "TRBHTM"
	DbSelectArea("TRBHTM")

// Informacoes de Marketing

//O texto est· na cor #666666.
//A fonte È Calibri.

//CTO := TRBHTM->A1_EMAIL


	cAnexo :="<html><head><title>Colchoes Ortobom</title> "
	cAnexo+="<style type='text/css'>"

	cAnexo+=" body {
	cAnexo+="  width:70%; margin: 10px 10px 10px 10px; "
	cAnexo+="  padding: 5px; "
	cAnexo+="  font-family: Calibri, Verdana, Arial; "
	cAnexo+="  background-color: #fff; "
	cAnexo+="  color: #666666; } "

	cAnexo+="p { "
	cAnexo+=" font-size:14px; } "

	cAnexo+=" h2 {font-size:12px;} "

	cAnexo+=" td,th { "
	cAnexo+=" white-space:nowrap; "
	cAnexo+=" text-indent:1px;
		cAnexo+=" padding: 5px; } "

	cAnexo+=" p.tit{ "
	cAnexo+=" font-size:14px; "
	cAnexo+=" align:'center';} "

	cAnexo+=" div{font-size:14px;}"

	cAnexo+="table { "
	cAnexo+=" cellspacing = '0'; "
	cAnexo+=" cellpadding ='0' ; "
	cAnexo+=" font-size:12px   ; "
	cAnexo+=" border-collapse : collapse; "
	cAnexo+=" width:95%; "
	cAnexo+=" align:left; } "

	cAnexo+= " #superior{ "
//cAnexo+= " background-image: url('http://www.ortobom.com.br/imagens/superior.jpg'); "
//cAnexo+= " background-repeat: no repeat; "
	cAnexo+= " height : 120px; }"

	cAnexo+= " #principal{ "
	cAnexo+= " font-family: Calibri, Verdana; "
	cAnexo+= " } "

	cAnexo+= " #inferior{"
//cAnexo+= "  background-image: url('http://www.ortobom.com.br/imagens/inferior.jpg'); "
//cAnexo+= "  background-repeat: no repeat;"
	cAnexo+= "  height : 120px; } "

	cAnexo+="</style><body>"

	cAnexo+="<img src='http://www.ortobom.com.br/imagens/superior.jpg'><br>"
// GLM: George: SSI: 23836: 19/09/2012
// Inclus„o do parametro: _cMsg
	cAnexo+="<p> Caro(a) Cliente <b>"+SUBSTR(TRBHTM->A1_NOME,1,30)+"</b>. "+_cMsg+"<br><br>Segue abaixo as informacoes do pedido <b>"+TRBHTM->C5_XPEDFIC+"</b>.<br><br>"
///cAnexo+="<p> Caro(a) Cliente <b>"+SUBSTR(TRBHTM->A1_NOME,1,30)+"</b>, recebemos seu pedido e o mesmo est· em processo de analise.Agradecemos sua preferÍncia. <br><br>Segue abaixo as informacoes do pedido <b>"+TRBHTM->C5_XPEDFIC+"</b>.<br><br>"
	cAnexo+="<p class='tit' align='center'><b><i> Informacoes do Cliente </i></b></p>
	cAnexo+="<table><tr>"
	cAnexo+="<td>Cliente</td>"
	cAnexo+="<td colspan='3'>"+TRBHTM->A1_COD+" - "+SUBSTR(TRBHTM->A1_NOME,1,30)+"</td>"
	cAnexo+="</tr><tr>"
	cAnexo+="<td>Endereco</td>"
	cAnexo+="<td>"+SUBSTR(TRBHTM->A1_END,1,30)+""
	cAnexo+="<td>Telefone</td>"
	cAnexo+="<td>("+TRBHTM->A1_DDD+") - "+TRBHTM->A1_TEL+"</td>"
	cAnexo+="</tr><tr>"
	cAnexo+="<td>Bairro</td>"
	cAnexo+="<td>"+SUBSTR(TRBHTM->A1_BAIRRO,1,30)+"</td>"
	cAnexo+="<td>Municipio</td>"
	cAnexo+="<td>"+SUBSTR(TRBHTM->A1_MUN,1,30)+"</td>"
	cAnexo+="</tr><tr>"
	cAnexo+="<td>Vendedor</td>"
	cAnexo+="<td colspan='3'>"+TRBHTM->A3_COD+" - "+SUBSTR(TRBHTM->A3_NOME,1,30)+"</td>"
	cAnexo+="</tr></table>"
	cAnexo+="<br><br><p class='tit' align='center'><b> <i> Informacoes do Pedido </i> </b> </p> "
	cAnexo+="<br>"
	cAnexo+="<div><p><ul>"
	cAnexo+="<li>Pedido Ortobom....: "   +TRBHTM->C5_NUM                +" </li> "
	cAnexo+="<li>Pedido Ficha..........: "+TRBHTM->C5_XPEDFIC            +" </li> "
	cAnexo+="<li>Data da Venda......: "  +DTOC(STOD(TRBHTM->C5_XDTVEND))+"</li>  "

	if !empty(TRBHTM->C5_xENTREG)
		cAnexo+="<li>Prev. Entrega........: "+DTOC(STOD(TRBHTM->C5_XENTREG))+" A "+DTOC(STOD(TRBHTM->C5_XENTREF))+" </li>"
	endif

	cAnexo+="</ul></p></div><br><br>"

	cAnexo+="</table><br>"

	cAnexo+="<table><tr>"
	cAnexo+="<td> Codigo</td>"
	cAnexo+="<td> Qtd</td>"
	cAnexo+="<td> DenominaÁ„o</td>"
	cAnexo+="<td> Medida </td> "
	cAnexo+="<td align='right'> Vlr. Unitario </td> "
	cAnexo+="<td align='right'> Vlr. Total </td> </tr> "


	WHILE !eof()

		cAnexo+="<tr>"
		cAnexo+="<td> "+ ALLTRIM(TRBHTM->C6_PRODUTO )+" </td>"
		cAnexo+="<td align='right'> "+ TRANSFORM(TRBHTM->C6_QTDVEN,"@ 999") +"</td>"
		cAnexo+="<td> "+ SUBSTR(TRBHTM->B1_DESC,1,30)+"</td>"
		cAnexo+="<td> "+ TRBHTM->B1_XMED+"</td> "
		cAnexo+="<td align='right'> "+ TRANSFORM(TRBHTM->C6_XPRUNIT,"@E 99,999,999.99")+" </td> "
		cAnexo+="<td align='right'> "+ TRANSFORM(TRBHTM->C6_XPRUNIT*TRBHTM->C6_QTDVEN,"@E 99,999,999.99")+" </td> </tr> "
		nTOt += round(TRBHTM->C6_XPRUNIT*TRBHTM->C6_QTDVEN,2)

		DbSelectArea("TRBHTM")
		dbSkip()

	END
	cAnexo+="<tr>"
	cAnexo+="<td colspan = '5' align='right'> Total </td>"
	cAnexo+="<td align='right'> "+ TRANSFORM(nTot,"@E 99,999,999.99")+" </td>"
	cAnexo+="</tr>"
	cAnexo+="</table>"
	cAnexo+="<br><br>"
	cAnexo+="Para maiores informacoes entre em contato conosco no "+cTel+".</p> <br> Att,<br>Colchoes Ortobom"
	cAnexo+="<br> <img src='http://www.ortobom.com.br/imagens/inferior.jpg'>"
	cAnexo+="</body></html>"

	DbSelectArea("TRBHTM")
	dbCloseArea()

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lOk

	If lOk
		If !Empty(cCC)
			//		SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cBody Result lOk
			SEND MAIL FROM cFrom TO cTo CC cCC SUBJECT cSubject BODY cAnexo ATTACHMENT 	cAnexos Result lOk
		Else
			//		SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cBody Result lOk
			SEND MAIL FROM cFrom TO cTo SUBJECT cSubject BODY cAnexo ATTACHMENT 	cAnexos Result lOk
		EndIf
		If !lOk
			msgbox("Problemas no envio para o email: "+cTo + DTOS(DDATABASE))
		EndIf
	Else
		msgbox("Problemas na conex„o com o servidor de email")
	EndIf
	DISCONNECT SMTP SERVER

Return(lOk)

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥JobControl∫ Autor ≥ Eduardo Brust      ∫ Data ≥ 11/03/11	  ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥CONTROLE DE JOB											  ∫±±
	±±∫          ≥PARAMETROS RECEBIDOS : ROTINA / HORAS EM SEGUNDOS     	  ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Uso       ≥ORTOBOM			                                          ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function JobControl(cRotina,nSeg,nHora)
//TABELA: SCHEDULE (GUARDA POR ROTINA O CONTROLE DE PROCESSAMENTO)
//CAMPO:ROTINA(CHAR 20)
//CAMPO:DIA(VARCHAR 8)
//CAMPO:SEGUNDOS(inteiro)

	local lRet := .T.
	Local lHoraFixa := ValType(nHora) == 'N' .And. nHora >= 0 .And. nHora < 86400
	Local dDataJob := CToD('  /  /  ')
	Local cFonte := ""
	Local cDescRot := ""

	IF SELECT("JOB") > 0
		DBSELECTAREA("JOB")
		DBCLOSEAREA()
	ENDIF

	cQuery := " SELECT * FROM SCHEDULE "
	cQuery += " WHERE ROTINA = '"+cRotina+"'"  //ROTINA NO JOB
	TCQUERY cQuery ALIAS "JOB" NEW

	DbSelectArea("JOB")

//pego a hora em segundos atual
	_nHoraAtu := NOROUND(SECONDS(),0)

	If Len(cRotina) >= 9 // .And. SubStr(cRotina,1,2) $ "06|07|08|09|11"
		cFonte		:= AllTrim(Upper(SubStr(cRotina,3,Len(cRotina) - 2)))
		cDescRot	:= "-"
		If cFonte == "ORTP036"
			cDescRot	:= PADR("IMPORTACAO SISLOJA - GERACAO DE ARQUIVOS",150)
		ElseIf cFonte == "ORTP037"
			cDescRot	:= PADR("IMPORTACAO SISLOJA - CONTROLE",150)
		ElseIf cFonte == "ORTP033"
			cDescRot	:= PADR("IMPORTACAO DA0 (IMPACO) E SG1",150)
		ElseIf cFonte == "ORTP034"
			cDescRot	:= PADR("EXPORTACAO SISPED",150)
		ElseIf cFonte == "ORTP035"
			cDescRot	:= PADR("IMPORTACAO SISLOJA",150)
		ElseIf cFonte == "ORTP025"
			cDescRot	:= PADR("BLOQUEIO DE PEDIDOS EM CARTEIRA PARA CLIENTES COM PENDENCIAS VENCIDAS NA COBRANCA",150)
		ElseIf cFonte == "ORTP022"
			cDescRot	:= PADR("EXPORTACAO PARA O SISTEMA DE FRANQUIAS (SISPED)",150)
		ElseIf cFonte == "ORTA023D"
			cDescRot	:= PADR("IMPORTACAO DE CARTOES (PA7)",150)
		ElseIf cFonte == "ORTP014"
			cDescRot	:= PADR("BAIXA AUTOMATICA DE DUPLICATAS",150)
		EndIf
		cQuery := "UPDATE SCHEDULE SET DESCRICAO = '"+cDescRot+"',DIAC = '"+DToS(dDataBase)+"', SEGC = "+ALLTRIM(STR(_nHoraAtu))+" WHERE ROTINA = '"+cRotina+"'"
		Begin Transaction
			TCSQLExec(cQuery)
		End Transaction
	EndIf

	If EOF()
		cQuery:=" INSERT INTO SCHEDULE(ROTINA, DIA, SEGUNDOS) VALUES('"+cRotina+"','"+DTOS(DATE())+"',"+ALLTRIM(STR(_nHoraAtu))+")"
		Begin Transaction
			TCSQLExec(cQuery)
		End Transaction
	Else
		dDataJob := SToD(JOB->DIA)
		cQuery:=" UPDATE SCHEDULE SET DIA ='"+DTOS(DATE())+"', SEGUNDOS="+ALLTRIM(STR(_nHoraAtu))+ " WHERE ROTINA = '"+cRotina+"'"
		If "COMP" $ upper(alltrim(GetEnvServer()))
			Begin Transaction
				TCSQLExec(cQuery)
			End Transaction
		ElseIf dDataJob <> dDataBase
			Begin Transaction
				TCSQLExec(cQuery)
			End Transaction
		ElseIf !lHoraFixa .And. ( (JOB->SEGUNDOS + nSeg) < _nHoraAtu )
			Begin Transaction
				TCSQLExec(cQuery)
			End Transaction
		ElseIf lHoraFixa .And. _nHoraAtu > nHora .And. JOB->SEGUNDOS < nHora
			Begin Transaction
				TCSQLExec(cQuery)
			End Transaction
		Else
			lRet := .F.
		EndIf
	EndIf

	DBSELECTAREA("JOB")

	If lRet .And. !Empty(JOB->DIAF)
		dDataJob	:= SToD(JOB->DIAF)
		tcsqlexec(" UPDATE SCHEDULE SET DIAF ='"+Space(08)+"' WHERE ROTINA = '"+cRotina+"'")
		If !Empty(dDataJob)
			dDataBase	:= dDataJob
		EndIf
	EndIf

	DBCLOSEAREA()
//Conout(cRotina+" / JOBCONTROL - AMBIENTE: "+upper(alltrim(GetEnvServer()))+CHR(13)+cQuery )
Return lRet
	*******************************************************************************
	* FunÁ„o......: RefazEst()                                                   *
	* Programador.: Cesar Dupim                                                   *
	* Finalidade..: Gera Estrutura de um produto sob encomenda a partir de um     *
	*               produto base                                                  *
	* Data........: 16/01/06                                                      *
	******************************************************************************
User Function RefazEst()
	Local aArea    :=GetArea()
	Local nVolBase :=0
	Local nAreaBase:=0
	Local nVolEnc  :=0
	Local nAreaEnc :=0
	Local nProp    :=0
	Local nQB      :=0
	Local lRet     :=.F.
	Local aSG1     :={}
	Local i        :=0
	Local cQuery   :=""
	PREPARE ENVIRONMENT EMPRESA "22" FILIAL "02"
	cQuery:="SELECT DISTINCT B1_COD, B1_XMODELO, B1_XCODBAS "
//cQuery+="  FROM "+RetSqlName("SB1")+" SB1, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SC5")+" SC5 "
	cQuery+="  FROM "+RetSqlName("SB1")+" SB1 "
	cQuery+=" WHERE SB1.D_E_L_E_T_ = ' ' "
//cQuery+="   AND SC5.D_E_L_E_T_ = ' ' "
//cQuery+="   AND SC6.D_E_L_E_T_ = ' ' "
	cQuery+="   AND B1_FILIAL = '"+xFilial("SB1")+"' "
//cQuery+="   AND C5_FILIAL = '"+xFilial("SC5")+"' "
//cQuery+="   AND C6_FILIAL = '"+xFilial("SC6")+"' "
//cQuery+="   AND C5_EMISSAO BETWEEN '20110401' AND '20110431' "
//cQuery+="   AND C6_NUM = C5_NUM "
//cQuery+="   AND C6_PRODUTO = B1_COD "
	cQuery+="   AND B1_XCODBAS <> ' ' "
	cQuery+="   AND B1_XFORLIN = '20111113' "
	cQuery+="   AND B1_COD NOT LIKE '4%' "
	cQuery+="   AND B1_COD NOT LIKE '0%' "
	TCQUERY cQuery alias "QRY" NEW
	dbselectarea("QRY")
	dbgotop()
	do while !eof()
		IF QRY->B1_XMODELO=="000014"
			dbselectarea("SG1")
			dbOrderNickName("PSG11")
			dbseek(xFilial("SG1")+QRY->B1_XCODBAS,.T.)
			if SG1->G1_COD == QRY->B1_XCODBAS
				dbselectarea("SB1")
				dbseek(xFilial("SB1")+QRY->B1_COD)
				if found()
					reclock("SB1",.F.)
					SB1->B1_QB:=1
					msunlock()
					dbselectarea("SG1")
					dbOrderNickName("PSG11")
					dbseek(xFilial("SG1")+QRY->B1_XCODBAS)
					aSG1:={}
					do while !eof() .and. SG1->G1_COD == QRY->B1_XCODBAS
						dbselectarea("SB1")
						dbseek(xFilial("SB1")+SG1->G1_COMP)
						if found()
							aadd(aSG1,{SB1->B1_COD,SG1->G1_TRT,SG1->G1_QUANT,SG1->G1_PERDA,SG1->G1_INI,;
								SG1->G1_FIM,SG1->G1_OBSERV,SG1->G1_FIXVAR,SG1->G1_GROPC,SG1->G1_OPC,SG1->G1_REVINI,;
								SG1->G1_REVFIM,SG1->G1_POTENCI})
						endif
						dbselectarea("SG1")
						dbskip()
					enddo
					dbselectarea("SG1")
					dbOrderNickName("PSG11")
					dbseek(xFilial("SG1")+QRY->B1_COD) //Apaga Estrutura anterior se houver
					do while !eof() .and. Alltrim(SG1->G1_COD) == Alltrim(QRY->B1_COD)
						reclock("SG1",.F.)
						delete
						msunlock()
						dbskip()
					enddo
					for i:=1 to len(aSG1)
						reclock("SG1",.T.)
						SG1->G1_FILIAL  :=xFilial("SG1")
						SG1->G1_COD     := QRY->B1_COD
						SG1->G1_COMP    := aSG1[i,01]
						SG1->G1_TRT     := aSG1[i,02]
						SG1->G1_QUANT   := aSG1[i,03]
						SG1->G1_PERDA   := aSG1[i,04]
						SG1->G1_INI     := aSG1[i,05]
						SG1->G1_FIM     := aSG1[i,06]
						SG1->G1_OBSERV  := aSG1[i,07]
						SG1->G1_FIXVAR  := aSG1[i,08]
						SG1->G1_GROPC   := aSG1[i,09]
						SG1->G1_OPC     := aSG1[i,10]
						SG1->G1_REVINI  := aSG1[i,11]
						SG1->G1_REVFIM  := aSG1[i,12]
						SG1->G1_POTENCI := aSG1[i,13]
						msunlock()
					next
				endif
			endif
		ELSE
			If QRY->B1_XMODELO>="000008" // SUBSTR(QRY->B1_XMODELO,1,1)=="2"
				dbselectarea("SB1")
				dbOrderNickName("PSB11")
				dbseek(xFilial("SB1")+QRY->B1_XCODBAS)
				nPesoM3:=SB1->B1_QB/(SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP)
				dbgotop()
				if dbseek(xFilial("SB1")+QRY->B1_COD)
					dbselectarea("SG1")
					dbOrderNickName("PSG11")
					dbseek(xFilial("SG1")+QRY->B1_COD) //Apaga Estrutura anterior se houver
					do while !eof() .and. Alltrim(SG1->G1_COD) == Alltrim(QRY->B1_COD)
						reclock("SG1",.F.)
						delete
						msunlock()
						dbskip()
					enddo
					reclock("SG1",.T.)
					SG1->G1_FILIAL  :=xFilial("SG1")
					SG1->G1_COD     := QRY->B1_COD
					SG1->G1_COMP    := QRY->B1_XCODBAS
					SG1->G1_QUANT   := (SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP)*nPesoM3
					SG1->G1_INI     := STOD("20050901")
					SG1->G1_FIM     := STOD("20050101")
					SG1->G1_FIXVAR  := "V"
					msunlock()
					lRet:=.T.
				endif
			else
				dbselectarea("SB1")
				dbOrderNickName("PSB11")
				dbseek(xFilial("SB1")+QRY->B1_XCODBAS)
				if found()
					nVolBase  := SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP
					nAreaBase := SB1->B1_XLARG*SB1->B1_XCOMP
					nQB       := SB1->B1_QB
					dbselectarea("SG1")
					dbOrderNickName("PSG11")
					dbseek(xFilial("SG1")+QRY->B1_XCODBAS,.T.)
					if SG1->G1_COD == QRY->B1_XCODBAS
						dbselectarea("SB1")
						dbseek(xFilial("SB1")+QRY->B1_COD)
						if found()
							lRet:=.T.
							nVolEnc  := SB1->B1_XALT*SB1->B1_XLARG*SB1->B1_XCOMP
							nAreaEnc := SB1->B1_XLARG*SB1->B1_XCOMP
							reclock("SB1",.F.)
							SB1->B1_QB:= nQB
							msunlock()
							dbselectarea("SG1")
							dbOrderNickName("PSG11")
							dbseek(xFilial("SG1")+QRY->B1_XCODBAS)
							aSG1:={}
							do while !eof() .and. SG1->G1_COD == QRY->B1_XCODBAS
								dbselectarea("SB1")
								dbseek(xFilial("SB1")+SG1->G1_COMP)
								if found()
									If SB1->B1_XVAREST == "V"
										nProp:=nVolEnc/nVolBase
									Else
										if SB1->B1_XVAREST == "A"
											nProp:=nAreaEnc/nAreaBase
										else
											nProp:=1
										endif
									Endif
									aadd(aSG1,{SB1->B1_COD,SG1->G1_TRT,SG1->G1_QUANT*nProp,SG1->G1_PERDA,SG1->G1_INI,;
										SG1->G1_FIM,SG1->G1_OBSERV,SG1->G1_FIXVAR,SG1->G1_GROPC,SG1->G1_OPC,SG1->G1_REVINI,;
										SG1->G1_REVFIM,SG1->G1_POTENCI})
								endif
								dbselectarea("SG1")
								dbskip()
							enddo
							dbselectarea("SG1")
							dbOrderNickName("PSG11")
							dbseek(xFilial("SG1")+QRY->B1_COD) //Apaga Estrutura anterior se houver
							do while !eof() .and. Alltrim(SG1->G1_COD) == Alltrim(QRY->B1_COD)
								reclock("SG1",.F.)
								delete
								msunlock()
								dbskip()
							enddo
							for i:=1 to len(aSG1)
								reclock("SG1",.T.)
								SG1->G1_FILIAL  :=xFilial("SG1")
								SG1->G1_COD     := QRY->B1_COD
								SG1->G1_COMP    := aSG1[i,01]
								SG1->G1_TRT     := aSG1[i,02]
								SG1->G1_QUANT   := aSG1[i,03]
								SG1->G1_PERDA   := aSG1[i,04]
								SG1->G1_INI     := aSG1[i,05]
								SG1->G1_FIM     := aSG1[i,06]
								SG1->G1_OBSERV  := aSG1[i,07]
								SG1->G1_FIXVAR  := aSG1[i,08]
								SG1->G1_GROPC   := aSG1[i,09]
								SG1->G1_OPC     := aSG1[i,10]
								SG1->G1_REVINI  := aSG1[i,11]
								SG1->G1_REVFIM  := aSG1[i,12]
								SG1->G1_POTENCI := aSG1[i,13]
								msunlock()
							next
						endif
					endif
				endif
			endif
		endif
		dbselectarea("QRY")
		dbskip()
	enddo
	restarea(aArea)
Return(lRet)

/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥FUSERMWRITE  ∫ Autor ≥ Eduardo Brust ∫ Data ≥ 06/06/11      ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥FUNCAO QUE SUBSTITUIRA A MEMOWRITE NOS PROGRAMAS CONTENDO   ∫±±
	±±∫          ≥CONTROLE POR USUARIO. SO SERA EXECUTADA SE USUARIO TIVER    ∫±±
	±±∫          ≥PERMISSAO.												  ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Uso       ≥ORTOBOM			                                          ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function FUSERMWRITE(_cNomeProg,_cSql)
	Local aArea := GetArea() //gravo area atual
	Local cUsu    :=alltrim(cUsername)

//_cNomeProg = NOME DO PROGRAMA QUE SERA GRAVADO
// _cSql = QUERY QUE SERA GRAVADA

	if Alltrim(cUsu)$ "Administrador|dupim|brust.20|siga.20|wanderley|thiagocpd"   //SO EXECUTA PARA ESTES USUARIOS
		memowrite("c:\"+_cNomeProg,_cSql)
	endif

	RestArea(aArea)  //retorno area atual
return
//--------------------------------------------------------------------------//
User Function PrzMed(aTitRTC,dPrimVenc,cFoco)
//--------------------------------------------------------------------------//

// aTitRTC[1] --> Data de Vencimento
// aTitRTC[2] --> Tipo do titulo
// aTitRTC[3] --> Prazo medio do pedido. SÛ sera necessario caso exista pedido do tipo "PEN"
// aTitRTC[4] --> Valor do titulo
// aTitRTC[5] --> Tipo do cliente (A1_XTIPO)
// aTitRTC[6] --> Pedido de Venda

	Local I        := 0
	Local nPrzMed  := 0
	Local nValor   := 0
	Local dDtMedia := ctod("")
	Local nPosJur  := ascan(aTitRTC, {|x| x[2] == "JR"})
	Local nPosSld  := ascan(aTitRTC, {|x| x[2] == "SD"})
	Local cStrLog  := "DT.REF.  VENCTO.  TP/OPER PRZ.MED      VALOR     XTIPO PEDIDO PRAZO MEDIO"+chr(13)+chr(10)
//                 99/99/99 99/99/99   XXX     999   999,999,999.99   X   999999
	Local cArqLog  := iif(empty(cFoco)," ","C:\MEDRTC_"+cFoco+".TXT")

	If !empty(aTitRTC)

		If nPosJur > 0
			aTitRTC[nPosJur,1] := ctod("31/12/2049")
		Endif

		If nPosSld > 0
			aTitRTC[nPosSld,1] := ctod("31/12/2049")
		Endif
		aTitRTC   := asort(aTitRTC,,,{|x,y| x[1]<y[1]})
		dPrimVenc := iif(empty(dPrimVenc),aTitRTC[1,1],dPrimVenc)
		For I := 1 to len(aTitRTC)
			If !(alltrim(aTitRTC[I,2]) $ "SD/JR")
				nPrzMed += (((aTitRTC[I,1]-dPrimVenc)+1)*aTitRTC[I,4])
				nValor += aTitRTC[I,4]

				// Grava log do calculo do prazo mÈdio se foi informado o parametro cFoco
				If !empty(cFoco)
					cStrLog += dtoc(dPrimVenc)   +space(1)
					cStrLog += dtoc(aTitRTC[I,1])+space(3)
					cStrLog += aTitRTC[I,2]      +space(5)
					cStrLog += aTitRTC[I,3]      +space(3)
					cStrLog += transform(aTitRTC[I,4],"@E 999,999,999.99") +space(3)
					cStrLog += aTitRTC[I,5]      +space(3)
					IF !EMPTY(aTitRTC[i,6]) .or. cFoco == "D"
						cStrLog += aTitRTC[I,6]      +space(1)
					else
						cStrLog += aTitRTC[I,8]      +space(1)
					endif
					cStrLog += transform(nValor,"@E 999,999,999.99")+"("+transform(nPrzMed/nValor,"@E 999,999,999,999.99")+" dias)"+chr(13)+chr(10)
				Endif

			Endif
		Next

		nPrzMed  := nPrzMed/nValor
		nPrzMed  := round(nPrzMed,0)
		dDtMedia := dPrimVenc + nPrzMed

		If !empty(cFoco)
			cStrLog += "Prazo Medio:"+transform(nPrzMed,"@E 999,999,999.99")+chr(13)+chr(10)
			cStrLog += "Data Media :"+dtoc(dDtMedia)+" (Data Ref. + Prazo Medio)"
			Memowrit(cArqLog,cStrLog)
		Endif

	Endif

Return({dDtMedia,nPrzMed,dPrimVenc})

	**********************************
User Function GravaSE1(aTit,cOrigem)
	**********************************
	Local cNumTit:=GetMv("MV_XNUMTIT")
	Local cVar   :=""
	Local i:=0
	if Len(alltrim(cNumTit))<12
		cNumTit:="000000000001"
	endif
	dbselectarea("SE1")
	dbsetorder(1)
	dbseek(xFilial("SE1")+cNumTit)
	do while SE1->E1_PREFIXO+SE1->E1_NUM == cNumtit
		dbskip()
		cNumTit:=soma1(cNumTit,12)
	enddo
	PutMv("MV_XNUMTIT",Soma1(cNumTit))
	RecLock('SE1',.T.)
	SE1->E1_FILIAL	:=xFilial("SE1")
	SE1->E1_PREFIXO	:=Substr(cNumTit,1,3)
	SE1->E1_NUM		:=Substr(cNumTit,4,9)
	SE1->E1_SITUACA :="0"
	SE1->E1_STATUS  :="A"
	SE1->E1_FLUXO	:="S"
	SE1->E1_MSFIL   :=SM0->M0_CODFIL
	SE1->E1_MSEMP   :=SM0->M0_CODIGO
	SE1->E1_FILORIG :=SM0->M0_CODFIL
	SE1->E1_TIPODES :='1'
	SE1->E1_XEMPRT  :=.F.
	SE1->E1_XFNDLJ  :=.F.
	SE1->E1_XORIGEM :=cOrigem
	SE1->E1_EMIS1   :=dDataBase
	SE1->E1_MOEDA   :=1
	SE1->E1_DESDOBR	:= '2'
	SE1->E1_ORIGEM  :="GRVSE1"
	SE1->E1_NATUREZ := GetMV("MV_1DUPNAT")
	SE1->E1_OCORREN := "01"
	SE1->E1_MULTNAT := "2"
	SE1->E1_PROJPMS := "2"
	SE1->E1_MODSPB  := "1"
	SE1->E1_XCLIBLQ := "N"
	SE1->E1_SCORGP  := "2"
	SE1->E1_APLVLMN := "1"
	SE1->E1_TPDESC  := "C"
	SE1->E1_RELATO  := "2"
	If cVersao == "12" && Henrique - 13/06/2019 - Incluido IF por conta da SSI 80595
		SE1->E1_RATFIN  := "2"
		SE1->E1_TCONHTL := "3"
	EndIf

	for i:=1 to len(aTit)
		if alltrim(upper(aTit[i,1])) == "E1_PREFIXO" .OR. alltrim(upper(aTit[i,1])) == "E1_NUM"
			SE1->E1_PREFIXO	:=Substr(cNumTit,1,3)
			SE1->E1_NUM		:=Substr(cNumTit,4,9)
		else
			cVar:="SE1->"+aTit[i,1]
			&cVar:=aTit[i,2]
			if upper(alltrim(aTit[i,1]))=="E1_VALOR"
				SE1->E1_SALDO:=aTit[i,2]
			endif
		endif
	next
	SE1->E1_VLCRUZ :=SE1->E1_VALOR
	SE1->E1_VENCREA:=datavalida(SE1->E1_VENCTO)
	/*IF SE1->E1_EMISSAO > dDatabase
		SE1->E1_EMISSAO:=dDatabase
	ENDIF*/ //alterado em 2021-10-25 por Gabriel Rezende
	IF SE1->E1_EMISSAO > dDatabase
			If dDatabase > SE1->E1_VENCTO
				SE1->E1_EMISSAO := SE1->E1_VENCTO
			Else
				SE1->E1_EMISSAO := dDataBase
			EndIF
	ElseIf SE1->E1_EMISSAO > SE1->E1_VENCTO
		SE1->E1_EMISSAO := SE1->E1_VENCTO
	ENDIF 
	msunlock()
	reclock("SE1",.F.)
	SE1->E1_VENCORI:=SE1->E1_VENCTO
	msunlock()

	cChaveTit := xFilial("SE1") + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" +;
		SE1->E1_TIPO   + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA

	cIdDoc    := FINGRVFK7("SE1", cChaveTit)

Return(cNumTit)
	************************
User Function ValPLib(cPed,cTpLib,cAdm,cAutori,cCartao,cNumPv)
	************************
	Local lRet:=.F.
	Local nPedLib:=0
	Local cQuery:=""
	Local cEmpPesq:="'" + cEmpAnt + "'"
	Default cNumPv := ""

	cQuery+=" SELECT SUM(TOT) TOT FROM ( "
	cQuery+=" SELECT COUNT(*) TOT FROM PEDFLIB WHERE UNIDADE In ("+cEmpPesq+") AND PEDIDO = '"+cPed+"' AND TPLIB = '"+cTpLib+"' "
	if !empty(cAdm) .and. !empty(cAutori) .and. !empty(cCartao)
		cQuery+= " AND ADM = '"+cAdm+"'"
		cQuery+= " AND AUTORI = '"+cAutori+"'"
		cQuery+= " AND CARTAO = '"+cCartao+"'"
	endif
	IF !EMPTY(cNumPv) .and. !empty(cAutori)
		cQuery+=" UNION "
		cQuery+=" SELECT COUNT(*) TOT FROM PEDFLIB WHERE NUMPV = '"+cNumPv+"' AND UNIDADE In ("+cEmpPesq+")"
		cQuery+= " AND AUTORI = '"+cAutori+"'"
	endif
	cQuery+=" ) "
	tcquery cQuery ALIAS "PEDFLIB" NEW
	memowrit("c:\ValPLib.sql",cQuery)
	dbselectarea("PEDFLIB")
	nPedLib:=PEDFLIB->TOT
	dbclosearea()
	if nPedLib>0
		lRet:=.T.
	endif
Return(lRet)


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥fTRVPOS   ∫ Autor ≥ BRUNO COSTA        ∫ Data ≥  27/10/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Trava para POS que est„o fixados para clientes diferentes  ∫±±
±±∫          ≥ do que est„o sendo lanÁados                                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫16/05/2013≥ AlteraÁ„o - SSI 28449. Marcos Furtado                      ∫±±
±±∫          ≥ Inclus„o das empresas 07,08,09 e 11.                       ∫±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	****************************
User Function fTRVPOS(cCliente,cLoja,cPOS,cPv)
	****************************
	Local cQuery := ""
	Local lRet   := .F.
	Local aRet	 := {}

//if DTOS(ddatabase) >= "20130213" .and. DTOS(ddatabase) <= "20130423" .or. !(cEmpAnt$("05|06|10|15"))
//if DTOS(ddatabase) >= "20130213" .and. DTOS(ddatabase) <= "20130423" .or. !(cEmpAnt$("03|04|05|06|07|08|09|10|11|15")) && Henrique - 15/10/2013 - Incluida unidade 03 para nao retornar e entrar na validacao
//Retirada a Unidade 10 da lista de trava de POS em 17/12/13.

//=====
// N√O LIBERAR A PEDIDO DE UNIDADES -
// A UNIDADE DEVE ENTRAR EM CONTATO COM O SETOR DE CARTOES DA REGIONAL
// PARA SOLICITAR A REGULARIZACAO DE POS
//=====
/*
	if DTOS(ddatabase) >= "20130213" .and. DTOS(ddatabase) <= "20130423" .or. cEmpAnt=="03" //!(cEmpAnt$("03|04|05|06|07|08|09|11|15")) && Henrique - 15/10/2013 - Incluida unidade 03 para nao retornar e entrar na validacao
	aAdd(aRet,{.F.,""})
	return aRet
	endif
*/

	cQuery := " SELECT DISTINCT PA4_CODEMP,PA4_PV,PA4_CODCLI,PA4_LOJA,PA4_TPPOS, PA4_MATRIZ, A1_CGC,A1_NOME, A1_XCODGRU "
	cQuery += "  FROM "+RETSQLNAME("PA4")+" PA4, "+RETSQLNAME("SA1")+" SA1 "
	cQuery += " WHERE PA4.D_e_L_E_t_ = ' ' "
	cQuery += "   AND SA1.D_e_L_E_t_(+) = ' ' "
	cQuery += "   AND PA4_CODCLI = A1_COD(+) "
	cQuery += "   AND PA4_LOJA = A1_LOJA(+) "
	cQuery += "   AND PA4_FILIAL = '"+XFILIAL("PA4")+"'"
	cQuery += "   AND A1_FILIAL(+) = '"+XFILIAL("SA1")+"'"
	cQuery += "   AND PA4_POS = '"+cPos+"'"
	cQuery += "   AND PA4_CODCLI <> '  '"
	cQuery += "   AND A1_CGC <> '  ' "
	if !empty(cPv)
		cQuery += "   AND PA4_PV  like '%"+cPv+"%'"
	endif

	u_fUserMWrite("ORTR015_TRVPOS.sql",cQuery)
	TCQUERY cQuery ALIAS "TPOS" NEW

	dbselectarea("TPOS")
	while !(eof())
		cAVar:= cCliente+cLoja
		cBVar:= TPOS->PA4_CODCLI+TPOS->PA4_LOJA                         //M·quinas usadas normalmente em feirıes ( sem fio e pertence a matriz )
		If cAVar <> cBVar .And. !empty(Alltrim(TPOS->PA4_CODCLI)) .And. !( (TPOS->PA4_TPPOS == "S")  .And. (TPOS->PA4_MATRIZ == "S") )  //Alltrim(Str(val(TPOS->PA4_PV))) $ GetNewPar("MV_XPOSMAT","9999999"))
			//If cAVar <> cBVar .and. !empty(Alltrim(TPOS->PA4_CODCLI)) .AND. !(TPOS->PA4_TPPOS == "S" .AND. Alltrim(Str(val(TPOS->PA4_PV))) $ GetNewPar("MV_XPOSMAT","9999999"))
			If alltrim(TPOS->A1_XCODGRU)<>alltrim(POSICIONE("SA1",1,xFILIAL("SA1")+cCliente+cLoja,"A1_XCODGRU"))
				If !u_ValPLib("","","","","",TPOS->PA4_PV)
					lRet := .T.
					if TPOS->PA4_CODEMP <> cEmpAnt // hd 1550 - sergio
						aAdd(aRet,{lRet,"POS da unidade " + TPOS->PA4_CODEMP })
					else
						aAdd(aRet,{lRet,TPOS->A1_NOME})
					endif
				endif
			Else
				Exit
			EndIf
		EndIf
		dbSelectArea("TPOS")
		TPOS->(DbSkip())
	enddo

	if len(aRet) = 0
		aAdd(aRet,{.F.,""})
	endif

	dbselectarea("TPOS")
	dbCloseArea()

return aRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥fTRVPOS   ∫ Autor ≥ BRUNO COSTA        ∫ Data ≥  27/10/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Trava para POS que est„o fixados para clientes diferentes  ∫±±
±±∫          ≥ do que est„o sendo lanÁados                                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	****************************
User Function fTRVCARTAO(cAdm,cAutori,cCartao,cRotina,cValRep)
	****************************
	Local cQuery := ""
	Local cMsg   := ""

	cQuery := " SELECT PA7_CODCLI, "
	cQuery += "        PA7_LOJCLI, "
	cQuery += "       (CASE "
	cQuery += "         WHEN PA7_ORIGEM = 'L' THEN "
	cQuery += "          'Financeiro loja, pedido: '||ZB_NUMPED "
	cQuery += "         WHEN PA7_ORIGEM = 'A' THEN "
	cQuery += "          'Acerto, pedido: '||ZB_NUMPED "
	cQuery += "         WHEN PA7_ORIGEM = 'R' THEN "
	cQuery += "          'CobranÁa, RTC: '||ZK_NUMRTC  "
	cQuery += "       END) MSGBLQ, "
	cQuery += "       PA7_ORIGEM ORI, "
	cQuery += "       ZB_NUMPED, "
	cQuery += "       ZK_NUMRTC "
//cQuery += "  FROM "+RETSQLNAME("PA7")+" PA7, "+RETSQLNAME("SZB")+" SZB, "+RETSQLNAME("SZK")+" SZK "
	cQuery += "  FROM V_PA7UNI PA7, "+RETSQLNAME("SZB")+" SZB, "+RETSQLNAME("SZK")+" SZK "
	cQuery += " WHERE PA7.D_E_L_E_T_ = ' ' "
	cQuery += "   AND PA7_FILIAL = '"+XFILIAL("PA7")+"'"
	cQuery += "   AND SZB.D_E_L_E_T_(+) = ' ' "
	cQuery += "   AND ZB_FILIAL(+) = '"+XFILIAL("SZB")+"'"
	cQuery += "   AND SZK.D_E_L_E_T_(+) = ' '
	cQuery += "   AND ZK_FILIAL(+) = '"+XFILIAL("SZK")+"'"
	cQuery += "   AND SZB.R_E_C_N_O_(+) = PA7_RECNO
	cQuery += "   AND SZK.R_E_C_N_O_(+) = PA7_RECNO
	cQuery += "   AND PA7_ADM = '"+cAdm+"'"
	cQuery += "   AND PA7_AUTORI = '"+cAutori+"'"
	cQuery += "   AND PA7_CARTAO = '"+cCartao+"'"
	if cRotina == "R"
		cQuery += " AND ZK_NUMRTC(+) <> '"+cValRep+"'"
	else
		cQuery += " AND ZB_NUMPED(+) <> '"+cValRep+"'"
	endif
	cQuery += " AND PA7_AUTORI = ZB_AUTORIZ "

	u_fUserMWrite("fTRVCARTAO.sql",cQuery)
	TCQUERY cQuery ALIAS "TCAR" NEW

	dbselectarea("TCAR")
	if !(eof())
		if (!empty(TCAR->ZB_NUMPED) .and. TCAR->ORI $ ("A|L")) .or. (!empty(TCAR->ZK_NUMRTC) .and.  TCAR->ORI == "R")
			cMsg:= "Cart„o j· incluido. "+TCAR->MSGBLQ
		endif
	endif

	dbselectarea("TCAR")
	dbCloseArea()

return cMsg


	************************
User Function ValNtLib(cNota,cSerie,cFornec,ctplib)
	************************
	Local lRet:=.F.
	Local nPedLib:=0
	Local cQuery:=""
	default ctplib:="DE"
	cQuery:="SELECT COUNT(*) TOT FROM PEDFLIB "
	cQuery+="WHERE UNIDADE = '"+cEmpAnt+"' AND NOTA = '"+cNota+"' "
	cQuery+="  AND SERIE = '"+cSerie+"'   AND CODIGOF = '"+cFornec+"' "
	cQuery+="  AND TPLIB = '"+cTpLib+"'  "
	memowrit("c:\valntlib.sql",cQuery)
	tcquery cQuery ALIAS "NTALIB" NEW
	dbselectarea("NTALIB")
	nPedLib:=NTALIB->TOT
	dbclosearea()
	if nPedLib>0
		lRet:=.T.
	endif
Return(lRet)

/*
Funcao	: Impr
Data		: 23/05/2012
Autor		: Marinaldo de Jesus
Uso		: Impressao de Relatorio Nao Grafico
Sintaxe	: StaticCall( FUNCOES , Impr , <...> )
*/
Static Function Impr(;
		cDetalhe		,;	//01 -> Linha Detalhe a ser impressa.
	cFimFolha	,;	//02 -> "F" ou "P" Imprime Rodape e Salta de Pagina. Qualquer outro Ex.: "C" Imprime Detalhe e  Incrementa Li.
	nReg			,;	//03 -> Numero de Registros a Serem Impressos no Rodape.
	cRoda			,;	//04 -> Descritivo a Ser Impresso no Rodape apos nReg.
	nColuna		,;	//05 -> Coluna onde Iniciar Impressao do Detalhe.
	lSalta		,;	//06 -> Se deve ou nao Incrementar o salto de Linha.
	lMvImpSX1	,;	//07 -> Se Deve Considerar o Parametro MV_IMPSX1 ao inves do MV_PERGRH
	bCabec		,;	//08 -> Bloco com a Chamada de Funcao para Cabecalho Especifico
	bRoda		 	,;	//09 -> Bloco com a Chamada de Funcao para Rodape Especifico
	nLinhas		,; //10 -> Numero de Linhas do Relatorio
	cPicture		,;	//11 -> Picture
	oFont			 ; //12 -> Font
	)

	Local aCabec		:= {}
	Local cDetCab		:= ""
	Local cWCabec		:= ""
	Local lbCabec		:= ( ValType( bCabec ) == "B" )
	Local lbRoda        := ( ValType( bRoda  ) == "B" )
	Local nCb			:= 0
	Local nSpace		:= 0

	Static lPerg
	Static nNormal
	Static nComp

	DEFAULT lMvImpSX1	:= .T.

	DEFAULT lPerg  	:= ( GetMv( IF( lMvImpSX1 , "MV_IMPSX1" , "MV_PERGRH" ) ) == "S" )
	DEFAULT	nNormal	:= GetMv("MV_NORM")
	DEFAULT nComp		:= GetMv("MV_COMP")
	DEFAULT cFimFolha	:= ""
	DEFAULT cDetalhe	:= ""
	DEFAULT nReg		:= 0
	DEFAULT nColuna 	:= 0
	DEFAULT lSalta		:= .T.
	DEFAULT nLinhas   := 80

	wnRel			:= IF( Type("wnRel")	== "U" , IF( Type("NomeProg") != "U" ,  NomeProg , "" ) , wnRel )
	wCabec0		:= IF( Type("wCabec0")	== "U" , 0	, wCabec0	)
	wCabec1 		:= IF( Type("wCabec1")	== "U" , "" , wCabec1	)
	wCabec2 		:= IF( Type("wCabec2")	== "U" , "" , wCabec2	)
	nChar			:= IF( Type("nChar")	== "U" , NIL , IF( nChar == 15 , nComp , nNormal ) ) // Quando nao for compactado nChar deve ser Nil para tratamento da Cabec.
	ContFl		:= IF( Type("ContFl")   == "U" , 1   , ContFl   )
	nTamanho		:= IF( Type("nTamanho") == "U" , "P" , nTamanho )
	Li				:= IF( Type("Li")		== "U" , 0   , Li		)
	Titulo		:= IF( Type("Titulo")   == "U" , ""  , Titulo   )
	aReturn		:= IF( Type("aReturn")  == "U" , {"",1,"",2,1,"","",1} , aReturn )

	m_pag			:= ContFl
	nSpace		:= IF( nTamanho == "P" , 80 , IF( nTamanho == "G" , 220 , 132 ) )
	cFimFolha	:= Upper( AllTrim( cFimFolha ) )

	Begin Sequence

		IF (;
				( cFimFolha $ "FP" );
				.or.;
				( Li >= nLinhas );
				)
			IF ( Li != 0 )
				IF (;
						( cFimFolha $ "F" );
						.or.;
						( cRoda != NIL );
						)
					IF !( lbRoda )
						IF (;
								( nReg == 0 );
								.or.;
								( cRoda == NIL );
								)
							Roda( 0 , ""    , nTamanho )
						Else
							Roda( nReg , cRoda , nTamanho )
						EndIF
					Else
						Eval( bRoda )
					EndIF
				EndIF
				Li := 0
			EndIF
			IF (;
					( cFimFolha == "F" );
					.or.;
					(;
					( cFimFolha == "P" );
					.and.;
					Empty( cDetalhe );
					);
					)
				Break
			EndIF
		EndIF

		IF ( Li == 0 )
			IF !( lbCabec )
				IF ( wCabec0 <= 2 )
					Cabec( Titulo , wcabec1 , wcabec2 , wnrel , nTamanho , nChar , NIL , lPerg )
				Else
					aCabec := SendCab(nSpace)
					For nCb := 1 To wCabec0
						IF ( Type((cWCabec := "wCabec"+Alltrim(Str(nCb)))) != "U" )
							cDetCab := &(cWCabec)
							cDetCab += Space(nSpace - Len(cDetCab) -1)
							aAdd(aCabec,"__NOTRANSFORM__"+cDetCab)
						EndIF
					Next nCb
					Cabec( Titulo , "" , "" , wnrel , nTamanho , nChar , aCabec , lPerg )
				EndIF
			Else
				Eval( bCabec )
			EndIF
			ContFl++
		EndIF

		IF ( Len( cDetalhe ) == nSpace )
			IF ( Empty(StrTran(cDetalhe,"-","")) .or. Empty(StrTran(cDetalhe,".","")) )
				cDetalhe := __PrtThinLine()
			ElseIF ( Empty(StrTran(cDetalhe,"=","")) .or. Empty(StrTran(cDetalhe,"*","")) )
				cDetalhe := __PrtFatLine()
			EndIF
		EndIF

		PrintOut(Li,nColuna,cDetalhe,cPicture,oFont)

//AlteraÁ„o Roberto Mendes - 29/05/2018
		IF lSalta
			Li++
/*
		else
	NIL
*/
		endif

	End Sequence

Return( LI )

/*
Funcao	: SendCab
Data		: 23/05/2012
Autor		: Marinaldo de Jesus
Uso		: Impr
*/
Static Function SendCab( nLargura )

	Local aDetCab := {}
	Local cDetCab := ""
	Local nEspaco := 0

// Nome da Empresa / Pagina
	cDetCab := "__LOGOEMP__"
	nEspaco := ( ( nLargura - 2 ) - (Len(cDetCab + RptFolha+" "+TransForm(m_pag,'999999'))) )
	cDetCab += Space(nEspaco)+RptFolha+" "+TransForm(m_pag,'999999')
	aAdd(aDetCab,cDetCab)

// Vers„o / Titulo / Data
	cDetCab := ( "SIGA /"+wnrel+"/v."+cVersao+"  " )
	nEspaco := Len(cDetCab+RptDtRef+" "+DTOC(dDataBase))
	cDetCab += PADC(Trim(Titulo),(nLargura - 2)-nEspaco)
	nEspaco := ( (nLargura - 2) - (Len(cDetCab + RptDtRef+" "+DTOC(dDataBase))) )
	cDetCab += ( RptDtRef+" "+DTOC(dDataBase) )
	aAdd(aDetCab,cDetCab)

// Hora da emiss„o / Data Emissao
	cDetCab := ( RptHora+" "+time() )
	nEspaco := ( (nLargura - 2) - Len(cDetCab+RptEmiss+" "+DToC(MsDate())) )
	cDetCab += Space(nEspaco)+RptEmiss+" "+DToC(MsDate())
	aAdd(aDetCab,cDetCab)

	aAdd(aDetCab,"__FATLINE__")

Return(aDetCab)

/*
Funcao	: LEDriver
Data		: 23/05/2012
Autor		: Marinaldo de Jesus
Uso		: Impr
*/
Static Function LEDriver()

	Local aSettings := {}
	Local cStr
	Local cLine
	Local i

	if !File( __DRIVER )
		aSettings := { "CHR(15)" , "CHR(18)" , "CHR(15)" , "CHR(18)" , "CHR(15)" , "CHR(15)" }
	Else
		cStr := MemoRead(__DRIVER)
		For i := 2 To 7
			cLine := AllTrim( MemoLine( cStr , 254 , i ) )
			aAdd( aSettings , SubStr( cLine , 7 ) )
		Next
	Endif

Return( aSettings )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥SemAcento ∫ Autor ≥ BRUNO COSTA        ∫ Data ≥  31/05/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Retira acento de uma string retornando o caracter sem      ∫±±
±±∫          ≥ sem acento.                                                ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
USER FUNCTION SemAcento(Arg1)
	Local nConta := 0
	Local cLetra := ""
	Local cRet := ""
	Arg1 := Arg1
	For nConta:= 1 To Len(Arg1)
		cLetra := SubStr(Arg1, nConta, 1)
		if (Asc(cLetra) > 191 .and. Asc(cLetra) < 198) .or.;
				(Asc(cLetra) > 223 .and. Asc(cLetra) < 230)
			cLetra := "a"
		elseif (Asc(cLetra) > 199 .and. Asc(cLetra) < 204) .or.;
				(Asc(cLetra) > 231 .and. Asc(cLetra) < 236)
			cLetra := "e"
		elseif (Asc(cLetra) > 204 .and. Asc(cLetra) < 207) .or.;
				(Asc(cLetra) > 235 .and. Asc(cLetra) < 240)
			cLetra := "i"
		elseif (Asc(cLetra) > 209 .and. Asc(cLetra) < 215) .or.;
				(Asc(cLetra) == 240) .or. (Asc(cLetra) > 241 .and. Asc(cLetra) < 247)
			cLetra := "o"
		elseif (Asc(cLetra) > 216 .and. Asc(cLetra) < 221) .or.;
				(Asc(cLetra) > 248 .and. Asc(cLetra) < 253)
			cLetra := "u"
		elseif  Asc(cLetra) == 199 .or. Asc(cLetra) == 231
			cLetra := "c"
		elseif  Asc(cLetra) == 39
			cLetra := " "
		Endif
		cRet := cRet+cLetra
	Next
Return cRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥fSCHEDULLE∫ Autor ≥ BRUNO COSTA        ∫ Data ≥  08/11/12   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ Prepara ambientes para a execuÁ„o do schedulle evitando    ∫±±
±±∫          ≥ problema dos servidores separados	                      ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/
	****************************
User Function fSchedulle()
	****************************
	Local aVetEmp:= {}
	Local cEnvName	:= upper(alltrim(GetEnvServer()))
	do case
	case cEnvName == "COMP"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "04" FILIAL "02"
		aadd(aVetEmp,{"04", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "SP"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "02" FILIAL "02"
		aadd(aVetEmp,{"02", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "RJ"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "03" FILIAL "02"
		aadd(aVetEmp,{"03", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "MG"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "04" FILIAL "02"
		aadd(aVetEmp,{"04", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "GO"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "05" FILIAL "02"
		//aadd(aVetEmp,{"25", "02"})
		aadd(aVetEmp,{"05", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "MT"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "06" FILIAL "02"
		aadd(aVetEmp,{"06", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "PR"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "10" FILIAL "02"
		aadd(aVetEmp,{"10", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "RS"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "15" FILIAL "02"
		aadd(aVetEmp,{"15", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "AF"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "22" FILIAL "02"
		aadd(aVetEmp,{"22", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "OF"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "21" FILIAL "02"
		aadd(aVetEmp,{"21", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "BA"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "07" FILIAL "02"
		aadd(aVetEmp,{"07", "02"})
		aadd(aVetEmp,{"23", "02"})
		aadd(aVetEmp,{"24", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "PE"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "08" FILIAL "02"
		aadd(aVetEmp,{"08", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "CE"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "09" FILIAL "02"
		aadd(aVetEmp,{"09", "02"})
	case SubStr(cEnvName, Len(cEnvName) - 1, 2) == "PA"
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "11" FILIAL "02"
		aadd(aVetEmp,{"11", "02"})
		aadd(aVetEmp,{"26", "02"})
	otherwise
		RESET ENVIRONMENT
		RPCSetType(3)
		PREPARE ENVIRONMENT EMPRESA "07" FILIAL "02"
		//		aadd(aVetEmp,{"04", "02"})
		//		aadd(aVetEmp,{"07", "02"})
		//		aadd(aVetEmp,{"08", "02"}) PE
		//		aadd(aVetEmp,{"09", "02"}) CE
		//		aadd(aVetEmp,{"11", "02"}) PA
		//		aadd(aVetEmp,{"22", "02"})
		aadd(aVetEmp,{"23", "02"})

	endcase
return aVetEmp


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕª±±
±±∫Funcao    ≥pesq_aut_bndes∫ Autor ≥ DECIO              ∫ Data ≥15/01/13 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥ pesquisar autorizacoes de cartoes BNDES na tabela PA7      ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
*/

	*****************************
User Function pesq_aut_bndes()
	*****************************

	Private oTela   :=nil
	Private nlin    := 0
	Private cAutori := ""
	Private nValor  := 0

	Private cLabArp := "Numero do ARP:"
	Private cGetarp := SPACE(06)
	Private cLabDta := "Data da Venda:" // SSI 33191
	Private dDtvend := Stod(Space(8))   // SSI 33191

	DEFINE MSDIALOG oTela TITLE "Pesquisa de autorizaÁ„o de cartoes BNDES "+CEMPANT FROM 0,0 TO 260,300 PIXEL

	@ 15,010 SAY   cLabaRP PIXEL
	@ 15,050 MsGet cGetarp picture "@E 999999" Pixel

	@ 33,010 SAY   cLabDta PIXEL // SSI 33191
	@ 33,050 MsGet dDtvend Pixel // SSI 33191

	@ 51,010 say "Autorizacao: "+cAutori PIXEL
	@ 60,010 say "Valor      : "+str(nValor, 08,02)  PIXEL

//@ 100,040 BMPBUTTON TYPE 01 ACTION fBusca()
	@ 100,040 BMPBUTTON TYPE 01 ACTION processa ({||fBusca()}, "Aguarde, pesquisando . . .")
	@ 100,080 BMPBUTTON TYPE 02 ACTION oTela:End()
	ACTIVATE MSDIALOG oTela CENTERED

Return()


//###############################
//busca dados gravados na tabela
//###############################

Static Function fBusca()

	Local cQuery := ""

//cQuery := " SELECT * FROM SIGA.PA7030 "
	cQuery := " SELECT * FROM SIGA.V_PA7UNI "
	cQuery += " WHERE D_E_L_E_T_= ' '"
	cQuery += " AND PA7_autori LIKE '%"+cGetarp+"'"

	IF !EMPTY(dDtvend)
		cQuery += " AND PA7_DTVEND = '"+dtos(dDtvend)+"' " // SSI 33191
	ENDIF
	cQuery += " AND PA7_cartao = '0000000000000000000'"

	IF SELECT("TQY") > 0
		DBSELECTAREA("TQY")
		DBCLOSEAREA()
	ENDIF

	TCQUERY cQuery Alias "TQY" NEW

	DBSELECTAREA("TQY")

	dbgotop()

	IF !TQY->(EOF())
		cAutori := tqy->pa7_autori
		nValor  := tqy->pa7_valor

		TQY->(DbSkip())
		If !TQY->(EOF())
			MsgBox("Informe a data.","ATEN«√O!","INFO")
			cAutori := ''
			nValor  := 0
		Endif

	Else
		MsgBox("autorizacao nao encontrada","ATEN«√O!","INFO")
	ENDIF


//oTela:Refresh()
return
	********************************
User Function VALHORA()
	********************************
//03201305211948
//05012013270575
	Local cPassw:="25253318460C20133A4D20"//space(22)
	Local cHRLIBI:=""
	Local cHRLIBF:=""
	Local cQuery:="SELECT HRLIBI, HRLIBF FROM HORALIB WHERE UN = '"+cEmpAnt+"' AND DTLIB = ' ' "
	Local lBlq  :=.T.
	tcquery cQuery alias "VHORA" new
	cHRLIBI:=VHORA->HRLIBI
	cHRLIBF:=VHORA->HRLIBF
	VHORA->(DBCLOSEAREA())
	if empty(cHRLIBI)
		cHRLIBI:="07:00:00"
	endif
	if empty(cHRLIBF)
		cHRLIBF:="17:20:00"
	endif
	if TIME()<cHRLIBI .OR. TIME()>cHRLIBF
		cQuery:="SELECT MAX(HRLIBF) HRLIBF, MIN(HRLIBI) HRLIBI FROM HORALIB WHERE UN = '"+cEmpAnt+"' AND DTLIB = '"+dtos(date())+"' "
		tcquery cQuery alias "VHORA" new
		cHRLIBI:=VHORA->HRLIBI
		cHRLIBF:=VHORA->HRLIBF
		VHORA->(DBCLOSEAREA())
		if empty(cHRLIBI)
			cHRLIBI:="07:00:00"
		endif
		if empty(cHRLIBF)
			cHRLIBF:="17:20:00"
		endif
		if TIME()<cHRLIBI .OR. TIME()>cHRLIBF
			DEFINE MSDIALOG oDlgBlq FROM 00,00 TO 90,300 TITLE OemtoAnsi("Acesso Horario Especial") PIXEL
			@07,02 SAY OemToAnsi("Chave Desbloqueio")+":" OF oDlgBlq PIXEL
			@05,50 GET cPassw OF oDlgBlq PIXEL SIZE 90,9
			@20,100 BUTTON "Validar" PIXEL OF oDlgBlq SIZE 44,11 ACTION (lRet:=U_VALCHV(cPassw),oDlgSeek:End())
			ACTIVATE MSDIALOG oDlgBlq CENTERED
		else
			lBlq:=.F.
		endif
	else
		lBlq:=.F.
	endif
	if lBlq
		final("Acesso Em Horario Nao Autorizado","Acesso Bloqueado")
	endif
Return
	********************************
User Function ValCHV(cPassw)
	*******************************
//0320130521194800
//0521201305212013
	Local cInd  :="0123456789ABCDEFGHIJKLMNOPQ"
	Local cChave:=strzero(day(date()),2)+strzero(month(date()),2)+strzero(year(date()),4)
	Local lRet  :=.F.
	Local cRes  :=""
	Local i     :=0
	cChave+=cChave+cChave
	if len(alltrim(cPassw))==22
		lRet:=.T.
		for i:=1 to 22
			nPosS:=at(substr(cPassw,i,1),cInd)-1
			nPosC:=at(substr(cChave,i,1),cInd)-1
			if nPosS<nPosc
				lRet:=.F.
			else
				cRes :=cRes+str(nPosS-nPosC,1)
			endif
		next
		if lRet
			if len(alltrim(cRes))==22
				if substr(cRes,1,2)<>cEmpAnt
					lRet:=.F.
				else
					if substr(cRes,3,8)<>dtos(date())
						lRet:=.F.
					else
						if substr(cRes,11,2)+":"+substr(cRes,13,2)+":"+substr(cRes,15,2)>=TIME()
							lRet:=.F.
						else
							if substr(cRes,17,2)+":"+substr(cRes,19,2)+":"+substr(cRes,21,2)>=TIME()
								lRet:=.F.
							else
								cQuery:="INSERT INTO HORALIB VALUES('"+cEmpAnt+"','"+dtos(date())+"','"
								cQuery+=substr(cRes,11,2)+":"+substr(cRes,13,2)+":"+substr(cRes,15,2)+"','"
								cQuery+=substr(cRes,17,2)+":"+substr(cRes,19,2)+":"+substr(cRes,21,2)+"','"
								cQuery+=substr(cUsuario,7,15)+"') "
								Begin Transaction
									TCSQLExec(cQuery)
								End Transaction
							endif
						endif
					endif
				endif
			else
				lRet:=.F.
			endif
		endif
	endif
	if !lRet
		final("Acesso Em Horario Nao Autorizado","Acesso Bloqueado")
	endif
Return(lRet)

	**************************
User Function FLOCLOJA(_cOpc)
	**************************
	local oGetLocal
	Local aReto :={}
	LOCAL _cLoc := ""

//	aReto :={ "CH = Chegue" , "CT = Cart„o" , "DH = Dinheiro" , "NP = Nota Promissoria"}
	AADD(aReto,'             ')
	AADD(aReto,'1-LOJA DE RUA')
	AADD(aReto,'2-SHOPPING')
	AADD(aReto,'3-C.COMPRA')
	AADD(aReto,'4-HIPER MERCADO')
	AADD(aReto,'A-INDUSTRIA')
	AADD(aReto,'B-LOJA DE MOVEIS')
	AADD(aReto,'C-LOJA DECORACAO')
	AADD(aReto,'D-ESP. COLCHAO')
	AADD(aReto,'E-SUPERMERCADOS')
	AADD(aReto,'F-MOVE OUTROS')
	AADD(aReto,'G-MAT. CONSTRUCAO')

//_cLoc := areto(aScan(areto
/*AADD(aReto,{'1','LOJA DE RUA'})
AADD(aReto,{'2','SHOPPING'})
AADD(aReto,{'3','C.COMPRA'})
AADD(aReto,{'4','HIPER MERCADO'})
AADD(aReto,{'A','INDUSTRIA'})
AADD(aReto,{'B','LOJA DE MOVEIS'})
AADD(aReto,{'C','LOJA DECORACAO'})
AADD(aReto,{'D','ESP. COLCHAO'})
AADD(aReto,{'E','SUPERMERCADOS'})
AADD(aReto,{'F','MOVE OUTROS'})
AADD(aReto,{'G','MAT. CONSTRUCAO'})*/

//Avalia se a chamada È somente para validar a digitaÁ„o da vari·vel
	If _cOpc == "V"
	_nPos := ascan(aReto,M->A1_XLOCAL)
		IF _nPos > 0
		Return(.T.)
		Else
		MsgBox("LocalizaÁ„o de Loja n„o cadastrada. Informe um local v·lido!")
		Return(.F.)
		Endif
	ELSEIf _cOpc == "R"
	//Retorno para o relatÛrio de Mapa de Loja
	Return(aReto)
	EndIf

DEFINE MSDIALOG oDlgList TITLE "LocalizaÁ„o da Loja" FROM 000, 000 TO 180, 370 PIXEL

DEFINE Font  oFont1 Name "Arial" Size 0,-12 Bold

//@ 010, 005 Say "Escolha a localizaÁ„o da lojaInforme o Cliente e Data de BalanÁo" Font oFont1 PIXEL
@ 020,005 to 065,185 Pixel
@ 030,009 Say "Local:" Size 49,8 Pixel

	@ 030,050 ComboBox oGetLocal Var _cLoc  Items aReto size 100,10 Pixel
//@ 030,050 MsGet  oGetCod   	Var _cLoc  	PICTURE "@!" Size 030,010 F3 "SA1" Valid fvalidcod()  Pixel
//@ 030,080 MsGet  oSayNome  	Var _cDesc	PICTURE "@!" Size 100,08  When .F.  Pixel


//DEFINE SBUTTON FROM 070, 115 TYPE 1 ENABLE OF oDlgList ACTION fLocBAL(_cCLIENTE+DTOS(_cDTBAL))
DEFINE SBUTTON FROM 070, 115 TYPE 1 ENABLE OF oDlgList ACTION (IIf(inclui .or. altera,FLOCFGLB(SUBSTR(_cLoc,1,1)),),oDlgList:End())
DEFINE SBUTTON FROM 070, 150 TYPE 2 ENABLE OF oDlgList ACTION oDlgList:End()

	IF INCLUI .OR. ALTERA
	_nPos := ascan(aReto,M->A1_XLOCAL)
	ELSE
	_nPos := ascan(aReto,SA1->A1_XLOCAL)
	ENDIF
	IF _nPos > 0
	_cLoc := Alltrim(aReto[_npos])
	Else
	_cLoc := ' '
	Endif

ACTIVATE DIALOG oDlgList CENTERED


return(.t.)
Static Function FLOCFGLB(_cLocLj)

GlbLock()
PutGlbValue("_cLocLoja",Alltrim(_cLocLj))
GlbUnLock()

Return()

**********************************************************************************
User Function RoundUp(nValor, nDecimais)
**********************************************************************************

Local nRet	:= 0
Local nX	:= 0
Local nY	:= 0

Default nDecimais := 0

nY := nValor
	While nX < nDecimais
	nY := nY * 10
	nX++
	EndDo
nRet := Int(nY)
nRet += IIf(nRet < nY, 1, 0)
	While nX > 0
	nRet := nRet / 10
	nX--
	EndDo

Return nRet

**********************************************************************************
User Function LogHistori(cArquivo, cProcOri, nDtExpir)
**********************************************************************************
Local _cArqName	:= ""
Local _cFlNm	:= ""
Local _cNewFlNm := ""
Local _cExt		:= ""
Local _nPosPont := 0
Local _cFullPth := "\"
Local _cDirDest := ""
Local _cBuffer	:= ""
Local _cChrTmp	:= ""
Local nX		:= 0
Local _cDtExpir	:= DToS(dDataBase - IIf(ValType(nDtExpir) == 'N' .And. nDtExpir > 0, nDtExpir, 45))
Local _aArqHist	:= {}
Local lContinua	:= ValType(cArquivo) == "C" .And. !Empty(cArquivo) .And. File(cArquivo)

	If ValType(cProcOri) <> "C"
	cProcOri := ""
	EndIf

	If lContinua
		For nX := 1 To Len(cArquivo)
		_cChrTmp := SubStr(cArquivo, nX, 1)
			If _cChrTmp == "\" .And. nX == 1
			Loop
			ElseIf _cChrTmp == "\"
				If !Empty(_cBuffer)
				_cFullPth += _cBuffer + "\"
				_cBuffer := ""
					If !ExistDir(_cFullPth)
					lContinua := .F.
					Exit
					EndIf
				EndIf
			ElseIf nX == Len(cArquivo)
			_cBuffer += _cChrTmp
				If !File(_cFullPth + _cBuffer) .Or. ExistDir(_cFullPth + _cBuffer)
				lContinua := .F.
				Exit
				EndIf
			_cArqName := _cBuffer
			_cBuffer := ""
			Else
			_cBuffer += _cChrTmp
			EndIf
		Next nX
	EndIf

lContinua := lContinua .And. File(_cFullPth + _cArqName)

	If lContinua
	_cDirDest	:= _cFullPth + "loghistori\"
		If !ExistDir(_cDirDest)
		MakeDir(_cDirDest)
			If !ExistDir(_cDirDest)
			lContinua := .F.
			EndIf
		EndIf
	EndIf

	If lContinua
	_nPosPont := Len(_cArqName)
		While _nPosPont >= 1
			If SubStr(_cArqName,_nPosPont,1) == "."
			Exit
			EndIf
		_nPosPont--
		EndDo
		If _nPosPont == 0
		_cFlNm		:= _cArqName
		_cExt		:= ""
		Else
		_cFlNm		:= SubStr(_cArqName, 1, _nPosPont - 1)
		_cExt		:= SubStr(_cArqName, _nPosPont + 1, Len(_cArqName) - _nPosPont)
		EndIf
	_cNewFlNm	:= _cFlNm + "_" + DToS(dDataBase) + "_" + StrZero(Round(SECONDS()*100,0),10)
	_cNewFlNm	+= IIf(!Empty(_cExt), "." + _cExt, "")
	EndIf

	If lContinua
	TarCompress({_cFullPth+_cArqName},_cDirDest+_cNewFlNm+".tar")
	GzCompress(_cDirDest+_cNewFlNm+".tar",_cDirDest+_cNewFlNm+".tar.gz")
	FErase(_cDirDest+_cNewFlNm+".tar")
	lContinua := File(_cDirDest+_cNewFlNm+".tar.gz")
	EndIf

	If lContinua
	Conout(AllTrim(DToS(dDataBase))+" "+AllTrim(TIME())+" - Log do processo '"+AllTrim(cProcOri)+"' gravado com sucesso! Arquivo '"+_cDirDest+_cNewFlNm+".tar.gz'")
	Else
	Conout(AllTrim(DToS(dDataBase))+" "+AllTrim(TIME())+" - Falha ao gravar o log do processo '"+AllTrim(cProcOri)+"'")
	EndIf

	If lContinua
	ADir(_cDirDest+AllTrim(PADR(_cFlNm, 8))+"*.tar.gz", _aArqHist)
		For nX := 1 To Len(_aArqHist)
			If SubStr(_aArqHist[nX], Len(_cFlNm) + 2, 8) < _cDtExpir
			FErase(_cDirDest+_aArqHist[nX])
			EndIf
		Next nX
	EndIf

Return lContinua

**********************************************************************************
User Function JobCInfo(cFonte, cMsg, nLevel, nForLevel)
**********************************************************************************

Local _aTmp     := {}
Local _aFiles	:= {}
Local _aSizes	:= {}
Local _nHandle	:= 0
Local _cRet     := "JOBCINFO;" + AllTrim(Str(ThreadID())) + ";"
Local _lOk      := .T.
Local _cCurTime := DToC(DATE()) + "-" + AllTrim(TIME())

Local cUrl		:= "http://apps.ortobom.com.br/logsigo/job.php"
Local nTimeOut 	:= 30
Local sPostRet 	:= ""
Local cPost		:= ""

Default nLevel := 2	//2 - INFO, 1 - WARN, 0 - ERROR
Default nForLevel := -1

	If ValType(cMsg) <> 'C'
	cMsg := ""
	EndIf

cMsg := AllTrim(cMsg)

	If ValType(cFonte) <> "C" .Or. Empty(cFonte)
	cFonte := "ErroParametro("+ValType(cFonte)+");"
	_cRet  += cFonte
	_lOk   := .F.
	EndIf

	If _lOk
	cFonte := AllTrim(Upper(cFonte))
	_aTmp  := GetAPOInfo(cFonte)
		If ValType(_aTmp) <> 'A' .Or. Len(_aTmp) < 5
		_cRet += "ErroAPO("+cFonte+");"
		_lOk  := .F.
		EndIf
	EndIf

_cRet += _cCurTime + ";"

	If _lOk
	_cRet += Upper(AllTrim(GetEnvServer())) + ";"
	_cRet += IIf(ValType(cEmpAnt)=="C",cEmpAnt,"") + ";"
	_cRet += IIf(ValType(cFilAnt)=="C",cFilAnt,"") + ";"
	_cRet += cFonte + "[" + AllTrim(DToC(_aTmp[4])) + "-" + AllTrim(_aTmp[5]) + "];"
	EndIf

	If _lOk
		If nForLevel == 0 .Or. nLevel == 0
		_cRet += "ERROR;"
		ElseIf nForLevel == 1 .Or. nLevel == 1
		_cRet += "WARN;"
		Else
		_cRet += "INFO;"
		EndIf
	EndIf

_cRet += cMsg

Conout(_cRet)

_lOk	:= .F.

cPost    := "u="+alltrim(cEmpAnt)+"&f="+alltrim(cFonte)+"&m="+alltrim(_cRet)+"&l="+alltrim(str(nLevel))+""
sPostRet := httpPost(cUrl, "", cPost, nTimeOut)

	If _lOk
		If !ExistDir("\logs")
		MakeDir("\logs")
		EndIf
		If !File("\logs\job.log")
		_nHandle	:= FCreate("\logs\job.log")
		Else
		_nHandle	:= FOpen("\logs\job.log",64)
		EndIf
		If _nHandle <> -1
		FSeek( _nHandle, 0, 2 )
		FWrite( _nHandle, _cRet + CHR(13) + CHR(10) )
		FClose( _nHandle )
		SocketConn("10.0.100.120",8015,_cRet,1)
		ADir("\logs\job.log", _aFiles, _aSizes)
			If ValType(_aSizes) == 'A' .And. Len(_aSizes) > 1 .And. _aSizes[1] > 10485760	//Tamanho limite: 10MB
				If U_LogHistori("\logs\job.log", "JOBCINFO", 1000)
				FErase("\logs\job.log")
				EndIf
			EndIf
		EndIf
	EndIf

	If _lOk .And. nLevel < 2
	U_JobCInfo(cFonte, cMsg, nLevel+1, nForLevel)
	EndIf

Return _cRet

**********************************************************************************
User Function MsgErAut(cErroExAut)
**********************************************************************************

Local _cRet		:= ""
Local _cCampo	:= ""
Local _cTit		:= ""
Local _nX		:= 0
Local _nHandle	:= 0

//-----------------------------------
// armazena a mensagem de erro padrao
	If !ExistDir("\logs")
	MakeDir("\logs")
	EndIf
	If !File("\logs\ortp043.log")
	_nHandle	:= FCreate("\logs\ortp043.log")
	Else
	_nHandle	:= FOpen("\logs\ortp043.log",64)
	EndIf
	If _nHandle <> -1
	FSeek( _nHandle, 0, 2 )
	FWrite( _nHandle, cErroExAut + CHR(13) + CHR(10) )
	FClose( _nHandle )
	EndIf
// --------------------------------

cErroExAut	:= UPPER(cErroExAut)

	If "11" $ cVersao
	_nX		:= 1
		While !(SubStr(cErroExAut, _nX, 1) $ " :") .And. Len(cErroExAut) > _nX
		_nX++
		EndDo
		While SubStr(cErroExAut, _nX, 1) $ " :" .And. Len(cErroExAut) > _nX
		_nX++
		EndDo
		While SubStr(cErroExAut, _nX, 1) $ "ABCDEFGHIJKLMNOPQRSTUVWYXZ0123456789_" .And. Len(cErroExAut) > _nX
		_cCampo	+= SubStr(cErroExAut, _nX, 1)
		_nX++
		EndDo
		If !Empty(_cCampo)
		_cTit	:= AllTrim(GetSX3Cache(_cCampo,"X3_DESCRIC"))
			If !Empty(_cTit)
			_cRet	:= "O campo '"+_cTit+"' ("+AllTrim(_cCampo)+") est· inv·lido."
			EndIf
		EndIf
	EndIf

Return _cRet

**********************************************************************************
User Function ORTQUERY(cParQuery, cParAlias, cArquivo, lDebug)
**********************************************************************************
Local cPath       := "C:\querys"
DEFAULT cParAlias := GetNextAlias()
DEFAULT cArquivo  := cParAlias+".sql"
Default lDebug	  := .T.

IF !IsBlind()
	cPath += "\"+cUserName
endif
If Empty(cParAlias)
	cParAlias	:= GetNextAlias()
Else
cParAlias	:= AllTrim(PADR(UPPER(cParAlias), 10))
EndIf
If Select(@cParAlias) > 0
	(cParAlias)->(dbCloseArea())
EndIf
MakeDir(cPath)
If lDebug
	Memowrite(cPath+"\"+cArquivo, cParQuery)
Endif
TCQUERY cParQuery ALIAS ( cParAlias ) NEW
Return cParAlias

**********************************************************************************
User Function GeraNPed()
**********************************************************************************

Local cNumPed	:= ""

cNumPed	:= GetSXENum("SC5","C5_NUM")
DbSelectArea("SC5")
dbOrderNickName("PSC51")
dbSeek(xFilial("SC5") + cNumPed)
	Do While Found()
	confirmSX8()
	cNumPed := GetSXENum("SC5","C5_NUM")
	dbGoTop()
	dbseek(xFilial("SC5")+cNumPed)
	EndDo

Return cNumPed

**********************************************************************************
User Function GetAKits(cKitDe, cKitAte, cGrupoDe, cGrupoAte)
**********************************************************************************

Local cCodPro	:= ""
Local cDesPro	:= ""
Local cGrpPro	:= ""
Local lPrinc	:= .F.
Local cRefKit	:= ""
Local cNomeKit	:= ""
Local cCodKit	:= ""
Local cGrpKit	:= ""

Local cQuery	:= ""
Local aGrupos	:= {}
Local aKits		:= {}

Local aTmp		:= {}

Local nX		:= 0
Local nPKit		:= 0
Local nPGrp		:= 0

/*
aGrupos
01 - Codigo
02 - Nome
03 - aKits
*/

/*
aKits
01 - Codigo
02 - Nome
03 - Referencias
04 - Produto Principal
05 - DescriÁ„o produto principal
06 - Grupo
07 - aProdutos
*/

/*
aProdutos
01 - Codigo
02 - DescriÁ„o
*/

	cQuery	:= " SELECT PAK_GRUPO, "
	cQuery	+= "        PAK_CODKIT, "
	cQuery	+= "        PAK_PRINC, "
	cQuery	+= "        PAK_CODPRO, "
	cQuery	+= "        B1_GRUPO, "
	cQuery	+= "        BM_DESC, "
	cQuery	+= "        PAK_NOME, "
	cQuery	+= "        PAK_REFTAB "
	cQuery	+= "   FROM "+RetSqlName("PAK")+" PAK, "+RetSqlName("SB1")+" SB1, "+RetSqlName("SBM")+" SBM "
	cQuery	+= "  WHERE PAK.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SB1.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SBM.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND PAK_FILIAL = '"+xFilial("PAK")+"' "
	cQuery	+= "    AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery	+= "    AND BM_FILIAL = '"+xFilial("SBM")+"' "
	cQuery	+= "    AND PAK_CODKIT BETWEEN '"+cKitDe+"' AND '"+cKitAte+"' "
	cQuery	+= "    AND PAK_GRUPO BETWEEN '"+cGrupoDe+"' AND '"+cGrupoAte+"' "
	cQuery	+= "    AND B1_COD = PAK_CODPRO "
	cQuery	+= "    AND BM_GRUPO = B1_GRUPO "
	cQuery	+= "  ORDER BY 1, 2, 3 DESC "
	U_ORTQUERY(cQuery, "GETAKITS")
	While !(GETAKITS->(EOF()))

		cCodPro	:= PADR(GETAKITS->PAK_CODPRO, GetSX3Cache("B1_COD", "X3_TAMANHO"))
		cDesPro	:= PADR(GETAKITS->BM_DESC, GetSX3Cache("BM_DESC", "X3_TAMANHO"))
		cGrpPro	:= PADR(GETAKITS->B1_GRUPO, GetSX3Cache("B1_GRUPO", "X3_TAMANHO"))
		lPrinc	:= (AllTrim(GETAKITS->PAK_PRINC) == 'S')
		cRefKit	:= PADR(GETAKITS->PAK_REFTAB, GetSX3Cache("PAK_REFTAB", "X3_TAMANHO"))
		cNomeKit:= PADR(GETAKITS->PAK_NOME, GetSX3Cache("PAK_NOME", "X3_TAMANHO"))
		cCodKit	:= PADR(GETAKITS->PAK_CODKIT, GetSX3Cache("PAK_CODKIT", "X3_TAMANHO"))
		cGrpKit	:= PADR(GETAKITS->PAK_GRUPO, GetSX3Cache("PAK_GRUPO", "X3_TAMANHO"))

		nPKit		:= AScan(aKits, {|x| x[1] == cCodKit})

		If nPKit == 0
			aAdd(aKits, {cCodKit, cNomeKit, cRefKit, "", "", cGrpKit, "", {}})
			nPKit	:= Len(aKits)
		EndIf

		If lPrinc
			aKits[nPKit,02]	:= cNomeKit
			aKits[nPKit,04]	:= cCodPro
			aKits[nPKit,05]	:= cDesPro
			aKits[nPKit,07]	:= cGrpPro
		Else
			aAdd(aKits[nPKit,08], {cCodPro, cDesPro})
		EndIf

		GETAKITS->(dbSkip())
	EndDo
	GETAKITS->(dbCloseArea())

	For nPKit := 1 To Len(aKits)
		cGrpKit		:= aKits[nPKit,06]
		nPGrp		:= AScan(aGrupos, {|x| x[1] == cGrpKit})

		If nPGrp == 0
			aAdd(aGrupos, {cGrpKit, "", {}})
			nPGrp	:= Len(aGrupos)
		EndIf

		aAdd(aGrupos[nPGrp, 03], aKits[nPKit])
	Next nPKit

	For nPGrp := 1 To Len(aGrupos)
		If !Empty(aGrupos[nPGrp,02])
			Loop
		EndIf

		cDesPro	:= PADR(aGrupos[nPGrp,03,01,05], GetSX3Cache("BM_DESC", "X3_TAMANHO"))

		If nPGrp == Len(aGrupos)
			aGrupos[nPGrp,02]	:= cDesPro
			Loop
		EndIf

		cGrpKit	:= aGrupos[nPGrp,03,01,07]
		aTmp	:= {}

		For nX := 1 To Len(aGrupos)
			If aGrupos[nX,03,01,07] == cGrpKit
				aAdd(aTmp, nX)
			EndIf
		Next nX

		For nX := 1 To Len(aTmp)
			aGrupos[aTmp[nX],02]	:= AllTrim(cDesPro) + IIf(Len(aTmp) > 1, " - " + AllTrim(Str(nX)), "")
		Next nX
	Next nPGrp

Return aGrupos

	**********************************************************************************
User Function ORTGRUPO(cGrupo, cUsGrp)
	**********************************************************************************

	Local nX			:= 0
	Local cCodGrpVld	:= ""
	Local aVldInfUsr	:= {}
	Local aGruposVld	:= AllGroups()

	If Empty(cUsGrp)
		cUsGrp	:= __cUserID
	EndIf

	PswOrder(1)
	PswSeek(cUsGrp, .T.)
	aVldInfUsr	:= PswRet(1)

	cCodGrpVld	:= ""
	nX	:= AScan(aGruposVld, {|x| AllTrim(UPPER(x[1,2])) == AllTrim(UPPER(cGrupo))})
	If nX > 0
		cCodGrpVld	:= aGruposVld[nX][1][1]
	EndIf

	If Empty(cCodGrpVld) .Or. AScan(aVldInfUsr[1,10], {|x| AllTrim(x) == AllTrim(cCodGrpVld)}) == 0
		If alltrim(cUserName) $ "victor|fabio|castro|thais|henrique"
			Return MsgYesNo("ForÁar liberaÁ„o '"+cGrupo+"'?")
		Else
			Return .F.
		EndIf
	endif

Return .T.



	**********************************************************************************
User Function fDelSZB()
	**********************************************************************************

	dbSelectArea("SZB")

	If AllTrim(SZB->ZB_TPOPER) == 'TF'
		U_ORTP051L(SZB->ZB_CHEQUE, SZB->ZB_NUMPED)
	EndIf

	If AllTrim(SZB->ZB_TPOPER) $ 'CC|CD'
		u_MarkPA7(SZB->ZB_BANCAR,SZB->ZB_AUTORIZ,SZB->ZB_NUMCAR,5,"","","","A")
	EndIf


	RecLock("SZB",.F.)
	SZB->(DbDelete())
	MsUnLock()

Return .T.

	************************************************************
User Function ApurComis(cSegm, cDtini, cDtfin)
	************************************************************
	Local cQuery:=""
	Local aRet:={}
	cQuery:="SELECT e3_xnumger, SUM(E3_BASE) TOT FROM "+RetSQLName("SE3")+" SE3, "+RetSQLName("SA1")+" SA1 , "+RetSQLName("SC5")+" SC5 "
	cQuery+="WHERE E3_FILIAL = '" + xFilial("SE3") + "' "
	cQuery+="  AND A1_FILIAL = '  ' "
	cQuery+="  AND E3_CODCLI = A1_COD "
	cQuery+="  AND SE3.D_E_L_E_T_ =  ' ' "
	cQuery+="  AND SA1.D_E_L_E_T_ =  ' ' "
	cQuery+="  AND A1_XTIPO = '"+cSegm+"' "
	cQuery+="  AND E3_XDTINI = '"+cDtini+"' "
	cQuery+="  AND E3_XDTFIN = '"+cDtfin+"' "
	cQuery+="  AND SUBSTR(E3_XTPCOM,1,10) IN ('COMISSAO  ','COM_EUND14') "

	cQuery+="  AND SC5.C5_FILIAL   = '"+xFilial("SC5")+"' "
	cQuery+="  AND SC5.C5_NUM      = E3_PEDIDO "
	cQuery+="  AND SC5.C5_XOPER    <> '97' "
	cQuery+="  AND SC5.D_E_L_E_T_  = ' ' "

	cQuery+="GROUP BY e3_xnumger "
	TCQUERY cQuery ALIAS "QRYAPUR" new
	dbselectarea("QRYAPUR")
	aRet:={QRYAPUR->TOT, QRYAPUR->E3_XNUMGER}
	dbclosearea()
Return(aRet)
	*******************************************
User Function dbQuery( cQuery , cAlias )
	*******************************************
	DEFAULT cAlias := GetNextAlias()
	IF ( Select( @cAlias ) > 0 )
		( cAlias )->( dbCloseArea() )
	EndIF
	TCQUERY ( cQuery ) ALIAS ( cAlias ) NEW
Return( .NOT.( ( cAlias )->( Bof() .and. Eof() ) ) )

	*******************************************
User Function rnkfor(unde,unate,grpde,grpate,datade, dataate, codde,codate,numfor,lUPME,nOrd,ntprnk)
	*******************************************
	Local cQuery:=""
	Local cTmpTab:=""
	Default nTpRnk:=1
	cTmpTab:="RNKF_"+CriaTrab(,.F.)
	cQuery:="CREATE TABLE "+cTmpTab+" AS ("
	IF NUMFOR > 0
		cQuery+=" SELECT * FROM ( "
	ENDIF
	if nTpRnk==1
		cQuery+="SELECT FORNECE, A2_NOME, "
	else
		cQuery+="SELECT B1_COD FORNECE, B1_DESC A2_NOME, "
	endif
	cQuery+="SUM(QTD) QTD, SUM(QTD*VLRUN"+IIF(LUPME,"/M2_MOEDA5","")+") VLR "
	cQuery+="  FROM CONSUMOMP, SA2030 SA2, SB1030 SB1 "
	if lUPME
		cQuery+=", SM2030 SM2 "
	endif
	cQuery+=" WHERE FORNECE = A2_COD  "
	if lUPME
		cQuery+=" AND M2_DATA = DTMOV "
		cQuery+=" AND SM2.D_E_L_E_T_ = ' '  "
	endif
	cQuery+="   AND COD = B1_COD      "
	cQuery+="   AND A2_FILIAL = ' '   "
	cQuery+="   AND B1_FILIAL = ' '   "
	cQuery+="   AND SA2.D_E_L_E_T_ = ' '  "
	cQuery+="   AND SB1.D_E_L_E_T_ = ' '  "
	IF !EMPTY(UNDE) .OR. UPPER(UNATE)<>"ZZ"
		cQuery+="   AND UN BETWEEN '"+UNDE+"' AND '"+UNATE+"' "
	ENDIF
	IF !EMPTY(GRPDE) .OR. UPPER(GRPATE)<>"ZZZZ"
		cQuery+="   AND B1_GRUPO BETWEEN '"+GRPDE+"' AND '"+GRPATE+"' "
	ENDIF
	IF !EMPTY(DATADE) .OR. DATAATE < DATE()+60
		cQuery+="   AND DTMOV BETWEEN '"+DTOS(DATADE)+"' AND '"+DTOS(DATAATE)+"' "
	ENDIF
	IF !EMPTY(CODDE) .OR. SUBSTR(UPPER(CODATE),1,4)<>"ZZZZ"
		cQuery+="   AND COD BETWEEN '"+CODDE+"' AND '"+CODATE+"' "
	ENDIF
	if nTpRnk==1
		cQuery+="GROUP BY FORNECE, A2_NOME  "
	else
		cQuery+="GROUP BY B1_COD, B1_DESC  "
	endif
	IF NUMFOR > 0
		cQuery+="ORDER BY "+STR(NORD+2)+" DESC "
		cQuery+=" ) WHERE ROWNUM <= "+str(numfor)
	ENDIF
	cQuery+=") "
	memowrite("RNKFOR.SQL",cQuery)
	tcsqlexec(cQuery)
Return(cTmpTab)
	*******************************************
User Function delrnkfor(cTab)
	*******************************************
	U_ORTQUERY("SELECT TABLE_NAME FROM USER_TABLES WHERE TABLE_NAME = '"+cTab+"'", "CHKTBL")
	If CHKTBL->(!EOF())
		TcSqlExec("DROP TABLE "+cTab)
	EndIf
	CHKTBL->(dbCloseArea())
Return
	******************************************
User Function CalcCodBar(cLinDig)
	******************************************
//Calcula Codigo de barra a partir da linha digitavel
	Local cRet:=""
	Local cCpoLivreCodBar := 	Substr(Alltrim(cLinDig),05,05)+;	// Campo Livre no Codigo de Barras		X(005)
	Substr(Alltrim(cLinDig),11,10)+;					// Campo Livre no Codigo de Barras		X(010)
	Substr(Alltrim(cLinDig),22,10) 					// Campo Livre no Codigo de Barras		X(010)

	cRet:= Padl(SUBSTR(cLinDig,1,3),3," ")   	//	  BANCO FAVORECIDO		C”D. DE BARRAS ñ C”DIGO 			018 020	9(03)	NOTA 18
//							BANCO FAVORECIDO
	cRet+= "9"										//	  MOEDA 				C”D. DE BARRAS ñ C”DIGO DA MOEDA 	021 021 9(01) 	NOTA 18
	cRet+= Substr(Alltrim(cLinDig),33,01)	//	  DV					C”D. DE BARRAS ñ DÕGITO VERIF. DO 	022 022 9(01) 	NOTA 18
//    						C”D. BARRAS
	cRet+= Substr(Alltrim(cLinDig),34,04)	//	  VENCIMENTO 			C”D. DE BARRAS ñ FATOR DE 			023 026 9(04) 	NOTA 18
//							VENCIMENTO
	cRet+= Substr(Alltrim(cLinDig),38,10)	//    VALOR					C”D. DE BARRAS ñ VALOR				027 036	9(08)	V9(02) NOTA 18
	cRet+= cCpoLivreCodBar						//    CAMPO LIVRE 			C”D. DE BARRAS - 'CAMPO LIVRE' 		037 061 9(25) 	NOTA 18
Return(cRet)
	*******************************************
User Function vercod(cMP,cPA)
	*******************************************
	Local aRet:={}
	dbselectarea("SB1")
	dbsetorder(1)
	if dbseek(xFilial("SB1")+cPA)
		aadd(aRet,SB1->B1_XMED)
	else
		aadd(aRet,"XXXXXXXXXX")
	endif
	if dbseek(xFilial("SB1")+cMP)
		aadd(aRet,SB1->B1_FABRIC)
	else
		aadd(aRet,"XXXXXXXXXX")
	endif
return(aRet)
	*****************************
User Function FValEmail(cEmail)
	*****************************
	Local lRet:=.T.
	Local lValDom:=.F.
	Local cDom:=""
	if dtos(dDatabase)>="20150520"
		IF AT("@",cEmail)<2 .OR. AT("@",cEmail)>=LEN(ALLTRIM(cEmail))-3 .OR.;
				AT(" ",ALLTRIM(cEmail))>0
			lRet := .F.
		ELSE
			cDom:=rtrim(substr(cEmail,AT("@",cEmail)+1))
			do while at(".",cDom)>0 .and. !lValDom
				lValDom	:=	U_fValDom(substr(cDom,1,AT(".",cDom)-1))
				cDom:=substr(cDom,AT(".",cdom)+1)
			enddo
			if !lValdom
				lValDom	:= U_fValDom(cDom)
			endif
			if !lValDom
				lRet := .F.
			endif
		ENDIF
	endif
Return(lRet)
	*****************************
User Function FValDom(cDom)
	*****************************
	Local lRet:=.F.
	if UPPER(cDom)$("COM|GOV|JUS|NET|EDU|TUR|ORG|COOP|ADV|IND|FR|BR|NL") .OR. cDom$GetNewPar("MV_XVALDOM"," ") //SSI 12110 - Incluido DomÌnio: IND //SSI 15492 - incluÌdo domÌnio NL
		lRet:=.T.
	endif
Return(lRet)

	******************************
User Function ORTDSR(nTp, cMesAno, dDataDe, dDataAte)
// nTp = NIL ou Zero retorna todos os dias
// nTp = 1 retorna a quantidade de dias uteis do mes da folha
// nTp = 2 Retorna a quantidade de feriados e finais de semana
	******************************

	Local cQuery	:= ""
	Local nRetorno	:= 0

	If ValType(nTp) <> "N"
		nTp	:= 0
	EndIf

	If ValType(cMesAno) <> "C" .Or. Len(cMesAno) < 6
		cMesAno	:= SubStr(DToS(dDataBase), 5, 2) + SubStr(DToS(dDataBase), 1, 4)
	EndIf

	If Empty(dDataDe) .Or. ValType(dDataDe) <> "D" .Or. Empty(dDataAte) .Or. ValType(dDataAte) <> "D"
		dDataDe		:= SToD(SubStr(cMesAno, 3, 4) + SubStr(cMesAno, 1, 2) + "01")
		dDataAte	:= LastDay(dDataDe)
	Endif

	nRetorno	:= 0

	cQuery	:= " SELECT NVL(COUNT(DISTINCT RCG_DIAMES), 0) AS DIAS "
	cQuery	+= "   FROM "+RetSqlName("RCG")+" RCG "
	cQuery	+= "  WHERE RCG.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND RCG_FILIAL = '"+xFilial("RCG")+"' "
	cQuery	+= "    AND RCG_DIAMES BETWEEN '"+DToS(dDataDe)+"' AND '"+DToS(dDataAte)+"' "
	If nTp == 1
		cQuery	+= "    AND RCG_TIPDIA IN ('1','2') "
	ElseIf nTp == 2
		cQuery	+= "    AND RCG_TIPDIA NOT IN ('1','2') "
	EndIf
	U_ORTQUERY(cQuery, "ORTDSR")
	nRetorno	:= ORTDSR->DIAS
	ORTDSR->(dbCloseArea())

Return(nRetorno)

	******************************
User Function OPENSISL(lHomolog)
	******************************

	Local nHandMS	:= 0
	Local cTopNm	:= "MSSQL/ORTBHOMOLO"
	Local cTopIP	:= "10.0.100.95"
	Local nTopPr	:= 7890

	If ValType(lHomolog) <> "L"
		lHomolog	:= .F.
	EndIf

	If lHomolog
		cTopNm	:= "MSSQL/ORTBHOMOLO"
		cTopIP	:= "10.0.100.95"
		nTopPr	:= 7890
	Else
		cTopNm	:= "MSSQL/ORTBPROD"
		cTopIP	:= "10.0.100.95"
		nTopPr	:= 7890
	EndIf

	nHandMS	:= TcLink(cTopNm, cTopIP, nTopPr)
	If nHandMS < 0
		MsgStop("TcLink: Erro '"+AllTrim(Str(nHandMS))+"'")
	EndIf

Return nHandMS

	******************************
User Function CLOSSISL(nHandMS)
	******************************
	if nHandMS > 0
		TcUnLink(nHandMS)
	Endif
Return

	******************************
User Function OPENSWCA(cUnidade)
	******************************
	Local nHandMS	:= 0
	Local cTopNm	:= ""
	Local cTopIP	:= "10.0.100.95"
	Local nTopPr	:= 7890

	If ValType(cUnidade) <> "C" ; cUnidade := cEmpAnt ; EndIf

		cTopNm	:= "MYSQL/SWCAM" + cUnidade

		nHandMS	:= TcLink(cTopNm, cTopIP, nTopPr)
		If nHandMS < 0
			MsgStop("TcLink: Erro '"+AllTrim(Str(nHandMS))+"'")
		EndIf

		Return nHandMS

		******************************
User Function CLOSSWCA(nHandMS)
	******************************
	if nHandMS > 0
		TcUnLink(nHandMS)
	Endif
Return

	******************************
User Function OPENSISP(cUnidade)
	******************************

	Local nHandMS	:= 0
	Local cTopNm	:= "MYSQL/SISPED" + cUnidade
	Local cTopIP	:= "10.0.100.95"
	Local nTopPr	:= 7890

	nHandMS	:= TcLink(cTopNm, cTopIP, nTopPr)
	If nHandMS < 0
		MsgStop("TcLink: Erro '"+AllTrim(Str(nHandMS))+"'")
	EndIf

Return nHandMS

	******************************
User Function CLOSSISP(nHandMS)
	******************************
	if nHandMS > 0
		TcUnLink(nHandMS)
	Endif
Return

	******************************
User Function ORTVLDPS(cPedido, lVldFis, lVldFin)
	******************************

	Local nHandMS	:= 0
	Local cQuery	:= ""
	Local lExistSlj	:= .F.
	Local lRet		:= .T.
	Local lLibFis	:= .F.
	Local lLibFin	:= .F.

	If ValType(lVldFis) <> "L"
		lVldFis	:= .T.
	EndIf
	If ValType(lVldFin) <> "L"
		lVldFin	:= .T.
	EndIf

	nHandMS	:= U_OPENSISL()
	If nHandMS < 0
		Return .F.
	EndIf

	cQuery	:= " SELECT V.IdOrtobom "
	cQuery	+= "   FROM Venda V "
	cQuery	+= "   JOIN Loja L ON L.Id = V.LojaId "
	cQuery	+= "   JOIN Fabrica F ON F.Id = L.FabricaId "
	cQuery	+= "  WHERE V.IdOrtobom = '"+cPedido+"' "
	cQuery	+= "    AND F.IdOrtobom = '"+cEmpAnt+"' "
	U_ORTQUERY(cQuery, "ORTVLDPS_1")
	lExistSlj	:= ORTVLDPS_1->(!EOF())
	ORTVLDPS_1->(dbCloseArea())

	U_CLOSSISL(nHandMS)

	cQuery	:= " SELECT PEDIDO, MAX(FISICO) AS FISICO, MAX(FINANCEIRO) AS FINANCEIRO "
	cQuery	+= "   FROM PSLJLIB "
	cQuery	+= "  WHERE UNIDADE = '"+cEmpAnt+"' "
	cQuery	+= "    AND PEDIDO = '"+cPedido+"' "
	cQuery	+= "  GROUP BY PEDIDO "
	U_ORTQUERY(cQuery, "ORTVLDPS_2")
	lLibFis	:= .F.
	lLibFin	:= .F.
	If ORTVLDPS_2->(!EOF())
		lLibFis	:= ("S" == PADR(ORTVLDPS_2->FISICO, 01))
		lLibFin	:= ("S" == PADR(ORTVLDPS_2->FINANCEIRO, 01))
	EndIf
	ORTVLDPS_2->(dbCloseArea())

	lRet	:= !lExistSlj .Or. ((!lVldFis .Or. lLibFis) .And. (!lVldFin .Or. lLibFin))

Return lRet

// ------------------------------------------------------------------
// [ Leitura da tabela PBB (Arquivos CNAB Gerados) por unidade ]
// [ Chamada de ortr582.prw ]
// ------------------------------------------------------------------
User Function LePBB(cData, cDtLib)

	Local aArea	 := GetArea()
	Local cQuery := ''
	Local aRet   := {}

	Default cDtLib := ''

	cQuery := " SELECT unique PBB_UF  , PBB_BANCO , PBB_AGENCI, "
	cQuery += "               PBB_DVAG, PBB_CONTA , PBB_DVCONT, "
	cQuery += "               PBB_PR  , PBB_VALOR , PBB_ARQUIV, "
	cQuery += "               PBB_SEQ , PBB_EXTENS, PBB_NUMREG, "
	cQuery += "               PBB_DATA                          "
	cQuery += " FROM " + RetSQLName('PBB')         + " PBB      "
	cQuery += " WHERE         PBB.D_E_L_E_T_ = ' '             "
	cQuery += "           AND PBB_FILIAL      = '"+xFilial("PBB")+"' "
	cQuery += "           AND PBB_SITUAC <> 'E' "	//ARQUIVO ESTORNADO
	cQuery += "           AND PBB_DATA        = '" + cData + "' "

	If !Empty( cDtLib )

		cQuery += "           AND PBB_DTLIB        = '" + cDtLib + "' "

	EndIf

	MemoWrite('C:\ORTR582.SQL', cQuery)
	If ( Select('TMPa') > 0 )
		TMPa->( dbCloseArea() )
	EndIf
	TcQuery cQuery Alias 'TMPa' New
	dbselectarea('TMPa')
	TMPa->(dbGoTop())
	do while !eof()

		Aadd(aRet,{ TMPa->PBB_UF     ,;
			TMPa->PBB_BANCO  ,;
			TMPa->PBB_AGENCI ,;
			TMPa->PBB_DVAG   ,;
			TMPa->PBB_CONTA  ,;
			TMPa->PBB_DVCONT ,;
			TMPa->PBB_PR     ,;
			TMPa->PBB_VALOR  ,;
			TMPa->PBB_ARQUIV ,;
			TMPa->PBB_SEQ    ,;
			TMPa->PBB_EXTENS ,;
			TMPa->PBB_NUMREG ,;
			TMPa->PBB_DATA   ,;
			cEmpAnt})

		TMPa->(DbSkip())

	enddo

	dbclosearea()
	RestArea(aArea)
Return(aRet)

// ------------------------------------------------------------------
// [ Leitura da tabela PAZ (Tabela de liberaÁao de Hor·rio) ]
// [ Chamada de orta635.prw ]
// ------------------------------------------------------------------
User Function LePAZ(cData)

	Local aArea	 := GetArea()
	Local cQuery := ''
	Local aRet   := {}

	cQuery := " SELECT * "
	cQuery += " FROM " + RetSQLName('PAZ')         + " PAZ      "
	cQuery += " WHERE         PAZ.D_E_L_E_T_ = '*'             "
	cQuery += "           AND PAZ_FILIAL      = '"+xFilial("PAZ")+"' "
	cQuery += "           AND PAZ_VENCTO        = '" + cData + "' "
	cQuery += "           AND PAZ_ORIGEM        = ' ' "
	MemoWrite('C:\ORTA635.SQL', cQuery)
	If ( Select('TMPa') > 0 )
		TMPa->( dbCloseArea() )
	EndIf
	TcQuery cQuery Alias 'TMPa' New
	dbselectarea('TMPa')
	TMPa->(dbGoTop())
	do while !eof()

		Aadd(aRet,{ cEmpAnt     ,;
			TMPa->PAZ_DTLIMI ,;
			TMPa->PAZ_HORALI })

		TMPa->(DbSkip())

	enddo

	dbclosearea()
	RestArea(aArea)

Return(aRet)

// ------------------------------------------------------------------
	*----------------------------------------------------------*
User Function SANITIZE( _cNomeArquivo, cCharEsp )
	*----------------------------------------------------------*
	Local _nT   := 0
	Local _cRet   := _cNomeArquivo
	Local _aCaracteres := Nil

	If ValType(cCharEsp) <> "C"
		cCharEsp	:= "_"
	EndIf

	_aCaracteres := { { "·", "a" } , ;
		{ "‡", "a" } , ;
		{ "„", "a" } , ;
		{ "‰", "a" } , ;
		{ "‚", "a" } , ;
		{ "¡", "A" } , ;
		{ "¿", "A" } , ;
		{ "√", "A" } , ;
		{ "ƒ", "A" } , ;
		{ "¬", "A" } , ;
		{ "È", "e" } , ;
		{ "Ë", "e" } , ;
		{ "Î", "e" } , ;
		{ "Í", "e" } , ;
		{ "…", "E" } , ;
		{ "»", "E" } , ;
		{ "À", "E" } , ;
		{ " ", "E" } , ;
		{ "Ì", "i" } , ;
		{ "Ï", "i" } , ;
		{ "Ô", "i" } , ;
		{ "Ó", "i" } , ;
		{ "Õ", "I" } , ;
		{ "Ã", "I" } , ;
		{ "œ", "I" } , ;
		{ "Œ", "I" } , ;
		{ "Û", "o" } , ;
		{ "Ú", "o" } , ;
		{ "ı", "o" } , ;
		{ "ˆ", "o" } , ;
		{ "Ù", "o" } , ;
		{ "”", "O" } , ;
		{ "“", "O" } , ;
		{ "’", "O" } , ;
		{ "÷", "O" } , ;
		{ "‘", "O" } , ;
		{ "˙", "u" } , ;
		{ "˘", "u" } , ;
		{ "¸", "u" } , ;
		{ "˚", "u" } , ;
		{ "⁄", "U" } , ;
		{ "Ÿ", "U" } , ;
		{ "‹", "U" } , ;
		{ "€", "U" } , ;
		{ "¥", cCharEsp } , ;
		{ "`", cCharEsp } , ;
		{ "~", cCharEsp } , ;
		{ "^", cCharEsp } , ;
		{ "®", cCharEsp } , ;
		{ "&", cCharEsp } , ;
		{ "$", cCharEsp } , ;
		{ "%", cCharEsp } , ;
		{ "#", cCharEsp } , ;
		{ "@", cCharEsp } , ;
		{ "!", cCharEsp } , ;
		{ "?", cCharEsp } , ;
		{ "ø", cCharEsp } , ;
		{ "[", cCharEsp } , ;
		{ "]", cCharEsp } , ;
		{ "{", cCharEsp } , ;
		{ "}", cCharEsp } , ;
		{ "\", cCharEsp } , ;
		{ ">", " " } , ;
		{ "<", " " } , ;
		{ ":", cCharEsp } , ;
		{ ";", cCharEsp } , ;
		{ "ß", cCharEsp } , ;
		{ '"', " " } , ;
		{ "'", " " } , ;
		{ ",", " " } , ;
		{ "∫", cCharEsp } , ;
		{ "∞", cCharEsp } , ;
		{ "™", cCharEsp } , ;
		{ "+", cCharEsp } , ;
		{ "+", cCharEsp } , ;
		{ "=", cCharEsp } , ;
		{ "|", cCharEsp } , ;
		{ "-", cCharEsp } , ;
		{ "Á", "c" } , ;
		{ "«", "C" } , ;
		{ "Ä", "C" }   }

/*{ "\", cCharEsp } , ;
{ "/", cCharEsp } , ;
{ ")", cCharEsp } , ;
{ "(", cCharEsp } , ;*/

	For _nT := 01 To Len( _aCaracteres )
_cRet := Replace( _cRet, _aCaracteres[_nT][01], _aCaracteres[_nT][02] )
	Next _nT

Return _cRet

// ------------------------------------------------------------------
*----------------------------------------------------------*
User Function ORTDECOD( cParam )
*----------------------------------------------------------*

Local cBuffer	:= ""
Local cCurChar	:= ""
Local nX		:= 0

cBuffer	:= DecodeUTF8(cParam)

	If Empty(cBuffer)
	cBuffer	:= ""
		For nX := 1 To Len(cParam)
		cCurChar	:= DecodeUTF8(SubStr(cParam, nX, 1))
			If Empty(cCurChar)
			cCurChar	:= " "
			EndIf
		cBuffer	+= cCurChar
		Next nX
	EndIf

Return cBuffer


*----------------------------------------------------------*
User Function FVLDCONS(cCodLoja, cTpSegm)
*----------------------------------------------------------*

Local cQuery	:= ""
Local lRet		:= .T.

If !(cTpSegm $ "3|4|2|6|L") //Adicionados segmento 2-Comercial e 6-Caminh„o Volante, para permitir consignado. 25-05-2020. Novos modelos de consignaÁ„o

	cQuery	:= " SELECT RPAD(NVL(REGEXP_REPLACE(LISTAGG(TRIM(Z7_COD), ',') WITHIN "
	cQuery	+= "                                GROUP(ORDER BY TRIM(Z7_COD)), "
	cQuery	+= "                                '([^,]+)(,\1)+($|,)', "
	cQuery	+= "                                '\1\3'), "
	cQuery	+= "                 ' '), "
	cQuery	+= "             98) AS PRODUTOS "
	cQuery	+= "   FROM "+RetSqlName("SA1")+" SA1, "+RetSqlName("SZ7")+" SZ7 "
	cQuery	+= "  WHERE SA1.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SZ7.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND A1_FILIAL = '"+xFilial("SA1")+"' "
	cQuery	+= "    AND Z7_FILIAL = '"+xFilial("SZ7")+"' "
	cQuery	+= "    AND A1_COD = '"+cCodLoja+"' "
	cQuery	+= "    AND Z7_CLIENTE = A1_COD "
	cQuery	+= "    AND Z7_LOJA = A1_LOJA "
	cQuery	+= "    AND Z7_QTD > 0 "

	U_ORTQUERY(cQuery, "FVLDCONS")

	lRet := .T.

	If FVLDCONS->(!EOF()) .And. !Empty(FVLDCONS->PRODUTOS)
		lRet	:= .F.
		MsgStop("O cliente possui saldo consignado nos produtos '"+AllTrim(FVLDCONS->PRODUTOS)+"' mas n„o pertence ao segmento de lojas.")
	EndIf

	FVLDCONS->(dbCloseArea())

EndIf

Return(lRet)

*----------------------------------------------------------*
* Verificar se existe Carga em aberto para o Motorista e,  *
* caso exista, n„o permitir que o Motorista seja Bloqueado *
* ou que o cÛdigo do Propriet·rio seja alterado. SSI 14459 *
*----------------------------------------------------------*
User Function FVLDMOT(cMotorista,cPropri,_cBlq)
*----------------------------------------------------------*
Local _lOk := .T.

/*
_cQryMot := " SELECT A4_XCODPRP, A4_MSBLQL, COUNT(*) NUMREG "+ENTER
_cQryMot += " FROM SIGA."+RetSqlName("SZQ")+"  ZQ, SIGA."+RetSqlName("SA4")+" A4, SIGA."+RetSqlName("SC5")+" C5 "+ENTER
_cQryMot += " WHERE ZQ.D_E_L_E_T_ = ' ' "+ENTER
_cQryMot += " AND A4.D_E_L_E_T_ = ' ' "+ENTER
_cQryMot += " AND C5.D_E_L_E_T_ = ' ' "+ENTER
_cQryMot += " AND ZQ_FILIAL = '"+xFilial("SZQ")+"' "+ENTER
_cQryMot += " AND A4_FILIAL = '"+xFilial("SA4")+"' "+ENTER
_cQryMot += " AND C5_FILIAL = '"+xFilial("SC5")+"' "+ENTER
_cQryMot += " AND C5_XEMBARQ = ZQ_EMBARQ "+ENTER
_cQryMot += " AND A4_COD = ZQ_TRANSP "+ENTER
_cQryMot += " AND C5_XACERTO = '        ' "+ENTER
_cQryMot += " AND A4_COD = '"+cMotorista+"' "+ENTER
_cQryMot += " AND A4_MSBLQL = '2' "+ENTER
_cQryMot += " GROUP BY A4_XCODPRP, A4_MSBLQL "

MemoWrite('C:\MATA050_VLD.SQL', _cQryMot)
	If ( Select('VLDMOT') > 0 )
	VLDMOT->( dbCloseArea() )
	EndIf

TcQuery _cQryMot Alias 'VLDMOT' New
DbSelectArea('VLDMOT')
	If ALLTRIM(VLDMOT->A4_XCODPRP) <> aLLTRIM(cPropri)
		If VLDMOT->NUMREG > 0

		Alert("CÛdigo do Propriet·rio n„o pode ser alterado pois existem cargas em aberto para este motorista.")
		M->A4_XCODPRP := VLDMOT->A4_XCODPRP
		_lOk := .F.

			If ALLTRIM(VLDMOT->A4_MSBLQL) <> ALLTRIM(_cBlq)
		Alert("Motorista n„o pode ser bloqueado pois existem cargas em aberto para o mesmo.")
		M->A4_MSBLQL := VLDMOT->A4_MSBLQL
		_lOk := .F.
			EndIf
		Else

		_lOk := .T.

		EndIf
	EndIf
VLDMOT->( dbCloseArea() )
*/
Return _lOk
// ------------------------------------------------------------------
// [ Leitura da tabela PA7  - Chamada de orfr004.prw ]
// ------------------------------------------------------------------
User Function LePA7(cUni,cAdm,cAut,cCar)
	Local cQuery := ''
	Local aRet   := {}
	cQuery := " SELECT *                                         "
	cQuery += " FROM " + RetSQLName('PA7') + " PA7               "
	cQuery += " WHERE PA7.D_E_L_E_T_ <> '*'                      "
	cQuery += "   AND PA7_FILIAL      = '" + xFilial('PA7') + "' "
	cQuery += "   AND PA7_EMPRES      = '" + cUni           + "' "
	cQuery += "   AND PA7_ADM         = '" + cAdm           + "' "
	cQuery += "   AND PA7_AUTORI      = '" + cAut           + "' "
	cQuery += "   AND PA7_CARTAO      = '" + cCar           + "' "
	MemoWrite('C:\LEPA7.SQL', cQuery)
	If ( Select('TMP') > 0 )
		TMP->( dbCloseArea() )
	EndIf
	TcQuery cQuery Alias 'TMP' New
	dbselectarea('TMP')
	TMP->(dbGoTop())
	do while !eof()
		Aadd(aRet,{ TMP->PA7_FILIAL,;
			TMP->PA7_EMPRES,;
			TMP->PA7_ADM   ,;
			TMP->PA7_ADMORI,;
			TMP->PA7_AUTORI,;
			TMP->PA7_CARTAO,;
			TMP->PA7_POS   ,;
			TMP->PA7_PV    ,;
			TMP->PA7_VALOR ,;
			TMP->PA7_TOTPAR})
		TMP->(DbSkip())
	enddo
	dbclosearea()
Return(aRet)
// ------------------------------------------------------------------

	*--------------------------------------------------------------------------------*
User Function fMultSelect(_aOpcao,_cTitulo,_aCampo)  // FunÁ„o de multipla seleÁ„o
	*--------------------------------------------------------------------------------*
// Onde:
// _aOpcao  = Array com opÁıes da seleÁ„o
// _cTitulo = TÌtulo da janela de seleÁ„o
// _cCampo  = TÌtulo do campo a ser exibido
// _aCols   => Esta variavelk tem de ser definida como private na rotina que faz a chamada da funÁ„o de multipla seleÁ„o

	Local aSaveArea	:= GetArea()
	Local _cSelec	:= Nil
	Local oOk       := LoadBitmap( GetResources(), "LBTIK" )  //"LBTIK" OU "LBOK"
	Local oNo       := LoadBitmap( GetResources(), "LBNO" )
	Local oChk      := Nil
	Local Ln        := 0

	Private oList

	For Ln := 1 To Len(_aOpcao)
		Do Case
		Case Len(_aCampo) == 1
			AaDd(_aCols, {	_lMark, _aOpcao[Ln,1] })
		Case Len(_aCampo) == 2
			AaDd(_aCols, {	_lMark, _aOpcao[Ln,1], _aOpcao[Ln,2] })
		Case Len(_aCampo) >= 3
			AaDd(_aCols, {	_lMark, _aOpcao[Ln,1], _aOpcao[Ln,2], _aOpcao[Ln,3] })
		EndCase
	Next

// DefiniÁ„o da Tela
	oTela			:= MsDialog():New(091,232,330,607,_cTitulo,,,.F.,,,,,,.T.,,,.T.)
	oTela:bInit		:= {||EnchoiceBar(oTela,{||oTela:End()},{||oTela:End()},.F.,{})}

	oGrpR			:= TGroup():New(002,002,105,189,"",oTela,CLR_BLACK,CLR_WHITE,.T.,.F.)

	Do Case
	Case Len(_aCampo) == 1
		@ 004,004 ListBox oList Var _cSelec Fields Header "",;
			_aCampo[1] Size 183,099 Of oTela Pixel;
			On DblClick(_aCols[oList:nAt,1] := !_aCols[oList:nAt,1],oList:Refresh())

		oList:SetArray(_aCols)
		oList:bLine := {|| {Iif(_aCols[oList:nAt,1],oOk,oNo),;
			_aCols[oList:nAt,2]}}

	Case Len(_aCampo) == 2
		@ 004,004 ListBox oList Var _cSelec Fields Header "",;
			_aCampo[1],;
			_aCampo[2] Size 183,099 Of oTela Pixel;
			On DblClick(_aCols[oList:nAt,1] := !_aCols[oList:nAt,1],oList:Refresh())

		oList:SetArray(_aCols)
		oList:bLine := {|| {Iif(_aCols[oList:nAt,1],oOk,oNo),;
			_aCols[oList:nAt,2],;
			_aCols[oList:nAt,3]}}

	Case Len(_aCampo) >= 3
		@ 004,004 ListBox oList Var _cSelec Fields Header "",;
			_aCampo[1],;
			_aCampo[2],;
			_aCampo[3] Size 183,099 Of oTela Pixel;
			On DblClick(_aCols[oList:nAt,1] := !_aCols[oList:nAt,1],oList:Refresh())

		oList:SetArray(_aCols)
		oList:bLine := {|| {Iif(_aCols[oList:nAt,1],oOk,oNo),;
			_aCols[oList:nAt,2],;
			_aCols[oList:nAt,3],;
			_aCols[oList:nAt,4]}}

	EndCase

	@ 007,006 CheckBox oChk Var _lMark Prompt "" Size 030,005 Pixel Of oTela On Click(iIf(_lMark,fMarcaTodos(_lMark),fMarcaTodos(_lMark)))

///oBtnOkL			:= SButton():New(107,162,1,,oTela,,"",)
///oBtnOkL:bAction	:= {||oTela:End()}

// Ativa Objeto Tela
	oTela:Activate(,,,.T.)

	RestArea(aSaveArea)

Return()  // Retorno da funÁ„o

	*----------------------------------------------------------------*
Static Function fMarcaTodos(lMarca)  // FunÁ„o de marcar/desmarcar
	*----------------------------------------------------------------*
	Local _Ln := 0
	For _Ln := 1 To Len(_aCols)
		_aCols[_Ln,1] := lMarca
	Next

	oList:AARRAY:=_aCols
	oList:Refresh()

Return .T.  // Retorno da funÁ„o


	*----------------------------------------------------------*
User Function ORTMIX(cPedMix)
	*----------------------------------------------------------*

	Local nRet		:= 0
	Local cQuery	:= ""

	cQuery	:= " SELECT NVL(ROUND(100 * SUM(DECODE(C5_XOPER, '05', -1, 1) * C6_QTDVEN * "
	cQuery	+= "                        (C6_XPRUNIT - C6_XCUSTO)) / SUM(C6_QTDVEN*C6_XPRUNIT), "
	cQuery	+= "              2), 0) AS MIX "
	cQuery	+= "   FROM SIGA."+RetSqlName("SC5")+" SC5, SIGA."+RetSqlName("SC6")+" SC6 "
	cQuery	+= "  WHERE SC5.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SC6.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND C5_FILIAL = '"+xFilial("SC6")+"' "
	cQuery	+= "    AND C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery	+= "    AND C6_NUM = C5_NUM "
	cQuery	+= "    AND C5_NUM = '"+PADR(cPedMix, GetSX3Cache("C5_NUM","X3_TAMANHO"))+"' "
	U_ORTQUERY(cQuery, "ORTMIX")
	nRet	:= ORTMIX->MIX
	ORTMIX->(dbCloseArea())

Return nRet

	**********************************************************************************
User Function ORTLNOVA(cDtIni, cDtFim)
	**********************************************************************************
	Local cQuery	:= ""
	Local aRet		:= {}

	cQuery	:= " SELECT CASE "
	cQuery	+= "          WHEN EXISTS (SELECT 1 "
	cQuery	+= "                  FROM "+RetSqlName("SC5")+" SC5A "
	cQuery	+= "                 WHERE SC5A.D_E_L_E_T_ = ' ' "
	cQuery	+= "                   AND SC5A.C5_FILIAL = '"+IIf(cEmpAnt=="26","  ","02")+"' "
	cQuery	+= "                   AND SC5A.C5_CLIENTE = A1_COD "
	cQuery	+= "                   AND SC5A.C5_XPEDMAE = 'T' "
	cQuery	+= "                   AND SC5A.C5_EMISSAO < '"+cDtIni+"') THEN "
	cQuery	+= "           1 "
	cQuery	+= "          ELSE "
	cQuery	+= "           0 "
	cQuery	+= "        END AS EMISANT, "
	cQuery	+= "        A1_COD, "
	cQuery	+= "        A1_CGC, "
	cQuery	+= "        A1_NOME, "
	cQuery	+= "        A1_XTIPO, "
	cQuery	+= "        A1_XDTCRIA, "
	cQuery	+= "        A3_COD, "
	cQuery	+= "        A3_NOME "
	cQuery	+= "   FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1, "+RetSqlName("SA3")+" SA3 "
	cQuery	+= "  WHERE SC5.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SA1.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SA3.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SC5.C5_FILIAL = '"+IIf(cEmpAnt=="26","  ","02")+"' "
	cQuery	+= "    AND A1_FILIAL = '  ' "
	cQuery	+= "    AND A3_FILIAL = '  ' "
	cQuery	+= "    AND SC5.C5_XPEDMAE = 'T' "
	cQuery	+= "    AND SC5.C5_EMISSAO BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
	cQuery	+= "    AND SC5.C5_XOPER IN ('01','04') "
	cQuery	+= "    AND A1_COD = SC5.C5_CLIENTE "
	cQuery	+= "    AND A1_XTIPO IN ('3','4','L') "
	cQuery	+= "    AND A3_COD = A1_VEND "
	cQuery	+= "    AND A1_XCGC <> 'IMPORTACAO07  ' "
	If cEmpAnt == "11"
		cQuery	+= " AND A1_CGC NOT IN ( "
		cQuery	+= " '07961034000191', "
		cQuery	+= " '08602840000136', "
		cQuery	+= " '11573273000141', "
		cQuery	+= " '10800643000173', "
		cQuery	+= " '14634399000177', "
		cQuery	+= " '21793693000197' "
		cQuery	+= " ) "
	EndIf

	cQuery	+= " AND A1_CGC NOT IN ( "
	cQuery	+= " '05935522000107', "
	cQuery	+= " '22770377000162', "
	cQuery	+= " '22911431000142', "
	cQuery	+= " '23340542000109', "
	cQuery	+= " '23150906000198', "
	cQuery	+= " '23495582000120', "
	cQuery	+= " '23520774000149', "
	cQuery	+= " '23593521000103', "
	cQuery	+= " '23621111000110', "
	cQuery	+= " '23532299000120', "
	cQuery	+= " '23560236000188', "
	cQuery	+= " '23689024000103' "
	cQuery	+= " ) "

	cQuery	+= "  GROUP BY A1_COD, A1_CGC, A1_NOME, A1_XTIPO, A1_XDTCRIA, A3_COD, A3_NOME "
	cQuery	+= "  ORDER BY 1, 2 "
	U_ORTQUERY(cQuery, "ORTLNOVA_1")
	While ORTLNOVA_1->(!EOF())
		aAdd(aRet, { ;
			PADR(ORTLNOVA_1->A1_COD, 06), ;
			PADR(ORTLNOVA_1->A1_CGC, 14), ;
			PADR(ORTLNOVA_1->A1_NOME, 40), ;
			PADR(ORTLNOVA_1->A1_XTIPO, 01), ;
			PADR(ORTLNOVA_1->A1_XDTCRIA, 08), ;
			PADR(ORTLNOVA_1->A3_COD, 06), ;
			PADR(ORTLNOVA_1->A3_NOME, 40), ;
			(ORTLNOVA_1->EMISANT == 0) ;
			})
		ORTLNOVA_1->(dbSkip())
	EndDo
	ORTLNOVA_1->(dbCloseArea())

Return aRet

	**********************************************************************************
User Function ORTXRPC(cUnidade, cFuncao, aParams, lHomolog, cNomEnv)
	**********************************************************************************
	Local nX		:= 0
	Local nY		:= 0
	Local cParams	:= ""
	Local xRet		:= Nil
	Local aEnvProd	:= {}
	Local aEnvHomo	:= {}
	Local aConexao	:= {}

	Private oObjRpc	:= Nil

	If ValType(lHomolog) <> "L" ; lHomolog := .F. ; EndIf

		If FunName() $ 'ORTA601||ORTE046||ORTE040||ORTA635||ORTR631||ORTP062'

			aAdd(aEnvProd, {"10.0.200.62", 1235, IIf(Empty(cNomEnv), "ORTOSP", cNomEnv), "02", "01"})// marcela coimbra
		
		EndIf

		aAdd(aEnvProd, {"10.0.200.62", 1235, IIf(Empty(cNomEnv), "ORTOSP", cNomEnv), "02", "02"})

		aAdd(aEnvProd, {"10.0.200.63" , 1235, IIf(Empty(cNomEnv), "ORTORJ", cNomEnv), "03", "02"})
		aAdd(aEnvProd, {"10.0.200.63" , 1235, IIf(Empty(cNomEnv), "ORTORJ", cNomEnv), "18", "02"})
		aAdd(aEnvProd, {"10.0.200.63" , 1235, IIf(Empty(cNomEnv), "ORTORJ", cNomEnv), "27", "03"})
		aAdd(aEnvProd, {"10.0.200.63" , 1235, IIf(Empty(cNomEnv), "ORTORJ", cNomEnv), "28", "04"})

		aAdd(aEnvProd, {"10.0.200.63" , 1235, IIf(Empty(cNomEnv), "ORTORJ", cNomEnv), "58", "01"})
		aAdd(aEnvProd, {"10.0.200.64" , 1235, IIf(Empty(cNomEnv), "ORTOMG", cNomEnv), "04", "02"})
		aAdd(aEnvProd, {"10.0.200.65" , 1235, IIf(Empty(cNomEnv), "ORTOGO", cNomEnv), "05", "02"})
//aAdd(aEnvProd, {"10.0.100.203", 1235, IIf(Empty(cNomEnv), "ORTOGO", cNomEnv), "25", "02"})
		aAdd(aEnvProd, {"10.0.200.66" , 1235, IIf(Empty(cNomEnv), "ORTOMT", cNomEnv), "06", "02"})
		aAdd(aEnvProd, {"10.0.200.67" , 1235, IIf(Empty(cNomEnv), "ORTOBA", cNomEnv), "07", "02"})
		aAdd(aEnvProd, {"10.0.200.67" , 1235, IIf(Empty(cNomEnv), "ORTOBA", cNomEnv), "23", "02"})
		aAdd(aEnvProd, {"10.0.200.67" , 1235, IIf(Empty(cNomEnv), "ORTOBA", cNomEnv), "24", "02"})
		aAdd(aEnvProd, {"10.0.200.68" , 1235, IIf(Empty(cNomEnv), "ORTOPE", cNomEnv), "08", "02"})
		aAdd(aEnvProd, {"10.0.200.69" , 1235, IIf(Empty(cNomEnv), "ORTOCE", cNomEnv), "09", "02"})
		aAdd(aEnvProd, {"10.0.200.70" , 1235, IIf(Empty(cNomEnv), "ORTOPR", cNomEnv), "10", "02"})
		aAdd(aEnvProd, {"10.0.200.71" , 1235, IIf(Empty(cNomEnv), "ORTOPA", cNomEnv), "11", "02"})
		aAdd(aEnvProd, {"10.0.200.71" , 1235, IIf(Empty(cNomEnv), "ORTOPA", cNomEnv), "26", "02"})
		aAdd(aEnvProd, {"10.0.200.75" , 1235, IIf(Empty(cNomEnv), "ORTORS", cNomEnv), "15", "02"})
		aAdd(aEnvProd, {"10.0.100.213", 1235, IIf(Empty(cNomEnv), "ORTOOF", cNomEnv), "21", "02"})
		aAdd(aEnvProd, {"10.0.100.213", 1235, IIf(Empty(cNomEnv), "ORTOAF", cNomEnv), "22", "02"})
		aAdd(aEnvProd, {"10.0.100.6"  , 1235, IIf(Empty(cNomEnv), "ORTOBOM", cNomEnv), "51", "01"})
		aAdd(aEnvProd, {"10.0.100.6"  , 1235, IIf(Empty(cNomEnv), "ORTOBOM", cNomEnv), "30", "01"})     // Marcela Coimbra
		aAdd(aEnvProd, {"10.0.100.6"  , 1235, IIf(Empty(cNomEnv), "ORTOBOM", cNomEnv), "31", "01"})     // Marcela Coimbra
		aAdd(aEnvProd, {"10.0.100.6"  , 1235, IIf(Empty(cNomEnv), "ORTOBOM", cNomEnv), "32", "01"})     // Marcela Coimbra
        aAdd(aEnvProd, {"10.0.100.6"  , 1235, IIf(Empty(cNomEnv), "ORTOBOM", cNomEnv), "33", "01"})     // Marcela Coimbra
        aAdd(aEnvProd, {"10.0.100.6"  , 1235, IIf(Empty(cNomEnv), "ORTOBOM", cNomEnv), "34", "01"})     // Marcela Coimbra
        
		aAdd(aEnvHomo, {"10.0.200.62" , 1250, IIf(Empty(cNomEnv), "COMPSP", cNomEnv), "02", "02"})
		aAdd(aEnvHomo, {"10.0.200.63" , 1250, IIf(Empty(cNomEnv), "COMPRJ", cNomEnv), "03", "02"})
		aAdd(aEnvHomo, {"10.0.200.63" , 1250, IIf(Empty(cNomEnv), "COMPRJ", cNomEnv), "18", "02"})
		aAdd(aEnvHomo, {"10.0.200.63" , 1250, IIf(Empty(cNomEnv), "COMPRJ", cNomEnv), "27", "03"})
		aAdd(aEnvHomo, {"10.0.200.63" , 1250, IIf(Empty(cNomEnv), "COMPRJ", cNomEnv), "28", "04"})
		aAdd(aEnvHomo, {"10.0.200.63" , 1250, IIf(Empty(cNomEnv), "COMPRJ", cNomEnv), "58", "01"})
		aAdd(aEnvHomo, {"10.0.200.64" , 1250, IIf(Empty(cNomEnv), "COMPMG", cNomEnv), "04", "02"})
		aAdd(aEnvHomo, {"10.0.200.65" , 1250, IIf(Empty(cNomEnv), "COMPGO", cNomEnv), "05", "02"})
//aAdd(aEnvHomo, {"10.0.100.203", 1250, IIf(Empty(cNomEnv), "COMPGO", cNomEnv), "25", "02"})
		aAdd(aEnvHomo, {"10.0.200.66" , 1250, IIf(Empty(cNomEnv), "COMPMT", cNomEnv), "06", "02"})
		aAdd(aEnvHomo, {"10.0.200.67" , 1250, IIf(Empty(cNomEnv), "COMPBA", cNomEnv), "07", "02"})
		aAdd(aEnvHomo, {"10.0.200.67" , 1250, IIf(Empty(cNomEnv), "COMPBA", cNomEnv), "23", "02"})
		aAdd(aEnvHomo, {"10.0.200.67" , 1250, IIf(Empty(cNomEnv), "COMPBA", cNomEnv), "24", "02"})
		aAdd(aEnvHomo, {"10.0.200.68" , 1250, IIf(Empty(cNomEnv), "COMPPE", cNomEnv), "08", "02"})
		aAdd(aEnvHomo, {"10.0.200.69" , 1250, IIf(Empty(cNomEnv), "COMPCE", cNomEnv), "09", "02"})
		aAdd(aEnvHomo, {"10.0.200.70" , 1250, IIf(Empty(cNomEnv), "COMPPR", cNomEnv), "10", "02"})
		aAdd(aEnvHomo, {"10.0.200.71" , 1250, IIf(Empty(cNomEnv), "COMPPA", cNomEnv), "11", "02"})
		aAdd(aEnvHomo, {"10.0.200.71" , 1250, IIf(Empty(cNomEnv), "COMPPA", cNomEnv), "26", "02"})
		aAdd(aEnvHomo, {"10.0.200.75" , 1250, IIf(Empty(cNomEnv), "COMPRS", cNomEnv), "15", "02"})
		aAdd(aEnvHomo, {"10.0.100.213", 1250, IIf(Empty(cNomEnv), "COMPOF", cNomEnv), "21", "02"})
		aAdd(aEnvHomo, {"10.0.100.213", 1250, IIf(Empty(cNomEnv), "COMPAF", cNomEnv), "22", "02"})


		If lHomolog
			nX	:= AScan(aEnvHomo, {|x| x[4] == cUnidade})
			If nX == 0 
				Return Nil
			EndIf
			aConexao	:= aEnvHomo[nX]
			If cUnidade == "27" .OR. cUnidade == "28"
				aConexao[4] := "18"
			Endif
		Else
			nX	:= AScan(aEnvProd, {|x| x[4] == cUnidade})
			If nX == 0 
				Return Nil
			EndIf
			aConexao	:= aEnvProd[nX]
			If cUnidade == "27" .OR. cUnidade == "28"
				aConexao[4] := "18"
			Endif
		EndIf

				For nX := 1 To Len(aParams)
					If ValType(aParams[nX]) <> "C" ; Return Nil ; EndIf
						For nY := 1 To Len(aParams[nX])
							If SubStr(aParams[nX], nY, 1) == "'" ; Return Nil ; EndIf
							Next nY
							cParams	+= ",'"+aParams[nX]+"'"
						Next nX

						oObjRpc	:= RPCConnect(aConexao[01], aConexao[02], aConexao[03], aConexao[04], aConexao[05])
						If ValType(oObjRpc) <> "O" ; Return Nil ; EndIf

							xRet	:= &("oObjRpc:CallProc('"+cFuncao+"'"+cParams+")")

	RPCDisconnect(oObjRpc)

Return xRet

							**********************************************************************************
User Function ORTBLPRC(cCodBloco, cModCorte, cTabela, cRef, nAlt, nLarg, nComp)
	**********************************************************************************
	Local nCustoB	:= 0
	Local nMarfB	:= 0
	Local nPesoB	:= 0
	Local nDescon	:= 0
	Local nPrcCorte	:= 0
	Local cQuery	:= ""

	If !(cModCorte $ "000008|000018|000009|000010|000012")
		Return Nil
	EndIf
	cQuery	:= " SELECT B1_XQTDEMB, "
	cQuery	+= "        B5_DENSID, "
	cQuery	+= "        DA1_PRCVEN, "
	cQuery	+= "        DA1_XCUSTO, "
	cQuery	+= "        NVL(ACP_PERDES, 0) AS ACP_PERDES "
	cQuery	+= "   FROM "+RetSqlName("SB1")+" SB1, "+RetSqlName("SB5")+" SB5, "+RetSqlName("DA1")+" DA1, "+RetSqlName("ACP")+" ACP "
	cQuery	+= "  WHERE SB1.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND ACP.D_E_L_E_T_(+) = ' ' "
	cQuery	+= "    AND DA1.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND SB5.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery	+= "    AND ACP_FILIAL(+) = '"+xFilial("ACP")+"' "
	cQuery	+= "    AND DA1_FILIAL = '"+xFilial("DA1")+"' "
	cQuery	+= "    AND B5_FILIAL = '"+xFilial("SB5")+"' "
	cQuery	+= "    AND B1_COD = '"+cCodBloco+"' "
	cQuery	+= "    AND B5_COD = B1_COD "
	cQuery	+= "    AND B1_XMODELO = '000011' "
	cQuery	+= "    AND DA1_CODTAB = '"+cTabela+"' "
	cQuery	+= "    AND DA1_CODPRO = B1_COD "
	cQuery	+= "    AND ACP_CODREG(+) = '00"+cTabela+cRef+"' "
	cQuery	+= "    AND ACP_CODPRO(+) = B1_COD "
	U_ORTQUERY(cQuery, "ORTBLPRC")

	If ORTBLPRC->(EOF())
		ORTBLPRC->(dbCloseArea())
		Return Nil
	EndIf

	nPesoB		:= Round(ORTBLPRC->B1_XQTDEMB / ORTBLPRC->B5_DENSID, 4)
	nMarfB		:= Round(ORTBLPRC->DA1_PRCVEN, 2)
	nCustoB		:= Round(ORTBLPRC->DA1_XCUSTO, 2)
	nDescon		:= Round(ORTBLPRC->ACP_PERDES, 4)

	ORTBLPRC->(dbCloseArea())

	If cModCorte $ "000008|000018"	//Laminado
		nPrcCorte	:= U_RoundUp(U_RoundUp(U_RoundUp(nCustoB * nPesoB, 2) * 1.08, 2) * nAlt * nLarg * nComp, 2)	//Custo
		nPrcCorte	:= Round(nPrcCorte * Round(nMarfB / nCustoB, 2), 2)
		nPrcCorte	:= Round(nPrcCorte * (100 - nDescon) / 100, 2)
	ElseIf cModCorte $ "000009"	//Perfilado
		nPrcCorte	:= U_RoundUp(U_RoundUp(U_RoundUp(nCustoB * nPesoB, 2) * 1.10, 2) * nAlt * nLarg * nComp, 2)	//Custo
		nPrcCorte	:= Round(nPrcCorte * Round(nMarfB / nCustoB, 2), 2)
		nPrcCorte	:= Round(nPrcCorte * (100 - nDescon) / 100, 2)
	ElseIf cModCorte $ "000010|000012"	//PeÁa
		nPrcCorte	:= U_RoundUp(U_RoundUp(U_RoundUp(nCustoB * nPesoB, 2) * 1.17, 2) * nAlt * nLarg * nComp, 2) //Custo
		nPrcCorte	:= Round(nPrcCorte * Round(nMarfB / nCustoB, 2), 2)
		nPrcCorte	:= Round(nPrcCorte * (100 - nDescon) / 100, 2)
	Else
		Return Nil
	Endif

Return nPrcCorte

	**********************************************************************************
User Function ORTESTRU(cProd_, nQuant_)
	**********************************************************************************
	Local nX		:= 0
	Local nY		:= 0
	Local nZ		:= 0
	Local cQuery	:= ""
	Local aTmp		:= {}
	Local aTmpSub	:= {}
	Local aRet		:= {}

	If Empty(nQuant_) ; nQuant_ := 1 ; EndIf

		cQuery	:= " SELECT G1_COMP, G1_QUANT * (100 + G1_PERDA) / 100 AS G1_QUANT "
		cQuery	+= "   FROM "+RetSqlName("SG1")+" SG1 "
		cQuery	+= "  WHERE SG1.D_E_L_E_T_ = ' ' "
		cQuery	+= "    AND G1_FILIAL = '"+xFilial("SG1")+"' "
		cQuery	+= "    AND G1_COD = '"+PADR(cProd_, GetSX3Cache("G1_COD","X3_TAMANHO"))+"' "
		U_ORTQUERY(cQuery, "ORTESTRU")
		While ORTESTRU->(!EOF())
			aAdd(aTmp, {PADR(ORTESTRU->G1_COMP, GetSX3Cache("G1_COD","X3_TAMANHO")), ORTESTRU->G1_QUANT})
			ORTESTRU->(dbSkip())
		EndDo
		ORTESTRU->(dbCloseArea())

		For nX := 1 To Len(aTmp)
			aTmpSub	:= U_ORTESTRU(aTmp[nX,01], aTmp[nX,02])
			If Empty(aTmpSub)
				nZ	:= AScan(aRet, {|x| x[1] == aTmp[nX,01]})
				If nZ == 0
					aAdd(aRet, {aTmp[nX,01], aTmp[nX,02] * nQuant_})
				Else
					aRet[nZ,02]	+= aTmp[nX,02] * nQuant_
				EndIf
			Else
				For nY := 1 To Len(aTmpSub)
					nZ	:= AScan(aRet, {|x| x[1] == aTmpSub[nY,01]})
					If nZ == 0
						aAdd(aRet, {aTmpSub[nY,01], aTmpSub[nY,02] * nQuant_})
					Else
						aRet[nZ,02]	+= aTmpSub[nY,02] * nQuant_
					EndIf
				Next nY
			EndIf
		Next nX

		Return aRet

		**********************************************************************************
/*
Retorna numÈrico contendo a capacidade de produÁ„o de um produto com o estoque
atual de insumos
*/
User Function ORTVPROD(cProd_, cLocal_)
	**********************************************************************************
	Local nX		:= 0
	Local nY		:= 0
	Local nQuant_	:= 0
	Local nQtdTmp	:= 0
	Local cQuery	:= ""
	Local aEstru_	:= {}
	Local aProds_	:= {}

	aEstru_	:= U_ORTESTRU(cProd_, 1)

	If Empty(aEstru_)
		Return 0
	EndIf

	cQuery	:= " SELECT B2_COD, SUM(B2_QATU) AS B2_QATU "
	cQuery	+= "   FROM "+RetSqlName("SB2")+" SB2 "
	cQuery	+= "  WHERE SB2.D_E_L_E_T_ = ' ' "
	cQuery	+= "    AND B2_FILIAL = '"+xFilial("SB2")+"' "
	If !Empty(cLocal_)
		cQuery	+= "    AND B2_LOCAL = '"+cLocal_+"' "
	EndIf
	cQuery	+= "    AND B2_COD IN ( "
	For nX := 1 To Len(aEstru_)
		If nX > 1 ; cQuery += "," ; EndIf
			cQuery	+= "'"+PADR(aEstru_[nX,01], GetSX3Cache("B2_COD","X3_TAMANHO"))+"'"
		Next nX
		cQuery	+= "    ) "
		cQuery	+= " GROUP BY B2_COD "
		U_ORTQUERY(cQuery, "ORTVPROD")
		While ORTVPROD->(!EOF())
			aAdd(aProds_, {PADR(ORTVPROD->B2_COD, GetSX3Cache("B2_COD","X3_TAMANHO")), ORTVPROD->B2_QATU})
			ORTVPROD->(dbSkip())
		EndDo
		ORTVPROD->(dbCloseArea())

		For nX := 1 To Len(aEstru_)
			nY	:= AScan(aProds_, {|x| AllTrim(x[01]) == AllTrim(aEstru_[nX,01])})
			If nY == 0
				nQuant_	:= 0
				Exit
			EndIf
			nQtdTmp	:= aProds_[nY,02] / aEstru_[nX,02]
			If nQtdTmp < nQuant_
				nQuant_	:= nQtdTmp
			EndIf
		Next nX

		nQuant_	:= NoRound(nQuant_, 0)

		Return nQuant_


		*********************************
User Function fRetClFr(cTab,cCod)
	*********************************

	Local cTabela:=cTab
	Local cCpo   :=Right(cTab,2) + "_NOME"

	cRetorno:=Posicione(cTabela,1,XFILIAL(cTabela)+cCod,cCpo)

Return(cRetorno)


	*-------------------------------------------------------------------------------*
/*/{Protheus.doc} FTimerMsg

Rotina para apresentaÁ„o de mensagem com Timer

@params
	FTimerMsg( 	cPTitulo	--> TÌtulo a ser apresentado na Janela da Mensagem
				cPMensagem	--> Mensagem a ser apresentada ( poodendo utilizar formataÁ„o HTML/CSS )
				nTimer		--> Tempo em Milisegundos para ExecuÁ„o da AÁ„o do Timer --> Ex.: 2000 --> 2 segundos
				cRotina		--> Nome do Fonte que contÈm a Static Function
				cStatic 	--> Nome da StaticFuncton a ser executada no Timer.
							    A mesma precisar· retornar .T. --> Sucesso e .F. --> Tenta Novamente

@Exemplo

User Function TSTRGR001()
	If U_FTimerMsg( "Registro Bloqueado", "Aguarde alguns instantes, pois o fornecedor est· com o registro bloqueado. <br>Em 05 segundos sua tela ser· <h3>reiniciada</h3>, ou clique em continuar", NIL, "FUNCOES", "FMeuTimer" )
			Alert( "A rotina executou a tarefa perfeitamente" )
	Else
			Alert( "A rotina foi abortada" )
	EndIf
	Return

Static Function FMeuTimer()
	Return MsgYesNo( "Deseja encerrar o Timer?" )

@author Rafael Rezende
@email rafael.rezende@rgrsolucoes.com
@since 19/05/2016
@version 1.0

@return

@see www.rgrsolucoes.com
/*/
	*--------------------------------------------------------------------------------*

	*-----------------------------------------------------------------------*
User Function FTimerMsg( cPTitulo, cPMensagem, nTimer, cRotina, cStatic )
	*-----------------------------------------------------------------------*
	Local lRet	:= .T.
	Private nContinuar 		:= 02
	Private cSayMensag 		:= ""
	Private bFTimer	   		:= { || FTimer( @nContinuar, cRotina, cStatic ) }

	Default cPTitulo   		:= "Aguarde..."
	Default cPMensagem 		:= "Aguarde..."
	Default nTimer	   		:= 10000 // 10 Segundos ou 10000 milisegundos
	Default cRotina		    := "RGRTimerMsg"
	Default cStatic			:= "FTimerSub"

	Do While .T.

		// Mostra tela e ativa o Timer
		nContinuar := FTelaTimerMsg( cPTitulo, cPMensagem, nTimer, bFTimer )

		If nContinuar == 00 // Deu tudo certo

			lRet := .T.
			Exit

		Else

			lRet := .F.
			If nContinuar == 01 // Tentar Novamente
				Loop
			Else // Cancelar
				Exit
			EndIf

		EndIf

	EndDo

Return lRet



	*--------------------------------------------------------------------*
Static Function FTelaTimerMsg( cPTitulo, cPMensagem, nTimer, bFTimer )
	*--------------------------------------------------------------------*
	Private cSayMensag 	:= ""
	SetPrvt("oFontTimer","oDlgTimer","oGrpMensagem","oSayMensagem","oBtnOk","oBtnCancelar","oTimer" )

	oFontTimer := TFont():New( "Arial Narrow",0,-13,,.F.,0,,400,.F.,.F.,,,,,, )
	oDlgTimer  := MSDialog():New( 092,232,245,953, cPTitulo ,,,.F.,,,,,,.T.,,,.T. )
	oGrpMensag := TGroup():New( 004,008,060,284,"",oDlgTimer,CLR_BLACK,CLR_WHITE,.T.,.F. )

	oSayMensag := TSay():New( 011,013,{|| cPMensagem }, oGrpMensagem,,oFontTimer,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,266,043,,,,,, .T. )
	oBtnOk     := TButton():New( 006,290,"Continuar",oDlgTimer,{ || FContinuar() },054,012,,,,.T.,,"",,,,.F. )
	oBtnCancel := TButton():New( 021,290,"Cancelar",oDlgTimer,{ || FCancelar( 02 ) },054,012,,,,.T.,,"",,,,.F. )
	oTimer 	   := TTimer():New( nTimer, bFTimer, oDlgTimer )
	oTimer:Activate()
	oDlgTimer:Activate(,,,.T.)

Return nContinuar


	*---------------------------------*
Static Function FContinuar( nAcao )
	*---------------------------------*
	Default nAcao := 01

	nContinuar := nAcao
	oDlgTimer:End()

Return

	*--------------------------------*
Static Function FCancelar( nAcao )
	*--------------------------------*

	nContinuar := nAcao
	oDlgTimer:End()

Return


	*----------------------------------------------------*
Static Function FTimer( nContinuar, cRotina, cStatic )
	*----------------------------------------------------*

	If &cStaticFunction
		nContinuar := 00 // Tudo Certo
	Else
		nContinuar := 01 // Tentar Novamente
	EndIf
	FContinuar( nContinuar )

Return

	*-------------------------*
Static Function FTimerSub()
	*-------------------------*

Return .F.

	*-------------------------------------------------------------------------------*
/*/{Protheus.doc} FChkRecBxTit

Rotina para verificar se o registro corrente para procedimento de Baixa(s) de TÌtulo(s))
se encontra em uso por outro usu·rio, caso esteja em uso apresenta uma mensagem com Timer,
informando do Bloqueio do registro, verificando atÈ a LiberaÁ„o do mesmo para processamento
e imediantamento passando para o registro seguinte.

@params
	FChkRecBxTit(
				cPUnidade	--> Unidade (Estado da FedereÁ„o) a que pertence o registro
				cTabela		--> Nome da tabela a que pertence o registro
				nRecNo		--> ID de identificaÁ„o do registro (Recno) )

@Exemplo

@author Ricardo da Silva
@email ricardo.silva@rgrsolucoes.com
@since 23/05/2016
@version 1.0

@return

@see www.rgrsolucoes.com
/*/
	*--------------------------------------------------------------------------------*
	*----------------------------------------------------*
User Function FChkRecBxTit(cPUnidade, cTabela, nRecNo)
	*----------------------------------------------------*

	Local aAreaAnt := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cSQL   	:= ""
	Local lRet     	:= .T.
	Local cUns      :="<> '" +cEmpAnt+ "'"
	If cEmpAnt=="02"
		cUns:="<> '02' "
	Else
		If cEmpAnt$"03|18|58"
			cUns:="NOT IN ('03','18','58') "
		Else
			If cEmpAnt=="04"
				cUns:="<> '04' "
			Else
				If cEmpAnt$"05|25"
					cUns:="NOT IN ('05','25') "
				Else
					If cEmpAnt=="06"
						cUns:="<> '06' "
					Else
						If cEmpAnt$"07|23|24"
							cUns:="NOT IN ('07','23','24') "
						Else
							If cEmpAnt=="08"
								cUns:="<> '08' "
							Else
								If cEmpAnt=="09"
									cUns:="<> '09' "
								Else
									If cEmpAnt=="10"
										cUns:="<> '10' "
									Else
										If cEmpAnt$"11|26"
											cUns:="NOT IN ('05','25') "
										Else
											If cEmpAnt=="15"
												cUns:="<> '15' "
											Endif
										Endif
									Endif
								Endif
							Endif
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
//If ( AllTrim(cEmpAnt) $ ('21') )
//	cSQL  := "SELECT COUNT(*) AS ACHOU  FROM UPDREG WHERE UN  <> 'RJ'  AND  TAB = '" + cTabela + "' AND REC = " + AllTrim( Str( nRecNo ) )
//Else
	cSQL  := "SELECT COUNT(*) AS ACHOU  FROM SIGA.UPDREG@PROD WHERE UN  " + cUns + "  AND  TAB = '" + cTabela + "' AND REC = " + AllTrim( Str( nRecNo ) )
//EndIf

	Do While ( .T. )
		lRet := .T.
		nAchou:=0
		If ( Select(cAliasQry)  > 0 )
			(cAliasQry)->(DbCloseArea())
		EndIf
		TCRefresh("SIGA.UPDREG@PROD")
		TcQuery cSQL Alias (cAliasQry) New
		If !(cAliasQry)->(Eof())
			nAchou:=(cAliasQry)->ACHOU
		Else
			nAchou:=0
		Endif
		(cAliasQry)->(DbCloseArea())
		If nAchou > 0

			If U_FTimerMsg( "Registro Bloqueado", "Aguarde alguns instantes, pois o registro esta em usos por outro usu·rio. <br>Em 05 segundos sua tela ser· <B>reiniciada</B>, ou clique em continuar", NIL, "FUNCOES", "FMeuTimer" )
				lRet := .F.
				Loop
			Else
				lRet := .T.
				Exit
			EndIf
		Else
			lRet := .T.
			Exit
		EndIf
	EndDo

	RestArea(aAreaAnt)

Return( lRet )

	*-------------------------------------------------------------------------------*
/*/{Protheus.doc} FMeuTimer

Rotina para uso em conjunto com a FunÁ„o FTimerMsg, para registrar a continuaÁ„o
do processamento de verificaÁ„o de Bloqueio de registro.

@params

@Exemplo

	lRet := .F.
If U_FTimerMsg( "Registro Bloqueado", "Aguarde alguns instantes, pois o registro esta em usos por outro usu·rio. <br>Em 05 segundos sua tela ser· <B>reiniciada</B>, ou clique em continuar", NIL, "FUNCOES", "FMeuTimer" )
		Loop
Else
		Exit
EndIf

@author Ricardo da Silva
@email ricardo.silva@rgrsolucoes.com
@since 23/05/2016
@version 1.0

@return

@see www.rgrsolucoes.com
/*/
*--------------------------------------------------------------------------------*
*-------------------------*
Static Function FMeuTimer()
	*-------------------------*
	sleep(10)
Return(.T.)


	*--------------------*
User Function ImpDDA()
	*--------------------*
	Local aAreaAnt		:= GetArea()
	Local aAreaSA2  	:= SA2->( GetArea() )
	Local aAreaFIG 		:= FIG->( GetArea() )
	Local aRet	 		:= { "a" }
	Local nPosCNPJ 		:= 01 // PosiÁ„o do CNPJ no retorno do RetDDA()
	Local nPosVencto 	:= 02 // PosiÁ„o do Vecimento no retorno da FunÁ„o RetDDA()
	Local nPosValor		:= 03 // PosiÁ„o do Valor no retorno da FunÁ„o RetDDA()
	Local nPosTitulo	:= 04 // PosiÁ„o do TÌtulo Financeiro no retorno da FunÁ„o RetDDA()
	Local nPosData 		:= 05 // PosiÁ„o da Data no retorno da FunÁ„o RetDDA()
	Local nPosCodBarras := 06 // PosiÁ„o do CÛdigo de Barras no retorno da FunÁ„o RetDDA()
	Local nPosTipo		:= 07 // PosiÁ„o do Campo Tipo no retorno da FunÁ„o RetDDA()
	Local nPosNomeForn  := 08 // PosiÁ„o do Campo Nome do Fornecedor Oriundo do DDA
	Local nPosCnpjSac   := 10 // PosiÁ„o do cnpj do sacador
	Local nPosTpMov   	:= 11 // PosiÁ„o do cnpj do sacador
	Local l_Altera 		:= .F.
	Local l_Conc 	 	:= .F.

	Local l_SacAv := .F.
	Private oSrv 		:= RPCConnect( "10.0.100.6", 1234, "ORTOBOM", "51", "01" )
//Private oSrv 		:= RPCConnect( "10.0.100.6", 1235, "ORTOBOM", "51", "01" )

	If ValType( oSrv ) == "O"                                           '

		Do While Len( aRet ) > 0

			aRet := oSrv:CallProc( "U_RetDDA", cEmpAnt, cFilAnt )
			//aRet := U_RetDDA(cEmpAnt)
			If Len( aRet ) > 0

				lForn := .F.
				DbSelectArea( "SA2" )   // Cadastro de Fornecedores
				DbSetOrder( 03 ) 		// A2_FILIAL + A2_CGC
				If ( aRet[nPosCnpjSac] == '00000000000000' .or. ;
						Empty( aRet[nPosCnpjSac]) ) .AND.;
						DbSeek( XFilial( "SA2" ) + aRet[nPosCNPJ] )
					//If DbSeek( XFilial( "SA2" ) + aRet[nPosCNPJ] )

					lForn 	:= .T.
					c_Cnpj 	:= aRet[nPosCNPJ]
					l_SacAv := .F.

				ElseIf aRet[nPosCnpjSac] <> '00000000000000' .and. ;
						!Empty( aRet[nPosCnpjSac])

					If DbSeek( XFilial( "SA2" ) + aRet[nPosCnpjSac] )

						lForn 	:= .T.
						l_SacAv := .T.
						c_Cnpj 	:= aRet[nPosCnpjSac]

					ElseIf DbSeek( XFilial( "SA2" ) + substr( aRet[nPosCnpjSac], 1, 8)  )

						lForn 	:= .T.
						l_SacAv := .T.
						c_Cnpj 	:= aRet[nPosCnpjSac]

					EndIf

				EndIf

				DbSelectArea( "FIG" )	// ConciliaÁ„o DDAs
				DbSetOrder( 04 ) 		// FIG_FILIAL + FIG_CODBAR
				//If !DbSeek( XFilial( "FIG" ) + aRet[nPosCodBarras] )
				If DbSeek( XFilial( "FIG" ) + aRet[nPosCodBarras] )
					// Existe da FIG e n„o foi conciliado

					If FIG->FIG_CONCIL == "2"

						l_Altera := .F.
						l_Conc   := .F.

					Else

						l_Conc   := .T.
						l_Altera := .F.

					EndIf

				Else

					l_Altera := .T.
					l_Conc 	 := .F.

				EndIf

				If RecLock( "FIG", l_Altera ) .and. !l_Conc

					FIG->FIG_FILIAL	:= XFilial( "FIG" )
					FIG->FIG_DATA  	:= SToD( aRet[nPosData] )
					If lForn
						FIG->FIG_FORNEC	:= SA2->A2_COD
						FIG->FIG_LOJA  	:= SA2->A2_LOJA
						FIG->FIG_NOMFOR	:= SA2->A2_NOME
						FIG->FIG_CNPJ  	:= SA2->A2_CGC
					Else

						FIG->FIG_NOMFOR	:= aRet[nPosNomeForn]
						FIG->FIG_CNPJ  	:= aRet[nPosCNPJ]

					EndIf


					If l_SacAv

						//FIG->FIG_CNPJ  	:= aRet[nPosCNPJ    ] // CASO SEJA SACADOR AVALISTA, O CNPJ ENTRA DO ARQUIVO PARA QUE A ROTINA POSSA ENCONTRAR O REGISTRO // Retirado em 23/01/2020 por afetar ORTR745
						FIG->FIG_XCNPJS	:= aRet[nPosCNPJ    ]
						FIG->FIG_XNOMSC	:= aRet[nPosNomeForn]

					EndIf

					FIG->FIG_TITULO	:= aRet[nPosTitulo]
					FIG->FIG_VENCTO	:= SToD( aRet[nPosVencto] )
					FIG->FIG_VALOR 	:= aRet[nPosValor]

					FIG->FIG_CODBAR	:= aRet[nPosCodBarras]
					FIG->FIG_CONCIL	:= "2"  // nao
					If AllTrim( aRet[nPosTipo] ) == "12"
						FIG->FIG_TIPO  := "NP"
					Else
						FIG->FIG_TIPO  := "DP"
					EndIf


					FIG->FIG_XTIPMO	:= aRet[nPosTpMov]
					FIG->( MsUnLock() )

				EndIf

				//EndIf

				// Concilia na Unidade o DDA
				oSrv:CallProc( "U_MarkDDA", cEmpAnt, aRet[nPosCodBarras], cFilAnt )
				//U_MarkDDA( cEmpAnt, aRet[nPosCodBarras] )

			EndIf

		EndDo

	Else

		Aviso("AtenÁ„o", "Problemas ao tentar conectar com o ambiente remoto: ", { "Sair" } )  //+ aSrv[I][03] )

	EndIf

	RestArea( aAreaSA2 )
	RestArea( aAreaFIG )
	RestArea( aAreaAnt )

Return

	**********************************************************************************
/*
Retorna uma vari·vel em formato serializado.

Aceita apenas par‚metros do tipo N, C, L, D e A
*/
User Function ORTSERIA(xPar)
	**********************************************************************************
	Local _cTipoVar	:= ""
	Local _cVarSer	:= ""
	Local _cBuffer	:= ""
	Local _nX		:= 0

	_cTipoVar	:= ValType(xPar)
	If !(_cTipoVar $ "NCLDA")
		Return Nil
	EndIf

	_cBuffer	:= _cTipoVar
	_cVarSer	:= ""

	If _cTipoVar == "N"
		_cVarSer	:= AllTrim(Str(xPar))
	ElseIf _cTipoVar == "C"
		_cVarSer	:= xPar
	ElseIf _cTipoVar == "L"
		_cVarSer	:= IIf(xPar, "T", "F")
	ElseIf _cTipoVar == "D"
		_cVarSer	:= DToS(xPar)
	ElseIf _cTipoVar == "A"
		_cVarSer	:= ""
		For _nX := 1 To Len(xPar)
			_cVarSer	+= U_ORTSERIA(xPar[_nX])
		Next _nX
	EndIf

	_cBuffer	+= StrZero(Len(_cVarSer), 07)
	_cBuffer	+= _cVarSer

Return _cBuffer

	**********************************************************************************
/*
Retorna uma vari·vel serializada em formato AdvPL atravÈs da funÁ„o U_ORTSERIA
*/
User Function ORTDESER(_cBuffer)
	**********************************************************************************
	Local _xRet		:= Nil
	Local _cTipoVar	:= ""
	Local _nTamFixo	:= 0
	Local _nX		:= 0

	If ValType(_cBuffer) == "C" .And. Len(_cBuffer) >= 08
		_cTipoVar	:= SubStr(_cBuffer, 1, 1)
		_nTamFixo	:= Val(SubStr(_cBuffer, 2, 7))
		If _cTipoVar == "N"
			_xRet	:= Val(SubStr(_cBuffer, 09, _nTamFixo))
		ElseIf _cTipoVar == "C"
			_xRet	:= SubStr(_cBuffer, 09, _nTamFixo)
		ElseIf _cTipoVar == "L"
			_xRet	:= (SubStr(_cBuffer, 09, 01) == "T")
		ElseIf _cTipoVar == "D"
			_xRet	:= SToD(SubStr(_cBuffer, 09, 08))
		ElseIf _cTipoVar == "A"
			_nX		:= 09
			_xRet	:= {}
			While _nX <= Len(_cBuffer)
				_nTamFixo	:= Val(SubStr(_cBuffer, _nX + 1, 7))
				aAdd(_xRet, U_ORTDESER(SubStr(_cBuffer, _nX, 08 + _nTamFixo)))
				_nX	+= 08 + _nTamFixo
			EndDo
		EndIf
	EndIf

Return _xRet

	**********************************************************************************
/*
Insere um valor no cache
*/
User Function ORTCHPUT(_cChave, _xValor, _nDuracao)
	**********************************************************************************
	Local _cPostRet	:= ""
	Local _xValorS	:= ""

	_xValorS	:= U_ORTSERIA(_xValor)

	If ValType(_nDuracao) <> "N" .Or. _nDuracao < 1
		_nDuracao	:= 10
	EndIf

	_cChave		:= md5(_cChave, 2)
	_cPostRet	:= HttpPost(;
		'http://10.0.100.133:8001/memcached/?apikey=apikeysigo&chave=' + _cChave + '&duracao=' + AllTrim(Str(_nDuracao)),;
		"",;
		_xValorS)

Return _cPostRet

	**********************************************************************************
/*
Retorna uma vari·vel armazenada no cache
*/
User Function ORTCHGET(_cChave)
	**********************************************************************************
	Local _cGet	:= ""
	Local _xRet	:= Nil

	_cChave	:= md5(_cChave, 2)
	_cGet	:= httpGet('http://10.0.100.133:8001/memcached/' + _cChave + '?apikey=apikeysigo')
	_xRet	:= U_ORTDESER(_cGet)

Return _xRet


	**********************************************************************************
/*
Valida a permiss„o de digitaÁ„o para o campo A1_XROTA
*/
User Function ORTWROTA()
	**********************************************************************************
Return M->A1_XROTA=="000000" .And. U_ORTGRUPO("ALTSITEFRT")


	**********************************************************************************
/*
Valida a permiss„o de digitaÁ„o para o campo A1_XPERFRE
*/
User Function ORTWFRET()
	**********************************************************************************
	Local nFreteDef	:= 0

	If cEmpAnt == "15"
		nFreteDef	:= 2.7
	EndIf

Return M->A1_XPERFRE==nFreteDef .And. U_ORTGRUPO("ALTSITEFRT")


	**********************************************************************************
/*
Envio e E-mail sistema para domÌnios @ortobom.com.br
*/
User Function ORTSMAIL(_cDestino, _cBody, _cAssunto, _cCc)
	**********************************************************************************
	Local lOk	:= .T.

	If Empty(_cDestino) .Or. Empty(_cBody)
		Return .F.
	EndIf

	If !IsEmail(_cDestino)
		Return .F.
	EndIf

	If Empty(_cAssunto)
		_cAssunto	:= "NotificaÁ„o sistema SIGO"
	EndIf

	_cBody	+= "<br><br>Equipe CPD Regional RJ Ortobom"

	CONNECT SMTP SERVER "10.0.100.102" ACCOUNT "sistema" PASSWORD "sis7823@w" Result lOk

	If !lOk
		Return .F.
	EndIf

	If !Empty(_cCc)
		SEND MAIL FROM "sistema@ortobom.com.br" TO _cDestino CC _cCC SUBJECT _cAssunto BODY _cBody Result lOk
	Else
		SEND MAIL FROM "sistema@ortobom.com.br" TO _cDestino SUBJECT _cAssunto BODY _cBody Result lOk
	EndIf

	DISCONNECT SMTP SERVER

Return lOk

	**********************************************************************************
/*
Tratar a Hora nas Unidades ORTA576/ORTA571
*/
User Function HORAUNID(_cUnidade)
	**********************************************************************************
	Local _cHrUn	:= ""
	Local aRet	:= {}
	Local cHrVerao  := "N"

	CriaMv("MV_XHRVERA"	, "Indica se esta no hor·rio de Ver„o no RJ      ","Pos Venda e Pos Troca","S")

	cHrVerao := GetNewPar("MV_XHRVERA","N")

	If _cUnidade == "06"

		aRet := FwTimeUF('MT')

	/* Teste
	_cHrUn	:= time()
	_cTexto := "Hora RJ: "+_cHrUn
		For I:= 1 to len(aRet)
		_ctexto += " Convers„o: "+aRet[I]
		Next
	Alert(_ctexto)*/

	_cHrUn := aRet[2]

	ElseIf _cUnidade == "26"

	aRet := FwTimeUF('AM')

	/* Teste
	_cHrUn	:= time()
	_cTexto := "Hora RJ: "+_cHrUn
		For I:= 1 to len(aRet)
		_ctexto += " Convers„o: "+aRet[I]
		Next
	Alert(_ctexto)*/

		If cHrVerao == 'S'
		_cHrUn := DecTime(time(),01,00,00)
		Else
		_cHrUn := aRet[2]
		EndIf

	ElseIf cHrVerao == "S"

		If _cUnidade $ "07|08|09|11|23|24"
			if substr(time(),1,2) == "00"
			_cHrUn	:= time()
			else
			_cHrUn := DecTime(time(),01,00,00)
			endif
		Else
		_cHrUn	:= time()
		EndIf

	Else
	_cHrUn	:= time()
	EndIf

Return _cHrUn

*---------------------------*
Static Function CriaMV( cMV, cDesc, cDesc2, cConteudo)
*---------------------------*
Local _aArea := GetArea()

dbSelectArea( "SX6" )
dbSetOrder(1)

	If !dbSeek( xFilial("SX6") + cMV )
	RecLock("SX6", .T.)
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := cMV
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := cDesc
	SX6->X6_DESC1	:= cDesc2
	SX6->X6_CONTEUD := cConteudo
	SX6->X6_CONTSPA := " "
	SX6->X6_CONTENG := " "
	SX6->X6_PROPRI  := "U"
	SX6->X6_PYME    := "S"
	MsUnlock()
	EndIf

RestArea( _aArea )

Return
**********************************************************************************

/**********************************************************************************
Retorna o preÁo do metro c˙bico para cortes sob-medida de colchıes e camas
**********************************************************************************/
User Function ORTSMEDP(_cCodBase, _cCodTab, _cRefTab, _cCodCli, _nPrzMed)
**********************************************************************************
Local nRet		:= 0
Local nMaxVal	:= 0
Local cTpCli	:= 0
Local nAcresR	:= 0
Local nPrecoZV	:= 0
Local nC90D		:= 0
Local nC75D		:= 0
Local nC60D		:= 0
Local nC45D		:= 0
Local nC30D		:= 0
Local nC15D		:= 0
Local nC01D		:= 0
Local nC00D		:= 0
Local nFAIXA1	:= 0
Local nFAIXA2	:= 0
Local nFAIXA3	:= 0
Local nFAIXA4	:= 0
Local nAcresPrz	:= 0
Local nAcresFai	:= 0
Local nDescCome	:= 0
Local cQuery	:= ""
Local aMedTri	:= {}

	If !(cEmpAnt $ "02|03|04|06|07|08|09|10|11|15|25|26")
	Return 0
	EndIf

_cCodBase	:= PADR(_cCodBase, GetSX3Cache("B1_COD", "X3_TAMANHO"))
_cCodTab	:= PADR(_cCodTab, GetSX3Cache("DA1_CODTAB", "X3_TAMANHO"))
_cRefTab	:= SubStr(_cRefTab, 1, 1)

SB1->(dbOrderNickName("PSB11"))	//B1_FILIAL+B1_COD
	If SB1->(!dbSeek(xFilial("SB1")+_cCodBase))
	Return 0
	EndIf

SZV->(dbOrderNickName("CSZV1"))	//ZV_FILIAL+ZV_TABELA+ZV_GRUPO
	If SZV->(!dbSeek(xFilial("SZV")+_cCodTab+SB1->B1_GRUPO))
	Return 0
	EndIf

nPrecoZV	:= SZV->ZV_VENDA

	If Empty(_cCodCli)
	cTpCli	:= "P"
	Else
	SA1->(dbOrderNickName("PSA11"))	//A1_FILIAL+A1_COD+A1_LOJA
		If SA1->(!dbSeek(xFilial("SA1")+_cCodCli))
		Return 0
		EndIf

	aMedTri	:= u_fMedTri(SA1->A1_COD, SA1->A1_LOJA, dDataBase)

		If aMedTri[4] >= aMedTri[3] .And. aMedTri[4] >= aMedTri[2] .And. aMedTri[4] >= aMedTri[1]
		nMaxVal	:= aMedTri[4]
		ElseIf aMedTri[3] >= aMedTri[2] .And. aMedTri[3] >= aMedTri[1]
		nMaxVal	:= aMedTri[3]
		ElseIf aMedTri[2] >= aMedTri[1]
		nMaxVal	:= aMedTri[2]
		Else
		nMaxVal	:= aMedTri[1]
		EndIf

		If nMaxVal < 100
		cTpCli	:= "P"
		ElseIf nMaxVal < 200
		cTpCli	:= "V"
		ElseIf nMaxVal < 300
		cTpCli	:= "S"
		Else
		cTpCli	:= "E"
		EndIf
	EndIf

	If _cRefTab == "A" .Or. (SB1->B1_XSEGMEN $ "3|4" .And. _cRefTab == "F") .Or. (SB1->B1_XSEGMEN $ "2" .And. _cRefTab == "K")
	nAcresR	:= 1.00
	ElseIf _cRefTab == "B" .Or. (SB1->B1_XSEGMEN $ "3|4" .And. _cRefTab == "G")
	nAcresR	:= 1.05
	ElseIf _cRefTab == "C" .Or. (SB1->B1_XSEGMEN $ "3|4" .And. _cRefTab == "H")
	nAcresR	:= 1.10
	ElseIf _cRefTab == "D" .Or. (SB1->B1_XSEGMEN $ "3|4" .And. _cRefTab == "I")
	nAcresR	:= 1.15
	Else
	nAcresR	:= 1.20
	EndIf

U_ORTR306F(@nC90D, @nC75D, @nC60D, @nC45D, @nC30D, @nC15D, @nC01D, @nC00D, @nFAIXA1, @nFAIXA2, @nFAIXA3, @nFAIXA4, _cRefTab)

	If _nPrzMed >= 90
	nAcresPrz	:= nC90D
	ElseIf _nPrzMed >= 75
	nAcresPrz	:= nC75D
	ElseIf _nPrzMed >= 60
	nAcresPrz	:= nC60D
	ElseIf _nPrzMed >= 45
	nAcresPrz	:= nC45D
	ElseIf _nPrzMed >= 30
	nAcresPrz	:= nC30D
	ElseIf _nPrzMed >= 15
	nAcresPrz	:= nC15D
	Else
	nAcresPrz	:= nC01D
	EndIf

	If cTpCli == "P"
	nAcresFai	:= nFAIXA1
	ElseIf cTpCli == "V"
	nAcresFai	:= nFAIXA2
	ElseIf cTpCli == "S"
	nAcresFai	:= nFAIXA3
	Else
	nAcresFai	:= nFAIXA4
	nAcresPrz	:= nC00D
	EndIf

cQuery	:= " SELECT ACP_PERDES "
cQuery	+= "   FROM "+RetSqlName("ACP")+" ACP, "+RetSqlName("SB1")+" SB1 "
cQuery	+= "  WHERE ACP.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SB1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND ACP_FILIAL = '"+xFilial("ACP")+"' "
cQuery	+= "    AND B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery	+= "    AND ACP_CODREG = '00"+_cCodTab+_cRefTab+"' "
cQuery	+= "    AND B1_COD = ACP_CODPRO "
cQuery	+= "    AND B1_GRUPO = '"+SB1->B1_GRUPO+"' "
cQuery	+= "  ORDER BY 1 "
U_ORTQUERY(cQuery, "ORTSMEDPC")
nDescCome	:= 0
	If ORTSMEDPC->(!EOF()) .And. ORTSMEDPC->ACP_PERDES > 0
	nDescCome	:= ORTSMEDPC->ACP_PERDES
	EndIf
ORTSMEDPC->(dbCloseArea())

nRet	:= nPrecoZV
nRet	:= nRet * nAcresR
nRet	:= nRet * (100 - nAcresPrz) / 100
nRet	:= nRet * (100 - nAcresFai) / 100
nRet	:= nRet * (100 - nDescCome) / 100
nRet	:= Round(nRet, 2)

Return nRet


User Function ValQE()
Local aArea := GetArea()
Local lRet:=.T.
Local nX			:= 0
Local nY			:= 0
Local aVldInfUsr	:= {}
Local aGruposVld	:= AllGroups()
Local cGrupo:=""
Local cGrupo2:=""


PswOrder(1)
PswSeek(__cUserID, .T.)
aVldInfUsr	:= PswRet(1)

nX	:= AScan(aGruposVld, {|x| AllTrim(UPPER(x[1,2])) == AllTrim(UPPER("ALTMATSB1"))})
nY	:= AScan(aGruposVld, {|x| AllTrim(UPPER(x[1,2])) == AllTrim(UPPER("ALTSB1"))})

cGrupo:=aGruposVld[nX,1,1] //MATSB1
cGrupo2:=aGruposVld[nY,1,1] //ALTSB1


	If ascan(aVldInfUsr[1,10],AllTrim(cGrupo)) > 0 .AND. ascan(aVldInfUsr[1,10],AllTrim(cGrupo2)) = 0
		If !M->B1_TIPO$"MP|CR|CF"
	Alert("Usuario sem permiss„o para alterar este tipo de produto")
	lRet:=.F.
		Endif
//	cCodGrpVld	:= aGruposVld[nX][1][1]
	EndIf


RestArea(aArea)
Return(lRet)

// ------------------------------------------------------------------

***************************************************************************
User Function fDelPedL(_cPedido)
***************************************************************************
Local nX		:= 0
Local nCntPExcl	:= 0
Local _cBordero	:= ""
Local cQuery	:= ""
Local lRet		:= .T.
Local lLjExcl	:= .F.
Local _aPedidos	:= {}

_cPedido	:= PADR(_cPedido, GetSX3Cache("Z2_PEDIDO", "X3_TAMANHO"))
_cBordero	:= Space(08)

cQuery	:= " SELECT BORDERO, A1_XTIPO "
cQuery	+= "   FROM FISICO, "+RetSqlName("SA1")+" SA1 "
cQuery	+= "  WHERE UNIDADE = '"+cEmpAnt+"' "
cQuery	+= "    AND PEDIDO = '"+_cPedido+"' "
cQuery	+= "    AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery	+= "    AND A1_CGC = CLIENTE "
U_ORTQUERY(cQuery, "FDELPEDLBD")
	If FDELPEDLBD->(!EOF())
	_cBordero	:= PADR(FDELPEDLBD->BORDERO, 08)
	lLjExcl		:= AllTrim(FDELPEDLBD->A1_XTIPO) == "4"
	EndIf
FDELPEDLBD->(dbCloseArea())

nCntPExcl	:= 0
	If lLjExcl
	cQuery	:= " SELECT PEDIDO, "
	cQuery	+= "        SUM(DECODE(NVL(SZ2.R_E_C_N_O_, 0), 0, 0, 1)) AS PEDZ2, "
	cQuery	+= "        SUM(DECODE(NVL(SZB.R_E_C_N_O_, 0), 0, 0, 1)) AS PEDZB, "
	cQuery	+= "        SUM(DECODE(NVL(SZL.R_E_C_N_O_, 0), 0, 0, 1)) AS PEDZL "
	cQuery	+= "   FROM FISICO, "
	cQuery	+= "        "+RetSqlName("SZ2")+" SZ2, "
	cQuery	+= "        "+RetSqlName("SZB")+" SZB, "
	cQuery	+= "        "+RetSqlName("SZL")+" SZL "
	cQuery	+= "  WHERE UNIDADE = '"+cEmpAnt+"' "
	cQuery	+= "    AND BORDERO = '"+_cBordero+"' "
	cQuery	+= "    AND SZ2.D_E_L_E_T_(+) = ' ' "
	cQuery	+= "    AND Z2_FILIAL(+) = '"+xFilial("SZ2")+"' "
	cQuery	+= "    AND Z2_PEDIDO(+) = PEDIDO "
	cQuery	+= "    AND SZB.D_E_L_E_T_(+) = ' ' "
	cQuery	+= "    AND ZB_FILIAL(+) = '"+xFilial("SZB")+"' "
	cQuery	+= "    AND ZB_NUMPED(+) = PEDIDO "
	cQuery	+= "    AND SZL.D_E_L_E_T_(+) = ' ' "
	cQuery	+= "    AND ZL_FILIAL(+) = '"+xFilial("SZL")+"' "
	cQuery	+= "    AND ZL_PEDIDO(+) = PEDIDO "
	cQuery	+= "  GROUP BY PEDIDO "
	cQuery	+= "  ORDER BY 1 "
	U_ORTQUERY(cQuery, "FDELPEDL")
		While FDELPEDL->(!EOF())
		nCntPExcl	+= FDELPEDL->PEDZ2
		nCntPExcl	+= FDELPEDL->PEDZB
		nCntPExcl	+= FDELPEDL->PEDZL
		aAdd(_aPedidos, PADR(FDELPEDL->PEDIDO, GetSX3Cache("Z2_PEDIDO", "X3_TAMANHO")))
		FDELPEDL->(dbSkip())
		EndDo
	FDELPEDL->(dbCloseArea())

		If Empty(nCntPExcl)	//N„o existem pedidos de exclusiva
		Return .T.
		EndIf
	Else
	aAdd(_aPedidos, _cPedido)
	EndIf

	For nX := 1 To Len(_aPedidos)
	lRet	:= lRet .And. fDelPedL_V(_aPedidos[nX], (_aPedidos[nX] == _cPedido))
	Next nX

	If lRet
		For nX := 1 To Len(_aPedidos)
		fDelPedL(_aPedidos[nX])
		Next nX
	EndIf

Return lRet


***************************************************************************
Static Function fDelPedL_V(_cPedido, _lVldCanc)
***************************************************************************
Local cQuery	:= ""
Local lRet		:= .T.

cQuery	:= " SELECT R_E_C_N_O_ "
cQuery	+= "   FROM " + RetSqlName("SZ2")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND Z2_FILIAL = '"+xFilial("SZ2")+"' "
cQuery	+= "    AND Z2_PEDIDO = '"+_cPedido+"' "
cQuery	+= "    AND (Z2_NUMPED <> '      ' "+IIf(_lVldCanc, "OR Z2_SITUACA = 'C'", "")+") "
cQuery	+= " UNION ALL "
cQuery	+= " SELECT R_E_C_N_O_ "
cQuery	+= "   FROM " + RetSqlName("SZB")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND ZB_FILIAL = '"+xFilial("SZB")+"' "
cQuery	+= "    AND ZB_NUMPED = '"+_cPedido+"' "
cQuery	+= "    AND ZB_FLAGINT = '1' "
U_ORTQUERY(cQuery, "FDELPEDL_V")
lRet	:= FDELPEDL_V->(EOF())
FDELPEDL_V->(dbCloseArea())

Return lRet


***************************************************************************
Static Function fDelPedL(_cPedido)
***************************************************************************
Local cQuery	:= ""

cQuery	:= " SELECT 'SZ2' AS TABELA, R_E_C_N_O_ AS RECNUM "
cQuery	+= "   FROM " + RetSqlName("SZ2")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND Z2_FILIAL = '"+xFilial("SZ2")+"' "
cQuery	+= "    AND Z2_PEDIDO = '"+_cPedido+"' "
cQuery	+= "    AND Z2_NUMPED = '"+Space(GetSX3Cache("Z2_PEDIDO", "X3_TAMANHO"))+"' "
cQuery	+= "    AND Z2_SITUACA <> 'C' "
cQuery	+= " UNION ALL "
cQuery	+= " SELECT 'SZB' AS TABELA, R_E_C_N_O_ AS RECNUM "
cQuery	+= "   FROM " + RetSqlName("SZB")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND ZB_FILIAL = '"+xFilial("SZB")+"' "
cQuery	+= "    AND ZB_NUMPED = '"+_cPedido+"' "
cQuery	+= "    AND ZB_FLAGINT <> '1' "
cQuery	+= " UNION ALL "
cQuery	+= " SELECT 'SZL' AS TABELA, R_E_C_N_O_ AS RECNUM "
cQuery	+= "   FROM " + RetSqlName("SZL")
cQuery	+= "  WHERE D_E_L_E_T_ = ' ' "
cQuery	+= "    AND ZL_FILIAL = '"+xFilial("SZL")+"' "
cQuery	+= "    AND ZL_PEDIDO = '"+_cPedido+"' "
U_ORTQUERY(cQuery, "FDELPEDLDE")
	While FDELPEDLDE->(!EOF())
		If FDELPEDLDE->TABELA == "SZ2"
		SZ2->(dbGoTo(FDELPEDLDE->RECNUM))
		RecLock("SZ2", .F.)
		SZ2->(dbDelete())
		SZ2->(msUnlock())
		ElseIf FDELPEDLDE->TABELA == "SZB"
		SZB->(dbGoTo(FDELPEDLDE->RECNUM))
		U_fDelSZB()
		ElseIf FDELPEDLDE->TABELA == "SZL"
		SZL->(dbGoTo(FDELPEDLDE->RECNUM))
		RecLock("SZL", .F.)
		SZL->(dbDelete())
		SZL->(msUnlock())
		EndIf
	FDELPEDLDE->(dbSkip())
	EndDo
FDELPEDLDE->(dbCloseArea())

	If !(GetNewPar("MV_BLQDEPO", .t.) .and. Date() >= STOD("20161019"))
	TcSqlExec("UPDATE DEPOFIN SET USADO = 'N' WHERE UNIDADE = '"+cEmpAnt+"' AND PEDIDO = '"+_cPedido+"'")
	endif
TcSqlExec("UPDATE FISICO SET IMPORTADO = 'N' WHERE UNIDADE = '"+cEmpAnt+"' AND PEDIDO = '"+_cPedido+"'")
TcSqlExec("UPDATE FINANCEIRO SET IMPORTADO = 'N' WHERE UNIDADE = '"+cEmpAnt+"' AND PEDIDO = '"+_cPedido+"'")

Return


***************************************************************************
User Function ORTVLCPD()
***************************************************************************
Local lRet		:= .T.
Local cQuery	:= ""

cQuery	:= "SELECT COUNT(*) TOT FROM USULIB WHERE UPPER(USU) = '"+AllTrim(UPPER(cUserName))+"'"
U_ORTQUERY(cQuery, "ORTVLCPD")
lRet	:= ORTVLCPD->TOT > 0
ORTVLCPD->(dbCloseArea())
	if alltrim(upper(cUserName))=="DUPIM" .And. alltrim(upper(cUserName))=="RAFAEL.MELO"
   lRet:=.T.
	Endif

Return lRet


***************************************************************************
User Function ORTLHOMO()
***************************************************************************
Local cTitulo	:= "Painel de ExportaÁ„o"
Local cSql		:= ""
Local cUnLib	:= cEmpAnt
Local cUsuLib	:= Space(50)
Local dDtLib	:= DATE()
Local cHrLib	:= TIME()
Local cObsLib	:= Space(100)
Local aPergs	:= {}
Local aRet		:= {}

	If !U_ORTVLCPD()
	MsgStop("Usu·rio sem acesso para liberar ambiente de homologaÁ„o.")
	Return
	EndIf

cHrLib	:= StrZero(Val(SubStr(cHrLib, 1, 2)) + 5, 02) + SubStr(cHrLib, 3)

aAdd(aPergs ,{1,"Unidade ",cUnLib,"@!",'',"",'.T.',40,.T.})
aAdd(aPergs ,{1,"Usu·rio ",cUsuLib,"",'',"US3",'.T.',40,.T.})
aAdd(aPergs ,{1,"Data ExpiraÁ„o ",dDtLib,"@d",'',"",'.T.',40,.T.})
aAdd(aPergs ,{1,"Hora ExpiraÁ„o ",cHrLib,"@!",'',"",'.T.',40,.T.})
aAdd(aPergs ,{1,"ObservaÁıes ",cObsLib,"@!",'',"",'.T.',100,.F.})
	If !Parambox ( aPergs, cTitulo, aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, "ORTLHOMO" + AllTrim(__cUserId) /* cLoad */, .T. /* lCanSave */, /* lUserSave */ )
	Return
	EndIf

cUnLib	:= MV_PAR01
cUsuLib	:= AllTrim(MV_PAR02)
dDtLib	:= MV_PAR03
cHrLib	:= MV_PAR04
cObsLib	:= AllTrim(MV_PAR05)

cSql	:= " INSERT INTO HOMOLIB (UNIDADE, LIBERADOR, USUARIO, OBS, DATA, HORA, DTINC, HRINC) "
cSql	+= " VALUES "
cSql	+= "   ('"+cUnLib+"', "
cSql	+= "    '"+AllTrim(cUserName)+"', "
cSql	+= "    '"+cUsuLib+"', "
cSql	+= "    '"+cObsLib+"', "
cSql	+= "    '"+DToS(dDtLib)+"', "
cSql	+= "    '"+cHrLib+"', "
cSql	+= "    '"+DToS(DATE())+"', "
cSql	+= "    '"+TIME()+"') "
	If TcSqlExec(cSql) < 0
	MsgStop("Erro ao efetuar liberaÁ„o para ambiente de homologaÁ„o.")
	Return
	EndIf

MsgInfo("LiberaÁ„o efetuada com sucesso para usu·rio '"+cUsuLib+"' atÈ a data "+DToC(dDtLib)+" "+cHrLib)

Return


***************************************************************************
User Function SISLJAPI(_cChaveCmd, _aParams)
***************************************************************************
Local _xRet		:= Nil
Local _cGetPars	:= ""
Local _aHeadOut	:= {}

	If _cChaveCmd == "/api/Pedido/IsCancelable"
	aAdd(_aHeadOut, 'Accept: application/json')
	_cGetPars	:= "IdOrtobom=" + Escape(_aParams[01])
		If cEmpAnt == "02"
		_cGetPars	+= "&Fabrica=SP"
		ElseIf cEmpAnt == "03"
		_cGetPars	+= "&Fabrica=RJ"
		ElseIf cEmpAnt == "04"
		_cGetPars	+= "&Fabrica=MG"
		ElseIf cEmpAnt == "05"
		_cGetPars	+= "&Fabrica=GO"
		ElseIf cEmpAnt == "06"
		_cGetPars	+= "&Fabrica=MT"
		ElseIf cEmpAnt == "07"
		_cGetPars	+= "&Fabrica=BA"
		ElseIf cEmpAnt == "08"
		_cGetPars	+= "&Fabrica=PE"
		ElseIf cEmpAnt == "09"
		_cGetPars	+= "&Fabrica=CE"
		ElseIf cEmpAnt == "10"
		_cGetPars	+= "&Fabrica=PR"
		ElseIf cEmpAnt == "11"
		_cGetPars	+= "&Fabrica=PA"
		ElseIf cEmpAnt == "15"
		_cGetPars	+= "&Fabrica=RS"
		ElseIf cEmpAnt == "26"
		_cGetPars	+= "&Fabrica=AM"
		EndIf
	_xRet		:= (SljAPIGet(_cChaveCmd, _aHeadOut, _cGetPars) == "true")
	EndIf

Return _xRet


***************************************************************************
Static Function SljAPIGet(_cChaveCmd, _aHeadOut, _cGetPars)
***************************************************************************
Local _nTimeOut	:= 60
Local _cHeadRet	:= ""
Local _cBodyRet	:= ""
Local _cToken	:= ""

_cToken		:= SislAPITok()
aAdd(_aHeadOut, 'Authorization: ' + _cToken)

_cBodyRet	:= HttpGet(;
				"http://services.ortobom.com.br:81" + _cChaveCmd + "?" + _cGetPars,;
				"",;
				_nTimeOut,;
				_aHeadOut,;
				@_cHeadRet)

Return _cBodyRet


***************************************************************************
Static Function SislAPITok(_lForca)
***************************************************************************
Local _cToken	:= ""
Local _cReqBody	:= '{"userName": "microsiga","password": "7s0m1cr0.5a7s1g4"}'
Local _cHost	:= "http://services.ortobom.com.br:81"
Local _cAPI		:= "/api/Users/login"
Local _cGetPar	:= ""
Local _nTimeOut	:= 60
Local _aHeadOut	:= {}
Local _cHeadRet	:= ""
Local _cCacheCh	:= "SISLOJA_BEARER_TOKEN"
Local _oObjRet	:= Nil

Default _lForca	:= .F.

	If !_lForca
	_cToken	:= U_ORTCHGET(_cCacheCh)
		If ValType(_cToken) == "C" .And. !Empty(_cToken)
		Return _cToken
		EndIf
	EndIf

aAdd(_aHeadOut, 'Content-Type: application/json')
aAdd(_aHeadOut, 'Accept: application/json')

_cRet	:= HttpPost(;
			_cHost+_cAPI,;
			_cGetPar,;
			_cReqBody,;
			_nTimeOut,;
			_aHeadOut,;
			@_cHeadRet)

	If Empty(_cRet)
	U_JobCInfo("FUNCOES.PRW", "SISLJTOK - Erro ao gerar token Sisloja", 0)
	MsgStop("N„o foi possÌvel gerar autenticaÁ„o de comunicaÁ„o com o Sisloja. Contate o TI da regional")
	Return ""
	EndIf

	If !FWJsonDeserialize(_cRet, @_oObjRet)
	U_JobCInfo("FUNCOES.PRW", "SISLJTOK - Erro ao parsear retorno json", 0)
	MsgStop("N„o foi possÌvel processar a autenticaÁ„o de comunicaÁ„o com o Sisloja. Contate o TI da regional")
	Return ""
	EndIf

	If _oObjRet:TOKEN_TYPE <> "bearer"
	U_JobCInfo("FUNCOES.PRW", "SISLJTOK - Tipo de autenticaÁ„o inv·lido", 0)
	MsgStop("N„o foi possÌvel interpretar a autenticaÁ„o de comunicaÁ„o com o Sisloja. Contate o TI da regional")
	Return ""
	EndIf

_cToken	:= "Bearer " + _oObjRet:ACCESS_TOKEN

FreeObj(_oObjRet)

U_ORTCHPUT(_cCacheCh, _cToken, 14440)

Return _cToken

*-------------------------*
User Function RemEstru(dProg)
*-------------------------*
Private aCorte    := {"COLCH√O","LAMINADO","PE«A", "TORNEADO", "BLOCO" , "CHANFRADO","PROTETORES","PLACA" ,"FLOCOS","CASCAO","ROLETE","PERFILADO","RESIDUO","TRAV TERC","TRAVESSEIRO"}
Private aModelo   := {"000006" ,"000008","000010", "000009"  , "000011", "000012"   ,"000007"    ,"000008","000013","000020","000019","000018"   ,"000021" ,"000028"   ,"000029"}
cQuery:="SELECT DISTINCT SB1.B1_COD, SB1.B1_XMODELO, SB1.B1_XCODBAS "
cQuery+="  FROM "+RetSqlName("SB1")+" SB1, "+RetSqlName("SZQ")+" SZQ, "+RetSqlName("SC6")+" SC6, "
cQuery+="       "+RetSqlName("SC5")+" SC5, "+RetSqlName("SG1")+" SG1  "
cQuery+=" WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery+="   AND SZQ.ZQ_FILIAL = '"+xFilial("SZQ")+"' "
cQuery+="   AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery+="   AND SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery+="   AND SG1.G1_FILIAL(+) = '"+xFilial("SG1")+"' "
cQuery+="   AND SB1.D_E_L_E_T_ = ' ' "
cQuery+="   AND SC6.D_E_L_E_T_ = ' ' "
cQuery+="   AND SC5.D_E_L_E_T_ = ' ' "
cQuery+="   AND SZQ.D_E_L_E_T_ = ' ' "
cQuery+="   AND SG1.D_E_L_E_T_(+) = ' ' "
cQuery+="   AND B1_COD = C6_PRODUTO "
cQuery+="   AND B1_COD = SG1.G1_COD(+) "
cQuery+="   AND G1_COD IS NULL "
cQuery+="   AND C5_NUM = C6_NUM "
cQuery+="   AND C5_XOPER <> '22' "
cQuery+="   AND ZQ_EMBARQ = C5_XEMBARQ "
cQuery+="   AND ZQ_DTPREVE = '"+DTOS(DPROG)+"' "
cQuery+="   AND SB1.B1_COD NOT LIKE '4%' "
cQuery+="   AND SB1.B1_COD NOT LIKE '0%' "
cQuery+=" ORDER BY 3,1 "
	if select("QRY") > 0
   dbselectarea("QRY")
   dbclosearea()
	endif
TCQUERY CQUERY ALIAS "QRY" NEW
dbselectarea("QRY")
dbgotop()
	do while !eof()
	nPos:=ascan(aModelo,QRY->B1_XMODELO)
		if nPos>1
		cCorte:=aCorte[nPos]
		else
		cCorte:="COLCH√O"
		endif
	U_GeraEstru(QRY->B1_XCODBAS,QRY->B1_COD,cCorte)
	dbskip()
	enddo
cQuery:="DELETE "+RetSQLName("SG1")+" WHERE D_E_L_E_T_ = '*' "
tcsqlexec(cQuery)
Return()




/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ORTCOSX5     ∫Autor  Artur Silveira     ∫ Data ≥  16/08/17   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁ„o para consulta padr„o de tabelas SX5                 ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
	static cOrtSX5Ret := ""

User Function ORTCOSX5(cTabX5,lTipoRet,cTipos)

	Local cTitulo	 := ""
	Local MvParDef	 := ""
	Local MvPar      := nil
	Local aReg	 	 := {}
	Local nTam	     := 3
	default lTipoRet := .T.
	default cTipos   := ""

	cOrtSX5Ret := ""

	if !empty(cTabX5)

		cAlias := Alias()

		IF lTipoRet
			MvPar:=&(Alltrim(ReadVar()))
			mvRet:=Alltrim(ReadVar())
		EndIF

		dbSelectArea("SX5")
		SX5->(DbSetOrder(1))

		If SX5->(dbSeek(xFilial("SX5") + "00"+cTabX5))
			cTitulo := Alltrim(Left(X5Descri(), 20))
		Endif

		If SX5->(dbSeek(xFilial("SX5")+cTabX5))
			CursorWait()
			While SX5->(!Eof()) .AND. SX5->X5_Tabela == cTabX5

				if !empty(cTipos) .and. !(PadR(SX5->X5_Chave,nTam) $ cTipos)
					SX5->(dbSkip())
					loop
				endif

				Aadd(aReg,Alltrim(SX5->X5_Chave) + " - " + Alltrim(X5Descri()))
				MvParDef += PadR(Left(SX5->X5_Chave,nTam),nTam)
				SX5->(dbSkip())
			Enddo
			CursorArrow()
		Endif

		IF f_Opcoes(@MvPar,cTitulo,aReg,MvParDef,12,49,.f.,nTam)
			mvpar 		:= StrTran(mvpar,'*','')
			cOrtSX5Ret 	:= mvpar
			&MvRet 		:= mvpar
		EndIF

		dbSelectArea(cAlias)
	endif

Return( IF( lTipoRet , .T. , cOrtSX5Ret ) )

user Function ORTRETX5() //Retorno da Consulta
return cOrtSX5Ret





/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
	±±≥Funá∆o    ORTCSZ0M   ≥ Autor ≥ Artur Silveira        ≥ Data ≥ 19.10.17 ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥Descriá∆o ≥Consulta Especifica para SZ0 Mult-Empresa                   ≥±±
	±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
	±±≥ Uso      ≥ORTOBOM                                                     ≥±±
	±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/

	static cSZ0_MRet := ""
	static aLinSZ0   := {}

user Function ORTCSZ0M(cTab)

	local aArea     := GetArea()
	local oDlg		:= nil
	local oCombo	:= nil
	local oButPesq  := nil
	local oGet		:= nil
	local oButOK	:= nil
	local oButCan 	:= nil
	local nLargBot	:= 30
	local nAltBot	:= 11
	local nInterv   := 3
	local nTempInt  := 0
	Local nd        := 0
	local nVertBot  := 250
	private lCheck  := .f.
	private nPos    := 1
	private cPesq	:= space(100)
	private aCombo	:= {"Codigo","Descricao"}
	private cCombo	:= ""
	private oBrowse := nil
	private oboOK   := LoadBitmap(GetResources(),'LBTICK')
	private oboNO   := LoadBitmap(GetResources(),'LBNO')
	private aCamLab := {''," Codigo"," Descricao"}
	private aCamTam := {15,35,300}
	default cTab	:= ''

	cSZ0_MRet := ""
	if empty(aLinSZ0)
		Processa( {|| CarregaPar(cTab) },"Aguarde...","Carregando Consulta...")
	else
		for nd:=1 to len(aLinSZ0)
			aLinSZ0[nd,1] := 'NO'
		next nd
	endif

	oDlg:=MSDialog():New(0,0,530,420,"Consulta Padr„o",,,,,CLR_BLACK,,,,.T.)

	oCombo   := tComboBox():New(3,3,{|u|if(PCount()>0,cCombo:=u,cCombo)},aCombo,120,10,oDlg,,{|| OrdBrowse() },,,,.T.,,,,,,,,,'cCombo')
	oGet     := TGet():New(17,3,{|u| if(PCount()>0,cPesq:=u,cPesq)},oDlg,120,10,,,,,,,,.T.,,,,,,,,,,'cPesq')
	oButPesq := TButton():New(3,125,'Pesquisar',oDlg,{|| pesqBrow()},40,11,,,,.T.)

// Marca / Desmarca - todos
	oCheck1 := TCheckBox():New(41,04,'',{|| lCheck},oDlg,15,15,,{|| ( lCheck:=!lCheck,MarDesAll(lCheck) )},,,,,,.T.,,,)
	oSay1   := tSay():new(41 ,12,{|| "Marcar/Desmarcar Todos"},oDlg,,,,,,.T.,,,100,10)

	oBrowse := TWBrowse():New( 50,03,210,190,,aCamLab,aCamTam, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	oBrowse:SetArray(aLinSZ0)
	oBrowse:bLine:={||{  Iif(aLinSZ0[oBrowse:nAt,01]=='OK',oboOK,oboNO), aLinSZ0[oBrowse:nAt,02],aLinSZ0[oBrowse:nAt,03] }}
	oBrowse:bLDblClick := {|| Iif(aLinSZ0[oBrowse:nAt,01]=='OK',aLinSZ0[oBrowse:nAt,01]:='NO',aLinSZ0[oBrowse:nAt,01]:='OK') }

	nTempInt += nInterv
	oButOK   := TButton():New(nVertBot,nTempInt,'OK',oDlg,{|| fRetPacote(),oDlg:End() },nLargBot,nAltBot,,,,.T.)
	nTempInt += nInterv + nLargBot
	oButCan  := TButton():New(nVertBot,nTempInt,'Cancelar',oDlg,{|| cSZ0_MRet:="",oDlg:End() },nLargBot,nAltBot,,,,.T.)

	oDlg:activate(,,,.T.)

	RestArea(aArea)
Return .T.


user Function RETSZ0CM() //Retorno da Consulta
return cSZ0_MRet


static function CarregaPar(cTabela)

	Local aAreax   := GetArea()
	local nTotReg  := 0
	local nContReg := 0
	local cTab     := GetNextAlias()
	local lProd    := cEmpant $ ('21|22|51|52|53|54|55|56|57|65|68|71')
	local cQryTab  := "% VIEW_SZ0_MULTEMP" + IIF(!lProd,"@PROD","") + " SZ0 %"
	default cTabela:= '01'

	BeginSql alias cTab
%noparser%

  SELECT DISTINCT SZ0.Z0_CODIGO, SZ0.Z0_DESCRI
  FROM %exp:cQryTab%
  WHERE SZ0.Z0_TIPTAB = %exp:cTabela%
   AND SZ0.Z0_CODIGO <> ' '
   AND SZ0.Z0_DESCRI <> ' '
  ORDER BY SZ0.Z0_CODIGO, SZ0.Z0_DESCRI

	EndSql

	dbselectarea(cTab)
	Count To nTotReg
	ProcRegua(nTotReg)
	(cTab)->(dbgotop())

	While !(cTab)->(EOF())
		nContReg++
		IncProc("Carregando - Status: " + IIF((nContReg/nTotReg)*100 <= 99, StrZero((nContReg/nTotReg)*100,2), STRZERO(100,3)) + "%")
		AADD( aLinSZ0, { "", Alltrim((cTab)->Z0_CODIGO), alltrim((cTab)->Z0_DESCRI) } )
		(cTab)->(dbskip())
	enddo
	RestArea(aAreax)
return


static function OrdBrowse() // ordena Browse--------------------------------------------------------
	if cCombo == aCombo[2]
		aSort( aLinSZ0,,,{ |x,y| ( x[3]+x[2] ) < ( y[3]+y[2] ) } )
		oBrowse:GoBottom()
		oBrowse:GoTop()
	else
		aSort( aLinSZ0,,,{ |x,y| ( x[2]+x[3] ) < ( y[2]+y[3] ) } )
		oBrowse:GoBottom()
		oBrowse:GoTop()
	endif
return


static function pesqBrow() // realiza a busca da pesquisa no array e posiciona o ponteiro -------------------
	if cCombo == aCombo[2]
		nPos:= ASCANX(aLinSZ0,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[3]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
		if nPos == 0
			oBrowse:SetFocus()
			oBrowse:GoPosition(1)
			nPos:= ASCANX(aLinSZ0,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[3]),1,len(AllTrim(cPesq)))) },1)
		endif
		oBrowse:SetFocus()
		if nPos > 0
			oBrowse:GoPosition(nPos)
		endif
	else
		nPos:= ASCANX(aLinSZ0,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[2]),1,len(AllTrim(cPesq)))) },oBrowse:nAt+1)
		if nPos == 0
			oBrowse:SetFocus()
			oBrowse:GoPosition(1)
			nPos:= ASCANX(aLinSZ0,{|x| UPPER(AllTrim(cPesq)) == UPPER(SUBSTR(AllTrim(x[2]),1,len(AllTrim(cPesq)))) },1)
		endif
		oBrowse:SetFocus()
		if nPos > 0
			oBrowse:GoPosition(nPos)
		endif
	endif
return


static function fContMark()
	local ntotmark, nh := 0
	for nh:=1 to len(aLinSZ0)
		if aLinSZ0[nh,1] == 'OK'
			ntotmark ++
		endif
	next nh
return ntotmark


static function fRetPacote()
    Local nk:=0
	cSZ0_MRet := ""
	for nk:=1 to len(aLinSZ0)
		if aLinSZ0[nk,1] <> 'OK'
			loop
		endif
		cSZ0_MRet += aLinSZ0[nk,2]+";"
	next nk
return


static function MarDesAll(pCheck)
	local nTempLin := oBrowse:nAt
	Local nx:=0
	for nx := 1 to len(aLinSZ0)
		aLinSZ0[nx,1]:= iif(pCheck,'OK','NO')
	next nx
	oBrowse:GoPosition(len(aLinSZ0))
	oBrowse:GoPosition(nTempLin)
return

User Function CEP(cCep, nOpc)
	Local url		:= ""
	Local oXML		:= Nil
	Local cError	:= ""
	Local cWarning	:= ""
	Local aRetorno  := {}
	Local lErro		:= .F.
	Default nOpc  	:= 0

	url	:= "viacep.com.br/ws/" + U_Sanitize(cCEP,"") +"/xml/"

	if len(AllTrim(U_Sanitize(cCEP,""))) <> 8
		U_JobCInfo("FUNCOES.PRW", "CEP COM TAMANHO INVALIDO - " + U_Sanitize(cCEP,"") , 2)
		lErro := .T.
	endif

	cRetorno := HTTPGet(url)
	oXML := XmlParser( cRetorno, "_", @cError, @cWarning )

	If (oXml == NIL )
		U_JobCInfo("FUNCOES.PRW", "CEP - Falha ao gerar Objeto XML : "+cError+" / "+cWarning, 0)
		lErro := .T.
	Endif

	If !lErro
		If XmlChildEx(oXML:_XMLCEP, "_ERRO") <> nil
			lErro := .T.
		Endif
	Endif

	If !lErro
		aadd(aRetorno,oXML:_XMLCEP:_CEP:TEXT)           // 1
		aadd(aRetorno,oXML:_XMLCEP:_LOGRADOURO:TEXT)    // 2
		aadd(aRetorno,oXML:_XMLCEP:_COMPLEMENTO:TEXT)   // 3
		aadd(aRetorno,oXML:_XMLCEP:_BAIRRO:TEXT)        // 4
		aadd(aRetorno,oXML:_XMLCEP:_LOCALIDADE:TEXT)    // 5
		aadd(aRetorno,oXML:_XMLCEP:_UF:TEXT)            // 6
		iif(XmlChildEx(oXML:_XMLCEP,"_UNIDADE")<>nil,aadd(aRetorno,oXML:_XMLCEP:_UNIDADE:TEXT),aadd(aRetorno,"")) // 7
		aadd(aRetorno,oXML:_XMLCEP:_IBGE:TEXT)          // 8
		aadd(aRetorno,oXML:_XMLCEP:_GIA:TEXT)           // 9
	Endif

	If lErro
		If nOpc > 0
			Return ""
		Else
			Return aRetorno
		Endif
	Else
		If nOpc > 0
			Return aRetorno[nOpc]
		Endif
	Endif

Return aRetorno
*************************************************
User Function CtrlRot(_cUn, _cTpOper, _cRotina, _dData,_cNomeUsr)
*************************************************
	Local _lRet 	:= .T.
	DEFAULT _cNomeUsr := " "
	conout("[CTRLROT] - PARAMETROS: ["+_cUn+","+_cTpOper+","+_cRotina+","+dtos(_dData)+","+_cNomeUsr+"]")
	If Upper(_cTpOper) = "I"
		cQuery:="INSERT INTO CTRLGER (UN,DTGER,USUARIO,HORA,ROTINA) VALUES('"+cEmpAnt+"','"+DTOS(_dData)+"','"
		cQuery+=_cNomeUsr+"','"+TIME()+"','"+_cRotina+"') "
		IF TCSQLEXEC(cQuery) < 0
			conout("[CTRLROT] - ERRO NO INSERT: ["+ TCSQLError()+"]")
			_lRet 	:= .F.
		EndIF
	ElseIF Upper(_cTpOper) = "E"
		cQuery:="DELETE CTRLGER WHERE UN = '"+_cUn+"' AND DTGER = '"+DTOS(_dData)+"' "
		cQuery+="AND ROTINA = '"+_cRotina+"' "
		IF TCSQLEXEC(cQuery) < 0
			conout("[CTRLROT] - ERRO NO DELETE: ["+ TCSQLError()+"]")
			_lRet 	:= .F.
		EndIF
	EndIF
Return()

	*************************************************
User Function fLibRot()
	*************************************************

	Local   nOpca    	:=  0   // Opcao da confirmacao
	Local   cArqEmp  	:= ''   // Arquivo temporario com as empresas a serem escolhidas
	Local   aStruTrb 	:= {}   // estrutura do temporario
	Local   aBrowse  	:= {}   // array do browse para demonstracao das empresas

	Private lInverte 	:= .F.  // Variaveis para o MsSelect
	Private cMarca   	:= 'Mu' // GetMark() && Variaveis para o MsSelect
	Private oBrwTrb          // objeto do msselect
	Private oDlg
	Private aSrv 	 	:= {}

	Private aHead  		:= {"UN","Bordero","CNPJ","Agencia / Conta","Arquivo","Valor"}
	Private aHeadErro  	:= {"UN","Bordero","Mensagem"}
	Private aItens 		:= {}
	Private _aErro 		:= {}
	Private aUnid 	:= U_ORTPJOBU()

// -------------------------------
//	[ Define campos do TRB ]
// -------------------------------
	aadd(aStruTrb,{'OK'     ,'C',02,0})
	aadd(aStruTrb,{'UNIDADE','C',02,0})
	aadd(aStruTrb,{'ROTINA' ,'C',07,0})
	aadd(aStruTrb,{'USUARIO','C',20,0})
	aadd(aStruTrb,{'DTGER'  ,'D',08,0})
	aadd(aStruTrb,{'HORA'   ,'C',10,0})

// -------------------------------
//	[ Define campos do MsSelect ]
// -------------------------------
	aadd(aBrowse,{'OK'     ,,''         })
	aadd(aBrowse,{'UNIDADE',,'Unidade'  })
	aadd(aBrowse,{'ROTINA' ,,'Rotina'   })
	aadd(aBrowse,{'USUARIO',,'Usu·rio'   })
	aadd(aBrowse,{'DTGER'  ,,'Data'     })
	aadd(aBrowse,{'HORA'   ,,'Hora'     })



	If len(aUnid) > 0
		PREPARE ENVIRONMENT EMPRESA aUnid[1][1] FILIAL aUnid[1][2]
	Else
		Alert("Ambiente n„o suportado. Veja a rotina (U_ORTPJOBU)!")
		Return()
	EndIF

	If Select('TRB') > 0
		TRB->(DbCloseArea())
	Endif

	cArqEmp := CriaTrab(aStruTrb)
	dbUseArea(.T.,__LocalDriver,cArqEmp,'TRB')

	DbSelectArea('TRB')

	cQuery := "SELECT * FROM SIGA.CTRLGER "

	TCQUERY cQuery ALIAS "ROT" NEW
	dbselectarea("ROT")

	If Eof()
		RecLock('TRB',.T.)
		TRB->(DbUnLock())
	EndIf

	dbselectarea("ROT")
	While !Eof()
		RecLock('TRB',.T.)
		TRB->OK := cMarca
		TRB->UNIDADE := ROT->UN
		TRB->ROTINA  := ROT->ROTINA
		TRB->USUARIO := ROT->USUARIO
		TRB->DTGER   := STOD(ROT->DTGER)
		TRB->HORA    := ROT->HORA
		MsUnlock()
		DbSelectArea('ROT')
		DbSkip()
	End

	oDlgTO                      := MSDialog():New( 099,250,383,706,'Selecione a Rotina',,,.F.,,,,,,.T.,,,.T. )
	oDlgTO:bInit                := {||EnchoiceBar(oDlgTO,{|| nOpca:=1,oDlgTO:End()},{|| nOpca:=0,oDlgTO:End()},.F.,/*aBotao*/)}
	oBrwTrb                     := MsSelect():New('TRB','OK','',aBrowse,@lInverte,@cMarca,{030,001,141,230},,,oDlgTO)
	oBrwTrb:oBrowse:lCanAllmark := .T.
	oBrwTrb:oBrowse:bAllMark	  :={||E046MarkAll(cMarca,@oDlgTO)}
	Eval(oBrwTrb:oBrowse:bGoTop)
	oBrwTrb:oBrowse:Refresh()
	oDlgTO:Activate(,,,.T.)

	If nOpca == 1

		If MsgYesNo( "Confirma a liberaÁ„o dos registros selecionadas?", "ATEN«√O" )

			TRB->(DbGotop())
			_ntotal	:= 0
			_nQtd   := 0
			_ntot   := 0
			While TRB->(!Eof())
				If !Empty(TRB->OK) // se usuario marcou o registro
					If U_CtrlRot(TRB->UNIDADE, "E", TRB->ROTINA, TRB->DTGER)
						_ntot ++
					EndIF
				EndIf
				TRB->(DbSkip())
			EndDo
			MsgAlert("Foram excluÌdos "+strzero(_ntot,3)+" registros!",funName())
		EndIF
	Endif

//  Fecha area de trabalho e arquivo tempor·rio criados
	Ferase(cArqEmp+OrdBagExt())
	RESET ENVIRONMENT

Return()
User Function VALCTF(_dDataDe,_dDataAte,_xAutori,cPrograma)
	Local aErro := {}
	Local aHead := {}
	Local lRet  := .F.

	aHead := {"FORNECEDOR","LANCAMENTO","TIPO","VALOR"}


	cQuery := " select  E2_FORNECE, E2_LOJA, E2_NUM,E2_TIPO, E2_VALOR "
	cQuery += " FROM siga."+ RetSqlName('SZ8')+"  sz8, siga."+ RetSqlName('SE2') +" se2 "
	cQuery += " where z8_filial = '" +    XFILIAL('SZ8') + "' "
	cQuery += " and e2_filial = '" +    XFILIAL('SE2') + "' "
	cQuery += " and E2_VENCREA >= '"+DTOS(_dDataDe)+"' "
	cQuery += " and E2_VENCREA <= '"+DTOS(_dDataAte)+"' "
	cQuery += " and Z8_MSBLQL = '1' "
	cQuery += " and e2_xautori = '"+_xAutori+"' "
	cQuery += " and z8_fornece = e2_fornece "
	cQuery += " and se2.d_e_l_e_t_= ' ' "
	cQuery += " and sz8.d_e_l_e_t_= ' ' "
	cQuery += " AND E2_PREFIXO  = '000'                       "
	cQuery += " AND E2_BAIXA    = ' '                         "
	cQuery += " AND E2_SALDO    > 0                           "
	cQuery += " AND E2_FORNECE = Z8_FORNECE "
	cQuery += " AND E2_LOJA = Z8_LOJA "
	cQuery += " AND E2_XBANCO = Z8_BANCO "
	cQuery += " AND E2_XAGENC = Z8_AGENCIA "
	cQuery += " AND E2_XCONTA = Z8_CONTA "
	cQuery += " AND E2_XDIGAGE = Z8_DIGAGEN "
	cQuery += " AND E2_XDIGCON = Z8_DIGCONT "
	cQuery += " AND E2_XTPPG   = Z8_MODALID "
	cQuery += " AND E2_TIPO   not in ( 'DES', 'FT ' )  "   // Marcela Coimbra

	if select('CTF') > 0
		dbselectarea('CTF')
		dbclosearea()
	endif

	TcQuery cQuery Alias 'CTF' New

	dbselectarea('CTF')

	While !EOF()
		AADD(aErro,{CTF->E2_FORNECE+Space(04), CTF->E2_NUM+Space(03), CTF->E2_TIPO+Space(02), Transform(CTF->E2_VALOR,"@E 99,999,999.99")})
		dbselectarea('CTF')
		DbSkip()
	End
	If len(aErro) > 0
		lRet := .T.
		If _dDataDe = _dDataAte
			cData := DTOC(_dDataDe)
		Else
			cData := DTOC(_dDataDe) + " a " +DTOC(_dDataAte)
		EndIF
		If (MsgYesNo("Existem LanÁamentos em contas Bloqueadas. Ajuste o cadastro ou cancele os lanÁamentos. Deseja imprimir o relatÛrio?"))
			U_ORTR538(cPrograma, "LanÁamentos para o vencimento "+cData+" que est„o com contas bloqueadas.", aHead, aErro, .t., .t.)
		EndIf
	EndIF

Return(lRet)
//+---------------------+------------------------------+------------+
//| FunÁ„o   : fAtuCx   | Autor : Marcos Furtado       | 06/12/2016 |
//+---------------------+------------------------------+------------+
//| Descricao: AtualizaÁ„o da autrizaÁ„o dos registros do rateio.   |
//+-----------------------------------------------------------------+
//| Uso      : PAGD                                                 |
//+-----------------------------------------------------------------+

User Function fAtuCx(_cAutori,_dDataDe,_dDataAte)

	CQUERY := "update siga."+RetSqlName("SE2")+" se2 "
	CQUERY += "   set E2_XAUTORI = '"+_cAutori+"' "
	CQUERY += "where e2_filial IN ('CX','AG') "
	CQUERY += "AND E2_PREFIXO = '000' "
	CQUERY += "AND D_E_L_E_T_ = ' ' "
	CQUERY += "and E2_VENCREA >= '"+DTOS(_dDataDe)+"' "
	CQUERY += "and E2_VENCREA <= '"+DTOS(_dDataAte)+"' "
	CQUERY += "AND R_E_C_N_O_ IN "
	CQUERY += "   (SELECT DISTINCT SE2_FL.R_E_C_N_O_ "
	CQUERY += "                       FROM SIGA."+RetSqlName("SE2")+" SE2_02, "
	CQUERY += "                            SIGA."+RetSqlName("SE2")+" SE2_FL "
	CQUERY += "                      WHERE SE2_02.E2_FILIAL = '"+xFilial("SE2")+"' "
	CQUERY += "                        AND SE2_FL.E2_FILIAL  IN ('CX','AG') "
	CQUERY += "                        AND SE2_02.E2_NUM = SE2_FL.E2_NUM "
	CQUERY += "                        AND SE2_02.E2_PREFIXO = SE2_FL.E2_PREFIXO "
	CQUERY += "                        AND SE2_02.E2_XAUTORI = '"+_cAutori+"' "
	CQUERY += "						   AND SE2_02.E2_VENCREA >= '"+DTOS(_dDataDe)+"' "
	CQUERY += "						   AND SE2_02.E2_VENCREA <= '"+DTOS(_dDataAte)+"' "
	CQUERY += "                        AND SE2_02.E2_VENCREA = SE2_FL.E2_VENCREA "
	CQUERY += "						   AND SE2_02.D_E_L_E_T_ = ' ' "
	CQUERY += "						   AND SE2_FL.D_E_L_E_T_ = ' ' "
	CQUERY += "                        AND SE2_02.E2_FORNECE = SE2_FL.E2_FORNECE) "

	TCSQLEXEC(CQUERY)

Return




/*/
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
	±±∫Programa  ≥PutSX1Help∫ Autor ≥ Roberto Mendes    ∫ Data ≥  30/05/2018  ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Descricao ≥ Grava o help da pergunta sx1 correspondente.               ∫±±
	±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
	±±∫Uso       ≥ AP6 IDE                                                    ∫±±
	±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function PutSX1Help(cKey, aHelp, lUpdate)
	Local cFilePor  := "SIGAHLP.HLP"
	Local cFileEng  := "SIGAHLE.HLE"
	Local cFileSpa  := "SIGAHLS.HLS"
	Local nRet,i    := 0
	Local cHelp     := ""
	Default cKey    := ""
	Default aHelp   := {"","",""}
	Default lUpdate := .F.

	for i := 1 to len(aHelp)
		cHelp += aHelp[i]+" "
	Next i

	//Se a Chave ou o Help estiverem em branco
	If Empty(cKey) .Or. Empty(cHelp)
		Return
	EndIf

	if substr(cKey,len(cKey)) <> '.'
		cKey := cKey+"."
	EndIf

	//**************************** PortuguÍs
	nRet := SPF_SEEK(cFilePor, cKey, 1)

	//Se n„o encontrar, ser· inclus„o
	If nRet < 0
		SPF_INSERT(cFilePor, cKey, , , cHelp)

		//Sen„o, ser· atualizaÁ„o
	Else
		If lUpdate
			SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
		EndIf
	EndIf



	//**************************** InglÍs
	nRet := SPF_SEEK(cFileEng, cKey, 1)

	//Se n„o encontrar, ser· inclus„o
	If nRet < 0
		SPF_INSERT(cFileEng, cKey, , , cHelp)

		//Sen„o, ser· atualizaÁ„o
	Else
		If lUpdate
			SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
		EndIf
	EndIf



	//**************************** Espanhol
	nRet := SPF_SEEK(cFileSpa, cKey, 1)

	//Se n„o encontrar, ser· inclus„o
	If nRet < 0
		SPF_INSERT(cFileSpa, cKey, , , cHelp)

		//Sen„o, ser· atualizaÁ„o
	Else
		If lUpdate
			SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
		EndIf
	EndIf
Return

	*************************************
User Function Acertaxls(cArquivo)
	*************************************
	Local cLinha:=""
	Local cFileAux:=substr(cArquivo,1,at(".",cArquivo))
	cFileAux:=cFileAux+"tmp"
	nHandle:=fCreate(cFileAux)
	if nHandle = -1
		MsgBox("Erro ao criar arquivo: "+cFileAux)
	Else
		FT_FUSE(cArquivo)
		nTot:=FT_FLastRec()
		ProcRegua(nTot)
		n:=1
		Do While !FT_FEOF()
			IncProc( "Convertendo XLS linha: "+Alltrim(Str(n))+" de "+Alltrim(Str(nTot))+", aguarde..." )
			n++
			cLinha:=FT_FREADLN()
			if At('ss:Type="DateTime"',cLinha)>0
				cLinha:=substr(cLinha,1,at("Z",cLinha)-1)+substr(cLinha,at("Z",cLinha)+1)
			Endif
			fWrite(nHandle,cLinha+CRLF)
			FT_FSKIP()
		EndDo
		FT_FUSE()
		FCLOSE(nHandle)
	Endif
	FErase(cArquivo)
	FRename(cFileAux,cArquivo)
Return()

**************************************
User Function SPEXEC(cStored,aParam)
**************************************

Local cQry:=""
Local cTrb:=""

	If SubStr(cStored,1,8)=="VALCARGA"
		
		cQry:="SELECT TO_CHAR(CREATED,'YYYYMMDD') CRIACAO"
		cQry+="  FROM USER_OBJECTS"
		cQry+=" WHERE OBJECT_NAME = '"+cStored+"' "
		cTrb := MpSysOpenQuery(cQry)

		If (cTrb)->CRIACAO < '20211001'
			U_COMPSP(cStored)
		EndIf
		
		(cTrb)->(DbCloseArea())
		
		TCSPEXEC(cStored,aParam[1],cFilAnt)
	
	Endif

Return
	
**************************************
User Function COMPSP(cStored)
**************************************

Local cQry:=""
Local cTrb:=""

/*
create table CARGA??0
(
CARGA    CHAR(6) default '      ',  SUBCOD   VARCHAR2(5) default '     ',  DTFECH   CHAR(8) default '        ',  DTACE    CHAR(8) default '        ',  VALEMB   NUMBER default 0.0,
VALLOJA  NUMBER default 0.0,  VALESP   NUMBER default 0.0,  QTDDEV   NUMBER default 0.0,  QTDDEVL  NUMBER default 0.0,  QTDNCA   NUMBER default 0.0,  QTDBON   NUMBER default 0.0,
QTDTRO   NUMBER default 0.0,  QTDREP   NUMBER default 0.0,  VALDEV   NUMBER default 0.0, VALDEVL  NUMBER default 0.0,  VALNCA   NUMBER default 0.0,  VALBON   NUMBER default 0.0,
VALTRO   NUMBER default 0.0,  VALREP   NUMBER default 0.0,  VALNRP   NUMBER default 0.0,  VALDEM   NUMBER default 0.0,  VALGER   NUMBER default 0.0,  ORDEMI   CHAR(4) default '    ',
ORDEMF   CHAR(4) default '    ',  MUNI     CHAR(15) default '               ',  MUNF     CHAR(15) default '               ',  QTDSAC   NUMBER default 0.0,
VALSAC   NUMBER default 0.0,   CHDEP    NUMBER default 0.0,  VALDH    NUMBER default 0.0,  CHCAR    NUMBER default 0.0,  LOJA     NUMBER default 0.0,
CHTCAR   NUMBER default 0.0,   CHTDEP   NUMBER default 0.0,  VALCC    NUMBER default 0.0,  VALDPC   NUMBER default 0.0,  VALCON   NUMBER default 0.0,
VALDP    NUMBER default 0.0,   VALNP    NUMBER default 0.0,  VALPEN   NUMBER default 0.0,  VALTR    NUMBER default 0.0,  DEVOL    NUMBER default 0.0,
BONIF    NUMBER default 0.0,   PZMLAN   NUMBER default 0.0,  VLRLAN   NUMBER default 0.0,  VALJUR   NUMBER default 0.0,  PZMACE   NUMBER default 0.0,
VLRACE   NUMBER default 0.0,  ANTEC    NUMBER default 0.0,  DTPREVE  VARCHAR2(8) default '        ',  VALCD    NUMBER default 0.0,  VALIND   NUMBER default 0.0,
DEVMEM   NUMBER default 0.0,  VALDPCN  NUMBER default 0.0,  VALRCO   NUMBER default 0.0,  QTDREM   NUMBER default 0.0,  VALCESTA NUMBER default 0.0,
VALSER   NUMBER default 0.0,  VALDES   NUMBER default 0.0,  VALFEC   NUMBER default 0.0,  VALDEP   NUMBER default 0.0,  UNORI    VARCHAR2(2) default '  ' not null)
create index CARGA??0_IDX1 on CARGA??0 (CARGA, DTFECH)
create index CARGA??0_IDX2 on CARGA??0 (DTFECH, CARGA)
create index CARGA??0_IDX3 on CARGA??0 (SUBCOD, DTFECH)
*/

	If SubStr(cStored,1,8)=="VALCARGA"
		
		cQry:="SELECT COUNT(*) CAMPO "
		cQry+="  FROM USER_TAB_COLS "
		cQry+=" WHERE TABLE_NAME = 'PEDCG"+cEmpAnt+"0' "
		cQry+="   AND COLUMN_NAME = 'FILIAL'" //Alterar esta essa linha sempre que alterar a procedure
		
		cTrb := MpSysOpenQuery(cQry)
		
		If (cTrb)->CAMPO == 0
			TcSqlExec("ALTER TABLE PEDCG"+cEmpAnt+"0 ADD (FILIAL VARCHAR2(2) DEFAULT '  ' NOT NULL) " )
			TcSqlExec("ALTER TABLE CARGA"+cEmpAnt+"0 ADD (FILIAL VARCHAR2(2) DEFAULT '  ' NOT NULL) " )
		EndIf
		
		(cTrb)->(DbCloseArea())
		
		cQry:="DROP PROCEDURE "+cStored
		
		TCSqlExec(cQry)
		
		cQry:="CREATE OR REPLACE PROCEDURE "+cStored+"(pCARGA VARCHAR, pFilial VARCHAR) AS " + ENTER
		cQry+="BEGIN " + ENTER
		cQry+="  DELETE PEDCG"+cEmpAnt+"0 WHERE CARGA = pCARGA; " + ENTER
		cQry+="  DELETE CARGA"+cEmpAnt+"0 WHERE CARGA = pCARGA; " + ENTER
		cQry+="  INSERT INTO PEDCG"+cEmpAnt+"0                  " + ENTER
		cQry+="      (FILIAL, CARGA, DTCARGA, PZMACE, TRANSP, PED, OPER, VALENT, TPENTR, DTFECH, ACEITE, DTACE, TPSEGM, ORDEM, MUN, NOTA, SERIE, CLIENTE, LOJA, " + ENTER
		cQry+="       UNORI,  QTDVEN,  CUSTO, VALFAT, VALVEN) " + ENTER
		cQry+="      (SELECT pFilial, CARGA, DTCARGA, SUM(PZMACE * VALFAT) PZMACE, TRANSP, PED, OPER, VALENT, TPENTR, DTFECH, ACEITE, DTACE, TPSEGM, ORDEM, " + ENTER
		cQry+="              NVL(MUN, '               ') MUN, NOTA, SERIE, CLIENTE, LOJA, UNORI, SUM(QTDVEN) QTDVEN, SUM(CUSTO) CUSTO, SUM(VALFAT) VALFAT, " + ENTER
		cQry+="              SUM(VALVEN) VALVEN " + ENTER
		cQry+="         FROM (SELECT SZQ.ZQ_EMBARQ CARGA, SZQ.ZQ_DTEMBAR DTCARGA, SZQ.ZQ_TRANSP TRANSP, SC5.C5_NUM PED, SC5.C5_XOPER OPER, " + ENTER
		cQry+="                      DECODE(C5_XOPER,'14','  ',DECODE(C5_XPEDCLX, '      ', '  ', C5_XUNORI)) UNORI,DECODE(SC5.C5_XPRZMED, '   ', " + ENTER
		cQry+="                             0, TO_NUMBER(SC5.C5_XPRZMED)) PZMACE, " + ENTER
		cQry+="                      SC5.C5_XVALENT VALENT, SC5.C5_XTPENTR TPENTR, SC5.C5_XDTFECH DTFECH, SC5.C5_XACEITE ACEITE, SC5.C5_XACERTO DTACE, " + ENTER
		cQry+="                      SC5.C5_XTPSEGM TPSEGM, SC5.C5_XORDEMB ORDEM, DECODE(SC5.C5_TIPO,'B',SA2.A2_MUN,'D',SA2.A2_MUN, SA1.A1_MUN) MUN, " + ENTER
		cQry+="                      NVL(SD2.D2_DOC, 'XXXXXXXXX') NOTA, NVL(SD2.D2_SERIE, 'XXX') SERIE, NVL(RPAD(SD2.D2_ITEM, 4, ' '), 'XXXX') ITEM, " + ENTER
		cQry+="                      SC5.C5_CLIENTE CLIENTE, SC5.C5_LOJACLI LOJA, SC6.C6_PRODUTO COD, " + ENTER
		cQry+="                      DECODE(C5_TIPO,'P',1,'C',1,'I',1, NVL(D2_QUANT, C6_QTDVEN)) QTDVEN, " + ENTER
		cQry+="                      DECODE(C5_TIPO,'P',1,'C',1,'I',1, NVL(D2_QUANT, C6_QTDVEN)) * C6_XCUSTO CUSTO, " + ENTER
		cQry+="                      NVL(D2_TOTAL + D2_VALIPI + D2_ICMSRET, 0) VALFAT, " + ENTER
		cQry+="                      (DECODE(C5_TIPO,'P',1,'C',1,'I',1,NVL(D2_QUANT, C6_QTDVEN)) * C6_XPRUNIT)+NVL(D2_VALIPI, 0) + NVL(D2_ICMSRET, 0) VALVEN, " + ENTER
		cQry+="                      D2_QTDEDEV QTDDEV,((D2_QTDEDEV * C6_XPRUNIT) + D2_ICMSRET +DECODE(C5_XDESPRO, '3', D2_VALIPI, 0)) TOTDEV " + ENTER
		cQry+="                 FROM "+RetSqlName("SZQ")+" SZQ, "+RetSqlName("SC5")+" SC5, "+RetSqlName("SC6")+" SC6, "+RetSqlName("SD2")+" SD2, " + ENTER
		cQry+="                      "+RetSqlName("SA1")+" SA1, "+RetSqlName("SA2")+" SA2 " + ENTER
		cQry+="                WHERE SZQ.D_E_L_E_T_ = ' ' " + ENTER
		cQry+="                  AND SC5.D_E_L_E_T_ = ' ' " + ENTER
		cQry+="                  AND SC6.D_E_L_E_T_ = ' ' " + ENTER
		cQry+="                  AND SA1.D_E_L_E_T_(+) = ' ' " + ENTER
		cQry+="                  AND SA2.D_E_L_E_T_(+) = ' ' " + ENTER
		cQry+="                  AND SD2.D_E_L_E_T_(+) = ' ' " + ENTER
		cQry+="                  AND SZQ.ZQ_FILIAL = "+IF(Empty(xFilial("SZQ")),"'   '","pFilial") + ENTER
		cQry+="                  AND SC5.C5_FILIAL = "+IF(Empty(xFilial("SC5")),"'   '","pFilial") + ENTER
		cQry+="                  AND SC6.C6_FILIAL = "+IF(Empty(xFilial("SC6")),"'   '","pFilial") + ENTER
		cQry+="                  AND SA1.A1_FILIAL(+) = "+IF(Empty(xFilial("SA1")),"'   '","pFilial") + ENTER
		cQry+="                  AND SA2.A2_FILIAL(+) = "+IF(Empty(xFilial("SA2")),"'   '","pFilial") + ENTER
		cQry+="                  AND SD2.D2_FILIAL(+) = "+IF(Empty(xFilial("SD2")),"'   '","pFilial") + ENTER
		cQry+="                  AND C6_BLQ <> 'R' " + ENTER
		cQry+="                  AND ZQ_EMBARQ = pCARGA " + ENTER
		cQry+="                  AND ZQ_EMBARQ = SC5.C5_XEMBARQ " + ENTER
		cQry+="                  AND C5_NUM = C6_NUM            " + ENTER
		cQry+="                  AND C6_NUM = D2_PEDIDO(+)      " + ENTER
		cQry+="                  AND C6_ITEM = D2_ITEMPV(+)     " + ENTER
		cQry+="                  AND C5_CLIENTE = A1_COD(+)     " + ENTER
		cQry+="                  AND C5_LOJACLI = A1_LOJA(+)    " + ENTER
		cQry+="                  AND C5_CLIENTE = A2_COD(+)     " + ENTER
		cQry+="                  AND C5_LOJACLI = A2_LOJA(+)    " + ENTER
		cQry+="                  AND SC5.C5_XOPER <> '99')      " + ENTER
		cQry+="       GROUP BY CARGA, DTCARGA, CLIENTE, LOJA, TRANSP, PED, OPER, UNORI, VALENT, TPENTR, DTFECH, DTACE, ACEITE, TPSEGM, ORDEM, MUN, NOTA, SERIE); " + ENTER
		cQry+="  UPDATE PEDCG"+cEmpAnt+"0 SET (VALDEV, QTDDEV, VALNCA, QTDNCA) = " + ENTER
		cQry+="                      (SELECT SUM(DECODE(TES, NULL, D1_TOTAL + D1_VALIPI + D1_ICMSRET - decode(d1_desczfr,0,d1_valdesc,d1_desczfr) , 0)), " + ENTER   //Alterado era: DECODE(TES, NULL, D1_TOTAL + D1_VALIPI + D1_ICMSRET, 0) marcos gomes - 30/7/2020
		cQry+="                              SUM(DECODE(TES, NULL, D1_QUANT, 0)), " + ENTER   //Incluido: marcos gomes - 11/8/2020
		cQry+="                              SUM(DECODE(TES, NULL, 0, D1_TOTAL + D1_VALIPI + D1_ICMSRET - decode(d1_desczfr,0,d1_valdesc,d1_desczfr) )), " + ENTER   //Alterado era: DECODE(TES, NULL, 0, D1_TOTAL + D1_VALIPI + D1_ICMSRET) marcos gomes - 30/7/2020
		cQry+="                              SUM(DECODE(TES, NULL, 0, D1_QUANT))  " + ENTER   //Incluido: marcos gomes - 11/8/2020
		cQry+="                         FROM "+RetSQLName("SD1")+" SD1, TESNCA"+cEmpAnt+"0, "+RetSQLName("SD2")+" SD2, "+RetSQLName("SC5")+" SC5 " + ENTER
		cQry+="                        WHERE D1_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                          AND D2_FILIAL = "+IF(Empty(xFilial("SD2")),"'   '","pFilial") + ENTER
		cQry+="                          AND C5_FILIAL = "+IF(Empty(xFilial("SC5")),"'   '","pFilial") + ENTER
		cQry+="                          AND D1_NFORI = NOTA          " + ENTER
		cQry+="                          AND D1_SERIORI = SERIE       " + ENTER
		cQry+="                          AND D1_ITEMORI = D2_ITEM     " + ENTER
		cQry+="                          AND D2_DOC = NOTA            " + ENTER
		cQry+="                          AND D2_SERIE = SERIE         " + ENTER
		cQry+="                          AND SD1.D_E_L_E_T_ = ' '     " + ENTER
		cQry+="                          AND SD2.D_E_L_E_T_ = ' '     " + ENTER
		cQry+="                          AND SC5.D_E_L_E_T_ = ' '     " + ENTER
		cQry+="                          AND C5_NUM = D2_PEDIDO       " + ENTER
		cQry+="                          AND D1_DTDIGIT <= C5_XACERTO " + ENTER
		cQry+="                          AND D1_TES = TES(+))         " + ENTER
		cQry+="   WHERE CARGA = pCARGA                                " + ENTER
		cQry+="     AND VALENT = 0                                    " + ENTER
		cQry+="     AND FILIAL = pFilial                              " + ENTER
		cQry+="     AND (OPER = '14' OR UNORI <> '07')                " + ENTER
		cQry+="     AND EXISTS  (SELECT 'X'                           " + ENTER
		cQry+="                    FROM "+RetSQLName("SD1")+" SD1, "+RetSQLName("SD2")+" SD2, "+RetSQLName("SC5")+" SC5 " + ENTER
		cQry+="                   WHERE D1_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                     AND D2_FILIAL = "+IF(Empty(xFilial("SD2")),"'   '","pFilial") + ENTER
		cQry+="                     AND C5_FILIAL = "+IF(Empty(xFilial("SC5")),"'   '","pFilial") + ENTER
		cQry+="                     AND D1_NFORI = NOTA                                            " + ENTER
		cQry+="                     AND D1_SERIORI = SERIE                                         " + ENTER
		cQry+="                     AND D1_ITEMORI = D2_ITEM                                       " + ENTER
		cQry+="                     AND D2_DOC = NOTA                                              " + ENTER
		cQry+="                     AND D2_SERIE = SERIE                                           " + ENTER
		cQry+="                     AND D2_PEDIDO = C5_NUM                                         " + ENTER
		cQry+="                     AND D1_DTDIGIT <= C5_XACERTO                                   " + ENTER
		cQry+="                     AND (C5_XUNORI <> '07' OR C5_XPEDCLX = ' ' OR D2_EST = 'SE')   " + ENTER
		cQry+="                     AND SD1.D_E_L_E_T_ = ' '                                       " + ENTER
		cQry+="                     AND SD2.D_E_L_E_T_ = ' '                                       " + ENTER
		cQry+="                     AND SC5.D_E_L_E_T_ = ' ');                                     " + ENTER
		cQry+="  UPDATE PEDCG"+cEmpAnt+"0 SET (VALDEV, QTDDEV, VALNCA, QTDNCA) = " + ENTER
		cQry+="     		(SELECT SUM(DECODE(TES,NULL,(C6_XPRUNIT * D1_QUANT)+D1_ICMSRET,0))-MAX(DECODE(TES,NULL,C5_XVALENT,0)), " + ENTER      //Alterado era: DECODE(TES,NULL,C5_XVALENT) marcos gomes - 30/7/2020
		cQry+="                     SUM(DECODE(TES,NULL,D1_QUANT, 0)), " + ENTER   //Incluido: marcos gomes - 11/8/2020
		cQry+="                     SUM(DECODE(TES,NULL,0,(C6_XPRUNIT * D1_QUANT)+D1_ICMSRET))-MAX(DECODE(TES,NULL,0,C5_XVALENT)), " + ENTER      //Alterado era: DECODE(TES,NULL,C5_XVALENT) marcos gomes - 30/7/2020
		cQry+="                     SUM(DECODE(TES,NULL,0, D1_QUANT))  " + ENTER   //Incluido: marcos gomes - 11/8/2020
		cQry+="                FROM "+RetSQLName("SD1")+" SD1, TESNCA"+cEmpAnt+"0, "+RetSQLName("SD2")+" SD2, "+RetSQLName("SC5")+" SC5, "+RetSQLName("SC6")+" SC6 " + ENTER
		cQry+="               WHERE D1_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                 AND D2_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                 AND C6_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                 AND C5_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                 AND D1_NFORI = NOTA          " + ENTER
		cQry+="                 AND D1_SERIORI = SERIE       " + ENTER
		cQry+="                 AND D1_ITEMORI = D2_ITEM     " + ENTER
		cQry+="                 AND D2_DOC = NOTA            " + ENTER
		cQry+="                 AND D2_SERIE = SERIE         " + ENTER
		cQry+="                 AND D2_PEDIDO = C6_NUM       " + ENTER
		cQry+="                 AND D2_ITEMPV = C6_ITEM      " + ENTER
		cQry+="                 AND C5_NUM = C6_NUM          " + ENTER
		cQry+="                 AND D1_DTDIGIT <= C5_XACERTO " + ENTER
		cQry+="                 AND SD1.D_E_L_E_T_ = ' '     " + ENTER
		cQry+="                 AND SD2.D_E_L_E_T_ = ' '     " + ENTER
		cQry+="                 AND SC5.D_E_L_E_T_ = ' '     " + ENTER
		cQry+="                 AND SC6.D_E_L_E_T_ = ' '     " + ENTER
		cQry+="                 AND D1_TES = TES(+))         " + ENTER
		cQry+="   WHERE CARGA = pCARGA                       " + ENTER
		cQry+="     AND VALDEV = 0                           " + ENTER
		cQry+="     AND FILIAL = pFilial                     " + ENTER
		cQry+="     AND VALNCA = 0                           " + ENTER
		cQry+="     AND EXISTS (SELECT 'X'                   " + ENTER
		cQry+="                   FROM "+RetSQLName("SD1")+" SD1, "+RetSQLName("SD2")+" SD2, "+RetSQLName("SC5")+" SC5 " + ENTER
		cQry+="                  WHERE D1_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                    AND D2_FILIAL = "+IF(Empty(xFilial("SD2")),"'   '","pFilial") + ENTER
		cQry+="                    AND C5_FILIAL = "+IF(Empty(xFilial("SC5")),"'   '","pFilial") + ENTER
		cQry+="                    AND D1_NFORI = NOTA           " + ENTER
		cQry+="                    AND D1_SERIORI = SERIE        " + ENTER
		cQry+="                    AND D1_ITEMORI = D2_ITEM      " + ENTER
		cQry+="                    AND D2_DOC = NOTA             " + ENTER
		cQry+="                    AND D2_SERIE = SERIE          " + ENTER
		cQry+="                    AND D2_PEDIDO = C5_NUM        " + ENTER
		cQry+="                    AND D1_DTDIGIT <= C5_XACERTO  " + ENTER
		cQry+="                    AND C5_XVALENT > 0            " + ENTER
		cQry+="                    AND SD1.D_E_L_E_T_ = ' '      " + ENTER
		cQry+="                    AND SD2.D_E_L_E_T_ = ' '      " + ENTER
		cQry+="                    AND SC5.D_E_L_E_T_ = ' ');    " + ENTER
		cQry+="  UPDATE PEDCG"+cEmpAnt+"0 SET (VALDEV, QTDDEV, VALNCA, QTDNCA) = " + ENTER
		cQry+="            (SELECT SUM(DECODE(TES,NULL,(C6_XPRUNIT * D1_QUANT) + D1_ICMSRET,0)), " + ENTER
		cQry+="                    SUM(DECODE(TES,NULL,D1_QUANT,0)), " + ENTER   //Incluido: marcos gomes - 11/8/2020
		cQry+="                    SUM(DECODE(TES,NULL,0,(C6_XPRUNIT * D1_QUANT) + D1_ICMSRET)), " + ENTER
		cQry+="                    SUM(DECODE(TES,NULL,0, D1_QUANT)) " + ENTER   //Incluido: marcos gomes - 11/8/2020
		cQry+="               FROM "+RetSQLName("SD1")+" SD1, TESNCA"+cEmpAnt+"0, "+RetSQLName("SD2")+" SD2, "+RetSQLName("SC5")+" SC5, "+RetSQLName("SC6")+" SC6 " + ENTER
		cQry+="              WHERE D1_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                AND D2_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                AND C6_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                AND C5_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="                AND D1_NFORI = NOTA             " + ENTER
		cQry+="                AND D1_SERIORI = SERIE          " + ENTER
		cQry+="                AND D1_ITEMORI = D2_ITEM        " + ENTER
		cQry+="                AND D2_DOC = NOTA               " + ENTER
		cQry+="                AND D2_SERIE = SERIE            " + ENTER
		cQry+="                AND D2_PEDIDO = C6_NUM          " + ENTER
		cQry+="                AND D2_ITEMPV = C6_ITEM         " + ENTER
		cQry+="                AND C6_NUM = C5_NUM             " + ENTER
		cQry+="                AND D1_DTDIGIT <= C5_XACERTO    " + ENTER
		cQry+="                AND SC6.D_E_L_E_T_ = ' '        " + ENTER
		cQry+="                AND SC5.D_E_L_E_T_ = ' '        " + ENTER
		cQry+="                AND SD1.D_E_L_E_T_ = ' '        " + ENTER
		cQry+="                AND SD2.D_E_L_E_T_ = ' '        " + ENTER
		cQry+="                AND D1_TES = TES(+))            " + ENTER
		cQry+="   WHERE CARGA = pCARGA                         " + ENTER
		cQry+="     AND FILIAL = pFilial                       " + ENTER
		cQry+="     AND VALDEV = 0                             " + ENTER
		cQry+="     AND VALNCA = 0                             " + ENTER
		cQry+="     AND EXISTS                                 " + ENTER
		cQry+="           (SELECT 'X'                          " + ENTER
		cQry+="              FROM "+RetSQLName("SD1")+" SD1, "+RetSQLName("SD2")+" SD2, "+RetSQLName("SC5")+" SC5 " + ENTER
		cQry+="             WHERE D1_FILIAL = "+IF(Empty(xFilial("SD1")),"'   '","pFilial") + ENTER
		cQry+="               AND D2_FILIAL = "+IF(Empty(xFilial("SD2")),"'   '","pFilial") + ENTER
		cQry+="               AND C5_FILIAL = "+IF(Empty(xFilial("SC5")),"'   '","pFilial") + ENTER
		cQry+="               AND D1_NFORI = NOTA               " + ENTER
		cQry+="               AND D1_SERIORI = SERIE            " + ENTER
		cQry+="               AND D1_ITEMORI = D2_ITEM          " + ENTER
		cQry+="               AND D2_DOC = NOTA                 " + ENTER
		cQry+="               AND D2_SERIE = SERIE              " + ENTER
		cQry+="               AND D2_PEDIDO = C5_NUM            " + ENTER
		cQry+="               AND D1_DTDIGIT <= C5_XACERTO      " + ENTER
		cQry+="               AND SD1.D_E_L_E_T_ = ' '          " + ENTER
		cQry+="               AND SD2.D_E_L_E_T_ = ' '          " + ENTER
		cQry+="               AND SC5.D_E_L_E_T_ = ' ');        " + ENTER
		cQry+="  COMMIT;                                        " + ENTER
		cQry+="    UPDATE PEDCG"+cEmpAnt+"0                     " + ENTER
		cQry+="       SET (CHDEP, CHCAR, VALDH, VALSEM, CHTDEP, CHTCAR, VALCC, VALDPC, VALDP, VALNP, VALPEN, BONIF, PZMLAN, VLRLAN, VALJUR, VALCD, DEVMEM, VALDEP) = " + ENTER
		cQry+="   (SELECT NVL(SUM(CASE WHEN ZB_TPOPER = 'CH ' AND TO_DATE(ZB_DTVENC,'YYYYMMDD') - TO_DATE(ZB_DTMOV, 'YYYYMMDD') <= 1 THEN ZB_VALOR ELSE 0 END), 0) CHDEP, " + ENTER
		cQry+="           NVL(SUM(CASE WHEN ZB_TPOPER = 'CH ' AND TO_DATE(ZB_DTVENC,'YYYYMMDD') - TO_DATE(ZB_DTMOV, 'YYYYMMDD') > 1 THEN ZB_VALOR ELSE 0 END), 0) CHCAR, " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'DH ', ZB_VALOR, 0)), 0) VALDH,  " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'   ', ZB_VALOR, 0)), 0) VALSEM,  " + ENTER
		cQry+="           NVL(SUM(CASE WHEN ZB_TPOPER = 'CHT' AND TO_DATE(ZB_DTVENC,'YYYYMMDD') - TO_DATE(ZB_DTMOV,'YYYYMMDD') <= 1 THEN ZB_VALOR ELSE 0 END), 0) CHTDEP, " + ENTER
		cQry+="           NVL(SUM(CASE WHEN ZB_TPOPER = 'CHT' AND TO_DATE(ZB_DTVENC,'YYYYMMDD') - TO_DATE(ZB_DTMOV,'YYYYMMDD') > 1 THEN ZB_VALOR ELSE 0 END), 0) CHTCAR, " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'CC ', ZB_VALOR, 0)), 0) VALCC, " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'DPC', ZB_VALOR, 0)), 0) VALDPC, " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'DP ', ZB_VALOR, 0)), 0) VALDP, " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'NP ', ZB_VALOR, 0)), 0) VALNP, " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'PEN', ZB_VALOR, 0)), 0) VALPEN, " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'BON', ZB_VALOR, 0)), 0) BONIF, " + ENTER
		cQry+="           NVL(SUM(ROUND((DECODE(ZB_DTVENC, '        ', PZMACE/VALFAT, " + ENTER
		cQry+="                          DECODE(ZB_TPOPER,'   ',PZMACE /VALFAT,'PEN',PZMACE /VALFAT, " + ENTER
		cQry+="                                 TO_DATE(ZB_DTVENC,'YYYYMMDD') - TO_DATE(ACEITE, 'YYYYMMDD'))) * (ZB_VALOR+VALDEV)),2)),0) PZMLAN, " + ENTER
		cQry+="           NVL(SUM(ZB_VALOR),0) VLRLAN,  " + ENTER
		cQry+="           NVL(SUM(ZB_VALJUR),0) VALJUR, " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'CD ', ZB_VALOR, 0)),0) VALCD, " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'MEM', ZB_VALOR, 0)),0) DEVMEM, " + ENTER
		cQry+="           NVL(SUM(DECODE(ZB_TPOPER,'DEP', ZB_VALOR, 0)),0) VALDEP " + ENTER
		cQry+="      FROM "+RetSqlName("SZB")+" SZB " + ENTER
		cQry+="     WHERE D_E_L_E_T_ = ' ' " + ENTER
		cQry+="       AND ZB_FILIAL = "+IF(Empty(xFilial("SZB")),"'   '","pFilial") + ENTER
		cQry+="       AND ZB_DOCREC = CARGA " + ENTER
		cQry+="       AND ZB_NUMPED = PED)  " + ENTER
		cQry+="  WHERE CARGA = pCARGA     " + ENTER
		cQry+="    AND FILIAL = pFILIAL;  " + ENTER
		cQry+=" UPDATE PEDCG"+cEmpAnt+"0  SET ANTEC = nvl((SELECT SUM(decode(zk_operac,'SB',-1,1)*zk_valor) " + ENTER
		cQry+="                                              FROM "+RetSqlName("SZK")+" SZK " + ENTER
		cQry+="                                             WHERE ZK_FILIAL = "+IF(Empty(xFilial("SZK")),"'   '","pFilial") + ENTER
		cQry+="                                               AND D_E_L_E_T_ = ' ' " + ENTER
		cQry+="                                               AND ZK_PEDIDO = PED " + ENTER
		cQry+="                                               AND ZK_OPERAC in ('AP', 'ST', 'PI','SB')),0) " + ENTER
		cQry+="                                             WHERE FILIAL = pFILIAL " + ENTER
		cQry+="                                               AND  CARGA = pCARGA; " + ENTER
		cQry+=" UPDATE PEDCG"+cEmpAnt+"0  SET ANTEC = (CASE WHEN ANTEC <= (VALDEV + VALNCA) THEN 0 ELSE(ANTEC - VALDEV - VALNCA) END) " + ENTER
		cQry+="  WHERE CARGA = pCARGA    " + ENTER
		cQry+="    AND FILIAL = pFILIAL  " + ENTER
		cQry+="    AND ANTEC > 0;        " + ENTER
		cQry+=" COMMIT; " + ENTER
		cQry+=" INSERT INTO CARGA"+cEmpAnt+"0 " + ENTER
		cQry+=" (FILIAL, CARGA, DTFECH, DTACE, SUBCOD, UNORI, VALEMB, VALLOJA, VALESP, QTDDEV, QTDDEVL, QTDNCA, QTDBON, QTDSAC, QTDTRO, QTDREP, VALDEV, VALDEVL, " + ENTER
		cQry+="  VALNCA, VALBON, VALCON,  VALIND, VALRCO, VALSER, VALCESTA, VALDES, VALSAC, VALTRO, VALREP, VALNRP, VALDEM, VALFEC, VALGER, ORDEMI, ORDEMF, " + ENTER
		cQry+="  CHDEP, CHCAR, VALDH, CHTDEP, CHTCAR, VALCC, VALCD,  DEVMEM, VALDPC, VALDP, VALNP, VALPEN, VALDEP, BONIF, VLRLAN, VALJUR, ANTEC, DEVOL, VALDPCN, " + ENTER
		cQry+="  LOJA, VALTR, PZMLAN, PZMACE, QTDREM) " + ENTER
		cQry+=" (SELECT pFILIAL, CARGA, MAX(DTFECH) DTFECH, MAX(DTACE) DTACE, SUBSTR(CARGA,2,5) SUBCOD, UNORI, " + ENTER
		cQry+="         SUM(CASE WHEN OPER IN ('01', '13', '14') AND TPSEGM NOT IN ('3','4','L') THEN DECODE(DTCARGA, '        ', CUSTO, VALFAT) ELSE 0 END) VALEMB, " + ENTER
		cQry+="         SUM(DECODE(TPSEGM,'3',DECODE(DTCARGA,'        ',CUSTO,VALFAT),DECODE(TPSEGM,'L',DECODE(DTCARGA,'        ',CUSTO,VALFAT),0))) VALLOJA, " + ENTER
		cQry+="         SUM(DECODE(TPSEGM,'4',DECODE(DTCARGA, '        ', CUSTO, VALFAT),0)) VALESP,  " + ENTER
		cQry+="         SUM(DECODE(TPSEGM, '3', 0, '4', 0, 'L', 0, QTDDEV)) QTDDEV, " + ENTER
		cQry+="         SUM(DECODE(TPSEGM, '3', QTDDEV, '4', QTDDEV, 'L', QTDDEV, 0)) QTDDEVL, " + ENTER
		cQry+="         SUM(QTDNCA) QTDNCA, " + ENTER
		cQry+="         SUM(DECODE(OPER, '05', QTDVEN - QTDDEV - QTDNCA, 0)) QTDBON, " + ENTER
		cQry+="         SUM(DECODE(OPER, '17', QTDVEN - QTDDEV - QTDNCA, 0)) QTDSAC, " + ENTER
		cQry+="         SUM(DECODE(OPER, '02', QTDVEN - QTDDEV - QTDNCA,'03', QTDVEN - QTDDEV - QTDNCA, 0)) QTDTRO, " + ENTER
		cQry+="         SUM(DECODE(OPER, '08', QTDVEN - QTDDEV - QTDNCA, 0)) QTDREP, " + ENTER
		cQry+="         SUM(DECODE(TPSEGM, '3', 0, '4', 0, 'L', 0, VALDEV)) VALDEV, " + ENTER
		cQry+="         SUM(DECODE(TPSEGM, '3', VALDEV, '4', VALDEV, 'L', VALDEV, 0)) VALDEVL, " + ENTER
		cQry+="         SUM(VALNCA) VALNCA, " + ENTER
		cQry+="         SUM(DECODE(OPER, '05', VALFAT - VALDEV - VALNCA, 0)) VALBON, " + ENTER
		cQry+="         SUM(DECODE(OPER, '09', VALSEM, 0)) VALCON, " + ENTER
		cQry+="         SUM(DECODE(OPER, '25', VALFAT - VALDEV - VALNCA, 0)) VALIND, " + ENTER
		cQry+="         SUM(DECODE(OPER, '23', VALFAT - VALDEV - VALNCA, 0)) VALRCO, " + ENTER
		cQry+="         SUM(DECODE(OPER, '18', VALFAT - VALDEV - VALNCA, 0)) VALSER, " + ENTER
		cQry+="         SUM(DECODE(OPER, '28', VALFAT - VALDEV - VALNCA, 0)) VALCESTA, " + ENTER
		cQry+="         SUM(DECODE(OPER, '24', VALFAT - VALDEV - VALNCA, 0)) VALDES, " + ENTER
		cQry+="         SUM(DECODE(OPER, '17', DECODE(VALENT,0,VALFAT - VALDEV - VALNCA,DECODE(VALNCA + VALDEV,0,VALVEN - VALENT,0)),0)) VALSAC, " + ENTER
		cQry+="         SUM(DECODE(OPER, '03', DECODE(VALENT,0,VALFAT - VALDEV - VALNCA,DECODE(VALNCA + VALDEV,0,VALVEN - VALENT,0)),            " + ENTER
		cQry+="                          '02', DECODE(VALENT,0,VALFAT - VALDEV - VALNCA,DECODE(VALNCA + VALDEV,0,VALVEN - VALENT,0)),0)) VALTRO, " + ENTER
		cQry+="         SUM(DECODE(OPER, '08', VALFAT - VALDEV - VALNCA, 0)) VALREP, " + ENTER
		cQry+="         SUM(DECODE(OPER, '04', VALFAT - VALDEV - VALNCA, 0)) VALNRP, " + ENTER
		cQry+="         SUM(DECODE(OPER, '07', VALFAT - VALDEV - VALNCA, 0)) VALDEM, " + ENTER
		cQry+="         SUM(DECODE(OPER, '29', VALFAT - VALDEV - VALNCA, 0)) VALFEC, " + ENTER
		cQry+="         SUM(DECODE(VALENT,0,VALFAT - VALDEV - VALNCA,DECODE(VALNCA + VALDEV, 0, VALVEN - VALENT, 0))) VALGER, " + ENTER
		cQry+="         MIN(ORDEM) ORDEMI, MAX(ORDEM) ORDEMF, SUM(CHDEP) CHDEP, SUM(CHCAR) CHCAR, SUM(VALDH) VALDH, SUM(CHTDEP) CHTDEP, " + ENTER
		cQry+="         SUM(CHTCAR) CHTCAR, SUM(VALCC) VALCC, SUM(VALCD) VALCD, SUM(DEVMEM) DEVMEM, SUM(VALDPC) VALDPC, SUM(VALDP) VALDP, " + ENTER
		cQry+="         SUM(VALNP) VALNP, SUM(VALPEN) VALPEN, SUM(VALDEP) VALDEP, SUM(BONIF) BONIF, SUM(VLRLAN) VLRLAN, SUM(VALJUR) VALJUR, " + ENTER
		cQry+="         SUM(ANTEC) ANTEC, SUM(DECODE(OPER, '06', VALSEM, 0)) DEVOL, SUM(DECODE(OPER, '07', VALSEM, 0)) VALDPCN, " + ENTER
		cQry+="         SUM(CASE WHEN TPSEGM IN ('3','4','L') AND OPER NOT IN ('02', '03', '05', '06', '07', '08', '17', '24', '25') THEN " + ENTER
		cQry+="                       VALSEM ELSE 0 END) LOJA, " + ENTER
		cQry+="         SUM(DECODE(OPER,'02',(CASE WHEN TPSEGM IN ('3','4','L') OR VALENT = 0 THEN VALSEM ELSE 0 END), " + ENTER
		cQry+="                         '03',(CASE WHEN TPSEGM IN ('3','4','L') OR VALENT = 0 THEN VALSEM ELSE 0 END), " + ENTER
		cQry+="                         '17',(CASE WHEN TPSEGM IN ('3','4','L') OR VALENT = 0 THEN VALSEM ELSE 0 END), 0)) VALTR, " + ENTER
		cQry+="         SUM(PZMLAN) / DECODE(SUM(VALFAT), 0, 1, SUM(VALFAT)) PZMLAN, " + ENTER
		cQry+="         SUM(PZMACE) / DECODE(SUM(VLRLAN + VALDEV), 0, 1, SUM(VLRLAN + VALDEV)) PZMACE, " + ENTER
		cQry+="         SUM(DECODE(OPER,'06',QTDVEN - QTDDEV - QTDNCA,'09',QTDVEN - QTDDEV - QTDNCA,'25',QTDVEN - QTDDEV - QTDNCA,'23', QTDVEN - QTDDEV - QTDNCA,0)) QTDREM " + ENTER
		cQry+="   FROM PEDCG"+cEmpAnt+"0 " + ENTER
		cQry+="  WHERE CARGA = pCARGA AND FILIAL = pFILIAL " + ENTER
		cQry+="  GROUP BY CARGA, UNORI); " + ENTER
		cQry+=" UPDATE CARGA"+cEmpAnt+"0 C SET MUNI = (SELECT MIN(MUN) FROM PEDCG"+cEmpAnt+"0 P " + ENTER
		cQry+="                                         WHERE P.CARGA  = C.CARGA  " + ENTER
		cQry+="                                           AND P.FILIAL = C.FILIAL " + ENTER
		cQry+="                                           AND P.UNORI  = C.UNORI  " + ENTER
		cQry+="                                           AND ORDEM    = ORDEMI)  " + ENTER
		cQry+="  WHERE FILIAL = pFILIAL " + ENTER
		cQry+="    AND CARGA  = pCARGA; " + ENTER
		cQry+=" UPDATE CARGA"+cEmpAnt+"0 C SET MUNF = (SELECT MAX(MUN) FROM PEDCG"+cEmpAnt+"0 P " + ENTER
		cQry+="                                         WHERE P.CARGA  = C.CARGA  " + ENTER
		cQry+="                                           AND P.FILIAL = C.FILIAL " + ENTER
		cQry+="                                           AND P.UNORI  = C.UNORI  " + ENTER
		cQry+="                                           AND ORDEM    = ORDEMF)  " + ENTER
		cQry+="  WHERE FILIAL = pFILIAL " + ENTER
		cQry+="    AND CARGA  = pCARGA; " + ENTER
		cQry+="  COMMIT; " + ENTER
		cQry+=" END; "
		TcSqlExec(cQry)
	Endif
Return()


// Retorna nome SQL com DbLink (FEito para tratamento para virada de vers„o)
User Function ORTSQLTB(cTab)

local cRetSql 	 := "" 
Local lV12 		 := GetVersao(.F.) == "12" //vers„o do ambiente
local cV11TabOri := Alltrim(GetnewPar("MV_XTABV11","SX5/SBM/SZQ/SZ2/SA1/SA3/SE3/SD2/SD1/SC6/SC5/SZB/SE1/SZZ/SM2/SB1/DA1/ACP/SZH/SZA/CT2/PBX"))
Private _lDbLink := GetnewPar("MV_DBLINK",.T.)
default cTab     := ""
	
cRetSql := RetSqlName(cTab)
if empty(cRetSql) 
	cRetSql := cTab + cEmpAnt + "0"
endif

if ! empty(cTab) 
	if lV12 .and. _lDbLink .and. cTab $ cV11TabOri 
		if cEmpAnt == '07' .And. Alltrim(cFilAnt) == '03'
			cRetSql := cTab + "230"
		endif	
		cRetSql := " SIGA." + cRetSql
		cRetSql += U_ORTDBLIK()
	else
		cRetSql := " SIGA." + cRetSql
	endif 
endif
return cRetSql   


// Retorna nome SQL com DbLink (FEito para tratamento para virada de vers„o)
User Function ORTDBLIK()

local cRetDB 	 := "" 
local cEmpDb 	 := cEmpAnt 
Local lProd      := cEmpant $ ('G1|30|31|51|52|53|54|55|56|57|65|68|69|71|72|73|75|') 

do case
	case cEmpAnt $ "03|18|58" 
		cEmpDb := "03"
	case cEmpAnt $ "07|23|24|" 
		cEmpDb := "07"
	case cEmpAnt $ "11|26|" 
		cEmpDb := "11"
	case cEmpAnt $ "21|" 
		cEmpDb := "22"
endcase		

cRetDB += "@DB" + cEmpDb
if lProd
	cRetDB	:= "@PROD" 
endif

return cRetDB    



User Function ORTPERFO(nTipo,cRot)
local aArea		:= GetArea()
local cQuery 	:= ''
local cRet		:= ''   	
default nTipo   := 3
default cRot    := 'FOL'

cQuery := " SELECT * "
cQuery += " FROM " + RetSqlName("RCH") + " RCH " 
cQuery += " where RCH_FILIAL = '"+xFilial( "RCH" )+"' "
cQuery += " and RCH_PROCES = '00001' "
cQuery += " and RCH_ROTEIR = '"+cRot+"' "
cQuery += " and RCH_PERSEL = '1' "
cQuery += " and d_e_l_e_t_ = ' ' "
		
If Select("XRCH") > 0
	XRCH->(dbCloseArea())
EndIf
TCQUERY cQuery ALIAS "XRCH" NEW
XRCH->(dbGotop())

if nTipo == 4
	cRet := XRCH->(RCH_MES + RCH_ANO)
elseif nTipo == 1
	cRet := XRCH->RCH_MES
elseif nTipo == 2
	cRet := XRCH->RCH_ANO
elseif nTipo == 3
	cRet := XRCH->(RCH_ANO + RCH_MES)
endif
RestArea(aArea)
return cRet



User Function fRetUnV11( _cUN, _nPorta, _cAmb )

Local   aIPs    := {}
Local   aTemp   := {}
Local   i		:= 0
Default _cUN    := ""
Default _nPorta := 1235
Default _cAmb   := ""
                           
//Lista de Servidores Remotos ( Unidades )
aAdd( aIPs, { "02", "10.0.200.62" , _nPorta, "ORTOSP" , "02", "02", "S„o Paulo			","RJ", "SB" } )
aAdd( aIPs, { "03", "10.0.200.63" , _nPorta, "ORTORJ" , "03", "02", "Rio de Janeiro		","RJ", "RJ" } )
aAdd( aIPs, { "18", "10.0.200.63" , _nPorta, "ORTORJ" , "18", "02", "Queimados		    ","RJ", "QM" } )
aAdd( aIPs, { "58", "10.0.200.63" , _nPorta, "ORTORJ" , "58", "01", "TCO           		","RJ", "TC" } )
aAdd( aIPs, { "M3", "10.0.200.63" , _nPorta, "ORTORJ" , "03", "03", "Rio de Janeiro		","RJ", "RJ" } )
aAdd( aIPs, { "04", "10.0.200.64" , _nPorta, "ORTOMG" , "04", "02", "Minas Gerais		","RJ", "MG" } )
aAdd( aIPs, { "05", "10.0.200.65" , _nPorta, "ORTOGO" , "05", "02", "Goias				","RJ", "GO" } )
aAdd( aIPs, { "25", "10.0.200.65" , _nPorta, "ORTOGO" , "25", "02", "Goias				","RJ", "GO" } )
aAdd( aIPs, { "06", "10.0.200.66" , _nPorta, "ORTOMT" , "06", "02", "Mato Grosso		","RJ", "MT" } )
aAdd( aIPs, { "07", "10.0.200.67" , _nPorta, "ORTOBA" , "07", "02", "Bahia				","RJ", "BA" } )
aAdd( aIPs, { "23", "10.0.200.67" , _nPorta, "ORTOBA" , "23", "02", "Bahia				","RJ", "FC" } )
aAdd( aIPs, { "24", "10.0.200.67" , _nPorta, "ORTOBA" , "24", "02", "CiaPlast   		","RJ", "CP" } )
aAdd( aIPs, { "08", "10.0.200.68" , _nPorta, "ORTOPE" , "08", "02", "Pernambuco			","RJ", "PE" } )
aAdd( aIPs, { "09", "10.0.200.69" , _nPorta, "ORTOCE" , "09", "02", "Cear·				","RJ", "CE" } )
aAdd( aIPs, { "10", "10.0.200.70" , _nPorta, "ORTOPR" , "10", "02", "Paran·				","RJ", "PR" } )
aAdd( aIPs, { "11", "10.0.200.71" , _nPorta, "ORTOPA" , "11", "02", "Par·				","RJ", "PA" } )
aAdd( aIPs, { "26", "10.0.200.71" , _nPorta, "ORTOPA" , "26", "02", "Manaus				","RJ", "AM" } )
aAdd( aIPs, { "15", "10.0.200.75" , _nPorta, "ORTORS" , "15", "02", "Rio Grande do Sul	","RJ", "RS" } )
aAdd( aIPs, { "21", "10.0.100.213", _nPorta, "ORTOOF" , "21", "02", "OrtoFio			","RJ", "OF" } )
aAdd( aIPs, { "22", "10.0.100.213", _nPorta, "ORTOAF" , "22", "02", "All Fibra 			","RJ", "AF" } )

if cEmpAnt == '07' .and. Alltrim(cFilAnt) == '03'
	_cUN := '23'
endif
if cEmpAnt == '03' .and. Alltrim(cFilAnt) == '03'
	_cUN := 'M3'
endif

if !Empty(_cUN)
   for i:=1 to Len(aIPs)
      if _cUN == aIPs[i,1]
      	aTemp := { aIPs[i] }
      endif	
   Next i
   if !Empty(aTemp)
      aIPs := aTemp
   endif   
Endif

if !Empty(_cAmb)
   for i:=1 to Len(aIPs)
       aIPs[i,4]:=_cAmb
   Next
Endif

Return aIPs



*******************************************************************************
* FunÁ„o......: ValCEP()                                                      *
* Programador.: Gabriel Rezende                                               *
* Finalidade..: Valida CEP digitado, mas fica a critÈrio do usu·rio prosseguir*
*                                                                             *
* Data........: 14/03/18                                                      *
******************************************************************************
/*
@Example	Cliente 	-> U_ValCEP( M->A1_CEP,"M->A1_EST","M->A1_MUN","M->A1_BAIRRO","M->A1_END","M->A1_COD_MUN")
@Example	Fornecedor 	-> U_ValCEP( M->A2_CEP,"M->A2_EST","M->A2_MUN","M->A2_BAIRRO","M->A2_END","M->A2_COD_MUN")
@Example	Vendedor 	-> U_ValCEP( M->A3_CEP,"M->A3_EST","M->A3_MUN","M->A3_BAIRRO","M->A3_END")

Usar por gatilho. Dominio e contra Dominio Iguais*/

User Function ValCEP( cCEP, oUF, oCidade, oBairro, oEnd, oCodMun )

Local oXML		:= Nil
Local cError	:= ''
Local cWarning	:= ''
Local cURL		:= ''
Local cXML		:= ''

Local cUF		:= M->RA_EST
Local cCidade	:= M->RA_CODMUNE
Local cBairro	:= M->RA_BAIRRO
Local cEnd		:= ''
Local cTipoEnd	:= M->RA_LOGRDSC

Local aArea		:= GetArea()
Local aAreaCC2	:= CC2->( GetArea() )

Default oUF		:= ''
Default oCidade	:= ''
Default oBairro	:= ''
Default oEnd	:= ''
Default oCodMun	:= ''

cURL	:= "http://cep.republicavirtual.com.br/web_cep.php?cep=" + StrTran( cCEP, "-", "") + "&formato=xml"
MsgRun( "Aguarde..." , "Consultando CEP" , { || cXML := HTTPGET( cURL ) } )

oXML		:= XmlParser( cXML , "_" , @cError , @cWarning )

If oXml:_WebServiceCep:_Resultado:Text == '1'

	cUF				:= oXml:_WebServiceCep:_UF:Text
	cCidade			:= oXml:_WebServiceCep:_Cidade:Text
	cBairro			:= oXml:_WebServiceCep:_Bairro:Text
	cEnd			:= oXml:_WebServiceCep:_Logradouro:Text
	cTipoEnd		:= oXml:_WebServiceCep:_Tipo_Logradouro:Text
	
	If oUF <> ''
		&(oUF) := cUF
	Endif
	If oCidade <> ''
		&(oCidade) := cCidade
	Endif
	If oBairro <> ''
		&(oBairro) := cBairro
	Endif
	If oEnd <> ''
		&(oEnd)	:= cEnd
	Endif
	
	CC2->(DbSetOrder(4))
	If CC2->(DbSeek(xFilial("CC2")+Upper(Padr(cUF,TamSX3("CC2_EST")[01]))+Upper(Padr(cCidade,TamSX3("CC2_MUN")[01]))))
		If oCodMun <> ''
			&(oCodMun) := CC2->CC2_CODMUN
		Endif		
	Endif	

Else

	If MsgBox("Este CEP n„o foi localizado. Deseja prosseguir com esta informaÁ„o?","ATEN«¬O","YESNO")

		&(oUF) := cUF
		&(oCidade) := cCidade
		&(oBairro) := cBairro
		&(oEnd)	:= cEnd

	Else

		&(oUF) := ''
		&(oCidade) := ''
		&(oBairro) := ''
		&(oEnd)	:= ''

	EndIf

Endif

RestArea(aAreaCC2)
RestArea(aArea)
Return(&(Alltrim(ReadVar())))

*******************************************************************************
* FunÁ„o......: ValCEPSRA()                                                   *
* Programador.: Gabriel Rezende                                               *
* Finalidade..: Valida CEP digitado, especÌfico para antigos campos da SRA    *
*               de antes do e-Social.                                         *
* Data........: 14/03/18                                                      *
******************************************************************************
/*
@Example	Funcion·rio -> U_ValCEPSRA(M->RA_CEP,"M->RA_MUNICIP","M->RA_ENDEREC")

Usar por gatilho. Dominio e contra Dominio Iguais*/

User Function ValCEPSRA( cCEP, oCidade, oEnd )

Local oXML		:= Nil
Local cError	:= ''
Local cWarning	:= ''
Local cURL		:= ''
Local cXML		:= ''

Local cUF		:= M->RA_EST
Local cCidade	:= M->RA_CODMUNE
Local cBairro	:= M->RA_BAIRRO
Local cEnd		:= ''
Local cTipoEnd	:= M->RA_ENDEREC

Local aArea		:= GetArea()
Local aAreaCC2	:= CC2->( GetArea() )

Default oCidade	:= ''
Default oEnd	:= ''

cURL	:= "http://cep.republicavirtual.com.br/web_cep.php?cep=" + StrTran( cCEP, "-", "") + "&formato=xml"
MsgRun( "Aguarde..." , "Consultando CEP" , { || cXML := HTTPGET( cURL ) } )

oXML		:= XmlParser( cXML , "_" , @cError , @cWarning )

If oXml:_WebServiceCep:_Resultado:Text == '1'

	cUF				:= oXml:_WebServiceCep:_UF:Text
	cCidade			:= oXml:_WebServiceCep:_Cidade:Text
	cBairro			:= oXml:_WebServiceCep:_Bairro:Text
	cEnd			:= oXml:_WebServiceCep:_Logradouro:Text
	cTipoEnd		:= oXml:_WebServiceCep:_Tipo_Logradouro:Text
	
	If oCidade <> ''
		&(oCidade) := cCidade
	Endif
	If oEnd <> ''
		&(oEnd)	:= cTipoEnd + ' ' + cEnd
	Endif
	
Else

	If MsgBox("Este CEP n„o foi localizado. Deseja prosseguir com esta informaÁ„o?","ATEN«¬O","YESNO")

		&(oCidade) := cCidade
		&(oEnd)	:= cTipoEnd + ' ' + cEnd

	Else

		&(oCidade) := ''
		&(oEnd)	:= ''

	EndIf

Endif

RestArea(aAreaCC2)
RestArea(aArea)
Return(&(Alltrim(ReadVar())))



User Function ufGetPer(nTipo,cProc,cRot)

local aArea		:= GetArea()
Local mvfolmes  := ""
Local aper      := {}
default nTipo   := '1'
default cProc   := '00001'
default cRot    := 'FOL'

fGetPerAtual(@aPer,xFilial("RCH"),cProc,cRot)
if len(aPer) > 0 
	if nTipo == '2' 
		mvfolmes := aPer[1,4] + aPer[1,5]
	else
		mvfolmes := aPer[1,5] + aPer[1,4]
	endif
endif	

RestArea(aArea)
Return(mvfolmes) 



User function OrtEstCv(cTp)
local cRet := '04'
do case 
	case cTp == 'S'
		cRet := '01' // SOLTEIRO
	case cTp == 'C'
		cRet := '02' // CASADO
	case cTp == 'D'
		cRet := '03' // OUTROS
endcase
return cRet



User function OrtGrIns(cTp)
local cRet := '03'
do case 
	case cTp == '10'
		cRet := '01' // Analfabeto
	case cTp $ '20/25/30/'
		cRet := '02' // 1∫ Grau incompleto 
	case cTp == '35'
		cRet := '03' // 1∫ Grau completo
	case cTp == '40'
		cRet := '04' // 2∫ Grau incompleto
	case cTp == '45'
		cRet := '05' // 2∫ Grau completo
	case cTp == '50'
		cRet := '06' // Superior incompleto 
	case cTp == '55/65/75/85/95'
		cRet := '07' // Superior completo
endcase
return cRet



User function OrtConPA()
return ( iif(SRA->RA_XTPCONT=="7","0099999999",STRZERO(VAL(SUBSTR(SRA->RA_CTDEPSA,1,10)),10)) ) 


//Retorna informaÁıes de conta de debito e convenio para Cnab Bradesco
User function OrtInfPG(nTipo,cEmpX)

local cRet	  := ""
default nTipo := 0 
default cEmpX := cEmpAnt

do case
	case cEmpX == '52'
		do case
			case nTipo == 1 //agencia 
				cRet  := "01934"
			case nTipo == 2 //digito agencia 
				cRet  := " "
			case nTipo == 3 //conta
				cRet  := "000000012084"
			case nTipo == 4 //digito da conta
				cRet  := "4" 
			case nTipo == 5 //Convenio
				cRet  := "837059              "
		endcase		
	case cEmpX == '53'
		do case
			case nTipo == 1 //agencia 
				cRet  := "01934"
			case nTipo == 2 //digito agencia 
				cRet  := " "
			case nTipo == 3 //conta
				cRet  := "000000012188"
			case nTipo == 4 //digito da conta
				cRet  := "3" 
			case nTipo == 5 //Convenio
				cRet  := "838454              "
		endcase		
	case cEmpX == '54'
		do case
			case nTipo == 1 //agencia 
				cRet  := "01934"
			case nTipo == 2 //digito agencia 
				cRet  := " "
			case nTipo == 3 //conta
				cRet  := "000000012477"
			case nTipo == 4 //digito da conta
				cRet  := "7" 
			case nTipo == 5 //Convenio
				cRet  := "843504              "
		endcase		
	case cEmpX == '56'
		do case
			case nTipo == 1 //agencia 
				cRet  := "01934"
			case nTipo == 2 //digito agencia 
				cRet  := " "
			case nTipo == 3 //conta
				cRet  := "000000012360"
			case nTipo == 4 //digito da conta
				cRet  := "6" 
			case nTipo == 5 //Convenio
				cRet  := "839400              "
		endcase		
	case cEmpX == '57'
		do case
			case nTipo == 1 //agencia 
				cRet  := "01934"
			case nTipo == 2 //digito agencia 
				cRet  := " "
			case nTipo == 3 //conta
				cRet  := "000000012337"
			case nTipo == 4 //digito da conta
				cRet  := "1" 
			case nTipo == 5 //Convenio
				cRet  := "839396              "
		endcase		
	case cEmpX == '65'
		do case
			case nTipo == 1 //agencia 
				cRet  := "01934"
			case nTipo == 2 //digito agencia 
				cRet  := " "
			case nTipo == 3 //conta
				cRet  := "000000011961"
			case nTipo == 4 //digito da conta
				cRet  := "7" 
			case nTipo == 5 //Convenio
				cRet  := "837067              "
		endcase		
	case cEmpX == '68'
		do case
			case nTipo == 1 //agencia 
				cRet  := "01934"
			case nTipo == 2 //digito agencia 
				cRet  := " "
			case nTipo == 3 //conta
				cRet  := "000000011961"
			case nTipo == 4 //digito da conta
				cRet  := "7" 
			case nTipo == 5 //Convenio
				cRet  := "857211              "
		endcase		
	case cEmpX == '71'
		do case
			case nTipo == 1 //agencia 
				cRet  := "03378"
			case nTipo == 2 //digito agencia 
				cRet  := "2"
			case nTipo == 3 //conta
				cRet  := "000000001605"
			case nTipo == 4 //digito da conta
				cRet  := "5" 
			case nTipo == 5 //Convenio
				cRet  := "307919              "
		endcase		
	case cEmpX == '75'
		do case
			case nTipo == 1 //agencia 
				cRet  := "02864"
			case nTipo == 2 //digito agencia 
				cRet  := " "
			case nTipo == 3 //conta
				cRet  := "000000001326"
			case nTipo == 4 //digito da conta
				cRet  := "9" 
			case nTipo == 5 //Convenio
				cRet  := "452211              "
		endcase	
	OTHERWISE 
		do case
			case nTipo == 1 //agencia 
				cRet  := "02864"
			case nTipo == 2 //digito agencia 
				cRet  := " "
			case nTipo == 3 //conta
				cRet  := "000000001326"
			case nTipo == 4 //digito da conta
				cRet  := "9" 
			case nTipo == 5 //Convenio
				cRet  := "452211              "
		endcase			
endcase

return cRet


// Retorna filial correta para o calculo do TQ
User Function xOrtFil(cTab,nTipo)

local cRet 	     := "" 
local cV11TabOri := Alltrim(GetnewPar("MV_XTABV11","SX5/SBM/SZQ/SZ2/SA1/SA3/SE3/SD2/SD1/SC6/SC5/SZB/SE1/SZZ/SM2/SB1/DA1/ACP/SZH/SZA/"))
default cTab     := ""
default nTipo    := 1

cRet := xFilial(cTab)

if nTipo == 2 
	If (cEmpAnt == '02' .And. Alltrim(cFilAnt) == '04') .or. (cEmpAnt == '02' .And. Alltrim(cFilAnt) == '05')
		cRet := "02" 
	endif
	If cEmpAnt == '07' .And. Alltrim(cFilAnt) == '03'
		cRet := "02" 
	endif
	If cEmpAnt == '22' .And. Alltrim(cFilAnt) == '01'
		cRet := "02" 
	endif
else
	if !empty(cTab) .and. cTab $ cV11TabOri  
		If (cEmpAnt == '02' .And. Alltrim(cFilAnt) == '04') .or. (cEmpAnt == '02' .And. Alltrim(cFilAnt) == '05')
			cRet := "02" 
		endif
		If cEmpAnt == '07' .And. Alltrim(cFilAnt) == '03'
			cRet := "02" 
		endif
		If cEmpAnt == '22' .And. Alltrim(cFilAnt) == '01'
			cRet := "02" 
		endif
	endif
endif		
return cRet 


// Retorna empresa especifica do TQ
User Function xOrtEmp()
Local cEmpTmp := ""

If cEmpAnt=='07' .And. Alltrim(cFilAnt) =='03'
	cEmpTmp	:= '23'
else
	cEmpTmp	:= cEmpAnt
endif	
return cEmpTmp
             
             

User Function fUltMat(cCpf)
local aArea	 := GetArea()
local cQuery := ''
local nRet	 := 0   	

cQuery := " SELECT MAX(SRA.R_E_C_N_O_) XRECNO "
cQuery += " FROM " + RetSqlName("SRA") + " SRA " 
cQuery += " WHERE RA_CIC    = '" + Alltrim(cCpf) +"' "
cQuery += "  AND RA_RESCRAI <> '31' "
cQuery += "  AND RA_SITFOLH <> 'D' "
cQuery += "  AND d_e_l_e_t_ = ' ' "
		
If Select("XSRA") > 0
	XSRA->(dbCloseArea())
EndIf
TCQUERY cQuery ALIAS "XSRA" NEW
XSRA->(dbGotop())
if !XSRA->(Eof())
	nRet := XSRA->XRECNO
endif
RestArea(aArea)
return nRet



User Function OrIpRepl(lComercial,lFolha,lRegional,lG3)

local aSrv 	   		:= {}
Local nPortFol 		:= 4235
Local nPortCom 		:= 1235
default lComercial  := .f.
default lFolha	    := .f.
default lRegional   := .f.
default lG3		    := .f.

if lComercial
	aAdd(aSrv,{"10.0.200.62" , nPortCom, "ORTOSP" , "02", "02"} )
	aAdd(aSrv,{"10.0.200.63" , nPortCom, "ORTORJ" , "03", "02"} )
	aAdd(aSrv,{"10.0.200.63" , nPortCom, "ORTORJ" , "03", "03"} )
	aAdd(aSrv,{"10.0.200.63" , nPortCom, "ORTORJ" , "18", "02"} )
	aAdd(aSrv,{"10.0.200.63" , nPortCom, "ORTORJ" , "18", "03"} )
	aAdd(aSrv,{"10.0.200.63" , nPortCom, "ORTORJ" , "58", "01"} )
	aAdd(aSrv,{"10.0.200.64" , nPortCom, "ORTOMG" , "04", "02"} )
	aAdd(aSrv,{"10.0.200.65" , nPortCom, "ORTOGO" , "05", "02"} )
	aAdd(aSrv,{"10.0.200.65" , nPortCom, "ORTOGO" , "25", "02"} )
	aAdd(aSrv,{"10.0.200.66" , nPortCom, "ORTOMT" , "06", "02"} )
	aAdd(aSrv,{"10.0.200.67" , nPortCom, "ORTOBA" , "07", "02"} )
	aAdd(aSrv,{"10.0.200.67" , nPortCom, "ORTOBA" , "07", "04"} )
	aAdd(aSrv,{"10.0.200.67" , nPortCom, "ORTOBA" , "23", "02"} )
	aAdd(aSrv,{"10.0.200.67" , nPortCom, "ORTOBA" , "24", "02"} )
	aAdd(aSrv,{"10.0.200.68" , nPortCom, "ORTOPE" , "08", "02"} )
	aAdd(aSrv,{"10.0.200.68" , nPortCom, "ORTOPE" , "08", "03"} )
	aAdd(aSrv,{"10.0.200.69" , nPortCom, "ORTOCE" , "09", "02"} )
	aAdd(aSrv,{"10.0.200.69" , nPortCom, "ORTOCE" , "09", "03"} )
	aAdd(aSrv,{"10.0.200.70" , nPortCom, "ORTOPR" , "10", "02"} )
	aAdd(aSrv,{"10.0.200.71" , nPortCom, "ORTOPA" , "11", "02"} )
	aAdd(aSrv,{"10.0.200.71" , nPortCom, "ORTOPA" , "26", "02"} )
	aAdd(aSrv,{"10.0.200.75" , nPortCom, "ORTORS" , "15", "02"} )
	aAdd(aSrv,{"10.0.200.75" , nPortCom, "ORTORS" , "15", "03"} )
	aAdd(aSrv,{"10.0.100.213", nPortCom, "ORTOOF" , "21", "02"} )
	aAdd(aSrv,{"10.0.100.213", nPortCom, "ORTOAF" , "22", "02"} )
endif

if lFolha
	AADD(aSrv,{"10.0.100.215", nPortFol, "FOLHASP", "02", "02"} )
	AADD(aSrv,{"10.0.100.215", nPortFol, "FOLHASP", "02", "03"} )
	AADD(aSrv,{"10.0.100.215", nPortFol, "FOLHASP", "02", "04"} )
	AADD(aSrv,{"10.0.100.215", nPortFol, "FOLHASP", "02", "05"} )
    if cEmpAnt == "03" .and. cFilAnt == "02"
    	AADD(aSrv,{"10.0.100.201", nPortFol, "FOLHARJ", "03", "03"} )
    elseif  cEmpAnt == "03" .and. cFilAnt == "03"
    	AADD(aSrv,{"10.0.100.201", nPortFol, "FOLHARJ", "03", "02"} )
    endif
	AADD(aSrv,{"10.0.100.201", nPortFol, "FOLHARJ", "58", "01"} )
	AADD(aSrv,{"10.0.100.201", nPortFol, "FOLHARJ", "18", "02"} )
	AADD(aSrv,{"10.0.100.201", nPortFol, "FOLHARJ", "18", "03"} )
	AADD(aSrv,{"10.0.100.202", nPortFol, "FOLHAMG", "04", "02"} ) 
	AADD(aSrv,{"10.0.100.202", nPortFol, "FOLHAMG", "59", "01"} ) 
	AADD(aSrv,{"10.0.100.203", nPortFol, "FOLHAGO", "05", "02"} )
	AADD(aSrv,{"10.0.100.203", nPortFol, "FOLHAGO", "25", "02"} )
	AADD(aSrv,{"10.0.100.204", nPortFol, "FOLHAMT", "06", "02"} )
	AADD(aSrv,{"10.0.100.205", nPortFol, "FOLHABA", "07", "02"} ) 
	AADD(aSrv,{"10.0.100.205", nPortFol, "FOLHABA", "07", "03"} ) 
	AADD(aSrv,{"10.0.100.205", nPortFol, "FOLHABA", "07", "04"} ) 
	AADD(aSrv,{"10.0.100.205", nPortFol, "FOLHABA", "24", "02"} )
	AADD(aSrv,{"10.0.100.206", nPortFol, "FOLHAPE", "08", "02"} )
	AADD(aSrv,{"10.0.100.206", nPortFol, "FOLHAPE", "08", "03"} )
	AADD(aSrv,{"10.0.100.207", nPortFol, "FOLHACE", "09", "02"} ) 
	AADD(aSrv,{"10.0.100.207", nPortFol, "FOLHACE", "09", "03"} ) 
	AADD(aSrv,{"10.0.100.208", nPortFol, "FOLHAPR", "10", "02"} )
	AADD(aSrv,{"10.0.100.209", nPortFol, "FOLHAPA", "11", "02"} )
	AADD(aSrv,{"10.0.100.209", nPortFol, "FOLHAPA", "26", "02"} )
	AADD(aSrv,{"10.0.100.210", nPortFol, "FOLHARS", "15", "02"} )
	AADD(aSrv,{"10.0.100.210", nPortFol, "FOLHARS", "15", "03"} )
	AADD(aSrv,{"10.0.100.213", nPortFol, "FOLHAAF", "21", "02"} )
	AADD(aSrv,{"10.0.100.213", nPortFol, "FOLHAAF", "22", "01"} )
	AADD(aSrv,{"10.0.100.213", nPortFol, "FOLHAAF", "22", "02"} )
endif

if lRegional 	
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "30", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "30", "02"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "30", "03"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "31", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "51", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "52", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "53", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "54", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "55", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "56", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "57", "01"} ) 
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "62", "01"} )  
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "65", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "68", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "69", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "71", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "72", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "73", "01"} )
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "75", "01"} ) 
	AADD(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "32", "01"} )
endif

if lG3
	aAdd(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "G3", "340100"} )
	aAdd(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "G3", "340500"} )
	aAdd(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "G3", "340600"} )
	aAdd(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "G3", "341000"} )
	aAdd(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "G3", "341500"} )
	aAdd(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "G3", "342600"} )
	aAdd(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "G3", "343000"} )
	aAdd(aSrv,{"10.0.100.6"  , nPortFol, "ORTOBOM", "G3", "360100"} )
endif
return aSrv             



user function ORSQBCPA()
local cRet       := "01"
local cAnoMesAtu := AnoMes(Date())
local cAnoMesMv  := "" 
local cSeqBcMv   := ""
local cTmpMv     := Alltrim(GetMv('MV_XSQBCPA',.f.,'00'+AnoMes(Date()) ))  

if "FOL" $ mv_par01
	cRet := "00"
elseif !empty(cTmpMv)
	cAnoMesMv  := substr(cTmpMv,3,6)
	cSeqBcMv   := substr(cTmpMv,1,2)
	if cAnoMesAtu == cAnoMesMv 
		cRet := Soma1(cSeqBcMv)
	endif
	PutMv("MV_XSQBCPA",cRet + cAnoMesAtu)
endif
return cRet

// ===============================================
// verifica se È balanco (ultimo dia util do mes)
// bloquear todas as atividades apos as 12h.
// ===============================================
User Function IsBalanco()
Local lRet    := .F.
Local cQuery  := ""
Local cLimite := "12:00"
Local dData   := Date()

cQuery	:= " SELECT DATABAL, HORABAL, LIBERAR "
cQuery	+= "   FROM BALANCOMENSAL "
cQuery	+= "  WHERE UNIDADE = '"+cEmpAnt+"' "		
cQuery	+= "    AND DATABAL = '"+DToS(dData)+"' "
cQuery	+= "    ORDER BY DATABAL ASC "
		
U_ORTQUERY(cQuery, "ISBALANCO")

if !ISBALANCO->(Eof())
	dData	:= STOD(ISBALANCO->DATABAL)
	cLimite := ISBALANCO->HORABAL
	If ISBALANCO->LIBERAR == "T"
		ISBALANCO->(dbCloseArea())
		RETURN .F.
	Endif
Else
	ISBALANCO->(dbCloseArea())
	RETURN .F.
Endif

ISBALANCO->(dbCloseArea())

If Date() == dData
	If Time() > cLimite
		Alert("Operacao n„o permitida apÛs as " + cLimite + " em dia de BalanÁo.")
		lRet := .T.
	Endif
Endif

Return lRet


User Function FRPEDEUN(_cUn,_cNum)
Local aRet   := {""}
Local cQuery := ""

cQuery := " SELECT SC5.* "
cQuery += " FROM " + RetSqlName("SC5") + " SC5 " 
cQuery += " WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery += " AND SC5.C5_FILIAL  =   '"+ XFILIAL("SC5")+ "' "
cQuery += " AND SC5.C5_XOPER   = '14' "
cQuery += " AND SUBSTR(SC5.C5_XPEDCLX,1,6) = '"+_cNum + "' "
cQuery += " AND SC5.C5_XUNORI  = '"+_cUn + "' "
cQuery += " AND SUBSTR(C5_VEND1, 1, 1) = 'C' "
cQuery += " AND SC5.C5_XDTFECH <> ' ' "
cQuery += " AND SC5.C5_XACERTO <> ' ' "

If Select("TMPDES") > 0
	DbSelectArea("TMPDES")
	DbCloseArea()
EndIf
TcQuery cQuery Alias "TMPDES" New
if !TMPDES->(EOF())
	aRet[1] := TMPDES->C5_NUM	
Endif
TMPDES->(DbCloseArea())

Return aRet
