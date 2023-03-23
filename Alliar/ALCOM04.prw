
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"


//C7_XNUMPDC é o numero do pedido no Bionexo


//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM07()
tudo ok do pedido de compra

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function ALCOM07(cNumSc, cItemSc, cProd, lAtuSC7) 
Local nPosSolic	 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_NUMSC'})
Local nPosItemSC := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEMSC'})
Local nPosProd	 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})
Local nPosAprov	 := aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_APROV'})
Local nRepetido  := 0
Local nX
Local cGrp    := ""
Local cOldGrpapv := ""
Local lGrpUnico := .T.	
Local aLstGrupos := {}
Local cGrpUnico := ''
Local lPrimeiro  := .T. 
Local lPrimGrp   := ''
Local lAlgumItemComSolic := .F. //verifica se pelo menos um item do pedido é orginado por solicitacao de compra
Local lRet := .T.	
Local cGrpPadrao := SuperGetMV("ES_GRPAP",, '')	
Local nPosXRjtd := 0
Local nResXPos  := 0

/*
existirao tres tipos de pedido de compra:

1 pedido cujo itens são todos originados por SC1 (gravar grupo de aprovacao e submeter este pedido a aprovacao)
2 pedido cujo nenhum dos itens foram originados por SC1 ( NÃO gravar grupo de aprovacao e NÃO submeter este pedido a aprovacao)
3 pedido cujos itens são mesclados, parte deles originados por SC1 e outra parte não, (gravar grupo de aprovacao e submeter este pedido a aprovacao)

*/	

If Empty(cGrpPadrao)

	If !IsInCallStack("CNTA120")//pedido gerado por contrato ...nao consiste nada. Pois caso contrato tenho grp aprov no cabecalho todos ja estarao setados com o mesmo grupo
	                             //                                                 Mas caso nao haja grp aprov no cabecalho do contrato, deixarei pedido nascer ja liberado e sem grupo de aprovacao nos itens do pedido
	
		If l120Auto//<-- trata erro para exibi-lo em execauto
			Help(" ",1,"O Parâmetro referente ao Grupo de Aprovação Default ES_GRPAP está sem informação! Configure adequadamente o parâmetro antes de prosseguir!")
		Else
			Alert ("O Parâmetro referente ao Grupo de Aprovação Default ES_GRPAP está sem informação! Configure adequadamente o parâmetro antes de prosseguir!")
		EndIf
		lRet := .F.
		
	EndIf
Else

	If !IsInCallStack("CNTA120")//pedido gerado por contrato ...nao consiste nada. Pois caso contrato tenho grp aprov no cabecalho todos ja estarao setados com o mesmo grupo
	                             //                                                 Mas caso nao haja grp aprov no cabecalho do contrato, deixarei pedido nascer ja liberado e sem grupo de aprovacao nos itens do pedido
	

		For nX := 1 To Len(aCols)
							
			If !gdDeleted(nX)
				
				//============================================================================
				//tratamemto exclusivo devido a copia de pedidos de compras rejeitados. 
				//nesta copia, o status do pedido muda de ROSA para AZUL 
				nPosXRjtd :=  aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XRJTD'})
				nResXPos  :=  aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_RESIDUO'})
				If nPosXRjtd > 0 .And. nResXPos > 0
					If Empty(aCols[nx,nResXPos]) .And. Alltrim(aCols[nx,nPosXRjtd]) == '1' 
						aCols[nx,nPosXRjtd] := '2'
					EndIf
				EndIf
				//============================================================================
				
				If lPrimeiro 
					lPrimeiro  := .F.
					lPrimGrp   := aCols[nx,nPosAprov]
				else
					If lPrimGrp != aCols[nx,nPosAprov]
		
						If l120Auto//<-- trata erro para exibi-lo em execauto
							Help(" ",1,"Linha " + AllTrim(STR(nx)) + ": Grupo de aprovação difere dos demais grupos utilizados no Pedido! Utilize um único Grupo de Aprovação!")
						Else
							Alert ("Linha " + AllTrim(STR(nx)) + ": Grupo de aprovação difere dos demais grupos utilizados no Pedido! Utilize um único Grupo de Aprovação!")
						EndIf
						
						lRet := .F.
						exit
					EndIf
				EndIf
				 
				If Empty(aCols[nx,nPosAprov])
				
					If l120Auto//<-- trata erro para exibi-lo em execauto
						Help(" ",1,"Linha " + AllTrim(STR(nx)) + ": Grupo de aprovação não informado!")
					Else
						Alert ("Linha " + AllTrim(STR(nx)) + ": Grupo de aprovação não informado!")
					EndIf
					
					lRet := .F.
					exit
				EndIf
				  
			EndIf
		Next
		
	
	EndIf
		
EndIf


return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM5()
Copia dados da SC1 exibida na telinha F4 do ações relacionadas da tela do pedido de compra para o browse do SC7

@since 28/01/2013
@version 1.0
@return NIL
/*/
User Function ALCOM5() 
Local aArea     := GetArea()
Local nItemSc   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEMSC"})
Local nNumSc    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_NUMSC" })
Local nAprovSc  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_APROV" })
Local nProdSc   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO" })
Local nIndx     := 0
Local cAliasApv
Local cPrdALias
Local cB1Grupo  := ''
Local cProd     := ''
Private cC1Solic := ''
Private cC1xAprov := ''



For nIndx := 1 to Len(aCols)

	If !Empty(aCols[nIndx][nNumSc]) .And. !Empty(aCols[nIndx][nItemSc]) .ANd. PosSc1(aCols[nIndx][nNumSc], aCols[nIndx][nItemSc], aCols[nIndx][nProdSc]) 
		aCols[n][nAprovSc] := cC1xAprov
	EndIf
Next


restArea(aArea)
return

//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM04()
Troca grupo de aprovacao no ato da geracao do pedido na tela de analise de cotacao - PE AVALCOT

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function ALCOM04(cNumSc, cItemSc, cProd, lAtuSC7) 
Local cAliasSc1 := ''
Local cGrpAprov := ""


	
cAliasSc1 := GetNextAlias()
	
	
BeginSql Alias cAliasSc1
	
	SELECT SC1.C1_XAPROV, SC1.C1_USER, SC1.C1_NUM, SC1.C1_ITEM  //C1_SOLICIT  
	       
	       FROM %table:SC1% SC1
	              
	       WHERE              
	             SC1.C1_FILIAL     = %xFilial:SC1%
	             AND SC1.%NotDel%
	             AND SC1.C1_NUM     = %EXP:( cNumSc    )%    
	             AND SC1.C1_ITEM    = %EXP:( cItemSc    )%   
EndSql
	
If (cAliasSc1)->(!Eof()) .And. ;
	  AllTrim( (cAliasSc1)->(C1_NUM) ) == AllTrim(cNumSc)   .And.  ; 
      AllTrim( (cAliasSc1)->(C1_ITEM) ) == AllTrim(cItemSc)         
	
	If lAtuSC7
			reclock('SC7',.F.)
			SC7->C7_APROV := (cAliasSc1)->(C1_XAPROV)
			MsUNlock()
	EndIf
				
EndIf
	
(cAliasSc1)->(DbCLoseArea())

RETURN cGrpAProv

//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM8
Busca grupo de aprovacao

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

User function ALCOM8 (cB1Grupo, cProd, cSolic)
Local cRet := ''
Local cAliasApv := GetNextAlias()
Local lPorGrpGenerico := .F.
Local cGrpAprov := ""
Local nIndx := 0
//Local aAllUsuarios := AllUsers()
Local cGrpPrincDeUsuarios := ''
Local lOlhaApenasGrupoUsuarios := .F.
Local aRet := {}

PswOrder(2)
If PswSeek(cUserName ,.T.)//avaliar somente primeiro grupo ao qual este se encontra amarrado
	aRet := PswRet()
	
	If Len( aRet[1][10] ) > 0//caso o usuario esteja amarrado a algum grupo
		cGrpPrincDeUsuarios := aRet[1][10][1]
	EndIf
EndIf

/*
nIndx := aScan(aAllUsuarios,{|x| AllTrim(x[1][1]) == cSolic})


//avaliar somente primeiro grupo ao qual este se encontra amarrado
If nIndx > 0            
	If len(aAllUsuarios[nIndx][1][10]) > 0//caso o usuario esteja amarrado a algum grupo
		cGrpPrincDeUsuarios := aAllUsuarios[nIndx][1][10][1]
	EndIf
EndIf
*/
If !VincNoUsuario (cSolic, cGrpPrincDeUsuarios)//por definicao: o sistema ou olha somente no vinculo com o usuario ou somente no vinculo com grupo de usuarios...mas jamais nos dois!
	lOlhaApenasGrupoUsuarios := .T.
EndIf


//================================================================
//Passo 1 - verifica se tem grupo de estoque vinculado 
//verifica se existe um grupo de aprovacao amarrado ao produto ou ao grupo do produto
If Empty(cRet) .And.  !Empty(cB1Grupo)

	If lOlhaApenasGrupoUsuarios
		BeginSql Alias cAliasApv
		
		SELECT SAI.*  
		       
		       FROM %table:SAI% SAI
		              
		       WHERE              
		             SAI.AI_FILIAL     = %xFilial:SAI%
		             AND SAI.%NotDel%
		             AND SAI.AI_GRUSER     = %EXP:( cGrpPrincDeUsuarios    )%    AND
		             SAI.AI_GRUPO   = %EXP:( cB1Grupo )%      
		EndSql
	Else
		BeginSql Alias cAliasApv
		
		SELECT SAI.*  
		       
		       FROM %table:SAI% SAI
		              
		       WHERE              
		             SAI.AI_FILIAL     = %xFilial:SAI%
		             AND SAI.%NotDel%
		             AND SAI.AI_USER     = %EXP:( cSolic    )%    AND
		             SAI.AI_GRUPO   = %EXP:( cB1Grupo )%  
		EndSql
	EndIf
	
	If (cAliasApv)->(!Eof())   .And.    AllTrim( (cAliasApv)->(AI_GRUPO) ) == AllTrim(cB1Grupo) 
		cRet := (cAliasApv)->(AI_APROV)
	EndIf
	
	//================================================================
	//Passo 2 - verifica se tem grupo: *    definido na SAI
	If Empty(cRet)
		(cAliasApv)->(DbCLoseArea())
	
		If lOlhaApenasGrupoUsuarios
	
			BeginSql Alias cAliasApv
			
			SELECT SAI.*  
			       FROM %table:SAI% SAI
			       WHERE              
			             SAI.AI_FILIAL     = %xFilial:SAI%
			             AND SAI.%NotDel%
			             AND SAI.AI_GRUSER     = %EXP:( cGrpPrincDeUsuarios    )%    AND
			             SAI.AI_GRUPO   = '*' AND SAI.AI_PRODUTO = '*'
			EndSql
			
		Else
			BeginSql Alias cAliasApv
			
			SELECT SAI.*  
			       FROM %table:SAI% SAI
			       WHERE              
			             SAI.AI_FILIAL     = %xFilial:SAI%
			             AND SAI.%NotDel%
			             AND SAI.AI_USER     = %EXP:( cSolic    )%    AND
			             SAI.AI_GRUPO   = '*' AND SAI.AI_PRODUTO = '*'
			EndSql
			
		EndIf
		
		If (cAliasApv)->(!Eof())   .And. AllTrim( (cAliasApv)->(AI_GRUPO) ) == '*' 
	   		cRet := (cAliasApv)->(AI_APROV)
		EndIf
	
	EndIf

	(cAliasApv)->(DbCLoseArea())
EndIf

If Empty(cRet)
	//================================================================		
	//Passo 3  - primeiro procura se existe algo vinculado apenas ao produto
	//================================================================
	If lOlhaApenasGrupoUsuarios
		BeginSql Alias cAliasApv
			
			SELECT SAI.*  
			       
			       FROM %table:SAI% SAI
			              
			       WHERE              
			             SAI.AI_FILIAL     = %xFilial:SAI%
			             AND SAI.%NotDel%
			             AND SAI.AI_GRUSER     = %EXP:( cGrpPrincDeUsuarios    )%    AND
			             
			             SAI.AI_PRODUTO = %EXP:( cProd    )%    
		EndSql
	Else
		BeginSql Alias cAliasApv 
			
			SELECT SAI.*  
			       
			       FROM %table:SAI% SAI
			              
			       WHERE              
			             SAI.AI_FILIAL     = %xFilial:SAI%
			             AND SAI.%NotDel%
			             AND SAI.AI_USER     = %EXP:( cSolic    )%    AND
			             
			             SAI.AI_PRODUTO = %EXP:( cProd    )%    
			EndSql
	EndIf
		
	If (cAliasApv)->(!Eof())   .And.   AllTrim( (cAliasApv)->(AI_PRODUTO) ) == AllTrim(cProd)      
		cRet := (cAliasApv)->(AI_APROV)
	EndIf

	(cAliasApv)->(DbCLoseArea())
	//================================================================
EndIf

If Empty(cRet)
	//Passo 2
	//caso não tenha localizado nada, utilizadar o grupo de aprovacao especificado no parametro padrao
	cRet := SuperGetMV("ES_GRPAP",, '')//utiliza um grupo de aprovador padrao
EndIf

return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PosSC1
posiciona SC1

@since 28/01/2013
@version 1.0
@return NIL
/*/

Static function PosSC1(cNum, cItem, cProd)
Local cC1ALias := GetNextAlias()
Local lRet     := .F.

cC1Solic := ''		
cC1xAprov:= ""
BeginSql Alias cC1ALias
				
	SELECT SC1.*  
	       FROM %table:SC1% SC1
	       WHERE              
		             SC1.C1_FILIAL     = %xFilial:SC1%
		             AND SC1.%NotDel%
		             AND SC1.C1_PRODUTO = %EXP:( cProd    )%
		             AND SC1.C1_NUM     = %EXP:( cNum    )%
				     AND SC1.C1_ITEM    = %EXP:( cItem    )%    
				             
EndSql
				
If (cC1ALias)->(!Eof()) .And. 	AllTrim( (cC1Alias)->(C1_PRODUTO) ) == AllTrim(cProd) ;
                        .And. 	AllTrim( (cC1Alias)->(C1_NUM)     ) == AllTrim(cNum) ;
                        .And. 	AllTrim( (cC1Alias)->(C1_ITEM)    ) == AllTrim(cItem)
    cC1Solic := (cC1ALias)->(C1_USER)
    cC1xAprov := (cC1ALias)->(C1_XAPROV)
    lRet     := .T.
EndIf
			
(cC1ALias)->(DbCLoseArea())

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM6()
seta grupo de aprovacao no pedido gerado via cotacao

@since 28/01/2013
@version 1.0
@return NIL
/*/
User Function ALCOM6( _cAlias ) 
Local aArea      := GetArea()
Local cProd      := ''
Local cAliasApv
Local cPrdALias
Local cB1Grupo   := ''
Local cRet       := ''
Local lProsseguir := .T.
Local lPorGrpGenerico := .F.
Local aAllUsuarios //:= AllUsers()
Local cGrpPrincDeUsuarios := ''
Local lOlhaApenasGrupoUsuarios := .F. 
LOcal aRet := {}
Local nIndx := 0
Private cC1Solic := __CUSERID
Private cFilSolc := CFILANT

Default _cAlias	:= ""

If IsInCallStack("CNTA120") 
	
	If Empty(CN9->CN9_XAPALI) //pedido gerado por contrato ... caso nao haja grp aprov no cabecalho do contrato, deixo pedido nascer ja liberado e sem grupo de aprovacao nos itens do pedido
		restArea(aArea)
		RETURN ''
	EndIf
EndIf

//produto
cAliasApv := GetNextAlias()
//aAllUsuarios := AllUsers()

/*
nIndx := aScan(aAllUsuarios,{|x| AllTrim(x[1][1]) == cC1Solic})

//avaliar somente primeiro grupo ao qual este se encontra amarrado
If nIndx > 0
	If len(aAllUsuarios[nIndx][1][10]) > 0//caso o usuario esteja amarrado a algum grupo
		cGrpPrincDeUsuarios := aAllUsuarios[nIndx][1][10][1]
	EndIf
EndIf
*/

PswOrder(2)
If PswSeek(cUserName ,.T.)//avaliar somente primeiro grupo ao qual este se encontra amarrado
	aRet := PswRet()
	
	If Len( aRet[1][10] ) > 0//caso o usuario esteja amarrado a algum grupo
		cGrpPrincDeUsuarios := aRet[1][10][1]
	EndIf
EndIf

If _cAlias == "SC1"
	cProd      := SC1->C1_PRODUTO
	cRet       := ""//M->C1_XAPROV
	cFilSolc   := SC1->(XFILIAL())
	lProsseguir := .T.
ElseIf !IsInCallStack("MATA110")  //tela de solicitacao de compras
		
	cProd      := M->C7_PRODUTO
	cRet       := M->C7_APROV
	cFilSolc   := SC7->(XFILIAL())
	lProsseguir := .T.	
Else
	cProd      := M->C1_PRODUTO
	cRet       := ""//M->C1_XAPROV
	cFilSolc   := SC1->(XFILIAL())
	lProsseguir := .T.
	
//	IF EMPTY(cC1Solic)
//		cC1Solic	:= __CUSERID
//	ENDIF 
	
EndIf


//If !VincNoUsuario (cC1Solic, cGrpPrincDeUsuarios)//por definicao: o sistema ou olha somente no vinculo com o usuario ou somente no vinculo com grupo de usuarios...mas jamais nos dois!
//	lOlhaApenasGrupoUsuarios := .T.
//	
//EndIf


If Empty(cRet) .And. !Empty(cProd)  .And. lProsseguir 


	If Empty(cRet)
	
		//======================================================
		//Passo 3 - verifica se tem produto vinculado 
		/*----------------------------------------
			01/06/2018 - Jonatas Oliveira - Compila
			Alterado a ordem para Primeiro verifique
			se o produto está vinculado
		------------------------------------------*/
		If lOlhaApenasGrupoUsuarios
/*
			BeginSql Alias cAliasApv
						
				SELECT SAI.*  
						       
			       FROM %table:SAI% SAI
							              
					       WHERE              
				             SAI.AI_FILIAL     = %xFilial:SAI%
				             AND SAI.%NotDel%
				             AND SAI.AI_GRUSER     = %EXP:( cGrpPrincDeUsuarios    )%    AND
				             SAI.AI_PRODUTO = %EXP:( cProd    )%    
			EndSql
*/			
		Else
			BeginSql Alias cAliasApv
						
				SELECT SZN.*  
							       
			       FROM %table:SZN% SZN
							              
					       WHERE              
					             SZN.ZN_FILIAL     = %EXP:( cFilSolc    )% 
					             AND SZN.%NotDel%
					             AND SZN.ZN_PRODUTO = %EXP:( cProd    )%    
			EndSql
	
		EndIf
				
		If (cAliasApv)->(!Eof())   .And. AllTrim( (cAliasApv)->(ZN_PRODUTO) ) == AllTrim(cProd)      
			cRet := (cAliasApv)->(ZN_APROV)
			
		EndIf
				
		(cAliasApv)->(DbCLoseArea())
				
		//======================================================
	EndIf
	
	IF EMPTY(cRet)

		cB1Grupo  :=  ''
			
		cPrdALias := GetNextAlias()
			
		BeginSql Alias cPrdALias
						
				SELECT SB1.B1_GRUPO, SB1.B1_COD  
						       
			       FROM %table:SB1% SB1
						              
				       WHERE              
				             SB1.B1_FILIAL     = %xFilial:SB1%
				             AND SB1.%NotDel%
				             AND SB1.B1_COD     = %EXP:( cProd    )%    
						             
		EndSql
					
		If (cPrdALias)->(!Eof()) .ANd. 	AllTrim( (cPrdAlias)->(B1_COD) ) == AllTrim(cProd) 
			cB1Grupo := (cPrdALias)->(B1_GRUPO)
		EndIf
				
		(cPrdALias)->(DbCLoseArea())
		
		lPorGrpGenerico := .F.
		
		//======================================================
		//Passo 1 - verifica se tem grupo de estoque vinculado 
	
		If !Empty(cB1Grupo)
		
			If lOlhaApenasGrupoUsuarios
			/*			
			
				BeginSql Alias cAliasApv
					
						SELECT SAI.*  
						       
						       FROM %table:SAI% SAI
						              
						       WHERE              
						             SAI.AI_FILIAL     = %xFilial:SAI%
						             AND SAI.%NotDel%
						             AND SAI.AI_GRUSER     = %EXP:( cGrpPrincDeUsuarios    )%    AND
						             SAI.AI_GRUPO   = %EXP:( cB1Grupo )%      
				EndSql
				*/
			Else
				
				BeginSql Alias cAliasApv
					
						SELECT SZN.*  
						       
						       FROM %table:SZN% SZN
						              
						       WHERE              
						             SZN.ZN_FILIAL     = %EXP:( cFilSolc    )% 
						             AND SZN.%NotDel%						             						             
						             AND SZN.ZN_GRUPO   = %EXP:( cB1Grupo )%      
				EndSql
				
			EndIf	
			
			If (cAliasApv)->(!Eof())   .And.  AllTrim( (cAliasApv)->(ZN_GRUPO) ) == AllTrim(cB1Grupo)
				cRet := (cAliasApv)->(ZN_APROV)
			EndIf
			
			If Empty(cRet)
		
				(cAliasApv)->(DbCLoseArea())
		
				//========================================================================
				//Passo 2 - Verifica se tem grupo: * 
				//========================================================================
				If lOlhaApenasGrupoUsuarios
				
						/*
						BeginSql Alias cAliasApv
							
								SELECT SAI.*  
								       
								       FROM %table:SAI% SAI
								              
								       WHERE              
								             SAI.AI_FILIAL     = %xFilial:SAI%
								             AND SAI.%NotDel%
								             AND SAI.AI_GRUSER     = %EXP:( cGrpPrincDeUsuarios  )%    AND
								             SAI.AI_GRUPO   = '*'   AND SAI.AI_PRODUTO = '*'  
						EndSql
						*/
				Else
				
						BeginSql Alias cAliasApv
							
								SELECT SZN.*  
								       
								       FROM %table:SZN% SZN
								              
								       WHERE              
								             SZN.ZN_FILIAL   = %EXP:( cFilSolc    )% 
								             AND SZN.%NotDel%
								             AND SZN.ZN_GRUPO   = '*'  AND SZN.ZN_PRODUTO = '*'
						EndSql
						
				ENdIf
			
				If (cAliasApv)->(!Eof())   .And.  AllTrim( (cAliasApv)->(ZN_GRUPO) ) == AllTrim("*")      
					lPorGrpGenerico := .T.
					cRet := (cAliasApv)->(ZN_APROV)
					
				ENdIf
				
			EndIf
		
			(cAliasApv)->(DbCLoseArea())
			
		EndIf
	
	ENDIF 
	


	
	If Empty(cRet)
		cRet := SuperGetMV("ES_GRPAP",, '')//utiliza um grupo de aprovador padrao
	EndIf
					
EndIf

restArea(aArea)


return cRet

//ESTA FUNCAO NAO E UTILIZADA
//vrf teste de execauto para garantir que mensagem sera exibida para bionexo
user function xteste ()
Local aCbPC := {}
Local aItPc := {}
Local cArqErrAuto := ''
Local cMsgErro := ''
Local cIt := "0001"
Local cNumPed		
Local aItem := {}
Private lMsErroAuto := .F.

	dbselectarea('SC7')
	dbsetorder(1)
	SC7->(dbgotop())

	cNumPed := CriaVar('C7_NUM', .T.)

	aCbPC:= {}
	aadd(aCbPC,{"C7_FILIAL"  ,xFilial("SC7")		,Nil}) //SC1->C1_FILENT
	aadd(aCbPC,{"C7_NUM"     ,cNumPed				,Nil})
	aadd(aCbPC,{"C7_EMISSAO" ,dDataBase				,Nil})
	aadd(aCbPC,{"C7_FORNECE" ,'01505499'			,Nil})
	aadd(aCbPC,{"C7_LOJA"    ,'0001'				,Nil})
	aadd(aCbPC,{"C7_COND"    ,'002'					,Nil}) //SC1->C1_XCONPAG
	aadd(aCbPC,{"C7_CONTATO" ,'  '	,Nil})
//	aadd(aCbPC,{"C7_FILENT"  ,xFilial("SC7")		,Nil}) //SC1->C1_FILENT
	//aadd(aCbPC,{"C7_CONTATO" ,Iif(Empty(SA2->A2_CONTATO),".",SA2->A2_CONTATO)	,Nil})
	//aadd(aCbPC,{"C7_TPFRETE" ,aItensPDC[nXi,_PDCTFRE]	,Nil}) //SC1->C1_XCONPAG


	aadd(aItem,{"C7_ITEM"	,'0001'	,Nil})
	aadd(aItem,{"C7_PRODUTO"	,'00010013'	,Nil})
	aadd(aItem,{"C7_UM"		    ,'KG'	,Nil})
	aadd(aItem,{"C7_QUANT"		,1	,Nil})
	aadd(aItem,{"C7_PRECO"		,1	,Nil})
	aadd(aItem,{"C7_TOTAL"		,1	,Nil})
	aadd(aItem,{"C7_NUMSC"		,''	,Nil})
	aadd(aItem,{"C7_ITEMSC"		,''	,Nil})
	aadd(aItem,{"C7_DATPRF"		,dDataBase	,Nil})
	

	/*aadd(aItem,{"C7_XNUMPDC"		,''	,Nil})
	aadd(aItem,{"C7_XJUSTIF"		,''	,Nil})

	aadd(aItem,{"C7_CC"			,''		,Nil})
	aadd(aItem,{"C7_CONTA"		,''	,Nil})
	aadd(aItem,{"C7_ITEMCTA"	,''	,Nil})
	aadd(aItem,{"C7_CLVL"		,''		,Nil})*/









	aadd(aItem,{"C7_ITEM"	,'0002'	,Nil})
	
	aadd(aItem,{"C7_PRODUTO"	,'00040001'	,Nil})
	aadd(aItem,{"C7_UM"		,'UN'	,Nil})
	
	aadd(aItem,{"C7_QUANT"		,1	,Nil})
	aadd(aItem,{"C7_PRECO"		,1	,Nil})
	aadd(aItem,{"C7_TOTAL"		,1	,Nil})
	aadd(aItem,{"C7_NUMSC"		,''	,Nil})
	aadd(aItem,{"C7_ITEMSC"		,''	,Nil})
	aadd(aItem,{"C7_DATPRF"		,dDataBase	,Nil})
	/*aadd(aItem,{"C7_XNUMPDC"		,''	,Nil})
	aadd(aItem,{"C7_XJUSTIF"		,''	,Nil})

	aadd(aItem,{"C7_CC"			,''		,Nil})
	aadd(aItem,{"C7_CONTA"		,''	,Nil})
	aadd(aItem,{"C7_ITEMCTA"	,''	,Nil})
	aadd(aItem,{"C7_CLVL"		,''		,Nil})*/
			

	Aadd(aItPC, aItem)
	lMsErroAuto := .F.
	alert ('PAU qewewewewewedo execauto ' + cNumPed)
	MSExecAuto({|a, b, c, d| MATA120(a, b, c, d)},1,aCbPC, aItPC, 3)//Executa Msxecauto Opção padrão 3
	
 // MSExecAuto( {|a,b,c,d|"+cRotina+"(a,b,c,d)},1,aCabec,aItens,"+cValToChar(nOption)+")"
	
	If lMsErroAuto 
		cArqErrAuto := NomeAutoLog()
		cMsgErro    := Memoread(cArqErrAuto)
		alert (cMsgErro)
		Ferase(cArqErrAuto)
	else
		alert ('sucesso')
	EndIf
	
return







//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM9()
filtra solicitacoes que serao usadas para gerar uma cotacao no sistema

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User Function ALCOM9(cNumSc, cItemSc, cProd, lAtuSC7) 
Local lMantem := .T.
Local cPerg   := "ALCOM9"
Local aRet    := {}
SaveInter()

ValPerg(cPerg)

While lMantem
	If Pergunte(cPerg,.T.)
	
		If MV_PAR01 > MV_PAR02
			Alert ("Grupo De deve ser menor ou igual ao Grupo Até")
			Loop
		EndIf
		
		If Empty (MV_PAR02)
			Alert ("Grupo Até deve ser informado!")
			Loop
		EndIf
		
		Aadd(aRet, " .And. C1_XAPROV >= '" + MV_PAR01 + "' .And. C1_XAPROV <= '" + MV_PAR02 + "' " + /*concateno tratamento Claudo -> */" .AND. C1_XSTABIO <> '1' .AND. C1_XNUMPDC = ' ' ")
		Aadd(aRet, "  And  C1_XAPROV >= '" + MV_PAR01 + "'  And  C1_XAPROV <= '" + MV_PAR02 + "' " +/*concateno tratamento Claudo -> */ " AND C1_XSTABIO <> '1' AND C1_XNUMPDC = ' ' ")
			
			
			
					
		lMantem := .F.
	Else
		Alert ("Informe um intervalo válido de Grupos de Aprovação!")
	EndIf
End

RestInter()

return aRet


/*/{Protheus.doc} ValPerg

Perguntas/parametros para impressao

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/                
Static Function ValPerg(CPERG)
PRIVATE APERG := {}

DBSELECTAREA("SX1")
DBSETORDER(1)
                                        
PutSx1(cPerg, "01", "Grp Aprov De", "Grp Aprov De", "Grp Aprov De", "mv_ch1", "C", 06, 0, 0, "G", "", "SAL", "", "", "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
PutSx1(cPerg, "02", "Grp Aprov Ate","Grp Aprov Ate","Grp Aprov Ate","mv_ch2", "C", 06, 0, 0, "G", "", "SAL", "", "", "MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )

return

//-------------------------------------------------------------------
/*/{Protheus.doc} ALCOM9
trata grupo de aprovacao no ato da geracao da cotacao MATA131

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

User function ALCO10 (aLstSc1,oObjCNB)
Local aArea     := GetARea()
Local cC1ALias  := GetNextAlias()

Local nIndx     := 1
Local lPrimeiro := .T.
Local cGrpAProvPrimeiro := ''
Local lRet      := .T.


If oObjCNB != Nil .And. aLstSc1 != Nil
	aLstSc1 := {}
		
		
	VrfGridSC(aLstSc1,oObjCNB)
 

	For nIndx := 1 to Len(aLstSc1)
		
		
		BeginSql Alias cC1ALias
						
			SELECT SC1.*  
			       FROM %table:SC1% SC1
			       WHERE              
				             SC1.C1_FILIAL     = %xFilial:SC1%
				             AND SC1.%NotDel%
				             AND SC1.C1_NUM     = %EXP:( aLstSc1[nIndx][1]    )%
						     AND SC1.C1_ITEM    = %EXP:( aLstSc1[nIndx][2]    )%    
						             
		EndSql
						
		If (cC1ALias)->(!Eof()) .And. 	AllTrim( (cC1Alias)->(C1_NUM)     ) == AllTrim(aLstSc1[nIndx][1])      .And. 	AllTrim( (cC1Alias)->(C1_ITEM)    ) == AllTrim(aLstSc1[nIndx][2])
		    If lPrimeiro
		    	cGrpAProvPrimeiro := (cC1ALias)->(C1_XAPROV)
		    	
		    	lPrimeiro         := .F.
		    Else
		        If AllTrim(cGrpAProvPrimeiro) != AllTrim((cC1ALias)->(C1_XAPROV))
		    	
		    		Help( ,'','HELP4', "Erro Grupo Aprovacao","Não é permitido gerar cotação à partir de Solicitações de compras que pertençam a diferentes Grupos de Aprovação!",1,0)//dentro da tela de ediçao temsempre que ser help ....
		    		
		    		lRet := .F.
		    		exit
		    	EndIf
		    EndIf
		EndIf
					
		(cC1ALias)->(DbCLoseArea())
	Next

EndIf

restArea(aARea)

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VrfGridSC

trata grupo de aprovacao no ato da geracao da cotacao MATA131

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
/*
Static Function VrfGridSC(aLstSc1,oObjCNB)
	Local nIndex			:= 0
	Local cReq := ''
	Local cItemReq := ''
	Local nI := 0
	Local cVar := oObjCNB:GetValue("ITEMSC")//...EM ITEMSC TB HA UMA SERE DE NUMEROS DE SOLICITACAO CONCATENADOS ...CASO VARIAS SOLICITACOES SEJAM DO MESMO PRODUTO DE ESTOQUE
	Local aLista :=  StrTokArr(oObjCNB:GetValue("ITEMSC"), ";")
	
	U_LogDebug (  STR(oObjCNB:Length())  + " --> oObjCNB:GetValue(ITEMSC): " + oObjCNB:GetValue("ITEMSC"))
		
			
	For nI := 1 to Len(aLista)
			alert ('Loop')
		cReq     := substr ( aLista[nI],                       1, TamSx3('C1_NUM')[1] )
		cItemReq := substr ( aLista[nI], TamSx3('C1_NUM')[1] + 1, TamSx3('C1_ITEM')[1]           )
		
		nIndex := ascan(aLstSC1,  {|x| AllTrim(x[1]) = AllTrim(cReq) .ANd. AllTrim(x[2]) = AllTrim(cItemReq)   }    ) 	
			
		If nIndex == 0
			aadd (aLstSC1, {cReq, cItemReq})
			U_LogDebug ("Loop: " + cReq)
		
		EndIf
	Next
		
	
Return 
*/
Static Function VrfGridSC(aLstSc1,oObjMaster)
	Local nIndex			:= 0
	Local cReq := ''
	Local cItemReq := ''
	Local nI := 0
	Local nIndSbm
	Local nI2 := 0
	
	Local aLista        :=  {}
	lOCAL oOBjSBM := oObjMaster:GetModel("SBMDETAIL")
	lOCAL oOBjCNB := oObjMaster:GetModel("SC1DETAIL")//para cada regostro do SBM existem N registro do SC1 
	Local nLinSBM		:= oObjSBM:GetLine()
	Local nLinCNB		:= oObjCNB:GetLine()
	Local nTamSBM       := oObjSBM:Length()
	Local nTamCNB       := oObjCNB:Length()
			
	
	For nIndSbm := 1 to nTamSBM

		oObjSBM:GoLine(nIndSBM)

		For nI := 1 to nTamCNB
			
			oObjCNB:GoLine(nI)
			
			aLista := Nil
			aLista := {}
			aLista :=  StrTokArr(oObjCNB:GetValue("ITEMSC"), ";")
			
			For nI2 := 1 to Len(aLista)
				cReq     := substr ( aLista[nI2],                       1, TamSx3('C1_NUM')[1] )
				cItemReq := substr ( aLista[nI2], TamSx3('C1_NUM')[1] + 1, TamSx3('C1_ITEM')[1]           )
		
				nIndex := ascan(aLstSC1,  {|x| AllTrim(x[1]) = AllTrim(cReq) .ANd. AllTrim(x[2]) = AllTrim(cItemReq)   }    ) 	
					
				If nIndex == 0
					aadd (aLstSC1, {cReq, cItemReq})
				EndIf
			Next
		Next
	Next
	
	oObjSBM:GoLine(nLinSBM)
	oObjCNB:GoLine(nLinCNB)
	
	
Return //n2

//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO11

pega grupo de aprovacao do cabecalho do contrato e grava no pedido gerado pela medicao (em todos os itens sempre)

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

User  Function ALCO11(aMeusItens)
	Local nI			 := 0
	
	For nI := 1 to Len(aMeusItens)
		aAdd(aMeusItens[nI]	,{"C7_APROV"		,			CN9->CN9_XAPALI							,NIL})	//ignora o grupo vinculado ao solicitante e grava o da CN9
	Next
	
Return aMeusItens


//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO11

pega grupo de aprovacao do cabecalho do contrato e grava no pedido gerado pela medicao (em todos os itens sempre)

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

User  Function ALCO21(aMeusItens)
	Local nI			 := 0
	
	For nI := 1 to Len(aMeusItens)
		aAdd(aMeusItens[nI]	,{"C7_APROV"		,			''							,NIL})	//ignora o grupo vinculado ao solicitante e grava o da CN9
	Next
	
Return aMeusItens
//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO12

puxa grupo de aprovacao da SC1 para a SC7 ao fazer a analise de cotacao

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

User  Function ALCO12()
Local aSC1Area := GetARea('SC1')
DbSelectarea('SC7')
SC1->(dbSetOrder(1))
SC1->(dbSeek(xFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC)))
       		
If SC1->(!Eof()) .And. AllTrim(SC7->C7_ITEMSC)  == AllTrim(SC1->C1_ITEM)  .And.  AllTrim(SC7->C7_NUMSC) == AllTrim(SC1->C1_NUM) 
	
	SC7->C7_APROV := SC1->C1_XAPROV

	//hfp abax cotacao   passa todos itens um a um 
	SC7->C7_XBUDGET	:= SC1->C1_XBUDGET  //abax
	SC7->C7_XMOTBUD	:= SC1->C1_XMOTBUD  //abax

ENdIf	
       		
RestArea(aSC1Area)       		
return





/*/{Protheus.doc} ALCOM07()
tudo ok do pedido de compra

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
//premissa
//o sistema procura o grupo de aprovacao só no grupo de usuarios ou só no vinculo com o próprio usuario
//jamais procura simultaneamente nos dois tipos de vinculo. 

Static Function VincNoUsuario (cUsuPesq, cGrpPrincDeUsuarios)
Local cAliasPesq := GetNextAlias()
Local lRet       := .T.

If !Empty(cGrpPrincDeUsuarios)
	BeginSql Alias cAliasPesq
		SELECT SAI.*  FROM %table:SAI% SAI
		       WHERE             SAI.AI_FILIAL     = %xFilial:SAI%
					             AND SAI.%NotDel%
					             AND SAI.AI_GRUSER     = %EXP:( cGrpPrincDeUsuarios )%    
	EndSql
	
	If  (cAliasPesq)->(!Eof())  .And. AllTrim(cGrpPrincDeUsuarios) == AllTrim( (cAliasPesq)->(AI_GRUSER)  )
		lRet := .F. //entao deixo procurar o grupo de aprovacao somente no vinculo com o grupo e nem vejo mais o vinculo com usuario
	EndIf
	//caso nao tenha nada na SAI para este grupo, retorno T e deixo ele buscar no vinculo com o usuario mesmo
	(cAliasPesq)->(DbCloseArea())
else
	//se nao tem grupo deixa procurar só no usuario
	lRet       := .T.
EndIf

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO33

adiciona campo grupo de estoque na tela do SC1

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

User  Function ALCO33(aParamPE)

Local oNewDialog	:= aParamPE[1]
Local aPosGet       := aParamPE[2]
Local nOpcx	        := aParamPE[3]
Local nReg	        := aParamPE[4]
Local oGet1
Local oGet2
Local nPos          := 63
Local nPos2
Local lHabilita := .F.
Public cAliGrpId	:= Space(4)

If IsInCallStack("U_FSCOMP01")  //tela customizada pela equipe BIONEXO 
	
	cAliGrpId := SC1->C1_XGRUP
Else

	
	If !INCLUI
		cAliGrpId := SC1->C1_XGRUP
	EndIf
EndIf

If nOpcx == 3 .or. nOpcx == 4 //4:contempla alteracao e copia
	lHabilita := .T.
EndIf

aadd(aPosGet[2],0)
/*nPos1 := 63
nPos2 := 63*/
@ nPos,aPosGet[2,8]-100 Say 'Grupo Estoque' Pixel Size 40,9 Of  oNewDialog
@ nPos,aPosGet[2,8]/*aPosGet[2,8]+ 60*/ MSGET oGet1 Var cAliGrpId Size 032, 011 Picture '@!' Valid Iif(EMpty(cAliGrpId) ,  (ALert("Informe Grupo de Estoque"),.F.  )  , .T.   )  F3 "SBM" when lHabilita Of oNewDialog Colors 0, 16777215 Pixel

return

//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO16

aumenta cabecalho do SC1

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

User  Function ALCO16(aRet)

	aRet[2,1] := 85 //Abaixando o começo da linha da getdados
	aRet[1,3] := 85 // Abaixando a linha de contorno dos campos do cabeçalho

return


//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO17

tudo ok do SC1

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User  Function ALCO17()
Local lRet    := .T.
Local nIndx   := 1
Local nIndiceGrp := 0
Local cMsg := ''
Local cGrpItem := ''

nIndiceGrp := aScan(aHeader, {|z| Alltrim(z[2]) == "C1_XGRUP"})

If Empty (cAliGrpId)
	lRet := .F.
	Alert ("Informe o Grupo de Estoque no cabeçalho da Solicitação de Compra")
EndIf

If lRet .ANd. nIndiceGrp > 0

	
	For nIndx := 1 to Len(aCols)
	
		If aCols[nIndx, Len(aCols[nIndx]) ] != .T. //registro nao deletado
			cGrpItem := AllTrim(aCols[nIndx, nIndiceGrp ])
			
			If  cGrpItem != Alltrim(cAliGrpId) 
				//nIndice := aScan(aCols, {|aX| aX[nIndx]==(cAliasSC1)->C1_ITEM})>0
				lRet := .F.
				cMsg := "Linha: " + AllTrim(STR(nIndx)) + " possui grupo de estoque diferente do informado no Cabeçalho desta Solicitação de compras! Todos os itens devem conter o mesmo grupo de estoque!"
				Alert(cMsg)
				exit
			EndIf
			
		EndIf
		
	Next
EndIf

return 	lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO18

valida a linha inserida no SC1 - LinhaOk

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User  Function ALCO18()
Local lRet    := .T.
Local nIndx   := 1
Local nIndiceGrp := 0
Local cMsg := ''
Local cGrpItem := ''


	nIndiceGrp := aScan(aHeader, {|z| Alltrim(z[2]) == "C1_XGRUP"})
	
	If Empty (cAliGrpId)
		lRet := .F.
		Alert ("Informe o Grupo de Estoque no cabeçalho da Solicitação de Compra!")
	EndIf
	
	If lRet .ANd. nIndiceGrp > 0
	
		If aCols[n, Len(aCols[n]) ] != .T. //registro nao deletado
			
			cGrpItem := AllTrim(aCols[n, nIndiceGrp ])
					
			If  cGrpItem != Alltrim(cAliGrpId) 
					
				//nIndice := aScan(aCols, {|aX| aX[nIndx]==(cAliasSC1)->C1_ITEM})>0
				lRet := .F.
				cMsg := "Linha: " + AllTrim(STR(n)) + " possui grupo de estoque diferente do informado no Cabeçalho desta Solicitação de compras! Todos os itens devem conter o mesmo grupo de estoque!"
				Alert(cMsg)
			EndIf
		EndIf
		
	EndIf


return 	lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO19

grava no campo na tabela SC1

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
User  Function ALCO19()
If !l110Auto
	reclock('SC1',.F.)
	SC1->C1_XGRUP := cAliGrpId
	MsUNlock()
EndIf
return 	

//-------------------------------------------------------------------
user function pegax()
Local aCab := {}
Local aLinha := {}
Local aItem := {}
Local cArqErrAuto
Local cErrAuto
Local cNumSc := ''
Local cIt := '0001'
Private lMsErroAuto := .F.

Aadd( aCab , { "C1_NUM"  	, cNumSC := GetNumSC1() , Nil })
Aadd( aCab , { "C1_FILENT"  , xFilial("SC1") 		, Nil })
Aadd( aCab , { "C1_EMISSAO"	, dDataBase 			, Nil })
Aadd( aCab , { "C1_SOLICIT" , CriaVar("C1_SOLICIT") , Nil})
alert (cNumSC)

//aCab:={{"C1_EMISSAO" ,dDataBase ,Nil},; // Data de Emissao
	//		{"C1_SOLICIT" ,'oswaldo.leite' ,Nil}}	



		 	aadd(aLinha,{"C1_ITEM"   , cIt, Nil})
		 	aadd(aLinha,{"C1_PRODUTO"   , '00010013', Nil})
		 	aadd(aLinha,{"C1_QUANT"   , 1, Nil})
		 	aadd(aLinha,{"C1_LOCAL"   , '01', Nil})
		 	aadd(aLinha,{"C1_DATPRF"   , dDataBase, Nil})
		 	//aadd(aLinha,{"C1_CC"   , aSolicitacaoCompra:ITEM[nCount]:C1_CC, Nil})
		 	aadd(aLinha,{"C1_OBS"   , '1', Nil})
		 	aadd(aLinha,{"C1_ORIGEM"   , "FsIntCad", Nil}) 
     		aadd(aItem,aLinha)
		
		cIt := SOma1(cIt)
		alert (cIt)
		
		aadd(aLinha,{"C1_ITEM"   , cIt, Nil})
		 	aadd(aLinha,{"C1_PRODUTO"   , '00040001', Nil})
		 	aadd(aLinha,{"C1_QUANT"   , 1, Nil})
		 	aadd(aLinha,{"C1_LOCAL"   , '01', Nil})
		 	aadd(aLinha,{"C1_DATPRF"   , dDataBase, Nil})
		 	//aadd(aLinha,{"C1_CC"   , aSolicitacaoCompra:ITEM[nCount]:C1_CC, Nil})
		 	aadd(aLinha,{"C1_OBS"   , '1', Nil})
		 	aadd(aLinha,{"C1_ORIGEM"   , "FsIntCad", Nil}) 
     		aadd(aItem,aLinha)
		
		
	  MSExecAuto({|v,x,y| MATA110(v,x,y)},aCab,aItem,3)

	  
	  If lMsErroAuto
			cArqErrAuto := NomeAutoLog()
			cErrAuto    := Memoread(cArqErrAuto)
			alert (cErrAuto)
	else 
			alert ('sucesso')
	  endif

return		


static Function Log99(cTxt)
Local cFileOper
Local nHandleCr

cFIleOpen :=  "C:\teste\log.txt"//cLogCompleto + "\log_bol_po.txt"
nHandleCr := fopen( cFileOpen  , FO_READWRITE + FO_SHARED )
         
if nHandleCr  == -1
	nHandleCr := FCreate(cFileOpen)//esta função cria o arquivo automaticamente sempre no protheus_data\system
else                 
	fseek(nHandleCr, 0, FS_END)
EndIf		

		   
FWrite(nHandleCr, cTxt + Chr(13) + CHr(10))
		
FClose(nHandleCr) 
return      




user function petst ()

Local aCab   := {}
Local aItens := {}
Local cItem			:= Replicate("0" , TamSX3("C1_ITEM")[1])
Local cNumSC		:= ""

Private lMsErroAuto    := .F.


Aadd( aCab , { "C1_NUM"  	, cNumSC := GetNumSC1() , Nil })
Aadd( aCab , { "C1_FILENT"  , xFilial("SC1") 		, Nil })
Aadd( aCab , { "C1_EMISSAO"	, dDataBase 			, Nil })
Aadd( aCab , { "C1_SOLICIT" , CriaVar("C1_SOLICIT") , Nil})

Aadd(aItens,{})
cItem	:= Soma1(cItem)

Aadd(aItens[Len(aItens)] ,  {  "C1_NUM" 	,  cNumSC    				, Nil  })
Aadd(aItens[Len(aItens)] ,  {  "C1_ITEM" 	,  cItem    				, Nil  })
Aadd(aItens[Len(aItens)] ,  {  "C1_PRODUTO" ,  "MOD90101"  , Nil  })
Aadd(aItens[Len(aItens)] ,  {  "C1_QUANT" 	,  1   , Nil  })
Aadd(aItens[Len(aItens)] ,  {  "C1_ORIGEM" 	, "PFCOMA04"    			, Nil  })
alert (" ======== inicio ======== ")
MSExecAuto({|x,y,z|MATA110(x,y,z)},aCab, aItens ,3)
		
If lMsErroAuto
alert('deu erro '  + cNumSC)		
		MostraErro()
alert('deu ' + cNumSC)		
EndIf

return



//-------------------------------------------------------------------
/*/{Protheus.doc} ALCO20()
tudo ok da solicitacao chamado no fluig

@since 28/01/2013
@version 1.0
@return NIL
/*/
User function ALCO20(cVigSolic)
Local lRet    := .T.
Local nIndx   := 1
Local nIndiceNum  := 0
Local nProdIndice := 0
Local nApvIndice  := 0
Local aArea     := GetARea()
Local aSC1Area  := GetARea("SC1")

Local cMsg := ''
Local cGrpItem := ''






nProdIndice := aScan(aHeader, {|z| Alltrim(z[2]) == "C1_PRODUTO"})
nApvIndice := aScan(aHeader, {|z| Alltrim(z[2]) == "C1_XAPROV"})

If nProdIndice > 0 .ANd.  nApvIndice > 0
	
	For nIndx := 1 to Len(aCols)
	
		If aCols[nIndx, Len(aCols[nIndx]) ] != .T. //registro nao deletado
			//alert ('antes: ' + aCols[nIndx][nApvIndice])
			aCols[nIndx][nApvIndice] := BscAprov(aCols[nIndx][nProdIndice],cVigSolic)//no execauto chamado pelo fluig, apenas neste ponto temos o M->C1_SOLICIT com algum conteudo! Portanto, aqui refazemos tudo de novo!
			//alert ('depos: ' + aCols[nIndx][nApvIndice])
		EndIf
	Next
EndIf

/*
Local aArea     := GetARea()
Local aSC1Area  := GetARea("SC1")
Local cAliasSc1 := GetNextAlias()
Local cNUmSc    := SC1->C1_NUM
Local lRet      := .T.
		
BeginSql Alias cAliasSc1
	
	SELECT SC1.*  //C1_SOLICIT  
	       
	       FROM %table:SC1% SC1
	              
	       WHERE              
	             SC1.C1_FILIAL     = %xFilial:SC1%
	             AND SC1.%NotDel%
	             AND SC1.C1_NUM     = %EXP:( SC1->C1_NUM    )%    
	                
EndSql
	
While (cAliasSc1)->(!Eof()) .And. AllTrim( (cAliasSc1)->(C1_NUM) ) == AllTrim(cNumSc)  

	SC1->( DbGoTo( (cAliasSc1)->(R_E_C_N_O_) ) )
	
	reclock('SC1',.F.)
	SC1->C1_XAPROV := BscAprov()//no execauto chamado pelo fluig, apenas neste ponto temos o M->C1_SOLICIT com algum conteudo! Portanto, aqui refazemos tudo de novo! 
	MsUnLOck()
	
	(cAliasSc1)->(DbSkip())
End

(cAliasSc1)->(DbCloseArea())

RestArea(aArea)
RestArea(aSC1Area)
*/
RestArea(aArea)
RestArea(aSC1Area)

return lRet
//-------------------------------------------------------------------


//-------------------------------------------------------------------
/*/{Protheus.doc} BscAprov()
tudo ok do execauto de solicitacao de compra somnete qdo chamado pelo fluig

@since 28/01/2013
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static function BscAprov(c1Prod,cVigSolic)

Local aArea      := GetArea()
Local cProd      := ''
Local cAliasApv
Local cPrdALias
Local cB1Grupo   := ''
Local cRet       := ''
Local lProsseguir := .T.
Local lPorGrpGenerico := .F.
Local aAllUsuarios //:= AllUsers()
Local cGrpPrincDeUsuarios := ''
Local lOlhaApenasGrupoUsuarios := .F.
Local aRet := {}
Local nIndx := 0
Private cC1Solic := ''

//BscAprov(SC1->C1_PRODUTO, SC1->C1_SOLICIT)

//produto
cAliasApv := GetNextAlias()
//aAllUsuarios := AllUsers()


If !Empty(cVigSolic)
	
	PswOrder(2)
	If PswSeek(cUserName ,.T.)//avaliar somente primeiro grupo ao qual este se encontra amarrado
		aRet := PswRet()
		
		//If Len( aRet[1][10] ) > 0//caso o usuario esteja amarrado a algum grupo
			//cGrpPrincDeUsuarios := aRet[1][10][1]
			nIndx := 1
		//EndIf
	EndIf
	
	//nIndx := aScan(aAllUsuarios,{|x| AllTrim(x[1][2]) == AllTrim(cVigSolic) })
EndIf

//avaliar somente primeiro grupo ao qual este se encontra amarrado
If nIndx > 0
	cC1Solic := aRet[1][1]   //aAllUsuarios[nIndx][1][1]
	
	//If len(aAllUsuarios[nIndx][1][10]) > 0//caso o usuario esteja amarrado a algum grupo
	If Len( aRet[1][10] ) > 0
		cGrpPrincDeUsuarios := aRet[1][10][1] //aAllUsuarios[nIndx][1][10][1]
	EndIf
Else
	cRet := SuperGetMV("ES_GRPAP",, '')//utiliza um grupo de aprovador padrao
	restArea(aArea)
	return cRet
EndIf

cProd      := c1Prod
cRet       := ''
lProsseguir := .T.


If !VincNoUsuario (cC1Solic, cGrpPrincDeUsuarios)//por definicao: o sistema ou olha somente no vinculo com o usuario ou somente no vinculo com grupo de usuarios...mas jamais nos dois!
	lOlhaApenasGrupoUsuarios := .T.
EndIf


If Empty(cRet) .And. !Empty(cProd)  .And. lProsseguir 

	If Empty(cRet)
	
		//======================================================
		//Passo 3 - verifica se tem produto vinculado 
		If lOlhaApenasGrupoUsuarios
			BeginSql Alias cAliasApv
						
				SELECT SAI.*  
						       
			       FROM %table:SAI% SAI
							              
					       WHERE              
				             SAI.AI_FILIAL     = %xFilial:SAI%
				             AND SAI.%NotDel%
				             AND SAI.AI_GRUSER     = %EXP:( cGrpPrincDeUsuarios    )%    AND
				             SAI.AI_PRODUTO = %EXP:( cProd    )%    
			EndSql
			
		Else
			BeginSql Alias cAliasApv
						
				SELECT SAI.*  
							       
			       FROM %table:SAI% SAI
							              
					       WHERE              
					             SAI.AI_FILIAL     = %xFilial:SAI%
					             AND SAI.%NotDel%
					             AND SAI.AI_USER     = %EXP:( cC1Solic    )%    AND
					             SAI.AI_PRODUTO = %EXP:( cProd    )%    
			EndSql
	
		EndIf
				
		If (cAliasApv)->(!Eof())   .And. AllTrim( (cAliasApv)->(AI_PRODUTO) ) == AllTrim(cProd)      
			cRet := (cAliasApv)->(AI_APROV)
			
		EndIf
				
		(cAliasApv)->(DbCLoseArea())
				
		//======================================================
	EndIf

	If Empty(cRet)
	
		cB1Grupo  :=  ''
			
		cPrdALias := GetNextAlias()
			
		BeginSql Alias cPrdALias
						
				SELECT SB1.B1_GRUPO, SB1.B1_COD  
						       
			       FROM %table:SB1% SB1
						              
				       WHERE              
				             SB1.B1_FILIAL     = %xFilial:SB1%
				             AND SB1.%NotDel%
				             AND SB1.B1_COD     = %EXP:( cProd    )%    
						             
		EndSql
					
		If (cPrdALias)->(!Eof()) .ANd. 	AllTrim( (cPrdAlias)->(B1_COD) ) == AllTrim(cProd) 
			cB1Grupo := (cPrdALias)->(B1_GRUPO)
		EndIf
				
		(cPrdALias)->(DbCLoseArea())
		
		lPorGrpGenerico := .F.
	
		//======================================================
		//Passo 1 - verifica se tem grupo de estoque vinculado 
	
		If !Empty(cB1Grupo)
		
			If lOlhaApenasGrupoUsuarios
			
				BeginSql Alias cAliasApv
					
						SELECT SAI.*  
						       
						       FROM %table:SAI% SAI
						              
						       WHERE              
						             SAI.AI_FILIAL     = %xFilial:SAI%
						             AND SAI.%NotDel%
						             AND SAI.AI_GRUSER     = %EXP:( cGrpPrincDeUsuarios    )%    AND
						             SAI.AI_GRUPO   = %EXP:( cB1Grupo )%      
				EndSql
				
			Else
				
				BeginSql Alias cAliasApv
					
						SELECT SAI.*  
						       
						       FROM %table:SAI% SAI
						              
						       WHERE              
						             SAI.AI_FILIAL     = %xFilial:SAI%
						             AND SAI.%NotDel%
						             AND SAI.AI_USER     = %EXP:( cC1Solic    )%    AND
						             SAI.AI_GRUPO   = %EXP:( cB1Grupo )%      
				EndSql
				
			EndIf	
			
			If (cAliasApv)->(!Eof())   .And.  AllTrim( (cAliasApv)->(AI_GRUPO) ) == AllTrim(cB1Grupo)
				cRet := (cAliasApv)->(AI_APROV)
			EndIf
			
			If Empty(cRet)
		
				(cAliasApv)->(DbCLoseArea())
		
				//========================================================================
				//Passo 2 - Verifica se tem grupo: * 
				//========================================================================
				If lOlhaApenasGrupoUsuarios
						BeginSql Alias cAliasApv
							
								SELECT SAI.*  
								       
								       FROM %table:SAI% SAI
								              
								       WHERE              
								             SAI.AI_FILIAL     = %xFilial:SAI%
								             AND SAI.%NotDel%
								             AND SAI.AI_GRUSER     = %EXP:( cGrpPrincDeUsuarios  )%    AND
								             SAI.AI_GRUPO   = '*'   AND SAI.AI_PRODUTO = '*'  
						EndSql
				Else
						BeginSql Alias cAliasApv
							
								SELECT SAI.*  
								       
								       FROM %table:SAI% SAI
								              
								       WHERE              
								             SAI.AI_FILIAL     = %xFilial:SAI%
								             AND SAI.%NotDel%
								             AND SAI.AI_USER     = %EXP:( cC1Solic    )%    AND
								             SAI.AI_GRUPO   = '*'  AND SAI.AI_PRODUTO = '*'
						EndSql
				ENdIf
			
				If (cAliasApv)->(!Eof())   .And.  AllTrim( (cAliasApv)->(AI_GRUPO) ) == AllTrim("*")      
					lPorGrpGenerico := .T.
					cRet := (cAliasApv)->(AI_APROV)
				ENdIf
				
			EndIf
		
			(cAliasApv)->(DbCLoseArea())
			
		EndIf
	
	EndIf
	

	
	
	If Empty(cRet)
		cRet := SuperGetMV("ES_GRPAP",, '')//utiliza um grupo de aprovador padrao
	EndIf
					
EndIf

restArea(aArea)

return cRet
