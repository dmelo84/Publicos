#Include 'Protheus.ch'
#Include 'RestFul.CH'


#DEFINE AC4_XTPDOC_PENDENTE "1"
#DEFINE AC4_XTPDOC_TITULAR "2"
#DEFINE AC4_XTPDOC_PASSAPORT "3"


/*/{Protheus.doc} ALPLPACI
Integração de Pacientes para o Pleres
@author Augusto Ribeiro | www.compila.com.br
@since 27/06/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function ALPLPACI(cCodAC4,nRecAC4)
Local aRet		:= {.F., ""}
Local cQuery	:= ""
Local cJson		:= ""
Local nRecAC4, cCPFTit
Local cLoginAPI	:= alltrim(GETMV("AL_APIPUSR",.F.,"protheus"))
Local cSenhaAPI	:= alltrim(GETMV("AL_APIPPAS",.F.,"1234"))
Local cHostAPI	:= alltrim(GETMV("AL_APIPLER",.F.,"http://alliar.teste.pleres.net:8805"))
Local cPathAPI	:=  "/IntegracaoFluig.svc/CadastroPacienteFluig"
Local aHeadAPI	:= {}
Local cErroRest	:= ""
Local lPosAC4	:= .f.

IF !EMPTY(cCodAC4) .or. !empty(nRecAC4)

	
	DBSELECTAREA("AC4")
	IF !EMPTY(nRecAC4)
		AC4->(DBGOTO(nRecAC4))
		lPosAC4	:= .t.
	ELSE
		AC4->(DBSETORDER(1)) //| 
		IF AC4->(DBSEEK(xfilial("AC4")+cCodAC4))
			lPosAC4	:= .t.
		ENDIF	
	ENDIF
	
	
	IF lPosAC4
	 	nRecAC4	:= AC4->(RECNO())
	
		cJson	+= U_cpxToJson("TIPODOC",AC4->AC4_XTPDOC)+","
		/*------------------------------------------------------ Augusto Ribeiro | 28/06/2018 - 7:10:01 PM
			Não envia CPF pois a identificação do paciente ocorre através do IDPLERES
		------------------------------------------------------------------------------------------*/
		//cJson	+= U_cpxToJson("CPF",AC4->AC4_XCPF)+","
		cJson	+= U_cpxToJson("NOME",AC4->AC4_NOME)+","
		cJson	+= U_cpxToJson("DTNASC",AC4->AC4_XNIVER)+","
		
		//| Busca dados do titular se necessário |
		IF AC4->AC4_XTPDOC == AC4_XTPDOC_PENDENTE
			cCPFTit	:= AC4->AC4_XCPF
			
			DBSELECTAREA("AC4")
			AC4->(DbOrderNickName("AC4CPF"))//| AC4_FILIAL+AC4_XCPF	
			IF AC4->(DBSEEK(xfilial("AC4")+cCPFTit))
				WHILE AC4->AC4_XCPF == cCPFTit
				
					IF AC4->AC4_XTPDOC == AC4_XTPDOC_TITULAR
						cJson	+= U_cpxToJson("NOMETITULAR",AC4->AC4_NOME) 					
						EXIT
					ENDIF
					
					AC4->(DBSKIP())
				ENDDO
				
				//Reposiciona no Registro
				AC4->(DBGOTO(nRecAC4))
			ENDIF
		ENDIF
		
		
		cJson	+= U_cpxToJson("PESO",AC4->AC4_XPESO)+","
		cJson	+= U_cpxToJson("ALTURA",AC4->AC4_XALTUR)+","
		cJson	+= U_cpxToJson("SEXO",AC4->AC4_XSEXO)+","		
		cJson	+= U_cpxToJson("ENDERECO",AC4->AC4_END)+","
		//cJson	+= U_cpxToJson("NUMEND",AC4->)+"," //| #### 
		cJson	+= U_cpxToJson("BAIRRO",AC4->AC4_BAIRRO)+","
		cJson	+= U_cpxToJson("MUNICIPIO",AC4->AC4_MUN)+","
		cJson	+= U_cpxToJson("UF",AC4->AC4_EST)+","		
		cJson	+= U_cpxToJson("COMPLEMENTO",AC4->AC4_XCOMPL)+","
		cJson	+= U_cpxToJson("REFERENCIA",AC4->AC4_XREFER)+","
		cJson	+= U_cpxToJson("DDD",AC4->AC4_DDD)+","
		cJson	+= U_cpxToJson("TELEFONE",AC4->AC4_TEL)+","
		//cJson	+= U_cpxToJson("DDDC","")+","
		cJson	+= U_cpxToJson("CONTATO",AC4->AC4_CONTAT)+","
		cJson	+= U_cpxToJson("EMAIL",AC4->AC4_XMAIL)+","
		cJson	+= U_cpxToJson("CONVENIO",AC4->AC4_XCONVE)+","
		cJson	+= U_cpxToJson("MATRICULA",AC4->AC4_XMATRI)+","
		//cJson	+= U_cpxToJson("RG",""
		cJson	+= U_cpxToJson("CELULAR",AC4->AC4_FAX)+","
		//cJson	+= U_cpxToJson("TELCOM1","")
		//cJson	+= U_cpxToJson("TELCOM2","")
		//cJson	+= U_cpxToJson("ESTADOCIVIL","")		
		//cJson	+= U_cpxToJson("IDPLERES",AC4->) //| #### |
		
		DBSELECTAREA("Z30")
		Z30->(DBSETORDER(2)) //| 
		IF Z30->(DBSEEK("AC4"+STR(nRecAC4,10,0))) 
			
			cErroRest	:= ""
			WHILE Z30->(!EOF()) .AND. Z30->Z30_ALIAS == "AC4" .AND. Z30->Z30_RECALI == nRecAC4
			
				//cJsonNew	:= cJson			
				//cJsonNew	+= U_cpxToJson("IDPLERES",Z30->Z30_XIDPLE)
			
			
				//aadd(aHeadAPI, "Authorization: Basic "+clPass64)
				aadd(aHeadAPI, "Content-Type: application/json")
				aadd(aHeadAPI, "accept: application/json")
				aadd(aHeadAPI, "dominio: "+alltrim(Z30->Z30_XIDPLE))
				aadd(aHeadAPI, "login: "+cLoginAPI)
				aadd(aHeadAPI, "senha: "+cSenhaAPI)
				
				oRestSend	:= FWRest():New(cHostAPI)				
			
				cJson	:= "{"+cJson+U_cpxToJson("IDPLERES",Z30->Z30_XIDPLE)+"}"
				oRestSend:SetPostParams(cJson)
				oRestSend:setPath(cPathAPI)
				If oRestSend:Post(aHeadAPI)
					aRet[1]	:= .T.
				Else
					cErroRest += ALLTRIM(UPPER(Z30->Z30_XIDPLE))+" "+oRestSend:GetLastError()+oRestSend:GetResult()
					
				EndIf				
			
				Z30->(DBSKIP()) 
			ENDDO
		ELSE
			aRet[1]	:= .t.
		ENDIF

		
	ELSE
		aRet[2] := "Codigo do paciente não localizado ["+cCodAC4+"]"
	ENDIF

ELSE
	aRet[2] := "Parametros invalidos [ALPLPACI]"
ENDIF



IF !EMPTY(cErroRest)
	aRet[1] := .F.
	aRet[2] := cErroRest
ENDIF
	
Return(aRet)



/*/{Protheus.doc} ALDOMPLE
Grava em tabela auxiliar os dados do paciente e dominio
@author Jonatas Oliveira | www.compila.com.br
@since 23/10/2017
@version 1.0
@param cIdPler, C, IDPLERES
@param cDomin, C, Dominio
@param cCpf, C, CPF
/*/
//User Function ALDOMPLE(cIdPler,cDomin, cCpf)
User Function ALPLGDOM(cAlReg, nRecno, cIdPler,cDomin, cCpf)
Local nI := 0 
Local aRet	:= {.F.,""}
lOCAL cChvReg, nIndAli

Default nRecno		:= ""


IF !EMPTY(nRecno) 
	
	IF cAlReg == "AC4" //| pacientes|
	
		DBSELECTAREA("AC4")
		AC4->(DBGOTO(nRecno))
		
		nIndAli	:= 1
		cChvReg	:= AC4->(AC4_FILIAL+AC4_PARTNE)
	
	ELSEIF cAlReg == "ACH"	// medicos
	
		DBSELECTAREA("ACH")
		AC4->(DBGOTO(nRecno))

		nIndAli	:= 1
		cChvReg	:= ACH->(ACH_FILIAL+ACH_CODIGO+ACH_LOJA)
	ENDIF
	
	
	IF !EMPTY(cAlReg) .AND. !EMPTY(cIdPler) .AND.  !EMPTY(cDomin) .AND.   !EMPTY(cChvReg) 
	
		DBSELECTAREA("Z30")
		Z30->(DBSETORDER(5)) //| Z30_ALIAS+Z30_XIDPLE+Z30_DOMINI
		cIdPler	:= PADR(alltrim(cIdPler),TAMSX3("Z30_XIDPLE")[1])
		cDomin	:= LOWER(ALLTRIM(cDomin))
		IF Z30->(DBSEEK(cAlReg+cIdPler+cDomin)) 
			aRet[1]	:= .T.		
		ELSE	
			
			DBSELECTAREA("Z30")
			Z30->(DBSETORDER(1))
			
			nTotCpo	:= Z30->(FCount())
			
			RegToMemory("Z30",.T.)
			
			M->Z30_ALIAS	:= cAlReg
			M->Z30_RECALI	:= nRecno
			M->Z30_INDALI	:= nIndAli
			M->Z30_CHVALI	:= cChvReg
			M->Z30_XIDPLE	:= cIdPler
			M->Z30_DOMINI	:= cDomin
			M->Z30_CPF		:= cCpf
			
			RECLOCK("Z30",.T.)
			
			For nI := 1 To nTotCpo
				FieldPut(nI, M->&(FIELDNAME(nI)) )
			Next nI
			
			MSUNLOCK()
			CONFIRMSX8()
			
			aRet[1]	:= .T.
			
		ENDIF
	ELSE
		aRet[2]	:= "Parametros Invalidos [ALPLGDOM]"
	ENDIF
ELSE
	aRet[2]	:= "Parametro recno Invalidos [ALPLGDOM]"
ENDIF
	
Return(aRet)

