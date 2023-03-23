#include "Totvs.ch"
//GETNUMSC7()        antes

/*/{Protheus.doc} ALNUMSC7
// sequencia de numeração do pedido de compra.
@author Sivaldo P. Santos
@since 25/03/2017
@version undefined

@type function
/*/


User Function ALNUMSC7()

Local cRet      := ""
Local cNumero   := ""
Local cNumIni 	:= ""
Local lRet      := .F.
Local cQuery    := ""
Local cSC7Qry   := "TabQry"
 
 cQuery := " SELECT MAX(C7_NUM) AS C7_NUM "+CRLF
 cQuery += " FROM "+ RETSQLNAME("SC7")+" SC7 "+CRLF
 cQuery += " WHERE SC7.C7_FILIAL = '"+ xFilial("SC7")+"' "
// cQuery += " AND SC7.C7_NUM NOT LIKE '%Z%' "+CRLF
 cQuery += " AND LEN(C7_NUM ) = 6 "+CRLF
 cQuery += " AND ISNUMERIC( C7_NUM)  = '1' "+CRLF
 
 //cQuery += " AND SC7.D_E_L_E_T_ = '' "+CRLF   
  
 If Select(cSC7Qry) > 0
  (cSC7Qry)->(DbCloseArea())
 EndIf
   
 DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cSC7Qry, .T., .T.)
 
 cNumero := (cSC7Qry)->C7_NUM

 (cSC7Qry)->(DbCloseArea())
 
 For i:= 1 to 20 
   
   cNumero := soma1(cNumero)
   
   lRet :=  MayIUseCode( xfilial("SC7") + Alltrim(cNumero) ) 
   If lRet //  MayIUseCode( xfilial("SC7") + cNumero ) 
   
    cRet := cNumero
  
    //FreeUsedCode()
    exit
   Endif
     
 Next 

  
Return(cRet)