#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} FINALEG
O ponto de entrada FINALEG é utilizado para customizar 
as legendas de Mbrowse do módulo Financeiro.
O resultado deste ponto de entrada substitui as legendas 
padrões do sistema.
@author Jonatas Oliveira | www.compila.com.br
@since 20/11/2019
@version 1.0
/*/
User Function FINALEG()
	Local nReg     := PARAMIXB[1]
	Local cAlias   := PARAMIXB[2]
	Local nI		:= 1
	
	Local lPrjCni		:= ValidaCNI()
	Local lFaLegPares	:= ExistBlock("FaLegPARes") .And. ExecBlock("FaLegPARes",.f.,.f.)
	Local lF040URET		:= ExistBlock("F040URET")
	
	Local uRetorno := {}
	Local aLegenda := {	{"BR_VERDE"    , "Titulo em aberto"       },;	// "Titulo em aberto"					
						{"BR_AZUL"     , "Baixado parcialmente"   },;	// "Baixado parcialmente"					
						{"BR_VERMELHO" , "Titulo baixado"         },;	// "Titulo Baixado"					
						{"BR_PRETO"    , "Titulo em bordero"      },;	// "Titulo em Bordero"					
						{"BR_BRANCO"   , "Adiantamento com saldo" },;	// "Adiantamento com saldo"
						{"BR_CINZA"	   , "Titulo baixado parcialmente e em bordero" },; //6. "Titulo baixado parcialmente e em bordero"
						{"BR_PINK"     , "Adiantamento de Imp. Bx. com saldo"} } 	//7. "Adiantamento de Imp. Bx. com saldo"
					
	If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
		uRetorno := {}
		If cAlias == "SE2"
			If lPrjCni
				IF !Empty(SuperGetMv("MV_APRPAG",.F.,"")) .or. SuperGetMv("MV_CTLIPAG",.F.,.F.)
					Aadd(aLegenda, {"BR_AMARELO", "Titulo aguardando liberacao"})  //"Titulo aguardando liberacao"
					Aadd(uRetorno, { ' EMPTY(E2_DATALIB) .AND. (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > GetMV("MV_VLMINPG") .AND. E2_SALDO > 0', aLegenda[Len(aLegenda)][1] } )
				EndIf
			Else
				IF SuperGetMv("MV_CTLIPAG",.F.,.F.)
					Aadd(aLegenda, {"BR_AMARELO", "Titulo aguardando liberacao"})	//"Titulo aguardando liberacao"
					Aadd(uRetorno, { ' !( SE2->E2_TIPO $ MVPAGANT ).and. EMPTY(E2_DATALIB) .AND. (SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE) > SuperGetMV("MV_VLMINPG",.F.,0) .AND. E2_SALDO > 0', aLegenda[Len(aLegenda)][1] } )
				EndIf
			EndIf

			Aadd(aLegenda, {"BR_LARANJA", "Adiantamento de Viagem sem taxa"}) //"Adiantamento de Viagem sem taxa"
			Aadd(uRetorno, { ' (ALLTRIM(SE2->E2_ORIGEM) $ "FINA667|FINA677") .and. SE2->E2_MOEDA > 1 .AND. SE2->E2_TXMOEDA == 0 .AND. SE2->E2_SALDO > 0', aLegenda[Len(aLegenda)][1] } )

			IF lFaLegPares
				Aadd(aLegenda,{"BR_MARROM","Titulo PA com resíduos de saldo"})
				Aadd(uRetorno, { 'E2_TIPO == "'+MVPAGANT+'" .and. ROUND(E2_SALDO,2) > 0 .And. (ROUND(E2_SALDO,2) < ROUND(E2_VALOR,2))', aLegenda[Len(aLegenda)][1] } )
			Endif

			//Validação para uso do documento hábil - SIAFI
			If FinUsaDH()
				Aadd(aLegenda,{"BR_VIOLETA","Titulo Vinculado a Docto Hábil"}) // "Titulo Vinculado a Docto Hábil"
				Aadd(uRetorno, { 'ROUND(E2_SALDO,2) > 0 .And. !EMPTY(E2_DOCHAB)'	, aLegenda[Len(aLegenda)][1]				} ) //"Titulo relacionado ao Documento hábil"
			Endif

			Aadd(uRetorno, { 'E2_TIPO $ "INA/'+MVTXA+'" .and. ROUND(E2_SALDO,2) > 0 .And. E2_OK == "TA"  ', aLegenda[7][1] } )
			Aadd(uRetorno, { 'E2_TIPO == "'+MVPAGANT+'" .and. ROUND(E2_SALDO,2) > 0', aLegenda[5][1] } )
			Aadd(uRetorno, { 'ROUND(E2_SALDO,2) + ROUND(E2_SDACRES,2)  = 0', aLegenda[3][1] } )
			Aadd(uRetorno, { '!Empty(E2_NUMBOR) .and.(ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2))', aLegenda[6][1] } )
			Aadd(uRetorno, { '!Empty(E2_NUMBOR)', aLegenda[4][1] } )
			Aadd(uRetorno, { 'ROUND(E2_SALDO,2)+ ROUND(E2_SDACRES,2) # ROUND(E2_VALOR,2)+ ROUND(E2_ACRESC,2)', aLegenda[2][1] } )

			If !lF040URET
				Aadd(uRetorno, { '.T.', aLegenda[1][1] } )
			Endif
			
		ElseIf cAlias == "SE1"
			Aadd(aLegenda, {"BR_VERDE_ESCURO", "Titulo Protestado"})  //"Titulo Protestado"
			Aadd(uRetorno, { 'ROUND(E1_SALDO,2) = 0'													, aLegenda[3][1]				} ) //"Titulo Baixado"
			Aadd(uRetorno, { '!Empty(E1_NUMBOR) .and.(ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2))'			, aLegenda[6][1]				} ) //"Titulo baixado parcialmente e em bordero"
			Aadd(uRetorno, { 'E1_TIPO == "'+MVRECANT+'".and. ROUND(E1_SALDO,2) > 0 .And. !FXAtuTitCo()'	, aLegenda[5][1]				} ) //"Adiantamento com saldo"
			Aadd(uRetorno, { '!Empty(E1_NUMBOR)'														, aLegenda[4][1]				} ) //"Titulo em Bordero"
			Aadd(uRetorno, { '!(ROUND(E1_SDACRES,2) > ROUND(E1_ACRESC,2)) .And. ROUND(E1_SALDO,2) + ROUND(E1_SDACRES,2) # ROUND(E1_VALOR,2) + ROUND(E1_ACRESC,2) .And. !FXAtuTitCo()', aLegenda[2][1]} ) //"Baixado parcialmente"				
			Aadd(uRetorno, { 'ROUND(E1_SALDO,2) == ROUND(E1_VALOR,2) .and. AllTrim(E1_SITUACA)== "F"'			, aLegenda[Len(aLegenda)][1]	} ) //"Titulo Protestado"


			If !lF040URET
				Aadd(uRetorno, { '.T.', aLegenda[1][1] } )
			Endif
		Endif
	Else
		If cAlias = "SE1"
			Aadd(aLegenda,{"BR_VERDE_ESCURO", "Titulo Protestado"}) //"Titulo Protestado"
	    Else
			If lPrjCni
				If !Empty(SuperGetMv("MV_APRPAG",.F.,"")) .or. SuperGetMv("MV_CTLIPAG",.F.,.F.)
					Aadd(aLegenda, {"BR_AMARELO",  "Titulo aguardando liberacao"})		//"Titulo aguardando liberacao"
				EndIf
			Else
				IF SuperGetMv("MV_CTLIPAG",.F.,.F.)
					Aadd(aLegenda, {"BR_AMARELO",  "Titulo aguardando liberacao"})		//"Titulo aguardando liberacao"
				EndIf
			Endif

			Aadd(aLegenda, {"BR_LARANJA", "Adiantamento de Viagem sem taxa"}) //"Adiantamento de Viagem sem taxa"

			IF lFaLegPares
				Aadd(aLegenda,{"BR_MARROM","Titulo PA com resíduos de saldo"})
			Endif

			//Validação para uso do documento habil (SIAFI)
			If FinUsaDH()
				Aadd(aLegenda,{"BR_VIOLETA","Titulo Vinculado a Docto Hábil"}) // "Titulo Vinculado a Docto Hábil"
			Endif
		EndIf
		
		BrwLegenda(cCadastro, "Legenda", aLegenda)		//"Legenda"
	EndIf
	
	
IF TYPE("_aRFIN02") == "A"
	nLenLeg	:= len(aLegenda)
	FOR nI := 1 to len(uRetorno)
		AADD(_aRFIN02, {uRetorno[nI, 1], uRetorno[nI, 2], iif(nLenLeg>=nI,aLegenda[nI, 2],"" )})
	NEXT nI
ENDIF	

Return uRetorno