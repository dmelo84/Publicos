#Include 'Protheus.ch'

/*-----------------------------------------------------------------
|Criação de tabela temporária                                      |
|Cria a tabela temporária no banco de dados para processo          |
|Desenvolvedo: Diogo Melo                                          |
|Data atualização: 09/05/2019                                      |
-------------------------------------------------------------------*/

User Function FT701BTN

ateste := aclone(aRet)

aRet := { "Importar Pedidos", { || Alert('Click botão.')} }

Alert("Passou pelo ponto de entrada FT701BTN")

Return aRet 