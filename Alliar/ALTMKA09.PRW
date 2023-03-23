#INCLUDE "rwmake.ch"
//-------------------------------------------------------------------
/*{Protheus.doc} ALTMKA09


@author Itamar Gama .:
@since  28/03/2017
@version P12
*/
//-------------------------------------------------------------------
User Function ALTMKA09()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de Variaveis                                             Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Local cVldAlt := ".T." 
Local cVldExc := ".T." 

Private cString := "SZI"

dbSelectArea("SZI")
dbSetOrder(1)

AxCadastro(cString,"Marcas",cVldExc,cVldAlt)

Return