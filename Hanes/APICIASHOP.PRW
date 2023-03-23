#INCLUDE "TOTVS.CH"



/*/{Protheus.doc} updCiash
	
	Função para recuperar dados adicionais de pedidos de venda do Ciashop.
	
@author iagob
@since 23/05/2019
@version 1.0
@return cGetResult, String em formato JSON contendo os dados adicionais do pedido informado
@param cOrderId, char, Número (id) do pedido de venda
@type function
/*/
User Function updCiash(cOrderId)
Return getTransactionDetails(cOrderId)



Static Function getTransactionDetails(cOrderId)

	Local aHeader		:= {}

	Local cRestURL		:= "https://hanes.myciashop.com.br" // .../api/v1/orders/<order_id>
	Local cPath			:= "/api/v1/orders"
	Local cEntityURL	:= "/paymentTransactions"
	Local cBearer		:= "eyJvIjoie1wiaVwiOlwiQ2lhc2hvcFwiLFwiblwiOlwiUHJvdGhldXNcIixcInBcIjpcImVlNDk2ZTNjLTBhMGMtNGE4Ny1hYWZhLTZiMGQ3YTVmOGJlZlwifSIsInMiOiJRVWdFL2JOb1RtdFJWTkJXeWE3czFJL0lyenJUbHEwa05qQ2t2NUNjemVzdWZzT2RkQ05NZlp0azBaU0Y0azk4NG1qR25TM2IxZW1lbmkrdXhUcWFKOEhiOFI4Z3JJQVpFMUhzY1dzcHE0TnhkOENaaUZNbDEzRlNHdXhsODJUUVpVVkxPQ213NmtvSkRtTDIxVE9TUzB0QnZpTmRkTlFmVEtBVmQ2eHJJMkU9In0="
	Local cPathURL		:= ""
	Local cGetResult	:= ""
	
	Local oRestClient

	If Empty(cOrderId)
		//Return {"Erro", "Id do pedido não é válido."}
		Return Nil
	EndIf

	// Inclui o campo Authorization no header da solicitação
	Aadd(aHeader, "Authorization: Bearer " + cBearer)

	cPathURL := cPath + "/" + Alltrim(cOrderId) + cEntityURL

	// Define as URL de client e path para inserir novo usuário
	oRestClient	:= FWRest():New(cRestURL)
	oRestClient:setPath(cPathURL)

	// Realiza a chamada GET
	If oRestClient:GET(aHeader)
		// Em caso de sucesso, recupera a mensagem de resposta
		cGetResult := oRestClient:GetResult()
	Else
		// Em caso de erro, recupera a mensagem de erro
		cGetResult := oRestClient:GetLastError() + " - " + oRestClient:cResult
		ConOut("GET Error", cGetResult)
		//Return {"Erro", "Falha ao executar método get: " + cGetResult}
		Return Nil
	EndIf

	FreeObj(oRestClient)

Return cGetResult