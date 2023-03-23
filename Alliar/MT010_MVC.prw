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
            cMsg := "Chamada na valida��o total do modelo." + CRLF
            cMsg += "ID " + cIdModel + CRLF
 
            xRet := ApMsgYesNo(cMsg + "Continua?")
            */
            
        ElseIf cIdPonto == "FORMPOS"
            /*
            cMsg := "Chamada na valida��o total do formul�rio." + CRLF
            cMsg += "ID " + cIdModel + CRLF
 
            If lIsGrid
                cMsg += "� um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
            Else
                cMsg += "� um FORMFIELD" + CRLF
            EndIf
 
            xRet := ApMsgYesNo(cMsg + "Continua?")
            */
            
        ElseIf cIdPonto == "FORMLINEPRE"
        	/*
            If aParam[5] == "DELETE"
                cMsg := "Chamada na pr� valida��o da linha do formul�rio. " + CRLF
                cMsg += "Onde esta se tentando deletar a linha" + CRLF
                cMsg += "ID " + cIdModel + CRLF
                cMsg += "� um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
                cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
                xRet := ApMsgYesNo(cMsg + " Continua?")
            EndIf
            */
 
        ElseIf cIdPonto == "FORMLINEPOS"
            /*
            cMsg := "Chamada na valida��o da linha do formul�rio." + CRLF
            cMsg += "ID " + cIdModel + CRLF
            cMsg += "� um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
            cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
            xRet := ApMsgYesNo(cMsg + " Continua?")
            */
            
        ElseIf cIdPonto == "MODELCOMMITTTS"        	//ApMsgInfo("Chamada ap�s a grava��o total do modelo e dentro da transa��o.")
            
        ElseIf cIdPonto == "MODELCOMMITNTTS"		//ApMsgInfo("Chamada ap�s a grava��o total do modelo e fora da transa��o.")
            
            //inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200430]
            //registrar classe de valor
            nOper := oObj:nOperation
    
            If nOper = 3
	            DbSelectArea("CTH")
	            RecLock( "CTH",  !DbSeek( xFilial( "CTH" ) + SB1->B1_COD ) ) 
	            
	            CTH->CTH_CLVL 	:= SB1->B1_COD
				CTH->CTH_CLASSE := "2" 				//(ANALITICA)
				CTH->CTH_DESC01 := SB1->B1_DESC		
				CTH->CTH_ACATIV := "1" 				//(SIM)
				CTH->CTH_ATOBRG := "2" 				//(N�O)
				
				CTH->(MsUnLock())
			EndIf
			//fim bloco [Mauro Nagata, www.compila.com.br, 20200430]			
 
        ElseIf cIdPonto == "FORMCOMMITTTSPRE"
            //ApMsgInfo("Chamada antes a grava��o da tabela do formul�rio.")
 
        ElseIf cIdPonto == "FORMCOMMITTTSPOS"
        	/*
            //ApMsgInfo("Chamada ap�s a grava��o da tabela do formul�rio.")
            Par�metros Recebidos:
			
			1 O Objeto do formul�rio ou do modelo, conforme o caso
			2 C ID do local de execu��o do ponto de entrada
			3 C ID do formul�rio
			4 L Se .T. indica novo registro (Inclus�o) se .F. registro j� existente (Altera��o / Exclus�o)
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