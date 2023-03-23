#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"

/*
ALXFINP23
seleciona de um dado ID para poder desmarcar estes titulos e remover pontualmente registros não mais desejados

@author 
@since 09/12/2014
@version 1.0
*/
User Function ALXFINP23(lExcluir)//execblock("ALXFINP14")
Local oBrowse 	:= Nil
Local aCampos    := {}
Local lMarcar    := .F.   
Local lMantem := .T.
Local lOk := .F. 
Local bAfterMark:= {|| MarcaS() }

Private oMark
Private aRotina 
Private cSiglaMark := "TI"//Alltrim(Date())+"-"+AllTrim(Time())
Private cPerg := "OY9HGPS"


If IsInCallStack("FINA750")
	
	pergunte(cPerg,.F.)
	mv_par01 := SE2->E2_XIDGPS
	
	If Empty(SE2->E2_XIDGPS)
		ALert ("Não existe ID GPS neste título")
	else
		lOk := .T.
	EndIf
	
Else   
		
	while lMantem
	
		If	pergunte(cPerg,.T.)
		    
			If empty(mv_par01)
				ALert ("Informe o ID GPS desejado")
				Loop
			Endif
			
			
			LOK := .T.	 
			lMantem := .F.	
		else
			Alert ("Operação cancelada!")
			lMantem := .F.	
		endif
		
	End
EndIf

If lOk
          
        //If mv_par02 == 1
        If lExcluir
        	If MsgNoYes( "Confirma a operação ?" ) 
				Begin Transaction
       			dbselectarea('SZM')
				SZM->(DbSetOrder(1))
				SZM->( DbSeek(Fwxfilial('SE2') + AllTrim(mv_par01)  ) )
				
				If SZM->(!Eof()) .And. AllTrim(SZM->ZM_ID) == AllTrim(mv_par01)
					reclock('SZM',.F.)
					SZM->(DbDelete())
					MsUnLock()
				EndIf
		
        		TCSQLExec("UPDATE " + RetSqlName('SE2') + " SET E2_XMARCA = '',  E2_XIDGPS = '' WHERE E2_XIDGPS = '" + mv_par01 + "' AND E2_FILIAL = '" + Fwxfilial('SE2') + "'"  )
				End Transaction
				
        	EndIf
        
        Else
            aRotina := MenuDef()
			
			//-- Instanciamento do classe
			oMark:= FWMarkBrowse():New()
			//-- Definição da tabela a ser utilizada
			oMark:SetAlias('SE2')
			oMark:SetDescription('Títulos do ID GPS: ' + AllTrim(mv_par01))
			
			//oMark:SetFieldMark( 'E2_XMARCA' )//<----
			
			omARK:SetFilterDefault( " E2_XIDGPS = '" + mv_par01 + "' " )
				
			//-- Define o campo que sera utilizado para a marcação    
			//oMark:SetFieldMark( 'E2_XMARCA' )    
			//oMark:SetMark(cSiglaMark, 'SE2', 'E2_XMARCA') 
			//-- Define a marcacao de todos os registros
			
			//oMark:bAllMark := { || SetMarkAll(cSiglaMark,lMarcar := !lMarcar ) }        
			
			//oMark:SetValid({|| fVldMark() })
			//oMark:SetAfterMark( bAfterMark )//<<----
			oMark:Activate()
		EndIf
EndIf

Return Nil

/*
fVldMark
marca do browse

@author  oswaldo leite
@since 09/12/2014
@version 1.0*/

Static Function fVldMark()
Local aAreaAnt  := GetArea()  
Local lRet := .T.

If AllTrim(SE2->E2_XMARCA) == AllTrim(cSiglaMark) 

	lRet := .F.
Endif

RestArea( aAreaAnt )
Return lRet


/*
ModelDef
Funcao MVC para criar o modelo de dados

@author
@since 09/12/2014
@version 1.0
*/              
Static Function ModelDef()
Local oModel	:= Nil
Local oStruQ01	:= FWFormStruct(1,"SE2") 
Local bPreValid	:= Nil
Local bPosValid := Nil
Local bCommit 	:= Nil
Local bCancel	:= Nil  
       
bCommit := {|oModel|CommitMdl(oModel)}     
bPreValid := {|oModel|MeuPre(oModel)}
bPosValid := {|oModel|MeuPos(oModel)}

// Criacao da Modelo
oModel:= MpFormMOdel():New("ALFINP14"/* É O MESMO NOME DO FONTE E NAO PODE SER O NOME DE UMA USER FUNCTION*/ ,   , /**/,   ;
             bCommit/*bCommitbCommit*/ , ; //SE VC NÃO IMPLEMENTA ESTA FUNCAO O MVC SEMPRE GRAVA TUDO PRA VC. MAS SE VC A IMPLEMENTA O MVC NAO GRAVA NADA, ELE ESPERA Q VC GRAVE
               /*bCancel*/ )

// Cabecalho      
oModel:AddFields("MdFieldQ01",Nil,oStruQ01,/*prevalid*/,{ | oModel | MeuPos( oModel ) } ,/*bCarga*/)                                                                       

oModel:SetDescription("Objetivos")
//oModel:SetPrimaryKey({ "ZZ3_FILIAL","ZZ3_COD","ZZ3_LOCAL", "ZZ3_USUA" })

Return ( oModel )

/*
CommitMdl
consiste dados

@author  oswaldo leite
@since 09/12/2014
@version 1.0
*/
Static Function CommitMdl(oModel)
Local lRet := .T.
Local cAliasGps := GetNextAlias()
Local nX			:= 0            
Local oModel 	:=  FWModelActive()//FwLoadModel("XF003")
Local oModelG02	:= oModel:GetModel("MdFieldQ01")
Local nLinAt		:= 0
Local cQrysdb     
Local cquery
Local aGrid := {}                                  
Local nOpc			:= oModel:GetOperation()
Local cOld     := ''
Local cAtual   := ''
//Local cIDGPS   := SuperGetMV("ES_GPSFI",, '')  
Local oModelG02	:= oModel:GetModel("MdFieldQ01")

RETURN lRet  // f EVITA FECHAR A JANELA   t DEIXA FECHAR     ...MAS SO SALVA SE VC ASSIM DEXIAR EM SEU METODO

/*
ViewDef
Funcao MVC para criar as Views

@author 
@since 09/12/2014
@version 1.0
*/
Static Function ViewDef()

Local oModel 	:= FwLoadModel("ALFINP14")/* É O MESMO NOME DO FONTE E NAO PODE SER O NOME DE UMA USER FUNCTION*/
Local cCmpFil	:= ""
Local oStruQ01	:= FWFormStruct(2,"SE2", {|x| AllTrim( x ) + "|" $ 'E2_NUM|E2_PREFIXO|E2_TIPO|' }) 
Local oView 	:= Nil
         
// Instacia a View
oView := FwFormView():New()
oView:SetModel(oModel)
         
// Cabecalho
oView:AddField('VwFieldQ01', oStruQ01 , 'MdFieldQ01') 
// Cria os panels 
oView:CreateHorizontalBox("SUPERIOR",100)
// Define 
oView:SetOwnerView('VwFieldQ01',"SUPERIOR")
// Habilita titulos para melhor visualizacao do usuario
oView:EnableTitleView('VwFieldQ01',"Dados Cadastrais" )
Return(oView)

/*
MenuDef
Funcao generica MVC com as opcoes de menu

@author 
@since 09/12/2014
@version 1.0
*/

Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE 'PESQ' 	    ACTION "PesqBrw"           OPERATION 1 ACCESS 0  //"Pesquisar"

Return ( aRotina )


 /*
SetMarkAll
Marca todos registros

@author 
@since 09/12/2014
@version 1.0
*/

Static Function SetMarkAll(cMarca,lMarcar )
ALert ("Opção não permitida!")
/*Local aAreaAnt  := GetArea()

SE2->( DbGoTop() )
While !(SE2->( Eof() ))
	SE2->( RecLock( 'SE2', .F. ) )
	SE2->E2_XMARCA := IIf( lMarcar, cMarca, '  ' )
	SE2->E2_XIDGPS :=mv_par01
	SE2->( MsUnLock() )
	SE2->( dbSkip() )
EndDo

RestArea( aAreaAnt )*/
Return .T.

/*
MeuPos
consiste dados

@author  totvs
@since 09/12/2014
@version 1.0
*/
Static Function MeuPos(oModel)
Local lRet := .T.
Local nX			:= 0                   
Local oModel 	:=  FWModelActive()//FwLoadModel("XF003")
Local oModelG02	:= oModel:GetModel("MdFieldQ01")
Local nLinAt		:= 0
Local cQrysdb     
Local cquery
Local aGrid := {}                                  
Local nOpc			:= oModel:GetOperation()

Local oModelG02	:= oModel:GetModel("MdFieldQ01")

nOpc := oModelG02:GETOPERATION()


RETURN lRet  // f EVITA FECHAR A JANELA   t DEIXA FECHAR     ...MAS SO SALVA SE VC ASSIM DEXIAR EM SEU METODO

Static Function MarcaS()
Local nAt		:= oMark:At()
Local nCont		:= 0
Local lMark		:= oMark:IsMark()

Local cMark		:= oMark:Mark()

If !lMark
	alert ("cmark em branco")
	cMark	:= ""
else 
	alert ("cmark alimentado")
EndIf

RecLock("SE2",.F.)
SE2->E2_XMARCA	:= cMark

If Empty(cMark)
	SE2->E2_XIDGPS := ""
Else		
	SE2->E2_XIDGPS := mv_par01
EndIf
	
MsUNLock()



Return .T. 
