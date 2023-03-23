#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} FSFATP04
Job chama Gera NF Faturamento - Automatica (FSFATP03) 

@type function
@author Alex Teixeira de Souza
@since 15/01/2016
@version 1.0
@param  aParam {Empresa, Filial}
@return 
@see (links_or_references)
/*/
User Function FSFATP04()

	Local aTables		:= {"SM0", "SC5", "SC6", "SC9", "SD2", "SF2", "SF3", "SFT", "SF4", "SE1", "CD2", "SB1", "SB2", "SE4"}
	Local nE 			:= 0
	Local nF 			:= 0
	Local cArqLck   	:= GetPathSemaforo()+"FSFATP04.LCK"
	Local lContinua	:= .t.
	Local nHandle		:= 0
	
	ConOut("*********************************************************")
	ConOut("* FSFATP04 - " + DtoC(Date()) + " - " + Time() + " - Iniciando o processo. Aguarde!	               		  ")
	ConOut("*********************************************************")	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Controle de execucao. Nao permite que o mesmo JOB seja inicializado mais³
	//³de uma vez                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeDir(GetPathSemaforo())
	If File(cArqLck)
		If (nHandle := FOpen(cArqLck,16)) < 0
			lContinua := .F.
		EndIf
	Else
		If ( nHandle := FCreate(cArqLck)) < 0
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
			
		ConOut("*********************************************************")
		ConOut("* FSFATP04 - " + DtoC(Date()) + " - " + Time() + " - Gerando semaforo do processamento						  ")
		ConOut("*********************************************************")		

		// Seta o ambiente para a primeira empresa/filial
		// O fonte FSFATP04 vai executar para todas as empresas/filiais
		// que possuirem pedidos liberados SC9/SC6/SC5
		RpcSetEnv("01", "00101MG0001", NIL, NIL, "FAT", NIL, aTables, NIL, NIL, NIL, .T.)
		
		//Executa a Rotina de Faturamento Automatico
		U_FSFATP03(.T.)

		//U_FSFATP08()
		
		MSUnlockAll()
		
		ConOut("*********************************************************")
		ConOut("* FSFATP04 - " + DtoC(Date()) + " - " + Time() + " - Processo Finalizado!				               		  ")
		ConOut("*********************************************************")	

		RpcClearEnv()
		FClose(nHandle)
		FErase(cArqLck)
	Else
		ConOut("*********************************************************")
		ConOut("* FSFATP04 - " + DtoC(Date()) + " - " + Time() + " - Semaforo nao permitiu executar ")
		ConOut("*********************************************************")						
	EndIf

Return





/*/{Protheus.doc} FSFATP4T
Faturamento automático com MultiThread.
Somente será aberta Thread para filiais com mais de 30 pedidos para processamento
@author Augusto Ribeiro | www.compila.com.br
@since 22/09/2021 14/06/2021
@version 1.0
/*/
User Function FSFATP4T(aParam)
Local nZ
Local cQuery := ""
Local aFilThread	:= {}
Local nQtdeNF		:= 0
Local cFSemaf, nHSemaf
Local cFSemThr, nHSemThr
Local lTry := .t.
Local cEmpJob 	:= "01"
Local cFilJob	:= "00101MG0001"
Local aThOpen	:= {}

Default aParam	:= {"01","00101MG0001"}


FwLogMsg("INFO", /*cTransactionId*/, "FSFATP4T", "FSFATP4T_INICIO", "", "01", "Inicio da rotina", 0, 10, {})

IF empty(aParam)
	FwLogMsg("ERROR", /*cTransactionId*/, "FSFATP4T", "FSFATP4T", "", "01", "Parametros Inválidos. Empresa, filial nao informados", 0, 10, {})
	return
ELSE
	cEmpJob 	:= aParam[1]
	cFilJob		:= aParam[2]
ENDIF

/*----------------------------------------| Augusto Ribeiro - 22/09/2021 - 18:13
|	Abre semaforo de processamento para a rotina geral
--------------------------------------------------------------------------------*/
cFSemaf	:= "FSFATP4T"
nHSemaf	:= U_CPXSEMAF("A", cFSemaf)	
IF nHSemaf > 0	

	PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob




	cQuery += " SELECT 	SC5.C5_FILIAL, COUNT(*) AS QTDPED "+CRLF
	cQuery += " FROM  "+RetSqlName("SC5")+" SC5  "+CRLF
	cQuery += " INNER JOIN  "+RetSqlName("SA1")+" SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ''  "+CRLF
	cQuery += " AND SA1.A1_PESSOA = 'F'  "+CRLF
	cQuery += " WHERE SC5.D_E_L_E_T_ <> '*' AND SC5.C5_XIDPLE <> ''  "+CRLF
	cQuery += " AND NOT EXISTS ( SELECT 	C9_PEDIDO FROM "+RetSqlName("SC9")+" SC9 WHERE  "+CRLF
	cQuery += "                        	SC5.C5_FILIAL = SC9.C9_FILIAL AND  "+CRLF
	cQuery += "                          	SC5.C5_NUM = SC9.C9_PEDIDO AND  "+CRLF
	cQuery += "                          	SC9.C9_NFISCAL <> '' AND SC9.D_E_L_E_T_ <> '*' )  "+CRLF
	cQuery += " AND SC5.C5_BLQ = ' '  "+CRLF
	cQuery += " AND SC5.C5_XBLQ IN ('4','7') AND SC5.C5_EMISSAO >= '20170201'  "+CRLF
	cQuery += " GROUP BY SC5.C5_FILIAL "+CRLF
	cQuery += " ORDER BY 2 DESC "+CRLF


	If Select("TSQL") > 0
	TSQL->(DbCloseArea())
	EndIf

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)

	IF TSQL->(!EOF())

		/*----------------------------------------| Augusto Ribeiro - 24/09/2021 - 13:52
		|	Numero de Threads para processamento simultaneo
		--------------------------------------------------------------------------------*/
		nTotThread	:= GETMV("AL_THRFAT",.f.,4) 

		/*----------------------------------------| Augusto Ribeiro - 24/09/2021 - 12:06
		|	Alterada logica para abertura de uma Thread por filial, visto caso contrário
		| como exite filal que possui volume muito superior as demais, acaba ficando preso.
		| Importante abrir semaforo vinculado ao codigo da filial, pois caso se considerar 
		| somente uma sequencia de Threads, causara lock de registros pois na proxima execução
		| do job, abrira um novo processamento.
		--------------------------------------------------------------------------------*/
		WHILE TSQL->(!EOF())
			/*----------------------------------------| Augusto Ribeiro - 22/09/2021 - 18:32
			|	Abre semaforo para processamento das Threads
			--------------------------------------------------------------------------------*/
			cFSemThr	:= "FSFATP4T_"+ALLTRIM(TSQL->C5_FILIAL)
			nHSemThr	:= U_CPXSEMAF("A", cFSemThr)	
			IF nHSemThr > 0
				U_CPXSEMAF("F", cFSemThr, nHSemThr)


				//| Adiciona na contagem do Array para controle do numero de Threads abertas
				AADD(aThOpen,cFSemThr)


				//U_FSFATP4A(cEmpAnt, cFilAnt, {cFSemThr}, cFSemThr)
				STARTJOB("U_FSFATP4A",getenvserver(),.f., cEmpAnt, TSQL->C5_FILIAL, {TSQL->C5_FILIAL}, cFSemThr)					
				SLEEP(5000)
			ENDIF

			/*----------------------------------------| Augusto Ribeiro - 28/09/2021 - 12:16
			|	Controle para numero de abertura de Threads
			--------------------------------------------------------------------------------*/
			IF Len(aThOpen) >= nTotThread
				WHILE Len(aThOpen) >= nTotThread

					For nZ := 1 to len(aThOpen)

						/*----------------------------------------| Augusto Ribeiro - 22/09/2021 - 18:32
						|	Abre semaforo para processamento das Threads 
						--------------------------------------------------------------------------------*/
						cFSemThr	:= aThOpen[nZ]
						nHSemThr	:= U_CPXSEMAF("A", cFSemThr)	
						IF nHSemThr > 0
							U_CPXSEMAF("F", cFSemThr, nHSemThr)	

							adel(aThOpen,nZ)	
							aSize(aThOpen,len(aThOpen)-1)	
							EXIT
						ENDIF
					NEXT nZ
				
					IF LEN(aThOpen) >= nTotThread
						SLEEP(15000)
					ENDIF
				ENDDO 
			ENDIF 

				

			TSQL->(DBSKIP())
		ENDDO
	ENDIF

	

/*----------------------------------------| Augusto Ribeiro - 24/09/2021 - 12:30
|	Fecha semaforo
--------------------------------------------------------------------------------*/
U_CPXSEMAF("F", cFSemaf, nHSemaf)


RESET ENVIRONMENT

else 
	FwLogMsg("INFO", /*cTransactionId*/, "FSFATP4T", "FSFATP4T_SEMAFORO", "", "01", "Nao foi possivel abrir o semaforo "+cFSemaf, 0, 10, {})
endif

FwLogMsg("INFO", /*cTransactionId*/, "FSFATP4T", "FSFATP4T_FIM", "", "01", "Fim da rotina", 0, 10, {})


Return()





/*/{Protheus.doc} FSFATP4T
Faturamento automático com MultiThread.
Somente será aberta Thread para filiais com mais de 30 pedidos para processamento
@author Augusto Ribeiro | www.compila.com.br
@since 22/09/2021 14/06/2021
@version 1.0
/*/
User Function FSFATP4A(cEmpJob, cFilJob, aFilProc, cFsnome)
Local nHSNum

/*----------------------------------------| Augusto Ribeiro - 22/09/2021 - 18:32
|	Abre semaforo para processamento das Threads
--------------------------------------------------------------------------------*/
nHSNum	:= U_CPXSEMAF("A", cFsnome)	
IF nHSNum > 0

	PREPARE ENVIRONMENT EMPRESA cEmpJob FILIAL cFilJob

	FwLogMsg("INFO", /*cTransactionId*/, "FSFATP4A", "FSFATP4A_SEMAFORO", "", "01", "Thread Aberta "+cFsnome, 0, 10, {})	
	
	/*----------------------------------------| Augusto Ribeiro - 24/09/2021 - 12:47
	|	Chama rotina de processamento dos pedidos
	--------------------------------------------------------------------------------*/
	U_FSFATP03(.T., ,aFilProc)

	RESET ENVIRONMENT		

	//| Fecha semaforo
	U_CPXSEMAF("F", cFsnome, nHSNum)	
else
	FwLogMsg("INFO", /*cTransactionId*/, "FSFATP4A", "FSFATP4A_SEMAFORO", "", "01", "Nao foi possivel abrir o semaforo "+cFsnome, 0, 10, {})
ENDIF	


 

RETURN()
