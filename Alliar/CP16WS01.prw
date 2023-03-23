#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE 'FWMVCDEF.ch'

User Function CP16WS01()
Return

//-------------------------------------------------------------------
/*/ {REST Web Service} WEBHOOK
    Serviço webhook utilizado para recepção de eventos
    @version undefined
    @since 24/03/2020
    @author Julio Teixeira | www.compila.com.br
/*/
//-------------------------------------------------------------------
WSRESTFUL WEBHOOK DESCRIPTION "Serviço WebHook"

    WSMETHOD GET Status ; 
    DESCRIPTION "Status serviço" ;
    WSSYNTAX "/api/webhook/" ;
    PATH "/api/webhook/"

    WSMETHOD POST Main ; 
    DESCRIPTION "Recebe ocorrência webhook" ;
    WSSYNTAX "/api/webhook/" ;
    PATH "/api/webhook/"

END WSRESTFUL

/*/--------------------------------------------------------------------------/*/
WSMETHOD POST Main WSSERVICE WEBHOOK

    Local cBody as String
    Local cCatch as Character 
    Local oJson := JsonObject():New()
    Local cJRetOK := '{"code":201,"status":"success"}'
    Local aRet := {.T.,"",""}

    ::SetContentType("application/json")
    cBody := ::GetContent()
    
    If !Empty(cBody) 
        
        cCatch := oJson:FromJson(cBody)
        
        If ValType(cCatch) == "U" 

            cBody := DECODEUTF8( cBody )
            
            aRet := U_CP12ADD("000032", "", 0, cBody, )
            
            If aRet[1]
                ::SetResponse(cJRetOK)
            Else
                SetRestFault(500, "Internal server error")
            Endif
        Else          
            SetRestFault(402, "Invalid Json")
        Endif
    Else
        SetRestFault(401, "Empty body")
    Endif

    FreeObj(oJson)

Return aRet[1]

/*/--------------------------------------------------------------------------/*/
WSMETHOD GET Status WSSERVICE WEBHOOK

    Local lRet := .T.

    ::SetContentType("application/json")
    ::SetResponse('{"status":"Webhook service is running!"}')

Return lRet