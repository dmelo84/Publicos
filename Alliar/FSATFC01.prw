#Include 'Protheus.ch'

/*/{Protheus.doc} FSATFC01
Cadastro de Tipo de Bem OCS

@type function
@author claudiol
@since 09/12/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function FSATFC01()

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := "U_FSSZ1DEL()" //Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Local cString := "SZ1"

dbSelectArea(cString)
dbSetOrder(1) //Z1_FILIAL+Z1_CODIGO

AxCadastro(cString,"Cadastro de Tipos de Bem OCS",cVldExc,cVldAlt)

Return

/*/{Protheus.doc} FSSZ1DEL
Validacao para exclusao de tipo de BEM

@type function
@author claudiol
@since 09/12/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function FSSZ1DEL()

Local	aAreOld := {GetArea()}
Local 	lRet	 := .T. // Retorno
Local 	aTabVal := {}  // Tabelas a serem validadas
Local 	nXi     := 0

//Tabelas e campos que utilizam a tabela
Aadd(aTabVal, {"SN1",{{"N1_XTPOCS", Z1_CODIGO}}})

For nXi:= 1 To Len(aTabVal)
	If !(lRet:= U_FSValQry(aTabVal[nXi][1], aTabVal[nXi][2]))
		Exit
	EndIf
Next nXi

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return(lRet)
