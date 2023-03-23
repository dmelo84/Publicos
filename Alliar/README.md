# PROTHEUS ALLIAR 


## Parametros
_Principais parametros utilizados pelas customizações_

| PARAMETRO    | TP | DESCRICAO                                                                                                        |
|--------------|----|------------------------------------------------------------------------------------------------------------------|
| AL_APIPUSR   | C  | Login API Pleres para integração via REST                                                                        |
| AL_APIPPAS   | C  | Senha API Pleres para integração via REST                                                                        |
| AL_APIPLER   | C  | URL API Pleres para integração via REST                                                                          |
| AL_APIPDOM   | C  | DOMINIO da filial correspondente no Pleres para integração via REST                                              |
| AL_TAMCOMP   | N  | Tamanho máximo do campo Complemento para geração do XML das NFS-e







# Contabilização das Provisões

Obtem PDF Notas Fiscais Municipais

## MENU | Contabilidade Gerencial
- MESCELANEA
- - ESPECIFICO
- - - [ALCTB001] - Contabilização Provisões


## FONTES
| FONTE         | DESCRICAO                                                                         |
|---------------|-----------------------------------------------------------------------------------|
| ALCTB001.PRW  | Cadastro das provisões contábeis                                                  |  
| ALWSI001.PRW  | Webservices intgracao fluig                                                       |
| FSIntCad.prw  | Gravacao da pre-nota                                                              |



## TABELAS
| TABELA | DESCRICAO                                                                         |
|--------|-----------------------------------------------------------------------------------|
| SZB    | Cadastro das provisões contábeis                                                  |    



## DICIONARIO
| CAMPO        | TP | TAM | DEC | TITULO        | DESCRICAO               |
|--------------|----|-----|-----|---------------|-------------------------|
| F1_XCOMPET   | C  | 6   | 0   | Arq. PDF. NF  | Arquivo PDF Nota Fiscal |
| F1_XMULTCP   | C  | 1   | 0   | Multiplas Comp| Multiplas Competencias  |  

