#include 'rwmake.ch'
#include 'protheus.ch'
#include 'topconn.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณORTP006   บAutor  ณCesar Dupim         บ Data ณ  01/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Replica็ใo de produtos da unidade 03                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*--------------+------------+----------------------------------------------------------*\
| Everton Tate  | 24/11/2021 | Remover o campo B1_CEST da replica por que ้ especifico   |
| ARMI  #5571   |            | por Unidade                                               |
|---------------|------------|-----------------------------------------------------------|
| Everton Tate  | 28/01/2022 | Criar tela para o usuแrio poder selecionar o item para    |
| ARMI  #11925  |            | integra็ใo e informar Grupo Trib.                         |
\*--------------+------------+----------------------------------------------------------*/

User Function ortp006(aProds)
	Local i:=0
	Local aArea:=GetArea()
	Local cQuery:=""
	Local aParamBox:={}
	Local aRet:={}

	Local nPosProd
	Default aProds := {}

	Private MV_PAR01 := iif(valtype(MV_PAR01) == "U","",MV_PAR01)

	BEGIN TRANSACTION
		cQuery:="UPDATE "+RetSqlName("SB1")+" SET B1_QB = 1 WHERE B1_QB = 0 "
		TcSqlExec(CQUERY)
		cQuery:="UPDATE "+RetSqlName("SB1")+" SET B1_XMODELO = '999999' WHERE B1_COD LIKE '0%' AND B1_XMODELO <> '999999' "
		TcSqlExec(CQUERY)
	END TRANSACTION
	cQuery:="SELECT ORIG.* "
	cQuery+="  FROM SB1030 ORIG, "+RetSqlName("SB1")+" DEST "
	cQuery+=" WHERE ORIG.D_E_L_E_T_ = ' ' "
	cQuery+="   AND DEST.D_E_L_E_T_ = ' ' "
	cQuery+="   AND ORIG.B1_COD = DEST.B1_COD "
	cQuery+="   AND ORIG.B1_XDTIMPV > DEST.B1_XDTIMPV "
	cQuery+="   AND ORIG.B1_XDTIMPV > '20200801' "
	cQuery+="   AND ORIG.B1_GRUPO <> ' ' "
	cQuery+="   AND ORIG.B1_XCODBAS = ' ' "
	cQuery+="   AND ORIG.B1_FILIAL = '  ' "
	cQuery+="   AND DEST.B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery+="UNION ALL "
	cQuery+="SELECT ORIG.* "
	cQuery+="  FROM SB1030 ORIG, "+RetSqlName("SB1")+" DEST "
	cQuery+=" WHERE ORIG.D_E_L_E_T_ = ' ' "
	cQuery+="   AND DEST.D_E_L_E_T_(+) = ' ' "
	cQuery+="   AND ORIG.B1_COD = DEST.B1_COD(+) "
	cQuery+="   AND DEST.B1_XDTIMPV IS NULL "
	cQuery+="   AND ORIG.B1_XDTIMPV > '20200801' "
	cQuery+="   AND ORIG.B1_GRUPO <> ' ' "
	cQuery+="   AND ORIG.B1_XCODBAS = ' ' "
	cQuery+="   AND ORIG.B1_FILIAL = '  ' "
	cQuery+="   AND DEST.B1_FILIAL(+) = '"+xFilial("SB1")+"' "
	memowrite('C:\ORTP006.SQL',cquery)
	cTrb := MpSysOpenQuery(cQuery)
	dbselectarea("SB1")
	aCmpO:=DbStruct()
	dbselectarea(cTrb)
	aCmpD:=DbStruct()
	dbgotop()
	lContinua:=.T.
	do while !eof() .and. lContinua
		nPosProd := aScan(aProds,{|x| Ltrim(RTrim(x[1])) == Ltrim(RTrim((cTrb)->B1_COD)) })  //Inclusใo automแtica
		If Empty(aProds) .OR. nPosProd > 0  //Se array vazio chamada manual, se encontrou o produto chamada automแtica.
			dbselectarea("SB1")
			dbSetOrder(1)
			lInc:=.F.
			If DbSeek(xFilial("SB1")+(cTrb)->B1_COD)
				reclock("SB1",.F.)
			Else
				If nPosProd == 0 //Inclusใo manual
					aParamBox:={{9,"Importando Produto: "+(cTrb)->B1_COD+" - "+(cTrb)->B1_DESC,200,10,.T.}} // Tipo say
					aAdd(aParamBox,{1,"Grupo Tributacao"  ,Space(3),"@!","EXISTCPO('SX5','21'+MV_PAR01)",,"",3,.F.}) // Tipo Get
					DbSelectArea("SX5")
					DbSetOrder(1)
					DbSeek(xFilial("SX5")+"21")
					nCont:=1
					Do While !Eof() .and. SX5->X5_TABELA == "21" .and. ncont < 50//Adotei essa solucao pq da pau no F3 na tela de login - Dupim
						aAdd(aParamBox,{9,SX5->X5_CHAVE+" - "+SX5->X5_DESCRI,200,7,.F.}) // Tipo say
						DbSkip()
						nCont++
					EndDo
					If !ParamBox(aParamBox,"Parโmetros...",@aRet,,,,,,,,.f.,.f.)
						lContinua:=.F.
					else
						reclock("SB1",.T.)
						SB1->B1_FILIAL:=xFilial("SB1")
						SB1->B1_GRTRIB:=MV_PAR01
					Endif
				Else //Inclusใo automแtica
					reclock("SB1",.T.)
					SB1->B1_FILIAL:=xFilial("SB1")
					SB1->B1_GRTRIB:=aProds[nPosProd,2]   
				EndIf
				lInc:=.T.
			Endif
			if lContinua
				for i:=1 to len(aCmpD)
					nPos:=aScan(aCmpO,{|x| x[1]==aCmpD[i,1]})
					cIgnore:="B1_ESPECIE|B1_GRTRIB|B1_CONTA|B1_PROC|B1_XTABUN|B1_XDIRIGI|B1_XFORFCI|B1_FILIAL|B1_XAGRPF|B1_XCUSMED|B1_XDECOMP|B1_CEST"
					if cEmpAnt$("21|22|23|24") .and. !lInc
						cIgnore+="|B1_XMODELO|B1_XTPORTO"
						If cEmpAnt == "21" // 22/12/2020 - Henrique - SSI 107841
						cIgnore+="|B1_XPERFCI|B1_XNUMFCI"
						EndIf
					Endif
					if substr((cTRB)->B1_COD,1,1)=="0"
						cIgnore+="|B1_XFORLIN"
					Endif
					If (cTrb)->B1_XMODELO=="000011" .OR. (cTrb)->B1_TIPO=="MB"
					cIgnore+="|B1_LOCPAD"
					EndIf
					if nPos > 0 .and. !(ALLTRIM(aCmpD[i,1])$cIgnore)
						cCmp:=aCmpD[i,1]
						if aCmpO[nPos,2]=="D"
							SB1->(&cCmp):=stod((cTrb)->(&cCmp))
						else
							if aCmpO[nPos,2]=="L"
								if (cTrb)->(&cCmp)=="T"
									SB1->(&cCmp):=.T.
								else
									SB1->(&cCmp):=.F.
								endif
							else
								SB1->(&cCmp):=(cTrb)->(&cCmp)
							endif
						endif
					endif
				next
				if (cTrb)->B1_XMODELO=="000015" .AND. (cEmpAnt=="22" .or. cEmpAnt=="16")
					SB1->B1_XMODELO:="000007"
				endif
				msunlock()
			Endif
		EndIf
		dbselectarea(cTrb)
		dbskip()
	enddo
	dbclosearea()
	restarea(aArea)
Return()

//Chamada trazendo todos os produtos. Para que possam editar em lote.
User Function ORTP006A()

Local aProds := {}
Local cQuery := ""

Local oNewGet
Local aHeaderEx := {}
Local aColsEx := {}
Local aFields := {"B1_COD","B1_DESC","B1_GRTRIB"}
Local aAlterFields := {"B1_GRTRIB"}
Local nX
Local oBtnExec
Local oBtnCanc

Static oDlgPrd

/*  A T E N ว ร O  -  MANTER A QUERY COMPATIVEL COM A FUNวรO ACIMA ORTP006 EM SUA PARTE DE INCLUSรO (depois do union) */

cQuery:="SELECT ORIG.B1_COD, ORIG.B1_DESC "
cQuery+="  FROM SB1030 ORIG, "+RetSqlName("SB1")+" DEST "
cQuery+=" WHERE ORIG.D_E_L_E_T_ = ' ' "
cQuery+="   AND DEST.D_E_L_E_T_(+) = ' ' "
cQuery+="   AND ORIG.B1_COD = DEST.B1_COD(+) "
cQuery+="   AND DEST.B1_XDTIMPV IS NULL "
cQuery+="   AND ORIG.B1_XDTIMPV > '20200801' "
cQuery+="   AND ORIG.B1_GRUPO <> ' ' "
cQuery+="   AND ORIG.B1_XCODBAS = ' ' "
cQuery+="   AND ORIG.B1_FILIAL = '  ' "
cQuery+="   AND DEST.B1_FILIAL(+) = '"+xFilial("SB1")+"' "
TCQUERY cQuery NEW ALIAS "QRYINC"

While !QRYINC->(Eof())
	aAdd(aColsEx,{'WFUNCHK',QRYINC->B1_COD,QRYINC->B1_DESC,Space(3),.F.})
	QRYINC->(dbSkip())
EndDo
QRYINC->(dbCloseArea())

ASORT(aColsEx, , ,{|x,y| x[2] < y[2] } )

If Len(aColsEx) > 0

	aAdd(aHeaderEx,{'Status','STATUS','@BMP', 2, 0, '.F.' , '', 'C', '', 'V', '', ''})

	SX3->(DbSetOrder(2))
  	For nX := 1 to Len(aFields)
    	If SX3->(DbSeek(aFields[nX]))
      		Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
                       		 " ",SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
    	Endif
 	Next nX
	
  	DEFINE MSDIALOG oDlgPrd TITLE "Replica de Produtos" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

    	@ 007, 005 BUTTON oBtnExec PROMPT "Salvar Marcados" SIZE 055, 012 OF oDlgPrd PIXEL ACTION (aProds:=faProds(oNewGet),if(!Empty(aProds),U_ortp006(aProds),nil),oDlgPrd:END())
    	@ 007, 208 BUTTON oBtnCanc PROMPT "Cancelar" SIZE 037, 012 OF oDlgPrd        PIXEL ACTION oDlgPrd:END()
		oNewGet := MsNewGetDados():New( 025, 005, 246, 246, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgPrd, aHeaderEx, aColsEx)
		oNewGet:oBrowse:blDblClick := { |x,c|  if(c==4,(oNewGet:EditCell(),oNewGet:aCols[oNewGet:nAt,1] := IIf(Empty(oNewGet:aCols[oNewGet:nAt,4]),'WFUNCHK','WFCHK')),oNewGet:aCols[oNewGet:nAt,1] := IIf(oNewGet:aCols[oNewGet:nAt,1] == 'WFCHK','WFUNCHK','WFCHK')) }
		oNewGet:AINFO[4][8] := .F.  //Retirar a obrigatoriedade do B1_GRTRIB

  	ACTIVATE MSDIALOG oDlgPrd CENTERED
else
	
	MsgInfo("Nใo existem produtos pendentes.", "Replica de Produtos")

EndIf

Return

Static Function faProds(oNewGet)
Local aRet := {}

AEVAL( oNewGet:aCols, {|x| If(x[1]=='WFCHK',aAdd(aRet,{x[2],x[4]}),nil) })

Return aRet
