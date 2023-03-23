#Include 'Protheus.ch'
#Include "topconn.ch"

/*/{Protheus.doc} MyCalInt
LIB Generica. Neste fonte serão armazenadas as funções que podem ser utilizadas em mais de um módulo ou processo
a Função de nome FSLIB002 nunca será implementada.

@author claudiol
@since 09/12/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/


/*/{Protheus.doc} MyCalInt
Calcula intervalo entre duas datas e horas

@author claudiol
@since 19/02/2016
@version undefined
@param dDatIni, date, descricao
@param dDatFin, date, descricao
@param cHorIni, characters, descricao
@param cHorFin, characters, descricao
@type function
/*/
User Function MyCalInt(dDatIni,dDatFin,cHorIni,cHorFin)

Local cRet		:= ""
Local nIntDia	:= 0
Local nHorDia	:= 0
Local cHorEnt	:= ""
Local cHorSai	:= ""

Local nSeqIni:= fDHtoNS( dDatIni , Val(StrTran(cHorIni,":",".")) )
Local nSeqFin:= fDHtoNS( dDatFin , Val(StrTran(cHorFin,":",".")) )

//Se data final menor que data inicial nao calcula
If nSeqFin < nSeqIni
	Return(cRet)
EndIf


If Len(cHorIni)==5
	cHorIni+= ":00"
EndIf

If Len(cHorFin)==5
	cHorFin+= ":00"
EndIf

If (dDatIni==dDatFin)
	cRet:= ElapTime( cHorIni, cHorFin )
Else
	//Calcula o numero de dias
	nIntDia	:= DateDiffDay( dDatIni , dDatFin )

	//Calcula as horas do dia inicial
	cHorEnt	:= ElapTime( cHorIni, '24:00:00' )
	
	//Calcula as horas do dia final
	cHorSai	:= ElapTime( '00:00:00', cHorFin )

	//Soma as horas inicial e final
	cRet:= SomaHoras( cHorEnt , cHorSai )

	//Calcula e soma as horas do intervalo de dias
	If (nIntDia > 1)
		nHorDia:= (nIntDia - 1) * 24
		cRet:= SomaHoras( cRet , nHorDia )
	EndIf

	//Formata o total de horas para o formato de horas
	cRet:= cValToChar(cRet)     
	cRet:= Strtran(cRet,".",":")
	
	If (At(":",cRet) <> 0)
		cRet+= Repl("0", (5 - Len(cRet)))
	Else
		cRet+= ":00"
	EndIf      
	
	//cRet := Repl("0", (10 - Len(cRet)))+cRet
	cRet := Repl("0", (7 - Len(cRet))) + cRet + ":00"
EndIf

Return(cRet)
