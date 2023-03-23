#Include 'Protheus.ch'
#Include 'RestFul.CH'
#Include 'TbiConn.ch'
#include "tryexception.ch"

#Define CODIGO		1
#Define SAFRA		2
#Define CALCULADO	3
#Define CARTEIRA	4
#Define PEDLIB		5
#Define SLDDUP		6
#Define GESTOR		7
#Define CROPLINE	8
#Define SLDATRASO   9
#Define SLDCLEAN    10
#Define SLDDISPO    11
#Define MOEDA  		12
#Define TEMPORARIO	13


#Define AP_GRUPOVENDA	1
#Define AP_SAFRA		2	
#Define AP_APROVA		3
#Define AP_TEMPORARIO	4
#Define AP_MOTIVOTEMP	5
#Define AP_MOTIVOCANC	6
#Define AP_PREVLIBER	7
#Define AP_ACAO			8

/*
=====================================================================================
|Programa: RFLUW011    |Autor: Wanderley R. Neto                   |Data: 21/01/2020|
=====================================================================================
|Descri��o: Integra��o das aprova��es de cr�dito pendentes                          |
|                                                                                   |
| - GET:  Obtem a listagem das aprova��es pendentes de um determinado gestor        |
| - POST: Atualiza os calendarios Safra/Grupo com as aprova��es dos gestores        |
=====================================================================================
|CONTROLE DE ALTERA��ES:                                                            |
=====================================================================================
|Programador          |Data       |Descri��o                                        |
=====================================================================================
|                     |           |                                                 |
=====================================================================================
*/
User Function RFLUW011();Return Nil

WsRestFul AprovCredito Description 'Exibe os limites de cr�dito pendentes de aprova��o'

	WsData gestor	As String
	WsMethod GET Description "Retorna uma listagem das aprova��es de cr�dito pendentes de um determinado Gestor de campo" WSSYNTAX "/AprovCredito || /AprovCredito/{}"
	WsMethod POST Description "Atualiza os calend�rios que possuem limites bloqueados com as aprova��es pendentes ou limite tempor�rio informado pelo gestor de campo." WSSYNTAX "/AprovCredito || /AprovCredito/{}"

End WsrestFul

/*
=====================================================================================
|Programa: RFLUW011    |Autor: Wanderley R. Neto                   |Data: 22/01/2020|
=====================================================================================
|Descri��o: Obtem a listagem das aprova��es pendentes de um determinado gestor      |
|                                                                                   |
=====================================================================================
*/
WsMethod GET WsReceive gestor WsService AprovCredito

	Local cGestor	:= ::gestor
	Local aAprovPen	:= {}
	Local nAprov	:= 0
	Local oListaAp	:= ListaAprovCred():New()
	Local cRet		:= ''

	Reset Environment
	// RPCSetType(3)  //Nao consome licensas
	Prepare Environment Empresa '01' Filial '01'
	
	::SetContentType("application/json")

	// -------------------------------------------------------
	// Validando se gestor foi informado
	// -------------------------------------------------------
	// If Empty(cGestor)
	// 	SetRestFault(500,EncodeUtf8('Gestor n�o informado.'))
	// 	Reset Environment
	// 	Return .F.
	// EndIf


	// -------------------------------------------------------
	// Obtem as aprova��es do gestor
	// -------------------------------------------------------
	// StartJ
	aAprovPen := BuscaAprov(cGestor)

	// Monta lista de aprova��es e constroe retorno em Json
	For nAProv := 1 To Len(aAprovPen)
		
		oListaAp:Adicionar(;
			aAprovPen[nAprov,CODIGO ],;
			aAprovPen[nAprov,SAFRA ],;
			aAprovPen[nAprov,CALCULADO ],;
			aAprovPen[nAprov,CARTEIRA ],;
			aAprovPen[nAprov,PEDLIB ],;
			aAprovPen[nAprov,SLDDUP ],;
			aAprovPen[nAprov,GESTOR ],;
			aAprovPen[nAprov,CROPLINE ],;
			aAprovPen[nAprov,SLDCLEAN ],;
			aAprovPen[nAprov,SLDDISPO ],;
			aAprovPen[nAprov,SLDATRASO ],;
			aAprovPen[nAprov,MOEDA ],;
			aAprovPen[nAprov,TEMPORARIO ];
		)

	Next nAProv


	cRet := FWJsonSerialize(oListaAp)
	Conout('RFLUW011'+' - '+DToC(dDataBase)+' '+Time()+'| Realizada consulta de Aprova��es Pendentes.')
	Reset Environment
	::SetResponse(cRet)

Return .T.

/*
=====================================================================================
|Programa: RFLUW011    |Autor: Wanderley R. Neto                   |Data: 22/01/2020|
=====================================================================================
|Descri��o: Atualiza as aprova��es pendentes com as aprova��es e limites temp infor-|
| mados pelo gestor de campo.                                                       |
=====================================================================================
*/
WsMethod POST WsService AprovCredito

	Local cJsonPost	:= Self:GetContent()		// Recupera o JSON enviado via POST
	Local oJson		:= Nil

	Local aDados	:= {}
	Local cMsg		:= ''
	Local lRet		:= .T.
	Local oError	:= Nil
	// Local bError	:= { |oError| (	SetRestFault(500,'Erro na rotina de integra��o de aprova��es de cr�dito via Fluig.'),;
	// 								RpcClearEnv(),;
	// 								lRet :=  .F.) }


	Reset Environment
	// RPCSetType(3)  //Nao consome licensas
	Prepare Environment Empresa '01' Filial '01' TABLES ',ZZH,ZZ2,ZZI,' MODULO 'FIN'

	If !Empty(cJsonPost)

		FwJSONDeserialize(cJsonPost,@oJson)
		
		TRYEXCEPTION //USING bError

			// Obtem array de aprova��es
			aDados := ObtemDados(oJson:params:aprovacoes)
		
		CATCHEXCEPTION USING oError

			SetRestFault(500,EncodeUtf8('Erro no obten��o dos dados.'))
			Reset Environment
			Return .F.

		ENDEXCEPTION

		// -------------------------------------------------------------------------
		// Grava as aprova��es obtidas
		// -------------------------------------------------------------------------
		If !Empty(aDados)

			Begin Transaction
				TRYEXCEPTION // USING bError

					AprovaCred(aDados)
				
				CATCHEXCEPTION USING oError

					DisarmTransaction()
					SetRestFault(500,EncodeUtf8('Erro na grava��o da aprova��o.'))
					Reset Environment
					Return .F.

				ENDEXCEPTION
			End Transaction
		
		EndIf
	EndIf

	Reset Environment
	
Return lRet


/*
=====================================================================================
|Programa: RFLUW011    |Autor: Wanderley R. Neto                   |Data: 21/01/2020|
=====================================================================================
|Descri��o: Busca aprova��es pendente do gestor informado                           |
|                                                                                   |
=====================================================================================
*/
Static Function BuscaAprov(cGestor)

	Local cQuery		:= ''
	Local cAliasAp		:= GetNextAlias()
	Local aAprovacoes	:= {}

	Default cGestor := ''
	
	cQuery += CRLF + " select ZZH_GRPVEN, ZZH_SAFRA, ZZH_DISCAL,ZZH_CARTEI, ZZH_SLDPED, ZZH_SLDDUP,A1_XGESTOR,A1_VEND, ZZH_SLDATS "
	cQuery += CRLF + "        , ZZH_LIMCLE, ZZH_LIMDIS, ZZH_MOEDLC, ZZH_LIMMAN "
	cQuery += CRLF + "   from "+RetSqlName('ZZH')+" Z"
	cQuery += CRLF + "  inner join "+RetSqlName('ACY')+" A"
	cQuery += CRLF + "     on ACY_GRPVEN = ZZH_GRPVEN"
	cQuery += CRLF + "  inner join "+RetSqlName('SA1')+" S"
	cQuery += CRLF + "     on A1_COD = ACY_XCODRP"
	cQuery += CRLF + "    and A1_LOJA = ACY_XLOJRP"
	cQuery += CRLF + "  where A.D_E_L_E_T_ = ''"
	cQuery += CRLF + "    and Z.D_E_L_E_T_ = ''"
	cQuery += CRLF + "    and S.D_E_L_E_T_ = ''"
	cQuery += CRLF + "    and (ZZH_STATUS = '2' or ZZH_STATUS = '' and ZZH_LIMPOT = 0 and ZZH_CARTEI > 0 )"
	If !Empty(cGestor)
		cQuery += CRLF + "    and A1_XGESTOR = '"+cGestor+"'"
	EndIF
	cQuery += CRLF + "  order by ZZH_GRPVEN, ZZH_SAFRA "
	
	//TODO: Resolver essa parada
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasAp,.F., .F.)
	
	While (cAliasAp)->( ! Eof() )

		AAdd(aAprovacoes, {;
							(cAliasAp)->ZZH_GRPVEN,;
							(cAliasAp)->ZZH_SAFRA,;
							(cAliasAp)->ZZH_DISCAL,;
							(cAliasAp)->ZZH_CARTEI,;
							(cAliasAp)->ZZH_SLDPED,;
							(cAliasAp)->ZZH_SLDDUP,;
							(cAliasAp)->A1_XGESTOR,;
							(cAliasAp)->A1_VEND=='000002',;
							(cAliasAp)->ZZH_SLDATS,;
							(cAliasAp)->ZZH_LIMCLE,;
							(iif((cAliasAp)->ZZH_LIMCLE > (cAliasAp)->ZZH_LIMDIS,(cAliasAp)->ZZH_LIMCLE,(cAliasAp)->ZZH_LIMDIS))-((cAliasAp)->ZZH_SLDPED+(cAliasAp)->ZZH_SLDDUP),;
							(cAliasAp)->ZZH_MOEDLC,;
							(cAliasAp)->ZZH_LIMMAN;
							})
	
		(cAliasAp)->( DbSkip() )
	End
	
	(cAliasAp)->(dbCloseArea())
	
	// TcUnlink(nConn)

Return aAprovacoes

/*
=====================================================================================
|Programa: RFLUW011    |Autor: Wanderley R. Neto                   |Data: 22/01/2020|
=====================================================================================
|Descri��o: Rotina que obtem os dados enviados pela integra��o                      |
|                                                                                   |
=====================================================================================
*/
Static Function ObtemDados(aParams)

// Local nPosAprov		:= AScan(aParams, {|x| lower(x[1]) == 'aprovacoes' })
// Local aAprov		:= ClassDataArr( aParams[nPosAprov] )
Local nAprov		:= 0
Local aDados		:= {}
// Local nPosGrpVen	:= 0
// Local nPosSafra		:= 0
// Local nPosAprov		:= 0
// Local nPosLimTemp	:= 0

If !Empty(aParams)

	For nAprov := 1 To Len(aParams)

		AAdd(aDados, {;
			aParams[nAprov]:grupovenda		,;	// AP_GRUPOVENDA
			aParams[nAprov]:safra			,;	// AP_SAFRA
			aParams[nAprov]:aprova			,;	// AP_APROVA
			aParams[nAprov]:limitetemp		,;	// AP_TEMPORARIO
			aParams[nAprov]:motivotemp  	,;  // AP_MOTIVOTEMP 
			aParams[nAprov]:motivo  		,;  // AP_MOTIVOCANC
			aParams[nAprov]:prevLiberacao  	,;  // AP_PREVLIBER
			aParams[nAprov]:acao  			;   // AP_ACAO
		})
		// AAdd(aDados, {;
		// 	aParams[nAprov,nPosGrpVen	],;	// AP_GRUPOVENDA
		// 	aParams[nAprov,nPosSafra		],;	// AP_SAFRA
		// 	aParams[nAprov,nPosAprov		],;	// AP_APROVA
		// 	aParams[nAprov,nPosLimTemp	];	// AP_TEMPORARIO
		// })

	Next nAprov

EndIf

Return aDados

/*
=====================================================================================
|Programa: RFLUW011    |Autor: Wanderley R. Neto                   |Data: 22/01/2020|
=====================================================================================
|Descri��o: Com base no array das aprova��es realiza aprova��es no Protheus dos     |
| limites bloqueados nos calendarios de cr�dito.                                    |
=====================================================================================
*/
Static Function AprovaCred(aDados)
Local lRet		:= .T.
Local nAp		:= 0
// Local cFilZZH			:= xFilial('ZZH')

// DbSelectArea('ZZH')
// ZZH->(DbSetOrder(1)) // Safra + Grupo Vend

For nAp := 1 To Len(aDados)

	// If ZZH->( DbSeek( cFilZZH + aDados[nAp, AP_SAFRA] + aDados[nAp, AP_GRUPOVENDA] ) )
		Conout('RFLUW011'+' - '+DToC(Date())+' '+Time()+'| Acessando rotina de aprova��o temporaria')
		// ----------------------------------------------------------------
		// Executa rotina de aprova��o manual do Calendario Safra/Grupo
		// ----------------------------------------------------------------
		u_FINA001A(aDados[nAp, AP_SAFRA], aDados[nAp, AP_GRUPOVENDA],Val(aDados[nAp, AP_TEMPORARIO]),aDados[nAp, AP_MOTIVOTEMP],aDados[nAp, AP_MOTIVOCANC],aDados[nAp, AP_PREVLIBER],aDados[nAp, AP_ACAO]) 
	
	// EndIf

Next nAp

Return lRet

Class ListaAprovCred

	Data aprovacoes

	MEthod New()Constructor
	Method Adicionar(cGrupo, cSafra, nLimCalc, nCarteira, nPedLib, nSldDup, cGestor, lCropline, nLimClean, nLimDispo, nSldVenc, nMoeda, nLimTemp) 

EndClass

Method New() Class ListaAprovCred

	::aprovacoes := {}

Return Self

Method Adicionar(cGrupo, cSafra, nLimCalc, nCarteira, nPedLib, nSldDup, cGestor, lCropline, nLimClean, nLimDispo, nSldVenc, nMoeda,nLimTemp) Class ListaAprovCred

	Local oDado := AprovCredito():New(cGrupo, cSafra, nLimCalc, nCarteira, nPedLib, nSldDup, cGestor, lCropline, nLimClean, nLimDispo, nSldVenc, nMoeda,nLimTemp)
	AAdd(::aprovacoes, oDado)

Return Self
