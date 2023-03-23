#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FILEIO.CH"




Static __cProcPrinc := "FINA473"
Static __cPerg		:= "FINA473"
Static lFWCodFil := .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM10()

ALCOM10 conciliacao bancaria em lote

Oswaldo.leite
@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function ALCOM10() 
Local aSays    := {}
Local aButtons := {}
Local lOk      := .F. 

Private cLicon     := SuperGetMV("ES_LICON",, '')  //Pasta Pai
Private cDirLayout      := SuperGetMV("ES_DIRLAY",, '')  
Private cDirArquivos    := SuperGetMV("ES_DIRARQ",, '')  
Private cDirProcessados := SuperGetMV("ES_DIRPRO",, '')  
Private cDirLogs        := SuperGetMV("ES_DIRLOG",, '')  

Private cPathDest := GetSrvProfString("StartPath","\system\")

AAdd(aSays, 'Leitura de listas de arquivos de conciliação bancária.')
AAdd(aButtons,{01, .T., {|o| lOk := .T., FechaBatch()}})
AAdd(aButtons,{02, .T., {|o| lOk := .F., FechaBatch()}})
				
FormBatch('Conciliação', aSays, aButtons)    

If Empty(cLicon) .or. Empty(cDirLayout)  .or. Empty(cDirArquivos) .or. Empty(cDirProcessados) .or. Empty(cDirLogs)
	Alert ("Configure os parâmetros ES_LICON, ES_DIRLAY, ES_DIRARQ, ES_DIRPRO e ES_DIRLOG antes de utilizar esta rotina.")
	lOk := .F.
EndIf

If lOk
 	Processa({|| FazCon()}, 'Aguarde...', 'Processando conciliações ...')
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
Local cNome

Local nCount2     := 0
Local nCount3      := 0
Local nTam        := 0
Local cNomArq     := ''
Local cLayNomArq     := ''
Local cErrNomArq     := ''




Local aLays := {}
Local lErro := .F.
Local cHtmlEmail := SuperGetMV("ES_PAEMA",, '')

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
Private cServer := SuperGetMV("ES_CNSRV",, '')// smtp.totvspartners.com.br  – código do servidor de email SMTP que será responsável pelo disparo do email. Ex: mail.alliar.com
Private cPorta := SuperGetMV("ES_CNPOR",, '')// – porta do servidor de email SMTP. Ex; 587
Private cOriEmail := SuperGetMV("ES_CNORI",, '')// oswaldo.leite@totvspartners.com.br – email único de origem que será utilizado para o disparo dos email´s em todas as empresas-filiais. Ex: Jose@alliar.com.br
Private cUsuDoEmail := SuperGetMV("ES_CRUS",, '')// oswaldo.leite@totvspartners.com.br – nome do usuário do email que será utilizado como origem para o disparo de email Ex.: Jose
Private cSenhaEmail := SuperGetMV("ES_CNSEN",, '')// !senha@2015!     – senha do usuário que será utilizado como origem . Ex.: JOSE2016
Private cDestEmail := SuperGetMV("ES_CNDES",, '')// oswaldo.leite@totvspartners.com.br !senha@2015!                                                                                                                                                                                                                                              – email único de destino para o qual serão encaminhadas todas as mensagens de alertas de todas as empresas-filiais. Ex.: CARLOS@ALLIAR.COM.BR
Private lABortaPorCNPJ := .F.
Private aArqs, aLogs

cNome :=  AllTrim(cLicon) 

cHtmlEmail := cPathDest + cNome + "\" + cHtmlEmail

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
            
ProcRegua(0)
      
For nCount1 := 1 to Len(aLstDirBcos)//varre lista de bancos existntes no cliente
    /*
    For nCount3 := 1 to 4                  
    	aLstDirBcos[nCount1][nCOunt3] := strtran ( aLstDirBcos[nCount2][nCOunt3], "\\", "\",1,5)
    Next*/
     
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
			//aadd(aLogs,{"1","erro estranho"} )
			//aadd(aLogs,{"2","pau complexo"} )
			
			cLayNomArq := AllTrim(aLayArqs[1][1])//<- sempre apenas 1
			
			cNomArq    := AllTrim(aArqs[nCount2][1])
			nTam       := Len(cNomArq)
			
			IncProc (cNomArq)
			cLogNomArq     := strtran(cNomArq,".","_LOG.",1,1)
			cLogNomArq     := strtran(cLogNomArq,".TXT",".XML",1,1)
			cLogNomArq     := strtran(cLogNomArq,".RET",".XML",1,1)
			
			cErrNomArq     := strtran(cNomArq,".","_ERRO.",1,1)
			
			lABortaPorCNPJ := .F.			
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
		
		If Len(aLinhas) > 0
			MandaEmail(cHtmlEmail)
		EndIf
		
	Else
		/*
		
		alogs é NIL neste ponto
		If Len(aLayArqs) <= 0 // não existe arquivo de configuracao do banco a ser conciliado na pastinha de layouts
			Aadd (aLogs, {1,"Não existe arquivo de conifguração de layout deste banco"} )
		EndIf
		
		If Len(aArqs) <= 0 // não existe arquivo de dados para ser conciliado 
			Aadd (aLogs, {1,"Não existem arquivos para ser conciliados neste banco"} )
		EndIf*/
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
dbSelectArea("SIF")
dbSelectArea("SIG")

cIdProc	:= F473ProxNum("SIF")
aConfig1 := {cIdProc ,  aLstDirBcos[nCount1][5], aLstDirBcos[nCount1][6] } //CriaVar("A6_COD"), CriaVar("IF_DESC") }
aConfig2 := { cLayNomArq,  cNomArq} //funcao parao pede esta barra antes do nome do arquivo

//alert ("Padrao utiizando: {" +cIdProc + "," + aLstDirBcos[nCount1][5] + "," + aLstDirBcos[nCount1][6] + "} " +Chr(13)+Chr(10) + "{" + aconfig1[1] + "," + aconfig1[2] + "}" )

cFilAnt := DetectaFilial(aConfig1,aConfig2) 

If !Empty(cFilAnt)
	BeginTran()
	lRet := F473ImpExt(aConfig1, aConfig2, nOpc,aLogs)//funcao do produto padrao
	
	If !lRet
		Aadd(aLinhas, {aconfig1[2], cLogNomArq} )//codigo do banco e nome do arquivo de log gerado
		DisarmTransaction()
	Else
		ConfirmSX8()
	EndIf
	EndTran()
else
	Alert ('Problema no CPNJ do arquivo de dados. Não localizamos uma empresa-filial no sistema referente ao CNPJ lido do arquivo: ' + AllTrim(cNomArq))
EndIf


If !lRet
	RollBackSX8()
	/*cSubProc 	:= cIdProc
	ProcLogIni( {},cProc,cSubProc,@cIdCV8 )
	ProcLogAtu( "INICIO" , "Importação de Extrato Bancario" ,,,.T. ) //"Importação de Extrato Bancario"
		
	For nX := 1 to Len(aLog)	
		ProcLogAtu("ERRO","Linha do Arquivo " + cValtoChar(aLog[nX][1]) ,aLog[nX][2],,.F. )//"Linha do Arquivo "
	Next nX	
		
	ProcLogAtu( "FIM" ,,,,.T.)
	ProcLogView(cFilAnt,cProc,cSubProc,cIdCV8)*/
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



/*/{Protheus.doc} MandaEmail

envia email

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/
Static Function MandaEmail (cArqHtml)
Local nI   := 0  
Local oServer       := NIL, nErro := 0, cMAilError := ''
Local nArr := 0
Local oMessage      := NIL
Local ncont := 0


Local cMailServer := SuperGetMV("ES_CNSRV",, '')//* – código do servidor de email SMTP que será responsável pelo disparo do email. Ex: mail.alliar.com
Local cPrtServer  := SuperGetMV("ES_CNPOR",, '')//* – porta do servidor de email SMTP. Ex; 587
Local cMailCtaAut := SuperGetMV("ES_CNORI",, '')//* – email único de origem que será utilizado para o disparo dos email´s em todas as empresas-filiais. Ex: Jose@alliar.com.br
Local cMailConta  := SuperGetMV("ES_CRUS",, '')// * – nome do usuário do email que será utilizado como origem para o disparo de email Ex.: Jose
Local cMailSenha  := SuperGetMV("ES_CNSEN",, '')//* – senha do usuário que será utilizado como origem . Ex.: JOSE2016
Local cMailDest   := SuperGetMV("ES_CNDES",, '')// – email único de destino para o qual serão encaminhadas todas as mensagens de alertas de todas as empresas-filiais. Ex.: CARLOS@ALLIAR.COM.BR

Local cTitulo       := dtoc(dDataBase) + " Conciliação Bancária" 
Local cMailOrig     := cMailCtaAut 



Local lRet          := .T.
Local lCOntinua     := .T.                                       
Local nTamFim       := 0
Local cStr          := ''
Local cStrArq       := ''

Local nIndChar      := 0        
Local cNome         := ''
Local cParcNome     := ''
Local cNewNome      := ''
Local cTxtHtml      := Memoread(cArqHtml)
Local cCorpo        := GridCorpoEMail ()

cTxtHtml := STRTRAN ( cTxtHtml , '[LINHAS]' , cCorpo , 1 , 1 )		

//--Cria a conexão com o server STadmin	MP ( Envio de e-mail )
oServer := TMailManager():New()      
//oServer:SetUseTLS(.T.) 
                                            
//ALert ("cMailServer '" + AllTrim(cMailServer) + "'")
//ALert ("cMailCtaAut '" + AllTrim(cMailCtaAut) + "'") 
//ALert ("cMailSenha '"  + AllTrim(cMailSenha) + "'")


oServer:Init('', cMailServer, cMailCtaAut, cMailSenha, 0, Val(cPrtServer))//25

nArr := oServer:SetSMTPTimeOut( 120 ) 
cMAilError := oServer:GetErrorString(nArr)
  
If  oServer:SMTPConnect() <> 0     
//	ALert ("nao achou SMTP")

	//Conout( "Ocorreu um problema ao determinar o Time-Out do servidor SMTP ou nao foi possível estabelecer a conexao com o mesmo." )
	lRet := .F.
	lContinua := .F.          
else
//	ALert ("cMailConta '" + AllTrim(cMailConta) + "'")   
//	ALert ("cMailSenha '" + AllTrim(cMailSenha) + "'")


	nErro := oServer:SmtpAuth(cMailConta, cMailSenha)

	If nErro <> 0
//		ALert ("nao validou senha")

        cMAilError := oServer:GetErrorString(nErro)
        DEFAULT cMailError := '***UNKNOW***'
        //ConOut("Erro de Autenticacao " + Str(nErro,4) + '(' + cMAilError + ')')
        oServer := Nil
		 lRet := .F.	
        Return lRet
    EndIf	
EndIf

If lContinua          
	oMessage := TMailMessage():New()         
	oMessage:Clear()                            
	
	
	If Len(aLinhas) > 0
		cTitulo := cTitulo + " Banco: " + aLinhas[1, 1]
	EndIf
	
	
	//--Popula com os dados de envio
	oMessage:cFrom 		:= cMailOrig //cMailCtaAut
	oMessage:cTo 		:= cMailDest    //"oswaldo.luiz@totvs.com.br"
	oMessage:cSubject   := cTitulo
				                       
	oMessage:cBody := cTxtHtml
    
	//--Envia o e-mail
	//ConOut('Enviando mensagem ')
	
	If oMessage:Send(oServer) != 0
		lRet := .F.
		//Conout( "Erro ao enviar o e-mail" )      
	else     
		If Empty(oMessage:cTo)
			lRet := .F.
			//Conout( "Erro ao enviar o e-mail" )      
		Endif
	EndIf
	        
    oMessage := Nil
                                                       
	//--Desconecta do servidor
	If oServer:SMTPDisconnect() != 0
		lRet := .F.
		//Conout( "Erro ao disconectar do servidor SMTP" )
	EndIf

EndIf

Return lRet



/*/{Protheus.doc} GridCorpoEMail

grid com titulos

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/
Static FUnction GridCorpoEMail ()
LOcal cGrid := ''
Local nIndex := 1

for nIndex := 1 to Len(aLinhas)
	
	cGrid += '									<tr class="Text">' + Chr(13)+Chr(10)
	
	cGrid += '										<td>' + aLinhas[nIndex, 2] + '</td>' + Chr(13)+Chr(10)
    
	cGrid += '									</tr>' + Chr(13)+Chr(10)
Next

return cGrid

/*/{Protheus.doc} DetectaFilial

DetectaFilial

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/
Static FUnction DetectaFilial(aCfg1,aCfg2)
Local cArqEnt		:= ""
Local xBuffer
Local nHdlBco		:= 0
Local nTamArq
Local nLidos
Local nTamDet       := 0
Local cPartCgc       := ''
Local cSalvCgc       := ''
Local aSM0Area      
Local cRet          := ''
Local lAchou        := .F.

//Posiciona no Banco indicado 
dbSelectArea("SEE")
dbSetOrder(1)
If dbSeek(xFilial("SEE")+aCfg1[2])
	nTamDet	 := IIF(SEE->EE_BYTESXT > 0, SEE->EE_BYTESXT + 2, 202 )
Else
	Return cFilAnt//se nao conseguir abrir retornar a mesma emp-fil e deixa que o padrao critique adiante ...dentro do FINA473, pois ele fará o mesmo tipo de teste de novo
Endif


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
	
	cPartCgc :=Substr(xBuffer, 19 , 14 )
	
EndIf

If Empty(cPartCgc)
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
			
//Fecha arquivo do Banco 
Fclose(nHdlBco)

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

return cRet 




//========================================================
User Function ALFI99()
Local aArea		:= {}
Local oBrowse
PRIVATE cCadastro :=  "Conciliação Bancária"
PRIVATE aRotina := Menudef()

aArea := GetArea()
dbSelectArea("SIF")
dbSelectArea("SIG")

If FWHASMVC()
	If cPaisLoc == "BRA"
		If xFilial("SIG") == xFilial("SE5") .And. xFilial("SIF") == xFilial("SE5") 
				
			oBrowse := FWMBrowse():New()
			oBrowse:SetAlias('SIF')
			oBrowse:SetDescription('Conciliação Bancária'	) //'Conciliação Bancária'
			oBrowse:AddLegend( "IF_STATUS=='1'", "RED", "Não conciliado" ) 	 //"Não conciliado"
			oBrowse:AddLegend( "IF_STATUS=='2'", "YELLOW", "Em Andamento" ) //"Em Andamento"
			oBrowse:AddLegend( "IF_STATUS=='3'", "GREEN", "Conciliado" )  //"Conciliado"
			oBrowse:Activate()
		Else
			Help(" ",1,"FIN473SE5",,"As tabelas da rotina devem ter o mesmo compartilhamento da tabela SE5", 1, 0 ) //"As tabelas da rotina devem ter o mesmo compartilhamento da tabela SE5"
		EndIf
	Else
		Help(" ",1,"FIN473BRA",,"Rotina disponível apenas para o Brasil ", 1, 0 ) //"Rotina disponível apenas para o Brasil "
	EndIf
Else
	Help(" ",1,"FIN473MVC",,"Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib ", 1, 0 ) //"Ambiente desatualizado, por favor atualizar com o ultimo pacote da lib "
Endif



RestArea(aArea)
Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF
Função de definição do Menu da Rotina

@author	Alvaro Camillo Neto
@since		25/09/2013
@version	MP11.90
		
/*/
//-------------------------------------------------------------------
   

Static Function MenuDef()     
Local aRotina

aRotina	:= {}
ADD OPTION aRotina TITLE 'Pesquisar'  		ACTION 'PesqBrw'            	OPERATION 1 ACCESS 0		//'Pesquisar'	
//ADD OPTION aRotina TITLE "Importar" 		ACTION 'F473Import(,,3)' 		OPERATION 3 ACCESS 0		//"Importar"	
ADD OPTION aRotina TITLE "Conciliar" 		ACTION 'F473Concil(,,4)' 		OPERATION 4 ACCESS 0	    //"Conciliar"
ADD OPTION aRotina TITLE 'Visualizar' 		ACTION 'VIEWDEF.FINA473'  		OPERATION 2 ACCESS 0 		//'Visualizar'		
ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.FINA473' 		OPERATION 5 ACCESS 0 		//'Excluir'

ADD OPTION aRotina TITLE "Log Processamento" ACTION 'F473LogExt()'    OPERATION 6 ACCESS 0			//"Log Processamento"

Return(Aclone(aRotina))