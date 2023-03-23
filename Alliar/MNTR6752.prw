#Include 'Protheus.ch'

/*/{Protheus.doc} MNTR6752
O ponto de entrada MNTR6752 está destinado a imprimir o relatório Gráfico Completo 
de forma customizada.

@author claudiol
@since 16/11/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
@obs
PARAMIXB1 = oPrint; Objeto de impressão.
PARAMIXB2 = cDEPLANO; Parâmetro inicial de plano.
PARAMIXB3 = cATEPLANO; Parâmetro final de plano.
PARAMIXB4 = aMATOS; Array contendo na posição um o código do plano e na posição dois o código da O.S.
PARAMIXB5 = nRecOs; Número de registro da O.S.
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
	ApMsgStop("Relatório customizado não está compilado. Entre em contato com Administrador!",".:Atenção:.")
EndIf

Return
