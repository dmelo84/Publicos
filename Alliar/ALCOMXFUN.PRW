#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH" 


/*------------------------------------------------------ Augusto Ribeiro | 27/02/2017 - 8:47:10 AM
		FUNÇÕES GENERICAS modulo de Compras
------------------------------------------------------------------------------------------*/




/*/{Protheus.doc} alDelPre
Exclusao da Pre-nota
@author Augusto Ribeiro | www.compila.com.br
@since 27/02/2017
@version version
@param nRecSF1, Recno da Pre-nota SF1
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function alDelPre(nRecSF1)
Local aRet		:= {.F., ""}
Local cQuery	:= ""
Local nI, aItens, aCabec, aLinha
Local _cCodEmp, _cCodFil, _cFilNew

IF !EMPTY(nRecSF1)

	
	DBSELECTAREA("SF1")
	SF1->(DBGOTO(nRecSF1))


	/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE 
	-----------------------------------------*/
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	_cFilNew	:= SF1->F1_FILIAL  //| CODIGO DA FILIAL DE DESTINO 
	
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
	ENDIF



	aCabec := {} 
	aItens := {}
	nOpcao := 5

	aadd(aCabec,{"F1_FILIAL"  ,SF1->F1_FILIAL                                        ,Nil}) 
	aadd(aCabec,{"F1_TIPO"    ,SF1->F1_TIPO                                                         ,Nil}) 
	aadd(aCabec,{"F1_FORMUL"  ,SF1->F1_FORMUL                                                         ,Nil}) 
	aadd(aCabec,{"F1_DOC"     ,SF1->F1_DOC                                                       ,Nil})   
	aadd(aCabec,{"F1_SERIE"   ,SF1->F1_SERIE                                                      ,Nil})      
	aadd(aCabec,{"F1_EMISSAO" ,SF1->F1_EMISSAO                                                       ,Nil}) 
	aadd(aCabec,{"F1_FORNECE" ,SF1->F1_FORNECE ,Nil}) 
	aadd(aCabec,{"F1_LOJA"    ,SF1->F1_LOJA   ,Nil}) 
	//aadd(aCabec,{"F1_XIDFLG"  ,aPNFEntrada:F1_XIDFLG                                                          ,Nil})
	//aadd(aCabec,{"F1_USERID"  ,SF1->                                                      ,Nil})
	//	aadd(aCabec,{"F1_DTDIGIT" ,SF1->                                                                     ,Nil})


	DBSELECTAREA("SD1")
	SD1->(DBSETORDER(1)) //| D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
	IF SD1->(DBSEEK(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))) 
		
		WHILE SD1->(!EOF()) .AND. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
		
			aLinha := {} 
			
			aadd(aLinha,{"D1_FILIAL"  ,SD1->D1_FILIAL ,Nil})
			aadd(aLinha,{"D1_COD"     ,SD1->D1_COD     ,Nil}) 
			aadd(aLinha,{"D1_PEDIDO"  ,SD1->D1_PEDIDO    ,Nil}) 
			aadd(aLinha,{"D1_ITEMPC"  ,SD1->D1_ITEMPC    ,Nil})
			aadd(aLinha,{"D1_QUANT"   ,SD1->D1_QUANT ,Nil}) 
			aadd(aLinha,{"D1_VUNIT"   ,SD1->D1_VUNIT ,Nil}) 
			aadd(aLinha,{"D1_TOTAL"   ,SD1->D1_TOTAL ,Nil}) 
		    aadd(aLinha,{"D1_SERIE"   ,SD1->D1_SERIE                 ,Nil})
		    aadd(aLinha,{"D1_EMISSAO" ,SD1->D1_EMISSAO                ,Nil})
		    aadd(aLinha,{"D1_TIPO"    ,SD1->D1_TIPO                                 ,Nil})
		    aadd(aLinha,{"D1_TP"      ,SD1->D1_TP                              ,Nil})
		    aadd(aLinha,{"D1_FORNECE" ,SD1->D1_FORNECE             ,Nil})
		    aadd(aLinha,{"D1_LOJA"    ,SD1->D1_LOJA                  ,Nil})
		    aadd(aLinha,{"D1_DTDIGIT" ,SD1->D1_DTDIGIT              ,Nil})
		    aadd(aLinha,{"D1_ITEM"    ,SD1->D1_ITEM     ,Nil}) 	
		    aadd(aLinha,{"D1_UM"      ,SD1->D1_UM      ,Nil})
		    aadd(aLinha,{"D1_CC"      ,SD1->D1_CC      ,Nil})
		     
	     	
	     	aadd(aItens,aLinha)		
		
		
			SD1->(DBSKIP()) 
		ENDDO
			
	ENDIF

	lMsErroAuto	:= .F.
	
	MSExecAuto( {|x,y,z| MATA140(x,y,z) }, aCabec, aItens, nOpcao)   
	
	If 	lMsErroAuto

		cAutoLog	:= alltrim(NOMEAUTOLOG())
	
		cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
		cMemo := STRTRAN(cMemo,"'","")
	
		//| Apaga arquivo de Log
		Ferase(cAutoLog)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Le Log da Execauto e retorna mensagem amigavel ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRet[2] := U_CPXERRO(cMemo)
	
		IF EMPTY(aRet[2])
			aRet[2]	:= alltrim(cMemo)
		ENDIF	
	
	ELSE
		
		aRet[1]	:= .T.
	Endif
	
	/*---------------------------------------
		Restaura FILIAL  
	-----------------------------------------*/
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)			 			
	ENDIF   			



ELSE
	aRet[2]:= "Parametros invalidos. Recno SF1 vazio"
ENDIF

Return(aRet)



/*/{Protheus.doc} alLogo
Retorna Path do Logotipo da Unidade Passada.
	1. Retorna Logo Especifico da FIlial
	2. Caso 1 não exista, retorna logo da Marca
	3. Caso 2 não exista, retorna logo da Alliar
@author Augusto Ribeiro | www.compila.com.br
@since 26/04/2017
@version undefined
@param cFilLogo, Filial a retornar o Logo
@param cOpc, prefixo incorporado no nome do arquivo, utilizado para diferenciar logotipos de acordo com o fim desejado. 
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function alLogo(cFilLogo,cOpc)
Local cRet			:= ""
Local cLogoAlliar	:= "alliar.bmp"
Local cPathLogo		:= ""
Local cEmpLogo		:= ""
Local cLogoParam	:= ""

Default cOpc		:= ""
Default cFilLogo 	:= xfilial()

cFilLogo	:= ALLTRIM(cFilLogo)
cEmpLogo	:= LEFT(cFilLogo,5)

IF cOpc == "WEB"
	cLogoParam	:= alltrim(SUPERGETMV("ES_LOGWEBR",.F.,"", cFilLogo))
	IF !EMPTY(cLogoParam)
		cRet		:= cLogoParam //| Logo especifico da filial na WEB 
	ELSE	
		cRet		:= "rps_"+LEFT(cEmpLogo,3)+".png"
	ENDIF 	
ELSE
	/*--------------------------
		Filial
	---------------------------*/
	cPathLogo	:= "\logotipos\"+cOpc+cFilLogo+".bmp"
	IF FILE(cPathLogo)
		cRet	:= cPathLogo
	ELSE
		/*--------------------------
			Empresa
		---------------------------*/
		cPathLogo	:= "\logotipos\"+cOpc+cEmpLogo+".bmp"
		IF  FILE(cPathLogo)	
			cRet	:=  cPathLogo
		ELSE
			/*--------------------------
				Grupo de Empresa
			---------------------------*/
			cEmpLogo	:= LEFT(cEmpLogo,3)
			cPathLogo	:= "\logotipos\"+cOpc+cEmpLogo+".bmp"
			IF  FILE(cPathLogo)
				cRet	:=  cPathLogo
			ENDIF
		ENDIF
	ENDIF
	
	
	IF EMPTY(cRet)
		cRet	:= "\logotipos\"+cLogoAlliar
	ENDIF
ENDIF	
	
Return(cRet)







/*/{Protheus.doc} alSendSMS
Envio de SMS através do serviço INFOBIP
@author Fabio Sales | www.compila.com.br
@since 06/06/2017
@version 1.0
@param clFrom	, C, De onde a mensagem esta partindo
@param clTo		, C, Destinatário da mensagem com DDD+Celular tudo junto e somente número Exemplo: 11999999999
@param clmsg	, C, Mensagem a ser enviada, não pode conter acentuação.
@return aRet, {Processado, cMsgErro,Dados do retorno}
/*/
User Function alSendSMS(clto,clmsg)
	
	Local alHeadStr := {}
	Local alRet		:= {.F.,"",{}}
	Local clHostAPI	:= Alltrim(SuperGetMV("AL_SMSAPI"	, NIL, "https://api.infobip.com")) 
	Local clPath	:= Alltrim(SuperGetMV("AL_SMSPATH"	, NIL, "/sms/1/text/single")) 	
	Local clCliID	:= Alltrim(SuperGetMV("AL_SMSCLIID"	, NIL, "totvs"))
	Local clCliPass	:= Alltrim(SuperGetMV("AL_SMSCLIPA"	, NIL, "kYXIeB6i"))
	Local clPass64	:= Encode64(clCliID+":"+clCliPass)
	Local clJason	:= ""
	Local clResult	:= ""
	Local oJsonRet
	Local clFrom	:= "ALLIAR"
	
	Default clto 	:= ""
	Default clmsg 	:= ""
	
	//| Limpa os espeços e retira os caracteres comuns de telefones.
		
	IF !Empty(clto) .AND. !Empty(clmsg)
	
		clto := StrTran(clto,"-","")
		clto := StrTran(clto," ","")
		clto := StrTran(clto,")","")
		clto := StrTran(clto,"(","")
				
		//| Validação básica do numero do telefone.
		
		IF LEN(clto) < 10
		
			alRet[2]:= "DDD ou telefone está incorreto." 
			Return(alRet)
			
		ENDIF
		
		//| Concatena o código internacional do país.
		
		clto := "55" + Alltrim(clto)
		
		aadd(alHeadStr, "Authorization: Basic "+clPass64)
		aadd(alHeadStr, "Content-Type: application/json")
		aadd(alHeadStr, "accept: application/json")
		
		oRestSend	:= FWRest():New(clHostAPI)	
			
		clJason := "{"		
		clJason += '"from": "' + clFrom + '",'
		clJason += '"to": "' + clTo + '",'
		clJason += '"text": "' + clmsg + '"'														
		clJason += '}'
			
		oRestSend:SetPostParams(clJason)
		oRestSend:setPath(clPath)
				
		If oRestSend:Post(alHeadStr)
			
			clResult := oRestSend:GetResult()
					
			IF FWJsonDeserialize(clResult,@oJsonRet)
							
				IF VALTYPE(oJsonRet:MESSAGES[1]:STATUS)== "O"
					
					olMessage	:= oJsonRet:MESSAGES[1]								
					olStatus	:= oJsonRet:MESSAGES[1]:STATUS
														
					IF VALTYPE(olStatus:groupid)=="N" .AND. VALTYPE(olStatus:id)=="N"
					
						IF	olStatus:groupid <> 5 //| Se o grupo for diferente de rejeitado aceitamos como Sucesso.
											
							alRet[1]	:= .T.
																										
						ELSE
							IF VALTYPE(alRet[2]:= olStatus:description)== "C"
								alRet[2]:= olStatus:description
							ELSE
								alRet[2]:= "Erro oa enviar SMS: Retorno não definido."
							ENDIF
							
						ENDIF	
						
						alRet[3] 	:= {olMessage:messageid,olMessage:smscount,olStatus:description,olStatus:groupid,olStatus:groupname,olStatus:id,olStatus:name}
									
					ELSE
					
						alRet[2]:= "Retorno inesperado."
					
					ENDIF																												
														
				ELSE
				
					alRet[2]:= "Erro desqualificado no envio do SMS para o número: " + clTo
					
				ENDIF								
				
			ELSE
			
				alRet[2]:= clResult
			
			ENDIF
			
		Else
		
			alRet[2] := oRestSend:GetLastError()
			
		EndIf
		 		
	Else
	
		alRet[2]:= "Telefone com DDD e mensagem não podem esta vazio."
	
	Endif
	
Return(alRet)



/*/{Protheus.doc} alJClaNF
Job para classificação da NF
@author Augusto Ribeiro | www.compila.com.br
@since 08/09/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function alJClaNF(aParam)
	Local cNatFin	:= ""

Default aParam		:= {}

IF LEN(aParam) >= 6

	cCodEmp	:= aParam[1]
	cCodFil	:= aParam[2]
	cDoc	:= aParam[3]
	cSerie	:= aParam[4]
	cFor	:= aParam[5]
	cLoja	:= aParam[6]
	
	IF LEN(aParam) > 6 
		cNatFin := aParam[7]
	ENDIF 
	
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
	
		U_alClaNFE(cDoc, cSerie, cFor, cLoja, cNatFin)	 
	
	RESET ENVIRONMENT

ENDIF

Return()



/*/{Protheus.doc} alClaNFE
Classificacao automatica da Pre-Nota       
@author Augusto Ribeiro | www.compila.com.br
@since 08/09/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function alClaNFE(cDoc, cSerie, cFor, cLoja, cNatFin)
Local aRet := {.F., ""}
Local aCabec                   	
Local aLinha
Local aItens, cTES     
Local lClassifica	:= .T.

Local nCpoSF1	:= SF1->(FCOUNT())
Local nCpoSD1	:= SD1->(FCOUNT())
Local nF1COND
Local nI, nY, cLogErro
Local cErroExec	:= ""
Local nD1NFORI, nD1NFSERIORI, nD1NFITEMORI, nD1TES

Private lTitNFeAuto	:= .F. //| Variavel utilizada no P.E. MTCOLSE2 para gravação customizada dos titulos

Default cNatFin := ""              

IF !EMPTY(cDoc) .AND.;
	!EMPTY(cFor) .AND.;
	!EMPTY(cLoja)
	
	cDoc	:= PADR(ALLTRIM(cDoc),TAMSX3("F1_DOC")[1])
	cSerie	:= PADR(ALLTRIM(cSerie),TAMSX3("F1_SERIE")[1])
	cFor	:= PADR(ALLTRIM(cFor),TAMSX3("F1_FORNECE")[1])
	cLoja	:= PADR(ALLTRIM(cLoja),TAMSX3("F1_LOJA")[1])
	
                                                                                     
	DBSELECTAREA("SA2") 
	SA2->(DBSETORDER(1))
	
	DBSELECTAREA("SB1") 
	SB1->(DBSETORDER(1))	
 
	DBSELECTAREA("SF1") 
	SF1->(DBSETORDER(1))//| F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_TIPO
	IF SF1->(DBSEEK(XFILIAL("SF1")+cDoc+cSerie+cFor+cLoja))
	
		
		DBSELECTAREA("SD1") 		
		SD1->(DBSETORDER(1))//| D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM
		IF SD1->( DBSEEK(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)) )
			
			aCabec	:= {}
			aLinha	:= {}
			aItens	:= {}
			           
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alimenta CABECALHO da Nota ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			DBSELECTAREA("SF1") 
			FOR nI := 1 to nCpoSF1	 
				IF ALLTRIM(FieldName(nI)) == "F1_COND"
					nF1COND	:= nI	//AADD(aCabec,{FieldName(nI), "001", nil })
				ENDIF							
				
				IF !EMPTY(FieldGet(nI))	 .OR. nF1COND > 0
					AADD(aCabec,{FieldName(nI), FieldGet(nI), nil })			
				ENDIF
			NEXT nI                                                             

		                               
			
			WHILE SD1->(!EOF()) .AND. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)

			                 
				DBSELECTAREA("SD1")
				aLinha	:= {}
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Alimenta ITENS da Nota     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				FOR nI := 1 to nCpoSD1	  
					
					IF ALLTRIM(FieldName(nI)) == "D1_TES"
						//aChave	:= {SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_COD, SD1->D1_ITEM}
	                                                    
						cTES	:= SD1->(FieldGet(nI))
						IF EMPTY(cTES)    
						
							DBSELECTAREA("SB1")
							SB1->(DBSETORDER(1)) //| 
							IF SB1->(DBSEEK(xfilial("SB1")+SD1->D1_COD)) 
								IF !EMPTY(SB1->B1_TE)
									cTES	:= SB1->B1_TE
								ENDIF
							ENDIF
							DBSELECTAREA("SD1")
							
							/*
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica se a TES Gera - DUPLICATA ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							DBSELECTAREA("SF4")
							SF4->(DBSETORDER(1))   //| F4_FILIAL, F4_CODIGO
		
							IF SF4->(DBSEEK(XFILIAL("SF4")+cTES))
								IF SF4->F4_DUPLIC == "S"
									lTitNFeAuto	:= .T.
								ENDIF
							ENDIF
							*/
						ENDIF
						AADD(aLinha,{SD1->(FieldName(nI)), cTES , nil })
					ELSE
						IF !EMPTY(FieldGet(nI))		
							AADD(aLinha,{SD1->(FieldName(nI)), SD1->(FieldGet(nI)), nil })								
						ENDIF
					ENDIF
					
					/*
					IF !EMPTY(FieldGet(nI))		
						AADD(aLinha,{FieldName(nI), FieldGet(nI), nil })								
					ENDIF
					*/
				NEXT nI	 
				
				
				aadd(aItens, aLinha)
                 
				SD1->(DBSKIP())
			ENDDO
			
			
               
			IF lClassifica  

				aadd(aCabec,{"E2_NATUREZ"  , cNatFin          ,Nil})
				
				BEGIN TRANSACTION
				
					lMSErroAuto := .F. 
	
					nOpc	:= 4 //| Classificacao
					MSExecAuto({|x,y,z|Mata103(x,y,z)},aCabec,aItens,nOpc)   
	
					If lMSErroAuto
						DisarmTransaction()
						//MostraErro()
	
						cErroExec	:= ""
						cPathLog	:=	NOMEAUTOLOG()
						IF !EMPTY(cPathLog)
							cLogErro	:=	STRTRAN(MemoRead(cPathLog),'"',"")
							
						  	cErroExec	:= U_CPXERRO(cLogErro) //U_cpReadError(cErroExec)
						  	
						  	IF EMPTY(ALLTRIM(cErroExec))
						  		cErroExec	:= ALLTRIM(STRTRAN(STRTRAN(LEFT(cLogErro,100),CHR(10)," "),CHR(13)," "))
						  	ENDIF
						ENDIF
						
						aRet[2]	:= "Falha na Classificação da Pre-Nota "+CRLF+cErroExec+CRLF
						
						

						/*------------------------------------------------------ Augusto Ribeiro | 27/02/2017 - 9:53:31 AM
							FLUIG - Notifica processo no Fluig
						------------------------------------------------------------------------------------------*/
						IF !EMPTY(SF1->F1_XIDFLG) .and. SF1->F1_XFLUXOF == "3" // somente Honorarios Medicos neste momento
						
							/*------------------------------------------------------ Augusto Ribeiro | 24/08/2017 - 2:37:47 PM
								Tratamento para processo de concessionárias
							------------------------------------------------------------------------------------------*/
							nAtivFluig	:= 6
							IF SF1->F1_XFLUXOF == "3" // Honorarios Medicos
								nAtivFluig	:= 9 //| Falha |
							ELSEIF Empty(SD1->D1_PEDIDO) 
								nAtivFluig	:= 12
							endif	
						
							IF !(ISBLIND())
								MsgRun ( "Integrando NF com Fluig...", "Integração Fluig", {|| aRetAux	:= U_cpFSSTsk(VAL(SF1->F1_XIDFLG), SF1->F1_USERID, nAtivFluig, aRet[2], .T., .F., /*aCardData */ ) } )	
							ELSE
								aRetAux	:= U_cpFSSTsk(VAL(SF1->F1_XIDFLG), SF1->F1_USERID, nAtivFluig, aRet[2], .T., .F., /*aCardData */ )
							ENDIF 
								
							 	
							IF !(aRetAux[1])
								//Conout("SF1100I "+SF1->F1_XFLUXOF, "ERRO: "+aRetAux[2])
								Help(" ",1,"SF1100I",,aRetAux[2],4,5)
							ENDIF
						
						ENDIF
						
					ELSE          
				
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Pre-Nota Gravada com Sucesso ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aRet[1]	:= .T.
						aRet[2]	:= "Nota Fiscal Classificada com sucesso!"+CRLF
						/*
						DBSELECTAREA("SE2")
						SE2->(RecLock("SE2",.F.))
							SE2->E2_NATUREZ := cNatFin					
						SE2->(MsUnLock())
						*/
					ENDIF		     
					
				END TRANSACTION
			ENDIF
						
		ELSE                                        
			aRet[2]	:= "Pre-Nota Não encontrada [SD1]"+CRLF			
		ENDIF
	ELSE
		aRet[2]	:= "Pre-Nota Não encontrada [SF1]"+CRLF	
	ENDIF	                                    
ELSE
	aRet[2]	:= "Parametros em branco."+CRLF	
ENDIF

       

Return(aRet)


