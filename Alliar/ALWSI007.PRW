#INCLUDE "ALWSI007.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALWSI007
Funcao Generica para Compilacao

@author Guilherme.Santos
@since 16/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALWSI007()


Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} WSTMKFLG
Integracao TMK x Fluig

@author Guilherme.Santos
@since 16/12/2016
@version P12
*/
//-------------------------------------------------------------------
WsService WSTMKFLG 	Description "Integração Call Center x Fluig"
	WsData aRetTMK				as stRetTMK
	WsData sParam				as stParamTMK
	WsData sRetorno				as String

	WsMethod AtualizaTMK	Description "Resposta do Ponto Focal para Atualização do Atendimento do Call Center"
 	WsMethod WSAtuWS		Description "iTAMAR gAMA"
	WsMethod ConsultaTMK	Description "Consulta do Atendimento do Call Center"
EndWsService

WsMethod WSAtuWS WsReceive sParam WsSend sRetorno WsService WSTMKFLG
Local lRet := .T.

	::sRetorno := "Atendimento 000000 atualizado com Sucesso."

	 //If !lRet
	 //	SetSoapFault('Erro', ::cXMLResp)
	 //EndIf
	
Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} AtualizaTMK
Atualizacao do Atendimento do Call Center a partir da Resposta do Ponto Focal

@author Guilherme.Santos
@since 20/12/2016
@version P12
*/
//-------------------------------------------------------------------
WsMethod AtualizaTMK WsReceive sParam WsSend sRetorno WsService WSTMKFLG
	Local aCabec	:= {}
	Local aItens	:= {}   
	Local ChaveEnv	:=''
	Local aAux		:= {}
	Local aAuxRet	:= {}
	Local aAuxNew	:= {}
	Local nCampo	:= 0
	Local nCampo1	:= 0
	Local nPosItem	:= 0 
	Local lRetorno  := .T.	
	Local cCodUserx	:=''
	Local cDscUserx :=''
	Local cSubItem  :=''
	Local xcItem  :=''
	Local xcSubItem  :=''
	Private lMsErroAuto:= .F.
	/*-----------------------------------------------------------------------------------------------------
		Validação de Usuario e Senha
	-----------------------------------------------------------------------------------------------------	
	*/
	//If VldUser(::sParam:sUser, ::sParam:sPassword)
		/*
		-----------------------------------------------------------------------------------------------------
			Validação da Empresa e Filial
		-----------------------------------------------------------------------------------------------------	
		*/
		If VldEmpFil(::sParam:sEmpresa, ::sParam:sFilial)
			/*
			-----------------------------------------------------------------------------------------------------
				Localiza o Atendimento   xFilial("SUC")
			-----------------------------------------------------------------------------------------------------	
			*/   
			
	 		PswOrder(4)
      		If PswSeek(AllTrim(::sParam:SUSER)  ,.T.)
        		aInfUsr := PswRet(1)
         		cCodUserx := aInfUsr[1][1]
  	  		Endif
			ChaveEnv:=::sParam:sCodTMK
			xchavenv:=ChaveEnv
			xidfluig:=::sParam:sIDFluig
			DbSelectArea("SUC")
			DbSetOrder(1)		//UC_FILIAL, UC_CODIGO 
			

			If DbSeek(xFilial("SUC") + Left(::sParam:sCodTMK,6))
				/*
				-----------------------------------------------------------------------------------------------------
					Localiza o Item que gerou a Tarefa do Ponto Focal
				-----------------------------------------------------------------------------------------------------	
				*/
				DbSelectArea("SUD")
				DbOrderNickName("UDXIDFLUI")		//UD_FILIAL, UD_XIDFLG
				
				If DbSeek(xFilial("SUD") + ::sParam:sIDFluig)
					If SUC->UC_CODIGO == SUD->UD_CODIGO
						/*
						-----------------------------------------------------------------------------------------------------
							Campos do Itens do Atendimento
						-----------------------------------------------------------------------------------------------------	
						*/
						For nCampo := 1 to SUD->(FCount())
							Do Case
							Case FieldName(nCampo) == "UD_XIDFLG"
								Aadd(aAuxRet, {"UD_XIDFLG", "", NIL})
							Case FieldName(nCampo) == "UD_XRESP"
								Aadd(aAuxRet, {"UD_XRESP", ::sParam:sResponsavel, NIL})
							Case FieldName(nCampo) == "UD_XCONTAT"
								Aadd(aAuxRet, {"UD_XCONTAT", ::sParam:sContato, NIL})
							Case FieldName(nCampo) == "UD_XOBS"
								Aadd(aAuxRet, {"UD_XOBS", ::sParam:sObservacao, NIL})
							Case FieldName(nCampo) == "UD_XCOMPL"
								Aadd(aAuxRet, {"UD_XCOMPL", ::sParam:sComplemento, NIL})
							Otherwise
								Aadd(aAuxRet, {FieldName(nCampo), SUD->(&(FieldName(nCampo))), NIL})
							EndCase
							Aadd(aAuxNew, {FieldName(nCampo), SUD->(&(FieldName(nCampo))), NIL})
						Next nCampo
						if SUD->UD_ITEM == Substr(ChaveEnv,7,2) 
						xcItem:=SUD->UD_ITEM
						xcSubItem:=SUD->UD_SUBITEM
						else
						cMsgErro := "O Atendimento informado não confere com o Atendimento do ID Fluig."
						lRetorno := .F.
						endif

					Else
						cMsgErro := "O Atendimento informado não confere com o Atendimento do ID Fluig."
						lRetorno := .F.
					EndIf

					If lRetorno
						/*
						-----------------------------------------------------------------------------------------------------
							Preparacao para o ExecAuto
						-----------------------------------------------------------------------------------------------------	
							Campos do Cabecalho do Atendimento
						-----------------------------------------------------------------------------------------------------	
						*/    
						DbSelectArea("SUC")
						For nCampo := 1 to SUC->(FCount())
							Aadd(aCabec, {FieldName(nCampo), SUC->(&(FieldName(nCampo))), NIL})
						Next nCampo

						DbSelectArea("SUD")
						DbSetOrder(1)		//UD_FILIAL, UD_CODIGO, UD_ITEM
                        sud->(Dbgotop())
						If dbSeek(xFilial("SUD") + SUC->UC_CODIGO)
							While (SUD->UD_FILIAL + SUD->UD_CODIGO) == (xFilial("SUD") +SUC->UC_CODIGO) .and. !SUD->(Eof())
								aAux 	:= {}
								cItem 	:= SUD->UD_ITEM
								/*
								-----------------------------------------------------------------------------------------------------
									Campos do Itens do Atendimento
								-----------------------------------------------------------------------------------------------------	
								*/           
								
								For nCampo1 := 1 to SUD->(FCount())
									Aadd(aAux, {FieldName(nCampo1), SUD->(&(FieldName(nCampo1))), NIL})  
									If SUD->UD_ITEM == Substr(ChaveEnv,7,2)	// .and. SUD->UD_XIDFLG==xidfluig 
										If FieldName(nCampo1) == "UD_STATUS"
											aAux[nCampo1][2]:="2"
										EndIf	
										If FieldName(nCampo1) == "UD_XCONTAT" .And. aAux[nCampo1][2] == " "
											aAux[nCampo1][2]:="N"
										EndIf	
										//Aadd(aAuxNew, {FieldName(nCampo1), SUD->(&(FieldName(nCampo1))), NIL})
									Endif
								Next nCampo1 
								Aadd(aItens, aAux)
								
								//If SUD->UD_ITEM == Substr(ChaveEnv,7,2) .and. SUD->UD_XIDFLG==xidfluig
								//	cSubItem:=SUD->UD_SUBITEM//Substr(ChaveEnv,7,2)+IIf(Len(Right(SUD->UD_SUBITEM,2))==0,'00',Right(SUD->UD_SUBITEM,2))
								//Endif
								
//								If Substr(ChaveEnv,7,2)== Left(SUD->UD_SUBITEM,2) 
//									cSubItem:=Substr(ChaveEnv,7,2)+IIf(Len(Right(SUD->UD_SUBITEM,2))==0,'00',Right(SUD->UD_SUBITEM,2))
//								Endif
								
//								IF SUD->UD_ITEM==xcItem
//									xcSubItem:=SUD->UD_SUBITEM
//							    EndIF
								If Substr(SUD->UD_SUBITEM,1,2) == Substr(ChaveEnv,7,2)
									xcSubItem:=if(SUD->UD_SUBITEM>xcSubItem,SUD->UD_SUBITEM,xcSubItem)
								endif
								SUD->(DbSkip())
							End
							/*
							-----------------------------------------------------------------------------------------------------
								Inclui uma Linha Nova para o Item que Recebeu a Resposta do Ponto Focal
							-----------------------------------------------------------------------------------------------------	
							*/ 
							
//							aAuxNew[3][2]:=Strzero(Val(cItem)+1,2)
							nPosCpo:=AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_ITEM"})
							aAuxNew[nPosCpo][2]:=Strzero(Val(cItem)+1,2)
//							aAuxNew[nPosCpo][2]:=Strzero(Val(aAuxNew[nPosCpo][2])+1,2)
							nPosCpo:=AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_SUBITEM"})
//							aAuxNew[nPosCpo][2]:=Strzero(Val(cSubItem)+1,4)
//							aAuxNew[nPosCpo][2]:=Strzero(Val(aAuxNew[nPosCpo][2])+1,4)
							cSubItem:=aAuxNew[nPosCpo][2] //05092017
							//cSubItem:=cItem+Right(cSubItem,2)
							aAuxNew[nPosCpo][2]:=Strzero(Val(xcSubItem)+1,4)
							
							// Acertos de campos novo registro
							nPosCpo:=AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_OPERADO"}) // Respons�vel
							/*
							If ! Empty(cCodUserx)
							   aAuxNew[nPosCpo][2]:=cCodUserx	//::sParam:sResponsavel  
							Endif                                    
                            */
							aAuxNew[nPosCpo][2]:= cCodUserx
							//::sParam:sResponsavel
							
							nPosCpo:=AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_DATA"}) // Data A��o
							aAuxNew[nPosCpo][2]:=ddatabase

							nPosCpo:=AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_DTEXEC"}) // Data Execu��o verificar
							aAuxNew[nPosCpo][2]:=ddatabase  //+10

							nPosCpo:=AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_OBS"}) // Observa��o Verificar
							aAuxNew[nPosCpo][2]:=::sParam:sObservacao   

							Aadd(aAuxNew, {"UD_OBSEXEC", ::sParam:sComplemento, NIL}) 

							nPosCpo:=AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_STATUS"}) // Status Pendente
							aAuxNew[nPosCpo][2]:="1"

							nPosCpo:=AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_SOLUCAO"}) // A��o
							aAuxNew[nPosCpo][2]:=GETMV("AL_ACAORET")

							nPosCpo:=AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_XCONTAT"}) // ENTROU EM CONTATO COM O PACIENTE 
							aAuxNew[nPosCpo][2]:= ::sParam:sContato

							nPosCpo:=AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_DESCOPE"}) // Nome do Operador
							aAuxNew[nPosCpo][2]:= ::sParam:sResponsavel
             

						    Aadd(aItens, aAuxNew)                                                                
							/*   
							-----------------------------------------------------------------------------------------------------
								Roda o ExecAuto
							-----------------------------------------------------------------------------------------------------	
							*/
							
							TMKA271(aCabec, aItens, 4, "1")  
							cLock := "SUC"+xFilial("SUC")+SUC->UC_CODIGO 
							
							UnLockByName(cLock,.T.)
						    SUD->(DBCloseArea())
						    SUC->(DBCloseArea())  
					
							
			
							If lMsErroAuto
								cMsgErro := MostraErro("\logs\", "TMKA271.log") + CRLF
								lRetorno := .F. 
							EndIf
						Else
							cMsgErro := "Erro ao Buscar Itens do Atendimento."
							lRetorno := .F.
						EndIf
					EndIf
				Else
					cMsgErro := "ID Fluig não localizado."
					lRetorno := .F.
				EndIf
			Else
				cMsgErro := "Atendimento não localizado."
				lRetorno := .F.
			EndIf
		Else
			cMsgErro := "Empresa ou Filial invalida."
			lRetorno := .F.
		EndIf
	//Else
	//	cMsgErro := "Usuario ou Senha invalidos."
	//	lRetorno := .F.
	//EndIf
      
	If lRetorno
		::sRetorno := "Atendimento " + (::sParam:sCodTMK) + " atualizado com Sucesso."  
		//::sRetorno := "Atendimento atualizado com Sucesso." 
	Else
		Console(cMsgErro, .F., .T.)
		SetSoapFault(XNOMEPROG, cMsgErro)
	EndIf
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaTMK
Consulta do Atendimento do Call Center

@author Guilherme.Santos
@since 20/12/2016
@version P12
*/
//-------------------------------------------------------------------
WsMethod ConsultaTMK WsReceive sParam WsSend aRetTMK WsService WSTMKFLG
	Local cMsgErro	:= ""
	Local cQuery	:= ""
	Local cTabQry	:= GetNextAlias()
	Local nRegistro	:= 0
	Local lRetorno	:= .T.
	/*
	-----------------------------------------------------------------------------------------------------
		Validação de Usuario e Senha
	-----------------------------------------------------------------------------------------------------	
	*/
	//If VldUser(::sParam:sUser, ::sParam:sPassword)
		/*
		-----------------------------------------------------------------------------------------------------
			Validação da Empresa e Filial
		-----------------------------------------------------------------------------------------------------	
		*/
		If VldEmpFil(::sParam:sEmpresa, ::sParam:sFilial)
			/*
			-----------------------------------------------------------------------------------------------------
				Localiza o Atendimento
			-----------------------------------------------------------------------------------------------------	
			*/
			DbSelectArea("SUC")
			DbSetOrder(1)		//UC_FILIAL, UC_CODIGO
			
			If DbSeek(xFilial("SUC") + ::sParam:sCodTMK)
                nRegistro++
				AddReg(@Self:aRetTMK)

				AddCpo(@Self:aRetTMK, "UC_CODIGO"		, SUC->UC_CODIGO)
				AddCpo(@Self:aRetTMK, "UC_DATA"  		, DtoS(SUC->UC_DATA))				

				Do Case
				Case SUC->UC_XPRIORI	== "1"
					AddCpo(@Self:aRetTMK, "UC_XPRIORI"	, "1=Baixa")
				Case SUC->UC_XPRIORI	== "2"
					AddCpo(@Self:aRetTMK, "UC_XPRIORI"	, "2=Media")
				Case SUC->UC_XPRIORI	== "3"
					AddCpo(@Self:aRetTMK, "UC_XPRIORI"	, "3=Alta")
				Case SUC->UC_XPRIORI	== "4"
					AddCpo(@Self:aRetTMK, "UC_XPRIORI"	, "4=Critica")
				EndCase

				AddCpo(@Self:aRetTMK, "UC_XDTSLA"		, DtoS(SUC->UC_XDTSLA))
				AddCpo(@Self:aRetTMK, "UC_DTENCER"		, DtoS(SUC->UC_DTENCER))

				Do Case
				Case SUC->UC_XTIPO == "1"
					AddCpo(@Self:aRetTMK, "UC_XTIPO"	, "1=SAC")
				Case SUC->UC_XTIPO == "2"
					AddCpo(@Self:aRetTMK, "UC_XTIPO"	, "2=Concierge Medico")
				EndCase

                _TpEnt := TkEntidade(SUC->UC_ENTIDAD,SUC->UC_CHAVE,1)    

				AddCpo(@Self:aRetTMK, "UC_XCDMARC"		, SUC->UC_XCDMARC)
				AddCpo(@Self:aRetTMK, "UC_XMARCA"		, SUC->UC_XMARCA)
				AddCpo(@Self:aRetTMK, "UC_XUNIDAD"		, SUC->UC_XUNIDAD)
				AddCpo(@Self:aRetTMK, "UC_OPERADO"		, SUC->UC_OPERADO)
				AddCpo(@Self:aRetTMK, "U7_NOME"			, Posicione("SU7", 1, xFilial("SU7") + SUC->UC_OPERADO, "U7_NOME"))
				AddCpo(@Self:aRetTMK, "UC_CODCONT"		, SUC->UC_CODCONT)
				AddCpo(@Self:aRetTMK, "U5_CONTAT"		, Posicione("SU5",1,xFilial("SU5") + SUC->UC_CODCONT, "U5_CONTAT")) 
				AddCpo(@Self:aRetTMK, "UC_DESCCHA"		, TkEntidade(SUC->UC_ENTIDAD,SUC->UC_CHAVE,1))
                AddCpo(@Self:aRetTMK, "UC_DESCENT"		, Posicione("SX2",1,SUC->UC_ENTIDAD,"X2NOME()"))
				AddCpo(@Self:aRetTMK, "UC_XCGC"			, SUC->UC_XCGC)
				AddCpo(@Self:aRetTMK, "UC_XCRM"			, SUC->UC_XCRM)
				AddCpo(@Self:aRetTMK, "UC_XCRMUF"		, SUC->UC_XCRMUF)
				AddCpo(@Self:aRetTMK, "UC_XEMAIL"		, SUC->UC_XEMAIL)
				AddCpo(@Self:aRetTMK, "UC_XFONE1"		, SUC->UC_XFONE1)
				AddCpo(@Self:aRetTMK, "UC_XFONE2"		, SUC->UC_XFONE2)
				AddCpo(@Self:aRetTMK, "UC_XCELULA" 		, SUC->UC_XCELULA)
				AddCpo(@Self:aRetTMK, "UC_XMEDICO"		, SUC->UC_XMEDICO)				
				AddCpo(@Self:aRetTMK, "UC_OBS"			, MSMM(SUC->UC_CODOBS,80, ,,3, , ,"SUC","SUC->UC_CODOBS"))       
				
				/*
				-----------------------------------------------------------------------------------------------------
					Selecao dos Itens do Atendimento
				-----------------------------------------------------------------------------------------------------	
				*/
				cQuery += "SELECT 	SUD.UD_ITEM" + CRLF
				cQuery += ",		SUD.UD_OPERADO" + CRLF   
				cQuery += ",		SUD.UD_ASSUNTO" + CRLF
				cQuery += ",		SUD.UD_PRODUTO" + CRLF
				cQuery += ",		SUD.UD_OCORREN" + CRLF
				cQuery += ",		SUD.UD_SOLUCAO" + CRLF
				cQuery += ",		SUD.UD_DATA" + CRLF
				cQuery += ",		SUD.UD_XSLA" + CRLF                        
				cQuery += ",		SUD.UD_XDESCLA" + CRLF  
				cQuery += ",		SUD.UD_DTEXEC" + CRLF
				cQuery += ",		'S'	UD_CONTATO" + CRLF
				cQuery += ",		SUD.UD_OBS" + CRLF
				cQuery += ",		SUD.UD_CODEXEC" + CRLF
				cQuery += "FROM		" + RetSqlName("SUD") + " SUD" + CRLF
				cQuery += "WHERE	SUD.UD_FILIAL = '" + xFilial("SUD") + "'" + CRLF
				cQuery += "AND		SUD.UD_CODIGO = '" + ::sParam:sCodTMK + "'" + CRLF
				cQuery += "AND		SUD.D_E_L_E_T_ = ''" + CRLF
				cQuery += "ORDER BY SUD.UD_FILIAL, SUD.UD_CODIGO, SUD.UD_ITEM" + CRLF

				cQuery := ChangeQuery(cQuery)
					
				DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
					
				While !(cTabQry)->(Eof())
                    nRegistro++					
					AddReg(@Self:aRetTMK)
                    
                    SX5->(DBSETORDER(1))				
	                IF SX5->(dbseek(xFILIAL("SX5")+"T1"+(cTabQry)->UD_ASSUNTO))
		               _cAssun :=	SX5->X5_DESCRI
	                ENDIF
   
					AddCpo(@Self:aRetTMK, "UD_ITEM"		, (cTabQry)->UD_ITEM)
					AddCpo(@Self:aRetTMK, "UD_OPERADO"	, (cTabQry)->UD_OPERADO)
					AddCpo(@Self:aRetTMK, "UD_DESCOPE"	, Posicione("SU7", 1, xFilial("SU7") + (cTabQry)->UD_OPERADO, "U7_NOME")) //(cTabQry)->UD_DESCOPE)
					AddCpo(@Self:aRetTMK, "UD_ASSUNTO"	, _cAssun)   //(cTabQry)->UD_ASSUNTO)
					AddCpo(@Self:aRetTMK, "UD_PRODUTO"	, (cTabQry)->UD_PRODUTO)
					AddCpo(@Self:aRetTMK, "UD_OCORREN"	, Posicione("SU9", 1, xFilial("SU9") + (cTabQry)->UD_ASSUNTO + (cTabQry)->UD_OCORREN, "U9_DESC"))   //(cTabQry)->UD_OCORREN)
					AddCpo(@Self:aRetTMK, "UD_SOLUCAO"	, Posicione("SUQ", 1, xFilial("SUQ") + (cTabQry)->UD_SOLUCAO, "UQ_DESC")) //(cTabQry)->UD_SOLUCAO) 
					AddCpo(@Self:aRetTMK, "UD_DATA"		, (cTabQry)->UD_DATA)
					AddCpo(@Self:aRetTMK, "UD_XSLA"		, STR((cTabQry)->UD_XSLA,3))
					AddCpo(@Self:aRetTMK, "UD_DTEXEC"	, (cTabQry)->UD_DTEXEC)
					AddCpo(@Self:aRetTMK, "UD_CONTATO"	, (cTabQry)->UD_CONTATO)  
					AddCpo(@Self:aRetTMK, "UD_XDESCLA"	, (cTabQry)->UD_XDESCLA)					
					AddCpo(@Self:aRetTMK, "UD_OBS"		, (cTabQry)->UD_OBS)
		        	AddCpo(@Self:aRetTMK, "UD_CODEXEC"	, MSMM((cTabQry)->UD_CODEXEC,80, ,,3, , ,"SUD","SUD->UD_CODECEC"))  
					(cTabQry)->(DbSkip())
				End
				
				If Select(cTabQry) > 0
					(cTabQry)->(DbCloseArea())
				EndIf
			Else
				cMsgErro := "Atendimento não localizado."
				lRetorno := .F.
			EndIf
		Else
			cMsgErro := "Empresa ou Filial invalida."
			lRetorno := .F.
		EndIf
	//Else
	//	cMsgErro := "Usuario ou Senha invalidos."
	//	lRetorno := .F.
	//EndIf

	If !lRetorno
		Console(cMsgErro, .F., .T.)
		SetSoapFault(XNOMEPROG, cMsgErro)
	EndIf      
	
    ::aRetTMK:Registros := STR(nRegistro)
    
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} AddReg
Adiciona um Registro na Estrutura de Retorno

@author Guilherme.Santos
@since 21/12/2016
@version P12
@param aStruct	Estrutura de Retorno da Consulta - Passar por Referencia
*/
//-------------------------------------------------------------------
Static Function AddReg(aStruct)

	Aadd(aStruct:aRegTMK, WsClassNew("stRegTMK"))			//Adiciona com Base na Estrutura de Registros

	aStruct:aRegTMK[Len(aStruct:aRegTMK)]:aCpoTMK := {}		//Limpa o Registro Incluido

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} AddCpo
Adiciona um Campo a Estrutura de Retorno

@author Guilherme.Santos
@since 21/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function AddCpo(aStruct, cCampo, xValor)

	Aadd(aStruct:aRegTMK[Len(aStruct:aRegTMK)]:aCpoTMK, WsClassNew("stCpoTMK"))
	
	aStruct:aRegTMK[Len(aStruct:aRegTMK)]:aCpoTMK[Len(aStruct:aRegTMK[Len(aStruct:aRegTMK)]:aCpoTMK)]:cCpoTMK := cCampo
	aStruct:aRegTMK[Len(aStruct:aRegTMK)]:aCpoTMK[Len(aStruct:aRegTMK[Len(aStruct:aRegTMK)]:aCpoTMK)]:xVlrTMK := xValor

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} VldEmpFil
Valida a Filial Informada

@author Guilherme Santos
@since 06/09/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function VldEmpFil(cEmpTMK, cFilTMK)
	Local lRetorno	:= .F.

	DbSelectArea("SM0")
	DbSetOrder(1)
	
	If SM0->(DbSeek(cEmpTMK + cFilTMK))
		lRetorno	:= .T.
		cFilAnt		:= cFilTMK
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} VldUser
Validacao do Usuario e Senha

@author Guilherme Santos
@since 06/09/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function VldUser(cUsuario, cPassword)
	Local lRetorno	:= .T.

	PswOrder(2)

	//Verifica se o usuario é valido
	If !PswSeek(cUsuario, .T.)
		lRetorno := .F.
	Else
		//Verifica se a senha é valida para o usuário
		If !PswName(cPassword)
			lRetorno := .F.
		Endif
	Endif			

Return lRetorno	
//-------------------------------------------------------------------
/*{Protheus.doc} Console
Grava o Texto no Console do AppServer

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Static Function Console(cTexto, lGrava, lNewLog)
	Default lGrava 	:= .F.
	Default lNewLog	:= .F.

	ConOut(XNOMEPROG + " - " + DtoC(Date()) + " - " + Time() + " - " + cTexto)
Return NIL
/*
-----------------------------------------------------------------------------------------------------
	Estrutura dos Parametros
-----------------------------------------------------------------------------------------------------	
*/
WsStruct stParamTMK
	WsData sEmpresa				as String
	WsData sFilial				as String
	WsData sCodTMK				as String	
	WsData sUser				as String
	WsData sPassword			as String
	WsData sIDFluig			    as String	OPTIONAL
	WsData sResponsavel		    as String	OPTIONAL
	WsData sContato			    as String	OPTIONAL
	WsData sObservacao		    as String	OPTIONAL
	WsData sComplemento		    as String	OPTIONAL
EndWsStruct
/*
-----------------------------------------------------------------------------------------------------
	Estrutura de Retorno do Atendimento
-----------------------------------------------------------------------------------------------------	
*/
WsStruct stRetTMK
	WsData aRegTMK			as Array of stRegTMK
    WsData Registros       	as String
EndWsStruct
/*
-----------------------------------------------------------------------------------------------------
	Registros do Atendimento
-----------------------------------------------------------------------------------------------------	
	Adiciona um Registro na Estrutura do Atendimento
---------------------------------------------------------------------------------------------------------------------------------------------
	Aadd(::aRetTMK:aRegTMK, WsClassNew("stRegTMK"))
	::aRetTMK:aRegTMK[Len(::aRetTMK:aRegTMK)]:aCpoTMK := {}
---------------------------------------------------------------------------------------------------------------------------------------------
*/
WsStruct stRegTMK
	WsData aCpoTMK			as Array of stCpoTMK
EndWsStruct
/*
-----------------------------------------------------------------------------------------------------
	Campo do Atendimento
-----------------------------------------------------------------------------------------------------	
	Adiciona um Campo na Estrutura do Registro 	
---------------------------------------------------------------------------------------------------------------------------------------------	
	Aadd(::aRetTMK:aRegTMK[Len(::aRetTMK:aRegTMK)]:aCpoTMK, WsClassNew("stCpoTMK"))
	::aRetTMK:aRegTMK[Len(::aRetTMK:aRegTMK)]:aCpoTMK[Len(::aRetTMK:aRegTMK[Len(::aRetTMK:aRegTMK)]:aCpoTMK)]:cCpoTMK := "CAMPO"
	::aRetTMK:aRegTMK[Len(::aRetTMK:aRegTMK)]:aCpoTMK[Len(::aRetTMK:aRegTMK[Len(::aRetTMK:aRegTMK)]:aCpoTMK)]:xVlrTMK := "VALOR"
---------------------------------------------------------------------------------------------------------------------------------------------
*/
WsStruct stCpoTMK
	WsData cCpoTMK			as String
	WsData xVlrTMK			as String
EndWsStruct
