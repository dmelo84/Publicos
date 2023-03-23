//Bibliotecas
#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE 'TBICONN.CH'

#DEFINE PULA chr(13)+chr(10)

/*/{Protheus.doc} ORTP205
    (long_description)
    @type  Function
    @author Diogo Melo
    @since 09/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

user Function ORTP205()

Local aArea  := getArea()
Local __cQryDel := ""
Local nCont     := 0
Local cQuery    := ""
Local aPergs    := {}
Local cOPde     := Space(tamSx3("D3_OP")[1])
Local cOPate    := Repl("Z",TamSX3("D3_OP")[1])
Local dDtProd   := dDataBase
Local nTipo     
Local cGrupo    := Space(tamSX3("B1_GRUPO")[1])
//Local aProduto  := {}
Local nContFlds := 0
Local aFields := {}
Local aColumns := {}
Local cAlias := getNextAlias()
//Local lInc := .F.
Local cEmpProc := "18"

Private lTela := .F.
Private lMenu := .F.

	if !IsBlind()
		//Parambox
		aAdd(aPergs, {1, "De Ord. Produção:" ,   cOPde, "", ".T.", "",    ".T.", 80, .F.})
		aAdd(aPergs, {1, "Até Ord. Produção:",  cOPate,  "", ".T.", /*"SB1"*/, ".T.", 80,  .F.})
		aAdd(aPergs, {1, "Data Produção:"    , dDtProd,  "", ".T.", /*"SB1"*/, ".T.", 60,  .F.})
		aAdd(aPergs, {2, "Tipo Produto:"     ,   nTipo, {"1=Padrão", "2=Sob Medida","3=Ambos"}, 100, ".T.", .F.})
		aAdd(aPergs, {1, "Grupo de Produtos:",   cGrupo, "", ".T.", "SBM", ".T.", 40, .F.})
		
		If ParamBox(aPergs, "Informe os parâmetros")
			cOPde   := MV_PAR01
			cOPate  := MV_PAR02
			dDtProd := MV_PAR03 //Jogar este paramento para a data de emissão do pedido de compra.
			nTipo   := MV_PAR04
			cGrupo  := MV_PAR05
		else
			FWAlertError("Parametros inválidos!", "Parametrização.")
			RETURN
		EndIf
		//Trata Job Futuro
		lTela := .T.
		//
	else
		MV_PAR01 := Space(tamSx3("D3_OP")[1])    //Op De
		MV_PAR02 := Repl("Z",TamSX3("D3_OP")[1]) //Op Até
		MV_PAR03 := dDataBase                    //Dt Produção
		MV_PAR04 := "3"                          //3- Ambos
		MV_PAR05 := "5044"                       //5044
	endif

	//Deleta tabela para recriar
	__cQryDel	:=	"DELETE totconsumo"+cEmpProc/*SM0->M0_CODIGO*/

	TCSQLEXEC(__cQryDel)

	TCSQLEXEC("COMMIT")

	//Excecuta a procedure
	If TCSPExist("CONSUMO"+cEmpProc/*SM0->M0_CODIGO*/)

		TCSPEXEC("CONSUMO"+cEmpProc/*SM0->M0_CODIGO*/,MV_PAR01,MV_PAR02,Dtos(MV_PAR03),val(MV_PAR04))
		
	Else
		Alert("Procedure CONSUMO"+cEmpProc/*SM0->M0_CODIGO*/+" não existe!")
		Return
	Endif

	//Retorno dos dados
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
		cQuery	+=	"        comp, " +PULA
		cQuery	+=	"        SUM(qtd) QUANT ," +PULA
		cQuery	+=  "        ' ' as c7_OK " +PULA
		cQuery	+=	"   FROM siga.totconsumo"+cEmpProc/*SM0->M0_CODIGO*/+", siga."+RetSqlName("SB1")+" b1, siga."+RetSqlName("SBM")+" bm " 	+PULA//, siga."+RetSqlName("SX5")+" X5 "
		cQuery	+=	"   WHERE b1_filial = '"+xFilial("SB1")+"' " +PULA
		cQuery	+=	"    AND bm_filial = '"+xFilial("SBM")+"' " +PULA
		cQuery	+=	"    AND b1.d_e_l_e_t_ = ' ' " +PULA
		cQuery	+=	"    AND bm.d_e_l_e_t_ = ' ' " +PULA
		cQuery	+=	"    AND bm_grupo = b1_grupo " +PULA
		cQuery	+=	"    AND b1_cod = comp " +PULA
		cQuery  +=  "    and b1_grupo ='"+cGrupo+"'" +PULA //DMS
						cQuery  +=  "and b1_cod not in (select c7_produto from siga.sc7180 where D_E_L_E_T_ != '*' "+PULA
						cQuery  += "and c7_xobsped != ' '"+PULA
						cQuery  += "and c7_contato = 'INTEGRACAO'"+PULA
						cQuery  += "and c7_residuo != 'S'" +PULA
						cQuery  += "and c7_quje < c7_quant)"+PULA
		cQuery	+=	"  GROUP BY b1_um, " +PULA 
		cQuery	+=	"           b1_tipconv, " +PULA
		cQuery	+=	"           b1_conv, " +PULA
		cQuery	+=	"		    b1_xmodelo, " +PULA
		cQuery	+=	"           b1_grupo, " +PULA
		cQuery	+=	"           b1_cod, " +PULA
		cQuery	+=	"           b1_desc, " +PULA
		cQuery	+=	"           bm_xsubgru, " +PULA
		cQuery	+=	"           comp " +PULA
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
		cQuery	+=	"        comp, " +PULA
		cQuery	+=	"        SUM(qtd) QUANT ," +PULA
		cQuery	+=  "        ' ' as c7_OK " +PULA
		cQuery	+=	"   FROM siga.totconsumo"+cEmpProc/*SM0->M0_CODIGO*/+", 
		cQuery	+=  "   siga."+RetSqlName("SB1")+" b1, "+PULA
		cQuery	+=  "   siga."+RetSqlName("SBM")+" bm, "+PULA
		cQuery	+=  "   siga."+RetSqlName("SX5")+" X5 " +PULA
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
		cQuery  +=  "    and b1_grupo ='"+cGrupo+"'" +PULA //DMS
			 cQuery  += "and b1_cod not in (select c7_produto from siga.sc7180 where D_E_L_E_T_ != '*' "+PULA
						cQuery  += "and c7_xobsped != ' '"+PULA
						cQuery  += "and c7_contato = 'INTEGRACAO'"+PULA
						cQuery  += "and c7_residuo != 'S'" +PULA
						cQuery  += "and c7_emissao  = '"+dtos(MV_PAR03)+"'"  +PULA
						cQuery  += "and c7_quje < c7_quant)"+PULA
		If cEmpAnt == '11'                 
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
	MemoWrite("C:\ORTP205.sql",cQuery)

	If Select("QRY") > 0
		dbSelectArea("QRY")
		dbCloseArea()
	EndIf

	TcQuery cQuery Alias "QRY" New

	DbSelectArea("QRY")
	nCont := LASTREC()
	dbGoTop()

	If Eof()
		MsgInfo("Não existe produção para o parametro informado!","Rel. Requis. MP")
		Return()
//	else
//		while QRY->(!eof())

		//lInc := itemCriado(QRY->B1_COD)

	    //If lInc
//			Aadd(aProduto,{QRY->B1_COD, QRY->B1_DESC, QRY->QUANT,QRY->B1_UM})
		//endif

//		QRY->(dbSkip())
//		endDo
	EndIf
	
		//Criando o MarkBrow
		oMark := FWMarkBrowse():New()

		Aadd(aFields,{"b1_cod"      ,"Produto" })
		Aadd(aFields,{"b1_desc"     ,"Descrição" })
		Aadd(aFields,{"b1_um"	    ,"UM" })
		Aadd(aFields,{"quant"	    ,"Quatidade" })
		
		For nContFlds := 1 To Len( aFields )
		
		AAdd( aColumns, FWBrwColumn():New() )
	
		aColumns[Len(aColumns)]:SetData( &("{ || " + aFields[nContFlds][1] + " }") )
		aColumns[Len(aColumns)]:SetTitle( aFields[nContFlds][2] )
		if aFields[nContFlds][1] != 'quant'
			aColumns[Len(aColumns)]:SetSize( tamSx3(aFields[nContFlds][1])[1] )
		else
			aColumns[Len(aColumns)]:SetSize( tamSx3("C7_QUANT")[1] )
		endif
		aColumns[Len(aColumns)]:SetID( aFields[nContFlds] )

	Next nContFlds
		
		/*/Adiciona botoes na janela
		oMark:AddButton("Enviar Mensagem", { || U_MCFG006M()},,,, .F., 2 )
		oMark:AddButton("Detalhes"		 , { || MsgRun('Coletando dados de usuário(s)','Relatório',{|| U_RCFG0005() }) },,,, .F., 2 )
		oMark:AddButton("Legenda"		 , { || MCFG006LEG()},,,, .F., 2 )
	*/
	//Setando Legenda
//    oMark:AddLegend( "SC7->C7_OK != 'IN'", "GREEN",    "Integrado" )
//    oMark:AddLegend( "SC7->C7_OK == '  ' ", "RED",     "Não Integrado")
	
	//Setando semáforo, descrição e campo de mark
	oMark:SetSemaphore(.F.)
	//oMark:SetAlias(cTable)
	oMark:SetDescription('Itens Programados')
	oMark:SetFieldMark( 'C7_OK' )
	oMark:SetColumns( aColumns )
	oMark:SetDataQuery()
	oMark:SetQuery( cQuery)
	oMark:SetAlias( cAlias )
	oMark:SetMenuDef('ORTP205')
	
	oMark:Activate()

	//Restaura area anterior 
	restArea(aArea)


Return /*aProduto*/

/****************************************************
| Chamada do execAuto de criação de pedido de compra|
****************************************************/

//Inclui o mesmo produto na empresa '18/03'
//STARTJOB("U_ORTP205C",getenvserver(),.t.,aProduto)

user Function ORTP205C(aProduto)

static cErro := ""

Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local aLinRat := {}
Local aRatCC := {}
Local aItemCC := {}
Local aRateio := {}
Local nX := 0
Local nY := 0
Local cDoc := ""
Local lOk := .T.
Local n := 0
Local nVez := .F.
Local cMsg := ""
Local nValCom := 1
Local lSai := .T.

PRIVATE lMsErroAuto := .F.
Private lAutoErrNoFile := .T.

PREPARE ENVIRONMENT EMPRESA "18" FILIAL "03" MODULO "COM" TABLES "SC7","SCH"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Abertura do ambiente |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

U_JobCInfo("ORTP205.prw",Repl("-",80),2)
//ConOut(Repl("-",80))

U_JobCInfo("ORTP205.prw",PadC("Inicio do processo MATA120",80),2)
//ConOut(PadC("Inicio do processo MATA120",80))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Verificacao do ambiente para teste |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SB1")
dbSetOrder(1)

If len(aProduto) > 0

	for n := 1 to Len(aProduto)

		If !SB1->(MsSeek(xFilial("SB1")+aProduto[n][1]))

			lOk := .F.
			cMsg := "Cadastrar produto: "+aProduto[n][1] +PULA
			//ConOut("Cadastrar produto: "+aProduto[n][1])

		EndIf

		dbSelectArea("SF4")
		dbSetOrder(1)

		cTes := "001"//Posicione("SB1",1,xFilial("SB1")+aProduto[n][1],"B1_TE")
		
		If !SF4->(MsSeek(xFilial("SF4")+cTes))

			lOk := .F.
			cMsg += "TES não encontrada: "+cTes +PULA
			//ConOut(cMsg)
		else
			cTes := "001"
		EndIf

		dbSelectArea("SE4")
		dbSetOrder(1)

		If !SE4->(MsSeek(xFilial("SE4")+"000"))

			lOk := .F.
			cMsg += "Cadastrar condicao de pagamento: 000 - A Vista" +PULA
			//ConOut("Cadastrar condicao de pagamento: 000 - A Vista")
		else
			cCond := "Q60"
		EndIf

		dbSelectArea("SA2")
		dbSetOrder(1)

		If !SA2->(MsSeek(xFilial("SA2")+"000126"+"01")) //000126 - 01 | FAB. DE POL. RIO SUL LTDA

			lOk := .F.
			//ConOut("Cadastrar fornecedor: "+"000126 - 01 | FAB. DE POL. RIO SUL LTDA")
			cMsg += "Cadastrar fornecedor: "+"000126 - 01 | FAB. DE POL. RIO SUL LTDA"
		else
			cForne := "000126"
			cLoja  := "01"
		EndIf

		If !lOk
			Help(,,"Validação",,"Itens validados", 1, 0,,,,,, {cMsg})
			return
		else
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//| Verifica o ultimo documento valido para um fornecedor |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			dbSelectArea("SC7")
			dbSetOrder(1)
			MsSeek(xFilial("SC7")+"zzzzzz",.T.)
			dbSkip(-1)
			/*
			aCabec := {}
			aItens := {}
			*/
			if !nVez

				cDoc := SC7->C7_NUM /*GetSxeNum("SC7", "C7_NUM")*/

				If Empty(cDoc)
					cDoc := StrZero(1,Len(SC7->C7_NUM))
				Else
					cDoc := Soma1(cDoc)
				EndIf
				
				aadd(aCabec,{"C7_NUM"     ,cDoc})
				aadd(aCabec,{"C7_EMISSAO" ,aProduto[n][4]})
				aadd(aCabec,{"C7_FORNECE" ,cForne})
				aadd(aCabec,{"C7_LOJA"    ,cLoja})
				aadd(aCabec,{"C7_COND"    ,cCond})
				aadd(aCabec,{"C7_CONTATO" ,"INTEGRACAO"})
				aadd(aCabec,{"C7_FILENT"  ,cFilAnt})

				nVez := .T.
				
			endIf 
		
			//Item do pedido
			aLinha := {}
			
			//Ultima Compra
			
			  if nValCom == 1
			  		nValCom := Posicione("SB1",1,xFilial("SB1")+aProduto[n][1],"B1_UPRC")
			  elseif nValCom == 1
					nValCom := Posicione("SB2",1,xFilial("SB2")+aProduto[n][1],"B2_CM1")
			  elseif nValCom == 1
			  		nValCom := Posicione("DA1",1,xFilial("DA1")+aProduto[n][1]+PadL(cEmpAnt,3,"0"),"DA1_PRCVEN") //DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM
			  endIf

			aadd(aLinha,{"C7_PRODUTO" ,aProduto[n][1],Nil})
			aadd(aLinha,{"C7_QUANT"   ,aProduto[n][2] ,Nil})
			aadd(aLinha,{"C7_PRECO"   ,nValCom ,Nil})
			aadd(aLinha,{"C7_TOTAL"   ,nValCom*aProduto[n][2] ,Nil})
			aadd(aLinha,{"C7_TES"     ,cTes ,Nil})
			aadd(aLinha,{"C7_OBS"     ,"ORTP205 - "+cDoc ,Nil})
			aadd(aLinha,{"C7_XOBSPED" ,cDoc ,Nil})
			aadd(aItens,aLinha) 
		endIf		
	next

	/*
		// Monta itens rateio
		aAdd(aRatCC,{"0001",{ }})

		// Primeiro item do rateio
		aAdd(aItemCC,{"CH_ITEM",StrZero(1,Len(SCH->CH_ITEM)),NIL})
		aAdd(aItemCC,{"CH_PERC",100,NIL}) // Percentual a ser ratiado.
		aAdd(aItemCC,{"CH_CC","000000001",NIL}) //centro de custo do primeiro Item.
		aAdd(aRatCC[1][2],aItemCC)
*/
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//| Teste de Inclusao |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		U_JobCInfo("ORTP205.prw","Antes do ExecAuto [MATA120]: "+Time(),2)
		//
		MSExecAuto({|k,v,w,x,y,z| MATA120(k,v,w,x,y,z)},1,aCabec,aItens,3,,aRatCC)
		//
		U_JobCInfo("ORTP205.prw","Depois do ExecAuto [MATA120]: "+Time(),2)
		If !lMsErroAuto
		
			U_JobCInfo("ORTP205.prw","Incluido com sucesso o pedido de compra: "+cDoc,2)
			//
			U_JobCInfo("ORTP205.prw","Inicia o [ORTA791]: "+Time(),2)
			//
			FWMsgRun(, {|oSay| u_ORTA791(cDoc)},'Processando', 'Pedido de Venda n° '+cDoc)
			//
			U_JobCInfo("ORTP205.prw","Finaliza o [ORTA791]: "+Time(),2)
		//	confirmSX8()
		Else

		U_JobCInfo("ORTP205.prw","Erro na inclusao - [MATA120]",2)
		//ConOut("Erro na inclusao - [MATA120]")

		AutoGrLog("Inicio")
		AutoGrLog(Replicate("-", 20))

		aLog := GetAutoGRLog()
		For nX := 1 To Len(aLog)				
			cErro += aLog[nX] +CHR(13)+CHR(10)		
		Next nX	
		//
		if ExistDir( "\temp" )
			if FERASE("\temp\error.txt") == -1
            	U_JobCInfo("ORTP205.prw","Erro delecao do arquivo de log",2)
        	else
            	U_JobCInfo("ORTP205.prw","Arquivo de log deletado com sucesso",2)
        	endif
			MemoWrite( "\temp\"+"error.txt", cErro )
		else
			nRet := MakeDir( "\temp" )
			if nRet > 0
				MemoWrite( "\temp\error.txt", cErro )
			else
				U_JobCInfo("ORTP205.prw","Criação diretório do error.log - [MATA120]",2)
			endif
		endif
		//
		AutoGrLog(Replicate("-", 20))
		AutoGrLog("Fim")
		//
		U_JobCInfo("ORTP205.prw","Erro na inclusao - [MATA120]: "+cErro,2)
       // RollBackSX8()
		U_JobCInfo("ORTP205.prw",PadC("Fim do Processamento MATA120",80),2)
		EndIf

RESET ENVIRONMENT

EndIf

Return (.T.)

Static Function MenuDef()
    
Local aRot := {}
    
ADD OPTION aRot TITLE "Gerar Pedido"   ACTION "u_gerPed()"  OPERATION 6 ACCESS 0
//ADD OPTION aRot TITLE "Gerar Pedido"   ACTION "FWMsgRun(, {|oSay| u_gerPed()},'Processando', 'Montando Pedidos')"  OPERATION 6 ACCESS 0
//  ADD OPTION aRot TITLE "Impor. Ped. Compra" ACTION "FWMsgRun(, {|oSay| u_ORTP205()},'Executando Procedure', 'Montando Ped. Compras')"  OPERATION 6 ACCESS 0
//  ADD OPTION aRot TITLE "Legenda"     	   ACTION "u_ORTL791LEG()"  OPERATION 6 ACCESS 0
ADD OPTION aRot TITLE "Produtos Programados" ACTION "u_ORTR864()"  OPERATION 6 ACCESS 0
 
Return(Aclone(aRot))

/*/{Protheus.doc} procMark
    (long_description)
    @type  Static Function
    @author user
    @since 15/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
user Function gerPed(dtProg)

  //Local aArea    := GetArea()
    Local cMarca   := oMark:Mark()
    Local lInverte := oMark:IsInvert()
    Local nCt      := 0
	Local cAlias   := alias()

	default dtProg := MV_PAR03 //Será a Data de emissão do pedido de compra

    Private aProduto := {}
    //Private cAlias := alias()
     
    //Percorrendo os registros da TMP
    (cAlias)->(DbGoTop())

    While !(cAlias)->(EoF())
        
        If oMark:IsMark(cMarca)
			nCt++
			aAdd(aProduto,{(cAlias)->B1_COD, (cAlias)->QUANT, (cAlias)->C7_OK, dtProg})
			
			//Limpando a marca, o execAuto vai gravar o campo na C7 direto
			RecLock(cAlias, .F.)
				C7_OK := ''
			(cAlias)->(MsUnlock())
        EndIf
         
        (cAlias)->(DbSkip())
    EndDo
	
    //ExecAuto Criação de pedido de venda
    If nCt > 0
        FWMsgRun(, {|oSay| STARTJOB("U_ORTP205C",getenvserver(),.T.,aProduto) },'Executando Procedure', 'Montando Ped. Compra')
        //CloseBrowse() //Fecha Tela
		u_retNumPed()
    else
        FWAlertWarning("Nenhum item selecionado na tela.", "Aviso!")
        return
    endif  

//Restaurando área armazenada
//RestArea(aArea)

Return

/*/{Protheus.doc} itemCriado
	(long_description)
	@type  Static Function
	@author user
	@since 22/12/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
/*
Static Function itemCriado(cProduto)

Local cQry   := ""
Local cTable := "TAB"
Local lRet   := .F.

cQry := "select * from siga.sc7180 where D_E_L_E_T_ != '*'" +PULA
cQry += "and c7_produto = '"+alltrim(cProduto)+"'" +PULA
cQry += "and c7_xobsped != ' '" +PULA
cQry += "and c7_residuo != 'S' " +PULA
cQry += "and c7_contato = 'INTEGRACAO'" +PULA
cQry += "and c7_quje < c7_quant " +PULA

MemoWrite("C:\itemCriado.sql",cQry)

//if Select(cTable) > 0
    //cTable->(dbCloseArea())
	//dbCloseArea()
//EndIf

TcQuery cQry Alias cTable New

DbSelectArea(cTable)
cTable->(dbGoTop())

if eof()
	lRet := .T.
endif

cTable->(dbCloseArea())

Return lRet
*/

/*/{Protheus.doc} retNumPed
	(Retorna o de/Para dos pedidos de compra e venda)
	@type  Static Function
	@author user
	@since 27/12/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
user Function retNumPed()

Local cQry := ""
//Local cMsg := ""
Local nCount := 0
//Local PULA := chr(13) + chr(10)

cQry += "select distinct C7_NUM, C7_OBS, C7_EMISSAO "
cQry += "from siga.sc7180 where D_E_L_E_T_ != '*' " +PULA
cQry += "and c7_xobsped != ' ' " +PULA
cQry += "and c7_contato = 'INTEGRACAO' " +PULA
cQry += "and c7_residuo != 'S' "  +PULA
cQry += "and c7_quje < c7_quant " +PULA
cQry += "and c7_emissao ='"+dtos(dDatabase)+"'"

nStatus := TCSqlExec(cQry)

if (nStatus < 0)
    conout("TCSQLError() " + TCSQLError())
    //FWAlertInfo(TCSQLError(), "TCSQLError()")
	Return 
endif

If select('TMP') > 0
	TMP->(dbCloseArea())
EndIf
//
TCQuery (cQry) ALIAS "TMP" NEW

while TMP->(!eof())

nCount++

cPedCom  := TMP->C7_NUM //Pedido compra
cPedVen  := Iif(subs(alltrim(TMP->C7_OBS),1,7) == "ORTA791",subs(alltrim(TMP->C7_OBS),-6),"Pedido de venda não encontrado") //Pedido de Venda
dEmissao := TMP->C7_EMISSAO //Dt. Emissão

cErro += "Pedido de compra: "+TMP->C7_NUM+" (UN 27)"+" => "+ "Pedido de venda: "+cPedVen+" (UN 03)" +" Emissão: "+subs(dEmissao,7,2)+"/"+subs(dEmissao,5,2)+"/"+subs(dEmissao,1,4) +PULA

TMP->(dbSkip())
endDo

if nCount == 0
	cErro := MemoRead( "temp\error.txt" )
	if !empty(cErro)
		 DEFINE DIALOG oDlg TITLE "De / Para pedidos" FROM 180, 180 TO 500, 700 PIXEL
		// Usando o New
  		cTexto1 := cErro
  		oTMultiget1 := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cTexto1 := u, cTexto1 ) }, ;
    			 					   oDlg, 260, 150, , , , , , .T. )

		ACTIVATE DIALOG oDlg CENTERED
	else
		//FWAlertError("Não foi encontrado pedido de compra/venda para data de: "+dtoc(dDatabase)+" gere o relatório de produtos programados para identificar os pedidos já gerados.","Alerta!")
		lRet := FWAlertYesNo("Não foi encontrado pedido de compra/venda para data de: "+dtoc(dDatabase)+" Deseja gerar o relatório de produtos programados?", "Facilitador.")
		if lRet
			u_ORTR864()
		endif
	endIf
endif
	
Return 
