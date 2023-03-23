#include "protheus.ch"
#include "parmtype.ch"
 
/*/{Protheus.doc} ITEM
//TODO PRODUTO MVC
@author Mauro Nagata | www.compila.com.br
@since 20/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ITEM()
    Local aParam		:= PARAMIXB
    Local xRet 			:= .T.
    Local oObj 			:= ""
    Local cIdPonto 		:= ""
    Local cIdModel 		:= ""
    Local lIsGrid 		:= .F.
    Local nLinha 		:= 0
    Local nQtdLinhas 	:= 0
    Local cMsg 			:= ""
    Local nOper			:= 0
 
    If aParam <> NIL
        oObj 		:= aParam[1]
        cIdPonto 	:= aParam[2]
        cIdModel 	:= aParam[3]
        lIsGrid 	:= (Len(aParam) > 3)
 
        If cIdPonto == "MODELPOS"
            /*
            cMsg := "Chamada na validação total do modelo." + CRLF
            cMsg += "ID " + cIdModel + CRLF
 
            xRet := ApMsgYesNo(cMsg + "Continua?")
            */
            
        ElseIf cIdPonto == "FORMPOS"
            /*
            cMsg := "Chamada na validação total do formulário." + CRLF
            cMsg += "ID " + cIdModel + CRLF
 
            If lIsGrid
                cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
            Else
                cMsg += "É um FORMFIELD" + CRLF
            EndIf
 
            xRet := ApMsgYesNo(cMsg + "Continua?")
            */
            
        ElseIf cIdPonto == "FORMLINEPRE"
        	/*
            If aParam[5] == "DELETE"
                cMsg := "Chamada na pré validação da linha do formulário. " + CRLF
                cMsg += "Onde esta se tentando deletar a linha" + CRLF
                cMsg += "ID " + cIdModel + CRLF
                cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
                xRet := ApMsgYesNo(cMsg + " Continua?")
            EndIf
            */
 
        ElseIf cIdPonto == "FORMLINEPOS"
            /*
            cMsg := "Chamada na validação da linha do formulário." + CRLF
            cMsg += "ID " + cIdModel + CRLF
            cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
            cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
            xRet := ApMsgYesNo(cMsg + " Continua?")
            */
            
        ElseIf cIdPonto == "MODELCOMMITTTS"        	//ApMsgInfo("Chamada após a gravação total do modelo e dentro da transação.")
            
        ElseIf cIdPonto == "MODELCOMMITNTTS"		//ApMsgInfo("Chamada após a gravação total do modelo e fora da transação.")
            
            //incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200430]
            //registrar classe de valor
            nOper := oObj:nOperation
    
            If nOper = 3
	            DbSelectArea("CTH")
	            RecLock( "CTH",  !DbSeek( xFilial( "CTH" ) + SB1->B1_COD ) ) 
	            
	            CTH->CTH_CLVL 	:= SB1->B1_COD
				CTH->CTH_CLASSE := "2" 				//(ANALITICA)
				CTH->CTH_DESC01 := SB1->B1_DESC		
				CTH->CTH_ACATIV := "1" 				//(SIM)
				CTH->CTH_ATOBRG := "2" 				//(NÃO)
				
				CTH->(MsUnLock())
			EndIf
			//fim bloco [Mauro Nagata, www.compila.com.br, 20200430]			
 
        ElseIf cIdPonto == "FORMCOMMITTTSPRE"
            //ApMsgInfo("Chamada antes a gravação da tabela do formulário.")
 
        ElseIf cIdPonto == "FORMCOMMITTTSPOS"
        	/*
            //ApMsgInfo("Chamada após a gravação da tabela do formulário.")
            Parâmetros Recebidos:
			
			1 O Objeto do formulário ou do modelo, conforme o caso
			2 C ID do local de execução do ponto de entrada
			3 C ID do formulário
			4 L Se .T. indica novo registro (Inclusão) se .F. registro já existente (Alteração / Exclusão)
			*/
 
        ElseIf cIdPonto == "MODELCANCEL"
            //cMsg := "Deseja realmente sair?"
            //xRet := ApMsgYesNo(cMsg)
 
        ElseIf cIdPonto == "BUTTONBAR"
           // xRet := {{"Salvar", "SALVAR", {||u_TSMT010()}}}
        EndIf
    EndIf
Return xRet

/* 
User Function TSMT010()
    Alert("Buttonbar")
Return NIL
*/