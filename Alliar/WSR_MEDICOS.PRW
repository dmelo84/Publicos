#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function WSR_MEDICOS()
Return



WSRESTFUL MEDICOS DESCRIPTION "Serviço REST para manipulação de Medicos"

WSDATA CRM AS STRING  
WSDATA UFCRM AS STRING 
//WSDATA EMAILVISIT AS STRING 

WSMETHOD GET DESCRIPTION "Retorna o médicos informado na URL" WSSYNTAX "/MEDICOS || /MEDICOS/{EMAILVISIT, CRM, UFCRM}"
WSMETHOD POST DESCRIPTION "Insere medicos" WSSYNTAX "/MEDICOS || /MEDICOS/{}"

END WSRESTFUL



//WSMETHOD GET WSRECEIVE CRM, UFCRM, EMAILVISIT WSSERVICE MEDICOS
WSMETHOD GET WSRECEIVE CRM, UFCRM  WSSERVICE MEDICOS
	//Local cCodProd := Self:CODPRODUTO
	//Local aArea    := GetArea()
	Local oObjProd := Nil
	Local cStatus  := ""
	Local cQuery	:= ""
	Local cJson    := '{"STATUS":"OK GET"}'
	Local oMedico, cJoin
	Local cMsgErro	:= ""	
	Local aMedicos	:= {}


	::SetContentType("application/json")



	
	
		

	cQuery := " SELECT  "+CRLF
	cQuery += " ACH_RAZAO, "+CRLF
	cQuery += " ACH_XCRM, "+CRLF
	cQuery += " ACH_XCRMUF, "+CRLF
	cQuery += " ACH_CGC, "+CRLF
	cQuery += " ACH_END, "+CRLF
	cQuery += " ACH_XCOMPL, "+CRLF
	cQuery += " ACH_CODMUN, "+CRLF
	cQuery += " ACH_BAIRRO, "+CRLF
	cQuery += " ACH_CIDADE, "+CRLF
	cQuery += " ACH_EST, "+CRLF
	cQuery += " ACH_CEP, "+CRLF
	cQuery += " ACH_DDI, "+CRLF
	cQuery += " ACH_DDD, "+CRLF
	cQuery += " ACH_TEL, "+CRLF
	cQuery += " ACH_EMAIL, "+CRLF
	cQuery += " ACH_XNIVER, "+CRLF
	cQuery += " ACH_XESP01, "+CRLF
	cQuery += " ACH_XESP02, "+CRLF
	cQuery += " ACH_XESP03, "+CRLF
	cQuery += " ACH_XFONE1, "+CRLF
	cQuery += " ACH_XCEL, "+CRLF
	cQuery += " ACH_XCEL2, "+CRLF
//		cQuery += " Z03_EMAIL, "+CRLF
	cQuery += " CASE WHEN ACH_XCLINI = '' THEN '2' ELSE ACH_XCLINI END AS ACH_XCLINI "+CRLF
	cQuery += " FROM "+RetSqlName("ACH")+" ACH "+CRLF

	//SELF:EMAILVISIT	:= ALLTRIM(upper(SELF:EMAILVISIT))
	
	/*------------------------------------------------------ Augusto Ribeiro | 29/08/2017 - 6:13:39 PM
		Caso seja informado o CRM do medico, verifica se o mesmo esta vinculado a visitadora 
	------------------------------------------------------------------------------------------*/
	/*
	IF !EMPTY(SELF:CRM) .AND. !EMPTY(SELF:UFCRM)
		cJoin	:= " LEFT "
	ELSE
		cJoin	:= " LEFT "//" INNER "
	ENDIF
	
	cQuery += cJoin+" JOIN "+RetSqlName("Z03")+" Z03 "+CRLF
	cQuery += " 	ON Z03_FILIAL = '"+XFILIAL("Z03")+"' "+CRLF
	cQuery += " 	AND UPPER(Z03_EMAIL) = '"+SELF:EMAILVISIT+"' "+CRLF
	cQuery += "     AND Z03.D_E_L_E_T_ = '' "+CRLF
	cQuery += cJoin+" JOIN "+RetSqlName("Z04")+" Z04 "+CRLF
	cQuery += "     ON Z04_FILIAL = Z03_FILIAL "+CRLF
	cQuery += "     AND Z04_CODVIS = Z03_CODVIS "+CRLF
	cQuery += "     AND Z04_CODMED = ACH_CODIGO "+CRLF
	cQuery += "     AND Z04_LOJAME = ACH_LOJA "+CRLF
	cQuery += "     AND Z04.D_E_L_E_T_ = '' "+CRLF		

	*/
	cQuery += " WHERE ACH.D_E_L_E_T_ = '' "+CRLF
	IF !EMPTY(SELF:CRM) .AND. !EMPTY(SELF:UFCRM)
		cQuery += " AND ACH_XCRM = '"+SELF:CRM+"'"+CRLF
		cQuery += " AND ACH_XCRMUF = '"+SELF:UFCRM+"' "+CRLF
	ENDIF
	cQuery += " AND ACH_MSBLQL <> '1' "+CRLF
	cQuery += " ORDER BY ACH_RAZAO "+CRLF


	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						


	IF TSQL->(!EOF())
		
		cJson := ""
		WHILE TSQL->(!EOF())
			
			IF  EMPTY(SELF:CRM)
			
				IF !EMPTY(cJson)
					cJson	+= ","
				ENDIF
				
				cJson	+= "{"
				cJson	+= U_cpxToJson("NOME",FwNoAccent(ALLTRIM(TSQL->ACH_RAZAO )))+","
				cJson	+= U_cpxToJson("CRM",FwNoAccent(ALLTRIM(TSQL->ACH_XCRM )))+","
				cJson	+= U_cpxToJson("UFCRM",FwNoAccent(ALLTRIM(TSQL->ACH_XCRMUF )))
				cJson	+= "}"
			
			ELSE 

				oMedico	:= nil
				oMedico	:= UMEDICO():NEW()
				
				
				oMedico:NOME	          := FwNoAccent(ALLTRIM(TSQL->ACH_RAZAO ))
				oMedico:CRM               := FwNoAccent(ALLTRIM(TSQL->ACH_XCRM  ))
				oMedico:UFCRM             := FwNoAccent(ALLTRIM(TSQL->ACH_XCRMUF))
				oMedico:CPF               := FwNoAccent(ALLTRIM(TSQL->ACH_CGC   ))
				oMedico:ENDERECO          := FwNoAccent(ALLTRIM(TSQL->ACH_END   ))
				oMedico:COMPLEMENTO       := FwNoAccent(ALLTRIM(TSQL->ACH_XCOMPL))
				oMedico:CODMUN            := FwNoAccent(ALLTRIM(TSQL->ACH_CODMUN))
				oMedico:BAIRRO            := FwNoAccent(ALLTRIM(TSQL->ACH_BAIRRO))
				oMedico:MUNICIPIO         := FwNoAccent(ALLTRIM(TSQL->ACH_CIDADE))
				oMedico:UF                := FwNoAccent(ALLTRIM(TSQL->ACH_EST   ))
				oMedico:CEP               := FwNoAccent(ALLTRIM(TSQL->ACH_CEP   ))
				oMedico:DDI1              := FwNoAccent(ALLTRIM(TSQL->ACH_DDI   ))
				oMedico:DDD1              := FwNoAccent(ALLTRIM(TSQL->ACH_DDD   ))
				oMedico:TEL1              := FwNoAccent(ALLTRIM(TSQL->ACH_TEL   ))
				oMedico:EMAIL1            := FwNoAccent(ALLTRIM(TSQL->ACH_EMAIL ))
				IF !EMPTY(TSQL->ACH_XNIVER)
					oMedico:DTNASC            := STOD(TSQL->ACH_XNIVER)
				ENDIF   
				oMedico:ESPECIALIDADE1    := FwNoAccent(ALLTRIM(TSQL->ACH_XESP01))
				oMedico:ESPECIALIDADE2    := FwNoAccent(ALLTRIM(TSQL->ACH_XESP02))
				oMedico:ESPECIALIDADE3    := FwNoAccent(ALLTRIM(TSQL->ACH_XESP03))
				oMedico:TEL2              := FwNoAccent(ALLTRIM(TSQL->ACH_XFONE1))
				oMedico:CEL1              := FwNoAccent(ALLTRIM(TSQL->ACH_XCEL  ))
				oMedico:CEL2              := FwNoAccent(ALLTRIM(TSQL->ACH_XCEL2 ))
				oMedico:CLINICA           := FwNoAccent(ALLTRIM(TSQL->ACH_XCLINI ))
	
				AADD(aMedicos, oMedico)
			ENDIF

			/*
			IF ALLTRIM(UPPER(TSQL->Z03_EMAIL)) <> SELF:EMAILVISIT .and. !EMPTY(SELF:CRM) .AND. !EMPTY(SELF:UFCRM)
				cMsgErro += "Medico nao pertence a visitadora"					
			ELSE
				cMsgErro += ""
			ENDIF	
			*/
			TSQL->(DBSKIP()) 
		ENDDO	
		
		
		IF EMPTY(SELF:CRM)		
			cJson := "["+cJson+"]"
		ELSE
			cJson := FWJsonSerialize(aMedicos,.F.)
		ENDIF
		cJson := 	'{"MEDICO": '+cJson+', "MSGERRO": "'+cMsgErro+'" }'
		
	ELSE
		cJson	:= ' { '
		cJson	+= ' "MEDICOS": [], '
		cJson	+= '	"MSGERRO": "Nenhum medico foi localizado." '
		cJson	+= '} '
	ENDIF

	TSQL->(DbCloseArea())

	
	::SetResponse(cJson)

	//RestArea(aArea)
Return(.T.)


WSMETHOD POST WSRECEIVE CRM, UFCRM WSSERVICE MEDICOS
	Local oObjProd := Nil
	Local cStatus  := ""
	LOcal cBody		:= ""
	Local cJRetOK   := '{"code":200,"status":"success"}'
	Local oJson	
	Local lRet		:= .F.

	Local aMedicos	:= {}
	Local aContato	:= {}
	Local aEndereco := {}
	Local aTelefone := {}
	Local aAuxDados := {}
	Local cCRM		:= ""
	Local cUFCRM	:= ""
	Local cChvMed	:= ""
	
	Local nOpcPac	:= 0 //|3- Inclusão, 4- Alteração, 5- Exclusão|
	
	Private cVisitad

	::SetContentType("application/json")

	cBody := ::GetContent()
	IF !EMPTY(cBody)
		IF FWJsonDeserialize(cBody,@oJson)
			If !EMPTY(oJson:CRM) .AND. !EMPTY(oJson:UFCRM)
				// 7
				// ACH_FILIAL+ACH_XCRM+ACH_XCRMUF
				// XCRM
				

				cCRM	:= PADR(ALLTRIM(oJson:CRM), TAMSX3("ACH_XCRM")[1])
				cUFCRM	:= PADR(ALLTRIM(oJson:UFCRM), TAMSX3("ACH_XCRMUF")[1])
			
				AAdd(aMedicos ,{"ACH_FILIAL"	, XFILIAL("ACH")	, .F.} )
			
			
				DBSELECTAREA("ACH")
				ACH->(DbOrderNickName("XCRM")) //| ACH_FILIAL+ACH_XCRM+ACH_XCRMUF |
				//ACH->(DBSETORDER(2))				
				//ACH->(DBSETORDER(2))//|ACH_FILIAL+ACH_CGC

				//IF ACH->(DBSEEK(XFILIAL("ACH") + ALLTRIM(oJson:CPF)))
				IF ACH->(DBSEEK(XFILIAL("ACH") + cCRM + cUFCRM))
					nOpcPac := 4 //|UPDATE|
					INCLUI	:= .F.
					ALTER	:= .T.
					
					
					AAdd(aMedicos ,{"ACH_CODIGO"	, ACH->ACH_CODIGO	, .F.} )
					AAdd(aMedicos ,{"ACH_LOJA"	, ACH->ACH_LOJA	, .F.} )
										
				ELSE
					nOpcPac := 3 //|INSERT|
					INCLUI	:= .T.
					ALTER	:= .F.
				
					AAdd(aMedicos ,{"ACH_LOJA"	, "0001"		, .F.} )					
				ENDIF



				/*--------------------------
					MEDICO
				---------------------------*/				
				AAdd(aMedicos ,{"ACH_XCRM"		, ALLTRIM(oJson:CRM)		, .F.} )
				AAdd(aMedicos ,{"ACH_XCRMUF"	, ALLTRIM(oJson:UFCRM)		, .F.} )
				
				


				IF AttIsMemberOf(oJson , "CPF")
					AADD(aMedicos, {"ACH_CGC"		, ALLTRIM(oJson:CPF)			, .F.} )
				ENDIF
				//EncodeUtf8( < cText > )
				AADD(aMedicos, {"ACH_RAZAO "	, FwNoAccent(ALLTRIM(EncodeUtf8(oJson:NOME)))			, .F.} )
				AADD(aMedicos, {"ACH_END"		, FwNoAccent(ALLTRIM(oJson:ENDERECO))		, .F.} )
				AADD(aMedicos, {"ACH_XCOMPL"	, FwNoAccent(ALLTRIM(oJson:COMPLEMENTO))	, .F.} )
				AADD(aMedicos, {"ACH_EST"	, ALLTRIM(oJson:UF)		, .F.} )
				IF AttIsMemberOf(oJson , "CODMUN")
					AADD(aMedicos, {"ACH_CODMUN"	, ALLTRIM(oJson:CODMUN)			, .F.} )
				ENDIF
				AADD(aMedicos, {"ACH_BAIRRO"	, FwNoAccent(ALLTRIM(oJson:BAIRRO))			, .F.} )
				AADD(aMedicos, {"ACH_CIDADE"	, FwNoAccent(ALLTRIM(oJson:MUNICIPIO))		, .F.} )

				AAdd(aMedicos, {"ACH_CEP"		, ALLTRIM(oJson:CEP)		, Nil})
				AADD(aMedicos, {"ACH_DDI"		, "55"			, .F.} )
				
				IF AttIsMemberOf(oJson , "DDD1") 
					AADD(aMedicos, {"ACH_DDD"		, ALLTRIM(oJson:DDD1)			, .F.} )
				ENDIF
				IF AttIsMemberOf(oJson , "TEL1") 
					AADD(aMedicos, {"ACH_TEL"		, ALLTRIM(oJson:TEL1)			, .F.} )
				endif
				AADD(aMedicos, {"ACH_EMAIL"		, ALLTRIM(oJson:EMAIL1)			, .F.} )
				IF AttIsMemberOf(oJson , "DTNASC")
					AADD(aMedicos, {"ACH_XNIVER"	, CTOD(ALLTRIM(oJson:DTNASC))			, .F.} )
				endif
				IF AttIsMemberOf(oJson , "ESPECIALIDADE1")
					AADD(aMedicos, {"ACH_XESP01"	, FwNoAccent(ALLTRIM(oJson:ESPECIALIDADE1))	, .F.} )
				endif
				
				IF AttIsMemberOf(oJson , "CONSELHO")
					AADD(aMedicos, {"ACH_XCONSE"	, ALLTRIM(oJson:CONSELHO1)	, .F.} )
				endif	
				
				/*------------------------------------------------------ Augusto Ribeiro | 06/10/2017 - 8:42:23 AM
					Adicionar tabela de controle de Dominios x IDPleres
				------------------------------------------------------------------------------------------*/
				IF AttIsMemberOf(oJson , "IDPLERES")
					//AADD(aMedicos, {"ACH_XCONSE"	, ALLTRIM(oJson:CONSELHO1)	, .F.} )
				endif	
				IF AttIsMemberOf(oJson , "DOMINIO")
					//AADD(aMedicos, {"ACH_XCONSE"	, ALLTRIM(oJson:CONSELHO1)	, .F.} )
				endif												
				
				//AADD(aMedicos, {"ACH_XESP02"	, ALLTRIM(oJson:ESPECIALIDADE2)	, .F.} )
				//AADD(aMedicos, {"ACH_XESP03"	, ALLTRIM(oJson:ESPECIALIDADE3)	, .F.} )
				//AADD(aMedicos, {"ACH_XFONE1"	, ALLTRIM(oJson:TEL2)			, .F.} )
				//AADD(aMedicos, {"ACH_XCEL"		, ALLTRIM(oJson:CEL1)			, .F.} )
				//AADD(aMedicos, {"ACH_XCEL2"		, ALLTRIM(oJson:CEL2)			, .F.} )
				
				
				
				
				/*--------------------------
					CONTATO
				---------------------------*/

				
				AAdd(aContato ,{"U5_FILIAL"		, xFilial("SU5")					, Nil} )
				AAdd(aContato ,{"U5_CONTAT"		, FwNoAccent(ALLTRIM(oJson:NOME))					, Nil} )
				AAdd(aContato ,{"U5_XCRM"		, ALLTRIM(oJson:CRM)			, Nil} )
				AAdd(aContato ,{"U5_XCRMUF"		, ALLTRIM(oJson:UFCRM)			, Nil} )				
				AADD(aContato, {"U5_BAIRRO"		, FwNoAccent(ALLTRIM(oJson:BAIRRO))				, Nil} )
				//AADD(aContato, {"U5_CELULAR"	, ALLTRIM(oJson:CEL1)				, Nil} )
				//AADD(aContato, {"U5_CODPAIS"	, ALLTRIM(oJson:DDI1)				, Nil} )
				//AADD(aContato, {"U5_CONTAT"		, ALLTRIM(oJson:NOME)				, Nil} )
				IF  AttIsMemberOf(oJson , "CPF")
					AADD(aContato, {"U5_CPF"		, ALLTRIM(oJson:CPF)				, Nil} )
				ENDIF
				IF AttIsMemberOf(oJson , "DDD1") 
					AADD(aContato, {"U5_DDD"		, ALLTRIM(oJson:DDD1)				, Nil} )
				ENDIF
				AADD(aContato, {"U5_EMAIL"		, ALLTRIM(oJson:EMAIL1)				, Nil} )
				AADD(aContato, {"U5_END"		, FwNoAccent(ALLTRIM(oJson:ENDERECO))			, Nil} )
				//AADD(aContato, {"U5_FCOM1"		, ALLTRIM(oJson:TEL2)				, Nil} )
				IF AttIsMemberOf(oJson , "TEL1")
					AADD(aContato, {"U5_FONE"		, ALLTRIM(oJson:TEL1)				, Nil} )
				ENDIF
				AADD(aContato, {"U5_MUN"		, FwNoAccent(ALLTRIM(oJson:MUNICIPIO))			, Nil} )
				IF AttIsMemberOf(oJson , "DTNASC")
					AADD(aContato, {"U5_XNIVER"		, CTOD(ALLTRIM(oJson:DTNASC))		, Nil} )
				ENDIF
				//AADD(aContato, {"U5_XCEL2"		, ALLTRIM(oJson:CEL2)				, Nil} )
				AADD(aContato, {"U5_XCOMPL"		, FwNoAccent(ALLTRIM(oJson:COMPLEMENTO))		, Nil} )
				AADD(aContato, {"U5_XESP01"		, FwNoAccent(ALLTRIM(oJson:ESPECIALIDADE1))		, Nil} )
				//AADD(aContato, {"U5_XESP02"		, ALLTRIM(oJson:ESPECIALIDADE2)		, Nil} )
				//AADD(aContato, {"U5_XESP03"		, ALLTRIM(oJson:ESPECIALIDADE3)		, Nil} )
				
				
				AAdd(aAuxDados, {"AGB_TIPO"		, "1"						, Nil})
				AAdd(aAuxDados, {"AGB_PADRAO"	, "1"						, Nil})
				AAdd(aAuxDados, {"AGB_DDI"		, "55"		, Nil})
				IF AttIsMemberOf(oJson , "DDD1")
					AAdd(aAuxDados, {"AGB_DDD"		, ALLTRIM(oJson:DDD1)		, Nil})
				ENDIF
				IF AttIsMemberOf(oJson , "TEL1") 
					AAdd(aAuxDados, {"AGB_TELEFO"	, ALLTRIM(oJson:TEL1)		, Nil})
				ENDIF
				
				AAdd(aTelefone, aAuxDados)
				
				aAuxDados := {}
			
				AAdd(aAuxDados, {"AGA_TIPO"		, "1"						, Nil})
				AAdd(aAuxDados, {"AGA_PADRAO"	, "1"						, Nil})
				AAdd(aAuxDados, {"AGA_END"		, FwNoAccent(ALLTRIM(oJson:ENDERECO))	, Nil})
				AAdd(aAuxDados, {"AGA_CEP"		, ALLTRIM(oJson:CEP)		, Nil})
				AAdd(aAuxDados, {"AGA_BAIRRO"	, FwNoAccent(ALLTRIM(oJson:BAIRRO))		, Nil})
				AAdd(aAuxDados, {"AGA_MUNDES"	, FwNoAccent(ALLTRIM(oJson:MUNICIPIO))	, Nil})
				AAdd(aAuxDados, {"AGA_EST"		, ALLTRIM(oJson:UF)			, Nil})
				
				AAdd(aEndereco, aAuxDados)
				
				
				/*------------------------------------------------------ Augusto Ribeiro | 18/09/2017 - 11:35:54 AM
					Busca usuário e alimentoa variavel private que sera utilizada por ponto de entrada para
					vincular o novo medico cadastrado para a vistiadora
				------------------------------------------------------------------------------------------*/
				IF AttIsMemberOf(oJson , "EMAILVISIT") 
					PswOrder(4)//|E-mail|
					If PswSeek( alltrim(oJson:EMAILVISIT), .T. )
						cVisitad := PswRet( 1, .F. )[1][1]	
					ENDIF
				ENDIF
				
				
				aRet := U_AFAT003(aMedicos, nOpcPac)
				//sleep(500)
				//cChvMed	:= ACH->ACH_CODIGO+ACH->ACH_LOJA

				IF aRet[1] == "0"
					cChvMed	:= aRet[2]				
					
					DBSELECTAREA("SU5")
					SU5->(DbOrderNickName("SU5U5E")) // U5_FILIAL+U5_XCRM+U5_XCRMUF  
					// SU5U5E    
					// U5_FILIAL+U5_XCRM+U5_XCRMUF                                                                                                                                     
					
					cCRM	:= PADR(ALLTRIM(cCRM), TAMSX3("U5_XCRM")[1])
					cUFCRM	:= PADR(ALLTRIM(cUFCRM), TAMSX3("U5_XCRMUF")[1])
					
					IF SU5->(DBSEEK(XFILIAL("SU5") + cCRM + cUFCRM ))
						nOpcPac := 4 //|UPDATE|
					ELSE
						nOpcPac := 3 //|INSERT|
					ENDIF 	
					
					aRet := U_AFAT03C(aContato,aEndereco,aTelefone, nOpcPac)
					
					IF aRet[1] == "0"
						/*------------------------------------------------------ Augusto Ribeiro | 13/09/2017 - 4:16:43 PM
							Vincula Paciente ao Contato
						------------------------------------------------------------------------------------------*/
						IF nOpcPac == 3
						
							DBSELECTAREA("AC8")
							RECLOCK("AC8",.T.)
								AC8->AC8_ENTIDA := "ACH"
								AC8->AC8_CODENT	:= cChvMed
								AC8->AC8_CODCON	:= SU5->U5_CODCONT
							MSUNLOCK()
						ENDIF					

					ELSE
						SetRestFault(403, aRet[2])
						lRet	:= .F.
					ENDIF 				

							
					::SetResponse(cJRetOK)
					lRet	:= .T.
				ELSE
					SetRestFault(403, aRet[2])
					lRet	:= .F.
				ENDIF 
			Else
				SetRestFault(400, "Parameters are mandatory")
			EndIf
		ELSE
			SetRestFault(402, "Invalid Json")

		ENDIF
	ELSE
		SetRestFault(401, "Body Vazio")

	ENDIF


Return(lRet)



