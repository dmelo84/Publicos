#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'


/*/{Protheus.doc} WSR_OCORSAC
Chamada REST para atualizar ocorrencia de SAC
@author Jonatas Oliveira | www.compila.com.br
@since 22/03/2019
@version 1.0
/*/
User Function WSR_OCORSAC()
Return


WSRESTFUL OCORSAC DESCRIPTION "Serviço REST para atualização de ocorrencia SAC"

WSDATA CODTMK		AS STRING
WSDATA COMPLEMENTO	AS STRING
WSDATA CONTATO		AS STRING
WSDATA EMPRESA		AS STRING
WSDATA FILIAL		AS STRING
WSDATA IDFLUIG		AS STRING
WSDATA OBSERVACAO	AS STRING
WSDATA RESPONSAVEL	AS STRING
WSDATA USUARIO		AS STRING		

WSMETHOD POST DESCRIPTION "Atualiza Ocorrencia" WSSYNTAX "/OCORSAC || /OCORSAC/{}"

END WSRESTFUL


WSMETHOD POST WSRECEIVE CODTMK,COMPLEMENTO,CONTATO,EMPRESA,FILIAL,IDFLUIG,OBSERVACAO,RESPONSAVEL,USUARIO WSSERVICE OCORSAC
	Local oObjProd 	:= Nil
	Local cStatus  	:= ""
	LOcal cBody		:= ""
	Local cJRetOK   := '{"code":200,"status":"success"}'
	Local oJson	
	Local lRet		:= .F.

	Local aCabec	:= {}
	Local aItens	:= {}   
	Local ChaveEnv	:= ""
	Local aAux		:= {}
	Local aAuxRet	:= {}
	Local aAuxNew	:= {}
	Local nCampo	:= 0
	Local nCampo1	:= 0
	Local nPosItem	:= 0 
	Local lRetorno  := .T.	
	Local cCodUserx	:= ""
	Local cDscUserx := ""
	Local cSubItem  := ""
	Local xcItem  	:= ""
	Local xcSubItem := ""

	Private lMsErroAuto:= .F.	

	::SetContentType("application/json")

	cBody := ::GetContent()
	IF !EMPTY(cBody)
		IF FWJsonDeserialize(cBody,@oJson)

			If VldEmpFil(oJson:EMPRESA, oJson:FILIAL)
				PswOrder(4)
				If PswSeek(AllTrim(oJson:USUARIO)  ,.T.)
					aInfUsr 	:= PswRet(1)
					cCodUserx 	:= aInfUsr[1][1]
				Endif

				ChaveEnv	:= oJson:CODTMK
				xchavenv	:=	ChaveEnv
				xidfluig	:= oJson:IDFLUIG
				DbSelectArea("SUC")
				DbSetOrder(1)		//UC_FILIAL, UC_CODIGO 

				If DbSeek(xFilial("SUC") + Left(oJson:CODTMK,6))
					/*
					-----------------------------------------------------------------------------------------------------
					Localiza o Item que gerou a Tarefa do Ponto Focal
					-----------------------------------------------------------------------------------------------------	
					*/
					DbSelectArea("SUD")
					DbOrderNickName("UDXIDFLUI")		//UD_FILIAL, UD_XIDFLG

					If DbSeek(xFilial("SUD") + oJson:IDFLUIG)
						If SUC->UC_CODIGO == SUD->UD_CODIGO
							/*
							-----------------------------------------------------------------------------------------------------
							Campos do Itens do Atendimento
							-----------------------------------------------------------------------------------------------------	
							*/
							For nCampo := 1 to SUD->(FCount())								
								Aadd(aAuxNew, {FieldName(nCampo), SUD->(&(FieldName(nCampo))), NIL})
							Next nCampo

							if SUD->UD_ITEM == Substr(ChaveEnv,7,2) 
								xcItem := SUD->UD_ITEM
								xcSubItem := SUD->UD_SUBITEM
							else
								cMsgErro := "O Atendimento informado nao confere com o Atendimento do ID Fluig."
								lRetorno := .F.
							endif

						Else
							cMsgErro := "O Atendimento informado nao confere com o Atendimento do ID Fluig."
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
												aAux[nCampo1][2]	:="N"
											EndIf	

										Endif

									Next nCampo1

									Aadd(aItens, aAux)

									If Substr(SUD->UD_SUBITEM,1,2) == Substr(ChaveEnv,7,2)
										xcSubItem := if(SUD->UD_SUBITEM > xcSubItem, SUD->UD_SUBITEM, xcSubItem)
									endif

									SUD->(DbSkip())
								End

								/*
								-----------------------------------------------------------------------------------------------------
								Inclui uma Linha Nova para o Item que Recebeu a Resposta do Ponto Focal
								-----------------------------------------------------------------------------------------------------	
								*/ 
								nPosCpo	:= AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_ITEM"})
								aAuxNew[nPosCpo][2] :=	Strzero(Val(cItem)+1,2)

								nPosCpo :=	AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_SUBITEM"})								
								cSubItem :=	aAuxNew[nPosCpo][2] //05092017

								aAuxNew[nPosCpo][2] :=	Strzero(Val(xcSubItem)+1,4)

								// Acertos de campos novo registro
								nPosCpo :=	AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_OPERADO"}) // Responsável

								aAuxNew[nPosCpo][2] :=	cCodUserx
								//oJson:RESPONSAVEL

								nPosCpo :=	AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_DATA"}) // Data Ação
								aAuxNew[nPosCpo][2] :=	ddatabase

								nPosCpo :=	AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_DTEXEC"}) // Data Execução verificar
								aAuxNew[nPosCpo][2] :=	ddatabase  //+10

								nPosCpo :=	AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_OBS"}) // Observação Verificar
								aAuxNew[nPosCpo][2] :=	oJson:OBSERVACAO   

								Aadd(aAuxNew, {"UD_OBSEXEC", oJson:COMPLEMENTO, NIL}) 

								nPosCpo :=	AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_STATUS"}) // Status Pendente
								aAuxNew[nPosCpo][2] :=	"1"

								nPosCpo :=	AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_SOLUCAO"}) // Ação
								aAuxNew[nPosCpo][2] :=	GETMV("AL_ACAORET")

								nPosCpo :=	AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_XCONTAT"}) // ENTROU EM CONTATO COM O PACIENTE 
								aAuxNew[nPosCpo][2] :=	oJson:CONTATO

								nPosCpo :=	AScan(aAuxNew, {|x| AllTrim(x[1]) == "UD_DESCOPE"}) // Nome do Operador
								aAuxNew[nPosCpo][2] :=	oJson:RESPONSAVEL


								Aadd(aItens, aAuxNew)                                                                
								/*   
								-----------------------------------------------------------------------------------------------------
								Roda o ExecAuto
								-----------------------------------------------------------------------------------------------------	
								*/

								TMKA271(aCabec, aItens, 4, "1")  
								cLock := "SUC" + xFilial("SUC") + SUC->UC_CODIGO 

								UnLockByName(cLock,.T.)
								SUD->(DBCloseArea())
								SUC->(DBCloseArea())  

								If lMsErroAuto
									cMsgErro := MostraErro("\logs\", "TMKA271.log") + CRLF
									lRetorno := .F. 
								Else
									::SetResponse(cJRetOK)
									lRetorno	:= .T.
								EndIf
							Else
								cMsgErro := "Erro ao Buscar Itens do Atendimento."
								lRetorno := .F.
							EndIf
						EndIf
					Else
						cMsgErro := "ID Fluig nao localizado."
						lRetorno := .F.
					EndIf
				Else
					cMsgErro := "Atendimento nao localizado."
					lRetorno := .F.
				EndIf
			Else
				cMsgErro := "Empresa ou Filial invalida."
				lRetorno := .F.
			EndIf
		ELSE
			SetRestFault(402, "Invalid Json")
		ENDIF
	ELSE
		SetRestFault(401, "Body Vazio")
	ENDIF
	
	IF !lRetorno 
		SetRestFault(400, cMsgErro)
	ENDIF 

Return(lRetorno)



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