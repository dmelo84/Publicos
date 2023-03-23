#INCLUDE "protheus.ch"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TOPCONN.CH"
#Include "rwmake.Ch"

#DEFINE EOL				chr(13)+chr(10) 
#DEFINE COD_EMPRESA 	"01"
                           

/*/{Protheus.doc} LTSXGDB
    Fun็ใo para corre็ใo automแtica do SXG para ambientes com Dicionแrio no Banco
    Verifica se existe diferen็a entre SX3 e SXG. 
    Caso exista direfenn็a tabela nao exista ou esteja vazia,
    realiza drop da tabela e corre็ใo SX3
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
User Function ALSXGDB()


cArqEmp     := "SigaMat.Emp"
__cInterNet := Nil

PRIVATE cMessage
PRIVATE aArqUpd	 := {}
PRIVATE aREOPEN	 := {}
PRIVATE oMainWnd 

Set Dele On

lEmpenho	:= .F.
lAtuMnu		:= .F.

DEFINE WINDOW oMainWnd FROM 0,0 TO 01,30 TITLE "Corre็ใo Automแtica SXG"
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
Local cPath   	:= "Selecione diret๓rio"
Local lOk		:= .F.
Local aEmpUpd	
Local cMsgAviso := ""
Private cDir	:= Space(500)


cMsgAviso += "Deseja efetuar a corre็ใo automแtica do SX3 x SXG ? "+CRLF
cMsgAviso += "Em caso de divergencia no SX3, caso a tabela nใo exista no banco, SX3 serแ ajustado conforme SXG"+CRLF
cMsgAviso += "Caso a tabela exista mas nใo possua registros, drop da tabela serแ realizado e ajuste no SX3"+CRLF
If !ApMsgNoYes(cMsgAviso, "Aten็ใo")
	oMainWnd:End()
	Return
EndIf


DEFINE MSDIALOG oDlgUpd TITLE "Atualizacao Automatica" FROM 0,0 TO 205,452 OF oDlgUpd PIXEL

@ 06,06 TO 80,220 LABEL "" OF oDlgUpd PIXEL

@ 10,10 SAY "Deseja efetuar a corre็ใo automแtica do SX3 x SXG ?"  SIZE  200, 8 PIXEL OF oDlgUpd
//@ 20,10 SAY "ATENCAO : Os arquivos devem estar no formato da configuracao atual "  SIZE  200, 8 PIXEL OF oDlgUpd
//@ 30,10 SAY "do server e o nome do arquivo deve estar atualizado (EX:sx3.DBF/DTC)"  SIZE  200, 8 PIXEL OF oDlgUpd
//@ 40,10 SAY "SXดs configurados: SX1, SX2, SX3, SIX, SX7, SX6, SXB e SXA         "  SIZE  200, 8 PIXEL OF oDlgUpd

//@ 55, 10 SAY "Pasta:"  SIZE  65, 8 PIXEL OF oDlgUpd
//@ 65, 10 MSGET cDir PICTURE "@!"           SIZE 180,10 PIXEL OF oDlgUpd
//@ 65,200 BUTTON "..."                      SIZE  13,13 PIXEL OF oDlgUpd ACTION cDir:=AllTrim(cGetFile(,cPath,,,.T.,128))

@ 085,140 BUTTON "&Ok"       SIZE 36,16 PIXEL ACTION (lOk:=.T.,oDlgUpd:End())
@ 085,180 BUTTON "&Cancelar" SIZE 36,16 PIXEL ACTION (lOk:=.F.,oDlgUpd:End())

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ MarkEmp = Monta Listmark para selecao das empresas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
ACTIVATE MSDIALOG oDlgUpd CENTER ON INIT aEmpUpd := MarkEmp()
                                                 
IF LEN(aEmpUpd) > 0 .AND. lOk

		
	   	Processa({|| SX3SXG(aEmpUpd)},"Atualiza็ใo Automแtica","Aguarde , processando atualizacao de base de dados",.F.)	
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
Static Function SX3SXG(aEmpUpd)
Local aAnalis   := {}
Local nI, _cEmp, _cFilial
Local aSigamat  := {}

Private _cFileLog	:= ""
Private _cLogPath	:= ""
Private _Handle		:= ""  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicia Log ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู
cpLogTxt(1)	

If 	Upper(Alltrim(GetSrvProfString("LOCALFILES", ""))) == "DBF" .OR. Upper(Alltrim(GetSrvProfString("LOCALFILES", ""))) == "ADS"
	cExtensao := "*.DBF"
ElseIf 	 "CTREE" $ Upper(Alltrim(GetSrvProfString("LOCALFILES", "")))
	cExtensao := "*.DTC"
EndIf


ProcRegua(len(aEmpUpd))
for nI := 1 to len(aEmpUpd)
    IncProc("Empresa "+aEmpUpd[nI,1])
//    _cEmp   := 

    PREPARE ENVIRONMENT EMPRESA aEmpUpd[nI,1] FILIAL aEmpUpd[nI,2]
        

		cpLogTxt(2, Replicate("-",40)+CRLF)		
		cpLogTxt(2, "EMPRESA: "+aEmpUpd[nI,1]+" FILIAL: "+aEmpUpd[nI,2]+" NOME: "+aEmpUpd[nI,3]+CRLF+CRLF)	        
        

        cLogEmp := Processa({|| updSX3(aEmpUpd[nI,1])},"Empresa: "+aEmpUpd[nI,1],"Aguarde , processando atualizacao de base de dados",.F.)

    RESET ENVIRONMENT 
    
next
cpLogTxt(3)
    
Return()



/*/{Protheus.doc} updSX3
    Verifica SX3 x SXG, realiza ajuste (se possivel) e retorna log da execu็ใo
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
Static Function updSX3(cCodEmp)
Local cLog  := ""
Local cStatus := ""
Local nQtdReg   := 0

cLog    += PADR("CPOSX3", 12)+"|"
cLog    += PADR("TAMSX3", 7)+"|"
cLog    += PADR("CODSXG", 7)+"|"
cLog    += PADR("TAMSXG", 7)+"|"
cLog    += PADR("STATUS", 30)




DBSELECTAREA("SX2")
SX2->(DBSETORDER(1)) //| X2_CHAVE
SX2->(DbGoTop())


DBSELECTAREA("SXG")
SXG->(DBSETORDER(1)) //| XG_GRUPO
SXG->(DbGoTop())

DBSELECTAREA("SX3")
SX3->(DBSETORDER(1))
SX3->(DbGoTop())
ProcRegua(RecCount())
WHILE SX3->(!EOF())
    IncProc(SX3->X3_CAMPO)

    IF !EMPTY(SX3->X3_GRPSXG)

        SXG->(DbGoTop())
        IF SXG->(DBSEEK(SX3->X3_GRPSXG))
            if SXG->XG_SIZE <> SX3->X3_TAMANHO
                cLog    += CRLF
                cLog    += PADR(SX3->X3_CAMPO, 12)+"|"
                cLog    += PADR(STRZERO(SX3->X3_TAMANHO,3), 7)+"|"
                cLog    += PADR(SX3->X3_GRPSXG,7)+"|"
                cLog    += PADR(STRZERO(SXG->XG_SIZE,3), 7)+"|"
                //cLog    += PADR("STATUS", 30)
                cStatus := ""
                
                lAltSX3 := .F.

                SX2->(DbGoTop())
                IF SX2->(DBSEEK(SX3->X3_ARQUIVO))
                    //| Verifica se o objeto existe no banco de dados
                    IF TCObject( SX2->X2_ARQUIVO ) 
                        nQtdReg := ValidReg(SX2->X2_ARQUIVO)
                        if nQtdReg == 0
                            cStatus  := "TAB. "+SX2->X2_ARQUIVO+" VAZIA. "
                            IF TCDelFile( SX2->X2_ARQUIVO )
                                cStatus  += "DROP. REALIZADO COM SUCESSO. "
                                CONOUT("U_LTSXGDB - DROP. ["+SX2->X2_ARQUIVO+"]REALIZADO COM SUCESSO. ")
                            ENDIF
                            lAltSX3 := .T.
                        ELSE                        
                            cStatus  := "TAB. "+SX2->X2_ARQUIVO+" COM REGISTROS ["+ALLTRIM(STR(nQtdReg))+"]. "
                        ENDIF
                    ELSE
                        cStatus  := "TAB. "+SX2->X2_ARQUIVO+" INEXISTENTE. "
                        lAltSX3 := .T.
                    ENDIF                    
                ELSE
                    cStatus := "ALIAS nao localizado no SX2 ["+SX3->X3_ARQUIVO+"]"
                ENDIF

                IF lAltSX3
                    RECLOCK("SX3",.F.)
                        SX3->X3_TAMANHO := SXG->XG_SIZE
                    MSUNLOCK()
                    cStatus += "SX3 CORRIGIDO."
                    CONOUT("U_LTSXGDB - DROP. ["+SX3->X3_CAMPO+"] SX3 CORRIGIDO. ")
                ENDIF

                cLog    += cStatus
                cpLogTxt(2, cLog)	
                cLog    := ""	
            endif
        ENDIF
    ENDIF
    SX3->(DBSKIP())
ENDDO

Return(cLog)


/*/{Protheus.doc} VerAtd=
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
Static Function ValidReg(cTab)
Local nQtdReg:= 0
Local cQuery    := ""

cQuery    := "SELECT COUNT(*) AS QTDREG FROM "+cTab


If Select("TSQL") > 0
	TSQL->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						

IF TSQL->(!EOF())
	nQtdReg := TSQL->QTDREG
ENDIF	
TSQL->(DbCloseArea())

Return(nQtdReg)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณMyOpenSM0Exณ Autor ณSergio Silveira       ณ Data ณ07/01/2003ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Efetua a abertura do SM0 exclusivo                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Atualizacao FIS                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MarkEmp  บAutor  ณ Augusto Ribeiro	 บ Data ณ  23/11/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta ListMark para selec็ใo das empresas                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MarkEmp()
Local aRet	:= {}  
Local nI
Private	lOk	:= .F. 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta List Solicitacao de Compras ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
Private oOk   	   	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Private oNo			:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Private aHeadEmp	:= {}       
Private aDadoEmp	:= {}
Private oLbxEmp		:= Nil    
Private oDlgEmp   
Private cTitulo  	:= "Update Projeto | WorkFlow Compras "
                           
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Dialog ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgEmp TITLE "Atualizacao Automatica" FROM 0,0 TO 305,452 OF oDlgEmp PIXEL

ListEmp("C",@oLbxEmp,@aHeadEmp, @aDadoEmp)  
                                     
                                     
@ 135,140 BUTTON "&Ok"       SIZE 36,16 PIXEL ACTION (lOk:=.T.,oDlgEmp:End())
@ 135,180 BUTTON "&Cancelar" SIZE 36,16 PIXEL ACTION (lOk:=.F.,oDlgEmp:End())                                     
                                           
ACTIVATE MSDIALOG oDlgEmp CENTERED //ON INIT Eval({ || EnChoiceBar(oDlg,bOKEmp,bCancEmp,.F.,aButtons) })


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona somente os codigos das empresas selecionadas ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ListLog  บAutor  ณ Augusto Ribeiro	 บ Data ณ  10/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  List Log                                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta aHeader ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
aHeader		:= {"", "Codigo", "Filial","Empresa"}
aCpoHeader	:= {"", "Codigo", "Filial","Empresa"}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta aDados ณ

PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00101MG0001"

cQuery += " SELECT M0_CODIGO, MIN(M0_NOME) AS M0_NOME, MIN(M0_CODFIL) AS M0_CODFIL, MIN(M0_FILIAL) AS M0_FILIAL "+CRLF
cQuery += " FROM SYS_COMPANY  "+CRLF
cQuery += " WHERE D_E_L_E_T_  = '' "+CRLF
cQuery += " GROUP BY M0_CODIGO "+CRLF

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)



//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ cOpcList | C = Cria, A = Atualiza ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF cOpcList == "C"
	
		@ 001,001 LISTBOX oLbxEmp FIELDS HEADER ;
		   " ", "Campos" ;                                                                                                    
		   SIZE 226, 130 OF oDlgEmp PIXEL ON dblClick( aDados[oLbxEmp:nAt,1] := !aDados[oLbxEmp:nAt,1] ,oLbxEmp:Refresh())
	ENDIF                                           
	
	
	oLbxEmp:aheaders := aHeader	
	oLbxEmp:SetArray( aDados )  
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria string com Bloco de Codigo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
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
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ cpGrvLog บAutor  ณ Augusto Ribeiro	 บ Data ณ  24/04/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a Cria็ใo, Gravacao, Apresentacao do Log           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบPARAMETROSณ _nOpc : 1=Cria Arquivo, 2= Grava Log, 3 = Apresenta Log    บฑฑ
ฑฑบ          ณ _cTxtLog : Log a ser gravado                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ*ATENCAO* ณ Necessario a criacao das variaveis como Private            บฑฑ
ฑฑบ          ณ Private _cFileLog	 	:= ""                             บฑฑ
ฑฑบ          ณ Private _cLogPath		:= ""                             บฑฑ
ฑฑบ          ณ Private _Handle			:= ""                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function cpLogTxt(_nOpc, _cTxtLog)
Local _lRet	:= Nil
Local _nOpc, _cTxtLog  
Local cLogIni	:= ""
                                                                  
Default _nOpc		:= 0
Default _cTxtLog 	:= ""                                            

	Do Case
		Case _nOpc == 1
			//_cFileLog	 	:= Criatrab(,.F.)                        
			_cFileLog		:= "LTSXGDB_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","-")
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
				FwHelpShow(,"Arquivo invแlido","Arquivo nใo encontrado.","Verifique se o arquivo realmente encontra-se em ["+cPathTemp+"]")
			ENDIF		
	 
            WinExec("Explorer "+cPathTemp)
	EndCase

Return(_lRet)

