#include "rwmake.ch"
#include "topconn.ch"
#Include "TOTVS.ch"

/*/{Protheus.doc} MT120LOK

//TODO O ponto se encontra no final da função e deve ser utilizado para
       validações especificas do usuario onde será controlada pelo retorno 
       do ponto de entrada oqual se for .F. o processo será interrompido e 
       se .T. será validado.
       
       Utilizado para validar se o produto encontra-se fora de linha.
       
@author Peder Munksgaard 
@since 25/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MT120LOK()

Local lRet  := .T.
Local cUsu  := substr(cUsuario,7,15)
Local _aArea := GetArea()

Local lnterface := isBlind()

Public _lVldPrc := .F.
Public _lTOK := .F.

if lnterface
	conout("Processamento automatico, não valida o [MT120LOK]")
	return lRet
endIf

cUsu  :=alltrim(substr(cUsu,at('.',cUsu)+1))

if cUsu=="01"
	cQuery:="SELECT UNID, COD FORNECE "
	cQuery+="  FROM HPED2 "
	cQuery+=" WHERE PEDIDO = '"+alltrim(CA120NUM)+"'        "
	cQuery+=" UNION "
	cQuery+="SELECT ZW_UNID, ZW_FORNECE "
	cQuery+="  FROM SZW030 "
	cQuery+=" WHERE ZW_PEDIDO = '"+alltrim(CA120NUM)+"'        "
	cQuery+="   AND D_E_L_E_T_ = ' '     "
	Tcquery cQuery ALias "QRY120LK" NEW
	dbselectarea("QRY120LK")
	dbgotop()
	do while !eof() .and. lRet
		if QRY120LK->UNID <> CEMPANT .or. CA120FORN <> QRY120LK->FORNECE
			MsgBox("Pedido ja lancado na unidade: "+QRY120LK->UNID+" para o fornecedor "+QRY120LK->FORNECE,"ATENCAO")
			lRet:=.F.
		endif
		dbskip()
	enddo
	dbclosearea()
endif

// Peder Munksgaard - 25/10/2018
// Valida se produto encontra-se fora de linha conforme
// determinação do gestor Gabriel Rezende.

dbSelectArea("SB1")
SB1->(dbSetOrder(1))

If SB1->(MsSeek(FWxFilial("SB1")+GDFieldGet("C7_PRODUTO",n)))


	If !Empty(SB1->B1_XFORLIN) .And. SB1->B1_XFORLIN <= Date() .And. SB1->B1_TIPO $ 'MP|ML|MD|MB'
	
		lRet := .F.
		
		_cMsg := "Prezado(a), " + Alltrim(Capital(UsrFullName(__cUserID))) 	+ CRLF
		_cMsg += "O produto em questão encontra-se fora de linha."         	+ CRLF
		_cMsg += "Deseja prosseguir com a inclusão do mesmo?"				+ CRLF
		
		//MsgStop(_cMsg,"MT120LOK")
		If MsgYesNo(_cMsg, 'MT120LOK') 
			lRet := .T.
			cQryLog := " INSERT INTO SIGA.LOGROTINA (UN, USUARIO, DTLOG, HORA, ROTINA, CNT, OBSERV) "
			cQryLog += " VALUES ('"+cEmpAnt+"','"+RetCodUsr()+"','"+DTOS(dDatabase)+"','"+time()+"','MATA120','N', 'Produto:"+SB1->B1_COD+" Fora de Linha:"+DtoS(SB1->B1_XFORLIN)+"')"
			   	
			If TcSqlExec(cQryLog) == 0
			   	TCSqlExec('COMMIT')                      
			Else
				MsgBox("O log de Fora de Linha não foi gravado! Entre em contato com a TI.",'AVISO!','INFO')
				lRet := .F.
			EndIf	
		EndIf
	Endif
	
Endif


If Alltrim(GDFieldGet("C7_PRODUTO",N)) == "0000014418"
   Aviso("MT120LOK","Código de produto importado não deve mais ser usado. Favor procurar Sr. Eloi.")
   lRet := .F.
EndIf


RestArea(_aArea)

Return(lRet)
