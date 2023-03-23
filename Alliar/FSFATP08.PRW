#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} FSFATP08
Job chama Gera NF Faturamento - Automatica (FSFATP03) 

@type function
@author Jonatas Oliveira
@since 29/08/2018
@version 1.0
@param  aParam {Empresa, Filial}
@return 
@see (links_or_references)
/*/
User Function FSFATP08()

	Local aTables		:= {"SM0", "SC5", "SC6", "SC9", "SD2", "SF2", "SF3", "SFT", "SF4", "SE1", "CD2", "SB1", "SB2", "SE4"}
	Local nE 			:= 0
	Local nF 			:= 0
	Local cArqLck   	:= GetPathSemaforo()+"FSFATP08.LCK"
	Local lContinua	:= .t.
	Local nHandle		:= 0
	
	ConOut("*********************************************************")
	ConOut("* FSFATP08 - " + DtoC(Date()) + " - " + Time() + " - Iniciando o processo. Aguarde!	               		  ")
	ConOut("*********************************************************")	

	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
	//쿎ontrole de execucao. Nao permite que o mesmo JOB seja inicializado mais�
	//쿭e uma vez                                                              �
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
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
		ConOut("* FSFATP08 - " + DtoC(Date()) + " - " + Time() + " - Gerando semaforo do processamento						  ")
		ConOut("*********************************************************")		

		// Seta o ambiente para a primeira empresa/filial
		// O fonte FSFATP08 vai executar para todas as empresas/filiais
		// que possuirem pedidos liberados SC9/SC6/SC5
		RpcSetEnv("01", "00101MG0001", NIL, NIL, "FAT", NIL, aTables, NIL, NIL, NIL, .T.)
		
		//Executa a Rotina de Faturamento Automatico
		U_FSFATP03(.T., "PJ")

		//U_FSFATP08()
		
		MSUnlockAll()
		
		ConOut("*********************************************************")
		ConOut("* FSFATP08 - " + DtoC(Date()) + " - " + Time() + " - Processo Finalizado!				               		  ")
		ConOut("*********************************************************")	

		RpcClearEnv()
		FClose(nHandle)
		FErase(cArqLck)
	Else
		ConOut("*********************************************************")
		ConOut("* FSFATP08 - " + DtoC(Date()) + " - " + Time() + " - Semaforo nao permitiu executar ")
		ConOut("*********************************************************")						
	EndIf

Return
