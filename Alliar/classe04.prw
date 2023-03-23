#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} Classe04
Funcao Generica para Compilacao

@author Guilherme Santos
@since 19/02/2016
@version P12
*/
//-------------------------------------------------------------------
User Function Classe04()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} uPreReq
Gravacao da Pre Requisicao a partir da Solicitacao ao Armazem

@author Guilherme Santos
@since 22/02/2016
@version P12
*/
//-------------------------------------------------------------------
Class uPreReq
	Data cMsgErro
	Data cNumSol
	Data cNumReq

	Method New()
	Method Gravacao(cNumSol)
	Method Exclusao(cNumSol)
	Method GetMensagem()
	Method GetNumero()
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Inicializacao do Objeto

@author Guilherme Santos
@since 22/02/2016
@version P12
*/
//-------------------------------------------------------------------
Method New() Class uPreReq
	::cMsgErro	:= ""
	::cNumSol	:= ""
	::cNumReq	:= ""
Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} Gravacao
Gravacao da Pre Requisicao

@author Guilherme Santos
@since 22/02/2016
@version P12
*/
//-------------------------------------------------------------------
Method Gravacao(cNumSol) Class uPreReq
	Local aRecSCP		:= {}
	Local nAglutSC	:= 0
	Local nI			:= 0
	Local lRateio		:= .F.
	Local lRetorno	:= .T.

	::cNumSol 			:= cNumSol

	DbSelectArea("SCP")
	DbSetOrder(1)		//CP_FILIAL, CP_NUM, CP_ITEM, CP_EMISSAO
	
	If SCP->(DbSeek(xFilial("SCP") + ::cNumSol))
		If Empty(SCP->CP_PREREQU)  .AND. SCP->CP_STATSA <> "B"
			//Pergunte da MATA106
			Pergunte("MTA106", .F.)
		
			//Atribuicao do Numero da Solicitacao para Utilizacao do Ponto de Entrada MT106QRY
			U_M106SETN(::cNumSol)
		
			//Gravacao da Pre Requisicao
			MaSaPreReq(	.F.,;					//Determina se esta executando a Partir da MarkBrowse
							MV_PAR01 == 2,;		//MV_PAR01 -> Considera Data               --> 1 = Necessidade / 2=Emissao
							{|| .T.},;				//bFiltro  -> Filtra os Registros para Geracao da Pre-Requisicao
							MV_PAR02 == 1,;		//MV_PAR02 -> Cons. Sld Prev Entr          --> 1 = Sim / 2 = Nao
							MV_PAR03 == 2,;		//MV_PAR03 -> Gera Solic. Compras          --> 1 = Sim / 2 = Nao
							MV_PAR04 == 2,;		//MV_PAR04 -> Cons. Armazem do SA          --> 1 = Sim / 2 = Nao
							"  ",;					//MV_PAR05 -> Saldo do Armazem             --> B1_LOCPAD
							"ZZ",;					//MV_PAR06 -> Saldo Ate o Armazem          --> B1_LOCPAD
							MV_PAR07 == 1,;		//MV_PAR07 -> Considera Lote Economico     --> 1 = Sim / 2 = Nao
							MV_PAR08 == 1,;		//MV_PAR08 -> Avalia Empenhos para OP      --> 1 = Sim / 2 = Nao
							nAglutSC,;				//Determina se Aglutina as Solicitacoes de Compras --> 0 = Nao / 1 = Sim
							.T.,;					//Determina se esta sendo executado via Rotina Automatica
							MV_PAR10 == 1,;		//MV_PAR10 -> Subtrai estoque de segurança --> Sim / Nao
							@aRecSCP,;				//Retorna Array com os Recnos dos Registros Processados
							lRateio)				//Determina se a Solicitacao ao Armazem tem Rateio
	
			If Empty(aRecSCP)
				//Se Estiver Vazio, não tem saldo para atender
				::cMsgErro	:= "Produto não possui saldo para Reserva."
				//lRetorno 	:= .F.
			Else
				::cNumReq := SCQ->CQ_NUM
			EndIf
		EndIf
	Else
		::cMsgErro	:= "Solicitação ao Armazem não Localizada."
		lRetorno	:= .F.
	EndIf
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} Exclusao
Exclusao da Pre-Requisicao

@author Guilherme Santos
@since 26/04/2016
@version P12
*/
//-------------------------------------------------------------------
Method Exclusao(cNumSol) Class uPreReq
	Local aArea		:= GetArea()
	Local aAreaSCP	:= {}
	Local aDadosSCP	:= {}
	Local aDadosSD3	:= {}
	Local aTempSD3	:= {}
	Local nI			:= 1

	Local lRetorno 	:= .T.

	Private lMsErroAuto	:= .F.

	DbSelectArea("SCP")
	DbSetOrder(1)
	
	If SCP->(DbSeek(xFilial("SCP") + cNumSol))
		While !SCP->(Eof()) .AND. lRetorno .AND. xFilial("SCP") + cNumSol == SCP->CP_FILIAL + SCP->CP_NUM
			If lRetorno
				aAreaSCP	:= SCP->(GetArea())
	
				aDadosSCP	:= {}
		
				Aadd(aDadosSCP, {"CP_FILIAL"	, SCP->CP_FILIAL	, NIL})
				Aadd(aDadosSCP, {"CP_NUM"		, SCP->CP_NUM		, NIL})
				Aadd(aDadosSCP, {"CP_ITEM"		, SCP->CP_ITEM	, NIL})
				Aadd(aDadosSCP, {"CP_XIDFLG"	, SCP->CP_XIDFLG	, NIL})
	
				aDadosSD3	:= {}
	
				Aadd(aDadosSD3, {"D3_FILIAL"	, SCP->CP_FILIAL, 							NIL})
				Aadd(aDadosSD3, {"D3_TM"			, SuperGetMV("AL_TMPRERQ", NIL, "501"),	NIL})
				Aadd(aDadosSD3, {"D3_COD"		, SCP->CP_PRODUTO, 							NIL})
				Aadd(aDadosSD3, {"D3_LOCAL"		, SCP->CP_LOCAL, 								NIL})
				Aadd(aDadosSD3, {"D3_QUANT"		, SCP->CP_QUANT, 								NIL})
				Aadd(aDadosSD3, {"D3_EMISSAO"	, SCP->CP_EMISSAO, 							NIL})
	
				//Exclui a Pre Requisicao
				MSExecAuto({|a, b, c| MATA185(a, b, c)}, aDadosSCP, aDadosSD3, 5)
		
				If lMsErroAuto
					lRetorno 	:= .F.
					::cMsgErro	:= MostraErro("\LOGS\", "MATA185.LOG")
					RestArea(aAreaSCP)
				Else
					RestArea(aAreaSCP)
				EndIf
			EndIf

			SCP->(DbSkip())
		End
	Else
		lRetorno 		:= .F.
		::cMsgErro		:= "Solicitação não localizada."
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} GetMensagem
Retorna a Mensagem de Erro

@author Guilherme Santos
@since 22/02/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetMensagem() Class uPreReq
Return ::cMsgErro
//-------------------------------------------------------------------
/*{Protheus.doc} GetNumero
Retorna o Numero da Pre Requisicao

@author Guilherme Santos
@since 19/04/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetNumero() Class uPreReq
Return ::cNumReq
