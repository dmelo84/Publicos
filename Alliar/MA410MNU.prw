#include "rwmake.ch"

/*/{Protheus.doc} MA410MNU
Ponto de Entrada. Adiciona opção no menu Pedido de Vendas

@type function
@author Alex Teixeira de Souza
@since 20/01/2016
@version 1.0
@param ${aRet}
@return ${aRet}
@example 
(examples)
@see (links_or_references)
/*/
user function MA410MNU() 

	//Fora do escopo, apenas para auxiliar Antônio, inserimos esta rotina no ações relacionadas do pedido de venda no dia 13-04-16
	aAdd(aRotina,{"Nfs-e", "FISA022" , 0 , 0 , 0 , .F.})	
//	aadd(aRotina,{	"Formas de pagamento" ,'U_FSFATC01()'		, 0 ,3 ,0 ,.F. } )
	
Return 
