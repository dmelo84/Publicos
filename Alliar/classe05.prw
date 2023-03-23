#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} Classe05
Funcao Generica para Compilacao

@author Guilherme Santos
@since 02/03/2016
@version P12
*/
//-------------------------------------------------------------------
User Function Classe05()
Return Nil
//-------------------------------------------------------------------
/*{Protheus.doc} uBaixaPreReq
Classe para Gravacao das Solicitacoes ao Armazem via ExecAuto

@author Guilherme Santos
@since 02/03/2016
@version P12
*/
//-------------------------------------------------------------------
Class uBaixaPreReq From uExecAuto
	Data cNumero										//Numero da Pre Requisicao
	Data aDadosSCP									//Dados da Solicitacao ao Armazem
	Data aDadosSD3									//Dados do Movimento Interno

	Method New()										//Inicializa o Objeto
	Method AddValues()								//Metodo para Inclusao dos Valores para Gravacao
	Method Gravacao()									//Gravacao da Pre Requisicao via ExecAuto
	Method GetNumero()								//Retorna o Numero da Pre Requisicao
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Inicializa o Objeto

@author Guilherme Santos
@since 02/03/2016
@version P12
*/
//-------------------------------------------------------------------
Method New() Class uBaixaPreReq
	_Super:New()

	::aTabelas		:= {"SCP", "SCQ", "SD3"}
	::aDadosSCP	:= {}
	::aDadosSD3	:= {}
	::cNumero		:= ""
	::cFileLog		:= "MATA185.LOG"
Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} AddValues
Adiciona os Dados do Cabecalho da Pre Requisicao SCP - Tabela SCP

@author Guilherme Santos
@since 02/03/2016
@version P12
*/
//-------------------------------------------------------------------
Method AddValues(cCampo, xValor, xValid) Class uBaixaPreReq
	Local nPosCpo		:= Ascan(::aValues, {|x| AllTrim(x[01]) == AllTrim(cCampo)})
	Default xValid	:= NIL

	If cCampo == "CP_NUM"
		::cNumero	:= xValor
	EndIf

	If AllTrim(cCampo) == "EMPRESA"
		::cEmpGrv := xValor
	Else
		If "_FILIAL" $ AllTrim(cCampo)
			::cFilGrv := xValor
		EndIf

		If nPosCpo == 0
			If cCampo $ "CP_"
				Aadd(::aDadosSCP, {cCampo		,xValor		,xValid})
			ElseIf cCampo $ "D3_"
				Aadd(::aDadosSD3, {cCampo		,xValor		,xValid})
			EndIf
		Else
			If cCampo $ "CP_"
				::aDadosSCP[nPosCpo][02] := xValor
			ElseIf cCampo $ "D3_"
				::aDadosSD3[nPosCpo][02] := xValor
			EndIf
		EndIf
	EndIf
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} Gravacao
Gravacao da Pre Requisicao - Deve ser Executado uma vez para cada
item da Solicitacao ao Armazem

@author Guilherme Santos
@since 02/03/2016
@version P12
*/
//-------------------------------------------------------------------
Method Gravacao(nOpcao) Class uBaixaPreReq
	Local lRetorno 		:= .T.
	Private lMsErroAuto	:= .F.

	::SetEnv(1, "EST")

	DbSelectArea("SCP")
	DbSetOrder(1)		//CP_FILIAL, CP_NUM

	If !SCP->(DbSeek(xFilial("SCP") + ::cNumero))
		::cMensagem	:= "Solicitação não localizada."
		lRetorno 		:= .F.
	EndIf

	If lRetorno
		//Gravacao do Titulo a Pagar
		MSExecAuto({|a, b, c| MATA185(a, b, c)}, ::aDadosSCP, ::aDadosSD3, nOpcao)

		If lMsErroAuto
			lRetorno := .F.

			If ::lExibeTela
				MostraErro()
			EndIf
			
			If ::lGravaLog
				::cMensagem := MostraErro(::cPathLog, ::cFileLog)
			EndIf
		EndIf
	EndIf

	::SetEnv(2, "EST")

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} GetNumero
Retorna o Numero da Pre Requisicao

@author Guilherme Santos
@since 02/03/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetNumero() Class uBaixaPreReq
Return ::cNumero
