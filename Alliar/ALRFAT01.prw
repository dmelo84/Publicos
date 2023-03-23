#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"   



/*/{Protheus.doc} ALRFAT01
Validacao do cadastro de Clientes
Atualiza o Pedido de vendas conf regra de tratamento de Tributos 
@author Leandro Oliveira
@since 27/11/2015
@version 1.0
/*/
User Function ALRFAT01()
	
	Local cTpTePis  
	Local cTpTeCof  
	Local cTpTeCsl  
	Local cTpTeIrf  
	Local cTpTeIns  
	Local nBsPis 	
	Local nBsCof 	
	Local nBsCsl 	
	Local nBsIrf 	
	Local nBsIns 	
	Local nAlPis 	
	Local nAlCof 	
	Local nAlCsl 	
	Local nAlIrf 	
	Local nAlIns 	
	Local nTest	  	:= 0
	Local lValido   := .T.
	Local nX		  := 0
	Local aPVsPend  := {}
	Local Qry := ""
	
	Private cClieLoja 	:= If(Len(SA1->(A1_COD+A1_LOJA)) == 0, M->(A1_COD+A1_LOJA), SA1->(A1_COD+A1_LOJA))
	Private lFixo //:= If(M->A1_XTRIBES == "F", .T., .F.)
	Private lVariav //:= If(M->A1_XTRIBES == "V", .T., .F.)
	Private lPj := If(M->A1_PESSOA == "J", .T., .F.)
	
	/*----------------------------------------
		20/06/2019 - Jonatas Oliveira - Compila
		Tratativa para verificar os tributos 
		variaveis na tabela ZZA antes de verificar
		no cadastro de clientes		
	------------------------------------------*/
	DBSELECTAREA("ZZA")
	ZZA->(DBSETORDER(1))//|ZZA_FILIAL+ZZA_CODCLI+ZZA_LOJA|
	
	If ZZA->(DBSEEK( xFilial("SC5") + cClieLoja )) 
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
			
			cTpTePis  := ZZA->ZZA_XTEPIS
			cTpTeCof  := ZZA->ZZA_XTECOF
			cTpTeCsl  := ZZA->ZZA_XTECSL
			cTpTeIrf  := ZZA->ZZA_XTEIRF
			cTpTeIns  := ZZA->ZZA_XTEINS
			nBsPis 	  := ZZA->ZZA_XBSPIS
			nBsCof 	  := ZZA->ZZA_XBSCOF
			nBsCsl 	  := ZZA->ZZA_XBSCSL
			nBsIrf 	  := ZZA->ZZA_XBSIRF
			nBsIns 	  := ZZA->ZZA_XBSINS
			nAlPis 	  := ZZA->ZZA_XALPIS
			nAlCof 	  := ZZA->ZZA_XALCOF
			nAlCsl 	  := ZZA->ZZA_XALCSL
			nAlIrf 	  := ZZA->ZZA_XALIRF
			nAlIns 	  := ZZA->ZZA_XALINS
		ELSE
			cTpTePis  := M->A1_XTEPIS
			cTpTeCof  := M->A1_XTECOF
			cTpTeCsl  := M->A1_XTECSL
			cTpTeIrf  := M->A1_XTEIRF
			cTpTeIns  := M->A1_XTEINS
			nBsPis 	  := M->A1_XBSPIS
			nBsCof 	  := M->A1_XBSCOF
			nBsCsl 	  := M->A1_XBSCSL
			nBsIrf 	  := M->A1_XBSIRF
			nBsIns 	  := M->A1_XBSINS
			nAlPis 	  := M->A1_XALPIS
			nAlCof 	  := M->A1_XALCOF
			nAlCsl 	  := M->A1_XALCSL
			nAlIrf 	  := M->A1_XALIRF
			nAlIns 	  := M->A1_XALINS
		ENDIF 
		
		IF ZZA->ZZA_XTRIBE == "F"
			lFixo := .T.
		ELSE
			lFixo := If(M->A1_XTRIBES == "F", .T., .F.)
			
		ENDIF 
		
		IF ZZA->ZZA_XTRIBE == "V"
			lVariav := .T.
		ELSE
			lVariav := If(M->A1_XTRIBES == "V", .T., .F.)
			
		ENDIF 
	ELSE
		lFixo 	:= If(M->A1_XTRIBES == "F", .T., .F.)
		
		lVariav := If(M->A1_XTRIBES == "V", .T., .F.)
		
		cTpTePis  := M->A1_XTEPIS
		cTpTeCof  := M->A1_XTECOF
		cTpTeCsl  := M->A1_XTECSL
		cTpTeIrf  := M->A1_XTEIRF
		cTpTeIns  := M->A1_XTEINS
		nBsPis 	  := M->A1_XBSPIS
		nBsCof 	  := M->A1_XBSCOF
		nBsCsl 	  := M->A1_XBSCSL
		nBsIrf 	  := M->A1_XBSIRF
		nBsIns 	  := M->A1_XBSINS
		nAlPis 	  := M->A1_XALPIS
		nAlCof 	  := M->A1_XALCOF
		nAlCsl 	  := M->A1_XALCSL
		nAlIrf 	  := M->A1_XALIRF
		nAlIns 	  := M->A1_XALINS
	Endif
	
	
	If(lFixo .and. lPj)
		If(len(alltrim(cTpTePis) + alltrim(cTpTeCof) + alltrim(cTpTeCsl) + alltrim(cTpTeIrf) + alltrim(cTpTeIns)) < 5)
			Alert("Favor definir o tipo de tratamento especifico para cada tributo (PIS, COFINS, CSLL, IRRF, INSS")
			lValido := .F.
		EndIf
		nTest := TestaVal("PIS", cTpTePis, nBsPis, nAlPis)
		nTest += TestaVal("COFINS", cTpTeCof, nBsCof, nAlCof) 
		nTest += TestaVal("CSLL", cTpTeCsl, nBsCsl, nAlCsl)
		nTest += TestaVal("IRRF", cTpTeIrf, nBsIrf, nAlIrf)
		nTest += TestaVal("INSS", cTpTeIns, nBsIns, nAlIns)
		nTest += TestaVal("INSS", cTpTeIns, nBsIns, nAlIns)
		If(nTest == 0 .and. lValido, lValido := .T., lValido := .F.) 
	Endif
		
	If((lFixo .OR. lVariav) .AND. lValido .AND. lPj)
		aPVsPend := possuiPVs()		
		If(Len(aPVsPend) > 0 )
				
			For nX := 1 to Len(aPVsPend)
				Qry += "UPDATE "+RetSqlName("SC5")+" SET C5_XBLQ = '3' WHERE C5_NUM = '"+aPVsPend[nX]+"' AND C5_FILIAL = '"+xFilial("SC5")+"';" 	
			Next
			TcSqlExec(Qry)
		EndIf
	Endif

Return lValido




Static Function possuiPVs()

	Local aPedidos := {}
	Local cQry := ""
	
	cQry :=	" SELECT C5_NUM FROM "+RetSQLName("SC5") 
	cQry +=	" WHERE C5_CLIENTE+C5_LOJACLI = '"+cClieLoja+"' AND C5_NOTA = '' "
	cQry += " AND C5_XBLQ IN ('1','2') AND UPPER(C5_XIDPLE) NOT LIKE 'R%'  AND D_E_L_E_T_ = '' AND C5_FILIAL = '"+xFilial("SC5")+"'; "
	
	
	tcQuery cQry New Alias "temp"      		
	Do While temp->(!EOF())
		aAdd(aPedidos, temp->C5_NUM)
		temp->(dbSkip())
	EndDo 	
	temp->(dbCloseArea())

Return aPedidos 
	



Static Function TestaVal(campo, tipo, base, aliquota)
	local lRet := 0
	if(tipo=="F")
		if(base == 0)
			alert("Favor preencher a BASE DE CALCULO do tributo: "+campo+", Informar 100,00 % caso nao haja reducao.")
			lRet := 1
		endIf
		if(aliquota == 0)
			alert("Favor preencher a ALIQUOTA do tributo: "+campo+", informar a aliquota padrao caso nao haja reducao.")
			lRet := 1
		endIf
	endIf
Return lRet
