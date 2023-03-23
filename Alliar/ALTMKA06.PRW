#INCLUDE "rwmake.ch"
//-------------------------------------------------------------------
/*{Protheus.doc} ALTMKA06


@author Itamar Gama .:
@since  28/03/2017
@version P12
*/
//-------------------------------------------------------------------
User Function ALTMKA06()
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
//?Declaracao de Variaveis                                             ?
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

Local cVldAlt := ".T." 
Local cVldExc := ".T." 

Private cString := "SZG"

dbSelectArea("SZG")
dbSetOrder(1)

AxCadastro(cString,"Classificacao",cVldExc,cVldAlt)

Return