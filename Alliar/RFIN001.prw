#INCLUDE "PROTHEUS.CH"
#include "TBICONN.CH"
#include "RWMAKE.CH"
#include 'topconn.ch'
#include "TbiCode.ch"

#DEFINE EOL CHR(13)+CHR(10)

/*/{Protheus.doc} RFIN001
Relatorio recebimentos
@author Jonatas Oliveira | www.compila.com.br
@since 27/09/2016
@version 1.0
/*/
User Function RFIN001()
	
	Local cPerg := "RFIN01"
	Local _lProcess	:= .F.
	Local _aSay			:= {}
	Local _aBotoes		:= {}
	Private oOk      := LoadBitmap( GetResources(), "LBOK" )
	Private oNo      := LoadBitmap( GetResources(), "LBNO" )
	
	Private cTitulo  := "Relatorio recebimentos"
	
	
	/*=====================
	| Parametros do Usuário
	=======================*/
	AjustaSx1(cPerg)
	
	_aSay	:= {cTitulo,;
		"  ",;
		" Este programa tem como objetivo gerar apresentar Relatorio  ",;
		" recebimentos.",;
		" Preencha os parametros para que os dados sejam corretamente selecionados.",;
		" ",;
		" Compila - Versão 1.1"}
	
	aAdd(_aBotoes, { 5,.T.,{|| PERGUNTE(cPerg,.T.)}})
	aAdd(_aBotoes, { 1,.T.,{|| _lProcess := .T., FechaBatch() }} )
	aAdd(_aBotoes, { 2,.T.,{|| _lProcess := .F., FechaBatch()  }} )
	
	FormBatch( cTitulo, _aSay, _aBotoes ,,240,510)
	
	Pergunte(cPerg,.F.)
	
	IF _lProcess
		RptStatus({|| RFIN01Q()}, cTitulo)
	ENDIF
	
Return()

/*/{Protheus.doc} RFIN01Q
Gera Query para filtros dos registros
@author Jonatas Oliveira | www.compila.com.br
@since 20/10/2015
@version 1.0
/*/
Static Function RFIN01Q()
	Local cQryAux	:= ""
	Local cQuery	:= ""
	Local cQuery2	:= ""
	Local cQuery3	:= ""
	Local cQuery4	:= ""
	Local cQuery5	:= ""
	Local cTpTit	:= ""	 
	
	Private nCount	:= 0
	
	
	cTpTit := INQuery(ALLTRIM(STRTRAN(MV_PAR07,"*","")), , 3)
	
	/*========================================================================
	| Query TKS
	======================================================================== */
	cQuery	+= " SELECT A.R_E_C_N_O_ AS RECSE1,*    	"+CRLF   		  			
	cQuery	+= " FROM "+Retsqlname("SE1")+" A 			"+CRLF
	
	cQuery	+= " INNER JOIN "+Retsqlname("SE5")+" B	"+CRLF
	cQuery	+= " 	ON E1_FILIAL = E5_FILIAL 		"+CRLF
	cQuery	+= " 	AND E1_PREFIXO = E5_PREFIXO		"+CRLF
	cQuery	+= " 	AND E1_NUM = E5_NUMERO			"+CRLF
	cQuery	+= " 	AND E1_PARCELA = E5_PARCELA		"+CRLF
	cQuery	+= " 	AND E1_TIPO = E5_TIPO			"+CRLF
	cQuery	+= " 	AND E1_CLIENTE = E5_CLIFOR		"+CRLF
	cQuery	+= " 	AND E1_LOJA = E5_LOJA			"+CRLF
	cQuery	+= " 	AND E5_RECPAG = 'R'				"+CRLF
	cQuery	+= " 	AND B.D_E_L_E_T_ = ''			"+CRLF
	cQuery	+= " 	AND E5_DATA BETWEEN '"+DTOS(MV_PAR05)+"' AND '"+DTOS(MV_PAR06)+"'			"+CRLF
	
	cQuery	+= " WHERE A.D_E_L_E_T_ = '' 				"+CRLF
	cQuery	+= " 	AND E1_TIPO IN " + cTpTit + " "+CRLF
	cQuery	+= " 	AND E1_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'			"+CRLF
	cQuery	+= " 	AND E1_VENCREA BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'			"+CRLF
	cQuery	+= " 	AND E1_BAIXA <> '' 		"+CRLF
	cQuery	+= " ORDER BY E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA	"+CRLF
	
	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf
	
	MemoWrite(GetTempPath(.T.) + "RFIN001.SQL", cQuery) 
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)
	
	TCSetField("TSQL","E1_EMISSAO"	,"D",08,00)
	TCSetField("TSQL","E1_VENCTO"	,"D",08,00)
	TCSetField("TSQL","E1_VENCREA"	,"D",08,00)
	TCSetField("TSQL","E1_BAIXA"	,"D",08,00)	
	TCSetField("TSQL","E5_DATA"	,"D",08,00)	
	
	
	
	IF TSQL->(!EOF()) 
		Processa({|| RFIN01E() }, "Processando... ")
	ELSE
		AVISO("GERENCIALRECEB"," Verifique os parametros informados. Não existem dados... " ,{"Fechar"}, 3)
	ENDIF
	
	
Return()

/*/{Protheus.doc} RFIN01E
Processa Excel
@author Jonatas Oliveira | www.compila.com.br
@since 27/09/2016
@version 1.0
/*/
Static Function RFIN01E()
	Local oExcel 	:= FWMSEXCEL():New()
	
	Local _cNome	:= GetTempPath(.T.) + "RECEBIMENTOS_" + DTOS(DDATABASE)+"_" + STRTRAN(TIME(),":","-") + ".XLS"
	Local cSheet	:= ""
	Local cTable	:= ""
	Local cStatus	:= ""
	
	Local cNomEmp	:= ""
	Local nVlrNf	:= 0 
	
	Local _nVlrTit	:= 0
	Local _nVlrIss	:= 0
	Local _nVlrPis	:= 0
	Local _nVlrCof	:= 0
	Local _nVlrCsl	:= 0
	Local _nVlrISS	:= 0
	Local _nVlrINS	:= 0 
	Local _nVlrIrf	:= 0
	Local _nVlrLiq	:= 0
	Local _nVlrGlos	:= 0 	
	Local aImpostos	:= {}
	
	//|Define a cor de preenchimento geral para todos os estilos da planilha
	oExcel:SetFrGeneralColor("#000000")
	
	TSQL->(DBGoTop())
	TSQL->( dbEval( {|| nCount++ } ) )
	TSQL->(DBGoTop())
	
	/*========================================================================
	| Cria planilha Base
	======================================================================== */
	cSheet 	:= "Recebimentos "//+"_"+DTOS(DDATABASE)+"_"+STRTRAN(TIME(),":","-")
	cTable	:= "Recebimentos "
	
	oExcel:AddworkSheet(cSheet)
	
	oExcel:AddTable (cSheet,cTable)
	oExcel:SetTitleFrColor("#000000")
	oExcel:SetTitleBgColor("#E6E6E6")
	oExcel:SetHeaderBold(.F.)
	oExcel:SetFrColorHeader("#000000")
	oExcel:SetBgColorHeader("#F8F8F8")
	
	oExcel:SetLineBgColor("#000000")
	oExcel:SetLineBgColor("#FFFFFF")
	oExcel:Set2LineBgColor("#000000")
	oExcel:Set2LineBgColor("#FFFFFF")
		
	oExcel:AddColumn(cSheet ,cTable ,"Empresa"					,1,1)//|1| "Empresa"				
	oExcel:AddColumn(cSheet ,cTable ,"Filial"					,1,1)//|2| "Filial"				
	oExcel:AddColumn(cSheet ,cTable ,"Código Loja"				,1,1)//|3| "Código Loja"			
	oExcel:AddColumn(cSheet ,cTable ,"Nome Cliente"				,1,1)//|4| "Nome Cliente"			
	oExcel:AddColumn(cSheet ,cTable ,"Numero"					,1,1)//|5| "Numero"				
	oExcel:AddColumn(cSheet ,cTable ,"Prefixo"					,1,1)//|6| "Prefixo"				
	oExcel:AddColumn(cSheet ,cTable ,"Parcela"					,1,1)//|7| "Parcela"				
	oExcel:AddColumn(cSheet ,cTable ,"Tipo"						,1,1)//|8| "Tipo"			
	oExcel:AddColumn(cSheet ,cTable ,"Natureza"					,1,1)//|8| "Natureza"
	oExcel:AddColumn(cSheet ,cTable ,"Desc Natureza"			,1,1)//|8| "Desc Natureza"		
	oExcel:AddColumn(cSheet ,cTable ,"Dt. Emissão"				,1,1)//|9| "Dt. Emissão"			
	oExcel:AddColumn(cSheet ,cTable ,"Dt Vencto"				,1,1)//|10|"Dt Vencto"			
	oExcel:AddColumn(cSheet ,cTable ,"DT Baixa"					,1,1)//|11|"DT Baixa"				
	oExcel:AddColumn(cSheet ,cTable ,"Valor Original da NF"		,1,2)//|12|"Valor Original da NF"
	oExcel:AddColumn(cSheet ,cTable ,"Valor da Parcela"			,1,2)//|13|"Valor da Parcela"		
	oExcel:AddColumn(cSheet ,cTable ,"Desconto (-)"				,1,2)//|14|"Desconto (-)"
	oExcel:AddColumn(cSheet ,cTable ,"Acrescimo (+)"			,1,2)//|15|"Acrescimo (+)"				
	oExcel:AddColumn(cSheet ,cTable ,"Valor IRRF "				,1,2)//|16|"Valor IRRF "			
	oExcel:AddColumn(cSheet ,cTable ,"Valor ISS "				,1,2)//|17|"Valor ISS "			
	oExcel:AddColumn(cSheet ,cTable ,"Valor INSS "				,1,2)//|18|"Valor INSS "			
	oExcel:AddColumn(cSheet ,cTable ,"Valor PIS "				,1,2)//|19|"Valor PIS "			
	oExcel:AddColumn(cSheet ,cTable ,"Valor COFINS "			,1,2)//|20|"Valor COFINS "		
	oExcel:AddColumn(cSheet ,cTable ,"Valor CSLL "				,1,2)//|21|"Valor CSLL "			
	oExcel:AddColumn(cSheet ,cTable ,"Multa (+)"				,1,2)//|22|"Multa (+)"			
	oExcel:AddColumn(cSheet ,cTable ,"Juros (+)"				,1,2)//|23|"Juros (+)"			
	oExcel:AddColumn(cSheet ,cTable ,"Valor Liquido"			,1,2)//|24|"Valor Liquido"		
	
	_nRecSe1 := 0 
	
	
	DBSELECTAREA("SE1")
	SE1->(DBSETORDER(1))
	
	
	WHILE TSQL->(!EOF())
	
		SE1->(DBGOTO(TSQL->RECSE1))
							
		aImpostos := RFIN01I()	
		
		IF Len(aImpostos) > 0 
		
			nPosPis := aScan(aImpostos,{|x| Trim(x[1])=="PIS"})
			nPosCof := aScan(aImpostos,{|x| Trim(x[1])=="COF"})
			nPosCsl := aScan(aImpostos,{|x| Trim(x[1])=="CSL"})
			nPosIrf := aScan(aImpostos,{|x| Trim(x[1])=="IR-"})
			
			IF nPosPis > 0 
				_nVlrPis	:= aImpostos[nPosPis][2]
			ENDIF 
			
			IF nPosCof > 0 
				_nVlrCof	:= aImpostos[nPosCof][2]
		 	ENDIF 
			
			IF nPosCsl > 0 
				_nVlrCsl	:= aImpostos[nPosCsl][2]
			ENDIF
			 
			IF nPosIrf > 0 
				_nVlrIrf	:= aImpostos[nPosIrf][2]
			ENDIF 
			
		ELSE
			_nVlrPis	:= 0
		 	_nVlrCof	:= 0
			_nVlrCsl	:= 0
			_nVlrIrf	:= 0 
		ENDIF 
		
		_nVlrISS := 0
		_nVlrINS := 0  
		
		nVlrNf := RFIN1NF()
		
		_nVlrLiq := TSQL->E1_VALOR + (TSQL->E1_MULTA + TSQL->E1_JUROS + TSQL->E1_ACRESC  ) - (TSQL->E1_DECRESC + _nVlrIrf + _nVlrPis + _nVlrCof + _nVlrCsl)
		
		_nVlrISS :=  TSQL->E1_ISS

		IF SE1->E1_NATUREZ == "22010001"
			_nVlrIrf := _nVlrIrf * -1
			
		ELSEIF SE1->E1_NATUREZ == "21020006" 			
			_nVlrPis := _nVlrPis * -1
			
		ELSEIF SE1->E1_NATUREZ == "21020007"			
			_nVlrCof := _nVlrCof * -1
			
		ELSEIF SE1->E1_NATUREZ == "21010006"	
			_nVlrCsl := _nVlrCsl * -1
			
		ELSEIF SE1->E1_NATUREZ == "21020008"	
			_nVlrISS := _nVlrISS * -1
			
		ELSEIF SE1->E1_NATUREZ == "21010034"				
			_nVlrINS := TSQL->E1_INSS * -1
									 		
		ENDIF 

									
		oExcel:AddRow(cSheet,cTable,{	cNomEmp,							;//|1| "Empresa"				
										TSQL->E1_FILIAL,					;//|2| "Filial"				
										TSQL->(E1_CLIENTE+E1_LOJA),			;//|3| "Código Loja"			
										TSQL->E1_NOMCLI,					;//|4| "Nome Cliente"			
										TSQL->E1_NUM,						;//|5| "Numero"				
										TSQL->E1_PREFIXO,					;//|6| "Prefixo"				
										TSQL->E1_PARCELA,					;//|7| "Parcela"				
										TSQL->E1_TIPO,						;//|8| "Tipo"			
										TSQL->E1_NATUREZ,					;//|8| "Tipo"
										POSICIONE("SED",1,XFILIAL("SED")+TSQL->E1_NATUREZ,"ED_DESCRIC"),						;//|8| "Tipo"		
										DTOC(TSQL->E1_EMISSAO),				;//|9| "Dt. Emissão"			
										DTOC(TSQL->E1_VENCREA),				;//|10|"Dt Vencto"			
										DTOC(TSQL->E5_DATA),				;//|11|"DT Baixa"						
										nVlrNf, 							;//|12|"Valor Original da NF"	
										TSQL->E1_VALOR,						;//|13|"Valor da Parcela"		
										TSQL->E1_DECRESC,					;//|14|"Desconto (-)"	
										TSQL->E1_ACRESC,					;//|15|"Acrescimo (+)"		
										_nVlrIrf,							;//|16|"Valor IRRF "			
										_nVlrISS,							;//|17|"Valor ISS "			
										_nVlrINS,							;//|18|"Valor INSS "			
										_nVlrPis,							;//|19|"Valor PIS "			
										_nVlrCof,							;//|20|"Valor COFINS "		
										_nVlrCsl,							;//|21|"Valor CSLL "			
										TSQL->E1_MULTA,						;//|22|"Multa (+)"			
										TSQL->E1_JUROS,						;//|23|"Juros (+)"			
										_nVlrLiq						   })//|24|"Valor Liquido"													
		
		TSQL->(DBSKIP())
		
		aImpostos := {}
	ENDDO
	
	
	
	oExcel:Activate()
	oExcel:GetXMLFile(_cNome)
	oExcel:DeActivate()
	
	/*=====================
	| Abre arquivo gerado  |
	=======================*/
	ShellExecute("open","excel.exe",_cNome,"", 1 )
	
	
Return

/*========================================================================
| Função...: AjustaSx1
| Descrição: Ajusta as Perguntas.
|
| Nota.....:
|
| ========================================================================
| Desenvolvido por: Jonatas Oliveira
======================================================================== */
Static Function AjustaSx1(cPerg)
	
	Local aArea := GetArea()
	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}
	
	aAdd( aHelpEng, "  ")
	aAdd( aHelpSpa, "  ")
	
	aHelpPor := {} ; Aadd( aHelpPor, "Emissão De ")
	PutSx1( cPerg, "01","Emissão De"	,"",""		,"mv_ch1","D",08,0,0,"G","NaoVazio"	,"","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Emissão Ate")
	PutSx1( cPerg, "02","Emissão Ate"	,"",""		,"mv_ch2","D",08,0,0,"G","NaoVazio"	,"","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Vencimento De ")
	PutSx1( cPerg, "03","Vencimento De"	,"",""		,"mv_ch3","D",08,00,0,"G","NaoVazio","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Vencimento Ate ")
	PutSx1( cPerg, "04","Vencimento Ate","",""		,"mv_ch4","D",08,00,0,"G","NaoVazio","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "Dt Baixa De ")
	PutSx1( cPerg, "05","Dt Baixa De"	,"",""		,"mv_ch5","D",08,00,0,"G","NaoVazio","","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Dt Baixa Ate ")
	PutSx1( cPerg, "06","Dt Baixa Ate","",""		,"mv_ch6","D",08,00,0,"G","NaoVazio","","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Tipos de Titulo ")
	PutSx1( cPerg, "07","Tipos ","Tipos","Tipos"	,"mv_ch7","C",60,0,0,"G","U_RFIN5PI","","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
		
Return()


/*/{Protheus.doc} RFIN5PI
Busca os tipos de titulos utilizados 
@author Jonatas Oliveira | www.compila.com.br
@since 27/09/2016
@version 1.0
/*/
User Function RFIN5PI()
	Local _cRet	:= ""
	Local aCartoes	:= {}
	Local aArea		:= GetArea()
	Local cQry		:= ""
	
	cQry += " SELECT E1_TIPO,X5_DESCRI	"+CRLF
	cQry += " FROM "+RetSqlName("SE1")+" A	"+CRLF
	cQry += " INNER JOIN "+RetSqlName("SX5")+" B	"+CRLF
	cQry += " 	ON X5_FILIAL = '"+XFILIAL("SX5")+"'	"+CRLF
	cQry += " 	AND X5_TABELA = '05'	"+CRLF
	cQry += " 	AND E1_TIPO = X5_CHAVE	"+CRLF
	cQry += " WHERE A.D_E_L_E_T_ = ''	"+CRLF
	cQry += " GROUP BY E1_TIPO,X5_DESCRI	"+CRLF
	
	If Select("TSQLP") > 0
		TSQLP->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TSQLP",.F., .T.)
	
	WHILE TSQLP->(!EOF())
		aadd(aCartoes,{TSQLP->E1_TIPO,ALLTRIM(TSQLP->(FIELDGET(FIELDPOS("X5_DESCRI"))))})
		
		TSQLP->(DBSKIP())
	ENDDO
	
	_cRet := BrowX1("Tipos", aCartoes)
	
	RestArea(aArea)
	
Return() 



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AUGUSTO RIBEIRO                                             ³
//³                                                             ³
//³ Monta Pequeno Browser da Pergunta, permitindo que o usuário ³
//³selecione mais de uma opção.                                 ³
//³ Recebe Array com os elementos                               ³
//³ Retorna: ****                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function BrowX1(cTitBrw,aOpcoes)
	Local BrowX1
	Local MvPar
	Local MvParDef	:=	""
	Local l1Elem   	:=	Nil
	Local lTipoRet	:= 	.T.
	Local cFilBack	:= cFilAnt
	
	Private _aFilial:=	{}
	Private aSit	:= 	{}
	
	l1Elem 			:= 	If (l1Elem = Nil , .F. , .T.)
	
	DEFAULT lTipoRet	:= .T.
	DEFAULT BrowX1 		:= "Selecione"
	DEFAULT aOpcoes		:= {}
	
	IF LEN(aOpcoes) == 0
		Return
	ENDIF
	
	cAlias 			:= Alias() 					 // Salva Alias Anterior
	
	IF lTipoRet
		MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIF
	
	
	For nI := 1 To LEN(aOpcoes)
		
		aadd(aSit, aOpcoes[nI,1]+" - "+aOpcoes[nI,2])
		MvParDef += aOpcoes[nI,1]
	Next nI
	
	
	
	// Tamanho dos caracters de retorno (Ex.: 04)
	nTam := LEN(aOpcoes[1,1])
	lComboBox := .T.
	IF lTipoRet
		IF f_Opcoes(@MvPar,BrowX1,aSit,MvParDef,12,49,l1Elem,nTam)	// Chama funcao f_Opcoes
			&MvRet := mvpar                                   			// Devolve Resultado
		EndIF
	EndIF
	
	dbSelectArea(cAlias) 	 // Retorna Alias
	
	cFilAnt	:= cFilBack 	// Retorna a empresa
	
Return( IF( lTipoRet , .T. , MvParDef ) )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AUGUSTO RIBEIRO                                  ³
//³                                                  ³
//³ Recebe String separa por caracter "X"            ³
//³ ou Numero de Caractres para "quebra" _nCaracX)   ³
//³ Retorna String pronta para IN em selects         ³
//³ Ex.: Retorn: ('A','C','F')                       ³
//³                                                  ³
//³ PARAMETROS:  _cString, _cCaracX                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function INQuery(_cString, _cCaracX, _nCaracX)
	Local _cRet	:= ""
	Local _cString, _cCaracX, _nCaracX, nY
	Local _aString	:= {}
	Default	_nCaracX := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida Informacoes Basicas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !EMPTY(_cString) .AND. (!EMPTY(_cCaracX) .OR. _nCaracX > 0)
		
		nString	:= LEN(_cString)
		
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza Separacao por Numero de Caracteres ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF _nCaracX > 0
			FOR nY := 1 TO nString STEP _nCaracX
				
				AADD(_aString, SUBSTR(_cString,nY, _nCaracX) )
				
			Next nY
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Utiliza Separacao por caracter especifico ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ELSE
			_aString	:= WFTokenChar(_cString, _cCaracX)
		ENDIF
		
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta String para utilizar com IN em querys³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cRet	+=  "('"
		FOR _nI := 1 TO Len(_aString)
			IF _nI > 1
				_cRet	+= ",'"
			ENDIF
			_cRet += ALLTRIM(_aString[_nI])+"'"
		Next _nI
		_cRet += ") "
		
	ENDIF
	
Return(_cRet)

/*/{Protheus.doc} RFIN01I
Busca os impostos dos titulos
@author Jonatas Oliveira | www.compila.com.br
@since 27/09/2016
@version 1.0
/*/
Static Function RFIN01I()
	Local cQry 	:= ""
	Local aRet	:= {}	
	
	cQry += " SELECT E1_TIPO,E1_VALOR		 " +CRLF
	cQry += " FROM "+RetSqlName("SE1")+" E1   " +CRLF
	cQry += " WHERE E1.D_E_L_E_T_ 	= 	''        " +CRLF
	cQry += " 	AND E1_TITPAI 		= 	'"+ TSQL->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) +"'" +CRLF
	
	
	If Select("TSQLIM") > 0
		TSQLIM->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TSQLIM",.F., .T.)
	
	WHILE TSQLIM->(!EOF())
		AADD(aRet,{TSQLIM->E1_TIPO ,TSQLIM->E1_VALOR })
		
		TSQLIM->(DBSKIP())
	ENDDO 
	
	
Return (aRet)	


/*/{Protheus.doc} RFIN1NF
Busca o valor total da NF 
@author Jonatas Oliveira | www.compila.com.br
@since 27/09/2016
@version 1.0
/*/
Static Function RFIN1NF()
	Local cQry := ""
	
	cQry += " SELECT F2_VALFAT		 " +CRLF
	cQry += " FROM "+RetSqlName("SF2")+" SF2   " +CRLF
	cQry += " WHERE SF2.D_E_L_E_T_ 	= 	''        " +CRLF
	cQry += " 	AND F2_FILIAL = '"+ TSQL->E1_FILIAL +"' " +CRLF
	cQry += " 	AND F2_SERIE = '"+ TSQL->E1_PREFIXO +"' " +CRLF
	cQry += " 	AND F2_DOC = '"+ TSQL->E1_NUM +"' " +CRLF
	cQry += " 	AND F2_CLIENTE = '"+ TSQL->E1_CLIENTE +"' " +CRLF
	cQry += " 	AND F2_LOJA = '"+ TSQL->E1_LOJA +"' " +CRLF
	
	If Select("TSQLNF") > 0
		TSQLNF->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "TSQLNF",.F., .T.)
	
	IF  TSQLNF->(!EOF())
		nValNf := TSQLNF->F2_VALFAT
	ENDIF 	
	
Return(nValNf)