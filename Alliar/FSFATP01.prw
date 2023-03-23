#Include 'Protheus.ch'

/*/{Protheus.doc} FSFATP01
Rotina responsável pelo tratamento dos dados do Pedido de Venda (Pleres), Cliente e Formas de Pagamento 
para geração do Pedido de Vendas (Protheus).

@type function
@author Gustavo Barcelos
@since 12/01/2016
@version 1.0
@obs
02/03/2016 Claudio Silva	Ajuste para validar se o XML é valido
/*/

User Function FSFATP01(cXml, aRet)

	Local aFatura 		:= {}
	Local aPedido 		:= {}
	Local aCliente 		:= {}
	Local aItensPedido 	:= {}
	Local aPagam 			:= {} 
	Local cMsg				:= "Pedido de Venda incluído com sucesso!"
	Local cFilAtu			:= ""
	Local cEmpAtu			:= ""
	Local cCnpjFil		:= ""
	Local cPedido			:= ""
	Local lCli				:= .F.
	Local cCusto			:= ""
	Local cTipoFat		:= ""

	Local cError  		:= ""
	Local cWarning		:= ""
	Local oXml				:= Nil
	Local lRetorno		:= .T.
	Local nPosCPO		:= 0
	Local cIdPleres, cSemaf, nHSemaf

	If Empty(cXml)
		aRet		:= {}
		aRet		:= {-3, "Obrigatório informar XML!"}
		lRetorno	:= .F.
	EndIf
	
	If lRetorno
		//Gera o Objeto XML ref. ao script
		oXml := XmlParser( cXml, "_", @cError, @cWarning )
		
		If (oXml == NIL )
			aRet		:= {}
			aRet		:= {-3, "Falha ao gerar Objeto XML : "+cError+" / "+cWarning}
			lRetorno	:= .F.
		Endif
	EndIf
	
//-------------------------------------------------------------------------------	

	//Carrega filial de acordo com CNPJ
	If lRetorno
		cCnpjFil	:= SubStr(cXml, ( AT("<CNPJFilial>", cXml) + 12 ), at("</CNPJFilial>", cXml) - ( AT("<CNPJFilial>", cXml) + 12 ) )
		U_FSSetFil( cCnpjFil, @cEmpAtu, @cFilAtu )
		
		If cFilAtu == ""
			aRet		:= {}
			aRet		:= {-7, "Não foi possível carregar a informação da filial!"}
			lRetorno 	:= .F.
		EndIf
	EndIf
	
//-------------------------------------------------------------------------------		

	//Inicia ambiente baseado na filial selecionada
	If lRetorno
		RpcSetType(3)
		RpcSetEnv(cEmpAtu, cFilAtu)
		
		cEmpAnt := cEmpAtu
		cFilAnt := cFilAtu
	EndIf
	
//-------------------------------------------------------------------------------

	//Carrega Centro de Custo de acordo com Filial
	If lRetorno	
		cCusto := U_FSCustoFil(cCnpjFil)
	EndIf

//-------------------------------------------------------------------------------
	
	//Carrega dados do XML e grava em arrays
	If lRetorno
		If U_FSXML2ARR(1, cXml, @cFilAtu, @aFatura, @aPedido, @aCliente, @aItensPedido, @aPagam, @cMsg, cCusto)
			//Carrega tipo de Faturamento
			cTipoFat	:= AllTrim(aPedido[aScan(aPedido, {|X| X[1] == "C5_XTIPFAT"})][2])
		Else 
			aRet		:= {}
			aAdd(aRet, -1)
			aAdd(aRet, cMsg)
			lRetorno	:= .F.
		EndIf
	EndIf
	
//-------------------------------------------------------------------------------	
	
	//Testa usuário e senha
	If lRetorno	
		If !U_FVerPwd(aFatura[aScan(aFatura, {|X| X[1] == "LOGIN"})][2], aFatura[aScan(aFatura, {|X| X[1] == "SENHA"})][2])
			aRet		:= {}
			aAdd(aRet, -2)
			aAdd(aRet, "Usuário inexistente ou senha incorreta!")
			lRetorno := .F.
		EndIf
	EndIf

//-------------------------------------------------------------------------------
	If lRetorno
	

		nC5XIDPLE	:= aScan(aPedido, {|X| X[1] == "C5_XIDPLE"})
	
		IF nC5XIDPLE > 0		
			cIdPleres	:= aPedido[nC5XIDPLE,2]			
			IF !EMPTY(cIdPleres)
			
				IF LEFT(cIdPleres,1) == "P"
				
				
			
					/*------------------------------------------------------ Augusto Ribeiro | 14/06/2017 - 2:04:30 PM
						Semaforo para impedir Duplicidade de IDPleres no PV
					------------------------------------------------------------------------------------------*/
					cSemaf		:= "FSFATP01_"+cFilAtu+cIdPleres
					nHSemaf	:= U_CPXSEMAF("A", cSemaf)
				
					IF nHSemaf > 0
				
						If lRetorno
							//Valida pedido Pleres
							If !U_FSValidPed(cFilAtu, @aPedido, @cMsg)
								aRet		:= {}
								aAdd(aRet, -4)	//Erro na validação do pedido
								aAdd(aRet, cMsg)
								lRetorno := .F.
							EndIf
						EndIf
				
						//Atualiza dados do cliente
						If lRetorno
							If !U_FSAtuCli( @aCliente, @aPedido, @cMsg, @lCli, cTipoFat, aPagam)
								aRet		:= {}
								aAdd(aRet, -5)	// Erro ao incluir/atualizar cliente
								aAdd(aRet, cMsg)
								lRetorno := .F.
							EndIf
						EndIf
					
						//Inclui Pedido de Vendas
						If lRetorno	
							If !U_FSGeraPed(@aPedido, @aItensPedido, @cPedido, @cMsg, cXml)
								aRet		:= {}
								aAdd(aRet, -6)	// Erro ao incluir pedido
								aAdd(aRet, cMsg)
								lRetorno := .F.
							Else
								IIf( Len(aPagam) > 0, U_FSGeraParc( cFilAtu, cPedido, aPagam ) , )
								aRet		:= {}	
								aAdd(aRet, 0)
								aAdd(aRet, cMsg)
								U_FSValTipPV(cTipoFat, lCli, cFilAtu, cPedido)
							EndIf
						EndIf
						
						
						nHldSemaf	:= U_CPXSEMAF("F", cSemaf, nHSemaf)
					ELSE
						aRet	:= {-3, "O ID ["+cIdPleres+"] já esta sendo processado por outra instancia."}
					ENDIF
				ELSE 
					aRet	:= {-3, "O ID ["+cIdPleres+"] inválido."}
				ENDIF
			ENDIF
			
		ENDIF
			
		MSUnlockAll()
								
	EndIf
//-------------------------------------------------------------------------------	

Return
