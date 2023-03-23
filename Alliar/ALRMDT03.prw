#Include "Totvs.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} uConcluiCIPA
(long_description)
@type class
@author JorgeHeitor
@since 31/12/2015
@version 1.0
@obs Classe chamada para retorno dos dados via WebService, após a Conclusão do Fluig (Processo de Abertura da CIPA)
/*/

Class uConcluiCIPA

	Data cEmpDest
	Data cFilDest
	Data cIDFluig
	Data cMsgRet
	Data aDatas
	
	Method New()
	Method Baixa()
	
EndClass

Method New() Class uConcluiCIPA

	::cEmpDest 	:= ""
	::cFilDest	:= ""
	::cIDFluig	:= ""
	::cMsgRet	:= ""
	::aDatas	:= {}
	
	aAdd(::aDatas,{"TNN_CONVOC",CtoD("  /  /  ")}) //Tipo 2 - EDITAL DE CONVOCACAO PARA INSCRICAO NAS ELEICOES CIPA       
	aAdd(::aDatas,{"TNN_COMISS",CtoD("  /  /  ")}) //Tipo 3 - DESIGNACAO / FORMACAO DA COMISSAO ELEITORAL                 
	aAdd(::aDatas,{"TNN_COPEDI",CtoD("  /  /  ")}) //Tipo 4 - ENVIAR AVISO AO SINDICATO SOBRE INICIO DO PROCESSO ELEITORAL
	aAdd(::aDatas,{"TNN_INSCRI",CtoD("  /  /  ")}) //Tipo 5 - INICIO INSCRICOES CANDIDATOS                                
	aAdd(::aDatas,{"TNN_INSCRF",CtoD("  /  /  ")}) //Tipo 7 - TERMINO INSCRICOES CANDIDATOS                               
	aAdd(::aDatas,{"TNN_ELEICR",CtoD("  /  /  ")}) //Tipo 8 - REALIZACAO DA ELEICAO (VOTACAO)                             
	aAdd(::aDatas,{"TNN_CURCIP",CtoD("  /  /  ")}) //Tipo A - CURSO PARA CIPEIROS (DATA MINIMA)                           
	aAdd(::aDatas,{"TNN_COSIND",CtoD("  /  /  ")}) //Tipo B - COMUNICAR AO SINDICATO DO RESULTADO E DATA POSSE            
	aAdd(::aDatas,{"TNN_POSSE",CtoD("  /  /  ")}) //Tipo C - REALIZACAO DA POSSE - ATA DE POSSE NOVOS MEMBROS            
	
Return Self

Method Baixa() Class uConcluiCIPA

	Local lRet		:= .T.
	Local cQuery	:= ""
	Local x
	Local aArea		:= GetArea()
	
	cQuery := "SELECT R_E_C_N_O_ REG FROM " + RetSqlName("TNW") + " TNW "
	cQuery += " WHERE TNW.TNW_XIDFLG = '" + ::cIdFluig + "' " 
	cQuery += " AND D_E_L_E_T_ = ' ' AND LTRIM(RTRIM(TNW_USUFIM)) = '' "
	cQuery += " AND TNW.TNW_FILIAL = '" + PadR(::cFilDest,TamSX3("TNW_FILIAL")[1]) + "' "
	
	If Select("TTNW") > 0
	
		TTNW->(dbCloseArea())
		
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	
	TcQuery cQuery Alias "TTNW" NEW
	
	dbSelectArea("TTNW")
	
	If !Eof() //Encontrou registros
	
		While !TTNW->(Eof())
			
			dbSelectArea("TNW")
			dbGoTo(TTNW->REG)
			RecLock("TNW",.F.)
			
				TNW->TNW_USUFIM := PadR("Administrador",TamSX3("TNW_USUFIM")[1])
			
			MsUnlock()
			
			TTNW->(dbSkip())
			
		End
		
		//Atualiza Datas dos Mandatos
		dbSelectArea("TNN")
		dbSetOrder(3) //TNN_XIDFLG
		dbSeek(::cIDFluig)
		If Found()
		
			RecLock("TNN",.F.)
			
			For x := 1 To Len(::aDatas)
			
				TNN->&(::aDatas[x][1]) := ::aDatas[x][2] 
				
			Next x
			
			MsUnlock()
			
		EndIf		
		
		::cMsgRet := "ALRMDT03 - Baixa de pendencias efetuada com sucesso para a solicitação Fluig " + AllTrim(::cIdFluig)
		
	Else
	
		lRet := .F.
		::cMsgRet := "ALRMDT03 - Não foram encontrados registros válidos para a solicitação Fluig " + AllTrim(::cIdFluig)
		
	EndIf
	
	RestArea(aArea)
	
Return lRet