#Include "Protheus.ch"
#Include "TOTVS.CH"
#Include 'FWMVCDef.ch'


/*/{Protheus.doc} FSCTBP02
Rotina para apuração e contabilização da produção/perda do mes de referencia

@type function
@author Alex Teixeira de Souza
@since 08/01/2016
@version 1.0
@param nenhum
@return ${aRet}, ${Codigo do erro, Descricao do Erro}
@example
(examples)
@see (links_or_references)
/*/
User Function FSCTBP02()
Local cValPerg  	:= "FSCTBP02"


//Funcao para criar/ajustar o grupo de perguntas da SX1
FSAjuSX1(cValPerg)

//Chamada das perguntas
If Pergunte(cValPerg,.T.)
	U_FSCTBP03()
Endif

Return Nil

/*/{Protheus.doc} FSAjuSX1
Rotina para apuração e contabilização da produção/perda do mes de referencia

@type function
@author Alex Teixeira de Souza
@since 08/01/2016
@version 1.0
@param cPerg, character, 	Codigo da pergunta a ser gerado
@return ${aRet}, ${Codigo do erro, Descricao do Erro}
@example
(examples)
@see (links_or_references)
/*/
Static Function FSAjuSX1(cPerg)

Local aPergs   := {}
Local aHelpPor := {}

aHelpPor := {}
Aadd( aHelpPor, 'Data Referencia' )

PutSx1(cPerg,"01","Dt.Referencia AAAAMM?","Dt.Referencia AAAAMM??","Dt.Referencia AAAAMM??","mv_cha","C",6,0,0,"G","NaoVazio()","","","S",;
	"MV_PAR01","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor := {}
Aadd( aHelpPor, 'Conta Contábil receita faturada' )

PutSx1(cPerg,"02","Ct Receita Faturada?","Ct Receita Faturada?","Ct Receita Faturada?","mv_chb","C",TamSX3("CT1_CONTA")[1],0,0,"G",'ExistCpo("CT1")',"CT1","003","S",;
	"MV_PAR02","","","","","","","","","","","","","C","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Conta Contábil receita a faturar' )

PutSx1(cPerg,"03","Ct Receita a Faturar?","Ct Receita a Faturar?","Ct Receita a Faturar?","mv_chc","C",TamSX3("CT1_CONTA")[1],0,0,"G",'ExistCpo("CT1")',"CT1","003","S",;
	"MV_PAR03","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

aHelpPor:= {}
Aadd( aHelpPor, 'Conta Contábil Glosa' )

PutSx1(cPerg,"04","Ct Contabil Glosa?","Ct Contabil Glosa?","Ct Contabil Glosa?","mv_chd","C",TamSX3("CT1_CONTA")[1],0,0,"G",'ExistCpo("CT1")',"CT1","003","S",;
	"MV_PAR04","","","","","","","","","","","","","","","","",aHelpPor,aHelpPor,aHelpPor)

Return Nil

//--< fim de arquivo >----------------------------------------------------------------------

