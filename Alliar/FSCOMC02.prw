#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} FSCOMC02
Cadastro de Tipo de Cotacao Bionexo

@author claudiol
@since 23/12/2015
@version undefined

@type function
/*/
user function FSCOMC02()

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := "U_FSSZ3DEL()" //Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Local cString := "SZ3"

dbSelectArea(cString)
dbSetOrder(1) //Z3_FILIAL+Z3_CODIGO

AxCadastro(cString,"Cadastro de Tipo de Cotação Bionexo",cVldExc,cVldAlt)

Return


/*/{Protheus.doc} FSSZ3DEL
Validacao para exclusao

@author claudiol
@since 23/12/2015
@version undefined

@type function
/*/
User Function FSSZ3DEL()

Local	aAreOld	:= {GetArea()}
Local lRet		:= .T. // Retorno
Local aTabVal	:= {}  // Tabelas a serem validadas
Local nXi		:= 0

//Tabelas e campos que utilizam a tabela
Aadd(aTabVal, {"SC1",{{"C1_XTIPPDC", SZ3->Z3_CODIGO}}})

For nXi:= 1 To Len(aTabVal)
	If !(lRet:= U_FSValQry(aTabVal[nXi][1], aTabVal[nXi][2]))
		Exit
	EndIf
Next nXi

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return(lRet)
