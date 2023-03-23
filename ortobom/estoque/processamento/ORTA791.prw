//Bibliotecas
#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE 'TBICONN.CH'
 
#DEFINE PULA chr(13)+chr(10)

/*/{Protheus.doc} ORTA791
MarkBrow em MVC da tabela de Artistas
@author Diogo
@since 03/09/2016
@version 1.0
@obs Criar a coluna TMP_OK com o tamanho 2 no Configurador e deixar como não usado
/*/

user function ORTA791(cNumPed)

Local cQry      := ""
Local cAlias    := GetNextAlias()
Local nContFlds := 0
Local aFields   := {}
Local aColumns  := {}
Local cGrupo    := SuperGetMV("OR_GRPPED",.T.,"5044")
Local aArea     := getArea()
Local nCt       := 0

Private aProduto := {}
Default cNumPed  := ""

Private oMark
Private lMenu := .F.

cQry := "select c7_filial, c7_produto, c7_descri, c7_um, sum(c7_quant) as c7_quant, " +PULA
cQry += "sum(c7_preco) as c7_preco, sum(c7_total) as c7_total, c7_obs, c7_ok " +PULA
cQry += "from siga.SC7180"+ " SC7 " +PULA
cQry += "where D_E_L_E_T_ !='*' " +PULA
cQry += "and c7_filial = '03' " +PULA //Mudar 
cQry += "and c7_quje < c7_quant " +PULA
cQry += "and c7_residuo != 'S' " +PULA
cQry += "and c7_fornece = '000126' " +PULA //Mudar
cQry += "and c7_loja = '01' " +PULA //Mudar
if !Empty(cNumPed)
    cQry += "and c7_OBS = 'ORTP205 - "+cNumPed+"'" +PULA
else
    cQry += "and c7_OBS like '%ORTP205%'"+cNumPed +PULA
endif
cQry +=  "and c7_produto in (SELECT b1_cod " +PULA
cQry +=     "FROM siga.totconsumo18, siga.SB1180"+" b1 ," +PULA
cQry +=     "siga.SBM200"+" bm ," +PULA
cQry +=     "siga.SX5180"+" X5 " +PULA
cQry +=     "WHERE b1_filial = '  ' " +PULA
cQry +=     "AND bm_filial = '  ' " +PULA
cQry +=     "AND b1.d_e_l_e_t_ = ' '" +PULA
cQry +=     "AND bm.d_e_l_e_t_ = ' '" +PULA
cQry +=     "AND X5.d_e_l_e_t_ = ' '" +PULA
cQry +=     "AND X5.X5_FILIAL  = '  ' " +PULA
cQry +=     "AND bm_grupo = b1_grupo " +PULA
cQry +=     "AND b1_cod = comp " +PULA
cQry +=     "AND X5_TABELA = 'ZD' " +PULA
cQry +=     "AND X5_CHAVE = b1_xmodelo" +PULA
cQry +=     "and b1_grupo = '"+cGrupo+"')" +PULA
cQry += "group by c7_filial, c7_produto, c7_descri, c7_um, c7_quant, c7_preco, c7_total, c7_obs, c7_ok "

MemoWrite("C:\ORTA791.sql",cQry)

    If Select("TMP") > 0
        dbSelectArea("TMP")
        TMP->(dbCloseArea())
    EndIf

    TcQuery cQry Alias "TMP" New

    DbSelectArea("TMP")
    dbGoTop()

    If Eof()
        MsgInfo("Não existe pedido de compra para geração de Pedido de vendas!","Rel. Requis. MP")
    else
        lMenu := .T.
    endIf

    if !Empty(cNumPed) 
        aProduto := {}
        while TMP->(!eof())
        nCt++
            aAdd(aProduto,{cNumPed, TMP->C7_PRODUTO, TMP->C7_QUANT, TMP->C7_PRECO, TMP->C7_OK})    
        TMP->(dbSkip())
        endDo
    FWMsgRun(, {|oSay| STARTJOB("U_ORTP791V",getenvserver(),.T.,/*cA1Cod*/,/*cA1Loja*/,/*cF4TES*/,/*cE4Codigo*/,aProduto) },'Executando Processo', 'Montando Ped. Venda')
    else
        
        //Criando o MarkBrow
        oMark := FWMarkBrowse():New()

        Aadd(aFields,{"c7_filial"	,"Filial" })
        Aadd(aFields,{"c7_produto"  ,"Produto" })
        Aadd(aFields,{"c7_descri"   ,"Descrição" })
        Aadd(aFields,{"c7_um"	    ,"UM" })
        Aadd(aFields,{"c7_quant"	,"Quantidade" })
        Aadd(aFields,{"c7_preco"	,"Preço"  })
        Aadd(aFields,{"c7_total"	,"Total"})
        Aadd(aFields,{"c7_obs"	    ,"Observação"})

        
        For nContFlds := 1 To Len( aFields )
        
            AAdd( aColumns, FWBrwColumn():New() )
        
            aColumns[Len(aColumns)]:SetData( &("{ || " + aFields[nContFlds][1] + " }") )
            aColumns[Len(aColumns)]:SetTitle( aFields[nContFlds][2] )
            aColumns[Len(aColumns)]:SetSize( tamSx3(aFields[nContFlds][1])[1] )
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
        oMark:SetSemaphore(.T.)
        //oMark:SetAlias(cTable)
        oMark:SetDescription('Itens Programados')
        oMark:SetFieldMark( 'C7_OK' )
        oMark:SetColumns( aColumns )
        oMark:SetDataQuery()
        oMark:SetQuery( cQry)
        oMark:SetAlias( cAlias )
        oMark:SetMenuDef('ORTA791')
        
        oMark:Activate()

        //Restaura area anterior 
        restArea(aArea)
    endif
    
//Fecha tabela
TMP->(dbCloseArea())

Return 

/*/{Protheus.doc} ORTA791LEG
    (long_description)
    @type  user Function
    @author user
    @since 15/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

user Function ORTL791LEG()
    Local oLegenda  :=  FWLegend():New()
 
    oLegenda:Add( '', 'BR_VERDE'   , "Item já em pedido de venda." )
    oLegenda:Add( '', 'BR_VERMELHO', "Item sem pedido de venda.")
    
    oLegenda:Activate()
    oLegenda:View()
    oLegenda:DeActivate()
Return Nil

/*
|MenuDef()
*/
//Caso crie os botões por função, abaixo seque um exemplo
Static Function MenuDef()
    
    Local aRot := {}
    
    ADD OPTION aRot TITLE "Gerar Ped. Venda"   ACTION "FWMsgRun(, {|oSay| u_procMark()},'Processando', 'Montando Pedidos')"  OPERATION 6 ACCESS 0
    if !lMenu
        ADD OPTION aRot TITLE "Impor. Ped. Compra" ACTION "FWMsgRun(, {|oSay| u_ORTP205()},'Executando Procedure', 'Montando Ped. Compras')"  OPERATION 6 ACCESS 0
    endif
//  ADD OPTION aRot TITLE "Legenda"     	   ACTION "u_ORTL791LEG()"  OPERATION 6 ACCESS 0
 
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
user Function procMark()

    Local aArea    := GetArea()
    Local cMarca   := oMark:Mark()
    //Local lInverte := oMark:IsInvert()
    Local nCt      := 0

    Private aProduto := {}
    Private cAlias := alias()
     
    //Percorrendo os registros da TMP
    (cAlias)->(DbGoTop())

    While !(cAlias)->(EoF())
        
        If oMark:IsMark(cMarca)
        nCt++
        aAdd(aProduto,{subs(Alltrim((cAlias)->C7_OBS),-6), (cAlias)->C7_PRODUTO, (cAlias)->C7_QUANT, (cAlias)->C7_PRECO, (cAlias)->C7_OK})
        
        //Limpando a marca, o execAuto vai gravar o campo na C7 direto
        RecLock(cAlias, .F.)
            C7_OK := ''
        (cAlias)->(MsUnlock())
        EndIf
         
        (cAlias)->(DbSkip())
    EndDo

    //ExecAuto Criação de pedido de venda
    If nCt > 0
        FWMsgRun(, {|oSay| u_ORTP791V(/*cA1Cod*/,/*cA1Loja*/,/*cF4TES*/,/*cE4Codigo*/,aProduto)},'Executando Procedure', 'Montando Ped. Venda')
        u_retNumPed()
        //CloseBrowse() //Fecha Tela
    else
        FWAlertWarning("Nenhum item selecionado na tela.", "Aviso!")
        return
    endif  

//Restaurando área armazenada
RestArea(aArea)

//Fecha a Area
//(cAlias)->(dbCloseArea())

Return NIL

/*/{Protheus.doc} ORTP205V
	(long_description)
	@type  Static Function
	@author Diogo Melo
	@since 13/12/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/

user function ORTP791V(cA1Cod,cA1Loja,cF4TES,cE4Codigo,aProduto)
	 
Local cDoc       := ""                                                                 // Número do Pedido de Vendas
Local cMsgLog    := ""
Local cFilSA1    := ""
Local cFilSB1    := ""
Local cFilSE4    := ""
Local cFilSF4    := ""
Local nOpcX      := 0
Local nX         := 0
Local aCabec     := {}
Local aItens     := {}
Local aLinha     := {}
Local lOk        := .T.
Local cQry       := ""
Local cUpd := ""
Local nStatus := 0
Local nValVen := 0
Local aLog := {}
Local cMsg := ""
Local cTexto1 := ""

PUBLIC cErro := ""


/*
if cEmpAnt != "03"
    FWAlertWarning("Rotina só pode ser executada no grupo 03.", "Bloqueio.")
    return .F.
endif
*/ 
 
PREPARE ENVIRONMENT EMPRESA "03" FILIAL "02" MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4","SE4","SF4","AGG"

//****************************************************************
//* Abertura do ambiente
//****************************************************************
U_JobCInfo("ORTA791.prw","Inicio: " + Time(),2)
//ConOut("Inicio: " + Time())
U_JobCInfo("ORTA791.prw",Repl("-",80),2)
//ConOut(Repl("-",80))
U_JobCInfo("ORTA791.prw",PadC(" Inclusao ", 80),2)
//ConOut(PadC(" Inclusao / Alteração / exclusão ", 80))
 
DEFAULT cA1Cod     := "99GRJ4"                              // Código do Cliente
DEFAULT cA1Loja    := "01"                                  // Loja do Cliente
//DEFAULT cB1Cod   := "000000000000000000000000000061"      // Código do Produto
DEFAULT cF4TES     := "605"                                 // Código do TES
DEFAULT cE4Codigo  := "360" 
DEFAULT cNumPed    := "TES999"                              // Código da Condição de Pagamento

Private nValVen := 1
Private nMargem := GETNEWPAR("MV_XMARKUP", 1.13) //Margem do preço de venda
 
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.

SA1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SE4->(dbSetOrder(1))
SF4->(dbSetOrder(1))
 
cFilAGG := xFilial("AGG")
cFilSA1 := xFilial("SA1")
cFilSB1 := xFilial("SB1")
cFilSE4 := xFilial("SE4")
cFilSF4 := xFilial("SF4")
 
//****************************************************************
//* Verificacao do ambiente para teste
//****************************************************************
/*
If SB1->(!MsSeek(cFilSB1 + cB1Cod))
   cMsgLog += "Cadastrar o Produto: " + cB1Cod + CRLF
   lOk     := .F.
EndIf
*/ 
If SF4->(!MsSeek(cFilSF4 + cF4TES))
   cMsgLog += "Cadastrar o TES: " + cF4TES 
   lOk     := .F.
EndIf
 
If SE4->(!MsSeek(cFilSE4 + cE4Codigo))
   cMsgLog += "Cadastrar a Condição de Pagamento: " + cE4Codigo 
   lOk     := .F.
EndIf
 
If SA1->(!MsSeek(cFilSA1 + cA1Cod + cA1Loja))
   cMsgLog += "Cadastrar o Cliente: " + cA1Cod + " Loja: " + cA1Loja 
   lOk     := .F.
EndIf
 
If lOk
 
   //cDoc := GetSxeNum("SC5", "C5_NUM")
   
   dbSelectArea("SC5")
   dbSetOrder(1)
   MsSeek(xFilial("SC5")+"zzzzzz",.T.)
   dbSkip(-1)
   
   cDoc := SC5->C5_NUM //Retorna o ultimo gravado

   while SC5->(MsSeek(xFilial("SC5")+cDoc))

        cDoc := GetSxeNum("SC5", "C5_NUM") //Soma1(cDoc)

   SC5->(dbSkip())
   endDo
   
   /*/cDoc := SC5->C5_NUM
   If Empty(cDoc)
	    cDoc := StrZero(1,Len(SC5->C5_NUM))
   Else
	    cDoc := Soma1(cDoc)
   EndIf
   /*/

   //****************************************************************
   //* Inclusao - INÍCIO
   //****************************************************************
   aCabec   := {}
   aItens   := {}
   aLinha   := {}

   aadd(aCabec, {"C5_NUM",     cDoc,      Nil})
   aadd(aCabec, {"C5_TIPO",    "N",       Nil})
   aadd(aCabec, {"C5_CLIENTE", cA1Cod,    Nil})
   aadd(aCabec, {"C5_LOJACLI", cA1Loja,   Nil})
   aadd(aCabec, {"C5_LOJAENT", cA1Loja,   Nil})
   aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})
   aadd(aCabec, {"C5_COTACAO", aProduto[1][1],Nil}) //Chumbado porque todos os itens são iguais
   aadd(aCabec, {"C5_XTPSEGM", "2"      , Nil})
   aadd(aCabec, {"C5_XOPER"  , "22"     , Nil})
   aadd(aCabec, {"C5_TABELA" , vldTabVen(), Nil})
   aadd(aCabec, {"C5_XTPPGT",  "07", Nil})
   aadd(aCabec, {"C5_XDESPRO", "3", Nil})
   aadd(aCabec, {"C5_XPEDFIC", "INT791", Nil})
   aadd(aCabec, {"C5_XDTVEND", dDatabase, Nil})
   aadd(aCabec, {"C5_TIPOCLI", "F", Nil})
   aadd(aCabec, {"C5_MENNOTA", "Pedido de compra: "+aProduto[1][1], Nil})
 
 
   If cPaisLoc == "PTG"
      aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
   Endif
 
   For nX := 1 To len(aProduto)
      		
		//Ultima Compra
        if nValVen == 1     
			 nValVen := Posicione("SB1",1,xFilial("SB1")+aProduto[nX][2],"B1_UPRC")
        elseif nValVen == 1
			nValVen := Posicione("SB2",1,xFilial("SB2")+aProduto[nX][2],"B2_CM1")
        endif

      nValVen := round(nValVen*nMargem,2)//Parametro numérico - 1.3

      //--- Informando os dados do item do Pedido de Venda
      aLinha := {}
      aadd(aLinha,{"C6_ITEM",    StrZero(nX,2)  , Nil})
      aadd(aLinha,{"C6_PRODUTO", aProduto[nX][2], Nil})
      aadd(aLinha,{"C6_QTDVEN",  aProduto[nX][3], Nil})
      aadd(aLinha,{"C6_PRCVEN",  nValVen, Nil})
      aadd(aLinha,{"C6_PRUNIT",  nValVen, Nil})
      aadd(aLinha,{"C6_VALOR",   aProduto[nX][3]*nValVen, Nil})
      aadd(aLinha,{"C6_TES",     cF4TES,        Nil})
      aadd(aItens, aLinha)
   Next nX
   //
   U_JobCInfo("ORTA791.prw","antes do execauto " + time(),2)
   nOpcX := 3
   MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, nOpcX, .F.)
   //
   U_JobCInfo("ORTA791.prw","depois do execauto " + time(),2)

   If !lMsErroAuto

        U_JobCInfo("ORTA791.prw","Incluido com sucesso! " + cDoc,2)
        //ConOut("Incluido com sucesso! " + cDoc)

        cQry := "select * from siga.sc7180 where D_E_L_E_T_ != '*'" +PULA
        cQry += "and c7_num = '"+aCabec[7][2]+"'" +PULA
        cQry += "and c7_residuo != 'S' "

        MemoWrite("C:\ORTP791V.sql",cQry)
        
        If Select("UPD") > 0
            dbSelectArea("QRY")
            QRY->(dbCloseArea())
        EndIf

        TcQuery cQry Alias "UPD" New

        DbSelectArea("UPD")
        dbGoTop()

        while UPD->(!eof())

            nRecSC7 := UPD->R_E_C_N_O_
            nPosPr  := aScan(aItens,{|x| AllTrim(x[2][2]) == alltrim(UPD->C7_PRODUTO) })
            
            if nPosPr > 0

            cUpd := "UPDATE siga.SC7180  SET C7_OBS = 'ORTA791 - "+cDoc+"', C7_OK = 'IN'" +PULA
            cUpd += "WHERE c7_NUM = '"+aCabec[7][2]+"'" +PULA
            cUpd += "AND C7_RESIDUO != 'S' " +PULA
            cUpd += "AND C7_PRODUTO = '"+UPD->C7_PRODUTO+"'"

            nStatus := TCSqlExec(cUpd)

                if (nStatus < 0)
                    U_JobCInfo("ORTA791.prw","TCSQLError() " + TCSQLError(),2)
                    //conout("TCSQLError() " + TCSQLError())
                    //FWAlertInfo(TCSQLError(), "TCSQLError()")
                    Return 
                endif

            endif

        UPD->(dbSkip())

        endDo

        UPD->(dbCloseArea())
        //Confirma numeração
        confirmSX8()

   Else

    U_JobCInfo("ORTA791.prw","Erro na inclusao - [MATA410]",2)
    //ConOut("Erro na inclusao - [MATA410]")

    AutoGrLog("Inicio error.log")
    AutoGrLog(Replicate("-", 20))

    aLog := GetAutoGRLog()
    For nX := 1 To Len(aLog)				
		cErro += aLog[nX] +CHR(13)+CHR(10)		
	Next nX		
    //
	if ExistDir( "\temp" )
        if FERASE("\temp\error.txt") == -1
            U_JobCInfo("ORTA791.prw","Erro delecao do arquivo de log",2)
        else
            U_JobCInfo("ORTA791.prw","Arquivo de log deletado com sucesso",2)
        endif
		MemoWrite( "\temp\"+"error.txt", cErro )
	else
		nRet := MakeDir( "\temp" )
        if nRet > 0
            MemoWrite( "\temp\error.txt", cErro )
        else
            U_JobCInfo("ORTA791.prw","Criação diretório do error.log - [MATA410]",2)
        endif
	endif
	//
    AutoGrLog(Replicate("-", 20))
    AutoGrLog("Fim")
    //
    U_JobCInfo("ORTA791.prw","Erro na inclusao - [MATA410]: "+cErro,2)

    /*/
    DEFINE DIALOG oDlg TITLE "Erro de inclusão:" FROM 180, 180 TO 550, 700 PIXEL
    // Usando o New
    cTexto1 := cMsg
    oTMultiget1 := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cTexto1 := u, cTexto1 ) }, ;
    oDlg, 260, 92, , , , , , .T. )

    ACTIVATE DIALOG oDlg CENTERED
    /*/
    //Retorna numeração anterior
    RollBackSX8()
   EndIf
   //****************************************************************
   //* Inclusao - FIM
   //****************************************************************
ELSE
    //FWAlertWarning(cMsgLog, "Erro Validação!")
    U_JobCInfo("ORTA791.prw","Erro de validacao "+cMsgLog,2)
    //conout("Erro de validacao "+cMsgLog)
ENDIF

//
Reset Environment
//

Return (.T.)

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 16/12/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function vldTabVen()

Local cQry := ""
Local cCodTab := ""
Local dDataAtu := dDatabase

cQry += "select * from siga."+retSqlName("DA0")+ " DA0 " +PULA
cQry += "where D_E_L_E_T_ != '*'" +PULA
cQry += "and DA0_DATATE like '%"+cValtochar(YEAR(DATE()))+"%'"
cQry += "and DA0_DATATE >= '"+dtos(dDataBase)+"'" +PULA

If Select("QRY") > 0
	dbSelectArea("QRY")
	QRY->(dbCloseArea())
EndIf

TcQuery cQry Alias "QRY" New

DbSelectArea("QRY")
dbGoTop()

If Eof()

	MsgInfo("Não existe pedido de compra para geração de Pedido de vendas!","Rel. Requis. MP")

else

    while QRY->(!eof())

    dDataDe  := stod(QRY->DA0_DATDE)
    dDataAte  := stod(QRY->DA0_DATATE)

    dDif1 := abs(dDataAtu - dDataDe)
    dDif2 := abs(dDataAtu - dDataAte)

        if (dDif1 + dDif2) == 10 /*.and. dDatabase >= dDataAte*/
            cCodTab := QRY->DA0_CODTAB
        endif

    QRY->(dbSkip())
    endDo
    
endIf
    
Return cCodTab
