#INCLUDE 'TBICONN.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "PROTHEUS.CH"


/*
UPDATE GLAUTON
@author 
@since 09/12/2016
@version 1.0
*/
User Function GLAUTON()
Local cQuery := ""
   	
   	
CQUERY := "UPDATE SB1010 SET B1_CONTA = BM_XCONTA1,   B1_XCONTA1 = BM_XCONTA, B1_XCONTA2 = BM_XCONTA2 FROM SBM010, SB1010 " 
CQUERY += " WHERE BM_GRUPO IN (SELECT B1_GRUPO FROM SB1010 WHERE SB1010.D_E_L_E_T_ <> '*' ) "
CQUERY += " AND BM_GRUPO=B1_GRUPO "
CQUERY += " AND BM_GRUPO NOT IN ('1300','2300') "

TCSQLExec(cQuery)

return         


User Function AjuCVD()
Local cStr
Local nCOunt := 1
Dbselectarea('CVD')
CVD->(DbGoTop())
            
While CVD->(!Eof()) 
          
   If Len(CVD->CVD_CTAREF) >= 3
      reclock('CVD',.F.) 
      //alert ("Tamanho: " + STR(  Len( CVD->CVD_CTAREF)  )   )
      
      cStr := Alltrim(CVD->CVD_CTAREF  )       
	   cStr := substr (cStr, 1, Len( cStr ) - 3)
	   //Alert ('apos truncar ' + cStr)
	   CVD->CVD_CTASUP := cStr
	   //alert (CVD->CVD_CTASUP)
	   MsUnLock() 
   EndIf
   //nCOunt += 1
   
   CVD->(DbSkip())
   
   //If nCOunt > 2
   //exit
   //endif
End
alert ('finalizou')
return