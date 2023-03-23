#include "protheus.ch"
User Function F114299()
	
	Local oProcess
	//incluído o parâmetro lEnd para controlar o cancelamento da janela
	oProcess := MsNewProcess():New({|lEnd| T114299(@oProcess, @lEnd) },"Teste MsNewProcess","Lendo Registros do Pedido de Vendas",.T.) 
	oProcess:Activate()
Return  
                                     
static Function T114299(oProcess, lEnd)   
	Local nCountC5
	Local nCountC6  
	//inserido este blocoDefault 
	lEnd := .F.
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbGotop()	
	nCountC5 := SC5->(RecCount())
	oProcess:SetRegua1(nCountC5)
	While SC5->(!Eof())               	
		sleep(300)	
		If lEnd	
			//houve cancelamento do processo		
			Exit	
		EndIf	       	
		oProcess:IncRegua1("Lendo Pedido de Venda:" + SC5->C5_NUM)             	
		DbSelectArea("SC6")   	
		DbSetOrder(1)   	
		DbClearFil()   	
		Set Filter to SC6->C6_FILIAL == xFilial("SC5") .And. SC6->C6_NUM == SC5->C5_NUM   	
		COUNT to nCountC6   	
		oProcess:SetRegua2(nCountC6)	
		While SC6->(!Eof())      		
			//inserido este bloco		
			If lEnd			
				//houve cancelamento do processo			
				Exit		
			EndIf	      	
			oProcess:IncRegua2("Pedido: "+SC5->C5_NUM+" - Item: "+SC6->C6_ITEM)		
			sleep(300)	    
			conout("Item: "+SC6->C6_ITEM)	   				      	
			SC6->(DbSkip())   	
		End  		       
		SC5->(DbSkip()) 
	End
Return