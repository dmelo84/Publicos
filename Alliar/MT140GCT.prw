#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} MT140GCT
Este ponto de entrada tem o objetivo de incluir os itens 
não-pertinentes ao Módulo Gestão de Contratos no Pré-Documento
@author Jonatas Oliveira | www.compila.com.br
@since 15/03/2019
@version 1.0
/*/
User Function MT140GCT()
	Local ExpA1   := PARAMIXB[1]
	Local ExpN1   := PARAMIXB[2]
	Local ExpN2   := PARAMIXB[3] //Validações do usuário.

	/*
	Retorna as variáveis lógicas 
	lItensMed (Itens pertinentes ao SIGAGCT) e 
	lItensNaoMed (Itens não-pertinentes ao SIGAGCT) customizada.
	
	1- ({.F.,.F.}) 
	- Identifica que a Medição não possui itens pertinentes e não possui itens não-pertinentes do SIGAGCT, 
	CONFIRMA a gravação do Documento de Entrada.


	2- ({.F.,.T.}) 
	- Identifica que a Medição não possui itens pertinentes e possui itens não-pertinentes do SIGAGCT, 
	CONFIRMA a gravação do Documento de Entrada.
	3- ({.T.,.F.}) - 
	- Identifica que a Medição possui itens pertinentes e não possui itens não-pertinentes do SIGAGCT, 
	CONFIRMA a gravação do Documento de Entrada.

	4- ({.T.,.T.}) 
	- Identifica que a Medição possui itens pertinentes e possui itens não-pertinentes do SIGAGCT, 
	NÃO CONFIRMA a gravação do Documento de Entrada.
	*/

Return({ .F. , .F.})