#include "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"  
//#include "CFGA710.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PARMTYPE.CH
#INCLUDE "RWMAKE.ch"
#INCLUDE "TBICONN.CH"


/*/{Protheus.doc} RCFG004
Exporta para excel dados de Usuários
@author Jonatas Oliveira | www.compila.com.br
@since 26/08/2019
@version 1.0
/*/
User Function RCFG004()
	Local cPerg		:= "RCFG04"
	Private _cFileLog
	Private _cLogPath
	Private _Handle

	AjustSX1(cPerg)

	IF Pergunte(cPerg)
		fGrvLog(1,"Iniciando gravação de Log. "+TIME()+". "+ DToC(ddatabase)  )	//||Opcao:  1= Cria Arquivo de Log, 2= Grava Log, 3 = Apresenta Log

		Processa({|| U_RCFG04P()},"Exportando Dados (v1)...")

		fGrvLog(3,"Fim da Gravação . "+TIME()+". "+ DToC(ddatabase))
	ENDIF 
Return()

/*/{Protheus.doc} RCFG004
Relatório deve listar todas as informações 
apresentadas na interface de configuração do audit trail
@author Jonatas Oliveira | www.compila.com.br
@since 21/03/2019
@version 1.0
/*/
User Function RCFG04P()
	//Local nx, nI, nY
	Local nI, nY
	Local aUser 	:= {}
	Local aAllusers := FWSFALLUSERS()
	Local aAllGrp 	:= AllGroups()
	Local nPosGrp	:= 0 
	Local oExcel, cSheet, cTable

	// HFP - Compila 20210311  
	// modificado para XML, pois estava dando erro na abertura
	//Local _cNome	:= GetTempPath(.T.) + "USUARIOS_" + DTOS(DDATABASE)+"_" + STRTRAN(TIME(),":","-") + ".XLS"
	Local _cNome	:= GetTempPath(.T.) + "USUARIOS_" + DTOS(DDATABASE)+"_" + STRTRAN(TIME(),":","-") + ".xml"

	//	Local _cPasta	:= "/DATA/"
	//	Local _cNome	:= "USUARIOS_" + DTOS(DDATABASE)+"_" + STRTRAN(TIME(),":","-") + ".XLS"
	

	Local cUsrId	:= ""
	Local cCodUsr	:= ""
	Local cNomUsr	:= ""  
	Local cMailusr	:= ""  
	Local cIdGrp 	:= ""
	Local cDescGrp	:= ""
	Local cDtCria	:= ""
	Local cDtBlq	:= ""
	Local cStatus	:= ""
	Local nTotAcs	:= 0 
	Local nTotReg	:= 0 
	Local lContinua	:= .F. 
	Local aDadGrp	:= {}

	oExcel 	:= FWMSEXCEL():New()
	cSheet 	:= "Usuarios "
	cTable	:= "Usuarios "

	oExcel:AddworkSheet(cSheet)
	oExcel:AddTable (cSheet,cTable)


	oExcel:AddColumn(cSheet ,cTable ,"ID"			,1,1) 
	oExcel:AddColumn(cSheet ,cTable ,"USUARIO"		,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"NOME"			,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"EMAIL"		,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"GRUPO"		,1,1)
	//	oExcel:AddColumn(cSheet ,cTable ,"DESC GRUPO"	,1,1) 
	oExcel:AddColumn(cSheet ,cTable ,"DATA CRIAÇÃO"	,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"DATA BLOQUEIO",1,1) 
	oExcel:AddColumn(cSheet ,cTable ,"STATUS"		,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"QTD ACESSOS"	,1,2)

	nTotReg := Len( aAllusers )
	ProcRegua(nTotReg)

	For nI := 1 To nTotReg

//		incproc("Exportando " + str(++nI, 5) + " / " + str(nTotReg, 5))

		psworder(1)
		IF pswseek(aAllusers[nI][2])
//			fGrvLog(2, "Achou Usuario " + aAllusers[nI][2])
			aUser := PSWRET()

			IF 	(  EMPTY(MV_PAR01) .OR. (MV_PAR01 >= aUser[1][6] .AND. MV_PAR02 <= aUser[1][6]) );
			.AND. ( MV_PAR03 <= aUser[1][24] .AND. MV_PAR04 >= aUser[1][24] ); 
			.AND. ( MV_PAR05 == 3 .OR. ( MV_PAR05 == 1 .AND. !aUser[1][17] ) .OR. ( MV_PAR05 == 2 .AND. aUser[1][17] ) ) 

//				fGrvLog(2, "Entrou no Filtro " + aAllusers[nI][2])

				cUsrId	:= aUser[1][1]
				cCodUsr	:= aUser[1][2] 
				cNomUsr	:= aUser[1][4]
				cMailusr:= aUser[1][14]
				cIdGrp	:= ""
				nTotAcs	:= aUser[1][15]

				aDadGrp := {}

				//|Grupos|
				IF LEN( aUser[ 1 ][ 10 ]) > 0 
					For nY := 1 To Len( aUser[1][10])

						AADD( aDadGrp, Alltrim( aUser[1][10][nY] ))

						cIdGrp 	+= Alltrim( aUser[1][10][nY] ) + " - "

						nPosGrp := aScan( aAllGrp, { |x| AllTrim(x[01][1]) == ALLTRIM( Alltrim( aUser[1][10][nY] ) ) } )

						IF nPosGrp > 0 
							cIdGrp	+= ALLTRIM( aAllGrp[ nPosGrp ][ 1 ][ 2 ]) + " | "

						ELSE
							cIdGrp	:= ""
						ENDIF 
					Next nY
				ELSE
					cIdGrp 		:= ""
					cDescGrp	:= ""
				ENDIF 

				cDtCria	:= DTOC( aUser[1][24])
				cDtBlq	:= DTOC( aUser[1][6] )
				cStatus	:= IIF(aUser[1][17], "Bloqueado", "Ativo")


				oExcel:AddRow(cSheet,cTable,{	cUsrId		,;
												cCodUsr 	,;
												cNomUsr 	,;
												cMailusr 	,;
												cIdGrp		,;										
												cDtCria		,;
												cDtBlq		,;
												cStatus 	,;
												nTotAcs		})

			ELSE
//				fGrvLog(2, "Não Entrou no Filtro " + aAllusers[nI][2])
			ENDIF 

			lContinua	:= .T.
			//
			//			IF ( EMPTY(MV_PAR06) .AND. LEN(aDadGrp) == 0 )
			//				lContinua	:= .T.
			//			ELSE
			//				For nW := 1 To Len(aDadGrp)
			//					IF aDadGrp[nW] >= MV_PAR06 .AND. aDadGrp[nW] <= MV_PAR07
			//						lContinua	:= .T.
			//					ENDIF 					
			//				Next nW 
			//			ENDIF

			IF lContinua 

			ENDIF 
		ELSE
//			fGrvLog(2, "NÃO Achou Usuario " + aAllusers[nI][2])
		ENDIF 
	Next nI

	oExcel:Activate()
	oExcel:GetXMLFile(_cNome)
//	oExcel:GetXMLFile(_cPasta + _cNome)
	
//	IF __CopyFile( _cPasta + _cNome , GetTempPath(.T.) + _cNome)								

		/*=====================
		| Abre arquivo gerado  |
		=======================*/
		// HFP - Compila  20210311
		// Modificao o codigo abaixo para WINEXEC, pois o shell dando erro de abertura.
		//ShellExecute("open","excel.exe",GetTempPath(.T.) + _cNome,"", 1 )
		WinExec('explorer.exe '+ _cNome,2)
		
		AVISO("RCFG04P","Arquivo salvo em " + GetTempPath(.T.) + _cNome,{"Fechar"}, 3, ,, , .T.,  )
//	ENDIF 


Return


//C:\Fontes\Compila\AjustSx1.prw
/*/{Protheus.doc} AjustSX1
Ajusta Perguntas - SX1
@author Jonatas Oliveira | www.compila.com.br
@since 19/07/2018
@version 1.0
/*/
Static Function AjustSX1(cPerg)
	//hfp Local aArea := GetArea()
	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}

	aAdd( aHelpEng, "  ")
	aAdd( aHelpSpa, "  ")

	aHelpPor := {} ; Aadd( aHelpPor, "Data Bloqueio De")
	xPutSX1(cPerg,"01","Data Bloqueio De?"		 			,"Data Bloqueio De?"		,"Data Bloqueio De?"		,"mv_ch1","D",08,00,0,"G",""		,""		,""	,"","mv_par01",""				,"","","",""		,"","",""			,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Data Bloqueio Ate")
	xPutSX1(cPerg,"02","Data Bloqueio Ate?"					,"Data Bloqueio Ate?"		,"Data Bloqueio Ate?"		,"mv_ch2","D",08,00,0,"G",""		,""		,""	,"","mv_par02",""				,"","","",""		,"","",""			,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Data Inclusão De")
	xPutSX1(cPerg,"03","Data Inclusão De?"					,"Data Inclusão De?"		,"Data Bloqueio De?"		,"mv_ch3","D",08,00,0,"G",""		,""		,""	,"","mv_par03",""				,"","","",""		,"","",""			,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Data Inclusão Ate")
	xPutSX1(cPerg,"04","Data Inclusão Ate?"					,"Data Inclusão Ate?"		,"Data Bloqueio Ate?"		,"mv_ch4","D",08,00,0,"G","NaoVazio",""		,""	,"","mv_par04",""				,"","","",""		,"","",""			,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Status")
	xPutSX1(cPerg,"05","Status?"							,"Status?"					,"Status?"					,"mv_ch5","C",01,00,0,"C","NaoVazio",""		,""	,"","mv_par05","Ativo"			,"","","","Bloqueado","","","AMBOS" 	,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Grupo De")
	xPutSX1(cPerg,"06","Grupo De?"							,"Grupo De?"				,"Grupo De?"				,"mv_ch6","C",06,00,0,"G",""		,"GRPUSR",""	,"","mv_par06",""			,"","","","          ","","","    " 	,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Grupo Ate")
	xPutSX1(cPerg,"07","Grupo Ate?"							,"Grupo Ate?"				,"Grupo Ate?"				,"mv_ch7","C",06,00,0,"G","NaoVazio","GRPUSR",""	,"","mv_par07",""			,"","","","          ","","","    " 	,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )


Return()

/*/{Protheus.doc} xPutSX1
Ajusta Perguntas - SX1
@author Jonatas Oliveira | www.compila.com.br
@since 19/07/2018
@version 1.0
/*/
Static Function xPutSX1(   cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

	Local aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa  := .f.
	Local lIngl := .f. 

	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme           == Nil, " ", cPyme        )
	cF3      := Iif( cF3             == NIl, " ", cF3          )
	cGrpSxg  := Iif( cGrpSxg  == Nil, " ", cGrpSxg      )
	cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01       )
	cHelp := Iif( cHelp            == Nil, "" , cHelp        )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa      := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng      := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01

		If cGSC == "C"                   // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP  With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else

		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

		If lPort .Or. lSpa .Or. lIngl
			If lPort 
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf

			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf

			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif

	RestArea( aArea )

Return




/*/{Protheus.doc} fGrvLog
Realiza a Criação, Gravacao, Apresentacao do Log de acordo com o Pametro passado
@author www.compila.com.br
@param _nOpc, N, 1= Cria Arquivo de Log, 2= Grava Log, 3 = Apresenta Log
@param _cTxtLog, C, Log a ser gravado 
/*/
Static Function fGrvLog(_nOpc, _cTxtLog)
	Local _lRet	:= Nil
	//hfp Local _nOpc, _cTxtLog
	Local _EOL	:= chr(13)+chr(10)

	Default _nOpc		:= 0
	Default _cTxtLog 	:= ""
	
	_cTxtLog += _EOL

	Do Case
		Case _nOpc == 1
		_cFileLog	 	:= Criatrab(,.F.)
		_cLogPath		:= AllTrim(GetTempPath())+_cFileLog+".txt"
		_Handle			:= FCREATE(_cLogPath,0)	//| Arquivo de Log
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF

		Case _nOpc == 2
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF

		Case _nOpc == 3
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		FCLOSE(_Handle)
		WINEXEC("NOTEPAD "+_cLogPath)
	EndCase

Return(_lRet)
