#INCLUDE "TOTVS.CH"



/*/{Protheus.doc} ALRFAT02
Busca Base / Aliquotas de acordo com Tipo de Tributacao do Cliente, 
Exibe Tela para capturar/confirmar valor de Tributos 
Grava dados dos tributos retidos na SC6
@author Leandro Oliveira
@since 27/11/2015
/*/
User Function ALRFAT02() 
	Local lRet := .T.
	Private cNatureza := If( !empty(M->C5_NATUREZ), M->C5_NATUREZ, Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NATUREZ"))
	Private cTribCli  //:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XTRIBES")
	Private lTribA1   //:= If(cTribCli == "F", .T., .F.)
	Private nAlIRCli := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_ALIQIR")
	// Posicoes SC6
	Private nPosVrUnit := nPosVr := 0
	Private nPosPis := nPosCof := nPosCsl := nPosIrf := nPosIns := 0
	Private nPosBsPis := nPosBsCof := nPosBsCsl := nPosBsIrf := nPosBsIns := 0
	Private nPosAlPis := nPosAlCof := nPosAlCsl := nPosAlIrf := nPosAlIns := 0
	// SA1
	Private nA1BsPis := nA1BsCof := nA1BsCsl := nA1BsIrf := nA1BsIns := 0
	Private nA1AlPis := nA1AlCof := nA1AlCsl := nA1AlIrf := nA1AlIns := 0
	// SED
	Private nAlPisNat := nAlCofNat := nAlCslNat := nAlIrfNat := nAlInsNat := 0
	// SC6
	Private nBsPis := nBsCof := nBsCsl := nBsIrf := nBsIns := 0
	Private nAlPis := nAlCof := nAlCsl := nAlIrf := nAlIns := 0
	// Tela
	Private nBCCofins  := nBCCsll    := nBCInss    := nBCIr      := nBCPis     := 0
	Private nPerPis   := nPerCofins := nPerCsll   := nPerIr     := nPerInss   := 0
	Private nVrTotal := nVrPis := nVrCof := nVrCsl := nVrIrf := nVrIns := 0

	DBSELECTAREA("SA1")
	SA1->(DBSETORDER(1))
	SA1->(DBSEEK(XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI  ))

	/*----------------------------------------
	17/09/2018 - Jonatas Oliveira - Compila
		Busca natureza da tabela Customizada
		
	20/06/2019 - Jonatas Oliveira - Compila
		Tratativa para verificar os tributos 
		variaveis na tabela ZZA antes de verificar
		no cadastro de clientes	
	------------------------------------------*/
	DBSELECTAREA("ZZA")
	ZZA->(DBSETORDER(1))//|ZZA_FILIAL+ZZA_CODCLI+ZZA_LOJA|
	If ZZA->(DBSEEK(M->C5_FILIAL + M->C5_CLIENTE + M->C5_LOJACLI ))
		IF !EMPTY(ZZA->ZZA_NATURE)
			cNatureza := ZZA->ZZA_NATURE
		ENDIF
		
		IF !EMPTY(ZZA->ZZA_XTRIBE)
			cTribCli 	:= ZZA->ZZA_XTRIBE
			lTribA1 	:= If(cTribCli == "F", .T., .F.)
		ELSE
			 cTribCli 	:= SA1->A1_XTRIBES
			 lTribA1 	:= If(cTribCli == "F", .T., .F.)
		ENDIF
	Else
		cTribCli 	:= SA1->A1_XTRIBES
		lTribA1 	:= If(cTribCli == "F", .T., .F.)
	Endif
	
	//	If(cTribCli $ "F,V" )   
		

		
	If(empty(cNatureza))
			Alert("Uso da Natureza Obrigatorio!")
			Return .F.
	Endif
		
	MapCampos()
	RecValsPed()
	DefAliqBases()
		
	// ***************************************************************************************
	// HFP - Compila
	// tratamento, para quando a tela customizada, nao for configurada no cliente, 
	// nao entrar nas rotinas abaixo, mesmo que cancelado ela, e calculando erroneamente
	// os impostos.
	// * task imposto calculando IR menor 10
	// ***************************************************************************************
	
	/*
	// Aqui Anterior, abaixo ajustado
	IF 	SA1->A1_XTELTRI == "S"
		IF !(ISBLIND())
			lRet := TelaConf()
		ENDIF
	ELSE
		nVrPis := nBCPis   *(nPerPis/100) 
		nVrCof := nBCCofins*(nPerCofins/100) 
		nVrCsl := nBCCsll  *(nPerCsll/100)
		nVrIns := nBCInss  *(nPerInss/100)
		nVrIrf := nBCIr    *(nPerIr/100)
		lRet := .T.
	ENDIF
	*/
	IF SA1->A1_XTELTRI == "S"
		IF !(ISBLIND())
			lRet := TelaConf()
		ENDIF
	ELSE
		// nao calcula nada, segue o padrao.
		/*
		nVrPis := nBCPis   *(nPerPis/100) 
		nVrCof := nBCCofins*(nPerCofins/100) 
		nVrCsl := nBCCsll  *(nPerCsll/100)
		nVrIns := nBCInss  *(nPerInss/100)
		nVrIrf := nBCIr    *(nPerIr/100)
		*/
		lRet := .f.
	ENDIF

	If(lRet)  // HFP - Compila -- se nao tem tela, nao tem que mudar/gravar nada
		GravaDados()
	Endif

	//		U_setlproc()         // Marca a variavel lProc do fonte do PE (ALRFAT00) pra impedir processamento do PE em Loop  
	//		U_ALRFAT03()

	//	Endif

Return .T.




Static Function MapCampos()
	nPosVrUnit := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_PRCVEN"})
	nPosVr 	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_VALOR"})
	nPosPis 	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XVTRPIS"})
	nPosCof 	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XVTRCOF"})
	nPosCsl 	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XVTRCSL"})
	nPosIrf 	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XVTRIRF"})
	nPosIns 	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XVTRINS"})
	nPosBsPis	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XBSPIS"})
	nPosBsCof	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XBSCOF"})
	nPosBsCsl	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XBSCSL"})
	nPosBsIrf	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XBSIRF"})
	nPosBsIns	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XBSINS"})
	nPosAlPis	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XALPIS"})
	nPosAlCof	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XALCOF"})
	nPosAlCsl	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XALCSL"})
	nPosAlIrf	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XALIRF"})
	nPosAlIns	:= ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XALINS"})
Return



Static Function DefAliqBases()

	nAlPisNat := Posicione("SED",1,xFilial("SED")+cNatureza,"ED_PERCPIS")
	nAlCofNat := Posicione("SED",1,xFilial("SED")+cNatureza,"ED_PERCCOF")
	nAlCslNat := Posicione("SED",1,xFilial("SED")+cNatureza,"ED_PERCCSL")
	nAlIrfNat := If(nAlIRCli > 0, nAlIRCli, Posicione("SED",1,xFilial("SED")+cNatureza,"ED_PERCIRF"))
	nAlInsNat := Posicione("SED",1,xFilial("SED")+cNatureza,"ED_PERCINS")

	/*----------------------------------------
		20/06/2019 - Jonatas Oliveira - Compila
		Tratativa para verificar os tributos 
		variaveis na tabela ZZA antes de verificar
		no cadastro de clientes		
	------------------------------------------*/
	DBSELECTAREA("ZZA")
	ZZA->(DBSETORDER(1))//|ZZA_FILIAL+ZZA_CODCLI+ZZA_LOJA|
	If ZZA->(DBSEEK( xFilial("SC5") + M->C5_CLIENTE + M->C5_LOJACLI ))
		IF 	!EMPTY(ZZA->ZZA_XTEPIS) .OR. ;
			!EMPTY(ZZA->ZZA_XTECOF) .OR. ;
			!EMPTY(ZZA->ZZA_XTECSL) .OR. ;
			!EMPTY(ZZA->ZZA_XTEIRF) .OR. ;
			!EMPTY(ZZA->ZZA_XTEINS) .OR. ;
			ZZA->ZZA_XBSPIS > 0 .OR. ;
			ZZA->ZZA_XBSCOF > 0 .OR. ;
			ZZA->ZZA_XBSCSL > 0 .OR. ;
			ZZA->ZZA_XBSIRF > 0 .OR. ;
			ZZA->ZZA_XBSINS > 0 .OR. ;
			ZZA->ZZA_XALPIS > 0 .OR. ;
			ZZA->ZZA_XALCOF > 0 .OR. ;
			ZZA->ZZA_XALCSL > 0 .OR. ;
			ZZA->ZZA_XALIRF > 0 .OR. ;
			ZZA->ZZA_XALINS > 0
			
			nA1AlPis := if(lTribA1, ZZA->ZZA_XALPIS, 0)
			nA1AlCof := if(lTribA1, ZZA->ZZA_XALCOF, 0)
			nA1AlCsl := if(lTribA1, ZZA->ZZA_XALCSL, 0)
			nA1AlIrf := if(lTribA1, ZZA->ZZA_XALIRF, 0)
			nA1AlIns := if(lTribA1, ZZA->ZZA_XALINS, 0)
		
			nA1BsPis := if(lTribA1, ZZA->ZZA_XBSPIS, 0)
			nA1BsCof := if(lTribA1, ZZA->ZZA_XBSCOF, 0)
			nA1BsCsl := if(lTribA1, ZZA->ZZA_XBSCSL, 0)
			nA1BsIrf := if(lTribA1, ZZA->ZZA_XBSIRF, 0)
			nA1BsIns := if(lTribA1, ZZA->ZZA_XBSINS, 0)
			ELSE
			nA1AlPis := if(lTribA1, getVrA1("A1_XAlPIS"), 0)
			nA1AlCof := if(lTribA1, getVrA1("A1_XAlCOF"), 0)
			nA1AlCsl := if(lTribA1, getVrA1("A1_XAlCSL"), 0)
			nA1AlIrf := if(lTribA1, getVrA1("A1_XAlIRF"), 0)
			nA1AlIns := if(lTribA1, getVrA1("A1_XAlINS"), 0)
		
			nA1BsPis := if(lTribA1, getVrA1("A1_XBSPIS"), 0)
			nA1BsCof := if(lTribA1, getVrA1("A1_XBSCOF"), 0)
			nA1BsCsl := if(lTribA1, getVrA1("A1_XBSCSL"), 0)
			nA1BsIrf := if(lTribA1, getVrA1("A1_XBSIRF"), 0)
			nA1BsIns := if(lTribA1, getVrA1("A1_XBSINS"), 0)
		ENDIF
	Else
		nA1AlPis := if(lTribA1, getVrA1("A1_XAlPIS"), 0)
		nA1AlCof := if(lTribA1, getVrA1("A1_XAlCOF"), 0)
		nA1AlCsl := if(lTribA1, getVrA1("A1_XAlCSL"), 0)
		nA1AlIrf := if(lTribA1, getVrA1("A1_XAlIRF"), 0)
		nA1AlIns := if(lTribA1, getVrA1("A1_XAlINS"), 0)
	
		nA1BsPis := if(lTribA1, getVrA1("A1_XBSPIS"), 0)
		nA1BsCof := if(lTribA1, getVrA1("A1_XBSCOF"), 0)
		nA1BsCsl := if(lTribA1, getVrA1("A1_XBSCSL"), 0)
		nA1BsIrf := if(lTribA1, getVrA1("A1_XBSIRF"), 0)
		nA1BsIns := if(lTribA1, getVrA1("A1_XBSINS"), 0)
	Endif
	
	nBCPis     := if(lTribA1 .and. nA1BsPis > 0, nVrTotal / 100 * nA1BsPis, if(nBsPis > 0, nBsPis, nVrTotal))
	nBCCofins  := if(lTribA1 .and. nA1BsCof > 0, nVrTotal / 100 * nA1BsCof, if(nBsCof > 0, nBsCof, nVrTotal))
	nBCCsll    := if(lTribA1 .and. nA1BsCsl > 0, nVrTotal / 100 * nA1BsCsl, if(nBsCsl > 0, nBsCsl, nVrTotal))
	nBCInss    := if(lTribA1 .and. nA1BsIns > 0, nVrTotal / 100 * nA1BsIns, if(nBsIns > 0, nBsIns, nVrTotal))
	nBCIr      := if(lTribA1 .and. nA1BsIrf > 0, nVrTotal / 100 * nA1BsIrf,  if(nBsIrf > 0, nBsIrf, nVrTotal))
	
	nPerPis    := if(lTribA1 .and. nA1AlPis > 0, nA1AlPis, if(nAlPis > 0, nAlPis, nAlPisNat))
	nPerCofins := if(lTribA1 .and. nA1AlCof > 0, nA1AlCof, if(nAlCof > 0, nAlCof, nAlCofNat))
	nPerCsll   := if(lTribA1 .and. nA1AlCsl > 0, nA1AlCsl, if(nAlCsl > 0, nAlCsl, nAlCslNat))
	nPerIr     := if(lTribA1 .and. nA1AlIrf > 0, nA1AlIrf, if(nAlIrf > 0, nAlIrf, nAlIrfNat))
	nPerInss   := if(lTribA1 .and. nA1AlIns > 0, nA1AlIns, if(nAlIns > 0, nAlIns, nAlInsNat))

Return



Static Function RecValsPed()
	Local nX := 0
	For nX := 1 to Len(aCols)
		If !aCols[nX,Len(aHeader)+1]
			nVrTotal += aCols[nX, nPosVr] 
			nVrPis += aCols[nX, nPosPis] 
			nVrCof += aCols[nX, nPosCof]
			nVrCsl += aCols[nX, nPosCsl]
			nVrIrf += aCols[nX, nPosIrf]
			nVrIns += aCols[nX, nPosIns]
			
			nBsPis += aCols[nX, nPosBsPis] 
			nBsCof += aCols[nX, nPosBsCof]
			nBsCsl += aCols[nX, nPosBsCsl]
			nBsIrf += aCols[nX, nPosBsIrf]
			nBsIns += aCols[nX, nPosBsIns]
			
			nAlPis := if(nAlPis > 0, nAlPis, aCols[nX, nPosAlPis]) 
			nAlCof := if(nAlCof > 0, nAlCof, aCols[nX, nPosAlCof])
			nAlCsl := if(nAlCsl > 0, nAlCsl, aCols[nX, nPosAlCsl])
			nAlIrf := if(nAlIrf > 0, nAlIrf, aCols[nX, nPosAlIrf])
			nAlIns := if(nAlIns > 0, nAlIns, aCols[nX, nPosAlIns])
		Endif
	Next
Return 

Static Function TelaConf()
	Local lRet				:= .F.
	Local nOpcx			:= 0
	Local lEdita
	Local nOldBCPis		:= nVrTotal//nBCPis
	Local nOldBCCofins	:= nVrTotal//nBCCofins
	Local nOldBCCsll		:= nVrTotal//nBCCsll
	Local nOldBCInss		:= nVrTotal//nBCInss
	Local nOldBCIr		:= nVrTotal//nBCIr

	Private nVlrLiq		:= VlrLiq()
	Private nVlrAnt		:= 0
	Private cObserv		:= M->C5_XOBS
    
    nBCPis    := nVrTotal
    nBCCofins := nVrTotal
    nBCCsll   := nVrTotal
    nBCInss   := nVrTotal
	nBCIr     := nVrTotal
	
	SetPrvt("oDlg1","oSay1","oSay2","oSay3","oSay4","oSay5","oSay6","oSay7","oSay8","oSay9","oSay10","oBtn1","oBtn2","oGet1")
	SetPrvt("oGet3","oGet4","oGet5","oGet6","oGet7","oGet8","oGet9","oGet10","oGet11","oGet12","oGet13","oGet14","oGet15","oGet16","oGet17")
	SetPrvt("oCBox1","oCBox2","oCBox3")
	
	oDlg1      := MSDialog():New( 091,232,560,870,"Impostos",,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 050,049,{||"Base Calculo"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2      := TSay():New( 050,121,{||"Percentual"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3      := TSay():New( 050,193,{||"Valor Imposto"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,055,008)
	oSay4      := TSay():New( 066,018,{||"PIS"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,017,008)
	oSay5      := TSay():New( 088,015,{||"COFINS"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,023,008)
	oSay6      := TSay():New( 109,017,{||"CSLL"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,018,008)
	oSay7      := TSay():New( 129,018,{||"INSS"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,016,008)
	oSay8      := TSay():New( 149,021,{||"IR"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,011,008)
	oSay9      := TSay():New( 169,021,{||"Vlr.Liq."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,070,008)
	oSay10     := TSay():New( 189,021,{||"Obs."},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,070,008)

	DbSelectArea('SA1')
	DbSetOrder(1)
	SA1->( DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI)  )
	
	/*----------------------------------------
		20/06/2019 - Jonatas Oliveira - Compila
		Tratativa para verificar os tributos 
		variaveis na tabela ZZA antes de verificar
		no cadastro de clientes		
	------------------------------------------*/
	DBSELECTAREA("ZZA")
	ZZA->(DBSETORDER(1))//|ZZA_FILIAL+ZZA_CODCLI+ZZA_LOJA|
	If ZZA->(DBSEEK(M->C5_FILIAL + M->C5_CLIENTE + M->C5_LOJACLI ))
		IF ZZA->ZZA_XTRIBE == "F"
			lEdita	:= .T.
		ELSE
			lEdita       := Iif (AllTrim(SA1->A1_XTRIBES) == "F", .T., .F.)
		ENDIF
	Else
		lEdita       := Iif (AllTrim(SA1->A1_XTRIBES) == "F", .T., .F.)
	Endif
	
	
//	lEdita       := Iif (AllTrim(SA1->A1_XTRIBES) == "F", .T., .F.)
	
	If lEdita
		oBtn1      := TButton():New( 210,115,"OK",oDlg1,{|| nOpcx := 1,oDlg1:End() },037,012,,,,.T.,,"",,,,.F. )
	Else
		oBtn1      := TButton():New( 210,115,"OK",oDlg1,{|| nOpcx := 1,oDlg1:End() },037,012,,,,.T.,,"",,,,.F. )
		oBtn2      := TButton():New( 210,163,"Cancelar",oDlg1,{|| nOpcx := 0,oDlg1:End() },037,012,,,,.T.,,"",,,,.F. )
	EndIf
	
	
	nVrPis := nBCPis   *(nPerPis/100) 
	nVrCof := nBCCofins*(nPerCofins/100) 
	nVrCsl := nBCCsll  *(nPerCsll/100)
	nVrIns := nBCInss  *(nPerInss/100)
	nVrIrf := nBCIr    *(nPerIr/100)
	
	//oGet2      := TGet():New( 066,049,{|u| If(PCount()>0,nBCPis:=u,nBCPis)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.  ,/*{|| nVrPis:=nBCPis*(nPerPis/100) }*/,.F.,.F.,"","nBCPis",,)
	oGet2      := TGet():New( 066,;
	                          049,;
	                          {|u| If(  PCount()>0, (nVlrAnt := nBCPis, nBCPis:=u), nBCPis )    },;
	                          oDlg1,;
	                          060,;
	                          008,;
	                          '@E 99,999,999,999.99',     ,;
	                          CLR_BLACK,;
	                          CLR_WHITE,;
	                          ,;
	                          ,;
	                          ,;
	                          .T.,;//se setar FALSE o campo some da tela
	                          "",;
	                          ,;
	                          ,;
	                          .F.,;//<--17   WHEN
	                          .F.,  ;//nada ocorre
	                          {||  iif (  AltBase (nBCPis, nOldBCPis) == .T., nVrPis:=nBCPis*(nPerPis/100), nBCPis := nVlrAnt )    }   ,  ;
	                          lEdita/*.F. = deixa editar*/,;//<--20
	                          .F.,;
	                          "",;
	                          "nBCPis",;//<-- 23
	                          ,;
	                          )//<--25

	//oGet3      := TGet():New( 066,121,{|u| If(PCount()>0,nPerPis:=u,nPerPis)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,/*{|| nVrPis:=nBCPis*(nPerPis/100) }*/,.F.,.F.,"","nPerPis",,)
	oGet3      := TGet():New( 066,121,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nPerPis, nPerPis:=u),   ;
	                                              nPerPis        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (  nPerPis <= 100  ,   ;  
	                                                nVrPis:=nBCPis*(nPerPis/100)    ,   ;   
	                                                   (nPerPis := nVlrAnt, ALert ("Percentual deve ser menor ou igual a 100%") )              )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nPerPis",,)
	
	
	
	//oGet4      := TGet():New( 066,193,{|u| If(PCount()>0,nVrPis:=u,nVrPis)},oDlg1,060,008,'@E 99,999,999,999.99'  ,,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,/*{|| nBCPis:=(nVrPis/nPerPis)*100 }*/,.F.,.F.,"","nVrPis",,)
	oGet4      := TGet():New( 066,193,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nVrPis, nVrPis:=u),   ;
	                                              nVrPis        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (   AltVlr ((nVrPis/nPerPis)*100, nOldBCPis) ,   ;  
	                                                nBCPis := (nVrPis/nPerPis)*100   ,   ;   
	                                                   nVrPis := nVlrAnt               )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nVrPis",,)
	
	
	
	//oGet5      := TGet():New( 087,049,{|u| If(PCount()>0,nBCCofins:=u,nBCCofins)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  {||    Iif ( AltBase (nBCCofins, nOldBCCofins) == .T.               ,  (nVrCof:=nBCCofins*(nPerCofins/100) ),                                                     )  },.F.,.F.,"","nBCCofins",,)
	oGet5      := TGet():New( 087,049,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nBCCofins, nBCCofins:=u),   ;
	                                              nBCCofins        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (  AltBase (nBCCofins, nOldBCCofins) == .T.   ,   ;  
	                                                nVrCof:=nBCCofins*(nPerCofins/100)    ,   ;   
	                                                   nBCCofins := nVlrAnt               )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nBCCofins",,)
	
	
	
	//oGet6      := TGet():New( 087,121,{|u| If(PCount()>0,nPerCofins:=u,nPerCofins)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{||    Iif ( nPerCofins <= 100                                      ,   nVrCof:=nBCCofins*(nPerCofins/100)  , Alert('Percentual deve ser menor ou igual a 100%')  )  },.F.,.F.,"","nPerCofins",,)
	oGet6      := TGet():New( 087,121,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nPerCofins, nPerCofins:=u),   ;
	                                              nPerCofins        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (  nPerCofins <= 100  ,   ;  
	                                                nVrCof:=nBCCofins*(nPerCofins/100)    ,   ;   
	                                                   (nPerCofins := nVlrAnt, ALert ("Percentual deve ser menor ou igual a 100%") )              )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nPerCofins",,)
	                                         
	//oGet1      := TGet():New( 087,193,{|u| If(PCount()>0,    (alert('1.A:   u >' + STR(u) + '  nVrCof>' + STR(nVrCof) ) , nVrCof:=u),    (alert('1.B: '  + STR(nVrCof)),nVrCof)  )},oDlg1,060,008,'@E 99,999,999,999.99',  {||    Iif ( AltVlr ((nVrCof/nPerCofins)*100, nOldBCCofins), .T., .F.   )}   ,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  {||  alert('setando'),nBCCofins := (nVrCof/nPerCofins)*100 }    /*  {||    Iif ( AltVlr ((nVrCof/nPerCofins)*100, nOldBCCofins) == .T.  ,  nBCCofins:=(nVrCof/nPerCofins)*100   ,                                                     )  }*/,.F.,.F.,"","nVrCof",,)
	oGet1      := TGet():New( 087,193,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nVrCof, nVrCof:=u),   ;
	                                              nVrCof        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (   AltVlr ((nVrCof/nPerCofins)*100, nOldBCCofins) ,   ;  
	                                                nBCCofins := (nVrCof/nPerCofins)*100   ,   ;   
	                                                   nVrCof := nVlrAnt               )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nVrCof",,)
	
	
	//oGet8      := TGet():New( 108,049,{|u| If(PCount()>0,nBCCsll:=u,nBCCsll)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,      {|| nVrCsl:=nBCCsll*(nPerCsll/100) },.F.,.F.,"","nBCCsll",,)
	oGet8      := TGet():New( 108,049,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nBCCsll, nBCCsll:=u),   ;
	                                              nBCCsll        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (  AltBase (nBCCsll, nOldBCCsll) == .T.   ,   ;  
	                                                nVrCsl :=nBCCsll*(nPerCsll/100)    ,   ;   
	                                                   nBCCsll := nVlrAnt               )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nBCCsll",,)
	
	
	
	
	//oGet7      := TGet():New( 108,121,{|u| If(PCount()>0,nPerCsll:=u,nPerCsll)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,    {|| nVrCsl:=nBCCsll*(nPerCsll/100) },.F.,.F.,"","nPerCsll",,)
	oGet7      := TGet():New( 108,121,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nPerCsll, nPerCsll:=u),   ;
	                                              nPerCsll        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (  nPerCsll <= 100  ,   ;  
	                                                nVrCsl:=nBCCsll*(nPerCsll/100)    ,   ;   
	                                                   (nPerCsll := nVlrAnt, ALert ("Percentual deve ser menor ou igual a 100%") )              )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nPerCsll",,)
	
	
	
	//oGet9      := TGet():New( 108,193,{|u| If(PCount()>0,nVrCsl:=u,nVrCsl)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,        {|| nBCCsll:=(nVrCsl/nPerCsll)*100 },.F.,.F.,"","nVrCsl",,)
	oGet9      := TGet():New( 108,193,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nVrCsl, nVrCsl:=u),   ;
	                                              nVrCsl        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (   AltVlr ((nVrCsl/nPerCsll)*100, nOldBCCsll) ,   ;  
	                                                nBCCsll := (nVrCsl/nPerCsll)*100   ,   ;   
	                                                   nVrCsl := nVlrAnt               )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nVrCsl",,)
	
	
	
	
	
	//oGet11     := TGet():New( 128,049,{|u| If(PCount()>0,nBCInss:=u,nBCInss)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,      {|| nVrIns:=nBCInss*(nPerInss/100) },.F.,.F.,"","nBCInss",,)
	oGet11      := TGet():New( 128,049,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nBCInss, nBCInss:=u),   ;
	                                              nBCInss        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (  AltBase (nBCInss, nOldBCInss) == .T.   ,   ;  
	                                                nVrIns :=nBCInss*(nPerInss/100)    ,   ;   
	                                                   nBCInss := nVlrAnt               )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nBCInss",,)
	
	
	
	//oGet10     := TGet():New( 128,121,{|u| If(PCount()>0,nPerInss:=u,nPerInss)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,    {|| nVrIns:=nBCInss*(nPerInss/100) },.F.,.F.,"","nPerInss",,)
	oGet10      := TGet():New( 128,121,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nPerInss, nPerInss:=u),   ;
	                                              nPerInss        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (  nPerInss <= 100  ,   ;  
	                                                nVrIns:=nBCInss*(nPerInss/100)    ,   ;   
	                                                   (nPerInss := nVlrAnt, ALert ("Percentual deve ser menor ou igual a 100%") )              )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nPerInss",,)
	
	
	
	//oGet12     := TGet():New( 128,193,{|u| If(PCount()>0,nVrIns:=u,nVrIns)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,        {|| nBCInss:=(nVrIns/nPerInss)*100 },.F.,.F.,"","nVrIns",,)
	oGet12      := TGet():New( 128,193,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nVrIns, nVrIns:=u),   ;
	                                              nVrIns        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (   AltVlr ((nVrIns/nPerInss)*100, nOldBCInss) ,   ;  
	                                                nBCInss := (nVrIns/nPerInss)*100   ,   ;   
	                                                   nVrIns := nVlrAnt               )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nVrIns",,)
	
	//oGet14     := TGet():New( 148,049,{|u| If(PCount()>0,nBCIr:=u,nBCIr)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,          {|| nVrIrf:=nBCIr*(nPerIr/100) },.F.,.F.,"","nBCIr",,)
	oGet14      := TGet():New( 148,049,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nBCIr, nBCIr:=u),   ;
	                                              nBCIr        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (  AltBase (nBCIr, nOldBCIr) == .T.   ,   ;  
	                                                nVrIrf :=nBCIr*(nPerIr/100)    ,   ;   
	                                                   nBCIr := nVlrAnt               )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nBCIr",,)
	
	//oGet13     := TGet():New( 148,121,{|u| If(PCount()>0,nPerIr:=u,nPerIr)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,        {|| nVrIrf:=nBCIr*(nPerIr/100) },.F.,.F.,"","nPerIr",,)
	oGet13      := TGet():New( 148,121,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nPerIr, nPerIr:=u),   ;
	                                              nPerIr        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (  nPerIr <= 100  ,   ;  
	                                                nVrIrf:=nBCIr*(nPerIr/100)    ,   ;   
	                                                   (nPerIr := nVlrAnt, ALert ("Percentual deve ser menor ou igual a 100%") )              )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nPerIr",,)
	
	
	
	//oGet15     := TGet():New( 148,193,{|u| If(PCount()>0,nVrIrf:=u,nVrIrf)},oDlg1,060,008,'@E 99,999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,        {|| nBCIr:=(nVrIrf/nPerIr)*100 },.F.,.F.,"","nVrIrf",,)
	oGet15      := TGet():New( 148,193,{|u| If(  PCount()>0,  ; 
	                                            (nVlrAnt := nVrIrf, nVrIrf:=u),   ;
	                                              nVrIrf        ;
	                                         )    },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| ;	                                         
	                                         iif (   AltVlr ((nVrIrf/nPerIr)*100, nOldBCIr) ,   ;  
	                                                nBCIr := (nVrIrf/nPerIr)*100   ,   ;   
	                                                   nVrIrf := nVlrAnt               )    }   ,  ;
	                                         lEdita/*.F.*/,.F.,"","nVrIrf",,)


	oGet16      := TGet():New( 168,193,{ |u| If( PCount() == 0, nVlrLiq, nVlrLiq := u) },;
	                                         oDlg1,060,008,'@E 99,999,999,999.99',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| },;
	                                         .T.,.F.,"","nVlrLiq",,)

	oGet17      := TGet():New( 188,049,{ |u| If( PCount() == 0, cObserv, cObserv := u ) },;
	                                         oDlg1,205,008,'@!',     ,;
	                                         CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,  ;
	                                         {|| },;
	                                         .T.,.F.,"","cObserv",,)

	oDlg1:Activate(,,,.T.)
	
	If(nOpcx == 1)
	lRet :=  .T.
	Endif

return lRet	
 	

Static Function GravaDados()
	Local nX := 0
	For nX := 1 to Len(aCols)
		if !aCols[nX,Len(aHeader)+1]
			
			nVrUnit := aCols[ nX, nPosVrUnit]
		
			aCols[nX, nPosPis] :=  nPerPis/100 	* ( nVrPis / (nPerPis/100)		* (nVrUnit / nVrTotal))
			aCols[nX, nPosCof] :=  nPerCofins/100	* ( nVrCof / (nPerCofins/100) 	* (nVrUnit / nVrTotal))
			aCols[nX, nPosCsl] :=  nPerCsll/100 	* ( nVrCsl / (nPerCsll/100) 	* (nVrUnit / nVrTotal))
			aCols[nX, nPosIrf] :=  nPerIr/100 		* ( nVrIrf / (nPerIr/100) 		* (nVrUnit / nVrTotal))
			aCols[nX, nPosIns] :=  nPerInss/100 	* ( nVrIns / (nPerInss/100)		* (nVrUnit / nVrTotal))
			
			aCols[nX, nPosAlPis] := 	nPerPis    
			aCols[nX, nPosAlCof] := 	nPerCofins
			aCols[nX, nPosAlCsl] :=	nPerCsll
			aCols[nX, nPosAlIrf]	:=	nPerIr
			aCols[nX, nPosAlIns]	:= 	nPerInss
			
			aCols[nX, nPosBsPis] := nBCPis 		* (nVrUnit / nVrTotal)        
			aCols[nX, nPosBsCof] := nBCCofins 	* (nVrUnit / nVrTotal)
			aCols[nX, nPosBsCsl] := nBCCsll    * (nVrUnit / nVrTotal)
			aCols[nX, nPosBsIrf] := nBCIr    * (nVrUnit / nVrTotal)
			aCols[nX, nPosBsIns] := nBCInss		* (nVrUnit / nVrTotal)
		Endif
	Next
Return 



Static Function getVrA1(cCampo)
	Local valor := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,cCampo) 
Return valor


Static function AltBase (nBase, nOldBase)//{|| nVrCof:=nBCCofins*(nPerCofins/100) }
Local lRet := .T.

	If nBase > nOldBase
	lRet := .F.
	Alert ("Não é permitido aumentar a Base de Cálculo!")
	EndIf

return lRet


Static function AltVlr (nBase, nOldBase)
Local lRet := .T.

	If nBase > nOldBase
	lRet := .F.
	Alert ("Este novo valor extrapola a Base original do Pedido. Não é permitido aumentar a Base de Cálculo!")
	EndIf

return lRet


/*/{Protheus.doc} ALRFAT7

consistencias no ato de prep doc saida na tela de pedidos de vendas. 

@author totvs
@since 27/11/2015
/*/

User function ALRFAT7()
	Local lRet          := .T.
	Local cTribCli 		//:= Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, "A1_XTRIBES")
	Local cBloq			:= SC5->C5_XBLQ

/*----------------------------------------
	20/06/2019 - Jonatas Oliveira - Compila
	Tratativa para verificar os tributos 
	variaveis na tabela ZZA antes de verificar
	no cadastro de clientes		
------------------------------------------*/
DbSelectArea('SA1')
DbSetOrder(1)
SA1->( DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI)  )

DBSELECTAREA("ZZA")
ZZA->(DBSETORDER(1))//|ZZA_FILIAL+ZZA_CODCLI+ZZA_LOJA|

	If ZZA->(DBSEEK(SC5->C5_FILIAL + SC5->C5_CLIENTE + SC5->C5_LOJACLI ))
		IF !EMPTY(ZZA->ZZA_XTRIBE)
		cTribCli := ZZA->ZZA_XTRIBE
		ELSE
		cTribCli := SA1->A1_XTRIBES
		ENDIF
	Else
	cTribCli := SA1->A1_XTRIBES
	Endif
	
	If (!Empty(cTribCli) .and. cBloq != "4")
	lRet := MsgNoYes( "Tributos retidos na fonte nao informados. Deseja Gerar o Documento de Saída assim mesmo ?" + CRLF + "Confirma a ação ?" )
	EndIf

	If lRet .And. cBloq == "1"
	lRet := MsgNoYes( "Pedido pertence a um Cliente Novo. Deseja Gerar o Documento de Saída assim mesmo ?" + CRLF + "Confirma a ação ?" )
	EndIf
    
	
return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} VlrLiq
Retorna o Valor Liquido do Pedido

@author Guilherme Santos
@since 11/08/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function VlrLiq()
	Local nRetorno	:= 0
	Local nPosDel		:= Len(aHeader) + 1
	Local nPosVlr		:= Ascan(aHeader, {|x| Upper(AllTrim(x[02])) == "C6_XVLRLIQ"})
	Local nI			:= 0

	If nPosVlr > 0
		For nI := 1 to Len(aCols)
			If !aCols[nI][nPosDel]
				nRetorno += aCols[nI][nPosVlr]
			EndIf
		Next nI
	EndIf

Return nRetorno
