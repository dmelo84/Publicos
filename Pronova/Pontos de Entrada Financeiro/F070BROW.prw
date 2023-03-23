#INCLUDE "PROTHEUS.CH" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F070BROW   บAutor  ณ Valdemar Merlim  บ Data ณ  07/08/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada para tratar os descontos dos contratos.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Pronova                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function F070BROW()

    aAdd( aRotina,	{ "Processa Descontos", "U_xProcDesc()", 0 , 7}) //"Le&genda"

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ xProcDesc  บAutor  ณ Valdemar Merlim  บ Data ณ  07/08/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para montar a tela com os descontos que serใo       บฑฑ
ฑฑบ          ณ aplicados.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Pronova                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function xProcDesc()
    Local _lRet := .T.
    Local _cCaption 		:= "Descontos de Contrato"
    Local _oMainWnd		    := NIL
    Private _aArea          := GetArea()
    Private _aSize          := MsAdvSize()		// Size da Dialog .T., .F., 600
    Private _aVetor         := {}
    Private _oDlg1          := NIL
    Private _cPrefixo       := SE1->E1_PREFIXO
    Private _cNumTit        := SE1->E1_NUM
    Private _cParc          := SE1->E1_PARCELA
    Private _cTipo          := SE1->E1_TIPO
    Private _cCodCli        := SE1->E1_CLIENTE+"/"+SE1->E1_LOJA
    Private _cNome          := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME")
    Private _dDtEmi         := DtoC(SE1->E1_EMISSAO)
    Private _dDtVenc        := DtoC(SE1->E1_VENCTO)
    Private _cContrato      := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_XCONTR")
    Private _dDtContr       := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_XDTCON")
    Private _cBanco         := "TRA"        //CriaVar("A6_COD")
    Private _cAg            := "TRADE"      //CriaVar("A6_AGENCIA")
    Private _cConta         := "DESCTRADE " //CriaVar("A6_NUMCON")
    Private _cDesc1         := 0
    Private _cDesc2         := 0
    Private _cDesc3         := 0
    Private _cDesc4         := 0
    Private _cDesc5         := 0
    Private _cDesc6         := 0
    Private _cDesc7         := 0
    Private _cDesc8         := 0
    Private _cDesc9         := 0
    Private _cDesc10        := 0
    Private _cDesc11        := 0
    Private _cDesc12        := 0
    Private _cCC1           := CriaVar("CTT_CUSTO")
    Private _cCC2           := CriaVar("CTT_CUSTO")
    Private _cCC3           := CriaVar("CTT_CUSTO")
    Private _cCC4           := CriaVar("CTT_CUSTO")
    Private _cCC5           := CriaVar("CTT_CUSTO")
    Private _cCC6           := CriaVar("CTT_CUSTO")
    Private _cCC8           := CriaVar("CTT_CUSTO")
    Private _cCC9           := CriaVar("CTT_CUSTO")
    Private _cCC10          := CriaVar("CTT_CUSTO")
    Private _cCC11          := "12.100001"//CriaVar("CTT_CUSTO")
    Private _cCC12          := "15.000001"//CriaVar("CTT_CUSTO")

    If !Alltrim(SE1->E1_TIPO) $ "NF|BOL|NCC"
        MsgStop("Tipo do tํtulo nใo pode ser diferente de NF, BOL OU NCC.")
        _lRet := .F.
    EndIf

    If Empty(SE1->E1_SALDO)
        MsgStop("Tํtulo sem saldo para processar descontos.")
        _lRet := .F.
    EndIf

    If SE1->E1_SALDO <> SE1->E1_VALOR
        MsgInfo("Este tํtulo jแ sofreu movimenta็๕es e a rotina de Desconto de Contratos nใo poderแ ser executada.")
        _lRet := .F.
    EndIf

    If dDataBase > _dDtContr .And. !Empty(_dDtContr)
        MsgInfo("O contrato n๚mero "+Alltrim(_cContrato)+" venceu em "+DtoC(_dDtContr)+" a rotina nใo poderแ ser executada.")
        _lRet := .F.
    EndIf

    DbSelectArea("SA1")
    DbSetOrder(1)
    If DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.)

        _cDesc1   := SA1->A1_XDESC1
        _cDesc2   := SA1->A1_XDESC2
        _cDesc3   := SA1->A1_XDESC3
        _cDesc4   := SA1->A1_XDESC4
        _cDesc5   := SA1->A1_XDESC5
        _cDesc6   := SA1->A1_XDESC6
        _cDesc7   := SA1->A1_XDESC7
        _cDesc8   := SA1->A1_XDESC8
        _cDesc9   := SA1->A1_XDESC9
        _cDesc10  := SA1->A1_XDESC10
        _cDesc12  := SA1->A1_XDESC11
        _cCC1     := SA1->A1_XCC1
        _cCC2     := SA1->A1_XCC2
        _cCC3     := SA1->A1_XCC3
        _cCC4     := SA1->A1_XCC4
        _cCC5     := SA1->A1_XCC5
        _cCC6     := SA1->A1_XCC6
        _cCC7     := SA1->A1_XCC7
        _cCC8     := SA1->A1_XCC8
        _cCC9     := SA1->A1_XCC9
        _cCC10    := SA1->A1_XCC10
        _cCC12    := IIF(!Empty(SA1->A1_XCC11),SA1->A1_XCC11,"15.000001")

    EndIf

    If _lRet
        //_aSize[6],_aSize[5]
        DEFINE MSDIALOG _oDlg1 FROM 0,0 TO 530,781 PIXEL TITLE _cCaption Of _oMainWnd PIXEL STYLE DS_MODALFRAME STATUS

        _oDlg1:lEscClose := .T.

        DEFINE FONT _oFnt    NAME "Arial Black" Size 20,30
        DEFINE FONT _oFnt1   NAME "Arial"       Size 10,16
        DEFINE FONT _oFnt2   NAME "Arial"       Size 15,21
        DEFINE FONT _oFnt3   NAME "Arial"       Size 08,14

        _aTipoPessoa := {"Fisica","Juridica"}

        @ 008, 5  TO 250-22,391-3 LABEL "Dados do Tํtulo" OF _oDlg1 PIXEL

        @ 020, 007 	SAY "Prefixo: " PIXEL //COLOR CLR_HBLUE
        @ 020, 060	MSGET _cPrefixo Picture "@!"             SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 020, 120 	SAY "N๚mero: "  PIXEL
        @ 020, 150	MSGET _cNumTit  Picture "@!"             SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 020, 210 	SAY "Parcela: " PIXEL
        @ 020, 240	MSGET _cParc    Picture "@!"             SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 020, 320 	SAY "Tipo: "    PIXEL
        @ 020, 340	MSGET _cTipo    Picture "@!"             SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 035, 007 	SAY "C๓digo/Loja: "    PIXEL
        @ 035, 060	MSGET _cCodCli  Picture "@!"             SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 035, 120 	SAY "Nome: "    PIXEL
        @ 035, 150	MSGET _cNome    Picture "@!"             SIZE 230,006 When .F.  OF _oDlg1 PIXEL

        @ 050, 007 	SAY "Emissใo: "        PIXEL
        @ 050, 060	MSGET _dDtEmi          Picture "@!"       SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 050, 120 	SAY "Vencto.: "        PIXEL
        @ 050, 150	MSGET _dDtVenc         Picture "@!"       SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 065, 007 	SAY "Contrato: "       PIXEL
        @ 065, 060	MSGET _cContrato       Picture "@!"           SIZE 130,006 When .F.  OF _oDlg1 PIXEL

        @ 065, 210 	SAY "Dt.Contr.: "      PIXEL
        @ 065, 240	MSGET _dDtContr        Picture "@!"           SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 080, 5  TO 250-22,391-3 LABEL "Banco" OF _oDlg1 PIXEL

        @ 090, 007 	SAY "Banco: "          PIXEL  COLOR CLR_HBLUE
        @ 090, 060	MSGET _cBanco          Picture "@!" F3 "SA6"  SIZE 040,006 When .F.  OF _oDlg1 PIXEL Valid !Empty(_cBanco) .And. ExistCpo( "SA6", _cBanco )

        @ 090, 120 	SAY "Ag.: "            PIXEL
        @ 090, 150	MSGET _cAg             Picture "@!"           SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 090, 210 	SAY "Conta: "          PIXEL
        @ 090, 240	MSGET _cConta          Picture "@!"           SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 105, 5  TO 250-22,391-3 LABEL "Descontos de Contrato do Cliente: "  OF _oDlg1 PIXEL

        @ 135, 007 	SAY "Marketing"       PIXEL //COLOR CLR_HRED
        @ 135, 060	MSGET _cDesc1     Picture "@E 999,999,999.99"      SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 135, 120 	SAY "C.Custo"         PIXEL
        @ 135, 150	MSGET _cCC1                                        SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 150, 007 	SAY "Crescimento"     PIXEL //COLOR CLR_HRED
        @ 150, 060	MSGET _cDesc2     Picture "@E 999,999,999.99"      SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 150, 120 	SAY "C.Custo"         PIXEL
        @ 150, 150	MSGET _cCC2                                        SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 165, 007 	SAY "Financeiro"      PIXEL //COLOR CLR_HRED
        @ 165, 060	MSGET _cDesc3     Picture "@E 999,999,999.99"      SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 165, 120 	SAY "C.Custo"         PIXEL
        @ 165, 150	MSGET _cCC3                                        SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 180, 007 	SAY "Inau./Reinau."   PIXEL //COLOR CLR_HRED
        @ 180, 060	MSGET _cDesc4     Picture "@E 999,999,999.99"      SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 180, 120 	SAY "C.Custo"         PIXEL
        @ 180, 150	MSGET _cCC4                                        SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 195, 007 	SAY "Aniverแrio"      PIXEL //COLOR CLR_HRED
        @ 195, 060	MSGET _cDesc5     Picture "@E 999,999,999.99"      SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 195, 120 	SAY "C.Custo"         PIXEL
        @ 195, 150	MSGET _cCC5                                        SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 135, 210 	SAY "Indeniza็ใo"     PIXEL //COLOR CLR_HRED
        @ 135, 240	MSGET _cDesc6     Picture "@E 999,999,999.99"      SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 135, 300 	SAY "C.Custo"         PIXEL
        @ 135, 330	MSGET _cCC6                                        SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 150, 210 	SAY "Fidelidade"      PIXEL //COLOR CLR_HRED
        @ 150, 240	MSGET _cDesc7     Picture "@E 999,999,999.99"      SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 150, 300 	SAY "C.Custo"         PIXEL
        @ 150, 330	MSGET _cCC7                                        SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 165, 210 	SAY "Trocas"          PIXEL //COLOR CLR_HRED
        @ 165, 240	MSGET _cDesc8     Picture "@E 999,999,999.99"      SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 165, 300 	SAY "C.Custo"         PIXEL
        @ 165, 330	MSGET _cCC8                                        SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 180, 210 	SAY "Logํstica"       PIXEL //COLOR CLR_HRED
        @ 180, 240	MSGET _cDesc9     Picture "@E 999,999,999.99"      SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 180, 300 	SAY "C.Custo"         PIXEL
        @ 180, 330	MSGET _cCC9                                        SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 195, 210 	SAY "Comercial"       PIXEL //COLOR CLR_HRED
        @ 195, 240	MSGET _cDesc10    Picture "@E 999,999,999.99"      SIZE 040,006 When .F.  OF _oDlg1 PIXEL
        @ 195, 300 	SAY "C.Custo"         PIXEL
        @ 195, 330	MSGET _cCC10                                       SIZE 040,006 When .F.  OF _oDlg1 PIXEL

        @ 210, 007 	SAY "A Vista"         PIXEL COLOR CLR_HBLUE
        @ 210, 060	MSGET _cDesc11     Picture "@E 999,999,999.99"     SIZE 040,006 When .T.  OF _oDlg1 PIXEL
        @ 210, 120 	SAY "C.Custo"         PIXEL
        @ 210, 150	MSGET _cCC11          F3 "CTT"                     SIZE 040,006 When .T.  OF _oDlg1 PIXEL VALID IIF(!Empty(_cDesc11),!Empty(_cCC11),.T.) .And. IIF(!Empty(_cDesc11),ExistCpo( "CTT", _cCC11 ),.T.)
        
        @ 210, 210 	SAY "Frete FOB"       PIXEL COLOR CLR_HBLUE
        @ 210, 240	MSGET _cDesc12     Picture "@E 999,999,999.99"     SIZE 040,006 When IIF(Empty(_cDesc12),.T.,.F.)  OF _oDlg1 PIXEL
        @ 210, 300 	SAY "C.Custo"         PIXEL
        @ 210, 330	MSGET _cCC12          F3 "CTT"                     SIZE 040,006 When IIF(Empty(_cCC12)  ,.T.,.F.)  OF _oDlg1 PIXEL VALID IIF(!Empty(_cDesc12),!Empty(_cCC12),.T.) .And. IIF(!Empty(_cDesc12),ExistCpo( "CTT", _cCC12 ),.T.)

        @ 314-70, 300 BUTTON OemToAnsi("Sair")          SIZE 035,015          FONT _oDlg1:oFont ACTION {|| _oDlg1:End() }  OF _oDlg1 PIXEL
        @ 314-70, 350 BUTTON OemToAnsi("Gravar")        SIZE 035,015          FONT _oDlg1:oFont ACTION MsgRun("Executando Baixas Desconto de Contrato","Processamento",{|| xExecBxDesc() })  OF _oDlg1 PIXEL

        _nLi := 45

        ACTIVATE MSDIALOG _oDlg1 CENTERED
    EndIf

    RestArea(_aArea)

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ xExecBxDesc บAutor  ณ Valdemar Merlim  บ Data ณ 07/08/20   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para ExecAuto do FINA070 de acordo com os           บฑฑ
ฑฑบ          ณ parametros passados.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Pronova                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function xExecBxDesc()
    Local   aBaixa      := {}
    Local   _n
    Private lMsErroAuto := .F.
    Private _lProc      := .F.
    Private _nVlrDesc   := 0

For _n:=1 To 12

    aBaixa      := {}
    lMsErroAuto := .F.
    _nVlrDesc   := 0

    If _n <= 10
        _cCampoDesc := "A1_XDESC"+Alltrim(Str(_n))
        _cCampoCC   := "A1_XCC"+Alltrim(Str(_n))

        _nDesconto  := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,_cCampoDesc)
        _cCCusto    := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,_cCampoCC)

        _cDescrDesc := FWX3Titulo( _cCampoDesc ) 
        _cHist      := "Desconto "+Alltrim(_cDescrDesc)+" conforme contrato: "+Alltrim(_cContrato)

        _nVlrDesc   := Round(((SE1->E1_VALOR*_nDesconto)/100),2)
    Else
        If _n=11
            _nDesconto  := _cDesc11
            _cCCusto    := _cCC11
            _cDescrDesc := "A Vista"
            _cHist      := "Desconto "+Alltrim(_cDescrDesc)+" conforme contrato: "+Alltrim(_cContrato)
            _nVlrDesc   := Round(((SE1->E1_VALOR*_nDesconto)/100),2)
        Else
            _nDesconto := _cDesc12
            _cCCusto   := _cCC12
            _cDescrDesc := "Frete FOB"
            _cHist      := "Desconto "+Alltrim(_cDescrDesc)+" conforme contrato: "+Alltrim(_cContrato)
            _nVlrDesc   := Round(((SE1->E1_VALOR*_nDesconto)/100),2)
        EndIf

    EndIf
    
    If Empty(_nDesconto)
        Loop
    EndIf

    aBaixa := {{"E1_PREFIXO"  ,SE1->E1_PREFIXO         ,Nil },;
        {"E1_NUM"      ,SE1->E1_NUM                    ,Nil },;
        {"E1_TIPO"     ,SE1->E1_TIPO                   ,Nil },;
        {"E1_CLIENTE"  ,SE1->E1_CLIENTE                ,Nil },;
        {"E1_LOJA"     ,SE1->E1_LOJA                   ,Nil },;
        {"E1_NATUREZ"  ,SE1->E1_NATUREZ                ,Nil },;
        {"E1_PARCELA"  ,SE1->E1_PARCELA                ,Nil },;
        {"AUTMOTBX"    ,"NOR"                          ,Nil },;
        {"AUTBANCO"    ,_cBanco                        ,Nil },;
        {"AUTAGENCIA"  ,_cAg                           ,Nil },;
        {"AUTCONTA"    ,_cConta                        ,Nil },;
        {"AUTDTBAIXA"  ,dDataBase                      ,Nil },;
        {"AUTDTCREDITO",dDataBase                      ,Nil },;
        {"AUTDESCONT"  ,_nVlrDesc                      ,Nil,.T. },;
        {"AUTVALREC"   ,0                              ,Nil,.T. },;
        {"AUTHIST"     ,_cHist                         ,Nil },;
        {"AUTJUROS"    ,0                              ,Nil,.T. }}

    MSExecAuto({|x,y,b,a| Fina070(x,y,b,a)},aBaixa,3,.F.,5) //3 - Baixa de Tํtulo, 5 - Cancelamento de baixa, 6 - Exclusใo de Baixa.

    If lMsErroAuto
        MostraErro()
    Else
        _lProc := .T.
        If !Empty(_cCCusto)
            RecLock("SE5",.F.)
            Replace SE5->E5_CCD With _cCCusto
            SE5->(MsUnLock())
        EndIf

        SE5->(DbCloseArea())

    Endif

Next _n

If _lProc        
        RecLock("SE1",.F.)
        Replace SE1->E1_XPRODES With "S"
        SE1->(MsUnLock())

        SE1->(DbCloseArea())

    _oDlg1:End()
    MsgInfo("Descontos de contrato executados com sucesso! " + SE1->E1_NUM)
Else 
    MsgaLERT("Cliente sem descontos no cadastro! Favor verificar..." + SE1->E1_NUM)
EndIf

Return()
