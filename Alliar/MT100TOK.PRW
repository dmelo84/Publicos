#INCLUDE "PROTHEUS.CH"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MT100TOK

Ponto de entrada Valida a inclusão de NF.

@author     ABAX SISTEMAS
@since     	01/01/2021
@version  	P.11
@obs        Nenhum
Alterações Realizadas desde a Estruturação Inicial
------------+-----------------+----------------------------------------------------------
Data       	|Desenvolvedor    |Motivo
------------+-----------------+----------------------------------------------------------
/*/
User Function MT100TOK()

Local lRet := .T.
Local nPosItem := aScan(aHeader,{|X| AllTrim(X[2]) == "D1_ITEM"})
Local nPosCc := aScan(aHeader,{|X| AllTrim(X[2]) == "D1_CC"})
Local nPosRat := aScan(aHeader,{|X| AllTrim(X[2]) == "D1_RATEIO"})
Local nDiasVenc := 0
Local aVenc	:= {} 

If IsInCallStack("U_MTUFOPRO")

	private nPrzMin  := 0

	/*
	//bloqueado HFP para na Producao nao ficar mostrando MSG toda Hora, 
	//conforme conversado com Vaney, via whats
	If IsInCallStack("U_MTUFOPRO")
		Help('TESTE PE MT103FIN - ABAX',1,'MT103FIN',,"RECONHECEU QUE A CHAMADA É DO ÝBAX." ,1,0)
	else
		Help('TESTE PE MT103FIN - ABAX',1,'MT103FIN',,"NÃO RECONHECEU QUE A CHAMADA É DO ÝBAX." ,1,0)
	ENDIF
	*/


	IF Type("cXTPINT") == "C"
		IF cXTPINT == "HM"
			_cParam := "ES_XDPGHM"
		ELSE	
			_cParam := "ES_XDIASPG"
		ENDIF	
	ELSEIF FunName() == "MATA103" .AND. ALTERA
		IF ALLTRIM(SF1->F1_XTPINT) == "HM"
			_cParam := "ES_XDPGHM"
		ELSE	
			_cParam := "ES_XDIASPG" 
		ENDIF	

	ELSE
		//HFP-Compila  20210329 - inlusdo else para nao dar erro -  _cParam nulo qdo inclusao
		//             task 7554649
		_cParam := "ES_XDIASPG"  
	ENDIF

	nDiasVenc  := GetMV(_cParam,.F.)
	
	If(L103AUTO)	
		aVenc	:= Condicao(100,CCONDABAX,,DDEMISSAO)	
	Else
		aVenc	:= Condicao(100,CCONDICAO,,DDEMISSAO)
	EndIf
	
	If Len(aVenc)>0
		If(aVenc[1][1] <= DATE())
			Help('Valida Vencimento',1,'MT100TOK',,"ÝBAX - Lançamento bloqueado, pois a NF está vencida, gentileza verificar." ,1,0)			
			lRet := .F.
		ElseIf(DateDiffDay(DATE(),aVenc[1][1]) < nDiasVenc)
			Help('Valida Vencimento',1,'MT100TOK',,"ÝBAX - Lançamento bloqueado, pois a NF irá vencer em menos de (07) dias úteis, gentileza verificar." ,1,0)			
			lRet := .F.
		EndIf
	EndIf
	
	
else
	Return(lRet)
ENDIF

Return(lRet)






