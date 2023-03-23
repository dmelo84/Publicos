
*****************************************************************************
* Programas Contidos neste Fonte                                            *
*****************************************************************************
* User Functions                                                            *
*---------------------------------------------------------------------------*
* 0rtr024()                                                                 *
*---------------------------------------------------------------------------*
* Static Functions                                                          *
*---------------------------------------------------------------------------*
* RunReport()    | ValidPerg()    | ImpRodap()     |                        *
*****************************************************************************
* Tabelas Utilizadas (SC5, SC6)                                             *
*****************************************************************************
* Parametros:                                                               *
*****************************************************************************

*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | ORTR024  | Autor |  Cleverson Luiz Schaefer                |*
*+------------+------------------------------------------------------------+*
*|Data        | 17.03.2006                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Picking List de Produção.                                  |*
*|            |                                                            |*
*+-------------------------------------------------------------------------+*
*|Alterado por|					         | Data |			               |*
*+-------------------------------------------------------------------------+*
*|Descricao   |									                           |*
*+-------------------------------------------------------------------------+*
*****************************************************************************

#include "Rwmake.ch"
#include "TopConn.ch"
#include "tbiconn.ch"

#DEFINE PULA chr(13)+chr(10)

User Function ORTR024()
***********************

Local cPict          := ""
Local imprime        := .T.
Local aOrd := {}

Private cDesc1       := "USUARIO       : GER.GERAL, GER.LOJA, ASSESSORES E GESTORES "
Private cDesc2       := "OBJETIVO      : EMITIR O PICKING LIST DE MATERIAS PRIMAS   "
Private cDesc3       := "PER.UTILIZACAO: DIARIA                                     "
Private cCabDet      := "ORTR024                         UN:                             EMISSAO:"
//                      "ORTR024                        UN: 03                         EMISSAO: 99/99/9999"
//                                10        20        30        40        50        60        70        80
//                       012345678901234567890123456789012345678901234567890123456789012345678901234567890
Private cCabDet2    := "REQUISICAO DE MATERIA PRIMA DOS PRODUTOS EM PRODUCAO:                     PAG:"
//                     "REQUISICAO DE MATERIA PRIMA DOS PROUTOS EM PRODUCAO: 99/99/9999          PAG: 001"
Private cCabDet3    := "                                             CODIGO: RQO-09/001              "
Private titulo         := "REQ. MATERIA PRIMA DA PRODUCAO "
Private nLin        := 80
Private limite      := 80
Private tamanho     := "P"
Private nomeprog    := "ORTR024"
Private nTipo       := 15
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private m_pag       := 01
Private wnrel       := 	"ORTR024"
Private cPerg       := 	"ORT024"
Private cString     := 	"SC5"
Private Cabec1		:=	"CODIGO     |DESCRICAO                     |UN|   |QUANT         |     CONTROLE"
Private Cabec2		:=	"                                                   M2      MT.LIN"
Private Cabec3		:=	"CODIGO     |DESCRICAO                     |UN|   QUANT    |Peso| QU.BLOCO  "
Private aEmb		:=	{}
Private aBloco		:=	{}


ValidPerg(cPerg)
Pergunte(cPerg, .F.)

dbSelectArea("SC6")
dbOrderNickName("PSC61")

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.F.,Tamanho,,.T.)


If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

titulo         := "REQ. MATERIA PRIMA DA PRODUCAO: "+DTOC(MV_PAR03)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

RptStatus({|| RunReport() },Titulo)
Return



*******************************************************************************
* Funcao : RUNREPORT   * Autor : Cleverson Luiz Schafer  * Data : 17/03/2006  *
*******************************************************************************
* Descricao : Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTASUS      *
*             monta a janela com a regua de processamento do relatorio.       *
*******************************************************************************
* Uso       : ORTR024                                                         *
*******************************************************************************

Static Function RunReport()

Local cQuery   := ""
Local cEmb     := ""
Local nTotEsp  := 0
Local nTotPec  := 0
Local nTotPes  := 0
Local cCodBas  := ""
LOCAL CGRUPO   := ""
Local nTotCdb  := 0
Local cCodPrP  := ""
Local cNumOpP  := ""
Local nValSEUM := 0
Local _aTotalMP:= {}
Local _nFator  := 0
Local _nPos	   := 0
Local _cGrupo  := ''
Local _cOrdem  := ''
Local _nSegUM  := 0  
Local cXModelo := ''
Local nXQTDEMB := 0.00
Local aResult  := {}
Private _aEstrut:={}

dbSelectArea("SC6")
dbOrderNickName("PSC61")

nCont := LASTREC()
/*
cQuery:="SELECT SC2.C2_PRODUTO, sum(SC2.C2_QUANT) TOTAL, case when SB1.B1_QB=0 then 1 else SB1.B1_QB end as B1_QB "
cQuery+=" FROM "+RetSqlName("SC2")+" SC2, "+RetSqlName('SB1')+" SB1 "
cQuery+=" WHERE SC2.D_E_L_E_T_ = ' ' and SB1.D_E_L_E_T_<>'*' "
cQuery+="  AND SC2.C2_FILIAL  = '"  + XFILIAL("SC2") + "' and SB1.B1_FILIAL='"+xFilial('SB1')+"'"
cQuery+="  AND SC2.C2_DATPRI   = '"  + DTOS(MV_PAR03) + "' "
cQuery+="  AND SC2.C2_NUM   >= '" + MV_PAR01       + "' "
cQuery+="  AND SC2.C2_NUM   <= '" + MV_PAR02       + "' "
cQuery+="  AND SC2.C2_PRODUTO=SB1.B1_COD "
// Nao considera Blocos e Laminados
//cQuery+="  AND ( SC2.C2_PRODUTO <  '200000000000000' OR SC2.C2_PRODUTO >  '299999999999999' )"
cQuery+=" GROUP BY SC2.C2_PRODUTO, SB1.B1_QB "
cQuery+=" ORDER BY SC2.C2_PRODUTO"
*/
__cQryDel	:=	"DELETE totconsumo"+SM0->M0_CODIGO

TCSQLEXEC(__cQryDel)

TCSQLEXEC("COMMIT")

If TCSPExist("CONSUMO"+SM0->M0_CODIGO)

	TCSPEXEC("CONSUMO"+SM0->M0_CODIGO,MV_PAR01,MV_PAR02,Dtos(MV_PAR03),MV_PAR04)
	
Else
	Alert("Procedure CONSUMO"+SM0->M0_CODIGO+" não existe!")
	Return
Endif
/*
cQuery	:=	"SELECT   CASE "
cQuery	+=	"            WHEN b1_grupo IN ('265', '772', '861', '5020', '5060') "
cQuery	+=	"               THEN 0 "
cQuery	+=	"            WHEN b1_grupo = '5030' "
cQuery	+=	"               THEN 8 "
cQuery	+=	"            WHEN bm_xsubgru IN ('20001I', '20002I', '20009I') "
cQuery	+=	"               THEN 9 "
cQuery	+=	"            ELSE 1 "
cQuery	+=	"         END ord, "
cQuery	+=	"         b1_um,b1_tipconv,b1_conv,b1_grupo, b1_cod, b1_desc, bm_xsubgru, comp, SUM (qtd) QUANT "
cQuery	+=	"    FROM totconsumo"+SM0->M0_CODIGO+", "+RetSqlName("SB1")+" b1, "+RetSqlName("SBM")+" bm "
cQuery	+=	"   WHERE b1_filial = '"+xFilial("SB1")+"' "
cQuery	+=	"     AND bm_filial = '"+xFilial("SBM")+"' "
cQuery	+=	"     AND b1.d_e_l_e_t_ = ' ' "
cQuery	+=	"     AND bm.d_e_l_e_t_ = ' ' "
cQuery	+=	"     AND bm_grupo = b1_grupo "    
cQuery	+=	"     AND b1_cod = comp "
If cEmpAnt == '11'                   
	cQuery	+=	" AND b1_locpad = '01' "
EndIf
cQuery	+=	"GROUP BY b1_um,b1_tipconv,b1_conv,b1_grupo, b1_cod, b1_desc, bm_xsubgru, comp "
cQuery	+=	"ORDER BY b1_grupo, comp, ord "
*/

IF cEmpAnt == "04" .OR. cEmpAnt == "11"  .or. cEmpAnt == '15'  .or. cEmpAnt == '09'   .or. cEmpAnt == '08'    .or. cEmpAnt == '07' 
	cQuery	:=	"SELECT   CASE " +PULA
	cQuery	+=	"            WHEN b1_grupo IN ('265', '772', '861', '5020', '5060') " +PULA
	cQuery	+=	"               THEN 0 " +PULA
	cQuery	+=	"            WHEN b1_grupo = '5030' " +PULA
	cQuery	+=	"               THEN 8 " +PULA
	cQuery	+=	"            WHEN bm_xsubgru IN ('20001I', '20002I', '20009I') " +PULA
	cQuery	+=	"               THEN 9 " +PULA
	cQuery	+=	"            ELSE 1 " +PULA
	cQuery	+=	"         END ord, " +PULA
	cQuery	+=	"        b1_um, " +PULA
	cQuery	+=	"        b1_tipconv, " +PULA
	cQuery	+=	"        b1_conv, " +PULA
	cQuery	+=	"	     b1_xmodelo, " +PULA
//	cQuery	+=	"		 X5_DESCRI, "
	cQuery	+=	"        b1_grupo, " +PULA
	cQuery	+=	"        b1_cod, " +PULA
	cQuery	+=	"        b1_desc, " +PULA
	cQuery	+=	"        bm_xsubgru, " +PULA
	cQuery	+=	"        comp, "
	cQuery	+=	"        SUM(qtd) QUANT "
	cQuery	+=	"   FROM siga.totconsumo"+SM0->M0_CODIGO+", siga."+RetSqlName("SB1")+" b1, siga."+RetSqlName("SBM")+" bm " 	+PULA//, siga."+RetSqlName("SX5")+" X5 "
	cQuery	+=	"   WHERE b1_filial = '"+xFilial("SB1")+"' " +PULA
	cQuery	+=	"    AND bm_filial = '"+xFilial("SBM")+"' " +PULA
	cQuery	+=	"    AND b1.d_e_l_e_t_ = ' ' " +PULA
	cQuery	+=	"    AND bm.d_e_l_e_t_ = ' ' " +PULA
	cQuery	+=	"    AND bm_grupo = b1_grupo " +PULA
	cQuery	+=	"    AND b1_cod = comp " +PULA
//	cQuery	+=	"	 AND X5_TABELA = 'ZD' "
//	cQuery	+=	"	 AND X5_CHAVE = b1_xmodelo "
	cQuery	+=	"  GROUP BY b1_um, " +PULA 
	cQuery	+=	"           b1_tipconv, " +PULA
	cQuery	+=	"           b1_conv, " +PULA
	cQuery	+=	"		    b1_xmodelo, " +PULA
//	cQuery	+=	"		    X5_DESCRI, "
	cQuery	+=	"           b1_grupo, " +PULA
	cQuery	+=	"           b1_cod, " +PULA
	cQuery	+=	"           b1_desc, " +PULA
	cQuery	+=	"           bm_xsubgru, " +PULA
	cQuery	+=	"           comp "
	cQuery	+=	"  ORDER BY b1_grupo, comp, b1_xmodelo, ord " +PULA
ELSE
	cQuery	:=	"SELECT   CASE " +PULA
	cQuery	+=	"            WHEN b1_grupo IN ('265', '772', '861', '5020', '5060') " +PULA
	cQuery	+=	"               THEN 0 " +PULA
	cQuery	+=	"            WHEN b1_grupo = '5030' " +PULA
	cQuery	+=	"               THEN 8 " +PULA
	cQuery	+=	"            WHEN bm_xsubgru IN ('20001I', '20002I', '20009I') " +PULA
	cQuery	+=	"               THEN 9 " +PULA
	cQuery	+=	"            ELSE 1 " +PULA
	cQuery	+=	"         END ord, " +PULA
	cQuery	+=	"        b1_um, " +PULA
	cQuery	+=	"        b1_tipconv, " +PULA
	cQuery	+=	"        b1_conv, "  +PULA
	cQuery	+=	"	     b1_xmodelo, " +PULA
	cQuery	+=	"		 X5_DESCRI, " +PULA
	cQuery	+=	"        b1_grupo, " +PULA
	cQuery	+=	"        b1_cod, " +PULA
	cQuery	+=	"        b1_desc, " +PULA
	cQuery	+=	"        bm_xsubgru, " +PULA
	cQuery	+=	"        comp, "
	//cQuery	+=	"        b1_xqtdemb, "
	cQuery	+=	"        SUM(qtd) QUANT " +PULA
	cQuery	+=	"   FROM siga.totconsumo"+SM0->M0_CODIGO+", siga."+RetSqlName("SB1")+" b1, siga."+RetSqlName("SBM")+" bm, siga."+RetSqlName("SX5")+" X5 " +PULA
	cQuery	+=	"   WHERE b1_filial = '"+xFilial("SB1")+"' " +PULA
	cQuery	+=	"    AND bm_filial = '"+xFilial("SBM")+"' " +PULA
	cQuery	+=	"    AND b1.d_e_l_e_t_ = ' ' " +PULA
	cQuery	+=	"    AND bm.d_e_l_e_t_ = ' ' " +PULA
	cQuery	+=	"    AND X5.d_e_l_e_t_ = ' ' " +PULA//Edilson Leal SSI 112252
	cQuery	+=	"    AND X5.X5_FILIAL= '"+xFilial("SX5")+"'"+PULA ////Edilson Leal SSI 112252
	cQuery	+=	"    AND bm_grupo = b1_grupo "+PULA
	cQuery	+=	"    AND b1_cod = comp "+PULA
	cQuery	+=	"	 AND X5_TABELA = 'ZD' "+PULA
	cQuery	+=	"	 AND X5_CHAVE = b1_xmodelo "+PULA
	If cEmpAnt == '11'                   +PULA
		cQuery	+=	" AND b1_locpad = '01' "+PULA
	EndIf
	cQuery	+=	"  GROUP BY b1_um, " +PULA
	cQuery	+=	"           b1_tipconv, " +PULA
	cQuery	+=	"           b1_conv, " +PULA
	cQuery	+=	"		    b1_xmodelo, " +PULA
	cQuery	+=	"		    X5_DESCRI, " +PULA
	cQuery	+=	"           b1_grupo, " +PULA
	cQuery	+=	"           b1_cod, " +PULA
	cQuery	+=	"           b1_desc, " +PULA
	cQuery	+=	"           bm_xsubgru, " +PULA
	cQuery	+=	"           comp " +PULA
	//cQuery	+=	"           b1_xqtdemb "
	cQuery	+=	"  ORDER BY b1_xmodelo,b1_grupo, comp, ord " +PULA
ENDIF
MemoWrite("C:\ortr024.sql",cQuery)

If Select("QRY") > 0
	dbSelectArea("QRY")
	dbCloseArea()
EndIf

TcQuery cQuery Alias "QRY" New

DbSelectArea("QRY")
dbGoTop()

If Eof()
	MsgInfo("Não existe produção para o parametro informado!","Rel. Requis. MP")
	Return()
EndIf

SetRegua(nCont)

/*
While QRY->(!Eof())
//	_nFator:=QRY->(TOTAL/B1_QB)

_aEstrut:={}
u_fEstrut(QRY->C2_PRODUTO,1) //calcula a estrutura. ESTA INCLUINDO NO VETOR _AESTRUT

IncRegua()

For _nI:=1 to len(_aEstrut)
SB1->(DbSeek(xFilial('SB1')+_aEstrut[_nI][1]))
SBM->(DBSeek(xFilial('SBM')+SB1->B1_GRUPO))


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³A ordem de impressão deve ser tecido + 6 primeiros digitos do ³
//³codigo do produto o codigo abaixo garante essa ordem          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF alltrim(SB1->B1_GRUPO)$'265#772#861#5020#5060'
_cOrdem:='00000'+alltrim(SB1->B1_GRUPO)+SB1->B1_COD
else
_cOrdem:='99999'+alltrim(SB1->B1_GRUPO)+SB1->B1_COD
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calcula a quantidade na segunda unidade de medida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nSegUM:=0
IF SB1->B1_TIPCONV='D' .and. SB1->B1_CONV<>0
//			_nSegUM:=(_aEstrut[_nI][2]*_nFator)/SB1->B1_CONV
_nSegUM:=(_aEstrut[_nI][2])/SB1->B1_CONV
else
//			_nSegUM:=(_aEstrut[_nI][2]*_nFator)*SB1->B1_CONV
_nSegUM:=(_aEstrut[_nI][2])*SB1->B1_CONV
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ja existe a materia prima no vetor _aTotalMP³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nPos:=0
If len(_aTotalMP)>0
_nPos:=aScan(_aTotalMP,{|x| alltrim(x[2])==alltrim(_aEstrut[_nI][1]) })
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Incrementa as quantidades de materia prima³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If _nPos=0 //MP ainda não incluida no _aTotalMP
//			aAdd(_aTotalMP,{_cOrdem, _aEstrut[_nI][1], _aEstrut[_nI][2]*_nFator, _nSegUM, SB1->B1_UM, SB1->B1_DESC, SB1->B1_GRUPO, SBM->BM_XSUBGRU})
aAdd(_aTotalMP,{_cOrdem, _aEstrut[_nI][1], _aEstrut[_nI][2]*QRY->TOTAL, _nSegUM*QRY->TOTAL, SB1->B1_UM, SB1->B1_DESC, SB1->B1_GRUPO, SBM->BM_XSUBGRU})
else
//			_aTotalMP[_nPos][3]+=_aEstrut[_nI][2]*_nFator
_aTotalMP[_nPos][3]+=_aEstrut[_nI][2]*QRY->TOTAL
_aTotalMP[_nPos][4]+=_nSegUM*QRY->TOTAL
endif

Next _nI

QRY->(DbSkip())
EndDO

DbSelectArea("QRY")
DbCloseArea()

aSort(_aTotalMP,,,{|X,Y| X[1]<Y[1] })
*/
SetPrc(0,0)

@ 0,0 psay AVALIMP(limite)

If QRY->(!EOF())
	cXModelo := QRY->B1_XMODELO
	CGRUPO := QRY->B1_GRUPO
	cCodBas := SUBSTR(QRY->B1_COD,1,6)
endif
lImp := .F.
nPag := "001"
_lQuebra := .F.

While QRY->(!EOF())
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	IncRegua()
	
	If QRY->ORD = 8
		
		//EMBALAGENS
		AADD(aEmb,{QRY->B1_COD,QRY->B1_DESC,QRY->B1_UM,QRY->QUANT})
		QRY->(DbSkip())
		Loop
		
	ElseIf	QRY->ORD = 9
		//BLOCOS
		AADD(aBloco,{QRY->B1_COD,QRY->B1_DESC,QRY->B1_UM,QRY->QUANT })
		QRY->(DbSkip())
		Loop
		
	Endif

	IF cEmpAnt <> '04' .and. cEmpAnt <> '11' .and. cEmpAnt <> '15' .and. cEmpAnt <> '09' .and. cEmpAnt <> '08' .and. cEmpAnt <> '07'
		If cXModelo <> QRY->B1_XMODELO //cCodBas <> SUBSTR(QRY->B1_COD,1,6)
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin++                    
			@ nLin,000 psay "Modelo :  " + QRY->B1_XMODELO + " - " + QRY->X5_DESCRI
			nlin++
	//		nlin++
	//		cCodBas := SUBSTR(QRY->B1_COD,1,6)
			cXModelo := QRY->B1_XMODELO   
			_lQuebra := .T.
		EndIf
	ENDIF
	
	If CgRUPO <> QRY->B1_GRUPO 
		If !_lQuebra //cCodBas <> SUBSTR(QRY->B1_COD,1,6)
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin++
			IF cEmpAnt <> '04' .and. cEmpAnt <> '11' .and. cEmpAnt <> '15'  .and. cEmpAnt <> '09' .and. cEmpAnt <> '08' .and. cEmpAnt <> '07'
				@ nLin,000 psay "Modelo :  " + QRY->B1_XMODELO + " - " + QRY->X5_DESCRI    
				nLin++
			ENDIF
		Endif	
		nLin++
		@ nLin,000 psay "Grupo :  " + QRY->B1_GRUPO
		nlin++
		nlin++
//		cCodBas := SUBSTR(QRY->B1_COD,1,6)
		CGRUPO := QRY->B1_GRUPO
	EndIf
	
	if nLin >= 60
		nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin++
		IF cEmpAnt <> '04' .and. cEmpAnt <> '11' .and. cEmpAnt <> '15'  .and. cEmpAnt <> '09'  .and. cEmpAnt <> '08' .and. cEmpAnt <> '07'
			@ nLin,000 psay "Modelo :  " + QRY->B1_XMODELO + " - " + QRY->X5_DESCRI    
			nLin++
		ENDIF
		nLin++
		@ nLin,000 psay "Grupo :  " + QRY->B1_GRUPO
		nlin++
		nlin++
	endif
	
	_lQuebra := .F.

	//              10        20        30        40        50        60        70        80        90       100       110       120       130
	//     0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//    "CODIGO     |DESCRICAO                     |UN|    QUANT|S.UN|    QUANT|CONTROLE"
	//     999999.9999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XX 99,999.99   XX 99,999.99 __________
	
	@ nLin,00 psay substr(QRY->B1_COD,1,6) + "." +substr(QRY->B1_COD,7,4)
	@ nLin,12 psay SUBSTR(QRY->B1_DESC,1,30)
	@ nLin,43 psay QRY->B1_UM
	@ nLin,46 psay QRY->QUANT Picture "@E 99,999.999"
	If	QRY->B1_UM = "M2"
		@ nLin,58 psay Transform(IIF(QRY->B1_TIPCONV = 'D' .And. QRY->B1_CONV <> 0,QRY->QUANT/QRY->B1_CONV,QRY->QUANT*QRY->B1_CONV), "@E 99,999.999")
/*	elseif	QRY->B1_UM = "KG"

			nXQTDEMB := Posicione("SB1",1,XFILIAL("SB1")+QRY->B1_COD,"B1_XQTDEMB")

			IF nXQTDEMB > 0
//				nXQTDEMB := Posicione("SB1",1,XFILIAL("SB1")+QRY->B1_COD,"B1_XQTDEMB")
				@ nLin,52 psay Transform(nXQTDEMB, "@E 999.99")
				@ nLin,57 psay "/"
				@ nLin,58 psay Transform(QRY->QUANT/nXQTDEMB, "@E 9999.999")
			ELSE
				@ nLin,52 psay Transform(001, "@E 9")
				@ nLin,53 psay "/"
				@ nLin,54 psay Transform(QRY->QUANT, "@E 99,999.999")
			ENDIF
*/
	Endif

	@ nLin,70 psay "__________"
	
	nLin++
	
QRY->(DbSkip())	
EndDo

//Imprime resumo de embalagens
Cabec2	:=	" "
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin	:=	9

@ nLin,00 psay "LISTAGEM GERAL DAS EMBALAGENS UTILIZADAS"
nLin++

For i := 1 to Len(aEmb)
	if nLin >= 60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin	:=	9
	endif
	
	@ nLin,00 psay substr(aEmb[i,1],1,6) + "." +substr(aEmb[i,1],7,4)
	@ nLin,12 psay SUBSTR(aEmb[i,2],1,30)
	@ nLin,43 psay aEmb[i,3]
	@ nLin,46 psay aEmb[i,4] Picture "@E 99,999.999"
	
	@ nLin,70 psay "__________"
	
	nLin++
	
Next

//Imprime resumo dos blocos

Cabec2	:=	" "
Cabec(Titulo,Cabec3,Cabec2,NomeProg,Tamanho,nTipo)
nLin	:=	9

@ nLin,00 psay "BLOCOS"
nLin++


For	x	:=	1 To	Len(aBloco)
	
	if nLin >= 60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin	:=	9
	endif
	
	@ nLin,00 psay substr(aBloco[x,1],1,6) + "." +substr(aBloco[x,1],7,4)
	@ nLin,12 psay SUBSTR(aBloco[x,2],1,30)
	@ nLin,43 psay aBloco[x,3]
	@ nLin,46 psay aBloco[x,4] Picture "@E 99,999.999"
	IF	aBloco[x,3] = "KG"
		nXQTDEMB := Posicione("SB1",1,XFILIAL("SB1")+aBloco[x,1],"B1_XQTDEMB")
		IF nXQTDEMB > 0
//			nXQTDEMB := Posicione("SB1",1,XFILIAL("SB1")+aBloco[x,1],"B1_XQTDEMB")
			@ nLin,56 psay "/"
			@ nLin,58 psay Transform(nXQTDEMB, "@E 999.99")
			@ nLin,64 psay Transform(round(aBloco[x,4]/nXQTDEMB,2), "@E 99,999.99")
		ELSE
			@ nLin,56 psay "/"
			@ nLin,58 psay "/1"
			@ nLin,64 psay Transform(round(aBloco[x,4],2), "@E 99,999.99")
		ENDIF
	ENDIF
	nLin++
	
Next



SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return



*******************************************************************************
* Funcao : ValidPerg   * Autor : Cleverson Luiz Schaefer * Data : 17/03/2006  *
*******************************************************************************
* Descricao : Funcao auxiliar para verificacao das perguntas do relatorio.    *
*             Se as mesmas nao existirem, o sistema cria as perguntas.        *
*******************************************************************************
* Uso       : OrtR013                                                         *
*******************************************************************************

Static Function ValidPerg()
***************************

Local aAreaAtu := GetArea()
Local aRegs    := {}
Local i,j

Aadd(aRegs,{cPerg,"01","Da Ord. Producao ","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""   ,"","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Ate Ord. Producao","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""   ,"","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Data Producao    ","","","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SA3","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"04","Tipo Produto     ","","","mv_ch4","N",01,0,0,"C","","mv_par04","Padrao","","","","","Sob-Medida","","","","","Ambos","","","","","","","","","","","","","","",""})


//Cria Pergunta
cPerg := U_AjustaSx1(cPerg,aRegs)

RestArea( aAreaAtu )

Return(.T.)
