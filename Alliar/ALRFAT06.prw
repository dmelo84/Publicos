#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} ALRFAT06
Marca o campo de status do Ped de Venda 
Atualiza o campo C5_XBLQ de acordo com as regras
@author Leandro Oliveira
@since 27/11/2015
/*/

USER FUNCTION ALRFAT06()

Local cBloqC5
Local nX			:= 0
Local nPosPis 		:= nPosCof := nPosCsl := nPosIrf := nPosIns := 0
Local nVrPis 		:= nVrCof := nVrCsl := nVrIrf := nVrIns := 0 
Local cMsgErro		:= ""
Local cTribCli


DBSELECTAREA("SA1")
SA1->(DBSETORDER(1)) //| 
IF SA1->(DBSEEK(xfilial("SA1")+SC5->(C5_CLIENTE + C5_LOJACLI)))


	nPosPis := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XVTRPIS"})
	nPosCof := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XVTRCOF"})
	nPosCsl := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XVTRCSL"})
	nPosIrf := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XVTRIRF"})
	nPosIns := ASCAN(aHeader, {|aVal| Alltrim(aVal[2]) == "C6_XVTRINS"})
	
	
	DBSELECTAREA("SZK")
	SZK->(DBSETORDER(1)) //| 
			
			
	/*
	Aadd(aCores, {"C5_XBLQ == '1' .AND. Empty(C5_NOTA)",'BR_CINZA'		,"Bloq.: Cadastro NOVO Cliente"}) //"Bloq.: Cliente novo atualizar cadastro"})
	Aadd(aCores, {"C5_XBLQ == '2' .AND. Empty(C5_NOTA)",'BR_MARROM'		,"Bloq.: Cliente com tributo VARIAVEL"}) //"Bloq.: Atualizar cad. cliente"})
	Aadd(aCores, {"C5_XBLQ == '3' .AND. Empty(C5_NOTA)",'BR_BRANCO'		,"Bloq.: Sem VALOR dos tributos retidos"}) //"Bloq.: Atualizar valor dos tribs retidos"})
	Aadd(aCores, {"C5_XBLQ == '5' .AND. Empty(C5_NOTA)",'BR_LARANJA'	,"Bloq.: Pedido NÃO possui retenções"}) //"Bloq.: Atualizar Valor do Pedido"})
	Aadd(aCores, {"C5_XBLQ == '6' .AND. Empty(C5_NOTA)",'BR_AZUL'		,"Bloq.: NF Cancelada"})
	Aadd(aCores, {"C5_XBLQ == '7' .AND. Empty(C5_NOTA)",'BR_PRETO'		,"Bloq.: Emitindo NF"})				
	*/
			
	IF SC5->C5_XBRTLIQ == "L"		
		cBloqC5	:= "5" //| "Bloq.: Pedido NÃO possui retenções" |
	
	ELSEIF ALLTRIM(SA1->A1_PESSOA) == "J"	
		/*----------------------------------------
			20/06/2019 - Jonatas Oliveira - Compila
			Tratativa para verificar os tributos 
			variaveis na tabela ZZA antes de verificar
			no cadastro de clientes		
		------------------------------------------*/
		DBSELECTAREA("ZZA")
		ZZA->(DBSETORDER(1))//|ZZA_FILIAL+ZZA_CODCLI+ZZA_LOJA|
		
		If ZZA->(DBSEEK( SC5->( C5_FILIAL + C5_CLIENTE + C5_LOJACLI ) ))
			IF !EMPTY(ZZA->ZZA_XTRIBE)
				cTribCli := ZZA->ZZA_XTRIBE
			ELSE
				cTribCli := SA1->A1_XTRIBES
			ENDIF 
		Else
			cTribCli := SA1->A1_XTRIBES
		Endif
		
		IF EMPTY(cTribCli)
			cBloqC5	:= "1" //| "Bloq.: Cliente com tributo VARIAVEL" |
	
		ELSEIF ALLTRIM(cTribCli) == "N"
			cBloqC5 := "4"	//| LIBERADO |
		ELSEIF SC5->C5_XBLQ  == "8"
			cBloqC5 := "8"
		ELSE

			If ALLTRIM(cTribCli) == "F" .OR. ALLTRIM(cTribCli) == "V" 
				If SC5->C5_XBLQ == "1" .OR. SC5->C5_XBLQ == "2" .OR. SC5->C5_XBLQ == "3" //(cStatus $ "1,2,3")
					Alert("Cliente com tributos retidos e valores nao informados - Favor Conferir!")
				EndIf
			EndIf

			For nX := 1 to Len(aCols)
				If !aCols[nX,Len(aHeader)+1]                 	
					nVrPis += aCols[ nX, nPosPis] 
					nVrCof += aCols[ nX, nPosCof]
					nVrCsl += aCols[ nX, nPosCsl]
					nVrIrf += aCols[ nX, nPosIrf]
					nVrIns += aCols[ nX, nPosIns]
				Endif	
			Next
				 
			If(nVrPis+nVrCof+nVrCsl+nVrIrf+nVrIns == 0) //.AND. !lFatAut
				
				cBloqC5 := "3" //| "Bloq.: Sem VALOR dos tributos retidos" |			
				IF SZK->(DBSEEK(SM0->M0_CODIGO + SC5->C5_FILIAL)) .AND. SZK->ZK_FATPJAU == "S" 
					IF SA1->A1_XTELTRI == "N"
						cBloqC5 := "4" //| LIBBERADO |
					ENDIF 
				ENDIF 
					
			Else
				cBloqC5 := "4" //| LIBBERADO |
			EndIf
			
		ENDIF

	ENDIF
	
		
	/*------------------------------------------------------ Augusto Ribeiro | 18/02/2019 - 3:56:34 PM
		Atualiza pedido de venda
	------------------------------------------------------------------------------------------*/
	IF !EMPTY(cBloqC5)
		RecLock("SC5", .F.)
			SC5->C5_XBLQ := cBloqC5
		MsUnlock()	
	ENDIF

ENDIF
					  		
Return NIL 
