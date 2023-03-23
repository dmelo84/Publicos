# PROTHEUS ALLIAR 


## Parametros
_Principais parametros utilizados pelas customiza��es_

| PARAMETRO    | TP | DESCRICAO                                                                                                        |
|--------------|----|------------------------------------------------------------------------------------------------------------------|
| AL_APIPUSR   | C  | Login API Pleres para integra��o via REST                                                                        |
| AL_APIPPAS   | C  | Senha API Pleres para integra��o via REST                                                                        |
| AL_APIPLER   | C  | URL API Pleres para integra��o via REST                                                                          |
| AL_APIPDOM   | C  | DOMINIO da filial correspondente no Pleres para integra��o via REST                                              |
| AL_TAMCOMP   | N  | Tamanho m�ximo do campo Complemento para gera��o do XML das NFS-e







# Contabiliza��o das Provis�es

Obtem PDF Notas Fiscais Municipais

## MENU | Contabilidade Gerencial
- MESCELANEA
- - ESPECIFICO
- - - [ALCTB001] - Contabiliza��o Provis�es


## FONTES
| FONTE         | DESCRICAO                                                                         |
|---------------|-----------------------------------------------------------------------------------|
| ALCTB001.PRW  | Cadastro das provis�es cont�beis                                                  |  
| ALWSI001.PRW  | Webservices intgracao fluig                                                       |
| FSIntCad.prw  | Gravacao da pre-nota                                                              |



## TABELAS
| TABELA | DESCRICAO                                                                         |
|--------|-----------------------------------------------------------------------------------|
| SZB    | Cadastro das provis�es cont�beis                                                  |    



## DICIONARIO
| CAMPO        | TP | TAM | DEC | TITULO        | DESCRICAO               |
|--------------|----|-----|-----|---------------|-------------------------|
| F1_XCOMPET   | C  | 6   | 0   | Arq. PDF. NF  | Arquivo PDF Nota Fiscal |
| F1_XMULTCP   | C  | 1   | 0   | Multiplas Comp| Multiplas Competencias  |  

