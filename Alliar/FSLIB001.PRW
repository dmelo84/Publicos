#Include 'Protheus.ch'
#Include "topconn.ch"

/*/{Protheus.doc} FSLIB001
LIB Generica. Neste fonte serão armazenadas as funções que podem ser utilizadas em mais de um módulo ou processo
a Função de nome FSLIB002 nunca será implementada.

@author claudiol
@since 09/12/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function FSLIB001()

Return


/*/{Protheus.doc} FSValQry
Verifica quantos registros existem na tabela com o codigo passado em parametro

@author claudiol
@since 11/04/2014
@version 1.0
@param cTabela, character, alias da tabela. Exemplo: "SB1"
@param aFiltro, array, array com campo e valor: Exemplo: "B1_LOCAL","01"
@return lRet, .T. se encontrou registros
@example
(examples)
@see (links_or_references)
/*/
User Function FSValQry(cTabela,aFiltro,cTabRef,lShowHelp)

Local aArea  := GetArea()
Local cTipo  := Iif(Left(cTabela,1)=="S",SubStr(cTabela,2),cTabela)
Local lRet   := .T.
Local cQuery := ""
Local nXi		:= 0
Local cMsgPro	:= ""
Local cMsgSol	:= ""
Local cAliTmp	:= GetNextAlias()

Default cTabRef:= ""
Default lShowHelp:= .T.

cQuery := "SELECT COUNT(*) NRECS FROM " + RetSqlName(cTabela) + " "
cQuery += "WHERE D_E_L_E_T_ = ' ' AND "

If FWModeAccess(cTabRef)=="E"
	cQuery += cTipo+"_FILIAL = '"+ xFilial(cTabela)+"' AND "
EndIf

For nXi:= 1 To Len(aFiltro)

	If ValType(aFiltro[nXi,2])=="C"
		cQuery += Alltrim(aFiltro[nXi,1])+ " = '"+ Alltrim(aFiltro[nXi,2]) + "' "
	ElseIf ValType(aFiltro[nXi,2])=="N"
		cQuery += Alltrim(aFiltro[nXi,1])+ " =  "+ Alltrim(Str(aFiltro[nXi,2])) + " "
	EndIf
	
	//Se tiver mais de um filtro e nao for o ultimo filtro, adiciona o "AND"
	If (Len(aFiltro)>1) .And. (Len(aFiltro)<>nXi)
		cQuery+= " AND "
	EndIf
	
Next nXi
                
cQuery := ChangeQuery(cQuery)

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliTmp,.F.,.T.)

If ((cAliTmp)->NRECS > 0)
	If lShowHelp 
		cMsgPro:= "Registro já está sendo utilizado na tabela "+cTabela+ " (" + Alltrim(U_FSX2Nome(cTabela)) + ") !"
		cMsgSol:= "Verifique a tabela "+cTabela+"."
		ShowHelpDlg("Registro já Utilizado",{cMsgPro},5,{cMsgSol},5)
	EndIf
	lRet:= .F.
Endif                                    

(cAliTmp)->(dbCloseArea())

RestArea(aArea)

Return(lRet)


/*/{Protheus.doc} FSOpenSM0
Abre arquivo de empresas

@type function
@author claudiol
@since 09/12/2015
@version 1.0
@param lShared, ${param_type}, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
User Function FSOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	//dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )
	OpenSM0()

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	ApMsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen


/*/{Protheus.doc} FSX2Nome
Retorna o nome da tabela passada em parametro

@author claudiol
@since 11/12/2014
@version 1.0
@param cAliasTab, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
User Function FSX2Nome(cAliasTab)

Local aAreAtu := {GetArea(),SX2->(GetArea())}
Local cNameTab:= ""

If Empty(cAliasTab)
	cAliasTab := Alias()
Endif

dbSelectArea("SX2")
dbSetOrder(1)
If MsSeek(cAliasTab,.F.)
	cNameTab := X2NOME()
Endif

aEval(aAreAtu, {|x| RestArea(x) })

Return(cNameTab)


/*/{Protheus.doc} FSRetSX3
Função auxiliar que retorna dados de um campo no SX3

@author claudiol
@since 24/12/2015
@version 1.0
@param cCampo, character, Nome do campo que deseja obter informações
@return aDados, Dados do campo 	[1] Título do campo. [2] Descrição do campo. [3] Tamanho do campo.	[4] Decimais do campo.	[5] Picture do campo.
@example FSRetSX3(cCampo)
/*/
User Function FSRetSX3( cCampo )

Local aArea	:= GetArea()
Local aDados	:= {}

DbSelectArea('SX3')		//Campos da tabela
SX3->( DbSetOrder(2) )	//X3_CAMPO
If ( SX3->( MsSeek( cCampo ) ) )
	AAdd( aDados, X3Titulo() )			//Retorna título do campo no X3
	AAdd( aDados, X3Descric() )			//Retorna descrição do campo no X3
	AAdd( aDados, TamSX3(cCampo)[1] )	//Retorna tamanho do campo
	AAdd( aDados, TamSX3(cCampo)[2] )	//Retorna quantidade de casas decimais do campo
	AAdd( aDados, X3Picture(cCampo) )	//Retorna a picture do campo
EndIf

RestArea( aArea )

Return aDados


/*/{Protheus.doc} FSOrdArr
Função para ordenar array usados em rotinas automáticas (SIGAAUTO)

@author claudiol
@since 06/01/2016
@version undefined
@param aArrOri, array,  Array no padrão exigido pelo SIGAAUTO
@param cAliasSx3, characters, Alias da Tabela a ser tratada no SIGAAUTO
@param lItem, logical, Indica se o array é de itens
@type function
/*/
User Function FSOrdArr(aArrOri,cAliasSx3,lItem)

Local aAreOld := {GetArea(),SX3->(GetArea())}
Local aArrRet	:= {}
Local nPos		:= 0
Local nXi		:= 0  

Local nX3CAMPO 		//:= FIELDPOS("X3_CAMPO")
Local nX3ARQUIVO	//:= FIELDPOS("X3_ARQUIVO")

Default lItem := .F.


DBSELECTAREA("SX3")
nX3CAMPO 	:= SX3->(FIELDPOS("X3_CAMPO"))
nX3ARQUIVO	:= SX3->(FIELDPOS("X3_ARQUIVO"))

If lItem
	For nXi := 1 To Len(aArrOri)
		U_FSOrdArr(@aArrOri[nXi],cAliasSX3,.F.)
	Next
Else
	
	SX3->(dbSetOrder(1))
	SX3->(dbSeek(cAliasSx3,.T.))
	While SX3->(!Eof()) .And. SX3->(FIELDGET(nX3ARQUIVO)) == cAliasSX3
	
		If (nPos:= aScan(aArrOri,{|x| Alltrim(x[1]) == Alltrim(SX3->(FIELDGET(nX3CAMPO))) })) <> 0
			aadd(aArrRet,aClone(aArrOri[nPos]))
		EndIf
	
		SX3->(dbSkip())
	EndDo 
	
	aArrOri := aClone(aArrRet)
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return Nil


/*/{Protheus.doc} FSExeAut
Executa EXECAUTO

@author claudiol
@since 06/01/2015
@version 1.0
@param cRotina, character, (Descrição do parâmetro)
@param nOption, numérico, (Descrição do parâmetro)
@param aCabec, array, (Descrição do parâmetro)
@param aItens, array, (Descrição do parâmetro)
@param cErrLog, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
User Function FSExeAut(cRotina,nOption,aCabec,aItens,cErrLog)

Local cBlock	:= ""
Local lRet		:= .T.

Private lMsHelpAuto:= .T.
Private lMsErroAuto:= .F.

Default aCabec:= {}
Default aItens:= {}

// Monto a rotina automática do processo
If cRotina=="MATA120"
	cBlock := "{|| MSExecAuto({|a,b,c,d|"+cRotina+"(a,b,c,d)},1,aCabec,aItens,"+cValToChar(nOption)+")}"
Else
	cBlock := "{|| MsExecAuto({|x, y, z|"+cRotina+"(x, y, z)},aCabec,"				
	
	If !Empty(aItens)
		cBlock += " aItens, "+cValToChar(nOption)+")}"
	Else
		cBlock += ", "+cValToChar(nOption)+")}"
	EndIf
EndIf

// Executo a rotina automática
Eval(&(cBlock))

If lMsErroAuto
	lRet:= .F.
	cErrLog:= MemoRead(NomeAutoLog())
	Ferase(NomeAutoLog())
EndIf	

Return(lRet)


/*/{Protheus.doc} FSGrvReg
Função usada para gravacao de registros em tabelas

@author claudiol
@since 02/03/2016
@version undefined
@param aDados, array, Vetor com informações de campos e valores {campo, valor}
@param lModo, logical, Informa o modo de travacao, T=Novo registro, F=Alteracao
@param cAlias, characters, Nome da tabela a ser modificada
@param nRecno, numeric, Recno do registro
@param lExclui, logical, Define se é exclusão
@type function
/*/
User Function FSGrvReg(aDados,lModo,cAlias,nRecno,lExclui)

Local aAreAtu 	:= {GetArea()} //Salva todas as areas num array
Local nXi		:= 0
Local	lRet		:= .T.
Local nPosCmp	:= 0

Default aDados	:= {}
Default lModo	:= .T.
Default cAlias	:= Alias()
Default nRecno	:= 0
Default lExclui:= .F.

If (lRet:=(cAlias)->(RecLock(cAlias,lModo)))
	If !lExclui
		For nXi:=1 To Len(aDados)
			If (nPosCmp:=(cAlias)->(FieldPos(aDados[nXi][1])) ) > 0
				//Verifica se o tipo de dado a ser gravado é o mesmo do campo
				If ValType((cAlias)->(FieldGet(nPosCmp)))==ValType(aDados[nXi][2])		
					(cAlias)->(FieldPut(nPosCmp,aDados[nXi][2]))
				EndIf
			EndIf
		Next nXi
		nRecno:= (cAlias)->(Recno())
	Else
		(cAlias)->(dbDelete())
	EndIf  
   (cAlias)->(MsUnlock())
EndIf

aEval(aAreAtu, {|x| RestArea(x) }) // restaurando todas as areas dentro do array.

Return(lRet)




/*/{Protheus.doc} FSMosTxt
Mostra texto em janela.

@author claudiol
@since 06/01/2016
@version undefined
@param cTitulo, characters, titulo da janela
@param cTexto, characters, texto a ser apresentado
@param aLog, array, array com logs
@param lButImp, logical, inibi botao de imprimir
@param lButSal, logical, inibi botao de salvar
@type function
/*/
User Function FSMosTxt(cTitulo, cTexto, aLog, lButImp, lButSal)

Local oDlg, oMemo, oButton1, oButton2, oButton3
Local oFont	:= TFont():New("Mono AS",,-13,.T.)
Local bGrvLog	:= {|| cFile := cGetFile( 'Log |*.Log|' , 'Arquivos de Log', 1, 'C:\', .F., GETF_LOCALHARD,.T., .T. ), FSalvaLog(aLog,cFile) }
Local aPosBut	:= {155,205,255}
Local nXi		:= 0
Local cMenPad := CRLF + "*** MENSAGEM ULTRAPASSOU 1MB ***"
Local nTamLin	:= 140

Default cTitulo:= ".: Ocorrências :."
Default cTexto	:= Space(100)
Default aLog		:= {}
Default lButImp	:= .T.
Default lButSal	:= .T.

If !Empty(aLog)
	//Converte aLog em cTexto
	For nXi:= 1 to Len(aLog)
		If (Len(cTexto) + Len(aLog[nXi])) >= (1024*1024)+1
			cTexto+= Left(cTexto, Len(cTexto) - Len(cMenPad)) + cMenPad
			Exit
		EndIf
		cTexto += aLog[nXi] + CRLF
	Next
Else
	//Converte cTexto em aLog
    For nXi := 1 To MLCount(cTexto,nTamLin)
		If !Empty(MemoLine(cTexto,nTamLin,nXi))
			Aadd(aLog,MemoLine(cTexto,nTamLin,nXi))
       EndIf
    Next nXi
EndIf

If !lButImp
	aPosBut:= {205,155,255}
EndIf

oDlg:= MSDIALOG():New(3, 0, 340, 667, cTitulo,,,,,,,,,.T.)
oDlg:LEscClose 	:= .F.   //Nao Permitir fechar a janela pelo ESC do teclado 

oMemo:= tMultiget():New(05,05,{|u|if(Pcount()>0,cTexto:=u,cTexto)},oDlg,325,145,,,,,,.T.,,,,,,.T.)

oButton1:=tButton():New(153,aPosBut[1],'&Salvar'	,oDlg,{||Eval(bGrvLog)},40,10,,,,.T.)
oButton2:=tButton():New(153,aPosBut[2],'&Imprimir',oDlg,{|| U_FSImpLog(aLog,Funname())},40,10,,,,.T.)
oButton3:=tButton():New(153,aPosBut[3],'&Fechar'	,oDlg,{||oDlg:End()},40,10,,,,.T.)

If !lButImp
	oButton2:lVisibleControl:= .F.
EndIf

If !lButSal
	oButton1:lVisibleControl:= .F.
EndIf

oMemo:EnableVScroll(.T.)
oMemo:EnableHScroll(.T.)
oMemo:lWordWrap:= .T.
oMemo:oFont:=oFont

oDlg:lCentered := .T.
oDlg:Activate()

Return


/*/{Protheus.doc} FSalvaLog
Salva em arquivo o log

@author claudiol
@since 05/06/2014
@version 1.0
@param aLogs, array, (Descrição do parâmetro)
@param cFile, character, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function FSalvaLog(aLogs,cFile)

Local 	nHandle	:= 0  
Local 	nX 		:= 0
Local 	cLin 		:= ""

If(File(cFile)) .And. (MessageBox("O arquivo já existe, deseja substituí-lo?","",4)==6)
	FErase(cFile) 
EndIf

nHandle:= FCreate(cFile)	
   
For nX:= 1 to Len(aLogs)
	cLin := aLogs[nX] + chr(13) + chr(10)
	FWrite (nHandle,cLin )
Next

FClose(nHandle)

Return 


/*/{Protheus.doc} FSImpLog
Imprime log

@author claudiol
@since 06/01/2016
@version undefined
@param aLogs, array, array com log
@param cRotina, characters, rotina atual
@type function
/*/
User Function FSImpLog(aLogs,cRotina)

Local oReport

//If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
	oReport := ReportLog(aLogs,cRotina)
	oReport:PrintDialog()	
//EndIf

Return Nil


/*/{Protheus.doc} ReportLog
Definicao relatorio de log de ocorrencias

@author claudiol
@since 06/01/2016
@version undefined
@param aLogs, array, descricao
@param cRotina, characters, descricao
@type function
/*/
Static Function ReportLog(aLogs,cRotina)

Local 	oReport
Local 	oSection1
Local 	oTotal
Local	cAliTr1:= GetNextAlias()
Local	nTamLin:= 140

oReport := TReport():New(cRotina,"Relação de Logs",,{|oReport| PrintReport(oReport,aLogs, cAliTr1, nTamLin)},"Relação de Logs de Divergências")

oSection1 := TRSection():New(oReport,"Ocorrências")

TRCell():New(oSection1,"XX_DESCRI",cAliTr1,"Ocorrências","@!",nTamLin,/*lPixel*/,/*{|| codblock de impressao }*/)

//Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 09

Return(oReport)


/*/{Protheus.doc} PrintReport
Impressao do relatorio

@author claudiol
@since 06/01/2016
@version undefined
@param oReport, object, descricao
@param aLogs, array, descricao
@param cAliTr1, characters, descricao
@param nTamLin, numeric, descricao
@type function
/*/
Static Function PrintReport(oReport,aLogs, cAliTr1, nTamLin)

Local oSection1 := oReport:Section(1)
Local aCampos	  := {}
Local oTempTable
Local nXi       := 0
Local nXy       := 0



//Criação do objeto

oTempTable := FWTemporaryTable():New( cAliTr1 )

//|Define os campos da tabela temporária.

Aadd(aCampos,{"XX_DESCRI" ,"C",nTamLin,0})

oTemptable:SetFields(aCampos)

//Criação da tabela

oTempTable:Create()

//Atualiza arquivo de trabalho
For nXi:= 1 To Len(aLogs)
    For nXy := 1 To MLCount(aLogs[nXi],nTamLin)
		If !Empty(MemoLine(aLogs[nXy],nTamLin,nXy))

			(cAliTr1)->(DBAppend())
			(cAliTr1)->XX_DESCRI:= MemoLine(aLogs[nXi],nTamLin,nXy)
			(cAliTr1)->(DBCommit())
									
       EndIf
    Next nXy
Next nXi

//Impressao
oReport:SetMeter(RecCount())
oSection1:Init()

(cAliTr1)->(dbGotop())
While !(cAliTr1)->(Eof())

	oReport:IncMeter()

	If oReport:Cancel()
		Exit
	EndIf

	oSection1:PrintLine()

	(cAliTr1)->(dbSkip())
EndDo

oSection1:Finish()

//Fecha arquivo de trabalho
(cAliTr1)->(dbCloseArea())

oTempTable:Delete() 

Return


/*/{Protheus.doc} FSISDIGIT
Trata string deixando somente números

@author claudiol
@since 06/01/2016
@version undefined
@param cParam, characters, descricao
@type function
/*/
User Function FSISDIGIT(cParam)

Local cRet	:= ""
Local nXi	:= 0

For nXi:= 1 To Len(cParam)
	cRet+= Iif(ISDIGIT(SubStr(cParam,nXi,1)), SubStr(cParam,nXi,1), "")
Next nXi

Return(cRet)


/*/{Protheus.doc} FSRetVal
Retorno conteudo do campo no array padrao SIGAAUTO passado em parametro.

@author claudiol
@since 08/01/2016
@version undefined
@param aArray, array, Array para pesquisa (padrao sigaauto)
@param cCampo, characters, Campo a ser pesquisado no array
@type function
/*/
User Function FSRetVal(aArray,cCampo)

Local xRet
Local nPos:= 0

If (nPos:= aScan(aArray,{|x| Alltrim(x[1]) == Alltrim(cCampo)})) <> 0
	xRet := aArray[nPos,2]
EndIf

Return(xRet)


/*/{Protheus.doc} FSSetVal
Seta valor no array (padrao SIGAAUTO) passado como parametro

@author claudiol
@since 08/01/2016
@version undefined
@param aArray, array, Array padrao SIGAAUTO a ser atualizado
@param cCampo, characters, Nome do campo
@param cConteudo, characters, Conteudo a ser atualizado
@type function
/*/
User Function FSSetVal(aArray,cCampo,cConteudo)

Local nPos:= 0

If (nPos:= aScan(aArray,{|x| Alltrim(x[1]) == Alltrim(cCampo)})) <> 0
	aArray[nPos,2]:= cConteudo
EndIf

Return


/*/{Protheus.doc} FSGerSeq
Gera Sequencial no formato ano e sequencia

@author claudiol
@since 11/01/2016
@version undefined
@param cAlias, characters, Alias da tabela a ser pesquisada
@param nIndice, numeric, Indice da tabela a ser pesquisada
@param cOrdNick, characters, Nickname caso o indice seja customizado
@param cNomCmp, characters, Nome do campo
@param nTamSeq, numeric, Tamanho da sequencia
@type function
/*/
User Function FSGerSeq(cAlias,nIndice,cOrdNick,cNomCmp,nTamSeq)

Local		aAreOld	:= {(cAlias)->(GetArea()),GetArea()}
Local 	cNumSeq	:= ""
Local 	cSeqOld	:= ""
Local 	cAnoSeq	:= ""
Local 	cAnoOld	:= ""
Local 	cAnoAtu	:= Strzero(Year(dDataBase),4)
Local		cSeqIni	:= Strzero(0,nTamSeq)
Local		cPreTab	:= Iif(Left(cAlias,1)=='S',SubStr(cAlias,2,Len(cAlias)),cAlias)

//Busca Ultima Sequencia
If !Empty(nIndice)
	(cAlias)->(dbSetOrder(nIndice))
Else
	(cAlias)->(dbOrderNickName(cOrdNick))
EndIf

//Localiza o primeiro registro posterior
(cAlias)->(dbSeek(xFilial(cAlias)+Soma1(cAnoAtu),.T.))
//Posiciona no registro anterior
(cAlias)->(dbSkip(-1))

//Trata filial
If (xFilial(cAlias)==(cAlias)->&(cPreTab+'_FILIAL'))
	cSeqOld:= (cAlias)->&(cNomCmp)
Else
   cSeqOld:= cSeqIni
EndIf
cAnoOld:= Left(cSeqOld,4)

//Avalia virada de ano
cNumSeq:= Iif((cAnoOld==cAnoAtu), cSeqOld, cAnoAtu+cSeqIni)

While .T.
	//Incrementa sequencia
	cNumSeq:= Soma1(cNumSeq)

	//Avalia se sequencia nao esta reservado
	If	MayIUseCode(cEmpAnt+cAlias+xFilial(cAlias)+cNumSeq)
		Exit
	EndIf
EndDo	

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return(cNumSeq)


/*/{Protheus.doc} FVerPwd
Valida login e senha do usuario

@type function
@author Alex Teixeira de Souza
@since 08/01/2016
@version 1.0
@param cUsuario, character, Login Usuario
@param cPassword, character, Senha Usuario
@example
(examples)
@see (links_or_references)
/*/
User Function FVerPwd(cUsuario,cPassword)
Local lRet := .T.
Local cUsuInt	:= SuperGetMV("FS_USUINT", ,"integrador")
Local cSenInt	:= SuperGetMV("FS_PSWINT", ,"integrador@1234") 	

	If !(Upper(Alltrim(cUsuInt)) == Upper(Alltrim(cUsuario)) 	.and. Upper(Alltrim(cSenInt)) == Upper(Alltrim(cPassword))) 
		lRet := .f.
	Endif	

		/*
      	//Valida usuario existe
      	PswOrder(2)
      	If !PswSeek(cUsuario, .T.) // Verifica se o usuario é valido
            lRet := .f.
      	Else
            If !PswName(cPassword) // Verifica se a senha é valida para o usuário
                  lRet := .f.
            Endif
      	Endif             
		*/
Return(lRet)      


/*/{Protheus.doc} FSSetFil
Rotina que busca o código da filial.
@type function
@author gustavo.barcelos
@since 13/01/2016
@version 1.0
@param cCnpjFil, character, CNPJ da filial
@example
(examples)
@see (links_or_references)
/*/
User Function FSSetFil(cCnpjFil, cCodEmp, cCodFil)

	Local cCodFil := ""
	Local aArea	:= GetArea()
	
	If Select("SM0")==0
		If U_FSOpenSM0(.T.)
			
			SM0->(DbGoTop())
			While !SM0->(EOF())
				If AllTrim(SM0->M0_CGC) == cCnpjFil
					cCodFil := SM0->M0_CODFIL
					cCodEmp := SM0->M0_CODIGO
					Exit
				EndIf
				SM0->(DbSkip())
			EndDo
			
		EndIf
	Else
		SM0->(DbGoTop())
		While !SM0->(EOF())
			If AllTrim(SM0->M0_CGC) == cCnpjFil
				cCodFil := SM0->M0_CODFIL
				cCodEmp := SM0->M0_CODIGO
				Exit
			EndIf
			SM0->(DbSkip())
		EndDo
	EndIf
	
	RestArea(aArea)

Return


/*/{Protheus.doc} FSCnvVlr
Funcao para converter valores, conforme o dicionario de dados
        
@author 	Leandro de Faria
@since 		09/12/2014
@version 	P11
@param		cCampo, character, Campo para comparacao
@param    	xValor, variavel, Valor a ser convertido
@param		lConDat, logico, Indica se a data sera convertida para o formato DD/MM/AAAA
@return	xConverte - Valor convertido
@obs  		Lib

/*/        
User Function FSCnvVlr(cCampo,xValor,lConDat)

Local xConverte 	:= Nil
Local aGetCmp		:= Separa(cCampo,"_")

Default lConDat 	:= .T.

Do Case
						
	//Converte para Numerico
	Case (Len(aGetCmp) == 2 .And. TamSx3(cCampo)[3] == "N")
						
		//Converte o valor para numerico
		xConverte := Val(xValor)
						
	//Converte para data
	Case (Len(aGetCmp) == 2 .And. TamSx3(cCampo)[3] == "D")	
			
		//Converte o valor para data
		If (lConDat)
			xConverte := Iif(!Empty(AllTrim(xValor)),SToD(xValor),"")
		Else
			xConverte := Iif(!Empty(AllTrim(xValor)),xValor,"")
		EndIf	
	
	//Converte para String		
	Case (Len(aGetCmp) == 2 .And. TamSx3(cCampo)[3] == "C")	.OR. (cCampo == "A1_COD_MUN")
	
		//Converte o valor para String
		xConverte := PadR(xValor,TamSx3(cCampo)[1])
		xConverte := Upper(xConverte)
		xConverte := FwNoAccent(xConverte)
		
	Case (Len(aGetCmp) == 2 .And. TamSx3(cCampo)[3] == "M")
	
		//Converte o valor para String
		xConverte := xValor	
				
EndCase

Return (xConverte)


/*/{Protheus.doc} FSCustoFil
Rotina responsável pelo Centro de Custo da Filial cadastrado no campo CTT_XFIL.
@type function
@author gustavo.barcelos
@since 04/02/2016
@version 1.0
@param cFil, character, Filial a ser buscada.
@return cCusto, Centro de Custo correspondente a esta filial.
/*/

User Function FSCustoFil(cCnpjFil)

	Local aArea  := GetArea()
	Local cCusto := ""
	Local cQuery := ""
	
	cQuery := " SELECT CTT_CUSTO, CTT_XEMPFI FROM "+RetSqlName("CTT")+" "
	cQuery += "	WHERE CTT_XEMPFI = '" + cCnpjFil + "' "
	cQuery += " 	AND D_E_L_E_T_ = '' "
	
	TCQUERY cQuery NEW ALIAS "QRY"	
	DbSelectArea("QRY")
	QRY->(DBGoTop())
	
	cCusto := QRY->CTT_CUSTO
	
	QRY->( DBCloseArea() )
	
	RestArea(aArea)

Return cCusto


/*/{Protheus.doc} FSMudFil
Funcao para alterar a filial corrente

@author claudiol
@since 19/02/2016
@version undefined
@param cFilNew, characters, descricao
@type function
/*/
User Function FSMudFil(cFilNew)

//Troca a filial
cFilAnt := cFilNew
SM0->(dbSetOrder(1))
SM0->(dbSeek(cEmpAnt+cFilNew))

Return Nil


/*/{Protheus.doc} FSCalInt
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
User Function FSCalInt(dDatIni,dDatFin,cHorIni,cHorFin)

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
EndIf

//Formata o total de horas para o formato de horas
cRet:= cValToChar(cRet)
cRet:= Strtran(cRet,".",":")

If (At(":",cRet) <> 0)
	cRet+= Repl("0", (5 - Len(cRet)))
Else
	cRet+= ":00"
EndIf

Return(cRet)


/*/{Protheus.doc} FSTraExe
Controle para travar e destravar rotina para ser executada somente 1 vez

@author claudiol
@since 01/03/2016
@version undefined
@param nHdlLock, numeric, Identificador interno para o arquivo de trava
@param cNomArq, characters, Nome Arquivo a ser gerado com extensao .L01 onde 01 empresa
@param lTrava, logical, Avalia se a rotina sera para travar ou destravar
@param lManual, logical, Avalia se a rotina esta sendo executada Manualmente ou Automatico
@type function
/*/
User Function FSTraExe(nHdlLock, cNomArq, lTrava, lManual)

Local lRet		:= .F.
Local cNomUsu	:= Iif(Type("cUserName")<>"U", cUserName, "JOB")

Default lTrava	:= .F.
Default lManual:= .T.

If lTrava

	// Nao permite o acesso simultaneo … rotina por mais de 1 usuario.
	IF ( nHdlLock := MSFCREATE(cNomArq+".L"+cEmpAnt)) < 0
		If lManual
			ApMsgAlert("A rotina esta sendo utilizada por outro usuário."+CRLF+;
						"Por questões de integridade de dados, não é permitida"+CRLF+;
						"a utilização desta rotina por mais de um usuário simultaneamente."+CRLF+;
						"Tente novamente mais tarde.","::Atenção::")
		else
			//ConOut("** A rotina esta sendo utilizada por outro usuário **" + DtoC(Date()) + " as " + Time() + "Hrs")
		EndIf
		lRet:= .T.
	Endif
	
	//Grava no semaforo informações sobre quem está utilizando
	FWrite(nHdlLock,"Operador: "+cNomUsu+CRLF+;
					"Empresa.: "+cEmpAnt+CRLF+;
					"Filial..: "+cFilAnt+CRLF)

else

	If nHdlLock > -1
		fclose(nHdlLock)
		Ferase(cNomArq+".L"+cEmpAnt)
	Endif
	
EndIf

Return(lRet)


/*/{Protheus.doc} FSCnvXML
Gera array a partir de XML
	
@author Claudio Luiz da Silva
@since 17/09/2013
@version 1.0		

@param aArray, array, (Descrição do parâmetro)
@param nDesloc, numérico, (Descrição do parâmetro)

@return cXML, xml criado
/*/
User Function FSCnvXML(aArray,nDesloc)

Local cXml		:= ""
Local cTag		:= Alltrim(aArray[1])
Local cCampo	:= UPPER(Alltrim(aArray[2]))
Local bBloco 	:= aArray[3]
Local xValor	:= Nil
Local nTam		:= 0
Local nDec		:= 0
Local cTipo	:= Nil
Local cMask	:= Nil
Local lTagIn	:= .T.
Local lTagFim	:= .T.
Local lQuebra	:= .T.
Local cAtrib	:= Nil
Local lAcento	:= .F.
Local lDiopsfi	:= .F.
Local lCasSens	:= .F.

//Avalia a existencia do campo na area atual
If !Empty(cCampo)
	cAliAux:= FWTabPref(cCampo)
	If (cAliAux)->(FieldPos(cCampo)) <> 0
		xValor := &(cAliAux+'->'+cCampo)
	EndIf
	nTam	:= TamSX3(cCampo)[1]
	nDec	:= TamSX3(cCampo)[2]
	cTipo	:= TamSX3(cCampo)[3]
EndIf

If !Empty(bBloco)
	xValor := Eval(&bBloco, xValor)
	nTam	:= Nil
	nDec	:= Nil
	cTipo	:= ValType(xValor)
EndIf

//Converte tipo data para string DD/MM/AAAA
If cTipo=="D"
	nTam:= 10
	nDec:= 0
	cTipo:="C"
	xValor:= Dtoc(xValor)
EndIf

cXml:= MontaXML(cTag,xValor,cTipo,nTam,nDec,cMask,nDesloc,lTagIn,lTagFim,lQuebra,cAtrib,lAcento,lDiopsfi,lCasSens)

/*
Descri‡ao ³Funcao para retornar a linha em formato XML (tags)
Retorno   ³ExpC1 : linha em xml     
                         
Parametros³ExpC1 : Tag a ser apresentada   				    
          ³ExpC2 : Campo a ser apresentado na Tag (conteudo) 
          ³ExpC3 : Tipo do campo                             
          ³ExpN4 : Tamanho do campo                          
          ³ExpN5 : Decimais do campo                         
          ³ExpC6 : Mascara do campo                          
          ³ExpN7 : Deslocamento inicial da tag (identacao)   
          ³ExpL8 : Se apresenta a Tag inicial <>             
          ³ExpL9 : Se apresenta a Tag final </>              
          ³ExpLA : Se inclui a quebra de linha chr(13) + chr(10)
          ³ExpLB : Atributo de TAG                              
          ³ExpLC : Se apresenta Tag caracter com acentos        
          ³ExpLD : Se é Diopsfin                                
          ³ExpLE : Se considera case sensitive                  
*/

Return(cXml)
