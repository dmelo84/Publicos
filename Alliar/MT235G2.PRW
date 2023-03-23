#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MT235G2
Tratamento para filtro na eliminacao de residuo

@author claudiol
@since 30/12/2015
@version undefined

@type function
/*/
User Function MT235G2()
    Local aArea := GetArea()
    Local aSC1Area := GetArea("SC1")
	Local nTipo		:= PARAMIXB[2]
	Local lRet		:= .T.
	Private cAliSC1	        := PARAMIXB[1]
	
	If nTipo==3 //Solicitacao de Compra
	
		DbSelectArea('SC1')
		DbSetOrder(1)
		SC1->(DbGoTo(  (cAliSC1)->(SC1RECNO)  ) )//(DbSeek( (cAliSC1)->(C1_FILIAL)+(cAliSC1)->(C1_NUM)+(cAliSC1)->(C1_ITEM) ) )
		
		If SC1->(!Eof())
	
			If (lRet:= U_FSCOMP03("MATA235","",'SC1') )
				if !Empty(SC1->C1_XIDFLG)
					MsgRun("Executando integração!", "Integração!",{||ECFLG(SC1->C1_XIDFLG)})
				endif
			EndIf
		EndIf
		
	EndIf

	restArea(aArea)
	restArea(aSC1Area)
Return(lRet)

//Função para Executar a exclusão da Solicitação de compra no Fluig consumindo webservice
Static Function ECFLG(cIdFlg)
	Local FlgWS := WSECMWorkflowEngineServiceService():new()
	
	FlgWs:_URL := SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	if FlgWS:cancelInstance(SuperGetMv("MV_ECMUSER"    ,NIL ,"integrador"),;
	                        SuperGetMv("MV_ECMPSW"     ,NIL ,"integrador"),;
	                        VAL(SuperGetMv("MV_ECMEMP" ,NIL ,1)),;
	                        VAL(cIdFlg),;
	                        SuperGetMv("MV_ECMMAT"),;
	                        "Processo cancelado através da integração com o Protheus") 
		//Se processamento ocorrer sem erros exibe o valor de retorno
		MsgInfo("A Solicitação de Compra "+SC1->C1_NUM+" foi eliminada pela rotina 'Eliminação de Resíduos' do Protheus.") 
	else
		MsgStop("Erro na integração com o Fluig: " + GetWSCError(3))
	endIf  
Return 