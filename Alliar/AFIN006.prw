#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH" 


/*/{Protheus.doc} AFIN006
Realiza a geração do arquivo SISPAG automático 
@author Jonatas Oliveira | www.compila.com.br
@since 30/04/2018
@version 1.0
@param cNumBI	, C	, Bordero De
@param cNumBF	, C	, Bordero Até
@param cArqCfg	, C	, Arquivo de Confuguração
@param cArqSaid	, C	, Arquivo à ser Gerado
@param cFilSea	, C	, Filial Bordero
@return aRet	, A , aRet[1] - Sucesso? 	aRet[2] - Mensagem Processamento aRet[3] - Caminho arquivo gerado
/*/
User Function AFIN006(cNumBI, cNumBF, cArqCfg, cArqSaid)
Local aRet		:= { .T., "", ""}
Local lRetPag	:= .F.
Local cRet		:= ""

Local cCodEmp	:= "01"
Local cCodFil	:= ""

PRIVATE cFil240		:= ""
PRIVATE c240FilBT	:= space(60)
Private xConteudo
Private cLoteFin	:= Space(04)
Private cPadrao 	:= ""
Private cBenef		:= ""
Private nTotAGer 	:= 0
Private nTotADesp	:= 0
Private nTotADesc	:= 0
Private nTotAMul 	:= 0
Private nTotAJur 	:= 0
Private nValPadrao	:= 0
Private nValEstrang	:= 0
Private cBanco   	:=  ""
Private cAgencia 	:=  ""
Private cConta 		:=  ""
Private cCtBaixa 	:=  ""
Private cAgen240 	:=  ""
Private cConta240	:=  ""
Private cModPgto  	:=  ""
Private cTipoPag 	:=  ""
Private cMarca   	:=  ""
Private cLote
Private cCadastro   
Private aGetMark 	:= {}

Private MV_PAR01 	:= ""
Private MV_PAR02 	:= ""
Private MV_PAR03 	:= ""
Private MV_PAR04 	:= ""

Default cNumBI	 := "002212"
Default	cNumBF	 := "002212"
Default cArqCfg  := "itau.pag"
Default cArqSaid := "C:\TEMP\TESTE_SISPAG.REM"



cBanco   	:= CriaVar("E1_PORTADO")
cAgencia 	:= CriaVar("E1_AGEDEP")
cConta 		:= CriaVar("E1_CONTA")
cCtBaixa 	:= GetMv("MV_CTBAIXA")
cAgen240 	:= CriaVar("A6_AGENCIA")
cConta240	:= CriaVar("A6_NUMCON")
cModPgto  	:= CriaVar("EA_MODELO")
cTipoPag 	:= CriaVar("EA_TIPOPAG")
cBenef		:= CriaVar("E5_BENEF")	



IF FILE("/SYSTEM/" + cArqCfg)

	MV_PAR01 	:= cNumBI
	MV_PAR02 	:= cNumBF
	MV_PAR03 	:= cArqCfg
	MV_PAR04 	:= cArqSaid

	//|Gera Arquivo Remessa SisPag|
	lRetPag := SisPagGer("SE2")

	IF !lRetPag 
		aRet	:= { .F., "Falha na geração do arquivo. ", ""}
	ELSE
		aRet	:= { .T., "",  cArqSaid }
		cRet 	:= cArqSaid
	ENDIF 

ELSE
	aRet	:= { .F., "Arquivo de Configuração não Localizado", ""}
ENDIF 

Return(cRet)



//|u_AFIN006("002212", "002212","itau.pag", "C:\TEMP\SISPAG.TXT")