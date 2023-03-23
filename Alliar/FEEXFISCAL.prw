// #########################################################################################
// Projeto: CSC ALLIAR
// Modulo : FISCAL
// Fonte  : FEEXFISCAL
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 12/07/17 | Eduardo.D.Ferreira|
// ---------+-------------------+-----------------------------------------------------------


#Include "Protheus.ch"
#Include "TopConn.ch"
#Define CTRL Chr(13)+Chr(10)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FEEXFISCAL
Geração de arquivo da E5 E E1

@author    TOTVS | Developer Studio -
@version   1.xx
@since     12/07/2017
/*/
//------------------------------------------------------------------------------------------
User Function FEEXFISCAL()

Private cPerg     := "FEEXFISCAL"

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
dComptDe   	:= Alltrim(MV_PAR05)
dComptAte	:= Alltrim(MV_PAR06)


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

fWrite(nHandle,+'Filial; DT Movimen; Natureza; Cliente;	Loja; Nome;	CNPJ CPF; Parcela;	Prefixo; No Titulo;	Tipo;  	Vlr Movim ;	Vlr Titulo;	Saldo; 	Desconto; 	DT Emissao; Vencimento;	Vencto real;	Beneficiario;	RecPag;   	Historico; 	Data Digit;	Tipo do Doc; Valor Acresc; Valor Decres; Valor Rt PIS; Valor Rt COF; Valor Rt CSL; IRRF; Valor Rt IR; Valor Rt ISS; Base IRPF;'+CTRL)

While !EOF()


fWrite(nHandle,;
			TAB->E1_FILIAL		+';'+;
			TAB->E5_DATA,       +';'+;
			TAB->E1_NATUREZ,    +';'+;
			TAB->E1_CLIENTE,    +';'+;
			TAB->E1_LOJA,       +';'+;
			TAB->A1_NOME,       +';'+;
			TAB->A1_CGC,        +';'+;
			TAB->E1_PARCELA,    +';'+;
			TAB->E1_PREFIXO,    +';'+;
			TAB->E1_NUM,        +';'+;
			TAB->E1_TIPO,       +';'+;
			TAB->E5_VALOR,      +';'+;
			TAB->E1_VALOR,      +';'+;
			TAB->E1_SALDO,      +';'+;
			TAB->E1_DESCONT,    +';'+;
			TAB->E1_EMISSAO,    +';'+;
			TAB->E1_VENCTO,     +';'+;
			TAB->E1_VENCREA,    +';'+;
			TAB->E5_BENEF,      +';'+;
			TAB->E5_RECPAG,     +';'+;
			TAB->E5_HISTOR,     +';'+;
			TAB->E5_DTDIGIT,    +';'+;
			TAB->E5_TIPODOC,    +';'+;
			TAB->E5_VLACRES,    +';'+;
			TAB->E5_VLDECRE,    +';'+;
			TAB->E5_VRETPIS,    +';'+;
			TAB->E5_VRETCOF,    +';'+;
			TAB->E5_VRETCSL,    +';'+;
			TAB->E1_IRRF,       +';'+;
			TAB->E5_VRETIRF,    +';'+;
			TAB->E5_VRETISS,    +';'+;
			TAB->E5_BASEIRF +';'+CTRL)

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

         cQuery := " SELECT                        "
	     cQuery  +=" E1_FILIAL,                    "
	     cQuery  +=" E5_DATA,                      "
		 cQuery  +=" E1_NATUREZ,                   "
		 cQuery  +=" E1_CLIENTE,                   "
		 cQuery  +=" E1_LOJA,                      "
		 cQuery  +=" A1_NOME,                      "
		 cQuery  +=" A1_CGC,                       "          
		 cQuery  +=" E1_PARCELA,                   "
		 cQuery  +=" E1_PREFIXO,                   "
		 cQuery  +=" E1_NUM,                       "          
	     cQuery  +=" E1_TIPO,                      "
         cQuery  +=" E5_VALOR,                     "
         cQuery  +=" E1_VALOR,                     "
         cQuery  +=" E1_SALDO,                     "
         cQuery  +=" E1_DESCONT,                   "
         cQuery  +=" E1_EMISSAO,                   "
         cQuery  +=" E1_VENCTO,                    "
         cQuery  +=" E1_VENCREA,                   "
         cQuery  +=" E5_BENEF,                     "
         cQuery  +=" E5_RECPAG,                    "
         cQuery  +=" E5_HISTOR,                    "
         cQuery  +=" E5_DTDIGIT,                   "
         cQuery  +=" E5_TIPODOC,                   "
         cQuery  +=" E5_VLACRES,                   "
         cQuery  +=" E5_VLDECRE,                   "
         cQuery  +=" E5_VRETPIS,                   "
         cQuery  +=" E5_VRETCOF,                   "
         cQuery  +=" E5_VRETCSL,                   "
         cQuery  +=" E1_IRRF,                      "
         cQuery  +=" E5_VRETIRF,                   "
         cQuery  +=" E5_VRETISS,                   "
         cQuery  +=" E5_BASEIRF                    "
         cQuery  +="	FROM                       "
         cQuery  +=" 	SE5010                     "
         cQuery  +=" LEFT JOIN                     "
         cQuery  +=" 	SE1010                     "
         cQuery  +=" 	ON                         "
         cQuery  +=" 	E5_NUMERO = E1_NUM         "  
         cQuery  +=" 	AND E5_PREFIXO = E1_PREFIXO "
         cQuery  +=" 	AND E5_CLIFOR = E1_CLIENTE  "
         cQuery  +=" 	AND E5_LOJA = E1_LOJA       " 
         cQuery  +=" 	AND E5_PARCELA = E1_PARCELA "
         cQuery  +=" 	AND SE1010.D_E_L_E_T_ = ''  "
         cQuery  +=" 	AND E1_TIPO = 'NF'          "  
         cQuery  +=" LEFT JOIN                      "
         cQuery  +=" 	SA1010                      "
         cQuery  +=" 	ON                          "
         cQuery  +=" 	E1_CLIENTE = A1_COD         "
         cQuery  +=" 	AND E1_LOJA = A1_LOJA       "
         cQuery  +=" 	AND SA1010.D_E_L_E_T_ = ''  "
         cQuery  +=" WHERE                          "
         cQuery  +=" 	SE5010.D_E_L_E_T_ = ''      "
         cQuery  +=" 	AND E5_RECPAG = 'R'         "
         cQuery  +=" 	AND E5_TIPODOC = 'VL'       "
         cQuery  +=" 	AND E5_PREFIXO <> 'MUT'     "
         cQuery  +="    AND E5_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"'       
         cQuery  +=" 	AND E5_DATA BETWEEN '"+DtoS(dComptDe)+"' AND '"+DtoS(dComptAte)+"' 
         

   //MemoWrite("c:\query.txt",cquery)

   DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TAB", .F., .T.)

Return


//-------------------------------------------------------------------
Static Function FAjustSX1()

PutSx1(cPerg,"01","Nome Arquivo			"		,"","","mv_ch01","C",20							,0,0,"G","",""		,"","","mv_par01")
PutSx1(cPerg,"02","Pasta Destino		"		,"","","mv_ch02","C",20							,0,0,"G","",""		,"","","mv_par02")
PutSx1(cPerg,"03","Filial de			"		,"","","mv_ch03","C",TamSx3("E5_FILIAL")[1]	,0,0,"G","","SM0"		,"","","mv_par03")
PutSx1(cPerg,"04","Filial ate			"		,"","","mv_ch04","C",TamSx3("E5_FILIAL")[1]	,0,0,"G","","SM0"		,"","","mv_par04")
PutSx1(cPerg,"05","Data  de			"		,"","","mv_ch07","D",8							,0,0,"G","",""		,"","","mv_par05")
PutSx1(cPerg,"06","Data ate			"		,"","","mv_ch08","D",8							,0,0,"G","",""		,"","","mv_par06")

Return(Nil)

