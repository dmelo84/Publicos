#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#include "FILEIO.CH"     


/*
GCT01ASS
Executa rotina de envio de email

@author 
@since 09/12/2014
@version 1.0
*/
User Function GCT01ASS()
Local aSays    := {}
Local aButtons := {}
Local lOk      := .F. , lRet:= .T.
Local aPergs := {}                              

Private aSize := {} 
Private aInfo := {}            
Private aObj := {} 
Private aPObj := {} 
Private aPGet := {} // Retorna a area util das janelas Protheus 

aSize := MsAdvSize() // Sera utilizado tres areas na janela 
AADD( aObj, { 100, 100, .T., .T. }) 
aInfo := { aSize[1], aSize[2], aSize[3], aSize[4], 3, 3 } 
aPObj := MsObjSize( aInfo, aObj ) 
aPGet := MsObjGetPos( (aSize[3] - aSize[1]), 315, { {004, 024, 240, 270} } )         
AAdd(aSays, '     Verificar contratos sem assinatura')
		
AAdd(aButtons,{01, .T., {|o| lOk := .T., FechaBatch()}})
AAdd(aButtons,{02, .T., {|o| lOk := .F., FechaBatch()}})
		
FormBatch('Contratos', aSays, aButtons)    

IF lOk     
	If lRet
		Processa({|| GCTProc(.F.)}, 'Aguarde...', 'Processando verificacao...')
	Endif
EndIf
    
Return

/*
GCT02ASS
Executa rotina de envio de email em job

@author 
@since 09/12/2014
@version 1.0
*/
User Function GCT02ASS(aParam)      
    
	GCTProc(.T., aParam[1], aParam[2])

	//--Encerra o JOB apos o processo:
	RpcClearEnv()                                        
	
return

/*
GCTPROC
Envia email alertando sobre contratos nao assinado

@author 
@since 09/12/2014
@version 1.0
*/
Static Function GCTProc(lJob, cxhEmpr, cxhFil)
Local cCN9Alias := GetNextAlias()
Local cA2Alias := GetNextAlias()
Local cA1Alias := GetNextAlias()
Local nDif := 0
Local cTexto := ""
Local lPrimeira := .T.
Local nCmp1 := 0
Local nCmp2 := 20
Local nCmp3 := 10
Local nCmp4 := 30                   
Local c1Cmp := ''                   
Local c2Cmp := ''                   
Local c3Cmp := ''                   
Local c4Cmp := ''
Local nIntDias := 0
Local aCampos := {}
Private aLinhas := {}
// ------------------------------------------
// INICIALIZA O AMBIENTE
// ------------------------------------------
If lJob
	RpcSetType(2)
	
	RpcSetEnv(cxhEmpr, cxhFil)
		
	nIntDias := Val(SuperGetMV('ES_GCTMAIL',,'1') )
	
else
	nIntDias := Val(SuperGetMV('ES_GCTMAIL',,'1') )
EndIf

nCmp1 := TamSx3("CN9_NUMERO")[1] + TamSx3("CN9_REVISA")[1] + 1

If !lJob
	ProcRegua(0)
EndIf


BeginSql Alias cCN9Alias

SELECT CN9.CN9_NUMERO,
       CN9.CN9_REVISA,
       CN9.CN9_TPCTO,
       CN9.CN9_DTINIC,
       CN9.CN9_ASSINA,
       CN9.CN9_DTENCE,
       CN9.CN9_CLIENT,
       CN1.CN1_ESPCTR,
       CN1.CN1_DESCRI
       
       FROM %table:CN9% CN9,
            %table:CN1% CN1
       WHERE CN9.CN9_FILIAL     = %xFilial:CN9% AND 
             CN1.CN1_FILIAL     = %xFilial:CN1%  
             AND CN9.%NotDel%
             AND CN1.%NotDel%
                                           
       		 AND CN9.CN9_TPCTO  = CN1.CN1_CODIGO
       		 AND CN9.CN9_ASSINA = ''
       		 AND CN9.CN9_DTENCE = ''
       		 AND CN9.CN9_DTFIM   >= %Exp:(DTOS(dDataBase))% 
              			 
ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA
  
EndSql



While (cCN9Alias)->(!Eof()) .And. EMpty( (cCN9Alias)->(CN9_ASSINA) ) .And. EMpty( (cCN9Alias)->(CN9_DTENCE) )

    nDif := dDataBase - STOD((cCN9Alias)->(CN9_DTINIC))
    
    If nDif >= nIntDias
        c1Cmp := ""
        If !Empty ((cCN9Alias)->(CN9_REVISA)) 
        	c1Cmp += AllTrim((cCN9Alias)->(CN9_NUMERO)) + "-" + AllTrim((cCN9Alias)->(CN9_REVISA))
        Else
        	c1Cmp :=  AllTrim((cCN9Alias)->(CN9_NUMERO)) 
        EndIf
        
        
        c2Cmp :=  AllTrim((cCN9Alias)->(CN1_DESCRI))
          
        c3Cmp :=  substr( (cCN9Alias)->(CN9_DTINIC), 7,2) + "/" + substr( (cCN9Alias)->(CN9_DTINIC), 5,2) + "/" + substr( (cCN9Alias)->(CN9_DTINIC), 1,4) 
			
		If (cCN9Alias)->(CN1_ESPCTR) == "1"//compra
		
				BeginSql Alias cA2Alias

					SELECT SA2.A2_NOME
					       
					       FROM %table:CNC% CNC,
					            %table:SA2% SA2
					       WHERE CNC.CNC_FILIAL       = %xFilial:CNC% AND 
					             SA2.A2_FILIAL        = %xFilial:SA2%  
					             AND CNC.%NotDel%
					             AND SA2.%NotDel%
					       		 AND CNC.CNC_CODIGO   = SA2.A2_COD
					       		 AND CNC.CNC_LOJA     = SA2.A2_LOJA
					       		 AND CNC.CNC_NUMERO   =  %Exp:((cCN9Alias)->(CN9_NUMERO))%
					       		 AND CNC.CNC_REVISA   =  %Exp:((cCN9Alias)->(CN9_REVISA))% 
					  
				EndSql
	
				c4Cmp := " "
				If (cA2Alias)->(!Eof())
					While (cA2Alias)->(!Eof())
						c4Cmp := AllTrim((cA2Alias)->(A2_NOME))
						//cTexto += (  c4Cmp + Chr(13) + Chr(10))
						//c4Cmp := "" 
					    Aadd(aLinhas, {c1Cmp, c2Cmp, c3Cmp, c4Cmp})
					    
				        (cA2Alias)->(DbSKip())
			        End
				Else
					Aadd(aLinhas, {c1Cmp, c2Cmp, c3Cmp, c4Cmp})
				EndIf
				
	            (cA2Alias)->(DbCloseArea())
		Else
				BeginSql Alias cA1Alias

					SELECT SA1.A1_NOME
					       
					       FROM %table:CNC% CNC,
					            %table:SA1% SA1
					       WHERE CNC.CNC_FILIAL       = %xFilial:CNC% AND 
					             SA1.A1_FILIAL        = %xFilial:SA1%  
					             AND CNC.%NotDel%
					             AND SA1.%NotDel%
					       		 AND CNC.CNC_CLIENT   = SA1.A1_COD
					       		 AND CNC.CNC_LOJACL   = SA1.A1_LOJA
					       		 AND CNC.CNC_NUMERO   =  %Exp:((cCN9Alias)->(CN9_NUMERO))%
					       		 AND CNC.CNC_REVISA   =  %Exp:((cCN9Alias)->(CN9_REVISA))% 
					  
				EndSql
				/*
				cTexto += (  c1Cmp + Chr(13) + Chr(10))  
				cTexto += (  c2Cmp + Chr(13) + Chr(10))  
				cTexto += (  c3Cmp + Chr(13) + Chr(10))  
				*/
		        //c4Cmp := "Cliente: "
	            c4Cmp := ""
	            
	            If (cA1Alias)->(!Eof())
		            While (cA1Alias)->(!Eof())
					
						c4Cmp := AllTrim((cA1Alias)->(A1_NOME)) 
						//cTexto += (  c4Cmp + Chr(13) + Chr(10))
						//c4Cmp := ""
				
						Aadd(aLinhas, {c1Cmp, c2Cmp, c3Cmp, c4Cmp})
				    	
				        (cA1Alias)->(DbSKip())
			        End
				Else
					Aadd(aLinhas, {c1Cmp, c2Cmp, c3Cmp, c4Cmp})
					
				EndIf
				
	            (cA1Alias)->(DbCloseArea())
		EndIf
		
    EndIf
    
	(cCN9Alias)->(DbSkip())
End

(cCN9Alias)->(DbCLoseArea())

If Len(aLinhas) > 0
	MandaEmail()
EndIf

//--Encerra o ambiente:
If lJob
	RpcClearEnv()
EndIf

Return


/*/{Protheus.doc} MandaEmail

envia email

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/
Static Function MandaEmail ()
Local nI   := 0  
Local oServer       := NIL, nErro := 0, cMAilError := ''
Local nArr := 0
Local oMessage      := NIL
Local ncont := 0
Local cMailConta    := SuperGetMV("ES_XECONT",, '')//'oswaldo.luiz'                                                                                                                                                                                                                                   
Local cMailServer   := SuperGetMV("ES_XSRVC",, '')// 'mail.totvs.com.br'                                                                                                                                                                                                                                            
Local cMailSenha    := SuperGetMV("ES_XSENHA",, '')//'oswa2015'   
Local cMailCtaAut   := SuperGetMV("ES_XCONTA",, '')//'oswaldo.luiz@totvs.com.br'
Local cPrtServer    := SuperGetMV("ES_XPORTA",, '')//'587' 
Local cTitulo       := SuperGetMV("ES_XTIT",, '')//'587' 
Local cMailDest       := SuperGetMV("ES_XDEST",, '')//'587' 
Local cMailOrig       := SuperGetMV("ES_XORIG",, '')//'587' 

Local cArqHtml      := SuperGetMV('ES_HTML',,'')

Local lRet          := .T.
Local lCOntinua     := .T.                                       
Local nTamFim       := 0
Local cStr          := ''
Local cStrArq       := ''

Local nIndChar      := 0        
Local cNome         := ''
Local cParcNome     := ''
Local cNewNome      := ''
Local cTxtHtml      := Memoread(cArqHtml)
Local cCorpo        := GridCorpoEMail ()

cTxtHtml := STRTRAN ( cTxtHtml , '[LINHAS]' , cCorpo , 1 , 1 )		

//--Cria a conexão com o server STadmin	MP ( Envio de e-mail )
oServer := TMailManager():New()      
//oServer:SetUseTLS(.T.) 
                                            
//ALert ("cMailServer '" + AllTrim(cMailServer) + "'")
//ALert ("cMailCtaAut '" + AllTrim(cMailCtaAut) + "'") 
//ALert ("cMailSenha '"  + AllTrim(cMailSenha) + "'")


oServer:Init('', cMailServer, cMailCtaAut, cMailSenha, 0, Val(cPrtServer))//25

nArr := oServer:SetSMTPTimeOut( 120 ) 
cMAilError := oServer:GetErrorString(nArr)
  
If  oServer:SMTPConnect() <> 0     
//	ALert ("nao achou SMTP")

	lRet := .F.
	lContinua := .F.          
else
//	ALert ("cMailConta '" + AllTrim(cMailConta) + "'")   
//	ALert ("cMailSenha '" + AllTrim(cMailSenha) + "'")


	nErro := oServer:SmtpAuth(cMailConta, cMailSenha)

	If nErro <> 0
//		ALert ("nao validou senha")

        cMAilError := oServer:GetErrorString(nErro)
        DEFAULT cMailError := '***UNKNOW***'
        oServer := Nil
		 lRet := .F.	
        Return lRet
    EndIf	
EndIf

If lContinua          
//	alert ('continua from ' + cMailOrig + '  to ' + cMailDest)
   	oMessage := TMailMessage():New()         
	oMessage:Clear()                            
	
	//--Popula com os dados de envio
	oMessage:cFrom 		:= cMailOrig //cMailCtaAut
	oMessage:cTo 		:= cMailDest    //"oswaldo.luiz@totvs.com.br"
	oMessage:cSubject   := cTitulo
				                       
	oMessage:cBody := cTxtHtml
    			//      alert (cTxtHtml)
    
	//--Envia o e-mail
	
	If oMessage:Send(oServer) != 0
		lRet := .F.      
	else     
		If Empty(oMessage:cTo)
			lRet := .F.      
		Endif
	EndIf
	        
    oMessage := Nil
                                                       
	//--Desconecta do servidor
	If oServer:SMTPDisconnect() != 0
		lRet := .F.
	EndIf

EndIf

Return lRet




/*/{Protheus.doc} AjAssinat

REGISTRA ASSINATURA NO CONTRATO

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/
User Function ALGCTP02 ()
Local cPerg := "AJASSGCT"
Local lSim := .F.
Local lMantem := .T.
Local lOk := .F.
lOCAL cUpd := ''

If !Empty(CN9->CN9_NUMERO)


	If AllTrim(CN9->CN9_SITUAC) == '02' .or. AllTrim(CN9->CN9_SITUAC) == '05'
		
		If Empty(CN9->CN9_ASSINA) .And. Empty(CN9->CN9_DTENCE)
			AjustSX1(cPerg)
			
			while lMantem
				mv_par01 := ctod('')		
	
				If	pergunte(cPerg,.T.)
				    
					If empty(mv_par01)
				    	ALert ("Informe a Data de Assinatura do Contrato")
						Loop
					endif
					
					LOK := .T.	 
					lMantem := .F.	
				Else
					lMantem := .F.	
				Endif
				
			End
			
			If lOk
				lSim := MsgNoYes( "Foi selecionada a Data de Assinatura do Contrato. Após informá-la não será possível mais modificar esta Data." + CRLF + "Confirma a ação ?" )
				
				If lSim
				
					If mv_par01 >= CN9->CN9_DTINIC  
						reclock('CN9',.F.)
						CN9->CN9_ASSINA := mv_par01
						MsUnLock()
						
						cUpd := "UPDATE "+RetSqlName("CN9") +" SET CN9_ASSINA = '" + dtos(mv_par01) + "' "
						cUpd += "WHERE CN9_FILIAL = '"+FwXFilial("CN9")+"' AND D_E_L_E_T_ = ' ' "
						cUpd += "AND CN9_NUMERO = '" + CN9->CN9_NUMERO + "'  "
						cUpd += "AND CN9_TPCTO  = '" + CN9->CN9_TPCTO + "'  "
			
						TCSqlExec(cUpd)
						
	     				Msginfo ("Data de Assinatura informada com sucesso!")
					Else
						Alert ("Não é possível utilizar uma Data de Assinatura inferior a Data de Inicio do Contrato")
					EndIf
				EndIf
			EndIf
		Else
			Alert ("Este contrato já possui Data de Assinatura ou já se encontra encerrado!")
		EndIf

	Else
		Alert ("Somente é possível assinar contratos Vigentes ou Em Elaboração")
	EndIf
EndIf

return


/*/{Protheus.doc} AJustSX1

Perguntas/parametros para impressao

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/                
Static Function AjustSX1(CPERG)
DBSELECTAREA("SX1")
DBSETORDER(1)
                         
PutSx1(cPerg, "01", "Assinatura", "Assinatura", "Assinatura", "mv_ch1", "D", 08, 0, 0, "G", "", "", "", "", "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
          
return


/*
User Function CNTA300()
Local aRet    := Paramixb
Local cIdPonto := ''
Local xRet := .T.
    
If aRet <> Nil    
	cIdPonto := Paramixb[2]

	If cIdPonto == 'BUTTONBAR'
		alert ("entrou")
		xRet := { {'Data de Assinatura', 'Data de Assinatura', { || U_ALGCTP02() }, 'Este botao informa a Data de Assinatura' } }
    EndIf
EndIf

Return xRet*/


/*/{Protheus.doc} GridCorpoEMail

grid com titulos

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/
Static FUnction GridCorpoEMail ()
LOcal cGrid := ''
Local nIndex := 1

for nIndex := 1 to Len(aLinhas)
	
	cGrid += '									<tr class="Text">' + Chr(13)+Chr(10)
	
	cGrid += '										<td>' + aLinhas[nIndex, 1] + '</td>' + Chr(13)+Chr(10)
    cGrid += '										<td>' + aLinhas[nIndex, 2] + '</td>' + Chr(13)+Chr(10)
    cGrid += '										<td>' + aLinhas[nIndex, 3] + '</td>' + Chr(13)+Chr(10)
    cGrid += '										<td>' + aLinhas[nIndex, 4] + '</td>' + Chr(13)+Chr(10)
    
	cGrid += '									</tr>' + Chr(13)+Chr(10)
Next

return cGrid



/*
GCT03ASS
adiciona menu de assinatura de contratos

@author 
@since 09/12/2014
@version 1.0
*/
User Function GCT03ASS()      


//artificio para adicionar novo menu no FwBrowse
AADD (AROTINA, {"Data Assinatura","U_ALGCTP02",0,4,0,Nil,Nil,Nil} )


return