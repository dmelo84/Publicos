#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} Classe01
Funcao Dummy para Compilacao

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
User Function Classe01()
Return Nil
//-------------------------------------------------------------------
/*{Protheus.doc} uTitPagar
Classe responsavel pela gravacao do Titulo a Pagar via MsExecAuto

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Class uTitPagar From uExecAuto
	Data cPrefixo										//Prefixo
	Data cTitulo										//Titulo
	Data cParcela										//Parcela
	Data cTipo											//Tipo
	Data cFornece										//Fornecedor
	Data cLoja											//Loja do Fornecedor
	Data dVencto										//Vencimento
	Data dVencRea										//Vencimento Real
	Data cBanco										//Banco
	Data cAgencia										//Agencia
	Data cConta										//Conta
	Data cCheque										//Cheque
	Data aRateioCC									//Rateio por Centro de Custo
	Data aRatTemp										//Array Temporario para o Rateio
	Data nVlrTit										//Valor do Titulo
	Data cIdSenior										//ID Integracao Senior

	Method New()										//Inicializa o Objeto
	Method AddValues(cCampo, xValor, xValid)		//Armazena os Campos e Valores do Titulo a Pagar
	Method AddRatCC(cCampo, xValor, bValid)		//Inclusao dos Dados para o Rateio por Centro de Custo
	Method SetRatCC()									//Armazena os Valores do Item do Rateio e Reinicializa o Array Temporario.
	Method Gravacao(nOpcao)							//Gravacao do Titulo
	Method GetPrefixo()								//Retorna o Prefixo do Titulo
	Method GetTitulo()								//Retorna o Numero do Titulo
	Method GetParcela()								//Retorna o Parcela do Titulo
	Method GetTipo()									//Retorna o Tipo do Titulo
	Method GetFornece()								//Retorna o Fornecedor
	Method GetLoja()									//Retorna a Loja do Fornecedor
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Inicializa o Objeto

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method New() Class uTitPagar
	_Super:New()

	::aTabelas		:= {"SE2"}
	::cPrefixo		:= ""
	::cTitulo		:= ""
	::cParcela		:= Space(TamSX3("E2_PARCELA")[01])
	::cTipo			:= ""
	::cFornece		:= ""
	::cLoja			:= ""
	::cFileLog		:= "FINA050.LOG"
	::dVencto		:= CtoD("")
	::dVencRea		:= CtoD("")
	::cBanco		:= ""
	::cAgencia		:= ""
	::cConta		:= ""
	::cCheque		:= ""
	::aRateioCC	:= {}
	::aRatTemp		:= {}
	::nVlrTit		:= 0
	::cIDSenior		:= ""
Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} AddValues
Armazena os Campos para Gravacao

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method AddValues(cCampo, xValor, xValid) Class uTitPagar
	Local lAdiciona := .T.

	//Default xValid := NIL

	Do Case
	Case AllTrim(cCampo) == "E2_NUM"
		::cTitulo	:= xValor
	Case AllTrim(cCampo) == "E2_EMISSAO"
		::dEmissao	:= xValor
	Case AllTrim(cCampo) == "E2_PREFIXO"
		::cPrefixo	:= xValor
	Case AllTrim(cCampo) == "E2_PARCELA"
		::cParcela	:= xValor
	Case AllTrim(cCampo) == "E2_TIPO"
		::cTipo		:= xValor
	Case AllTrim(cCampo) == "E2_FORNECE"
		::cFornece	:= xValor
	Case AllTrim(cCampo) == "E2_LOJA"
		::cLoja		:= xValor
	Case AllTrim(cCampo) == "E2_VENCTO"
		::dVencto	:= xValor
	Case AllTrim(cCampo) == "E2_VENCREA"
		::dVencRea	:= xValor
	Case AllTrim(cCampo) == "E2_VALOR"
		::nVlrTit 	:= xValor
	Case AllTrim(cCampo) == "AUTBANCO"
		::cBanco	:= xValor
	Case AllTrim(cCampo) == "AUTAGENCIA"
		::cAgencia	:= xValor
	Case AllTrim(cCampo) == "AUTCONTA"
		::cConta	:= xValor
	Case AllTrim(cCampo) == "AUTCHEQUE"
		::cCheque	:= xValor
	Case AllTrim(cCampo) == "E2_XIDSEN"
		::cIdSenior := xValor
	EndCase

	_Super:AddValues(cCampo, xValor, xValid)

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} AddRatCC
Inclusao dos Dados para o Rateio por Centro de Custo

@author Guilherme Santos
@since 18/03/2016
@version P12
*/
//-------------------------------------------------------------------
Method AddRatCC(cCampo, xValor, bValid) Class uTitPagar
	//Default xValid	:= NIL

	Aadd(::aRatTemp, {cCampo, xValor, bValid})
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} SetRatCC
Armazena os Valores do Item do Rateio e Reinicializa o Array Temporario.

@author Guilherme Santos
@since 18/03/2016
@version P12
*/
//-------------------------------------------------------------------
Method SetRatCC() Class uTitPagar
	
	Aadd(::aRateioCC, ::aRatTemp)
	::aRatTemp := {}
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} Gravacao
Gravacao do Titulo a Pagar

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method Gravacao(nOpcao) Class uTitPagar
	Local dDataBackup		:= dDataBase
	Local lReserva		:= .F.
	Local lRetorno		:= .T.
	Local nI

	Private lMsErroAuto	:= .F.

	::SetEnv(1, "FIN")

	If !Empty(::dEmissao)
		dDataBase	:= ::dEmissao
	EndIf

	If lRetorno .AND. !Empty(::cIDSenior)
		DbSelectArea("SE2")
		DbOrderNickName("E2XIDSEN")		//E2_XIDSEN		//Nao inclui a Filial pois o ID Senior e unico para todas as empresas

		If nOpcao == 3
			If SE2->(DbSeek(::cIDSenior))
				::cMensagem	:= "ID Senior já incluido."
				lRetorno	:= .F.
			EndIf 
		ElseIf nOpcao == 5
			If SE2->(DbSeek(::cIDSenior))
				::AddValues("E2_PREFIXO"	, SE2->E2_PREFIXO		, NIL)
				::AddValues("E2_NUM"		, SE2->E2_NUM			, NIL)
				::AddValues("E2_PARCELA"	, SE2->E2_PARCELA		, NIL)
				::AddValues("E2_TIPO"	, SE2->E2_TIPO		, NIL)
				::AddValues("E2_FORNECE"	, SE2->E2_FORNECE		, NIL)
				::AddValues("E2_LOJA"	, SE2->E2_LOJA		, NIL)
			Else
				::cMensagem	:= "ID Senior não localizado."
				lRetorno	:= .F.
			EndIf 
		EndIf
	EndIf

	If lRetorno

    	DbSelectArea("SE2")
    	DbSetOrder(1)	//E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA
    
    	If nOpcao == 3
    		If Empty(::cTitulo)
    			::cTitulo	:= GetSx8Num("SE2", "E2_NUM")
    
    			While SE2->(DbSeek(xFilial("SE2") + ::cPrefixo + ::cTitulo + ::cParcela + ::cTipo + ::cFornece + ::cLoja))
    				ConfirmSX8()
    				
    				::cTitulo := GetSx8Num("SE2", "E2_NUM")
    			End
    
    			lReserva	:= .T.
    			::AddValues("E2_NUM", ::cTitulo)
    		EndIf
    	Else
    		If Empty(::cTitulo)
    			lRetorno		:= .F.
    			::cMensagem		:= "Numero do Titulo não informado."
    		Else
    			If !SE2->(DbSeek(xFilial("SE2") + ::cPrefixo + ::cTitulo + ::cParcela + ::cTipo + ::cFornece + ::cLoja))
    				lRetorno 	:= .F.
    				::cMensagem	:= "Titulo " + ::cTitulo + " não cadastrado."
    			EndIf
    		EndIf
    	EndIf
	EndIf

	If lRetorno .AND. (Empty(::dVencto) .OR. Empty(::dEmissao))
		lRetorno 	:= .F.
		::cMensagem := "Verifique as datas de Emissao e Vencimento do Titulo, pois uma destas datas nao foi informada."
	EndIf		

	If lRetorno .AND. ::cTipo $ MVPAGANT
		If Empty(::cBanco) .OR. Empty(::cAgencia) .OR. Empty(::cConta)
			lRetorno	:= .F.
			::cMensagem	:= "Banco, Agencia ou Conta do Pagamento Antecipado nao informados."
		EndIf
	EndIf

	If lRetorno .AND. !Empty(::aRateioCC)
		::AddValues("E2_RATEIO", "S")
	EndIf

	If lRetorno
	
		//Gravacao do Titulo a Pagar
		MSExecAuto({|a, b, c, d, e, f, g, h| FINA050(a, b, c, d, e, f, g, h)}, ::aValues, nOpcao, nOpcao, NIL, NIL, NIL, NIL, ::aRateioCC)

		If lMsErroAuto
			lRetorno := .F.

			If lReserva
				RollBackSx8()
			EndIf
	
			If ::lExibeTela
				MostraErro()
			EndIf
			
			If ::lGravaLog
				::cMensagem := MostraErro(::cPathLog, ::cFileLog) + CRLF
			EndIf
		Else
			If lReserva
				ConfirmSx8()
			EndIf
		EndIf
	EndIf

	::SetEnv(2, "FIN")

	dDataBase := dDataBackup

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} GetPrefixo
Retorna o Prefixo do Titulo

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method GetPrefixo() Class uTitPagar
Return ::cPrefixo
//-------------------------------------------------------------------
/*{Protheus.doc} GetTitulo
Retorna o Numero do Titulo

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method GetTitulo() Class uTitPagar
Return ::cTitulo
//-------------------------------------------------------------------
/*{Protheus.doc} GetParcela
Retorna a Parcela do Titulo

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method GetParcela() Class uTitPagar
Return ::cParcela
//-------------------------------------------------------------------
/*{Protheus.doc} GetTipo
Retorna o Tipo do Titulo

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method GetTipo() Class uTitPagar
Return ::cTipo
//-------------------------------------------------------------------
/*{Protheus.doc} GetFornece
Retorna o Fornecedor do Titulo

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method GetFornece() Class uTitPagar
Return ::cFornece
//-------------------------------------------------------------------
/*{Protheus.doc} GetLoja
Retorna a Loja do Fornecedor

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method GetLoja() Class uTitPagar
Return ::cLoja
