#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALRCLS08
Funcao Generica para Compilacao

@author Guilherme Santos
@since 03/05/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRCLS08()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} uColecao
Classe Responsavel em Guardar uma Colecao de Objetos

@author Guilherme Santos
@since 03/05/2016
@version P12
*/
//-------------------------------------------------------------------
Class uColecao
	Data aColecao									//Array que ira armazenar os dados
	
	Method New()									//Metodo construtor
	Method Add(vKey, oObject, lNew)				//Adiciona um objeto na Colecao
	Method Remove(vKey)							//Remove um objeto da Colecao
	Method Count()								//Retorna o numero de objetos da Colecao
	Method Contains(vKey)						//Verifica se existe um determinado elemento na Colecao
	Method GetValue(vKey)						//Retorna um elemento da Colecao
	Method SetValue(vKey)						//Atribui um Conteudo a um elemento da Colecao
	Method GetPos(vKey)							//Retorna a Posicao da Chave Informada
	Method GetKey(nIndice)						//Retorna a Chave do elemento da Colecao
	Method Elements(nIndice)						//Metodo que ira retornar um elemento de um determinado indice
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Construtor da Classe uColecao

@author Guilherme Santos
@since 03/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method New() Class uColecao
    ::aColecao := {}
Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} Add
Adiciona um Elemento a Colecao

@author Guilherme Santos
@since 03/05/2016
@version P12
@param vKey 		- Chave da Colecao
@param oObject	- Elemento da Colecao
@param lNew 		- Indica se ira adicionar um novo elemento
*/
//-------------------------------------------------------------------
Method Add(vKey, oObject, lNew) Class uColecao
	Default lNew := .F.

    //Verifica se o elemento ja existe na colecao, se sim, remove
    If lNew == .F.
	    If ::Contains(vKey)
	    	::Remove(vKey)
	    EndIf
    EndIf
    
    //Adiciona um elemento na colecao
    Aadd(::aColecao, {vKey, oObject})
Return Nil
//-------------------------------------------------------------------
/*{Protheus.doc} Count
Retorna a Quantidade de Elementos da Colecao

@author Guilherme Santos
@since 03/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method Count() Class uColecao
	Local nRetorno 	:= Len(::aColecao)				//Variavel de retorno do metodo
Return nRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} Contains
Verifica se existe um determinado elemento na Colecao

@author Guilherme Santos
@since 03/05/2016
@version P12
@param vKey - Chave da Colecao
*/
//-------------------------------------------------------------------
Method Contains(vKey) Class uColecao
	Local nPosicao 	:= 0				//Posicao do array
	Local lRetorno 	:= .F.				//Variavel de retorno do metodo
		
	//Verifica se possui algum elemento na colecao
	If ::Count() > 0
		Begin Sequence
			//Procura o elemento na colecao
			nPosicao := Ascan(::aColecao, {|x| x[1] == vKey})
			
			//Verifica se encontrou o elemento
			If nPosicao > 0 
				lRetorno := .T.	
			EndIf
		Recover
			lRetorno := .F.			
		End Sequence
	EndIf
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} Remove
Remove um Elemento da Colecao

@author Guilherme Santos
@since 03/05/2016
@version P12
@param vKey - Chave da Colecao
*/
//-------------------------------------------------------------------
Method Remove(vKey) Class uColecao
	Local nPosicao 	:= 0				//Posicao do produto no array
	
	//Procura o elemento na colecao
	nPosicao := Ascan(::aColecao, {|x| x[1] == vKey})

	If nPosicao > 0
		//Apaga o elemento da colecao
		ADel(::aColecao, nPosicao)
		//Redimensiona a colecao		
		ASize(::aColecao, ::Count() - 1)
	EndIf
Return Nil
//-------------------------------------------------------------------
/*{Protheus.doc} GetValue
Retorna um Elemento da Colecao atraves da Chave

@author Guilherme Santos
@since 03/05/2016
@version P12
@param vKey - Chave da Colecao
*/
//-------------------------------------------------------------------
Method GetValue(vKey) Class uColecao
	Local nPosicao	:= 0				//Posicao do elemento no array
	Local oElement	:= NIL				//Objeto que sera retornado na funcao

	//Procura o elemento na colecao
	nPosicao := Ascan(::aColecao, {|x| x[1] == vKey})

	If nPosicao > 0
		//Pega o elemento
		oElement := ::Elements(nPosicao)
	EndIf
Return oElement
//-------------------------------------------------------------------
/*{Protheus.doc} SetValue
Atribui um Conteudo ao Elemento da Chave Informada

@author Guilherme Santos
@since 03/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method SetValue(vKey, oElement) Class uColecao
	Local nPosicao	:= ::GetPos(vKey)
	Local lRetorno	:= .T.

	If nPosicao > 0
		::aColecao[nPosicao][02] := oElement
	Else
		lRetorno := .F.
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} GetPos
Retorna a Posicao da Chave Informada

@author Guilherme Santos
@since 03/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetPos(vKey) Class uColecao
	Local nPosicao	:= Ascan(::aColecao, {|x| x[1] == vKey})	//Posicao do elemento no array
Return nPosicao
//-------------------------------------------------------------------
/*{Protheus.doc} GetKey
Retorna a Chave da Colecao atraves do Indice

@author Guilherme Santos
@since 03/05/2016
@version P12
@param nIndice - Indice da Colecao
*/
//-------------------------------------------------------------------
Method GetKey(nIndice) Class uColecao
	Local oElement  := ::aColecao[nIndice, 1]				//Objeto que sera retornado na funcao
Return oElement
//-------------------------------------------------------------------
/*{Protheus.doc} Elements
Retorna um Elemento da Colecao atraves de um Indice

@author Guilherme Santos
@since 03/05/2016
@version P12
@param nIndice - Posicao do Elemento
*/
//-------------------------------------------------------------------
Method Elements(nIndice) Class uColecao
	Local oElement := ::aColecao[nIndice, 2]				//Objeto que sera retornado na funcao
Return oElement
