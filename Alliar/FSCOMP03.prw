#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FSCOMP03
Monta filtro de usuario para nao considerar SCs enviadas ao Bionexo 

@author claudiol
@since 29/12/2015
@version undefined

@type function
/*/
user function FSCOMP03(cOrigem,cFiltro,cAliAux)

Local 	xRet	:= Nil

Default cFiltro:= ""
Default cAliAux:= ""

If cOrigem=="MATA126" //Aglutinacao de SCs
	xRet:= cFiltro
	If !Empty(xRet)
		xRet+= " AND "
	EndIf
	//Retorna filtro
	xRet:= " C1_XSTABIO <> '1' AND C1_XNUMPDC = ' ' "

ElseIf cOrigem=="MATA110" //Manutencao de SCs
	//Valida o item da solicitacao de compra
	xRet:= FVerSC1()
	
	If !xRet .And. !IsInCallStack("A110Cancela")
		ApMsgStop("Solicitação possui item em processo Bionexo. Verifique!",".:Atenção:.")
	EndIf

ElseIf cOrigem=="MATA110C" //Manutencao de SCs
	//Limpa campos customizados na copia
	FLimSC1()

ElseIf cOrigem=="MATA235" //Eliminacao residuo de SCs
	//Valida o item da solicitacao de compra
	xRet:= !((cAliAux)->C1_XSTABIO == '1' .OR. !Empty((cAliAux)->C1_XNUMPDC))

ElseIf cOrigem=="MATA130" //Cotacao
	xRet:= cFiltro
	If !Empty(xRet)
		xRet+= " AND "
	EndIf
	//Retorna filtro
	xRet:= " C1_XSTABIO <> '1' AND C1_XNUMPDC = ' ' "

ElseIf cOrigem=="MATA130B" //Cotacao
	//Retorna filtro
	xRet:= {"",""}
	xRet[1]:= ".AND. C1_XSTABIO <> '1' .AND. C1_XNUMPDC = ' ' "
	xRet[2]:= " AND C1_XSTABIO <> '1' AND C1_XNUMPDC = ' ' "

ElseIf cOrigem=="MATA120" //Pedido de Compra
	//Retorna filtro
	xRet:= {"C1_XSTABIO <> '1' .AND. Empty(C1_XNUMPDC)", "C1_XSTABIO <> '1' AND C1_XNUMPDC = ' '"}

ElseIf cOrigem=="MATA120E" //Pedido de Compra - Exclusao
	//Limpa Flag no SC de origem
	FFlagSC1()

ElseIf cOrigem=="CNTA300" //Contratos
	//Valida o item da solicitacao de compra
	xRet:= !(SC1->C1_XSTABIO == '1' .OR. !Empty(SC1->C1_XNUMPDC))

EndIf
	
return(xRet)


/*/{Protheus.doc} FVerSC1
Avalia se algum item da solicitacao foi enviado ao Bionexo

@author claudiol
@since 30/12/2015
@version undefined

@type function
/*/
Static Function FVerSC1()

Local	aAreOld	:= {SC1->(GetArea()),GetArea()}
Local cSeek		:= ""
Local lRet		:= .T.

SC1->(DbSetOrder(1))
SC1->(MsSeek(cSeek:= xFilial("SC1")+cA110Num,.T.))
While SC1->(!Eof()) .And. cSeek==SC1->(C1_FILIAL+C1_NUM)

	If SC1->C1_XSTABIO == '1' .Or. !Empty(C1_XNUMPDC)
		lRet:= .F.
		Exit
	EndIf

	SC1->(dbSkip())
EndDo

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return(lRet)


/*/{Protheus.doc} FLimSC1
Limpa campos customizados na copia da solicitacao de compra

@author claudiol
@since 30/12/2015
@version undefined

@type function
/*/
Static Function FLimSC1()

Local nXi:= 0

For nXi:= 1 To Len(aCols)
	GdFieldPut("C1_XTIPPDC","",nXi)
	GdFieldPut("C1_XDATVEN",Ctod(""),nXi)
	GdFieldPut("C1_XHORVEN","",nXi)
	GdFieldPut("C1_XCONPAG","",nXi)
	GdFieldPut("C1_XOBS","",nXi)
	GdFieldPut("C1_XNUMPDC","",nXi)
	GdFieldPut("C1_XSTABIO","0",nXi)
	GdFieldPut("C1_XHISBIO","",nXi)
	GdFieldPut("C1_XNUMREQ","",nXi)
Next nXi

Return


/*/{Protheus.doc} FFlagSC1
Atualiza flag SC1
@author claudiol
@since 11/01/2016
@version undefined

@type function
/*/
Static Function FFlagSC1()

Local aRet		:= {}
Local aRecSC1	:= {}
Local lRet		:= .T.

BeginTran()

	SC1->(dbSetOrder(1))
	SC1->(dbSeek(xFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC)))
	If !SC1->(EOF()) .And. SC1->(C1_FILIAL+C1_NUM+C1_ITEM) == xFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC)
		//Busca SCs sem pedido para limpar flag
		U_FSBusSC1(SC7->C7_XNUMPDC, aRecSC1, Nil, .T.)
		If !Empty(aRecSC1)
			aRet:= {"0", Dtoc(Date())+" "+Time(), SC7->C7_XNUMPDC}
			U_FSGrvSC1("Y",aRecSC1,aRet)
		EndIf

		//Limpa flag o item do pedido de compra
		aRet:= {"0", Dtoc(Date())+" "+Time(), SC7->C7_XNUMPDC}
		U_FSGrvSC1("X",{SC1->(Recno())},aRet,Nil,"Pedido de Compra:" + SC7->C7_NUM +"/"+ SC7->C7_ITEM)
	EndIf

	If lRet
		//Efetiva transacao
		EndTran()
	Else
		//Disarmo a transação
		DisarmTransaction ()
	EndIF

MsUnlockAll()

Return
