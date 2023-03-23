#Include "Protheus.Ch"
#INCLUDE "TOPCONN.CH"




/*/{Protheus.doc} SM0CAL
Consulta padrao filtra Filial atraves de busca no SQL para melhor interacao com usuario
@author Augusto Ribeiro | www.compila.com.br
@since 21/09/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function SM0CAL()
Local lRet		:= .F.
Local lContinua	:= .F.
Local cQuery	:= ""
Local cTitulo	:= "Filiais"
Local cAliasTab	:= "SZK"
Local aBtnAdd, oModel, cFilFilter
	
	
	cQuery := " SELECT ZK_CODFIL as Codigo,     "+CRLF
	cQuery += " 		ZK_FILNOM AS Filial,    "+CRLF
	cQuery += " 		ZK_CGC AS Cnpj,  "+CRLF
	cQuery += "  MAT.R_E_C_N_O_ AS TAB_RECNO  "+CRLF
	cQuery += " FROM "+RetSqlName("SZK")+" MAT                "+CRLF
	cQuery += " WHERE D_E_L_E_T_ = ''  "+CRLF
	cQuery += " AND ZK_CODIGO = '"+SM0->M0_CODIGO+"' "
	IF !EMPTY(M->UC_XCDMARC)
		cQuery += " AND LEFT(ZK_CODFIL,3) = '"+M->UC_XCDMARC+"' "
	ENDIF
	cQuery += " AND (ZK_CODFIL LIKE '#CAMPO_BUSCA#%'    "+CRLF
	cQuery += " OR ZK_FILNOM LIKE '%#CAMPO_BUSCA#%'   "+CRLF
	cQuery += " OR ZK_CGC LIKE '%#CAMPO_BUSCA#%')   "+CRLF
	cQuery += " AND ZK_MSBLQL <> '1' "+CRLF
	

	lRet	:= U_CPXCPAD(cTitulo, cAliasTab, cQuery, aBtnAdd)
	
Return(lRet)
