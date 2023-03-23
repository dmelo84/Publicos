#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#include "fileio.ch"


/*------------------------------------------------------ Augusto Ribeiro | 27/02/2017 - 8:47:10 AM
		FUNÇÕES GENERICAS PARA INTEGRAÇÃO COM FLUIG
------------------------------------------------------------------------------------------*/


/*/{Protheus.doc} cpFNewTsk
INTEGRACAO FLUIG
Cria nova solicitação no Fluig
@author Jonatas Oliveira | www.compila.com.br
@since 26/05/2017
@version 1.0
@param cIDProc 		- RegistroPresencialdeVisita
@param cUserFluig 	- Usuario Fluig
@param nTaskDest 	- Atividade - 10 
@param cComments	- comments: comentários.
@param lComplete 	- completeTask: indica se deve completar a tarefa (true) ou somente salvar (false).
@param lManager		- managerMode: indica se usuário esta iniciando a solicitação como gestor do processo.
@param aCardData, A, 	[colleagueID]			
						[login]                
						[id_dtVisita]          
						[id_dtregistro]        
						[id_inicio]            
						[id_fim]               
						[id_crmZoom]           
						[txt_crmUF]            
						[txt_segmento]         
						[txt_nomeMedico]       
						[txt_enderecoMedico]   
						[txt_bairroMedico]     
						[txt_municipioMedico]  
						[txt_ufMedico]         
						[txt_cepMedico]        
						[txt_complementoMedico]
						[txt_emailMedico]    	
						[txt_nomeUsuario]      
						[colleagueName]   
@param cUserAtrib	- Usuário que sera atribuido a tarefa
@param aAnexos - {{cPath_Arquivo, cDescricao}}
/*/
User Function cpFNewTsk(cIDProc, cUserFluig, nTaskDest, cComments, lComplete, lManager, aCardData, cUserAtrib, aAnexos)
Local aRet	:= {.f.,"",""}
Local nI, nY, xValor
Local oFluig  := WSECMWorkflowEngineServiceService():new()
//Local cIdFluig	:= "" //|GRAVAR IDFLUIG Z05|

Default lComplete	:= .F.
Default lManager	:= .F.
Default nTaskDest	:= 0
Default aCardData	:= {}
Default cUserAtrib	:= ""
Default aAnexos		:= {}


oFluig:_URL            		:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
oFluig:cusername       		:= SuperGetMv("MV_ECMUSER"     ,NIL ,"integrador")//GETMV("MV_USERFLG"
oFluig:cpassword    	    := SuperGetMv("MV_ECMPSW"      ,NIL ,"integrador")//GETMV("MV_PWDFLG")
oFluig:ncompanyId   	    := Val(SuperGetMv("MV_ECMEMP"  ,NIL ,1))//GETMV("MV_COMPFLG")
oFluig:cprocessId			:= cIDProc
oFluig:nchoosedState	  	:= nTaskDest //| Fim |
oFluig:ccomments			:= cComments
oFluig:cuserId	  			:= cUserFluig
oFluig:lcompleteTask		:= lComplete
oFluig:lmanagerMode			:= lManager
oFluig:nthreadSequence		:= 0


IF !EMPTY(aCardData)

	FOR nI := 1 to len(aCardData)
		Aadd(oFluig:oWSstartprocesscardData:oWSitem, ECMWorkflowEngineServiceService_stringArray():New())	
	
		For nY := 1 to Len(aCardData[nI])
			/*
			-----------------------------------------------------------------------------------------------------
				Trata valores diferentes de caractere para adicionar no array cItem
				Não trato valores caractere, pois os mesmos são incluidos normalmente no xml
			-----------------------------------------------------------------------------------------------------	
			*/
			xValor := aCardData[nI][nY]

			If ValType(xValor) == "L"
				If xValor
					xValor := "true"
				Else
					xValor := "false"
				EndIf
			ElseIf ValType(xValor) == "D"
				xValor := DtoC(xValor)
			ElseIf ValType(xValor) == "N"
				xValor := AllTrim(Transform(xValor, "@E 999,999,999,999.99"))
			EndIf
			
			Aadd(aTail(oFluig:oWSstartprocesscardData:oWSitem):cItem, xValor)
		Next nY	
	
	NEXT nI
ELSE
	oFluig:oWSstartprocessCardData := oFluig:oWSGetInstanceCardDataCardData //AtualizaCardData do método startprocess
ENDIF

oFluig:oWSstartProcesscolleagueIds := ECMWorkflowEngineServiceService_stringArray():New()




IF !EMPTy(cUserAtrib)
	aadd(oFluig:oWSstartProcesscolleagueIds:cItem, cUserFluig)
ENDIF



IF !EMPTY(aAnexos)
	oAttch	:= {}
	//oAttch	:= 
	//oWSsaveAndSendTaskattachments
	FOR nI := 1 TO LEN(aAnexos)
	
		Aadd(oFluig:oWSstartProcessattachments:oWSitem, ECMWorkflowEngineServiceService_processAttachmentDto():NEW())
	
		oFluig:oWSstartProcessattachments:oWSitem[nI]:nattachmentSequence := nI-1
		oFluig:oWSstartProcessattachments:oWSitem[nI]:lNewAttach			 := .T.
		oFluig:oWSstartProcessattachments:oWSitem[nI]:nCompanyId			 := oFluig:ncompanyId
		oFluig:oWSstartProcessattachments:oWSitem[nI]:cdescription			 := IIF(LEN(aAnexos[nI]) >=2, aAnexos[nI,2], aAnexos[nI,1])
			
		Aadd(oFluig:oWSstartProcessattachments:oWSitem[nI]:oWSAttachments, ECMWorkflowEngineServiceService_attachment():new())
		
		
		aRetAux	:= DIRECTORY(aAnexos[nI,1])
			
		oFluig:oWSstartProcessattachments:oWSitem[nI]:oWSAttachments[1]:lattach			:= .T.
		oFluig:oWSstartProcessattachments:oWSitem[nI]:oWSAttachments[1]:lediting		:= .T.
		oFluig:oWSstartProcessattachments:oWSitem[nI]:oWSAttachments[1]:cFileName		:= aRetAux[1,1]	      
		oFluig:oWSstartProcessattachments:oWSitem[nI]:oWSAttachments[1]:nfileSize		:= aRetAux[1,2]
		oFluig:oWSstartProcessattachments:oWSitem[nI]:oWSAttachments[1]:cfilecontent	:= U_CPFTo64(aAnexos[nI,1])
		oFluig:oWSstartProcessattachments:oWSitem[nI]:oWSAttachments[1]:lprincipal		:= .T.	
	
	NEXT nI
	
ENDIF




WSDLDbgLevel(2)

IF oFluig:startprocess()

	if len(oFluig:oWSstartprocessresult:oWSitem) >= 1
	
		FOR nI := 1 TO LEN(oFluig:oWSstartprocessresult:oWSitem)
			IF upper(alltrim(oFluig:oWSstartprocessresult:oWSitem[nI]:citem[1])) == "ERROR"
				aRet[2] := 'Ocorreu um erro e o processo não pode ser finalizado. '+oFluig:oWSstartprocessresult:oWSitem[nI]:citem[2]
				exit
			ELSEIF upper(alltrim(oFluig:oWSstartprocessresult:oWSitem[nI]:citem[1])) == "IPROCESS"
				aRet[1]	:= .T.
				aRet[2] := ""
				aRet[3] := oFluig:oWSstartprocessresult:oWSitem[nI]:citem[2]
				exit
			ELSE 
				aRet[2] := 'Retorno Fluig Vazio '
			ENDIF
			
		NEXT nI
		
		/*
		IF UPPER(LEFT(oFluig:oWSstartprocessresult:oWSitem[1]:citem[1], 5)) <> "ERROR"
			aRet[1]	:= .T.
			
//			aRet[3] := oFluig:oWSstartprocessresult:oWSitem[6]:citem[2]
			
			For nI := 1 to Len(oFluig:OWSSTARTPROCESSRESULT:OWSITEM)
				If AllTrim(oFluig:OWSSTARTPROCESSRESULT:OWSITEM[nI]:cItem[1]) == "iProcess"
					aRet[3] := oFluig:OWSSTARTPROCESSRESULT:OWSITEM[nI]:cItem[2]
				EndIf
			Next nI
			
		else
			aRet[2] := 'Ocorreu um erro e o processo não pode ser finalizado. '+oFluig:oWSstartprocessresult:oWSitem[1]:citem[2]
		endif
		*/
	else
		aRet[2] := 'Ocorreu um erro e o processo não pode ser finalizado. Retorno Vazio '		
	endif

ELSE
	aRet[2] := 'Ocorreu um erro no processo de integração!'+chr(13)+GetWSCError()
ENDIF

Return(aRet)






/*/{Protheus.doc} cpFSSTsk
INTEGRACAO FLUIG
CHAMADA DO saveAndSendTask
@author Augusto Ribeiro | www.compila.com.br
@since 24/02/2017
@version undefined
@param nIDProc, 
@param cUserFluig, 
@param cComments, 
@param aAnexos - {{cPath_Arquivo, cDescricao}}
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function  cpFSSTsk(nIDProc, cUserFluig, nTaskDest, cComments, lComplete, lManager, aCardData, aAnexos)
Local aRet	:= {.f.,""}
Local nI, nY, xValor
Local oFluig  := WSECMWorkflowEngineServiceService():new()

Default lComplete	:= .F.
Default lManager	:= .F.
Default nTaskDest	:= 0
Default aCardData	:= {}
Default aAnexos		:= {}


oFluig:_URL            		:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
oFluig:cusername       		:= SuperGetMv("MV_ECMUSER"     ,NIL ,"integrador")//GETMV("MV_USERFLG"
oFluig:cpassword    	    := SuperGetMv("MV_ECMPSW"      ,NIL ,"integrador")//GETMV("MV_PWDFLG")
oFluig:ncompanyId   	    := Val(SuperGetMv("MV_ECMEMP"  ,NIL ,1))//GETMV("MV_COMPFLG")
oFluig:nprocessInstanceId	:= nIDProc
oFluig:nchoosedState	  	:= nTaskDest //| Fim |
oFluig:ccomments			:= cComments
oFluig:cuserId	  			:= cUserFluig
oFluig:lcompleteTask		:= lComplete
oFluig:lmanagerMode			:= lManager
oFluig:nthreadSequence		:= 0



IF !EMPTY(aAnexos)
	oAttch	:= {}
	//oAttch	:= 
	//oWSsaveAndSendTaskattachments
	FOR nI := 1 TO LEN(aAnexos)
	
		Aadd(oFluig:oWSsaveAndSendTaskattachments:oWSitem, ECMWorkflowEngineServiceService_processAttachmentDto():NEW())
	
		oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:nattachmentSequence 	:= nI-1
		oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:lNewAttach			 	:= .T.
		oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:nCompanyId			 	:= oFluig:ncompanyId
		oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:cdescription			:= IIF(LEN(aAnexos[nI]) >=2, aAnexos[nI,2], aAnexos[nI,1])
			
		Aadd(oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:oWSAttachments, ECMWorkflowEngineServiceService_attachment():new())
		
		
		aRetAux	:= DIRECTORY(aAnexos[nI,1])
			
		oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:oWSAttachments[1]:lattach			:= .T.
		oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:oWSAttachments[1]:lediting			:= .T.
		oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:oWSAttachments[1]:cFileName		:= aRetAux[1,1]	      
		oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:oWSAttachments[1]:nfileSize		:= aRetAux[1,2]
		oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:oWSAttachments[1]:cfilecontent		:= U_CPFTo64(aAnexos[nI,1])
		oFluig:oWSsaveAndSendTaskattachments:oWSitem[nI]:oWSAttachments[1]:lprincipal		:= .T.	
	
	NEXT nI
	
ENDIF




WSDLDbgLevel(2)  

IF !EMPTY(aCardData)

	FOR nI := 1 to len(aCardData)
		Aadd(oFluig:oWSsaveAndSendTaskcardData:oWSitem, ECMWorkflowEngineServiceService_stringArray():New())	
	
		For nY := 1 to Len(aCardData[nI])
			/*
			-----------------------------------------------------------------------------------------------------
				Trata valores diferentes de caractere para adicionar no array cItem
				Não trato valores caractere, pois os mesmos são incluidos normalmente no xml
			-----------------------------------------------------------------------------------------------------	
			*/
			xValor := aCardData[nI][nY]

			If ValType(xValor) == "L"
				If xValor
					xValor := "true"
				Else
					xValor := "false"
				EndIf
			ElseIf ValType(xValor) == "D"
				xValor := DtoC(xValor)
			ElseIf ValType(xValor) == "N"
				xValor := AllTrim(Transform(xValor, "@E 999,999,999,999.99"))
			EndIf
			
			Aadd(aTail(oFluig:oWSsaveAndSendTaskcardData:oWSitem):cItem, xValor)
		Next nY	
	
	NEXT nI
ELSE
	oFluig:oWSSaveAndSendTaskCardData := oFluig:oWSGetInstanceCardDataCardData //AtualizaCardData do método SaveAndSendTask
ENDIF

//oWSsaveAndSendTaskcardData


WSDLDbgLevel(2)  

IF oFluig:saveAndSendTask()

	if len(oFluig:oWSsaveAndSendTaskresult:oWSitem) >= 1
	
		IF UPPER(LEFT(oFluig:oWSsaveAndSendTaskresult:oWSitem[1]:citem[1], 5)) <> "ERROR"
			aRet[1]	:= .T.
		else
			aRet[2] := 'Ocorreu um erro e o processo não pode ser finalizado. ' +oFluig:oWSsaveAndSendTaskresult:oWSitem[1]:citem[2]
		endif
	else
		aRet[2] := 'Ocorreu um erro e o processo não pode ser finalizado. Retorno Vazio '		
	endif

ELSE
	aRet[2] := 'Ocorreu um erro no processo de integração!'+GetWSCError()
ENDIF

Return(aRet)




/*/{Protheus.doc} flgCancP
INTEGRACAO FLUIG
CHAMADA DO cancelInstance
@author Augusto Ribeiro | www.compila.com.br
@since 24/02/2017
@version undefined
@param nIDProc, 
@param cUserFluig, 
@param cComments, 
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function cpFCancI(nIDProc)
Local aRet	:= {.f.,""}
Local oFluig := WSECMWorkflowEngineServiceService():new()

oFluig:_URL := SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"

if oFluig:cancelInstance(SuperGetMv("MV_ECMUSER"    ,NIL ,"integrador"),;
                        SuperGetMv("MV_ECMPSW"     ,NIL ,"integrador"),;
                        VAL(SuperGetMv("MV_ECMEMP" ,NIL ,1)),;
                        nIDProc,;
                        SuperGetMv("MV_ECMMAT"),;
                        "Processo cancelado através da integração com o Protheus") 
	//Se processamento ocorrer sem erros exibe o valor de retorno
	
	aRet[1]	:= .T. 
else
	//MsgStop("Erro na integração com o Fluig: " + GetWSCError(3))
	aRet[2]	:= "Erro na integração com o Fluig: " + GetWSCError(3)
endIf

Return(aRet)




//-------------------------------------------------------------------
/*{Protheus.doc} AddCard
Adiciona os Dados do Formulario para Envio

@author Guilherme.Santos
@since 06/01/2016
@version P12
*/
//-------------------------------------------------------------------
User Function cpFaadd(aCardData, cCampo, xValor)
	Local aTemp := {}

	Aadd(aTemp, cCampo)
	Aadd(aTemp, xValor)
	Aadd(aCardData, aClone(aTemp))
Return NIL





/*/{Protheus.doc} cpIdFlg
Busca o Id do usuário no Fluig
@author Jonatas Oliveira | www.compila.com.br
@since 25/05/2017
@version 1.0
/*/
User Function  cpIdFlg(cMailbs)
Local aRet	:= {.f.,"",{"","",""}}
Local nI, nY, xValor
Local oFluig  := UWSECMCOLLEAGUESERVICESERVICE():new()

Local _CCOLLID		:= ""
Local _CCOLLNAME	:= ""
Local _CLOGIN		:= ""

oFluig:_URL            		:= SuperGetMV("MV_ECMURL") + "ECMColleagueService"
oFluig:cusername       		:= SuperGetMv("MV_ECMUSER"     ,NIL ,"integrador")//GETMV("MV_USERFLG"
oFluig:cpassword    	    := SuperGetMv("MV_ECMPSW"      ,NIL ,"integrador")//GETMV("MV_PWDFLG")
oFluig:ncompanyId   	    := Val(SuperGetMv("MV_ECMEMP"  ,NIL ,1))//GETMV("MV_COMPFLG")
oFluig:cmail				:= cMailbs//"diego.humberto@compila.com.br"

WSDLDbgLevel(2)
IF oFluig:getColleaguesMail()

	if len(OFLUIG:OWSGETCOLLEAGUESMAILRESULT:OWSITEM) >= 1
	
		IF !EMPTY(OFLUIG:OWSGETCOLLEAGUESMAILRESULT:OWSITEM[1]:CLOGIN)
			aRet[3][1] := OFLUIG:OWSGETCOLLEAGUESMAILRESULT:OWSITEM[1]:CCOLLEAGUEID
			aRet[3][2] := OFLUIG:OWSGETCOLLEAGUESMAILRESULT:OWSITEM[1]:CCOLLEAGUENAME
			aRet[3][3] := OFLUIG:OWSGETCOLLEAGUESMAILRESULT:OWSITEM[1]:CLOGIN
			
			aRet[1]	:= .T.
		else
			aRet[2] := 'Ocorreu um erro e o processo não pode ser finalizado ' 
		endif
	else
		aRet[2] := 'Ocorreu um erro e o processo não pode ser finalizado. Retorno Vazio '		
	endif

ELSE
	aRet[2] := 'Ocorreu um erro no processo de integração!'+chr(13)+GetWSCError()
ENDIF

Return(aRet)


/*/{Protheus.doc} cpVisit
Inclusão de visita no Fluig
@author Jonatas Oliveira | www.compila.com.br
@since 26/05/2017
@version 1.0
@param cIDProc 		- RegistroPresencialdeVisita
@param cUserFluig 	- Usuario Fluig
@param nTaskDest 	- Atividade - 10 
@param cComments	- comments: comentários.
@param lComplete 	- completeTask: indica se deve completar a tarefa (true) ou somente salvar (false).
@param lManager		- managerMode: indica se usuário esta iniciando a solicitação como gestor do processo.
@param aCardData, A, 	[colleagueID]			
						[login]                
						[id_dtVisita]          
						[id_dtregistro]        
						[id_inicio]            
						[id_fim]               
						[id_crmZoom]           
						[txt_crmUF]            
						[txt_segmento]         
						[txt_nomeMedico]       
						[txt_enderecoMedico]   
						[txt_bairroMedico]     
						[txt_municipioMedico]  
						[txt_ufMedico]         
						[txt_cepMedico]        
						[txt_complementoMedico]
						[txt_emailMedico]    	
						[txt_nomeUsuario]      
						[colleagueName]   
/*/
User Function cpVisit (cIDProc, cUserFluig, nTaskDest, cComments, lComplete, lManager, aCardData)
Local aRet	:= {.f.,"",""}
Local nI, nY, xValor
Local oFluig  := WSECMWorkflowEngineServiceService():new()
//Local cIdFluig	:= "" //|GRAVAR IDFLUIG Z05|

Default lComplete	:= .F.
Default lManager	:= .F.
Default nTaskDest	:= 0
Default aCardData	:= {}


oFluig:_URL            		:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
oFluig:cusername       		:= SuperGetMv("MV_ECMUSER"     ,NIL ,"integrador")//GETMV("MV_USERFLG"
oFluig:cpassword    	    := SuperGetMv("MV_ECMPSW"      ,NIL ,"integrador")//GETMV("MV_PWDFLG")
oFluig:ncompanyId   	    := Val(SuperGetMv("MV_ECMEMP"  ,NIL ,1))//GETMV("MV_COMPFLG")
oFluig:cprocessId			:= cIDProc
oFluig:nchoosedState	  	:= nTaskDest //| Fim |
oFluig:ccomments			:= cComments
oFluig:cuserId	  			:= cUserFluig
oFluig:lcompleteTask		:= lComplete
oFluig:lmanagerMode			:= lManager
oFluig:nthreadSequence		:= 0


IF !EMPTY(aCardData)

	FOR nI := 1 to len(aCardData)
		Aadd(oFluig:oWSstartprocesscardData:oWSitem, ECMWorkflowEngineServiceService_stringArray():New())	
	
		For nY := 1 to Len(aCardData[nI])
			/*
			-----------------------------------------------------------------------------------------------------
				Trata valores diferentes de caractere para adicionar no array cItem
				Não trato valores caractere, pois os mesmos são incluidos normalmente no xml
			-----------------------------------------------------------------------------------------------------	
			*/
			xValor := aCardData[nI][nY]

			If ValType(xValor) == "L"
				If xValor
					xValor := "true"
				Else
					xValor := "false"
				EndIf
			ElseIf ValType(xValor) == "D"
				xValor := DtoC(xValor)
			ElseIf ValType(xValor) == "N"
				xValor := AllTrim(Transform(xValor, "@E 999,999,999,999.99"))
			EndIf
			
			Aadd(aTail(oFluig:oWSstartprocesscardData:oWSitem):cItem, xValor)
		Next nY	
	
	NEXT nI
ELSE
	oFluig:oWSstartprocessCardData := oFluig:oWSGetInstanceCardDataCardData //AtualizaCardData do método startprocess
ENDIF

oFluig:oWSstartProcesscolleagueIds := ECMWorkflowEngineServiceService_stringArray():New()



aadd(oFluig:oWSstartProcesscolleagueIds:cItem, cUserFluig)


WSDLDbgLevel(2)

IF oFluig:startprocess()

	if len(oFluig:oWSstartprocessresult:oWSitem) >= 1
	
		IF UPPER(LEFT(oFluig:oWSstartprocessresult:oWSitem[1]:citem[1], 5)) <> "ERROR"
			aRet[1]	:= .T.
			
			aRet[3] := oFluig:oWSstartprocessresult:oWSitem[5]:citem[2]
			
		else
			aRet[2] := 'Ocorreu um erro e o processo não pode ser finalizado ' +chr(13)+oFluig:oWSstartprocessresult:oWSitem[1]:citem[2]
		endif
	else
		aRet[2] := 'Ocorreu um erro e o processo não pode ser finalizado. Retorno Vazio '		
	endif

ELSE
	aRet[2] := 'Ocorreu um erro no processo de integração!'+chr(13)+GetWSCError()
ENDIF

Return(aRet)

/*/{Protheus.doc} CPGRPUSR
Retorna os grupos de usuarios do Protheus
@author Jonatas Oliveira | www.compila.com.br
@since 15/06/2017
@version 1.0
/*/
User Function CPGRPUSR()
	Local aRet := AllGroups()                            
	Local nI
	Local aGrupos := {}
	
	For nI := 1 to Len(aRet)	
		Aadd(aGrupos, {aRet[nI][1][1],aRet[nI][1][2]})
	Next
		
Return(aGrupos)


/*/{Protheus.doc} CPGRPUSR
Retorna os usuarios do Protheus
@author Jonatas Oliveira | www.compila.com.br
@since 15/06/2017
@version 1.0
/*/
User Function USRPROT(_cEmpPsq)
	Local aRet := AllUsers()   
	Local aGrpEmp	:= {}                         
	
	Local nI
	Local aUsers 	:= {}
	
	
	Default _cEmpPsq	:= "001"
	
	For nI := 1 to Len(aRet)
		
		//|Não apresenta usuário Bloqueado|
		IF !ARET[nI][1][17]
			
			aGrpEmp	:= {} 
			
			aGrpEmp := ARET[nI][2][6]
			
			//|Apenas usuários com acesso à todas empresas ou da empresa informada no parametro|
			IF aScan(aGrpEmp,{|x| AllTrim(x) == '@@@@'}) > 0  .OR. aScan(aGrpEmp,{|x| SUBSTR(x,3,3) == _cEmpPsq}) > 0 
				Aadd(aUsers, {ARET[nI][1][1] , ARET[nI][1][2] , ARET[nI][1][4]})
			ENDIF 
		 
		ENDIF 
	Next nI
Return(aUsers)






/*/{Protheus.doc} cpFTakeP
INTEGRACAO FLUIG
CHAMADA DO takeProcessTask
@author Augusto Ribeiro | www.compila.com.br
@since 10/02/2017
@version undefined
@param nIDProc, 
@param cUserFluig, 
@param cComments, 
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function  cpFTakeP(nIDProc, cUserFluig,nTaskDest)
Local aRet	:= {.f.,""}
Local nI, nY, xValor
Local oFluig  := WSECMWorkflowEngineServiceService():new()

Default nTaskDest	:= 0



oFluig:_URL            		:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
oFluig:cusername       		:= SuperGetMv("MV_ECMUSER"     ,NIL ,"integrador")//GETMV("MV_USERFLG"
oFluig:cpassword    	    := SuperGetMv("MV_ECMPSW"      ,NIL ,"integrador")//GETMV("MV_PWDFLG")
oFluig:ncompanyId   	    := Val(SuperGetMv("MV_ECMEMP"  ,NIL ,1))//GETMV("MV_COMPFLG")
oFluig:nprocessInstanceId	:= nIDProc

IF nTaskDest > 0 
	oFluig:nchoosedState	  	:= nTaskDest //| Fim |
ENDIF 

oFluig:cuserId				:= cUserFluig
oFluig:nthreadSequence		:= 0

WSDLDbgLevel(2)  

IF oFluig:takeProcessTask()

	if iif(!empty(oFluig:cresult), UPPER(alltrim(oFluig:cresult)) == "OK",.F.) 
		aRet[1]	:= .T.
	else
		aRet[2] := "Erro ao assumir tarefa. "+alltrim(oFluig:cresult)		
	endif

ELSE
	aRet[2] := 'Ocorreu um erro no processo de integração!'+GetWSCError()
ENDIF

Return(aRet)




/*/{Protheus.doc} CPDOMIN
Grava em tabela auxiliar os dados do paciente e dominio
@author Jonatas Oliveira | www.compila.com.br
@since 23/10/2017
@version 1.0
@param cIdPler, C, IDPLERES
@param cDomin, C, Dominio
@param cCpf, C, CPF
/*/
User Function CPDOMIN(cIdPler,cDomin, cCpf)
	Local nI := 0 

	DBSELECTAREA("Z30")
	Z30->(DBSETORDER(1))
	
	nTotCpo	:= Z30->(FCount())
	
	RegToMemory("Z30",.T.)
	
	M->Z30_XIDPLE	:= cIdPler
	M->Z30_DOMINI	:= cDomin
	M->Z30_CPF		:= cCpf
	
	RECLOCK("Z30",.T.)
	
	For nI := 1 To nTotCpo
		FieldPut(nI, M->&(FIELDNAME(nI)) )
	Next nI
	
	MSUNLOCK()
	CONFIRMSX8()
	
	
Return()




/*/{Protheus.doc} CPFTo64
Converte arquivo passado para base64
@author desconhecido
@since 18/10/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User function CPFTo64(cDoc) 
local _cImgBuffer :='' 
local _nRead := 0
local _nSize := 0
Local nArq
	nArq := fOpen(cDoc, FO_READWRITE)	// Abre o arquivo  
	
		if(fError() <> 0 .AND. nArq == -1)
		  //	msgAlert("Erro de abertura. Código: " + str(fError()))
		else 
			_nSize		:= fSeek(nArq,0,2)
			fSeek(nArq,0,0)						// Retorna à posição inicial do ponteiro
			//fSeek(cArq,0,1)					// Fornece a posição atual do ponteiro
	
		   	_cImgBuffer := space(_nSize)
			_nRead		:= fRead(nArq,@_cImgBuffer,_nSize) // converte o arquivo fisico em base64
		 
		endif	
	fClose(nArq)

Return _cImgBuffer  




/*/{Protheus.doc} cpLogAPI
Grava dados da API como log para auditar rotinas
@author Augusto Ribeiro | www.compila.com.br
@since 27/02/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function cpLogAPI(cRestApi, cJsonRet)
Local lRet	:= .F.



IF !EMPTY(cRestApi) .AND. !EMPTY(cJsonRet)
 	DBSELECTAREA("Z08")
	RegToMemory("Z08", .T., .F.)

	RecLock("Z08", .T.)
	
	/*--------------------------
		Nomeado cada campo para otimizar performance
	---------------------------*/

	M->Z08_REST		:= cRestApi
	M->Z08_RETJSO	:= cJsonRet

	nTotCpo	:= Z08->(FCOUNT()) 
	For nI := 1 To nTotCpo
		cNameCpo	:= ALLTRIM(Z08->(FIELDNAME(nI)))

		FieldPut(nI, M->&(cNameCpo) )
	Next nI
	
	Z08->(MsUnLock())
	CONFIRMSX8()
ENDIF 


Return(lRet)

/*/{Protheus.doc} cpCnFlg
Cancela Solicitacao no Fluig
@author Jonatas Oliveira | www.compila.com.br
@since 04/07/2019
@version 1.0
/*/
User Function cpCnFlg(nIdFlg, cUserFlg, cTexCan)
Local aRet	:= { .F.,""}
Local nI, nY, xValor
Local oFluig  := WSECMWorkflowEngineServiceService():new()
//
Local _CCOLLID		:= ""
Local _CCOLLNAME	:= ""
Local _CLOGIN		:= ""

oFluig:_URL            		:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
oFluig:cusername       		:= SuperGetMv("MV_ECMUSER"     ,NIL ,"integrador")//GETMV("MV_USERFLG"
oFluig:cpassword    	    := SuperGetMv("MV_ECMPSW"      ,NIL ,"integrador")//GETMV("MV_PWDFLG")
oFluig:ncompanyId   	    := Val(SuperGetMv("MV_ECMEMP"  ,NIL ,1))//GETMV("MV_COMPFLG")
oFluig:nprocessInstanceId   := nIdFlg
oFluig:cuserId	  			:= cUserFlg
oFluig:ccancelText  			:= cTexCan 
oFluig:creplacementId 		:= GETMV("MV_ECMMAT",.F.,"")


WSDLDbgLevel(2)
IF oFluig:cancelInstanceByReplacement()

	if iif(!empty(oFluig:cresult), UPPER(alltrim(oFluig:cresult)) == "OK",.F.) 
		aRet[1]	:= .T.
	else
		aRet[2] := "Erro ao assumir tarefa. "+alltrim(oFluig:cresult)		
	endif

ELSE
	aRet[2] := 'Ocorreu um erro no processo de integração!'+GetWSCError()
ENDIF

Return(aRet)

/*/{Protheus.doc} cpxCJson
Realiza consulta generica no Protheus conforme parametros passados 
@author Augusto Ribeiro | www.compila.com.br
@since 20/03/2019
@version 6
@param cJson, Json Post
@return cRet, Json de retorno com dados da consulta
@example
(examples)
@see (links_or_references)
/*/
User Function cpxCJson(cJson)
Local cRet		:= ""
Local oJson, nI
Local cCampos	:= ""
Local cQuery	:= ""
Local cFilQry	:= ""
Local cJoin		:= ""
Local aTipoDado	:= {}
Local cLog 		:= "" 
Local lEBlock	:= .F.
Local nCpoQery, lAlltrim, cTipo, cTam, nPos
Local oErro 	:= ErrorBlock({|e| DisarmTransaction() ,lEBlock := .T., cLog := IIF(VALTYPE(e:Description)=="C", e:Description,"[cpxCJson] Falha da rotina cpxCJson")})


IF FWJsonDeserialize(cJson,@oJson)


	
	IF AttIsMemberOf(oJson , "ALIAS") .AND. AttIsMemberOf(oJson , "CAMPOS")
	
		/*------------------------------------------------------ Augusto Ribeiro | 21/03/2019 - 8:35:51 AM
			Verifica se realiza ALLTRIM no retorno da String
		------------------------------------------------------------------------------------------*/
		IF AttIsMemberOf(oJson , "TRIM") //|1=SIM, 2=NAO|
			lAlltrim	:= oJson:TRIM == 1
		ELSE
			lAlltrim	:= .T.
		ENDIF
	
		BEGIN SEQUENCE	
	
		oJson:ALIAS	:= ALLTRIM(oJson:ALIAS)
		

		/*------------------------------------------------------ Augusto Ribeiro | 20/03/2019 - 4:28:40 PM
		 Montas campos da para retorno na Query
		------------------------------------------------------------------------------------------*/
		FOR nI := 1 to len(oJson:CAMPOS)		
			if !empty(cCampos)
				cCampos += ', '
			endif
			cCampos	+= ALLTRIM(oJson:CAMPOS[nI])
				
				
				
		NEXT nI	
		
		/*------------------------------------------------------ Augusto Ribeiro | 20/03/2019 - 4:32:56 PM
			Monta Array de filiais
		------------------------------------------------------------------------------------------*/
		IF  AttIsMemberOf(oJson , "FILIAL")
			FOR nI := 1 to len(oJson:FILIAL)		
				if !empty(cFilQry)
					cFilQry += ','
				endif
				cFilQry	:= ALLTRIM(oJson:FILIAL[nI])
			NEXT nI			
		ENDIF
		
		cQuery	:= "SELECT "+cCampos
		cQuery	+= " FROM "+RetSqlname(oJson:ALIAS) +" "+oJson:ALIAS
		
		IF AttIsMemberOf(oJson , "JOIN") 
			cJoin	:= oJson:JOIN
			IF !EMPTY(cJoin)
				nTravaLoop := 0 //| Evitar loop infinito |
				nPos		:= AT("_#",cJoin)
				While nPos > 0
					nTravaLoop++
					If nTravaLoop >= 40
						CONOUT("cpxCJson", "Loop infinito abortado")
						EXIT
					endif
														
				
					nPos		:= AT("_#",cJoin)
					IF nPos > 0
						cAux		:= SUBSTR(cJoin, nPos,5)
						cTabJoin	:= RIGHT(cAux,3)
						
						//| Substitui o Coringa da tabela pela tabela da empresa no Protheus |
						cJoin		:= STRTRAN(cJoin,cAux,RetSqlName(cTabJoin))
					ENDIF 
				ENDDO
			ENDIF
			
			
			cQuery	+= " "+cJoin+" "
		ENDIF
		
		IF !EMPTY(cFilQry)
			cQuery	+= " WHERE "+IIF(UPPER(LEFT(oJson:ALIAS,1))=="S",RIGHT(oJson:ALIAS,2),oJson:ALIAS)+"_FILIAL IN "+FormatIn(cFilQry,",")
			cQuery	+= " AND "+oJson:ALIAS+".D_E_L_E_T_ <> '*' "
		ELSE
			cQuery	+= " WHERE "+oJson:ALIAS+".D_E_L_E_T_ <> '*' "
		ENDIF 
		IF  AttIsMemberOf(oJson , "WHEREQRY")
			IF !EMPTY(oJson:WHEREQRY)
				cQuery	+= "AND "+oJson:WHEREQRY
			ENDIF
		ENDIF
		
				
		If Select("TQRY") > 0
			TQRY->(DbCloseArea())
		EndIf
		
		DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TQRY",.F., .T.)						

		IF TQRY->(!EOF())
		
			cRet		:= '{"CAMPOS":['
			
		
			/*------------------------------------------------------ Augusto Ribeiro | 20/03/2019 - 4:47:08 PM
				Monta trecho com dados dos campos
			------------------------------------------------------------------------------------------*/
			DBSELECTAREA("SX3")
			SX3->(DBSETORDER(2)) //| 
			
			nCpoQery	:= TQRY->(FCOUNT())
			FOR nI := 1 to nCpoQery
				cCpoQry	:= TQRY->(FieldName(nI))
				
				
				IF nI > 1
				cRet	+= ","	
				ENDIF
				cRet	+= '{'
				cRet	+= U_cpxToJson("CAMPO", cCpoQry)+","
				

	
				cTipo	:= ""
				cTam	:= 0
				IF SX3->(DBSEEK(cCpoQry))
					cTipo	:= SX3->X3_TIPO
					cTam	:= SX3->X3_TAMANHO
				ELSE
					cTipo	:= VALTYPE(TQRY->(FIELDGET(nI)))				
				endif
				
				cRet	+= U_cpxToJson("TIPO", cTipo)+","
				cRet	+= U_cpxToJson("TAM", cTam)
				cRet	+= '}'
				
				aadd(aTipoDado,cTipo)
			NEXT nI
			cRet	+= "],"
			cRet	+= '"DADOS":['
			
		
			nQtdeReg	:= 0
			WHILE TQRY->(!EOF())
				nQtdeReg++
				IF nQtdeReg > 1
					cRet	+= ','
				endif				
				
				cRet	+= '['
				FOR nI := 1 to nCpoQery
					IF nI > 1
						cRet	+= ','
					endif
					IF aTipoDado[nI] == "N"
						cRet	+= ALLTRIM(STR(TQRY->(FIELDGET(nI))))
					ELSE
						cAux	:= REPLACE(TQRY->(FIELDGET(nI)),'"',' ')
						cAux	:= REPLACE(cAux,'\',' ')
						IF lAlltrim
							cAux	:= alltrim(cAux)							
						ENDIF
						cRet	+= '"'+cAux+'"'
					ENDIF
				NEXT nI
				cRet	+= ']'
				
				TQRY->(DBSKIP()) 
			ENDDO		
			
			cRet	+= "]"
			cRet	+= "}"
		ENDIF	
		
		TQRY->(DbCloseArea())	
	
		END SEQUENCE
	
	ELSE
		conout("cpxCJson","Obrigatorio informar ALIAS e CAMPOS de retorno")
	ENDIF
	
	
	
ELSE
	conout("cpxCJson","Json Invalido")
ENDIF

ErrorBlock(oErro)

IF lEBlock
	//aRet[1]	:= .F.
	//aRet[2]	:= cLog
	CONOUT("cpxCJson ERROR", cLog)
ENDIF


Return(cRet)



