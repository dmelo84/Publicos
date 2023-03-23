#Include 'Protheus.ch'

User Function M410VCT()

Local aDupl     := PARAMIXB[1]  //Array com as duplicatas
Local nTotFat   := PARAMIXB[2]  //Valor total da fatura

Alert("Parou")

aDupl[1][1] := CtoD("02/06/2016")   //Data de vencimento
aDupl[1][2] := TransForm(50.55,PesqPict("SE1","E1_VALOR"))  //Valor da duplicata

Return aDupl