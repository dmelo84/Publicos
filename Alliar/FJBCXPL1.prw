#include 'protheus.ch'
#INCLUDE "TBICONN.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} FJBCXPL1
Prepara  JOb para  execução, deve ser  passado empresa  e filial
@author  bruno.ferreira // compila.com.br
@since   09/02/2019
/*/
//-------------------------------------------------------------------
User Function FJBCXPL1(aParam ) // Função Job Caixa Pleres 1 

Local lisBlind, cEmpJob, cFilJob, cFilFilter
Local nOpcProc := 1 //dia atual

Default aParam	:= {"01","00101MG0001"}

CONOUT("### FJBCXPL1: INICIO "+DTOC(DATE())+" "+TIME())

IF !empty(aParam)
	cEmpJob		:= aParam[1]
	cFilJob	:= aParam[2]
	IF LEN(aParam) >= 3
		cFilFilter	:= aParam[3]
	ENDIF
	/*
	
	RpcSetType(3)
	RpcSetEnv(cEmpJob, cFilJob)
	*/
	
	PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob
	
	lisBlind := IsBlind()
	
	If !lisBlind
		oProcess:= MsNewProcess():New({|lEnd|U_FGETCXPL(lisBlind, cFilFilter,nOpcProc)}, 'Realizando Integração de Títulos Caixa Pleres', '...',.F.  ) 
		oProcess:Activate()
	Else 
		U_FGETCXPL(lisBlind, cFilFilter,nOpcProc)
	Endif
	
	RESET ENVIRONMENT
ELSE
	CONOUT("### FJBCXPL1: Parametros inválidos")
ENDIF

CONOUT("### FJBCXPL1: FIM "+DTOC(DATE())+" "+TIME())	

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} FJBCXPL2
Prepara  JOb para  execução, deve ser  passado empresa  e filial
@author  bruno.ferreira // compila.com.br
@since   09/02/2019
/*/
//-------------------------------------------------------------------
User Function FJBCXPL2(aParam ) // Função Job Caixa Pleres 1 

Local lisBlind, cEmpJob, cFilJob, cFilFilter
Local nOpcProc := 2 //dias passados

Default aParam	:= {"01","00101MG0001"}

CONOUT("### FJBCXPL2: INICIO "+DTOC(DATE())+" "+TIME())

IF !empty(aParam)
	cEmpJob		:= aParam[1]
	cFilJob	:= aParam[2]
	IF LEN(aParam) >= 3
		cFilFilter	:= aParam[3]
	ENDIF
	
	PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob
	
	lisBlind := IsBlind()
	
	If !lisBlind
		oProcess:= MsNewProcess():New({|lEnd|U_FGETCXPL(lisBlind, cFilFilter,nOpcProc)}, 'Realizando Integração de Títulos Caixa Pleres', '...',.F.  ) 
		oProcess:Activate()
	Else 
		U_FGETCXPL(lisBlind, cFilFilter,nOpcProc)
	Endif
	
	RESET ENVIRONMENT
ELSE
	CONOUT("### FJBCXPL2: Parametros inválidos")
ENDIF

CONOUT("### FJBCXPL2: FIM "+DTOC(DATE())+" "+TIME())	

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} FGETCXPL
realiza o GET na API da do sistema pleres.
@author  bruno.ferreira // compila.com.br
@since   09/02/2019
/*/
//-------------------------------------------------------------------
User Function FGETCXPL (lIsBlind, cFilFilter,nOpcProc) // Funcao  Get Caixa Pleres

Local aAreas	:= { GetArea(), SA1->(GetArea()), SC5->(GetArea()), SE1->(GetArea()) }
Local nOldRecSC5	:= 0
Local cMsgIntegra	:= ''
Local cPath 		:= U_GetAd("MV_CXPPAT","C","Path da API Caixa Pleres - Titulos","/api/relatorios/conciliacaobancaria")
Local cHostApi		:= "" //U_GetAd("MV_CXPHOS","C","Host da API Caixa Pleres - Titulos",'http://201.94.147.251:8081' )
Local cDominioApi	:= "" //U_GetAd("MV_CXPDOM","C","Dominio do Header - Api Caixa Pleres - Titulos",'')
Local cUsuarioApi	:= "" //U_GetAd("MV_CXPUSU","C","Usuario do Header - Api Caixa Pleres",'fluig'  )
Local cPassword		:= "" //U_GetAd("MV_CXPPSS","C","Host da API Caixa Pleres - Titulos",'12345'  )
Local aHeadOut  	:= {}
Local oRestClient
Local cJson
Local cFilTit		:= ""
Local lConnect 		:= .F.
Local cAliasTIT := GetNextAlias()
Local cSemaf		:= "FGETCXPL"
Local nHSemafaro	:= 0
Local aAreaSM0		:= SM0->(GETAREA())
lOCAL cCnpjSM0		:= ""
lOCAL cIdPleres		:= ""

Local cTopReg		:= alltrim(str(U_GetAd("MV_CXPTRE","N","Top para retorno da Query",'300')))
Private lFiltraPJ	:= U_GetAd("MV_CXPJFI","L",'Filtro Cliente PJ Caixa Pleres - Titulos','.F.'  )
Private nTryInt		:= U_GetAd("MV_CXPTRY","N","Numero Tentativa Integracao- Titulos",'2'  )
Private cDataCorte	:= U_GetAd("MV_CXPDTFI","C","Data filtro Busca - Titulos",'20190401'  )

Private cMsgMemo	:= ''


Default lIsBlind := .T.
Default cFilFilter	:= ""
Default nOpcProc := 3

/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
	Abre semaforo de Processamento
------------------------------------------------------------------------------------------*/
If nOpcProc == 2
	cSemaf := "FGETCXPL2"
Endif

nHSemafaro	:= U_CPXSEMAF("A", cSemaf)

IF nHSemafaro > 0	

	CONOUT("[FJBCXPL1][FGETCXPL] SEMAFORO ABERTO COM SUCESSO ")
	
	//-----------------------------------------------
	// Abro as áreas aqui para fazer uma única vez.
	//-----------------------------------------------
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2))
	
	DbSelectArea("SC5")
	SC5->(DbSetOrder(1))
	
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	
	
	//-----------------------------------------------
	// Busco os títulos para  realizar  integração. 
	//-----------------------------------------------
	 
	cQryTit :=	" SELECT TOP "+cTopReg+" C5_FILIAL, A1_CGC, C5_XIDPLE, SA1.R_E_C_N_O_ AS SA1REC, SC5.R_E_C_N_O_ AS SC5REC, SE1.R_E_C_N_O_ AS SE1REC " + CRLF
	cQryTit +=	" FROM  "+RetSqlName("SC5")+" (NOLOCK) SC5 " + CRLF
	cQryTit +=	" INNER JOIN "+RetSqlName("SE1")+" (NOLOCK) SE1 ON  SE1.D_E_L_E_T_ = '' " + CRLF
	cQryTit +=	"	AND  E1_FILIAL = C5_FILIAL "+ CRLF
	cQryTit +=	" 	AND E1_CLIENTE = C5_CLIENTE " + CRLF
	cQryTit +=	"	AND  E1_LOJA = C5_LOJACLI " + CRLF
	cQryTit +=	"	AND E1_PREFIXO = C5_SERIE " + CRLF
	cQryTit +=	"	AND E1_NUM = C5_NOTA " + CRLF
	cQryTit +=  "   AND E1_XIDPLER = '' " + CRLF
	
	If nTryInt > 0 
		cQryTit +=  "	AND E1_XNTPLER < "+cValtochar(nTryInt)+" "+ CRLF
	Endif
	
	cQryTit +=	" INNER JOIN "+RetSqlName("SA1")+" SA1 ON  SA1.D_E_L_E_T_ = ''"  + CRLF
	cQryTit +=	"	AND A1_FILIAL = '"+xFilial("SA1")+"'"+ CRLF
	cQryTit +=	"	AND A1_COD = C5_CLIENTE  "+ CRLF
	cQryTit +=	"	AND A1_LOJA = C5_LOJACLI "+ CRLF
	IF lFiltraPJ
		cQryTit +=	"	AND A1_PESSOA = 'J'" + CRLF
	Endif
	cQryTit +=	" WHERE SC5.D_E_L_E_T_ = '' "+ CRLF
	//cQryTit +=	" AND C5_FILIAL LIKE '001%' "+ CRLF //| ### REMOVER|
	cQryTit +=	" 	AND C5_NOTA <> '' AND  C5_XIDPLE <> '' "+ CRLF
	IF !EMPTY(cFilFilter)
		cQryTit += 	"	AND C5_FILIAL = '"+cFilFilter+"' "
	ENDIF
	cQryTit += 	"	AND C5_EMISSAO > '"+cDataCorte+"' "
	If nOpcProc == 1//dia
		cQryTit += 	"	AND E1_EMISSAO = '"+dtos(date())+"' "
	ElseIf nOpcProc == 2//dias passados
		cQryTit += 	"	AND E1_EMISSAO < '"+dtos(date())+"' "
	Endif
	cQryTit +=	" 	ORDER BY C5_FILIAL, SC5.R_E_C_N_O_ DESC "+ CRLF
	
	If Select(cAliasTIT) > 0
		(cAliasTIT)->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQryTit), cAliasTIT,.F., .T.)	
	
	While (cAliasTIT)->(!EOF())
		//| |                         1                       2                   3                    4                    5
		 //Aadd (aRetTit, {(cAliasTIT)->A1_CGC, (cAliasTIT)->C5_XIDPLE, (cAliasTIT)->SA1REC, (cAliasTIT)->SC5REC,  (cAliasTIT)->SE1REC})
	
		 
	
		 /*------------------------------------------------------ Augusto Ribeiro | 05/04/2019 - 1:25:54 PM
		 	Carrega parametros do dominio
		 ------------------------------------------------------------------------------------------*/
		 IF cFilTit <> alltrim((cAliasTIT)->C5_FILIAL)
		 	cFilTit		:= alltrim((cAliasTIT)->C5_FILIAL)
		 	cDominioApi	:= ""
	 	
			cPath 		:= SUPERGETMV("MV_CXPPAT" ,.F.,"/api/relatorios/conciliacaobancaria", cFilTit) 
			//cHostApi	:= SUPERGETMV("MV_CXPHOS" ,.F.,"http://201.94.147.251:8081", cFilTit)
			//cDominioApi	:= SUPERGETMV("MV_CXPDOM" ,.F.,"", cFilTit)
//			cUsuarioApi	:= SUPERGETMV("MV_CXPUSU" ,.F.,"fluig", cFilTit)
//			cPassword	:= SUPERGETMV("MV_CXPPSS" ,.F.,"12345", cFilTit)			
			cHostApi	:= SUPERGETMV("AL_APIPLER" ,.F.,"http://35.199.77.179:8081", cFilTit)
			
			/*----------------------------------------
				25/06/2019 - Jonatas Oliveira - Compila
				Busca o Dominio no Cadastro de Empresas
				Customizado
			------------------------------------------*/
			DBSELECTAREA("SZK")
			SZK->(DBSETORDER(1)) //| 
			IF SZK->( DBSEEK( SM0->M0_CODIGO + cFilTit )) 
				IF !EMPTY(SZK->ZK_XCODDOM)
					cDominioApi	:= ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"ZL"+SZK->ZK_XCODDOM ,"X5_DESCRI"))
					ConOut("FJBCXPL1 - Dominio Parametro 1 - "+ cDominioApi+ " Filial " + cFilTit)
				ENDIF
			ENDIF	
			
			IF EMPTY(cDominioApi)
				cDominioApi	:= SUPERGETMV("AL_APIPDOM" ,.F.,"", cFilTit)
				ConOut("FJBCXPL1 - Dominio Parametro 2 - "+ cDominioApi + " Filial " + cFilTit)
			ENDIF			
									
			cUsuarioApi	:= SUPERGETMV("AL_APIPUSR" ,.F.,"fluig", cFilTit)
			cPassword	:= SUPERGETMV("AL_APIPPAS" ,.F.,"12345", cFilTit)
	//		lFiltraPJ	:= SUPERGETMV("MV_CXPJFI" ,.F.,.f., cFilTit)
	//		nTryInt		:= SUPERGETMV("MV_CXPTRY" ,.F.,2, cFilTit)
	//		cDataCorte	:= SUPERGETMV("MV_CXPDTFI",.F.,"20190401", cFilTit)
	
	
			/*------------------------------------------------------ Augusto Ribeiro | 15/04/2019 - 5:56:17 PM
				Posiciona SM0
			------------------------------------------------------------------------------------------*/
			DBSELECTAREA("SM0")
			IF ALLTRIM(SM0->M0_CODFIL) <> cFilTit
				SM0->(DBGOTOP())
				WHILE SM0->(!EOF())
					IF ALLTRIM(SM0->M0_CODFIL) == cFilTit
						cCnpjSM0	:= SM0->M0_CGC
						EXIT
					ENDIF
					SM0->(DBSKIP())
				ENDDO
			ELSE
				cCnpjSM0	:= SM0->M0_CGC
			ENDIF 
		 ENDIF
	
		/*------------------------------------------------------ Augusto Ribeiro | 05/04/2019 - 1:38:49 PM
			Caso dominio Vaizo. nao realiza a execulção.
			como id pleres pode se repedir dentro dos dominios do pleres.  não deve-se utilizar
			o dominio default
		------------------------------------------------------------------------------------------*/
		IF EMPTY(cDominioApi)
			CONOUT("[FJBCXPL1][FGETCXPL] - Dominio vazio para esta filial ["+(cAliasTIT)->C5_FILIAL+"] - MV_CXPDOM")
			(cAliasTIT)->(DbSkip())
			LOOP
		ENDIF
	
	
		//---------------------------------------------------------------
		// Se o REC da SC5 manteve, tenho mais de um título para mesmo PV
		//---------------------------------------------------------------
		If nOldRecSC5 != (cAliasTIT)->SC5REC
		
			aHeadOut := {}
			aCmpSave := {}
			cJsonRet := ''
			cMsgInt  := ''
			//--------------- header da requisiçao------------------//
			Aadd(aHeadOut, "Dominio: "+cDominioApi)
			Aadd(aHeadOut, "usuario: "+cUsuarioApi)
			Aadd(aHeadOut, "senha: "+cPassword)
			//Aadd(aHeadOut, 'Parametros:{"CNPJ":"42.771.949/0026-93","IDPLERES":"68260"}')
			//Aadd(aHeadOut, 'Parametros:{"CNPJ":"'+Transform( aTitIntegra[nl,1], "@R 99.999.999/9999-99" )+'","IDPLERES":"'+RIGHT(aTitIntegra[nl,2], 5) +'"}')
			cIdPleres	:= ALLTRIM((cAliasTIT)->C5_XIDPLE)
			cIdPleres	:= SUBSTR(cIdPleres,2,LEN(cIdPleres)-1)
			Aadd(aHeadOut, 'Parametros:{"CNPJ":"'+Transform( cCnpjSM0, "@R 99.999.999/9999-99" )+'","IDPLERES":"'+cIdPleres+'"}')
	
			oRestClient := ''
			oRestClient := FWRest():New(cHostApi)
	
			oRestClient:setPath(cPath)
	
			//--------------- Faz a requisição ------------------//
			lConnect 		:= .F.
			If oRestClient:Get(aHeadOut) 
				lConnect := .T.
				If  Len(oRestClient:GetResult()) > 5
					cJsonRet := oRestClient:GetResult()
					//--------------- Passa o objeto para  a rotina de importação ------------------//
					aCmpSave 	:= U_FJSONCXP(cJsonRet)
					cMsgInt := "SUCESSO "+CRLF+ aHeadOut[4]+CRLF+CRLF
					lSucesso 	:= .T.
				Else
					lSucesso := .F.
					cMsgInt := "Resposta req.: "+oRestClient:oResponseH:cREason+":"+oRestClient:oResponseH:cStatusCode+CRLF
					cMsgInt +=  aHeadOut[4] + "RETORNO  VAZIO" +CRLF +CRLF
				Endif
			Else 
				
				lSucesso := .F.
				cMsgInt := "Resposta req. "+oRestClient:oResponseH:cREason+":"+oRestClient:oResponseH:cStatusCode+CRLF
				cMsgInt +=  aHeadOut[4] +CRLF +CRLF
	
			EndIf
		Endif
	
		//---------------------------------------------------
		// Chama  funcao de gravaçao da integraçao
		//---------------------------------------------------
		If lConnect
			FGRVINTEGRA(aCmpSave, lSucesso, cMsgInt, (cAliasTIT)->SA1REC, (cAliasTIT)->SC5REC,  (cAliasTIT)->SE1REC) 
		Endif
	
		//---------------------------------------------------
		//Grava  o atual RECSC5
		//---------------------------------------------------
		nOldRecSC5 := (cAliasTIT)->SC5REC
		
		
		(cAliasTIT)->(DbSkip())
	End
	(cAliasTIT)->(DbCloseArea())
	
	//---------------------------------------------------
	//Grava  o LOG
	//---------------------------------------------------
	U_FGRVLOG (cMsgMemo)
	
	AEval(aAreas, {|x| RestArea(x)})
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
		FECHA semaforo de Processamento
	------------------------------------------------------------------------------------------*/	
	U_CPXSEMAF("F", cSemaf,nHSemafaro)	
ELSE
	CONOUT("[FJBCXPL1][FGETCXPL] SEMAFORO ABERTO COM SUCESSO Não foi possivel abrir o semaforo["+cSemaf+"]")
ENDIF	

RestArea(aAreaSM0)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} FJSONCXP
Realiza o parse do JSON,  traz o conteudo dos campos a serem gravados
@author  bruno.ferreira // compila.com.br
@since   10/02/2019
/*/
//-------------------------------------------------------------------

User Function FJSONCXP(cJsonToParse)

Local aGravar		:= {}

Local  cFieldSE1		:= U_GetAd("MV_CXPCMP","C","Campos Gravação da API Caixa Pleres - Titulos",'{{"SE1->E1_XIDPLER","ID_PLERES"},{"SE1->E1_XUNPLER","UNIDADE"}, {"SE1->E1_XNAPLER","ATENDIMENTO"},{"SE1->E1_XDAPLER","DT_ATEND"}}') 
Local  aFieldSE1  	:= &(cFieldSE1)
Private  oJson 

Default cJsonToParse := ''

//------------------ O JSON enviado iniciando com '['  e  finalizando com ']' dava problema ao deserealizar--------//
If LEFT (Alltrim(cJsonToParse), 1) == "["  .and. RIGHT(Alltrim(cJsonToParse), 1) == "]"
	cJsonToParse := Substr(cJsonToParse, 2, (Len(cJsonToParse)-1))
Endif

//--------------- Transforma  JSON em obJeto ------------------//
If FWJsonDeserialize(cJsonToParse,@oJson)

	For nx := 1 to Len(aFieldSE1)

		If  AttIsMemberOf(oJson, aFieldSE1[nx,2])
			cVarTmp := "oJson:"+aFieldSE1[nx,2]
			
			xAux	:= &(cVarTmp)

			IF !EMPTY(xAux)
				aAdd( aGravar, {aFieldSE1[nx,1],aFieldSE1[nx,2], xAux} ) // Campo / TAG / VALOR
			ENDIF
		Endif

	Next 

EndIf 

Return aGravar


//-------------------------------------------------------------------
/*/{Protheus.doc} FGRVINTEGRA
Grava os dados  da  integracao
@author  bruno.ferreira // compila.com.br
@since   10/02/2019
/*/
//-------------------------------------------------------------------

Static Function FGRVINTEGRA(aCmpSave, lSucesso, cMsgInt, RECSA1, RECSC5, RECSE1 )

Default aCmpSave 	:= {}
Default lSucesso	:= .F. 	
Default cMsgInt		:= ''
Default RECSA1		:= 0 
Default RECSC5		:= 0 
Default RECSE1		:= 0 

If RECSA1 > 0  .AND.  RECSC5 > 0  .AND. RECSE1 > 0 

	SA1->(DbGoto(RECSA1)) 
	SC5->(DbGoto(RECSC5)) 
	SE1->(DbGoto(RECSE1)) 

	Reclock("SE1", .F.)

	If lSucesso	

		For  nC := 1 to Len (aCmpSave) 
			xCMPO  := Substr(aCmpSave[nC,1], 6)
			xVal   := RetValores(xCMPO, aCmpSave[nC,3] )
			SE1->(&xCMPO) :=  xVal
		Next 	

		cMsgMemo += "PEDIDO: "+SC5->C5_FILIAL+" "+SC5->C5_NUM+CRLF 
		cMsgMemo += "CLIENTE:"+SA1->(A1_COD+A1_LOJA)+" "+Alltrim(SA1->A1_NOME)+CRLF
		cMsgMemo += "TÍTULO: "+SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+CRLF
		cMsgMemo += "STATUS INT.: INTEGRADO COM SUCESSO"+CRLF
		cMsgMemo += "API RESP.: " +cMsgInt +CRLF + CRLF

	Else 

		cMsgMemo += "PEDIDO: "+SC5->C5_FILIAL+" "+SC5->C5_NUM+CRLF 
		cMsgMemo += "CLIENTE:"+SA1->(A1_COD+A1_LOJA)+" "+Alltrim(SA1->A1_NOME)+CRLF
		cMsgMemo += "TÍTULO: "+SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)+CRLF
		cMsgMemo += "STATUS INT.: NAO INTEGRADO"+CRLF
		cMsgMemo += "API RESP.: " +cMsgInt +CRLF + CRLF
	Endif
	//---------------------
	//Grava  + 1 tentativa
	//---------------------
	SE1->E1_XNTPLER := SE1->E1_XNTPLER+1

	SE1->(MsUnlock())

Endif

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} FGRVLOG
GRava o LOG, dir  padrao  \system\APILOG\
@author  bruno.ferreira // compila.com.br
@since   10/02/2019
/*/
//-------------------------------------------------------------------
User Function FGRVLOG (cTxtFile, cDir, cNameFile)

Local lOk 		:= .F. 
Local cIniLog 	:= ''

Default cTxtFile	:= "FILE_TESTE_ONLY"
Default cDir 		:=  "\LOGAPI\"
Default cNameFile	:= "LOG_"+cFilAnt+"_"+DTOS(dDataBase)+"_"+Left(Time(),2)+"_"+Substr(Time(),4,2)+"_"+__CUSERID+".TXT"

cIniLog  += Replicate( '=', 80 ) +CRLF
cIniLog  += 'INICIANDO O LOG - Inclusão de Pedidos' +CRLF
cIniLog  += Replicate( '-', 80 ) +CRLF
cIniLog  += 'DATABASE...........: ' + DtoC( dDataBase ) +CRLF
cIniLog  += 'DATA...............: ' + DtoC( Date() ) +CRLF
cIniLog  += 'HORA...............: ' + Time() +CRLF
cIniLog  += 'ENVIRONMENT........: ' + GetEnvServer() +CRLF
cIniLog  += 'PATCH..............: ' + GetSrvProfString( 'StartPath', '' ) +CRLF
cIniLog  += 'ROOT...............: ' + GetSrvProfString( 'RootPath', '' ) +CRLF
cIniLog  += 'VERSÃO.............: ' + GetVersao() +CRLF
cIniLog  += 'MÓDULO.............: ' + 'SIGA' + cModulo +CRLF
cIniLog  += 'EMPRESA / FILIAL...: ' + SM0->M0_CODIGO + '/' + SM0->M0_CODFIL +CRLF
cIniLog  += 'USUÁRIO............: ' + SubStr( cUsuario, 7, 15 ) +CRLF
cIniLog  += 'EXECUÇÃO...........: '+ DtoC(dDataBase)+ " - "+Time() +CRLF
cIniLog  += Replicate( '=', 80 ) +CRLF
cIniLog  += '' +CRLF

MAKEDIR(cDir)
MEMOWRITE( cDir+cNameFile,cIniLog + cTxtFile)

If File(cDir+cNameFile)
	lOk := .T.
Endif

Return  lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} RetValores
Retorna o valor de acordo com o campo.
@author  bruno.ferreira // compila.com.br
@since   10/02/2019
/*/
//-------------------------------------------------------------------
Static Function RetValores(xCMPO, xValor )

Local xRetVal := ''

If TamSx3(xCMPO)[3] == "C"
	If VALTYPE(xvalor) == "C"
		xRetVal := xValor
	Elseif VALTYPE(xvalor) == "N"
		xRetVal := cValtochar(xValor)		
	Endif

Elseif TamSx3(xCMPO)[3] == "D"
	If VALTYPE(xvalor) == "C"
		xRetVal := LEFT(xValor,4)+ Substr(xValor,6,2)+Substr(xValor,9,2)
		xRetVal := STOD(xRetVal)
	Endif
Endif 

Return xRetVal



//-------------------------------------------------------------------
/*/{Protheus.doc} GetAd
Retorna  e cria parametro. 
@author  bruno.ferreira
@since   23/03/19
/*/
//-------------------------------------------------------------------

User Function GetAd(cPar,cTp,cDesc,xVal,cFilPar)

Local xRet

Default cTp   := "C"
Default cDesc := "Inclusão Automática pelo GETAD"
Default cFilPar := Space(TamSX3("C5_FILIAL")[1])

SX6->(dbSetOrder(1))
If ! SX6->(dbSeek(cFilPar+cPar))

	RecLock("SX6",.T.)
	SX6->(FIELDPUT(FIELDPOS("X6_FIL"),cFilPar)) 
	SX6->(FIELDPUT(FIELDPOS("X6_VAR"),cPar))  
	SX6->(FIELDPUT(FIELDPOS("X6_TIPO"),UPPER(cTp)))  
	SX6->(FIELDPUT(FIELDPOS("X6_DESCRIC"),Left(cDesc,49)))  
	SX6->(FIELDPUT(FIELDPOS("X6_DSCSPA"),SX6->(FIELDGET(FIELDPOS("X6_DESCRIC")))))  
	SX6->(FIELDPUT(FIELDPOS("X6_DSCENG"),SX6->(FIELDGET(FIELDPOS("X6_DESCRIC")))))  
	SX6->(FIELDPUT(FIELDPOS("X6_CONTEUD"),xVal))  
	SX6->(FIELDPUT(FIELDPOS("X6_CONTSPA"),SX6->(FIELDGET(FIELDPOS("X6_CONTEUD")))))  
	SX6->(FIELDPUT(FIELDPOS("X6_CONTENG"),SX6->(FIELDGET(FIELDPOS("X6_CONTEUD")))))   
	SX6->(FIELDPUT(FIELDPOS("X6_PROPRI"),"U")) 
	SX6->(FIELDPUT(FIELDPOS("X6_PYME"),"S")) 
	SX6->(msUnLock())		

EndIf

xRet := GetMV(cPar)

If UPPER(cTp) == "C"
	xRet := AllTrim(xRet)
EndIf	

Return xRet
