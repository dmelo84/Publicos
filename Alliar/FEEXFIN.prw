// #########################################################################################
// Projeto: CSC ALLIAR
// Modulo : FINANCEIRO
// Fonte  : FEEXFIN
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 12/07/17 | Eduardo.D.Ferreira|
// ---------+-------------------+-----------------------------------------------------------


#Include "Protheus.ch"
#Include "TopConn.ch"
#Define CTRL Chr(13)+Chr(10)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FEEXFIN
Geração de arquivo da E2

@author    TOTVS | Developer Studio -
@version   1.xx
@since     12/07/2017
/*/
//------------------------------------------------------------------------------------------
User Function FEEXFIN()

Private cPerg     := "FINAFEEX"

DbSelectArea("SX1")

//Chamada de função para criar as perguntas.
SX1->(DBSetOrder(1))
If !SX1->(MsSeek(cPerg))
	Processa({||FAjustSX1()},"Aguarde...","Gerando Parâmetros...")
EndIf


If !Pergunte(cPerg,.T.)
   Return
Else
	Processa({||GerArq()},"Aguarde...","Gerando Arquivo...")
Endif

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerArq
Geração de arquivo Seguro

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     28/01/2015
/*/
//------------------------------------------------------------------------------------------
Static Function GerArq()


Private nHandle   := 0

cNomeArq   	:= Alltrim(MV_PAR01)
cPastaDest 	:= Alltrim(MV_PAR02)
cFilDe		:= Alltrim(MV_PAR03)
cFilAte		:= Alltrim(MV_PAR04)
dComptDe   	:= MV_PAR05
dComptAte	:= MV_PAR06


If Upper(SubStr(cNomeArq,(Len(cNomeArq))-4,4)) <> ".CSV"
   cNomeArq := cNomeArq+".CSV"
EndIf

If SubStr(cPastaDest,Len(cPastaDest),1) <> "\"
   cPastaDest := cPastaDest+"\"
EndIf

nHandle := fCreate(cPastaDest+cNomeArq,0)

If nHandle == -1
   Alert("Ocorreu um erro na criação do arquivo: "+cNomeArq+" - "+ Str(fError(),4))
   Return
EndIf

ExecQuery()

ProcRegua(180000) // passa quantidade de registros

DbSelectArea("TAB")
DbGoTop()

fWrite(nHandle,+'Filial;  	Prefixo;   	No Titulo;  	Parcela;   	Tipo  ;    	Natureza ;   	Portador;    	Fornecedor;  	Loja;        	Nome Fornece;	DT Emissao;  	Vencimento;  	Vencto Real; 	VlrTitulo;  	ISS;         	IRRF;        	DT Baixa ;   	Bco de Pgto; 	Historico;   	Saldo ;      	Desconto;    	Multa;       	Juros;       	Val Liq Baix;	Vencto Orig; 	Num Bordero; 	Num Fatura;  	Acrescimo;   	Tit. Origem; 	Dt Liberacao;	Sld Acresc; 	Decrescimo;  	Sld Decresc;	Usuario;     	Id Cnab;    	Filial Orig;	Linha Dig;  	Base PCC ;   	Cod Barras;  	Base Csll;   	Num Contrato;	Num  Parcela;	Banco For;  	Agencia For;	DV Agencia;  	Conta For;  	DV Conta;    	C de Custo; 	Status ;     	Data Agend; 	Forma Pgto; 	Agl Impostos;	Ident Reg;  Dt  Bordero; '+CTRL)

While !EOF()


fWrite(nHandle,;
			TAB->E2_FILIAL                         +';'+;
			TAB->E2_PREFIXO                        +';'+;
			TAB->E2_NUM                            +';'+;
			TAB->E2_PARCELA                        +';'+;
			TAB->E2_TIPO                           +';'+;
			TAB->E2_NATUREZ                        +';'+;
			TAB->E2_PORTADO                        +';'+;
			TAB->E2_FORNECE                        +';'+;
			TAB->E2_LOJA                           +';'+;
			TAB->E2_NOMFOR                         +';'+;
			DtoC(StoD(TAB->E2_EMISSAO))            +';'+;
			DtoC(StoD(TAB->E2_VENCTO))             +';'+;
			DtoC(StoD(TAB->E2_VENCREA))            +';'+;
			AllTrim(Str(TAB->E2_VALOR))            +';'+;
			AllTrim(Str(TAB->E2_ISS))              +';'+;
			AllTrim(Str(TAB->E2_IRRF))             +';'+;
			DtoC(StoD(TAB->E2_BAIXA))              +';'+;
			TAB->E2_BCOPAG                         +';'+;
			TAB->E2_HIST                           +';'+;
			AllTrim(Str(TAB->E2_SALDO))            +';'+;
			AllTrim(Str(TAB->E2_DESCONT))          +';'+;
			AllTrim(Str(TAB->E2_MULTA))            +';'+;
			AllTrim(Str(TAB->E2_JUROS))            +';'+;
			AllTrim(Str(TAB->E2_VALLIQ))           +';'+;
			DtoC(StoD(TAB->E2_VENCORI))            +';'+;
			TAB->E2_NUMBOR                         +';'+;
			TAB->E2_FATURA                         +';'+;
			AllTrim(Str(TAB->E2_ACRESC))           +';'+;
			TAB->E2_TITORIG                        +';'+;
			DtoC(StoD(TAB->E2_DATALIB))            +';'+;
			AllTrim(Str(TAB->E2_SDACRES))          +';'+;
			AllTrim(Str(TAB->E2_DECRESC))          +';'+;
			AllTrim(Str(TAB->E2_SDDECRE))          +';'+;
			TAB->E2_USUALIB                        +';'+;
			TAB->E2_IDCNAB                         +';'+;
			TAB->E2_FILORIG                        +';'+;
			TAB->E2_LINDIG                         +';'+;
			TAB->E2_BASEPIS                        +';'+;
			TAB->E2_CODBAR                         +';'+;
			AllTrim(Str(TAB->E2_BASECSL))          +';'+;
			TAB->E2_MDCONTR                        +';'+;
			TAB->E2_MDPARCE                        +';'+;
			TAB->E2_FORBCO                         +';'+;
			TAB->E2_FORAGE                         +';'+;
			TAB->E2_FAGEDV                         +';'+;
			TAB->E2_FORCTA                         +';'+;
			TAB->E2_FCTADV                         +';'+;
			TAB->E2_CCUSTO                         +';'+;
			TAB->E2_STATLIB                        +';'+;
			DtoC(StoD(TAB->E2_DATAAGE))            +';'+;
			TAB->E2_FORMPAG                        +';'+;
			TAB->E2_AGLIMP                         +';'+;
			TAB->E2_MSIDENT                        +';'+;
			DtoC(StoD(TAB->E2_DTBORDE))            +';'+CTRL)

	TAB->(dbSkip())

	dbSkip()

EndDo

fClose(nHandle)

dbCloseArea()

MSGINFO("Arquivo gerado.","Informação")

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecQuery
Executa Query

@author    TOTVS | Developer Studio - /*/
//------------------------------------------------------------------------------------------

Static Function ExecQuery()


	     cQuery := "  SELECT     *                                                  "
         cQuery  +="  FROM                                                          "
         cQuery  +="  	SE2010                                                      "
         cQuery  +="  WHERE                                                         "
         cQuery  +="  	SE2010.D_E_L_E_T_ = ''                                      "
         cQuery  +="	AND  E2_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"'            "
         cQuery  +=" 	AND E2_BAIXA BETWEEN '"+DtoS(dComptDe)+"' AND '"+DtoS(dComptAte)+"' "

   //MemoWrite("c:\query.txt",cquery)

   DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TAB", .F., .T.)

Return


//-------------------------------------------------------------------
Static Function FAjustSX1()

PutSx1(cPerg,"01","Nome Arquivo			"		,"","","mv_ch01","C",20							,0,0,"G","",""		,"","","mv_par01")
PutSx1(cPerg,"02","Pasta Destino		"		,"","","mv_ch02","C",20							,0,0,"G","",""		,"","","mv_par02")
PutSx1(cPerg,"03","Filial de			"		,"","","mv_ch03","C",TamSx3("E2_FILIAL")[1]	,0,0,"G","","SM0"		,"","","mv_par03")
PutSx1(cPerg,"04","Filial ate			"		,"","","mv_ch04","C",TamSx3("E2_FILIAL")[1]	,0,0,"G","","SM0"		,"","","mv_par04")
PutSx1(cPerg,"05","Data Emis de			"		,"","","mv_ch06","D",8							,0,0,"G","",""		,"","","mv_par05")
PutSx1(cPerg,"06","Data Emis ate			"		,"","","mv_ch07","D",8							,0,0,"G","",""		,"","","mv_par06")



Return(Nil)

