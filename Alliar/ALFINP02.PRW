#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#include "apwizard.ch"
#INCLUDE "TBICODE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
//#INCLUDE "FINA300.CH"  
#INCLUDE "FWMVCDEF.CH"  

Static lFWCodFil := .T.  

//-------------------------------------------------------------------
/*/{Protheus.doc} ALFINP02()
@autor Oswaldo.leite
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function ALFINP02() 
Local lOk      := .T. 

Local nPar01
Local nPar02
Local nPar03

Local cPar04
Local cPar05
Local cPar06
Local cPar07

Local nPar08
Local nPar09
Local nPar10
Local nPar11
Private cPerg := "FINP05"
Private cXCSub          := SuperGetMV("ES_XCSUB",, '')  //antonio comentou que utilizarao somente registros da SEE cuja subconta seja 002. Sendo assim, criei parâmetro para isto

Private cLicon          := SuperGetMV("ES_XLICON",, '')  //Pasta Pai
Private cDirLayout      := SuperGetMV("ES_DIRLAY",, '') //lxç~flkçsdajkl~fjskladjflkjsdçklfjçksladjfçklsjadlkçf //Layout
Private cDirArquivos    := SuperGetMV("ES_DIRARQ",, '')  //Arquivos
Private cDirProcessados := SuperGetMV("ES_DIRPRO",, '')  //Processados 
Private cDirLogs        := SuperGetMV("ES_DIRLOG",, '')  //Log
Private cPathDest := GetSrvProfString("StartPath","\system\")

Private lDigita
Private lAglut
Private lContabiliza

If Empty(cLicon) .or. Empty(cDirLayout)  .or. Empty(cDirArquivos) .or. Empty(cDirProcessados) .or. Empty(cDirLogs)
	Alert ("Configure os parâmetros ES_LICON, ES_DIRLAY, ES_DIRARQ, ES_DIRPRO e ES_DIRLOG antes de utilizar esta rotina.")
	lOk := .F.
EndIf

If lOk

	
	If pergunte(cPerg,.T.)//tela fake removendo campos nao mais necessarios
	
		nPar01 := mv_par01
		nPar02 := mv_par02
		nPar03 := mv_par03
		cPar04 := mv_par04
		cPar05 := mv_par05
		cPar06 := mv_par06
		cPar07 := mv_par07
		nPar08 := mv_par08
		nPar09 := mv_par09
		nPar10 := mv_par10
		nPar11 := mv_par11
	
		pergunte("AFI300",.F.) //tela do produto padrao ....que será re-alimentado com dados da tela fake
		
		mv_par01  := nPar01
		mv_par02  := nPar02
		mv_par03  := nPar03
		mv_par04  := " " //eram nomes de arquivos e iremos desconsiderá-los pois a leitura será feita do ote de arquivos  
		mv_par05  := " " //eram nomes de arquivos e iremos desconsiderá-los pois a leitura será feita do ote de arquivos
		mv_par06  := cPar04
		mv_par07  := cPar05
		mv_par08  := cPar06
		mv_par09  := cPar07
		mv_par10  := nPar08
		mv_par11  := nPar09
		mv_par12  := nPar10
		mv_par13  := nPar11
		
		lDigita:=IIF(mv_par01 == 1,.T.,.F.)
		lAglut :=IIF(mv_par02 == 1,.T.,.F.)
		lContabiliza:= Iif(mv_par11 == 1,.T.,.F.)
	
		//Fazcon()
	 	Processa({|| FazCon()}, 'Aguarde...', 'Processando Syspag em Lote ...')
	EndIf

EndIf

return
//-------------------------------------------------------------------
/*/{Protheus.doc} FazCon

Abre lista de arquivos existentes em diretorio 

Oswaldo.leite
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static function FazCon ()

Local lErro := .F.

Local cNome

Local nCount2     := 0
Local nCount3      := 0
Local nTam        := 0
Local cNomArq     := ''
Local cLayNomArq     := ''
Local cErrNomArq     := ''

Local aLays := {}
Local lErro := .F.


Local cBco033 := SuperGetMV("ES_L033",, '')  //sub pasta na qual se encontram os arquivos de conciliacao do banco santander
Local cBco237 := SuperGetMV("ES_L237",, '')
Local cBco341 := SuperGetMV("ES_L341",, '')
Local cBco001 := SuperGetMV("ES_L001",, '')

Local c033Cod  := SuperGetMV("ES_C033",, '')  //código do banco 033
Local c033Desc := SuperGetMV("ES_D033",, '')  //descricao do banco 033
Local c237Cod  := SuperGetMV("ES_C237",, '')  
Local c237Desc := SuperGetMV("ES_D237",, '')  
Local c001Cod  := SuperGetMV("ES_C001",, '')  
Local c001Desc := SuperGetMV("ES_D001",, '')  
Local c341Cod  := SuperGetMV("ES_C341",, '')  
Local c341Desc := SuperGetMV("ES_D341",, '')  


Private cLogNomArq     := ''
Private aLinhas    := {}
Private nCount1     := 0
Private aLstDirBcos := {}
/*Private cServer := SuperGetMV("ES_CNSRV",, '')// smtp.totvspartners.com.br  – código do servidor de email SMTP que será responsável pelo disparo do email. Ex: mail.alliar.com
Private cPorta := SuperGetMV("ES_CNPOR",, '')// – porta do servidor de email SMTP. Ex; 587
Private cOriEmail := SuperGetMV("ES_CNORI",, '')// oswaldo.leite@totvspartners.com.br – email único de origem que será utilizado para o disparo dos email´s em todas as empresas-filiais. Ex: Jose@alliar.com.br
Private cUsuDoEmail := SuperGetMV("ES_CRUS",, '')// oswaldo.leite@totvspartners.com.br – nome do usuário do email que será utilizado como origem para o disparo de email Ex.: Jose
Private cSenhaEmail := SuperGetMV("ES_CNSEN",, '')// !senha@2015!     – senha do usuário que será utilizado como origem . Ex.: JOSE2016
Private cDestEmail := SuperGetMV("ES_CNDES",, '')// oswaldo.leite@totvspartners.com.br !senha@2015!                                                                                                                                                                                                                                              – email único de destino para o qual serão encaminhadas todas as mensagens de alertas de todas as empresas-filiais. Ex.: CARLOS@ALLIAR.COM.BR
*/
Private lABortaPorCNPJ := .F.
Private aArqs, aLogs

Private lABortaPorCNPJ := .F.

SetFunName("FINA300")
ProcRegua(0)
cNome :=  AllTrim(cLicon) 

//cHtmlEmail := cPathDest + cNome + "\" + cHtmlEmail

aadd(aLstDirBcos, {cPathDest + cNome + "\" + AllTrim(cBco033) + "\" + AllTrim(cDirLayout)      + "\"   ,;
				   cPathDest + cNome + "\" + AllTrim(cBco033) + "\" + AllTrim(cDirArquivos)    + "\" ,;
				   cPathDest + cNome + "\" + AllTrim(cBco033) + "\" + AllTrim(cDirProcessados) + "\" ,;
				   cPathDest + cNome + "\" + AllTrim(cBco033) + "\" + AllTrim(cDirLogs)        + "\" ,;
				   c033Cod,;
				   c033Desc ;
                  }   )

aadd(aLstDirBcos, {cPathDest + cNome + "\" + AllTrim(cBco001) + "\" + AllTrim(cDirLayout)      + "\"   ,;
				   cPathDest + cNome + "\" + AllTrim(cBco001) + "\" + AllTrim(cDirArquivos)    + "\" ,;
				   cPathDest + cNome + "\" + AllTrim(cBco001) + "\" + AllTrim(cDirProcessados) + "\" ,;
				   cPathDest + cNome + "\" + AllTrim(cBco001) + "\" + AllTrim(cDirLogs)        + "\" ,;
				   c001Cod,;
				   c001Desc;
                  }   )


aadd(aLstDirBcos, {cPathDest + cNome + "\" + AllTrim(cBco237) + "\" + AllTrim(cDirLayout)      + "\"   ,;
				   cPathDest + cNome + "\" + AllTrim(cBco237) + "\" + AllTrim(cDirArquivos)    + "\" ,;
				   cPathDest + cNome + "\" + AllTrim(cBco237) + "\" + AllTrim(cDirProcessados) + "\" ,;
				   cPathDest + cNome + "\" + AllTrim(cBco237) + "\" + AllTrim(cDirLogs)        + "\" ,;
				   c237Cod,;
				   c237Desc ;
                  }   )
                  
                  
aadd(aLstDirBcos, {cPathDest + cNome + "\" + AllTrim(cBco341) + "\" + AllTrim(cDirLayout)      + "\"   ,;
				   cPathDest + cNome + "\" + AllTrim(cBco341) + "\" + AllTrim(cDirArquivos)    + "\" ,;
				   cPathDest + cNome + "\" + AllTrim(cBco341) + "\" + AllTrim(cDirProcessados) + "\" ,;
				   cPathDest + cNome + "\" + AllTrim(cBco341) + "\" + AllTrim(cDirLogs)        + "\" ,;
				   c341Cod,;
				   c341Desc;
                  }   )
            
//ProcRegua(0)
      
For nCount1 := 1 to Len(aLstDirBcos)//varre lista de bancos existntes no cliente
 
     
    aLays := {}
    aLays := Directory(aLstDirBcos[nCount1][1])
	
    aArqs := {}
	aArqs := Directory(aLstDirBcos[nCount1][2] + "*.*")
	
	aLayArqs := {}
	aLayArqs := Directory(aLstDirBcos[nCount1][1] + "*.*")//caso tenha N arquivos no diretorio ignorar e usar apenas o primeiro
	aLinhas  := {}
	
	If Len(aArqs) > 0 .And. Len(aLayArqs) > 0
		For nCount2 := 1 to Len(aArqs)   
			aLogs := {}
			
			cLayNomArq := AllTrim(aLayArqs[1][1])//<- sempre apenas 1
			
			cNomArq    := AllTrim(aArqs[nCount2][1])
			nTam       := Len(cNomArq)
			
			cLogNomArq     := strtran(cNomArq,".","_LOG.",1,1)
			cLogNomArq     := strtran(cLogNomArq,".TXT",".XML",1,1)
			cLogNomArq     := strtran(cLogNomArq,".RET",".XML",1,1)
			
			cErrNomArq     := strtran(cNomArq,".","_ERRO.",1,1)
			
			IncProc("Lendo arquivos: " + Alltrim(cNomArq) + ", " + AllTrim(cLayNomArq) )
			mv_par04 := cNomArq
			mv_par05 := cLayNomArq
			mv_par06 := ''//bco
			mv_par07 := ''//agencia
			mv_par08 := ''//conta   // <---- alimentados adiante em DetectaFilial()
			mv_par09 := ''
			mv_par12 := 2 //processa so filial  // Alterado 24/10/16 para processar todas as filiais. ABL
			lABortaPorCNPJ := .F.	
			
			Dbselectarea('SE2')
			Dbselectarea('SE5')
			Dbselectarea('SEE')
			Dbselectarea('SA6')
			
			lErro := ImpArqConciliacao(   (aLstDirBcos[nCount1][2]+cNomArq),  (aLstDirBcos[nCount1][1]+cLayNomArq)   )
	
			If lABortaPorCNPJ
			 	exit
			EndIf
			 	
			If lErro == .F.
				If frename( (aLstDirBcos[nCount1][2]+cNomArq), (aLstDirBcos[nCount1][2]+cErrNomArq) ) <> -1
				
					__CopyFile( aLstDirBcos[nCount1][2]+cErrNomArq, aLstDirBcos[nCount1][3] + cErrNomArq)
					Sleep(1000)
					LogXml (aLstDirBcos[nCount1][4] + cLogNomArq)
					//cloquei apos a geracao do xml para dar tempo ao processador para terminar de copiar o arquivo
					ferase (aLstDirBcos[nCount1][2]+cErrNomArq)
					
				EndIf
			Else
				__CopyFile( aLstDirBcos[nCount1][2]+cNomArq, aLstDirBcos[nCount1][3] + cNomArq)
				Sleep(1000)
				ferase (aLstDirBcos[nCount1][2]+cNomArq)
					
			EndIf
			
		Next
		
	EndIf
	
	If lABortaPorCNPJ
	 	exit
	EndIf
			
Next

return 
//-------------------------------------------------------------------
/*/{Protheus.doc} LOgXml


@author	Oswaldo Leite
@since		01/10/13
@version	MP11.90
		
/*/
//-------------------------------------------------------------------

Static Function LogXml (cNomeXml)
Local cNomWrk := "STATUS", cNomPla := "STATUS", cTitPla := "STATUS", nCount:= 0
Local oExcel  := FwMsExcel():New()                       
Local nCount  := 0

oExcel:AddworkSheet(cNomWrk)
oExcel:AddTable(cNomPla, cTitPla)

oExcel:AddColumn(cNomPla, cTitPla, "Linha", 1, 1, .F.)
oExcel:AddColumn(cNomPla, cTitPla, "Critica", 1, 1, .F.)

for nCount := 1 to Len(aLogs)
	oExcel:AddRow(cNomPla, cTitPla, { STR(aLogs[nCount][1]), aLogs[nCount][2]} )
Next

oExcel:Activate()               
//cPath := cArq//( dtos(Date()) + ".XML" )

oExcel:GetXMLFile( cNomeXml )//diretorio completo com nome do arquivo em extensao .XML
oExcel := FwMsExcel():DeActivate()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpArqConciliacao

@author	Oswaldo Leite
@since		01/10/13
@version	MP11.90
		
/*/
//-------------------------------------------------------------------

Static function ImpArqConciliacao (cNomArq,cLayNomArq)
Local cIdProc	:= ''
Local nOpc      := 3
Local aConfig1  := {}
Local aConfig2  := {}
Local lRet      := .F.
Local cOldFilAnt := cFilAnt

Private aRotina := {}
PRIVATE dDataLanc := dDataBase,cPadrao := "530"
PRIVATE cBcoDe    := CriaVar("E2_PORTADO"),cBcoAte := CriaVar("E2_PORTADO")
PRIVATE dVencIni  := dDataBase,dVencFim := dDataBase,dBaixa := dDataBase,nJuros := 0
PRIVATE nCorrecao := 0
PRIVATE cCtBaixa  := GetMv("MV_CTBAIXA")
PRIVATE cMarca    := GetMark( ) 

// Retorno Automatico via Job
// parametro que controla execucao via Job utilizado para pontos de entrada que nao tem como passar o parametro
PRIVATE lExecJob := IsBlind() //Variável adicionada pelo padrão em 2016 no fonte FINA300
Private cLotefin := Space( TamSX3("EE_LOTECP")[1] )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o n£mero do Lote                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cLote    
LoteCont( "FIN" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena a filial logada para processar os borderos somente desta filial e nao ³
//³ da filial do titulo posicionado na mBrowse                                     ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
xFa300FilLog(.T.)

cIdProc	:= '111'//sem uso F473ProxNum("SIF")
aConfig1 := {cIdProc ,  aLstDirBcos[nCount1][5], aLstDirBcos[nCount1][6] } //CriaVar("A6_COD"), CriaVar("IF_DESC") }
aConfig2 := { cLayNomArq,  cNomArq} //funcao parao pede esta barra antes do nome do arquivo

cFilAnt := DetectaFilial(aConfig1,aConfig2) 

If !Empty(cFilAnt)
	
	SetFunName("FINA300")
	mv_par04 := aConfig2[2]
	mv_par05 := aConfig2[1]
	
	Fa300Processa()
	
else
	Alert ('Problema no CPNJ do arquivo de dados ou a Agência\Banco\Conta não fora localizado na SEE. Lendo o arquivo: ' + AllTrim(cNomArq))
EndIf


cFilAnt := cOldFilAnt

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F473ProxNum

Retorna o próximo número da chave

@author	Alvaro Camillo Neto
@since		01/10/13
@version	MP11.90
		
/*/
//-------------------------------------------------------------------
Static Function F473ProxNum(cTab)
Local cNovaChave := ""
Local aArea := GetArea()
Local cCampo := ""
Local cChave 
Local nIndex := 0

If cTab == "SIF"
	SIF->(dbSetOrder(1))//IF_FILIAL+IF_IDPROC
	cCampo := "IF_IDPROC"
	nIndex := 1	
Else
	SIG->(dbSetOrder(2))//IG_FILIAL+IG_SEQMOV
	cCampo := "IG_SEQMOV"
	cChave := "IG_SEQMOV"+cEmpAnt
	nIndex := 2
EndIf


While .T.
	(cTab)->(dbSetOrder(nIndex))
	cNovaChave := GetSXEnum(cTab,cCampo,cChave,nIndex)
	If cTab == "SIF" 
		If (cTab)->(!dbSeek(xFilial(cTab) + cNovaChave) )
			Exit
		EndIf
	Else
		If (cTab)->(!dbSeek(cNovaChave) )
			Exit
		EndIf
	EndIf
EndDo

RestArea(aArea)
Return cNovaChave

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Fa300FilLog ºAutor ³ Gustavo Henrique º Data ³  11/05/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna a filial logada para processar os borderos desta   º±±
±±º          ³ filial e nao da filial do titulo posicionado na mBrowse    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Financeiro - FINA300 / FINA240                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xFa300FilLog( lAtualiza )

Static cFilLog

Default lAtualiza := .F.

If cFilLog == NIL .Or. lAtualiza
	cFilLog := cFilAnt//xFilial( "SEA" )
EndIf	

Return( cFilLog )



//-------------------------------------------------------------------
/*/{Protheus.doc} DetectaFilial
Valida o Cnpj e os dados do banco obtidos no arquivo .Ret
@author	Oswaldo Leite
@since		01/10/13
@version	MP11.90
		
/*/
//-------------------------------------------------------------------

Static FUnction DetectaFilial(aCfg1,aCfg2)
Local cArqEnt		:= ""
Local xBuffer
Local nHdlBco		:= 0
Local nTamArq
Local nLidos
Local nTamDet       := 100
Local cPartCgc       := ''
Local cPartAgencia   := ''
Local cPartConta     := ''
Local cPartBanco     := aCfg1[2]
Local cSalvCgc       := ''
Local aSM0Area      
Local cRet          := ''
Local lAchou        := .F.
Local cALiasEE
Local cFIlMove := ''
local aCampos := {}

//Abre arquivo enviado pelo banco
cArqEnt:= aCfg2[2]

IF !FILE(cArqEnt)
	Return cFilAnt//se nao conseguir abrir retornar a mesma emp-fil e deixa que o padrao critique adiante ...dentro do FINA473, pois ele fará o mesmo tipo de teste de novo
Else
	nHdlBco:=FOPEN(cArqEnt,0+64)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ler arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos:=0
FSEEK(nHdlBco,0,0)
nTamArq:=FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)

If nLidos <= nTamArq //conforme alinhado com consultores e Douglas haverá um unico arquivo por empresa. Náo haverá mistura de registros de diferentes empresas.
                     //então, por performance, apenas analizamos o primeiro registro do arquivo e vemos o CGC dele
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tipo qual registro foi lido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer:=Space(nTamDet)
	FREAD(nHdlBco,@xBuffer,nTamDet)
	
	cPartCgc     :=Substr(xBuffer, 19 , 14 )
	cPartAgencia :=Substr(xBuffer, /*53*/54 ,  4/*5 */)
	cPartConta   :=Substr(xBuffer, 66 ,  5 )
	
EndIf

//Fecha arquivo do Banco 
Fclose(nHdlBco)

If Empty(cPartCgc)  .or. Empty(cPartAgencia) .or. Empty(cPartConta)
    
	return cRet //neste caso nem deixar processar
endif 

cSalvCGC := AllTrim(substr(SM0->M0_CGC,1,14))

dbSelectArea( "SM0" )
SM0->(dbGoTop())

While !SM0->( EOF() )

	If AllTrim(Subs(SM0->M0_CGC,1,14)) == AllTrim(cPartCgc)
		lAchou := .T.
		cRet := SM0->M0_CODFIL
		exit
	EndIf	
	
	SM0->( DbSKip() )
End	

If !lAchou  
    
	lABortaPorCNPJ := .T. //abortar totalmente o processo
	cRet := ''
EndIf
			

//---- reposiciona no SM0 correto
  
	dbSelectArea( "SM0" )
	SM0->(dbGoTop())
	
	While !SM0->( EOF() )
	
		If AllTrim(Subs(SM0->M0_CGC,1,14)) == AllTrim(cSalvCgc)
			exit
		EndIf	
		
		SM0->( DbSKip() )
	End	

//---- reposiciona no SM0 correto

If !EMpty(cRet)

	cAliasEE := GetNextAlias()
	
	cFIlMove := cFilAnt
	cFilAnt := 	Alltrim(cRet)
	BeginSql Alias cAliasEE
		SELECT SEE.*  
		       FROM %table:SEE% SEE
		       WHERE              
		             SEE.%NotDel%
		             AND SEE.EE_FILIAL     = %EXP:( Fwxfilial('SEE') )%    
		             AND SEE.EE_CODIGO     = %EXP:( cPartBanco   )%    
		             AND SEE.EE_AGENCIA    = %EXP:( cPartAgencia )%    
		             AND SEE.EE_CONTA      = %EXP:( cPartConta   )%   
		             AND SEE.EE_SUBCTA      = %EXP:( cXCSub   )%
	EndSql
	
	
	
	If (cAliasEE)->(!Eof())  .And. AllTrim( (cAliasEE)->(EE_CODIGO) )  == AllTrim(cPartBanco) ;
	                         .And. AllTrim( (cAliasEE)->(EE_AGENCIA) ) == AllTrim(cPartAGencia) ;
	                         .And. AllTrim( (cAliasEE)->(EE_CONTA) )   == AllTrim(cPartConta) ;
	                         .And. AllTrim( (cAliasEE)->(EE_FILIAL) )  == AllTrim(Fwxfilial('SEE'))
	                         
	                        
			mv_par06 := (cAliasEE)->(EE_CODIGO)  //bco
			mv_par07 := (cAliasEE)->(EE_AGENCIA) //agencia
			mv_par08 := (cAliasEE)->(EE_CONTA)   //conta
			mv_par09 := (cAliasEE)->(EE_SUBCTA) 
			dBsELECTAREA('SEA')
			DbSelectarea('SEE')
			SEE->(DbGoto(  (cAliasEE)->(R_E_C_N_O_)   ))
			
			
			dBsELECTAREA('SA6')
			DbSetOrder(1)
			SA6->( dbSeek(xFilial("SA6")+SEE->EE_CODIGO+SEE->EE_agencia+SEE->EE_conta) )
	Else
		cRet := ''// <- forca o erro
		lABortaPorCNPJ := .T. //abortar totalmente o processo
	EndIf
	
	cFilAnt  := cFIlMove
	
	(cAliasEE)->(DbCLoseArea())

EndIf

return cRet 
