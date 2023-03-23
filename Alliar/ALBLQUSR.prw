#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} ALBLQUSR
Função para bloqueio do Usuario
@author Jonatas Oliveira | www.compila.com.br
@since 09/04/2019
@version 1.0
/*/
User Function ALBLQUSR()
	Local nI		:= 0 
	Local cUsrCod 	:= ""
	Local cUsrName 	:= ""
	Local aRetBlq	:= { .F. , ""}

	Private	aAllusers := FWSFALLUSERS()

	For nI := 1 To len( aAllusers)
		aRetBlq := ALBLQUSR( alltrim( aAllusers[nI][2]))
	Next nI

Return(aRetBlq)

/*/{Protheus.doc} ALBLQUSR
Função para bloqueio do Usuario
@author Jonatas Oliveira | www.compila.com.br
@since 09/04/2019
@version 1.0
/*/
Static Function ALBLQUSR(cCodUsr)
	Local nX 		:= 0 
	Local aDadosUsr	:= {}
	Local aRet 		:= { .F. , ""}
	Local nDiasBlq	:= GetMv("AL_BLQUSR",.F., 90)	
	Local oDataSet
	Local dDtBlqFl
	Local lUserFlg	:= .F.

	Default cCodUsr := ""

	PswOrder(1)//|Codigo|

	_oXMLUSR	:= ""

	IF !EMPTY(cCodUsr)
		IF PswSeek( alltrim(cCodUsr), .T. )
			aDadosUsr	:= PswRet( 1, .F. )
			IF aDadosUsr[1][1] != "000000"

				cUsrCod 	:= aDadosUsr[1][1]
				cUsrName	:= aDadosUsr[1][2]

				IF !aDadosUsr[1][17] //|Bloqueado|
					IF DDATABASE - aDadosUsr[1][16] >= nDiasBlq

						//|Verifica se tem E-Mail Cadastrado|
						IF !EMPTY( aDadosUsr[1][14])

							oDataSet  := WSECMDatasetServiceService():New()

							//|Consultar no Fluig se usuario à mais de x dias sem acesso|
							oDataSet:_URL            	:= SuperGetMV("MV_ECMURL") + "ECMDatasetService"
							oDataSet:ncompanyId   	    := Val(SuperGetMv("MV_ECMEMP"  ,NIL ,1))	
							oDataSet:cusername       	:= SuperGetMv("MV_ECMUSER"     ,NIL ,"integrador")
							oDataSet:cpassword    	    := SuperGetMv("MV_ECMPSW"      ,NIL ,"integrador")
							oDataSet:cname	    	    := "ds_UltimoAcesso"

							aAdd(oDataSet:oWsGetDatasetConstraints:oWsItem,ECMDatasetServiceService_searchConstraintDto():NEW())
							aTail(oDataSet:oWsGetDatasetConstraints:oWsItem):ccontraintType 	:= ""
							aTail(oDataSet:oWsGetDatasetConstraints:oWsItem):cfieldName 		:= "EMAIL"
							aTail(oDataSet:oWsGetDatasetConstraints:oWsItem):cinitialValue 		:= ALLTRIM( aDadosUsr[1][14] )
							aTail(oDataSet:oWsGetDatasetConstraints:oWsItem):cfinalValue 		:= ALLTRIM( aDadosUsr[1][14] )	


							aAdd(oDataSet:oWsGetDatasetConstraints:oWsItem,ECMDatasetServiceService_searchConstraintDto():NEW())
							aTail(oDataSet:oWsGetDatasetConstraints:oWsItem):ccontraintType 	:= ""
							aTail(oDataSet:oWsGetDatasetConstraints:oWsItem):cfieldName 		:= "EMAIL"
							aTail(oDataSet:oWsGetDatasetConstraints:oWsItem):cinitialValue 		:= ALLTRIM( aDadosUsr[1][14] )
							aTail(oDataSet:oWsGetDatasetConstraints:oWsItem):cfinalValue 		:= ALLTRIM( aDadosUsr[1][14] )

							//							WSDLDbgLevel(2)

							If oDataSet:getDataset()
								lUserFlg := .T.

								IF !EMPTY(LEFT(_oXMLUSR:_DATASET:_VALUES:_VALUE[1]:TEXT,10))
									dDtBlqFl := LEFT(_oXMLUSR:_DATASET:_VALUES:_VALUE[1]:TEXT,10)

									dDtBlqFl := cpToDate( dDtBlqFl , 'YYYY-MM-DD','D') 		
								ELSE 
									lUserFlg := .F.
								ENDIF 					
							Else
								aRet[2] := "Problemas com o DataSet informado"							
							EndIf							
						ENDIF 

						If lUserFlg
							If DDATABASE - dDtBlqFl >= nDiasBlq									
								//ConOut( "RETORNO [ALBLQUSR] USUARIO -  " + cUsrCod  + " FLUIG[VENCIDO] PROTHEUS[VENCIDO]")
								//|Bloqueia Usuario|
								IF PswBlock(cUsrName)
									aRet[1]	:= .T.
								ELSE
									aRet[2] := "Falha no Bloqueio do usuario"
								ENDIF															
							Endif 						
						Else							
							//ConOut("RETORNO [ALBLQUSR] USUARIO -  " + cUsrCod  + " FLUIG[NÃO LOCALIZADO] PROTHEUS[VENCIDO]")
							//|Bloqueia Usuario|
							IF PswBlock(cUsrName)
								aRet[1]	:= .T.
							ELSE
								aRet[2] := "Falha no Bloqueio do usuario"
							ENDIF								
						Endif 
					ENDIF 
				ELSE
					aRet[2] := "Usuario ja Bloqueado - " + "[" +cUsrCod +"]" + "[" +cUsrName +"]"
				ENDIF 
			ELSE
				aRet[2] := "Usuario Administrador nao pode ser bloqueado"
			ENDIF 
		ELSE
			aRet[2] := "Usuario nao localizado"
		ENDIF 
	ENDIF 

Return(aRet)


/*/{Protheus.doc} ALBLQJOB
Função para Bloqueio de Usuário via JOB
@author Jonatas Oliveira | www.compila.com.br
@since 15/04/2019
@version 1.0
/*/
User Function ALBLQJOB(aParam)
	Local aParam

	Default aParam := {}

	//Conout("###| U_ALBLQJOB - INICIO: "+DTOC(DATE())+" "+TIME())

	PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2]
	U_ALBLQUSR()//|bloqueio do Usuario|
	RESET ENVIRONMENT	

	//Conout("###| U_ALBLQJOB - FIM: "+DTOC(DATE())+" "+TIME())

Return()

/*/{Protheus.doc} cpToDate
Convert Caracter em Data                                   
_cDate*    : Data a ser convertida                         
_cLayDate* : LayOut da Data                                
_cTpRet    : Tipo de Retorno (D/C/Y) - (D=Date, C=Caracter, S="YYYYMMDD")
@author  www.compila.com.br
@version 1.0
/*/
Static Function cpToDate(_cDate,_cLayDate, _cTpRet)
	Local _cLayDate, _cDate, _cTpRet
	Local xRet		:= ""   
	Local dDtAux	:= ""

	Default	_cTpRet := "D"

	IF !EMPTY(_cLayDate) .AND. !EMPTY(_cDate)

		_cLayDate	:= UPPER(_cLayDate)


		/*-------------------------------------------------------------
		Converte _cDate para data de acordo com o Layout de origem
		---------------------------------------------------------------*/
		IF _cLayDate == "YYYY-MM-DD"		 
			dDtAux	:= STOD(STRTRAN(ALLTRIM(_cDate),"-",""))		
		ENDIF      

		/*-------------------------------------------------------------
		Converte data para o formato desejado
		---------------------------------------------------------------*/
		IF _cTpRet == "C"
			xRet	:= DTOC(dDtAux)
		ELSEIF _cTpRet == "S"
			xRet	:= DTOS(dDtAux)	
		ELSEIF _cTpRet == "D"
			xRet	:= dDtAux
		ENDIF

	ENDIF               

Return(xRet)





User Function TST_USR2()
	Local aDadosUsr := {}
	Local nI		:= 0 
	Local cUsrCod 	:= ""
	Local cUsrName 	:= ""
	Local aRetBlq	:= { .F. , ""}

	Private	aAllusers := FWSFALLUSERS()



	_cEmp		:= "01"
	_cFilial	:= "00101MG0001" 

	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial

	//ConOut( "INICIO [ALBLQUSR]" + DTOC(DATE()) + " " + TIME())
	//	aRetblq := U_ALBLQUSR()
	For nI := 1 To 20
		aRetBlq := ALBLQUSR( alltrim( aAllusers[nI][2]))
		IF !EMPTY(aRetblq[2])
			//ConOut( "RETORNO [ALBLQUSR]" + ALLTRIM(aRetblq[2]) + DTOC(DATE()) + " " + TIME())
		ENDIF 
	Next nI


	//ConOut( "FINAL [ALBLQUSR]" + DTOC(DATE()) + " " + TIME())


	RESET ENVIRONMENT 
Return()


User Function TST_USR3()
	Local aDadosUsr := {}
	Local aRetblq	:= {}
	Local aAllusers	:= {}

	_cEmp		:= "01"
	_cFilial	:= "00101MG0001" 

	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
	//ConOut( "INICIO [ALBLQUSR]" +DTOC(DATE())+" "+TIME())

	aAllusers := FWSFALLUSERS()

	//ConOut( "FINAL [ALBLQUSR]" +DTOC(DATE())+" "+TIME())

	//ConOut("TST_USR3 - Quantidade de Usuarios " + ALLTRIM( STR( LEN( aAllusers ) ) ) )


	RESET ENVIRONMENT 
Return()