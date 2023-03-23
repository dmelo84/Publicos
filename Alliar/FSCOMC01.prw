#Include 'Protheus.ch'

/*/{Protheus.doc} FSCOMC01
Cadastro Categoria Bionexo

@type function
@author claudiol
@since 16/12/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function FSCOMC01()

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := "U_FSSZ2DEL()" //Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Local cString := "SZ2"

dbSelectArea(cString)
dbSetOrder(1) //Z2_FILIAL+Z2_CODIGO

AxCadastro(cString,"Cadastro de Categoria Bionexo",cVldExc,cVldAlt)

Return


/*/{Protheus.doc} FSSZ2DEL
Validacao para exclusao

@type function
@author claudiol
@since 16/12/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function FSSZ2DEL()

Local	aAreOld := {GetArea()}
Local 	lRet	 := .T. // Retorno
Local 	aTabVal := {}  // Tabelas a serem validadas
Local 	nXi     := 0

//Tabelas e campos que utilizam a tabela
Aadd(aTabVal, {"SBM",{{"BM_XCATBIO", SZ2->Z2_CODIGO}}})

For nXi:= 1 To Len(aTabVal)
	If !(lRet:= U_FSValQry(aTabVal[nXi][1], aTabVal[nXi][2]))
		Exit
	EndIf
Next nXi

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return(lRet)
