#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} ALJOB01
Função para atualização de SLA's SUC E SUD Call Center

@author 	Itamar Gama.:
@since 		20/03/2017
@version P12
*/
//-------------------------------------------------------------------
User Function ALJOB01()
  Local cQuery 	:= '' 
  RpcSetEnv( "01","00101MG0001")
  cQuery :="UPDATE "+ RetSqlName("SUC") +" SET UC_XSLSLA =  UC_XSLA - DATEDIFF(DAY,UC_DATA,GETDATE()) WHERE UC_STATUS = 2"
  cQuery +="UPDATE "+ RetSqlName("SUD") +" SET UD_XSLSLA =  UD_XSLA - DATEDIFF(DAY,UD_DATA,GETDATE()) WHERE UD_STATUS = 1"
  nStatus := TCSqlExec(cQuery)
  //if (nStatus < 0)
    //conout("TCSQLError() " + TCSQLError())
  //Else
    //conout("JOB Finalizado com sucesso - ALJOB01 - Atualização SLAs")  
  //endif
  RpcClearEnv()
Return .t.