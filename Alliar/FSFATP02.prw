#Include 'Protheus.ch'

/*/{Protheus.doc} FSFATP02
Rotina responsável pelo tratamento dos dados do Pedido de Venda (Pleres) para exclusão.

@type function
@author Gustavo Barcelos
@since 12/01/2016
@version 1.0

/*/

User Function FSFATP02(cXml, aRet)

	Local aEstorno 		:= {}
	Local aPedido 		:= {}
	Local aCliente 		:= {}
	Local aPagam 			:= {} 
	Local cMsg				:= "Pedido de Venda excluído com sucesso!"
	Local cFilAtu			:= ""
	Local cFilAtu			:= ""
	Local cEmpAtu			:= ""
	Local cCnpjFil		:= SubStr(cXml, ( AT("<CNPJFilial>", cXml) + 12 ), at("</CNPJFilial>", cXml) - ( AT("<CNPJFilial>", cXml) + 12 ) ) 
	Local cPedido			:= ""
	Local lCli			:= .T.

//-------------------------------------------------------------------------------	

	//Carrega filial de acordo com CNPJ
	
	U_FSSetFil(cCnpjFil, @cEmpAtu, @cFilAtu )
	
	If cFilAtu == ""
		aAdd(aRet, -3)
		aAdd(aRet, "Não foi possível carregar a informação da filial!")
		Return
	EndIf
	
//-------------------------------------------------------------------------------

	//Inicia ambiente baseado na filial selecionada
	
	RpcSetType(3)
	RpcSetEnv(cEmpAtu, cFilAtu)
	
//-------------------------------------------------------------------------------

	//Carrega dados do XML e grava em arrays
	If !( U_FSXML2ARR(2, cXml, @cFilAtu, @aEstorno, @aPedido, , , , @cMsg) )
		aAdd(aRet, -1)
		aAdd(aRet, cMsg)
//		RpcClearEnv()
		Return
	EndIf
	
//-------------------------------------------------------------------------------

	//Testa usuário e senha
	
	If !U_FVerPwd(aEstorno[aScan(aEstorno, {|X| X[1] == "LOGIN"})][2], aEstorno[aScan(aEstorno, {|X| X[1] == "SENHA"})][2])
		aAdd(aRet, -2)
		aAdd(aRet, "Usuário inexistente ou senha incorreta!")
//		RpcClearEnv()
		Return
	EndIF

//-------------------------------------------------------------------------------

	//Valida pedido Pleres
	
	If !U_FSValidPed(cFilAtu, @aPedido, @cMsg)
		aAdd(aRet, -4)
		aAdd(aRet, cMsg)
//		RpcClearEnv()
		Return
	Else
		aAdd(aRet, 0)
		aAdd(aRet, cMsg)
	EndIf
	
	MSUnlockAll()	
	
	
//-------------------------------------------------------------------------------

//RpcClearEnv()

Return

