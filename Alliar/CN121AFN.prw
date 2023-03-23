#Include 'Protheus.ch'

/*/{Protheus.doc} CN121AFN
Altera informa��es do t�tulo no financeiro no encerramento da Medi��o
Descri��o:  permite alterar informa��es nos t�tulos financeiros no momento de encerrar uma medi��o.
Localiza��o: no momento do encerramento da medi��o.

==> antigo CN120ALT (CNTA120)  (HFP-COMPILA) 

Eventos: ao encerrar a medi��o, � gerado um t�tulo no Financeiro com as informa��es alteradas.
Programa fonte: CNTA121.
@author Jonatas Oliveira | www.compila.com.br
@since 01/02/2018
@version 1.0
/*/



User Function CN121AFN()
Local aCab:= PARAMIXB[1]
Local cTipo:= PARAMIXB[2]
Local nPosAux

IF cTipo == "1"

 	nE2XIDFLG	:= aScan(aCab,{|x| AllTrim(x[1]) == 'E2_XIDFLG'})
 	IF nE2XIDFLG > 0
 		aCab[nE2XIDFLG,2]	:= CND->CND_XIDFLG
 	ELSE
 		aAdd(aCab,{"E2_XIDFLG",CND->CND_XIDFLG,NIL})
 	ENDIF
 	
 	/*------------------------------------------------------ Augusto Ribeiro | 08/02/2019 - 4:06:07 PM
 		Preenche vencimento conforme campo do cabec da medicao
 	------------------------------------------------------------------------------------------*/
 	IF GETMV("AL_VENCMED",.F.,.T.) .AND. !EMPTY(CND->CND_XIDFLG)
	 	nPosAux	:= aScan(aCab,{|x| AllTrim(x[1]) == 'E2_VENCTO'})
	 	IF nPosAux > 0
	 		aCab[nPosAux,2]	:= CND->CND_DTVENC
	 	ELSE
	 		aAdd(aCab,{"E2_VENCTO",CND->CND_DTVENC,NIL})
	 	ENDIF
	 	
	 	nPosAux	:= aScan(aCab,{|x| AllTrim(x[1]) == 'E2_VENCREA'})
	 	IF nPosAux > 0
	 		aCab[nPosAux,2]	:= DATAVALIDA(CND->CND_DTVENC,.T.)
	 	ELSE
	 		aAdd(aCab,{"E2_VENCREA",DATAVALIDA(CND->CND_DTVENC,.T.),NIL})
	 	ENDIF
	 ENDIF
 
ENDIF

Return(aCab)
