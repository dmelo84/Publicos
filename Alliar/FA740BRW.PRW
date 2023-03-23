/*/{Protheus.doc} fa740brw
Alterar Vencto real do Mutuo

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Aliar
 
@return Boolean
/*/

User Function fa740brw()
Local aArea := GetARea()
Local nCnt := 0       
 
//Passado como parametro a posicao da opcao dentro da arotina
Local aCsRot330 :=	{	{ 'Alterar Vencto Real', "U_ALE1VCTO()"   , 0 , 4}  }                        

restarea(aArea)

return aCsRot330 