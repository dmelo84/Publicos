#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"


/*/{Protheus.doc} ModelDef
Definicao do Modelo

@author oswaldo leite
@since 06/08/2012
@version 11.7
/*/
Static Function ModelDef()
Local oStructSC7 	:= FWFormStruct(1,"SC7",{|cCampo| AllTrim(cCampo) $ "C7_XJUST"})
Local oModel 		:= Nil
Local bCommit 	    := Nil
Local bPosValid     := Nil

bCommit := {|oModel|CommitMdl(oModel)} 
bPosValid := {|oModel|PosValid(oModel)}   



//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("ALCO13",/*Pre-Validacao*/,/*Pos-Validacao*/,/*bCommit*/,/*Cancel*/)    

oModel:AddFields("SC7MASTER", Nil/*cOwner*/, oStructSC7 ,/*Pre-Validacao*/,bPosValid/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("SC7MASTER"):SetDescription("Pedido de Compra Rejeitado")
oModel:SetPrimaryKey({"SC7_FILIAL+SC7_NUM"})

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao da Interface

@author oswaldo leite
@since 06/08/2012
@version 11.7
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView  		:= Nil
Local oModel  	:= FWLoadModel("ALCO13")
Local oStructSC7 	:= FWFormStruct(2,"SC7",{|cCampo| AllTrim(cCampo) $ "C7_NUM|C7_XJUST"})

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "VIEW_CAB" , oStructSC7, "SC7MASTER" )
oView:CreateHorizontalBox( "HEADER" , 100 )
oView:SetOwnerView( "VIEW_CAB" , "HEADER" )
              
Return oView                                    

/*/{Protheus.doc} PosValid
Grava nome da ultima pessoa que editou pesos e volumes

@author oswaldo leite
@since 06/08/2012
@version 11.7
/*/
Static Function PosValid(oModel)     
/*
Local nX			:= 0            
Local oModel 	:=  FWModelActive()//FwLoadModel("XF003")

Local oModelSC5	:= oModel:GetModel("SC5MASTER")
Local oModelSC6	:= oModel:GetModel("SC6ITENS")
Local nLinAt		:= 0
Local cQrysdb     
Local cquery
Local aGrid := {}                                  
Local nOpc	:= oModel:GetOperation()                     

U_AVXFATA01(.T.)
                                         
DbSelectArea('SC6')
DbSetOrder(1)

For nX := 1 to oModelSC6:GetQtdLine()
	oModelSC6:GoLine( nX )
		
	If !(oModelSC6:IsDeleted())                                 			
		
		SC6->( DbSeek(xfilial('SC6')+ oModelSC5:GetValue  ("C5_NUM")+ oModelSC6:GetValue  ("C6_ITEM") ) )
		If SC6->(!Eof()) .And. Empty(SC6->C6_NOTA)                            

			RecLock('SC6',.F.)
			SC6->C6_QTDVEN :=  oModelSC6:GetValue  ("C6_XPEEM")
			SC6->C6_QTDLIB     :=  SC6->C6_QTDVEN 
			
			SC6->C6_VALOR  :=  SC6->C6_QTDVEN * SC6->C6_PRCVEN
			MsUnLock()      
			
			AjSC9(SC6->C6_QTDLIB)
		EndIf
	EndIf
Next
*/

return .T.


/*
CommitMdl
consiste dados

@author  oswaldo leite
@since 09/12/2014
@version 1.0
*/
Static Function CommitMdl(oModel)
Local lRet := .T.


RETURN lRet  // f EVITA FECHAR A JANELA   t DEIXA FECHAR     ...MAS SO SALVA SE VC ASSIM DEXIAR EM SEU METODO

