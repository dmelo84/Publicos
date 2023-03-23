#include 'protheus.ch'
#include 'parmtype.ch'

/*-----------------------------------------------------------------
|Ponto de Entrada Geração do borderô de pagamento                  |
|O ponto de entrada F240BORD sera utilizado para tratamento        |
|complementar, apos a gravação do borderô.                         |
|Desenvolvedor: Diogo Melo                                         |
|Data atualização: 17/06/2019                                      |
-------------------------------------------------------------------*/

USER FUNCTION F240BORD

	Local cQrySEA   := ''
	Local AliasSEA  := GetNextAlias() 
	Local cxNumBor  := cNumBor
	Local cxModPag  := cModPgto
	Local cxTipoPag := cTipoPag
	//Local nOpc      := 0
	Local cModSA2   := ''
	Local xMod
	Local xTpl

	nOpc:= AVISO("Alteração Borderô",;
	"Esta rotina altera o Modelo e o Tipo de Pagamento de acordo com o campo "+" 'Forma de pagamento' "+"do cadastro de fornecedores. ";
	+CHR(13)+CHR(10)+ "Confirma a alteração? Clique 'OK' "+CHR(13)+CHR(10)+"Caso contrário 'Fechar', permanecerá o Modelo e Tipo digitados na tela da geração do borderô.",;
	{ "Fechar","OK"}, 2)

	
		cQrySEA := "Select EA_FORNECE, EA_LOJA, EA_NUMBOR, EA_NUM, EA_MODELO, EA_TIPOPAG, EA_ORIGEM, R_E_C_N_O_ " 
		cQrySEA += "From "+RetSqlName("SEA") 
		cQrySEA += "Where D_E_L_E_T_ != '*' "
		cQrySEA += "And EA_NUMBOR = '"+cxNumBor+"' " 
		//cQrySEA += "And EA_FILIAL = '"+cFilAnt+"' "

		cQrySEA := ChangeQuery(cQrySEA)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySEA),AliasSEA, .F., .T.)

		dbSelectArea("SEA")
		dbSelectArea("SA2")

		While (AliasSEA)->(!eof()) 
			
			SA2->(MsSeek(xFilial("SEA")+(AliasSEA)->EA_FORNECE+(AliasSEA)->EA_LOJA))
			cModSA2 := SA2->A2_FORMPAG

		If nOpc == 2

			If !Empty(cModSA2)

				If cModSA2 $ "11|13|16|17|18|21|"
					xTpl := "22"
				ElseIf cModSA2 $ "|99|"
					xTpl := "98"
				Else
					xTpl := cxTipoPag
				EndIf

				SEA->(MSGOTO((AliasSEA)->R_E_C_N_O_))
				RecLock("SEA",.F.)
				Replace EA_MODELO  With cModSA2
				Replace EA_TIPOPAG With xTpl
				MsUnlock( )
			else
				MSGSTOP( "Informação não encontrada no cadastro de cliente", "Modelo inválido" )
				Return .F.
			EndIf 

		EndIf 

			If nOpc == 1

				SEA->(MSGOTO((AliasSEA)->R_E_C_N_O_))
				RecLock("SEA",.F.)
				Replace EA_MODELO  With cModPgto
				Replace EA_TIPOPAG With cTipoPag
				MsUnlock( )

			EndIf

		(AliasSEA)->(dbSkip())
		EndDo
Return