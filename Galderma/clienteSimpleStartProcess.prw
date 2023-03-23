#include "protheus.ch"
#include "Totvs.ch"

#define CRLF chr(13) + chr(10)

User Function simpleStartProcess(cPrefixo,cParcela,cTitulo,cTipo,cCodCli,cNomCli,cValor,cDtAtu, cDtVencto,cMotAprov)

    Local cTexto := ""
    Local oWSDL
    Local n      := 0

    Default cPrefixo := ""
    Default Parcela  := ""
    Default cTitulo  := ""
    Default cTipo    := ""
    Default cCodCli  := ""
    Default cNomCli  := ""
    Default cValor   := ""
    Default cDtAtu   := ""
    Default cDtVencto:= ""
    Default cMotAprov:= "Aprovado pela regra do Protheus."

//   FWAlertYesNo("Mensagem de pergunta Sim / Não", "Título FWAlertYesNo")

    oWSDL := WSECMWorkflowEngineServiceService():New()

    oWSDL:cusername         := SUPERGETMV("MV_lgFluig", .T., "diogo.melo")
    oWSDL:cpassword         := SUPERGETMV("MV_pwFluig", .T., "552324")
    oWSDL:ncompanyId        := SUPERGETMV("MV_EmpFluig", .T., 1)
    oWSDL:cprocessId        := SUPERGETMV("MV_prcFluig", .T., "AlteraTituloHodie") //solicitud de vacaciones
    oWSDL:ccomments         := SUPERGETMV("MV_cmtFluig", .T., "Solicitação inserida via WebService") // ou variavel cMotAprov
//    oWSDL:cuserId           := SUPERGETMV("MV_usrFluig", .T., "doca.melo")
    oWSDL:lcompleteTask     := .T.

    /*cardData*/
    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"empresa",cEmpAnt} //nome campo, valor

    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"venctoaltera",cDtAtu} //nome campo , valor

    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"cliente",cCodCli} //nome campo , valor

    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"prefixo",cPrefixo} //nome campo , valor

    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"titulo",cTitulo} //nome campo , valor

    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"parcela",cParcela} //nome campo , valor

    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"tipo",cTipo} //nome campo , valor

    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"nome",cNomCli} //nome campo , valor

    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"valorConvertido",cValor} //nome campo , valor

    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"venctoreal",cDtVencto} //nome campo , valor

    aAdd(oWSDL:oWSsimpleStartProcesscardData:oWSitem, WsClassNew("ECMWorkflowEngineServiceService_stringArray"))
    Atail(oWSDL:oWSsimpleStartProcesscardData:oWSitem):cItem := {"justificativa",cMotAprov} //nome campo , valor

    oWSDL:lmanagerMode := .T. //como gestor del proceso es .T.

    varinfo( "Objeto Fluig:", oWSDL )

/*startProcess(String user, String password, int companyId, String processId, int choosedState, 
String[] colleagueIds, String comments, String userId, boolean completeTask, 
ProcessAttachmentDto[] attachments, String[][] cardData, ProcessTaskAppointmentDto[] appointment, 
boolean managerMode) 
 oWSDL:startProcess( oWSDL:cusername,;
                        oWSDL:cpassword,;
                        oWSDL:ncompanyId,;
                        oWSDL:cprocessId,;
                        oWSDL:nchoosedState,;
                        oWSDL:oWSstartProcesscolleagueIds,;
                        oWSDL:ccomments,;
                        oWSDL:cuserId,;
                        oWSDL:lcompleteTask,;
                        oWSDL:oWSstartProcessattachments,;
                        oWSDL:oWSstartProcesscardData,;
                        oWSDL:oWSstartProcessappointment,;
                        oWSDL:lmanagerMode;
                         )  
/*

//#################################################################################################

/*simpleStartProcess(String user, String password, int companyId, String processId, String comments,
ProcessAttachmentDto[] attachments, String cardData[][])*/
    oWSDL:simpleStartProcess( oWSDL:cusername,;
                              oWSDL:cpassword,;
                              oWSDL:ncompanyId,;
                              oWSDL:cprocessId,;
                              oWSDL:ccomments,;
                              oWSDL:oWSsimpleStartProcessattachments,;
                              oWSDL:oWSstartProcesscardData,;
                         )
    /*              
    ConOut(WSDLDbgLevel(1))
    Conout(GETWSCERROR(1))

    ConOut(WSDLDbgLevel(2))
    Conout(GETWSCERROR(2))

    ConOut(WSDLDbgLevel(3))
    Conout(GETWSCERROR(3))        
    */
    Conout("OK - Executado!")

    If Len( OWSDL:oWSsimpleStartProcessresult:cITEM ) = 1//Erro

        Conout( OWSDL:oWSstartProcessresult:cITEM[1] + " - " + OWSDL:oWSstartProcessresult:cITEM[1]:cItem[2] )

    Else

        if len(OWSDL:oWSsimpleStartProcessresult:citem) > 0
            conout("Resposta do servidor:")
            For n := 1 to len(OWSDL:oWSsimpleStartProcessresult:citem)
                cTexto += OWSDL:oWSsimplestartProcessresult:citem[n] + CRLF
            next
            conout( cTexto )
            conout("Tarefa iniciada no Fluig")
        endif

    EndIf
    
Return
