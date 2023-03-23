#INCLUDE "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA105SCR �Autor  �Toni Guedes/Insight � Data �  08/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Acrescenta o campo "Centro de Custo" ao cabecalho da        ���
���          �solicitacao ao aramazem.                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � EXECBLOCK Solicitacao ao Aramazem Estoque                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*----------------------------------------
	10/09/2018 - Jonatas Oliveira - Compila
	Customiza��o especifica do CDB Disponibilizada 
	para base CSC
------------------------------------------*/
User function MT105SCR()

	Local oNewDialog := PARAMIXB[1]      // Recebe como par�metro o objeto oDialog para manipula��o do usuario
	Local nOpcx      := PARAMIXB[2]      // Recebe como par�metro a nOpcao. 
	Local nPosVLbl   := 02.7
	Local nPosHLbl   := 10.0
	Local nPosVGet   := 02.6
	Local nPosHGet   := 12.5

	Public cA105CC	:= CRIAVAR("CP_CC")  

	IF GetMv("AL_CCSA",.F.,.F.)//Habilita Centro de Custo no cabe�alho?
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MTA105LIN �Autor  �Toni Guedes/Insight � Data �  08/12/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Usado para validar se foi digitado o centro de custo na     ���
���          �solicitacao ao aramazem, replicando a informacao digitada   ���
���          �no cabecalho para as linhas aCols                           ���
�������������������������������������������������������������������������͹��
���Uso       � EXECBLOCK Solicitacao ao Aramazem Estoque                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
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
						ApmsgInfo("Por favor informe o Centro de Custo...!!!!!, no item "+_lContit+" da SA","Aten��o")				//Mostra a mensagem para informar o centro de custo
						_lOK := .F.	 //altera o flag para nao deixar grava ou passar o campo caso o centro de custo esteja em branco
					EndIf
				ELSE
					ApmsgInfo("Por favor informe o Centro de Custo...!!!!!, no item "+_lContit+" da SA","Aten��o")				//Mostra a mensagem para informar o centro de custo
					_lOK := .F.	 //altera o flag para nao deixar grava ou passar o campo caso o centro de custo esteja em branco
				ENDIF
			ENDIF
			//Endif   
		Endif    
	ENDIF    

	RestArea(cAlias)			//Restaura a area
Return(_lOK)