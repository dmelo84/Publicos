#include "protheus.ch"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

user function xCadEmail

    Local aArea       := GetArea()
    Local cTabela     := "Z03"
    
    Private aCores    := {}
    Private cCadastro := "Cadastro de Email"
    Private aRotina   := {}
    Private cFiltro := ''
     
    //Montando o Array aRotina, com funções que serão mostradas no menu
    //aAdd(aRotina,{"Pesquisar",  "AxPesqui", 0, 1})
    aAdd(aRotina,{"Visualizar", "axVisual", 0, 4})
    aAdd(aRotina,{"Incluir",    "axInclui", 0, 3})
    aAdd(aRotina,{"Alterar",    "AxAltera", 0, 4}) 
    aAdd(aRotina,{"Excluir",    "AxDeleta", 0, 5})
 
    //Montando as cores da legenda
    aAdd(aCores,{"Z03_MSBLQ != '1' ", "BR_VERDE" })
    aAdd(aCores,{"Z03_MSBLQ == '1' ", "BR_VERMELHO" })
     
    //Selecionando a tabela e ordenando
    DbSelectArea(cTabela)
    (cTabela)->(DbSetOrder(1))
     
    //Montando o Browse
    //mBrowse(6, 1, 22, 75, cArquivo, , , , , , aCores )
    mBrowse( ,,,,cTabela,,,,,,aCores,,,,,,,,cFiltro)

    //Encerrando a rotina
    (cTabela)->(DbCloseArea())
    RestArea(aArea)
