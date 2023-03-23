#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDef.ch'
#include "FWBROWSE.CH"

/*/{Protheus.doc} JBTXTCAR
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 06/04/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
user function JBTXTCAR(aParam,lForca)
Local cEmpAtu	 := ""
Local cFilAtu	 := ""
//Local aRet       := {}
Local lJob	  	 := (Select("SM0")==0 .or. IsBlind())
Local aTipo      := {}
Local cDir	 	 := ""
Local cDirFisico := ""
Local oBrowse	 := nil
Local lRet	 	 := .T.
//Local lAdmin	 := .F.
Local nX 		 := 0

Default aParam := {'01','01'}
Default lForca   := .F.

Private aRotina := {}	
Private cCadastro 	:= "Log de relatorio do site cartao de credito"

If lJob
	cEmpAtu	 := aParam[ 01 ]
	cFilAtu	 := aParam[ 02 ]

	RpcClearEnv()	
	RPCSetType(3)	
	RpcSetEnv( cEmpAtu,cFilAtu,"","","FIN" )
Endif

cDir	   := Lower(alltrim(GETMV("MV_P_CARD",.F.,"\impcard")))
cDirFisico := Alltrim(GetSrvProfString("ROOTPATH",""))+cDir

Aadd(aTipo,{"1=Wordpay",{}})
Aadd(aTipo[Len(aTipo),2],cDir+Lower(alltrim(GetMv("MV_P_WPST",.F.,"\impword")))+"\"+cFilAnt+"\")
Aadd(aTipo[Len(aTipo),2],GetMv("MV_P_WFTP",.F.,""))

Aadd(aTipo,{"2=GetNet",{}})
Aadd(aTipo[Len(aTipo),2],cDir+Lower(alltrim(GetMv("MV_P_GPST",.F.,"\impgetn")))+"\"+cFilAnt+"\")
Aadd(aTipo[Len(aTipo),2],GetMv("MV_P_GFTP",.F.,""))

If lJob .OR. lForca
	For nX := 1 To Len(aTipo)
		If !ExistDir(aTipo[nX,2,1])
			Loop
		EndIf
		//PROCSFTP(Left(aTipo[nx,1],1),aTipo[nX,2,1],aTipo[nX,2,2])
		JBTXTImp(Left(aTipo[nx,1],1),aTipo[nX,2,1])
	Next
Else
	oBrowse	:= FWmBrowse():New()
	aRotina := MenuDef(1)
	oBrowse:SetAlias('SZ4')
	oBrowse:SetDescription(cCadastro) 
	oBrowse:AddLegend( "SZ4->Z4_INTEG == '1' ", "RED"   ,"Nao Conciliado")
	oBrowse:AddLegend( "SZ4->Z4_INTEG == '2' ", "GREEN" ,"Conciliado Normal")
	oBrowse:AddLegend( "SZ4->Z4_INTEG == '3' ", "YELLOW" ,"Baixado anteriormente")
	oBrowse:AddLegend( "SZ4->Z4_INTEG == '4' ", "BLACK" ,"Divergente")	
	oBrowse:AddLegend( "SZ4->Z4_INTEG == '5' ", "BLUE" ,"Conciliado com Baixa")	
	oBrowse:AddLegend( "SZ4->Z4_INTEG == '6' ", "BROWN" ,"Outros registros")	
	oBrowse:SetCacheView(.F.)// Não realiza o cache da viewdef
	oBrowse:Activate()	
EndIf

Return

/*/{Protheus.doc} JBTXTImp
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 06/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cArquivo, characters, descricao
@type function
/*/
Static Function JBTXTImp(cTipo, cPasta )
Local lRet		:= .T.
Local nX        := 0
Local nY        := 0
Local nZ        := 0
Local nI        := 0
//Local nPosFil

//Local aStruct	:=	{}
Local aArea		:= GetArea()
Local cLinha 	:= ""
Local oTemp 	:= nil
Local aCpoObrig := {}
Local nNumLin	:= 0        
Local nHandle
//Local nCpo
Local nAt
Local cToken
Local nMax	    := 2000
//Local oMultiGet := nil
//Local oDlgErro  := nil
//Local oBtn1		:= nil
Local xVal		:= nil
//Local lReg		:= .F.
Local afiles    := {}
Local aSizes    := {}
Local lJob	  	:= (Select("SM0")==0 .or. IsBlind())
Local lTela		:= .F.
Local _aDadostxt:= {}

Private aErros	:= {}  //esta variavel tem que ser private pq .....
Private cReg	:= ""
Private cRegOut := ""

If cTipo=='1' //estrutura do WorldPay
	cReg := '02'
	cRegOut := '03/04'
					//NOMECAMPO,POSICAO INI,POSICAO,FINAL,TIPO,TAMANHO,CAMPO DE GRAVACAO
	aAdd( aCpoObrig,{"Tipo de Registro"		     ,CHR(9),2 ,'C',"Z4_REG"})
	aAdd( aCpoObrig,{"Estabelecimento" 		     ,CHR(9),10,'C',"Z4_ESTAB"})
	aAdd( aCpoObrig,{"Número de Transação"	     ,CHR(9),11,'C',"Z4_NSU"})
	aAdd( aCpoObrig,{"Número de Referência"	     ,CHR(9),64,'C',"Z4_ID"})
	aAdd( aCpoObrig,{"Código de Autorização"     ,CHR(9),6 ,'C',""})
	aAdd( aCpoObrig,{"Data da Transação"	     ,CHR(9),8 ,'D',"Z4_DTTRANS"})
	aAdd( aCpoObrig,{"Hora da Transação"	     ,CHR(9),6 ,'C',"Z4_HRTRANS"})
	aAdd( aCpoObrig,{"Número do terminal"	     ,CHR(9),8 ,'C',""})	
	aAdd( aCpoObrig,{"Método de Captura"	     ,CHR(9),2 ,'C',"Z4_FORCAP"})
	aAdd( aCpoObrig,{"Data de Debito"		     ,CHR(9),8 ,'D',"Z4_DTPAGTO"})
	aAdd( aCpoObrig,{"Bandeira"				     ,CHR(9),10,'C',"Z4_BANDEIR"})
	aAdd( aCpoObrig,{"Tipo de Cartão"	 	     ,CHR(9),2 ,'C',"Z4_TIPOPG"})
	aAdd( aCpoObrig,{"Código de Produto"	     ,CHR(9),4 ,'C',""})
	aAdd( aCpoObrig,{"Numero do cartão"		     ,CHR(9),19,'C',"Z4_NUMCAR"})
	aAdd( aCpoObrig,{"Domestico/Internacional"   ,CHR(9),3 ,'C',"Z4_NACINT"})
	aAdd( aCpoObrig,{"Moeda"				  	 ,CHR(9),3 ,'C',"Z4_MOEDA"})
	aAdd( aCpoObrig,{"Valor Compra ou Parcela"	 ,CHR(9),12,'N',"Z4_VLPARCE"})
	aAdd( aCpoObrig,{"Valor Total da Venda"   	 ,CHR(9),12,'N',"Z4_VALOR"})
	aAdd( aCpoObrig,{"Parcela"	  			  	 ,CHR(9),2 ,'C',""})
	aAdd( aCpoObrig,{"Total de Parcelas"      	 ,CHR(9),2 ,'N',"Z4_QTDPARC"})
	aAdd( aCpoObrig,{"Valor Taxa de Comissão" 	 ,CHR(9),12,'N',"Z4_VLTAXA"})
	aAdd( aCpoObrig,{"Valor de Intercâmbio"   	 ,CHR(9),12,'N',""})
	aAdd( aCpoObrig,{"Valor Custo de Bandeiras"  ,CHR(9),12,'N',""})
	aAdd( aCpoObrig,{"Valor Custo de Adquirencia",CHR(9),12,'N',""})
	aAdd( aCpoObrig,{"Transação Antecipada"      ,CHR(9),2 ,'N',""})
	aAdd( aCpoObrig,{"Valor Taxa de Antecipação" ,CHR(9),12,'N',""})
	aAdd( aCpoObrig,{"Valor Liquido da Venda"	 ,CHR(9),12,'N',"Z4_VLIQUID"})
	aAdd( aCpoObrig,{"Código de Rejeição"        ,CHR(9),3 ,'C',"Z4_CDREJEC"})
	aAdd( aCpoObrig,{"Descrição de Rejeição"     ,CHR(9),3 ,'C',"Z4_DEREJEC"})
	aAdd( aCpoObrig,{"Número de passagem"	     ,CHR(9),14,'N',""})
	
ElseIf cTipo=='2' //estrutura do GetNet
	cReg := '2'
					//NOMECAMPO,POSICAO INI,POSICAO,FINAL,TIPO,TAMANHO,CAMPO DE GRAVACAO
	aAdd( aCpoObrig,{"Tipo de Registro"		     ,1  ,1 ,'C',"Z4_REG"})
	aAdd( aCpoObrig,{"Estabelecimento" 		     ,2  ,15,'C',"Z4_ESTAB"})
	aAdd( aCpoObrig,{"Número de Referência"	     ,17 ,9 ,'C',"Z4_ID"})
	aAdd( aCpoObrig,{"Número de Transação"	     ,26 ,12,'C',"Z4_NSU"})
	aAdd( aCpoObrig,{"Data da Transação"	     ,38 ,8 ,'D',"Z4_DTTRANS"})
	aAdd( aCpoObrig,{"Hora da Transação"	     ,46 ,6 ,'C',"Z4_HRTRANS"})
	aAdd( aCpoObrig,{"Numero do cartão"		     ,52 ,19,'C',"Z4_NUMCAR"})
	aAdd( aCpoObrig,{"Valor da Transação"   	 ,71 ,12,'N',"Z4_VALOR"})
	aAdd( aCpoObrig,{"Valor do Saque"            ,83 ,12,'N',""})
	aAdd( aCpoObrig,{"Valor Taxa de Embarque" 	 ,95 ,12,'N',"Z4_VLTAXA"})
	aAdd( aCpoObrig,{"Numero de Parcelas"      	 ,107,2 ,'N',"Z4_QTDPARC"})
	aAdd( aCpoObrig,{"Parcela"	  			  	 ,109,2 ,'C',""})
	aAdd( aCpoObrig,{"Valor da Parcela"	 		 ,111,12,'N',"Z4_VLPARCE"})
	aAdd( aCpoObrig,{"Data de Pagamento"		 ,123,8 ,'D',"Z4_DTPAGTO"})
	aAdd( aCpoObrig,{"Código de Autorizacao"	 ,131,10,'C',""})
	aAdd( aCpoObrig,{"Forma de Captura"	         ,141,3 ,'C',"Z4_FORCAP"})
	aAdd( aCpoObrig,{"Status de Transação"	  	 ,144,1 ,'C',""})
	aAdd( aCpoObrig,{"Codigo estabel. comercial" ,145,15,'C',""})
	aAdd( aCpoObrig,{"Codigo do terminal"        ,160,8 ,'C',""})
	aAdd( aCpoObrig,{"Moeda"				  	 ,168,3 ,'C',"Z4_MOEDA"})
	aAdd( aCpoObrig,{"Origem Emissor do Cartao"  ,171,1 ,'C',"Z4_NACINT"})
	aAdd( aCpoObrig,{"Sinal da transaçao"        ,172,1 ,'C',""})
	aAdd( aCpoObrig,{"Carteira Digital"          ,173,3 ,'C',""})
	aAdd( aCpoObrig,{"Reservado para uso futuro" ,176,224,'C',""})	
EndIf


ADir(cPasta+'\'+"*.txt",afiles, aSizes)

For nI := 1 to len(afiles)

	cArquivo := cPasta+afiles[nI]
	lRet       := .T.   
	//_aCpos_txt := {}
	_aDadostxt := {}
	aErros     := {}
		
	If ((nHandle := FT_FUse(AllTrim(cArquivo)))== -1)  //abertura do arquivo texto
		aAdd(aErros,"Erro de Arquivo: "+AllTrim(cArquivo)+" Não é possivel abrir arquivo")   
		lRet := .F.
	EndIf
	
	If lRet
		nNumLin := FT_FLASTREC()
		If nNumLin < 1
			aAdd(aErros,"Erro de Arquivo: Arquivo Vazio") //
			lRet := .F.
		EndIf
		If nNumLin > nMax
			aAdd(aErros,"Erro de Arquivo: Tamanho máximo é de " + cValToChar(nMax) + " linhas." )  
			lRet := .F.
		EndIf
	EndIf
	
	If lRet
		nPosReg := aScan( aCpoObrig, {|x| Alltrim(x[5]) == "Z4_REG" })
		
		FT_FGOTOP() 
		Do While !FT_FEOF()
		
			clinha 	:= ft_freadln()	
			If (valtype(aCpoObrig[nPosReg,2])=="C") .AND. (aCpoObrig[nPosReg,2] == CHR(9))
				nAt	:=	AT(CHR(9),cLinha)
				If nAt > 0
					cToken	:=	Substr(cLinha,1,nAt-1)
				Else	
					cToken	:=	Alltrim(cLinha)
				EndIf		
			Else
				cToken := Subs(cLinha,aCpoObrig[nPosReg,2],aCpoObrig[nPosReg,3])		
			EndIf
			If (cToken != cReg) .AND. !(cToken $ cRegOut) 
				FT_FSKIP()		
				loop
			EndIf
			aadd(_aDadostxt,array(len(aCpoObrig)))
	
			nLin := Len(_aDadostxt)
			For nX:=1 To Len(aCpoObrig)					
				If (valtype(aCpoObrig[nX,2])=="C") .AND. (aCpoObrig[nX,2] == CHR(9))
					nAt	:=	AT(CHR(9),cLinha)
					If nAt > 0
						cToken	:=	Substr(cLinha,1,nAt-1)
					Else	
						cToken	:=	Alltrim(cLinha)
					EndIf
					xVal := cToken
					If aCpoObrig[nX,4]=="N"
						cToken := Subs(cToken,1,Len(cToken)-2)+"."+Right(cToken,2)
						xVal := val(cToken)
					ElseIf aCpoObrig[nX,4]=="D" 
						xVal := CTOD(SUBS(cToken,1,2)+"/"+SUBS(cToken,3,2)+"/"+SUBS(cToken,5))
					EndIf
					_aDadostxt[nLin][nX] := xVal
					cLinha	:=	Substr(cLinha,nAt+1)
				Else
					cToken := Subs(cLinha,aCpoObrig[nX,2],aCpoObrig[nX,3])
					xVal := cToken
					If aCpoObrig[nX,4]=="N"
						cToken := Subs(cToken,1,Len(cToken)-2)+"."+Right(cToken,2)
						xVal := val(cToken)
					ElseIf aCpoObrig[nX,4]=="D" 
						xVal := CTOD(SUBS(cToken,1,2)+"/"+SUBS(cToken,3,2)+"/"+SUBS(cToken,5))
					EndIf
					_aDadostxt[nLin][nX] := xVal
				EndIf		
			Next
			
			FT_FSKIP()		
		EndDo
	EndIf
	FT_FUSE()
	
	If lRet
		nPosID := aScan( aCpoObrig, {|x| Alltrim(x[5]) == "Z4_ID" })
		nPosReg := aScan( aCpoObrig, {|x| Alltrim(x[5]) == "Z4_REG" })
		// valida linha no txt
		For nX := 1 To Len( _aDadostxt )
			If (_aDadostxt[nX,nPosReg] != cReg) .AND. !(_aDadostxt[nX,nPosReg] $ cRegOut) 
				loop
			EndIf
		
			lRet := ValidLitxt( nX,_aDadostxt[nX],aCpoObrig,nPosID,cTipo,nPosReg)
			If !lRet
				If !lJob
					If MsgYesNo("Erro no arquivo importado no arquivo: "+cArquivo+Chr(13)+Chr(10)+" Continua Importacao ?")
						lRet := .T.
					End
				EndIF
				aAdd(aErros,"Erro no arquivo importado no arquivo: "+cArquivo)  
				Exit
			EndIf
		Next nX
	EndIf
	
	If lRet
		If cTipo=='1'
			acumulaID(@_aDadostxt,aCpoObrig)
		EndIf
		
		DbSelectArea("SZ4")
		cTRB:= fCreateTemp(@oTemp,_aDadostxt,aCpoObrig,cTipo,lTela)
		JBTXTGRAVA(cTRB,.F.)
		(cTRB)->(DbCloseArea())
		oTemp:Delete() 
		DbSelectArea("SZ4")

		If __Copyfile(cArquivo,cPasta+"\processado\"+afiles[nI])
			fErase(cArquivo) //-- Apago arquivo na Pasta RAIZ
		EndIf	

	EndIf
	
	For nZ:=1 To Len(aErros)
		Conout(aErros[nZ])
	Next
Next

RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} MontaTela
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 15/04/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function MontaTela()
Local aCampos 	:= {}
Local cDescricao:= "Registros do Site"
Local cTRB  	:= ""
Local oTemp 	:= nil
Local aClRot	:= {}
Local oMark 

//Local lMarca 	:= .F.
//Local bAllMark  :={|| .T.}
Local cAliasSZ4 := GetNextAlias()
Local lTela     := .T.
Local bCorLeg   := {|x| If(x=='1',"BR_VERMELHO",If(x=='2',"BR_VERDE",If(x=='3',"BR_AMARELO",If(x=='4',"BR_PRETO","BR_AZUL")))) }

Private bRun := nil
//Private cMarca  := GetMark()

SaveInter()
aRotina := MenuDef(2)

cTRB:= fCreateTemp(@oTemp,{},{},"",lTela)
gercp(@aCampos)

bRun := {|X,Y| JBTXAJUSTA(cTRB), JBTXTGRAVA(cTRB,.T.), oMark:oBrowse:Refresh(.T.) }

oMark := FWMarkBrowse():New()  		// Instanciamento do classe	
oMark:SetAlias(cTRB)   	   		// Definição da tabela a ser utilizada
oMark:SetFields(aCampos)	
oMark:SetDescription(cDescricao)	// Define a titulo do browse de marcacao	

// Define as legendas  
oMark:AddStatusColumns( {|| eval(bCorLeg,(cTRB)->T_INTEG) },{|| "" } )
oMark:obrowse:aColumns[1]:SetTitle("Int") 

oMark:AddButton("Conciliar e Baixar",   {|| IF(MSGYESNO("confirma baixa dos titulos marcados ?"),FwMsgRun(,{|| Eval(bRun,cTRB)},,"Gravando..."),"") },,1)
oMark:AddButton("Legenda",  {|| JBTXTLEGEND()} ,,1)

oMark:SetFieldMark( 'T_OK' )		// Define o campo que sera utilizado para a marcação 
oMark:Activate() // Ativacao da classe

(cTRB)->(DbCloseArea())
oTemp:Delete() 

aRotina := aClone(aClRot)
RESTINTER()

Return

Static Function JBTXAJUSTA(cTRB)

Local cQRY		  := GetNextAlias()
Local cAliaSA6    := GetNextAlias()
Local cId 		  := ""
Local aBaixa 	  := {}
Local cTipo  	  := "1"
Local cBanco	  := ""
Local cAgencia	  := ""
Local cConta	  := ""	
Local nJuros      := 0 
Local nDesco	  := 0
Local nX		  := 0
Local cMsgErro	  := ""

Begin Transaction
	(cTRB)->(DbGotop())
	While (cTRB)->(!Eof())
		If Empty((cTRB)->T_OK)
			(cTRB)->(DbSkip())
			Loop
		EndIf
		
		cId 	:= Alltrim((cTRB)->T_ID)
		cTipo 	:= Alltrim((cTRB)->T_TOPCARD)
		cBanco	:= ""
		cAgencia:= ""
		cConta	:= ""
		cMsgErro:= ""
		
		BeginSql Alias cAliaSA6
			SELECT TOP 1 A6_COD,A6_AGENCIA,A6_NUMCON,A6_XOPECAR 
				From %table:SA6% SA6
				Where SA6.A6_FILIAL = %xfilial:SA6% AND
					SA6.A6_XOPECAR = %exp:cTipo% AND
					SA6.A6_BLOCKED <> '1' AND
					SA6.%notdel%
		EndSql
		
		If (cAliaSA6)->(!Eof())
			cBanco	:= (cAliaSA6)->A6_COD
			cAgencia:= (cAliaSA6)->A6_AGENCIA
			cConta	:= (cAliaSA6)->A6_NUMCON
		EndIf
		(cAliaSA6)->(DbCloseArea())
		DbSelectArea(cTRB)
		
		Beginsql alias cQRY
			COLUMN E1_SALDO    AS NUMERIC(12,2)
			COLUMN E1_VALOR    AS NUMERIC(12,2)
			COLUMN VLIQUI      AS NUMERIC(12,2)
			COLUMN E1_BAIXA    AS DATE
			COLUMN E1_DECRESC  AS NUMERIC(12,2)
			SELECT SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,SE1.E1_DECRESC,
				SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_SALDO,SE1.E1_VALOR,SE1.E1_BAIXA,		
				SE1.E1_NATUREZ,SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_VALOR,SE1.E1_VLCRUZ,
				SE1.E1_EMISSAO,SE1.E1_P_DTRAX
				FROM %table:SE1% SE1
				WHERE SE1.E1_FILIAL = %xFilial:SE1% AND 
					(SE1.E1_SALDO > 0 OR SE1.E1_BAIXA = ' ') AND
					SE1.E1_P_DTRAX = %exp:cId% AND
					SE1.%notdel%
		Endsql
		If (cQRY)->(!Eof())

			Pergunte("FIN070",.F.)
			For nx := 1 to 30
				If nx==1
					&("mv_par"+StrZero(nx,2)) := 2
				ElseIf nx==4
					&("mv_par"+StrZero(nx,2)) := 2 
				EndIf	
			Next nx	
			
			nJuros := 0
			nDesco := 0
			nValor := (cTRB)->T_VLIQUID

			
			//Incluída regra para calcular a diferença entre a taxa gerada no título ((cQRY)->E1_DECRESC) e a taxa gerada no DATATRAX ((cTRB)->T_VLTAXA)
			    If (cQRY)->E1_DECRESC > (cTRB)->T_VLTAXA 
			    nSomDif := ((cQRY)->E1_DECRESC - (cTRB)->T_VLTAXA )
			Elseif (cQRY)->E1_DECRESC < (cTCOMRB)->T_VLTAXA 
			    nSomDif := ((cTRB)->T_VLTAXA - (cQRY)->E1_DECRESC) 
		    Else 
			    nSomDif := 0
			EndIf
		    
			
			If (cTRB)->T_VDIFERE > 0
				nJuros :=  ROUND(((cTRB)->T_VDIFERE + nSomDif),2)
                nDesco :=  ROUND((cTRB)->T_VLTAXA,2) 
			Else 
				nDesco := ROUND(((cTRB)->T_VLTAXA) +((((cTRB)->T_VDIFERE)*-1) + nSomDif),2)
			EndIf
			aBaixa 	:= {}
			Aadd(aBaixa,{"E1_PREFIXO"	,(cQRY)->E1_PREFIXO	,Nil})
			Aadd(aBaixa,{"E1_NUM"		,(cQRY)->E1_NUM  	,Nil})
			Aadd(aBaixa,{"E1_PARCELA"	,(cQRY)->E1_PARCELA	,Nil})
			Aadd(aBaixa,{"E1_TIPO"	   	,(cQRY)->E1_TIPO   	,Nil})
			Aadd(aBaixa,{"E1_CLIENTE"	,(cQRY)->E1_CLIENTE	,Nil})
			Aadd(aBaixa,{"E1_LOJA"    	,(cQRY)->E1_LOJA   	,Nil})
			Aadd(aBaixa,{"E1_EMISSAO"   ,(cQRY)->E1_EMISSAO	,Nil})		
			Aadd(aBaixa,{"E1_NATUREZ"   ,(cQRY)->E1_NATUREZ ,Nil})
			Aadd(aBaixa,{"E1_P_DTRAX"   ,(cQRY)->E1_P_DTRAX ,Nil})
			Aadd(aBaixa,{"E1_CLIENTE"   ,(cQRY)->E1_CLIENTE ,Nil})
			Aadd(aBaixa,{"E1_LOJA"    	,(cQRY)->E1_LOJA   	,Nil})
			Aadd(aBaixa,{"E1_VALOR"    	,(cQRY)->E1_VALOR   ,Nil})
			Aadd(aBaixa,{"E1_VLCRUZ"    ,(cQRY)->E1_VLCRUZ  ,Nil})
			Aadd(aBaixa,{"AUTMOTBX"	    ,"NOR"             	,Nil})
			Aadd(aBaixa,{"AUTBANCO"  	,cBanco		   		,Nil})
			Aadd(aBaixa,{"AUTAGENCIA"   ,cAgencia		   	,Nil})
			Aadd(aBaixa,{"AUTCONTA"  	,cConta 		   	,Nil})
			Aadd(aBaixa,{"AUTDTBAIXA"	,ddatabase		   	,Nil})
			Aadd(aBaixa,{"AUTDTCREDITO" ,ddatabase          ,Nil})
			Aadd(aBaixa,{"AUTHIST"	    ,'Datatrax '+cId    ,Nil})
			Aadd(aBaixa,{"AUTDECRESC"  	,(cQRY)->E1_DECRESC ,Nil})
			//Aadd(aBaixa,{"AUTDECRESC" ,(cTRB)->T_VLTAXA   ,Nil})
			Aadd(aBaixa,{"AUTDESCONT" 	,nDesco				,Nil})
			Aadd(aBaixa,{"AUTMULTA"     ,nJuros				,Nil})
			Aadd(aBaixa,{"AUTVALREC"	,nValor         	,Nil})
					  		
			lMsErroAuto := .F.			  
			Begin Transaction			  
				MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 
		    End Transaction
		   	IF lMsErroAuto
		   		cTemSE1 := "4"
				aErros := GetAutoGRLog()
			    DisarmTransaction()
		    	For nX:=1 To Len(aErros)
					cMsgErro += aErros[nX]
				Next
			Else
				cTemSE1 := '5'
				cMsgErro := "baixa Normal com Acertos!"
			EndIF
	
			RecLock(cTRB,.F.)
			(cTRB)->T_INTEG		:= cTemSE1
			(cTRB)->T_LOGMSG	:= cMsgErro	
			MsUnlock()
		EndIF
		(cQRY)->(DbCloseArea())
		DbSelectArea(cTRB)
		(cTRB)->(DbSkip())
	EndDo
End Transaction

Return	
	
/*/{Protheus.doc} ValidLitxt
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 13/04/2019
@version 1.0
@return ${return}, ${return_description}
@param nLinha, numeric, descricao
@param aDados, array, descricao
@param aCpos, array, descricao
@param nPosID, numeric, descricao
@param aErros, array, descricao
@type function
/*/
Static Function ValidLitxt(nLinha,aDados,aCpos,nPosID,cTipo,nPosReg)
Local lRet := .T.
Local nX   := 1
Local nY   := 1
Local cAliasSZ4 := getnextAlias()
Local cId  := ""

If Len(aDados) > Len(aCpos) 
	lRet := .F.	
EndIf

If lRet
	If nPosID > 0 .And. !Empty( aDados[nPosID] )
		cId := aDados[nPosID]
		If cTipo=='1'
			if Len(cId)==11
				cId := Subs(cId,2,Len(cId)-3)
			endif
		EndIf
						
		BeginSQL alias cAliasSZ4 
			SELECT 1 FROM %table:SZ4% SZ4
				WHERE SZ4.Z4_FILIAL = %xfilial:SZ4% AND
					SZ4.Z4_ID = %exp:cId% AND
					SZ4.Z4_REG = %exp:cReg% AND 
					SZ4.%notdel%
		EndSql
		If (cAliasSZ4)->(!EOF())
			lRet := .F.
		EndIf
		(cAliasSZ4)->(DbCloseArea())
		DbSelectArea("SZ4")
	EndIf
EndIf

Return(lRet)


/*/{Protheus.doc} acumulaID
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 13/04/2019
@version 1.0
@return ${return}, ${return_description}
@param _aDadostxt, , descricao
@param aCpoObrig, array, descricao
@type function
/*/
static Function acumulaID(_aDadostxt,aCpoObrig)

Local aDadAux := {}
Local cId	  := ""
Local nI      := 0
LOcal nPos	  := 0
Local nPosID  := aScan( aCpoObrig, {|x| Alltrim(x[5]) == "Z4_ID" })
Local nPosVLQ := aScan( aCpoObrig, {|x| Alltrim(x[5]) == "Z4_VLIQUID" })
Local nPosVLT := aScan( aCpoObrig, {|x| Alltrim(x[5]) == "Z4_VLTAXA" })
Local nPosVLO := aScan( aCpoObrig, {|x| Alltrim(x[5]) == "Z4_VALOR" })
Local nPosReg := aScan( aCpoObrig, {|x| Alltrim(x[5]) == "Z4_REG" })
	
For nI:=1 TO Len(_aDadostxt)
	If (_aDadostxt[nI,nPosReg] == cReg)
	
		cId := _aDadostxt[nI,nPosID]
		cId := Subs(cId,2,Len(cId)-3)
		
		If (nPos := ascan(aDadAux,{|x| y:=Subs(x[nPosID],2,Len(x[nPosID])-3), y==cId })) == 0
			aadd(aDadAux,_aDadostxt[nI])
		Else
			aDadAux[nPos,nPosVLQ] += _aDadostxt[nI,nPosVLQ]		
			aDadAux[nPos,nPosVLT] += _aDadostxt[nI,nPosVLT]		
			aDadAux[nPos,nPosVLO] += _aDadostxt[nI,nPosVLO]		
		EndIf
	EndIf
Next

For nI:=1 TO Len(_aDadostxt)
	If (_aDadostxt[nI,nPosReg] $ cRegOut)
		aadd(aDadAux,_aDadostxt[nI])
	EndIf	
Next

_aDadostxt := aClone(aDadAux)

Return

/*/{Protheus.doc} JBTXTGRAVA
//TODO Descrição auto-gerada.
@author Telso Carneiro
@since 13/04/2019
@version 1.0
@return ${return}, ${return_description}
@param cTRB, characters, descricao
@type function
/*/
Static Function JBTXTGRAVA(cTRB,lRepro)

Begin Transaction
	(cTRB)->(DbGotop())
	While (cTRB)->(!Eof())
		If lRepro
			If !Empty((cTRB)->T_OK)		
				SZ4->(DbGOTO((cTRB)->T_RECSZ4))	    
				If (SZ4->Z4_ID==(cTRB)->T_ID)
					Reclock("SZ4",.F.)
					SZ4->Z4_INTEG	:= (cTRB)->T_INTEG					
					SZ4->Z4_DATAIMP := (cTRB)->T_DATAIMP  	
					SZ4->Z4_HORAIMP := (cTRB)->T_HORAIMP
					SZ4->Z4_LOGMSG  := SZ4->Z4_LOGMSG+" BAIXADO PELO BOTAO ERROR "+DTOC(dDatabase)+" "+TIME()	
					SZ4->Z4_CODUSER := RetCodUsr()
				EndIf
			EndIf
		Else
			Reclock("SZ4",.T.)
			SZ4->Z4_FILIAL 	:= xfilial("SZ4")
			SZ4->Z4_INTEG	:= (cTRB)->T_INTEG						
			SZ4->Z4_TOPCARD := (cTRB)->T_TOPCARD 
			SZ4->Z4_REG		:= (cTRB)->T_REG
			SZ4->Z4_ESTAB   := (cTRB)->T_ESTAB			
			SZ4->Z4_NSU    	:= (cTRB)->T_NSU
			SZ4->Z4_ID 		:= (cTRB)->T_ID	    
			SZ4->Z4_DTTRANS := (cTRB)->T_DTTRANS
			SZ4->Z4_HRTRANS := (cTRB)->T_HRTRANS   
			SZ4->Z4_FORCAP  := (cTRB)->T_FORCAP 	
			SZ4->Z4_DTPAGTO := (cTRB)->T_DTPAGTO  	 
			SZ4->Z4_BANDEIR := (cTRB)->T_BANDEIR   
			SZ4->Z4_TIPOPG  := (cTRB)->T_TIPOPG	
			SZ4->Z4_NUMCAR	:= (cTRB)->T_NUMCAR	
			SZ4->Z4_NACINT  := (cTRB)->T_NACINT	
			SZ4->Z4_MOEDA   := (cTRB)->T_MOEDA	    
			SZ4->Z4_VALOR   := (cTRB)->T_VALOR   	
			SZ4->Z4_CDREJEC := (cTRB)->T_CDREJEC		
			SZ4->Z4_VLTAXA	:= (cTRB)->T_VLTAXA    
			SZ4->Z4_QTDPARC := (cTRB)->T_QTDPARC	
			SZ4->Z4_VLPARCE := (cTRB)->T_VLPARCE
			SZ4->Z4_VLIQUID := (cTRB)->T_VLIQUID
			SZ4->Z4_VDIFERE	:= (cTRB)->T_VDIFERE	   
			SZ4->Z4_LOGMSG  := (cTRB)->T_LOGMSG	
			SZ4->Z4_DATAIMP := (cTRB)->T_DATAIMP  	
			SZ4->Z4_HORAIMP := (cTRB)->T_HORAIMP
			SZ4->Z4_CODUSER := RetCodUsr()
		EndIf
		MsUnlock()
		(cTRB)->(DbSkip())
	EndDo
End Transaction

Return

Static Function Gercp(aCampos)
	aAdd( aCampos, { 'TpOpCart'		,'T_TOPCARD' ,"C",  PesqPict("SZ4","Z4_TOPCARD"),	1, TAMSX3("Z4_TOPCARD")[1], TAMSX3("Z4_TOPCARD")[2],,,,,,,,,"1=Sim, 2=Não"} )
	aAdd( aCampos, { 'Reg'			,'T_REG'     ,"C",  PesqPict("SZ4","Z4_REG")   ,	1, TAMSX3("Z4_REG")[1]   ,	TAMSX3("Z4_REG")[2] } )
	//aAdd( aCampos, { 'Estabel.'		,'T_ESTAB'   ,"C",  PesqPict("SZ4","Z4_ESTAB")   ,	1, TAMSX3("Z4_ESTAB")[1] ,	TAMSX3("Z4_ESTAB")[2] } )
	//aAdd( aCampos, { 'NSU'			,'T_NSU'     ,"C",  PesqPict("SZ4","Z4_NSU")   ,	1, TAMSX3("Z4_NSU")[1]   ,	TAMSX3("Z4_NSU")[2] } )
	aAdd( aCampos, { 'Núm.Ref.'	  	,'T_ID'      ,"C",	PesqPict("SZ4","Z4_ID")    ,	1, TAMSX3("Z4_ID")[1]    , 	TAMSX3("Z4_ID")[2] 	} )
	aAdd( aCampos, { 'Dt.Trans'     ,'T_DTTRANS' ,"D",	PesqPict("SZ4","Z4_DTTRANS"),	1, TAMSX3("Z4_DTTRANS")[1], TAMSX3("Z4_DTTRANS")[2]	} )
	aAdd( aCampos, { 'Hr.Trans'	    ,'T_HRTRANS' ,"C",	PesqPict("SZ4","Z4_HRTRANS"), 	1, TAMSX3("Z4_HRTRANS")[1], TAMSX3("Z4_HRTRANS")[2]	} )
	//aAdd( aCampos, { 'Mét.Capt'	  	,'T_FORCAP'  ,"C",	PesqPict("SZ4","Z4_FORCAP"), 	1, TAMSX3("Z4_FORCAP")[1],  TAMSX3("Z4_FORCAP")[2]	} )
	aAdd( aCampos, { 'Dt.Debit'     ,'T_DTPAGTO' ,"D",	PesqPict("SZ4","Z4_DTPAGTO"), 	1, TAMSX3("Z4_DTPAGTO")[1], TAMSX3("Z4_DTPAGTO")[2]	} )
	aAdd( aCampos, { 'Bandeira'  	,'T_BANDEIR' ,"C",	PesqPict("SZ4","Z4_BANDEIR"), 	1, TAMSX3("Z4_BANDEIR")[1], TAMSX3("Z4_BANDEIR")[2]	} )
	aAdd( aCampos, { 'Tp.Cartão'    ,'T_TIPOPG'  ,"C",	PesqPict("SZ4","Z4_TIPOPG"), 	1, TAMSX3("Z4_TIPOPG")[1],  TAMSX3("Z4_TIPOPG")[2]	} )
	aAdd( aCampos, { 'Nu.cartão'    ,'T_NUMCAR'  ,"C",	PesqPict("SZ4","Z4_NUMCAR"), 	1, TAMSX3("Z4_NUMCAR")[1], 	TAMSX3("Z4_NUMCAR")[2]	} )
	//aAdd( aCampos, { 'Dom/Int'		,'T_NACINT'  ,"C",	PesqPict("SZ4","Z4_NACINT"), 	1, TAMSX3("Z4_NACINT")[1],  TAMSX3("Z4_NACINT")[2]	} )
	//aAdd( aCampos, { 'Moeda'     	,'T_MOEDA'   ,"C",	PesqPict("SZ4","Z4_MOEDA"), 	1, TAMSX3("Z4_MOEDA")[1], 	TAMSX3("Z4_MOEDA")[2]	} )
	aAdd( aCampos, { 'VTot.Vend'   	,'T_VALOR'   ,"N",	PesqPict("SZ4","Z4_VALOR"), 	2, TAMSX3("Z4_VALOR")[1],   TAMSX3("Z4_VALOR")[2]	} )
	aAdd( aCampos, { 'Cd.Rejei'     ,'T_CDREJEC' ,"C",	PesqPict("SZ4","Z4_CDREJEC"), 	1, TAMSX3("Z4_CDREJEC")[1], TAMSX3("Z4_CDREJEC")[2]	} )
	aAdd( aCampos, { 'De.Rejei'     ,'T_DEREJEC' ,"C",	PesqPict("SZ4","Z4_DEREJEC"), 	1, TAMSX3("Z4_DEREJEC")[1], TAMSX3("Z4_DEREJEC")[2]	} )
	aAdd( aCampos, { 'Vl.taxa'      ,'T_VLTAXA'  ,"N",	PesqPict("SZ4","Z4_VLTAXA"), 	2, TAMSX3("Z4_VLTAXA")[1],  TAMSX3("Z4_VLTAXA")[2]	} )
	aAdd( aCampos, { 'Qtd.Parc'     ,'T_QTDPARC' ,"N",	PesqPict("SZ4","Z4_QTDPARC"), 	2, TAMSX3("Z4_QTDPARC")[1], TAMSX3("Z4_QTDPARC")[2]	} )
	aAdd( aCampos, { 'Vl.Parce'     ,'T_VLPARCE' ,"N",	PesqPict("SZ4","Z4_VLPARCE"), 	2, TAMSX3("Z4_VLPARCE")[1], TAMSX3("Z4_VLPARCE")[2]	} )
	aAdd( aCampos, { 'Vl.Liqu.'     ,'T_VLIQUID' ,"N",	PesqPict("SZ4","Z4_VLIQUID"), 	2, TAMSX3("Z4_VLIQUID")[1], TAMSX3("Z4_VLIQUID")[2]	} )
	aAdd( aCampos, { 'Vl.Dif.'     ,'T_VDIFERE' ,"C",	PesqPict("SZ4","Z4_VDIFERE"), 	2, TAMSX3("Z4_VDIFERE")[1], TAMSX3("Z4_VDIFERE")[2]	} )
	aAdd( aCampos, { 'Erro '        ,'T_LOGMSG'  ,"C",	                            , 	1, 30                     , 0} )
	aAdd( aCampos, { 'Dt.Impor'     ,'T_DATAIMP' ,"D",	PesqPict("SZ4","Z4_DATAIMP"), 	1, TAMSX3("Z4_DATAIMP")[1], TAMSX3("Z4_DATAIMP")[2]	} )
	aAdd( aCampos, { 'Hr.Impor'     ,'T_HORAIMP' ,"C",	PesqPict("SZ4","Z4_HORAIMP"), 	2, TAMSX3("Z4_HORAIMP")[1], TAMSX3("Z4_HORAIMP")[2]	} )

Return

Static Function fCreateTemp(oTemp,_aDadostxt,aCpoObrig,cTipo,lTela)
    
Local aStru  := {}
Local cArqTrab := ""
		
	aAdd( aStru, { 'T_OK'     	,'C', 1			          , 0 } )
	aAdd( aStru, { 'T_INTEG'    ,'C', 1                   , 0 } )	
	aAdd( aStru, { 'T_TOPCARD'  ,'C', TAMSX3("Z4_TOPCARD")[1], TAMSX3("Z4_TOPCARD")[2]} )				
	aAdd( aStru, { 'T_REG'   	,'C', TAMSX3("Z4_REG")[1],     TAMSX3("Z4_REG")[2]} )				
	If !lTela
		aAdd( aStru, { 'T_ESTAB'   	,'C', TAMSX3("Z4_ESTAB")[1],   TAMSX3("Z4_ESTAB")[2]} )			
		aAdd( aStru, { 'T_NSU'   	,'C', TAMSX3("Z4_NSU")[1],     TAMSX3("Z4_NSU")[2]} )	
	EndIf
	aAdd( aStru, { 'T_ID'  		,'C', TAMSX3("Z4_ID")[1],  	   TAMSX3("Z4_ID")[2] } )
	aAdd( aStru, { 'T_DTTRANS'	,'D', TAMSX3("Z4_DTTRANS")[1], TAMSX3("Z4_DTTRANS")[2] } )
	aAdd( aStru, { 'T_HRTRANS' 	,'C', TAMSX3("Z4_HRTRANS")[1], TAMSX3("Z4_HRTRANS")[2] } )
	If !lTela
		aAdd( aStru, { 'T_FORCAP' 	,'C', TAMSX3("Z4_FORCAP")[1],  TAMSX3("Z4_FORCAP")[2] } )
	EndIf
	aAdd( aStru, { 'T_DTPAGTO'  ,'D', TAMSX3("Z4_DTPAGTO")[1], TAMSX3("Z4_DTPAGTO")[2] } )
	aAdd( aStru, { 'T_BANDEIR' 	,'C', TAMSX3("Z4_BANDEIR")[1], TAMSX3("Z4_BANDEIR")[2]} )
	aAdd( aStru, { 'T_TIPOPG' 	,'C', TAMSX3("Z4_TIPOPG")[1],  TAMSX3("Z4_TIPOPG")[2] } )
	aAdd( aStru, { 'T_NUMCAR'  	,'C', TAMSX3("Z4_NUMCAR")[1],  TAMSX3("Z4_NUMCAR")[2] } )
	If !lTela
		aAdd( aStru, { 'T_NACINT'  	,'C', TAMSX3("Z4_NACINT")[1],  TAMSX3("Z4_NACINT")[2] } )
		aAdd( aStru, { 'T_MOEDA'  	,'C', TAMSX3("Z4_MOEDA")[1],   TAMSX3("Z4_MOEDA")[2] } )
	EndIf
	aAdd( aStru, { 'T_VALOR'    ,'N', TAMSX3("Z4_VALOR")[1],   TAMSX3("Z4_VALOR")[2]	} )
	aAdd( aStru, { 'T_CDREJEC'  ,'C', TAMSX3("Z4_CDREJEC")[1], TAMSX3("Z4_CDREJEC")[2]	} )
	aAdd( aStru, { 'T_DEREJEC'  ,'C', TAMSX3("Z4_DEREJEC")[1], TAMSX3("Z4_DEREJEC")[2]	} )
	aAdd( aStru, { 'T_VLTAXA'   ,'N', TAMSX3("Z4_VLTAXA")[1],  TAMSX3("Z4_VLTAXA")[2]	} )
	aAdd( aStru, { 'T_QTDPARC'  ,'N', TAMSX3("Z4_QTDPARC")[1], TAMSX3("Z4_QTDPARC")[2]	} )
	aAdd( aStru, { 'T_VLPARCE'  ,'N', TAMSX3("Z4_VLPARCE")[1], TAMSX3("Z4_VLPARCE")[2]	} )
	aAdd( aStru, { 'T_VLIQUID'  ,'N', TAMSX3("Z4_VLIQUID")[1], TAMSX3("Z4_VLIQUID")[2]	} )
	aAdd( aStru, { 'T_VDIFERE'  ,'N', TAMSX3("Z4_VDIFERE")[1], TAMSX3("Z4_VDIFERE")[2]	} )	
	aAdd( aStru, { 'T_DATAIMP'  ,'D', TAMSX3("Z4_DATAIMP")[1], TAMSX3("Z4_DATAIMP")[2] } )
	aAdd( aStru, { 'T_HORAIMP'  ,'C', TAMSX3("Z4_HORAIMP")[1], TAMSX3("Z4_HORAIMP")[2]} )	
	aAdd( aStru, { 'T_LOGMSG'   ,'M', TAMSX3("Z4_LOGMSG")[1] , TAMSX3("Z4_LOGMSG")[2]} )	
	aAdd( aStru, { 'T_RECSZ4' ,'N', 12 , 0} )	
	
	cArqTrab := GetNextAlias()
	
	oTemp := FwTemporaryTable():New(cArqTrab)
	oTemp:SetFields( aStru )
	If lTela 
		oTemp:AddIndex("01", {"T_VDIFERE"} )
	Else
		oTemp:AddIndex("01", {"T_REG","T_ID"} )	
	EndIF
	oTemp:Create()
	
	If lTela
		fTCharge(cArqTrab) //Carga do TRB	
	Else
		fCharge(cArqTrab,_aDadostxt,aCpoObrig,cTipo) //Carga do TRB
	EndIf
Return(cArqTrab)


Static Function fTCharge(cTRB) 

Local cWhere 	:= ""
Local cTemSE1	:= ""
Local cAliasSZ4 := GetNextAlias()
Local cId    	:= ""
Local nI	 	:= 0
Local nX	 	:= 0
Local cMsgErro	:= ""
Local nPos		:= 0

(cTRB)->(__DbZap())

BeginSQL alias cAliasSZ4 
	%noparser%
		
	COLUMN Z4_DTTRANS AS DATE
	COLUMN Z4_DTPAGTO AS DATE
	COLUMN Z4_DATAIMP AS DATE
	COLUMN Z4_VLTAXA AS NUMERIC(12,2)
	COLUMN Z4_VLPARCE AS NUMERIC(12,2)
	COLUMN Z4_VLIQUID AS NUMERIC(12,2)
	COLUMN Z4_VALOR AS NUMERIC(12,2)	
		
	SELECT SZ4.*,ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), SZ4.Z4_LOGMSG)),'') AS MSGRET,
		SZ4.R_E_C_N_O_ AS RECSZ4
	 
	 FROM %table:SZ4% SZ4
		WHERE SZ4.Z4_FILIAL = %xfilial:SZ4% AND
			SZ4.Z4_INTEG = '4' AND
			SZ4.%notdel%
EndSql
While (cAliasSZ4)->(!EOF())

	RecLock((cTRB), .T. )
	(cTRB)->T_OK		:= ""
	(cTRB)->T_TOPCARD   := (cAliasSZ4)->Z4_TOPCARD
	(cTRB)->T_INTEG		:= (cAliasSZ4)->Z4_INTEG
	(cTRB)->T_REG 		:= (cAliasSZ4)->Z4_REG
	(cTRB)->T_ID		:= (cAliasSZ4)->Z4_ID
	(cTRB)->T_DTTRANS	:= (cAliasSZ4)->Z4_DTTRANS
	(cTRB)->T_HRTRANS   := (cAliasSZ4)->Z4_HRTRANS
	(cTRB)->T_DTPAGTO  	:= (cAliasSZ4)->Z4_DTPAGTO 
	(cTRB)->T_BANDEIR   := (cAliasSZ4)->Z4_BANDEIR
	(cTRB)->T_TIPOPG	:= (cAliasSZ4)->Z4_TIPOPG
	(cTRB)->T_NUMCAR	:= (cAliasSZ4)->Z4_NUMCAR
	(cTRB)->T_VALOR   	:= (cAliasSZ4)->Z4_VALOR
	(cTRB)->T_CDREJEC	:= (cAliasSZ4)->Z4_CDREJEC
	(cTRB)->T_DEREJEC	:= (cAliasSZ4)->Z4_DEREJEC	
	(cTRB)->T_VLTAXA    := (cAliasSZ4)->Z4_VLTAXA
	(cTRB)->T_QTDPARC	:= (cAliasSZ4)->Z4_QTDPARC
	(cTRB)->T_VLPARCE   := (cAliasSZ4)->Z4_VLPARCE
	(cTRB)->T_VLIQUID	:= (cAliasSZ4)->Z4_VLIQUID 
	(cTRB)->T_VDIFERE	:= (cAliasSZ4)->Z4_VDIFERE
	(cTRB)->T_DATAIMP  	:= (cAliasSZ4)->Z4_DATAIMP
	(cTRB)->T_HORAIMP	:= (cAliasSZ4)->Z4_HORAIMP
	(cTRB)->T_LOGMSG	:= (cAliasSZ4)->MSGRET
	(cTRB)->T_RECSZ4	:= (cAliasSZ4)->RECSZ4
	msUnlock() 

	(cAliasSZ4)->(DbSkip())
EndDo
(cAliasSZ4)->(DbCloseArea())
DbSelectArea("SZ4")

(cTRB)->(dbGoTop())
	
Return 

Static Function fCharge(cTRB,_aDadostxt,aCpoObrig,cTipo) 

Local cWhere 	:= ""
Local cTemSE1	:= ""
Local cQRY   	:= GetNextAlias()
Local cId    	:= ""
Local nI	 	:= 0
Local nX	 	:= 0
Local cMsgErro	:= ""
Local nPos		:= 0
Local aBaixa	:= {}
Local cBanco	:= ""
Local cAgencia	:= ""
Local cConta	:= ""
Local nValor	:= 0 
Local nValLiq	:= 0
Local nValDif   := 0
Local cAliaSA6  := GetNextAlias()
Local lForcaErr := .F.
Local nPosReg   := aScan( aCpoObrig, {|x| Alltrim(x[5]) == "Z4_REG" })

//Bloco de pesquisa valor do campo ou valor inicializador padrao
Local bCpoVl := {|x,y| cpo:=y,nx:=ascan(aCpoObrig,{|z| z[5]==cpo}),If(nx>0,_aDadostxt[x,nx],Criavar(cpo,.T.))} 
Private lMsErroAuto := .F.


BeginSql Alias cAliaSA6
	%noparser%

	SELECT TOP 1 A6_COD,A6_AGENCIA,A6_NUMCON,A6_XOPECAR 
		From %table:SA6% SA6
		Where SA6.A6_FILIAL = %xfilial:SA6% AND
			SA6.A6_XOPECAR = %exp:cTipo% AND
			SA6.A6_BLOCKED <> '1' AND
			SA6.%notdel%
EndSql

If (cAliaSA6)->(!Eof())
	cBanco	:= (cAliaSA6)->A6_COD
	cAgencia:= (cAliaSA6)->A6_AGENCIA
	cConta	:= (cAliaSA6)->A6_NUMCON
Else
	lForcaErr := .T.
EndIf
(cAliaSA6)->(DbCloseArea())

DbSelectArea(cTRB)
(cTRB)->(__DbZap())

For nI:= 1 To  Len(_aDadostxt)  	    

	cId := Eval(bCpoVl,nI,"Z4_ID")
	If cTipo=='1'
		if Len(cId)==11
			cId := Subs(cId,2,Len(cId)-3)
		endif
	EndIf
	nValLiq  := Round(Eval(bCpoVl,nI,"Z4_VLIQUID"),2)
	nValDif  := 0

	cTemSE1  := "1"
	If (_aDadostxt[nI,nPosReg] != cReg)  
		cTemSE1  := "2"
		if (_aDadostxt[nI,nPosReg] $ cRegOut)
			cTemSE1  := "6"
		endif
		cMsgErro := "Registro nao verificado"
	Else
		If lForcaErr
			cMsgErro := "Sem banco definido para baixa automatica do Tipo "+cTipo
		Else
			cMsgErro := "Erro Titulo nao Localizado"
		EndIf
		If !lForcaErr
			Beginsql alias cQRY
				COLUMN E1_SALDO    AS NUMERIC(12,2)
				COLUMN E1_VALOR    AS NUMERIC(12,2)
				COLUMN VLIQUI      AS NUMERIC(12,2)
				COLUMN E1_BAIXA    AS DATE
				SELECT SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,SE1.E1_VALOR,
					SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_SALDO,SE1.E1_VALOR,SE1.E1_BAIXA,SE1.E1_DECRESC,		
				    (SE1.E1_VALOR-SE1.E1_DESCONT+SE1.E1_MULTA+SE1.E1_JUROS+SE1.E1_ACRESC-SE1.E1_DECRESC) AS VLIQUI
					FROM %table:SE1% SE1
					WHERE SE1.E1_FILIAL = %xFilial:SE1% AND 
						SE1.E1_P_DTRAX = %exp:cId% AND
						SE1.%notdel%
			Endsql
			If (cQRY)->(!Eof())
				//Valor Titulo – Desconto + Multa + Juros + Acrescimo – Descrescimo.
				nValor := (cQRY)->VLIQUI
				nValDif := ROUND((nValLiq - nValor),2)
				If ((cQRY)->E1_SALDO == 0 .OR. !Empty((cQRY)->E1_BAIXA))  
					cTemSE1 := "3"
					cMsgErro := "Titulo Baixado anteriomente!"
				ElseIf nValLiq == nValor
					cTemSE1 := "2"
				Else
					cTemSE1 := "4"
					cMsgErro := "Valor liquido Diferente!"
				EndIf
					
				If cTemSE1=='2'
					Pergunte("FIN070",.F.)
					For nx := 1 to 30
						If nx==1
							&("mv_par"+StrZero(nx,2)) := 2
						ElseIf nx==4
							&("mv_par"+StrZero(nx,2)) := 2 
						EndIf	
					Next nx	
					aBaixa := {{"E1_PREFIXO"		,(cQRY)->E1_PREFIXO	,Nil},;
								  {"E1_NUM"		 	,(cQRY)->E1_NUM    	,Nil},;
								  {"E1_PARCELA"	 	,(cQRY)->E1_PARCELA	,Nil},;
								  {"E1_TIPO"	   	,(cQRY)->E1_TIPO   	,Nil},;
								  {"E1_CLIENTE"	    ,(cQRY)->E1_CLIENTE	,Nil},;
							      {"E1_LOJA"    	,(cQRY)->E1_LOJA   	,Nil},;
								  {"AUTMOTBX"	    ,"NOR"             	,Nil},;
								  {"AUTBANCO"  	    ,cBanco			   	,Nil},;
								  {"AUTAGENCIA"   	,cAgencia		   	,Nil},;
								  {"AUTCONTA"  		,cConta 		   	,Nil},;
								  {"AUTDTBAIXA"	 	,ddatabase			,Nil},;
								  {"AUTDTCREDITO" 	,ddatabase			,Nil},;
								  {"AUTHIST"	    ,'Datatrax '+cID	,Nil},; 
								  {"AUTCHEQUE"  	, ""				,Nil},;
								  {"AUTVALREC"	 	,nValor  			,Nil},;
								  {"AUTDECRESC" 	,(cQRY)->E1_DECRESC	,Nil}}

					lMsErroAuto := .F.			  
					Begin Transaction			  
						MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
				    End Transaction
				   	IF lMsErroAuto
				   		cTemSE1 := "4"
						aErros := GetAutoGRLog()
					    DisarmTransaction()
				    	For nX:=1 To Len(aErros)
							cMsgErro += aErros[nX]
						Next
					Else
						cMsgErro := "baixa com Sucesso!"
					EndIF
				EndIf
			EndIf
			(cQRY)->(dbCloseArea())			
		EndIf
	EndIf
	
	RecLock((cTRB), .T. )
	(cTRB)->T_OK		:= ""
	(cTRB)->T_INTEG		:= cTemSE1
	(cTRB)->T_TOPCARD	:= cTipo
	(cTRB)->T_REG 		:= Eval(bCpoVl,nI,"Z4_REG")
	(cTRB)->T_ESTAB		:= Eval(bCpoVl,nI,"Z4_ESTAB")
	(cTRB)->T_NSU 		:= Eval(bCpoVl,nI,"Z4_NSU")
	(cTRB)->T_ID		:= cId
	(cTRB)->T_DTTRANS	:= Eval(bCpoVl,nI,"Z4_DTTRANS")
	(cTRB)->T_HRTRANS   := Eval(bCpoVl,nI,"Z4_HRTRANS")
	(cTRB)->T_FORCAP 	:= Eval(bCpoVl,nI,"Z4_FORCAP")
	(cTRB)->T_DTPAGTO  	:= Eval(bCpoVl,nI,"Z4_DTPAGTO") 
	(cTRB)->T_BANDEIR   := Eval(bCpoVl,nI,"Z4_BANDEIR")
	(cTRB)->T_TIPOPG	:= Eval(bCpoVl,nI,"Z4_TIPOPG")
	(cTRB)->T_NUMCAR	:= Eval(bCpoVl,nI,"Z4_NUMCAR")
	(cTRB)->T_NACINT	:= Eval(bCpoVl,nI,"Z4_NACINT")
	(cTRB)->T_MOEDA	    := Eval(bCpoVl,nI,"Z4_MOEDA")
	(cTRB)->T_VALOR   	:= Eval(bCpoVl,nI,"Z4_VALOR")
	(cTRB)->T_CDREJEC	:= Eval(bCpoVl,nI,"Z4_CDREJEC")
	(cTRB)->T_DEREJEC	:= Eval(bCpoVl,nI,"Z4_DEREJEC")	
	(cTRB)->T_VLTAXA    := Eval(bCpoVl,nI,"Z4_VLTAXA")
	(cTRB)->T_QTDPARC	:= Eval(bCpoVl,nI,"Z4_QTDPARC")
	(cTRB)->T_VLPARCE   := Eval(bCpoVl,nI,"Z4_VLPARCE")
	(cTRB)->T_VLIQUID	:= nValLiq 
	(cTRB)->T_VDIFERE	:= nValDif
	(cTRB)->T_DATAIMP  	:= date()
	(cTRB)->T_HORAIMP	:= StrTran(time(),":","")
	(cTRB)->T_LOGMSG	:= cMsgErro	
	msUnlock() 
Next
(cTRB)->(dbGoTop())
	
Return 


Static Function PROCSFTP(lMov,PROCSFTP)

Local lRet       := .T.
Local cDir	 	 := Upper(Alltrim(GETMV("MV_P_00119"))+"\")
Local cDirFisico := Alltrim(GetSrvProfString("ROOTPATH",""))+cDir
//Local nRecSZ0    := GETMV("MV_P_XNSZ0")
Local nX         := 0
Local aFiles	 := {}
Local aSizes	 := {}

Default lMov   := .F.

If !lMov
	//[INI] EFETUA A LIMPEZA DA PASTA "IMPORTADO"
	ADir(cDir+'IMPORTADO\'+cPasta+'\'+"*.txt",aFiles, aSizes)
	
	For nX := 1 to Len( aFiles )  
	   fErase(cDir+'IMPORTADO\'+cPasta+'\'+aFiles[nX])
	Next nX
	//[FIM] EFETUA A LIMPEZA DA PASTA "IMPORTADO"
			
	//Execução do batch para buscar no sftp os arquivos do datatrax
	WaitRunSrv(@cDirFisico+"datatrax.bat "+cPasta,.T.,@cDirFisico)
	
Else	  
	//If __Copyfile(cDir+'IMPORTADO\'+cPasta+'\'+ARQXML->Z0_XMLARQ,cDir+'PROCESSADO\'+cPasta+'\'+ARQXML->Z0_XMLARQ)
	//	fErase(cDir+'IMPORTADO\'+cPasta+'\'+ARQXML->Z0_XMLARQ) //-- Apago arquivo na Pasta RAIZ
	//EndIf	
EndIf

Return lRet



Static Function MenuDef(nOption)
Local aRotina 	:= {}	
	If nOption==1
		ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.JBTXTCAR' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 	
		ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.JBTXTCAR' OPERATION MODEL_OPERATION_DELETE ACCESS 0	
		ADD OPTION aRotina TITLE 'Reprocessa'	ACTION 'StaticCall(JBTXTCAR,MontaTela)' OPERATION MODEL_OPERATION_VIEW ACCESS 0 	  
		ADD OPTION aRotina TITLE 'Job'	        ACTION 'StaticCall(JBTXTCAR,JBTXTCALL)' OPERATION MODEL_OPERATION_VIEW ACCESS 0 	  
	EndIf	
Return aRotina

Static Function Modeldef()
Local oModel := Nil
Local oStSZ4 := FWFormStruct(1,"SZ4")

oModel:= MPFormModel():New("SZ4MVC",/*Pre-Validacao*/, /*Pos-Validacao*/ ,/*Commit*/,/*Cancel*/)
oModel:AddFields("REL_SZ4", Nil , oStSZ4,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:SetPrimarykey({'Z4_FILIAL','Z4_REG','Z4_ID','Z4_NSU','Z4_ESTAB'})


Return(oModel)

Static Function ViewDef()
Local oModel := FWLoadModel("JBTXTCAR")
oView := FWFormView():New()     
oView:SetModel(oModel)
oView:AddField( "REL_SZ4" , FWFormStruct(2,"SZ4"))   
oView:CreateHorizontalBox("ALL",100)
oView:SetOwnerView("REL_SZ4","ALL")

Return oView

Static Function JBTXTLEGEND()

BrwLegenda("Conciliacao","Legenda",{{"BR_VERDE"		,"Conciliado Normal"},;
									{"BR_VERMELHO"	,"Nao Conciliado"},;
									{"BR_AMARELO"	,"Baixado anteriormente"},;
									{"BR_PRETO"	    ,"Divergente"},;  
									{"BR_AZUL"      ,"Conciliado com Baixa"},;
									{"BR_MARROM"    ,"Outros registros"}})

Return

Static Function JBTXTCALL() 
	If !MsgYesNo("Confirma o processos do Job?")
		Return
	EndIf
	FWMsgRun(, {|| U_JBTXTCAR(nil,.T.) }, "JOB - Importa txt cartao", "Aguarde...")
Return Nil
