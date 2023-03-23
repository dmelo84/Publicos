#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "ALWSICATCH.CH"
                            
Static cMsgLog	:= ""

User Function ALWSICATCH()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} WSCONPRO
Consulta Protheus

@author Itamar Gama.:
@since 20/02/2016
@version P12
*/
//-------------------------------------------------------------------
WSSERVICE WSCONPRO DESCRIPTION "Consulta Protheus - Informações Gerais" NAMESPACE XNAMESPACE
	//Consultas
	WSDATA sFilInd				AS FSXENVFilInd
	WSDATA sEmailUser			AS FSXENVEmailUser

	//Retorno da Consulta de Empresa/Filial
	WSDATA SRetornoFilInd 		AS ARRAY OF FSXRETFilInd

	//Retorno da Consulta de Usuários
	WSDATA SRetornoUser 		AS ARRAY OF FSXRETUser

	//Método para consulta Filial
	WSMETHOD ConsultaFilialInd 	DESCRIPTION "Consulta Filial Individual"

	//Método para consulta Usuario por Email
	WSMETHOD ConsultaUser 	DESCRIPTION "Consulta Usuário por E-mail"



ENDWSSERVICE

//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaUser
Método para consultar informações de usuários

@author Itamar Gama .:
@since 20/02/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD ConsultaUser WSRECEIVE sEmailUser WSSEND SRetornoUser WSSERVICE WSCONPRO
 	  Local cNome :=''	
      oNewInf :=  WSClassNew( "FSXRETUser" )	  	
      PswOrder(4)
      If PswSeek(AllTrim(::sEmailUser:EmailUser)  ,.T.)
         aInfUsr := PswRet(1)
         cNome := aInfUsr[1][2]
  	  Else	
  		 cNome := "E-mail não cadastrado"
      EndIf	
	  oNewInf:cNome    := cNome
   	  AAdd( ::SRetornoUser, oNewInf )   
 Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaFilialInd
Método para consultar dados da Filial Individual

@author Itamar Gama .:
@since 20/02/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD ConsultaFilialInd WSRECEIVE sFilInd WSSEND SRetornoFilInd WSSERVICE WSCONPRO
	
	dbSelectArea("SM0")
	dbSetOrder(1)  
	SM0->(dbSeek(Left(AllTrim(FWCodEmp()),2)+AllTrim(::sFilInd:FilInd)))	
	If !Eof()
		oNewSM0 :=  WSClassNew( "FSXRETFilInd" )	
		oNewSM0:cCodEmp    := SM0->M0_CODIGO
		oNewSM0:cEmpresa   := SM0->M0_NOME 
		oNewSM0:cCodFil     := SM0->M0_CODFIL
		oNewSM0:cNomeFil    := SM0->M0_FILIAL
		oNewSM0:cRazao      := SM0->M0_NOMECOM
		oNewSM0:cTelefoneFil:= SM0->M0_TEL
		oNewSM0:cTipoInscr  := IIF(Len(Alltrim(SM0->M0_CGC)) == 14,"JURIDICA","FISICA")	 
		oNewSM0:cCNPJ		:= SM0->M0_CGC		
		oNewSM0:cInscricao  := SM0->M0_INSC	
		oNewSM0:cInscrUF    := SM0->M0_ESTCOB		
		oNewSM0:cInscrMUN   := SM0->M0_INSCM			
		oNewSM0:cEndereco   := SM0->M0_ENDCOB			
		oNewSM0:cComplEnd   := SM0->M0_COMPCOB			
		oNewSM0:cBairro     := SM0->M0_BAIRCOB		
		oNewSM0:cCidade     := SM0->M0_CIDCOB				
		oNewSM0:cUF         := SM0->M0_ESTCOB			
		oNewSM0:cCEP        := SM0->M0_CEPCOB
		oNewSM0:cCodMun     := SM0->M0_CODMUN
		oNewSM0:cCodCNAE    := SM0->M0_CNAE		
		oNewSM0:cCodCEI     := SM0->M0_CEI   
		AAdd( ::SRetornoFilInd, oNewSM0 )
	EndIf
Return .T.



//Estruturas Campos 

//Estrutura Filial
WSSTRUCT FSXRETFilInd     
	WSData cCodEmp     As String
	WsData cEmpresa    As String
	WsData cCodFil     As String
	WsData cNomeFil    As String
	WsData cRazao      As String		
	WsData cTelefoneFil As String
	WsData cTipoInscr  As String  
	WsData cCNPJ	   As String  
	WsData cInscricao  As String		
	WsData cInscrUF    As String		
	WsData cInscrMUN   As String			
	WsData cEndereco   As String			
	WsData cComplEnd   As String			
	WsData cBairro     As String			
	WsData cCidade     As String				
	WsData cUF         As String	
	WsData cCEP        As String	
	WsData cCodMun     As String	
	WsData cCodCNAE    As String		
	WsData cCodCEI    As String	 
ENDWSSTRUCT

WSSTRUCT FSXENVFilInd
	WSDATA FilInd As String
ENDWSSTRUCT

WSSTRUCT FSXENVEmailUser
	WSDATA EmailUser As String
ENDWSSTRUCT

WSSTRUCT FSXRETUser
	WSDATA cNome As String
ENDWSSTRUCT
