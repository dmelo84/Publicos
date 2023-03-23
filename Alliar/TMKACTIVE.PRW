#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} TMKACTIVE
Ponto de Entrada na abertura da Rotina do Call Center

@author Guilherme Santos
@since 21/11/2016
@version P12
*/
//-------------------------------------------------------------------
User Function TMKACTIVE()
	Local cEntidade := ""
	Local cDescri	:= ""
	Public nLenCols:= 0
	
	If Altera 
		nLenCols:=Len(aCols)
	Endif
	
	If IsInCallStack("U_ALTMKA01")
		If !Empty(M->UC_CODCONT)

			U_A01Entid(M->UC_CODCONT, @cEntidade, @cDescri)

			M->UC_XTIPO 	:= "1"
			M->UC_DESCNT 	:= Posicione("SU5", 1, xFilial("SU5") + M->UC_CODCONT, "U5_CONTAT")
			M->UC_ENTIDAD	:= "AC4"
			M->UC_DESCENT	:= Posicione("SX2", 1, "AC4", "X2_NOME")
			M->UC_XCGC		:= Posicione("SU5", 1, xFilial("SU5") + M->UC_CODCONT, "U5_CPF")
			M->UC_OPERACA	:= "1"
			M->UC_STATUS	:= "2"
			M->UC_CHAVE		:= cEntidade
			M->UC_DESCCHA	:= cDescri
			M->UC_XEMAIL  	:= Posicione("SU5",1,xFilial("SU5") +M->UC_CODCONT, "U5_EMAIL")     
			M->UC_XFONE1  	:= Posicione("SU5",1,xFilial("SU5") +M->UC_CODCONT, "U5_FONE")   
			M->UC_XCDMARC   := MV_PAR58
			MV_PAR60		:= Alltrim(MV_PAR58)
			M->UC_XMARCA 	:= Posicione("SX5",1,xFilial("SX5")+"Z4"+M->UC_XCDMARC, "X5_DESCRI")                                                                       
			aCols[1][(AScan(aHeader, {|x| AllTrim(x[2]) == "UD_ASSUNTO"}))]	:= MV_PAR59
			aCols[1][(AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XFCR"}))]	:= 'N'	
			aCols[1][(AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XSLA"}))]	:= '0'
			TkEntContato(M->UC_CODCONT)  
			/*
			//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
			//쿌tiva o cronometro da tela 10- 10 Segundos�
			//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
			cEntidade	:= M->UC_ENTIDAD	// 1 - Alias :
			cDescInd    := M->UC_CODCONT	// 2 - Indice: Codigo + Loja
			cChave      := cEntidade		// 3 - Codigo: 00000101
			cDescEnt	:= Posicione("SX2", 1, "AC4", "X2_NOME")	// 4 - Nome  : Cadastro de Clientes
			cDescChave  := cDescri			// 5 - Descr : Empresa X Ltda.
			cTimeIni := Time()
			oTimerCro:Activate()    */                                                       


		EndIf
	EndIf
	
Return .T.
