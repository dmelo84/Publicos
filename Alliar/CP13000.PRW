#Include 'Protheus.ch'
#Include 'RestFul.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "TopConn.ch"


#DEFINE PATH_SAVE_PDF	"\data_custom\pdf_nf_municipal\"
#DEFINE CP13_STATU_ATIVO	"1"
#DEFINE CP13_STATU_INATIVO	"2"


/*/{Protheus.doc} CP13GNF
Retorna dados das Notas Fiscais no qual ainda não possuem PDF da prefeitura 
@author Augusto Ribeiro | www.compila.com.br
@since 10/10/2018
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP13GNF(cFCodMun)
Local cJsonRet	:= ""
Local cQuery	:= ""
Local cFilNF	:= ""
Local nFil		:= 0
Local cCnpj, cInscM, cCodMun, cUF, cMunic
Local nTopNF	:= GETMV("CP13_TOPNF",.F.,50)
Local aXCVNFS	:= TAMSX3("F2_XCVNFS")
Local nXCVNFS	:= 0


Default cFCodMun	:= ""

IF !EMPTY(aXCVNFS)
	nXCVNFS		:= aXCVNFS[1]
ENDIF

cQuery := " SELECT " 
IF nTopNF > 0
	cQuery += " TOP "+ALLTRIM(STR(nTopNF)) 
ENDIF
cQuery += " SF2.F2_FILIAL, "+CRLF
cQuery += " 	SF2.F2_SERIE, "+CRLF
cQuery += " 	SF2.F2_DOC, "+CRLF
cQuery += " 	SF2.F2_NFELETR, "+CRLF
IF nXCVNFS > 0
	cQuery += " 	SF2.F2_XCVNFS, "+CRLF	
ENDIF
cQuery += " 	SF2.F2_CODNFE, "+CRLF
cQuery += " 	SF2.F2_CHVNFE, "+CRLF
cQuery += " 	CASE WHEN SZK.ZK_ESTCOB = 'DF' THEN 'S' ELSE 'N' END AS FILDF, "+CRLF
cQuery += " 	SF2.R_E_C_N_O_  AS SF2_RECNO "+CRLF
cQuery += " FROM "+RetSqlName("SF2")+" SF2  WITH(NOLOCK) "+CRLF
cQuery += " INNER JOIN "+RetSqlName("SZK")+" SZK  WITH(NOLOCK) "+CRLF
cQuery += " ON SZK.ZK_CODIGO = '"+SM0->M0_CODIGO+"' " 	
cQuery += " AND SZK.ZK_CODFIL = SF2.F2_FILIAL "+CRLF
cQuery += " AND SZK.ZK_XCP13ST = '1' "+CRLF
cQuery += " AND SZK.D_E_L_E_T_ = ''	 "+CRLF


cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1  WITH(NOLOCK) "+CRLF
cQuery += " 	ON A1_COD = F2_CLIENTE "+CRLF
cQuery += " 	AND A1_LOJA = F2_LOJA  "+CRLF
nTpPessoa	:= ALLTRIM(GETMV("CP13_TPPES",.F.,"A"))
IF nTpPessoa == "F" .OR. nTpPessoa == "J"
	cQuery += " 	AND A1_PESSOA = '"+nTpPessoa+"' "+CRLF
ENDIF	
cQuery += " 	AND SA1.D_E_L_E_T_ = ''	 "+CRLF
cQuery += " WHERE SF2.F2_EMISSAO >= '"+DTOS(GETMV("CP13_DTIMP",.F.,DDATABASE-30))+"'"+CRLF
cQuery += " AND SF2.F2_XPDFNF = '' "+CRLF
cQuery += " AND ((SZK.ZK_ESTCOB = 'DF' AND SF2.F2_CHVNFE <> '' AND SF2.F2_DAUTNFE <> '') OR  SF2.F2_NFELETR <> '') "+CRLF
cQuery += " AND SF2.D_E_L_E_T_ = '' "+CRLF
cQuery += " ORDER BY F2_FILIAL, F2_SERIE, F2_DOC "+CRLF

If Select("TSQL") > 0
	TSQL->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						

IF TSQL->(!EOF())


	DBSELECTAREA("SM0")
	aAreaSM0	:= SM0->(GETAREA())

	cJsonRet	+= "["
	
	WHILE TSQL->(!EOF())
		cFilNF	:= TSQL->F2_FILIAL
		nFil++
		
		IF nFil > 1
			cJsonRet	+= ","
		ENDIF
		
		cJsonRet	+= '{'
		/*--------------------------
			Dados da Filial
		---------------------------*/
		SM0->(DBGOTOP())
		lPosFil	:= .f.
		WHILE SM0->(!EOF())
		
			IF ALLTRIM(cFilNF) == ALLTRIM(SM0->M0_CODFIL)
		
				lPosFil	:= .t.
				cCnpj	:= ALLTRIM(SM0->M0_CGC)
				cInscM	:= ALLTRIM(SM0->M0_INSCM)
				cCodMun	:= ALLTRIM(SM0->M0_CODMUN)
				cUF		:= ALLTRIM(SM0->M0_ESTCOB)
				cMunic	:= ALLTRIM(SM0->M0_CIDCOB)
				
				EXIT
			ENDIF
		
			SM0->(DBSKIP())
		ENDDO
		
		IF lPosFil
		
		
			cJsonRet += U_cpxToJson("EMITENTE",cCnpj)+","
			cJsonRet += U_cpxToJson("INSCM",cInscM)+","
			cJsonRet += U_cpxToJson("CODMUN",cCodMun)+","
			cJsonRet += U_cpxToJson("UF",cUF)+","
			cJsonRet += U_cpxToJson("MUNICIPIO",cMunic)+","
			cJsonRet += '"NOTAS":['			
			
			nQtdNF	:= 0
			WHILE TSQL->(!EOF()) .and. cFilNF == TSQL->F2_FILIAL
				nQtdNF++				
				IF nQtdNF > 1
					cJsonRet	+= ","
				ENDIF
				
				cJsonRet += "{"
				
				/*------------------------------------------------------ Augusto Ribeiro | 03/04/2019 - 9:43:20 AM
					Tratamento diferenciado para Distrito Federal (DF)
				------------------------------------------------------------------------------------------*/
				IF TSQL->FILDF == "S"
					cJsonRet += U_cpxToJson("NF",ALLTRIM(TSQL->F2_DOC))+","
					cJsonRet += U_cpxToJson("CHV",ALLTRIM(TSQL->F2_CHVNFE))
				ELSE
					cJsonRet += U_cpxToJson("NF",ALLTRIM(TSQL->F2_NFELETR))+","
					IF IIF(nXCVNFS > 0, !EMPTY(SF2->F2_XCVNFS), .F.)
						cJsonRet += U_cpxToJson("CHV",ALLTRIM(TSQL->F2_XCVNFS))
					ELSE
						cJsonRet += U_cpxToJson("CHV",ALLTRIM(TSQL->F2_CODNFE))
					ENDIF
				ENDIF
				cJsonRet += "}"
			
			
				TSQL->(DBSKIP()) 
			ENDDO			
			cJsonRet += ']'
		ELSE			
			CONOUT("CP13GNF", "Filial não localizada na SM0 ["+cFilNF+"]")
			TSQL->(DBSKIP()) 
		ENDIF	
		cJsonRet	+= '}'	
	ENDDO
	cJsonRet	+= ']'
	
	
	RestArea(aAreaSM0)
ELSE
	cJsonRet	:= "[]"
ENDIF

TSQL->(DbCloseArea())
	

IF EMPTY(cJsonRet)
	cJsonRet	:= "[]"
ENDIF



Return(cJsonRet)




/*/{Protheus.doc} CP13GFTP
Busca PDF das notas fiscais que foram disponibilizadas pelo Motor Fiscal
@author Augusto Ribeiro | www.compila.com.br
@since 10/10/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP13GFTP()
Local cExtArq		:= "*.pdf"
Local nF2FILIAL	:= TAMSX3("F2_FILIAL")[1]
Local cFTPURL	:= ALLTRIM(GetMV("CP13_URFTP",.F.,""))
Local cFTPUser	:= ALLTRIM(GetMV("CP13_LGFTP",.F.,""))
Local cFTPPass	:= ALLTRIM(GetMV("CP13_SNFTP",.F.,""))
Local nFTPPort	:= GetMV("CP13_PTFTP",.F.,21)
Local cFTPDir	:= ALLTRIM(GetMV("CP13_DRFTP",.F.,""))
Local cMsgErro	:= ""
Local nI, cNomeArq, cFilPDF, cCnpjPDF
Local oFTP, nY, aRetFil

//|### remover |
//cFTPURL		:= "35.243.134.35"
//cFTPUser	:= "rpa_oncoclinica@compila.com.br"
//cFTPPass	:= "RPA@Onco123456"
//|### remover |

IF !EMPTY(cFTPURL)

	oFTP	:= tFtpClient():New()
	oFTP:bFirewallMode 			:= .T.
	// oFTP:nTransferMode		:= 
	//oFTP:bUsesIPConnection	:= 1
	
	IF oFTP:FTPConnect(cFTPURL, nFTPPort, cFTPUser, cFTPPass) == 0
		oFTP:SetType(1)
		
		IF !EMPTY(cFTPDir)
			IF !(oFTP:ChDir(cFTPDir))
	
				cMsgErro	:= "Falha ao posicionar na Pasta do FTP: "+cFTPDir    
			ENDIF
		ENDIF
	         
		IF EMPTY(cMsgErro)	
			aDirFTP	:= oFTP:Directory(cExtArq)
			
			IF !EMPTY(aDirFTP)
				//| Ordena Array |
				aSort(aDirFTP,,,{ |x,y| x[1]< y[1] })					
				
				
				cFilPDF		:= ""
				cCnpjPDF	:= "" 
				cCnpjFil	:= ""
				FOR nI := 1 to len(aDirFTP)
					cNomeArq	:= ALLTRIM(LOWER(ALLTRIM(aDirFTP[nI,1])))
				
					nPos_		:= at("_", cNomeArq)
					nPosDot		:= at(".", cNomeArq)
					IF nPos_ > 1 .and. nPosDot > 1
						//| Separa CNPJ do nome do arquivo |
						cCnpjPDF	:= LEFT(cNomeArq,nPos_-1)
						cNumNFE		:= SUBSTR(cNomeArq,nPos_+1, nPosDot-nPos_-1)
						
						/*--------------------------
							Localiza Filial
						---------------------------*/
						
						IF cCnpjFil <> cCnpjPDF
							aRetFil	:= {}
							cFilPDF		:= ""
							cCnpjFil	:= ""						
						
							aRetFil	:= FILSM0(cCnpjPDF)

							IF !EMPTY(aRetFil)
								cCnpjFil 	:= cCnpjPDF
								//cFilPDF		:= PADR(ALLTRIM(aRetFil[1,2]),nF2FILIAL)
							ELSE
								cMsgErro	:= "Filial nao localizada ["+cCnpjPDF+"]"+CRLF
							ENDIF
						ENDIF
						
						
						//|### remover |
						//| cFilPDF	:= "01"
						IF !EMPTY(aRetFil)
							FOR nY := 1 to LEN(aRetFil)
							
								cFilPDF		:= PADR(ALLTRIM(aRetFil[nY,2]),nF2FILIAL)
							
								/*----------------------------
									Posiciona na Nota Fiscal
								-----------------------------*/
								DBSELECTAREA("SF2")
								SF2->(DBSETORDER(8)) //| F2_FILIAL, F2_NFELETR, F2_EMINFE, F2_CLIENTE, F2_LOJA, R_E_C_N_O_, D_E_L_E_T_
								IF SF2->(DBSEEK(cFilPDF+cNumNFE,.F.)) 
									
									aDirSave	:= DirSave(PATH_SAVE_PDF)
									IF aDirSave[1]
										//IF oFTP:ReceiveFile( cNomeArq, aDirSave[3]+cNomeArq )
										IF oFTP:ReceiveFile( cNomeArq, aDirSave[3]+cNomeArq ) == 0
											
											RECLOCK("SF2",.F.)
												SF2->F2_XPDFNF	:= aDirSave[3]+cNomeArq
											MSUNLOCK()
											
											
											oFTP:DeleteFile(cNomeArq)
											
										ENDIF
									ELSE 
										cMsgErro	:= aDirSave[2]+CRLF
									ENDIF
									
									EXIT
								ENDIF
							
							NEXT nY
						ELSE
							cMsgErro	:= "Filial nao localizada ["+cCnpjPDF+"]"+CRLF
						ENDIF
					
					ELSE
						cMsgErro	:= "Nome do arquivo fora do padrão. '_' nao localizado ["+cNomeArq+"]"+CRLF				
					ENDIF				
				NEXT nI
			ENDIF
		ENDIF				                
		
			
		oFTP:Close()
	ELSE
		cMsgErro	:= " Não foi possível conectar ao servidor FTP: "+cFTPURL+" Erro: "+oFTP:GetLastResponse()
	ENDIF
ELSE  
	cMsgErro	:= "URL FTP vazio. verifique o parametro [CP13_URFTP]"+CRLF
ENDIF

Return(cMsgErro)






/*/{Protheus.doc} DirSave
Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
@author Augusto Ribeiro | www.compila.com.br
@since 14/01/2015
@version 1.0
@param ${dDataRef}, ${D}, ${Data de referencia - Utilizado para criar o diretorio onde ser armazenado o arquivo}
@return aRet,  {.F., cMsgErro, cPaths}
/*/
Static Function DirSave(cPath)
Local aRet			:= {.F., "", ""}
Local cAnoMes, cDirComp, cCurDir, nAux
Local aPath, nI
Local cNewPath, aNewPath


/*
#DEFINE DIR_TEMP "\data_braspag\temp\"
#DEFINE DIR_IMPORTADO "\data_braspag\importado\"
*/

IF !EMPTY(cPath)

	cNewPath	:= ALLTRIM(cPath)+LEFT(DTOS(DDATABASE),6)
	
	
	cCurDir	:= CurDir()
	CurDir("\")
	/*------------------------------------------------------ Augusto Ribeiro | 27/11/2016 - 12:42:46 PM
		Verifica se o caminho existe, caso não, cria as patas
	------------------------------------------------------------------------------------------*/
	IF !ExistDir(cNewPath)
	
		aNewPath	:= StrTokArr(cNewPath, "\" )
		
		FOR nI := 1 to len(aNewPath)
		
			IF ExistDir(aNewPath[nI])
				CurDir(aNewPath[nI])
			ELSE
				nAux	:= MakeDir(aNewPath[nI])
				IF nAux == 0
					CurDir(aNewPath[nI])
				ELSE
					aRet[2] := "Nao foi possivel criar o diretorio ["+CurDir()+"\"+aNewPath[nI]+"]. Cod. Erro: "+alltrim(str(FError()))
					CONOUT("CP13000.PRW [DirSave] | "+aRet[2] )
					EXIT
				ENDIF			
			ENDIF
		
		NEXT nI	
	
	ENDIF
	
	
	IF ExistDir(cNewPath)
		aRet[1]	:= .t.
		aRet[3]	:= cNewPath+"\"
	ELSE
		aRet[2] := "Não foi possivel localiar o diretorio ["+cNewPath+"]"
	ENDIF

	CurDir(cCurDir) 	
ENDIF


Return(aRet)







/*/{Protheus.doc} CP13JOBF
Job para busca dos PDF's automaticamento do FTP
@author Augusto Ribeiro | www.compila.com.br
@since 16/10/2018
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP13JOBF(aParam)
lOCAL cTeste	:= ''
lOCAL aTeste	:= {}
Local lRetAux
Default aParam	:= {"01","02201"}

CONOUT("CP13JOBF - INICIO "+DTOC(DATE())+" "+TIME())

_cEmp		:= aParam[1]
_cFilial	:= aParam[2]                      

PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial

//U_CP13GNF()
U_CP13GFTP()

RESET ENVIRONMENT 

CONOUT("CP13JOBF - FIM "+DTOC(DATE())+" "+TIME())

Return







                                        

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fEmpFil  ºAutor  ³Augusto Ribeiro     º Data ³ 04/12/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorno Empresa Filial do SM0 do CNPJ passado              º±±
±±º          ³                                                            º±±
±±ºParametros³ cCNPJ                                                      º±±
±±ºRetorno   ³ aRet := {cCodEmp, cCodFild}                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  

/*/{Protheus.doc} CPXFILSM0
Retorno Empresa Filial do SM0 do CNPJ passado
@author Augusto Ribeiro | www.compila.com.br
@since 11/06/2014
@version 1.0
@param cCNPJ, C, cnpj
@return  aRet, {cCodEmp, cCodFild}  
/*/
Static Function FILSM0(cCNPJ)
Local aRet		:= {}
Local aAreaSM0 



                                                     
IF !EMPTY(cCNPJ)           
	cCNPJ	:= ALLTRIM(cCNPJ)

	DBSELECTAREA("SM0")
	aAreaSM0 := SM0->(GetArea())
	
	IF ALLTRIM(SM0->M0_CGC) == cCNPJ 
		aadd(aRet, {SM0->M0_CODIGO, SM0->M0_CODFIL})
	ELSE
		SM0->(DBGOTOP())  
		
		WHILE SM0->(!EOF())        

			IF ALLTRIM(SM0->M0_CGC) == cCNPJ  
				aadd(aRet, {SM0->M0_CODIGO, SM0->M0_CODFIL})				
			ENDIF		    
		    
			SM0->(DBSKIP())
		ENDDO
	ENDIF   

	RestArea(aAreaSM0)
ENDIF

Return(aRet)  



/*/{Protheus.doc} CP13SPDF
(long_description)
@author Augusto Ribeiro | www.compila.com.br
@since 14/01/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP13SPDF(cJson)
Local aRet		:= {.f.,""}
Local nF2FILIAL	:= TAMSX3("F2_FILIAL")[1]
Local oJson
Local cCnpjPDF, cNumNFE, cChvNF, cPDF, cPDFSTR
Local cCnpjFil	:= ""
Default cJson	:= ""	



IF !EMPTY(cJson)	
	
	IF FWJsonDeserialize(cJson,@oJson)
		IF AttIsMemberOf(oJson, "EMITENTE")
			cCnpjPDF	:= oJson:EMITENTE
		ENDIF
		
		IF AttIsMemberOf(oJson, "NF")
			cNumNFE	:= oJson:NF
		ENDIF
		
		IF AttIsMemberOf(oJson, "CHV")
			cChvNF	:= oJson:CHV
		ENDIF
		
		IF AttIsMemberOf(oJson, "PDF")
			cPDF	:= oJson:PDF
		ENDIF	
		
		
		IF !EMPTY(cCnpjPDF) .AND. !EMPTY(cNumNFE) .AND. !EMPTY(cChvNF) .AND. !EMPTY(cPDF) 
		
			
			//MemoWrite( < cFile >, < cText > )
		
		
			
			/*--------------------------
				Localiza Filial
			---------------------------*/
			
			IF cCnpjFil <> cCnpjPDF
				aRetFil	:= {}
				cFilPDF		:= ""
				cCnpjFil	:= ""						
			
				aRetFil	:= FILSM0(cCnpjPDF)
	
				IF !EMPTY(aRetFil)
					cCnpjFil 	:= cCnpjPDF
					//cFilPDF		:= PADR(ALLTRIM(aRetFil[1,2]),nF2FILIAL)
				ELSE
					cMsgErro	:= "Filial nao localizada ["+cCnpjPDF+"]"+CRLF
				ENDIF
			ENDIF
			
			
			//|### remover |
			//| cFilPDF	:= "01"
			IF !EMPTY(aRetFil)
				FOR nY := 1 to LEN(aRetFil)
				
					cFilPDF		:= PADR(ALLTRIM(aRetFil[nY,2]),nF2FILIAL)
				
					/*----------------------------
						Posiciona na Nota Fiscal
					-----------------------------*/
					DBSELECTAREA("SF2")
					SF2->(DBSETORDER(8)) //| F2_FILIAL, F2_NFELETR, F2_EMINFE, F2_CLIENTE, F2_LOJA, R_E_C_N_O_, D_E_L_E_T_
					IF SF2->(DBSEEK(cFilPDF+cNumNFE,.F.))					
					
						aDirSave	:= DirSave(PATH_SAVE_PDF)
						IF aDirSave[1]
						
							cPDFSTR	:= DECODE64(cPDF)
							cNomeArq	:= cCnpjPDF+"_"+cNumNFE+".pdf"
							
						
							//IF oFTP:ReceiveFile( cNomeArq, aDirSave[3]+cNomeArq )
							IF MemoWrite( aDirSave[3]+cNomeArq, cPDFSTR)
								
								RECLOCK("SF2",.F.)
									SF2->F2_XPDFNF	:= aDirSave[3]+cNomeArq
								MSUNLOCK()
								
								
								
								/*------------------------------------------------------------
								  Realiza gravação dos dados em FTP especifico
								------------------------------------------------------------*/								
								cURLCopy	:= ALLTRIM(SUPERGETMV("CP13_U2FTP",.F.,"2", SF2->F2_FILIAL))
								IF !EMPTY(cURLCopy)
									
									///| COPIA FTP |
								
								ENDIF
								
								
								
								
								
								aRet[1]:= .T.
								
								
								/*--------------------------
									PONTO DE ENTRADA
								---------------------------*/
								IF GETMV("CP13_FLGNF",.F.,.F.)
									IF EXISTBLOCK("CP13GRVP")
										EXECBLOCK("CP13GRVP")
									ENDIF
								ENDIF
								
							ELSE 
								cMsgErro	:= "Falha na gracao do arquivo ["+aDirSave[3]+cNomeArq+"]"
							ENDIF
						ELSE 
							cMsgErro	:= aDirSave[2]+CRLF
						ENDIF
						
						EXIT
					ENDIF
				
				NEXT nY
			ELSE
				cMsgErro	:= "Filial nao localizada ["+cCnpjPDF+"]"+CRLF
			ENDIF
		ELSE
			cMsgRet:= "Json incompleto, verifique os parametros passados. [CP13SPDF]"
		ENDIF					
		
	ELSE
		cMsgRet:= "Não foi poossível desserializar o objeto. [CP13SPDF]"
	ENDIF
	
ELSE
	cMsgRet:= "Parâmetro Vazio, não contém dados de Json. [CP13SPDF]"
ENDIF


Return(aRet)




/*/{Protheus.doc} CP13CNPJ
Retornar JSON com todos os CNPJ's com o parametro de Status Ativo
@author Augusto Ribeiro | www.compila.com.br
@since 15/01/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP13CNPJ()
Local nQtdeFil	:= 0
Local cJsonRet	:= ""
DBSELECTAREA("SM0")
aAreaSM0	:= SM0->(GETAREA())

_cCodEmp 	:= SM0->M0_CODIGO
_cCodFil	:= SM0->M0_CODFIL

SM0->(DBGOTOP())
cJsonRet	:= "["
WHILE SM0->(!EOF())
	
	IF _cCodEmp == SM0->M0_CODIGO
		IF ALLTRIM(SUPERGETMV("CP13_STATU",.F.,"2", SM0->M0_CODFIL)) == CP13_STATU_ATIVO
			nQtdeFil++				
			IF nQtdeFil > 1
				cJsonRet	+= ","
			ENDIF
			
			cJsonRet += "{"
			cJsonRet += U_cpxToJson("SEQ",		 		nQtdeFil)+","
			cJsonRet += U_cpxToJson("EMPRESA", 			SM0->M0_CODIGO)+","
			cJsonRet += U_cpxToJson("FILIAL", 			SM0->M0_CODFIL)+","
			cJsonRet += U_cpxToJson("FANTASIA",			SM0->M0_FILIAL)+","
			cJsonRet += U_cpxToJson("RAZAO", 			SM0->M0_NOMECOM)+","
			cJsonRet += U_cpxToJson("CNPJ", 			SM0->M0_CGC)+","
			cJsonRet += U_cpxToJson("INSC_ESTADUAL", 	SM0->M0_INSC)+","
			cJsonRet += U_cpxToJson("INSC_MUNICIPAL", 	SM0->M0_INSCM)+","
			cJsonRet += U_cpxToJson("ESTADO", 			SM0->M0_ESTCOB)+","
			cJsonRet += U_cpxToJson("MUNICIPIO", 		SM0->M0_CIDCOB)+","
			cJsonRet += U_cpxToJson("CODMUN", 			SM0->M0_CODMUN)
			cJsonRet += "}"
		
		ENDIF
	ENDIF

	SM0->(DBSKIP())
ENDDO
SM0->(RESTAREA(aAreaSM0))
cJsonRet	+= "]"

RestArea(aAreaSM0)

Return(cJsonRet)





/*/{Protheus.doc} CP13NFLG
Envia nota fiscal para o Fluig com base no Recno passado.
@author Augusto Ribeiro | www.compila.com.br
@since 21/01/2019
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP13NFLG(nSF2)
Local aRet		:= {.F., ""}
Local aArea		:= GetArea()
Local cQuery	:= ""
Local aRetAux, cCompFluig, cIDUsrInt


dbselectarea("SF2")
SF2->(DBGOTO(nSF2))

cQuery := " SELECT C5_XIDFLG "+CRLF
cQuery += " FROM "+RetSqlName("SD2")+" SD2 "+CRLF
cQuery += " INNER JOIN "+RetSqlName("SF2")+" SF2 "+CRLF
cQuery += " 	ON D2_FILIAL = F2_FILIAL  "+CRLF
cQuery += " 	AND D2_DOC = F2_DOC "+CRLF
cQuery += " 	AND D2_SERIE = F2_SERIE "+CRLF
cQuery += " 	AND SF2.R_E_C_N_O_ = "+ALLTRIM(STR(nSF2))+" "+CRLF
cQuery += " 	AND SF2.D_E_L_E_T_ = '' "+CRLF
cQuery += " INNER JOIN "+RetSqlName("SC5")+" SC5 "+CRLF
cQuery += " 	ON C5_FILIAL = D2_FILIAL "+CRLF
cQuery += " 	AND C5_NUM = D2_PEDIDO "+CRLF
cQuery += " 	AND C5_XIDFLG <> '' "+CRLF
cQuery += " 	AND SC5.D_E_L_E_T_ = '' "+CRLF
cQuery += " WHERE SD2.D_E_L_E_T_ = '' "+CRLF
cQuery += " GROUP BY C5_XIDFLG "+CRLF



If Select("TPDF") > 0
	TPDF->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TPDF",.F., .T.)						


IF TPDF->(!EOF())
	cCompFluig	:= "NF: "+ALLTRIM(SF2->F2_NFELETR)
		//cpFSSTsk(nIDProc, cUserFluig, nTaskDest, cComments, lComplete, lManager, aCardData, aAnexos)
	
	cIDUsrInt	:= GETMV("MV_ECMMAT",.F.,"")
	
	aRet	:= U_cpFTakeP(VAL(TPDF->C5_XIDFLG),cIDUsrInt) //| Assume |
	IF aRet[1]
		aRet	:= U_cpFSSTsk(VAL(TPDF->C5_XIDFLG), cIDUsrInt, 36,cCompFluig, .T., .F., ,{{SF2->F2_XPDFNF,RetFileName(SF2->F2_XPDFNF)}})
	ENDIF
ELSE
	aRet[2] := "Registro nao possui ID Fluig"
ENDIF



TPDF->(DbCloseArea())



RestArea(aArea)

Return(aRet)
 
 
 
/*/{Protheus.doc} CP13CPFJ
Realiza copia para o FTP de destino job
@author Augusto Ribeiro | www.compila.com.br
@since 07/03/2019
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP13CPFJ(aParam)
lOCAL cTeste	:= ''
lOCAL aTeste	:= {}
Local lRetAux
Default aParam	:= {"01","00101"}

CONOUT("CP13CPFJ - INICIO "+DTOC(DATE())+" "+TIME())

_cEmp		:= aParam[1]
_cFilial	:= aParam[2]                      

PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial

//U_CP13GNF()
U_CP13CPFT()

RESET ENVIRONMENT 

CONOUT("CP13CPFJ - FIM "+DTOC(DATE())+" "+TIME())


Return() 
 
 
/*/{Protheus.doc} CP13CPFT
Realiza copia para o FTP de destino
@author Augusto Ribeiro | www.compila.com.br
@since 07/03/2019
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP13CPFT()
Local cExtArq	
Local nF2FILIAL	
Local cFTPURL	
Local cFTPUser	
Local cFTPPass	
Local nFTPPort	
Local cFTPDir	
Local cMsgErro
Local nRecSF2
Local cNomeArq
Local lConFTP		:= .F.
Local cMsgErro		:= ""	

Local cQuery		:= ""	
Local cInFil		:= ""



/*-------------------------------------------------------------------------------
	Busca notas fiscais somente das filiais no qual a customização esta ativa
--------------------------------------------------------------------------------*/
DBSELECTAREA("SM0")
aAreaSM0	:= SM0->(GETAREA())

_cCodEmp 	:= SM0->M0_CODIGO
_cCodFil	:= SM0->M0_CODFIL

SM0->(DBGOTOP())
WHILE SM0->(!EOF())
	
	IF _cCodEmp == SM0->M0_CODIGO
		IF ALLTRIM(SUPERGETMV("CP13_STATU",.F.,"2", SM0->M0_CODFIL)) == CP13_STATU_ATIVO
		
			/*------------------------------------------------------ Augusto Ribeiro | 15/01/2019 - 10:14:57 AM
				Filtra municipios enviado via parametro
			
			IF !EMPTY(cFCodMun)
				IF cFCodMun != ALLTRIM(SM0->M0_CODMUN)
					SM0->(DBSKIP())
					LOOP
				ENDIF
			ENDIF
			AADD(aFILCP13, SM0->M0_CODFIL)
			------------------------------------------------------------------------------------------*/
			
			
			IF !EMPTY(cInFil)
				cInFil  += ","
			ENDIF
			cInFil	+= "'"+SM0->M0_CODFIL+"'"
		ENDIF
	ENDIF

	SM0->(DBSKIP())
ENDDO
SM0->(RESTAREA(aAreaSM0))



DBSELECTAREA("SF2")
SF2->(DBSETORDER(1))

DBSELECTAREA("SA1")
SA1->(DBSETORDER(1)) //| 



cQuery := " SELECT " 
cQuery += " SF2.F2_FILIAL, "+CRLF
cQuery += " 	SF2.F2_SERIE, "+CRLF
cQuery += " 	SF2.F2_DOC, "+CRLF
cQuery += " 	SF2.F2_NFELETR, "+CRLF
cQuery += " 	SF2.F2_CODNFE, "+CRLF
cQuery += " 	SF2.R_E_C_N_O_  AS SF2_RECNO "+CRLF
cQuery += " FROM "+RetSqlName("SF2")+" SF2 "+CRLF
cQuery += " WHERE SF2.F2_EMISSAO >= '"+DTOS(GETMV("CP13_DTIMP",.F.,DDATABASE-30))+"'"+CRLF
cQuery += "	 AND SF2.F2_FILIAL IN ("+cInFil+") "
cQuery += " AND SF2.F2_XPDFNF <> '' "+CRLF
cQuery += " AND SF2.F2_XDTCOP = '' "+CRLF
cQuery += " AND SF2.D_E_L_E_T_ = '' "+CRLF
cQuery += " ORDER BY F2_FILIAL, F2_SERIE, F2_DOC "+CRLF



If Select("TNFFTP") > 0
	TNFFTP->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TNFFTP",.F., .T.)						


IF TNFFTP->(!EOF()) 


	cFilFTP	:= ""
	WHILE TNFFTP->(!EOF()) 
	
		nRecSF2		:= TNFFTP->SF2_RECNO		
		SF2->(DBGOTO(nRecSF2))
		
		
		
		/*--------------------------
			Caso filial seja diferente, realiza nova conexao ao FTP
		---------------------------*/
		IF cFilFTP <> ALLTRIM(SF2->F2_FILIAL)
			if lConFTP
				oFTP:Close()
			endif
			lConFTP		:= .F.
			
			cFTPURL		:= ALLTRIM(SUPERGETMV("OC_FTPURL",.F.,"",SF2->F2_FILIAL)) //ALLTRIM(SUPERGETMV("CP13_U2FTP",.F.,"",SF2->F2_FILIAL))
			cFTPUser	:= ALLTRIM(SUPERGETMV("OC_FTPUSR",.F.,"",SF2->F2_FILIAL))//ALLTRIM(SUPERGETMV("CP13_L2FTP",.F.,"",SF2->F2_FILIAL))
			cFTPPass	:= ALLTRIM(SUPERGETMV("OC_FTPPAS",.F.,"",SF2->F2_FILIAL))//ALLTRIM(SUPERGETMV("CP13_S2FTP",.F.,"",SF2->F2_FILIAL))
			nFTPPort	:= SUPERGETMV("CP13_P2FTP",.F.,21,SF2->F2_FILIAL)
			cFTPDir		:= ALLTRIM(SUPERGETMV("CP13_D2FTP",.F.,"",SF2->F2_FILIAL)) //| Diretorio FTP    para cópia de PDF  |
			cMsgErro	:= ""
			
			
			oFTP	:= tFtpClient():New()
			//oFTP:bFirewallMode 			:= .T.
			// oFTP:nTransferMode		:= 
			//oFTP:bUsesIPConnection	:= 1
			
			IF oFTP:FTPConnect(cFTPURL, nFTPPort, cFTPUser, cFTPPass) == 0
				lConFTP		:= .T.
				
				oFTP:SetType(1)
				
				IF !EMPTY(cFTPDir)
					IF oFTP:ChDir(cFTPDir) <> 0
						cMsgErro	:= "Falha ao posicionar na Pasta do FTP: "+cFTPDir    
					ENDIF
				ENDIF
			ENDIF

		ENDIF
		//| Realiza a conexão ao FTP |
		IF lConFTP
				
			IF EMPTY(cMsgErro)				
		
				
				cNomeArq	:= ""
				
				IF SA1->(DBSEEK(xfilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)) 
					
					cPathArquivo	:= alltrim(SF2->F2_FILIAL)+"/"+LEFT(DTOS(SF2->F2_EMISSAO),6)+"/" //| Aguardando definição da regra|
					cNomeArq		:= upper(ALLTRIM(SA1->A1_CGC)+"_"+STRTRAN(ALLTRIM(SA1->A1_NREDUZ)," ","_")+"_"+alltrim(SF2->F2_NFELETR)+".pdf")
					
					/*------------------------------------------------------ Augusto Ribeiro | 07/03/2019 - 4:13:03 PM
					 Verifica se caminho do FTP existe, a partir da pasta posicionada. 
					 Caso nao, sera criada as pastas e posiciona na pasta
					------------------------------------------------------------------------------------------*/
					DirSvFTP(@oFTP, cPathArquivo)
					
					
					IF oFTP:SendFile(alltrim(SF2->F2_XPDFNF), cNomeArq) == 0
						RECLOCK("SF2",.F.)
							SF2->F2_XDTCOP	:= date()
						MSUNLOCK()
					ELSE
						CONOUT("CP13CPFT", " Falha no Upload do arquivo  FTP: "+cFTPURL+" Erro: "+oFTP:GetLastResponse())					
					ENDIF
					
					
				
				ELSE
					CONOUT("CP13CPFT", "Cliente nao localizado para realizar a copia para o FTP de destino ["+SF2->F2_FILIAL+" "+F2_DOC+" "+F2_CLIENTE+" "+F2_LOJA+"]")		
				ENDIF
				
			
				TNFFTP->(DBSKIP()) 
				
			ELSE
				CONOUT("CP13CPFT", cMsgErro)			
			ENDIF
		ELSE
			CONOUT("CP13CPFT", " Não foi possível conectar ao servidor FTP: "+cFTPURL+" Erro: "+oFTP:GetLastResponse())
		ENDIF				
		
	ENDDO	
	


ENDIF

TNFFTP->(DbCloseArea())

 Return()
 
 
 
 
 
 
 /*/{Protheus.doc} DirSvFTP
 Verifica se caminho do FTP existe, a partir da pasta posicionada. Caso nao, sera criada as pastas e posiciona na pasta
@author Augusto Ribeiro | www.compila.com.br
@since 07/03/2019
@version 1.0
@param ${dDataRef}, ${D}, ${Data de referencia - Utilizado para criar o diretorio onde ser armazenado o arquivo}
@return aRet,  {.F., cMsgErro, cPaths}
/*/
Static Function DirSvFTP(oFtpDir, cPath)
Local aRet			:= {.F., "", ""}
Local cAnoMes, cDirComp, cCurDir, nAux
Local aPath, nI
Local cNewPath, aNewPath

Default cPath := ""

/*
#DEFINE DIR_TEMP "\data_braspag\temp\"
#DEFINE DIR_IMPORTADO "\data_braspag\importado\"
*/
cNewPath	:= cPath

IF !EMPTY(cPath)

	//cNewPath	:= ALLTRIM(cPath)+LEFT(DTOS(DDATABASE),6)
	cNewPath	:= cPath
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 27/11/2016 - 12:42:46 PM
		Verifica se o caminho existe, caso não, cria as patas
	------------------------------------------------------------------------------------------*/
	aNewPath	:= StrTokArr(cNewPath, "/" )
	
	FOR nI := 1 to len(aNewPath)
		if !empty(aNewPath[nI])
			IF oFtpDir:ChDir(aNewPath[nI]) <> 0 
				nAux	:= oFtpDir:MkDir(aNewPath[nI])
				IF nAux == 0
					oFtpDir:ChDir(aNewPath[nI])
				ELSE
					aRet[2] := "Nao foi possivel criar o diretorio ["+oFtpDir:ChDir()+"\"+aNewPath[nI]+"]. Cod. Erro: "+alltrim(str(FError()))
					CONOUT("CP13000.PRW [DirSave] | "+aRet[2] )
					EXIT
				ENDIF			
			ENDIF
		endif
	NEXT nI	
	
	
	
	
	IF EMPTY(aRet[2])
		aRet[1]	:= .t.
		aRet[3]	:= cNewPath+"/"
	ELSE
		aRet[2] := "Não foi possivel localiar o diretorio ["+cNewPath+"]"
	ENDIF
ELSE
	aRet[2] := "Path do FTP Vazio. ["+cNewPath+"]"		
ENDIF


Return(aRet)