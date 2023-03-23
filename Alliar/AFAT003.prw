#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH


/*/{Protheus.doc} AFAT003
Realiza inclusão de Medicos via MsExecAuto
@author Jonatas Oliveira | www.compila.com.br
@since 16/06/2017
@version 1.0
@param aDados, A, Dados à serem gravados ALTMKA03.PRX
@param _nOpc, N, Opção de gravação 3- Inclusão, 4- Alteração, 5- Exclusão
@return nRet, Codigo do processamento - nRet == 1 | SUCESSO,  nRet < 0 | ERRO, nRet -99 | Erro Indeterminado
@return cMsgErro, Mensagem de Erro  
/*/
User Function AFAT003(aDados, _nOpc)
	//Local _nOpc		:= 0 //|3- Inclusão, 4- Alteração, 5- Exclusão|	
	Local aRet		:= {"0", ""}
	Local cChave 	:= ""
	Local nIndice	:= 0
	Local nPosChv	:= 0
	Local cModeloImp	:= ""
	Local _cAliasT	:= ""

	Private _cRotina	:= ""

	_cAliasT := "ACH"	
	cModeloImp	:= "MVC"
	nIndice		:= 1
	//nIndice		:= 2  //| ACH_FILIAL+ACH_CGC

	//nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "ACH_CGC"		})

	_cRotina	:= "TMKA341"//"ALTMKA03"

	IF nPosChv > 0 
		cChave	:= XFILIAL(_cAliasT) + aDados[nPosChv][2]
	ELSE
		aRet[1]	:= "-8"
		aRet[2]	:= "Chave Principal não localizada [ACH][ACH_CGC]"
	ENDIF 

	aRet := aClone(impMVC(_cAliasT, nIndice, aDados, _nOpc,_cRotina))


Return(aRet)





/*/{Protheus.doc} AFAT03C
Realiza inclusão de Contatos via MsExecAuto
@author Jonatas Oliveira | www.compila.com.br
@since 24/06/2017
@version 1.0
@param aDados, A, Dados à serem gravados ALTMKA03.PRX
@param _nOpc, N, Opção de gravação 3- Inclusão, 4- Alteração, 5- Exclusão
@return nRet, Codigo do processamento - nRet == 1 | SUCESSO,  nRet < 0 | ERRO, nRet -99 | Erro Indeterminado
@return cMsgErro, Mensagem de Erro  
/*/
User Function AFAT03C(_aContato,_aEndereco,_aTelefone, _nOpc)
	//Local _nOpc		:= 0 //|3- Inclusão, 4- Alteração, 5- Exclusão|	
	Local aRet		:= {"0", ""}
	Local cChave 	:= ""
	Local nIndice	:= 0
	Local nPosChv	:= 0
	Local cModeloImp	:= ""
	Local _cAliasT	:= ""
	
	Local aContato := {}
	Local aEndereco := {}
	Local aTelefone := {}
	Local aAuxDados := {}
	Local cAutoLog, cMemo
	
	Private lMsErroAuto := .F.
		
	Private _cRotina	:= ""
	

	MSExecAuto({|x,y,z,a,b|TMKA070(x,y,z,a,b)},_aContato,_nOpc, /*_aEndereco*/,/*_aTelefone*/, .F.) 
	If lMsErroAuto 
	
		//MostraErro()
		cAutoLog	:= alltrim(NOMEAUTOLOG())

		cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
		cMemo := STRTRAN(cMemo,"'","")

		//| Apaga arquivo de Log
		Ferase(cAutoLog)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Le Log da Execauto e retorna mensagem amigavel ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet[1]:= "500"
		aRet[2] := U_CPXERRO(cMemo)
		IF EMPTY(aRet[2])
			aRet[2]	:= alltrim(cMemo)
		ENDIF

	    //MsgStop("Erro na gravação do contato")

	EndIf
	
Return(aRet)
	
	/*

	_cAliasT := "SU5"	
	cModeloImp	:= "MVC"
	nIndice		:= 2  //| ACH_FILIAL+ACH_CGC

	nPosChv 	:= aScan( aDados , { |x| AllTrim(x[01]) == "US_CPF"		})

	_cRotina	:= "TMKA070"

	IF nPosChv > 0 
		cChave	:= XFILIAL(_cAliasT) + aDados[nPosChv][2]
	ELSE
		aRet[1]	:= "-8"
		aRet[2]	:= "Chave Principal não localizada [SU5][US_CPF]"
	ENDIF 

	aRet := aClone(impMVC(_cAliasT, nIndice, aDados, _nOpc,_cRotina))


Return(aRet)

*/

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

			// È feita a atribuição do dado ao campo do Model
			If !( lAux := oModel:SetValue(aDados[nI][1], aDados[nI][2] ) )
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por 	exemplo)
				// o método SetValue retorna .F.

				cWarn	+= aCampos[nI][1]+"- Não foi possivel atribuir valor a este campo"
			EndIf
		ELSE
			cWarn	+= aCampos[nI][1]+"- Não encontrado na entidade "+cAliasImp 
		EndIf
	Next nI

	If oModFull:VldData() 
		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		IF oModFull:CommitData()
			aRet	:= {"0", oModel:GetValue("ACH_CODIGO")+oModel:GetValue("ACH_LOJA")}
		ELSE
			aRet[1]	:= "-6"
			aRet[2]	:= oModFull:GetErrorMessage()[6]
		ENDIF
	ELSE
		aErro := oModFull:GetErrorMessage()
		// A estrutura do vetor com erro é:
		// [1] identificador (ID) do formulário de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formulário de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solução
		// [8] Valor atribuído
		// [9] Valor anterior

		aRet[1]	:= "-7"
		aRet[2]	:=  aErro[4]+"-"+aErro[6]
	EndIf

	oModFull:DeActivate()

Return(aRet)





/*/{Protheus.doc} AFAT3SU5
Validacao Customizada U5_CPF
@author Augusto Ribeiro | www.compila.com.br
@since 13/09/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function AFAT3SU5()
Local lRet		:= .T.
Local lRetAux	
Local aAreaSU5	:= SE5->(GETAREA())
Local nRecAlt	:= 0


IF ALTERA
	nRecAlt	:= SU5->(RECNO())
ENDIF

IF !EMPTY(M->U5_CPF) .AND.!EMPTY(M->U5_XTPDOC) 			
	DBSELECTAREA("SU5")
	SU5->(DBSETORDER(8))//|U5_FILIAL+U5_CPF|			
	IF SU5->(DBSEEK(XFILIAL("SU5") + ALLTRIM(M->U5_CPF) ))
	
	
		WHILE SU5->(!EOF()) .AND. alltrim(SU5->U5_CPF) == ALLTRIM(M->U5_CPF)
		
			IF ALTERA
				IF nRecAlt == SU5->(RECNO())
					SU5->(DBSKIP())
					LOOP
				ENDIF
			ENDIF
				
			IF (M->U5_XTPDOC == "1" .OR.  M->U5_XTPDOC == "3") .AND.;
			 	M->U5_XTPDOC == SU5->U5_XTPDOC
			 	
			 	lRet	:= .F.
			 	EXIT			 	
			ELSEIF M->U5_XTPDOC == "2" .AND. M->U5_XTPDOC == SU5->U5_XTPDOC .AND. M->U5_XNIVER == SU5->U5_XNIVER
			 	lRet	:= .F.
			 	EXIT			 	
			ENDIF
					
			SU5->(DBSKIP())
		ENDDO
		
		IF !lRet
			Help(" ",1,"JAGRAVADO",,"Registro ja existe com a chave, Tipo DOC + CPF + *DT. NASC",4,5)
		ENDIF		
		
	ENDIF

ENDIF

RestArea(aAreaSU5)
Return(lRet) 





