#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "Fileio.ch"
/*/{Protheus.doc} FA740BRW
Ponto de Entrada para adicionar rotina no Browse FINA740
@type function
@version  
@author Valdemar Merlim
@since 14/01/2021
@return return_type, return_description
/*/
User Function FA740BRW()
    Local aBotao := {}
    aAdd(aBotao, {'Alt. Vencto. em Lote',"U_xAltVenc()",   0 , 3    })
Return(aBotao)
/*
___________________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ BaixaOP    ¦ Autor          ¦ Valdemar Merlim Filho            ¦ Data ¦ 14/01/21         ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ CRIA TELA COM OS TITULOS DE ACORDO COM OS PARAMETROS SELECIONADOS              		    ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ PRONOVA				                                	                                ¦¦¦
¦+------------------------------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
User Function xAltVenc()       // MONTA O BROWSE COM OS ITENS A SEREM BAIXADOS SEQUENCIA 001
	Private oDlgMain     := Nil
	Private oListBox     := Nil
	Private oCheck       := Nil
	Private aCoordenadas := MsAdvSize(.T.)
	Private nOpcClick    := 0
	Private lMarcaDesm   := .F.
	Private lEdicao      := .T.
	Private aNotas 	     := {}
	Private oOk          := LoadBitmap( GetResources(), 'LBOK')
	Private oNo          := LoadBitmap( GetResources(), 'LBNO')
	aSizeAut 	         := MsAdvSize()
    Private _cDiasVenc   := CTOD("  /  /    ")
	aObjects             := {}

    Pergunte("XALTVENC",.T.)


	aAdd(aObjects,{100,100,.T.,.T.})

	aInfo		:= {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],1,1}
	aPosObj		:= MsObjSize(aInfo,aObjects)
	aPosGet		:= MsObjGetPos((aSizeAut[3]-aSizeAut[1]),315,{{004,024,240,270}} )

	nSuperior	:= 020
	nEsquerda	:= 005
	nInferior	:= aPosObj[1,3]-( aPosObj[1,1] + 040 )
	nDireita	:= aPosObj[1,4]-(aPosObj[1,2]+08)

	//Desenha a Tela
	oDlgMain := TDialog():New(aSizeAut[7],000,aSizeAut[6],aSizeAut[5],OemToAnsi("Títulos a Receber"),,,,,,,,oMainWnd,.T.)

	TButton():New(nInferior+30,nDireita-50 ,"Fechar"        ,oDlgMain,{|| Processa(FSAI())},055,011,,,,.T.,,"",,,,.F. )
	TButton():New(nInferior+30,nDireita-120,"Alt.Vencimento",oDlgMain,{|| Processa({|| ExecAltDt(@aNotas,@oListBox,@lEdicao,_cDiasVenc)},"Aguarde ...","Processando Dados ...")},055,011,,,,.T.,,"",,,,.F. )

	aNotas := {{.F.,"","","","","","","","",""}}

	oListBox := TWBrowse():New(nSuperior,nEsquerda,nDireita,nInferior,,{" ","Numero","Prefixo","Parcela","Cód.Cliente","Loja","Nome","Valor","Vencimento Real","Tipo"},,oDlgMain,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox:SetArray(aNotas)
	oListBox:bLine := {||{ 	IIf(aNotas[oListBox:nAt,1],oOk,oNo ),;
		aNotas[oListBox:nAt][2],;
		aNotas[oListBox:nAt][3],;
		aNotas[oListBox:nAt][4],;
		aNotas[oListBox:nAt][5],;
		aNotas[oListBox:nAt][6],;
        aNotas[oListBox:nAt][7],;
        aNotas[oListBox:nAt][8],;        
		aNotas[oListBox:nAt][9]}}
	oListBox:bLDblClick := {|| aNotas[oListBox:nAt,1] := !aNotas[oListBox:nAt,1]}
	oListBox:Refresh()

	Processa({|| Carrega(@aNotas,@oListBox,@lEdicao) })

    @ 010,012 CHECKBOX oCheck VAR lMarcaDesm PROMPT "Marcar/Desmarcar Todos"             SIZE 200,10 OF oDlgMain PIXEL ON CHANGE (LJMsgRun("Aguarde...","Aguarde...",{|| MarcaDesm(@aNotas,@oListBox)}))
    //@ 006,260 SAY OemtoAnsi("Qtd. de Dias para Prorrogação")                                         OF oDlgMain PIXEL COLOR CLR_BLUE
	@ 006,260 SAY OemtoAnsi("Nova data de vencimento")                                         OF oDlgMain PIXEL COLOR CLR_BLUE
   // @ 005,335 MSGET oDataVenc VAR _cDiasVenc VALID !Empty(_cDiasVenc) Picture "@E 999"   SIZE 020,4  OF oDlgMain PIXEL COLOR CLR_BLACK
   @ 005,335 MSGET oDataVenc VAR _cDiasVenc VALID !Empty(_cDiasVenc) Picture "@E 99/99/9999"   SIZE 40,4  OF oDlgMain PIXEL COLOR CLR_BLACK
	
    oDlgMain:Activate(,,,.T.)

Return()
/*
___________________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ FSAI       ¦ Autor          ¦ Valdemar Merlim Filho            ¦ Data ¦ 22/09/20         ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ FUNCAO PARA ENCERRAMENTO DA TELA                                               		    ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ PRONOVA				                                	                                ¦¦¦
¦+------------------------------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function FSAI()
	oDlgMain:End()
Return()
/*
___________________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ MarcaDesm  ¦ Autor          ¦ Valdemar Merlim Filho            ¦ Data ¦ 22/09/20         ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ FUNCAO PARA MARCAR E DESMARCAR RREGISTROS                                     		    ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ PRONOVA				                                	                                ¦¦¦
¦+------------------------------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function MarcaDesm(aNotas,oListBox)

	ProcRegua(Len(aNotas))

	For i := 1 To Len(aNotas)
		IncProc()
		aNotas[i,1] := !aNotas[i,1]
	Next i

	oListBox:SetArray(aNotas)
	oListBox:bLine := {||{ 	IIf(aNotas[oListBox:nAt,1],oOk,oNo ),;
		aNotas[oListBox:nAt][2],;
		aNotas[oListBox:nAt][3],;
		aNotas[oListBox:nAt][4],;
		aNotas[oListBox:nAt][5],;
		aNotas[oListBox:nAt][6],;
        aNotas[oListBox:nAt][7],;
        aNotas[oListBox:nAt][8],;
        aNotas[oListBox:nAt][9],;
		aNotas[oListBox:nAt][10]}}
	oListBox:Refresh()

Return()
/*
___________________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ Carrega    ¦ Autor          ¦ Valdemar Merlim Filho            ¦ Data ¦ 22/09/20         ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ FUNCAO PARA CARREGAR REGISTROS NO BROWSE                                      		    ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ PRONOVA				                                	                                ¦¦¦
¦+------------------------------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function Carrega()

	aNotas := {}

    _cNomCli := Posicione("SA1",1,xFilial("SA1")+MV_PAR01+MV_PAR02,"A1_NREDUZ")

	cQry1 := "SELECT * FROM "+RetSqlName("SE1")+" SE1 WHERE SE1.D_E_L_E_T_ = '' "
    //cQry1 += "AND SE1.E1_CLIENTE = '"+MV_PAR01+"' "
    //cQry1 += "AND SE1.E1_LOJA = '"+MV_PAR02+"' "
    cQry1 += "AND SE1.E1_NOMCLI = '"+Alltrim(_cNomCli)+"' "
    cQry1 += "AND SE1.E1_NUM BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR05+"' "
    cQry1 += "AND SE1.E1_PREFIXO BETWEEN '"+MV_PAR04+"' AND '"+MV_PAR06+"' "
    cQry1 += "AND SE1.E1_EMISSAO BETWEEN '"+DtoS(MV_PAR07)+"' AND '"+DtoS(MV_PAR08)+"' "
    cQry1 += "AND SE1.E1_VENCREA BETWEEN '"+DtoS(MV_PAR09)+"' AND '"+DtoS(MV_PAR10)+"' "
    cQry1 += "AND SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
    cQry1 += "AND SE1.E1_SALDO = SE1.E1_VALOR "
    cQry1 += "AND SE1.E1_TIPO IN ('NF ','BOL','TX ') "
    cQry1 += "ORDER BY E1_PREFIXO, E1_NUM, E1_PARCELA "

	IF Select("SQL") > 0
		SQL->(dbCloseArea())
	EndIf

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry1), "SQL", .F., .T.)

	SQL->(dbGoTop())

	Do While SQL->(!EOF())

		aAdd(aNotas,{.F.,SQL->E1_NUM,SQL->E1_PREFIXO,SQL->E1_PARCELA,SQL->E1_CLIENTE,SQL->E1_LOJA,SQL->E1_NOMCLI,SQL->E1_SALDO,DtoC(StoD(SQL->E1_VENCREA)),SQL->E1_TIPO})

		SQL->(dbSkip())

	EndDo

	If Len(aNotas) = 0
		aNotas := {{.F.,"","","","","","","","",""}}
		MsgStop("Sem dados para os parâmetros selecionados.")
	EndIf

	oListBox:SetArray(aNotas)
	oListBox:bLine := {||{ 	IIf(aNotas[oListBox:nAt,1],oOk,oNo ),;
		aNotas[oListBox:nAt][2],;
		aNotas[oListBox:nAt][3],;
		aNotas[oListBox:nAt][4],;
		aNotas[oListBox:nAt][5],;
		aNotas[oListBox:nAt][6],;
        aNotas[oListBox:nAt][7],;
        aNotas[oListBox:nAt][8],;
        aNotas[oListBox:nAt][9],;
		aNotas[oListBox:nAt][10] }}
	oListBox:Refresh()

	lEdicao := .F.

Return()
/*
___________________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ExecBaix   ¦ Autor          ¦ Valdemar Merlim Filho            ¦ Data ¦ 22/09/20         ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ FUNCAO PARA ALTERAÇÂO DO CAMPO E1_VENCREA EM LOTE                             		    ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ PRONOVA				                                	                                ¦¦¦
¦+------------------------------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function ExecAltDt(aNotas,oListBox,lEdicao,_cDiasVenc)
	Private aSelec   := {}
	Private aProds   := {}
	Private cRelProd := ""
	Private cProds   := ""
	Private cCompet := ""
	Private cPeriod := ""
	lMarcado := .F.

	cOrdens := "("

	For z:= 1 To Len(aNotas)
		IncProc()
		If aNotas[z,1]
			lMarcado := .T.
			cOrdens += "'"+alltrim(aNotas[z][2]+"/"+aNotas[z][3])+"',"
		Endif
	Next z

	cOrdens := SubStr(cOrdens,1,len(cOrdens)-1)
	cOrdens += ")"

	If !lMarcado
		Alert("Nenhum título selecionado, Favor selecione os títulos para alteração.")
		Return()
	Else
		For _n := 1 To Len(aNotas)
			If aNotas[_n,1]
				MsgRun("Alterando Datas de Vencimento...","Aguarde",{||ExcDataV(aNotas[_n,2],aNotas[_n,3],aNotas[_n,4],_cDiasVenc,aNotas[_n,10]) })
			EndIf
		Next _n
	Endif

//Inclui static funtion carrega pois a tela não pode fechar, ela precisa ficar ativa para o usuário selecionar outros titulos. - claudio duarte STARDATA 20210719
	Carrega()
	
	//FSAI() //ESSA FUNÇÃO FECHAVA TELA

Return()
/*
___________________________________________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ExcDataV  ¦ Autor          ¦ Valdemar Merlim Filho            ¦ Data ¦ 14/01/21          ¦¦¦
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦Descrição ¦ FUNCAO PARA ALTERAÇÃO DO CAMPO E1_VENCREA                                     		    ¦¦¦Ù
¦¦+----------+------------------------------------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ PRONOVA				                                	                                ¦¦¦
¦+------------------------------------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function ExcDataV(_cNum,_cPrefixo,_cParcela,_cDiasVenc,_cTipo)
	Local _aVetor := {}

	If Empty(_cNum)
		MsgStop("Nenhum título foi selecionado.")
		Return()
	EndIf

    DbSelectArea("SE1")
    DbSetOrder(1)
    If DbSeek(xFilial("SE1")+_cPrefixo+_cNum+_cParcela+_cTipo,.F.)
        
      //  _dData := DataValida((SE1->E1_VENCREA+_cDiasVenc),.T.)
	  _dData := DataValida(_cDiasVenc,.T.)
        
        RecLock("SE1",.F.)
        Replace SE1->E1_LOGDTVE With FwGetUserName(RetCodUsr())+' - '+FWTimeStamp( 2,dDataBase,Time())+' - '+'Data Anterior: '+DtoC(SE1->E1_VENCREA)
        Replace SE1->E1_VENCREA With _dData
        SE1->(MsUnLock())

    EndIf

Return(Nil)
