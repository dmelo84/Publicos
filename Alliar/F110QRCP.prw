#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "Protheus.Ch"
#include "TbiConn.ch"


/*/{Protheus.doc} F110QRCP
PE que acrescenta um filtro de forma de pagto 
@author Mateus Hengle | www.compila.com.br
@since 16/09/2018
@version 1.0
/*/
User Function F110QRCP()  

	Local aArea    := GetArea()
	Local cQuery   := PARAMIXB[1]
	Local cOrderBy := ""
	Local cAux     := ""
	Local cFilRet  := ""
	Local cTipoPG  := ""
	Local lFilDtAt	:= U_GetAD("MV_FDTF110","L","Habilita Filtro Data de Atendimento - Fina110",".T.") //Imprime etiqueta só se for entrada de mercadoria

	If lFilDtAt
		cDTAtend := U_DTATEND()
	Endif
	cTipoPG  := U_FORMPAGTO()


	IF !EMPTY(cTipoPG)
		/*----------------------------------------
		05/10/2018 - Jonatas Oliveira - Compila
		Remove o Traço caso tenha sido escolhido
		o registro "  " - NÃO INFORMADO
		------------------------------------------*/
		cTipoPG := STRTRAN(cTipoPG,"-","")
		cFilRet += " AND E1_XFORMPG IN (" + ALLTRIM(cTipoPG) + ")"
	EndIf

	IF !Empty(cDTAtend)
		cFilRet += " AND E1_XDAPLER = '"+cDTAtend+"'"
	Endif

	cOrderBy := SubStr(cQuery, RAt("ORDER BY", cQuery), Len(cQuery))
	cAux := SubStr(cQuery, 1, RAt("ORDER BY", cQuery)-1)

	cQuery := cAux + cFilRet + cOrderBy

	RestArea(aArea)
Return cQuery


/*/{Protheus.doc} FORMPAGTO
Fonte que carrega a telinha de multiseleção
@author Mateus Hengle | www.compila.com.br
@since 16/09/2018
@version 1.0
/*/
User Function FORMPAGTO()

	Local MvPar
	Local MvParDef	:= ""
	Local cQuery1  	:= ""
	Local cAliasSX5	:= GetNextAlias()
	Local nIt	   	:= 0
	Local nX 
	Private aTipo:={}

	cAlias := Alias() 					 // Salva Alias Anterior

	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

	If Select(cAliasSX5) > 0
		(cAliasSX5)->(DbCloseArea())
	EndIf

	CursorWait()

	cQuery1 := " SELECT DISTINCT X5_CHAVE, X5_DESCRI "
	cQuery1 += " FROM " + RetSQLName("SX5") + " SX5 "
	cQuery1 += " WHERE X5_TABELA = 'TP' "
	cQuery1 += " AND SX5.D_E_L_E_T_ = '' "
	cQuery1 += " ORDER BY X5_CHAVE "

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery1),cAliasSX5, .F., .T.)
	(cAliasSX5)->(DbGoTop())

	dbSelectArea(cAliasSX5)

	Do While !(EoF())
		nIt++
		Aadd(aTipo,Alltrim((cAliasSX5)->(FIELDGET(FIELDPOS("X5_CHAVE")))) + " - " + Alltrim((cAliasSX5)->(FIELDGET(FIELDPOS("X5_DESCRI")))))
		dbSkip()
	EndDo

	(cAliasSX5)->(DbCloseArea())

	CursorArrow()
	cMVTipo := ""

	nTam := 3
	IF f_Opcoes(@MvPar,"Formas de pagamento",@aTipo,@MvParDef,Nil,Nil,.F.,nIt*4,nIt,.T.,.F.,NIl,.F.,.F.,.T.,Nil)

		For nX := 1 to Len( mvpar )
			cMVTipo := IIF( cMVTipo == "","'" + Substr(mvpar[nX],1,nTam)+ "'", cMVTipo + "," + "'" + Substr(mvpar[nX],1,nTam)+ "'")
		Next

		&MvRet := cMVTipo
	EndIf

	dbSelectArea(cAlias)
	GetdRefresh()

Return cMvTipo

//-------------------------------------------------------------------
/*/{Protheus.doc} DTATEND
Data Atendimento Pleres - Filtro Fina110 - Baixa Automatica
@author  bruno.ferreira
@since   29/03/2019
/*/
//-------------------------------------------------------------------
User  Function DTATEND()

Local cDataRet		:= ''
Private dDTAtend   	:= STOD("")
Private nOpcFin     := 0
Private oDlgFin

oDlgFin := FWDialogModal():New()
oDlgFin:setCloseButton(.T.)
oDlgFin:SetBackground( .F. )  
oDlgFin:SetTitle( "CAIXA GERENCIAL ")	// "Alterar - Oportunidade de Vendas"
oDlgFin:SetEscClose( .F. )
oDlgFin:SetSize(100,200) 
oDlgFin:CreateDialog()
oDlgFin:EnableFormBar( .T. )
oDlgFin:CreateFormBar()
oDlgFin:addCloseButton()

oPnlFol := oDlgFin:GetPanelMain()

TSay():Create(oPnlFol,{|| " Data do Atendimento: " },010,015,,,,,,.T.,,,060,020,,,,,,)
TGet():New(005,075,{|u| if( Pcount( )>0,dDTAtend := u, dDTAtend) },oPnlFol,050,0010,"@!",{|| .T.},,,,.F.,,.T. ,,.F.,{||.T.},.F.,.F.,,.F.,.F. ,"","dDTAtend","",.F.,,.F.,.F. ,.T.,,,)

oDlgFin:AddButton( "Ok", {|| nOpcFin := 1, oDlgFin:oOwner:End()}, "Ok" , , .T., .F., .T., ) //Gravar
oDlgFin:Activate() 

If nOpcFin == 1
	cDataRet 	:= DTOS(dDTAtend)
Endif

Return cDataRet
