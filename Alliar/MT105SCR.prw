#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA105SCR บAutor  ณToni Guedes/Insight บ Data ณ  08/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAcrescenta o campo "Centro de Custo" ao cabecalho da        บฑฑ
ฑฑบ          ณsolicitacao ao aramazem.                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EXECBLOCK Solicitacao ao Aramazem Estoque                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

/*----------------------------------------
	10/09/2018 - Jonatas Oliveira - Compila
	Customiza็ใo especifica do CDB Disponibilizada 
	para base CSC
------------------------------------------*/
User function MT105SCR()

	Local oNewDialog := PARAMIXB[1]      // Recebe como parโmetro o objeto oDialog para manipula็ใo do usuario
	Local nOpcx      := PARAMIXB[2]      // Recebe como parโmetro a nOpcao. 
	Local nPosVLbl   := 02.7
	Local nPosHLbl   := 10.0
	Local nPosVGet   := 02.6
	Local nPosHGet   := 12.5

	Public cA105CC	:= CRIAVAR("CP_CC")  

	IF GetMv("AL_CCSA",.F.,.F.)//Habilita Centro de Custo no cabe็alho?
		IF nOpcx==4 //Alteracao                        

			cA105CC	:= 	SCP->CP_CC

			@ nPosVLbl,nPosHLbl SAY 'C.Custo'  Of oNewDialog
			@ nPosVGet,nPosHGet MSGET cA105CC F3 "CTT" When VisualSX3("CP_CC") Valid ( /* Vazio() .Or. */ ExistCpo("CTT",cA105CC)) Of oNewDialog 


		ElseIf nOpcx==3 //Incluir

			@ nPosVLbl,nPosHLbl SAY 'C.Custo'  Of oNewDialog
			@ nPosVGet,nPosHGet MSGET cA105CC F3 "CTT" When VisualSX3("CP_CC") Valid ( /*Vazio() .Or. */ExistCpo("CTT",cA105CC)) Of oNewDialog 

		ElseIf nOpcx==5 //Excluir 

			cA105CC	:= 	SCP->CP_CC

			@ nPosVLbl,nPosHLbl SAY 'C.Custo'  Of oNewDialog
			@ nPosVGet,nPosHGet MSGET cA105CC F3 "CTT" When .f. Of oNewDialog   

		Else	

			cA105CC	:= 	SCP->CP_CC

			@ nPosVLbl,nPosHLbl SAY 'C.Custo'  Of oNewDialog
			@ nPosVGet,nPosHGet MSGET cA105CC F3 "CTT" When .f. Of oNewDialog   	

		EndIf
	ENDIF 

Return  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMTA105LIN บAutor  ณToni Guedes/Insight บ Data ณ  08/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณUsado para validar se foi digitado o centro de custo na     บฑฑ
ฑฑบ          ณsolicitacao ao aramazem, replicando a informacao digitada   บฑฑ
ฑฑบ          ณno cabecalho para as linhas aCols                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ EXECBLOCK Solicitacao ao Aramazem Estoque                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MTA105LIN()
	Local cAlias	:= GetArea()		//Guarda a Area atual
	Local _lOK		:= .T.				//Flag para controlar a validacao
	Local cCCusto	:= aCols[n][GDFieldPos("CP_CC")]        //Pega o conteudo do campos do centro de custo da SA
	Local _lContit		:= aCols[n][GDFieldPos("CP_ITEM")]	//Pega o conteudo do campos do Item da SA
	
	IF GetMv("AL_CCSA",.F.,.F.)
		If aCols[n][Len(aHeader)+1] == .F.		//Verifica se a linha foi deletada
		
			IF  empty(cCCusto)
				//If (Len(AllTrim(_lContcc)) = 0)  
				IF TYPE("cA105CC") == "C"
					If !EMPTY(cA105CC) 
						aCols[n][GDFieldPos("CP_CC")] :=cA105CC
					Else	 
						ApmsgInfo("Por favor informe o Centro de Custo...!!!!!, no item "+_lContit+" da SA","Aten็ใo")				//Mostra a mensagem para informar o centro de custo
						_lOK := .F.	 //altera o flag para nao deixar grava ou passar o campo caso o centro de custo esteja em branco
					EndIf
				ELSE
					ApmsgInfo("Por favor informe o Centro de Custo...!!!!!, no item "+_lContit+" da SA","Aten็ใo")				//Mostra a mensagem para informar o centro de custo
					_lOK := .F.	 //altera o flag para nao deixar grava ou passar o campo caso o centro de custo esteja em branco
				ENDIF
			ENDIF
			//Endif   
		Endif    
	ENDIF    

	RestArea(cAlias)			//Restaura a area
Return(_lOK)