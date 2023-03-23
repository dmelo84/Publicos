#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} MT140GCT
Este ponto de entrada tem o objetivo de incluir os itens 
n�o-pertinentes ao M�dulo Gest�o de Contratos no Pr�-Documento
@author Jonatas Oliveira | www.compila.com.br
@since 15/03/2019
@version 1.0
/*/
User Function MT140GCT()
	Local ExpA1   := PARAMIXB[1]
	Local ExpN1   := PARAMIXB[2]
	Local ExpN2   := PARAMIXB[3] //Valida��es do usu�rio.

	/*
	Retorna as vari�veis l�gicas 
	lItensMed (Itens pertinentes ao SIGAGCT) e 
	lItensNaoMed (Itens n�o-pertinentes ao SIGAGCT) customizada.
	
	1- ({.F.,.F.}) 
	- Identifica que a Medi��o n�o possui itens pertinentes e n�o possui itens n�o-pertinentes do SIGAGCT, 
	CONFIRMA a grava��o do Documento de Entrada.


	2- ({.F.,.T.}) 
	- Identifica que a Medi��o n�o possui itens pertinentes e possui itens n�o-pertinentes do SIGAGCT, 
	CONFIRMA a grava��o do Documento de Entrada.
	3- ({.T.,.F.}) - 
	- Identifica que a Medi��o possui itens pertinentes e n�o possui itens n�o-pertinentes do SIGAGCT, 
	CONFIRMA a grava��o do Documento de Entrada.

	4- ({.T.,.T.}) 
	- Identifica que a Medi��o possui itens pertinentes e possui itens n�o-pertinentes do SIGAGCT, 
	N�O CONFIRMA a grava��o do Documento de Entrada.
	*/

Return({ .F. , .F.})