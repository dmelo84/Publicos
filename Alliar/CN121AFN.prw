#Include 'Protheus.ch'

/*/{Protheus.doc} CN121AFN
Altera informações do título no financeiro no encerramento da Medição
Descrição:  permite alterar informações nos títulos financeiros no momento de encerrar uma medição.
Localização: no momento do encerramento da medição.

==> antigo CN120ALT (CNTA120)  (HFP-COMPILA) 

Eventos: ao encerrar a medição, é gerado um título no Financeiro com as informações alteradas.
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
