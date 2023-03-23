#include "rwmake.ch"

/*
+-----------+------------+----------------+-------------------+-------+---------------+
| Programa  | OCONR001   | Desenvolvedor  | Daiana            | Data  | 23/03/2011    |
+-----------+------------+----------------+-------------------+-------+---------------+
| Descricao | Função criada para montar Seguimento N - Impostos                       |
+-----------+-------------------------------------------------------------------------+
| Retorno   |  cTrb                                                                   |
+-----------+-------------------------------------------------------------------------+
| Modulos   | SIGAFIN                                                                 |
+-----------+-------------------------------------------------------------------------+
| Processos | REMESSA DE PAGAMENTO AO BANCO ITAU SISPAG                               |
+---------- +-------------+-----------------------------------------------------------+
| DATA      | PROGRAMADOR | MOTIVO                                                    |
+-----------+-------------+-----------------------------------------------------------+
|CAMPOS     | E2_CODTRIB, E2_ZVALENT, E2_CGCTRIB, E2_XCOMPET                          |
+-----------+-------------+-----------------------------------------------------------+
|DATA       | Ultima alteracao 21/03/2016 (Alliar) Glauton                            |
+-----------+-------------+-----------------------------------------------------------+
*/

User Function SISPTRIB
************************
*
*************************

LOCAL cString1	:=""
LOCAL cString2	:=""
LOCAL cString3	:=""
LOCAL cString4	:=""
LOCAL cString5	:=""
LOCAL cString6	:=""

IF SEA->EA_MODELO == '17'
	
	cString1 :=  U_DADOSGPS()
	Return(cString1)
	
ELSEIF SEA->EA_MODELO == '16'
	
	cString2 := U_DADOSDARF()
	Return(cString2)
	
ELSEIF SEA->EA_MODELO == '50'
	
	cString3 := U_DADOSGARE()
	Return(cString3)
	
ELSEIF SEA->EA_MODELO $ ('25')
	
	cString4 := U_DADOSIPVA()
	Return(cString4)
	
ELSEIF SEA->EA_MODELO $ ('27')
	
	cString5 := U_DADOSDPVAT()
	Return(cString5)
	
	
ELSEIF SEA->EA_MODELO == '35'
	
	cString6 := U_DADOSFGTS()
	Return(cString6)
	
ENDIF


Return()




USER FUNCTION DADOSGPS()
************************
*
*************************

Local cRetGPS  := ""
Local cCodGps  := '01'

cCompet := Left(SE2->E2_XCOMPET,2) + Right(SE2->E2_XCOMPET,4)

cRetGPS := cCodGPS 																				//Identificação do tributo Pos.18 - 19
cRetGPS += STRZERO(VAL(SE2->E2_XCODTRI),4) 												    	//codigo pagamento Pos. 20 - 23
cRetGPS += STRZERO(VAL(cCompet),6)						  										//mes ano da competencia Pos. 24 - 29
cRetGPS += STRZERO(VAL(IIF(!EMPTY(SE2->E2_XCGCTRI),SE2->E2_XCGCTRI,SM0->M0_CGC)),14) 			//cnpj Pos. 30-43
cRetGPS += STRZERO((SE2->(E2_SALDO-E2_SDDECRE-SE2->E2_XVALENT+SE2->E2_ACRESC))*100,14) 			//valor liquido do tributo Pos. 44 - 57
cRetGPS += STRZERO((SE2->E2_XVALENT)*100,14) 													//valor de outras entidades Pos. 58 - 71
cRetGPS += STRZERO((SE2->E2_SDACRES)*100,14) 													//atualização monetária Pos. 72-85
cRetGPS += STRZERO((SE2->(E2_SALDO+E2_SDACRES-E2_SDDECRE))*100,14) 								//valor arrecadado Pos. 86 - 99
cRetGPS += GRAVADATA(SE2->E2_DATAAGE,.F.,5) 													//efetivação do pagamento Pos. 100 - 107
cRetGPS += SPACE(8) 																			//complemento de registro, deve ir em branco Pos. 108 - 115
cRetGPS += SPACE(50)																			//BRANCOS (50)
cRetGPS += SUBSTR(SM0->M0_NOMECOM,1,30)	 														//nome do contribuinte Pos. 166- 195


Return(cRetGPS)



USER FUNCTION DADOSDARF()
************************
*
*************************

Local cRetDARF  := ""
Local cCodDarf  := '02'

	
	cRetDARF += cCodDarf 												//Idenfiticação do tributo Pos. 18 - 19
	cRetDARF += STRZERO(VAL(SE2->E2_CODRET),4)							//Código da receita Pos. 20 - 23
	cRetDARF += "2"														//Tipo de inscrição do contribuinte, no caso é CNPJ Pos. 24 - 24
	cRetDARF += SUBSTR(SM0->M0_CGC,1,14)								//CNPJ do contribuinte Pos. 25 - 38
	cRetDARF += GRAVADATA(SE2->E2_XPERIOD,.F.,5)						//Perído de Apuração Pos. 39 - 46
	cRetDARF += REPLICATE("0",16) + "1" 								//Número de referência Pos. 47 - 63
	cRetDARF += STRZERO((SE2->E2_SALDO)*100,14)							//Valor da guia Pos. 64 - 77
	cRetDARF += STRZERO((SE2->E2_MULTA)*100,14)							//Valor de multa Pos. 78 - 91
	cRetDARF += STRZERO((SE2->E2_JUROS)*100,14)							//Valor de juros Pos. 92 - 105
	cRetDARF += STRZERO((SE2->(E2_SALDO+E2_MULTA+E2_JUROS))*100,14)		//Valor líquido Pos. 106 - 119
	cRetDARF += GRAVADATA(SE2->E2_VENCREA,.F.,5)						//Data de vencimento Pos. 120 - 127
	cRetDARF += GRAVADATA(SE2->E2_DATAAGE,.F.,5)						//Data do pagamento Pos. 128 - 135
	cRetDARF += SPACE(30)												//Complemento do registro, deve ir em branco Pos. 136 - 165
	cRetDARF += SM0->M0_NOMECOM 										//Nome do contribuinte Pos. 166 - 195
	
	Return(cRetDARF)
	
	
	
	USER FUNCTION DADOSIPVA()
	************************
	*
	*************************
	
	Local cRetIPVA  := ""
	Local cCodIpva  := '07'
	
	cRetIPVA :=  cCodIpva 														//Identificação do tributo Pos. 18 - 19
	cRetIPVA += SPACE(4)														//Complemento de registro, deve ir em branco Pos. 20 - 23
	cRetIPVA += "2"																//Tipo de inscrição do contribuinte, no caso é CNPJ Pos. 24 - 24
	cRetIPVA += STRZERO(VAL(SE2->E2_XCGCIPV),14) 								//CGC PAGTO IPVA Pos 25-38
	cRetIPVA += SUBSTR(DTOS(SE2->E2_EMISSAO),1,4)								//Ano base Pos. 39 - 42
	cRetIPVA += STRZERO(VAL(SE2->E2_XRENAVA),9)									//Renavam Pos. 43 - 51
	cRetIPVA += SE2->E2_XEST													//Estado Pos. 52 - 53
	cRetIPVA += SE2->E2_XCODMUN													//Código do município Pos. 54 - 58
	cRetIPVA += SUBSTR(SE2->E2_XPLACA,1,7)										//Placa do veículo Pos. 59 - 65
	cRetIPVA += STRZERO(VAL(SE2->E2_XOPTO),1)									//Opção de pagamento Pos. 66 - 66
	cRetIPVA += STRZERO((SE2->E2_VALOR)*100,14)									//Valor do IPVA Pos. 67 - 80
	cRetIPVA += STRZERO((SE2->E2_DECRESC)*100,14)								//Desconto Pos. 81-94
	cRetIPVA += STRZERO((SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC))*100,14)			//Valor líquido Pos. 95 - 108
	cRetIPVA += GRAVADATA(SE2->E2_VENCREA,.F.,5)								//Vencimento Pos. 109 - 116
	cRetIPVA += GRAVADATA(SE2->E2_DATAAGE,.F.,5)								//Data de Pagamento Pos. 117 - 124
	cRetIPVA += SPACE(29)														//Complemento de registro, deve ir em branco Pos. 125 - 153
	cRetIPVA += IF(EMPTY(SE2->E2_XRENAV1),SE2->E2_XRENAV1,REPLICATE(' ',12)) 	//Codigo Renavam 12 digitos Pos 154-165
	cRetIPVA += SM0->M0_NOMECOM													//Nome do contribuinte Pos. 166 - 195
	
	
	Return(cRetIPVA)
	
	
	
	USER FUNCTION DADOSDPVAT()
	************************
	*
	*************************
	Local cRetDpvat  := ""
	Local cCodDpvat := '08'
	
	cRetDpvat :=  cCodDpVat 													//Identificação do tributo Pos. 18 - 19
	cRetDpvat += SPACE(4)														//Complemento de registro, deve ir em branco Pos. 20 - 23
	cRetDpvat += "2"															//Tipo de inscrição do contribuinte, no caso é CNPJ Pos. 24 - 24
	cRetDpvat += STRZERO(VAL(SE2->E2_XCGCIPV),14) 						    	//CGC PAGTO DPVAT Pos 25-38
	cRetDpvat += SUBSTR(DTOS(SE2->E2_EMISSAO),1,4)								//Ano base Pos. 39 - 42
	cRetDpvat += STRZERO(VAL(SE2->E2_XRENAVA),9)								//Renavam Pos. 43 - 51
	cRetDpvat += SE2->E2_XEST													//Estado Pos. 52 - 53
	cRetDpvat += SE2->E2_XCODMUN												//Código do município Pos. 54 - 58
	cRetDpvat += SUBSTR(SE2->E2_XPLACA,1,7)										//Placa do veículo Pos. 59 - 65
	cRetDpvat += STRZERO(VAL(SE2->E2_XOPGTO),1)									//Opção de pagamento Pos. 66 - 66
	cRetDpvat += STRZERO((SE2->E2_VALOR)*100,14)								//Valor do DPVAT Pos. 67 - 80
	cRetDpvat += STRZERO((SE2->E2_DECRESC)*100,14)								//Desconto Pos. 81-94
	cRetDpvat += STRZERO((SE2->(E2_SALDO+E2_ACRESC-E2_DECRESC))*100,14)			//Valor líquido Pos. 95 - 108
	cRetDpvat += GRAVADATA(SE2->E2_VENCREA,.F.,5)								//Vencimento Pos. 109 - 116
	cRetDpvat += GRAVADATA(SE2->E2_DATAAGE,.F.,5)								//Data de Pagamento Pos. 117 - 124
	cRetDpvat += SPACE(29)														//Complemento de registro, deve ir em branco Pos. 125 - 153
	cRetDpvat += IF(EMPTY(SE2->E2_XRENOV),SE2->E2_XRENOV,REPLICATE(' ',12)) 	//Codigo Renavam 12 digitos Pos 154-165
	cRetDpvat += SM0->M0_NOMECOM												//Nome do contribuinte Pos. 166 - 195
	
	Return(cRetDpvat)
	
	
	
	USER FUNCTION DADOSFGTS()
	************************
	*
	*************************
	
	Local  cRetFGTS :=""
	Local  cCodFGTS := '11'
	
	cRetFGTS := cCodFgts														//Identificação do tributo Pos. 18 - 19
	cRetFGTS += STRZERO(VAL(SE2->E2_CODRET),4)									//Código da receita Pos. 20 - 23
	cRetFGTS += "1"																//Tipo de inscrição do contribuinte, no caso é CNPJ Pos. 24 - 24 (alterado para 1)
	cRetFGTS += StrZero(Val(SE2->E2_XCGCTRI),14) 								//25-38  CNPJ
	cRetFGTS += IF(!EMPTY(SE2->E2_CODBAR),SE2->E2_CODBAR + "    ",REPLICATE(' ',48)) 	//Código de Barra Pos. 39 - 86	
//	cRetFGTS += IF(!EMPTY(SE2->E2_CODBAR),SE2->E2_CODBAR,REPLICATE(' ',48)) 	//Código de Barra Pos. 39 - 86
	cRetFGTS += IF(!EMPTY(SE2->E2_XIDFGTS),SE2->E2_XIDFGTS,SPACE(16)) 			//Identificador do Contribuinte Pos. 087 - 102
	cRetFGTS += SPACE(9)   														//Lacre de Conectividade Social Pos. 103 - 111
	cRetFGTS += SPACE(2)														//Digito do Lacre de Conectividade Social Pos. 112 - 113
	cRetFGTS += Left(SM0->M0_NOMECOM,30)										//Nome do Contribuinte Pos. 114 - 143
	cRetFGTS += GRAVADATA(SE2->E2_DATAAGE,.F.,5) 								//Data de Pagamento Pos. 144 - 151
	cRetFGTS += STRZERO((SE2->E2_VALOR)*100,14)									//Valor do FGTS Pos. 152-165
	cRetFGTS += SPACE(30)														//Complemento de registro, deve ir em branco Pos. 166 - 195
	
	Return(cRetFGTS)
	
	
