#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} TK271BOK
Ponto de Entrada para Validar a Confirmacao do Atendimento do CallCenter

@author Guilherme.Santos
@since 31/01/2017
@version P12 validar nOpção p/ certificar o não envio qdo for encerramento
*/  
//-------------------------------------------------------------------
User Function TK271BOK( nOpc )     
	//Local cAcaoFlg:= SuperGetMV("ES_ACAOFLG", NIL, "000001") //UQ_XENVPFO  C  1 = SIM 
    Local aArea     := GetArea()	
	Local aCardData	:= {}
	Local cRetWS	:= ""
	Local nItem		:= 0
	Local nItemReal	:= 1
	Local nPosAcao	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_SOLUCAO"})
	Local nPosIDFl	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XIDFLUI"})
	Local nPosSlSLA	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XSLSLA"})
	Local nPosSUBI	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_SUBITEM"})
	Local nPosITEM	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_ITEM"})
	Local nPosStat	:= AScan(aHeader, {|x| AllTrim(x[2]) == "UD_STATUS"})
	Local nPosDele	:= Len(aHeader) + 1
	Local lRetorno	:= .T.
    Local _cTipo    := Space(20)
    Local _cPrio    := Space(20)
    Local _cIdOco   := Space(06)         
    Local _cDesOco  := Space(60)
	Local alCodResp	:= {}
	Local _cCpfCt	:= ""

If nOpc = 4
	For nItem := 1 to Len(aCols)
	   If aCols[nItem][nPosDele] .And. nItem <= nLenCols
			Aviso("TK271BOK", "Não permitido deletar linha na rotina de alteração", {"Fechar"})
			Return .F.
	   Endif
	Next
Endif	

IF nOpc = 4 .OR. nOpc = 3 //Só inclusão e alteração ATERMSMENUDEF
    //cAcaoFlg := Posicione("SUQ",1,xFilial("SUQ") + SUC->UC_CODIGO, "UQ_XENVPFO")
    
    /*----------------------------------------
    	22/03/2019 - Jonatas Oliveira - Compila
    	Realiza conferencia de campos obrigatórios
    	para integração
    ------------------------------------------*/
    _cCpfCt := Posicione("SU5",1,xFilial("SU5") + M->UC_CODCONT, "U5_CPF")
    _cCpfCt := STRTRAN(_cCpfCt, ".", "")
    _cCpfCt := STRTRAN(_cCpfCt, "-", "")
    
    
    IF EMPTY(_cCpfCt)
    	lRetorno 	:= .F.
    	cRetWS 		+=  "Obrigatório o CPF do contato " + CRLF
    ENDIF 
    
    IF EMPTY(M->UC_XFONE1)
    	lRetorno 	:= .F.
    	cRetWS 		+=  "Obrigatório o Telefone do contato " + CRLF
    ENDIF 
    
//    IF EMPTY(M->UC_OBS)
//    	lRetorno 	:= .F.
//    	cRetWS 		+=  "Obrigatório informar Observação do atendimento. " + CRLF
//    ENDIF 
  
	If lRetorno 
		For nItem := 1 to Len(aCols)    
		
			// Salvar maior SLA para gravar no campo UC_xSLA UC_XDTSLA  - UC_XSLSLA,UD_xSLA e UD_XSLSLA
			If M->UC_xSLA < aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XSLA"}))]
				M->UC_xSLA 	:= aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XSLA"}))]
				M->UC_XDTSLA:= (MSDATE())+ aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XSLA"}))]
			Endif
			aCols[nItem][nPosSlSLA] := ( M->UC_XDTSLA -(MSDATE()) )	
			M->UC_XSLSLA	:= ( M->UC_XDTSLA -(MSDATE()) )	
	    //	If !aCOLS[n][nUsado+1] 	// SE não deletado
			If !aCols[nItem][nPosDele]
				aadd(alCodResp,Alltrim(aCols[nItem][ AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XRESPAD"})]))
			 	cAcaoFlg := Posicione("SUQ",1,xFilial("SUQ") + aCols[nItem][nPosAcao], "UQ_XENVPFO")
				If aCols[nItem][nPosStat] == "1"
					If cAcaoFlg = "1"     //aCols[nItem][nPosAcao] == cAcaoFlg
					/*-----------------------------------------------------------------------------------------------------
							Monta o CardData para Iniciar a Tarefa no Fluig somente se estiver flegado
					  -----------------------------------------------------------------------------------------------------	
					*/ 
                        Do Case
    		               Case M->UC_XTIPO == "1"
				 	          _cTipo := "SAC"
				           Case M->UC_XTIPO == "2"
					          _cTipo := "Concierge Medico"
        			    EndCase 
        			    
        			    Do Case
				           Case M->UC_XPRIORI	== "1"
         				     _cPrio := "Baixa"       
		                   Case M->UC_XPRIORI	== "2"
					         _cPrio := "Media"
				           Case M->UC_XPRIORI	== "3"
					         _cPrio := "Alta"
				           Case M->UC_XPRIORI	== "4"
					         _cPrio := "Critica"
				        EndCase
                        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                        //³ Verifica tabela de ocorrências                                            ³
                        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
                        cTabela  := "T1"
                        _cDesOco := GetAdvFVal("SX5","X5_DESCRI",XFILIAL("SX5")+cTabela+Alltrim(aCols[nItem][6]))    
                        _CodEnt  := Left((Posicione("AC8",1,xFilial("AC8")+PADR(M->UC_CODCONT,6)+Alltrim(M->UC_ENTIDAD),"AC8_CODENT")),6)
                           
                        
                        DbSelectArea("SUD")
                        DbGoTop()

						U_TMKXCRD(@aCardData, "idGrupoEmpresas"			, SM0->M0_CODIGO)
						U_TMKXCRD(@aCardData, "descGrupoEmpresas"		, SM0->M0_NOME)
						U_TMKXCRD(@aCardData, "idFilial"				, alltrim(M->UC_XCODUNI))//AllTrim(SM0->M0_CODFIL))
						U_TMKXCRD(@aCardData, "descFilial"				, alltrim(M->UC_XUNIDAD))
						U_TMKXCRD(@aCardData, "login"					, SuperGetMv("MV_ECMUSER"))
						U_TMKXCRD(@aCardData, "colleagueName"			, SuperGetMv("MV_ECMUSER"))
						U_TMKXCRD(@aCardData, "idMarca"	        		, Alltrim(M->UC_XCDMARC))
						U_TMKXCRD(@aCardData, "descMarca"		    	, Alltrim(M->UC_XMARCA))
						U_TMKXCRD(@aCardData, "idAtendimento"			, Alltrim(M->UC_CODIGO)+StrZero(nItem,2))
						U_TMKXCRD(@aCardData, "tpAtendimento"			, Alltrim(_cTipo))
						U_TMKXCRD(@aCardData, "prioridade"			    , Alltrim(_cPrio))
						U_TMKXCRD(@aCardData, "idOperador"			    , Alltrim(M->UC_OPERADO))
						U_TMKXCRD(@aCardData, "nmOperador"			    , Posicione("SU7", 1, xFilial("SU7") + M->UC_OPERADO, "U7_NOME"))
//						U_TMKXCRD(@aCardData, "idEntidade"			    , Posicione(Alltrim(M->UC_ENTIDAD),1,xFilial(Alltrim(M->UC_ENTIDAD)) + M->UC_CODCONT, IIF(Alltrim(M->UC_ENTIDAD)=='AC4',"AC4_PARTNE","ACH_CODIGO")))
//						U_TMKXCRD(@aCardData, "nmEntidade"			    , Posicione(Alltrim(M->UC_ENTIDAD),1,xFilial(Alltrim(M->UC_ENTIDAD)) + M->UC_CODCONT, IIF(Alltrim(M->UC_ENTIDAD)=='AC4',"AC4_NOME","ACH_RAZAO")))	// 

//						U_TMKXCRD(@aCardData, "idEntidade"			    , Posicione(Alltrim(M->UC_ENTIDAD),1,xFilial(Alltrim(M->UC_ENTIDAD)) + IIF(Alltrim(M->UC_ENTIDAD)=='AC4',_CodEnt,_CodEnt), IIF(Alltrim(M->UC_ENTIDAD)=='AC4',"AC4_PARTNE",IIF(Alltrim(M->UC_ENTIDAD)=='SUS',"US_COD","ACH_CODIGO"))))
//						U_TMKXCRD(@aCardData, "nmEntidade"			    , Posicione(Alltrim(M->UC_ENTIDAD),1,xFilial(Alltrim(M->UC_ENTIDAD)) + IIF(Alltrim(M->UC_ENTIDAD)=='AC4',_CodEnt,_CodEnt), IIF(Alltrim(M->UC_ENTIDAD)=='AC4',"AC4_NOME",IIF(Alltrim(M->UC_ENTIDAD)=='SUS',"US_NOME","ACH_RAZAO"))))	
						U_TMKXCRD(@aCardData, "idEntidade"			    , Posicione(Alltrim(M->UC_ENTIDAD),1,xFilial(Alltrim(M->UC_ENTIDAD)) + IIF(Alltrim(M->UC_ENTIDAD)=='AC4',_CodEnt,_CodEnt), IIF(Alltrim(M->UC_ENTIDAD)=='AC4',"AC4_PARTNE","ACH_CODIGO")))
						U_TMKXCRD(@aCardData, "nmEntidade"			    , Posicione(Alltrim(M->UC_ENTIDAD),1,xFilial(Alltrim(M->UC_ENTIDAD)) + IIF(Alltrim(M->UC_ENTIDAD)=='AC4',_CodEnt,_CodEnt), IIF(Alltrim(M->UC_ENTIDAD)=='AC4',"AC4_NOME","ACH_RAZAO")))	
						
						U_TMKXCRD(@aCardData, "TPEntidade"			    , IIf(Alltrim(M->UC_ENTIDAD)=='AC4','PACIENTE','MÉDICO'))
																
						U_TMKXCRD(@aCardData, "idContado"			    , Alltrim(M->UC_CODCONT))
						U_TMKXCRD(@aCardData, "nmContato"			    , Posicione("SU5",1,xFilial("SU5") + M->UC_CODCONT, "U5_CONTAT"))
						U_TMKXCRD(@aCardData, "cpfContato"			    , Posicione("SU5",1,xFilial("SU5") + M->UC_CODCONT, "U5_CPF"))
						U_TMKXCRD(@aCardData, "emailContato"			, Alltrim(M->UC_XEMAIL)) 
						U_TMKXCRD(@aCardData, "telefoneContato"			, Alltrim(M->UC_XFONE1))
						U_TMKXCRD(@aCardData, "telefone2Contato"		, Alltrim(M->UC_XFONE2))
						U_TMKXCRD(@aCardData, "celularContato"			, Alltrim(M->UC_XCELULA))
						U_TMKXCRD(@aCardData, "idMedico"			    , Alltrim(M->UC_XCODMED))
						U_TMKXCRD(@aCardData, "nmMedico"			    , Alltrim(M->UC_XMEDICO))
						U_TMKXCRD(@aCardData, "crm"			            , Alltrim(M->UC_XCRM))
						U_TMKXCRD(@aCardData, "ufCrm"			        , Alltrim(M->UC_XCRMUF))
						U_TMKXCRD(@aCardData, "obsAtendimento"			, Alltrim(M->UC_OBS))  //MSMM(M->UC_OBS,80, ,,3, , ,"SUC","M->UC_OBS"))
						U_TMKXCRD(@aCardData, "dtAcao"		        	, aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_DATA"}))])
						U_TMKXCRD(@aCardData, "idClassificacao"			, Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XCLASSI"}))]))
						U_TMKXCRD(@aCardData, "descClassificacao"		, Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XDESCLA"}))]))
						U_TMKXCRD(@aCardData, "dtPrazo"			        , aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_DTEXEC"}))])
						U_TMKXCRD(@aCardData, "idAssunto"			    , Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_ASSUNTO"}))]))
						U_TMKXCRD(@aCardData, "descAssunto"	     		, Alltrim(_cDesOco))  
						cUD_OCORREN := Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_OCORREN"}))])
						U_TMKXCRD(@aCardData, "idOcorrencia"			, cUD_OCORREN)
						U_TMKXCRD(@aCardData, "descOcorrencia"			, Posicione("SU9",2,xFilial("SU9") + cUD_OCORREN, "U9_DESC"))
						
						cUDTPOCORR := Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XCODTPO"}))])
						U_TMKXCRD(@aCardData, "tpOcorrencia"	        , Alltrim(cUDTPOCORR))						
						
						cUD_SOLUCAO :=Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_SOLUCAO"}))])
						U_TMKXCRD(@aCardData, "idAcao"			        , cUD_SOLUCAO)
						U_TMKXCRD(@aCardData, "descAcao"			    , Posicione("SUQ",1,xFilial("SUQ") + cUD_SOLUCAO,"UQ_DESC"))
						U_TMKXCRD(@aCardData, "obsAcao"				    , Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_OBS"}))]))
						U_TMKXCRD(@aCardData, "obsComplementoAcao"	    , Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_OBSEXEC"}))]))
						U_TMKXCRD(@aCardData, "idResponsavel"			, Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_OPERADO"}))]))
						U_TMKXCRD(@aCardData, "nmResponsavel"			, Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_DESCOPE"}))]))
						/*(AScan(aHeader, {|x| AllTrim(x[2]) == "UD_SOLUCAO"}))
						
						-----------------------------------------------------------------------------------------------------
							Inicia a Tarefa no FluigPosicione("SUD",1,xFilial("SUD") + SUC->UC_CODIGO, "UD_DESCASS"))
						-----------------------------------------------------------------------------------------------------	
						*/ 
						
						
						If Alltrim(aCols[nItem][nPosITEM]) == ""
							aCols[nItem][nPosITEM] := StrZero(nItem,2)
						Endif
						
						If Alltrim(aCols[nItem][nPosSUBI]) == ""
							aCols[nItem][nPosSUBI] := StrZero(nItem,2)+"00"
							//aCols[nItem][nPosSUBI] := Alltrim(aCols[nItem][ (AScan(aHeader, {|x| AllTrim(x[2]) == "UD_ITEM"}))])+"00" 
						Endif	

						nSitMov:=aCols[nItem][ AScan(aHeader, {|x| AllTrim(x[2]) == "UD_XIDFLUI"})]
						If nSitMov == 0
							If U_TMKXFLG(aCardData, "Processo", 10, @cRetWS, "")
								//Gravar ID Fluig no Item do Atendimento77
								aCols[nItem][nPosIDFl] := VAL(cRetWS)
								
							Else
								Aviso("TK271BOK", STRTRAN(cRetWS,"!</br>", " "), {"Fechar"})
								lRetorno := .F.
								Exit
							EndIf
						Endif
					Else
						If Alltrim(aCols[nItem][nPosSUBI]) == ""
							aCols[nItem][nPosSUBI] := StrZero(nItem,2)+"00"
						Endif	
						If cAcaoFlg = "3" .And. nOpc = 4 .And. aCols[nItem][nPosStat] = '1'  // Cancelamento
							If U_TMKENCF(aCols[nItem][nPosIDFl], 10, @cRetWS)
								//Enviar mensagem de cancelamento o Fluig
								aCols[nItem][nPosStat] := "2"
							Else
								Aviso("TK271BOK - Cancelamento FLuig", cRetWS, {"Fechar"})
							EndIf						
						Endif
					EndIf
				EndIf
			EndIf
		Next nItem
	
	Else 	
		AVISO("TK271BOK",cRetWS,{"Fechar"}, 3, ,, , .T.,  )			
	EndIf
	
	cRetWS := STRTRAN(cRetWS,"!</br>", " " + CRLF)
/*
    IF SUD->UD_STATUS = "2"
       U_TMKCANC( nOpcA )
    ENDIF                 
*/
ENDIF

/*------------------------------------------------------ Augusto Ribeiro - compila.com.br 
	Envio de SMS 
------------------------------------------------------------------------------------------*/
IF lRetorno .AND. GETMV("AL_SACSMS",.F.,.F.)
	SendSMS()
ENDIF

//|lRetorno := .T. //| Coloquei(Fabio Sales) para poder efetuar os teste, pois estava conseguindo acessar o Fluig.

IF lRetorno .AND. LEN(alCodResp) > 0 .and. GetNewPar("AL_SACMAIL",.T.)

	AlSendMail(alCodResp)
	
ENDIF            

RestArea( aArea )
Return lRetorno




/*/{Protheus.doc} function_method_class_name
(long_description)
@author Augusto Ribeiro | www.compila.com.br
@since 26/06/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SendSMS()
Local cMsgSMS, cCel


IF !EMPTY(M->UC_XCELULA)
	

	cCel	:= STRTRAN(STRTRAN(alltrim(M->UC_XDDD)+alltrim(M->UC_XCELULA)," ",""),"-","")
	IF LEFT(cCel,1) == "0"
		cCel	:= SUBSTR(cCel,2,LEN(cCel)-1)
	ENDIF

	cMsgSMS	:= "Protocolo de Atendimento "+ALLTRIM(M->UC_XMARCA)+": "+ALLTRIM(M->UC_CODIGO)
	
	/*------------------------------------------------------  Augusto Ribeiro - compila.com.br
		Funcao de envio de SMS
	------------------------------------------------------------------------------------------*/
	U_alSendSMS(cCel,cMsgSMS)
ENDIF
	
Return()


/*/{Protheus.doc} SendMail
Envia e-mail de acordo e-mail.
@author Fabio Sales | www.compila.com.br
@since 01/05/2018
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/

STATIC FUNCTION AlSendMail(alCodResp)

	Local nJ := 0
	
	For nJ := 1 To Len(alCodResp)
		
		U_TMKWFENV(alCodResp[nJ])
				
	Next nJ

RETURN()