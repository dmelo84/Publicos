#Include "Protheus.Ch"
#Include "rwmake.ch"

#DEFINE EOL			chr(13)+chr(10)
#DEFINE aAliasM2	"Z08"							
#DEFINE cChave		"Z08->(Z08_FILIAL+Z08_CODIGO)"		//| Chave do Cabecalho
#DEFINE nIndChv		1

//| Indice e chave Unica  - Utilizado na Alteracao e Exclusao
#DEFINE nIndUniq	1

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AFAT151  �Autor  �Augusto Ribeiro     � Data � 11/02/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Configurador reembolso de despesa                 ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �      	                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function CP07002()
Private cCenario, _cRevCen,	cNomCena, _cMSBLQL,	_dDtIni, _dDtFim
Private INCLUI,	ALTERA
Private cLinhaOk	:= ".T."
Private cTudoOk		:= ".T." 
Private cIniCpos := "+Z08_ITEM" // String com o nome dos campos que devem inicializados ao pressionar a seta para baixo.

Private aAC,cTITULO , cCADASTRO , lEND, cDELFUNC, aROTINA

Private aCabec	:= {}                              
Private aChvUnq	:= {}


	//���������������������������������Ŀ
	//� Cria HELPs utilizados na rotina �
	//�����������������������������������
//	AjustaHlp()		

	//������������������������������������������������������������Ŀ
	//� CABECALHO - Defini�coes do cabelho                         �
	//� aCabec[<cCAMPO>, <VAR>, <nLINHA>, <nCOLUNA>, <cVALIDACAO>] �
	//��������������������������������������������������������������
	AADD(aCabec,{"Z08_CODIGO",,15, 10, ".T." })
	AADD(aCabec,{"Z08_DESC",,15,100, ".T." })
	
	
	//����������������������������������Ŀ
	//� Campos que compeem a chave Unica �
	//������������������������������������
	aChvUnq	:= {"Z08_CODIGO", "Z08_ITEM"}
	
	//������������������������������������������������������������������Ŀ
	//� Campo com ID UNICO Sequencial - Somente utlizado na Gravacao     �
	//� Nunca se repete mesmo que o registro seja deletado               �
	//� {<cCAMPO>, <cFuncao Gera Unico> }                                �
	//��������������������������������������������������������������������
//	aIDUniq	:= {"POO_ID", "GetUniq()"}


	aAC:={"Abandona","Confirma"}
	cTitulo := "Configurador Importa��o "
	cCadastro := OemToAnsi (cTitulo)
	lEnd := .F.                               	
	CdelFunc := ".T."
	
	aRotina := {{"Pesquis","AxPesqui ", 0, 1},;
	{"Visual"	,"U_CP07002A(2)", 0, 2},;
	{"Incluir"	,"U_CP07002A(3)", 0, 3},;
	{"Alterar"	,"U_CP07002A(4)", 0, 4},;
	{"Exclusao"	,"U_CP07002A(5)", 0, 5}}
	
	dbSelectArea(aAliasM2) 
	dbSetOrder(nIndChv)
	mBrowse(06,01,22,75,aAliasM2,,,30)
Return


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CP07002A �Autor  �Augusto Ribeiro     � Data �  05/04/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Configurador 	                                          ���
���          � | Inclusao/Alteracao/Exclusao                              ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function CP07002A(cOpcao)     
Local nGrava, cQuebra          
Local nScan		:= 0 
Local cChvReg	:= ""
Local aPosChv	:= {}  
Local aCpoLog	:= {} 	//| LOG

//��������������������������������������������������������������Ŀ
//� Opcao de acesso para o Modelo 2                              �
//����������������������������������������������������������������
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza
nOpcx:=cOpcao     


//��������������������������������������������������������������Ŀ
//� Montando aHeader                                             �
//����������������������������������������������������������������
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek(aAliasM2))   

nUsado	:= 0
aHeader	:= {}

While SX3->(!Eof()) .And. (SX3->x3_arquivo == aAliasM2)

	nScan	:= Ascan(aCabec,{|x| Alltrim(Upper(x[1]))==Alltrim(SX3->X3_CAMPO)})
	If nScan <> 0 //Alltrim(SX3->X3_CAMPO)=="POU_CENARI" //.OR. Alltrim(SX3->X3_CAMPO)=="POM_FILUSO" 
		      
		        
		aadd(aCabec[nScan],SX3->X3_CONTEXT)
		SX3->(dbSkip())
		Loop
	EndIf	

	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
		nUsado:=nUsado+1
		AADD(aHeader,{ TRIM(x3_titulo),;
						x3_campo,;
						x3_picture,;
						x3_tamanho,;
						x3_decimal,;
						x3_valid,;
						x3_usado,;
						x3_tipo,;
						x3_arquivo,;
						x3_context } )
	Endif
	SX3->(dbSkip())
EndDo



//�����������������Ŀ
//�                 �
//� MONTA INTERFACE �
//�                 �
//�������������������
//����������Ŀ
//� Inclusao �
//������������
If nOpcx==3 
	INCLUI	:= .T.
	ALTERA	:= .F.
	aCols := Array(1,nUsado+1)
	dbSelectArea("SX3")
	SX3->(dbSeek(aAliasM2))
	
	nUsado:=0
	
	While SX3->(!Eof()) .And. (x3_arquivo == aAliasM2)
	
		If Ascan(aCabec,{|x| Alltrim(Upper(x[1]))==Alltrim(SX3->X3_CAMPO)}) <> 0		
			dbSelectArea("SX3")
		   	SX3->(dbSkip())
			Loop
			
		EndIf	

		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado++                
			IF nOpcx == 3           
				aCOLS[1][nUsado]	:= CRIAVAR(SX3->X3_CAMPO, .T.)
			Endif
		Endif
		SX3->(dbSkip())
	EndDO              
	
	aCOLS[1][nUsado+1] := .F.	//| Delete
	aCOLS[1,1]	:= "001"     
	

//���������������������������������Ŀ
//� alteracao/exclusao/visualizacao �
//�����������������������������������
ElseIf nOpcx <> 3 
	INCLUI	:= .F.
	ALTERA	:= .T.

	aCols:={}
		
	dbSelectArea(aAliasM2)
	(aAliasM2)->(dbSetOrder(nIndChv))
	(aAliasM2)->(dbSeek(&(cChave)))  
	
	REGTOMEMORY(aAliasM2, .F.)

	//�����������Ŀ
	//� CABECALHO �
	//�������������
	FOR _ni := 1 TO LEN(aCabec)
		aCabec[_ni,2]	:=	M->&(aCabec[_ni,1]) 
	NEXT _ni	
	
	//����������������������Ŀ
	//� ITENS -  Monta aCols �
	//������������������������
	cQuebra	:=	&(cChave)
	While (aAliasM2)->(!Eof()) .And. cQuebra == &(cChave)
	
		AADD(aCols,Array(nUsado+1))
		
		REGTOMEMORY(aAliasM2, .F.)		
		
		For _ni:=1 to nUsado       
			aCols[Len(aCols),_ni]	:=	M->&(aHeader[_ni,2])
		Next
		
		aCols[Len(aCols),nUsado+1]	:=	.F.
		
		(aAliasM2)->( dbSkip() )
	Enddo                      
	
EndIf 
      
       
aAreaSX3	:= SX3->(GetArea())	
SX3->(DBSETORDER(2))

aC:={}
//��������������������������������������������������������������Ŀ
//� Array com descricao dos campos do Cabecalho do Modelo 2      �
//����������������������������������������������������������������
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.


//��������������������Ŀ
//� CABECALHO MODELO 2 �
//����������������������
If nOpcx==3

//	REGTOMEMORY(aAliasM2,.T.)  

	FOR ni := 1 TO LEN(aCabec)
		aCabec[nI,2]	:= CriaVar(aCabec[nI,1],.T.)   
                                
		//| Posiciona SX3
		SX3->(DBSEEK(aCabec[nI,1],.F.))
		                                
		cValidCpo	:= IIF(EMPTY(SX3->X3_VALID),".T. ",SX3->X3_VALID)+" .AND. "+IIF(EMPTY(SX3->X3_VLDUSER)," .T.",SX3->X3_VLDUSER)
		AADD(aC,{"aCabec["+alltrim(str(ni))+",2]"	,{aCabec[nI,3], aCabec[nI,4]}  ,ALLTRIM(SX3->X3_TITULO)   ,SX3->X3_PICTURE	,cValidCpo,SX3->X3_F3, IIF(SX3->X3_VISUAL == "V",.F., &(SX3->X3_WHEN))	})

	NEXT nI

	
Else

	(aAliasM2)->(dbSeek(cQuebra))

	FOR ni := 1 TO LEN(aCabec) 
	
		//| Posiciona SX3
		SX3->(DBSEEK(aCabec[nI,1],.F.))
			
		AADD(aC,{"aCabec["+alltrim(str(ni))+",2]"	,{aCabec[nI,3], aCabec[nI,4]}  ,ALLTRIM(SX3->X3_TITULO)   ,SX3->X3_PICTURE	, aCabec[nI,5] ,SX3->X3_F3, IIF(SX3->X3_VISUAL == "V",.F., &(SX3->X3_WHEN))	})					
	NEXT nI	
	
EndIf  

RestArea(aAreaSX3)

//��������������������������������������������������������������Ŀ
//� Array com descricao dos campos do Rodape do Modelo 2         �
//����������������������������������������������������������������
aR:={}
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.

//��������������������������������������������������������������Ŀ
//� Array com coordenadas da GetDados no modelo2                 �
//����������������������������������������������������������������
//aCGD:={} //{85,5,118,315}
// Coordenadas do objeto GetDados.
aCGD := {75,5,128,280}

//��������������������������������������������������������������Ŀ
//� Chamada da Modelo2                                           �
//����������������������������������������������������������������
lRetMod2 := Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk, , , cIniCpos,999999,/*aCordW*/,,.T.)



//��������������������Ŀ
//�                    �
//� GRAVACAO DOS DADOS �
//�                    �
//����������������������
If lRetMod2    
                              
	//������������������Ŀ
	//� *** INCLUSAO *** �
	//��������������������
	If nOpcx==3
		For nGrava:=1 To Len(aCols)
		                                   
			//| Desconsidera registro deletado
			If Acols[nGrava,Len(aHeader)+1]
				Loop
			EndIf


			//�������������������������������
			//� Alimenta campo do Cabecalho �
			//�������������������������������
			RecLock( aAliasM2,.T.)
			FOR nX	:= 1 TO LEN(aCabec)
				//������������������������������Ŀ
				//� Desconsidera campos virtuais �
				//��������������������������������
				IF aCabec[nX, Len(aCabec[nX])]	<> "V"
					&(aAliasM2+"->"+aCabec[nX,1])		:= aCabec[nX,2]
					
				ENDIF
			Next nX


			//��������������������������Ŀ
			//� Alimenta Campo dos Itens �
			//����������������������������
			For nX:=1 To Len(aHeader)    
				IF aHeader[nX,10] <> "V"

					&(aAliasM2+"->"+aHeader[nX,2])	:= 	Acols[nGrava,nX]
				ENDIF				
			Next nX
			MsUnLock()             
			ConfirmSx8()
			                        
		
		Next  nGrava
		
	//�������������������Ŀ
	//� *** ALTERACAO *** �
	//���������������������
	ElseIf nOpcx==4
	    
	    dbSelectArea(aAliasM2)
	    dbSetOrder(nIndChv)
	    
		For nGrava:=1 To Len(aCols)         
			
			//�������������Ŀ
			//� Monta Chave �
			//���������������
			cChvReg	:= XFILIAL(aAliasM2)				
			FOR nI := 1 TO LEN(aChvUnq)
	                     
	  			//| Cabec
				nPos	:=	Ascan(aCabec,{|x| Alltrim(Upper(x[1]))== aChvUnq[nI]  })
				IF nPos <> 0                                                          
					cChvReg	+= 	aCabec[nPos,2] //|aCols[nGrava, aPosChv[nI]] 					
				ENDIF		
	                                             
				//| Itens
				nPos	:=	Ascan(aHeader,{|x| Alltrim(Upper(x[2]))== aChvUnq[nI]  })
				IF nPos <> 0                                                          
					cChvReg	+= aCols[nGrava, nPos] 					
				ENDIF
			Next nI				
				

			          
			//��������������������������������������������������Ŀ
			//� Posiciona no registro a ser Alterado ou Excluido �
			//����������������������������������������������������			
			IF (aAliasM2)->(DBSEEK(cChvReg,.F.))   
			
				//������������������������������������������������������������������Ŀ
				//� EXCLUSAO                                                         �
				//� Caso linha tenha sido deletada, EXCLUI registro da tabela Fisica �
				//��������������������������������������������������������������������
				If Acols[nGrava,Len(aHeader)+1]
					RECLOCK(aAliasM2,.F.)
						(aAliasM2)->(DBDELETE())				
					MSUNLOCK()

					LOOP
				EndIf			
				
			     
				//������������������������������������������������������������������Ŀ
				//� ALTERACAO                                                        �
				//�                                                                  �
				//��������������������������������������������������������������������

				//�����������Ŀ
				//� CABECALHO �
				//�������������
				FOR nI := 1 TO LEN(aCabec)
					M->&(aCabec[nI,1])	:= aCabec[nI,2]									
				Next nI				

				//�������Ŀ
				//� ITENS �
				//���������
				FOR nI := 1 TO LEN(aHeader)
					IF aHeader[nI,10] <> "V"
						M->&(aHeader[nI,2])	:= aCols[nGrava,nI]									
					ENDIF
				Next nI
			

				//�������������������
				//� Grava Alteracao �
				//������������������� 
				nCpoAlt	:= 0  
				For nY := 1 To (aAliasM2)->(FCOUNT())                    
					     
					//| Armazena dados para gravacao do LOG
					IF (aAliasM2)->&(FieldName(nY)) <> M->&(FieldName(nY))
						aAdd( aCpoLog , { FieldName(nY) , (aAliasM2)->&(FieldName(nY)) , M->&(FieldName(nY)) } )	
						
						nCpoAlt++
						
						//���������������������������������������������������������Ŀ
						//� Otimizacao de Performance                               �
						//� Somente abre transacao se ao menos 1 campo foi alterado �
						//�����������������������������������������������������������
						IF nCpoAlt == 1
							RECLOCK(aAliasM2, .F.)	
						ENDIF

						(aAliasM2)->&(FieldName(nY))	:= M->&(FieldName(nY))						
					ENDIF
				Next nY				                                       

				(aAliasM2)->(MSUNLOCK())
				aCpoLog	:= {}
				
			//������������������������������������������������������������������Ŀ
			//� INCLUSAO                                                         �
			//� Quando o registro nao e localizado,inclui registro               �
			//��������������������������������������������������������������������			
			ELSE    				


				//| Desconsidera registros deletados 				
				If Acols[nGrava,Len(aHeader)+1]
					
					LOOP
				EndIf				
			                                       
			       
			
				//�������������������������������
				//� Alimenta campo do Cabecalho �
				//�������������������������������
				RecLock( aAliasM2,.T.)
				FOR nX	:= 1 TO LEN(aCabec)
					//������������������������������Ŀ
					//� Desconsidera campos virtuais �
					//��������������������������������
					IF aCabec[nX, Len(aCabec[nX])]	<> "V"
						&(aAliasM2+"->"+aCabec[nX,1])		:= aCabec[nX,2]
						
					ENDIF
				Next nX
	
	
				//��������������������������Ŀ
				//� Alimenta Campo dos Itens �
				//����������������������������
				For nX:=1 To Len(aHeader) 
					IF aHeader[nX,10] <> "V" 
					
						&(aAliasM2+"->"+aHeader[nX,2])	:= 	Acols[nGrava,nX]
					ENDIF
				Next
				MsUnLock() 

			ENDIF 
			
		Next nGrava	
		           
	//������������������Ŀ
	//� *** EXCLUSAO *** �
	//��������������������
	ElseIf nOpcx==5	 
	
		dbSelectArea(aAliasM2)
		(aAliasM2)->(dbSetOrder(nIndChv))
		(aAliasM2)->(dbSeek(&(cChave)))  		

		cQuebra	:=	&(cChave)
		While (aAliasM2)->(!Eof()) .And. cQuebra == &(cChave)
				
			RECLOCK(aAliasM2, .F.)			
				(aAliasM2)->(DBDELETE())			
			MSUNLOCK()
			
			(aAliasM2)->(dbSkip())
		Enddo		
	Endif 
ELSE
	ROLLBACKSX8()
	      
Endif

Return()


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CP07002G �Autor  �Augusto Ribeiro     � Data � 11/02/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna Conteudo do Pagametro solicitado                   ���
���          �                                                            ���
���PARAMETROS� cTipoNF, cChave, xDefault                                   ���
���RETORNO   � xRet | Formula                                             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function CP07002G(cCodigo, cChvFunc, xDefault)
Local xRet
       
	DBSELECTAREA("Z08")
	Z08->(DBSETORDER(2))
	IF Z08->(DBSEEK(XFILIAL("Z08")+cCodigo+cChvFunc,.F.))
		xRet	:= &(Z08->Z08_FORMUL)
	ELSE
		xRet	:= xDefault
	ENDIF

Return(xRet)


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CP07002D �Autor  �Augusto Ribeiro     � Data � 11/02/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Inclui Valore Defaults                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function CP07002D()
Local aDadosCad	:= {} 
Local aDadosN	:= {}         
Local aDadosZ08	:= {}
Local cDesc10, cDesc11, cDesc12
Local nI, nY, nX


//	"<Codigo, Chave, Default, DESCTEC>"	


	//�������������������������������������������������������������������Ŀ
	//� DANFE - CONFIGURACOES GLOBAIS                                     �
	//� Parametros para importacao nota fiscal de entrada e saida vai XML �
	//���������������������������������������������������������������������
	cDesc20	:= "REEMBOLSO DE DESPESA - Configura��es"
	aDadosCad	:= {}
	AADD(aDadosCad,{"20", "DIRCOMPROV", 	'"\data_reembolso\comprovantes\"',	"[C] Diretorio onde sera gravada comprovantes"})
	AADD(aDadosCad,{"20", "DIRLIXEIRA", 	'"\data_reembolso\comprovantes\lixeira\"',	"[C] Lixeira onde sera armazenado os arquivos excluidos"})
	AADD(aDadosCad,{"20", "ALIASDESP", 	'"SED"',	"[C] Alias da entidade utilizada para identificar a despesa SB1 ou SED"})
	AADD(aDadosCad,{"20", "AGRUPATITU",	'"NAOAGRUPA"',	"[C] Agrupamento dos titulos no financeiro. [NAOAGRUPA, DESPESA, USUARIO]. Caso seja utilizado por 'USUARIO', obrigatorio informar param. [NATUREZFIX] "})
	AADD(aDadosCad,{"20", "NATUREZFIX",	'"1000"',	"[C] Codigo da Natureza no qual sera gerado TODOS os titulo. Natureza FIXA"})
	AADD(aDadosCad,{"20", "E2_FILIAL", 	'"01"',	"[C] Filial onde sera gerado o titulo a pagar"})
	AADD(aDadosCad,{"20", "E2_PREFIXO", 	'"DES"',	"[C] Prefixo do Titulo a pagar"})
	AADD(aDadosCad,{"20", "E2_TIPO", 		'"DES"',	"[C] Tipo do Titulo a Pagar"})


	aadd(aDadosN, {"20",cDesc20, aDadosCad})
	
 

	DBSELECTAREA("Z08")              
	nTotCpo	:= FCOUNT()
	Z08->(DBSETORDER(2))             

    
	FOR nX := 1 TO LEN(aDadosN)    
         
		IF Z08->(DBSEEK(XFILIAL("Z08")+aDadosN[nX,1]))   
			cDesc11	:= Z08->Z08_DESC
		ELSE
			cDesc11  := aDadosN[nX,2]
		ENDIF	                    

		aDadosZ08 := aDadosN[nX,3]
		      
		cCodConfig	:= aDadosN[nX,1]
		FOR nI := 1 to len(aDadosZ08)  

			IF Z08->(!DBSEEK(XFILIAL("Z08")+aDadosZ08[nI, 1]+aDadosZ08[nI, 2]))  
				
				RegToMemory("Z08",.T.)
				      
				M->Z08_CODIGO	:= aDadosZ08[nI, 1]
				M->Z08_DESC		:= cDesc11
				M->Z08_ITEM		:= SOMA1( RetMaxItem(aDadosZ08[nI, 1]) )
				M->Z08_CHAVE	:= aDadosZ08[nI, 2]
				M->Z08_FORMUL	:= aDadosZ08[nI, 3]
				M->Z08_DESTEC 	:= aDadosZ08[nI, 4]
				
				RECLOCK("Z08",.T.)
					FOR nY := 1 to nTotCpo
						FieldPut(nY, M->&(FieldName(nY)))
					NEXT nY		     
				MSUNLOCK()    
		                         
			ENDIF
		NEXT  nI
	NEXT nX
	

Return()

                            
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � RetMaxItem�Autor �Augusto Ribeiro     � Data � 11/02/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna last item                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function RetMaxItem(cCodigo)
Local cRet 		:= ""
Local cQuery	:= ""
                    
cQuery	+= " SELECT MAX(Z08_ITEM) AS Z08_ITEM "
cQuery	+= " FROM "+RetSqlName("Z08")
cQuery	+= " WHERE Z08_FILIAL = '' "
cQuery	+= " AND Z08_CODIGO = '"+cCodigo+"' "
cQuery	+= " AND D_E_L_E_T_ = '' "

                               
If Select("TITEM") > 0
	TITEM->(DbCloseArea())
EndIf                
              
cQuery	:= changeQuery(cQuery)         
         
DBUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TITEM", .F., .T.)      	 
    

IF TITEM->(!EOF()) 
	cRet	:= TITEM->Z08_ITEM
ELSE
	cRet	:= "000"
ENDIF
          
TITEM->(DbCloseArea())

Return(cRet)



