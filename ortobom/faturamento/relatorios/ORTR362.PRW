#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO4     บ Autor ณ AP6 IDE            บ Data ณ  15-06-11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function ORTR362


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Relacao de CNPJs Consultados"
Local cPict          := ""




//                               1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//                     01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

//                     XXXXXX XXXXXX XXXXXXXXXXXXXXX XXX.XXX.XXX/XXXX-X  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
Local imprime      := .T.
Local aOrd := {}
Private titulo       := "Relacao de CNPJs Consultados"
Private nLin         := 80
//                                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//                       01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Private Cabec1       := ""
Private Cabec2       := "CARGA   PEDIDO  CODIGO-CLIENTE                    CNPJ                     STATUS                             NOTA FISCAL"
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 80
Private tamanho          := "P"
Private nomeprog         := "ortr362" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "ortr362" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg      := "ortr362"
Private cString := "SC5"
Private nEsp         := 40
Private nLin       := 4000
Private cPedido    := ""
Private aProd      := {}
Private I          := 1
Private nPag       := 1


dbSelectArea("SC5")
dbSetOrder(1)

ValidPerg(cPerg)
Pergunte(cPerg, .T.)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
/*
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
*/

oFont1:= TFont():New("Courier New",,08,,.F.)
oFont1Bold:= TFont():New("Courier New",,08,,.T.) //Negrito
oFont1a:= TFont():New("Courier New",,8,,.F.)
oFont3:= TFont():New("Courier New",,12,,.F.)
oFont4:= TFont():New("Courier New",,12,,.T.)
oFont5:= TFont():New("Courier New",,16,,.T.)
oFont6:= TFont():New("Courier New",,16,,.F.)
oFont7:= TFont():New("Courier New",,08,,.F.)

oPrn:= TReport():New("ORTR362",Titulo,,{|oPrn| fGeraRel(oPrn)},"ORTR362")
oPrn:SetLandscape()
oPrn:PrintDialog()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  15-06-11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function fGeraRel(oPrn) //RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem
cabec1 :="Embarque:"+dtoc(mv_par01)+" a "+dtoc(mv_par02)+" - Carga :"+mv_par03+" a "+mv_par04+" - Situacao :"

IF MV_PAR05 == 1
	cabec1 += " Com Restricoes "
ELSEIF MV_PAR05 == 2
	cabec1 += " Sem Restricoes "
ELSEIF MV_PAR05 == 3
	cabec1 += " Nao Consultado	"
ELSE
	cabec1 += " Todos "
ENDIF

dbSelectArea(cString)
dbSetOrder(1)

cQuery := " SELECT * FROM ( "
cQuery += "  SELECT C5_CLIENTE , A1_EST , A1_CGC , A1_COD || '-' || A1_NOME A1_NOME , C5_XSERASA , C5_XEMBARQ , C5_XOBSERA , C5_NUM, C5_NOTA "
cQuery += "   FROM "+RETSQLNAME("SC5")+" SC5, "+RETSQLNAME("SA1")+" SA1,"+RETSQLNAME("SZQ")+" SZQ "
cQuery += " WHERE SC5.D_E_L_E_T_ = ' '
cQuery += "   AND SZQ.D_E_L_E_T_ = ' '
cQuery += "   AND SA1.D_E_L_E_T_ = ' '
cQuery += "   AND A1_FILIAL = '"+XFILIAL("SA1")+"' "
cQuery += "   AND C5_FILIAL = '"+XFILIAL("SC5")+"' "
cQuery += "   AND ZQ_FILIAL = '"+XFILIAL("SZQ")+"' "
cQuery += "   AND C5_XDTLIB <> ' ' "
cQuery += "   AND C5_XEMBARQ = ZQ_EMBARQ "
cQuery += "   AND C5_CLIENTE = A1_COD "
cQuery += "   AND C5_LOJACLI = A1_LOJA "

if mv_par05 == 1
	cQuery += "   AND C5_XSERASA = 'S' "                                             
endif		                                                                         

if mv_par05 == 2   
	cQuery += "   AND C5_XSERASA IN ('N','P') "
endif		

if mv_par05 == 3
	cQuery += "   AND ( C5_XSERASA = ' ' OR  C5_XSERASA = 'A') "
endif		

cQuery += "   AND C5_XOPER <> '99' "        
cQuery += "   AND C5_TIPO NOT IN ('B', 'D') "
cQuery += "   AND ZQ_DTPREVE between '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cQuery += "   AND ZQ_EMBARQ BETWEEN '"+MV_PAR03+"' and '"+MV_PAR04+"'  "

cQuery += " UNION  "

cQuery += "  SELECT C5_CLIENTE , A2_EST A1_EST , A2_CGC  A2_CGC , A2_COD || '-' || A2_NOME A1_NOME    , C5_XSERASA , C5_XEMBARQ , C5_XOBSERA , C5_NUM, C5_NOTA "
cQuery += "   FROM "+RETSQLNAME("SC5")+" SC5, "+RETSQLNAME("SA2")+" SA2,"+RETSQLNAME("SZQ")+" SZQ "
cQuery += "    WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery += "      AND SZQ.D_E_L_E_T_ = ' ' "
cQuery += "      AND SA2.D_E_L_E_T_ = ' ' "
cQuery += "      AND A2_FILIAL = '"+XFILIAL("SA1")+"' "
cQuery += "      AND C5_FILIAL = '"+XFILIAL("SC5")+"' "
cQuery += "      AND ZQ_FILIAL = '"+XFILIAL("SZQ")+"' "
cQuery += "      AND C5_XDTLIB <> ' ' "
cQuery += "      AND C5_XEMBARQ = ZQ_EMBARQ "
cQuery += "      AND C5_CLIENTE = A2_COD "
cQuery += "      AND C5_LOJACLI = A2_LOJA "
cQuery += "      AND C5_XOPER <> '99' "           
cQuery += "      AND C5_TIPO IN ('B', 'D') "

if mv_par05 == 1
	cQuery += "   AND C5_XSERASA = 'S' "                                             
endif		                                                                         

if mv_par05 == 2
	cQuery += "   AND C5_XSERASA IN ('N','P') "
endif		

if mv_par05 == 3
	cQuery += "   AND ( C5_XSERASA = ' ' OR C5_XSERASA = 'A' ) "
endif		


cQuery += "   AND ZQ_DTPREVE between '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "
cQuery += "   AND ZQ_EMBARQ BETWEEN '"+MV_PAR03+"' and '"+MV_PAR04+"' ) "
cQuery += "   GROUP BY C5_CLIENTE , A1_EST , A1_CGC , A1_NOME   , C5_XSERASA , C5_XEMBARQ , C5_XOBSERA , C5_NUM, C5_NOTA "
cQuery += "   ORDER BY C5_XEMBARQ , C5_NUM , A1_NOME  "
MemoWrit('C:\ORTR362.SQL',cQuery)
TcQuery cQuery New Alias "QRY"
DBSELECTAREA("QRY")

//SetRegua(U_rfRecCount("QRY"))

While !EOF()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica o cancelamento pelo usuario...                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//	IncRegua()
	
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao do cabecalho do relatorio. . .                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	

		If nLin>2100
			ImpCab(oPrn)
			nLin+=nEsp
		Endif
	nLin+=nEsp
//	nLin := nLin + 1
	
	oPrn:Say(nLin,0000,QRY->C5_XEMBARQ,oFont3) //@nLin,000 Psay QRY->C5_XEMBARQ
	oPrn:Say(nLin,0000,SPACE(8)+QRY->C5_NUM,oFont3) //@nLin,007 Psay QRY->C5_NUM
	oPrn:Say(nLin,0000,SPACE(16)+SUBSTR(QRY->A1_NOME,1,30),oFont3)//	@nLin,014 Psay SUBSTR(QRY->A1_NOME,1,15)
	if(len(alltrim(QRY->A1_CGC)))==14
		oPrn:Say(nLin,0000,SPACE(50)+TRANSFORM(ALLTRIM(QRY->A1_CGC),"@R 99.999.999/9999-99"),oFont3)//		@ nLin,030 psay ALLTRIM(QRY->A1_CGC) PICTURE "@R 99.999.999/9999-99"
	ELSE
		oPrn:Say(nLin,0000,SPACE(50)+TRANSFORM(ALLTRIM(QRY->A1_CGC),"@R 999.999.999-99"),oFont3) //		@ nLin,030 psay ALLTRIM(QRY->A1_CGC) PICTURE "@R 999.999.999-99"
	ENDIF
	
	if EMPTY(QRY->C5_XSERASA)
		oPrn:Say(nLin,0000,SPACE(75)+"NAO FOI REALIZADA A CONSULTA",oFont3) //		@nLin,050 Psay "NAO FOI REALIZADA A CONSULTA"
	else
		if UPPER(QRY->C5_XSERASA) == 'N'
			oPrn:Say(nLin,0000,SPACE(75)+"AUTORIZADO P/ FATURAMENTO",oFont3) //			@nLin,050 Psay "AUTORIZADO SERASA P/ FATURAMENTO"
		elseif UPPER(QRY->C5_XSERASA) == 'P'
			oPrn:Say(nLin,0000,SPACE(75)+"AUTORIZADO P/ PRODUCAO",oFont3)//			@nLin,050 Psay "AUTORIZADO SERASA P/ PRODUCAO"
		ELSE                            
			cMenLib := "NAO AUTORIZADO - "+QRY->C5_XOBSERA
	 		oPrn:Say(nLin,0000,SPACE(75)+cMenLib,oFont3)//			@nLin,050 psay substr(cMenLib,1,30)
/*
			cMenLib:=substr(cMenLib,31)
			do while len(AllTrim(cMenLib)) > 0
			    nLin++
				@nLin,030 psay substr(cMenLib,1,50)
				If nLin > 55
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 9
				Endif
				cMenLib:=substr(cMenLib,51)
			enddo
	*/
		ENDIF
		if !EMPTY(QRY->C5_NOTA)
			oPrn:Say(nLin,0000,SPACE(110)+QRY->C5_NOTA,oFont3)
		endif
	ENDIF
	
	nLin+=nEsp // Avanca a linha de impressao
	
	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo

dbSelectArea("QRY")
dbCloseArea()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

*-------------------------*
Static Function ValidPerg()
*-------------------------*
Local aAreaAtu := GetArea()
Local aRegs    := {}
Local i,j

Aadd(aRegs,{cPerg,"01","Embarque de         ","","","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Embarque ate        ","","","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Carga de            ","","","mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"04","Carga Ate           ","","","mv_ch4","C",6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05","Status              ","","","mv_ch5","N",1,0,0,"C","","mv_par05","Com Restricoes","","","","","Sem Restricoes","","","","","Nao Consultado","","","","","Todos","","","","","","","","","",""})

//Cria Pergunta
cPerg := U_AjustaSx1(cPerg,aRegs)
RestArea( aAreaAtu )

Return(.T.)

    
Static Function ImpCab(oPrn)
**************************
Local i:= 1

nLin:=5000
if nLin>=4000
	nPag+=1
	oPrn:EndPage()
	oPrn:SetLandscape()
	//	oPrn:HideHeader()
	oPrn:StartPage()
	nLin:= 5
	nLin+=nEsp
	nLin+=nEsp
//	oPrn:Say(nLin,1370,"RELACAO DE CNPJS CONSULTADOS",oFont5)
	nLin+=nEsp
	nLin+=nEsp
//	oPrn:Say(nLin,1300,"PERIODO DE :"+DTOC(MV_PAR01)+" ATE: "+DTOC(MV_PAR02)+"",oFont4)
	
	oPrn:Say(nLin,0000,SPACE(42)+CABEC1,oFont3)	
	nLin+=nEsp
	//		oPrn:Say(nLin,0005,R,,,eplicate("-",1000),oFont3)
	nLin+=nEsp
	

//	nLin+=nEsp	                                 
	oPrn:Say(nLin,0000,CABEC2,oFont4)
	oPrn:Say(nLin,0005,Replicate("_",1000),oFont4)
	nLin+=nEsp
	
	
endif
Return(oPrn)
