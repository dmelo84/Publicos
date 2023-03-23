#Include "Protheus.Ch"
#Include "TopConn.Ch"
#Include "RwMake.Ch"
#Include "SigaWin.Ch"
#include "colors.ch"
#include "font.ch"
#INCLUDE "JPEG.CH"
#INCLUDE "TBICONN.CH"


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ORTA454   ∫Autora ≥Thais Fernandes     ∫ Data ≥  11/28/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ Mapa R.A.C (RelatÛrio de Atendimento ao Cliente)           ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

**********************************
User Function ORTA454()
**********************************
PRIVATE aCores := {{ "EMPTY(DTFECH)" 	, "BR_VERDE"    },;   
				   { "!EMPTY(DTFECH)" 	, "BR_VERMELHO" }}
				
Private aRotina := { {"Filtra" ,"U_fPesq454()"    ,0,1} ,;
{"Visualizar","U_aRacMov(2)"  ,0,2} ,;
{"Incluir"   ,"U_aRacMov(3)"  ,0,3} ,;
{"Alterar"   ,"U_aRacMov(4)"  ,0,4} ,;
{"Excluir"   ,"U_aRacMov(5)"  ,0,5} ,;
{"Imprimir"  ,"U_fImpRac()"  ,0,6},;
{"Legenda"   ,"U_orta454leg()"  ,0,2}}
Private aBotao     := {}
Private aTitulos:= {}
Private aFld    := {}
Private cAliasRac := "MAPARAC" //GetNextAlias()
Private cPerg   :="ORTA454"

CriaMv("MV_XALTAMO"	, "Usuarios que possuem permissao para alterar","a Analise das Amostras do Mapa RAC") //SSI 15677

//aadd(aBotao,{ "IMPRIMIR", {|| fImpRac()}, "Imprimir", "Imprimir" }  )
ValidPerg(cPerg)                                                            

AADD(aTitulos,{"Num RAC"	 , "NUMRAC"	 ,"C", 06,  0,"@!"})
AADD(aTitulos,{"Causas"	 	 , "CAUSAS"	 ,"C", 100, 0,"@!"})
AADD(aTitulos,{"Cliente"	 , "CLIENTE" ,"C", 06,  0,"@!"})
AADD(aTitulos,{"Loja"		 , "LOJACLI" ,"C", 02,  0,"@!"})
AADD(aTitulos,{"Razao Social", "A1_NOME" ,"C", 40,  0,"@!"})
AADD(aTitulos,{"Inclusao"	 , "DTINCLU" ,"D", 08,  0,""  })
AADD(aTitulos,{"Fechamento"	 , "DTFECH"  ,"D", 08,  0,""  })
AADD(aTitulos,{"Produto"	 , "PRODUTO" ,"C", 10,  0,"@!"})
AADD(aTitulos,{"Num Pedido"  , "NUMPED"  ,"C", 06,  0,"@!"})
AADD(aTitulos,{"Vendedor"	 , "VENDEDOR","C", 06,  0,"@!"})
AADD(aTitulos,{"Setor"		 , "SETOR"   ,"C", 30,  0,"@!"})
AADD(aTitulos,{"Tipo Atendimento" , "TPATEND" ,"C", 13,  0,"@!"})
AADD(aTitulos,{"Num RNC"	 , "NUMRNC"  ,"C", 10,  0,"@!"})
//AADD(aTitulos,{"Mao de Obra" , "MAODEOBRA"  ,"C", 40,  0,"@!"})
//AADD(aTitulos,{"Materia Prima" , "MATPRIMA"  ,"C", 40,  0,"@!"})
//AADD(aTitulos,{"Maquina" , "MAQUINA"  ,"C", 40,  0,"@!"})
//AADD(aTitulos,{"Metodo"  , "METODO"   ,"C", 40,  0,"@!"})
//AADD(aTitulos,{"Meio Ambiente"  , "MEIOAMB" ,"C", 40,  0,"@!"})
                                         

AADD(aFld,{"NUMRAC"	  ,"C", 06,  0,"@!"})
AADD(aFld,{"CAUSAS"	  ,"C", 100,  0,"@!"})
AADD(aFld,{"CLIENTE"  ,"C", 06,  0,"@!"})
AADD(aFld,{"LOJACLI"  ,"C", 02,  0,"@!"})
AADD(aFld,{"A1_NOME"  ,"C", 40,  0,"@!"})
AADD(aFld,{"DTINCLU"  ,"D", 08,  0," " })
AADD(aFld,{"DTFECH"	  ,"D", 08,  0," " })
AADD(aFld,{"PRODUTO"  ,"C", 10,  0,"@!"})
AADD(aFld,{"NUMPED"   ,"C", 06,  0,"@!"})
AADD(aFld,{"VENDEDOR" ,"C", 06,  0,"@!"})
AADD(aFld,{"SETOR"    ,"C", 30,  0,"@!"})
AADD(aFld,{"TPATEND"  ,"C", 13,  0,"@!"})
AADD(aFld,{"NUMRNC"   ,"C", 10,  0,"@!"})
//AADD(aFld,{"MAODEOBRA","C", 40,  0,"@!"})
//AADD(aFld,{"MATPRIMA" ,"C", 40,  0,"@!"})
//AADD(aFld,{"MAQUINA"  ,"C", 40,  0,"@!"})
//AADD(aFld,{"METODO"   ,"C", 40,  0,"@!"})
//AADD(aFld,{"MEIOAMB"  ,"C", 40,  0,"@!"})

cQuery := " SELECT NUMRAC, CLIENTE, SUBSTR(A1_NOME,1,40) A1_NOME, LOJACLI, PRODUTO, NUMPED, VENDEDOR, SETOR, "

//Edilson Leal SSI 108351
cQuery += "(CASE WHEN 
cQuery += "            TRIM(MAODEOBRA) <> ' ' OR"
cQuery += "            TRIM(MATPRIMA)  <> ' ' OR"
cQuery += "            TRIM(MAQUINA)   <> ' ' OR"
cQuery += "            TRIM(METODO)    <> ' ' OR"
cQuery += "            TRIM(MEIOAMB)   <> ' ' OR"
cQuery += "            TRIM(MEDICAO)   <> ' '"
cQuery += "        THEN"                    
cQuery += "          (CASE WHEN TRIM(MAODEOBRA) <> ' ' THEN 'MAO DE OBRA/'   ELSE NULL END||"   
cQuery += "           CASE WHEN TRIM(MATPRIMA)  <> ' ' THEN 'MAT…RIA PRIMA/' ELSE NULL END||"           
cQuery += "           CASE WHEN TRIM(MAQUINA)   <> ' ' THEN 'MAQUINA/'       ELSE NULL END||"
cQuery += "           CASE WHEN TRIM(METODO)    <> ' ' THEN 'METODO/'        ELSE NULL END||"
cQuery += "           CASE WHEN TRIM(MEIOAMB)   <> ' ' THEN 'MEIO AMBIENTE/' ELSE NULL END||"
cQuery += "           CASE WHEN TRIM(MEDICAO)   <> ' ' THEN 'MEDICAO/'       ELSE NULL END)"
cQuery += "         ELSE"
cQuery += "         '            '"
cQuery += "         END) CAUSAS,"
//
cQuery += " DECODE(TPATEND,'R','Reclamacao   ','S','O.M Sugestoes','Observacao') AS TPATEND, "
cQuery += " NUMRNC, DTINCLU, DTFECH "
cQuery += " FROM SIGA.MAPARAC, "+RETSQLNAME("SA1")+" SA1 "
cQuery += " WHERE DELRAC = ' ' "
cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += " AND CLIENTE = A1_COD "
cQuery += " AND UNIDINC = '"+cEmpAnt+"' "
cQuery += " AND FILINC = '"+cFilAnt+"' "
cQuery += " ORDER BY NUMRAC "

MemoWrit("C:\ORTA454_1.SQL",cQuery)

If Select(cAliasRac) > 0
	(cAliasRac)->(dbCloseArea())
EndIf

cArquivo := CriaTrab(aFld,.T.)
dbUseArea(.T.,,cArquivo,cAliasRac,.F.,.F.)
SQLToTrb(cQuery,aFld,cAliasRac)

cInd := CriaTrab(NIL,.F.)

DbSelectArea(cAliasRac)
IndRegua(cAliasRac,cInd,"NUMRAC",,,"Selecionando Registros...")

DbSelectArea(cAliasRac)
dbSetOrder(1)
dbGoTop()
//mBrowse(06,01,22,75,"TRB",aTitulos,,,,,aCores)
mBrowse(06,01,22,75,cAliasRac,aTitulos,,,,,aCores)
//MBrowse(6,1,22,75,cAliasRac,,,,,,aCores)

DbSelectArea(cAliasRac)
dbClearind()
DBCLOSEAREA()

FErase(cArquivo + GetDbExtension())  // Deletando o arquivo

FErase(cArquivo + OrdBagExt())       // Deletando Ìndice     

Return()

**********************************
User Function aRacMov(_nOpcx)
**********************************
Local nOpca		:= 0
Local cQryIt	:= ""
Local cAliasIt	:= GetNextAlias()
Local cQryCab	:= ""
Local cAliasCab	:= GetNextAlias()
Local lTp		:= .T.
Local lProc		:= .T.   
Local lAltAmo	:= .T. //SSI 15677
Local aAdvSize	//SSI 15677
Local aInfoAdvSize //SSI 15677
Local aObjCoords //SSI 15677
Local aMsObjSize //SSI 15677
Private codcli     := Space(6)
Private Ljcli	   := Space(2)
Private comecli    := Space(50)
Private codprod    := Space(15)
Private comeprod   := Space(50)
Private csetor     := Space(30)
Private cvendedor  := Space(6)
Private ccontato   := Space(30)
Private ctelefone  := Space(30)
Private cpedido    := Space(6)
Private cnota	   := Space(9)
Private cacao      := Space(400)
Private cimpress   := Space(100)
Private ccit1      := 0
Private ccit2      := 0
Private ccit3      := 0
Private ccit4      := 0
Private ccit5      := 0
Private ceit1      := 0
Private ceit2      := 0
Private ceit3      := 0
Private ceit4      := 0
Private ceit5      := 0
Private clit1      := 0
Private clit2      := 0
Private clit3      := 0
Private clit4      := 0
Private clit5      := 0
Private cpit1      := Space(10)
Private cpit2      := Space(10)
Private cpit3      := Space(10)
Private cpit4      := Space(10)
Private cpit5      := Space(10)
Private cqit1      := 0
Private cqit2      := 0
Private cqit3      := 0
Private cqit4      := 0
Private cqit5      := 0
Private csit1      := 0
Private csit2      := 0
Private csit3      := 0
Private csit4      := 0
Private csit5      := 0
Private crnc	   := Space(10)
Private dtinc	   := DTOC(ddatabase)
Private _dtfech	   := DTOC(ddatabase)
Private cMconclusa := Space(800)
Private cMdescr	   := Space(500)
Private cMjustifiq := "Justifique"
Private cMobservac := Space(400)
Private nRprocede 
Private nRtipo
private cmao       := Space(400)
private cmateria   := Space(400)
private cmaquina   := Space(400)
private cmetodo    := Space(400)
private cambiente  := Space(400)
private cmedicao   := Space(400)
Private _cNumRac   := IIf(_nOpcx == 3, fBuscaNum(), alltrim((cAliasRac)->NUMRAC))
Private crespon	   := IIf(_nOpcx == 3, Upper(Alltrim(UsrFullName(__cUserId))),Space(100))
Private _aListAnexos	:= {}


/*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±± DeclaraÁ„o de Variaveis Private dos Objetos                             ±±
Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
SetPrvt("oDlg1","oGrp1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oSay10")
SetPrvt("oSay12","oSay13","oSay14","oSay15","oSay16","oSay17","oSay18","oSay19","oSay20","oSay21","oSay22","oSay27")
SetPrvt("oSay24","oSay25","oSay26","ocodcli","oljcli","ocodprod","onomecli","onomeprod","ocpedido","ocvendedor","ocimpress")
SetPrvt("occontato","octel","oRtipo","oMdescr","opit1","opit2","opit3","opit4","opit5","oMobservacoes","odtinc","ocnota")
SetPrvt("oeit2","oeit3","oeit4","oeit5","olit1","olit2","olit3","olit4","olit5","ocit1","ocit2","ocit3","odtfech")
SetPrvt("ocit5","osit1","osit2","osit3","osit4","osit5","oqit5","oqit4","oqit3","oqit2","oqit1","oGrp2","orespon")
SetPrvt("omateria","omaquina","ometodo","oambiente","omedicao","ocacao","oMconclusao","ocrnc","oRprocede","oMjustifique")

lAltAmo := Alltrim(UsrRetName(__cUserId)) $ AllTrim(GetMV("MV_XALTAMO"))

If _nOpcx == 2 .or. _nOpcx == 4 .or. _nOpcx == 5
	
	_aAreaCab := GetArea()
	cQryCab := " SELECT * "
	cQryCab += " FROM SIGA.MAPARAC "
	cQryCab += " WHERE DELRAC = ' ' "
	cQryCab += " AND UNIDINC = '"+cEmpAnt+"' "
	cQryCab += " AND FILINC = '"+cFilAnt+"' "
	cQryCab += " AND NUMRAC = '"+(cAliasRac)->NUMRAC+"' "
	
	MemoWrit("C:\ORTA454_2.SQL",cQryCab)
	
	If Select(cAliasCab) > 0
		(cAliasCab)->(dbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCab),cAliasCab,.T.,.T.)
	
	(cAliasCab)->(dbGoTop())
	If (cAliasCab)->(!EOF())
		
		codcli     := (cAliasCab)->CLIENTE
		Ljcli	   := (cAliasCab)->LOJACLI
		comecli    := Posicione("SA1",1,xFilial("SA1")+(cAliasCab)->CLIENTE+(cAliasCab)->LOJACLI,"A1_NOME")
		codprod    := (cAliasCab)->PRODUTO
		comeprod   := Posicione("SB1",1,xFilial("SB1")+(cAliasCab)->PRODUTO,"B1_DESC")
		csetor     := PADR((cAliasCab)->SETOR,30)
		cvendedor  := (cAliasCab)->VENDEDOR
		ccontato   := PADR((cAliasCab)->CONTATO,30)
		ctelefone  := PADR((cAliasCab)->TELEFONE,30)
		cpedido    := (cAliasCab)->NUMPED
		cnota	   := (cAliasCab)->NOTA
		cacao      := PADR((cAliasCab)->ACAOIMED,400)
		cimpress   := PADR((cAliasCab)->IMPRESSAO,100)
		crnc	   := (cAliasCab)->NUMRNC
		cMconclusa := PADR((cAliasCab)->CONCLUSAO,800)
		cMdescr    := PADR((cAliasCab)->DESCATEND,500)
		cMjustifiq := PADR((cAliasCab)->JUSTIFIC,400)
		cMobservac := PADR((cAliasCab)->OBSERV,400)
		nRprocede  := Iif((cAliasCab)->PROCEDE == 'S', 1, 2)
		nRtipo     := Iif((cAliasCab)->TPATEND=='R',1,Iif((cAliasCab)->TPATEND=='S',2,3))
		cmao       := PADR((cAliasCab)->MAODEOBRA,400)
		cmateria   := PADR((cAliasCab)->MATPRIMA,400)
		cmaquina   := PADR((cAliasCab)->MAQUINA,400)
		cmetodo    := PADR((cAliasCab)->METODO,400)
		cambiente  := PADR((cAliasCab)->MEIOAMB,400)  
		cmedicao   := PADR((cAliasCab)->MEDICAO,400)  
		dtinc	   := STOD((cAliasCab)->DTINCLU)
		_dtfech	   := STOD((cAliasCab)->DTFECH)
		crespon	   := PADR(Alltrim((cAliasCab)->RESPONSAVEL),100)
				
		_aAreaIt := GetArea()
		
		_cQryIt := " SELECT * FROM SIGA.ITMAPARAC "
		_cQryIt += " WHERE DELRAC = ' ' "
		_cQryIt += " AND UNIDINC = '"+cEmpAnt+"' "
		_cQryIt += " AND FILINC = '"+cFilAnt+"' "
		_cQryIt += " AND NUMRAC = '"+(cAliasCab)->NUMRAC+"' "
		_cQryIt += " ORDER BY ITPED "
		
		MemoWrit("C:\ORTA454_3.SQL",_cQryIt)
		
		If Select(cAliasIt) > 0
			(cAliasIt)->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryIt),cAliasIt,.T.,.T.)
		
		(cAliasIt)->(dbGoTop())
		While (cAliasIt)->(!EOF())
			
			If (cAliasIt)->ITPED == "1"
				ccit1      := (cAliasIt)->COMPRIT
				ceit1      := (cAliasIt)->ESPESIT
				clit1      := (cAliasIt)->LARGIT
				cpit1      := (cAliasIt)->NUMPEDIT
				cqit1      := (cAliasIt)->QTDPESIT
				csit1      := (cAliasIt)->SANFIT
			EndIf
			
			If (cAliasIt)->ITPED == "2"
				ccit2      := (cAliasIt)->COMPRIT
				ceit2      := (cAliasIt)->ESPESIT
				clit2      := (cAliasIt)->LARGIT
				cpit2      := (cAliasIt)->NUMPEDIT
				cqit2      := (cAliasIt)->QTDPESIT
				csit2      := (cAliasIt)->SANFIT
			EndIf
			
			If (cAliasIt)->ITPED == "3"
				ccit3      := (cAliasIt)->COMPRIT
				ceit3      := (cAliasIt)->ESPESIT
				clit3      := (cAliasIt)->LARGIT
				cpit3      := (cAliasIt)->NUMPEDIT
				cqit3      := (cAliasIt)->QTDPESIT
				csit3      := (cAliasIt)->SANFIT
			EndIf
			
			If (cAliasIt)->ITPED == "4"
				ccit4      := (cAliasIt)->COMPRIT
				ceit4      := (cAliasIt)->ESPESIT
				clit4      := (cAliasIt)->LARGIT
				cpit4      := (cAliasIt)->NUMPEDIT
				cqit4      := (cAliasIt)->QTDPESIT
				csit4      := (cAliasIt)->SANFIT
			EndIf
			
			If (cAliasIt)->ITPED == "5"
				ccit5      := (cAliasIt)->COMPRIT
				ceit5      := (cAliasIt)->ESPESIT
				clit5      := (cAliasIt)->LARGIT
				cpit5      := (cAliasIt)->NUMPEDIT
				cqit5      := (cAliasIt)->QTDPESIT
				csit5      := (cAliasIt)->SANFIT
			EndIf
			
			(cAliasIt)->(DbSkip())
		EndDo
		RestArea(_aAreaIt)
		
	EndIf
	RestArea(_aAreaCab)
	
EndIf

aAdvSize := MsAdvSize( .T. , .F. ) //SSI 15677
aAdvSize[6]+=100 //SSI 15677
aAdvSize[5] -= 130 //SSI 15677
aInfoAdvSize := { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 } //SSI 15677
aObjCoords := { { 000 , 000 , .T. , .T. } } //SSI 15677
aMsObjSize := MsObjSize( aInfoAdvSize , aObjCoords ) //SSI 15677
nDif := 35
/*ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±± Definicao do Dialog e todos os seus componentes.                        ±±
Ÿ±±¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ*/
oDlg1      := MSDialog():New( aAdvSize[7],aAdvSize[1],aAdvSize[6],aAdvSize[5],"Atendimento ao Cliente",,,.F.,,,,,,.T.,,,.F. )
oDlg1:bInit	:= {||EnchoiceBar(oDlg1,{||nOpca:=1,Iif(_nOpcx == 2 .OR. VldTudo(),oDlg1:End(),nOpca := 0)},{|| nOpca := 3, oDlg1:End()},.F.,aBotao)}

oGrp1      := TGroup():New( nDif+002,002,302+nDif,410," Informe de Atendimento ao Cliente ",oDlg1,CLR_BLUE,CLR_WHITE,.T.,.F. )

oSay1      := TSay():New( nDif+012,007,{||"Cliente:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,029,008)
oSay2      := TSay():New( nDif+027,007,{||"Produto:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,029,008)
oSay3      := TSay():New( nDif+012,222,{||"N. Pedido:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
oSay28     := TSay():New( nDif+012,322,{||"Nota:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008) //SSI 15677
oSay4      := TSay():New( nDif+042,007,{||"Impress„o:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,029,008)
oSay5      := TSay():New( nDif+057,007,{||"Contato:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,029,008)
oSay6      := TSay():New( nDif+027,222,{||"Vendedor:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
oSay7      := TSay():New( nDif+042,222,{||"Setor:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
oSay8      := TSay():New( nDif+057,222,{||"Telefone:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,030,008)
oSay9      := TSay():New( nDif+072,007,{||"DescriÁ„o do Atendimento:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,071,008)
oSay10     := TSay():New( nDif+120,006,{||"ANALISE DAS AMOSTRAS DE EVIDENCIA (quando aplicavel)"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,157,008)
oSay11     := TSay():New( nDif+130,006,{||"Item"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,012,008)
oSay12     := TSay():New( nDif+130,022,{||"Pedido"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
oSay13     := TSay():New( nDif+130,057,{||"Espessura"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oSay14     := TSay():New( nDif+130,105,{||"Largura"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oSay15     := TSay():New( nDif+130,147,{||"Comprimento"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oSay16     := TSay():New( nDif+130,194,{||"Sanfona"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oSay17     := TSay():New( nDif+130,241,{||"Qtd/Peso"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
oSay18     := TSay():New( nDif+120,286,{||"ObservaÁıes:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,112,008)
oSay19     := TSay():New( nDif+141,010,{||"1"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,008,008)
oSay20     := TSay():New( nDif+150,010,{||"2"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,008,008)
oSay21     := TSay():New( nDif+162,010,{||"3"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,008,008)
oSay22     := TSay():New( nDif+174,010,{||"4"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,008,008)
oSay23     := TSay():New( nDif+186,010,{||"5"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,008,008)
oSay24     := TSay():New( nDif+202,065,{||"AÁ„o Imediata (quando aplic·vel)"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,088,008)
oSay25     := TSay():New( nDif+230,065,{||"Conclus„o:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLUE,CLR_WHITE,032,008)

ocodcli    := TGet():New( nDif+012,038,{|u| If(PCount()>0,codcli:=u  ,codcli  )},oGrp1,036,008,'',{||VldRAC1(1)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 3,.F.,.T.),.F.,"SA1","codcli",,)
oljcli     := TGet():New( nDif+012,082,{|u| If(PCount()>0,ljcli:=u  ,ljcli    )},oGrp1,020,008,'',{||VldRAC1(1)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 3,.F.,.T.),.F.,"","ljcli",,)
onomecli   := TGet():New( nDif+012,110,{|u| If(PCount()>0,comecli:=u ,comecli )},oGrp1,102,008,'',			   ,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","comecli",,)
ocpedido   := TGet():New( nDif+012,252,{|u| If(PCount()>0,cpedido:=u,cpedido    )},oGrp1,060,008,'',{||VldRAC1(3)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 3,.F.,.T.),.F.,"PEDRAC","cpedido",,)
ocnota     := TGet():New( nDif+012,342,{|u| If(PCount()>0,cnota:=u,cnota    )},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","cnota",,)
ocodprod   := TGet():New( nDif+027,038,{|u| If(PCount()>0,codprod:=u ,codprod )},oGrp1,044,008,'',{||VldRAC1(2)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 3,.F.,.T.),.F.,"PRORAC","codprod",,)
onomeprod  := TGet():New( nDif+026,090,{|u| If(PCount()>0,comeprod:=u,comeprod)},oGrp1,122,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","comeprod",,)

ocvendedor := TGet():New( nDif+027,252,{|u| If(PCount()>0,cvendedor:=u,cvendedor)},oGrp1,060,008,'',{||VldRAC1(4)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 3,.F.,.T.),.F.,"SA3","cvendedor",,)
oanexo       := TButton():New( nDif+027,350,"Anexar"  ,oGrp1,{|| IIf(!Empty(cpedido),fAnexa(_nOpcx),MsgBox("N⁄MERO DO PEDIDO N√O INFORMADO.","ATENCAO")) },050,012,,,,.T.,,"",,,,.F. )

ocimpress  := TGet():New( nDif+042,038,{|u| If(PCount()>0,cimpress:=u,cimpress  )},oGrp1,175,008,'',{||VldRAC1(5)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 3,.F.,.T.),.F.,"","cimpress",,)
ocsetor    := TGet():New( nDif+042,252,{|u| If(PCount()>0,csetor:=u,csetor      )},oGrp1,100,008,'',{||VldRAC1(6)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 3 .OR. _nOpcx == 4,.F.,.T.),.F.,"","csetor",,) //SSI 15667
occontato  := TGet():New( nDif+057,038,{|u| If(PCount()>0,ccontato:=u,ccontato  )},oGrp1,175,008,'',{||VldRAC1(7)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 3 .OR. _nOpcx == 4,.F.,.T.),.F.,"","ccontato",,) //SSI 15667
octel      := TGet():New( nDif+057,252,{|u| If(PCount()>0,ctelefone:=u,ctelefone)},oGrp1,100,008,'',{||VldRAC1(8)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 3 .OR. _nOpcx == 4,.F.,.T.),.F.,"","ctelefone",,) //SSI 15667

GoRtipo    := TGroup():New(   nDif+072,272,114+nDif,364," Tipo de Atendimento ",oGrp1,CLR_BLACK,CLR_WHITE,.T.,.F. )
oRtipo     := TRadMenu():New( nDif+082,278,{"Reclamacao","O.M Sugestoes","Observacao"},{|u| If(PCount()>0,nRtipo:=u,nRtipo)},oGrp1,,,CLR_BLACK,CLR_WHITE,"",,,072,14,,.F.,.F.,.T. )

lTp := !(_nOpcx == 2 .or. _nOpcx == 5)
oRtipo:EnableItem(1,lTp)
oRtipo:EnableItem(2,lTp)
oRtipo:EnableItem(3,lTp)

oMdescr    := TMultiGet():New( nDif+082,007,{|u| If(PCount()>0,cMdescr:=u,cMdescr)},oGrp1,207,032,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5, .T., .F.),{|| VldRAC1(9)},,.F.,,,,)

opit1      := TGet():New( nDif+141,022,{|u| If(PCount()>0,cpit1:=u,cpit1)},oGrp1,032,008,''		   ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cpit1",,)
oeit1      := TGet():New( nDif+141,057,{|u| If(PCount()>0,ceit1:=u,ceit1)},oGrp1,025,008,'@E 9.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","ceit1",,)
olit1      := TGet():New( nDif+141,105,{|u| If(PCount()>0,clit1:=u,clit1)},oGrp1,025,008,'@E 9.999' ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","clit1",,)
ocit1      := TGet():New( nDif+141,147,{|u| If(PCount()>0,ccit1:=u,ccit1)},oGrp1,025,008,'@E 9.999' ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","ccit1",,)
osit1      := TGet():New( nDif+141,194,{|u| If(PCount()>0,csit1:=u,csit1)},oGrp1,025,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","csit1",,)
oqit1      := TGet():New( nDif+141,241,{|u| If(PCount()>0,cqit1:=u,cqit1)},oGrp1,030,008,'@E 999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cqit1",,)

opit2      := TGet():New( nDif+152,022,{|u| If(PCount()>0,cpit2:=u,cpit2)},oGrp1,032,008,''		   ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cpit2",,)
oeit2      := TGet():New( nDif+152,057,{|u| If(PCount()>0,ceit2:=u,ceit2)},oGrp1,025,008,'@E 9.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","ceit2",,)
olit2      := TGet():New( nDif+152,105,{|u| If(PCount()>0,clit2:=u,clit2)},oGrp1,025,008,'@E 9.999' ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","clit2",,)
ocit2      := TGet():New( nDif+152,147,{|u| If(PCount()>0,ccit2:=u,ccit2)},oGrp1,025,008,'@E 9.999' ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","ccit2",,)
osit2      := TGet():New( nDif+152,194,{|u| If(PCount()>0,csit2:=u,csit2)},oGrp1,025,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","csit2",,)
oqit2      := TGet():New( nDif+152,241,{|u| If(PCount()>0,cqit2:=u,cqit2)},oGrp1,030,008,'@E 999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cqit2",,)

opit3      := TGet():New( nDif+163,022,{|u| If(PCount()>0,cpit3:=u,cpit3)},oGrp1,032,008,''         ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cpit3",,)
oeit3      := TGet():New( nDif+163,057,{|u| If(PCount()>0,ceit3:=u,ceit3)},oGrp1,025,008,'@E 9.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","ceit3",,)
olit3      := TGet():New( nDif+163,105,{|u| If(PCount()>0,clit3:=u,clit3)},oGrp1,025,008,'@E 9.999' ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","clit3",,)
ocit3      := TGet():New( nDif+163,147,{|u| If(PCount()>0,ccit3:=u,ccit3)},oGrp1,025,008,'@E 9.999' ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","ccit3",,)
osit3      := TGet():New( nDif+163,194,{|u| If(PCount()>0,csit3:=u,csit3)},oGrp1,025,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","csit3",,)
oqit3      := TGet():New( nDif+163,241,{|u| If(PCount()>0,cqit3:=u,cqit3)},oGrp1,030,008,'@E 999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cqit3",,)

opit4      := TGet():New( nDif+174,022,{|u| If(PCount()>0,cpit4:=u,cpit4)},oGrp1,032,008,''         ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cpit4",,)
oeit4      := TGet():New( nDif+174,057,{|u| If(PCount()>0,ceit4:=u,ceit4)},oGrp1,025,008,'@E 9.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","ceit4",,)
olit4      := TGet():New( nDif+174,105,{|u| If(PCount()>0,clit4:=u,clit4)},oGrp1,025,008,'@E 9.999' ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","clit4",,)
ocit4      := TGet():New( nDif+174,147,{|u| If(PCount()>0,ccit4:=u,ccit4)},oGrp1,025,008,'@E 9.999' ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","ccit4",,)
osit4      := TGet():New( nDif+174,194,{|u| If(PCount()>0,csit4:=u,csit4)},oGrp1,025,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","csit4",,)
oqit4      := TGet():New( nDif+174,241,{|u| If(PCount()>0,cqit4:=u,cqit4)},oGrp1,030,008,'@E 999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cqit4",,)

opit5      := TGet():New( nDif+185,022,{|u| If(PCount()>0,cpit5:=u,cpit5)},oGrp1,032,008,''         ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cpit5",,)
oeit5      := TGet():New( nDif+185,057,{|u| If(PCount()>0,ceit5:=u,ceit5)},oGrp1,025,008,'@E 9.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","ceit5",,)
olit5      := TGet():New( nDif+185,105,{|u| If(PCount()>0,clit5:=u,clit5)},oGrp1,025,008,'@E 9.999' ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","clit5",,)
ocit5      := TGet():New( nDif+185,147,{|u| If(PCount()>0,ccit5:=u,ccit5)},oGrp1,025,008,'@E 9.999' ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","ccit5",,)
osit5      := TGet():New( nDif+185,194,{|u| If(PCount()>0,csit5:=u,csit5)},oGrp1,025,008,'@E 999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","csit5",,)
oqit5      := TGet():New( nDif+185,241,{|u| If(PCount()>0,cqit5:=u,cqit5)},oGrp1,030,008,'@E 999,999.9999',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cqit5",,)

oMobservac := TMultiGet():New( nDif+132,286,{|u| If(PCount()>0,cMobservacoes:=u,cMobservacoes)},oGrp1,110,038,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),{|| VldRAC1(10)},,.F.,,  )

oGrp2      := TGroup():New(  nDif+198,006,296+nDif,060," Causas ",oGrp1,CLR_BLUE,CLR_WHITE,.T.,.F. )
omao       := TButton():New( nDif+207,009,"Mao de Obra"  ,oGrp2,{|| memoGet(@cmao     , "Mao de Obra"  , _nOpcx) },045,012,,,,.T.,,"",,,,.F. )
omateria   := TButton():New( nDif+222,009,"Materia Prima",oGrp2,{|| memoGet(@cmateria , "Materia Prima", _nOpcx) },045,012,,,,.T.,,"",,,,.F. )
omaquina   := TButton():New( nDif+237,009,"Maquina"		,oGrp2,{|| memoGet(@cmaquina , "Maquina"      , _nOpcx) },045,012,,,,.T.,,"",,,,.F. )
ometodo    := TButton():New( nDif+252,009,"Metodo"		,oGrp2,{|| memoGet(@cmetodo  , "Metodo"       , _nOpcx) },045,012,,,,.T.,,"",,,,.F. )
oambiente  := TButton():New( nDif+267,009,"Meio Ambiente",oGrp2,{|| memoGet(@cambiente, "Meio Ambiente", _nOpcx) },045,012,,,,.T.,,"",,,,.F. )
omedicao   := TButton():New( nDif+282,009,"Medicao      ",oGrp2,{|| memoGet(@cmedicao , "Medicao"      , _nOpcx) },045,012,,,,.T.,,"",,,,.F. )

ocacao     := TGet():New(      nDif+214,065,{|u|If(PCount()>0,cacao:=u      ,cacao      )},oGrp1,200,008,'',{|| VldRAC1(12)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","cacao",,)
oMconclusa := TMultiGet():New( nDif+242,065,{|u|If(PCount()>0,cMconclusa:=u,cMconclusa)},oGrp1,200,038,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),{|| VldRAC1(11)},,.F.,,  )

oSay27     := TSay():New( nDif+172,286,{||"Data Inclus„o:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
odtinc	   := TGet():New( nDif+172,330,{|u| If(PCount()>0,dtinc:=u,dtinc    )},oGrp1,060,008,'99/99/99',,CLR_BLUE,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","dtinc",,)

oSay29     := TSay():New( nDif+192,286,{||"Data Fechamento:"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
odtfech	   := TGet():New( nDif+192,330,{|u| If(PCount()>0,_dtfech:=u,_dtfech    )},oGrp1,060,008,'99/99/99',,CLR_BLUE,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","_dtfech",,)

oSay26     := TSay():New( nDif+212,286,{||"Registrar RNC?"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
ocrnc	   := TGet():New( nDif+212,330,{|u| If(PCount()>0,crnc:=u,crnc    )},oGrp1,060,008,'',,CLR_BLUE,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","crnc",,)

GoRprocede := TGroup():New(   nDif+230,271,262+nDif,359," Procede? ",oGrp1,CLR_BLUE,CLR_WHITE,.T.,.F. )
oRprocede  := TRadMenu():New( nDif+240,277,{"Procede","Nao Procede"},{|u| If(PCount()>0,nRprocede:=u,nRprocede)},oGrp1,,{|| iif(nRprocede == 1, cMjustifiq:="",)},CLR_BLUE,CLR_WHITE,"",,,088,16,,.F.,.F.,.T. )

lProc := !(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo)
oRprocede:EnableItem(1,lProc)
oRprocede:EnableItem(2,lProc)

oMjustifiq := TMultiGet():New( nDif+266,271,{|u| If(PCount()>0,cMjustifiq:=u,cMjustifiq)},oGrp1,108,034,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,,!lProc,{|| VldRAC2()},,.F.,,  )

oSay30     := TSay():New( nDif+283,065,{||"Respons·vel: "},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,008)
orespon	   := TGet():New( nDif+290,065,{|u| If(PCount()>0,crespon:=u,crespon    )},oGrp1,100,008,'',,CLR_BLUE,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,IIF(_nOpcx == 2 .or. _nOpcx == 5 .or. !lAltAmo, .T., .F.),.F.,"","crespon",,)
oSay30     := TSay():New( nDif+290,185,{||"Setor: Controle de Qualidade"},oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,080,008)

oDlg1:Activate(,,,.T.) 

If nOpca == 1 .AND. _nOpcx == 3
	
	fGrvDad() 
		
ElseIf nOpca == 1 .AND. _nOpcx == 4
	
	fAltDad()
		
ElseIf nOpca == 1 .AND. _nOpcx == 5
	
	fExcDad()
		
ElseIf nOpca == 3 .AND. _nOpcx == 3

	_cAltArq := " UPDATE SIGA.ANEXORAC "
	_cAltArq += " SET 	DELREG = '*' "
	_cAltArq += " WHERE	DELREG <> '*' "
	_cAltArq += " AND	UNIDINC = '"+cEmpAnt+"' "
	_cAltArq += " AND	FILINC = '"+cFilAnt+"' "
	_cAltArq += " AND 	NUMRAC = '"+_cNumRac+"' "

	TcSqlExec(_cAltArq)
	TcSqlExec('commit')      
	
EndIf

Return

**********************************
Static Function memoGet(_cMemo, cTitulo, _nOp)
**********************************
Local memofield := _cMemo
Default cTitulo := "Preenchimento de Campo"
SetPrvt("oDlg2","oGrp1","oMGet1","oBsv","oBcn")

oDlg2      := MSDialog():New( 088,232,274,507,cTitulo,,,.F.,,,,,,.T.,,,.T. )
oGrp1      := TGroup():New( 002,002,090,134,"",oDlg2,CLR_BLACK,CLR_WHITE,.T.,.F. )
oMGet1     := TMultiGet():New( 007,004,{|u| If(PCount()>0,memofield:=u,memofield)},oGrp1,126,063,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,Iif(_nOp == 2 .or. _nOp == 5,.T.,.F.),{|| VldMemo(memofield)},,.F.,,  )
oBsv       := TButton():New( 074,004,"Salvar"  ,oGrp1,{|| _cMemo := SUBSTR(Alltrim(memofield),1,400), oDlg2:end() },037,012,,,,.T.,,"",,,,.F. )
oBcn       := TButton():New( 074,094,"Cancelar",oGrp1,{|| oDlg2:end() },037,012,,,,.T.,,"",,,,.F. )

oDlg2:Activate(,,,.T.)

Return

**********************************
Static Function VldMemo(_InfMemo)
**********************************
Local _lRet := .T.

If !Empty(Alltrim(_InfMemo)) .and. len(Alltrim(_InfMemo)) > 400    
	nlen := len(Alltrim(_InfMemo))
	MsgAlert("O Campo n„o pode ter mais de 400 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
	_lRet := .F.     
EndIf

Return _lRet

**********************************
* Gravar as informaÁıes			 *
**********************************
Static Function fGrvDad()
**********************************
Local _cIncRac 		:= ""
Local _cIncItRac	:= ""
Local _aAreaInc 	:= GetArea()

_cIncRac := " INSERT INTO SIGA.MAPARAC( "
_cIncRac += "			UNIDINC,"
_cIncRac += "			FILINC,"
_cIncRac += "			NUMRAC,"
_cIncRac += "			CLIENTE,"
_cIncRac += "			LOJACLI,"
_cIncRac += "			PRODUTO,"
_cIncRac += "			NUMPED,"
_cIncRac += "			IMPRESSAO,"
_cIncRac += "			CONTATO,"
_cIncRac += "			VENDEDOR,"
_cIncRac += "			SETOR,"
_cIncRac += "			TELEFONE,"
_cIncRac += "			DESCATEND,"
_cIncRac += "			OBSERV,"
_cIncRac += "			TPATEND,"
_cIncRac += "			NUMRNC,"
_cIncRac += "			MAODEOBRA,"
_cIncRac += "			MATPRIMA,"
_cIncRac += "			MAQUINA,"
_cIncRac += "			METODO,"
_cIncRac += "			MEIOAMB,"
_cIncRac += "			MEDICAO,"
_cIncRac += "			ACAOIMED,"
_cIncRac += "			CONCLUSAO,"
_cIncRac += "			PROCEDE,"
_cIncRac += "			JUSTIFIC,"
_cIncRac += "			DTINCLU,"
_cIncRac += "			USERINC,"
_cIncRac += "			HORAINC,"
_cIncRac += "			DTALT,"
_cIncRac += "			USERALT,"
_cIncRac += "			HORAALT,"
_cIncRac += "			NOTA,"
_cIncRac += "			RESPONSAVEL,"
_cIncRac += "			DTFECH,"
_cIncRac += "			DELRAC )"
_cIncRac += "		VALUES ("
_cIncRac += "		'"	+cEmpAnt+	"',"
_cIncRac += "		'"	+cFilAnt+	"',"
_cIncRac += "		'"	+_cNumRac+	"',"
_cIncRac += "		'"	+codcli+	"',"
_cIncRac += "		'"	+Ljcli+		"',"
_cIncRac += "		'"	+codprod+	"',"
_cIncRac += "		'"	+cpedido+	"',"
_cIncRac += "		'"	+U_SANITIZE(cimpress)+	"',"
_cIncRac += "		'"	+ccontato+	"',"
_cIncRac += "		'"	+cvendedor+	"',"
_cIncRac += "		'"	+csetor+	"',"
_cIncRac += "		'"	+ctelefone+	"',"
_cIncRac += "		'"	+U_SANITIZE(Iif(Empty(alltrim(cMdescr)),Space(500),alltrim(cMdescr)))+	"',"
_cIncRac += "		'"	+Iif(Empty(alltrim(cMobservac)),Space(400),alltrim(cMobservac))+"',"
_cIncRac += "		'"	+Iif(nRtipo==1,'R',Iif(nRtipo==2,'S','E'))+"',"
_cIncRac += "		'"	+crnc+		"',"
_cIncRac += "		'"	+Iif(Empty(alltrim(cmao)),Space(400),alltrim(cmao))+"',"
_cIncRac += "		'"	+Iif(Empty(alltrim(cmateria)),Space(400),alltrim(cmateria))+"',"
_cIncRac += "		'"	+Iif(Empty(alltrim(cmaquina)),Space(400),alltrim(cmaquina))+"',"
_cIncRac += "		'"	+Iif(Empty(alltrim(cmetodo)),Space(400),alltrim(cmetodo))+"',"
_cIncRac += "		'"	+Iif(Empty(alltrim(cambiente)),Space(400),alltrim(cambiente))+"',"
_cIncRac += "		'"	+Iif(Empty(alltrim(cmedicao)),Space(400),alltrim(cmedicao))+"',"
_cIncRac += "		'"	+Iif(Empty(alltrim(cacao)),Space(400),alltrim(cacao))+		"',"
_cIncRac += "		'"	+Iif(Empty(alltrim(cMconclusa)),Space(800),alltrim(cMconclusa))+"',"
_cIncRac += "		'"	+Iif(nRprocede==1,'S','N')+	"',"
_cIncRac += "		'"	+Iif(alltrim(cMjustifiq) == "Justifique" .OR. Empty(alltrim(cMjustifiq)), Space(400), alltrim(cMjustifiq))+"',"
_cIncRac += "		'"	+DTOS(CTOD(dtinc))+"',"
_cIncRac += "		'"	+__cuserid+	"',"
_cIncRac += "		'"	+time()+	"',"
_cIncRac += "		'"	+Space(8)+	"',"
_cIncRac += "		'"	+Space(10)+	"',"
_cIncRac += "		'"	+Space(8)+	"',"
_cIncRac += "		'"	+cnota+	"',"
_cIncRac += "		'"	+cRespon+	"',"
_cIncRac += "		'"	+DTOS(CTOD(_dtfech))+	"',"
_cIncRac += "		'"	+Space(1)+"' )"

TcSqlExec(_cIncRac)
TcSqlExec('commit')

For _nit := 1 to 5
	
	_Itm1	:= "cpit"+alltrim(str(_nit))
	_Itm2	:= "ceit"+alltrim(str(_nit))
	_Itm3	:= "clit"+alltrim(str(_nit))
	_Itm4	:= "ccit"+alltrim(str(_nit))
	_Itm5	:= "csit"+alltrim(str(_nit))
	_Itm6	:= "cqit"+alltrim(str(_nit))
	
	_cPedido 	:= &_Itm1
	_nEspess	:= &_Itm2
	_nLarg		:= &_Itm3
	_nCompr		:= &_Itm4
	_nSanfo		:= &_Itm5
	_nQtdPes	:= &_Itm6
	
	If !Empty(_cPedido)
	
		_cIncItRac := " INSERT INTO SIGA.ITMAPARAC( "
		_cIncItRac += "			UNIDINC,"
		_cIncItRac += "			FILINC,"
		_cIncItRac += "			NUMRAC,"
		_cIncItRac += "			ITPED,"
		_cIncItRac += "			NUMPEDIT,"
		_cIncItRac += "			ESPESIT,"
		_cIncItRac += "			LARGIT,"
		_cIncItRac += "			COMPRIT,"
		_cIncItRac += "			SANFIT,"
		_cIncItRac += "			QTDPESIT,"
		_cIncItRac += "			DTINCLU,"
		_cIncItRac += "			USERINC,"
		_cIncItRac += "			HORAINC,"
		_cIncItRac += "			DTALT,"
		_cIncItRac += "			USERALT,"
		_cIncItRac += "			HORAALT,"
		_cIncItRac += "			DELRAC )"
		_cIncItRac += "		VALUES ("
		_cIncItRac += "		'"	+cEmpAnt+	"',"
		_cIncItRac += "		'"	+cFilAnt+	"',"
		_cIncItRac += "		'"	+_cNumRac+	"',"
		_cIncItRac += "		'"	+alltrim(str(_nit))+	"',"
		_cIncItRac += "		'"	+alltrim(_cPedido)+	"',"
		_cIncItRac += "		 "	+alltrim(str(_nEspess))+	" ,"
		_cIncItRac += "		 "	+alltrim(str(_nLarg))+	" ,"
		_cIncItRac += "		 "	+alltrim(str(_nCompr))+	" ,"
		_cIncItRac += "		 "	+alltrim(str(_nSanfo))+	" ,"
		_cIncItRac += "		 "	+alltrim(str(_nQtdPes))+  " ,"
		_cIncItRac += "		'"	+DTOS(CTOD(dtinc))+"',"
		_cIncItRac += "		'"	+__cuserid+	"',"
		_cIncItRac += "		'"	+time()+	"'"
		_cIncItRac += "		'"	+Space(8)+	"',"
		_cIncItRac += "		'"	+Space(10)+	"',"
		_cIncItRac += "		'"	+Space(8)+	"', "
		_cIncItRac += "		'"	+Space(1)+	"' )"
		
		TcSqlExec(_cIncItRac)
		TcSqlExec('commit')
		
		_cProduto 	:= ""
		_nEspess	:= 0
		_nLarg		:= 0
		_nCompr		:= 0
		_nSanfo		:= 0
		_nQtdPes	:= 0   
				
	EndIf

Next        

RestArea(_aAreaInc)

DbSelectArea(cAliasRac)
RecLock(cAliasRac,.T.)

(cAliasRac)->NUMRAC		:= _cNumRac
(cAliasRac)->CLIENTE	:= codcli
(cAliasRac)->LOJACLI 	:= Ljcli
(cAliasRac)->PRODUTO	:= codprod
(cAliasRac)->NUMPED 	:= cpedido
(cAliasRac)->VENDEDOR	:= cvendedor
(cAliasRac)->SETOR		:= csetor
(cAliasRac)->TPATEND 	:= Iif(nRtipo==1,'R',Iif(nRtipo==2,'S','E'))	
(cAliasRac)->NUMRNC 	:= crnc	
(cAliasRac)->(MsUnLock())  

Return

**********************************
* Alterar as informaÁıes		 *
**********************************
Static Function fAltDad()
**********************************
Local _aAreaAlt		:= GetArea()
Local _cAltRac 		:= ""
Local _cAltItRac	:= ""
Local _cIncItRac	:= ""
Local _cSelIt		:= ""
Local _cAlisSelIt	:= GetNextAlias()


_cAltRac := " UPDATE SIGA.MAPARAC "
_cAltRac += " SET 	DESCATEND = '"+Iif(Empty(alltrim(cMdescr)),Space(500),alltrim(cMdescr))+"', "
_cAltRac += "	  	OBSERV = '"+Iif(Empty(alltrim(cMobservac)),Space(400),alltrim(cMobservac))+"', "
_cAltRac += "		MATPRIMA = '"+Iif(Empty(alltrim(cmateria)),Space(400),alltrim(cmateria))+"', "
_cAltRac += "	  	MAODEOBRA = '"+Iif(Empty(alltrim(cmao)),Space(400),alltrim(cmao))+"', "
_cAltRac += "		MAQUINA = '"+Iif(Empty(alltrim(cmaquina)),Space(400),alltrim(cmaquina))+"', "
_cAltRac += "		METODO = '"+Iif(Empty(alltrim(cmetodo)),Space(400),alltrim(cmetodo))+"', "
_cAltRac += "		MEIOAMB = '"+Iif(Empty(alltrim(cambiente)),Space(400),alltrim(cambiente))+"', "
_cAltRac += "		MEDICAO = '"+Iif(Empty(alltrim(cmedicao)),Space(400),alltrim(cmedicao))+"', "
_cAltRac += "		ACAOIMED = '"+Iif(Empty(alltrim(cacao)),Space(400),alltrim(cacao))+"', "
_cAltRac += "		CONCLUSAO = '"+Iif(Empty(alltrim(cMconclusa)),Space(800),alltrim(cMconclusa))+"', "
_cAltRac += "		JUSTIFIC = '"+Iif(Empty(alltrim(cMjustifiq)),Space(400),alltrim(cMjustifiq))+"', "
_cAltRac += "		DTALT = '"+DTOS(ddatabase)+"', "
_cAltRac += "		USERALT = '"+__cuserid+"', "
_cAltRac += "		HORAALT = '"+time()+"', "  
_cAltRac += "		SETOR = '"+csetor+"', "  
_cAltRac += "		CONTATO = '"+ccontato+"', "  
_cAltRac += "		TELEFONE = '"+ctelefone+"', "  
_cAltRac += "		TPATEND = '"+Iif(nRtipo==1,'R',Iif(nRtipo==2,'S','E'))+"', "  
_cAltRac += "		DTINCLU = '"+DTOS(dtinc)+"', "  
_cAltRac += "		DTFECH = '"+DTOS(_dtfech)+"', "  
_cAltRac += "		RESPONSAVEL = '"+crespon+"', "  
_cAltRac += "		NUMRNC = '"+crnc+"', "  
_cAltRac += "		PROCEDE = '"+Iif(nRprocede==1,'S','N')+ "'"
_cAltRac += " WHERE DELRAC <> '*' "
_cAltRac += " AND UNIDINC = '"+cEmpAnt+"' "
_cAltRac += " AND FILINC = '"+cFilAnt+"' "
_cAltRac += " AND NUMRAC = '"+_cNumRac+"' "

TcSqlExec(_cAltRac)
TcSqlExec('commit')

For _nit := 1 to 5
	
	_Itm1	:= "cpit"+alltrim(str(_nit))
	_Itm2	:= "ceit"+alltrim(str(_nit))
	_Itm3	:= "clit"+alltrim(str(_nit))
	_Itm4	:= "ccit"+alltrim(str(_nit))
	_Itm5	:= "csit"+alltrim(str(_nit))
	_Itm6	:= "cqit"+alltrim(str(_nit))
	
	_cPedido 	:= &_Itm1
	_nEspess	:= &_Itm2
	_nLarg		:= &_Itm3
	_nCompr		:= &_Itm4
	_nSanfo		:= &_Itm5
	_nQtdPes	:= &_Itm6
	
	If !Empty(_cPedido)
		
		
		_cSelIt := " SELECT * FROM SIGA.ITMAPARAC "
		_cSelIt += " WHERE DELRAC = ' ' "
		_cSelIt += " AND UNIDINC = '"+cEmpAnt+"' "
		_cSelIt += " AND FILINC = '"+cFilAnt+"' "
		_cSelIt += " AND NUMRAC = '"+_cNumRac+"' "
		_cSelIt += " AND ITPED = '"+alltrim(str(_nit))+"' "
		
		MemoWrit("C:\ORTA454_4.SQL",_cSelIt)
		
		If Select(_cAlisSelIt) > 0
			(_cAlisSelIt)->(dbCloseArea())
		EndIf
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSelIt),_cAlisSelIt,.T.,.T.)
		
		(_cAlisSelIt)->(dbGoTop())
		If (_cAlisSelIt)->(!EOF())
			
			_cAltItRac := " UPDATE SIGA.ITMAPARAC "
			_cAltItRac += "	SET		ESPESIT = "+alltrim(str(_nEspess))+" , "
			_cAltItRac += "			LARGIT = "+alltrim(str(_nLarg))+" , "
			_cAltItRac += "			COMPRIT = "+alltrim(str(_nCompr))+" , "
			_cAltItRac += "			SANFIT = "+alltrim(str(_nSanfo))+" , "
			_cAltItRac += "			QTDPESIT = "+alltrim(str(_nQtdPes))+ " , "
			_cAltItRac += "			DTALT = '"+DTOS(ddatabase)+"', "
			_cAltItRac += "			USERALT = '"+__cuserid+"', "
			_cAltItRac += "			HORAALT = '"+time()+"' "
			_cAltItRac += " WHERE	DELRAC <> '*' "
			_cAltItRac += " AND		UNIDINC = '"+cEmpAnt+"' "
			_cAltItRac += "	AND		FILINC = '"+cFilAnt+"' "
			_cAltItRac += "	AND		NUMRAC = '"+_cNumRac+"' "
			_cAltItRac += "	AND		ITPED = '"+alltrim(str(_nit))+"' "
			
			TcSqlExec(_cAltItRac)
			TcSqlExec('commit')
			
		Else
			
			_cIncItRac := " INSERT INTO SIGA.ITMAPARAC( "
			_cIncItRac += "			UNIDINC,"
			_cIncItRac += "			FILINC,"
			_cIncItRac += "			NUMRAC,"
			_cIncItRac += "			ITPED,"
			_cIncItRac += "			NUMPEDIT,"
			_cIncItRac += "			ESPESIT,"
			_cIncItRac += "			LARGIT,"
			_cIncItRac += "			COMPRIT,"
			_cIncItRac += "			SANFIT,"
			_cIncItRac += "			QTDPESIT,"
			_cIncItRac += "			DTINCLU,"
			_cIncItRac += "			USERINC,"
			_cIncItRac += "			HORAINC,"
			_cIncItRac += "			DTALT,"
			_cIncItRac += "			USERALT,"
			_cIncItRac += "			HORAALT,"
			_cIncItRac += "			DELRAC )"
			_cIncItRac += "		VALUES ("
			_cIncItRac += "		'"	+cEmpAnt+	"',"
			_cIncItRac += "		'"	+cFilAnt+	"',"
			_cIncItRac += "		'"	+_cNumRac+	"',"
			_cIncItRac += "		'"	+alltrim(str(_nit))+"',"
			_cIncItRac += "		'"	+alltrim(_cPedido)+"',"
			_cIncItRac += "		 "	+alltrim(str(_nEspess))+" ,"
			_cIncItRac += "		 "	+alltrim(str(_nLarg))+" ,"
			_cIncItRac += "		 "	+alltrim(str(_nCompr))+" ,"
			_cIncItRac += "		 "	+alltrim(str(_nSanfo))+" ,"
			_cIncItRac += "		 "	+alltrim(str(_nQtdPes))+" ,"
			_cIncItRac += "		'"	+DTOS(dtinc)+"',"
			_cIncItRac += "		'"	+__cuserid+	"' ,"
			_cIncItRac += "		'"	+time()+	"' ,"
			_cIncItRac += "		'"	+Space(8)+	"' ,"
			_cIncItRac += "		'"	+Space(10)+	"' ,"
			_cIncItRac += "		'"	+Space(8)+	"' ,"
			_cIncItRac += "		'"	+Space(1)+	"' )"
			
			TcSqlExec(_cIncItRac)
			TcSqlExec('commit')
			
		EndIf
		
	EndIf
	
	_cProduto 	:= ""
	_nEspess	:= 0
	_nLarg		:= 0
	_nCompr		:= 0
	_nSanfo		:= 0
	_nQtdPes	:= 0
	
Next

RestArea(_aAreaAlt)      

DbSelectArea(cAliasRac)
RecLock(cAliasRac,.F.)
(cAliasRac)->NUMRNC 	:= crnc	
(cAliasRac)->(MsUnLock())  

Return

**********************************
* excluir as informaÁıes		 *
**********************************
Static Function fExcDad()
**********************************
Local _aAreaExc		:= GetArea()
Local _cExcRac 		:= ""
Local _cExcItRac	:= ""

_cExcRac := " UPDATE SIGA.MAPARAC "
_cExcRac += " SET 	DELRAC = '*' "
_cExcRac += " WHERE DELRAC <> '*' "
_cExcRac += " AND UNIDINC = '"+cEmpAnt+"' "
_cExcRac += " AND FILINC = '"+cFilAnt+"' "
_cExcRac += " AND NUMRAC = '"+_cNumRac+"' "

TcSqlExec(_cExcRac)
TcSqlExec('commit')

_cExcItRac := " UPDATE SIGA.ITMAPARAC "
_cExcItRac += "	SET		DELRAC = '*' "
_cExcItRac += " WHERE	DELRAC <> '*' "
_cExcItRac += " AND		UNIDINC = '"+cEmpAnt+"' "
_cExcItRac += "	AND		FILINC = '"+cFilAnt+"' "
_cExcItRac += "	AND		NUMRAC = '"+_cNumRac+"' "

TcSqlExec(_cExcItRac)
TcSqlExec('commit')      

_cAltArq := " UPDATE SIGA.ANEXORAC "
_cAltArq += " SET 	DELREG = '*' "
_cAltArq += " WHERE	DELREG <> '*' "
_cAltArq += " AND	UNIDINC = '"+cEmpAnt+"' "
_cAltArq += " AND	FILINC = '"+cFilAnt+"' "
_cAltArq += " AND 	NUMRAC = '"+_cNumRac+"' "

TcSqlExec(_cAltArq)
TcSqlExec('commit')      

RestArea(_aAreaExc)

DbSelectArea(cAliasRac)	
RecLock(cAliasRac,.F.)
(cAliasRac)->(DbDelete())
(cAliasRac)->(MsUnLock())

Return

**********************************
*   ValidaÁ„o de Campos	 		 *
**********************************
Static Function VldRAC1(_ncP)
**********************************
Local _lRet := .T.

Do Case
	Case _ncP == 1
		
		If Empty(alltrim(codcli))
			MsgBox("C”DIGO DO CLIENTE N√O INFORMADO.","ATENCAO")
			_lRet := .F.
		Else
			_aAreaA1 := GetArea()
			DbSelectArea("SA1")
			DbSetOrder(1)
			If Empty(ljcli)
				_lAchou := !DbSeek(xFilial("SA1")+padr(alltrim(codcli),TamSx3("A1_COD")[1]))
			Else
				_lAchou := !DbSeek(xFilial("SA1")+padr(alltrim(codcli),TamSx3("A1_COD")[1])+ljcli)
			EndIf
			If _lAchou
				MsgBox("C”DIGO DO CLIENTE N√O EXISTE.","ATENCAO")
				_lRet := .F.
			Else
				If Empty(ljcli)
					ljcli := SA1->A1_LOJA
				EndIf
				comecli := SA1->A1_NOME //Posicione("SA1",1,xFilial("SA1")+padr(alltrim(codcli),TamSx3("A1_COD")[1])+ljcli,"A1_NOME")
			EndIf
			RestArea(_aAreaA1)
		EndIf
		
	Case _ncP == 2
		
		If Empty(alltrim(codprod))
			MsgBox("C”DIGO DO PRODUTO N√O INFORMADO.","ATENCAO")
			_lRet := .F.
		Else
			_aAreaB1 := GetArea()
			DbSelectArea("SB1")
			DbSetOrder(1)
			If !Dbseek(xFilial("SB1")+alltrim(codprod))
				MsgBox("C”DIGO DO PRODUTO N√O EXISTE.","ATENCAO")
				_lRet := .F.
			Else
				comeprod := SB1->B1_DESC //Posicione("SB1",1,xFilial("SB1")+alltrim(codprod),"B1_DESC")
			EndIf
			Restarea(_aAreaB1)
		EndIf
		
	Case _ncP == 3
		
		If Empty(alltrim(cpedido))
			MsgBox("N⁄MERO DO PEDIDO N√O INFORMADO.","ATENCAO")
			_lRet := .F.
		Else
			cnota := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_NOTA")
			cvendedor := Posicione("SC5",1,xFilial("SC5")+cPedido,"C5_VEND1")
		EndIf
		
	Case _ncP == 4
		
		If Empty(alltrim(cvendedor))
			MsgBox("C”DIGO DO VENDEDOR N√O INFORMADO.","ATENCAO")
			_lRet := .F.
		Else
			_aAreaA3 := GetArea()
			DbSelectArea("SA3")
			DbSetOrder(1)
			If !DbSeek(xFilial("SA3")+alltrim(cvendedor))
				MsgBox("C”DIGO DO VENDEDOR N√O EXISTE.","ATENCAO")
				_lRet := .F.
			EndIf
			RestArea(_aAreaA3)
		EndIf
		
	Case _ncP == 5
		
		If Empty(alltrim(cimpress))
			MsgBox("CAMPO IMPRESSAO N√O INFORMADO.","ATENCAO")
			_lRet := .F.
		EndIf
		
		If _lRet
			If !Empty(Alltrim(cimpress)) .and. len(Alltrim(cimpress)) > 100    
				nlen := len(Alltrim(cimpress))
				MsgAlert("O Campo Impress„o n„o pode ter mais de 100 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
				ocimpress:SetFocus() 
				_lRet := .F.     
			EndIf
		EndIf
		
	Case _ncP == 6
		
		If Empty(alltrim(csetor))
			MsgBox("CAMPO SETOR N√O INFORMADO.","ATENCAO")
			_lRet := .F.
		EndIf
		
	Case _ncP == 7
		
		If Empty(alltrim(ccontato))
			MsgBox("CAMPO CONTATO N√O INFORMADO.","ATENCAO")
			_lRet := .F.
		EndIf
		
		If _lRet
			If !Empty(Alltrim(ccontato)) .and. len(Alltrim(ccontato)) > 30    
				nlen := len(Alltrim(ccontato))
				MsgAlert("O Campo Contato n„o pode ter mais de 30 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
				occontato:SetFocus() 
				_lRet := .F.     
			EndIf
		EndIf
		
	Case _ncP == 8
		
		If Empty(alltrim(ctelefone))
			MsgBox("TELEFONE N√O INFORMADO.","ATENCAO")
			_lRet := .F.
		EndIf
		
	Case _ncP == 4
		
		If Empty(alltrim(cvendedor))
			MsgBox("C”DIGO DO VENDEDOR N√O INFORMADO.","ATENCAO")
			_lRet := .F.
		EndIf
	
	Case _ncP == 9
	
		If !Empty(Alltrim(cMdescr)) .and. len(Alltrim(cMdescr)) > 500    
			nlen := len(Alltrim(cMdescr))
			MsgAlert("O Campo DescriÁ„o do Atendimento n„o pode ter mais de 500 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
			oMdescr:SetFocus() 
			_lRet := .F.     
		EndIf
	
	Case  _ncP == 10
		
		If !Empty(Alltrim(cMobservacoes)) .and. len(Alltrim(cMobservacoes)) > 400    
			nlen := len(Alltrim(cMobservacoes))
			MsgAlert("O Campo ObservaÁıes n„o pode ter mais de 400 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
			oMobservac:SetFocus() 
			_lRet := .F.     
		EndIf
	
	Case  _ncP == 11
		
		If !Empty(Alltrim(cMconclusa)) .and. len(Alltrim(cMconclusa)) > 800
			nlen := len(Alltrim(cMconclusa))
			MsgAlert("O Campo Conclus„o n„o pode ter mais de 800 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
			oMconclusa:SetFocus() 
			_lRet := .F.     
		EndIf
	
	Case  _ncP == 12
	
		If !Empty(Alltrim(cacao)) .and. len(Alltrim(cacao)) > 400    
			nlen := len(Alltrim(cacao))
			MsgAlert("O Campo AÁ„o Imediata n„o pode ter mais de 400 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
			ocacao:SetFocus() 
			_lRet := .F.     
		EndIf
		
End Case

Return _lRet

*************************************
* Buscar ˙ltimo n˙mero RAC incluÌdo *
*************************************
Static Function fBuscaNum()
*************************************
Local _cQryNum := ""
Local _NumRac := ""

_aAreaRAC := GetArea()

_cQryNum := " SELECT MAX(NUMRAC) AS NUMRAC FROM SIGA.MAPARAC "
_cQryNum += " WHERE UNIDINC = '"+cEmpAnt+"' "
_cQryNum += " AND FILINC = '"+cFilAnt+"' "
_cQryNum += " AND DELRAC = ' '"
_cQryNum += " ORDER BY UNIDINC, FILINC, NUMRAC "

TCQUERY _cQryNum ALIAS "IDRAC" NEW

DBSELECTAREA("IDRAC")
DBGOTOP()
If !EOF() .and. !Empty(alltrim(IDRAC->NUMRAC))
	
	_NumRac := Strzero(val(IDRAC->NUMRAC)+1,6)
	
Else
	
	_NumRac := "000001"
	
EndIf
DbCloseArea()
RestArea(_aAreaRAC)

Return _NumRac

	
**********************************
*   ValidaÁ„o de Campos			 *
**********************************
Static Function VLDRAC2()
**********************************
Local _lRet := .T.

If nRprocede == 2 .AND. (Empty(alltrim(cMjustifiq)) .OR. alltrim(cMjustifiq) == "Justifique")
	MsgBox("O CAMPO JUSTIFICATIVA DEVE SER PREENCHIDO.","ATENCAO")
	_lRet := .F.
EndIf
If _lRet
	If !Empty(Alltrim(cMjustifiq)) .and. len(Alltrim(cMjustifiq)) > 400
		nlen := len(Alltrim(cMjustifiq))
		MsgAlert("O Campo Justificativa n„o pode ter mais de 400 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
		oMdescr:SetFocus() 
		_lRet := .F.     
	EndIf
EndIf

Return _lRet

	
**********************************
*	ValidaÁ„o da Tela			 *
**********************************
Static Function VldTudo()
**********************************
Local _lRet := .T.

If Empty(alltrim(codcli))
	MsgBox("C”DIGO DO CLIENTE N√O INFORMADO.","ATENCAO")
	_lRet := .F.
ElseIf !Empty(alltrim(codcli))
	_aAreaA1 := GetArea()
	DbSelectArea("SA1")
	DbSetOrder(1)
	If !DbSeek(xFilial("SA1")+padr(alltrim(codcli),TamSx3("A1_COD")[1])+ljcli)
		MsgBox("C”DIGO DO CLIENTE N√O EXISTE.","ATENCAO")
		_lRet := .F.
	EndIf
	RestArea(_aAreaA1)
EndIf

If Empty(alltrim(codprod))
	MsgBox("C”DIGO DO PRODUTO N√O INFORMADO.","ATENCAO")
	_lRet := .F.
ElseIf !Empty(alltrim(codprod))
	_aAreaB1 := GetArea()
	DbSelectArea("SB1")
	DbSetOrder(1)
	If !Dbseek(xFilial("SB1")+alltrim(codprod))
		MsgBox("C”DIGO DO PRODUTO N√O EXISTE.","ATENCAO")
		_lRet := .F.
	EndIf
	Restarea(_aAreaB1)
EndIf

If Empty(alltrim(cpedido))
	MsgBox("N⁄MERO DO PEDIDO N√O INFORMADO.","ATENCAO")
	_lRet := .F.
EndIf

If Empty(alltrim(cvendedor))
	MsgBox("C”DIGO DO VENDEDOR N√O INFORMADO.","ATENCAO")
	_lRet := .F.
ElseIf !Empty(alltrim(cvendedor))
	_aAreaA3 := GetArea()
	DbSelectArea("SA3")
	DbSetOrder(1)
	If !DbSeek(xFilial("SA3")+alltrim(cvendedor))
		MsgBox("C”DIGO DO VENDEDOR N√O EXISTE.","ATENCAO")
		_lRet := .F.
	EndIf
	RestArea(_aAreaA3)
EndIf

If Empty(alltrim(cimpress))
	MsgBox("CAMPO IMPRESSAO N√O INFORMADO.","ATENCAO")
	_lRet := .F.
EndIf

If !Empty(Alltrim(cimpress)) .and. len(Alltrim(cimpress)) > 100    
	nlen := len(Alltrim(cimpress))
	MsgAlert("O Campo Impress„o n„o pode ter mais de 100 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
	ocimpress:SetFocus() 
	_lRet := .F.     
EndIf

If Empty(alltrim(csetor))
	MsgBox("CAMPO SETOR N√O INFORMADO.","ATENCAO")
	_lRet := .F.
EndIf

If Empty(alltrim(ccontato))
	MsgBox("CAMPO CONTATO N√O INFORMADO.","ATENCAO")
	_lRet := .F.
EndIf

If Empty(alltrim(ctelefone))
	MsgBox("TELEFONE N√O INFORMADO.","ATENCAO")
	_lRet := .F.
EndIf
If !Empty(Alltrim(ccontato)) .and. len(Alltrim(ccontato)) > 30    
	nlen := len(Alltrim(ccontato))
	MsgAlert("O Campo Contato n„o pode ter mais de 30 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
	occontato:SetFocus() 
	_lRet := .F.     
EndIf

If Empty(alltrim(cvendedor))
	MsgBox("C”DIGO DO VENDEDOR N√O INFORMADO.","ATENCAO")
	_lRet := .F.
EndIf

If !Empty(Alltrim(cMdescr)) .and. len(Alltrim(cMdescr)) > 500    
	nlen := len(Alltrim(cMdescr))
	MsgAlert("O Campo DescriÁ„o do Atendimento n„o pode ter mais de 500 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
	oMdescr:SetFocus() 
	_lRet := .F.     
EndIf

If nRprocede == 2 .AND. (Empty(alltrim(cMjustifiq)) .OR. alltrim(cMjustifiq) == "Justifique")
	MsgBox("O CAMPO JUSTIFICATIVA DEVE SER PREENCHIDO.","ATENCAO")
	_lRet := .F. 
EndIf

If !Empty(Alltrim(cMjustifiq)) .and. len(Alltrim(cMjustifiq)) > 400
	nlen := len(Alltrim(cMjustifiq))
	MsgAlert("O Campo Justificativa n„o pode ter mais de 400 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
	oMdescr:SetFocus() 
	_lRet := .F.     
EndIf

If !Empty(Alltrim(cMobservacoes)) .and. len(Alltrim(cMobservacoes)) > 400    
	nlen := len(Alltrim(cMobservacoes))
	MsgAlert("O Campo ObservaÁıes n„o pode ter mais de 400 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
	oMobservac:SetFocus() 
	_lRet := .F.     
EndIf

If !Empty(Alltrim(cMconclusa)) .and. len(Alltrim(cMconclusa)) > 800
	nlen := len(Alltrim(cMconclusa))
	MsgAlert("O Campo Conclus„o n„o pode ter mais de 800 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
	oMconclusa:SetFocus() 
	_lRet := .F.     
EndIf

If !Empty(Alltrim(cacao)) .and. len(Alltrim(cacao)) > 400    
	nlen := len(Alltrim(cacao))
	MsgAlert("O Campo AÁ„o Imediata n„o pode ter mais de 400 caracteres. VocÍ digitou:" + AllTrim(Str(nlen)) )
	ocacao:SetFocus() 
	_lRet := .F.     
EndIf

Return _lRet

//InÌcio SSI 15677
**********************************
Static Function CriaMV( cMV, cDesc, cDesc1 )
**********************************
Local _aArea := GetArea()

dbSelectArea( "SX6" )
dbSetOrder(1)

If !dbSeek( xFilial("SX6") + cMV )
	RecLock("SX6", .T.)
	SX6->X6_FIL     := xFilial("SX6")
	SX6->X6_VAR     := cMV
	SX6->X6_TIPO    := "C"
	SX6->X6_DESCRIC := cDesc
	SX6->X6_DESC1	:= cDesc1
	SX6->X6_CONTEUD := "ana.24|thais"
	SX6->X6_CONTSPA := " "
	SX6->X6_CONTENG := " "
	SX6->X6_PROPRI  := "U"
	SX6->X6_PYME    := "S"
	MsUnlock()
EndIf

RestArea( _aArea )

Return      

**********************************
Static Function fAnexa(_nOpcA)
**********************************
Local _nOpc             := -1 
Local _oDlgAnexo		:= Nil
Local _oGrpRac			:= Nil
Local _oGrpAnexo		:= Nil
Local _oSayCodigo		:= Nil
Local _oGetCodigo		:= Nil
Local _oSayPedido		:= Nil
Local _oGetCodCli		:= Nil
Local _oGetLjCli		:= Nil
Local _oGetNomCli		:= Nil
Local _oSayCliente		:= Nil
Local _oBtnOk			:= Nil
Local _oBtnSair			:= Nil

Private _oListAnexos	:= Nil
Private _cGetCodigo  	:= _cNumRac
Private _cGetPedido		:= cpedido
Private _cGetCodCli		:= codcli
Private _cGetLjCli		:= ljcli
Private _cGetNomCli		:= comecli

MsgRun( "Carregando informaÁıes dos Anexos, aguarde...", "Carregando informaÁıes dos Anexos, aguarde...", { || FListRac() } ) 

_oDlgAnexo  	:= MsDialog():New( 091, 232, 555, 840, "Anexos RAC",,,.F.,,,,,,.T.,,,.T. )

_oGrpRac:= TGroup():New( 004, 004, 044, 268, "Anexos"			  , _oDlgAnexo, CLR_BLACK, CLR_WHITE, .T., .F. )
_oGrpAnexo   	:= TGroup():New( 052, 004, 224, 300, "InformaÁıes dos Anexos", _oDlgAnexo, CLR_BLACK, CLR_WHITE, .T., .F. )

_oSayCodigo 	:= TSay():New( 016, 012, { || "Num RAC" } , _oGrpRac	,,,.F.,.F.,.F.,.T., CLR_BLACK, CLR_WHITE,032, 008 )
_oSayData   	:= TSay():New( 016, 048, { || "Pedido:"  }, _oGrpRac	,,,.F.,.F.,.F.,.T., CLR_BLACK, CLR_WHITE,032, 008 )
_oSayCliente   	:= TSay():New( 016, 088, { || "Cliente:"  }, _oGrpRac	,,,.F.,.F.,.F.,.T., CLR_BLACK, CLR_WHITE,032, 008 )

_oGetCodigo 	:= TGet():New( 024, 012, { |u| If( PCount() > 0, _cGetCodigo  := u, _cGetCodigo	) }, _oGrpRac	,032, 008, "",, CLR_HRED, CLR_LIGHTGRAY,,,, .T., "",, { || .F. },.F.,.F.,,.F.,.F., "", "_cGetCodigo"		,,)
_oGetPedido   	:= TGet():New( 024, 049, { |u| If( PCount() > 0, _cGetPedido  := u, _cGetPedido	) }, _oGrpRac	,035, 008, "",, CLR_HRED, CLR_LIGHTGRAY	,,,, .T., "",, { || .F. },.F.,.F.,,.F.,.F., "", "_cGetPedido"		,,)
_oGetCodCli   	:= TGet():New( 024, 089, { |u| If( PCount() > 0, _cGetCodCli  := u, _cGetCodCli	) }, _oGrpRac	,036, 008, "",, CLR_HRED, CLR_LIGHTGRAY	,,,, .T., "",, { || .F. },.F.,.F.,,.F.,.F., "", "_cGetCodCli"		,,)
_oGetLjCli   	:= TGet():New( 024, 133, { |u| If( PCount() > 0, _cGetLjCli  := u, _cGetLjCli	) }, _oGrpRac	,020, 008, "",, CLR_HRED, CLR_LIGHTGRAY	,,,, .T., "",, { || .F. },.F.,.F.,,.F.,.F., "", "_cGetLjCli"		,,)
_oGetNomCli   	:= TGet():New( 024, 161, { |u| If( PCount() > 0, _cGetNomCli  := u, _cGetNomCli	) }, _oGrpRac	,102, 008, "",, CLR_HRED, CLR_LIGHTGRAY	,,,, .T., "",, { || .F. },.F.,.F.,,.F.,.F., "", "_cGetNomCli"		,,)

If _nOpcA <> 2
	_oBtnInclui		:= TBtnBmp2():New( 130, 558, 018, 015, "ADDCONTAINER",,,, { || FDetalhe( 3, -1			    ) }, _oGrpAnexo, "Incluir"   , { || .T.  } )
	_oBtnExclui		:= TBtnBmp2():New( 190, 558, 018, 015, "BMPDEL"		 ,,,, { || FDetalhe( 5, _oListAnexos:nAt ) }, _oGrpAnexo, "Excluir"   , { || .T.  } )
EndIf
_oBtnVisual		:= TBtnBmp2():New( 160, 561, 018, 015, "ANALITICO"	 ,,,, { || FVisual( 2, _oListAnexos:nAt ) }, _oGrpAnexo, "Visualizar", { || .T.  } )

        
@ 064, 012 ListBox _oListAnexos Fields Header "Data", "Hora", "DescriÁ„o" Size 260, 152 Of _oGrpAnexo Pixel ColSizes 25, 25, 020 On DblClick ( FDetalhe( 2, _oListAnexos:nAt ) )
_oListAnexos:SetArray( _aListAnexos )
_oListAnexos:bLine 		  := { || { _aListAnexos[ _oListAnexos:nAt ][01] , ; // Data
									_aListAnexos[ _oListAnexos:nAt ][02] , ; // Hora
								 	_aListAnexos[ _oListAnexos:nAt ][03] } } // DescriÁ„o

_oBtnSair  		:= SButton():New( 008, 273, 01, { || _nOpc := 00, _oDlgAnexo:End() }  , _oDlgAnexo,, "", )

_oDlgAnexo:Activate( ,,, .T. )

Return

**********************************
Static Function FListRac( _lRefresh )
**********************************
Local _aAreaAnt    := GetArea()
Local _cAliasFoto  := GetNextAlias()
Local _cQuery      := ""           

Default _lRefresh  := .F.

_aListAnexos 	   := {}
_cQuery := "	SELECT DISTINCT 	" 
_cQuery += "    	   NUMRAC , " 
_cQuery += "    	   PEDIDO , " 
_cQuery += "    	   DTINCLU , " 
_cQuery += "    	   HORA , " 
_cQuery += "    	   ORIGEM , " 
_cQuery += "    	   DESTINO , " 
_cQuery += "    	   DESCRICAO     " 
_cQuery += "      FROM SIGA.ANEXORAC "
_cQuery += "     WHERE DELREG  = ' ' " + CRLF
_cQuery += "	   AND UNIDINC = '" +cEmpAnt+ "' "
_cQuery += "	   AND FILINC = '" +cFilAnt+ "' "
_cQuery += "       AND NUMRAC = '"+_cNumRac+"' "
_cQuery += "       AND PEDIDO = '"+cpedido+"' "
_cQuery += "  ORDER BY DTINCLU, HORA " + CRLF
If Select( _cAliasFoto ) > 0
	( _cAliasFoto )->( DbCloseArea() )
EndIf
TcQuery _cQuery Alias ( _cAliasFoto ) New
Do While !( _cAliasFoto )->( Eof() )
	
	aAdd( _aListAnexos, {( _cAliasFoto )->DTINCLU , ; // Data
						 ( _cAliasFoto )->HORA , ; // Hora 
						 ( _cAliasFoto )->DESCRICAO ,; //DescriÁ„o
						 ( _cAliasFoto )->DESTINO ,; //Destino
						 ( _cAliasFoto )->ORIGEM } ) //Origem

	DbSelectArea( _cAliasFoto ) 
	( _cAliasFoto )->( DbSkip() )

EndDo
( _cAliasFoto )->( DbCloseArea() )

If Len( _aListAnexos ) == 0
	aAdd( _aListAnexos, { "", "", "", "", "" } )
EndIf
                 
If _lRefresh

	_oListAnexos:SetArray( _aListAnexos )
	_oListAnexos:bLine := { || { _aListAnexos[ _oListAnexos:nAt ][01] , ; // Data
								 _aListAnexos[ _oListAnexos:nAt ][02] , ; // Hora
								 _aListAnexos[ _oListAnexos:nAt ][03] , ; // DescriÁ„o
								 _aListAnexos[ _oListAnexos:nAt ][04] , ; //Destino
								 _aListAnexos[ _oListAnexos:nAt ][05] } } //Origem
EndIf

RestArea( _aAreaAnt )

Return

**********************************
Static Function FDetalhe( _nAcao, _nLinhaGrid ) 
**********************************
Local _nAcao2           := -1
Private _oDlgDetFoto, _oSayDescricao, _oSaySeleciona
Private _oSayOrigem, _oSayData, _oSayHora, _oGrpInfo
Private _oSayData, _oSayDescrica, _oGetData, _oGetOri
Private _oSaySelecionar, _oBtnSelFoto, _oBtnOk, _oBtnSair
Private _cGetData 	:= ""
Private _cGetDescricao 	:= ""
Private _lWhen          := _nAcao == 3

If _lWhen 
	_cGetData 		:= DTOC(ddatabase)
	_cGetHora		:= time()
	_cGetDescricao 	:= Space(20) 
	_cImgName		:= ""
Else
	_cGetData 	:= _aListAnexos[_nLinhaGrid][01]
	_cGetHora	:= _aListAnexos[_nLinhaGrid][02]
	_cGetDescricao 	:= PadR( _aListAnexos[_nLinhaGrid][03], 020 ) 
	_cImgName		:= AllTrim( _aListAnexos[_nLinhaGrid][04] ) 
EndIf

_oDlgDetFoto 	:= MsDialog():New( 091, 232, 250, 900, "Anexo RAC",,, .F.,,,,,, .T.,,, .T. )

_oGrpInfo  		:= TGroup():New( 004, 005, 070, 283, "Anexo" , _oDlgDetFoto, CLR_BLACK, CLR_WHITE, .T., .F. )

_oSayData	:= TSay():New( 014, 013, { || "Data:"		 }, _oGrpInfo	,,, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008 )
_oSayHora	:= TSay():New( 014, 050, { || "Hora:"		 }, _oGrpInfo	,,, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008 )
_oSayDescricao	:= TSay():New( 014, 100, { || "DescriÁ„o:"		 }, _oGrpInfo	,,, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 032, 008 )
_oSaySelecionar := TSay():New( 044, 013, { || "Selecionar Anexo:" }, _oDlgDetFoto,,, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008 )
_oSayOrigem := TSay():New( 044, 100, { || "Caminho Arquivo:" }, _oDlgDetFoto,,, .F., .F., .F., .T., CLR_BLACK, CLR_WHITE, 050, 008 )

_oGetData  := TGet():New( 024, 013, 		{ |u| If( PCount() > 0, _cGetData  := u, _cGetData ) }, _oGrpInfo, 024, 008, "",, CLR_HRED , CLR_LIGHTGRAY,,,, .T., "",, { || .F.    }, .F., .F.,,.F.,.F.,"", "_cGetData",, )
_oGetHora  := TGet():New( 024, 050, 		{ |u| If( PCount() > 0, _cGetHora  := u, _cGetHora ) }, _oGrpInfo, 024, 008, "",, CLR_HRED , CLR_LIGHTGRAY,,,, .T., "",, { || .F.    }, .F., .F.,,.F.,.F.,"", "_cGetHora",, )
_oGetDescricao  := TGet():New( 024, 100,{ |u| If( PCount() > 0, _cGetDescricao  := u, _cGetDescricao ) }, _oGrpInfo, 150, 008, "",, CLR_HRED , CLR_LIGHTGRAY,,,, .T., "",, { || .T.    }, .F., .F.,,.F.,.F.,"", "_cGetDescricao",, )
_oGetDescricao:bWhen := { || _lWhen }
_oBtnSelFoto	:= TBtnBmp2():New( 090, 150, 021, 016, "OPEN",,,, { || FSelAnexo() }, _oDlgDetFoto, "Selecionar Anexo", { || _lWhen } )
_oGetOri  := TGet():New( 044, 150,{ |u| If( PCount() > 0, _cImgName  := u, _cImgName ) }, _oGrpInfo, 100, 008, "",, CLR_HRED , CLR_LIGHTGRAY,,,, .T., "",, { || .F.    }, .F., .F.,,.F.,.F.,"", "_cImgName",, )

If AllTrim( _cImgName ) != ""
	MsgRun( "Carregando anexo, aguarde...", "Carregando anexo, aguarde...", { || FSelAnexo( _cImgName ) } ) 
EndIf

//_oBtnView  		:= TButton():New( 073, 300, "Visualizar", _oDlgDetFoto, { || FVisualizaLink() }, 031, 013,,,, .T.,, "",,,, .F. )
If _nAcao == 2
	_oBtnSair  		:= SButton():New( 007, 290, 02, { || _nAcao2 := 00, _oDlgDetFoto:End() 									    }, _oDlgDetFoto,, "", )
Else
	_oBtnOk    		:= SButton():New( 007, 290, 01, { || _nAcao2 := 01, If( FVldAnexo( _nAcao ), _oDlgDetFoto:End(), _nAcao2 := 00 ) }, _oDlgDetFoto,, "", )
	_oBtnSair  		:= SButton():New( 019, 290, 02, { || _nAcao2 := 00, _oDlgDetFoto:End() 									    }, _oDlgDetFoto,, "", )
EndIf

_oDlgDetFoto:Activate(,,,.T.)
                                                      
If _nAcao2 == 1

	MsgRun( "Gravando informaÁıes e Anexo, aguarde...", "Gravando informaÁıes e Anexo, aguarde...", { || FGravaAnexo( _nAcao ) } ) 
	
EndIf

Return

**********************************
Static Function FSelAnexo( _cFileName )
**********************************
Local _cPathSrvProtheus := Replace( AllTrim( GetSrvProfString( "ROOTPATH", "" ) ) + "\", "\\", "\" ) 
Default _cFileName 		:= ""
_cImgName 		   		:= ""

If AllTrim( _cFileName ) == ""

	OPEXGetFile( "_cImgName", "Todos | *.*", "Selecione o arquivo", "", .F. )

Else             

	_aArquivoImg := Directory( _cFileName )
	If Len( _aArquivoImg ) > 0 
		_nTamFile := aTail( _aArquivoImg )[02]
  	Else 
    	_nTamFile := 0
    EndIf
    If _nTamFile > 999999 // 1 Mb 
		_cImgName   := _cPathSrvProtheus + _cFileName
	Else
		_cImgName   := _cFileName
	EndIf


EndIf

Return

**********************************
Static Function OPEXGetFile( _cVariavel, _cFiltro, _cTitulo, _cDirIni, _lEhSalvar )
**********************************

/***
 * _________________________________________________________
 * cGetFile(<ExpC1>,<ExpC2>,<ExpN1>,<ExpC3>,<ExpL1>,<ExpN2>)
 * ØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØØ
 * <ExpC1> - Expressao de filtro
 * <ExpC2> - Titulo da janela
 * <ExpN1> - Numero de mascara default 1 para *.Exe
 * <ExpC3> - DiretÛrio inicial se necess·rio
 * <ExpL1> - .F. bot„o salvar - .T. bot„o abrir
 * <ExpN2> - Mascara de bits para escolher as opÁıes de visualizaÁ„o do objeto (prconst.ch)
 */

/*
ConfiguraÁıes para a FunÁ„o cGetFile, encontradas no Arquivo PrConst.Ch

#DEFINE GETF_ONLYSERVER                   0
#DEFINE GETF_OVERWRITEPROMPT              1
#DEFINE GETF_MULTISELECT                  2
#DEFINE GETF_NOCHANGEDIR                  4
#DEFINE GETF_LOCALFLOPPY                  8
#DEFINE GETF_LOCALHARD                   16
#DEFINE GETF_NETWORKDRIVE                32
#DEFINE GETF_SHAREAWARE                  64
#DEFINE GETF_RETDIRECTORY               128
*/	

Default _cFiltro   := "Planilha Excel| *.csv"
Default _cTitulo   := "Selecione o Arquivo"
Default _lEhSalvar := .F.
Default _cDirIni   := ""

&( _cVariavel ) := AllTrim( cGetFile( _cFiltro, _cTitulo, , _cDirIni, !_lEhSalvar,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, /*GETF_RETDIRECTORY*/,GETF_NETWORKDRIVE ) ) )

Return .T.

**********************************
Static Function FGravaAnexo( _nAcaoFt )
**********************************
Local _cPathImagens := "\RAC\"+_cNumRac+"\"
Local _cNomeImgAux  := Substr( AllTrim( _cImgName ),RAT( "\", _cImgName ) +1) 
Local cQryArq := ""
Local _cAliasArq := GetNextAlias()
Local _cAltArq := ""

If _nAcaoFt == 2
	Return
EndIf	

FwMakeDir( _cPathImagens )

cQryArq := " SELECT * FROM SIGA.ANEXORAC "
cQryArq += " WHERE DELREG = ' ' "
cQryArq += " AND UNIDINC = '"+cEmpAnt+"' "
cQryArq += " AND FILINC = '"+cFilAnt+"' "
cQryArq += " AND NUMRAC = '"+_cNumRac+"'"
cQryArq += " AND PEDIDO = '"+cpedido+"' "
cQryArq += " AND DESTINO = '"+_cPathImagens+_cNomeImgAux+"' "

If Select( _cAliasArq ) > 0
	( _cAliasArq )->( DbCloseArea() )
EndIf

TcQuery cQryArq Alias ( _cAliasArq ) New

If !((_cAliasArq)->(EOF())) 

	If _nAcaoFt 	== 3
		
		_cAltArq := " UPDATE SIGA.ANEXORAC "
		_cAltArq += " SET 	ORIGEM = '"+_cImgName+"', "
		_cAltArq += "		DESCRICAO = '"+_cGetDescricao+"', "
		_cAltArq += "		USERINC	= '"+__cUserId+"', "
		_cAltArq += "		DTINCLU = '"+DTOS(CTOD(_cGetData))+"', "
		_cAltArq += "		HORA  = '"+_cGetHora+"' "
		_cAltArq += " WHERE	DELREG <> '*' "
		_cAltArq += " AND	UNIDINC = '"+cEmpAnt+"' "
		_cAltArq += " AND	FILINC = '"+cFilAnt+"' "
		_cAltArq += " AND 	NUMRAC = '"+_cNumRac+"' "
		_cAltArq += " AND 	PEDIDO = '"+cpedido+"' "
		_cAltArq += " AND 	DESTINO = '"+_cPathImagens+_cNomeImgAux+"' "
		
		TcSqlExec(_cAltArq)
		TcSqlExec('commit')  

	ElseIf _nAcaoFt == 5

		_cAltArq := " UPDATE SIGA.ANEXORAC "
		_cAltArq += " SET 	DELREG = '*' "
		_cAltArq += " WHERE	DELREG <> '*' "
		_cAltArq += " AND	UNIDINC = '"+cEmpAnt+"' "
		_cAltArq += " AND	FILINC = '"+cFilAnt+"' "
		_cAltArq += " AND 	NUMRAC = '"+_cNumRac+"' "
		_cAltArq += " AND 	PEDIDO = '"+cpedido+"' "
		_cAltArq += " AND 	DESTINO = '"+_cPathImagens+_cNomeImgAux+"' "
		
		TcSqlExec(_cAltArq)
		TcSqlExec('commit')
		
	EndIf

Else

	If _nAcaoFt 	== 3
		
		_cAltArq := " INSERT INTO SIGA.ANEXORAC ("
		_cAltArq += " 	UNIDINC, "
		_cAltArq += " 	FILINC, "
		_cAltArq += " 	NUMRAC, "
		_cAltArq += " 	PEDIDO, "
		_cAltArq += " 	ORIGEM, "
		_cAltArq += "	DESCRICAO, "
		_cAltArq += "	USERINC, "
		_cAltArq += "	DTINCLU, "
		_cAltArq += "	HORA, "
		_cAltArq += " 	DESTINO, "
		_cAltArq += " 	DELREG )"
		_cAltArq += " VALUES ( "
		_cAltArq += " '"+cEmpAnt+"' ,"
		_cAltArq += " '"+cFilAnt+"' ,"
		_cAltArq += " '"+_cNumRac+"' ,"
		_cAltArq += " '"+cpedido+"' ,"
		_cAltArq += " '"+_cImgName+"' ,"
		_cAltArq += " '"+_cGetDescricao+"' ,"
		_cAltArq += " '"+__cUserId+"' ,"
		_cAltArq += " '"+DTOS(CTOD(_cGetData))+"' ,"
		_cAltArq += " '"+_cGetHora+"' ,"
		_cAltArq += " '"+_cPathImagens+_cNomeImgAux+"' ,"
		_cAltArq += " '"+Space(1)+"' )"
		
		
		TcSqlExec(_cAltArq)
		TcSqlExec('commit')  
		
	EndIf
	
		
EndIf           

If _nAcaoFt != 5
	  
	//Pega o Nome do Arquivo
	_cNomeArquivo := aTail( Separa( _cImgName, "\" ) )

	//Faz a cÛpia do Arquivo para o Servidor
	_cFileLocal := FTransferT2S( Replace( _cImgName, _cNomeArquivo, "" ), _cNomeArquivo )
	
	If AllTrim( _cFileLocal ) != ""

		FRename( _cFileLocal,  _cPathImagens + _cNomeImgAux )
	
	Else
		
		If _nAcaoFt 	== 3
			Aviso( "AtenÁ„o", "N„o conseguiu transferir o arquivo para o Servidor, o registro ser· excluÌdo.", { "Continuar" } ) 

			_cAltArq := " UPDATE SIGA.ANEXORAC "
			_cAltArq += " SET 	DELREG = '*' "
			_cAltArq += " WHERE	DELREG <> '*' "
			_cAltArq += " AND	UNIDINC = '"+cEmpAnt+"' "
			_cAltArq += " AND	FILINC = '"+cFilAnt+"' "
			_cAltArq += " AND 	PEDIDO = '"+cpedido+"' "
			_cAltArq += " AND 	DESTINO = '"+_cPathImagens+_cNomeImgAux+"' "
			
			TcSqlExec(_cAltArq)
			TcSqlExec('commit')
			
		EndIf
		
	EndIf

EndIf	

MsgRun( "Carregando informaÁıes do(s) Anexo(s), aguarde...", "Carregando informaÁıes do(s) Anexo(s), aguarde...", { || FListRac( .T. ) } ) 
                    
Return

**********************************
Static Function FVldAnexo( _nAcao )
**********************************
Local _lRet := .T.
                             
If _nAcao != 05 

	If Alltrim( _cGetDescricao ) == ""
		Aviso( "AtenÁ„o", "O Campo [ DescriÁ„o ] È obrigatÛrio!", { "Voltar" } ) 
		_lRet := .F.
	EndIf           
	
	If _lRet .And. Alltrim( _cImgName ) == ""
		Aviso( "AtenÁ„o", "A seleÁ„o de um Arquivo È obrigatÛrio!", { "Voltar" } ) 
		_lRet := .F.
	EndIf

EndIf
	
Return _lRet 

**********************************
Static Function FTransferT2S( _cGetPath, _cGetFile )
**********************************
Local _cPathDest  := "\RAC\"+_cNumRac+"\"
Local _cArqOrigem := Replace( AllTrim( _cGetPath  + "\" + _cGetFile ), "\\", "\" )
Local _cRet       := Replace( AllTrim( _cPathDest + "\" + _cGetFile ), "\\", "\" )

If Left( AllTrim( _cArqOrigem ), 01 ) != "\" // Significa que n„o Foi selecionado um Arquivo do Servidor...
                                
	//_cRet := _cArqOrigem
	If File( _cRet ) 
		FErase( _cRet )
	EndIf 
	If !CpyT2S( _cArqOrigem, _cPathDest, .F. )
		Aviso( "AtenÁ„o", "N„o conseguiu transferir o Arquivo para o Servidor Protheus.", { "Voltar" } )
		_cRet := ""
	EndIf 

EndIf 

Return _cRet

**********************************
Static Function FTransferS2T( _cFileName ) 
**********************************
Local _cPathDest  := "C:\TEMP\RAC\"+cEmpAnt+"\"+_cNumRac+"\"
Local _cRetA      := ""
Local _cNomeArq   := aTail( Separa( _cFileName, "\" ) )
Local _cFileDest  := _cPathDest  + _cNomeArq
_cRetA 			  := _cFileDest

FwMakeDir( _cPathDest, .F. ) 

If Left( AllTrim( _cFileName ), 01 ) == "\" // Significa que Foi selecionado um Arquivo do Servidor...
                                
	If File( _cFileDest ) 
		FErase( _cFileDest )
	EndIf 
	If !CpyS2T( _cFileName, _cPathDest, .F. )
		Aviso( "AtenÁ„o", "N„o conseguiu criar o Arquivo temporario do anexo.", { "Voltar" } )
		_cRetA := ""
	EndIf 

EndIf 

Return _cRetA

**********************************
User Function fImpRac()
**********************************
Local cDesc1         := "Este programa tem como objetivo imprimir RelatÛrio "
Local cDesc2         := "de Atendimento ao Cliente (RAC)         "
Local cDesc3         := ""
Local cPict          := ""
Local imprime      := .T.
Local aOrd         := {}
Private cProg     	:= "ORTA454"
Private nomeprog  	:= "ORTA454"
Private Cabec1       := ""
//                               1         2         3         4         5         6         7         8         9         10        11        12        13        14        15
//                     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
Private titulo       := OemToAnsi("RELAT”RIO DE ATENDIMENTO AO CLIENTE (RAC)")
Private cPerg     	:= "ORTA454"
Private oPrn,oFontM,oFontP,oBrush
Private lDebug    	:= .F.
Private lRet	   	:= .T.
Private Cabec1		:= ""
Private ltopo := .t.                                                            
Private cHora 	   	:= Time()
Private nLin       	:= 0
Private nPag	   	:= 0
Private cNomFil		:= ""
Private nEsp 		:= 50
Private aSx1	   	:= {}

oFontM	:= TFont():New('Courier new',, 10,, .T.,,,,,.F.,.F.)
oFontP	:= TFont():New('Courier new',, 09,, .T.,,,,,.F.,.F.)

oBrush	:= TBrush():New( ,CLR_HGRAY )

oPrn := TMSPrinter():New( titulo )
oPrn:Setup()

oPrn:Setportrait()   // Modo Paisagem
oPrn:SetPaperSize(09) // Formato A4
oPrn:SetFont(oFontM)

if !oPrn:Canceled()
	Processa( {|| GeraRel(@oPrn) }, "Aguarde...", "Gerando RelatÛrio...",.T.)
	
	oPrn:Preview()
	oPrn:End()
EndIf

FreeObj(oPrn)
oPrn := Nil

Return

**********************************
Static Function GeraRel(oPrn)                                
**********************************

Local _cQryRac 	:= ""
Local _cAliasRac:= GetNextAlias()
Local _cTpAtend	:= Alltrim((cAliasRac)->TPATEND)
Local _cProcede	:= ""
Local _cNomeCli	:= ""
Local _cNomePro	:= ""
Local _cNomeVend:= ""
Local _cProd	:= ""      
Local _cTpSeg	:= ""
Local nLines	:= 0

Private _cRacImp	:= alltrim((cAliasRac)->NUMRAC)

Private aBox := {{ 0050, 0300, 0550, 0800 ,1200, 1450, 1600, 1850, 2000, 2380},;
{ 0100, 0350, 0650, 0950, 1250, 1550, 1850,2200,2380}}
private nBox := Len(aBox) 

titulo := "RELAT”RIO DE ATENDIMENTO AO CLIENTE"
Cabec1 := "N⁄MERO: "+_cRacImp+" - TIPO DE ATENDIMENTO: "+_cTpAtend

_cQryRac :=" SELECT * FROM SIGA.MAPARAC "  
_cQryRac +=" WHERE DELRAC = ' ' "
_cQryRac +=" AND UNIDINC = '"+cEmpAnt+"' "
_cQryRac +=" AND FILINC = '"+cFilAnt+"' "
_cQryRac +=" AND NUMRAC = '"+_cRacImp+"' "

memowrite("c:\ORTA454_IMP.sql",_cQryRac)

If Select(_cAliasRac) > 0
	(_cAliasRac)->(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryRac),_cAliasRac,.T.,.T.)

(_cAliasRac)->(dbGoTop())
nTotReg := 0
While (_cAliasRac)->(!EOF())
	nTotReg++
	(_cAliasRac)->(DbSkip())
EndDo

(_cAliasRac)->(dbGoTop())
If (_cAliasRac)->(eof())
	(_cAliasRac)->(dbclosearea())
	MsgBox("Nao ha Dados a serem gerados para este relatorio","Aviso","INFO")
	Return
EndIf

nLin := fImpCab( "1", .t. , oPrn )

(_cAliasRac)->(dbGoTop())
If (_cAliasRac)->(!EOF())
		
	
	_cNomeCli := Posicione("SA1",1,xFilial("SA1")+(_cAliasRac)->CLIENTE+(_cAliasRac)->LOJACLI,"A1_NOME")
	_cNomeCli := Alltrim(_cNomeCli)
	_cNomePro := Posicione("SB1",1,xFilial("SB1")+(_cAliasRac)->PRODUTO,"B1_DESC")
	_cNomePro := Alltrim(_cNomePro)
	_cNomeVend:= Posicione("SA3",1,xFilial("SA3")+(_cAliasRac)->VENDEDOR,"A3_NOME")
	_cNomeVend:= ALLTRIM(_cNomeVend)
		
	oPrn:Say(nLin+15, aBox[1][01], "CLIENTE: ",oFontM) 
	oPrn:Say(nLin+15, aBox[1][02], (_cAliasRac)->CLIENTE+" - "+_cNomeCli,oFontP) 
	oPrn:Say(nLin+15, aBox[1][06], "PEDIDO: ",oFontM) 
	oPrn:Say(nLin+15, aBox[1][07], (_cAliasRac)->NUMPED,oFontP) 
	oPrn:Say(nLin+15, aBox[1][08], " NOTA: ",oFontM) 
	oPrn:Say(nLin+15, aBox[1][09], (_cAliasRac)->NOTA,oFontP) 
	nLin+=nEsp
	oPrn:Say(nLin+15, aBox[1][01], "PRODUTO: ",oFontM) 
	oPrn:Say(nLin+15, aBox[1][02], (_cAliasRac)->PRODUTO+" - "+_cNomePro,oFontP) 
	oPrn:Say(nLin+15, aBox[1][05], "VENDEDOR: ",oFontM) 
	oPrn:Say(nLin+15, aBox[1][06], (_cAliasRac)->VENDEDOR+" - "+_cNomeVend,oFontP) 
	nLin+=nEsp
	oPrn:Say(nLin+15, aBox[1][01], "IMPRESS√O: ",oFontM)  
	oPrn:Say(nLin+15, aBox[1][02], (_cAliasRac)->IMPRESSAO,oFontP)  
	oPrn:Say(nLin+15, aBox[1][05], "SETOR: ",oFontM)  
	oPrn:Say(nLin+15, aBox[1][06], (_cAliasRac)->SETOR,oFontP)  
	nLin+=nEsp
	oPrn:Say(nLin+15, aBox[1][01], "CONTATO: ",oFontM)  
	oPrn:Say(nLin+15, aBox[1][02], (_cAliasRac)->CONTATO,oFontP)  
	oPrn:Say(nLin+15, aBox[1][05], "TELEFONE: ",oFontM)  
	oPrn:Say(nLin+15, aBox[1][06], (_cAliasRac)->TELEFONE,oFontP)  
	nLin+=nEsp
	nLin += nEsp
	oPrn:Say(nLin+15, aBox[1][01], "DESCRI«√O DO ATENDIMENTO: ",oFontM)  
	nLin+=nEsp
	If !Empty(Alltrim((_cAliasRac)->DESCATEND))
		
		nLines := MLCOUNT(AllTrim((_cAliasRac)->DESCATEND), 110)
		For _nD := 1 To nLines
			oPrn:Say(nLin+15, aBox[1][01],(MEMOLINE(Alltrim((_cAliasRac)->DESCATEND),110,_nD)) , oFontP) 
			nLin += nEsp
		Next _nD
	Else
		oPrn:Say(nLin, aBox[1][01],"N/A" , oFontP)   
		nLin +=nEsp
	EndIf
	
	If !fImpAmost()
	
		nLin +=nEsp
		oPrn:Box( nLin, aBox[2][01], nLin+nEsp, aBox[2][08] )
		oPrn:Say(nLin+15, aBox[2][03], "AN¡LISE DAS AMOSTRAS DE EVID NCIA",oFontM) 
		nLin +=nEsp		
		oPrn:Box( nLin, aBox[2][01], nLin+nEsp, aBox[2][08] )
		oPrn:Say(nLin+15, aBox[2][01]+20, Replicate("*",090),oFontM)  
		nLin +=nEsp
		nLin +=nEsp
		
	Else
		
		nLin +=nEsp
		
	EndIf
			
	If nLin > 3150 // Salto de P·gina.  
		oPrn:Say(3250, aBox[1][01], "FQ. 7.2-2 Novembro/2015 Rev. 09",oFontP) 
		oPrn:Say(3250, aBox[1][08], "ElaboraÁ„o: Ana Clara",oFontP) 
		nLin := fImpCab( "1", .f. , oPrn )
		ltopo := .t.
	Endif
	
	oPrn:Say(nLin+15, aBox[1][01], "OBSERVA«’ES: ",oFontM)  
	nLin+=nEsp
	If !Empty(Alltrim((_cAliasRac)->OBSERV))
	
		nLines := MLCOUNT(AllTrim((_cAliasRac)->OBSERV), 110)
		For _nO := 1 To nLines
			oPrn:Say(nLin+15, aBox[1][01],(MEMOLINE(Alltrim((_cAliasRac)->OBSERV),110,_nO)) , oFontP) 
			nLin += nEsp
		Next _nO
		
	Else
		oPrn:Say(nLin, aBox[1][01],"N/A" , oFontP)   
		nLin +=nEsp
	EndIf
	
	If nLin > 3150 // Salto de P·gina.  
		oPrn:Say(3250, aBox[1][01], "FQ. 7.2-2 Novembro/2015 Rev. 09",oFontP) 
		oPrn:Say(3250, aBox[1][08], "ElaboraÁ„o: Ana Clara",oFontP) 
		nLin := fImpCab( "1", .f. , oPrn )
		ltopo := .t.
	Endif
	
	nLin += nEsp
	oPrn:Say(nLin+15, aBox[1][01], "DATA INCLUS√O: "+DTOC(STOD((_cAliasRac)->DTINCLU)),oFontM)  
	oPrn:Say(nLin+15, aBox[1][04], "DATA FECHAMENTO: "+DTOC(STOD((_cAliasRac)->DTFECH)),oFontM)  
	oPrn:Say(nLin+15, aBox[1][06], "N⁄MERO RNC: "+(_cAliasRac)->NUMRNC,oFontM)  
	nLin+=nEsp
	nLin += nEsp
	
	oPrn:Say(nLin+15, aBox[1][01], "PROCEDE? ",oFontM)  
	oPrn:Say(nLin+15, aBox[1][02], Iif(ALLTRIM((_cAliasRac)->PROCEDE)== "S","SIM","N√O"),oFontP)  
	nLin+=nEsp
	oPrn:Say(nLin+15, aBox[1][01], "JUSTIFICATIVA: ",oFontM)  
	nLin+=nEsp
	If !Empty(Alltrim((_cAliasRac)->JUSTIFIC))
	
		nLines := MLCOUNT(AllTrim((_cAliasRac)->JUSTIFIC), 110)
		For _nJ := 1 To nLines
			oPrn:Say(nLin+15, aBox[1][01],(MEMOLINE(Alltrim((_cAliasRac)->JUSTIFIC),110,_nJ)) , oFontP) 
			nLin += nEsp
		Next _nJ
		
	Else
		oPrn:Say(nLin, aBox[1][01],"N/A" , oFontP)   
		nLin +=nEsp
	EndIf
	
	nLin +=nEsp
	oPrn:Line(nLin, aBox[1][01], nLin, oPrn:nHorzRes()-50 )
	oPrn:Say(nLin+15, aBox[2][03], "CAUSAS",oFontM) 
	nLin +=nEsp
	oPrn:Line(nLin, aBox[1][01], nLin, oPrn:nHorzRes()-50)
	If !Empty(Alltrim((_cAliasRac)->MAODEOBRA)) .OR. !Empty(Alltrim((_cAliasRac)->MATPRIMA)) .OR. ;
	   !Empty(Alltrim((_cAliasRac)->MAQUINA)) .OR. !Empty(Alltrim((_cAliasRac)->METODO)) .OR. ;
	   !Empty(Alltrim((_cAliasRac)->MEIOAMB))
		If !Empty(Alltrim((_cAliasRac)->MAODEOBRA))
			oPrn:Say(nLin+15, aBox[1][01], "M√O DE OBRA:",oFontM) 
			nLin +=nEsp
			nLines := MLCOUNT(AllTrim((_cAliasRac)->MAODEOBRA), 110)
			For _nM := 1 To nLines
				oPrn:Say(nLin+15, aBox[1][01],(MEMOLINE(Alltrim((_cAliasRac)->MAODEOBRA),110,_nM)) , oFontP) 
				nLin += nEsp
			Next _nM
			oPrn:Line(nLin, aBox[1][01], nLin, oPrn:nHorzRes()-50 )
		EndIf
		If !Empty(Alltrim((_cAliasRac)->MATPRIMA))
			oPrn:Say(nLin+15, aBox[1][01], "MAT…RIA PRIMA:",oFontM) 
			nLin +=nEsp
			nLines := MLCOUNT(AllTrim((_cAliasRac)->MATPRIMA), 110)
			For _nP := 1 To nLines
				oPrn:Say(nLin+15, aBox[1][01],(MEMOLINE(Alltrim((_cAliasRac)->MATPRIMA),110,_nP)) , oFontP) 
				nLin += nEsp
			Next _nP
			oPrn:Line(nLin, aBox[1][01], nLin, oPrn:nHorzRes()-50 )
		EndIf
		If !Empty(Alltrim((_cAliasRac)->MAQUINA))
			oPrn:Say(nLin+15, aBox[1][01], "M¡QUINA:",oFontM) 
			nLin +=nEsp
			nLines := MLCOUNT(AllTrim((_cAliasRac)->MAQUINA), 110)
			For _nQ := 1 To nLines
				oPrn:Say(nLin+15, aBox[1][01],(MEMOLINE(Alltrim((_cAliasRac)->MAQUINA),110,_nQ)) , oFontP) 
				nLin += nEsp
			Next _nQ
			oPrn:Line(nLin, aBox[1][01], nLin, oPrn:nHorzRes()-50 )
		EndIf
	    If !Empty(Alltrim((_cAliasRac)->METODO))
			oPrn:Say(nLin+15, aBox[1][01], "M…TODO:",oFontM) 
			nLin +=nEsp
			nLines := MLCOUNT(AllTrim((_cAliasRac)->METODO), 110)
			For _nT := 1 To nLines
				oPrn:Say(nLin+15, aBox[1][01],(MEMOLINE(Alltrim((_cAliasRac)->METODO),110,_nT)) , oFontP) 
				nLin += nEsp
			Next _nT
			oPrn:Line(nLin, aBox[1][01], nLin, oPrn:nHorzRes()-50 )
		EndIf
		If !Empty(Alltrim((_cAliasRac)->MEIOAMB))
			oPrn:Say(nLin+15, aBox[1][01], "MEIO AMBIENTE:",oFontM) 
			nLin +=nEsp
			nLines := MLCOUNT(AllTrim((_cAliasRac)->MEIOAMB), 110)
			For _nA := 1 To nLines
				oPrn:Say(nLin+15, aBox[1][01],(MEMOLINE(Alltrim((_cAliasRac)->MEIOAMB),110,_nA)) , oFontP) 
				nLin += nEsp
			Next _nA
			oPrn:Line(nLin, aBox[1][01], nLin, oPrn:nHorzRes()-50 )
		EndIf
	    If !Empty(Alltrim((_cAliasRac)->MEDICAO))
			oPrn:Say(nLin+15, aBox[1][01], "MEDI«√O:",oFontM) 
			nLin +=nEsp
			nLines := MLCOUNT(AllTrim((_cAliasRac)->MEDICAO), 110)
			For _nT := 1 To nLines
				oPrn:Say(nLin+15, aBox[1][01],(MEMOLINE(Alltrim((_cAliasRac)->MEDICAO),110,_nT)) , oFontP) 
				nLin += nEsp
			Next _nT
			oPrn:Line(nLin, aBox[1][01], nLin, oPrn:nHorzRes()-50 )
		EndIf
		nLin += nEsp
	Else
		oPrn:Say(nLin, aBox[1][01],"N/A" , oFontP)   
		nLin +=nEsp
		oPrn:Line(nLin, aBox[1][01], nLin, oPrn:nHorzRes()-50 )
		nLin +=nEsp
	EndIf
	
	If nLin > 3150 // Salto de P·gina.  
		oPrn:Say(3250, aBox[1][01], "FQ. 7.2-2 Novembro/2015 Rev. 09",oFontP) 
		oPrn:Say(3250, aBox[1][08], "ElaboraÁ„o: Ana Clara",oFontP) 
		nLin := fImpCab( "1", .f. , oPrn )
		ltopo := .t.
	Endif
	
	oPrn:Say(nLin+15, aBox[1][01], "A«√O IMEDIATA (quando aplic·vel):",oFontM) 
	nLin +=nEsp
	oPrn:Say(nLin+15, aBox[1][01], IIf(Empty(Alltrim((_cAliasRac)->ACAOIMED)),"N/A",Alltrim((_cAliasRac)->ACAOIMED)),oFontP) 
	nLin +=nEsp
	nLin +=nEsp
	
	If nLin > 3150 // Salto de P·gina.  
		oPrn:Say(3250, aBox[1][01], "FQ. 7.2-2 Novembro/2015 Rev. 09",oFontP) 
		oPrn:Say(3250, aBox[1][08], "ElaboraÁ„o: Ana Clara",oFontP) 
		nLin := fImpCab( "1", .f. , oPrn )
		ltopo := .t.
	Endif
	
	oPrn:Say(nLin+15, aBox[1][01], "CONCLUS√O:",oFontM) 
	nLin +=nEsp
	If !Empty(Alltrim((_cAliasRac)->CONCLUSAO))
		nLines := MLCOUNT(AllTrim((_cAliasRac)->CONCLUSAO), 110)
		For _nC := 1 To nLines
			If nLin > 3150 // Salto de P·gina.  
				oPrn:Say(3250, aBox[1][01], "FQ. 7.2-2 Novembro/2015 Rev. 09",oFontP) 
				oPrn:Say(3250, aBox[1][08], "ElaboraÁ„o: Ana Clara",oFontP) 
				nLin := fImpCab( "1", .f. , oPrn )
				ltopo := .t.
			Endif
			oPrn:Say(nLin+15, aBox[1][01],(MEMOLINE(Alltrim((_cAliasRac)->CONCLUSAO),110,_nC)) , oFontP) 
			nLin += nEsp
		Next _nC
	Else
		oPrn:Say(nLin, aBox[1][01],"N/A" , oFontP)   
		nLin +=nEsp
	EndIf
	nLin +=nEsp
		
	If nLin > 3150 // Salto de P·gina.  
		oPrn:Say(3250, aBox[1][01], "FQ. 7.2-2 Novembro/2015 Rev. 09",oFontP) 
		oPrn:Say(3250, aBox[1][08], "ElaboraÁ„o: Ana Clara",oFontP) 
		nLin := fImpCab( "1", .f. , oPrn )
		ltopo := .t.
	Endif
	
	oPrn:Say(nLin+15, aBox[1][01], "RESPONS¡VEL: "+IIf(Empty(Alltrim((_cAliasRac)->RESPONSAVEL)),"N/A",Alltrim((_cAliasRac)->RESPONSAVEL)),oFontM) 
	oPrn:Say(nLin+15, aBox[1][06], "SETOR: Controle de Qualidade",oFontM) 
	nLin +=nEsp
	
EndIf
(_cAliasRac)->(DbCloseArea())

oPrn:Say(3250, aBox[1][01], "FQ. 7.2-2 Novembro/2015 Rev. 09",oFontP) 
oPrn:Say(3250, aBox[1][08], "ElaboraÁ„o: Ana Clara",oFontP) 

Return

**********************************
Static Function fImpCab(cTp, lPrimeira, oPrn) 
**********************************

nPag	+= 1

If !lPrimeira
	oPrn:EndPage()
EndIf

oPrn:StartPage()
oPrn:SetPortrait()   // Modo Paisagem
oPrn:SetPaperSize(09) // Formato A4
oPrn:SetFont(oFontM)

oPrn:Box( 50, 50, 200, oPrn:nHorzRes()-55 )
oPrn:Box( 49, 49, 199, oPrn:nHorzRes()-54 )

// Lado Esquerdo
oPrn:Say ( 085, 95, "Hora: " + cHora + " - (" + nomeprog + ")"     , oFontM)
oPrn:Say ( 125, 95, "Empresa: " + cEmpAnt + " / Filial: " + cNomFil , oFontM)

// Centro
oPrn:Say ( 085 , 10, PADC(AllTrim(Upper(titulo)), 100 ), oFontM)

// Lado Direito
nTam := oPrn:GetTextWidth ( "Emiss„o:" + Dtos(Date()), oFontM ) + 115
oPrn:Say ( 085, oPrn:nHorzRes()-nTam, "Folha: " + AllTrim(Str(nPag)), oFontM)
oPrn:Say ( 125, oPrn:nHorzRes()-nTam, "Emiss„o:" + DtoC(Date()), oFontM)

nLin	:= 210

oPrn:Say ( nLin, 50, Cabec1, oFontM)

nLin += nEsp

oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
oPrn:Line(nLin+2, 50, nLin+2, oPrn:nHorzRes()-50 )
oPrn:Line(nLin+4, 50, nLin+4, oPrn:nHorzRes()-50 )

nLin += 15

Return(nLin)

**********************************
Static Function fImpAmost()
**********************************
Local _aAreaAm	:= GetArea()
Local _cQryAm	:= ""
Local _cAliasIIt := GetNextAlias()
Local _lImpCab := .T.
Local _lTem	:= .F.


_cQryAm := " SELECT * FROM SIGA.ITMAPARAC "
_cQryAm += " WHERE DELRAC = ' ' "
_cQryAm += " AND UNIDINC = '"+cEmpAnt+"' "
_cQryAm += " AND FILINC = '"+cFilAnt+"' "
_cQryAm += " AND NUMRAC = '"+_cRacImp+"' "
_cQryAm += " ORDER BY ITPED "

memowrite("c:\ORTA454_IMPIT.sql",_cQryAm)

If Select(_cAliasIIt) > 0
	(_cAliasIIt)->(dbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQryAm),_cAliasIIt,.T.,.T.)

(_cAliasIIt)->(dbGoTop())
nTotReg := 0
While (_cAliasIIt)->(!EOF())
	nTotReg++
	(_cAliasIIt)->(DbSkip())
EndDo

(_cAliasIIt)->(dbGoTop())
If (_cAliasIIt)->(eof())
	(_cAliasIIt)->(dbclosearea())
	Return
EndIf

(_cAliasIIt)->(dbGoTop())
While (_cAliasIIt)->(!EOF())

	If _lImpCab
		
		nLin += nEsp    
		oPrn:Box( nLin, aBox[2][01], nLin+nEsp, aBox[2][08] )
		oPrn:Say(nLin, aBox[1][03], "AN¡LISE DAS AMOSTRAS DE EVID NCIA",oFontM)  
		nLin += nEsp
		
		oPrn:Box( nLin, aBox[2][01], nLin+nEsp, aBox[2][08] )
		For ii := 1 to Len(aBox[2])-1
			oPrn:Line(nLin, aBox[2][ii], nLin+nEsp, aBox[2][ii] )
		Next ii
		
		oPrn:Say(nLin+15, aBox[2][01]+10, "ITEM",oFontM)  
		oPrn:Say(nLin+15, aBox[2][02]+10, "PEDIDO",oFontM)  
		oPrn:Say(nLin+15, aBox[2][03]+10, "ESPESSURA",oFontM)  
		oPrn:Say(nLin+15, aBox[2][04]+10, "LARGURA",oFontM)  
		oPrn:Say(nLin+15, aBox[2][05]+10, "COMPRIMENTO",oFontM)  
		oPrn:Say(nLin+15, aBox[2][06]+10, "SANFONA",oFontM)  
		oPrn:Say(nLin+15, aBox[2][07]+10, "QUANTIDADE/PESO",oFontM)  
		
		nLin += nEsp
		
		_lImpCab := .F.
		_lTem := .T.
		
	EndIf
	
	oPrn:Box( nLin, aBox[2][01], nLin+nEsp, aBox[2][08] )
	For _nIIt := 1 to Len(aBox[2])-1
		oPrn:Line(nLin, aBox[2][_nIIt], nLin+nEsp, aBox[2][_nIIt] )
	Next _nIIt
	
	oPrn:Say(nLin+15, aBox[2][01]+10, STRZERO(VAL((_cAliasIIt)->ITPED),2),oFontP)  
	oPrn:Say(nLin+15, aBox[2][02]+10, (_cAliasIIt)->NUMPEDIT,oFontP)  
	oPrn:Say(nLin+15, aBox[2][03]+10, Transform((_cAliasIIt)->ESPESIT,"@E 9.9999"),oFontP)  
	oPrn:Say(nLin+15, aBox[2][04]+10, Transform((_cAliasIIt)->LARGIT,"@E 9.999"),oFontP)  
	oPrn:Say(nLin+15, aBox[2][05]+10, Transform((_cAliasIIt)->COMPRIT,"@E 9.999"),oFontP)  
	oPrn:Say(nLin+15, aBox[2][06]+10, Transform((_cAliasIIt)->SANFIT,"@E 999.99"),oFontP)  
	oPrn:Say(nLin+15, aBox[2][07]+10, Transform((_cAliasIIt)->QTDPESIT,"@E 999,999.9999"),oFontP)  
	nLin += nEsp
	
	(_cAliasIIt)->(DbSkip())
EndDo

RestArea(_aAreaAm)

Return _lTem

Static Function FVisual(_nAcao, _nLinhaGrid )
Local _cLocal := AllTrim( _aListAnexos[_nLinhaGrid][04])
Local _cPathSrvProtheus := Replace( AllTrim( GetSrvProfString( "ROOTPATH", "" ) ), "/", "\" ) 
Local _cEndComp := ""

_cEndComp := FTransferS2T( _cLocal ) 

shellExecute("Open", _cEndComp, "", "C:\TEMP\RAC\"+cEmpAnt+"\"+_cNumRac+"\", 1 )
	
Return
//Fim SSI 15677

User Function ORTA454LEG()

Local  aCores := {	{ 'BR_VERDE ', "ABERTO " },;
					{ 'BR_VERMELHO', "FECHADO"}}

BrwLegenda("STATUS","Legenda",aCores )

Return(.T.)                               

User Function fPesq454()

Pergunte("ORTA454",.T.)

CloseBrowse()


//cAliasRac := GetNextAlias()

cQuery := " SELECT NUMRAC, CLIENTE, SUBSTR(A1_NOME,1,40) A1_NOME, LOJACLI, PRODUTO, NUMPED, VENDEDOR, SETOR,MAODEOBRA,MATPRIMA,MAQUINA,METODO,MEDICAO,MEIOAMB, "
cQuery += " DECODE(TPATEND,'R','Reclamacao   ','S','O.M Sugestoes','Observacao') AS TPATEND, NUMRNC "
cQuery += " FROM SIGA.MAPARAC, "+RETSQLNAME("SA1")+" SA1 "
cQuery += " WHERE DELRAC = ' ' "
cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += " AND CLIENTE = A1_COD "
cQuery += " AND A1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'"
cQuery += " AND DTINCLU BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'"
cQuery += " AND UNIDINC = '"+cEmpAnt+"' "
cQuery += " AND FILINC = '"+cFilAnt+"' "
cQuery += " ORDER BY NUMRAC "

MemoWrit("C:\ORTA454_1.SQL",cQuery)

If Select(cAliasRac) > 0
	(cAliasRac)->(dbCloseArea())
EndIf

cArquivo := CriaTrab(aFld,.T.)
dbUseArea(.T.,,cArquivo,cAliasRac,.F.,.F.)
SQLToTrb(cQuery,aFld,cAliasRac)

cInd := CriaTrab(NIL,.F.)

DbSelectArea(cAliasRac)
IndRegua(cAliasRac,cInd,"NUMRAC",,,"Selecionando Registros...")

DbSelectArea(cAliasRac)
dbSetOrder(1)
dbGoTop()
//mBrowse(06,01,22,75,"TRB",aTitulos,,,,,aCores)
mBrowse(06,01,22,75,cAliasRac,aTitulos,,,,,aCores)
//MBrowse(6,1,22,75,cAliasRac,,,,,,aCores)

DbSelectArea(cAliasRac)
dbClearind()
//DBCLOSEAREA()
/*If Select(cAliasRac) > 0
	(cAliasRac)->(dbCloseArea())
EndIf*/
FErase(cArquivo + GetDbExtension())  // Deletando o arquivo

FErase(cArquivo + OrdBagExt())       // Deletando Ìndice     


Return


*********************************
Static Function ValidPerg(cPerg)
*********************************

DbSelectArea("SX1")
DbSetOrder(1) //NAO TROCAR

aRegs := {}

aAdd(aRegs,{cPerg,"01","Cliente Ate ....:", "", "", "MV_CH1","C",06,0,0,"G","","mv_par01","" ,"","","","",;
""				,"","","","",""					,"","","","","","","","","","","","","","SA1"	 ,"" ,"",""})
aAdd(aRegs,{cPerg,"02","Cliente Ate ....:", "", "", "MV_CH2","C",06,0,0,"G","","mv_par02","" ,"","","","",;
""				,"","","","",""					,"","","","","","","","","","","","","","SA1"	 ,"" ,"",""})
aAdd(aRegs,{cPerg,"03","Periodo de  ....:", "", "", "MV_CH3","D",08,0,0,"G","","mv_par03",""		 ,"","","","",;
""				,"","","","",""					,"","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Periodo ate ....:", "", "", "MV_CH4","D",08,0,0,"G","","mv_par04",""		 ,"","","","",;
""				,"","","","",""					,"","","","","","","","","","","","","","","","",""})

//Cria Pergunta
cPerg := U_AjustaSx1(cPerg,aRegs)

Return
