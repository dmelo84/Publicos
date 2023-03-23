/*#Include "Totvs.ch" 
#Include "TopConn.ch"
#Include "TBIConn.ch"
#INCLUDE "FILEIO.CH"  
*/
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#include "apwizard.ch"
#INCLUDE "TBICODE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"  

User Function ALRTT2()
Local dDiaHj := dDataBase
private cPerg := "XKCIPA"	

dDiaHj += 30

alert ("Hoje: " + dtoc(dDataBase) + " mais 30 dias resulta em: " + dtoc(dDiaHj))
return



/*/{Protheus.doc} ALRMDTP1

@author Jorge Heitor
@since 24/12/2015
@version 12.001.7
@description Solucao paliatoiva para fase de teste
@obs Específico ALLIAR - Abertura CIPA

/*/
User Function ALRMDTP1()
Local dMeuData := dDataBase
/*
dMeuData += 30
alert ("Daqui 30 dias: " + dtos(dMeuData))
	*/
U_ALRMDT01(cEmpAnt,cFilAnt)
return

/*/{Protheus.doc} ALRMDT01

@author Jorge Heitor
@since 24/12/2015
@version 12.001.7
@description Schedule para abertura de Solicitação Fluig (monitora vencimento da CIPA e gera nova atividade)
@obs Específico ALLIAR - Abertura CIPA

/*/
User Function ALRMDT01(aParam)
Local cDias 
Local cPerg := "XYCIPA"
Local cQuery		:= ""
Local cUp := ""
Local lRet   := .T.
Private cSimLog :=   ''

	//If !IsInCallStack("U_ALRMDTP1")
	RpcSetType(3)
		
	RpcSetEnv(aParam[1], aParam[2])
	//	RpcSetEnv(/*Empresa*/ "01", /*Filial*/ , /*Login*/, /*Senha*/, "MDT", "ALRMDT01", {"TNW","TNN"}, /*lShowFinal*/.F., /*lAbend*/ .F., /*lOpenSX*/ .T., /*lConnect*/ .T.) //Remover quando for agendado o Schedule
	//EndIf
	cSimLog :=   SuperGetMV("ES_CIRIMP",, '')
	cSimLog := Alltrim(cSimLog)
	

/*
    If IsInCallStack("U_ALRMDTP1")
    	
    	TNWAjust(CPERG)
    	If pergunte(CPERG,.T.)

    	
    		If !EMpty(mv_par01) .and. !Empty(mv_par02)
	    		cUp := " UPDATE " + RetSqlName( "TNW" )
				cUp += " 		SET TNW_DTFIM = '" +dtos(mv_par01) + "', TNW_XIDFLG = '' , TNW_USUFIM = ' '  " 
				cUp += " WHERE TNW_TIPO = '1'  AND TNW_FILIAL = '" + xFilial( "TNW" ) + "'  AND TNW_CODIGO = '" + mv_par02 + "' AND D_E_L_E_T_ = '' " 

				TCSQLEXEC(cUp)
    		EndIf
    	EndIf    	

	endif*/
	
	If lRet
		
		cDias :=   SuperGetMV("ES_CIDIAS",, '')
		
	
		//Verificar para cada Filial se existe pendencia de inclusão de novo mandato
		//cQuery := " SELECT R_E_C_N_O_ as NREG,* FROM " + RetSqlName("TNW") + " WHERE TNW_TIPO = '1' AND CAST(TNW_DTINIC AS DATE) = DateAdd(day,TNW_ANTES,Cast('" + DtoS(Date()) + "' as Date)) AND TNW_USUFIM = ' ' AND D_E_L_E_T_ = '' "
		
		If EMpty(cDias)
			cDias := "30"
		EndIf
			
		cQuery := " SELECT R_E_C_N_O_ as NREG,* FROM " + RetSqlName("TNW") + " WHERE TNW_TIPO = '1' AND '" + DtoS(Date()) + "' = DateAdd(day, (-1)* " + AllTrim(cDias) + " , TNW_DTFIM) AND TNW_USUFIM = ' ' AND D_E_L_E_T_ = '' "
	
		
		//Considerar ID Fluig
		cQuery += " AND TNW_XIDFLG = '' "
		
		//If cSimLog == "SIM"	
			//Conout("passo 3")
		
			//Conout(cQuery)
			//Conout(" ")
		//EndIf
	
		cQuery := ChangeQuery(cQuery)
		
		
		If Select("TTNW") > 0
			TTNW->(dbCloseArea())
		EndIf
		
		TcQuery cQuery Alias "TTNW" NEW
	
	
		dbSelectArea("TTNW")
		
		If !Eof()
			
			cEmpDest := cEmpAnt
			
			dbSelectArea("TTNW")
			While !Eof()
				
				cFilDest := TTNW->TNW_FILIAL
						
				GeraFluig(cEmpDest,cFilDest,TTNW->NREG)
			
				dbSelectArea("TTNW")
				dbSkip(1)
				
			End
							
		EndIf
			
	EndIf
	
	
	//If !IsInCallStack("U_ALRMDTP1")
		RpcClearEnv()
	//EndIf
	
Return Nil 

/*/{Protheus.doc} GeraFluig

@author Jorge Heitor
@since 28/12/2015
@version 12.001.7
@description Função para geração da Atividade no Fluig
@obs Específico ALLIAR - Abertura CIPA

/*/
Static Function GeraFluig(cEmpDest,cFilDest,nRecTNW)

	Local aEmp				:= NomeEmpresa(cEmpDest,cFilDest)
	Local cNomeEmp			:= aEmp[1]
	Local cNomeFil			:= aEmp[2]
	Local nCompanyID		:= Val(GetMv("MV_ECMEMP"))
	Local cUserID			:= GetMv("MV_ECMMAT")
	Local cProcessID		:= "AberturaCIPA" //Padrão para o proceso
	Local nChoosedState		:= 12 //Início da Atividade (era 1, virou 4 agora é 12)
	Local cUserName			:= GetMv("MV_ECMUSER")
	Local cPassword			:= GetMv("MV_ECMPSW")
	Local cColleagueID		:= GetMv("MV_ECMMAT")
	Local aCardData			:= {}
	Local aTemp
	Local oFluig			:= Nil
	Local x,y
	Local nI
	Local cStr := ''
	Local cIdFluig			:= ''
	Local aAreaTNW			:= TNW->(GetArea())
	Private cNumSol			:= ''
	
	//Monta Formulário para Início da Tarefa
	aTemp := {}
	aAdd(aTemp,"M0_CODIGO")
	aAdd(aTemp,cEmpDest)
	aAdd(aCardData,aClone(aTemp))
	
	aTemp := {}
	aAdd(aTemp,"M0_NOME")
	aAdd(aTemp,cNomeEmp)
	aAdd(aCardData,aClone(aTemp))
	
	aTemp := {}
	aAdd(aTemp,"M0_CODFIL")
	aAdd(aTemp,cFilDest)
	aAdd(aCardData,aClone(aTemp))
	
	aTemp := {}
	aAdd(aTemp,"M0_FILIAL")
	aAdd(aTemp,cNomeFil)
	aAdd(aCardData,aClone(aTemp))
	
	PswOrder(2)
	PswSeek(cUserName  ,.T.)

	aTemp := {}
	aAdd(aTemp,"login")

	aAdd(aTemp,(PswRet()[1][14])/*"integrador"*/)
	aAdd(aCardData,aClone(aTemp))
	
	aTemp := {}
	aAdd(aTemp,"colleagueName")

	aAdd(aTemp,(PswRet()[1][02])/*"integrador"*/)
	aAdd(aCardData,aClone(aTemp))
	
	aTemp := {}
	aAdd(aTemp,"dataAbertura")
	aAdd(aTemp,DtoC(Date()))
	aAdd(aCardData,aClone(aTemp))
	
	//Instancia WebService Client Fluig
	oFluig := WSECMWorkflowEngineServiceService():New()

	oFluig:cUserName		:= cUserName
	
	oFluig:cPassword		:= cPassword
	
	
	cStr := getmv("MV_ECMURL")
	cStr += "ECMWorkflowEngineService?wsdl"
	oFluig:_Url := cSTr
	oFluig:nCompanyID		:= nCompanyID
	
	oFluig:cProcessID		:= cProcessID
	
	oFLuig:nChoosedState	:= nChoosedState
	
	oFluig:cColleagueID		:= cColleagueID
	
	oFluig:cUserID			:= cUserID
	
	oFluig:lCompleteTask	:= .T.
	
	oFluig:lManagerMode		:= .F.
	
	oFluig:cComments		:= "Processo de Abertura CIPA"
	
	//Atribui CardData
	For x:= 1 To Len(aCardData)
	
	
		
		aAdd(oFluig:OWSSTARTPROCESSCARDDATA:oWSitem , ECMWorkflowEngineServiceService_stringArray():New())
		
		For y:= 1 To Len(aCardData[x])
		
			
			xValor := aCardData[x][y]
			
			//Trata valores diferentes de caractere para adicionar no array cItem
			//Não trato valores caractere, pois os mesmos são incluidos normalmente no xml
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
		
			aAdd(aTail(oFluig:OWSSTARTPROCESSCARDDATA:oWSitem):cItem,xValor)
			
		Next y
		
	Next x
	
	//Inicia processo no Fluig
	If !oFluig:StartProcess()

		/*If cSimLog == "SIM"	
			Conout("GeraFluig 001 - falha")
			
			Conout("Falha na comunicação com o Fluig. A Solicitação não foi iniciada.")
			Conout("Verificar com o administrador do Protheus, WebServer Protheus ou Fluig não iniciado") 
			Conout('Erro de Execução : '+GetWSCError())
		endif */
	Else
	
		If oFluig:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[1] = 'ERROR'
		
			/*If cSimLog == "SIM"	
				Conout("GeraFluig 002 - falha")
			
				Conout("Erro durante a abertura da solicitação Fluig.")
				Conout("Descrição do erro:")
				Conout(oFluig:OWSSTARTPROCESSRESULT:OWSITEM[1]:CITEM[2])
			EndIf*/
		
		Else
		
			For nI := 1 to Len(oFluig:OWSSTARTPROCESSRESULT:OWSITEM)
				
				If AllTrim(oFluig:OWSSTARTPROCESSRESULT:OWSITEM[nI]:cItem[1]) == "iProcess"
					
					cIdFluig := oFluig:OWSSTARTPROCESSRESULT:OWSITEM[nI]:cItem[2]
				
					Exit
					
				EndIf
				
			Next nI
			
			dbselectarea('SX6')
			SX6->(dbsetorder(1))
			SX6->( dbseek(xfilial() + "ES_FLUCI")  )
					
			if SX6->(!Eof())//sempre inicializa com zero
				PutMV("ES_FLUCI", AllTrim( cIdFluig ) + ", " + AllTrim(cEMpAnt) + ", " + AllTrim(cFilAnt) )
			endif
			
			//Gravação do ID Fluig na pendencia que originou a inclusão de Novo Mandato
			cAliasTMP := Alias()
			
			dbSelectArea("TNW")
			dbGoTo(nRecTNW)
			
			RecLock("TNW",.F.)
			TNW->TNW_XIDFLG := cIdFluig
			MsUnlock()
			
			dbSelectArea(cALiasTMP)
			
		EndIf
		
	EndIf
	
	RestArea(aAreaTNW)

	
Return Nil


/*/{Protheus.doc} NomeEmpresa

@author Jorge Heitor
@since 28/12/2015
@version 12.001.7
@description Retorna Nome da Empresa/Filial do sistema 
@obs Específico ALLIAR - Abertura CIPA

/*/	
Static Function NomeEmpresa(cCodEmp,cCodFil)

	Local aRet	:= {}
	Local aArea	:= GetArea()
	
	dbSelectArea("SM0")
	dbSetOrder(1)
	dbSeek(cCodEmp+cCodFil)
	
	If Found()
		
		aAdd(aRet,SM0->M0_NOME)
		aAdd(aRet,SM0->M0_FILIAL)
		
	Else
		
		aRet := { "N/A","N/A" }
		
	EndIf
	
	RestArea(aArea)
	
Return aRet



//log auxiliar para debug de performance em fase de testes
//static Function LogProcesso(cTxt)
//Local cFIleOpen :=   SuperGetMV("ES_CIRIMP",, '') // "c:\temp\log_val.txt"  //SuperGetMV("ES_DITIMP",, '') // "c:\cargaRH\" + "log_sra.txt"
//Local nHandleCr := 0
//Default cMAlias := ''        
/*conout ("ES_CIRIMP: " + cFIleOpen)
If !Empty(cFIleOpen)
    counout ('F1=====')
	nHandleCr := fopen( cFileOpen  , FO_READWRITE + FO_SHARED )

    counout ('F2=====')
	If nHandleCr  == -1
		nHandleCr := FCreate(cFileOpen)//esta função cria o arquivo automaticamente sempre no protheus_data\system
	Else                 
		fseek(nHandleCr, 0, FS_END)
	EndIf		
		   
    counout ('F3=====')
	FWrite(nHandleCr, cTxt + Chr(13) + CHr(10))
		
    counout ('F4=====')
	FClose(nHandleCr)
	
    counout ('F5=====') 
EndIf
*/
    //counout ('F6=====')
//return                         


user function OFGTRA()
Local cNome := cUserName 
Local aRet := {}

PswOrder(2)
PswSeek(cNome  ,.T.)

return


Static Function TNWAjust(CPERG)
Local nCnt := 0

DBSELECTAREA("SX1")
DBSETORDER(1)
                    
If cPerg := "XKCIPA"	
	PutSx1(cPerg, "01", "Data Fim", "Data Fim", "Data Fim",             "mv_ch1", "D", 08, 0, 0, "G", "", "", "", "", "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
Else
	PutSx1(cPerg, "01", "Data Fim", "Data Fim", "Data Fim",             "mv_ch1", "D", 08, 0, 0, "G", "", "", "", "", "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
	PutSx1(cPerg, "02", "Mandato", "Mandato", "Mandato",             "mv_ch2", "C", TamSx3("TNW_CODIGO")[1], 0, 0, "G", "", "", "", "", "MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
EndIf

return





user function f30di ()
Local dData := dDataBase

dData += 30
alert (dtoc(dData))

return