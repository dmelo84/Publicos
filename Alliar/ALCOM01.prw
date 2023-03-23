#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

STATIC cOperID:= 	"000"	 // Variavel para armazenar a operação que foi executada
#DEFINE OP_LIB   	"001" //Liberado
#DEFINE OP_EST   	"002" //Estornar
#DEFINE OP_SUP   	"003" //Superior
#DEFINE OP_TRA   	"004" //Transferir Superior
#DEFINE OP_EST	"005" // Estorna
#DEFINE OP_REJ	"006" // Rejeitado

//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM01()
Rejeitar doc

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function ALCOM01() 
Local oBrowse  
Local cFiltraSCR
Local ca097User 	:= RetCodUsr()

//-------------------------------------------------------------------
// Verifica se o usuario possui direito de liberacao.           
//-------------------------------------------------------------------
dbSelectArea("SAK")
dbSetOrder(2)
If !MsSeek(xFilial("SAK")+RetCodUsr())
	Help(" ",1,"A097APROV") //  Usuário não esta cadastrado como aprovador. O  acesso  e  a utilizacao desta rotina e destinada apenas aos usuários envolvidos no processo de aprovação de Pedido Compras definido pelos grupos de aprovação.
	dbSelectArea("SCR")
	dbSetOrder(1)
Else
	
		dbSelectArea("SCR")
		dbSetOrder(1)   
		      
 		If cFiltraSCR == NIL
 		    cFiltraSCR  := 'CR_FILIAL=="'+xFilial("SCR")+'"'+'.And.CR_USER=="'+ca097User
   	  		cFiltraSCR += '".And.CR_STATUS=="02"'
   	  
   	    EndIf		
   	  
		
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias('SCR')       
		                                   
		// Definição da legenda
		oBrowse:AddLegend( "CR_STATUS=='01'", "BR_AZUL" , "Blqueado (aguardando outros niveis)" )//"Blqueado (aguardando outros niveis)"
		oBrowse:AddLegend( "CR_STATUS=='02'", "DISABLE" , "Aguardando Liberacao do usuario" )//"Aguardando Liberacao do usuario"
		oBrowse:AddLegend( "CR_STATUS=='03'", "ENABLE"  , "Documento Liberado pelo usuario" )//"Documento Liberado pelo usuario"
		oBrowse:AddLegend( "CR_STATUS=='04'", "BR_PRETO", "Documento Bloqueado pelo usuario" )//"Documento Bloqueado pelo usuario"
		oBrowse:AddLegend( "CR_STATUS=='05'", "BR_CINZA", "Documento Liberado por outro usuario" )//"Documento Liberado por outro usuario"
		oBrowse:AddLegend( "CR_STATUS=='06'", "BR_AMARELO",	 "Documento Rejeitado pelo usuário" )//"Documento Rejeitado pelo usuário"
		
		oBrowse:SetCacheView(.F.)
		oBrowse:DisableDetails()
		//oBrowse:SetDescription(STR0006)  //"Aprovação de Documentos"
		oBrowse:SetFilterDefault(cFiltraSCR)

		oBrowse:Activate()		

EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@since 28/01/2013
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)
/*/
//-------------------------------------------------------------------
Static Function MenuDef()  

Local aRotina := {} //Array utilizado para controlar opcao selecionada
ADD OPTION aRotina Title "Pesquisar"	Action 'PesqBrw'  			OPERATION 1 ACCESS 0 			//"Pesquisar"
ADD OPTION aRotina Title "Rejeitar Pedido"	Action 'U_Rejeitar'			OPERATION 5 ACCESS 0 // "Rejeitar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} Rejeitar()
Rejeitar pedido e eliminar residuo
@author Leonardo Quintania
@since 28/01/2013
@version 1.0
@return aRotina (vetor com botoes da EnchoiceBar)


Veja como funciona a tabela SCR:

---- INCLUI PEDIDO <<
pedidos nascem com C7APROV = 000001   C7_CONAPRO = B   SCR->CR_STATUS == '02'


---- LIBEREI PEDIDO <<
DEPOIS QUE DEI ORDEM DE LIBERAR SETEI CR_STATUS 03                                           
Depois que liberamos o C7_CONAPRO vira L

---- CLIQUEI EM ESTORNAR LIBERACAO <<
pedidos nascem com C7APROV = 000001   C7_CONAPRO = B   SCR->CR_STATUS == '02'

-- CLIQUEI EM BLOQUEIO <<
pedidos nascem com C7APROV = 000001   C7_CONAPRO = B   SCR->CR_STATUS == '04'

-- APOS BLOQUEAR É POSSIVEL ESCOLHER O REGISTRO E CLICAR EM LIBERAR <<<<
DEPOIS QUE DEI ORDEM DE LIBERAR SETEI CR_STATUS 03                                           
Depois que liberamos o C7_CONAPRO vira L

/*/
//-------------------------------------------------------------------
User Function Rejeitar(nRecSCR)
	Local aArea		:= GetArea()
	Local aAreaSCR	:= SCR->(GetArea())
	Local aAreaSC7	:= SC7->(GetArea())
	Local aRecSC7		:= {}
	
	Local cUpd 		:= ""
	Local lPodeRej 	:= .F.
	Local aRet		:= { .F. ,""}
	
	DEFAULT  nRecSCR := SCR->(RECNO())
	
	DBSELECTAREA("SCR")
	SCR->(DBGOTO(nRecSCR))
	
	If AllTrim(SCR->CR_STATUS) == "02"
	
		dbselectarea('SC7')
		dbsetorder(1)
		dbseek(Fwxfilial('SC7') + AllTrim(SCR->CR_NUM) )
		
		If SC7->(!Eof()) .And. AllTrim(SC7->C7_NUM) == AllTrim(SCR->CR_NUM)
			If AllTrim(SC7->C7_CONAPRO) == "B"
				lPodeRej := .T.
			EndIf
		EndIf
	EndIf
	
	If !lPodeRej 
//		Alert ("Somente é possivel rejeitar Pedidos de Compra ainda 'não aprovados'.")
		aRet		:= { .F. ,"Somente é possivel rejeitar Pedidos de Compra ainda 'não aprovados'."}
	Else
		RecLock('SCR', .F.)
		SCR->CR_DATALIB	:= ctod('')
		SCR->CR_STATUS	:= '04' 
		SCR->CR_XRJTD 	:= "1"
		MsUnLock()

		If SC7->(FieldPos("C7_XJUST")) > 0 .And. !IsBlind() .AND. EMPTY(SC7->C7_XIDFLG) .AND. ALLTRIM(FunName()) != "CP12001"
		 	Justificativa()
	  	EndIf
		
		DbSelectArea("SC7")
		DbSetOrder(1)		//C7_FILIAL, C7_NUM
	
		If SC7->(DbSeek(xFilial("SC7") + PadR(SCR->CR_NUM, Len(SC7->C7_NUM))))
	
			While !SC7->(Eof()) .AND. AllTrim(xFilial("SC7") + SCR->CR_NUM )== AllTrim(SC7->C7_FILIAL + SC7->C7_NUM)
				RecLock("SC7", .F.)
					SC7->C7_CONAPRO	:= "B"
					SC7->C7_XRJTD 	:= "1"
					
				MsUnlock()
	
				SC7->(DbSkip())
			End
		EndIf
	
		RestArea(aAreaSC7)
		RestArea(aAreaSCR)
		RestArea(aArea)
	
	
		//eliminacao do pedido compras por residuo
		MA235PC(100,1,CTOD('01/01/80'),CTOD('31/12/29'),SCR->CR_NUM,SCR->CR_NUM,' ','ZZZZZZZZZZZZZZZZZZZZ',' ','ZZZZZZZZZZ',CTOD('01/01/80'),CTOD('31/12/29'),' ','ZZZZ', NIL, aRecSC7)
		
		/*----------------------------------------
			20/09/2018 - Jonatas Oliveira - Compila
			Verifica se o pedido foi eliminado
		------------------------------------------*/
		IF SC7->(dbseek(XFILIAL("SC7") + AllTrim(SCR->CR_NUM) ))
			IF !Empty(SC7->C7_RESIDUO)
				aRet		:= { .T. ,"Pedido " + XFILIAL("SC7") + AllTrim(SCR->CR_NUM) + "Recusado."}
			ELSE
				aRet		:= { .F. ,"Falha na Recusa do pedido: " + XFILIAL("SC7") + AllTrim(SCR->CR_NUM)}
			ENDIF 
		ENDIF 
	EndIf

	RestArea(aAreaSC7)
	RestArea(aAreaSCR)
	RestArea(aArea)

Return(aRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM02()
Rejeitar douc

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function ALCOM02(aRet) 
Local nIndex := 0

For nIndex := 1 to Len(aRet)
	aRet[nIndex][1] := aRet[nIndex][1] + " .AND. C7_XRJTD <> '1' " 
Next

aAdd(aRet,    { "!Empty(C7_RESIDUO) .AND. C7_XRJTD = '1' ", 'BR_PINK' })	//-- Executou rotina de rejeicao do pedido de compra

RETURN aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO14()
Adiciona nova pasta na tela do pedido de compra

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function ALCO14() 

AAdd( aTitles, "Justificativa Rejeição" ) //Nome do folder que será adicionado

RETURN 

//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO15()
Adiciona nova pasta na tela do pedido de compra

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function ALCO15(nOpc, aPosGet) 
	
If SC7->(FieldPos("C7_XJUST")) > 0

	cCampo1 := CriaVar("C7_XJUST")
		
	IF !INCLUI
		cCampo1 := SC7->C7_XJUST
	Endif
	
	@ 010,010/*aPosGet[4,1]*/ GET oCamp1 var cCampo1 MultiLine PIXEL OF oFolder:aDialogs[7]  when .F.  SIZE 400,40

EndIf


RETURN 


//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM03()
legendas da tela do pedido de compra

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function ALCOM03(aRet) 

aAdd(aRet,{"BR_PINK"		,"Ped.Compra Rejeitado"})

RETURN aRet



/*/{Protheus.doc} Justificativa
Chamada de menu

@author oswaldo leite
@since 06/08/2012
@version 11.7
/*/
                               
Static Function Justificativa()     
Local aArea         := GetArea()

FWExecView("Justificativa ", 'ALCO13', 4, Nil, {||.T.}, {||.T.},/*percwntual de reducao do tamanho da tela 60*/ ,/*aButtons*/ , {||.T.} )

RestArea( aArea )
Return Nil



