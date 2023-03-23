#Include 'Protheus.ch'

/*/{Protheus.doc} MNTR6752
O ponto de entrada MNTR6752 est� destinado a imprimir o relat�rio Gr�fico Completo 
de forma customizada.

@author claudiol
@since 16/11/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
@obs
PARAMIXB1 = oPrint; Objeto de impress�o.
PARAMIXB2 = cDEPLANO; Par�metro inicial de plano.
PARAMIXB3 = cATEPLANO; Par�metro final de plano.
PARAMIXB4 = aMATOS; Array contendo na posi��o um o c�digo do plano e na posi��o dois o c�digo da O.S.
PARAMIXB5 = nRecOs; N�mero de registro da O.S.
/*/
User Function MNTR6752()

Local oPrint 		:= PARAMIXB[1]
Local cDEPLANO 	:= PARAMIXB[2]
Local cATEPLANO 	:= PARAMIXB[3]
Local aMATOS 		:= PARAMIXB[4]
Local nRecOs 		:= PARAMIXB[5]

If ExistBlock("FSMNTR01")
	Processa({ |lEnd| U_FSMNTR01({oPrint,cDEPLANO,cATEPLANO,aMATOS,nRecOs})},"Aguarde... verificando alteracoes..")
Else
	ApMsgStop("Relat�rio customizado n�o est� compilado. Entre em contato com Administrador!",".:Aten��o:.")
EndIf

Return
