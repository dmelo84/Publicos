#include "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"  
#include "CFGA710.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PARMTYPE.CH


/*/{Protheus.doc} RCFG002
Relatório deve listar todas as informações 
apresentadas na interface de configuração do audit trail
@author Jonatas Oliveira | www.compila.com.br
@since 21/03/2019
@version 1.0
/*/
User Function RCFG002()
		Local cPerg	:= "RCFG02"
		AjustaSx1(cPerg)


//	IF Aviso("Relatório Acessos","Exporta para excel configurações do Embedded Audit Trail."+CRLF+CRLF+"Deseja Continuar ?",{"Ok","Cancelar"}) == 1
	IF Pergunte(cPerg)
		RCFG002E(MV_PAR01, MV_PAR02)
	ENDIF
//	ENDIF

Return()



/*/{Protheus.doc} RCFG002E
Realiza impressão do relatorio
@author Jonatas Oliveira | www.compila.com.br
@since 21/03/2019
@version 1.0
/*/
Static Function RCFG002E(cIdDe, cIDAte)
	Local _cNome	:= GetTempPath(.T.) + "APLICADOR_" + DTOS(DDATABASE)+"_" + STRTRAN(TIME(),":","-") + ".XLS"
	Local oExcel, cSheet, cTable
	
	Local cITEmp := ""
	Local cEscEmp := ""
	Local cEMEmp := ""
	Local cOPEmp := ""
	Local cCAEmp := ""

	Local cITTab := ""
	Local cEscTab := ""
	Local cTATab := ""
	Local cIDTab := ""
	Local cOPTab := ""
	Local cCATab := ""
	Local cALTab := ""

	Local cITCam := ""
	Local cEscCam := ""
	Local cFICam := ""
	Local cIDCam := ""
	Local cOPCam := ""
	Local nPosAux	:= 0
	
	Local _cTable	:= ""
	Local _cCampo	:= ""
	Local _cAux		:= ""

	Private aDadEmp	:= {}
	Private aDadTab	:= {}
	Private aDadCam	:= {}
	
	// Abre dicionario de tablespaces do audittrail 	
	FwOpenXA4()

//	Loadme()


	oExcel 	:= FWMSEXCEL():New()
	cSheet 	:= "Aplicador "
	cTable	:= "Aplicador "

	oExcel:AddworkSheet(cSheet)
	oExcel:AddTable (cSheet,cTable)

	/*Grupo de Empresas*/

	oExcel:AddColumn(cSheet ,cTable ,"Grupo de Empresas"		,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Escopo Grupo"				,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Operação Grupo"			,1,1)

	/*Tabela*/
	oExcel:AddColumn(cSheet ,cTable ,"Tabela"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Escopo Tabela"			,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Operação Tabela"			,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Campos Deletados"			,1,1)

	/*Campos*/
	oExcel:AddColumn(cSheet ,cTable ,"Item"						,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Campo"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Escopo"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Operação"					,1,1)

	dbselectarea("XA4")
	XA4->(dbsetorder(0))
	XA4->(dbgotop())

	IF !EMPTY(MV_PAR01)
		_cTable := ALLTRIM(MV_PAR01) 
	ENDIF 
		
	IF !EMPTY(MV_PAR02) 
		_cTable := SX3INFO(2, ALLTRIM(MV_PAR02)) 
	ENDIF 

	IF XA4->(!Eof())
		While XA4->(!Eof())
			
			/*Grupo de Empresas*/
			If !Empty(XA4_EMP)
	
				cEMEmp	:= XA4_EMP 		//|Grp de Empresa|
				cEscEmp := GetDescEsc( "XA4_ACCESS" ,XA4_ACCESS ) 	//|Escopo|
				cOPEmp 	:= GetDescEsc( "XA4_OPER" ,XA4_OPER )		//|Operação|
		
	
			Endif 
			
			/*Tabelas*/
			If !Empty(XA4_TABLE)
			
				IF EMPTY(_cTable) .OR. ALLTRIM(XA4_TABLE) == _cTable   
			
					cTATab	:= XA4_TABLE 	//|Tabela|
					cEscTab	:= GetDescEsc( "XA4_ACCESS" ,XA4_ACCESS )	//|Escopo|
					cOPTab	:= GetDescEsc( "XA4_OPER" ,XA4_OPER )		//|Operação|
					cALTab	:= GetDescEsc( "XA4_ALLDEL" ,XA4_ALLDEL )  	//|Campos Deletados|
				ENDIF 			 
		
			Endif 
	
			If !Empty(XA4_FIELD)
				
				_cAux := SX3INFO(2, ALLTRIM(XA4_FIELD)) 
				
				IF ALLTRIM(MV_PAR02) == ALLTRIM(XA4_FIELD) .OR. ( _cAux == ALLTRIM(MV_PAR01) .AND. EMPTY(MV_PAR02) ) .OR. ( EMPTY(MV_PAR01) .AND. EMPTY(MV_PAR02) )
					
					cITCam	:= XA4_IDFLD	//|Item|
					cFICam	:= XA4_FIELD	//|Campo |
					cEscCam	:= GetDescEsc( "XA4_ACCESS" ,XA4_ACCESS )	//|Escopo|
					cOPCam	:= GetDescEsc( "XA4_OPER" ,XA4_OPER ) 	 	//|Operação|
		
					oExcel:AddRow(cSheet,cTable,{	cEMEmp	,;
													cEscEmp ,;
													cOPEmp 	,;
													cTATab	,;
													cEscTab	,;
													cOPTab	,;
													cALTab	,;
													cITCam	,;
													cFICam	,;
													cEscCam	,;
													cOPCam})
				ENDIF 
			endif 
	
			XA4->(dbskip())
	
	
	
	
		EndDo
	ELSE	
		oExcel:AddRow(cSheet,cTable,{	"NÃO HÁ DADOS"	,;
										cEscEmp ,;
										cOPEmp 	,;
										cTATab	,;
										cEscTab	,;
										cOPTab	,;
										cALTab	,;
										cITCam	,;
										cFICam	,;
										cEscCam	,;
										cOPCam})
	ENDIF
	
	oExcel:Activate()
	oExcel:GetXMLFile(_cNome)								
	
	/*=====================
	| Abre arquivo gerado  |
	=======================*/
	ShellExecute("open","excel.exe",_cNome,"", 1 )	


Return()

Static Function Loadme()
	Local aLinEmp	:= {}
	Local aLinTab	:= {}
	Local aLinCam	:= {}
	Local cMsg1 	:= ""
	Local cMsg2 	:= ""
	Local cMsg3 	:= ""
	Local _cTable	:= ""
	Local _cCampo	:= ""
	Local _cAux		:= ""

	Private _cFileLog
	Private _cLogPath
	Private _Handle


	fGrvLog(1,"Iniciando gravação de Log. "+TIME()+". "+ DToC(ddatabase)  )	//||Opcao:  1= Cria Arquivo de Log, 2= Grava Log, 3 = Apresenta Log

	IF !EMPTY(MV_PAR01)
		_cTable := ALLTRIM(MV_PAR01) 
	ENDIF 
		
	IF !EMPTY(MV_PAR02) 
		_cTable := SX3INFO(2, ALLTRIM(MV_PAR02)) 
	ENDIF 
	
	dbselectarea("XA4")
	XA4->(dbsetorder(0))
	XA4->(dbgotop())

	While XA4->(!Eof())

		if !Empty(XA4_EMP)

			//			cEMEmp	:=  XA4_EMP

			//			AADD(aLinEmp, {'XA4_ITEM'	, XA4_ITEM })			
			//			AADD(aLinEmp, {'XA4_ACCESS'	, XA4_ACCESS})				
			//			AADD(aLinEmp, {'XA4_EMP'	, XA4_EMP})
			//			AADD(aLinEmp, {'XA4_OPER'	, XA4_OPER})		
			//			AADD(aLinEmp, {'XA4_CARGO'	, XA4_CARGO})

			cMsg1 := 	"EMPRESA: " +; 
			'XA4_ITEM' 		+ "->" + XA4_ITEM 	+ " | " + ;
			'XA4_ACCESS' 	+ "->" + XA4_ACCESS + " | " + ;
			'XA4_EMP'		+ "->" + XA4_EMP 	+ " | " + ;
			'XA4_OPER' 		+ "->" + XA4_OPER 	+ " | " + ;
			'XA4_CARGO' 	+ "->" + XA4_CARGO 	+ " | "   

		elseif !Empty(XA4_TABLE)
													
			IF EMPTY(_cTable) .OR. ALLTRIM(XA4_TABLE) == _cTable   
			
				AADD(aLinTab, {'XA4_ITEM'	, XA4_IDTAB })			
				AADD(aLinTab, {'XA4_ACCESS'	, XA4_ACCESS})
				AADD(aLinTab, {'GUJ_TABELA'	, XA4_TABLE})
				AADD(aLinTab, {'XA4_IDTAB'	, XA4_IDTAB})        
				AADD(aLinTab, {'XA4_OPER'	, XA4_OPER})
				AADD(aLinTab, {'XA4_ALLDEL'	, XA4_ALLDEL})
	
				//			cTATab	:= XA4_TABLE
				//			cCmpDel	:= XA4_ALLDEL
	
	
				cMsg2 := 	"TABELA: " +;
							'XA4_ITEM'		+ "->" + XA4_IDTAB 	+ " | " + ;		
							'XA4_ACCESS'	+ "->" + XA4_ACCESS	+ " | " + ;
							'GUJ_TABELA'	+ "->" + XA4_TABLE	+ " | " + ;
							'XA4_IDTAB'		+ "->" + XA4_IDTAB	+ " | " + ;      
							'XA4_OPER'		+ "->" + XA4_OPER	+ " | " + ;
						'XA4_ALLDEL'	+ "->" + XA4_ALLDEL	+ " | " 
			ENDIF 
			
		elseif !Empty(XA4_FIELD)
			_cAux	:= XA4_FIELD
			_cAux 	:= SX3INFO(2, ALLTRIM(_cAux)) 
			
			IF ALLTRIM(MV_PAR02) == ALLTRIM(XA4_FIELD) .OR. ( _cAux == ALLTRIM(MV_PAR01) .AND. EMPTY(MV_PAR02) ) .OR. ( EMPTY(MV_PAR01) .AND. EMPTY(MV_PAR02) )  
			 
				AADD(aLinCam, {'XA4_ITEM'	, XA4_IDFLD })			
				AADD(aLinCam, {'XA4_ACCESS'	, XA4_ACCESS})
				AADD(aLinCam, {'XA4_FIELD'	, XA4_FIELD})
				AADD(aLinCam, {'XA4_IDFLD'	, XA4_IDFLD})            
				AADD(aLinCam, {'XA4_OPER'	, XA4_OPER})			
	
	
				cMsg3 := 	"CAMPO: " +; 
				'XA4_ITEM'		+ "->" + XA4_IDFLD 	+ " | " + ;			
				'XA4_ACCESS'	+ "->" + XA4_ACCESS	+ " | " + ;	
				'XA4_FIELD'		+ "->" + XA4_FIELD	+ " | " + ;	
				'XA4_IDFLD'		+ "->" + XA4_IDFLD	+ " | " + ;	          
				'XA4_OPER'		+ "->" + XA4_OPER	+ " | " 
			ENDIF 
		endif 

		XA4->(dbskip())

		fGrvLog(2,cMsg1 + cMsg2 + cMsg3)

		cMsg1 := ""
		cMsg2 := "" 
		cMsg3 := ""

		//		AADD(aDadEmp , aLinEmp)
		//		AADD(aDadTab , aLinTab)
		//		AADD(aDadCam , aLinCam)

	EndDo


	fGrvLog(3,"Fim da Gravação . "+TIME()+". "+ DToC(ddatabase))
Return()


/*/{Protheus.doc} AjustaSx1
Cria perguntas
@author Fabio Sales | www.compila.com.br
@since 05/11/2018
@version 1.0
/*/

Static Function AjustaSx1(cPerg)
	Local aArea := GetArea()

	xPutSX1( cPerg, "01","Tabela" ,"","","mv_ch1","C",3,0,0,"G","",""	,"","","mv_par01","","","","","","","","","","","","","","","","",,, )
	xPutSX1( cPerg, "02","Campo"  ,"","","mv_ch2","C",10,0,0,"G","",""	,"","","mv_par02","","","","","","","","","","","","","","","","",,, )
//	xPutSX1( cPerg, "03","Rotina"      ,"","","mv_ch3","C",30,0,0,"G","",""	,"","","mv_par03","","","","","","","","","","","","","","","","",,, )

	RestArea(aArea)
Return()





/*/{Protheus.doc} xPutSX1
Ajusta perguntas SX1
@author Augusto Ribeiro | www.compila.com.br
@since 15/03/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function xPutSX1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
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

	// Ajusta o tamanho do grupo. Ajuste emergencial para validaÃ§Ã£o dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt	:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa		:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng		:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

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

/*/{Protheus.doc} GetDescEsc
Retorna Descrição do campo
@author Jonatas Oliveira | www.compila.com.br
@since 15/03/2019
@version 1.0
/*/
Static Function GetDescEsc( _cField ,cCdAcess )
	Local cRet 	:= ""
	
	
	IF ALLTRIM(_cField) == "XA4_ACCESS"
	
		IF ALLTRIM(cCdAcess) == "1"
			cRet := "Regra"
		ELSEIF ALLTRIM(cCdAcess) == "2"
			cRet := "Exceção"
		ELSEIF ALLTRIM(cCdAcess) == "3"
			cRet := "Ligação"
		ENDIF 
		
	ELSEIF ALLTRIM(_cField) == "XA4_OPER"
	
		IF ALLTRIM(cCdAcess) == "0"
			cRet := "Não se aplica"
		ELSEIF ALLTRIM(cCdAcess) == "1"
			cRet := "Inclusão"
		ELSEIF ALLTRIM(cCdAcess) == "2"
			cRet := "Alteração"
		ELSEIF ALLTRIM(cCdAcess) == "3"
			cRet := "Exclusão"
		ELSEIF ALLTRIM(cCdAcess) == "4"
			cRet := "Inclusão e Alteração"
		ELSEIF ALLTRIM(cCdAcess) == "5"
			cRet := "Inclusão e Exclusão"
		ELSEIF ALLTRIM(cCdAcess) == "6"
			cRet := "Alteração e Exclusão"
		ELSEIF ALLTRIM(cCdAcess) == "7"
			cRet := "Inclusão, Alteração e Exclusão"	
		ENDIF 
		
	ELSEIF ALLTRIM(_cField) == "XA4_ALLDEL"
	
		IF ALLTRIM(cCdAcess) == "1"
			cRet := "Todos Campos"	
		ELSEIF ALLTRIM(cCdAcess) == "0"
			cRet := "Apenas Selecionados"	
		ENDIF 
		
	ENDIF 

Return(cRet)

Static Function SX3INFO(_nIndice, _cInfo)
	Local cRet := ""
	Local aArea		:= GetArea()
	
	
	DBSELECTAREA("SX3")
	SX3->(DBSETORDER(_nIndice)) 
	IF SX3->(DBSEEK(ALLTRIM(UPPER(_cInfo))))
		
		cRet	:= ALLTRIM(SX3->X3_ARQUIVO)	
		
	ENDIF 
	RestArea(aArea)
Return(cRet)