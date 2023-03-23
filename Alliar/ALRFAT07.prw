#INCLUDE "PROTHEUS.CH"

Static lCSCCorr := .T.
//-------------------------------------------------------------------
/*{Protheus.doc} ALRFAT07
Funcao Generica para Compilacao

@author Guilherme Santos
@since 22/09/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRFAT07()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} AL07VLEX
Valida a Exclusao do Documento de Saida e Envia o Cancelamento para
o Sistema de Origem

@author Guilherme Santos
@since 22/09/2016
@version P12
*/
//-------------------------------------------------------------------
User Function AL07VLEX(aPedidos)
	Local aRet			:= {}
	Local cMensLog		:= ""
	Local cXML			:= ""
	Local nPedido		:= 0
	Local lFinanc		:= .T.

	For nPedido := 1 to Len(aPedidos)
		DbSelectArea("SC5")
		DbSetOrder(1)		//C5_FILIAL, C5_NUM
		
		If SC5->(DbSeek(xFilial("SC5") + aPedidos[nPedido][01]))

			If !Empty(SC5->C5_XIDPLE) .AND. Left(SC5->C5_XIDPLE,1) != "V" .AND. Left(SC5->C5_XIDPLE,1) != "R"

				lFinanc := !(SC5->C5_XELIMRE == "S")

    			DbSelectArea("SA1")
    			DbSetOrder(1)	//A1_FILIAL, A1_COD, A1_LOJA
    			
    			If SA1->(DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
     
    				//Monta o XML para Integracao
        			cXML 	:= U_FSXmlNFS(SM0->M0_CGC, SM0->M0_CODFIL, SC5->C5_XTIPFAT, SC5->C5_XIDPLE, SA1->A1_CGC, SA1->A1_NOME, "", "", "", "", "", 0, 0, .T., lFinanc)
    
        			//Envia o Cancelamento para o Sistema de Origem
                	aRet	:= U_FSPLEFAT(cXml, SC5->C5_XIDPLE)
                	
                	If aRet[1] == "-1"
                		//ConOut("AL07VLEX - " + DtoC(Date()) + " - " + Time())
                		//ConOut("=> " + SM0->M0_CGC + " " + SM0->M0_CODFIL + " " + SC5->C5_XIDPLE)
						//ConOut(aRet[2])
                		//ConOut("AL07VLEX -------------------------------------------------------")

                		Exit
                	EndIf
            	EndIf
        	EndIf
        EndIf
	Next nPedido 

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} AL07TPEX
Determina o Tipo de Exclusao da NF de Saida

@author Guilherme Santos
@since 29/09/2016
@version P12
*/
//-------------------------------------------------------------------
User Function AL07TPEX(lCorrCSC)
	Local cMensagem	:= ""
	Local lRetorno	:= .T.

	cMensagem += "Esta rotina enviará o Cancelamento da NF para a Ponta." + CRLF
	cMensagem += "Em caso de correção do CSC, o Pedido permanecerá aberto e o sistema da Ponta receberá um novo numero de NF após a Reemissão." + CRLF
	cMensagem += "Em caso de correção da Ponta, os Residuos do Pedido serão eliminados e um novo Pedido deverá ser incluido a partir da Ponta." + CRLF

	If IsBlind() .AND. IsInCallStack("CP16PROC")
		nRetorno := 2
	Else
		nRetorno := Aviso("AL07TPEX", cMensagem, {"Correção CSC", "Correção Ponta", "Cancelar"})
	Endif

	Do Case
	Case nRetorno == 1
		lCorrCSC := .T.
	Case nRetorno == 2
		lCorrCSC := .F.
	Case nRetorno == 3
		lRetorno := .F.
	EndCase

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} AL07GPED
Retorna os Pedidos de Venda da NF

@author Guilherme Santos
@since 09/08/2016
@version P12
*/
//-------------------------------------------------------------------
User Function AL07GPED(cSerie, cDoc, cCliente, cLojaCli)
	Local aArea		:= GetArea()
	Local aRetorno 	:= {}
	Local cQuery	:= ""
	Local cTabQry	:= GetNextAlias()
	
	cQuery += "SELECT	SD2.D2_PEDIDO" + CRLF
	cQuery += "FROM		" + RetSqlName("SD2") + " SD2" + CRLF
	cQuery += "WHERE	SD2.D2_FILIAL = '" + xFilial("SD2") + "'" + CRLF
	cQuery += "AND 		SD2.D2_SERIE = '" + cSerie + "'" + CRLF
	cQuery += "AND		SD2.D2_DOC = '" + cDoc + "'" + CRLF
	cQuery += "AND 		SD2.D2_CLIENTE = '" + cCliente + "'" + CRLF
	cQuery += "AND 		SD2.D2_LOJA = '" + cLojaCli + "'" + CRLF
	cQuery += "AND 		SD2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "GROUP BY SD2.D2_PEDIDO" + CRLF
	
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		
	While !(cTabQry)->(Eof())
	
		Aadd(aRetorno, {(cTabQry)->D2_PEDIDO})

		(cTabQry)->(DbSkip())
	End
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf
	
	RestArea(aArea)

Return aRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} AL07SETC
Atribui o Tipo de Correcao da NF

@author Guilherme Santos
@since 22/09/2016
@version P12
*/
//-------------------------------------------------------------------
User Function AL07SETC(lParam)
	lCSCCorr := lParam
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} AL07FINA
Retorna se e uma Correcao do CSC

@author Guilherme Santos
@since 22/09/2016
@version P12
*/
//-------------------------------------------------------------------
User Function AL07LCSC()
Return lCSCCorr
//-------------------------------------------------------------------
/*{Protheus.doc} AL07RESI
Eliminacao de Residuos do Pedido apos o Cancelamento da NF

@author Guilherme Santos
@since 22/09/2016
@version P12
*/
//-------------------------------------------------------------------
User Function AL07RESI()
	Local aArea		:= GetArea()
	Local cQuery		:= ""
	Local cTabQry		:= GetNextAlias()
	Local cMensagem	:= ""
	Local oPedido		:= NIL

	RpcSetType(3)
	RpcSetEnv("01", "00101MG0001", NIL, NIL, "FAT", NIL, {"SC5", "SC6", "SC9"})

	cEmpAnt := "01"
	cFilAnt := "00101MG0001"

	cQuery += "SELECT		SC5.C5_FILIAL" + CRLF
	cQuery += ",			SC5.C5_NUM" + CRLF

	cQuery += "FROM		" + RetSqlName("SC5") + " SC5" + CRLF

	cQuery += "WHERE		SC5.C5_NOTA = ''" + CRLF
	cQuery += "AND		SC5.C5_SERIE = ''" + CRLF
	cQuery += "AND		SC5.C5_XELIMRE = 'S'" + CRLF
	cQuery += "AND		SC5.D_E_L_E_T_ <> '*'" + CRLF

	cQuery += "ORDER BY 	SC5.C5_FILIAL, SC5.C5_NUM" + CRLF
	
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		
	While !(cTabQry)->(Eof())
	
		cFilAnt := (cTabQry)->C5_FILIAL

		DbSelectArea("SC5")
		DbSetOrder(1)		//C5_FILIAL, C5_NUM

		If SC5->(DbSeek(xFilial("SC5") + (cTabQry)->C5_NUM))

			oPedido	:= ResPedVenda():New(SC5->C5_NUM)	
		
			If oPedido:Gravacao()
				//ConOut("AL07RESI - " + DtoC(Date()) + " - " + Time() + "Filial: " + cFilAnt + " - Residuos do Pedido " + SC5->C5_NUM + " eliminados com Sucesso.")
			Else
				//ConOut("AL07RESI - " + DtoC(Date()) + " - " + Time() + " - Filial: " + cFilAnt + " - Erro ao Eliminar os Residuos do Pedido " + SC5->C5_NUM)
				//ConOut("AL07RESI - " + oPedido:GetMensagem())
			EndIf 

			FreeObj(oPedido)
		EndIf 
		(cTabQry)->(DbSkip())
	End
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf
	
	RestArea(aArea)

Return NIL
