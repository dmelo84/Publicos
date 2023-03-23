#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} FSFATP03
Gera NF Faturamento - Automatica 

@type function
@author Alex Teixeira de Souza
@since 15/01/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function FSFATP03(lJob, cTpPess, aFilProc)

Local cAlias 		:= ""
Local aItemNF 	:= {}
Local aItemMt	:= {}
Local aPVlNFs		:= {}
Local aPVlMT	:= {}
Local lGerNF		:= .f.	
Local cNota		:= ""
Local cFilBkp		:= cFilAnt
Local lP03Auto	:= .F.			//SuperGetMV("ES_P03AUTO", NIL, .F.)
Local cNovaNF		:= ""
Local cSerieNF	:= ""
Local nRecSC9		:= 0
Local cFilLoop	:= ""
Local lContabOn


	Private __GeraNF	:= .f.

	Default lJob := .f.
	Default cTpPess := "PF"
	Default aFilProc	:= {}

	cAlias := GetNextAlias()

	If FSTABTMP(cAlias, cTpPess, aFilProc)
	
		dbSelectArea("SE4")
		SE4->( DbSetOrder(1) )	

		dbSelectArea("SB1")
		SB1->( DbSetOrder(1) )	

		dbSelectArea("SB2")
		SB2->( DbSetOrder(1) )	

		dbSelectArea("SF4")
		SF4->( DbSetOrder(1) )	

		dbSelectArea("SC6")
		SC6->( DbSetOrder(1) )
		
		dbSelectArea("SC9")
		SC9->( DbSetOrder(1) )

		dbSelectArea("SC5")
		SC5->( DbSetOrder(1) )	

		// Coloca todos os pedidos da selecao com status de em processamento
		If lJob		
			ConOut("*********************************************************")
			ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Alterando status da selecao para em processamento   *")
		Endif					

		cFilLoop	:= ""
		Do While (cAlias)->(!Eof())		
			
			/*------------------------------------------------------ Augusto Ribeiro | 18/04/2017 - 5:39:38 PM
				Verifica se a Filial esta com a emissão de NF automatica habilitada.
			------------------------------------------------------------------------------------------*/
			IF cFilLoop <> (cAlias)->C5_FILIAL
			
				cFilLoop	:= (cAlias)->C5_FILIAL
			
				/*---------------------------------------
					Realiza a TROCA DA FILIAL CORRENTE 
				-----------------------------------------*/
				_cCodEmp 	:= SM0->M0_CODIGO
				_cCodFil	:= SM0->M0_CODFIL
				_cFilNew	:= cFilLoop //| CODIGO DA FILIAL DE DESTINO 
				
				IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
					CFILANT := _cFilNew
					opensm0(_cCodEmp+CFILANT)
				ENDIF
			
			
				IF !(GetMV("ES_P03AUTO", NIL, .F.))					
					WHILE (cAlias)->(!EOF()) .AND. cFilLoop == (cAlias)->C5_FILIAL
						(cAlias)->(DBSKIP())
					ENDDO
					
					
					/*---------------------------------------
						Restaura FILIAL  
					-----------------------------------------*/
					IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
						CFILANT := _cCodFil
						opensm0(_cCodEmp+CFILANT)			 			
					ENDIF   						
									
					LOOP
				ENDIF		
			
				/*---------------------------------------
					Restaura FILIAL  
				-----------------------------------------*/
				IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
					CFILANT := _cCodFil
					opensm0(_cCodEmp+CFILANT)			 			
				ENDIF   			
			ENDIF
			
			
		
			If UpdXBLQ((cAlias)->SC5REC)
				SC5->(DBGoto((cAlias)->SC5REC))
				If lJob
					ConOut("* Alterado status do pedido "+ SC5->C5_NUM+ " para 7 ")
				Endif	
			Endif
			
			(cAlias)->(DBSkip())
		EndDo
		
		If lJob
			ConOut("*********************************************************")
		Endif			
		
		(cAlias)->( dbSelectArea( cAlias ) )
		(cAlias)->( dbGoTop() )		

		Do While (cAlias)->(!Eof())
		
			Set(_SET_DELETED, .T.)
		
			If lJob		
				ConOut("*********************************************************")
				ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Executando loop da selecao dos registros de pedidos   *")
				ConOut("*********************************************************")		
			Endif					
				
			DbSelectArea("SM0")
			DbSetOrder(1)
			
			If SM0->(DbSeek(cEmpAnt + (cAlias)->C5_FILIAL))
				cFilAnt	:= (cAlias)->C5_FILIAL

				//Valida se a Filial esta com o Faturamento Automatico habilitado
				If GetMV("ES_P03AUTO", NIL, .F.)
					lGerNF		:= .f.
					aPVlNFs	:= {}
					aPVlMT	:= {}
					aItemNF 	:= {}
					aItemMt	:= {}
					
								
					If lJob		
						ConOut("*********************************************************")
						ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Processando Filial: "+cFilAnt+" ")
						ConOut("*********************************************************")		
					Endif					
								
					SC5->(DBGoto( (cAlias)->SC5REC  ))	
					
						
					If  Alltrim(SC5->C5_XBLQ) == "7"
						If SC5->(Deleted())
							If lJob
								ConOut("*********************************************************")
								ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Pedido "+SC5->C5_NUM+" deletado! ")
								ConOut("*********************************************************")						
							Endif
							(cAlias)->(DBSkip())
							Loop
						Endif							 
													
						If lJob
							ConOut("*********************************************************")
							ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Lendo Pedido "+SC5->C5_NUM+"! ")
							ConOut("*********************************************************")						
						Endif

						// Liberando pedido
						If !FSLibPed( SC5->C5_NUM )
							ConOut("*********************************************************")
							ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Nao liberou o pedido "+SC5->C5_NUM+"! ")
							ConOut("*********************************************************")						
							(cAlias)->(DBSkip())
							Loop
						Endif
						
						//Limpa registros duplicados na SC9 caso existam
						nRecSC9 := 0
						dbSelectArea("SC9")
						dbSetOrder(1)
						MsSeek(xFilial("SC9") + SC5->C5_NUM)
						while ( SC9->(!Eof()) .AND. SC9->C9_PEDIDO == SC5->C5_NUM)
							If Empty(Alltrim(SC9->C9_BLEST)) .and. Empty(Alltrim(SC9->C9_BLCRED)) 
								If nRecSC9 == 0
									nRecSC9 := SC9->(Recno())
								Else
									RecLock("SC9",.F.)
									SC9->(DbDelete())
									SC9->(MsUnlock())
								Endif	
							Endif
							SC9->(dbSkip())
						Enddo			
																					
						lGerNF		:= .f.	
						aPVlNFs	:= {}	
						aPVlMT	:= {}								
						dbSelectArea("SC9")
						dbSetOrder(1)
						MsSeek(xFilial("SC9") + SC5->C5_NUM)
						
						While (SC9->(!Eof()) .AND. SC9->C9_PEDIDO == SC5->C5_NUM)						
							If Empty(Alltrim(SC9->C9_BLEST)) .and. Empty(Alltrim(SC9->C9_BLCRED)) 						
								SE4->(DBSeek(xFilial("SE4")+SC5->C5_CONDPAG))
								SC6->(DBSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM))
								SB1->(DBSeek(xFilial("SB1")+SC9->C9_PRODUTO))
								SB2->(DBSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL))
								SF4->(DBSeek(xFilial("SF4")+SC6->C6_TES))
								
								IF SC5->C5_XMOTOB != "3" .OR.  (SC5->C5_XMOTOB == "3" .AND. SC6->C6_PRCVEN <> GetMV("ES_VALMOT",.F., 12) .AND. ALLTRIM(SC9->C9_PRODUTO) == ALLTRIM(GetMV("ES_PRDMOT", .F., "23000004")))
									aItemNF 	:= {}
									aAdd( aItemNF , SC9->C9_PEDIDO )
									aAdd( aItemNF , SC9->C9_ITEM   )
									aAdd( aItemNF , SC9->C9_SEQUEN )
									aAdd( aItemNF , SC9->C9_QTDLIB )
									aAdd( aItemNF , SC9->C9_PRCVEN )
									aAdd( aItemNF , SC9->C9_PRODUTO)
									aAdd( aItemNF , SF4->F4_ISS=="S")
									aAdd( aItemNF , SC9->(RecNo()) )
									aAdd( aItemNF , SC5->(RecNo()) )
									aAdd( aItemNF , SC6->(RecNo()) )
									aAdd( aItemNF , SE4->(RecNo()) )
									aAdd( aItemNF , SB1->(RecNo()) )
									aAdd( aItemNF , SB2->(RecNo()) )
									aAdd( aItemNF , SF4->(RecNo()) )
									aAdd( aItemNF , SC9->C9_LOCAL  )
									aAdd( aItemNF , 1 )
									aAdd( aItemNF , SC9->C9_QTDLIB2 )
									aAdd( aItemNF , SF4->F4_DUPLIC=="S" )
									aAdd( aPVlNFs, aClone(aItemNF))		
									lGerNF		:= .t.	
								ELSE
									aItemMt 	:= {}
									aAdd( aItemMt , SC9->C9_PEDIDO )
									aAdd( aItemMt , SC9->C9_ITEM   )
									aAdd( aItemMt , SC9->C9_SEQUEN )
									aAdd( aItemMt , SC9->C9_QTDLIB )
									aAdd( aItemMt , SC9->C9_PRCVEN )
									aAdd( aItemMt , SC9->C9_PRODUTO)
									aAdd( aItemMt , SF4->F4_ISS=="S")
									aAdd( aItemMt , SC9->(RecNo()) )
									aAdd( aItemMt , SC5->(RecNo()) )
									aAdd( aItemMt , SC6->(RecNo()) )
									aAdd( aItemMt , SE4->(RecNo()) )
									aAdd( aItemMt , SB1->(RecNo()) )
									aAdd( aItemMt , SB2->(RecNo()) )
									aAdd( aItemMt , SF4->(RecNo()) )
									aAdd( aItemMt , SC9->C9_LOCAL  )
									aAdd( aItemMt , 1 )
									aAdd( aItemMt , SC9->C9_QTDLIB2 )
									aAdd( aItemMt , SF4->F4_DUPLIC=="S" )
									aAdd( aPVlMT, aClone(aItemMt))		
									lGerNF		:= .t.	
								ENDIF 								
							Endif
							SC9->(dbSkip())
						EndDo


						if lGerNF
							If lJob
								ConOut("*********************************************************")
								ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Inicio da geracao de NF para o pedido "+SC5->C5_NUM+"! ")
								ConOut("*********************************************************")
														
							Endif
	
							//Verifica a Numeracao das NFs para a Filial / Serie
							IF SC5->C5_XMOTOB == "1"//|Motoboy - Sim|								
								cSerieNF := GetNewPar("ES_SERMOT","MOT")
								
								DbSelectArea("SX5")
								SX5->(DbSetOrder(1))		//X5_FILIAL, X5_TABELA, X5_CHAVE
								
								If SX5->(!DbSeek(SC5->C5_FILIAL + "01" + cSerieNF))
									/*----------------------------------------
										10/12/2018 - Jonatas Oliveira - Compila
										Cria Serie Motoboy 
									------------------------------------------*/							
									RecLock("SX5", .T.)
										SX5->(FIELDPUT(FIELDPOS("X5_FILIAL"),SC5->(FIELDGET(FIELDPOS("C5_FILIAL"))))) 
										SX5->(FIELDPUT(FIELDPOS("X5_TABELA"),"01")) 
										SX5->(FIELDPUT(FIELDPOS("X5_CHAVE"),"MOT")) 
										
										SX5->(FIELDPUT(FIELDPOS("X5_DESCRI"),"000000001")) 
										SX5->(FIELDPUT(FIELDPOS("X5_DESCSPA"),"000000001"))  
										SX5->(FIELDPUT(FIELDPOS("X5_DESCENG"),"000000001"))  
										
									SX5->(MsUnlock())							
						
								EndIf
							ELSE
								cSerieNF := GetNewPar("ES_FATAUTS","001")
							ENDIF 

							//Aliança 2.0 Verificações nota de débito, caso sim atualiza a serie
							If !Empty(SC5->C5_XCGCPAR)
								cSerieNF := Alltrim(SuperGetMV("CP16_SERNFD",.F.,""))
							Endif
							
							If ChkNumNF(cSerieNF,@cNovaNF)
								
								ConOut("*********************************************************")
								ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Gerando NF "+cNovaNF+" Serie "+cSerieNF+"! ")							
								ConOut("*********************************************************")					
								__GeraNF := .T.
								
								// Pergunte("MT460A",.F.)
								
								lContabOn	:= GetMV("ES_CTBONAUT",.F.,.T.)
								
								cNota:= MaPvlNfs(aPVlNFs,;
													cSerieNF,;
													.F.	,;		//Mostra lançamentos contábeis. 1 = Sim, 2 = Não.
													.F.	,;		//	MV_PAR02==1,;	//Aglutina lançamentos. 1 = Sim, 2 = Não.
													lContabOn	,;		//	MV_PAR03==1,;	//Lanç. Contab. Online. 1 = Sim, 2 = Não. 
													.F.	,;		//	MV_PAR04==1,;	//Contab. Custo Online. 1 = Sim, 2 = Não.
													.F.	,;  	//	MV_PAR05==1,;	//Reaj. na mesma NF. 1 = Sim, 2 = Não.
													 0	,;		//	MV_PAR07,;		//Método calc.acr.fin.
													 0	,; 		//	MV_PAR08,;		//Arred.prc unit vist.
													.T.	,;		//	MV_PAR15==1,;	//Atualiza Cli.X Prod.
													.F.	,;		//	MV_PAR16==2,; //Emitir. 1 = Nota, 2 = Cupom Fiscal. 
													,,,,,dDatabase)
													
								__GeraNF := .f.
		
								If lJob
									If Empty(Alltrim(cNota))
										ConOut("*********************************************************")
										ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Erro na geracao da NF!")
										ConOut("*********************************************************")
									Else
										ConOut("*********************************************************")
										ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - NF " + cNota + " gerada!")
										ConOut("*********************************************************")
									Endif
								Endif
								
								If Len(aPVlMT) > 0 //|Item com Motoboy|
									cSerieNF := GetNewPar("ES_FATAUTS","001")
									
									If ChkNumNF(cSerieNF,@cNovaNF)
										
										ConOut("*********************************************************")
										ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Gerando NF "+cNovaNF+" Serie "+cSerieNF+"! ")							
										ConOut("*********************************************************")					
										__GeraNF := .T.
										
										// Pergunte("MT460A",.F.)
										
										lContabOn	:= GetMV("ES_CTBONAUT",.F.,.T.)
										
										cNota:= MaPvlNfs(aPVlMT,;
															cSerieNF,;
															.F.	,;		//Mostra lançamentos contábeis. 1 = Sim, 2 = Não.
															.F.	,;		//	MV_PAR02==1,;	//Aglutina lançamentos. 1 = Sim, 2 = Não.
															lContabOn	,;		//	MV_PAR03==1,;	//Lanç. Contab. Online. 1 = Sim, 2 = Não. 
															.F.	,;		//	MV_PAR04==1,;	//Contab. Custo Online. 1 = Sim, 2 = Não.
															.F.	,;  	//	MV_PAR05==1,;	//Reaj. na mesma NF. 1 = Sim, 2 = Não.
															 0	,;		//	MV_PAR07,;		//Método calc.acr.fin.
															 0	,; 		//	MV_PAR08,;		//Arred.prc unit vist.
															.T.	,;		//	MV_PAR15==1,;	//Atualiza Cli.X Prod.
															.F.	,;		//	MV_PAR16==2,; //Emitir. 1 = Nota, 2 = Cupom Fiscal. 
															,,,,,dDatabase)
															
										__GeraNF := .f.
				
										If lJob
											If Empty(Alltrim(cNota))
												ConOut("*********************************************************")
												ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Erro na geracao da NF!")
												ConOut("*********************************************************")
											Else
												ConOut("*********************************************************")
												ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - NF " + cNota + " gerada!")
												ConOut("*********************************************************")
											Endif
										Endif
									Endif
								Endif 
							Else
								ConOut("*********************************************************")
								ConOut("* FSFATP03 - " + DtoC(Date()) + " - " + Time() + " - Nao foi possivel gerar proximo numero de NF!")
								ConOut("*********************************************************")						
							Endif	
						Endif
					Endif	
				Endif
			EndIf	
			
			(cAlias)->(DBSkip())
				
		EndDo	
				
		(cAlias)->(DBCloseArea())

	Endif
	
	cFilAnt := cFilBkp

Return


/*/{Protheus.doc} FSTABTMP
Monta Tabela Temporaria

@author Alex T. Soiza
@since 15/01/2016
@version 1.0
@param cAlias - Nome da tabela temporaria
@return lOk
@example  
/*/
//-------------------------------------------------------------------
Static Function FSTABTMP(cAlias, cTipo, aFilProc)
Local cQuery 	:= ""
Local lOk		:= .f.

Default cTipo 		:= "PF" //|Pessoa Fisica|
Default aFilProc	:= {}

	If Select(cAlias)  > 0
		(cAlias)->(DBCloseArea())
	Endif	
	
	cQuery += " SELECT 	SC5.C5_FILIAL, SC5.C5_EMISSAO, SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, "
	cQuery += " 			SC5.R_E_C_N_O_ SC5REC FROM  "+RetSqlName("SC5")+" SC5 "
	
	/*----------------------------------------
		16/08/2018 - Jonatas Oliveira - Compila
		Tratativa para Pedidos PF e PJ
	------------------------------------------*/
	IF cTipo == "PF"
		cQuery += " INNER JOIN  "+RetSqlName("SA1")+" SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' AND SA1.A1_PESSOA = 'F' "
	ELSEIF cTipo == "PJ"
		cQuery += " INNER JOIN  "+RetSqlName("SA1")+" SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = '' AND SA1.A1_PESSOA = 'J' "
		
		//| Busca no SIGAMAT Customizado quais filiais irão integrar faturamento Automatico|
		cQuery += " INNER JOIN "+ RETSQLNAME("SZK") +" SZK "
		cQuery += " 	ON SC5.C5_FILIAL = ZK_CODFIL "
		cQuery += " 	AND ZK_FATPJAU = 'S' "
		cQuery += " 	AND (C5_XIDFLG <> '' OR (C5_XIDPLE LIKE 'V%' OR C5_XIDPLE LIKE 'R%' OR C5_XIDPLE LIKE 'U%') ) "
		
		cQuery += " 	AND SZK.D_E_L_E_T_='' "
	ENDIF 	
	
	cQuery += " WHERE SC5.D_E_L_E_T_ <> '*' AND SC5.C5_XIDPLE <> '' "

	IF !EMPTY(aFilProc)
		cQuery += "  AND SC5.C5_FILIAL IN  "+U_cpxINQRY(aFilProc)
	ENDIF

	cQuery += " AND NOT EXISTS ( SELECT 	C9_PEDIDO FROM "+RetSqlName("SC9")+" SC9 WHERE " 
   	cQuery += "                        	SC5.C5_FILIAL = SC9.C9_FILIAL AND "
   	cQuery += "                          	SC5.C5_NUM = SC9.C9_PEDIDO AND "
   	cQuery += "                          	SC9.C9_NFISCAL <> '' AND SC9.D_E_L_E_T_ <> '*' ) "
	cQuery += " AND SC5.C5_BLQ = '"+Space(TamSx3("C5_BLQ")[1])+"' "
	cQuery += " AND SC5.C5_XBLQ IN ('4','7') AND SC5.C5_EMISSAO >= '20170201' " // VALIDO SOMENTE PARA PEDIDOS EMITIDOS APARTIR DE 01/02/2017
	cQuery += " ORDER BY SC5.C5_FILIAL, SC5.C5_EMISSAO, SC5.C5_NUM " 

	//cQuery := ChangeQuery(cQuery)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.T.,.T.)
	
	If !(cAlias)->(Eof())
		lOk := .t.
	Endif
	
Return lOk
//-------------------------------------------------------------------
/*{Protheus.doc} ChkNumNF
Verifica e Corrige a Numeracao das NFs da Filial

@author Guilherme Santos
@since 18/10/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ChkNumNF(cSerie,cNovaNF)
	Local aArea		:= GetArea()
	Local cQuery		:= ""
	Local cNumNF		:= ""
	Local cTabQry		:= GetNextAlias()
	Local lRetorno	:= .T.
	
	cQuery += "SELECT		MAX(SF2.F2_DOC) F2_DOC" + CRLF
	cQuery += "FROM		" + RetSqlName("SF2") + " SF2" + CRLF
	cQuery += "WHERE		SF2.F2_FILIAL = '" + xFilial("SF2") + "'" + CRLF
	cQuery += "AND		SF2.F2_SERIE = '" + cSerie + "'" + CRLF
	cQuery += "AND 		SF2.D_E_L_E_T_ <> '*'" + CRLF

	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		
	If !(cTabQry)->(Eof())
		cNumNF := Soma1((cTabQry)->F2_DOC)

		DbSelectArea("SX5")
		DbSetOrder(1)		//X5_FILIAL, X5_TABELA, X5_CHAVE
		
		If SX5->(DbSeek(xFilial("SX5") + "01" + cSerie))
			//Corrige a Numeracao da Filial
			If AllTrim(SX5->(FIELDGET(FIELDPOS("X5_DESCRI")))) <> AllTrim(cNumNF)
				RecLock("SX5", .F.)
				SX5->(FIELDPUT(FIELDPOS("X5_DESCRI"),cNumNF)) 
				SX5->(FIELDPUT(FIELDPOS("X5_DESCSPA"),cNumNF)) 
				SX5->(FIELDPUT(FIELDPOS("X5_DESCENG"),cNumNF))  
				SX5->(MsUnlock())
				cNovaNF := cNumNF
			EndIf
		EndIf
	EndIf
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf
	
	RestArea(aArea)
Return lRetorno



//-------------------------------------------------------------------
/*{Protheus.doc} UpdXBLQ


@author Guilherme Santos
@since 18/10/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function UpdXBLQ(nSC5Rec)
Local lRet 		:= .t.
Local cUpdate		:= ""

	//Exclusao dos movimentos de simulacao
	//Via Update pois as filiais dos movimentos dependem da filial do Bem a ser depreciado
	cUpdate := " UPDATE "+ RetSQLName("SC5") 
	cUpdate += " SET C5_XBLQ = '7' "
	cUpdate += " WHERE R_E_C_N_O_ = " +  Alltrim(Str( nSC5Rec ))
	
	If TCSqlExec(cUpdate) < 0
		Conout(TcSqlError())
		lRet := .F.
	Else
		TcSqlExec( "COMMIT" )
	Endif	

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} UpdXBLQ


@author Guilherme Santos
@since 18/10/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function FSLibPed( cNumPed )
Local aAreaAnt	:= GetArea()
Local cSeek		:= ''
Local lRet		:= .f.

SC6->( DbSetOrder( 1 ) )
If	SC6->( MsSeek( cSeek := xFilial('SC6') + cNumPed, .F. ) )
	While SC6->( ! Eof() .And. SC6->C6_FILIAL + SC6->C6_NUM == cSeek )

		If MaLibDoFat( SC6->( RecNo() ),SC6->C6_QTDVEN , , , .F., .F., .F., .F. ) > 0		
			SC6->(MaLiberOk({SC5->C5_NUM},.F.))
			lRet := .t.
		Endif	

		SC6->( DbSkip() )
	EndDo
EndIf

RestArea( aAreaAnt )

Return lRet
