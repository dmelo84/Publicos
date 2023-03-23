#Include 'Protheus.ch'



/*/{Protheus.doc} CP13GRVP
Ponto de entrada na rotina RECEBE PDF MUNICIPAL
Gera fila para integração com o Fluig
SF2 Posicionado e F2_XPDFNF
@author Augusto Ribeiro | www.compila.com.br
@since 21/01/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP13GRVP()
Local aRet		:= {.F., ""}
Local cQuery	:= ""
Local nI

cQuery := " SELECT C5_XIDFLG "+CRLF
cQuery += " FROM "+RetSqlName("SD2")+" SD2 WITH(NOLOCK) "+CRLF
cQuery += " INNER JOIN "+RetSqlName("SF2")+" SF2 WITH(NOLOCK)  "+CRLF
cQuery += " 	ON D2_FILIAL = F2_FILIAL  "+CRLF
cQuery += " 	AND D2_DOC = F2_DOC "+CRLF
cQuery += " 	AND D2_SERIE = F2_SERIE "+CRLF
cQuery += " 	AND SF2.R_E_C_N_O_ = "+ALLTRIM(STR(SF2->(recno())))+" "+CRLF
cQuery += " 	AND SF2.D_E_L_E_T_ = '' "+CRLF
cQuery += " INNER JOIN "+RetSqlName("SC5")+" SC5 WITH(NOLOCK) "+CRLF
cQuery += " 	ON C5_FILIAL = D2_FILIAL "+CRLF
cQuery += " 	AND C5_NUM = D2_PEDIDO "+CRLF
cQuery += " 	AND C5_XIDFLG <> '' "+CRLF
cQuery += " 	AND SC5.D_E_L_E_T_ = '' "+CRLF
cQuery += " WHERE SD2.D_E_L_E_T_ = '' "+CRLF
cQuery += " GROUP BY C5_XIDFLG "+CRLF



If Select("TFIL") > 0
	TFIL->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TFIL",.F., .T.)						


IF TFIL->(!EOF())
	U_CP12ADD("000028", "SF2", SF2->(RECNO()),, )
ENDIF

TFIL->(DbCloseArea())

Return(aRet)




