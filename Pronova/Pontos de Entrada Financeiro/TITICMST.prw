#INCLUDE "Protheus.ch"
                        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Empresa  ³ AKRON Projetos e Sistemas                                  ³±±
±±³          ³ Av. Celso Garcia, 3977 - Tatuape - Sao Paulo - SP - Brasil ³±±
±±³          ³ Fone: +55 11 3853-6470                                     ³±±
±±³          ³ Site: www.akronbr.com.br     e-mail: akron@akronbr.com.br  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Funcao   ³ TITICMST   ³ Autor ³ Gesivaldo Leite     ³ Data ³07/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ponto de entrada para alterar F6_NUMERO e F6_VENCTO        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TITICMST(PE)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Akron                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function TITICMST()          

Local cTipoImp := PARAMIXB[2]

IF SD2->D2_FILIAL='02' .AND. SD2->D2_TES='847'
    SE2->E2_NUM := SF2->F2_DOC

//If AllTrim(cTipoImp)='1' // ICMS ST
//  SE2->E2_NUM := SF2->F2_DOC
    
EndIf



/*TOTVS
User Function TITICMST
Local cOrigem := PARAMIXB[1]
Local cTipoImp := PARAMIXB[2]
Local lDifal := PARAMIXB[3]
 
//EXEMPLO 1 (cOrigem)
If AllTrim(cOrigem)='MATA954' //Apuracao de ISS
    SE2->E2_NUM := SE2->(Soma1(E2_NUM,Len(E2_NUM)))
    SE2->E2_VENCTO := DataValida(dDataBase+30,.T.)
    SE2->E2_VENCREA := DataValida(dDataBase+30,.T.)
    SE2->E2_NATUREZ := 'EXEMPLO1'
EndIf
 
//EXEMPLO 2 (cTipoImp)
If AllTrim(cTipoImp)='1' // ICMS ST
    SE2->E2_NUM := SE2->(Soma1(E2_NUM,Len(E2_NUM)))
    SE2->E2_VENCTO := DataValida(dDataBase+30,.T.)
    SE2->E2_VENCREA := DataValida(dDataBase+30,.T.)
    SE2->E2_NATUREZ := 'EXEMPLO2'
EndIf
 
//EXEMPLO 3 (lDifal)
If lDifal // DIFAL
    SE2->E2_NUM := SE2->(Soma1(E2_NUM,Len(E2_NUM)))
    SE2->E2_VENCTO := DataValida(dDataBase+30,.T.)
    SE2->E2_VENCREA := DataValida(dDataBase+30,.T.)
    SE2->E2_NATUREZ := 'EXEMPLO3'
EndIf
 
Return {SE2->E2_NUM,SE2->E2_VENCTO}

*/

//SE2->E2_VENCREA := DDatabase + 1  
//SE2->E2_VENCTO := DDatabase + 1  
//SE2->E2_VENCORI := DDatabase + 1  
// Inserido PE para que o titulo do icms st na se2 seja gerado com mesmo numero do titulo princial, ou seja, SF2->F2_DOC, essa ação visa atender chamado da Luciana do financeiro Pronova - feito em 26/10/2020 - claudio duarte
//SE2->E2_NUM := SF2->F2_DOC


Return
