#INCLUDE "PROTHEUS.CH"

#DEFINE	XPROC	"ALRMDT05"
//-------------------------------------------------------------------
/*{Protheus.doc} ALRMDT05
Impressao Relatorio PPRA via Job e Start do Processo no Fluig

@author Guilherme.Santos
@since 15/01/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRMDT05(aParam)
	Local aEmpresas	:= {}
	Local aTabelas 	:= {"TO0"}
	Local aCardData	:= {}
	Local cEmpBkp		:= ""
	Local cFilBkp		:= ""
	Local cRetWS		:= ""
	Local nI			:= 0
	Default aParam 	:= {"01", "00101MG0001"}
	
	RpcSetType(3)
	RpcSetEnv(aParam[1], aParam[2])

	cEmpBkp		:= cEmpAnt
	cFilBkp		:= cFilAnt

	DbSelectArea("SM0")
	DbSetOrder(1)		//M0_CODIGO, M0_CODFIL
	
	SM0->(DbGoTop())
	
	While !SM0->(Eof())
		Aadd(aEmpresas, {	SM0->M0_CODIGO, SM0->M0_CODFIL})
		
		SM0->(DbSkip())
	End

	For nI := 1 to Len(aEmpresas)
		RPCSetType(3)
		RpcSetEnv(aEmpresas[nI][01], aEmpresas[nI][02], NIL, NIL, "MDT", NIL, aTabelas)
		
		DbSelectArea("SM0")
		DbSetOrder(1)		//EMPRESA + FILIAL
		
		If SM0->(DbSeek(aEmpresas[nI][01] + aEmpresas[nI][02]))
			cEmpAnt 	:= AllTrim(aEmpresas[nI][01])
			cFilAnt	:= AllTrim(aEmpresas[nI][02])

			U_ALRXLOG("ALRMDT05 - Gerando PPRA da Empresa: " + cEmpAnt + "- Filial: " + cFilAnt, .F., XPROC)

			If ChkDados()
				//Monta Formulário para Início da Tarefa
				U_ALRXCRD(@aCardData, "M0_CODIGO"			, SM0->M0_CODIGO, 			XPROC)
				U_ALRXCRD(@aCardData, "M0_NOME"				, SM0->M0_NOME, 				XPROC)
				U_ALRXCRD(@aCardData, "M0_CODFIL"			, AllTrim(SM0->M0_CODFIL), 	XPROC)
				U_ALRXCRD(@aCardData, "M0_FILIAL"			, SM0->M0_FILIAL, 			XPROC)
				U_ALRXCRD(@aCardData, "login"				, SuperGetMv("MV_ECMUSER"), XPROC)
				U_ALRXCRD(@aCardData, "colleagueName"		, SuperGetMv("MV_ECMUSER"), XPROC)
				U_ALRXCRD(@aCardData, "dtVencimentoPPRA"	, dDatabase + 30, 			XPROC)

				If U_ALRXFLG(aCardData, "AtualizacaoPPRA", 10, @cRetWS, "")
					U_ALRXLOG("Start do Processo no Fluig OK.", .F., XPROC)
					U_ALRXLOG(cRetWS, .F., XPROC)
				Else
					U_ALRXLOG("Erro no Start do Processo no Fluig", .F., XPROC)
					U_ALRXLOG(cRetWS, .F., XPROC)
				EndIf
			Else
				U_ALRXLOG("Sem dados de PPRA para o Vencimento " + DtoC(dDatabase + 30) + ".", .F., XPROC)
			EndIf
		Else
			U_ALRXLOG("Empresa: " + aEmpresas[nI][01] + "- Filial: " + aEmpresas[nI][02] + " nao localizada.", .F., XPROC)
		EndIf
	Next nI

	U_ALRXLOG("", .T., XPROC)

	//Restaura a Empresa Original
	DbSelectArea("SM0")
	DbSetOrder(1)
	
	SM0->(DbSeek(cEmpBkp + cFilBkp))
	
	cEmpAnt := cEmpBkp
	cFilAnt := cFilBkp	

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} ChkDados
Verifica se Existem dados de PPRA para Iniciar a Tarefa no Fluig

@author Guilherme Santos
@since 10/06/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ChkDados()
	Local aArea		:= GetArea()
	Local cQuery		:= ""
	Local cTabQry		:= GetNextAlias()
	Local lRetorno	:= .T.

	cQuery += "SELECT		TO0.TO0_LAUDO" + CRLF
	cQuery += ", 			TO0.TO0_DTINIC" + CRLF
	cQuery += ", 			TO0.TO0_DTFIM" + CRLF
	cQuery += ", 			TO0.TO0_CODUSU" + CRLF

	cQuery += "FROM 		" + RetSqlName("TO0") + " TO0" + CRLF

	cQuery += "WHERE 		TO0.TO0_FILIAL = '" + xFilial("TO0") + "'" + CRLF
	cQuery += "AND 		TO0.TO0_DTFIM = '" + DtoS(dDatabase + 30) + "'" + CRLF		//		--DATA + 30 DIAS
	cQuery += "AND		TO0.TO0_TIPREL = '1'" + CRLF

	cQuery += "AND 		TO0.D_E_L_E_T_ = ''" + CRLF

	cQuery += "ORDER BY TO0.TO0_LAUDO" + CRLF
	
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		
	If (cTabQry)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf
	
	RestArea(aArea)

Return lRetorno
