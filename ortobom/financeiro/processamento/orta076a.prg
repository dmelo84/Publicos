/*/

Autor     : Ronaldo Pena (Korus Consultoria)
---------------------------------------------------------------------
Data      : 05/03/2007
---------------------------------------------------------------------
Descricao : Impressao do Arquivo de Titulos para Interface
---------------------------------------------------------------------
Partida   : Menu de Usuario


/*/
/*###################################################
# Alteração: SSI 61125     || DATA: 04/06/2018      #
#===================================================#
# Autor: Adriano S Dourado                          #
#===================================================#
# Tratativa do cliente '232766' , Carajas Material  #
# de Construção Ltda. para desconto de VPC apenas   #
# na última parcela do pedido.                      #
###################################################*/

#Include "rwmake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Tbiconn.Ch"

#DEFINE CRLF   Chr(13)+Chr(10)

************************
User Function ORTA076A()
************************
Local cQuery	:= ""

Private cTitulo	:= ""
Private cCabec1	:= ""
Private cPerg	:= "ORTR76"
Private oPrn	:= Nil
Private oFont1	:= Nil
Private oFont2	:= Nil
Private nEsp	:= 50
Private nLin	:= 250
Private nPag	:= 0
Private _cAgruVB  := GetNewPar("MV_XAGRUVB","") //Parâmetro com o Codigo do agurapamento que deve calcular a Verba de Repasse a partir do 
Private _cExcAgru := GetNewPar("MV_XEXCAGR","") //Parâmetro com o Codigo do Cliente que não fará parte do arqupamento. 												
Private lHabilitaVP := AllTrim( GetNewPar( "MV_XHABIVP", "S" ) ) == "S"  // Habilita Integração dos Títulos VP com a Regional

if Type("cChamada") <> "C"
	cChamada := ""
endif

If cChamada = "L"
	cTitulo := "RELATORIO DE CARNETS ENVIADOS PARA REGIONAL"
Else
	cTitulo := "RELATORIO DE DUPLICATAS "
Endif

/*ValidPerg(cPerg)
Pergunte(cPerg, .F.)*/

oFont1	:= TFont():New("Courier New",,11,,.T.)
oFont2	:= TFont():New("Courier New",,11,,.F.)
oPrn	:= TReport():New("ORTA076A",cTitulo,,{|oPrn| GeraRel(oPrn)},cTitulo)

oPrn:HideHeader()
oPrn:HideFooter()
oPrn:SetLandscape()
oPrn:SetEdit(.F.)
oPrn:NoUserFilter()
oPrn:DisableOrietation()
oPrn:PrintDialog()

Return

**************************
Static Function GeraRel()
**************************
Local aParc:={"1","2","3","4","5","6","7","8","9","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}
Local cArq := ""
Local _aVP := {}
Local aPergs	:= {}
Local aRet		:= {}
aTotais := {0,0}

aAdd( aPergs ,{1,"Data Movimento  ",dDataBase,"@d",'.T.',,'.T.',40,.F.})

If !Parambox ( aPergs, "cTitulo", aRet, /* bOk */, /* aButtons */, /* lCentered */, /* nPosX */, /* nPosy */, /* oDlgWizard */, /* cLoad */, .F. /* lCanSave */, /* lUserSave */ )
	Return
EndIf

If cChamada = "L"
	//cTipo := "CN"     // SSI 31468
	cTipo := "'CN'"       // SSI 31468
	cOrigem := "L"
else              
	//cTipo := "DP"     // SSI 31468
	cTipo := "'DP','DPC','PEN'" // SSI 31468
	cOrigem := "A"
endif

cQuery := " SELECT DISTINCT DECODE(E1_TIPO,'PEN','ZZZZZZZZZ',E1_MOTIVO) E1_MOTIVO, "
cQuery += "        E1_PREFIXO, "
cQuery += "        E1_NUM, "
cQuery += "        E1_PARCELA, " 
cQuery += "        E1_TIPO, "
cQuery += "        E1_EMISSAO, "
cQuery += "        E1_VENCTO, "
cQuery += "        E1_NUMBOR, "
cQuery += "        E1_SALDO, "
cQuery += "        F2_VALMERC, "
cQuery += "        F2_DESCONT, "
cQuery += "        F2_DESCZFR, "
cQuery += "        E1_NUMNOTA, "
cQuery += "        E1_SERIE, "
cQuery += "        E1_PEDIDO, "
cQuery += "        E1_VALOR , "
cQuery += "        E1_CLIENTE, "
cQuery += "        E1_LOJA, "
cQuery += "        E1_EMIS1, "

// By Rafael Rezende - 23-03-2017 
cQuery += "        SE1.R_E_C_N_O_ AS NUMRECE1 , "
// Fim 

cQuery += "        C5_NUM, "
cQuery += "        C5_NOTA, "
cQuery += "        C5_SERIE, "
cQuery += "        C5_XACERTO, "
cQuery += "        E1_MOTIVO, "
cQuery += "        E1_XAUTORI, "
cQuery += "        E1_XNUMPRC, "
cQuery += "        A1_NOME, "
cQuery += "        A1_XCODGRU, "
cQuery += "        A1_PESSOA, " 				//SSI-98198 - Vagner Almeida - 17/08/2020
cQuery += "        NVL(C5_XVERREP, 0) C5_XVERREP, "
cQuery += "        NVL(C5_XVEREXT, 0) C5_XVEREXT, "
cQuery += "        NVL(ZH_COMISUN, 0) ZH_COMISUN, "
cQuery += "        A1_MUN, "  
cQuery += "        C5_XTPSEGM, "  
cQuery += "        C5_COTACAO, "  

cQuery += "        (SELECT COUNT(*) " 
cQuery += "         FROM " + RetSqlName("SE1") + " C "
cQuery += "         WHERE C.E1_FILIAL = SE1.E1_FILIAL "
cQuery += "          AND C.E1_TIPO = SE1.E1_TIPO "
cQuery += "          AND C.E1_XORIGEM = SE1.E1_XORIGEM "
cQuery += "          AND C.E1_EMIS1 = SE1.E1_EMIS1 "
cQuery += "          AND C.E1_PEDIDO = SE1.E1_PEDIDO "
cQuery += "          AND C.E1_CLIENTE = SE1.E1_CLIENTE "
cQuery += "          AND C.E1_LOJA = SE1.E1_LOJA "
cQuery += "          AND C.D_E_L_E_T_ = ' ' "
cQuery += "         ) XTOTPARC "
cQuery += "   FROM "+RetSqlName("SE1")+" SE1, "+RetSqlName("SC5")+" SC5, "+RetSqlName("SA1")+" SA1, "+RetSqlName("SF2")+" SF2,"
cQuery += "  "+RetSqlName("SZH")+ " SZH "	
cQuery += "  WHERE SA1.D_E_L_E_T_ = ' ' "
cQuery += "    AND SE1.D_E_L_E_T_ = ' ' "
cQuery += "    AND SF2.D_E_L_E_T_ = ' ' "
cQuery += "    AND SC5.D_E_L_E_T_ = ' ' "
cQuery += "    AND SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
cQuery += "    AND SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery += "    AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' "
if cEmpAnt=="26"
  cQuery += "  AND SF2.F2_FILIAL IN ('01','02') "
Else
  cQuery += "  AND SF2.F2_FILIAL = '"+xFilial("SF2")+"' "
Endif

cQuery += "    AND SE1.E1_TIPO IN ("+cTipo+") "
cQuery += "    AND SE1.E1_XORIGEM = '"+cOrigem+"' "

cQuery += "    AND SE1.E1_EMIS1 = '"+Dtos(MV_PAR01)+"' "
cQuery += "    AND SE1.E1_FILIAL = SC5.C5_FILIAL "
cQuery += "    AND SE1.E1_PEDIDO = SC5.C5_NUM "
/* link para buscar a Verba de Repasse */
cQuery += "    AND SZH.ZH_FILIAL(+) = '" +xFilial("SZH")+ "' "
cQuery += "    AND SZH.D_E_L_E_T_(+) = ' ' "
cQuery += "    AND ZH_CLIENTE(+) = C5_CLIENT "
cQuery += "    AND SZH.ZH_MSBLQL(+) <> '1'    "
cQuery += "    AND ZH_LOJA(+) = C5_LOJACLI "
cQuery += "    AND ZH_SEGMENT(+) = C5_XTPSEGM "
cQuery += "    AND F2_DOC = C5_NOTA "	
cQuery += "    AND F2_SERIE = C5_SERIE "	 
//cQuery += "   AND F2_CLIENTE = C5_CLIENT "			
/* Fim link para buscar a Verba de Repasse */
cQuery += "    AND SE1.E1_CLIENTE = SA1.A1_COD "
cQuery += "    AND SE1.E1_LOJA = SA1.A1_LOJA "                        
//cQuery += "    AND SE1.E1_MOTIVO <> ' ' " // Marcela Coimbra - Não imprimir o relatório caso a geração do arquivo não tenha sido concluida 
cQuery += "  ORDER BY SA1.A1_PESSOA DESC "	//SSI-98198 - Vagner Almeida - 17/08/2020
cQuery += "         , 1 "
cQuery += "         , SE1.E1_EMIS1 "
cQuery += "         , SE1.E1_PREFIXO "
cQuery += "         , SE1.E1_NUM "
cQuery += "         , SE1.E1_PARCELA "
cQuery += "         , SE1.E1_TIPO "

 
Memowrite( "C:\QRY\ORTA076A.SQL", cQuery )

U_ORTQUERY(cQuery, "ORTA076A")

cCabec1	:= "Conferencia de Arquivo de Duplicatas - Nome Do Arquivo : " +ORTA076A->E1_MOTIVO
//cTitulo	:= "RELATORIO DE DUPLICATAS CARTEIRA ENVIADAS PARA REGIONAL-"+iif(Substr(ORTA076A->E1_MOTIVO,2,1)=="I","ITAU","BRADESCO")
If ORTA076A->E1_TIPO == 'DPC'
	cTitulo	:= "RELATORIO DE DUPLICATAS CARTEIRA ENVIADAS PARA REGIONAL"
Else
	cTitulo	:= "RELATORIO DE DUPLICATAS BANCO ENVIADAS PARA REGIONAL-"+iif(Substr(ORTA076A->E1_MOTIVO,2,1)=="I" ,"ITAU","BRADESCO")
Endif

cArq	:= ORTA076A->E1_MOTIVO
cTipoQ  := ORTA076A->e1_tipo
fCabec()   

While ORTA076A->(!Eof())
	if ORTA076A->E1_TIPO =="PEN"
		cl1Parc  := strzero(ascan(aParc,ORTA076A->E1_PARCELA),2)		//SSI 60160
		cl1tparc := "1"
		_nTotParc:= 1
		If ORTA076A->C5_XVERREP > 0 .OR. ORTA076A->C5_XVEREXT > 0
			If ORTA076A->A1_XCODGRU $ "("+AllTrim(_cAgruVB)+")" .or. ORTA076A->C5_XTPSEGM == "8" .or. AllTrim(ORTA076A->C5_COTACAO) $ "ORTP156/OTP156" // Segmento 8 não considera IPI
				// Manter IPI conforme solicitação do William - 08/05/2020
				nValVP    := ROUND(ORTA076A->E1_VALOR * (ORTA076A->C5_XVERREP / 100),2) // Valor da Verba de Repasse sobre valor bruto
				nValExt   := ROUND(ORTA076A->E1_VALOR * (ORTA076A->C5_XVEREXT / 100),2) // Valor da Extra de Repasse sobre valor bruto
				nValComis := ROUND(ORTA076A->E1_VALOR * (ORTA076A->ZH_COMISUN / 100),2) // Valor da Extra de Repasse sobre valor bruto

				_cQuebra := IIf(ORTA076A->E1_CLIENTE $ AllTrim(_cExcAgru),ORTA076A->E1_CLIENTE,ORTA076A->A1_XCODGRU)
				
				//AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->E1_VALOR, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT, nValComis, ORTA076A->ZH_COMISUN, _cQuebra,cl1Parc+'/'+cl1tparc})				//SSI-98198 - Vagner Almeida - 17/08/2020	
				AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->E1_VALOR, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT, nValComis, ORTA076A->ZH_COMISUN, _cQuebra,cl1Parc+'/'+cl1tparc, ORTA076A->A1_PESSOA})	//SSI-98198 - Vagner Almeida - 17/08/2020
			Else
				nValDev   := RetDev(ORTA076A->C5_NOTA,.F.,ORTA076A->C5_SERIE) //O segundo parâmetro indica se será o valor bruto ou valor da mercadoria.
				//nValDev   := nValDev/_nTotParc
				nValVP    := ROUND((ORTA076A->F2_VALMERC/_nTotParc - nValDev) * (ORTA076A->C5_XVERREP/ 100),2) // Valor da Verba de Repasse sobre valor das mercadorias
				nValExt   := ROUND((ORTA076A->F2_VALMERC/_nTotParc - nValDev) * (ORTA076A->C5_XVEREXT/ 100),2) // Valor da Verba de Extra sobre valor das mercadorias
				nValComis := ROUND((ORTA076A->F2_VALMERC/_nTotParc - nValDev) * (ORTA076A->ZH_COMISUN/ 100),2) // Valor de comissão sobre valor das mercadorias
				
				_cQuebra := IIf(ORTA076A->E1_CLIENTE $ AllTrim(_cExcAgru),ORTA076A->E1_CLIENTE,ORTA076A->A1_XCODGRU)
				
				//AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->F2_VALMERC/_nTotParc - nValDev, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT,nValComis, ORTA076A->ZH_COMISUN,_cQuebra,cl1Parc+'/'+cl1tparc})	//SSI-98198 - Vagner Almeida - 17/08/2020	
				AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->F2_VALMERC/_nTotParc - nValDev, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT,nValComis, ORTA076A->ZH_COMISUN,_cQuebra,cl1Parc+'/'+cl1tparc, ORTA076A->A1_PESSOA})		//SSI-98198 - Vagner Almeida - 17/08/2020	
			EndIF
			
			// By Rafael Rezende - 23-03-2017 - Geração das Verbas de Repasse, Extra e de Comissão para Importação pela Regional
			If lHabilitaVP
				
				If nValVP    != 0
					FGravaVP( ORTA076A->NUMRECE1, nValVP, "R" )
				EndIf
				If nValExt   != 0
					FGravaVP( ORTA076A->NUMRECE1, nValExt, "E" )
				EndIf
				If nValComis != 0
					FGravaVP( ORTA076A->NUMRECE1, nValComis, "C" )
				EndIf
				
			EndIf
			// Fim
			
		EndIF
	Else
		If ( nLin >= 2200 .or. cArq<>ORTA076A->E1_MOTIVO) 
		
			
		
			if cArq<>ORTA076A->E1_MOTIVO 
				oPrn:Box(nLin,0000,nLin+nEsp,1800)
				oPrn:Say(nLin,0010,"No de Títulos: " + Transform(aTotais[1],"999,999"),oFont2)
				oPrn:Box(nLin,1800,nLin+nEsp,2060)
				oPrn:Say(nLin,1810,Transform(aTotais[2],"@E 9,999,999.99"),oFont2)
				nLin+=nEsp
				aTotais := {0,0}
			endif
			cCabec1	:= "Conferencia de Arquivo de Duplicatas - Nome Do Arquivo : " +ORTA076A->E1_MOTIVO
			If ORTA076A->E1_TIPO == 'DPC'
				cTitulo	:= "RELATORIO DE DUPLICATAS CARTEIRA ENVIADAS PARA REGIONAL"
			Else
				cTitulo	:= "RELATORIO DE DUPLICATAS BANCO ENVIADAS PARA REGIONAL-"+iif(Substr(ORTA076A->E1_MOTIVO,2,1)=="I","ITAU","BRADESCO")
			Endif
			fCabec()
		Endif
		
		cSerie := ""
		cNota  :=Iif(cChamada = "L",ALLTRIM(ORTA076A->E1_XAUTORI),ORTA076A->C5_NOTA)
		cSerie := Iif(cChamada = "L",ALLTRIM(ORTA076A->E1_XAUTORI),ORTA076A->C5_SERIE)
		cParcel:=strzero(ascan(aParc,ORTA076A->E1_PARCELA),2)
		
		IF cChamada <> "L"
			cQuery := " SELECT ZG_TOTAL "
			cQuery += "   FROM "+RetSqlName("SZG")+" SZG "
			cQuery += "  WHERE SZG.D_E_L_E_T_ = ' ' "
			cQuery += "    AND SZG.ZG_FILIAL = '"+xFilial("SZG")+"' "
			cQuery += "    AND SZG.ZG_NOTA = '"+cNota+"' "
			cQuery += "    AND SZG.ZG_SERIE = '"+cSerie+"' "
			cQuery += "    AND SZG.ZG_PARC = '"+cParcel+"' "
			U_ORTQUERY(cQuery, "ORTA076A_2")
			cZG_TOTAL:=ORTA076A_2->ZG_TOTAL
			ORTA076A_2->(dbCloseArea())
			
			
		else
			cZG_TOTAL := ALLTRIM(STR(ORTA076A->E1_XNUMPRC))
		endif
		
		cl1Parc:=cParcel
		If val(cZG_TOTAL) > 9
			If val(cl1Parc) < 11
				cl1tparc:="0"
			ElseIf val(cl1Parc) < 21
				cl1tparc:="1"
			Else
				cl1tparc:="2"
			endif
		else
			cl1tparc:=substr(cZG_TOTAL,2,1)
		endif
		cl1parc:=substr(cl1parc,2,1)
		
		If cChamada = "L"
			oPrn:Box(nLin,0000,nLin+nEsp,0200)
			oPrn:Say(nLin,0010,Padl(Alltrim(ORTA076A->E1_XAUTORI),9,'0'),oFont2)
			oPrn:Box(nLin,0200,nLin+nEsp,0300)
			oPrn:Say(nLin,0210,Padl(Alltrim(str(ascan(aParc,ORTA076A->E1_PARCELA))),2,'0'),oFont2)
		Else
			oPrn:Box(nLin,0000,nLin+nEsp,0200)
			oPrn:Say(nLin,0010,ORTA076A->C5_NOTA,oFont2)
			oPrn:Box(nLin,0200,nLin+nEsp,0300)
			oPrn:Say(nLin,0210,cl1Parc+'/'+cl1tparc,oFont2)
			
			nValVP    := 0
			nValExt   := 0
			nValComis := 0
			_nTotParc := IIf(ORTA076A->XTOTPARC < 1,1,ORTA076A->XTOTPARC)
			If ORTA076A->C5_XVERREP > 0 .OR. ORTA076A->C5_XVEREXT > 0
/*			 if cEmpAnt="08" .and. ORTA076A->E1_CLIENTE=="232766"         // SSI 61125 // Cliente 232766 da Emp.08 deduz VPC da ultima parcela.
			   If  ORTA076A->E1_PARCELA == cl1tparc  
					nValVP    := (ORTA076A->E1_VALOR * VAL(cl1tparc))  * (ORTA076A->C5_XVERREP / 100) // Valor da Verba de Repasse sobre valor bruto
					nValExt   := (ORTA076A->E1_VALOR * VAL(cl1tparc))  * (ORTA076A->C5_XVEREXT / 100) // Valor da Extra de Repasse sobre valor bruto
					nValComis := (ORTA076A->E1_VALOR * VAL(cl1tparc))  * (ORTA076A->ZH_COMISUN / 100) // Valor da Extra de Repasse sobre valor bruto
					
					If cEmpAnt == '21' // C5_XTPSEGM
					
						_cQuebra := ORTA076A->E1_TIPO
	
					Else
	
						_cQuebra := IIf(ORTA076A->E1_CLIENTE $ AllTrim(_cExcAgru),ORTA076A->E1_CLIENTE,ORTA076A->A1_XCODGRU)
					
					EndIf
						
					//AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->E1_VALOR, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT, nValComis, ORTA076A->ZH_COMISUN, _cQuebra,cl1Parc+'/'+cl1tparc}) 				//SSI-98198 - Vagner Almeida - 17/08/2020	
					AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->E1_VALOR, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT, nValComis, ORTA076A->ZH_COMISUN, _cQuebra,cl1Parc+'/'+cl1tparc, ORTA076A->A1_PESSOA})	//SSI-98198 - Vagner Almeida - 17/08/2020	
			   Else 
			   
			   
				If cEmpAnt == '21' // C5_XTPSEGM
				
					_cQuebra := ORTA076A->E1_TIPO

				Else

					_cQuebra := IIf(ORTA076A->E1_CLIENTE $ AllTrim(_cExcAgru),ORTA076A->E1_CLIENTE,ORTA076A->A1_XCODGRU)
				
				EndIf
				
				
					//AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->E1_VALOR, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT, nValComis, ORTA076A->ZH_COMISUN, _cQuebra,cl1Parc+'/'+cl1tparc})				//SSI-98198 - Vagner Almeida - 17/08/2020
					AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->E1_VALOR, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT, nValComis, ORTA076A->ZH_COMISUN, _cQuebra,cl1Parc+'/'+cl1tparc, ORTA076A->A1_PESSOA})	//SSI-98198 - Vagner Almeida - 17/08/2020
				
			   EndIf    
			 Else
*/
				If ORTA076A->A1_XCODGRU $ "("+AllTrim(_cAgruVB)+")" .or. ORTA076A->C5_XTPSEGM == "8" .or. AllTrim(ORTA076A->C5_COTACAO) $ "ORTP156/OTP156" // Segmento 8 não considera IPI
					// Manter IPI conforme solicitação do William - 08/05/2020
					//				nValDev := RetDev(ORTA076A->C5_NOTA,.T.) //O segundo parâmetro indica se será o valor bruto ou valor da mercadoria.
					nValVP    := ROUND(ORTA076A->E1_VALOR * (ORTA076A->C5_XVERREP / 100),2) // Valor da Verba de Repasse sobre valor bruto
					nValExt   := ROUND(ORTA076A->E1_VALOR * (ORTA076A->C5_XVEREXT / 100),2) // Valor da Extra de Repasse sobre valor bruto
					nValComis := ROUND(ORTA076A->E1_VALOR * (ORTA076A->ZH_COMISUN / 100),2) // Valor da Extra de Repasse sobre valor bruto
					
					_cQuebra := IIf(ORTA076A->E1_CLIENTE $ AllTrim(_cExcAgru),ORTA076A->E1_CLIENTE,ORTA076A->A1_XCODGRU)
					
					//AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->E1_VALOR, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT, nValComis, ORTA076A->ZH_COMISUN, _cQuebra,cl1Parc+'/'+cl1tparc})				//SSI-98198 - Vagner Almeida - 17/08/2020
					AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->E1_VALOR, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT, nValComis, ORTA076A->ZH_COMISUN, _cQuebra,cl1Parc+'/'+cl1tparc, ORTA076A->A1_PESSOA})	//SSI-98198 - Vagner Almeida - 17/08/2020
				Else
					nValDev   := RetDev(ORTA076A->C5_NOTA,.F.,ORTA076A->C5_SERIE) //O segundo parâmetro indica se será o valor bruto ou valor da mercadoria.
					nValDev   := nValDev/_nTotParc
					nValVP    := ROUND((ORTA076A->F2_VALMERC/_nTotParc - nValDev) * (ORTA076A->C5_XVERREP/ 100),2) // Valor da Verba de Repasse sobre valor das mercadorias
					nValExt   := ROUND((ORTA076A->F2_VALMERC/_nTotParc - nValDev) * (ORTA076A->C5_XVEREXT/ 100),2) // Valor da Verba de Extra sobre valor das mercadorias
					nValComis := ROUND((ORTA076A->F2_VALMERC/_nTotParc - nValDev) * (ORTA076A->ZH_COMISUN/ 100),2) // Valor de comissão sobre valor das mercadorias
					
					_cQuebra := IIf(ORTA076A->E1_CLIENTE $ AllTrim(_cExcAgru),ORTA076A->E1_CLIENTE,ORTA076A->A1_XCODGRU)
													
					//AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->F2_VALMERC/_nTotParc - nValDev, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT,nValComis, ORTA076A->ZH_COMISUN,_cQuebra,cl1Parc+'/'+cl1tparc})			//SSI-98198 - Vagner Almeida - 17/08/2020
					AADD(_aVP,{ORTA076A->C5_XACERTO, AllTrim(ORTA076A->C5_NOTA), ORTA076A->C5_NUM, ORTA076A->A1_NOME, ORTA076A->F2_VALMERC/_nTotParc - nValDev, nValVP, ORTA076A->C5_XVERREP, nValExt, ORTA076A->C5_XVEREXT, nValComis, ORTA076A->ZH_COMISUN, _cQuebra, cl1Parc+'/'+cl1tparc, ORTA076A->A1_PESSOA})	//SSI-98198 - Vagner Almeida - 17/08/2020
				EndIF
//			 EndIf	
				// By Rafael Rezende - 23-03-2017 - Geração das Verbas de Repasse, Extra e de Comissão para Importação pela Regional
				If lHabilitaVP
					
					If nValVP    != 0
						FGravaVP( ORTA076A->NUMRECE1, nValVP, "R" )
					EndIf
					If nValExt   != 0
						FGravaVP( ORTA076A->NUMRECE1, nValExt, "E" )
					EndIf
					If nValComis != 0
						FGravaVP( ORTA076A->NUMRECE1, nValComis, "C" )
					EndIf
					
				EndIf
				// Fim
				
			EndIF
		Endif
		oPrn:Box(nLin,0300,nLin+nEsp,0440)
		oPrn:Say(nLin,0310,ORTA076A->E1_PEDIDO,oFont2)
		oPrn:Box(nLin,0440,nLin+nEsp,0660)
		oPrn:Say(nLin,0450,DToC(SToD(ORTA076A->E1_VENCTO)),oFont2)
		oPrn:Box(nLin,0660,nLin+nEsp,1480)
		oPrn:Say(nLin,0670,ORTA076A->A1_NOME,oFont2)
		oPrn:Box(nLin,1480,nLin+nEsp,1800)
		oPrn:Say(nLin,1490,ORTA076A->A1_MUN,oFont2)
		oPrn:Box(nLin,1800,nLin+nEsp,2060)
		oPrn:Say(nLin,1810,Transform(ORTA076A->E1_VALOR ,"@E 9,999,999.99"),oFont2)
		oPrn:Box(nLin,2060,nLin+nEsp,2240)
		oPrn:Say(nLin,2070,DToC(SToD(ORTA076A->E1_EMIS1)),oFont2)
		oPrn:Box(nLin,2240,nLin+nEsp,2340)
		oPrn:Say(nLin,2250,AllTrim(ORTA076A->E1_TIPO),oFont2)
		nLin += nEsp
		
		aTotais[1] ++
		aTotais[2] += ORTA076A->E1_VALOR
		
		cArq:= ORTA076A->E1_MOTIVO
		cTipoQ := ORTA076A->e1_tipo
		
	Endif
	ORTA076A->(DbSkip())
EndDo

oPrn:Box(nLin,0000,nLin+nEsp,1800)
oPrn:Say(nLin,0010,"No de Títulos: " + Transform(aTotais[1],"999,999"),oFont2)
oPrn:Box(nLin,1800,nLin+nEsp,2060)
oPrn:Say(nLin,1810,Transform(aTotais[2],"@E 9,999,999.99"),oFont2)
nLin+=nEsp

ORTA076A->(dbCloseArea())

If Len(_aVP) > 0

	//Ordenando por Agrupamento /Cliente, Nota e Parcela
	ASORT(_aVP, , , { | x,y | (x[12]+Str(x[7])+x[2]+x[13]) < (y[12]+Str(y[7])+y[2]+Y[13]) } )
	cCabec1	:= "Conferencia de Arquivo de Duplicatas - Verba de Repasse " //+ORTA076A->E1_MOTIVO
	//cTitulo	:= "RELATORIO DE DUPLICATAS CARTEIRA ENVIADAS PARA REGIONAL-"+iif(Substr(ORTA076A->E1_MOTIVO,2,1)=="I","ITAU","BRADESCO")
	cTitulo	:= "RELATORIO DE DUPLICATAS - VERBA DE REPASSE"	
/*
	If ORTA076A->E1_TIPO == 'DPC'
		cTitulo	:= "RELATORIO DE DUPLICATAS - VERBA DE REPASSE"
	Else
		cTitulo	:= "RELATORIO DE DUPLICATAS BANCO ENVIADAS PARA REGIONAL-"+iif(Substr(ORTA076A->E1_MOTIVO,2,1)=="I","ITAU","BRADESCO")
	Endif
*/
	fCabecVP(AllTrim(_aVP[1][12]) + " - " + AllTrim(_aVP[1][4]), IIF(_aVP[1][10] > 0 ,.T.,.F.)) //[10] - Valor de Comsissão	//SSI-98198 - Vagner Almeida - 17/08/2020
	_nTot 		:= 0
	_ntotVal 	:= 0
	_ntotVP 	:= 0
	_ntotExt 	:= 0
	_ntotComis	:= 0
	_cCodGru    := _aVP[1][12]
	_nVerbaR    := _aVP[1][07]		//NÃO AGRUPAR VERBAS DIFERENTES - SSI 46718

	For _i := 1 to Len(_aVP)
			
		If _aVP[_i][14] == "J"	//SSI-98198 - Vagner Almeida - 17/08/2020
		
			//If AllTrim(_cCodGru) <> AllTrim(_aVP[_i][12]) .Or. _nVerbaR <> _aVP[_i][07]	//SSI-98198 - Vagner Almeida - 17/08/2020							
			If AllTrim(_cCodGru) <> AllTrim(_aVP[_i][12])

				nLin += nEsp
				oPrn:Box(nLin,0000,nLin+nEsp,0290)
				oPrn:Say(nLin,0010,"No de Títulos: " + Transform(_nTot,"999,999"),oFont2)
				oPrn:Box(nLin,0290,nLin+nEsp,0850)
				oPrn:Box(nLin,0850,nLin+nEsp,1140)
				oPrn:Say(nLin,0860,Transform(_ntotVal,"@E 9,999,999.99"),oFont2)
				oPrn:Box(nLin,1140,nLin+nEsp,1440)
				oPrn:Say(nLin,1150,Transform(_ntotVP,"@E 9,999,999.99"),oFont2)
				oPrn:Box(nLin,1440,nLin+nEsp,1680)
				oPrn:Box(nLin,1680,nLin+nEsp,1980)
				oPrn:Say(nLin,1690,Transform(_ntotExt,"@E 9,999,999.99"),oFont1)
				oPrn:Box(nLin,1980,nLin+nEsp,2220)
				If _ntotComis > 0
					oPrn:Box(nLin,2220,nLin+nEsp,2520)
					oPrn:Say(nLin,2230,Transform(_ntotComis,"@E 9,999,999.99"),oFont1)
				EndIF
				
				_nTot	 := 0
				_ntotVal := 0
				_ntotVP	 := 0
				_ntotExt 	:= 0
				_ntotComis	:= 0
							
				nLin+=nEsp*3
				
				oPrn:Say(nLin,0400,"                                     ______________________________                                          ",oFont1)
				nLin += nEsp
				oPrn:Say(nLin,0400,"                                          GERÊNCIA FINANCEIRA                                          			",oFont1)
				
				_cCodGru    := _aVP[_i][12]
				_nVerbaR    := _aVP[_i][07]
				
				fCabecVP(AllTrim(_aVP[_i][12]) + " - " + AllTrim(_aVP[_i][4]),IIF(_aVP[_i][10] > 0 ,.T.,.F.))
			EndIF
		
			If nLin >= 2200 
				fCabecVP("",IIF(_aVP[_i][10] > 0 ,.T.,.F.))
			Endif
	
	
			_nMix := u_ORTMIX(AllTrim(_aVP[_i][3]))	//Cálculo do Mix
			
			oPrn:Box(nLin,0000,nLin+nEsp,0220)
			oPrn:Say(nLin,0010,DToC(SToD(_aVP[_i][1])),oFont2) 						//Data do Acerto
			oPrn:Box(nLin,0220,nLin+nEsp,0420)
			oPrn:Say(nLin,0230,AllTrim(_aVP[_i][2]),oFont2) 						//NF
			oPrn:Box(nLin,0420,nLin+nEsp,0520)
			oPrn:Say(nLin,0430,AllTrim(_aVP[_i][13]),oFont1)						//Parc
			oPrn:Box(nLin,0520,nLin+nEsp,0660)
			oPrn:Say(nLin,0530,AllTrim(_aVP[_i][3]),oFont2) 						//Pedido
			oPrn:Box(nLin,0660,nLin+nEsp,0850)
			/*oPrn:Say(nLin,0570,AllTrim(_aVP[_i][4]),oFont2)
			oPrn:Box(nLin,1360,nLin+nEsp,1660)*/
			oPrn:Say(nLin,0670,Transform(_nMix ,"@E 9,999.99"),oFont2) 	//Mix
			oPrn:Box(nLin,0850,nLin+nEsp,1140)
			oPrn:Say(nLin,0860,Transform(_aVP[_i][5] ,"@E 9,999,999.99"),oFont2) 	//Valor
			oPrn:Box(nLin,1140,nLin+nEsp,1440)
			oPrn:Say(nLin,1150,Transform(_aVP[_i][6] ,"@E 9,999,999.99"),oFont2) 	//Verba de Repasse
	
			oPrn:Box(nLin,1440,nLin+nEsp,1680)
			oPrn:Say(nLin,1450,Transform(_aVP[_i][7] ,"@E 999.99"),oFont1) 			// % Verba de Repasse
			oPrn:Box(nLin,1680,nLin+nEsp,1980)
			oPrn:Say(nLin,1690,Transform(_aVP[_i][8],"@E 9,999,999.99"),oFont1) 	// Verba Extra
			oPrn:Box(nLin,1980,nLin+nEsp,2220)
			oPrn:Say(nLin,1990,Transform(_aVP[_i][9] ,"@E 999.99"),oFont1) 			// % Verba Extra
			If _aVP[_i][10] > 0
				oPrn:Box(nLin,2220,nLin+nEsp,2520)
				oPrn:Say(nLin,2230,Transform(_aVP[_i][10],"@E 9,999,999.99"),oFont1)//Valor Comissão
				oPrn:Box(nLin,2520,nLin+nEsp,2760)
				oPrn:Say(nLin,2530,Transform(_aVP[_i][11] ,"@E 999.99"),oFont1) 	//% Comissão
				oPrn:Box(nLin,2520,nLin+nEsp,3500)
				oPrn:Say(nLin,2530,AllTrim(_aVP[_i][12]) + " - " + AllTrim(_aVP[_i][4]),oFont1)		//Código e Nome do Cliente
			Else
				oPrn:Box(nLin,2220,nLin+nEsp,3100)
				oPrn:Say(nLin,2230,AllTrim(_aVP[_i][12]) + " - " + AllTrim(_aVP[_i][4]),oFont1)		//Código e Nome do Cliente

			EndIF
		
			nLin += nEsp
			
			_nTot 		++
			_ntotVal 	+= _aVP[_i][5] //VAlor Liquido
			_ntotVP 	+= _aVP[_i][6] //Verba de Repasse
			_ntotExt  	+= _aVP[_i][8] //Verba extra
			_ntotComis 	+= _aVP[_i][10] //Valor comissão
		
		EndIf
		
	Next _i

	nLin += nEsp
	oPrn:Box(nLin,0000,nLin+nEsp,0290)
	oPrn:Say(nLin,0010,"No de Títulos: " + Transform(_nTot,"999,999"),oFont2)
	oPrn:Box(nLin,0290,nLin+nEsp,0850)
	oPrn:Box(nLin,0850,nLin+nEsp,1140)
	oPrn:Say(nLin,0860,Transform(_ntotVal,"@E 9,999,999.99"),oFont2)
	oPrn:Box(nLin,1140,nLin+nEsp,1440)
	oPrn:Say(nLin,1150,Transform(_ntotVP,"@E 9,999,999.99"),oFont2)
	oPrn:Box(nLin,1440,nLin+nEsp,1680)
	//oPrn:Say(nLin,1170,"% VERBA",oFont1)
	oPrn:Box(nLin,1680,nLin+nEsp,1980)
	oPrn:Say(nLin,1690,Transform(_ntotExt,"@E 9,999,999.99"),oFont1)
	oPrn:Box(nLin,1980,nLin+nEsp,2220)
	//oPrn:Say(nLin,1710,"% VERBA",oFont1)
	If _ntotComis > 0
		oPrn:Box(nLin,2220,nLin+nEsp,2520)
		oPrn:Say(nLin,2230,Transform(_ntotComis,"@E 9,999,999.99"),oFont1)
/*		oPrn:Box(nLin,2240,nLin+nEsp*2,2480)
		oPrn:Say(nLin,2250,"% COMISSÃO",oFont1)*/
	EndIF
			
	
	nLin+=nEsp*3

	oPrn:Say(nLin,0400,"                                     ______________________________                                          ",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0400,"                                          GERÊNCIA FINANCEIRA                                          			",oFont1)
	
EndIf

/*--------------------------------------------------*
 |SSI-98198 - Vagner Almeida - 17/08/2020 - Início	|
 *--------------------------------------------------*/

If Len(_aVP) > 0

	//Ordenando por Agrupamento /Cliente, Nota e Parcela
	ASORT(_aVP, , , { | x,y | (x[12]+Str(x[7])+x[2]+x[13]) < (y[12]+Str(y[7])+y[2]+Y[13]) } )
	cCabec1	:= "Conferencia de Arquivo de Duplicatas - Verba de Repasse " //+ORTA076A->E1_MOTIVO
	//cTitulo	:= "RELATORIO DE DUPLICATAS CARTEIRA ENVIADAS PARA REGIONAL-"+iif(Substr(ORTA076A->E1_MOTIVO,2,1)=="I","ITAU","BRADESCO")
	cTitulo	:= "RELATORIO DE DUPLICATAS - VERBA DE REPASSE"	
/*	
	If ORTA076A->E1_TIPO == 'DPC'
		cTitulo	:= "RELATORIO DE DUPLICATAS - VERBA DE REPASSE"
	Else
		cTitulo	:= "RELATORIO DE DUPLICATAS BANCO ENVIADAS PARA REGIONAL-"+iif(Substr(ORTA076A->E1_MOTIVO,2,1)=="I","ITAU","BRADESCO")
	Endif
*/
	fCabecVP(AllTrim(_aVP[1][12]) + " - " + AllTrim(_aVP[1][4]), IIF(_aVP[1][10] > 0 ,.T.,.F.)) //[10] - Valor de Comsissão
	_nTot 		:= 0
	_ntotVal 	:= 0
	_ntotVP 	:= 0
	_ntotExt 	:= 0
	_ntotComis	:= 0
	_cCodGru   	:= _aVP[1][12]
	_nVerbaR   	:= _aVP[1][07]		//NÃO AGRUPAR VERBAS DIFERENTES - SSI 46718

	For _i := 1 to Len(_aVP)
			
		If _aVP[_i][14] == "F"			

			If nLin >= 2200 
				fCabecVP("",IIF(_aVP[_i][10] > 0 ,.T.,.F.))
			Endif

			_nMix := u_ORTMIX(AllTrim(_aVP[_i][3]))	//Cálculo do Mix
			
			oPrn:Box(nLin,0000,nLin+nEsp,0220)
			oPrn:Say(nLin,0010,DToC(SToD(_aVP[_i][1])),oFont2) 						//Data do Acerto
			oPrn:Box(nLin,0220,nLin+nEsp,0420)
			oPrn:Say(nLin,0230,AllTrim(_aVP[_i][2]),oFont2) 						//NF
			oPrn:Box(nLin,0420,nLin+nEsp,0520)
			oPrn:Say(nLin,0430,AllTrim(_aVP[_i][13]),oFont1)						//Parc
			oPrn:Box(nLin,0520,nLin+nEsp,0660)
			oPrn:Say(nLin,0530,AllTrim(_aVP[_i][3]),oFont2) 						//Pedido
			oPrn:Box(nLin,0660,nLin+nEsp,0850)
			/*oPrn:Say(nLin,0570,AllTrim(_aVP[_i][4]),oFont2)
			oPrn:Box(nLin,1360,nLin+nEsp,1660)*/
			oPrn:Say(nLin,0670,Transform(_nMix ,"@E 9,999.99"),oFont2) 	//Mix
			oPrn:Box(nLin,0850,nLin+nEsp,1140)
			oPrn:Say(nLin,0860,Transform(_aVP[_i][5] ,"@E 9,999,999.99"),oFont2) 	//Valor
			oPrn:Box(nLin,1140,nLin+nEsp,1440)
			oPrn:Say(nLin,1150,Transform(_aVP[_i][6] ,"@E 9,999,999.99"),oFont2) 	//Verba de Repasse
	
			oPrn:Box(nLin,1440,nLin+nEsp,1680)
			oPrn:Say(nLin,1450,Transform(_aVP[_i][7] ,"@E 999.99"),oFont1) 			// % Verba de Repasse
			oPrn:Box(nLin,1680,nLin+nEsp,1980)
			oPrn:Say(nLin,1690,Transform(_aVP[_i][8],"@E 9,999,999.99"),oFont1) 	// Verba Extra
			oPrn:Box(nLin,1980,nLin+nEsp,2220)
			oPrn:Say(nLin,1990,Transform(_aVP[_i][9] ,"@E 999.99"),oFont1) 			// % Verba Extra
			If _aVP[_i][10] > 0
				oPrn:Box(nLin,2220,nLin+nEsp,2520)
				oPrn:Say(nLin,2230,Transform(_aVP[_i][10],"@E 9,999,999.99"),oFont1)//Valor Comissão
				oPrn:Box(nLin,2520,nLin+nEsp,2760)
				oPrn:Say(nLin,2530,Transform(_aVP[_i][11] ,"@E 999.99"),oFont1) 	//% Comissão
				oPrn:Box(nLin,2520,nLin+nEsp,3500)
				oPrn:Say(nLin,2530,AllTrim(_aVP[_i][12]) + " - " + AllTrim(_aVP[_i][4]),oFont1)		//Código e Nome do Cliente
			Else
				oPrn:Box(nLin,2220,nLin+nEsp,3100)
				oPrn:Say(nLin,2230,AllTrim(_aVP[_i][12]) + " - " + AllTrim(_aVP[_i][4]),oFont1)		//Código e Nome do Cliente
			EndIF
		
			nLin += nEsp
			
			_nTot 		++
			_ntotVal 	+= _aVP[_i][5] //VAlor Liquido
			_ntotVP 	+= _aVP[_i][6] //Verba de Repasse
			_ntotExt  	+= _aVP[_i][8] //Verba extra
			_ntotComis 	+= _aVP[_i][10] //Valor comissão
			
		EndIf
		
	Next _i

	nLin += nEsp
	oPrn:Box(nLin,0000,nLin+nEsp,0290)
	oPrn:Say(nLin,0010,"No de Títulos: " + Transform(_nTot,"999,999"),oFont2)
	oPrn:Box(nLin,0290,nLin+nEsp,0850)
	oPrn:Box(nLin,0850,nLin+nEsp,1140)
	oPrn:Say(nLin,0860,Transform(_ntotVal,"@E 9,999,999.99"),oFont2)
	oPrn:Box(nLin,1140,nLin+nEsp,1440)
	oPrn:Say(nLin,1150,Transform(_ntotVP,"@E 9,999,999.99"),oFont2)
	oPrn:Box(nLin,1440,nLin+nEsp,1680)
	//oPrn:Say(nLin,1170,"% VERBA",oFont1)
	oPrn:Box(nLin,1680,nLin+nEsp,1980)
	oPrn:Say(nLin,1690,Transform(_ntotExt,"@E 9,999,999.99"),oFont1)
	oPrn:Box(nLin,1980,nLin+nEsp,2220)
	//oPrn:Say(nLin,1710,"% VERBA",oFont1)
	If _ntotComis > 0
		oPrn:Box(nLin,2220,nLin+nEsp,2520)
		oPrn:Say(nLin,2230,Transform(_ntotComis,"@E 9,999,999.99"),oFont1)
/*		oPrn:Box(nLin,2240,nLin+nEsp*2,2480)
		oPrn:Say(nLin,2250,"% COMISSÃO",oFont1)*/
	EndIF
	
	nLin+=nEsp*3

	oPrn:Say(nLin,0400,"                                     ______________________________                                          ",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0400,"                                          GERÊNCIA FINANCEIRA                                          			",oFont1)
	
EndIf

/*------------------------------------------------------*
 |SSI-98198 - Vagner Almeida - 17/08/2020 - Final 	|
 *------------------------------------------------------*/
Return

**************************
Static Function fCabec()
**************************
oPrn:EndPage()
oPrn:StartPage()
nLin := 50
oPrn:Box(nLin,0005,nLin+nEsp*4,3300)
nLin+=nEsp

nPag++

oPrn:Say(nLin,0010,"HORA: " + Time() + " - (ORTA076A)",oFont1)
oPrn:Say(nLin,3015,"No FOLHA: " + StrZero(nPag,3,0),oFont1)
nLin += nEsp

oPrn:Say(nLin,1100,cTitulo,oFont1)
oPrn:Say(nLin,0010,"EMPRESA: "+cEmpAnt + " / Filial: " + cFilAnt,oFont1)
oPrn:Say(nLin,2925,"EMISSAO: "+dToC(dDataBase),oFont1)
nLin += nEsp*2

oPrn:Box(nLin,0000,nLin+nEsp*3,3300)
oPrn:Say(nlin,0010,"USUARIO         : FINANCEIRO REGIONAL (SETOR DUPLICATAS)",oFont1)
nLin += nEsp
oPrn:Say(nlin,0010,"OBJETIVO        : CONFERIR AS DUPLICATAS COM O RELATÓRIO E ENCAMINHAR ARQUIVO PARA REGISTRO NO BANCO E SISTEMA DA REGIONAL",oFont1)
nLin += nEsp
oPrn:Say(nlin,0010,"PER.UTILIZAÇÃO  : DIÁRIO",oFont1)
nLin += nEsp*2

oPrn:Say(nlin,0010,cCabec1,oFont1)
nLin += nEsp*2

oPrn:Box(nLin,0000,nLin+nEsp,0200)
oPrn:Say(nLin,0010,"PREF/NUM",oFont1)
oPrn:Box(nLin,0200,nLin+nEsp,0300)
oPrn:Say(nLin,0210,"PARC",oFont1)
oPrn:Box(nLin,0300,nLin+nEsp,0440)
oPrn:Say(nLin,0310,"PEDIDO",oFont1)
oPrn:Box(nLin,0440,nLin+nEsp,0660)
oPrn:Say(nLin,0450,"VENCIMENTO",oFont1)
oPrn:Box(nLin,0660,nLin+nEsp,1480)
oPrn:Say(nLin,0670,"NOME DO CLIENTE",oFont1)
oPrn:Box(nLin,1480,nLin+nEsp,1800)
oPrn:Say(nLin,1490,"PRAÇA",oFont1)
oPrn:Box(nLin,1800,nLin+nEsp,2060)
oPrn:Say(nLin,1810,"VALOR TÍTULO",oFont1)
oPrn:Box(nLin,2060,nLin+nEsp,2240)
oPrn:Say(nLin,2070,"ENTRADA",oFont1)
oPrn:Box(nLin,2240,nLin+nEsp,2340)
oPrn:Say(nLin,2250,"TIPO",oFont1)
nLin += nEsp

Return

**************************
Static Function fCabecVp(_cNome, lComis)
**************************
oPrn:EndPage()
oPrn:StartPage()
nLin := 50
oPrn:Box(nLin,0005,nLin+nEsp*4,3300)
nLin+=nEsp

nPag++

oPrn:Say(nLin,0010,"HORA: " + Time() + " - (ORTA076A)",oFont1)
oPrn:Say(nLin,3015,"No FOLHA: " + StrZero(nPag,3,0),oFont1)
nLin += nEsp

oPrn:Say(nLin,1100,cTitulo,oFont1)
oPrn:Say(nLin,0010,"EMPRESA: "+cEmpAnt + " / Filial: " + cFilAnt,oFont1)
oPrn:Say(nLin,2925,"EMISSAO: "+dToC(dDataBase),oFont1)
nLin += nEsp*2

oPrn:Box(nLin,0000,nLin+nEsp*3,3300)
oPrn:Say(nlin,0010,"USUARIO         : FINANCEIRO REGIONAL (SETOR DUPLICATAS)",oFont1)
nLin += nEsp
oPrn:Say(nlin,0010,"OBJETIVO        : CONFERIR AS DUPLICATAS COM O RELATÓRIO E ENCAMINHAR ARQUIVO PARA REGISTRO NO BANCO E SISTEMA DA REGIONAL",oFont1)
nLin += nEsp
oPrn:Say(nlin,0010,"PER.UTILIZAÇÃO  : DIÁRIO",oFont1)
nLin += nEsp*2

oPrn:Say(nlin,0010,cCabec1,oFont1)
nLin += nEsp*2

/*
//SSI-98198 - Vagner Almeida - 17/08/2020 - Início
If !Empty(_cNome)
	oPrn:Say(nLin,0010,"Cliente: " + _cNome,oFont1)
	nLin += nEsp*2
EndIF
//SSI-98198 - Vagner Almeida - 17/08/2020 - Final
*/

oPrn:Box(nLin,0000,nLin+nEsp*2,0220)
oPrn:Say(nLin,0010,"DATA ",oFont1)
oPrn:Box(nLin,0220,nLin+nEsp*2,0420)
oPrn:Say(nLin,0230,"NOTA",oFont1)
oPrn:Box(nLin,0420,nLin+nEsp*2,0520)
oPrn:Say(nLin,0430,"PARC",oFont1)

oPrn:Box(nLin,0520,nLin+nEsp*2,0660)									
oPrn:Say(nLin,0530,"PEDIDO",oFont1)
/*oPrn:Box(nLin,0560,nLin+nEsp*2,1360)
oPrn:Say(nLin,0570,"RAZAO SOCIAL",oFont1)*/
oPrn:Box(nLin,0660,nLin+nEsp*2,0850)									
oPrn:Say(nLin,0670,"MIX",oFont1)
oPrn:Box(nLin,0850,nLin+nEsp*2,1140)
oPrn:Say(nLin,0860,"VALOR",oFont1)
oPrn:Box(nLin,1140,nLin+nEsp*2,1440)
oPrn:Say(nLin,1150,"VERBA DE",oFont1)
oPrn:Box(nLin,1440,nLin+nEsp*2,1680)
oPrn:Say(nLin,1450,"% VERBA",oFont1)
oPrn:Box(nLin,1680,nLin+nEsp*2,1980)
oPrn:Say(nLin,1690,"VERBA DE",oFont1)
oPrn:Box(nLin,1980,nLin+nEsp*2,2220)
oPrn:Say(nLin,1990,"% VERBA",oFont1)
If lComis
	oPrn:Box(nLin,2220,nLin+nEsp*2,2520)
	oPrn:Say(nLin,2230,"COMISSÃO",oFont1)
	oPrn:Box(nLin,2520,nLin+nEsp*2,2760)
	oPrn:Say(nLin,2530,"% COMISSÃO",oFont1)
	oPrn:Box(nLin,2880,nLin+nEsp*2,3500)
	oPrn:Say(nLin,3140,"CLIENTE",oFont1)	//SSI-98198 - Vagner Almeida - 17/08/2020
Else	
	oPrn:Box(nLin,2220,nLin+nEsp*2,3100)
	oPrn:Say(nLin,2480,"CLIENTE",oFont1)	//SSI-98198 - Vagner Almeida - 17/08/2020
EndIF

nLin += nEsp

oPrn:Say(nLin,0010,"DE ACERTO ",oFont1)
oPrn:Say(nLin,0230,"FISCAL",oFont1)
oPrn:Say(nLin,0860,"LIQUIDO",oFont1)
oPrn:Say(nLin,1150,"REPASSE",oFont1)
oPrn:Say(nLin,1450,"REPASSE",oFont1)
oPrn:Say(nLin,1690,"EXTRA",oFont1)
oPrn:Say(nLin,1990,"EXTRA",oFont1)


nLin += nEsp

Return


Static Function ValidPerg()
***************************

Local aAreaAtu := GetArea()
Local aRegs    := {}
Local i,j

Aadd(aRegs,{cPerg,"01","Data Acerto de...:","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//Cria Pergunta
cPerg := U_AjustaSx1(cPerg,aRegs)

RestArea( aAreaAtu )
Return(.T.)


*********************************
Static Function RetDev(cDOC,lTotNota,cSerie)
*********************************

Local nValor := 0
Local cQry   := ""

cQry:=" SELECT SUM(CASE WHEN C5_XVALENT > 0 THEN ROUND((VALPED-C5_XVALENT)*(TOTDEV/VALNF),2) ELSE TOTDEV END) VALDEV "
cQry+=" FROM (SELECT " 
cQry+="              SUM(("
cQry+="  (select sum(d1_quant) From Siga."+ RetSqlName("SD1") + " SD1"
cQry+="   WHERE SD1.D_E_L_E_T_  = ' '                  "
cQry+="   AND SD1.D1_FILIAL   = '"+xFilial("SD1")+"' "
cQry+="   AND SD1.D1_NFORI    = D2_DOC           "
cQry+="   AND SD1.D1_SERIORI  = D2_SERIE         "
cQry+="   AND SD1.D1_COD      = D2_COD           "
//cQry+="   and D1_TES  NOT IN "
//cQry+="   (Select TES From siga.TESNCA"+cEMPANT+"0 ) "
cQry+="   AND SD1.D1_ITEMORI  = D2_ITEM          "
cQry+="   AND SD1.D1_FORNECE  = D2_CLIENTE       "
cQry+="   AND SD1.D1_LOJA     = D2_LOJA          "
cQry+="   AND SD1.D1_EMISSAO  <= C5_XACERTO          "
cQry+="   AND SD1.D1_DTDIGIT  <= C5_XACERTO)          "
cQry+="                  / DECODE(D2_QUANT,0,1,D2_QUANT)) * "+IIF(lTotNota,"D2_TOTAL + D2_VALIPI + D2_ICMSRET","D2_TOTAL")+") TOTDEV, "
cQry+="              SUM("+IIF(lTotNota,"D2_TOTAL+D2_VALIPI+D2_ICMSRET","D2_TOTAL")+") VALNF,         "
cQry+="              SUM((C6_XPRUNIT*C6_QTDVEN)"+IIF(lTotNota,"+ D2_VALIPI + D2_ICMSRET"," " )+" ) VALPED, C5_XVALENT, C5_NUM  "
cQry+="       FROM  (SELECT D2_TOTAL, D2_VALIPI, D2_ICMSRET, D2_QTDEDEV, D2_QUANT, C6_XPRUNIT, C6_QTDVEN, C5_XVALENT, C5_NUM, D2_DOC, D2_SERIE, D2_COD, D2_ITEM, "
cQry+="                     D2_CLIENTE, D2_LOJA, C5_XACERTO                                                                                       "
cQry+="                FROM Siga."+RetSQLName("SD2")+" SD2, "
cQry+="                     Siga."+RetSQLName("SC6")+" SC6, "
cQry+="                     Siga."+RetSQLName("SC5")+" SC5  "
cQry+="               WHERE SD2.D_E_L_E_T_ = ' '                  "
cQry+="                 AND SC5.D_E_L_E_T_ = ' '                  "
cQry+="                 AND SC6.D_E_L_E_T_ = ' '                  "
cQry+="                 AND SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
cQry+="                 AND SC5.C5_FILIAL  = '"+xFilial("SC5")+"' "
cQry+="                 AND SD2.D2_FILIAL  = '"+xFilial("SD2")+"' "
cQry+="                 AND SC5.C5_NUM	   = SD2.D2_PEDIDO		 "
cQry+="                 AND SC6.C6_NUM	   = SD2.D2_PEDIDO		 "
cQry+="                 AND SC6.C6_ITEM	   = SD2.D2_ITEMPV		 "
cQry+="                 AND SD2.D2_DOC     = '"+cDOC+"'          "
cQry+="                 AND SD2.D2_SERIE   = '"+cSerie+"')       "
cQry+="   GROUP BY C5_XVALENT, c5_num)      "
If Select("TRBDEV") > 0 ; TRBDEV->(DbCloseArea()) ; Endif

MemoWrite("C:\ortA076_DEV.sql", cQry)

TcQuery cQry Alias "TRBDEV" New
TRBDEV->(DbGoTop())  
nValor := TRBDEV->VALDEV
If Select("TRBDEV") > 0 ; TRBDEV->(DbCloseArea()) ; Endif

Return(nValor)


// By Rafael Rezende - 23-03-2017 - Geração das Verbas de Repasse, Extra e de Comissão para Importação pela Regional
*----------------------------------------------------------------*
Static Function FGravaVP( nParamRecNoE1, nParamVlrVP, cParamTipo )
*----------------------------------------------------------------*
Local aAreaAnt  := GetArea()
Local aAreaSE1  := SE1->( GetArea() ) 
Local aEstrut   := SE1->( DbStruct() ) 
Local aRegistro := {}                    
Local uConteudo := Nil
Local cParamNomeArq   := ""
 
Default cParamTipo := "R" 

aRegistro	:= {}
DbSelectArea( "SE1" ) 
SE1->( DbGoTo( nParamRecNoE1 ) ) 
if SE1->E1_TIPO == "PEN"
   cParamNomeArq   := "VP" + cEmpAnt
Else
   cParamNomeArq   := "VP" + iif(Empty(SE1->E1_MOTIVO),"",Right( AllTrim( SE1->E1_MOTIVO ), Len( AllTrim( SE1->E1_MOTIVO ) )-2 ))
Endif
For nC := 01 To Len( aEstrut ) 

	cCampoAux := aEstrut[nC][01]
	cCampo 	  := "SE1->" + AllTrim( aEstrut[nC][01] ) 
	uConteudo := Nil
	Do Case 
		Case AllTrim( cCampoAux ) == "E1_XTITCOB"
			If AllTrim( cParamTipo ) == "R" 
				uConteudo := "V" + Replace( AllTrim( SE1->E1_XTITCOB ), "-", "" ) 
			ElseIf AllTrim( cParamTipo ) == "E" 
				uConteudo := "E" + Replace( AllTrim( SE1->E1_XTITCOB ), "-", "" ) 
			Else
				uConteudo := "C" + Replace( AllTrim( SE1->E1_XTITCOB ), "-", "" ) 
			EndIf
		Case AllTrim( cCampoAux ) == "E1_TIPO"
			If AllTrim( cParamTipo ) == "R" 
				uConteudo := "VP" // Verba de Repasse
			ElseIf AllTrim( cParamTipo ) == "E" 
				uConteudo := "VPE" // verba Extra
			Else
				uConteudo := "VPC" // verba Extra
			EndIf
		Case AllTrim( cCampoAux ) == "E1_VALOR"
			uConteudo := nParamVlrVP			
		Case AllTrim( cCampoAux ) == "E1_VALLIQ"
			uConteudo := nParamVlrVP			
		Case AllTrim( cCampoAux ) == "E1_VLCRUZ"
			uConteudo := nParamVlrVP			
		Case AllTrim( cCampoAux ) == "E1_SALDO"
			uConteudo := 0
		Case AllTrim( cCampoAux ) == "E1_BAIXA"
			uConteudo := dDataBase
		Case AllTrim( cCampoAux ) == "E1_ORIGEM"
			uConteudo := "ORTA076"
		Case AllTrim( cCampoAux ) == "E1_HIST" // Título Pai
			uConteudo := SE1->E1_XTITCOB 
		Case AllTrim( cCampoAux ) == "E1_MOTIVO"
			uConteudo := "" // Adequação para o Uso da Trigger que grava o Registro da ArqFin que permite a Importação do movimento pelo job do Dupim
		OtherWise   
			uConteudo := &cCampo
	EndCase                                            
	aAdd( aRegistro, { cCampoAux, uConteudo } ) 
	
Next nC 
                          
DbSelectArea( "SE1" )
DbSetOrder( 01 ) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
If AllTrim( cParamTipo ) == "R" 
	Seek SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + PadR( "VP", TamSX3( "E1_TIPO" )[01] )
ElseIf AllTrim( cParamTipo ) == "E" 
	Seek SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + PadR( "VPE", TamSX3( "E1_TIPO" )[01] )
Else
	Seek SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + PadR( "VPC", TamSX3( "E1_TIPO" )[01] )
EndIf
lAchou := Found()
If RecLock( "SE1", !lAchou ) 

	For nC := 01 To Len( aRegistro ) 

		cCampo  := "SE1->" + AllTrim( aRegistro[nC][01] ) 
		&cCampo := aRegistro[nC][02]

	Next nC 
	SE1->( MsUnLock() )

EndIf	

If RecLock( "SE1", .F. ) 
	SE1->E1_MOTIVO := cParamNomeArq
	SE1->( MsUnLock() ) 
EndIf

RestArea( aAreaSE1 )
RestArea( aAreaAnt )

Return 
// Fim 