#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALRCLS13
Funcao Generica para Compilacao

@author Guilherme.Santos
@since 07/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRCLS13()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} uCadContato
Classe para Cadastramento dos Contatos com Amarracao a Entidade de Origem
Implementada por Heranca da Classe uModelo2

@author Guilherme.Santos
@since 07/12/2016
@version P12
*/
//-------------------------------------------------------------------
Class uCadContato From uModelo2
	Method SetGetD(nOpcao)
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} SetGetD
Metodo para Definicao da GetDados
Sobrescreve o Metodo SetGetD da Classe uModelo2

@author Guilherme.Santos
@since 07/12/2016
@version P12
*/
//-------------------------------------------------------------------
Method SetGetD(nOpcao) Class uCadContato

Return NIL
