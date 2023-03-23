#INCLUDE "RWMAKE.CH"

/*---------------------------------------------------------
| Ponto de entrada para considerar a database do sistema   |
| para calculo da condição de pagamento                    |
|Desenvolvedor: Diogo Melo                                 |
|Data: 06/08/2019                                          |
----------------------------------------------------------*/

User Function A103VCTO

Local aVencto := {} //Array com os vencimentos e valores para geração dos títulos.
Local nY := 0

Local aPELinhas   := PARAMIXB[1]
Local nPEValor    := PARAMIXB[2]
Local cPECondicao := PARAMIXB[3]
Local nPEValIPI   := PARAMIXB[4]
Local dPEDEmissao := PARAMIXB[5]
Local nPEValSol   := PARAMIXB[6]

Local aCondNFe    := Condicao(NPEVALOR,CPECONDICAO,,DDATABASE,)

For nX := 1 to Len(aCondNFE)
    aadd(aVencto,{ACONDNFE[nX][1],ACONDNFE[nX][2]})
Next

Return aVencto