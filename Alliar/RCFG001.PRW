#include "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"  




/*/{Protheus.doc} RCFG001
Relatórios exporta dados de privilégio de acesso paara excel.
@author Augusto Ribeiro | www.compila.com.br
@since 15/03/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function RCFG001()
Local cPerg	:= "RCFG01"


//IF Aviso("Relatório Acessos","Exporta  para execel permissoes/privilegios cadastros."+CRLF+CRLF+"Deseja Continuar ?",{"Ok","Cancelar"}) == 1
	IF Pergunte(cPerg)
		RCFG001E(MV_PAR01, MV_PAR02)
	ENDIF
//ENDIF

Return()



/*/{Protheus.doc} RCFG001E
Realiza impressão do relatorio
@author Augusto Ribeiro
@since 15/03/2019
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function RCFG001E(cIdDe, cIDAte)
Local _cNome	:= GetTempPath(.T.) + "PRIVILEGIOS_" + DTOS(DDATABASE)+"_" + STRTRAN(TIME(),":","-") + ".XLS"
Local oExcel, cSheet, cTable

Local oModel   := FWLoadModel("FWRULESACCOUNTDATA")

Local oModRul	:= oModel:GetModel("DATARULE")
Local oModTran	:= oModel:GetModel("DATATRANSACTION")
Local oModMenu	:= oModel:GetModel("DATAMENUDEF")
Local oModBar	:= oModel:GetModel("DATABARDEF")

Local oStrMdl1 := oModel:GetModel("DATARULE"):GetStruct()
Local oStrMdl2 := oModel:GetModel("DATATRANSACTION"):GetStruct()
Local oStrMdl3 := oModel:GetModel("DATAMENUDEF"):GetStruct()
Local oStrMdl4 := oModel:GetModel("DATABARDEF"):GetStruct()

Default cIdDe  := ""
Default cIDAte := ""


aRules := FWSFAllRules()

IF !EMPTY(aRules)

		
	oExcel 	:= FWMSEXCEL():New()
	cSheet 	:= "Privilegios "//+"_"+DTOS(DDATABASE)+"_"+STRTRAN(TIME(),":","-")
	cTable	:= "Privilegios "
	
	oExcel:AddworkSheet(cSheet)
	oExcel:AddTable (cSheet,cTable)
	
	oExcel:AddColumn(cSheet ,cTable ,"Regra"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Comentario"					,1,1)
	
	oExcel:AddColumn(cSheet ,cTable ,"Transacao/Rotina"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Descricao"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Acesso"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Item"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Menu"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Definicao da Operacao"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Acesso"					,1,1)
	oExcel:AddColumn(cSheet ,cTable ,"Rotina do Menu"					,1,1)
	
	

	FOR nI := 1 to len(aRules)
	
	
		IF alltrim(aRules[nI,2]) >= ALLTRIM(cIdDe) .and. alltrim(aRules[nI,2]) <= ALLTRIM(cIDAte)

			oModel:DeActivate()
			oModel:Cargo := {aRules[nI][1],aRules[nI][2],.F.}		
			oModel:Activate()
			
			
			cRegra	:= "TESTE"
			cComent	:= "Comentario TESTE"
			
			FOR nY := 1 to oModTran:Length()
			
				oModTran:GoLine(nY)
			
				FOR nZ := 1 to oModMenu:Length()
				
					oModMenu:GoLine(nZ)
					IF EMPTY(MV_PAR03) .OR. ALLTRIM(oModTran:GetValue("RL__ROTINA")) == ALLTRIM(MV_PAR03)
						oExcel:AddRow(cSheet,cTable,{	oModRul:GetValue("RL__CODIGO"),;
														oModRul:GetValue("RL__DESCRI"),;
														oModTran:GetValue("RL__ROTINA"),;
														oModTran:GetValue("RL__DESROT"),;
														GetDescAc( oModTran:GetValue("RL__ACESSO")),;
														oModMenu:GetValue("RL__ITEM"),;
														oModMenu:GetValue("RL__DESMDEF"),;
														oModMenu:GetValue("RL__MENUOPER"),;
														GetDescAc( oModMenu:GetValue("RL__ACESSO")),;
														oModMenu:GetValue("RL__MENUDEF")	})
												
					ENDIF 								
				NEXT nZ	
				
				
				
			NEXT nY
			
		endif
	NEXT nI
	
	oExcel:Activate()
	oExcel:GetXMLFile(_cNome)								
	
	/*=====================
	| Abre arquivo gerado  |
	=======================*/
	ShellExecute("open","excel.exe",_cNome,"", 1 )	
ENDIF


Return()


/*/{Protheus.doc} GetDescAc
Retorna Descrição do campo
@author Jonatas Oliveira | www.compila.com.br
@since 15/03/2019
@version 1.0
/*/
Static Function GetDescAc( cCdAcess )
	Local cRet 	:= ""
	
	IF ALLTRIM(cCdAcess) == "1"
		cRet := "Permitido"
	ELSEIF ALLTRIM(cCdAcess) == "2"
		cRet := "Não Permitido"
	ELSEIF ALLTRIM(cCdAcess) == "3"
		cRet := "Negado"
	ENDIF 
	
	
Return(cRet)

