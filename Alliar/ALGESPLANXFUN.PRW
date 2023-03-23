#INCLUDE 'protheus.ch'
#INCLUDE 'parmtype.ch'
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.Ch"
#Include "rwmake.Ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"  



#DEFINE D_TOPQUERY 100 //| Top Retorna registros da Query |


// 0=Pendente;1=CashPosting;2=FinancialOpenness;3=AccountingOpenness;4=Deletado
#DEFINE D_XSTGES_PENDENTE 		"0"
#DEFINE D_XSTGES_CASH			"1"
#DEFINE D_XSTGES_FINANCIAL		"2"
#DEFINE D_XSTGES_ACCOUNTING		"3"


//| Beneficiary

#DEFINE XCODGES_CLIENT		1
#DEFINE XCODGES_EMPLOYEE	2
#DEFINE XCODGES_PROVIDER	3
#DEFINE XCODGES_ATTORNEY	4
#DEFINE XCODGES_PARTINER	5
#DEFINE XCODGES_OTHERS		6


//| Motivos que serãodesconsiderados das movimentações.

/*
AP - Aplicação Financeira
BA - Baixa Automática ou Baixa que não tenha movimentação bancária
BD - Borderô em cobrança descontada
BL - Baixa Aplicação Longo Prazo
C2 - Correção Monetária na cobrança descontada
CB - Cancelamento Bordero em Cobrança Descontada
CD - Cheque Pré-Datado
CH - Cheque
CM - Correção Monetária
CP - Compensação
CX - Movimentação do Caixa
D2 - Desconto na cobrança descontada
DB - Despesas Bancárias
DC - Desconto
DV - Devolução - Sigaloja
EP - Empréstimo
ES - Estorno de movimentação
IB - Impostos Bancários
J2 - Juro na cobrança descontada
JR - Juro
LJ - Entrada Dinheiro pelo Caixa - SIGALOJA
M2 - Multa na cobrança descontada
MT - Multa
NCC- Nota de Crédito Cliente
NDF- Nota de Débito Fornecedor
PA - Pagamento Antecipado
PE - Pagamento Empréstimo
RA - Recebimento Antecipado
RF - Resgate de Aplicação Financeira
R$ - Entrada em dinheiro - SIGALOJA
SG - Sangria do Caixa - SIGALOJA
TC - Entrada de Troco - SIGALOJA
TE - Transferência Estornada
TL - Valor de Tolerância Recebido sobre o título
TR - Transferência
VL - Movimentação Bancária ou Baixas que movimentem banco
V2 - Movimentação Bancária na Cobrança Descontada
*/

#DEFINE X_TIPODOC "('J2','JR','M2','MT','D2','DC')"





User Function ALTST02()
	Local cRetJsn	:=  ""
	Local nValSe2	:= 0 
	
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "00101MG0001"
	
	
	cRetJsn	:= U_ALGPCASH(3)
	cRetJsn	:= cRetJsn
	
//	cRetJsn	:=  U_ALGPINTE()
//	AVISO("CashPosting","/*CashPosting*/" + U_ALGPINTE(1),{"Fechar"},3, "",,,.T.)
	//AVISO("CashPosting","/*CashPosting*/" + U_ALGPCASH(2) ,{"Fechar"},3, "",,,.T.)
//	AVISO("FinancialOpenness","/*FinancialOpenness*/" + U_ALGPFCP(),{"Fechar"},3, "",,,.T.)
//	AVISO("AccountingOpenness","/*AccountingOpenness*/" + U_ALGPINTE(3),{"Fechar"},3, "",,,.T.)

//	DBSELECTAREA("SE2")
//	SE2->(DBSETORDER(1))
//	SE2->(DBGOTO(440001))
//	
//	nValSe2 := U_alSaldTit("SE2")
//	
//	cRetJsn := '"value":"' + Alltrim(Transform(nValSe2,"@E 999999999.99")) + '"'
//	
//	alert(cRetJsn)
	RESET ENVIRONMENT
	
Return()

User Function ALTST03(cFilCopy)

	Local cFilCode	:= ""

	Local aEmpSm0 	:= RetSM0()
	Local cCnpjF	:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| ALLTRIM(x[1]) == ALLTRIM(cFilCopy) })][2])
	Local cFilCode 	:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| LEFT(x[2],12) == LEFT(Alltrim(cCnpjF) ,8) + "0001" })][1])

//	cFilCode := aEmpSm0[aScan(aEmpSm0	, {|x| LEFT(x[2],12) == LEFT(cFilCopy ,8) + "0001" })][1]
	alert("Filial: " + ALLTRIM(cFilCopy) )
	Alert("CGC1 " + cCnpjF )
	Alert("CGC2 " + cFilCode )
//	u_ALTST03("00301RJ0002")
Return(cFilCode)


/*/{Protheus.doc} ALGPINTE
Rotina responsável por retornar o Json de todas as integrações
@author Fabio Sales
@since 18/08/2018
@param nOpc , N,1 = CashPosting(Contas a Receber e pagar)
				2 = FinancialOpenness(Contas a Receber e pagar)
				3 = AccountingOpenness(Contas a Receber e pagar)
@Return String
@version 1.0
/*/


User Function ALGPINTE(nOpc)


	Local cJson		:= ""
	Local cJsonCP	:= "" 
	Local cJsonCR	:= "" 
	Local cJsonBC	:= ""
	
	Private aEmpSm0 	:= RetSM0()
	 
	Default nOpc		:= 1
	
	//cJson += '{"items": ['
	
	/*--------------------------------------------------\
	|Habilita controle de transação para garantir que não| 
	|haverá atualização caso ocorra algum erro.         |
	\--------------------------------------------------*/
	
	//BEGIN TRANSACTION
		
		IF nOpc == 1 //| CashPosting
		 	
			cJsonCR		+= U_ALGPCASH(1) //| Contas a Receber		
			cJsonCP 	+= U_ALGPCASH(2) //| Contas a pagar
			cJsonBC 	+= U_ALGPCASH(3) //| Movimento Bancario
			
		ELSEIF nOpc == 2 //| FinancialOpenness
		
			cJsonCR		+= U_ALGPFCR() //| Contas a Receber		
			cJsonCP 	+= U_ALGPFCP() //| Contas a pagar
			cJsonBC 	+= U_ALGPFBC() //| Movimentação bancária.
				
		ELSEIF nOpc == 3 //| AccountingOpenness
		
			cJsonCR		+= U_ALGPAOCR() //| Contas a Receber		
			cJsonCP 	+= U_ALGPAOCP() //| Contas a pagar
			cJsonBC 	+= U_ALGPAOBC() //| Movimento Bancario
			
		ELSE
			
			cJson := '{"items": []}'
			Return(cJson)
			
		ENDIF
		
		cJson += cJsonCR
		
		IF !EMPTY(cJsonCR) .AND. !EMPTY(cJsonCP)
		
			cJson += ","
			
		ENDIF
		
		cJson += cJsonCP
		
		IF (!EMPTY(cJsonCR) .OR. !EMPTY(cJsonCP)) .AND. !EMPTY(cJsonBC)
		
			cJson += ","
			
		ENDIF
		
		cJson += cJsonBC
		
			
	//END TRANSACTION
	
	//cJson += ']}'
	
	
	IF !EMPTY(cJson)
		
		cJson := '{"items": ['+cJson+']}'
	ENDIF


Return(cJson)


/*/{Protheus.doc} IntCR001
Monta Json dos títulos incluidos no sistema.
@author Fabio Sales
@since 18/08/2018
@param nOpc , N , Opção 1= Contas a receber| 2=Contas a pagar.
@Return String
@version 1.0
/*/

User Function ALGPCASH(nOpc)

	Local cRetJson	:= ""
	Local cFilCode	:= ""
	Local cCnpjF	:= ""
	Local cChave, cDtAux, cDocTit
	
	Private dtCorte	:= dtos(GETMV("AL_DTFIGSP",.F.,STOD("20181208")))
	Private nTopQry	:= GETMV("AL_GSPTOPQ",.F.,D_TOPQUERY)
	
	Default nOpc	:= 1 //| CONTAS A RECEBER
	
	IF nOpc == 1 //| Contas a receber.
	
		QryCPostCR() //| Consulta Titulos no contas a receber pendentes de envio no CashPosting
		
	ELSEIF nOpc == 2 //| Contas a Pagar.
	
		QryCPostCP() //| Consulta Titulos no contas a pagar pendentes de envio no CashPosting
		
	ELSEIF nOpc == 3 //| Movimentacao Bancaria
	
		QryMovBC(1) //Retorna query cashposting
	
	ENDIF
	
	DBSELECTAREA("SM0")
	
	
	//|cRetJson += '{"items": ['
	
	
	/*-------------------------------------------------\
	|Inicia a transação para garanti que as alterações |
	| Seja efetuada somente após a montagem do Json.   |
	\-------------------------------------------------*/
	
	//|BEGIN TRANSACTION
		
		
		
		/*--------------------------
			 CONTAS A RECEBER
		---------------------------*/		
		IF nOpc == 1
		 
			IF CRFIN->(!EOF())
						
				//| Alimenta o Array do Jason.
							
				WHILE CRFIN->(!EOF()) 
				
					DBSELECTAREA("SE1")
			 		SE1->(DBGOTO(CRFIN->RECSE1))
			 		IF SE1->(RecLock("SE1",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
			 			CRFIN->(DBSKIP())
			 			LOOP
			 		ENDIF
			 		

					cChave	:= CRFIN->E1_FILIAL + "|" + CRFIN->E1_PREFIXO + "|" +CRFIN->E1_NUM + "|" + CRFIN->E1_PARCELA  + "|" + CRFIN->E1_TIPO + "|" + CRFIN->E1_CLIENTE + "|" + CRFIN->E1_LOJA
					cDtAux	:= LEFT(CRFIN->DATA,4) + '/' + SUBSTR(CRFIN->DATA,5,2) + '/' + RIGHT(CRFIN->DATA,2)
		 			cCnpjF		:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| ALLTRIM(x[1]) == ALLTRIM(SE1->E1_FILIAL) })][2])
		 			//cFilCode 	:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| LEFT(x[2],12) == LEFT(Alltrim(cCnpjF) ,8) + "0001" })][1])
		 			
		 			cFilCode	:= CRFIN->E1_FILIAL
		 			
		 			DBSELECTAREA("SZK")
		 			SZK->(DBSETORDER(1)) //| 
		 			IF SZK->(DBSEEK(SM0->M0_CODIGO+CRFIN->E1_FILIAL)) 
		 				IF !EMPTY(SZK->ZK_XFILMAT)
		 					cFilCode	:= SZK->ZK_XFILMAT
		 				ENDIF
		 			ENDIF
		 			
			 		
					cRetJson += '{'									
					cRetJson += '"externalCode":"' + Alltrim(cChave) + '",'		
					cRetJson += '"businessUnit":"' + Alltrim(cFilCode)  + '",'
					cRetJson += '"originSystem":"CR",'
					cRetJson += '"dateOfIssue":"' + Alltrim(cDtAux) + '",'
					cRetJson += '"description":"' + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + '",'
					cRetJson += '"documentType":"' + Alltrim(CRFIN->TIPO) + '",'
					cRetJson += '"documentNumber":"' + Alltrim(CRFIN->DOC) + '",'
					
					IF !EMPTY(SE1->E1_HIST)
						cRetJson += '"observation":"' + ALLTRIM(RemovChar(SE1->E1_HIST)) + '",'
					ELSE					
						cRetJson += '"observation":"",'
					ENDIF 
							
					cRetJson += '"currency":"BRL",'
					
					IF CRFIN->EXCLUIDO == "SIM" .AND. SE1->( Deleted() )  .AND. !EMPTY(SE1->E1_XSTCAS)
						cRetJson += '"integrationType":"e",'
					ENDIF					
					
					cRetJson += '"flexField002":"' + Alltrim(CRFIN->FILIAL)  + '",'
					
					cRetJson += '"flexField003":"'+alltrim(str(CRFIN->RECSE1))+ '"'
					 
			 		cRetJson += '}'
			 		
			 		
			 		//| Atualiza o status da integração.
			 		
			 		
			 		IF CRFIN->EXCLUIDO == "SIM" .AND. SE1->( Deleted() )  .AND. !EMPTY(SE1->E1_XSTCAS)
			 			SE1->E1_XSTCAS := "2" 			 			
			 		ELSE
			 			SE1->E1_XSTCAS := "1"  //| 0=Pendente;1=Integrado;2=Excluido
			 			
			 			IF EMPTY(SE1->E1_XSTFIN)
			 				SE1->E1_XSTFIN	:= '0'
			 			ENDIF 	
			 			
			 			IF EMPTY(SE1->E1_XSTACC)
			 				SE1->E1_XSTACC	:= '0'
			 			ENDIF 
			 		ENDIF	 		           
			 		                                       
			 		SE1->E1_XDTGPLA := DDATABASE
			 		
			 		SE1->(MsUnLock())
			 		
			 		//| Vai para o próximo registro.
			 				 		
			 		CRFIN->(DBSKIP())
			 		
			 		IF CRFIN->(!EOF())
			 			
			 			cRetJson += ','
			 		
			 		ENDIF		 			 	
					
				ENDDO
						
				//| Fecha a tabela caso a mesma esteja aberta.				
				//AVISO("CashPosting",cRetJson,{"Fechar"},3, "",,,.T.)

				
				IF SELECT("CPFIN") > 0
		
					CRFIN->(DbCloseArea())
				
				ENDIF
									
			ENDIF
	
		/*--------------------------
			CONTAS A PAGAR
		---------------------------*/			
		ELSEIF nOpc == 2		
			
			IF CPFIN->(!EOF())
														
				//| Alimenta o Array do Jason.
							
				WHILE CPFIN->(!EOF()) 
					
					DBSELECTAREA("SE2")
			 		SE2->(DBGOTO(CPFIN->RECSE2))
			 		if SE2->(RecLock("SE2",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
						CPFIN->(DBSKIP())
						LOOP
					ENDIF
			 		
			 		cCnpjF		:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| ALLTRIM(x[1]) == ALLTRIM(SE2->E2_FILIAL) })][2])
		 			//cFilCode 	:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| LEFT(x[2],12) == LEFT(Alltrim(cCnpjF) ,8) + "0001" })][1])
					cChave		:= CPFIN->E2_FILIAL + "|" + CPFIN->E2_PREFIXO + "|" + CPFIN->E2_NUM + "|" + CPFIN->E2_PARCELA + "|" + CPFIN->E2_TIPO + "|" + CPFIN->E2_FORNECE + "|" + CPFIN->E2_LOJA
					cDtAux		:= LEFT(CPFIN->DATA,4) + '/' + SUBSTR(CPFIN->DATA,5,2) + '/' + RIGHT(CPFIN->DATA,2)
					cDocTit		:= CPFIN->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
					
		 			cFilCode	:= CPFIN->E2_FILIAL
		 			DBSELECTAREA("SZK")
		 			SZK->(DBSETORDER(1)) //| 
		 			IF SZK->(DBSEEK(SM0->M0_CODIGO+CPFIN->E2_FILIAL))
		 				IF !EMPTY(SZK->ZK_XFILMAT) 
		 					cFilCode	:= SZK->ZK_XFILMAT
		 				ENDIF		 				
		 			ENDIF					
					
					cRetJson += '{'			
					cRetJson += '"externalCode":"' + Alltrim(cChave) + '",'				
					cRetJson += '"businessUnit":"' +  Alltrim(cFilCode)  + '",'
					cRetJson += '"originSystem":"CP",'
					cRetJson += '"dateOfIssue":"' + Alltrim(cDtAux) + '",'
					cRetJson += '"description":"' + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + '",'
					cRetJson += '"documentType":"' + Alltrim(CPFIN->TIPO) + '",'
					cRetJson += '"documentNumber":"' + Alltrim(cDocTit) + '",'
					
					IF !EMPTY(SE2->E2_HIST)
						cRetJson += '"observation":"' + ALLTRIM(RemovChar(SE2->E2_HIST)) + '",'
					ELSE					
						cRetJson += '"observation":"",'
					ENDIF 
					
					
					/*----------------------------------------
						26/03/2019 - Jonatas Oliveira - Compila
						Tratativa para evitar a integração de 
						Titulo em processo de inclusão
					------------------------------------------*/					
					IF CPFIN->EXCLUIDO == "SIM" .AND. SE2->( Deleted() ) .AND. !EMPTY(SE2->E2_XSTCAS)
						cRetJson += '"integrationType":"e",'
					ENDIF 
					
//					IF CPFIN->EXCLUIDO == "SIM" .AND. SE2->( Deleted() ) 
//						IF !EMPTY(SE2->E2_XSTCAS) .AND. ALLTRIM(SE2->E2_FORNECE) == "MUNIC"
//							cRetJson += '"integrationType":"e",'							
//						ELSEIF ALLTRIM(SE2->E2_FORNECE) != "MUNIC"
//							cRetJson += '"integrationType":"e",'
//						ENDIF 
//					ENDIF	
								
					cRetJson += '"currency":"BRL",'
					cRetJson += '"flexField002":"' + Alltrim(CPFIN->FILIAL)  + '",'
					cRetJson += '"flexField003":"'+alltrim(str(CPFIN->RECSE2))+ '"'
					
					 
			 		cRetJson += '}'
			 					 		
			 		//| Atualiza o status da integração.
			 		
			 		
			 		
			 		
			 		
			 		//SE2->E2_XSTCAS := "1"  //| 0=Pendente;1=Integrado;2=Excluido|
			 		IF CPFIN->EXCLUIDO == "SIM" .AND. SE2->( Deleted() ) .AND. !EMPTY(SE2->E2_XSTCAS)
			 			SE2->E2_XSTCAS := "2" 
			 		ELSE
			 			SE2->E2_XSTCAS := "1"  //| 0=Pendente;1=Integrado;2=Excluido
			 			
			 			IF EMPTY(SE2->E2_XSTFIN)
			 				SE2->E2_XSTFIN	:= '0'
			 			ENDIF 	
			 			
			 			IF EMPTY(SE2->E2_XSTACC)
			 				SE2->E2_XSTACC	:= '0'
			 			ENDIF
			 		ENDIF			 		
			 				 		                                                  
			 		SE2->E2_XDTGPLA := DDATABASE
			 		
			 		SE2->(MsUnLock())
			 		
			 		//| Vai para o próximo registro.
			 				 		
			 		CPFIN->(DBSKIP())
			 		
			 		IF CPFIN->(!EOF())
			 			cRetJson += ','
			 		ENDIF		 			 	
					
				ENDDO
				
				//| Fecha a tabela caso a mesma esteja aberta.
			
				IF SELECT("CPFIN") > 0
		
					CPFIN->(DbCloseArea())
				
				ENDIF		
					
			ENDIF
			
			
		/*--------------------------
			MOVIMENTACAO BANCARIA
		---------------------------*/
		ELSEIF nOpc == 3
		
		
		
		
			IF BCSE5->(!EOF())
														
				//| Alimenta o Array do Jason.
							
				WHILE BCSE5->(!EOF()) 
					
					DBSELECTAREA("SE5")
			 		SE5->(DBGOTO(BCSE5->RECSE5))
			 		IF SE5->(RecLock("SE5",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
						BCSE5->(DBSKIP())
						LOOP
					ENDIF
			 		
			 		
			 		cCnpjF		:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| ALLTRIM(x[1]) == ALLTRIM(SE5->E5_FILIAL) })][2])
					cChave		:= alltrim(str(BCSE5->RECSE5))
					cDtAux		:= DTOS(SE5->E5_DATA)
					cDtAux		:= LEFT(cDtAux,4) + '/' + SUBSTR(cDtAux,5,2) + '/' + RIGHT(cDtAux,2)
					cDocTit		:= cChave //CPFIN->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
					
		 			cFilCode	:= SE5->E5_FILIAL
		 			DBSELECTAREA("SZK")
		 			SZK->(DBSETORDER(1)) //| 
		 			IF SZK->(DBSEEK(SM0->M0_CODIGO+SE5->E5_FILIAL))
		 				IF !EMPTY(SZK->ZK_XFILMAT) 
		 					cFilCode	:= SZK->ZK_XFILMAT
		 				ENDIF		 				
		 			ENDIF					
					
					cRetJson += '{'			
					cRetJson += '"externalCode":"' + Alltrim(cChave) + '",'				
					cRetJson += '"businessUnit":"' +  Alltrim(cFilCode)  + '",'
					cRetJson += '"originSystem":"'+IIF(SE5->E5_RECPAG=="R","CR","CP")+'",'
					cRetJson += '"dateOfIssue":"' + Alltrim(cDtAux) + '",'
					cRetJson += '"description":"' + cChave +'",' //SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + '",'
					IF EMPTY(SE5->E5_TIPODOC)
						cRetJson += '"documentType":"TB",'
					ELSE
						cRetJson += '"documentType":"' + Alltrim(SE5->E5_TIPODOC) + '",'
					ENDIF
					cRetJson += '"documentNumber":"' + Alltrim(cDocTit) + '",'
					
					IF !EMPTY(SE5->E5_HISTOR)
						cRetJson += '"observation":"' + ALLTRIM(RemovChar(SE5->E5_HISTOR)) + '",'
					ELSE					
						cRetJson += '"observation":"",'
					ENDIF 
					
					
					/*----------------------------------------
						26/03/2019 - Jonatas Oliveira - Compila
						Tratativa para evitar a integração de 
						Titulo em processo de inclusão
					------------------------------------------*/					
					IF BCSE5->EXCLUIDO == "SIM" .AND. SE5->( Deleted() ) .AND. !EMPTY(SE5->E5_XSTCAS)
						cRetJson += '"integrationType":"e",'
					ENDIF 

								
					cRetJson += '"currency":"BRL",'
					cRetJson += '"flexField002":"' + Alltrim(SE5->E5_FILIAL)  + '",'
					cRetJson += '"flexField003":"'+alltrim(str(BCSE5->RECSE5))+ '"'					
					
			 		cRetJson += '}'
			 					 		
			 		//| Atualiza o status da integração.
			 		
			 		
			 		
			 		
			 		
			 		//SE2->E2_XSTCAS := "1"  //| 0=Pendente;1=Integrado;2=Excluido|
			 		IF BCSE5->EXCLUIDO == "SIM" .AND. SE5->( Deleted() ) .AND. !EMPTY(SE5->E5_XSTCAS)
			 			SE5->E5_XSTCAS := "2" 
			 		ELSE
			 			SE5->E5_XSTCAS := "1"  //| 0=Pendente;1=Integrado;2=Excluido
			 			
			 		ENDIF			 		
			 				 		                                                  
			 		SE5->E5_XDTGPLA := DDATABASE
			 		
			 		SE5->(MsUnLock())
			 		
			 		//| Vai para o próximo registro.
			 				 		
			 		BCSE5->(DBSKIP())
			 		
			 		IF BCSE5->(!EOF())
			 			cRetJson += ','
			 		ENDIF		 			 	
					
				ENDDO
				
				//| Fecha a tabela caso a mesma esteja aberta.
			
				IF SELECT("BCSE5") > 0
		
					BCSE5->(DbCloseArea())
				
				ENDIF		
					
			ENDIF		

		ENDIF
		
		//|cRetJson += ']}'
	
	//|END TRANSACTION	

Return(cRetJson)





/*/{Protheus.doc} IntCR002
** FinancialOpenness **
Monta Json dos títulos alterados e que
já tenha sido integrado o CashPosting com a Gesplan
@author Fabio Sales
@since 18/08/2018
@Return String
@version 1.0
/*/

//User Function IntCR002()
User Function ALGPFCR()

	Local cRetJson	:= ""  
	Local cRetBlock	:= ""
	Local cFilCode	:= ""
	Local cCnpjF	:= ""
	Local cChave	:= ""
	Local cVENCREA	:= ""
	Local cDTBX		:= ""
	Local cCONTAG	:= ""
	Local aMotBx	:= u_zMotBaixa()  
	Local _cMotBx 	:= ""
	Local nPosMt	:= 0 
	
	Private dtCorte	:= dtos(GETMV("AL_DTFIGSP",.F.,STOD("20181208")))
	Private nTopQry	:= GETMV("AL_GSPTOPQ",.F.,D_TOPQUERY)		
	
	QryMovCR() //| Movimentação financeira.
		
	//|BEGIN TRANSACTION
	
	//|	cRetJson += '{"items": ['
		
		
		IF CRSE5->(!EOF())
		
			//| Alimenta o Array do Jason.
						
			WHILE CRSE5->(!EOF()) 
			
				DBSELECTAREA("SE1")
				DBGOTO(CRSE5->RECSE1)
		 		IF SE1->(RECLOCK("SE1",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
					CRSE5->(DBSKIP())
					LOOP
				ENDIF		
				
				
				
				
				nSaldo	:= 0

	 			cCnpjF		:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| ALLTRIM(x[1]) == ALLTRIM(SE1->E1_FILIAL) })][2])
//	 			cFilCode 	:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| LEFT(x[2],12) == LEFT(Alltrim(cCnpjF) ,8) + "0001" })][1])	

	 			cFilCode	:= CRSE5->E1_FILIAL
	 			DBSELECTAREA("SZK")
	 			SZK->(DBSETORDER(1)) //| 
	 			IF SZK->(DBSEEK(SM0->M0_CODIGO+CRSE5->E1_FILIAL)) 
	 				IF !EMPTY(SZK->ZK_XFILMAT)
	 					cFilCode	:= SZK->ZK_XFILMAT
	 				ENDIF
	 			ENDIF			 

				cChave		:= CRSE5->E1_FILIAL + "|" + CRSE5->E1_PREFIXO + "|" + CRSE5->E1_NUM + "|" + CRSE5->E1_PARCELA + "|" + CRSE5->E1_TIPO + "|" + CRSE5->E1_CLIENTE + "|" + CRSE5->E1_LOJA
				cVENCREA	:= LEFT(CRSE5->DATA,4) + '/' + SUBSTR(CRSE5->DATA,5,2) + '/' + RIGHT(CRSE5->DATA,2)
				cDTBX		:= LEFT(CRSE5->DTBX,4) + '/' + SUBSTR(CRSE5->DTBX,5,2) + '/' + RIGHT(CRSE5->DTBX,2)

				cRetJson += '{'	
				cRetJson += '"externalCode":"' + Alltrim(cChave) +  '",'				
//				IF CRSE5->EXCSE1 == "SIM"
//					cRetJson += '"cashPosting":"' + Alltrim(cChave) + '",'				
//					cRetJson += '"integrationType":"e"'				
//				ELSE
					cRetJson += '"cashPosting":"' + Alltrim(cChave) + '",'				
					cRetJson += '"dueDate":"' + Alltrim(cVENCREA) + '",'
					cRetJson += '"eventType": "E",'
					cRetJson += '"currentAccount":"999999' + ALLTRIM(cFilCode) + '",'
					cRetJson += '"beneficiary":"' + CRSE5->CLI+CRSE5->LOJ + '",'
					cRetJson += '"beneficiaryType": "1",
					cRetJson += '"beneficiaryOrigin": "1",'
					cRetJson += '"payday": "",'
					cRetJson += '"motionWay":"' + Alltrim(CRSE5->FORMPG) + '",'	
					cRetJson += '"paymentNumber":"' + Alltrim(STRTRAN(cChave,"|", "")) + '",'
					
					IF CRSE5->EXCSE1 == "SIM" .AND. SE1->( Deleted() ) 
						cRetJson += '"integrationType":"e",'	
						nSaldo	:= 0
					ELSE
						IF ALLTRIM(SE1->E1_TIPO) == "RA"
					 		nSaldo := 0 
					 	ELSE
					 		nSaldo	:=	U_alSaldTit()
						ENDIF 
					ENDIF
					
					/* 
					IF CRSE5->EXCSE1 <> "SIM" 				 	
					 	IF ALLTRIM(SE1->E1_TIPO) == "RA"
					 		nSaldo := 0 
					 	ELSE
					 		nSaldo	:=	U_alSaldTit()
						ENDIF 
					ELSE
						cRetJson += '"integrationType":"e",'	
						nSaldo	:= 0
					ENDIF
					*/
					//|cRetJson += '"value":"' + Alltrim(Transform(CRSE5->SALDO,"@E 999999999.99")) + '",'
					
					cRetJson += '"value":"' + Alltrim(Transform(nSaldo,"@E 999999999.99")) + '",'
					
					//|cRetJson += '"valueBusiness": "",
					//|cRetJson += '"conversionBusiness": "",'
					//|cRetJson += '"fixedRateBusiness": "",'
					//|cRetJson += '"valueAccount": "",'
					//|cRetJson += '"conversionAccount": "",'
					//|cRetJson += '"fixedRateAccount": ""'
					 
					cRetJson += '"flexField002":"' + Alltrim(SE1->E1_FILIAL)  + '",'
					
					cRetJson += '"flexField005":' + Alltrim(Transform(SE1->E1_JUROS,"@R 999999999.99"))  + ','
					cRetJson += '"flexField006":' + Alltrim(Transform(SE1->E1_MULTA,"@R 999999999.99"))  + ','
					cRetJson += '"flexField007":' + Alltrim(Transform(SE1->E1_ACRESC,"@R 999999999.99"))  + ','
					cRetJson += '"flexField008":' + Alltrim(Transform(SE1->E1_MDDESC,"@R 999999999.99"))  + ','
					cRetJson += '"flexField009":' + Alltrim(Transform(SE1->E1_DECRESC,"@R 999999999.99")) + ','
					cRetJson += '"flexField014":"'+alltrim(str(CRSE5->RECSE1))+ '"'
					
			 	//ENDIF
		 		cRetJson += '}'
		 		
		 			 		
 				//| Atualização do Status na SE1
		 			
		 		//IF CRSE5->EXCSE1 <> "SIM"
		 		

			 		IF CRSE5->EXCSE1 == "SIM"
			 			SE1->E1_XSTFIN := "2"  //| 0=Pendente;1=Integrado;2=Excluido
			 		ELSE
			 			SE1->E1_XSTFIN := "1"  //| 0=Pendente;1=Integrado;2=Excluido
			 			
			 			/*------------------------------------------------------ Augusto Ribeiro | 09/05/2019 - 2:56:16 PM
			 				Quando envio de Finnacial ocorre para um titulo anterior a data de corte
			 				força o envio do Cash e Acount caso estejam com o status vazio.
			 			------------------------------------------------------------------------------------------*/
			 			IF SE1->E1_EMISSAO < STOD(dtCorte)
			 				IF EMPTY(SE1->E1_XSTCAS)
			 					SE1->E1_XSTCAS := "0" 
			 				ENDIF
			 				IF EMPTY(SE1->E1_XSTACC)
			 					SE1->E1_XSTACC := "0" 
			 				ENDIF			 				
			 			ENDIF
			 		ENDIF	 		                                                  
			 		SE1->E1_XDTGPLA := DDATABASE
			 		
			 		SE1->(MsUnLock())
//			 		
//			 	ELSE
//			 					
//			 		cUpd := "UPDATE " + RetSqlName("SE1") + " SET E1_XSTFIN = '2', E1_XDTGPLA= '" + dtos(ddatabase) + "' WHERE D_E_L_E_T_= '*' AND R_E_C_N_O_ = " + ALLTRIM(STR(CRSE5->RECSE1)) + " "
//			 		TCSqlExec(cUpd)
//			 		
//			 	ENDIF
		 		
		 		
		 		clChv	:= Alltrim(STRTRAN(cChave,"|", ""))
		 		
		 		IF  CRSE5->RECSE5 > 0 //| Verifica se existe movimentação bancária para o título corrente.
		 			
		 			cRetJson += ','
		 			
			 		WHILE CRSE5->(!EOF()) .AND. clChv == Alltrim(CRSE5->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
			 		
			 			DBSELECTAREA("SE5")
					 	DBGOTO(CRSE5->RECSE5)
					 	if SE5->(RECLOCK("SE5",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
							CRSE5->(DBSKIP())
							LOOP
						ENDIF
					 	
						_cMotBx := ""
						nPosMt	:= aScan(aMotBx,{|x| x[1] == ALLTRIM(SE5->E5_MOTBX)})
						
						IF !EMPTY(SE5->E5_MOTBX) .AND. LEN(aMotBx) > 0 .and. nPosMt > 0 
							_cMotBx := aMotBx[nPosMt][2]
						ENDIF 					 	
					 	
						IF !EMPTY(CRSE5->A6_COD)
							cCONTAG	:= RTRIM(CRSE5->A6_COD) + RTRIM(CRSE5->A6_AGENCIA) + RTRIM(CRSE5->A6_DVAGE) + RTRIM(CRSE5->A6_NUMCON) + RTRIM(CRSE5->A6_DVCTA)
						ELSE
							cCONTAG	:= RTRIM(CRSE5->E5_BANCO) + RTRIM(CRSE5->E5_CONTA) + RTRIM(CRSE5->E5_AGENCIA)
						ENDIF		
						
						cVENCREA	:= LEFT(CRSE5->DATA,4) + '/' + SUBSTR(CRSE5->DATA,5,2) + '/' + RIGHT(CRSE5->DATA,2)
						cDTBX		:= LEFT(CRSE5->DTBX,4) + '/' + SUBSTR(CRSE5->DTBX,5,2) + '/' + RIGHT(CRSE5->DTBX,2)
									 	
					 	
					 	cCnpjF		:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| ALLTRIM(x[1]) == ALLTRIM(SE5->E5_FILIAL) })][2])
					 	cFilCode 	:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| LEFT(x[2],12) == LEFT(Alltrim(cCnpjF) ,8) + "0001" })][1])	
			 		
						cRetJson += '{'
						cRetJson += '"externalCode":"'  + Alltrim(STR(CRSE5->RECSE5)) + '",'		
						cRetJson += '"cashPosting":"' + Alltrim(cChave) + '",'
						cRetJson += '"dueDate":"' + Alltrim(cVENCREA) + '",'
						cRetJson += '"eventType": "E",'
						
						IF !EMPTY(cCONTAG)
							cRetJson += '"currentAccount":"' + Alltrim(cCONTAG) + '",'
						ELSE
							cRetJson += '"currentAccount":"' + Alltrim(CRSE5->FILIAL) + '",'
						ENDIF
						
						cRetJson += '"beneficiary":"' + CRSE5->CLI + CRSE5->LOJ + '",'
						cRetJson += '"beneficiaryType": "1",
						cRetJson += '"beneficiaryOrigin": "1",'
						cRetJson += '"payday":"' + Alltrim(cDTBX) + '",'
						cRetJson += '"motionWay":"' + Alltrim(CRSE5->FORMPG) + '",'													
						cRetJson += '"paymentNumber":"' + Alltrim(STR(CRSE5->RECSE5)) + '",'
						cRetJson += '"value":"' + Alltrim(Transform(CRSE5->VALOR,"@E 999999999.99")) + '",'
						
						//|cRetJson += '"valueBusiness": "",
						//|cRetJson += '"conversionBusiness": "",'
						//|cRetJson += '"fixedRateBusiness": "",'
						//|cRetJson += '"valueAccount": "",'
						//|cRetJson += '"conversionAccount": "",'
						//|cRetJson += '"fixedRateAccount": ""'
						
						IF CRSE5->EXCSE5 == "SIM"
							cRetJson += '"integrationType":"e",'
						ENDIF
						
						
						cRetJson += '"flexField002":"' + Alltrim(SE5->E5_FILIAL)  + '",'
						
						cRetJson += '"flexField005":' + Alltrim(Transform(SE5->E5_VLJUROS,"@R 999999999.99"))  + ','
						cRetJson += '"flexField006":' + Alltrim(Transform(SE5->E5_VLMULTA,"@R 999999999.99"))  + ','
						cRetJson += '"flexField007":' + Alltrim(Transform(SE5->E5_VLACRES,"@R 999999999.99"))  + ','
						cRetJson += '"flexField008":' + Alltrim(Transform(SE5->E5_VLDESCO,"@R 999999999.99"))  + ','
						cRetJson += '"flexField009":' + Alltrim(Transform(SE5->E5_VLDECRE,"@R 999999999.99"))  + ','
						cRetJson += '"flexField010":' + Alltrim(Transform(SE5->E5_VLCORRE,"@R 999999999.99"))  + ','
						cRetJson += '"flexField011":"' + Alltrim(SE5->E5_MOTBX) + ' - ' + Alltrim(_cMotBx)  + '",'
 				
						cRetJson += '"flexField014":"'+alltrim(str(CRSE5->RECSE5))+ '"'
						 
				 		cRetJson += '}'
				 					 							 		
				 		//| Atualiza status na SE5
				 		
				 		//IF CRSE5->EXCSE5 <> "SIM"
				 		
				 			
					 		
					 		IF CRSE5->EXCSE5 == "SIM"
					 			SE5->E5_XSTFIN := "2"  //| 0=Pendente;1=Integrado;2=Excluido
					 		ELSE
					 			SE5->E5_XSTFIN := "1"  //| 0=Pendente;1=Integrado;2=Excluido
					 		ENDIF					 		
					 		 		 		                                                  
					 		SE5->E5_XDTGPLA := DDATABASE
					 		
					 		SE5->(MsUnLock())
//					 		
//					 	ELSE
//					 					
//					 		cUpd := "UPDATE " + RetSqlName("SE5") + " SET E5_XSTACC = '1', E5_XDTGPLA= '" + dtos(ddatabase) + "' WHERE D_E_L_E_T_= '*' AND R_E_C_N_O_ = " + ALLTRIM(STR(CRSE5->RECSE5)) + " "
//					 		
//					 		TCSqlExec(cUpd)
//					 		
//					 	ENDIF
				 		
			 		
				 		CRSE5->(DBSKIP())
				 		
				 		IF CRSE5->(!EOF())
				 			
				 			cRetJson += ','
				 		
				 		ENDIF 
				 		
			 		ENDDO
			 		
			 	ELSE
			 		
		 			CRSE5->(DBSKIP())
			 		
			 		IF CRSE5->(!EOF())
			 			
			 			cRetJson += ','
			 		
			 		ENDIF 
			 		
			 	ENDIF
				
			ENDDO				
			
			//| Fecha a tabela caso a mesma esteja aberta.
			
			IF SELECT("CRSE5") > 0
	
				CRSE5->(DbCloseArea())
			
			ENDIF	
			
		ENDIF	
		
	//|	cRetJson += ']}'
		
	//|END TRANSACTION
	
Return(cRetJson)


/*/{Protheus.doc} ALGPFCP
** FinancialOpenness ** Contas a Pagar
Monta Json dos títulos alterados e que
já tenha sido integrado o CashPosting com a Gesplan
@author Fabio Sales
@since 18/08/2018
@Return String
@version 1.0
/*/
User Function ALGPFCP()

	Local cRetJson	:= ""
	Local cFilCode	:= ""
	Local cCnpjF	:= ""
	Local cChave	:= ""
	Local cVENCREA	:= ""
	Local cDTBX		:= ""
	Local cCONTAG	:= ""	
	Local aMotBx	:= u_zMotBaixa()  
	Local _cMotBx 	:= ""
	Local nPosMt	:= 0
	Private dtCorte	:= dtos(GETMV("AL_DTFIGSP",.F.,STOD("20181208")))
	Private nTopQry	:= GETMV("AL_GSPTOPQ",.F.,D_TOPQUERY)		 	

		
	QryMovCP() //| Movimentação financeira.
		
	//|BEGIN TRANSACTION
	
	//|	cRetJson += '{"items": ['
		
		
		IF CPSE5->(!EOF())
		
			//| Alimenta o Array do Jason.
						
			WHILE CPSE5->(!EOF()) 
				
				nSaldo	:= 0
				
				DBSELECTAREA("SE2")
				DBGOTO(CPSE5->RECSE2)
		 		IF SE2->(RECLOCK("SE2",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
					CPSE5->(DBSKIP())
					LOOP
				ENDIF			
				
				cCnpjF		:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| ALLTRIM(x[1]) == ALLTRIM(SE2->E2_FILIAL) })][2])
//				cFilCode 	:= ALLTRIM(aEmpSm0[aScan(aEmpSm0	, {|x| LEFT(x[2],12) == LEFT(Alltrim(cCnpjF) ,8) + "0001" })][1])
				
				cChave		:= CPSE5->E2_FILIAL + "|" + CPSE5->E2_PREFIXO + "|" + CPSE5->E2_NUM + "|" + CPSE5->E2_PARCELA + "|" + CPSE5->E2_TIPO + "|" + CPSE5->E2_FORNECE + "|" + CPSE5->E2_LOJA
				cVENCREA	:= LEFT(CPSE5->DATA,4) + '/' + SUBSTR(CPSE5->DATA,5,2) + '/' + RIGHT(CPSE5->DATA,2)
				cDTBX		:= LEFT(CPSE5->DTBX,4) + '/' + SUBSTR(CPSE5->DTBX,5,2) + '/' + RIGHT(CPSE5->DTBX,2)
				
				cFilCode	:= CPSE5->E2_FILIAL
				
	 			DBSELECTAREA("SZK")
	 			SZK->(DBSETORDER(1)) //| 
	 			
	 			IF SZK->(DBSEEK(SM0->M0_CODIGO+CPSE5->E2_FILIAL)) 
	 				IF !EMPTY(SZK->ZK_XFILMAT)
	 					cFilCode	:= SZK->ZK_XFILMAT
	 				ENDIF
	 			ENDIF	
				 
				cRetJson += '{'	

				cRetJson += '"externalCode":"' + Alltrim(cChave) + '",'	
				cRetJson += '"cashPosting":"' + Alltrim(cChave) + '",'
				cRetJson += '"dueDate":"' + Alltrim(cVENCREA) + '",'
				cRetJson += '"eventType": "S",'
				cRetJson += '"currentAccount":"999999' + Alltrim(cFilCode) + '",'
				cRetJson += '"beneficiary":"' + CPSE5->FORN + CPSE5->LOJ + '",'
				cRetJson += '"beneficiaryType": "1",
				cRetJson += '"beneficiaryOrigin": "1",'
				cRetJson += '"payday": "",'
				cRetJson += '"motionWay":"' + Alltrim(CPSE5->FORMPG)  + '",'
				cRetJson += '"paymentNumber":"' + Alltrim(STRTRAN(cChave,"|", "")) + '",'
				
				IF CPSE5->EXCSE2 == "SIM" .AND. SE2->( Deleted() )
					cRetJson += '"integrationType":"e",'
				ELSE									
				 	IF ALLTRIM(SE2->E2_TIPO) == "PA"
				 		nSaldo := 0 
				 	ELSE
				 		nSaldo	:= U_alSaldTit("SE2")
				 	ENDIF 
				ENDIF
				
				//|cRetJson += '"value":"' + Alltrim(Transform(CRSE5->SALDO,"@E 999999999.99")) + '",'
				
				cRetJson += '"value":"' + Alltrim(Transform(nSaldo,"@E 999999999.99")) + '",'
				
				//|cRetJson += '"valueBusiness": "",
				//|cRetJson += '"conversionBusiness": "",'
				//|cRetJson += '"fixedRateBusiness": "",'
				//|cRetJson += '"valueAccount": "",'
				//|cRetJson += '"conversionAccount": "",'
				//|cRetJson += '"fixedRateAccount": ""'
				
				cRetJson += '"flexField002":"' + Alltrim(SE2->E2_FILIAL)  + '",'
				
				cRetJson += '"flexField005":' + Alltrim(Transform(SE2->E2_JUROS,"@R 999999999.99"))  + ','
				cRetJson += '"flexField006":' + Alltrim(Transform(SE2->E2_MULTA,"@R 999999999.99"))  + ','
				cRetJson += '"flexField007":' + Alltrim(Transform(SE2->E2_ACRESC,"@R 999999999.99"))  + ','
				cRetJson += '"flexField008":' + Alltrim(Transform(SE2->E2_MDDESC,"@R 999999999.99"))  + ','
				cRetJson += '"flexField009":' + Alltrim(Transform(SE2->E2_DECRESC,"@R 999999999.99")) + ',' 				
				cRetJson += '"flexField014":"'+alltrim(str(CPSE5->RECSE2))+ '"'
		 		cRetJson += '}'
		 		
		 			 		
 				//| Atualização do Status na SE2
	 			DBSELECTAREA("SE2")

		 		
		 		//SE2->E2_XSTFIN := "1"  //|0=Pendente;1=Integrado;2=Excluido
		 		IF CPSE5->EXCSE2 == "SIM"
		 			SE2->E2_XSTFIN := "2" 
		 		ELSE
		 			SE2->E2_XSTFIN := "1"  //| 0=Pendente;1=Integrado;2=Excluido
		 			
		 			/*------------------------------------------------------ Augusto Ribeiro | 09/05/2019 - 2:56:16 PM
		 				Quando envio de Finnacial ocorre para um titulo anterior a data de corte
		 				força o envio do Cash e Acount caso estejam com o status vazio.
		 			------------------------------------------------------------------------------------------*/
		 			IF SE2->E2_EMISSAO < STOD(dtCorte)
		 				IF EMPTY(SE2->E2_XSTCAS)
		 					SE2->E2_XSTCAS := "0" 
		 				ENDIF
		 				IF EMPTY(SE2->E2_XSTACC)
		 					SE2->E2_XSTACC := "0" 
		 				ENDIF			 				
		 			ENDIF		 			
		 		ENDIF	 			 		
		 		 		 		                                                  
		 		SE2->E2_XDTGPLA := DDATABASE
		 		
		 		SE2->(MsUnLock())
			
		 		
		 		
		 		clChv	:= Alltrim(STRTRAN(cChave,"|", ""))
		 		
		 		IF  CPSE5->RECSE5 > 0 //| Verifica se existe movimentação bancária para o título corrente.
		 			
		 			cRetJson += ','
		 			
			 		WHILE CPSE5->(!EOF()) .AND. clChv == Alltrim(CPSE5->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA))
			 		
			 			DBSELECTAREA("SE5")
					 	DBGOTO(CPSE5->RECSE5)					 		
				 		IF SE5->(RECLOCK("SE5",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
							CPSE5->(DBSKIP())
							LOOP
						ENDIF			 	
					 	
						_cMotBx := ""
						nPosMt	:= aScan(aMotBx,{|x| x[1] == ALLTRIM(SE5->E5_MOTBX)})
						
						IF !EMPTY(SE5->E5_MOTBX) .AND. LEN(aMotBx) > 0 .and. nPosMt > 0 
							_cMotBx :=  aMotBx[nPosMt][2]
						ENDIF 					 		 		
			 		
			 		
						cVENCREA	:= LEFT(CPSE5->DATA,4) + '/' + SUBSTR(CPSE5->DATA,5,2) + '/' + RIGHT(CPSE5->DATA,2)
						cDTBX		:= LEFT(CPSE5->DTBX,4) + '/' + SUBSTR(CPSE5->DTBX,5,2) + '/' + RIGHT(CPSE5->DTBX,2)
			 		
						IF !EMPTY(CPSE5->A6_COD)
							cCONTAG	:= RTRIM(CPSE5->A6_COD) + RTRIM(CPSE5->A6_AGENCIA) + RTRIM(CPSE5->A6_DVAGE) + RTRIM(CPSE5->A6_NUMCON) + RTRIM(CPSE5->A6_DVCTA)
						ELSE
							cCONTAG	:= RTRIM(CPSE5->E5_BANCO) + RTRIM(CPSE5->E5_CONTA) + RTRIM(CPSE5->E5_AGENCIA)
						ENDIF				 		
			 		
			 		
						cRetJson += '{'
								
						cRetJson += '"externalCode":"' + Alltrim(STR(CPSE5->RECSE5)) + '",'
						cRetJson += '"cashPosting":"' + Alltrim(cChave) + '",'
						cRetJson += '"dueDate":"' + Alltrim(cVENCREA) + '",'
						cRetJson += '"eventType": "S",'
						
						IF !EMPTY(cCONTAG)
							cRetJson += '"currentAccount":"' + Alltrim(cCONTAG) + '",'
						ELSE
							cRetJson += '"currentAccount":"' + Alltrim(CPSE5->FILIAL) + '",'
						ENDIF
						
						cRetJson += '"beneficiary":"' + CPSE5->FORN + CPSE5->LOJ + '",'
						cRetJson += '"beneficiaryType": "1",
						cRetJson += '"beneficiaryOrigin": "1",'
						cRetJson += '"payday":"' + Alltrim(cDTBX) + '",'
						cRetJson += '"motionWay":"' + Alltrim(CPSE5->FORMPG)  + '",'
						cRetJson += '"paymentNumber":"' + Alltrim(STR(CPSE5->RECSE5)) + '",'						
						IF CPSE5->EXCSE5 == "SIM"
							cRetJson += '"integrationType":"e",'
						ENDIF
						cRetJson += '"value":"' + Alltrim(Transform(CPSE5->VALOR,"@E 999999999.99")) + '",'
						
						
						cRetJson += '"flexField002":"' + Alltrim(SE5->E5_FILIAL)  + '",'						
						cRetJson += '"flexField005":' + Alltrim(Transform(SE5->E5_VLJUROS,"@R 999999999.99"))  + ','
						cRetJson += '"flexField006":' + Alltrim(Transform(SE5->E5_VLMULTA,"@R 999999999.99"))  + ','
						cRetJson += '"flexField007":' + Alltrim(Transform(SE5->E5_VLACRES,"@R 999999999.99"))  + ','
						cRetJson += '"flexField008":' + Alltrim(Transform(SE5->E5_VLDESCO,"@R 999999999.99"))  + ','
						cRetJson += '"flexField009":' + Alltrim(Transform(SE5->E5_VLDECRE,"@R 999999999.99"))  + ','
						cRetJson += '"flexField010":' + Alltrim(Transform(SE5->E5_VLCORRE,"@R 999999999.99"))  + ','
						cRetJson += '"flexField011":"' + Alltrim(SE5->E5_MOTBX) + ' - ' + Alltrim(_cMotBx)  + '",'							
						cRetJson += '"flexField014":"'+alltrim(str(CPSE5->RECSE5))+ '"'
						//|cRetJson += '"valueBusiness": "",
						//|cRetJson += '"conversionBusiness": "",'
						//|cRetJson += '"fixedRateBusiness": "",'
						//|cRetJson += '"valueAccount": "",'
						//|cRetJson += '"conversionAccount": "",'
						//|cRetJson += '"fixedRateAccount": ""'
						 
				 		cRetJson += '}'
				 					 							 		
				 		//| Atualiza status na SE5
				 		
				 		
				 		
			 			DBSELECTAREA("SE5")

				 		
				 		//SE5->E5_XSTFIN := "1"  //|0=Pendente;1=Integrado;2=Excluido
				 		IF CPSE5->EXCSE5 == "SIM"
				 			SE5->E5_XSTFIN := "2" 
				 		ELSE
				 			SE5->E5_XSTFIN := "1"  //| 0=Pendente;1=Integrado;2=Excluido
				 		ENDIF	 				 			                                                  
				 		SE5->E5_XDTGPLA := DDATABASE
				 		
				 		SE5->(MsUnLock())
					 
			 		
				 		CPSE5->(DBSKIP())
				 		
				 		IF CPSE5->(!EOF())
				 			
				 			cRetJson += ','
				 		
				 		ENDIF 
				 		
			 		ENDDO
			 		
			 	ELSE
			 		
		 			CPSE5->(DBSKIP())
			 		
			 		IF CPSE5->(!EOF())
			 			
			 			cRetJson += ','
			 		
			 		ENDIF 
			 		
			 	ENDIF
				
			ENDDO				
			
			//| Fecha a tabela caso a mesma esteja aberta.
			
			IF SELECT("CPSE5") > 0
	
				CPSE5->(DbCloseArea())
			
			ENDIF	
			
		ENDIF	
		
	//|	cRetJson += ']}'
		
	//|END TRANSACTION
	
Return(cRetJson)



/*/{Protheus.doc} ALGPFBC
Monta Json da movimentação Bancária.
@author Fabio Sales
@since 30/09/2018
@Return String
@version 1.0
/*/

User Function ALGPFBC()

	Local cRetJson	:= ""
	LOCAL AllMotBx	:= {} 
	Local aMotBx	:= u_zMotBaixa()  
	Local _cMotBx 	:= ""
	Local nPosMt	:= 0 
	Private dtCorte	:= dtos(GETMV("AL_DTFIGSP",.F.,STOD("20181208")))
	Private nTopQry	:= GETMV("AL_GSPTOPQ",.F.,D_TOPQUERY)		
	
	QryMovBC(2) //| Movimentação Bancária - Financial
		
	
	IF BCSE5->(!EOF())
	
		//| Alimenta o Array do Jason.
	
 		WHILE BCSE5->(!EOF()) 
 			
 			
 			DBSELECTAREA("SE5")
	 		DBGOTO(BCSE5->RECSE5) 		
	 		IF SE5->(RECLOCK("SE5",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
				BCSE5->(DBSKIP())
				LOOP
			ENDIF 		
			
			_cMotBx := ""
			nPosMt	:= aScan(aMotBx,{|x| x[1] == ALLTRIM(SE5->E5_MOTBX)})
			
			IF !EMPTY(SE5->E5_MOTBX) .AND. LEN(aMotBx) > 0 .and. nPosMt > 0 
				_cMotBx :=  aMotBx[nPosMt][2]
			ENDIF 
			
			cRetJson += '{'
					
			cRetJson += '"externalCode":"' + Alltrim(STR(BCSE5->RECSE5)) + '",'
			cRetJson += '"cashPosting":"' + Alltrim(STR(BCSE5->RECSE5)) + '",' //Alltrim(BCSE5->CHAVE) + '",'
			cRetJson += '"dueDate":"' + Alltrim(BCSE5->DTBX) + '",'
			
			IF BCSE5->TIPOREC=="R"
				cRetJson += '"eventType": "E",'
			ELSE
				cRetJson += '"eventType": "S",'
			ENDIF
			
			IF !EMPTY(BCSE5->CONTAG)
				cRetJson += '"currentAccount":"' + Alltrim(BCSE5->CONTAG) + '",'
			ELSE
				cRetJson += '"currentAccount":"' + Alltrim(BCSE5->FILIAL) + '",'
			ENDIF
			
			cRetJson += '"beneficiary":"",'
			cRetJson += '"beneficiaryType": "1",
			cRetJson += '"beneficiaryOrigin": "1",'
			cRetJson += '"payday":"' + Alltrim(BCSE5->DTBX) + '",'
			cRetJson += '"motionWay":"",'		
			cRetJson += '"paymentNumber":"' + Alltrim(STR(BCSE5->RECSE5)) + '",'
			cRetJson += '"value":"' + Alltrim(Transform(BCSE5->VALOR,"@E 999999999.99")) + '",'
			
			cRetJson += '"flexField005":' + Alltrim(Transform(SE5->E5_VLJUROS,"@R 999999999.99"))  + ','
			cRetJson += '"flexField006":' + Alltrim(Transform(SE5->E5_VLMULTA,"@R 999999999.99"))  + ','
			cRetJson += '"flexField007":' + Alltrim(Transform(SE5->E5_VLACRES,"@R 999999999.99"))  + ','
			cRetJson += '"flexField008":' + Alltrim(Transform(SE5->E5_VLDESCO,"@R 999999999.99"))  + ','
			cRetJson += '"flexField009":' + Alltrim(Transform(SE5->E5_VLDECRE,"@R 999999999.99"))  + ','
			cRetJson += '"flexField010":' + Alltrim(Transform(SE5->E5_VLCORRE,"@R 999999999.99"))  + ','
			cRetJson += '"flexField011":"' + Alltrim(SE5->E5_MOTBX) + ' - ' + Alltrim(_cMotBx)  + '",'			 
			cRetJson += '"flexField014":"'+alltrim(str(BCSE5->RECSE5))+ '"'
	 		cRetJson += '}'
	 					 							 		
	 		//| Atualiza status na SE5

	 		
 			DBSELECTAREA("SE5")

	 		
	 		SE5->E5_XSTFIN := "1"  //|0=Pendente;1=Integrado;2=Excluido	 		                                                  
	 		SE5->E5_XDTGPLA := DDATABASE
	 		
	 		SE5->(MsUnLock())

	 		BCSE5->(DBSKIP())
	 		
	 		IF BCSE5->(!EOF())
	 			
	 			cRetJson += ','
	 		
	 		ENDIF 
	 		
 		ENDDO
		 				
		
		//| Fecha a tabela caso a mesma esteja aberta.
		
		IF SELECT("BCSE5") > 0

			BCSE5->(DbCloseArea())
		
		ENDIF	
		
	ENDIF	

	
Return(cRetJson)



/*/{Protheus.doc} ALGPAOCR
Monta Json dos títulos do contas a receber para a integração do AccountingOpenness
@author Fabio Sales
@since 10/09/2018
@Return String
@version 1.0
/*/


User Function ALGPAOCR()

	Local cRetJson	:= ""
	
	Private dtCorte	:= dtos(GETMV("AL_DTFIGSP",.F.,STOD("20181208")))
	Private nTopQry	:= GETMV("AL_GSPTOPQ",.F.,D_TOPQUERY)

	QryAcOpCR() //| Consulta Titulos no contas a receber pendentes de envio no AccountingOpenness
	
	//|cRetJson += '{"items": ['

	/*-------------------------------------------------\
	|Inicia a transação para garanti que as alterações |
	| Seja efetuada somente após a montagem do Json.   |
	\-------------------------------------------------*/
	
	//|BEGIN TRANSACTION
		 
		IF ACCOP->(!EOF())
					
			//| Alimenta o Array do Jason.
						
			WHILE ACCOP->(!EOF()) 
		 		DBSELECTAREA("SE1")
		 		DBGOTO(ACCOP->RECSE1)
		 		
		 		IF SE1->(RecLock("SE1",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
					ACCOP->(DBSKIP())
					LOOP
				ENDIF		
			
				cRetJson += '{'	
				
				cRetJson += '"externalCode":"' + Alltrim(ACCOP->CHAVE) + '",'
				cRetJson += '"cashPosting":"' + Alltrim(ACCOP->CHAVE) + '",'	
				cRetJson += '"eventType": "E",
				cRetJson += '"accountingAccount":"1102010001",'				
				cRetJson += '"accountingAccountPlan": "1",
				cRetJson += '"costCenter":"' + Alltrim(ACCOP->CCUSTO) + '",'
				cRetJson += '"costCenterPlan": "1",'						
				cRetJson += '"value":"' + Alltrim(Transform(ACCOP->VALOR,"@E 999999999.99")) + '",'
				cRetJson += '"flexField001":"' + Alltrim(ACCOP->NATUREZ) + '",'
				cRetJson += '"flexField002":"'+alltrim(str(ACCOP->RECSE1))+ '"'								 
		 		cRetJson += '}'
		 		
		 		
		 		//| Atualiza o status da integração.
		 		

		 		
		 		SE1->E1_XSTACC := "1"  //|0=Pendente;1=CashPosting;2=FinancialOpenness;3=AccountingOpenness;4=Deletado  		 		                                                  
		 		SE1->E1_XDTGPLA := DDATABASE
		 		
		 		SE1->(MsUnLock())
		 		
		 		//| Vai para o próximo registro.
		 				 		
		 		ACCOP->(DBSKIP())
		 		
		 		IF ACCOP->(!EOF())
		 			
		 			cRetJson += ','
		 		
		 		ENDIF		 			 	
				
			ENDDO
					
			//| Fecha a tabela caso a mesma esteja aberta.
		
			IF SELECT("ACCOP") > 0
	
				ACCOP->(DbCloseArea())
			
			ENDIF
								
		ENDIF
		
		//|cRetJson += ']}'
	
	//|END TRANSACTION	

Return(cRetJson)




/*/{Protheus.doc} ALGPAOCP
Monta Json dos títulos do contas a pagar para a integração do AccountingOpenness
@author Fabio Sales
@since 10/09/2018
@Return String
@version 1.0
/*/


User Function ALGPAOCP()

	Local cRetJson	:= ""
	Private dtCorte	:= dtos(GETMV("AL_DTFIGSP",.F.,STOD("20181208")))
	Private nTopQry	:= GETMV("AL_GSPTOPQ",.F.,D_TOPQUERY)		

	QryAcOpCP() //| Consulta Titulos no contas a receber pendentes de envio no AccountingOpenness
	
	//|cRetJson += '{"items": ['

	/*-------------------------------------------------\
	|Inicia a transação para garanti que as alterações |
	| Seja efetuada somente após a montagem do Json.   |
	\-------------------------------------------------*/
	
	//|BEGIN TRANSACTION
		 
		IF ACCOP->(!EOF())
					
			//| Alimenta o Array do Jason.
						
			WHILE ACCOP->(!EOF()) 
			
		 		DBSELECTAREA("SE2")
		 		DBGOTO(ACCOP->RECSE2)
		 		
		 		IF SE2->(RecLock("SE2",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
					ACCOP->(DBSKIP())
					LOOP
				ENDIF			
			
				cRetJson += '{'	
				
				cRetJson += '"externalCode":"' + Alltrim(ACCOP->CHAVE) + '",'
				cRetJson += '"cashPosting":"' + Alltrim(ACCOP->CHAVE) + '",'	
				cRetJson += '"eventType": "S",'
				cRetJson += '"accountingAccount":"2101010001",'
				cRetJson += '"accountingAccountPlan": "1",
				cRetJson += '"costCenter":"' + Alltrim(ACCOP->CCUSTO) + '",'				
				cRetJson += '"costCenterPlan": "1",'			
				cRetJson += '"value":"' + Alltrim(Transform(ACCOP->VALOR,"@E 999999999.99")) + '",'
				cRetJson += '"flexField001":"' + Alltrim(ACCOP->NATUREZ) + '",'
				cRetJson += '"flexField002":"'+alltrim(str(ACCOP->RECSE2))+ '"'								 
		 		cRetJson += '}'
		 		
		 		
		 		//| Atualiza o status da integração.
		 		

		 		
		 		SE2->E2_XSTACC := "1"  //|0=Pendente;1=Integrado;2=Excluido	                                                  
		 		SE2->E2_XDTGPLA := DDATABASE
		 		
		 		SE2->(MsUnLock())
		 		
		 		//| Vai para o próximo registro.
		 				 		
		 		ACCOP->(DBSKIP())
		 		
		 		IF ACCOP->(!EOF())
		 			
		 			cRetJson += ','
		 		
		 		ENDIF		 			 	
				
			ENDDO
					
			//| Fecha a tabela caso a mesma esteja aberta.
		
			IF SELECT("ACCOP") > 0
	
				ACCOP->(DbCloseArea())
			
			ENDIF
								
		ENDIF
		
		//|cRetJson += ']}'
	
	//|END TRANSACTION	

Return(cRetJson)




/*/{Protheus.doc} ALGPAOBC
Monta Json dos títulos do movimento bancário para a integração do AccountingOpenness
@author Fabio Sales
@since 10/09/2018
@Return String
@version 1.0
/*/

User Function ALGPAOBC()

Local cRetJson	:= ""
Local cEvType, cAccount
Private dtCorte	:= dtos(GETMV("AL_DTFIGSP",.F.,STOD("20181208")))
Private nTopQry	:= GETMV("AL_GSPTOPQ",.F.,D_TOPQUERY)		

DBSELECTAREA("SE5")

QryMovBC(3)	 //| Consulta Titulos no contas a receber pendentes de envio no AccountingOpenness


 		
IF BCSE5->(!EOF())
			
	//| Alimenta o Array do Jason.
				
	WHILE BCSE5->(!EOF()) 
	
		//| posiciona no registro SE5|
		DBSELECTAREA("SE5") 		
		SE5->(DBGOTO(BCSE5->RECSE5)) 		
 		IF SE5->(RecLock("SE5",.F.,,.F.,.T.)) == .F. //| Verifica se o LOCK foi realizado com Sucesso |
			BCSE5->(DBSKIP())
			LOOP
		ENDIF	
		
		IF SE5->E5_RECPAG=="R"
			cEvType		:= "E"
			cAccount	:= "1102010001"
		ELSE
			cEvType		:= "S"
			cAccount	:= "2101010001"
		ENDIF
	
		cRetJson += '{'	
		
		cRetJson += '"externalCode":"' + Alltrim(STR(BCSE5->RECSE5)) + '",'
		cRetJson += '"cashPosting":"' + Alltrim(STR(BCSE5->RECSE5))+ '",'	
		cRetJson += '"eventType":"'+cEvType+'",'		
		cRetJson += '"accountingAccount":"'+cAccount+'",' 
		cRetJson += '"accountingAccountPlan": "1",
		cRetJson += '"costCenter":"' + Alltrim(SE5->E5_CCUSTO) + '",'				
		cRetJson += '"costCenterPlan": "1",'			
		cRetJson += '"value":"' + Alltrim(Transform(SE5->E5_VALOR,"@E 999999999.99")) + '",'
		cRetJson += '"flexField001":"' + Alltrim(SE5->E5_NATUREZ) + '",'
		cRetJson += '"flexField002":"'+alltrim(str(BCSE5->RECSE5))+ '"'						 
 		cRetJson += '}'
 		
 		
 		//| Atualiza o status da integração.
 		
 		

 		
 		SE5->E5_XSTACC := "1"  //|0=Pendente;1=Integrado;2=Excluido	                                                  
 		SE5->E5_XDTGPLA := DDATABASE
 		
 		SE5->(MsUnLock())
 		 		
 		
 		//| Vai para o próximo registro.
 				 		
 		BCSE5->(DBSKIP())
 		
 		IF BCSE5->(!EOF())
 			cRetJson += ','
 		ENDIF		
	ENDDO
			
	//| Fecha a tabela caso a mesma esteja aberta.
	IF SELECT("BCSE5") > 0
		BCSE5->(DbCloseArea())
	ENDIF
						
ENDIF

//|cRetJson += ']}'


Return(cRetJson)


/*/{Protheus.doc} QryCashPos
Consulta os títulos que estão pendentes de envio no CashPost
no contas a receber.
@author Fabio Sales
@since 18/08/2018
@Return String
@version 1.0
/*/

STATIC FUNCTION QryCPostCR(cOper)

	Local cQry	:= ""
	Default cOper:= "0" 
		
	cQry := " SELECT "+CRLF
	/*------------------------------------------------------------------
		Limita o numero de movimentos a sere retornados no JSON
	-------------------------------------------------------------------*/
	IF !EMPTY(nTopQry)
		cQry += " TOP "+ALLTRIM(STR(nTopQry))+" "
	ENDIF
	//cQry += "	(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA ) CHAVE "+CRLF
	cQry += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA 
	cQry += "	,E1_FILIAL FILIAL "+CRLF
	//cQry += "	,LEFT(E1_EMISSAO,4) + '/' + SUBSTRING(E1_EMISSAO,5,2) + '/' + RIGHT(E1_EMISSAO,2) DATA "+CRLF
	cQry += "	,E1_EMISSAO DATA "+CRLF
	cQry += "	,E1_TIPO TIPO "+CRLF
	cQry += "	,E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO DOC "+CRLF
	cQry += "	,E1_CLIENTE CLI "+CRLF
	cQry += "	,E1_LOJA LOJ "+CRLF
	cQry += "	,E1_SALDO SALDO"+CRLF
	cQry += "	,CASE WHEN SE1.D_E_L_E_T_='*' THEN 'SIM' ELSE 'NAO' END EXCLUIDO "+CRLF
	cQry += "	,SE1.R_E_C_N_O_ RECSE1"+CRLF
	cQry += " FROM "+ RETSQLNAME("SE1") +" SE1 "+CRLF
	
	//| Busca no SIGAMAT Customizado quais filiais irão integrar com o Gesplan|
	cQry += " INNER JOIN "+ RETSQLNAME("SZK") +" SZK "+CRLF
	cQry += " 	ON E1_FILIAL = ZK_CODFIL "+CRLF
	cQry += " 	AND ZK_XINTGSP = 'S' "+CRLF
	cQry += " 	AND SZK.D_E_L_E_T_='' "+CRLF
		
	cQry += " WHERE SE1.E1_FILIAL <> ''   "+CRLF
	cQry += " 	AND SE1.E1_TIPO NOT IN" + FormatIn(MVABATIM,"|")+CRLF 	//| Remove os títulos de abatimentos.
	cQry += " 	AND NOT (SE1.E1_TIPO = 'TX' AND SE1.E1_PREFIXO <> 'AGP') " //| Somente lista titulos de taxa quando for aglutinado|
	cQry += " 	AND (  "+CRLF
	cQry += "   ( SE1.E1_EMISSAO  >='"+ dtCorte +"' AND ((SE1.E1_XSTCAS IN ('','0') AND SE1.D_E_L_E_T_='') OR (SE1.E1_XSTCAS  = '1' AND SE1.D_E_L_E_T_='*')) ) "+CRLF
	cQry += "   OR ( SE1.E1_EMISSAO  < '"+ dtCorte +"' AND ((SE1.E1_XSTCAS  = '0' AND SE1.D_E_L_E_T_='') OR (SE1.E1_XSTCAS  = '1' AND SE1.D_E_L_E_T_='*')) )"+CRLF
	cQry += " 	)  "+CRLF


	/*----------------------------------------
	18/12/2018 - Jonatas Oliveira - Compila
	Busca registros de origem cuja movimentação
	ocorreu após a data de corte
	------------------------------------------*/
	cQry += " UNION ALL  "+CRLF

	cQry += " SELECT  "+CRLF
	/*------------------------------------------------------------------
		Limita o numero de movimentos a sere retornados no JSON
	-------------------------------------------------------------------*/
	IF !EMPTY(nTopQry)
		cQry += " TOP "+ALLTRIM(STR(nTopQry))+" "
	ENDIF	
	cQry += " 	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA  "+CRLF
	cQry += " 	,E1_FILIAL FILIAL  "+CRLF
	cQry += " 	,E1_EMISSAO DATA  "+CRLF
	cQry += " 	,E1_TIPO TIPO  "+CRLF
	cQry += " 	,E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO DOC  "+CRLF
	cQry += " 	,E1_CLIENTE CLI  "+CRLF
	cQry += " 	,E1_LOJA LOJ  "+CRLF
	cQry += " 	,E1_SALDO SALDO "+CRLF
	cQry += " 	,CASE WHEN SE1.D_E_L_E_T_='*' THEN 'SIM' ELSE 'NAO' END EXCLUIDO  "+CRLF
	cQry += " 	,SE1.R_E_C_N_O_ RECSE1 "+CRLF
	cQry += " FROM "+ RETSQLNAME("SE1") +" SE1 "+CRLF
	
	cQry += " INNER JOIN "+ RETSQLNAME("SZK") +" SZK "+CRLF
	cQry += "  	ON E1_FILIAL = ZK_CODFIL  "+CRLF
	cQry += "  	AND ZK_XINTGSP = 'S'  "+CRLF
	cQry += "  	AND SZK.D_E_L_E_T_=''  "+CRLF
	
	cQry += "  INNER JOIN "+ RETSQLNAME("SE5") +" SE5 "+CRLF
	cQry += "   ON E5_FILORIG = E1_FILIAL "+CRLF
	cQry += "   AND E5_PREFIXO = E1_PREFIXO "+CRLF
	cQry += "   AND E5_NUMERO = E1_NUM "+CRLF
	cQry += "   AND E5_PARCELA = E1_PARCELA "+CRLF
	cQry += "   AND E5_TIPO = E1_TIPO "+CRLF

	cQry += "   AND E5_CLIFOR = E1_CLIENTE "+CRLF
	cQry += "   AND E5_LOJA = E1_LOJA "+CRLF
	
//	cQry += "   AND E5_RECPAG = 'R' "+CRLF
	cQry += "   AND (SE5.E5_XSTFIN <> '' OR SE5.E5_XSTCAS <> '' OR SE5.E5_XSTACC <> '')  "+CRLF
	cQry += "   AND SE5.E5_TIPODOC NOT IN "+X_TIPODOC+" "+CRLF 
	cQry += "   AND (SE5.E5_DATA >= '"+ dtCorte +"' OR SE5.E5_DTCANBX >= '"+ dtCorte +"' ) "+CRLF
	
	cQry += "  WHERE SE1.E1_FILIAL <> ''    "+CRLF
	cQry += "  	AND SE1.E1_TIPO NOT IN" + FormatIn(MVABATIM,"|")+CRLF  
	cQry += " 	AND NOT (SE1.E1_TIPO = 'TX' AND SE1.E1_PREFIXO <> 'AGP') " //| Somente lista titulos de taxa quando for aglutinado|	
	cQry += "  	AND ( SE1.E1_EMISSAO  < '"+ dtCorte +"' AND ((SE1.E1_XSTCAS = '' AND SE1.D_E_L_E_T_='') OR (SE1.E1_XSTCAS  = '1' AND SE1.D_E_L_E_T_='*')) )  "+CRLF

	
	//	cQry += " AND ( SE1.E1_EMISSAO  >='"+ dtCorte +"' AND ((SE1.E1_XSTCAS IN ('','0') AND SE1.D_E_L_E_T_='') OR (SE1.E1_XSTCAS  IN ('','0','1') AND SE1.D_E_L_E_T_='*')) ) "+CRLF			//| Status de integração da Gesplan
	
//	MemoWrite(GetTempPath(.T.) + "QryCPostCR.SQL", cQry) 

	/*
	IF cOper == D_XSTGES_PENDENTE //| Pendente.
	
		cQry += "	AND SE1.D_E_L_E_T_='' "+CRLF
		
	ENDIF
	*/
	
	cQry += " ORDER BY E1_FILIAL,E1_PREFIXO,E1_NUM,E1_TIPO,E1_PARCELA
	
	IF SELECT("CRFIN") > 0

		CRFIN->(DbCloseArea())
		
	ENDIF
	
	TCQUERY cQry NEW ALIAS "CRFIN"


RETURN()




/*/{Protheus.doc} QryCPostCP
Consulta os títulos que estão pendentes de envio no CashPost
no contas a pagar.
@author Fabio Sales
@since 27/08/2018
@Return String
@version 1.0
/*/

STATIC FUNCTION QryCPostCP(cOper)

	Local cQry	:= ""
	Default cOper:= "0" 
		
	cQry := " SELECT "
	
	/*------------------------------------------------------------------
		Limita o numero de movimentos a sere retornados no JSON
	-------------------------------------------------------------------*/
	IF !EMPTY(nTopQry)
		cQry += " TOP "+ALLTRIM(STR(nTopQry))+" "
	ENDIF	
	
	//cQry += "	(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO+E2_FORNECE+E2_LOJA) CHAVE "
	cQry += "	E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA"
	cQry += "	,E2_FILIAL FILIAL "
	//cQry += "	,LEFT(E2_EMISSAO,4) + '/' + SUBSTRING(E2_EMISSAO,5,2) + '/' + RIGHT(E2_EMISSAO,2) DATA "
	cQry += "	,E2_EMISSAO DATA "
	cQry += "	,E2_TIPO TIPO "
	//cQry += "	,E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO DOC "
	
	cQry += "	,E2_FORNECE FORN "
	cQry += "	,E2_LOJA LOJ "
	cQry += "	,E2_SALDO SALDO"
	cQry += "	,CASE WHEN SE2.D_E_L_E_T_='*' THEN 'SIM' ELSE 'NAO' END EXCLUIDO "
	cQry += "	,SE2.R_E_C_N_O_ RECSE2"
	cQry += " FROM "+ RETSQLNAME("SE2") +" SE2 "
	
	//| Busca no SIGAMAT Customizado quais filiais irão integrar com o Gesplan|
	cQry += " INNER JOIN "+ RETSQLNAME("SZK") +" SZK "+CRLF
	cQry += " 	ON E2_FILIAL = ZK_CODFIL "+CRLF
	cQry += " 	AND ZK_XINTGSP = 'S' "+CRLF
	cQry += " 	AND SZK.D_E_L_E_T_='' "+CRLF
		
	cQry += " WHERE SE2.E2_FILIAL <> ''   "+CRLF	
	cQry += " 	AND  SE2.E2_TIPO NOT IN" + FormatIn(MVABATIM,"|") 	//| Remove os títulos de abatimentos.
	cQry += " 	AND NOT (SE2.E2_TIPO = 'TX' AND SE2.E2_PREFIXO <> 'AGP') " //| Somente lista titulos de taxa quando for aglutinado| 
	cQry += " 	AND (  "+CRLF
	cQry += "   ( SE2.E2_EMISSAO  >='"+ dtCorte +"' AND ((SE2.E2_XSTCAS IN ('','0') AND SE2.D_E_L_E_T_='') OR (SE2.E2_XSTCAS = '1' AND SE2.D_E_L_E_T_='*')) ) "+CRLF
	cQry += "    OR ( SE2.E2_EMISSAO  < '"+ dtCorte +"' AND ((SE2.E2_XSTCAS  = '0' AND SE2.D_E_L_E_T_='') OR (SE2.E2_XSTCAS  = '1' AND SE2.D_E_L_E_T_='*')) )"+CRLF
	cQry += " 	)  "+CRLF
	
	/*----------------------------------------
		18/12/2018 - Jonatas Oliveira - Compila
		Busca registros de origem cuja movimentação
		ocorreu após a data de corte
	------------------------------------------*/
	cQry += " UNION ALL "+CRLF
	
	cQry += " SELECT "+CRLF
	
	/*------------------------------------------------------------------
		Limita o numero de movimentos a sere retornados no JSON
	-------------------------------------------------------------------*/
	IF !EMPTY(nTopQry)
		cQry += " TOP "+ALLTRIM(STR(nTopQry))+" "
	ENDIF	
	
	cQry += "	E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA"+CRLF
	cQry += "	,E2_FILIAL FILIAL "+CRLF
	cQry += "	,E2_EMISSAO DATA "+CRLF
	cQry += "	,E2_TIPO TIPO "	+CRLF
	cQry += "	,E2_FORNECE FORN "+CRLF
	cQry += "	,E2_LOJA LOJ "+CRLF
	cQry += "	,E2_SALDO SALDO"+CRLF
	cQry += "	,CASE WHEN SE2.D_E_L_E_T_='*' THEN 'SIM' ELSE 'NAO' END EXCLUIDO "+CRLF
	cQry += "	,SE2.R_E_C_N_O_ RECSE2"+CRLF
	
	cQry += " FROM "+ RETSQLNAME("SE2") +" SE2 "+CRLF	
	
	cQry += " INNER JOIN "+ RETSQLNAME("SZK") +" SZK "+CRLF
	cQry += "  	ON E2_FILIAL = ZK_CODFIL  "+CRLF
	cQry += "  	AND ZK_XINTGSP = 'S'  "+CRLF
	cQry += "  	AND SZK.D_E_L_E_T_=''  "+CRLF
	
	cQry += "  INNER JOIN "+ RETSQLNAME("SE5") +" SE5 "+CRLF
	cQry += "   ON E5_FILORIG = E2_FILIAL "+CRLF
	cQry += "   AND E5_PREFIXO = E2_PREFIXO "+CRLF
	cQry += "   AND E5_NUMERO = E2_NUM "+CRLF
	cQry += "   AND E5_PARCELA = E2_PARCELA "+CRLF
	cQry += "   AND E5_TIPO = E2_TIPO "+CRLF
	cQry += "   AND E5_RECPAG = 'P' "+CRLF
	
	cQry += "   AND E5_CLIFOR = E2_FORNECE "+CRLF
	cQry += "   AND E5_LOJA = E2_LOJA "+CRLF
	
	cQry += "   AND (SE5.E5_XSTFIN <> '' OR SE5.E5_XSTCAS <> '' OR SE5.E5_XSTACC <> '')  "+CRLF
	cQry += "   AND SE5.E5_TIPODOC NOT IN "+X_TIPODOC+" "+CRLF 
	cQry += "   AND (SE5.E5_DATA >= '"+ dtCorte +"' OR SE5.E5_DTCANBX >= '"+ dtCorte +"' ) "+CRLF
	
	cQry += "  WHERE SE2.E2_FILIAL <> ''    "+CRLF
	cQry += "  	AND SE2.E2_TIPO NOT IN" + FormatIn(MVABATIM,"|")
	 cQry += " 	AND NOT (SE2.E2_TIPO = 'TX' AND SE2.E2_PREFIXO <> 'AGP') " //| Somente lista titulos de taxa quando for aglutinado|
	cQry += "  	AND ( SE2.E2_EMISSAO  < '"+ dtCorte +"' AND ((SE2.E2_XSTCAS = '' AND SE2.D_E_L_E_T_='') OR (SE2.E2_XSTCAS  = '1' AND SE2.D_E_L_E_T_='*')) )  "+CRLF
	
	cQry += " ORDER BY E2_FILIAL,E2_PREFIXO,E2_NUM,E2_TIPO,E2_PARCELA
	
//	MemoWrite(GetTempPath(.T.) + "QryCPostCP_20190110.SQL", cQry) 

	
	IF SELECT("CPFIN") > 0

		CPFIN->(DbCloseArea())
		
	ENDIF

		
	TCQUERY cQry NEW ALIAS "CPFIN"


RETURN()




/*/{Protheus.doc} QryMovCR
Consulta os títulos que estão pendentes de envio no CashPost
@author Fabio Sales
@since 18/08/2018
@Return String
@version 1.0
/*/

STATIC FUNCTION QryMovCR()

	Local cQry	:= ""
	Local nTamChv	:= TamSx3("E5_PREFIXO")[1] + TamSx3("E5_NUMERO")[1] + TamSx3("E5_PARCELA")[1] + TamSx3("E5_TIPO")[1]
			
	cQry += " SELECT "
	
	/*------------------------------------------------------------------
		Limita o numero de movimentos a sere retornados no JSON
	-------------------------------------------------------------------*/
	IF !EMPTY(nTopQry)
		cQry += " TOP "+ALLTRIM(STR(nTopQry))+" "
	ENDIF	
	
	cQry += "	E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA "
	cQry += "	,E1_FILIAL FILIAL  "
	cQry += "	,E1_VENCREA DATA  "
	cQry += "	,CASE WHEN  SE5.R_E_C_N_O_ IS NOT NULL THEN SE5.E5_DATA ELSE SE5B.E5_DATA END DTBX  "+CRLF
	cQry += "	,E1_TIPO TIPO  "+CRLF
	cQry += "	,E1_CLIENTE CLI "+CRLF
	cQry += "	,E1_LOJA LOJ  "+CRLF
	cQry += "	,SE5.E5_MOTBX MOTBX  "+CRLF
    cQry += "	,A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, SE5.E5_BANCO, SE5.E5_CONTA, SE5.E5_AGENCIA "+CRLF    
	cQry += "	,SE5.E5_HISTOR  "+CRLF
	cQry += "	,SE1.R_E_C_N_O_ RECSE1  "+CRLF
	cQry += "	,ISNULL(SE5.R_E_C_N_O_,ISNULL(SE5B.R_E_C_N_O_,0)) RECSE5 "
	
	/*-----------------------------------------------------------------------------------------\
	| Tratativas para zerar o valor baixado para os casos de exclusão de baixas e compenação,  | 
	| estorno de compensação e canelamento de baixas.                                          |
	\-----------------------------------------------------------------------------------------*/
	
	cQry += "	,CASE WHEN SE5.D_E_L_E_T_='*'  THEN 0  "+CRLF //| Exclusão de baixas e exclusão de compensação
	cQry += "		 WHEN SE5.E5_DTCANBX <> '' THEN 0  "+CRLF //| Cancelamento de Baixas
	cQry += "		 WHEN SE5.E5_MOTBX = 'DAC' THEN 0  "+CRLF //| Baixa Dacao
	cQry += "		 WHEN SE5.E5_MOTBX = 'TXC' THEN 0  "+CRLF //| Taxa Cartão
	cQry += "		 WHEN SE5.E5_MOTBX = 'PCC' THEN 0  "+CRLF //| PCC
	
	cQry += "			 WHEN EXISTS(SELECT 1 FROM " + RetSqlName("SE5")+ " CMP "+CRLF  //| Estorno de compensação.
	cQry += "								WHERE CMP.E5_FILIAL= SE5.E5_FILIAL "+CRLF
	cQry += "									AND LEFT(CMP.E5_DOCUMEN," + alltrim(str(nTamChv)) + ") = SE5.E5_PREFIXO + SE5.E5_NUMERO + SE5.E5_PARCELA + SE5.E5_TIPO "+CRLF
	cQry += "									AND CMP.E5_CLIFOR=SE5.E5_CLIFOR "+CRLF
	cQry += "									AND CMP.E5_LOJA=SE5.E5_LOJA "+CRLF
	cQry += "									AND CMP.E5_SEQ = SE5.E5_SEQ "+CRLF
	cQry += "									AND CMP.E5_MOTBX NOT IN ('CMP','FAT')  "+CRLF
	cQry += "									AND CMP.E5_TIPODOC='ES' "+CRLF
	cQry += "							) THEN 0 ELSE "+CRLF
	
	cQry += "	 			ISNULL(SE5.E5_VALOR,0) "+CRLF
	cQry += "	 END AS VALOR  "+CRLF
	 
	cQry += "	,CASE WHEN SE1.D_E_L_E_T_='*' THEN 0 ELSE E1_SALDO END SALDO  "+CRLF
	cQry += "	,CASE WHEN SE5.D_E_L_E_T_='*' THEN 'SIM' ELSE 'NAO' END EXCSE5 "+CRLF
	cQry += "	,CASE WHEN SE1.D_E_L_E_T_='*' THEN 'SIM' ELSE 'NAO' END EXCSE1 "+CRLF
	cQry += "	,E1_XFORMPG FORMPG "+CRLF
	
	cQry += " FROM  "+ RetSqlName("SE1") +" SE1 "+CRLF
	
	cQry += " LEFT JOIN " + RetSqlName("SE5")+ " SE5 "+CRLF
	cQry += "	 ON SE5.E5_FILORIG=E1_FILIAL  "+CRLF
	cQry += "	 AND SE5.E5_PREFIXO =E1_PREFIXO " +CRLF
	cQry += "	 AND SE5.E5_NUMERO=E1_NUM  "+CRLF
	cQry += "	 AND SE5.E5_PARCELA=E1_PARCELA  "+CRLF
	cQry += "	 AND SE5.E5_TIPO=E1_TIPO  "+CRLF
//	cQry += "	 AND SE5.E5_RECPAG ='R' " +CRLF
	cQry += "	 AND ( SE5.E5_XSTFIN IN ('','0')  "+CRLF 	//| Só retorna os que estão pendentes de integração.
	cQry += "	 OR (SE1.E1_EMISSAO  < '"+ dtCorte +"' AND  SE5.E5_XSTFIN <> '' )) "+CRLF //| Retorna os movimentos anteriores
	cQry += "	 AND SE5.E5_MOTBX NOT IN ('CMP','FAT') " +CRLF
	cQry += "	 AND SE5.E5_TIPODOC NOT IN "+X_TIPODOC+" "+CRLF 	//| Desconsidera Tipos de documentos que que estejam na constante.
	
	cQry += "  LEFT JOIN " + RetSqlName("SE5")+ " SE5B "+CRLF
	cQry += " 	 ON SE5B.E5_FILORIG=E1_FILIAL   "+CRLF
	cQry += " 	 AND SE5B.E5_DATA>=E1_EMISSAO   "+CRLF	
	cQry += " 	 AND SE5B.E5_RECPAG ='R'  "+CRLF
	cQry += " 	 AND SE1.D_E_L_E_T_='*'  "+CRLF
	cQry += "      AND SE1.E1_TIPO = 'RA' "+CRLF
	cQry += "      AND SE5B.E5_TIPODOC<>'ES'  "+CRLF
	cQry += "	 AND SE5B.E5_MOTBX NOT IN ('CMP','FAT') " +CRLF
	cQry += "      AND SE5B.E5_KEY = E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA "+CRLF
	cQry += " 	 AND SE5B.E5_TIPODOC NOT IN ('J2','JR','M2','MT','D2','DC')  "+CRLF	
	
	cQry += " LEFT JOIN "+ RetSqlName("SA6") +" A6 "+CRLF
	cQry += "	 ON LEFT(SE5.E5_FILIAL  , 5 ) = A6_FILIAL  "+CRLF
	cQry += "	 AND SE5.E5_BANCO = A6_COD "+CRLF
	cQry += "	 AND SE5.E5_AGENCIA = A6_AGENCIA "+CRLF
	cQry += "	 AND SE5.E5_CONTA = A6_NUMCON "+CRLF
	cQry += "	 AND A6.D_E_L_E_T_ = '' "
	
	//| Busca no SIGAMAT Customizado quais filiais irão integrar com o Gesplan|
	cQry += " INNER JOIN "+ RETSQLNAME("SZK") +" SZK "+CRLF
	cQry += " 	ON E1_FILIAL = ZK_CODFIL "+CRLF
	cQry += " 	AND ZK_XINTGSP = 'S' "+CRLF
	cQry += " 	AND SZK.D_E_L_E_T_='' "+CRLF

	
	cQry += " WHERE (  "+CRLF
	cQry += "   ( SE1.E1_EMISSAO  >='"+ dtCorte +"' AND ((SE1.E1_XSTFIN IN ('','0') AND SE1.D_E_L_E_T_='') OR (SE1.E1_XSTFIN  = '1' AND SE1.D_E_L_E_T_='*')) ) "+CRLF
	cQry += "   OR ( SE1.E1_EMISSAO  < '"+ dtCorte +"' AND ((SE1.E1_XSTFIN  = '0' AND SE1.D_E_L_E_T_='') OR (SE1.E1_XSTFIN  = '1' AND SE1.D_E_L_E_T_='*')) )"+CRLF
	cQry += " 	)  "+CRLF
	
	cQry += "	 AND SE1.E1_TIPO NOT IN" + FormatIn(MVABATIM,"|")+CRLF 	//| Remove os títulos de abatimentos.
	cQry += " 	AND NOT (SE1.E1_TIPO = 'TX' AND SE1.E1_PREFIXO <> 'AGP') " //| Somente lista titulos de taxa quando for aglutinado|	
	cQry += " ORDER BY E1_FILIAL , E1_PREFIXO , E1_NUM , E1_PARCELA , E1_TIPO  "+CRLF


	
	IF SELECT("CRSE5") > 0
		CRSE5->(DbCloseArea())
	ENDIF
	
	TCQUERY cQry NEW ALIAS "CRSE5"


RETURN()


/*/{Protheus.doc} QryMovCP
Consulta os títulos que estão pendentes de envio no CashPost
@author Fabio Sales
@since 18/08/2018
@Return String
@version 1.0
/*/

STATIC FUNCTION QryMovCP()

	Local cQry	:= ""
	Local nTamChv	:= TamSx3("E5_PREFIXO")[1] + TamSx3("E5_NUMERO")[1] + TamSx3("E5_PARCELA")[1] + TamSx3("E5_TIPO")[1]		
	
	cQry += " SELECT "+CRLF
	
	/*------------------------------------------------------------------
		Limita o numero de movimentos a sere retornados no JSON
	-------------------------------------------------------------------*/
	IF !EMPTY(nTopQry)
		cQry += " TOP "+ALLTRIM(STR(nTopQry))+" "
	ENDIF	
	
	cQry += "	E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA "+CRLF
	cQry += "	,E2_FILIAL FILIAL  "+CRLF
	cQry += "	,E2_VENCREA DATA  "+CRLF
	cQry += "	,CASE WHEN  SE5.R_E_C_N_O_ IS NOT NULL THEN SE5.E5_DATA ELSE SE5B.E5_DATA END DTBX  "+CRLF	
//	cQry += "	,SE5.E5_DATA DTBX "+CRLF	
	cQry += "	,E2_TIPO TIPO  "+CRLF
	cQry += "	,E2_FORNECE FORN "+CRLF
	cQry += "	,E2_LOJA LOJ  "+CRLF
	cQry += "	,SE5.E5_MOTBX MOTBX  "+CRLF
    cQry += "	,A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, SE5.E5_BANCO, SE5.E5_CONTA, SE5.E5_AGENCIA
	cQry += "	,SE5.E5_HISTOR  "+CRLF
	cQry += "	,SE2.R_E_C_N_O_ RECSE2  "+CRLF
	cQry += "	,ISNULL(SE5.R_E_C_N_O_,ISNULL(SE5B.R_E_C_N_O_,0)) RECSE5 "
	
	
	/*-----------------------------------------------------------------------------------------\
	| Tratativas para zerar o valor baixado para os casos de exclusão de baixas e compenação,  | 
	| estorno de compensação e canelamento de baixas.                                          |
	\-----------------------------------------------------------------------------------------*/	
	cQry += "	,CASE WHEN SE5.D_E_L_E_T_='*'  THEN 0  "+CRLF //| Exclusão de baixas e exclusão de compensação
	cQry += "		 WHEN SE5.E5_DTCANBX <> '' THEN 0  "+CRLF //| Cancelamento de Baixas
	cQry += "		 WHEN SE5.E5_MOTBX = 'DAC' THEN 0  "+CRLF //| Baixa Dacao
	cQry += "		 WHEN SE5.E5_MOTBX = 'TXC' THEN 0  "+CRLF //| Taxa Cartão
	cQry += "		 WHEN SE5.E5_MOTBX = 'PCC' THEN 0  "+CRLF //| PCC
	cQry += "			 WHEN EXISTS(SELECT 1 FROM " + RetSqlName("SE5")+ " CMP "+CRLF  //| Estorno de compensação.
	cQry += "								WHERE CMP.E5_FILIAL= SE5.E5_FILIAL "+CRLF
	cQry += "									AND LEFT(CMP.E5_DOCUMEN," + alltrim(str(nTamChv)) + ") = SE5.E5_PREFIXO + SE5.E5_NUMERO + SE5.E5_PARCELA + SE5.E5_TIPO "+CRLF
	cQry += "									AND CMP.E5_CLIFOR=SE5.E5_CLIFOR "+CRLF
	cQry += "									AND CMP.E5_LOJA=SE5.E5_LOJA "+CRLF
	cQry += "									AND CMP.E5_SEQ = SE5.E5_SEQ "+CRLF
	cQry += "									AND  CMP.E5_MOTBX IN ('CMP','FAT') "+CRLF
	cQry += "									AND CMP.E5_TIPODOC='ES' "+CRLF
	cQry += "							) THEN 0 ELSE "+CRLF
	cQry += "	 			ISNULL(SE5.E5_VALOR,0) "+CRLF
	cQry += "	 END AS VALOR  "+CRLF
	
	
	cQry += "	,CASE WHEN SE2.D_E_L_E_T_='*' THEN 0 ELSE E2_SALDO END SALDO  "+CRLF
	cQry += "	,CASE WHEN SE5.D_E_L_E_T_='*' THEN 'SIM' ELSE 'NAO' END EXCSE5 "  +CRLF
	cQry += "	,CASE WHEN SE2.D_E_L_E_T_='*' THEN 'SIM' ELSE 'NAO' END EXCSE2 "+CRLF
	cQry += "	,E2_FORMPAG FORMPG "+CRLF
	cQry += " FROM  "+ RetSqlName("SE2") +" SE2 "+CRLF
	cQry += " LEFT JOIN " + RetSqlName("SE5")+ " SE5 "+CRLF
	cQry += "	 ON SE5.E5_FILORIG=E2_FILIAL  "+CRLF
	cQry += "	 AND SE5.E5_PREFIXO =E2_PREFIXO " +CRLF
	cQry += "	 AND SE5.E5_NUMERO=E2_NUM  "+CRLF
	cQry += "	 AND SE5.E5_PARCELA=E2_PARCELA  "+CRLF
	cQry += "	 AND SE5.E5_TIPO=E2_TIPO  "+CRLF
	cQry += "	 AND SE5.E5_CLIFOR=E2_FORNECE "+CRLF
	cQry += "	 AND SE5.E5_LOJA=E2_LOJA "+CRLF
//	cQry += "	 AND SE5.E5_RECPAG ='P' " +CRLF
	cQry += "	 AND SE5.E5_MOTBX NOT IN ('CMP','FAT') " +CRLF
	
	cQry += "	 AND ((SE5.E5_XSTFIN IN ('','0')  AND SE5.D_E_L_E_T_ = '') OR (SE5.E5_XSTFIN IN ('','0','1') AND SE5.D_E_L_E_T_ = '*')    " 	//| Só retorna os que estão pendentes de integração.
	cQry += "	 OR (SE2.E2_EMISSAO  < '"+ dtCorte +"' AND  SE5.E5_XSTFIN <> '' )) "+CRLF 	//| Retorna os movimentos anteriores	
	cQry += "	 AND SE5.E5_TIPODOC NOT IN "+X_TIPODOC+" " 	//| Desconsidera Tipos de documentos que que estejam na constante.
	
	cQry += "  LEFT JOIN " + RetSqlName("SE5")+ " SE5B "+CRLF
	cQry += " 	 ON SE5B.E5_FILORIG=E2_FILIAL   "+CRLF
	cQry += " 	 AND SE5B.E5_DATA>=E2_EMISSAO   "+CRLF	
	cQry += " 	 AND SE5B.E5_RECPAG ='P'  "+CRLF
	cQry += " 	 AND SE2.D_E_L_E_T_='*'  "+CRLF
	cQry += "      AND SE2.E2_TIPO = 'PA' "+CRLF
	cQry += "      AND SE5B.E5_TIPODOC<>'ES'  "+CRLF
	cQry += "	 AND SE5B.E5_MOTBX NOT IN ('CMP','FAT') " +CRLF
	cQry += "      AND SE5B.E5_KEY = E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA "+CRLF
	cQry += " 	 AND SE5B.E5_TIPODOC NOT IN ('J2','JR','M2','MT','D2','DC')  "+CRLF	
		
	
	cQry += " LEFT JOIN "+ RetSqlName("SA6") +" A6 "+CRLF
	cQry += "	 ON LEFT(SE5.E5_FILIAL  , 5 ) = A6_FILIAL " +CRLF
	cQry += "	 AND SE5.E5_BANCO = A6_COD "+CRLF
	cQry += "	 AND SE5.E5_AGENCIA = A6_AGENCIA "+CRLF
	cQry += "	 AND SE5.E5_CONTA = A6_NUMCON "+CRLF
	cQry += "	 AND A6.D_E_L_E_T_ = '' "+CRLF
	
	//| Busca no SIGAMAT Customizado quais filiais irão integrar com o Gesplan|
	cQry += " INNER JOIN "+ RETSQLNAME("SZK") +" SZK "+CRLF
	cQry += " 	ON E2_FILIAL = ZK_CODFIL "+CRLF
	cQry += " 	AND ZK_XINTGSP = 'S' "+CRLF
	cQry += " 	AND SZK.D_E_L_E_T_='' "+CRLF

	
	cQry += " WHERE (  "+CRLF
	cQry += "   ( SE2.E2_EMISSAO  >='"+ dtCorte +"' AND ((SE2.E2_XSTFIN IN ('','0') AND SE2.D_E_L_E_T_='') OR (SE2.E2_XSTFIN  = '1' AND SE2.D_E_L_E_T_='*')) ) "+CRLF
	cQry += "    OR ( SE2.E2_EMISSAO  < '"+ dtCorte +"' AND ((SE2.E2_XSTFIN  = '0' AND SE2.D_E_L_E_T_='') OR (SE2.E2_XSTFIN  = '1' AND SE2.D_E_L_E_T_='*')) )"+CRLF
	cQry += " 	)  "+CRLF

	cQry += " 	AND NOT (SE2.E2_TIPO = 'TX' AND SE2.E2_PREFIXO <> 'AGP') " //| Somente lista titulos de taxa quando for aglutinado|	
	cQry += "	 AND SE2.E2_TIPO NOT IN" + FormatIn(MVABATIM,"|")+CRLF 	//| Remove os títulos de abatimentos.
	cQry += " ORDER BY E2_FILIAL , E2_PREFIXO , E2_NUM , E2_PARCELA , E2_TIPO  "+CRLF


//	cQry += " WHERE E2_EMISSAO >='"+ dtCorte +"' "+CRLF
//	cQry += "	 AND SE2.E2_XSTFIN = '0' " 	+CRLF						//| Filtra somente os títulos que estão aguardando o CashPosting
//	cQry += " AND ((SE2.E2_XSTFIN IN ('','0')  AND SE2.D_E_L_E_T_ = '') OR (SE2.E2_XSTFIN IN ('','0','1') AND SE2.D_E_L_E_T_ = '*') ) "+CRLF	
//	MemoWrite(GetTempPath(.T.) + "QryMovCP_20181218.SQL", cQry) 

	
	IF SELECT("CPSE5") > 0

		CPSE5->(DbCloseArea())
		
	ENDIF
	
	TCQUERY cQry NEW ALIAS "CPSE5"


RETURN()


/*/{Protheus.doc} QryMovBC
Consulta os títulos que estão pendentes do financialOpenness na movimentação banária.
@author Fabio Sales
@since 30/09/2018
@Return String
@version 1.0
/*/

STATIC FUNCTION QryMovBC(nOpc)

	Local cQry		:= ""
	Local cCpoSt	:= ""

	cQry := " SELECT "
	
	/*------------------------------------------------------------------
		Limita o numero de movimentos a sere retornados no JSON
	-------------------------------------------------------------------*/
	IF !EMPTY(nTopQry)
		cQry += " TOP "+ALLTRIM(STR(nTopQry))+" "
	ENDIF	
	
	IF nOpc == 1 //CashPosting
	
		cCpoSt	:= "E5_XSTCAS"
		
		cQry += " 	SE5.R_E_C_N_O_ AS RECSE5 "
		cQry += "	,CASE WHEN SE5.D_E_L_E_T_='*' THEN 'SIM' ELSE 'NAO' END EXCLUIDO "
		
	ELSEIF nOpc == 2 // financialOpenness
		
		cCpoSt	:= "E5_XSTFIN"
	
		cQry += " 	SE5.R_E_C_N_O_ AS CHAVE " 
		cQry += " 		,E5_FILIAL FILIAL "
		cQry += " 		,LEFT(E5_DATA,4) + '/' + SUBSTRING(E5_DATA,5,2) + '/' + RIGHT(E5_DATA,2) DTBX " 
		cQry += " 		,E5_MOTBX MOTBX  "
	//	cQry += " 		,RTRIM(E5_BANCO) + RTRIM(E5_AGENCIA) + RTRIM(E5_CONTA)  CONTAG "
	    cQry += "	,CASE  "
	    cQry += "	  WHEN ISNULL(A6_COD,  '') <> ''" 
	    cQry += "	    THEN  RTRIM(A6_COD) + RTRIM(A6_AGENCIA) + RTRIM(A6_DVAGE) + RTRIM(A6_NUMCON) + RTRIM(A6_DVCTA)  "
	    cQry += "	  ELSE  "
	    cQry += "	    RTRIM(E5_BANCO) + RTRIM(E5_CONTA) + RTRIM(E5_AGENCIA)   "
	    cQry += "	END AS CONTAG  "  
		cQry += " 		,E5_HISTOR  "
		cQry += " 		,SE5.R_E_C_N_O_ RECSE5 " 
		cQry += " 		,E5_RECPAG TIPOREC " 
		cQry += " 		,CASE WHEN E5_SITUACA IN('C','X') THEN 0 ELSE E5_VALOR END AS VALOR "
			
	ELSEIF nOpc == 3 //AccountingOpenness
	
		cCpoSt	:= "E5_XSTACC"		
		
		cQry += " 	SE5.R_E_C_N_O_ AS RECSE5 "
		cQry += "	,CASE WHEN SE5.D_E_L_E_T_='*' THEN 'SIM' ELSE 'NAO' END EXCLUIDO "
		
	ENDIF
	cQry += " FROM  " + RetSqlName("SE5") + " SE5 "
	cQry += " LEFT JOIN "+ RetSqlName("SA6") +" A6 "
	cQry += "	 ON LEFT(E5_FILIAL  , 5 ) = A6_FILIAL " 
	cQry += "	 AND E5_BANCO = A6_COD "
	cQry += "	 AND E5_AGENCIA = A6_AGENCIA "
	cQry += "	 AND E5_CONTA = A6_NUMCON "
	cQry += "	 AND A6.D_E_L_E_T_ = '' "
	
	//| Busca no SIGAMAT Customizado quais filiais irão integrar com o Gesplan|
	cQry += " INNER JOIN "+ RETSQLNAME("SZK") +" SZK "+CRLF
	cQry += " 	ON E5_FILIAL = ZK_CODFIL "+CRLF
	cQry += " 	AND ZK_XINTGSP = 'S' "+CRLF
	cQry += " 	AND SZK.D_E_L_E_T_='' "+CRLF	
	
	cQry += " WHERE (   "
//	cQry += " 	(E5_DATA >='"+ dtCorte +"' AND SE5."+cCpoSt+" IN ('','0'))  "
	
	
	cQry += " 	(E5_DATA >='"+ dtCorte +"' AND ((SE5."+cCpoSt+" IN ('','0') AND SE5.D_E_L_E_T_ = '') OR (SE5."+cCpoSt+" = '1' AND SE5.D_E_L_E_T_ = '*'))  )  "
	
	cQry += " 	OR (E5_DATA < '"+ dtCorte +"' AND SE5."+cCpoSt+" = '0')   "
	cQry += " 	)"
	cQry += " 		AND E5_CLIFOR='' "	
	
	//| Nao processa excluidos para AccountingOpenness|
	IF nOpc == 3 //AccountingOpenness
		cQry += " 	AND SE5.D_E_L_E_T_ = '' "
	endif
	
	cQry += " 	AND SE5.E5_TIPODOC NOT IN ('TR') "
	cQry += " 	AND NOT (SE5.E5_TIPO = 'TX' AND SE5.E5_AGLIMP <> '') " //| Somente lista titulos de taxa quando for aglutinado|
			
	cQry += " ORDER BY SE5.R_E_C_N_O_ "
	
//	cQry += " WHERE E5_DATA >='"+ dtCorte +"' " 	 
//	cQry += " 		AND SE5.E5_XSTFIN='0' "

//	MemoWrite(GetTempPath(.T.) + "QryMovBC_20181218.SQL", cQry) 

//	AVISO("QryMovBC",cQry,{"Fechar"}, 3, ,, , .T.,  )
	
	IF SELECT("BCSE5") > 0

		BCSE5->(DbCloseArea())
		
	ENDIF
	
	TCQUERY cQry NEW ALIAS "BCSE5"
	
RETURN()



	

/*/{Protheus.doc} QryAcOpCR
Consulta os títulos que estão pendentes de envio no AccountingOpenness
@author Fabio Sales
@since 10/09/2018
@Return String
@version 1.0
/*/

STATIC FUNCTION QryAcOpCR()

	Local cQry	:= ""
			
	cQry += " SELECT "
	/*------------------------------------------------------------------
		Limita o numero de movimentos a sere retornados no JSON
	-------------------------------------------------------------------*/
	IF !EMPTY(nTopQry)
		cQry += " TOP "+ALLTRIM(STR(nTopQry))+" "
	ENDIF	
	
	cQry += "	E1_FILIAL + '|' + E1_PREFIXO + '|' + E1_NUM + '|' + E1_PARCELA + '|' + E1_TIPO + '|' + E1_CLIENTE + '|' + E1_LOJA AS CHAVE "
	cQry += "	,E1_NATUREZ NATUREZ  "
	cQry += "	,E1_CCUSTO CCUSTO  "
	cQry += "	,E1_VALOR VALOR  "
	cQry += "	,SE1.R_E_C_N_O_ RECSE1"
	cQry += " FROM " + RetSqlName("SE1") + " SE1  "
	
	//| Busca no SIGAMAT Customizado quais filiais irão integrar com o Gesplan|
	cQry += " INNER JOIN "+ RETSQLNAME("SZK") +" SZK "//+CRLF
	cQry += " 	ON E1_FILIAL = ZK_CODFIL "//+CRLF
	cQry += " 	AND ZK_XINTGSP = 'S' "//+CRLF
	cQry += " 	AND SZK.D_E_L_E_T_='' "//+CRLF
	
	cQry += " WHERE SE1.E1_FILIAL <> ''   "//+CRLF
//	
//	cQry += " AND (  "+CRLF
//	cQry += "   ( SE1.E1_EMISSAO  >='"+ dtCorte +"' AND ((SE1.E1_XSTACC IN ('','0') AND SE1.D_E_L_E_T_='') OR (SE1.E1_XSTACC  = '1' AND SE1.D_E_L_E_T_='*')) ) "+CRLF
//	cQry += "   OR ( SE1.E1_EMISSAO  < '"+ dtCorte +"' AND ((SE1.E1_XSTACC  = '0' AND SE1.D_E_L_E_T_='') OR (SE1.E1_XSTACC  = '1' AND SE1.D_E_L_E_T_='*')) )"+CRLF
//	cQry += " 	)  "+CRLF
//		
	
	cQry += " 	AND (  "//+CRLF
	cQry += "   (    SE1.E1_EMISSAO  >='"+ dtCorte +"' AND SE1.E1_XSTACC IN ('','0')  AND SE1.D_E_L_E_T_='' ) "//+CRLF
	cQry += "   OR ( SE1.E1_EMISSAO  < '"+ dtCorte +"' AND SE1.E1_XSTACC  = '0'  AND SE1.D_E_L_E_T_='' )"//+CRLF
	cQry += " 	)  "//+CRLF	

	cQry += "	 AND SE1.E1_TIPO NOT IN" + FormatIn(MVABATIM,"|") 	//| Remove os títulos de abatimentos.		
	cQry += " 	AND NOT (SE1.E1_TIPO = 'TX' AND SE1.E1_PREFIXO <> 'AGP') " //| Somente lista titulos de taxa quando for aglutinado|
//	cQry += " WHERE E1_EMISSAO >='"+ dtCorte +"' "
//	cQry += "	 AND SE1.E1_XSTACC = '0' "
 		
//	MemoWrite(GetTempPath(.T.) + "QryAcOpCR.SQL", cQry) 


	IF SELECT("ACCOP") > 0

		ACCOP->(DbCloseArea())
		
	ENDIF
	
	TCQUERY cQry NEW ALIAS "ACCOP"


RETURN()


/*/{Protheus.doc} QryAcOpCR
Consulta os títulos que estão pendentes de envio no AccountingOpenness
@author Fabio Sales
@since 10/09/2018
@Return String
@version 1.0
/*/

STATIC FUNCTION QryAcOpCP()

	Local cQry	:= ""
			
	cQry += " SELECT "
	/*------------------------------------------------------------------
		Limita o numero de movimentos a sere retornados no JSON
	-------------------------------------------------------------------*/
	IF !EMPTY(nTopQry)
		cQry += " TOP "+ALLTRIM(STR(nTopQry))+" "
	ENDIF	
	cQry += "	E2_FILIAL + '|' + E2_PREFIXO + '|' + E2_NUM + '|' + E2_PARCELA + '|' + E2_TIPO + '|' + E2_FORNECE + '|' + E2_LOJA AS CHAVE "
	cQry += "	,E2_NATUREZ NATUREZ  "
	cQry += "	,E2_CCUSTO CCUSTO  "
	cQry += "	,E2_VALOR VALOR  "
	cQry += "	,SE2.R_E_C_N_O_ RECSE2"
	cQry += " FROM " + RetSqlName("SE2") + " SE2  "
	
	//| Busca no SIGAMAT Customizado quais filiais irão integrar com o Gesplan|
	cQry += " INNER JOIN "+ RETSQLNAME("SZK") +" SZK "+CRLF
	cQry += " 	ON E2_FILIAL = ZK_CODFIL "+CRLF
	cQry += " 	AND ZK_XINTGSP = 'S' "+CRLF
	cQry += " 	AND SZK.D_E_L_E_T_='' "+CRLF

	cQry += " WHERE E2_FILIAL <> '' "
	
	
//	cQry += " AND (  "+CRLF
//	cQry += "   ( SE2.E2_EMISSAO  >='"+ dtCorte +"' AND ((SE2.E2_XSTACC IN ('','0') AND SE2.D_E_L_E_T_='') OR (SE2.E2_XSTACC  = '1' AND SE2.D_E_L_E_T_='*')) ) "+CRLF
//	cQry += "    OR ( SE2.E2_EMISSAO  < '"+ dtCorte +"' AND ((SE2.E2_XSTACC  = '0' AND SE2.D_E_L_E_T_='') OR (SE2.E2_XSTACC  = '1' AND SE2.D_E_L_E_T_='*')) )"+CRLF
//	cQry += " 	)  "+CRLF
	
	
	
	cQry += " AND (  "+CRLF
	cQry += "   (     SE2.E2_EMISSAO  >='"+ dtCorte +"' AND SE2.E2_XSTACC IN ('','0')  AND SE2.D_E_L_E_T_='') "+CRLF
	cQry += "    OR ( SE2.E2_EMISSAO  < '"+ dtCorte +"' AND SE2.E2_XSTACC  = '0' AND SE2.D_E_L_E_T_='' )"+CRLF
	cQry += " 	)  "+CRLF
	
	cQry += "	 AND SE2.E2_TIPO NOT IN" + FormatIn(MVABATIM,"|") 	//| Remove os títulos de abatimentos.		
	cQry += " 	AND NOT (SE2.E2_TIPO = 'TX' AND SE2.E2_PREFIXO <> 'AGP') " //| Somente lista titulos de taxa quando for aglutinado|	
//	cQry += " WHERE E2_EMISSAO >='"+ dtCorte +"' "
//	cQry += "	 AND SE2.E2_XSTACC IN ('','0')  " 	
//	MemoWrite(GetTempPath(.T.) + "QryAcOpCP.SQL", cQry) 

	IF SELECT("ACCOP") > 0

		ACCOP->(DbCloseArea())
		
	ENDIF
	
	TCQUERY cQry NEW ALIAS "ACCOP"


RETURN()


/*/{Protheus.doc} AtuStatus
Altera o status da integração para poder testar.
@author Fabio Sales
@since 22/08/2018
@Return String
@version 1.0
/*/

User Function AtuStatus(Alias,status)

	Local cmsg		:= "Atualizado com Sucesso"
	Default Alias   := ""
	Default status  := ""
		
	IF !EMPTY(Alias) .AND. !EMPTY(status)
		
		Alias := UPPER(ALLTRIM(Alias))
		
		IF Alias $ "SE1/SE5/SE2"
		
			Suf	 := RIGHT(Alias,2)
			
			cUpd := "UPDATE " + RetSqlName(Alias) + " SET "+ Suf + "_XSTCAS = '"+ status +"',  "+ Suf + "_XDTGPLA= '" + dtos(ddatabase) + "' WHERE "+ Suf + "_XSTCAS <> ''  "
			
			TCSqlExec(cUpd)
			
			cUpd := "UPDATE " + RetSqlName(Alias) + " SET "+ Suf + "_XSTFIN = '"+ status +"',  "+ Suf + "_XDTGPLA= '" + dtos(ddatabase) + "' WHERE "+ Suf + "_XSTFIN <> ''  "
			
			TCSqlExec(cUpd)
			
			cUpd := "UPDATE " + RetSqlName(Alias) + " SET "+ Suf + "_XSTACC = '"+ status +"',  "+ Suf + "_XDTGPLA= '" + dtos(ddatabase) + "' WHERE "+ Suf + "_XSTACC <> ''  "
			
			TCSqlExec(cUpd)
			
		ELSE
			cmsg:= "Tabela informada no primeiro parãmetro está errada. Informada " + Alias 
		ENDIF
		
	ELSE
		cmsg:= "digite os dois parâmetros da Função."
	ENDIF

Return()



User Function GPTSTST()
Local nOpcSt	:= 0

	nOpcSt	:= AVISO("GESPLAN TESTE","**** ROTINA DEVE SER UTILIZADA SOMENTE EM AMBIENTE DE TESTE ****"+CRLF+"Limpar STATUS para reintegrar registros",{"SE1","SE5","SE1 + SE5","SE2", "Fechar"},3, "",,,.T.)
	
	
	IF nOpcSt == 1 .OR. nOpcSt == 3
		U_AtuStatus("SE1","0")
	ENDIF
	
	IF nOpcSt == 2 .OR. nOpcSt == 3
		U_AtuStatus("SE5","0")
	ENDIF	
	
	IF nOpcSt == 4 
		U_AtuStatus("SE2","0")
	ENDIF	
	

Return()


User Function GPTSTCAS()

	nOpcSt	:= AVISO("GESPLAN TESTE - CASHPOSTING","***CLIQUE NO JSON QUE DESEJA GERAR",{"Gerar","Fechar"},3, "",,,.T.)
	
	IF nOpcSt == 1
	
		AVISO("CashPosting",U_ALGPINTE(1),{"Fechar"},3, "",,,.T.)
			
	ENDIF

Return()

User Function GPTSTFIN()

	nOpcSt	:= AVISO("GESPLAN TESTE - FINANCIALOPENNESS","***CLIQUE NO JSON QUE DESEJA GERAR",{"Gerar", "Fechar"},3, "",,,.T.)
	
	IF nOpcSt == 1 //| CONTAS ARECEBER
	
		AVISO("FinancialOpenness",U_ALGPINTE(2),{"Fechar"},3, "",,,.T.)
		
	//|ELSEIF nOpcSt == 2 //| CONTAS A PAGAR
	
	//|	AVISO("FinancialOpenness",U_ALGPFCP(),{"Fechar"},3, "",,,.T.)
			
	ENDIF


Return()


User Function GPTSTACO()

	nOpcSt	:= AVISO("GESPLAN TESTE - ACCOUNTINOPENNESS","***CLIQUE NO JSON QUE DESEJA GERAR",{"Gerar","Fechar"},3, "",,,.T.)
	
	IF nOpcSt == 1 //| CONTAS ARECEBER
	
		AVISO("ACCOUNTINOPENNESS",U_ALGPINTE(3),{"Fechar"},3, "",,,.T.)	
			
	ENDIF

Return()




User Function GPTSTALL()
Local lFecha	:= .f.
Local cJsonMsg	:= ""

	WHILE !(lFecha)
		nOpcSt	:= AVISO("GESPLAN TESTE - CASHPOSTING /  FINANCIALOPENNESS / ACCOUNTINOPENNESS","***CLIQUE NO JSON QUE DESEJA GERAR",{"Gerar","Fechar"},3, "",,,.T.)
		
		IF nOpcSt == 1
		
			
			cJsonMsg	:= ""
			cJsonMsg	+= "// CASHPOSTING // "+DTOC(DATE())+" "+TIME()+CRLF
			cJsonMsg	+= U_ALGPINTE(1)
			cJsonMsg	+= CRLF
			cJsonMsg	+= "// FINANCIALOPENNESS //"+DTOC(DATE())+" "+TIME()+CRLF
			cJsonMsg	+= U_ALGPINTE(2)
			cJsonMsg	+= CRLF
			cJsonMsg	+= "// ACCOUNTINOPENNESS //"+DTOC(DATE())+" "+TIME()+CRLF
			cJsonMsg	+= U_ALGPINTE(3)
			
			AVISO("TESTE GESPLAN",cJsonMsg,{"Fechar"},3, "",,,.T.)
			
		else
			lFecha	:= .T.
			EXIT			
		ENDIF
	ENDDO

Return()


/*/{Protheus.doc} alValLiq
Retorna os valores a receber do título, o mesmo do campo valor recebido na tela de baixas.
Alguns trechos desta rotina foram baseadas na rotina de baixa padrão
da tela de baixa.
@author Fabio Sales | www.compila.com.br
@since 27/08/2018
@version version
@param clTable , C , Tabela de parâmetro
@return nVal
@example alValLiq("SE1")
@see (links_or_references)
/*/

USER FUNCTION alSaldTit(clTable)

	Local nVal 			:= 0
	Local _cCodEmp 		:= ""
	Local _cCodFil		:= ""
	Local _cFilNew		:= ""	
	Local lPccBxCr		:= FPccBxCr()
	Local lIrPjBxCr		:= FIrPjBxCr()	//| Controla IRPJ na baixa
	
	Local lPCCBaixa := (cPaisLoc == "BRA") .And. (SuperGetMv("MV_BX10925",.T.,"2") == "1")
	Local lIRPFBaixa := .F.
	
	Local nTotAdto		:= 0
	Local nVlrBaixa		:= 0
	Local lBaixaAbat	:= .F.
	Local lBxCec		:= .F.	
	Local lBxLiq		:= .F.
	Local lTipBxCP		:= .F.	
	Local lSigaloja		:= .F.
	Local nTotMult		:= 0
	Local  dLastPcc	:= GETMV("AL_DTPCGSP",.F.,STOD("20181208")) //CTOD("22/06/2015")
	
	Default clTable		:= "SE1"
		
	PRIVATE lRaRtImp	:= FRaRtImp()	//| Define se ha retencao de impostos PCC/IRPJ no R.A
	PRIVATE nParciais	:= 0
	PRIVATE aBaixaSE5	:= {}
	
	lBQ10925 := SuperGetMV("MV_BQ10925",,"2") == "1" .And. !lRaRtImp




	
	IF clTable == "SE1" //| Calculo do Valor Líquido para campo customizado.
		
		/*---------------------------------------
			Realiza a TROCA DA FILIAL CORRENTE 
		-----------------------------------------*/
		
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= SE1->E1_FILIAL //| CODIGO DA FILIAL DE DESTINO
				
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF			
		
		
		
		nVal	:= xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,,2)
					
		IF nVal > 0
		
		
			nTotAbImp := 0
			
			nTxMoeda 	:= If(SE1->E1_MOEDA > 1, If(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA,RecMoeda(ddatabase,SE1->E1_MOEDA)),0)
			
			SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",ddatabase,@nTotAbImp,,,,,,SE1->E1_FILIAL, nTxMoeda)								
			
			If (SE1->E1_VALOR > SE1->E1_SALDO) .And. Empty(SE1->E1_TIPOLIQ)
				
				//| Procura pelas baixas deste titulo
	
				lTipBxCP:=lRaRtImp
				
				aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,@nTotAdto, @lBaixaAbat,SE1->E1_CLIENTE,SE1->E1_LOJA, @nVlrBaixa, , @lBxCec, @lBxLiq ,@lSigaloja, @lTipBxCP)
					
				For x := 1 To Len(aBaixaSE5)
				
					/*
						** aBaixaSE5 ** 
						
						SE5->E5_PREFIXO	
						cNumero			
						SE5->E5_PARCELA	
						SE5->E5_TIPO		 
						SE5->E5_CLIFOR	   
						SE5->E5_LOJA		
						SE5->E5_DATA		
						SE5->E5_VALOR	 
						SE5->E5_SEQ		   
						SE5->E5_DTDISPO	
						SE5->E5_BANCO	
						SE5->E5_AGENCIA	 
						SE5->E5_CONTA	   
						SE5->E5_VLJUROS	
						SE5->E5_VLMULTA	
						SE5->E5_VLDESCO	 
						SE5->E5_VLCORRE	
						SE5->E5_VRETPIS	
						SE5->E5_VRETCOF	
						SE5->E5_VRETCSL	 
						SE5->E5_PRETPIS	
						SE5->E5_PRETCOF	
						SE5->E5_PRETCSL	
						SE5->E5_MOEDA	 
						SE5->E5_TIPODOC	
						AllTrim(SE5->E5_FORMAPG) 
						cOrdRec			   
						cSerRec
						SE5->E5_MOTBX
						SE5->E5_VRETIRF
						SE5->E5_PRETIRF
						If(lRaRtImp, SE5->E5_PRISS,0), If(lRaRtImp, SE5->E5_PRINSS,0)} )					
					*/
				
				
					nParciais += aBaixaSE5[x][8]
					
		   			If lPccBxCR .And. lRaRtImp
		   			 
					   nParciais += aBaixaSE5[x][18]+aBaixaSE5[x][19]+aBaixaSE5[x][20]+aBaixaSE5[x][30]// somar impostos PCC
					    
					Elseif lIrPjBxCr .And. lRaRtImp
					  
				  		nParciais += aBaixaSE5[x][30]
				  	
					Endif  
					 
					nTotMult	 += (aBaixaSE5[x][14]+aBaixaSE5[x][15])  // Soma Acrescimo mais Multa
					   
					If lRaRtImp
					
				 		nParciais += aBaixaSE5[x][32]+aBaixaSE5[x][33]
				 		nTotAbat  -= aBaixaSE5[x][32]+aBaixaSE5[x][33]
				 		
					Endif
					
				Next
				
				nParciais += nTotAdto
				
				//| Soma valor de decrescimo em baixas parciais, para evitar
				//| diferencas entre valor original e valor recebido
				
				If SE1->E1_SDDECRE <> SE1->E1_DECRESC
					nParciais += ( SE1->E1_DECRESC - SE1->E1_SDDECRE )
				EndIf
				
			Else
				nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
			Endif	
			
			If "RA" $ SE1->E1_TIPO
				nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
			Endif	
			
			nVal := SE1->E1_VALOR -	nParciais														
			
			//|nValAbati	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL,,)
			
			nValDec		:= SE1->E1_SDDECRE		
			nValJuros	:= SE1->E1_SDACRES
			
			//| Simula o calculo do Pis, Cofins e cll como se fosse na baixa.
															
			If lPccBxCR .AND. nVal > 0 .AND.  ddatabase > dLastPcc .AND. SE1->E1_TIPO # MVRECANT
			
				aPcc	:= newMinPcc(ddatabase, nVal,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
				nPis	:= aPcc[2]
				nCofins	:= aPcc[3]
				nCsll	:= aPcc[4]
				
				//|nVal	:= nVal - (nPis + nCofins + nCsll)
				
				nPcc :=  nPis + nCofins + nCsll				
				
				nVal	:= SE1->E1_SALDO - nPcc 
				
			EndIf
			
			nVal := nVal - nValDec + nValJuros - nTotAbImp
			
		ELSE
			nVal := 0 //| Tratativas para quando campo E1_SALDO possui um valor negativo.
		ENDIF
		
	ELSEIF clTable == "SE2" //| Calculo do Valor Líquido para campo customizado.
	
	
		/*---------------------------------------
			Realiza a TROCA DA FILIAL CORRENTE 
		-----------------------------------------*/
		
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= SE2->E2_FILIAL //| CODIGO DA FILIAL DE DESTINO
				
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF		
	
		
		nVal	:= xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,,2)
					
		IF nVal > 0
		
		
			nTotAbImp := 0
			
			nTxMoeda 	:= If(SE2->E2_MOEDA > 1, If(SE2->E2_TXMOEDA > 0, SE2->E2_TXMOEDA,RecMoeda(ddatabase,SE2->E2_MOEDA)),0)
			
			SumAbatRec(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_MOEDA,"S",ddatabase,@nTotAbImp,,,,,,SE2->E2_FILIAL, nTxMoeda)								
			
			If (SE2->E2_VALOR > SE2->E2_SALDO) .And. Empty(SE2->E2_TIPOLIQ)
				
				//| Procura pelas baixas deste titulo
	
//				lTipBxCP:=lRaRtImp
				
				//aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,@nTotAdto, @lBaixaAbat,SE2->E2_CLIENTE,SE2->E2_LOJA, @nVlrBaixa, , @lBxCec, @lBxLiq ,@lSigaloja, @lTipBxCP)
				aBaixa := Sel080Baixa( "VL /BA /CP /"						,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,@nTotAdto, @lBaixaAbat,SE2->E2_FORNECE,SE2->E2_LOJA)
				For x := 1 To Len(aBaixaSE5)
				
					nParciais += aBaixaSE5[x][8]
					
		   			If lPCCBaixa //.And. lRaRtImp
		   			
		   				/*
		   				*** aBaixaSE5 *** 
						1 SE5->E5_PREFIXO
						2 SE5->E5_NUMERO
						3 SE5->E5_PARCELA
						4 SE5->E5_TIPO
						5 SE5->E5_CLIFOR
						6 SE5->E5_LOJA
						7 SE5->E5_DATA
						8 SE5->E5_VALOR
						9 SE5->E5_SEQ
						10 SE5->E5_DTDISPO
						11 SE5->E5_BANCO
						12 SE5->E5_AGENCIA
						13 SE5->E5_CONTA
						14 SE5->E5_DTDISPO
						15 SE5->E5_VRETPIS
						16 SE5->E5_VRETCOF
						17 SE5->E5_VRETCSL
						18 SE5->E5_PRETPIS
						19 SE5->E5_PRETCOF
						20 SE5->E5_PRETCSL
						21 SE5->E5_TIPODOC
						22 SE5->E5_VRETIRF
						23 SE5->E5_PRETIRF
						24 SE5->E5_VLDESCO
						25 SE5->E5_VLJUROS
						26 SE5->E5_VLMULTA
						27 SE5->E5_VRETINS
		   				*/
		   			 
					   nParciais += aBaixaSE5[x][15]+aBaixaSE5[x][16]+aBaixaSE5[x][17]+aBaixaSE5[x][22]// somar impostos PCC
					    
					Elseif lIRPFBaixa// .And. lRaRtImp
					  
				  		nParciais += aBaixaSE5[x][22]
				  	
					Endif  
					 
					nTotMult	 += (aBaixaSE5[x][14]+aBaixaSE5[x][15])  // Soma Acrescimo mais Multa
					   
//					If lRaRtImp
//					
//				 		nParciais += aBaixaSE5[x][32]+aBaixaSE5[x][33]
//				 		nTotAbat  -= aBaixaSE5[x][32]+aBaixaSE5[x][33]
//				 		
//					Endif
					
				Next
				
				nParciais += nTotAdto
				
				//| Soma valor de decrescimo em baixas parciais, para evitar
				//| diferencas entre valor original e valor recebido
				
				If SE2->E2_SDDECRE <> SE2->E2_DECRESC
					nParciais += ( SE2->E2_DECRESC - SE2->E2_SDDECRE )
				EndIf
				
			Else
				nParciais 	:= SE2->E2_VALOR-SE2->E2_SALDO
			Endif	
			
			If "PA" $ SE2->E2_TIPO
				nParciais 	:= SE2->E2_VALOR-SE2->E2_SALDO
			Endif	
			
			nVal := SE2->E2_VALOR -	nParciais														
			
			//|nValAbati	:= SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"R",1,,SE2->E2_CLIENTE,SE2->E2_LOJA,SE2->E2_FILIAL,,)
			
			nValDec		:= SE2->E2_SDDECRE		
			nValJuros	:= SE2->E2_SDACRES
			
			//| Simula o calculo do Pis, Cofins e cll como se fosse na baixa.
															
			If lPCCBaixa .AND. nVal > 0 .AND.  ddatabase > dLastPcc .AND. SE2->E2_TIPO # MVPAGANT
			
				aPcc	:= newMinPcc(ddatabase, nVal,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE+SE2->E2_LOJA)
				nPis	:= aPcc[2]
				nCofins	:= aPcc[3]
				nCsll	:= aPcc[4]
				
				//|nVal	:= nVal - (nPis + nCofins + nCsll)
				
				nPcc :=  nPis + nCofins + nCsll				
				
				nVal	:= SE2->E2_SALDO - nPcc 
				
			EndIf
			
			nVal := nVal - nValDec + nValJuros - nTotAbImp
			
		ELSE
			nVal := 0 //| Tratativas para quando campo E2_SALDO possui um valor negativo.
		ENDIF
	ENDIF

	/*---------------------------------------
		Restaura FILIAL  
	-----------------------------------------*/
	IF !EMPTY(_cFilNew)
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF 
	ENDIF		
		
Return(nVal)


/*/{Protheus.doc} ALGPBENE
Monta Json com os benefiários de acordo
com o parametros especificado
@author Fabio Sales
@since 07/10/2018
@param clParaJS , C , String no formato Json
@Return cRetJson, C, String no formato Json.
@version 1.0
/*/


User Function ALGPBENE(cParJson)

	Local cRetJson	:= ""
	Local oJson		:= Nil
	
	Default cParJson := ""
		
	cRetJson += '{"items": ['
		
	IF !EMPTY(cParJson)
				
		IF FWJsonDeserialize(cParJson,@oJson)
			
			IF Valtype(oJson:externalcode) == "A" 
			
				
				IF LEN(oJson:externalcode) > 0
				
					IF oJson:beneficiarytype == XCODGES_CLIENT 
					
						cRetJson += U_ALGPCLI(oJson:externalcode)
					
					ELSEIF oJson:beneficiarytype == XCODGES_PROVIDER 
						
						cRetJson += U_ALGPFOR(oJson:externalcode)
	
					ENDIF
					
				ENDIF
				
			ENDIF
									
		ENDIF
			
	ENDIF
	
	cRetJson += ']}'
	
Return(cRetJson)

/*/{Protheus.doc} ALGPCLI
Monta os dados dos clientes.
@author Fabio Sales
@since 07/10/2018
@param clParaJS , C , String no formato Json
@Return cRetJson, C, String no formato Json.
@version 1.0
/*/


USER FUNCTION ALGPCLI(oCliente)

	Local cRetJson 	:= ""
	Local nTotCli	:= 0
	Local nI		:= 0
		
	nTotCli	:= Len(oCliente)
	
	IF nTotCli > 0
		
		DBSELECTAREA("SA1")
		SA1->(DBSETORDER(1)) //| A1_COD + A1_LOJA + D_E_L_E_T_
		
		For nI := 1 To nTotCli
			
			IF SA1->(DBSEEK(XFILIAL("SA1") + oCliente[nI]))
				
				IF EMPTY(cRetJson)							
					cRetJson	+= "{"				
				ELSE				
					cRetJson	+= ",{"				
				ENDIF
								
				cRetJson += '"name":"' + Alltrim(SA1->A1_NOME) + '",'
				cRetJson += '"externalCode":"' + Alltrim(SA1->(A1_COD + A1_LOJA)) + '",'
				cRetJson += '"federalCode":"' + Alltrim(SA1->A1_CGC) + '",'
				cRetJson += '"beneficiaryType":"1"'
				
				cRetJson	+= "}"
			
			ENDIF		
		
		Next nI
			
	ENDIF
	
RETURN(cRetJson)



/*/{Protheus.doc} ALGPFOR
Monta os dados dos fornecedores.
@author Fabio Sales
@since 07/10/2018
@param clParaJS , C , String no formato Json
@Return cRetJson, C, String no formato Json.
@version 1.0
/*/


USER FUNCTION ALGPFOR(oFornece)

	Local cRetJson 	:= ""
	Local nTotCli	:= 0
	Local nI		:= 0
	
	nTotCli	:= Len(oFornece)
	
	IF nTotCli > 0
		
		DBSELECTAREA("SA2")
		SA2->(DBSETORDER(1)) //| A2_COD + A2_LOJA + D_E_L_E_T_
		
		For nI := 1 To nTotCli
			
			IF SA2->(DBSEEK(XFILIAL("SA2") + oFornece[nI]))
				
				IF EMPTY(cRetJson)							
					cRetJson	+= "{"				
				ELSE				
					cRetJson	+= ",{"				
				ENDIF
								
				cRetJson += '"name":"' + Alltrim(SA2->A2_NOME) + '",'
				cRetJson += '"externalCode":"' + Alltrim(SA2->(A2_COD + A2_LOJA)) + '",'
				cRetJson += '"federalCode":"' + Alltrim(SA2->A2_CGC) + '",'
				cRetJson += '"beneficiaryType":"3"'
				
				cRetJson	+= "}"
			
			ENDIF		
		
		Next nI
			
	ENDIF
	
RETURN(cRetJson)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RemovCharºAutor  ³ Augusto Ribeiro	 º Data ³  08/06/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Remove caracter especial                                   ±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
STATIC Function RemovChar(cRet)
	Local cRet

	cRet	:= upper(cRet)
	
	cRet	:= STRTRAN(cRet,"Ã‡","C")
	cRet	:= STRTRAN(cRet,"ÃÂÂÇÍ","C")
	cRet	:= STRTRAN(cRet,"ÂÆÆ","")
	cRet	:= STRTRAN(cRet,"Á","A")
	cRet	:= STRTRAN(cRet,"É","E")
	cRet	:= STRTRAN(cRet,"Í","I")
	cRet	:= STRTRAN(cRet,"Ó","O")
	cRet	:= STRTRAN(cRet,"Ú","U")
	cRet	:= STRTRAN(cRet,"À","A")
	cRet	:= STRTRAN(cRet,"È","E")
	cRet	:= STRTRAN(cRet,"Ì","I")
	cRet	:= STRTRAN(cRet,"Ò","O")
	cRet	:= STRTRAN(cRet,"Ù","U")
	cRet	:= STRTRAN(cRet,"Ã","A")
	cRet	:= STRTRAN(cRet,"Õ","O")
	cRet	:= STRTRAN(cRet,"Ä","A")
	cRet	:= STRTRAN(cRet,"Ë","E")
	cRet	:= STRTRAN(cRet,"Ï","I")
	cRet	:= STRTRAN(cRet,"Ö","O")
	cRet	:= STRTRAN(cRet,"Ü","U")
	cRet	:= STRTRAN(cRet,"Â","A")
	cRet	:= STRTRAN(cRet,"Ê","E")
	cRet	:= STRTRAN(cRet,"Î","I")
	cRet	:= STRTRAN(cRet,"Ô","O")
	cRet	:= STRTRAN(cRet,"Û","U")
	cRet	:= STRTRAN(cRet,"Ç","C")
	cRet	:= STRTRAN(cRet,"º"," ")
	cRet	:= STRTRAN(cRet,"-","")
	cRet	:= STRTRAN(cRet,".","")
	cRet	:= STRTRAN(cRet,"R$","")
	cRet	:= STRTRAN(cRet,"NULL","")
	cRet	:= STRTRAN(cRet,"ƒ","")
	cRet	:= STRTRAN(cRet,"^M","")




Return(cRet)






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



/*/{Protheus.doc} zMotBaixa
Motivos de baixa
@author Jonatas Oliveira | www.compila.com.br
@since 26/03/2018
@version 1.0
/*/
User Function zMotBaixa()
	Local aArea     := GetArea()
	Local aMotBx    := {}
	Local aBaixaAtu := {}
	Local aRet 		:= {}
		
	aMotBx := ReadMotBx()
		
	For nI := 1 To Len(aMotBx)		
		aBaixaAtu := StrTokArr(aMotBx[nI], '³')
		
		AADD(aRet, {ALLTRIM(aBaixaAtu[1]),ALLTRIM(aBaixaAtu[2]) })
	Next nI 
	
	RestArea(aArea)
Return(aRet)





/*/{Protheus.doc} ALGSPJOB
Executa consulta nos lançamentos financeiros e grava na tabela Z08
@author Augusto Ribeiro | www.compila.com.br
@since 18/06/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function ALGSPJOB(aParam)
Local aRet			:= {.F., ""}
Local cQuery		:= ""
Local nI, _cEmp, _cFilial
Local lProcFalha	:= .F.
Local cJsonAux
Local cSemaf, nHSemafaro

Default aParam	:= {"01","00101MG0001"}

IF !empty(aParam)
	_cEmp		:= aParam[1]
	_cFilial	:= aParam[2]
	
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
	
	/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
		Abre semaforo de Processamento
	------------------------------------------------------------------------------------------*/	
	cSemaf		:= "ALGSPJOB"
	nHSemafaro	:= U_CPXSEMAF("A", cSemaf)
	
	IF nHSemafaro > 0	
		
		/*--------------------------
			CASHPOSTING
		---------------------------*/
		BEGIN TRANSACTION
	
		cJsonAux	:= U_ALGPINTE(1)
		IF !EMPTY(cJsonAux)
			U_cpLogAPI("CASHPOSTING", cJsonAux)
		ENDIF
			
		END TRANSACTION
		
		
		/*--------------------------
			FINANCIALOPENNESS
		---------------------------*/
		BEGIN TRANSACTION
		
		cJsonAux	:= U_ALGPINTE(2)
		IF !EMPTY(cJsonAux)
			U_cpLogAPI("FINANCIALOPENNESS", cJsonAux)
		ENDIF
			
		END TRANSACTION	
		
		
		/*--------------------------
			ACCOUNTINGOPENNESS
		---------------------------*/
		BEGIN TRANSACTION
		
		cJsonAux	:= U_ALGPINTE(3)
		IF !EMPTY(cJsonAux)
			U_cpLogAPI("ACCOUNTINGOPENNESS", cJsonAux)
		ENDIF			
		
		END TRANSACTION	
		
		/*--------------------------
		FECHA SEMAFORO
		---------------------------*/
		U_CPXSEMAF("F", cSemaf,nHSemafaro)
	ELSE
		
	ENDIF				

	RESET ENVIRONMENT
ELSE
	
ENDIF

	

	
Return(aRet)



/*/{Protheus.doc} ALRETZ08
Gravar registros na tabela de LOG Z08
@author Augusto Ribeiro | www.compila.com.br
@since 18/06/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function ALRETZ08(nOpc)
Local cQuery	:= ""
Local cRet		:= '{"items": []}'
Local cAPI	:= "" 


IF nOpc == 1
	cAPI := 'CASHPOSTING'
ELSEIF nOpc == 2
	cAPI := 'FINANCIALOPENNESS'
ELSEIF nOpc == 3
	cAPI := 'ACCOUNTINGOPENNESS'
ENDIF

IF !EMPTY(cAPI)
	DBSELECTAREA("Z08")
	DBSETORDER(2)
	IF Z08->(DBSEEK("1"+cAPI,.F.))
		
		cRet	:= Z08->Z08_RETJSO
		
		RecLock("Z08",.F.)
			Z08->Z08_DTAPI	:= DATE()
			Z08->Z08_HRAPI	:= TIME()	
			Z08->Z08_STATUS	:= "2"
		MSUNLOCK()
	
		//TSQL->(DBSKIP()) 
	ENDIF	
ENDIF


Return(cRet)






