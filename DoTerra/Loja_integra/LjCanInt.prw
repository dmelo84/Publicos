#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#include "Tbiconn.ch"

/*-----------------------------------------------------------------
|Funo Cancelamento de Integração SigaLoja                        |
|Realiza o processo reverso de Integração                          |
|Desenvolvedo: Diogo Melo                                          |
|Data atualizao: 23/07/2019                                      |
-------------------------------------------------------------------*/
User Function ViewCanc
	//MsgRun("Executando..","Revertendo Integração",{||  })
	oSay := Nil
	FWMsgRun(, {|oSay| u_LjCanInt() }, "Processando", "Processando a rotina...")
Return

User Function LjCanInt

	Local cQry   := ""
	Local aPergs := {}
	Local aRet   := {}
	Local nX     := 0
		
	aAdd( aPergs ,{1,"Integração De : "    ,stod(space(8)),"@!",/*'.F.'*/,,".T.",50,.F.}) 
	aAdd( aPergs ,{1,"Integração Ate : "   ,dDatabase,"@!",/*'.F.'*/,,".T.",50,.F.})
	
	If ParamBox(aPergs ,"Seleção para Envio ",@aRet)      

		dDataDe   := DtoS(aRet[1])
		dDataAte  := DtoS(aRet[2])
		
	Else
		Msginfo("Seleção incorreta de títulos")    
		Return   
	EndIf

	cQry := " SELECT C5_FILIAL, C5_P_DTRAX, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_OK, C5_NOTA, C5_SERIE, SC5.R_E_C_N_O_ AS nRecSC5, "
	cQry += " L1_FILIAL, L1_PEDIDO, L1_P_DTRAX, L1_DTLIM, SL1.R_E_C_N_O_ as nRecSL1 "
	cQry += " FROM "+ RetSqlName("SC5") + " SC5 "

	cQry += " INNER JOIN "+ RetSqlName("SL1") + " SL1 "
	cQry += " ON C5_FILIAL = L1_FILIAL "
	cQry += " AND C5_P_DTRAX = L1_P_DTRAX "
	cQry += " AND C5_NUM = L1_PEDIDO "

	cQry += " WHERE SL1.D_E_L_E_T_ != '*' "
	cQry += " AND L1_PEDIDO != ' ' "
	cQry += " AND L1_P_DTRAX != ' ' "
	cQry += " AND SC5.D_E_L_E_T_ != '*' "
	cQry += " AND C5_NOTA = 'Integrado' " 
	cQry += " And C5_SERIE = 'INT' "
	
	cQry += " AND C5_EMISSAO BETWEEN '"+ dDataDe +"' AND '"+ dDataAte+"'"
	
	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"cAliasSC5", .F., .T.)

	dbSelectArea("cAliasSC5")
	
	While cAliasSC5->(!EOF())
	nx++

		SC5->(dbGoTo(cAliasSC5->nRecSC5))

		Reclock("SC5",.F.)
		SC5->C5_OK    := '  '
		SC5->C5_NOTA  := '  '
		SC5->C5_SERIE := '  '
		SC5->C5_MKOK  := '  '
		//SC5->C5_ORIGEM := "LjCanInt"    
		MsUnlock()

		SL1->(dbGoTo(cAliasSC5->nRecSL1))
		Reclock("SL1",.F.)
		SL1->L1_DTLIM := dDataBase - 1
		SL1->L1_PEDIDO := " "
		//SL1->L1_ORIGEM := "LjCanInt"
		MsUnLock()
		
		cAliasSC5->(dbSkip())
	EndDo
	cAliasSC5->(dbCloseArea())

	If nX = 0
		Msginfo("Não há integração a cancelar")
		RETURN
	ENDIF

Return