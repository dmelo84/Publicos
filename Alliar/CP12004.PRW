#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"  
#INCLUDE 'TBICONN.CH'    


/*/{Protheus.doc} CP12004
Funcao para trabamento do JSON e chamada da funcao de integracao 
@author Augusto Ribeiro | www.compila.com.br
@since 16/03/2018
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function CPTESTE()
	
	PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01702BA0001' MODULO 'FAT'	
	
	// --Contas a Receber RA testado.
		
		//|clteste:= '{"EMP": "01","FILIAL": "01",	"TABELA": "SE1",	"SISTEMA": "GESPLAN",	"OPERACAO": "I",	"CABEC": {		"E1_FILIAL": "01",		"E1_PREFIXO": "FAB",		"E1_NUM": "249974",    "E1_TIPO": "RA",    "E1_NATUREZ": "1040",    "E1_VENCTO": "20180330", "E1_VENCORI": "20180330",    "E1_EMISSAO": "20180330","CNPJ":"59109017006599",				"E1_VALOR": 10.73,		"AUTBANCO": "341",		"AUTAGENCIA": "0190 ",		"AUTCONTA": "404905    ",		"E1_CCUSTO": "13054",		"E1_HIST": "TESTES"	}}'
	
	//--Contas a Receber Nomral Testado.
	
		//|clteste:= '{"EMP": "01","FILIAL": "01",	"TABELA": "SE1",	"SISTEMA": "GESPLAN",	"OPERACAO": "I",	"CABEC": {		"E1_FILIAL": "01",		"E1_PREFIXO": "FAB",		"E1_NUM": "249974",    "E1_TIPO": "NF",    "E1_NATUREZ": "1040",    "E1_VENCTO": "20180330", "E1_VENCORI": "20180330",    "E1_EMISSAO": "20180330","CNPJ":"59109017006599",				"E1_VALOR": 10.73,		"AUTBANCO": "341",		"AUTAGENCIA": "0190",		"AUTCONTA": "404905",		"E1_CCUSTO": "13054",		"E1_HIST": "TESTES"	}}'
		
		clteste:= '{"EMP":"01","FILIAL":"00101MG0001","TABELA":"SE2","SISTEMA":"GESPLAN","OPERACAO":"I","CABEC":{"E2_FILIAL":"00101MG0001","E2_CLIENTE":"09022249","E2_LOJA":"0001","CNPJ":"09022249000172","E2_TIPO":"RA","E2_VALOR":10.73,"E2_VENCTO":"20181220","AUTBANCO":"341","AUTAGENCIA":"0135","AUTCONTA":"43056","E2_NUM":"249961","E2_CCUSTO":"90101","E2_HIST":"TESTES","E2_XGESPL":"12764363"}}'
	//--Contas a pagar PA Testado.
	
		//|clteste:='{	"EMP": "01",	"FILIAL": "01",	"TABELA": "SE2",	"SISTEMA": "GESPLAN",	"OPERACAO": "I",	"CABEC": {		"E2_FILIAL": "01",		"E2_PREFIXO": "BOL",		"E2_NUM": "249973",		"E2_TIPO": "PA",		"E2_NATUREZ": "1040",		"AUTBANCO": "341",		"AUTAGENCIA": "0641",		"AUTCONTA": "748140","CNPJ":"01733265000161",		"E2_EMISSAO": "20180330",		"E2_VENCTO": "20180330",		"E2_VALOR": 10.73,		"E2_CCUSTO": "13054",		"E2_HIST": "TESTES"	}}'
		
	//--Contas a pagar normal Testado.
	
		//|clteste:='{	"EMP": "01",	"FILIAL": "01",	"TABELA": "SE2",	"SISTEMA": "GESPLAN",	"OPERACAO": "I",	"CABEC": {		"E2_FILIAL": "01",		"E2_PREFIXO": "BOL",		"E2_NUM": "249973",		"E2_TIPO": "NF",		"E2_NATUREZ": "1040",		"AUTBANCO": "341",		"AUTAGENCIA": "0641",		"AUTCONTA": "748140","CNPJ":"01733265000161",		"E2_EMISSAO": "20180318",		"E2_VENCTO": "20180318",		"E2_VALOR": 10.73,		"E2_CCUSTO": "13054",		"E2_HIST": "TESTES"	}}'
		

	/// clteste:='{"EMP": "01","FILIAL": "01702BA0001","TABELA": "SZD","SISTEMA": "GESPLAN","OPERACAO": "INSERT","CABEC": {"ZD_IDTRAN": "201712056001000032","ZD_STATUS": "1","ZD_LOTE": "TESTE","ZD_SUBLOTE": "TESTE-01","ZD_DOCTO": "FSALES","ZD_DTINC": "20180331","ZD_HRINC": "10:00:00"},"ITENS": [{"ZC_DTLANC": "20180331","ZC_TIPO": "3","ZC_CTADEB": "4202010004","ZC_CTACRD": "2101020001","ZC_CCD": "90101","ZC_CCC": "","ZC_VALOR": 1000,"ZC_HIST": "TESTANDO APLICAÇÃO 1","ZC_IDSEN": "1","ZC_IDTRAN ": "201712056001000032"},{"ZC_DTLANC": "20180331","ZC_TIPO": "3","ZC_CTADEB": "4202010004","ZC_CTACRD": "2101020001","ZC_CCD": "90101","ZC_CCC": "","ZC_VALOR": 1000,"ZC_HIST": "TESTANDO APLICAÇÃO 2","ZC_IDSEN": "2","ZC_IDTRAN ": "201712056001000032"},{"ZC_DTLANC": "20180331","ZC_TIPO": "3", "ZC_CTADEB": "4202010004", "ZC_CTACRD": "2101020001", "ZC_CCD": "90101", "ZC_CCC": "","ZC_VALOR": 1000,"ZC_HIST": "TESTANDO APLICAÇÃO 3","ZC_IDSEN": "3","ZC_IDTRAN ": "201712056001000032"}]}'
	//clteste:=' {"EMP":"00101","FILIAL":"00101MG0001","TABELA":"SE2","SISTEMA":"GESPLAN","OPERACAO":"D","CABEC":{"CNPJ":"49925225000148","E2_NUM":"24630","E2_PARCELA":"44/51","E2_TIPO":"PA","E2_VALOR":42359.0,"E2_VENCTO":"20180515","AUTBANCO":"341","AUTAGENCIA":"7475","AUTCONTA":"05722","E2_CCUSTO":"","E2_HIST":"Juros Pago","E2_XGESPL":"24630:15052018"}} '
//	clteste := ' {   "EMP": "00101","FILIAL": "00101MG0001","TABELA": "SE1","SISTEMA": "GESPLAN","OPERACAO": "D","CABEC": {"CNPJ": "09863853000717","E1_NUM": "246301","E1_PARCELA": "","E1_TIPO": "EMP","E1_VALOR": 50000.0,"E1_VENCTO": "20181110","E1_EMISSAO": "20181031","E1_CCUSTO": "","E1_NATUREZ": "23050002","E1_HIST": "Principal CP","E1_XGESPL": "229999"}}'		
		
	U_CP12W2D(clteste)
	
	//|u_LerSM0()
	
	RESET ENVIRONMENT

Return()

/*/{Protheus.doc} CP12004
Função para exclusão ou Manutenção de título. 
@author Fabio Sales | www.compila.com.br
@since 16/03/2018
@version 1
@param clTable	,C, Table.
@param Aldados	,A, Dados dos títulos.
@param nlOpc	,A, Opção(Inclusão, alteração ou exclusão).
@param clFil	,A, Filial.
@return aRet	,A, aRet[1] Contém False or True.
@return aRet	,A, aRet[2] Mensagem de erro. 
@return aRet	,A, aRet[3] Chave do Registro.
@example
(examples)
@see (www.compila.com.br)
/*/

USER FUNCTION CP12004A(clTable,alTitulo,clOpc,clFil)
Local aRet	:= {.f.,"",""}
Local _cCodEmp	
Local _cCodFil
Local _cFilNew	
Local clpre		:= ""
Local clNum		:= ""
Local cltipo	:= ""
Local clPar		:= ""
Local clCli		:= ""
Local clLoj		:= ""
Local nAscan	:= 0	
Local clSufTab	:= Right(Alltrim(clTable),2)
Local alArea	:= GetArea()
Local alFields	:= {}
Local nlOpc		:= 0
Local nI		:= 0
Local nJ		:= 0
Local Aldados	:= {}
Local cidGesp	:= ""
lOCAL nRecSE	:= 0
Local nPosEms	:= 0 
Local nPosVenc	:= 0 
Local nRatNat	:= 0

Default clOpc := "I" 

//| Faz o De/Para da operação.

IF clOpc =="I"
	nlOpc := 3
ELSEIF clOpc =="U"
	nlOpc	:= 4
ELSEIF clOpc =="D"
	nlOpc	:= 5
END		

/*-------------------------------------------------------------------------\
| Faz as tratativas para o Jsons que não tenha os campos de código e Loja  |
| do Cliente/Fornecedor.                                                   |
\-------------------------------------------------------------------------*/

For nJ := 1 To Len(alTitulo)
							
	IF ALLTRIM(alTitulo[nJ,1]) == "CNPJ"
									
		IF clTable == "SE1"
			DBSELECTAREA("SA1")
			SA1->(DBSETORDER(3)) //| A1_FILIAL, A1_CGC, R_E_C_N_O_, D_E_L_E_T_
			IF DBSEEK(XFILIAL("SA1") + alTitulo[nJ,2] )			
				AADD(Aldados,{"E1_CLIENTE"	,SA1->A1_COD	,Nil})
				AADD(Aldados,{"E1_LOJA"		,SA1->A1_LOJA	,Nil})
			else
				aRet[2]	:= "Cliente não localizado"
			ENDIF								
		ELSE
			DBSELECTAREA("SA2")
			SA2->(DBSETORDER(3)) //| A2_FILIAL, A2_CGC, R_E_C_N_O_, D_E_L_E_T_
			IF DBSEEK(XFILIAL("SA2") + alTitulo[nJ,2] )
				AADD(Aldados,{"E2_FORNECE"	,SA2->A2_COD	,Nil})
				AADD(Aldados,{"E2_LOJA"		,SA2->A2_LOJA	,Nil})
			ELSE
				aRet[2]	:= "Fornecedor não localizado"			
			ENDIF
			
		ENDIF								
	
	ELSE
	
		IF alTitulo[nJ,1] == "RATEIO_NATUREZA"
			nRatNat	:= nJ
		ELSE
			AADD(Aldados,alTitulo[nJ])
		ENDIF
	ENDIF
Next nJ		
				
//| Realiza o De/Para de campos para a tabela SE1.

IF clTable == "SE1" //| Contas a Receber.
	
	//|Array com campos de De/para quando a tabela for SE1.
	/* 
	//| Removido pois gesplan não utiliza |
	aadd(alFields,{"AUTBANCO"	,"E1_PORTADO"	})
	aadd(alFields,{"AUTAGENCIA"	,"E1_AGEDEP"	})
	aadd(alFields,{"AUTCONTA"	,"E1_CONTA"		})	
	*/
	For nI := 1 to Len(alFields)
	
		nScan := Ascan(Aldados,{|x| x[1] == alFields[nI,1]})
		
		IF nScan > 0
		
			Aldados[nScan,1] := alFields[nI,2]
			  
		ENDIF
		
	Next nI
	
ENDIF		

nScan := Ascan(Aldados,{|x| x[1] == clSufTab + "_XGESPL"})		
IF nScan > 0		
	cidGesp				:= alltrim(Aldados[nScan,2])		
	Aldados[nScan,2]	:= cidGesp
ENDIF	

/*--------------------------
	Verifica ID Gesplan
---------------------------*/
IF EMPTY(cidGesp)	
	aRet[2]	:= "IdGesplan não informado"
ELSE
	

	/*--------------------------
		Verifica se o ID já existe na base
	---------------------------*/
	DBSELECTAREA(clTable)
	DbOrderNickName("IDGESPLAN") // E1_FILIAL+E1_XGESPL
	IF DBSEEK(AVKEY(clFil, "E1_FILIAL")+cidGesp) 
		nRecSE	:= RECNO()
	ENDIF		
	
	IF nlOpc == 3 .AND. !EMPTY(nRecSE)
		aRet[2]	:= "Movimento não pode ser inserido. ID Gesplan ["+cidGesp+"] ja existe na base"
	ELSEIF nlOpc == 5 .AND. EMPTY(nRecSE)
		aRet[2]	:= "Movimento não pode ser excluido. ID Gesplan ["+cidGesp+"] não localizado."
	ENDIF	
				
ENDIF


IF EMPTY(aRet[2])
		
	/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE 
	-----------------------------------------*/
	
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	_cFilNew	:= clFil //| CODIGO DA FILIAL DE DESTINO 
	
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
	ENDIF	


	/*------------------------------------------------------ Augusto Ribeiro | 27/04/2018 - 11:07:38 AM
		EXCLUSAO
	------------------------------------------------------------------------------------------*/
	IF nlOpc == 5
	
		DBSELECTAREA(clTable)
		DBSETORDER(1)
		DBGOTO(nRecSE)
		
		
		Aldados	:= {}
		AADD(Aldados, {clSufTab+"_FILIAL", FIELDGET(FIELDPOS(clSufTab+"_FILIAL")), NIL})
		AADD(Aldados, {clSufTab+"_PREFIXO", FIELDGET(FIELDPOS(clSufTab+"_PREFIXO")), NIL})
		AADD(Aldados, {clSufTab+"_NUM", FIELDGET(FIELDPOS(clSufTab+"_NUM")), NIL})
		AADD(Aldados, {clSufTab+"_PARCELA", FIELDGET(FIELDPOS(clSufTab+"_PARCELA")), NIL})
		AADD(Aldados, {clSufTab+"_TIPO", FIELDGET(FIELDPOS(clSufTab+"_TIPO")), NIL})
		IF clTable == "SE1"
			AADD(Aldados, {clSufTab+"_CLIENTE", FIELDGET(FIELDPOS(clSufTab+"_CLIENTE")), NIL})
		ELSE
			AADD(Aldados, {clSufTab+"_FORNECE", FIELDGET(FIELDPOS(clSufTab+"_FORNECE")), NIL})
		ENDIF
		AADD(Aldados, {clSufTab+"_LOJA", FIELDGET(FIELDPOS(clSufTab+"_LOJA")), NIL})
		
		
		lMsErroAuto	:= .f.		
		IF clTable == "SE1" 
			MSExecAuto({|x,y,z| Fina040(x,y,z)},Aldados,nlOpc)
		ELSE		
			MSExecAuto({|x,y,z| Fina050(x,y,z)},Aldados,,nlOpc)
		ENDIF
			
		
		
		If lMsErroAuto		
			cAutoLog	:= alltrim(NOMEAUTOLOG())
	
			cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
			cMemo := STRTRAN(cMemo,"'","")
	
			//| Apaga arquivo de Log
			
			Ferase(cAutoLog)
			
			//| Le Log da Execauto e retorna mensagem amigavel ³
			
			aRet[1]	:= .F.
			aRet[2] := U_CPXERRO(cMemo)
			
			IF EMPTY(aRet[2])
				aRet[2]	:= alltrim(cMemo)
			ENDIF	
		ELSE
			aRet[1]	:= .T.	
			IF clTable=="SE1"
				aRet[3]	:= SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
			ELSE
				aRet[3]	:= SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)					
			ENDIF					
		ENDIF			
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 27/04/2018 - 11:07:43 AM
		INCLUSAO
	------------------------------------------------------------------------------------------*/
	ELSEIF  nlOpc == 3 

			
		//| Obtém o prefixo.
		nScan := Ascan(Aldados,{|x| x[1] == clSufTab + "_PREFIXO"})
		clpre:= "GSP"
		IF nScan > 0		
			Aldados[nScan,2]	:= clpre
		ELSE
			AADD(Aldados, {clSufTab+"_PREFIXO",clpre, NIL })
		ENDIF			
		
		//| Obtém o numero do titulo
		nScan := Ascan(Aldados,{|x| x[1] == clSufTab + "_NUM"})		
		IF nScan > 0		
			clNum	:= ALLTRIM(Aldados[nScan,2])	
			clNum	:= PADL(clNum, TAMSX3(clSufTab + "_NUM")[1],"0")
			Aldados[nScan,2]	:= clNum	 
		ENDIF
		
		//| Obtém O tipo do título				
		nScan := Ascan(Aldados,{|x| x[1] == clSufTab + "_TIPO"})
		cltipo	:= "EMP"		
		IF nScan > 0		
		 	Aldados[nScan,2]	:= cltipo
		ELSE
			AADD(Aldados, {clSufTab+"_TIPO",cltipo, NIL })
								 
		ENDIF
		
		//|Obtém A parcela.			
		nScan := Ascan(Aldados,{|x| x[1] == clSufTab + "_PARCELA"})		
		IF nScan > 0		
			clPar	:= ALLTRIM(Aldados[nScan,2])		
			nPosAUX	:= 	AT("/",clPar)		
			IF nPosAUX > 0
				clPar	:= LEFT(clPar, nPosAUX-1)
			ENDIF 
			
			Aldados[nScan,2]	:= clPar
		ENDIF
		
		//| Obtém a parcela.				
		nScan := Ascan(Aldados,{|x| x[1] == clSufTab + "_LOJA"})		
		IF nScan > 0		
			cidGesp:= Aldados[nScan,2]			 
		ENDIF	
		
		
		nScan := Ascan(Aldados,{|x| x[1] == clSufTab + "_HIST"})		
		IF nScan > 0		
			Aldados[nScan,2]	:= 	UPPER(fwnoaccent(ALLTRIM(Aldados[nScan,2])))		 
		ENDIF		
		
		
		//| Adequa o campo de acordo com o tamanho pardrão.
		
		clpre 	:= AVKEY(clpre	,clSufTab + "_PREFIXO")
		clNum 	:= AVKEY(clNum	,clSufTab + "_NUM")
		cltipo	:= AVKEY(cltipo	,clSufTab + "_TIPO")
		clPar 	:= AVKEY(clPar	,clSufTab + "_PARCELA")
		clLoj 	:= AVKEY(clLoj	,clSufTab + "_LOJA")				
		cidGesp := AVKEY(clLoj	,clSufTab + "_XGESPL")
		
	
		nPosEms		:= Ascan(Aldados,{|x| x[1] == clSufTab + "_EMISSAO"})
		nPosVenc	:= Ascan(Aldados,{|x| x[1] == clSufTab + "_VENCTO"})
		
		
		/*----------------------------------------
			31/10/2018 - Jonatas Oliveira - Compila
			Verifica se Vencimento é menor que a 
			Emissão
		------------------------------------------*/
		IF nPosEms > 0 .AND. nPosVenc > 0 
			IF Aldados[nPosVenc][2] < Aldados[nPosEms][2]
				Aldados[nPosEms][2] := Aldados[nPosVenc][2]
			ENDIF 
		ENDIF 
		
		lMsErroAuto	:= .F.
		
		IF clTable == "SE2"
		
			nScan := Ascan(Aldados,{|x| x[1] == clSufTab + "_FORNECE"})		
			IF nScan > 0		
				clCli:= Aldados[nScan,2]			 
			ENDIF		
			
			clCli := AVKEY(clCli	,clSufTab + "_FORNECE")
			
			//| Verifica se o titulo existe.
			
			DBSELECTAREA("SE2")
			SE2->(DBSETORDER(1)) //| E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_			
					
			IF !SE2->(DBSEEK(XFILIAL("SE2")+clpre+clNum+clPar+clTipo+clCli+clLoj)) .OR. nlOpc <> 3
				MSExecAuto({|x,y,z| Fina050(x,y,z)},Aldados,,nlOpc)
			ELSE
				 aRet[1]:= .F.
				 aRet[2]:= "Título já existente no contas a pagar: Chave["+ XFILIAL("SE2") + clpre + clNum + clPar + clTipo + clCli + clLoj +"]"
			ENDIF
			
		ELSEIF clTable=="SE1"
		
			nScan := Ascan(Aldados,{|x| x[1] == clSufTab + "_CLIENTE"})		
			IF nScan > 0		
				clCli:= Aldados[nScan,2]			 
			ENDIF
			
			clCli := AVKEY(clCli	,clSufTab + "_CLIENTE")
			
			//| Verifica se o titulo existe.
			
			DBSELECTAREA("SE1")
			SE1->(DBSETORDER(1)) //| E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
					
			IF !SE1->(DBSEEK(XFILIAL("SE1")+clpre+clNum+clPar+clTipo)) .OR. nlOpc <> 3
				MSExecAuto({|x,y,z| Fina040(x,y,z)},Aldados,,nlOpc)
			ELSE
				 aRet[1]:= .F.
				 aRet[2]:= "Título já existente no contas a Receber: Chave["+ XFILIAL("SE1") + clpre + clNum + clPar + clTipo +"]"
			ENDIF
			
		ENDIF		
	
		If lMsErroAuto //.AND. aRet[2]
	
			cAutoLog	:= alltrim(NOMEAUTOLOG())
	
			cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
			cMemo := STRTRAN(cMemo,"'","")
	
			//| Apaga arquivo de Log
			
			Ferase(cAutoLog)
			
			//| Le Log da Execauto e retorna mensagem amigavel ³
			
			aRet[1]	:= .F.
			aRet[2] := U_CPXERRO(cMemo)
			
			IF EMPTY(aRet[2])
				aRet[2]	:= alltrim(cMemo)
			ENDIF
			
		ELSE
			aRet[1]	:= .T.
						
			IF clTable=="SE1"
				aRet[3]	:= SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
			ELSE
				aRet[3]	:= SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)					
			ENDIF
		EndIf
		
		/*---------------------------------------
			Restaura FILIAL  
		-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF 
	ENDIF
ENDIF
	
RestArea(alArea)
	
Return(aRet)


/*/{Protheus.doc} CP12004
Função para inclusão e exclusão de dados na entidade contábil. 
@author Fabio Sales | www.compila.com.br
@since 30/03/2018
@version 1
@param clTable	,C, Table.
@param alCabec	,A, Dados do cabeçalho da entidade contábil.
@param aItens	,A, Dados dos Itens do cabeçalho.
@param nlOpc	,A, Opção(Inclusão, alteração ou exclusão).
@param clFil	,A, Filial.
@return aRet	,A, aRet[1] Contém False or True.
@return aRet	,A, aRet[2] Mensagem de erro.
@return aRet	,A, aRet[3] Chave do Registro. 
@example
(examples)
@see (www.compila.com.br)
/*/

USER FUNCTION CP12004B(clTable,aCabec,aItens,clOpc,clFil)

Local aRet		:= {.F.,"Erro indeterminado",""}
Local nIDTRAN	:=  TamSX3("ZD_IDTRAN")[1]	
Local nPosID	:=  Ascan(aCabec,{|x| x[1] == "ZD_IDTRAN"})
Local nIDSEN	:= 	TamSX3("ZC_IDSEN")[1]
Local aObriga	:= {}
Local cIdTran	:= ""  
Local cMsgErro	:= ""
Local _cCodEmp 	:= ""
Local _cCodFil	:= ""
Local _cFilNew	:= "" 

Default clOpc	:= ""
Default aCabec	:= {}
Default aItens	:= {}
Default clFil	:= ""
Default clTable	:= ""
	
IF Len(aCabec) > 0 .AND. Len (aItens) > 0 .AND. !EMPTY(clOpc) .AND. !EMPTY(clFil) .AND. !EMPTY(clTable) //|valida se os dados principais estão preenchidos.
	
		
	nScan := Ascan(aCabec,{|x| x[1] == "ZD_FILIAL"})		
	IF nScan > 0		
		aCabec[nScan,2]	:= 	clFil	
	ELSE
		AADD(aCabec,{"ZD_FILIAL",clFil,Nil}) //| Adciona a filial no Cabeçalho.
	ENDIF
	AADD(aCabec,{"ZD_SISTEMA","2",Nil}) //| 2=Gesplan
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 01/05/2018 - 6:10:20 PM
		Verifica se filial esta ativa
	------------------------------------------------------------------------------------------*/
	DBSELECTAREA("SZK")
	SZK->(DBSETORDER(1)) //| 
	IF SZK->(DBSEEK("01"+clFil))
		IF SZK->ZK_MSBLQL == "1"
			cMsgErro	:= "Filial bloqueada. ["+clFil+"] SZK"
		ENDIF
	ELSE 
		cMsgErro	:= "Filial não localizada ["+clFil+"]"
	ENDIF
	
	
	if empty(cMsgErro)
		
		
		/*--------------------------
			Campos obrigatórios
		---------------------------*/		
		aadd(aObriga, "ZC_IDSEN")
		aadd(aObriga, "ZC_DTLANC")
		aadd(aObriga, "ZC_TIPO")
		aadd(aObriga, "ZC_VALOR")
		
		nObriga	:= LEN(aObriga)
		
		IF nPosID > 0
			cIdTran		:= PADR(aCabec[nPosID,2], nIDTRAN) //| ID da Transação.				
		ENDIF    
						
		IF clOpc == "I" .OR. clOpc == "D"
				 
			nQtdReg	:= Len(aItens)
									
			DbSelectArea(clTable)
			SZD->(DbSetOrder(1))	//| ZD_FILIAL, ZD_IDTRAN	
			
			//| Valida Inclusão | Exclusão.
							
			If clOpc == "I"											
				
				If SZD->(DbSeek(AVKEY(clFil	,"ZD_FILIAL") + cIdTran))					
					cMsgErro	:= "Registro já existe STATUS ["+alltrim(X3COMBO("ZD_STATUS", SZD->ZD_STATUS ))+"]"+CRLF
				ENDIF
				
			ELSEIF clOpc == "D"				
								
				If SZD->(DbSeek(AVKEY(clFil	,"ZD_FILIAL") + cIdTran))
					IF SZD->ZD_STATUS <> "1"												
						cMsgErro	:= "Exclusão permitida STATUS ["+alltrim(X3COMBO("ZD_STATUS", SZD->ZD_STATUS ))+"]"+CRLF
					ENDIF
				ENDIF
				
			ENDIF
				
			IF EMPTY(cMsgErro) //| Verifica se existe alguma inconsistência.
																													
				IF clOpc == "I"
				
					nQtdReg	:= Len(aItens)
					
					FOR nI := 1 to nQtdReg
					
						/*------------------------------------------------------ Augusto Ribeiro | 05/04/2018 - 5:50:50 PM
							Alimenta campos adicionais
						------------------------------------------------------------------------------------------*/
						AADD(aItens[nI],{"ZC_FILIAL",clFil,Nil}) //| Adciono a filial no Array dos itens
						AADD(aItens[nI],{"ZC_IDTRAN",cIdTran,Nil}) //| Id Transacao
					
						nPosIdSen :=  Ascan(aItens[nI],{|x| x[1] == "ZC_IDSEN"})
						
						IF nPosIdSen > 0
							cIDSen	:= aItens[nI,nPosIdSen,2]
						ELSE
							cIDSen	:= ""
						ENDIF
						
						nPosAux :=  Ascan(aItens[nI],{|x| x[1] == "ZC_HIST"})
						IF nPosAux > 0
							aItens[nI,nPosAux,2]	:= UPPER(RemovChar(ALLTRIM( aItens[nI,nPosAux,2] )))	
						ENDIF
						
																																							
						IF !EMPTY(cIDSen)
						
							DbSelectArea("SZC")
							SZC->(DbSetOrder(1)) //| ZC_FILIAL, ZC_IDTRAN, ZC_IDSEN
							
							IF SZC->(DbSeek(AVKEY(clFil	,"ZC_FILIAL") + cIdTran + PADR(cIDSen,nIDSEN) ))
								IF clOpc == "I"
									cMsgErro	+=  "["+cIDSen+"] Registro informado já existe."+CRLF
								ENDIF
							ENDIF
							
							//| Valida campos obrigatórios.
							
							FOR nY := 1 to nObriga					
								nPosAux	:= aScan(aItens[nI], { |x| AllTrim(x[1]) == aObriga[nY] })
								IF nPosAux	> 0
									IF EMPTY(aItens[nI,nPosAux,2])
										cMsgErro	+= "["+cIDSen+"] Campo Obrigatorio vazio ["+aObriga[nY]+"]"+CRLF
									ENDIF								
								ELSE
									cMsgErro	+= "["+cIDSen+"] Campo Obrigatorio vazio ou nao informado ["+aObriga[nY]+"]"+CRLF									
								ENDIF
							NEXT nY
						ELSE
							cMsgErro	+= "[ZC_IDSEN] Vazio."+CRLF 
						ENDIF												
					NEXT nI
				ENDIF									
		
			ENDIF					
		
		ELSE			
			cMsgErro := "Operação inválida: CP12004B"
		ENDIF 
	ENDIF
	
ELSE			
	cMsgErro := "Cabecalho ou itens vazios: CP12004B"
ENDIF

//| Verifica se ocorreu algum erro.

IF EMPTY(cMsgErro)	

	/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE 
	-----------------------------------------*/
	
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	_cFilNew	:= clFil //| CODIGO DA FILIAL DE DESTINO 
	
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
	ENDIF				

	/*--------------------------
		INCLUSAO
	---------------------------*/
	IF clOpc == "I"
	
		
		BEGIN TRANSACTION 
		
			RegToMemory("SZD", .T., .F.)
		
			//| Cabec
			DBSELECTAREA("SZD")
			RECLOCK("SZD",.T.)
			
				nTotCpo	:= SZD->(FCOUNT()) 
				For nI := 1 To nTotCpo
					cNameCpo	:= ALLTRIM(SZD->(FIELDNAME(nI)))
					nPosAux	:= aScan(aCabec, { |x| AllTrim(x[1]) == cNameCpo })  
					IF nPosAux > 0
						FieldPut(nI, aCabec[nPosAux, 2])
					ELSE
						FieldPut(nI, M->&(cNameCpo) )
					ENDIF
				Next nI					
			MSUNLOCK()
			
			
			// Itens
			DBSELECTAREA("SZC")
			nTotCpo	:= SZC->(FCOUNT()) 
			FOR nI := 1 to len(aItens)
				RegToMemory("SZC", .T., .F.)
				
				RECLOCK("SZC",.T.)					
					
					
					For nY := 1 To nTotCpo
						cNameCpo	:= ALLTRIM(SZC->(FIELDNAME(nY)))
						nPosAux		:= aScan(aItens[nI], { |x| AllTrim(x[1]) == cNameCpo })  
						IF nPosAux > 0
							FieldPut(nY, aItens[nI,nPosAux, 2])
						ELSE
							FieldPut(nY, M->&(cNameCpo) )
						ENDIF
					Next nY						
													
				MSUNLOCK()	
			NEXT nI							
			
		END TRANSACTION
		
		aRet[3]:= SZD->ZD_FILIAL + SZD->ZD_IDTRAN
	
	/*--------------------------
		EXCLUSAO
	---------------------------*/							
	ELSEIF clOpc == "D"
			
		DbSelectArea("SZD")
		DbSetOrder(1)	//ZD_FILIAL, ZD_IDTRAN		
		If SZD->(DbSeek(xFilial("SZD") + cIdTran))
			IF SZD->ZD_STATUS == "1" //| PENDENTE |
				
				aRet[3]:= SZD->ZD_FILIAL + SZD->ZD_IDTRAN
				
				BEGIN TRANSACTION
				
				DbSelectArea("SZC")
				DbSetOrder(1)		
				If SZC->(DbSeek(xFilial("SZC")+SZD->ZD_IDTRAN))		
				
					WHILE SZC->(!EOF()) .AND. SZC->ZC_IDTRAN == SZD->ZD_IDTRAN
						
						RECLOCK("SZC",.F.)
							SZC->(DBDELETE())
						MSUNLOCK()
					
						SZC->(DBSKIP())
						
					ENDDO
																
				ENDIF
				
				RECLOCK("SZD",.F.)
					SZD->(DBDELETE())
				MSUNLOCK()						
				
				END TRANSACTION
			ELSE
				cMsgErro := "Registro nao pode ser excluido."
			ENDIF
		ELSE
			cMsgErro := "Registro nao localizado."
		ENDIF							
	ELSE
		cMsgErro := "Operacao não implementada ["+clOpc+"]"
	ENDIF
			
	/*---------------------------------------
	Restaura FILIAL  
	-----------------------------------------*/
	
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)			 			
	ENDIF 				

ENDIF

IF EMPTY(cMsgErro)
	aRet[1] := .T.
ELSE 

	aRet[1] := .F.
	aRet[2] := cMsgErro
	
ENDIF
				
RETURN(aRet)





/*/{Protheus.doc} CP12004C
Inclusao de Titulos a Pagar com Rateio 
@author Fabio Sales | www.compila.com.br
@since 16/03/2018
@version 1
@param clTable	,C, Table.
@param Aldados	,A, Dados dos títulos.
@param nlOpc	,A, Opção(Inclusão, alteração ou exclusão).
@param clFil	,A, Filial.
@return aRet	,A, aRet[1] Contém False or True.
@return aRet	,A, aRet[2] Mensagem de erro. 
@return aRet	,A, aRet[3] Chave do Registro.
@example
(examples)
@see (www.compila.com.br)
/*/

USER FUNCTION CP12004C(clTable,alTitulo,clOpc,clFil)
Local aRet	:= {.f.,"",""}
Local _cCodEmp	
Local _cCodFil
Local _cFilNew	
Local clpre		:= ""
Local clNum		:= ""
Local cltipo	:= ""
Local clPar		:= ""
Local clCli		:= ""
Local clLoj		:= ""
Local nAscan	:= 0	
Local clSufTab	:= Right(Alltrim(clTable),2)
Local alArea	:= GetArea()
Local alFields	:= {}
Local nlOpc		:= 0
Local nI		:= 0
Local nJ		:= 0
Local Aldados	:= {}
Local cidGesp	:= ""
lOCAL nRecSE	:= 0
Local nPosEms	:= 0 
Local nPosVenc	:= 0 
Local nRatNat	:= 0
Local aItensRat, aItem, nCpo
Local nE2FORNECE	:= TAMSX3("E2_FORNECE")[1]
Local nE2LOJA		:= TAMSX3("E2_LOJA")[1]
local cChvTitulo := ""
local aCpoChv	 := {} 

//* POSICAO DOS CAMPOS NO ARRAY
LOCAL nFILIAL  := 0
LOCAL nPREFIXO := 0
LOCAL nNUM     := 0
LOCAL nPARCELA := 0
LOCAL nTIPO    := 0
LOCAL nFORNECE := 0
LOCAL nLOJA    := 0
LOCAL nXIDFLG  := 0
LOCAL nXGESPL  := 0
LOCAL nEMISSAO	:= 0
LOCAL nVENCTO	:= 0

Default clOpc := "I" 

//| Faz o De/Para da operação.

IF clOpc =="I"
	nlOpc := 3
ELSEIF clOpc =="U"
	nlOpc	:= 4
ELSEIF clOpc =="D"
	nlOpc	:= 5
END		

/*-------------------------------------------------------------------------\
| Faz as tratativas para o Jsons que não tenha os campos de código e Loja  |
| do Cliente/Fornecedor.                                                   |
\-------------------------------------------------------------------------*/
nCpo	:= 0
For nJ := 1 To Len(alTitulo)

	
	IF alTitulo[nJ,1] == "RATEIO_NATUREZA"
		nRatNat	:= nJ
	ELSE
		AADD(Aldados,alTitulo[nJ])
	ENDIF
	
Next nJ

/*--------------------------
	Ordena campo conforme dicionário de dados 
---------------------------*/
IF GETMV("CP12_ORDIC",.F.,.T.) //| Ordena Array conforme dicionario|
	Aldados	:=  FWVetByDic ( Aldados, "SE2", .F., 1)
ENDIF 


/*------------------------------------------------------ Augusto Ribeiro | 26/02/2019 - 6:50:45 PM
	MONTA CHAVE DO TITULO CONSIDERANDO QUE NEM TODOS OS CAMPOS CHAVES ESTAO SENDO ENVIDADOS
------------------------------------------------------------------------------------------*/
aCpoChv	:= {"E2_PREFIXO", "E2_NUM", "E2_PARCELA", "E2_TIPO", "E2_FORNECE", "E2_LOJA"}

cChvTitulo	:= XFILIAL("SE2")
FOR nI := 1 to len(aCpoChv)
	
	nPosAux	:= aScan(Aldados, { |x| AllTrim(x[1]) == aCpoChv[nI] })
	IF nPosAux > 0
		Aldados[nPosAux,2]	:=  AVKEY(Aldados[nPosAux,2]	,aCpoChv[nI])
		cChvTitulo	+= Aldados[nPosAux,2]
	ELSE 
		cChvTitulo	+= AVKEY(Aldados[nPosAux,2]	,aCpoChv[nI])
	ENDIF


NEXT nI

nPosAux	:= aScan(Aldados, { |x| AllTrim(x[1]) == "E2_EMISSAO" })
IF nPosAux > 0
	nEMISSAO    := nPosAux	
ENDIF

nPosAux	:= aScan(Aldados, { |x| AllTrim(x[1]) == "E2_VENCTO" })
IF nPosAux > 0
	nVENCTO    := nPosAux						
ENDIF

nPosAux	:= aScan(Aldados, { |x| AllTrim(x[1]) == "E2_XIDFLG" })
IF nPosAux > 0
	nXIDFLG  := nPosAux
ENDIF

nPosAux	:= aScan(Aldados, { |x| AllTrim(x[1]) == "E2_XGESPL" })
IF nPosAux > 0
	nXGESPL  := nPosAux			
ENDIF


/*------------------------------------------------------ Augusto Ribeiro | 08/12/2018 - 10:53:09 AM
	RATEIO MULTIPLAS NATUREZAS
------------------------------------------------------------------------------------------*/
IF nRatNat > 0
	aItensRat	:= {}			
	FOR nI := 1 TO LEN(alTitulo[nRatNat,2])
		aItem		:= {}
		aadd(aItem, {"EV_NATUREZ",alTitulo[nRatNat,2,nI]:EV_NATUREZ,NIL} )
		aadd(aItem, {"EV_VALOR",alTitulo[nRatNat,2,nI]:EV_VALOR,NIL} )
		aadd(aItem, {"EV_PERC",alTitulo[nRatNat,2,nI]:EV_PERC,NIL} )
		
		AADD(aItensRat, ACLONE(aItem))
	NEXT nI
	
	//| Altera campo para considera Multiplas naturezas|
	IF LEN(aItensRat) > 0
		nPosAux	:= aScan(Aldados, { |x| AllTrim(x[1]) == "E2_MULTNAT" })  
		IF nPosAux > 0
			Aldados[nPosAux,2]	:= 1
		ELSE
			AADD(Aldados,{"E2_MULTNAT" , "1"			, Nil})	
		ENDIF
		
		aAdd(Aldados,{"AUTRATEEV", aItensRat, Nil})
	ENDIF		
	
ENDIF
	
		

/*--------------------------
	Verifica ID Gesplan
---------------------------*/
IF nXGESPL > 0

	/*--------------------------
		Verifica se o ID já existe na base
	---------------------------*/
	DBSELECTAREA(clTable)
	DbOrderNickName("IDGESPLAN") // E1_FILIAL+E1_XGESPL
	IF DBSEEK(AVKEY(clFil, "E1_FILIAL")+Aldados[nXGESPL,2]) 
		nRecSE	:= RECNO()
	ENDIF		
	
	IF nlOpc == 3 .AND. !EMPTY(nRecSE)
		aRet[2]	:= "Movimento não pode ser inserido. ID Gesplan ["+cidGesp+"] ja existe na base"
	ELSEIF nlOpc == 5 .AND. EMPTY(nRecSE)
		aRet[2]	:= "Movimento não pode ser excluido. ID Gesplan ["+cidGesp+"] não localizado."
	ENDIF	
ENDIF

/*--------------------------
	Valida se ID Fluig existe na base
---------------------------*/
IF nXIDFLG
	DBSELECTAREA("SE2")
	DbOrderNickName("IDFLUIG") // E2_XIDFLG
	IF SE2->(DBSEEK(ALLTRIM(Aldados[nXIDFLG,2]))) 
		//nSE2RECNO	:= SE2->(RECNO())
		aRet[2]	:= "Movimento não pode ser inserido. ID FLUIG ["+Aldados[nXIDFLG,2]+"] ja existe na base"		
	ENDIF
ENDIF


IF EMPTY(aRet[2])
		
	/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE 
	-----------------------------------------*/
	
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	_cFilNew	:= clFil //| CODIGO DA FILIAL DE DESTINO 
	
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
	ENDIF	


	/*------------------------------------------------------ Augusto Ribeiro | 27/04/2018 - 11:07:38 AM
		EXCLUSAO
	------------------------------------------------------------------------------------------*/
	IF nlOpc == 5
	
		DBSELECTAREA(clTable)
		DBSETORDER(1)
		DBGOTO(nRecSE)
		
		
		Aldados	:= {}
		AADD(Aldados, {"E2_FILIAL", 	FIELDGET(FIELDPOS("E2_FILIAL")), NIL})
		AADD(Aldados, {"E2_PREFIXO", 	FIELDGET(FIELDPOS("E2_PREFIXO")), NIL})
		AADD(Aldados, {"E2_NUM", 		FIELDGET(FIELDPOS("E2_NUM")), NIL})
		AADD(Aldados, {"E2_PARCELA", 	FIELDGET(FIELDPOS("E2_PARCELA")), NIL})
		AADD(Aldados, {"E2_TIPO", 		FIELDGET(FIELDPOS("E2_TIPO")), NIL})
		AADD(Aldados, {"E2_FORNECE", 	FIELDGET(FIELDPOS("E2_FORNECE")), NIL})
		AADD(Aldados, {"E2_LOJA", 		FIELDGET(FIELDPOS("E2_LOJA")), NIL})
		
		
		lMsErroAuto	:= .f.		
		MSExecAuto({|x,y,z| Fina050(x,y,z)},Aldados,,nlOpc)
	
		
		If lMsErroAuto		
			cAutoLog	:= alltrim(NOMEAUTOLOG())
	
			cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
			cMemo := STRTRAN(cMemo,"'","")
	
			//| Apaga arquivo de Log
			
			Ferase(cAutoLog)
			
			//| Le Log da Execauto e retorna mensagem amigavel ³
			
			aRet[1]	:= .F.
			aRet[2] := U_CPXERRO(cMemo)
			
			IF EMPTY(aRet[2])
				aRet[2]	:= alltrim(cMemo)
			ENDIF	
		ELSE
			aRet[1]	:= .T.	
			aRet[3]	:= SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)					
				
		ENDIF			
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 27/04/2018 - 11:07:43 AM
		INCLUSAO
	------------------------------------------------------------------------------------------*/
	ELSEIF  nlOpc == 3 

		
		nScan := Ascan(Aldados,{|x| x[1] == "E2_HIST"})		
		IF nScan > 0		
			Aldados[nScan,2]	:= 	UPPER(fwnoaccent(ALLTRIM(Aldados[nScan,2])))		 
		ENDIF		
		
		
		//| Adequa o campo de acordo com o tamanho pardrão.
		
		clpre 	:= AVKEY(clpre	,"E2_PREFIXO")
		clNum 	:= AVKEY(clNum	,"E2_NUM")
		cltipo	:= AVKEY(cltipo	,"E2_TIPO")
		clPar 	:= AVKEY(clPar	,"E2_PARCELA")
		clLoj 	:= AVKEY(clLoj	,"E2_LOJA")				
		//cidGesp := AVKEY(clLoj	,"E2_XGESPL")
		
	
		nPosEms		:= Ascan(Aldados,{|x| x[1] == "E2_EMISSAO"})
		nPosVenc	:= Ascan(Aldados,{|x| x[1] == "E2_VENCTO"})
		
		
		/*----------------------------------------
			31/10/2018 - Jonatas Oliveira - Compila
			Verifica se Vencimento é menor que a 
			Emissão
		------------------------------------------*/
		IF nEMISSAO > 0 .AND. nVENCTO > 0 
			IF Aldados[nVENCTO][2] < Aldados[nEMISSAO][2]
				Aldados[nEMISSAO][2] := Aldados[nVENCTO][2]
			ENDIF 
		ENDIF 
		
		lMsErroAuto	:= .F.
		
		
		
		
		

		//| Verifica se o titulo existe.
		DBSELECTAREA("SE2")
		SE2->(DBSETORDER(1)) //| E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA, R_E_C_N_O_, D_E_L_E_T_		
		//cChvTitulo	:= XFILIAL("SE2")+Aldados[nPREFIXO,2]+Aldados[nNUM,2]+Aldados[nPARCELA,2]+Aldados[nTIPO,2]+Aldados[nFORNECE,2]+Aldados[nLOJA,2]
		IF !SE2->(DBSEEK(cChvTitulo))
			MSExecAuto({|x,y,z| Fina050(x,y,z)},Aldados,,nlOpc)
		ELSE
			 aRet[1]:= .F.
			 aRet[2]:= "Título já existente no contas a pagar: Chave["+cChvTitulo+"]"
		ENDIF
		
	
	
		If lMsErroAuto //.AND. aRet[2]
	
			cAutoLog	:= alltrim(NOMEAUTOLOG())
	
			cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
			cMemo := STRTRAN(cMemo,"'","")
			CONOU("U_CP12004C",cMemo)
			//| Apaga arquivo de Log
			
			Ferase(cAutoLog)
			
			//| Le Log da Execauto e retorna mensagem amigavel ³
			
			aRet[1]	:= .F.
			aRet[2] := U_CPXERRO(cMemo)
			
			IF EMPTY(aRet[2])
				aRet[2]	:= alltrim(cMemo)
			ENDIF
			
		ELSE
			aRet[1]	:= .T.
			aRet[3]	:= SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)					
		EndIf
		
		/*---------------------------------------
			Restaura FILIAL  
		-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF 
	ENDIF
ENDIF
	
RestArea(alArea)
	
Return(aRet)




/*/{Protheus.doc} RemovChar
Remove caracter especial
@author Augusto Ribeiro | www.compila.com.br
@since 08/06/2011
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
STATIC Function RemovChar(cRet)
Local cRet

cRet	:= upper(cRet)

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

Return(cRet)