#include 'protheus.ch'
#include 'parmtype.ch'

user function IMPCSV()

	Local cArq    := UPPER(cGetFile( '*.*' , 'Textos (CSV)', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, /*GETF_RETDIRECTORY*/ GETF_MULTISELECT  ),.T., .T. ))
	Local cLinha  := ""
	Local lPrim   := .T.
	Local aCampos := {}
	Local aDados  := {}
	Local aCab := {}
	Local aItem := {}
	Local aItens := {}
	//Local aItensRat := {}
	//Local aCodRet := {}
	Local nOpc := 4 
	Local cNum := ""
	Local nI := 0
	Local nX := 0
	Local nReg := 1

	If Subs(cArq,-4) <> ".CSV"
		MsgInfo("Leitura é realizada apenas em arquivos .CSV!")
		return(MsgInfo)
	Endif

	If !File(cArq)
		MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","[Imp. Mov. SD3] - ATENCAO")
		Return
	EndIf

	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()

		IncProc("Lendo arquivo texto...")

		cLinha := FT_FREADLN()

		If lPrim
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf
		FT_FSKIP()
	EndDo



	Conout("Inicio: " + Time())

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	For nI := 1 to Len(aDados)  

		//Cabeçalho
		aadd(aCab,{"F1_FILIAL" ,aDados[nI][1] ,NIL})
		aadd(aCab,{"F1_TIPO" ,aDados[nI][7] ,NIL})
		aadd(aCab,{"F1_FORMUL" ,aDados[nI][8] ,NIL})
		aadd(aCab,{"F1_DOC" ,aDados[nI][2] ,NIL})
		aadd(aCab,{"F1_SERIE" ,aDados[nI][3] ,NIL})
		aadd(aCab,{"F1_EMISSAO" ,aDados[nI][6] ,NIL})
		aadd(aCab,{"F1_DTDIGIT" ,DDATABASE ,NIL})
		aadd(aCab,{"F1_FORNECE" ,aDados[nI][4] ,NIL})
		aadd(aCab,{"F1_LOJA" ,aDados[nI][5] ,NIL})
		aadd(aCab,{"F1_ESPECIE" ,aDados[nI][9] ,NIL})

		//Itens
		For nX := 1 To Len(aDados)

	If aCab[1][2] == aDados [nX][1] .and. aCab[4][2] == aDados[nX][2] .and. aCab[5][2] == aDados[nX][3] .and. aCab[8][2] == aDados[nX][4] .and. aCab[9][2] == aDados[nX][5]

				aItem := {}

				aadd(aItem,{"D1_FILIAL" ,PadR(aDados[nX][10],TamSx3("D1_FILIAL")[1]) ,NIL})
				aadd(aItem,{"D1_DOC" ,aDados[nX][2] ,NIL})
				aadd(aItem,{"D1_ITEM" ,PadR(aDados[nX][11],TamSx3("D1_ITEM")[1]) ,NIL})
				aadd(aItem,{"D1_COD" ,PadR(aDados[nX][12],TamSx3("D1_COD")[1]) ,NIL})
				aadd(aItem,{"D1_QUANT" ,val(aDados[nX][13]) ,NIL})
				aadd(aItem,{"D1_VUNIT" ,val(aDados[nX][14]) ,NIL})
				aadd(aItem,{"D1_TOTAL" ,val(aDados[nX][15]) ,NIL}) 
				aadd(aItem,{"D1_TES" ,aDados[nX][16] ,NIL}) 
				aadd(aItem,{"D1_NFORI" ,aDados[nX][17] ,NIL})
				aadd(aItem,{"D1_SERIORI" ,aDados[nX][18] ,NIL})
				aadd(aItem,{"D1_ITEMORI" ,aDados[nX][19] ,NIL}) 
				aadd(aItem,{"D1_IDENTB6" ,aDados[nX][20] ,NIL})
				aadd(aItem,{"D1_LOCAL" ,aDados[nX][21] ,NIL})  
				//aAdd(aItem,{"LINPOS" , "D1_ITEM", PadR(aDados[nX][11],TamSx3("D1_ITEM")[1]) ,NIL})


				aAdd(aItens,aItem)

	Endif

		Next nX
	Next nI
		MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,nOpc)
	
		If lMsErroAuto
			Alert("Erro na importação")
			cMsgErro := MostraErro()
			MsgInfo(cMsgErro)
		Else
			Alert("Incluido com Sucesso")
		EndIf

	
return