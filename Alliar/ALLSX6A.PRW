#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} nomeFunction
	Alteracao parametro MV_DATAFIN

	@type  Function
	@author Hamilton (HFP) - Compila
	@since 21/07/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/


User Function ALLSX6A()
	Local aArea := GetArea()
	Local dMvDtFin

	Local oDlg
	Local lOk	:=	.F.

	Private cCadastro := "Manutencao MV_DATAFIN "+ " FILIAL EMPRESA: "+SM0->M0_CODFIL
	Private dNewDtF

	dMvDtFin:= GetMV("MV_DATAFIN")
	dNewDtF:= dMvDtFin

	nLinF := 125
	nColF	:= 450
	Define MsDialog oDlg Title cCadastro From 000,000 To nLinF,nColF Pixel

	@ 12,03 Say "Data Atual " Of oDlg Pixel
	@ 09,33  MsGet dMvDtFin  WHEN .F. size 50,07 Of oDlg Pixel HasButton

	@ 12,93 Say "Nova Data "  Of oDlg Pixel
	@ 09,123 MsGet dNewDtF Valid NaoVazio() size 50,07 Of oDlg Pixel HasButton


	nLin1:= 30
	nCol11:= 55
	nCol12:= 100

	@ nLin1,nCol11 Say "Filial Parametro: "  Of oDlg Pixel

	IF Empty(SX6->X6_FIL)

		@ nLin1,nCol12 Say "*<vazio>*"  COLOR CLR_RED  Of oDlg Pixel

	ELSE

		@ nLin1,nCol12 Say SX6->X6_FIL  COLOR CLR_RED  Of oDlg Pixel

	ENDIF


	nLin2:= 48
	nCol21:= 085
	nCol22:= 140

	//TButton():New(30, 65 ,"Confirmar", oDlg,{||If(lOk := fValData(),oDlg:End(),'')} , 50 , 12 ,,,,.T.,,,,,,)
	TButton():New(nLin2, nCol21 ,"Confirmar", oDlg,{||If(lOk := .T.,oDlg:End(),'')} , 50 , 12 ,,,,.T.,,,,,,)
	TButton():New(nLin2, nCol22,"Sair"	 , oDlg,{|| oDlg:End()} , 50 , 12 ,,,,.T.,,,,,,)

	ACTIVATE MSDIALOG oDlg Center

	//se tiver alteração de alguma data altera a trb
	If lOk .AND. dMvDtFin <> dNewDtF

		//se data diferente confirma se continua
		//IF MV_PAR01 <> MV_PAR02
		cMsgAviso	:= "Valor Anterior: "+dtoc(dMvDtFin)+CRLF+CRLF
		cMsgAviso	+= "Novo Valor:"+dtoc(dNewDtF)+CRLF+CRLF
		cMsgAviso	+= "Deseja continuar e Alterar Valor???"

		nOpcAviso	:= AVISO(cCadastro, cMsgAviso,{"SIM", "NÃO"},2)

		IF nOpcAviso == 1

			BEGIN TRANSACTION

				lOk:=PutMV("MV_DATAFIN",dNewDtF)

				IF !lOk  //nao gravou
					Alert("Erro Alteracao Parametro...Dados nao Atualizados...")
					DISARMTRANSACTION()
				ELSE

					RecLock("SZO",.T.)
					//GRAVA O LOG
					SZO->ZO_FILIAL		:= xFilial("SZO")
					SZO->ZO_COD			:= GetSx8Num("SZO", "ZO_COD")
					SZO->ZO_USUARIO	:= __CUSERID
					SZO->ZO_DATA		:= DATE()
					SZO->ZO_HORA		:= TIME()
					SZO->ZO_MOVEXCL	:= "N"
					//ZO->ZO_NOMBKB9	C
					//SZO->ZO_NOMBKBJ	C
					//SZO->ZO_NOMBKBK	C
					SZO->ZO_PARAM		:=	"MV_DATAFIN"
					SZO->ZO_VALANT		:= DTOC(dMvDtFin)
					SZO->ZO_VALNEW		:= DTOC(dNewDtF)

					SZO->(MsUnlock())

					ConfirmSX8()

				ENDIF

			END TRANSACTION

			//ENDIF
		Endif

	ENDIF

	restArea( aArea )
return

