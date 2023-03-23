#Include "Protheus.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#include "TbiConn.ch"


/*/{Protheus.doc} CTA100MNU
Ponto de entrada para adicionar botão na interface de manutenção de contrato
@author Augusto Ribeiro | www.compila.com.br
@since 04/10/2018
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CTA100MNU ()
	//ADD OPTION aRotina TITLE 'Replicar_Contrato'    ACTION 'U_CTA100CP()' OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE 'Replicar_Contrato-(v1)'    ACTION 'U_SELECFIL()' OPERATION 9 ACCESS 0
Return



/*/{Protheus.doc} SELECFIL
Carrega a tela pra selecionar as filiais 
@author Mateus Hengle | www.compila.com.br
@since 14/09/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function SELECFIL()

	Local oDlgMain     := Nil
	Local oListBox     := Nil
	Local oCheck       := Nil
	Local aCoordenadas := MsAdvSize(.T.)
	//hfp Local nOpcClick    := 0  // retirado pq nao esta em uso
	Local lMarcaDesm   := .F.
	//hfp Local lEdicao      := .T.  // retirado pq nao esta em uso
	Local aNotas 	   := {}
	//hfp Local lMarcaDesm   := .F. // retirado pq nao esta em uso
	//hfp Local cCod         := cUserName  // retirado pq nao esta em uso
	Local aValida      := {}
	Local _cCodEmp, _cCodFil, _cFilNew

	Private oOk        := LoadBitmap( GetResources(), 'LBOK')
	Private oNo        := LoadBitmap( GetResources(), 'LBNO')
	Private cFilPos    := CN9->CN9_FILIAL
	Private cContra    := CN9->CN9_NUMERO

	Private _cFileLog	:= ""
	Private _cLogPath	:= ""
	Private _Handle		:= ""

	oModel := FWLoadModel("CNTA300")
	oModel :SetOperation(1)
	oModel :Activate()
	aValida := aClone(oModel:AMODELSTRUCT[1,3]:ADATAMODEL)

	IF Len(aValida[1]) == 0
		Aviso("Acesso negado","Usuário não possui direito sobre a transação executada",{"Ok"})
		Return
	ENDIF


/*---------------------------------------
Realiza a TROCA DA FILIAL CORRENTE
-----------------------------------------*/
_cCodEmp 	:= SM0->M0_CODIGO
_cCodFil	:= SM0->M0_CODFIL
_cFilNew	:= cFilPos //| CODIGO DA FILIAL DE DESTINO

IF _cCodEmp+_cCodFil <> _cCodEmp+cFilPos
	CFILANT := cFilPos
	opensm0(_cCodEmp+CFILANT)
ENDIF

cGetFil := GETMV("MV_XFILI",.F.,.T.)

// VERIRIFICA SE A FILIAL EH REPLICADORA
IF !cGetFil
	//	ALERT("Filial posicionada não é replicadora! Favor ajustar o parâmetro MV_XFILI e tentar novamente!")
	Help(" ",1,"CTA100MNU",,"Filial posicionada não é replicadora! Favor ajustar o parâmetro MV_XFILI e tentar novamente!" ,4,5)
	
	/*---------------------------------------
	Restaura FILIAL
	-----------------------------------------*/
	IF _cCodEmp+_cCodFil <> _cCodEmp+cFilPos
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)
	ENDIF
	
	Return
ENDIF

//Desenha a Tela
oDlgMain := TDialog():New(aCoordenadas[7],000,aCoordenadas[6],aCoordenadas[5],OemToAnsi("Selecionar Filiais"),,,,,,,,oMainWnd,.T.)

TGroup():New(10,003,oDlgMain:nClientHeight/2-15,oDlgMain:nClientWidth/2-5,"Filiais",oDlgMain,,,.T.)

/*
TButton():New(280,570,"Fechar",oDlgMain,{|| oDlgMain:End()},065,011,,,,.T.,,"",,,,.F. )
TButton():New(280,490,"Replicar Contrato",oDlgMain,{|| Processa(Ordena(aNotas)) },065,011,,,,.T.,,"",,,,.F. )
*/

	aNotas := {{.F.,"",""}}


	oListBox := TWBrowse():New(060,008,oDlgMain:nClientWidth/2-17,oDlgMain:nClientHeight/2-115,,{" ","Filial","Descrição Filial"},,oDlgMain,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListBox:SetArray(aNotas)
	oListBox:bLine := {||{ 	IIf(aNotas[oListBox:nAt,1],oOk,oNo ),;
		aNotas[oListBox:nAt][2],;
		aNotas[oListBox:nAt][3]}}
	oListBox:bLDblClick := {|| aNotas[oListBox:nAt,1] := !aNotas[oListBox:nAt,1]}
	oListBox:Refresh()

	Processa({|| Carrega(aNotas,oListBox) })

	nxLin:= 25  // 20210504 HFP-Compila -  alterado para deixar botoes mais acima, algumas telas ficando baixo e nao aparecendo
	nCol1:= 250
	nCol2:= 350
	TButton():New(nxLin,nCol1,"Replicar Contrato (v1)",oDlgMain,{|| Processa(Ordena(aNotas)) },065,011,,,,.T.,,"",,,,.F. )
	TButton():New(nxLin,nCol2,"Fechar",oDlgMain,{|| oDlgMain:End()},065,011,,,,.T.,,"",,,,.F. )

	@ 025,12 CHECKBOX oCheck VAR lMarcaDesm PROMPT "*Marcar/Desmarcar Todos" SIZE 200,10 OF oDlgMain PIXEL ON CHANGE (LJMsgRun("Aguarde...","Aguarde...",{|| MarcaDesm(@aNotas,@oListBox)}))


	oDlgMain:Activate(,,,.T.)


/*---------------------------------------
Restaura FILIAL
-----------------------------------------*/
IF _cCodEmp+_cCodFil <> _cCodEmp+cFilPos
	CFILANT := _cCodFil
	opensm0(_cCodEmp+CFILANT)
ENDIF
Return

/*/{Protheus.doc} Carrega
Carrega as filiais no array 
@author Mateus Hengle   | www.compila.com.br
@since 14/09/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function Carrega(aNotas,oListBox)

aNotas := {}

// LACO PARA CARREGAR A FILIAL CORRETA DO TXT
_aArea := GetArea()
DbSelectArea("SM0")
SM0->(DbGoTop())


DBSELECTAREA("SZK")
SZK->(DBSETORDER(1)) //| 


DO WHILE !SM0->(EOF())
	//IF ALLTRIM(SM0->M0_CODIGO) == '01'
	IncProc()
	IF SZK->(DBSEEK(SM0->M0_CODIGO + SM0->M0_CODFIL)) .AND. SZK->ZK_MSBLQL != "1"
		AAdd(aNotas,{.F.,SM0->M0_CODFIL,SM0->M0_FILIAL})
	ENDIF 
	//ENDIF
	SM0->(DbSkip())
ENDDO
RestArea( _aArea )

//Atualiza o list de produtos
oListBox:SetArray(aNotas)
oListBox:bLine := {||{ 	IIf(aNotas[oListBox:nAt,1],oOk,oNo ),;
aNotas[oListBox:nAt][2],;
aNotas[oListBox:nAt][3] }}
oListBox:Refresh()

lEdicao := .F.

Return


/*/{Protheus.doc} MarcaDesm
Marcar ou Desmarcar todos os itens 
@author Mateus Hengle | www.compila.com.br
@since 14/09/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MarcaDesm(aNotas,oListBox)
Local i
ProcRegua(Len(aNotas))

For i := 1 To Len(aNotas)
	IncProc()
	aNotas[i,1] := !aNotas[i,1]
	If aNotas[i,1]
		aNotas[i,3] := aNotas[i,2]
	EndIf
Next i

oListBox:SetArray(aNotas)
oListBox:bLine := {||{ 	IIf(aNotas[oListBox:nAt,1],oOk,oNo ),;
aNotas[oListBox:nAt][2],;
aNotas[oListBox:nAt][3]}}
oListBox:Refresh()

Return


/*/{Protheus.doc} Ordena
(long_description)
@author Mateus Hengle  | www.compila.com.br
@since 14/09/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function Ordena(aNotas)
Local z
Private aSelec   := {}

// Add apenas os itens marcados
For z:= 1 To Len(aNotas)
	IncProc()
	IF aNotas[z,1]
		aAdd(aSelec,{aNotas [z][1],;
		aNotas [z][2],;
		aNotas [z][3]})
	ENDIF
Next z

//SELECX(aSelec)
//U_CTA100CP(aSelec)
Processa({|| U_CTA100CP(aSelec)},"Replicando contrato")
Return



/*/{Protheus.doc} CTA100CP
Realiza a copia do contrato posicionado
@author Augusto Ribeiro | www.compila.com.br
@since 04/10/2018
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CTA100CP(aFilCopy)
Local aRet		:= {.F., ""}
//hfp Local cQuery	:= "" // retirado pq nao esta em uso
Local oModel, oModFull  //, aDados, 
Local oModCNB, oModCNA, oModCN9
Local nI, nY, nQtdPai, nIF, nYF, nIN, nXN, nA, nModPai, nDadosPai, nCpoHeader, nModFilho, nDadoFilho, nCpoFilho, nModNeto, nDadoNeto, nCpoNeto
Local aCN9MASTER	:= {}
Local aDadoMod		:= {}
Local cMsgErro			:= ""
Local cChavCN9		:= CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA)
Local nTotCpo		:= 0 
Local nRecCNF		:= 0 
Local cCnpjFil		:= ""
Local aEmpSm0		:= {}
Local nTotCna		:= 0 
Local nTotLen		:= 0 
Local nFil

fGrvLog(1,"Iniciando replicação de contrato. " + CN9->CN9_NUMERO +"  " + TIME()+". "+ DToC(ddatabase)  )

IF !EMPTY(aFilCopy)
	
	aEmpSm0 := RetSM0() 
	
	DBSELECTAREA("CNF")
	CNF->(DBSETORDER(2))//|CNF_FILIAL+CNF_CONTRA+CNF_REVISA|)
	
	aAreaCN9	:= CN9->(GETAREA())
	
	
	oModFull := FWLoadModel("CNTA300")
	oModFull:SetOperation(1)
	oModFull:Activate()
	
	//| CN9MASTER |
	aMStruct	:= aClone(oModFull:aModelStruct[1])
	aCN9MASTER	:= aClone(oModFull:aModelStruct[1,3]:aDataModel[1])
	//aCN9Martes tem todo o achoice do cadastrais
	
	//------------------------------------------
	//	QUANTIDADE DE MODELO DE DADOS
	//	FILHOS DA MASTER
	//-------------------------------------------
	nQtdMod	:= 0
	FOR nI := 1 TO LEN(oModFull:aModelStruct[1,4])
	
		//| sOMENTE CARREGA O QUE PERMITE INSERIR LINHAS |
		IF oModFull:aModelStruct[1,4,nI,3]:LINSERTLINE
			
			//aadd(aDadoMod, {"",{},{},{}} ) //Nome Model, Header, Dados, Filhos
			//aadd(aDadoMod, { "",{},{ {},{} } } ) //{}Nome Model, Header, {Dados, Filhos}}
	
			
			//| Verifica se possui dados |
			IF len(oModFull:aModelStruct[1,4,nI,3]:aDataModel) > 0
				
				aadd(aDadoMod, { "",{}, {} } ) //{}Nome Model, Header, {Dados, Filhos}}
				nQtdMod++
				cModPai			:= oModFull:aModelStruct[1,4,nI,2] //Nome Model
				aDadoMod[nQtdMod,1]	:= cModPai
				
				//| Carrega Header |
				FOR nY := 1 to len(oModFull:aModelStruct[1,4,nI,3]:aHeader)		
					aadd(aDadoMod[nQtdMod,2], oModFull:aModelStruct[1,4,nI,3]:aHeader[nY,2] )		
				NEXT nY		
			
				
				FOR nQtdPai := 1 TO len(oModFull:aModelStruct[1,4,nI,3]:aDataModel)	
					
					oModFull:GetModel(cModPai):Goline(nQtdPai)			
					aadd(aDadoMod[nQtdMod,3], {aClone(oModFull:aModelStruct[1,4,nI,3]:aDataModel[nQtdPai,1,1]), {} })		
					
					
					//-----------------------------------------------------------------
					//	NIVEL 2 - Verifica se Grid possui tabelas FILHO relacionadas
					//-----------------------------------------------------------------
					IF LEN(oModFull:aModelStruct[1,4,nI,4]) > 0
					
						aFilho	:=  aClone(oModFull:aModelStruct[1,4,nI,4])
						aDadoF	:= {}
						
						nQtdFilho:= 0
						FOR nIF := 1 TO LEN(aFilho)
						
							//| sOMENTE CARREGA O QUE PERMITE INSERIR LINHAS |
							IF IIF(aFilho[nIF,1]=="GRID", aFilho[nIF,3]:LINSERTLINE,.F.)
								
								
								
								//aDadoMod[nQtdMod,3,nQtdPai,2]	:= { "",{},{} }
								nQtdFilho++
								aadd(aDadoMod[nQtdMod,3,nQtdPai,2], { "",{},{} })
								
								//aadd(aDadoF, {"",{},{},{}} ) //Nome Model, Header, Dados, Filhos
								
								//aadd(aDadoF, { "",{},{ {},{} } } ) //{}Nome Model, Header, {Dados, Filhos}}
								cModFilho 	:= aFilho[nIF,2]
								aDadoMod[nQtdMod,3,nQtdPai,2,nQtdFilho,1]	:= cModFilho //Nome Model
								
								//| Carrega Header |
								FOR nYF := 1 to len(aFilho[nIF,3]:aHeader)		
									aadd(aDadoMod[nQtdMod,3,nQtdPai,2,nQtdFilho,2], aFilho[nIF,3]:aHeader[nYF,2] )		
								NEXT nYF
								
								//| Carrega Dados |
								FOR nYF := 1 TO len(aFilho[nIF,3]:aDataModel)	
									oModFull:GetModel(cModFilho):Goline(nQtdFilho)	
									aadd(aDadoMod[nQtdMod,3,nQtdPai,2,nQtdFilho,3], {aClone(aFilho[nIF,3]:aDataModel[nYF,1,1] ), {} })		
								
	
									//-----------------------------------------------------------------
									//	NIVEL 3 - Verifica se Grid possui tabelas NETO relacionadas
									//-----------------------------------------------------------------
									IF LEN(aFilho[1,4]) > 0
									
										aNeto	:=  aClone(aFilho[1,4])
										aDadoN	:= {}
										
										nQtdNeto := 0
										FOR nIN := 1 TO LEN(aNeto)
										
											//| sOMENTE CARREGA O QUE PERMITE INSERIR LINHAS |
											IF IIF(aNeto[nIN,1]=="GRID", aNeto[nIN,3]:LINSERTLINE,.F.)
												
												
												
												//aDadoMod[nQtdMod,3,nQtdPai,2]	:= { "",{},{} }
												nQtdNeto++
												aadd(aDadoMod[nQtdMod,3,nQtdPai,2,nQtdFilho,3,nYF,2], { "",{},{} })
												
												//aadd(aDadoF, {"",{},{},{}} ) //Nome Model, Header, Dados, Filhos
												
												//aadd(aDadoF, { "",{},{ {},{} } } ) //{}Nome Model, Header, {Dados, Filhos}}
												cModFilho 	:= aNeto[nIN,2]
												aDadoMod[nQtdMod,3,nQtdPai,2,nQtdFilho,3,nYF,2,nQtdNeto,1]	:= cModFilho //Nome Model
												
												//| Carrega Header |
												FOR nXN := 1 to len(aNeto[nIN,3]:aHeader)		
													aadd(aDadoMod[nQtdMod,3,nQtdPai,2,nQtdFilho,3,nYF,2,nQtdNeto,2], aNeto[nIN,3]:aHeader[nXN,2] )		
												NEXT nXN
												
												//| Carrega Dados |
												FOR nXN := 1 TO len(aNeto[nIN,3]:aDataModel)	
													oModFull:GetModel(cModFilho):Goline(nQtdFilho)	
													aadd(aDadoMod[nQtdMod,3,nQtdPai,2,nQtdFilho,3,nYF,2,nQtdNeto,3], {aClone(aNeto[nIN,3]:aDataModel[nXN,1,1] ), {} })		
												NEXT nXN	
											ENDIF
												
										NEXT nIN
									ENDIF
	
	
								NEXT nYF	
							ENDIF
								
						NEXT nIF
					ENDIF				
					
					
				NEXT nQtdPai
			ENDIF
			
		ENDIF
			
	NEXT nI
	
	oModFull:DeActivate()
	
	
	FOR nFil := 1 to LEN(aFilCopy)
	
		cFilCopy		:= ALLTRIM(aFilCopy[nFil][2])
		cNomeCopy	:= ALLTRIM(aFilCopy[nFil][3])	
		
		
		RestArea(aAreaCN9)
		
		//------------------------------------------------------ Augusto Ribeiro | 09/10/2018 - 7:53:53 AM
		//	Verifica se o Contrato já existe na Filial posicionada
		//------------------------------------------------------------------------------------------
		DBSELECTAREA("CN9")
		CN9->(DBSETORDER(1)) //| 
		IF CN9->(DBSEEK(cFilCopy+CN9->CN9_NUMERO)) 
			cMsgErro	+= "Contrato já existente na filial ["+cFilCopy+"]"
			fGrvLog(2,"Contrato já existente na filial ["+cFilCopy+"]")
			LOOP
		ENDIF
		
		RestArea(aAreaCN9)
			
		
	
		//---------------------------------------
		//Realiza a TROCA DA FILIAL CORRENTE
		//-----------------------------------------
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= cFilCopy //| CODIGO DA FILIAL DE DESTINO
		
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF	
		
		cCnpjFil := SM0->M0_CGC
	
		oModFull := FWLoadModel("CNTA300")
		oModFull:SetOperation(3)
		oModFull:Activate()
		
		aModels		:= aMStruct[3]:aDataModel[2]
		
		oModel	:= oModFull:GetModel("CN9MASTER")
		oModCNB	:= oModFull:GetModel("CNBDETAIL")
		oModCNA	:= oModFull:GetModel("CNADETAIL")
		
		//----------------------------------------
		//	10/10/2018 - Jonatas Oliveira - Compila
		//	Realiza gravações adicionais 
		//------------------------------------------		
		oModel:SetValue("CN9_NUMERO"		, CN9->CN9_NUMERO	)
		oModel:LoadValue("CN9_INDICE"		, CN9->CN9_INDICE	)

		
		FOR nI := 1 to LEN(aCN9MASTER)
		
		
			IF aCN9MASTER[nI,1] == "CN9_NUMERO"
				//oModel:SetValue(aCN9MASTER[nI,1],)
			ELSE
				oModel:SetValue(aCN9MASTER[nI,1],aCN9MASTER[nI,2])
			ENDIF
		
		NEXT nI
				
		oModel:SetValue("CN9_VLINI"			, CN9->CN9_VLINI	)
		oModel:SetValue("CN9_VLATU"			, CN9->CN9_VLATU	)
		oModel:SetValue("CN9_SALDO"			, CN9->CN9_SALDO	)
		//
		nCN9_VLINI	:=	CN9->CN9_VLINI
		nCN9_VLATU	:=	CN9->CN9_VLATU
		nCN9_SALDO	:=	CN9->CN9_SALDO
		
		//| Modelo de Dados Pai|
		nCNASaldo:=0
		lEntrou:=.F.
		FOR nModPai := 1 to LEN(aDadoMod)
		
			oModel	:= oModFull:GetModel(aDadoMod[nModPai,1])
			
			//| Dados (linhas) do Modelo de dados Pai |
			FOR nDadosPai := 1 TO LEN(aDadoMod[nModPai,3])
			
				IF nDadosPai > 1
					oModel:lValid	:= .T.
					oModel:ADDLINE()
				ENDIF
		
				//| Campos do Header |
				FOR nCpoHeader := 1 TO LEN(aDadoMod[nModPai,2])
				
					IF !EMPTY(aDadoMod[nModPai,3,nDadosPai,1,nCpoHeader]) .AND. RIGHT(ALLTRIM(aDadoMod[nModPai,2,nCpoHeader]),7) <> "_FILIAL"
						lTeste	:= oModel:SetValue(aDadoMod[nModPai,2,nCpoHeader], aDadoMod[nModPai,3,nDadosPai,1,nCpoHeader])					
					ENDIF
					
					// hfp - Compila 20210818 e 19
					//       A pedido usuaria Naya, segundo ela, valor sempre esteve errado, 
				  	//			
					// IF ALLTRIM(aDadoMod[nModPai,2,nCpoHeader]) == "CNA_VLTOT"
					// IF oModel:GetValue("CNA_VLTOT") == 0 
					// oModel:SetValue("CNA_VLTOT"		, oModel:GetValue("CNA_SALDO")	)
					//	fGrvLog(2,"CNA_VLTOT " + str(oModel:GetValue("CNA_VLTOT")))
					//	ENDIF 
					//	ENDIF 

					IF ALLTRIM(aDadoMod[nModPai,2,nCpoHeader]) == "CNA_SALDO"
						nCNASaldo+= oModel:GetValue("CNA_SALDO")
						lEntrou:=.T.
					ENDIF

				NEXT nCpoHeader
				
				
				//--------------------------
				//	FILHO
				//---------------------------
				IF LEN(aDadoMod[nModPai,3,nDadosPai,2]) > 0
			
					aDadoMF	:= aDadoMod[nModPai,3,nDadosPai,2]
					
					FOR nModFilho := 1 to LEN(aDadoMF)
					
						oModelF	:= oModFull:GetModel(aDadoMF[nModFilho,1])
						
						FOR nDadoFilho := 1 TO LEN(aDadoMF[nModFilho,3])
						
							IF nDadoFilho > 1
								oModelF:lValid	:= .T.
								oModelF:ADDLINE()
							ENDIF

							//nota: CNB é a parte do itens planilha

							FOR nCpoFilho := 1 TO LEN(aDadoMF[nModFilho,2])
							
								IF !EMPTY(aDadoMF[nModFilho,3,nDadoFilho,1,nCpoFilho]) .AND. RIGHT(ALLTRIM(aDadoMF[nModFilho,2,nCpoFilho]),7) <> "_FILIAL"

									//incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20201228]
									//regra do Centro de Custo Base
									//quando a replica de contrato for entre grupo de empresa diferentes será realizada tratativa de compor 
									//o centro de custo com o CC Base mais a filial a quem esta sendo replicada
									If aDadoMF[ nModFilho, 2, nCpoFilho ] = "CNB_CC"
										//hfp - Solicitado Naia	- ja era assim antigo.				
										//aDadoMF[ nModFilho, 3, 1, 1, nCpoFilho ] := Substr( aDadoMF[ nModFilho, 3, 1, 1, nCpoFilho ], 1, 5 ) + cFilCopy
										aDadoMF[ nModFilho, 3, nDadoFilho, 1, nCpoFilho ] := Substr( aDadoMF[ nModFilho, 3, 1, 1, nCpoFilho ], 1, 5 ) + cFilCopy
									EndIf
									//fim bloco [Mauro Nagata, www.compila.com.br, 20201228]

									lTeste	:= oModelF:SetValue(aDadoMF[nModFilho,2,nCpoFilho], aDadoMF[nModFilho,3,nDadoFilho,1,nCpoFilho])								
								ENDIF
													
								//--------------------------
								//	Neto
								//---------------------------
								IF LEN(aDadoMF[nModFilho,3,nDadoFilho,2]) > 0
							
									aDadoNeto	:= aDadoMF[nModFilho,3,nDadoFilho,2]
									
									FOR nModNeto := 1 to LEN(aDadoNeto)
									
										oModelN	:= oModFull:GetModel(aDadoNeto[nModNeto,1])
										
										FOR nDadoNeto := 1 TO LEN(aDadoNeto[nModNeto,3])
										
											IF nDadoNeto > 1
												oModelN:lValid	:= .T.
												oModelN:ADDLINE()
											ENDIF
									
											
											FOR nCpoNeto := 1 TO LEN(aDadoNeto[nModNeto,2])
											
												IF !EMPTY(aDadoNeto[nModNeto,3,nDadoNeto,1,nCpoNeto]) .AND. RIGHT(ALLTRIM(aDadoNeto[nModNeto,2,nCpoNeto]),7) <> "_FILIAL"
													lTeste	:= oModelN:SetValue(aDadoNeto[nModNeto,2,nCpoNeto], aDadoNeto[nModNeto,3,nDadoNeto,1,nCpoNeto])
												ENDIF 
												
												
											NEXT nXF
						
										NEXT nDadoNeto			
									NEXT nModNeto
								ENDIF								
													
								
							NEXT nXF
		
						NEXT nDadoFilho			
					NEXT nModFilho
				ENDIF
				
			NEXT nDadosPai

			// hfp - Compila 20210819
			//			Incluido para ajustar o model, pois nao encontrado, mesmo apos varios debugs
		  	//			o que alterando o valor. 
			IF lEntrou  
				oModel:SetValue("CNA_SALDO"		, nCNASaldo	)


				//incluido 20211028 - hfp - Compila
				//no codigo mais acima, a Naya pediu para ajustar o total
				//validado.  Agora Kamila dizendo que errado.
				// vamos tratar por hora, se o total estiver zero, 
				// igualo ao saldo
				IF oModel:GetValue("CNA_VLTOT") == 0 
					oModel:SetValue("CNA_VLTOT"		, nCNASaldo	)
				ENDIF

				lEntrou:=.F.
			ENDIF
			
		
		NEXT nModPai
		
		nTotLen	:= oModCNB:Length()
		
		IF nTotLen > 0
			oModCNB:GoLine( 1 ) 
			nTotCna := 0 
			
			FOR nA := 1 TO nTotLen
				
				//aqui tb da pra mudar cnb
				oModCNB:GoLine( nA )

				//20211028 hfp - Compila 
				//contratos sem itens na planilha dando erro
				IF !EMPTY( oModCNB:GetValue("CNB_NUMERO") )

					//20211007 - hfp - Compila   (erro saldo itens)
					// incluido calculo para o saldo, pois
					// testes e nao identificado onde esta fazendo o calculo errado
					nXQuant := oModCNB:GetValue("CNB_QUANT")
					nXQMed  := oModCNB:GetValue("CNB_QTDMED")
					// oModCNB:GetValue("CNB_SLDMED")  para conferencia e verificacao erro
					nXNewSld:= nXQuant - nXQMed
					oModCNB:SetValue("CNB_SLDMED"		, nXNewSld	)
					// end 20211007
				
				ENDIF  //EMPTY CNB_NUMERO


				DBSELECTAREA("CTT")
				//CTT->(DBSETORDER(6))//|CTT_FILIAL+CTT_XEMPFI|
				CTT->(DbOrderNickName("CTTXEMPFI"))//|CTT_FILIAL+CTT_XEMPFI|
				
				IF CTT->(DBSEEK(cFilCopy + ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| x[1] == ALLTRIM(cFilCopy) })][2]))) .AND. !EMPTY(oModCNB:GetValue("CNB_CONTRA"))
					oModCNB:SetValue("CNB_CC"		, CTT->CTT_CUSTO	)
				ENDIF 
				
			Next nA
		ENDIF 
		
		
		nTotLen	:= oModCNA:Length()
		
		IF nTotLen > 0 
			oModCNA:GoLine( 1 ) 
			nTotCna := 0 
			FOR nA := 1 TO nTotLen
				oModCNA:GoLine( nA )
				
				IF !EMPTY(oModCNA:GetValue("CNA_CONTRA")) 

					// hfp - Compila 20210819
					//			Modificado solicitado por usuaria, que na replica saldo nao igual ao original
					//	IF oModCNA:GetValue("CNA_VLTOT") == 0 
					//	oModCNA:SetValue("CNA_VLTOT"		, oModCNA:GetValue("CNA_SALDO")	)
					// ENDIF 
					//	IF oModCNA:GetValue("CNA_SALDO") > oModCNA:GetValue("CNA_VLTOT")
					//	oModCNA:SetValue("CNA_SALDO"		, oModCNA:GetValue("CNA_VLTOT")	)
					//	ENDIF 

					nTotCna += oModCNA:GetValue("CNA_VLTOT")
					
				ENDIF 
			Next nA 
		ENDIF 
		
		oModCN9 := oModFull:GetModel("CN9MASTER")
		//		
		oModCN9:SetValue("CN9_VLATU"	, nCN9_VLATU	)
		oModCN9:SetValue("CN9_SALDO"	, nCN9_SALDO	)
		oModCN9:LoadValue("CN9_VLINI"	, nCN9_VLINI	)

		/*
		nCN9_VLINI	:=	CN9->CN9_VLINI
		nCN9_VLATU	:=	CN9->CN9_VLATU
		nCN9_SALDO	:=	CN9->CN9_SALDO
		*/

	oModCN9:LoadValue("CN9_FILCTR"			, XFILIAL("CN9")	)

	FWFormCommit(oModFull)
	oModFull:DeActivate()

	///*----------------------------------------
	//	09/10/2018 - Jonatas Oliveira - Compila
	//	Grava registros CNF- Cronograma Financeiro
	//	Struct da Tabela  //-- Desabilita inclusão e exclusão de linhas nos cronogramas
	//				      oModel:GetModel('CNFDETAIL'):SetNoInsertLine(.T.)
	//------------------------------------------*/

	CNF->(DBGOTOP())
	IF CNF->(DBSEEK(cChavCN9))
		WHILE CNF->(!EOF()) .AND. cChavCN9 == CNF->(CNF_FILIAL+CNF_CONTRA+CNF_REVISA)
			nRecCNF	:= CNF->(RECNO())
			nTotCpo	:= CNF->(FCount())

			RegToMemory("CNF",.T.)

			M->CNF_FILIAL 	:=  cFilCopy
			M->CNF_NUMERO	:=	CNF->CNF_NUMERO
			M->CNF_CONTRA  :=  CNF->CNF_CONTRA
			M->CNF_PARCEL  :=  CNF->CNF_PARCEL
			M->CNF_COMPET  :=  CNF->CNF_COMPET
			M->CNF_VLPREV	:=  CNF->CNF_VLPREV

			//hfp - Compila - 20210818 SOLCITADO PARA NAO VIR ZERO
			//M->CNF_VLREAL	:=  0
			M->CNF_VLREAL	:=  CNF->CNF_VLREAL

			//hfp - Compila - 20210818 SOLCITADO PARA NAO VIR ZERO
			M->CNF_SALDO 	:=  CNF->CNF_SALDO

			M->CNF_DTVENC	:=	CNF->CNF_DTVENC
			M->CNF_PRUMED  :=  CNF->CNF_PRUMED
			M->CNF_MAXPAR  :=  CNF->CNF_MAXPAR
			M->CNF_REVISA  :=  CNF->CNF_REVISA
			M->CNF_PERANT  :=  CNF->CNF_PERANT
			M->CNF_DTREAL  :=  CNF->CNF_DTREAL
			M->CNF_TXMOED  :=  CNF->CNF_TXMOED
			M->CNF_PERIOD	:=  CNF->CNF_PERIOD
			M->CNF_DIAPAR	:=  CNF->CNF_DIAPAR
			M->CNF_CONDPG  :=  CNF->CNF_CONDPG
			M->CNF_NUMPLA  :=  CNF->CNF_NUMPLA


			RECLOCK("CNF",.T.)

			For nI := 1 To nTotCpo
				FieldPut(nI, M->&(FIELDNAME(nI)) )
			Next nI

			MSUNLOCK()
			CONFIRMSX8()

			CNF->(DBSETORDER(2))
			CNF->(DBGOTO(nRecCNF))

			CNF->(DBSKIP())
		ENDDO
	ENDIF

	DBSELECTAREA("CNB")
	CNB->(DBSETORDER(1))
	CNB->(DBGOTOP())

	IF CNB->(DBSEEK(ALLTRIM(cFilCopy) + CN9->(CN9_NUMERO+CN9_REVISA)))
		//aqui tb manipular cnb ja gravado
		DBSELECTAREA("CTT")
		//CTT->(DBSETORDER(6))//|CTT_FILIAL+CTT_XEMPFI|
		CTT->(DbOrderNickName("CTTXEMPFI"))//|CTT_FILIAL+CTT_XEMPFI|
		IF CTT->(DBSEEK(cFilCopy + ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| x[1] == ALLTRIM(cFilCopy) })][2]))) //.AND. !EMPTY(oModCNB:GetValue("CNB_CONTRA"))
//				oModCNB:SetValue("CNB_CC"		, CTT->CTT_CUSTO	)
			CNB->(RecLock("CNB",.F.))
			CNB->CNB_CC	:= 		CTT->CTT_CUSTO
			CNB->(MsUnLock())
		ENDIF
	ENDIF


		/*----------------------------------------
			07/03/2019 - Jonatas Oliveira - Compila
			Grava Nome da Filial Autorizada 
		------------------------------------------*/
		DBSELECTAREA("CNA")		
		CNA->(DBSETORDER(1))//|CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO|
		IF CNA->(DBSEEK( XFILIAL("CNA") + CNB->( CNB_CONTRA + CNB_REVISA + CNB_NUMERO )))
		
			DBSELECTAREA("CPD")
			CPD->(DBSETORDER(1))//|CPD_FILIAL+CPD_CONTRA+CPD_NUMPLA+CPD_FILAUT|
			
			IF CPD->(DBSEEK(xfilial("CPD") + CNB->( CNB_CONTRA + CNB_NUMERO) ))
				IF EMPTY(CPD->CPD_FILAUT)
					CPD->(RecLock("CPD",.F.))
						CPD->CPD_FILAUT := CPD->CPD_FILIAL
					CPD->(MsUnLock())
				ENDIF 
			ENDIF 
		
		ENDIF
				
		fGrvLog(2,"Contrato "+ CN9->CN9_NUMERO + " replicado na filial : " + cFilCopy)
		
		RestArea(aAreaCN9)

		/*---------------------------------------
			Restaura FILIAL  
		-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF   			
		
	
	NEXT nFil
ELSE
	fGrvLog(2,"Nenhuma filial selecionada")
	
	aRet[2]	:= "Nenhuma filial selecionada"
ENDIF

fGrvLog(3,"Fim da Gravação . "+TIME()+". "+ DToC(ddatabase))

AVISO("CTA100CP","Replicação finalizada. Verifique o log de processamento.  ",{"Fechar"}, 3, ,, , .T.,  )

Return(aRet)



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Realiza a Criação, Gravacao, Apresentacao do Log de acordo com o Pametro passado ³
//³                                                                                  ³
//³ PARAMETRO	DESCRICAO                                                            ³
//³ _nOpc		Opcao:  1= Cria Arquivo de Log, 2= Grava Log, 3 = Apresenta Log      ³
//³ _cTxtLog	Log a ser gravado                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function fGrvLog(_nOpc, _cTxtLog)
Local _lRet	:= Nil
//hfp Local _nOpc
//hfp , _cTxtLog
Local _EOL	:= chr(13)+chr(10)

Default _nOpc		:= 0
Default _cTxtLog 	:= ""
_cTxtLog += _EOL
Do Case
	Case _nOpc == 1
		_cFileLog	 	:= Criatrab(,.F.)
		_cLogPath		:= AllTrim(GetTempPath())+_cFileLog+".txt"
		_Handle			:= FCREATE(_cLogPath,0)	//| Arquivo de Log
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		
	Case _nOpc == 2
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		
	Case _nOpc == 3
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		FCLOSE(_Handle)
		WINEXEC("NOTEPAD "+_cLogPath)
EndCase

Return(_lRet)

/*/{Protheus.doc} RetSM0
Retorna Array com Dados das Empresas
@author Jonatas Oliveira | www.compila.com.br
@since 10/10/2018
@version 1.0
/*/
Static Function RetSM0()
	Local aRet	:= {}	
	Local aArea		:= GetArea()
	Local aAreaSM0	:= SM0->(GetArea())
	
	DBSELECTAREA("SM0")
	SM0->(DBSETORDER(1))
	SM0->(DBGOTOP())
	
	WHILE SM0->(!EOF())
		AADD(aRet,{ALLTRIM(SM0->M0_CODFIL), ALLTRIM(SM0->M0_CGC), ALLTRIM(SM0->M0_NOME) })
		SM0->(DBSKIP())
	ENDDO
	
	RestArea(aAreaSM0)
	RestArea(aArea)
Return(aRet)	
	
