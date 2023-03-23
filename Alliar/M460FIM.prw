#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} M460FIM
Ponto de Entrada executado após a gravação do documento de saída.
@type function
@author gustavo.barcelos
@since 05/02/2016
@version 1.0
/*/

User Function M460FIM()
	Local lRet := .T.
	Local lPrefOn	:= .F.// GetMv("AL_PREFON",.F.,.T.)
	Local aArea		:= GETAREA()
	Local aAreaSF2	:= SF2->(GETAREA())
	Local cDadoFila


	ConOut("### M460FIM INICIO "+TIME())

	
	DBSELECTAREA("SZK")
	SZK->(DBSETORDER(1)) //| 
	IF SZK->(DBSEEK(SM0->M0_CODIGO + SC5->C5_FILIAL)) .AND. SZK->ZK_PREFONL == "S"
		lPrefOn := .T.
	ENDIF 

	//Libera o Pedido para Manipulacao apos a emissao da NF
	If SC5->C5_XBLQ == "7"
		RecLock("SC5", .F.)
			SC5->C5_XBLQ := "4"
		MsUnlock()
	EndIf
	ConOut("U_ALRFAT04")
	lRet := U_ALRFAT04() 
	 
	// ConOut("U_FSFATP06")
	// If FindFunction("U_FSFATP06") .AND. SC5->(FieldPos("C5_XIDPLE")) > 0 .AND. AllTrim(SC5->C5_XIDPLE) <> ""
	// 	U_FSFATP06()
	// EndIf
	RESTAREA(aAreaSF2)
	cDadoFila	:= '{'
	cDadoFila	+= '"F2_FILIAL":"'+ALLTRIM(SF2->F2_FILIAL)+'",'
	cDadoFila	+= '"F2_DOC":"'+ALLTRIM(SF2->F2_DOC)+'",'
	cDadoFila	+= '"F2_SERIE":"'+ALLTRIM(SF2->F2_SERIE)+'",'
    cDadoFila	+= '"SC5RECNO":'+ALLTRIM( STR(SC5->(RECNO())) )+','
    cDadoFila	+= '"SA1RECNO": '+ALLTRIM( STR(SA1->(RECNO())) )
	cDadoFila	+= '}'
	U_CP12ADD("000034", "SF2", SF2->(RECNO()), cDadoFila)
	
	// CP12ADD(cCodConf, cAliReg, nRecReg,		cDados, cCodDep, cCodTip, cIdInt )

	
	ConOut("U_ALFINZ")
	If FindFunction("U_ALFINZ")//CUSTOMIZACAO A PEDIDO DE ANTONIO, para copiar ados da tabela cuztomizada dele SZ7 para a SE1 (pedidos integracao com DigitalMed)
		U_ALFINZ()
	EndIf
	
	ConOut("U_ALFINT")
	If FindFunction("U_ALFINT")//CUSTOMIZACAO A PEDIDO DE ANTONIO, CHAMADO AO FINAL DA GERACAO DE  NOTA DE SAIDA, TROCANDO O CONTEUDO DO CAMPO CONTA
		U_ALFINT()
	EndIf
	
	/*----------------------------------------
		28/08/2018 - Jonatas Oliveira - Compila
		Verifica se pedido possui IdFluig e
		Grava na Nota
	------------------------------------------*/
	DBSELECTAREA("SA1")
	SA1->(DBSETORDER(1))

	IF !EMPTY(SC5->C5_XIDFLG) 
		ConOut("C5_XIDFLG")
		SF2->(RecLock("SF2",.F.))
			SF2->F2_XIDFLG := SC5->C5_XIDFLG
			ConOut("C5_XIDPLE")
			SF2->F2_XIDPLE := SC5->C5_XIDPLE
			//#########REMOVER#########
			/*
			IF lPrefOn
				SF2->F2_NFELETR	:= "99999999"
				SF2->F2_HORNFE	:= TIME()
				SF2->F2_CODNFE  := "99999999"
			ENDIF
			*/ 
			//#########REMOVER#########				
		SF2->(MsUnLock())
		
		/*----------------------------------------
			28/08/2018 - Jonatas Oliveira - Compila
			Cria Fila de Processamento Atualização de Nota- Fluig
		------------------------------------------*/
		DBSELECTAREA("SZK")
		SZK->(DBSETORDER(1)) //| 
		
		IF SA1->(DBSEEK( XFILIAL("SA1") + SC5->( C5_CLIENTE + C5_LOJACLI ) )) .AND. SA1->A1_PESSOA == "J"
		
			IF SZK->(DBSEEK(SM0->M0_CODIGO + SC5->C5_FILIAL)) .AND. SZK->ZK_FATPJAU == "S" 
				IF lPrefOn
					
					ConOut("U_CP12ADD(000020)")
					//|Cria Fila de Processamento Atualização de Nota- Fluig|
		
					U_CP12ADD("000020", "SF2"		, SF2->(RECNO()), 		, 		 , "01",  SC5->C5_XIDFLG )
				ELSE
					U_CP12ADD("000023", "SF2"		, SF2->(RECNO()), 		, 		 , "01",  SC5->C5_XIDFLG )
				ENDIF
			ENDIF 		 
		ENDIF 		 
	ENDIF 
	
	//| Grava os recnos dos títulos originados por notas.
	//| Incluído em 20180804

	DBSELECTAREA("SE1")
	aAreaSE1	:= SE1->(GetArea())
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	SE1->(DbGotop())
	
	DBSELECTAREA("SZ7")
	SZ7->( DBSETORDER(1) )
	
	If SE1->(DBSEEK(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC))
	
		//| Verifica todas as parecalelas geradas.
		
		While SE1->(!EOF()) .AND. SE1->E1_FILIAL	== SF2->F2_FILIAL .AND. SE1->E1_PREFIXO == SF2->F2_SERIE .AND. SE1->E1_NUM == SF2->F2_DOC
			 
				//| Envia título para fila do integrador.
				
			 	//|U_CP12ADD("000016", "SE1", SE1->(RECNO()),, )
			 	
		 		SE1->(RecLock("SE1",.F.))
		 		
					SE1->E1_XSTCAS:= "0" //| Pendente de Integração com a Gesplan
					SE1->E1_XSTFIN:= "0" //| Pendente de Integração com a Gesplan
					SE1->E1_XSTACC:= "0" //| Pendente de Integração com a Gesplan
					
					
					/*----------------------------------------
						27/05/2019 - Jonatas Oliveira - Compila
						Atualiza Forma de pagamento de acordo
						com FORMAS PAGTO PEDIDO VENDA
					------------------------------------------*/
					IF EMPTY(SE1->E1_XFORMPG) 
						IF SZ7->( DBSEEK( SE1->E1_FILIAL + SE1->E1_PEDIDO ))
							IF !EMPTY(SZ7->Z7_FORMA)
								SE1->E1_XFORMPG	:= 	SZ7->Z7_FORMA
							ENDIF 
						ENDIF	
					ENDIF 
			
					//GRAVA O CNPJ DO PARCEIRO DE ACORDO COMO ESTÁ NO PEDIDO DE VENDA 
					IF !EMPTY(SC5->C5_XCGCPAR) 
						SE1->E1_XCGCPAR	:= 	SC5->C5_XCGCPAR
					ENDIF 

					//GRAVA UN VENDA CARTÃO ALIANÇA
					IF !EMPTY(SC5->C5_XUNVALC)
						SE1->E1_XUNVALC := SC5->C5_XUNVALC
					ENDIF 

					//GRAVA ID NO TÍTULO
					IF LEFT(ALLTRIM(SC5->C5_XIDPLE),1) $ "U|R|V"
						SE1->E1_XIDPLER := SC5->C5_XIDPLE
					ENDIF 

				SE1->(MsUnLock())
				

			SE1->(DbSkip())
			
		Enddo
	
	ENDIF
	
	
	RestArea(aAreaSE1)


	ConOut("### M460FIM FIM "+TIME())

Return lRet


