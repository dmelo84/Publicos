#INCLUDE "Protheus.ch"   
#INCLUDE "TbiConn.ch"
#INCLUDE "FILEIO.CH"

/* ----------------------------------------------------------------------------------------------------
@ Function FA070TIT - Faz a validação dos dados da baixa CR.       
@ Autor 			: Francisco Lopes Junior
@ Objetivo 			: A rotina deverá bloquear a baixa de títulos que não 
@            		 possuírem o campo E1_NFELETR preenchido e oriundos do módulo faturamento E1_ORIGEM MATA460.
@            		 Colocar o parâmetro habilitavel por filial.
@  			 		 Desta maneira iremos estancar as futuras baixas de notas não autorizadas
@ Data				: 10/03/2017
/*-------------------------------------------------------------------------------------------------------*/   

// obs TDN http://tdn.totvs.com/display/public/PROT/MSERV-1531_DT_NFSE_GRAVACAO_CORRETA_DOS_CAMPOS


User function FA070TIT()

Local _lRet 		:= .T.
Local _aArea		:= GetArea()
Local _aParciais	:= Paramixb[1]
Local _aTitnBx		:= {}   
Local oDlg  		
Local oLbx
Local cSaldo        := ""
Local _lRetFil 	    := GetMv("FS_FILBXNF",.F.,.F.)  ////parâmetro se .T. passa na valição 
Local _cTitulo		:= "Titulos a receber de Nf Saida sem numero SEFAZ"
                                                            
                                                        

If  Empty(SE1->E1_NFELETR) .and. Alltrim(SE1->E1_ORIGEM) == 'MATA460' .and. _lRetFil .AND. SE1->E1_PREFIXO != GetNewPar("ES_SERMOT","MOT")
	If iif(Type('lF070Auto') =='U',.t., !lF070Auto)
		
		  Help(" ",1,"VLDATIT",,"Título [ "+ Alltrim(SE1->E1_PREFIXO) + Iif(!empty(SE1->E1_PREFIXO),"] ", "") +" "  ;
				  +"["+ Alltrim(SE1->E1_NUM) + IiF(!Empty(SE1->E1_PARCELA) , "/", "") + Alltrim(SE1->E1_PARCELA) + "] " ;
				  + " não permite baixa devido NFS eletrônica pendente de processamento",1,0)
		
	/*	  Help(" ",1,"VLDATIT",,"Numero de Nota Fiscal Eletronica em Branco Titulo CR gerado pela Venda " + ;
				 Alltrim(SE1->E1_PREFIXO) + Iif(!empty(SE1->E1_PREFIXO)," - ", "") +;
				 Alltrim(SE1->E1_NUM) + IiF(!Empty(SE1->E1_PARCELA) , "/", "") + Alltrim(SE1->E1_PARCELA) + " Emissão: "+ DtoC(SE2->E2_EMISSAO)+ " baixa abortada" ,1,0)*/
				 _lRet := .F.
    Else  		      
    	cSaldo := TransForm(SE1->E1_VALOR,X3Picture("E1_VALOR"))
    	Aadd(_aTitnbx, { Alltrim(SE1->E1_PREFIXO) + Iif(!empty(SE1->E1_PREFIXO)," - ", "") +;
				 	Alltrim(SE1->E1_NUM) + IiF(!Empty(SE1->E1_PARCELA) , "/", "") +;
				    Alltrim(SE1->E1_PARCELA) +  DtoC(SE2->E2_EMISSAO), 	MsPadL(cSaldo,100)})
	Endif 															// rotina automatica
	
Endif 


// If Len( _aTitnbx ) > 0
  

// 	// Monta a tela para usuário visualizar consulta.
// 	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
	
// 	   // Primeira opção para montar o listbox.
// 	   @ 10,10 LISTBOX oLbx FIELDS HEADER ;
// 	   "Titulo", "Valor" ;
// 	   SIZE 230,95 OF oDlg PIXEL	
	
// 	   oLbx:SetArray( _aTitnbx )
// 	   oLbx:bLine := {|| {_aTitnbx[oLbx:nAt,1],;
// 	                      _aTitnbx[oLbx:nAt,2]}}
	                   
	   
		                    
// 	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
// 	ACTIVATE MSDIALOG oDlg CENTER 
// 	_aTitnbx:= {}    
	
// Endif
	
RestArea(_aArea)	

Return (_lRet)    

