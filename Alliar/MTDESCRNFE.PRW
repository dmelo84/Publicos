#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.ch"
#INCLUDE "TopConn.ch"




/*/{Protheus.doc} MTDESCRNFE
Descrição Nota fiscal de serviço via arquivo magnetico
@author Augusto Ribeiro | www.compila.com.br
@since 09/03/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
USER FUNCTION MTDESCRNFE()
Local cRet		:= ""
Local cNumRPS	:= paramixb[1]
Local cSerRPS	:= paramixb[2]
Local cCodCli	:= paramixb[3]
Local cLoja		:= paramixb[4]

	DBSELECTAREA("SC6")
	aAreaSC6	:= GetArea()
	SC6->(DBSETORDER(4))	//| C6_FILIAL+C6_NOTA+C6_SERIE
	
	DBSELECTAREA("SC5")
	aAreaSC5	:= GetArea()
	SC5->(DBSETORDER(1))	


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Busca Mensagem no Pedido de Venda ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF SC6->(DBSEEK(XFILIAL("SC6")+cNumRPS+cSerRPS,.F.))
		IF SC5->(DBSEEK(XFILIAL("SC5")+SC6->C6_NUM,.F.))

			cRet += ALLTRIM(SC5->C5_MENNOTA)
		ENDIF		
	ENDIF  
	

RETURN(cRet)