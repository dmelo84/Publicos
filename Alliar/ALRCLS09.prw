#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "RPTDEF.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALRCLS09
Funcao Generica para Compilacao

@author Guilherme Santos
@since 10/05/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRCLS09()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} uPrintPDF
Impressao Relatorios Graficos em PDF utilizando a Classe FWMSPrinter

@author Guilherme Santos
@since 10/05/2016
@version P12
*/
//-------------------------------------------------------------------
Class uPrintPDF
	Data aFields
	Data cFileReport
	Data cPathServer
	Data cReportTitle
	Data cReportLogo
	Data cReportName
	Data cRepAlias
	Data cPergunte

	Data nLine
	Data nPage
	Data nColIni
	Data nColFin
	Data nColLen
	Data nLinIni
	Data nLinFin
	Data nMargin
	Data nJumpDef
	Data nColor
	Data cPixel

	Data oFontHeader
	Data oFontBody
	Data oFontFooter
	Data oReport

	Method New()
	Method PrintHeader()
	Method PrintBody()
	Method PrintFooter()
	//Method PrintParam()
	Method PrintColumnsCab()
	Method PrintLine()
	Method Print()

	Method SetReportTitle(cTitle)
	Method SetReportLogo()
	Method SetReportDef()
	
	Method LineSum()
	Method SetField(cField, cTitle, nLength)

	Method GetFileName()
	Method GetPathServer()

EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Inicializador do Objeto

@author Guilherme Santos
@since 10/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method New(cReport, cTitle, cPath, cRepAlias, cPerg, nOrientation, lBlind) Class uPrintPDF
	::aFields			:= {}
	::cFileReport		:= cReport + "_" + DtoS(Date()) + "_" + StrTran(Time(), ":", "") + ".pdf"
	::cPathServer		:= "\spool\"
	::cReportName		:= cReport
	::cRepAlias		:= cRepAlias
	::cPergunte		:= cPerg

	::nPage			:= 0
	::nLinIni			:= 200
	::nLinFin			:= 2900
	::nLine			:= ::nLinIni
	::nColIni			:= 060
	::nColFin			:= 2250
	::nColLen			:= 13
	::nMargin			:= 13
	::nColor			:= 0
	::cPixel			:= "1"
	::nJumpDef			:= 40

	::oFontHeader		:= TFont():New("Courier New", 10, 10, NIL, .T., NIL, NIL, NIL, .F., .F.)
	::oFontBody		:= TFont():New("Courier New", 08, 08, NIL, .F., NIL, NIL, NIL, .F., .F.)
	::oFontFooter		:= TFont():New("Courier New", 08, 08, NIL, .F., NIL, NIL, NIL, .F., .F.)

	::oReport			:= FWMSPrinter():New(	::cFileReport,;	//Nome do Arquivo
													IMP_PDF,;			//Tipo de Saida: IMP_SPOOL - Envia para a Impressora ou IMP_PDF - Gera arquivo PDF
													.T.,;				//Habilita o Legado com a TMSPrinter
													::cPathServer,;	//Caminho do Arquivo no Servidor
													.T.,;				//Se .T. nao exibe a tela de Setup.
													.F.,;				//Indica que a classe foi chamada pelo TReport
													NIL,;				//Objeto FWPrintSetup instanciado pelo usuario
													"",;				//Impressora
													.T.,;				//Indica impressao via Server
													.T.,;				//Indica que sera gerado o PDF no formato PNG
													.F.,;				//.T. indica impressao RAW, .F. indica impressao PCL
													.F.,;				//Quando o tipo de impressão for PDF, define se arquivo sera exibido apos a impressao
													1)					//Quantidade de Copias

	::SetReportDef(nOrientation, lBlind)
	::SetReportLogo()
	::SetReportTitle(cTitle)

Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} PrintHeader
Impressao do Cabecalho do Relatorio

@author Guilherme Santos
@since 10/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method PrintHeader() Class uPrintPDF

	//Linha Separadora
	::PrintLine()
	::LineSum(30)

	//Logo
	::oReport:SayBitMap(::nLine, ::nColIni, ::cReportLogo, 250, 100)
	::LineSum(120)

	//Nome do Programa
	::oReport:Say(::nLine, ::nColIni, ::cReportName, ::oFontHeader, , , , 2)

	//Titulo do Relatorio
	::oReport:Say(::nLine, (::nColFin - ::nColIni - (Len(::cReportTitle) * ::nColLen)) / 2, ::cReportTitle, ::oFontHeader, , , , 2)

	//Data de Emissao
	::oReport:Say(::nLine, ::nColFin - ::nMargin - ::nMargin - (Len(DtoC(Date())) * ::nColLen), DtoC(Date()), ::oFontHeader, , , , 2)

	::LineSum()

	//Empresa de Emissao
	::oReport:Say(::nLine, ::nColIni, "Empresa: " + AllTrim(SM0->M0_NOME), ::oFontHeader, , , , 2)

	//Hora de Emissao
	::oReport:Say(::nLine, ::nColFin - ::nMargin - ::nMargin - (Len(Time()) * ::nColLen), Time(), ::oFontHeader, , , , 2)

	::LineSum()

	::oReport:Say(::nLine, ::nColIni, "Filial: " + AllTrim(SM0->M0_FILIAL), ::oFontHeader, , , , 2)
	
	::oReport:Say(::nLine, ::nColFin - ::nMargin - ::nMargin - (Len("Pagina XXX") * ::nColLen), "Pagina " + StrZero(::nPage, 3), ::oFontHeader, , , , 2)

	::LineSum(30)

	//Linha Separadora
	::PrintLine()
	::LineSum()

	If ::nPage > 1
		::PrintColumnsCab()
	EndIf

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} PrintBody
Impressao do Corpo do Relatorio

@author Guilherme Santos
@since 12/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method PrintBody() Class uPrintPDF
	Local nCol 	:= 0
	Local xValor	:= ""
	Local xAgrupa	:= ""

	DbSelectArea(::cRepAlias)
	(::cRepAlias)->(DbGoTop())		

	While !(::cRepAlias)->(Eof())

		//Dados das Colunas do Relatorio
		For nCol := 1 to Len(::aFields)

			//Campo Agrupador
			If ::aFields[nCol][09]
				If Empty(::aFields[nCol][10])
					xValor := &(::cRepAlias + "->" + ::aFields[nCol][01])
	
					If xAgrupa <> xValor
						xAgrupa := &(::cRepAlias + "->" + ::aFields[nCol][01])
						::oReport:Say(::nLine, ::aFields[nCol][04], ::aFields[nCol][02], ::oFontBody, , , , 2)
						::LineSum()
	
						::oReport:Say(::nLine, ::aFields[nCol][04], AllTrim(xValor), ::oFontBody, , , , 2)
						::LineSum()
	
						::PrintLine()
						::LineSum()
					EndIf
				Else
					xValor := &(::aFields[nCol][10])
	
					If xAgrupa <> xValor
						xAgrupa := &(::aFields[nCol][10])

						::LineSum()

						::oReport:Say(::nLine, ::aFields[nCol][04], ::aFields[nCol][02], ::oFontBody, , , , 2)
						::LineSum()
	
						::oReport:Say(::nLine, ::aFields[nCol][04], AllTrim(xValor), ::oFontBody, , , , 2)
						::LineSum()
	
						::PrintLine()
						::LineSum()
					EndIf
				EndIf
			Else 
				xValor := &(::cRepAlias + "->" + ::aFields[nCol][01])
	
				Do Case
				Case Valtype(xValor) == "N"
					If Empty(::aFields[nCol][07])
						::oReport:Say(::nLine, ::aFields[nCol][04], xValor, ::oFontBody, , , , 2)
					Else
						::oReport:Say(::nLine, ::aFields[nCol][04], Transform(xValor, ::aFields[nCol][04]), ::oFontBody, , , , 2)
					EndIf
	
					//Totalizadores
					If ::aFields[nCol][05]
						::aFiels[nCol][06] += xValor
					EndIf
				Case Valtype(xValor) == "D"
					::oReport:Say(::nLine, ::aFields[nCol][04], DtoC(xValor), ::oFontBody, , , , 2)
				Case Valtype(xValor) == "C"
					::oReport:Say(::nLine, ::aFields[nCol][04], AllTrim(xValor), ::oFontBody, , , , 2)
				Case Valtype(xValor) == "B"
					::oReport:Say(::nLine, ::aFields[nCol][04], If(xValor, "Verdadeiro", "Falso"), ::oFontBody, , , , 2)
				EndCase			
			EndIf

		Next nCol
	
		::LineSum()

		(::cRepAlias)->(DbSkip())
	End

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} PrintFooter
Impressao do Rodape do Relatorio

@author Guilherme Santos
@since 12/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method PrintFooter() Class uPrintPDF
	Local nCol 	:= 0
	Local lPrint 	:= Ascan(::aFields, {|x| x[05]}) > 0 

	If lPrint
		::oReport:Say(::nLine, ::nColIni, "Totais:", ::oFontBody, , , , 2)
		::LineSum()

		//Totalizadores das Colunas do Relatorio
		For nCol := 1 to Len(::aFields)
			If ::aFields[nCol][05]
				::oReport:Say(::nLine, ::aFields[nCol][04], Tranform(::aFields[nCol][06], ::aFields[nCol][07]), ::oFontBody, , , , 2)
			EndIf
		Next nCol

		::LineSum()
	EndIf

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} PrintColumnsCab
cDescri

@author Guilherme Santos
@since 12/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method PrintColumnsCab() Class uPrintPDF
	Local nCol := 0
	
	For nCol := 1 to Len(::aFields)
		If !::aFields[nCol][09]
			::oReport:Say(::nLine, ::aFields[nCol][04], ::aFields[nCol][02], ::oFontBody, , , , 2)
		EndIf
	Next nCol

	::LineSum(30)
	::PrintLine()
	::LineSum(30)
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} PrintLine
Impressao de Linha Separadora

@author Guilherme Santos
@since 12/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method PrintLine() Class uPrintPDF
	::oReport:Line(::nLine, ::nColIni, ::nLine, ::nColFin, /*::nColor*/, /*::cPixel*/)
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} Print
Impressao do Relatorio

@author Guilherme Santos
@since 12/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method Print() Class uPrintPDF
	Local lRetorno := .T.

	::oReport:StartPage()

	//Posiciona na Primeira Linha do Relatorio
	::nLine := ::nLinIni

	//Incrementa a Pagina
	::nPage++

	::PrintHeader()

	//::PrintParam()
	
	::PrintBody()
	
	::PrintFooter()

	::oReport:EndPage()
	
	::oReport:Print()

	If !File(::GetPathServer() + ::GetFileName())
		lRetorno := .F.
	EndIf

Return lRetorno

//-------------------------------------------------------------------
/*{Protheus.doc} SetReportTitle
Armazena o Titulo do Relatorio

@author Guilherme Santos
@since 10/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method SetReportTitle(cTitle) Class uPrintPDF
	::cReportTitle := cTitle
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} SetReportLogo
Armazena o Logo do Relatorio

@author Guilherme Santos
@since 10/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method SetReportLogo() Class uPrintPDF
	Local cDirLogo	:= AllTrim(GetSrvProfString("StartPath", "\"))

	::cReportLogo	:= ""

	If File(cDirLogo + "LGRL" + FWGrpCompany() + FWCodFil() + ".BMP")
		::cReportLogo := cDirLogo + "LGRL" + FWGrpCompany() + FWCodFil() + ".BMP"
	ElseIf File(cDirLogo + "LGRL" + FWGrpCompany() + ".BMP")
		::cReportLogo := cDirLogo + "LGRL" + FWGrpCompany() + ".BMP"
	EndIf
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} SetReportDef
Definicao dos Parametros de Impressao

@author Guilherme Santos
@since 10/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method SetReportDef(nOrientation, lBlind) Class uPrintPDF
	::oReport:SetResolution(72)

	Do Case
	Case nOrientation == 1
		::oReport:SetPortrait()
	Case nOrientation == 2
		::oReport:SetLandscape()
	EndCase	

	::oReport:SetPaperSize(9)	
	::oReport:SetMargin(60, 60, 60, 60) // nEsquerda, nSuperior, nDireita, nInferior
	::oReport:lInJob		:= lBlind
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} LineSum
Salto de Linha do Relatorio

@author Guilherme Santos
@since 12/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method LineSum(nJump) Class uPrintPDF
	Default nJump := ::nJumpDef
	
	::nLine += nJump

	If ::nLine > ::nLinFin
		If ::nPage > 0
			::oReport:EndPage()
		EndIf
		
		::oReport:StartPage()

		//Posiciona na Primeira Linha do Relatorio
		::nLine := ::nLinIni

		//Incrementa a Pagina
		::nPage++

		::PrintHeader()
	EndIf
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} SetField
cDescri

@author Guilherme Santos
@since 12/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method SetField(cField, cTitulo, nLength, lTotal, cPicture, lAgrupa, cFormula) Class uPrintPDF
	Local nColIni 	:= 0
	Local nColFin 	:= 0

	Default lAgrupa	:= .F.
	Default cFormula	:= ""
	
	//Verifica a Posicao atual da Coluna
	If Len(::aFields) == 0 .OR. lAgrupa
		nColIni := ::nColIni
		nColFin := nColIni + (nLength * ::nColLen) + ::nMargin
	Else
		//Se o Campo Anterior for de Agrupamento
		If ::aFields[Len(::aFields)][09]
			nColIni := ::nColIni
			nColFin := nColIni + (nLength * ::nColLen) + ::nMargin
		Else
			nColIni := ::aFields[Len(::aFields)][08]
			nColFin := nColIni + (nLength * ::nColLen) + ::nMargin
		EndIf
	EndIf
	
	Aadd(::aFields, {	cField,;												//01 - Nome do Campo na Tabela de Origem
						cTitulo,;												//02 - Titulo do Campo
						nLength,;												//03 - Tamanho do Campo
						nColIni,;												//04 - Posicao do Campo na Impressao
						lTotal,;												//05 - Determina se tem Totalizador
						0,;														//06 - Soma do Totalizador
						cPicture,;												//07 - Picture do Campo Numerico
						nColFin,;												//08 - Picture do Campo Numerico
						lAgrupa,;												//09 - Campo Agrupador para o Cabecalho
						cFormula})												//10 - Formula para Impressao do Agrupador

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} GetFileName
Retorna o Nome do Arquivo do Relatorio

@author Guilherme Santos
@since 12/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetFileName() Class uPrintPDF
Return ::cFileReport
//-------------------------------------------------------------------
/*{Protheus.doc} GetPathServer
Retorna o Caminho do Arquivo no Servidor

@author Guilherme Santos
@since 12/05/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetPathServer() Class uPrintPDF
Return ::cPathServer
