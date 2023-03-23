#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºStarData - B.Machado + C.duarte  º Data ³  13/05/2020				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ POSIÇÃO FORNECEDOR.			     				          º±±
±±º          ³ Imprime todos titulos                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Pronova                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
	
User Function FC030CON()


	/*cArq1->FILORIG
	cArq1->PREFIXO
	cArq1->NUMERO
	cArq1->PARCELA
	cArq1->TIPO
	cArq1->EMISSAO
	cArq1->NATUREZA			
	cArq1->SALDOPAGAR
	cArq1->DATAVENC 
	cArq1->ATRASO      
	cArq1->VALORJUROS  
	cArq1->ACRESCIMO   
	cArq1->DECRESCIMO  
	cArq1->VLR_IR	
	cArq1->VLR_ISS	
	cArq1->VLR_INSS			
	cArq1->NUMBCO	
	cArq1->HISTORICO*/
 	Local _aArea := GetArea("cArq1")
    _nCount := 0

    DbSelectArea("cArq1")
    DbGoTop("cArq1")
    Do While cArq1->(!EOF())
        _nCount++
        cArq1->(DbSkip())
    EndDo
   // MsgInfo("Qtd.Titulos em Aberto: "+Alltrim(Str(_nCount)))
   reldefip()
   
Return()


Static Function reldefip()
Local Lret := .T.
//SetPrvt(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho,,.T.)

//cPerg           := Padr("reldefin",len(SX1->X1_GRUPO)," ") =>comentei
cDesc1          := "POSIÇÃO FORNECEDOR"
cDesc2          := "Imprime todos titulos "
cDesc3          := "Imprime todos titulos "
cPict           := ""
tamanho         := "G"
nomeprog        := "reldefip" //  impressao no cabecalho	=>comentei
aReturn         := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
titulo          := "POSIÇÃO FORNECEDOR"
nLin            := 80
Cabec2          := ""
Cabec1          := ""
wnrel           := "reldefip" //nome para impressao em disco
cString         := "SE5"					
nTipo           := 15       // usado na função bNewPage
m_pag           := 01       // Inicio pagina
cQuery          := ""
cPath           := ""
cMontaTxt       := ""
cQueryP         := ""
cOrdem          := ""
nNum 			:= ""
Private cPerg   := "reldefip"					


// Neste relatorio serão impressos todos os bens,
//por isso este pergunte é somente um exemplo ilustrativo,
//ou seja, não esta sendo utilizado realmente
//ValidPerg()
//Pergunte(cPerg,.F.)

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

//Inicializa os codigos de caracter da impressora
nTipo := IIF(aReturn[4]==1,15,18)

// RPTSTATUS monta janela com a regua de processamento.
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return (Lret)


//////////////////////////////////////////////////////////////////////////
// RunReport: Monta o relatorio
//////////////////////////////////////////////////////////////////////////
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,cPath)


// Bloco de código executado para inserir nova página
bNewPage := {|| Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo), nLin:=9}

//01234567890123456789012345678901234567890
//0         1      10      18       3         4
// 999999xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Cabec1 := "PREFIXO     NUMERO  PARCELA    TIPO   EMISSAO   NATUREZA    SALDOPAGAR   DATAVENC   ATRASO    VALORJUROS    ACRESCIMO   DECRESCIMO     VLR_IR    VLR_ISS   VLR_INSS    NUMBCO        HISTOR     "
cMontaTxt += "PREFIXO;NUMERO; PARCELA;TIPO;EMISSAO;NATUREZA;SALDOPAGAR;DATAVENC;ATRASO;VALORJUROS;ACRESCIMO;DECRESCIMO;VLR_IR;VLR_ISS;VLR_INSS;NUMBCO;HISTOR " + CRLF
// Exemplo de query para consulta ao bancoTIPO DE RECEBIMENTO



// Seleção da tabela temporaria criada pela consulta
DbSelectArea("cArq1")
cArq1->(DbGotop())

While cArq1->(!Eof())
	
	// Salto de Página
	IIF(nLin > 70, EVAL(bNewPage),)
	                                                                                                          
	// imprime na visualizaçao do relatorio
	//@nlin, 001 PSAY cArq1->FILORIG
	@nlin, 003 PSAY cArq1->PREFIXO
	@nlin, 010 PSAY cArq1->NUMERO
	@nlin, 022 PSAY cArq1->PARCELA
	@nlin, 031 PSAY cArq1->TIPO
	@nlin, 037 PSAY cArq1->EMISSAO
	@nlin, 049 PSAY cArq1->NATUREZA	
   	@nlin, 058 PSAY cArq1->SALDOPAGAR
   	@nlin, 072 PSAY cArq1->DATAVENC 
  	@nlin, 085 PSAY cArq1->ATRASO 
   	@nlin, 098 PSAY cArq1->VALORJUROS  
  	@nlin, 110 PSAY cArq1->ACRESCIMO
  	@nlin, 124 PSAY cArq1->DECRESCIMO  
   	@nlin, 137 PSAY cArq1->VLR_IR	
   	@nlin, 147 PSAY cArq1->VLR_ISS	
  	@nlin, 157 PSAY cArq1->VLR_INSS
 	@nlin, 161 PSAY cArq1->NUMBCO	
   	@nlin, 170 PSAY cArq1->HISTORICO
	
	
	nLin++ // soma mais uma linha
	
	// guarda informação em string para gravar o arquivo .csv
	//cMontaTxt += cArq1->FILORIG                  	   				  + ";"
	cMontaTxt += cArq1->PREFIXO             					      + ";"
	cMontaTxt += cArq1->NUMERO		           						  + ";"
	cMontaTxt += cArq1->PARCELA                 					  + ";"
	cMontaTxt += cArq1->TIPO                 					      + ";"
	cMontaTxt += DTOC( cArq1->EMISSAO)      					      + ";"
	cMontaTxt += cArq1->NATUREZA	           						  + ";"
	cMontaTxt += transform(cArq1->SALDOPAGAR,"@E 999,999,999.99")     + ";"
	cMontaTxt += DTOC(cArq1->DATAVENC)         					      + ";"
	cMontaTxt += cValToChar(cArq1->ATRASO)         	      	          + ";"
	cMontaTxt += transform(cArq1->VALORJUROS,"@E 999,999,999.99")     + ";"
	cMontaTxt += transform(cArq1->ACRESCIMO,"@E 999,999,999.99")      + ";"
    cMontaTxt += transform(cArq1->DECRESCIMO,"@E 999,999,999.99")     + ";"
	cMontaTxt += transform(cArq1->VLR_IR,"@E 999,999,999.99")         + ";"
	cMontaTxt += transform(cArq1->VLR_ISS,"@E 999,999,999.99")        + ";"
	cMontaTxt += transform(cArq1->VLR_INSS,"@E 999,999,999.99")	      + ";"
	cMontaTxt += cArq1->NUMBCO              					      + ";"
	cMontaTxt += cArq1->HISTORICO            						  + ";"
	
	
	cMontaTxt += CRLF // Salto de linha para .csv (excel)
	cArq1->(dbSkip())   // próxima linha
	
Enddo

//dbCloseArea("cArq1") // finaliza seleção da area

MS_FLUSH()
cArq1->(DbGotop())

// Chama a função que gera o arquivo csv com os dados.
criaCSV()


// Finaliza a execucao do relatorio...
SET DEVICE TO SCREEN

// Se impressao em disco, chama o gerenciador de impressao...
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel) // gerenciador de impressão do Siga
Endif

//Descarrega spool de impressão.
//Após os comandos de impressão as informações ficam armazenadas no
//spool e são descarregadas em seus destinos através da função  Ms_Flush()

Return()
///////////////////////////////////////////////////////////////////////
// Exportando dados para planilha
////////////////////////////////////////////////////////////////////////
Static Function criaCSV()

// Nome do arquivo criado, o nome é composto por uma descrição
//a data e a hora da criação, para que não existam nomes iguais
cNomeArq := "C:\relato\relatorio_"+DtoS(dDataBase)+StrTran(Time(),":","")+".csv"

// criar arquivo texto vazio a partir do root path no servidor
nHandle := FCREATE(cNomeArq)

FWrite(nHandle,cMontaTxt)

// encerra gravação no arquivo
FClose(nHandle)

MsgAlert("Relatorio salvo em: "+"C:\relato\relatorio_"+DtoS(dDataBase)+StrTran(Time(),":","")+".csv")

Return()

