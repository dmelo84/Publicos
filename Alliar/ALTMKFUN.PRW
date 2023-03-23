#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALTMKFUN
Funcao Generica para Compilacao

@author Guilherme.Santos
@since 08/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALTMKFUN()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} TMKXCPO
Atribui os Campos do Model de Origem no Model de Destino
No caso de Grids a Grid deve estar posicionada antes da Chamada da Rotina

@author Guilherme.Santos
@since 08/12/2016
@version P12
@param oModOri, Object, Objeto com o Model de Origem dos Dados
@param oModDst, Object, Objeto com o Model de Destino dos Dados (Deve ser passado por referencia. Ex.: @oModDst)
@param cModOri, Caracter, Sub Modelo de Origem dos Dados
@param cModDst, Caracter, Sub Modelo de Destino dos Dados
@param cCpoNao, Caracter, String com os Campos que nao deverao ser Atribuidos
@return lRetorno, logico, Retorna se o Model de Destino foi Atribuido com Sucesso
*/
//-------------------------------------------------------------------
User Function TMKXCPO(oModOri, oModDst, cModOri, cModDst, cCpoNao)
	Local aCpoMod	:= aClone(oModOri:GetModel(cModOri):GetStruct():GetFields())
	Local cCpoMod	:= ""
	Local xConteudo	:= NIL
	Local nCpoMod	:= 0
	Local lRetorno	:= .T.

	Default cCpoNao	:= ""

	For nCpoMod := 1 to Len(aCpoMod)
		If lRetorno
			cCpoMod		:= Alltrim(aCpoMod[nCpoMod][03])
			xConteudo 	:= oModOri:GetModel(cModOri):GetValue(cCpoMod)

			If !Alltrim(cCpoMod) $ cCpoNao .AND. U_TMKXUSO(cCpoMod) .AND. !Empty(xConteudo)
				If oModDst:GetModel(cModDst):CanSetValue(cCpoMod)
					lRetorno := oModDst:LoadValue(cModDst, cCpoMod, xConteudo)
				EndIf
			EndIf
		EndIf
	Next nCpoMod

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} TMKXUSO
Verifica se o Campo informado nos Parametros e usado

@author Guilherme.Santos
@since 08/12/2016
@version P12
@param cCampo, character, Campo a Validar
@return lRetorno, logico, Retorna se o Campo e Usado
*/
//-------------------------------------------------------------------
User Function TMKXUSO(cCampo)
	Local aArea		:= GetArea()
	Local aAreaSX3	:= SX3->(GetArea())
	Local lRetorno 	:= .F.

	DbSelectArea("SX3")
	DbSetOrder(2)

	If SX3->(DbSeek(cCampo)) .AND. SX3->(FIELDGET(FIELDPOS("X3_CONTEXT"))) == "R" .AND. X3Uso((FIELDGET(FIELDPOS("X3_USADO"))))
		lRetorno := .T.
	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} TMKXUNL
Desbloqueia ou Bloqueia um Campo do Model para Edicao

@author Guilherme.Santos
@since 08/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function TMKXUNL(lUnlock, oSubMod, cCampo)
	Local lRetorno := .T.
	
	oSubMod:GetStruct():SetProperty(cCampo, MODEL_FIELD_WHEN, {|| lUnlock})	

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} TMKXERR
Retorna a Mensagem de Erro do Model

@author Guilherme.Santos
@since 08/12/2016
@version P12
@param oModMsg, Objeto, Objeto de onde sera Retornada a Mensagem de Erro
@return cRetorno, Caracter, Mensagem de Erro do Objeto
*/
//-------------------------------------------------------------------
User Function TMKXERR(oModMsg)
	Local aMsgErro 	:= oModMsg:GetErrorMessage()
	Local cRetorno 	:= ""
	Local nI			:= 0

	For nI := 1 to Len(aMsgErro)
		Do Case
			Case ValType(aMsgErro[nI]) == "C"
			cRetorno += aMsgErro[nI] + Space(1)
			Case ValType(aMsgErro[nI]) == "N"
			cRetorno += AllTrim(Str(aMsgErro[nI])) + Space(1)
		EndCase
	Next nI

Return cRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} ALRXFLG
Inicia a Tarefa no Fluig

@author Guilherme.Santos
@since 14/05/2016
@version P12
*/
//-------------------------------------------------------------------
User Function TMKXFLG(aCardData, cProcessID, nChoosedState, cRetWS, cAttach)
	Local nCompanyID		:= Val(SuperGetMv("MV_ECMEMP",.T.,"1"))
	Local cUser             := Alltrim(SuperGetMv("MV_ECMUSER", ,"integradors3@alliar.com") )
	Local cUserID			:= Alltrim( SuperGetMV("MV_ECMMAT", ,"ronaldo.fernandes") )
	Local cUserName			:= Alltrim(SuperGetMv("MV_ECMUSER", ,"integradors3@alliar.com") )
	Local cPassword			:= Alltrim(SuperGetMv("MV_ECMPSW", ,"Supra03@") )
	Local cColleagueIDS		:= Alltrim(SuperGetMv("MV_ECMMAT", ," ") )
	Local aTemp				:= {}
	Local oFluig			:= NIL
	Local nX				:= 0
	Local nY				:= 0
	Local nI				:= 0
	Local xValor			:= NIL
	Local lRetorno			:= .T.
	Local lcompleteTask     := .T.
	Local cString			:= ""
	Local cComments			:= ""
	Local aRet				:= {}
	Local nD				:= 0 
	
	Default aCardData		:= {}
	Default cProcessID		:= "sacAtendimentoPontoFocal"
	Default nChoosedState	:= 24
	Default cRetWS			:= ""
	Default cAttach	:= "" 
	//Default cComments		:= ""
    
    cProcessID		:= "sacAtendimentoPontoFocal"
    nChoosedState	:= 24

	//Instancia WebService Client Fluig   BIWSECMINTEGRATION   Habilitado na rede
	oFluig	:= WSECMWorkflowEngineServiceService():New()
	
	oFluig:cUserName			:= cUserName
	oFluig:cPassword			:= cPassword
	oFluig:nCompanyID			:= nCompanyID
	oFluig:cProcessID			:= cProcessID
	oFLuig:nChoosedState		:= nChoosedState
	oFluig:cColleagueID   		:= cColleagueIDS
	oFluig:cUserID				:= cUserID
	oFluig:lCompleteTask		:= lcompleteTask
	oFluig:lManagerMode			:= .F.
	oFluig:cComments			:= cComments	
	oFluig:_URL					:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	If !Empty(cAttach)
		//Vincula os Dados do Anexo enviado ao FTP     -     Service
		Aadd(oFluig:oWSstartProcessattachments:oWSitem, ECMWorkflowEngineServiceService_processAttachmentDto():New())
		aTail(oFluig:oWSstartProcessattachments:oWSitem):nattachmentSequence := 1
		Aadd(aTail(oFluig:oWSstartProcessattachments:oWSitem):oWSattachments,ECMWorkflowEngineServiceService_attachment():New())
		aTail(aTail(oFluig:oWSstartProcessattachments:oWSitem):oWSattachments):cfilename := cAttach
		aTail(oFluig:oWSstartProcessattachments:oWSitem):ldeleted := .F.
		aTail(oFluig:oWSstartProcessattachments:oWSitem):cdescription := cAttach
		aTail(oFluig:oWSstartProcessattachments:oWSitem):lnewAttach := .T.
		aTail(oFluig:oWSstartProcessattachments:oWSitem):noriginalMovementSequence := 1
	EndIf

	//Atribui CardData
	For nX	:= 1 to Len(aCardData)
		Aadd(oFluig:OWSSTARTPROCESSCARDDATA:oWSitem, ECMWorkflowEngineServiceService_stringArray():New())
		
		For nY := 1 to Len(aCardData[nX])
			/*
			-----------------------------------------------------------------------------------------------------
				Trata valores diferentes de caractere para adicionar no array cItem
				NÃ£o trato valores caractere, pois os mesmos sÃ£o incluidos normalmente no xml
			-----------------------------------------------------------------------------------------------------	
			*/
			xValor := aCardData[nX][nY]

			If ValType(xValor) == "L"
				If xValor
					xValor := "true"
				Else
					xValor := "false"
				EndIf
			ElseIf ValType(xValor) == "D"
				xValor := DtoC(xValor)
			ElseIf ValType(xValor) == "N"
				xValor := AllTrim(Str(xValor))
			EndIf
			
			Aadd(aTail(oFluig:OWSSTARTPROCESSCARDDATA:oWSitem):cItem, xValor)
		Next nY
	Next nX
	
	//Inicia processo no Fluig
	If oFluig:StartProcess()
		If oFluig:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[1] == "ERROR"
			cRetWS 		+= "Erro durante a abertura da solicitacão Fluig." + CRLF
			cRetWS		+= "Descricão do erro: " + CRLF
//			cRetWs		+= oFluig:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[2] + CRLF
			
			//			cRetWs		+= oFluig:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[2] + CRLF

			aRet   := StrTokArr( oFluig:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[2],  chr(13)+chr(10))
			For nD := 1 To Len(aRet)	
				cRetWS += aRet[nD] + chr(13)+chr(10)
			Next nD
			
			
			
			lRetorno 	:= .F.
		Else
			//Numero da Solicitacao de Aprovacao do Fluig
			cRetWs 		:= ""
			lRetorno 	:= .T.

			For nI := 1 to Len(oFluig:OWSSTARTPROCESSRESULT:OWSITEM)
				If AllTrim(oFluig:OWSSTARTPROCESSRESULT:OWSITEM[nI]:cItem[1]) == "iProcess"
					cRetWS := oFluig:OWSSTARTPROCESSRESULT:OWSITEM[nI]:cItem[2]
				EndIf
			Next nI
		EndIf
	Else
		cRetWS 		:= "Erro Durante a Abertura da Solicitacão Fluig.." + CRLF
		cRetWS		+= "Descricão do Erro: " + CRLF
		cRetWs 		+= GetWSCError() + CRLF
		lRetorno 	:= .F.
	EndIf
	
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} TMKXCRD
Adiciona os Dados do Formulario para Envio

@author Guilherme.Santos
@since 06/01/2016
@version P12
*/
//-------------------------------------------------------------------
User Function TMKXCRD(aCardData, cCampo, xValor)
	Local aTemp 			:= {}

	Aadd(aTemp, cCampo)
	Aadd(aTemp, xValor)
	Aadd(aCardData, aClone(aTemp))
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} TMKXCNT
Retorna o Proximo Codigo de Contato Disponivel

@author Guilherme.Santos
@since 23/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function TKMXCNT()
	Local cRetorno := GetSX8Num("SU5", "U5_CODCONT")

	DbSelectArea("SU5")
	DbSetOrder(1)		//U5_FILIAL, U5_CODCONT

	While SU5->(DbSeek(xFilial("SU5") + cRetorno))
		ConfirmSX8()
		cRetorno := GetSX8Num("SU5", "U5_CODCONT")
	End

Return cRetorno 


//-------------------------------------------------------------------
/*{Protheus.doc} TMKENCF
Envia msm encerramento p/ Fluig

@author Guilherme.Santos
@since 03/02/2017
@version P12
*/
//-------------------------------------------------------------------
User Function TMKENCF( cProcessID, nChoosedState, cRetWS)
	Local nCompanyID		:= Val(SuperGetMv("MV_ECMEMP",.T.,"1"))
	Local cUser             := Alltrim(SuperGetMv("MV_ECMUSER", ,"integradors3@alliar.com") )
	Local cUserID			:= Alltrim( SuperGetMV("MV_ECMMAT", ,"ronaldo.fernandes") )
	Local cPassword			:= Alltrim(SuperGetMv("MV_ECMPSW", ,"Supra03@") )
	Local processInstanceId := 0 //Número da Soliciatção no Fluig a ser cancelada
	Local cancelText        := "cancelado por "+cusername //Adionar o nome da operadora canceladora
	Local lRetorno			:= .T.
	Local oFluig			:= NIL
		
	Default cRetWS			:= ""
	
	//Instancia WebService Client Fluig   BIWSECMINTEGRATION   Habilitado na rede
	oFluig	:= WSECMWorkflowEngineServiceService():New()
	
	//IoFluig:cUser				:= cUser
	oFluig:cusername			:= cUser	
	oFluig:cUserID				:= cUserID	
	oFluig:cPassword			:= cPassword
	oFluig:nCompanyID			:= nCompanyID
	oFluig:ccancelText			:= cancelText
	oFluig:nprocessInstanceId	:= cProcessID
	
	oFluig:_URL					:= SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	//Encerra processo no Fluig
	
	If oFluig:cancelInstance()
		If oFluig:CRESULT <> "OK"
			cRetWS 		+= "Erro durante o cancelamento da solicitacão Fluig." + CRLF
			cRetWS		+= "Descricão do erro: " + CRLF
			cRetWs		+= oFluig:CRESULT + CRLF
			lRetorno 	:= .F.
		Else
			//Retorno resultado do Fluig
			cRetWs 		:= ""
			lRetorno 	:= .T.
			cRetWS := oFluig:CRESULT
		EndIf
	Else
		cRetWS 		:= "Erro Durante o cancelamento da Solicitacão Fluig." + CRLF
		cRetWS		+= "Descricão do Erro: " + CRLF
		cRetWs 		+= GetWSCError() + CRLF
		lRetorno 	:= .F.
	EndIf
	
Return lRetorno

//-------------------------------------------------------------------
/*{Protheus.doc} ConsAssF3()
Consulta Assunto F3

@author Itamar Gama .:
@since  27/03/2017
@version P12
*/
//-------------------------------------------------------------------
User Function ConsAssF3()
Local bRet := .F.

Local nX5DESCRI := SX5->(FIELDPOS("X5_DESCRI"))

Private cPosAss	   := aScan(aHeader, {|x| alltrim(x[2]) == "UD_ASSUNTO"})  
Private cPosOco    := aScan(aHeader, {|x| alltrim(x[2]) == "UD_OCORREN"})
Private cPosTPO    := aScan(aHeader, {|x| alltrim(x[2]) == "UD_XCODTPO"})
Private cPosORI    := aScan(aHeader, {|x| alltrim(x[2]) == "UD_XORIENT"})
Private cCodigo    := Alltrim(&(ReadVar()))
Private cCodigo1   := Alltrim("M->UD_OCORREN")

Private aCpoRet	   := {,,,}	
M->UD_ASSUNTO:=''
bRet := FiltraSX5(aCols[n][cPosTPO])     

Return(bRet)


Static Function FiltraSX5(cChave)

Local cQuery	 	:= ""
Local oLstSX5 		:= nil   
Private oDlgSX5 	:= nil
Private _bRet 		:= .F.
Private aDadosSX5	:= {}

//Query de assuntos
cQuery := " SELECT DISTINCT RTRIM( SX5.X5_CHAVE) CHAVE,SX5.X5_DESCRI"
cQuery += " FROM "+RetSQLName("SU9") +" SU9" 
cQuery += " INNER JOIN "+RetSQLName("SX5")+" SX5 ON RTRIM(SX5.X5_CHAVE) = SU9.U9_ASSUNTO AND SX5.X5_TABELA = 'T1'  AND SX5.D_E_L_E_T_ = ''"
cQuery += " WHERE SU9.U9_TIPOOCO = '"+cChave+"' AND SU9.D_E_L_E_T_ = ''"  
cQuery += " GROUP BY RTRIM( SX5.X5_CHAVE),SX5.X5_DESCRI"

cAlias1:= CriaTrab(Nil,.F.)
DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAlias1, .F., .T.)
     
(cAlias1)->(DbGoTop())     
If (cAlias1)->(Eof())
     Aviso( "Assuntos", "Não existe dados a consultar", {"Ok"} )
     Return .F.
Endif

Do While (cAlias1)->(!Eof())
   
     aAdd( aDadosSX5, { (cAlias1)->CHAVE, (cAlias1)->(FIELDGET(nX5DESCRI))} )
     
    (cAlias1)->(DbSkip())
    
Enddo

DbCloseArea(cAlias1)     

nList := aScan(aDadosSX5, {|x| alltrim(x[1]) == alltrim(cCodigo)})

iif(nList = 0,nList := 1,nList)

//--Montagem da Tela
Define MsDialog oDlgSX5 Title "Assuntos" From 0,0 To 280, 500 Of oMainWnd Pixel

@ 5,5 LISTBOX oLstSX5 ;
          VAR lVarMat ;
          Fields HEADER "Assunto", "Desc Assunto";
          SIZE 245,110 On DblClick ( ConfSX5(oLstSX5:nAt, @aDadosSX5, @_bRet) ) ;
          OF oDlgSX5 PIXEL       

oLstSX5:SetArray(aDadosSX5)
oLstSX5:nAt := nList
oLstSX5:bLine := { || {aDadosSX5[oLstSX5:nAt,1], aDadosSX5[oLstSX5:nAt,2]}}

DEFINE SBUTTON FROM 122,5 TYPE 1 ACTION ConfSX5(oLstSX5:nAt, @aDadosSX5, @_bRet) ENABLE OF oDlgSX5     
DEFINE SBUTTON FROM 122,40 TYPE 2 ACTION oDlgSX5:End() ENABLE OF oDlgSX5

Activate MSDialog oDlgSX5 Centered

Return _bRet


Static Function ConfSX5(_nPos, aDadosSX5, _bRet)   

cCodigo := aDadosSX5[_nPos,1]   
aCols[n,cPosAss] := cCodigo    
aCols[n,cPosAss+1] := aDadosSX5[_nPos,2] 

aCpoRet[1] := cCodigo    //Não esquecer de alimentar essa variável quando for f3 pois ela e o retorno e se estiver com valor diferente complica.
aCpoRet[2] := aDadosSX5[_nPos,2] 
_bRet := .T.

oDlgSX5:End()
     
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³TMKUSR01 ºAutor ³Microsiga           º Data ³ 05/09/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function TMKUSR01(cIDUser)
Local cName:=''
Local aUser:={}

// Pesquisa no arquivo de senhas o usuario e valida a senha digitada
If !empty(cIDUser)
     PswOrder(1)
     if PswSeek(cIDUser,.t.)
     	aUser := PSWRET()	// Retorna vetor com informações do usuário 
     	cName:=aUser[1][2]
     endif	
EndIf

Return (cName)




/*/{Protheus.doc} TMKWCPO
Realiza validação dos campos que permitem Edicao (WHEN)
@author Augusto Ribeiro | www.compila.com.br
@since 02/04/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function TMKWCPO()
Local lRet	:= .T.
Local nPosAli, nPosREC, nPosSol

IF TYPE("ALTERA") == "L"
	IF ALTERA
	
		
	
		nPosAli	:= Ascan(aHeader, {|x|AllTrim(x[2]) == "UD_ALI_WT"})
		nPosREC	:= Ascan(aHeader, {|x|AllTrim(x[2]) == "UD_REC_WT"})
		nPosSol	:= Ascan(aHeader, {|x|AllTrim(x[2]) == "UD_SOLUCAO"})
		
		
		/*------------------------------------------------------ Augusto Ribeiro | 08/04/2019 - 4:03:47 PM
			Nao permite alteracao do campos Status quando acao encerramendo com cliente
		------------------------------------------------------------------------------------------*/
		IF ALLTRIM(READVAR()) == "M->UD_STATUS"
			IF nPosSol > 0
				DBSELECTAREA("SUQ")
				SUQ->(DBSETORDER(1)) //| 
				IF SUQ->(DBSEEK(xfilial("SUQ")+aCols[n,nPosSol])) 
					IF SUQ->UQ_STATCH == "3"
						lRet := .F.
					ENDIF						
				ENDIF		
			ENDIF
		ENDIF
		
		
		IF nPosAli > 0 .AND. nPosREC > 0
			IF UPPER(ALLTRIM(aCols[n,nPosAli])) == "SUD"
				nRecSUD	:= aCols[n,nPosREC]
				IF nRecSUD > 0
					DBSELECTAREA("SUD")
					SUD->(DBGOTO(nRecSUD))
					IF !EMPTY(SUD->UD_XIDFLUI) .OR.  SUD->UD_STATUS == "2" //| Encerrado |
						lRet := .F.
					ENDIF
				ENDIF			
			ENDIF
		ENDIF		
	ENDIF
ENDIF


Return(lRet)




