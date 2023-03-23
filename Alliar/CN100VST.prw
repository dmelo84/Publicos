#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} CN100VST
LOCALIZAÇÃO   :  Function CN100SitCh - Função executada na alteração da situação do contrato.
EM QUE PONTO :  Executado antes do processamento da alteração.
@author Jonatas Oliveira | www.compila.com.br
@since 02/05/2019
@version 1.0
/*/
User Function CN100VST()
	Local aParam1	:= {}
	Local bOkParam	:=  {|| U_CN100Mot()}
	Local aParamBox	:= {}
	Local aRet		:= {}
	Local cMemMot	:= ""

	Local cNovSit  	:= PARAMIXB[1]

	Private lRet := .T.
	
	IF cNovSit == "08" //|FINALIZADA|
	
		aAdd(aParamBox,{11,"Informe o motivo",cMemMot,"U_CN100Mot()",".T.",.T.})

		If ParamBox(aParamBox,"Teste Parâmetros...",@aRet,bOkParam/*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosX*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, /*lCanSave*/ .F.,/*lUserSave*/ )
			lRet	:= .T.
		ELSE
			lRet	:= .F.
			Help(" ",1,"VALIDMOT",,"Obrigatorio o preenchimento do motivo.",4,5)
		Endif 

		IF lRet
			cMemMot := "Alteração na Data - " + DTOC(DDATABASE) + " - " + TIME() + " - por " + alltrim(USRRETNAME(__CUSERID)) + CRLF
			cMemMot += "Motivo Informado: " + CRLF 
			cMemMot += aRet[1]
			
//			AVISO("CN100VST",cMemMot,{"Fechar"}, 3, ,, , .T.,  )
			
			CN9->(RecLock("CN9",.F.))
				CN9->CN9_MOTFIM		:= cMemMot
			CN9->(MsUnLock())
			
			/*
			DBSELECTAREA("Z16")
			Z16->(DBSETORDER(1))

			nTotCpo	:= Z16->(FCount())

			RegToMemory("Z16",.T.)

			M->Z16_FILIAL	:= CN9->CN9_FILIAL
			M->Z16_NUMERO	:= CN9->CN9_NUMERO
			M->Z16_REVISA	:= CN9->CN9_REVISA
			M->Z16_SITANT	:= CN9->CN9_SITUAC
			M->Z16_SITATU	:= cNovSit
			M->Z16_MOTIVO	:= cMemMot   		

			RECLOCK("Z16",.T.)

			For nI := 1 To nTotCpo
				FieldPut(nI, M->&(FIELDNAME(nI)) )
			Next nI

			MSUNLOCK()
			CONFIRMSX8()
			*/
		ENDIF 
	ENDIF 

Return(lRet)


User Function CN100Mot()

	//	IF EMPTY(MV_PAR01)
	//		Help(" ",1,"VALIDMOT",,"Obrigatorio o preenchimento do motivo.",4,5)
	//		lRet := .F.
	//	ENDIF 

Return(lRet)