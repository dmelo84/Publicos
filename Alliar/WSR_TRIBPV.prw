#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

/*/{Protheus.doc} WSR_TRIBPV
Rest responsavel em gravar tributos no PV
@author Jonatas Oliveira | www.compila.com.br
@since 24/06/2019
@version 1.0
/*/
user function WSR_TRIBPV()
return


WSRESTFUL TRIBUTOS DESCRIPTION "Serviço REST para manipulação de Tributos PEDIDO"



//WSMETHOD GET DESCRIPTION "Retorna o PACIENTES informado na URL" WSSYNTAX "/PACIENTES || /PACIENTES/{crm}"
WSMETHOD POST DESCRIPTION "Insere TRIBUTOS" WSSYNTAX " /TRIBUTOS/{}"

END WSRESTFUL




WSMETHOD POST  WSSERVICE TRIBUTOS
	Local oObjProd := Nil
	Local cStatus  := ""
	LOcal cBody		:= ""
	Local cJRetOK   := '{"code":200,"status":"success"}'
	Local oJson	
	Local lRet		:= .F.

	//Local aPacien	:= {}
	//Local aContato	:= {}
	//Local aEndereco := {}
	//Local aTelefone := {}
	//Local aAuxDados := {}
	Local nOpcPac	:= 0 //|3- Inclusão, 4- Alteração, 5- Exclusão|

	Local cFilPV	:= "" 
	Local cPleres	:= ""
	Local cIdFluig	:= ""
	Local cCodCli	:= ""
	Local cLojCli	:= ""
	Local cQuery	:= ""

	//Local cTipoDoc
	//Local cIdPleres	:= ""
	//Local cDominio	:= ""
	//Local cCpfPac	:= ""
	//Local cNomRedz	:= ""
	//lOCAL nRecAC4	:= 0
	//Local cCOdAC4	:= ""

	//oJson:SetContentType("application/json")
	::SetContentType("application/json")
	cBody := ::GetContent()
	ConOut(cBody)

	IF !EMPTY(cBody)
		IF FWJsonDeserialize(cBody,@oJson)

			cFilPV		:= ALLTRIM(oJson:FILIAL)
			cPleres		:= ALLTRIM(oJson:IDPLERES)
			cIdFluig	:= ALLTRIM(oJson:IDFLUIG)
			cCodCli		:= ALLTRIM(oJson:CODCLI)
			cLojCli		:= ALLTRIM(oJson:LOJACLI)


			IF !EMPTY(cFilPV) .AND. !EMPTY(cPleres) .AND. !EMPTY(cIdFluig) .AND. !EMPTY(cCodCli) .AND. !EMPTY(cLojCli)

				cQuery +=  " SELECT C5.R_E_C_N_O_ AS C5RECNO, C6.R_E_C_N_O_ AS C6RECNO "

				cQuery +=  " FROM "+Retsqlname("SC5")+" C5 "

				cQuery +=  " INNER JOIN "+Retsqlname("SC6")+" C6 "
				cQuery +=  " 	ON C5_FILIAL = C6_FILIAL "
				cQuery +=  " 	AND C5_NUM = C6_NUM "
				cQuery +=  " 	AND C6.D_E_L_E_T_ = '' "			

				cQuery +=  " WHERE C5.D_E_L_E_T_ = '' "
				cQuery +=  " 	AND C5_FILIAL =  '"+ cFilPV +"'  "
				cQuery +=  " 	AND C5_CLIENTE =  '"+ cCodCli +"'  "
				cQuery +=  " 	AND C5_LOJACLI =  '"+ cLojCli +"'  "
				cQuery +=  " 	AND C5_XIDPLE =  '"+ cPleres +"'  "
				cQuery +=  " 	AND C5_XIDFLG =  '"+ cIdFluig +"'  "

				If Select("QRYEXC") > 0
					QRYEXC->(DbCloseArea())
				EndIf
				
				ConOut("TRIBUTOS - query " + cQuery )
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYEXC')

				IF QRYEXC->(!EOF())
				
					DBSELECTAREA("SC5")
					SC5->(DBSETORDER(1))
					
					DBSELECTAREA("SC6")
					SC6->(DBSETORDER(1))
										
					WHILE QRYEXC->(!EOF())
					
						SC5->(DBGOTO(QRYEXC->C5RECNO))
						SC6->(DBGOTO(QRYEXC->C6RECNO))
						
						IF EMPTY(SC5->C5_NOTA)
							SC6->(RecLock("SC6",.F.))						
								SC6->C6_XALCOF	 := IIF(VALTYPE(oJson:C6_XALCOF  ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XALCOF		,".",""), ",",".") ), oJson:C6_XALCOF )
								SC6->C6_XALCSL	 := IIF(VALTYPE(oJson:C6_XALCSL  ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XALCSL		,".",""), ",",".") ),oJson:C6_XALCSL )
								SC6->C6_XALINS   := IIF(VALTYPE(oJson:C6_XALINS  ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XALINS		,".",""), ",",".") ),oJson:C6_XALINS )
								SC6->C6_XALIRF   := IIF(VALTYPE(oJson:C6_XALIRF  ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XALIRF		,".",""), ",",".") ),oJson:C6_XALIRF )
								SC6->C6_XALPIS   := IIF(VALTYPE(oJson:C6_XALPIS  ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XALPIS		,".",""), ",",".") ),oJson:C6_XALPIS )
								SC6->C6_XBSCOF   := IIF(VALTYPE(oJson:C6_XBSCOF  ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XBSCOF		,".",""), ",",".") ),oJson:C6_XBSCOF )
								SC6->C6_XBSCSL   := IIF(VALTYPE(oJson:C6_XBSCSL  ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XBSCSL		,".",""), ",",".") ),oJson:C6_XBSCSL )
								SC6->C6_XBSINS   := IIF(VALTYPE(oJson:C6_XBSINS  ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XBSINS		,".",""), ",",".") ),oJson:C6_XBSINS )
								SC6->C6_XBSIRF   := IIF(VALTYPE(oJson:C6_XBSIRF  ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XBSIRF		,".",""), ",",".") ),oJson:C6_XBSIRF )
								SC6->C6_XBSPIS   := IIF(VALTYPE(oJson:C6_XBSPIS  ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XBSPIS		,".",""), ",",".") ),oJson:C6_XBSPIS )
								SC6->C6_XVTRCOF  := IIF(VALTYPE(oJson:C6_XVTRCOF ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XVTRCOF	,".",""), ",",".") ),oJson:C6_XVTRCOF)
								SC6->C6_XVTRCSL  := IIF(VALTYPE(oJson:C6_XVTRCSL ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XVTRCSL	,".",""), ",",".") ),oJson:C6_XVTRCSL)
								SC6->C6_XVTRINS  := IIF(VALTYPE(oJson:C6_XVTRINS ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XVTRINS	,".",""), ",",".") ),oJson:C6_XVTRINS)
								SC6->C6_XVTRIRF  := IIF(VALTYPE(oJson:C6_XVTRIRF ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XVTRIRF	,".",""), ",",".") ),oJson:C6_XVTRIRF)
								SC6->C6_XVTRPIS  := IIF(VALTYPE(oJson:C6_XVTRPIS ) == "C", VAL(STRTRAN(STRTRAN( oJson:C6_XVTRPIS	,".",""), ",",".") ),oJson:C6_XVTRPIS)											
							SC6->(MsUnLock())
	
							SC5->(RecLock("SC5",.F.))
								SC5->C5_XBLQ := "4"
							SC5->(MsUnLock())
						ELSE
							SetRestFault(402, "Nao foi possivel atualizar pois o pedido ja foi utilizado em nota.")	
						ENDIF
						 
						QRYEXC->(DBSKIP())
					ENDDO
				ELSE
					SetRestFault(402, "Pedido nao localizado.")	
				ENDIF 
				
				::SetResponse(cJRetOK)
				lRet	:= .T.

			ELSE
				SetRestFault(402, "FILIAL , IDPLERES, IDFLUIG, CODCLI, LOJACLI  é de preenchimento obrigatório")		
			ENDIF

		ELSE
			SetRestFault(402, "Invalid Json")

		ENDIF
	ELSE
		SetRestFault(401, "Body Vazio")

	ENDIF


Return(lRet)
