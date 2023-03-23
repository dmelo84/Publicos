#include 'protheus.ch'
#Include "TopConn.Ch"
#include 'parmtype.ch'


/*/{Protheus.doc} CPADZDU
Consulta Padrão no campo de resposta padrão 
nos itens de atendimentos no Call Center
@author Fabio Sales | www.compila.com.br
@since 01/05/2018
@version 1.0
/*/

User Function CPADZDU()

	Local lRet		:= .F.	
	Local cQuery	:= ""	
	Local cTitulo	:= "Respostas Padrões"
	Local cAliasTab	:= "ZUD"
	Local aBtnAdd, oModel, cFilFilter
	Local nlPosOcor	:= Ascan( aHeader ,{|y| AllTrim(y[02]) == "UD_OCORREN"} )	
				
	cQuery := " SELECT "		
	cQuery += " 	ZUD_CODIGO "
	cQuery += " 	,ZUD_DESCRI "
	cQuery += " 	,ZUD.R_E_C_N_O_ AS TAB_RECNO "	
	cQuery += " FROM "+RetSqlName("ZUD")+" ZUD WITH(NOLOCK) "
	cQuery += " WHERE ZUD_FILIAL='' "
	cQuery += " 	AND ZUD_CODOCO='" + acols[n,nlPosOcor] + "' "
	cQuery += " 	AND ZUD.D_E_L_E_T_='' "					

	lRet	:= U_CPXCPAD(cTitulo, cAliasTab, cQuery, aBtnAdd)

Return(lRet)


/*/{Protheus.doc} TMKENVWF
Envia e-mail para endereço informado na tela de atendimento.
@author Fabio Sales | www.compila.com.br
@since 01/05/2018
@version 1.0
/*/

User Function TMKWFENV(CodResp)
	
	Local cDescrServ	:= ""			
	Local cCodProc 		:= "TMKENVWF0001"
	Local cSubject		:= "Teste WorkFlow"
	Local cFromName		:= "Teste WorkFlow"
	Local cDescProc		:= "Atendimento Call center"
	Local cHTMLModelo	:= "\WORKFLOW\TMKENVWF.htm"	
	
	Default CodResp		:= ""							
	
	//|Cria Processo de Workflow
	
	oMail	:= TWFProcess():New(cCodProc,cDescProc)
	oMail:NewTask(cDescProc,cHTMLModelo)

	oHtml 		:= oMail:oHtml

	oHtml:ValByName( "logohtml" 	, LOWER(U_alLogo(SM0->M0_CODFIL,"WEB")))
	
	oHtml:ValByName( "cCliente" 	, ALLTRIM(M->UC_DESCNT))
	
	DBSELECTAREA("ZUD")
	ZUD->(DBSETORDER(1))
	IF ZUD->(DBSEEK(XFILIAL("ZUD") + CodResp ))
	
		clBody := U_alParse(AllTrim(ZUD->ZUD_RESPAD))
	
		oHtml:ValByName("clmemo",clBody)				
	
	ENDIF					
	
	oMail:cTo 		:= ALLTRIM(M->UC_XEMAIL)	
	oMail:cSubject 	:= cSubject			
	oMail:CFROMNAME := cFromName	

	oMail:Start()
	oMail:Finish()					

Return()


/*/{Protheus.doc} alParse
Realiza o parse da string.
@author Fabio Sales | www.compila.com.br
@since 01/05/2018
@version 1.0
/*/

User Function alParse(ResPad)

	Local aldados
	Local clStr		:= "#"	
	Local clRet		:= ""
	Local llCond	:= .T.
	Local nA		:= 0
	 	
	Default ResPad := ""
	
	ResPad	:= Alltrim(ResPad)	
	
	IF !Empty(ResPad)
		
		aldados := StrTokArr(ResPad,clStr)
				
		For nA := 1 To Len(aldados)
		
			IF "UC_" $ aldados[nA]
			
				DBSELECTAREA("SX3")
				aAreaSX3 := SX3->(GETAREA())
				
				SX3->(DBSETORDER(2)) //| X3_CAMPO	
				
				//| Verifica se o campo Existe.
				
				IF SX3->(DBSEEK(ALLTRIM(aldados[nA])))
					
					clRet += " " +  alltrim( M->&(ALLTRIM(aldados[nA]))) + " "
					
				ELSE
				
					clRet += ALLTRIM(aldados[nA])
					 
				ENDIF
				
				RestArea(aAreaSX3)
			ELSE
			
				clRet += ALLTRIM(aldados[nA])
			
			ENDIF
							
		Next nA
		
	ENDIF
	
Return(clRet)

