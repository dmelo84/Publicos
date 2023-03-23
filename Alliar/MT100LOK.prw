#include "Protheus.ch"
//-----------------------------------
/*/
@Autor   : Francisco Lopes Junior
@Empresa : Compila
@Data    : 27/02/2017
@Objetivo: Classificacao TES para nao atualizar estoque conforme FS_GRPPRD
*/*

User function MT100LOK()                                     					 //verifica Tes permitidas

Local _lret 		:= .t.
Local _cEstoque  := " " 
Local _cGrpPrd   := " "
Local _aArea 	:= GetArea()

Local _nPosCod := 0 
Local _nPosTES := 0 

_nPosCod := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
_nPosTES := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})

if l103Class .and. _nPosCod > 0 .and. _nPosTes > 0										// verifica se for rotina de classificacao

	SF4->(MsSeek(xFilial("SF4")+aCols[n][_nPostes]))
	_cEstoque	:= SF4->F4_ESTOQUE
	
	SB1->(MsSeek(xFilial("SB1") + aCols[n][_nPosCod]))
	_cGrpPrd	:= SB1->B1_GRUPO
	
	_cGrpTES := SuperGetMv("FS_GRPPRD",.F.,"0001")
		/*
	if Empty(_cGrpTES)                                                     // verifica parametro com as TES que nao movimentam estoque
	 
		Help( "", 1, "_A103BLTES01")                                         // Preencher Grupos sem mov. de estoque em parametros 'FS_GRPPRD'"
		_lRet := .F.
		
	Elseif empty(_cGrpPrd)															  // verifica se produto tem seu grupo preenchido no cadastro

		Help( "", 1, "_A103BLTES02")													  // "Preencher Grupo de Produto em cadastro de produto para cod. " + aCols[n][_nPosCod] + " item " + strzero(n,4)
		_lRet := .F.

	Endif
*/
   If _cEstoque == "S" .and. Alltrim(_cGrpPrd) $ Alltrim(_cGrpTES)
   
   		//Help( "", 1, "_A103BLTES03")													  //Grupo de Produto não movimenta estoque
   		//Help(" ",1,"MT100LOK",,"O Grupo do produto selecionado nao permite tes que movimente estoque.",4,5)
   		FwHelpShow("MT100LOK","","O Grupo do produto selecionado não permite TES que movimente estoque.","Utilizar TES para nota serviço")
		_lRet := .F.
   		
     
	Endif

Endif

RestArea(_aArea)

Return(_lRet)

