#Include 'Protheus.ch'

/*-----------------------------------------------------------------
|Cria��o de tabela tempor�ria                                      |
|Cria a tabela tempor�ria no banco de dados para processo          |
|Desenvolvedo: Diogo Melo                                          |
|Data atualiza��o: 09/05/2019                                      |
-------------------------------------------------------------------*/

User Function FT701BTN

ateste := aclone(aRet)

aRet := { "Importar Pedidos", { || Alert('Click bot�o.')} }

Alert("Passou pelo ponto de entrada FT701BTN")

Return aRet 