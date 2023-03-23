#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
//#Include "tbiconn.Ch"

#DEFINE EOL Chr(13)+Chr(10)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ COMPILAXFUN บAutor  ณ Augusto Ribeiro บ Data ณ  05/03/2014 บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ LIB Compila (Funcoes Genericas)                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบATENCAO   ณ Todas as fucoes quando passado o primeiro parametro uma    บฑฑ
ฑฑบ          ณ string "COMPILA", apresenta informacoes da rotina e como   บฑฑ
ฑฑบ          ณ aviso e retorno string com informacoes                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/


/*/{Protheus.doc} CPXGRV
Realiza a gravacao de registros via RECLOCK e inicializando
todos os inicializadores padroes. Realiza consitencia se 
registro ja existe de acordo com a chave passada
@author Augusto Ribeiro | www.compila.com.br
@since 03/04/2014
@version 6
@param cAliasTab,  Alias da tabela 
@param nChvInd, Indice para consulta da chave
@param aDados, Dados a serem gravados
@param lIniPadrao, Inicializa Inicializadores padroes (default .t.)
@param lVldChave, Realiza consistencia para verificar se a chave de registo existe (default .t.) | Caso este parametro seja passado como .F., SEMPRE serแ realizada a opera็ใo de INCLUSAO
@param nOpcGrv, 1=Inclui/Altera (Default); 2=Somente Inclusao (RETORNA FALHA CASO REGISTRO Jม EXISTA), 3=Inclui sem Validar Chave, 
@return aRet{lRet, cMsgErro}
@example
(examples)
@see COMPLA (www.compila.com.br)
/*/
User function CPXGRV(cAliasTab, nChvInd, aDados, lIniPadrao, nOpcGrv)
Local aRet	:= {.F., ""}
Local cPrefCpo
Local nI, nAux, nPosAlias, nCpoAlias, nPosAux, cCampo
Local cChvReg	:= ""

Default lIniPadrao	:= .T.
//Default lVldChave	:= .T.
Default nOpcGrv		:= 1

/*-----------------------------
	INFORMACOES DA ROTINA
	* PROPRIEDADE INTELECTUAL * 
-------------------------------*/
//CONOUT("[compila.com.br] - Para maiores informacoes U_CPXGRV('COMPILA')")
IF VALTYPE(cAliasTab) == "C"
	IF UPPER(cAliasTab) == "COMPILA"
		cInfoComp	:= "COMPILA [www.compila.com.br]  - Propriedade Intelectual "+CRLF+CRLF
		cInfoComp	+= "ROTINA: CPXGRV"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "DESCRICAO: Realiza a gravacao de registros via RECLOCK e inicializando todos os inicializadores padroes. Realiza consitencia se egistro ja existe de acordo com a chave passada"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "PARAMETROS: cAliasTab: Alias da tabela "+CRLF
		cInfoComp	+= " nChvInd: Indice para consulta da chave "+CRLF
		cInfoComp	+= " aDados: Dados a serem gravados "+CRLF
		cInfoComp	+= " lIniPadrao: Quando Inclusao, inicializa inicializadores padroes (.T.) "+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "RETORNO: aRet{lRet, cMsgErro} "+CRLF
	
		AVISO("COMPILA - LIB",cInfoComp,{"fechar"},3,"www.compila.com.br")
	
		return(cInfoComp)
	ENDIF
ENDIF

IF !EMPTY(cAliasTab) .and. !empty(nChvInd) .and. !empty(aDados)

	/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 9:35:57 AM
		Ignora validacao de chave de registro, forcando a sempre executar opera็ใo de inclusใo
	------------------------------------------------------------------------------------------*/
	IF nOpcGrv == 1 .or.  nOpcGrv == 2
	
		DBSELECTAREA(cAliasTab)
		(cAliasTab)->(DBSETORDER(nChvInd))
		
		/*-------------------------------------
			MONTA CHAVE DE CONSULTA 
		-------------------------------------*/
		aChvInd	:= STRTOKARR( IndexKey(nChvInd), "+" )
		
		FOR nI := 1 TO LEN(aChvInd)
			nPosCpo	:= 	aScan(aDados, { |x| AllTrim(x[1]) == alltrim(aChvInd[nI]) })
			IF nPosCpo > 0
				cChvReg	+= aDados[nPosCpo,2]
			ENDIF 
		NEXT nI 
		
		
				
		IF EMPTY(cChvReg)
			aRet[2]	:= "Nao foi possivel montar a chave de pesquisa."	
		ENDIF
	
	ENDIF
	
	
	
	/*--------------------------
		3=Inclui sem Validar Chave, 
	---------------------------*/
	IF  nOpcGrv == 3
		RegToMemory(cAliasTab, .T., .f., lIniPadrao)
		RECLOCK(cAliasTab, .T.)
		aRet[2]	:= "INCLUI"	
	
	ELSEIF EMPTY(aRet[2])
	
		IF (cAliasTab)->(DBSEEK(cChvReg,.F.))
			IF nOpcGrv == 1
				RECLOCK(cAliasTab, .F.)
				aRet[2]	:= "ALTERA"
			ELSEIF nOpcGrv == 2			
				aRet[2]	:= "JAEXISTE"
			ENDIF		
		ELSE
			RegToMemory(cAliasTab, .T., .f., lIniPadrao)
			RECLOCK(cAliasTab, .T.)
			aRet[2]	:= "INCLUI"				
		ENDIF	
	ENDIF
	
	
	IF aRet[2] == "INCLUI" .OR. aRet[2] == "ALTERA"
	
		nCpoAlias	:= (cAliasTab)->(FCOUNT())
		FOR nI := 1 to nCpoAlias
			cCampo		:= ALLTRIM((cAliasTab)->(FIELDNAME(nI)))
			nPosAux	:= aScan(aDados, { |x| AllTrim(x[1]) == cCampo })
			
			//| Minimiza uso de Macro substitui็ใo paara otimzar performance
			IF !EMPTY(nPosAux)
				IF VALTYPE(aDados[nPosAux,2]) == "C" .AND. !EMPTY(aDados[nPosAux,2])
					aDados[nPosAux,2] := RemovChar(aDados[nPosAux,2]) 
				ENDIF 
				FIELDPUT(nI, aDados[nPosAux,2])
			ELSEIF aRet[2]	== "INCLUI"
				FIELDPUT(nI, M->&(cCampo))			
			ENDIF			
		NEXT nI		
		
		
		MSUNLOCK()
		aRet[1]		:= .T.
			
		IF aRet[2]	== "INCLUI"	
			CONFIRMSX8()
		ENDIF	
	ENDIF
		

ELSE
	aRet[2]	:= "Parametros invแlidos"
ENDIF		

Return(aRet)







/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ ReadErrorบAutor  ณAugusto Ribeiro     บ Data ณ 21/12/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Realiza o parse do ERROR log retornado em ExecAuto        บฑฑ
ฑฑบ          ณ retornando erro resumino de facil interpretacao            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบPARAMEROS ณ cErro: Mensagem de Erro a ter tratada                      บฑฑ
ฑฑบ          ณ lRetTabela: Retorna Nome da tabela que gerou a Falha.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบRETORNO   ณ cRet: Mensagem de erro simplificada                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ USO      ณ COMPLA (www.compila.com.br)                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function CPXERRO(cErro, lRetTabela)
Local cErroPart		:= ""
Local cErroAmigo	:= ""
Local cErroAux		:= ""
Local cAliasErro	:= ""

Local nPos1, nPos2

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Indica a posicao para iniciar a leitura.              ณ
//ณ Posicao se altera de acordo com os caracteres ja lido ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nPosRead	:= 1

Default lRetTabela	:= .F.


/*-----------------------------
	INFORMACOES DA ROTINA
	* PROPRIEDADE INTELECTUAL * 
-------------------------------*/
CONOUT("[compila.com.br] - Para maiores informacoes U_CPXERRO('COMPILA')")
IF VALTYPE(cErro) == "C"
	IF UPPER(cErro) == "COMPILA"
		cInfoComp	:= "COMPILA [www.compila.com.br]  - Propriedade Intelectual "+CRLF+CRLF
		cInfoComp	+= "ROTINA: CPXERRO"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "DESCRICAO: Realiza o parse do ERROR log retornado em ExecAuto retornando erro resumino de facil interpretacao "+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "PARAMETROS: cErro: Mensagem de Erro a ter tratada  "+CRLF
		cInfoComp	+= " lRetTabela: Retorna Nome da tabela que gerou a Falha. "+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= " RETORNO: cRet: Mensagem de erro simplificada   "+CRLF
	
		AVISO("COMPILA - LIB",cInfoComp,{"fechar"},3,"www.compila.com.br")
	
		return(cInfoComp)
	ENDIF
ENDIF


IF !EMPTY(cErro)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ                                     ณ
	//ณ Recupera somente a mensagem do HELP ณ
	//ณ                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cErro	:= alltrim(cErro)
	IF LEFT(cErro,5) == "HELP:"
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Busca primeira quebra de linha.   ณ
		//ณ Indica inicio da mensagem de help ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPos1	:= At(EOL,cErro)
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Busca duas quebra se linhas na sequencia ณ
		//ณ Indica o fim da mensagem do Help         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPos2 		:= At(EOL+EOL,cErro)
		IF nPos2 <= 0
			nPos2	:= LEN(cErro)
		ENDIF
		
		nPosRead	:= nPos2+3
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Se posicoes forem diferentes, indica que existe mensagem de Help ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF nPos1 <> nPos2
			nPos2	:= ((nPos2-1)-nPos1)
			cErroAmigo += "MSG.ERRO:"+REPLACE(SUBSTR(cErro, nPos1+2, nPos2-1), "xx","")
		ENDIF
		
	ENDIF
	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ                                                            ณ
	//ณ Busca nome da Tabela que gerou o Erro Ex. (Cabec ou Itens) ณ
	//ณ                                                            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF lRetTabela
		cErroPart	:= alltrim(SUBSTR(cErro, nPosRead, len(cErro)))
		
		nPos2		:= At("TABELA ",UPPER(cErroPart))
		IF nPos2 > 0
			cAliasErro	:= SUBSTR(cErroPart, nPos2+LEN("TABELA "), 3)
			
			
			DbSelectArea("SX2")
			SX2->(DBSETORDER(1))
			IF SX2->(Dbseek(cAliasErro, .F.))
				cErroAux	:= "TABELA:"+cAliasErro+"-"+ALLTRIM(SX2->(FIELDGET(FIELDPOS("X2_NOME"))))
				
				cErroAmigo 	:= cErroAux+" |"+cErroAmigo
			ENDIF
		ENDIF
	ENDIF
	
	
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ                                        ณ
	//ณ Recupera linha do campo  <-- Invalido  ณ
	//ณ                                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cErroPart	:= alltrim(SUBSTR(cErro, nPosRead, len(cErro)))
	
	nPos2		:= At("< --",cErroPart)
	IF nPos2 > 0
		nPos2		:= (At(EOL,alltrim(Substr(cErroPart,nPos2,len(cErroPart)) ))+nPos2)-1
		nPos1		:= Rat(EOL,Substr(cErroPart,1,nPos2))+2
		
		cErroAmigo	+=  " |CAMPO:"+Substr(cErroPart,nPos1,nPos2-nPos1)
	ENDIF
	
	cErroAmigo	:= ALLTRIM(cErroAmigo)
ENDIF

Return(cErroAmigo)















/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ cpXCPAD  บAutor  ณ Augusto Ribeiro 	 บ Data ณ  23/01/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Monta interface de consulta conforme parametros passados  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบPARAMETROSณcTitulo: Titulo da Rotina                                   บฑฑ
ฑฑบ          ณcAliasTab: Alias da Tabela                                  บฑฑ
ฑฑบ          ณcQuery: Query a ser executada deve converte obrigatoriamenteบฑฑ
ฑฑบ          ณ   Coriga #CAMPO_BUSCA# para like com campo e consulta      บฑฑ
ฑฑบ          ณ   Campo TAB_RECNO, que deve retornar Recno do alias passado.บฑฑ
ฑฑบ          ณaBtnAdd: {cBtnNome, cUserFunc}                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบRETORNO   ณlRet ; .T. quando usuario clica em confirmar.               บฑฑ
ฑฑบ          ณ *Sempre sera posicionado no alias ao clicar no botao ok.   sบฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User function CPXCPAD(cTitulo, cAliasTab, cQuery, aBtnAdd)
Local lRet := .F.


/*-----------------------------
	INFORMACOES DA ROTINA
	* PROPRIEDADE INTELECTUAL * 
-------------------------------*/
CONOUT("[compila.com.br] - Para maiores informacoes U_CPXCPAD('COMPILA')")
IF VALTYPE(cTitulo) == "C"
	IF UPPER(cTitulo) == "COMPILA"
		cInfoComp	:= "COMPILA [www.compila.com.br]  - Propriedade Intelectual "+CRLF+CRLF
		cInfoComp	+= "ROTINA: cpXCPAD"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "DESCRICAO: Monta interface de consulta com base da query passada."+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "PARAMETROS: cTitulo: Titulo da Rotina "+CRLF
		cInfoComp	+= "cAliasTab: Alias da Tabela "+CRLF
		cInfoComp	+= "cQuery: Query a ser executada deve converte obrigatoriamente "+CRLF
		cInfoComp	+= "   Coriga #CAMPO_BUSCA# para like com campo e consulta "+CRLF
		cInfoComp	+= "   Campo TAB_RECNO, que deve retornar Recno do alias passado "+CRLF
		cInfoComp	+= "aBtnAdd: {cBtnNome, cUserFunc} "+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "RETORNO: lRet ; .T. quando usuario clica em confirmar. "+CRLF
		cInfoComp	+= " *Sempre sera posicionado no alias ao clicar no botao ok. "+CRLF
		cInfoComp	+= CRLF	
		cInfoComp	+= " *EXEMPLO* "	
		cInfoComp	+= " SELECT A1_NOME, A1_CGC, A1_COD, A1_LOJA, SA1.R_E_C_N_O_ AS TAB_RECNO 
		cInfoComp	+= " FROM SA1010 SA1
		cInfoComp	+= " WHERE A1_NOME LIKE '#CAMPO_BUSCA#%' 
		cInfoComp	+= " AND SA1.D_E_L_E_T_ = ''	
	
	
		AVISO("COMPILA - LIB",cInfoComp,{"fechar"},3,"www.compila.com.br")
	
		return(cInfoComp)
	ENDIF
ENDIF


IF !EMPTY(cTitulo).AND. !EMPTY(cAliasTab) .AND. !EMPTY(cQuery)
	lRet	:= fDlgCPAD(cTitulo, cAliasTab, cQuery,aBtnAdd)
ENDIF

Return(lRet)





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fDialogo บAutor  ณ Augusto Ribeiro	 บ Data ณ  10/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Monta Dialogo                                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fDlgCPAD(cTitulo, cAliasTab, cQuery, aBtnNew)
Local lRet  := .F.
Local bOKcPad		
Local bCanccPad		
Local aButtons	:= {}   
Local oFLabels := TFont():New("MS Sans Serif",,026,,.F.,,,,,.F.,.F.)
Local oCpoBusca
Local cCpoBusca	:= SPACE(100)

Default aBtnNew	:= {}


Private aBtnAdd	:= aClone(aBtnNew)
                     
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis de posionamento dos campos ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private nColAnt	:= 0
Private lMarkAll	:= .F.
Private oDlgMain	:= NIL
Private aSize, aObjects, aInfo, aPosObj, aPosEnc
                
bOKcPad		:= {|| IIF(IIF(GotoReg(cAliasTab, @oLbxMain),  lRet  := .T. , .F.), oDlgMain:End(), .F.) }
bCanccPad	:= {|| oDlgMain:End()} 	

aButtons	:= {}

//aAdd(aButtons	,{"BMPPOST"	,{|| U_CCOM02EM() },"Envia e-mail com status da SC selecionada", "E-mail" })

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDimensionamento da Janela - Parte Superior ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize 		:= MsAdvSize()		
aObjects	 := {}
 

aAdd( aObjects, { 100, 100, .T., .T.} )	


aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj 	:= MsObjSize( aInfo, aObjects, .T., .T. )                                                                         

aPosEnc	:= {000,000,aPosObj[1,3]-aPosObj[1,1]-12,aPosObj[1,4]-aPosObj[1,2]-1}


aPosObj[1,3]	:= (aPosObj[1,3]*0.50)-20
aPosObj[1,4]	:= aPosObj[1,4]*0.60

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Dialog ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgMain TITLE cTitulo FROM aSize[7],00 to aSize[6]*0.6,aSize[5]*0.6 OF oMainWnd PIXEL	

//@  aPosObj[1,1]-12, aPosObj[1,2] SAY oLblSolicita PROMPT "Busca" SIZE 300, 014 OF oDlgMain FONT oFLabels COLORS 128, 16777215 PIXEL

@ aPosObj[1,1], aPosObj[1,2] MSGET oCpoBusca VAR cCpoBusca /*PICTURE "@!"*/ SIZE 98,10 OF oDlgMain PIXEL  ON CHANGE ListMain("A",@oLbxMain,@aHeadMain, @aDadoMain, cQuery, cCpoBusca)

oBtnBusca	:= TButton():New(aPosObj[1,1], (aPosObj[1,2]+100),"Buscar",oDlgMain,		{|| ListMain("A",@oLbxMain,@aHeadMain, @aDadoMain, cQuery, cCpoBusca), oLbxMain:Refresh() },045,012,,,,.T.,,"Buscar",,,,.F. )
IF LEN(aBtnAdd) > 0
	oBtnNew	:= TButton():New(aPosObj[1,1], (aPosObj[1,4]-60),aBtnAdd[1],oDlgMain,		{|| &(aBtnAdd[2]), ListMain("A",@oLbxMain,@aHeadMain, @aDadoMain, cQuery, cCpoBusca), oLbxMain:Refresh() },060,012,,,,.T.,,aBtnAdd[1],,,,.F. )
ENDIF	


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta List Solicitacao de Compras ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
Private aHeadMain	:= {}       
Private aDadoMain	:= {}
Private oLbxMain	:= Nil            

IF ListMain("C",@oLbxMain,@aHeadMain, @aDadoMain, cQuery, cCpoBusca)
	oLbxMain:BLDBLCLICK		:= 	bOKcPad	  
ELSE
	Return
ENDIF
 

//oDlgMain:lMaximized := .T.		
ACTIVATE MSDIALOG oDlgMain CENTERED ON INIT Eval({ || EnChoiceBar(oDlgMain,bOKcPad,bCanccPad,,aButtons) })

Return(lRet)        



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ListMain บAutor  ณ Augusto Ribeiro	 บ Data ณ  10/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  List Solicitacao de Compras                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ListMain(cOpcList,oLbxMain,aHeader, aDados, cQuery, cCpoDado)
Local lRet		:= .T.
Local aCpoHeader, nY, nI
Local cBCodLin	:= ""  
Local aLinha, cCpoNome, cCpoTitle
Local cTmpQry	:= GetNextAlias()
     
aCpoHeader	:= {} 
aHeader		:= {} 
aDados		:= {}

/*
cQuery	:= " SELECT ZAV_CODIGO, "+CRLF
cQuery	+= " 		ZAV_DESCRI, "+CRLF
cQuery	+= " 		ZAV.R_E_C_N_O_  AS TAB_RECNO"+CRLF
cQuery	+= " FROM "+RetSqlname("ZAV")+" ZAV "+CRLF
cQuery	+= " WHERE ZAV_FILIAL = '' "+CRLF
cQuery	+= " AND ZAV.D_E_L_E_T_ = '' "+CRLF
*/

cCpoDado	:=  strtran(strtran(ALLTRIM(cCpoDado),"'",""),'"',"")

cQuery	:= STRTRAN(cQuery, "#CAMPO_BUSCA#", cCpoDado)

	
If Select(cTmpQry) > 0
	(cTmpQry)->(DbCloseArea())
EndIf
         
CursorWait()           
//MSGRUN("Buscando registros....","SQL" ,		{|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTmpQry) } )
dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cTmpQry)
MemoWrite(GetTempPath(.T.) + "ListMain.SQL", cQuery) 

CursorArrow()					
// dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRY')



//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ cOpcList | C = Cria, A = Atualiza ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF cOpcList == "C"

	@ aPosObj[1,1]+12,aPosObj[1,2] LISTBOX oLbxMain FIELDS HEADER ;
	   " ", "Campos" ;                                                                                                    
	   SIZE aPosObj[1,4],aPosObj[1,3] OF oDlgMain PIXEL //ON dblClick( aDados[oLbxMain:nAt,1] := !aDados[oLbxMain:nAt,1] ,oLbxMain:Refresh()) //dblClick(VisualSC(aDadoMain, oLbxMain:nAt))
	   
	oLbxMain:aheaders := aHeader		   

	oLbxMain:BHEADERCLICK	:= { |oObj,nCol| U_CPXORDH( oObj,nCol) }
			
ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta aHeader ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
aDados	:= {}
aLinha	:= {}		 
aHeader	:= {}
For nY := 1 To (cTmpQry)->(FCOUNT())         

	cCpoNome	:= (cTmpQry)->(FieldName(nY))
	cCpoTitle	:= alltrim((cTmpQry)->(RetTitle(cCpoNome)))
	
	IF EMPTY(cCpoTitle)
		aadd(aHeader,cCpoNome )
	ELSE
		aadd(aHeader,cCpoTitle )
	ENDIF
	aadd(aCpoHeader,cCpoNome)
	
	IF EMPTY(cCpoTitle)		
		aadd(aLinha, "" )
	ELSE                                              				
		aadd(aLinha, CRIAVAR(cCpoNome,.F.) )
	ENDIF		
	
Next nY	
 
 
oLbxMain:aheaders := aHeader
AADD(aDados, aLinha)			


IF (cTmpQry)->(!EOF()) 

	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Variaveis de posionamento dos campos ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//nP04CODCLI	:=  Ascan(aCpoHeader,"P04_CODCLI")
 
			
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta aDados ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aDados	:= {}
	WHILE (cTmpQry)->(!EOF())
		aLinha	:= {}
		
		For nY := 1 To (cTmpQry)->(FCOUNT())
		
			cCpoNome	:= (cTmpQry)->(FieldName(nY))      

			IF VALTYPE((cTmpQry)->(FIELDGET(nY))) == "C"     
			
				aadd(aLinha, (cTmpQry)->(FIELDGET(nY)) )
			ELSE                                              				
				aadd(aLinha, (cTmpQry)->(FIELDGET(nY)) )
			ENDIF
		Next nY	 
		
	 	AADD(aDados, aLinha)
	 	
		(cTmpQry)->(DBSKIP())
	ENDDO                       

ENDIF

IF VALTYPE(oLbxMain) == "O"
	oLbxMain:SetArray( aDados )  
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Cria string com Bloco de Codigo ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cBCodLin	:= ""
	For nI := 1 To LEN(aHeader)
		IF nI > 1
			cBCodLin	+=", "
		endif
	   cBCodLin	+= "aDados[oLbxMain:nAt,"+alltrim(str(nI))+"]"
	Next nI	

	cBCodLin	:= "oLbxMain:bLine := {|| {"+cBCodLin+"}}"
	&(cBCodLin)    
  
  	oLbxMain:Refresh()
ENDIF

(cTmpQry)->(DbCloseArea()) 
 
Return(.T.)





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GotoReg   บAutor  ณ Augusto Ribeiro	 บ Data ณ  12/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Posiciona no registros selecionado                        บฑฑ
ฑฑบ          ณ              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
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


/*/{Protheus.doc} CPXORDH
Orderna Coluna que o usuario realizar o click ou Marca/Desmarca todos os registros selecionados
ATENCAO: Necessairo declarar variavel "nColAnt" com private  
@author Augusto Ribeiro | www.compila.com.br
@since 28/01/2015
@version 1.0
@param oLbxAux, C, Objeto ListBox
@param nCol, N, Numero da Coluna
@param lMark, L, Marca ou Desmarca
/*/
//User Function CPXCPADH(oLbxAux, nCol, lMark)
User Function CPXORDH(oLbxAux, nCol, lMark)
Local lMarkAll
Default lMark	:= .F.


/*-----------------------------
	INFORMACOES DA ROTINA
	* PROPRIEDADE INTELECTUAL * 
-------------------------------*/
CONOUT("[compila.com.br] - Para maiores informacoes U_CPXCPADH('COMPILA')")
IF VALTYPE(oLbxAux) == "C"
	IF UPPER(oLbxAux) == "COMPILA"
		cInfoComp	:= "COMPILA [www.compila.com.br]  - Propriedade Intelectual "+CRLF+CRLF
		cInfoComp	+= "ROTINA: CPXCPADH"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "DESCRICAO: Orderna Coluna que o usuario realizar o click ou Marca/Desmarca"
		cInfoComp	+= " todos os registros selecionados."+CRLF
		cInfoComp	+= "ATENCAO: Necessairo declarar variavel 'nColAnt' com private"
		cInfoComp	+= CRLF
		cInfoComp	+= "PARAMETROS: coLbxAux, nCol, lMark "+CRLF
		cInfoComp	+= "	oLbxAux, C, Objeto ListBox "+CRLF
		cInfoComp	+= "	nCol, N, Numero da Coluna "+CRLF
		cInfoComp	+= "	lMark, L, Marca ou Desmarca "+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "RETORNO: NIL "+CRLF	
	
		AVISO("COMPILA - LIB",cInfoComp,{"fechar"},3,"www.compila.com.br")
	
		return(cInfoComp)
	ENDIF
ENDIF


If	nCol > 0

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Marca/Desmarca Registrios ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF !EMPTY(oLbxAux:aArray)
		If nCol == 1 .AND. lMark
		                   
			lMarkAll	:= !(oLbxAux:aArray[1,1])
	
			aEval(oLbxAux:aArray, {|x| x[1] := lMarkAll} )
			nColAnt := nCol			
		
		ELSEIF nCol == nColAnt
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] < y[nCol] })
			nColAnt := 0
		Else
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] > y[nCol] })
			nColAnt := nCol
		EndIf
	
		oLbxAux:Refresh()
	ENDIF
	
EndIf

Return()



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RemovCharบAutor  ณ Augusto Ribeiro	 บ Data ณ  08/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Remove caracter especial                                   ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
STATIC Function RemovChar(cRet)
Local cRet

cRet	:= upper(cRet)

cRet	:= STRTRAN(cRet,"ม","A")
cRet	:= STRTRAN(cRet,"ษ","E")
cRet	:= STRTRAN(cRet,"อ","I")
cRet	:= STRTRAN(cRet,"ำ","O")
cRet	:= STRTRAN(cRet,"ฺ","U")
cRet	:= STRTRAN(cRet,"ภ","A")
cRet	:= STRTRAN(cRet,"ศ","E")
cRet	:= STRTRAN(cRet,"ฬ","I")
cRet	:= STRTRAN(cRet,"า","O")
cRet	:= STRTRAN(cRet,"ู","U")
cRet	:= STRTRAN(cRet,"ร","A")
cRet	:= STRTRAN(cRet,"ี","O")
cRet	:= STRTRAN(cRet,"ฤ","A")
cRet	:= STRTRAN(cRet,"ห","E")
cRet	:= STRTRAN(cRet,"ฯ","I")
cRet	:= STRTRAN(cRet,"ึ","O")
cRet	:= STRTRAN(cRet,"Ü","U")
cRet	:= STRTRAN(cRet,"ย","A")
cRet	:= STRTRAN(cRet,"ส","E")
cRet	:= STRTRAN(cRet,"ฮ","I")
cRet	:= STRTRAN(cRet,"ิ","O")
cRet	:= STRTRAN(cRet,"Û","U")
cRet	:= STRTRAN(cRet,"ว","C")   

Return(cRet)




/*/{Protheus.doc} CPXSEMAF
Rotina responsavel pela abertura e fechamento de semaforo de processamento
@author Augusto Ribeiro | www.compila.com.br
@since 11/02/2015
@version 1.0
@param cAbreFecha, C, A="Abre" semaforo (cria arquivo e o mantem aberto), F=Fecha (Libera semaforo para utilizacao)
@param cFile, C, Nome do Semaforo (arquivo fisivo sera criado)
@param nHSemafaro, N, Numero do Handle do arquivo a ser fechado.
@return nRet, Handle do arquivo de semaforo criado. Quando MAIOR que ZERO, semaforo aberto com suceso, MENOR ou IGUAL a Zero = nao foi possivel abrir o semaforo.
/*/

User Function CPXSEMAF(cAbreFecha, cFile, nHSemaf)
Default cAbreFecha	:= ""
Default nHSemaf	:= 0

/*-----------------------------
	INFORMACOES DA ROTINA
	* PROPRIEDADE INTELECTUAL * 
-------------------------------*/
IF VALTYPE(cAbreFecha) == "C"
	IF UPPER(cAbreFecha) == "COMPILA"
		cInfoComp	:= "COMPILA [www.compila.com.br]  - Propriedade Intelectual "+CRLF+CRLF
		cInfoComp	+= "ROTINA: CPXSEMAF"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "DESCRICAO: Rotina responsavel pela abertura e fechamento de semaforo de processamento"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "PARAMETROS: cAbreFecha, C, A=Abre semaforo (cria arquivo e o mantem aberto), F=Fecha (Libera semaforo para utilizacao) "+CRLF
		cInfoComp	+= " cFile, C, Nome do Semaforo (arquivo fisivo sera criado) "+CRLF
		cInfoComp	+= " nHSemaf, N, Numero do Handle do arquivo a ser fechado."+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "RETORNO: nRet, Handle do arquivo de semaforo criado. Quando MAIOR que ZERO, semaforo aberto com suceso, MENOR ou IGUAL a Zero = nao foi possivel abrir o semaforo."+CRLF
	
		AVISO("COMPILA - LIB",cInfoComp,{"fechar"},3,"www.compila.com.br")
	
		return(cInfoComp)
	ENDIF
ENDIF

IF !EMPTY(cFile) 

	cFile			:= LOWER(alltrim(cFile))
	cAbreFecha		:= UPPER(ALLTRIM(cAbreFecha))
	/*------------------------------------------------------------|  Augusto Ribeiro - 11/02/2015
		ABRE SEMAFORO
	-------------------------------------------------------------------------------------------*/
	IF cAbreFecha == "A"
		
		nHSemaf 	:= FCreate("CPXSEMAF_"+cFile+".lck")
		
		If nHSemaf < 0 
			nHSemaf := 0
		Endif
		
	/*------------------------------------------------------------|  Augusto Ribeiro - 11/02/2015
		FECHA SEMAFORO
	-------------------------------------------------------------------------------------------*/	
	ELSEIF cAbreFecha == "F" .AND. !EMPTY(nHSemaf)
		
		FCLOSE(nHSemaf)
		
		If ValType(cFile) == "C"
		   Ferase("CPXSEMAF_"+cFile+".lck")
		EndIf  
	ENDIF
ENDIF

Return(nHSemaf)


/*/{Protheus.doc} CPXBrwX1
Monta Pequeno Browser da Pergunta SX1, permitindo que o usuแrio selecione mais de uma op็ใo.
@author Augusto Ribeiro | www.compila.com.br
@since 16/02/2015
@version 1.0
@param cTitBrw, C, Titulo da Janela
@param aOpcoes, A, Lista de Op็๕es
@return xRet, logico ou Caracter
/*/
User Function CPXBrwX1(cTitBrw,aOpcoes)
Local BrowX1
Local MvPar, nI
Local MvParDef	:=	""
Local l1Elem   	:=	Nil      
Local lTipoRet	:= 	.T.  
Local cFilBack	:= cFilAnt

Private _aFilial:=	{}
Private aSit	:= 	{}




/*-----------------------------
	INFORMACOES DA ROTINA
	* PROPRIEDADE INTELECTUAL * 
-------------------------------*/
IF VALTYPE(cTitBrw) == "C"
	IF UPPER(cTitBrw) == "COMPILA"
		cInfoComp	:= "COMPILA [www.compila.com.br]  - Propriedade Intelectual "+CRLF+CRLF
		cInfoComp	+= "ROTINA: CPXBrwX1"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "DESCRICAO: Monta Pequeno Browser da Pergunta SX1, permitindo que o usuแrio selecione mais de uma op็ใo."+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "PARAMETROS: cTitBrw, C, Titulo da Janela"+CRLF
		cInfoComp	+= " aOpcoes, A, Lista de Op็๕es "+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "RETORNO: xRet, logico ou Caracter "+CRLF
	
		AVISO("COMPILA - LIB",cInfoComp,{"fechar"},3,"www.compila.com.br")
	
		return(cInfoComp)
	ENDIF
ENDIF


l1Elem 			:= 	If (l1Elem = Nil , .F. , .T.)

DEFAULT lTipoRet	:= .T.
DEFAULT BrowX1 		:= "Selecione"
DEFAULT aOpcoes		:= {}
                        
	IF LEN(aOpcoes) == 0
		Return
	ENDIF
	
	cAlias 			:= Alias() 					 // Salva Alias Anterior
	
	IF lTipoRet
		MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIF
	

	For nI := 1 To LEN(aOpcoes)
		         
		aadd(aSit, aOpcoes[nI,1]+" - "+aOpcoes[nI,2])				
		MvParDef += aOpcoes[nI,1]
	Next nI
	
                                                     
	
	// Tamanho dos caracters de retorno (Ex.: 04)
	nTam := LEN(aOpcoes[1,1])
	lComboBox := .T.      
	IF lTipoRet
		IF f_Opcoes(@MvPar,BrowX1,aSit,MvParDef,12,49,l1Elem,nTam)	// Chama funcao f_Opcoes
			&MvRet := mvpar                                   			// Devolve Resultado
		EndIF	
	EndIF
	
	dbSelectArea(cAlias) 	 // Retorna Alias
	
	cFilAnt	:= cFilBack 	// Retorna a empresa
	
Return( IF( lTipoRet , .T. , MvParDef ) )
                                                   
                                                   
                                                   

                                                   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fEmpFil  บAutor  ณAugusto Ribeiro     บ Data ณ 04/12/2010  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorno Empresa Filial do SM0 do CNPJ passado              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบParametrosณ cCNPJ                                                      บฑฑ
ฑฑบRetorno   ณ aRet := {cCodEmp, cCodFild}                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  

/*/{Protheus.doc} CPXFILSM0
Retorno Empresa Filial do SM0 do CNPJ passado
@author Augusto Ribeiro | www.compila.com.br
@since 11/06/2014
@version 1.0
@param cCNPJ, C, cnpj
@return  aRet, {cCodEmp, cCodFild}  
/*/
User Function CPXFILSM0(cCNPJ)
Local cRet		:= {"", ""}   
Local aAreaSM0 


/*-----------------------------
	INFORMACOES DA ROTINA
	* PROPRIEDADE INTELECTUAL * 
-------------------------------*/
IF VALTYPE(cCNPJ) == "C"
	IF UPPER(cCNPJ) == "COMPILA"
		cInfoComp	:= "COMPILA [www.compila.com.br]  - Propriedade Intelectual "+CRLF+CRLF
		cInfoComp	+= "ROTINA: CPXFILSM0"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "DESCRICAO: Retorno Empresa Filial do SM0 do CNPJ passado."+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "PARAMETROS: cCNPJ, C, CNPJ"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "RETORNO: aRet, {cCodEmp, cCodFild} "+CRLF
	
		AVISO("COMPILA - LIB",cInfoComp,{"fechar"},3,"www.compila.com.br")
	
		return(cInfoComp)
	ENDIF
ENDIF

                                                     
IF !EMPTY(cCNPJ)           
	cCNPJ	:= ALLTRIM(cCNPJ)

	DBSELECTAREA("SM0")
	aAreaSM0 := SM0->(GetArea())
	
	IF ALLTRIM(SM0->M0_CGC) == cCNPJ 
		cRet := {SM0->M0_CODIGO, SM0->M0_CODFIL}
	ELSE
		SM0->(DBGOTOP())  
		
		WHILE SM0->(!EOF())        

			IF ALLTRIM(SM0->M0_CGC) == cCNPJ  
				cRet := {SM0->M0_CODIGO, SM0->M0_CODFIL}				
			ENDIF		    
		    
			SM0->(DBSKIP())
		ENDDO
	ENDIF   

	RestArea(aAreaSM0)
ENDIF

Return(cRet)  






/*/{Protheus.doc} CPXSQLXLS
Exporta para Excel a Query passada
@author Augusto Ribeiro | www.compila.com.br
@since 11/06/2014
@version 1.0
@param cCNPJ, C, cnpj
@param lX3Title, l, Retorna Titulo do SX3
@return  aRet, {lRet, cMsgErro}  
/*/
User Function CPXSQLXLS(cQuery, lX3Title)
Local aRet		:= {.F., ""}   


/*-----------------------------
	INFORMACOES DA ROTINA
	* PROPRIEDADE INTELECTUAL * 
-------------------------------*/
IF VALTYPE(cQuery) == "C"
	IF UPPER(cQuery) == "COMPILA"
		cInfoComp	:= "COMPILA [www.compila.com.br]  - Propriedade Intelectual "+CRLF+CRLF
		cInfoComp	+= "ROTINA: CPXSQLXLS"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "DESCRICAO: Exporta para Excel a Query passada."+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "PARAMETROS: cQuery, C, Query a ser exportada"+CRLF
		cInfoComp	+= CRLF
		cInfoComp	+= "RETORNO: aRet, {cCodEmp, cCodFild} "+CRLF
	
		AVISO("COMPILA - LIB",cInfoComp,{"fechar"},3,"www.compila.com.br")
	
		return(cInfoComp)
	ENDIF
ENDIF

                                                     
IF !EMPTY(cQuery)           
	cQuery	:= ALLTRIM(cQuery)
	IF UPPER(LEFT(cQuery, 6)) == "SELECT"
		aRet	:= Processa({|| SQL2XLS(cQuery, lX3Title) }, "Exportando Dados")
	ENDIF
	
//	IF !aRet[1]
//		AVISO("Query Export","Nใo hแ Dados",{"Fechar"}, 1)
//	ENDIF 
ENDIF

Return(aRet)  


/*/{Protheus.doc} SQL2XLS
Exporta para Excel a Query passada
@author Augusto Ribeiro | www.compila.com.br
@since 11/06/2014
@version 1.0
@param cCNPJ, C, cnpj
@param lX3Title, L, Retorna Titulo do SX3
@param lOpen, L, Abre Arquivo ao termino do processamento
@param cFullPath, C, Caminho completo para gravacao do arquivo
@param lLgiLga, L, Convert conteudo do LGI e LGA
@return  aRet, {lRet, cMsgErro}  
/*/
Static Function SQL2XLS(cQuery, lX3Title, lOpen, cFullPath, lLgiLga)
Local aRet		:= {.F., ""}   
Local nCount	:= 0
Local aCampos	:= {}
lOCAL nReg		:= 0
Local aHeadXLS	:= {}
Local oExcel	:= {}
Local aLinha	:= {}
Local cTemp		:= GetTempPath(.T.)
lOCAL cArqXLS	:= DTOS(DATE())+"_"+STRTRAN(TIME(),":","")+".XLS"
Local cAux		:= ""
Local nI

Local nX3TITULO := SX3->(FIELDPOS("X3_TITULO"))
Local nX3TIPO   := SX3->(FIELDPOS("X3_TIPO"))


Default lOpen 		:= .T.
Default lLgiLga		:= .T. 
Default cFullPath 	:= cTemp+cArqXLS

//nFormat	Num้rico	Codigo de formata็ใo ( 1-General,2-Number,3-Monetแrio,4-DateTime )
#DEFINE XLS_GENERAL 1
#DEFINE XLS_NUMBER 2
#DEFINE XLS_MONETARIO 3
#DEFINE XLS_DATETIME 4


If Select("CPXSQL") > 0
	CPXSQL->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "CPXSQL",.F., .T.)						


If Select("CPXSQL") > 0
	
	
	CPXSQL->(DBGoTop())	
	CPXSQL->( dbEval( {|| nCount++ } ) )	
	CPXSQL->(DBGoTop())
	
	
	IF CPXSQL->(!EOF())
		ProcRegua(nCount)
		
		/*--------------------------
			Cria Objeto Excel
		---------------------------*/
		oExcel := FWMSEXCEL():New()
		oExcel:AddworkSheet("Dados_Qry")
		oExcel:AddTable ("Dados_Qry","COMPILA.com.br | Query Export")
		
		IF lX3Title
			DBSELECTAREA("SX3")
			SX3->(DBSETORDER(2)) //| 
		ENDIF
		
	
		aHeadXLS	:= {}
		aCampos		:= {}
		nTotCpo		:= CPXSQL->(FCOUNT()) 
		
		
		/*------------------------------------------------------ Augusto Ribeiro | 06/02/2017 - 6:07:47 PM
			mONTA CABECALHO
		------------------------------------------------------------------------------------------*/
		FOR nI := 1 TO nTotCpo
			cCampo		:= CPXSQL->(FIELDNAME(nI))
			cTipoCpo	:= VALTYPE(CPXSQL->(FIELDGET(nI)) )
			aadd(aCampos, ALLTRIM(cCampo))
			
			IF lX3Title
				IF SX3->(DBSEEK(cCampo)) 
					cCampo		:= SX3->(FIELDGET(nX3TITULO))
					cTipoCpo	:= SX3->(FIELDGET(nX3TIPO))
				ENDIF
			ENDIF
				
			
			nTipoXML	:= XLS_GENERAL
			nAling		:= 1 // 1-Left,2-Center,3-Right )
			IF cTipoCpo == "N"
				nTipoXML := XLS_NUMBER
				nAling		:= 3
			ELSEIF cTipoCpo == "D"
				nTipoXML := XLS_DATETIME
			ENDIF
			
			oExcel:AddColumn("Dados_Qry","COMPILA.com.br | Query Export",cCampo,nAling, nTipoXML)
		NEXT nI
		
		
		
		nReg	:= 0
		WHILE CPXSQL->(!EOF())
			nReg++
			IncProc("Importanto registros... "+STRZERO(nReg,6)+" de "+STRZERO(nCount,6))
			
			aLinha	:= {}
			FOR nI := 1 TO nTotCpo
				IF oExcel:ATABLE[1,3,nI,4] == XLS_DATETIME
					AADD(aLinha, STOD(CPXSQL->(FIELDGET(nI))))
				ELSEIF lLgiLga .AND. (RIGHT(aCampos[nI],7) == "USERLGI" .OR. RIGHT(aCampos[nI],7) == "USERLGA")
					/*------------------------------------------------------ Augusto Ribeiro | 17/01/2018 - 3:11:56 PM
						Desembaralha UserLgi e UserLga
					------------------------------------------------------------------------------------------*/
					cUserLG	:= CPXSQL->(FIELDGET(nI))
					IF !EMPTY(cUserLG)
						//cAux	:= FWLeUserlg(aCampos[nI],1)
						//cAux	+= "-"+FWLeUserlg(aCampos[nI],2)
						cAux	:= U_CPxUserLg(aCampos[nI],1,cUserLG)
						cAux	+= "-"+U_CPxUserLg(aCampos[nI],2,cUserLG)						
						cUserLG	:= cAux
						
					ENDIF
					AADD(aLinha, cUserLG)
					
				ELSE
					AADD(aLinha, CPXSQL->(FIELDGET(nI)))
				ENDIF
			NEXT nI
			
			oExcel:AddRow("Dados_Qry","COMPILA.com.br | Query Export",ACLONE(aLinha))
		
			CPXSQL->(DBSKIP()) 
		ENDDO	
		
		
		
		
		oExcel:Activate()	
		oExcel:GetXMLFile(cFullPath)
		IF lOpen
			WinExec('explorer.exe '+cFullPath,2)
		ENDIF
		
	ELSE
		aRet[1]	:= .F.
		aRet[2]	:= "Consulta nใo retornou dados"
	ENDIF
	
	
	
	CPXSQL->(DbCloseArea())
ELSE 
	aRet[2]:= "Falha no SQL"
ENDIF


Return(aRet)






/*/{Protheus.doc} CPXSQL
Apresenta interface para exporta็ใo de excel da query passada.
@author Augusto Ribeiro | www.compila.com.br
@since 11/06/2014
@version 1.0
@param cCNPJ, C, cnpj
@param lX3Title, l, Retorna Titulo do SX3
@return  aRet, {lRet, cMsgErro}  
/*/
User Function CPXSQL()
Local oDlg,oGet1,oSBtn2,oSBtn3
Local oErro := ErrorBlock({|e| FwHelpShow("Erro na Query","Erro na Query", IIF(VALTYPE(e:Description)=="C", e:Description,"Erro no SQL inserido"),"Verifique a Query") })
Local oFLabels 		:= TFont():New("Verdana",,014,,.T.,,,,,.F.,.F.)

Private cQryDlg

Begin Sequence	

oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := "COMPILA | Query Export"
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 534
oDlg:nHeight := 350//277
oDlg:lShowHint := .F.
oDlg:lCentered := .T.

oSepLogo	:= ""
@ 5, 145 BITMAP oSepLogo RESOURCE "COMPLOGO.PNG" PIXEL SIZE 111,30 OF oDlg NOBORDER
//oSepLogo:align := CONTROL_ALIGN_LEFT
oSepLogo:lStretch := .T.

oLblSql := ""
@ 30, 5 SAY oLblSql PROMPT "Query (SQL)" SIZE 50, 012 OF oDlg FONT oFLabels COLORS RGB(32,32,32), 16777215 PIXEL

oGet1 := TMultiGet():Create(oDlg)
oGet1:cName := "oGet1"
oGet1:nLeft := 9
oGet1:nTop := 80 //30 //11
oGet1:nWidth := 504
oGet1:nHeight := 179
oGet1:lShowHint := .F.
oGet1:lReadOnly := .F.
oGet1:Align := 0
oGet1:cVariable := "cQryDlg"
oGet1:bSetGet := {|u| If(PCount()>0,cQryDlg:=u,cQryDlg) }
oGet1:lVisibleControl := .T.



oSBtn3 := SBUTTON():Create(oDlg)
oSBtn3:cName := "oSBtn3"
oSBtn3:cCaption := "Cancelar"
oSBtn3:nLeft := 382 
oSBtn3:nTop := 265 //237//207
oSBtn3:nWidth := 70
oSBtn3:nHeight := 22
oSBtn3:lShowHint := .F.
oSBtn3:lReadOnly := .F.
oSBtn3:Align := 0
oSBtn3:lVisibleControl := .T.
oSBtn3:nType := 2        
oSBtn3:bAction := {||oDlg:End()}


oSBtn2 := SBUTTON():Create(oDlg)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "Exportar"
oSBtn2:nLeft := 462
oSBtn2:nTop := 265 //237//207
oSBtn2:nWidth := 70
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 1              
//oSBtn2:bAction := {||ExecSql()}
oSBtn2:bAction := {|| SQL2XLS(cQryDlg, .T.)}

oDlg:Activate()


End Sequence

ErrorBlock(oErro)

Return Nil



/*/{Protheus.doc} cpxToJson
Converte Json em dados e retorna Json
@author Augusto Ribeiro | www.compila.com.br
@since 09/06/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function cpxToJson(cName, xValue)
Local cRet := ""
Local cValor	:= ""


cName	:= '"'+ALLTRIM(cName)+'"'

IF VALTYPE(xValue) == "C"
	cValor	:= '"'+ALLTRIM(xValue)+'"'
	
ELSEIF VALTYPE(xValue) == "N"
	cValor	:= ALLTRIM(STR(xValue))
	
ELSEIF VALTYPE(xValue) == "D"

	cValor	:= '"'+DTOC(xValue)+'"'
	
ELSEIF VALTYPE(xValue) == "L"
	
	IF xValue
		cValor	:= "true"
	ELSE
		cValor	:= "false"
	ENDIF
ENDIF


cRet := cName+":"+cValor

Return(cRet)






/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ INqueryบAutor  ณAugusto Ribeiro     บ Data ณ 10/10/2006  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Recebe String ou  Array separa por caracter "X" ou Numero  บฑฑ
ฑฑบ          ณ de Caractres para "quebra" _nCaracX                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบPARAMETROSณ _xVar     : String ou Array                                บฑฑ
ฑฑบ          ณ _cCaracX  : Caracter para Quebra                           บฑฑ
ฑฑบ          ณ _nCaracX  : Numero de caracteres para Quebra               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบRETORNO   ณ Exemplo: ('A','C','F')                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function cpxINQRY(_xVar, _cCaracX, _nCaracX)
Local _cRet	:= ""                  
Local _xVar, _cCaracX, _nCaracX, nY, _nI
Local _aString	:= {}                            
Default	_nCaracX := 0                   
		                              

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Caso dado enviado seja STRING ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF ValType(_xVar) == "C" .AND. (!EMPTY(_cCaracX) .OR. _nCaracX > 0)
                                
	    	nString	:= LEN(_xVar)		
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Utiliza Separacao por Numero de Caracteres ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			IF _nCaracX > 0
				FOR nY := 1 TO nString STEP _nCaracX
				
					ADD(_aString, SUBSTR(_xVar,nY, _nCaracX) )
				
				Next nY
				
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Utiliza Separacao por caracter especifico ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			ELSE
				_aString	:= WFTokenChar(_xVar, _cCaracX)		
			ENDIF
		ENDIF		

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Caso dado enviado seja ARRAY ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF ValType(_xVar) == "A"  
			_aString	:= _xVar
		ENDIF
		   

		IF LEN(_aString) > 0
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Monta String para utilizar com IN em querysณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			_cRet	+=  "(
			FOR _nI := 1 TO Len(_aString)
		
				IF _nI > 1
					_cRet	+= ","
				ENDIF			

				IF VALTYPE(_aString[_nI]) == "C"
					_cRet	+=  "'"+ALLTRIM(_aString[_nI])+"'"
				ELSE                
					_cRet	+=  ALLTRIM(STR(_aString[_nI]))
				ENDIF
			Next _nI
			_cRet += ") " 
			 
		ENDIF
		
Return(_cRet) 


/*/{Protheus.doc} CPxUserLg
Retorna as informa็๕es do USERLGI/USERLGA dependendo do  campo e do tipo de consulta selecionada.	
Esta consulta mant้m um cache com as informa็๕es do usuแrio para que nใo seja necessแrio efetuar novamente a pesquisa.
Possibilita apresentar as informa็๕es diretamente no browse
@author Augusto Ribeiro | www.compila.com.br
@since 17/01/2018
@version 6
@param cCampo, Nome do campo que serแ verificado. Ex: A1_USERLGI ou
@param nTipo, Tipo de consulta que serแ realizada.	[1] - pesquisa o usuแrio		[2] - pesquisa a data
@param cConteudo, Conteudo a ser traduzio evitando necessidade de posicionamento no registro.
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
USER Function CPxUserLg(cCampo, nTipo, cConteudo)
Local nPos			:= 0
Local cAux			:= ""        
Local cID			:= ""             
Local cUsrName 	:= "" 
Local cRet			:= ""                     
Local cAlias		:= ""
Local cSvAlias  	:= Alias()
Local lChgAlias 	:= .F.
Local lAliasInDic := .T. 

Default nTipo := 1


//-----------------------------------------------------
// Tratamento para tabelas temporแrias
//-----------------------------------------------------
lTemporary := cSvAlias == "TRB"
If !lTemporary	
	If ( ! AliasInDic( cSvAlias ) )
		cAlias := Subs(cCampo, 1, At('_', cCampo)- 1 )   
		
		If ( len( cAlias ) == 2 )
			cAlias := 'S' + cAlias
		EndIf
	
		lAliasInDic := ( AliasInDic( cAlias ) )
		lTemporary  :=  ! lAliasInDic
	EndIf
EndIf 

If !lTemporary
	//--------------------------------------------------
	// For็a a pesquisa do conte๚do do _USERLG na tabela
	// correspondente ao campo
	//--------------------------------------------------
	nPos := At( '->', cCampo) 
	
	If !( nPos == 0 ) 
		cCampo := Subs(cCampo, nPos + 2 )   
	EndIf 
	
	If  ( lAliasInDic )
		cAlias := Subs(cCampo, 1, At('_', cCampo)- 1 )   
		
		If ( len(cAlias) == 2 )
			cAlias := 'S'+cAlias
		EndIf
	EndIf
	
	If cAlias != cSvAlias
		DbSelectArea(cAlias)
		lChgAlias := .T.
	Endif
	
EndIf

//cAux := Embaralha(&cCampo,1)
cAux := Embaralha(cConteudo,1)
IF TYPE("__aUserLg") == "U"
	__aUserLg	:= {}
ENDIF
If !Empty(cAux)
	If Subs(cAux, 1, 2) == "#@"
		cID := Subs(cAux, 3, 6)
		If Empty(__aUserLg) .Or. Ascan(__aUserLg, {|x| x[1] == cID}) == 0                            
			PSWORDER(1)
			If ( PSWSEEK(cID) )
				cUsrName	:= Alltrim(PSWRET()[1][2])
			EndIf		
			Aadd(__aUserLg, {cID, cUsrName})	
		EndIf
		
		If nTipo == 1 // retorna o usuแrio
			nPos := Ascan(__aUserLg, {|x| x[1] == cID})
			cRet := __aUserLg[nPos][2]
		Else
			cRet := Dtoc(CTOD("01/01/96","DDMMYY") + Load2In4(Substr(cAux,16)))
		Endif                         
	Else
		If nTipo == 1 // retorna o usuแrio
			cRet := Subs(cAux,1,15)
		Else   
			cRet := Dtoc(CTOD("01/01/96","DDMMYY") + Load2In4(Substr(cAux,16)))
		Endif                         
	EndIf
EndIf                 

If lChgAlias
	If !Empty(cSvAlias)
		DbSelectArea(cSvAlias)	
	Endif
EndIf

Return cRet





/*/{Protheus.doc} CPxAuWSR
Realiza autentica็ใo do WS Rest com base na string passada. Autentication Basic	
Autentica็ใo de acordo com o cadastro de usuแrios.
@author Augusto Ribeiro | www.compila.com.br
@since 18/01/2018
@version 6
@param cAutBasic, String do Header parametro Authorization - Formato "BASIC YWRtaW46". Parametro obtido atrav้s do self:GetHeader("Authorization")
@return lRet, Autentica็ใo de acordo com o cadastro de usuแrios.
@example
(examples)
@see (links_or_references)
/*/
USER Function CPxAuWSR(cAutBasic)
Local lRet, cAux, nPosAux, cUserWSR, cPassWSR

IF VALTYPE(cAutBasic) == "C" .AND. !EMPTY(cAutBasic)
	IF UPPER(LEFT(cAutBasic,6)) == "BASIC "
		cAux	:= Decode64(SUBSTR(cAutBasic,7,LEN(cAutBasic)-6))
		nPosAux	:= at(":",cAux)
		IF nPosAux > 0
			cUserWSR	:= LEFT(cAux,nPosAux-1)
			cPassWSR	:= SUBSTR(cAux,nPosAux+1,len(cAux)-nPosAux)
			lRet		:= U_cpxVUser(cUserWSR, cPassWSR)
			IF !lRet
				CONOUT("CPxAuWSR","Usuario e senha invแlidos ["+cUserWSR+"]["+cPassWSR+"]")
			ENDIF
		ENDIF
	ENDIF
ENDIF



Return(lRet)


/*/{Protheus.doc} cpxVUser
Valida Usuแrio e Senha de acordo com o cadastro de usuแrios do Protheus
@author Augusto Ribeiro | www.compila.com.br
@since 18/01/2018
@version 6
@param cLogin, LOgin
@param cPass, Senha
@return lRet, Autentica็ใo de acordo com o cadastro de usuแrios.
@example
(examples)
@see (links_or_references)
/*/
User Function cpxVUser(cLogin, cPass)
Local lRet	:= .F.

PswOrder(2)

// Valida Usuแrio
If PswSeek(cLogin, .T.)
	// Valida Usuแrio
	If PswName(cPass)
		lRet := .T.
	Endif
Endif			

Return lRet	