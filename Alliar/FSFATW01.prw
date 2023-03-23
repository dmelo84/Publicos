#Include 'Protheus.ch'
#Include "TBIConn.ch"
#Include "APWEBSRV.CH"

/*/{Protheus.doc} FSFATW01
Web Service para integracao de rotinas do módulo Faturamento entre Protheus e Digitalmed - Pleres
        
@author 	Gustavo Barcelos
@since 		12/01/2016
@version 	P12
@Project	FS007476

@param    	
@obs  		

@return	Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
WSSERVICE IntegraFaturamento DESCRIPTION "FSW - Integração de Faturamento entre Protheus e Digitalmed - Pleres"

//Atributos
WSDATA XML AS STRING

//Retorno do Ws
WSDATA FSRETWS AS FSRETWS

//Metodo para geração do Pedido de Venda
WSMETHOD FaturaPedido DESCRIPTION "Incluir Pedido de Venda"

//Metodo para estorno do Pedido de Venda
WSMETHOD Estorno DESCRIPTION "Estornar Pedido de Venda"


ENDWSSERVICE

/*/{Protheus.doc} FSRETWS
Retorno Protheus referente a integração com Digitalmed - Pleres
        
@author 	Gustavo Barcelos
@since 		12/01/2016
@version 	P12
@Project	FS007476
			 
@param    	0 			= Sucesso  Mensagem = ""
            Negativo 	= Erro  	Mensagem = Descricao do erro 
@obs  		

@return	Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
WSSTRUCT FSRETWS

WSDATA RETORNO		AS INTEGER
WSDATA MENSAGEM 		AS STRING

ENDWSSTRUCT


/*/{Protheus.doc} FaturaPedido
Web Service para integracao entre Protheus e Digitalmed - Pleres
Metodo para Inclusao de pedido de venda
        
@author 	Gustavo Barcelos
@since 		12/01/2016
@version 	P12
@Project	FS007476

@param    	
@obs  		

@return	Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
WSMETHOD FaturaPedido WSRECEIVE XML WSSEND FSRETWS WSSERVICE IntegraFaturamento

	Local aRet := {-99, "Erro indeterminado."}
	Local cXml := ::XML
	Local cNomeArq	:= "log_fat_"+DTOS(DATE())+"."+STRTRAN(TIME(),":","")+"_" //| Augusto Ribeiro (12/09/2017) |
	Local nH//| Augusto Ribeiro (12/09/2017) |

	
	
//Retorno		
	
	U_FSFATP01(cXml, @aRet)
	
	::FSRETWS:RETORNO 	:= aRet[1] // 0
	::FSRETWS:MENSAGEM	:= aRet[2] // "Inclusão Pedido Venda OK!"

	cNomeArq	:= cNomeArq+DTOS(DATE())+"."+STRTRAN(TIME(),":","")+"_"+ALLTRIM(STR(Randomize(1, 100)))+".txt"//| Augusto Ribeiro (12/09/2017) |
	IF !FILE("\data\temp\log_fat_desativa.txt")
		nRet := MemoWrite("\data\temp\"+cNomeArq, cXml)//| Augusto Ribeiro (12/09/2017) |
	endif
	
Return (.T.)

/*/{Protheus.doc} Estorno
Web Service para integracao entre Protheus e Digitalmed - Pleres
Metodo para Estorno de pedido de venda
        
@author 	Gustavo Barcelos
@since 		12/01/2016
@version 	P12
@Project	FS007476

@param    	
@obs  		

@return	Nil
        
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/
WSMETHOD Estorno WSRECEIVE XML WSSEND FSRETWS WSSERVICE IntegraFaturamento

	Local aRet := {}
	Local cXml := ::XML
	
	::FSRETWS:RETORNO 	:= -3
	::FSRETWS:MENSAGEM	:= "Erro na conexão com webservice/time out!"	

//Retorno		
	U_FSFATP02(cXml, @aRet)
	
	::FSRETWS:RETORNO 	:= aRet[1] // 0
	::FSRETWS:MENSAGEM	:= aRet[2] // "Exclusão Pedido Venda OK!"

Return (.T.)

