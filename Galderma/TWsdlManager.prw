#include "protheus.ch"
#include "Totvs.ch"

User Function wsStartProcess()
  Local oWsdl
  Local xRet
  Local aOps := {}, aComplex := {}, aSimple := {}
  Local aParents := {}, aValues := {}
//  Local nCampo := 3
  Local n := 0
//  Local nCount:=0
  Local aAnexo := {}
  Local oRetECM
  
  // CRIA O OBJETO DA CLASSE TWSDLMANAGER
  oWsdl := TWsdlManager():New()
   
  // SETA O MODO DE TRABALHO DA CLASSE PARA "VERBOSE"
  oWsdl:lVerbose := .T.
  
  // FAZ O PARSE DE UMA URL
  conOut("realizando parse de url...")
  xRet:= oWsdl:ParseURL( "http://localhost:8080/webdesk/ECMWorkflowEngineService?wsdl" )
  oRetECM := WSECMWorkflowEngineServiceService():New()
  if xRet== .F.
    conOut("realizando parse de url... erro: " + oWsdl:cError)
    Return
  else
    conOut("realizando parse de url... feito")
  endif
  conOut(chr(10) + chr(10))
 
  // LISTA AS OPERACÕES DISPONIVEIS
  conOut("listando as operacões disponiveis...")
  aOps := oWsdl:ListOperations()
  if Len( aOps ) == 0
    conOut("listando as operacões disponiveis... erro: " + oWsdl:cError)
    Return
  else
    varinfo( "aOps", aOps )
    conOut("listando as operacões disponiveis... feito")
  endif
  conOut(chr(10) + chr(10))
  
  //Variavel que retorna o metodo
  nPos := aScan( aOps, {|aVet| aVet[1] == "startProcess"})
    If nPos > 0
        // DEFINE UMA OPERACAO
        conOut("  setando operacao "+aOps[nPos][1]+"...")
        xRet:= oWsdl:SetOperation( aOps[nPos][1] )
        if xRet== .F.
            conOut("  setando operacao"+aOps[nPos][1]+"..."+" erro:" + oWsdl:cError)
            Return
        else
            conOut("Operacao startProcess... feita")
        endif
        conOut(chr(10) + chr(10))
    endIf
 
  // LISTA OS ELEMENTOS COMPLEXOS DA OPERACAO
  conOut("listando elementos complexos da operacao...")
  aComplex := oWsdl:NextComplex()
  varinfo( "aComplex", aComplex )
  conOut("   listando elementos complexos da operacao... feito")
  conOut(chr(10) + chr(10))
 
  // LISTA OS ELEMENTOS SIMPLES DA OPERACAO
  conOut("listando elementos simples da operacao...")
  aSimple := oWsdl:SimpleInput()
  varinfo( "aSimple", aSimple )
  conOut("listando elementos simples da operacao... feito")
  conOut(chr(10) + chr(10))

  //Pegar todos os itens com "attachments#1.item#1"
    for n:= 1 to len(aSimple)
      if aSimple[n][5] == "attachments#1.item#1"
        aAdd(aAnexo,aSimple[n])
      endif
    next
  //Insere valor nas tag's de cabeçalho e Body
  For nx := 1 to len(aSimple)
    do case
        case aSimple[nx][2] == "username"
                lRetSimple := oWsdl:SetValue( aSimple[nx][1], "diogo.melo" )
        case aSimple[nx][2] == "password"
                lRetSimple := oWsdl:SetValue( aSimple[nx][1], "552324" )
        case aSimple[nx][2] == "companyId"
                lRetSimple := oWsdl:SetValue( aSimple[nx][1], "1" )
        case aSimple[nx][2] == "processId"
                lRetSimple := oWsdl:SetValue( aSimple[nx][1], "cadastroCliente" )
        case aSimple[nx][2] == "choosedState"
                lRetSimple := oWsdl:SetValue( aSimple[nx][1], "5" )
        case aSimple[nx][2] == "comments"
                lRetSimple := oWsdl:SetValue( aSimple[nx][1], "Processo Iniciado via WebService" )
        case aSimple[nx][2] == "userId"
                lRetSimple := oWsdl:SetValue( aSimple[nx][1], "diogo.melo" )
        case aSimple[nx][2] == "completeTask"
                lRetSimple := oWsdl:SetValue( aSimple[nx][1], "false" )
        case aSimple[nx][2] == "attachmentSequence"
                lRetSimple := oWsdl:SetValue( aSimple[nx][1], "0" )
                //Seta valor para cada item encontrado no "attachments#1.item#1"
                for n := 1 to len(aAnexo)
                  do case
                    case aAnexo[n][2] == "attach"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "false" )
                    case aAnexo[n][2] == "filecontent"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "padrao.pdf" )
                    case aAnexo[n][2] == "mobile"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "true" )
                    case aAnexo[n][2] == "fileSize"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "0" )
                    case aAnexo[n][2] == "principal"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "true" )
                    case aAnexo[n][2] == "companyId"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "1" )
                    case aAnexo[n][2] == "processInstanceId"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "0" )
                    case aAnexo[n][2] == "size"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "0" )
                    case aAnexo[n][2] == "description"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "padrao" )
                    case aAnexo[n][2] == "fileName"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "padrao.pdf" )
                    case aAnexo[n][2] == "companyId"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "1" )
                    case aAnexo[n][2] == "processInstanceId"
                            lRetSimple := oWsdl:SetValue( aAnexo[n][1], "0" )
                  end case
                next
        case aSimple [nX][2] == "item" .and. aSimple [nX][5] == "cardData#1.item#1"
                //Define os elementos pai
        //        aParents := {"cardData#1","item#1"}
                // Define o valor de cada parâmeto necessário
        //        aAdd( aValues, '{"filtroCPF":"06368129603"}' )
                //aAdd( aValues, "06368129603")
        //        xRet := oWsdl:SetValParArray( "item", aParents, aValues )
        //        if xRet == .F.
        //            conout( "Erro: " + oWsdl:cError )
        //          Return
        //        endif /*
                lRetSimple := oWsdl:SetValue( aSimple[n][1], '{"empresa":"99"}' ) 
        /*        lRetSimple := oWsdl:SetValue( aSimple[n][1], "99" )
                lRetSimple := oWsdl:SetValue( aSimple[n][1], "selecionaLayer" ) 
                lRetSimple := oWsdl:SetValue( aSimple[n][1], "1" )
                lRetSimple := oWsdl:SetValue( aSimple[n][1], "filtroCPF" ) 
                lRetSimple := oWsdl:SetValue( aSimple[n][1], "06368129603" ) */ 
        case aSimple [nx][2] == "managerMode"
                lRetSimple := oWsdl:SetValue( aSimple[nx][1], "false" )         
    end case
  next
    
  // SETA QUANTAS VEZES O ELEMENTO COMPLEXO APARECERÁ
    conOut("setando ocorrencias de elemento complexo...")
    while ValType( aComplex ) == "A"
      if ( aComplex[2] == "item" ) .And. ( aComplex[5] == "attachments#1" )
        occurs := 3 // o objeto complexo aparecerá 3 vezes para os 3 campos do formulário
        n2 := occurs
      else
        occurs := 0
      endif
      xRet:= oWsdl:SetComplexOccurs( aComplex[1], occurs )
      if xRet== .F.
        conout( "setando ocorrencias de elemento complexo... erro: erro ao definir elemento " + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", com " + cValToChar( occurs ) + " ocorrencias" )
        return
      endif
      aComplex := oWsdl:NextComplex()
    enddo
  conOut("   setando ocorrencias de elemento complexo... feito")
  conOut(chr(10) + chr(10))
   
  // RECEBE E IMPRIME A MENSAGEM FORMATADA PARA ENVIO
  conOut("pegando mensagem formatada para envio...")
  conout( oWsdl:GetSoapMsg() )
  conOut("pegando mensagem formatada para envio... feito")
  // Pega a mensagem de resposta parseada
  conout( oWsdl:GetParsedResponse() )
  conOut(chr(10) + chr(10))
 
  // ENVIA A MENSAGEM PARA O SERVIDOR
  conOut("   enviando mensagem para o servidor...")
  xRet:= oWsdl:SendSoapMsg()
  if xRet== .F.
    conOut("   enviando mensagem para o servidor... erro: " + oWsdl:cError )
    Return
  else
    conOut("   enviando mensagem para o servidor... feito")
  endif
  conOut(chr(10) + chr(10))
 
 
  // RECEBE A MENSAGEM DE RESPOSTA
  conOut("   pegando a mensagem de resposta do servidor...")
  conout( oWsdl:GetSoapResponse() )
  conOut("   pegando a mensagem de resposta do servidor... feito")
  conOut(chr(10) + chr(10))
 
 /*
  // DEFINE UMA OPERACAO
  conOut("  setando operacao INSERECONTATOS...")
  xRet:= oWsdl:SetOperation( "INSERECONTATOS" )
  if xRet== .F.
    conOut("  setando operacao INSERECONTATOS... erro: " + oWsdl:cError)
    Return
  else
    conOut("  setando operacao INSERECONTATOS... feito")
  endif
  conOut(chr(10) + chr(10))
 
 
  // LISTA OS ELEMENTOS COMPLEXOS DA OPERACAO
  conOut("   listando elementos complexos da operacao...")
  aComplex := oWsdl:NextComplex()
  varinfo( "aComplex", aComplex )
  conOut("   listando elementos complexos da operacao... feito")
  conOut(chr(10) + chr(10))
 
 
  // SETA QUANTAS VEZES O ELEMENTO COMPLEXO APARECERÁ
  conOut("   setando ocorrencias de elemento complexo...")
  while ValType( aComplex ) == "A"
    if ( aComplex[2] == "CONTATO" ) .And. ( aComplex[5] == "INSERECONTATOS#1._DADOS#1.REGISTROS#1" )
      occurs := 2 // o objeto complexo aparecerá 2 vezes
    else
      occurs := 0
    endif
    xRet:= oWsdl:SetComplexOccurs( aComplex[1], occurs )
    if xRet== .F.
      conout( "   setando ocorrencias de elemento complexo... erro: erro ao definir elemento " + aComplex[2] + ", ID " + cValToChar( aComplex[1] ) + ", com " + cValToChar( occurs ) + " ocorrencias" )
      return
    endif
    aComplex := oWsdl:NextComplex()
  enddo
  conOut("   setando ocorrencias de elemento complexo... feito")
  conOut(chr(10) + chr(10))
 */
  // LISTA OS ELEMENTOS SIMPLES DA OPERACAO
  conOut("   listando elementos simples da operacao...")
  aSimple := oWsdl:SimpleInput()
  varinfo( "aSimple", aSimple )
  conOut("   listando elementos simples da operacao... feito")
  conOut(chr(10) + chr(10))
 
  // SETA OS VALORES DOS ELEMENTOS SIMPLES
  /* 
    cada elemento complexo do nosso exemplo (contato) possui dois elementos simples (nome e telefone);
    No nosso exemplo temos 2 elementos complexos, então temos que setar 4 elementos simples
    setamos cada elemento simples sequencialmente:
      registro 1 propridade 1 do exemplo
      registro 1 propridade 2 do exemplo
      registro 2 propridade 1 do exemplo
      registro 2 propridade 2 do exemplo
  */
  /*
  conOut("   localizando posicao do ID e definindo valor da propriedade...")
  nPos := aScan( aSimple, {|aVet| aVet[2] == "NOME" .AND. aVet[5] == "INSERECONTATOS#1._DADOS#1.REGISTROS#1.CONTATO#1" })
  conOut("      ID: " + cValToChar(nPos) + " | PROPRIEDADE: " + cValToChar(aSimple[nPos][2]))
  xRet := oWsdl:SetValue( aSimple[nPos][1], "Ciclano" )
  nPos := aScan( aSimple, {|aVet| aVet[2] == "TELEFONE" .AND. aVet[5] == "INSERECONTATOS#1._DADOS#1.REGISTROS#1.CONTATO#1" })
  conOut("      ID: " + cValToChar(nPos) + " | PROPRIEDADE: " + cValToChar(aSimple[nPos][2]))
  xRet := oWsdl:SetValue( aSimple[nPos][1], "98765" )
  nPos := aScan( aSimple, {|aVet| aVet[2] == "NOME" .AND. aVet[5] == "INSERECONTATOS#1._DADOS#1.REGISTROS#1.CONTATO#2" })
  conOut("      ID: " + cValToChar(nPos) + " | PROPRIEDADE: " + cValToChar(aSimple[nPos][2]))
  xRet := oWsdl:SetValue( aSimple[nPos][1], "Beltrano" )
  nPos := aScan( aSimple, {|aVet| aVet[2] == "TELEFONE" .AND. aVet[5] == "INSERECONTATOS#1._DADOS#1.REGISTROS#1.CONTATO#2" })
  conOut("      ID: " + cValToChar(nPos) + " | PROPRIEDADE: " + cValToChar(aSimple[nPos][2]))
  xRet := oWsdl:SetValue( aSimple[nPos][1], "912345" )
  conOut("   localizando posicao do ID e definindo valor da propriedade... feito")
  conOut(chr(10) + chr(10))
 
  // EXIBE A MENSAGEM QUE SERÁ ENVIADA
  conOut("   pegando mensagem formatada para envio...")
  conout( oWsdl:GetSoapMsg() )
  conOut("   pegando mensagem formatada para envio... feito")
  conOut(chr(10) + chr(10))
 
 
  // ENVIA A MENSAGEM SOAP AO SERVIDOR
  conOut("   enviando mensagem para o servidor...")
  xRet:= oWsdl:SendSoapMsg()
  if xRet== .F.
    conout(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    conOut("   enviando mensagem para o servidor... erro: " + oWsdl:cError )
    Return
  else
    conOut("   enviando mensagem para o servidor... feito")
  endif
  conOut(chr(10) + chr(10))
 
 
  // PEGA A MENSAGEM DE RESPOSTA
  conOut("   pegando a mensagem de resposta do servidor...")
  conout( oWsdl:GetSoapResponse() )
  conOut("   pegando a mensagem de resposta do servidor... feito")
  conOut(chr(10) + chr(10))
 */
Return

