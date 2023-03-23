#Include 'Protheus.ch'
#Include 'RestFul.CH'


User Function WSR_MARCA_EMPRESA()
Return


WSRESTFUL MARCA_EMPRESA DESCRIPTION "Serviço REST retorna Marca das Empresas"


WSMETHOD GET DESCRIPTION "Retorna todas as marcas do grupo de empresa " WSSYNTAX "/MARCA_EMPRESA"


END WSRESTFUL



WSMETHOD GET  WSSERVICE MARCA_EMPRESA
Local cJson := ""



::SetContentType("application/json")


cJson += '{'
cJson += '    "MARCAS":['
cJson += '        {"COD":"001",'
cJson += '        "DESC":"AXIAL"},'
cJson += '        {"COD":"002",'
cJson += '        "DESC":"CDB"},'
cJson += '        {"COD":"003",'
cJson += '        "DESC":"CEDIMAGEM"},'
cJson += '        {"COD":"004",'
cJson += '        "DESC":"PLANI"},'
cJson += '        {"COD":"005",'
cJson += '        "DESC":"CO DI IMAGEM"},'
cJson += '        {"COD":"006",'
cJson += '        "DESC":"CSD SOM"},'
cJson += '        {"COD":"007",'
cJson += '        "DESC":"UMDI"},'
cJson += '        {"COD":"008",'
cJson += '        "DESC":"CDI"},'
cJson += '        {"COD":"009",'
cJson += '        "DESC":"SABEDOTTI"},'
cJson += '        {"COD":"010",'
cJson += '        "DESC":"GOLDIMAGEM"},'
cJson += '        {"COD":"011",'
cJson += '        "DESC":"SJT"},'
cJson += '        {"COD":"012",'
cJson += '        "DESC":"PROIMAGEM"},'
cJson += '        {"COD":"013",'
cJson += '        "DESC":"ECOCLINICA"},'
cJson += '        {"COD":"014",'
cJson += '        "DESC":"NUCLEAR"},'
cJson += '        {"COD":"015",'
cJson += '        "DESC":"RDB"},'
cJson += '        {"COD":"016",'
cJson += '        "DESC":"IMRAD"},'
cJson += '        {"COD":"017",'
cJson += '        "DESC":"DELFIN"},'
cJson += '        {"COD":"018",'
cJson += '        "DESC":"IDR"},'
cJson += '        {"COD":"019",'
cJson += '        "DESC":"ALIANCA"}'
cJson += '    ]'
cJson += '}'


::SetResponse(cJson)


Return(.T.)
