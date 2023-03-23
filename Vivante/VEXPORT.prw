//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
 
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
 
/*/{Protheus.doc} VEXPORT
Função para gerar relatório processos em Excel
@author Pablo
@since 28/02/2019
@version 1.0
/*/
//---------------------------------------------------------------------------
User Function VEXPORT()

	Private cPerg      := "VEXPORT"

	Private cAlias     := GetNextAlias()
	Private dDataIni
	Private dDataFin
	Private cReclam
	Private dDataEncD
	Private dDataEncF
	
	// Avalia se o diretorio Temp existe!
/*	If !ExistDir(cPath)
		If MakeDir(cPath) <> 0
			Aviso("Atenção","O Diretório "+cPath+" deve ser criado para gravação dos arquivos temporários!",{"Ok"})
			Return 	
		End If
	End If*/

	//Funcao para criar o grupo de perguntas da SX1
	CriaPerg()
	If !Pergunte(cPerg,.T.)
		Return
	EndIf             
	
	dDataIni     := MV_PAR01
	dDataFin     := MV_PAR02  
	cReclam      := MV_PAR03
	dDataEncD    := MV_PAR05
	dDataEncF    := MV_PAR06 

	//função que que seleciona os dados de acordo com os parametros informados
/*	Processa( {|| fSelecDados() }, "Aguarde...", "Gerando dados!",.F.)
	
	IF (cAlias)->(EOF())
		Alert("Não existem dados no período")
		(cAlias)->dbCloseArea
	   	Return
	Endif			                                 */
	
	Processa( {|| FGeraRelat() }, "Aguarde...", "Processando...",.F.)

Return          
 
Static Function FGeraRelat()
    Local aArea        := GetArea()
    Local cQuery        := ""
    Local oFWMsExcel
    Local oExcel
    Local cArquivo    := GetTempPath()+'zProcessos.xml'
 
    //Pegando os dados
    cQuery := "  SELECT PPASSIVO "
	cQuery += CRLF + " ,PATIVO   "
	cQuery += CRLF + " ,CPFRECL  "
	cQuery += CRLF + " ,DTADM    "
	cQuery += CRLF + " ,DTDEM    "
	cQuery += CRLF + " ,CAURES   "
	cQuery += CRLF + " ,FUNCI     "
	cQuery += CRLF + " ,ULTSAL   "
	cQuery += CRLF + " ,NOMDIR   "
	cQuery += CRLF + " ,NOMGER   "
	cQuery += CRLF + " ,ADVRECL  "
	cQuery += CRLF + " ,CODCONTRATO "
	cQuery += CRLF + " ,NOMCONTRATO "
	cQuery += CRLF + " ,NUMPROC  "
	cQuery += CRLF + " ,NOMENVOLV"
	cQuery += CRLF + " ,VARA     "
	cQuery += CRLF + " ,COMARCA  "
	cQuery += CRLF + " ,UF       "
	cQuery += CRLF + " ,OBJETOS  "
	cQuery += CRLF + " ,DESCAND  "
	cQuery += CRLF + " ,DESCFASE "
	cQuery += CRLF + " ,DTDISTR  "
	cQuery += CRLF + " ,DTINCL   "
	cQuery += CRLF + " ,TPACAO   "
	cQuery += CRLF + " ,DESCPROG "
	cQuery += CRLF + " ,VLRO     "
	cQuery += CRLF + " ,DTRO     "
	cQuery += CRLF + " ,VLRR     "
	cQuery += CRLF + " ,DTRR     "
	cQuery += CRLF + " ,VLAGR    "
	cQuery += CRLF + " ,DTAGR    "
	cQuery += CRLF + " ,VLGAR    "
	cQuery += CRLF + " ,DTGAR    "
	cQuery += CRLF + " ,VLCAU    "
	cQuery += CRLF + " ,VLRECL   "
	cQuery += CRLF + " ,VLRISCO  "
	cQuery += CRLF + " ,DESCST   "
	cQuery += CRLF + " ,SITUAC   "
	cQuery += CRLF + " ,XESPEC   "
	cQuery += CRLF + " ,DESCXESP "
	cQuery += CRLF + " ,DTENCE   "

	cQuery += CRLF + " FROM ZPROCESSO "
	cQuery += CRLF + " WHERE DTINCL BETWEEN '"+ Dtos(dDataIni) + "' AND '"+ Dtos(dDataFin) +"'" 
	cQuery += CRLF + " AND PATIVO LIKE '%" + Alltrim(cReclam) + "%' "
	
	   If mv_par04     == 1                                                    
			cQuery   += CRLF + "AND SITUAC  = '1'   "
	   ElseIf mv_par04 == 2   
	        cQuery   += CRLF + "AND SITUAC = '2'   "
	   ElseIf mv_par04 == 3      
            cQuery   += CRLF + "AND SITUAC IN ('2', '1') "
       EndIf
	   If  !Empty(mv_par05) .and. !Empty(mv_par06)  
	        cQuery += CRLF + " AND DTENCE BETWEEN '"+ Dtos(dDataEncD) + "' AND '"+ Dtos(dDataEncF) +"'"    
	   Endif
    TCQuery cQuery New Alias "QRYPRO"
     
    //Criando o objeto que irá gerar o conteúdo do Excel
    oFWMsExcel := FWMSExcel():New()
     
 
    oFWMsExcel:AddworkSheet("Processos")
        //Criando a Tabela
        oFWMsExcel:AddTable("Processos","Processos")
        oFWMsExcel:AddColumn("Processos","Processos","Polo Passivo",1)
        oFWMsExcel:AddColumn("Processos","Processos","Polo Ativo",1)
        oFWMsExcel:AddColumn("Processos","Processos","CPF Reclamente",1)
        oFWMsExcel:AddColumn("Processos","Processos","Data Admissao",1)
        oFWMsExcel:AddColumn("Processos","Processos","Data Demissao",1)
        oFWMsExcel:AddColumn("Processos","Processos","Motivo Desligamento",1)
        oFWMsExcel:AddColumn("Processos","Processos","Funcao",1)
        oFWMsExcel:AddColumn("Processos","Processos","Ultimo Salario",1)
        oFWMsExcel:AddColumn("Processos","Processos","Diretor",1)
        oFWMsExcel:AddColumn("Processos","Processos","Gerente",1)
        oFWMsExcel:AddColumn("Processos","Processos","Advogado Reclamante",1)
        oFWMsExcel:AddColumn("Processos","Processos","Codigo do Contrato",1)
        oFWMsExcel:AddColumn("Processos","Processos","Nome Contrato",1)
        oFWMsExcel:AddColumn("Processos","Processos","Numero Processo",1)
        oFWMsExcel:AddColumn("Processos","Processos","Nome Envolvido",1)
        oFWMsExcel:AddColumn("Processos","Processos","Vara",1)
        oFWMsExcel:AddColumn("Processos","Processos","Comarca",1)
        oFWMsExcel:AddColumn("Processos","Processos","UF",1)
        oFWMsExcel:AddColumn("Processos","Processos","Andamento",1)
        oFWMsExcel:AddColumn("Processos","Processos","Fase",1)
        oFWMsExcel:AddColumn("Processos","Processos","Data Distribuicao",1)
        oFWMsExcel:AddColumn("Processos","Processos","Data Inclussao",1)
        oFWMsExcel:AddColumn("Processos","Processos","Tipo acao",1)
        oFWMsExcel:AddColumn("Processos","Processos","Prognastico",1)
        oFWMsExcel:AddColumn("Processos","Processos","Valor RO",1)
        oFWMsExcel:AddColumn("Processos","Processos","Data RO",1)
        oFWMsExcel:AddColumn("Processos","Processos","Valor RR",1)
        oFWMsExcel:AddColumn("Processos","Processos","Data RR",1)
        oFWMsExcel:AddColumn("Processos","Processos","Valor AGR",1)
        oFWMsExcel:AddColumn("Processos","Processos","Data AGR",1)
        oFWMsExcel:AddColumn("Processos","Processos","Valor Garantia",1)
        oFWMsExcel:AddColumn("Processos","Processos","Data Garantia",1)
        oFWMsExcel:AddColumn("Processos","Processos","Valor Causa",1)
        oFWMsExcel:AddColumn("Processos","Processos","Valor Reclamado",1)
        oFWMsExcel:AddColumn("Processos","Processos","Valor Risco",1)
        oFWMsExcel:AddColumn("Processos","Processos","Descricao Situacao",1)
        oFWMsExcel:AddColumn("Processos","Processos","Descricao Especial",1)
        oFWMsExcel:AddColumn("Processos","Processos","Data Encerramento",1)
       // oFWMsExcel:AddColumn("Processos","Processos","Concatenado",1)
        
        //Criando as Linhas... Enquanto não for fim da query
        While !(QRYPRO->(EoF()))
            oFWMsExcel:AddRow("Processos","Processos",{;
                                                                    QRYPRO->PPASSIVO,;
                                                                    QRYPRO->PATIVO,;
                                                                    QRYPRO->CPFRECL,;
                                                                    Stod(QRYPRO->DTADM),; 
                                                                    Stod(QRYPRO->DTDEM),;
                                                                    QRYPRO->CAURES,;
                                                                    QRYPRO->FUNCI,;
                                                                    QRYPRO->ULTSAL,;
                                                                    QRYPRO->NOMDIR,;
                                                                    QRYPRO->NOMGER,;
                                                                    QRYPRO->ADVRECL,;
                                                                    QRYPRO->CODCONTRATO,;
                                                                    QRYPRO->NOMCONTRATO,;
                                                                    QRYPRO->NUMPROC,;
                                                                    QRYPRO->NOMENVOLV,;
                                                                    QRYPRO->VARA,;
                                                                    QRYPRO->COMARCA,;
                                                                    QRYPRO->UF,;
                                                                    QRYPRO->DESCAND,;
                                                                    QRYPRO->DESCFASE,;
                                                                    Stod(QRYPRO->DTDISTR),;
                                                                    Stod(QRYPRO->DTINCL),;
                                                                    QRYPRO->TPACAO,;
                                                                    QRYPRO->DESCPROG,;
                                                                    QRYPRO->VLRO,;
                                                                    Stod(QRYPRO->DTRO),;
                                                                    QRYPRO->VLRR,;
                                                                    Stod(QRYPRO->DTRR),;
                                                                    QRYPRO->VLAGR,;
                                                                    Stod(QRYPRO->DTAGR),;
                                                                    QRYPRO->VLGAR,;
                                                                    Stod(QRYPRO->DTGAR),;
                                                                    QRYPRO->VLCAU,;
                                                                    QRYPRO->VLRECL,;
                                                                    QRYPRO->VLRISCO,;
                                                                    QRYPRO->DESCST,;
                                                                    QRYPRO->DESCXESP,;
                                                                    Stod(QRYPRO->DTENCE);                                               
            })
         
            //Pulando Registro
            QRYPRO->(DbSkip())
        EndDo
     
    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo)
         
    //Abrindo o excel e abrindo o arquivo xml
    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
    oExcel:SetVisible(.T.)                 //Visualiza a planilha
    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     
    QRYPRO->(DbCloseArea())
    RestArea(aArea)
Return


//------------------------------------------------------------------ 
/*/{Protheus.doc} CriaPerg
Cria pergunta para realizar filtros na query
          
@author    Pablo
@since     28.02.2019
@version 	P12
@return	NA                                            
                                                                                                               	
@description
Cria pergunta 
/*/ 
//------------------------------------------------------------------ 
Static Function CriaPerg()

	Local aArea := GetArea()

    U_FJGSX1(cPerg, "01", "Data Inicial", "Data Inicial" , "Data Inicial" ,"MV_CH1", "D", 08, 0,0, "G","","","", "N","MV_PAR01")    
	U_FJGSX1(cPerg, "02", "Data Final"  , "Data Final"   , "Data Final"   ,"MV_CH2", "D", 08, 0,0, "G","","","", "N","MV_PAR02")
	U_FJGSX1(cPerg, "03", "Polo Ativo"  , "Polo Ativo"   , "Polo Ativo"   ,"MV_CH3", "C", 40, 0,0, "G","","","", "N","MV_PAR02")
	U_FJGSX1(cPerg, "04","Situacao?  "  , "Situacao?   " , "Situacao?   " ,"mv_ch4", "N", 01, 0,1, "C","","","", "N","mv_par04","Aberto","","","","Encerrado","","","","Todos","","")	
	U_FJGSX1(cPerg, "05", "Data Encerramento De"  , "Data Encerramento De"   , "Data Encerramento De"   ,"MV_CH5", "D", 08, 0,0, "G","","","", "N","MV_PAR05")
	U_FJGSX1(cPerg, "06", "Data Encerramento Ate"  , "Data Encerramento Ate"   , "Data Encerramento Ate"   ,"MV_CH6", "D", 08, 0,0, "G","","","", "N","MV_PAR06")
	
	
	RestArea(aArea)

Return Nil

