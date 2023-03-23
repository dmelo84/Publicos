#Include "Protheus.ch"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} FSFATP06
Rotina responsável pela montagem do XML de Documento de Saída e envio para o WS Pleres. 
@type function
@author gustavo.barcelos
@since 11/02/2016
@version 1.0
@return boolean, T = Transmissão realizada com sucesso; F = Falha na transmissão.
/*/

User Function FSFATP06()
	Local lRet 		:= .F.
	Local cCgcFil 	:= SM0->M0_CGC
	Local cCodFil 	:= SM0->M0_FILIAL
	Local cTipFat 	:= SC5->C5_XTIPFAT
	Local cIdPleres	:= SC5->C5_XIDPLE
	Local cCgcCli 	:= SA1->A1_CGC
	Local cNomeCli 	:= SA1->A1_NOME
	Local cSerie		:= SF2->F2_SERIE
	Local cDoc 		:= SF2->F2_DOC
	Local cNFElet		:= SF2->F2_NFELETR
	Local cChvNfe		:= SF2->F2_XCVNFS
	Local cDatEmi		:= Iif(Empty(SF2->F2_EMINFE), Dtos(SF2->F2_EMISSAO), Dtos(SF2->F2_EMINFE))
	Local nVlrBrt		:= SF2->F2_VALBRUT
	Local nVlrLiq		:= SF2->F2_VALBRUT
	Local cXml			:= ""
	Local cMensLog	:= ""
		
	ConOut("*********************************************************")
	ConOut("* FSFATP06 - Enviando XML para PLERES " + DtoC(Date()) + " " + Time() )
	ConOut("* NF:"+cDoc+"  Serie: "+cSerie)	
	ConOut("*********************************************************")	

	If Left(cIdPleres,1) != "V"
		cXml:= U_FSXmlNFS(cCgcFil,cCodFil,cTipFat,cIdPleres,cCgcCli,cNomeCli,cSerie,cDoc,cChvNfe,cDatEmi,cNFElet, nVlrBrt)	
		
		aRet:= U_FSPLEFAT(cXml,cIdPleres)
		
		If aRet[1] <> "-1"
			//Inclui flag de integração com sistema Pleres.
			If RecLock("SF2", .F.)
				SF2->F2_XINTPLE 	:= Iif(Empty(cChvNfe), "1", "2")
				SF2->F2_XIDPLE	:= cIdPleres
				SF2->(MsUnlock())
			EndIf
			lRet:= .T.
		Else
			cMensLog += "=> " + cCgcFil + " " + cCodFil + " " + cIdPleres + CRLF
			cMensLog += aRet[2] + CRLF
		EndIf
	
		If lRet
			ConOut("*********************************************************")
			ConOut("* Concluída envio XML. " + DtoC(Date()) + " " + Time() )
			ConOut("*********************************************************")
		Endif	
		
		If !Empty(cMensLog)
			ConOut("*********************************************************")
			ConOut("* Erro no envio XML. " + DtoC(Date()) + " " + Time() )
			ConOut("* "+cMensLog )
			ConOut("*********************************************************")
		Endif		

		If !Empty(cMensLog)
			ApMsgStop(cMensLog,".:Atenção:.")
		EndIf
	Else
		If RecLock("SF2", .F.)
			SF2->F2_XIDPLE	:= cIdPleres
			SF2->(MsUnlock())
		EndIf	
	Endif
Return lRet


/*/{Protheus.doc} FSXmlNFS
Monta XML de Envio Pleres

@author claudiol
@since 11/03/2016
@version undefined
@param cGcFil, characters, CNPJ Filial
@param cCodFil, characters, Codigo Filial
@param cTipFat, characters, Tipo Pedido
@param cIdPleres, characters, ID Pleres
@param cGgcCli, characters, CNPJ Cliente
@param cNomeCli, characters, Nome Cliente
@param cSerie, characters, Serie NF
@param cDoc, characters, Numero NF
@param cChvNfe, characters, Chave NFSe
@param cDatEmi, characters, Data Emissao
@param cNFEElet, characters, Numero NF
@param nVlrBrt, float, Valor Bruto
@param nVlrLiq, float, Valor Liquido
@param lExclNF, boolean, Determina se a NF foi Excluida
@param lCorrCSC, boolean, Determina se e Correcao do CSC
@type function
/*/
User Function FSXmlNFS(cCgcFil,cCodFil,cTipFat,cIdPleres,cCgcCli,cNomeCli,cSerie,cDoc,cChvNfe,cDatEmi,cNFElet,nVlrBrt,nVlrLiq,lExclNF,lCorrCSC)
	Local cXml			:= ""
	Local cPicture	:= "@E 999999999.99"
	
	Default nVlrBrt 	:= 0
	Default nVlrLiq	:= 0
	Default lExclNF 	:= .F.
	Default lCorrCSC	:= .F.
	
	cXml += " <LotexNotaFiscal> "+ CRLF
	cXml += " 		<Login>PAR_LOGIN</Login> "	+ CRLF
	cXml += " 		<Senha>PAR_SENHA</Senha> "	+ CRLF
	cXml += " 		<CNPJFilial>" + Alltrim(cCgcFil) + "</CNPJFilial> "+ CRLF
	cXml += " 		<NomeFilial>" + Alltrim(cCodFil) + "</NomeFilial> "+ CRLF
	cXml += " 		<TipoPedido>" + Alltrim(cTipFat) + "</TipoPedido> "+ CRLF
	cXml += " 		<IDPleres>" + Alltrim(cIdPleres) + "</IDPleres> "+ CRLF
	cXml += " 		<NotaFiscal> "+ CRLF
	cXml += " 			<CNPJCli>" + Alltrim(cCgcCli) + "</CNPJCli> "+ CRLF
	cXml += " 			<NomeCli>" + Alltrim(cNomeCli) + "</NomeCli> "+ CRLF
	cXml += " 			<Serie>" + Alltrim(cSerie) + "</Serie> "+ CRLF
	cXml += " 			<NumRPS>" + Alltrim(cDoc) + "</NumRPS> "+ CRLF
	cXml += " 			<NumNota>" + Alltrim(cNFElet) + "</NumNota> "+ CRLF
	cXml += " 			<ChvNfe>" + Alltrim(cChvNfe) + "</ChvNfe> "+ CRLF
	cXml += " 			<DataEmissao>" + Alltrim(cDatEmi) + "</DataEmissao> "+ CRLF
	cXml += "			<ExclusaoNota>" + If(lExclNF, "true", "false") + "</ExclusaoNota>"
	cXml += "			<CorrecaoFinanceiro>" + If(lCorrCSC, "true", "false") + "</CorrecaoFinanceiro>"
	cXml += " 			<ValorBruto>" + AllTrim(StrTran(Transform(nVlrBrt, cPicture), ",", ".")) + "</ValorBruto> "+ CRLF
	cXml += " 			<ValorLiquido>" + AllTrim(StrTran(Transform(nVlrLiq, cPicture), ",", ".")) + "</ValorLiquido> "+ CRLF
	cXml += " 		</NotaFiscal> "+ CRLF
	cXml += " </LotexNotaFiscal> "+ CRLF

Return(cXml)
