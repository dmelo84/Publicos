/*/{Protheus.doc} fa750brw
Alterar Vencto real do Mutuo

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Alliar
 
@return Boolean
/*/

User Function fa750brw()
Local aArea := GetARea()
Local nCnt 	:= 0       
Local aCsRot330 	:= {}
 
//Passado como parametro a posicao da opcao dentro da arotina
// Local aCsRot330 :=	{	{ 'Alterar Vencto Real', "U_ALE2VCTO()"   , 0 , 4}, {"Consultar ID Gps","U_CFINP13"   , 0 , 4}, {"Sispag","U_CFINP13"   , 0 , 4}   }                        

      
aAdd(aCsRot330, {'Cnab SISPAG'			,"FINA300()"	,   0 , 4    }) 
aAdd(aCsRot330, {'Ret. Sispag Autom.'	,"U_ALFINP02()"	,   0 , 4    })
aAdd(aCsRot330, {'Altera Vencto Real'	,"U_ALE2VCTO()"	,   0 , 4    })
aAdd(aCsRot330, {'Consulta ID GPS'		,"U_CFINP13()"	,   0 , 4    })
 
restarea(aArea)

return aCsRot330 