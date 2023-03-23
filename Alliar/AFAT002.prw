#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH


/*/{Protheus.doc} AFAT002
Realiza inclus�o de pacientes via MsExecAuto
@author Jonatas Oliveira | www.compila.com.br
@since 21/04/2017
@version 1.0
@param aDados, A, Dados � serem gravados FATA030.PRX
@param _nOpc, N, Op��o de grava��o 3- Inclus�o, 4- Altera��o, 5- Exclus�o
@return nRet, Codigo do processamento - nRet == 1 | SUCESSO,  nRet < 0 | ERRO, nRet -99 | Erro Indeterminado
@return cMsgErro, Mensagem de Erro  
/*/
User Function AFAT002(aDados, _nOpc)
	//Local _nOpc		:= 0 //|3- Inclus�o, 4- Altera��o, 5- Exclus�o|	
	Local aRet		:= {"0", ""}
	Local cChave 	:= ""
	Local nIndice	:= 0
	Local nPosChv	:= 0
	Local cModeloImp	:= ""
	Local _cAliasT	:= ""

	Private _cRotina	:= ""

	_cAliasT := "AC4"	
	cModeloImp	:= "MVC"
	nIndice		:= 3 //| AC4_FILIAL+AC4_XCPF

	nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "AC4_XCPF"		})

	_cRotina	:= "FATA030"

	IF nPosChv > 0 
		cChave	:= XFILIAL(_cAliasT)+aDados[nPosChv][2]
	ELSE
		aRet[1]	:= "-8"
		aRet[2]	:= "Chave Principal n�o localizada [AC4][AC4_XCPF]"
	ENDIF 

	aRet := aClone(impMVC(_cAliasT, nIndice, aDados, _nOpc,_cRotina))


Return(aRet)

/*/{Protheus.doc} impMVC
Importa registro via MVC
@author Augusto Ribeiro | www.compila.com.br
@since 05/01/2016
@version  1.0
@param cAliasImp, C, Alias
@param nIndice, n, Indice
@param aDados, a, Dados
@param nOper, n, Operacao
@param cModel, C, Modelo de dados
@return aRet, {.F., ""}
@example
(examples)
@see (links_or_references)
/*/
Static Function impMVC(cAliasImp, nIndice, aDados, nOper,cModel)
	Local aRet		:= {"0", ""}
	local cWarn		:= "SUCESSO"
	Local oModel, oAux, oStruct
	Local nI		:= 0
	Local nPos 		:= 0
	Local lRet 		:= .T.
	Local aAux    	:= {}
	Local aCampos	:= {}

	dbSelectArea( cAliasImp )
	dbSetOrder( nIndice )

	oModFull := FWLoadModel( cModel )
	oModFull:SetOperation( nOper )
	oModFull:Activate()

	oModel 		:= oModFull:GetModel( cAliasImp + 'MASTER' )
	oStruct 	:= oModel:GetStruct()
	aCampos  	:= oStruct:GetFields()

	//| Atribui Valores ao Model|
	For nI := 1 To Len( aDados )
		// Verifica se os campos passados existem na estrutura do modelo
		//If ( nPos := aScan(aDados,{|x| AllTrim( x[1] )== AllTrim(aCampos[nI][3]) } ) ) > 0
		If ( nPos := aScan(aCampos,{|x| AllTrim( x[3] )== AllTrim(aDados[nI][1]) } ) ) > 0

			// � feita a atribui��o do dado ao campo do Model
			If !( lAux := oModel:SetValue(aDados[nI][1], aDados[nI][2] ) )
				// Caso a atribui��o n�o possa ser feita, por algum motivo (valida��o, por 	exemplo)
				// o m�todo SetValue retorna .F.

				cWarn	+= aCampos[nI][1]+"- N�o foi possivel atribuir valor a este campo"
			EndIf
		ELSE
			cWarn	+= aCampos[nI][1]+"- N�o encontrado na entidade "+cAliasImp 
		EndIf
	Next nI

	If oModFull:VldData() 
		// Se o dados foram validados faz-se a grava��o efetiva dos dados (commit)
		IF oModFull:CommitData()
			aRet	:= {"0", cWarn}
		ELSE
			aRet[1]	:= "-6"
			aRet[2]	:= oModFull:GetErrorMessage()[6]
		ENDIF
	ELSE
		aErro := oModFull:GetErrorMessage()
		// A estrutura do vetor com erro �:
		// [1] identificador (ID) do formul�rio de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formul�rio de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solu��o
		// [8] Valor atribu�do
		// [9] Valor anterior

		aRet[1]	:= "-7"
		aRet[2]	:=  aErro[4]+"-"+aErro[6]
	EndIf

	oModFull:DeActivate()

Return(aRet)