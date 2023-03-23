#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      

#DEFINE COLUNA_LOG "LOG_IMPORTACAO"

/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclusão;
MODEL_OPERATION_UPDATE para alteração;
MODEL_OPERATION_DELETE para exclusão.
*/

/*STATUS SZB*/
//1=Pendente;2=Prv. Não Gerada. Existe NF;3=Prv. Efetivada;4=Prv. Estornada;5=Erro
#DEFINE  ZB_STATUS_PENDENTE 	'1'
#DEFINE  ZB_STATUS_NAO_GERADA 	'2'
#DEFINE  ZB_STATUS_EFETIVADA 	'3'
#DEFINE  ZB_STATUS_ESTORNADA	'4'
#DEFINE  ZB_STATUS_ERRO		'5'
#DEFINE  ZB_STATUS_REVERTIDA	'6'


//| TABELA
#DEFINE D_ALIAS 'SZB'
#DEFINE D_TITULO 'Cadastro de Provisões'
#DEFINE D_ROTINA 'ALCTB001'
#DEFINE D_MODEL 'SZBMODEL'
#DEFINE D_MODELMASTER 'SZBMASTER'
#DEFINE D_VIEWMASTER 'VIEW_SZB'

STATIC  _LBLOCKINC := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} ALCTB001
Browse, rotina de Efetivação de provisões.
@author  bruno.ferreira compila.com.br
@since   20/06/2019
/*/
//-------------------------------------------------------------------
User Function ALCTB001()
Local oBrowse
//_LBLOCKINC := U_GetAD("MV_ALCTBINC","L","Bloqueia inclusão por Fornecedor+Competencia",".T.")

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(D_ALIAS)
oBrowse:SetDescription(D_TITULO)


//| ZB_STATUS 1=Pendente;2=Prv. Não Gerada. Existe NF;3=Prv. Efetivada;4=Prv. Estornada;5=Erro
oBrowse:AddLegend( "ZB_STATUS =='1'", "YELLOW" ,   "Pendente"  )
oBrowse:AddLegend( "ZB_STATUS =='2'", "WHITE"  ,   "Provisão Não Gerada. Existe NF")
oBrowse:AddLegend( "ZB_STATUS =='3'", "GREEN"  ,   "Provisão Efetivada"  )
oBrowse:AddLegend( "ZB_STATUS =='4'", "BLUE"   ,   "Provisão Estornada"  )
oBrowse:AddLegend( "ZB_STATUS =='5'", "RED"  	,   "Erro"  )
oBrowse:AddLegend( "ZB_STATUS =='6'", "BLACK"  ,   "Provisão Revertida"  )

oBrowse:DisableDetails()

oBrowse:Activate()

Return NIL
       
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Rotinas  disponiveis do menu
@author  bruno.ferriera compila.com.br
@since   20190620
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'           OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Efetivar'   ACTION 'U_ALCTB01B("EFETIVA")'      OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Reverter'   ACTION 'U_ALCTB01B("REVERTE")'      OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Estornar/ Manualmente'   ACTION 'U_ALCTB01B("ESTORNA")'      OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Importar'   ACTION 'U_ALCTB01C()'      OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definições do MODEL
@author  bruno.ferreira compila.com.br
@since   20190620
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruct := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

oModel := MPFormModel():New(D_MODEL, /*bPreValidacao*/,  {  |oModel| POSMODEL( oModel ) } /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:AddFields( D_MODELMASTER, /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )  

oModel:SetPrimaryKey({"ZB_FILIAL","ZB_FORNEC", "ZB_LOJA", "ZB_COMPET"}) // Feito valid pelo P.E do model, primary não impediu duplicidade

oModel:SetDescription( D_TITULO )
oModel:SetVldActivate( { |oModel,cAcao| U_ALCTB01V('MODEL_ACTIVE', oModel) } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definições da  VIEW
@author  bruno.ferreira compila.com.br
@since   20190620
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FWLoadModel( D_ROTINA )
Local oStruct := FWFormStruct( 2, D_ALIAS )
Local oView   

oModel:SetPrimaryKey({"ZB_FILIAL","ZB_FORNEC", "ZB_LOJA", "ZB_COMPET"})
oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( D_VIEWMASTER, oStruct, D_MODELMASTER )
oView:CreateHorizontalBox( 'SUPERIOR' , 100 )    
oView:SetOwnerView( D_VIEWMASTER, 'SUPERIOR' )
oView:SetCloseOnOk({||.T.})

Return oView



/*/{Protheus.doc} ALCTB01B
Efetivar contabilização das Provisões.
@author Augusto Ribeiro | www.compila.com.br
@since 21/06/2019
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function ALCTB01B(cAcao)
Local lret	:= .t.

IF cAcao == "EFETIVA"

	cMsgAviso	:= "Esta rotina realiza a efetivacao das provisões lançadas."+CRLF+CRLF
	cMsgAviso	+= "Qual registro deseja processar ?"+CRLF+CRLF
	
	nOpcAviso	:= AVISO("Provisões", cMsgAviso,{"Posicionado","Em Lote", "Cancelar"},2)
			
	IF nOpcAviso == 1 .OR. nOpcAviso == 2
	
		
		Processa({|| U_ALCTB01E(nOpcAviso == 1,,.T.,.f.)}, "Processando... ")
		

	ENDIF
	
ELSEIF cAcao == "REVERTE"

	cMsgAviso	:= "Esta rotina realiza a reversão das provisões lançadas."+CRLF+CRLF
	cMsgAviso	+= "Qual registro deseja processar ?"+CRLF+CRLF
	
	nOpcAviso	:= AVISO("Provisões", cMsgAviso,{"Posicionado","Em Lote", "Cancelar"},2)
			
	IF nOpcAviso == 1 .OR. nOpcAviso == 2
	
		
		Processa({|| U_ALCTB01E(nOpcAviso == 1 ,,.f.,.t.)}, "Processando... ")
		

	ENDIF	
	
ELSEIF cAcao == "ESTORNA"

	cMsgAviso	:= "Esta rotina realiza o estorno das provisões lançadas."+CRLF+CRLF
	cMsgAviso	+= "Qual registro deseja processar ?"+CRLF+CRLF
	
	nOpcAviso	:= AVISO("Provisões", cMsgAviso,{"Posicionado","Em Lote", "Cancelar"},2)
			
	IF nOpcAviso == 1 .OR. nOpcAviso == 2
	
		
		Processa({|| U_ALCTB01E(nOpcAviso == 1, .T.) }, "Processando... ")
		
	ENDIF
ENDIF

RETURN(lret)


/*/{Protheus.doc} ALCTB01E
Efetiva registros
@author Augusto Ribeiro | www.compila.com.br
@since 21/06/2019
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function ALCTB01E(lPosicionado, lEstorno, lEfetiva, lReverte)
Local aRet	:= { .F. ,""}
Local aCabec 	:= {}
Local aitens	:= {}
Local cDocto	:= ""

Local cPerg		:= "ALCTB01"
Local cQuery	:= "" 
Local nI
Local cMsgerro	:= ""
Local cStDestin	:= ""
Local nRecCT2	:= ""
Local cKeyCT2	:= ""
Local nLinCT2	:= 0
Local cChvNF, cIDFlgNf
Local cDtIni, cDtFim
Local lAux		:= .f.

Local dDtCtbMV	:= ctod("  /  /  ")
Local dDtDigIni	:= ctod("  /  /  ")
Local dDtDigFim	:= ctod("  /  /  ")

Local  cFilDe		:= ""
Local  cFilAte		:= ""
Local  cCompet		:= ""
Local  dDtCtbMV		:= ""
Local  cFornece		:= ""
Local  cLoja		:= ""
Local _cCodEmp, _cCodFil, _cFilNew

Private aParams:={}
Private aRetPar:={}
Private aRegSZB	:= {}
Private nTotReg	:= 1

Default lPosicionado 	:= .T.
Default lEstorno		:= .F.
Default lEfetiva		:= .F.
Default lReverte		:= .F.





IF lPosicionado .AND. !(lReverte)
	AADD(aRegSZB, SZB->(RECNO()))
	
	AADD(aParams,{1,"Data Contabilizacao",cToD(SPACE(08)),,"NAOVAZIO()","","",90,.F.,})

	If ParamBox(aParams,"Parametros",@aRetPar)
		dDtCtbMV	:= aRetPar[1]
	Endif 
	
	IF EMPTY(dDtCtbMV)
		aRet[2]	:= "Parametros são de preenchimento obrigatório"
	ENDIF	
	
ELSE
	
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 22/08/2019 - 6:04:53 PM
		Alteração para ser informada a datta de digitação inicial e final
	------------------------------------------------------------------------------------------*/
	IF lReverte .AND. lPosicionado //| REVERTER POSICIONADO |
	
		AADD(aParams,{1,"Data Contabilizacao",cToD(SPACE(08)),,"NAOVAZIO()","","",90,.F.,})
		AADD(aParams,{1,"Data Digitacao De",cToD(SPACE(08)),,"NAOVAZIO()","","",90,.F.,})
		AADD(aParams,{1,"Data Digitacao Ate",cToD(SPACE(08)),,"NAOVAZIO()","","",90,.F.,})
	
		If ParamBox(aParams,"Parametros",@aRetPar)
			dDtCtbMV	:= aRetPar[1]
			dDtDigIni	:= aRetPar[2]
			dDtDigFim	:= aRetPar[3]
			
			
			IF !EMPTY(dDtDigIni) .AND. !EMPTY(dDtDigFim) .AND. !EMPTY(dDtCtbMV)
				lAux	:= .T.
			ELSE
				aRet[2]	:= "Parametros são de preenchimento obrigatório"
			ENDIF
		Endif 
	ELSE
		lAux	:= PERGUNTE(cPerg,.T.)
		
		cFilDe		:= MV_PAR01
		cFilAte		:= MV_PAR02
		cCompet		:= MV_PAR03
		dDtCtbMV	:= MV_PAR04
		cFornece	:= MV_PAR05
		cLoja		:= MV_PAR06		
		
		IF EMPTY(cFilAte) .OR. EMPTY(cCompet)
			aRet[2]	:= "Parametros Filial Ate e Competencia sao obrigatorios"
		ELSEIF EMPTY(dDtCtbMV)		
			aRet[2]	:= "Parametro data da contabilização é obrigatorio."
		ENDIF
	ENDIF


	IF lAux .AND. EMPTY(aRet[2])
		
		cQuery := " SELECT ZB_FILIAL,ZB_FORNEC,ZB_LOJA ,A2_NOME, ZB_COMPET, ZB_VALOR , ZB_STATUS, ZB_DEBITO, ZB_CREDIT, ZB_CCD   , ZB_CCC   , SZB.R_E_C_N_O_ as ZB_RECNO "+CRLF
		cQuery += " FROM "+RetSqlName("SZB")+" SZB "+CRLF
		cQuery += " INNER JOIN "+Retsqlname("SA2")+" SA2 "+CRLF
		cQuery += " 	ON A2_FILIAL = '"+ XFILIAL("SA2") +"' "+CRLF
		cQuery += " 	AND ZB_FORNEC = A2_COD "+CRLF
		cQuery += " 	AND ZB_LOJA = A2_LOJA "+CRLF
		cQuery += " 	AND SA2.D_E_L_E_T_ = '' "+CRLF
		
		IF lReverte .AND. lPosicionado //| REVERTER POSICIONADO |
			cQuery += " WHERE SZB.R_E_C_N_O_  = "+alltrim(str(SZB->(RECNO()))) 
		ELSE
			cQuery += " WHERE ZB_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"' "+CRLF
			
			IF !lReverte
				cQuery += " AND ZB_COMPET =  '"+cCompet+"' "+CRLF
			ENDIF
			IF !EMPTY(cFornece) 			
				cQuery += " AND ZB_FORNEC =  '"+cFornece+"' "+CRLF
			ENDIF
			IF !EMPTY(cLoja) 
				cQuery += " AND ZB_LOJA =  '"+cLoja+"' "+CRLF
			ENDIF				
		ENDIF
		
		IF lEstorno
			cQuery += " AND SZB.ZB_STATUS = '"+ZB_STATUS_EFETIVADA+"' "+CRLF
		ELSEIF lEfetiva
			cQuery += " AND SZB.ZB_STATUS ='"+ZB_STATUS_PENDENTE+"' "+CRLF
		ELSEIF lReverte
			cQuery += " AND SZB.ZB_STATUS ='"+ZB_STATUS_EFETIVADA+"' "+CRLF
			
			/*----------------------------------------------------------------------------------------  
				Realiza o Filtro pela data da digitacao da NF e nao pela competencia da provisao.
				Melhoria solicitada pelo cliente.
				comportamento necessario somente quando opcao reverte
				 ALTERADO CODIGO NESTE TRECHO PARA EVITAR REESCRITA DE GRANDE PARTE DA ROTINA.
			------------------------------------------------------------------------------------------*/
			IF lPosicionado //| REVERTER POSICIONADO |
				cDtIni	:= DTOS(dDtDigIni)
				cDtFim	:= DTOS(dDtDigFim)
			ELSE
				cDtIni	:= RIGHT(cCompet,4)+LEFT(cCompet,2)+"01"
				cDtFim	:= DTOS(LASTDAY(STOD(cDtIni)))
			ENDIF
			
			cQuery += " AND EXISTS ( "+CRLF
			cQuery += " SELECT 1 AS 'A' "+CRLF
			cQuery += " FROM "+RetSqlName("SF1")+" SF1 "+CRLF
			cQuery += " WHERE F1_FILIAL = ZB_FILIAL  "+CRLF
			cQuery += " AND F1_DTDIGIT BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "+CRLF
			cQuery += " AND F1_FORNECE = ZB_FORNEC "+CRLF
			cQuery += " AND F1_LOJA = ZB_LOJA "+CRLF
			cQuery += " AND F1_XCOMPET = ZB_COMPET "+CRLF
			cQuery += " AND SF1.D_E_L_E_T_ = '') "+CRLF				
			
		ENDIF
		
		cQuery += " AND SZB.D_E_L_E_T_ = '' "+CRLF
		cQuery += " ORDER BY ZB_CODIGO  "+CRLF
		

		IF lReverte .AND. lPosicionado
		
			If Select("TSQL") > 0
				TSQL->(DbCloseArea())
			EndIf
			
			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						
			
	
			IF TSQL->(!EOF())
				AADD(aRegSZB,  TSQL->ZB_RECNO)
			ENDIF			
			
			TSQL->(DbCloseArea())	
		
		else
		

			fDialogo("Selecao Provisoes", "SZB", cQuery, lEstorno)
		
		endif

	ELSE
		aRet[2]	:= "Parametros inválidos"
	ENDIF
ENDIF 




IF !EMPTY(aRegSZB) .and. empty(aRet[2])

	ProcRegua( nTotReg )
	
	DBSELECTAREA("SZB")
	nLinCT2	:= 1
	FOR nI := 1 to len(aRegSZB)
		IncProc("Processando...")
		
		IF EMPTY(aRegSZB[nI])
			LOOP
		ENDIF
		
		//| Posiciona SZB |
		SZB->(DBGOTO(aRegSZB[nI]))

		/*---------------------------------------
			Realiza a TROCA DA FILIAL CORRENTE 
		-----------------------------------------*/
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= SZB->ZB_FILIAL //| CODIGO DA FILIAL DE DESTINO 
		
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF
	
	

	
		cCompet		:= SZB->ZB_COMPET
		IF !EMPTY(dDtCtbMV)
			dDtLanc		:= dDtCtbMV
		ELSE
			dDtLanc		:= LastDay(STOD(right(cCompet,4)+left(cCompet,2)+"01"))
		ENDIF
		cLote		:= SUPERGETMV("AL_LOTPROV",.F.,"8815", SZB->ZB_FILIAL)
		cDocto		:= "001"
		cSubLote	:= RetSubLote(SZB->ZB_FILIAL, cLote, dDtLanc)
		cMsgErro	:= ""
		cStDestin	:= "" 
		aCabec		:= {}
		aitens		:= {}
		aadd(aCabec, {'DDATALANC'   ,dDtLanc	 	  	,NIL})
		aadd(aCabec, {'CLOTE'       ,cLote         		,NIL})
		aadd(aCabec, {'CSUBLOTE'    ,cSubLote     		,NIL})
		aadd(aCabec, {'CDOC' 		,cDocto				,NIL})
		aadd(aCabec, {'CPADRAO' 	,"" 				,NIL})
		aadd(aCabec, {'NTOTINF' 	,0 					,NIL})
		aadd(aCabec, {'NTOTINFLOT' 	,0 					,NIL})
	
		//| Verifica provisão a ser finalizada |
		aRetAux := VerifPrv(aRegSZB[nI],nLinCT2/*nLinha*/, lEstorno) //| {lRet, cMsgErro, {nRecSZB, ZB_STATUS_EFETIVADA, ""}, aDadosCT2} |
		IF aRetAux[1]
		
			/*--------------------------------------------------------
				Caso ocorra erro, mantem não altera o status do SZB
			---------------------------------------------------------*/
			cStDestin	:= SZB->ZB_STATUS
			IF aRetAux[3,2] == ZB_STATUS_EFETIVADA .OR. aRetAux[3,2] == ZB_STATUS_ESTORNADA .OR. aRetAux[3,2] == ZB_STATUS_REVERTIDA			
	
				AADD(aitens, aClone(aRetAux[4]))
				IF !EMPTY(aItens)
				
					lMsErroAuto := .F.
					
					aRet	:= { .F. ,""}
				
					MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCabec ,aItens, 3)
				
					IF lMsErroAuto	
					
						mostraerro()
					
						cAutoLog	:= alltrim(NOMEAUTOLOG())
				
						cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
						cMemo := STRTRAN(cMemo,"'","")
						
						cMsgErro := U_CPXERRO(cMemo)
						IF EMPTY(cMsgErro)
							cMsgErro	:=  alltrim(STRTRAN(cMemo,chr(13)+chr(10),"|"))
						ENDIF					
						
						//cMsgErro := cRetAux
						//| Apaga arquivo de Log
						Ferase(cAutoLog)
						
						//|Le Log da Execauto e retorna mensagem amigavel|
						//aRet[2] := cMsgErro//U_CPXERRO(cMsgErro)
					ELSE
						cStDestin	:= aRetAux[3,2]
						nRecCT2		:= CT2->(RECNO())
						cKeyCT2		:= CT2->(CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC+CT2_SEQIDX)
						nLinCT2++	
					ENDIF
				ELSE
					cMsgErro := "[ALCTB01E] Dados para contabilizacao invalido."
				ENDIF
				
			ELSE
				
				cStDestin	:= aRetAux[3,2]
				cChvNF		:= aRetAux[3,4]
				cIDFlgNf	:= aRetAux[3,5]
				cMsgErro	:= aRetAux[2]
			ENDIF			
		ELSE	
			cMsgerro	:= aRetAux[2]	
		ENDIF
		
		
		/*------------------------------------------------------ Augusto Ribeiro | 24/06/2019 - 10:48:05 AM
			Atualiza registro processado
		------------------------------------------------------------------------------------------*/
		RECLOCK("SZB",.f.)
			IF !EMPTY(cStDestin)
				SZB->ZB_STATUS	:= cStDestin
			ENDIF			
			SZB->ZB_MSGLOG := cMsgErro
			
			
			IF SZB->ZB_STATUS == ZB_STATUS_NAO_GERADA
				IF !empty(cChvNF)
					SZB->ZB_CHVNF	:= cChvNF
				ENDIF
				IF !empty(cIDFlgNf)
					SZB->ZB_IDFLGNF	:= cIDFlgNf
				ENDIF
			ENDIF
			
			
			IF !EMPTY(nRecCT2)
				IF SZB->ZB_STATUS == ZB_STATUS_EFETIVADA
					SZB->ZB_RECPRV		:= nRecCT2
					SZB->ZB_DTEFET		:= dDataBase
					SZB->ZB_DTCTEF		:= dDtCtbMV
					
				ELSEIF SZB->ZB_STATUS == ZB_STATUS_ESTORNADA				
					SZB->ZB_RECEST		:= nRecCT2
					SZB->ZB_DTESTO		:= dDataBase
					SZB->ZB_DTCTES		:= dDtCtbMV
				ENDIF
			ENDIF			
			IF !EMPTY(cKeyCT2)
				IF SZB->ZB_STATUS == ZB_STATUS_EFETIVADA
					SZB->ZB_CT2PRV		:= cKeyCT2
					SZB->ZB_DTEFET		:= dDataBase
				ELSEIF SZB->ZB_STATUS == ZB_STATUS_ESTORNADA		
					SZB->ZB_CT2EST		:= cKeyCT2
					SZB->ZB_DTESTO		:= dDataBase
				ENDIF
			ENDIF		
			
		MSUNLOCK()
		
		
		
		/*---------------------------------------
			Restaura FILIAL  
		-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF   			
						
		
	next nI
ELSE
	IF EMPTY(aRet[2])
		Help("Vazio",1,"Efetiva",,"Nao existe registros a serem processados.",4,5)
	ELSE
		Help("Falha",1,"Falha",,aRet[2],4,5)
	ENDIF
ENDIF

Return(aRet)




/*/{Protheus.doc} VerifPrv
Verifica provisão a ser finalizada
@author Augusto Ribeiro | www.compila.com.br
@since 21/06/2019
@version version
@param param                    
@return aRet, {lRet, cMsgErro, {nRecSZB, ZB_STATUS_EFETIVADA, cErro, cChvNF, cIDFluig}, aDadosCT2} 
@example
(examples)
@see (links_or_references)
/*/
Static function VerifPrv(nRecSZB, nLinLote, lEstorno)
										//                      1            2              3      4        5
Local aRet		:= {.F., "", {}, {}}  //| {lRet, cMsgErro, {nRecSZB, ZB_STATUS_EFETIVADA, cErro, cChvNF, cIDFluig}, aDadosCT2} 
Local aCT2		:= {}
Local aRetAux	:= {}

Default nLinLote	:= 1
Default lEstorno	:= .F.

IF !EMPTY(nRecSZB)
	
	DBSELECTAREA("SZB")
	SZB->(DBGOTO(nRecSZB))
	
	//| ZB_STATUS 1=Pendente;2=Prv. Não Gerada. Existe NF;3=Prv. Efetivada;4=Prv. Estornada;5=Erro
	IF SZB->ZB_STATUS == ZB_STATUS_PENDENTE
	
		//| Verifica se ja existe NF lancada para o Fornecedor na competencia .|
		aRetAux	:= ExistNF(SZB->ZB_FILIAL, SZB->ZB_FORNEC, SZB->ZB_LOJA, SZB->ZB_COMPET, SZB->ZB_DEBITO) //| {lNfLocalizada, cChvNF, cIDFluig} |
		IF !aRetAux[1]
				
			aAdd(aCT2,  {'CT2_FILIAL'      	, SZB->ZB_FILIAL     , NIL})
			aAdd(aCT2,	{'CT2_LINHA'      	, STRZERO(nLinLote,3) 		, NIL})
			aAdd(aCT2,	{'CT2_MOEDLC'      	, "01"           		, NIL})
			aAdd(aCT2,	{'CT2_DC'           , "3"	 	         	, NIL})				
			aAdd(aCT2,	{'CT2_DEBITO'      	, SZB->ZB_DEBITO     , NIL})
			aAdd(aCT2,	{'CT2_CREDIT'      	, SZB->ZB_CREDIT     , NIL})
			aAdd(aCT2,	{'CT2_VALOR'      	, SZB->ZB_VALOR      , NIL})
			aAdd(aCT2,	{'CT2_ORIGEM'     	, SZB->ZB_CODIGO    	, NIL})
			
			aAdd(aCT2,	{'CT2_HIST'       	, UPPER(ALLTRIM(SZB->ZB_HIST)) 	, NIL})
	
			
			IF !EMPTY(SZB->ZB_CCD)
				IF CT1->( DBSEEK( XFILIAL("CT1") + SZB->ZB_DEBITO )) 
					IF CT1->CT1_ACCUST == "1"
						aAdd(aCT2,	{'CT2_CCD'       	, SZB->ZB_CCD		, NIL})
					ENDIF
				ENDIF 
			ENDIF
			
			IF !EMPTY(SZB->ZB_CCC)
				IF CT1->( DBSEEK( XFILIAL("CT1") + SZB->ZB_CREDIT ))
				
					IF CT1->CT1_ACCUST == "1"
						aAdd(aCT2,	{'CT2_CCC'       	, SZB->ZB_CCC			, NIL})
					ENDIF
				 
				ENDIF
			ENDIF
			
			aRet[3] := {nRecSZB, ZB_STATUS_EFETIVADA, "","",""}
			aRet[4] := ACLONE(aCT2)					
		ELSE
			aRet[3] := {nRecSZB, ZB_STATUS_NAO_GERADA, ,aRetAux[2],aRetAux[3]}
		ENDIF
				
			
		aRet[1] := .T.
	
	ELSEIF SZB->ZB_STATUS == ZB_STATUS_NAO_GERADA .OR. SZB->ZB_STATUS == ZB_STATUS_NAO_GERADA 
		aRet[2] := "Status atual do registro nao permite interacao"
	
	ELSEIF SZB->ZB_STATUS == ZB_STATUS_EFETIVADA
	 
	 
		//| Verifica se ja existe NF lancada para o Fornecedor na competencia .|
		IF lEstorno
			aRetAux	:= {.T.,""}
		ELSE
			aRetAux	:= ExistNF(SZB->ZB_FILIAL, SZB->ZB_FORNEC, SZB->ZB_LOJA, SZB->ZB_COMPET, SZB->ZB_DEBITO) //| {lNfLocalizada, cChvNF, cIDFluig}|
		ENDIF
		IF aRetAux[1]
				
			aAdd(aCT2,  {'CT2_FILIAL'      	, SZB->ZB_FILIAL     , NIL})
			aAdd(aCT2,	{'CT2_LINHA'      	, STRZERO(nLinLote,3) 		, NIL})
			aAdd(aCT2,	{'CT2_MOEDLC'      	, "01"           		, NIL})
			aAdd(aCT2,	{'CT2_DC'           , "3"	 	         	, NIL})				
			aAdd(aCT2,	{'CT2_DEBITO'      	, SZB->ZB_CREDIT     , NIL})
			aAdd(aCT2,	{'CT2_CREDIT'      	, SZB->ZB_DEBITO      , NIL})
			aAdd(aCT2,	{'CT2_VALOR'      	, SZB->ZB_VALOR      , NIL})
			aAdd(aCT2,	{'CT2_ORIGEM'     	, SZB->ZB_CODIGO    	, NIL})
			
			IF lEstorno
				aAdd(aCT2,	{'CT2_HIST'       	, "ESTORNO MANUAL "+UPPER(ALLTRIM(SZB->ZB_HIST)) 	, NIL})
			ELSE
				aAdd(aCT2,	{'CT2_HIST'       	, "ESTORNO "+UPPER(ALLTRIM(SZB->ZB_HIST)) 	, NIL})
			ENDIF
	
			
			IF !EMPTY(SZB->ZB_CCD)
				IF CT1->( DBSEEK( XFILIAL("CT1") + SZB->ZB_DEBITO )) 
					IF CT1->CT1_ACCUST == "1"
						aAdd(aCT2,	{'CT2_CCC'       	, SZB->ZB_CCD		, NIL})
					ENDIF
				ENDIF 
			ENDIF
			
			IF !EMPTY(SZB->ZB_CCC)
				IF CT1->( DBSEEK( XFILIAL("CT1") + SZB->ZB_CREDIT ))
						IF CT1->CT1_ACCUST == "1"
							aAdd(aCT2,	{'CT2_CCD'       	, SZB->ZB_CCC			, NIL})
						ENDIF
				ENDIF
			ENDIF
			
			
			aRetAux	:= ExistNF(SZB->ZB_FILIAL, SZB->ZB_FORNEC, SZB->ZB_LOJA, SZB->ZB_COMPET, SZB->ZB_DEBITO) // {lNfLocalizada, cChvNF, cIDFluig}
			
			IF aRetAux[1]
				aRet[3] := {nRecSZB, ZB_STATUS_REVERTIDA,"","",""}
			ELSE
				aRet[3] := {nRecSZB, ZB_STATUS_ESTORNADA, "","",""}		
			ENDIF 
			aRet[4] := ACLONE(aCT2)					
		ELSE
			aRet[3] := {nRecSZB, "", "Estorno na provisao não disponivel pois a nf corresponde não foi localizada.","",""}
		ENDIF
				
			
		aRet[1] := .T.	 
	 
	ENDIF
	
	
ELSE
	aRet[2] := "Recno SZB nao informado"
ENDIF
Return(aRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} ALCTB01C
Importação das provisões, CSV
@author  bruno.ferriera   compila.com.br
@since   20190620
/*/
//-------------------------------------------------------------------
User Function ALCTB01C()

	Local clFile	:= ""
	Local aRetImp	:= {.F.,""}

	clFile := cGetFile('Arquivo CSV|*.csv','Selecione arquivo',0,,.F.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.F.)
	
	IF !EMPTY(clFile)
	
		Processa({|| aRetImp := impArq(clFile) }, "Importando Planilha... ")
				
		IF aRetImp[1]
					
			FwHelpShow("LOG","LOG","ARQUIVO: " + clFile + " | LOG: SUCESSO (TODOS OS REGISTROS FORAM PROCESSADOS COM SUCESSO). " + ALLTRIM(aRetImp[2])	+CRLF,"")
			
		ELSE
		
			FwHelpShow("LOG","LOG","ARQUIVO: " + clFile + " | LOG: "+aRetImp[2]+CRLF,"")
			
		ENDIF
	
	ELSE
	
		FwHelpShow("NAO EXISTE","NAO EXISTE","Selecione o Aquivo por favor.","")
		
	ENDIF


RETURN 



/*/{Protheus.doc} POSMODEL
Validação POS MODEL (TUDOOK)
@author Augusto Ribeiro | www.compila.com.br
@since 21/06/2019
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function POSMODEL(oModel)
Local lRet	:= .T.
Local nY, nAux, cChvSZB
Local nOperation	:= oModel:GetOperation()
Local oModSZB		:= oModel:GetModel(D_MODELMASTER)
Local nRecSZB		:= 0

IF nOperation == MODEL_OPERATION_INSERT .OR.  nOperation == MODEL_OPERATION_UPDATE

	IF nOperation == MODEL_OPERATION_UPDATE
		nRecSZB	:= SZB->(RECNO())
	ENDIF

	DBSELECTAREA("SZB")
	SZB->(DBSETORDER(2)) //| ZB_FILIAL+ZB_FORNEC+ZB_LOJA+ZB_COMPET
	cChvSZB := oModSZB:GetValue("ZB_FILIAL")+oModSZB:GetValue("ZB_FORNEC")+oModSZB:GetValue("ZB_LOJA")+oModSZB:GetValue("ZB_COMPET")+oModSZB:GetValue("ZB_DEBITO") 
	IF SZB->(DBSEEK(cChvSZB)) 		 
		
		WHILE SZB->(ZB_FILIAL+ZB_FORNEC+ZB_LOJA+ZB_COMPET+ZB_DEBITO) == cChvSZB			
		
			if nRecSZB	<> SZB->(RECNO())
				
			
			
				IF SZB->ZB_STATUS == ZB_STATUS_PENDENTE .OR. SZB->ZB_STATUS == ZB_STATUS_EFETIVADA .OR. SZB->ZB_STATUS == ZB_STATUS_REVERTIDA
					oModel:SetErrorMessage('SZBMASTER', 'ZB_FORNEC' , 'SZBMASTER' , 'ZB_FORNEC' , "Erro", 'Chave já existente (FILIAL+ FORNECEDOR+ LOJA+ COMPETENCIA+ CONTA_DEBITO)', 'Por favor verificar')
					Return(.F.)			
				ENDIF 	
				
			endif
			
			SZB->(DBSKIP())	
		ENDDO

	ENDIF
	
	//| Valida fornecedor + Loja
		
	DBSELECTAREA("SA2")
	SA2->(DBSETORDER(1)) //| A2_FILIAL+A2_COD+A1_LOJA	
	IF !SA2->(DBSEEK(xfilial("SA2") + oModSZB:GetValue("ZB_FORNEC")+oModSZB:GetValue("ZB_LOJA")))
			
		oModel:SetErrorMessage('SZBMASTER', 'ZB_FORNEC' , 'SZBMASTER' , 'ZB_FORNEC' , "Erro", 'Fornecedor inexistente', 'Informe um fornecedor Existente')
		Return(.F.)
			
	ENDIF
	
	IF	LEN(ALLTRIM(oModSZB:GetValue("ZB_COMPET"))) <> 6	
			
		oModel:SetErrorMessage('SZBMASTER', 'ZB_COMPET' , 'SZBMASTER' , 'ZB_COMPET' , "Erro", 'Compenetência inválida', 'digite mês ano no Formato MMAAAA')
		Return(.F.)
		
	ELSE
		
		clMes :=  VAL(LEFT(ALLTRIM(oModSZB:GetValue("ZB_COMPET")),2))
				
		//| Valida o Mês.
		IF clMes < 1 .OR. clMes > 12
					
			oModel:SetErrorMessage('SZBMASTER', 'ZB_COMPET' , 'SZBMASTER' , 'ZB_COMPET' , "Erro", 'Mês inválido', 'Digite um mês válido')			
			Return(.F.)
			
		ENDIF				
			
	ENDIF

ENDIF

Return(lRet)



/*/{Protheus.doc} POSMODEL
Validação POS MODEL (TUDOOK)
@author Augusto Ribeiro | www.compila.com.br
@since 21/06/2019
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
uSER Function ALCTB01V(cTpValid, oModel)
Local lRet	:= .T.
Local nY, nAux
Local nOperation	:= oModel:GetOperation()
Local oModSZB		:= oModel:GetModel("D_MODELMASTER")

IF cTpValid == "MODEL_ACTIVE"
	IF nOperation == MODEL_OPERATION_DELETE .OR. nOperation == MODEL_OPERATION_UPDATE
	
		//| 1=Pendente;2=Prv. Não Gerada. Existe NF;3=Prv. Efetivada;4=Prv. Estornada;5=Erro                                                 
		IF SZB->ZB_STATUS <> '1' .OR.  !EMPTY(SZB->ZB_RECPRV) .OR. !EMPTY(SZB->ZB_CT2EST)
			//FwHelpShow("Alteração/Exclusao","SZBMODEL","Não é permitida alteracao de registros ja contabilizados.","")
			Help("Operacao Invalida",1,"POSMODEL",,"Não é permitida alteracao de registros ja contabilizados.",4,5)
			lRet	:= .F.
		ENDIF
	    
	ENDIF
ENDIF

Return(lRet)




/*/{Protheus.doc} ExistNF
Verifica se ja existe Nota Fiscal para o Fornecedor para o periodo
@author Augusto Ribeiro | www.compila.com.br
@since 21/06/2019
@version undefined
@param param
@return aRet, {lNfLocalizada, cChvNF, cIDFluig}
@example
(examples)
@see (links_or_references)
/*/
Static Function ExistNF(cFilPrv, cCodFor, cLjFor, cCompet, cContaDeb) //(SZB->ZB_FILIAL, SZB->ZB_FORNEC, SZB->ZB_LOJA, SZB->ZB_COMPET)
Local aRet		:= {.F.,"",""}
Local cQuery	:= ""

cQuery := " SELECT F1_FILIAL, F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_XIDFLG "+CRLF
cQuery += " FROM "+RetSqlName("SF1")+" SF1 "+CRLF
cQuery += " INNER JOIN "+RetSqlName("SD1")+" SD1 "+CRLF
cQuery += "  ON D1_FILIAL = F1_FILIAL "+CRLF
cQuery += "  AND D1_DOC = F1_DOC "+CRLF
cQuery += "  AND D1_SERIE = F1_SERIE "+CRLF
cQuery += "  AND D1_FORNECE = F1_FORNECE "+CRLF
cQuery += "  AND D1_LOJA = F1_LOJA "+CRLF
cQuery += "  AND D1_CONTA = '"+cContaDeb+"' "+CRLF
cQuery += "  AND SD1.D_E_L_E_T_ = '' "+CRLF
cQuery += " WHERE SF1.F1_FILIAL = '"+cFilPrv+"' "+CRLF
cQuery += " AND SF1.F1_FORNECE = '"+cCodFor+"' "+CRLF
cQuery += " AND SF1.F1_LOJA = '"+cLjFor+"' "+CRLF
cQuery += " AND SF1.F1_XCOMPET = '"+cCompet+"' "+CRLF
cQuery += " AND SF1.D_E_L_E_T_ = '' "+CRLF



If Select("TSF1") > 0
	TSF1->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSF1",.F., .T.)						


IF TSF1->(!EOF())
	aRet[1] := .T.
	aRet[2] := TSF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)	
	aRet[3] := TSF1->F1_XIDFLG
ENDIF	

TSF1->(DbCloseArea())
Return(aRet)



/*/{Protheus.doc} RetSubLote
Retorna Sub-Lote a ser inserido
@author Augusto Ribeiro | www.compila.com.br
@since 21/06/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function RetSubLote(cFilPrv, cLote, dData)
Local cRet		:= "000"
Local cQuery	:= ""

cQuery += " SELECT ISNULL(MAX(CT2.CT2_SBLOTE),'000') AS CT2_SBLOTE "+CRLF
cQuery += " FROM "+RetSqlName("CT2")+" CT2 "+CRLF
cQuery += " WHERE CT2_FILIAL= '"+cFilPrv+"' "+CRLF
cQuery += " AND CT2_LOTE = '"+cLote+"' "+CRLF
cQuery += " AND CT2_DATA = '"+DTOS(dData)+"' "+CRLF
cQuery += " and CT2.D_E_L_E_T_ = '' "+CRLF



If Select("TLOT") > 0
	TLOT->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TLOT",.F., .T.)						


IF TLOT->(!EOF())
	cRet := SOMA1(TLOT->CT2_SBLOTE)
ENDIF	

TLOT->(DbCloseArea())
Return(cRet)



/*/{Protheus.doc} impArq
Importa Arquivo
@author Augusto Ribeiro | www.compila.com.br
@since Oct 27, 2015
@version version
@param cPathFull, C, Caminho Completo do arquivo 
@return aRet	:= {.F., cMsgErr, nCodErrp}
@example
(examples)
@see (links_or_references)
/*/
Static Function impArq(cPathFull)

	Local aRet	:= {.F., ""}
	Local cNomeArq
	Local cPathTemp := DirTemp() //| Busca diretorio temporario |
	Local cFullTemp	:= ""
	Local cArqLog	:= ""
	Local cAliasImp	:= ""
	Local nI
	
	Local nHdlArq, cLinha, aLinha, aDados, nTotLin,aItens, aItem
	Local nHdlErro	:= 0
	Local nReg	:= 0
	Local lArqErro	:= .F.
	Local cCabecArq, cCabecF
	Local nPosErro	:= 0
	Local xVarCpo
	Local nRet	:= 0 //| 0=Valor Inicial, 1=Sucesso, 2=Erro |
	
	//Campos para consultar sx3	
	Local nX3_CAMPO := SX3->(FIELDPOS("X3_CAMPO"))
	Local nX3_TIPO := SX3->(FIELDPOS("X3_TIPO"))
	Local nX3_TAMANHO := SX3->(FIELDPOS("X3_TAMANHO"))
	

	
	Private aCabecArq := {}
	Private nCabecArq := {}
	
	Private aCabecF := {}
	Private nCabecF := {}
	
	
	IF !EMPTY(cPathFull)
		cPathFull	:= Lower(cPathFull)			//| Todo o caminho deve ser minusco, evita problemas com Linux
		cNomeArq	:= alltrim(Lower(NomeArq(cPathFull)))		//| Retorna Nome do Arquivo
		
		IF !EMPTY(cPathFull) .AND. !EMPTY(cNomeArq)
		
			/*--------------------------
				Copia Arquivos para a Pasta Temp
			---------------------------*/		                               
			cFullTemp	:= ALLTRIM(cPathTemp+cNomeArq)
			IF cPathFull <> cFullTemp
				__CopyFile(cPathFull, cFullTemp)
			ENDIF
			
			
			/*--------------------------
				Monta nome do arquivo de log de erro
			---------------------------*/
			cArqLog	:= LEFT(cNomeArq,LEN(cNomeArq)-4)+"_LOG.CSV"
			
			
			//| Abre Arquivo|
			IF  (nHdlArq	:= FT_FUSE(cFullTemp) ) >= 0				
				
				
				/*--------------------------
					Verifica Quantas linha Possui o Arquivo
				---------------------------*/				
				nTotLin := FT_FLASTREC()				
				ProcRegua(nTotLin)      
	
				//| Posiciona na Primeira Linha do Arquivo
				FT_FGOTOP()
				
				
				/*-----------------------------------------------
					Primeira linha refere-se ao Cabecalho
				-------------------------------------------------------*/
				cCabecArq	:= FT_FREADLN()
				aCabecArq	:= StrTokArr2( cCabecArq, ";", .F.)
				nCabecArq	:= len(aCabecArq)
				
				
				/*-----------------------------------------------------------------
					Caso coluna de Log ja exista no arquivo, remove do cabecalho
				------------------------------------------------------------------*/
				nPosErro	:= aScan(aCabecArq, COLUNA_LOG)
				IF nPosErro > 0
					aDel(aCabecArq, nPosErro)
					nCabecArq--
					aSize(aCabecArq,nCabecArq)
				ENDIF
				
				//| Identificacao do Alias que esta sendo importado |
				DBSELECTAREA("SX3")
				SX3->(DBSETORDER(2)) //|CAMPO 
				IF SX3->(DBSEEK(ALLTRIM(UPPER(aCabecArq[1])))) 
					cAliasImp	:= SX3->(FIELDGET(FIELDPOS("X3_ARQUIVO")))						
				ENDIF
				
				
				/*--------------------------
					Array com Cabecalho e Tipo de Dados
				---------------------------*/
				DBSELECTAREA("SX3")
				SX3->(DBSETORDER(2)) //|CAMPO
				aCabecX3	:= {}
				for nI:= 1 to Len(aCabecArq)
					IF SX3->(DBSEEK(ALLTRIM(UPPER(aCabecArq[nI]))))
						AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3_CAMPO))), SX3->(FIELDGET(nX3_TIPO)), SX3->(FIELDGET(nX3_TAMANHO))})
					ELSE
						AADD(aCabecX3, {alltrim(SX3->(FIELDGET(nX3_CAMPO))), "", 0 })										
					ENDIF
				next nI
				
						
				FT_FSKIP()
				                                          
				WHILE !FT_FEOF()
				
					nReg++					
					IncProc("Importanto registros... "+STRZERO(nReg,6)+" de "+STRZERO(nTotLin,6))					
	
					cErroLin	:= ""
					aDados		:= {}
					
					cLinha 		:= FT_FREADLN()			
					aLinha		:= StrTokArr2( cLinha, ";", .T.)
					nQtdeCol	:= LEN(aLinha)		
					IF nPosErro > 0	
						aDel(aLinha, nPosErro)//| Remove linha com LOG de ERRO|
						nQtdeCol--	
						aSize(aLinha,nQtdeCol)
					ENDIF
					
									
					/*------------------------------------------------------ Augusto Ribeiro | Oct 27, 2015 - 9:46:36 PM
						ARMAZENA VARIAVEIS CONFORME LAYOUT
					------------------------------------------------------------------------------------------*/
					IF nCabecArq == nQtdeCol
										
						FOR nI := 1 to nCabecArq
						
							IF aCabecX3[nI,2] == "C" .OR. aCabecX3[nI,2] == "M" 
								xVarCpo	:= PADR(ALLTRIM(aLinha[nI]),aCabecX3[nI,3]) 
							ELSEIF aCabecX3[nI,2] == "N"
								xVarCpo	:= VAL(aLinha[nI])
							ELSEIF aCabecX3[nI,2] == "D"
								xVarCpo	:= STOD(aLinha[nI])
							ENDIF
									
							aaDD(aDados,{aCabecArq[nI], xVarCpo})

						NEXT nI					
											
																
						//| CHAMA ROTINA DE IMPORTACAO.
									
						aRetAux := impMVC("SZB", 1 , aDados, 3 ,D_ROTINA)
															
						IF aRetAux[1]
												
							if nRet == 0
								nRet	:= 1
							endif
						else
							cErroLin	+= aRetAux[2]
						ENDIF
					
					ELSE
						cErroLin	+= "Quantidade de Colunas diverge do cabecalho do arquivo"
					ENDIF
					
									
					IF !EMPTY(cErroLin)
						nRet := 2 //| Erro 
						//GrvArqErro(@nHdlErro, cLinha, cErroLin, cArqLog, cPathTemp)
						GrvArqErro(@nHdlErro, cArqLog, aLinha, cErroLin)
					ENDIF
					
					FT_FSKIP()
				ENDDO
	
				IF nHdlErro > 0
					fClose(nHdlErro)
				ENDIF
			ELSE
				aRet[2]	:= "Falha na abertura do arquivo ["+cFullTemp+"]"
			ENDIF
		ELSE
			aRet[2]	:= "Caminho do arquivo invalido ou vazio ["+cPathFull+"]."
		ENDIF	
	ELSE 
		aRet[2]	:= "Caminho do arquivo invalido ou vazio"
	ENDIF
	
	
	IF nRet == 1 //| Todos os registros foram processados com sucesso|
		aRet[1]	:= .T.
		aRet[2]	:= "Total de registros " + alltrim(STR(nTotLin)) + " Total Importado " + alltrim(STR(nReg))
	ELSEIF nRet == 2
		aRet[1]	:= .F.
		aRet[2]	:= "Alguns registros foram processados com erro, por favor verifique o log de erro ["+cArqLog+"] Total de registros " + alltrim(STR(nTotLin)) + " Total Processados " + alltrim(STR(nReg))"
		
		/*--------------------------
			Copia Arquivos para a Pasta Temp
		---------------------------*/		    
		IF !EMPTY(cArqLog)   
		
		
			nPosBar	:= RAT("\",cPathFull)
			IF nPosBar > 0
				cPathOrig	:= SUBSTR(cPathFull, 1, nPosBar)
			ELSE
				cPathOrig	:= cPathFull
			ENDIF
			
			cPathOrig	:= ALLTRIM(cPathOrig)
			cPathTemp	:= ALLTRIM(cPathTemp)
			
			IF cPathOrig <> cPathTemp
				__CopyFile(cPathTemp+cArqLog, cPathOrig+cArqLog)
			ENDIF
			 
		ENDIF
		
	ENDIF

Return(aRet)


/*/{Protheus.doc} NomeArq
Retorna somente o nome do arquivo + extensao Ex.: Arq.xml 
@author Augusto Ribeiro | www.compila.com.br
@since Oct 27, 2015
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function NomeArq(cFullPath)

	Local cRet	:= ""
	Local nFullPath	:= 0      
	Local nI	

	IF !EMPTY(cFullPath)    
		cFullPath	:= ALLTRIM(cFullPath)
		nFullPath	:= LEN(cFullPath)
		
		FOR nI := 1 to nFullPath
			IF LEFT(RIGHT(cFullPath,nI),1) == "\"
				cRet	:= RIGHT(cFullPath,nI-1)
				EXIT
			ENDIF					
		NEXT nI	    
		
		IF EMPTY(cRet)
			cRet	:= cFullPath
		ENDIF
	ENDIF 

Return(cRet) 


/*/{Protheus.doc} DirTemp
Retornar/Criar caminho para pasta temporaria
@author Augusto Ribeiro | www.compila.com.br
@since 27/10/2015
@version 1.0
@param ${dDataRef}, ${D}, ${Data de referencia - Utilizado para criar o diretorio onde ser armazenado o arquivo}
@return ${cRet}, ${Caminho de destino no arquivo}
/*/
Static Function DirTemp(dDataRef)
Local cRet				:= ""
Local cDirTemp			:= "\DATA_INTEGRACAO\TEMP\"
Local cAnoMes, cDirComp, cCurDir, nAux, aPastas
Local nI

IF ExistDir(cDirTemp)
	cRet	:= cDirTemp
ELSE

	cCurDir	:= CurDir()	

	//aPastas	:= StrTokArr2(cDirTemp, "\", .F.)
	aPastas	:= StrTokArr2(cDirTemp,"\", .F.)
	

	/*--------------------------
		Cria pastas
	---------------------------*/
	CurDir("\")
	nAux	:= 0
	for nI := 1 to Len(aPastas)
						
		nAux	:= MakeDir(alltrim(aPastas[nI]))
		IF nAux <> 0
			CONOUT("### CPIMP01.PRW [DirTemp] | Nao foi possivel criar o diretorio ["+alltrim(aPastas[nI])+"]. Cod. Erro: "+alltrim(str(FError())) )
		ENDIF		
		
		CurDir("\"+alltrim(aPastas[nI]))
	next nI
	
	IF nAux == 0
		cRet	:= cDirTemp
	ENDIF
		
	//| Rollback no diretorio corrente
	IF LEFT(cCurDir,1) <> "\"
		cCurDir	:= "\"+cCurDir
	ENDIF		
	CurDir(cCurDir) 
ENDIF 

cRet	:= ALLTRIM(cRet)

Return(cRet)


/*/{Protheus.doc} GrvArqErro
Grava log de erro
@author Augusto Ribeiro | www.compila.com.br
@since Oct 30, 2015
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//Static Function GrvArqErro(nHdlErro, cLinha, cMsgErro, cNomeArq, cPathTemp)
Static Function GrvArqErro(nHdlErro, cNomeArq, aLinha, cMsgErro)
//Local cRet	:= ""
Local cPathTemp := DirTemp() //| Busca diretorio temporario |
Local nI		:= 0
Local cCabec	:= ""
Local cLinErro	:= ""

IF !EMPTY(cMsgErro)
	
	IF nHdlErro == 0
		cCurDir	:= CurDir()
		CurDir(cPathTemp)
		
		//cRet		:= LEFT(cNomeArq,LEN(cNomeArq)-4)+"_ERRO.CSV"
		nHdlErro	:= Fcreate(cNomeArq)
		lArqErro	:= .T.
		
		//| Rollback no diretorio corrente
		IF LEFT(cCurDir,1) <> "\"
			cCurDir	:= "\"+cCurDir
		ENDIF		
		CurDir(cCurDir)
		
		/*--------------------------
		Adiciona coluna de LOG
		---------------------------*/
		cCabec	:= ""
		FOR nI := 1 to nCabecArq
			cCabec += aCabecArq[nI]+";"
		next
		cCabec	+= COLUNA_LOG
		
		nAux	:= FWrite(nHdlErro, cCabec+CRLF)				 
	endif
	
	
	//| Tratamento para sempre gravar o log na coluna correta|
	cLinErro	:= ""
	nQtdeLin	:= len(aLinha)
	FOR nI := 1 to nCabecArq
		IF nQtdeLin >= nI
			cLinErro += aLinha[nI]+";"
		ELSE
			cLinErro += ";"
		ENDIF
	next
	cLinErro	+= cMsgErro	+CRLF

	nAux	:= FWrite(nHdlErro, cLinErro)
ENDIF


Return()


/*/{Protheus.doc} impMVC
Importa registro via MVC
@author Augusto Ribeiro | www.compila.com.br
@since 05/01/2016
@version 
@param cAliasImp, C, Alias
@param nIndice, n, Indice
@param aDados, a, Dados
@param nOper, n, Operacao
@param cModel, C, Modelo de dados
@return aRet, {.F., ""}
@example
(examples)
@see (links_or_references)
/*/
Static Function impMVC(cAliasImp, nIndice, aDados, nOper,cModel)
	Local aRet		:= {.F., ""}
	local cWarn		:= ""
	Local oModel, oAux, oStruct
	Local nI		:= 0
	Local nPos 		:= 0
	Local lRet 		:= .T.
	Local aAux    	:= {}
	Local aCampos	:= {}
	Local nPosFil	:= 0 
	

	dbSelectArea( cAliasImp )
	dbSetOrder( nIndice )
	
	nPosFil := aScan(aDados,{|x| AllTrim( x[1] )== "ZB_FILIAL" } )

	IF nPosFil > 0 
		/*---------------------------------------
			Realiza a TROCA DA FILIAL CORRENTE 
		-----------------------------------------*/
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= aDados[nPosFil][2]//| CODIGO DA FILIAL DE DESTINO 
		
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF
	ENDIF 


	oModFull := FWLoadModel( cModel )

	oModFull:SetOperation( nOper )

	oModFull:Activate()



	oModel 		:= oModFull:GetModel( cAliasImp + 'MASTER' )
	oStruct 	:= oModel:GetStruct()

	aCampos  	:= oStruct:GetFields()


	//| Atribui Valores ao Model|
	For nI := 1 To Len( aDados )
		// Verifica se os campos passados existem na estrutura do modelo
		//If ( nPos := aScan(aDados,{|x| AllTrim( x[1] )== AllTrim(aCampos[nI][3]) } ) ) > 0
		If ( nPos := aScan(aCampos,{|x| AllTrim( x[3] )== AllTrim(aDados[nI][1]) } ) ) > 0

			// È feita a atribuição do dado ao campo do Model
			If ALLTRIM(aDados[nI][1]) == "ZB_FILIAL"
				oModel:LoadValue(aDados[nI][1], aDados[nI][2] )
			ElseIf !( lAux := oModel:SetValue(aDados[nI][1], aDados[nI][2] ) )
				// Caso a atribuição não possa ser feita, por algum motivo (validação, por 	exemplo)
				// o método SetValue retorna .F.

				cWarn	+= aCampos[nI][1]+"- Não foi possivel atribuir valor a este campo"
				
			EndIf
		ELSE
		
			cWarn	+= aCampos[nI][1]+"- Não encontrado na entidade "+cAliasImp
			 
		EndIf
		
	Next nI




	If oModFull:VldData() 
	
		// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
		IF oModFull:CommitData()
		
			aRet	:= {.T., cWarn}
			
		ELSE
		
			aRet[2]	:= oModFull:GetErrorMessage()[6]
			
		ENDIF
		
	ELSE

		aErro := oModFull:GetErrorMessage()
		// A estrutura do vetor com erro é:
		// [1] identificador (ID) do formulário de origem
		// [2] identificador (ID) do campo de origem
		// [3] identificador (ID) do formulário de erro
		// [4] identificador (ID) do campo de erro
		// [5] identificador (ID) do erro
		// [6] mensagem do erro
		// [7] mensagem da solução
		// [8] Valor atribuído
		// [9] Valor anterior


		aRet[2]	:=  aErro[4]+"-"+aErro[6]
		
	EndIf


	oModFull:DeActivate()
	IF nPosFil > 0 
		/*---------------------------------------
			Restaura FILIAL  
		-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF   
	ENDIF 

Return(aRet)




/*/{Protheus.doc} ALCBCPO1
Validacao de usuário;
@author Augusto Ribeiro | www.compila.com.br
@since 28/10/16
@version version
@param cCampo C, Nome do Campo
@param cTipo, C,  V = Validacao, W = When 
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/  
User Function ALCBCPO1(cCampo, cTipo)
Local lRet := .T.
Local nPosCpo, nI
Local oModel 	:= FWModelActive()
LOCAL oModSZB	:= oModel:GetModel(D_MODELMASTER)
Local nOperation := oModel:GetOperation()
Local aAreaZEG := {}

Local oModeZEG, cCodRot

Default cCampo		:= ''
Default cTipo		:= "V"

cCampo := alltrim(cCampo)

/*-------------------
  VALIDACAO
--------------------*/
IF cTipo == "V"

	IF cCampo == "ZB_COMPET"
		cCompet := oModSZB:GetValue("ZB_COMPET")
		
		IF !((LEFT(cCompet,2)>="01" .AND. LEFT(cCompet,2)<="12") .AND. (RIGHT(cCompet,4)>="2000" .AND. RIGHT(cCompet,4)<="2049"))
			oModel:SetErrorMessage(D_MODELMASTER, 'ZB_COMPET' , D_MODELMASTER , 'ZB_COMPET' , "Erro", 'Competencia Invalida.', 'Por favor verificar')
			lRet	:= .F.
		ENDIF 
	ENDIF


	
/*-------------------
 MODO DE EDICAO - WHEN
--------------------*/
ELSEIF cTipo == "W"

ENDIF


Return(lRet)




/*/{Protheus.doc} fDialogo
Monta Dialogo
@author Jonatas Oliveira | www.compila.com.br
@since 08/12/2015
@version 1.0
/*/
Static Function fDialogo(cTitulo, cAliasTab , CQuery, lEstorno)
	Local lRet  := .F.
	Local bOKcPad
	Local bCanccPad
	Local aButtons	:= {}
	Local oFLabels := TFont():New("MS Sans Serif",,026,,.F.,,,,,.F.,.F.)
	Local oFGrpCpo := TFont():New("MS Sans Serif",,018,,.F.,,,,,.F.,.F.)
	Local oCpoBusca
	Local cCpoBusca	:= SPACE(100)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis de posionamento dos campos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private nColAnt	:= 0
	Private lMarkAll	:= .F.
	Private oDlgMain	:= NIL
	Private aSize, aObjects, aInfo, aPosObj, aPosEnc

	Private cBuscaVl	:= 0// SPACE(14)
	Private cBuscaPg	:=  SPACE(15)
	Private cBuscaCN	:=  SPACE(14)
	Private cTotal	:= ""
	Private cTotalP	:= ""
	Private cTotSel	:= ""
	Private cTtSelP	:= ""
	Private nF2VALOR	:= 0
	Private nLTPAGAM	:= 0
	Private nE1PREFIXO, nE1NUM, nE1PARCELA, nE1TIPO, nE1XSTCONF, nSTATUS,nE1FILIAL


	bOKcPad		:= {|| IIF(IIF(GotoReg(cAliasTab, @oLbxMain),  lRet  := .T. , .F.), oDlgMain:End(), .F.) }
	bCanccPad	:= {|| oDlgMain:End()}

	aButtons	:= {}

	//aAdd(aButtons	,{"BMPPOST"	,{|| U_CCOM02EM() },"Envia e-mail com status da SC selecionada", "E-mail" })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dimensionamento da Janela - Parte Superior ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize 		:= MsAdvSize()
	aObjects	 := {}


	aAdd( aObjects, { 100, 100, .T., .T.} )
	//aAdd( aObjects, { 30, 100, .T., .T.} )


	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj 	:= MsObjSize( aInfo, aObjects, .T., .T. )

	aPosEnc	:= {000,000,aPosObj[1,3]-aPosObj[1,1]-12,aPosObj[1,4]-aPosObj[1,2]-1}


	//aPosObj[1,3] -= 15
	aPosObj[1,3] -= 40
	aPosObj[1,4] -= 70
	//aPosObj[1,4] -= 45



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Dialog ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If (Alltrim(GetTheme()) == "OCEAN")                       
		DEFINE MSDIALOG oDlgMain TITLE cTitulo FROM aSize[7],00 to aSize[6]*1,aSize[5]*1 OF oMainWnd PIXEL                                                            
	Else
		DEFINE MSDIALOG oDlgMain TITLE cTitulo FROM aSize[7],00 to aSize[6]*0.6,aSize[5]*0.6 OF oMainWnd PIXEL	
	EndIf   

	//DEFINE MSDIALOG oDlgMain TITLE cTitulo FROM aSize[7],00 to aSize[6]*0.6,aSize[5]*0.6 OF oMainWnd PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta List Solicitacao de Compras ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aHeadMain	:= {}
	Private aDadoMain	:= {}
	Private oLbxMain	:= Nil

	IF ListMain("C",@oLbxMain,@aHeadMain, @aDadoMain, CQuery)
		//	oLbxMain:BLDBLCLICK		:= 	bOKcPad
	ELSE
		Return
	ENDIF


	@  aPosObj[1,1], aPosObj[1,2] SAY oLblSolicita PROMPT D_TITULO SIZE 300, 014 OF oDlgMain FONT oFLabels COLORS 128, 16777215 PIXEL



	//@  aPosObj[1,1]+22, aPosObj[1,4]+10 SAY oLblSolicita PROMPT "Filtros" SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS RGB( 17,   84,   169 ), 16777215 PIXEL
	//oBtnBusca	:= TButton():New(aPosObj[1,1]+32, aPosObj[1,4]+10,"Parametros"	,oDlgMain,		{|| IF(PERGUNTE(D_PARAMETRO,.T.), ListMain("A",@oLbxMain,@aHeadMain, @aDadoMain), .T.), oLbxMain:Refresh() },045,012,,,,.T.,,"Parametros",,,,.F. )
	//oBtnBusca	:= TButton():New(aPosObj[1,1]+45, aPosObj[1,4]+10,"Legenda"		,oDlgMain,		{||  ClickLeg() },045,012,,,,.T.,,"Legenda",,,,.F. )
	
	@  aPosObj[1,1]+22, aPosObj[1,4]+10 SAY oLblSolicita PROMPT "Analise" SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS RGB( 17,   84,   169 ), 16777215 PIXEL
	oBtnBusca	:= TButton():New(aPosObj[1,1]+32, aPosObj[1,4]+10,"Confirma"		,oDlgMain,		{||  ClickBtn("CONFERIDO", aDadoMain, lEstorno), ListMain("A",@oLbxMain,@aHeadMain, @aDadoMain, CQuery) },045,012,,,,.T.,,"Conferido",,,,.F. )	

	//@  aPosObj[1,3]+19, aPosObj[1,2] 	SAY oLblSolicita PROMPT "Selecionados " SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	//oTotSel := TGet():Create( oDlgMain,{|| CalcTot("S", @aDadoMain)},aPosObj[1,3]+29, aPosObj[1,2]	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalP,,,, )
	//	
	//@  aPosObj[1,3]+19, aPosObj[1,2]+100 		SAY oLblSolicita PROMPT "Total NF" 		SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	//oTotalP := TGet():Create( oDlgMain,{|| CalcTot("TP", @aDadoMain)},aPosObj[1,3]+29, aPosObj[1,2]+100	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTtSelP,,,, )
	

		



	oDlgMain:lMaximized := .T.
	ACTIVATE MSDIALOG oDlgMain CENTERED ON INIT Eval({ || EnChoiceBar(oDlgMain,bOKcPad,bCanccPad,,aButtons) })

Return(lRet)





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValidSel ºAutor  ³ Augusto Ribeiro	 º Data ³  26/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Valida se algum registro foi selecionado .                º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ValidSel(aDados)
	Local lRet	:= .F.
	local nI


	IF !EMPTY(aDados)
		FOR nI := 1 to len(aDados)
			IF aDados[nI, 1]
				lRet	:= .T.
				EXIT
			endif
		NEXT nI

	ENDIF

	IF !(lRet)
		AVISO("Selecione um Registro", "Nenhum registro selecionado.", {"Fechar"}, 1)
	ENDIF

Return(lRet)




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ListMain ºAutor  ³ Augusto Ribeiro	 º Data ³  10/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Lista Titulos disponiveis                                 º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ListMain(cOpcList,oLbxMain,aHeader, aDados, cQuery)
	Local lRet		:= .T.
	Local aCpoHeader, nY, nI
	Local cBCodLin	:= ""
	Local aLinha, cCpoNome, cCpoTitle
	Local oOk 	     	:= LoadBitmap( GetResources(), "LBOK" )
	Local oNo   	   	:= LoadBitmap( GetResources(), "LBNO" )

	Local oVerm  		   	:= LoadBitmap( GetResources(), "BR_VERMELHO" )
	Local oVerde  	   	:= LoadBitmap( GetResources(), "BR_VERDE" )
	Local oAmar	  	   	:= LoadBitmap( GetResources(), "BR_AMARELO" )


	aCpoHeader	:= {}
	aHeader		:= {}
	aDados		:= {}

	If Select("QRY") > 0
		QRY->(DbCloseArea())
	EndIf

	MSGRUN("Verificando Lotes....","SQL" ,		{|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRY') } )
	// dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRY')

	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ cOpcList | C = Cria, A = Atualiza ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF cOpcList == "C"

		@ aPosObj[1,1]+12,aPosObj[1,2] LISTBOX oLbxMain FIELDS HEADER ;
		" ", "Campos" ;
		SIZE aPosObj[1,4],aPosObj[1,3] OF oDlgMain PIXEL ON dblClick( aDados[oLbxMain:nAt,1] := !aDados[oLbxMain:nAt,1] , oLbxMain:Refresh()) //dblClick(VisualSC(aDadoMain, oLbxMain:nAt))

		oLbxMain:aheaders := aHeader

		//oLbxMain:BHEADERCLICK	:= { |oObj,nCol| U_XCONPADH( oObj,nCol) }
		oLbxMain:BHEADERCLICK	:= { |oObj,nCol| U_ALCTB1H( oObj,nCol,.t.) }

	ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDados	:= {}
	aLinha	:= {}

	aadd(aHeader, "" )
	aadd(aCpoHeader,"MARK")
	aadd(aLinha, .F. )
	For nY := 1 To QRY->(FCOUNT())

		cCpoNome	:= FieldName(nY)
		cCpoTitle	:= alltrim(RetTitle(cCpoNome))


		aadd(aCpoHeader,cCpoNome)

		IF EMPTY(cCpoTitle)
			aadd(aHeader, Capital(cCpoNome ))
			aadd(aLinha, "" )
		ELSE
			aadd(aHeader,cCpoTitle )
			aadd(aLinha, CRIAVAR(cCpoNome,.F.) )
		ENDIF

	Next nY


	oLbxMain:aheaders := aHeader
	AADD(aDados, aLinha)


	IF QRY->(!EOF())


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Variaveis de posionamento dos campos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		/*
		nSTATUS		:=  Ascan(aCpoHeader,"STATUSCF")
		nE1PREFIXO	:=  Ascan(aCpoHeader,"E1_PREFIXO")
		nE1NUM		:=  Ascan(aCpoHeader,"E1_NUM")
		nE1PARCELA	:=  Ascan(aCpoHeader,"E1_PARCELA")
		nE1TIPO		:=  Ascan(aCpoHeader,"E1_TIPO")
		nE1VALOR	:=  Ascan(aCpoHeader,"E1_VALOR")
		nE1PAGAM	:=  Ascan(aCpoHeader,"E1_XVLRPG")
		nE1XSTCONF	:=  Ascan(aCpoHeader,"E1_XSTCONF")
		nE1FILIAL	:=  Ascan(aCpoHeader,"E1_FILIAL")
		*/


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta aDados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDados	:= {}
		WHILE QRY->(!EOF())
			aLinha	:= {}

			aadd(aLinha, .F. )
			For nY := 1 To QRY->(FCOUNT())

				cCpoNome	:= QRY->(FieldName(nY))
				IF ALLTRIM(cCpoNome) $ "ZB_STATUS"
					aadd(aLinha, QRY->(FIELDGET(nY))+"-"+X3COMBO("ZB_STATUS",QRY->(FIELDGET(nY))))
				ELSE
					aadd(aLinha, QRY->(FIELDGET(nY)) )
				ENDIF 
			Next nY

			AADD(aDados, aLinha)

			QRY->(DBSKIP())
		ENDDO

	ENDIF

	IF VALTYPE(oLbxMain) == "O"
		oLbxMain:SetArray( aDados )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria string com Bloco de Codigo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cBCodLin	:= ""
		cBCodLin	:= "Iif(aDados[oLbxMain:nAt,1],oOk,oNo)"
		For nI := 2 To LEN(aHeader)
			IF nI > 1
				cBCodLin	+=", "
			endif

			cBCodLin	+= "aDados[oLbxMain:nAt,"+alltrim(str(nI))+"]"
			

		Next nI

		cBCodLin	:= "oLbxMain:bLine := {|| {"+cBCodLin+"}}"
		&(cBCodLin)

	ENDIF


	IF VALTYPE(oLbxMain) == "O"
		oLbxMain:Refresh()
	ENDIF
Return(.T.)





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GotoReg   ºAutor  ³ Augusto Ribeiro	 º Data ³  12/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Posiciona no registros selecionado                        º±±
±±º          ³              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GotoReg(cAliasTab, oLbxMain)
	Local lRet := .F.
	Local nPosReg	:= 0

	IF !EMPTY(cAliasTab) .AND. !empty(oLbxMain:nAt) .and. len(oLbxMain:aArray) > 0

		nPosReg	:= oLbxMain:aArray[oLbxMain:nAt, len(oLbxMain:aheaders)]
		if !empty(nPosReg)
			lRet := .T.

			DBSELECTAREA(cAliasTab)
			(cAliasTab)->(DBGOTO(nPosReg))
		ENDIF
	ENDIF


Return(lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AFAT153H   ºAutor  ³ Augusto Ribeiro	 º Data ³  12/03/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Orderna Coluna que o usuario realizar o click ou          º±±
±±º          ³Marca/Desmarca todos os registros selecionados              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function ALCTB1H(oLbxAux, nCol, lMark)

	Default lMark	:= .F.


	If	nCol > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Marca/Desmarca Registrios ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nCol == 1 .AND. lMark

			lMarkAll	:= !(lMarkAll)

			aEval(oLbxAux:aArray, {|x| x[1] := lMarkAll} )
			nColAnt := nCol

			//oTotal:Refresh()
//			oTotSel:Refresh()
//			oTotalP:Refresh()
			//oTotSelP:Refresh()
		ELSEIF nCol == nColAnt
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] < y[nCol] })
			nColAnt := 0
		Else
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] > y[nCol] })
			nColAnt := nCol
		EndIf

		oLbxAux:Refresh()


	EndIf

Return()






/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ClickBtn ºAutor  ³ Augusto Ribeiro	 º Data ³  10/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Ao Clicar nos botoes, funcao realiza a chamada a operacao º±±
±±º          ³  selecionada                                               º±±
±±ºPARAMETROS³  cOpc = "CONFERIDO", "PENDENTE"                            º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ClickBtn(cOpc, aDados, lEstorno)
	Local nI, nPosVlr, cCodPen, lAbort, nPosSel
	Local aRetBox		:= {}
	local aParamBox	:= {}
	Local aCpoLog	:= {}
	Local lAbort, nPosSel
	Local cCadastro	:= ""
	Local cMsgAviso	:= ""



	IF !(ValidSel(aDados))
		RETURN()
	ENDIF


	//| Solicita informacoes da pendencia.
	IF cOpc == "CONFERIDO"
		IF lEstorno
			cMsgAviso	:= " Todos os registros selecionados serão marcados como ESTORNO."
		Else
			cMsgAviso	:= " Todos os registros selecionados serão marcados como EFETIVADO."
		Endif 	
	ENDIF


	cCadastro	:= cOpc

	IF AVISO(cOpc, cMsgAviso, {"Continuar", "Cancelar"}, 2) == 1


		nPosRec	:= LEN(aDados[1])

		IF EMPTY(nPosRec)

			AVISO("FALHA", "Registro Invalido", {"Cancelar"}, 2)

		ELSEIF cOpc == "CONFERIDO"

			FOR nI := 1 to len(aDados)
				IF aDados[nI, 1]
					IF cOpc == "CONFERIDO"
						AADD(aRegSZB, aDados[nI, nPosRec])
						nTotReg++
					ENDIF
				endif
			NEXT nI
			
			oDlgMain:End()
			
					
		ENDIF
	ENDIF




Return()