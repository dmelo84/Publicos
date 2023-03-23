#INCLUDE "protheus.ch"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TOPCONN.CH"
#Include "rwmake.Ch"

#DEFINE EOL				chr(13)+chr(10) 
#DEFINE COD_EMPRESA 	"01"
                           

/*/{Protheus.doc} LTSX3DB
    Realiza alteração no banco de dados e SX3.
    altera somente campos presentes no ARRAY da Funcao
    @type  Function
    @author Augusto Ribeiro | Compila.com.br
    @since 09/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function ALDUPLIC()


cArqEmp     := "SigaMat.Emp"
__cInterNet := Nil

PRIVATE cMessage
PRIVATE aArqUpd	 := {}
PRIVATE aREOPEN	 := {}
PRIVATE oMainWnd 

Set Dele On

lEmpenho	:= .F.
lAtuMnu		:= .F.

DEFINE WINDOW oMainWnd FROM 0,0 TO 01,30 TITLE "Remove Duplicidades"
ACTIVATE WINDOW oMainWnd ON INIT UpdGPSTela()

Return


/*/{Protheus.doc} UpdGPSTela
    (long_description)
    @type  Static Function
    @author Augusto Ribeiro | Compila.com.br
    @since 09/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function UpdGPSTela()
Local oDlgUpd
Local cPath   	:= "Selecione diretório"
Local lOk		:= .F.
Local aEmpUpd	
Local cMsgAviso := ""
Private cDir	:= Space(500)


cMsgAviso += "Deseja efetuar a correcao ref. aos registros duplicados "+CRLF
cMsgAviso += "Somente serão alteradas tabelas previamente mapeadas"+CRLF
If !ApMsgNoYes(cMsgAviso, "Atenção")
	oMainWnd:End()
	Return
EndIf


DEFINE MSDIALOG oDlgUpd TITLE "Atualizacao Automatica" FROM 0,0 TO 205,452 OF oDlgUpd PIXEL

@ 06,06 TO 80,220 LABEL "" OF oDlgUpd PIXEL

@ 10,10 SAY "Deseja efetuar a correcao ref. aos registros duplicados ?"  SIZE  200, 8 PIXEL OF oDlgUpd
//@ 20,10 SAY "ATENCAO : Os arquivos devem estar no formato da configuracao atual "  SIZE  200, 8 PIXEL OF oDlgUpd
//@ 30,10 SAY "do server e o nome do arquivo deve estar atualizado (EX:sx3.DBF/DTC)"  SIZE  200, 8 PIXEL OF oDlgUpd
//@ 40,10 SAY "SX´s configurados: SX1, SX2, SX3, SIX, SX7, SX6, SXB e SXA         "  SIZE  200, 8 PIXEL OF oDlgUpd

//@ 55, 10 SAY "Pasta:"  SIZE  65, 8 PIXEL OF oDlgUpd
//@ 65, 10 MSGET cDir PICTURE "@!"           SIZE 180,10 PIXEL OF oDlgUpd
//@ 65,200 BUTTON "..."                      SIZE  13,13 PIXEL OF oDlgUpd ACTION cDir:=AllTrim(cGetFile(,cPath,,,.T.,128))

@ 085,140 BUTTON "&Ok"       SIZE 36,16 PIXEL ACTION (lOk:=.T.,oDlgUpd:End())
@ 085,180 BUTTON "&Cancelar" SIZE 36,16 PIXEL ACTION (lOk:=.F.,oDlgUpd:End())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MarkEmp = Monta Listmark para selecao das empresas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgUpd CENTER ON INIT aEmpUpd := MarkEmp()
                                                 
IF LEN(aEmpUpd) > 0 .AND. lOk

		
	   	Processa({|| DUPTAB(aEmpUpd)},"Atualização Automática","Aguarde , processando atualizacao de base de dados",.F.)	
        MSGINFO("Processamento concluido")
ENDIF

Return


/*/{Protheus.doc} SX3SXG
    (long_description)
    @type  Static Function
    @author user
    @since 09/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function DUPTAB(aEmpUpd)
Local aAnalis   := {}
Local nI, _cEmp, _cFilial
Local aSigamat  := {}

Private _cFileLog	:= ""
Private _cLogPath	:= ""
Private _Handle		:= ""  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia Log ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
cpLogTxt(1)	


ProcRegua(len(aEmpUpd))
for nI := 1 to len(aEmpUpd)
    IncProc("Empresa "+aEmpUpd[nI,1])
//    _cEmp   := 

    PREPARE ENVIRONMENT EMPRESA aEmpUpd[nI,1] FILIAL aEmpUpd[nI,2]
        

		cpLogTxt(2, Replicate("-",40)+CRLF)		
		cpLogTxt(2, "EMPRESA: "+aEmpUpd[nI,1]+" FILIAL: "+aEmpUpd[nI,2]+" NOME: "+aEmpUpd[nI,3]+CRLF+CRLF)	        
        

        cLogEmp := Processa({|| updTab(aEmpUpd[nI,1])},"Empresa: "+aEmpUpd[nI,1],"Aguarde , processando atualizacao de base de dados",.F.)

    RESET ENVIRONMENT 
    
next
cpLogTxt(3)
    
Return()



/*/{Protheus.doc} updTab
    Realiza alteracao na SX3 e tabela no banco de dados
    @type  Static Function
    @author user
    @since 09/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function updTab(cCodEmp)
Local cLog  := ""
Local cStatus := ""
Local nQtdReg   := 0
Local aUpdDup   := {}
Local nPosEMP   := 0
Local nI, nY, lAux , cLog

#DEFINE POS_CAMPO 1
#DEFINE POS_TAMANHO 2


//| {cEmpresa,{cUpd1,cUpd2}}
//| *** EMPRESA 01 *****
aadd(aUpdDup,{"01",{}}) 
nPosEMP := LEN(aUpdDup)

cUpd := " UPDATE SE2010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
cUpd += " FROM SE2010  SE2 "
cUpd += " INNER JOIN (  "
cUpd += " 			SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA, MAX(R_E_C_N_O_) as SE2_RECNO "
cUpd += " 			FROM SE2010 SE2 "
cUpd += " 			WHERE SE2.D_E_L_E_T_ = '' "
cUpd += " 			GROUP BY E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA "
cUpd += " 			HAVING COUNT(*) > 1) A "
cUpd += " 		ON SE2.R_E_C_N_O_ = A.SE2_RECNO "

aadd(aUpdDup[nPosEMP,2],cUpd) //|  Upd a ser executado


FOR nI := 1 to len(aUpdDup)

    IF aUpdDup[nI,1] == cCodEmp
        cLog    := "EMPRESA: "+ cCodEmp+CRLF

        FOR nY := 1 to len(aUpdDup[nI,2])

            cUpdTab    := ""
            cUpdTab    := aUpdDup[nI,2,nY]

            nStatus := TCSqlExec(cUpdTab)

            if (nStatus < 0)
               cLog :=  "INSTRUCAO: "+cUpdTab+" | ERRO "+TCSQLError()
            ELSE
               cLog    :=  "INSTRUCAO: "+cUpdTab+" | SUCESSO "
            ENDIF            
            
            cpLogTxt(2, cLog)	
            cLog    := ""                          

        NEXT nY
    ENDIF
NEXT nI



Return(cLog)





/*/{Protheus.doc} DropConst
    Retorna nome da constraint do banco de dados.
    @type  Static Function
    @author user
    @since 09/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function DropConst(cTab, cCampo)
Local aRet      := {.F.,""}
Local cQuery    := ""
Local cConst    := ""
Local cUpdTab   := ""
Local nStatus

/*------------------------------
    BUSCA NOME DA CONSTRAINT
------------------------------*/
cQuery := ""
cQuery += " select oo.name AS CONSTR "+CRLF
cQuery += " from "+CRLF
cQuery += "     sysobjects o, "+CRLF
cQuery += "     syscolumns c, "+CRLF
cQuery += "     sysobjects oo "+CRLF
cQuery += " where "+CRLF
cQuery += "     o.id = object_id('"+SX2->X2_ARQUIVO+"') "+CRLF
cQuery += "     and o.id = c.id "+CRLF
cQuery += "     and c.name = '"+SX3->X3_CAMPO+"' "+CRLF
cQuery += "     and c.cdefault = oo.id "+CRLF
cQuery += "     and oo.parent_obj = o.id "+CRLF


If Select("TSQL") > 0
	TSQL->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						

IF TSQL->(!EOF())
	cConst    := TSQL->CONSTR

    cUpdTab := "ALTER TABLE dbo."+cTab+" DROP CONSTRAINT "+TSQL->CONSTR

    nStatus := TCSqlExec(cUpdTab)
   
    if (nStatus < 0)
        aRet[2] := "DROP CONSTRAINT TAB: "+cTab+" | "+TCSQLError()
    else 
        aRet    := {.T.,""}
    endif

ELSE
    aRet    := {.T.,""}
ENDIF	
TSQL->(DbCloseArea())

Return(aRet)



/*/{Protheus.doc} DropIndex
    Retorna nome da Index do banco de dados.
    @type  Static Function
    @author user
    @since 09/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function DropIndex(cTab, cCampo)
Local aRet      := {.F.,""}
Local cQuery    := ""
Local cConst    := ""
Local cUpdTab   := ""
Local nStatus

/*------------------------------
    BUSCA NOME DA INDEX
------------------------------*/
cQuery := ""
cQuery += " SELECT "+CRLF
cQuery += "     x.name as INDEXNAME, "+CRLF
cQuery += "     c.name as FIELDNAME "+CRLF
cQuery += " FROM "+CRLF
cQuery += "     sysindexes x, "+CRLF
cQuery += "     syscolumns c, "+CRLF
cQuery += "     sysindexkeys k "+CRLF
cQuery += " WHERE "+CRLF
cQuery += "     x.id = object_id('"+cTab+"') "+CRLF
cQuery += "     AND c.id = x.id "+CRLF
cQuery += "     AND k.id = x.id "+CRLF
cQuery += "     AND c.colid = k.colid "+CRLF
cQuery += "     AND k.indid = x.indid "+CRLF
cQuery += "     AND x.indid > 0 "+CRLF
cQuery += "     AND SUBSTRING(x.name, 1, 1) != '_' "+CRLF
cQuery += "     AND INDEXPROPERTY(x.id, x.name, 'IsStatistics') = 0 "+CRLF
cQuery += "     AND INDEXPROPERTY(x.id, x.name, 'IsAutoStatistics') = 0 "+CRLF
cQuery += "     AND c.name = '"+cCampo+"' "+CRLF
cQuery += " ORDER BY "+CRLF
cQuery += "     x.indid, "+CRLF
cQuery += "     k.keyno "+CRLF

If Select("TSQL") > 0
	TSQL->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						

IF TSQL->(!EOF())
    WHILE TSQL->(!EOF())
        cUpdTab := "DROP INDEX "+cTab+"."+TSQL->INDEXNAME

        nStatus := TCSqlExec(cUpdTab)
    
        if (nStatus < 0)
            aRet[2] := "DROP INDEX TAB: "+cTab+"."+TSQL->INDEXNAME+" | "+TCSQLError()
        else 
            aRet    := {.T.,""}
        endif

        TSQL->(DBSKIP())
    ENDDO
ELSE
    aRet    := {.T.,""}
ENDIF	
TSQL->(DbCloseArea())

Return(aRet)





/*/{Protheus.doc} AltTab
    Altera tabela no banco de dados e recria a constraint
    @type  Static Function
    @author user
    @since 09/07/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function AltTab(cTab, cCampo, nTam)
Local aRet      := {.F.,""}
Local cQuery    := ""
Local cConst    := ""
Local cUpdTab   := ""
Local nStatus, cErroUpd


cUpdTab := "ALTER TABLE dbo."+cTab+"  ALTER COLUMN "+cCampo+" VARCHAR("+alltrim(str(nTam))+") NOT NULL"
//|  ALTERA TAMANHO DOC CAMPO
nStatus := TCSqlExec(cUpdTab)

if (nStatus < 0)
    cErroUpd := "ALTER TABLE TAB: "+cTab+" | "+TCSQLError()
else 
    cConst  := ALLTRIM(cTab)+"_"+ALLTRIM(cCampo)+"_DF"
    cUpdTab := "ALTER TABLE dbo."+cTab+" ADD CONSTRAINT "+cConst+" DEFAULT '"+REPLICATE(' ',nTam)+"' FOR "+cCampo

    //|  INCLUI CONSTRAINT NOVAMENTE 
    nStatus := TCSqlExec(cUpdTab)

    if (nStatus < 0)
        aRet[2] := "ALTER TABLE ADD CONTRAINT TAB: "+cTab+" | "+TCSQLError()
    ELSE
        aRet[1]    := .T.
    ENDIF
endif

Return(aRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MyOpenSM0Ex³ Autor ³Sergio Silveira       ³ Data ³07/01/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua a abertura do SM0 exclusivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao FIS                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MyOpenSM0Ex(lSM0Compartilhado)

Local lOpen := .F. 
Local nLoop := 0 

For nLoop := 1 To 20
	If Select("SM0")>0
		dbSelecTArea("SM0")
		dbCloseArea()
	EndIf
	dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", lSM0Compartilhado, .F. ) 
	If !Empty( Select( "SM0" ) ) 
		lOpen := .T. 
		dbSetIndex("SIGAMAT.IND") 
		Exit	
	EndIf
	Sleep( 500 ) 
Next nLoop 

If !lOpen
	Aviso( "Atencao !", "Nao foi possivel a abertura da tabela de empresas de forma exclusiva !", { "Ok" }, 2 ) 
EndIf                                 

Return( lOpen ) 






/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MarkEmp  ºAutor  ³ Augusto Ribeiro	 º Data ³  23/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta ListMark para selecção das empresas                  º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MarkEmp()
Local aRet	:= {}  
Local nI
Private	lOk	:= .F. 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta List Solicitacao de Compras ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
Private oOk   	   	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Private oNo			:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Private aHeadEmp	:= {}       
Private aDadoEmp	:= {}
Private oLbxEmp		:= Nil    
Private oDlgEmp   
Private cTitulo  	:= "Update Projeto | WorkFlow Compras "
                           
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Dialog ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgEmp TITLE "Atualizacao Automatica" FROM 0,0 TO 305,452 OF oDlgEmp PIXEL

ListEmp("C",@oLbxEmp,@aHeadEmp, @aDadoEmp)  
                                     
                                     
@ 135,140 BUTTON "&Ok"       SIZE 36,16 PIXEL ACTION (lOk:=.T.,oDlgEmp:End())
@ 135,180 BUTTON "&Cancelar" SIZE 36,16 PIXEL ACTION (lOk:=.F.,oDlgEmp:End())                                     
                                           
ACTIVATE MSDIALOG oDlgEmp CENTERED //ON INIT Eval({ || EnChoiceBar(oDlg,bOKEmp,bCancEmp,.F.,aButtons) })


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Adiciona somente os codigos das empresas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lOk           
	For nI := 1 to Len(aDadoEmp)
		IF aDadoEmp[nI,1]
			AADD(aRet, {aDadoEmp[nI,2],aDadoEmp[nI,3],aDadoEmp[nI,4]})
		ENDIF
	Next nI
ELSE 
	aRet	:= {}
ENDIF


Return(aRet)





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ListLog  ºAutor  ³ Augusto Ribeiro	 º Data ³  10/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  List Log                                                  º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ListEmp(cOpcList, oLbxLog,aHeader, aDados)
Local lRet			:= .T.
Local cQuery		:= "" 
Local aCpoHeader
Local cBCodLin		:= "" 
Local nZ03IMAGE
Local nZ04DATA, nI 
Local cQuery    := ""


aCpoHeader	:= {} 
aHeader		:= {} 
aDados		:= {}



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
aHeader		:= {"", "Codigo", "Filial","Empresa"}
aCpoHeader	:= {"", "Codigo", "Filial","Empresa"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aDados ³

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "100001"

cQuery += " SELECT M0_CODIGO, MIN(M0_NOME) AS M0_NOME, MIN(M0_CODFIL) AS M0_CODFIL, MIN(M0_FILIAL) AS M0_FILIAL "+CRLF
cQuery += " FROM SYS_COMPANY  "+CRLF
cQuery += " WHERE D_E_L_E_T_  = '' "+CRLF
cQuery += " GROUP BY M0_CODIGO "+CRLF

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)



//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//DBSELECTAREA("SM0") 
//MyOpenSm0Ex(.F.)
//DBSELECTAREA("SM0")
//	dbUseArea(.T.,,"\system\sigamat.emp","TSM0",.F.)

WHILE TSQL->(!EOF())                                                     

	IF aScan(aDados,{|x| x[2] == TSQL->M0_CODIGO}) <= 0

		aLinha	:= {.F., TSQL->M0_CODIGO, TSQL->M0_CODFIL, alltrim(TSQL->M0_FILIAL)+"-"+TSQL->M0_NOME}
		
		AADD(aDados, aLinha)
	ENDIF
 	
	TSQL->(DBSKIP())
ENDDO   
               
RESET ENVIRONMENT	     
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ cOpcList | C = Cria, A = Atualiza ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF cOpcList == "C"
	
		@ 001,001 LISTBOX oLbxEmp FIELDS HEADER ;
		   " ", "Campos" ;                                                                                                    
		   SIZE 226, 130 OF oDlgEmp PIXEL ON dblClick( aDados[oLbxEmp:nAt,1] := !aDados[oLbxEmp:nAt,1] ,oLbxEmp:Refresh())
	ENDIF                                           
	
	
	oLbxEmp:aheaders := aHeader	
	oLbxEmp:SetArray( aDados )  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria string com Bloco de Codigo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	cBCodLin	:= "LoadBitmap( GetResources(), aDados[oLbxEmp:nAt,"+alltrim(str(nZ03IMAGE))+"] ) "
	cBCodLin	:= "Iif(aDados[oLbxEmp:nAt,1],oOk,oNo)"
	
	For nI := 2 To LEN(aHeader)
		IF nI > 1
			cBCodLin	+=", "
		endif
	   cBCodLin	+= "aDados[oLbxEmp:nAt,"+alltrim(str(nI))+"]"
	Next nI	
	
	cBCodLin	:= "oLbxEmp:bLine := {|| {"+cBCodLin+"}}"
	&(cBCodLin)


oLbxEmp:Refresh()

Return    







/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ cpGrvLog ºAutor  ³ Augusto Ribeiro	 º Data ³  24/04/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a Criação, Gravacao, Apresentacao do Log           º±±
±±º          ³                                                            º±±
±±ºPARAMETROS³ _nOpc : 1=Cria Arquivo, 2= Grava Log, 3 = Apresenta Log    º±±
±±º          ³ _cTxtLog : Log a ser gravado                               º±±
±±º          ³                                                            º±±
±±º*ATENCAO* ³ Necessario a criacao das variaveis como Private            º±±
±±º          ³ Private _cFileLog	 	:= ""                             º±±
±±º          ³ Private _cLogPath		:= ""                             º±±
±±º          ³ Private _Handle			:= ""                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function cpLogTxt(_nOpc, _cTxtLog)
Local _lRet	:= Nil
Local _nOpc, _cTxtLog  
Local cLogIni	:= ""
                                                                  
Default _nOpc		:= 0
Default _cTxtLog 	:= ""                                            

	Do Case
		Case _nOpc == 1
			//_cFileLog	 	:= Criatrab(,.F.)                        
			_cFileLog		:= "DVDUPOK_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","-")
			_cLogPath		:= "\"+_cFileLog+".txt"//AllTrim(GetTempPath())+_cFileLog+".txt"
			_Handle			:= FCREATE(_cLogPath,0)	//| Arquivo de Log		
			
			FWRITE (_Handle, cLogIni+EOL+_cTxtLog)
			
		Case _nOpc == 2                   
			IF !EMPTY(_cTxtLog)
				FWRITE (_Handle, _cTxtLog)
			ENDIF		
			
		Case _nOpc == 3
			
			cLogIni	:= REPLICATE("-",80)+EOL
			cLogIni	+= 'DATA - HORA........: ' + DtoC(Date())+" - "+Time()+EOL				
			cLogIni	+= "**** FIM ****"+EOL				
					
			FWRITE (_Handle, cLogIni+EOL+_cTxtLog)
            FCLOSE(_Handle)	      

			cPathTemp	:= GetTempPath(.T.)+_cFileLog+".txt"		
			__CopyFile(_cLogPath, cPathTemp)
			
			IF FILE(cPathTemp)
				WinExec("Explorer "+cPathTemp)
			ELSE		
				FwHelpShow(,"Arquivo inválido","Arquivo não encontrado.","Verifique se o arquivo realmente encontra-se em ["+cPathTemp+"]")
			ENDIF		
	 
            WinExec("Explorer "+cPathTemp)
	EndCase

Return(_lRet)

