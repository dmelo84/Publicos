#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"

/*
ALFINP03
seleciona titulos para GPS

@author TOTVS 
@since 09/12/2014
@version 1.0
*/
User Function ALXFINP13()//execblock("ALXFINP13")
Local oBrowse 	:= Nil
Local aCampos    := {}
Local lMarcar    := .F.   
Local lMantem := .T.
Local lOk := .F. 

Private lMarcouAlgum := .F.
Private oMark
Private aRotina 
Private cSiglaMark := "TI"//Alltrim(Date())+"-"+AllTrim(Time())
Private cPerg := "MIDXGPS"
Private cFinRgps
Private bAfterMark:= {|| MarcaS() }
Private aSelSE2 := {}

If !MayIUseCode("ALXFINP13")
	Alert(" Janela já está em uso ! Não é possível utilizá-la no momento!")
	return
EndIf
dbselectArea('SE2')
dbselectarea('SX6')
SX6->(dbsetorder(1))
SX6->( dbseek(Fwxfilial('SE2') + "ES_GPSFI")  )
			
If SX6->(Eof())
    ALert("Não existe o Parâmetro ES_GPSFI nesta empresa-filial para o controle do ID!")
    return
EndIf  



cFinRgps := " .AND. E2_TIPO = 'INS'  "
    
//cFinRgps := " .AND. (E2_INSS > 0 .OR. "
//cFinRgps += "(E2_INSS = 0 .AND. E2_TIPO IN " + FormatIn(MVINSS+'INA',,3) + "))  "
	
     


while lMantem

	If	pergunte(cPerg,.T.)
	    
		If empty(mv_par02)
	    	ALert ("Informe o Título Até")
			Loop
		Else
			If mv_par01 > mv_par02
		    	ALert ("Título De deve ser menor ou igual ao Título Até")
				Loop
			EndIf
		Endif
		
		
		If empty(mv_par04)
	    	ALert ("Informe o Prefixo Até")
			Loop
		Else
			If mv_par03 > mv_par04
		    	ALert ("Prefixo De deve ser menor ou igual ao Prefixo Até")
				Loop
			EndIf
		Endif
		
		LOK := .T.	 
		lMantem := .F.	
	else
		Alert ("Operação cancelada!")
		lMantem := .F.	
	endif
	
End


If lOk
  
		TCSQLExec("UPDATE " + RetSqlName('SE2') + " SET E2_XMARCA = ''  WHERE E2_XIDGPS = '' AND E2_XMARCA = '" + cSiglaMark + "' AND E2_FILIAL = '" + Fwxfilial('SE2') + "'"  )
	
		aRotina := MenuDef()
		
		//-- Instanciamento do classe
		oMark:= FWMarkBrowse():New()
		//-- Definição da tabela a ser utilizada
		oMark:SetAlias('SE2')
		oMark:SetDescription('Títulos para marcarmos com o ID GPS')
		
		//oMark:SetFieldMark( 'E2_XMARCA' )//<----
		//alert ('ok ta compilado')
		omARK:SetFilterDefault(" E2_FILIAL = '" + Fwxfilial('SE2') + "' .AND. ( E2_XIDGPS = '' )    .AND. E2_NUM >= '" + mv_par01 + "' .AND. E2_NUM <= '" + mv_par02 + "' .AND. E2_PREFIXO >= '" + mv_par03 + "' .AND. E2_PREFIXO <= '" + mv_par04 + "'" +   cFinRgps   + " .AND. E2_EMISSAO >= '" + dtos(mv_par05) + "' .AND. E2_EMISSAO <= '" + dtos(mv_par06) + "'" )
			
			
			
		//-- Define o campo que sera utilizado para a marcação    
		oMark:SetFieldMark( 'E2_XMARCA' )    
		oMark:SetMark(cSiglaMark, 'SE2', 'E2_XMARCA')
		
		
		oMark:bAllMark := { || SetMarkAll(cSiglaMark,lMarcar := !lMarcar ), oMark:Refresh(.T.)  }        

		//oMark:SetValid({|| fVldMark() })
		
		 
		//-- Define a marcacao de todos os registros
		
		//oMark:bAllMark := { || SetMarkAll(cSiglaMark,lMarcar := !lMarcar ), oMark:Refresh(.T.)  }        
		
//		oMark:SetValid({|| fVldMark() })
		//oMark:SetDoubleCLick({|| Marcas() })
		//oMark:bMark    := bAfterMark 
		oMark:SetAfterMark( bAfterMark )//<<----
		oMark:Activate()
		
		
	//Else
	//	Alert ("Parâmetro ES_GPSFI não localizado no sistema! Operação Cancelada!")
	//endif
	
EndIf

Return Nil

/*
fVldMark
marca do browse

@author  totvs
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

@author  totvs
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
oModel:= MpFormMOdel():New("ALFINP13"/* É O MESMO NOME DO FONTE E NAO PODE SER O NOME DE UMA USER FUNCTION*/ ,   , /**/,   ;
             bCommit/*bCommitbCommit*/ , ; //SE VC NÃO IMPLEMENTA ESTA FUNCAO O MVC SEMPRE GRAVA TUDO PRA VC. MAS SE VC A IMPLEMENTA O MVC NAO GRAVA NADA, ELE ESPERA Q VC GRAVE
               /*bCancel*/ )

// Cabecalho      
oModel:AddFields("MdFieldQ01",Nil,oStruQ01,/*prevalid*/,{ | oModel | MeuPos( oModel ) } ,/*bCarga*/)                                                                       

oModel:SetDescription("Objetivos")

Return ( oModel )

/*
CommitMdl
consiste dados

@author  totvs
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

TCSQLExec("UPDATE " + RetSqlName('SE2') + " SET E2_XMARCA = ''  WHERE E2_XIDGPS = '' AND E2_XMARCA = '" + cSiglaMark + "' ")
	
RETURN lRet  

/*
ViewDef
Funcao MVC para criar as Views

@author totvs
@since 09/12/2014
@version 1.0
*/
Static Function ViewDef()

Local oModel 	:= FwLoadModel("ALFINP13")/* É O MESMO NOME DO FONTE E NAO PODE SER O NOME DE UMA USER FUNCTION*/
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
//ADD OPTION aRotina TITLE 'PESQ' 	    ACTION "PesqBrw"           OPERATION 1 ACCESS 0  //"Pesquisar"
ADD OPTION aRotina TITLE 'Excluir Id' 	    ACTION "U_EFINP13" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Consultar Id' 	    ACTION "U_CFINP13" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Filtrar' 	    ACTION "U_FFINP13" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Gerar Id' 	    ACTION "U_IFINP13" OPERATION 3 ACCESS 0


Return ( aRotina )


 /*
SetMarkAll
Marca todos registros

@author 
@since 09/12/2014
@version 1.0
*/

Static Function SetMarkAll(cMarca,lMarcar )
Local aAreaAnt  := GetArea()
Local cAuxMarca := ""
Local nInd      := 0
Local nPrimeiro := 10
Local nUltimo   := 0
Local oLista
Local cAiasTmp := oMark:Alias()

aSelSE2 := {}
While (cAiasTmp)->(!Eof())
	
	If !Empty(  (cAiasTmp)->(E2_XMARCA)  )
		cAuxMarca := ""
	Else
		cAuxMarca := cMarca
	EndIf
	
	RecLock("SE2",.F.)
	(cAiasTmp)->(E2_XMARCA)	:= cAuxMarca
	
	If Empty(cAuxMarca)
		//SE2->E2_XIDGPS := ""
		nPosOrd := aScan( aSelSE2, { |x|       AllTrim( x[1] ) == AllTrim((cAiasTmp)->(E2_FILIAL) )  ;  
		                                 .And. AllTrim( x[2] ) == AllTrim((cAiasTmp)->(E2_NUM)    )     ;
		                                 .And. AllTrim( x[3] ) == AllTrim((cAiasTmp)->(E2_PREFIXO) ) ;
		                                 .And. AllTrim( x[4] ) == AllTrim((cAiasTmp)->(E2_PARCELA) ) ;
		                                 .And. AllTrim( x[5] ) == AllTrim((cAiasTmp)->(E2_TIPO)    )    ;
		                                 .And. AllTrim( x[6] ) == AllTrim((cAiasTmp)->(E2_FORNECE) ) ;
		                                 .And. AllTrim( x[7] ) == AllTrim((cAiasTmp)->(E2_LOJA)    ) 	} )
	
		If nPosOrd == 1    
	
			//alert ("DESMARCAR "+AllTrim((cAiasTmp)->(E2_FILIAL) )  + " " + AllTrim((cAiasTmp)->(SE2->E2_NUM)) + " " + AllTrim((cAiasTmp)->(SE2->E2_PREFIXO)) + " " + AllTrim((cAiasTmp)->(SE2->E2_PARCELA)) )
			
			ADEL(aSelSE2,nPosOrd)
			ASIZE(aSelSE2,Len(aSelSE2)-1)	
		EndIf
	Else	
	
		nPosOrd := aScan( aSelSE2, { |x|       AllTrim( x[1] ) == AllTrim((cAiasTmp)->(E2_FILIAL) )  ;  
		                                 .And. AllTrim( x[2] ) == AllTrim((cAiasTmp)->(E2_NUM)    )     ;
		                                 .And. AllTrim( x[3] ) == AllTrim((cAiasTmp)->(E2_PREFIXO) ) ;
		                                 .And. AllTrim( x[4] ) == AllTrim((cAiasTmp)->(E2_PARCELA) ) ;
		                                 .And. AllTrim( x[5] ) == AllTrim((cAiasTmp)->(E2_TIPO)    )    ;
		                                 .And. AllTrim( x[6] ) == AllTrim((cAiasTmp)->(E2_FORNECE) ) ;
		                                 .And. AllTrim( x[7] ) == AllTrim((cAiasTmp)->(E2_LOJA)    ) 	} )
	
		If nPosOrd == 0
			//alert ("MARCAR "+AllTrim((cAiasTmp)->(E2_FILIAL) )  + " " + AllTrim((cAiasTmp)->(SE2->E2_NUM)) + " " + AllTrim((cAiasTmp)->(SE2->E2_PREFIXO)) + " " + AllTrim((cAiasTmp)->(SE2->E2_PARCELA)) )
			
			Aadd(aSelSE2,{(cAiasTmp)->(E2_FILIAL)  ,(cAiasTmp)->(E2_PREFIXO) ,(cAiasTmp)->(E2_NUM) , ;
			              (cAiasTmp)->(E2_PARCELA) ,(cAiasTmp)->(E2_TIPO)    ,(cAiasTmp)->(E2_FORNECE) , ;
			              (cAiasTmp)->(E2_LOJA) })
		EndIf	
		
	EndIf
	
	MsUnLock()
	
	(cAiasTmp)->(Dbskip())
End




RestArea( aAreaAnt )
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



/*
Marcas
marca reg no grid

@author TOTVS 
@since 09/12/2014
@version 1.0
*/
Static Function MarcaS()
Local nAt		:= oMark:At()
Local nCont		:= 0
Local lMark		:= oMark:IsMark()
Local cMark		:= oMark:Mark()

If !lMark
	cMark	:= ""
EndIf

RecLock("SE2",.F.)
SE2->E2_XMARCA	:= cMark

If Empty(cMark)
	//SE2->E2_XIDGPS := ""
	nPosOrd := aScan( aSelSE2, { |x|       AllTrim( x[1] ) == AllTrim(SE2->E2_FILIAL)  ;  
	                                 .And. AllTrim( x[2] ) == AllTrim(SE2->E2_NUM)     ;
	                                 .And. AllTrim( x[3] ) == AllTrim(SE2->E2_PREFIXO) ;
	                                 .And. AllTrim( x[4] ) == AllTrim(SE2->E2_PARCELA) ;
	                                 .And. AllTrim( x[5] ) == AllTrim(SE2->E2_TIPO)    ;
	                                 .And. AllTrim( x[6] ) == AllTrim(SE2->E2_FORNECE) ;
	                                 .And. AllTrim( x[7] ) == AllTrim(SE2->E2_LOJA) 	} )

	If nPosOrd == 1
		
		ADEL(aSelSE2,nPosOrd)
		ASIZE(aSelSE2,Len(aSelSE2)-1)	
	EndIf
Else	

	nPosOrd := aScan( aSelSE2, { |x|       AllTrim( x[1] ) == AllTrim(SE2->E2_FILIAL)  ;  
	                                 .And. AllTrim( x[2] ) == AllTrim(SE2->E2_NUM)     ;
	                                 .And. AllTrim( x[3] ) == AllTrim(SE2->E2_PREFIXO) ;
	                                 .And. AllTrim( x[4] ) == AllTrim(SE2->E2_PARCELA) ;
	                                 .And. AllTrim( x[5] ) == AllTrim(SE2->E2_TIPO)    ;
	                                 .And. AllTrim( x[6] ) == AllTrim(SE2->E2_FORNECE) ;
	                                 .And. AllTrim( x[7] ) == AllTrim(SE2->E2_LOJA) 	} )

	If nPosOrd == 0
		
		Aadd(aSelSE2,{SE2->E2_FILIAL ,SE2->E2_PREFIXO ,SE2->E2_NUM ,SE2->E2_PARCELA ,SE2->E2_TIPO ,SE2->E2_FORNECE ,SE2->E2_LOJA })
	EndIf	
	//SE2->E2_XIDGPS := cIDGPS
	//lMarcouAlgum := .T.
EndIf
MsUnLock()	


oMark:Refresh(.F.)

Return .T. 


/*
EFINP13
exclui ID

@author TOTVS 
@since 09/12/2014
@version 1.0
*/
User function EFINP13()
aSelSE2 := {}
U_ALXFINP23(.T.)
oMark:Refresh(.T.)
return


/*
CFINP13
consulta ID

@author TOTVS 
@since 09/12/2014
@version 1.0
*/
User function CFINP13()

U_ALXFINP23(.F.)

return


/*
IFINP13
gera ID

@author TOTVS 
@since 09/12/2014
@version 1.0
*/
User function IFINP13()
Local nInd        := 1
Local lHouveMarca := .F.
Local cIDGPS      := ''//SuperGetMV("ES_GPSFI",, '')
Local cAux        := ''
  
  
dbselectarea('SX6')
SX6->(dbsetorder(1))
SX6->( dbseek(Fwxfilial('SE2') + "ES_GPSFI")  )
			
If SX6->(!Eof())
    cIDGPS := AllTrim(SX6->(FIELDGET(FIELDPOS("X6_CONTEUD"))))
EndIf  
  
          
If Empty(cIDGPS)
	cIDGPS	:= Replicate("0" , TamSX3("E2_XIDGPS")[1])
EndIf
	
cIDGPS	:= Soma1(cIDGPS)
	      
	      
dbselectarea('SX6')
SX6->(dbsetorder(1))
SX6->( dbseek(fwxfilial('SE2') + "ES_GPSFI")  )
			
if SX6->(!Eof())                                
    Begin Transaction
    
    DbSelectArea('SE2')
	DbSetorder(1)	
	
  /*  
	DbSelectArea('SE2')
	DbSetorder(1)	
	PutMV("ES_GPSFI",cIDGPS)

	dbselectarea('SX6')
	SX6->(dbsetorder(1))
	SX6->( dbseek(xfilial('SE2') + "ES_GPSFI")  )
				
	If SX6->(!Eof())
	    cAux := AllTrim(SX6->X6_CONTEUD)
	EndIf  
*/	     
	      
	For nInd := 1 to Len(aSelSE2)
		//alert (str(nInd) + "  " + aSelSE2[nInd][1]+ "  " + aSelSE2[nInd][2] +  "  " +  aSelSE2[nInd][3] +  "  " +  aSelSE2[nInd][4]   )
		
		SE2->(DbSeek( aSelSE2[nInd][1]+aSelSE2[nInd][2]+aSelSE2[nInd][3] +  aSelSE2[nInd][4]+aSelSE2[nInd][5]   +aSelSE2[nInd][6]   +aSelSE2[nInd][7] )  )
		
		If SE2->(!Eof()) .And. ;
	         AllTrim(aSelSE2[nInd][1]) == AllTrim(SE2->E2_FILIAL)  .And. ; 
	         AllTrim(aSelSE2[nInd][2]) == AllTrim(SE2->E2_PREFIXO)  .And.  ;
	         AllTrim(aSelSE2[nInd][3]) == AllTrim(SE2->E2_NUM)  .And. ;
	         AllTrim(aSelSE2[nInd][4]) == AllTrim(SE2->E2_PARCELA)  .And. ; 
	         AllTrim(aSelSE2[nInd][5]) == AllTrim(SE2->E2_TIPO)  .And. ;
	         AllTrim(aSelSE2[nInd][6]) == AllTrim(SE2->E2_FORNECE)  .And.  ;
	         AllTrim(aSelSE2[nInd][7]) == AllTrim(SE2->E2_LOJA)
	         
	      	 If Empty(SE2->E2_XIDGPS)
	         	 lHouveMarca := .T.
		         reclock('SE2',.F.)
		         SE2->E2_XIDGPS := cIDGPS
		         SE2->E2_XMARCA := cSiglaMark 
		         MsUnLock()
	         
		         If !Empty(SE2->E2_TITPAI)
		             if TitPai()
				         //agora posicionou no PAI:
				         reclock('SE2',.F.)
				         SE2->E2_XIDGPS := cIDGPS
				         SE2->E2_XMARCA := cSiglaMark 
				         MsUnLock()
			         EndIf
		         EndIf
		         
	         EndIf
        EndIf
	Next
	
	If lHouveMarca

		PutMV("ES_GPSFI",cIDGPS)

		dbselectarea('SX6')
		SX6->(dbsetorder(1))
		SX6->( dbseek(xfilial('SE2') + "ES_GPSFI")  )

		dbselectarea('SZM')
		SZM->(DbSetOrder(1))
		SZM->( DbSeek(Fwxfilial('SE2') + AllTrim(cIDGPS)  ) )
		
		If SZM->(Eof())
			reclock('SZM',.T.) 
			SZM->ZM_FILIAL :=  Fwxfilial('SE2')
			SZM->ZM_ID := cIDGPS
			SZM->ZM_DATA := dDataBase
			SZM->ZM_HORA := Time()
			SZM->ZM_User := cUserName
			MsUnLock()
		EndIf
		
		ALert ("Foi gerado o ID " + cIDGPS )
		
	EndIf
	
	End Transaction
    If !lHouveMarca
    	Alert ("Selecione algum registro antes de Gerar o Id de GPS!")
    EndIf
	aSelSE2 := {}
	oMark:Refresh(.T.)
	
Else
	Alert ("ES_GPSFI: Parâmetro de controle do ID de GPS não localizado no sistema ")
EndIf

return//caux


/*
FFINP13
refaz pesquisa no grid

@author TOTVS 
@since 09/12/2014
@version 1.0
*/
User function FFINP13()

Local lMantem := .T.
Local lOk := .F. 



while lMantem

	If	pergunte(cPerg,.T.)
	    
		If empty(mv_par02)
	    	ALert ("Informe o Título Até")
			Loop
		Else
			If mv_par01 > mv_par02
		    	ALert ("Título De deve ser menor ou igual ao Título Até")
				Loop
			EndIf
		Endif
		
		
		If empty(mv_par04)
	    	ALert ("Informe o Prefixo Até")
			Loop
		Else
			If mv_par03 > mv_par04
		    	ALert ("Prefixo De deve ser menor ou igual ao Prefixo Até")
				Loop
			EndIf
		Endif
		
		If empty(mv_par06)
	    	ALert ("Informe a Emissão Até")
			Loop
		Else
			If mv_par05 > mv_par06
		    	ALert ("Emissão De deve ser menor ou igual ao Emissão Até")
				Loop
			EndIf
		Endif
		
		
		LOK := .T.	 
		lMantem := .F.	
	else
		Alert ("Operação cancelada!")
		lMantem := .F.	
	endif
	
End




If lOk
	TCSQLExec("UPDATE " + RetSqlName('SE2') + " SET E2_XMARCA = ''  WHERE E2_XIDGPS = '' AND E2_XMARCA = '" + cSiglaMark + "' ")
	
	aSelSE2 := {}
	oMark:CleanFilter()
	omARK:SetFilterDefault(" E2_FILIAL = '" + Fwxfilial('SE2') + "' .AND. ( E2_XIDGPS = '' )    .AND. E2_NUM >= '" + mv_par01 + "' .AND. E2_NUM <= '" + mv_par02 + "' .AND. E2_PREFIXO >= '" + mv_par03 + "' .AND. E2_PREFIXO <= '" + mv_par04 + "'"  +   cFinRgps   + "   .AND. E2_EMISSAO >= '"+ dtos(mv_par05) + "' .AND. E2_EMISSAO <= '" + dtos(mv_par06) + "' " )
	
	
	
	oMark:Refresh(.T.)
EndIf

return



/*
REINP13
Intervalo de ID´s para relatorio

@author TOTVS 
@since 09/12/2014
@version 1.0
*/
User function REINP13()
Local cRet := " "
Local lOk := .F.
Local lMantem := .T.
Private cPerg := "REPGPST"

SaveInter()

while lMantem

	If	pergunte(cPerg,.T.)
	    
		If empty(mv_par02)
	    	ALert ("Informe o ID GPS Até")
			Loop
		Else
			If mv_par01 > mv_par02
		    	ALert ("ID GPS De deve ser menor ou igual ao ID GPS Até")
				Loop
			EndIf
		Endif
		
		LOK := .T.	 
		lMantem := .F.
		
		If !Empty(mv_par01) 
			cRet += "  SE2.E2_XIDGPS >= '" + mv_par01 + "' AND "
		EndIf
		
		If !Empty(mv_par02) 
			cRet += "  SE2.E2_XIDGPS <= '" + mv_par02 + "' AND "
		EndIf
			
	Else
		lMantem := .F.	
	Endif
	
End

RestInter()

return cRet


Static function TitPai ()
Local lRet  := .F.
Local cE2Alias := GetNextAlias()
Local cNum  := ""
Local cPref := ""
Local cParc := ""
Local cTipo := ""
Local cForn := ""
Local cLoja := ""
Local aCampos := {}
//Exemplo do conteudo do E2_TITPAI -> "CCC1001     001NF 000000010001                    "

cPref := substr( AllTrim(SE2->E2_TITPAI), 1, TamSx3("E2_PREFIXO")[1]   )
cNum  := substr( AllTrim(SE2->E2_TITPAI), 4, TamSx3("E2_NUM")[1]       )
cParc := substr( AllTrim(SE2->E2_TITPAI),13, TamSx3("E2_PARCELA")[1]   )
cTipo := substr( AllTrim(SE2->E2_TITPAI),16, TamSx3("E2_TIPO")[1]      )
cForn := substr( AllTrim(SE2->E2_TITPAI),19, TamSx3("E2_FORNECE")[1]   )
cLoja := substr( AllTrim(SE2->E2_TITPAI),27, TamSx3("E2_LOJA")[1]      )

BeginSql Alias cE2Alias
			
		SELECT SE2.*  	       
		FROM %table:SE2% SE2 
		     WHERE               
				             SE2.E2_FILIAL   = %EXP:( SE2->E2_FILIAL  )%  AND 
				             SE2.E2_PREFIXO = %EXP:( cPref )% AND
				             SE2.E2_NUM     = %EXP:( cNum  )% AND
				             SE2.E2_PARCELA = %EXP:( cParc  )% AND
				             SE2.E2_TIPO    = %EXP:( cTipo  )% AND
				             SE2.E2_FORNECE = %EXP:( cForn  )% AND
				             SE2.E2_LOJA     = %EXP:( cLoja  )% 
				             AND SE2.%NotDel%        
										     
										                
EndSql
aCampos := GetLastQuery()
If (cE2Alias)->(!Eof())
	SE2->( DbGoTo( (cE2Alias)->(R_E_C_N_O_) )   )
	lRet := .T.
EndIf			

(cE2Alias)->(DbCloseArea())

return  lRet 