#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'


/*/{Protheus.doc} WSR_PACIENTES
REST para captação dos dados para envio para a tabela AC4
@author Jonatas Oliveira | www.compila.com.br
@since 16/06/2017
@version 1.0
/*/
User Function WSR_PACIENTES()
Return



WSRESTFUL PACIENTES DESCRIPTION "Serviço REST para manipulação de PACIENTES"



//WSMETHOD GET DESCRIPTION "Retorna o PACIENTES informado na URL" WSSYNTAX "/PACIENTES || /PACIENTES/{crm}"
WSMETHOD POST DESCRIPTION "Insere PACIENTES" WSSYNTAX " /PACIENTES/{}"

END WSRESTFUL




WSMETHOD POST  WSSERVICE PACIENTES

	Local cBody		:= ""
	Local alRet		:={.F.,402,"Erro indeterminado"}
	
	//oJson:SetContentType("application/json")
	::SetContentType("application/json")
	cBody := ::GetContent()
	//ConOut(cBody)
	
	IF !EMPTY(cBody)
		
		/*------------------------------------------------------------\
		| Esta Função retrona um Array com 3 posições, conforme abaixo|
		| alRet[1] = Status(.T./.F.)                                  |
		| alRet[2] = Codigo do Erro(402/403...)                       |
		| alRet[3] = Mensagem de erros                                |
		\------------------------------------------------------------*/
		
		alRet	:= U_WSRPACADD(cBody)
		
		IF alRet[1]
		
			::SetResponse(alRet[3])
		
		ELSE
		
			SetRestFault(alRet[2], alRet[3])
		
		ENDIF
		
	ELSE
	
		SetRestFault(401,"Body Vazio")
		
	ENDIF

Return(alRet[1])







/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RemovCharºAutor  ³ Augusto Ribeiro	 º Data ³  08/06/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Remove caracter especial                                   ±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC Function RemovChar(cRet)
	Local cRet

	cRet	:= upper(cRet)
	
	cRet	:= STRTRAN(cRet,"Ã‡","C")
	cRet	:= STRTRAN(cRet,"ÃÂÂÇÍ","C")
	cRet	:= STRTRAN(cRet,"ÂÆÆ","")
	cRet	:= STRTRAN(cRet,"Á","A")
	cRet	:= STRTRAN(cRet,"É","E")
	cRet	:= STRTRAN(cRet,"Í","I")
	cRet	:= STRTRAN(cRet,"Ó","O")
	cRet	:= STRTRAN(cRet,"Ú","U")
	cRet	:= STRTRAN(cRet,"À","A")
	cRet	:= STRTRAN(cRet,"È","E")
	cRet	:= STRTRAN(cRet,"Ì","I")
	cRet	:= STRTRAN(cRet,"Ò","O")
	cRet	:= STRTRAN(cRet,"Ù","U")
	cRet	:= STRTRAN(cRet,"Ã","A")
	cRet	:= STRTRAN(cRet,"Õ","O")
	cRet	:= STRTRAN(cRet,"Ä","A")
	cRet	:= STRTRAN(cRet,"Ë","E")
	cRet	:= STRTRAN(cRet,"Ï","I")
	cRet	:= STRTRAN(cRet,"Ö","O")
	cRet	:= STRTRAN(cRet,"Ü","U")
	cRet	:= STRTRAN(cRet,"Â","A")
	cRet	:= STRTRAN(cRet,"Ê","E")
	cRet	:= STRTRAN(cRet,"Î","I")
	cRet	:= STRTRAN(cRet,"Ô","O")
	cRet	:= STRTRAN(cRet,"Û","U")
	cRet	:= STRTRAN(cRet,"Ç","C")
	cRet	:= STRTRAN(cRet,"º"," ")
	cRet	:= STRTRAN(cRet,"-","")
	cRet	:= STRTRAN(cRet,".","")
	cRet	:= STRTRAN(cRet,"R$","")
	cRet	:= STRTRAN(cRet,"NULL","")
	cRet	:= STRTRAN(cRet,"ƒ","")




Return(cRet)



/*/{Protheus.doc} ALDOMPLE
Grava em tabela auxiliar os dados do paciente e dominio
@author Jonatas Oliveira | www.compila.com.br
@since 23/10/2017
@version 1.0
@param cIdPler, C, IDPLERES
@param cDomin, C, Dominio
@param cCpf, C, CPF
/*/
User Function ALDOMPLE(cIdPler,cDomin, cCpf)
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


/*/{Protheus.doc} WSRPACADD
REST para captação dos dados para envio para a tabela AC4
@author Fabio Sales | www.compila.com.br
@since 15/05/2018
@version 1.0
/*/

User Function WSRPACADD(cBody)

	Local oJson		:= Nil	
	Local lRet		:= .F.
	Local alRet		:= {.F.,0,'{"code":200,"status":"success"}'}
	
	Local aPacien	:= {}
	Local aContato	:= {}
	Local aEndereco := {}
	Local aTelefone := {}
	Local aAuxDados := {}
	Local nOpcPac	:= 0 //|3- Inclusão, 4- Alteração, 5- Exclusão|
	Local cTipoDoc
	Local cIdPleres	:= ""
	Local cDominio	:= ""
	Local cCpfPac	:= ""
	Local cNomRedz	:= ""
	lOCAL nRecAC4	:= 0
	Local cCOdAC4	:= ""
	
	
	Default cBody	:= ""
	
	IF !EMPTY(cBody)
		IF FWJsonDeserialize(cBody,@oJson)
			IF VALTYPE(oJson) == "O"
				IF AttIsMemberOf(oJson, "TIPODOC")

			
					cTipoDoc	:= ALLTRIM(oJson:TIPODOC)//| 1=CPF;2=CPF DEPENDENTE;3=PASSAPORTE| 
				
					IF !EMPTY(cTipoDoc) 
					
						DBSELECTAREA("AC4")
						AC4->(DBSETORDER(3))//|AC4_FILIAL+AC4_XCPF
						
						IF AC4->(DBSEEK(XFILIAL("AC4") + ALLTRIM(oJson:CPF)))
							
							//|Titular ou Passaporte|
							IF cTipoDoc == "2"	.OR.  cTipoDoc == "3" 		
								
								WHILE AC4->(!EOF())
									IF AC4->AC4_XTPDOC == cTipoDoc
										nOpcPac := 4 //|UPDATE|
										cCOdAC4	:= AC4->AC4_PARTNE 
										EXIT
									ELSE
										nOpcPac := 3 //|INSERT|
									ENDIF
									
									AC4->(DBSKIP())
								ENDDO
							
							//|CPF Dependente|	
							ELSEIF cTipoDoc == "1"
								WHILE AC4->(!EOF())
								
									IF ALLTRIM(oJson:CPF) == ALLTRIM(AC4->AC4_XCPF) .AND. AC4->AC4_XNIVER == CTOD(ALLTRIM(oJson:DTNASC))
										nOpcPac := 4 //|UPDATE|
										cCOdAC4	:= AC4->AC4_PARTNE 
										EXIT
									ELSE
										nOpcPac := 3 //|INSERT|
									ENDIF
									
									AC4->(DBSKIP())
								ENDDO 
							ENDIF
						ELSE
							nOpcPac := 3 //|INSERT|
						ENDIF 
					
						AADD(aPacien, {"AC4_XTPDOC"	, ALLTRIM(oJson:TIPODOC)		, .F.} )
						AADD(aPacien, {"AC4_XCPF"	, ALLTRIM(oJson:CPF)			, .F.} )
						cCpfPac := ALLTRIM(oJson:CPF)
						AADD(aPacien, {"AC4_NOME"	, upper(RemovChar(oJson:NOME))			, .F.} )
						
						//AADD(aPacien, {"AC4_NREDUZ"	, upper(LEFT(ALLTRIM(oJson:NOME),AT(" ",ALLTRIM(oJson:NOME))))		, .F.} )
						//
						IF AT(" ",ALLTRIM(oJson:NOME)) == 0
							cNomRedz	:= Upper(LEFT(RemovChar((ALLTRIM(oJson:NOME))), TamSx3("AC4_NREDUZ")[1] ))
						ELSE
							cNomRedz	:= Upper(LEFT((ALLTRIM(oJson:NOME)),AT(" ",(ALLTRIM(oJson:NOME)))))
						ENDIF 	
						
						AADD(aPacien, {"AC4_NREDUZ"	,cNomRedz		, .F.} )
						
						
						AADD(aPacien, {"AC4_XNIVER"	, CTOD(ALLTRIM(oJson:DTNASC))	, .F.} )
						AADD(aPacien, {"AC4_XRESP"	, upper(ALLTRIM(oJson:NOMETITULAR))	, .F.} )
						
						IF VALTYPE(oJson:PESO) == "C"
							AADD(aPacien, {"AC4_XPESO"	, VAL(STRTRAN(oJson:PESO,",","."))			, .F.} )
						ELSE
							AADD(aPacien, {"AC4_XPESO"	, oJson:PESO				, .F.} )
						ENDIF 
						
						IF VALTYPE(oJson:PESO) == "C"
							AADD(aPacien, {"AC4_XALTUR"	, VAL(STRTRAN(oJson:ALTURA, ",","."))				, .F.} )
						ELSE
							AADD(aPacien, {"AC4_XALTUR"	, oJson:ALTURA					, .F.} )
						ENDIF
						 
						AADD(aPacien, {"AC4_XSEXO"	, oJson:SEXO					, .F.} )
						/*
						IF !EMPTY(oJson:SegMedico)
							AADD(aPacien, {"AC4_XSEGMT"	, oJson:SegMedico	, .F.} )
						ENDIF
						*/
						
						AADD(aPacien, {"AC4_XDOC"	, oJson:RG							, .F.} )
						AADD(aPacien, {"AC4_END"	, RemovChar((oJson:ENDERECO))		, .F.} )
						AADD(aPacien, {"AC4_CEP"	, STRTRAN(oJson:CEP,"-","")	, .F.} )
						AADD(aPacien, {"AC4_BAIRRO"	, RemovChar((oJson:BAIRRO))				, .F.} )
						AADD(aPacien, {"AC4_MUN"	, RemovChar((oJson:MUNICIPIO))			, .F.} )
						AADD(aPacien, {"AC4_EST"	, oJson:UF					, .F.} )
						AADD(aPacien, {"AC4_XCOMPL"	, RemovChar((oJson:COMPLEMENTO))			, .F.} )
						AADD(aPacien, {"AC4_XREFER"	, RemovChar((oJson:REFERENCIA))			, .F.} )
						AADD(aPacien, {"AC4_DDI"	, oJson:DDI					, .F.} )
						AADD(aPacien, {"AC4_DDD"	, oJson:DDD					, .F.} )
						AADD(aPacien, {"AC4_TEL"	, STRTRAN(oJson:TEL,"-","")	, .F.} )
						AADD(aPacien, {"AC4_CONTAT"	, RemovChar((oJson:CONTATO))				, .F.} )
						AADD(aPacien, {"AC4_FAX"	, STRTRAN(oJson:CEL	,"-",""), .F.} )
						AADD(aPacien, {"AC4_XMAIL"	, LOWER(oJson:EMAIL)				, .F.} )
						//AADD(aPacien, {"AC4_HPAGE"	, oJson:Site				, .F.} )
						AADD(aPacien, {"AC4_XCONVE"	, RemovChar((UPPER(ALLTRIM(oJson:CONVENIO))))			, .F.} )
						AADD(aPacien, {"AC4_XPLANO"	, alltrim(RemovChar((oJson:PLANO)))				, .F.} )
						AADD(aPacien, {"AC4_XMATRI"	, oJson:MATRICULAPLANO		, .F.} )
						AADD(aPacien, {"AC4_JSON"	, cBody						, .F.} )
						
						
						/*------------------------------------------------------ Augusto Ribeiro | 06/10/2017 - 8:42:23 AM
							Adicionar tabela de controle de Dominios x IDPleres
						------------------------------------------------------------------------------------------*/
						IF AttIsMemberOf(oJson , "IDPLERES")
							cIdPleres := oJson:IDPLERES
							//AADD(aMedicos, {"ACH_XCONSE"	, ALLTRIM(oJson:CONSELHO1)	, .F.} )
						endif	
						IF AttIsMemberOf(oJson , "DOMINIO")
							cDominio := oJson:DOMINIO
							//AADD(aMedicos, {"ACH_XCONSE"	, ALLTRIM(oJson:CONSELHO1)	, .F.} )
						endif				
						
						/*------------------------------------------------------ Augusto Ribeiro | 13/09/2017 - 3:46:30 PM
							CONTATOS
						------------------------------------------------------------------------------------------*/
						AAdd(aContato ,{"U5_FILIAL"		, xFilial("SU5")					, Nil} )			
						
						nOpcCont := 3 //|INSERT|
						
						IF nOpcPac == 4//| UPDATE |
						
							DBSELECTAREA("SU5")
							SU5->(DBSETORDER(8))//|U5_FILIAL+U5_CPF|			
							IF SU5->(DBSEEK(XFILIAL("SU5") + ALLTRIM(oJson:CPF) )) 
								
								//
								WHILE SU5->(!EOF()) .AND. ALLTRIM(oJson:CPF) == ALLTRIM(SU5->U5_CPF)
								
									IF SU5->U5_XTPDOC == cTipoDoc
								
										 DBSELECTAREA("AC8")
										 AC8->(DBSETORDER(1)) //| AC8_FILIAL+AC8_CODCON
										 IF AC8->(DBSEEK(xfilial("AC8")+SU5->U5_CODCONT+"AC4", .F.)) 
										 	IF alltrim(AC8->AC8_CODENT) == alltrim(cCOdAC4)
										 	
												nOpcCont := 4 //|UPDATE|
												AADD(aContato, {"U5_CODCONT"		, SU5->U5_CODCONT			, Nil} )
												EXIT							 	
										 	
										 	ENDIF							
										 ENDIF
										 
									ENDIF					 
				
									SU5->(DBSKIP())
								ENDDO	
								
							ENDIF
							
								
							/*
							
							//|Titular ou Passaporte|
							IF cTipoDoc == "2"	.OR.  cTipoDoc == "3"			
								WHILE SU5->(!EOF())
									IF SU5->U5_XTPDOC == cTipoDoc
										nOpcCont := 4 //|UPDATE|
										AADD(aContato, {"U5_CODCONT"		, SU5->U5_CODCONT			, Nil} )
										EXIT
									ELSE
										nOpcCont := 3 //|INSERT|
									ENDIF
									
									SU5->(DBSKIP())
								ENDDO		
											
							//|CPF Dependente|	
							ELSEIF cTipoDoc == "1"
								WHILE SU5->(!EOF())
								
									IF ALLTRIM(oJson:CPF) == ALLTRIM(SU5->U5_CPF) .AND. SU5->U5_XNIVER == CTOD(ALLTRIM(oJson:DTNASC))
										nOpcCont := 4 //|UPDATE|
										AADD(aContato, {"U5_CODCONT"		, SU5->U5_CODCONT			, Nil} )
										EXIT
									ELSE
										nOpcCont := 3 //|INSERT|
									ENDIF
									
									SU5->(DBSKIP())
								ENDDO 
							ENDIF
							*/
			
						ENDIF			
						
						IF nOpcCont == 3
							AADD(aContato, {"U5_XTPDOC"		, cTipoDoc							, Nil} )
							AADD(aContato, {"U5_CPF"		, ALLTRIM(oJson:CPF)				, Nil} )				
						ENDIF
						
						AADD(aContato, {"U5_RG"			, oJson:RG							, Nil} )
						AADD(aContato, {"U5_BAIRRO"		, RemovChar(ALLTRIM((oJson:BAIRRO)))				, Nil} )
						AADD(aContato, {"U5_CELULAR"	, STRTRAN(ALLTRIM(oJson:CEL)	,"-","")				, Nil} )
						AADD(aContato, {"U5_CODPAIS"	, ALLTRIM(oJson:DDI)				, Nil} )
						AADD(aContato, {"U5_CONTAT"		, upper(RemovChar(ALLTRIM((ALLTRIM(oJson:NOME)))))				, Nil} )
			
						AADD(aContato, {"U5_DDD"		, ALLTRIM(oJson:DDD)				, Nil} )
						AADD(aContato, {"U5_EMAIL"		, LOWER(ALLTRIM(oJson:EMAIL))				, Nil} )
						AADD(aContato, {"U5_END"		, RemovChar((ALLTRIM(oJson:ENDERECO)))			, Nil} )
						AADD(aContato, {"U5_MUN"		, RemovChar((ALLTRIM(oJson:MUNICIPIO)))			, Nil} )
						AADD(aContato, {"U5_XNIVER"		, CTOD(ALLTRIM(oJson:DTNASC))		, Nil} )			
						AADD(aContato, {"U5_XCOMPL"		, RemovChar(ALLTRIM((oJson:COMPLEMENTO)))		, Nil} )
						
						IF !EMPTY(oJson:CEL)
							AAdd(aAuxDados, {"AGB_TIPO"		, "1"						, Nil})
							AAdd(aAuxDados, {"AGB_PADRAO"	, "1"						, Nil})
							AAdd(aAuxDados, {"AGB_DDI"		, ALLTRIM(oJson:DDI)		, Nil})
							AAdd(aAuxDados, {"AGB_DDD"		, ALLTRIM(oJson:DDD)		, Nil})
							AAdd(aAuxDados, {"AGB_TELEFO"	, STRTRAN(ALLTRIM(oJson:CEL)	,"-","")		, Nil})
						
							AAdd(aTelefone, aAuxDados)
						ENDIF 
						
						
						aAuxDados := {}
						
						IF !EMPTY(oJson:MUNICIPIO)
							AAdd(aAuxDados, {"AGA_TIPO"		, "2"						, Nil})
							AAdd(aAuxDados, {"AGA_PADRAO"	, "1"						, Nil})
							AAdd(aAuxDados, {"AGA_END"		, RemovChar(ALLTRIM((oJson:ENDERECO)))	, Nil})
							//AAdd(aAuxDados, {"AGA_CEP"		, "12345123"				, Nil})
							AAdd(aAuxDados, {"AGA_BAIRRO"	, RemovChar(ALLTRIM((oJson:BAIRRO)))		, Nil})
							AAdd(aAuxDados, {"AGA_MUNDES"	, RemovChar(ALLTRIM((oJson:MUNICIPIO)))	, Nil})
							//AAdd(aAuxDados, {"AGA_EST"		, "SP"			, Nil})
						
							AAdd(aEndereco, aAuxDados)
							
						ENDIF 
						
						
									
						/*
							"RG": "",
							"CEL": "",
							"TELCOM1": "",
							"TELCOM2": "",
							"ESTADOCIVIL": ""
						*/
						
						IF LEN(aPacien) >= 0
						
							aRet := U_AFAT002(aPacien, nOpcPac) 
							IF aRet[1] == "0"
								nRecAC4	:= AC4->(RECNO())
								/*
								DBSELECTAREA("AC4")
								AC4->(RecLock("AC4",.F.))
									AC4->AC4_JSON := cBody				
								AC4->(MsUnLock())
								*/
								/*
								DBSELECTAREA("SU5")
								SU5->(DBSETORDER(8))//|U5_FILIAL+U5_CPF|
								
								IF SU5->(DBSEEK(XFILIAL("SU5") + ALLTRIM(oJson:CPF) ))
									nOpcPac := 4 //|UPDATE|
								ELSE
									nOpcPac := 3 //|INSERT|
								ENDIF 	
								*/
								IF LEN(aEndereco) > 0 .AND. LEN(aTelefone) > 0 
									aRet := U_AFAT03C(aContato,aEndereco,aTelefone, nOpcCont)
								ELSE
			//						IF nOpcCont == 3 
										aRet := U_AFAT03C(aContato,,, nOpcCont)
			//						ENDIF 
								ENDIF				
								 
								IF aRet[1] == "0"
									
									/*----------------------------------------
										28/06/2018 - Jonatas Oliveira - Compila
										Posiciona no registro criado AC4	
									------------------------------------------*/
									DBSELECTAREA("AC4")
									AC4->(DBSETORDER(3))
									IF AC4->(DBSEEK(XFILIAL("AC4") + ALLTRIM(oJson:CPF)) )
										/*----------------------------------------
											28/06/2018 - Jonatas Oliveira - Compila
											Busca o Paciente pelo CPF e Data de Nascimento
										------------------------------------------*/
										WHILE AC4->(!EOF()) 
											IF ALLTRIM(oJson:CPF) == ALLTRIM(AC4->AC4_XCPF) .AND. AC4->AC4_XNIVER == CTOD(ALLTRIM(oJson:DTNASC))
												nRecAC4	:= AC4->(RECNO())
												cCOdAC4	:= AC4->AC4_PARTNE
												
												EXIT 
											ENDIF 
											AC4->(DBSKIP())
											
										ENDDO
									
									ENDIF 
									
									/*------------------------------------------------------ Augusto Ribeiro | 13/09/2017 - 4:16:43 PM
										Vincula Paciente ao Contato
									------------------------------------------------------------------------------------------*/
									IF nOpcCont == 3
										
										DBSELECTAREA("AC8")
										RECLOCK("AC8",.T.)
											AC8->AC8_ENTIDA := "AC4"
			//								AC8->AC8_CODENT	:= AC4->AC4_PARTNE
											AC8->AC8_CODENT := cCOdAC4
											AC8->AC8_CODCON	:= SU5->U5_CODCONT
										MSUNLOCK()
									ENDIF
									
									alRet[1]		:= .T.
									 
								ELSE
								
									alRet[1]	:= .F. 
									alRet[2]	:= 403
									alRet[3]	:= aRet[2]
		
								ENDIF
								
								IF !EMPTY(cDominio) .AND. !EMPTY(cIdPleres) .AND. !EMPTY(cCpfPac)
									
									aRetAux	:= U_ALPLGDOM("AC4", nRecAC4, cIdPleres,cDominio, cCpfPac)
									
									//DBSELECTAREA("Z30")
									//Z30->(DBSETORDER(4))//|Z30_XIDPLE+Z30_DOMINI|
									
									//IF Z30->(!DBSEEK(cIdPleres + SPACE((TamSx3 ("Z30_XIDPLE")[1]) - LEN(cIdPleres)) + ALLTRIM(cDominio)))
										/*----------------------------------------
											23/10/2017 - Jonatas Oliveira - Compila
											Grava na tabela Z30 - 
										------------------------------------------*/
										//U_ALDOMPLE(cIdPleres,cDominio, cCpfPac)
									//ENDIF 
								ENDIF 
								 		
							ELSE
								
								alRet[1]	:= .F. 
								alRet[2]	:= 403
								alRet[3]	:= aRet[2]
								
							ENDIF 
							
						ENDIF 
					ELSE					
						alRet[1]	:= .F. 
						alRet[2]	:= 402
						alRet[3]	:= "TIPODOC é de preenchimento obrigatório"	
					ENDIF
				ELSE
					alRet[1]	:= .F. 
					alRet[2]	:= 402
					alRet[3]	:= "Invalid Json. TIPODOC nao informado."					
				ENDIF
			ELSE
				alRet[1]	:= .F. 
				alRet[2]	:= 402
				alRet[3]	:= "Invalid Json..."	
			ENDIF			
		ELSE		   
		   
			alRet[1]	:= .F. 
			alRet[2]	:= 402
			alRet[3]	:= "Invalid Json"		   
	
		ENDIF
	ELSE
   		   
		alRet[1]	:= .F. 
		alRet[2]	:= 401
		alRet[3]	:= "Body Vazio"	
	
	ENDIF


Return(alRet)