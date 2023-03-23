#INCLUDE "rwmake.ch"
//-------------------------------------------------------------------
/*{Protheus.doc} ALTMKA10
Interação Imediata

@author Itamar Gama .:
@since  28/03/2017
@version P12
*/
//-------------------------------------------------------------------
User Function ALTMKA10()
Local aColsaux  :={}
Local nPosOri   := n
Local nPosSUBI	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_SUBITEM"})
Local nPosITEM	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_ITEM"})
Local nPosSOLU	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_SOLUCAO"})
Local cChavePes	:=''
If Altera .And. ! (aCols[n][Len(aCols[n])]) .And. !IsInCallStack("U_ALTMKA01")

	cChavePes 	:=M->UC_CODIGO+LEFT(aCols[nPosOri][nPosSUBI],2)
	
	aColsaux	:=aClone(aCols[n])
	oGetTmk:AddLine()  		      				//Adiciona uma linha nova
	ACopy(aCols[nPosOri],aCols[n],,nPosSOLU-1,)
	aCols[n][nPosITEM] :=StrZero(n,2)
	aCols[n][nPosSUBI] :=GetSubIt10(cChavePes)  //Left(aColsaux[3],2)+StrZero(Val(Right(aColsaux[3],2))+1,2)
	oGetTmk:oBrowse:nColPos := 4  				//Muda a coluna para a 4
	oGetTmk:Refresh() 							//Atualiza a Getdados
	oGetTmk:oBrowse:Refresh() 					//Atualiza a Getdados do browse em tela. 
Else
	If !Altera
		Aviso("ALTMKA10", "Rotina apenas para opção Alterar", {"Fechar"})
	Else
		Aviso("ALTMKA10", "Linha posicionada se encontra marcada como excluida", {"Fechar"})		
	Endif	
Endif	
Return Nil

Static Function GetSubIt10(cCHAVE)
Local cQuery	 	:= ''
Local cSubItem		:= ''
Local nPosSUBIa		:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_SUBITEM"})
//Query 
cQuery 	:= " SELECT MAX(SUD.UD_SUBITEM)SUBITEM"
cQuery 	+= " FROM "+RetSQLName("SUD") +" SUD" 
cQuery 	+= " WHERE SUD.UD_FILIAL = '"+xFilial("SUD")+"' AND SUD.UD_CODIGO+LEFT(SUD.UD_SUBITEM,2)= '"+cCHAVE+"' AND SUD.D_E_L_E_T_ = ''"

cAlias1:= CriaTrab(Nil,.F.)
DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAlias1, .F., .T.)
     
If !(cAlias1)->(Eof())
	nPosAcol := 99
	nContSIT := 1
	
	Do While nPosAcol <> 0
		cSubItem := StrZero(Val(SUBITEM)+nContSIT,4)
		nPosAcol := aScan(aCols,{|x| AllTrim(x[nPosSUBIa]) == cSubItem})
		nContSIT++
	Enddo	
Else
	If Len(cCHAVE) == 10
		cSubItem := StrZero(Val(Right(cCHAVE,4))+1,4)
	Else
		cSubItem := Right(cCHAVE,2)+"00"
	Endif
Endif
(cAlias1)->(DBCloseArea())

Return(cSubItem)