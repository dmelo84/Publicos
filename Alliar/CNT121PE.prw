#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'


/*/{Protheus.doc} nomeFunction
   PONTO ENTRADA MVC - Para o Model nova rotina medicao de contratos CNTA121
                       Em subistituicao ao cnta120
   @type  Function
   @author Hamilton Fernandes - Compila
   @since 04/03/2021
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/
user Function CNT121PE()

// user somente para ter sua criacao.
// o ponto entrada baseado no model informado pela totvs, esta abaixo.

Return


/*/{Protheus.doc} nomeFunction
   PONTO DE ENTRADA CNTA121
 
   @type  Function
   @author Hamilton Fernandes (HFP) - Compila
   @since 04/03/2021
   @version version
   @param param_name, param_type, param_descr
   @return return_var, return_type, return_description
   @example
   (examples)
   @see (links_or_references)
   /*/

USER Function CNTA121(param_name)

	Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := ''
	Local cIdPonto   := ''
	Local cIdModel   := ''
	Local lIsGrid    := .F.

	If aParam <> NIL

		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		lIsGrid    := ( Len( aParam ) > 3 )


		// *-*-*-*-*-*--
		// POR HORA NAO UTILIZANDO NADA,
		// MAS COLOCANDO AQUI OS MODELOS QUE ACHAMOS NO TDN, CASO UM DIA PRECISE.


      /*
		IF cIdPonto == 'MODELCOMMITNTTS'
		   ApMsgInfo('Chamada apos a grava��o total do modelo e fora da transa��o (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel)
		ElseIf cIdPonto == 'FORMCOMMITTTSPRE'


      
	   ELSEIf cIdPonto == 'MODELVLDACTIVE' .And. FwIsInCallStack("CN121MedEnc")
            // ***Como o modelo ainda n�o foi ativado,*** devemos utilizar as tabelas p/ valida��o, a �nica informa��o que constara em oModel
            //ser� a opera��o(obtida pelo m�todo GetOperation), que nesse exemplo sempre ser� MODEL_OPERATION_UPDATE.                
            //

            //simula o CN120ENVL antigo
		   If (CND->CND_VLTOT > 1000)
                Help("",1,"CNTA121ENC",,"Nao foi possivel realizar essa operacao",1,1)
                xRet := .F.
		   EndIf
	EndIf
      */


EndIf

Return xRet
