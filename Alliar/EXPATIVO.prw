// #########################################################################################
// Projeto: CSC ALLIAR	
// Modulo : ATIVO FIXO
// Fonte  : EXPATIVO	
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 28/01/15 | Eduardo.D.Ferreira| 
// ---------+-------------------+-----------------------------------------------------------


#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Define CTRL Chr(13)+Chr(10)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EXPATIVO
Geração de arquivo de funcionarios

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     06/01/2017
/*/
//------------------------------------------------------------------------------------------
User Function EXPATIVO() 

Private cPerg     := 'EXPATIVO1'

DbSelectArea('SX1')


If !Pergunte(cPerg,.T.)
   Return
Else
	Processa({||GerArq()},'Aguarde...','Gerando Arquivo...')
Endif		   
	   
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GerArq
Geração de arquivo Seguro

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     28/01/2015
/*/
//------------------------------------------------------------------------------------------
Static Function GerArq()


Private nHandle   := 0 

cNomeArq   	:= Alltrim(MV_PAR01)
cPastaDest 	:= Alltrim(MV_PAR02)
cFilDe		:= Alltrim(MV_PAR03)
cFilAte		:= Alltrim(MV_PAR04)
//dComptDe   	:= Alltrim(MV_PAR05)
//dComptAte	:= Alltrim(MV_PAR06)


If Upper(SubStr(cNomeArq,(Len(cNomeArq))-4,4)) <> '.CSV'
   cNomeArq := cNomeArq+'.CSV'
EndIf

If SubStr(cPastaDest,Len(cPastaDest),1) <> '\'
   cPastaDest := cPastaDest+'\'
EndIf

nHandle := fCreate(cPastaDest+cNomeArq,0)

If nHandle == -1
   Alert('Ocorreu um erro na criação do arquivo: '+cNomeArq+' - '+ Str(fError(),4))
   Return 
EndIf    

ExecQuery()

ProcRegua(80000000) // passa quantidade de registros

DbSelectArea('TAB')
DbGoTop()

fWrite(nHandle,+'Filial ; Grupo;	Cod do Bem; 	Item;	Quantidade;	Dt Aquisicao;	Descr Sint;	Num Plaqueta;	Nota Fiscal;	Status Bem;	Vl Aquisicao; N3_Vorig1  ;Depr acum M1'+ CTRL)
			
While   !EOF()	                               
fWrite(nHandle,;    
		 TAB->N1_FILIAL        +';'+;          
		 TAB->N1_GRUPO	          +  ';' +;
		 TAB->N1_CBASE             +   ';' +;
		 TAB->N1_ITEM	            +    ';' +; 
		 AllTrim(Str(TAB->N1_QUANTD))+	';' +;
		 DtoC(Stod(TAB->N1_AQUISIC)) + ';' +;
		 TAB->N1_DESCRIC             + ';' +;
		 TAB->N1_CHAPA	           + ';' +;
		 TAB->N1_NFISCAL            +  ';' +;
		 TAB->N1_STATUS	            +';' +;
		 AllTrim(Str(TAB->N1_VLAQUIS))+';' +;
		 AllTrim(Str(TAB->N3_VORIG1)) +';' +;
		 AllTrim(Str(TAB->N3_VRDACM1)) +';'+CTRL)  
	 
	TAB->(dbSkip())		
	dbSkip()
EndDo

fClose(nHandle)

dbCloseArea()

MSGINFO('Arquivo gerado.','Informação')

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecQuery
Executa Query

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     28/01/2015
/*/
//------------------------------------------------------------------------------------------

Static Function ExecQuery()
                                                                                 
	   
	                                                                                                   
	     cQuery :=" SELECT                                                                               "
		 cQuery +=" N1_FILIAL ,N1_GRUPO , N1_CBASE , N1_ITEM , N1_QUANTD , N1_AQUISIC , N1_DESCRIC ,     "
		 cQuery +=" N1_CHAPA , N1_NFISCAL , N1_STATUS , N1_VLAQUIS , N3_VORIG1 , N3_VRDACM1              "
		 cQuery +=" from SN1010, SN3010                                                                  "
		 cQuery +=" WHERE  N1_CBASE = N3_CBASE                                                           "
	 	 cQuery +=" AND N1_FILIAL = N3_FILIAL                                                            "
 		 cQuery +=" AND SN1010.D_E_L_E_T_=''                                                             "
 		 cQuery +=" AND SN3010.D_E_L_E_T_=''                                                             "
	     //cQuery +=" AND N1_AQUISIC BETWEEN '"+DtoS(dComptDe)+"' AND '"+DtoS(dComptAte)+"'              "
	     cQuery +=" AND N1_FILIAL  BETWEEN '"+cFilDe+"' AND '"+cFilAte+"'                                "
	     
                                          
	
   //MemoWrite('c:\query.txt',cquery)
   
   DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQuery), 'TAB', .F., .T.)

Return

