#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CSSBOTAO	"QPushButton { color: #024670; "+;
	"    border-image: url(rpo:fwstd_btn_nml.png) 3 3 3 3 stretch; "+;
	"    border-top-width: 3px; "+;
	"    border-left-width: 3px; "+;
	"    border-right-width: 3px; "+;
	"    border-bottom-width: 3px }"+;
	"QPushButton:pressed {	color: #FFFFFF; "+;
	"    border-image: url(rpo:fwstd_btn_prd.png) 3 3 3 3 stretch; "+;
	"    border-top-width: 3px; "+;
	"    border-left-width: 3px; "+;
	"    border-right-width: 3px; "+;
	"    border-bottom-width: 3px }"

/*/{Protheus.doc} nomeFunction
	Alteracao parametro MV_ULMES

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


User Function ALLSX6B()
	Local aArea := GetArea()
	Local aAreaSM0 := SM0->(GetArea())
	Local oDlg
	Local lOk	:=	.F.
	Local cMsgAviso
	Local nBTN	:= 0

	Local lSelFils:=.F.
	Local lApagMov:=.F.

	Local jj

	Private cCadastro := "v1-Manutencao MV_ULMES "+ " FILIAL EMPRESA: "+SM0->M0_CODFIL
	Private dMvUlmes	:= GetMV("MV_ULMES")
	Private dNewDtF
	Private aMarcadas	:= {}

	Private dMvFNew

	Private cFulUlMes:= ALLTRIM(SX6->X6_FIL)

//supergetmv("MV_ULMES","2",'00101MG0002')

	//verifica se vazio, pois estava dando erro de conversao
	//se erro ja avisa e volta
	IF Empty(dMvUlmes)
		Alert("Parametro Vazio ou Nulo...Verificar com Suporte")
		Return
	ENDIF

	//calcula o mes alterior
	dNewDtF 	:=  FirstDay(dMvUlmes) - 1

	nLinF := 250
	nColF	:= 635
	Define MsDialog oDlg Title cCadastro From 000,000 To nLinF,nColF Pixel


	// hfp 20210927 - Compila inclusao dos grupos, para ficar mais legivel o leiaute da tela,
	//para a inclusao do item fechar estoque, uma vez que tudo foi preparado pelo ABRIR.
	// TGroup():New([nTop],[nLeft],[nBottom],[nRight],[cCaption],[oWnd],[nClrText],[nClrPane],[lPixel],[uParam10])
	//cria grupo 1 - usando new
	nTop1		:=	05
	nLeft1	:=	05
	nBot1		:=	120
	nRigh1	:=	185
	oGroup1:= TGroup():New(nTop1,nLeft1,nBot1,nRigh1,'Dados "abrir" Estoque',oDlg,,,.T.)

	nLinDtold:= 017
	nColDtOld:= 140
	@ nLinDtold,08 Say "Data Ultimo Encerramento para Empresa Atual Atual " Of oGroup1 Pixel
	@ nLinDtold-3,nColDtOld  MsGet dMvUlmes  WHEN .F. size 45,07 Of oGroup1 Pixel HasButton

	nLinDtNew:= 35
	nColDtNew:= nColDtOld
	@ nLinDtNew,08 Say "Nova Data a ser '*Aberta*' para a Empresa Atual "  Of oGroup1 Pixel
	@ nLinDtNew-3,nColDtNew MsGet dNewDtF /*Valid NaoVazio()*/ WHEN .F. size 45,07 Of oGroup1 Pixel HasButton


	nLin1:= nLinDtNew+18
	nCol11:= 08
	nCol12:= 55

	@ nLin1,nCol11 Say "Filial Parametro: "  Of oGroup1 Pixel
	IF Empty(SX6->X6_FIL)
		@ nLin1,nCol12 Say "*<vazio>*"  COLOR CLR_RED  Of oGroup1 Pixel
	ELSE
		@ nLin1,nCol12 Say SX6->X6_FIL  COLOR CLR_RED  Of oGroup1 Pixel
	ENDIF


	nLinchek1:= nLin1 + 18
	@ nLinchek1,08 CHECKBOX oCheck1 VAR lSelFils PROMPT "Seleciona Diversas Filiais Para Reabrir Estoque? " SIZE 200,10 ;
		ON CHANGE (LJMsgRun("Aguarde...","Aguarde...",{||  SelFilsH(SM0->M0_CODIGO, @aMarcadas, @lSelFils )})) ;
		OF oGroup1 PIXEL


	nLinchek2:= nLinchek1 + 18

	@ nLinchek2,08 CHECKBOX oCheck2 VAR lApagMov PROMPT "Apagar Movimentos do Fechamento (SB9, SBJ, SBK)" SIZE 200,10 OF oGroup1 PIXEL


	nBTL1:= nLinchek2 + 15
	nColB1:= nLeft1 + 08
	TButton():New(nBTL1, nColB1 ,">> Abrir <<", oGroup1,{|| lOk := .T., nBTN:=1, oDlg:End()} , 50 , 12 ,,,,.T.,,,,,,)

// ************************
	//cria grupo 2 - usando create
	nTop2		:=	05
	nLeft2	:=	nRigh1+5
	nBot2		:=	080
	nRigh2	:=	317
	oGroup2 := TGroup():Create(oDlg,nTop2,nLeft2,nBot2,nRigh2,'Dados "Fechar" Estoque',,,.T.)

	nLinDt21:= 017
	nLinDt22:= 035

	nColGr21:= nLeft2+3
	nColGr22:= nRigh2-50

	dMvFAtu:= dMvUlmes  //pega data ultimo fechamamento
	@ nLinDt21,nColGr21 Say "Data Atual Fechada: " Of oGroup2 Pixel
	@ nLinDt21,nColGr22  MsGet dMvFAtu  WHEN .F. size 45,07 Of oGroup2 Pixel HasButton

	//nLinDtNew:= 35
	//nColDtOld:= 140
	dMvFNew:=  LastDay(dMvUlmes+1) 
	@ nLinDt22,nColGr21 Say "Nova Data a ser '*Fechada*' "  Of oGroup2 Pixel
	@ nLinDt22,nColGr22 MsGet dMvFNew /*Valid NaoVazio()*/ WHEN .F. size 45,07 Of oGroup2 Pixel HasButton

	nBTL2:= nLinDt22 + 15
	nColB2:= nLeft2+08
	TButton():New(nBTL2, nColB2 ,">> Fechar <<", oGroup2,{|| lOk := .T., nBTN:=2, oDlg:End()} , 50 , 12 ,,,,.T.,,,,,,)


	nLin2:= nLinchek2 + 20
	//nCol21:= 190
	nCol22:= 250
	//TButton():New(nLin2, nCol21 ,"Confirmar", oDlg,{||If(lOk := .T.,oDlg:End(),'')} , 50 , 12 ,,,,.T.,,,,,,)
	TButton():New(nLin2, nCol22 ,"Sair"	 , oDlg,{|| oDlg:End()} , 50 , 12 ,,,,.T.,,,,,,)

	ACTIVATE MSDIALOG oDlg Center



	If lOk //.AND. dMvUlmes <> dNewDtF

		IF nBTN==2  //fechar
			
			FTEMSB9(dMvFNew)

		ELSE
			//verifica se tem registro a processar
			lMarcada := Len(aMarcadas) > 0
			IF !lMarcada

				lMarcada:=MsgNoYes( "Nenhuma Filial Marcada, Processa Somente a Atual ?", "Sem Selecao.." )
				IF lMarcada
					aMarcadas:= {{SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_CODIGO+SM0->M0_CODFIL, dMvUlmes}}
				ENDIF
			ENDIF


			lMarcada := Len(aMarcadas) > 0  //testa novamente pq acima pode ou nao pegar somente a atual
			IF lMarcada

				//se data diferente confirma se continua
				//IF MV_PAR01 <> MV_PAR02
				cCadastro:= "Cofirmacao Manutecao MV_ULMES"

				// retirado abaixo coforme solicitacao taks
				//cMsgAviso	:= "Total de Filiais Selecionadas: "+ StrZero(Len(aMarcadas),3)+CRLF+CRLF+CRLF

				cMsgAviso	:= "* Seleciona Filiais: "+IIF( lSelFils, "SIM", "NAO")+CRLF+CRLF
				cMsgAviso	+= "* Apaga Movimentos Estoque: "+IIF( lApagMov, "SIM", "NAO")+CRLF+CRLF+CRLF+CRLF

				cMsgAviso	+= "Deseja continuar e Alterar Valor???"

				nOpcAviso	:= AVISO(cCadastro, cMsgAviso,{"SIM", "NÃO"},3)


				IF nOpcAviso == 1


					For jj:=1 to Len(aMarcadas)

						// ---------------------------------------
						//	Realiza a TROCA DA FILIAL CORRENTE
						// -----------------------------------------
						_cCodEmp:= aMarcadas[jj,1]
						_cFilNew:= aMarcadas[jj,2]

						opensm0(_cCodEmp+_cFilNew)

						//igualo cfilant
						CFILANT := _cFilNew

						BEGIN TRANSACTION


							//refaz o calculo do mes anterior
							dAtual 	:= aMarcadas[jj,4]
							cAtual	:= dtos(dAtual)
							dNewDtF 	:=  FirstDay( dAtual ) - 1

							lok:=.F.
							lOk:=PutMV("MV_ULMES",dNewDtF)

							IF !lOk  //nao gravou
								Alert("Erro Alteracao Parametro...Filial: " + SM0->M0_CODFIL)
								DISARMTRANSACTION()
							ELSE

								//verifica se apaga movimento
								IF lApagMov

									//LIMPA SB9
									cFilSB9:= XFILIAL("SB9")

									cQuery := "UPDATE "+ RETSQLNAME("SB9")
									cQuery += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ , B9_XKULMES = '"+__CUSERID+"' "
									cQuery += " WHERE D_E_L_E_T_ = '' AND B9_FILIAL = '"+cFilSB9+"' "
									cQuery += " AND B9_DATA = '" + cAtual+ "' "

									If TcSqlExec(cQuery) <> 0  // sb9

										cMsgAviso	:= "*** ATENÇÃO ***"+CRLF+CRLF

										cMsgAviso	+= " Erro Exclusao Movimento " +CRLF
										cMsgAviso	+= " ===>    Filial EmPresa: "+cFilant+" e Filial SB9: "+cFilSB9 +CRLF+CRLF

										cMsgAviso	+= "TCSQLError() " + TCSQLError()+CRLF+CRLF+CRLF+CRLF

										//cMsgAviso	+= "Deseja continuar e Alterar Valor???"

										nOpcAviso	:= AVISO(cCadastro, cMsgAviso,{"Sair"},3)

									ELSE

										//LIMPA SBJ
										cFilSBJ:= XFILIAL("SBJ")
//colocar o campo BJ_XKULMES QDO OK
										cQuery := "UPDATE "+ RETSQLNAME("SBJ")
										cQuery += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_, BJ_XKULMES = '"+__CUSERID+"' "
										cQuery += " WHERE D_E_L_E_T_ = '' AND BJ_FILIAL = '"+cFilSBJ+"' "
										cQuery += " AND BJ_DATA = '" + cAtual+ "' "

										If TcSqlExec(cQuery) <> 0  //sbj

											cMsgAviso	:= "*** ATENÇÃO ***"+CRLF+CRLF

											cMsgAviso	+= " Erro Exclusao Movimento Lote " +CRLF
											cMsgAviso	+= " ===>    Filial EmPresa: "+cFilant+" e Filial SBJ: "+cFilSB9 +CRLF+CRLF

											cMsgAviso	+= "TCSQLError() " + TCSQLError()+CRLF+CRLF+CRLF+CRLF

											//cMsgAviso	+= "Deseja continuar e Alterar Valor???"

											nOpcAviso	:= AVISO(cCadastro, cMsgAviso,{"Sair"},3)

										ELSE

											//LIMPA SBK
											cFilSBK:= XFILIAL("SBK")

											cQuery := "UPDATE "+ RETSQLNAME("SBK")
											cQuery += " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_, BK_XKULMES = '"+__CUSERID+"' "
											cQuery += " WHERE D_E_L_E_T_ = '' AND BK_FILIAL = '"+cFilSBK+"' "
											cQuery += " AND BK_DATA = '" + cAtual+ "' "

											If TcSqlExec(cQuery) <> 0

												cMsgAviso	:= "*** ATENÇÃO ***"+CRLF+CRLF

												cMsgAviso	+= " Erro Exclusao Movimento sub Lote " +CRLF
												cMsgAviso	+= " ===>    Filial EmPresa: "+cFilant+" e Filial SBk: "+cFilSB9 +CRLF+CRLF

												cMsgAviso	+= "TCSQLError() " + TCSQLError()+CRLF+CRLF+CRLF+CRLF

												//cMsgAviso	+= "Deseja continuar e Alterar Valor???"

												nOpcAviso	:= AVISO(cCadastro, cMsgAviso,{"Sair"},3)



											ENDIF


										ENDIF

									ENDIF
								ENDIF

								RecLock("SZO",.T.)
								//GRAVA O LOG
								SZO->ZO_FILIAL		:= xFilial("SZO")
								SZO->ZO_COD			:= GetSx8Num("SZO", "ZO_COD")
								SZO->ZO_USUARIO	:= __CUSERID
								SZO->ZO_DATA		:= DATE()
								SZO->ZO_HORA		:= TIME()
								SZO->ZO_MOVEXCL	:= IIF(lApagMov,"S","N")
								//ZO->ZO_NOMBKB9	C
								//SZO->ZO_NOMBKBJ	C
								//SZO->ZO_NOMBKBK	C
								SZO->ZO_PARAM		:=	"MV_ULMES"
								SZO->ZO_VALANT		:= DTOC(dMvUlmes)
								SZO->ZO_VALNEW		:= DTOC(dNewDtF)

								SZO->(MsUnlock())

								ConfirmSX8()

							ENDIF

						END TRANSACTION

					Next

				Endif  // aviso

			ENDIF  //MARCADAS
		ENDIF  //NBTN
	ENDIF  //LOK

	restArea( aArea )
	restArea( aAreaSM0 )
return


/*

		aMarcadas := EscEmpresa()
	EndIf

	If !Empty( aMarcadas )
		If lAuto .OR. MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas, lAuto ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lAuto
				If lOk
					MsgStop( "Atualização Realizada.", "PARAM" )
				Else
					MsgStop( "Atualização não Realizada.", "PARAM" )
				EndIf
				dbCloseAll()
			Else
				If lOk
					Final( "Atualização Concluída." )
				Else
					Final( "Atualização não Realizada." )
				EndIf
			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "PARAM" )

		EndIf






		*/



/*/{Protheus.doc} nomeFunction
	FUncao Retorna Empresas Selecionadas - Adaptada por Hamilton - Compila
	@type  Function
	@author user
	@since 05/08/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function SelFilsH(cEmp,aSelecionadas, lSelFIL)

//---------------------------------------------
// Parâmetro  nTipo
// 1 - Monta com Todas Empresas/Filiais
// 2 - Monta só com Empresas
// 3 - Monta só com Filiais de uma Empresa
//
// Parâmetro  aMarcadas
// Vetor com Empresas/Filiais pré marcadas
//
// Parâmetro  cEmpSel
// Empresa que será usada para montar seleção
//---------------------------------------------
	Local   aRet      := {}
	Local   aSalvAmb  := GetArea()
	Local   aSalvSM0  := {}
	Local   aVetor    := {}
	//Local   cMascEmp  := "??"
	Local   cVar      := ""
	Local   lChk      := .F.
	Local   lTeveMarc := .F.
	Local   oNo       := LoadBitmap( GetResources(), "LBNO" )
	Local   oOk       := LoadBitmap( GetResources(), "LBOK" )
	Local   oDlg, oChkMar, oLbx
	Local    oButCanc
	Local jj
	Local   aMarcadas := {}


	IF lSelFIL  //selecionou prepara tudo

//dbSelectArea( "SM0" )
		aSalvSM0 := SM0->( GetArea() )

		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilan	:= cFilant

		dbSetOrder( 1 )
		dbGoTop()

		While !SM0->( EOF() )

			IF  SM0->M0_CODIGO == cEmp

				//If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0  //																1						2					3					4			   5
				aAdd(  aVetor, { .F. , SM0->M0_CODIGO, SM0->M0_CODFIL, Alltrim(SM0->M0_NOME), Alltrim(SM0->M0_FILIAL),'' } )
				//EndIf
			ENDIF
			dbSkip()
		Enddo

		// pega o mv_ulmes de cada filial para demonstrar
		For jj:=1 TO Len(aVetor)

			_cFilNew:= aVetor[jj,3]

			//IF _cCodEmp+_cCodFil <> _cCodEmp + _cFilNew

			xEmp:= aVetor[jj,2]
			xFil:= aVetor[jj,3]
			opensm0(_cCodEmp + aVetor[jj,3])

			CFILANT := SM0->M0_CODFIL

			naosei:= GetMV("MV_ULMES")
			nao2:= iif(valtype(naosei) =="D", naosei,CTOD(SPACE(8) ))
			aVetor[jj, Len( aVetor[jj] ) ] := nao2

		NEXT


		RestArea( aSalvSM0 )
		cFilant := _cFilan

		Define MSDialog  oDlg Title "" From 0, 0 To 285, 600 Pixel

		oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

		oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

		@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa","","","","" Size 278, 095 ;
			ColSizes 06,015,030,006, 035 ,020,010,020,035,020,050,060,025,060,035  Of oDlg Pixel
		oLbx:SetArray(  aVetor )
		oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
			aVetor[oLbx:nAt, 2], ;
			aVetor[oLbx:nAt, 3], ;
			aVetor[oLbx:nAt, 4], ;
			aVetor[oLbx:nAt, 5], ;
			aVetor[oLbx:nAt, 6]}}

		oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar,oLbx ), oChkMar:Refresh(), oLbx:Refresh()}
		oLbx:cToolTip   :=  oDlg:cTitle
		oLbx:lHScroll   := .F. // NoScroll

		@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos" Message "Marca / Desmarca"+ CRLF + "Todos" Size 40, 007 Pixel Of oDlg;
			on Click MarcaTodos( lChk, @aVetor, oLbx )

// Marca/Desmarca por mascara
		//@ 113, 51 Say   oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
		//@ 112, 80 MSGet oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
			//	Message "Máscara Empresa ( ?? )"  Of oDlg
		//oSay:cToolTip := oMascEmp:cToolTip

		/*@ 128, 10 Button oButInv    Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar,oLbx ) ) ;
			Message "Inverter Seleção" Of oDlg
		oButInv:SetCss( CSSBOTAO )
		*/
		//@ 128, 50 Button oButMarc   Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
			//	Message "Marcar usando" + CRLF + "máscara ( ?? )"    Of oDlg
		//oButMarc:SetCss( CSSBOTAO )

	/*	@ 128, 80 Button oButDMar   Prompt "&Desmarcar" Size 32, 12 Pixel Action ( VerTodos( aVetor, @lChk, oChkMar ,oLbx) ) ;
			Message "Desmarcar usando" + CRLF + "máscara ( ?? )" Of oDlg
		oButDMar:SetCss( CSSBOTAO )
*/

		@ 112, 157  Button oButOk   Prompt "Processar"  Size 32, 12 Pixel Action (  RetSelecao( @aRet, aVetor ), oDlg:End()  ) ;
			Message "Confirma a seleção e efetua" + CRLF + "o processamento" Of oDlg
		oButOk:SetCss( CSSBOTAO )


		@ 128, 157  Button oButCanc Prompt "Cancelar"   Size 32, 12 Pixel Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), lSelFIL:=.F., oDlg:End() ) ;
			Message "Cancela o processamento" + CRLF + "e abandona a aplicação" Of oDlg
		oButCanc:SetCss( CSSBOTAO )

		Activate MSDialog  oDlg Center

		RestArea( aSalvAmb )

	ELSE

		aSelecionadas:={}

	ENDIF

	aSelecionadas:= Aclone(aRet)



Return  aRet


// -----------------------


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaTodos
Função auxiliar para marcar/desmarcar todos os ítens do ListBox ativo

@param lMarca  Contéudo para marca .T./.F.
@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaTodos( lMarca, aVetor, oLbx )
	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := lMarca
	Next nI

	oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} InvSelecao
Função auxiliar para inverter a seleção do ListBox ativo

@param aVetor  Vetor do ListBox
@param oLbx    Objeto do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function InvSelecao( aVetor, oLbx )
	Local  nI := 0

	For nI := 1 To Len( aVetor )
		aVetor[nI][1] := !aVetor[nI][1]
	Next nI

	oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} RetSelecao
Função auxiliar que monta o retorno com as seleções

@param aRet    Array que terá o retorno das seleções (é alterado internamente)
@param aVetor  Vetor do ListBox

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function RetSelecao( aRet, aVetor )
	Local  nI    := 0

	aRet := {}
	For nI := 1 To Len( aVetor )
		If aVetor[nI][1]
			aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3],;
				aVetor[nI,Len(aVetor[nI])] } )
		EndIf
	Next nI

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} MarcaMas
Função para marcar/desmarcar usando máscaras

@param oLbx     Objeto do ListBox
@param aVetor   Vetor do ListBox
@param cMascEmp Campo com a máscara (???)
@param lMarDes  Marca a ser atribuída .T./.F.

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
	Local cPos1 := SubStr( cMascEmp, 1, 1 )
	Local cPos2 := SubStr( cMascEmp, 2, 1 )
	Local nPos  := oLbx:nAt
	Local nZ    := 0

	For nZ := 1 To Len( aVetor )
		If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
			If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
				aVetor[nZ][1] := lMarDes
			EndIf
		EndIf
	Next

	oLbx:nAt := nPos
	oLbx:Refresh()

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} VerTodos
Função auxiliar para verificar se estão todos marcados ou não

@param aVetor   Vetor do ListBox
@param lChk     Marca do CheckBox do marca todos (referncia)
@param oChkMar  Objeto de CheckBox do marca todos

@author Ernani Forastieri
@since  27/09/2004
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function VerTodos( aVetor, lChk, oChkMar, oXList)
	Local lTTrue := .T.
	Local nI     := 0

	//marca todos do mesmo prefixo filial
	nPosi:= oXList:nat
	//pega os 5 primeiros caracteres da filial
	cNFil:= Left(aVetor[nPosi,3],5)
	//pega o valor para alterar todos
	lNFil:= aVetor[nPosi,1]
	//repassa vetor, alterando para .T. todas as filiais iguais
	For nI := 1 To Len( aVetor )
		IF Left(aVetor[nI,3],5) == cNFil
			aVetor[nI][1]:= lNFil // .T.
		ENDIF
	Next nI

	For nI := 1 To Len( aVetor )
		lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
	Next nI

	lChk := IIf( lTTrue, .T., .F. )
	oChkMar:Refresh()

Return NIL


/*/{Protheus.doc} nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 30/09/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function FTEMSB9(dDtNew)
	Local aArea:= GetArea()
	Local cAliasSB9 	:= GetNextAlias()
	Local cDtNew		:= dtos(dDtNew)
	Local nTRegs		:= 0
	Local cFilSB9		:= xFilial("SB9")

	BeginSql Alias cAliasSB9

		// COLUMN E2_VENCORI AS DATE

		SELECT COUNT(1) TOTREGS
		FROM %Table:SB9% SB9
		WHERE
			SB9.%NotDel%
			AND SB9.B9_FILIAL = %Exp:cFilSB9% 
			AND SB9.B9_DATA = %Exp:cDtNew%
	
	EndSql

	IF (cAliasSB9)->(!Eof())
		nTRegs:= (cAliasSB9)->TOTREGS

		cMsgAviso	:= "*** ATENÇÃO ***"+CRLF+CRLF

		cMsgAviso	+= " Foram encontrados "+ Alltrim( Str( nTRegs) )  + " registros para:" +CRLF+CRLF
		cMsgAviso	+= " Empresa: "+cFilant+CRLF+CRLF
		cMsgAviso	+= " Filial SB9: "+cFilSB9 +CRLF+CRLF
		cMsgAviso	+= " Filial MV_ULMES: "+cFulUlMes +CRLF+CRLF+CRLF
		cMsgAviso	+= "Confirma Alteracao do Parametro para o valor: "+DTOC(dDtNew)+ " Valor???"

		nOpcAviso	:= AVISO(cCadastro, cMsgAviso,{"Sim","Cancelar"},3)

		IF nOpcAviso ==1

			lOk:=PutMV("MV_ULMES",dDtNew)

			IF !lOk  //nao gravou
				Alert("Erro Alteracao Parametro...Filial: " + SM0->M0_CODFIL+" Verificar...")
			ENDIF
		ENDIF
	
	ELSE

		Alert("Erro Alteracao Parametro...Filial: " + SM0->M0_CODFIL+CRLF+" Não Foram Encontrados Registros de Fechamento...")

	ENDIF

	(cAliasSB9)->(dbCloseArea())

	RestArea(aArea)

Return
