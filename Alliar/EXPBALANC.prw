// #########################################################################################
// Projeto: CSC ALLIAR 
// Modulo : CONTABIL
// Fonte  : EXPBALANC
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 25/08/2017 | Eduardo.D Ferreira| Gerar arquivo texto para importação 
// ---------+-------------------+-----------------------------------------------------------


#Include "Protheus.ch"
#Include "TopConn.ch"
#Define CTRL Chr(13)+Chr(10)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EXPBALANC
Geração de arquivo contabilidade

@author    TOTVS | Developer Studio -
@version   1.xx
@since     25/08/2017
/*/
//------------------------------------------------------------------------------------------
User Function EXPBALANC() 
                           	
Private cPerg     := "EXPBALANC"

DbSelectArea("SX1")

If !Pergunte(cPerg,.T.)
   Return
Else
	Processa({||GerArq()},"Aguarde...","Gerando Arquivo...")
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
//cFilDe			:= Alltrim(MV_PAR03)
//cFilAte		:= Alltrim(MV_PAR04)
dComptDe   	:= MV_PAR03
dComptAte	:= MV_PAR04

If Upper(SubStr(cNomeArq,(Len(cNomeArq))-4,4)) <> ".txt"
   cNomeArq := cNomeArq+".txt"
EndIf

If SubStr(cPastaDest,Len(cPastaDest),1) <> "\"
   cPastaDest := cPastaDest+"\"
EndIf

nHandle := fCreate(cPastaDest+cNomeArq,0)

If nHandle == -1
   Alert("Ocorreu um erro na criação do arquivo: "+cNomeArq+" - "+ Str(fError(),4))
   Return 
EndIf    

ExecQuery()

ProcRegua(1000800) // passa quantidade de registros

DbSelectArea("TAB")
DbGoTop()
			
While !EOF()

fWrite(nHandle,;
	TAB->CT2_FILIAL +';'+;
	TAB->M0_FILIAL +';'+;
	TAB->CT2_CCD +';'+;
	TAB->CTT_DESC01 +';'+;
	TAB->CT2_DEBITO +';'+;
	TAB->CT1_DESC01 +';'+;
	AllTrim(Str(TAB->CT2_VALOR)) +';'+;	
	left(TAB->CT2_DATA , 4) + 'M' + SubStr(TAB->CT2_DATA , 5 , 2) +';'+ CTRL) 
	//DtoC(Stod(TAB->CT2_DATA))+';' + CTRL)

	TAB->(dbSkip())
	
	dbSkip()
	
EndDo

fClose(nHandle)

dbCloseArea()

MSGINFO("Arquivo gerado.","Informação")

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
                                                                                                                              
	   	    cQuery :="  WITH CONTAB AS ( 
	   	    cQuery +="  SELECT DISTINCT CT2_FILIAL , M0_FILIAL , CT2_CCD , CTT_DESC01 , CT2_DEBITO , CT1_DESC01 , CT2_VALOR , CT2_DATA   "
			cQuery +="  FROM  CT2010 , CT1010 , CTT010 , SIGAMAT                                                                         "
			cQuery +="  WHERE CT2_CCD = CTT_CUSTO                                                                                        "
			cQuery +="	AND CT2_FILIAL = M0_CODFIL 	                                                                                     "
			cQuery +="	AND CT2_DEBITO = CT1_CONTA                                                                                       "
			cQuery +="  AND CT2010.D_E_L_E_T_=''																			             "
			cQuery +="  AND CTT010.D_E_L_E_T_='' 																						 "
			cQuery +="  AND CT1010.D_E_L_E_T_='' 																						 "
			cQuery +="	AND CT2_DATA BETWEEN '"+DtoS(dComptDe)+"' AND '"+DtoS(dComptAte)+"'                                              "
			cQuery +="  union all                                                                                                        "
            cQuery +="  SELECT DISTINCT CT2_FILIAL , M0_FILIAL , CT2_CCC ,  CTT_DESC01 , CT2_CREDIT , CT1_DESC01 , CT2_VALOR , CT2_DATA  "
            cQuery +="  FROM  CT2010, CT1010, CTT010 , SIGAMAT                                                                           "    
            cQuery +="  WHERE CT2_CCD = CTT_CUSTO                                                                                        "
            cQuery +="  AND CT2_FILIAL = M0_CODFIL                                                                                       "
            cQuery +="  AND CT2_DEBITO = CT1_CONTA                                                                                       "
            cQuery +="  AND CT2010.D_E_L_E_T_=''																			             "
			cQuery +="  AND CTT010.D_E_L_E_T_='' 																						 "
			cQuery +="  AND CT1010.D_E_L_E_T_='' 																						 "
			cQuery +="	AND CT2_DATA BETWEEN '"+DtoS(dComptDe)+"' AND '"+DtoS(dComptAte)+"'                                              "
            cQuery +=" )select * from CONTAB                                                                                             "
          
 
   //MemoWrite("c:\query.txt",cquery)
     
   DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TAB", .F., .T.)
   
   	aEval(SRA->(dbStruct()), {|x| If(x[2] <> "C", TcSetField("TAB",x[1],x[2],x[3],x[4]),Nil)})

Return

