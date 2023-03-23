#include 'protheus.ch'
#include 'parmtype.ch'
#Include "tbiconn.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TBICONN.CH'
#include "MSOle.Ch"


/*-----------------------------------------------------------------
	Codigo da Adquirentes
------------------------------------------------------------------*/
#DEFINE ADQ_BIN  "001"
#DEFINE ADQ_CIELO  "002"
#DEFINE ADQ_GETNET  "003"
#DEFINE ADQ_REDE  "004"


/*-----------------------------------------------------------------
	Posies fixas do Array do Layout.
------------------------------------------------------------------*/

#DEFINE CAMPOSX3 1
#DEFINE POSINI   2
#DEFINE POSFIM   3
#DEFINE TIPO     4
#DEFINE FORMULA  5


user function IMP_TST()		
	
	PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' MODULO 'FAT'
		
		
	U_CP11005("E:\ALLIAR_CARTOES\CIELO\EXTVISA161017.txt")
	U_CP11005("E:\ALLIAR_CARTOES\CIELO\EXTVISA17101701.txt")
	U_CP11005("E:\ALLIAR_CARTOES\CIELO\EXTVISA18101701.txt")			
		/*
	U_CP11005("C:\AF\Arq_teste.txt") //| Teste da REDECARD
	U_CP11005("C:\AF\GETNET.txt") //| Teste da GETNET
	U_CP11005("C:\AF\TESTE_BIN.TXT") //| Teste da BIN.
		*/
		
	RESET ENVIRONMENT
			
Return()


/*/{Protheus.doc} CP11005
Funo genrica para importao dos arquivos da Adquirentes.
@author Fabio Sales | www.compila.com.br
@since 12/10/2017
@version 1
@return {.F.,"", {aZC4Comp = Complemento para Gravacao do registro do arquivo}}  | aZC4Comp Exemplo = {{ZC4_CODADQ,"001"}, {ZC4_VERSAO,"1"}}}
@example
(examples)
@see (links_or_references)
/*/


User Function CP11005(cCodArq, cpath)
Local alRet		:= {.F.,"", {},""}
Local Ni		:= 0	
Local nTamLay	:= 0
Local lFirstLine:= .T.
Local alLayoutad:= {}
Local alLayout	:= {}
Local alLinha	:= {}	
Local alzc8		:= {}
Local clTipo	:= ""
Local nLayouttp := 0
Local clFormul	:= ""
Local nlTamstr	:= 0
Local nlPosFim	:= 0
Local nlPosInich := 0
Local nLinArq	:= 0
Local aRetAux	:= {}
Local nQtdeImp	:= 0
Local nJaExiste := 0
Local aZC4Comp	:= {}
Local clChvHead := ""
Local clTipArq	:= ""
Local NJ

Default cpath	:= ""

Private xPConteu:= ""

		
IF !empty(cCodArq) .and. !empty(cpath)

	//| Abre o arquivo.
	
	FT_FUSE(cpath)
	
	//| Alimenta a Rgua de progresso com a Quantidade de linhas no arquivo.
	
	//|nLinhas	:= FT_FLASTREC()			
	//|ProcRegua(nLinhas)
	
	//| Posiciona no primeiro Registro.
	
	FT_FGOTOP()
	
	lFirstLine := .T.
	
	Do While !FT_FEOF()
		nLinArq++
					
		//IncProc("Processando Arquivo...")		
		
		cLinha	:= FT_FREADLN() //| Obtm a linha corrente do Arquivo.
			
		/*		
		 Verifica o Header do Arquivo para identificar a Adquirente
		 e Carregar as configuraes de importao. Executa somente
		 na promeira linha.
		*/
		
		IF lFirstLine
			
			lFirstLine := .F.																		
			
			//| Obtm Layout de importao de acordo com adquirente do Header.
			
			aRetAux		:= U_CP11005A(cLinha) //| Carrega Configuraes de acordo com a Adquirente.			
			IF EMPTY(aRetAux[1])
				alRet[2]:= " CP11005: Arquivo invlido."
				alRet[4]:= "ARQINVALIDO"
				EXIT
			ELSE
				aadd(aZC4Comp, {"ZC4_CODADQ",aRetAux[1]})
			ENDIF
						
			alLayout 	:= aRetAux[2] //| Carrega Configuraes de acordo com a Adquirente.																															
			
			//|Tratativas para evitar duupliicidade de registros na GETNET.
			IF LEN(alLayout) >= 4
				IF alLayout[4]== ADQ_GETNET			
					clChvHead := Subs(cLinha,16,8) //| Data do movimento
				ELSE
					clChvHead := ""
				ENDIF	
			ENDIF
																																		
		ENDIF														
												
		nTamLay := Len(alLayout)
		
		If nTamLay > 0
		
			nTamtipArq 	:= alLayout[1] //| Tamanho do Tipo de Registro.
			alLayoutad	:= alLayout[2] //| Array com as configuraes das adquirentes.
			cAlias		:= alLayout[3] //| Alias.
			clCodad		:= alLayout[4] //| Codigo da adquirente.
			clTpArq		:= alLayout[5] //| Tipo de arquivo F= Fixo; V= Variavel
			clSepara	:= alLayout[6] //| Separador de campo 1=TXT-Virgula;2=TXT-Ponto e Virgula;3=TXT-Pipe;4=TXT-Fixo
			
			IF !EMPTY(clTpArq) //| Verifica o tipo do arquivo se  fixo ou varivel.
			
				//| Tipo de separao dos campos.
				
				IF clTpArq == "V" //| Varivel	
													
					alLinha := StrTokArr2(cLinha, clSepara,.T.)	//| Transforma a linha em array de acordo com separador no segunto parametro.																									
											
				ENDIF
				
				clTipArq := Left(cLinha,nTamtipArq) //| Identifica o tipo do arquivo.
						
				nlPosArray := aScan(alLayoutad,{|x| ALLTRIM(x[1]) == clTipArq}) //| Busca a posio do tipo de arquivo no array de Layouts da Adquirente.
				
				IF nlPosArray > 0
												
					nLayouttp := Len(alLayoutad[nlPosArray][2])
					
					Ni := 0
												
					For Ni := 1 To nLayouttp
						
						/*
						 Preenchimento do contedo de acordo com as configuraes de Layout da adiquirente.
						*/
																											
						clCposx3	:= alLayoutAd[nlPosArray][2][Ni][CAMPOSX3]
						nPosIni		:= alLayoutAd[nlPosArray][2][Ni][POSINI]					
						nlPosFim		:= alLayoutAd[nlPosArray][2][Ni][POSFIM]
						nlTamstr		:= (nlPosFim - nPosIni) + 1						
						clTipo		:= alLayoutAd[nlPosArray][2][Ni][TIPO]							
						clFormul	:= Alltrim(alLayoutAd[nlPosArray][2][Ni][FORMULA])
						
						IF clTpArq == "F" //| Define se a configurao da linha  fixa ou varivel(Com separador).
															
							xPConteu 	:= SubStr(cLinha,nPosIni,nlTamStr)
							
						ELSE
						
							xPConteu 	:= alLinha[nPosIni]
							
						ENDIF																
						
						IF clTipo=="F" //| Formula 
						
							IF nlPosFim == 0
							
								xPConteu := &(clFormul)													
								 
							ENDIF
							
						ELSEIF clTipo=="N"
													
							xPConteu	:= Val(xPConteu)/100
							
						ELSEIF clTipo=="D"
						
							//|Verifica qual adquirente de acordo com o Alias.
							IF cAlias =="ZC6" .AND. LEN(xPConteu) == 6//| CIELO
								xPConteu 	:= "20"+xPConteu									
								xPConteu	:= STOD(xPConteu)
							
							ELSEIF cAlias $ "ZC8/ZC5/ZC7" //| ZC8=RedeCard;ZC5=BIN;ZC7=GETNET
							 	
							 	//| Tratativa para a data de acordo com a documentao.
							 														
								xPConteu	:= left(xPConteu,2) +"/" + subs(xPConteu,3,2)+ "/" + Right(xPConteu,4)
								xPConteu	:= ctod(xPConteu)
							
							//| Falta Inclui regra para outras Operadoras.
							ELSE 
								xPConteu	:= STOD(xPConteu)							
							ENDIF																										
						
						ENDIF
						
						/*------------------------------------------------------ Augusto Ribeiro | 27/10/2017 - 3:21:04 PM
							Quando campo pertencer a tabela de registro de arquivos
							retorna no array de retono para gravacao na ZC4.
							ATENO: importante utilizar registros que somente tenha uma ocorrencia por arquivo
							para evitar sobreposicao de informao
						------------------------------------------------------------------------------------------*/
						IF LEFT(clCposx3,3) =="ZC4"
							aadd(aZC4Comp, {clCposx3,xPConteu})
						ELSE																								
							AADD(alzc8,{clCposx3,xPConteu})
						ENDIF											
																						
					Next Ni
					
					/*
					 Grava a filial e a linha inteira para uma possvel anlise posterior.
					 OBSERVE: O campo de sufixo _REGIST precisa esta em todas as entidade
					 que sero alimentadas por esta rotina.
					*/
					AADD(alzc8,{cAlias+"_CODARQ",cCodArq})
					AADD(alzc8,{cAlias+"_LINARQ",nLinArq})
					AADD(alzc8,{cAlias+"_FILIAL",XFILIAL(cAlias)})
					AADD(alzc8,{cAlias+"_REGIST",cLinha})
										
					clChave := ""
					
					DBSELECTAREA("ZC0")
					ZC0->(DBSETORDER(1)) //| ZC9_FILIAL+ZC9_CODADQ+ZC9_TIPREG+ZC9_ITEM
					
					/*
						Posiciona no cabealho da entidade de Layout para obter a configurao 
						de montagem da chave de gravao.
					*/
						
					IF ZC0->(DBSEEK(XFILIAL("ZC0") + clCodad + clTipArq ))							
														
						clChave := Alltrim(ZC0->ZC0_CHVREG)
												
					ENDIF
					
					IF !EMPTY(clChave)
																										
						alchave:= &(clChave)						
						
						IF Len(alchave) > 0
						
							nPosAux	:= aScan(aZC4Comp,{|x| ALLTRIM(x[1]) == "ZC4_TPARQ"})  //aZC4Comp
												
							IF nPosAux > 0
								xPConteu := ALLTRIM(aZC4Comp[nPosAux,2])
							ELSE
								xPConteu := ""
							ENDIF		
							
							FOR NJ := 1 TO Len(alchave)
								
								nlPosInich	:= alchave[NJ][1]
								nPosTam 	:= alchave[NJ][2]
								
								
								/*
									A chave  composta por arrays com posies definidas.
									Exemplo1: {{1,3},{5,7}} Este exemplo1  aplicado para o tipo de arquipo de posies fixa.
									Cada array representa um campo, os elementos que esto nele representa a posio inicial
									na linha e o tamanho respectivamente. No exemplo temos uma chave com dois campos.
									
									Para os tipos de arquivos ariveis que vem com separador,o contedo  o mesmo, 
									porm o primeiro elemento de cada array	representa a posio do campo dentro do Array.
								*/
								
								IF clTpArq == "F"
								
									xPConteu 	+= SUBS(cLinha,nlPosInich,nPosTam)
									
								ELSE
									xPConteu += alLinha[nlPosInich]																		
								ENDIF
							Next
							
							/*------------------------------------------------------ Augusto Ribeiro | 01/11/2017 - 4:42:14 PM
								ALIMENTA CHAVE DO REGISTRO utilizada para evitar duplicidade.
							------------------------------------------------------------------------------------------*/
							xPConteu += clChvHead							
							AADD(alzc8,{cAlias+"_CHVREG", UPPER(FwNoAccent(xPConteu))})
							
						ENDIF
											
					ENDIF
																		
					//| Verifica se existe registro para gravao.
					
					IF LEN(alzc8) > 0
					
						aRetAux := U_CPXGRV(cAlias,2,alzc8,.T.,2)
						IF aRetAux[1]
							nQtdeImp++
						ELSEIF aRetAux[2] == "JAEXISTE"
							nJaExiste++
						ENDIF						
					ENDIF
					
					alzc8:= {}
																																
				else
					//alRet[2]:= " CP11005: Layout no configurado para esta Adquirente + Tipo Arquivo ["+alLayout[4]+"]["+clTipArq+"]"
					//alRet[4]:= "TIPOARQ"
					IF EMPTY(alRet[4])
						alRet[4]:= "TIPOARQ"
					ENDIF
				Endif
			ELSE
				alRet[2]:= " CP11005: No foi encontrado o delimitador do registro."
			ENDIF
			
		Else
		
			alRet[2]:= " CP11005: No foi possvel obter o Layout de importao para o Arquivo"
			EXIT
		EndIf			
																
		FT_FSKIP()
	EndDo
	
	//| Fecha arquivo aberto|
	FT_FUSE()
						
Else
	alRet[2]:= " CP11005: Arquivo de destino."
EndIf



IF nQtdeImp == 0  .AND. nJaExiste > 0
	alRet[2] := "Registros j existentes ["+alltrim(str(nJaExiste))+"]. Nenhum registro foi importado."
	alRet[4]:= "JAEXISTE"
ELSEIF nQtdeImp == 0  .AND. nJaExiste == 0
	IF alRet[4] == "TIPOARQ"
		alRet[2]:= " CP11005: Layout no configurado para esta Adquirente + Tipo Arquivo"
	ENDIF
ELSEIF nQtdeImp > 0 .AND. EMPTY(alRet[2])
	alRet[1]	:= .T.
	alRet[3]	:= aZC4Comp
ENDIF
			
Return(alRet)


/*/{Protheus.doc} CP11005A
Retorna Configurao conforme adquirente na linha xdo Parmetro.
@author Fabio Sales | www.compila.com.br
@since 12/10/2017
@version 1
@return aRet, {cCodAdq, aLayout}
@example
(examples)
@see (links_or_references)
/*/

User Function CP11005A(cLinha)
Local aRet		:= {"",{}}
Local AlRetL	:= {}
Local AlTipReg	:= {}
Local alLin		:= {}
Local clCodAdq	:= ""
Local clTipo	:= ""	
Local clDelimit	:= ""
Local clAlias	:= ""
Local cTmp1
Local cTMP2
Local cTMP3

Default cLinha  := ""
	
IF Len(Alltrim(cLinha)) > 0

	//| Descobre a qual adquirente pertence o arquivo.		
			
	IF UPPER(SUBS(cLinha,12,8))== "REDECARD"		
		clCodAdq := ADQ_REDE		
	ELSEIF UPPER(SUBS(cLinha,43,5))== "CIELO"
		clCodAdq := ADQ_CIELO
	ELSEIF  UPPER(SUBS(cLinha,61,6))== "GETNET"
		clCodAdq := ADQ_GETNET					
	ELSE  			
		alLin := StrTokArr2(cLinha, ",",.T.)
		
		IF LEN(alLin) >= 3
		 							
			// 20211025 - HFP - Compila
			// alterado IF abaixo, porque os txts vindo com a string do "ctmp2" e com isso
			// nao processava os arquivos.
			cTmp1:= "FD DO BRASIL PROCESSAMENTO DE DADOS"
			cTMP2:= "FIRSTDATA-BIN(003)"
			cTMP3:= "BIN"
			//IF "FD DO BRASIL PROCESSAMENTO DE DADOS" $ UPPER(ALLTRIM(alLin[3])) // BIN
			IF cTmp1 $ UPPER(ALLTRIM(alLin[3]))  .OR.;
				 cTmp2 $ UPPER(ALLTRIM(alLin[3])) .OR.; 
				 cTmp3 $ UPPER(ALLTRIM(alLin[3]))
				 // BIN

				clCodAdq := ADQ_BIN
					
			ENDIF
										
		ENDIF	
																		
	ENDIF					
	
	
	IF !EMPTY(clCodAdq)
	
		DBSELECTAREA("ZC0")
		ZC0->(DBSETORDER(1)) //| ZC9_FILIAL+ZC9_CODADQ+ZC9_TIPREG+ZC9_ITEM
			
		IF ZC0->(DBSEEK(XFILIAL("ZC0") + clCodAdq ))							
			
			clAlias		:= ZC0->ZC0_ALIAS
			clTipo		:= ZC0->ZC0_TIPARQ
			clDelimit	:= ZC0->ZC0_DELIMI
						
			TamTipReg := LEN(ALLTRIM(ZC0->ZC0_TIPREG))				 						
			
			DBSELECTAREA("ZC9")
			ZC9->(DBSETORDER(1))
			
			IF ZC9->(DBSEEK(XFILIAL("ZC9") + clCodAdq ))
			
				WHILE ZC9->(!EOF()) .AND. clCodAdq == ZC9->ZC9_CODADQ
					
					clTipReg := ZC9->ZC9_TIPREG
					
					WHILE ZC9->(!EOF()) .AND. clCodAdq == ZC9->ZC9_CODADQ .AND. clTipReg == ZC9->ZC9_TIPREG
																	
						AADD(AlTipReg,{ZC9->ZC9_CPOSX3,ZC9->ZC9_POSINI,ZC9->ZC9_POSFIM,ZC9->ZC9_TIPO,ZC9->ZC9_FORMUL})
					
						ZC9->(DBSKIP())
																	
					ENDDO
												
					AADD(AlRetL,{clTipReg,AlTipReg})
					AlTipReg := {}
					
				ENDDO							
			
				AlRetL := {TamTipReg,AlRetL,clAlias,clCodAdq,clTipo,clDelimit}
				
			ENDIF
			
		ENDIF
		
		
		aRet	:= {clCodAdq,AlRetL}
		
	ENDIF

ENDIF



Return(aRet)
