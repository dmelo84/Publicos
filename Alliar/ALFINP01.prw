#INCLUDE 'TBICONN.CH'
#include "FILEIO.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "PROTHEUS.CH"


/*
ALFINP01
inclusao de título no CR (mutuo)

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFINP01()
	Local lOk            := .F.
	Local lMantem        := .T.
	Local cPerg          := 'ATFPT9'//'ALFINP1'
	Local cOldFilial     := cFilAnt

	Private cFilFornec   := ''
	Private cFilLoja     := ''
	Private cFilBco      := ''
	Private cFilAgencia  := ''
	Private cFilNumCon   := ''
	Private cFilCgc      := ''

	Private cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Private cNatOrMutuo  := SuperGetMV("ES_NATOR",, '')
	Private cTipOrMutuo  := SuperGetMV("ES_TPOR",, '')
	Private cNatDeMutuo  := SuperGetMV("ES_NATDE",, '')
	Private cTipDeMutuo  := SuperGetMV("ES_TPDE",, '')
	Private aPagto       := {}

	If Empty(cNatOrMutuo)
		Alert ("Informe a Natureza do Título do Contas a Receber (ES_NATOR)!")
		lMantem := .F.
	EndIf

	If Empty(cTipOrMutuo)
		Alert ("Informe o Tipo do Título do Contas a Receber(ES_TPOR)!")
		lMantem := .F.
	EndIf

	If Empty(cNatDeMutuo)
		Alert ("Informe a Natureza do Título do Contas a Pagar (ES_NATDE)!")
		lMantem := .F.
	EndIf

	If Empty(cTipDeMutuo)
		Alert ("Informe o Tipo do Título do Contas a Pagar(ES_TPDE)!")
		lMantem := .F.
	EndIf

	lMantem := PegForDaFIlial()

	AjustSx1(cPerg)
//SetaVlrDefault(cPerg)
	While lMantem

		If	pergunte(cPerg,.T.)

			If Empty(MV_PAR01)//prefixos
				Alert ("Informe o Prefixo!")
				Loop
			EndIf

			If AllTrim(cPrefMutuo) != AllTrim(MV_PAR01)
				Alert ("O prefixo deve ser idêntico ao informado no parâmetro ES_PRMU:" + AllTrim(cPrefMutuo) )
				Loop
			EndIf


			If Empty(MV_PAR03)//emissao
				Alert ("Informe a Emissão do título no Contas a Receber!")
				Loop
			EndIf

			If Empty(MV_PAR05)//cond pgto
				Alert ("Informe a condição de pagamento!")
				Loop
			EndIf

			If Empty(MV_PAR06)//cliente
				Alert ("Informe o cliente origem!")
				Loop
			EndIf

			If Empty(MV_PAR07)//loja
				Alert ("Informe a loja do cliente origem!")
				Loop
			EndIf

			DbSelectArea("SA1")
			DbSetOrder(1)

			If PosCli(mv_par06, mv_par07)
				If AllTrim(SA1->A1_COD) == AllTrim(mv_par06) .And. AllTrim(SA1->A1_LOJA) == AllTrim(mv_par07)

					If AllTrim(cFilcgc) == AllTrim(SA1->A1_CGC)
						Alert ("O cliente não deve possuir o mesmo CNPJ do Fornecedor utilizado como Mútuo (" + AllTrim(SA1->A1_CGC) + ") !")
						Loop
					ENdIf

					If AllTrim(SA1->A1_XM0FIL) == AllTrim(cFilAnt)
						Alert ("O cliente não deve possuir a mesma Empresa-Filial do Fornecedor utilizado como Mútuo (" + AllTrim(cFIlAnt) + ") !")
						Loop
					EndIf

					If AllTrim(SA1->A1_XCLM0) != "1"
						Alert ("Cliente não está configurado como Mútuo!")
						Loop
					EndIf

					If Empty(MV_PAR10)//SA1->A1_XMAG)
						Alert ("Agência não informada no cadastro do Cliente!")
						Loop
					EndIf

					If Empty(MV_PAR11)//SA1->A1_XMCN)
						Alert ("Conta não informada no cadastro do Cliente!")
						Loop
					EndIf

					If Empty(MV_PAR09)//SA1->A1_XMBC)
						Alert ("Banco não informada no cadastro do Cliente!")
						Loop
					EndIf

					cFilAnt := SA1->A1_XM0FIL
				                                   /*     removi 01-04-16
				DbSelectArea("SA6")
				DbSetOrder(1)
				DbSeek( xFilial("SA6") + MV_PAR09 + MV_PAR10 + MV_PAR11,.T.)   

					If !(SA6->(!Eof()) .And. Alltrim(SA6->A6_COD) == AllTrim(MV_PAR09) .And.  Alltrim(SA6->A6_AGENCIA) == AllTrim(MV_PAR10) .And.  Alltrim(SA6->A6_NUMCON) == AllTrim(MV_PAR11) )
					Alert ("Banco\Agência e Conta do Cliente não cadastrados no sistema (Tabela SA6) na Empresa-filial("+ cFilAnt + ") !")
					Loop
					EndIf                            */
				
				cFilAnt := cOldFilial
					
				Else
				Alert ("Cliente não localizado")
				Loop
				EndIf
			Else
			Alert ("Cliente não localizado no sistema")
			Loop
			EndIf

			If (MV_PAR04) <= 0//valor
			Alert ("Informe o Valor!")
			Loop
			EndIf
			
		aPagto := Condicao(MV_PAR04,MV_PAR05,,dDataBase) // Total para o calculo, cod. cond.pgto,data base
		
			If Len(aPagto) <= 0
			Alert ("Informe uma condição de pagamento Válida!")
			Loop
			EndIf
		lOk := .T.
		lMantem := .F.		
		//-->MV_PAR14//moeda
		Else
		lMantem := .F.
		EndIf

	End

	IF lOk
	Processa({|| MutuoProc()}, 'Aguarde...', 'Processando verificacao...')
	EndIf
    
Return


/*
ALFIN1
Validacoes ao final da inclusao do cliente ou do fornecedor
@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFIN1(cRotina)
	Local lRet := .T.
	//Local cPsqAlias
	// := cFilAnt

	If cRotina == "MATA030"

		If M->A1_XCLM0 == "1"
			If Empty(M->A1_XM0FIL)
				Alert ("Empresa-filial não localizada. Campo A1_XM0FIL!")
				lRet := .F.
			EndIf
		                            /* removi 01-04-16
			If lRet .And. Empty(M->A1_XMAG)
			Alert ("Para clientes que utilizam o Mútuo é obrigatório a informação da Agência!")
			lRet := .F.
			EndIf
		
			If lRet .And. Empty(M->A1_XMCN)
			Alert ("Para clientes que utilizam o Mútuo é obrigatório a informação da Conta!")
			lRet := .F.
			EndIf
		
			If lRet .And. Empty(M->A1_XMBC)
			Alert ("Para clientes que utilizam o Mútuo é obrigatório a informação do Banco!")
			lRet := .F.
			EndIf                     */
		
			If lRet
		/*
			DbSelectArea("SA6")
			DbSetOrder(1)
			
			cFilAnt := M->A1_XM0FIL
			DbSeek( FwxFilial('SA6') + M->A1_XMBC + M->A1_XMAG + M->A1_XMCN,.T.)
			cFilAnt := cOldAnt

				If !(SA6->(!Eof()) .And. Alltrim(SA6->A6_COD) == AllTrim(M->A1_XMBC) .And.  Alltrim(SA6->A6_AGENCIA) == AllTrim(M->A1_XMAG) .And.  Alltrim(SA6->A6_NUMCON) == AllTrim(M->A1_XMCN) )
				Alert ("Banco\Agência e Conta do Cliente não cadastrados no sistema (Tabela SA6)!")
				lRet := .F.
				EndIf
			
				If SA1JaExisteNestaFilial(M->A1_COD, M->A1_LOJA, M->A1_XM0FIL)//se ja existia SA1 vinculado a esta filial critica a amarraçao de um segundo SA1
				lRet := .F.
				EndIf*/
			EndIf
		Else
	                                        /* removi 01-04-16
			If lRet .And. !Empty(M->A1_XMAG)
			Alert ("Para clientes que não utilizam o Mútuo não utilizamos a informação da Agência!")
			lRet := .F.
			EndIf
		
			If lRet .And. !Empty(M->A1_XMCN)
			Alert ("Para clientes que não utilizam o Mútuo não utilizamos a informação da Conta!")
			lRet := .F.
			EndIf
		
			If lRet .And. !Empty(M->A1_XMBC)
			Alert ("Para clientes que não utilizam o Mútuo não utilizamos a informação do Banco!")
			lRet := .F.
			EndIf                             */
		
		/*
		cPsqAlias := GetNextAlias()
			BeginSql Alias cPsqAlias
		
		SELECT SE2.*
		       
		       FROM %table:SE2% SE2
		       WHERE SE2.%NotDel%
		             AND SE2.E2_XMCLI = %Exp:(M->A1_COD)%
		             AND SE2.E2_XMLOJ = %Exp:(M->A1_LOJA)%
		                                            
			EndSql

			If (cPsqAlias)->(!Eof())
				If  (AllTrim((cPsqAlias)->(E2_XMCLI)) == AllTrim(M->A1_COD) .and. AllTrim((cPsqAlias)->(E2_XMLOJ)) == AllTrim(M->A1_LOJA)  )
					ALert ("Este cliente já fora utilizado como mútuo gerando título a Pagar na Empresa-Filial:" + AllTrim((cPsqAlias)->(E2_FILIAL)) + " Titulo: " +  AllTrim((cPsqAlias)->(E2_NUM)) + " Prefixo: " +  AllTrim((cPsqAlias)->(E2_PREFIXO)) + "! Não é possível desativar o campo Mútuo!"  )
					lRet := .F.
				EndIf
			EndIf

			(cPsqAlias)->(DbCLoseArea())
	*/
		EndIf


	ELse
    /*
		If M->A2_XCLM0 == "1" .And. cRotina == "MATA020"
			If Empty(M->A2_XM0FIL)
			Alert ("Empresa-filial não localizada. Campo A2_XM0FIL!")
			lRet := .F.
			EndIf
		
			If lRet .And. Empty(M->A2_AGENCIA)
			Alert ("Para fornecedores que utilizam o Mútuo é obrigatório a informação da Agência!")
			lRet := .F.
			EndIf
		
			If lRet .And. Empty(M->A2_NUMCON)
			Alert ("Para fornecedores que utilizam o Mútuo é obrigatório a informação da Conta!")
			lRet := .F.
			EndIf
		
			If lRet .And. Empty(M->A2_BANCO)
			Alert ("Para fornecedores que utilizam o Mútuo é obrigatório a informação do Banco!")
			lRet := .F.
			EndIf
		
			If lRet
		
			DbSelectArea("SA6")
			DbSetOrder(1)
		
			cFilAnt := M->A2_XM0FIL
			DbSeek( Fwxfilial('SA6') + M->A2_BANCO + M->A2_AGENCIA + M->A2_NUMCON,.T.)
			cFilAnt := cOldAnt
				
				If !(SA6->(!Eof()) .And. Alltrim(SA6->A6_COD) == AllTrim(M->A2_BANCO) .And.  Alltrim(SA6->A6_AGENCIA) == AllTrim(M->A2_AGENCIA) .And.  Alltrim(SA6->A6_NUMCON) == AllTrim(M->A2_NUMCON) )
				Alert ("Banco\Agência e Conta do Fornecedor não cadastrados no sistema (Tabela SA6)!")
				lRet := .F.
				EndIf
			
				If SA2JaExisteNestaFilial(M->A2_COD, M->A2_LOJA, M->A2_XM0FIL)//se ja existia SA2 vinculado a esta filial critica a amarraçao de um segundo SA2
				lRet := .F.
				EndIf
			EndIf
		EndIf
	
		If M->A2_XCLM0 != "1" .And. cRotina == "MATA020"
		cPsqAlias := GetNextAlias()
			BeginSql Alias cPsqAlias
		
		SELECT SE1.*
		       
		       FROM %table:SE1% SE1
		       WHERE  SE1.%NotDel%
		             AND SE1.E1_XMFOR = %Exp:(M->A2_COD)%
		             AND SE1.E1_XMLOJ = %Exp:(M->A2_LOJA)%
		                                            
			EndSql

			If (cPsqAlias)->(!Eof())
				If  (AllTrim((cPsqAlias)->(E1_XMFOR)) == AllTrim(M->A2_COD) .and. AllTrim((cPsqAlias)->(E1_XMLOJ)) == AllTrim(M->A2_LOJA)  )
					ALert ("Este fornecedor já fora utilizado como mútuo de destino do Contas a Receber na Empresa-Filial:" + AllTrim((cPsqAlias)->(E1_FILIAL)) + " Titulo: " +  AllTrim((cPsqAlias)->(E1_NUM)) + " Prefixo: " +  AllTrim((cPsqAlias)->(E1_PREFIXO)) + "! Não é possível desativar o campo Mútuo!"  )
					lRet := .F.
				EndIf
			EndIf

			(cPsqAlias)->(DbCLoseArea())

		EndIf
	*/

	EndIf

return lRet

/*/{Protheus.doc} MutuoProc

Executa rotina de geracao de titulos no CP

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/                

Static Function MutuoProc ()
	Local nInd  := 1
	Local cParc := ''
	Local nTam  := TamSX3("E2_PARCELA")[1]
	Local cMsgTit := ''
	Local cNumE2  := ''
	Local cNumE1  := ''
	Local cArqErrAuto := ''
	Local __nSaveSX8
	Local aItens := {}
	Local lOk := .F.
	Local nRecSE1
	Local nCalcNum := 0
	Local cOldFilAnt := cFilAnt
	Private cCttXCusto := ''
	Private cHistCP     := ''
	Private cHistCR     := ''
	Private lMsErroAuto := .F.
	Private cCRAgencia := ''
	Private cCRConta   := ''
	Private cCRBanco   := ''
	Private cCPAgencia := ''
	Private cCPConta   := ''
	Private cCPBanco   := ''
	Private cCttFilial   := ''
	Private cNumUnicoMutuo   := SuperGetMV("ES_NUUN",, '1')

	dbselectarea('SX6')
	SX6->(dbsetorder(1))
	SX6->( dbseek(xfilial() + "ES_NUUN")  )

	if SX6->(!Eof())
		nCalcNum := Val(cNumUnicoMutuo)
		nCalcNum += 1
		cNumUnicoMutuo   := STR(nCalcNum)//pediram para remover : SOma1(cNumUnicoMutuo)
		cNumUnicoMutuo   := AllTrim(cNumUnicoMutuo)

		PutMV("ES_NUUN",cNumUnicoMutuo)
	endif


	cNumUnicoMutuo := padl (  AllTrim(cNumUnicoMutuo),  TamSx3("E2_NUM")[1],  "0")

//cFIlAnt := SA2->A2_XM0FIL
	CttDaFilial()

/*
	If Empty(cCttFilial) .or. Empty(cCttXCusto)
	Alert ("Informe o Centro de Custos padrão desta filial para utilizarmos nos títulos que serão gerados (vide campo CTT_XEMPFI)!")
	return
	EndIf
*/
//cFilAnt := cOldFilAnt 

	For nInd := 1 to nTam
		cParc += '0'
	Next

	DbSelectArea("SA1")
	DbSetOrder(1)
	PosCli( mv_par06 , mv_par07)

	cCRAgencia := ''//cFilBco      >>>> Toninho e Glauton pediram para naoalimentar aqui mais nada ...so na tela de baixa do CP o sistema abrira uma telinha exigindo infromarem o banco
	cCRConta   := ''//cFilAgencia
	cCRBanco   := ''//cFilNumCon

	cCPAgencia := MV_PAR09//SA2->A1_XMAG
	cCPConta   := MV_PAR10//SA2->A1_XMCN
	cCPBanco   := MV_PAR11//SA2->A1_XMBC

	ProcRegua(0)

	DbSelectArea('SE2')
	DbSetOrder(1)
	cNumE2 := cNumUnicoMutuo//->GetSx8Num("SE2","E2_NUM")//fui instruido a pegar a numeração e já deixar registrado ela como confirmada ...não haverá rollback se deu erro no execauto. Ou seja, já irá gerar novo pedido se entrar de novo
//->ConfirmSX8()//ja deixa 'queimado' o numero mesmo


	cFIlAnt := SA1->A1_XM0FIL

	DbSelectArea('SE1')
	DbSetOrder(1)
	cNumE1 := cNumUnicoMutuo//->GetSx8Num("SE1","E1_NUM")//fui instruido a pegar a numeração e já deixar registrado ela como confirmada ...não haverá rollback se deu erro no execauto. Ou seja, já irá gerar novo pedido se entrar de novo
//->ConfirmSX8()//ja deixa 'queimado' o numero mesmo


	cFilAnt := cOldFilAnt


	Begin Transaction

		For nInd := 1 to Len(aPagto)//apagto[1][1]  data     apagto[1][1] valor


			cParc := AllTrim(cParc)
			cParc := Soma1(cParc,2)

			If nInd == 1
				__nSaveSX8  := GetSX8Len()
				DbSelectArea('SE1')
				DbSetOrder(1)

				//- cNumE1 := GetSx8Num("SE1","E1_NUM")//fui instruido a pegar a numeração e já deixar registrado ela como confirmada ...não haverá rollback se deu erro no execauto. Ou seja, já irá gerar novo pedido se entrar de novo
			EndIf

			aItens := Nil
			aItens := {}
			aItens := {     { "E1_FILIAL"	, Fwxfilial('SE1')	   							, NIL, },;
				{ "E1_PREFIXO"	, padr(cPrefMutuo,TamSX3("E1_PREFIXO")[1])	    , NIL, },;
				{ "E1_NUM"		, padr(cNumE1,TamSX3("E1_NUM")[1])		    	, NIL, },;
				{ "E1_PARCELA"	, cParc  										, NIL, },;
				{ "E1_TIPO"		, padr(cTipOrMutuo,TamSX3("E1_TIPO")[1])	    , NIL, },;
				{ "E1_NATUREZ"	, padr(cNatOrMutuo,TamSX3("E1_NATUREZ")[1])	    , NIL, },;
				{ "E1_CLIENTE"	, padr(SA1->A1_COD,TamSX3("E1_CLIENTE")[1])     , NIL, },;
				{ "E1_LOJA"		, padr(SA1->A1_LOJA,TamSX3("E1_LOJA")[1])		, NIL, },;
				{ "E1_EMISSAO"	, mv_par03  									, NIL, },;
				{ "E1_VENCTO"	, aPagto[nInd][1]  								, NIL, },;
				{ "E1_VENCREA"	, VencReal(aPagto[nInd][1])         			, NIL, },;
				{ "E1_VALOR"	, aPagto[nInd][2]	             				, NIL, } , ;					//{ "E1_PORTADO"	, padr(SA1->A1_XMBC,TamSX3("E1_PORTADO")[1])	, NIL, },;
				{ "E1_MOEDA"	, Val(mv_par02)          						, NIL ,},;
				{ "E1_CCUSTO"	, MV_PAR12              						, NIL ,},;
				{ "E1_XMFIL"    , SA1->A1_XM0FIL          						, NIL ,},;
				{ "E1_XMPRF"    , cPrefMutuo          							, NIL ,},;
				{ "E1_XMTIP"    , cTipDeMutuo          							, NIL ,},;
				{ "E1_XMPAR"    , cParc          							   , NIL ,},;
				{ "E1_XMFOR"    , padr(cFilFornec,TamSX3("E2_FORNECE")[1])             , NIL ,},;
				{ "E1_XMLOJ"    , padr(cFilLoja,TamSX3("E2_LOJA")[1])          		   , NIL ,} }

			//Toninho pediu para remover { "E1_XMAG"    ,  cFilAgencia         							       , NIL ,},;
				//{ "E1_XMCN"    ,  cFilNumCon         							       , NIL ,},;
				//{ "E1_XMBC"    ,  cFilBco/*SA1->A1_XMBC*/         				       , NIL ,}


			aEval(aItens ,{|x| x[4] := Posicione("SX3", 2, x[1], "X3_ORDEM") })
			aItens := aSort(aItens,,,{|x,y| x[4] < y[4]})
			nRecSE1 := 0
			lMsErroAuto := .F.
			SetFunName("FINA040")
			IncProc("Processando inclusão do Tìtulo no Contas a Receber da filial Origem")
			MsExecAuto( { |x,y| FINA040(x,y)}, aItens, 3)//<-- inclui manualmente todas as parcelas do titulo fatura

			If lMsErroAuto

				cArqErrAuto := NomeAutoLog()

				MostraErros()
				Ferase(cArqErrAuto)

				If nInd == 1
					If ( GetSX8Len() > __nSaveSX8 )
						//--RollBackSX8()

						//alert ('rollback na SE1')
					EndIf
				EndIf

				lOk := .F.
			Else

				If nInd == 1
					cHistCR := "Emp-fil: " + AllTrim(cFIlAnt) + " Tit: " + AllTrim(cNumE1)
					cMsgTit := "Inserido no Contas a Receber da Empresa-Filial(" + AllTrim(cFIlAnt)+ ") o Título: " + AllTrim(cNumE1) +  " !" + CHr(13) + CHr(10)
				EndIf

				nRecSE1 := SE1->(Recno())

				lOk := .T.
				//Desativar por enquanto: IncMovBancario(.T., SE1->E1_NATUREZ, SE1->E1_VALOR)

			EndIf


			If lOk


				cFilAnt := SA1->A1_XM0FIL
				If nInd == 1

					__nSaveSX8  := GetSX8Len()

					DbSelectArea('SE2')
					DbSetOrder(1)
					//	cNumE2 := GetSx8Num("SE2","E2_NUM")

				EndIf


				IncProc("Geranto título na Empresa Filial Destino")


				aItens := Nil
				aItens := {}
				aItens := { 	        { "E2_FILIAL"	, Fwxfilial('SE2')		      						   , NIL, },;
					{ "E2_PREFIXO"	, padr(cPrefMutuo,TamSX3("E2_PREFIXO")[1])	           , NIL, },;
					{ "E2_NUM"		, padr(cNumE2    ,TamSX3("E2_NUM")[1])	  			   , NIL, },;
					{ "E2_PARCELA"	, cParc 			               					   , NIL, },;
					{ "E2_TIPO"		, padr(cTipDeMutuo,TamSX3("E2_TIPO")[1])			   , NIL, },;
					{ "E2_NATUREZ"	, padr(cNatDeMutuo,TamSX3("E2_NATUREZ")[1])   	       , NIL ,},;
					{ "E2_FORNECE"	, padr(cFilFornec,TamSX3("E2_FORNECE")[1]) 		       , NIL, },;
					{ "E2_LOJA"		, padr(cFilLOja,TamSX3("E2_LOJA")[1])   			   , NIL, },;
					{ "E2_EMISSAO"	, mv_par03			    							   , NIL, },;
					{ "E2_VENCTO"	, aPagto[nInd][1] 			    					   , NIL, },;
					{ "E2_VENCREA"	, VencReal(aPagto[nInd][1])   						   , NIL ,},;
					{ "E2_VALOR"	, aPagto[nInd][2]	            					   , NIL ,},;//	            { "E2_PORTADO"	, padr(MV_PAR09,TamSX3("E2_PORTADO")[1])               , NIL ,},;
					{ "E2_MOEDA"	, Val(mv_par02)          							   , NIL ,},;
					{ "E2_XMFIL"    , cOldFilAnt          							       , NIL ,},;
					{ "E2_XMNUM"    , cNumE1          									   , NIL ,},;
					{ "E2_XMPRF"    , cPrefMutuo           								   , NIL ,},;
					{ "E2_XMTIP"    , cTipOrMutuo           							   , NIL ,},;
					{ "E2_XMPAR"    , cParc          									   , NIL ,},;
					{ "E2_XMCLI"     , padr(mv_par06,TamSX3("E1_CLIENTE")[1])   	       , NIL ,},;
					{ "E2_XMLOJ"    , padr(mv_par07,TamSX3("E1_LOJA")[1])          		   , NIL ,},;
					{ "E2_XMAG"    ,  MV_PAR10         							  	     , NIL ,},;
					{ "E2_XMCN"    ,  MV_PAR11         							  	     , NIL ,},;
					{ "E2_CCUSTO"     ,  /*cCttXCusto*/ MV_PAR12   				       , NIL ,},;
					{ "E2_XMBC"    ,  /*SA2->A2_BANCO*/MV_PAR09         			       , NIL ,} }




				//este campo nao sera usado apos explicacAO DE toNINHO { "E2_XCNPJ"     ,  cCttFilial         							       , NIL ,},;
					//este campo nao sera usado { "E2_CCD"     ,  cCttFilial         							       , NIL ,},;

				aEval(aItens ,{|x| x[4] := Posicione("SX3", 2, x[1], "X3_ORDEM") })
				aItens := aSort(aItens,,,{|x,y| x[4] < y[4]})

				lMsErroAuto := .F.

				MsExecAuto( { |x,y| FINA050(x,y)}, aItens, 3)//<-- inclui manualmente todas as parcelas do titulo fatura

				If lMsErroAuto
					cArqErrAuto := NomeAutoLog()
					MostraErro()
					Ferase(cArqErrAuto)

					cFilAnt := cOldFilAnt

					lOk := .F.
				Else

					If nInd == 1
						cHistCP := "Emp-fil: " + AllTrim(cFIlAnt) + " Tit: " + AllTrim(cNumE2)
						cMsgTit += "Geramos no Contas a Pagar da Empresa-Filial (" + AllTrim(cFIlAnt) +   ") o Título: " + AllTrim(cNumE2) + " !"
					EndIf

					lOk := .T.

					//Desativar por enquanto: IncMovBancario(.F., SE2->E2_NATUREZ, SE2->E2_VALOR)
					cFilAnt := cOldFilAnt

					SE1->(DbGoTo(nRecSe1))

					reclock('SE1',.F.)
					SE1->E1_XMNUM := SE2->E2_NUM//atualiza na origem o nro do titulo CP gerado na outra filial de destino
					MsUNLock()


				EndIf
				//-------------------------------------------------------------------------------------------

			EndIf

			If lOk == .F.
				DisarmTransaction()

				exit
			EndIf

		Next

		If lOk == .F.
			DisarmTransaction()
		EndIf


	End Transaction


	If lOk
		MsgInfo(cMsgTit)
	EndIf

return  //nrecse1

/*/{Protheus.doc} AJustSX1

Perguntas/parametros para impressao

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/                
Static Function AjustSX1(CPERG)
	Local nCnt := 0

	dbSelectArea("SX1")  //APRESENTAR ESTES CAMPOS NA MATA112
	dbsetOrder(1)
	dbSeek(CPERG)

	While AllTrim(SX1->(FIELDGET(FIELDPOS("X1_GRUPO")))) == CPERG //hfp

		If AllTrim(SX1->(FIELDGET(FIELDPOS("X1_PERGUNT")))) == "Prefixo ?"
			nCnt += 1
			Reclock('SX1',.F.)
			SX1->(FIELDGET(FIELDPOS("X1_CNT01")))  := cPrefMutuo
			MsUnLock()

			If nCnt == 2
				exit
			EndIf
		EndIf

		If AllTrim(SX1->(FIELDGET(FIELDPOS("X1_PERGUNT")))) == "Moeda ?"
			nCnt += 1

			Reclock('SX1',.F.)
			SX1->(FIELDGET(FIELDPOS("X1_CNT01")))  := '1  '
			MsUnLock()

			If nCnt == 2
				exit
			EndIf
		EndIf

		SX1->(DbSkip())
	End

//==================================================================================
	DBSELECTAREA("SX1")
	DBSETORDER(1)

	PutSx1(cPerg, "01", "Prefixo", "Prefixo", "Prefixo"      , "mv_ch1", "C", 03, 0, 0, "S", "", "", "", "",       "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )

	PutSx1(cPerg, "02", "Moeda", "Moeda", "Moeda"            , "mv_ch2", "C", 03, 0, 0, "S", "", "", "", "",       "MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )

	PutSx1(cPerg, "03", "Emissão", "Emissão", "Emissão"      , "mv_ch3", "D", 08, 0, 0, "G", "", "", "", "",       "MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
//PutSx1(cPerg, "04", "Tipo",      "Tipo",  "Tipo"         , "mv_ch4", "C", 03, 0, 0, "G", "", "05", "", "",     "MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
	PutSx1(cPerg, "04", "Valor", "Valor", "Valor"            , "mv_ch4", "N", 12, 2, 0, "G", "", "", "", "",       "MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )



	PutSx1(cPerg, "05", "Cond Pgto",     "Cond Pgto",     "Cond Pgto",     "mv_ch5", "C", 03                 , 0, 0, "G", "", "SE4", "", "",    "MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
	PutSx1(cPerg, "06", "Cliente",       "Cliente",       "Cliente"      , "mv_ch6", "C", TamSx3("A1_COD")[1], 0, 0, "G", "", "ALLSA1", "", "", "MV_PAR06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
	PutSx1(cPerg, "07", "Loja.",         "Loja.",         "Loja."         , "mv_ch7","C", TamSx3("A1_LOJA")[1], 0, 0, "G", "", "", "", "",        "MV_PAR07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
	PutSx1(cPerg, "08", "Nome.",         "Nome",          "Nome"         , "mv_ch8", "C", 40                  , 0, 0, "G", "", "", "", "",        "MV_PAR08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )


	PutSx1(cPerg, "09", "Bco ",    "Bco ",    "Bco "   , "mv_ch9", "C", TamSx3("A6_COD")[1], 0, 0, "G", "", "ALLS17", "", "", "MV_PAR09", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
	PutSx1(cPerg, "10", "Agenc. ", "Agenc. ", "Agenc. ", "mv_chA", "C", TamSx3("A6_AGENCIA")[1], 0, 0, "G", "", "", "", "",       "MV_PAR10", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
	PutSx1(cPerg, "11", "Conta ",  "Conta ",  "Conta " , "mv_chB", "C", TamSx3("A6_NUMCON ")[1], 0, 0, "G", "", "", "", "",        "MV_PAR11", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )




//PutSx1(cPerg, "12", "Vencto", "Vencto", "Vencto"         , "mv_chC", "D", 08, 0, 0, "G", "", "", "", "",       "MV_PAR12", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
//PutSx1(cPerg, "13", "Valor", "Valor", "Valor"            , "mv_chD", "N", 12, 2, 0, "G", "", "", "", "",       "MV_PAR13", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
//PutSx1(cPerg, "12", "Moeda", "Moeda", "Moeda"            , "mv_chC", "N", 02, 0, 0, "G", "", "", "", "",       "MV_PAR12", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )


return

/*
ALFIN2
Busca empresa filial para campo de mutuo
@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFIN2(cRotina)
	Local cRet := " "

	If cRotina == "MATA030"
		If M->A1_XCLM0 == "1"
			cRet := SM0->M0_CODFIL
		EndIf
	EndIf
/*
	If cRotina == "MATA020"
		If M->A2_XCLM0 == "1"
		cRet := SM0->M0_CODFIL
		EndIf
	EndIf*/
	
return cRet


/*
SA1JaExisteNestaFilial
PARA UMA MESMA FILIAL NAO PODERÃO EXISTIR 2 CLIENTES DE ORIGEM DO MUTUO! MAS SIM APENAS PODE HAVER 1 !
@author 
@since 09/12/2014
@version 1.0
*/

Static Function SA1JaExisteNestaFilial(cCli, cLj, cInfoFilial)
	Local cA1Alias := GetNextAlias()
	Local lRet := .F.
	BeginSql Alias cA1Alias

SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_XM0FIL
       
       FROM %table:SA1% SA1
       WHERE SA1.A1_FILIAL     = %xFilial:SA1%  
             AND SA1.%NotDel%
             AND SA1.A1_XM0FIL = %Exp:(cInfoFilial)%                               
       		 AND  (SA1.A1_COD   <> %Exp:(cCli)%   OR   SA1.A1_LOJA  <> %Exp:(cLj)% )
       		 			 
	EndSql

	If (cA1Alias)->(!Eof())
		If  !Empty((cA1Alias)->(A1_XM0FIL)) .And.   (AllTrim((cA1Alias)->(A1_COD)) != AllTrim(cCli) .or. AllTrim((cA1Alias)->(A1_LOJA)) != AllTrim(cLj)  )
			ALert ("Já existe um cliente vinculado a esta Empresa-Filial (Cod:" + AllTrim((cA1Alias)->(A1_COD)) + " Loja: " + AllTrim((cA1Alias)->(A1_LOJA)) + "! Não é possível vincular 2 ou mais clientes na mesma Empresa-Filial"  )
			lRet := .T.
		EndIf
	EndIf

	(cA1Alias)->(DbCLoseArea())

return lRet


/*
PosCli

@author 
@since 09/12/2014
@version 1.0
*/

Static Function PosCli(cCli, cLj)
	Local cA1Alias := GetNextAlias()
	Local lRet := .F.
	BeginSql Alias cA1Alias

SELECT SA1.*
       
       FROM %table:SA1% SA1
       WHERE SA1.A1_FILIAL     = %xFilial:SA1%  
             AND SA1.%NotDel%
             AND  (SA1.A1_COD   = %Exp:(cCli)%   AND   SA1.A1_LOJA  = %Exp:(cLj)% )
       		 			 
	EndSql

	If (cA1Alias)->(!Eof()) .ANd. AllTrim( (cA1Alias)->(A1_COD) )  ==  AllTrim(cCli)  .And. Alltrim( (cA1Alias)->(A1_LOJA) ) ==  AllTrim(cLj)
		SA1->(DbGoTo( (cA1Alias)->(R_E_C_N_O_) )   )
		lRet := .T.
	EndIf

	(cA1Alias)->(DbCLoseArea())

return lRet

/*
PosCli

@author 
@since 09/12/2014
@version 1.0
*/

Static Function PosFor(cFor, cLj)
	Local cA2Alias := GetNextAlias()
	Local lRet := .F.
	BeginSql Alias cA2Alias

SELECT SA2.*
       
       FROM %table:SA2% SA2
       WHERE SA2.A2_FILIAL     = %xFilial:SA2%  
             AND SA2.%NotDel%
             AND  (SA2.A2_COD   = %Exp:(cFor)%   AND   SA2.A2_LOJA  = %Exp:(cLj)% )
       		 			 
	EndSql

	If (cA2Alias)->(!Eof()) .ANd. AllTrim( (cA2Alias)->(A2_COD) )  ==  AllTrim(cFor)  .And. Alltrim( (cA2Alias)->(A2_LOJA) ) ==  AllTrim(cLj)
		SA2->(DbGoTo( (cA2Alias)->(R_E_C_N_O_) )  )
		lRet := .T.
	EndIf

	(cA2Alias)->(DbCLoseArea())

return lRet

/*
SA2JaExisteNestaFilial
PARA UMA MESMA FILIAL NAO PODERÃO EXISTIR 2 FORNECS DE ORIGEM DO MUTUO! MAS SIM APENAS PODE HAVER 1 !
@author 
@since 09/12/2014
@version 1.0


Static Function SA2JaExisteNestaFilial(cFor, cLj, cInfoFilial)//<===============================
Local cA2Alias := GetNextAlias()
Local lRet := .F.
	BeginSql Alias cA2Alias

SELECT SA2.A2_COD, SA2.A2_LOJA, SA2.A2_XM0FIL
       
       FROM %table:SA2% SA2
       WHERE SA2.A2_FILIAL     = %xFilial:SA2%  
             AND SA2.%NotDel%
             AND SA2.A2_XM0FIL = %Exp:(cInfoFilial)%                               
       		 AND  (SA2.A2_COD   <> %Exp:(cFor)%   OR   SA2.A2_LOJA  <> %Exp:(cLj)% )
       		 			 
	EndSql

	If (cA2Alias)->(!Eof())
		If  !Empty((cA2Alias)->(A2_XM0FIL)) .And.   (AllTrim((cA2Alias)->(A2_COD)) != AllTrim(cFor) .or. AllTrim((cA2Alias)->(A2_LOJA)) != AllTrim(cLj)  )
			ALert ("Já existe um fornecedor vinculado a esta Empresa-Filial (Cod:" + AllTrim((cA2Alias)->(A2_COD)) + " Loja: " + AllTrim((cA2Alias)->(A2_LOJA)) + "! Não é possível vincular 2 ou mais Fornecedores na mesma Empresa-Filial"  )
			lRet := .T.
		EndIf
	EndIf

	(cA2Alias)->(DbCLoseArea())

return lRet
*/


/*/{Protheus.doc} AJustSX1

Perguntas/parametros para impressao

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/ 
Static function SetaVlrDefault(cPerg)
	Local lTemCliOrig := PosCliOrigem()
	dbSelectArea("SX1")
	dbsetOrder(1)
	dbSeek(cPerg)

	While AllTrim(SX1->(FIELDGET(FIELDPOS("X1_GRUPO")))) == cPerg //hfp

		If AllTrim(SX1->(FIELDGET(FIELDPOS("X1_PERGUNT")))) == "Prefixo ?"
			reclock('SX1',.F.)
			SX1->(FIELDGET(FIELDPOS("X1_CNT01")))  := cPrefMutuo
			MsUnLock()
		EndIf



		/*
		If lTemCliOrig
	
			If AllTrim(SX1->X1_PERGUNT== "Bco Origem ?"
			reclock('SX1',.F.)
			SX1->(FIELDGET(FIELDPOS("X1_CNT01")))  := SA1->A1_XMBC
			MsUnLock()
			EndIf
		
			If AllTrim(SX1->X1_PERGUNT == "Agenc. Origem ?"
			reclock('SX1',.F.)
			SX1->(FIELDGET(FIELDPOS("X1_CNT01")))  := SA1->A1_XMAG
			MsUnLock()
			EndIf
		
			If AllTrim(SX1->== "Conta Origem ?"
			reclock('SX1',.F.)
			SX1->(FIELDGET(FIELDPOS("X1_CNT01")))  := SA1->A1_XMCN
			MsUnLock()
			EndIf
		
			If AllTrim(SX1->X1_PERGUNT== "Cliente ?"
			reclock('SX1',.F.)
			SX1->(FIELDGET(FIELDPOS("X1_CNT01")))  := SA1->A1_COD
			MsUnLock()
			EndIf
		
			If AllTrim(SX1->X1_PERGUNT == "Loja. ?"
			reclock('SX1',.F.)
			SX1->(FIELDGET(FIELDPOS("X1_CNT01")))  := SA1->A1_LOJA
			MsUnLock()
			EndIf
		
			If AllTrim(SX1->X1_PERGUNT== "Nome. ?"
			reclock('SX1',.F.)
			SX1->(FIELDGET(FIELDPOS("X1_CNT01")))  := SA1->A1_NREDUZ
			MsUnLock()
			EndIf
		EndIf*/
	
	
	
	SX1->(DbSkip())
	End
   
return

/*/{Protheus.doc} PosCliOrigem

Perguntas/parametros para impressao

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/ 

Static Function PosCliOrigem()
	Local cA1Alias := GetNextAlias()
	Local lRet     := .F.
	BeginSql Alias cA1Alias

SELECT SA1.* 
       
       FROM %table:SA1% SA1
       WHERE SA1.A1_FILIAL     = %xFilial:SA1%  
             AND SA1.%NotDel%                             
       		 AND  SA1.A1_XM0FIL = %Exp:(SM0->M0_CODFIL)%  
       		 			 
	EndSql

	If (cA1Alias)->(!Eof())
		If  AllTrim((cA1Alias)->(A1_XM0FIL)) == AllTrim(SM0->M0_CODFIL)
			DBSelectArea('SA1')
			SA1->( DBGoTo( (cA1Alias)->(R_E_C_N_O_) ) )

			lRet := .T.
		EndIf
	EndIf

	(cA1Alias)->(DbCLoseArea())

return lRet

/*
ALFIN5
Evita INCLUIR MANUOAMENTE TITULO DE PREFIXO IGUAL AO DO MUTUO
@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFIN5 (lSE1)
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local lRet := .T.



	If !IsInCallStack("U_ALFINP01")

		If lSE1
			If AllTrim(M->E1_PREFIXO) == AllTrim(cPrefMutuo)
				lRet := .F.
				Alert ("Não é permitido incluir manualmente títulos com o Prefixo utilizado pela rotina de Mútuos")

			EndIf
		Else
			If AllTrim(M->E2_PREFIXO) == AllTrim(cPrefMutuo)
				lRet := .F.
				Alert ("Não é permitido incluir manualmente títulos com o Prefixo utilizado pela rotina de Mútuos")

			EndIf
		EndIf
	ENdIf
return lRet


/*
ALFINT
POnto de entrada do Antonio para Evita buscar novo campo de conta contabil - ESTA CUSTOMIZACAO NAO SE REFERE AO MUTUO, APENAS APROVEITAMOS O MESMO FONTES PARA DEIXAR NELE A FUNCAO
@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFINT ()
	Local cSC6ALias := GetNextAlias()
	Local cSD2ALias := GetNextAlias()
//	Local aCampos   := {}

	If VerxCusto() <> '1'

		DbSelectArea('SD2')

		BeginSql Alias cSC6ALias
		SELECT SC6.C6_NUM, SC6.C6_ITEM, SC6.C6_CLI, SC6.C6_LOJA, SC6.C6_NOTA, SC6.C6_SERIE, SC6.C6_PRODUTO, SB1.B1_XCONTA2   FROM %table:SC6% SC6,  %table:SB1% SB1
		       WHERE              
		             SC6.C6_FILIAL     = %xFilial:SC6%
		             AND SC6.%NotDel%
		             AND SC6.C6_NUM     = %EXP:( SC5->C5_NUM       )%    
		             AND SC6.C6_CLI     = %EXP:( SC5->C5_CLIENTE    )%    
		             AND SC6.C6_LOJA    = %EXP:( SC5->C5_LOJACLI    )%
		             AND SC6.C6_NOTA <> ''
		             AND SB1.B1_FILIAL     = %xFilial:SB1%
		             AND SB1.%NotDel%
		             AND SC6.C6_PRODUTO     = SB1.B1_COD  
		             AND SB1.B1_XCONTA2 <> ''    
		EndSql


		While (cSC6Alias)->(!Eof()) .and. ;
				AllTrim((cSC6Alias)->(C6_NUM)) == AllTrim(SC5->C5_NUM)     .and. ;
				AllTrim((cSC6Alias)->(C6_CLI)) == AllTrim(SC5->C5_CLIENTE) .and. ;
				AllTrim((cSC6Alias)->(C6_LOJA)) == AllTrim(SC5->C5_LOJACLI) .and. ;
				!Empty ((cSC6Alias)->(C6_NOTA))


			BeginSql Alias cSD2ALias
			//SELECT SD2.*  FROM %table:SD2% SD2
			SELECT SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_PEDIDO, SD2.D2_ITEMPV, SD2.D2_COD, SD2.R_E_C_N_O_   FROM %table:SD2% SD2
			       WHERE              
			             SD2.D2_FILIAL     = %xFilial:SD2%
			             AND SD2.%NotDel%
			             AND SD2.D2_DOC     = %EXP:( (cSC6Alias)->(C6_NOTA)  )%
			             AND SD2.D2_SERIE   = %EXP:( (cSC6Alias)->(C6_SERIE) )%    
			             AND SD2.D2_CLIENTE = %EXP:( (cSC6Alias)->(C6_CLI)   )%    
			             AND SD2.D2_LOJA    = %EXP:( (cSC6Alias)->(C6_LOJA)  )%    
			             AND SD2.D2_COD     = %EXP:( (cSC6Alias)->(C6_PRODUTO))%    
			             AND SD2.D2_PEDIDO = %EXP:( (cSC6Alias)->(C6_NUM)   )%    
			             AND SD2.D2_ITEMPV = %EXP:( (cSC6Alias)->(C6_ITEM)   )%    
			EndSql

			While (cSD2Alias)->(!Eof()) .And.     ;
					AllTrim((cSD2Alias)->(D2_DOC)    ) == AllTrim((cSC6Alias)->(C6_NOTA))     .and. ;
					AllTrim((cSD2Alias)->(D2_SERIE)  ) == AllTrim((cSC6Alias)->(C6_SERIE))     .and. ;
					AllTrim((cSD2Alias)->(D2_CLIENTE)) == AllTrim((cSC6Alias)->(C6_CLI))     .and. ;
					AllTrim((cSD2Alias)->(D2_LOJA)   ) == AllTrim((cSC6Alias)->(C6_LOJA))     .and. ;
					AllTrim((cSD2Alias)->(D2_PEDIDO)   ) == AllTrim((cSC6Alias)->(C6_NUM))     .and. ;
					AllTrim((cSD2Alias)->(D2_ITEMPV)   ) == AllTrim((cSC6Alias)->(C6_ITEM))     .and. ;
					AllTrim((cSD2Alias)->(D2_COD)    ) == AllTrim((cSC6Alias)->(C6_PRODUTO))


				SD2->( DbGoto( (cSD2Alias)->(R_E_C_N_O_) ) )

				If SD2->(!Eof())

					reclock('SD2',.F.)
					SD2->D2_CONTA := (cSC6Alias)->(B1_XCONTA2)
					MsUNLock()
				EndIf

				(cSD2Alias)->(DbSkip())
			End

			(cSD2Alias)->(DbCloseArea())

			(cSC6Alias)->(DbSkip())
		End

		(cSC6Alias)->(dbclosearea())
	EndIf

return

/*
ALFING
POnto de entrada do Glauton para Evita INCLUIR TITULO SEM C.CUSTOS
@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFING ()
	Local lRet := .T.


	If !IsInCallStack("U_ALFINP01")

		If (lF050Auto .And. Alltrim(M->E2_ORIGEM) == "FINA050")  .or. (!lF050Auto .And.  IsInCallStack("FINA750")) .or. (!lF050Auto .And. IsInCallStack("FINA050"))

			//Ponto de entrada para validação de CCD vazio na inclusao
			If Empty(Alltrim(M->E2_CCUSTO))//CCD))
				Alert( "Atenção!! A Informação de Centro de Custo é Obrigatória!" )
				lRet := .F.
			EndIf
		EndIf

	ENdIf

return lRet

/*
ALFIN6
Exclui título do COntas a pagar gerado na Destino
@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFIN6ExclCP (lSE1)
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cOldFil := cFilAnt
	Local cArqErrAuto := ''
	Local cErrAuto := ''
	Local lRet := .T.
	Local lSim := .F.
	LOcal aArea := GetARea()
	LOcal aAreaSE1 := GetARea('SE1')
	Private lMsErroAuto := .F.
	Private aItens := {}

	If lSE1
		If AllTrim(SE1->E1_PREFIXO) == AllTrim(cPrefMutuo) .And. !Empty(SE1->E1_XMNUM)

			If ClicouOK()//o PE FA040DEL não nos permite identificar se o cara clicou no excluir e depois no OK .... ou se clicou no excluir e depois no CANCELAR(abortando a operacao)
				//portanto esta é a forma que encontramos para ver se o cara excluir mesmo o titulo ou nao (ou seja, clicou em cancelar)
				//ja no FA050DEL o ´roprio padrao ja trata isto para nós
				cFilAnt := SE1->E1_XMFIL

				If PosSe2()

					If SE2->E2_SALDO = SE2->E2_VALOR

						// exclui titulo destino	=============================================================
						aItens := {}
						aItens := { 	        { "E2_FILIAL"	, Fwxfilial('SE2')		      						   , NIL, },;
							{ "E2_PREFIXO"	, padr(SE2->E2_PREFIXO,TamSX3("E2_PREFIXO")[1])	       , NIL, },;
							{ "E2_NUM"		, padr(SE2->E2_NUM,TamSX3("E2_NUM")[1])	  			   , NIL, },;
							{ "E2_PARCELA"	, SE2->E2_PARCELA 			               				, NIL, },;
							{ "E2_TIPO"		, padr(SE2->E2_TIPO,TamSX3("E2_TIPO")[1])			   , NIL, },;
							{ "E2_NATUREZ"	, padr(SE2->E2_NATUREZ,TamSX3("E2_NATUREZ")[1])   	    , NIL ,},;
							{ "E2_FORNECE"	, padr(SE2->E2_FORNECE,TamSX3("E2_FORNECE")[1]) 		, NIL, },;
							{ "E2_LOJA"		, padr(SE2->E2_LOJA,TamSX3("E2_LOJA")[1])   			, NIL, },;
							{ "E2_EMISSAO"	, SE2->E2_EMISSAO			    						 , NIL, },;
							{ "E2_VENCTO"	, SE2->E2_VENCTO 			    					   , NIL, },;
							{ "E2_VENCREA"	, SE2->E2_VENCREA   						           , NIL ,},;
							{ "E2_VALOR"	, SE2->E2_VALOR	            					       , NIL ,},;
							{ "E2_PORTADO"	, padr(SE2->E2_PORTADO,TamSX3("E2_PORTADO")[1])           , NIL ,},;
							{ "E2_MOEDA"	, SE2->E2_MOEDA          								   , NIL ,} }


						aEval(aItens ,{|x| x[4] := Posicione("SX3", 2, x[1], "X3_ORDEM") })
						aItens := aSort(aItens,,,{|x,y| x[4] < y[4]})

						lMsErroAuto := .F.

						//MsExecAuto( { |x,y| FINA050(x,y)}, aItens, 5)//<-- EXCLUI O TITULO NA DESTINO
						MSExecAuto({|x, y, z| FINA050(x, y, z)}, aItens, 5, 5)


						If lMsErroAuto
							cArqErrAuto := NomeAutoLog()
							cErrAuto    := Memoread(cArqErrAuto)

							Alert ("Erro ao Efetuar a exclusão do título de Mútuo do Contas a Pagar (" + AllTrim(SE1->E1_XMFIL) + ")" + Chr(13)+ Chr(10) + Alltrim(cErrAuto))
							Ferase(cArqErrAuto)
							lRet := .F.

						Else
							If !IsInCallStack("ExcluiTodasParcelas")
								Alert ("Excluído o Título correspondente no Contas a Pagar da Empresa-Filial Destino (" + AllTrim(SE1->E1_XMFIL) + ")" )
							EndIf

							lRet := .T.
						EndIf

						//========================================================================================
					EndIf
				EndIf

				cFilAnt := cOldFil

				lSim := .F.
				If !IsInCallStack("ExcluiTodasParcelas")
					lSim := MsgNoYes( "Deseja excluir TODAS as demais parcelas deste título ? Obs.: serão excluídas apenas parcelas para as quais não haja baixa na Empresa-filial Destino."  + "Confirma a ação [Sim p/Todos] ?" )
				EndIf

				If lSim
					ExcluiTodasParcelas()
				EndIf
			EndIf

		EndIf
	Else

		If !IsInCallStack("U_FA040DEL")
			If AllTrim(SE2->E2_PREFIXO) == AllTrim(cPrefMutuo) .And. !Empty(SE2->E2_XMNUM)
				lRet := .F.
				Alert ("Não é permitido a exclusão manual do Título de Mútuo diretamente pelo Contas a Pagar! A exclusão deste ocorrerá automaticamente apenas após excluirmos o título (do Contas a Receber) na Empresa-FIlial de Origem")
			EndIf

		ENdIf
	ENdIf

	restarea(aArea)
	restarea(aAreaSE1)

return  lRet

/*
ALFIN4
Evita fazer qualquer tipo de operação manual com titulo de Mutuo
@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFIN4 ()
	Local lRet := .T.
	Local cOldFil := cFilAnt

	If !IsInCallStack("U_ALFINP01")
		If !IsInCallStack("FA040Inclu")

			If IsInCallStack("Fa040Delet")
				If !Empty(SE1->E1_XMFIL)
					cFilAnt := SE1->E1_XMFIL

					If PosSe2()
						If SE2->E2_SALDO <> SE2->E2_VALOR
							cFilAnt := cOldFil
							Alert ("Não é possível efetuar a exclusão pois o Título do Mútuo na Empresa-Filial Destino(" + AllTrim(SE1->E1_XMFIL) + ")  já sofreu Baixa!")
							lRet := .F.
						EndIf
					Else
						lRet := .F.
					EndIf

					cFilAnt := cOldFil
				EndIf
			Else
				Alert ("Não é possível efetuar esta operação com Títulos do Mútuo!")
				lRet := .F.
			EndIf

		EndIf
	EndIf

return lRet

/*
ALFIN3
Faz baixa do contas a receber correspondente
@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFIN3BaixaCancelaCROrigem (lBaixa)

	Local aCabItem      := {}
	Local cPrefMutuo    := SuperGetMV("ES_PRMU",, '')
	Local lRet          := .F.
	Local cOldFil       := cFilAnt
	Local cArqErrAuto   := ""
	Local cErrAuto      := ""
	Local cFazEmpr      := ""
//	Local cFazFil       := ""
	Local cUpdDel       := ""
	Local lEvitaErrFA100BCO := .F.
	Private lMsErroAuto := .F.



//6 é exclusao da baixa e 5 cancelamento
	If  AllTrim(SE2->E2_PREFIXO) == AllTrim(cPrefMutuo)

		cFilAnt := SE2->E2_XMFIL

		If PosSe1()

			cFilAnt := cOldFil

			DbSelectArea("SA6")
			DbSetOrder(1)
			DbSeek( xFilial("SA6") + SE1->E1_XMBC + SE1->E1_XMAG + SE1->E1_XMCN)//SE1->E1_XMBC + SE1->E1_XMAG + SE1->E1_XMCN,.T.)

			If  !(  SA6->(!Eof()) .And. AllTrim(SE1->E1_XMBC) == AllTrim(SA6->A6_COD) .And. AllTrim(SE1->E1_XMAG) == AllTrim(SA6->A6_agencia)  .And.  AllTrim(SE1->E1_XMCN) == AllTrim(SA6->A6_numcon))

				reclock('SA6',.T.)
				SA6->A6_FILIAL  := xFilial("SA6")
				SA6->A6_COD     := SE1->E1_XMBC
				SA6->A6_AGENCIA := SE1->E1_XMAG
				SA6->A6_numcon  := SE1->E1_XMCN
				MsUnLock()
				lEvitaErrFA100BCO := .T.

			EndIf

			cFilAnt := SE2->E2_XMFIL

			//cfilant := coldfil

			DbSelectArea("SA6")
			DbSetOrder(1)
			DbSeek( xFilial("SA6") + SE1->E1_XMBC + SE1->E1_XMAG + SE1->E1_XMCN)//SE1->E1_XMBC + SE1->E1_XMAG + SE1->E1_XMCN,.T.)

			aAdd( aCabItem , {"AUTMOTBX"	,"NOR"     	       , NIL})

			// SE1->E1_XMBC contem o banco vnculado ao cliente origem no ato da geracao do titulo no CR. Ou seja, trata-se do banco com o qual efetuaremos a baixa no CR origem
			aAdd( aCabItem , {"AUTBANCO"	,SA6->A6_COD	        , NIL})//SE1->E1_PORTADO
			aAdd( aCabItem , {"AUTAGENCIA"	,SA6->A6_agencia 	, NIL})//SE1->E1_AGEDEP
			aAdd( aCabItem , {"AUTCONTA"	,SA6->A6_numcon  , NIL})//SE1->E1_CONTA

			If lBaixa
				//alert ('vai baixar: ' + SE1->E1_NUM + " filial " + SE1->E1_FILIAL + " pref " + SE1->E1_PREFIXO)

				aAdd( aCabItem , {"AUTDTBAIXA"	,dBaixa 	, NIL})
				aAdd( aCabItem , {"AUTCHEQUE"	,Space(1)  	, NIL})
				aAdd( aCabItem , {"AUTDTCREDITO",dBaixa 	, NIL})

				aAdd( aCabItem , {"AUTVALREC"	,nValPgto	, NIL})
				aAdd( aCabItem , {"AUTMULTA"	,nMulta		, NIL})//0

				aAdd( aCabItem , {"AUTDESCONT"	, nDescont	, NIL})//(E1_VALOR - (nAutValRec - nJuros)  - nDescontos) + nDescontos
				aAdd( aCabItem , {"E1_FILIAL"	,SE1->E1_FILIAL , NIL})

				aAdd( aCabItem , {"E1_PREFIXO"	,SE1->E1_PREFIXO , NIL})
				aAdd( aCabItem , {"E1_NUM"		,SE1->E1_NUM     , NIL})
				aAdd( aCabItem , {"E1_TIPO"		,SE1->E1_TIPO    , NIL})
				aAdd( aCabItem , {"E1_PARCELA"	,SE1->E1_PARCELA , NIL})
				aAdd( aCabItem , {"E1_CLIENTE"	,SE1->E1_CLIENTE	, NIL})
				aAdd( aCabItem , {"E1_LOJA"		,SE1->E1_LOJA   	, NIL})

				MSExecAuto({|x,y| Fina070(x,y)},aCabItem,3)

			Else//entao é cancelamento de baixa

				aAdd( aCabItem , {"AUTCHEQUE"	,Space(1)  	, NIL})

				aAdd( aCabItem , {"E1_PREFIXO"	,SE1->E1_PREFIXO , NIL})
				aAdd( aCabItem , {"E1_NUM"		,SE1->E1_NUM     , NIL})
				aAdd( aCabItem , {"E1_TIPO"		,SE1->E1_TIPO    , NIL})
				aAdd( aCabItem , {"E1_PARCELA"	,SE1->E1_PARCELA , NIL})
				aAdd( aCabItem , {"E1_CLIENTE"	,SE1->E1_CLIENTE	, NIL})
				aAdd( aCabItem , {"E1_LOJA"		,SE1->E1_LOJA   	, NIL})

				MSExecAuto({|x,y| Fina070(x,y)},aCabItem,5)
			EndIf

			If lMsErroAuto
				cArqErrAuto := NomeAutoLog()
				cErrAuto    := Memoread(cArqErrAuto)

				If lBaixa
					Alert ("Erro ao Efetuar a Baixa do título de Mútuo do Contas a Receber da Empresa Filial (" + AllTrim(SE2->E2_XMFIL) + ")" + Chr(13)+ Chr(10) + Alltrim(cErrAuto))
				Else
					Alert ("Erro ao Efetuar o cancelamento da Baixa do título de Mútuo do Contas a Receber da Empresa Filial (" + AllTrim(SE2->E2_XMFIL) + ")" + Chr(13)+ Chr(10) + Alltrim(cErrAuto))
				EndIf

				Ferase(cArqErrAuto)
			else
				If lBaixa
					Alert ("Realizada a Baixa do título de Mútuo do Contas a Receber da Empresa Filial (" + AllTrim(SE2->E2_XMFIL) + ")" )
				Else
					Alert ("Realizado o cancelamento da Baixa do título de Mútuo do Contas a Receber da Empresa Filial (" + AllTrim(SE2->E2_XMFIL) + ")" )
				EndIf
			ENDIF

		EndIf

		cFilAnt := cOldFil

		If lEvitaErrFA100BCO
			DbSelectArea("SA6")
			DbSetOrder(1)
			DbSeek( xFilial("SA6") + SE1->E1_XMBC + SE1->E1_XMAG + SE1->E1_XMCN)//SE1->E1_XMBC + SE1->E1_XMAG + SE1->E1_XMCN,.T.)

			If  (  SA6->(!Eof()) .And. AllTrim(SE1->E1_XMBC) == AllTrim(SA6->A6_COD) .And. AllTrim(SE1->E1_XMAG) == AllTrim(SA6->A6_agencia)  .And.  AllTrim(SE1->E1_XMCN) == AllTrim(SA6->A6_numcon))

				cUpdDel := "DELETE FROM " + RetSqlName("SA6")
				cUpdDel += " WHERE A6_FILIAL = '"+ XFilial("SA6") +"'  "
				cUpdDel += "AND A6_COD = '"     +  SE1->E1_XMBC  + "'  "
				cUpdDel += "AND A6_AGENCIA = '" + SE1->E1_XMAG   + "'  "
				cUpdDel += "AND A6_NUMCON = '"  +  SE1->E1_XMCN  + "'  "

				TCSqlExec(cUpdDel)

			EndIf

		EndIf

	EndIf

	lRet := lMsErroAuto

return lRet

//-----------------------------------------------------------------------------------------------
//seta vcto em dia útil
Static Function VencReal (dData)

	if dow(dData) == 1//Domingo
		dData += 1
	endif

	if dow(dData) == 7//Sábado
		dData += 2
	endif

return dData


/*
PosSE1
Procuras titulo orgem do mutuo

@author 
@since 09/12/2014
@version 1.0
*/

Static Function PosSE1()
	Local cE1Alias := GetNextAlias()
	Local lRet     := .F.

	BeginSql Alias cE1Alias

SELECT SE1.*
       
       FROM %table:SE1% SE1
       WHERE SE1.E1_FILIAL     = %xFilial:SE1%  
             AND SE1.%NotDel%
             AND SE1.E1_NUM     = %Exp:(SE2->E2_XMNUM)%                               
       		 AND SE1.E1_PREFIXO = %Exp:(SE2->E2_XMPRF)%                               
       		 AND SE1.E1_TIPO    = %Exp:(SE2->E2_XMTIP)%                               
       		 AND SE1.E1_PARCELA = %Exp:(SE2->E2_XMPAR)%                               
       		 AND SE1.E1_CLIENTE = %Exp:(SE2->E2_XMCLI)%                               
       		 AND SE1.E1_LOJA    = %Exp:(SE2->E2_XMLOJ)%                               
       		 			 
	EndSql

	If (cE1Alias)->(!Eof())
		If  AllTrim( (cE1Alias)->(E1_NUM)     ) == AllTrim(SE2->E2_XMNUM) .And. ;
				AllTrim( (cE1Alias)->(E1_PREFIXO) ) == AllTrim(SE2->E2_XMPRF) .And. ;
				AllTrim( (cE1Alias)->(E1_TIPO)    ) == AllTrim(SE2->E2_XMTIP) .And. ;
				AllTrim( (cE1Alias)->(E1_PARCELA) ) == AllTrim(SE2->E2_XMPAR) .And. ;
				AllTrim( (cE1Alias)->(E1_CLIENTE) ) == AllTrim(SE2->E2_XMCLI) .And. ;
				AllTrim( (cE1Alias)->(E1_LOJA   ) ) == AllTrim(SE2->E2_XMLOJ)

			lRet := .T.
			DbSelectArea('SE1')
			DbSetOrder(1)
			SE1->(DbGoTo(  (cE1Alias)->(R_E_C_N_O_) ))
		Else
			Alert ('Atenção: Título Origem do Mútuo não localizado no Contas a Receber(' + cFIlAnt + ')! Desfaça a operação do Contas a Pagar e verifique a situação de seu título origem' )
		EndIf
	EndIf

	(cE1Alias)->(DbCLoseArea())

return lRet


/*
PosSE2
Procuras titulo orgem do mutuo

@author 
@since 09/12/2014
@version 1.0
*/

Static Function PosSE2()
	Local cE2Alias := GetNextAlias()
	Local lRet     := .F.


	BeginSql Alias cE2Alias

SELECT SE2.*
       
       FROM %table:SE2% SE2
       WHERE SE2.E2_FILIAL     = %xFilial:SE2%  
             AND SE2.%NotDel%
             AND SE2.E2_NUM     = %Exp:(SE1->E1_XMNUM)%                               
       		 AND SE2.E2_PREFIXO = %Exp:(SE1->E1_XMPRF)%                               
       		 AND SE2.E2_TIPO    = %Exp:(SE1->E1_XMTIP)%                               
       		 AND SE2.E2_PARCELA = %Exp:(SE1->E1_XMPAR)%                               
       		 AND SE2.E2_FORNECE = %Exp:(SE1->E1_XMFOR)%                               
       		 AND SE2.E2_LOJA    = %Exp:(SE1->E1_XMLOJ)%                               
       		 			 
	EndSql

	If (cE2Alias)->(!Eof())
		If  AllTrim( (cE2Alias)->(E2_NUM)     ) == AllTrim(SE1->E1_XMNUM) .And. ;
				AllTrim( (cE2Alias)->(E2_PREFIXO) ) == AllTrim(SE1->E1_XMPRF) .And. ;
				AllTrim( (cE2Alias)->(E2_TIPO)    ) == AllTrim(SE1->E1_XMTIP) .And. ;
				AllTrim( (cE2Alias)->(E2_PARCELA) ) == AllTrim(SE1->E1_XMPAR) .And. ;
				AllTrim( (cE2Alias)->(E2_FORNECE) ) == AllTrim(SE1->E1_XMFOR) .And. ;
				AllTrim( (cE2Alias)->(E2_LOJA   ) ) == AllTrim(SE1->E1_XMLOJ)

			lRet := .T.
			DbSelectArea('SE2')
			DbSetOrder(1)
			SE2->(DbGoTo(  (cE2Alias)->(R_E_C_N_O_) ))
		Else
			Alert ('Atenção: O Título Destino do Mútuo(Contas a Pagar) não fora localizado na filial Destino(' + AllTrim(cFilAnt) + ")!"  )
		EndIf
	EndIf

	(cE2Alias)->(DbCLoseArea())

return lRet

/*
ExcluiTodasParcelas
exclui todas as parcelas do referido titulo CR ...e excluiu tb no destino(CP), desde que este nao contenha alguma baixa

@author 
@since 09/12/2014
@version 1.0
*/
Static function ExcluiTodasParcelas()
	Local cE1Alias := GetNextAlias()
	Local cNum     := SE1->E1_NUM
	Local cPref    := SE1->E1_PREFIXO
	Local cTip     := SE1->E1_TIPO
	Local cCli     := SE1->E1_CLIENTE
	Local cLoja    := SE1->E1_LOJA
	Local cArqErrAuto := ''
	BeginSql Alias cE1Alias
		
	SELECT SE1.*
		       
	       FROM %table:SE1% SE1
	       WHERE SE1.%NotDel%
	             AND SE1.E1_FILIAL  = %Exp:(Fwxfilial('SE1'))%
	             AND SE1.E1_CLIENTE = %Exp:(cCli)%
	             AND SE1.E1_LOJA    = %Exp:(cLOja)%
	             AND SE1.E1_NUM     = %Exp:(cNum)%
	             AND SE1.E1_PREFIXO = %Exp:(cPref)%
	             AND SE1.E1_TIPO    = %Exp:(cTip)%
		                                            
	EndSql

	While (cE1Alias)->(!Eof()) .And. ;
			AllTrim( (cE1Alias)->(E1_CLIENTE)  ) == AllTrim(cCli) .ANd. ;
			AllTrim( (cE1Alias)->(E1_LOJA)  )    == AllTrim(cLoja) .ANd. ;
			AllTrim( (cE1Alias)->(E1_NUM)  )  == AllTrim(cNum) .ANd. ;
			AllTrim( (cE1Alias)->(E1_PREFIXO)  ) == AllTrim(cPref) .ANd. ;
			AllTrim( (cE1Alias)->(E1_TIPO)  )    == AllTrim(cTip)

		DbSelectArea('SE1')
		SE1->(DbGoTo(  (cE1Alias)->(R_E_C_N_O_)   ))

		If SE1->(!Eof())

			aItens := {}
			aItens := {    { "E1_FILIAL"	, Fwxfilial('SE1')	   	    , NIL, },;
				{ "E1_PREFIXO"	, SE1->E1_PREFIXO			, NIL, },;
				{ "E1_NUM"		, SE1->E1_NUM		    	, NIL, },;
				{ "E1_PARCELA"	, SE1->E1_PARCELA			, NIL, },;
				{ "E1_TIPO"		, SE1->E1_TIPO				, NIL, },;
				{ "E1_NATUREZ"	, SE1->E1_NATUREZ			, NIL, },;
				{ "E1_CLIENTE"	, SE1->E1_CLIENTE 			, NIL, },;
				{ "E1_LOJA"		, SE1->E1_LOJA				, NIL, },;
				{ "E1_VALOR"	, SE1->E1_VALOR	             , NIL, }  }

			aEval(aItens ,{|x| x[4] := Posicione("SX3", 2, x[1], "X3_ORDEM") })
			aItens := aSort(aItens,,,{|x,y| x[4] < y[4]})

			lMsErroAuto := .F.
			SetFunName("FINA040")
			IncProc("Processando exclusao demais parcelas - FINA040")

			MsExecAuto( { |x,y| FINA040(x,y)}, aItens, 5)//<-- inclui manualmente todas as parcelas do titulo fatura

			If lMsErroAuto
				cArqErrAuto := NomeAutoLog()
				MostraErros()
				Ferase(cArqErrAuto)
				exit
			EndIf

		EndIf

		(cE1Alias)->(DbSkip())
	End

	(cE1Alias)->(DbCloseArea())

return



/*
ALFI01
Invocada via PE F070OWN

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI01   ()

	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cFiltro := 'E1_FILIAL=="' + xFilial("SE1") + '".And.   E1_PREFIXO <> "'  + cPrefMutuo + '"  .ANd. '

	cFiltro += 'DTOS(E1_VENCREA)>="' + DTOS(dVencDe)  + '".And.'
	cFiltro += 'DTOS(E1_VENCREA)<="' + DTOS(dVencAte) + '".And.'
	cFiltro += 'E1_NATUREZ>="'       + cNatDe         + '".And.'
	cFiltro += 'E1_NATUREZ<="'       + cNatAte        + '".And.'
	cFiltro += '(E1_PORTADO="'       + cBancolt         + '".OR.'
	cFiltro += 'E1_PORTADO=="'+ space(Len(E1_PORTADO)) + '").AND.'
	cFiltro += '!(E1_TIPO$"'+MVPROVIS+"/"+MVRECANT+"/"+MVIRABT+"/"+MVINABT+"/"+MV_CRNEG

//Destacar Abatimentos
	If mv_par06 == 2
		cFiltro += "/"+MVABATIM+"/"+MVFUABT +'")'//adicionado MVFUABT pois a variável MVABATIM não está retornando FU-
	Else
		cFiltro += '")'
	Endif

// Verifica integracao com TMS e nao permite baixar titulos que tenham solicitacoes
// de transferencias em aberto.
	cFiltro += ' .And. Empty(E1_NUMSOL)'
	cFiltro += ' .And. (E1_SALDO>0 .OR. E1_OK="xx")'

return cFiltro


/*
ALFI02
Invocada via PE F080FIL

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI02   ()
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cRet := '  E2_PREFIXO <> "' + cPrefMutuo + '"  '

return cRet

/*
ALFI03
Invocada via PE  F090FIL

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI03 ()
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cRet  := " E2_PREFIXO <>'" + cPrefMutuo + "'"

return cRet

/*
ALFI04
Invocada via PE   F240FPGT

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI04  ()
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cRet  := "  E2_PREFIXO <>'" + cPrefMutuo + "'  AND "

return cRet

/*
ALFI05
Invocada via PE F290FIL

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI05 ()
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cRet  := " E2_PREFIXO <>'" + cPrefMutuo + "'"

return cRet

/*
ALFI06
Invocada via PE   F300VALID

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI06 ()
	Local lRet := .T.
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')

	If Alltrim(SE1->E1_PREFIXO) == AllTrim(cPrefMutuo)
		lRet := .F.
		Alert ("Operação não permitida para Títulos do Mútuo!")
	EndIf

return  lRet

/*
ALFI07
Invocada via PE  F340FCPTOP

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI07 (cStr)
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cRet := strtran(cStr,"ORDER", " AND E2_PREFIXO <> '" + cPrefMutuo + "' ORDER  " ,1,1)

return cRet

/*
ALFI08
Invocada via PE     F340VALID

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI08  ()
	Local lRet 		   := .T.
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')


	If Alltrim(SE2->E2_PREFIXO) == AllTrim(cPrefMutuo)
		lRet := .F.
		Alert ("Operação não permitida para Títulos do Mútuo!")
	EndIf

return lRet

/*
ALFI09
Invocada via PE   F390FIL

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI09  ()
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cRet  := " E2_PREFIXO <>'" + cPrefMutuo + "'"

return cRet

/*
ALFI10
Invocada via PE F050ALT

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI10 ()
	Local lRet  := .T.
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')

	If AllTrim(SE2->E2_PREFIXO) == AllTrim(cPrefMutuo)
		lRet := .F.
		ALert ("Não é possível alterar títulos orginados pelo Mútuo.")
	EndIf


return lRet

/*
ALFI10
Invocada via PE FA070CA3

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI11 ()
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local lRet := .T.

	If AllTrim(SE1->E1_PREFIXO) == AllTrim(cPrefMutuo)
		If !IsInCallStack("U_ALFIN3BaixaCancelaCROrigem") //se o PE não fora disparado pela rotina do proprio mutuo ...e sim invocado manulamente
			lRet := .F.
			Alert ("Não é permitido efetuar esta operação para Título de Mútuo. O sistema realizará estas operações automaticamente quando efetuarmos manutenção do Título do Contas a pagar(na Empresa-Filial destino)")
		EndIf
	EndIf

return lRet



/*
ALFI12
Invocada via PE FA070CHK

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI12 ()
	Local lRet  := .T.
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')

	If AllTrim(SE1->E1_PREFIXO) == AllTrim(cPrefMutuo)
		If !IsInCallStack("U_ALFIN3BaixaCancelaCROrigem") //se o PE não fora disparado pela rotina do proprio mutuo ...e sim invocado manulamente
			lRet := .F.
			Alert ("Não é permitido efetuar esta operação para Título de Mútuo. O sistema realizará estas operações automaticamente quando efetuarmos manutenção do Título do Contas a pagar(na Empresa-Filial destino)")
		EndIf
	EndIF

return lRet


/*
ALFI13
Invocada via PE   FA080OWN

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI13 (nOper)
	Local lRet       := .T.
	Local cPrefMutuo := SuperGetMV("ES_PRMU",, '')

//6 é exclusao da baixa e 5 cancelamento
	If nOper == 6 .And. AllTrim(SE2->E2_PREFIXO) == AllTrim(cPrefMutuo)
		lRet := .F.
		Alert ("Para títulos de Mútuo utilize a opção cancelar Baixa! ")
	EndIf

return lRet


/*
ALFI14
Invocada via PE  FA280QRY

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI14 ()
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cRet  := " E1_PREFIXO <> '" + cPrefMutuo + "'"
return  cRet


/*
ALFI15
Invocada via PE FA030QRY

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI15 (cStr)
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cRet  := strtran( cStr, "ORDER BY",  " AND SE1.E1_PREFIXO <>'" + cPrefMutuo + "' ORDER BY ",1,1)

return  cRet


/*
ALFI16
Invocada via PE  FA460FIL

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALFI16 ()

	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cRet  := " AND E1_PREFIXO <> '" + cPrefMutuo + "'"


return cRet

/*
IncMovBancario
inclui movimento de transferencia automaticamente

@author 
@since 09/12/2014
@version 1.0
*/

Static function IncMovBancario(lParaReceber, cNat, cValor)
	Local cChave := ''
	Local oModelMvR	:= FWLoadModel("FINM030")
	Local oSubFK5	:= oModelMvR:GetModel("FK5DETAIL")
	Local oSubFKA	:= oModelMvR:GetModel("FKADETAIL")
	Local cLog		  := ""
	Local cCamposE5	  := ""
	Local dDtCredito  := dDataBase
	Local cNum
	PRIVATE nMoedaBco := 1

	DbSelectArea("SA6")
	DbSetOrder(1)

	If lParaReceber
		DbSeek( xFilial("SA6") + MV_PAR09 + MV_PAR10 + MV_PAR11,.T.)
	Else
		DbSeek( xFilial("SA6") + MV_PAR15 + MV_PAR16 + MV_PAR17,.T.)
	EndIf

//se chegou ate este ponto certeza que regostro existe na tabela SA6, mesmo assim testamos
	If SA6->(!Eof())

		cCamposE5 += "{"
		cCamposE5 += "{'E5_DTDIGIT',StoD('" + DtoS(dDtCredito) + "')}"
		//cCamposE5 += ",{'E5_LOTE','" + cLoteFin + "'}"

		cCamposE5 += "}"

		//Inicializo os models
		oModelMvR:SetOperation(MODEL_OPERATION_INSERT) //Inclusao
		oModelMvR:Activate()
		oModelMvR:SetValue("MASTER","E5_GRV",.T.) //Informa se vai gravar SE5 ou não
		oModelMvR:SetValue("MASTER","E5_CAMPOS",cCamposE5) //Informa os campos da SE5 que serão gravados indepentes de FK5

		// oModelMvR:SetValue('MASTER','E5_IDMOVI', '11111')
		//                 oModelMvR:SetValue( "MASTER", "NOVOPROC", .T. )//<------------------------
		//cIdDoc	:= FINGRVFK7("SE1", "0101010202030")

		//baixa contas a receber
		If !oSubFKA:IsEmpty()
			//Inclui a quantidade de linhas necessárias
			oSubFKA:AddLine()
			//Vai para linha criada
			oSubFKA:GoLine( oSubFKA:Length() )
		Endif
		oSubFKA:SetValue( 'FKA_IDORIG', FWUUIDV4() )
		oSubFKA:SetValue( 'FKA_TABORI', 'FK5' )
		//E5_IDMOVI    E5_MODSPB


		oSubFK5:SetValue("FK5_FILIAL"	,xFilial() )
		oSubFK5:SetValue("FK5_BANCO"	,SA6->A6_COD )
		oSubFK5:SetValue("FK5_AGENCI"	,SA6->A6_AGENCIA )
		oSubFK5:SetValue("FK5_CONTA"	,SA6->A6_NUMCON )

		If lParaReceber
			oSubFK5:SetValue("FK5_RECPAG"	,'R' )//movto a receber
		Else
			oSubFK5:SetValue("FK5_RECPAG"	,'P' )//movto a pagar
		EndIf

		//oSubFK5:SetValue("FK5_HISTOR"	,STR0130 + cLoteFin )
		oSubFK5:SetValue("FK5_DATA"		,dDtCredito )
		oSubFK5:SetValue("FK5_TPDOC"	,'DH' )
		oSubFK5:SetValue("FK5_VALOR"	,cValor)
		oSubFK5:SetValue("FK5_NATURE"	,cNat )
		oSubFK5:SetValue("FK5_FILORI"	,cFilAnt )
		oSubFK5:SetValue("FK5_DTDISP"	,dDtCredito )
		oSubFK5:SetValue("FK5_ORIGEM"	,'FINA100' )

		//			oSubFK5:SetValue( "FK5_IDDOC" , cIdDoc )//<------------------------

		//	If lSpbInUse
		// Se houver retencao ModSpb = Comp, caso contrario, STR
		//	oSubFK5:SetValue("FK5_MODSPB"	,IIF(SE5->E5_DTDISPO > dDataBase,"3","1") )
		//Endif

		oSubFK5:SetValue("FK5_MOEDA"	,"M1"/*StrZero(nMoedaBco,2)*/ )
		oSubFK5:SetValue("FK5_LA"		,/*IIf((lContabiliza .And. lPadrao .And. lHdlPrv) .Or. nHdlPrv > 0,'S','')*/'' )

		If oModelMvR:VldData()

			oModelMvR:CommitData()
			oModelMvR:DeActivate()

			//-------------------------------------------------------------------------------------
			//ao final atualizamos informações que o execauto do MVC não estava tratando corretamente
			cNum := GetSXEnum('SE5','E5_IDMOVI')
			//	alert(cNum)
			ConfirmSX8()
			RECLOCK('SE5',.F.)
			SE5->E5_IDMOVI := cNum
			SE5->E5_MODSPB := '1'

			If lParaReceber == .F.
				SE5->E5_TPDESC := 'C'
			EndIf

			SE5->E5_VENCTO := dDtCredito
			cChave := SE5->E5_IDORIG
			MSUNLOCK()

			cFK5Alias := GetNextAlias()
			BeginSql Alias cFK5Alias
			
			SELECT FK5.*
			       
			       FROM %table:FK5% FK5
			       WHERE FK5.%NotDel%
			             AND FK5.FK5_FILIAL = %Exp:(fwxfilial('SE5'))%
			             AND FK5.FK5_IDMOV  = %Exp:(cChave)%
			                                            
			EndSql

			If (cFK5Alias)->(!Eof())
				If  AllTrim((cFK5Alias)->(FK5_IDMOV)) == AllTrim(cChave)
					DbSelectArea('FK5')
					FK5->( dbgoto((cFK5Alias)->(R_E_C_N_O_)) )


					Reclock('FK5',.F.)
					FK5->FK5_MODSPB := '1'
					MsUnLock()
				EndIf
			EndIf

			(cFK5Alias)->(DbCLoseArea())
			//-------------------------------------------------------------------------------------------------------


		Else
			cLog := cValToChar(oModelMvR:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModelMvR:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModelMvR:GetErrorMessage()[6])

			Help( ,,"M030VLDA1",,cLog, 1, 0 )
		Endif

		If lParaReceber
			AtuSalBco( SA6->A6_COD, SA6->A6_AGENCIA, SA6->A6_NUMCON, dDtCredito, cValor, "+" )
		Else
			AtuSalBco( SA6->A6_COD, SA6->A6_AGENCIA, SA6->A6_NUMCON, dDtCredito, cValor, "-" )
		EndIf

	EndIf

return







/*
FazMovBancario
Faz movimentos bancario de saida de dinheiro na origem - Pagamento
ou
Faz movimentos bancario de entrada de dinheiro na destino - Recebinento

@author 
@since 09/12/2014
@version 1.0
*/
Static Function FazMovBancario(lFazMovPagtoNaOrigem)
	Local   lRet        := .F.
	Local   aFina100    := {}
	Local   cTipoTran   := SuperGetMV('ES_TPMMU',.F.,'M1')
	Local   cArqErrAuto := ''
	Private lMsErroAuto := .F.

/*
Private cCRAgencia := '' 
Private cCRConta   := ''
Private cCRBanco   := ''
Private cCPAgencia := ''
Private cCPConta   := ''
Private cCPBanco   := ''
*/


//=====================================================================================================================
//
// Faz movimento de a pagar na origem - saindo o dinheiro
//
//=====================================================================================================================
	cNomeOri := AllTrim(Posicione('SA6',1,xFilial('SA6')+cCRBanco+cCRAgencia+cCRConta,'A6_NREDUZ'))

	AADD(aFina100 , {"CBCOORIG"   	, cCRBanco                           	, NIL}) //-- Banco Origem
	AADD(aFina100 , {"CAGENORIG"  	, cCRAgencia                         	, NIL}) //-- Agencia Origem
	AADD(aFina100 , {"CCTAORIG"    	, cCRConta                           	, NIL}) //-- Conta Origem
	AADD(aFina100 , {"CNATURORI"  	, cNatOrMutuo/*cNatDeMutuo*/                           	, NIL}) //-- Natureza Origem
	AADD(aFina100 , {"CTIPOTRAN"  	, cTipoTran                            	, NIL}) //-- Tipo Movimento
	AADD(aFina100 , {"CDOCTRAN"    	, cNomeOri                            	, NIL}) //-- Numero Documento
	AADD(aFina100 , {"NVALORTRAN"  	, MV_PAR04                           	, NIL}) //-- Valor da Transferencia
	AADD(aFina100 , {"CHIST100"    	, cHistCR  	, NIL}) //-- Historico

	lMsErroAuto := .F.

	MsExecAuto( {|x,y| FINA100(Nil,x,y)}, aFina100, 3)//3 a pagar     4 a receber

	If lMsErroAuto
		cArqErrAuto := NomeAutoLog()

		MostraErros()
		Ferase(cArqErrAuto)
		lRet := .F.
	Else
		lRet := .T.
	EndIf
//=====================================================================================================================


	If lRet
		aFina100    := Nil
		aFina100    := {}
		cArqErrAuto := ''
		lMsErroAuto := .F.

		//=====================================================================================================================
		//
		// Faz movimento de a receber na destino - entrando o dinheiro
		//
		//=====================================================================================================================
		cNomeOri := AllTrim(Posicione('SA6',1,xFilial('SA6')+cCRBanco+cCRAgencia+cCRConta,'A6_NREDUZ'))

		AADD(aFina100 , {"CBCOORIG"   	, cCPBanco                           	, NIL}) //-- Banco Origem
		AADD(aFina100 , {"CAGENORIG"  	, cCPAgencia                         	, NIL}) //-- Agencia Origem
		AADD(aFina100 , {"CCTAORIG"    	, cCPConta                           	, NIL}) //-- Conta Origem
		AADD(aFina100 , {"CNATURORI"  	, cNatDeMutuo                           	, NIL}) //-- Natureza Origem
		AADD(aFina100 , {"CTIPOTRAN"  	, cTipoTran                            	, NIL}) //-- Tipo Movimento
		AADD(aFina100 , {"CDOCTRAN"    	, cNomeOri                            	, NIL}) //-- Numero Documento
		AADD(aFina100 , {"NVALORTRAN"  	, MV_PAR04                           	, NIL}) //-- Valor da Transferencia
		AADD(aFina100 , {"CHIST100"    	, cHistCP  	, NIL}) //-- Historico

		lMsErroAuto := .F.

		MsExecAuto( {|x,y| FINA100(Nil,x,y)}, aFina100, 3)//3 a pagar     4 a receber

		If lMsErroAuto
			cArqErrAuto := NomeAutoLog()

			MostraErros()
			Ferase(cArqErrAuto)
			lRet := .F.
		Else
			lRet := .T.
		EndIf
		//=====================================================================================================================

	EndIf

return lRet



/*
ALGTBC
LOOKUP DE BANCOS DE ACORDO COM EMPRESA FILIAL DO FORNECEDOR

@author 
@since 09/12/2014
@version 1.0

User Function ALGTBC ()
Local aStrRec := {}
Local oBrowse 	:= Nil
Local lMarcar    := .F.

Local nCount     := 0
Local lAchou     := .F.   
Local cOldFil    := cFIlAnt
//Private aRotina :=Menudef()  <---nao usar no F3 de bancos do fornecedor
Private cTmpRec
Private cTempAlias := GetNextALias()
Private cSA6ALias  := GetNextAlias()
Private aCampos := {}
Private oMarkENd
Private lMantem    := .T.
Private oDlgMrk
Private oSize := {} 

//oSize := MsAdvSize() // Sera utilizado tres areas na janela 
oSize := FwDefSize():New()             
oSize:AddObject( "CABECALHO",  100, 100, .T., .T. ) // Totalmente dimensionavel
	
oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process() // Dispara os calculos 
	

DbSelectArea("SA2")
DbSetOrder(1)

	If PosFor(mv_par12, mv_par13)
		
		If !Empty(SA2->A2_XM0FIL)
					

	
		AADD( aStrRec, { "MARK"     , "C", 2 	, 0 })
		
		Aadd( aStrRec, {"TMP_FIL"	   ,"C",  TamSX3("A6_FILIAL") [1], 0 })
		Aadd( aStrRec, {"TMP_BCO"	       ,"C",  TamSX3("A6_COD")   [1], 0 })
		Aadd( aStrRec, {"TMP_AGEN"	   ,"C",  TamSX3("A6_AGENCIA")[1], 0 })
		Aadd( aStrRec, {"TMP_NUM"	   ,"C",  TamSX3("A6_NUMCON")[1], 0 })
		Aadd( aStrRec, {"TMP_NOME"   	   ,"C",  TamSX3("A6_NOME" )[1], 0 })
		
		//Cria arquivo temporario com os campos acima
		cTmpRec := CriaTrab( aStrRec , .T. )       
		
		DbUseArea(.T.,,cTmpRec,cTempAlias,.T.,.F.)   //arq temp deve estar aberta para poder dar insert
		
		cFilAnt := SA2->A2_XM0FIL
		
			BeginSql Alias cSA6Alias
		
		SELECT SA6.*      FROM %table:SA6% SA6       WHERE SA6.A6_FILIAL  = %xFilial:SA6%
		             AND SA6.%NotDel%              //AND SL1.L1_DOC    <> %Exp:(cBranco)%   //no loja não existe faturamento parcial do orçamento. Por isto, olhamos direto no cabeçalho
		ORDER BY A6_FILIAL, A6_COD
		  
			EndSql


			While (cSA6Alias)->(!Eof())
				lAchou     := .T.
				reclock(cTempAlias,.T.)
				(cTempAlias)->MARK    :=  ''
				(cTempAlias)->TMP_FIL    :=  (cSA6Alias)->A6_FILIAL
				(cTempAlias)->TMP_BCO       :=  (cSA6Alias)->A6_COD
				(cTempAlias)->TMP_AGEN   :=  (cSA6Alias)->A6_AGENCIA
				(cTempAlias)->TMP_NUM    :=  (cSA6Alias)->A6_NUMCON
				MsUnLock()

				(cSA6Alias)->(DbSkip())
			End

			(cSA6Alias)->(DbCLoseArea())

			cFilAnt := cOLdFil

			If lAchou  == .T.

				While lMantem

					(cTempAlias)->(DbGoTop())

					aCampos := {}
					AADD(aCampos,{ "Filial"        , {|| (cTempAlias)->(TMP_FIL) } , "C" , "@!"  	})
					AADD(aCampos,{ "Banco"        , {|| (cTempAlias)->(TMP_BCO) } , "C" , "@!"  	})
					AADD(aCampos,{ "Agência"        , {|| (cTempAlias)->(TMP_AGEN) } , "C" , "@!"  	})
					AADD(aCampos,{ "Conta"        , {|| (cTempAlias)->(TMP_NUM) } , "C" , "@!"  	})

					DEFINE MSDIALOG oDlgMrk TITLE OemToAnsi('Bancos') FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4]  PIXEL


					oMarkEnd:= FWMarkBrowse():New()

					oMArkEnd:SetOwner(oDlgMrk)
					//-- Definição da tabela a ser utilizada

					//FWMarkBrowse():SetMenuDef(< cMenuDef >)-
					//FWMarkBrowse():ForceQuitButton(< lSet >)-> NIL

					//oMark:bAllMark := { || SetMarkAll('IT',lMarcar := !lMarcar ), oMark:Refresh(.T.)  }


					oMarkEnd:SetAlias(cTempAlias)
					oMarkEnd:SetDescription('Bancos da empresa-filial: ' + AllTrim(SA2->A2_XM0FIL))
					//-- Define o campo que sera utilizado para a marcação
					oMarkEnd:SetFieldMark( 'MARK' )
					oMarkEnd:SetMark('IT', cTempAlias, 'MARK')
					//-- Define a marcacao de todos os registros
					oMarkEnd:ballMark := { || }//SetMarkAll('IT',lMarcar := !lMarcar ), oMarkEnd:Refresh(.T.)  }

					//-- Define os campos a serem apresentados no Browse
					oMarkEnd:SetFields(aCampos)

//				oMarkEnd:SetMenuDef("U_MENUDEF")//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

					//oMarkEnd:ForceQuitButton(.T.)
					oMarkEnd:Activate()

					oMarkEnd := Nil


					ACTIVATE MSDIALOG oDlgMrk CENTER ON INIT EnchoiceBar(oDlgMrk, {|| oDlgMrk:End() }, {|| oDlgMrk:End()}  ,,)

					(cTempAlias)->(DbGoTop())

					nCOunt := 0
					While (cTempAlias)->(!Eof())
						If !Empty((cTempAlias)->(MARK))
							cFilANt := SA2->A2_XM0FIL

							DbSelectArea("SA6")
							DbSetOrder(1)
							DbSeek( xFilial("SA6") + (cTempAlias)->(TMP_BCO) + (cTempAlias)->(TMP_AGEN) + (cTempAlias)->(TMP_NUM),.T.)

							cFilAnt := cOLdFil

							nCount += 1
							If nCOunt > 1
								exit
							EndIf
						ENdIf
						(cTempAlias)->(DbSkip())
					End

					If nCOunt > 1
						Alert ("Selecione um único banco !")
						Loop
					EndIf

					If nCOunt == 0
						Alert ("Selecione ao menos um banco!")
						Loop
					EndIf
					lMantem := .F.
					MV_PAR15 := SA6->A6_COD
					MV_PAR16 := SA6->A6_AGENCIA
					MV_PAR17 := SA6->A6_NUMCON

				ENd

			Else
				Alert ("Não existem registros na tabela de Bancos da empresa-filial: " + AllTrim(SA2->A2_XM0FIL))
			EndIf


			(cTempAlias)->(DbCLoseArea())
			fErase ( cTmpRec + GetDBExtension() )
		Else
			Alert ("Este Fornecedor não possui empresa-filial de Mútuo informada em seu cadastro. Portanto, não deve ser utilizado!")
		EndIf

	Else
		Alert('Informe um Fornecedor de Destino antes de utilizar esta funcionalidade!')
	EndIf

RETURN

*/




/*
CttDaFilial
Pegar c.custo padrao para ser utilizado no mutuo (campo customizado por outra equipe: CTT_XEMPFI)
@author 
@since 09/12/2014
@version 1.0
*/

Static Function CttDaFilial()

	Local cPsqAlias

	Dbselectarea('SE2')
	DbSetOrder(1)

	Dbselectarea('CTT')
	DbSetOrder(1)

	If CTT->(FieldPos("CTT_XEMPFI")) > 0 //.And.   SE2->(FieldPos("E2_XCNPJ")) > 0

		cPsqAlias := GetNextAlias()
		BeginSql Alias cPsqAlias
		
		SELECT CTT.*
		       FROM %table:CTT% CTT
		       WHERE CTT.%NotDel% AND
		       		 CTT.CTT_FILIAL     = %xFilial:CTT%  //cfilant ja esta posicionado de acordo neste ponto
		             AND CTT.CTT_XEMPFI   = %Exp:(cFilCgc)% 
		                                            
		EndSql

		If (cPsqAlias)->(!Eof())
			cCttFilial := (cPsqAlias)->(CTT_XEMPFI)
			cCttXCusto := (cPsqAlias)->(CTT_CUSTO)//conversei com ANtonio ele disse para nao usar CTT_XCUSTO
		EndIf

		(cPsqAlias)->(DbCLoseArea())
	EndIf

return

/*
ALGTBSA1
LOOKUP DE BANCOS DE ACORDO COM EMPRESA FILIAL DO CLIENTE

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALGTBSA1 ()
	Local aStrRec := {}
	Local oBrowse 	:= Nil
	Local lMarcar    := .F.
	Local nCount     := 0
	Local lAchou     := .F.
	Local cOldFil    := cFIlAnt
	Private aRotina := MenuDef() //<-- Somente qdo chamado o F3 de bancos pela "tela de clientes", foi preciso forjar um menu em branco para remover os botões de incluir e alterar que o sistema insistia em exibir
	Private cTmpRec
	Private cTempAlias := GetNextALias()
	Private cSA6ALias  := GetNextAlias()
	Private aCampos := {}
	Private oMarkENd
	Private oDlgMrk
	Private oSize
	Private lMantem    := .T.

	oSize := FwDefSize():New()
	oSize:AddObject( "CABECALHO",  100, 100, .T., .T. ) // Totalmente dimensionavel

	oSize:lProp 	:= .T. // Proporcional
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
	oSize:Process() // Dispara os calculos

	DbSelectArea("SA1")
	DbSetOrder(1)


	If !Empty(M->A1_XM0FIL)

		AADD( aStrRec, { "MARK"     , "C", 2 	, 0 })

		Aadd( aStrRec, {"TMP_FIL"	   ,"C",  TamSX3("A6_FILIAL") [1], 0 })
		Aadd( aStrRec, {"TMP_BCO"	   ,"C",  TamSX3("A6_COD")   [1], 0 })
		Aadd( aStrRec, {"TMP_AGEN"	   ,"C",  TamSX3("A6_AGENCIA")[1], 0 })
		Aadd( aStrRec, {"TMP_NUM"	   ,"C",  TamSX3("A6_NUMCON")[1], 0 })
		Aadd( aStrRec, {"TMP_NOME"     ,"C",  TamSX3("A6_NOME" )[1], 0 })


/*  by hfp/compila
Trocado o codigo abaixo do criatrab e dbuseArea, por causa do erro acusado no codeanalysis
*/
		oTmpTab := FwTemporaryTable():New("TMP",aStrRec)
//oTmpTab:AddIndex("1", {}  )
//Criando a Tabela Temporaria
		oTmpTab:Create()
//pega alias criado e coloca na variavel do antigo criatrab
		cTempAlias := oTmpTab:GetAlias()

/*
 	cTmpRec := CriaTrab( aStrRec , .T. )       
	DbUseArea(.T.,,cTmpRec,cTempAlias,.T.,.F.)   //arq temp deve estar aberta para poder dar insert	
*/

		cFilAnt := M->A1_XM0FIL

		BeginSql Alias cSA6Alias
		
		SELECT SA6.*      FROM %table:SA6% SA6       WHERE SA6.A6_FILIAL  = %xFilial:SA6%
		             AND SA6.%NotDel%              //AND SL1.L1_DOC    <> %Exp:(cBranco)%   //no loja não existe faturamento parcial do orçamento. Por isto, olhamos direto no cabeçalho
		ORDER BY A6_FILIAL, A6_COD
		  
		EndSql


		While (cSA6Alias)->(!Eof())
			lAchou     := .T.
			reclock(cTempAlias,.T.)
			(cTempAlias)->MARK    :=  ''
			(cTempAlias)->TMP_FIL    :=  (cSA6Alias)->A6_FILIAL
			(cTempAlias)->TMP_BCO       :=  (cSA6Alias)->A6_COD
			(cTempAlias)->TMP_AGEN   :=  (cSA6Alias)->A6_AGENCIA
			(cTempAlias)->TMP_NUM    :=  (cSA6Alias)->A6_NUMCON
			MsUnLock()

			(cSA6Alias)->(DbSkip())
		End

		(cSA6Alias)->(DbCLoseArea())

		cFilAnt := cOLdFil

		If lAchou  == .T.

			While lMantem

				(cTempAlias)->(DbGoTop())

				aCampos := {}
				AADD(aCampos,{ "Filial"        , {|| (cTempAlias)->(TMP_FIL) } , "C" , "@!"  	})
				AADD(aCampos,{ "Banco"        , {|| (cTempAlias)->(TMP_BCO) } , "C" , "@!"  	})
				AADD(aCampos,{ "Agência"        , {|| (cTempAlias)->(TMP_AGEN) } , "C" , "@!"  	})
				AADD(aCampos,{ "Conta"        , {|| (cTempAlias)->(TMP_NUM) } , "C" , "@!"  	})

				DEFINE MSDIALOG oDlgMrk TITLE OemToAnsi('Bancos') FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4]  PIXEL

				oMarkEnd:= FWMarkBrowse():New()
				//-- Definição da tabela a ser utilizada
				oMArkEnd:SetOwner(oDlgMrk)

				oMarkEnd:SetAlias(cTempAlias)
				oMarkEnd:SetDescription('Bancos da empresa-filial: ' + AllTrim(cFilAnt))
				//-- Define o campo que sera utilizado para a marcação
				oMarkEnd:SetFieldMark( 'MARK' )
				oMarkEnd:SetMark('IT', cTempAlias, 'MARK')
				//-- Define a marcacao de todos os registros
				oMarkEnd:ballMark := { || }//SetMarkAll('IT'/*oMarkEnd:Mark()*/,lMarcar := !lMarcar ), oMarkEnd:Refresh(.T.)  }

				//-- Define os campos a serem apresentados no Browse
				oMarkEnd:SetFields(aCampos)
				oMarkEnd:Activate()
				oMarkEnd := Nil
				ACTIVATE MSDIALOG oDlgMrk CENTER ON INIT EnchoiceBar(oDlgMrk, {|| oDlgMrk:End() }, {|| oDlgMrk:End()}  ,,)

				(cTempAlias)->(DbGoTop())

				nCOunt := 0
				While (cTempAlias)->(!Eof())
					If !Empty((cTempAlias)->(MARK))
						cFilANt := M->A1_XM0FIL

						DbSelectArea("SA6")
						DbSetOrder(1)
						DbSeek( xFilial("SA6") + (cTempAlias)->(TMP_BCO) + (cTempAlias)->(TMP_AGEN) + (cTempAlias)->(TMP_NUM),.T.)

						cFilAnt := cOLdFil

						nCount += 1
						If nCOunt > 1
							exit
						EndIf
					ENdIf
					(cTempAlias)->(DbSkip())
				End

				If nCOunt > 1
					Alert ("Selecione um único banco !")
					Loop
				EndIf

				If nCOunt == 0
					Alert ("Selecione ao menos um banco!")
					Loop
				EndIf
				lMantem := .F.
				M->A1_XMBC := SA6->A6_COD
				M->A1_XMAG := SA6->A6_AGENCIA
				M->A1_XMCN := SA6->A6_NUMCON

			ENd

		Else
			Alert ("Não existem registros na tabela de Bancos da empresa-filial: " + AllTrim(M->A1_XM0FIL))
		EndIf

		/*
		==>trocado pelo codigo abaixo, pois a criacao foi pelo nova forma.
		   ver a criacao antes do criatrab acima.
		
		(cTempAlias)->(DbCLoseArea()) 
		fErase ( cTmpRec + GetDBExtension() )
		*/
		IF VALTYPE(oTmpTab) == "O"
			oTmpTab:DELETE()
			oTmpTab	:= NIL
		ENDIF

	Else
		Alert ("Este Cliente não possui empresa-filial de Mútuo informada em seu cadastro. Portanto, não deve ser utilizado!")
	EndIf



RETURN


/*
MenuDef
Somente qdo chamado o F3 de bancos pela "tela de clientes", foi preciso forjar um menu em branco para remover os botões de incluir e alterar que o sistema insistia em exibir

@author 
@since 09/12/2014
@version 1.0
*/

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE '' 	    ACTION ''           OPERATION 1 ACCESS 0  //nao efetua nenhuma ação

Return ( aRotina )

/*
PegForDaFIlial()
VERIFICA SE FILIAL CONECTADA ESTA CADASTRADA COMO FORNEC

@author 
@since 09/12/2014
@version 1.0
*/

Static Function PegForDaFIlial()
//	Local aArea
	Local cPsqAlias
	Local cCgc := ''
	Local cMeuOldFilAnt := SM0->M0_CODFIL
//	LOcal cPsqAlias
	Local lRet := .T.

	SM0->(DBgotop())

	While SM0->(!Eof())

		If AllTrim(SM0->M0_CODFIL) == AllTrim(cFIlAnt)
			cCgc := SM0->M0_CGC
			exit
		EndIf

		SM0->(DbSKip())
	End


	SM0->(DBgotop())

	While SM0->(!Eof())

		If AllTrim(SM0->M0_CODFIL) == AllTrim(cMeuOldFilAnt)//reposiciona na filial na qual SM) estava
			exit
		EndIf

		SM0->(DbSKip())
	End

	If !Empty(cCgc)

		cPsqAlias := GetNextAlias()
		BeginSql Alias cPsqAlias
			
	SELECT SA2.*
		FROM %table:SA2% SA2
			       WHERE SA2.%NotDel%           AND SA2.A2_CGC = %Exp:(cCgc)%
			                                            
		EndSql

		If (cPsqAlias)->(!Eof())
			If  AllTrim((cPsqAlias)->(A2_CGC)) == AllTrim(cCgc)
				cFilcgc    := cCgc
				cFilFornec := (cPsqAlias)->(A2_COD)
				cFilLoja   := (cPsqAlias)->(A2_LOJA)
				cFilBco    := (cPsqAlias)->(A2_BANCO)
				cFilAgencia:= (cPsqAlias)->(A2_AGENCIA)
				cFilNumCon := (cPsqAlias)->(A2_NUMCON)
				SA2->(DbGoTo( (cPsqAlias)->(R_E_C_N_O_) )  )
			Else
				lRet := .F.
				Alert ("A empresa-filial na qual estamos conectados deve estar cadastrado como um Fornecedor no sistema para podermos utilizar esta rotina!")
			EndIf
		Else
			lRet := .F.
			Alert ("A empresa-filial na qual estamos conectados deve estar cadastrado como um Fornecedor no sistema para podermos utilizar esta rotina!")
		EndIf

		(cPsqAlias)->(DbCLoseArea())

	/*
		If lRet
		DbSelectArea('SA6')
		DbSetOrder(1)
		SA6->(DBSeek( Fwxfilial('SA6') + cFilBco + cFilAgencia + cFilNumCon ))
		 	
			If  !( SA6->(!Eof()) .ANd. AllTrim(SA6->A6_COD) == AllTrim(cFilBco)  .ANd. AllTrim(SA6->A6_AGENCIA) == AllTrim(cFilAgencia)  .ANd. AllTrim(SA6->A6_NUMCON) == AllTrim(cFilNumCon) )
		 		Alert ("O Banco(" + AllTrim(cFilBco) + ") Agência(" + AllTrim(cFilAgencia) + ") e Conta(" + AllTrim(cFilNumCon) + "), " ;
		 		       + "especificados no cadastro do Fornecedor do Mútuo (" + AllTrim(cFilFornec) + " - " + AllTrim(cFilLoja) + ") não se encontra no cadastro de Bancos da Empresa-Filial na qual você se encontra conectado!" )
		
		 		lRet := .F.
			ENdIf
		ENdIf*/
	
	EndIf



return lRet



/*
ALGTSSA1
LOOKUP DE BANCOS DE ACORDO COM EMPRESA FILIAL DO CLIENTE

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALGTSSA1 ()
	Local aStrRec := {}
	//Local oBrowse 	:= Nil
//	Local lMarcar    := .F.
	Local nCount     := 0
	Local lAchou     := .F.
	Local cOldFil    := cFIlAnt
	Private aRotina := MenuDef() //<-- Somente qdo chamado o F3 de bancos pela "tela de clientes", foi preciso forjar um menu em branco para remover os botões de incluir e alterar que o sistema insistia em exibir
	Private cTmpRec
	Private cTempAlias := GetNextALias()
	Private cSA6ALias  := GetNextAlias()
	Private aCampos := {}
	Private oMarkENd
	Private oDlgMrk
	Private oSize
	Private lMantem    := .T.

	oSize := FwDefSize():New()
	oSize:AddObject( "CABECALHO",  100, 100, .T., .T. ) // Totalmente dimensionavel

	oSize:lProp 	:= .T. // Proporcional
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
	oSize:Process() // Dispara os calculos

	DbSelectArea("SA1")
	DbSetOrder(1)


	If !Empty(SA1->A1_XM0FIL)

		AADD( aStrRec, { "MARK"     , "C", 2 	, 0 })

		Aadd( aStrRec, {"TMP_FIL"	   ,"C",  TamSX3("A6_FILIAL") [1], 0 })
		Aadd( aStrRec, {"TMP_BCO"	   ,"C",  TamSX3("A6_COD")   [1], 0 })
		Aadd( aStrRec, {"TMP_AGEN"	   ,"C",  TamSX3("A6_AGENCIA")[1], 0 })
		Aadd( aStrRec, {"TMP_NUM"	   ,"C",  TamSX3("A6_NUMCON")[1], 0 })
		Aadd( aStrRec, {"TMP_NOME"     ,"C",  TamSX3("A6_NOME" )[1], 0 })


		//Cria arquivo temporario com os campos acima
		//hfp cTmpRec := CriaTrab( aStrRec , .T. )
		//hfp DbUseArea(.T.,,cTmpRec,cTempAlias,.T.,.F.)   //arq temp deve estar aberta para poder dar insert
		oTmpTab := FwTemporaryTable():New("TMP",aStrRec)
		oTmpTab:Create()
		cTempAlias := oTmpTab:GetAlias()


		cFilAnt := SA1->A1_XM0FIL

		BeginSql Alias cSA6Alias
		
		SELECT SA6.*      FROM %table:SA6% SA6       WHERE SA6.A6_FILIAL  = %xFilial:SA6%
		             AND SA6.%NotDel%              //AND SL1.L1_DOC    <> %Exp:(cBranco)%   //no loja não existe faturamento parcial do orçamento. Por isto, olhamos direto no cabeçalho
		ORDER BY A6_FILIAL, A6_COD
		  
		EndSql


		While (cSA6Alias)->(!Eof())
			lAchou     := .T.
			reclock(cTempAlias,.T.)
			(cTempAlias)->MARK    :=  ''
			(cTempAlias)->TMP_FIL    :=  (cSA6Alias)->A6_FILIAL
			(cTempAlias)->TMP_BCO       :=  (cSA6Alias)->A6_COD
			(cTempAlias)->TMP_AGEN   :=  (cSA6Alias)->A6_AGENCIA
			(cTempAlias)->TMP_NUM    :=  (cSA6Alias)->A6_NUMCON
			MsUnLock()

			(cSA6Alias)->(DbSkip())
		End

		(cSA6Alias)->(DbCLoseArea())

		cFilAnt := cOLdFil

		If lAchou  == .T.

			While lMantem

				(cTempAlias)->(DbGoTop())

				aCampos := {}
				AADD(aCampos,{ "Filial"        , {|| (cTempAlias)->(TMP_FIL) } , "C" , "@!"  	})
				AADD(aCampos,{ "Banco"        , {|| (cTempAlias)->(TMP_BCO) } , "C" , "@!"  	})
				AADD(aCampos,{ "Agência"        , {|| (cTempAlias)->(TMP_AGEN) } , "C" , "@!"  	})
				AADD(aCampos,{ "Conta"        , {|| (cTempAlias)->(TMP_NUM) } , "C" , "@!"  	})

				DEFINE MSDIALOG oDlgMrk TITLE OemToAnsi('Bancos') FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4]  PIXEL

				oMarkEnd:= FWMarkBrowse():New()
				//-- Definição da tabela a ser utilizada
				oMArkEnd:SetOwner(oDlgMrk)

				oMarkEnd:SetAlias(cTempAlias)
				oMarkEnd:SetDescription('Bancos da empresa-filial: ' + AllTrim(cFilAnt))
				//-- Define o campo que sera utilizado para a marcação
				oMarkEnd:SetFieldMark( 'MARK' )
				oMarkEnd:SetMark('IT', cTempAlias, 'MARK')
				//-- Define a marcacao de todos os registros
				oMarkEnd:ballMark := { || }//SetMarkAll('IT'/*oMarkEnd:Mark()*/,lMarcar := !lMarcar ), oMarkEnd:Refresh(.T.)  }

				//-- Define os campos a serem apresentados no Browse
				oMarkEnd:SetFields(aCampos)
				oMarkEnd:Activate()
				oMarkEnd := Nil
				ACTIVATE MSDIALOG oDlgMrk CENTER ON INIT EnchoiceBar(oDlgMrk, {|| oDlgMrk:End() }, {|| oDlgMrk:End()}  ,,)

				(cTempAlias)->(DbGoTop())

				nCOunt := 0
				While (cTempAlias)->(!Eof())
					If !Empty((cTempAlias)->(MARK))
						cFilANt := SA1->A1_XM0FIL

						DbSelectArea("SA6")
						DbSetOrder(1)
						DbSeek( xFilial("SA6") + (cTempAlias)->(TMP_BCO) + (cTempAlias)->(TMP_AGEN) + (cTempAlias)->(TMP_NUM),.T.)

						cFilAnt := cOLdFil

						nCount += 1
						If nCOunt > 1
							exit
						EndIf
					ENdIf
					(cTempAlias)->(DbSkip())
				End

				If nCOunt > 1
					Alert ("Selecione um único banco !")
					Loop
				EndIf

				If nCOunt == 0
					Alert ("Selecione ao menos um banco!")
					Loop
				EndIf
				lMantem := .F.
				MV_PAR09 := SA6->A6_COD
				MV_PAR10 := SA6->A6_AGENCIA
				MV_PAR11 := SA6->A6_NUMCON

			ENd

		Else
			Alert ("Não existem registros na tabela de Bancos da empresa-filial: " + AllTrim(M->A1_XM0FIL))
		EndIf


		//hfp (cTempAlias)->(DbCLoseArea())
		//hfp fErase ( cTmpRec + GetDBExtension() )
		IF VALTYPE(oTmpTab) == "O"
			oTmpTab:DELETE()
			oTmpTab	:= NIL
		ENDIF

	Else
		Alert ("Este Cliente não possui empresa-filial de Mútuo informada em seu cadastro. Portanto, não deve ser utilizado!")
	EndIf



RETURN





/*
VrExistBco
Verifica se o banco agencia e conta do titulo que sera automaticamente baixado na Origem ...ainda existem no sistema. Caso contrario impede iniciar a operacao.

@author 
@since 09/12/2014
@version 1.0
*/

User Function VrExistBco()
	Local cE1Alias := GetNextAlias()
	Local lRet     := .T.
	Local cOldFil := cFilAnt
	Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')

	If Alltrim(cPrefMutuo) == AllTrim(SE2->E2_PREFIXO)

		cFilAnt := SE2->E2_XMFIL

		BeginSql Alias cE1Alias
	
	SELECT SE1.*
	       
	       FROM %table:SE1% SE1
	       WHERE SE1.E1_FILIAL     = %xFilial:SE1%  
	             AND SE1.%NotDel%
	             AND SE1.E1_NUM     = %Exp:(SE2->E2_XMNUM)%                               
	       		 AND SE1.E1_PREFIXO = %Exp:(SE2->E2_XMPRF)%                               
	       		 AND SE1.E1_TIPO    = %Exp:(SE2->E2_XMTIP)%                               
	       		 AND SE1.E1_PARCELA = %Exp:(SE2->E2_XMPAR)%                               
	       		 AND SE1.E1_CLIENTE = %Exp:(SE2->E2_XMCLI)%                               
	       		 AND SE1.E1_LOJA    = %Exp:(SE2->E2_XMLOJ)%                               
	       		 			 
		EndSql

		If (cE1Alias)->(!Eof())
			If  AllTrim( (cE1Alias)->(E1_NUM)     ) == AllTrim(SE2->E2_XMNUM) .And. ;
					AllTrim( (cE1Alias)->(E1_PREFIXO) ) == AllTrim(SE2->E2_XMPRF) .And. ;
					AllTrim( (cE1Alias)->(E1_TIPO)    ) == AllTrim(SE2->E2_XMTIP) .And. ;
					AllTrim( (cE1Alias)->(E1_PARCELA) ) == AllTrim(SE2->E2_XMPAR) .And. ;
					AllTrim( (cE1Alias)->(E1_CLIENTE) ) == AllTrim(SE2->E2_XMCLI) .And. ;
					AllTrim( (cE1Alias)->(E1_LOJA   ) ) == AllTrim(SE2->E2_XMLOJ)

				DbSelectArea('SE1')
				DbSetOrder(1)
				SE1->(DbGoTo(  (cE1Alias)->(R_E_C_N_O_) ))
			/*
			DbSelectARea('SA6')
			DbSetOrder(1)
			SA6->(DbSeek   (Fwxfilial('SA6') +  SE1->E1_XMBC + SE1->E1_XMAG  + SE1->E1_XMCN  )   )

				If !(SA6->(!Eof()) .And. Alltrim(SA6->A6_COD) == AllTrim(SE1->E1_XMBC) .And.  Alltrim(SA6->A6_AGENCIA) == AllTrim(SE1->E1_XMAG) .And.  Alltrim(SA6->A6_NUMCON) == AllTrim(SE1->E1_XMCN) )
				Alert ("Ao efetuar a baixa no Contas a Pagar, o sistema deverá baixar também o Tìtulo do Contas a Receber da empresa-filial que originou o Mútuo. Entretanto, o Título de Origem do Mútuo (" + SE1->E1_NUM + ") existente na Empresa-filial (" + AllTrim(cFilAnt) + ") possui dados bancários que não se encontram mais cadastrados no sistema! Por favor, ajuste os seus cadastros e refaça a operação. ")
				EndIf*/
			
			Else
			Alert ('Atenção: Título Origem do Mútuo não localizado no Contas a Receber(' + cFIlAnt + ')! Não será possível efetuar a operação de Baixa!' )
			lRet := .F.
			
			EndIf
		EndIf
	
	(cE1Alias)->(DbCLoseArea())
	
	cFilANt := cOLdFil

		If lRet
		lRet := EscolheNovoBcoParaBaixaCR()
		
		
			If lRet .ANd. SA6->(!Eof())
			 
			//SE1 ainda estara posicionado na SE1 desejada para baixa
			reclock('SE1',.F.)
	
			//marca o titulo que sera baixado com o banco recentemente escolhido
			//avisei toninho que com esta customizacao diferentes parcelas do titulo poderao ser baixadas com diferentes bancos (caso a todo momento o usuario selecione um novo banco)
			SE1->E1_XMBC := SA6->A6_COD
			SE1->E1_XMAG := SA6->A6_AGENCIA
			SE1->E1_XMCN := SA6->A6_NUMCON
			MsUNLock()
			EndIf
		
				
		EndIf

	EndIf

return lRet


/*
VrExistBco
Verifica se o banco agencia e conta do titulo que sera automaticamente baixado na Origem ...ainda existem no sistema. Caso contrario impede iniciar a operacao.

@author 
@since 09/12/2014
@version 1.0
*/

Static Function EscolheNovoBcoParaBaixaCR()
	Local lMantem := .T.
	Local cPerg   := "ESCMTU"
	Local cOldFil := cFilANt
	Local lOk     := .F.

	SaveInter()//salva os dados da primeira pergunta

	cFilAnt := SE2->E2_XMFIL

	BcoAjustSx1(cPerg)

	While lMantem

		If	pergunte(cPerg,.T.)

			If Empty(MV_PAR01)//Informe o banco
				Alert ("Informe o Banco para ser utilizado na Baixa do Contas a Receber (Origem do Mùtuo)!")
				Loop
			EndIf

			If Empty(MV_PAR02)//Informe a agencia
				Alert ("Informe a Agência para ser utilizado na Baixa do Contas a Receber (Origem do Mùtuo)!")
				Loop
			EndIf

			If Empty(MV_PAR03)//Informe a conta
				Alert ("Informe a Conta para ser utilizado na Baixa do Contas a Receber (Origem do Mùtuo)!")
				Loop
			EndIf

			DbSelectArea("SA6")
			DbSetOrder(1)
			DbSeek( FwxFilial("SA6") + MV_PAR01 + MV_PAR02 + MV_PAR03,.T.)

			If !(SA6->(!Eof()) .And. Alltrim(SA6->A6_COD) == AllTrim(MV_PAR01) .And.  Alltrim(SA6->A6_AGENCIA) == AllTrim(MV_PAR02) .And.  Alltrim(SA6->A6_NUMCON) == AllTrim(MV_PAR03) )
				Alert ("Banco\Agência e Conta não cadastrados no sistema (Tabela SA6) na Empresa-filial Origem do Mútuo("+ cFilAnt + ") !")
				Loop
			EndIf

			lMantem := .F.
			lOk := .T.
		Else
			lMantem := .F.
			lOk := .F.
			Alert ("Ao cancelar a seleção do Banco de Origem do Mútuo(dado obrigatório) a sua operação de Baixa será abortada!")
		EndIf
	End

	RestInter()

	cFilANt := cOldFil

return lOk


/*/{Protheus.doc} BcoAjustSX1

Perguntas/parametros para impressao

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/                
Static Function BcoAjustSX1(CPERG)
//	Local nCnt := 0

	PutSx1(cPerg, "01", "Bco Origem Mutuo",    "Bco ",    "Bco "   , "mv_ch1", "C", TamSx3("A6_COD")[1], 0, 0, "G", "", "ALLS18", "", "",       "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
	PutSx1(cPerg, "02", "Agenc. ", "Agenc. ", "Agenc. ", "mv_ch2", "C", TamSx3("A6_AGENCIA")[1], 0, 0, "G", "",       "", "", "",       "MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
	PutSx1(cPerg, "03", "Conta ",  "Conta ",  "Conta " , "mv_ch3", "C", TamSx3("A6_NUMCON")[1], 0, 0, "G", "",       "", "", "",        "MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )


return




/*
ALF3BAI
LOOKUP DE BANCOS da empresa origem do mutuo, exibido no ato da baixa do contas a pagar na empresa destino

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALF3BAI ()
	Local aStrRec := {}
	//Local oBrowse 	:= Nil
	//Local lMarcar    := .F.
	Local nCount     := 0
	Local lAchou     := .F.
	Local cOldFil    := cFIlAnt
	Private aRotina := MenuDef() //<-- Somente qdo chamado o F3 de bancos pela "tela de clientes", foi preciso forjar um menu em branco para remover os botões de incluir e alterar que o sistema insistia em exibir
	Private cTmpRec
	Private cTempAlias := GetNextALias()
	Private cSA6ALias  := GetNextAlias()
	Private aCampos := {}
	Private oMarkENd
	Private oDlgMrk
	Private oSize
	Private lMantem    := .T.

	oSize := FwDefSize():New()
	oSize:AddObject( "CABECALHO",  100, 100, .T., .T. ) // Totalmente dimensionavel

	oSize:lProp 	:= .T. // Proporcional
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
	oSize:Process() // Dispara os calculos


	AADD( aStrRec, { "MARK"     , "C", 2 	, 0 })

	Aadd( aStrRec, {"TMP_FIL"	   ,"C",  TamSX3("A6_FILIAL") [1], 0 })
	Aadd( aStrRec, {"TMP_BCO"	   ,"C",  TamSX3("A6_COD")   [1], 0 })
	Aadd( aStrRec, {"TMP_AGEN"	   ,"C",  TamSX3("A6_AGENCIA")[1], 0 })
	Aadd( aStrRec, {"TMP_NUM"	   ,"C",  TamSX3("A6_NUMCON")[1], 0 })
	Aadd( aStrRec, {"TMP_NOME"     ,"C",  TamSX3("A6_NOME" )[1], 0 })

	//Cria arquivo temporario com os campos acima
	// cTmpRec := CriaTrab( aStrRec , .T. )
	// DbUseArea(.T.,,cTmpRec,cTempAlias,.T.,.F.)   //arq temp deve estar aberta para poder dar insert
	oTmpTab := FwTemporaryTable():New("TMP",aStrRec)
	oTmpTab:Create()
	cTempAlias := oTmpTab:GetAlias()

	cFilAnt := SE2->E2_XMFIL

	BeginSql Alias cSA6Alias
		
		SELECT SA6.*      FROM %table:SA6% SA6       WHERE SA6.A6_FILIAL  = %xFilial:SA6%    AND SA6.%NotDel%             
		ORDER BY A6_FILIAL, A6_COD
		  
	EndSql


	While (cSA6Alias)->(!Eof())
		lAchou     := .T.
		reclock(cTempAlias,.T.)
		(cTempAlias)->MARK    :=  ''
		(cTempAlias)->TMP_FIL    :=  (cSA6Alias)->A6_FILIAL
		(cTempAlias)->TMP_BCO       :=  (cSA6Alias)->A6_COD
		(cTempAlias)->TMP_AGEN   :=  (cSA6Alias)->A6_AGENCIA
		(cTempAlias)->TMP_NUM    :=  (cSA6Alias)->A6_NUMCON
		MsUnLock()

		(cSA6Alias)->(DbSkip())
	End

	(cSA6Alias)->(DbCLoseArea())

	cFilAnt := cOLdFil

	If lAchou  == .T.

		While lMantem

			(cTempAlias)->(DbGoTop())

			aCampos := {}
			AADD(aCampos,{ "Filial"        , {|| (cTempAlias)->(TMP_FIL) } , "C" , "@!"  	})
			AADD(aCampos,{ "Banco"        , {|| (cTempAlias)->(TMP_BCO) } , "C" , "@!"  	})
			AADD(aCampos,{ "Agência"        , {|| (cTempAlias)->(TMP_AGEN) } , "C" , "@!"  	})
			AADD(aCampos,{ "Conta"        , {|| (cTempAlias)->(TMP_NUM) } , "C" , "@!"  	})

			DEFINE MSDIALOG oDlgMrk TITLE OemToAnsi('Bancos da Empresa-Filial Origem do Mútuo') FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4]  PIXEL

			oMarkEnd:= FWMarkBrowse():New()
			//-- Definição da tabela a ser utilizada
			oMArkEnd:SetOwner(oDlgMrk)

			oMarkEnd:SetAlias(cTempAlias)
			oMarkEnd:SetDescription('Bancos da empresa-filial: ' + AllTrim(cFilAnt))
			//-- Define o campo que sera utilizado para a marcação
			oMarkEnd:SetFieldMark( 'MARK' )
			oMarkEnd:SetMark('IT', cTempAlias, 'MARK')
			//-- Define a marcacao de todos os registros
			oMarkEnd:ballMark := { || }//SetMarkAll('IT'/*oMarkEnd:Mark()*/,lMarcar := !lMarcar ), oMarkEnd:Refresh(.T.)  }

			//-- Define os campos a serem apresentados no Browse
			oMarkEnd:SetFields(aCampos)
			oMarkEnd:Activate()
			oMarkEnd := Nil
			ACTIVATE MSDIALOG oDlgMrk CENTER ON INIT EnchoiceBar(oDlgMrk, {|| oDlgMrk:End() }, {|| oDlgMrk:End()}  ,,)

			(cTempAlias)->(DbGoTop())

			nCOunt := 0
			While (cTempAlias)->(!Eof())
				If !Empty((cTempAlias)->(MARK))

					DbSelectArea("SA6")
					DbSetOrder(1)
					DbSeek( xFilial("SA6") + (cTempAlias)->(TMP_BCO) + (cTempAlias)->(TMP_AGEN) + (cTempAlias)->(TMP_NUM),.T.)

					nCount += 1
					If nCOunt > 1
						exit
					EndIf
				ENdIf
				(cTempAlias)->(DbSkip())
			End

			If nCOunt > 1
				Alert ("Selecione um único banco !")
				Loop
			EndIf

			If nCOunt == 0
				Alert ("Selecione ao menos um banco!")
				Loop
			EndIf

			lMantem := .F.
			MV_PAR01 := SA6->A6_COD
			MV_PAR02 := SA6->A6_AGENCIA
			MV_PAR03 := SA6->A6_NUMCON

		End

	Else
		Alert ("Não existem registros na tabela de Bancos da empresa-filial: " + AllTrim(cFilAnt))
	EndIf


	//hfp (cTempAlias)->(DbCLoseArea())
	//hfp fErase ( cTmpRec + GetDBExtension() )
	IF VALTYPE(oTmpTab) == "O"
		oTmpTab:DELETE()
		oTmpTab	:= NIL
	ENDIF

RETURN



/*
ALE1VCTO
Alterar vencimento do mutuo SE1

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALE1VCTO ()
	//Local lMantem := .T.
	Local  cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cTitALias := GetNextAlias()
	Local dDtRet := ctod('')
	LOcal cOLdFil := cFilANt
	Private lBaixado := .F.
	Private cEMissao := Padl( AllTrim(STR(day(SE1->E1_EMISSAO))),  2,  "0")   + "/" + Padl( AllTrim(STR(month(SE1->E1_EMISSAO))),  2,  "0") + "/" +  AllTrim(STR(year(SE1->E1_EMISSAO)))
	Private cVencto  := Padl( AllTrim(STR(day(SE1->E1_VENCTO))) ,  2,  "0")   + "/" + Padl( AllTrim(STR(month(SE1->E1_VENCTO))) ,  2,  "0") + "/" +  AllTrim(STR(year(SE1->E1_VENCTO)))

	If SE1->(!Eof())
		If Alltrim(SE1->E1_PREFIXO) == AllTrim(cPrefMutuo)

			lBaixado := .F.

			dDtRet := TelaAltVcto (SE1->E1_VENCREA,SE1->E1_BAIXA, SE1->E1_EMISSAO, SE1->E1_VENCTO)

			If	!Empty(dDtRet) //pergunte(cPerg,.T.)
				If !lBaixado
					RecLock("SE1",.F.)
					SE1->E1_VENCREA := dDtRet
					MsUNLOck()

					cFIlAnt := SE1->E1_XMFIL

					BeginSql Alias cTitAlias
	
					SELECT SE2.*
					       
					       FROM %table:SE2% SE2
					       WHERE SE2.E2_FILIAL     = %xFilial:SE2%  
					             AND SE2.%NotDel%
					             AND SE2.E2_NUM     = %Exp:(SE1->E1_XMNUM)%                               
					       		 AND SE2.E2_PREFIXO = %Exp:(SE1->E1_XMPRF)%                               
					       		 AND SE2.E2_TIPO    = %Exp:(SE1->E1_XMTIP)%                               
					       		 AND SE2.E2_PARCELA = %Exp:(SE1->E1_XMPAR)%                               
					       		 AND SE2.E2_FORNECE = %Exp:(SE1->E1_XMFOR)%                               
					       		 AND SE2.E2_LOJA    = %Exp:(SE1->E1_XMLOJ)%                               
					       		 			 
					EndSql

					If (cTitAlias)->(!Eof())
						If  AllTrim( (cTitAlias)->(E2_NUM)     ) == AllTrim(SE1->E1_XMNUM) .And. ;
								AllTrim( (cTitAlias)->(E2_PREFIXO) ) == AllTrim(SE1->E1_XMPRF) .And. ;
								AllTrim( (cTitAlias)->(E2_TIPO)    ) == AllTrim(SE1->E1_XMTIP) .And. ;
								AllTrim( (cTitAlias)->(E2_PARCELA) ) == AllTrim(SE1->E1_XMPAR) .And. ;
								AllTrim( (cTitAlias)->(E2_FORNECE) ) == AllTrim(SE1->E1_XMFOR) .And. ;
								AllTrim( (cTitAlias)->(E2_LOJA   ) ) == AllTrim(SE1->E1_XMLOJ)

							Dbselectarea('SE2')
							SE2->( DbGoTo(  (cTitAlias)->(R_E_C_N_O_)  )   )

							RecLock("SE2",.F.)
							SE2->E2_VENCREA := dDtRet
							MsUNLOck()


						EndIf
					EndIf

					(cTitAlias)->(DbCloseArea())

					cFIlAnt := cOldFil

					MsgInfo("Data de Vencimento Real Modificada!","Sucesso")
				EndIf

			Else
				Alert("Operação de modificação abortada!")
			EndIf

		Else
			Alert ("Opção disponível somente para títulos do Mútuo!")
		EndiF
	Else
		Alert ("Título não localizado no Browse!")
	EndIf

return



/*
ALE2VCTO
Alterar vencimento do mutuo SE2

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALE2VCTO ()
	//Local lMantem := .T.
	Local  cPrefMutuo   := SuperGetMV("ES_PRMU",, '')
	Local cTitALias := GetNextAlias()
	Local cOldFil := cFIlAnt
	LOcal dDtRet := ctod('')
	Private lBaixado := .F.
	Private cEMissao := Padl( AllTrim(STR(day(SE2->E2_EMISSAO))),  2,  "0")   + "/" + Padl( AllTrim(STR(month(SE2->E2_EMISSAO))),  2,  "0") + "/" +  AllTrim(STR(year(SE2->E2_EMISSAO)))
	Private cVencto  := Padl( AllTrim(STR(day(SE2->E2_VENCTO))) ,  2,  "0")   + "/" + Padl( AllTrim(STR(month(SE2->E2_VENCTO))) ,  2,  "0") + "/" +  AllTrim(STR(year(SE2->E2_VENCTO)))

	If SE2->(!Eof())
		If Alltrim(SE2->E2_PREFIXO) == AllTrim(cPrefMutuo)

			lBaixado := .F.

			dDtRet := TelaAltVcto (SE2->E2_VENCREA,SE2->E2_BAIXA, SE2->E2_EMISSAO, SE2->E2_VENCTO)

			If	!Empty(dDtRet) //pergunte(cPerg,.T.)
				If !lBaixado
					RecLock("SE2",.F.)
					SE2->E2_VENCREA := dDtRet
					MsUNLOck()

					cFIlAnt := SE2->E2_XMFIL

					BeginSql Alias cTitAlias
	
					SELECT SE1.*
					       
					       FROM %table:SE1% SE1
					       WHERE SE1.E1_FILIAL     = %xFilial:SE1%  
					             AND SE1.%NotDel%
					             AND SE1.E1_NUM     = %Exp:(SE2->E2_XMNUM)%                               
					       		 AND SE1.E1_PREFIXO = %Exp:(SE2->E2_XMPRF)%                               
					       		 AND SE1.E1_TIPO    = %Exp:(SE2->E2_XMTIP)%                               
					       		 AND SE1.E1_PARCELA = %Exp:(SE2->E2_XMPAR)%                               
					       		 AND SE1.E1_CLIENTE = %Exp:(SE2->E2_XMCLI)%                               
					       		 AND SE1.E1_LOJA    = %Exp:(SE2->E2_XMLOJ)%                               
					       		 			 
					EndSql

					If (cTitAlias)->(!Eof())
						If  AllTrim( (cTitAlias)->(E1_NUM)     ) == AllTrim(SE2->E2_XMNUM) .And. ;
								AllTrim( (cTitAlias)->(E1_PREFIXO) ) == AllTrim(SE2->E2_XMPRF) .And. ;
								AllTrim( (cTitAlias)->(E1_TIPO)    ) == AllTrim(SE2->E2_XMTIP) .And. ;
								AllTrim( (cTitAlias)->(E1_PARCELA) ) == AllTrim(SE2->E2_XMPAR) .And. ;
								AllTrim( (cTitAlias)->(E1_CLIENTE) ) == AllTrim(SE2->E2_XMCLI) .And. ;
								AllTrim( (cTitAlias)->(E1_LOJA   ) ) == AllTrim(SE2->E2_XMLOJ)
							DBselectarea('SE1')
							SE1->(DbGoto(  (cTitAlias)->(R_E_C_N_O_)   ))

							reclock('SE1',.F.)
							SE1->E1_VENCREA := dDtRet
							MsUnLock()
						EndIf
					EndIf

					(cTitAlias)->(DbCloseArea())

					cFilAnt := cOldFil

					MsgInfo("Data de Vencimento Real Modificada!","Sucesso")
				EndIf
			Else
				Alert("Operação de modificação abortada!")
			EndIf

		Else
			Alert ("Opção disponível somente para títulos do Mútuo!")
		EndiF
	Else
		Alert ("Título não localizado no Browse!")
	EndIf

return




/*/{Protheus.doc} TelaAltVcto
Perguntas/parametros para alterar vencto real do Mutuo

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/                
Static function TelaAltVcto (dDataAtual,dBaixa, dEmissao, dVencto)
	Local oMainWnd
	Local oSize
	Local oCod
	Local oDlg
	//Local lOpcA := .F.
	Local 	dDataReal := dDataAtual

	Private aButtons    := {}

	oSize := FwDefSize():New()
	oSize:AddObject( "CABECALHO",  100, 100, .T., .T. ) // Totalmente dimensionavel
	oSize:lProp 	:= .T. // Proporcional
	oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3
	oSize:Process() // Dispara os calculos

	DEFINE MSDIALOG oDlg TITLE OemToAnsi('Alterar a Data de Vencimento Real') OF oMainWnd PIXEL 	FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL
	@ oSize:GetDimension("CABECALHO","LININI"), oSize:GetDimension("CABECALHO","COLINI") SAY 'Vcto Real'  Of oDlg PIXEL
	@ oSize:GetDimension("CABECALHO","LININI"), (oSize:GetDimension("CABECALHO","COLINI")+50) MSGET oCod  VAR dDataReal   SIZE 070, 010 OF oDlg COLORS 0, 16777215 PIXEL  HASBUTTON

	dDataReal := dDataAtual

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, {||   iif(VrfDatas(dDataReal,dBaixa, dEmissao, dVencto) ,oDlg:End(),   ) }, {|| dDataReal := ctod(''), oDlg:End()},,aButtons)

return dDataReal

/*/{Protheus.doc} VrfDatas
Perguntas/parametros para alterar vencto real do Mutuo

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/                
Static function VrfDatas (dDataReal, dBaixa, dEmissao, dVencto)
	Local lRet := .T.

	If Empty(dDataReal) .And. lRet //prefixos
		Alert ("Informe a Nova Data de Vencimento Real!")
		lRet := .F.
	EndIf

	If !Empty(dBaixa) .And. lRet
		Alert ("Título já sofreu alguma operação de Baixa no sistema. Impossível modificar a Data de vencimento real à partir de agora!")
		lRet := .T.
		lBaixado := .T.
	EndIf

	If dDataReal < dEmissao .And. lRet
		Alert ("A Nova Data de Vencimento Real deve ser igual ou superior a Data de Emissão deste título ("+cEmissao+")!")
		lRet := .F.
	EndIf

	If dDataReal < dVencto .And. lRet
		Alert ("A Nova Data de Vencimento Real deve ser igual ou superior a Data de Vencimento deste título ("+cVencto+")!")
		lRet := .F.
	EndIf

return lRet




/*
VerxCusto()
Conndicao necessaria para pega a conta a partir do B1_XCONTA2 na geracao da nota
@author 
@since 09/12/2014
@version 1.0
*/

Static Function VerxCusto()
	Local cPsqAlias
	Local cMeuOldFilAnt := cFilAnt
	Local cCgc := ''
	local cVerXCusto := ''

	SM0->(DBgotop())

	While SM0->(!Eof())

		If AllTrim(SM0->M0_CODFIL) == AllTrim(cFIlAnt)
			cCgc := SM0->M0_CGC
			exit
		EndIf

		SM0->(DbSKip())
	End


	SM0->(DBgotop())

	While SM0->(!Eof())

		If AllTrim(SM0->M0_CODFIL) == AllTrim(cMeuOldFilAnt)//reposiciona na filial na qual SM) estava
			exit
		EndIf

		SM0->(DbSKip())
	End

	Dbselectarea('CTT')
	DbSetOrder(1)

	If CTT->(FieldPos("CTT_XEMPFI")) > 0 //.And.   SE2->(FieldPos("E2_XCNPJ")) > 0


		cPsqAlias := GetNextAlias()
		BeginSql Alias cPsqAlias
		
		SELECT CTT.CTT_XCUSTO
		       FROM %table:CTT% CTT
		       WHERE CTT.%NotDel% AND
		       		 CTT.CTT_FILIAL     = %xFilial:CTT%  //cfilant ja esta posicionado de acordo neste ponto
		             AND CTT.CTT_XEMPFI   = %Exp:(cCgc)% 
		                                            
		EndSql

		If (cPsqAlias)->(!Eof())
			cVerXCusto := AllTrim((cPsqAlias)->(CTT_XCUSTO))//conversei com ANtonio ele disse para pegar deste campo que é um caracter de uma unica posicao
		EndIf

		(cPsqAlias)->(DbCLoseArea())
	EndIf

return cVerXCusto




Static function ClicouOk()
	Local lClicouOkFINA040 := .T.
	Local cE1Alias := GetNextAlias()

	BeginSql Alias cE1Alias

SELECT SE1.*
       
       FROM %table:SE1% SE1
       WHERE SE1.E1_FILIAL     = %xFilial:SE1%  
             AND SE1.%NotDel%
             AND SE1.E1_NUM     = %Exp:(SE1->E1_NUM    )%                               
       		 AND SE1.E1_PREFIXO = %Exp:(SE1->E1_PREFIXO)%                               
       		 AND SE1.E1_TIPO    = %Exp:(SE1->E1_TIPO   )%                               
       		 AND SE1.E1_PARCELA = %Exp:(SE1->E1_PARCELA)%                               
       		 AND SE1.E1_CLIENTE = %Exp:(SE1->E1_CLIENTE)%                               
       		 AND SE1.E1_LOJA    = %Exp:(SE1->E1_LOJA   )%                               
	EndSql

	If (cE1Alias)->(!Eof()) .ANd. ;
			AllTrim((cE1Alias)->(E1_NUM))     == AllTrim((SE1->E1_NUM    )) .ANd. ;
			AllTrim((cE1Alias)->(E1_PREFIXO)) == AllTrim((SE1->E1_PREFIXO)) .ANd. ;
			AllTrim((cE1Alias)->(E1_TIPO))    == AllTrim((SE1->E1_TIPO   )) .ANd. ;
			AllTrim((cE1Alias)->(E1_PARCELA)) == AllTrim((SE1->E1_PARCELA)) .ANd. ;
			AllTrim((cE1Alias)->(E1_CLIENTE)) == AllTrim((SE1->E1_CLIENTE)) .ANd. ;
			AllTrim((cE1Alias)->(E1_LOJA))    == AllTrim((SE1->E1_LOJA   ))

		lClicouOkFINA040 := .F.
	EndIf

	(cE1Alias)->(DbCloseArea())

return lClicouOkFINA040
