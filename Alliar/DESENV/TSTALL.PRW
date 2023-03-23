#INCLUDE "Protheus.ch"
// #INCLUDE "RWMAKE.ch"
// #INCLUDE "TopConn.ch"
#INCLUDE "TBICONN.CH" 
// #INCLUDE "RPTDEF.CH"
// #INCLUDE 'FWMVCDEF.CH'
// #INCLUDE "FWMBROWSE.CH"      
// #INCLUDE 'TBICONN.CH'
// #INCLUDE "TOTVS.CH"
// //#INCLUDE "XMLCSVCS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE 'FWMVCDEF.ch'

User Function TST_ALL()

_cEmp		:= "99"
_cFilial	:= "01"

cBody := '{"companyId":"1","endpoint":"/api/aliancab2b/customer","method":"post","serviceCode":"cadastro_clientes","timeoutService":"100","params":{"uf":"MG","complemento":"","bairro":"Paulo Camilo","municipio":"BETIM","nome":"FCA FIAT","insc_num":"","end":"do Contorno","end_num":"3455","id":8339759,"cpf_cnpj":"12838821000180","cep":"32669900"}}'
//cBody	:= '{"code":201,"status":"success"}'
oJson := JsonObject():New()

cCatch := oJson:FromJson(cBody)
cCatch	:= cCatch

//RESET ENVIRONMENT

Return

#INCLUDE "Protheus.ch"

#INCLUDE "TBICONN.CH" 

#INCLUDE "RESTFUL.CH"
#INCLUDE 'FWMVCDEF.ch'

User Function TST_JX
clHostAPI	:= ""
clPath		:= ""
alHeadStr  := {}
		aadd(alHeadStr, "Authorization: Basic "+clPass64)
		aadd(alHeadStr, "Content-Type: application/json")
		aadd(alHeadStr, "accept: application/json")
		
		oRestSend	:= FWRest():New(clHostAPI)	
			
		clJason := "{"		
		clJason += '"from": "' + clFrom + '",'
		clJason += '"to": "' + clTo + '",'
		clJason += '"text": "' + clmsg + '"'														
		clJason += '}'
			
		oRestSend:SetPostParams(clJason)
		oRestSend:setPath(clPath)
				
		lRet := oRestSend:Post(alHeadStr)
		lRet := lRet

RETURN()


/*/{Protheus.doc} TMKENVWF
Envia e-mail para endereço informado na tela de atendimento.
@author Fabio Sales | www.compila.com.br
@since 01/05/2018
@version 1.0
/*/

Static Function tstwf()
	
	Local cDescrServ	:= ""			
	Local cCodProc 		:= "TMKENVWF0001"
	Local cSubject		:= "Teste WorkFlow"
	Local cFromName		:= "Teste WorkFlow"
	Local cDescProc		:= "Atendimento Call center"
	Local cHTMLModelo	:= "\workflow\tstaug.htm"	

	
	//|Cria Processo de Workflow
	
	oMail	:= TWFProcess():New(cCodProc,cDescProc)
	oMail:NewTask(cDescProc,cHTMLModelo)

	oHtml 		:= oMail:oHtml

	oHtml:ValByName( "logohtml" 	, "00101.jpg")
	oHtml:ValByName( "cCliente" 	, ALLTRIM("TESTE TI"))
	

		clBody := "<H1>TESTE</H1>"//U_alParse(AllTrim(ZUD->ZUD_RESPAD))
	
		oHtml:ValByName("clmemo",clBody)				
	
				
	
	oMail:cTo 		:= "augusto.ribeiro@compila.com.br" //ALLTRIM(M->UC_XEMAIL)	
	oMail:cSubject 	:= cSubject			
	oMail:CFROMNAME := cFromName	

	oMail:Start()
	oMail:Finish()					

Return()
